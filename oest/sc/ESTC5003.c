/*==============================================================================
nom de l'application          : Trimestrialisation du fichier TIDLIFEST_DETAILLED
nom du source                 : 
revision                      : Revision: 1.13 $
date de creation              : 25/05/2016
auteur                        : M. BONATO
references des specifications : 
squelette de base             : batch
------------------------------------------------------------------------------
description :
              calcul la trimestrialisation des montant contenu dans le fichier
              TIDLIFEST_DETAILLED.
------------------------------------------------------------------------------
historique des modifications :
<jj/mm/aaaa>  <auteur>  <SPIRA:SPOT>  <description de la modification>

 [000]	06/06/2016     MBO       30691       création du programme
 [001]	10/08/2016	   MBO		 30898	     correction TRSLNK mal lu
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include "ESTC5000.h"
#include <estserv.h>
#include <struct.h>
#include <utctlib.h>

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

enum MODE
{
  PA = 0,
  PC = 1
} Kn_mode;

#define MAX_DATES     5000000
#define NB_MAX_TRSLNK 20000

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE  *Kp_PrevFil;                          /* pointeur sur les previsions en sortie    */
FILE  *Kp_SubTRSAssoFile;
FILE  *Kp_SubTRSFile;
FILE  *Kp_TrslnkFil;

T_RUPTURE_VAR   bd_RuptPrev;                /* gestion rupture sur Prev                 */
T_RUPTURE_VAR   pbd_RuptPerim;              /* gestion rupture sur Perimetre            */
T_TRSLNK        Kbd_TRSLNK[NB_MAX_TRSLNK];

int Kn_annee;                               /* Annee d'inventaire                       */
int Kn_annee1;                              /* Annee d'inventaire - 1                   */
int Kn_mois;                                /* Mois d'inventaire                        */
int Kb_AnInv;                               /* 1 si ACY=annee d'inventaire, 0 sinon     */
int Kn_postegen;                            /* Ancien poste                             */
int Kb_rollback;                            /* 1 si rollback possible, 0 sinon          */
int Kn_Dates;                               /* dates effet et expiration par CTR/SEC/UWY*/
int Kn_Cpt_Dates;                           /* compteur sur structure Dates             */
int Kn_Cpt_Dates_ctrsec = 0;                /* compteur sur structure Dates premiere ocurrence CTR/SEC */
int Kn_NbLigTrslnk = 0;

char sz_ref_CTR[30] = "";                   /* CTR reference pour recherche dates       */
char sz_ref_SEC[4]  = "";                   /* SEC reference pour recherche dates       */

double Kd_coef;                             /* Coefficient = mois d'inventaire / 12     */
double Kd_RP[9];                               /* Retrait de portefeuille                  */
double Kd_EP[9];                            /* Entree de portefeuille                   */
double Kd_Lib[9];                           /* Liberation                               */
double Kd_Cst[9];                           /* Constitution                             */

typedef struct
{
  char  sz_RETCOD[2];
  char  sz_SPIMOD[2];
  char  sz_ADJCOD[2];
  char  ACmtrs[5];
}       T_POST_INFO;

typedef struct
{
  char  sz_CTR_NF[10];
  char  sz_SEC_NF[4];
  char  sz_UWY_NF[6];
  char  sz_EFFET_D[9];
  char  sz_EXPIRATION_D[9];
}       T_DATES;

typedef struct {
  char  LOB_CF[3];
  char  NAT_CF[3];
  char  SSD[2];
  char  ESB[2];
  char  ACCTYP;
  char  USGAAP;
  double  TPNA;
  double  TCOM;
  double  TSURCOM;
  double  TCOURTAGE1;
  double  TCOURTAGE2;
  double  TPB;
  double  TFG;
  double  TCLMINT;
  double  TURRINT;
  double  TCLMFUN;
  double  TURRFUN;
  double  TCLMCAS;
  double  TURRCAS;
} T_ClePerimetre;

fpos_t          K_pos;
T_SUBTRS        SubTrsLigne;
T_RUPTURE_VAR   bd_RuptTACCPAR;             // Gestion rupture
T_POST_INFO     L_PostInfo_ACMTRS[180];     // Modification parametrage TACCPAR
T_DATES         L_DATES[MAX_DATES];
T_ClePerimetre  Kbd_ClePerimetre;


int   n_InitPrev             (T_RUPTURE_VAR *pbd_RuptPerim);
int   n_ActionLignePrev      (char **pbd_RuptPerim);
int   n_IsR1Prev             (char **ptb_InRec, char **ptb_InRec_Cur);
int   n_IsR2Prev             (char **ptb_InRec, char **ptb_InRec_Cur);
int   n_ActionFirstRupt1Prev (char **ptb_InRec_Cur);
int   n_ActionLastRupt1Prev  (char **ptb_InRec_Cur);
int   n_ActionFirstRupt2Prev (char **ptb_InRec_Cur);
void  EcrirePrevision        (double d[9], char **psz_ligne);

int    n_InitRuptPerim       (T_RUPTURE_VAR *pbd_Rupt);
int    n_ActionLignePerim    (char **pbd_InRec_Cur);
double d_CalculerRatio       (char **ptb_InRec_Cur);
int    n_AcyCourante         (char **ptb_InRec_Cur);
int    n_nbJoursDansMois     (int annee, int mois);

int    n_InitTACCPAR         (T_RUPTURE_VAR  *);     // Initialisation de traitement du fichier TACCPAR
int    n_ActionLigneTACCPAR  (char **);              // à chaque ligne du fichier TACCPAR_I3
int    n_RechercheTACCPAR    (char *);
void   init_SubTrsLigne      ();

