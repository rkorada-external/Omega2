/*==============================================================================
Nom de l'application          : Regroupement des fichiers : perimetre
                                XADPERICASE, FCTRULT, GT, FCTRGRO et
                                FCTREST (actuariat)
Nom du source                 : ESTC0603.c
Revision                      : $Revision: 1.2 $
Date de creation              : 23/06/1997
Auteur                        : CGI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
   Regroupement par synchronisations des fichiers perimetre XADPERICASE,
   FCTRULT, GT, FCTRGRO et FCTREST (actuariat) et ajout du numero de segment
   dans le perimetre (a la place du champ SEGTYP_CT).
   Le fichier perimetre est utilise comme fichier maitre.
------------------------------------------------------------------------------
Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <utctlib.h>
#include <stdarg.h>
#include "struct.h"


/*----------------------*/
/* Variables de travail */
/*----------------------*/

FILE 		   *Kp_OutputFileCASEXTRAV; /* Pointeur sur le fichier de */
                                            /* travail des affaires en sortie */
FILE 		   *Kp_OutputFilePERICASE; /* Pointeur sur le fichier */
                                           /* perimetre en sortie */
T_RUPTURE_VAR  	   *pbd_Rupture;   /* Pointeur sur la structure de la rupture */
T_RUPTURE_SYNC_VAR *pbd_SyncTCTRULT; /* Pointeur sur la structure de */
                                   /* synchronisation avec le fichier FCTRULT */
T_RUPTURE_SYNC_VAR *pbd_SyncGT;      /* Pointeur sur la structure de */
                                     /* synchronisation avec le fichier GT */
T_RUPTURE_SYNC_VAR *pbd_SyncTCTREST; /* Pointeur sur la structure de */
                                   /* synchronisation avec le fichier FCTREST */
T_RUPTURE_SYNC_VAR *pbd_SyncCTRGRO; /* Pointeur sur la structure de */
                                    /* synchronisation maitre FCTRGRO */
char Kc_SEGTYP_CT;    /* Type segment */
char Kc_INVTYP;       /* Type d'inventaire */
char Ksz_CLODAT_D[9]; /* Libelle d'inventaire */
short Ks_CompteurGT;  /* Compteur indiquant le nombre de postes du GT fournis */
char *Ktsz_Sortie[21];    /* Tableau de chaines a ecrire en sortie */
char Ksz_MessageErr[256]; /* Message d'erreur */
char Ksz_SEG_NF[11];      /* Chaine contenant SEG_NF */
char Ksz_Pai_M[25];       /* Chaine contenant Pai */
char Ksz_Scii_M[25];      /* Chaine contenant Scii */
char Ksz_Scci_M[25];      /* Chaine contenant Scci */
char Ksz_PAi_M[25];       /* Chaine contenant PAi */
char Ksz_Psi_M[25];       /* Chaine contenant Psi */
char Ksz_Ssi_M[25];       /* Chaine contenant Ssi */
char Ksz_Ssi_CT[2];       /* Chaine contenant Ssi_CT */
char Ksz_PAai_M[25];      /* Chaine contenant PAai */
char Ksz_Sai_M[25];       /* Chaine contenant Sai */
char Ksz_Sai_CT[2];       /* Chaine contenant Sai_CT */
char Ksz_CALAMTPRM_M[25]; /* Chaine contenant CALAMTPRM_M */
char Ksz_ENTAMTPRM_M[25]; /* Chaine contenant ENTAMTPRM_M */
char Ksz_ADMMODPRM_CT[2]; /* Chaine contenant ADMMODPRM_CT */
char Ksz_CALAMTCLM_M[25]; /* Chaine contenant CALAMTCLM_M */
char Ksz_ENTAMTCLM_M[25]; /* Chaine contenant ENTAMTCLM_M */
double Kd_Psi;            /* Variable contenant Psi */
double Kd_PAi;            /* Variable contenant PAi */
char Ksz_Sccai_M[25];      /* Chaine contenant Sccai */

char Ksz_ChaineVide[]=""; /* Chaine vide */
char Ksz_NombreNul[]="0.0"; /* Chaine contenant un nombre nul */
char Ksz_ModeGestionManuel[]="A"; /* Chaine contenant le mode de */
                                  /* gestion automatique */
short Ks_Analyse; /* Vaut 0 si l'affaire est termine pour les estimations, */
                  /* dans ce cas aucune ecriture n'est faite en sortie, 0 */
                  /* autrement */

/*--------------------------------*/
/* Fonctions du fichier perimetre */
/*--------------------------------*/

