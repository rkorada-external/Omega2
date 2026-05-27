
/*==============================================================================
nom de l'application          : Syncro PERICASEetre Vie et Retro Interne
nom du source                 : ESTC7607.c
revision                      : $Revision: 1.4 $
date de creation              : 25/06/2004
auteur                        : J. Ribot
references des specifications :
squelette de base             : batch
------------------------------------------------------------------------------
description :


------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
     07/04/2008    J. Ribot Spot14633 ajout acces FLIFDRI pour infos ARRETE STAT et ecriture
                            lignes d'avertissement dans le fichier .anos
    ---------------
    14/05/2008    [002]         ESTVIE15401 Agrandissement d'un tableau en mémoire
                                agrandissement de NB_MAX_PILOT 20000 => 40000
[XXX] 06/04/2014 JBG :spot:25773 Modify void main declaration to int main
[003] 12/06/2014 R. Cassis :spot:26948 Affectation de l'établissement à partir du fichier périmetre car pour les traités provenant de la RETRO INTERNE, c'est celui d'origine actuellement
[004] 10/04/2015 Julien FONTANA : spot28559: Ajout Cre_D, modification sortie 2 -> Anno en noSync + Reformat code
[005] 27/03/2019 S.Behague    :spira 70044:REQ.L.02.05: Evolution quarterly
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include "estserv.h"


/*----------------------*/
/* variables de travail */
/*----------------------*/
FILE    *Kp_OutputFilDLRLIFEP,
        *Kp_OutputFilDLRLIFEI,
		    *Kp_OutputFil_COMACC_1,
		    *Kp_InputFil_LIFDRI,
        *Kp_OutputFilFCURQUOT;

T_RUPTURE_VAR       bd_RuptPERICASE; /* gestion rupture sur perimetre */
T_RUPTURE_SYNC_VAR  bd_RuptLIFEST;   /* gestion synchro GT-perimetre */

T_LIFDRI_ALL_QUARTER        Kbd_PILOTD[NB_MAX_PILOT];

char *Ksz_Ctr;
char *Ksz_Esb;
char *Ksz_Sec;
char *Ksz_EstCrb;
char *Ksz_Ced;
char *Ksz_GanPayOrd;
char *Ksz_Pcpcur;

int n_InitLIFEST(T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int n_ActionLigneLIFEST(char **ptb_InRecOwner, char **pbd_InRecChild) ;
int n_ConditionSyncLIFEST(char **ptb_InRecOwner, char **pbd_InRecChild);

int n_IsR1PERICASE(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionLastRuptPERICASE(char **ptb_InRec_Cur);

int n_InitPERICASE(T_RUPTURE_VAR *pbd_Rupt) ;
int n_ActionLignePERICASE(char **pbd_InRec_Cur);
int n_ActionFilsSansPereLIFEST(char **ptb_InRecOwner );   /*  jr 11 09 2003 */

int n_IsCC(char **lineFormatLifest);


/*==============================================================================
objet	: 	point d'entree du programme
retour 	:   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   			Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc , char *argv[])
{
  /* Initialisation des signaux */
  InitSig () ;

  if (n_BeginPgm(argc, argv) 											                    == ERR) ExitPgm(ERR_XX, "");
  
  if (n_OpenFileAppl("ESTC7607_O1", "wt", &Kp_OutputFilDLRLIFEP) 		  == ERR) ExitPgm(ERR_XX, "");
  if (n_OpenFileAppl("ESTC7607_O2", "wt", &Kp_OutputFilDLRLIFEI) 		  == ERR) ExitPgm(ERR_XX, "");
  if (n_OpenFileAppl("ESTC7607_O3", "wt", &Kp_OutputFil_COMACC_1) 	  == ERR) ExitPgm(ERR_XX, "");
  if (n_OpenFileAppl("ESTC7607_I3", "rt", &Kp_OutputFilFCURQUOT) 		  == ERR) ExitPgm(ERR_XX, "");
  if (n_OpenFileAppl("ESTC7607_I4", "rb", &Kp_InputFil_LIFDRI) 			  == ERR) ExitPgm(ERR_XX, "");
  
  if (n_InitPERICASE(&bd_RuptPERICASE) 									              == ERR) ExitPgm(ERR_XX, "");
  if (n_InitLIFEST(&bd_RuptLIFEST) 										                == ERR)	ExitPgm(ERR_XX, "");
  if (n_ChargerPilot7000(Kp_InputFil_LIFDRI) == -1)
    ExitPgm(ERR_XX, "");
  if (n_ProcessingRuptureVar (&bd_RuptPERICASE) 						          == ERR) ExitPgm(ERR_XX, "");
  
  if (n_CloseFileAppl("ESTC7607_O1", &Kp_OutputFilDLRLIFEP) 			    == ERR) ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl("ESTC7607_O2", &Kp_OutputFilDLRLIFEI) 			    == ERR) ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl("ESTC7607_O3", &Kp_OutputFil_COMACC_1) 			    == ERR) ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl("ESTC7607_I1", &(bd_RuptPERICASE.pf_InputFil)) 	== ERR) ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl("ESTC7607_I2", &(bd_RuptLIFEST.pf_InputFil)) 	  == ERR) ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl("ESTC7607_I3", &Kp_OutputFilFCURQUOT) 			    == ERR) ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl("ESTC7607_I4", &Kp_InputFil_LIFDRI) 				    == ERR) ExitPgm(ERR_XX, "");
    
  if (n_EndPgm () 														                        == ERR) ExitPgm(ERR_XX, "");

  exit(OK) ;

}