int    Load_TRSLNK           (FILE* Kp_TrslnkFil);
int    Search_ACMTRS         (char *sz_poste);

int    K = 0;           // nombre de ACMTRS from TACCPAR

/*==============================================================================
objet :     point d'entree du programme
retour :    En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc , char *argv[])
{
  char sz_annee[5];
  char sz_mois[3];
  char sz_clodat[9];
  char sz_iclodat[9];
  char sz_clodatyea[5];
  char sz_clodatmth[3];
  char sz_iclodatmth[3];
  char sz_clodatday[3];
  //char sz_mode[3];

  /* Initialisation des signaux */
  InitSig();

  if (n_BeginPgm (argc, argv) == ERR)
    ExitPgm (ERR_XX, "");

  /* Recuperation des dates d'inventaire */
  strcpy (sz_annee,  psz_GetCharArgv(1));
  strcpy (sz_mois,   psz_GetCharArgv(2));
  strcpy (sz_clodat, psz_GetCharArgv(3));
  strcpy (sz_iclodat, psz_GetCharArgv(4));
//  strcpy (sz_mode,   psz_GetCharArgv(4));

  /* Eclatement du clodat AAAAMMJJ en 3 chaines de caractere */
  sscanf(sz_iclodat, "%4s%2s%2s", sz_clodatyea, sz_iclodatmth, sz_clodatday); //récupération de sz_iclodatmth. sz_clodatyea sz_clodatday ne sont pas important ici
  sscanf(sz_clodat, "%4s%2s%2s", sz_clodatyea, sz_clodatmth, sz_clodatday);

  printf("\nParams lus :\nBALSHTYEA_NF %s\nBALSHTMTH_NF %s\nCLODAT_D %s\nICLODAT_D %s\n",
         sz_annee, sz_mois, sz_clodat, sz_iclodat);

  Kd_coef = atof(sz_iclodatmth) / 12.0;

  Kn_mois = atoi(sz_iclodatmth);
  Kn_annee = atoi(sz_clodatyea);
  Kn_annee1 = Kn_annee - 1;

  Kn_mode = PC;

  memset(&L_PostInfo_ACMTRS, 0, 150 * sizeof(T_POST_INFO));
  memset(&Kbd_ClePerimetre, 0, sizeof(Kbd_ClePerimetre));

  /* Ouverture des fichiers en sortie wt */
  if ( n_OpenFileAppl ("ESTC5003_O1", "w", &Kp_PrevFil) == ERR )
    ExitPgm ( ERR_XX , "ESTC5003_O1" );

  if ( n_InitTACCPAR(&bd_RuptTACCPAR) )
    ExitPgm ( ERR_XX , "" );

  if ( n_ProcessingRuptureVar (&bd_RuptTACCPAR) == ERR )
    ExitPgm ( ERR_XX , "" );

  if ( n_OpenFileAppl ("ESTC5003_I3", "rb", &Kp_SubTRSAssoFile) == ERR )
    ExitPgm ( ERR_XX , "ESTC5003_I3" );
  n_ChargerTsubTRSAsso(Kp_SubTRSAssoFile);

  if ( n_OpenFileAppl ("ESTC5003_I4", "rb", &Kp_SubTRSFile) == ERR )
    ExitPgm ( ERR_XX , "ESTC5003_I4" );
  n_ChargerTsubTRS(Kp_SubTRSFile);

  if ( n_OpenFileAppl ("ESTC5003_I6", "rb", &Kp_TrslnkFil) == ERR )
    ExitPgm ( ERR_XX , "ESTC5003_I6" );
  Load_TRSLNK(Kp_TrslnkFil);

  // Chargement structure contenant les dates d'effet et d'expiration
  if ( n_InitRuptPerim(&pbd_RuptPerim) )
    ExitPgm ( ERR_XX , "Erreur a l'ouverture du fichier PERICASE" );
  
  Kn_Cpt_Dates = 0; // initialisation du compteur sur structure Dates
  
  if ( n_ProcessingRuptureVar(&pbd_RuptPerim) == ERR )
    ExitPgm ( ERR_XX , "Erreur lors du chargement du PERICASE" );

  /* Initialisation de la varible bd_RuptPrev */
  if ( n_InitPrev(&bd_RuptPrev) )
    ExitPgm ( ERR_XX , "" );

  // initialisation de la structure retour  //
  init_SubTrsLigne();

  /* Lancement du traitement du fichier */
  if ( n_ProcessingRuptureVar (&bd_RuptPrev) == ERR )
    ExitPgm ( ERR_XX , "" );

  /* Fermeture fichier */
  if (n_CloseFileAppl ("ESTC5003_I1", &(bd_RuptPrev.pf_InputFil)))
    ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTC5003_O1", &Kp_PrevFil))
    ExitPgm ( ERR_XX , "" );
  
  if (n_CloseFileAppl ("ESTC5003_I2", &(bd_RuptTACCPAR.pf_InputFil)))
    ExitPgm ( ERR_XX , "" );
  
  if (n_CloseFileAppl ("ESTC5003_I3", &Kp_SubTRSAssoFile) == ERR)
    ExitPgm ( ERR_XX , "" );
  
  if (n_CloseFileAppl ("ESTC5003_I4", &Kp_SubTRSFile) == ERR)
    ExitPgm ( ERR_XX , "" );
    
  if (n_CloseFileAppl ("ESTC5003_I6", &Kp_TrslnkFil) == ERR)
    ExitPgm ( ERR_XX , "" );

  if ( n_EndPgm () == ERR )
    ExitPgm ( ERR_XX , "" );

  exit(0);
}


