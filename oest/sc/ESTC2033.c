/*==============================================================================
nom de l'application          :  Interversion des informations retrocession et
				acceptation
nom du source                 : ESTC2033.c
revision                      : $Revision:   1.0  $
date de creation              : 03/06/1997
auteur                        : C. Chavatte (C.G.I.)
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :
	Le fichier des mouvements comptables est lu et reconduit en
	sortie apres que, dans le cas ou le poste cumule se termine
	par 2 ou 4, les zones Acceptation et Retrocession aient ete
	inverses.

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	   ...           ...            ...              ...
[XXX] 02/06/2014 JBG :spot:25773 Modify void main declaration to int main
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
	
/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

/* Fichier en sortie */
FILE	*Kp_GTFil;

/* Structure de lecture des mouvements comptables */
T_RUPTURE_VAR Kbd_RuptGT;

/*---------------------------*/
/* Declaration des fonctions */
/*---------------------------*/

int n_InitGT(T_RUPTURE_VAR  *pbd_Rupt);
int n_ProcessingGT(char **ptb_InRec_Cur);



/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{
        /* alimentation du nom en clair du programme */
        Gbd_Tech.psz_PgmLabel = "Rafraichisssement traites fictifs et segments";

	/* Initialisation des signaux */
	InitSig ();

	if ( n_BeginPgm (argc  ,argv) == ERR )
		ExitPgm ( ERR_XX , "" );

	n_InitGT(&Kbd_RuptGT);

	/* ouverture du fichier en sortie */
	if (n_OpenFileAppl("ESTC2033_O1","wt",&Kp_GTFil) == ERR )
		ExitPgm ( ERR_XX , "" );

	/* Traitement principal */
        if ( n_ProcessingRuptureVar (&Kbd_RuptGT) == ERR )
                ExitPgm ( ERR_XX , "" );
 
	if ( n_CloseFileAppl ("ESTC2033_I1",&(Kbd_RuptGT.pf_InputFil)))
		ExitPgm ( ERR_XX , "" );

	if ( n_CloseFileAppl ("ESTC2033_O1",&Kp_GTFil))
		ExitPgm ( ERR_XX , "" );

	if ( n_EndPgm () == ERR )
		ExitPgm ( ERR_XX , "" );

	exit(OK) ;

}

