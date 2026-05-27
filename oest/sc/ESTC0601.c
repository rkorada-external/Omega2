/*==============================================================================
Nom de l'application          : Cumul de postes du GT et ajout du segment a
                                partir du fichier FCTRGRO
Nom du source                 : ESTC0601.c
Revision                      : $Revision: 1.2 $
Date de creation              : 23/06/1997
Auteur                        : CGI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
   Cumul des postes ACY_NT, SCOSTRMTH_NF, SCOENDMTH_NF du GT et ajout du
   numero de segment a partir du fichier FCTRGRO
   En entree : GT,
               FCTRGRO.
   En sortie : GT.
------------------------------------------------------------------------------
Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
	   ...           ...            ...              ...
	 [001]05/03/2015 F Maragnes :spot:28305  Ajout de deux nouvelles variables (Kd_sccrpcc et Kd_sccarpcc) dans le fichier résultat 
	 [002]12/05/2015 F Maragnes :spot:28305  Ajout de la variable Kd_scirpcc  dans le fichier résultat 
	 [003] 10/09/2018 add UWY_NF  spira 57605
	 [004]  18/02/2019 sauvegarde des infos du maitre pendant la première synchro avec FCTRGROc, car  elle ne se fait pas sur la clé 
	 [005] 13/03/2020 test des montant fabs( xxx)  >  1  au lieu xxx != 0  
[006] 24/06/2020 R. cassis :spira:84903 Le ZERO doit avoir la valeur 0 et pas 1 comme l'ancienne version
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <utctlib.h>
#include <stdarg.h>
#include "struct.h"
#define CTRGRO_UWY_NF 20 //dernier champs

//[006]
#define ZERO 0
/*----------------------*/
/* Variables de travail */
/*----------------------*/

FILE 		   *Kp_OutputFile; /* Pointeur sur le fichier de sortie */
T_RUPTURE_VAR  	   *pbd_Rupture;   /* Pointeur sur la structure de la rupture */
T_RUPTURE_SYNC_VAR *pbd_SyncCTRGRO; /* Pointeur sur la structure de */
                                    /* synchronisation maitre FCTRULT */
char Ksz_SEG_NF[11]; /* Chaine contenant le segment */
double Kd_Scii;      /* Cumul du champ ACMAMT_M pour le poste 20000 */
double Kd_Scci;      /* Cumul du champ ACMAMT_M pour le poste -20000 : SP complets pour les proportionnels */
double Kd_Sccai;      /* Cumul du champ ACMAMT_M pour le poste -20030 : SAP complets pour les proportionnels */
double Kd_PAi;       /* Cumul du champ ACMAMT_M pour le poste 01002 */
double Kd_sccrpcc   ; /* Cumul du champ ACMAMT_M pour le poste -20500 */
double  Kd_sccarpcc;  /* Cumul du champ ACMAMT_M pour le poste 20530 */
double  Kd_scirpcc;  /* Cumul du champ ACMAMT_M pour le poste 20500*/

//[004]
char CTRGRO_CTR_SYNC[10] ="";
char CTRGRO_END_SYNC[5]  ="";
char CTRGRO_SEC_SYNC[5]   ="";
char CTRGRO_UWY_SYNC[5] ="";

/*-----------------------------*/
/* Fonctions du fichier maitre */
/*-----------------------------*/

