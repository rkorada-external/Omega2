/*==============================================================================
nom de l'application          : Mise a jour des valeurs d'amortissement
nom du source                 : ESTC2031.c
revision                      : $Revision: 1.1.1.1 $
date de creation              : 24/03/2015
auteur                        : T.LAIDI
references des specifications : SPOT:28554
squelette de base             : batch
------------------------------------------------------------------------------
description : recalcul le montant 'amortissement' (poste 43820) d'un contrat a
              partir des montants 'Net' (poste 43800) et 'Gross' (poste 43810).

------------------------------------------------------------------------------
historique des modifications :
[001] 15/04/2015 P. Menant    :spot:28554 - Correction du probleme decouvert sur MAI (n_ActionFirstRuptNet -> n_ActionLineRuptNet)
==============================================================================*/

/*------------------------------------------------------*/
/* inclusion des interfaces des composants importes     */
/*-----------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*--------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

static FILE *Kp_newAmort;                  /* Pointeur sur le fichier de sortie */
static T_RUPTURE_VAR bd_RuptNet;           /* Structure de gestion des ruptures sur les postes Net */
static T_RUPTURE_SYNC_VAR bd_SynctGross;   /* Structure de gestion de la synchro Net/Gross */
static T_RUPTURE_SYNC_VAR bd_SynctAmort;   /* Structure de gestion de la synchro Net/Amort */


static char Ksz_curDate[9];                /* Date courante */
static double Kf_netAmount;                /* Montant Net */
static double Kf_grossAmount;              /* Montant Gross */

static int n_InitNetAmount(T_RUPTURE_VAR *);           /* Procedure d'initialisation de la structure de gestion des ruptures du fichier maitre 'Net' */
static int n_IsR1Net(char *[], char *[]);              /* Procedure de detection des ruptures du fichier maitre */
static int n_ActionLineRuptNet(char *[]);              /* Procedure de traitement sur chaque ligne du fichier maitre */  // [001]

static int n_InitSyncGross(T_RUPTURE_SYNC_VAR *);      /* Procedure d'initialisation de la structure de gestion de la synchro du fichier 'Gross' */
static int n_ConditionSyncGross(char *[], char *[]);   /* Procedure de detection de perte de synchro du fichier 'Gross' */
static int n_ActionLigneGross(char *[], char *[]);     /* Procedure de traitement d'une perte de synchro sur le fichier 'Gross' */
static int n_PereSansFils(char *[]);                   /* Procedure de traitement pour les enregistrements du fichier 'Net' absents de 'Gross' ou 'Amort' */

static int n_InitSyncAmort(T_RUPTURE_SYNC_VAR *);      /* Procedure d'initialisation de la structure de gestion de la synchro du fichier 'Amort' */
static int n_ConditionSyncAmort(char *[], char *[]);   /* Procedure de detection de perte de synchro du fichier 'Amort' */
static int n_ActionLigneAmort(char *[], char *[]);     /* Procedure de traitement d'une perte de synchro sur le fichier 'Amort' */


