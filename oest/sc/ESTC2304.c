/*==============================================================================
nom de l'application          : Job xxx : Step xxx
nom du source                 : ESTC2304.c
revision                      : $Revision: 1.2 $
date de creation              : 13/08/97
auteur                        : CGI (Claire Soulier)
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
        Operateur de placement : GTAr100% * placements ===> GTAr et GTRr

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
     ...           ...            ...              ...
    30/01/03       J. Ribot   ajout colonne retintamt_m sur fichier en sortie
_________________
MODIFICATION    [002]
Auteur:         D.GATIBELZA
Date:           27/03/2009
Version:        9.1
Description:    ESTDOM17149 : ESID1800  enregistrements absents dans EST_FCURCVSN, generation de mouvements avec RETCUR_CF & RETAMT_M à vide

[03] 06/07/2011  Roger Cassis :spot:21408  - Changement GT_TRN_NT en GT_TRN_NT2
[04] 23/01/2014  Roger Cassis :spot:25427  - Centralization des bases - test des retours de fonctions
[05] 13/03/2014  -=Dch=-      :spot:25427  - Centralisation des bases - modification de d_ThisGetTaux (d_QuotDest =1)
[XX] 06/04/2014 JBG           :spot:25773 Modify void main declaration to int main
[06] 28/01/2016 Florent       :spot:29066 GLT à 71 colonnes, on laisse les 14 colonnes SAP à vide
[07] 27/04/2016 Roger cassis  :spot:30516 Ajoute synchro sur trn_nt et retroauto_b
[08] 02/05/2016 -=Dch=-  	    :spot:30465 Ajout de la log PNA RETRO
[09] 21/06/2019 -=Dch=-  	    :spot:29162 Adherence retro
[10] 22/06/2016 Florent       :spot:30516 RETROAUTO_B,SPEENTNAT_CT et RETARDRETINT_B peuvent être vide (NULL)
[11] 11/07/2016 S.Behague     :spot:30904 EST P&C / RET03H - les commissions estimées ACC se deversent en rétro alors que comm originale décochée
[12] 29/11/2016 P.Garnier     :spira:54569 - ajout d'une nouvelle ligne de commission debut
[13] 14/12/2017 S.Behague     :spira:66591 - EST Life - Mauvais montants rétro suite à l'application de la rétro auto
[14] 07/10/2019 MZM           :spira:71539 - REQ10.4-REQ10.5/Retro override commission mangement 
[15] 06/07/2020 MZM           :spira:87321 I17 - Ini - Retro Overrider not specific At placement
[16] 27/08/2020 MZM           :spira:87320 I17 - I17 Overrider - Based on criteria
[17] 08/02/2022 MZM           :Spira:98240 Ajout champ GT_GAAPCOD_NT et GT_I17PRDCOD_CT et definition champs et Impact sur ESTC2303
[18] 07/09/2022 MZM           :Spira:104519  Ret overrider - retro commission Separation du calcul Fix Commission et Retro Ovr  (dans EcrireTGTAR_NEW uniquement)
[19] 28/12/2022 MZM           :Spira:108082  Ret overrider - retro commission - Copy  (dans EcrireTGTAR_NEW uniquement)
[20] 27/07/2023 JYP/TD        :Spira:108082  Ret overrider - retro commission - new filters
[21] 01/08/2023 JYP/TD        :Spira:108082  Ret overrider - retro commission - new filters I17X/EBS scope
[22] 11/10/2023 JYP/TD        :Spira:108082  Ret overrider - retro commission - new filters
[23] 11/10/2023 JYP/MZM       :Spira:108082  revert MOD19 , RET OVERRIDE exclude some TC when RAICOM_B=0 
[24] 11/10/2023 JYP/MZM/Florian:Spira:110901 add parameter Y_N for RET OVERRIDE exclude some TC when RAICOM_B=0  
[25] 30/11/2023 JYP           :Spira:110936  add 12128/12161/12121 in exclusion of RET OVERRIDE commission   
[26] 10/04/2024 JYP           :Spira:110932  parameter A-AE for RET OVERRIDE exclude some TC when RAICOM_B=0   
[27] 16/05/2024 JYP           :Spira:110932  parameter A-AE for RET OVERRIDE exclude some TC when RAICOM_B=0    
==============================================================================*/
/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <struct.h>
#include <estserv.h>


/*----------------------------------------*/
static char VERSION_ESTC2304_C[150] = "__version__: ESTC2304.c version [027] 16/05/2024 RET OVERRIDE exclude some TC" ;
//#define DBG_MODE //18


/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/
static char* TRNCOD_COMMISSION_CED = "24120002";
static char* TRNCOD_COMMISSION_EST = "21120002";

// [14]
//static char* TRNCOD_FUTUREFIXE_PRM = "2A100012";
//static char* TRNCOD_FUTUREVARI_PRM = "2A100022";
//static char* TRNCOD_FUTURE_CHG = "2A120012";

static char* FUTURE_RETRO_OVERRIDE = "2A121212";

// Pour gérer les 4 sorties de fichiers GT
enum TYPE_FIC_GT {
  FIC_GTRR = 0
  , FIC_GTAR
  , FIC_2GTAR
  , FIC_GTARP
};

#define GTES_ENTPERYEA_NF 41
#define GTES_ENTPERMTH_NF 42
#define GTES_VALPERYEA_NF 43
#define GTES_VALPERMTH_NF 44
#define GTES_TRN_NT2 45  // [003]
#define GTES_ACCTYP_NF 46
#define GTES_BALSHEY_NF_PLUS 47
#define GTES_BALSHRMTH_NF_PLUS 48
#define GTES_BALSHRDAY_NF_PLUS 49
#define GTES_COMMAC_LL 50


//[17] Redefinition des colonnes du struct.h

#define GT_NEWCOLS1_NF 62
#define GT_NEWCOLS2_NF 63
#define GT_NEWCOLS3_NF 64
#define GT_NEWCOLS4_NF 65
#define GT_NEWCOLS5_NF 66
#define GT_NEWCOLS6_NF 67
#define GT_NEWCOLS7_NF 68
#define GT_NEWCOLS8_NF 69
#define GT_NEWCOLS9_NF 70



#define MAX_TACC 50000
#define MAX_TPLAC 20000
#define MAX_TGTAR 2000000

typedef struct {
  unsigned char SSD_CF;
  unsigned char ESB_CF;
  char RETCTR_NF[10];
  unsigned char RETEND_NT;
  unsigned char RETSEC_NF;
  short RTY_NF;
  unsigned char RETUW_NT;
  int PLC_NT;
  double OVRCOM_R;
  int RTO_NF;
  int INT_NF;
  int PAY_NF;
  char KEY_CF[2];
  unsigned char ORICUR_B;
  unsigned char SSDRTO_B;
  double RETSIGSHA_R;
  char LOB_CF[3];
  unsigned char RAICOM_B;
  unsigned char RETOVRCOM_B;
  char RETCUR_CF[4];
  double TAUXRETRO_R;
  char PLCTROUVE;      /*  JR 28/04/03 */
  int BASIS_NT;
  double FIXCOM_R;
  int OVERBASIS_NT;
} T_PLAC;

typedef struct {
  unsigned char SSD_CF;
  unsigned char ESB_CF;
  short BALSHEY_NF;
  unsigned char BALSHRMTH_NF;
  unsigned char BALSHRDAY_NF;
  char TRNCOD_CF[9];
  char DBLTRNCOD_CF[9];
  char CTR_NF[10];
  unsigned char END_NT;
  unsigned char SEC_NF;
  short UWY_NF;
  unsigned char UW_NT;
  char OCCYEA_NF[5];
  short ACY_NF;
  unsigned char SCOSTRMTH_NF;
  unsigned char SCOENDMTH_NF;
  char CLM_NF[10];
  char CUR_CF[4];
  double AMT_M;
  int CED_NF;
  int BRK_NF;
  int PAY_NF;
  char KEY_NF[3];
  char RETCTR_NF[10];
  unsigned char RETEND_NT;
  unsigned char RETSEC_NF;
  short RTY_NF;
  unsigned char RETUW_NT;
  char RETOCCYEA_NF[5];
  short RETACY_NF;
  unsigned char RETSCOSTRMTH_NF;
  unsigned char RETSCOENDMTH_NF;
  char RCL_NF[10];
  char RETCUR_CF[4];
  double RETAMT_M;
  char TRN_NT[11];
  char ORICOD_LS[17];
  char RETROAUTO_B[2];
  char SPEENTNAT_CT[2];
  char EVT_NF[11];
  char REVT_NF[11];
  char RETARDRETINT_B[2];
  char NEWCOLS1_NF[11];
  char NEWCOLS2_NF[11];
  char NEWCOLS3_NF[11];
  char NEWCOLS4_NF[11];
  char NEWCOLS5_NF[11];
  char NEWCOLS6_NF[11];
  char NEWCOLS7_NF[11];
  char NEWCOLS8_NF[11];
  char NEWCOLS9_NF[11];
  double TAUXACCEPT_R;
//Pour la version des ESID0091.cmd, ESIJ0091.cmd et ESPJ0091.cmd
  short ENTPERYEA_NF;
  short ENTPERMTH_NF;
  short VALPERYEA_NF;
  short VALPERMTH_NF;
  char TRN_NT2[11];
  short ACCTYP_NF;
  short BALSHEY_NF_PLUS;
  unsigned char BALSHRMTH_NF_PLUS;
  unsigned char BALSHRDAY_NF_PLUS;
  char COMMAC_LL[65];
} T_ACC;

typedef struct {
  T_ACC * pa; /* pointeur sur une ligne T_ACC */
  T_PLAC * pp; /* pointeur sur une ligne T_PLAC */
  double AMT_M;
  double RETAMT_M;
  unsigned char RETCUR_B;
  double OVRCOMAMT_M;
  double RETOVRCOMAMT_M;
  unsigned char RAICOM_B;
  double COMAMT_M;    // calcul intermédiaire de com
  double RETCOMAMT_M;
  unsigned char Iscom_B;
} T_GTAR;

/*--------------------------*/
/*    Protoypes             */
/*--------------------------*/
static int n_ActionFirst1(char **);
static int n_InitGTA(T_RUPTURE_VAR  *);
static int n_InitPLC(T_RUPTURE_SYNC_VAR  *);
static int n_ActionLignePLC(char **v, char **);
static int n_ConditionSync(char **v, char **);
static int n_ActionLigneGTA(char **v);
static int n_ConditionRupture1(char **, char **);
static int n_ConditionRupture2(char **, char **);
static int n_ActionFirst2(char **);
int   n_ActionLast2(char **);
int n_RechCURCVSNBIS(char *, int, int);

extern int n_ProcessingRuptureVar(T_RUPTURE_VAR *);
extern int n_ProcessingRuptureSyncVar(T_RUPTURE_SYNC_VAR *, char **);

static int EcrireGT(FILE * pf, T_GTAR TGTAR, double d_Ma, double d_Mr, char * sz_trncod, double d_Mri, enum TYPE_FIC_GT type_gt);
static int EcrireGTRr(FILE * pf, T_GTAR, double d_Ma, char * sz_trncod);

static int EcrireTGTAR(T_GTAR TGTAR[], int i, int a, int p);
static int StockeLignePlac(char ** tpsz_ReadBufferPLC) ;
static int StockeLigneAcc(char ** tpsz_ReadBufferGTA) ;
char   get_exclude_retrocomm_flag(char * trn_cd , int RAICOM_B, char * ACCTRN_NT  ) ;


//[14] Cette fonction sert uniquement au calcul des FUTURE Retro override
static int EcrireTGTAR_NEW(T_GTAR TGTAR[], int i, int a, int p);

static int b_IsRuptureGTRr(T_GTAR TGTAR[], int i, int j);
static char *sz_GetCurcvsnIndx(
  FILE* pf,           /* Discripteur du fichier des cours */
  char *sz_acpcur,    /* Cours d'origine */
  char c_ssd,         /* filiale */
  char *sz_retctr,    /* contrat */
  short s_rty,        /* Exercice */
  int   n_plc,        /* placement */
  char *pc_PlcTrouve  /* JR 28/04/03 */
);

double AfficheMontant(double mr);   

//[14] Nb_RETRO_OVER
int n_nbretrovirride = 0;

/*----------------------*/
/* variables de travail */
/*----------------------*/
T_PLAC   TPLAC[MAX_TPLAC];
T_ACC   TACC[MAX_TACC];

static FILE *Kp_GTAr;
static FILE *Kp_GTArMaj;
static FILE *Kp_GTRr;
static FILE *Kp_GTRrMaj;

static FILE *Kp_CurcvsnIndx;
static FILE *Kp_Curquot;

static T_RUPTURE_VAR   Kbd_RuptGTA;
static T_RUPTURE_SYNC_VAR  Kbd_RuptPLC;

static int Kn_TACC;
static int Kn_TPLAC;

static int Kb_TACCDepass;
static int Kb_TPLACDepass;

static BOOL Kb_ReturnStatus = 0; /* statut de retour du programme */
static BOOL Kb_GTA_COLS;  // Si GTA colonnes à 71

static int Kn_GTR;
static int Kn_GTE;
static int Kn_AnneeCours;
static int Kn_PRS;
//14
static int Kn_OVERRIDE = 1 ; //On ne traite pas les OVERRIDES

static double Kd_TauxAccept;

long double delta1 = 0, delta2 = 0, delta3 = 0, delta4 = 0 ;
struct  timespec ts1, ts2;
char Ksz_retrocomm_option[2] ;
// [006] Impact Retro
T_TRSLNK * pTrslnk ;  // pointeur sur un tableau de structure
static long nbTrslnk;  // nombre d'élément du tableau
int n_ChargementTrslnkRetro(int prs) ;
int RecherchePosteFromTRSLNK( char * trncode, int basis);

extern int Ksz_Argc ;

/**************************************************************
** Objet  : chargement FCURCVSNBIS
** Entree : ESTC2304_I5
*/
T_RUPTURE_VAR Kbd_ruptFCURCVSNBIS;
int n_InitFCURCVSNBIS(T_RUPTURE_VAR  *pbd_Rupt);
int n_ActionLigneFCURCVSNBIS(char **ptb_InRec_Cur);

/* Pour le chargement dans un tableau
du fichier des plc en dev specifiques */
typedef struct {
  short     SSD_CF;
//char      RETCTR_NF[9];
  char *    RETCTR_NF;
  short     RTY_NF;
  int       PLC_NT;
} T_CURCVSNBIS;

