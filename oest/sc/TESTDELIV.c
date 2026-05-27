/*==============================================================================
Nom de l'application          : Comparaison des perimetres inventaire et
                                segmentation (par le fichier de regroupement des
                                affaires)
Nom du source                 : ESTM1004.c
Revision                      : $Revision: 1.1.1.1 $
Date de creation              : 27/06/1997
Auteur                        : CGI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
  Comparaison des perimetre inventaire et segmentation.
  En sortie une liste des affaires du fichier des regroupement des affaires
  par segment absentes du perimetre d'inventaire est fourni ainsi qu'un
  nouveau fichier des regroupement des affaires supprimant ces affaires
  En entree : fichier perimetre inventaire IADPERICASE,
              fichier de regroupement des contrats FCTRGRO (memes lignes que le
              perimetre segmentation),
  En sortie : fichier de regroupement des affaire filtre FCTRGRO,
              fichier d'anomalies des affaires disparues.
------------------------------------------------------------------------------
Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
[002] 22/05/2012 Roger Cassis :spot:23802	Ajout sortie du fichier Pericase avec SEG_NF affecté
[003] 27/09/2012 Florent :spot:24041 sortir TOUTES LES LIGNES DU PÉRIMÈTRES !
[004] 10/09/2018 add UWY_NF  spira 57605 

==============================================================================*/

/*--------------------------------------------------*/

/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <stdarg.h>
#include "struct.h"

#define CTRGRO_UWY_NF 20 //dernier champs
/*----------------------*/
/* Variables de travail */
/*----------------------*/
FILE    *Kp_OutputFile1; /* Pointeur sur le fichier des regroupements des */
FILE	  *Kp_OutputFile2; /* Pointeur sur le fichier des anomalies en sortie */
FILE	  *Kp_OutputFile3; /* Pointeur sur le fichier des anomalies en sortie [002] */
                           /* contrats en sortie */
T_RUPTURE_VAR       *pbd_Rupture; /* Pointeur sur la structure de la rupture   */
T_RUPTURE_SYNC_VAR  *pbd_Sync; /* Pointeur sur la structure de synchronisation */

char   Ksz_MessageErr[256]; /* Message d'erreur                                 */
char gsz_seg_nf[11] = ""; // [003]

char CTRGRO_CTR_SYNC[10] ="";
char CTRGRO_END_SYNC[5]  ="";
char CTRGRO_SEC_SYNC[5]   ="";
char CTRGRO_UWY_SYNC[5] ="";

/*--------------------------------------------*/
/* Fonctions du fichier perimetre IADPERICASE */
/*--------------------------------------------*/

