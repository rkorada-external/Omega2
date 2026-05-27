/*==============================================================================
Nom de l'application          : Generation d un fichier au format de BEST..TCTRGRO
Nom du source                 : ESTC0112.c
Revision                      : $Revision: 1.2 $
Date de creation              : 28/08/1998
Auteur                        : M.NAJI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
    En entree : - Fichier venant de BSAR..TCTRGRO (fils)
                - Fichier venant du perimetre SADPERICAS0 (maitre) contenant des infos supplementaires

    En Sortie : - Fichier au format de BEST..TCTRGRO

------------------------------------------------------------------------------
Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
	   ...           ...            ...              ...
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <util.h>
#include "struct.h"

/*-----------------------------------------------------------*/
/* definition de la position des champs du fichier en entree */
/*-----------------------------------------------------------*/
#define CTRGRO2_SSD_CF           0
#define CTRGRO2_SEGTYP_CT        1
#define CTRGRO2_CTR_NF           2
#define CTRGRO2_END_NT           3
#define CTRGRO2_SEC_NF           4
#define CTRGRO2_SEG_NF           5
#define CTRGRO2_VRS_NF           6

#define SPER_CTR_NF             0
#define SPER_END_NT             1
#define SPER_SEC_NF             2
#define SPER_CED_NF             3
#define SPER_CTRNAT_CF          4
#define SPER_CTRRET_B           5
#define SPER_DIV_NT             6
#define SPER_EXP_D              7
#define SPER_INC_D              8
#define SPER_LOB_CF             9
#define SPER_NAT_CF             10
#define SPER_PCPRSKTRY_CF       11
#define SPER_SEGTYP_CT          12
#define SPER_SOB_CF             13
#define SPER_SSD_CF             14
#define SPER_SUBNAT_CF          15
#define SPER_TOP_CF             16
#define SPER_UWGRP_CF           17

/*----------------------*/
/* Variables de travail */
/*----------------------*/

FILE 		     	*Kp_OutputBestTctrgro;

T_RUPTURE_VAR 		bd_RuptPERIM;
T_RUPTURE_SYNC_VAR 	bd_CTRGRO;



/*-----------------------------*/
/* Fonctions du fichier maitre */
/*-----------------------------*/

