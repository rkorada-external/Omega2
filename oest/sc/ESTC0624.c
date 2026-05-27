/*==============================================================================
Nom de l'application          : Calcul de la sinistralite pour chaque
                                segment/exercice de TSEGEST en mode "S/P"
Nom du source                 : ESTC0604.c
Revision                      : $Revision: 1.2 $
Date de creation              : 04/07/1997
Auteur                        : CGI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :

   Initialement : ESTC0604 (regroupant les traitements en estimation ET
                  actuariat)
		  La présente évolution consiste à séparer le code en
		  deux steps ESTC0614 (estimation) et ESTC0624 (actuariat).


	  /\    *********************************************************
	 /  \   * TOUTE MODIFICATION DE CODE PORTANT EGALEMENT SUR LE   *
	/  ! \  * SEGMENT ESTIMATION DOIT ETRE REPORTEE DANS L'ESTC0614 *
       /______\ *********************************************************


   Calcul de la sinistralite pour chaque segment/exercice de TSEGEST en mode "S/P"

Fichier maitre  : SEGEST_O      trie sur [SEG][UWY]
Fichier esclave : PERICASEEST_O trie sur [SEG][UWY][CUR]

Les traitements sont donc synchronises sur [SEG][UWY]

Pour chaque enregistrement du maitre en mode 'ratio' (S/P a 'R') il faut
cumuler les primes acquises des affaires de l'esclave en convertissant les
montants de l'esclave (affaires) en monnaie du maitre (segment).

Dans un soucis d'optimisation, le fichier esclave (affaires) est trie egalement
sur les devises afin de determiner le taux de change une seule fois par groupe
de devise. On gere alors deux niveaux de rupture :
        - Rupture de niveau 1 sur [SEG][UWY],
	- Rupture de niveau 2 sur [SEG][UWY][CUR].

Algorithme :

   Pour chaque enregistrement du maitre ([SEG][UWY])
    |
    | Si l'enregistrement est en mode 'ratio' alors
    |  |
    |  | Initialiser le cumul des primes acquises
    |  |
    |  | Pour chaque lot [SEG][UWY][CUR] de l'esclave
    |  |  |
    |  |  | Cumuler les primes acquises
    |  |  | Ajouter le resultat au cumul du maitre (conversion en monnaie du segment)
    |  |
    |  | Mettre l'enregistrement en mode 'sinistre'
    |
    | Ecrire l'enregistrement en sortie.

Ainsi, la conversion de devise n'a lieu qu'une fois pour un lot de devises.
------------------------------------------------------------------------------
Historique des modifications :
   <jj/mm/aaaa>   <auteur>           <description de la modification>
    27/10/1998     B.Montagnac       Inversion du traitement (initialement S->S/P)
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

short Ks_SSD_CF;           /* Filiale */
char Ksz_CRE_D[9];         /* Date utilisee pour le cours en estimations */
int Kn_CREYEA;             /* Annee utilisee pour le cours en estimations */
int Kn_BALSHTYEA;          /* Annee utilisee pour le cours en actuariat */

short Ks_Analyse;          /* Vaut 1 si le segment/exercice doit etre analyse */
short Ks_SEGNUL;           /* Vaut 1 si le segment de l'affaire est nul */
                           /* (S/P a ratio), 0 autrement */

double Kd_Ss_M;            /* Valeur de Ss du segment */
char Kc_SP_CT;             /* Mode sinistralite ou S/P */
double Kd_SP_R;
double Kd_PA_M;            /* Variable contenant le cumul des PAi */
double Kd_PADevise_M;      /* Variable contenant le cumul des PAi pour la devise */
char *Ktsz_Sortie[10];     /* Tableau de chaines a ecrire en sortie */
char Ksz_MessageErr[256];  /* Message d'erreur */
char **Kptsz_LigneEsclave; /* Pointeur sur la ligne de l'esclave pour */
                           /* recuperer la ligne dans le maitre */