#define Kn_MaxLigFCURCVSNBIS 10000  /* nombre maxi de lignes de bret..tcurcvsn */
#define CURCVSNBIS_SSD_CF     0
#define CURCVSNBIS_RETCTR_NF  1
#define CURCVSNBIS_RTY_NF     2
#define CURCVSNBIS_PLC_NT     3

int  Kn_FCURCVSNBIS = 0; /* Nombre de lignes du tableau Ktbd_FEUROCUR */

T_CURCVSNBIS Ktbd_FCURCVSNBIS[Kn_MaxLigFCURCVSNBIS];

/*==============================================================================
objet :
   point d'entre du programme

retour :
   En cas de problme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc, char *argv[])
{

  /* Initialisation des signaux */
  InitSig () ;
  
  		if ( n_BeginPgm (argc , argv) == ERR )
    		ExitPgm ( ERR_XX, "" );
  
  /* Stockage des parametres du programme */
  Kn_GTR = n_GetIntArgv(1);
  Kn_AnneeCours = n_GetIntArgv(2);
  Kn_GTE = n_GetIntArgv(3);
  Kn_PRS = n_GetIntArgv(4);
  Kn_OVERRIDE = n_GetIntArgv(5);
  strcpy( Ksz_retrocomm_option, psz_GetCharArgv( 6 ) ) ;

  printf("Running with %s \n", VERSION_ESTC2304_C );  
  printf("\nNB_ARGUMENT Ksz_Argc %d  ; Kn_OVERRIDE (%d) ; retrocomm_opt= (%s) \n", Ksz_Argc, Kn_OVERRIDE, Ksz_retrocomm_option );   


  // Chargement des données TRSLNK dans le tableau de structure pTrslnk
  if (n_ChargementTrslnkRetro(Kn_PRS)) ExitPgm(ERR_XX, "erreur dans ChargementTrslnkRetro") ;

  //#ifdef DBG_MODE 

	printf("RETCTR_NF:CTR_NF:TRNCOD: BASIS_NT : OVERBASIS : AMT : RETAMT: FIXCOM : OVRCOM_R: OVRCOMAMT : RETCOMANT: RETOVRECOMANT\n");
  //#endif 
  /* Chargement des donnees de curcvsnbis */
  /* Initialisation des variables de gestion de ruptures */
  if (n_InitFCURCVSNBIS(&Kbd_ruptFCURCVSNBIS)) ExitPgm(ERR_XX, "");
  /* Lancement du traitement du fichier Maitre */
  if (n_ProcessingRuptureVar(&Kbd_ruptFCURCVSNBIS) == ERR) ExitPgm(ERR_XX, "");
  /* Fermeture des fichiers ouverts */
  if (n_CloseFileAppl("ESTC2304_I5", &(Kbd_ruptFCURCVSNBIS.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");

  if ( n_OpenFileAppl ("ESTC2304_O1", "wt", &Kp_GTAr) == ERR )
    ExitPgm ( ERR_XX, "" );

  if ( n_OpenFileAppl ("ESTC2304_O2", "wt", &Kp_GTArMaj) == ERR )
    ExitPgm ( ERR_XX, "" );

  /* les fichiers GTR et GTRMaj sont ouverts seulement si */
  /* l'option "generation GTR" est a 'oui' (1) */
  if (Kn_GTR == 1)
  {
    if ( n_OpenFileAppl ("ESTC2304_O3", "wt", &Kp_GTRr) == ERR )
      ExitPgm ( ERR_XX, "" );

    if ( n_OpenFileAppl ("ESTC2304_O4", "wt", &Kp_GTRrMaj) == ERR )
      ExitPgm ( ERR_XX, "" );
  }

  if ( n_OpenFileAppl ("ESTC2304_I3", "rb", &Kp_CurcvsnIndx) == ERR )
    ExitPgm ( ERR_XX, "" );

  if ( n_OpenFileAppl ("ESTC2304_I4", "rb", &Kp_Curquot) == ERR )
    ExitPgm ( ERR_XX, "" );


  /* Initialisation de la variable Kbd_RuptGTA  */
  if ( n_InitGTA(&Kbd_RuptGTA) == ERR )
    ExitPgm ( ERR_XX, "" );

  /* Initialisation de la varible Kbd_RuptPLC */
  if ( n_InitPLC(&Kbd_RuptPLC) == ERR )
    ExitPgm ( ERR_XX, "" );

  /* lancement du traitement du fichier maitre */
  if ( n_ProcessingRuptureVar(&Kbd_RuptGTA) == ERR )
    ExitPgm ( ERR_XX, "" );

  if ( n_CloseFileAppl ("ESTC2304_O1", &Kp_GTAr) == ERR )
    ExitPgm ( ERR_XX, "" );

  if ( n_CloseFileAppl ("ESTC2304_O2", &Kp_GTArMaj) == ERR )
    ExitPgm ( ERR_XX, "" );

  /* les fichiers GTR et GTRMaj sont presents seulement si */
  /* l'option "generation GTR" est a 'oui' (1) */
  if (Kn_GTR == 1)
  {
    if ( n_CloseFileAppl ("ESTC2304_O3", &Kp_GTRr) == ERR )
      ExitPgm ( ERR_XX, "" );

    if ( n_CloseFileAppl ("ESTC2304_O4", &Kp_GTRrMaj) == ERR )
      ExitPgm ( ERR_XX, "" );
  }

  if ( n_CloseFileAppl ("ESTC2304_I3", &Kp_CurcvsnIndx) == ERR )
    ExitPgm ( ERR_XX, "" );

  if ( n_CloseFileAppl ("ESTC2304_I4", &Kp_Curquot) == ERR )
    ExitPgm ( ERR_XX, "" );


  if ( n_CloseFileAppl ("ESTC2304_I1", &(Kbd_RuptGTA.pf_InputFil)) == ERR )
    ExitPgm ( ERR_XX, "" );

  if ( n_CloseFileAppl ("ESTC2304_I2", &(Kbd_RuptPLC.pf_InputFil)) == ERR )
    ExitPgm ( ERR_XX, "" );


  // on nettoie un peu avant de sortir...
  free(pTrslnk);
  pTrslnk = NULL;

  if ( n_EndPgm () == ERR )
    ExitPgm ( ERR_XX, "" );

  //exit(Kb_ReturnStatus) ; -=Dch=-
  exit(0);
}


/*==============================================================================
objet :
    fonction d'initialisation de la variable de gestion de rupture du fichier
    maitre.

retour :
  0K ---> traitement correctement effectue
  ERR ---> probleme a l'ouverture du fichier d'entree
==============================================================================*/
static int n_InitGTA(T_RUPTURE_VAR  *pbd_RuptGTA)
{
  DEBUT_FCT ("n_InitGTA") ;

  memset(pbd_RuptGTA, 0, sizeof(T_RUPTURE_VAR));

  if ( n_OpenFileAppl ("ESTC2304_I1", "rt", &(pbd_RuptGTA->pf_InputFil)) == ERR)
    RETURN_VAL( ERR );

  pbd_RuptGTA->n_NbRupture = 2;
  pbd_RuptGTA->n_ActionLigne     = n_ActionLigneGTA;

  pbd_RuptGTA->n_ConditionRupture[0] = n_ConditionRupture1;
  pbd_RuptGTA->n_ActionFirst[0] = n_ActionFirst1;

  pbd_RuptGTA->n_ConditionRupture[1] = n_ConditionRupture2;
  pbd_RuptGTA->n_ActionFirst[1] = n_ActionFirst2;
  pbd_RuptGTA->n_ActionLast[1] = n_ActionLast2;

  pbd_RuptGTA->c_Separ = SEPARATEUR;

  RETURN_VAL( OK );
}

/*==============================================================================
objet :
Test de rupture sur RETCTR_NF/RETEND_NT/RETSEC_NF/RTY_NF/RETUW_NT
        pour le fichier pere (GTAr100%)

retour :
  0 ---> pas de rupture
  1 ---> rupture
==============================================================================*/
static int n_ConditionRupture1(char ** tpsz_ReadBufferGTA,
                               char ** tpsz_ReadBufferGTA_Cur)
{

  DEBUT_FCT ("n_ConditionRupture1") ;

  if (strcmp(tpsz_ReadBufferGTA[GT_RETCTR_NF], tpsz_ReadBufferGTA_Cur[GT_RETCTR_NF]) != 0)
    RETURN_VAL(1);

  if (strcmp(tpsz_ReadBufferGTA[GT_RETEND_NT], tpsz_ReadBufferGTA_Cur[GT_RETEND_NT]) != 0)
    RETURN_VAL(1);

  if (strcmp(tpsz_ReadBufferGTA[GT_RETSEC_NF], tpsz_ReadBufferGTA_Cur[GT_RETSEC_NF]) != 0)
    RETURN_VAL(1);

  if (strcmp(tpsz_ReadBufferGTA[GT_RTY_NF], tpsz_ReadBufferGTA_Cur[GT_RTY_NF]) != 0)
    RETURN_VAL(1);

  if (strcmp(tpsz_ReadBufferGTA[GT_RETUW_NT], tpsz_ReadBufferGTA_Cur[GT_RETUW_NT]) != 0)
    RETURN_VAL(1);
    
//[14] Ajout Rupture sur PLC pour Future Retro OVERRIDE
  if (Kn_OVERRIDE == 2)
  { 
  	//[15]if (strcmp(tpsz_ReadBufferGTA[GT_PLC_NT], tpsz_ReadBufferGTA_Cur[GT_PLC_NT]) != 0)
  	
  	if (atoi(tpsz_ReadBufferGTA[GT_PLC_NT]) - atoi(tpsz_ReadBufferGTA_Cur[GT_PLC_NT]) != 0)
    	RETURN_VAL(1);    
  }     

  RETURN_VAL(0);
}

/*==============================================================================
objet :
Test de rupture sur RETCTR_NF/RETEND_NT/RETSEC_NF/RTY_NF/RETUW_NT/TRNCOD_CF/CUR_CF
        pour le fichier pere (GTAr100%)

retour :
  0 ---> pas de rupture
  1 ---> rupture
==============================================================================*/
static int n_ConditionRupture2(char ** tpsz_ReadBufferGTA,
                               char ** tpsz_ReadBufferGTA_Cur)
{
  DEBUT_FCT ("n_ConditionRupture2") ;

/*
  printf("n_ConditionRupture2: RETCTR:%s -RETENT:%s -RETSEC:%s -RTY:%s -RETUW:%s -CUR_CF:%s\n",
  tpsz_ReadBufferGTA[GT_RETCTR_NF],
  tpsz_ReadBufferGTA[GT_RETEND_NT],
  tpsz_ReadBufferGTA[GT_RETSEC_NF],
  tpsz_ReadBufferGTA[GT_RTY_NF],
  tpsz_ReadBufferGTA[GT_RETUW_NT],
  tpsz_ReadBufferGTA[GT_CUR_CF]);
*/

  if (strcmp(tpsz_ReadBufferGTA[GT_RETCTR_NF], tpsz_ReadBufferGTA_Cur[GT_RETCTR_NF]) != 0)
    RETURN_VAL(1);

  if (strcmp(tpsz_ReadBufferGTA[GT_RETEND_NT], tpsz_ReadBufferGTA_Cur[GT_RETEND_NT]) != 0)
    RETURN_VAL(1);

  if (strcmp(tpsz_ReadBufferGTA[GT_RETSEC_NF], tpsz_ReadBufferGTA_Cur[GT_RETSEC_NF]) != 0)
    RETURN_VAL(1);

  if (strcmp(tpsz_ReadBufferGTA[GT_RTY_NF], tpsz_ReadBufferGTA_Cur[GT_RTY_NF]) != 0)
    RETURN_VAL(1);

  if (strcmp(tpsz_ReadBufferGTA[GT_RETUW_NT], tpsz_ReadBufferGTA_Cur[GT_RETUW_NT]) != 0)
    RETURN_VAL(1);
    
//[14] Ajout Rupture sur PLC pour Future Retro OVERRIDE
  if (Kn_OVERRIDE == 2)
  { 
  	//[15] if (strcmp(tpsz_ReadBufferGTA[GT_PLC_NT], tpsz_ReadBufferGTA_Cur[GT_PLC_NT]) != 0)
  	if (atoi(tpsz_ReadBufferGTA[GT_PLC_NT]) - atoi(tpsz_ReadBufferGTA_Cur[GT_PLC_NT]) != 0)  		
    	RETURN_VAL(1);    
  }     

  if (strcmp(tpsz_ReadBufferGTA[GT_TRNCOD_CF], tpsz_ReadBufferGTA_Cur[GT_TRNCOD_CF]) != 0)
    RETURN_VAL(1);

  if (strcmp(tpsz_ReadBufferGTA[GT_CUR_CF], tpsz_ReadBufferGTA_Cur[GT_CUR_CF]) != 0)
    RETURN_VAL(1);

// [07]
  if ( tpsz_ReadBufferGTA[GT_NEWCOLS9_NF] != 0 )
  {
  		if (strcmp(tpsz_ReadBufferGTA[GT_TRN_NT], tpsz_ReadBufferGTA_Cur[GT_TRN_NT]) != 0)
  			RETURN_VAL(1);

  		if (strcmp(tpsz_ReadBufferGTA[GT_RETROAUTO_B], tpsz_ReadBufferGTA_Cur[GT_RETROAUTO_B]) != 0)
  			RETURN_VAL(1);
  }

  RETURN_VAL(0);
}

/*==============================================================================
objet :
  Fonction lancee en rupture premiere sur casex retro
        pour le fichier GTAr100%

retour :
  OK --->
  ERR --->
==============================================================================*/
static int n_ActionFirst1(char ** tpsz_ReadBufferGTA)
{
  /* initialiser TPLAC */
  DEBUT_FCT ("n_ActionFirst1") ;

  Kn_TPLAC = 0;
  Kb_TPLACDepass = 0;
  memset(TPLAC, 0, MAX_TPLAC * sizeof(T_PLAC));
  memset(TACC, 0, MAX_TACC * sizeof(T_ACC));

  /* lancement de la synchro */
  if ( n_ProcessingRuptureSyncVar(&Kbd_RuptPLC, tpsz_ReadBufferGTA) == ERR)
    RETURN_VAL (ERR );

  RETURN_VAL(OK);
}

/*==============================================================================
objet :
  Fonction lancee en rupture premiere sur casex retro/poste/monnaie
        pour le fichier GTAr100%

retour :
  OK --->
  ERR --->
==============================================================================*/
static int n_ActionFirst2(char ** tpsz_ReadBufferGTA)
{
  DEBUT_FCT ("n_ActionFirst2") ;

  if (Kb_TPLACDepass == 0)
  {
    Kn_TACC = 0;
    Kb_TACCDepass = 0;
    Kd_TauxAccept = d_GetTaux(Kp_Curquot,
                              (unsigned char) atoi(tpsz_ReadBufferGTA[GT_SSD_CF]),
                              (short) Kn_AnneeCours,
                              tpsz_ReadBufferGTA[GT_CUR_CF],
                              NULL);

  }
  if ( TACC[Kn_TACC].CUR_CF != 0)
    TACC[Kn_TACC].TAUXACCEPT_R = d_GetTaux(Kp_Curquot, TACC[Kn_TACC].SSD_CF,
                                           (short) Kn_AnneeCours,
                                           TACC[Kn_TACC].CUR_CF, NULL);

  RETURN_VAL(OK);
}

/*==============================================================================
objet :
  Initialisation de la synchronisation du maitre avec l'esclave

retour :
  OK ---> traitement correctement effectue
  ERR ---> probleme a l'ouverture du fichier d'entree
==============================================================================*/
static int n_InitPLC(T_RUPTURE_SYNC_VAR  *pbd_RuptPLC)
{
  DEBUT_FCT ("n_InitPLC") ;

  memset( pbd_RuptPLC, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;

  /* ouverture du fichier esclave */
  if (n_OpenFileAppl ("ESTC2304_I2", "rt", &(pbd_RuptPLC->pf_InputFil)) == ERR)
    RETURN_VAL( ERR );

  pbd_RuptPLC->n_NbRupture = 0;

  /* fonction du test de la ligne du maitre avec l'esclave */
  pbd_RuptPLC->ConditionEndSync = n_ConditionSync;

  /* fonction d'action sur la ligne courante du fichier esclave */
  pbd_RuptPLC->n_ActionLigne    = n_ActionLignePLC;

  pbd_RuptPLC->c_Separ = '~';

  RETURN_VAL(OK) ;
}

/*==============================================================================
objet :
  fonction lancee pour chaque ligne du fichier fils
        qui synchronise

retour :
  OK ---> traitement correctement effectue
  ERR --> probleme rencontre
==============================================================================*/
static int n_ActionLignePLC(
  char *tpsz_ReadBufferGTA[],
  char *tpsz_ReadBufferPLC[]
)
{
  char MsgAno[300];
  DEBUT_FCT ("n_ActionLignePLC") ;

  if (Kb_TPLACDepass == 0)
  {
    if (Kn_TPLAC < MAX_TPLAC)
    {
      StockeLignePlac(tpsz_ReadBufferPLC);
      Kn_TPLAC++;
    }
    else
    {
      sprintf(MsgAno, "The number of records in PLACEMENT file for contract (/RETCTR %s /RETEND %s /RETSEC %s /RTY %s /RETUW %s) overflows the program's storage capacity\n",
              tpsz_ReadBufferPLC[PLA_RETCTR_NF],
              tpsz_ReadBufferPLC[PLA_RETEND_NT],
              tpsz_ReadBufferPLC[PLA_RETSEC_NF],
              tpsz_ReadBufferPLC[PLA_RTY_NF],
              tpsz_ReadBufferPLC[PLA_RETUW_NT]);

      n_WriteAno(MsgAno);
      Kb_TPLACDepass = 1;
      Kb_ReturnStatus = 1;
    }
  }

  RETURN_VAL(OK);
}

/*==============================================================================
objet :
  fonction de test de synchronisation

retour :
  0       ---> pbd_InRecOwner = pbd_InRecChild
  > 0     ---> pbd_InRecOwner > pbd_InRecChild
  < 0     ---> pbd_InRecOwner < pbd_InRecChild
==============================================================================*/
static int n_ConditionSync(
  char *tpsz_ReadBufferGTA[],   /* adresse de la ligne du maitre */
  char *tpsz_ReadBufferPLC[]     /* adresse de la ligne de l'esclave */
)
{
  int ret ;
  DEBUT_FCT("n_ConditionSync");

  if ((ret = strcmp(tpsz_ReadBufferGTA[GT_RETCTR_NF], tpsz_ReadBufferPLC[PLA_RETCTR_NF])) != 0)
    RETURN_VAL (ret);

  if ((ret = strcmp(tpsz_ReadBufferGTA[GT_RETEND_NT], tpsz_ReadBufferPLC[PLA_RETEND_NT])) != 0)
    RETURN_VAL (ret);

  if ((ret = strcmp(tpsz_ReadBufferGTA[GT_RETSEC_NF], tpsz_ReadBufferPLC[PLA_RETSEC_NF])) != 0)
    RETURN_VAL (ret);

  if ((ret = strcmp(tpsz_ReadBufferGTA[GT_RTY_NF], tpsz_ReadBufferPLC[PLA_RTY_NF])) != 0)
    RETURN_VAL (ret);

  if ((ret = strcmp(tpsz_ReadBufferGTA[GT_RETUW_NT], tpsz_ReadBufferPLC[PLA_RETUW_NT])) != 0)
    RETURN_VAL (ret);
    
//[14] Ajout Rupture sur PLC pour Future Retro OVERRIDE
  if (Kn_OVERRIDE == 2)
  {    
  //[15] if ((ret = strcmp(tpsz_ReadBufferGTA[GT_PLC_NT], tpsz_ReadBufferPLC[PLA_PLC_NT])) != 0)
  if ((ret = atoi(tpsz_ReadBufferGTA[GT_PLC_NT])- atoi(tpsz_ReadBufferPLC[PLA_PLC_NT])) != 0)  	
    RETURN_VAL (ret);    

  }    

  RETURN_VAL(0);
}

/*--------------------------------------------------------------------------*/
/* Fonction de traitement de chaque enregistrement pere                     */
/*--------------------------------------------------------------------------*/
static int  n_ActionLigneGTA(char *tpsz_ReadBufferGTA[])
{
  char MsgAno[300];
  DEBUT_FCT ("n_ActionLigneGTA") ;

  if ( (Kb_TPLACDepass == 0) && (Kb_TACCDepass == 0) )
  {
    if (Kn_TACC < MAX_TACC)
    {
      StockeLigneAcc(tpsz_ReadBufferGTA) ;
      Kn_TACC ++;
    }
    else
    {
      sprintf(MsgAno, "The number of records in GT file for (/RETCTR %s /RETEND %s /RETSEC %s /RTY %s /RETUW %s /TRNCOD %s /CUR %s) overflows the program's storage capacity\n",
              tpsz_ReadBufferGTA[GT_RETCTR_NF],
              tpsz_ReadBufferGTA[GT_RETEND_NT],
              tpsz_ReadBufferGTA[GT_RETSEC_NF],
              tpsz_ReadBufferGTA[GT_RTY_NF],
              tpsz_ReadBufferGTA[GT_RETUW_NT],
              tpsz_ReadBufferGTA[GT_TRNCOD_CF],
              tpsz_ReadBufferGTA[GT_CUR_CF]);
      n_WriteAno(MsgAno);
      Kb_TACCDepass = 1;
      Kb_ReturnStatus = 1;
    }
  }
  RETURN_VAL(OK);
}


/*==============================================================================
objet : specific exclusion rule : retro overrider - retro commission , TC exclude

retour :
  OK ---> E for excluded , N for not excluded 
==============================================================================*/
char   get_exclude_retrocomm_flag(char * trn_cd , int RAICOM_B, char * ACCTRN_NT  ) 
{
	
            if (  (     strcmp(Ksz_retrocomm_option,"Y") == 0 
			         || ( strcmp(Ksz_retrocomm_option,"A") == 0  )
			      )
			    && RAICOM_B == 0 
                && ( 
                      ( strncmp(&trn_cd[2],"12",2) == 0 
					    && strncmp(&trn_cd[2],"12110",5) != 0 && strncmp(&trn_cd[2],"12120",5) != 0 
					    && strncmp(&trn_cd[2],"12128",5) != 0 && strncmp(&trn_cd[2],"12161",5) != 0 && strncmp(&trn_cd[2],"12121",5) != 0 
					  ) 
                    || strncmp(&trn_cd[2],"13",2) == 0 
                    || strncmp(&trn_cd[2],"14",2) == 0 
                    || strncmp(&trn_cd[2],"15",2) == 0 
                    || strncmp(&trn_cd[2],"31",2) == 0 
                    || strncmp(&trn_cd[2],"43",2) == 0 						
                   )  
               )
            { 
               return 'E';
            }
            else
               return 'N';							
}	


/*==============================================================================
objet :
  Fonction lancee en rupture derniere pour le fichier GTAa

retour :
  OK --->
  ERR --->
==============================================================================*/
int n_ActionLast2(char ** tpsz_ReadBufferGTA)
{
  int p, a, i, j, k, i0, imin, imax, n_TGTAR ;
  char c_PlcTrouve = 0;      /* JR 28/04/03 */
  char c_Init_PlcTrouve = 0; /* JR 28/04/03 */
  double d_Ma = 0., d_MaS = 0., d_Mr = 0., d_MrS = 0., d_MriS = 0., d_MaSMaj = 0., d_MrSMaj = 0., d_MriSMaj = 0., d_MrCom = 0.;
  char sz_retcur[4];
  T_GTAR   *TGTAR = NULL;    
  char MsgAno[400];
  char sz_trncod[9];
  char sv_trncod[9];
  static char *p2;

  memset(sz_trncod, 0, sizeof(sz_trncod));
  memset(sv_trncod, 0, sizeof(sv_trncod));

  if ( TGTAR )  { free ( TGTAR ); TGTAR = NULL;}
    TGTAR = malloc(Kn_TPLAC * Kn_TACC * sizeof(T_GTAR)) ;

  if ( !TGTAR )
  {
    n_WriteAno("Erreur d'alloction memoire pour TGTAR ") ;
  }
	  
  DEBUT_FCT ("n_ActionLast2") ;

  if ( (Kb_TPLACDepass == 0) && (Kb_TACCDepass == 0) && (Kn_TPLAC != 0) )
  {
    /*------------------------------*/
    /* 1- Calcul des monnaies retro */
    /*------------------------------*/
    for (p = 0; p < Kn_TPLAC; p++)
    {
      if (TPLAC[p].ORICUR_B == 1)
      {
        /* la devise retrocession est identique a la devise originale */
        strcpy(TPLAC[p].RETCUR_CF, TACC[0].CUR_CF);
        TPLAC[p].PLCTROUVE = c_Init_PlcTrouve;
      }
      else
      {
        clock_gettime(0, &ts1);
        /* transformation de devise */
        p2 = sz_GetCurcvsnIndx( Kp_CurcvsnIndx,
                                TACC[0].CUR_CF,
                                TACC[0].SSD_CF,
                                TACC[0].RETCTR_NF,
                                TACC[0].RTY_NF,
                                TPLAC[p].PLC_NT,
                                &c_PlcTrouve);        /* JR 28/04/03 */
        if (p2 != NULL) // [003]
        {
          strcpy(TPLAC[p].RETCUR_CF, p2);
          TPLAC[p].PLCTROUVE = c_PlcTrouve;
        }

        /* Si on n'a pas trouve de placement, la fction retourne -1 */
        if ( n_RechCURCVSNBIS(TACC[0].RETCTR_NF, TACC[0].RTY_NF, TPLAC[p].PLC_NT)  == -1)
          TPLAC[p].PLCTROUVE = 0 ;
        else
          TPLAC[p].PLCTROUVE = 1 ;
        /* rq: si la devise retrocession n'a pas ete trouvee,     */
        /* la fonction renvoie chaine vide - cette eventualite    */
        /* est prise en compte dans la generation du tableau TGTAR    */
      }
      if (TPLAC[p].RETCUR_CF != 0 )
        TPLAC[p].TAUXRETRO_R = d_GetTaux(Kp_Curquot, TPLAC[p].SSD_CF, (short) Kn_AnneeCours, TPLAC[p].RETCUR_CF, NULL);
    }

    /*----------------------------------------------*/
    /* 2- Generation du tableau intermediaire TGTAR */
    /*----------------------------------------------*/
    i = -1; 
    for (p = 0; p < Kn_TPLAC; p++)
    {
      if (TPLAC[p].RETCUR_CF != 0)
      {
        for (a = 0; a < Kn_TACC; a++)
        {
          i = a * Kn_TPLAC + p;        

          if ( i  < MAX_TGTAR) // [14] MAX_TGTAR) //Kn_TPLAC * Kn_TACC          	
          {
          	
          		if  (Kn_OVERRIDE == 1 )
          		{ 
          		  if (EcrireTGTAR(TGTAR, i, a, p) == ERR)
          		  {
          		   if ( TGTAR )  { free ( TGTAR ); TGTAR = NULL;}
          		    RETURN_VAL( OK);
          		  }
          		}  
          		  /* la fonction EcrireTGTAR renvoie ERR si le cours */
          		  /* de change entre CUR et RETCUR n'a pas ete trouve */
          		  /* dans ce cas on n'ecrit pas en sortie pour la cle */
          		  /* courante */
          		  
          		else   //if (( Kn_OVERRIDE == 2) && (strcmp(TACC[a].TRNCOD_CF, TRNCOD_FUTUREVARI_PRM) == 0 ||  strcmp(TACC[a].TRNCOD_CF, TRNCOD_FUTUREFIXE_PRM) == 0) )
          		{ 
          		  if (EcrireTGTAR_NEW(TGTAR, i, a, p) == ERR)
          		  {
          		   if ( TGTAR )  { free ( TGTAR ); TGTAR = NULL;}
          		    RETURN_VAL( OK);
          		  }           	
          		}	            	          
          }
          else
          {
            sprintf(MsgAno, "The number of records for \n\tcontract (/CTR %s /END %d /SEC %d /UWY %d /UW %d) \n\tretro contract (/RETCTR %s /RETEND %d /RETSEC %d /RTY %d /RETUW %d) \n\ttransaction code TRNCOD %s \n\tcurrency code CUR %s\noverflows the program's storage capacity\n",
                    TACC[a].CTR_NF,
                    TACC[a].END_NT,
                    TACC[a].SEC_NF,
                    TACC[a].UWY_NF,
                    TACC[a].UW_NT,
                    TACC[a].RETCTR_NF,
                    TACC[a].RETEND_NT,
                    TACC[a].RETSEC_NF,
                    TACC[a].RTY_NF,
                    TACC[a].RETUW_NT,
                    TACC[a].TRNCOD_CF,
                    TACC[a].CUR_CF);
            n_WriteAno(MsgAno);
            Kb_ReturnStatus = 1;
            if ( TGTAR )  { free ( TGTAR ); TGTAR = NULL;}
            RETURN_VAL( OK);
          } /* fin "si i < MAX_TGTAR */
        } /* fin boucle sur TACC */
      }
      else
      {
        /* ecrire une ano : devise retro non trouvee */
        sprintf(MsgAno, "No retrocession currency could be found in reference table TCURCVSN for (CUR %s /SSD %d /RETCTR %s /RTY_NF %d /PLC_NT %d)\n",
                TACC[0].CUR_CF,
                TACC[0].SSD_CF,
                TACC[0].RETCTR_NF,
                TACC[0].RTY_NF,
                TPLAC[p].PLC_NT);

        n_WriteAno(MsgAno);
        Kb_ReturnStatus = 1;
        if ( TGTAR )  { free ( TGTAR ); TGTAR = NULL;}
        RETURN_VAL( OK);
      } /* fin si TPLAC[p].RETCUR_CF != "" */
    } /* fin boucle sur TPLAC */
     
    n_TGTAR = i;
    if ((n_TGTAR != -1) && (Kn_OVERRIDE == 1 )) // Que si 
    {
      /*----------------------------------------------*/
      /* 3- Cumul 1 : generation des GTAr             */
      /*----------------------------------------------*/
      imin = 0;
      imax = Kn_TPLAC - 1;
      for (a = 0; a < Kn_TACC; a++)
      {
        i0 = imin;
        for (p = 0; p < Kn_TPLAC; p++)
        {
          i = a * Kn_TPLAC + p;
          strcpy(sz_trncod, TGTAR[i].pa->TRNCOD_CF);
          
          if (TGTAR[i].RETCUR_B == 0)
          {
            i0 = i + 1;
            TGTAR[i].RETCUR_B = 1;
            strcpy(sz_retcur, TGTAR[i].pp->RETCUR_CF);
            d_Ma = TGTAR[i].AMT_M;
            d_Mr = TGTAR[i].RETAMT_M;
            strcpy(sv_trncod, TGTAR[i].pa->TRNCOD_CF);

            if ( get_exclude_retrocomm_flag(sv_trncod,TGTAR[i].RAICOM_B,TGTAR[i].pa->TRN_NT)  != 'E'  )
            {
                if  (TGTAR[i].pp->PLCTROUVE == 0)
                {
                  EcrireGT(Kp_GTAr, TGTAR[i], d_Ma, d_Mr, sv_trncod, 0, FIC_GTAR);  /* jr 28 04 03 sans placement */
                }
                else
                {
                    EcrireGT(Kp_GTAr, TGTAR[i], d_Ma, d_Mr, sv_trncod, 0, FIC_2GTAR);  /* jr 28 04 03 avec placement */
                }				 
            }

                 // ajout d'une nouvelle ligne de commission
                 if (TGTAR[i].COMAMT_M != 0 && TGTAR[i].RAICOM_B != 0  )
                 {
                   TGTAR[i].Iscom_B = 1;
                   d_Ma = TGTAR[i].COMAMT_M  ;
                   d_Mr = TGTAR[i].RETCOMAMT_M;
                   EcrireGT(Kp_GTAr, TGTAR[i], d_Ma, d_Mr, TRNCOD_COMMISSION_EST, 0, FIC_GTAR); // commission
                 }
			
            if (TGTAR[i].RAICOM_B == 0 )
            {
              d_MaS = TGTAR[i].OVRCOMAMT_M ;
              d_MrS = TGTAR[i].RETOVRCOMAMT_M;
              d_MriS = TGTAR[i].RETOVRCOMAMT_M;
              d_MaSMaj = 0.;
              d_MrSMaj = 0.;
              d_MriSMaj = 0.;
            }
            else
            {
              d_MaSMaj = TGTAR[i].OVRCOMAMT_M ;
              d_MrSMaj = TGTAR[i].RETOVRCOMAMT_M;
              d_MriSMaj = TGTAR[i].RETOVRCOMAMT_M;
              d_MaS = 0.;
              d_MrS = 0.;
              d_MriS = 0.;
            }

            /*   ajout JR 10/02/03 */
            if  (TGTAR[i].pp->SSDRTO_B == 0)
            {
              d_MriS = 0.;
              d_MriSMaj = 0.;
            }

            if (d_MaS != 0. && d_MrS != 0.)
            {
              /* modification du poste comptable */
              sz_trncod[1] = '1';
              sz_trncod[2] = '1';
              sz_trncod[3] = '2';
              sz_trncod[4] = '1';
              sz_trncod[5] = '1';
              sz_trncod[6] = '0';
              EcrireGT(Kp_GTAr, TGTAR[i], d_MaS, d_MrS,  sz_trncod, d_MriS, FIC_GTARP);
            }
            if (d_MaSMaj != 0. && d_MrSMaj != 0.)
            {
              /* modification du poste comptable */
              sz_trncod[1] = '1';
              sz_trncod[2] = '1';
              sz_trncod[3] = '2';
              sz_trncod[4] = '1';
              sz_trncod[5] = '1';
              sz_trncod[6] = '0';
              EcrireGT(Kp_GTArMaj, TGTAR[i], d_MaSMaj, d_MrSMaj, sz_trncod, d_MriSMaj, FIC_GTARP);
              /* fin    ajout JR 10/02/03 */
            }

            for (k = i0; k <= imax; k++)
            {
              j = a * Kn_TPLAC + k;
              if (strcmp(TGTAR[k].pp->RETCUR_CF, sz_retcur) == 0)
              {
                TGTAR[k].RETCUR_B = 1;
                d_Ma =  TGTAR[k].AMT_M;
                d_Mr =  TGTAR[k].RETAMT_M;
                strcpy(sv_trncod, TGTAR[k].pa->TRNCOD_CF);

            if ( get_exclude_retrocomm_flag(sv_trncod,TGTAR[k].RAICOM_B, TGTAR[k].pa->TRN_NT)  != 'E'  )
				{
                    if  (TGTAR[k].pp->PLCTROUVE == 0)
                    {
                        EcrireGT(Kp_GTAr, TGTAR[k], d_Ma, d_Mr, sv_trncod, 0, FIC_GTAR);  /* jr 28 04 03 sans placement */
                    }
                    else
                    {
                    EcrireGT(Kp_GTAr, TGTAR[k], d_Ma, d_Mr, sv_trncod, 0, FIC_2GTAR);  /* jr 28 04 03 avec placement */
                    }
                }
                if (TGTAR[k].RAICOM_B == 0 )
                {
                  /*   ajout JR 10/02/03 */
                  d_MaS = TGTAR[k].OVRCOMAMT_M ;
                  d_MrS = TGTAR[k].RETOVRCOMAMT_M;
                  d_MriS = TGTAR[k].RETOVRCOMAMT_M;
                  d_MaSMaj = 0.;
                  d_MrSMaj = 0.;
                  d_MriSMaj = 0.;
                }
                else
                {
                  d_MaSMaj = TGTAR[k].OVRCOMAMT_M ;
                  d_MrSMaj = TGTAR[k].RETOVRCOMAMT_M;
                  d_MriSMaj = TGTAR[k].RETOVRCOMAMT_M;
                  d_MaS = 0.;
                  d_MrS = 0.;
                  d_MriS = 0.;
                }


                if  (TGTAR[k].pp->SSDRTO_B == 0)
                {
                  d_MriS = 0.;
                  d_MriSMaj = 0.;
                }

                if (d_MaS != 0. && d_MrS != 0.)
                {
                  /* modification du poste comptable */
                  sz_trncod[1] = '1';
                  sz_trncod[2] = '1';
                  sz_trncod[3] = '2';
                  sz_trncod[4] = '1';
                  sz_trncod[5] = '1';
                  sz_trncod[6] = '0';
                  EcrireGT(Kp_GTAr, TGTAR[k], d_MaS, d_MrS, sz_trncod, d_MriS, FIC_GTARP);
                }
                if (d_MaSMaj != 0. && d_MrSMaj != 0.)
                {
                  /* modification du poste comptable */
                  sz_trncod[1] = '1';
                  sz_trncod[2] = '1';
                  sz_trncod[3] = '2';
                  sz_trncod[4] = '1';
                  sz_trncod[5] = '1';
                  sz_trncod[6] = '0';
                  EcrireGT(Kp_GTArMaj, TGTAR[k], d_MaSMaj, d_MrSMaj,  sz_trncod, d_MriSMaj, FIC_GTARP);
                  /* fin    ajout JR 10/02/03 */
                }
              } /* fin "if (strcmp(TGTAR[k].RETCUR_CF,sz_retcur) == 0)" */
            } /* fin "for (k=i0; k<= imax; k++)" */
          }  /* fin du "si TGTAR[].RETCUR_B=0" */
        }   /* fin de la boucle sur TPLAC */
        imin = imin + Kn_TPLAC;
        imax = imax + Kn_TPLAC;
      }  /* fin de la boucle sur TACC */

      /*----------------------------------------------*/
      /* 4- Cumul 2 : generation des GTRr             */
      /*----------------------------------------------*/
      if (Kn_GTR == 1)
      { /* on ne genere les gtrr que si le parametre option est a "oui" (1) */
        for (p = 0; p < Kn_TPLAC; p++)
        {
          d_Ma = 0.; // [12]
          d_Mr = 0.;
          d_MrS = 0.;
          d_MrCom = 0.; // [12]
          for (a = 0; a < Kn_TACC; a++)
          {
            i = a * Kn_TPLAC + p;
            if (TGTAR[i].Iscom_B == 1)
            {
              d_Ma = d_Ma + TGTAR[i].COMAMT_M; // [12]
              TGTAR[i].Iscom_B = 0;
              d_MrCom = d_MrCom + TGTAR[i].RETCOMAMT_M; // [12]
            }
            strcpy(sz_trncod, TGTAR[i].pa->TRNCOD_CF);
            d_Mr = d_Mr + TGTAR[i].RETAMT_M;
            d_MrS = d_MrS + TGTAR[i].RETOVRCOMAMT_M;

            if ( (a == Kn_TACC - 1) || (b_IsRuptureGTRr(TGTAR, i, i + Kn_TPLAC) == 1) )
            {

            if ( get_exclude_retrocomm_flag(sz_trncod,TGTAR[i].RAICOM_B,TGTAR[i].pa->TRN_NT)  != 'E'  )             
              {
                EcrireGTRr(Kp_GTRr, TGTAR[i], d_Mr, sz_trncod);
              }

                // le but ici est de reproduire le comportement obtenue dans le GTAR ligne 915-920 [12]
                if (d_Ma != 0 && TGTAR[i].RAICOM_B != 0 )
                {
                  EcrireGTRr(Kp_GTRr, TGTAR[i], d_MrCom, TRNCOD_COMMISSION_EST);	
                }	
			  
              // fin [12]
              if (d_MrS != 0.)
              {
                /* modification du poste comptable */
                sz_trncod[1] = '1';
                sz_trncod[2] = '1';
                sz_trncod[3] = '2';
                sz_trncod[4] = '1';
                sz_trncod[5] = '1';
                sz_trncod[6] = '0';
                EcrireGTRr((TGTAR[p].RAICOM_B == 0 ? Kp_GTRr : Kp_GTRrMaj), TGTAR[i], d_MrS, sz_trncod);
              }
              d_Ma = 0.; // [12]
              d_Mr = 0.;
              d_MrS = 0.;
              d_MrCom = 0.; // [12]
            } /* fin du if rupture */
          } /* fin de la boucle sur l'acceptation */
        } /* fin de la boucle sur TPLAC */
      } /* fin du if option=1 */
    } /* fin if n_TGTAR!=0 */
  }  /* fin "if ( (Kb_TPLACDepass == 0) && (Kb_TACCDepass ==0) )" */
  if ( TGTAR )  { free ( TGTAR ); TGTAR = NULL;} 	
  	
  RETURN_VAL(OK);
}

/*======================================================================
 Fonction qui teste la rupture sur RETOCCYEA_NF/RCL_NF/RETACY_NF/
                                   RETSCOSTRMTH_NF/RETSCOENDMTH_NF
 Retour : 1 si il y a rupture
          0 s'il n'y a pas rupture
=======================================================================*/
static int b_IsRuptureGTRr(T_GTAR TGTAR[], int i, int j)
{
  DEBUT_FCT ("b_IsRuptureGTRr") ;

  if ((atoi(TGTAR[i].pa->RETOCCYEA_NF) - atoi(TGTAR[j].pa->RETOCCYEA_NF)) != 0)
    RETURN_VAL(1);
  if ((atoi(TGTAR[i].pa->RCL_NF) - atoi(TGTAR[j].pa->RCL_NF)) != 0)
    RETURN_VAL(1);
  if ((TGTAR[i].pa->RETACY_NF - TGTAR[j].pa->RETACY_NF) != 0)
    RETURN_VAL(1);
  if ((TGTAR[i].pa->RETSCOSTRMTH_NF - TGTAR[j].pa->RETSCOSTRMTH_NF) != 0)
    RETURN_VAL(1);
  if ((TGTAR[i].pa->RETSCOENDMTH_NF - TGTAR[j].pa->RETSCOENDMTH_NF) != 0)
    RETURN_VAL(1);

  RETURN_VAL(0);
}

/*==================================================================
objet : Stocker une ligne du fichier GTaccepation 100% lu en entree
  dans le tableau TACC.
====================================================================*/
static int StockeLigneAcc(char ** tpsz_ReadBufferGTA)
{
  DEBUT_FCT ("StockeLigneAcc") ;

  TACC[Kn_TACC].SSD_CF = (unsigned char) atoi(tpsz_ReadBufferGTA[GT_SSD_CF]);
  TACC[Kn_TACC].ESB_CF = (unsigned char) atoi(tpsz_ReadBufferGTA[GT_ESB_CF]);
  TACC[Kn_TACC].BALSHEY_NF = (short) atoi(tpsz_ReadBufferGTA[GT_BALSHEY_NF]);
  TACC[Kn_TACC].BALSHRMTH_NF = (unsigned char) atoi(tpsz_ReadBufferGTA[GT_BALSHRMTH_NF]);
  TACC[Kn_TACC].BALSHRDAY_NF = (unsigned char) atoi(tpsz_ReadBufferGTA[GT_BALSHRDAY_NF]);
  strcpy(TACC[Kn_TACC].TRNCOD_CF, tpsz_ReadBufferGTA[GT_TRNCOD_CF]);
  strcpy(TACC[Kn_TACC].DBLTRNCOD_CF, tpsz_ReadBufferGTA[GT_DBLTRNCOD_CF]);
  strcpy(TACC[Kn_TACC].CTR_NF, tpsz_ReadBufferGTA[GT_CTR_NF]);
  TACC[Kn_TACC].END_NT = (unsigned char) atoi(tpsz_ReadBufferGTA[GT_END_NT]);
  TACC[Kn_TACC].SEC_NF = (unsigned char) atoi(tpsz_ReadBufferGTA[GT_SEC_NF]);
  TACC[Kn_TACC].UWY_NF = (short) atoi(tpsz_ReadBufferGTA[GT_UWY_NF]);
  TACC[Kn_TACC].UW_NT = (unsigned char) atoi(tpsz_ReadBufferGTA[GT_UW_NT]);
  strcpy(TACC[Kn_TACC].OCCYEA_NF, tpsz_ReadBufferGTA[GT_OCCYEA_NF]);
  TACC[Kn_TACC].ACY_NF = (short) atoi(tpsz_ReadBufferGTA[GT_ACY_NF]);
  TACC[Kn_TACC].SCOSTRMTH_NF = (unsigned char) atoi(tpsz_ReadBufferGTA[GT_SCOSTRMTH_NF]);
  TACC[Kn_TACC].SCOENDMTH_NF = (unsigned char) atoi(tpsz_ReadBufferGTA[GT_SCOENDMTH_NF]);
  strcpy(TACC[Kn_TACC].CLM_NF, tpsz_ReadBufferGTA[GT_CLM_NF]);
  strcpy(TACC[Kn_TACC].CUR_CF, tpsz_ReadBufferGTA[GT_CUR_CF]);
  TACC[Kn_TACC].AMT_M = atof(tpsz_ReadBufferGTA[GT_AMT_M]);
  TACC[Kn_TACC].CED_NF = atoi(tpsz_ReadBufferGTA[GT_CED_NF]);
  TACC[Kn_TACC].BRK_NF = atoi(tpsz_ReadBufferGTA[GT_BRK_NF]);
  TACC[Kn_TACC].PAY_NF = atoi(tpsz_ReadBufferGTA[GT_PAY_NF]);
  strcpy(TACC[Kn_TACC].KEY_NF, tpsz_ReadBufferGTA[GT_KEY_NF]);
  strcpy(TACC[Kn_TACC].RETCTR_NF, tpsz_ReadBufferGTA[GT_RETCTR_NF]);
  TACC[Kn_TACC].RETEND_NT = (unsigned char) atoi(tpsz_ReadBufferGTA[GT_RETEND_NT]);
  TACC[Kn_TACC].RETSEC_NF = (unsigned char) atoi(tpsz_ReadBufferGTA[GT_RETSEC_NF]);
  TACC[Kn_TACC].RTY_NF = (short) atoi(tpsz_ReadBufferGTA[GT_RTY_NF]);
  TACC[Kn_TACC].RETUW_NT = (unsigned char) atoi(tpsz_ReadBufferGTA[GT_RETUW_NT]);
  strcpy(TACC[Kn_TACC].RETOCCYEA_NF, tpsz_ReadBufferGTA[GT_RETOCCYEA_NF]);
  TACC[Kn_TACC].RETACY_NF = (short) atoi(tpsz_ReadBufferGTA[GT_RETACY_NF]);
  TACC[Kn_TACC].RETSCOSTRMTH_NF = (unsigned char) atoi(tpsz_ReadBufferGTA[GT_RETSCOSTRMTH_NF]);
  TACC[Kn_TACC].RETSCOENDMTH_NF = (unsigned char) atoi(tpsz_ReadBufferGTA[GT_RETSCOENDMTH_NF]);
  strcpy(TACC[Kn_TACC].RCL_NF, tpsz_ReadBufferGTA[GT_RCL_NF]);
  strcpy(TACC[Kn_TACC].RETCUR_CF, tpsz_ReadBufferGTA[GT_RETCUR_CF]);
  TACC[Kn_TACC].RETAMT_M = atof(tpsz_ReadBufferGTA[GT_RETAMT_M]);


  //si on a 71 colonnes on gère un format GT à 71 colonnes
  if ( tpsz_ReadBufferGTA[GT_NEWCOLS9_NF] != 0 )
  {
    Kb_GTA_COLS = 1;
    strcpy(TACC[Kn_TACC].TRN_NT, tpsz_ReadBufferGTA[GT_TRN_NT]);
    strcpy(TACC[Kn_TACC].ORICOD_LS, tpsz_ReadBufferGTA[GT_ORICOD_LS]);
    TACC[Kn_TACC].RETROAUTO_B[0] = tpsz_ReadBufferGTA[GT_RETROAUTO_B][0];
    TACC[Kn_TACC].SPEENTNAT_CT[0] = tpsz_ReadBufferGTA[GT_SPEENTNAT_CT][0];
    strcpy(TACC[Kn_TACC].EVT_NF, tpsz_ReadBufferGTA[GT_EVT_NF]);
    strcpy(TACC[Kn_TACC].REVT_NF, tpsz_ReadBufferGTA[GT_REVT_NF]);
    TACC[Kn_TACC].RETARDRETINT_B[0] = tpsz_ReadBufferGTA[GT_RETARDRETINT_B][0];
    strcpy(TACC[Kn_TACC].NEWCOLS1_NF, tpsz_ReadBufferGTA[GT_NEWCOLS1_NF]);
    strcpy(TACC[Kn_TACC].NEWCOLS2_NF, tpsz_ReadBufferGTA[GT_NEWCOLS2_NF]);
    strcpy(TACC[Kn_TACC].NEWCOLS3_NF, tpsz_ReadBufferGTA[GT_NEWCOLS3_NF]);
    strcpy(TACC[Kn_TACC].NEWCOLS4_NF, tpsz_ReadBufferGTA[GT_NEWCOLS4_NF]);
    strcpy(TACC[Kn_TACC].NEWCOLS5_NF, tpsz_ReadBufferGTA[GT_NEWCOLS5_NF]);
    strcpy(TACC[Kn_TACC].NEWCOLS6_NF, tpsz_ReadBufferGTA[GT_NEWCOLS6_NF]);
    strcpy(TACC[Kn_TACC].NEWCOLS7_NF, tpsz_ReadBufferGTA[GT_NEWCOLS7_NF]);
    strcpy(TACC[Kn_TACC].NEWCOLS8_NF, tpsz_ReadBufferGTA[GT_NEWCOLS8_NF]);
    strcpy(TACC[Kn_TACC].NEWCOLS9_NF, tpsz_ReadBufferGTA[GT_NEWCOLS9_NF]);
  }

  TACC[Kn_TACC].TAUXACCEPT_R = Kd_TauxAccept;

  if (Kn_GTE == 1) /* GT enrichi : 5 champs en plus */
  {
    TACC[Kn_TACC].ENTPERYEA_NF = (short) atoi(tpsz_ReadBufferGTA[GTES_ENTPERYEA_NF]);
    TACC[Kn_TACC].ENTPERMTH_NF = (short) atoi(tpsz_ReadBufferGTA[GTES_ENTPERMTH_NF]);
    TACC[Kn_TACC].VALPERYEA_NF = (short) atoi(tpsz_ReadBufferGTA[GTES_VALPERYEA_NF]);
    TACC[Kn_TACC].VALPERMTH_NF = (short) atoi(tpsz_ReadBufferGTA[GTES_VALPERMTH_NF]);
    strcpy(TACC[Kn_TACC].TRN_NT2, tpsz_ReadBufferGTA[GTES_TRN_NT2]); // [003]
    TACC[Kn_TACC].ACCTYP_NF = (short) atoi(tpsz_ReadBufferGTA[GTES_ACCTYP_NF]);
    TACC[Kn_TACC].BALSHEY_NF_PLUS = (short) atoi(tpsz_ReadBufferGTA[GTES_BALSHEY_NF_PLUS]);
    TACC[Kn_TACC].BALSHRMTH_NF_PLUS = (unsigned char) atoi(tpsz_ReadBufferGTA[GTES_BALSHRMTH_NF_PLUS]);
    TACC[Kn_TACC].BALSHRDAY_NF_PLUS = (unsigned char) atoi(tpsz_ReadBufferGTA[GTES_BALSHRDAY_NF_PLUS]);
    strcpy(TACC[Kn_TACC].COMMAC_LL, tpsz_ReadBufferGTA[GTES_COMMAC_LL]);
  }
  RETURN_VAL( OK );
}

/*==================================================================
objet : Stocker une ligne du fichier placements lu en entree
  dans le tableau TPLAC.
====================================================================*/
static int StockeLignePlac(char ** tpsz_ReadBufferPLC)
{
  DEBUT_FCT ("StockeLignePlac") ;
  TPLAC[Kn_TPLAC].SSD_CF = (unsigned char) atoi(tpsz_ReadBufferPLC[PLA_SSD_CF]);
  TPLAC[Kn_TPLAC].ESB_CF = (unsigned char) atoi(tpsz_ReadBufferPLC[PLA_ESB_CF]);
  strcpy(TPLAC[Kn_TPLAC].RETCTR_NF, tpsz_ReadBufferPLC[PLA_RETCTR_NF]);
  TPLAC[Kn_TPLAC].RETEND_NT = (unsigned char) atoi(tpsz_ReadBufferPLC[PLA_RETEND_NT]);
  TPLAC[Kn_TPLAC].RETSEC_NF = (unsigned char) atoi(tpsz_ReadBufferPLC[PLA_RETSEC_NF]);
  TPLAC[Kn_TPLAC].RTY_NF = (short) atoi(tpsz_ReadBufferPLC[PLA_RTY_NF]);
  TPLAC[Kn_TPLAC].RETUW_NT = (unsigned char) atoi(tpsz_ReadBufferPLC[PLA_RETUW_NT]);
  TPLAC[Kn_TPLAC].PLC_NT = atoi(tpsz_ReadBufferPLC[PLA_PLC_NT]);
  TPLAC[Kn_TPLAC].OVRCOM_R = atof(tpsz_ReadBufferPLC[PLA_OVRCOM_R]);
  TPLAC[Kn_TPLAC].RTO_NF = atoi(tpsz_ReadBufferPLC[PLA_RTO_NF]);
  TPLAC[Kn_TPLAC].INT_NF = atoi(tpsz_ReadBufferPLC[PLA_INT_NF]);
  TPLAC[Kn_TPLAC].PAY_NF = atoi(tpsz_ReadBufferPLC[PLA_PAY_NF]);
  strcpy(TPLAC[Kn_TPLAC].KEY_CF, tpsz_ReadBufferPLC[PLA_KEY_CF]);
  TPLAC[Kn_TPLAC].ORICUR_B = (unsigned char) atoi(tpsz_ReadBufferPLC[PLA_ORICUR_B]);
  TPLAC[Kn_TPLAC].SSDRTO_B = (unsigned char) atoi(tpsz_ReadBufferPLC[PLA_SSDRTO_B]);
  TPLAC[Kn_TPLAC].RETSIGSHA_R = atof(tpsz_ReadBufferPLC[PLA_RETSIGSHA_R]);
  strcpy(TPLAC[Kn_TPLAC].LOB_CF, tpsz_ReadBufferPLC[PLA_LOB_CF]);
  TPLAC[Kn_TPLAC].RAICOM_B = (unsigned char) atoi(tpsz_ReadBufferPLC[PLA_RAICOM_B]);
  TPLAC[Kn_TPLAC].RETOVRCOM_B = (unsigned char) atoi(tpsz_ReadBufferPLC[PLA_RETOVRCOM_B]);
  //Dch
  strcpy(TPLAC[Kn_TPLAC].RETCUR_CF, tpsz_ReadBufferPLC[PLA_CUR_CF]);

  TPLAC[Kn_TPLAC].RETCUR_CF[3] = '\0';
  // on commence par mettre les valeurs par defauts
  TPLAC[Kn_TPLAC].BASIS_NT = 100;
  TPLAC[Kn_TPLAC].OVERBASIS_NT = 1;
  TPLAC[Kn_TPLAC].FIXCOM_R = 1;

  if ( tpsz_ReadBufferPLC[PLA_BASIS_NT] != NULL)
    if (atoi (tpsz_ReadBufferPLC[PLA_BASIS_NT]) != 0)
      TPLAC[Kn_TPLAC].BASIS_NT = atoi(tpsz_ReadBufferPLC[PLA_BASIS_NT]);


  if (tpsz_ReadBufferPLC[PLA_OVRBASIS_NT] != NULL)
    if (atoi (tpsz_ReadBufferPLC[PLA_OVRBASIS_NT]) != 0)
      TPLAC[Kn_TPLAC].OVERBASIS_NT = atoi(tpsz_ReadBufferPLC[PLA_OVRBASIS_NT]);
 if (tpsz_ReadBufferPLC[PLA_FIXCOM_R] != NULL)
	  TPLAC[Kn_TPLAC].FIXCOM_R = atof(tpsz_ReadBufferPLC[PLA_FIXCOM_R]);

  RETURN_VAL(OK);
}


/*=============================================================
objet : Stocker une ligne au format GTARr dans le tableau TGTAR
        Les donnees proviennent du tableau des placements
  TPLAC et du tableau du GTacceptation100% TACC
===============================================================*/
static int EcrireTGTAR(T_GTAR TGTAR[], int i, int a, int p)
{
  char sz_poste[4], posteCom[6] ;
  double d_taux;
  char MsgAno[200];
  DEBUT_FCT ("EcrireTGTAR") ;
  int flagCalc = -1;

  sprintf(sz_poste, "%.3s", TACC[a].TRNCOD_CF + 1);
  sprintf(posteCom, "%.5s", TACC[a].TRNCOD_CF + 2);

  TGTAR[i].pa = &TACC[a];
  TGTAR[i].pp = &TPLAC[p];

  // initialisation des champs de com à zero
  TGTAR[i].COMAMT_M = 0.;
  TGTAR[i].RETCOMAMT_M = 0.;



  TGTAR[i].AMT_M = TACC[a].AMT_M * TPLAC[p].RETSIGSHA_R;

  if ( (TACC[a].TAUXACCEPT_R != -1) && (TPLAC[p].TAUXRETRO_R != -1) )
  {
    d_taux = TACC[a].TAUXACCEPT_R / TPLAC[p].TAUXRETRO_R;
  }
  else d_taux = -1;

  if (d_taux == -1)   /* cours de change non trouve */
  {
    /* ecrire une ano : cours de change non trouve */
    sprintf(MsgAno, "Exchange rate from %s to %s for subsidiary %d and year %d not found in reference table TCURQUOT\n",
            TACC[a].RETCUR_CF,
            TPLAC[p].RETCUR_CF,
            TACC[a].SSD_CF,
            Kn_AnneeCours);

    n_WriteAno(MsgAno);
    d_taux = 0 ;
  }

  // par défaut :
  TGTAR[i].RETAMT_M = TGTAR[i].AMT_M * d_taux;
  TGTAR[i].RETCUR_B = 0;
  TGTAR[i].Iscom_B = 0;

  if (strcmp(TACC[a].RETCTR_NF, "RN0000755") == 0 || strcmp(TACC[a].RETCTR_NF, "RN0000741") == 0  || strcmp(TACC[a].RETCTR_NF, "TR0030951") == 0)
	printf(" DANS AVANT CALCUL EcrireTGTAR indice i [%d] : %s : %s : %s : %d : %d : %f : %f : %f  : %f :%f : %f : %f : %f : %f\n",
			i,
			TPLAC[p].RETCTR_NF,
			TACC[a].CTR_NF,
			TACC[a].TRNCOD_CF,
			TPLAC[p].BASIS_NT,
			TPLAC[p].OVERBASIS_NT,
			TGTAR[i].AMT_M,
			TGTAR[i].COMAMT_M,
			TGTAR[i].RETAMT_M,
			TPLAC[p].FIXCOM_R,
			TPLAC[p].OVRCOM_R,
			TGTAR[i].OVRCOMAMT_M,
			TGTAR[i].RETCOMAMT_M,
			TGTAR[i].RETOVRCOMAMT_M,
			TPLAC[p].RETSIGSHA_R	); 



//===========================================================================
// COM
  flagCalc = RecherchePosteFromTRSLNK(TACC[a].TRNCOD_CF, TPLAC[p].BASIS_NT) ;

  if ( TPLAC[p].FIXCOM_R != 0.)
  {
    if (flagCalc != -1 )
  {
      TGTAR[i].COMAMT_M = TGTAR[i].AMT_M * TPLAC[p].FIXCOM_R  * (-1.)  ;
      TGTAR[i].RETCOMAMT_M = TGTAR[i].RETAMT_M * TPLAC[p].FIXCOM_R  * (-1.)  ;
    }
  }

//===========================================================================
// SURCOM
    TGTAR[i].OVRCOMAMT_M = 0. ;
    TGTAR[i].RETOVRCOMAMT_M = 0. ;
    
  #ifdef DBG_MODE
  if (strcmp(TACC[a].TRNCOD_CF, "2A100012") == 0 || strcmp(TACC[a].TRNCOD_CF, "2A100022") == 0 || strcmp(TACC[a].TRNCOD_CF, "2A120012") == 0 )
  { 

  if (strcmp(TACC[a].RETCTR_NF, "RN0000755") == 0 || strcmp(TACC[a].CTR_NF, "RN0000741") == 0  || strcmp(TACC[a].CTR_NF, "TR0030951") == 0)
	printf(" DANS EcrireTGTAR indice i [%d] : %s : %s : %s : %d : %d : %f : %f : %f  : %f :%f : %f : %f : %f\n",
			i,
			TPLAC[p].RETCTR_NF,
			TACC[a].CTR_NF,
			TACC[a].TRNCOD_CF,
			TPLAC[p].BASIS_NT,
			TPLAC[p].OVERBASIS_NT,
			TGTAR[i].AMT_M,
			TGTAR[i].COMAMT_M,
			TGTAR[i].RETAMT_M,
			TPLAC[p].FIXCOM_R,
			TPLAC[p].OVRCOM_R,
			TGTAR[i].OVRCOMAMT_M,
			TGTAR[i].RETCOMAMT_M,
			TGTAR[i].RETOVRCOMAMT_M	);
			
	if ( TPLAC[p].BASIS_NT == 5)
     if (strcmp(TACC[a].RETCTR_NF, "RN0000755") == 0 || strcmp(TACC[a].CTR_NF, "RN0000741") == 0  || strcmp(TACC[a].CTR_NF, "TR0030951") == 0)
		printf(" UN CAS BASIC DANS EcrireTGTAR indice i [%d] : %s : %s : %s : %d : %d : %f : %f : %f  : %f :%f : %f : %f : %f\n",
			i,
			TPLAC[p].RETCTR_NF,
			TACC[a].CTR_NF,
			TACC[a].TRNCOD_CF,
			TPLAC[p].BASIS_NT,
			TPLAC[p].OVERBASIS_NT,
			TGTAR[i].AMT_M,
			TGTAR[i].COMAMT_M,
			TGTAR[i].RETAMT_M,
			TPLAC[p].FIXCOM_R,
			TPLAC[p].OVRCOM_R,
			TGTAR[i].OVRCOMAMT_M,
			TGTAR[i].RETCOMAMT_M,
			TGTAR[i].RETOVRCOMAMT_M	);
	}
  #endif			

  if ( TPLAC[p].OVRCOM_R != 0.)
  {
    flagCalc = RecherchePosteFromTRSLNK(TACC[a].TRNCOD_CF, TPLAC[p].OVERBASIS_NT);
    if (flagCalc != -1)
    {
      TGTAR[i].RETOVRCOMAMT_M = TGTAR[i].RETAMT_M * TPLAC[p].OVRCOM_R * (-1.) ;
      TGTAR[i].OVRCOMAMT_M = TGTAR[i].AMT_M * TPLAC[p].OVRCOM_R * (-1.) ;
   

   	if ((RecherchePosteFromTRSLNK(TRNCOD_COMMISSION_CED, TPLAC[p].OVERBASIS_NT ) != -1) || (RecherchePosteFromTRSLNK(TRNCOD_COMMISSION_EST, TPLAC[p].OVERBASIS_NT ) != -1))
   	{
   		TGTAR[i].RETOVRCOMAMT_M += TGTAR[i].RETCOMAMT_M  * TPLAC[p].OVRCOM_R * (-1.);
	  	TGTAR[i].OVRCOMAMT_M += TGTAR[i].COMAMT_M * TPLAC[p].OVRCOM_R * (-1.)  ;
   	}
	 }
  }

  TGTAR[i].RAICOM_B = TPLAC[p].RAICOM_B;

  #ifdef DBG_MODE
  if (strcmp(TACC[a].RETCTR_NF, "RN0000755") == 0 || strcmp(TACC[a].CTR_NF, "RN0000741") == 0  || strcmp(TACC[a].CTR_NF, "TR0030951") == 0)  
	printf(" 00 EcrireTGTAR  indice i [%d] : %s : %s : %s : %d : %d : %f : %f : %f  : %f :%f : %f : %f : %f\n",
			i,
			TPLAC[p].RETCTR_NF,
			TACC[a].CTR_NF,
			TACC[a].TRNCOD_CF,
			TPLAC[p].BASIS_NT,
			TPLAC[p].OVERBASIS_NT,
			TGTAR[i].AMT_M,
			TGTAR[i].COMAMT_M,
			TGTAR[i].RETAMT_M,
			TPLAC[p].FIXCOM_R,
			TPLAC[p].OVRCOM_R,
			TGTAR[i].OVRCOMAMT_M,
			TGTAR[i].RETCOMAMT_M,
			TGTAR[i].RETOVRCOMAMT_M	);

  #endif

  RETURN_VAL(OK);
}

//[14] [16] [18]
/*=============================================================
objet : Stocker une ligne au format GTARr dans le tableau TGTAR
        Les donnees proviennent du tableau des placements
  TPLAC et du tableau du GTacceptation100% TACC POUR BASIS 5 ou BASIS 6
===============================================================*/
static int EcrireTGTAR_NEW(T_GTAR TGTAR[], int i, int a, int p)
{
  char sz_poste[4], posteCom[6] ;
  double d_taux;
  char MsgAno[200];
  DEBUT_FCT ("EcrireTGTAR_NEW") ;
  int flagCalc = -1;
  
  int n_BASIS_NT_5 = 5; // BASIC 5 en dur
  int n_BASIS_NT_6 = 6; // [16] BASIC 6 en dur

  sprintf(sz_poste, "%.3s", TACC[a].TRNCOD_CF + 1);
  sprintf(posteCom, "%.5s", TACC[a].TRNCOD_CF + 2);

  TGTAR[i].pa = &TACC[a];
  TGTAR[i].pp = &TPLAC[p];

  // initialisation des champs de com à zero
  TGTAR[i].COMAMT_M = 0.;
  TGTAR[i].RETCOMAMT_M = 0.;



  // if (( strcmp(TACC[a].CTR_NF, "RP0002429") == 0)	&& TACC[a].RTY_NF == 2022 )
  //	printf(" DANS EcrireTGTAR_NEW PREMIUM : i = %d ; p = %d ; TACC[a].RETCTR_NF = %s ;  TACC[a].RTY_NF = %d ; TACC[a].TRNCOD_CF = %s ; TPLAC[p].FIXCOM_R=%f ; TPLAC[p].RETSIGSHA_R %f ; d_taux %f ; TGTAR[i].AMT_M %f ; TGTAR[i].RETAMT_M %f \n", i, p, TACC[a].RETCTR_NF,  TACC[a].RTY_NF, TACC[a].TRNCOD_CF, TPLAC[p].FIXCOM_R, TPLAC[p].RETSIGSHA_R, d_taux, TGTAR[i].AMT_M, TGTAR[i].RETAMT_M);



  TGTAR[i].AMT_M = TACC[a].AMT_M * TPLAC[p].RETSIGSHA_R;

  if ( (TACC[a].TAUXACCEPT_R != -1) && (TPLAC[p].TAUXRETRO_R != -1) )
  {
    d_taux = TACC[a].TAUXACCEPT_R / TPLAC[p].TAUXRETRO_R;
  }
  else d_taux = -1;

  if (d_taux == -1)   /* cours de change non trouve */
  {
    /* ecrire une ano : cours de change non trouve */
    sprintf(MsgAno, "Exchange rate from %s to %s for subsidiary %d and year %d not found in reference table TCURQUOT\n",
            TACC[a].RETCUR_CF,
            TPLAC[p].RETCUR_CF,
            TACC[a].SSD_CF,
            Kn_AnneeCours);

    n_WriteAno(MsgAno);
    d_taux = 0 ;
  }

  // par défaut :
  TGTAR[i].RETAMT_M = TGTAR[i].AMT_M * d_taux;
  TGTAR[i].RETCUR_B = 0;
  TGTAR[i].Iscom_B = 0;


//===========================================================================
// COM


 // if (strcmp(TACC[a].TRNCOD_CF, TRNCOD_FUTUREFIXE_PRM) == 0 || strcmp(TACC[a].TRNCOD_CF, TRNCOD_FUTUREVARI_PRM) == 0 ) 	
  { 

#ifdef DBG_MODE 
   if ((strcmp(TACC[a].RETCTR_NF, "RP0002429") == 0 || strcmp(TACC[a].CTR_NF, "RP0002429") == 0)	&& TACC[a].RTY_NF == 2022)
  //if ((strcmp(TACC[a].RETCTR_NF, "RP0000709") == 0 && TACC[a].RTY_NF == 2019 && TACC[a].RETSEC_NF == 6) ) 
  	printf(" DANS EcrireTGTAR_NEW PREMIUM : TACC[a].RETCTR_NF = %s ;  TACC[a].RTY_NF = %d ; TACC[a].TRNCOD_CF = %s ; TPLAC[p].FIXCOM_R=%f ; TPLAC[p].RETSIGSHA_R %f ; d_taux %f ; TGTAR[i].AMT_M %f ; TGTAR[i].RETAMT_M %f ; TPLAC[p].PLC_NT %d ; TPLAC[p].OVERBASIS_NT = %d\n", TACC[a].RETCTR_NF,  TACC[a].RTY_NF, TACC[a].TRNCOD_CF, TPLAC[p].FIXCOM_R, TPLAC[p].RETSIGSHA_R, d_taux, TGTAR[i].AMT_M, TGTAR[i].RETAMT_M, TPLAC[p].PLC_NT, TPLAC[p].OVERBASIS_NT);
#endif
  	

// [16] Si OVERBASIS_NT dans (2, 4) alors Recherche avec le nouveau Basis_NT_6 Sinon Recherche Dans BASIS_NT_5 

  	if (TPLAC[p].OVERBASIS_NT == 2 || TPLAC[p].OVERBASIS_NT == 4)
  		flagCalc = RecherchePosteFromTRSLNK(TACC[a].TRNCOD_CF, n_BASIS_NT_6); 
  	else 
    	flagCalc = RecherchePosteFromTRSLNK(TACC[a].TRNCOD_CF, n_BASIS_NT_5); 
  //flagCalc = RecherchePosteFromTRSLNK(TACC[a].TRNCOD_CF, n_BASIS_NT_5) ;  

  if ( TPLAC[p].FIXCOM_R != 0.)
  {
    if (flagCalc != -1 )
  	{
      TGTAR[i].COMAMT_M = TGTAR[i].AMT_M * TPLAC[p].FIXCOM_R  * (-1.)  ;
      TGTAR[i].RETCOMAMT_M = TGTAR[i].RETAMT_M * TPLAC[p].FIXCOM_R  * (-1.)  ;
    }
    

  }

//===========================================================================
// SURCOM 

#ifdef DBG_MODE 
   if ((strcmp(TACC[a].RETCTR_NF, "RP0002429") == 0 || strcmp(TACC[a].RETCTR_NF, "RT0000003") == 0  || strcmp(TACC[a].CTR_NF, "RP0002429") == 0)	&& TACC[a].RTY_NF == 2022)
  	printf(" DANS  SURCOM EcrireTGTAR_NEW AVANT INIT : TACC[a].RETCTR_NF = %s ;  TACC[a].TRNCOD_CF = %s ; TGTAR[i].OVRCOMAMT_M = %f ; TGTAR[i].RETOVRCOMAMT_M =%f; TPLAC[p].RETSIGSHA_R %f ; TPLAC[p].PLC_NT = %d \n", TACC[a].RETCTR_NF, TACC[a].TRNCOD_CF, TGTAR[i].OVRCOMAMT_M, TGTAR[i].RETOVRCOMAMT_M, TPLAC[p].RETSIGSHA_R, TPLAC[p].PLC_NT); 
#endif

    TGTAR[i].OVRCOMAMT_M = 0. ;
    TGTAR[i].RETOVRCOMAMT_M = 0. ;
    
  #ifdef DBG_MODE
  //if (strcmp(TACC[a].TRNCOD_CF, TRNCOD_FUTUREFIXE_PRM) == 0 || strcmp(TACC[a].TRNCOD_CF, TRNCOD_FUTUREVARI_PRM) == 0)
  {  	
   if ((strcmp(TACC[a].RETCTR_NF, "RP0002429") == 0 || strcmp(TACC[a].RETCTR_NF, "RT0000003") == 0  || strcmp(TACC[a].CTR_NF, "RP0002429") == 0)	&& TACC[a].RTY_NF == 2022)	
	printf(" DANS EcrireTGTAR_NEW indice i [%d] : %s : %s : %s : %d : %d : %f : %f : %f  : %f :%f : %f : %f : %f : %f : %d\n",
			i,
			TPLAC[p].RETCTR_NF,
			TACC[a].CTR_NF,
			TACC[a].TRNCOD_CF,
			n_BASIS_NT_5,
			TPLAC[p].OVERBASIS_NT,    //n_BASIS_NT_5
			TGTAR[i].AMT_M,
			TGTAR[i].COMAMT_M,
			TGTAR[i].RETAMT_M,
			TPLAC[p].FIXCOM_R,
			TPLAC[p].OVRCOM_R,
			TGTAR[i].OVRCOMAMT_M,
			TGTAR[i].RETCOMAMT_M,
			TGTAR[i].RETOVRCOMAMT_M,
			TPLAC[p].RETSIGSHA_R,
			TPLAC[p].PLC_NT);
			

	}
  #endif			

  if ( TPLAC[p].OVRCOM_R != 0.000) 
  { 
  	  	
  	
  #ifdef DBG_MODE
   if ((strcmp(TACC[a].RETCTR_NF, "RP0002429") == 0 || strcmp(TACC[a].RETCTR_NF, "RT0000003") == 0  || strcmp(TACC[a].CTR_NF, "RP0002429") == 0)	&& TACC[a].RTY_NF == 2022)
  //if ((strcmp(TACC[a].RETCTR_NF, "RP0000709") == 0 && TACC[a].RTY_NF == 2019 && TACC[a].RETSEC_NF == 6) )    	
		printf(" EXISTENCE OVRCOM EcrireTGTAR_NEW indice i [%d] : %s : %s : %s : %d : %d : %f : %f : %f  : %f :%f : %f : %f : %f : %f : %d \n",
		  i,
			TPLAC[p].RETCTR_NF,
			TACC[a].CTR_NF,
			TACC[a].TRNCOD_CF,
			n_BASIS_NT_5,
			TPLAC[p].OVERBASIS_NT,    //n_BASIS_NT_5
			TGTAR[i].AMT_M,
			TGTAR[i].COMAMT_M,
			TGTAR[i].RETAMT_M,
			TPLAC[p].FIXCOM_R,
			TPLAC[p].OVRCOM_R,
			TGTAR[i].OVRCOMAMT_M,
			TGTAR[i].RETCOMAMT_M,
			TGTAR[i].RETOVRCOMAMT_M,
			TPLAC[p].RETSIGSHA_R,
			TPLAC[p].PLC_NT);  
	#endif	
  	
  	if (TPLAC[p].OVERBASIS_NT == 2 || TPLAC[p].OVERBASIS_NT == 4)
  		flagCalc = RecherchePosteFromTRSLNK(TACC[a].TRNCOD_CF, n_BASIS_NT_6); 
  	else 
    	flagCalc = RecherchePosteFromTRSLNK(TACC[a].TRNCOD_CF, n_BASIS_NT_5); 

  #ifdef DBG_MODE    	
   if ((strcmp(TACC[a].RETCTR_NF, "RP0002429") == 0 )	&& TACC[a].RTY_NF == 2022)
   		printf(" RESULTAT indice  : i ; TGTAR[i].RAICOM_B ; TPLAC[p].RETCTR_NF ; TACC[a].CTR_NF ; TGTAR[i].RETOVRCOMAMT_M  ; TGTAR[i].OVRCOMAMT_M ; TPLAC[p].OVERBASIS_NT : %d ; %d ; %s ; %s ;  %d; %f; %f ; %f ; flagCalc = %d\n", i, TGTAR[i].RAICOM_B, TPLAC[p].RETCTR_NF, TACC[a].CTR_NF, TPLAC[p].PLC_NT, TGTAR[i].RETOVRCOMAMT_M, TGTAR[i].OVRCOMAMT_M, TPLAC[p].OVERBASIS_NT, flagCalc);
	#endif

    
    if(  (flagCalc != -1) )
    {     
    	
      TGTAR[i].RETOVRCOMAMT_M = TGTAR[i].RETAMT_M * TPLAC[p].OVRCOM_R * (-1.) ;
      TGTAR[i].OVRCOMAMT_M = TGTAR[i].AMT_M * TPLAC[p].OVRCOM_R * (-1.) ;


  #ifdef DBG_MODE    	
   if ((strcmp(TACC[a].RETCTR_NF, "RP0002429") == 0 || strcmp(TACC[a].RETCTR_NF, "RT0000003") == 0  || strcmp(TACC[a].CTR_NF, "RP0002429") == 0)	&& TACC[a].RTY_NF == 2022)
   		printf(" AVANT ADDITION RETOVRCOMAMT indice  : i ; TPLAC[p].RETCTR_NF ; TACC[a].CTR_NF ; TGTAR[i].RETOVRCOMAMT_M  ; TGTAR[i].OVRCOMAMT_M ; TPLAC[p].OVRCOM_R : %d ; %s ; %s ;  %d; %f; %f ; %f\n", i, TPLAC[p].RETCTR_NF, TACC[a].CTR_NF, TPLAC[p].PLC_NT, TGTAR[i].RETOVRCOMAMT_M, TGTAR[i].OVRCOMAMT_M, TPLAC[p].OVRCOM_R);
	#endif
    }	
   }
    // [18] Calcul du Fix Comm et du Ret OVr Comm
    

   		TGTAR[i].RETOVRCOMAMT_M += TGTAR[i].RETCOMAMT_M ; //TGTAR[i].RETOVRCOMAMT_M += TGTAR[i].RETCOMAMT_M  * TPLAC[p].OVRCOM_R * (-1.);
			TGTAR[i].OVRCOMAMT_M += TGTAR[i].COMAMT_M   ;	    //TGTAR[i].OVRCOMAMT_M += TGTAR[i].COMAMT_M * TPLAC[p].OVRCOM_R * (-1.) 		


  #ifdef DBG_MODE    	
   if ((strcmp(TACC[a].RETCTR_NF, "RP0002429") == 0 || strcmp(TACC[a].RETCTR_NF, "RT0000003") == 0  || strcmp(TACC[a].CTR_NF, "RP0002429") == 0)	&& TACC[a].RTY_NF == 2022)
   		printf(" APRES ADDITION RETOVRCOMAMT indice  : i ; TPLAC[p].RETCTR_NF ; TACC[a].CTR_NF ; TGTAR[i].RETOVRCOMAMT_M  ; TGTAR[i].OVRCOMAMT_M ; TPLAC[p].OVRCOM_R : %d ; %s ; %s ;  %d; %f; %f ; %f\n", i, TPLAC[p].RETCTR_NF, TACC[a].CTR_NF, TPLAC[p].PLC_NT, TGTAR[i].RETOVRCOMAMT_M, TGTAR[i].OVRCOMAMT_M, TPLAC[p].OVRCOM_R);
	#endif


// EVOL  SAVE  TRNCOD 
	  		
   	strcpy(TACC[a].TRNCOD_CF, FUTURE_RETRO_OVERRIDE);


  TGTAR[i].RAICOM_B = TPLAC[p].RAICOM_B;

  #ifdef DBG_MODE   
   if ((strcmp(TACC[a].RETCTR_NF, "RP0002429") == 0 || strcmp(TACC[a].RETCTR_NF, "RT0000003") == 0  || strcmp(TACC[a].CTR_NF, "RP0002429") == 0)	&& TACC[a].RTY_NF == 2022)	
	printf(" 00 EcrireTGTAR_NEW  CALCULE indice i [%d] : %s : %s : %s : %d : %d : %f : %f : %f  : %f :%f : %f : %f : %f : %f ; %d ; %f ; %f\n",
			i,
			TPLAC[p].RETCTR_NF,
			TACC[a].CTR_NF,
			TACC[a].TRNCOD_CF,
			n_BASIS_NT_5,
			n_BASIS_NT_5,    //TPLAC[p].OVERBASIS_NT
			TGTAR[i].AMT_M,
			TGTAR[i].COMAMT_M,
			TGTAR[i].RETAMT_M,
			TPLAC[p].FIXCOM_R,
			TPLAC[p].OVRCOM_R,
			TGTAR[i].OVRCOMAMT_M,
			TGTAR[i].RETCOMAMT_M,
			TGTAR[i].RETOVRCOMAMT_M,
			TPLAC[p].RETSIGSHA_R,
			TPLAC[p].PLC_NT,
			d_taux,
			TGTAR[i].RAICOM_B);

  #endif
  
  //
   if ( get_exclude_retrocomm_flag(TACC[a].TRNCOD_CF,TGTAR[i].RAICOM_B, TACC[a].TRN_NT)  != 'E'  )    
    {
      EcrireGT(Kp_GTAr, TGTAR[i], TGTAR[i].RETOVRCOMAMT_M, TGTAR[i].RETOVRCOMAMT_M, TACC[a].TRNCOD_CF, 0, FIC_2GTAR);
      EcrireGTRr(Kp_GTRr, TGTAR[i], TGTAR[i].RETOVRCOMAMT_M, TACC[a].TRNCOD_CF);
    }

  
 }
  RETURN_VAL(OK);
}



//[14]
/*=============================================================
objet : Ecrire une ligne au format GT dans un fichier en sortie
===============================================================*/
static int EcrireGT(FILE * pf, T_GTAR TGTAR, double d_Ma, double d_Mr, char * sz_trncod, double d_Mri, enum TYPE_FIC_GT type_gt)
{
  char sz_placement[10] = "\0";
  double d_retintamt_m = 0.0;

  DEBUT_FCT ("EcrireGT") ;



  if (type_gt == FIC_2GTAR || type_gt == FIC_GTARP)
			sprintf(sz_placement, "%d", TGTAR.pp->PLC_NT); 	
			
  if (type_gt == FIC_GTARP)
    d_retintamt_m = d_Mri;
    

//[14]

	if (strcmp(FUTURE_RETRO_OVERRIDE, sz_trncod) == 0 )   //&& atoi(sz_placement) == TGTAR.pp->PLC_NT)
  {  
  	
  	
  	//[18] if ( TGTAR.pp->OVRCOM_R != 0.000)
  	{ 

  		d_Ma = TGTAR.OVRCOMAMT_M ;
  		d_Mr = TGTAR.RETOVRCOMAMT_M ;
  		
  		sprintf(sz_placement, "%d", TGTAR.pp->PLC_NT);      // Renseigner le PLC_NT quelque soit le type de fichier pour les Future Retro OVERRIDE
    }
  	
  }	

  
  if ( fabs(d_Ma) >= 0.001 || fabs(d_Mr) >= 0.001 ) {
    fprintf(pf, "%d~%d~%d~%d~%d~%s~%s~%s~%d~%d~%d~%d~%s~%d~%d~%d~%s~%s~%.3lf~%d~%d~%d~%s~%s~%d~%d~%d~%d~%s~%d~%d~%d~%s~%s~%.3lf~%s~~~~~%.3lf",
            TGTAR.pa->SSD_CF,
            TGTAR.pp->ESB_CF,
            TGTAR.pa->BALSHEY_NF,
            TGTAR.pa->BALSHRMTH_NF,
            TGTAR.pa->BALSHRDAY_NF,
            sz_trncod,
            TGTAR.pa->DBLTRNCOD_CF,
            TGTAR.pa->CTR_NF,
            TGTAR.pa->END_NT,
            TGTAR.pa->SEC_NF,
            TGTAR.pa->UWY_NF,
            TGTAR.pa->UW_NT,
            TGTAR.pa->OCCYEA_NF,
            TGTAR.pa->ACY_NF,
            TGTAR.pa->SCOSTRMTH_NF,
            TGTAR.pa->SCOENDMTH_NF,
            TGTAR.pa->CLM_NF,
            TGTAR.pa->CUR_CF,
            d_Ma,
            TGTAR.pa->CED_NF,
            TGTAR.pa->BRK_NF,
            TGTAR.pa->PAY_NF,
            TGTAR.pa->KEY_NF,
            TGTAR.pa->RETCTR_NF,
            TGTAR.pa->RETEND_NT,
            TGTAR.pa->RETSEC_NF,
            TGTAR.pa->RTY_NF,
            TGTAR.pa->RETUW_NT,
            TGTAR.pa->RETOCCYEA_NF,
            TGTAR.pa->RETACY_NF,
            TGTAR.pa->RETSCOSTRMTH_NF,
            TGTAR.pa->RETSCOENDMTH_NF,
            TGTAR.pa->RCL_NF,
            TGTAR.pp->RETCUR_CF,
            AfficheMontant(d_Mr),
            sz_placement,
            d_retintamt_m);
    if (Kn_GTE == 0)
    {
      if (Kb_GTA_COLS == 1)
      { //14 colonnes SAP à vide
        fprintf(pf, "~~~~~~~~~~~~~~~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s",
                TGTAR.pa->TRN_NT,
                TGTAR.pa->ORICOD_LS,
                TGTAR.pa->RETROAUTO_B,
                TGTAR.pa->SPEENTNAT_CT,
                TGTAR.pa->EVT_NF,
                TGTAR.pa->REVT_NF,
                TGTAR.pa->RETARDRETINT_B,
                TGTAR.pa->NEWCOLS1_NF,
                TGTAR.pa->NEWCOLS2_NF,
                TGTAR.pa->NEWCOLS3_NF,
                TGTAR.pa->NEWCOLS4_NF,
                TGTAR.pa->NEWCOLS5_NF,
                TGTAR.pa->NEWCOLS6_NF,
                TGTAR.pa->NEWCOLS7_NF,
                TGTAR.pa->NEWCOLS8_NF,
                TGTAR.pa->NEWCOLS9_NF);
      }
      fprintf(pf, "\n");
    }
    else { // si gestion écritures service des ESID0091.cmd, ESIJ0091.cmd et ESPJ0091.cmd
      fprintf(pf, "~%d~%d~%d~%d~%s~%d~%d~%02d~%02d~%s\n",
              TGTAR.pa->ENTPERYEA_NF,
              TGTAR.pa->ENTPERMTH_NF,
              TGTAR.pa->VALPERYEA_NF,
              TGTAR.pa->VALPERMTH_NF,
              TGTAR.pa->TRN_NT2,
              TGTAR.pa->ACCTYP_NF,
              TGTAR.pa->BALSHEY_NF_PLUS,
              TGTAR.pa->BALSHRMTH_NF_PLUS,
              TGTAR.pa->BALSHRDAY_NF_PLUS,
              TGTAR.pa->COMMAC_LL);
    }
  }

  RETURN_VAL( OK);
}


//[14]
/*=============================================================
objet : Ecrire une ligne au format GTRr dans un fichier en sortie
===============================================================*/
static int EcrireGTRr(FILE * pf, T_GTAR TGTAR, double d_Mr, char * sz_trncod)
{
  DEBUT_FCT ("EcrireGTRr") ;


//[18]
 	if (strcmp(FUTURE_RETRO_OVERRIDE, sz_trncod) == 0)  
  {    	
  		d_Mr = TGTAR.RETOVRCOMAMT_M ;
  		
  }	

 
  if ( fabs(d_Mr) >= 0.001 ) {
    /* ajout derniere colonne pour retintamt_m */
    fprintf(pf, "%d~%d~%d~%d~%d~%s~%s~~~~~~~~~~~~~~~~~%s~%d~%d~%d~%d~%s~%d~%d~%d~%s~%s~%.3lf~%d~%d~%d~%d~%s~%.3lf",
            TGTAR.pa->SSD_CF,
            TGTAR.pp->ESB_CF,
            TGTAR.pa->BALSHEY_NF,
            TGTAR.pa->BALSHRMTH_NF,
            TGTAR.pa->BALSHRDAY_NF,
            sz_trncod,
            TGTAR.pa->DBLTRNCOD_CF,
            TGTAR.pa->RETCTR_NF,
            TGTAR.pa->RETEND_NT,
            TGTAR.pa->RETSEC_NF,
            TGTAR.pa->RTY_NF,
            TGTAR.pa->RETUW_NT,
            TGTAR.pa->RETOCCYEA_NF,
            TGTAR.pa->RETACY_NF,
            TGTAR.pa->RETSCOSTRMTH_NF,
            TGTAR.pa->RETSCOENDMTH_NF,
            TGTAR.pa->RCL_NF,
            TGTAR.pp->RETCUR_CF,
            AfficheMontant(d_Mr),
            TGTAR.pp->PLC_NT,
            TGTAR.pp->RTO_NF,
            TGTAR.pp->INT_NF,
            TGTAR.pp->PAY_NF,
            TGTAR.pp->KEY_CF,
            0.000); /* RETINTAMT_M */
    if (Kb_GTA_COLS == 1)
    { //14 colonnes SAP à vide
      fprintf(pf, "~~~~~~~~~~~~~~~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s",
              TGTAR.pa->TRN_NT,
              TGTAR.pa->ORICOD_LS,
              TGTAR.pa->RETROAUTO_B,
              TGTAR.pa->SPEENTNAT_CT,
              TGTAR.pa->EVT_NF,
              TGTAR.pa->REVT_NF,
              TGTAR.pa->RETARDRETINT_B,
              TGTAR.pa->NEWCOLS1_NF,
              TGTAR.pa->NEWCOLS2_NF,
              TGTAR.pa->NEWCOLS3_NF,
              TGTAR.pa->NEWCOLS4_NF,
              TGTAR.pa->NEWCOLS5_NF,
              TGTAR.pa->NEWCOLS6_NF,
              TGTAR.pa->NEWCOLS7_NF,
              TGTAR.pa->NEWCOLS8_NF,
              TGTAR.pa->NEWCOLS9_NF);
    }
    fprintf(pf, "\n");
  }
  RETURN_VAL (OK);
}

/*============================================================================
objet :
   Lancement du traitement destine a ramener des lignes de la base.

retour :
 CS_SUCCEED
 CS_FAIL
==============================================================================*/
static char *sz_GetCurcvsnIndx(     FILE * pf, /* Discripteur du fichier des cours    */
                                    char *sz_acpcur,        /* Cours d'origine      */
                                    char  c_ssd,            /* filiale              */
                                    char *sz_retctr,        /* contrat              */
                                    short s_rty,            /* Exercice             */
                                    int   n_plc,            /* placement            */
                                    char *pc_PlcTrouve      /* JR 28/04/03          */
                              )
{
  static char b_First = TRUE;
  static T_INDXCURQUOT *pKbd_Adr;
  static T_CURCVSN *pKbd_curcvsn;
  T_INDXCURQUOT bd_AdrTampon;
  static int Kn_MaxCoursDevise;
  static int k = 0;

  static char* sz_Vide = NULL ;
  int i, j;
  int n_position = -1;
  char b_SsdTrouve = 0;
  char b_RetctrRtyTrouve = 0;
  char b_PlcTrouve = 0;
  char b_PlcNulTrouve = 0;
  static int  n_DebutData = MAX_DEVISE * sizeof(T_INDXCURQUOT);

  DEBUT_FCT ("sz_GetCurcvsnIndx");


  *pc_PlcTrouve = 0;        /* JR 28/04/03 */
  if (b_First)
  {
    b_First = FALSE;
    if (fseek(pf, 0, SEEK_SET) == -1L)
    {
      RETURN_VAL (NULL);
    }
    else
    {
      while (fread (&bd_AdrTampon, sizeof(T_INDXCURQUOT), 1, pf) > 0 && bd_AdrTampon.n_Nbr != 0 )
      {
        k++;
        Kn_MaxCoursDevise = max ( bd_AdrTampon.n_Nbr, Kn_MaxCoursDevise );
      }

      /* allocation de la memoire pour les deux structures */
      pKbd_curcvsn = calloc (Kn_MaxCoursDevise, sizeof(T_CURCVSN));
      pKbd_Adr = calloc (k, sizeof(T_INDXCURQUOT));

      /* remplissage de la structure des adresses */
      fseek(pf, 0, SEEK_SET);
      fread(pKbd_Adr,  sizeof(T_INDXCURQUOT), k, pf);
    }
  }



  for (i = 0; i < k; i++)
  {
    if (strcmp(pKbd_Adr[i].sz_cur, sz_acpcur) == 0)
    {
      if (fseek( pf, pKbd_Adr[i].l_Pos * sizeof(T_CURCVSN) + n_DebutData, SEEK_SET) == -1L)
      {
        RETURN_VAL(NULL);
      }
      else
      {
        if ( fread(pKbd_curcvsn, sizeof(T_CURCVSN), pKbd_Adr[i].n_Nbr, pf) > 0 )
        {
          for (j = 0; j < pKbd_Adr[i].n_Nbr ; j++ )
          {
            if (c_ssd == pKbd_curcvsn[j].SSD_CF)
            {
              b_SsdTrouve = 1;

              if ( (strcmp(pKbd_curcvsn[j].RETCTR_NF, "         ") == 0) && pKbd_curcvsn[j].RTY_NF == 0)
              {
                n_position = j;
                continue ;
              }

              if ( (strcmp(sz_retctr, pKbd_curcvsn[j].RETCTR_NF) == 0) &&  (s_rty == pKbd_curcvsn[j].RTY_NF) )
              {
                b_RetctrRtyTrouve = 1;
                if (pKbd_curcvsn[j].PLC_NT == 0)
                {
                  n_position = j;
                  b_PlcNulTrouve = 1;
                }

                if (n_plc == pKbd_curcvsn[j].PLC_NT)
                {
                  b_PlcTrouve = 1;
                  *pc_PlcTrouve = 1;   /* JR 28/04/03 */
                  n_position = j;
                  break;
                }
              }

              if (strcmp(sz_retctr, pKbd_curcvsn[j].RETCTR_NF) < 0)
                break;
            }
          }

          if ((n_position < 0) || (b_SsdTrouve == 0) )
          {
            RETURN_VAL(sz_acpcur);      //[002]         RETURN_VAL(sz_Vide);
          }
          else
          {
            RETURN_VAL (pKbd_curcvsn[n_position].ACCCUR_CF);
          }
        }
        else
        {
          RETURN_VAL(sz_Vide) ;
        }
      }
    }
  }
  RETURN_VAL(sz_Vide);
}

/*==============================================================================
 Objet :
   Initialisation de la variable de gestion de rupture (Maitre==FCUR)
 Parametre(s) :
   Pointeur sur une structure T_RUPTURE_VAR

 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_InitFCURCVSNBIS(T_RUPTURE_VAR  * pbd_Rupt)
{

  memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

  if (n_OpenFileAppl("ESTC2304_I5", "rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->n_ActionLigne = n_ActionLigneFCURCVSNBIS;
  pbd_Rupt->c_Separ = '~';

  return OK;
}

/*==============================================================================
 Objet :
   Fonction lancee pour chaque ligne du Maitre

 Parametre(s) :
   Pointeur sur la ligne courante

 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_ActionLigneFCURCVSNBIS(char **ptb_InRec_Cur)
{
  Ktbd_FCURCVSNBIS[Kn_FCURCVSNBIS].SSD_CF = atoi(ptb_InRec_Cur[CURCVSNBIS_SSD_CF]);
  Ktbd_FCURCVSNBIS[Kn_FCURCVSNBIS].RETCTR_NF = ptb_InRec_Cur[CURCVSNBIS_RETCTR_NF];
  Ktbd_FCURCVSNBIS[Kn_FCURCVSNBIS].RTY_NF = atoi(ptb_InRec_Cur[CURCVSNBIS_RTY_NF]);
  Ktbd_FCURCVSNBIS[Kn_FCURCVSNBIS].PLC_NT = atoi(ptb_InRec_Cur[CURCVSNBIS_PLC_NT]);

  Kn_FCURCVSNBIS += 1;

  if (Kn_FCURCVSNBIS > Kn_MaxLigFCURCVSNBIS )
  {
    n_WriteAno(" Depassement capacite du tableau CURCVSNBIS ");
    return ERR;
  }
  return OK ;
}

/*==============================================================================
objet :
        fonction de recherche de la devise
retour :
        0       ---> Pas de rupture
        < 0     ---> On n'est pas arrive au bloc synchrone
        > 0     ---> On a depasse le bloc synchrone
==============================================================================*/
int n_RechCURCVSNBIS(char *sz_retctr, int n_rty, int n_plc)
{
  int i;

  DEBUT_FCT("n_RechCur");

  for ( i = 0; i <  Kn_FCURCVSNBIS ; i++ )
  {
    if (
      strcmp( sz_retctr, Ktbd_FCURCVSNBIS[i].RETCTR_NF) == 0
      &&
      n_rty == Ktbd_FCURCVSNBIS[i].RTY_NF
      &&
      n_plc == Ktbd_FCURCVSNBIS[i].PLC_NT
    )
      RETURN_VAL(i);
  }
  RETURN_VAL(-1);   /* Si non trouve */
}



/*==============================================================================
objet :
        fonction de chargement des données du fichier TRSLNK
retour :
        ERR ou Ok suivant le cas

==============================================================================*/
int n_ChargementTrslnkRetro(int prs)
{
  FILE* pFichier;
  // pour le chargement ligne par ligne
  T_TRSLNK buffer;

  DEBUT_FCT("n_ChargementTrslnkRetro");

  if (n_OpenFileAppl("ESTC2304_I6", "rb", &pFichier))
    return ERR;
  rewind(pFichier);

  // calcul du nombre de lignes PRS
  while ( fread (&buffer, sizeof(T_TRSLNK), 1, pFichier) == 1)
  {
    if (buffer.PRS_CF == prs)
      nbTrslnk++;
  }
  rewind(pFichier);

  pTrslnk = (T_TRSLNK*) malloc (sizeof(buffer) * nbTrslnk);
  nbTrslnk = 0;

  while ( fread (&buffer, sizeof(T_TRSLNK), 1, pFichier) == 1)
  {
    if (buffer.PRS_CF == prs)
    {
      memcpy(&pTrslnk[nbTrslnk], &buffer, sizeof(T_TRSLNK));
      //printf("TEST_PRS_50_GROUPING_6 PRS=%d~%d~%s\n", buffer.PRS_CF, buffer.ACMTRS_NT, buffer.DETTRS_CF);
      nbTrslnk++;
    }
  }


  if ( n_CloseFileAppl ("ESTC2304_I6", &pFichier) == ERR )
    ExitPgm ( ERR_XX , "Erreur de fermeture du fichier trslnk( ESTC2304_I6)" );

  RETURN_VAL( OK );
}

/*==============================================================================
objet :
        fonction de recherche des données du fichier TRSLNK
retour :
        -1 si pas trouvé , sinon l'index du tableau

==============================================================================*/

int RecherchePosteFromTRSLNK( char * trncode, int basis)
{
  int retour = -1; // par défaut
  int idx ;

  for (idx = 0; idx < nbTrslnk; idx++)
  {
    if ((strcmp (pTrslnk[idx].DETTRS_CF, trncode ) == 0) && (strcmp (pTrslnk[idx].DETTRS_CF, trncode ) == 0) && (pTrslnk[idx].ACMTRS_NT == basis ))
      return idx;
  }
  return retour;
}

// [13]
double AfficheMontant(double mr)
{
  double iMontant, mult = 1000000000L;

  iMontant = mr * mult;
  return iMontant / mult;

}