int n_InitRupture          (T_RUPTURE_VAR  *pbd_Rupture);
int n_TestRupture1	   (char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_TestRupture2	   (char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionPremiereRupture1(char *ptsz_LigneCour[]);
int n_ActionPremiereRupture2(char *ptsz_LigneCour[]);
int n_ActionLigneRupture   (char *ptsz_LigneCour[]);
int n_ActionDerniereRupture2(char *ptsz_LigneCour[]);


/*---------------------------------------------------------------*/
/* Fonctions de la synchronisation entre le perimetre et FCTRGRO */
/*---------------------------------------------------------------*/

int n_InitSyncCTRGRO 		(T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ActionLigneSyncCTRGRO	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSyncCTRGRO	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ActionPereSansFilsCTRGRO(char **ptsz_LigneMaitre);


/**************************************************************************/
/*** Objet : Cumul des postes ACY_NT, SCOSTRMTH_NF, SCOENDMTH_NF du GT	***/
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

/* Initialisation des signaux */
   InitSig();

   if (n_BeginPgm(argc, argv) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");
   }

/* Ouverture du fichier de sortie */
   if (n_OpenFileAppl("ESTC0601_O1", "wt", &Kp_OutputFile) == ERR) {
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

/* Lancement du traitement du fichier maitre */
   if (n_ProcessingRuptureVar(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
   }

   if (n_CloseFileAppl("ESTC0601_I1", &(pbd_Rupture->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC0601_I2", &(pbd_SyncCTRGRO->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC0601_O1", &Kp_OutputFile) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_EndPgm() == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_EndPgm");
   }

   free(pbd_Rupture);
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

/* Ouverture du fichier maitre */
   if (n_OpenFileAppl("ESTC0601_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_Rupture->n_NbRupture=2;
   pbd_Rupture->n_ConditionRupture[0]=n_TestRupture1;
   pbd_Rupture->n_ConditionRupture[1]=n_TestRupture2;
   pbd_Rupture->n_ActionFirst[0]=n_ActionPremiereRupture1;
   pbd_Rupture->n_ActionFirst[1]=n_ActionPremiereRupture2;
   pbd_Rupture->n_ActionLigne=n_ActionLigneRupture;
   pbd_Rupture->n_ActionLast[1]=n_ActionDerniereRupture2;
   pbd_Rupture->c_Separ= '~';

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
   if (n_OpenFileAppl("ESTC0601_I2", "rt", &(pbd_SyncCTRGRO->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_SyncCTRGRO->ConditionEndSync=n_ConditionSyncCTRGRO;
   pbd_SyncCTRGRO->n_ActionLigne=n_ActionLigneSyncCTRGRO;
   pbd_SyncCTRGRO->n_PereSansFils=n_ActionPereSansFilsCTRGRO;
   pbd_SyncCTRGRO->c_Separ='~';

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


   if ((s_Ret=strcmp(ptsz_LigneSuiv[GTE_CTR_NF], ptsz_LigneCour[GTE_CTR_NF]))) {
      return s_Ret;
   }
   if ((s_Ret=strcmp(ptsz_LigneSuiv[GTE_END_NT], ptsz_LigneCour[GTE_END_NT]))) {
      return s_Ret;
   }
   if ((s_Ret=strcmp(ptsz_LigneSuiv[GTE_UWY_NF], ptsz_LigneCour[GTE_UWY_NF]))) {
      return s_Ret;
   }
   return (strcmp(ptsz_LigneSuiv[GTE_SEC_NF], ptsz_LigneCour[GTE_SEC_NF]));
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
   static short s_Ret;

   if ((s_Ret=strcmp(ptsz_LigneSuiv[GTE_CTR_NF], ptsz_LigneCour[GTE_CTR_NF]))) {
      return s_Ret;
   }
   if ((s_Ret=strcmp(ptsz_LigneSuiv[GTE_END_NT], ptsz_LigneCour[GTE_END_NT]))) {
      return s_Ret;
   }
   if ((s_Ret=strcmp(ptsz_LigneSuiv[GTE_SEC_NF], ptsz_LigneCour[GTE_SEC_NF]))) {
      return s_Ret;
   }
   if ((s_Ret=strcmp(ptsz_LigneSuiv[GTE_UWY_NF], ptsz_LigneCour[GTE_UWY_NF]))) {
      return s_Ret;
   }
   if ((s_Ret=strcmp(ptsz_LigneSuiv[GTE_UW_NT], ptsz_LigneCour[GTE_UW_NT]))) {
      return s_Ret;
   }
   return (strcmp(ptsz_LigneSuiv[GTE_OCCYEA_NF], ptsz_LigneCour[GTE_OCCYEA_NF]));
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

int n_ActionPremiereRupture1(char *ptb_InRec[]) 
{
   DEBUT_FCT("n_ActionPremiereRupture1");


if (strcmp(CTRGRO_CTR_SYNC,ptb_InRec[GTE_CTR_NF]) == 0 &&
	strcmp(CTRGRO_END_SYNC,ptb_InRec[GTE_END_NT])== 0 &&
	strcmp(CTRGRO_SEC_SYNC,ptb_InRec[GTE_SEC_NF])== 0 &&
	(   *CTRGRO_UWY_SYNC == 0 || 
		*CTRGRO_UWY_SYNC == '0'  ||
		strcmp(CTRGRO_UWY_SYNC,ptb_InRec[GTE_UWY_NF])==0) ) // on garde le même segment car l'exrcice na pas changé ou  il est vide
	RETURN_VAL(OK);
else  /* Synchronisation avec le fichier TCTRGRO pour recuperer le segment */
{
      *Ksz_SEG_NF=0;
	  n_ProcessingRuptureSyncVar(pbd_SyncCTRGRO, ptb_InRec);
}
   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne en rupture premiere du 	***/
/***         fichier maitre						***/
/***									***/
/*** Nom : n_ActionPremiereRupture2					***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneCour : pointeur sur la ligne courante		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionPremiereRupture2(char *ptsz_LigneCour[])
{
   DEBUT_FCT("n_ActionPremiereRupture2");


   Kd_Scii = 0;
   Kd_Scci = 0;
   Kd_Sccai = 0;
   Kd_PAi = 0;
	 Kd_sccrpcc  =0 ; 
   Kd_sccarpcc=0;
   Kd_scirpcc =0;
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


   if (atoi(ptsz_LigneCour[GTE_ACMTRS_NT]) == 20000) {
      Kd_Scii = Kd_Scii + atof(ptsz_LigneCour[GTE_ACMAMT_M]);
   }
   else if (atoi(ptsz_LigneCour[GTE_ACMTRS_NT]) == -20000) {
      Kd_Scci = Kd_Scci + atof(ptsz_LigneCour[GTE_ACMAMT_M]);
   }
   else if (atoi(ptsz_LigneCour[GTE_ACMTRS_NT]) == -20030) {
      Kd_Sccai = Kd_Sccai + atof(ptsz_LigneCour[GTE_ACMAMT_M]);
   }
   else if (atoi(ptsz_LigneCour[GTE_ACMTRS_NT]) == 1002) {
      Kd_PAi = Kd_PAi + atof(ptsz_LigneCour[GTE_ACMAMT_M]);
   }
   else if (atoi(ptsz_LigneCour[GTE_ACMTRS_NT]) == -20500) {
      Kd_sccrpcc  = Kd_sccrpcc  + atof(ptsz_LigneCour[GTE_ACMAMT_M]);
   }else  if (atoi(ptsz_LigneCour[GTE_ACMTRS_NT]) == -20530) {
      Kd_sccarpcc = Kd_sccarpcc + atof(ptsz_LigneCour[GTE_ACMAMT_M]);
   }else  if (atoi(ptsz_LigneCour[GTE_ACMTRS_NT]) == 20500) {
      Kd_scirpcc  = Kd_scirpcc  + atof(ptsz_LigneCour[GTE_ACMAMT_M]);
   }   
   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne en rupture derniere du 	***/
/***         fichier maitre						***/
/***									***/
/*** Nom : n_ActionDerniereRupture2					***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneCour : pointeur sur la ligne courante		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionDerniereRupture2(char *ptsz_LigneCour[])
{
   DEBUT_FCT("n_ActionDerniereRupture2");
	
   //[005] if (Kd_Scii != 0) 
   if ( fabs(Kd_Scii) > ZERO ) {
      fprintf(Kp_OutputFile, "%s~%s~%s~%s~%s~%s~%d~%-.3lf~%s~%s\n",
              ptsz_LigneCour[GTE_CTR_NF],
              ptsz_LigneCour[GTE_END_NT],
              ptsz_LigneCour[GTE_SEC_NF],
              ptsz_LigneCour[GTE_UWY_NF],
              ptsz_LigneCour[GTE_UW_NT],
              ptsz_LigneCour[GTE_OCCYEA_NF],
              20000,
              Kd_Scii,
              ptsz_LigneCour[GTE_ACMCUR_CF],
              Ksz_SEG_NF
      );
   }
   //[005] if (Kd_Scci != 0) 
   if (fabs(Kd_Scci) > ZERO) {
      fprintf(Kp_OutputFile, "%s~%s~%s~%s~%s~%s~%d~%-.3lf~%s~%s\n",
              ptsz_LigneCour[GTE_CTR_NF],
              ptsz_LigneCour[GTE_END_NT],
              ptsz_LigneCour[GTE_SEC_NF],
              ptsz_LigneCour[GTE_UWY_NF],
              ptsz_LigneCour[GTE_UW_NT],
              ptsz_LigneCour[GTE_OCCYEA_NF],
              -20000,
              Kd_Scci,
              ptsz_LigneCour[GTE_ACMCUR_CF],
              Ksz_SEG_NF
      );
   }
  //[005] if (Kd_Sccai != 0) 
  if (fabs(Kd_Sccai ) > ZERO) {
      fprintf(Kp_OutputFile, "%s~%s~%s~%s~%s~%s~%d~%-.3lf~%s~%s\n",
              ptsz_LigneCour[GTE_CTR_NF],
              ptsz_LigneCour[GTE_END_NT],
              ptsz_LigneCour[GTE_SEC_NF],
              ptsz_LigneCour[GTE_UWY_NF],
              ptsz_LigneCour[GTE_UW_NT],
              ptsz_LigneCour[GTE_OCCYEA_NF],
              -20030,
              Kd_Sccai,
              ptsz_LigneCour[GTE_ACMCUR_CF],
              Ksz_SEG_NF
      );
   }
   //[005] if (Kd_PAi != 0) 
   if (fabs(Kd_PAi ) > ZERO) {
      fprintf(Kp_OutputFile, "%s~%s~%s~%s~%s~%s~%d~%-.3lf~%s~%s\n",
              ptsz_LigneCour[GTE_CTR_NF],
              ptsz_LigneCour[GTE_END_NT],
              ptsz_LigneCour[GTE_SEC_NF],
              ptsz_LigneCour[GTE_UWY_NF],
              ptsz_LigneCour[GTE_UW_NT],
              ptsz_LigneCour[GTE_OCCYEA_NF],
              1002,
              Kd_PAi,
              ptsz_LigneCour[GTE_ACMCUR_CF],
              Ksz_SEG_NF
      );
   }
   //[005] if (Kd_sccrpcc  != 0) 
   if (fabs(Kd_sccrpcc ) > ZERO){
   

      fprintf(Kp_OutputFile, "%s~%s~%s~%s~%s~%s~%d~%-.3lf~%s~%s\n",
              ptsz_LigneCour[GTE_CTR_NF],
              ptsz_LigneCour[GTE_END_NT],
              ptsz_LigneCour[GTE_SEC_NF],
              ptsz_LigneCour[GTE_UWY_NF],
              ptsz_LigneCour[GTE_UW_NT],
              ptsz_LigneCour[GTE_OCCYEA_NF],
              -20500,
              Kd_sccrpcc,
              ptsz_LigneCour[GTE_ACMCUR_CF],
              Ksz_SEG_NF 
      );
   }
   
   //[005] if (Kd_sccarpcc  != 0) 
   if (fabs(Kd_sccarpcc ) > ZERO){


      fprintf(Kp_OutputFile, "%s~%s~%s~%s~%s~%s~%d~%-.3lf~%s~%s\n",
              ptsz_LigneCour[GTE_CTR_NF],
              ptsz_LigneCour[GTE_END_NT],
              ptsz_LigneCour[GTE_SEC_NF],
              ptsz_LigneCour[GTE_UWY_NF],
              ptsz_LigneCour[GTE_UW_NT],
              ptsz_LigneCour[GTE_OCCYEA_NF],
              -20530,
              Kd_sccarpcc ,
              ptsz_LigneCour[GTE_ACMCUR_CF],
              Ksz_SEG_NF
      );
   }  
   
     //[005] if (Kd_scirpcc  != 0) 
	 if (fabs(Kd_scirpcc ) > ZERO) {


      fprintf(Kp_OutputFile, "%s~%s~%s~%s~%s~%s~%d~%-.3lf~%s~%s\n",
              ptsz_LigneCour[GTE_CTR_NF],
              ptsz_LigneCour[GTE_END_NT],
              ptsz_LigneCour[GTE_SEC_NF],
              ptsz_LigneCour[GTE_UWY_NF],
              ptsz_LigneCour[GTE_UW_NT],
              ptsz_LigneCour[GTE_OCCYEA_NF],
              20500,
              Kd_scirpcc ,
              ptsz_LigneCour[GTE_ACMCUR_CF],
              Ksz_SEG_NF
      );
   }  

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

	
   if ((ret = strcmp(ptsz_LigneMaitre[GTE_CTR_NF], ptsz_LigneEsclave[CTRGRO_CTR_NF]))) {
      return ret;
   }
   if ((ret = strcmp(ptsz_LigneMaitre[GTE_END_NT], ptsz_LigneEsclave[CTRGRO_END_NT]))) {
      return ret;
   }
   if ((ret = strcmp(ptsz_LigneMaitre[GTE_SEC_NF], ptsz_LigneEsclave[CTRGRO_SEC_NF]))) {
      return ret;
   }
   
   	// si l'exercice dans CTRGRO est vide ou égale 0 , on considère qu'il y a synchro pour n'importe quel exercice
	if (   *ptsz_LigneEsclave[CTRGRO_UWY_NF] == 0 || *ptsz_LigneEsclave[CTRGRO_UWY_NF] == '0' ) return 0 ;
	// sinon il faut que l'exercie synchronise 

   return (strcmp(ptsz_LigneMaitre[GTE_UWY_NF], ptsz_LigneEsclave[CTRGRO_UWY_NF]));
   
   
   
   
   
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
	
	strcpy(CTRGRO_CTR_SYNC,ptsz_LigneEsclave[CTRGRO_CTR_NF]);
	strcpy(CTRGRO_END_SYNC,ptsz_LigneEsclave[CTRGRO_END_NT]);
	strcpy(CTRGRO_SEC_SYNC,ptsz_LigneEsclave[CTRGRO_SEC_NF]);
	strcpy(CTRGRO_UWY_SYNC,ptsz_LigneEsclave[CTRGRO_UWY_NF]);
	
   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction lancee quand aucune ligne du fichier FCTRGRO ne 	***/
/***         correspond a la ligne courante du fichier maitre           ***/
/***									***/
/*** Nom : n_ActionPereSansFilsCTRGRO						***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionPereSansFilsCTRGRO(char *ptsz_LigneMaitre[])
{
   DEBUT_FCT("n_ActionPereSansFilsCTRGRO");


   RETURN_VAL(OK);
}
