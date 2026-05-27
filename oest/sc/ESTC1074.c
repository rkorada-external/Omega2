/*==============================================================================
 Nom de l'application          : Loader programs V2
 Nom du source                 : ESTC1074.c
 Revision                      : $Revision: 1.16 $
 Date de creation              : 23/06/2015
 Auteur                        : -=Dch=-
 References des specifications : EST49 - Risk Margin
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description : Ratios ULAE appliqués aux montants des aggrégats
------------------------------------------------------------------------------
 Historique des modifications :
________________
MODIFICATION
    Auteur:         Date:           ref:        Description:
[01]  -=Dch=-    23/06/2015    :spot:28941   SOLVENCY II - ULAE
[02] Florent   07/06/2016 :spot:30543 on passe à 65 années
[03] Florent   05/10/2016 :spot:31302 correction: on mets à zéro de 2 à 65 années !
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <util.h>
#include <stdarg.h>
#include "estserv.h"
#include "ESTC3001.h"

/*------------*/
/* Constantes */
/*------------*/
#define SEPARATOR   "~"

T_RUPTURE_VAR       *pbd_Rupture;   /* Pointeur sur la structure de la rupture    */
T_RUPTURE_SYNC_VAR  *pbd_Sync;    /* Pointeur sur la structure de synchronisation */

// Variable de fichiers d'entree
FILE *Kp_InputRatios; // pointeur sur le ficher de sinistres
FILE *Kp_InputCURQUOT; // pointeur sur le fichier de cotation ( cours de cloture)
FILE *Kp_InputSegment;// pointeur sur le fichier de segment

// Variable de fichiers de sortie
FILE *Kp_OutputBatch;

