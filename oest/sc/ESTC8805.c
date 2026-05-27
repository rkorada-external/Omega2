/*==============================================================================
nom de l'application          : ESTIMATION
nom du source                 : ESTC8805.c
revision                      : $Revision: 1.1.1.1 $
date de creation              : 11/05/2004
auteur                        : M. DJELLOULI
references des specifications : SPOT 10103
squelette de base             : batch
------------------------------------------------------------------------------
description :
   Ventilation des Couvertures Non Proportionnelles

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    21/02/2006   M.DJELLOULI  SPOT 12055 - Extension G�n�ration du Fichier Anomalie
                                           sur INTRANET.
                              - Inclusion du Fichier des Filliales FLIBEL2
                              - Inclusion de 4 Nouveaux Param�tres :
                                char ICLODAT = $1
                                int BLCYEA =  $2
                                int BLCMTH =  $3
                                int TypeEdition= $4
                                char CRE_D = $5
                                char ICLODAT = $6


                              Cela incite a revoir le Fichier des ANomalies (Structure)
                              Detail
                              %-3.3s     CodeErreur
                              %-10.10s   RETCTR_NF
                              %-5.5s     RTY_NF
                              %-3.3s     RETSEC_NF
                              %-10.10s   TRNCOD_CF,
                              %-3.3s     ACMTRS,
                              %-3.3s     TYPE_ACMTRS,
                              %1.4lf     Cumul Taux PRM_R,
                              %1.4lf     Cumul Taux CLM_R,
                              %1.4lf     Cumul Taux ADDPRM_R,
                              %1.4lf     Cumul Taux OTHER_R,
                              %-10.10s   N� Ligne Lue GT,
                              %s         Libell� du Code Erreur

                              Entete
                              5.5s       Renseign� dans le JOB : Ann�e Bilan
                              3.3s       Renseign� dans le JOB : Mois Bilan
                              10.10s     Renseign� dans le JOB : Date Inventaire
                              3.3s       Renseign� dans le JOB : Type Edition (3 Type)

                              Une Rupture de Page par FILLIALE

     27/03/2008 J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
[03] 18/03/2011 D.GATIBELZA ESTDOM21408 OneLedger
[04] 23/04/2014 R. Cassis  :spot:25427 Omega2 Centralization 1B - Correction sur test maxi de boucle - derniere occurence etait pas prise
                                       Suppression des warnings
[05] 27/06/2014 R. Cassis  :spot:25036 Modifie compteur du Kn_LimTRSLNK (doubl�)
[XX] 06/04/2014 JBG :spot:25773 Modify void main declaration to int main
[06] 01/12/2014 C. Despret :spot:26391 Modifie compteur du Kn_LimVentNP (150000 au lieu de 9000) et Kn_LimPericaseNP (50000 au lieu de 12000)
[07] 05/02/2016  Florent   :spot:29066 enlever le define du GT
[08] 25/04/2016  Florent   :spot:30516 GLT:le TRN_NT n'est plus vid�
[09] 07/06/2016  Roger     :spot:29629 RETRO NP Allocation - la date bilan du trimestre en cours est mise sur les clotures g�n�r�es
[10] 02/01/2018  Roger     :spira:66772 Revert sur la pr�c�dente modification.
[011] 16/04/2018 Roger     :spira:61675 On force le mois bilan en cours (CLODAT_D nouveau parametre) au lieu du bilan trimestre pour le type edition 1
[012] 23/04/2018 MZM       :spira:65651:Allocation NP : Differenciation de l'IFRS et EBS par le 2 eme caratere du DETTRS.
[013] 27/01/2019   KBAGWE	: spira 79904 : EBS - TNR - Funds Held discrepancies
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "struct.h"
#include "estserv.h"
#include "ESTC8805.h"


/*-----------------------------------------------------------------------------*/
/* structure de selection (Ventilation Contrats Accs pour chaque Contrat Retro */
/*-----------------------------------------------------------------------------*/
typedef struct {
  double  CC_Amt;
  long    CC_ACMTRS_CF;
} T_CUMUL_GT;


/*------------------------------------------------*/
/* MOD001 - inclusion de l'interface du composant */
/*------------------------------------------------*/
typedef struct {
  unsigned char SSD;
  char    LAG;
  char    LIBSSD[17];  /* Libelle Filiale */
  char    LIBCUR[4];   /* Libelle monnaie */
} T_LIB_SSD;

#define NB_SSD_MAX      150 /*Nbre max de filiales*/


/*---------------------------------------------*/
/* d�finition des constantes et macros priv�es */
/*---------------------------------------------*/
#define MAXLIG_RUPT 10000
#define INT(a) (((int)(a)-(int)('0')))
#define Kn_LimVentNP 150000     //9000           /* nombre maxi de lignes de Ventilation Retro [006] passe a 1500000*/
#define Kn_LimPericaseNP 70000  //12000          /* nombre maxi de lignes de Contrats Non Prop dans Pericase */
#define Kn_LimTRSLNK 4000                        /* Le nombre max de postes est fixe a 2000 [005] */

int     Kn_NbL, Kn_NbLRI, Kb_cond, Kb_condRI;
T_CUMUL_GT Ktb_CumulGt[MAXLIG_RUPT];
T_CUMUL_GT Ktb_CumulGtRI[MAXLIG_RUPT];

/*----------------------*/
/* variables de travail */
/*----------------------*/
FILE    *Kp_OutputFilGt ;           /* pointeur sur le fichier de sortie GT */
FILE    *Kp_OutputFilGtAno ;        /* pointeur sur le fichier de sortie GT ANOMALIES */
FILE    *Kp_OutputFilGtNpAlloc ;    /* pointeur sur le fichier de sortie GT NP allocation retro */


T_RUPTURE_VAR   bd_RuptGt ;         /* variable de gestion de la synchronisation avec le fichier GT */
T_RUPTURE_VAR   bd_RuptVentNP ;     /* variable de gestion de la synchronisation avec le fichier GT */
T_RUPTURE_VAR   bd_RuptTRSLNK ;     /* variable de gestion de la synchronisation avec le fichier Poste de Regroupent */
T_RUPTURE_VAR   bd_RuptPericaseNP ; /* variable de gestion de la synchronisation avec le fichier PERICASE */

int Kn_Acy ;                        /* variable de travail: annee de la periode compte complet */
unsigned char Kc_ScoEndMth ;        /* variable de travail: mois fin de la periode compte complet */


// Traitement Fichier TOTGTAR
int n_InitGt                ( T_RUPTURE_VAR *pbd_Rupt ) ;
int n_ActionLigneGt         ( char **ptb_InRec_Cur ) ;
int n_IsR1Gt                ( char **ptb_InRec, char **pbd_InRec_Cur );
int n_ActionFirstRuptGt   ( char **ptb_InRec_Cur ) ;
int n_ActionLastRuptGt      ( char **ptb_InRec_Cur ) ;


// Traitement Fichier TVENTNP (Chargement en Table)
int n_InitVentNP      ( T_RUPTURE_VAR *pbd_Rupt ) ;
int n_ActionLigneVentNP     ( char **ptb_InRec_Cur ) ;
int n_IsR1VentNP            ( char **ptb_InRec, char **pbd_InRec_Cur );

// Traitement Fichier PERICASE Non Prop (Chargement en Table)
int n_InitPericaseNP        ( T_RUPTURE_VAR *pbd_Rupt ) ;
int n_ActionLignePericaseNP ( char **ptb_InRec_Cur ) ;
int n_IsR1PericaseNP    ( char **ptb_InRec, char **pbd_InRec_Cur );


// Traitement Fichier FTRSLNK (Chargement en Table)
int n_InitTRSLNK      ( T_RUPTURE_VAR *pbd_Rupt ) ;
int n_ActionLigneTRSLNK     ( char **ptb_InRec_Cur ) ;
int n_IsR1TRSLNK          ( char **ptb_InRec, char **pbd_InRec_Cur );


// Fichier FTRSLNK Charger en Table & Fonctions de Recherche de Codes
// int Kn_NbLigTRSLNK;
T_TRSLNK Ktbd_TrsLnk[Kn_LimTRSLNK];
int Kn_MaxTRSLNK;

int n_ChargerTRSLNK ( short s_TrtCod ) ;
int n_RechPoste(char Check_DETTRS_CF[9]) ;
// int n_TypePoste(char *sz_poste, FILE *) ;
// int n_RechPoste_CourtageREC(char *sz_poste, short n_acmtrs_nt);

// TVENTNP
// Fichier Ventilations RETRO NP - Chargement de la Table
int Kn_NbLigVentNP;
T_VENTNP Ktbd_VentNP[Kn_LimVentNP];

/* pour Chaque RETCTR_NF, RTY_NF, RETSEC_NF de TOTGTAR */
int Kn_MinSeekVentNP;       // Limite Inferieure de Contrats Accept Trouvee
int Save_MinSeekVentNP = 1;       // Limite Inferieure de Contrats Accept Trouvee
int Kn_MaxSeekVentNP;       // Limite Superieure de Contrats Accept Trouvee
int Kn_MaxVentNP ;
int n_SeekVentNP (char Seek_RETCTR_NF[10], int Seek_RTY_NF, int Seek_RETSEC_NF, char Seek_CUR_CF[4] )  ;		/*MOD013*/

