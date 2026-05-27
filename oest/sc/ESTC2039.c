/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Introduction des postes cumuls et conversion
                                en devise principale
nom du source                 : ESTC2039.c
revision                      : $Revision: 1.3 $
date de creation              : 04/06/1997
auteur                        : C. Chavatte - R. Cassis
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :


------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	5/11/1999		Anb			Mise à jour du code ADJCOD_CT pour les affaires terminées
	8/6/2000		Anb			Prise en compte systématique de l'établissement présent dans
								le fichier Périmètre
	6/2/2001		Anb			Prise en compte (provisoirement en dur) des années limites pour bilan et AC
								dans le fichier comptable
	28/2/2001		Anb			Prise en compte des ES dans le calcul du bilan - 1
								(2ème suffixe = 4)
	05/12/2002		O.Arik			affectation dans le regroupement statutaire pour bilan <= 2002 des postes non zilmerisé
   17/04/2007   Roger Cassis    SPOT 14059 - Ce programme est la copie du ESTC2034 sauf que la condition à l'emplacement V006 est supprimée
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
_________________
MODIFICATION    [008]
Auteur:         D.GATIBELZA
Date:           29/07/2010
Version:        10.1
Description:    ESTVIE18754 Creation ligne fds egal. stab dans onglet Primes ( pour tout et tous )
                faire le 1093 en dupliquant comme le 1063 et le 1094 comme le 1064
/*==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include "estserv.h"

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

#define Kn_MaxPostes 2000        /* Le nombre max de postes est fixe a 2000 (modif O.Arik:28/05/2001 1000->2000 suite au dep. de mem.) */

char Ksz_vide[1];               /* Chaine vide pour initialisation */

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/
int Kn_BALSHTYEA_NF;
char Ksz_BALSHTYEA_NF_1[10];
short Ks_acmtrs_nt;
T_TRSLNK Kbd_TRSLNK[Kn_MaxPostes];
int Kn_NbLigTrslnk;

FILE    *Kp_OutputFil,  /* pointeur sur le fichier de sortie */
        *Kp_CoursFil,   /* fichier des cours devise */
        *Kp_TrslnkFil,  /* fichier des postes */
	*Kp_OutGTB1;       /* fichier Bilan -1 en sortie */

T_RUPTURE_VAR bd_RuptPerim; /* gestion rupture sur perimetre */
T_RUPTURE_SYNC_VAR bd_RuptGT; /* gestion synchro GT-perimetre */
T_RUPTURE_SYNC_VAR bd_RuptTrslnk; /* gestion synchro trslnk-perimetre */

