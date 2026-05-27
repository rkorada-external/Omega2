/*==============================================================================
 Nom de l'application          : Calcul des courbes de taux inflation
 Nom du source                 : ESTC3005.c
 Revision                      : $Revision: 1.0 $
 Date de creation              : 15/07/2015
 Auteur                        : Florent
 References des specifications : :spot:28941
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :
   Calcul des courbes de taux inflation
------------------------------------------------------------------------------
Historique des modifications :
[01] 19/05/2016 Florent :spot:30543 on passe à 65 années
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include "ESTC3001.h"

/*--------------------------------------------------*/
/* Prototype des fonctions							*/
/*--------------------------------------------------*/
int n_InitFichierIN(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLigneFichierIN(char **pbd_InRec_Cur);

/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*---------------------------------------------*/

T_RUPTURE_VAR Kbd_ruptFichierIN;
FILE *Kp_OutputFichierOUT;
FILE *Kp_OutputTraceOut;

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
  // Initialisation des signaux
  InitSig () ;

  if (n_BeginPgm(argc, argv) == ERR) ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_BeginPGM.");

  // Ouverture des fichiers binaires et des fichiers de sortie
  if (n_OpenFileAppl("ESTC3005_O1", "wt", &Kp_OutputFichierOUT)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier d'output." );
  if (n_OpenFileAppl("ESTC3005_O2", "wt", &Kp_OutputTraceOut)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier d'output(TRACE SEG)." );

  // Initialisation des variables de gestion de ruptures
  if (n_InitFichierIN(&Kbd_ruptFichierIN)) ExitPgm(ERR_XX, "Problème lors de l'exécution de la méthode n_InitFichierIN");

  if (n_ProcessingRuptureVar(&Kbd_ruptFichierIN) != OK) ExitPgm(ERR_XX, "Erreur lors du traitement ligne à ligne." );

    // Fermeture des fichiers ouverts
  if (n_CloseFileAppl("ESTC3005_I1", &(Kbd_ruptFichierIN.pf_InputFil)))  ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier d'input.");

  if (n_CloseFileAppl("ESTC3005_O1", &Kp_OutputFichierOUT)) ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier d'output.");
  if (n_CloseFileAppl("ESTC3005_O2", &Kp_OutputTraceOut)) ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier d'output(TRACESEG)\n.");

  if (n_EndPgm() == ERR) ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_EndPgm.");

  exit(OK);
}

/*==============================================================================
 Objet :            Initialisation de la variable de gestion de rupture (Maitre)
 Parametre(s) :     Pointeur sur une structure T_RUPTURE_VAR
 Retour :           En cas de probleme retourne ERR
                    sinon retourne OK
==============================================================================*/
int n_InitFichierIN(T_RUPTURE_VAR  *pbd_Rupt)
{
     memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

     if (n_OpenFileAppl("ESTC3005_I1", "rt", &(pbd_Rupt->pf_InputFil)))
          return ERR;

     pbd_Rupt->n_NbRupture   = 0;
     pbd_Rupt->n_ActionLigne = n_ActionLigneFichierIN;
     pbd_Rupt->c_Separ       = SEPARATEUR;

     return OK;
}

/*==============================================================================
 Objet :            Fonction lancee pour chaque ligne du Maitre
 Parametre(s) :     Pointeur sur la ligne courante
 Retour :           En cas de probleme retourne ERR
                    sinon retourne OK
==============================================================================*/
int n_ActionLigneFichierIN(char **ptb_InRec_Cur)
{
  char    sz_annees[PATTERNSII_ANNEES][TAILLE_PATTERNSII_TAUX];
  double  d_arrondi=0, d_taux=0;
  int     i_an;

  DEBUT_FCT("n_ActionLigneFichierIN");

   memset(sz_annees, 0, sizeof(sz_annees));

  //on utilise le tableau de pointeur de la ligne courante pour la sortie du fichier

  // calculs des taux
  for(i_an = 0; i_an < PATTERNSII_ANNEES; i_an++)
  {
    d_taux = atof(ptb_InRec_Cur[PAT_AN1 + i_an]);
    //l'index i_an commence à zéro mais l'année doit commencer à 1
    //(1 + INF)^(année – 0.5)
    d_taux = pow(1.0 + d_taux, i_an + 1 - 0.5);
    d_arrondi = 0;
    if (d_taux != 0 )
    {
      if (d_taux < 0)
      {
        d_arrondi = (long) ((d_taux * 100000000) - 0.5) ;
      }
      else
        d_arrondi = (long) ((d_taux * 100000000) + 0.5) ;
    }

    snprintf(sz_annees[i_an],TAILLE_PATTERNSII_TAUX,"%.8f",(d_arrondi != 0) ? (double) (d_arrondi / 100000000 ) : 0);
    //maj pour l'enregistrement en sortie
    ptb_InRec_Cur[PAT_AN1 + i_an] = sz_annees[i_an];
  }

  //maj du PATTYP_CT de pattern en sortie
  ptb_InRec_Cur[PAT_PATTYP_CT] = PATTYP_INFLATIONCALC;
  n_WriteCols( Kp_OutputFichierOUT, ptb_InRec_Cur, SEPARATEUR, 0 );

  //maj des pointeurs pour mettre les infos du fichier trace
  // on utilise des zone modifiées pour le fichier BEST..TPATSEGSII
  ptb_InRec_Cur[PAT_RATING_CF] = PATTYP_INFLATION; //ORIPATTYP_CT
  ptb_InRec_Cur[PAT_UWY_NF] = PER_CF_NEW; //PER_CF
  n_WriteCols( Kp_OutputTraceOut, ptb_InRec_Cur, SEPARATEUR, 16, PAT_CRE_D,PAT_UWY_NF,PAT_SSD_CF,PAT_SEG_NF
              ,PAT_LOB_CF,PAT_CUR_CF,PAT_NORME_CF,PAT_SEGNAT_CT,PAT_PATCAT_CT,PAT_PATTYP_CT,PAT_PATTERN_ID,PAT_PATCAT_CT
              ,PAT_RATING_CF,PAT_PATTERN_ID,PAT_CREUSR_CF,PAT_CRE_D);

    return OK;
}
