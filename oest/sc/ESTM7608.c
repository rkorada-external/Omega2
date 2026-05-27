/*==============================================================================
Nom de l'application          : Transfert COREE VIE - transformation de TOTGTAR GT
Nom du source                 : ESTM7608.c
Revision                      :
Date de creation              : 22/02/2006
Auteur                        : M.DJELLOULI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :Transformation du GT Retrocession

------------------------------------------------------------------------------
Historique des modifications :
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <util.h>
#include "struct.h"


#define COR_CTR_NF       0
#define COR_END_NT       1
#define COR_SEC_NF       2
#define COR_UWY_NF       3
#define COR_UW_NT        4
#define COR_RETCTR_NF    5
#define COR_RETEND_NT    6
#define COR_RETSEC_NF    7
#define COR_RTY_NF       8
#define COR_RETUW_NT     9
#define COR_RCL_NF       10
#define COR_PLC_NT       11
#define COR_RTO_NF       12
#define COR_INT_NF       13
#define COR_RETPAY_NF    14
#define COR_RETKEY_CF    15
#define COR_TAUXCESSION  16


/*----------------------*/
/* Variables de travail */
/*----------------------*/

FILE   *Kp_OutputFileGTAR;   /* Pointeur sur le fichier FGTA en sortie */
FILE   *Kp_OutputFileGTR;   /* Pointeur sur le fichier FGTR en sortie */

T_RUPTURE_VAR bd_Rupture; /* variable sur la structure du GT */
T_RUPTURE_SYNC_VAR  bd_Rupt; /*variable de gesstion de la synchro
                                    de TOTGTAR avec ordvpericase*/

// Paramètres d'Entrées
int  		n_parm_BALSHEY_NF;
char 		sz_parm_BLCSHT_D[8];
unsigned char	c_parm_ESTIM_B;   		/* 0/1 - si = 1 -> Postes estimations sont pris en compte */
int  		n_parm_FORCEBILAN;    /* MOD005 - Flag FORCEBILAN Forcé Bilan à à 31/12/N-1 (1=Oui par Défaut / 0= Bilan N préservé) */

/*--------------------------*/
/* Fonctions du fichier FGT */
/*--------------------------*/
int n_InitRupt_gtr(T_RUPTURE_VAR *pdb_Rupture);
int n_InitRuptgt(T_RUPTURE_SYNC_VAR *pdb_Rupt);
int n_ActionLignegt(char **pdb_InRecOwner, char **pdb_InRecChild);
int n_ActionLigne_gtr(char **pdb_InRecOwner);
int n_ConditionSyncgt(char **pdb_InRecOwner, char **pdb_InRecChild);
int n_ProcessingRuptureSyncVar(T_RUPTURE_SYNC_VAR *bd_Rupt,
                                 char **pdb_InRecOwner);
/***********************************************************************/
/*** Objet :                                                            ***/

/*** Parametres:							***/
/***	i argv : tableau de pointeurs sur les parametres		***/
/*** Retour:								***/
/***	ERR si erreur.							***/
/**************************************************************************/

int main(int argc, char *argv[])
{

/* Initialisation des signaux */ InitSig();

   if (n_BeginPgm(argc, argv) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");
   }
	strcpy(sz_parm_BLCSHT_D, psz_GetCharArgv(1)) ;
	n_parm_BALSHEY_NF = atoi(psz_GetCharArgv(2)) ;
	c_parm_ESTIM_B = atoi(psz_GetCharArgv(3)) ;
  n_parm_FORCEBILAN = atoi(psz_GetCharArgv(4)) ;


/* Ouverture du fichier de sortie GT-TOTGTAR */
   if (n_OpenFileAppl("ESTM7608_O1", "wt", &Kp_OutputFileGTAR) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
   }

   if (n_OpenFileAppl("ESTM7608_O2", "wt", &Kp_OutputFileGTR) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
   }

/* Initialisation de la variable bd_Rupture*/

   if(n_InitRupt_gtr(&bd_Rupture) )
     ExitPgm(ERR_XX,"Erreur appel de la fonction n_InitRupt_gtr");

/* Initialisation de la variable bd_Rupt*/

   if(n_InitRuptgt(&bd_Rupt) )
     ExitPgm(ERR_XX,"Erreur appel de la fonction n_InitRuptgt");


/* lancement du traitement du fichier maitre */
        if ( n_ProcessingRuptureVar( &bd_Rupture ) == ERR )
                ExitPgm( ERR_XX , "" ) ;

   if (n_CloseFileAppl("ESTM7608_I1", &(bd_Rupture.pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM7608_I2", &(bd_Rupt.pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM7608_O1", &Kp_OutputFileGTAR) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM7608_O2", &Kp_OutputFileGTR) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_EndPgm() == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_EndPgm");
   }

   exit(OK);
}


/**************************************************************************/
/***    Objet :                                                         ***/

/***    OK si pas d'erreur,                                             ***/

/***    ERR si erreur.                                                  ***/

/**************************************************************************/