/*==============================================================================
objet 	:	fonction d'initialisation de la variable de gestion de rupture du
        	fichier maitre.
retour 	:   OK
==============================================================================*/
int n_InitPERICASE(T_RUPTURE_VAR  *pbd_RuptPERICASE)
{
  DEBUT_FCT("n_InitPERICASE");

  memset(pbd_RuptPERICASE, 0, sizeof(T_RUPTURE_VAR));

  if (n_OpenFileAppl ("ESTC7607_I1", "rt", &(pbd_RuptPERICASE->pf_InputFil)))
    ExitPgm(ERR_XX, "");

  pbd_RuptPERICASE->n_NbRupture 		= 0;

  pbd_RuptPERICASE->n_ActionLigne 	= n_ActionLignePERICASE;

  pbd_RuptPERICASE->c_Separ 			  = SEPARATEUR;

  RETURN_VAL(OK);
}


/*==============================================================================
objet 	:	fonction lancee pour chaque ligne du maitre
retour 	:   OK ---> traitement correctement effectue
        	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePERICASE(char **pbd_RuptPERICASE)
{
  DEBUT_FCT("n_ActionLignePERICASE");

  n_ProcessingRuptureSyncVar(&bd_RuptLIFEST, pbd_RuptPERICASE);

  RETURN_VAL(OK);
}

/*==============================================================================
objet 	:	Initialisation de la synchronisation du maitre avec l'esclave GT
retour 	:   OK
==============================================================================*/
int n_InitLIFEST(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  DEBUT_FCT("n_InitLIFEST");

  memset(pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR)) ;

  /* ouverture du fichier esclave */
  n_OpenFileAppl("ESTC7607_I2", "rt", &(pbd_Rupt->pf_InputFil));

  pbd_Rupt->n_NbRupture           = 0;

  /* fonction du test de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync      = n_ConditionSyncLIFEST;

  /* fonction d'action sur la ligne courante du fichier esclave */
  pbd_Rupt->n_ActionLigne         = n_ActionLigneLIFEST;

  /* fonction d'action quand le maitre n'a pas de fils LIFEST */
  pbd_Rupt->n_FilsSansPere        = n_ActionFilsSansPereLIFEST;

  pbd_Rupt->c_Separ               = SEPARATEUR;

  RETURN_VAL(OK);
}

/*==============================================================================
objet 	:	fonction de test de rupture du nLIFEST
retour 	:   0       ---> pbd_InRecOwner = pbd_InRecChild
                        (egalite de rubriques a synchroniser)
        	> 0     ---> pbd_InRecOwne> > pbd_InRecChild
        	< 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncLIFEST(  char **pbd_InRecOwner ,  char **pbd_InRecChild)
{
  int ret;

  DEBUT_FCT("n_ConditionSyncLIFEST");

  if ((ret = strcmp(pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[PRE_CTR_NF])) != 0) RETURN_VAL(ret);
  if ((ret = strcmp(pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[PRE_SEC_NF])) != 0) RETURN_VAL(ret);
  if ((ret = strcmp(pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[PRE_UWY_NF])) != 0) RETURN_VAL(ret);

  RETURN_VAL(ret);
}


/*==============================================================================
objet 	:	fonction lancee pour chaque ligne du GT synchronisee avec le perimetre
retour 	:   OK ---> traitement correctement effectue
        	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneLIFEST(char **ptb_InRecOwner, char **ptb_InRecChild)
{
	double  d_montant; 
	double  d_taux;
	char    sz_montant[30];

  	DEBUT_FCT("n_ActionLigneLIFEST");

  	if (strcmp(ptb_InRecOwner[PER_PCPCUR_CF], ptb_InRecChild[PRE_CUR_CF]) != 0)
  	{
    	d_taux = d_GetTaux(Kp_OutputFilFCURQUOT,
                       (char)atoi(ptb_InRecOwner[PER_SSD_CF]),
                       (short)atoi(ptb_InRecChild[PRE_BALSHEY_NF]),
                       ptb_InRecChild[PRE_CUR_CF],
                       ptb_InRecOwner[PER_PCPCUR_CF]);
    	/* Si le taux est trouve, conversion*/
    	if (d_taux > 0)
    	{
    	  d_montant = atof(ptb_InRecChild[PRE_ESTMNT_M]) * d_taux;
    	}
    	/* Sinon, montant mis a -1 */
    	else 
    		d_montant = -1;
	
    	/* Remplacement du montant */
    	sprintf(sz_montant, "%.3lf", d_montant);
    	ptb_InRecChild[PRE_ESTMNT_M] = sz_montant;
  	}

 	if (n_IsCC(ptb_InRecChild) == 0)
  		n_WriteCols(Kp_OutputFilDLRLIFEP, ptb_InRecChild, SEPARATEUR, 0);
	else
  		n_WriteCols(Kp_OutputFil_COMACC_1, ptb_InRecChild, SEPARATEUR, 0);

  	Ksz_Ctr       = strdup(ptb_InRecOwner[PER_CTR_NF]);
  	Ksz_Sec       = strdup(ptb_InRecOwner[PER_SEC_NF]);
  	Ksz_EstCrb    = strdup(ptb_InRecOwner[PER_ESTCRB_CT]);
  	Ksz_Ced       = strdup(ptb_InRecOwner[PER_CED_NF]);
  	Ksz_GanPayOrd = strdup(ptb_InRecOwner[PER_GANPAYORD_NT]);
  	Ksz_Pcpcur    = strdup(ptb_InRecOwner[PER_PCPCUR_CF]);
    Ksz_Esb 	    = strdup(ptb_InRecOwner[PER_ACCESB_CF]);  //[003]

  	RETURN_VAL(OK);
}


