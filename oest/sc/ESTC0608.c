/*==============================================================================
Nom de l'application          : Cumul des sinistralites comptabilisees par
                                segment/exercice/exercice de souscription
Nom du source                 : ESTC0608.c
Revision                      : $Revision: 1.2 $
Date de creation              : 23/06/1997
Auteur                        : CGI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
   A partir du fichier FGT2, on cumule les montants de sinistralite
   comptabilisee des affaires d'un segment/exercice/exercice de survenance.
   En sortie, on ajoute un champ dans FLABOCY.
------------------------------------------------------------------------------
Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
	   ...           ...            ...              ...
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
T_RUPTURE_VAR 	   *pbd_Rupture;  /* Pointeur sur la structure de la rupture */
T_RUPTURE_SYNC_VAR *pbd_SyncLABOCY; /* Pointeur sur la structure de */
                                   /* synchronisation avec le fichier FLABOCY */
char **Kptsz_LABOCY; /* Pointeur de l'esclave pour utilisation dans le maitre */
short Ks_Analyse; /* Vaut 1 si le segment/exercice/exercice de survenance est */
                  /* analyse, 0 autrement */
double Kd_Sc;     /* Cumul de la sinistralite comptabilisee */
char Ksz_MessageErr[256]; /* Message d'erreur */


/*-----------------------------*/
/* Fonctions du fichier maitre */
/*-----------------------------*/

