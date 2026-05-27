/*============================================================================
Nom de l'application          : Calcul des primes par periode de compte
Nom du source                 : ESTM1007.c
Revision                      : $Revision: 1.13 $
Date de creation              : 05/07/1997
Auteur                        : CGI      
Squelette de base             : batch   
------------------------------------------------------------------------------
Description :
  Calcul des primes par periode de compte pour les traites et les facs avec
  encapsulation du lot 60.
  En entree : perimetre traites et facs (fichier maitre),
              GT enrichi cumule traites et facs cedantes,
              perimetre des echeanciers de primes provisionnelles traites et
              facs,
              fichier des ultimes,
              GT normal des primes facs seulement estimees.
  En sortie : fichier de travail optimise traites (le nombre de lignes est
              reduit au minimum !!! Une ligne seulement est ecrite par affaire,
              annee de compte et periode de compte),
              GT des complements de primes traites et facs,
              fichier de travail optimise facs.
  Le perimetre est trie par contrat/avenant/section/exercice/numero d'ordre.
  Le GT est trie par contrat/avenant/section/exercice/numero d'ordre/
  annee de compte/mois de fin/mois de debut
           
------------------------------------------------------------------------------
Historique des modifications :
    <jj/mm/aaaa><auteur> <description de la modification>
     29/01/03   J. Ribot  ajout 1 champs a NULL en sortie pour retintamt_m
     01/04/1998 M.HA-THUC rajout d'une synchro supplementaire avec le GT des PNA et ecriture dans le fichier de travail
     27/03/2008 J. Ribot  SPOT 15219  ASE15 : recompilation des programmes C
     19/10/2009 PLG       Fiche SPOT n° 16778: Calcul des estimations de primes des traités non proportionnels liés à la saisonnalité
[03] 22/12/2009 GATIBELZA ESTDOM11174 Possible time limit for calculation of estimates  limiter le nombre d'années d'estimation de primes
[04] 05/02/2010 GATIBELZA ESTDOM16778 estimations de primes NP liés à la saisonnalité
[05] 11/05/2010 GATIBELZA ESTDOM11174 Possible time limit for calculation of estimates  limiter le nombre d'années d'estimation de primes
[06] 21/05/2010 GATIBELZA ESTDOM19486 Mauvaise imputation des charges sur les Non prop type=3 en cas de PNA
[07] 13/07/2010 GATIBELZA ESTDOM17226 V10 Bug Commission Estimates 
[08] 21/09/2010 GATIBELZA ESTDOM19486 V10  Inventaire Non prop type=3 Mauvaise imputation des charges sur les Non prop type=3 en cas de PNA
[09] 29/01/2015 MARAGNES  :spot:28140 Modification appel calculExerciceSeuil nouveau prototype  n_CalculExerciceSeuil(short ssd_cf , short esb_cf, char *lob_cf, short nat_cf )
                           Appel des fonctions init_calculExerciceSeuil pour charger les données du fichier FTTHRHLDUWY en mémoire, ferme_calculExerciceSeuil pour liberer la mémoire
[09] 21/04/2015 R. cassis :spot:28660 Add SSD_CF and ESB_CF to trace log data file and suppress warning msgs.
[10] 08/03/2016 Florent   :spot:29066 GLT à 71 colonnes
[11] 30/11/2017 MZA       :spira:65621 Probleme sur les periodes Scor Inverses. Recompiler pour prendre en compte les modifications dans  la librairie estlib (estserv.c)
[12] 04/12/2017 MZA       :spira 42212 : Traités décalés : les primes sont calculées au prorata du nombre de jours dans un mois 
[013]24/01/2018 MZA       :spira 63718 : Ne plus effectuer les estimations sur les traites NP dont l'état est "FinalizedAcc" (ie PER_SBJCPTDEF_B=TRUE)
[014]09/03/2018 MZA       :spira:67817 Anomalie UAT ESID2002 et Suppression des traces et prise compte des TRAITES "Closed Administr" dans la gestion des DECALES  
[015]30/05/2018 MZA       :spira 63718 : Ne plus effectuer les estimations sur les traites NP dont l'état est "FinalizedAcc" (ie PER_SBJCPTDEF_B=TRUE)
[016]25/06/2018 MZA       :spira 69614 : Revert 42212 des traités décalés 
[017]13/09/2018 MZA				:spira 42212 : Reactivation du revert sur la 42212 : Correction, utilisation du nb de jours de la cedante lors de la ventilation des Scor Periode
[018]22/11/2018 MZA       :spira 42212 : Revert Nouveau 42212 
[019]20/09/2019 MZA       :spira 42212 : TESTS  
[020]24/08/2019 S.Behague :REQ_9.2: REQ.P.9.2 - Change in UPR calculation rules
[021]17/10/2019 MZA       :spira 42212 : TESTS ET Mise en commentaire des TRACES
[022]26/11/2019 RV        :spira 83211 : delete function n_CalculPrmEstTraitNonPropSaisonnalite and use only n_CalculPrmEstTraitNonPropSaisonnalite_02
[023]13/02/2020 MZA       :spira 42212 : Traites decales : Reactivation et prise en comptes des nouvelles fonctionnalités.
[024]28/02/2020 MiS       :REQ.P.09.6  : Calcul de PNA IFRS17
[025]09/04/2020 MZM       :Spira:42212 Ajout de la date de derniere Compta
[026]05/05/2020 MZM       :Spira:86967 Ajout REgle de ventilation Scor Periode, ACY si different de UWY 
[027]23/07/2020 MZM       :spira:88801 Revert 42212 Desactivativation de la fonction n_CalculPrmEstTraitPropDecale
[028]20/10/2020 LEL       :spira:90956 INT AZURE correction 
[029]22/10/2020 MiS       :spira:90831 DAC IFRS17
[030]28/10/2022 MZM       :spira:107501 PRD URGENT - Undue premium estimates :ANO RE INITIALISATION APRES SYNCHRO
==============================================================================*/


/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <stdarg.h>
#include <struct.h>
#include <estserv.h>

#define SEUIL_PRIME     ((double)1)     /* PLG 19/10/2009 - Fiche Spot n° 16778 */
#define SEUIL_MONTANT   ((double)0.01)  /* [007] */

/*----------------------------------------*/
/* inclusion de version dans les binaires */
/*----------------------------------------*/
static char VERSION_ESTM1007_C[150] = "__version__: ESTM1007.c version [030]   28/10/2022 : Undue Premium"; 

/*----------------------*/     
/* Variables de travail */
/*----------------------*/
FILE     *Kp_OutputFile1; /* Pointeur sur le fichier GT des primes        */
FILE     *Kp_OutputFile2; /* Pointeur sur le fichier de travail traites   */
FILE     *Kp_OutputFile3; /* Pointeur sur le fichier de travail facs      */
FILE     *Kp_OutputFile4; /* PLG 19/10/2009 - Fiche Spot n° 16778     :Pointeur sur le fichier de trace des primes estimées et PNA calculées */
FILE     *Kp_OutputFile5; /* [006] */

T_RUPTURE_VAR *pbd_Rupture;             /* Pointeur sur la structure du perimetre */
T_RUPTURE_SYNC_VAR *pbd_SyncGT;         /* Pointeur sur la structure de synchronisation avec le GT traites et facs cedantes             */
T_RUPTURE_SYNC_VAR *pbd_SyncPRMD;       /* Pointeur sur la structure de synchronisation avec le perimetre des echeanciers de primes     */
T_RUPTURE_SYNC_VAR *pbd_SyncCTRULT;     /* Pointeur sur la structure de synchronisation avec le fichier des ultimes                     */
T_RUPTURE_SYNC_VAR *pbd_SyncGTFAC;      /* Pointeur sur la structure de synchronisation avec le GT facs estimees                        */
T_RUPTURE_SYNC_VAR *pbd_SyncGTFACPNAE;  /* Pointeur sur la structure de synchronisation avec le GT facs des PNA estimees                */
T_RUPTURE_SYNC_VAR *pbd_SyncSinNP;      /* PLG 19/10/2009 - Fiche Spot n° 16778 : Pointeur sur la structure de synchronisation avec les taux de sinistralité des traités non proportionels */

char Ksz_CLODAT_D[9];                   /* Date de libelle d'inventaire */
int Kn_CloDatD, Kn_CloDatM, Kn_CloDatY; // [029]

T_EchPrmRecu Ktbd_EchPrm[NBPOSTECHPRM_MAX]; /* Tableau de structures des echeanciers de primes recues. Rempli avec le GT            */
T_EchSous Ktbd_EchSous[NBEchSous_MAX];      /* Tableau des montants des echeanciers de souscription Rempli par le fichier FPERIPRMD */
T_PrmEst Ktbd_PrmEst[NBPrmEst_MAX];         /* Tableau des montants du GT par annee de compte/periode de compte pour optimiser le nombre de ligne du fichier de sortie */
int Kn_NbrePrmEst;                          /* Nombre de lignes du tableau Ktbd_PrmEst  */
int Kn_CompteurPrmEst;                      /* Numero de ligne du tableau Ktbd_PrmEst   */
int Kn_NbreEchPrm;                          /* Nombre de lignes du tableau Ktbd_EchPrm  */
int Kn_CompteurEchPrm;                      /* Numero de ligne du tableau Ktbd_EchPrm   */
int Kn_NbreEchSous;                         /* Nombre de lignes du tableau Ktbd_EchSous */
int Kn_CompteurEchSous;                     /* Numero de ligne du tableau Ktbd_EchSous  */

char Ksz_MessageErr[256];                   /* Message d'erreur */
char **Kptsz_LigneEsclaveCTRULT;            /* Pointeur sur la ligne de FCTRULT pour utilisation dans le maitre                                     */
char **Kptsz_LigneEsclaveSinNP;             /* PLG 19/10/2009 - Fiche Spot n° 16778 : Pointeur sur la ligne de SinNP pour utilisation dans le maitre*/

short Ks_ACY_NF;                            /* Derniere annee de compte pour le poste 10000 */
short Ks_SCOENDMTH_NF;                      /* Dernier mois de fin de compte pour le poste 10000 */

int Ks_ACY_NF_02;                            /* Derniere annee de compte extrait du Pericase Etendu */
int Ks_SCOENDMTH_NF_02;                      /* Dernier mois de fin de compte Extrait du Pericase Etendu */
int Ks_DAY_NF_02 ;                           /* Jour de la date de derniere Compta */

char Ks_Date_DerCpa[9];

double Kd_Prm;                              /* Montant prime recue (poste 10000 du GT)  */
char Ksz_Annee[5];                          /* Annee de la date d'inventaire            */
char Ksz_Mois[3];                           /* Mois de la date d'inventaire             */
char Ksz_Jour[3];                           /* Jour de la date d'inventaire             */

BOOL Kb_ReturnStatus = 0; /* statut de retour du pgm (=0 si OK, 1 sinon) */

/* [024] Fonction pour le calcul de UPR REQ 9.6 */
double d_CalculPNAIFRS17 (double d_EGPI, char sz_IncDat[9], char sz_CloDat[9], char sz_ExpDat[9], double d_ITDWP);
/* [024] Variables REQ 9.6 */
double d_EGPI;
double d_ITDWP;


/*----------------------------------*/
/* Fonctions du fichier IADPERICASE */
/*----------------------------------*/
int n_InitRupture  (T_RUPTURE_VAR  *pbd_Rupture);
int n_ActionLigneRupture (char *ptsz_LigneCour[]);

