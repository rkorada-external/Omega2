/*==============================================================================
Nom de l'application          : Syncro du GT avec perimetre acceptation en vie
Nom du source                 : ESTM7620.c
Revision                      : $Revision: 1.2 $
Date de creation              : 03/09/2003
Auteur                        : J. Ribot
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
  Separation du GT acceptation en vie et non vie.
  En entree : le GT acceptation,
              le perimetre IADVPERICASE.
  En sortie : le GT vie
------------------------------------------------------------------------------
Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
[02}  20/11/2014 Florent :spot:27747 corrections des warnings
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

FILE 		   *Kp_OutputFileVie; /* Pointeur sur le GT vie en sortie */
FILE 		   *Kp_OutputFileGTA;

T_RUPTURE_VAR 		bd_Rupture;
T_RUPTURE_SYNC_VAR 	bd_SyncGTA;

/* char	Ksz_SSDs[100] ; */


/*-----------------------------*/
/* Fonctions du fichier maitre */
/*-----------------------------*/

int n_InitRupture	   (T_RUPTURE_VAR  *pbd_Rupture);
int n_ActionLigne (char *ptsz_LigneCour[]);


/*--------------------------------------------------------------*/
/* Fonctions de la synchronisation entre le maitre et l'esclave */
/*--------------------------------------------------------------*/

int n_InitSync(T_RUPTURE_SYNC_VAR  *pbd_Sync, char *sz_FicName);
int n_ActionLigneSync	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSync	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
/*int n_ActionFilsSansPere(char **ptsz_LigneMaitre);*/


/**************************************************************************/
/*** Objet : Separation du fichier GT en dommages et vie		***/
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
   T_RUPTURE_VAR 		bd_Rupture;

/* Initialisation des signaux */
   InitSig();

   if (n_BeginPgm(argc, argv) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");
   }

/*   strcpy(Ksz_SSDs,psz_GetCharArgv(1));  */

/* Ouverture du fichier de sortie dommages */
   if (n_OpenFileAppl("ESTM7620_O1", "wt", &Kp_OutputFileVie) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileApplVie");
   }

/* Initialisation de la structure de rupture */
   if (n_InitRupture(&bd_Rupture ) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupture");
   }

/* Initialisation de la structure de synchronisation du GTAavec le perimetre */
   if (n_InitSync(&bd_SyncGTA, "ESTM7620_I2") == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_InitSyncGTA");
   }

/* Lancement du traitement du fichier maitre */
   if (n_ProcessingRuptureVar(&bd_Rupture) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
   }

   if (n_CloseFileAppl("ESTM7620_I1", &(bd_Rupture.pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM7620_I2", &(bd_SyncGTA.pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM7620_O1", &Kp_OutputFileVie) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileApplVie");
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

   if (n_OpenFileAppl("ESTM7620_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }

   pbd_Rupture->n_ActionLigne=n_ActionLigne;
   pbd_Rupture->c_Separ= '~';

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

int n_InitSync(T_RUPTURE_SYNC_VAR  *pbd_Sync, char *sz_FicName)
{
   DEBUT_FCT("n_InitSync");
   memset(pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR));

/* Ouverture du fichier esclave */
   if (n_OpenFileAppl("ESTM7620_I2", "rt", &(pbd_Sync->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }


   pbd_Sync->ConditionEndSync=n_ConditionSync;
   pbd_Sync->n_ActionLigne=n_ActionLigneSync;
   pbd_Sync->c_Separ='~';

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

int n_ActionLigne(char *ptsz_LigneCour[])
{
   DEBUT_FCT("n_ActionLigneRupture");

/* Synchronisation avec le GTA */
   n_ProcessingRuptureSyncVar(&bd_SyncGTA, ptsz_LigneCour);

/*   if( bd_Rupture.b_EoF == TRUE )
   {
	   bd_Rupture.pf_InputFil = Kpf_InputFilIRD ;
	   bd_Rupture.b_EoW = FALSE;
	   bd_Rupture.b_EoF = FALSE;
   }*/
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

   /* Filtre des mouvements retro */
/*   if ( ptsz_LigneEsclave[GT_TRNCOD_CF][0] == '2'  || ptsz_LigneEsclave[GT_TRNCOD_CF][0] == '4' )
		RETURN_VAL(0);
*/
   if ( (s_ret = strcmp(ptsz_LigneMaitre[PER_CTR_NF], ptsz_LigneEsclave[GT_CTR_NF])) ) {
       RETURN_VAL(s_ret);
   }

   if ( (s_ret = strcmp(ptsz_LigneMaitre[PER_END_NT], ptsz_LigneEsclave[GT_END_NT])) ) {
      RETURN_VAL(s_ret);
   }
   if ( (s_ret = strcmp(ptsz_LigneMaitre[PER_SEC_NF], ptsz_LigneEsclave[GT_SEC_NF])) ) {
      RETURN_VAL(s_ret);
   }
   if ( (s_ret = strcmp(ptsz_LigneMaitre[PER_UWY_NF], ptsz_LigneEsclave[GT_UWY_NF])) ) {
      RETURN_VAL(s_ret);
   }
   RETURN_VAL(strcmp(ptsz_LigneMaitre[PER_UW_NT], ptsz_LigneEsclave[GT_UW_NT]));
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


/*   if ( ptsz_LigneEsclave[GT_TRNCOD_CF][0] == '2'  || ptsz_LigneEsclave[GT_TRNCOD_CF][0] == '4' )
   {
      	n_WriteCols(Kp_OutputFileGTAR, ptsz_LigneEsclave, '~', 0);
		RETURN_VAL(OK);
   }
*/
   if ( (strcmp(ptsz_LigneMaitre[PER_LOB_CF], "30") == 0) || (strcmp(ptsz_LigneMaitre[PER_LOB_CF], "31") == 0) )
   {
      n_WriteCols(Kp_OutputFileVie, ptsz_LigneEsclave, '~', 0);
   }
/*   else {
      n_WriteCols(Kp_OutputFileDom, ptsz_LigneEsclave, '~', 0);
   }
*/
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
/*
int n_ActionFilsSansPere(char *ptsz_Ligne[])
{
   DEBUT_FCT("int n_ActionFilsSansPere");


   if (   strstr(Ksz_SSDs, ptsz_Ligne[GT_SSD_CF] ) )
	   n_WriteCols(Kp_OutputFileAno, ptsz_Ligne, '~', 0);

   RETURN_VAL(OK);
}
*/