/*==============================================================================
objet : point d'entrée du programme

retour : En cas de probleme la sortie s'effectue par la fonction ExitPgm()
         Sinon par l'appel systeme exit()
================================================================================*/
int main(int argc ,char *argv[])
{
  /* Initialisation des signaux */
  InitSig();

  /* Traitement generique intial d'un programme */
  if (n_BeginPgm(argc, argv) == ERR)
    {ExitPgm(ERR_XX, "Failure during n_BeginPgm() call");}

  /* Recuperation des arguments et initialisation des variables globales */
  (void)snprintf(Ksz_curDate, 9, "%s", psz_GetCharArgv(1));
  Kf_netAmount = 0.0;
  Kf_grossAmount = 0.0;
  
  /* Creation du fichier de sortie */
  if (n_OpenFileAppl("ESTC2031_O1", "wt", &Kp_newAmort) == ERR)
    {ExitPgm(ERR_XX, "Cannot create file 'ESTC2031_O1'");}

  /* Initialisation de la structure bd_RuptNet */
  if (n_InitNetAmount(&bd_RuptNet) != OK)
    {ExitPgm(ERR_XX, "Failure during n_InitNetAmount() call");}

  /* Initialisation de la structure bd_SynctGross */
  if (n_InitSyncGross(&bd_SynctGross)!= OK)
    {ExitPgm(ERR_XX, "Failure during n_InitSyncGross() call");}

  /* Initialisation de la structure bd_SynctAmort */
  if (n_InitSyncAmort(&bd_SynctAmort)!= OK)
    {ExitPgm(ERR_XX, "Failure during n_InitSyncAmort() call");}

  /* lancement du traitement du fichier */
  if (n_ProcessingRuptureVar(&bd_RuptNet) == ERR)
    {ExitPgm(ERR_XX, "Failure during n_ProcessingRuptureVar() call");}

  /* 3 fichiers en entrée ESTC2031_I1 & ESTC2031_I2 & ESTC2031_I3*/
  if (n_CloseFileAppl("ESTC2031_I1", &(bd_RuptNet.pf_InputFil)) != OK)
    {ExitPgm(ERR_XX, "Cannot close properly file 'ESTC2031_I1'");}

  if (n_CloseFileAppl("ESTC2031_I2", &(bd_SynctGross.pf_InputFil)) != OK)
    {ExitPgm(ERR_XX, "Cannot close properly file 'ESTC2031_I2'");}

  if (n_CloseFileAppl("ESTC2031_I3", &(bd_SynctAmort.pf_InputFil)) != OK)
    {ExitPgm(ERR_XX, "Cannot close properly file 'ESTC2031_I3'");}

  if (n_CloseFileAppl("ESTC2031_O1", &Kp_newAmort) != OK)
    {ExitPgm(ERR_XX, "Cannot close properly file 'ESTC2031_O1'");}

  if (n_EndPgm() == ERR)
    {ExitPgm(ERR_XX, "Failure during n_EndPgm() call");}

  exit(OK);
}


/*==============================================================================
objet : Procedure d'initialisation de la structure de gestion des ruptures du fichier maitre 'Net'

retour : ERR si fichier d'entree non trouve
         OK sinon
==============================================================================*/
int n_InitNetAmount(T_RUPTURE_VAR *pbd_Rupt)
{
  DEBUT_FCT("n_InitNetAmount");

  memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

  /* ouverture du fichier esclave */
  if (n_OpenFileAppl("ESTC2031_I1", "rt", &(pbd_Rupt->pf_InputFil)) != OK)
    {RETURN_VAL(ERR);}

  pbd_Rupt->n_NbRupture = 1;                          // Rupture sur une seule cle
  pbd_Rupt->n_ConditionRupture[0] = n_IsR1Net;        // Procedure de detection des ruptures
  pbd_Rupt->n_ActionLigne = n_ActionLineRuptNet;      // Procedure de traitement sur chaque ligne du fichier maitre // [001]
  pbd_Rupt->c_Separ = '~';

  RETURN_VAL(OK);
}


/*==============================================================================
objet : Procedure de detection des ruptures de niveau 1 du fichier maitre 'Net'
        sur la cle 'Contrat/Section/Exercice/Annee de compte/Gaap'
retour : 0 ---> Pas de rupture
         -1 ou 1 ---> rupture
==============================================================================*/
int n_IsR1Net(char *ptb_InRecN[], char *ptb_InRecNMinusOne[])
{
  int ret;

  DEBUT_FCT("n_IsR1Net");

  if ((ret = strcmp(ptb_InRecN[PRE_CTR_NF], ptb_InRecNMinusOne[PRE_CTR_NF])) != 0)
    {RETURN_VAL(ret);}
  if ((ret = strcmp(ptb_InRecN[PRE_SEC_NF], ptb_InRecNMinusOne[PRE_SEC_NF])) != 0)
    {RETURN_VAL(ret);}
  if ((ret = strcmp(ptb_InRecN[PRE_UWY_NF], ptb_InRecNMinusOne[PRE_UWY_NF])) != 0)
    {RETURN_VAL(ret);}
  if ((ret = strcmp(ptb_InRecN[PRE_ACY_NF], ptb_InRecNMinusOne[PRE_ACY_NF])) != 0)
    {RETURN_VAL(ret);}
  if ((ret = strcmp(ptb_InRecN[PRE_GAAP_NF], ptb_InRecNMinusOne[PRE_GAAP_NF])) != 0)
    {RETURN_VAL(ret);}

  RETURN_VAL (ret);
}