int n_InitRupture		(T_RUPTURE_VAR  *pbd_Rupture);
int n_TestRupture	 	(char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionPremiereRupture	(char *ptsz_LigneCour[]);
int n_ActionLigneRupture 	(char *ptsz_LigneCour[]);
int n_ActionDerniereRupture	(char *ptsz_LigneCour[]);


/*------------------------------------------------------------*/
/* Fonctions de la synchronisation entre le maitre et FLABOCY */
/*------------------------------------------------------------*/

int n_InitSyncLABOCY 		(T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ConditionSyncLABOCY	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ActionLigneSyncLABOCY	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ActionPereSansFilsLABOCY(char **ptsz_LigneMaitre);


/**************************************************************************/
/*** Objet : Synchronisation entre le fichier FGT et FLABOCY		***/
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
   pbd_SyncLABOCY = malloc(sizeof(T_RUPTURE_SYNC_VAR));

/* Initialisation des signaux */
   InitSig();

   if (n_BeginPgm(argc, argv) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");
   }

/* Ouverture du fichier de sortie */
   if (n_OpenFileAppl("ESTC0608_O1", "wt", &Kp_OutputFile) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
   }

/* Initialisation de la structure de rupture */
   if (n_InitRupture(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupture");
   }

/* Initialisation de la structure de synchronisation LABOCY */
   if (n_InitSyncLABOCY(pbd_SyncLABOCY) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_InitSyncLABOCY");
   }

/* Lancement du traitement du fichier maitre */
   if (n_ProcessingRuptureVar(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
   }

   if (n_CloseFileAppl("ESTC0608_I1", &(pbd_Rupture->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileApplGT");
   }

   if (n_CloseFileAppl("ESTC0608_I2", &(pbd_SyncLABOCY->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileApplLABOCY");
   }

   if (n_CloseFileAppl("ESTC0608_O1", &Kp_OutputFile) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_EndPgm() == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_EndPgm");
   }

   free(pbd_Rupture);
   free(pbd_SyncLABOCY);
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
   if (n_OpenFileAppl("ESTC0608_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_Rupture->n_NbRupture=1;
   pbd_Rupture->n_ConditionRupture[0]=n_TestRupture;
   pbd_Rupture->n_ActionFirst[0]=n_ActionPremiereRupture;
   pbd_Rupture->n_ActionLigne=n_ActionLigneRupture;
   pbd_Rupture->n_ActionLast[0]=n_ActionDerniereRupture;
   pbd_Rupture->c_Separ= '~';

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : Initialisation de la synchronisation du perimetre avec	***/
/***         FLABOCY	                                                ***/
/***									***/
/*** Nom : n_InitSyncLABOCY     					***/
/***									***/
/*** Parametres:							***/
/***	i pbd_SyncLABOCY : pointeur sur la structure de synchro		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_InitSyncLABOCY(
   T_RUPTURE_SYNC_VAR  *pbd_SyncLABOCY
)
{
   DEBUT_FCT("n_InitSyncLABOCY");
   memset(pbd_SyncLABOCY, 0, sizeof(T_RUPTURE_SYNC_VAR));

/* Ouverture du fichier LABOCY */
   if (n_OpenFileAppl("ESTC0608_I2", "rt", &(pbd_SyncLABOCY->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_SyncLABOCY->ConditionEndSync=n_ConditionSyncLABOCY;
   pbd_SyncLABOCY->n_ActionLigne=n_ActionLigneSyncLABOCY;
   pbd_SyncLABOCY->n_PereSansFils=n_ActionPereSansFilsLABOCY;
   pbd_SyncLABOCY->c_Separ='~';

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

int n_TestRupture(
   char *ptsz_LigneSuiv[],
   char *ptsz_LigneCour[]
)
{
   static int n_Ret;

   if ((n_Ret = strcmp(ptsz_LigneSuiv[GTESTCUMUL1_SEG_NF], ptsz_LigneCour[GTESTCUMUL1_SEG_NF]))) {
      return n_Ret;
   }
   if ((n_Ret = strcmp(ptsz_LigneSuiv[GTESTCUMUL1_UWY_NF], ptsz_LigneCour[GTESTCUMUL1_UWY_NF]))) {
      return n_Ret;
   }
   return (strcmp(ptsz_LigneSuiv[GTESTCUMUL1_OCCYEA_NF], ptsz_LigneCour[GTESTCUMUL1_OCCYEA_NF]));
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

int n_ActionPremiereRupture(char *ptsz_LigneCour[])
{
   DEBUT_FCT("n_ActionPremiereRupture");

   Kd_Sc = 0;

/* Synchronisation avec le fichier FLABOCY pour chaque ligne */
/* permet de recuperer les affaires du segment/exercice,     */
/* et de pas traiter les segments sans exercices de survenance */
      n_ProcessingRuptureSyncVar(pbd_SyncLABOCY, ptsz_LigneCour);

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

   if (Ks_Analyse == 1) {
      if ( (atoi(ptsz_LigneCour[GTESTCUMUL1_ACMTRS_NT]) == 20000) || (atoi(ptsz_LigneCour[GTESTCUMUL1_ACMTRS_NT]) == -20000) || (atoi(ptsz_LigneCour[GTESTCUMUL1_ACMTRS_NT]) == -20030) ) {
         Kd_Sc = Kd_Sc + atof(ptsz_LigneCour[GTESTCUMUL1_ACMAMT_M]);
      }
   }

   RETURN_VAL(OK);
}

/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne en rupture derniere du 	***/
/***         fichier maitre						***/
/***									***/
/*** Nom : n_ActionDerniereRupture					***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneCour : pointeur sur la ligne courante		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionDerniereRupture(char *ptsz_LigneCour[])
{
   DEBUT_FCT("n_ActionDerniereRupture");

   if (Ks_Analyse == 1) {

/* Ecriture de la ligne */
         fprintf(Kp_OutputFile, "%s~%s~%s~%s~%-.3lf\n",
                 Kptsz_LABOCY[LABOCY_SEG_NF],
                 Kptsz_LABOCY[LABOCY_UWY_NF],
                 Kptsz_LABOCY[LABOCY_OCCYEA_NF],
                 Kptsz_LABOCY[LABOCY_SPIRAT_R],
                 Kd_Sc
         );
   }

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : synchronisation maitre et LABOCY				***/
/***									***/
/*** Nom : n_ConditionSyncLABOCY					***/
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

int n_ConditionSyncLABOCY(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   static short ret;

   if ((ret = strcmp(ptsz_LigneMaitre[GTESTCUMUL1_SEG_NF], ptsz_LigneEsclave[LABOCY_SEG_NF]))) {
      return ret;
   }
   if ((ret = strcmp(ptsz_LigneMaitre[GTESTCUMUL1_UWY_NF], ptsz_LigneEsclave[LABOCY_UWY_NF]))) {
      return ret;
   }
   return (strcmp(ptsz_LigneMaitre[GTESTCUMUL1_OCCYEA_NF], ptsz_LigneEsclave[LABOCY_OCCYEA_NF]));
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du fichier FLABOCY	***/
/***									***/
/*** Nom : n_ActionLigneSyncLABOCY					***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre,		***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave.       ***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionLigneSyncLABOCY(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   DEBUT_FCT("n_ActionLigneSyncLABOCY");

   Ks_Analyse = 1;
   Kptsz_LABOCY = ptsz_LigneEsclave;

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction lancee quand aucune ligne du fichier FLABOCY ne 	***/
/***         correspond a la ligne courante du fichier maitre           ***/
/***									***/
/*** Nom : n_ActionPereSansFilsLABOCY						***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionPereSansFilsLABOCY(char *ptsz_LigneMaitre[])
{
   DEBUT_FCT("n_ActionPereSansFilsLABOCY");

   Ks_Analyse = 0;

   RETURN_VAL(OK);
}
