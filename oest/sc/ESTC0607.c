/*==============================================================================
Nom de l'application          : Ajout du segment dans le fichier SADPERIFR a la
                                place du champ, SEGTYP_CT
Nom du source                 : ESTC0607.c
Revision                      : $Revision: 1.2 $
Date de creation              : 19/09/1997
Auteur                        : CGI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
   Au fichier SADPERIFR est ajoute le numero de segment a la place du champ
   SEGTYP_CT par synchronisation âvec le fichier FCTRGRO.
   La devise par synchronisation avec FCTRULT a la place de la filiale SSD_CF
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

FILE 		   *Kp_OutputFile; /* Pointeur sur le fichier de sortie */
T_RUPTURE_VAR  	   *pbd_Rupture;   /* Pointeur sur la structure de la rupture */
T_RUPTURE_SYNC_VAR *pbd_SyncCTRGRO; /* Pointeur sur la structure de */
T_RUPTURE_SYNC_VAR *pbd_SyncCTRULT; /* Pointeur sur la structure de */
                                    /* synchronisation maitre FCTRULT */
char Ksz_SEG_NF[11],	/* Numero de segment */
     Ksz_CUR_CF[4];	/* Monnaie de l'affaire */


/*--------------------------------*/
/* Fonctions du fichier SADPERIFR */
/*--------------------------------*/

