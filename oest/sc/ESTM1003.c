/*==============================================================================
Nom de l'application          : Filtre d'un fichier perimetre annexe comprenant
                                une synchro avec le fichier IADPERICASE pour
				eliminer les affaires en retrocession interne
Nom du source                 : ESTM1003.c
Revision                      : $Revision: 1.2 $
Date de creation              : 30/07/1997
Auteur                        : CGI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
  Filtre d'un fichier perimetre annexe comprenant une synchro avec le fichier
  IADPERICASE pour eliminer les affaires en retrocession interne
  Attention :
  La position des champs CASEX dans les fichier annexes est code en dur pour que
  ce soit valable pour tous les perimetres annexes.
  En entree : fichier perimetre annexe,
              fichier perimetre IADPERICASE,
  En sortie : fichier perimetre annexe filtre.
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

FILE 		   *Kp_OutputFile; /* Pointeur sur le fichier de sortie       */
T_RUPTURE_VAR  	   *pbd_Rupture; /* Pointeur sur la structure de la rupture   */
T_RUPTURE_SYNC_VAR *pbd_Sync; /* Pointeur sur la structure de synchronisation */

char Ksz_MessageErr[256]; /* Message d'erreur                                 */
short Ks_Ecrire; /* Vaut 1 si on ecrit la ligne, 0 autrement */

char **Kptsz_LigneEsclave; /* Pointeur sur la ligne de l'esclave pour */
                           /* l'utiliser dans le maitre */


/*-----------------------------*/
/* Fonctions du fichier maitre */
/*-----------------------------*/

int n_InitRupture	 (T_RUPTURE_VAR  *pbd_Rupture);
int n_TestRupture	 	(char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionPremiereRupture	(char *ptsz_LigneCour[]);
int n_ActionLigneRupture (char *ptsz_LigneCour[]);


/*--------------------------------------------------------------*/
/* Fonctions de la synchronisation entre le maitre et l'esclave */
/*--------------------------------------------------------------*/

int n_InitSync	 	(T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ActionLigneSync	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSync	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ActionPereSansFils(char **ptsz_LigneMaitre);


/**************************************************************************/
/*** Objet : synchronisation entre le fichier perimetre annexe     	***/
/***         et le fichier IADPERICASE     				***/
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

/* Ouverture du fichier de sortie */
   if (n_OpenFileAppl("ESTM1003_O1", "wt", &Kp_OutputFile) == ERR) {
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

   if (n_CloseFileAppl("ESTM1003_I1", &(pbd_Rupture->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM1003_I2", &(pbd_Sync->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM1003_O1", &Kp_OutputFile) == ERR) {
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
   if (n_OpenFileAppl("ESTM1003_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_Rupture->n_NbRupture=1;
   pbd_Rupture->n_ActionFirst[0]=n_ActionPremiereRupture;
   pbd_Rupture->n_ConditionRupture[0]=n_TestRupture;
   pbd_Rupture->n_ActionLigne=n_ActionLigneRupture;
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

/* Ouverture du fichier esclave ESTCASEEST */
   if (n_OpenFileAppl("ESTM1003_I2", "rt", &(pbd_Sync->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_Sync->ConditionEndSync=n_ConditionSync;
   pbd_Sync->n_ActionLigne=n_ActionLigneSync;
   pbd_Sync->n_PereSansFils=n_ActionPereSansFils;
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
   static int n_Ret;

   if (n_Ret=strcmp(ptsz_LigneSuiv[0], ptsz_LigneCour[0])) {
      return n_Ret;
   }
   if (n_Ret=strcmp(ptsz_LigneSuiv[1], ptsz_LigneCour[1])) {
      return n_Ret;
   }
   if (n_Ret=strcmp(ptsz_LigneSuiv[2], ptsz_LigneCour[2])) {
      return n_Ret;
   }
   if (n_Ret=strcmp(ptsz_LigneSuiv[3], ptsz_LigneCour[3])) {
      return n_Ret;
   }
   return (strcmp(ptsz_LigneSuiv[4], ptsz_LigneCour[4]));
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

/* Synchronisation du fichier esclave pour chaque ligne */
      n_ProcessingRuptureSyncVar(pbd_Sync, ptsz_LigneCour);

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

   if (Ks_Ecrire) {
      n_WriteCols(Kp_OutputFile, ptsz_LigneCour,'~', 0);
   }

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

   if (s_ret = strcmp(ptsz_LigneMaitre[0], ptsz_LigneEsclave[PER_CTR_NF])) {
      return s_ret;
   }
   if (s_ret = strcmp(ptsz_LigneMaitre[1], ptsz_LigneEsclave[PER_END_NT])) {
      return s_ret;
   }
   if (s_ret = strcmp(ptsz_LigneMaitre[2], ptsz_LigneEsclave[PER_SEC_NF])) {
      return s_ret;
   }
   if (s_ret = strcmp(ptsz_LigneMaitre[3], ptsz_LigneEsclave[PER_UWY_NF])) {
      return s_ret;
   }
   RETURN_VAL(strcmp(ptsz_LigneMaitre[4], ptsz_LigneEsclave[PER_UW_NT]));
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

   Kptsz_LigneEsclave = ptsz_LigneEsclave;

/* Pour ecrire en sortie */
   if (*Kptsz_LigneEsclave[PER_CTRRET_B] == '0') {
      Ks_Ecrire = 1;
   }
   else {
      Ks_Ecrire = 0;
   }

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction lancee quand aucune ligne du fichier esclave ne 	***/
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

int n_ActionPereSansFils(char *ptsz_LigneMaitre[])
{
   DEBUT_FCT("n_ActionPereSansFils");

 /*  sprintf (Ksz_MessageErr, "CTR %s, END %s, SEC %s, UWY %s, UW %s eliminated because of internal retrocession",
            ptsz_LigneMaitre[0],
            ptsz_LigneMaitre[1],
            ptsz_LigneMaitre[2],
            ptsz_LigneMaitre[3],
            ptsz_LigneMaitre[4]
   );

   n_WriteAno(Ksz_MessageErr);*/

/* Pour ne pas ecrire en sortie */
   Ks_Ecrire = 0;

   RETURN_VAL(OK);
}
