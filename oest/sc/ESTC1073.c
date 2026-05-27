/*==============================================================================
 Nom de l'application          : Loader programs V2
 Nom du source                 : ESTC1073.c
 Revision                      : $Revision: 1.16 $
 Date de creation              : 15/06/2015
 Auteur                        : -=Dch=-
 References des specifications : EST49 - ULAE Design
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description : Ratios ULAE appliqués aux montants des aggrégats
------------------------------------------------------------------------------
 Historique des modifications :
________________
MODIFICATION
    Auteur:         Date:           ref:        Description:
[01]  -=Dch=-    15/06/2015    :spot:28941   SOLVENCY II - ULAE
[02] Florent   07/06/2016 :spot:30543 on passe à 65 années
[03] 09/12/2020 JYP : SPIRA 92241 : add ACMTRSL3_NT into DSC_CLM file
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <util.h>
#include <stdarg.h>
#include "estserv.h"
#include "ESTC3001.h"

#define TRACE_1

/*------------*/
/* Constantes */
/*------------*/

#define SEPARATOR   "~"

T_RUPTURE_VAR       *pbd_Rupture; /* Pointeur sur la structure de la rupture   */
T_RUPTURE_SYNC_VAR  *pbd_Sync; /* Pointeur sur la structure de synchronisation */

// Variable de fichiers d'entree
FILE *Kp_InputEscompte;
FILE *Kp_InputCumul;

// Variable de fichiers de sortie
FILE *Kp_OutputBatch;
FILE *Kp_OutputBatchAno;

/*--------------------------------------------*
*   Fonctions du fichier d'aggregat
*--------------------------------------------*/

