/*==============================================================================
Nom de l'application          : Separation du GT acceptation en vie et non vie
Nom du source                 : ESTM7605.c
Revision                      : $Revision: 1.1.1.1 $
Date de creation              : 01/09/1997
Auteur                        : CGI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
  Separation du GT acceptation en vie et non vie.
  En entree : le GT acceptation,
              le perimetre IADVPERICASE.
  En sortie : le GT dommages,
              le GT vie,
              un fichier d'anomalies.
------------------------------------------------------------------------------
Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
[002] 17/12/2012 :spot:24041 - Solvency 2 - réactivation de l'écriturte sur le fichier Ano.
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

FILE 		   *Kp_OutputFileDom; /* Pointeur sur le GT dommages en */
                                      /* sortie */
FILE 		   *Kp_OutputFileVie; /* Pointeur sur le GT vie en sortie */
FILE 		   *Kp_OutputFileAno; /* Pointeur sur le fichier d'anomalies */
                                      /* en sortie */
T_RUPTURE_VAR  	   *pbd_Rupture;   /* Pointeur sur la structure de la rupture */
T_RUPTURE_SYNC_VAR *pbd_Sync; /* Pointeur sur la structure de synchronisation */

char Kc_Fichier; /* Vaut 'D' si affaire dommage, 'V' si affaire vie et 'N' si */
                 /* l'affaire n'existe pas */

double  Kd_Montant = 0  ;
fpos_t K_pos ;

/*-----------------------------*/
/* Fonctions du fichier maitre */
/*-----------------------------*/

