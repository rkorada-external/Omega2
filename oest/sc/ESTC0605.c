/*==============================================================================
Nom de l'tpplication          : Calcul des sinistres par segments/exercice
                                dans TSEGEST
Nom du source                 : ESTC0605.c
Revision                      : $Revision: 1.2 $
Date de creation              : 07/07/1997
Auteur                        : CGI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
   Calcul des sinistres par segments/exercice dans TSEGEST

Remarque identique au step ESTC0604 : Conserver un deuxieme niveau de rupture
sur la devise permet d'optimiser le calcul des cumuls. Le conversion en devise
du segment n'est faite qu'une seule fois par lot de devises du perimetre.
------------------------------------------------------------------------------
Historique des modifications :
   <jj/mm/aaaa>   <auteur>        <description de la modification>
    29/10/1998   B.Montagnac    Suppression du critere  de regroupement EGP_CUR
                                dans le calcul des sinistres
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <utctlib.h>
#include <stdarg.h>
#include "struct.h"
#include "estserv.h"

/*----------------------*/
/* Variables de travail */
/*----------------------*/

FILE 		   *Kp_OutputFile; /* Pointeur sur le fichier de sortie */
FILE 		   *Kp_GetTaux;    /* Pointeur sur le fichier des taux */
T_RUPTURE_VAR  	   *pbd_Rupture;   /* Pointeur sur la structure de la rupture */
T_RUPTURE_SYNC_VAR *pbd_Sync;      /* Pointeur sur la structure de */
                                   /* synchronisation */

char Kc_SEGTYP_CT;         /* Type segment */
short Ks_SSD_CF;           /* Filiale */
char Ksz_CRE_D[9];         /* Date utilisee pour le cours en estimations */
int Kn_CREYEA;             /* Annee utilisee pour le cours en estimations */
int Kn_BALSHTYEA;          /* Annee utilisee pour le cours en actuariat */

short Ks_SEGNUL;           /* Vaut 1 si le segment de l'affaire est nul */

char *Ktsz_Sortie[10];     /* Tableau de chaines a ecrire en sortie */
char Ksz_MessageErr[256];  /* Message d'erreur */
char **Kptsz_LigneEsclave; /* Pointeur sur la ligne de l'esclave pour */
                           /* recuperer la ligne dans le maitre */

double Kd_Ps_M;        /* Variable contenant le cumul des Ps */
double Kd_PsDevise_M;  /* Variable contenant le cumul des Ps pour le devise */

double Kd_PA_M;        /* Variable contenant le cumul des Ps */
double Kd_PADevise_M;  /* Variable contenant le cumul des Ps pour le devise */

double Kd_Pa_M;        /* Variable contenant le cumul des Pa */
double Kd_PaDevise_M;  /* Variable contenant le cumul des Pa pour le devise */

double Kd_PAa_M;       /* Variable contenant le cumul des PAa */
double Kd_PAaDevise_M; /* Variable contenant le cumul des PAa pour le devise */

double Kd_Sa_M;        /* Valeur de Sa du segment */
double Kd_Ss_M;        /* Valeur de Ss du segment */
double Kd_SsDevise_M;  /* Valeur de Ss des affaires du segment */

double Kd_Sc_M;        /* Variable contenant le cumul des Sc */
double Kd_ScDevise_M;  /* Variable contenant le cumul des Sc pour le devise */

double Kd_Sa_M;        /* Variable contenant le cumul des Sa */

double Kd_Taux;        /* Taux de change */


/*-----------------------------*/
/* Fonctions du fichier maitre */
/*-----------------------------*/