/*==============================================================================
objet : Procedure de traitement initial d'une rupture

retour : OK
==============================================================================*/
int n_ActionLineRuptNet(char *ptb_InRecNetFile[])   // [001]
{
	int ret = OK;

  DEBUT_FCT("n_ActionLineRuptNet");  // [001]

  /* Controle qu'il s'agit bien d'un poste 'Net' */
  if (strcmp(ptb_InRecNetFile[PRE_DETTRNCOD_CF], "43800") == 0)
  {
    Kf_netAmount = atof(ptb_InRecNetFile[PRE_ESTMNT_M]);
    /* Synchronisation avec le fichier 'Gross' */
    ret = n_ProcessingRuptureSyncVar(&bd_SynctGross, ptb_InRecNetFile);
  } 

  RETURN_VAL(ret);
}


/*==============================================================================
objet : Procedure d'initialisation de la structure de gestion de la synchro du fichier 'Gross'

retour : ERR si fichier d'entree non trouve
         OK sinon
==============================================================================*/
int n_InitSyncGross(T_RUPTURE_SYNC_VAR *pbd_Rupt)
{
  DEBUT_FCT("n_InitSyncGross");

  memset(pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR));

  /* Ouverture du fichier esclave 1 'Gross' */
  if (n_OpenFileAppl("ESTC2031_I2", "rt", &(pbd_Rupt->pf_InputFil)) != OK)
    {RETURN_VAL(ERR);}

  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->ConditionEndSync = n_ConditionSyncGross;  // Procedure de detection de perte de synchro avec le maitre 'Net'
  pbd_Rupt->n_ActionLigne = n_ActionLigneGross;       // Procedure de traitement des pertes de synchro
  pbd_Rupt->n_PereSansFils = n_PereSansFils;
  pbd_Rupt->c_Separ = '~';

  RETURN_VAL(OK);
}


/*==============================================================================
objet : Procedure de detection de perte de synchro du fichier 'Gross'

retour : 0  ---> ptb_InRecNetFile = ptb_InRecGrossFile ( egalite des champs a synchroniser)
        > 0 ---> ptb_InRecNetFile> > ptb_InRecGrossFile
        < 0 ---> ptb_InRecNetFile> < ptb_InRecGrossFile
==============================================================================*/
int n_ConditionSyncGross(char *ptb_InRecNetFile[], char *ptb_InRecGrossFile[])
{
  int ret;

  DEBUT_FCT("n_ConditionSyncGross"); 

  if ((ret = strcmp(ptb_InRecNetFile[PRE_CTR_NF], ptb_InRecGrossFile[PRE_CTR_NF])) != 0)
    {RETURN_VAL(ret);}
  if ((ret = strcmp(ptb_InRecNetFile[PRE_SEC_NF], ptb_InRecGrossFile[PRE_SEC_NF])) != 0)
    {RETURN_VAL(ret);}
  if ((ret = strcmp(ptb_InRecNetFile[PRE_UWY_NF], ptb_InRecGrossFile[PRE_UWY_NF])) != 0)
    {RETURN_VAL(ret);}
  if ((ret = strcmp(ptb_InRecNetFile[PRE_ACY_NF], ptb_InRecGrossFile[PRE_ACY_NF])) != 0)
    {RETURN_VAL(ret);}
  if ((ret = strcmp(ptb_InRecNetFile[PRE_GAAP_NF], ptb_InRecGrossFile[PRE_GAAP_NF])) != 0)
    {RETURN_VAL(ret);}

  RETURN_VAL(ret);
}