int n_InitRupture	 (T_RUPTURE_VAR  *pbd_Rupture);
int n_TestRupture0 (char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_TestRupture1 (char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionPremiereRupture0(char *ptsz_LigneCour[]);
int n_ActionPremiereRupture1(char *ptsz_LigneCour[]);
int n_ActionLigneRupture (char *ptsz_LigneCour[]);


/*------------------------------------------------------------*/
/* Fonctions de la synchronisation entre SADPERIFR et FCTRGRO */
/*------------------------------------------------------------*/

int n_InitSyncCTRGRO 		(T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ActionLigneSyncCTRGRO	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSyncCTRGRO	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);

/*------------------------------------------------------------*/
/* Fonctions de la synchronisation entre SADPERIFR et FCTRULT */
/*------------------------------------------------------------*/

int n_InitSyncCTRULT 		(T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ActionLigneSyncCTRULT	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSyncCTRULT	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);


/**************************************************************************/
/*** Objet : Synchronisation entre le fichier perimetre SADPERIFR,  	***/
/***         et FCTRGRO							***/
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
   pbd_SyncCTRGRO = malloc(sizeof(T_RUPTURE_SYNC_VAR));
   pbd_SyncCTRULT = malloc(sizeof(T_RUPTURE_SYNC_VAR));

/* Initialisation des signaux */
   InitSig();

   if (n_BeginPgm(argc, argv) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");
   }

/* Ouverture du fichier de sortie */
   if (n_OpenFileAppl("ESTC0607_O1", "wt", &Kp_OutputFile) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
   }

/* Initialisation de la structure de rupture */
   if (n_InitRupture(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupture");
   }

/* Initialisation de la structure de synchronisation avec CTRGRO */
   if (n_InitSyncCTRGRO(pbd_SyncCTRGRO) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_InitSyncCTRGRO");
   }

/* Initialisation de la structure de synchronisation avec CTRULT */
   if (n_InitSyncCTRULT(pbd_SyncCTRULT) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_InitSyncCTRULT");
   }

/* Lancement du traitement du fichier maitre */
   if (n_ProcessingRuptureVar(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
   }

   if (n_CloseFileAppl("ESTC0607_I1", &(pbd_Rupture->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC0607_I2", &(pbd_SyncCTRGRO->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC0607_I3", &(pbd_SyncCTRULT->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC0607_O1", &Kp_OutputFile) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_EndPgm() == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_EndPgm");
   }

   free(pbd_Rupture);
   free(pbd_SyncCTRGRO);
   free(pbd_SyncCTRULT);
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
   if (n_OpenFileAppl("ESTC0607_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_Rupture->n_NbRupture=2;
   pbd_Rupture->n_ConditionRupture[0]=n_TestRupture0;
   pbd_Rupture->n_ConditionRupture[1]=n_TestRupture1;
   pbd_Rupture->n_ActionFirst[0]=n_ActionPremiereRupture0;
   pbd_Rupture->n_ActionFirst[1]=n_ActionPremiereRupture1;
   pbd_Rupture->n_ActionLigne=n_ActionLigneRupture;
   pbd_Rupture->c_Separ= '~';

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : Initialisation de la synchronisation de SADPERIFR avec	***/
/***         FCTRGRO	                                                ***/
/***									***/
/*** Nom : n_InitSyncCTRGRO  						***/
/***									***/
/*** Parametres:							***/
/***	i pbd_SyncCTRGRO : pointeur sur la structure de synchro		***/
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
   if (n_OpenFileAppl("ESTC0607_I2", "rt", &(pbd_SyncCTRGRO->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_SyncCTRGRO->ConditionEndSync=n_ConditionSyncCTRGRO;
   pbd_SyncCTRGRO->n_ActionLigne=n_ActionLigneSyncCTRGRO;
   pbd_SyncCTRGRO->c_Separ='~';

   RETURN_VAL(OK);
}

/**************************************************************************/
/*** Objet : Initialisation de la synchronisation de SADPERIFR avec	***/
/***         FCTRULT */
/***									***/
/*** Nom : n_InitSyncCTRULT  						***/
/***									***/
/*** Parametres:							***/
/***	i pbd_SyncCTRULT : pointeur sur la structure de synchro	***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/
int n_InitSyncCTRULT(
   T_RUPTURE_SYNC_VAR  *pbd_SyncCTRULT
)
{
   DEBUT_FCT("n_InitSyncCTRULT");
   memset(pbd_SyncCTRULT, 0, sizeof(T_RUPTURE_SYNC_VAR));

/* Ouverture du fichier FCTRULT */
   if (n_OpenFileAppl("ESTC0607_I3", "rt", &(pbd_SyncCTRULT->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_SyncCTRULT->ConditionEndSync=n_ConditionSyncCTRULT;
   pbd_SyncCTRULT->n_ActionLigne=n_ActionLigneSyncCTRULT;
   pbd_SyncCTRULT->c_Separ='~';

   RETURN_VAL(OK);
}



/**************************************************************************/
/*** Objet : fonction de test de rupture				***/
/***									***/
/*** Nom : n_TestRupture     						***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LineSuiv : pointeur sur la ligne suivante,		***/
/***	i ptsz_LineCour : pointeur sur la ligne precedente.		***/
/***									***/
/*** Retour:								***/
/***	0 si pas de rupture,						***/
/***	1 si rupture.							***/
/**************************************************************************/

int n_TestRupture0(
   char *ptsz_LigneSuiv[],
   char *ptsz_LigneCour[]
)
{
   static short s_Ret;

   if ((s_Ret=strcmp(ptsz_LigneSuiv[PERFR_CTR_NF], ptsz_LigneCour[PERFR_CTR_NF]))) {
      return s_Ret;
   }
   if ((s_Ret=strcmp(ptsz_LigneSuiv[PERFR_END_NT], ptsz_LigneCour[PERFR_END_NT]))) {
      return s_Ret;
   }
   return (strcmp(ptsz_LigneSuiv[PERFR_SEC_NF], ptsz_LigneCour[PERFR_SEC_NF]));
}

/**************************************************************************/
/*** Objet : fonction de test de rupture				***/
/***									***/
/*** Nom : n_TestRupture     						***/
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

   if ((s_Ret=strcmp(ptsz_LigneSuiv[PERFR_CTR_NF], ptsz_LigneCour[PERFR_CTR_NF]))) {
      return s_Ret;
   }
   if ((s_Ret=strcmp(ptsz_LigneSuiv[PERFR_END_NT], ptsz_LigneCour[PERFR_END_NT]))) {
      return s_Ret;
   }
   if ((s_Ret=strcmp(ptsz_LigneSuiv[PERFR_SEC_NF], ptsz_LigneCour[PERFR_SEC_NF]))) {
      return s_Ret;
   }
   if ((s_Ret=strcmp(ptsz_LigneSuiv[PERFR_UWY_NF], ptsz_LigneCour[PERFR_UWY_NF]))) {
      return s_Ret;
   }
   return (strcmp(ptsz_LigneSuiv[PERFR_UW_NT], ptsz_LigneCour[PERFR_UW_NT]));
}



/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne en rupture premiere du 	***/
/***         fichier maitre						***/
/***									***/
/*** Nom : n_ActionPremiereRupture					***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneCour : pointeur sur la ligne courante		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionPremiereRupture0(char *ptsz_LigneCour[])
{
   DEBUT_FCT("n_ActionPremiereRupture");

/* Synchronisation avec le fichier FCTRGRO pour recuperer le segment */
      n_ProcessingRuptureSyncVar(pbd_SyncCTRGRO, ptsz_LigneCour);

   RETURN_VAL(OK);
}

/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne en rupture premiere du 	***/
/***         fichier maitre						***/
/***									***/
/*** Nom : n_ActionPremiereRupture					***/
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
   DEBUT_FCT("n_ActionPremiereRupture");

/* Synchronisation avec le fichier FCTRULT pour recuperer la monnaie */
      n_ProcessingRuptureSyncVar(pbd_SyncCTRULT, ptsz_LigneCour);

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
   DEBUT_FCT("n_ActionLigneRupture");

/* Ecriture de la ligne */
   ptsz_LigneCour[PERFR_SEGTYP_CT] = Ksz_SEG_NF;
   ptsz_LigneCour[PERFR_SSD_CF] = Ksz_CUR_CF;
   n_WriteCols(Kp_OutputFile, ptsz_LigneCour, '~', 0);

   RETURN_VAL(OK);
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

   if ((ret = strcmp(ptsz_LigneMaitre[PERFR_CTR_NF], ptsz_LigneEsclave[CTRGRO_CTR_NF]))) {
      return ret;
   }
   if ((ret = strcmp(ptsz_LigneMaitre[PERFR_END_NT], ptsz_LigneEsclave[CTRGRO_END_NT]))) {
      return ret;
   }
   return (strcmp(ptsz_LigneMaitre[PERFR_SEC_NF], ptsz_LigneEsclave[CTRGRO_SEC_NF]));
}


/**************************************************************************/
/*** Objet : synchronisation perimetre et FCTRULT			***/
/***									***/
/*** Nom : n_ConditionSyncCTRULT					***/
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

int n_ConditionSyncCTRULT(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   static short ret;

   if ((ret = strcmp(ptsz_LigneMaitre[PERFR_CTR_NF], ptsz_LigneEsclave[ULT_CTR_NF]))) {
      return ret;
   }
   if ((ret = strcmp(ptsz_LigneMaitre[PERFR_END_NT], ptsz_LigneEsclave[ULT_END_NT]))) {
      return ret;
   }
   if ((ret = strcmp(ptsz_LigneMaitre[PERFR_SEC_NF], ptsz_LigneEsclave[ULT_SEC_NF]))) {
      return ret;
   }
   if ((ret = strcmp(ptsz_LigneMaitre[PERFR_UWY_NF], ptsz_LigneEsclave[ULT_UWY_NF]))) {
      return ret;
   }
   return (strcmp(ptsz_LigneMaitre[PERFR_UW_NT], ptsz_LigneEsclave[ULT_UW_NT]));
}

/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du fichier FCTRULT	***/
/***									***/
/*** Nom : n_ActionLigneSyncCTRULT					***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre,		***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave.       ***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionLigneSyncCTRULT(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   DEBUT_FCT("n_ActionLigneSyncCTRULT");


   strcpy(Ksz_CUR_CF, ptsz_LigneEsclave[ULT_CUR_CF]);

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

   RETURN_VAL(OK);
}
