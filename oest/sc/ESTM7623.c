/*==============================================================================
nom de l'application          : Auto booking of FAC premium
nom du source                 : ESTM7623.c
revision                      : $Revision:   1.0  $
date de creation              : 23/02/2021
auteur                        : R. Cassis
references des specifications : spira : 92356

------------------------------------------------------------------------------
Description :
   Calcul de l'OverDue des primes Fac 11104002. 
   A partir de ce qui est dû (FAMPRMD) et ce qui est comptabilisé, payé (DTSTATGTAA), on en déduit l'Overdue. postes 11104000,11104100,11108000
   L'OverDue sera stocké dans une autre écriture 11104102 et dans la ligne estimée, poste 11104002, on lui soustrait l'overDue.
   
historique des modifications :
[0x] 	<jj/mm/aaaa>	<auteur>	<description de la modification>
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <utctlib.h>
#include <stdarg.h>
#include <estserv.h>
#include "struct.h"

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

#define FAM_CTR_NF 0
#define FAM_END_NT 1
#define FAM_SEC_NF 2
#define FAM_UWY_NF 3
#define FAM_UW_NT 4
#define FAM_EGPCUR_CF 5
#define FAM_PRMDUE_M 6

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE *Kp_GetTaux;   /* Pointeur sur le fichier des taux */
FILE *Kp_OutFile;		/* pointeur sur les primes estimées en sortie */

char **Kptsz_PERICASE; /* Pointeur sur la ligne de l'esclave permettant de */
                       /* recuperer des donnees du maitre */

T_RUPTURE_VAR    	  *pbd_RuptGTAAPRE;        /* gestion rupture sur les estimés */
T_RUPTURE_SYNC_VAR  *pbd_SyncPERICASE;       /* gestion Syncro entre estimés et PERICASE */
T_RUPTURE_SYNC_VAR  *pbd_SyncFAMPRMD;        /* gestion Syncro entre estimés et FAMPRMD */
T_RUPTURE_SYNC_VAR  *pbd_SyncDTSTATGTAA;     /* gestion Syncro entre estimés et DTSTATGTAA */

char   Ksz_MessageErr[256]; /* Message d'erreur */
int    Kn_BALSHTYEA;        /* Annee utilisee pour le cours en actuariat */
double d_amtBooked = 0.0;   /* Total primes comptabilisées */
double d_prmDue = 0.0;      /* Total primes dues */

/*------------------------*/
/* Prototype des fonction */
/*------------------------*/

/*--------------------------------------------------------------*/
/* Fonctions du fichier Maitre GTAAPRE                          */
/*--------------------------------------------------------------*/
int n_InitGTAAPRE(T_RUPTURE_VAR *pbd_RuptGTAAPRE);
int n_ActionLigneGTAAPRE(char **pbd_InRec_Cur);