/*==============================================================================
objet : Procedure de traitement d'une perte de synchro sur le fichier 'Gross'

retour : OK
=================================================================================*/
int n_ActionLigneGross(char *ptb_InRecNetFile[], char *ptb_InRecGrossFile[])
{
	int ret = OK;

  DEBUT_FCT("n_ActionLigneGross");

  /* Controle qu'il s'agit bien d'un poste 'Gross' */
  if (strcmp(ptb_InRecGrossFile[PRE_DETTRNCOD_CF], "43810") == 0)
  {
    Kf_grossAmount = atof(ptb_InRecGrossFile[PRE_ESTMNT_M]);
    /* Synchronisation avec le fichier 'Amort' */
    ret = n_ProcessingRuptureSyncVar(&bd_SynctAmort, ptb_InRecNetFile);
  }

  RETURN_VAL(ret);
}


/*==============================================================================
objet : Procedure de traitement en cas d'absence de la cle dans le fichier 'Gross'
        ou le fichier 'Amort'
retour : OK
=================================================================================*/
int n_PereSansFils(char *ptb_InRecNetFile[])
{
  double f_newAmort = 0.0;
  char sz_Mnt[30], sa_batch[2], sz_curDate[18], sz_user[4], sz_dettrncod[6],sz_acmtrs[5];
  char *psz_resLine[PRE_NBCOL+1];
  int i, ret = OK;
  int acmtrs=0;
  
  DEBUT_FCT("n_ActionLigneAmort");

  for (i = 0; i < PRE_NBCOL; i++)
  {
    psz_resLine[i] = ptb_InRecNetFile[i];
  }
  psz_resLine[PRE_NBCOL] = 0;

  /* Controle qu'il s'agit bien d'un poste 'Net' */
  if (strcmp(ptb_InRecNetFile[PRE_DETTRNCOD_CF], "43800") == 0)
  {
    f_newAmort = Kf_netAmount;
    (void)snprintf(sz_Mnt, 30, "%.3f", f_newAmort);
    psz_resLine[PRE_ESTMNT_M] = sz_Mnt;
    (void)snprintf(sa_batch, 2, "%s", "1");
    psz_resLine[PRE_BATCH_B] = sa_batch;
    (void)snprintf(sz_curDate, 18, "%s 23:59:50", Ksz_curDate);
    psz_resLine[PRE_CRE_D] = sz_curDate;
    psz_resLine[PRE_LSTUPD_D] = sz_curDate;
    (void)snprintf(sz_user, 4, "dbo");
    psz_resLine[PRE_LSTUPDUSR_CF] = sz_user;
    acmtrs = atoi(ptb_InRecNetFile[PRE_ACMTRS_NT]) + 300;
    (void)snprintf(sz_acmtrs, 5,"%d",  acmtrs);
    psz_resLine[PRE_ACMTRS_NT] = sz_acmtrs;
       (void)snprintf(sz_dettrncod, 6, "43820");
    psz_resLine[PRE_DETTRNCOD_CF] = sz_dettrncod;
    ret += n_WriteCols(Kp_newAmort, psz_resLine, '~', 0);
  }

  RETURN_VAL(ret);
}


/*==============================================================================
objet : Procedure d'initialisation de la structure de gestion de la synchro du fichier 'Amort'

retour : ERR si fichier d'entree non trouve
         OK sinon
==============================================================================*/
int n_InitSyncAmort(T_RUPTURE_SYNC_VAR *pbd_Rupt)
{
  DEBUT_FCT("n_InitSyncAmort");

  memset(pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR));

  /* Ouverture du fichier esclave 2 'Amort' */
  if (n_OpenFileAppl("ESTC2031_I3", "rt", &(pbd_Rupt->pf_InputFil)) != OK)
    {RETURN_VAL(ERR);}

  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->ConditionEndSync = n_ConditionSyncAmort;  // Procedure de detection de perte de synchro avec le maitre 'Net'
  pbd_Rupt->n_ActionLigne = n_ActionLigneAmort;       // Procedure de traitement des pertes de synchro
  pbd_Rupt->n_PereSansFils = n_PereSansFils;
  pbd_Rupt->c_Separ = '~';

  RETURN_VAL(OK);
}