/*==============================================================================
objet 	:	fonction lancee quand le pere n'a pas de fils GT
retour 	:   OK ---> traitement correctement effectue
        	ERR --> probleme rencontre
==============================================================================*/
int n_ActionFilsSansPereLIFEST(char **ptb_InRecChild)
{
	double  d_montant;
	double  d_taux;
	char    tmpBuffer[30] = {0};
  	
  	DEBUT_FCT("n_ActionFilsSansPereLIFEST");

    if (Ksz_Ctr != NULL && Ksz_Sec != NULL)
    {
  	 if ((strcmp(ptb_InRecChild[PRE_CTR_NF], Ksz_Ctr) == 0) &&
        	(strcmp(ptb_InRecChild[PRE_SEC_NF], Ksz_Sec) == 0))
  	 {
  	  if (strcmp(Ksz_Pcpcur, ptb_InRecChild[PRE_CUR_CF]) != 0)
      	{
        		d_taux = d_GetTaux(Kp_OutputFilFCURQUOT,
                           (char)atoi(ptb_InRecChild[PRE_SSD_CF]),
                           (short)atoi(ptb_InRecChild[PRE_BALSHEY_NF]),
                           ptb_InRecChild[PRE_CUR_CF],
                           Ksz_Pcpcur);
        	/* Si le taux est trouve, conversion*/
        	if (d_taux > 0)
          	d_montant = atof(ptb_InRecChild[PRE_ESTMNT_M]) * d_taux;
  
        	/* Sinon, montant mis a -1 */
       	 else d_montant = -1;
  
        	/* Remplacement du montant */
        	sprintf(tmpBuffer, "%.3lf", d_montant);
        	ptb_InRecChild[PRE_ESTMNT_M] = tmpBuffer;
  
      	}
      	if (n_IsCC(ptb_InRecChild) == 0)
      	{
        	ptb_InRecChild[PRE_CUR_CF] 			 = Ksz_Pcpcur;
        	ptb_InRecChild[PRE_ESB_CF] 			 = Ksz_Esb; 		// [003]
        	ptb_InRecChild[PRE_ESTCRB_CT] 	 = Ksz_EstCrb;
        	ptb_InRecChild[PRE_CED_NF] 			 = Ksz_Ced;
        	ptb_InRecChild[PRE_GANPAYORD_NT] = Ksz_GanPayOrd;
        	ptb_InRecChild[PRE_NBCOL] 			 = NULL;
        	ptb_InRecChild[PRE_BATCH_B] 		 = "1"; 			// [004]
  	 		n_WriteCols(Kp_OutputFilDLRLIFEP, ptb_InRecChild, SEPARATEUR, 0);
  	 	}
		    else
  	 		n_WriteCols(Kp_OutputFil_COMACC_1, ptb_InRecChild, SEPARATEUR, 0);
  	 	RETURN_VAL(OK);
  	  }
    }
  	n_WriteCols(Kp_OutputFilDLRLIFEI, ptb_InRecChild, SEPARATEUR, 0);

  	RETURN_VAL(OK);
}

/*==============================================================================
objet 	:	fonction de test compte coplet
retour 	:   0 ---> pas CC
        	1 ---> CC
==============================================================================*/
int n_IsCC(char **lineFormatLifest)
{
    static int      Kn_indexLIFDRI  = 0;

    if (n_RechPilot7000(lineFormatLifest, PRE_CTR_NF , PRE_SEC_NF, PRE_ACY_NF, PRE_ESTMTH_NF, &Kn_indexLIFDRI) != -1)
    {
        if (Kbd_PILOTD[Kn_indexLIFDRI].AUTUPD_B && Kbd_PILOTD[Kn_indexLIFDRI].COMACC_B)
        {
            RETURN_VAL(1);
        }
        else
            RETURN_VAL(0);
    }
    else
        RETURN_VAL(0);
}