int n_InitGT (T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int n_ActionLigneGT(char **ptb_InRecOwner,char **pbd_InRecChild) ;
int n_ConditionSyncGT(char **ptb_InRecOwner,char **pbd_InRecChild);

int n_InitPerim(T_RUPTURE_VAR *pbd_Rupt) ;
int n_ActionLignePerim(char **pbd_InRec_Cur);
int n_ActionPereSansFilsGT(char **ptb_InRecOwner );
int n_ActionFilsSansPereGT(char **ptb_InRecOwner );

int n_ChargerTRSLNK ();

/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{

        /* Initialisation des signaux */
        InitSig () ;

        if ( n_BeginPgm (argc  ,argv) == ERR )
                ExitPgm ( ERR_XX , "" );

	Kn_BALSHTYEA_NF = n_GetIntArgv(1) ;
	sprintf(Ksz_BALSHTYEA_NF_1,"%d", Kn_BALSHTYEA_NF - 1 ) ;

        /* ouverture des fichiers */

        if ( n_OpenFileAppl ("ESTC2039_O1","wt",&Kp_OutputFil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2039_O2","wt",&Kp_OutGTB1) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2039_I4","rb",&Kp_CoursFil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2039_I3","rb",&Kp_TrslnkFil) == ERR )
                ExitPgm ( ERR_XX , "" );


        /* Initialisation de la varible bd_RuptPerim */
        if ( n_InitPerim(&bd_RuptPerim) )
                ExitPgm ( ERR_XX , "" );

        /* Initialisation de la varible bd_RuptGT */
        if ( n_InitGT(&bd_RuptGT) )
                ExitPgm ( ERR_XX , "" );

        /* Chargement des postes en memoire (PRS_CF ==500 )*/
        /* modif O.Arik:29/05/2001 on sort en cas de dep. de memoire*/
        if(n_ChargerTRSLNK () == ERR )
                        ExitPgm( ERR_XX , "" ) ;


        /* lancement du traitement du fichier */
        if ( n_ProcessingRuptureVar (&bd_RuptPerim) == ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2039_O1",&Kp_OutputFil)== ERR)
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2039_O2",&Kp_OutGTB1)== ERR)
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl("ESTC2039_I1",&(bd_RuptPerim.pf_InputFil))== ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2039_I2",&(bd_RuptGT.pf_InputFil))== ERR)
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2039_I3",&Kp_TrslnkFil)== ERR)
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2039_I4",&Kp_CoursFil)== ERR)
                ExitPgm ( ERR_XX , "" );

        if ( n_EndPgm () == ERR )
                ExitPgm ( ERR_XX , "" );

        exit(OK) ;

}



/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du
        fichier maitre.

retour :
        OK
==============================================================================*/
int n_InitPerim(T_RUPTURE_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitPerim");

        memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

        if ( n_OpenFileAppl ("ESTC2039_I1","rt",&(pbd_Rupt->pf_InputFil)))
                ExitPgm ( ERR_XX , "" );

        pbd_Rupt->n_NbRupture = 0  ;

        pbd_Rupt->n_ActionLigne = n_ActionLignePerim ;

        pbd_Rupt->c_Separ = SEPARATEUR ;

        RETURN_VAL(OK);
}

/*==============================================================================
objet :
        fonction lancee pour chaque ligne du maitre

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePerim( char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_ActionLignePerim");

        /* synchronisation du fichier GT pour chaque ligne */
        n_ProcessingRuptureSyncVar (&bd_RuptGT, ptb_InRec_Cur) ;

        RETURN_VAL(OK);
}

/*==============================================================================
objet :
        Initialisation de la synchronisation du maitre avec l'esclave GT

retour :
        OK
==============================================================================*/
int n_InitGT(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitGT");

        memset( pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

        /* ouverture du fichier esclave */
        n_OpenFileAppl ("ESTC2039_I2","rt",&(pbd_Rupt->pf_InputFil));

        pbd_Rupt->n_NbRupture = 0  ;

        /* fonction du test de la ligne du maitre avec l'esclave */
        pbd_Rupt->ConditionEndSync      = n_ConditionSyncGT ;

        /* fonction d'action sur la ligne courante du fichier esclave */
        pbd_Rupt->n_ActionLigne         = n_ActionLigneGT ;

        /* fonction d'action quand le maitre n'a pas de fils GT */
        pbd_Rupt->n_PereSansFils = n_ActionPereSansFilsGT;

	/* fonction d'action quand le maitre n'a pas de fils GT */
        pbd_Rupt->n_FilsSansPere = n_ActionFilsSansPereGT;


        pbd_Rupt->c_Separ               = SEPARATEUR ;

        RETURN_VAL(OK);
}

/*==============================================================================
objet :
        fonction de test de rupture du niveau 1

retour :
        0       ---> pbd_InRecOwner = pbd_InRecChild
                        ( egalite de rubriques a synchroniser)
        > 0     ---> pbd_InRecOwne> > pbd_InRecChild
        < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncGT(
        char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
        char **pbd_InRecChild  /* adresse de la ligne de l'esclave */
        )
{
        int ret;

        DEBUT_FCT("n_ConditionSyncGT");

        if ( (ret = strcmp(pbd_InRecOwner[PER_CTR_NF],pbd_InRecChild[GT_CTR_NF])) != 0 )
                RETURN_VAL(ret);
        if ( (ret = strcmp(pbd_InRecOwner[PER_SEC_NF],pbd_InRecChild[GT_SEC_NF])) != 0 )
                RETURN_VAL(ret);
        if ( (ret = strcmp(pbd_InRecOwner[PER_UWY_NF],pbd_InRecChild[GT_UWY_NF])) != 0 )
                RETURN_VAL(ret);

        RETURN_VAL(0);
}

/*==============================================================================
objet:
        Lit le fichier binaire des postes et les met en memoire

==============================================================================*/
int n_ChargerTRSLNK ()
{
        int n_EOF = 0;
        T_TRSLNK bd_Lu;
        char MsgAno[300];

        DEBUT_FCT("n_ChargerTRSLNK");

        Kn_NbLigTrslnk=0;

        /* Tant que la fin de fichier n'est pas atteinte,... */
        while (n_EOF == 0)
        {
                if (fread(&bd_Lu,sizeof(T_TRSLNK),1,Kp_TrslnkFil)<=0)
                        n_EOF = 1;
                else {

                        if ( Kn_NbLigTrslnk + 1 >= Kn_MaxPostes ) {
                                /* depassement tableau */
                                sprintf(MsgAno,"The number of link (/PRS %d /ACMTRS %d /DETTRS %s) overflows the program's storage capacity",
                                                bd_Lu.PRS_CF,
                                                bd_Lu.ACMTRS_NT,
                                                bd_Lu.DETTRS_CF);
                                n_WriteAno(MsgAno);
                                RETURN_VAL(ERR);
                        }

                        else if (bd_Lu.PRS_CF == 500)
                                /* Enregistrement ecrit dans le tableau */
                                Kbd_TRSLNK[Kn_NbLigTrslnk++] = bd_Lu;
                }
        }
        RETURN_VAL(OK);
}

/*==============================================================================
objet :
        fonction de recherche du poste
retour :
        0               ---> Pas de rupture
        < 0     ---> On n'est pas arrive au bloc synchrone
        > 0     ---> On a depasse le bloc synchrone
==============================================================================*/
int n_RechPoste(char *sz_poste)
{
        int n_indice, ret;

        DEBUT_FCT("n_RechPoste");

        Ksz_vide[0]=0;
        n_indice=0;
        while (1==1)
        {
                /* Comparaison des codes */
                ret=strcmp(sz_poste,Kbd_TRSLNK[n_indice].DETTRS_CF);

                /* S'ils sont egaux, retourner l'indice */
                if (ret==0) RETURN_VAL(n_indice);

                /* Si la ligne est passee, retourner -1 (echec) */
                if (ret<0) RETURN_VAL(-1);

                /* Ligne suivante */
                n_indice++;

                /* Si on est a la fin du tableau, echec */
                if (n_indice>=Kn_NbLigTrslnk) RETURN_VAL(-1);
        }
}


/*==============================================================================
objet :
        fonction lancee pour chaque ligne du GT synchronisee avec le perimetre

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGT(
        char **ptb_InRecOwner ,/* adresse de la ligne du maitre */
        char **ptb_InRecChild  /* adresse de la ligne de l'esclave */
)
{
        double  d_montant,d_aliment,d_taux;
        char    sz_montant[30],sz_aliment[30];
        char    sz_devise[4],sz_GT[500], sz_acmtrs[10]="";
        int i;
	int flag_B1 =0 ;

        DEBUT_FCT("n_ActionLigneGT");

		/* Récupération prévision pour calcul situation bilan - 1 */

		if ( ptb_InRecChild[GT_TRNCOD_CF][7] == '2' )
			{
			ptb_InRecChild[GT_TRNCOD_CF][7] = '0' ;

			/* Modif Anb du 28/2/01 pour prise en cpte des ES */

			if ( ptb_InRecChild[GT_TRNCOD_CF][1] == '4' )
				{
				ptb_InRecChild[GT_TRNCOD_CF][1] = '1' ;
				}

			/* Fin modif */

			flag_B1 =1 ;
/*
			if (ptb_InRecChild[GT_TRNCOD_CF][0] == '1' || ptb_InRecChild[GT_TRNCOD_CF][0] == '3')
				{
		    		ptb_InRecChild[GT_BALSHEY_NF] = Ksz_BALSHTYEA_NF_1  ;
				ptb_InRecChild[GT_BALSHRMTH_NF] = "12" ;
				ptb_InRecChild[GT_BALSHRDAY_NF] = "31" ;
				}  R. Cassis supprime pour ne pas changer la date estimés 16/05/2007 */
			/*else
				{
				d_montant=atof(ptb_InRecChild[GT_AMT_M]);
                d_montant *= -1;
				sprintf(sz_montant,"%.3lf",d_montant);
                ptb_InRecChild[GT_AMT_M]=sz_montant;
                }*/
			}

		for(i=GT_ESTCUR_CF;i<GT_NBCOL;i++) ptb_InRecChild[i]="" ;
                ptb_InRecChild[GT_NBCOL] = 0 ;

        /* Synchronisation du fichier trslnk afin de recuperer ACMTRS_NT */
        i = n_RechPoste(ptb_InRecChild[GT_TRNCOD_CF]);
        if (i==-1)
        {
          RETURN_VAL(OK);
        }
        else
		{
            Ks_acmtrs_nt=Kbd_TRSLNK[i].ACMTRS_NT;
        }

        sprintf(sz_acmtrs,"%d",Ks_acmtrs_nt);

	/* rajouté par O. Arik le 05/12/2002 */
	if ( (atoi(ptb_InRecOwner[PER_SSD_CF])!=14)&&
		(atoi(ptb_InRecChild[GT_BALSHEY_NF])<=2002)&&
		(atoi( ptb_InRecChild[GT_TRNCOD_CF] ) == 31400100) )
        sprintf(sz_acmtrs,"%d",1063);

	/* rajouté par O. Arik le 05/12/2002 */
	if ( (atoi(ptb_InRecOwner[PER_SSD_CF])!=14)&&
		(atoi(ptb_InRecChild[GT_BALSHEY_NF])<=2002)&&
		(atoi( ptb_InRecChild[GT_TRNCOD_CF] ) == 31401100) )
        sprintf(sz_acmtrs,"%d",1064);

		/* Calcul du taux de conversion */

        /* Pour tous les traites           */
        /* si devise<>devise principale, conversion du montant  */
        ptb_InRecChild[GT_ESTAMT_M]=ptb_InRecChild[GT_AMT_M];
        ptb_InRecChild[GT_ESTCUR_CF]=ptb_InRecChild[GT_CUR_CF];

        if (strcmp(ptb_InRecOwner[PER_PCPCUR_CF],ptb_InRecChild[GT_CUR_CF])!=0)
        {
                d_taux=d_GetTaux(Kp_CoursFil,
                                (char)atoi(ptb_InRecOwner[PER_SSD_CF]),
                                (short)atoi(ptb_InRecChild[GT_BALSHEY_NF]),
                                ptb_InRecChild[GT_CUR_CF],
                                ptb_InRecOwner[PER_PCPCUR_CF]);
                /* Si le taux est trouve, conversion*/
                if (d_taux>0)
                {
                  d_montant=atof(ptb_InRecChild[GT_AMT_M]);
                  d_montant *= d_taux;
                }
                /* Sinon, montant mis a -1 */
                else d_montant = -1;

                /* Remplacement du montant */
                sprintf(sz_montant,"%.3lf",d_montant);
                ptb_InRecChild[GT_ESTAMT_M]=sz_montant;
        }

        /* Calcul du taux de conversion (cours: 31/12/exercice precedent) */

		d_taux=d_GetTaux(Kp_CoursFil,
                        (char)atoi(ptb_InRecOwner[PER_SSD_CF]),
                        (short)atoi(ptb_InRecOwner[PER_UWY_NF])-1,
                        ptb_InRecOwner[PER_EGPCUR_CF],
                        ptb_InRecOwner[PER_PCPCUR_CF]);

        if (d_taux>0)
        {
          /* Conversion de l'aliment brut SCOR */
          d_aliment=atof(ptb_InRecOwner[PER_SCOEGP_M]);
          d_aliment *= d_taux;
        }
        /* Sinon, montant mis a -1 */
		else d_aliment=-1;

		/* Remplacement de l'aliment */
        sprintf(sz_aliment,"%.3lf",d_aliment);


        ptb_InRecChild[GT_ESTCUR_CF]=ptb_InRecOwner[PER_PCPCUR_CF];

        ptb_InRecChild[GT_NAT_CF]       = ptb_InRecOwner[PER_NAT_CF];
        ptb_InRecChild[GT_ACMTRS_NT]    = sz_acmtrs;
        ptb_InRecChild[GT_ESTCTR_NF]    = ptb_InRecOwner[PER_ESTCTR_NF];
        ptb_InRecChild[GT_ESTSEC_NF]    = ptb_InRecOwner[PER_ESTSEC_NF];
        ptb_InRecChild[GT_LOB_CF]       = ptb_InRecOwner[PER_LOB_CF];
        ptb_InRecChild[GT_SCOEGP_M]     = sz_aliment;
        ptb_InRecChild[GT_ESTCRB_CT]    = ptb_InRecOwner[PER_ESTCRB_CT];
        ptb_InRecChild[GT_LIFTRTTYP_CF] = ptb_InRecOwner[PER_LIFTRTTYP_CF];
        ptb_InRecChild[GT_ACCADMTYP_CT] = ptb_InRecOwner[PER_ACCADMTYP_CT];
        ptb_InRecChild[GT_SECSTS_CT]    = ptb_InRecOwner[PER_SECSTS_CT];
        ptb_InRecChild[GT_BRK_NF]       = ptb_InRecOwner[PER_PRD_NF];
		ptb_InRecChild[GT_PRD_NF]       = ptb_InRecOwner[PER_PRD_NF];
        ptb_InRecChild[GT_SEG_NF]       = ptb_InRecOwner[PER_SEG_NF];
        ptb_InRecChild[GT_COMACC_B]     = "0";

        ptb_InRecChild[GT_ADJCOD_CT]    = "0";
        ptb_InRecChild[GT_RETCOD_CT]    = "0";
        ptb_InRecChild[GT_DETTRS_CF]    = "";

        ptb_InRecChild[GT_ADJSIG_B]     = "0";
        ptb_InRecChild[GT_ESTUWY_NF]    = "";

        ptb_InRecChild[GT_PROPER_N]     = ptb_InRecOwner[PER_ACCFRQ_CT];
        ptb_InRecChild[GT_UWGRP_CF]     = ptb_InRecOwner[PER_UWGRP_CF];
        ptb_InRecChild[GT_RTOCTY_CF]    = "";

	/************************************************************/
	/* Modifs du 8/06/00 - par A.BORDET 			            */
	/* Prise en cpte systématique de l'établissement présent    */
	/* dans le fichier souscription                             */
	/************************************************************/

	    ptb_InRecChild[GT_ESB_CF]       = ptb_InRecOwner[PER_ACCESB_CF];


	/************************************************************/
	/* Modifs du 27/03/98 - par M.HA-THUC 			            */
	/* l'exercice est force a l'annee de compte		            */
	/* si type comptable = 1 			                 	    */
	/* ou si type comptable = 3 et postes prime/charge/depot	*/
	/************************************************************/
/* Modif temporaire pour les différences PC*/
	if ( atoi( ptb_InRecOwner[PER_ACCADMTYP_CT] ) == 1 ||
		( atoi( ptb_InRecOwner[PER_ACCADMTYP_CT] ) == 3
		&& (sz_acmtrs[1] == '0'
		||  sz_acmtrs[1] == '1'
		||  sz_acmtrs[1] == '3'
		||  sz_acmtrs[1] == '5'
		||  sz_acmtrs[1] == '6')))
	{
		ptb_InRecChild[GT_UWY_NF] = ptb_InRecChild[GT_ACY_NF] ;
	}

	/********************************************************/
	/* Modifs du 05/10/98 - par A.BORDET         	        */
	/* pour certains contrats / sections / exercices, forcer*/
	/* l'exercice au dernier exercice existant              */
	/********************************************************/

	if ((strcmp(ptb_InRecChild[GT_CTR_NF],"04Z0N0009") == 0)
	&& (atoi( ptb_InRecChild[GT_SEC_NF] ) == 1)
	&& (atoi( ptb_InRecChild[GT_UWY_NF] ) >= 1994 ))
    {
		ptb_InRecChild[GT_UWY_NF] = "1994" ;
	}

	if ((strcmp(ptb_InRecChild[GT_CTR_NF],"04Z085211") == 0)
	&& (atoi( ptb_InRecChild[GT_SEC_NF] ) == 2)
	&& (atoi( ptb_InRecChild[GT_UWY_NF] ) >= 1985 ))
    {
		ptb_InRecChild[GT_UWY_NF] = "1985" ;
	}

	if ((strcmp(ptb_InRecChild[GT_CTR_NF],"04Z085211") == 0)
	&& (atoi( ptb_InRecChild[GT_SEC_NF] ) == 3)
	&& (atoi( ptb_InRecChild[GT_UWY_NF] ) >= 1985 ))
    {
		ptb_InRecChild[GT_UWY_NF] = "1985" ;
	}

	if ((strcmp(ptb_InRecChild[GT_CTR_NF],"04Z085212") == 0)
	&& (atoi( ptb_InRecChild[GT_SEC_NF] ) == 2)
	&& (atoi( ptb_InRecChild[GT_UWY_NF] ) >= 1985 ))
    {
		ptb_InRecChild[GT_UWY_NF] = "1985" ;
	}

	if ((strcmp(ptb_InRecChild[GT_CTR_NF],"04Z085214") == 0)
	&& (atoi( ptb_InRecChild[GT_SEC_NF] ) == 1)
	&& (atoi( ptb_InRecChild[GT_UWY_NF] ) >= 1995 ))
    {
		ptb_InRecChild[GT_UWY_NF] = "1995" ;
	}

	if ((strcmp(ptb_InRecChild[GT_CTR_NF],"04Z0N0136") == 0)
	&& (atoi( ptb_InRecChild[GT_SEC_NF] ) == 1)
	&& (atoi( ptb_InRecChild[GT_UWY_NF] ) >= 1996 ))
    {
		ptb_InRecChild[GT_UWY_NF] = "1996" ;
	}

	/*if ((strcmp(ptb_InRecChild[GT_CTR_NF],"05T000172") == 0)
	&& (atoi( ptb_InRecChild[GT_SEC_NF] ) == 10)
	&& (atoi( ptb_InRecChild[GT_UWY_NF] ) == 1997 )
	&& (atoi( ptb_InRecChild[GT_ACY_NF] ) == 1997 )
	&& (atoi( ptb_InRecChild[GT_TRNCOD_CF] ) == 11100000 ))
    {
		ptb_InRecChild[GT_CTR_NF] = "05T000450" ;
		ptb_InRecChild[GT_SEC_NF] = "1" ;
	}*/

	/*if ((strcmp(ptb_InRecChild[GT_CTR_NF],"05T000173") == 0)
	&& (atoi( ptb_InRecChild[GT_SEC_NF] ) == 10)
	&& (atoi( ptb_InRecChild[GT_UWY_NF] ) == 1997 )
	&& (atoi( ptb_InRecChild[GT_ACY_NF] ) == 1997 )
	&& (atoi( ptb_InRecChild[GT_TRNCOD_CF] ) == 11100000 ))
    {
		ptb_InRecChild[GT_CTR_NF] = "05T000451" ;
		ptb_InRecChild[GT_SEC_NF] = "1" ;
	}*/

	if ((strcmp(ptb_InRecChild[GT_CTR_NF],"04Z085671") == 0)
	&& (atoi( ptb_InRecChild[GT_SEC_NF] ) == 2)
	&& (atoi( ptb_InRecChild[GT_UWY_NF] ) > 1996 ))
    {
		ptb_InRecChild[GT_UWY_NF] = "1996" ;
	}

	if ((strcmp(ptb_InRecChild[GT_CTR_NF],"05Z120120") == 0)
	&& (atoi( ptb_InRecChild[GT_SEC_NF] ) == 1)
	&& (atoi( ptb_InRecChild[GT_UWY_NF] ) > 1992 ))
    {
		ptb_InRecChild[GT_UWY_NF] = "1992" ;
	}

	/********************************************************/
	/* Modifs du 10/03/99 - par A.BORDET 			        */
	/* si annee de compte < 1992  	                        */
	/* alors ne pas reecrire le mouvement en sortie		    */
	/* cela fait suite aux pbs de reprise compta pour les   */
	/* années de compte < 1992                              */
	/********************************************************/

	if ( atoi( ptb_InRecChild[GT_ACY_NF] ) < 1992 )
	{
		RETURN_VAL(OK);
	}

	/********************************************************/
	/* Modifs du 01/04/98 - par A.BORDET 			        */
	/* si annee de compte < 1986  	                        */
	/* alors ne pas reecrire le mouvement en sortie		    */
	/********************************************************/

	/*if ( atoi( ptb_InRecChild[GT_ACY_NF] ) < 1986 )
	{
		RETURN_VAL(OK);
	}*/

    /********************************************************/
	/* Modifs du 27/03/98 - par M.HA-THUC 			        */
	/* si annee de compte < 1991  	                        */
	/* alors forcer l'annee de compte a 1991	   	        */
	/********************************************************/

	/*if ( atoi( ptb_InRecChild[GT_ACY_NF] ) < 1991 )
	{
		ptb_InRecChild[GT_ACY_NF] = "1991" ;
	}*/

	/****************************************************************/
	/* Modifs du 30/03/98 - par M.HA-THUC 				            */
	/* si l'affaire est terminee comptablement ( SECACCSTS_CT = 9 ) */
	/* alors on positionne ADJCOD_CT a 9 de facon à ne pas calculer */
	/* de compléments pour ces affaires dans le traitement ESID2040 */
	/* (pour les criblés et les non criblés en fait)                 */
	/****************************************************************/

	/*if ( atoi( ptb_InRecOwner[PER_SECACCSTS_CT] ) == 9 &&
	     ptb_InRecOwner[PER_ESTCRB_CT][0]=='O' )
	{
		ptb_InRecChild[GT_ADJCOD_CT] = "9" ;
	}*/

	if  ( atoi( ptb_InRecOwner[PER_SECACCSTS_CT] ) == 9 )
	{
		ptb_InRecChild[GT_ADJCOD_CT] = "9" ;
	}

   	if ( atoi( ptb_InRecChild[GT_BALSHEY_NF] ) <=  Kn_BALSHTYEA_NF - 1 &&
	     atoi( ptb_InRecChild[GT_ACY_NF] ) <=  Kn_BALSHTYEA_NF -1  )
	{
		n_WriteCols(Kp_OutGTB1,ptb_InRecChild,SEPARATEUR,0);
	}
/*  V006 R Cassis
   	if ( atoi( ptb_InRecChild[GT_BALSHEY_NF] ) <= Kn_BALSHTYEA_NF &&
	     flag_B1 == 0 &&
		 atoi( ptb_InRecChild[GT_ACY_NF] ) <= Kn_BALSHTYEA_NF )
	{        */
        n_WriteCols(Kp_OutputFil,ptb_InRecChild,SEPARATEUR,0);

        RETURN_VAL(OK);
}


/*==============================================================================
objet :
        fonction lancee quand le pere n'a pas de fils GT
retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre

==============================================================================*/
int n_ActionPereSansFilsGT(
        char **ptb_InRecOwner   /* adresse de la ligne du maitre */
        )
{
      int i;
      double    d_aliment,d_taux;
      char      sz_aliment[22];
      char sz_GT[900];
      char *tb[GT_NBCOL] ;

      DEBUT_FCT("n_ActionPereSansFilsGT");

        for(i=0;i<GT_NBCOL;i++) tb[i]="" ;
              tb[GT_NBCOL] = 0 ;

        /* Calcul du taux de conversion (cours: 31/12/exercice precedent) */
        d_taux=d_GetTaux(Kp_CoursFil,
                        (char)atoi(ptb_InRecOwner[PER_SSD_CF]),
                        (short)atoi(ptb_InRecOwner[PER_UWY_NF])-1,
                        ptb_InRecOwner[PER_EGPCUR_CF],
                        ptb_InRecOwner[PER_PCPCUR_CF]);

        if (d_taux>0)
        {
          /* Conversion de l'aliment brut SCOR */
          d_aliment=atof(ptb_InRecOwner[PER_SCOEGP_M]);
          /* Conversion */
          d_aliment *= d_taux;
        }
        else d_aliment=-1;

        sprintf(sz_aliment,"%.3lf",d_aliment);


        tb[GT_SSD_CF]=                  ptb_InRecOwner[PER_SSD_CF];
        tb[GT_ESB_CF]=                  ptb_InRecOwner[PER_ACCESB_CF];

        tb[GT_CTR_NF]=                  ptb_InRecOwner[PER_CTR_NF];
        tb[GT_END_NT]=                  ptb_InRecOwner[PER_END_NT];
        tb[GT_SEC_NF]=                  ptb_InRecOwner[PER_SEC_NF];
        tb[GT_UWY_NF]=                  ptb_InRecOwner[PER_UWY_NF];
        tb[GT_UW_NT]=                   ptb_InRecOwner[PER_UW_NT];
        tb[GT_ACY_NF]=                  ptb_InRecOwner[PER_UWY_NF];

		/* Modif ANB du 16/10/98   */
		/* Ajout de la monnaie principale pour la conversion de l'aliment */
		/* lors du traitement de ventilation */

		tb[GT_CUR_CF]=                  ptb_InRecOwner[PER_PCPCUR_CF];

        tb[GT_CED_NF]=                  ptb_InRecOwner[PER_CED_NF];
        tb[GT_BRK_NF]=                  ptb_InRecOwner[PER_PRD_NF];
        tb[GT_PAY_NF]=                  ptb_InRecOwner[PER_GENPRMPAY_NF];
        tb[GT_KEY_NF]=                  ptb_InRecOwner[PER_GANPAYORD_NT];

        /**** GT enrichi */

		tb[GT_ESTCUR_CF]=               ptb_InRecOwner[PER_PCPCUR_CF];
        tb[GT_NAT_CF]=                  ptb_InRecOwner[PER_NAT_CF];
        tb[GT_ACMTRS_NT]=               "0";
        tb[GT_ESTCTR_NF]=               ptb_InRecOwner[PER_ESTCTR_NF];
        tb[GT_ESTSEC_NF]=               ptb_InRecOwner[PER_ESTSEC_NF];
        tb[GT_LOB_CF]=                  ptb_InRecOwner[PER_LOB_CF];
        tb[GT_SCOEGP_M]=                sz_aliment;
        tb[GT_ESTCRB_CT]=               ptb_InRecOwner[PER_ESTCRB_CT];
        tb[GT_LIFTRTTYP_CF]=            ptb_InRecOwner[PER_LIFTRTTYP_CF];
        tb[GT_ACCADMTYP_CT]=            ptb_InRecOwner[PER_ACCADMTYP_CT];
        tb[GT_SECSTS_CT]=               ptb_InRecOwner[PER_SECSTS_CT];
        tb[GT_PRD_NF]=                  ptb_InRecOwner[PER_PRD_NF];
        tb[GT_SEG_NF]=                  ptb_InRecOwner[PER_SEG_NF];
        tb[GT_COMACC_B]=                "0";

		/* Modif Anb le 5/11/1999 */
		/* Report modification adjcod_ct si affaire sans mouvement terminée */

		if  ( atoi( ptb_InRecOwner[PER_SECACCSTS_CT] ) == 9 )
		{
			tb[GT_ADJCOD_CT] = "9" ;
		};
		/*tb[GT_ADJCOD_CT]                = "0";*/

        tb[GT_RETCOD_CT]                = "0";
        tb[GT_DETTRS_CF]                = "";
        tb[GT_ADJSIG_B]=                "0";
        tb[GT_ESTUWY_NF]=               "";
        tb[GT_PROPER_N]=                ptb_InRecOwner[PER_ACCFRQ_CT];
        tb[GT_UWGRP_CF]=                ptb_InRecOwner[PER_UWGRP_CF];
        tb[GT_RTOCTY_CF]=               "";

        n_WriteCols(Kp_OutGTB1,tb,SEPARATEUR,0);

		n_WriteCols(Kp_OutputFil,tb,SEPARATEUR,0);

        RETURN_VAL(OK);
}

/*==============================================================================
objet :
        fonction lancee quand le pere n'a pas de fils GT
retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre

==============================================================================*/
int n_ActionFilsSansPereGT(
        char **ptb_InRecChild   /* adresse de la ligne du maitre */
        )
{
      int i;
      double    d_aliment,d_taux;
      char      sz_aliment[22];
      char sz_GT[900];
      char *tb[GT_NBCOL] ;

      DEBUT_FCT("n_ActionPereSansFilsGT");


        for(i=0;i<GT_NBCOL;i++) tb[i]="" ;
              tb[GT_NBCOL] = 0 ;

       /****************************************************************************************************/
       /* PROVISOIR en attendant le retour de ANB */
       /****************************************************************************************************/

	RETURN_VAL(OK);
//        /* Calcul du taux de conversion (cours: 31/12/exercice precedent) */
//        d_taux=d_GetTaux(Kp_CoursFil,
//                        (char)atoi(ptb_InRecChild[PER_SSD_CF]),
//                        (short)atoi(ptb_InRecChild[PER_UWY_NF])-1,
//                        ptb_InRecChild[PER_EGPCUR_CF],
//                        ptb_InRecChild[PER_PCPCUR_CF]);
//
//        if (d_taux>0)
//        {
//          /* Conversion de l'aliment brut SCOR */
//          d_aliment=atof(ptb_InRecChild[PER_SCOEGP_M]);
//          /* Conversion */
//          d_aliment *= d_taux;
//        }
//        else d_aliment=-1;
//
//        sprintf(sz_aliment,"%.3lf",d_aliment);
//
//
//        tb[GT_SSD_CF]=                  ptb_InRecChild[PER_SSD_CF];
//        tb[GT_ESB_CF]=                  ptb_InRecChild[PER_ACCESB_CF];
//
//        tb[GT_CTR_NF]=                  ptb_InRecChild[PER_CTR_NF];
//        tb[GT_END_NT]=                  ptb_InRecChild[PER_END_NT];
//        tb[GT_SEC_NF]=                  ptb_InRecChild[PER_SEC_NF];
//        tb[GT_UWY_NF]=                  ptb_InRecChild[PER_UWY_NF];
//        tb[GT_UW_NT]=                   ptb_InRecChild[PER_UW_NT];
//        tb[GT_ACY_NF]=                  ptb_InRecChild[PER_UWY_NF];
//
//		/* Modif ANB du 16/10/98   */
//		/* Ajout de la monnaie principale pour la conversion de l'aliment */
//		/* lors du traitement de ventilation */
//
//		tb[GT_CUR_CF]=                  ptb_InRecChild[PER_PCPCUR_CF];
//
//        tb[GT_CED_NF]=                  ptb_InRecChild[PER_CED_NF];
//        tb[GT_BRK_NF]=                  ptb_InRecChild[PER_PRD_NF];
//        tb[GT_PAY_NF]=                  ptb_InRecChild[PER_GENPRMPAY_NF];
//        tb[GT_KEY_NF]=                  ptb_InRecChild[PER_GANPAYORD_NT];
//
//        /**** GT enrichi */
//
//		tb[GT_ESTCUR_CF]=               ptb_InRecChild[PER_PCPCUR_CF];
//        tb[GT_NAT_CF]=                  ptb_InRecChild[PER_NAT_CF];
//        tb[GT_ACMTRS_NT]=               "0";
//        tb[GT_ESTCTR_NF]=               ptb_InRecChild[PER_ESTCTR_NF];
//        tb[GT_ESTSEC_NF]=               ptb_InRecChild[PER_ESTSEC_NF];
//        tb[GT_LOB_CF]=                  ptb_InRecChild[PER_LOB_CF];
//        tb[GT_SCOEGP_M]=                sz_aliment;
//        tb[GT_ESTCRB_CT]=               ptb_InRecChild[PER_ESTCRB_CT];
//        tb[GT_LIFTRTTYP_CF]=            ptb_InRecChild[PER_LIFTRTTYP_CF];
//        tb[GT_ACCADMTYP_CT]=            ptb_InRecChild[PER_ACCADMTYP_CT];
//        tb[GT_SECSTS_CT]=               ptb_InRecChild[PER_SECSTS_CT];
//        tb[GT_PRD_NF]=                  ptb_InRecChild[PER_PRD_NF];
//        tb[GT_SEG_NF]=                  ptb_InRecChild[PER_SEG_NF];
//        tb[GT_COMACC_B]=                "0";
//
//		/* Modif Anb le 5/11/1999 */
//		/* Report modification adjcod_ct si affaire sans mouvement terminée */
//
//		if  ( atoi( ptb_InRecChild[PER_SECACCSTS_CT] ) == 9 )
//		{
//			tb[GT_ADJCOD_CT] = "9" ;
//		};
//		/*tb[GT_ADJCOD_CT]                = "0";*/
//
//        tb[GT_RETCOD_CT]                = "0";
//        tb[GT_DETTRS_CF]                = "";
//        tb[GT_ADJSIG_B]=                "0";
//        tb[GT_ESTUWY_NF]=               "";
//        tb[GT_PROPER_N]=                ptb_InRecChild[PER_ACCFRQ_CT];
//        tb[GT_UWGRP_CF]=                ptb_InRecChild[PER_UWGRP_CF];
//        tb[GT_RTOCTY_CF]=               "";
//
//        n_WriteCols(Kp_OutGTB1,tb,SEPARATEUR,0);
//
//		n_WriteCols(Kp_OutputFil,tb,SEPARATEUR,0);
//
//        RETURN_VAL(OK);
}