int n_InitRupture	   (T_RUPTURE_VAR  *pbd_Rupture);
int n_TestRupture	 (char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_TestRupture2	 (char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionPremiereRupture(char *ptsz_LigneCour[]);
int n_ActionPremiereRupture2(char *ptsz_LigneCour[]);
int n_ActionDerniereRupture(char *ptsz_LigneCour[]);
int n_ActionDerniereRupture2(char *ptsz_LigneCour[]);
int n_ActionLigneRupture   (char *ptsz_LigneCour[]);


/*--------------------------------------------------------------*/
/* Fonctions de la synchronisation entre le maitre et l'esclave */
/*--------------------------------------------------------------*/

int n_InitSync	 	(T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ActionLigneSync	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSync	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ActionPereSansFils(char **ptsz_LigneMaitre);


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
   pbd_Rupture=malloc(sizeof(T_RUPTURE_VAR));
   pbd_Sync=malloc(sizeof(T_RUPTURE_SYNC_VAR));

/* Initialisation des signaux */
   InitSig();

   if (n_BeginPgm(argc, argv) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");
   }

/* Ouverture du fichier de sortie dommages */
   if (n_OpenFileAppl("ESTM7605_O1", "wt", &Kp_OutputFileDom) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileApplDom");
   }

/* Ouverture du fichier de sortie vie */
   if (n_OpenFileAppl("ESTM7605_O2", "wt", &Kp_OutputFileVie) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileApplVie");
   }

/* Ouverture du fichier d'anomalies */
   if (n_OpenFileAppl("ESTM7605_O3", "wt", &Kp_OutputFileAno) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileApplAno");
   }

/* Initialisation de la structure de rupture */
   if (n_InitRupture(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupture");
   }

/* Initialisation de la structure de synchronisation avec le perimetre */
   if (n_InitSync(pbd_Sync) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_InitSync");
   }

/* Lancement du traitement du fichier maitre */
   if (n_ProcessingRuptureVar(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
   }

   if (n_CloseFileAppl("ESTM7605_I1", &(pbd_Rupture->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM7605_I2", &(pbd_Sync->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM7605_O1", &Kp_OutputFileDom) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileApplDom");
   }

   if (n_CloseFileAppl("ESTM7605_O2", &Kp_OutputFileVie) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileApplVie");
   }

   if (n_CloseFileAppl("ESTM7605_O3", &Kp_OutputFileAno) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileApplAno");
   }

   if (n_EndPgm() == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_EndPgm");
   }

   free(pbd_Rupture);
   free(pbd_Sync);

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
   if (n_OpenFileAppl("ESTM7605_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_Rupture->n_NbRupture=2;
   pbd_Rupture->n_ConditionRupture[0]=n_TestRupture;
   pbd_Rupture->n_ConditionRupture[1]=n_TestRupture2;
   pbd_Rupture->n_ActionFirst[0]=n_ActionPremiereRupture;
   pbd_Rupture->n_ActionFirst[1]=n_ActionPremiereRupture2;
   pbd_Rupture->n_ActionLast[1]=n_ActionDerniereRupture2;
   pbd_Rupture->n_ActionLigne=n_ActionLigneRupture;
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

int n_InitSync(
   T_RUPTURE_SYNC_VAR  *pbd_Sync
)
{
   DEBUT_FCT("n_InitSync");
   memset(pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR));

/* Ouverture du fichier esclave */
   if (n_OpenFileAppl("ESTM7605_I2", "rt", &(pbd_Sync->pf_InputFil)) == ERR) {
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
   static short s_ret;

   DEBUT_FCT("n_TestRupture");

   if (s_ret = strcmp(ptsz_LigneSuiv[GT_CTR_NF], ptsz_LigneCour[GT_CTR_NF])) {
      return s_ret;
   }
   if (s_ret = strcmp(ptsz_LigneSuiv[GT_END_NT], ptsz_LigneCour[GT_END_NT])) {
      return s_ret;
   }
   if (s_ret = strcmp(ptsz_LigneSuiv[GT_SEC_NF], ptsz_LigneCour[GT_SEC_NF])) {
      return s_ret;
   }
   if (s_ret = strcmp(ptsz_LigneSuiv[GT_UWY_NF], ptsz_LigneCour[GT_UWY_NF])) {
      return s_ret;
   }
   RETURN_VAL(strcmp(ptsz_LigneSuiv[GT_UW_NT], ptsz_LigneCour[GT_UW_NT]));
}
/**************************************************************************/
/*** Objet : fonction de test de rupture                                ***/
/***                                                                    ***/
/*** Nom : n_TestRupture2                                                ***/
/***                                                                    ***/
/*** Parametres:                                                        ***/
/***    i ptsz_LineSuiv : pointeur sur la ligne suivante,               ***/
/***    i ptsz_LineCour : pointeur sur la ligne precedente.             ***/
/***                                                                    ***/
/*** Retour:                                                            ***/
/***    0 si pas de rupture,                                            ***/
/***    1 si rupture.                                                   ***/
/**************************************************************************/

int n_TestRupture2(
   char *ptsz_LigneSuiv[],
   char *ptsz_LigneCour[]
)
{
   static short s_ret;

   DEBUT_FCT("n_TestRupture2");

   if (s_ret = strcmp(ptsz_LigneSuiv[GT_CUR_CF], ptsz_LigneCour[GT_CUR_CF])) {
      return s_ret;
   }
   RETURN_VAL(strcmp(ptsz_LigneSuiv[GT_TRNCOD_CF], ptsz_LigneCour[GT_TRNCOD_CF]));
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

/* Synchronisation avec le perimetre pour la premiere ligne */
   n_ProcessingRuptureSyncVar(pbd_Sync, ptsz_LigneCour);

   RETURN_VAL(OK);
}

/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne en rupture premiere du   ***/
/***         fichier maitre                                             ***/
/***                                                                    ***/
/*** Nom : n_ActionPremiereRupture2                                      ***/
/***                                                                    ***/
/*** Parametres:                                                        ***/
/***    i ptsz_LigneCour : pointeur sur la ligne courante               ***/
/***                                                                    ***/
/*** Retour:                                                            ***/
/***    OK si pas d'erreur,                                             ***/
/***    ERR si erreur.                                                  ***/
/**************************************************************************/

int n_ActionPremiereRupture2(char *ptsz_LigneCour[])
{
   DEBUT_FCT("n_ActionPremiereRupture2");


/* Initialisation du cumul des montants a 0 */
   Kd_Montant = 0;

/* Ouverture d'une transaction d'ecriture dans le fichier des ano */
   if(Kc_Fichier == 'N' )
   	fgetpos(Kp_OutputFileAno,&K_pos);

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

   switch(Kc_Fichier)
  {
   case 'D' : /* Ligne dommage*/
      	n_WriteCols(Kp_OutputFileDom, ptsz_LigneCour, '~', 0);
	break ;
   case 'V' : /* ligne vie */
      	n_WriteCols(Kp_OutputFileVie, ptsz_LigneCour, '~', 0);
	break;
   case 'N' : /* ligne GT qu n'existe pas dans dans le perimetre */
      	n_WriteCols(Kp_OutputFileAno, ptsz_LigneCour, '~', 0);
	Kd_Montant += atof(ptsz_LigneCour[GT_AMT_M] );
	break ;
   }

   RETURN_VAL(OK);
}

/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne en rupture premiere du   ***/
/***         fichier maitre                                             ***/
/***                                                                    ***/
/*** Nom : n_ActionDerniereRupture                                      ***/
/***                                                                    ***/
/*** Parametres:                                                        ***/
/***    i ptsz_LigneCour : pointeur sur la ligne courante               ***/
/***                                                                    ***/
/*** Retour:                                                            ***/
/***    OK si pas d'erreur,                                             ***/
/***    ERR si erreur.                                                  ***/
/**************************************************************************/
int n_ActionDerniereRupture2(char *ptsz_LigneCour[])
{
   DEBUT_FCT("n_ActionPremiereRupture");

   if(Kc_Fichier == 'N' )
	if( fabs(Kd_Montant) < 1.0 )
		fsetpos(Kp_OutputFileAno,&K_pos);
	else
		fprintf(Kp_OutputFileAno,"*********     %lf    ********\n",Kd_Montant);

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

   if (s_ret = strcmp(ptsz_LigneMaitre[GT_CTR_NF], ptsz_LigneEsclave[PER_CTR_NF])) {
      return s_ret;
   }
   if (s_ret = strcmp(ptsz_LigneMaitre[GT_END_NT], ptsz_LigneEsclave[PER_END_NT])) {
      return s_ret;
   }
   if (s_ret = strcmp(ptsz_LigneMaitre[GT_SEC_NF], ptsz_LigneEsclave[PER_SEC_NF])) {
      return s_ret;
   }
   if (s_ret = strcmp(ptsz_LigneMaitre[GT_UWY_NF], ptsz_LigneEsclave[PER_UWY_NF])) {
      return s_ret;
   }
   RETURN_VAL(strcmp(ptsz_LigneMaitre[GT_UW_NT], ptsz_LigneEsclave[PER_UW_NT]));
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

   if ( (strcmp(ptsz_LigneEsclave[PER_LOB_CF], "30") == 0) || (strcmp(ptsz_LigneEsclave[PER_LOB_CF], "31") == 0) ) {
      Kc_Fichier = 'V';
   }
   else {
      Kc_Fichier = 'D';
   }
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

int n_ActionPereSansFils(char *ptsz_LigneMaitre[])
{
   DEBUT_FCT("n_ActionPereSansFils");

   Kc_Fichier = 'N';

	//[002]
   n_WriteCols(Kp_OutputFileAno, ptsz_LigneMaitre, '~', 0);
   /*
   fprintf (Kp_OutputFileAno, "CTR %s, END %s, SEC %s, UWY %s,  UW %s : not in Acceptance Perimeter\n",
            ptsz_LigneMaitre[GT_CTR_NF],
            ptsz_LigneMaitre[GT_END_NT],
            ptsz_LigneMaitre[GT_SEC_NF],
            ptsz_LigneMaitre[GT_UWY_NF],
            ptsz_LigneMaitre[GT_UW_NT]
   ); */

   RETURN_VAL(OK);
}
