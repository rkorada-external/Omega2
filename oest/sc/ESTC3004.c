/*==============================================================================
 Nom de l'application          : Loader programs V2
 Nom du source                 : ESTC3004.c
 Revision                      : $Revision: 1.16 $
 Date de creation              : 09/01/2012
 Auteur                        : gensource v2.0 (auto)
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :
   Loader programs V2
------------------------------------------------------------------------------
 Historique des modifications :
[01]  01/06/2012 	-=Dch=-  :spot:23937 SOLVENCY II
[02]  23/10/2012 	Florent  :spot:24041 SOLVENCY II
[03]  19/05/2016 Florent :spot:30543 on passe à 65 années
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <math.h>
#include "ESTC3001.h"

T_RUPTURE_VAR Kbd_ruptRfrBatchIN;
FILE *Kp_OutputPATERNSII;

/*--------------------------------------------------*/
/* Prototype des fonctions							*/
/*--------------------------------------------------*/
int n_InitRfrBatchIN(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLigneRfrBatchIN(char **pbd_InRec_Cur);

char *Ktp_FPATTERNSII[PAT_NBCOL + 1]; //tableau de pointeurs sur les colonnes à écrire dans le fichier de sortie +1 colonne à null pour marquer la fin
char  Ksz_annees[PATTERNSII_ANNEES][TAILLE_PATTERNSII_TAUX]; //les taux à calculer

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
  char  sz_CRE_D[22] ;      // Passé en paramètre
  char  sz_USER_CF[5];
  int   i_an;

  // Initialisation des signaux
  InitSig();

  if (n_BeginPgm(argc, argv) == ERR) ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_BeginPGM.");

  memset(sz_CRE_D,0,sizeof(sz_CRE_D));
  strncpy(sz_CRE_D,psz_GetCharArgv(1),sizeof(sz_CRE_D));

  memset(sz_USER_CF,0,sizeof(sz_USER_CF));
  strncpy(sz_USER_CF,psz_GetCharArgv(2),sizeof(sz_USER_CF));
  
  memset(Ktp_FPATTERNSII,0,sizeof(Ktp_FPATTERNSII));
  //initialisation du tableau de pointeurs avec les valeurs qui ne changeront pas dans le programme
  Ktp_FPATTERNSII[PAT_SSD_CF] = "";
  Ktp_FPATTERNSII[PAT_PATCAT_CT] = PATCAT_BAD_DEBT;
  Ktp_FPATTERNSII[PAT_PATTYP_CT] = PATTYP_BDT_RAT;
  Ktp_FPATTERNSII[PAT_SEG_NF] = "";
  Ktp_FPATTERNSII[PAT_UWY_NF] = "";
  Ktp_FPATTERNSII[PAT_CUR_CF] = "";
  Ktp_FPATTERNSII[PAT_LOB_CF] = "";
  Ktp_FPATTERNSII[PAT_SEGNAT_CT] = "";
  Ktp_FPATTERNSII[PAT_BALSHEY_NF] = "";
  Ktp_FPATTERNSII[PAT_PATTERN_ID] = "";
  Ktp_FPATTERNSII[PAT_CRE_D] = sz_CRE_D;
  Ktp_FPATTERNSII[PAT_CREUSR_CF] = sz_USER_CF;
  Ktp_FPATTERNSII[PAT_TOTAUX] = "";
  for(i_an = 0; i_an < PATTERNSII_ANNEES; i_an++)
  {
    Ktp_FPATTERNSII[PAT_AN1 + i_an] = Ksz_annees[i_an];
  }
  
  // Ouverture des fichiers binaires et des fichiers de sortie
  if (n_OpenFileAppl("ESTC3004_O1", "wt", &Kp_OutputPATERNSII)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier d'output." );

  // Initialisation des variables de gestion de ruptures
  if (n_InitRfrBatchIN(&Kbd_ruptRfrBatchIN)) ExitPgm(ERR_XX, "Problème lors de l'exécution de la méthode n_InitRfrBatchIN");

  if (n_ProcessingRuptureVar(&Kbd_ruptRfrBatchIN) != OK) ExitPgm(ERR_XX, "Erreur lors du traitement ligne à ligne." );

  // Fermeture des fichiers ouverts
  if (n_CloseFileAppl("ESTC3004_I1", &(Kbd_ruptRfrBatchIN.pf_InputFil)))  ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier d'input.");

  if (n_CloseFileAppl("ESTC3004_O1", &Kp_OutputPATERNSII))          ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier d'output.");

  if (n_EndPgm() == ERR) ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_EndPgm.");

  exit(OK);
}

/*==============================================================================
 Objet :            Initialisation de la variable de gestion de rupture (Maitre)
 Parametre(s) :     Pointeur sur une structure T_RUPTURE_VAR
 Retour :           En cas de probleme retourne ERR
                    sinon retourne OK
==============================================================================*/
int n_InitRfrBatchIN(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

  if (n_OpenFileAppl("ESTC3004_I1", "rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture   = 0;
  pbd_Rupt->n_ActionLigne = n_ActionLigneRfrBatchIN;
  pbd_Rupt->c_Separ       = SEPARATEUR;

  return OK;
}

/*==============================================================================
 Objet :            Fonction lancee pour chaque ligne du Maitre
 Parametre(s) :     Pointeur sur la ligne courante
 Retour :           En cas de probleme retourne ERR
                    sinon retourne OK
==============================================================================*/
int n_ActionLigneRfrBatchIN(char **ptb_InRec_Cur)
{
  double  d_DefaultProb;
  double  d_RecoveryRate;
  int     i_an;

  DEBUT_FCT("n_ActionLigneRfrBatchIN");

  // Récupération des valeurs en entrée
  d_DefaultProb  = atof(ptb_InRec_Cur[RATSII_DEFPROB_R]);
  d_RecoveryRate = atof(ptb_InRec_Cur[RATSII_RECOVRAT_R]);

  memset(Ksz_annees,0,sizeof(Ksz_annees));
  // Pour chaque année i de la ligne courante, le taux recherché vaut: Default probability x ((1 - Default probability) puissance i-1) x (1 - recovery rate)
  for(i_an = 1; i_an <= PATTERNSII_ANNEES; i_an++)
  {
    snprintf(Ksz_annees[i_an - 1], sizeof(Ksz_annees[i_an - 1]), "%.8f", d_DefaultProb * pow(1 - d_DefaultProb, i_an - 1) * (1 - d_RecoveryRate));
  }
  Ktp_FPATTERNSII[PAT_RATING_CF] = ptb_InRec_Cur[RATSII_RATING_CF];
  Ktp_FPATTERNSII[PAT_NORME_CF] = ptb_InRec_Cur[RATSII_NORME_CF];

  n_WriteCols(Kp_OutputPATERNSII, Ktp_FPATTERNSII, SEPARATEUR, 0);
  return OK;
}