// PERICASE
// Fichier Ventilations RETRO NP - Chargement de la Table
int Kn_NbLigPericaseNP;
T_PERICASENP Ktbd_PericaseNP[Kn_LimPericaseNP];

/* pour Chaque RETCTR_NF, RTY_NF, RETSEC_NF de TOTGTAR */
int Kn_MinSeekPericaseNP;       // Limite Inferieure de Contrats Accept Trouvee
int Save_MinSeekPericaseNP = 1;       // Limite Inferieure de Contrats Accept Trouvee
int Kn_MaxSeekPericaseNP;       // Limite Superieure de Contrats Accept Trouvee
int Kn_MaxPericaseNP ;
int n_SeekPericaseNP (char Seek_RETCTR_NF[10], int Seek_RTY_NF, int Seek_RETSEC_NF )  ;

static int n_ChargLib();

char save_PER_CTR_NF[10];
char save_PER_UWY_NF[5];
char save_PER_SEC_NF[5];

// int n_ListVentNP () ;
long Num_LigneWrite;
long Num_LigneLue;
long Nb_NouvelleLignes;

int idx_reg;

// MOD001
/*=========================== Messages d'Anomalies =========================*/
/*--------------------------------------------------------------------------*/
static char MsgAno_Fr01[] = "Contrat R�tro non trouv� dans le Fichier P�rim�tre" ;
static char MsgAno_Fr02[] = "Erreur Poste de Regroupement Non Trouv� " ;
static char MsgAno_Fr03[] = "Erreur sur Cumul Taux Ventilation non �gal � 0 ou 100%";
/*--------------------------------------------------------------------------*/
static char MsgAno_En01[] = "Retro Contract not Found in the Perimeter File" ;
static char MsgAno_En02[] = "Error on Regroupement Poste Not Found" ;
static char MsgAno_En03[] = "Error Sum of Percentage Rates (Must be 0 or 100%) ";

/*--------------------------------------------------------------------------
static char EntAno_Fr01[] = "Postes Non Ouvertures" ;
static char EntAno_Fr02[] = "Postes Ouvertures" ;
static char EntAno_Fr03[] = "Postes GTAR";
--------------------------------------------------------------------------*/
static char EntAno_En01[] = "Non Opening Postes" ;
static char EntAno_En02[] = "Opening Postes" ;
static char EntAno_En03[] = "GTAR Postes";

char sz_MsgAno[64];           /* Libelle Msg*/
char sz_EntAno[32];           /* Libelle Msg*/
/*--------------------------------------------------------------------------*/
char Kc_Lang;   /* Code langue */
int Kpn_ind[NB_SSD_MAX];
T_LIB_SSD Kbd_Lib[NB_SSD_MAX];  /* Libelles
                             (indice issu de Kpn_ind) */
int n_SSD_CF;
int n_indSsd;/* Indice libelle filiale */
char *sz_LibSsd,      /* Libelle filiale */
     *sz_LibCur;            /* Libelle monnaie */
void ReformatDate(char c_Lag, char sz_DateInput[9], char sz_DateOutput[11]);
void ReformatMontant(char c_Lag, double n_Mt, char *sz_Mt);
void o_AjoutSeparateurMt(char c_Lag, char *sz_MtFormate);

#define KnMax_Lines 30
int  Kn_lignes, Kn_Page, Kn_Page1;
char Ksz_titre[43] = "Anomalies of Ventilation Generation Report";
char Ksz_shell[10] = "ESID2562";

char Ksz_date[9], Ksz_DJ[11];

char Prt_CodeErreur[3];
char Prt_RETCTR_NF[10];
char Prt_RTY_NF[5];
char Prt_RETSEC_NF[3];
char Prt_TRNCOD_CF[9];
char Prt_ACMTRS[3];
char Prt_TYPE_ACMTRS[3];
char Prt_PRM_R[7];
char Prt_CLM_R[7];
char Prt_ADDPRM_R[7];
char Prt_OTHER_R[7];
char Prt_NumLine[10];
char Prt_BLCYEA[5];
char Prt_BLCMTH[3];
char Prt_CLODAT[9];
char Prt_TypeEdition[3];
char Prt_ErrorLibel[64];
char Prt_DDAY[9];
char Prt_CUR_B[2];

//[09]
char Ksz_AnneeBilan[5];
char Ksz_MoisBilan[3];
char Ksz_JourBilan[3];

int Kn_BLCYEA;
int Kn_BLCMTH;
int Kn_BLCDAY;
int Kn_TypeEdition;

#define Kn_MaxLignes 30

void EnTete();
void InitDetailAno(int NumAno);
void WriteDetailAno();
int n_save_SSD_CF;

// Fin MOD001
// Erreur sur Cumul Taux Ventilation non �gal � 0 ou 100%  (max 55 de longueur)