int n_InitRupture	 (T_RUPTURE_VAR  *pbd_Rupture);
int n_TestRupture1 (char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_TestRupture2 (char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionPremiereRupture1(char *ptsz_LigneCour[]);
int n_ActionLigneRupture (char *ptsz_LigneCour[]);


/*---------------------------------------------------------------*/
/* Fonctions de la synchronisation entre le perimetre et TCTRULT */
/*---------------------------------------------------------------*/

int n_InitSyncTCTRULT 		(T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ActionLigneSyncTCTRULT	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSyncTCTRULT	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ActionPereSansFilsTCTRULT(char **ptsz_LigneMaitre);


/*----------------------------------------------------------*/
/* Fonctions de la synchronisation entre le perimetre et GT */
/*----------------------------------------------------------*/

int n_InitSyncGT 		(T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ActionLigneSyncGT		(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSyncGT		(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);


/*---------------------------------------------------------------*/
/* Fonctions de la synchronisation entre le perimetre et TCTREST */
/*---------------------------------------------------------------*/

int n_InitSyncTCTREST 		(T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ActionLigneSyncTCTREST	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSyncTCTREST	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);


/*---------------------------------------------------------------*/
/* Fonctions de la synchronisation entre le perimetre et FCTRGRO */
/*---------------------------------------------------------------*/

int n_InitSyncCTRGRO 		(T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ActionLigneSyncCTRGRO	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSyncCTRGRO	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);


/**************************************************************************/
/*** Objet : Synchronisation entre le fichier perimetre XADPERICASE,  ***/
/***         FCTRULT, GT, FCTRGRO et FCTREST (actuariat)			***/
/***									***/
/*** Nom : main		     						***/
/***									***/
/*** Parametres:							***/
/***	i argc : nombre de parametres					***/
/***	i argv : tableau de pointeurs sur les parametres		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int main(
   int argc,
   char *argv[]
)
{
   pbd_Rupture = malloc(sizeof(T_RUPTURE_VAR));
   pbd_SyncTCTRULT = malloc(sizeof(T_RUPTURE_SYNC_VAR));
   pbd_SyncGT = malloc(sizeof(T_RUPTURE_SYNC_VAR));
   pbd_SyncTCTREST = malloc(sizeof(T_RUPTURE_SYNC_VAR));
   pbd_SyncCTRGRO = malloc(sizeof(T_RUPTURE_SYNC_VAR));

/* Initialisation des signaux */
   InitSig();

   if (n_BeginPgm(argc, argv) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");
   }

/* Recuperation du parametre correspondant au type de segment */
   Kc_SEGTYP_CT=*(psz_GetCharArgv(1));

   if (Kc_SEGTYP_CT == 'A') {
/* Recuperation du parametre correspondant au type d'inventaire */
      Kc_INVTYP=*(psz_GetCharArgv(2));

/* Recuperation du parametre correspondant au libelle d'inventaire */
      strcpy(Ksz_CLODAT_D, psz_GetCharArgv(3));
   }

/* Initialisation du tableau de pointeur sur le fichier de sortie */
   Ktsz_Sortie[7] = Ksz_Pai_M;

/* Ouverture du fichier de sortie */
   if (n_OpenFileAppl("ESTC0603_O1", "wt", &Kp_OutputFileCASEXTRAV) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
   }

/* Ouverture du fichier de sortie */
   if (n_OpenFileAppl("ESTC0603_O2", "wt", &Kp_OutputFilePERICASE) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
   }

/* Initialisation de la structure de rupture */
   if (n_InitRupture(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupture");
   }

/* Initialisation de la structure de synchronisation avec FCTRULT */
   if (n_InitSyncTCTRULT(pbd_SyncTCTRULT) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_InitSyncTCTRULT");
   }

/* Initialisation de la structure de synchronisation du GT */
   if (n_InitSyncGT(pbd_SyncGT) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_InitSyncGT");
   }

/* Initialisation de la structure de synchronisation avec FCTREST */
   if (Kc_SEGTYP_CT == 'A') {
      if (n_InitSyncTCTREST(pbd_SyncTCTREST) == ERR) {
         ExitPgm(ERR_XX, "Erreur appel fonction n_InitSyncTCTREST");
      }
   }

/* Initialisation de la structure de synchronisation avec CTRGRO */
   if (n_InitSyncCTRGRO(pbd_SyncCTRGRO) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_InitSyncCTRGRO");
   }

/* Lancement du traitement du fichier maitre */
   if (n_ProcessingRuptureVar(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
   }

   if (n_CloseFileAppl("ESTC0603_I1", &(pbd_Rupture->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC0603_I2", &(pbd_SyncTCTRULT->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC0603_I3", &(pbd_SyncGT->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC0603_I4", &(pbd_SyncCTRGRO->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (Kc_SEGTYP_CT == 'A') {
      if (n_CloseFileAppl("ESTC0603_I5", &(pbd_SyncTCTREST->pf_InputFil)) == ERR) {
         ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
      }
   }

   if (n_CloseFileAppl("ESTC0603_O1", &Kp_OutputFileCASEXTRAV) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC0603_O2", &Kp_OutputFilePERICASE) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_EndPgm() == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_EndPgm");
   }

   free(pbd_Rupture);
   free(pbd_SyncTCTRULT);
   free(pbd_SyncGT);
   free(pbd_SyncTCTREST);
   free(pbd_SyncCTRGRO);
   exit(OK);
}


/**************************************************************************/
/*** Objet : initialisation de la structure de rupture			***/
/***									***/
/*** Nom : n_InitRupture     						***/
/***									***/
/*** Parametres:							***/
/***	i pbd_Rupture : pointeur sur la structure de rupture		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_InitRupture(
   T_RUPTURE_VAR *pbd_Rupture
)
{
   DEBUT_FCT("n_InitRupture");
   memset(pbd_Rupture, 0, sizeof(T_RUPTURE_VAR));

/* Ouverture du fichier perimetre */
   if (n_OpenFileAppl("ESTC0603_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_Rupture->n_NbRupture=2;
   pbd_Rupture->n_ConditionRupture[0]=n_TestRupture1;
   pbd_Rupture->n_ConditionRupture[1]=n_TestRupture2;
   pbd_Rupture->n_ActionFirst[0]=n_ActionPremiereRupture1;
   pbd_Rupture->n_ActionLigne=n_ActionLigneRupture;
   pbd_Rupture->c_Separ= '~';

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : Initialisation de la synchronisation du perimetre avec	***/
/***         FCTRULT	                                                ***/
/***									***/
/*** Nom : n_InitSyncTCTRULT  						***/
/***									***/
/*** Parametres:							***/
/***	i pbd_SyncTCTRULT : pointeur sur la structure de synchro	***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_InitSyncTCTRULT(
   T_RUPTURE_SYNC_VAR  *pbd_SyncTCTRULT
)
{
   DEBUT_FCT("n_InitSyncTCTRULT");
   memset(pbd_SyncTCTRULT, 0, sizeof(T_RUPTURE_SYNC_VAR));

/* Ouverture du fichier TCTRULT */
   if (n_OpenFileAppl("ESTC0603_I2", "rt", &(pbd_SyncTCTRULT->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_SyncTCTRULT->ConditionEndSync=n_ConditionSyncTCTRULT;
   pbd_SyncTCTRULT->n_ActionLigne=n_ActionLigneSyncTCTRULT;
   pbd_SyncTCTRULT->n_PereSansFils=n_ActionPereSansFilsTCTRULT;
   pbd_SyncTCTRULT->c_Separ='~';

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : Initialisation de la synchronisation du perimetre avec	***/
/***         le GT	                                                ***/
/***									***/
/*** Nom : n_InitSyncGT     						***/
/***									***/
/*** Parametres:							***/
/***	i pbd_SyncGT : pointeur sur la structure de synchro		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_InitSyncGT(
   T_RUPTURE_SYNC_VAR  *pbd_SyncGT
)
{
   DEBUT_FCT("n_InitSyncGT");
   memset(pbd_SyncGT, 0, sizeof(T_RUPTURE_SYNC_VAR));

/* Ouverture du fichier GT */
   if (n_OpenFileAppl("ESTC0603_I3", "rt", &(pbd_SyncGT->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_SyncGT->ConditionEndSync=n_ConditionSyncGT;
   pbd_SyncGT->n_ActionLigne=n_ActionLigneSyncGT;
   pbd_SyncGT->c_Separ='~';

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : Initialisation de la synchronisation du perimetre avec	***/
/***         FCTRGRO	                                                ***/
/***									***/
/*** Nom : n_InitSyncCTRGRO  						***/
/***									***/
/*** Parametres:							***/
/***	i pbd_SyncCTRGRO : pointeur sur la structure de synchro	***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_InitSyncCTRGRO(
   T_RUPTURE_SYNC_VAR  *pbd_SyncCTRGRO
)
{
   DEBUT_FCT("n_InitSyncCTRGRO");
   memset(pbd_SyncCTRGRO, 0, sizeof(T_RUPTURE_SYNC_VAR));

/* Ouverture du fichier FCTRGRO */
   if (n_OpenFileAppl("ESTC0603_I4", "rt", &(pbd_SyncCTRGRO->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_SyncCTRGRO->ConditionEndSync=n_ConditionSyncCTRGRO;
   pbd_SyncCTRGRO->n_ActionLigne=n_ActionLigneSyncCTRGRO;
   pbd_SyncCTRGRO->c_Separ='~';

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : Initialisation de la synchronisation du perimetre avec	***/
/***         FCTREST	                                                ***/
/***									***/
/*** Nom : n_InitSyncTCTREST  						***/
/***									***/
/*** Parametres:							***/
/***	i pbd_SyncTCTREST : pointeur sur la structure de synchro	***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_InitSyncTCTREST(
   T_RUPTURE_SYNC_VAR  *pbd_SyncTCTREST
)
{
   DEBUT_FCT("n_InitSyncTCTREST");
   memset(pbd_SyncTCTREST, 0, sizeof(T_RUPTURE_SYNC_VAR));

/* Ouverture du fichier TCTREST */
   if (n_OpenFileAppl("ESTC0603_I5", "rt", &(pbd_SyncTCTREST->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_SyncTCTREST->ConditionEndSync=n_ConditionSyncTCTREST;
   pbd_SyncTCTREST->n_ActionLigne=n_ActionLigneSyncTCTREST;
   pbd_SyncTCTREST->c_Separ='~';

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction de test de rupture				***/
/***									***/
/*** Nom : n_TestRupture1     						***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LineSuiv : pointeur sur la ligne suivante,		***/
/***	i ptsz_LineCour : pointeur sur la ligne precedente.		***/
/***									***/
/*** Retour:								***/
/***	0 si pas de rupture,						***/
/***	1 si rupture.							***/
/**************************************************************************/

int n_TestRupture1(
   char *ptsz_LigneSuiv[],
   char *ptsz_LigneCour[]
)
{
   static short s_Ret;

   if ((s_Ret=strcmp(ptsz_LigneSuiv[PER_CTR_NF], ptsz_LigneCour[PER_CTR_NF]))) {
      return s_Ret;
   }
   if ((s_Ret=strcmp(ptsz_LigneSuiv[PER_END_NT], ptsz_LigneCour[PER_END_NT]))) {
      return s_Ret;
   }
   return (strcmp(ptsz_LigneSuiv[PER_SEC_NF], ptsz_LigneCour[PER_SEC_NF]));
}


/**************************************************************************/
/*** Objet : fonction de test de rupture				***/
/***									***/
/*** Nom : n_TestRupture2     						***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LineSuiv : pointeur sur la ligne suivante,		***/
/***	i ptsz_LineCour : pointeur sur la ligne precedente.		***/
/***									***/
/*** Retour:								***/
/***	0 si pas de rupture,						***/
/***	1 si rupture.							***/
/**************************************************************************/

int n_TestRupture2(
   char *ptsz_LigneSuiv[],
   char *ptsz_LigneCour[]
)
{
   static int n_Ret;

   if ((n_Ret=strcmp(ptsz_LigneSuiv[PER_CTR_NF], ptsz_LigneCour[PER_CTR_NF]))) {
      return n_Ret;
   }
   if ((n_Ret=strcmp(ptsz_LigneSuiv[PER_END_NT], ptsz_LigneCour[PER_END_NT]))) {
      return n_Ret;
   }
   if ((n_Ret=strcmp(ptsz_LigneSuiv[PER_SEC_NF], ptsz_LigneCour[PER_SEC_NF]))) {
      return n_Ret;
   }
   if ((n_Ret=strcmp(ptsz_LigneSuiv[PER_UWY_NF], ptsz_LigneCour[PER_UWY_NF]))) {
      return n_Ret;
   }
   return (strcmp(ptsz_LigneSuiv[PER_UW_NT], ptsz_LigneCour[PER_UW_NT]));
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne en rupture premiere du 	***/
/***         fichier maitre						***/
/***									***/
/*** Nom : n_ActionPremiereRupture1					***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneCour : pointeur sur la ligne courante		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionPremiereRupture1(char *ptsz_LigneCour[])
{
   DEBUT_FCT("n_ActionPremiereRupture1");

/* Synchronisation avec le fichier FCTRGRO pour recuperer le segment */
      Ktsz_Sortie[8] = Ksz_ChaineVide;
      n_ProcessingRuptureSyncVar(pbd_SyncCTRGRO, ptsz_LigneCour);

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du fichier maitre	***/
/***									***/
/*** Nom : n_ActionLigneRupture						***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneCour : pointeur sur la ligne courante		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionLigneRupture(char *ptsz_LigneCour[])
{
  static double d_Part;
  static double d_Pai;

  static double d_Sai;
  static char sz_Sai_CT[2], sz_Sai_M[25];

  DEBUT_FCT("n_ActionLigneRupture");

  /* On ne prend pas les traites prop. en controle des estimations */
  /* ni les affaires de type 1 (ACCADMTYP_CT = 1) terminees pour les */
  /* estimations (ESTEND_B = 1) en actuariat */

  if (*ptsz_LigneCour[PER_CTRNAT_CT] != 'P') {

    /* CASEEST et CASEACT ont des structures identiques au moins sur les 7 premiers éléments */
    Ktsz_Sortie[CASEEST_CTR_NF] = ptsz_LigneCour[PER_CTR_NF];
    Ktsz_Sortie[CASEEST_END_NT] = ptsz_LigneCour[PER_END_NT];
    Ktsz_Sortie[CASEEST_SEC_NF] = ptsz_LigneCour[PER_SEC_NF];
    Ktsz_Sortie[CASEEST_UWY_NF] = ptsz_LigneCour[PER_UWY_NF];
    Ktsz_Sortie[CASEEST_UW_NT] = ptsz_LigneCour[PER_UW_NT];
    Ktsz_Sortie[CASEEST_EGPCUR_CF] = ptsz_LigneCour[PER_EGPCUR_CF];
    Ktsz_Sortie[CASEEST_CTRNAT_CT] = ptsz_LigneCour[PER_CTRNAT_CT];

    /* Initialisation si les synchros ne marchent pas, sauf avec FCTRULT */
    if (Kc_SEGTYP_CT == 'E') {
      Ktsz_Sortie[CASEEST_Scii_M] = Ksz_NombreNul;
      Ktsz_Sortie[CASEEST_Scci_M] = Ksz_NombreNul;
      Ktsz_Sortie[CASEEST_PAi_M] = Ksz_NombreNul;
      Ktsz_Sortie[CASEEST_CALAMTCLM_M] = Ksz_NombreNul;
      Ktsz_Sortie[20] = NULL;
    }
    else {
      Ktsz_Sortie[CASEACT_Scii_M] = Ksz_NombreNul;
      Ktsz_Sortie[CASEACT_Scci_M] = Ksz_NombreNul;
      Ktsz_Sortie[CASEACT_PAi_M] = Ksz_NombreNul;
      Ktsz_Sortie[CASEACT_Sccai_M] = Ksz_NombreNul;
      Ktsz_Sortie[CASEACT_Sai_M] = Ksz_NombreNul;
      Ktsz_Sortie[CASEACT_Sai_CT] = Ksz_ModeGestionManuel;
      Ktsz_Sortie[CASEACT_PAai_M] = Ksz_NombreNul;
      Ktsz_Sortie[CASEACT_ENTAMT_M] = Ksz_NombreNul;
      Ktsz_Sortie[19] = NULL;
    }

    /* Calcul de Pai */
    if (*ptsz_LigneCour[PER_CTRNAT_CT] == 'N') {
      if (*ptsz_LigneCour[PER_LIARIDSHA_B] == '0') {
	d_Part = atof(ptsz_LigneCour[PER_RIDSHA_R])*atof(ptsz_LigneCour[PER_CUTSHA_R]);
      }
      else {
	d_Part = atof(ptsz_LigneCour[PER_CUTSHA_R]);
      }
      if (d_Part == 0) {
	sprintf (Ksz_MessageErr, "CTR %s, END %s, SEC %s, UWY %s, UW %s : RIDSHA_R=0 or CUTSHA_R=0",
		 ptsz_LigneCour[PER_CTR_NF],
		 ptsz_LigneCour[PER_END_NT],
		 ptsz_LigneCour[PER_SEC_NF],
		 ptsz_LigneCour[PER_UWY_NF],
		 ptsz_LigneCour[PER_UW_NT]
		 );
	n_WriteAno(Ksz_MessageErr);
	d_Pai = 0;
      }
      else {
	d_Pai = atof(ptsz_LigneCour[PER_CLMACT_M])*d_Part;
      }
    }
    else {
      d_Pai = 0;
    }
    sprintf(Ksz_Pai_M, "%-.3lf", d_Pai);

    /* Synchronisation avec le fichier GT pour chaque ligne */
    Kd_PAi=0;
    n_ProcessingRuptureSyncVar(pbd_SyncGT, ptsz_LigneCour);

    /* Synchronisation avec le fichier TCTRULT pour chaque ligne */
    n_ProcessingRuptureSyncVar(pbd_SyncTCTRULT, ptsz_LigneCour);

    /* En  actuariat : synchronisation avec le fichier TCTREST pour chaque ligne */
    if ( (Kc_SEGTYP_CT == 'A') && (Kd_Psi) ) {

      n_ProcessingRuptureSyncVar(pbd_SyncTCTREST, ptsz_LigneCour);
      sprintf(Ksz_PAai_M, "%-.3lf", (Kd_PAi/Kd_Psi)*d_Pai);
      Ktsz_Sortie[CASEACT_PAai_M] = Ksz_PAai_M;
    }

    /* En controle des estimations : PAi = Pai (non prop.) ; PAI = Psi (facs) */
    else  if ( (Kc_SEGTYP_CT == 'E') ) {
      if (*ptsz_LigneCour[PER_CTRNAT_CT] == 'N') {
	Ktsz_Sortie[CASEEST_PAi_M] = Ksz_Pai_M;
      }
      else {
	Ktsz_Sortie[CASEEST_PAi_M] = Ksz_Psi_M;
      }
    }

    /*Montagnac*/
    /* ADMMODCLM_CT (Sai_CT) forcé à "F" et Sai_M forcé à Sccai + Scci */
    /* pour les type 1 comptes complets (ACCADMTYP_CT à 1 et ADMMODPRM_CT à "A" */
    if ( (Kc_SEGTYP_CT == 'A') && (atoi(ptsz_LigneCour[PER_ACCADMTYP_CT]) == 1) && (*ptsz_LigneCour[PER_ADMMODPRM_CT] == 'A')) {
      sprintf(sz_Sai_CT, "%c", 'F');Ktsz_Sortie[CASEACT_Sai_CT] = sz_Sai_CT;
      d_Sai = atof(Ktsz_Sortie[CASEACT_Sccai_M]) + atof(Ktsz_Sortie[CASEACT_Scci_M]);
      sprintf(sz_Sai_M, "%-.3lf", d_Sai);Ktsz_Sortie[CASEACT_Sai_M] = sz_Sai_M;
    }

    /* Ecriture de la ligne dans le fichier de travail */
    n_WriteCols(Kp_OutputFileCASEXTRAV, Ktsz_Sortie, '~', 0);

    /* Ecriture de la ligne dans le fichier perimetre */
    /* Ajout du numero de segment a la place du type de segmentation */
    ptsz_LigneCour[PER_SEG_NF] = Ktsz_Sortie[8];
    n_WriteCols(Kp_OutputFilePERICASE, ptsz_LigneCour, '~', 0);
  }

  RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : synchronisation perimetre et TCTRULT			***/
/***									***/
/*** Nom : n_ConditionSyncTCTRULT					***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre		***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave	***/
/***									***/
/*** Retour:								***/
/***	0 si synchronise,						***/
/***	<0 si la ligne esclave est depassee,				***/
/***    >0 si la ligne esclave n'est pas depassee.			***/
/**************************************************************************/

int n_ConditionSyncTCTRULT(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   static short ret;

   if ((ret = strcmp(ptsz_LigneMaitre[PER_CTR_NF], ptsz_LigneEsclave[ULT_CTR_NF]))) {
      return ret;
   }
   if ((ret = strcmp(ptsz_LigneMaitre[PER_END_NT], ptsz_LigneEsclave[ULT_END_NT]))) {
      return ret;
   }
   if ((ret = strcmp(ptsz_LigneMaitre[PER_SEC_NF], ptsz_LigneEsclave[ULT_SEC_NF]))) {
      return ret;
   }
   if ((ret = strcmp(ptsz_LigneMaitre[PER_UWY_NF], ptsz_LigneEsclave[ULT_UWY_NF]))) {
      return ret;
   }
   return (strcmp(ptsz_LigneMaitre[PER_UW_NT], ptsz_LigneEsclave[ULT_UW_NT]));
}


/**************************************************************************/
/*** Objet : synchronisation perimetre et GT				***/
/***									***/
/*** Nom : n_ConditionSyncGT						***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre		***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave	***/
/***									***/
/*** Retour:								***/
/***	0 si synchronise,						***/
/***	<0 si la ligne esclave est depassee,				***/
/***    >0 si la ligne esclave n'est pas depassee.			***/
/**************************************************************************/

int n_ConditionSyncGT(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   static short ret;

   if ((ret = strcmp(ptsz_LigneMaitre[PER_CTR_NF], ptsz_LigneEsclave[GTESTCUMUL2_CTR_NF]))) {
      return ret;
   }
   if ((ret = strcmp(ptsz_LigneMaitre[PER_END_NT], ptsz_LigneEsclave[GTESTCUMUL2_END_NT]))) {
      return ret;
   }
   if ((ret = strcmp(ptsz_LigneMaitre[PER_SEC_NF], ptsz_LigneEsclave[GTESTCUMUL2_SEC_NF]))) {
      return ret;
   }
   if ((ret = strcmp(ptsz_LigneMaitre[PER_UWY_NF], ptsz_LigneEsclave[GTESTCUMUL2_UWY_NF]))) {
      return ret;
   }
   return (strcmp(ptsz_LigneMaitre[PER_UW_NT], ptsz_LigneEsclave[GTESTCUMUL2_UW_NT]));
}


/**************************************************************************/
/*** Objet : synchronisation perimetre et TCTREST			***/
/***									***/
/*** Nom : n_ConditionSyncTCTREST					***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre		***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave	***/
/***									***/
/*** Retour:								***/
/***	0 si synchronise,						***/
/***	<0 si la ligne esclave est depassee,				***/
/***    >0 si la ligne esclave n'est pas depassee.			***/
/**************************************************************************/

int n_ConditionSyncTCTREST(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   static short ret;

   if ((ret = strcmp(ptsz_LigneMaitre[PER_CTR_NF], ptsz_LigneEsclave[EST_CTR_NF]))) {
      return ret;
   }
   if ((ret = strcmp(ptsz_LigneMaitre[PER_END_NT], ptsz_LigneEsclave[EST_END_NT]))) {
      return ret;
   }
   if ((ret = strcmp(ptsz_LigneMaitre[PER_SEC_NF], ptsz_LigneEsclave[EST_SEC_NF]))) {
      return ret;
   }
   if ((ret = strcmp(ptsz_LigneMaitre[PER_UWY_NF], ptsz_LigneEsclave[EST_UWY_NF]))) {
      return ret;
   }
   return (strcmp(ptsz_LigneMaitre[PER_UW_NT], ptsz_LigneEsclave[EST_UW_NT]));
}


/**************************************************************************/
/*** Objet : synchronisation perimetre et FCTRGRO			***/
/***									***/
/*** Nom : n_ConditionSyncCTRGRO					***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre		***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave	***/
/***									***/
/*** Retour:								***/
/***	0 si synchronise,						***/
/***	<0 si la ligne esclave est depassee,				***/
/***    >0 si la ligne esclave n'est pas depassee.			***/
/**************************************************************************/

int n_ConditionSyncCTRGRO(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   static short ret;

   if ((ret = strcmp(ptsz_LigneMaitre[PER_CTR_NF], ptsz_LigneEsclave[CTRGRO_CTR_NF]))) {
      return ret;
   }
   if ((ret = strcmp(ptsz_LigneMaitre[PER_END_NT], ptsz_LigneEsclave[CTRGRO_END_NT]))) {
      return ret;
   }
   return (strcmp(ptsz_LigneMaitre[PER_SEC_NF], ptsz_LigneEsclave[CTRGRO_SEC_NF]));
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du fichier TCTRULT	***/
/***									***/
/*** Nom : n_ActionLigneSyncTCTRULT					***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre,		***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave.       ***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionLigneSyncTCTRULT(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   DEBUT_FCT("n_ActionLigneSyncTCTRULT");

   strcpy(Ksz_Psi_M, ptsz_LigneEsclave[ULT_RETAMTPRM_M]);
   strcpy(Ksz_Ssi_M, ptsz_LigneEsclave[ULT_RETAMTCLM_M]);
   Ktsz_Sortie[12] = Ksz_Psi_M;
   Ktsz_Sortie[13] = Ksz_Ssi_M;
   Kd_Psi=atof(Ksz_Psi_M);
   if (Kc_SEGTYP_CT == 'E') {
      strcpy(Ksz_Ssi_CT, ptsz_LigneEsclave[ULT_ADMMODCLM_CT]);
      strcpy(Ksz_CALAMTPRM_M, ptsz_LigneEsclave[ULT_CALAMTPRM_M]);
      strcpy(Ksz_ENTAMTPRM_M, ptsz_LigneEsclave[ULT_ENTAMTPRM_M]);
      strcpy(Ksz_ADMMODPRM_CT, ptsz_LigneEsclave[ULT_ADMMODPRM_CT]);
      strcpy(Ksz_CALAMTCLM_M, ptsz_LigneEsclave[ULT_CALAMTCLM_M]);
      strcpy(Ksz_ENTAMTCLM_M, ptsz_LigneEsclave[ULT_ENTAMTCLM_M]);
      Ktsz_Sortie[14] = Ksz_Ssi_CT;
      Ktsz_Sortie[15] = Ksz_CALAMTPRM_M;
      Ktsz_Sortie[16] = Ksz_ENTAMTPRM_M;
      Ktsz_Sortie[17] = Ksz_ADMMODPRM_CT;
      Ktsz_Sortie[18] = Ksz_CALAMTCLM_M;
      Ktsz_Sortie[19] = Ksz_ENTAMTCLM_M;
   }

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du fichier GT		***/
/***									***/
/*** Nom : n_ActionLigneSyncGT						***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre,		***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave.       ***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionLigneSyncGT(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   DEBUT_FCT("n_ActionLigneSyncGT");

   if (atoi(ptsz_LigneEsclave[GTESTCUMUL2_ACMTRS_NT]) == 20000) {
      strcpy(Ksz_Scii_M, ptsz_LigneEsclave[GTESTCUMUL2_ACMAMT_M]);
      Ktsz_Sortie[9] = Ksz_Scii_M;
   }
   else if (atoi(ptsz_LigneEsclave[GTESTCUMUL2_ACMTRS_NT]) == -20000) {
      strcpy(Ksz_Scci_M, ptsz_LigneEsclave[GTESTCUMUL2_ACMAMT_M]);
      Ktsz_Sortie[10] = Ksz_Scci_M;
   }
   else if (atoi(ptsz_LigneEsclave[GTESTCUMUL2_ACMTRS_NT]) == -20030) {
      strcpy(Ksz_Sccai_M, ptsz_LigneEsclave[GTESTCUMUL2_ACMAMT_M]);
      Ktsz_Sortie[18] = Ksz_Sccai_M;
   }

/* Uniquement en actuariat */
   else if ( (atoi(ptsz_LigneEsclave[GTESTCUMUL2_ACMTRS_NT]) == 1002) && (Kc_SEGTYP_CT == 'A') ) {
      strcpy(Ksz_PAi_M, ptsz_LigneEsclave[GTESTCUMUL2_ACMAMT_M]);
      Ktsz_Sortie[11]=Ksz_PAi_M;
      Kd_PAi=atof(Ksz_PAi_M);
   }

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du fichier TCTREST	***/
/***									***/
/*** Nom : n_ActionLigneSyncTCTREST					***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre,		***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave.       ***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionLigneSyncTCTREST(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
  DEBUT_FCT("n_ActionLigneSyncTCTREST");

  if ( (atoi(ptsz_LigneEsclave[EST_PRS_CF]) == 710) && (atoi(ptsz_LigneEsclave[EST_ACMTRS_NT]) == 20000) ) {
    strcpy(Ksz_Sai_M, ptsz_LigneEsclave[EST_RETAMT_M]);
    strcpy(Ksz_CALAMTPRM_M, ptsz_LigneEsclave[EST_ENTAMT_M]);
    Ktsz_Sortie[14] = Ksz_Sai_M;
    Ktsz_Sortie[17] = Ksz_CALAMTPRM_M;

    /* Par defaut mode a 'A' */
    strcpy(Ksz_Sai_CT, "A");
    Ktsz_Sortie[15] = Ksz_Sai_CT;

    /* En inventaire principal, le mode est a force si le champ est a force */
    /* et si le libelle d'inventaire vaut le champ libelle d'inventaire */

    if ( (Kc_INVTYP == 'P') && (strcmp(Ksz_CLODAT_D, ptsz_LigneEsclave[EST_CLODAT_D]) == 0) && (*ptsz_LigneEsclave[EST_ADMMOD_CT] == 'F') ) {
      strcpy(Ksz_Sai_CT, "F");
    }
  }

  RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction lancee quand aucune ligne du fichier TCTRULT ne 	***/
/***         correspond a la ligne courante du fichier maitre           ***/
/***									***/
/*** Nom : n_ActionPereSansFilsTCTRULT					***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionPereSansFilsTCTRULT(char *ptsz_LigneMaitre[])
{
   DEBUT_FCT("n_ActionPereSansFilsTCTRULT");

/* On prend des montants nul pour ne pas planter plus loin */
   Ktsz_Sortie[12] = Ksz_NombreNul;
   Ktsz_Sortie[13] = Ksz_NombreNul;
   Kd_Psi=0.0;
   if (Kc_SEGTYP_CT == 'E') {
      Ktsz_Sortie[14] = Ksz_NombreNul;
      Ktsz_Sortie[15] = Ksz_NombreNul;
      Ktsz_Sortie[16] = Ksz_NombreNul;
      Ktsz_Sortie[17] = Ksz_NombreNul;
      Ktsz_Sortie[18] = Ksz_NombreNul;
      Ktsz_Sortie[19] = Ksz_NombreNul;
   }

   sprintf (Ksz_MessageErr, "CTR %s, END %s, SEC %s, UWY %s,  UW %s : not in FCTRULT file",
            ptsz_LigneMaitre[PER_CTR_NF],
            ptsz_LigneMaitre[PER_END_NT],
            ptsz_LigneMaitre[PER_SEC_NF],
            ptsz_LigneMaitre[PER_UWY_NF],
            ptsz_LigneMaitre[PER_UW_NT]
   );
   n_WriteAno(Ksz_MessageErr);

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du fichier FCTRGRO	***/
/***									***/
/*** Nom : n_ActionLigneSyncCTRGRO					***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre,		***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave.       ***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionLigneSyncCTRGRO(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   DEBUT_FCT("n_ActionLigneSyncCTRGRO");

   strcpy(Ksz_SEG_NF, ptsz_LigneEsclave[CTRGRO_SEG_NF]);
   Ktsz_Sortie[8] = Ksz_SEG_NF;

   RETURN_VAL(OK);
}