/*==============================================================================
objet : Procedure de detection de perte de synchro du fichier 'Amort'

retour : 0  ---> ptb_InRecNetFile = ptb_InRecAmortFile ( egalite des champs a synchroniser)
        > 0 ---> ptb_InRecNetFile> > ptb_InRecAmortFile
        < 0 ---> ptb_InRecNetFile> < ptb_InRecAmortFile
==============================================================================*/
int n_ConditionSyncAmort(char *ptb_InRecNetFile[], char *ptb_InRecAmortFile[])
{
  int ret;

  DEBUT_FCT("n_ConditionSyncAmort"); 

  if ((ret = strcmp(ptb_InRecNetFile[PRE_CTR_NF], ptb_InRecAmortFile[PRE_CTR_NF])) != 0)
    {RETURN_VAL(ret);}
  if ((ret = strcmp(ptb_InRecNetFile[PRE_SEC_NF], ptb_InRecAmortFile[PRE_SEC_NF])) != 0)
    {RETURN_VAL(ret);}
  if ((ret = strcmp(ptb_InRecNetFile[PRE_UWY_NF], ptb_InRecAmortFile[PRE_UWY_NF])) != 0)
    {RETURN_VAL(ret);}
  if ((ret = strcmp(ptb_InRecNetFile[PRE_ACY_NF], ptb_InRecAmortFile[PRE_ACY_NF])) != 0)
    {RETURN_VAL(ret);}
  if ((ret = strcmp(ptb_InRecNetFile[PRE_GAAP_NF], ptb_InRecAmortFile[PRE_GAAP_NF])) != 0)
    {RETURN_VAL(ret);}
  
  RETURN_VAL(ret);
}


/*==============================================================================
objet : Procedure de traitement d'une perte de synchro sur le fichier 'Amort'

retour : OK
=================================================================================*/
int n_ActionLigneAmort(char *ptb_InRecNetFile[], char *ptb_InRecAmortFile[]) 
{
  double f_newAmort = 0.0;
  char sz_Mnt[30], sa_batch[2], sz_curDate[18], sz_user[4];
  char *psz_resLine[PRE_NBCOL+1];
  int i, ret = OK;

  DEBUT_FCT("n_ActionLigneAmort");

  for (i = 0; i < PRE_NBCOL; i++)
  {
    psz_resLine[i] = ptb_InRecAmortFile[i];
  }
  psz_resLine[PRE_NBCOL] = 0;

  /* Controle qu'il s'agit bien d'un poste 'Amort' */
  if (strcmp(ptb_InRecAmortFile[PRE_DETTRNCOD_CF], "43820") == 0)
  {
    f_newAmort = Kf_netAmount - Kf_grossAmount  ;
    (void)snprintf(sz_Mnt, 30, "%.3f", f_newAmort);
    psz_resLine[PRE_ESTMNT_M] = sz_Mnt;
    (void)snprintf(sa_batch, 2, "%s", "1");
    psz_resLine[PRE_BATCH_B] = sa_batch;
    (void)snprintf(sz_curDate, 18, "%s 23:59:50", Ksz_curDate);
    psz_resLine[PRE_CRE_D] = sz_curDate;
    psz_resLine[PRE_LSTUPD_D] = sz_curDate;
    (void)snprintf(sz_user, 4, "dbo");
    psz_resLine[PRE_LSTUPDUSR_CF] = sz_user;
    ret += n_WriteCols(Kp_newAmort, psz_resLine, '~', 0);
  }

  RETURN_VAL(ret);
}