/*==============================================================================
objet :
	Echange des donnee acceptation et retrocession   

retour :
   OK
==============================================================================*/
int n_ProcessingGT(char **ptb_InRec_Cur)
{
	char c_poste,		/* Chiffre du poste comptable indiquant s'il
				s'agit d'acceptation ou de retrocession */
	*psz_copie[GT_RETKEY_CF-GT_RETCTR_NF];
			/* Copie partielle du GT en entree */
	int n_chpA, n_chpR;	/* Numero du champ dans le tableau */
	int decalage;		/* decalage du au code placement */

	DEBUT_FCT("n_ProcessingGT");

	c_poste=ptb_InRec_Cur[GT_TRNCOD_CF][0];

	/* Controle du suffixe */
	if ( (c_poste=='2') || (c_poste=='4') )
	{
		decalage=0;
		/* Copie des donnees retro dans des variables intermediaires */
		for (n_chpR=GT_RETCTR_NF;n_chpR<=GT_RETKEY_CF;n_chpR++)
		{
			if (n_chpR==GT_PLC_NT) decalage=1;
			else
			{
			  n_chpA=n_chpR-GT_RETCTR_NF-decalage;
			  psz_copie[n_chpA]=ptb_InRec_Cur[n_chpR];
			}
		}
		decalage=0;
		/* Copie d'acceptation dans retro */
		for (n_chpR=GT_RETCTR_NF;n_chpR<=GT_RETKEY_CF;n_chpR++)
		{
			if (n_chpR==GT_PLC_NT) decalage=1;
			else
			{
			  n_chpA=n_chpR+GT_CTR_NF-GT_RETCTR_NF-decalage;
			  ptb_InRec_Cur[n_chpR]=ptb_InRec_Cur[n_chpA];
			}
		}
		/* Copie des variables intermediaires dans acceptation */
		for (n_chpA=GT_CTR_NF;n_chpA<=GT_KEY_NF;n_chpA++)
		{
			n_chpR=n_chpA-GT_CTR_NF;
			ptb_InRec_Cur[n_chpA]=psz_copie[n_chpR];
		}

	}
	
	/********************************************************/
	/* Modifs ANB du 11/12/98                   	        */
	/* pour certains contrats / sections / exercices, forcer*/
	/* l'exercice au dernier exercice existant              */
	/********************************************************/

	/* ACCEPTATION */

	if ((strcmp(ptb_InRec_Cur[GT_CTR_NF],"05T000172") == 0) 
	&& (atoi( ptb_InRec_Cur[GT_SEC_NF] ) == 10)
	&& (atoi( ptb_InRec_Cur[GT_UWY_NF] ) == 1997 )
	&& (atoi( ptb_InRec_Cur[GT_ACY_NF] ) == 1997 )
	&& (atoi( ptb_InRec_Cur[GT_TRNCOD_CF] ) == 11100000 ))
    { 
		ptb_InRec_Cur[GT_CTR_NF] = "05T000450" ;
		ptb_InRec_Cur[GT_SEC_NF] = "1" ;
	}
	
	if ((strcmp(ptb_InRec_Cur[GT_CTR_NF],"05T000173") == 0) 
	&& (atoi( ptb_InRec_Cur[GT_SEC_NF] ) == 10)
	&& (atoi( ptb_InRec_Cur[GT_UWY_NF] ) == 1997 )
	&& (atoi( ptb_InRec_Cur[GT_ACY_NF] ) == 1997 )
	&& (atoi( ptb_InRec_Cur[GT_TRNCOD_CF] ) == 11100000 ))
    { 
		ptb_InRec_Cur[GT_CTR_NF] = "05T000451" ;
		ptb_InRec_Cur[GT_SEC_NF] = "1" ;
	}
	
	/* RETROCESSION */

	if ((strcmp(ptb_InRec_Cur[GT_CTR_NF],"04W059112") == 0) 
	&& (atoi( ptb_InRec_Cur[GT_SEC_NF] ) == 1)
	&& (atoi( ptb_InRec_Cur[GT_UWY_NF] ) > 1996 ))
    { 
		ptb_InRec_Cur[GT_UWY_NF] = "1996" ;
	}    
	
	if ((strcmp(ptb_InRec_Cur[GT_CTR_NF],"04W059113") == 0) 
	&& (atoi( ptb_InRec_Cur[GT_SEC_NF] ) == 1)
	&& (atoi( ptb_InRec_Cur[GT_UWY_NF] ) > 1996 ))
    { 
		ptb_InRec_Cur[GT_UWY_NF] = "1996" ;
	}    
	
	if ((strcmp(ptb_InRec_Cur[GT_CTR_NF],"04W604280") == 0) 
	&& (atoi( ptb_InRec_Cur[GT_SEC_NF] ) == 1)
	&& (atoi( ptb_InRec_Cur[GT_UWY_NF] ) > 1989 ))
    { 
		ptb_InRec_Cur[GT_UWY_NF] = "1989" ;
	}    

	/********************************************************/
	/* Modifs ANB du 17/12/98                   	        */
	/* pour certains contrats / sections / exercices, forcer*/
	/* le montant ou le bilan (pb const/lib)                */
	/********************************************************/

	if ((strcmp(ptb_InRec_Cur[GT_CTR_NF],"06Z049700") == 0) 
	&& (atoi( ptb_InRec_Cur[GT_SEC_NF] ) == 1)
	&& (atoi( ptb_InRec_Cur[GT_UWY_NF] ) == 1994 )
	&& (atoi( ptb_InRec_Cur[GT_ACY_NF] ) == 1994 )
	&& (atoi( ptb_InRec_Cur[GT_BALSHEY_NF] ) == 1996 )
	&& (atoi( ptb_InRec_Cur[GT_TRNCOD_CF] ) == 31400100 ))
    { 
		ptb_InRec_Cur[GT_AMT_M] = "0" ;
		ptb_InRec_Cur[GT_ESTAMT_M] = "0" ;
	}    
	if ((strcmp(ptb_InRec_Cur[GT_CTR_NF],"06Z049700") == 0) 
	&& (atoi( ptb_InRec_Cur[GT_SEC_NF] ) == 1)
	&& (atoi( ptb_InRec_Cur[GT_UWY_NF] ) == 1995 )
	&& (atoi( ptb_InRec_Cur[GT_ACY_NF] ) == 1995 )
	&& (atoi( ptb_InRec_Cur[GT_BALSHEY_NF] ) == 1996 )
	&& (atoi( ptb_InRec_Cur[GT_TRNCOD_CF] ) == 31401100 ))
    { 
		ptb_InRec_Cur[GT_BALSHEY_NF] = "1995" ;
	}    


	if ((strcmp(ptb_InRec_Cur[GT_CTR_NF],"06Z051400") == 0) 
	&& (atoi( ptb_InRec_Cur[GT_SEC_NF] ) == 1)
	&& (atoi( ptb_InRec_Cur[GT_UWY_NF] ) == 1994 )
	&& (atoi( ptb_InRec_Cur[GT_ACY_NF] ) == 1995 )
	&& (atoi( ptb_InRec_Cur[GT_BALSHEY_NF] ) == 1996 )
	&& (atoi( ptb_InRec_Cur[GT_TRNCOD_CF] ) == 31401100 ))
    { 
		ptb_InRec_Cur[GT_BALSHEY_NF] = "1995" ;
		ptb_InRec_Cur[GT_AMT_M] = "198606.33" ;
		ptb_InRec_Cur[GT_ESTAMT_M] = "198606.33" ;
	}    
    if ((strcmp(ptb_InRec_Cur[GT_CTR_NF],"06Z051400") == 0) 
	&& (atoi( ptb_InRec_Cur[GT_SEC_NF] ) == 1)
	&& (atoi( ptb_InRec_Cur[GT_UWY_NF] ) == 1994 )
	&& (atoi( ptb_InRec_Cur[GT_ACY_NF] ) == 1996 )
	&& (atoi( ptb_InRec_Cur[GT_BALSHEY_NF] ) == 1997 )
	&& (atoi( ptb_InRec_Cur[GT_TRNCOD_CF] ) == 31401100 ))
    { 
		ptb_InRec_Cur[GT_BALSHEY_NF] = "1996" ;
		ptb_InRec_Cur[GT_AMT_M] = "175624.5" ;
		ptb_InRec_Cur[GT_ESTAMT_M] = "175624.5" ;
	}    
	

	if ((strcmp(ptb_InRec_Cur[GT_CTR_NF],"06Z088900") == 0) 
	&& (atoi( ptb_InRec_Cur[GT_SEC_NF] ) == 1)
	&& (atoi( ptb_InRec_Cur[GT_UWY_NF] ) == 1997 )
	&& (atoi( ptb_InRec_Cur[GT_ACY_NF] ) == 1997 )
	&& (atoi( ptb_InRec_Cur[GT_OCCYEA_NF] ) == 1996 )
	&& (atoi( ptb_InRec_Cur[GT_BALSHEY_NF] ) == 1997 )
	&& (atoi( ptb_InRec_Cur[GT_TRNCOD_CF] ) == 31421000 ))
    { 
		ptb_InRec_Cur[GT_AMT_M] = "0" ;
		ptb_InRec_Cur[GT_ESTAMT_M] = "0" ;
	}    
	

	if ((strcmp(ptb_InRec_Cur[GT_CTR_NF],"06Z212100") == 0) 
	&& (atoi( ptb_InRec_Cur[GT_SEC_NF] ) == 1)
	&& (atoi( ptb_InRec_Cur[GT_UWY_NF] ) == 1983 )
	&& (atoi( ptb_InRec_Cur[GT_ACY_NF] ) == 1995 )
	&& (atoi( ptb_InRec_Cur[GT_BALSHEY_NF] ) == 1996 )
	&& (atoi( ptb_InRec_Cur[GT_TRNCOD_CF] ) == 31401100 ))
    { 
		ptb_InRec_Cur[GT_BALSHEY_NF] = "1995" ;
		ptb_InRec_Cur[GT_AMT_M] = "7887.55" ;
		ptb_InRec_Cur[GT_ESTAMT_M] = "7887.55" ;
	}    


	if ((strcmp(ptb_InRec_Cur[GT_CTR_NF],"06Z232500") == 0) 
	&& (atoi( ptb_InRec_Cur[GT_SEC_NF] ) == 1)
	&& (atoi( ptb_InRec_Cur[GT_UWY_NF] ) == 1997 )
	&& (atoi( ptb_InRec_Cur[GT_ACY_NF] ) == 1997 )
	&& (atoi( ptb_InRec_Cur[GT_BALSHEY_NF] ) == 1997 )
	&& (strcmp(ptb_InRec_Cur[GT_CUR_CF],"FRF") == 0) 
	&& (atoi( ptb_InRec_Cur[GT_TRNCOD_CF] ) == 31421000 ))
    { 
		ptb_InRec_Cur[GT_AMT_M] = "0" ;
		ptb_InRec_Cur[GT_ESTAMT_M] = "0" ;
	}    


	if ((strcmp(ptb_InRec_Cur[GT_CTR_NF],"06Z242901") == 0) 
	&& (atoi( ptb_InRec_Cur[GT_SEC_NF] ) == 1)
	&& (atoi( ptb_InRec_Cur[GT_UWY_NF] ) == 1994 )
	&& (atoi( ptb_InRec_Cur[GT_ACY_NF] ) == 1994 )
	&& (atoi( ptb_InRec_Cur[GT_BALSHEY_NF] ) == 1996 )
	&& (atoi( ptb_InRec_Cur[GT_TRNCOD_CF] ) == 31400100 ))
    { 
		ptb_InRec_Cur[GT_AMT_M] = "0" ;
		ptb_InRec_Cur[GT_ESTAMT_M] = "0" ;
	}    
	if ((strcmp(ptb_InRec_Cur[GT_CTR_NF],"06Z242901") == 0) 
	&& (atoi( ptb_InRec_Cur[GT_SEC_NF] ) == 1)
	&& (atoi( ptb_InRec_Cur[GT_UWY_NF] ) == 1994 )
	&& (atoi( ptb_InRec_Cur[GT_ACY_NF] ) == 1995 )
	&& (atoi( ptb_InRec_Cur[GT_BALSHEY_NF] ) == 1996 )
	&& (atoi( ptb_InRec_Cur[GT_TRNCOD_CF] ) == 31401100 ))
    { 
		ptb_InRec_Cur[GT_BALSHEY_NF] = "1995" ;
	}    


	if ((strcmp(ptb_InRec_Cur[GT_CTR_NF],"06Z300400") == 0) 
	&& (atoi( ptb_InRec_Cur[GT_SEC_NF] ) == 1)
	&& (atoi( ptb_InRec_Cur[GT_UWY_NF] ) == 1997 )
	&& (atoi( ptb_InRec_Cur[GT_ACY_NF] ) == 1997 )
	&& (atoi( ptb_InRec_Cur[GT_OCCYEA_NF] ) == 1996 )
	&& (atoi( ptb_InRec_Cur[GT_BALSHEY_NF] ) == 1997 )
	&& (atoi( ptb_InRec_Cur[GT_TRNCOD_CF] ) == 31421000 ))
    { 
		ptb_InRec_Cur[GT_AMT_M] = "0" ;
		ptb_InRec_Cur[GT_ESTAMT_M] = "0" ;
	}    


	if ((strcmp(ptb_InRec_Cur[GT_CTR_NF],"06Z338800") == 0) 
	&& (atoi( ptb_InRec_Cur[GT_SEC_NF] ) == 1)
	&& (atoi( ptb_InRec_Cur[GT_UWY_NF] ) == 1983 )
	&& (atoi( ptb_InRec_Cur[GT_ACY_NF] ) == 1995 )
	&& (atoi( ptb_InRec_Cur[GT_BALSHEY_NF] ) == 1996 )
	&& (atoi( ptb_InRec_Cur[GT_TRNCOD_CF] ) == 31401100 ))
    { 
		ptb_InRec_Cur[GT_BALSHEY_NF] = "1995" ;
	}    


	if ((strcmp(ptb_InRec_Cur[GT_CTR_NF],"06Z364600") == 0) 
	&& (atoi( ptb_InRec_Cur[GT_SEC_NF] ) == 1)
	&& (atoi( ptb_InRec_Cur[GT_UWY_NF] ) == 1997 )
	&& (atoi( ptb_InRec_Cur[GT_ACY_NF] ) == 1997 )
	&& (atoi( ptb_InRec_Cur[GT_OCCYEA_NF] ) == 1996 )
	&& (atoi( ptb_InRec_Cur[GT_BALSHEY_NF] ) == 1997 )
	&& (atoi( ptb_InRec_Cur[GT_TRNCOD_CF] ) == 31421000 ))
    { 
		ptb_InRec_Cur[GT_AMT_M] = "0" ;
		ptb_InRec_Cur[GT_ESTAMT_M] = "0" ;
	}    
 	     ptb_InRec_Cur[GT_GAAP_NF]="1";
    if((ptb_InRec_Cur[GT_TRNCOD_CF][7]== 'A')|| (ptb_InRec_Cur[GT_TRNCOD_CF][7]== 'B'))
    	   ptb_InRec_Cur[GT_GAAP_NF]="2";
    if((ptb_InRec_Cur[GT_TRNCOD_CF][7]== 'C')|| (ptb_InRec_Cur[GT_TRNCOD_CF][7]== 'D'))
    	   ptb_InRec_Cur[GT_GAAP_NF]="3";
    if((ptb_InRec_Cur[GT_TRNCOD_CF][7]== 'E')|| (ptb_InRec_Cur[GT_TRNCOD_CF][7]== 'F'))
    	   ptb_InRec_Cur[GT_GAAP_NF]="4";
    if((ptb_InRec_Cur[GT_TRNCOD_CF][7]== 'G')|| (ptb_InRec_Cur[GT_TRNCOD_CF][7]== 'H'))
    	   ptb_InRec_Cur[GT_GAAP_NF]="5";
 

	/* Reconduction du fichier */
	n_WriteCols(Kp_GTFil,ptb_InRec_Cur,'~',0);


	RETURN_VAL (OK);
}

/*==============================================================================
objet :
  Initialisation de la gestion de rupture 

retour :
	OK
=============================================================================*/
int n_InitGT(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_InitGT");

	memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

	/* Ouverture du fichier maitre */
	if (n_OpenFileAppl ("ESTC2033_I1","rt",&(pbd_Rupt->pf_InputFil)))
		RETURN_VAL (ERR);

	/* Pas de gestion de rupture */
	pbd_Rupt->n_NbRupture = 0;

	/* Fonction executee pour chaque ligne du GT: */
	pbd_Rupt->n_ActionLigne     = n_ProcessingGT;

	/* Separateur utilise dans le fichier en entree */
	pbd_Rupt->c_Separ               = '~' ;

	RETURN_VAL (OK);
}