/*--------------------------------------------------------------*/
/* Fonctions de la synchronisation avec IADPERICASE             */
/*--------------------------------------------------------------*/
int n_InitSyncPERICASE(T_RUPTURE_SYNC_VAR  *pbd_Rupt);
int n_ConditionSyncPERICASE(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ActionLigneSyncPERICASE(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);

/*--------------------------------------------------------------*/
/* Fonctions de la synchronisation avec FAMPRMD                 */
/*--------------------------------------------------------------*/
int n_InitSyncFAMPRMD(T_RUPTURE_SYNC_VAR  *pbd_Rupt);
int n_ConditionSyncFAMPRMD(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ActionLigneSyncFAMPRMD(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);

/*--------------------------------------------------------------*/
/* Fonctions de la synchronisation avec DTSTATGTAA              */
/*--------------------------------------------------------------*/
int n_InitSyncDTSTATGTAA(T_RUPTURE_SYNC_VAR  *pbd_Rupt);
int n_ConditionSyncDTSTATGTAA(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ActionLigneSyncDTSTATGTAA(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);


/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{
	
  pbd_RuptGTAAPRE = malloc(sizeof(T_RUPTURE_VAR));
  pbd_SyncPERICASE = malloc(sizeof(T_RUPTURE_SYNC_VAR));
  pbd_SyncFAMPRMD = malloc(sizeof(T_RUPTURE_SYNC_VAR));
  pbd_SyncDTSTATGTAA = malloc(sizeof(T_RUPTURE_SYNC_VAR));

  /* Initialisation des signaux */
  InitSig();
  
  if (n_BeginPgm(argc  ,argv) == ERR)
    ExitPgm(ERR_XX , "ERROR à la récupération des paramètre");

  /* En actuariat, recuperation de BALSHTYEA_NF */
  Kn_BALSHTYEA = n_GetIntArgv(1);
  
  /* Ouverture du fichier des primes */
  if (n_OpenFileAppl("ESTM7623_O1","wt",&Kp_OutFile) == ERR)
    ExitPgm(ERR_XX, "ESTM7623_O1 can't be open");
  
  /* Initialisation du GTAAPRE des facs estimées*/
  if (n_InitGTAAPRE(pbd_RuptGTAAPRE))
    ExitPgm(ERR_XX , "pbd_RuptGTAAPRE initialisation failed");
  
  /* Initialisation de la synchronisation avec PERICASE*/
  if (n_InitSyncPERICASE(pbd_SyncPERICASE))
    ExitPgm(ERR_XX , "pbd_SyncPERICASE initialisation failed");
  
  /* Initialisation de la synchronisation avec FAMPRMD primes dues */
  if (n_InitSyncFAMPRMD(pbd_SyncFAMPRMD) == ERR)
    ExitPgm(ERR_XX , "pbd_SyncFAMPRMD initialisation failed");
  
  /* Initialisation de la synchronisation avec DTSTATGTAA facs comptabilisées */
  if (n_InitSyncDTSTATGTAA(pbd_SyncDTSTATGTAA) == ERR)
    ExitPgm(ERR_XX , "pbd_SyncDTSTATGTAA initialisation failed");
  
  /* Ouverture du fichier des taux */
  if (n_OpenFileAppl("ESTM7623_I5", "rb", &Kp_GetTaux) == ERR)
    ExitPgm(ERR_XX, "Erreur appel fonction n_OpenFileApplGetTaux");
  
  /* Lancement du traitement du fichier */
  if (n_ProcessingRuptureVar(pbd_RuptGTAAPRE) == ERR)
    ExitPgm(ERR_XX, "");
  
  /* Fermeture des fichiers */
  if (n_CloseFileAppl("ESTM7623_I1",&(pbd_RuptGTAAPRE->pf_InputFil)) == ERR)
    ExitPgm(ERR_XX, "ESTM7623_I1 can't be close");
  
  if (n_CloseFileAppl("ESTM7623_I2",&(pbd_SyncPERICASE->pf_InputFil)) == ERR)
    ExitPgm(ERR_XX, "ESTM7623_I2 can't be close");
  
  if (n_CloseFileAppl("ESTM7623_I3",&(pbd_SyncFAMPRMD->pf_InputFil)) == ERR)
    ExitPgm(ERR_XX, "ESTM7623_I3 can't be close");
  
  if (n_CloseFileAppl("ESTM7623_I4",&(pbd_SyncDTSTATGTAA->pf_InputFil)) == ERR)
    ExitPgm(ERR_XX, "ESTM7623_I4 can't be close");
  
  if (n_CloseFileAppl("ESTM7623_I5", &Kp_GetTaux) == ERR)
    ExitPgm(ERR_XX, "ESTM7623_I5 can't be close");
    
  if (n_CloseFileAppl("ESTM7623_O1",&Kp_OutFile) == ERR)
    ExitPgm(ERR_XX, "ESTM7623_O1 can't be close");
  
  if (n_EndPgm() == ERR)
    ExitPgm(ERR_XX , "ERROR en sortie de programme");
  
  exit(0);
}

/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du 
        fichier maitre GT des primes estimees.
retour :
        0
==============================================================================*/
int n_InitGTAAPRE(T_RUPTURE_VAR  *pbd_RuptGTAAPRE)
{
  DEBUT_FCT("n_InitGTAAPRE");

  memset(pbd_RuptGTAAPRE,0,sizeof(T_RUPTURE_VAR));

  /* Ouverture du fichier esclave */
  if (n_OpenFileAppl("ESTM7623_I1", "rt", &(pbd_RuptGTAAPRE->pf_InputFil)) == ERR)
    RETURN_VAL(ERR);

  pbd_RuptGTAAPRE->n_ActionLigne = n_ActionLigneGTAAPRE;
  pbd_RuptGTAAPRE->c_Separ = '~';

  RETURN_VAL(OK);
}

/*==============================================================================
objet :
        Initialisation de la synchronisation du PERICASE
retour :
        0
==============================================================================*/
int n_InitSyncPERICASE(T_RUPTURE_SYNC_VAR  *pbd_SyncPERICASE)
{
  DEBUT_FCT("n_InitSyncPERICASE");

  memset(pbd_SyncPERICASE, 0, sizeof(T_RUPTURE_SYNC_VAR));

  /* ouverture du fichier esclave */
  if (n_OpenFileAppl("ESTM7623_I2", "rt", &(pbd_SyncPERICASE->pf_InputFil)) == ERR)
    RETURN_VAL(ERR);

  /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
  pbd_SyncPERICASE->ConditionEndSync 	= n_ConditionSyncPERICASE;
  pbd_SyncPERICASE->n_ActionLigne = n_ActionLigneSyncPERICASE;
  pbd_SyncPERICASE->c_Separ 			= '~';

  RETURN_VAL(OK);
}

/*==============================================================================
param :
       pbd_InRecGTAAPRE 	-> Fichier père
       pbd_InRecPERICASE  -> Fichier Fils
objet :
       fonction de test de synchronisation
==============================================================================*/
int n_ConditionSyncPERICASE(char *pbd_InRecGTAAPRE[], char *pbd_InRecPericase[])
{
  int ret = 0;

  DEBUT_FCT("n_ConditionSyncPERICASE");

  if ((ret = strcmp(pbd_InRecGTAAPRE[GT_CTR_NF], pbd_InRecPericase[PER_CTR_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecGTAAPRE[GT_END_NT], pbd_InRecPericase[PER_END_NT])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecGTAAPRE[GT_SEC_NF], pbd_InRecPericase[PER_SEC_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecGTAAPRE[GT_UWY_NF], pbd_InRecPericase[PER_UWY_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecGTAAPRE[GT_UW_NT] , pbd_InRecPericase[PER_UW_NT]))  != 0) return ret;

  RETURN_VAL(OK);
}

/*==============================================================================
objet :
       Initialisation de la synchronisation avec FAMPRMD
retour :
        0
==============================================================================*/
int n_InitSyncFAMPRMD( T_RUPTURE_SYNC_VAR  *pbd_SyncFAMPRMD )
{
  DEBUT_FCT("n_InitSyncFAMPRMD");

  memset(pbd_SyncFAMPRMD, 0, sizeof(T_RUPTURE_SYNC_VAR));

  /* Ouverture du fichier esclave */
  if (n_OpenFileAppl("ESTM7623_I3", "rt", &(pbd_SyncFAMPRMD->pf_InputFil)) == ERR)
    RETURN_VAL(ERR);

  pbd_SyncFAMPRMD->ConditionEndSync = n_ConditionSyncFAMPRMD;
  pbd_SyncFAMPRMD->n_ActionLigne = n_ActionLigneSyncFAMPRMD;
  pbd_SyncFAMPRMD->c_Separ = '~';

  RETURN_VAL(OK);
}

/*==============================================================================
param :
       pbd_InRecGTAAPRE  -> Fichier père
       pbd_InRecFAMPRMD  -> Fichier Fils
objet :
       fonction de test de synchronisation
==============================================================================*/
int n_ConditionSyncFAMPRMD( char *pbd_InRecGTAAPRE[], char *pbd_InRecFAMPRMD[] )
{
  int ret = 0;

  DEBUT_FCT("n_ConditionSyncFAMPRMD");

  if ((ret = strcmp(pbd_InRecGTAAPRE[GT_CTR_NF], pbd_InRecFAMPRMD[FAM_CTR_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecGTAAPRE[GT_END_NT], pbd_InRecFAMPRMD[FAM_END_NT])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecGTAAPRE[GT_SEC_NF], pbd_InRecFAMPRMD[FAM_SEC_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecGTAAPRE[GT_UWY_NF], pbd_InRecFAMPRMD[FAM_UWY_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecGTAAPRE[GT_UW_NT] , pbd_InRecFAMPRMD[FAM_UW_NT]))  != 0) return ret;

  RETURN_VAL(OK);
}

/*==============================================================================
objet :
       Initialisation de la synchronisation avec DTSTATGTAA
retour :
        0
==============================================================================*/
int n_InitSyncDTSTATGTAA( T_RUPTURE_SYNC_VAR  *pbd_SyncDTSTATGTAA )
{
  DEBUT_FCT("n_InitSyncDTSTATGTAA");

  memset(pbd_SyncDTSTATGTAA, 0, sizeof(T_RUPTURE_SYNC_VAR));

  /* Ouverture du fichier esclave */
  if (n_OpenFileAppl("ESTM7623_I4", "rt", &(pbd_SyncDTSTATGTAA->pf_InputFil)) == ERR)
    RETURN_VAL(ERR);

  pbd_SyncDTSTATGTAA->ConditionEndSync = n_ConditionSyncDTSTATGTAA;
  pbd_SyncDTSTATGTAA->n_ActionLigne = n_ActionLigneSyncDTSTATGTAA;
  pbd_SyncDTSTATGTAA->c_Separ = '~';

  RETURN_VAL(OK);
}

/*==============================================================================
param :
       pbd_InRecGTAAPRE     -> Fichier père
       pbd_InRecDTSTATGTAA  -> Fichier Fils
objet :
       fonction de test de synchronisation
==============================================================================*/
int n_ConditionSyncDTSTATGTAA( char *pbd_InRecGTAAPRE[], char *pbd_InRecDTSTATGTAA[] )
{
  int ret = 0;

  DEBUT_FCT("n_ConditionSyncDTSTATGTAA");

  if ((ret = strcmp(pbd_InRecGTAAPRE[GT_CTR_NF], pbd_InRecDTSTATGTAA[GT_CTR_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecGTAAPRE[GT_END_NT], pbd_InRecDTSTATGTAA[GT_END_NT])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecGTAAPRE[GT_SEC_NF], pbd_InRecDTSTATGTAA[GT_SEC_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecGTAAPRE[GT_UWY_NF], pbd_InRecDTSTATGTAA[GT_UWY_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecGTAAPRE[GT_UW_NT] , pbd_InRecDTSTATGTAA[GT_UW_NT]))  != 0) return ret;

  RETURN_VAL(OK);
}

/*==============================================================================
objet :
       fonction lancee pour chaque ligne du fichier Maitre des primes estimées
Retour:
       0
==============================================================================*/
int n_ActionLigneGTAAPRE(char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_ActionLigneGTAAPRE");

  char   ksz_Amt[25];
  double d_overDue;           /* Prime OverDue */
  char   c_flagWrite='N';     /* Flag pour écriture */

  d_amtBooked = 0.0;   /* Total primes comptabilisées */
  d_prmDue = 0.0;      /* Total primes dues */

//printf("==> Ici 0 : %s",ptb_InRec_Cur[GT_TRNCOD_CF]);
  
	if (strcmp(ptb_InRec_Cur[GT_TRNCOD_CF], "11104002") == 0)
	{
    if (n_ProcessingRuptureSyncVar(pbd_SyncFAMPRMD, ptb_InRec_Cur) == ERR)
      RETURN_VAL(ERR);
  
    if (d_prmDue != 0.0)
    {
    	// On synchronise avec le PERICASE
      if (n_ProcessingRuptureSyncVar(pbd_SyncPERICASE, ptb_InRec_Cur) == ERR)
        RETURN_VAL(ERR);
  
    	// On va récupérer le montant total des primes 11104000 comptabilisées dans DTSTATGTAA
      if (n_ProcessingRuptureSyncVar(pbd_SyncDTSTATGTAA, ptb_InRec_Cur) == ERR)
        RETURN_VAL(ERR);

    // record pour l'Estimé
      d_overDue = d_prmDue - d_amtBooked;
      if (d_overDue < 0.0) d_overDue = 0.0;
      ///ksz_Amt/if (fabs(atof(ptb_InRec_Cur[GT_AMT_M]) - d_overDue) >= 1)
      {
        sprintf(ksz_Amt, "%-.3f", atof(ptb_InRec_Cur[GT_AMT_M]) - d_overDue);
        ptb_InRec_Cur[GT_AMT_M] = ksz_Amt;
        n_WriteCols(Kp_OutFile, ptb_InRec_Cur, '~', 0);
      }
/*
if (strcmp(ptb_InRec_Cur[GT_CTR_NF],"FA0013539") == 0)
printf("==> Ici 2 : d_overDue = %-.3f - d_prmDue = %-.3f - d_amtBooked = %-.3f - GT_AMT = %-.3f\n",d_overDue,d_prmDue,d_amtBooked,atof(ptb_InRec_Cur[GT_AMT_M]));
*/
      // record pour l'OverDue
      if (d_overDue >= 1.0)
      {
        sprintf(ksz_Amt, "%-.3f", d_overDue);
        strcpy(ptb_InRec_Cur[GT_TRNCOD_CF], "11104012");
        strcpy(ptb_InRec_Cur[GT_DBLTRNCOD_CF], "12104012");
        c_flagWrite = 'Y';
      }
    }
  	else
      c_flagWrite = 'Y';
  }
/*
if (strcmp(ptb_InRec_Cur[GT_CTR_NF],"FA0013539") == 0)
printf("==> Ici 1 : d_overDue = %-.3f - d_prmDue = %-.3f - d_amtBooked = %-.3f - c_flagWrite = %c\n",d_overDue,d_prmDue,d_amtBooked, c_flagWrite);
*/  
  if (c_flagWrite == 'Y')
    n_WriteCols(Kp_OutFile, ptb_InRec_Cur, '~', 0);

  RETURN_VAL(OK);
}

/*==============================================================================
objet :
       fonction lancee pour chaque ligne du fichier des primes dues a échéance FAMPRMD
Retour:
       0
==============================================================================*/
int n_ActionLigneSyncFAMPRMD(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[])
{
	DEBUT_FCT("n_ActionLigneSyncFAMPRMD");
	
	// On stocke le montant total de la prime due
	d_prmDue = atof(ptsz_LigneEsclave[FAM_PRMDUE_M]);

  RETURN_VAL(OK);
}

/*==============================================================================
objet :
       fonction lancee pour chaque ligne du PERICASE
Retour:
       0
==============================================================================*/
int n_ActionLigneSyncPERICASE(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[])
{
  DEBUT_FCT("n_ActionLigneSyncPERICASE");

  // Sauvegarde du pointeur sur PERICASE
  Kptsz_PERICASE = ptsz_LigneEsclave;

  RETURN_VAL(OK);
}

/*==============================================================================
objet :
       fonction lancee pour chaque ligne du fichier des primes comptabilisées DTSTATGTAA
Retour:
       0
==============================================================================*/
int n_ActionLigneSyncDTSTATGTAA(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[])
{
	DEBUT_FCT("n_ActionLigneSyncDTSTATGTAA");

  double d_Taux;

	if (strcmp(ptsz_LigneEsclave[GT_TRNCOD_CF], "11104000") == 0 || strcmp(ptsz_LigneEsclave[GT_TRNCOD_CF], "11104100") == 0 || strcmp(ptsz_LigneEsclave[GT_TRNCOD_CF], "11108000") == 0)
	{
    d_Taux = d_GetTaux(Kp_GetTaux, (unsigned char)atoi(Kptsz_PERICASE[PER_SSD_CF]), atoi(ptsz_LigneEsclave[GT_UWY_NF])-1, ptsz_LigneEsclave[GT_CUR_CF], Kptsz_PERICASE[PER_EGPCUR_CF]);
  
    /* Generation d'une anomalie quand la fonction de taux renvoie 0 */
    if (d_Taux == -1 || d_Taux == 0)
    {
      sprintf(Ksz_MessageErr, "SSD : %s ; UWY : %d ; INITIAL CUR : %s ; FINAL CUR %s",
              Kptsz_PERICASE[PER_SSD_CF], Kn_BALSHTYEA,
              ptsz_LigneEsclave[GT_CUR_CF], Kptsz_PERICASE[PER_EGPCUR_CF]);
      n_WriteAno(Ksz_MessageErr);
    }
  	
    d_amtBooked += atof(ptsz_LigneEsclave[GT_AMT_M]) * d_Taux;
  }
	
  RETURN_VAL(OK);
}

