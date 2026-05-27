/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : 
nom du source                 : ESTC1035.c
revision                      : $Revision:   1.0  $
date de creation              : 07/1998
auteur                        : L.Capomazza
references des specifications : 
squelette de base             : batch
------------------------------------------------------------------------------
description :
	Traitement du cas particulier des lobs nulles

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	   ...           ...            ...              ...
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <ESTC1035.h>


T_RUPTURE_VAR Kbd_Rupt;
FILE *Kp_GolIFil;
FILE *Kp_GoelPeopOFil;
char lob[5];

		
/*--------------------------------------------------*/
/* Description des fonctions                        */
/*--------------------------------------------------*/

int n_InitPeop(T_RUPTURE_VAR  *pbd_Rupt);
int n_IsR1(char **pbd_InRec ,char **pbd_InRec_Cur);
int n_ActionLignePeop(char **ptb_InRec_Cur);
int n_ActionFirst(char **ptb_InRec_Cur);
int n_ActionLast(char **ptb_InRec_Cur);
int n_Write_out(char **ptb_InRec_Cur,char *lob);

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
  InitSig ();
   
  if (n_BeginPgm(argc,argv) == ERR)
	ExitPgm (ERR_XX , "");
	
     
 /* ouverture du fichier goelette */
 /* if (n_OpenFileAppl("ESTC1035_I1","rt",&Kp_GolIFil) == ERR )
	 ExitPgm ( ERR_XX , "" ); */

 /* ouverture du fichier peoplesoft */
  if (n_OpenFileAppl("ESTC1035_O1","wt",&Kp_GoelPeopOFil) == ERR )
	ExitPgm ( ERR_XX , "" );
    
	n_InitPeop(&Kbd_Rupt);
	  
  /*traitement*/

  if (n_ProcessingRuptureVar(&Kbd_Rupt)==ERR)
    ExitPgm (ERR_XX , "");
  
  if (n_CloseFileAppl("ESTC1035_I1",&(Kbd_Rupt.pf_InputFil)) == ERR)
    ExitPgm (ERR_XX ,"");
  
  if (n_CloseFileAppl("ESTC1035_O1",&Kp_GoelPeopOFil) == ERR)
    ExitPgm (ERR_XX ,"");

  if (n_EndPgm() == ERR) 
    ExitPgm (ERR_XX , "");
  
  exit(OK) ;
  }
/*=============================================================================
 objet: Initialisation Rupture : 1 rupture 
=============================================================================*/
int n_InitPeop(T_RUPTURE_VAR  *pbd_Rupt)
{
  
  DEBUT_FCT("n_InitPeop");

  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

  /* Ouverture du fichier maitre */
  if (n_OpenFileAppl ("ESTC1035_I1","rt",&(pbd_Rupt->pf_InputFil)))
  	RETURN_VAL (ERR); 

  /* Gestion de rupture */
  pbd_Rupt->n_NbRupture = 1;
  pbd_Rupt->c_Separ = '~';

	pbd_Rupt->n_ConditionRupture[0] = n_IsR1 ;
	
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirst ;
  
	pbd_Rupt->n_ActionLigne = n_ActionLignePeop; 

	pbd_Rupt->n_ActionLast[0] = n_ActionLast ;

  

  RETURN_VAL (0);
}

/*==============================================================================
objet :	fonction de test de rupture de niveau 1

retour : 0	---> pas de rupture
	 sinon 	---> rupture
==============================================================================*/
int n_IsR1(char **pbd_InRec ,char **pbd_InRec_Cur  ) 
{
	DEBUT_FCT( "n_IsR1" ) ;

	if ( strcmp(pbd_InRec[TECLEDA_CTR_NF],pbd_InRec_Cur[TECLEDA_CTR_NF]) != 0 ) return(1);
	
	if ( strcmp(pbd_InRec[TECLEDA_SEC_NF],pbd_InRec_Cur[TECLEDA_SEC_NF]) != 0 ) return(1);
	
	RETURN_VAL( 0 ) ;
}

/*=======================================================================================

========================================================================================*/ 
int n_ActionLignePeop(char **ptb_InRec_Cur)
{
	char lob_c[5];
	
	strcpy(lob_c,ptb_InRec_Cur[TECLEDA_LOBACC_CF]);

	if ( strcmp(lob_c,"A") !=0 ) {
		n_Write_out(ptb_InRec_Cur,lob_c);
		strcpy(lob,lob_c);
		}
	else n_Write_out(ptb_InRec_Cur,lob);

/*	if ( strcmp(ptb_InRec_Cur[TECLEDA_LOBACC_CF],"A") == 0 )
		strcpy(ptb_InRec_Cur[TECLEDA_LOBACC_CF],lob);
	else strcpy(lob,ptb_InRec_Cur[TECLEDA_LOBACC_CF]);

	n_Write_out(ptb_InRec_Cur); */
	
RETURN_VAL(0);
}        

/*==============================================================================
objet : fonction lancee en rupture premiere

retour : OK ---> traitement correctement effectue
==============================================================================*/
int n_ActionFirst(char **ptb_InRec_Cur) 
{
	strcpy(lob,ptb_InRec_Cur[TECLEDA_LOBACC_CF]);
	if ( strcmp(lob,"A") ==0 ) 
		{
		if ( ptb_InRec_Cur[TECLEDA_SSD_CF][0] == '4' )
			strcpy(lob,"L.41");
		else
			strcpy(lob,"P.11");
		}
    RETURN_VAL(OK);
}

/*==============================================================================
objet : fonction lancee en rupture derniere

retour : OK ---> traitement correctement effectue
==============================================================================*/
int n_ActionLast(char **ptb_InRec_Cur) 
{
	RETURN_VAL(OK);
}

/*=============================================================================
 objet: Procedure d'ecriture dans le fichier sortie

 retour:   
=============================================================================*/
int n_Write_out(char **ptb_InRec_Cur,char *lob) 
{
	fprintf(Kp_GoelPeopOFil,"%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",
        	       		ptb_InRec_Cur[TECLEDA_SSD_CF],
                		ptb_InRec_Cur[TECLEDA_BALSHEY_NF],
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF],
				ptb_InRec_Cur[TECLEDA_CTRNAT_NF],
				ptb_InRec_Cur[TECLEDA_CUR_CF],
        			ptb_InRec_Cur[TECLEDA_AMT_M],
				lob,
				ptb_InRec_Cur[TECLEDA_NATACC_CF],
				ptb_InRec_Cur[TECLEDA_TOP_RTO],
				ptb_InRec_Cur[TECLEDA_SOBACC_CF],
				ptb_InRec_Cur[TECLEDA_TOPACC_CF],
				ptb_InRec_Cur[TECLEDA_GARACC_CF]);
	RETURN_VAL(OK);
}