//double roundNAfterCote(double x, unsigned int digits);
int n_InitRupture  (T_RUPTURE_VAR  *pbd_Rupture);
int n_TestRupture  (char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionPremiereRupture(char *ptsz_LigneCour[]);
int n_InitSync(T_RUPTURE_SYNC_VAR  *pbd_Sync);
int n_ConditionSync(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ActionLigneSync (char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);

/*--------------------------------------------*
*   Variable globale
*--------------------------------------------*/

int LastSync ; // flag de dernière synchro
double ratioCumule; // total du ration par synchro

/*==============================================================================
 Objet :
   Point d'entree du programme

 Parametre(s) :
   int argc    : Nombre d'arguments sur la ligne de commande;
   char **argv : parametres

 Retour :
   En cas de probleme, sortie par ExitPgm(ERRCODE)
   sinon appel systeme exit(OK)
==============================================================================*/
int main(int argc, char **argv)
{
  pbd_Rupture = malloc(sizeof(T_RUPTURE_VAR));
  pbd_Sync = malloc(sizeof(T_RUPTURE_SYNC_VAR));

  // Initialisation des signaux
  InitSig () ;

  if (n_BeginPgm(argc, argv) == ERR) ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_BeginPGM.");

  // Ouverture des fichiers binaires et des fichiers de sortie
  if (n_OpenFileAppl("ESTC1073_O1", "wt", &Kp_OutputBatch) == ERR ) ExitPgm(ERR_XX, "Problème lors de l'ouverture 1er fichier (cumul)." );
  if (n_OpenFileAppl("ESTC1073_O2", "wt", &Kp_OutputBatchAno) == ERR ) ExitPgm(ERR_XX, "Problème lors de l'ouverture 1er fichier ano " );
  // Initialisation des variables de gestion de ruptures
  if (n_InitRupture(pbd_Rupture) == ERR ) ExitPgm(ERR_XX, "Problème lors de l'exécution de la méthode pdb_Rupture");
  // Initialisation de la structure de synchronisation
  if (n_InitSync(pbd_Sync) == ERR) ExitPgm(ERR_XX, "Erreur appel fonction n_InitSync");

  /* Lancement du traitement du fichier maitre */
  if (n_ProcessingRuptureVar(pbd_Rupture) == ERR) ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");

  // Fermeture des fichiers ouverts
  if (n_CloseFileAppl("ESTC1073_I2", &(pbd_Rupture->pf_InputFil)) == ERR) ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier d'escompte.");
  if (n_CloseFileAppl("ESTC1073_I1", &(pbd_Sync->pf_InputFil)) == ERR) ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier de cumul.");
  if (n_CloseFileAppl("ESTC1073_O1", &Kp_OutputBatch) == ERR) ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier de cumul.");
  if (n_CloseFileAppl("ESTC1073_O2", &Kp_OutputBatchAno) == ERR) ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier ano ");
  if (n_EndPgm() == ERR) ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_EndPgm.");

  // libération mémoire
  free(pbd_Rupture);
  free(pbd_Sync);

  exit(OK);
}

/**************************************************************************/
/*** Objet : initialisation de la structure de rupture      ***/
/***                  ***/
/*** Nom : n_InitRupture                ***/
/***                  ***/
/*** Parametres:              ***/
/***  i pbd_Rupture : pointeur sur la structure de rupture    ***/
/***                  ***/
/*** Retour:                ***/
/***  OK si pas d'erreur,           ***/
/***  ERR si erreur.              ***/
/**************************************************************************/
int n_InitRupture(
  T_RUPTURE_VAR *pbd_Rupture
)
{
  DEBUT_FCT("n_InitRupture");
  memset(pbd_Rupture, 0, sizeof(T_RUPTURE_VAR));

  /* Ouverture du fichier maitre */
  if (n_OpenFileAppl("ESTC1073_I2", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
    RETURN_VAL(ERR);
  }
  pbd_Rupture->n_NbRupture = 1;
  pbd_Rupture->n_ConditionRupture[0] = n_TestRupture;
  pbd_Rupture->n_ActionFirst[0] = n_ActionPremiereRupture;
  pbd_Rupture->c_Separ = '~';

  RETURN_VAL(OK);
}

/**************************************************************************/
/*** Objet : initialisation de la synchronisation du maitre avec  ***/
/***         l'esclave                                                  ***/
/***                  ***/
/*** Nom : n_InitSync                 ***/
/***                  ***/
/*** Parametres:              ***/
/***  i pbd_Sync : pointeur sur la structure de synchro   ***/
/***                  ***/
/*** Retour:                ***/
/***  OK si pas d'erreur,           ***/
/***  ERR si erreur.              ***/
/**************************************************************************/
int n_InitSync(
  T_RUPTURE_SYNC_VAR  *pbd_Sync
)
{
  DEBUT_FCT("n_InitSync");
  memset(pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR));

  /* Ouverture du fichier esclave */
  if (n_OpenFileAppl("ESTC1073_I1", "rt", &(pbd_Sync->pf_InputFil)) == ERR) {
    RETURN_VAL(ERR);
  }
  pbd_Sync->n_NbRupture = 1;
  pbd_Sync->n_ConditionRupture[0] = n_ConditionSync;
  pbd_Sync->ConditionEndSync = n_ConditionSync;
  pbd_Sync->n_ActionLigne = n_ActionLigneSync;
  pbd_Sync->c_Separ = '~';

  RETURN_VAL(OK);
}

/**************************************************************************/
/*** Objet : fonction de test de rupture        ***/
/***                  ***/
/*** Nom : n_TestRupture                ***/
/***                  ***/
/*** Parametres:              ***/
/***  i ptsz_LineSuiv : pointeur sur la ligne suivante,   ***/
/***  i ptsz_LineCour : pointeur sur la ligne precedente.   ***/
/***                  ***/
/*** Retour:                ***/
/***  0 si pas de rupture,            ***/
/***  1 si rupture.             ***/
/**************************************************************************/
int n_TestRupture(
  char *ptsz_LigneSuiv[],
  char *ptsz_LigneCour[]
)
{
  static short s_ret;

  DEBUT_FCT("n_TestRupture");

  s_ret = strcmp(ptsz_LigneSuiv[CML_SEGMENT_LE], ptsz_LigneCour[CML_SEGMENT_LE]);
  if (s_ret)
    return s_ret;

  s_ret = strcmp(ptsz_LigneSuiv[CML_SEGMENT_SII], ptsz_LigneCour[CML_SEGMENT_SII]);
  if (s_ret)
    return s_ret;

  RETURN_VAL (strcmp(ptsz_LigneSuiv[CML_NORME_CF], ptsz_LigneCour[CML_NORME_CF]));
}

/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne en rupture premiere du   ***/
/***         fichier maitre           ***/
/***                  ***/
/*** Nom : n_ActionPremiereRupture          ***/
/***                  ***/
/*** Parametres:              ***/
/***  i ptsz_LigneCour : pointeur sur la ligne courante   ***/
/***                  ***/
/*** Retour:                ***/
/***  OK si pas d'erreur,           ***/
/***  ERR si erreur.              ***/
/**************************************************************************/
int n_ActionPremiereRupture(char *ptsz_LigneCour[])
{
  DEBUT_FCT("n_ActionPremiereRupture");

  /* Synchronisation avec le fichier esclave à chaque rupture */
  n_ProcessingRuptureSyncVar(pbd_Sync, ptsz_LigneCour);

  RETURN_VAL(OK);
}

/**************************************************************************/
/*** Objet : synchronisation maitre esclave       ***/
/***                  ***/
/*** Nom : n_ConditionSync            ***/
/***                  ***/
/*** Parametres:              ***/
/***  i ptsz_LigneMaitre  : pointeur sur la ligne du maitre   ***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave  ***/
/***                  ***/
/*** Retour:                ***/
/***  0 si synchronise,           ***/
/***  <0 si la ligne esclave est depassee,        ***/
/***    >0 si la ligne esclave n'est pas depassee.      ***/
/**************************************************************************/
int n_ConditionSync(
  char *ptsz_LigneMaitre[],
  char *ptsz_LigneEsclave[]
)
{
  static short s_ret;

  DEBUT_FCT("n_ConditionSync");

  s_ret = strcmp(ptsz_LigneMaitre[CML_SEGMENT_LE], ptsz_LigneEsclave[CML_SEGMENT_LE]);
  if (s_ret != 0)
    return s_ret;

  s_ret = strcmp(ptsz_LigneMaitre[CML_SEGMENT_SII], ptsz_LigneEsclave[CML_SEGMENT_SII]);
  if (s_ret != 0)
    return s_ret;

  RETURN_VAL(strcmp(ptsz_LigneMaitre[CML_NORME_CF], ptsz_LigneEsclave[CML_NORME_CF]));
}

/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne de l'esclave   ***/
/***                  ***/
/*** Nom : n_ActionLigneSync            ***/
/***                  ***/
/*** Parametres:              ***/
/***  i ptsz_LigneMaitre  : pointeur sur la ligne du maitre,    ***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave.       ***/
/***                  ***/
/*** Retour:                ***/
/***  OK si pas d'erreur,           ***/
/***  ERR si erreur.              ***/
/**************************************************************************/
int n_ActionLigneSync(
  char *ptsz_LigneMaitre[],
  char *ptsz_LigneEsclave[]
)
{
  double acmamt, CurrCumul;
  // pour la sortie des ratios
  char sz_ratio_acmamt[25] ;
  char flag_ano ;

  acmamt = 0.0;
  CurrCumul = 0.0;
  flag_ano = 'N';

  DEBUT_FCT("n_ActionLigneSync");

  // si c'est la dernière synchro , on met juste le reliquat , sinon , on calcul le ratio

  if (pbd_Sync->b_L[0]) // last syncro
  {
    sprintf(sz_ratio_acmamt , "%-.8f", (1 - ratioCumule));
    ratioCumule = 0.0;
  }
  else
  {
    CurrCumul = atof(ptsz_LigneMaitre[CML_AMT_EURO]);
    acmamt = atof(ptsz_LigneEsclave[CML_AMT_EURO]);
    if ( fabs(CurrCumul) > 0.0001)
         sprintf(sz_ratio_acmamt , "%-.8f", (double)(acmamt / CurrCumul));
    else
    {
         sprintf(sz_ratio_acmamt , "%-.8f", 0.0 );
         flag_ano = 'Y';
    } 
    ratioCumule += atof(sz_ratio_acmamt);
  }

  ptsz_LigneEsclave[CML_TOTAUX_MC] = ptsz_LigneEsclave[CML_AMT_EURO] ;
  ptsz_LigneEsclave[CML_COMMENT] = ptsz_LigneMaitre[CML_AMT_EURO] ;
  // on remplace le montant en euro par le ratio
  ptsz_LigneEsclave[CML_AMT_EURO] = sz_ratio_acmamt ;

  /* Ecriture du fichier regroupement des contrats en sortie */
    if ( flag_ano == 'N' )
       n_WriteCols(Kp_OutputBatch, ptsz_LigneEsclave, '~', 0);
    else
       n_WriteCols(Kp_OutputBatchAno, ptsz_LigneEsclave, '~', 0);

  RETURN_VAL(OK);
}