int n_InitRupt_gtr(T_RUPTURE_VAR *bd_Rupture)
{

   DEBUT_FCT("n_InitRupgt");
   memset(bd_Rupture, 0, sizeof(T_RUPTURE_VAR));

/* Ouverture du fichier maitre */
if (n_OpenFileAppl("ESTM7608_I2", "rt", &(bd_Rupture->pf_InputFil)) == ERR)
   {
      RETURN_VAL(ERR);
   }
  bd_Rupture->n_NbRupture = 0;
  bd_Rupture->n_ActionLigne = n_ActionLigne_gtr;
  bd_Rupture->c_Separ = '~';

   RETURN_VAL(OK);
}

/**************************************************************************/
/***    Objet :                                                         ***/

/***    OK si pas d'erreur,                                             ***/

/***    ERR si erreur.                                                  ***/

/**************************************************************************/

int n_InitRuptgt(T_RUPTURE_SYNC_VAR *pdb_Rupt)
{

   DEBUT_FCT("n_InitRuptgt");
   memset(pdb_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR));

/* Ouverture du fichier esclave */
if (n_OpenFileAppl("ESTM7608_I1", "rt", &(pdb_Rupt->pf_InputFil)) == ERR)
   {
      RETURN_VAL(ERR);
   }
  pdb_Rupt->ConditionEndSync = n_ConditionSyncgt;
  pdb_Rupt->n_ActionLigne = n_ActionLignegt;
  pdb_Rupt->c_Separ = '~';

   RETURN_VAL(OK);
}


/**************************************************************************/
/***    Objet : test de rupture                                       ***/

/***    OK si pas d'erreur,                                             ***/

/***    ERR si erreur.                                                  ***/

/**************************************************************************/

int n_ConditionSyncgt(char **pdb_InRecOwner, char **pdb_InRecChild)
{
  int ret;

  if((ret=strcmp(pdb_InRecOwner[COR_CTR_NF],pdb_InRecChild[GT_CTR_NF])) != 0) return ret;
  if((ret=strcmp(pdb_InRecOwner[COR_END_NT],pdb_InRecChild[GT_END_NT])) != 0) return ret;
  if((ret=strcmp(pdb_InRecOwner[COR_SEC_NF],pdb_InRecChild[GT_SEC_NF])) != 0) return ret;
  if((ret=strcmp(pdb_InRecOwner[COR_UWY_NF],pdb_InRecChild[GT_UWY_NF])) != 0) return ret;
  if((ret=strcmp(pdb_InRecOwner[COR_UW_NT], pdb_InRecChild[GT_UW_NT])) != 0) return ret;

  return ( 0);
}

/*************************************************************************/

/***    Objet : test de rupture                                       ***/

/***    OK si pas d'erreur,                                             ***/

/***    ERR si erreur.                                                  ***/
/**************************************************************************/