/*==============================================================================
objet : fonction d'initialisation de la variable de gestion de rupture du fichier maitre.
retour :    0
==============================================================================*/
int n_InitPrev(T_RUPTURE_VAR  *pbd_Rupt)
{
  DEBUT_FCT("n_InitPrev");

  memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

  if ( n_OpenFileAppl ("ESTC5003_I1", "rt", &(pbd_Rupt->pf_InputFil)))
    RETURN_VAL (ERR);

  pbd_Rupt->n_NbRupture           = 2 ;
  pbd_Rupt->n_ConditionRupture[0] = n_IsR1Prev;
  pbd_Rupt->n_ActionFirst[0]      = n_ActionFirstRupt1Prev;
  pbd_Rupt->n_ActionLast[0]       = n_ActionLastRupt1Prev;

  pbd_Rupt->n_ConditionRupture[1] = n_IsR2Prev;
  pbd_Rupt->n_ActionFirst[1]      = n_ActionFirstRupt2Prev;

  pbd_Rupt->n_ActionLigne         = n_ActionLignePrev ;

  pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL (0);
}


/*==============================================================================
objet : fonction de test de rupture de niveau 1
retour :    0   ---> Pas de rupture
            1   ---> rupture
==============================================================================*/
int n_IsR1Prev(char **ptb_InRec, char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_IsR1Prev");

  if (strcmp(ptb_InRec[DETAIL_CTR_NF], ptb_InRec_Cur[DETAIL_CTR_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[DETAIL_SEC_NF], ptb_InRec_Cur[DETAIL_SEC_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[DETAIL_UWY_NF], ptb_InRec_Cur[DETAIL_UWY_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[DETAIL_ACY_NF], ptb_InRec_Cur[DETAIL_ACY_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[DETAIL_PERIOD_NT], ptb_InRec_Cur[DETAIL_PERIOD_NT]) != 0)
    RETURN_VAL(1);

  RETURN_VAL (0);
}


/*==============================================================================
objet :     fonction de test de rupture de niveau 2
retour :    0   ---> Pas de rupture
            1   ---> rupture
==============================================================================*/
int n_IsR2Prev(char **ptb_InRec, char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_IsR2Prev");

  if (strcmp(ptb_InRec[DETAIL_CTR_NF], ptb_InRec_Cur[DETAIL_CTR_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[DETAIL_SEC_NF], ptb_InRec_Cur[DETAIL_SEC_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[DETAIL_UWY_NF], ptb_InRec_Cur[DETAIL_UWY_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[DETAIL_ACY_NF], ptb_InRec_Cur[DETAIL_ACY_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[DETAIL_PERIOD_NT], ptb_InRec_Cur[DETAIL_PERIOD_NT]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[DETAIL_DETTRNCOD_CF], ptb_InRec_Cur[DETAIL_DETTRNCOD_CF]) != 0)
    RETURN_VAL(1);

  RETURN_VAL (0);
}


/*==============================================================================
objet : Fonction lancee a chaque rupture premiere de niveau 1
==============================================================================*/
int n_ActionFirstRupt1Prev (char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_ActionFirstRupt1Prev");
  int i;

  /* Réinitialisation de la variable rollback dans tous les cas */
  Kb_rollback = 0;

  /* Réinitialisation des variables sauf si on est sur l'année d'inventaire */
  if ( atoi(ptb_InRec_Cur[DETAIL_ACY_NF]) != Kn_annee )
  {
    for (i = 0 ; i < 9 ; ++i)
    {
      Kd_EP[i] = 0;
      Kd_Lib[i] = 0;
      Kd_Cst[i] = 0;
      Kd_RP[i] = 0;
    }
  }
  RETURN_VAL(0);
}


/*==============================================================================
objet : Fonction lancee a chaque rupture premiere de niveau 2
==============================================================================*/
int n_ActionFirstRupt2Prev (char **ptb_InRec_Cur)
{
  char    sz_poste[5];
  char    ZDETTRNCOD[6];
  double  d_coeff      = 0.0;
  double  d_montant[9];
  int     dettrncod    = 0;
  int     i            = 0;
  int     n_poste      = 0;
  int     n_UnitePoste = 0;
  int     result       = 0;

  DEBUT_FCT("n_ActionFirstRupt2Prev");

  for (i = 0 ; i < 9 ; ++i)
    d_montant[i] = 0.0;

  ptb_InRec_Cur[DETAIL_QUARTER_B] = "1";

  /* Si l'annee de compte ne correspond pas a l'annee d'inventaire, */
  /* l'indicateur est mis a 0 pour interdire tout traitement de modification */
  if(n_AcyCourante(ptb_InRec_Cur) == 0)
    Kb_AnInv = 1;
  else
    Kb_AnInv = 0;

  // Calcul du ratio
  d_coeff = d_CalculerRatio(ptb_InRec_Cur);

  /* Conversion du montant pour le calcul */
  // pour chaque montant DETAIL_PREVIFRSAMT_M, DETAIL_IFRSAMT_M, DETAIL_PLNIFRSAMT_M,
  //                     DETAIL_PREVPRNTAMT_M, DETAIL_PRNTAMT_M, DETAIL_PLNPRNTAMT_M,
  //                     DETAIL_PREVLOCALAMT_M, DETAIL_LOCALAMT_M, DETAIL_PLNLOCALAMT_M
  for (i = 0 ; i < 9 ; ++i)
    d_montant[i] = atof(ptb_InRec_Cur[DETAIL_PREVIFRSAMT_M + i]);

  /* Numero de poste */
  n_poste = Search_ACMTRS(ptb_InRec_Cur[DETAIL_DETTRNCOD_CF]); //calcul ACMTRS

  /* Extraction du chiffre des unites du poste */
  n_UnitePoste = n_poste % 10; //le chiffre à la fin : ex 0 pour 1010 ou 3 pour 1243

  /* Si type comptable = 1 ou si type comptable 3 ou 5 et poste prime et que le contrat n'a pas ete renouvelé pour l'exercice egale a l'annee d'inventaire, */
  /* l'indicateur est mis a 0 pour interdire tout traitement de modification  SPOT 14307 */

  result = n_FindTsubTRS(&SubTrsLigne, ptb_InRec_Cur[DETAIL_DETTRNCOD_CF]);

  /* si c'est un poste analytique avec un inputtype=ration, alors on ne trimestrialise pas */
  if ((SubTrsLigne.TRSINPUTTYPE_CT == 3) && (SubTrsLigne.TRSNATURE_CT == 2)) // [023]
  {
    n_WriteCols(Kp_PrevFil, ptb_InRec_Cur, '~', 0);
    RETURN_VAL(0);
  }

  // Traitement de modification effectue uniquement pour l'annee d'inventaire 
  if (Kb_AnInv == 1)
  {
    if (n_poste == 2145)
    {
        Kb_rollback = 0;        
        // pour chaque montant DETAIL_PREVIFRSAMT_M, DETAIL_IFRSAMT_M, DETAIL_PLNIFRSAMT_M,
        //                     DETAIL_PREVPRNTAMT_M, DETAIL_PRNTAMT_M, DETAIL_PLNPRNTAMT_M,
        //                     DETAIL_PREVLOCALAMT_M, DETAIL_LOCALAMT_M, DETAIL_PLNLOCALAMT_M
        for (i = 0 ; i < 9 ; ++i)
          d_montant[i] *= Kd_coef;
        EcrirePrevision (d_montant, ptb_InRec_Cur);
    }

    /* Le calcul est fonction de ce chiffre */
    switch (n_UnitePoste)
    {
    case 0:             /* cas de suffixe '0' ('Primes+RPCC', 'Echeances', ...) */
      Kb_rollback = 0;
      // pour chaque montant DETAIL_PREVIFRSAMT_M, DETAIL_IFRSAMT_M, DETAIL_PLNIFRSAMT_M,
      //                     DETAIL_PREVPRNTAMT_M, DETAIL_PRNTAMT_M, DETAIL_PLNPRNTAMT_M,
      //                     DETAIL_PREVLOCALAMT_M, DETAIL_LOCALAMT_M, DETAIL_PLNLOCALAMT_M
      for (i = 0 ; i < 9 ; ++i)
        d_montant[i] *= d_coeff;
      EcrirePrevision (d_montant, ptb_InRec_Cur);
    break;

    case 1:             /* cas des entree; memorisation de l'estimation */
      Kb_rollback = 0;
      // pour chaque montant DETAIL_PREVIFRSAMT_M, DETAIL_IFRSAMT_M, DETAIL_PLNIFRSAMT_M,
      //                     DETAIL_PREVPRNTAMT_M, DETAIL_PRNTAMT_M, DETAIL_PLNPRNTAMT_M,
      //                     DETAIL_PREVLOCALAMT_M, DETAIL_LOCALAMT_M, DETAIL_PLNLOCALAMT_M
      for (i = 0 ; i < 9 ; ++i)
        Kd_EP[i] = d_montant[i];
      EcrirePrevision (d_montant, ptb_InRec_Cur);
    break;

    case 2:             /* cas des retraits de portfeuille */
      Kb_rollback = 0;
      // pour chaque montant DETAIL_PREVIFRSAMT_M, DETAIL_IFRSAMT_M, DETAIL_PLNIFRSAMT_M,
      //                     DETAIL_PREVPRNTAMT_M, DETAIL_PRNTAMT_M, DETAIL_PLNPRNTAMT_M,
      //                     DETAIL_PREVLOCALAMT_M, DETAIL_LOCALAMT_M, DETAIL_PLNLOCALAMT_M
      for (i = 0 ; i < 9 ; ++i)
        Kd_RP[i] = (-Kd_EP[i]) + ((Kd_EP[i] + d_montant[i]) * d_coeff);
      EcrirePrevision (Kd_RP, ptb_InRec_Cur);
      for (i = 0 ; i < 9 ; ++i)
      	Kd_EP[i] = 0;
    break;

    case 3:             /* annulation écriture des constitutions par défaut */
      if (Kb_rollback == 1)
      {
        Kb_rollback = 0;

        if (n_poste == Kn_postegen)
          fsetpos(Kp_PrevFil, &K_pos);
        else
          for (i = 0 ; i < 9 ; ++i)
            Kd_Lib[i] = 0;
      }
      else
        for (i = 0 ; i < 9 ; ++i)
          Kd_Lib[i] = 0;

      /* cas des constitutions de provisions */

      // pour chaque montant DETAIL_PREVIFRSAMT_M, DETAIL_IFRSAMT_M, DETAIL_PLNIFRSAMT_M,
      //                     DETAIL_PREVPRNTAMT_M, DETAIL_PRNTAMT_M, DETAIL_PLNPRNTAMT_M,
      //                     DETAIL_PREVLOCALAMT_M, DETAIL_LOCALAMT_M, DETAIL_PLNLOCALAMT_M
      for (i = 0 ; i < 9 ; ++i)
        Kd_Cst[i] = (Kd_Lib[i] + d_montant[i]) * d_coeff - Kd_Lib[i];
      for (i = 0 ; i < 9 ; ++i)
        Kd_Lib[i] = 0;
      EcrirePrevision (Kd_Cst, ptb_InRec_Cur);
    break;

    case 4:         // cas des liberations: memorisation
      for (i = 0 ; i < 9 ; ++i)
        Kd_Lib[i] = d_montant[i];
      EcrirePrevision (d_montant, ptb_InRec_Cur);

      /* stockage adresse au cas où il existe une constitution */
      fgetpos(Kp_PrevFil, &K_pos);
      Kb_rollback = 1;

      for (i = 0 ; i < 9 ; ++i)
        Kd_Cst[i] = Kd_Lib[i] * d_coeff - Kd_Lib[i];

      if (n_poste % 10 == 4)
        sprintf(sz_poste, "%d", n_poste - 1);
      else
        sprintf(sz_poste, "%d", n_poste);

      Kn_postegen = atoi(sz_poste);
      dettrncod = n_FindTsubTRSAssoCons(1, 1, ptb_InRec_Cur[DETAIL_DETTRNCOD_CF]);

      if (dettrncod != -1)
      {
        sprintf(ZDETTRNCOD, "%d", dettrncod);
        ZDETTRNCOD[5] = 0;
        sprintf(ptb_InRec_Cur[DETAIL_DETTRNCOD_CF], "%s", ZDETTRNCOD);
      }
      EcrirePrevision (Kd_Cst, ptb_InRec_Cur);
    break;
    }
  }

  // Pour les annees anterieures à l'annee d'inventaire, reconduction des previsions
  if(n_AcyCourante(ptb_InRec_Cur) == -1)
    n_WriteCols(Kp_PrevFil, ptb_InRec_Cur, '~', 0);

  RETURN_VAL(0);
}


/*==============================================================================
objet : fonction lancee pour chaque ligne du maitre
retour :    0 ----> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePrev(char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_ActionLignePrev");
  RETURN_VAL (0);
}


/*==============================================================================
objet : Fonction lancee a chaque rupture derniere de niveau 1
==============================================================================*/
int n_ActionLastRupt1Prev (char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_ActionLastRupt1Prev");
  RETURN_VAL(0);
}

int cmp_dettrncod_dettrs(char *dettrncod, char *dettrs)
{
  int   i;
  char  post[6];

  for (i = 0 ; i < 5 ; ++i) // on compare uniquement le code à 5
    post[i] = dettrs[i+2];
  post[5] = '\0';
  return strcmp(dettrncod, post);
}

/*==============================================================================
objet : Fonction de chargement de TRSLNK
==============================================================================*/
int Load_TRSLNK(FILE* Kp_TrslnkFil)
{
	int n_EOF = 0;
	T_TRSLNK bd_Lu;

	DEBUT_FCT("n_ChargerTRSLNK");

	Kn_NbLigTrslnk=0;

  /* Tant que la fin de fichier n'est pas atteinte,... */
	while (n_EOF == 0)
	{
		if (fread(&bd_Lu, sizeof(T_TRSLNK), 1, Kp_TrslnkFil) <= 0)
		{
			n_EOF = 1;
		}
		else
		{
			if (Kn_NbLigTrslnk + 1 >=  NB_MAX_TRSLNK)
				RETURN_VAL(ERR);
			else if (bd_Lu.PRS_CF == 500) // Enregistrement ecrit dans le tableau
				Kbd_TRSLNK[Kn_NbLigTrslnk++] = bd_Lu;
		}
	}
	RETURN_VAL(OK);
}

/*==============================================================================
objet : Fonction de recherche de ACMTRS pour un POSTE donné
==============================================================================*/
int Search_ACMTRS(char *dettrncod)
{
  DEBUT_FCT("n_RechPoste");
   
  int n_indice;
  int ret;

  n_indice=0;

  while (n_indice < Kn_NbLigTrslnk)
  {
    // Comparaison des codes
    ret = cmp_dettrncod_dettrs(dettrncod, Kbd_TRSLNK[n_indice].DETTRS_CF);
    // S'ils sont egaux, retourner l'indice
    if (ret == 0)
        return (Kbd_TRSLNK[n_indice].ACMTRS_NT);
    //[001] ligne supprimée
    // Ligne suivante
    n_indice++;
  }
  // Si on est a la fin du tableau, echec
  RETURN_VAL(-1);
}

/*==============================================================================
objet : Fonction d'ecriture dans le champs  psz_ligne
==============================================================================*/
void EcrirePrevision(double d[9], char **psz_ligne)
{
  char sz_montant[9][30];
  char sz_balshtyea[5] ;  /* zone de travail */
  char sz_balshtmth[3] ;  /* zone de travail */
  int  i;

  /* Conversion de l'annee et mois bilan en chaine - modifs du 27/03/98 */
  sprintf( sz_balshtyea, "%d", Kn_annee ) ;
  sprintf( sz_balshtmth, "%d", Kn_mois ) ;

  
  // pour chaque montant DETAIL_PREVIFRSAMT_M, DETAIL_IFRSAMT_M, DETAIL_PLNIFRSAMT_M,
  //                     DETAIL_PREVPRNTAMT_M, DETAIL_PRNTAMT_M, DETAIL_PLNPRNTAMT_M,
  //                     DETAIL_PREVLOCALAMT_M, DETAIL_LOCALAMT_M, DETAIL_PLNLOCALAMT_M
  for (i = 0 ; i < 9 ; ++i)
  {
    sprintf(sz_montant[i], "%.3lf", d[i]);                  /* Conversion du montant en chaine */
    psz_ligne[DETAIL_PREVIFRSAMT_M + i] = sz_montant[i];  /* Affectation a la structure de prevision */
  }

  /* Ecriture */
  n_WriteCols(Kp_PrevFil, psz_ligne, '~', 0);
}


/*==============================================================================
objet :     Initialisation du fichier
retour:     OK
==============================================================================*/
int n_InitTACCPAR(T_RUPTURE_VAR  *pbd_Rupt)
{
  DEBUT_FCT("n_InitTACCPAR");

  memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

  n_OpenFileAppl ("ESTC5003_I2", "rt", &(pbd_Rupt->pf_InputFil));

  pbd_Rupt->n_NbRupture     = 0  ;
  pbd_Rupt->n_ActionLigne   = n_ActionLigneTACCPAR;
  pbd_Rupt->c_Separ         = '~' ;

  RETURN_VAL(OK);
}


/*==============================================================================
objet : fonction lancee pour chaque ligne du perimetre
retour: OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneTACCPAR( char **ptb_InRecTACCPAR )
{
  DEBUT_FCT("n_ActionLigneTACCPAR");

  strcpy(L_PostInfo_ACMTRS[K].sz_RETCOD, ptb_InRecTACCPAR[ACC_RETCOD_CT]);
  strcpy(L_PostInfo_ACMTRS[K].sz_SPIMOD, ptb_InRecTACCPAR[ACC_SPIMOD_CT]);
  strcpy(L_PostInfo_ACMTRS[K].sz_ADJCOD, ptb_InRecTACCPAR[ACC_ADJCOD_CT]);
  strcpy(L_PostInfo_ACMTRS[K].ACmtrs, ptb_InRecTACCPAR[ACC_ACMTRS_NT]);
  K++;

  RETURN_VAL(OK);
}


/*=============================================================================
objet : Recherche le DETTRS du poste de regroupement
=============================================================================*/
int n_RechercheTACCPAR(char* ACMTRS )
{
  int i = 0;

  for (i = 0; i < K; i++)
  {
    if (strcmp(ACMTRS, L_PostInfo_ACMTRS[i].ACmtrs) == 0)
      return  i;
  }
  return -1;
}


/*==========================================================================
     Objet :    Initialisation de la structure TRS
     Nom:       init_SubTrsLigne
     Parametres:
     Retour:    0
==========================================================================*/
void init_SubTrsLigne()
{
  strcpy(SubTrsLigne.DETTRNCOD_CF,  "");
  strcpy(SubTrsLigne.LOB_CF,        "");
  strcpy(SubTrsLigne.LOGSIG_CT,     "");
  strcpy(SubTrsLigne.SUBTRS_GL,     "");
  strcpy(SubTrsLigne.SUBTRS_GS,     "");
  strcpy(SubTrsLigne.SUBTRSEXP_D,   "");
  strcpy(SubTrsLigne.SUBTRSINC_D,   "");
  SubTrsLigne.CELLPROTECEXC_B       = 0;
  SubTrsLigne.CMT_NT                = 0;
  SubTrsLigne.COMPLEMENT_B          = 0;
  SubTrsLigne.DACTYPE_B             = 0;
  SubTrsLigne.NEWBALSHEETPROPAG_B   = 0;
  SubTrsLigne.TRSINPUTTYPE_CT       = 0;
  SubTrsLigne.TRSNATURE_CT          = 0;
  SubTrsLigne.TRSPURERETRO_B        = 0;
  SubTrsLigne.TRSTYPE_CT            = 0;
}


/*==============================================================================
objet :     Initialisation de la structure de rupture du Detail
retour:     OK
==============================================================================*/
int n_InitRuptPerim(T_RUPTURE_VAR *pbd_RuptPerim)
{
  DEBUT_FCT("n_InitRuptDetail");

  memset(pbd_RuptPerim, 0, sizeof(T_RUPTURE_VAR));

  // Ouverture du fichier Detail
  if (n_OpenFileAppl("ESTC5003_I5", "rt", &(pbd_RuptPerim->pf_InputFil)) == ERR)
    ExitPgm(ERR_XX , "Erreur ouverture fichier PERICASE");

  pbd_RuptPerim->n_NbRupture   = 0;
  pbd_RuptPerim->n_ActionLigne = n_ActionLignePerim;
  pbd_RuptPerim->c_Separ       = SEPARATEUR;

  RETURN_VAL(OK);
}


/*==============================================================================
  Objet :     chargement de la structure contenant les dates d'effet et d'expiration
  Parametre : pointeur sur ligne pericase
  retour :    -1 si depassement de capacite
==============================================================================*/
int n_ActionLignePerim(char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_ActionLignePerim");

  if (Kn_Dates < MAX_DATES)
  {
    if (ptb_InRec_Cur[PER_CTR_NF] == 0)
      return 0;
    strcpy(L_DATES[Kn_Dates].sz_CTR_NF, ptb_InRec_Cur[PER_CTR_NF]);
    strcpy(L_DATES[Kn_Dates].sz_SEC_NF, ptb_InRec_Cur[PER_SEC_NF]);
    strcpy(L_DATES[Kn_Dates].sz_UWY_NF, ptb_InRec_Cur[PER_UWY_NF]);

    if (strcmp(ptb_InRec_Cur[PER_CTRTYP_CT], "TRT") == 0)     // Accept
    {
      strcpy(L_DATES[Kn_Dates].sz_EFFET_D, ptb_InRec_Cur[PER_SCOINC_D]);

      if(strcmp(ptb_InRec_Cur[PER_SCOINC_D],"") != 0 && strcmp(ptb_InRec_Cur[PER_EXP_D],"") == 0)
      {
        strcpy(L_DATES[Kn_Dates].sz_EXPIRATION_D,ptb_InRec_Cur[PER_SCOINC_D]);
        L_DATES[Kn_Dates].sz_EXPIRATION_D[4]='1';
        L_DATES[Kn_Dates].sz_EXPIRATION_D[5]='2';
        L_DATES[Kn_Dates].sz_EXPIRATION_D[6]='3';
        L_DATES[Kn_Dates].sz_EXPIRATION_D[7]='1';
      }
      else
      {
        strcpy(L_DATES[Kn_Dates].sz_EXPIRATION_D, ptb_InRec_Cur[PER_EXP_D]);
      }
      
    }
    else if (strcmp(ptb_InRec_Cur[PER_CTRTYP_CT], "RET") == 0) // Retro
    {
      strcpy(L_DATES[Kn_Dates].sz_EFFET_D, ptb_InRec_Cur[PER_CTRINCUWY_D]);
      if(strcmp(ptb_InRec_Cur[PER_CTRINCUWY_D],"") != 0 && strcmp(ptb_InRec_Cur[PER_EXP_D],"") == 0)
      {
        strcpy(L_DATES[Kn_Dates].sz_EXPIRATION_D,ptb_InRec_Cur[PER_CTRINCUWY_D]);
        n_AddYears(L_DATES[Kn_Dates].sz_EXPIRATION_D, 1, '+', L_DATES[Kn_Dates].sz_EXPIRATION_D);
        n_AddDays( L_DATES[Kn_Dates].sz_EXPIRATION_D, 1, '-', L_DATES[Kn_Dates].sz_EXPIRATION_D);
      }
      else
      {
        strcpy(L_DATES[Kn_Dates].sz_EXPIRATION_D, ptb_InRec_Cur[PER_EXP_D]);
      }
    }
    Kn_Dates++;
  }
  else
  {
    printf("Taille max de la structure atteinte\n");
    return -1;
  }
  RETURN_VAL(OK);
}


/*==========================================================================
  Objet :     Recherche des dates d'effet et d'expiration
  Parametres: Pointeur sur ligne prevision
  Retour:     position des dates recherchees dans L_DATES ou -1 si non trouve
===========================================================================*/
int n_RechercheDates(char **ptb_InRec_Cur)
{
  int i=Kn_Cpt_Dates_ctrsec;

  for (; i < Kn_Dates; i++)
  {
    if(strcmp(sz_ref_CTR, L_DATES[i].sz_CTR_NF) || strcmp(sz_ref_SEC, L_DATES[i].sz_SEC_NF))
    {
      sprintf(sz_ref_CTR,"%s",L_DATES[i].sz_CTR_NF);
      sprintf(sz_ref_SEC,"%s",L_DATES[i].sz_SEC_NF);
      Kn_Cpt_Dates_ctrsec=i;
    }
    if (strcmp(L_DATES[i].sz_CTR_NF, ptb_InRec_Cur[DETAIL_CTR_NF]) == 0 &&
        strcmp(L_DATES[i].sz_SEC_NF, ptb_InRec_Cur[DETAIL_SEC_NF]) == 0 &&
        strcmp(L_DATES[i].sz_UWY_NF, ptb_InRec_Cur[DETAIL_UWY_NF]) == 0)
    {
      Kn_Cpt_Dates = i;
      return i;
    }
    if (strcmp(L_DATES[i].sz_CTR_NF, ptb_InRec_Cur[DETAIL_CTR_NF]) > 0 ||
        (strcmp(L_DATES[i].sz_CTR_NF, ptb_InRec_Cur[DETAIL_CTR_NF]) == 0 &&
         strcmp(L_DATES[i].sz_SEC_NF, ptb_InRec_Cur[DETAIL_SEC_NF]) > 0) ||
        (strcmp(L_DATES[i].sz_CTR_NF, ptb_InRec_Cur[DETAIL_CTR_NF]) == 0 &&
         strcmp(L_DATES[i].sz_SEC_NF, ptb_InRec_Cur[DETAIL_SEC_NF]) == 0 &&
         strcmp(L_DATES[i].sz_UWY_NF, ptb_InRec_Cur[DETAIL_UWY_NF]) > 0))
    {
      return -1;
    }
  }
  return -1; // si non trouve
}

/*==========================================================================
  Objet :     Calcul du ratio
  Parametres: Pointeur sur ligne prevision
  Retour:     ratio
===========================================================================*/
double  d_CalculerRatio(char **ptb_InRec_Cur)
{
  int   n_acy;
  int   n_annee_eff;
  int   n_annee_exp;
  int   n_Dates;
  int   n_diff_dates;
  int   n_jour_exp;
  int   n_mois_eff;
  int   n_mois_exp;
  int   n_tot_b;
  int   n_tot_eff;
  int   n_tot_exp;

  double d_ratio_default = Kn_mois / 12.0;

  n_acy = atoi(ptb_InRec_Cur[DETAIL_ACY_NF]);

  if (Kn_mode == PC)
  {
    n_Dates = n_RechercheDates(ptb_InRec_Cur);
    if (n_Dates == -1 ||
      strcmp(L_DATES[n_Dates].sz_EFFET_D,"") == 0 ||
      strcmp(L_DATES[n_Dates].sz_EXPIRATION_D,"") == 0) // dates non trouvees
    {
      if(atoi(ptb_InRec_Cur[DETAIL_ACY_NF]) < Kn_annee)
        return 1.0;
      if(atoi(ptb_InRec_Cur[DETAIL_ACY_NF]) > Kn_annee)
        return 0.0;
      return d_ratio_default;
    }

    sscanf(L_DATES[n_Dates].sz_EFFET_D,      "%4d%2d", &n_annee_eff, &n_mois_eff);
    sscanf(L_DATES[n_Dates].sz_EXPIRATION_D, "%4d%2d%2d", &n_annee_exp, &n_mois_exp, &n_jour_exp);

    // application R03 EST27 : Date d’expiration = mois d’expiration -1 sauf si la date d’expiration est le dernier jour de mois
    if(n_jour_exp != n_nbJoursDansMois(n_annee_exp, n_mois_exp))
    {
      if(n_mois_exp==1)
      {
        n_annee_exp--;
        n_mois_exp=12;
      }
      else
      {
        n_mois_exp--;
      }
    }

    // glissement des dates (sur ACY)
    n_diff_dates = n_acy - n_annee_eff;
    if(n_acy > n_annee_eff)
    {
      n_annee_eff = n_acy;
      if(n_mois_exp == 12)
      {
        n_mois_eff = 1;
        n_annee_exp = n_annee_eff;
      }
      else if(n_mois_exp == 1)
      {
        n_mois_eff = 2;
        n_annee_exp = n_annee_eff + 1;
      }
      else
      {
        n_mois_eff = n_mois_exp + 1;
        n_annee_exp = n_annee_eff + 1;
      }
    }

    n_tot_b   = 12 * Kn_annee + Kn_mois;
    n_tot_eff = 12 * n_annee_eff + n_mois_eff;
    n_tot_exp = 12 * n_annee_exp + n_mois_exp;

    if (n_tot_b >= n_tot_exp)
      return 1.0;

    if (n_tot_b < n_tot_eff)
      return 0.0;

    return 1.0 * ((n_tot_b < n_tot_exp ? n_tot_b : n_tot_exp) - (n_tot_eff - 1)) / (n_tot_exp - (n_tot_eff - 1));
  }
  return d_ratio_default;
}


/*==========================================================================
  Objet :     Acy Courante
  Parametres: Pointeur sur ligne prevision
  Retour:     0 si la prevision est courante
              -1 si la prevision est passee
              +1 si la prevision est future
===========================================================================*/
int n_AcyCourante(char **ptb_InRec_Cur)
{
  int n_Dates;
  int n_annee_eff;
  int n_mois_eff;
  int n_annee_exp;
  int n_mois_exp;
  int n_jour_exp;
  int n_acy;
  int n_diff_dates;
  int n_tot_b;
  int n_tot_eff;
  int n_tot_exp;

  n_acy = atoi(ptb_InRec_Cur[DETAIL_ACY_NF]);

  n_Dates = n_RechercheDates(ptb_InRec_Cur);
  if (n_Dates == -1 ||
    strcmp(L_DATES[n_Dates].sz_EFFET_D,"") == 0 ||
    strcmp(L_DATES[n_Dates].sz_EXPIRATION_D,"") == 0) // dates non trouvees
  {
    if(atoi(ptb_InRec_Cur[DETAIL_ACY_NF]) < Kn_annee)
      return -1;
    if(atoi(ptb_InRec_Cur[DETAIL_ACY_NF]) > Kn_annee)
      return 1;
    return 0;
  }
  
  sscanf(L_DATES[n_Dates].sz_EFFET_D,      "%4d%2d", &n_annee_eff, &n_mois_eff);
  sscanf(L_DATES[n_Dates].sz_EXPIRATION_D, "%4d%2d%2d", &n_annee_exp, &n_mois_exp, &n_jour_exp);

  // R03 Date d’expiration = mois d’expiration -1 sauf si la date d’expiration est le dernier jour du mois
  if(n_jour_exp < n_nbJoursDansMois(n_annee_exp,n_mois_exp))
  {
    n_mois_exp--;
    if(n_mois_exp < 1)
    {
      n_annee_exp--;
      n_mois_exp=12;
    }
  }

  // glissement des dates (sur ACY)
  n_diff_dates = n_acy - n_annee_eff;
  if(n_acy > n_annee_eff)
  {
    n_annee_eff = n_acy;
    if(n_mois_exp == 12)
    {
      n_mois_eff = 1;
      n_annee_exp = n_annee_eff;
    }
    else if(n_mois_exp == 1)
    {
      n_mois_eff = 2;
      n_annee_exp = n_annee_eff + 1;
    }
    else
    {
      n_mois_eff = n_mois_exp + 1;
      n_annee_exp = n_annee_eff + 1;
    }
  }

  n_tot_b   = 12 * Kn_annee + Kn_mois;
  n_tot_eff = 12 * n_annee_eff + n_mois_eff;
  n_tot_exp = 12 * n_annee_exp + n_mois_exp;

  if (n_tot_b > n_tot_exp)
    return -1;

  if (n_tot_b < n_tot_eff)
    return 1;

  return 0;
}

/*==========================================================================
  Objet :     Nombre de jours dans un mois
  Parametres: annee et mois
  Retour:     nombre de jours dans le mois
===========================================================================*/
int n_nbJoursDansMois(int annee, int mois)
{
  /* Case where the month of the settlement date is among [january, march, may, july, august, october or december] */
  if ((mois == 1) || (mois == 3) || (mois == 5) || (mois == 7) || (mois == 8) || (mois == 10) || (mois == 12))
  {
    return 31;
  }
  /* Case where the month of the settlement date is among [april, june, september or november] */
  if ((mois == 4) || (mois == 6) || (mois == 9) || (mois == 11))
  {
    return 30;
  }
  /* Case where the month of the settlement date is february, it must be taken into account that the year is a leap year or not */
  if (mois == 2)
  {
    /* Is it a leap year ? */
    if ((((annee % 4) == 0) && ((annee % 100) != 0)) || ((annee % 400) == 0))
      return 29;
    else
      return 28;
  }

  /* si non trouve (annee et/ou mois en parametre non valide) */
  return 0;
}