int n_InitRupture 	(T_RUPTURE_VAR  *pbd_Rupture);
int n_TestRupture1 	(char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_TestRupture2 	(char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionPremiereRupture1	(char *ptsz_LigneCour[]);
int n_ActionPremiereRupture2	(char *ptsz_LigneCour[]);
int n_ActionLigneRupture 	(char *ptsz_LigneCour[]);
int n_ActionDerniereRupture1	(char *ptsz_LigneCour[]);
int n_ActionDerniereRupture2	(char *ptsz_LigneCour[]);


/*--------------------------------------------------------------*/
/* Fonctions de la synchronisation entre le maitre et l'esclave */
/*--------------------------------------------------------------*/

int n_InitSync 		(T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ActionLigneSync	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSync	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ActionPereSansFils(char **ptsz_LigneMaitre);


/**************************************************************************/
/*** Objet : Calcul de la sinistralite pour chaque segment/exercice de 	***/
/***        TSEGEST en mode "S/P"	       				***/
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
   pbd_Sync = malloc(sizeof(T_RUPTURE_SYNC_VAR));

   /* Initialisation des signaux */
   InitSig();

   if (n_BeginPgm(argc, argv) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");
   }

   /* Recuperation du parametre correspondant au type de segment */
   Kc_SEGTYP_CT=*(psz_GetCharArgv(1));

   /* En estimations, recuperation de l'annee de CRE_D */
   if (Kc_SEGTYP_CT == 'E') {
      strcpy(Ksz_CRE_D, psz_GetCharArgv(2));
      Ksz_CRE_D[5] = '\0';
      Kn_CREYEA = atoi(Ksz_CRE_D);
   }

   /* En actuariat, recuperation de BALSHTYEA_NF */
   else if (Kc_SEGTYP_CT == 'A') {
      Kn_BALSHTYEA = n_GetIntArgv(2);
   }


   /* Ouverture du fichier des taux */
   if (n_OpenFileAppl("ESTC0605_I3", "rt", &Kp_GetTaux) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileApplGetTaux");
   }

   /* Ouverture du fichier de sortie */
   if (n_OpenFileAppl("ESTC0605_O1", "wt", &Kp_OutputFile) == ERR) {
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

   if (n_CloseFileAppl("ESTC0605_I1", &(pbd_Rupture->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC0605_I2", &(pbd_Sync->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC0605_I3", &Kp_GetTaux) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC0605_O1", &Kp_OutputFile) == ERR) {
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
   if (n_OpenFileAppl("ESTC0605_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_Rupture->n_NbRupture=2;
   pbd_Rupture->n_ConditionRupture[0]=n_TestRupture1;
   pbd_Rupture->n_ConditionRupture[1]=n_TestRupture2;
   pbd_Rupture->n_ActionFirst[0]=n_ActionPremiereRupture1;
   pbd_Rupture->n_ActionFirst[1]=n_ActionPremiereRupture2;
   pbd_Rupture->n_ActionLigne=n_ActionLigneRupture;
   pbd_Rupture->n_ActionLast[0]=n_ActionDerniereRupture1;
   pbd_Rupture->n_ActionLast[1]=n_ActionDerniereRupture2;
   pbd_Rupture->c_Separ= '~';

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : Initialisation de la synchronisation		        ***/
/***									***/
/*** Nom : n_InitSync	  						***/
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
   if (n_OpenFileAppl("ESTC0605_I2", "rt", &(pbd_Sync->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_Sync->ConditionEndSync=n_ConditionSync;
   pbd_Sync->n_ActionLigne=n_ActionLigneSync;
   pbd_Sync->n_PereSansFils=n_ActionPereSansFils;
   pbd_Sync->c_Separ='~';

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction de test de rupture de niveau 1			***/
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
   static short n_Ret;

   if (Kc_SEGTYP_CT == 'E') {
      if ((n_Ret=strcmp(ptsz_LigneSuiv[CASEEST_SEG_NF], ptsz_LigneCour[CASEEST_SEG_NF]))) {
         return n_Ret;
      }
   return (strcmp(ptsz_LigneSuiv[CASEEST_UWY_NF], ptsz_LigneCour[CASEEST_UWY_NF]));
   }
   else {
      if ((n_Ret=strcmp(ptsz_LigneSuiv[CASEACT_SEG_NF], ptsz_LigneCour[CASEACT_SEG_NF]))) {
         return n_Ret;
      }
   return (strcmp(ptsz_LigneSuiv[CASEACT_UWY_NF], ptsz_LigneCour[CASEACT_UWY_NF]));
   }
}


/**************************************************************************/
/*** Objet : fonction de test de rupture de niveau 2			***/
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
   static short n_Ret;

   if (Kc_SEGTYP_CT == 'E') {
      if ((n_Ret=strcmp(ptsz_LigneSuiv[CASEEST_SEG_NF], ptsz_LigneCour[CASEEST_SEG_NF]))) {
         return n_Ret;
      }
      if ((n_Ret=strcmp(ptsz_LigneSuiv[CASEEST_UWY_NF], ptsz_LigneCour[CASEEST_UWY_NF]))) {
         return n_Ret;
      }
      return (strcmp(ptsz_LigneSuiv[CASEEST_EGPCUR_CF], ptsz_LigneCour[CASEEST_EGPCUR_CF]));
    }
   else { /* Kc_SEGTYP_CT = 'A' */
      if ((n_Ret=strcmp(ptsz_LigneSuiv[CASEACT_SEG_NF], ptsz_LigneCour[CASEACT_SEG_NF]))) {
         return n_Ret;
      }
      if ((n_Ret=strcmp(ptsz_LigneSuiv[CASEACT_UWY_NF], ptsz_LigneCour[CASEACT_UWY_NF]))) {
         return n_Ret;
      }
      return (strcmp(ptsz_LigneSuiv[CASEACT_EGPCUR_CF], ptsz_LigneCour[CASEACT_EGPCUR_CF]));
    }
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne en rupture premiere de   ***/
/***         niveau 1 du fichier maitre					***/
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

   if (*ptsz_LigneCour[CASEEST_SEG_NF] == '\0') {
      Ks_SEGNUL = 1;
   }
   else {
      Ks_SEGNUL = 0;
      Kd_Ps_M = 0;  /* E A */
      Kd_PA_M = 0;  /* E A */
      Kd_Pa_M = 0;  /* E   */
      Kd_PAa_M = 0; /*   A */
      Kd_Ss_M = 0;  /*   A */
      Kd_Sc_M = 0;  /* E A */
      Kd_Sa_M = 0;  /* E A */
   }

   if (Ks_SEGNUL == 0) {
      /* Synchronisation de la ligne avec le fichier esclave, */
      /* cumule les montants de l'esclave et convertit */
      /* le resultat en devise du segment */
      n_ProcessingRuptureSyncVar(pbd_Sync, ptsz_LigneCour);
   }

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne en rupture premiere de   ***/
/***         niveau 2 du fichier maitre					***/
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

   Kd_PsDevise_M = 0;  /* E A */
   Kd_PADevise_M = 0;  /* E A */
   Kd_PaDevise_M = 0;  /* E   */
   Kd_PAaDevise_M = 0; /*   A */
   Kd_ScDevise_M = 0;  /* E A */
   Kd_SsDevise_M = 0;  /*   A */

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

   if (Ks_SEGNUL == 0) {
      if (Kc_SEGTYP_CT == 'E') {
         Kd_PADevise_M += atof(ptsz_LigneCour[CASEEST_PAi_M]);
         Kd_PsDevise_M += atof(ptsz_LigneCour[CASEEST_Psi_M]);
         Kd_ScDevise_M += atof(ptsz_LigneCour[CASEEST_Scii_M]) +
	                  atof(ptsz_LigneCour[CASEEST_Scci_M]);
         Kd_PaDevise_M += atof(ptsz_LigneCour[CASEEST_Pai_M]);
      }
      else {
         Kd_PADevise_M += atof(ptsz_LigneCour[CASEACT_PAi_M]);
         Kd_PsDevise_M += atof(ptsz_LigneCour[CASEACT_Psi_M]);
         Kd_ScDevise_M += atof(ptsz_LigneCour[CASEACT_Scii_M]) +
	                  atof(ptsz_LigneCour[CASEACT_Scci_M]) +
	                  atof(ptsz_LigneCour[CASEACT_Sccai_M]);
         Kd_PAaDevise_M += atof(ptsz_LigneCour[CASEACT_PAai_M]);
         Kd_SsDevise_M += atof(ptsz_LigneCour[CASEACT_Ssi_M]);
      }
   }

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne en rupture derniere de   ***/
/***         niveau 1 du fichier maitre					***/
/***									***/
/*** Nom : n_ActionDerniereRupture1					***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneCour : pointeur sur la ligne courante		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionDerniereRupture1(char *ptsz_LigneCour[])
{
   static char sz_PA_M[25];  /* Chaine contenant PA */
   static char sz_Ps_M[25];  /* Chaine contenant Ps */
   static char sz_PAa_M[25]; /* Chaine contenant PAa */
   static char sz_Ss_M[25];  /* Chaine contenant Ss */
   static char sz_Sc_M[25];  /* Chaine contenant Sc */
   static char sz_Pa_M[25];  /* Chaine contenant Pa */
   static char sz_Sa_M[25];  /* Chaine contenant Sa */

   DEBUT_FCT("n_ActionDerniereRupture1");

   /* Si la synchro a fonctionne */
   if (Ks_SEGNUL == 0) {

      sprintf(sz_PA_M,  "%-.3lf", Kd_PA_M);
      sprintf(sz_Ps_M,  "%-.3lf", Kd_Ps_M);
      sprintf(sz_PAa_M, "%-.3lf", Kd_PAa_M);
      sprintf(sz_Ss_M,  "%-.3lf", Kd_Ss_M);
      sprintf(sz_Sc_M,  "%-.3lf", Kd_Sc_M);
      sprintf(sz_Pa_M,  "%-.3lf", Kd_Pa_M);
      sprintf(sz_Sa_M,  "%-.3lf", Kd_Sa_M);

      Ktsz_Sortie[0] = Kptsz_LigneEsclave[SEGEST1_SEG_NF];
      Ktsz_Sortie[1] = Kptsz_LigneEsclave[SEGEST1_UWY_NF];
      Ktsz_Sortie[2] = "\0";/*ptsz_LigneCour[CASEEST_EGPCUR_CF];*/
      Ktsz_Sortie[3] = Kptsz_LigneEsclave[SEGEST1_CUR_CF];
      Ktsz_Sortie[4] = Kptsz_LigneEsclave[SEGEST1_SEGNAT_CT];
      Ktsz_Sortie[5] = sz_Ss_M;
      Ktsz_Sortie[6] = sz_Ps_M;
      Ktsz_Sortie[7] = sz_PAa_M;
      Ktsz_Sortie[8] = sz_Sc_M;
      Ktsz_Sortie[9] = sz_PA_M;
      Ktsz_Sortie[10] = sz_Pa_M;
      Ktsz_Sortie[11] = sz_Sa_M;
      Ktsz_Sortie[12] = NULL;

      /* Ecriture dans le fichier de sortie */
      n_WriteCols(Kp_OutputFile, Ktsz_Sortie, '~', 0);
   }

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne en rupture derniere de   ***/
/***         niveau 2 du fichier maitre					***/
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

   if (Ks_SEGNUL == 0) {

      if (Kc_SEGTYP_CT == 'E') {

         Kd_Taux = d_GetTaux(Kp_GetTaux,
			     (unsigned char)atoi(Kptsz_LigneEsclave[SEGEST1_SSD_CF]),
			     Kn_CREYEA, ptsz_LigneCour[CASEEST_EGPCUR_CF],
			     Kptsz_LigneEsclave[SEGEST1_CUR_CF]);

	 /* Generation d'une anomalie quand la fonction de taux renvoie 0 */
         if (Kd_Taux == -1) {

            sprintf(Ksz_MessageErr, "SSD : %s ; UWY : %d ; INITIAL CUR : %s ; FINAL CUR %s",
		     Kptsz_LigneEsclave[SEGEST1_SSD_CF], Kn_CREYEA,
		     ptsz_LigneCour[CASEEST_EGPCUR_CF], Kptsz_LigneEsclave[SEGEST1_CUR_CF]);
            n_WriteAno(Ksz_MessageErr);
         }

         Kd_PA_M += Kd_PADevise_M * Kd_Taux;
         Kd_Ps_M += Kd_PsDevise_M * Kd_Taux;
         Kd_Sc_M += Kd_ScDevise_M * Kd_Taux;
         Kd_Pa_M += Kd_PaDevise_M * Kd_Taux;
         Kd_Ss_M += Kd_SsDevise_M * Kd_Taux;
      }
      else {

         Kd_Taux = d_GetTaux(Kp_GetTaux,
			     (unsigned char)atoi(Kptsz_LigneEsclave[SEGEST1_SSD_CF]),
			     Kn_BALSHTYEA, ptsz_LigneCour[CASEACT_EGPCUR_CF],
			     Kptsz_LigneEsclave[SEGEST1_CUR_CF]);

	 /* Generation d'une anomalie quand la fonction de taux renvoie 0 */
         if (Kd_Taux == -1) {

            sprintf(Ksz_MessageErr, "SSD : %s ; UWY : %d ; INITIAL CUR : %s ; FINAL CUR %s",
		     Kptsz_LigneEsclave[SEGEST1_SSD_CF], Kn_BALSHTYEA,
		     ptsz_LigneCour[CASEACT_EGPCUR_CF], Kptsz_LigneEsclave[SEGEST1_CUR_CF]);
            n_WriteAno(Ksz_MessageErr);
         }

         Kd_PA_M += Kd_PADevise_M * Kd_Taux;
         Kd_Ps_M += Kd_PsDevise_M * Kd_Taux;
         Kd_Sc_M += Kd_ScDevise_M * Kd_Taux;
         Kd_PAa_M += Kd_PAaDevise_M * Kd_Taux;
         Kd_Ss_M += Kd_SsDevise_M * Kd_Taux;
      }
   }

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : synchronisation entre le fichier maitre et le fichier 	***/
/***         esclave							***/
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
   static short ret;

   if (Kc_SEGTYP_CT == 'E') {
      if ((ret = strcmp(ptsz_LigneMaitre[CASEEST_SEG_NF], ptsz_LigneEsclave[SEGEST1_SEG_NF]))) {
         return ret;
   }
   return (strcmp(ptsz_LigneMaitre[CASEEST_UWY_NF], ptsz_LigneEsclave[SEGEST1_UWY_NF]));
   }
   else {
      if ((ret = strcmp(ptsz_LigneMaitre[CASEACT_SEG_NF], ptsz_LigneEsclave[SEGEST1_SEG_NF]))) {
         return ret;
   }
   return (strcmp(ptsz_LigneMaitre[CASEACT_UWY_NF], ptsz_LigneEsclave[SEGEST1_UWY_NF]));
   }
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne de l'esclave		***/
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

int n_ActionLigneSync(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   DEBUT_FCT("n_ActionLigneSync");

   Ks_SEGNUL = 0;
   Kptsz_LigneEsclave = ptsz_LigneEsclave;
   Kd_Sa_M = atof(ptsz_LigneEsclave[SEGEST1_Ss_M]);

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

   /* Si le segment/exercice de l'affaire n'est pas trouve dans FSEGEST, on */
   /* n'ecrit pas de ligne en sortie */
   Ks_SEGNUL = 1;

   RETURN_VAL(OK);
}