int n_ActionLigne_gtr(char **pdb_InRecOwner)
{
    n_ProcessingRuptureSyncVar(&bd_Rupt,pdb_InRecOwner);
    return OK;
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du fichier GT-TOTAGTAR	***/
/*** Nom : n_ActionLigne						***/
/*** Parametres:							***/
/***	i pdb_InRecChild : pointeur sur la ligne courante		***/

/*** Retour:
/***	OK si pas d'erreur,						            ***/
/***	ERR si erreur.							            ***/
/**************************************************************************/

int n_ActionLignegt(char **pdb_InRecOwner,char **pdb_InRecChild)
{
    /* Declartion des variables*/
    double VAR_AMT;
    double VAR_RETAMT;
    double VAR_RETINTAMT;
    double VAR_TauxCession;
    char sz_tmp[30];
    char sz_tmpret[30];
    char sz_tmpretint[30];
    char sz_trncod[9];
    char sz_dbltrncod[9];

    DEBUT_FCT("n_ActionLignegt");


    /* Initialisation des parametres*/
    VAR_AMT= 0;
    VAR_RETAMT= 0;
    VAR_RETINTAMT= 0;

    // Changement du TRNCOD
    memset(sz_trncod,0,sizeof(sz_trncod));
    strcpy(sz_trncod, pdb_InRecChild[GT_TRNCOD_CF]);

    if (sz_trncod[0]== '1')
    {
        sz_trncod[0]= '2';
    }

    if (sz_trncod[0]== '3')
    {
        sz_trncod[0]= '4';
    }
    pdb_InRecChild[GT_TRNCOD_CF]= sz_trncod;


    memset(sz_dbltrncod,0,sizeof(sz_dbltrncod));
    strcpy(sz_dbltrncod, pdb_InRecChild[GT_DBLTRNCOD_CF]);
    if (sz_dbltrncod[0]== '1')
    {
        sz_dbltrncod[0]= '2';
    }

    if (sz_dbltrncod[0]== '3')
    {
        sz_dbltrncod[0]= '4';
    }
    pdb_InRecChild[GT_DBLTRNCOD_CF]= sz_dbltrncod;


    pdb_InRecChild[GT_RETOCCYEA_NF] = pdb_InRecChild[GT_OCCYEA_NF];
    pdb_InRecChild[GT_RETACY_NF] = pdb_InRecChild[GT_ACY_NF];
    pdb_InRecChild[GT_RETSCOSTRMTH_NF] = pdb_InRecChild[GT_SCOSTRMTH_NF];
    pdb_InRecChild[GT_RETSCOENDMTH_NF] = pdb_InRecChild[GT_SCOENDMTH_NF];
    pdb_InRecChild[GT_RETCUR_CF] = pdb_InRecChild[GT_CUR_CF];

    pdb_InRecChild[GT_RETCTR_NF] = pdb_InRecOwner[COR_RETCTR_NF];
    pdb_InRecChild[GT_RETEND_NT] = pdb_InRecOwner[COR_RETEND_NT];
    pdb_InRecChild[GT_RETSEC_NF] = pdb_InRecOwner[COR_RETSEC_NF];
    pdb_InRecChild[GT_RTY_NF] = pdb_InRecOwner[COR_RTY_NF];
    pdb_InRecChild[GT_RETUW_NT] = pdb_InRecOwner[COR_RETUW_NT];

    pdb_InRecChild[GT_PLC_NT] = pdb_InRecOwner[COR_PLC_NT];
    pdb_InRecChild[GT_RTO_NF] = pdb_InRecOwner[COR_RTO_NF];
    pdb_InRecChild[GT_INT_NF] = pdb_InRecOwner[COR_INT_NF];
    pdb_InRecChild[GT_RETPAY_NF] = pdb_InRecOwner[COR_RETPAY_NF];
    pdb_InRecChild[GT_RCL_NF] = pdb_InRecOwner[COR_RCL_NF];
    pdb_InRecChild[GT_RETKEY_CF] = pdb_InRecOwner[COR_RETKEY_CF];


    // Récupération Taux de Cession
    VAR_TauxCession= atof(pdb_InRecOwner[COR_TAUXCESSION]);
    sprintf(sz_tmp,"%-.3lf",VAR_TauxCession);

    // Transformation des Montants
    VAR_AMT= -atof(pdb_InRecChild[GT_AMT_M]) * VAR_TauxCession;
    sprintf(sz_tmp,"%-.3lf",VAR_AMT);

    // Montant d'Accept renseginé au Taux de Cession ?
    pdb_InRecChild[GT_AMT_M]= sz_tmp;

    // Montant de Rétro renseigné dans le GTAR
    pdb_InRecChild[GT_RETAMT_M]= sz_tmp;

// Forcé à 0    pdb_InRecChild[GT_RETINTAMT_M]= sz_tmp;
    // Pas de Montant de Rétro Interne dans Le GTAR
    VAR_RETINTAMT= 0;
    sprintf(sz_tmpretint,"%-.3lf",VAR_RETINTAMT);
    pdb_InRecChild[GT_RETINTAMT_M]= sz_tmpretint;

/*
    VAR_RETAMT= -atof(pdb_InRecChild[GT_RETAMT_M]) * VAR_TauxCession;
    sprintf(sz_tmpret,"%-.3lf",VAR_RETAMT);
    pdb_InRecChild[GT_RETAMT_M]= sz_tmpret;

    VAR_RETINTAMT= -atof(pdb_InRecChild[GT_RETINTAMT_M]) * VAR_TauxCession;
    sprintf(sz_tmpretint,"%-.3lf",VAR_RETINTAMT);
    pdb_InRecChild[GT_RETINTAMT_M]= sz_tmpretint;
*/
    n_WriteCols(Kp_OutputFileGTAR, pdb_InRecChild, '~', 0);

    VAR_RETAMT= 0;
    sprintf(sz_tmpret,"%-.3lf",VAR_RETAMT);

    // Montant Acceptation à 0
    pdb_InRecChild[GT_AMT_M]= sz_tmpret;

    // Montant retro Interne Renseigné (Placement à 100%)
    pdb_InRecChild[GT_RETINTAMT_M]= sz_tmp;

    pdb_InRecChild[GT_CED_NF]= "";
    pdb_InRecChild[GT_BRK_NF]= "";
    pdb_InRecChild[GT_PAY_NF]= "";
    pdb_InRecChild[GT_KEY_NF]= "";

    pdb_InRecChild[GT_CTR_NF]= "";
    pdb_InRecChild[GT_END_NT]= "";
    pdb_InRecChild[GT_SEC_NF]= "";
    pdb_InRecChild[GT_UWY_NF]= "";
    pdb_InRecChild[GT_UW_NT]= "";

    pdb_InRecChild[GT_OCCYEA_NF]= "";
    pdb_InRecChild[GT_ACY_NF]= "";
    pdb_InRecChild[GT_SCOSTRMTH_NF]= "";
    pdb_InRecChild[GT_SCOENDMTH_NF]= "";
    pdb_InRecChild[GT_CLM_NF]= "";
    pdb_InRecChild[GT_CUR_CF]= "";

    n_WriteCols(Kp_OutputFileGTR, pdb_InRecChild, '~', 0);

    RETURN_VAL(OK);
}