/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc  , char *argv[])
{
  /* Initialisation des signaux */
  InitSig () ;

  if ( n_BeginPgm ( argc, argv ) == ERR ) ExitPgm( ERR_XX , "" ) ;

  /* Recuperation du parametre correspondant a la date libelle inventaire*/
  strcpy(Prt_CLODAT, psz_GetCharArgv(1));

  /* Recuperation de l'annee de compte */
  Kn_BLCYEA = atoi(psz_GetCharArgv(2)) ;
  /* Recuperation du Mois Bilan de compte */
  Kn_BLCMTH = atoi(psz_GetCharArgv(3)) ;
  /* Recuperation de l'annee de compte */
  Kn_TypeEdition = atoi(psz_GetCharArgv(4)) ;
  /* Recuperation du parametre correspondant a la date du jour d'inventaire*/
  strcpy(Prt_DDAY, psz_GetCharArgv(5));
  Prt_DDAY[8]=0;

  //[09] Date dilan du trimestre en cours [011] date fin de mois du bilan en cours
  strncpy(Ksz_AnneeBilan,psz_GetCharArgv(6),4);
  strncpy(Ksz_MoisBilan,psz_GetCharArgv(6)+4,2);
  strncpy(Ksz_JourBilan,psz_GetCharArgv(6)+6,2);
  
  strcpy(Prt_CUR_B, psz_GetCharArgv(7));
  Ksz_AnneeBilan[4]=0;
  Ksz_MoisBilan[2]=0;
  Ksz_JourBilan[2]=0;
  printf("Bilan en cours : %s - %s - %s\n",Ksz_AnneeBilan, Ksz_MoisBilan, Ksz_JourBilan);
	
  sprintf(Prt_BLCYEA, "%d", Kn_BLCYEA);
  sprintf(Prt_BLCMTH, "%d", Kn_BLCMTH);
  sprintf(Prt_TypeEdition, "%d", Kn_TypeEdition);

  memset(sz_EntAno, 0, sizeof(sz_EntAno));

  switch ( Kn_TypeEdition )
  {
  case 1 :
    strcpy(sz_EntAno, EntAno_En01);
  case 2 :
    strcpy(sz_EntAno, EntAno_En02);
  case 3 :
    strcpy(sz_EntAno, EntAno_En03);
  }

  Kn_Page = 1;
  Kn_Page1 = 1;
  Kn_lignes = 1;
  n_save_SSD_CF = 0;

  /* ouverture du fichier de sortie GT enrichi */
  if ( n_OpenFileAppl ( "ESTC8805_O1", "wt", &Kp_OutputFilGt ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier de sortie GT enrichi */
  if ( n_OpenFileAppl ( "ESTC8805_O2", "wt", &Kp_OutputFilGtAno) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier de sortie GT enrichi NP Alloc*/
  if ( n_OpenFileAppl ( "ESTC8805_O3", "wt", &Kp_OutputFilGtNpAlloc ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptGt */
  if ( n_InitGt( &bd_RuptGt ) )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptVentNP */
  if ( n_InitVentNP( &bd_RuptVentNP ) )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptVentNP */
  if ( n_InitTRSLNK( &bd_RuptTRSLNK) )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptPericaseNP */
  if ( n_InitPericaseNP( &bd_RuptPericaseNP ) )
    ExitPgm( ERR_XX , "" ) ;

  /* Chargement des libelles  - MOD001 */
  if (n_ChargLib() == ERR)
    exit(ERR);

  /* Chargement Ventilation NP en Table */
  if ( n_ProcessingRuptureVar( &bd_RuptVentNP ) == ERR ) ExitPgm( ERR_XX , "" ) ;

  /* Chargement Poste de Regroupement en Table */
  if ( n_ProcessingRuptureVar( &bd_RuptTRSLNK) == ERR ) ExitPgm( ERR_XX , "" ) ;

  /* Chargement PERICASE Non Prop en Table */
  if ( n_ProcessingRuptureVar( &bd_RuptPericaseNP ) == ERR ) ExitPgm( ERR_XX , "" ) ;

  // On ne quitte pas le programme si la Ventilation n'existe pas, mais l'on r��crit tel quel le Fichier GT en Sortie
  // if (Kn_MaxVentNP == 0 || Kn_MaxVentNP > Kn_LimVentNP ) exit(OK) ;

  if (Kn_MaxTRSLNK == 0 || Kn_MaxTRSLNK > Kn_LimTRSLNK )
    ExitPgm( ERR_XX , "Erreur de Chargement File TRSLNK" ) ;

  if (Kn_MaxPericaseNP == 0 || Kn_MaxPericaseNP > Kn_LimPericaseNP )
    ExitPgm( ERR_XX , "Erreur de Chargement File PERICASE" ) ;

  /* lancement du traitement du fichier Perimetre de souscription IADPERICASE.dat */
  if ( n_ProcessingRuptureVar( &bd_RuptGt ) == ERR )
    ExitPgm( ERR_XX , "" ) ;


  if ( n_CloseFileAppl( "ESTC8805_I1", &( bd_RuptGt.pf_InputFil )) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC8805_I2", &( bd_RuptVentNP.pf_InputFil )) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC8805_I3", &( bd_RuptTRSLNK.pf_InputFil )) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC8805_I4", &( bd_RuptPericaseNP.pf_InputFil )) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC8805_O1", &Kp_OutputFilGt ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC8805_O2", &Kp_OutputFilGtAno ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC8805_O3", &Kp_OutputFilGtNpAlloc ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_EndPgm() == ERR )
    ExitPgm( ERR_XX , "" );

  exit(OK) ;
}


/*==============================================================================
objet :
  fonction de test de rupture de niveau 1
retour :
  0 ---> pas de rupture
  sinon     ---> rupture
==============================================================================*/
int n_IsR1Gt(
  char **pbd_InRec ,  /* adresse de la ligne en avance */
  char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
  int ret ;

  DEBUT_FCT( "n_IsR1Gt" ) ;

  if ( ( ret = strcmp( pbd_InRec[GT_RETCTR_NF], pbd_InRec_Cur[GT_RETCTR_NF] ) ) != 0 ) RETURN_VAL (ret) ;
  if ( ( ret = strcmp( pbd_InRec[GT_RTY_NF], pbd_InRec_Cur[GT_RTY_NF] ) ) != 0 ) RETURN_VAL (ret) ;
  if ( ( ret = strcmp( pbd_InRec[GT_RETSEC_NF], pbd_InRec_Cur[GT_RETSEC_NF] ) ) != 0 ) RETURN_VAL (ret) ;
  if ( strcmp(Prt_CUR_B,"T") == 0 &&  ( ret = strcmp( pbd_InRec[GT_RETCUR_CF], pbd_InRec_Cur[GT_RETCUR_CF] ) ) != 0 ) RETURN_VAL (ret) ;

  RETURN_VAL( 0 ) ;
}



/*==============================================================================
objet :
  Initialisation de la synchronisation du maitre � Perimetre de souscription +
  avec l�esclave � GT +

retour :
  OK
==============================================================================*/
int n_InitGt( T_RUPTURE_VAR *pbd_Rupt )
{
  DEBUT_FCT( "n_InitGt" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

  /* ouverture du fichier maitre Perimetre de souscription */
  if ( n_OpenFileAppl( "ESTC8805_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
    RETURN_VAL(  ERR ) ;
  pbd_Rupt->n_NbRupture = 1 ;

  /* fonction d'action sur la ligne courante du fichier maitre */
  pbd_Rupt->n_ActionLigne = n_ActionLigneGt ;

  /* fonction du test de rupture de niveau 1 */
  pbd_Rupt->n_ConditionRupture[0] = n_IsR1Gt ;
  /* fonction lancee en rupture premiere */
  pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptGt ;
  pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptGt ;

  pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL( OK ) ;
}



/*==============================================================================
objet :
  fonction lancee en rupture premiere

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRuptGt(char **ptb_InRec_Cur  ) /* adresse de la ligne courante */
{
  int Rt_SeekVentNP;
  int Rt_SeekPericaseNP;
  int idx_i = 0;
  char tmp_RETCTR_NF[10];
  int tmp_RTY_NF;
  int tmp_RETSEC_NF;
  char tmp_CUR_CF[4];		/*MOD013*/

  DEBUT_FCT( "n_ActionFirstRuptGt" ) ;

  Kn_NbL = 0 ;

  Kn_MinSeekVentNP = 0;
  Kn_MinSeekPericaseNP = 0;

  strcpy(tmp_RETCTR_NF, ptb_InRec_Cur[GT_RETCTR_NF] ) ;
  tmp_RTY_NF = atoi(ptb_InRec_Cur[GT_RTY_NF]);
  tmp_RETSEC_NF = atoi(ptb_InRec_Cur[GT_RETSEC_NF]);
  
  strcpy(tmp_CUR_CF,"");				/*MOD013*/
  if (strcmp(Prt_CUR_B,"T") == 0){
	strcpy(tmp_CUR_CF, ptb_InRec_Cur[GT_CUR_CF] ) ;		/*MOD013*/
  }
  
// MOD001
  sz_LibSsd = "";
  sz_LibCur = "";
  Kc_Lang = ' ';

  n_SSD_CF = atoi(ptb_InRec_Cur[GT_SSD_CF]);
  n_indSsd = Kpn_ind[n_SSD_CF];

  /* Si filiale existe */
  /* Recherche de tous les libelles */
  if (n_indSsd >= 0)
  {
    Kc_Lang   = Kbd_Lib[n_indSsd].LAG;
    sz_LibSsd = Kbd_Lib[n_indSsd].LIBSSD;
    sz_LibCur = Kbd_Lib[n_indSsd].LIBCUR;
  }

  // Si le Fichier des Ventilations NP est vide, on �crit l'enrgistrement du GT , tel quel;
  // C'est � dire, que l'on indique au traitement que Kn_MinSeekVentNP = 0 et Kn_MinSeekPericaseNP = 0
  if ( Kn_MaxVentNP > 0 )
  {
    // On recherche la Ventilation pour ce Contrat
    Rt_SeekVentNP = n_SeekVentNP(tmp_RETCTR_NF, tmp_RTY_NF, tmp_RETSEC_NF, tmp_CUR_CF);			/*MOD013*/

    if (Kn_MinSeekVentNP != 0)
    {
      // Kn_MinSeekVentNP = Kn_MinSeekVentNP - 1;
      for (idx_i = Kn_MinSeekVentNP; idx_i <= Kn_MaxSeekVentNP; idx_i++)
      {
      }
      // Sauvegarde du Point de Recherche dans la Table des Ventilations
      Save_MinSeekVentNP = Kn_MinSeekVentNP;

      // On recherche que ce contrat existe bien dans le Perimetre
      // Uniquement si le Contrat doit �tre Ventil�
      Rt_SeekPericaseNP = n_SeekPericaseNP(tmp_RETCTR_NF, tmp_RTY_NF, tmp_RETSEC_NF);

      // Sauvegarde du Point de Recherche dans la Table des Perimetres
      if (Kn_MinSeekPericaseNP != 0)
      {
        Save_MinSeekPericaseNP = Kn_MinSeekPericaseNP;
      }
      else
      {
        InitDetailAno(1);

        sprintf(Prt_RETCTR_NF, "%s", tmp_RETCTR_NF);
        sprintf(Prt_RTY_NF, "%d", tmp_RTY_NF);
        sprintf(Prt_RETSEC_NF, "%d", tmp_RETSEC_NF);
        sprintf(Prt_TRNCOD_CF, "%s", "");
        sprintf(Prt_ACMTRS, "%d", 0);
        sprintf(Prt_TYPE_ACMTRS, "%d", 0);
        sprintf(Prt_PRM_R, "%1.4f", 0.000);
        sprintf(Prt_CLM_R, "%1.4f", 0.000);
        sprintf(Prt_ADDPRM_R, "%1.4f", 0.000);
        sprintf(Prt_OTHER_R, "%1.4f", 0.000);
        sprintf(Prt_NumLine, "%lu", Num_LigneLue);
        WriteDetailAno();
      }
    }

  } // Kn_MaxVentNP > 0
  else
  {
    Kn_MinSeekVentNP = 0 ;
    Kn_MinSeekPericaseNP = 0;

  } // Kn_MaxVentNP > 0

  RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
  fonction lancee en rupture derniere Gt

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptGt(char **ptb_InRec_Cur  ) /* adresse de la ligne courante */
{

  DEBUT_FCT( "n_ActionLastRuptGt" ) ;

  RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
  fonction lancee pour chaque ligne

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGt(char **ptb_InRec_Cur  ) /* adresse de la ligne courante */
{
  int idx_i = 0;
  int idx_j = 0;

  double VAR_AMT = 0.0;
  double VAR_RETAMT = 0.0;
  double VAR_RETINTAMT = 0.0;
  double Save_AMT = 0.0;
  double Save_RETAMT = 0.0;
  double Save_RETINTAMT = 0.0;
  char sz_tmp[30];
  char sz_tmpret[30];
  char sz_tmpretint[30];
  char sz_trncod[9];
  char sz_ctr_nf[10];
  char sz_uwy_nf[5];
  char sz_uw_nt[5];
  char sz_end_nt[5];
  char sz_sec_nf[5];
  long  l_AcmTrs ; /* poste cumul */
  int ntype_AcmTrs = 0;
  char sz_check_dettrs[9];
  
  char s_EBS_OR_IFRS ; /* [012] Variable contenant le deuxieme caractere du DETTRS (Poste comprtable) qui indique si ESB (egale A, E que les clotures cpt) ou IFRS (S different de A E J) */  

  double CumTaux_PRM_R = 0.000;
  double CumTaux_CLM_R = 0.000;
  double CumTaux_ADDPRM_R = 0.000;
  double CumTaux_OTHER_R = 0.000;

  int ecrire_ventilation;

  char sz_Vide[2] = "" ;

  DEBUT_FCT( "n_ActionLigneGt" ) ;

  VAR_AMT = 0;
  VAR_RETAMT = 0;
  VAR_RETINTAMT = 0;

  Num_LigneLue ++ ;

  /* ecriture ligne RETRO en sortie */
  Num_LigneWrite += 1;
  n_WriteCols(Kp_OutputFilGt, ptb_InRec_Cur, '~', 0 );

  // Si le Contrat n'est pas d�j� Ventiler et qu'il existe bien dans le P�rimetre
  // on �crit la ligne de TOTGTAR telle quelle.
  if ( (strcmp(ptb_InRec_Cur[GT_CTR_NF], sz_Vide) == 0 || ptb_InRec_Cur[GT_CTR_NF][0] == ' ' ) && Kn_MinSeekVentNP != 0 && Kn_MinSeekPericaseNP != 0 )
  {
    memset(sz_check_dettrs, 0, sizeof(ptb_InRec_Cur[GT_TRNCOD_CF]));
    strcpy(sz_check_dettrs, ptb_InRec_Cur[GT_TRNCOD_CF]);
    
    s_EBS_OR_IFRS = sz_check_dettrs[1];   // [012]  

    // Kn_MinSeekVentNP = Kn_MinSeekVentNP - 1;
    idx_reg = -1;
    /* Synchronisation du fichier trslnk afin de recuperer ACMTRS_NT */
    idx_reg = n_RechPoste(sz_check_dettrs) ;
    if (idx_reg == -1) l_AcmTrs = 0 ;
    else l_AcmTrs = Ktbd_TrsLnk[idx_reg].ACMTRS_NT ;

    ntype_AcmTrs = 0;
    // Si ACMTRS est un poste de Regroupement Primes
    if ( l_AcmTrs == 1 )
      ntype_AcmTrs = 1;


    // Si ACMTRS est un poste de Regroupement Sinistres
    if ( l_AcmTrs == 21)
      ntype_AcmTrs = 2;

    // Si ACMTRS est un poste de Regroupement Primes Additionnelles
    if ( l_AcmTrs == 11)
      ntype_AcmTrs = 3;

    // Si ACMTRS est un poste de Regroupement Autres
    if ( l_AcmTrs == 31)
      ntype_AcmTrs = 4;


    /* Pour tous les contrats Acceptations trouv�s pour ce Contrat R�tro
       on effectue la Ventilation et Calcul en Fonction de ACMTRS */
    Save_AMT = atof(ptb_InRec_Cur[GT_AMT_M]);
    Save_RETAMT = atof(ptb_InRec_Cur[GT_RETAMT_M]);
    Save_RETINTAMT = atof(ptb_InRec_Cur[GT_RETINTAMT_M]);

    // Par D�faut, on �crit
    ecrire_ventilation = 1;

    /* Cumul des Taux pour V�rification si l'on doit �crire en sortie.
        SI le cumul des taux est �gal � 0 pour le poste de regroupement trouv�, on n'�crit pas en sortie */
    CumTaux_PRM_R = 0.000;
    CumTaux_CLM_R = 0.000;
    CumTaux_ADDPRM_R = 0.000;
    CumTaux_OTHER_R = 0.000;

    idx_i = Kn_MinSeekVentNP - 1;


    for (idx_i = Kn_MinSeekVentNP; idx_i <= Kn_MaxSeekVentNP; idx_i++)
    {
      if (strcmp(ptb_InRec_Cur[GT_RETCTR_NF], Ktbd_VentNP[idx_i].RETCTR_NF) == 0 && atoi(ptb_InRec_Cur[GT_RTY_NF]) == Ktbd_VentNP[idx_i].RTY_NF
    		  && ((strcmp(Prt_CUR_B,"T") == 0 && strcmp(ptb_InRec_Cur[GT_RETCUR_CF], Ktbd_VentNP[idx_i].CUR_CF) == 0) || strcmp(Prt_CUR_B,"T") != 0))
      {
        CumTaux_PRM_R += Ktbd_VentNP[idx_i].PRM_R;
        CumTaux_CLM_R += Ktbd_VentNP[idx_i].CLM_R;
        CumTaux_ADDPRM_R += Ktbd_VentNP[idx_i].ADDPRM_R;
        CumTaux_OTHER_R += Ktbd_VentNP[idx_i].OTHER_R;
      }
    }

    if (ntype_AcmTrs == 0)
    {
      InitDetailAno(2);

      sprintf(Prt_RETCTR_NF, "%s", ptb_InRec_Cur[GT_RETCTR_NF]);
      sprintf(Prt_RTY_NF, "%d", atoi(ptb_InRec_Cur[GT_RTY_NF]));
      sprintf(Prt_RETSEC_NF, "%d", atoi(ptb_InRec_Cur[GT_RETSEC_NF]));
      sprintf(Prt_TRNCOD_CF, "%s", sz_check_dettrs);
      sprintf(Prt_ACMTRS, "%lu", l_AcmTrs);
      sprintf(Prt_TYPE_ACMTRS, "%d", ntype_AcmTrs);
      sprintf(Prt_PRM_R, "%1.4f", 0.000);
      sprintf(Prt_CLM_R, "%1.4f", 0.000);
      sprintf(Prt_ADDPRM_R, "%1.4f", 0.000);
      sprintf(Prt_OTHER_R, "%1.4f", 0.000);
      sprintf(Prt_NumLine, "%lu", Num_LigneLue);

      WriteDetailAno();

      ecrire_ventilation = 0;
    }

    // Si ACMTRS est un poste de Regroupement Primes
    if (ntype_AcmTrs == 1 &&  CumTaux_PRM_R == 0) ecrire_ventilation = 0;

    // Si ACMTRS est un poste de Regroupement Sinistres
    if (ntype_AcmTrs == 2 &&  CumTaux_CLM_R == 0) ecrire_ventilation = 0;

    // Si ACMTRS est un poste de Regroupement Primes Additionnelles
    if (ntype_AcmTrs == 3 &&  CumTaux_ADDPRM_R == 0) ecrire_ventilation = 0;

    // Si ACMTRS est un poste de Regroupement Autres (Non Sinistres, Non Primes, Non Primes Additionnelles)
    if (ntype_AcmTrs == 4 &&  CumTaux_OTHER_R == 0) ecrire_ventilation = 0;


    if (ecrire_ventilation == 0)
    {
      InitDetailAno(3);

      sprintf(Prt_RETCTR_NF, "%s", ptb_InRec_Cur[GT_RETCTR_NF]);
      sprintf(Prt_RTY_NF, "%d", atoi(ptb_InRec_Cur[GT_RTY_NF]));
      sprintf(Prt_RETSEC_NF, "%d", atoi(ptb_InRec_Cur[GT_RETSEC_NF]));
      sprintf(Prt_TRNCOD_CF, "%s", sz_check_dettrs);
      sprintf(Prt_ACMTRS, "%lu", l_AcmTrs);
      sprintf(Prt_TYPE_ACMTRS, "%d", ntype_AcmTrs);
      sprintf(Prt_PRM_R, "%1.4f", CumTaux_PRM_R);
      sprintf(Prt_CLM_R, "%1.4f", CumTaux_CLM_R);
      sprintf(Prt_ADDPRM_R, "%1.4f", CumTaux_ADDPRM_R);
      sprintf(Prt_OTHER_R, "%1.4f", CumTaux_OTHER_R);
      sprintf(Prt_NumLine, "%lu", Num_LigneLue);
      WriteDetailAno();
    }


    /* Traitement des Lignes � Ventiler  */
    if (ecrire_ventilation == 1)
    {
      /* G�n�ration d'une ligne de TOTGTAR avec Montant * -1 */
      memset(sz_tmp, 0, sizeof(sz_tmp));
      memset(sz_tmpret, 0, sizeof(sz_tmpret));
      memset(sz_tmpretint, 0, sizeof(sz_tmpretint));
      sprintf(sz_tmp, "%.3lf", 0.0);
      sprintf(sz_tmpret, "%.3lf", 0.0);
      sprintf(sz_tmpretint, "%.3lf", 0.0);

      sprintf(sz_tmp, "%.3lf", (atof(ptb_InRec_Cur[GT_AMT_M]) * -1));
      ptb_InRec_Cur[GT_AMT_M] = sz_tmp;
      sprintf(sz_tmpret, "%.3lf", (atof(ptb_InRec_Cur[GT_RETAMT_M]) * -1));
      ptb_InRec_Cur[GT_RETAMT_M] = sz_tmpret;
      sprintf(sz_tmpretint, "%.3lf", (atof(ptb_InRec_Cur[GT_RETINTAMT_M]) * -1));
      ptb_InRec_Cur[GT_RETINTAMT_M] = sz_tmpretint;

//[012]
     	if ((s_EBS_OR_IFRS != 'A') && (s_EBS_OR_IFRS != 'E'))
      	ptb_InRec_Cur[GT_ORICOD_LS] = "ESID2561ESTC8805";      //[003]
      else // CLOSING EBS
      	ptb_InRec_Cur[GT_ORICOD_LS] = "ESID3704ESTC8805";

      // Ecriture de la Ligne RETRO actuelle

			//[09] 
			// Gestion postes NP pour realloc et pas postes financiers et taux de ventilation existent      
     	if (Kn_TypeEdition == 1 && ntype_AcmTrs != 4 && (Kn_MinSeekVentNP > 0 || Kn_MaxSeekVentNP != Kn_MaxVentNP))  
     	{
     		ptb_InRec_Cur[GT_BALSHEY_NF] = Ksz_AnneeBilan;
     		ptb_InRec_Cur[GT_BALSHRMTH_NF] = Ksz_MoisBilan;
     		ptb_InRec_Cur[GT_BALSHRDAY_NF] = Ksz_JourBilan;
     		n_WriteCols(Kp_OutputFilGtNpAlloc, ptb_InRec_Cur, '~', 0 );
			}
			else n_WriteCols(Kp_OutputFilGt, ptb_InRec_Cur, '~', 0 );

      idx_i = Kn_MinSeekVentNP - 1;

      for (idx_i = Kn_MinSeekVentNP; idx_i <= Kn_MaxSeekVentNP; idx_i++)
      {

        idx_j ++;
        // Initialisation Variable � Mettre � Jour
        // -------------------------------------------------------------------------------------
        VAR_AMT = 0;
        VAR_RETAMT = 0;
        VAR_RETINTAMT = 0;
        memset(sz_trncod, 0, sizeof(sz_trncod));
        memset(sz_ctr_nf, 0, sizeof(sz_ctr_nf));
        memset(sz_uwy_nf, 0, sizeof(sz_uwy_nf));
        memset(sz_uw_nt, 0, sizeof(sz_uw_nt));
        memset(sz_end_nt, 0, sizeof(sz_end_nt));
        memset(sz_sec_nf, 0, sizeof(sz_sec_nf));

        memset(sz_tmp, 0, sizeof(sz_tmp));
        memset(sz_tmpret, 0, sizeof(sz_tmpret));
        memset(sz_tmpretint, 0, sizeof(sz_tmpretint));
        sprintf(sz_tmp, "%.3lf", 0.0);
        sprintf(sz_tmpret, "%.3lf", 0.0);
        sprintf(sz_tmpretint, "%.3lf", 0.0);

        strcpy(sz_trncod, ptb_InRec_Cur[GT_TRNCOD_CF]);
        strcpy(sz_ctr_nf, Ktbd_VentNP[idx_i].CTR_NF);
        sprintf(sz_uwy_nf , "%d", Ktbd_VentNP[idx_i].UWY_NF);
        sprintf(sz_uw_nt, "%d", Ktbd_VentNP[idx_i].UW_NT);
        sprintf(sz_end_nt, "%d",  Ktbd_VentNP[idx_i].END_NT);
        sprintf(sz_sec_nf, "%d", Ktbd_VentNP[idx_i].SEC_NF);


        // Si ACMTRS est un poste de Regroupement Primes
        if (ntype_AcmTrs == 1)
        {
          // Montant � Mettre � jour
          VAR_AMT = Save_AMT * Ktbd_VentNP[idx_i].PRM_R ;
          VAR_RETAMT = Save_RETAMT * Ktbd_VentNP[idx_i].PRM_R;
          VAR_RETINTAMT = Save_RETINTAMT * Ktbd_VentNP[idx_i].PRM_R;
        }

        // Si ACMTRS est un poste de Regroupement Sinistres
        if (ntype_AcmTrs == 2)
        {
          // Montant � Mettre � jour
          VAR_AMT = Save_AMT * Ktbd_VentNP[idx_i].CLM_R;
          VAR_RETAMT = Save_RETAMT * Ktbd_VentNP[idx_i].CLM_R;
          VAR_RETINTAMT = Save_RETINTAMT * Ktbd_VentNP[idx_i].CLM_R;
        }

        // Si ACMTRS est un poste de Regroupement Primes Additionnelles
        if (ntype_AcmTrs == 3)
        {
          // Montant � Mettre � jour
          VAR_AMT = Save_AMT * Ktbd_VentNP[idx_i].ADDPRM_R;
          VAR_RETAMT = Save_RETAMT * Ktbd_VentNP[idx_i].ADDPRM_R ;
          VAR_RETINTAMT = Save_RETINTAMT * Ktbd_VentNP[idx_i].ADDPRM_R;
        }

        // Si ACMTRS est un poste de Regroupement Autres (Non Sinistres, Non Primes, Non Primes Additionnelles)
        if (ntype_AcmTrs == 4)
        {
          // Montant � Mettre � jour
          VAR_AMT = Save_AMT * Ktbd_VentNP[idx_i].OTHER_R ;
          VAR_RETAMT = Save_RETAMT * Ktbd_VentNP[idx_i].OTHER_R;
          VAR_RETINTAMT = Save_RETINTAMT * Ktbd_VentNP[idx_i].OTHER_R ;
        }


        // Mise � jour des Donn�es avant �criture
        // -------------------------------------------------------------------------------------
        ptb_InRec_Cur[GT_CTR_NF] = sz_ctr_nf;
        ptb_InRec_Cur[GT_UWY_NF] = sz_uwy_nf;
        ptb_InRec_Cur[GT_UW_NT] = sz_uw_nt;
        ptb_InRec_Cur[GT_END_NT] = sz_end_nt;
        ptb_InRec_Cur[GT_SEC_NF] = sz_sec_nf;

        sprintf(sz_tmp, "%.3lf", VAR_AMT);
        ptb_InRec_Cur[GT_AMT_M] = sz_tmp;

        sprintf(sz_tmpret, "%.3lf", VAR_RETAMT);
        ptb_InRec_Cur[GT_RETAMT_M] = sz_tmpret;

        sprintf(sz_tmpretint, "%.3lf", VAR_RETINTAMT);
        ptb_InRec_Cur[GT_RETINTAMT_M] = sz_tmpretint;

        /* ecriture de la ligne Ventilee en sortie */
        if (idx_j > 1) Nb_NouvelleLignes ++;

        Num_LigneWrite += 1;

//[012]
     	if ((s_EBS_OR_IFRS != 'A') && (s_EBS_OR_IFRS != 'E'))
      	ptb_InRec_Cur[GT_ORICOD_LS] = "ESID2561ESTC8805";      //[003]
      else // CLOSING EBS
      	ptb_InRec_Cur[GT_ORICOD_LS] = "ESID3704ESTC8805"; 

				//[09]        
      	if (Kn_TypeEdition == 1 && ntype_AcmTrs != 4)    // gestion postes NP pour realloc et pas postes financiers
      	{
      		ptb_InRec_Cur[GT_BALSHEY_NF] = Ksz_AnneeBilan;
      		ptb_InRec_Cur[GT_BALSHRMTH_NF] = Ksz_MoisBilan;
      		ptb_InRec_Cur[GT_BALSHRDAY_NF] = Ksz_JourBilan;

     			n_WriteCols(Kp_OutputFilGtNpAlloc, ptb_InRec_Cur, '~', 0 );
				}
				else n_WriteCols(Kp_OutputFilGt, ptb_InRec_Cur, '~', 0 );
      } // for
    } //if   Ecrire en Sortie
  } //if   Si le Contrat n'est pas d�j� Ventiler et qu'il existe bien dans le P�rimetre

  RETURN_VAL( OK ) ;
}

/*==============================================================================
objet :
  fonction de test de rupture de niveau 1
retour :
  0 ---> pas de rupture
  sinon     ---> rupture
==============================================================================*/
int n_IsR1VentNP(
  char **pbd_InRec ,  /* adresse de la ligne en avance */
  char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
  int ret ;

  DEBUT_FCT( "n_IsR1VentNP" ) ;
  Kn_MinSeekVentNP = 0;

  if ( ( ret = strcmp( pbd_InRec[VENT_RETCTR_NF], pbd_InRec_Cur[VENT_RETCTR_NF] ) ) != 0 ) RETURN_VAL (ret) ;
  if ( ( ret = strcmp( pbd_InRec[VENT_RTY_NF], pbd_InRec_Cur[VENT_RTY_NF] ) ) != 0 ) RETURN_VAL (ret) ;
  if ( ( ret = strcmp( pbd_InRec[VENT_RETSEC_NF], pbd_InRec_Cur[VENT_RETSEC_NF] ) ) != 0 ) RETURN_VAL (ret) ;
  if ( strcmp(Prt_CUR_B,"T") == 0 && ( ret = strcmp( pbd_InRec[VENT_CUR_CF], pbd_InRec_Cur[VENT_CUR_CF] ) ) != 0 ) RETURN_VAL (ret) ;			/*MOD013*/

  RETURN_VAL( 0 ) ;
}

/*==============================================================================
objet :
  Initialisation de la synchronisation du maitre � Perimetre de souscription +
  avec l�esclave � GT +

retour :
  OK
==============================================================================*/
int n_InitVentNP( T_RUPTURE_VAR *pbd_Rupt )
{
  DEBUT_FCT( "n_InitVentNP" ) ;
  Kn_MaxVentNP = 0;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

  /* ouverture du fichier maitre Perimetre de souscription */
  if ( n_OpenFileAppl( "ESTC8805_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) )
    RETURN_VAL(  ERR ) ;
  pbd_Rupt->n_NbRupture = 1 ;

  /* fonction d'action sur la ligne courante du fichier maitre */
  pbd_Rupt->n_ActionLigne = n_ActionLigneVentNP ;

  /* fonction du test de rupture de niveau 1 */
  pbd_Rupt->n_ConditionRupture[0] = n_IsR1VentNP ;

  pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL( OK ) ;
}



/*==============================================================================
objet :
  fonction lancee pour chaque ligne

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneVentNP(char **ptb_InRec_Cur  ) /* adresse de la ligne courante */
{
  char sz_tmp_PRM_R[30];
  char sz_tmp_CLM_R[30];
  char sz_tmp_ADDPRM_R[30];
  char sz_tmp_OTHER_R[30];

  char  MsgAno[300] ; /* message d'anomalie */

  DEBUT_FCT( "n_ActionLigneVentNP" ) ;
  Kn_MaxVentNP ++;

  if ( Kn_MaxVentNP > Kn_LimVentNP )
  {
    sprintf(MsgAno, "la taille du tableau Ktbd_VentNP depasse la taille allouee %d", Kn_MaxVentNP);
    n_WriteAno(MsgAno);
    RETURN_VAL( Kn_MaxVentNP );
  }

  // Chargement en Table
  /* ecriture dans le Perimetre de souscription en sortie */

  strcpy(Ktbd_VentNP[Kn_MaxVentNP].RETCTR_NF, ptb_InRec_Cur[VENT_RETCTR_NF] ) ;
  Ktbd_VentNP[Kn_MaxVentNP].RTY_NF = atoi(ptb_InRec_Cur[VENT_RTY_NF]);
  Ktbd_VentNP[Kn_MaxVentNP].RETSEC_NF = atoi(ptb_InRec_Cur[VENT_RETSEC_NF]);
  strcpy( Ktbd_VentNP[Kn_MaxVentNP].CTR_NF, ptb_InRec_Cur[VENT_CTR_NF] ) ;
  Ktbd_VentNP[Kn_MaxVentNP].UWY_NF = atoi(ptb_InRec_Cur[VENT_UWY_NF]);
  Ktbd_VentNP[Kn_MaxVentNP].UW_NT = (unsigned char) atoi(ptb_InRec_Cur[VENT_UW_NT]);
  Ktbd_VentNP[Kn_MaxVentNP].END_NT = (unsigned char) atoi(ptb_InRec_Cur[VENT_END_NT]);
  Ktbd_VentNP[Kn_MaxVentNP].SEC_NF = (unsigned char)atoi(ptb_InRec_Cur[VENT_SEC_NF]);

  /* Initialisation Taux de Ventilations */
  memset(sz_tmp_PRM_R, 0, sizeof(sz_tmp_PRM_R));
  memset(sz_tmp_CLM_R, 0, sizeof(sz_tmp_CLM_R));
  memset(sz_tmp_ADDPRM_R, 0, sizeof(sz_tmp_ADDPRM_R));
  memset(sz_tmp_OTHER_R, 0, sizeof(sz_tmp_OTHER_R));

  sprintf(sz_tmp_PRM_R, "%.8f", atof(ptb_InRec_Cur[VENT_PRM_R]));
  sprintf(sz_tmp_CLM_R, "%.8f", atof(ptb_InRec_Cur[VENT_CLM_R]));
  sprintf(sz_tmp_ADDPRM_R, "%.8f", atof(ptb_InRec_Cur[VENT_ADDPRM_R]));
  sprintf(sz_tmp_OTHER_R, "%.8f", atof(ptb_InRec_Cur[VENT_OTHER_R]));

  Ktbd_VentNP[Kn_MaxVentNP].PRM_R = atof(sz_tmp_PRM_R);
  Ktbd_VentNP[Kn_MaxVentNP].CLM_R = atof(sz_tmp_CLM_R);
  Ktbd_VentNP[Kn_MaxVentNP].ADDPRM_R = atof(sz_tmp_ADDPRM_R);
  Ktbd_VentNP[Kn_MaxVentNP].OTHER_R = atof(sz_tmp_OTHER_R);

  Ktbd_VentNP[Kn_MaxVentNP].SSD_CF = atoi(ptb_InRec_Cur[VENT_SSD_CF]) ;

  strcpy( Ktbd_VentNP[Kn_MaxVentNP].CUR_CF, "");
  if (strcmp(Prt_CUR_B,"T") == 0){
	strcpy( Ktbd_VentNP[Kn_MaxVentNP].CUR_CF, ptb_InRec_Cur[VENT_CUR_CF] ) ;			/*MOD013*/
  }

  RETURN_VAL( OK ) ;
}

/*==============================================================================
objet :
  fonction de test de rupture de niveau 1
retour :
  0 ---> pas de rupture
  sinon     ---> rupture
==============================================================================*/
int n_IsR1PericaseNP(
  char **pbd_InRec ,  /* adresse de la ligne en avance */
  char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
  int ret ;

  DEBUT_FCT( "n_IsR1PericaseNP" ) ;
  Kn_MinSeekPericaseNP = 0;

  if ( ( ret = strcmp( pbd_InRec[PER_CTR_NF], pbd_InRec_Cur[PER_CTR_NF] ) ) != 0 ) RETURN_VAL (ret) ;
  if ( ( ret = strcmp( pbd_InRec[PER_UWY_NF], pbd_InRec_Cur[PER_UWY_NF] ) ) != 0 ) RETURN_VAL (ret) ;
  if ( ( ret = strcmp( pbd_InRec[PER_SEC_NF], pbd_InRec_Cur[PER_SEC_NF] ) ) != 0 ) RETURN_VAL (ret) ;

  memset(save_PER_CTR_NF, 0, sizeof(save_PER_CTR_NF));
  memset(save_PER_UWY_NF, 0, sizeof(save_PER_UWY_NF));
  memset(save_PER_SEC_NF, 0, sizeof(save_PER_SEC_NF));

  strcpy(save_PER_CTR_NF, pbd_InRec_Cur[PER_CTR_NF] );
  sprintf(save_PER_UWY_NF, "%s", pbd_InRec_Cur[PER_UWY_NF] );
  sprintf(save_PER_SEC_NF, "%s", pbd_InRec_Cur[PER_SEC_NF] );

  RETURN_VAL( 0 ) ;
}

/*==============================================================================
objet :
  Initialisation de la synchronisation du maitre � Perimetre de souscription +
  avec l�esclave � GT +

retour :
  OK
==============================================================================*/
int n_InitPericaseNP( T_RUPTURE_VAR *pbd_Rupt )
{
  DEBUT_FCT( "n_InitPericaseNP" ) ;
  Kn_MaxPericaseNP = 0;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

  /* ouverture du fichier maitre Perimetre de souscription */
  if ( n_OpenFileAppl( "ESTC8805_I4", "rt", &( pbd_Rupt->pf_InputFil ) ) )
    RETURN_VAL(  ERR ) ;
  pbd_Rupt->n_NbRupture = 1 ;

  /* fonction d'action sur la ligne courante du fichier maitre */
  pbd_Rupt->n_ActionLigne = n_ActionLignePericaseNP ;

  /* fonction du test de rupture de niveau 1 */
  pbd_Rupt->n_ConditionRupture[0] = n_IsR1PericaseNP ;

  pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL( OK ) ;
}

/*==============================================================================
objet :
  fonction lancee pour chaque ligne

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePericaseNP(char **ptb_InRec_Cur  ) /* adresse de la ligne courante */
{
  int idx_i = 0 ;
  char  MsgAno[300] ; /* message d'anomalie */
  int findcontrat = 0;

  DEBUT_FCT( "n_ActionLignePericaseNP" ) ;

  if (Kn_MaxPericaseNP > 0)
  {
    // On verifie que le contrat n'est pas d�j� en liste
    for (idx_i = 1; idx_i < Kn_MaxPericaseNP; idx_i++)
    {
      if (strcmp(Ktbd_PericaseNP[idx_i].RETCTR_NF, ptb_InRec_Cur[PER_CTR_NF]) == 0 &&
          Ktbd_PericaseNP[idx_i].RTY_NF == atoi(ptb_InRec_Cur[PER_UWY_NF]) &&
          Ktbd_PericaseNP[idx_i].RETSEC_NF == atoi(ptb_InRec_Cur[PER_SEC_NF]) )
      {
        findcontrat = 1;
        idx_i = Kn_MaxPericaseNP;
      }
    } // end for
  } // endif Kn_MaxPericaseNP > 0

  if (findcontrat != 1)
  {
    Kn_MaxPericaseNP ++;

    if ( Kn_MaxPericaseNP > Kn_LimPericaseNP )
    {
      sprintf(MsgAno, "la taille du tableau Ktbd_PericaseNP depasse la taille allouee %d", Kn_MaxPericaseNP);
      n_WriteAno(MsgAno);
      RETURN_VAL( Kn_MaxPericaseNP);
    }

    // Chargement en Table
    /* ecriture dans le Perimetre de souscription en sortie */
    // printf("contrat Lu : %s %s %s\n", ptb_InRec_Cur[VENT_RETCTR_NF], ptb_InRec_Cur[VENT_RTY_NF], ptb_InRec_Cur[VENT_RETSEC_NF]);

    strcpy(Ktbd_PericaseNP[Kn_MaxPericaseNP].RETCTR_NF, ptb_InRec_Cur[PER_CTR_NF] ) ;
    Ktbd_PericaseNP[Kn_MaxPericaseNP].RTY_NF = atoi(ptb_InRec_Cur[PER_UWY_NF]);
    Ktbd_PericaseNP[Kn_MaxPericaseNP].RETSEC_NF = atoi(ptb_InRec_Cur[PER_SEC_NF]);
  } // endif (findcontrat = false)

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  fonction de test de rupture de niveau 1
retour :
  0 ---> pas de rupture
  sinon     ---> rupture
==============================================================================*/
int n_IsR1TRSLNK(
  char **pbd_InRec ,  /* adresse de la ligne en avance */
  char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
  int ret ;

  DEBUT_FCT( "n_IsR1TRSLNK" ) ;

  if ( ( ret = strcmp( pbd_InRec[TRS7_PRS_CF], pbd_InRec_Cur[TRS7_PRS_CF] ) ) != 0 ) RETURN_VAL (ret) ;

  RETURN_VAL( 0 ) ;
}

/*==============================================================================
objet :
  Initialisation Chargement TABLE des Postes Comptables
retour :
  OK
==============================================================================*/
int n_InitTRSLNK( T_RUPTURE_VAR *pbd_Rupt )
{
  DEBUT_FCT( "n_InitTRSLNK" ) ;
  Kn_MaxTRSLNK = 0;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

  /* Ouverture du Fichier des Postes de Regroupement Comptable */
  if ( n_OpenFileAppl( "ESTC8805_I3", "rt", &( pbd_Rupt->pf_InputFil ) ) )
    RETURN_VAL(  ERR ) ;
  pbd_Rupt->n_NbRupture = 1 ;

  /* fonction d'action sur la ligne courante du fichier maitre */
  pbd_Rupt->n_ActionLigne = n_ActionLigneTRSLNK ;

  /* fonction du test de rupture de niveau 1 */
  pbd_Rupt->n_ConditionRupture[0] = n_IsR1TRSLNK ;

  pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL( OK ) ;
}

/*==============================================================================
objet :
  fonction lancee pour chaque ligne

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneTRSLNK(char **ptb_InRec_Cur  ) /* adresse de la ligne courante */
{

  char  MsgAno[300] ; /* message d'anomalie */

  DEBUT_FCT( "n_ActionLigneTRSLNK" ) ;
  Kn_MaxTRSLNK ++;

  if ( Kn_MaxTRSLNK > Kn_LimTRSLNK )
  {
    sprintf(MsgAno, "la taille du tableau Ktbd_TrsLnk depasse la taille allouee %d", Kn_MaxTRSLNK);
    n_WriteAno(MsgAno);
    RETURN_VAL( Kn_MaxTRSLNK );
  }

  // Chargement en Table

  Ktbd_TrsLnk[Kn_MaxTRSLNK].PRS_CF = atoi(ptb_InRec_Cur[TRS7_PRS_CF]);
  Ktbd_TrsLnk[Kn_MaxTRSLNK].ACMTRS_NT = atoi(ptb_InRec_Cur[TRS7_ACMTRS_NT]);
  strcpy( Ktbd_TrsLnk[Kn_MaxTRSLNK].DETTRS_CF, ptb_InRec_Cur[TRS7_DETTRS_CF] ) ;

  RETURN_VAL( OK ) ;
}

/*==============================================================================
objet :
  fonction de recherche du poste
retour :
  0   ---> Pas de rupture
  < 0     ---> On n'est pas arrive au bloc synchrone
  > 0     ---> On a depasse le bloc synchrone
==============================================================================*/
int n_RechPoste(char Check_DETTRS_CF[9])
{
  int idx_z = 0 ;

  DEBUT_FCT("n_RechPoste");

  for (idx_z = 1; idx_z <= Kn_MaxTRSLNK; idx_z++)
  {
    if (strncmp(Ktbd_TrsLnk[idx_z].DETTRS_CF, Check_DETTRS_CF, 8) == 0)
    {
      idx_reg = idx_z ;
      RETURN_VAL(idx_reg);
    }
  }
  RETURN_VAL(idx_reg);
}


/*==============================================================================
objet:
  Lit le fichier binaire des Ventilations Retro NP
==============================================================================*/
int n_SeekVentNP (char Seek_RETCTR_NF[10], int Seek_RTY_NF, int Seek_RETSEC_NF, char Seek_CUR_CF[4] )			/*MOD013*/
{
  int idx_i = 0 ;
  char Val_RETCTR_NF[10];
  int Val_RTY_NF;
  int Val_RETSEC_NF;
  char Val_CUR_CF[4];			/*MOD013*/

  DEBUT_FCT("n_SeekVentNP");
  Kn_MinSeekVentNP = 0;
  Kn_MaxSeekVentNP = Kn_MaxVentNP;

  // On initiliase Kn_MinSeekVentNP et  Kn_MaxSeekVentNP aux Bornes Inf et Sup
  // Cela donne la liste des contrats Acceptations pour ce Contrat, Ann�e, Section

  for (idx_i = Save_MinSeekVentNP; idx_i <= Kn_MaxVentNP; idx_i++)
  {
    strcpy(Val_RETCTR_NF, Ktbd_VentNP[idx_i].RETCTR_NF);
    Val_RTY_NF = Ktbd_VentNP[idx_i].RTY_NF;
    Val_RETSEC_NF = Ktbd_VentNP[idx_i].RETSEC_NF;
	strcpy(Val_CUR_CF, "");			/*MOD013*/
    if (strcmp(Prt_CUR_B,"T") == 0){
		strcpy(Val_CUR_CF, Ktbd_VentNP[idx_i].CUR_CF);			/*MOD013*/
	}

    if (strcmp(Seek_RETCTR_NF, Val_RETCTR_NF) == 0 &&
        Seek_RTY_NF == Val_RTY_NF &&
        Seek_RETSEC_NF == Val_RETSEC_NF && ((
        strcmp(Prt_CUR_B,"T") == 0 && strcmp(Seek_CUR_CF, Val_CUR_CF) == 0) || strcmp(Prt_CUR_B,"T") != 0 ))				/*MOD013*/
    {
      if (Kn_MinSeekVentNP == 0) Kn_MinSeekVentNP = idx_i ;
      Kn_MaxSeekVentNP = idx_i;
    }

  }


  RETURN_VAL(Kn_MinSeekVentNP);
}

/*==============================================================================
objet:
  Lit le fichier binaire des Ventilations Retro NP
==============================================================================*/
int n_SeekPericaseNP (char Seek_RETCTR_NF[10], int Seek_RTY_NF, int Seek_RETSEC_NF )
{
  int idx_i = 0 ;
  char Val_RETCTR_NF[10];
  int Val_RTY_NF;
  int Val_RETSEC_NF;

  DEBUT_FCT("n_SeekPericaseNP");
  Kn_MinSeekPericaseNP = 0;
  Kn_MaxSeekPericaseNP = Kn_MaxPericaseNP;

  // On initiliase Kn_MinSeekPericaseNP et  Kn_MaxSeekPericaseNP aux Bornes Inf et Sup
  // Cela donne la liste des contrats Acceptations pour ce Contrat, Ann�e, Section

  for (idx_i = Save_MinSeekPericaseNP; idx_i <= Kn_MaxPericaseNP; idx_i++)  // [004]
  {
    strcpy(Val_RETCTR_NF, Ktbd_PericaseNP[idx_i].RETCTR_NF);
    Val_RTY_NF = Ktbd_PericaseNP[idx_i].RTY_NF;
    Val_RETSEC_NF = Ktbd_PericaseNP[idx_i].RETSEC_NF;

    if (strcmp(Seek_RETCTR_NF, Val_RETCTR_NF) == 0 &&
        Seek_RTY_NF == Val_RTY_NF &&
        Seek_RETSEC_NF == Val_RETSEC_NF)
    {
      if (Kn_MinSeekPericaseNP == 0) Kn_MinSeekPericaseNP = idx_i ;
      Kn_MaxSeekPericaseNP = idx_i;
    }
  }
  RETURN_VAL(Kn_MinSeekPericaseNP);
}

// Debut MOD001
/*==============================================================================
objet :
   fonction d'extraction des donnees de la table TSUBSID de la base BREF
   Sont extraits le libelle (court) filiale, le code langue, la monnaie filiale

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static int n_ChargLib()
{
  T_LIB_SSD     bd_lu;
  FILE          *p_Libelle;

  int n_indice;
  unsigned char    c_Ssd;

  DEBUT_FCT ("n_ChargLib");

  /*Initialisation du tableau d'indices*/
  memset(Kpn_ind, -1, NB_SSD_MAX);

  /* Initialisation de l'indice courant */
  n_indice = 0;

  if (n_OpenFileAppl ("ESTC8805_I5", "rt", &p_Libelle))
    RETURN_VAL (ERR);

  for (;;)   /* pour tous les enregistrement du fichier des libelles */
  {
    if (   (fread(&bd_lu, sizeof(T_LIB_SSD), 1, p_Libelle) != 1)
           || (n_indice >= NB_SSD_MAX)  )
      break;

    /*Filiale courante*/
    c_Ssd = bd_lu.SSD;

    /* Stockage dans le tableau numero filiale */
    Kbd_Lib[n_indice].SSD = c_Ssd;

    /* Stockage des libelles */
    Kbd_Lib[n_indice].LAG = bd_lu.LAG;
    strcpy (Kbd_Lib[n_indice].LIBSSD, bd_lu.LIBSSD);
    strcpy (Kbd_Lib[n_indice].LIBCUR, bd_lu.LIBCUR);

    /* Stockage de l'indice dans le tableau "par filiale" */
    Kpn_ind[c_Ssd] = n_indice;

    /* Indice suivant */
    n_indice++;
  }

  /* Fermeture du fichier des libelles */
  if (n_CloseFileAppl("ESTC8805_I5", &p_Libelle) == ERR)
    RETURN_VAL(ERR);

  RETURN_VAL(OK);
}

/*=============================================================================
 objet:
  Genere en sortie une date formatee en fonction du code langue:
  jj/mm/aaaa si code langue=F
  mm/jj/aaaa sinon
 parametres:
  c_Lag code langue
  sz_DateInput  date en entree, qui doit etre au format aaaammjj
  sz_DateOutput date formatee en sortie
=============================================================================*/
void ReformatDate(char c_Lag, char sz_DateInput[9], char sz_DateOutput[11])
{
  DEBUT_FCT("ReformatDate");

  if (c_Lag == 'F')
  {
    sz_DateOutput[0] = sz_DateInput[6];
    sz_DateOutput[1] = sz_DateInput[7];
    sz_DateOutput[3] = sz_DateInput[4];
    sz_DateOutput[4] = sz_DateInput[5];
  }
  else
  {
    sz_DateOutput[0] = sz_DateInput[4];
    sz_DateOutput[1] = sz_DateInput[5];
    sz_DateOutput[3] = sz_DateInput[6];
    sz_DateOutput[4] = sz_DateInput[7];
  }
  sz_DateOutput[2] = '/';
  sz_DateOutput[5] = '/';
  sz_DateOutput[6] = sz_DateInput[0];
  sz_DateOutput[7] = sz_DateInput[1];
  sz_DateOutput[8] = sz_DateInput[2];
  sz_DateOutput[9] = sz_DateInput[3];
  sz_DateOutput[10] = 0;
}

/*=============================================================================
 objet:
  Genere en sortie un montant formate (double sur 15 positions sans decimales)
  en fonction du code langue:
  100.000.000 si code langue=F
  100,000,000 sinon
  parametres:
  c_Lag         code langue
  d_Mt      montant en entree
  sz_MtFormat   montant formate en sortie
=============================================================================*/
void ReformatMontant(char c_Lag, double d_Mt, char *sz_MtFormate)
{
  char sz_Mt[18],
       sz_MtEntier[17];

  char c_Virgule = '.';


  DEBUT_FCT("ReformatMontant");

  /* valeur de la virgule varie en fct du code langue */
  if  (c_Lag == 'F') c_Virgule = ',';

  /* Formatage : mt sur 15 caracteres dont 3 decimales*/
  /* + eventuellement le signe (si negatif) + virgule*/
  sprintf(sz_Mt, "%17.3lf", d_Mt);

  /* Ajout d'un espace tous les 3 chiffres
                 uniquement sur la partie non decimale du nombre*/
  sprintf(sz_MtEntier,
          "%.4s %.3s %.3s %.3s",
          sz_Mt, &(sz_Mt[4]), &(sz_Mt[7]),
          &(sz_Mt[10]));

  /* Ajout des separateurs '.' ou ',' si code
     langue est respec. francais ou anglais
                 (toujours sur la partie entiere du nombre) */
  o_AjoutSeparateurMt(c_Lag, sz_MtEntier);

  /* On reconstitue le nombre i.e; on lui recolle sa
     partie decimale */
  sprintf(sz_MtFormate, "%.16s%c%s",
          sz_MtEntier,          /* partie entiere */
          c_Virgule,            /* virgule */
          & (sz_Mt[14]));       /* partie decimale */
}

/*=============================================================================
 objet:
  Ajoute un separateur (point ou virgule en fonction du code langue) pour
  separer les milliers
  parametres:
  c_Lag           code langue
  sz_MtFormat   chaine en entree/sortie
=============================================================================*/
void o_AjoutSeparateurMt(char c_Lag, char *sz_MtFormate)
{
  char c_Separateur;
  int  n_ind;

  c_Separateur = (c_Lag == 'F') ? '.' : ',';

  /* Parcours du nombre de la droite vers la gauche et on remplace
     l'espace delimitant les groupes de 3 chiffres par un separateur si
     le nombre continue sur la gauche */
  for (n_ind = strlen(sz_MtFormate) - 4 ; n_ind > 0 ; n_ind -= 4)
  {
    if (sz_MtFormate[n_ind - 1] == '-')
    {
      /* On recolle le signe au nombre */
      sz_MtFormate[n_ind]   = '-';
      sz_MtFormate[n_ind - 1] = ' ';
    }

    if ((sz_MtFormate[n_ind - 1] >= '0') && (sz_MtFormate[n_ind - 1] <= '9'))
      sz_MtFormate[n_ind] = c_Separateur;
  }
}

/*==============================================================================
  objet:
        Edition de l'en-tete
==============================================================================*/
void EnTete()
{
  char Prt_SSD_CF[3];

  if (Kn_Page1 == 1)
    Kn_Page1 = 0;
  else
    PageBreak(Kp_OutputFilGtAno);

  memset(Prt_SSD_CF, 0, sizeof(Prt_SSD_CF));
  sprintf(Prt_SSD_CF, "%d", n_SSD_CF);


  fprintf(Kp_OutputFilGtAno, "%d%c%8.8s %5.5s %3.3s %10.10s %9.9s %d\n",
          Kn_TypeEdition, Kc_Lang, Ksz_shell, Prt_BLCYEA, Prt_BLCMTH, Prt_CLODAT, Prt_DDAY, Kn_Page);
  Kn_Page++;
  Kn_lignes = 2;
  n_save_SSD_CF = n_SSD_CF;
}

/*==============================================================================
  objet:
        Edition de l'en-tete
==============================================================================*/
void InitDetailAno(int NumAno)
{
  memset(Prt_ErrorLibel, 0, sizeof(Prt_ErrorLibel));

  switch ( NumAno )
  {
  case 1 :
    if (Kc_Lang == 'F')
      strcpy(Prt_ErrorLibel, MsgAno_Fr01);
    else
      strcpy(Prt_ErrorLibel, MsgAno_En01);
  case 2 :
    if (Kc_Lang == 'F')
      strcpy(Prt_ErrorLibel, MsgAno_Fr02);
    else
      strcpy(Prt_ErrorLibel, MsgAno_En02);
  case 3 :
    if (Kc_Lang == 'F')
      strcpy(Prt_ErrorLibel, MsgAno_Fr03);
    else
      strcpy(Prt_ErrorLibel, MsgAno_En03);
  }

  if (Kn_Page1 == 1)
    EnTete();

  if (Kn_lignes > KnMax_Lines)
    EnTete();

  // Rupture Par Filliale
  if (n_save_SSD_CF != n_SSD_CF)
    EnTete();

  memset(Prt_CodeErreur, 0, sizeof(Prt_CodeErreur));
  memset(Prt_RETCTR_NF, 0, sizeof(Prt_RETCTR_NF));
  memset(Prt_RTY_NF, 0, sizeof(Prt_RTY_NF));
  memset(Prt_RETSEC_NF, 0, sizeof(Prt_RETSEC_NF));
  memset(Prt_TRNCOD_CF, 0, sizeof(Prt_TRNCOD_CF));
  memset(Prt_ACMTRS, 0, sizeof(Prt_ACMTRS));
  memset(Prt_TYPE_ACMTRS, 0, sizeof(Prt_TYPE_ACMTRS));
  memset(Prt_PRM_R, 0, sizeof(Prt_PRM_R));
  memset(Prt_CLM_R, 0, sizeof(Prt_CLM_R));
  memset(Prt_ADDPRM_R, 0, sizeof(Prt_ADDPRM_R));
  memset(Prt_OTHER_R, 0, sizeof(Prt_OTHER_R));
  memset(Prt_NumLine, 0, sizeof(Prt_NumLine));

  sprintf(Prt_CodeErreur, "%d", NumAno);
}

/*==============================================================================
  objet:
        Edition de l'en-tete
==============================================================================*/
void WriteDetailAno()
{
  fprintf(Kp_OutputFilGtAno, "%2.2s %9.9s %5.5s %2.2s %9.9s %3.3s %3.3s %6.6s %6.6s %6.6s %6.6s %10.10s %s\n",
          Prt_CodeErreur,
          Prt_RETCTR_NF,
          Prt_RTY_NF,
          Prt_RETSEC_NF,
          Prt_TRNCOD_CF,
          Prt_ACMTRS,
          Prt_TYPE_ACMTRS,
          Prt_PRM_R,
          Prt_CLM_R,
          Prt_ADDPRM_R,
          Prt_OTHER_R,
          Prt_NumLine,
          Prt_ErrorLibel
         ) ;
  Kn_lignes ++;
}
