/*==============================================================================
Nom de l'application          : Rejet et reconduction du bilan precedent en
                                comptabilite
Nom du source                 : ESTM7602.c
Revision                      : $Revision: 1.3 $
Date de creation              : 19/08/1997
Auteur                        : CGI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
   On cumule les montants des lignes du GT correspondants a la clef et aux
   postes comptables specifies. Le rejet se fait par l'ecriture du
   montant oppose, la reconduction par l'ecriture du montant (pour le 1er
   janvier de l'annee suivante du libelle d'inventaire).

   Le tri est fait sur contrat acceptation/avenant acceptation/
   section acceptation/exercice acceptation/numero d'ordre acceptation/
   annee de compte acceptation/periode fin acceptation/
   periode debut acceptation/exercice de survenance acceptation/
   numero de sinistre acceptation/devise acceptation
   contrat retrocession/avenant retrocession/
   section retrocession/exercice retrocession/numero d'ordre retrocession/
   annee de compte retrocession/periode fin retrocession/
   periode debut retrocession/exercice de survenance retrocession/
   numero de sinistre retrocession/devise retrocession/code placement
   poste comptable.
------------------------------------------------------------------------------
Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
     24/01/2003   J.Ribot       ajout gestion cumul montant retro interne
     28/07/2006   JM HOFFMANN   reverse ecritures service CRP
       27/03/2008   J. Ribot      SPOT 15219  ASE15 : recompilation des programmes C
       13/01/2009   J. Ribot      rejet reconduction de lignes IFRS   SPOT16593
       29/01/2010   JF VDV        [18853] Ajout de l'etablissement dans les ruptures,avant le poste comptable (TRNCOD_CF)
                                          modification des criteres de selection des postes d'ouvertures (mis en phase avec le programme ESTM7601.c)
       18/06/2012  JF VDV      [23390] - SOLVENCY II adaptations de l'inventaire
[01]  07/10/2014  ABJ  spot:25773 Generation de lignes sur le Gaap 2/3/4/5
[02]  21/07/2015  SAS  spot:29113 récupération de TRNCOD a 8 plutot que 7
[03]  05/11/2015  RBE  spot:29646: Les ouvertures suffixes 7 (et autre suffixe)
[04]  06/11/2015  DFI  spot:29652: Correction format mois jour (01/01)
[05]  27/01/2016 Florent :spot:29066 enlever define: il est dans le struc.h
[06]  12/10/2016 Florent :spot:31344 Correction format mois/jour(1/1) et plus de strcpy dans l'ENR en entrée !
[07]  12/10/2021 MZM :   spira98240:peninng-ESTM7602 missing criteria in sort : Ajout du TRN_NT dans le critere de rupture
[08] 28/01/2022 Roger  :spira:98240 Ajout RETARDRETINT_B, GAAPCOD_NT, I17PRDCOD_CT dans la clé de rupture et code Ouverture 'O' dans col GT_NEWCOLS5_NF
======================================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <utctlib.h>
#include <stdarg.h>
#include "struct.h"

/*----------------------*/
/* Variables de travail */
/*----------------------*/

FILE     *Kp_OutputFile;  /* Pointeur sur le fichier de rejet/reconduction */
T_RUPTURE_VAR *pbd_Rupture;      /* Pointeur sur la structure de la rupture */

double Kd_MontantAcc;       /* Cumul des montants acceptation */
double Kd_MontantRet;       /* Cumul des montants retrocession */
double Kd_MontantRetInt;    /* Cumul des montants retrocession interne*/
short Ks_Analyse;           /* Vaut 1 si le poste doit etre analyse, 0 autrement */
char Ksz_CLODAT_D[9];       /* Date de libelle d'inventaire */
short Ks_BLCSHMTH_NF;       /* Mois de la periode comptable */
char Ksz_Annee[5];          /* Annee de la date d'inventaire */


/*-----------------------------*/
/* Fonctions du fichier maitre */
/*-----------------------------*/