int n_InitRupture	 (T_RUPTURE_VAR  *pbd_Rupture);
int n_TestRupture	 (char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionPremiereRupture(char *ptsz_LigneCour[]);
int n_ActionLignePere( char **ptb_InRec);

/*-------------------------------------------------------------------------*/
/* Fonctions de la synchronisation entre le fichier IADPERICASE et FCTRGRO */
/*-------------------------------------------------------------------------*/
int n_InitSync(T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ActionLigneSync	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSync	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ActionFilsSansPere(char **ptsz_LigneEsclave);

/**************************************************************************/
/*** Objet : synchronisation entre le fichier maitre et esclave     ***/
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
   pbd_Rupture=malloc(sizeof(T_RUPTURE_VAR));
   pbd_Sync=malloc(sizeof(T_RUPTURE_SYNC_VAR));

/* Initialisation des signaux */
   InitSig();

   if (n_BeginPgm(argc, argv) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");
   }

/* Ouverture des fichiers de sortie */
   if (n_OpenFileAppl("ESTM1004_O1", "wt", &Kp_OutputFile1) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
   }

   if (n_OpenFileAppl("ESTM1004_O2", "wt", &Kp_OutputFile2) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
   }

   if (n_OpenFileAppl("ESTM1004_O3", "wt", &Kp_OutputFile3) == ERR) {   // [002]
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
   }

/* Initialisation de la structure de rupture */
   if (n_InitRupture(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupture");
   }

/* Initialisation de la structure de synchronisation */
   if (n_InitSync(pbd_Sync) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_InitSync");
   }

/* Lancement du traitement du fichier maitre */
   if (n_ProcessingRuptureVar(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
   }

   if (n_CloseFileAppl("ESTM1004_I1", &(pbd_Rupture->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM1004_I2", &(pbd_Sync->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM1004_O1", &Kp_OutputFile1) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM1004_O2", &Kp_OutputFile2) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM1004_O3", &Kp_OutputFile3) == ERR) {    // [002]
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_EndPgm() == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_EndPgm");
   }

   free(pbd_Rupture);
   free(pbd_Sync);

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
   if (n_OpenFileAppl("ESTM1004_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_Rupture->n_NbRupture=1;
   pbd_Rupture->n_ConditionRupture[0]=n_TestRupture;
   pbd_Rupture->n_ActionFirst[0]=n_ActionPremiereRupture;
	 pbd_Rupture->n_ActionLigne = n_ActionLignePere;
   pbd_Rupture->c_Separ= '~';

   RETURN_VAL(OK);
}

/**************************************************************************/
/*** Objet : initialisation de la synchronisation du maitre avec	***/
/***         l'esclave                                                  ***/
/***									***/
/*** Nom : n_InitSync     						***/
/***									***/
/*** Parametres:							***/
/***	i pbd_Sync : pointeur sur la structure de synchro		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/
int n_InitSync(
   T_RUPTURE_SYNC_VAR  *pbd_Sync
)
{
   DEBUT_FCT("n_InitSync");
   memset(pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR));

/* Ouverture du fichier esclave */
   if (n_OpenFileAppl("ESTM1004_I2", "rt", &(pbd_Sync->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_Sync->ConditionEndSync=n_ConditionSync;
   pbd_Sync->n_ActionLigne=n_ActionLigneSync;
   pbd_Sync->n_FilsSansPere=n_ActionFilsSansPere;
   pbd_Sync->c_Separ='~';

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
   static short s_ret;

   DEBUT_FCT("n_TestRupture");

   if ((s_ret = strcmp(ptsz_LigneSuiv[PER_CTR_NF], ptsz_LigneCour[PER_CTR_NF]))) {
      return s_ret;
	  
   }
   if ((s_ret = strcmp(ptsz_LigneSuiv[PER_END_NT], ptsz_LigneCour[PER_END_NT]))) {
      return s_ret;
   }
   if ((s_ret = strcmp(ptsz_LigneSuiv[PER_SEC_NF], ptsz_LigneCour[PER_SEC_NF]))) {
      return s_ret;
   }
   

   RETURN_VAL(strcmp(ptsz_LigneSuiv[PER_UWY_NF], ptsz_LigneCour[PER_UWY_NF]));
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

	//gsz_seg_nf[0] = 0; // [003]
	/* Synchronisation avec le fichier esclave à chaque rupture */
  n_ProcessingRuptureSyncVar(pbd_Sync, ptsz_LigneCour);

   RETURN_VAL(OK);
}

/**************************************************************************/
/*** Objet : synchronisation maitre esclave				***/
/***									***/
/*** Nom : n_ConditionSync						***/
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
int n_ConditionSync(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   static short s_ret;

   DEBUT_FCT("n_ConditionSync");

   if ((s_ret = strcmp(ptsz_LigneMaitre[PER_CTR_NF], ptsz_LigneEsclave[CTRGRO_CTR_NF]))) {
      return s_ret;
   }
   if ((s_ret = strcmp(ptsz_LigneMaitre[PER_END_NT], ptsz_LigneEsclave[CTRGRO_END_NT]))) {
      return s_ret;
   }
   if ((s_ret = strcmp(ptsz_LigneMaitre[PER_SEC_NF], ptsz_LigneEsclave[CTRGRO_SEC_NF]))) {
      return s_ret;
   }
  
  // si l'exercice dans CTRGRO est vide ou égale 0 , on considère qu'il y a synchro pour n'importe quel exercice
  if (   *ptsz_LigneEsclave[CTRGRO_UWY_NF] == 0 || *ptsz_LigneEsclave[CTRGRO_UWY_NF] == '0' ) return 0 ;
  // sinon il faut que l'exercie synchronise 

  RETURN_VAL(strcmp(ptsz_LigneMaitre[PER_UWY_NF], ptsz_LigneEsclave[CTRGRO_UWY_NF]));
}

/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne de l'esclave		***/
/***									***/
/*** Nom : n_ActionLigneSync						***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre,		***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave.       ***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/
int n_ActionLigneSync(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
	DEBUT_FCT("n_ActionLigneSync");

	/* Ecriture du fichier regroupement des contrats en sortie */
	n_WriteCols(Kp_OutputFile1, ptsz_LigneEsclave, '~', 0);

	strcpy(gsz_seg_nf,ptsz_LigneEsclave[CTRGRO_SEG_NF]);// [002] // [003]

	strcpy(CTRGRO_CTR_SYNC,ptsz_LigneEsclave[CTRGRO_CTR_NF]);
	strcpy(CTRGRO_END_SYNC,ptsz_LigneEsclave[CTRGRO_END_NT]);
	strcpy(CTRGRO_SEC_SYNC,ptsz_LigneEsclave[CTRGRO_SEC_NF]);
	strcpy(CTRGRO_UWY_SYNC,ptsz_LigneEsclave[CTRGRO_UWY_NF]);

	RETURN_VAL(OK);
}

/**************************************************************************/
/*** Objet : fonction lancee quand aucune ligne du fichier maitre ne 	***/
/***         correspond a la ligne courante du fichier esclave          ***/
/***									***/
/*** Nom : n_ActionFilsSansPere						***/
/***									***/
/*** Parametres:							***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave        ***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/
int n_ActionFilsSansPere(char *ptsz_LigneEsclave[])
{
   DEBUT_FCT("n_ActionFilsSansPere");

 	   fprintf(Kp_OutputFile2, "CTR %s, END %s, SEC %s  UWY %s not in IADPERICASE\n",
				ptsz_LigneEsclave[CTRGRO_CTR_NF],
				ptsz_LigneEsclave[CTRGRO_END_NT],
				ptsz_LigneEsclave[CTRGRO_SEC_NF],
				ptsz_LigneEsclave[CTRGRO_UWY_NF]
	   );

   RETURN_VAL(OK);
}

/*==============================================================================
 Objet :            Fonction lancee pour chaque ligne du Maitre
 Parametre(s) :     Pointeur sur la ligne courante
 Retour :           En cas de probleme retourne ERR
                    sinon retourne OK
// [003] création
==============================================================================*/
int n_ActionLignePere( char **ptb_InRec)
{
	ptb_InRec[PER_SEG_NF] ="";
	if (//gsz_seg_nf[0] != ' ' && gsz_seg_nf[0] != 0 && //si le segment n'est pas vide
			strcmp(CTRGRO_CTR_SYNC,ptb_InRec[PER_CTR_NF]) == 0 &&
			strcmp(CTRGRO_END_SYNC,ptb_InRec[PER_END_NT])== 0 &&
			strcmp(CTRGRO_SEC_SYNC,ptb_InRec[PER_SEC_NF])== 0 &&
			(   *CTRGRO_UWY_SYNC == 0 || 
				*CTRGRO_UWY_SYNC == '0'  ||
				strcmp(CTRGRO_UWY_SYNC,ptb_InRec[PER_UWY_NF])==0) )
		ptb_InRec[PER_SEG_NF] = gsz_seg_nf;
		
	n_WriteCols(Kp_OutputFile3, ptb_InRec, '~', 0 );
 	RETURN_VAL(OK);
}