double Kd_Taux;            /* Taux de change */


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

  /* En actuariat, recuperation de BALSHTYEA_NF */
  Kn_BALSHTYEA = n_GetIntArgv(1);

  /* Ouverture du fichier des taux */
  if (n_OpenFileAppl("ESTC0624_I3", "rt", &Kp_GetTaux) == ERR) {
    ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileApplGetTaux");
  }

  /* Ouverture du fichier de sortie */
  if (n_OpenFileAppl("ESTC0624_O1", "wt", &Kp_OutputFile) == ERR) {
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

  if (n_CloseFileAppl("ESTC0624_I1", &(pbd_Rupture->pf_InputFil)) == ERR) {
    ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
  }

  if (n_CloseFileAppl("ESTC0624_I2", &(pbd_Sync->pf_InputFil)) == ERR) {
    ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
  }

  if (n_CloseFileAppl("ESTC0624_I3", &Kp_GetTaux) == ERR) {
    ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
  }

  if (n_CloseFileAppl("ESTC0624_O1", &Kp_OutputFile) == ERR) {
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
  if (n_OpenFileAppl("ESTC0624_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
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
  if (n_OpenFileAppl("ESTC0624_I2", "rt", &(pbd_Sync->pf_InputFil)) == ERR) {
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

  if ((n_Ret=strcmp(ptsz_LigneSuiv[CASEACT_SEG_NF], ptsz_LigneCour[CASEACT_SEG_NF]))) {
    return n_Ret;
  }
  return (strcmp(ptsz_LigneSuiv[CASEACT_UWY_NF], ptsz_LigneCour[CASEACT_UWY_NF]));
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

  if ((n_Ret=strcmp(ptsz_LigneSuiv[CASEACT_SEG_NF], ptsz_LigneCour[CASEACT_SEG_NF]))) {
    return n_Ret;
  }
  if ((n_Ret=strcmp(ptsz_LigneSuiv[CASEACT_UWY_NF], ptsz_LigneCour[CASEACT_UWY_NF]))) {
    return n_Ret;
  }
  return (strcmp(ptsz_LigneSuiv[CASEACT_EGPCUR_CF], ptsz_LigneCour[CASEACT_EGPCUR_CF]));
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

  if (*ptsz_LigneCour[CASEACT_SEG_NF] == '\0') {
    Ks_SEGNUL = 1;
  }
  else {
    Ks_SEGNUL = 0;
    Kd_PA_M = 0;
  }

  if (Ks_SEGNUL == 0) {
    /* Synchronisation de la ligne avec le fichier esclave, verifie que S/P est */
    /* a ratio et recupere alors la devise du segment et le montant de SP */
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

  Kd_PADevise_M = 0;

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

  if ( (Ks_Analyse == 1) && (Ks_SEGNUL == 0) ) {
    Kd_PADevise_M += atof(ptsz_LigneCour[CASEACT_PAi_M]);
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
  static char sz_Ss_M[25];      /* Chaine contenant Ss */
  static char sz_SP_R[25];      /* Chaine contenant S/P */
  static char sz_SP_CT[2]="S";  /* Chaine contenant S/P a sinistre */

  DEBUT_FCT("n_ActionDerniereRupture1");

  /* Si S/P a ratio pour le segment/exercice et segment renseigne */
  if ( (Ks_Analyse == 1) && (Ks_SEGNUL == 0) ) {

    if (Kd_PA_M) {
      sprintf(sz_Ss_M, "%-.3lf", -100*Kd_SP_R*Kd_PA_M);
    }
    else {
      sprintf(sz_Ss_M, "%-.3lf", 0.0);
    }

    Ktsz_Sortie[SEGEST1_SSD_CF] = Kptsz_LigneEsclave[SEGEST1_SSD_CF];
    Ktsz_Sortie[SEGEST1_SEG_NF] = Kptsz_LigneEsclave[SEGEST1_SEG_NF];
    Ktsz_Sortie[SEGEST1_UWY_NF] = Kptsz_LigneEsclave[SEGEST1_UWY_NF];
    Ktsz_Sortie[SEGEST1_CUR_CF] = Kptsz_LigneEsclave[SEGEST1_CUR_CF];
    Ktsz_Sortie[SEGEST1_SEGNAT_CT] = Kptsz_LigneEsclave[SEGEST1_SEGNAT_CT];
    Ktsz_Sortie[SEGEST1_Ss_M] = sz_Ss_M;
    Ktsz_Sortie[SEGEST1_SP_R] = sz_SP_R;
    Ktsz_Sortie[SEGEST1_SP_CT] = sz_SP_CT;
    Ktsz_Sortie[8] = NULL;

    /* Ecriture du fichier en sortie */
    n_WriteCols(Kp_OutputFile, Ktsz_Sortie, '~', 0);
  }

  /* Si S/P a sinistre pour le segment/exercice et segment renseigne */
  else if ( (Ks_Analyse == 0) && (Ks_SEGNUL == 0) ) {

    /* Recopie simple du montant actuel du segment */
    sprintf(sz_Ss_M, "%-.3lf", atof(Kptsz_LigneEsclave[SEGEST1_Ss_M]));
    Kptsz_LigneEsclave[SEGEST1_Ss_M] = sz_Ss_M;

    /* Ecriture du fichier en sortie */
    n_WriteCols(Kp_OutputFile, Kptsz_LigneEsclave, '~', 0);
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

  if ( (Ks_Analyse == 1) && (Ks_SEGNUL == 0) ) {

    /* Pour debuggage */
    /*printf ("SSD : %s ; UWY : %d ; INITIAL CUR : %s ; FINAL CUR %s ; Taux %lf ; Montant : %lf\n",
      Kptsz_LigneEsclave[SEGEST1_SSD_CF], Kn_BALSHTYEA, ptsz_LigneCour[CASEACT_EGPCUR_CF],
      Kptsz_LigneEsclave[SEGEST1_CUR_CF], Kd_Taux, Kd_PADevise_M); */

    Kd_Taux = d_GetTaux(Kp_GetTaux,
			(unsigned char)atoi(Kptsz_LigneEsclave[SEGEST1_SSD_CF]),
			Kn_BALSHTYEA, ptsz_LigneCour[CASEACT_EGPCUR_CF],
			Kptsz_LigneEsclave[SEGEST1_CUR_CF]);

    /* Generation d'une anomalie quand la fonction de taux renvoie 0 */
    if (Kd_Taux == -1) {

      sprintf (Ksz_MessageErr, "SSD : %s ; UWY : %d ; INITIAL CUR : %s ; FINAL CUR %s",
	       Kptsz_LigneEsclave[SEGEST1_SSD_CF], Kn_BALSHTYEA,
	       ptsz_LigneCour[CASEACT_EGPCUR_CF], Kptsz_LigneEsclave[SEGEST1_CUR_CF]);
      n_WriteAno(Ksz_MessageErr);
    }

    Kd_PA_M = Kd_PA_M + Kd_PADevise_M * Kd_Taux;
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

  if ((ret = strcmp(ptsz_LigneMaitre[CASEACT_SEG_NF], ptsz_LigneEsclave[SEGEST1_SEG_NF]))) {
    return ret;
  }
  return (strcmp(ptsz_LigneMaitre[CASEACT_UWY_NF], ptsz_LigneEsclave[SEGEST1_UWY_NF]));
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

  Kptsz_LigneEsclave = ptsz_LigneEsclave;
  if (*ptsz_LigneEsclave[SEGEST1_SP_CT] == 'S') {
    Ks_Analyse = 0;
  }
  else {
    Ks_Analyse = 1;
    Kd_SP_R = atof(ptsz_LigneEsclave[SEGEST1_SP_R]);
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

  /* Si le segment/exercice de l'affaire n'est pas trouve dans FSEGEST, on */
  /* n'ecrit pas de ligne en sortie */
  Ks_SEGNUL = 1;

  sprintf (Ksz_MessageErr, "SEG %s, UWY %s has no estimates in database",
	   ptsz_LigneMaitre[CASEACT_SEG_NF],
	   ptsz_LigneMaitre[CASEACT_UWY_NF]
	   );

  n_WriteAno(Ksz_MessageErr);

  RETURN_VAL(OK);
}