int n_InitRupture    (T_RUPTURE_VAR  *pbd_Rupture);
int n_TestRupture    (char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionPremiereRupture(char *ptsz_LigneCour[]);
int n_ActionLigneRupture   (char *ptsz_LigneCour[]);
int n_ActionDerniereRupture(char *ptsz_LigneCour[]);


/**************************************************************************/
/*** Objet : Cumul des montants                               ***/
/***                                                  ***/
/*** Nom : main                                           ***/
/***                                                  ***/
/*** Parametres:                                          ***/
/***  i argc : nombre de parametres                         ***/
/***  i argv : tableau de pointeurs sur les parametres            ***/
/***                                                  ***/
/*** Retour:                                            ***/
/***  OK si pas d'erreur,                                   ***/
/***  ERR si erreur.                                      ***/
/**************************************************************************/

int main(
  int argc,
  char *argv[]
)
{
  pbd_Rupture = malloc(sizeof(T_RUPTURE_VAR));

  /* Initialisation des signaux */
  InitSig();

  if (n_BeginPgm(argc, argv) == ERR) {
    ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");
  }

  /* Recuperation du parametre correspondant a la date libelle d'inventaire */
  strcpy(Ksz_CLODAT_D, psz_GetCharArgv(1));
  Ksz_Annee[0] = Ksz_CLODAT_D[0];
  Ksz_Annee[1] = Ksz_CLODAT_D[1];
  Ksz_Annee[2] = Ksz_CLODAT_D[2];
  Ksz_Annee[3] = Ksz_CLODAT_D[3];
  Ksz_Annee[4] = '\0';
  sprintf(Ksz_Annee, "%d", atoi(Ksz_Annee) + 1);

  /* Recuperation du parametre correspondant au mois de la periode comptable */
  Ks_BLCSHMTH_NF = n_GetIntArgv(2);

  /* Ouverture du fichier */
  if (n_OpenFileAppl("ESTM7602_O1", "wt", &Kp_OutputFile) == ERR) {
    ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
  }

  /* Initialisation de la structure de rupture */
  if (n_InitRupture(pbd_Rupture) == ERR) {
    ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupture");
  }

  /* Lancement du traitement du fichier maitre */
  if (n_ProcessingRuptureVar(pbd_Rupture) == ERR) {
    ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
  }

  if (n_CloseFileAppl("ESTM7602_I1", &(pbd_Rupture->pf_InputFil)) == ERR) {
    ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
  }

  if (n_CloseFileAppl("ESTM7602_O1", &Kp_OutputFile) == ERR) {
    ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
  }

  if (n_EndPgm() == ERR) {
    ExitPgm(ERR_XX, "Erreur appel fonction n_EndPgm");
  }

  free(pbd_Rupture);
  exit(OK);
}


/**************************************************************************/
/*** Objet : initialisation de la structure de rupture              ***/
/***                                                  ***/
/*** Nom : n_InitRupture                                    ***/
/***                                                  ***/
/*** Parametres:                                          ***/
/***  i pbd_Rupture : pointeur sur la structure de rupture        ***/
/***                                                  ***/
/*** Retour:                                            ***/
/***  OK si pas d'erreur,                                   ***/
/***  ERR si erreur.                                      ***/
/**************************************************************************/

int n_InitRupture(
  T_RUPTURE_VAR *pbd_Rupture
)
{
  DEBUT_FCT("n_InitRupture");
  memset(pbd_Rupture, 0, sizeof(T_RUPTURE_VAR));

  /* Ouverture du fichier maitre */
  if (n_OpenFileAppl("ESTM7602_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
    RETURN_VAL(ERR);
  }
  pbd_Rupture->n_NbRupture = 1;
  pbd_Rupture->n_ConditionRupture[0] = n_TestRupture;
  pbd_Rupture->n_ActionFirst[0] = n_ActionPremiereRupture;
  pbd_Rupture->n_ActionLigne = n_ActionLigneRupture;
  pbd_Rupture->n_ActionLast[0] = n_ActionDerniereRupture;
  pbd_Rupture->c_Separ = '~';

  RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction de test de rupture                        ***/
/***                                                  ***/
/*** Nom : n_TestRupture                                    ***/
/***                                                  ***/
/*** Parametres:                                          ***/
/***  i ptsz_LineSuiv : pointeur sur la ligne suivante,           ***/
/***  i ptsz_LineCour : pointeur sur la ligne precedente.           ***/
/***                                                  ***/
/*** Retour:                                            ***/
/***  0 si pas de rupture,                                ***/
/***  1 si rupture.                                     ***/
/**************************************************************************/

int n_TestRupture(
  char *ptsz_LigneSuiv[],
  char *ptsz_LigneCour[]
)
{
  DEBUT_FCT("n_TestRupture");
  if (strcmp(ptsz_LigneSuiv[GT_CTR_NF], ptsz_LigneCour[GT_CTR_NF]) != 0) {
    RETURN_VAL(1);
  }
  if (strcmp(ptsz_LigneSuiv[GT_END_NT], ptsz_LigneCour[GT_END_NT]) != 0) {
    RETURN_VAL(1);
  }
  if (strcmp(ptsz_LigneSuiv[GT_SEC_NF], ptsz_LigneCour[GT_SEC_NF]) != 0) {
    RETURN_VAL(1);
  }
  if (strcmp(ptsz_LigneSuiv[GT_UWY_NF], ptsz_LigneCour[GT_UWY_NF]) != 0) {
    RETURN_VAL(1);
  }
  if (strcmp(ptsz_LigneSuiv[GT_UW_NT], ptsz_LigneCour[GT_UW_NT]) != 0) {
    RETURN_VAL(1);
  }
  if (strcmp(ptsz_LigneSuiv[GT_ACY_NF], ptsz_LigneCour[GT_ACY_NF]) != 0) {
    RETURN_VAL(1);
  }
  if (strcmp(ptsz_LigneSuiv[GT_SCOENDMTH_NF], ptsz_LigneCour[GT_SCOENDMTH_NF]) != 0) {
    RETURN_VAL(1);
  }
  if (strcmp(ptsz_LigneSuiv[GT_SCOSTRMTH_NF], ptsz_LigneCour[GT_SCOSTRMTH_NF]) != 0) {
    RETURN_VAL(1);
  }
  if (strcmp(ptsz_LigneSuiv[GT_OCCYEA_NF], ptsz_LigneCour[GT_OCCYEA_NF]) != 0) {
    RETURN_VAL(1);
  }
  if (strcmp(ptsz_LigneSuiv[GT_CLM_NF], ptsz_LigneCour[GT_CLM_NF]) != 0) {
    RETURN_VAL(1);
  }
  if (strcmp(ptsz_LigneSuiv[GT_CUR_CF], ptsz_LigneCour[GT_CUR_CF]) != 0) {
    RETURN_VAL(1);
  }

  if (strcmp(ptsz_LigneSuiv[GT_RETCTR_NF], ptsz_LigneCour[GT_RETCTR_NF]) != 0) {
    RETURN_VAL(1);
  }
  if (strcmp(ptsz_LigneSuiv[GT_RETEND_NT], ptsz_LigneCour[GT_RETEND_NT]) != 0) {
    RETURN_VAL(1);
  }
  if (strcmp(ptsz_LigneSuiv[GT_RETSEC_NF], ptsz_LigneCour[GT_RETSEC_NF]) != 0) {
    RETURN_VAL(1);
  }
  if (strcmp(ptsz_LigneSuiv[GT_RTY_NF], ptsz_LigneCour[GT_RTY_NF]) != 0) {
    RETURN_VAL(1);
  }
  if (strcmp(ptsz_LigneSuiv[GT_RETUW_NT], ptsz_LigneCour[GT_RETUW_NT]) != 0) {
    RETURN_VAL(1);
  }
  if (strcmp(ptsz_LigneSuiv[GT_RETACY_NF], ptsz_LigneCour[GT_RETACY_NF]) != 0) {
    RETURN_VAL(1);
  }
  if (strcmp(ptsz_LigneSuiv[GT_RETSCOENDMTH_NF], ptsz_LigneCour[GT_RETSCOENDMTH_NF]) != 0) {
    RETURN_VAL(1);
  }
  if (strcmp(ptsz_LigneSuiv[GT_RETSCOSTRMTH_NF], ptsz_LigneCour[GT_RETSCOSTRMTH_NF]) != 0) {
    RETURN_VAL(1);
  }
  if (strcmp(ptsz_LigneSuiv[GT_RETOCCYEA_NF], ptsz_LigneCour[GT_RETOCCYEA_NF]) != 0) {
    RETURN_VAL(1);
  }
  if ( strcmp(ptsz_LigneSuiv[GT_RCL_NF], ptsz_LigneCour[GT_RCL_NF]) != 0) {
    RETURN_VAL(1);
  }
  if (strcmp(ptsz_LigneSuiv[GT_RETCUR_CF], ptsz_LigneCour[GT_RETCUR_CF]) != 0) {
    RETURN_VAL(1);
  }
  if (strcmp(ptsz_LigneSuiv[GT_PLC_NT], ptsz_LigneCour[GT_PLC_NT]) != 0) {
    RETURN_VAL(1);
  }
  if (strcmp(ptsz_LigneSuiv[GT_ESB_CF], ptsz_LigneCour[GT_ESB_CF]) != 0 ) {     // [18853]
    RETURN_VAL(1);
  }
  if (strcmp(ptsz_LigneSuiv[GT_TRNCOD_CF], ptsz_LigneCour[GT_TRNCOD_CF]) != 0) {
    RETURN_VAL(1);
  }
  if (strcmp(ptsz_LigneSuiv[GT_TRN_NT], ptsz_LigneCour[GT_TRN_NT]) != 0) {      //[07]
    RETURN_VAL(1);
  }  
  // [08]
  if (strcmp(ptsz_LigneSuiv[GT_RETARDRETINT_B], ptsz_LigneCour[GT_RETARDRETINT_B]) != 0) {
    RETURN_VAL(1);
  }
  if (strcmp(ptsz_LigneSuiv[GT_GAAPCOD_NT], ptsz_LigneCour[GT_GAAPCOD_NT]) != 0) {
    RETURN_VAL(1);
  }
  if (strcmp(ptsz_LigneSuiv[GT_I17PRDCOD_CT], ptsz_LigneCour[GT_I17PRDCOD_CT]) != 0) {
    RETURN_VAL(1);
  }
  
  RETURN_VAL(0);
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne en rupture premiere du   ***/
/***         fichier maitre                                   ***/
/***                                                  ***/
/*** Nom : n_ActionPremiereRupture                              ***/
/***                                                  ***/
/*** Parametres:                                          ***/
/***  i ptsz_LigneCour : pointeur sur la ligne courante           ***/
/***                                                  ***/
/*** Retour:                                            ***/
/***  OK si pas d'erreur,                                   ***/
/***  ERR si erreur.                                      ***/
/**************************************************************************/

int n_ActionPremiereRupture(char *ptsz_LigneCour[])
{
  DEBUT_FCT("n_ActionPremiereRupture");

//  Si le poste correspond : initialisation des cumuls
  // **********************************************************************
  // ** Pas d'annulation de services ni de rejets/reconductions sur service
  // ** pour la filiale 10 etablissements 2, 3 et 4 postes Acceptation et
  // ** Retrocession a suffixe 0 Direct Business considere comme de l'Actual
  // ** ajout etablissement 8 et 7 suite a reprise sorema direct business
  // ** ne pas prendre en compte les lignes de la filiale CRP (13 ) qui vérifie les conditions ci-dessous
  // ************************************************************************
  if
  (
    (
      (
        (
          (
            (ptsz_LigneCour[GT_TRNCOD_CF][1] >= '1') &&
            (ptsz_LigneCour[GT_TRNCOD_CF][1] <= '3')
          ) ||
          (
            (ptsz_LigneCour[GT_TRNCOD_CF][1] == 'A') ||            // SPOT23390
            (ptsz_LigneCour[GT_TRNCOD_CF][1] == 'B') ||            // SPOT23390
            (ptsz_LigneCour[GT_TRNCOD_CF][1] == 'D')               // SPOT23390
          )
        )
        &&
        (
          (ptsz_LigneCour[GT_TRNCOD_CF][7] == '2') ||
          (ptsz_LigneCour[GT_TRNCOD_CF][7] == '4') ||
          (ptsz_LigneCour[GT_TRNCOD_CF][7] == '6') ||
          (ptsz_LigneCour[GT_TRNCOD_CF][7] == 'A') || //[001]
          (ptsz_LigneCour[GT_TRNCOD_CF][7] == 'C') ||
          (ptsz_LigneCour[GT_TRNCOD_CF][7] == 'E') ||
          (ptsz_LigneCour[GT_TRNCOD_CF][7] == 'G')
        )
      )
      ||
      (
        (
          (ptsz_LigneCour[GT_TRNCOD_CF][1] == 'Z') ||           // SPOT16593
          (ptsz_LigneCour[GT_TRNCOD_CF][1] == 'M') ||           // SPOT16593
          (ptsz_LigneCour[GT_TRNCOD_CF][1] == 'F')
        ) &&
        (
          (ptsz_LigneCour[GT_TRNCOD_CF][7] == '2') ||
          (ptsz_LigneCour[GT_TRNCOD_CF][7] == '4') ||
          (ptsz_LigneCour[GT_TRNCOD_CF][7] == '6') ||
          (ptsz_LigneCour[GT_TRNCOD_CF][7] == 'A') || //[001]
          (ptsz_LigneCour[GT_TRNCOD_CF][7] == 'C') ||
          (ptsz_LigneCour[GT_TRNCOD_CF][7] == 'E') ||
          (ptsz_LigneCour[GT_TRNCOD_CF][7] == 'G')
        )
      )
      ||
      (
        (ptsz_LigneCour[GT_TRNCOD_CF][1] >= '4') &&
        (ptsz_LigneCour[GT_TRNCOD_CF][1] <= '6')
      )
      ||
      (
        (ptsz_LigneCour[GT_TRNCOD_CF][1] == 'V') ||           // SPOT16593
        (ptsz_LigneCour[GT_TRNCOD_CF][1] == 'X') ||           // SPOT16593
        (ptsz_LigneCour[GT_TRNCOD_CF][1] == 'Y') ||           // SPOT16593
        (ptsz_LigneCour[GT_TRNCOD_CF][1] == 'E') ||           // SPOT23390
        (ptsz_LigneCour[GT_TRNCOD_CF][1] == 'G') ||           // SPOT23390
        (ptsz_LigneCour[GT_TRNCOD_CF][1] == 'H') ||           // SPOT23390
        (ptsz_LigneCour[GT_TRNCOD_CF][1] == 'S') ||
        (ptsz_LigneCour[GT_TRNCOD_CF][1] == 'C')
      )
    )
    &&
    !(
      (
        (atoi(ptsz_LigneCour[GT_SSD_CF]) == 10) ||
        (atoi(ptsz_LigneCour[GT_SSD_CF]) == 13)
      )
      &&
      ( (atoi(ptsz_LigneCour[GT_ESB_CF]) == 2) ||
        (atoi(ptsz_LigneCour[GT_ESB_CF]) == 3) ||
        (atoi(ptsz_LigneCour[GT_ESB_CF]) == 4) ||
        (atoi(ptsz_LigneCour[GT_ESB_CF]) == 7) ||
        (atoi(ptsz_LigneCour[GT_ESB_CF]) == 8)
      )
      &&
      (
        (memcmp (ptsz_LigneCour[GT_TRNCOD_CF], "14", 2) == 0) ||
        (memcmp (ptsz_LigneCour[GT_TRNCOD_CF], "24", 2) == 0)
      )
      &&
      (ptsz_LigneCour[GT_TRNCOD_CF][7] == '0')
    )
    &&
    !(
      ( atoi(ptsz_LigneCour[GT_SSD_CF]) == 13) &&
      (
        (memcmp (ptsz_LigneCour[GT_TRNCOD_CF], "14", 2) == 0) ||
        (memcmp (ptsz_LigneCour[GT_TRNCOD_CF], "24", 2) == 0)
      )
      &&
      ( ptsz_LigneCour[GT_TRNCOD_CF][7] == '0' )
    )
  )
  {
    Ks_Analyse = 1;
    Kd_MontantAcc = 0;
    Kd_MontantRet = 0;
    Kd_MontantRetInt = 0;
  }

  /* Autres postes */
  else {
    Ks_Analyse = 0;
  }

  RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du fichier maitre      ***/
/***                                                  ***/
/*** Nom : n_ActionLigneRupture                               ***/
/***                                                  ***/
/*** Parametres:                                          ***/
/***  i ptsz_LigneCour : pointeur sur la ligne courante           ***/
/***                                                  ***/
/*** Retour:                                            ***/
/***  OK si pas d'erreur,                                   ***/
/***  ERR si erreur.                                      ***/
/**************************************************************************/

int n_ActionLigneRupture(char *ptsz_LigneCour[])
{
  DEBUT_FCT("n_ActionLigneRupture");

  /* Si le poste correspond : cumul des montants */
  if (Ks_Analyse) {
    Kd_MontantAcc = Kd_MontantAcc + atof(ptsz_LigneCour[GT_AMT_M]);
    Kd_MontantRet = Kd_MontantRet + atof(ptsz_LigneCour[GT_RETAMT_M]);
    Kd_MontantRetInt = Kd_MontantRetInt + atof(ptsz_LigneCour[GT_RETINTAMT_M]);
  }

  RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne en rupture derniere du   ***/
/***         fichier maitre                                   ***/
/***                                                  ***/
/*** Nom : n_ActionDerniereRupture                              ***/
/***                                                  ***/
/*** Parametres:                                          ***/
/***  i ptsz_LigneCour : pointeur sur la ligne courante           ***/
/***                                                  ***/
/*** Retour:                                            ***/
/***  OK si pas d'erreur,                                   ***/
/***  ERR si erreur.                                      ***/
/**************************************************************************/

int n_ActionDerniereRupture(char *ptsz_LigneCour[])
{
  char sz_AMT_M[25];       /* Chaine contenant le montant acceptation */
  char sz_RETAMT_M[25];    /* Chaine contenant le montant retrocession */
  char sz_RETINTAMT_M[25]; /* Chaine contenant le montant retrocession interne*/
  char sz_TRNCOD_CF[9];    /* Chaine contenant le poste comptable */

  DEBUT_FCT("n_ActionDerniereRupture");

// Si le poste correspond : ecriture d'une ligne dans le fichier de rejet et
// dans le fichier de reconduction

  if (Ks_Analyse) {

    /* Date bilan : 1/1 + Annee du libelle d'inventaire + 1 */
    ptsz_LigneCour[GT_BALSHEY_NF] = Ksz_Annee;
    ptsz_LigneCour[GT_BALSHRMTH_NF] = "1";
    ptsz_LigneCour[GT_BALSHRDAY_NF] = "1";

    /***************************/
    /* Fichier de reconduction */
    /***************************/
    sprintf(sz_AMT_M, "%-.3lf", Kd_MontantAcc);
    sprintf(sz_RETAMT_M, "%-.3lf", Kd_MontantRet);
    sprintf(sz_RETINTAMT_M, "%-.3lf", Kd_MontantRetInt);
    ptsz_LigneCour[GT_AMT_M] = sz_AMT_M;
    ptsz_LigneCour[GT_RETAMT_M] = sz_RETAMT_M;
    ptsz_LigneCour[GT_RETINTAMT_M] = sz_RETINTAMT_M;
    ptsz_LigneCour[GT_NEWCOLS5_NF] = "O";  // [08]

    if ((ptsz_LigneCour[GT_TRNCOD_CF][1] == 'A') ||       /* [23390] */
        (ptsz_LigneCour[GT_TRNCOD_CF][1] == 'B') ||       /* [23390] */
        (ptsz_LigneCour[GT_TRNCOD_CF][1] == 'D') ||       /* [23390] */
        (ptsz_LigneCour[GT_TRNCOD_CF][1] == 'E') ||       /* [23390] */
        (ptsz_LigneCour[GT_TRNCOD_CF][1] == 'G') ||       /* [23390] */
        (ptsz_LigneCour[GT_TRNCOD_CF][1] == 'H') ||       /* [23390] */
        (ptsz_LigneCour[GT_TRNCOD_CF][1] == 'J') ||       /* [23390] */
        (ptsz_LigneCour[GT_TRNCOD_CF][1] == 'K') ||       /* [23390] */
        (ptsz_LigneCour[GT_TRNCOD_CF][1] == 'L') ||       /* [23390] */
        (ptsz_LigneCour[GT_TRNCOD_CF][7] == 'G')  )        //[007]

      ptsz_LigneCour[GT_ORICOD_LS] = "EBSGTA";


    /********************************************************/
    /* Modifs du 01/04/98 - M.HA-THUC                 */
    /* pas d'ecriture dans le fichier des reconductions     */
    /* si les montants sont nuls                    */
    /********************************************************/

    /* cas : acceptation pure */
    /**************************/
    if ( *ptsz_LigneCour[GT_CTR_NF] != 0 && *ptsz_LigneCour[GT_RETCTR_NF] == 0
         && fabs( Kd_MontantAcc ) >= 0.0005 )
      n_WriteCols(Kp_OutputFile, ptsz_LigneCour, '~', 0);

    /* cas : retrocession pure */
    /**************************/
    if ( *ptsz_LigneCour[GT_CTR_NF] == 0 && *ptsz_LigneCour[GT_RETCTR_NF] != 0
         && fabs( Kd_MontantRet ) >= 0.0005 )
      n_WriteCols(Kp_OutputFile, ptsz_LigneCour, '~', 0);

    /* cas : retrocession par acceptation */
    /**************************************/
    if ( *ptsz_LigneCour[GT_CTR_NF] != 0 && *ptsz_LigneCour[GT_RETCTR_NF] != 0
         && ( fabs( Kd_MontantRet ) >= 0.0005 || fabs( Kd_MontantAcc ) >= 0.0005 ) )
      n_WriteCols(Kp_OutputFile, ptsz_LigneCour, '~', 0);

    /********************/
    /* Fichier de rejet */
    /********************/
    if   ( (ptsz_LigneCour[GT_TRNCOD_CF][1] >= '1') && (ptsz_LigneCour[GT_TRNCOD_CF][1] <= '3')  )
    {
      sprintf(sz_TRNCOD_CF, "%d", atoi(ptsz_LigneCour[GT_TRNCOD_CF]) );
      switch (ptsz_LigneCour[GT_TRNCOD_CF][7])    //[001]
      {
      case 'A':
        sz_TRNCOD_CF[7] = 'B';
        break;
      case 'C':
        sz_TRNCOD_CF[7] = 'D';
        break;
      case 'E':
        sz_TRNCOD_CF[7] = 'F';
        break;
      case 'G':
        sz_TRNCOD_CF[7] = 'H';
        break;
      case '2':
        sz_TRNCOD_CF[7] = '3';
        break;
      default :
        sz_TRNCOD_CF[7] = sz_TRNCOD_CF[7] + 1;
        break;
      }
    }
    else {
      strcpy(sz_TRNCOD_CF, ptsz_LigneCour[GT_TRNCOD_CF]);
      switch (ptsz_LigneCour[GT_TRNCOD_CF][1]) {
      case '4':
        sz_TRNCOD_CF[1] = '7';
        break;
      case '5':
        sz_TRNCOD_CF[1] = '8';
        break;
      case '6':
        sz_TRNCOD_CF[1] = '9';
        break;
      case 'S':
        sz_TRNCOD_CF[1] = 'O';
        break;
      case 'C':
        sz_TRNCOD_CF[1] = 'R';
        break;
      case 'V':                                // SPOT16593
        sz_TRNCOD_CF[1] = 'W';
        break;
      case 'X':                                // SPOT16593
        sz_TRNCOD_CF[1] = 'N';
        break;
      case 'Y':                                // SPOT16593
        sz_TRNCOD_CF[1] = 'U';
        break;
      case 'E':                                // SPOT23390
        sz_TRNCOD_CF[1] = 'J';
        break;
      case 'G':                                // SPOT23390
        sz_TRNCOD_CF[1] = 'K';
        break;
      case 'H':                                // SPOT23390
        sz_TRNCOD_CF[1] = 'L';
        break;
      case 'Z':
      case 'M':
      case 'F':                                    // SPOT16593
      case 'A':                                    // SPOT23390
      case 'B':                                    // SPOT23390
      case 'D':                                    // SPOT23390
        strcpy(sz_TRNCOD_CF, ptsz_LigneCour[GT_TRNCOD_CF]);
        switch (ptsz_LigneCour[GT_TRNCOD_CF][7])    //[001]
        {
        case 'A':
          sz_TRNCOD_CF[7] = 'B';
          break;
        case 'C':
          sz_TRNCOD_CF[7] = 'D';
          break;
        case 'E':
          sz_TRNCOD_CF[7] = 'F';
          break;
        case 'G':
          sz_TRNCOD_CF[7] = 'H';
          break;
        default:
          sz_TRNCOD_CF[7] = sz_TRNCOD_CF[7] + 1;     // +1 dans dernier caractere du trncod
        }
        break;

      }
    }

    sprintf(sz_AMT_M, "%-.3lf", - Kd_MontantAcc);
    sprintf(sz_RETAMT_M, "%-.3lf", - Kd_MontantRet);
    sprintf(sz_RETINTAMT_M, "%-.3lf", - Kd_MontantRetInt);
    ptsz_LigneCour[GT_TRNCOD_CF] = sz_TRNCOD_CF;
    ptsz_LigneCour[GT_NEWCOLS5_NF] = "O";  // [08]
    

    /********************************************************/
    /* Modifs du 01/04/98 - M.HA-THUC                 */
    /* pas d'ecriture dans le fichier des rejets        */
    /* si les montants sont nuls                    */
    /********************************************************/

    /* cas : acceptation pure */
    /**************************/
    if ( *ptsz_LigneCour[GT_CTR_NF] != 0 && *ptsz_LigneCour[GT_RETCTR_NF] == 0
         && fabs( Kd_MontantAcc ) >= 0.0005 )
      n_WriteCols(Kp_OutputFile, ptsz_LigneCour, '~', 0);

    /* cas : retrocession pure */
    /**************************/
    if ( *ptsz_LigneCour[GT_CTR_NF] == 0 && *ptsz_LigneCour[GT_RETCTR_NF] != 0
         && fabs( Kd_MontantRet ) >= 0.0005 )
      n_WriteCols(Kp_OutputFile, ptsz_LigneCour, '~', 0);

    /* cas : retrocession par acceptation */
    /**************************************/
    if ( *ptsz_LigneCour[GT_CTR_NF] != 0 && *ptsz_LigneCour[GT_RETCTR_NF] != 0
         && ( fabs( Kd_MontantRet ) >= 0.0005 || fabs( Kd_MontantAcc ) >= 0.0005 ) )
      n_WriteCols(Kp_OutputFile, ptsz_LigneCour, '~', 0);
  }
  RETURN_VAL(OK);
}