int n_InitRupture	(T_RUPTURE_VAR  *pbd_RuptPERIM);
int n_ActionLigne 	(char *ptsz_LigneCour[]);
int n_IsR1PERIM         ( char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionF1PERIM     (char *ptsz_LigneCour[]);
int n_ActionL1PERIM     (char *ptsz_LigneCour[]);


/*--------------------------------------------------------------*/
/* Fonctions de la synchronisation entre le maitre et l'esclave */
/*--------------------------------------------------------------*/

int n_InitSync		(T_RUPTURE_SYNC_VAR  *pbd_Sync);
int n_ActionLigneSync	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSync	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ActionFilsSansPere(char **ptsz_LigneFils);
int n_ActionPereSansFils(char **ptsz_LigneMaitre);


/**************************************************************************/
/*** Objet : Generation d un fichier au format de BEST..TCTRGRO         ***/
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
/*   T_RUPTURE_VAR 		bd_RuptPERIM; */

/* Initialisation des signaux */
   InitSig();

   if (n_BeginPgm(argc, argv) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");
   }


/* Ouverture du fichier de sortie GT */
   if (n_OpenFileAppl("ESTC0112_O1", "wt", &Kp_OutputBestTctrgro) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenBestTctrgro");
   }

/* Initialisation de la structure de rupture */
   if (n_InitRupture(&bd_RuptPERIM ) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupture");
   }

/* Initialisation de la structure de synchronisation du GTA avec le perimetre */
   if (n_InitSync(&bd_CTRGRO) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_InitSyncGTA");
   }


/* Lancement du traitement du fichier maitre */
   if (n_ProcessingRuptureVar(&bd_RuptPERIM) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
   }

   if (n_CloseFileAppl("ESTC0112_I1", &(bd_RuptPERIM.pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC0112_I2", &(bd_CTRGRO.pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }


   if (n_CloseFileAppl("ESTC0112_O1", &Kp_OutputBestTctrgro) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileBestTctrgro");
   }

   if (n_EndPgm() == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_EndPgm");
   }


   exit(OK);
}


/**************************************************************************/
/*** Objet : initialisation de la structure de rupture avec le fichier	***/
/***   	     IADVPERICASE						***/
/***									***/
/*** Nom : n_InitRupture     						***/
/***									***/
/*** Parametres:							***/
/***	i pbd_RuptPERIM: pointeur sur la structure de rupture		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_InitRupture(
   T_RUPTURE_VAR *pbd_RuptPERIM
)
{
   DEBUT_FCT("n_InitRupture");
   memset(pbd_RuptPERIM, 0, sizeof(T_RUPTURE_VAR));

   /* Ouverture du fichier maitre */

   if (n_OpenFileAppl("ESTC0112_I1", "rt", &(pbd_RuptPERIM->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_RuptPERIM->n_NbRupture=1;
   pbd_RuptPERIM->n_ConditionRupture[0]= n_IsR1PERIM;
   pbd_RuptPERIM->n_ActionFirst[0]     = n_ActionF1PERIM;
   pbd_RuptPERIM->c_Separ		= '~';

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : initialisation de la synchronisation du maitre avec	***/
/***         l'esclave IADVPERICASE                                     ***/
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

int n_InitSync(T_RUPTURE_SYNC_VAR  *pbd_Sync)
{
   DEBUT_FCT("n_InitSync");
   memset(pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR));

/* Ouverture du fichier esclave */
   if (n_OpenFileAppl("ESTC0112_I2", "rt", &(pbd_Sync->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }


   pbd_Sync->ConditionEndSync	=n_ConditionSync;
   pbd_Sync->n_ActionLigne	=n_ActionLigneSync;
   pbd_Sync->n_FilsSansPere	=n_ActionFilsSansPere;
   pbd_Sync->c_Separ='~';

   RETURN_VAL(OK);
}

/**************************************************************************/
/*** Objet : fonction de test de rupture***/
/******/
/*** Nom : n_IsR1PERIM                                                  ***/
/******/
/*** Parametres:                                                        ***/
/***    i ptsz_LineSuiv : pointeur sur la ligne suivante,               ***/
/***    i ptsz_LineCour : pointeur sur la ligne precedente.             ***/
/***                                                                    ***/
/*** Retour:                                                            ***/
/***    0 si pas de rupture,                                            ***/
/***    1 si rupture.                                                   ***/
/**************************************************************************/

int n_IsR1PERIM(
   char *ptsz_LigneSuiv[],
   char *ptsz_LigneCour[]
)
{
   static short s_ret;

   DEBUT_FCT("n_TestRupture");

   if ((s_ret = strcmp(ptsz_LigneSuiv[SPER_SSD_CF], ptsz_LigneCour[SPER_SSD_CF]))) {
      return s_ret;
   }
   if ((s_ret = strcmp(ptsz_LigneSuiv[SPER_SEGTYP_CT], ptsz_LigneCour[SPER_SEGTYP_CT]))) {
      return s_ret;
   }
   if ((s_ret = strcmp(ptsz_LigneSuiv[SPER_CTR_NF], ptsz_LigneCour[SPER_CTR_NF]))) {
      return s_ret;
   }
   if ((s_ret = strcmp(ptsz_LigneSuiv[SPER_END_NT], ptsz_LigneCour[SPER_END_NT]))) {
      return s_ret;
   }
   RETURN_VAL(strcmp(ptsz_LigneSuiv[SPER_SEC_NF],   ptsz_LigneCour[SPER_SEC_NF]));
}

/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du fichier maitre***/
/******/
/*** Nom : n_ActionLigneRupture***/
/******/
/*** Parametres:***/
/***    i ptsz_LigneCour : pointeur sur la ligne courante***/
/******/
/*** Retour:***/
/***    OK si pas d'erreur,                                             ***/
/***    ERR si erreur.                                                  ***/
/**************************************************************************/

int n_ActionF1PERIM(char *ptsz_LigneCour[])
{
   DEBUT_FCT("n_ActionLigneRupture");

/* Synchronisation avec CTRGRO */

   n_ProcessingRuptureSyncVar(&bd_CTRGRO, ptsz_LigneCour);

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


   if ((s_ret = strcmp(ptsz_LigneMaitre[SPER_SSD_CF], ptsz_LigneEsclave[CTRGRO2_SSD_CF]))) {
      RETURN_VAL(s_ret);
   }
   if ((s_ret = strcmp(ptsz_LigneMaitre[SPER_SEGTYP_CT], ptsz_LigneEsclave[CTRGRO2_SEGTYP_CT]))) {
      RETURN_VAL(s_ret);
   }
   if ((s_ret = strcmp(ptsz_LigneMaitre[SPER_CTR_NF], ptsz_LigneEsclave[CTRGRO2_CTR_NF]))) {
      RETURN_VAL(s_ret);
   }
   if ((s_ret = strcmp(ptsz_LigneMaitre[SPER_END_NT], ptsz_LigneEsclave[CTRGRO2_END_NT]))) {
      RETURN_VAL(s_ret);
   }
   RETURN_VAL (strcmp(ptsz_LigneMaitre[SPER_SEC_NF], ptsz_LigneEsclave[CTRGRO2_SEC_NF]));

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

/* On prepare un fichier au format de BEST..TCTRGRO ( le 20 champ est la date par defaut, lors du bcp) */

     fprintf(Kp_OutputBestTctrgro, "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~\n",
                   ptsz_LigneEsclave[CTRGRO2_CTR_NF],
                   ptsz_LigneEsclave[CTRGRO2_END_NT],
                   ptsz_LigneEsclave[CTRGRO2_SEC_NF],
                   ptsz_LigneEsclave[CTRGRO2_VRS_NF],
                   ptsz_LigneEsclave[CTRGRO2_SSD_CF],
                   ptsz_LigneEsclave[CTRGRO2_SEGTYP_CT],
                   ptsz_LigneEsclave[CTRGRO2_SEG_NF],
                   ptsz_LigneMaitre[SPER_DIV_NT],
                   ptsz_LigneMaitre[SPER_CED_NF],
                   ptsz_LigneMaitre[SPER_UWGRP_CF],
                   ptsz_LigneMaitre[SPER_LOB_CF],
                   ptsz_LigneMaitre[SPER_SOB_CF],
                   ptsz_LigneMaitre[SPER_TOP_CF],
                   ptsz_LigneMaitre[SPER_NAT_CF],
                   ptsz_LigneMaitre[SPER_SUBNAT_CF],
                   ptsz_LigneMaitre[SPER_PCPRSKTRY_CF],
                   ptsz_LigneMaitre[SPER_INC_D],
                   ptsz_LigneMaitre[SPER_EXP_D],
                   ptsz_LigneMaitre[SPER_CTRRET_B]      ) ;


   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction lancee quand aucune ligne du fichier ne 		***/
/***         correspond a la ligne courante du fichier maitre           ***/
/***									***/
/*** Nom : n_ActionPereSansFils						***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionFilsSansPere(char *ptsz_Ligne[])
{
   DEBUT_FCT("int n_ActionFilsSansPere");

/* On prepare un fichier au format de BEST..TCTRGRO ( le 19 champ est 0 par defaut) */
     fprintf(Kp_OutputBestTctrgro, "%s~%s~%s~%s~%s~%s~%s~~~~~~~~~~~~0~\n",
                  ptsz_Ligne[CTRGRO2_CTR_NF],
                  ptsz_Ligne[CTRGRO2_END_NT],
                  ptsz_Ligne[CTRGRO2_SEC_NF],
                  ptsz_Ligne[CTRGRO2_VRS_NF],
                  ptsz_Ligne[CTRGRO2_SSD_CF],
                  ptsz_Ligne[CTRGRO2_SEGTYP_CT],
                  ptsz_Ligne[CTRGRO2_SEG_NF]     ) ;


   RETURN_VAL(OK);
}