/*----------------------------------------------------------*/
/* Fonctions de la synchronisation entre IADPERICASE et GT  */
/*----------------------------------------------------------*/
int n_InitSyncGT  (T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ConditionSyncGT (char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ActionLigneSyncGT (char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);

/*------------------------------------------------------------------*/
/* Fonctions de la synchronisation entre IADPERICASE et IADPERIPRMD */
/*------------------------------------------------------------------*/
int n_InitSyncPRMD  (T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ConditionSyncPRMD (char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ActionLigneSyncPRMD(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);

/*--------------------------------------------------------------*/
/* Fonctions de la synchronisation entre IADPERICASE et FCTRULT */
/*--------------------------------------------------------------*/
int n_InitSyncCTRULT  (T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ConditionSyncCTRULT(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ActionLigneSyncCTRULT(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ActionPereSansFilsCTRULT(char **ptsz_LigneMaitre);


/*--------------------------------------------------------------*/
/* Fonctions de la synchronisation entre IADPERICASE et GT Facs */
/*--------------------------------------------------------------*/
int n_InitSyncGTFAC (T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ConditionSyncGTFAC(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ActionLigneSyncGTFAC(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);


/*-------------------------------------------------------------------------------*/
/* Fonctions de la synchronisation entre IADPERICASE et GT Facs des PNA estimees */
/*-------------------------------------------------------------------------------*/
int n_InitSyncGTFACPNAE   (T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ConditionSyncGTFACPNAE  (char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ActionLigneSyncGTFACPNAE  (char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);


/* PLG 19/10/2009 - Fiche Spot n° 16778 */
/*----------------------------------------------------------------------------------------------------------*/
/* Fonctions de la synchronisation entre IADPERICASE et taux de sinistralité des traités non proportionnels */
/*----------------------------------------------------------------------------------------------------------*/
int n_InitSyncSinNP       (T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ConditionSyncSinNP    (char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ActionLigneSyncSinNP  (char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
/* Fin PLG 19/10/2009 */

int n_initCalculExerciceSeuil(char *nomFic);
int n_CalculExerciceSeuil(short  , short esb_cf, char *lob_cf, short nat_cf );
/* PLG 19/10/2009 - Fiche Spot n° 16778 */
int     n_PremierMoisTrimestre(int);
void    CalculRatioNonPropSaisonnalite(char **, int, int, int, int, int *, double *);
void    n_CalculTauxPrimeAcquise(char **, int, int, double, double *);
int     n_CalculPrmEstTraitNonPropSaisonnalite_02(short, char *, char *, char *, char *, char, int, double, char **, short, T_EchPrmRecu *, char *, char *); // [013] [022]



/* Constantes qui paramètrent les postes comptables */
#define POSTE_CPTABLE_ESTIMATION_PROP       11100002
#define POSTE_CPTABLE_ESTIMATION_NON_PROP   11101002
#define POSTE_CPTABLE_PNA_NON_PROP          11410006
#define POSTE_CPTABLE_PNA_IFRS17            1141000I //[024]
/* Fin PLG 19/10/2009 */

/**************************************************************************/
/*** Objet : synchronisation entre le fichier maitre et esclave       ***/
/*** Nom : main                   ***/
/*** Parametres:              ***/
/***  i argc : nombre de parametres         ***/
/***  i argv : tableau de pointeurs sur les parametres    ***/
/*** Retour:                ***/
/***  OK si pas d'erreur,           ***/
/***  ERR si erreur.              ***/
/**************************************************************************/
int main( int argc, char *argv[] )
{
  pbd_Rupture       = malloc(sizeof(T_RUPTURE_VAR));
  pbd_SyncGT        = malloc(sizeof(T_RUPTURE_SYNC_VAR));
  pbd_SyncPRMD      = malloc(sizeof(T_RUPTURE_SYNC_VAR));
  pbd_SyncCTRULT    = malloc(sizeof(T_RUPTURE_SYNC_VAR));
  pbd_SyncGTFAC     = malloc(sizeof(T_RUPTURE_SYNC_VAR));
  pbd_SyncGTFACPNAE = malloc(sizeof(T_RUPTURE_SYNC_VAR));
  pbd_SyncSinNP     = malloc(sizeof(T_RUPTURE_SYNC_VAR));       /* PLG 19/10/2009 - Fiche Spot n° 16778 */

  /* Initialisation des signaux */
  InitSig();

  if (n_BeginPgm(argc, argv) == ERR)
    ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");

  /* Recuperation du parametre correspondant a la date libelle d'inventaire */
  strcpy(Ksz_CLODAT_D, psz_GetCharArgv(1));
  Ksz_Annee[0] = Ksz_CLODAT_D[0];
  Ksz_Annee[1] = Ksz_CLODAT_D[1];
  Ksz_Annee[2] = Ksz_CLODAT_D[2];
  Ksz_Annee[3] = Ksz_CLODAT_D[3];
  Ksz_Annee[4] = '\0';
  Ksz_Mois[0] = Ksz_CLODAT_D[4];
  Ksz_Mois[1] = Ksz_CLODAT_D[5];
  Ksz_Mois[2] = '\0';
  Ksz_Jour[0] = Ksz_CLODAT_D[6];
  Ksz_Jour[1] = Ksz_CLODAT_D[7];
  Ksz_Jour[2] = '\0';

	printf("\n Running with %s  \n", VERSION_ESTM1007_C);

  /* Ouverture du fichier GT */
  if (n_OpenFileAppl("ESTM1007_O1", "wt", &Kp_OutputFile1) == ERR)
    ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");

  /* Ouverture du fichier de travail traites */
  if (n_OpenFileAppl("ESTM1007_O2", "wt", &Kp_OutputFile2) == ERR)
    ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");

  /* Ouverture du fichier de travail facs */
  if (n_OpenFileAppl("ESTM1007_O3", "wt", &Kp_OutputFile3) == ERR)
    ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");

  /* PLG 19/10/2009 - Fiche Spot n° 16778 */
  /* Ouverture du fichier des traces des primes estimées et PNA calculées */
  if (n_OpenFileAppl("ESTM1007_O4", "wt", &Kp_OutputFile4) == ERR)
    ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");

  //[006] Ouverture du fichier de travail PNA négatives
  if (n_OpenFileAppl("ESTM1007_O5", "wt", &Kp_OutputFile5) == ERR)
    ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");

  /* Initialisation de la structure de rupture */
  if (n_InitRupture(pbd_Rupture) == ERR)
    ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupture");

  /* Initialisation de la structure de synchronisation avec le GT */
  if (n_InitSyncGT(pbd_SyncGT) == ERR)
    ExitPgm(ERR_XX, "Erreur appel fonction n_InitSync");

  /* Initialisation de la structure de synchronisation avec IADPERIPRMD */
  if (n_InitSyncPRMD(pbd_SyncPRMD) == ERR)
    ExitPgm(ERR_XX, "Erreur appel fonction n_InitSync");

  /* Initialisation de la structure de synchronisation avec FCTRULT */
  if (n_InitSyncCTRULT(pbd_SyncCTRULT) == ERR)
    ExitPgm(ERR_XX, "Erreur appel fonction n_InitSync");

  /* Initialisation de la structure de synchronisation avec le GT facs */
  if (n_InitSyncGTFAC(pbd_SyncGTFAC) == ERR)
    ExitPgm(ERR_XX, "Erreur appel fonction n_InitSync");

  /* Initialisation de la structure de synchronisation avec le GT facs des PNA estimees */
  if (n_InitSyncGTFACPNAE(pbd_SyncGTFACPNAE) == ERR)
    ExitPgm(ERR_XX, "Erreur appel fonction n_InitSync");

  /* PLG 19/10/2009 - Fiche Spot n° 16778 */
  /* Initialisation de la structure de synchronisation avec les taux de saisonnalité des traités non proportionnels */
  if (n_InitSyncSinNP(pbd_SyncSinNP) == ERR)
    ExitPgm(ERR_XX, "Erreur appel fonction n_InitSynSinNP");
  /* Fin PLG 19/10/2009 */

  if (n_initCalculExerciceSeuil("ESTM1007_I8"))
    ExitPgm( ERR_XX , "" ) ;

  /* Lancement du traitement du fichier maitre */
  if (n_ProcessingRuptureVar(pbd_Rupture) == ERR)
    ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");

  if (n_CloseFileAppl("ESTM1007_I1", &(pbd_Rupture->pf_InputFil)) == ERR)
    ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");

  if (n_CloseFileAppl("ESTM1007_I2", &(pbd_SyncGT->pf_InputFil)) == ERR)
    ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");

  if (n_CloseFileAppl("ESTM1007_I3", &(pbd_SyncPRMD->pf_InputFil)) == ERR)
    ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");

  if (n_CloseFileAppl("ESTM1007_I4", &(pbd_SyncCTRULT->pf_InputFil)) == ERR)
    ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");

  if (n_CloseFileAppl("ESTM1007_I5", &(pbd_SyncGTFAC->pf_InputFil)) == ERR)
    ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");

  if (n_CloseFileAppl("ESTM1007_I6", &(pbd_SyncGTFACPNAE->pf_InputFil)) == ERR)
    ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");

  /* PLG 19/10/2009 - Fiche Spot n° 16778 */
  if (n_CloseFileAppl("ESTM1007_I7", &(pbd_SyncSinNP->pf_InputFil)) == ERR)
    ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
  /* Fin PLG 19/10/2009 */

  if (n_CloseFileAppl("ESTM1007_O1", &Kp_OutputFile1) == ERR)
    ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");

  if (n_CloseFileAppl("ESTM1007_O2", &Kp_OutputFile2) == ERR)
    ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");

  if (n_CloseFileAppl("ESTM1007_O3", &Kp_OutputFile3) == ERR)
    ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");

  /* PLG 19/10/2009 - Fiche Spot n° 16778 */
  if (n_CloseFileAppl("ESTM1007_O4", &Kp_OutputFile4) == ERR)
    ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
  /* Fin PLG 19/10/2009 */

  //[006]
  if (n_CloseFileAppl("ESTM1007_O5", &Kp_OutputFile5) == ERR)
    ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");

  if (n_EndPgm() == ERR)
    ExitPgm(ERR_XX, "Erreur appel fonction n_EndPgm");
  free(pbd_Rupture);
  free(pbd_SyncGT);
  free(pbd_SyncPRMD);
  free(pbd_SyncCTRULT);
  free(pbd_SyncGTFAC);
  free(pbd_SyncGTFACPNAE);
  /* PLG 19/10/2009 - Fiche Spot n° 16778 */
  free(pbd_SyncSinNP);
  /* Fin PLG 19/10/2009 */

  exit(Kb_ReturnStatus);
}


/**************************************************************************/
/*** Objet : initialisation de la structure de rupture                  ***/
/***                                                                    ***/
/*** Nom : n_InitRupture                                                ***/
/*** Parametres:                                                        ***/
/***  i pbd_Rupture : pointeur sur la structure de rupture            ***/
/*** Retour:                                                            ***/
/***  OK si pas d'erreur,                                             ***/
/***  ERR si erreur.                                                  ***/
/**************************************************************************/
int n_InitRupture( T_RUPTURE_VAR *pbd_Rupture )
{
  DEBUT_FCT("n_InitRupture");
  memset(pbd_Rupture, 0, sizeof(T_RUPTURE_VAR));

  /* Ouverture du fichier maitre */
  if (n_OpenFileAppl("ESTM1007_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR)
  {
    RETURN_VAL(ERR);
  }
  pbd_Rupture->n_ActionLigne = n_ActionLigneRupture;
  pbd_Rupture->c_Separ = '~';

  RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : initialisation de la synchronisation de IADPERICASE avec   ***/
/***         le GT                                                      ***/
/*** Nom : n_InitSyncGT                                                 ***/
/*** Parametres:                                                        ***/
/***  i pbd_Sync : pointeur sur la structure de synchro               ***/
/*** Retour:                                                            ***/
/***  OK si pas d'erreur,                                             ***/
/***  ERR si erreur.                                                  ***/
/**************************************************************************/
int n_InitSyncGT( T_RUPTURE_SYNC_VAR  *pbd_SyncGT )
{
  DEBUT_FCT("n_InitSyncGT");
  memset(pbd_SyncGT, 0, sizeof(T_RUPTURE_SYNC_VAR));

  /* Ouverture du fichier esclave */
  if (n_OpenFileAppl("ESTM1007_I2", "rt", &(pbd_SyncGT->pf_InputFil)) == ERR)
  {
    RETURN_VAL(ERR);
  }
  pbd_SyncGT->ConditionEndSync = n_ConditionSyncGT;
  pbd_SyncGT->n_ActionLigne = n_ActionLigneSyncGT;
  pbd_SyncGT->c_Separ = '~';

  RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : initialisation de la synchronisation de IADPERICASE avec   ***/
/***         IADPERIPRMD                                                ***/
/*** Nom : n_InitSyncPRMD                                               ***/
/*** Parametres:                                                        ***/
/***  i pbd_Sync : pointeur sur la structure de synchro               ***/
/*** Retour:                                                            ***/
/***  OK si pas d'erreur,                                             ***/
/***  ERR si erreur.                                                  ***/
/**************************************************************************/
int n_InitSyncPRMD( T_RUPTURE_SYNC_VAR  *pbd_SyncPRMD )
{
  DEBUT_FCT("n_InitSyncPRMD");
  memset(pbd_SyncPRMD, 0, sizeof(T_RUPTURE_SYNC_VAR));

  /* Ouverture du fichier esclave */
  if (n_OpenFileAppl("ESTM1007_I3", "rt", &(pbd_SyncPRMD->pf_InputFil)) == ERR) {
    RETURN_VAL(ERR);
  }
  pbd_SyncPRMD->ConditionEndSync = n_ConditionSyncPRMD;
  pbd_SyncPRMD->n_ActionLigne = n_ActionLigneSyncPRMD;
  pbd_SyncPRMD->c_Separ = '~';

  RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : initialisation de la synchronisation de IADPERICASE avec   ***/
/***         FCTRULT                                                    ***/
/*** Nom : n_InitSyncCTRULT                                             ***/
/*** Parametres:                                                        ***/
/***  i pbd_Sync : pointeur sur la structure de synchro               ***/
/*** Retour:                                                            ***/
/***  OK si pas d'erreur,                                             ***/
/***  ERR si erreur.                                                  ***/
/**************************************************************************/
int n_InitSyncCTRULT( T_RUPTURE_SYNC_VAR  *pbd_SyncCTRULT )
{
  DEBUT_FCT("n_InitSyncCTRULT");
  memset(pbd_SyncCTRULT, 0, sizeof(T_RUPTURE_SYNC_VAR));

  /* Ouverture du fichier esclave */
  if (n_OpenFileAppl("ESTM1007_I4", "rt", &(pbd_SyncCTRULT->pf_InputFil)) == ERR)
  {
    RETURN_VAL(ERR);
  }
  pbd_SyncCTRULT->ConditionEndSync = n_ConditionSyncCTRULT;
  pbd_SyncCTRULT->n_ActionLigne = n_ActionLigneSyncCTRULT;
  pbd_SyncCTRULT->n_PereSansFils = n_ActionPereSansFilsCTRULT;
  pbd_SyncCTRULT->c_Separ = '~';

  RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : initialisation de la synchronisation de IADPERICASE avec   ***/
/***         le GT normal des facs                                      ***/
/*** Nom : n_InitSyncGTFAC                                              ***/
/*** Parametres:                                                        ***/
/***  i pbd_Sync : pointeur sur la structure de synchro               ***/
/*** Retour:                                                            ***/
/***  OK si pas d'erreur,                                             ***/
/***  ERR si erreur.                                                  ***/
/**************************************************************************/
int n_InitSyncGTFAC( T_RUPTURE_SYNC_VAR  *pbd_SyncGTFAC )
{
  DEBUT_FCT("n_InitSyncGTFAC");
  memset(pbd_SyncGTFAC, 0, sizeof(T_RUPTURE_SYNC_VAR));

  /* Ouverture du fichier esclave */
  if (n_OpenFileAppl("ESTM1007_I5", "rt", &(pbd_SyncGTFAC->pf_InputFil)) == ERR)
  {
    RETURN_VAL(ERR);
  }
  pbd_SyncGTFAC->ConditionEndSync = n_ConditionSyncGTFAC;
  pbd_SyncGTFAC->n_ActionLigne = n_ActionLigneSyncGTFAC;
  pbd_SyncGTFAC->c_Separ = '~';

  RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : initialisation de la synchronisation de IADPERICASE avec   ***/
/***         le GT normal des facs des PNA estimees                     ***/
/*** Nom : n_InitSyncGTFACPNAE                                          ***/
/*** Parametres:                                                        ***/
/***  i pbd_Sync : pointeur sur la structure de synchro               ***/
/*** Retour:                                                            ***/
/***  OK si pas d'erreur,                                             ***/
/***  ERR si erreur.                                                  ***/
/**************************************************************************/
int n_InitSyncGTFACPNAE( T_RUPTURE_SYNC_VAR  *pbd_SyncGTFACPNAE )
{
  DEBUT_FCT("n_InitSyncGTFACPNAE");
  memset(pbd_SyncGTFACPNAE, 0, sizeof(T_RUPTURE_SYNC_VAR));

  /* Ouverture du fichier esclave */
  if (n_OpenFileAppl("ESTM1007_I6", "rt", &(pbd_SyncGTFACPNAE->pf_InputFil)) == ERR)
  {
    RETURN_VAL(ERR);
  }
  pbd_SyncGTFACPNAE->ConditionEndSync = n_ConditionSyncGTFACPNAE;
  pbd_SyncGTFACPNAE->n_ActionLigne = n_ActionLigneSyncGTFACPNAE;
  pbd_SyncGTFACPNAE->c_Separ = '~';

  RETURN_VAL(OK);
}

/* PLG 19/10/2009 - Fiche Spot n° 16778 */
/**************************************************************************/
/*** Objet : initialisation de la synchronisation de IADPERICASE avec   ***/
/***         les taux de sinistralité des traités non proportionnels    ***/
/***                                                  ***/
/*** Nom : n_InitSyncSinNP                                    ***/
/***                                                  ***/
/*** Parametres:                                          ***/
/***  i pbd_Sync : pointeur sur la structure de synchro           ***/
/***                                                  ***/
/*** Retour:                                            ***/
/***  OK si pas d'erreur,                                   ***/
/***  ERR si erreur.                                      ***/
/**************************************************************************/

int n_InitSyncSinNP(T_RUPTURE_SYNC_VAR  *pbd_SyncSinNP)
{
  DEBUT_FCT("n_InitSyncSinNP");
  memset(pbd_SyncSinNP, 0, sizeof(T_RUPTURE_SYNC_VAR));

  /* Ouverture du fichier esclave */
  if (n_OpenFileAppl("ESTM1007_I7", "rt", &(pbd_SyncSinNP->pf_InputFil)) == ERR)
    RETURN_VAL(ERR);
  pbd_SyncSinNP->ConditionEndSync = n_ConditionSyncSinNP;
  pbd_SyncSinNP->n_ActionLigne    = n_ActionLigneSyncSinNP;
  pbd_SyncSinNP->c_Separ          = '~';

  RETURN_VAL(OK);
}
/* Fin PLG 19/10/2009 */

/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du fichier maitre  ***/
/***                  ***/
/*** Nom : n_ActionLigneRupture           ***/
/***                  ***/
/*** Parametres:              ***/
/***  i ptsz_LigneCour : pointeur sur la ligne courante   ***/
/***                  ***/
/*** Retour:                ***/
/***  OK si pas d'erreur,           ***/
/***  ERR si erreur.              ***/
/**************************************************************************/

int n_ActionLigneRupture(char *ptsz_LigneCour[])
{
  double  d_Part;             /* Part SCOR courante */
  int     n_PosteComptable;   /* Poste comptable de primes Proportionnel ou Non Proportionnel dans le GT */
  int     Kn_CompteurEchPrm;  /* Compteur du tableau des echeanciers de primes recues */
  int     NbJoursValiditesContrat; /* Nombre de jours entre la date de debut et la date de fin du contrat*/
  short   s_PRMD_B;           /* Vaut 1 s'il existe au mons une ligne dans le fichier des echeanciers, 0 autrement */
  short   s_LigneExistante;   /* Vaut 1 si la ligne a ete trouvee dans le tableau, 0 autrement */
  double  d_retamtprm ;
  FILE    *p_OutputFileGT;
  short s_acy;
  unsigned char c_scostrmth;
  unsigned char c_scoendmth;
  int 	 flg_w = 0;			/* flag ecriture PNA IFRS17 */
  int    n_va2, n_va1, n_vm2, n_vm1, n_vj2, n_vj1;
  int    n_Traite_Decale;     /* [12] Variable permettant de verifier qu'un traite est decalé */
  
  double Kd_PNAIFRS17 = 0; /* [028] */
  d_EGPI = atof(ptsz_LigneCour[PER_SCOEGP_M]);
  
  DEBUT_FCT("n_ActionLigneRupture");

  /* Calcul de la part SCOR courante */

  
  if (*ptsz_LigneCour[PER_LIARIDSHA_B] == '0')
  {
    d_Part = atof(ptsz_LigneCour[PER_RIDSHA_R]) * atof(ptsz_LigneCour[PER_CUTSHA_R]);
  }
  else
  {
    d_Part = atof(ptsz_LigneCour[PER_CUTSHA_R]);
  }
	
	
  /* Synchronisation avec le GT des complements de prime traites et facs */
  memset(Ktbd_PrmEst, 0, sizeof(T_PrmEst)*NBPrmEst_MAX);
  Ks_ACY_NF = 0;
  Ks_SCOENDMTH_NF = 0;
  Kd_Prm = 0;
  Kn_NbreEchPrm = 0;
  Kn_NbrePrmEst = 0;
  n_ProcessingRuptureSyncVar(pbd_SyncGT, ptsz_LigneCour);

  /* Synchronisation avec le fichier des ultimes pour les traites */
  if (*ptsz_LigneCour[PER_CTRNAT_CT] != 'F')
  {
    n_ProcessingRuptureSyncVar(pbd_SyncCTRULT, ptsz_LigneCour);
    
  }


  d_retamtprm = (Kptsz_LigneEsclaveCTRULT) ? atof(Kptsz_LigneEsclaveCTRULT[ULT_RETAMTPRM_M]) : 0 ;
  	  	
  Kptsz_LigneEsclaveCTRULT = 0 ;  	// [030] ANO INITIALISATION 
  	
  /* Cas proportionnels */
  if (*ptsz_LigneCour[PER_CTRNAT_CT] == 'P')
  {
    /******************************************************************/
    /* Modifs du 14/05/98 - M.HA-THUC                       */
    /* On ne calcule pas de primes estimees pour les traites si     */
    /* l'exercice est strictement inferieur a l'exercice seuil.       */
    /* L'exercice seuil est defini dans la fonction             */
    /*  n_CalculExerciceSeuilPre ( estserv.c )                    */
    /******************************************************************/
    // spot 28140 Modificaiton   des parametres d'appel de la fonction n_CalculExerciceSeuil
    if ( atoi( ptsz_LigneCour[PER_UWY_NF] ) >= n_CalculExerciceSeuil( atoi(ptsz_LigneCour[PER_SSD_CF]), atoi(ptsz_LigneCour[PER_ACCESB_CF]), ptsz_LigneCour[PER_LOB_CF], atoi(ptsz_LigneCour[PER_NAT_CF]) ))
    {
      /* Appel du module de calcul Lot 60 */
	  
	  /* MZ Affichage des variables utilisees 
	  printf("AFFICHAGE DES ENREG AVANT APPEL A n_CalculPrmEstTraitProp : CTR %s, END %s, SEC %s, UWY %s, UW %s, ACCFRQ %s, SECINC %s, SCOINC %s, EXP %s, DIFMTH %s : TRACE DE VERIFICATION AVANT\n",
              ptsz_LigneCour[PER_CTR_NF],
              ptsz_LigneCour[PER_END_NT],
              ptsz_LigneCour[PER_SEC_NF],
              ptsz_LigneCour[PER_UWY_NF],
              ptsz_LigneCour[PER_UW_NT],
			  ptsz_LigneCour[PER_ACCFRQ_CT],
			  ptsz_LigneCour[PER_SECINC_D],
			  ptsz_LigneCour[PER_SCOINC_D],
			  ptsz_LigneCour[PER_EXP_D],
			  ptsz_LigneCour[PER_DIFMTH_NF]
			  );			  
		
        printf( "AVANT APPEL%s~%s~%s~%s~%s~%s~%d~%d~%d~%s~%s~%s~%s~\n", 
                Ksz_CLODAT_D,
                ptsz_LigneCour[PER_CTR_NF],
                ptsz_LigneCour[PER_END_NT],
                ptsz_LigneCour[PER_SEC_NF],
                ptsz_LigneCour[PER_UWY_NF],
                ptsz_LigneCour[PER_UW_NT],
                Ktbd_PrmEst[Kn_CompteurPrmEst].ACY_NF,
                Ktbd_PrmEst[Kn_CompteurPrmEst].SCOSTRMTH_NF,
                Ktbd_PrmEst[Kn_CompteurPrmEst].SCOENDMTH_NF,
			  				ptsz_LigneCour[PER_SECINC_D],                
                ptsz_LigneCour[PER_UWY_NF],
                ptsz_LigneCour[PER_SSD_CF], 
                ptsz_LigneCour[PER_EGPCUR_CF]);		
		MZ */
	  /* [12] DEB */		
	  NbJoursValiditesContrat = 0;	 
	  
	  // [025] Recup Date Derniere Compta 
 
	  strcpy(Ks_Date_DerCpa, ptsz_LigneCour[PER_DATDERCPA_D]);	
	  o_ExtractionAnneeMoisJour(ptsz_LigneCour[PER_DATDERCPA_D], &Ks_ACY_NF_02, &Ks_SCOENDMTH_NF_02, &Ks_DAY_NF_02); 	

     

      o_ExtractionAnneeMoisJour(ptsz_LigneCour[PER_SECINC_D], &n_va1, &n_vm1, &n_vj1);      
      	
      o_ExtractionAnneeMoisJour(ptsz_LigneCour[PER_EXP_D], &n_va2, &n_vm2, &n_vj2);				
	
	  NbJoursValiditesContrat = nbJours_Entre_Deux_Dates(n_vj1, n_vm1, n_va1, n_vj2, n_vm2, n_va2);	    
	  
	  n_Traite_Decale = n_Verif_Traite_Decale(ptsz_LigneCour[PER_SECINC_D], ptsz_LigneCour[PER_EXP_D]);  /* n_Verif_Traite_Decale :Fonction verifie si un traite est decale */ 
	
	  /* DEB [023] */                         
    
	  		//if ( (n_Traite_Decale ) &&  ( strcmp(ptsz_LigneCour[PER_CTR_NF], "TR0033288" ) ==0 ) &&  atoi(ptsz_LigneCour[PER_UWY_NF]) == 2018)      //"02U037023"  06T006593~0~1~2014  TR0041316~0~1~2019   
	  	  //if ( (n_Traite_Decale ) &&  ( strcmp(ptsz_LigneCour[PER_CTR_NF], "02T036512" ) ==0) && (atoi(ptsz_LigneCour[PER_UWY_NF]) == 2014)  && (atoi(ptsz_LigneCour[PER_SEC_NF]) == 7) )
				//if ( ((n_Traite_Decale ) &&  atoi(ptsz_LigneCour[PER_UWY_NF]) == 2015  && strcmp(ptsz_LigneCour[PER_CTR_NF], "TR0006135" ) ==0 )) // || ((n_Traite_Decale ) &&  atoi(ptsz_LigneCour[PER_UWY_NF]) == 2019  && strcmp(ptsz_LigneCour[PER_CTR_NF], "TR0040245" ) ==0   ))  	 																     				  		
	  		//if ( (n_Traite_Decale ) && ( ato i(ptsz_LigneCour[PER_UWY_NF]) >= 2018 ) && ( strcmp(ptsz_LigneCour[PER_CTR_NF], "TR0038966" ) ==0 || strcmp(ptsz_LigneCour[PER_CTR_NF], "TR0038579" ) ==0	|| strcmp(ptsz_LigneCour[PER_CTR_NF], "TR0036334"	 ) ==0  || strcmp(ptsz_LigneCour[PER_CTR_NF], "TR0016977" ) ==0 || strcmp(ptsz_LigneCour[PER_CTR_NF], "TR0042679" ) ==0 || strcmp(ptsz_LigneCour[PER_CTR_NF], "TR0017781" ) ==0) )	    	   	 															     			
	  		
	  	  ///[027]if ( n_Traite_Decale )                 	                                               
	  		//{		          
	  		//		             
				//   NbJoursValiditesContrat = 1 + nbJours_Entre_Deux_Dates(n_vj1, n_vm1, n_va1, n_vj2, n_vm2, n_va2);  
				//  //[019]   
				//     
				//  {                                 
				//  	//if (n_va1 != Ks_ACY_NF)     
				//	 printf("\n DATA [03] ptsz_LigneCour[PER_CTR_NF] = %s, ptsz_LigneCour[PER_SEC_NF] = %s, ptsz_LigneCour[PER_UWY_NF]=%d ; ptsz_LigneCour[PER_SECINC_D] = %s ;ptsz_LigneCour[PER_EXP_D] =%s ; ptsz_LigneCour[PER_DATDERCPA_D]=%s ;Type_Periodicité = %d ; d_retamtprm =%f ; Kd_Prm=%f ; Mois_Der_Cpa_Recu=%d Ks_ACY_NF=%d\n", ptsz_LigneCour[PER_CTR_NF],  ptsz_LigneCour[PER_SEC_NF], atoi(ptsz_LigneCour[PER_UWY_NF]), ptsz_LigneCour[PER_SECINC_D], ptsz_LigneCour[PER_EXP_D],ptsz_LigneCour[PER_DATDERCPA_D], atoi(ptsz_LigneCour[PER_ACCFRQ_CT]), d_retamtprm, Kd_Prm, Ks_SCOENDMTH_NF, Ks_ACY_NF )	; 
    		//     
				//  /* [025]    
				//  Kn_NbreEchPrm = n_CalculPrmEstTraitPropDecale(Ksz_CLODAT_D,
    		//                                          (unsigned char)atoi(ptsz_LigneCour[PER_ACCFRQ_CT]), 
    		//                                          ptsz_LigneCour[PER_SECINC_D],
    		//                                          ptsz_LigneCour[PER_EXP_D],
    		//                                          (char)atoi(ptsz_LigneCour[PER_DIFMTH_NF]),
    		//                                          (unsigned char)Ks_SCOENDMTH_NF,
    		//                                          (short)Ks_ACY_NF,
    		//                                          d_retamtprm,
    		//                                          Kd_Prm,
    		//                                          Ktbd_EchPrm); */
    		//                                          
    		//                                               
    		//                                          
				//  Kn_NbreEchPrm = n_CalculPrmEstTraitPropDecale(Ksz_CLODAT_D,
    		//                                          (unsigned char)atoi(ptsz_LigneCour[PER_ACCFRQ_CT]),
    		//                                          ptsz_LigneCour[PER_SECINC_D],
    		//                                          ptsz_LigneCour[PER_EXP_D],
    		//                                          (char)atoi(ptsz_LigneCour[PER_DIFMTH_NF]),
				//																					ptsz_LigneCour[PER_DATDERCPA_D],
    		//                                          (unsigned char)Ks_SCOENDMTH_NF,
    		//                                          (short)Ks_ACY_NF,
    		//                                          d_retamtprm,
    		//                                          Kd_Prm , 
    		//                                          Ktbd_EchPrm );    		                                          
    		//                                          
    		//  }
    		//                                          	  		   
	  		//}  
	  		///[027]else  /*[014] [021] FIN*/
	  		{  
	  			/*
	  			if (strcmp(ptsz_LigneCour[PER_CTR_NF], "02T009329" ) ==0 )  
	  				printf(" NON MODIF CTRnf %s \n", ptsz_LigneCour[PER_CTR_NF]); */
    		
    		  Kn_NbreEchPrm = n_CalculPrmEstTraitProp(Ksz_CLODAT_D,
    		                                          (unsigned char)atoi(ptsz_LigneCour[PER_ACCFRQ_CT]),
    		                                          ptsz_LigneCour[PER_SECINC_D],
    		                                          ptsz_LigneCour[PER_EXP_D],
    		                                          (char)atoi(ptsz_LigneCour[PER_DIFMTH_NF]),
    		                                          (unsigned char)Ks_SCOENDMTH_NF,
    		                                          (short)Ks_ACY_NF,
    		                                          d_retamtprm,
    		                                          Kd_Prm,
    		                                          Ktbd_EchPrm);
	 			}
					
    }
    else
      Kn_NbreEchPrm = 0 ;
  }

  /* Cas non proportionnels */
  if (*ptsz_LigneCour[PER_CTRNAT_CT] == 'N')
  {
    /* Synchronisation avec le fichier des échéanciers */
    Kn_NbreEchSous = 0;
    n_ProcessingRuptureSyncVar(pbd_SyncPRMD, ptsz_LigneCour);

    /* Appel du module de calcul Lot 60 */
    s_PRMD_B = 0;
    if (Kn_NbreEchSous)
    {
      s_PRMD_B = 1;
    }

    /******************************************************************/
    /* Modifs du 14/05/98 - M.HA-THUC         */
    /* On ne calcule pas de primes estimees pour les traites si   */
    /* l'exercice est strictement inferieur a l'exercice seuil. */
    /* L'exercice seuil est defini dans la fonction       */
    /*  n_CalculExerciceSeuil( estserv.c )      */
    /******************************************************************/
    // spot 28140 Modificaiton   des parametres d'appel de la fonction n_CalculExerciceSeuil
    if ( atoi( ptsz_LigneCour[PER_UWY_NF] ) >= n_CalculExerciceSeuil( atoi(ptsz_LigneCour[PER_SSD_CF]), atoi(ptsz_LigneCour[PER_ACCESB_CF]), ptsz_LigneCour[PER_LOB_CF], atoi(ptsz_LigneCour[PER_NAT_CF]) ) )
    {
        // PLG 19/10/2009 - Fiche Spot n° 16778
        // Si type comptable 3 on applique la nouvelle methode
        // [022]
        if (atoi(ptsz_LigneCour[PER_ACCADMTYP_CT]) == 3) 
        {
            // Synchronisation avec le fichier des taux de sinistralite des traites non proportionnels 
            n_ProcessingRuptureSyncVar(pbd_SyncSinNP, ptsz_LigneCour);

        	Kn_NbreEchPrm = n_CalculPrmEstTraitNonPropSaisonnalite_02((short)atoi(ptsz_LigneCour[PER_UWY_NF]),
                        ptsz_LigneCour[PER_PCPCUR_CF],
                        Ksz_CLODAT_D,
                        ptsz_LigneCour[PER_EXP_D],
                        ptsz_LigneCour[PER_SECINC_D],
                        (char)atoi(ptsz_LigneCour[PER_DIFMTH_NF]),
                        atoi(ptsz_LigneCour[PER_SBJCPTDEF_B]),
                        d_retamtprm,
                        Kptsz_LigneEsclaveSinNP,
                        Kn_NbreEchPrm,
                        Ktbd_EchPrm,
                        ptsz_LigneCour[PER_SSD_CF],      // [009]
                        ptsz_LigneCour[PER_ACCESB_CF]);
            /* [024] REQ 9.6 */
                Kd_PNAIFRS17 = d_CalculPNAIFRS17 (d_EGPI, ptsz_LigneCour[PER_SCOINC_D], Ksz_CLODAT_D, ptsz_LigneCour[PER_EXP_D], 0);//Ktbd_PrmEst[Kn_CompteurPrmEst].Prm);
        }
        /* Sinon on utilise l'ancienne methode */
        else
        {
    	  
        	/* [013] [Si l'etat du contrat est "PER_SBJCPTDEF_B = TRUE" on n 'effectue plus les estimations pour les traites NP*/
        	if (atoi(ptsz_LigneCour[PER_SBJCPTDEF_B]) == 0)      
        	{
                Kn_NbreEchPrm = n_CalculPrmEstTraitNonProp((short)atoi(ptsz_LigneCour[PER_UWY_NF]),
                                Ksz_CLODAT_D,
                                ptsz_LigneCour[PER_EXP_D],
                                ptsz_LigneCour[PER_SECINC_D],
                                (char)atoi(ptsz_LigneCour[PER_DIFMTH_NF]),
                                d_retamtprm,
                                s_PRMD_B,
                                Kn_NbreEchSous,
                                Ktbd_EchSous,
                                Kn_NbreEchPrm,
                                Ktbd_EchPrm); 
            }
            else  /* [015] On n'effectue plus d'estimations des NP */
            {
                Kn_NbreEchPrm = n_CalculPrmEstTraitNonProp_02((short)atoi(ptsz_LigneCour[PER_UWY_NF]),
                                Ksz_CLODAT_D,
                                ptsz_LigneCour[PER_EXP_D],
                                ptsz_LigneCour[PER_SECINC_D],
                                (char)atoi(ptsz_LigneCour[PER_DIFMTH_NF]),
                                d_retamtprm,
                                s_PRMD_B,
                                atoi(ptsz_LigneCour[PER_SBJCPTDEF_B]),                        
                                Kn_NbreEchSous,
                                Ktbd_EchSous,
                                Kn_NbreEchPrm,
                                Ktbd_EchPrm);
            }
        } /* FIN [013] */
      /* Fin PLG 19/10/2009 */
    }
    else
      Kn_NbreEchPrm = 0 ;
  }

  /* Cas facultatives */
  if (*ptsz_LigneCour[PER_CTRNAT_CT] == 'F')
  {
    /* Synchronisation avec le GT facs */
    n_ProcessingRuptureSyncVar(pbd_SyncGTFAC, ptsz_LigneCour);

    /********************************************************/
    /* Modifs du 01/04/1998 - M.HA-THUC               */
    /* Rajout d'une synchro avec le GT des PNA estimees   */
    /********************************************************/
    n_ProcessingRuptureSyncVar(pbd_SyncGTFACPNAE, ptsz_LigneCour);
  }

  /* Cas traités */
  if (*ptsz_LigneCour[PER_CTRNAT_CT] != 'F')
  {
    if (Kn_NbrePrmEst == NBPrmEst_MAX)
    {
      sprintf(Ksz_MessageErr, "CTR %s, END %s, SEC %s, UWY %s, UW %s : maximum number of lines is reached ; increase NBPrmEst_MAX value",
              ptsz_LigneCour[PER_CTR_NF],
              ptsz_LigneCour[PER_END_NT],
              ptsz_LigneCour[PER_SEC_NF],
              ptsz_LigneCour[PER_UWY_NF],
              ptsz_LigneCour[PER_UW_NT]);

      /* Modif (28/01/98) : ecriture dans le .ano au lieu du .log */
      n_WriteAno(Ksz_MessageErr);
      Kb_ReturnStatus = 1;
    }
    else
    {
      /* Optimisation en ecrivant le resultat de l'appel a la fonction dans le tableau Ktbd_PrmEst */
      for (Kn_CompteurEchPrm = 0; Kn_CompteurEchPrm < Kn_NbreEchPrm; Kn_CompteurEchPrm++)
      {
        s_LigneExistante = 0;
        for (Kn_CompteurPrmEst = 0; Kn_CompteurPrmEst < Kn_NbrePrmEst; Kn_CompteurPrmEst++)
        {
          if ((Ktbd_EchPrm[Kn_CompteurEchPrm].ACY_NF == Ktbd_PrmEst[Kn_CompteurPrmEst].ACY_NF)
              && (Ktbd_EchPrm[Kn_CompteurEchPrm].SCOSTRMTH_NF == Ktbd_PrmEst[Kn_CompteurPrmEst].SCOSTRMTH_NF)
              && (Ktbd_EchPrm[Kn_CompteurEchPrm].SCOENDMTH_NF == Ktbd_PrmEst[Kn_CompteurPrmEst].SCOENDMTH_NF) )
          {
            /* Cas où la ligne existe deja */
            if (Ktbd_PrmEst[Kn_CompteurPrmEst].Prm == 0)
            {
              s_LigneExistante = 1;
              Ktbd_PrmEst[Kn_CompteurPrmEst].Prm = Ktbd_EchPrm[Kn_CompteurEchPrm].AMT_M;
              Ktbd_PrmEst[Kn_CompteurPrmEst].Type = 'E';
            }
          }
        }

        /* Cas ou la ligne n'existe pas : creation d'une nouvelle ligne */
        if (s_LigneExistante == 0)
        {
          /* Si depassement de la taille du tableau */
          if (Kn_NbrePrmEst == NBPrmEst_MAX)
          {
            sprintf (Ksz_MessageErr, "CTR %s, END %s, SEC %s, UWY %s, UW %s : maximum number of lines is reached ; increase NBPrmEst_MAX value",
                     ptsz_LigneCour[PER_CTR_NF],
                     ptsz_LigneCour[PER_END_NT],
                     ptsz_LigneCour[PER_SEC_NF],
                     ptsz_LigneCour[PER_UWY_NF],
                     ptsz_LigneCour[PER_UW_NT]);
            /* Modif (28/01/98) : ecriture dans le .ano au lieu du .log */
            n_WriteAno(Ksz_MessageErr);
            Kb_ReturnStatus = 1;
          }
          else
          {
            Ktbd_PrmEst[Kn_CompteurPrmEst].ACY_NF = Ktbd_EchPrm[Kn_CompteurEchPrm].ACY_NF;
            Ktbd_PrmEst[Kn_CompteurPrmEst].SCOSTRMTH_NF = Ktbd_EchPrm[Kn_CompteurEchPrm].SCOSTRMTH_NF;
            Ktbd_PrmEst[Kn_CompteurPrmEst].SCOENDMTH_NF = Ktbd_EchPrm[Kn_CompteurEchPrm].SCOENDMTH_NF;
            Ktbd_PrmEst[Kn_CompteurPrmEst].Prm = Ktbd_EchPrm[Kn_CompteurEchPrm].AMT_M;
            Ktbd_PrmEst[Kn_CompteurPrmEst].Type = 'E';
            Kn_NbrePrmEst++;
          }
        }
      }


      /* Ecriture dans le GT du tableau KtbdEchPrm */
      for (Kn_CompteurEchPrm = 0; Kn_CompteurEchPrm < Kn_NbreEchPrm; Kn_CompteurEchPrm++)
      {
        n_GestionDecalage(atoi(ptsz_LigneCour[PER_UWY_NF]),
                          &Ktbd_EchPrm[Kn_CompteurEchPrm].ACY_NF,
                          &Ktbd_EchPrm[Kn_CompteurEchPrm].SCOSTRMTH_NF,
                          &Ktbd_EchPrm[Kn_CompteurEchPrm].SCOENDMTH_NF);

        /* ajout une colonne pour retintamt_m */
        if ( fabs( Ktbd_EchPrm[Kn_CompteurEchPrm].AMT_M ) >= SEUIL_MONTANT )        //[007] seuil en dur devient SEUIL_MONTANT
        {
          //[004]
          if (*ptsz_LigneCour[PER_CTRNAT_CT] == 'N')
          {
            if (Ktbd_EchPrm[Kn_CompteurEchPrm].AMT_M >= 0)
              n_PosteComptable = POSTE_CPTABLE_ESTIMATION_NON_PROP;
            else
              n_PosteComptable = POSTE_CPTABLE_PNA_NON_PROP;
          }
          else
            n_PosteComptable = POSTE_CPTABLE_ESTIMATION_PROP;

          //[006]
          if ( n_PosteComptable == POSTE_CPTABLE_PNA_NON_PROP )
          {
            p_OutputFileGT = Kp_OutputFile5;
          }
          else
          {
            p_OutputFileGT = Kp_OutputFile1;
          }
          // REQ 9.2 [020]
          //if ( n_PosteComptable != POSTE_CPTABLE_PNA_NON_PROP )
          //{
          	//                        0  1  2  3  4  5...7  8  9 10 11 12 13 14 15..17     18 19 20 21 22..................
          	fprintf(p_OutputFileGT, "%s~%s~%s~%s~%s~%d~~%s~%s~%s~%s~%s~%s~%d~%d~%d~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~GTA~~~~~~~~~~~~~~\n",
                  ptsz_LigneCour[PER_SSD_CF],                         //  0
                  ptsz_LigneCour[PER_ACCESB_CF],                      //  1
                  Ksz_Annee,                                          //  2
                  Ksz_Mois,                                           //  3
                  Ksz_Jour,                                           //  4
                  n_PosteComptable,                                   //  5
                  ptsz_LigneCour[PER_CTR_NF],                         //  7
                  ptsz_LigneCour[PER_END_NT],                         //  8
                  ptsz_LigneCour[PER_SEC_NF],                         //  9
                  ptsz_LigneCour[PER_UWY_NF],                         // 10
                  ptsz_LigneCour[PER_UW_NT],                          // 11
                  ptsz_LigneCour[PER_UWY_NF],                         // 12
                  Ktbd_EchPrm[Kn_CompteurEchPrm].ACY_NF,              // 13
                  Ktbd_EchPrm[Kn_CompteurEchPrm].SCOSTRMTH_NF,        // 14
                  Ktbd_EchPrm[Kn_CompteurEchPrm].SCOENDMTH_NF,        // 15
                  ptsz_LigneCour[PER_EGPCUR_CF],                      // 17
                  Ktbd_EchPrm[Kn_CompteurEchPrm].AMT_M,               // 18
                  ptsz_LigneCour[PER_CED_NF],                         // 19
                  ptsz_LigneCour[PER_PRD_NF],                         // 20
                  ptsz_LigneCour[PER_GENPRMPAY_NF],                   // 21
                  ptsz_LigneCour[PER_GANPAYORD_NT]);                  // 22
          //}
        }
      }

      /* Ecriture dans le fichier de travail du tableau KtbdPrmEst */
      for (Kn_CompteurPrmEst = 0; Kn_CompteurPrmEst < Kn_NbrePrmEst; Kn_CompteurPrmEst++)
      {
        s_acy = Ktbd_PrmEst[Kn_CompteurPrmEst].ACY_NF;
        c_scostrmth = Ktbd_PrmEst[Kn_CompteurPrmEst].SCOSTRMTH_NF;
        c_scoendmth = Ktbd_PrmEst[Kn_CompteurPrmEst].SCOENDMTH_NF;

        n_GestionDecalage(atoi(ptsz_LigneCour[PER_UWY_NF]), &s_acy, &c_scostrmth, &c_scoendmth);

        Ktbd_PrmEst[Kn_CompteurPrmEst].ACY_NF       = s_acy;
        Ktbd_PrmEst[Kn_CompteurPrmEst].SCOSTRMTH_NF = c_scostrmth;
        Ktbd_PrmEst[Kn_CompteurPrmEst].SCOENDMTH_NF = c_scoendmth;

        //[006]
        
/*         if ((strcmp(ptsz_LigneCour[PER_CTR_NF], "TR0039719") == 0) || (strcmp(ptsz_LigneCour[PER_CTR_NF], "02T035614") == 0))
          	printf("AVANT 01 Ktbd_PrmEst[Kn_CompteurPrmEst].Prm = %-.3lf ; Ktbd_PrmEst[Kn_CompteurPrmEst].PPNA =%-.3lf ; Kn_CompteurPrmEst = %d; NBMAXKn_NbrePrmEst= %d; ANNEE_Ktbd_PrmEst[Kn_CompteurPrmEst].ACY_NF=%d\n", Ktbd_PrmEst[Kn_CompteurPrmEst].Prm, Ktbd_PrmEst[Kn_CompteurPrmEst].PPNA, Kn_CompteurPrmEst, Kn_NbrePrmEst, (Ktbd_PrmEst[Kn_CompteurPrmEst].ACY_NF));
*/
        
        if ((Ktbd_PrmEst[Kn_CompteurPrmEst].Prm < 0 && *ptsz_LigneCour[PER_CTRNAT_CT] != 'P' && Ktbd_PrmEst[Kn_CompteurPrmEst].Type != 'C'))
          Ktbd_PrmEst[Kn_CompteurPrmEst].PPNA += Ktbd_PrmEst[Kn_CompteurPrmEst].Prm;
        {  
/*
         if ((strcmp(ptsz_LigneCour[PER_CTR_NF], "TR0039719") == 0) || (strcmp(ptsz_LigneCour[PER_CTR_NF], "02T035614") == 0))
             	printf("APRES 01 Ktbd_PrmEst[Kn_CompteurPrmEst].Prm = %-.3lf ; Ktbd_PrmEst[Kn_CompteurPrmEst].PPNA =%-.3lf ; Kn_CompteurPrmEst = %d; NBMAXKn_NbrePrmEst= %d; ANNEE_Ktbd_PrmEst[Kn_CompteurPrmEst].ACY_NF=%d\n", Ktbd_PrmEst[Kn_CompteurPrmEst].Prm, Ktbd_PrmEst[Kn_CompteurPrmEst].PPNA, Kn_CompteurPrmEst, Kn_NbrePrmEst, (Ktbd_PrmEst[Kn_CompteurPrmEst].ACY_NF));
             	 */
        //                        0  1  2  3  4  5  6  7  8  9 10 11 12 13     14     15      17     19      20      22      24      26 27
        fprintf(Kp_OutputFile2, "%s~%s~%s~%s~%s~%s~%d~%d~%d~%s~%s~%d~%c~%s~%-.3lf~%-.3lf~~%-.3lf~~%-.3lf~%-.3lf~~%-.3lf~~%-.3lf~~%-.8lf~%s\n",
                Ksz_CLODAT_D,
                ptsz_LigneCour[PER_CTR_NF],
                ptsz_LigneCour[PER_END_NT],
                ptsz_LigneCour[PER_SEC_NF],
                ptsz_LigneCour[PER_UWY_NF],
                ptsz_LigneCour[PER_UW_NT],
                Ktbd_PrmEst[Kn_CompteurPrmEst].ACY_NF,
                Ktbd_PrmEst[Kn_CompteurPrmEst].SCOSTRMTH_NF,
                Ktbd_PrmEst[Kn_CompteurPrmEst].SCOENDMTH_NF,
                ptsz_LigneCour[PER_UWY_NF],
                ptsz_LigneCour[PER_SSD_CF], /* Ajout de la filiale */
                10000,
                Ktbd_PrmEst[Kn_CompteurPrmEst].Type,
                ptsz_LigneCour[PER_EGPCUR_CF],
                (Ktbd_PrmEst[Kn_CompteurPrmEst].Prm >= SEUIL_MONTANT || *ptsz_LigneCour[PER_CTRNAT_CT] == 'P' || Ktbd_PrmEst[Kn_CompteurPrmEst].Type == 'C' ) ? Ktbd_PrmEst[Kn_CompteurPrmEst].Prm : 0,     // PLG 19/10/2009 - Fiche Spot n° 16778 :       Ktbd_PrmEst[Kn_CompteurPrmEst].Prm,     //[007] seuil en dur devient SEUIL_MONTANT
                //[005]domdom Ktbd_PrmEst[Kn_CompteurPrmEst].Prm,
                Ktbd_PrmEst[Kn_CompteurPrmEst].PPNA,
                //(Ktbd_PrmEst[Kn_CompteurPrmEst].Prm < 0 && *ptsz_LigneCour[PER_CTRNAT_CT] == 'N' && atoi(ptsz_LigneCour[PER_ACCADMTYP_CT]) == 3 ) ? Ktbd_PrmEst[Kn_CompteurPrmEst].Prm : 0,      // PLG 19/10/2009 - Fiche Spot n° 16778
                Ktbd_PrmEst[Kn_CompteurPrmEst].RPP,
                Ktbd_PrmEst[Kn_CompteurPrmEst].PPNALib,
                Ktbd_PrmEst[Kn_CompteurPrmEst].EPP,
                Ktbd_PrmEst[Kn_CompteurPrmEst].Rec,
                Ktbd_PrmEst[Kn_CompteurPrmEst].BC,
                d_Part,
                ptsz_LigneCour[PER_ACCADMTYP_CT]);
                
                //REQ 9.6 [024]
                // [029]
				if (    ((strcmp(ptsz_LigneCour[PER_SECQUA4_CF], "20") == 0 || strcmp(ptsz_LigneCour[PER_SECQUA4_CF], "21") == 0 || strcmp(ptsz_LigneCour[PER_SECQUA4_CF], "22") == 0)) && flg_w == 1)
                                {
                                        fprintf(Kp_OutputFile2, "%s~%s~%s~%s~%s~%s~%d~%d~%d~%s~%s~%d~%c~%s~%-.3lf~%-.3lf~~%-.3lf~~%-.3lf~%-.3lf~~%-.3lf~~%-.3lf~~%-.8lf~%s\n",
                                        Ksz_CLODAT_D,
                                        ptsz_LigneCour[PER_CTR_NF],
                                        ptsz_LigneCour[PER_END_NT],
                                        ptsz_LigneCour[PER_SEC_NF],
                                        ptsz_LigneCour[PER_UWY_NF],
                                        ptsz_LigneCour[PER_UW_NT],
                                        Ktbd_PrmEst[Kn_CompteurPrmEst].ACY_NF,
                                        Ktbd_PrmEst[Kn_CompteurPrmEst].SCOSTRMTH_NF,
                                        Ktbd_PrmEst[Kn_CompteurPrmEst].SCOENDMTH_NF,
                                        ptsz_LigneCour[PER_UWY_NF],
                                        ptsz_LigneCour[PER_SSD_CF], /* Ajout de la filiale */
                                        99999,
                                        Ktbd_PrmEst[Kn_CompteurPrmEst].Type,
                                        ptsz_LigneCour[PER_EGPCUR_CF],
                                        (Ktbd_PrmEst[Kn_CompteurPrmEst].Prm >= SEUIL_MONTANT || *ptsz_LigneCour[PER_CTRNAT_CT] == 'P' || Ktbd_PrmEst[Kn_CompteurPrmEst].Type == 'C' ) ? Ktbd_PrmEst[Kn_CompteurPrmEst].Prm : 0,
                                        0.00000000,
                                        Ktbd_PrmEst[Kn_CompteurPrmEst].RPP,
                                        Ktbd_PrmEst[Kn_CompteurPrmEst].PPNALib,
                                        Ktbd_PrmEst[Kn_CompteurPrmEst].EPP,
                                        Ktbd_PrmEst[Kn_CompteurPrmEst].Rec,
                                        Ktbd_PrmEst[Kn_CompteurPrmEst].BC,
                                        d_Part,
                                        ptsz_LigneCour[PER_ACCADMTYP_CT]);
                                }

				if (	(strcmp(ptsz_LigneCour[PER_SECQUA4_CF], "20") == 0 || strcmp(ptsz_LigneCour[PER_SECQUA4_CF], "21") == 0 || strcmp(ptsz_LigneCour[PER_SECQUA4_CF], "22") == 0)
					 && flg_w == 0)
				{
					flg_w = 1;

					fprintf(Kp_OutputFile2, "%s~%s~%s~%s~%s~%s~%d~%d~%d~%s~%s~%d~%c~%s~%-.3lf~%-.3lf~~%-.3lf~~%-.3lf~%-.3lf~~%-.3lf~~%-.3lf~~%-.8lf~%s\n",
					Ksz_CLODAT_D,
					ptsz_LigneCour[PER_CTR_NF],
					ptsz_LigneCour[PER_END_NT],
					ptsz_LigneCour[PER_SEC_NF],
					ptsz_LigneCour[PER_UWY_NF],
					ptsz_LigneCour[PER_UW_NT],
					Ktbd_PrmEst[Kn_CompteurPrmEst].ACY_NF,
					Ktbd_PrmEst[Kn_CompteurPrmEst].SCOSTRMTH_NF,
					Ktbd_PrmEst[Kn_CompteurPrmEst].SCOENDMTH_NF,
					ptsz_LigneCour[PER_UWY_NF],
					ptsz_LigneCour[PER_SSD_CF], /* Ajout de la filiale */
					99999,
					Ktbd_PrmEst[Kn_CompteurPrmEst].Type,
					ptsz_LigneCour[PER_EGPCUR_CF],
					(Ktbd_PrmEst[Kn_CompteurPrmEst].Prm >= SEUIL_MONTANT || *ptsz_LigneCour[PER_CTRNAT_CT] == 'P' || Ktbd_PrmEst[Kn_CompteurPrmEst].Type == 'C' ) ? Ktbd_PrmEst[Kn_CompteurPrmEst].Prm : 0,
					Kd_PNAIFRS17,
					Ktbd_PrmEst[Kn_CompteurPrmEst].RPP,
					Ktbd_PrmEst[Kn_CompteurPrmEst].PPNALib,
					Ktbd_PrmEst[Kn_CompteurPrmEst].EPP,
					Ktbd_PrmEst[Kn_CompteurPrmEst].Rec,
					Ktbd_PrmEst[Kn_CompteurPrmEst].BC,
					d_Part,
					ptsz_LigneCour[PER_ACCADMTYP_CT]);
				}
       }
      }
    }
  }
  /* Cas facs */
  else
  {
    /* Ecriture dans le fichier de travail des facs du tableau KtbdPrmEst */
    for (Kn_CompteurPrmEst = 0; Kn_CompteurPrmEst < Kn_NbrePrmEst; Kn_CompteurPrmEst++)
    {
      /*******************************************************/
      /* Modifs du 01/04/98 - M.HA-THUC       */
      /* Ecriture dans le fichier de travail en sortie  */
      /* des PNA estimees         */
      /*******************************************************/
      if ( Ktbd_PrmEst[Kn_CompteurPrmEst].Type == 'P' )
      {
        fprintf(Kp_OutputFile3, "%s~%s~%s~%s~%s~%s~%d~%d~%d~%s~%s~%d~%c~%s~~~%-.3lf~~~~~~~~~~%-.8lf~%s\n",
                Ksz_CLODAT_D,
                ptsz_LigneCour[PER_CTR_NF],
                ptsz_LigneCour[PER_END_NT],
                ptsz_LigneCour[PER_SEC_NF],
                ptsz_LigneCour[PER_UWY_NF],
                ptsz_LigneCour[PER_UW_NT],
                Ktbd_PrmEst[Kn_CompteurPrmEst].ACY_NF,
                Ktbd_PrmEst[Kn_CompteurPrmEst].SCOSTRMTH_NF,
                Ktbd_PrmEst[Kn_CompteurPrmEst].SCOENDMTH_NF,
                ptsz_LigneCour[PER_UWY_NF],
                ptsz_LigneCour[PER_SSD_CF], /* Ajout de la filiale */
                10000,
                'E',
                ptsz_LigneCour[PER_EGPCUR_CF],
                Ktbd_PrmEst[Kn_CompteurPrmEst].PPNA,
                d_Part,
                ptsz_LigneCour[PER_ACCADMTYP_CT]);
      }
      else
        fprintf(Kp_OutputFile3, "%s~%s~%s~%s~%s~%s~%d~%d~%d~%s~%s~%d~%c~%s~%-.3lf~%-.3lf~~%-.3lf~~%-.3lf~%-.3lf~~%-.3lf~%-.3lf~~~%-.8lf~%s\n",
                Ksz_CLODAT_D,
                ptsz_LigneCour[PER_CTR_NF],
                ptsz_LigneCour[PER_END_NT],
                ptsz_LigneCour[PER_SEC_NF],
                ptsz_LigneCour[PER_UWY_NF],
                ptsz_LigneCour[PER_UW_NT],
                Ktbd_PrmEst[Kn_CompteurPrmEst].ACY_NF,
                Ktbd_PrmEst[Kn_CompteurPrmEst].SCOSTRMTH_NF,
                Ktbd_PrmEst[Kn_CompteurPrmEst].SCOENDMTH_NF,
                ptsz_LigneCour[PER_UWY_NF],
                ptsz_LigneCour[PER_SSD_CF], /* Ajout de la filiale */
                10000,
                Ktbd_PrmEst[Kn_CompteurPrmEst].Type,
                ptsz_LigneCour[PER_EGPCUR_CF],
                Ktbd_PrmEst[Kn_CompteurPrmEst].Prm,
                Ktbd_PrmEst[Kn_CompteurPrmEst].PPNA,
                Ktbd_PrmEst[Kn_CompteurPrmEst].RPP,
                Ktbd_PrmEst[Kn_CompteurPrmEst].PPNALib,
                Ktbd_PrmEst[Kn_CompteurPrmEst].EPP,
                Ktbd_PrmEst[Kn_CompteurPrmEst].Rec,
                Ktbd_PrmEst[Kn_CompteurPrmEst].BC,
                d_Part,
                ptsz_LigneCour[PER_ACCADMTYP_CT]);
    }
  }

  RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : synchronisation de IADPERICASE avec le GT              ***/
/*** Nom   : n_ConditionSyncGT                                ***/
/*** Parametres:                                                        ***/
/***        i ptsz_LigneMaitre  : pointeur sur la ligne du maitre       ***/
/***        i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave    ***/
/*** Retour:                                                            ***/
/***        0 si synchronise,                                           ***/
/***       <0 si la ligne esclave est depassee,                         ***/
/***       >0 si la ligne esclave n'est pas depassee.                   ***/
/**************************************************************************/
int n_ConditionSyncGT( char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[] )
{
  static short s_ret;

  DEBUT_FCT("n_ConditionSyncGT");

  if ((s_ret = strcmp(ptsz_LigneMaitre[PER_CTR_NF], ptsz_LigneEsclave[GTE_CTR_NF])))
    return s_ret;
  if ((s_ret = strcmp(ptsz_LigneMaitre[PER_END_NT], ptsz_LigneEsclave[GTE_END_NT])))
    return s_ret;
  if ((s_ret = strcmp(ptsz_LigneMaitre[PER_SEC_NF], ptsz_LigneEsclave[GTE_SEC_NF])))
    return s_ret;
  if ((s_ret = strcmp(ptsz_LigneMaitre[PER_UWY_NF], ptsz_LigneEsclave[GTE_UWY_NF])))
    return s_ret;

  RETURN_VAL(strcmp(ptsz_LigneMaitre[PER_UW_NT], ptsz_LigneEsclave[GTE_UW_NT]));
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du GT                    ***/
/*** Nom   : n_ActionLigneSyncGT                                        ***/
/*** Parametres:                                                        ***/
/***        i ptsz_LigneMaitre  : pointeur sur la ligne du maitre,      ***/
/***        i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave.   ***/
/*** Retour:                                                            ***/
/***        OK si pas d'erreur,                                         ***/
/***        ERR si erreur.                                              ***/
/**************************************************************************/
int n_ActionLigneSyncGT( char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[])
{
  static short s_LigneExistante;
  static int s_ACMTRS;

  DEBUT_FCT("n_ActionLigneSyncGT");

  s_ACMTRS = atoi(ptsz_LigneEsclave[GTE_ACMTRS_NT]);

  /* Cumul des montants de primes estimes et sauvegarde des derniers annee de compte, periode de compte */
  if (s_ACMTRS == 10000)
  {
    // Cas proportionnel : on cumule les montants et on sauve l'annee et la
    //  periode de compte dans des variables pour avoir les plus recents a la fin
    if (*ptsz_LigneMaitre[PER_CTRNAT_CT] == 'P')
    {
      Kd_Prm = Kd_Prm + atof(ptsz_LigneEsclave[GTE_ACMAMT_M]);
      Ks_ACY_NF = (short)atoi(ptsz_LigneEsclave[GTE_ACY_NF]);
      Ks_SCOENDMTH_NF = (short)atoi(ptsz_LigneEsclave[GTE_SCOENDMTH_NF]);
    }
    else    // Cas non proportionnel : on ecrit dans le tableau Ktbd_EchPrm
      if (*ptsz_LigneMaitre[PER_CTRNAT_CT] == 'N')
      {
        Ktbd_EchPrm[Kn_NbreEchPrm].ACY_NF       = (short)atoi(ptsz_LigneEsclave[GTE_ACY_NF]);
        Ktbd_EchPrm[Kn_NbreEchPrm].AMT_M        = atof(ptsz_LigneEsclave[GTE_ACMAMT_M]);
        Ktbd_EchPrm[Kn_NbreEchPrm].SCOSTRMTH_NF = (short)atoi(ptsz_LigneEsclave[GTE_SCOSTRMTH_NF]);
        Ktbd_EchPrm[Kn_NbreEchPrm].SCOENDMTH_NF = (short)atoi(ptsz_LigneEsclave[GTE_SCOENDMTH_NF]);
        Kn_NbreEchPrm++;
      }
  }

  s_LigneExistante = 0;

  for (Kn_CompteurPrmEst = 0; Kn_CompteurPrmEst < Kn_NbrePrmEst; Kn_CompteurPrmEst++)
  {
    if ( ((short)atoi(ptsz_LigneEsclave[GTE_ACY_NF]) == Ktbd_PrmEst[Kn_CompteurPrmEst].ACY_NF)              &&
         ((short)atoi(ptsz_LigneEsclave[GTE_SCOSTRMTH_NF]) == Ktbd_PrmEst[Kn_CompteurPrmEst].SCOSTRMTH_NF)  &&
         ((short)atoi(ptsz_LigneEsclave[GTE_SCOENDMTH_NF]) == Ktbd_PrmEst[Kn_CompteurPrmEst].SCOENDMTH_NF) )
    {
      /* Cas ou la ligne existe deja */
      s_LigneExistante = 1;

      switch (s_ACMTRS)
      {
      case 10000:
        Ktbd_PrmEst[Kn_CompteurPrmEst].Prm += atof(ptsz_LigneEsclave[GTE_ACMAMT_M]);
        break;
      case 10030:
        Ktbd_PrmEst[Kn_CompteurPrmEst].PPNA += atof(ptsz_LigneEsclave[GTE_ACMAMT_M]);
        break;
      case 10010:
        Ktbd_PrmEst[Kn_CompteurPrmEst].RPP += atof(ptsz_LigneEsclave[GTE_ACMAMT_M]);
        break;
      case 10040:
        Ktbd_PrmEst[Kn_CompteurPrmEst].PPNALib += atof(ptsz_LigneEsclave[GTE_ACMAMT_M]);
        break;
      case 10020:
        Ktbd_PrmEst[Kn_CompteurPrmEst].EPP += atof(ptsz_LigneEsclave[GTE_ACMAMT_M]);
        break;
      case 12000:
        Ktbd_PrmEst[Kn_CompteurPrmEst].Rec += atof(ptsz_LigneEsclave[GTE_ACMAMT_M]);
        break;
      case 13000:
        Ktbd_PrmEst[Kn_CompteurPrmEst].BC += atof(ptsz_LigneEsclave[GTE_ACMAMT_M]);
        break;
      }
    }
  }

  /* Cas ou la ligne n'existe pas : creation d'une nouvelle ligne */
  if ( (s_LigneExistante == 0) && ( (s_ACMTRS == 10000) || (s_ACMTRS == 10010) || (s_ACMTRS == 10020) || (s_ACMTRS == 10030) || (s_ACMTRS == 10040) || (s_ACMTRS == 12000) || (s_ACMTRS == 13000) ) )
  {
    /* Si depassement de la taille du tableau */
    if (Kn_NbrePrmEst == NBPrmEst_MAX)
    {
      sprintf (Ksz_MessageErr, "CTR %s, END %s, SEC %s, UWY %s, UW %s : maximum number of lines is reached ; increase NBPrmEst_MAX value",
               ptsz_LigneMaitre[PER_CTR_NF],
               ptsz_LigneMaitre[PER_END_NT],
               ptsz_LigneMaitre[PER_SEC_NF],
               ptsz_LigneMaitre[PER_UWY_NF],
               ptsz_LigneMaitre[PER_UW_NT] );
      /* Modif (28/01/98) : ecriture dans le .ano au lieu du .log */
      n_WriteAno(Ksz_MessageErr);
      Kb_ReturnStatus = 1;
    }
    else
    {
      Ktbd_PrmEst[Kn_NbrePrmEst].ACY_NF = (short)atoi(ptsz_LigneEsclave[GTE_ACY_NF]);
      Ktbd_PrmEst[Kn_NbrePrmEst].SCOSTRMTH_NF = (short)atoi(ptsz_LigneEsclave[GTE_SCOSTRMTH_NF]);
      Ktbd_PrmEst[Kn_NbrePrmEst].SCOENDMTH_NF = (short)atoi(ptsz_LigneEsclave[GTE_SCOENDMTH_NF]);
      Ktbd_PrmEst[Kn_NbrePrmEst].Type = 'C';
      switch (s_ACMTRS)
      {
      case 10000:
        Ktbd_PrmEst[Kn_NbrePrmEst].Prm = atof(ptsz_LigneEsclave[GTE_ACMAMT_M]);
        break;
      case 10030:
        Ktbd_PrmEst[Kn_NbrePrmEst].PPNA = atof(ptsz_LigneEsclave[GTE_ACMAMT_M]);
        break;
      case 10010:
        Ktbd_PrmEst[Kn_NbrePrmEst].RPP = atof(ptsz_LigneEsclave[GTE_ACMAMT_M]);
        break;
      case 10040:
        Ktbd_PrmEst[Kn_NbrePrmEst].PPNALib = atof(ptsz_LigneEsclave[GTE_ACMAMT_M]);
        break;
      case 10020:
        Ktbd_PrmEst[Kn_NbrePrmEst].EPP = atof(ptsz_LigneEsclave[GTE_ACMAMT_M]);
        break;
      case 12000:
        Ktbd_PrmEst[Kn_NbrePrmEst].Rec = atof(ptsz_LigneEsclave[GTE_ACMAMT_M]);
        break;
      case 13000:
        Ktbd_PrmEst[Kn_NbrePrmEst].BC = atof(ptsz_LigneEsclave[GTE_ACMAMT_M]);
        break;
      }
      Kn_NbrePrmEst++;
    }
  }
  RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : synchronisation IADPERICASE et IADPERIPRMD                 ***/
/*** Nom : n_ConditionSyncPRMD                                          ***/
/*** Parametres:                                                        ***/
/***        i ptsz_LigneMaitre  : pointeur sur la ligne du maitre       ***/
/***        i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave    ***/
/*** Retour:                                                            ***/
/***    0 si synchronise,                                               ***/
/***   <0 si la ligne esclave est depassee,                             ***/
/***   >0 si la ligne esclave n'est pas depassee.                       ***/
/**************************************************************************/
int n_ConditionSyncPRMD( char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[] )
{
  static short s_ret;

  DEBUT_FCT("n_ConditionSyncPRMD");

  if ((s_ret = strcmp(ptsz_LigneMaitre[PER_CTR_NF], ptsz_LigneEsclave[PERPRMD_CTR_NF])))
    return s_ret;
  if ((s_ret = strcmp(ptsz_LigneMaitre[PER_END_NT], ptsz_LigneEsclave[PERPRMD_END_NT])))
    return s_ret;
  if ((s_ret = strcmp(ptsz_LigneMaitre[PER_SEC_NF], ptsz_LigneEsclave[PERPRMD_SEC_NF])))
    return s_ret;
  if ((s_ret = strcmp(ptsz_LigneMaitre[PER_UWY_NF], ptsz_LigneEsclave[PERPRMD_UWY_NF])))
    return s_ret;

  RETURN_VAL(strcmp(ptsz_LigneMaitre[PER_UW_NT], ptsz_LigneEsclave[PERPRMD_UW_NT]));
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne de IADPERIPRMD           ***/
/*** Nom : n_ActionLigneSyncPRMD                                        ***/
/*** Parametres:                                                        ***/
/***  i ptsz_LigneMaitre  : pointeur sur la ligne du maitre,          ***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave.       ***/
/*** Retour:                                                            ***/
/***  OK si pas d'erreur,                                             ***/
/***  ERR si erreur.                                                  ***/
/**************************************************************************/
int n_ActionLigneSyncPRMD( char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[] )
{
  DEBUT_FCT("n_ActionLigneSyncPRMD");

  /* Si depassement de la taille du tableau */
  if (Kn_NbreEchSous == NBEchSous_MAX)
  {
    sprintf (Ksz_MessageErr, "CTR %s, END %s, SEC %s, UWY %s, UW %s : maximum number of lines is reached ; increase NBEchSous_MAX value",
             ptsz_LigneMaitre[PER_CTR_NF],
             ptsz_LigneMaitre[PER_END_NT],
             ptsz_LigneMaitre[PER_SEC_NF],
             ptsz_LigneMaitre[PER_UWY_NF],
             ptsz_LigneMaitre[PER_UW_NT] );
    /* Modif (28/01/98) : ecriture dans le .ano au lieu du .log */
    n_WriteAno(Ksz_MessageErr);
    Kb_ReturnStatus = 1;
  }
  else
  {
    Ktbd_EchSous[Kn_NbreEchSous].PRMLIN_NT = (short)atoi(ptsz_LigneEsclave[PERPRMD_PRMLIN_NT]);
    strcpy(Ktbd_EchSous[Kn_NbreEchSous].PRMDUE_D, ptsz_LigneEsclave[PERPRMD_PRMDUE_D]);
    Ktbd_EchSous[Kn_NbreEchSous].PRMDUE_M = atof(ptsz_LigneEsclave[PERPRMD_PRMDUE_M]);
    Kn_NbreEchSous++;
  }

  RETURN_VAL(OK);
}

/**************************************************************************/
/*** Objet : synchronisation IADPERICASE et FCTRULT                 ***/
/*** Nom : n_ConditionSyncCTRULT                                        ***/
/*** Parametres:                                                        ***/
/***    i ptsz_LigneMaitre  : pointeur sur la ligne du maitre           ***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave        ***/
/*** Retour:                                                            ***/
/***    0 si synchronise,                                               ***/
/***   <0 si la ligne esclave est depassee,                             ***/
/***   >0 si la ligne esclave n'est pas depassee.                       ***/
/**************************************************************************/
int n_ConditionSyncCTRULT( char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[] )
{
  static short s_ret;

  DEBUT_FCT("n_ConditionSyncCTRULT");

  if ((s_ret = strcmp(ptsz_LigneMaitre[PER_CTR_NF], ptsz_LigneEsclave[ULT_CTR_NF])))
    return s_ret;
  if ((s_ret = strcmp(ptsz_LigneMaitre[PER_END_NT], ptsz_LigneEsclave[ULT_END_NT])))
    return s_ret;
  if ((s_ret = strcmp(ptsz_LigneMaitre[PER_SEC_NF], ptsz_LigneEsclave[ULT_SEC_NF])))
    return s_ret;
  if ((s_ret = strcmp(ptsz_LigneMaitre[PER_UWY_NF], ptsz_LigneEsclave[ULT_UWY_NF])))
    return s_ret;

  RETURN_VAL(strcmp(ptsz_LigneMaitre[PER_UW_NT], ptsz_LigneEsclave[ULT_UW_NT]));
}

/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne de FCTRULT               ***/
/*** Nom : n_ActionLigneSyncCTRULT                                      ***/
/*** Parametres:                                                        ***/
/***  i ptsz_LigneMaitre  : pointeur sur la ligne du maitre,          ***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave.       ***/
/*** Retour:                                                            ***/
/***    OK si pas d'erreur,                                             ***/
/***    ERR si erreur.                                                  ***/
/**************************************************************************/
int n_ActionLigneSyncCTRULT( char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[] )
{
  DEBUT_FCT("n_ActionLigneSyncCTRULT");

  Kptsz_LigneEsclaveCTRULT = ptsz_LigneEsclave;

  RETURN_VAL(OK);
}




/**************************************************************************/
/*** Objet : fonction lancee quand aucune ligne du fichier FTRULT ne    ***/
/***         correspond a la ligne courante du fichier maitre           ***/
/*** Nom : n_ActionPereSansFilsCTRULT                                   ***/
/*** Parametres:                                                        ***/
/***    i ptsz_LigneMaitre  : pointeur sur la ligne du maitre           ***/
/*** Retour:                                                            ***/
/***    OK si pas d'erreur,                                             ***/
/***    ERR si erreur.                                      ***/
/**************************************************************************/
int n_ActionPereSansFilsCTRULT(char *ptsz_LigneMaitre[])
{
  DEBUT_FCT("n_ActionPereSansFilsCTRULT");

  RETURN_VAL(OK) ;
}

/**************************************************************************/
/*** Objet : synchronisation de IADPERICASE avec le GT des primes des ***/
/***         facs                                                       ***/
/*** Nom : n_ConditionSyncGTFAC                                         ***/
/*** Parametres:                                                        ***/
/***  i ptsz_LigneMaitre  : pointeur sur la ligne du maitre           ***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave        ***/
/*** Retour:                                                            ***/
/***    0 si synchronise,                                               ***/
/***   <0 si la ligne esclave est depassee,                             ***/
/***   >0 si la ligne esclave n'est pas depassee.                       ***/
/**************************************************************************/
int n_ConditionSyncGTFAC( char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[] )
{
  static short s_ret;

  DEBUT_FCT("n_ConditionSyncGTFAC");

  if ((s_ret = strcmp(ptsz_LigneMaitre[PER_CTR_NF], ptsz_LigneEsclave[GT_CTR_NF])))
    return s_ret;
  if ((s_ret = strcmp(ptsz_LigneMaitre[PER_END_NT], ptsz_LigneEsclave[GT_END_NT])))
    return s_ret;
  if ((s_ret = strcmp(ptsz_LigneMaitre[PER_SEC_NF], ptsz_LigneEsclave[GT_SEC_NF])))
    return s_ret;
  if ((s_ret = strcmp(ptsz_LigneMaitre[PER_UWY_NF], ptsz_LigneEsclave[GT_UWY_NF])))
    return s_ret;

  RETURN_VAL(strcmp(ptsz_LigneMaitre[PER_UW_NT], ptsz_LigneEsclave[GT_UW_NT]));
}

/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du GT des primes des facs***/
/*** Nom : n_ActionLigneSyncGTFAC                                       ***/
/*** Parametres:                                                        ***/
/***  i ptsz_LigneMaitre  : pointeur sur la ligne du maitre,          ***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave.       ***/
/*** Retour:                                                            ***/
/***    OK si pas d'erreur,                                             ***/
/***    ERR si erreur.                                                  ***/
/**************************************************************************/
int n_ActionLigneSyncGTFAC( char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[] )
{
  DEBUT_FCT("n_ActionLigneSyncGTFAC");

  /* Si depassement de la taille du tableau */
  if (Kn_NbrePrmEst == NBPrmEst_MAX)
  {
    sprintf(Ksz_MessageErr, "CTR %s, END %s, SEC %s, UWY %s, UW %s : maximum number of lines is reached ; increase NBPrmEst_MAX value",
            ptsz_LigneMaitre[PER_CTR_NF],
            ptsz_LigneMaitre[PER_END_NT],
            ptsz_LigneMaitre[PER_SEC_NF],
            ptsz_LigneMaitre[PER_UWY_NF],
            ptsz_LigneMaitre[PER_UW_NT]);
    /* Modif (28/01/98) : ecriture dans le .ano au lieu du .log */
    n_WriteAno(Ksz_MessageErr);
    Kb_ReturnStatus = 1;
  }
  else    /* Ecriture d'une ligne dans le tableau sans optimisation */
  {
    Ktbd_PrmEst[Kn_NbrePrmEst].ACY_NF = (short)atoi(ptsz_LigneEsclave[GT_ACY_NF]);
    Ktbd_PrmEst[Kn_NbrePrmEst].SCOSTRMTH_NF = (short)atoi(ptsz_LigneEsclave[GT_SCOSTRMTH_NF]);
    Ktbd_PrmEst[Kn_NbrePrmEst].SCOENDMTH_NF = (short)atoi(ptsz_LigneEsclave[GT_SCOENDMTH_NF]);
    Ktbd_PrmEst[Kn_NbrePrmEst].Type = 'E';
    Ktbd_PrmEst[Kn_NbrePrmEst].Prm = atof(ptsz_LigneEsclave[GT_AMT_M]);
    Kn_NbrePrmEst++;
  }
  /* Ecriture de la ligne dans le fichier GT pour reconduction */
  n_WriteCols(Kp_OutputFile1, ptsz_LigneEsclave, '~', 0);
  RETURN_VAL(OK);
}

/**************************************************************************/
/*** Objet : synchro de IADPERICASE avec le GT des facs PNA estimees    ***/
/*** Nom : n_ConditionSyncGTFAC                                         ***/
/*** Parametres:                                                        ***/
/***    i ptsz_LigneMaitre  : pointeur sur la ligne du maitre           ***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave        ***/
/*** Retour:                                                            ***/
/***    0 si synchronise,                                               ***/
/***   <0 si la ligne esclave est depassee,                            ***/
/***   >0 si la ligne esclave n'est pas depassee.                      ***/
/**************************************************************************/
int n_ConditionSyncGTFACPNAE( char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[] )
{
  static short s_ret;

  DEBUT_FCT("n_ConditionSyncGTFACPNAE");

  if ((s_ret = strcmp(ptsz_LigneMaitre[PER_CTR_NF], ptsz_LigneEsclave[GT_CTR_NF])))
    return s_ret;
  if ((s_ret = strcmp(ptsz_LigneMaitre[PER_END_NT], ptsz_LigneEsclave[GT_END_NT])))
    return s_ret;
  if ((s_ret = strcmp(ptsz_LigneMaitre[PER_SEC_NF], ptsz_LigneEsclave[GT_SEC_NF])))
    return s_ret;
  if ((s_ret = strcmp(ptsz_LigneMaitre[PER_UWY_NF], ptsz_LigneEsclave[GT_UWY_NF])))
    return s_ret;

  RETURN_VAL(strcmp(ptsz_LigneMaitre[PER_UW_NT], ptsz_LigneEsclave[GT_UW_NT]));
}


/* PLG 19/10/2009 - Fiche Spot n° 16778 */
/**************************************************************************/
/*** Objet : synchro de IADPERICASE avec le GT des facs PNA estimees    ***/
/*** Nom : n_ConditionSyncGTFAC                                         ***/
/*** Parametres:                                                        ***/
/***    i ptsz_LigneMaitre  : pointeur sur la ligne du maitre           ***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave        ***/
/*** Retour:                                                            ***/
/***    0 si synchronise,                                               ***/
/***   <0 si la ligne esclave est depassee,                             ***/
/***   >0 si la ligne esclave n'est pas depassee.                       ***/
/**************************************************************************/
int n_ConditionSyncSinNP(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[])
{
  static short s_ret;

  DEBUT_FCT("n_ConditionSyncSinNP");

  if ((s_ret = strcmp(ptsz_LigneMaitre[PER_CTR_NF], ptsz_LigneEsclave[SINNP_CTR_NF])))
    return s_ret;
  if ((s_ret = strcmp(ptsz_LigneMaitre[PER_END_NT], ptsz_LigneEsclave[SINNP_END_NT])))
    return s_ret;
  if ((s_ret = strcmp(ptsz_LigneMaitre[PER_SEC_NF], ptsz_LigneEsclave[SINNP_SEC_NF])))
    return s_ret;
  if ((s_ret = strcmp(ptsz_LigneMaitre[PER_UWY_NF], ptsz_LigneEsclave[SINNP_UWY_NF])))
    return s_ret;

  RETURN_VAL(strcmp(ptsz_LigneMaitre[PER_UW_NT], ptsz_LigneEsclave[SINNP_UW_NT]));
}
/* Fin PLG 19/10/2009 */


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du GT des facs           ***/
/***          PNA estimees                                              ***/
/*** Nom : n_ActionLigneSyncGTFACPNAE                                   ***/
/*** Parametres:                                                        ***/
/***    i ptsz_LigneMaitre  : pointeur sur la ligne du maitre,          ***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave.       ***/
/*** Retour:                                                            ***/
/***    OK si pas d'erreur,                                             ***/
/***    ERR si erreur.                                                  ***/
/**************************************************************************/
int n_ActionLigneSyncGTFACPNAE( char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[] )
{
  DEBUT_FCT("n_ActionLigneSyncGTFACPNAE");

  /* Si depassement de la taille du tableau */
  if (Kn_NbrePrmEst == NBPrmEst_MAX)
  {
    sprintf(Ksz_MessageErr, "CTR %s, END %s, SEC %s, UWY %s, UW %s : maximum number of lines is reached ; increase NBPrmEst_MAX value",
            ptsz_LigneMaitre[PER_CTR_NF],
            ptsz_LigneMaitre[PER_END_NT],
            ptsz_LigneMaitre[PER_SEC_NF],
            ptsz_LigneMaitre[PER_UWY_NF],
            ptsz_LigneMaitre[PER_UW_NT] );
    /* Modif (28/01/98) : ecriture dans le .ano au lieu du .log */
    n_WriteAno(Ksz_MessageErr);
    Kb_ReturnStatus = 1;
  }
  else /* Ecriture d'une ligne dans le tableau sans optimisation */
  {
    Ktbd_PrmEst[Kn_NbrePrmEst].ACY_NF       = (short)atoi(ptsz_LigneEsclave[GT_ACY_NF]);
    Ktbd_PrmEst[Kn_NbrePrmEst].SCOSTRMTH_NF = (short)atoi(ptsz_LigneEsclave[GT_SCOSTRMTH_NF]);
    Ktbd_PrmEst[Kn_NbrePrmEst].SCOENDMTH_NF = (short)atoi(ptsz_LigneEsclave[GT_SCOENDMTH_NF]);

    /* Type est positionne a P pour PNA estimees; ne sert qu'au test avant ecriture en en sortie */
    Ktbd_PrmEst[Kn_NbrePrmEst].Type = 'P';
    Ktbd_PrmEst[Kn_NbrePrmEst].PPNA = atof(ptsz_LigneEsclave[GT_AMT_M]);
    Kn_NbrePrmEst++;
  }
  RETURN_VAL(OK);
}

/* PLG 19/10/2009 - Fiche Spot n° 16778 */
/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne de taux de sinistralité  ***/
/***         des traités non proportionnels                             ***/
/*** Nom : n_ActionLigneSyncSinNP                             ***/
/*** Parametres:                                          ***/
/***  i ptsz_LigneMaitre  : pointeur sur la ligne du maitre,        ***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave.       ***/
/*** Retour:                                            ***/
/***  OK si pas d'erreur,                                   ***/
/***  ERR si erreur.                                      ***/
/**************************************************************************/
int n_ActionLigneSyncSinNP( char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[] )
{
  DEBUT_FCT("n_ActionLigneSyncSinNP");

  Kptsz_LigneEsclaveSinNP = ptsz_LigneEsclave;

  RETURN_VAL(OK);
}


/*=========================================================================
int n_PremierMoisTrimestre
objet : Calcule le premier mois du trimestre d'un mois dans une année
cette fct renvoie le numéro du mois
==========================================================================*/
int n_PremierMoisTrimestre(int pn_Mois)
{
  switch (pn_Mois)
  {
  case 1:
  case 2:
  case 3:
    return 1;
    break;
  case 4:
  case 5:
  case 6:
    return 4;
    break;
  case 7:
  case 8:
  case 9:
    return 7;
    break;
  case 10:
  case 11:
  case 12:
    return 10;
    break;
  }
  return 0;
}

/*=========================================================================
void CalculRatioNonPropSaisonnalite
objet : Calcule la somme des taux de saisonnalité associés aux trimestres
        entre la date d'effet et la date d'inventaire
        Remarque: Pour les traités non proportionnels de plus de 12 mois
                  cette somme peut dépasser les 100%.
                  Cette fct renvoie la somme des taux
==========================================================================*/
void CalculRatioNonPropSaisonnalite
(
  char   **ptsz_LigneEsclaveSinNP,   /* i - Pointeur sur le tableau des taux de saisonnalité du traité   */
  int    pn_AnneeINC,                /* i - Année de la date d'effet du traité                           */
  int    pn_MoisINC,                 /* i - Mois de début du trimestre de la date d'effet                */
  int    pn_AnneeEXP,                /* i - Année de la date d'échéance du traité                        */
  int    pn_MoisEXP,                 /* i - Mois de fin du trimestre de la date d'échéance               */
  int    *pn_NbTrimCouv,             /* o - Nombre de trimestres de couverture                           */
  double *pd_ratio                   /* o - Ratio de calcul qui permet de lisser la saisonnalité         */
)
{
  double  d_nominateur        = 0.0;  /* Nominateur du ratio à calculer                                   */
  double  d_denominateur      = 0.0;  /* Dénominateur du ratio à calculer                                 */
  int     n_NbTrimCouv        = 0;    /* Nombre de trimestres de couverture                               */
  int     n_NbMoisCouv        = 0;    /* Nombre de mois de couverture                                     */
  int     n_TrimestreINC      = 0;
  int     n_i                 = 0;

  /* Détermination du trimestre de la date d'effet du traité */
  /* (n_MoisINC contient déjà le premier mois du trimestre)  */
  switch (pn_MoisINC)
  {
  case 1:
    n_TrimestreINC = 1;
    break;
  case 4:
    n_TrimestreINC = 2;
    break;
  case 7:
    n_TrimestreINC = 3;
    break;
  case 10:
    n_TrimestreINC = 4;
    break;
  }

  /* Calcul du nombre de trimestres de couverture entre la date d'effet corrigée et la date d'échéance */
  n_NbMoisCouv = n_DureeEnMois(pn_AnneeINC, pn_MoisINC, pn_AnneeEXP, pn_MoisEXP) + 1;
  n_NbTrimCouv = n_NbMoisCouv / 3;

  /* Calcul du nominateur:   somme des taux pour n_i = PE à 4 + PE - 1          où PE = n° du trimestre de la date d'effet ie n_TrimestreINC */
  for (n_i = n_TrimestreINC; n_i <= 4 + n_TrimestreINC - 1; n_i++)
  {
    switch (n_i % 4)
    {
    case 1:
      d_nominateur += (double)atof(ptsz_LigneEsclaveSinNP[SINNP_TAUX_1]);
      break;
    case 2:
      d_nominateur += (double)atof(ptsz_LigneEsclaveSinNP[SINNP_TAUX_2]);
      break;
    case 3:
      d_nominateur += (double)atof(ptsz_LigneEsclaveSinNP[SINNP_TAUX_3]);
      break;
    case 0:
      d_nominateur += (double)atof(ptsz_LigneEsclaveSinNP[SINNP_TAUX_4]);
      break;
    }
  }
  /* Calcul du dénominateur: somme des taux pour n_i = PE à NbTrimCouv + PE - 1 où PE = n° du trimestre de la date d'effet ie n_TrimestreINC */
  for (n_i = n_TrimestreINC; n_i <= n_NbTrimCouv + n_TrimestreINC - 1; n_i++)
  {
    switch (n_i % 4)
    {
    case 1:
      d_denominateur += (double)atof(ptsz_LigneEsclaveSinNP[SINNP_TAUX_1]);
      break;
    case 2:
      d_denominateur += (double)atof(ptsz_LigneEsclaveSinNP[SINNP_TAUX_2]);
      break;
    case 3:
      d_denominateur += (double)atof(ptsz_LigneEsclaveSinNP[SINNP_TAUX_3]);
      break;
    case 0:
      d_denominateur += (double)atof(ptsz_LigneEsclaveSinNP[SINNP_TAUX_4]);
      break;
    }
  }
  /* Positionnement des variables en sortie */
  *pn_NbTrimCouv = n_NbTrimCouv;

  /*pez controle si dénominateur = 0 ou si n_NbTrimCouv <=4
   *pd_ratio      = d_nominateur / d_denominateur;    */
  *pd_ratio      = (d_denominateur == 0) ? 0.0 : d_nominateur / d_denominateur;
  *pd_ratio      = (*pd_ratio >  1.0) ? 1.0 : *pd_ratio;   /* PEZ 2312*/
}

/*========================================================================
  n_CalculTauxPrimeAcquise
==========================================================================*/
void n_CalculTauxPrimeAcquise ( char  **ptsz_LigneEsclaveSinNP,      /* i - Pointeur sur le tableau des taux de saisonnalité du traité   */
                                int     pn_NbTrimestres,             /* Nombre des trimestres à parcourir                                */
                                int     pn_MoisDebut,                /* Numéro du mois de début PEZ 2312                                 */
                                double  pd_ratio,                    /* Ratio permettant de "lisser" la saisonnalité sur la              */
                                double *pd_TxPrmAcqCible )           /* Pourcentage de prime acquise cible                               */
{
  int pn_iTrimestre;               /* indice des trimestres parcourus                                  */

  *pd_TxPrmAcqCible = 0.0;

  /* Pour chaque trimestre à prendre en compte */
  for (pn_iTrimestre = 0; pn_iTrimestre < pn_NbTrimestres; pn_iTrimestre++)
  {
    /* Cumul du taux pour le trimestre courant */
    switch (pn_MoisDebut)
    {
    case 1:
      *pd_TxPrmAcqCible += (pd_ratio * (double)atof(ptsz_LigneEsclaveSinNP[SINNP_TAUX_1]));
      break;
    case 4:
      *pd_TxPrmAcqCible += (pd_ratio * (double)atof(ptsz_LigneEsclaveSinNP[SINNP_TAUX_2]));
      break;
    case 7:
      *pd_TxPrmAcqCible += (pd_ratio * (double)atof(ptsz_LigneEsclaveSinNP[SINNP_TAUX_3]));
      break;
    case 10:
      *pd_TxPrmAcqCible += (pd_ratio * (double)atof(ptsz_LigneEsclaveSinNP[SINNP_TAUX_4]));
      break;
    }
    /* Détermination du mois de début du prochain trimestre */
    if (pn_MoisDebut < 10)
      pn_MoisDebut += 3;
    else
      pn_MoisDebut = 1;
  }
  *pd_TxPrmAcqCible = (*pd_TxPrmAcqCible > 1.0) ? 1.0 : *pd_TxPrmAcqCible;   /* PEZ 2312*/
}

/* Fin PLG 19/10/2009 */

/*=============================================================================
n_CalculPrmEstTraitNonPropSaisonnalite_02

objet : Cette fonction calcule pour les traités non proportionnels et par
        Contrat/Avenant/NumSection/Exercice/NumExercice les primes estimées ou
        PNA à comptabiliser par période et année de compte

Elle alimente le tableau écheancier primes reçues (de type EchPrmRecu,
pointé par pdb_EchPrm) dont les éléments sont les différentes périodes
de compte (mois début, mois fin de période) année de compte et montant
de prime reçue pour la période.

Pour la date d'arrêté pc_CLODAT_D, cette fonction calcule les primes estimées
ou les Primes Non Acquises pour chaque trimestre depuis la date d'effet (ou
le 01/01/exercice quand l'arrêté ne correspond pas à l'exercice de la date d'effet).

A la différence de l'ancienne fonction qu'elle remplace, celle-ci n'utilise
pas de tableau d'écheancier souscription.
Les traites non proportionnels dont le champ n_SBJCPTDEF_B = TRUE ne sont plus estimés ; 
les primes pour ces traites sont mises à zéro.

Cette fonction renvoie le nbre de postes du tableau échéancier primes reçues.
============================================================================*/
int n_CalculPrmEstTraitNonPropSaisonnalite_02 ( short  s_UWY_NF,               /* i - Exercice */
    char  *pc_CUR_CF,              /* i - Devise                                                       */
    char  *pc_CLODAT_D,            /* i - Date d'arrêté = Libelle d'inventaire                         */
    char  *pc_EXP_D,               /* i - Date d'échéance                                              */
    char  *pc_SECINC_D,            /* i - Date d'effet                                                 */
    char   c_DIFMTH_NF,            /* i - Décalage (en mois)                                           */
    int    n_SBJCPTDEF_B,		   /* i - Contrat Non proportionnel "FinalizedACC"                     */
    double d_AMTPRM_M,             /* i - Prime ultime/Aliment                                         */
    char **ptsz_LigneEsclaveSinNP, /* i - Pointeur sur le tableau des taux de saisonnalité du traité   */
    short  s_LIGNBR_NT,            /* i - Nombre d'éléments du tab ech prm reçues                      */
    T_EchPrmRecu *pdb_EchPrm,      /* i-o Tableau échéancier primes reçues                             */
    char   *pc_SSD_CF,             /* [009]  */
    char   *pc_ACCESB_CF)          /* [009]  */
{
  char   c_EXP_D[10];                       /* Date d'échéance à prendre en compte                              */
  char   c_DateMin[10];                     /* Min(Date d'arrêté, Date d'échéance)  =MIN(*pc_CLODAT_D;*pc_EXP_D)*/
  char   c_DateAnn[10];                     /* date anniversaire du contrat
                                               =DATEVAL(JOUR(*pc_SECINC_D)&"/"&MOIS(*pc_SECINC_D)&"/"&MAX(ANNEE(*pc_SECINC_D)+1;ANNEE(*pc_CLODAT_D)))   */
  int    n_ACY0;                            /* Année de compte calculée
                                               ANNEE(*pc_SECINC_D)+PLANCHER(((ANNEE(c_DateMin)-ANNEE(*pc_SECINC_D))*12+MOIS(c_DateMin)-MOIS(*pc_SECINC_D))/12;1)  */
  double d_PrimeCptaDA;                     /* Somme des primes comptabilisée à la date anniversaire            */
  double d_TotalPrimeCpta;                  /* Somme totale des primes comptabilisée                            */
  double d_ratio;                           /* Ratio permettant de "lisser" la saisonnalité sur la              */
  double d_TxPrmAcqCible;                   /* Pourcentage de prime acquise cible                               */
  double d_TxPrmAcqCibleDM;                 /* Pourcentage de prime acquise cible à Min(Date d'arrêté, échéance)*/
  double d_PrimeAcquiseCibleDM;             /* Prime acquise cible à Min(Date d'arrêté, Date d'échéance)        */
  double d_PrimeAcquiseCibleDA;             /* Prime acquise cible à la date anniversaire                       */
  double d_Prime;                           /* Prime estimée ou PNA                                             */
  int    n_AnneeCLODAT,   n_MoisCLODAT;     /* Année et mois de la date d'arrêté de l'inventaire                */
  int    n_AnneeINC,      n_MoisINC;        /* Année et mois de la date d'effet du traité                       */
  int    n_AnneeEXP,      n_MoisEXP;        /* Année et mois de la date d'échéance                              */
  int    n_AnneeDateMin,  n_MoisDateMin;    /* Année et mois de la plus petite date entre arrêté et échéance    */
  int    n_AnneeDateAnn,  n_MoisDateAnn;    /* Année et mois de la date anniversaire                            */
  int    n_NbTrimCouv;                      /* Nombre de trimestres de couverture                               */
  int    n_NbMois;                          /* Nombre de mois utilisé dans les calculs intermédiaires           */
  int    n_NbTrimestresDA;                  /* Nombre des trimestres entre date effet et date anniversaire      */
  int    n_NbTrimestresDM;                  /* Nombre de trimestres entre date d'effet corrigée et date min     */
  int    n_PerDebDB;                        /* Décalage Mois Civil Date Bilan par rapport Période Début Scor    3-PerDebDF-1+SI(3<MOIS(*pc_SECINC_D);12;0) */
  int    n_PerFinDR;                        /* Décalage Mois Civil Date Arrété par rapport Période Fin Scor     ENT((MOIS(c_DateMin)-n_MoisINC-1+SI(MOIS(c_DateMin)<MOIS(*pc_SECINC_D);12;0)+2)/3)*3 */
  int    n_MoisDebutInv;                    /* Mois où débute l'inventaire                                      */
  int    n_PosteComptable;                  /* Poste comptable                                                  */
  int    n_NbAnneesCpte;                    /* Nombre de lignes produites en sortie                             */
  int    i, i0;

  n_NbAnneesCpte = 0;

  /*-----------------------------------------------------------*/
  /* Détermination de la date d'échéance à prendre en compte   */
  /* Si la date d'échéance du traité n'est pas renseignée en   */
  /* entrée, il faut reprendre celle qui figure dans le traité */
  /*-----------------------------------------------------------*/
  memset(c_EXP_D, 0, sizeof(c_EXP_D));
  if (b_IsBlankOrEmpty(pc_EXP_D) == FALSE)
    strcpy(c_EXP_D, pc_EXP_D);
  else
    strcpy(c_EXP_D, ptsz_LigneEsclaveSinNP[SINNP_CTREXP_D]);

  /*------------------------------------------------------------------------------------------------*/
  /* Détermination du ratio de calcul qui permet d'appliquer la saisonnalité sur la durée du traité */
  /* (ratio fixe quel que soit le nombre de lignes à générer dans le GT)                            */
  /*------------------------------------------------------------------------------------------------*/
  o_ExtractionAnneeMois(pc_CLODAT_D, &n_AnneeCLODAT, &n_MoisCLODAT);
  o_ExtractionAnneeMois(pc_SECINC_D, &n_AnneeINC,    &n_MoisINC);
  o_ExtractionAnneeMois(c_EXP_D,     &n_AnneeEXP,    &n_MoisEXP);

  /* Détermination du premier mois du trimestre de la date d'effet */
  n_MoisINC = n_PremierMoisTrimestre(n_MoisINC);

  /* Détermination du dernier mois du trimestre de la date d'échéance */
  n_MoisEXP = n_PremierMoisTrimestre(n_MoisEXP) + 2;

  n_NbTrimCouv = 0;
  d_ratio      = 0.0;

  CalculRatioNonPropSaisonnalite( ptsz_LigneEsclaveSinNP,
                                  n_AnneeINC,
                                  n_MoisINC,
                                  n_AnneeEXP,
                                  n_MoisEXP,
                                  &n_NbTrimCouv,
                                  &d_ratio );

  /*----------------------------------------------------------*/
  /* Calcul du minimum entre date d'arrêté et date d'échéance */
  /*----------------------------------------------------------*/
  memset(c_DateMin, 0, sizeof(c_DateMin));
  if (strcmp(pc_CLODAT_D, c_EXP_D) < 0)
  {
    strcpy(c_DateMin, pc_CLODAT_D);
    n_AnneeDateMin = n_AnneeCLODAT;
    n_MoisDateMin  = n_MoisCLODAT;
  }
  else
  {
    strcpy(c_DateMin, c_EXP_D);
    n_AnneeDateMin = n_AnneeEXP;
    n_MoisDateMin  = n_MoisEXP;
  }

  /*--------------------------------------------------------------*/
  /* Calcul de la prime acquise cible à DateMin(arrête, échéance) */
  /*--------------------------------------------------------------*/

  /* Calcul du nombre de trimestres à prendre en compte entre la date d'effet corrigée et la date minimum */
  /* pour calculer la prime acquise cible                                                                      */
  n_NbMois         = n_DureeEnMois(n_AnneeINC, n_MoisINC, n_AnneeDateMin, n_MoisDateMin) + 1;
  n_NbTrimestresDM = n_NbMois / 3;

  n_MoisDebutInv = n_MoisINC;

  if (strcmp(c_EXP_D, pc_CLODAT_D) <= 0)
  {
    d_TxPrmAcqCible = 1;
  }
  else
  {
    n_CalculTauxPrimeAcquise( ptsz_LigneEsclaveSinNP, n_NbTrimestresDM, n_MoisDebutInv, d_ratio, &d_TxPrmAcqCible);
  }

  d_TxPrmAcqCibleDM = d_TxPrmAcqCible;

  /* La prime acquise cible correspond au taux calculé multiplié par l'aliment */
  d_PrimeAcquiseCibleDM = d_TxPrmAcqCibleDM * d_AMTPRM_M;

  /*----------------------------------------------------------------------------------------------*/
  /* Détermination du début de la période Scor au 1er trimestre de l'année de DateMin (n_PerDeb0) */
  /* et du début de la période Scor à DateMin (n_PerDeb1)                                         */
  /*----------------------------------------------------------------------------------------------*/

  /* Dbt 1er trimestre                  Date anniversaire "corrigée"            Dbt Trimestre     Date        */
  /* exercice bilan                     DA                                      inventaire        inventaire  */
  /* |----------------------------------|---------------------------------------|-----------------|           */
  /* n_PerDebDB                       12 1                                      n_PerDeb1         CLODAT_D    */

  /* Exemple: */
  /* Date effet: 01/08/2008   Inventaire au 31/12/2009                                                                */
  /* n_PerDeb0 = 7                      DA = 07/2009                            n_PerDeb1 = 4     CLODAT_D = 12/2009  */

  /*-------------------------------------------------------------------------------------*/
  /* pez Calcul de la date anniversaire du contrat                                       */
  /* DATEVAL(JOUR(*pc_SECINC_D)&"/"&MOIS(*pc_SECINC_D)&"/"&MAX(ANNEE(*pc_SECINC_D)+1;ANNEE(*pc_CLODAT_D))) */
  /*-------------------------------------------------------------------------------------*/

  /*c_DateAnn = DATEVAL(JOUR(*pc_SECINC_D)&"/"&MOIS(*pc_SECINC_D)&"/"&MAX(ANNEE(*pc_SECINC_D)+1;ANNEE(*pc_CLODAT_D)))  ;*/
  sprintf(c_DateAnn, "%d%.2d01", max(n_AnneeINC + 1, n_AnneeDateMin), n_MoisINC)  ; // warning [009]

  /*n_ACY0    = ANNEE(*pc_SECINC_D)+PLANCHER(((ANNEE(c_DateMin)-ANNEE(*pc_SECINC_D))*12+MOIS(c_DateMin)-MOIS(*pc_SECINC_D))/12;1) */
  n_ACY0    = n_AnneeINC + floor( ( (n_AnneeDateMin - n_AnneeINC) * 12 + n_MoisDateMin - n_MoisINC) / 12 );

  /*n_PerDebDB  =3-n_MoisINC-1+SI(3<MOIS(*pc_SECINC_D);12;0)  */
  n_PerDebDB  = 3 - n_MoisINC - 1 + ( (3 < n_MoisINC) ? 12 : 0);

  n_NbMois = floor( (n_MoisINC - 1) / 3) * 3 + 1; /* début Période premier trimestre pris en compte*/

  /*n_PerFinDR  =ENT((MOIS(c_DateMin)-n_MoisINC-1+SI(MOIS(c_DateMin)<MOIS(*pc_SECINC_D);12;0)+2)/3)*3  */
  /*n_PerFinDR  = floor((n_MoisDateMin - n_MoisINC - 1 + 2 + (n_MoisDateMin<n_MoisINC) ? 12 : 0 )/3) * 3;  PEZ 2312 */
  n_PerFinDR  = floor((n_MoisDateMin - n_NbMois - 1 + 2 + ((n_MoisDateMin < n_MoisINC) ? 12 : 0) ) / 3) * 3;

  /*-------------------------------------------*/
  /* Calcul des primes reçues (comptabilisées) */
  /*-------------------------------------------*/

  d_PrimeCptaDA = 0.0;      /* Calcul des primes reçues (comptabilisées) à la date anniversaire (sur l'année de compte précédente) */
  d_TotalPrimeCpta = 0.0;   /* Calcul du total des primes reçues (comptabilisées) */
  for (i = 0; i < (int)s_LIGNBR_NT; i++)
  {
    d_TotalPrimeCpta += pdb_EchPrm[i].AMT_M;
    if (pdb_EchPrm[i].ACY_NF <  n_ACY0 )
      d_PrimeCptaDA += pdb_EchPrm[i].AMT_M;
  }

  //domdomdom on initialise après
  memset(pdb_EchPrm, 0, NBPOSTECHPRM_MAX * sizeof(T_EchPrmRecu));

  /* [013] */
  /* Ne plus calculer les primes estimes sSi l'etat du contrat est "PER_SBJCPTDEF_B = TRUE"*/
  if (n_SBJCPTDEF_B != 0)
  	d_Prime = 0.0; 
  else  
  /* Calcul du montant de prime estimée ou de PNA: Prime acquise cible - Primes comptabilisées */
  d_Prime = d_PrimeAcquiseCibleDM - d_TotalPrimeCpta;

  /* Si le montant est trop petit (en valeur absolue) on ne génère pas de prime estimée ou PNA */
  if (fabs(d_Prime) <= SEUIL_PRIME) return 0;

  /* Si la date d'arrêté est postérieure à la date d'échéance et que la prime est négative (PNA) on ne génère aucune ligne */
  if ((strcmp(pc_CLODAT_D, c_EXP_D) >= 0) && (d_Prime) <= SEUIL_MONTANT) return 0;        //[007] seuil en dur devient SEUIL_MONTANT

  /*-----------------------------------------------*/
  /* Test de la ventilation par année de compte    */
  /*-----------------------------------------------*/
  if ((strcmp(c_DateAnn, pc_CLODAT_D) < 0) && (strcmp(pc_CLODAT_D, c_EXP_D) < 0) && n_PerDebDB > 1)
  {
    /* dans ce cas, on a dépassé la date anniversaire dans l'année bilan, le traité est décalé, il faut ventiler par AC
                Per Scor Deb    Per Scor Fin            ACY
      ---------------------------------------------------------------
      1° ligne    n_PerDebDB           12               n_ACY0 -1
      2° ligne       1            PerFinDR              n_ACY0      */
    /*----------------------------------------------------------------------------------------------*/
    /*   calcul de la premiere ligne                                                                */
    /*----------------------------------------------------------------------------------------------*/
    /* Nombre de trimestres entre la date d'effet corrigée et la date anniversaire pour calculer la prime acquise cible */
    o_ExtractionAnneeMois(c_DateAnn, &n_AnneeDateAnn, &n_MoisDateAnn);

    n_NbMois              = n_DureeEnMois(n_AnneeINC, n_MoisINC, n_AnneeDateAnn, n_MoisDateAnn) + 1;
    n_NbTrimestresDA        = n_NbMois / 3;
    n_CalculTauxPrimeAcquise( ptsz_LigneEsclaveSinNP, n_NbTrimestresDA, n_MoisDebutInv,  d_ratio, &d_TxPrmAcqCible);

    /* La prime acquise cible correspond au taux calculé multiplié par l'aliment */
    d_PrimeAcquiseCibleDA = d_TxPrmAcqCible * d_AMTPRM_M;


    
  /* [013] */
  /* Ne plus calculer les primes estimes sSi l'etat du contrat est "PER_SBJCPTDEF_B = TRUE"*/
  if (n_SBJCPTDEF_B != 0)
  	d_Prime = 0.0; 
  else
    /* Calcul du montant de prime estimée ou de PNA: Prime acquise cible - Primes comptabilisées */
    d_Prime = d_PrimeAcquiseCibleDA - d_PrimeCptaDA;  	   

    /* On ne génère de prime estimée ou de PNA que si le montant n'est pas trop petit (en valeur absolue) */
    if (fabs(d_Prime) > SEUIL_PRIME)
    {
      pdb_EchPrm[n_NbAnneesCpte].SCOSTRMTH_NF = (unsigned char)n_PerDebDB;
      pdb_EchPrm[n_NbAnneesCpte].SCOENDMTH_NF = 12;
      pdb_EchPrm[n_NbAnneesCpte].ACY_NF       = n_ACY0 - 1;
      pdb_EchPrm[n_NbAnneesCpte].AMT_M        = d_Prime;

      n_NbAnneesCpte++;
    }
    /*----------------------------------------------------------------------------------------------*/
    /*   calcul de la deuxieme ligne                                                                */
    /*----------------------------------------------------------------------------------------------*/

  /* [013] */
  /* Ne plus calculer les primes estimes Si l'etat du contrat est "PER_SBJCPTDEF_B = TRUE"*/
  if (n_SBJCPTDEF_B != 0)
  	d_Prime = 0.0; 
  else
    /* Calcul du montant de prime estimée ou de PNA: Prime acquise cible - Primes comptabilisées */
    d_Prime = d_PrimeAcquiseCibleDM - d_TotalPrimeCpta - d_Prime;

    if (fabs(d_Prime) > SEUIL_PRIME)
    {
      pdb_EchPrm[n_NbAnneesCpte].SCOSTRMTH_NF = 1;
      pdb_EchPrm[n_NbAnneesCpte].SCOENDMTH_NF = (unsigned char)n_PerFinDR;
      pdb_EchPrm[n_NbAnneesCpte].ACY_NF       = n_ACY0 ;
      pdb_EchPrm[n_NbAnneesCpte].AMT_M        = d_Prime;

      n_NbAnneesCpte++;
    }
  }
  else
  {
    /*----------------------------------------------*/
    /* Cas où il ne faut générer qu'une seule ligne */
    /*----------------------------------------------*/
    n_PerDebDB      = ( n_PerDebDB > n_PerFinDR) ? 1 : n_PerDebDB;

    /* Initialisation de la période de compte */
    
    /* [013] */
    /* Ne plus calculer les primes estimes sSi l'etat du contrat est "PER_SBJCPTDEF_B = TRUE"*/
    if (n_SBJCPTDEF_B != 0)
  	d_Prime = 0.0;    

    pdb_EchPrm[n_NbAnneesCpte].SCOSTRMTH_NF = (unsigned char)n_PerDebDB;
    pdb_EchPrm[n_NbAnneesCpte].SCOENDMTH_NF = (unsigned char)n_PerFinDR;
    pdb_EchPrm[n_NbAnneesCpte].ACY_NF       = n_ACY0;
    pdb_EchPrm[n_NbAnneesCpte].AMT_M        = d_Prime;

    n_NbAnneesCpte++;
  }
  i = 0;
  for (i0 = 0; i0 < n_NbAnneesCpte; i0++)
  {
    
  /* [013] */
  /* Ne plus calculer les primes estimes sSi l'etat du contrat est "PER_SBJCPTDEF_B = TRUE"*/
  if (n_SBJCPTDEF_B != 0)
  	d_Prime = 0.0; 
  else
    d_Prime = pdb_EchPrm[i0].AMT_M;     

    /* Détermination du poste comptable selon qu'on a calculé une prime estimée ou des PNAs */
    n_PosteComptable = (d_Prime >= 0) ? POSTE_CPTABLE_ESTIMATION_NON_PROP : POSTE_CPTABLE_PNA_NON_PROP;

    i = ( i0 == 0 && n_NbAnneesCpte > 1 ) ? 1 : 0;

    /* Ecriture du montant de prime estimée ou PNA calculé dans le fichier de traces */
    //                        1  2  3  4  5  6  7  8  9    10    11    12    13    14    15 16 17 18 19 20 21    22 23 24 25    26    27    28    29 30
    fprintf(Kp_OutputFile4, "%s~%s~%d~%s~%s~%s~%s~%s~%s~%s~%s~%.3lf~%.3lf~%.3lf~%.3lf~%.3lf~%.3lf~%d~%d~%d~%d~%d~%d~%.3lf~%d~%d~%d~%.3lf~%.3lf~%.3lf~%.3lf~%d\n",
            pc_SSD_CF,                                                    /*  [009] Ajout filiale                                                */
            pc_ACCESB_CF,                                                 /*  [009] Ajout Etablissement                                          */
            (int)s_UWY_NF,                                                /*  1 Exercice de l'inventaire                                         */
            (i == 1 ) ? c_DateAnn : pc_CLODAT_D,                          /*  2 Date d'inventaire                                                */
            ptsz_LigneEsclaveSinNP[SINNP_CTR_NF],                         /*  3 Traité                                                           */
            ptsz_LigneEsclaveSinNP[SINNP_END_NT],                         /*  4 N° d'ordre                                                       */
            ptsz_LigneEsclaveSinNP[SINNP_SEC_NF],                         /*  5 Section                                                          */
            ptsz_LigneEsclaveSinNP[SINNP_UWY_NF],                         /*  6 Exercice du traité                                               */
            pc_SECINC_D,                                                  /*  7 Date d'effet                                                     */
            c_EXP_D,                                                       /*  8 Date d'échéance                                                  */
            pc_CUR_CF,                                                    /*  9 Devise                                                           */
            (double)(atof(ptsz_LigneEsclaveSinNP[SINNP_TAUX_1]) * 100),   /* 10 Taux de sinistralité appliqué au 1er trimestre                   */
            (double)(atof(ptsz_LigneEsclaveSinNP[SINNP_TAUX_2]) * 100),   /* 11 Taux de sinistralité appliqué au 2ème trimestre                  */
            (double)(atof(ptsz_LigneEsclaveSinNP[SINNP_TAUX_3]) * 100),   /* 12 Taux de sinistralité appliqué au 3ème trimestre                  */
            (double)(atof(ptsz_LigneEsclaveSinNP[SINNP_TAUX_4]) * 100),   /* 13 Taux de sinistralité appliqué au 4ème trimestre                  */
            d_AMTPRM_M,                                                   /* 14 Aliment                                                          */
            (i == 1 ) ? d_PrimeCptaDA : d_TotalPrimeCpta,                 /* 15 Total des primes reçues                                          */
            n_MoisINC,                                                    /* 16 1er mois du trimestre de la date d'effet                         */
            n_MoisEXP,                                                    /* 17 Dernier mois du trimestre de la date d'échéance                  */
            (i == 1 ) ? n_NbTrimestresDA : n_NbTrimestresDM,              /* 18 Nombre de trimestres à générer pour l'inventaire                 */
            n_MoisDebutInv,                                               /* 19 Mois de début à générer pour l'inventaire                        */
            n_MoisDateMin,         /*PEZ 2312 */                          /* 20  Mois de début à générer pour l'inventaire                       */
            n_NbTrimCouv,                                                 /* 21  Nombre de trimestres de couverture du traité                    */
            d_ratio * 100,                                                /* 22  Ratio de calcul qui lisse la saisonnalité sur la durée du traité*/
            (int)pdb_EchPrm[i0].SCOSTRMTH_NF,                             /* 23  Début de la période Scor générée                                */
            (int)pdb_EchPrm[i0].SCOENDMTH_NF,                             /* 24  Fin de la période Scor                                          */
            (int)pdb_EchPrm[i0].ACY_NF,                                   /* 25  Année de compte                                                 */
            (i == 1 ) ? d_TxPrmAcqCible * 100 : d_TxPrmAcqCibleDM * 100,  /* 26  Pourcentage de prime acquise cible                              */
            (i == 1 ) ? d_PrimeAcquiseCibleDA : d_PrimeAcquiseCibleDM,    /* 27  Prime acquise cible                                             */
            (d_Prime > 0) ? d_Prime : (double)0,                          /* 28  Prime estimée                                                   */
            (d_Prime > 0) ? (double)0 : d_Prime,                          /* 29  Prime Non Acquise                                               */
            n_PosteComptable);                                            /* 30 Poste comptable                                                  */
            
            
/*printf(" DANS SAISONNALITE %s~%s~%d~%s~%s~%s~%s~%s~%s~%s~%s~%.3lf~%.3lf~%.3lf~%.3lf~%.3lf~%.3lf~%d~%d~%d~%d~%d~%d~%.3lf~%d~%d~%d~%.3lf~%.3lf~%.3lf~%.3lf~%d\n",
            pc_SSD_CF,                                                    
            pc_ACCESB_CF,                                                 
            (int)s_UWY_NF,                                                
            (i == 1 ) ? c_DateAnn : pc_CLODAT_D,                          
            ptsz_LigneEsclaveSinNP[SINNP_CTR_NF],                         
            ptsz_LigneEsclaveSinNP[SINNP_END_NT],                           
            ptsz_LigneEsclaveSinNP[SINNP_SEC_NF],                         
            ptsz_LigneEsclaveSinNP[SINNP_UWY_NF],                         
            pc_SECINC_D,                                                  
            c_EXP_D,                                                        
            pc_CUR_CF,                                                    
            (double)(atof(ptsz_LigneEsclaveSinNP[SINNP_TAUX_1]) * 100),   
            (double)(atof(ptsz_LigneEsclaveSinNP[SINNP_TAUX_2]) * 100),   
            (double)(atof(ptsz_LigneEsclaveSinNP[SINNP_TAUX_3]) * 100),   
            (double)(atof(ptsz_LigneEsclaveSinNP[SINNP_TAUX_4]) * 100),   
            d_AMTPRM_M,                                                    
            (i == 1 ) ? d_PrimeCptaDA : d_TotalPrimeCpta,                 
            n_MoisINC,                                                    
            n_MoisEXP,                                                    
            (i == 1 ) ? n_NbTrimestresDA : n_NbTrimestresDM,                
            n_MoisDebutInv,                                               
            n_MoisDateMin,                             
            n_NbTrimCouv,                                                 
            d_ratio * 100,                                                
            (int)pdb_EchPrm[i0].SCOSTRMTH_NF,                             
            (int)pdb_EchPrm[i0].SCOENDMTH_NF,                             
            (int)pdb_EchPrm[i0].ACY_NF,                                   
            (i == 1 ) ? d_TxPrmAcqCible * 100 : d_TxPrmAcqCibleDM * 100,  
            (i == 1 ) ? d_PrimeAcquiseCibleDA : d_PrimeAcquiseCibleDM,    
            (d_Prime > 0) ? d_Prime : (double)0,                          
            (d_Prime > 0) ? (double)0 : d_Prime,                          
            n_PosteComptable);     */       
            
  }
  return n_NbAnneesCpte;
}


/* Fin [013] */

/****************************************************************************
[024]
 Objet : REQ9.6 Calcul UPR IFRS17
 Retour: Valeur UPR IFRS17
****************************************************************************/

double d_CalculPNAIFRS17 (double d_EGPI, char sz_IncDat[9], char sz_CloDat[9], char sz_ExpDat[9], double d_ITDWP)
{
	double d_PNAIFRS17;
	int n_IncDatD, n_IncDatM, n_IncDatY, n_CloDatD, n_CloDatM, n_CloDatY, n_ExpDatD, n_ExpDatM, n_ExpDatY;
	int n_Diff1, n_Diff2;
	n_Diff1 = 0;
	n_Diff2 = 0;

	/* Extraction Jour, Mois, Annee */
	o_ExtractionAnneeMoisJour(sz_IncDat, &n_IncDatY, &n_IncDatM, &n_IncDatD);
	o_ExtractionAnneeMoisJour(sz_CloDat, &n_CloDatY, &n_CloDatM, &n_CloDatD);
	o_ExtractionAnneeMoisJour(sz_ExpDat, &n_ExpDatY, &n_ExpDatM, &n_ExpDatD);
	o_ExtractionAnneeMoisJour(sz_CloDat, &Kn_CloDatY, &Kn_CloDatM, &Kn_CloDatD); // [029]
	
	/* Calcul Differences des dates */
	n_Diff1 = nbJours_Entre_Deux_Dates( n_IncDatD, n_IncDatM, n_IncDatY, n_CloDatD, n_CloDatM, n_CloDatY);
	n_Diff2 = nbJours_Entre_Deux_Dates( n_IncDatD, n_IncDatM, n_IncDatY, n_ExpDatD, n_ExpDatM, n_ExpDatY);

	/* if Closing Date >= ExpiryDate
 		then --> UPR = 0
 		else --> IFRS17 UPR = EGPI * (InceptionDate - ClosingDate) / (InceptionDate - ExpiryDate) - ITD Written Premium */
	if(n_Diff2 != 0)
	{
		if (nbJours_Entre_Deux_Dates(n_CloDatD, n_CloDatM, n_CloDatY, n_ExpDatD, n_ExpDatM, n_ExpDatY) <= 0)
			d_PNAIFRS17 = 0 ;
		else
			d_PNAIFRS17 = d_EGPI * n_Diff1/n_Diff2 - d_ITDWP ;	
	}
	return d_PNAIFRS17;
}