/*--------------------------------------------*
*   Fonctions du fichier d'aggregat
*--------------------------------------------*/
int n_InitRupture  (T_RUPTURE_VAR  *pbd_Rupture);
int n_InitSync(T_RUPTURE_SYNC_VAR  *pbd_Sync);
int n_ConditionSync(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ActionLigneSync(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_TestRupture(char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionLignePerCSU(char *ptsz_LigneCour[]);
// fonction de suppression d'espace dans une chaine de caractère
char *LeftTrim(char *s);

/*************************************
*
*    Variables globales
*
***************************************/
int Annee_Bilan; // fournit en paramètre au prog

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
  /* arguments passés au programme */
  Annee_Bilan = n_GetIntArgv(1);

  // Ouverture des fichiers binaires et des fichiers de sortie
  /* ouverture du fichier en entree des cours de change FCURQUOT */
  if ( n_OpenFileAppl ( "ESTC1074_I3", "rb", &Kp_InputCURQUOT ) == ERR ) ExitPgm( ERR_XX , "Problème lors de l'ouverture du fichier de cotation" );
  if (n_OpenFileAppl("ESTC1074_O1", "wt", &Kp_OutputBatch) == ERR ) ExitPgm(ERR_XX, "Problème lors de l'ouverture 1er fichier (cumul)." );
  // Initialisation des variables de gestion de ruptures
  if (n_InitRupture(pbd_Rupture) == ERR ) ExitPgm(ERR_XX, "Problème lors de l'exécution de la méthode pdb_Rupture");
  // Initialisation de la structure de synchronisation
  if (n_InitSync(pbd_Sync) == ERR) ExitPgm(ERR_XX, "Erreur appel fonction n_InitSync");

  /* Lancement du traitement du fichier maitre */
  if (n_ProcessingRuptureVar(pbd_Rupture) == ERR) ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");

  // Fermeture des fichiers ouverts
  if ( n_CloseFileAppl ( "ESTC1074_I3", &Kp_InputCURQUOT ) == ERR ) ExitPgm( ERR_XX , "Problème lors de la fermeture du fichier de cotation" );
  if (n_CloseFileAppl("ESTC1074_I2", &(pbd_Rupture->pf_InputFil)) == ERR) ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier d'ULAE.");
  if (n_CloseFileAppl("ESTC1074_I1", &(pbd_Sync->pf_InputFil)) == ERR) ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier de cumul.");
  if (n_CloseFileAppl("ESTC1074_O1", &Kp_OutputBatch) == ERR) ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier de cumul.");
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
  if (n_OpenFileAppl("ESTC1074_I2", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
    RETURN_VAL(ERR);
  }
  pbd_Rupture->n_NbRupture = 0;
  pbd_Rupture->n_ActionLigne = n_ActionLignePerCSU;
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
  if (n_OpenFileAppl("ESTC1074_I1", "rt", &(pbd_Sync->pf_InputFil)) == ERR) {
    RETURN_VAL(ERR);
  }
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

  s_ret = strcmp(ptsz_LigneSuiv[RSKM_LE_SEGMENT_NF], ptsz_LigneCour[RSKM_LE_SEGMENT_NF]);
  if (s_ret)
    return s_ret;

  s_ret = strcmp(ptsz_LigneSuiv[RSKM_SII_SEGMENT_NF], ptsz_LigneCour[RSKM_SII_SEGMENT_NF]);
  if (s_ret)
    return s_ret;

  RETURN_VAL (strcmp(ptsz_LigneSuiv[RSKM_NORME_CF], ptsz_LigneCour[RSKM_NORME_CF]));
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
int n_ActionLignePerCSU(char *ptsz_LigneCour[])
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
  static short ret;

  DEBUT_FCT("n_ConditionSync");

  if ( (ret = strcmp(LeftTrim(ptsz_LigneMaitre[RSKM_LE_SEGMENT_NF]), LeftTrim(ptsz_LigneEsclave[CML_SEGMENT_LE]))) != 0 )    RETURN_VAL(ret);
  if ( (ret = strcmp(LeftTrim(ptsz_LigneMaitre[RSKM_SII_SEGMENT_NF]), LeftTrim(ptsz_LigneEsclave[CML_SEGMENT_SII]))) != 0 )    RETURN_VAL(ret);
  if ( (ret = strcmp(LeftTrim(ptsz_LigneMaitre[RSKM_NORME_CF]), LeftTrim(ptsz_LigneEsclave[CML_NORME_CF]))) != 0 )    RETURN_VAL(ret);
  RETURN_VAL(0);
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
  DEBUT_FCT("n_ActionLigneSync");
  int n_index;
  double CurrencyRatio, ACMAMT ;
  char Currency[4], sz_AcmAmt[25], sz_amt[25];
  char MsgAno[300];  /* message anomalie*/

  memset(Currency, 0, sizeof(Currency));
  memset (sz_AcmAmt, 0 , sizeof(sz_AcmAmt));
  memset (sz_amt, 0 , sizeof(sz_amt));

  ACMAMT = atof(ptsz_LigneMaitre[RSKM_AMT_M]) * atof( ptsz_LigneEsclave[CML_RATIO]) ;// montant accept
  // calcul dans la devise du contrat
  CurrencyRatio = d_GetTaux(Kp_InputCURQUOT, (char) atoi( ptsz_LigneEsclave[CML_SSD_CF]) , Annee_Bilan, ptsz_LigneMaitre[RSKM_CUR_CF], ptsz_LigneEsclave[CML_ACMCUR_CF]);
  if (CurrencyRatio <= 0 )
  {
    sprintf( MsgAno, "The rates of currency ( %s ) is not known for the perimeter contract ( CTR %s - SEC %s - UWY %s -) and BALSHEY %i \n",
             ptsz_LigneEsclave[CML_ACMCUR_CF],
             ptsz_LigneEsclave[CML_CTR_NF],
             ptsz_LigneEsclave[CML_SEC_NF],
             ptsz_LigneEsclave[CML_UWY_NF],
             Annee_Bilan);

    n_WriteAno( MsgAno );
    return 0;
  }
  sprintf(sz_amt, "%-.3f",  ACMAMT * CurrencyRatio ); // montant d'accept en devise de contrat
  ptsz_LigneEsclave[CML_SEG_NF] = ptsz_LigneEsclave[CML_SEGMENT_LE];
  ptsz_LigneEsclave[CML_RETCTR_NF] = "\0";
  ptsz_LigneEsclave[CML_RETSEC_NF] = "\0";
  ptsz_LigneEsclave[CML_AMT_MC] = sz_amt;
  ptsz_LigneEsclave[CML_TOTAUX_MC] = sz_amt;
  ptsz_LigneEsclave[CML_AM01_MC] = sz_amt;

  //on mets à zéro l'année 2
  for (n_index = CML_AM01_MC + 1; n_index <= CML_AM_FIN; n_index++)
    ptsz_LigneEsclave[n_index] = "0";

  ptsz_LigneEsclave[CML_ACMAMT_MC] = sz_amt;
  ptsz_LigneEsclave[CML_COMMENT] = "";
  ptsz_LigneEsclave[CML_SEG_NF] = "";

  /* Ecriture du fichier regroupement des contrats en sortie */
  n_WriteCols(Kp_OutputBatch, ptsz_LigneEsclave, '~', 0);

  RETURN_VAL(OK);
}

/**************************************************************************/
/*** Objet : fonction de "trim" de caractères              ***/
/*** Nom : LeftTrim                             ***/
/*** Retourne une chaine de caractère :                  ***/
/**************************************************************************/
char *LeftTrim(char *s)
{
  char *ptr;

  if (!s)
    return (char*) NULL;   // handle NULL string

  if (!*s)
    return s;      // handle empty string
  for (ptr = s + strlen(s) - 1; (ptr >= s) && isspace(*ptr); --ptr);
  ptr[1] = '\0';
  return s;
}
