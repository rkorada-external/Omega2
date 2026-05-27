/*==============================================================================
nom de l'application          : ESTIMATION SOLVENCY
nom du source                 : ESTC1065.c
révision                      : $Revision: 1.0 $
date de création              : 11/10/2012
auteur                        : Roger Cassis
references des specifications :
squelette de base             : batch
------------------------------------------------------------------------------
description :
   :spot:24041 - Calcul des primes et charges futures et des primes sinistre
                 avec Transformation des postes

1A100002 -> genere 1A100012 = Future Premium
         -> et 1A494302     = Future Claim
1A120002 -> genere 1A120012 = Future Charge

------------------------------------------------------------------------------
historique des modifications :
[01] 11/02/2013 R.Cassis :spot:24836 Gestion segment pas trouvé et bug dans recherche
[02] 27/06/2014 R. Cassis :spot:25036 Modifie compteur du NB_TRSLNK_MAX (+10000)
[XX] 06/04/2014 JBG      :spot:25773 Modify void main declaration to int main
[XX] 09/10/2014  JBG  :spot:25773  suppress warning: unused variables
[04] 05/05/2015 Florent :spot:26391 gestion du segment *
[05] 18/04/2016 -=Dch=- :spot:30465 Ajout des logs pour les utilisateurs 
[06] 04/05/2016 SAS   :spot:30534  EBS - Futures Premiums (42511) & Charges(42512)
[07] 23/06/2016 SAS      :spot:30534 42512: Charges Futures
[08] 07/07/2016 Florent  :spot:30890 EBS - Correction sur le calcul des futures pour traités NP
[09] 05/12/2016		PGA 	SPIRA 57431 renforcement restriction ligne 302
[10] 30/08/2018 JYP : IFRS17 req 10.6 : new rules to calculate loss ratio applied to claim amount
[11] 12/09/2018 JYP : IFRS17 req 10.1 : premium and charges Remaining Estimates
[012] 17/09/2018 MZM    :spira:68071 EBS - Future Premium - No estimates for fac : le montant des estimations sera  à 0
[013] 26/10/2018 MZM    Spira:67650 REQ10.4 REQ10.5 : Assumed Future Charges account by three new accounts : Future Brokerage, Future Fixed commission and Taxes, and Future Variable commissions
[014] 27/12/2018 JYP	:spira:73946 EBS - bugfix previous spira - Future charges NOT calculated for FAC
[015] 22/01/2019 MZM  :spira:75042 Update on UPR definition in BPR-EST-904298 
[016] 01/02/2019 MZM  :spira:75803 IFRS17- Signed amount for future, expenses and expected positions 
[017] 11/02/2019 JYP  :spira:75803 IFRS17 req 10.1 : Signed amount for future (req 10.1 amounts)  
[018] 20/02/2019 JYP  :spira:67651 IFRS17 req 10.6 : change rule future claim (add *100) 
[020] 20/02/2019 JYP  :spira:75803 IFRS17 req 10.1 : Signed amount for future (req 10.1 amounts)  
[021] 20/02/2019 JYP  :spira:75803 IFRS17 req 10.1 : review all amounts  
[022] 20/02/2019 MZM  :Spira:67650 REQ10.4 REQ10.5 : Assumed Future ; Modif Burning Cost et Reinstatemment Premium
[023] 27/02/2019 JYP  :spira:75803 IFRS17 req 10.1 : review all amounts and logs
[024] 04/03/2019 MZM  :spira:67650 IFRS17 REQ 10.4 10.5 Correction des Future Variable Charges
[025] 07/03/2019 JYP  :spira:67651 : bugfix ecrasement memoire 
[026] 22/03/2019 MZM  :spira:76456 IFRS 17 - Future Brokerage - Amount calculated incorrect : Pb d initialisation et ajout de la fonction n_ActionPereSansFilsLoaRat
[027] 04/04/2019 MZM  :spira:77282 no Future Profit Commission
[028] 11/04/2019 MZM  :spira:76628 Variable Premium Burning Cost et Reinstatament Premium non calcul
[029] 15/04/2019 JYP  :spira:73732 use UPR including ROJA for all calculation
[030] 24/04/2019 MZM  :spira:77696 Missing or incorrect future fixe commission
[031] 16/05/2019 MZM  :spira:77288 incorrect future variable commissions :the calculated sliding scale ratio is not correct
[032] 16/05/2019 MZM  :spira:77282 no Future Profit Commission : Management expenses are applied on (future fixed premium - UPR) instead of being applied on Future fixed premium only
[033] 16/05/2019 MZM  :spira:68072 EBS - Cash Flow Table - Transactional Currency
[034] 24/05/2019 MZM  :spira:77696 Missing or incorrect future fixe commission : Prise en compte du COMTYP ='1', ou COMTYP ='3' ou COMTYP ="" dans le calcul future Charge fixe
[035] 31/05/2019 JYP  :spira 73732 : bugfix UPR_DAC sec_nf >= 10
[036] 13/06/2019 JYP  :spira 79013 : bugfix UPR_DAC accept tcodes 14* instead of 12*
[037] 17/06/2019 TY   :IFRS17 req 10.11 : ajout champ CANEGP_M de TSECIFRS
[038] 03/07/2019 MZM  :spira 78985 : INT - No future commission (one contract) : Suppression de la condition kc_FlagPNAseul
[039] 20/08/2019 MiS  :spira 76458 : Assumed Future Brokerage Modification Règle de calcul
[040] 27/08/2019 MiS  :spira 76735 : No LR on a given UWY
[041] 30/08/2019 MZM  :spira:70537 : Calcul des FUTURE AT INCEPTION : Ajout Fonction n_ActionPereSansFilsDlGtaa
[042] 02/09/2019 MZM  :spira:76840 : Stop Future Claims calculation when no UPR and no future premium
[043] 16/09/2019 MZM  :spira:76175 : Future fixed charges - Take into account overrider in future fixed charges calculation
[044] 22/10/2019 MZM  :spira:73772 : Manage retro contract and merge input to cashflow calculations : Deplacement du calcul des Remaining dans la fct ActionLigneDLGTAA
[045] 23/10/2019 MiS  :spira 78628 : Future Variable commissions - split accounts
[046] 20/11/2019 JYP : spira 67646 : req 10.1 calculate remaining amount by CSUOE
[047] 28/11/2019 JYP : spira 82574 : check new UPR for claim calculation
[048] 10/12/2019 MZM : spira 67646 : req 10.1 calculate remaining amount by CSUOE [Mise en Commentaire de l'ecriture dans DLDGTAA]
[049] 15/01/2020 MZM : spira 82843 : Calcul des Taux At Inception à desactiver 
[050] 06/12/2019 MiS : spira 77466 : REQ 10.13 Split remaining
[051] 31/01/2020 HR  : spira 81813 : replacement of brokerage rate 1A120032 by 1A120062 
[052] 04/02/2020 MiS : spira 82761 : Profit and Loss Commission, Sliding Scale TRNCOD
========================================================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "ESTC1065.h" 
#include "struct.h"
#include "estserv.h"
#include "estutil.c"

/*----------------------------------------*/
/* inclusion de version dans les binaires */
/*----------------------------------------*/
static char VERSION_ESTC1065_C[150] = "__version__: ESTC1065.c version [050] 30/01/2020 : REQ 10.13 Split remaining"; 


/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/
#define NB_TRSLNK_MAX 30000   //  [002]
#define NB_SEGEST_MAX 10000
#define LGTH_SEGEST 100
#define SEPARATOR 	 "~"
#define SEG_SSD_CF     0
#define SEG_SEG_NF     1
#define SEG_UWY_NF     2
#define SEG_CUR_CF     3
#define SEG_SEGNAT_CT  4
#define SEG_CLMAMT_M   5
#define SEG_LOSRAT_R   6
#define SEG_AMORAT_CT  7
#define SEG_SEGTYP_CT  8
#define Kn_MaxLigFBOTRSLNK   60000 //[11] 
#define UPR   1  // [11]
#define DAC   2  // [11]
#define COME  3  // [11]
#define PRME  4  // [11]
#define ITDP  5  // [13] ITD written premium 
#define OTHER 6  // [11]

//Split DAC et COME qui correspondront aux FIXED
#define DACVAR 7 // DAC Variable
#define DACBRK 8 // DAC Brokerage
#define COMEVAR 9 // Commissions Estimates Variable
#define COMEBRK 10 // Commissions Estimates Brokerage

#define NB_COL_GT2 71 //[11]

/* 
#define TRACE_1  1  // [11]
#define TRACE_2  2  // [11] more detailled traces
*/


//#define TRACE_UPR_DAC  1
//#define TRACE_FUTURE_CLAIMS 
//#define TRACE_FUTURE_FIXE_PREMIUM 
//#define TRACE_FUTURE_VARIABLE_PREMIUM
//#define TRACE_FUTURE_FIXE_CHARGE
//#define TRACE_FUTURE_VARIABLE_CHARGE
////#define TRACE_FUTURE_BROKERAGE
//#define TRACE_PRIME_RECONSTITUTION
//#define TRACE_BURNING_COST
#define TRACE_BURNING_COST_INC
//
//#define TRACE_5
//
//#define TRACE_PNA_VERSUS_UPR  5
//
//#define TRACE_CLAIMS_RATIOS			3
//#define TRACE_REMAINING_PRM_COMM	4

//#define TRACE_FUTURE_INC_CLM
//#define TRACE_FUTURE_FIXE_INC_PRM
#define TRACE_FUTURE_INC_BROKERAGE
#define TRACE_FUTURE_VAR_INC_PRM
#define TRACE_PRIME_RECONSTITUTION_INC

/* [044]nn
#define TRACE_REMAINING_PRM
#define TRACE_REMAINING_PRM_ANN
#define TRACE_REMAINING_COMM
#define TRACE_REMAINING_COMM_ANN
*/
/*----------------------------------*/

// Ajout d'une structure pour stocker les colonnes de sorties de log

typedef struct T_FUT_LOGS{
		short SSD_CF; 
		short ESB_CF; 
		char* CTR_NF;
		short END_NT;
		short SEC_NF;
		short UWY_NF;
		char* SEG_NF;
		double SCOEGP_M;
		char* CUR_CF;
		double AMTCEXP_M;
		double AMTCPRM_M;
		double AMTCPNA;
		double LOSRAT_R;
		double TAUX;
		double FUFPREMIUM;
		double FUVPREMIUM;		
		double FUCLAIM;
		double FUFEXP;
		double FUVEXP;
		double FUBROKER;	
	  char*  TRNCOD;					
		} T_FUTURES;	

	T_FUTURES*	pFutures;
		
	T_LIGNEREC   Ktbd_Rec[1000] ; /*Pointeur sur element du tableau de reconstit*/
	int 	Kn_RecRnk ;

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE   *Kp_OutputFilResSii;    /* pointeur sur le fichier de sortie formaté avec les nouvelles colonnes */
FILE   *Kp_OutputFilResSiiAno; /* pointeur sur le fichier de sortie des lignes sans segment */
FILE   *Kp_InputFilTrsLnk;     /* pointeur sur le fichier en entree des postes cumuls */
FILE   *Kp_InputFilExc;        /* pointeur sur le fichier en entree des cours de change */
FILE   *Kp_InputFilSegest ;    /* pointeur sur le fichier binaire FSEGEST */
FILE   *p_OutputFutures; 	   /* Fichier de log pour les users [05] -=Dch=-  */

T_RUPTURE_VAR       bd_RuptPerUw;   /* variable de gestion de la rupture sur le perimetre de Accept ou Retro */
T_RUPTURE_SYNC_VAR  bd_RuptDlGtaa; /* variable de gestion de la synchronisation avec le fichier DTSTATGTx */


//[013]

T_RUPTURE_SYNC_VAR 	bd_RuptPerFci ; /* variable de gestion de la synchronisation avec le fichier annexe du perimetre famille de charges iterees */
T_RUPTURE_SYNC_VAR 	bd_RuptPerFr ;  /* variable de gestion de la synchronisation avec le pericase et fichier annexe du perimetre Annexe */
T_RUPTURE_SYNC_VAR  bd_RuptPrmLoa; 	/* Synchro avec le fichier des primes */
double  Ktd_Comp[COMP_NBPOSTE] ;  	/* tableau des complements de charges, taxes et courtage */

//[013] Deb Variables Familles iterees et Calcul des PB et PAP
T_TabPbPap    * pdb_P,  tbd_PbPap[NB_PAR_MAX];   		/* i-o Tableau des participations pertes et benef*/
T_TabPart Ktbd_Par[NB_PAR_MAX] ; 			/* tableau des participations */
short Kn_Par_Nbp	;		 								/* nombre de poste du tableau Ktbd_Par */
T_ESTGT	Ktbd_EstGt[NB_PAR_MAX] ; 			/* tableau des champs necessaires a l'ecriture en sortie */

T_TabFamCharIt Ktbd_FamCha_02[NB_UWY_MAX][NB_FAM_MAX] ; /* tableau des familles de charges iterees par exercice pour le calcul de PB et PAP */

T_TabFamCharIt  Ktbd_FamCha[NB_FAM_MAX] ;  	/* tableau des famillles */
short Ktn_FamUwy[NB_UWY_MAX] ; /* tableau des nombres de postes du tableau Ktbd_FamCha par exercice */
short Kn_Fam_Nbp ;		 /* nombre de postes de Ktbd_FamCha_02 pour un exercice */
short Kn_Fam_Nbl ;		 /* nombre de lignes de Ktbd_FamCha */
int   n_PbPap_Nbp;
//[013] Fin Variables Familles iterees et Calcul des PB et PAP

int Kn_NbLigTrslnk;     /* nombre de postes dans le tableau */
int Kn_NbLig_Segest;   /* nombre de postes dans le tableau */

//[013] Ajout des fonction de rupture Perimetre Annexe
int n_InitPerFr			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLignePerFr		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncPerFr	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_IsR1PerFr			( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_ActionFirstRuptPerFr	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ActionLastRuptPerFr	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int Kn_Pa ;		/* variable de participations des fichiers esclaves */

int Kc_Pe ;		/* flag positionne a 1 si il existe au moins une prime  dans
				le Fichier de travail pour une affaire donnee */
				
	

//[013]
int n_InitPrmLoa    ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLignePrmLoa   ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncPrmLoa ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;

T_RUPTURE_VAR  	   	bd_RuptFt ;     /* variable de gestion de la rupture sur le GT */
T_RUPTURE_SYNC_VAR 	bd_RuptLoaRat ; /* variable de gestion de la synchronisation avec le fichier des taux de charges */
T_RUPTURE_SYNC_VAR 	bd_RuptGtLoa ;  /* variable de gestion de la synchronisation avec le GT des charges */
T_RUPTURE_SYNC_VAR 	bd_RuptGtFac ;  /* variable de gestion de la synchronisation avec le GT des primes estimees FAC et RPCC */
T_RUPTURE_SYNC_VAR 	bd_RuptPer ;    /* variable de gestion de la synchronisation avec le perimetre */
T_RUPTURE_SYNC_VAR 	bd_RuptGtRec ;  /* variable de gestion de la synchronisation avec le GT des REC */   

//[013]synchronisation avec le fichier des taux de charges

int n_InitLoaRat( T_RUPTURE_SYNC_VAR  *pbd_Rupt);
int n_ConditionSyncLoaRat(char **pbd_InRecOwner , char **pbd_InRecChild  );
int n_ActionLigneLoaRat(char **ptb_InRecOwner , char **ptb_InRecChild );  
int n_ActionPereSansFilsLoaRat(char **ptsz_LigneMaitre);   //[026]

//[013] Synchronisation avec le fichier des Charges Itérées

int n_InitPerFci 		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLignePerFci		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncPerFci	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

double  Kd_ComRat = 0;     /* taux de commissionnement                 */
double  Kd_SurComRat =0;;  /* taux de surcommissionnement              */
double  Kd_Tax = 0;        /* taxes                                    */ //[026]
double  Kd_BrkRat =0;   /* taux de courtage                         */ //[026]

double 	Kd_ComRatsc ;   /* Taux de commissionnement Fixe, variable */  

double Kd_PAP;					/* Loss Commission ou participation aux Pertes */
double Kd_PB ;          /* Profit ou Participation Benefices */

double Kd_SC ;          /* Sliding Scale */

int	Kn_NbFam  ; 				/* nombre de postes du tableau Ktbd_FamCha */
//[013]

T_TRSLNK          Ktbd_TrsLnk[NB_TRSLNK_MAX];
T_SEGEST_SOLVENCY Ktbd_Segest[NB_SEGEST_MAX]; 	/* tableau permettant de charger en memoire FSEGEST */

int Kn_NbLigTrslnk;     /* nombre de postes dans le tableau */
int Kn_NbLig_Segest;   /* nombre de postes dans le tableau */

int n_InitPerUw            ( T_RUPTURE_VAR  *pbd_Rupt );
int n_TestRupturePER       (char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionFistRupturePER (char **pbd_InRec_Cur);  
int n_ActionLignePER			 ( char **pbd_InRec_Cur );
int n_ActionLastRupturePER (char **pbd_InRec_Cur);
int n_InitDlGtaa		      ( T_RUPTURE_SYNC_VAR *pbd_Rupt );
int n_ActionLigneDlGtaa    ( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ConditionSyncDlGtaa  ( char **pbd_InRecOwner, char **pbd_InRecChild );

//[41] 
int n_ActionPereSansFilsDlGtaa(char **ptsz_LigneMaitre);

// [11]
T_RUPTURE_SYNC_VAR  bd_RuptUprDac; /* variable de gestion de la synchronisation avec le fichier UPR_DAC_PRM_COMM */
int n_InitUprDac		   ( T_RUPTURE_SYNC_VAR *pbd_Rupt );
int n_ActionLigneUprDac    ( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ConditionSyncUprDac  ( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ActionPereSansFilsUprDac(char **ptsz_LigneMaitre);


int n_ProcessingRuptureSyncVar (T_RUPTURE_SYNC_VAR  *pbd_Rupt, char **pbd_InRecOwner );



int n_ChargerTSEGEST  ( void ) ;
int n_RechPosteTSEGEST( char c_ssd, char *sz_seg, int n_uwy , char * sz_segtyps  ) ;   // [10] IFRS17 req 10.6
void n_EcrireLog();  // sortie de la log FUTURES

int n_InitVariables( void ) ;

int n_ChargerFBOTRSLNK();                        //[11]
int n_check_trncd_cf(char *sz_TrnCd, int *);            //[11]
int n_EcrireGTremaining( char **pbd_InRec_Cur , char *CTR_NF, double d_Montant, char *account , char *cancel_account ); //[11]

int n_remaining_amounts( char **pbd_InRec_Cur );
FILE *Kp_FBOTRSLNK;                              //[11]
FILE *Kp_OutputFilGtRest ;		                 //[11]	/* pointeur sur le fichier de sortie GT des estimations restantes "non acquises" */
int Kn_FBOTRSLNK ;                               //[11]
T_FBOTRSLNK Ktbd_FBOTRSLNK[Kn_MaxLigFBOTRSLNK];  //[11]
int n_type_trn_cd;                               //[11]
char Ksz_CloDat[10]        ;                     //[11]  			

//[041]                    
char Ksz_Annee_bilan[5]    ;                     
char Ksz_Mois_bilan[3]     ;                     
char Ksz_Jour_bilan[3]     ;
char ksz_message[200];

char Ksz_gte_esb_cf[5]     ;                     //[11]
char Ksz_PerCedNf[50]      ;                     //[11]
char Ksz_PerPrdNf[50]      ;                     //[11]
char Ksz_PerGenPrmPayNf[50];                     //[11]
char Ksz_PerGanPayOrdNt[50];                     //[11]   
double  Kd_Prmrest ;    /* montant des estimations de primes restantes "non acquises "      [11] */ 
double  Kd_Commrest;    /* montant des estimations de commission restantes "non acquises"   [11] */
double  Kd_UPR;         // [11]
double  Kd_DAC;         // [11]
double  Kd_PRME;
double  Kd_COME;
char   c_UPR_FLG;       // [11]
char   c_DAC_FLG;       // [11]
char   c_PRME_FLG;        
char   c_COME_FLG;        

// Variable Splitees Kd_DAC et Kd_COME correspondent au FIXED
double  Kd_DACVAR; // DAC Variable
double  Kd_DACBRK; // DAC Brokerage
double  Kd_COMEVAR; // Commissions Estimates Variable
double  Kd_COMEBRK; // Commmissions Estimates Brokerage
char   c_DACVAR_FLG;
char   c_DACBRK_FLG;
char   c_COMEVAR_FLG;
char   c_COMEBRK_FLG;

int    kn_est_ITDP ;    // Permet de differencier les ITDP des PRME




char   kc_FlagAcc = 'N';
char   kc_FlagPNAseul = 'N';
char   kc_TRTNP_BILAN = 'N'; 	 //quand TRTNP et année de souscription supèrieure à date bilan -2
double kd_AmtcPRM;             // Montant ITDPREMIUM sauvegarde
double kd_AmtcPNA;             // Montant PNA sauvegarde
double kd_AmtcPRT;             // Montant Correspondant à la prime Porte Feuille [06]
int    kn_MIN_ICLODAT_A; //date bilan -2 (dans le ESID2003)

//[041]
char  Ksz_NORME[5] ;       //  NORME : 'EBS' ; 'IFRS' ; 'I17G' ; 'I17L' ; 'I17P' 
char  Kc_Norme_Suf[1] ; // = 'Z';  // SUFFICE DE LA Norme pour construire le TRNCOD des FUTURES AT INCEPTION (Kc_Norme_Suf : GROUP --> 'I' ; PARENT --> 'P' ; LOCAL --> 'M')


double Kd_PrmAmt ;			// Montant Future Premium
double Kd_FuturCharge;  // Montant Future Charge Fixe
double Kd_Claim_Amt ;	  // Montant Future Claims
double Kd_PrmVarAmt;    // Montant Future Variable Premium
double k_TCom ;         // Taux de commission //[027]
double Kd_FuturBrk;     //

extern int Ksz_Argc ;


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
	InitSig ();
	

	if ( n_BeginPgm ( argc, argv ) == ERR )
		ExitPgm( ERR_XX , "" );

	printf("Running with %s  \n", VERSION_ESTC1065_C);
	


  if (Ksz_Argc == 3)
  { 
 
  	  strcpy(Ksz_NORME, psz_GetCharArgv(3));
  	  printf("NB_ARGUMENT 03 RECUP Ksz_Argc %d Ksz_NORME = %s\n", Ksz_Argc, Ksz_NORME);   	  
  }
  else
  { 
  	  strcpy(Ksz_NORME, "EBS");
  	  printf("NB_ARGUMENT Classique RECUP Ksz_Argc %d Kn_NORME %s\n", Ksz_Argc, Ksz_NORME);   	  
  }

	
	kn_MIN_ICLODAT_A = atoi(psz_GetCharArgv(1));
    strcpy( Ksz_CloDat, psz_GetCharArgv(2) ) ;
     	 	
	
	
	/* Determination du Suffice pour les TRNCOD Des Future At INCEPTION */ // strncmp(Ksz_NORME, "I17G", 4) == 0) 	
	
	if ( strncmp(Ksz_NORME, "I17G", 4) == 0) 
		strcpy(Kc_Norme_Suf, "I"); //Kc_Norme_Suf = 'I';  
	if ( strncmp(Ksz_NORME, "I17P", 4) == 0)  
		strcpy(Kc_Norme_Suf, "K"); //Kc_Norme_Suf = 'K';		
	if ( strncmp(Ksz_NORME, "I17L", 4) == 0) 
		strcpy(Kc_Norme_Suf, "M"); //Kc_Norme_Suf = 'M' ;  		    

  
	
	/* ouverture du fichier en entree des postes cumuls FTRSLNK */
	if ( n_OpenFileAppl ( "ESTC1065_I3","rb",&Kp_InputFilTrsLnk ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* ouverture du fichier en entree des cours de change FCURQUOT */
	if ( n_OpenFileAppl ( "ESTC1065_I4","rb",&Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* ouverture du fichier en entree FSEGEST */
	if ( n_OpenFileAppl ( "ESTC1065_I5","rb",&Kp_InputFilSegest ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* [11] ouverture du fichier en entree FBOTRSLNK */
    if (n_OpenFileAppl("ESTC1065_I6", "rb", &Kp_FBOTRSLNK) == ERR )
        ExitPgm(ERR_XX ,"cannot open Kp_FBOTRSLNK ");
        
	
	//[013] DEB REQ10.4 REQ10.5

	//[013] FIN REQ10.4 REQ10.5	        
	
	/* ouverture du fichier de sortie des resultats par affaire */
	if ( n_OpenFileAppl ( "ESTC1065_O1","wt",&Kp_OutputFilResSii ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* ouverture du fichier de sortie des resultats par affaire */
	if ( n_OpenFileAppl ( "ESTC1065_O2","wt",&Kp_OutputFilResSiiAno ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* ouverture du fichier de sortie des logs */
	if ( n_OpenFileAppl ( "ESTC1065_O3","wt",&p_OutputFutures ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	/* ouverture du fichier de sortie des GT des estimations restantes */
    if ( n_OpenFileAppl ( "ESTC1065_O4","wt",&Kp_OutputFilGtRest ) == ERR )
        ExitPgm( ERR_XX , "" ) ;

    /* Chargement du tableau TRSLNK pour les postes 750 */       //[11]
    Kn_FBOTRSLNK = n_ChargerFBOTRSLNK();                         //[11]
    if ( Kn_FBOTRSLNK == -1 )                                    //[11]
    		ExitPgm( ERR_XX , "Taille tableau FBOTRSLNK insuffisante " ) ; //[11]
		
		
	pFutures = (T_FUTURES *) calloc(1,sizeof(T_FUTURES)); 

	/* Initialisation de la variable bd_RuptPerUw */
	if ( n_InitPerUw( &bd_RuptPerUw ) )
		ExitPgm( ERR_XX , "" );

	/* Initialisation de la variable FLOARAT */
	if ( n_InitLoaRat( &bd_RuptLoaRat ) )
		ExitPgm( ERR_XX , "" );	
		
		
  /* Initialisation de la variable bd_RuptPrmLoa */
  if ( n_InitPrmLoa( &bd_RuptPrmLoa ) )
    ExitPgm( ERR_XX , "" ) ;		

	/* Initialisation de la variable bd_RuptDlGtaa */
	if ( n_InitDlGtaa( &bd_RuptDlGtaa ) )
		ExitPgm( ERR_XX , "" );

	// [11]
	/* Initialisation de la variable bd_RuptUprDac */
	if ( n_InitUprDac( &bd_RuptUprDac ) )
		ExitPgm( ERR_XX , "" );
	
	
	
	

	if ( Kn_NbLigTrslnk > NB_TRSLNK_MAX )
		ExitPgm( ERR_XX , "" );


	/* Chargement de TSEGEST en memoire */
	Kn_NbLig_Segest = n_ChargerTSEGEST( ) ;

		
	if ( Kn_NbLig_Segest > NB_SEGEST_MAX )
		ExitPgm( ERR_XX , "" );

	/* Initialisation de la variable bd_RuptPerFr */
	if ( n_InitPerFr( &bd_RuptPerFr ) ) 
		ExitPgm( ERR_XX , "" ) ; 

	/* Initialisation de la variable bd_RuptPerFci */
	if ( n_InitPerFci( &bd_RuptPerFci ) )
		ExitPgm( ERR_XX , "" ) ;

	/* lancement du traitement du fichier Perimetre de souscription IADPERICASE.dat */
	if ( n_ProcessingRuptureVar( &bd_RuptPerUw ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1065_I1", &( bd_RuptPerUw.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1065_I2", &( bd_RuptDlGtaa.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1065_I3", &Kp_InputFilTrsLnk ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1065_I4", &Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1065_I5", &Kp_InputFilSegest ) == ERR )
		ExitPgm( ERR_XX , "" );

	//[11] close 2 inputs files
	if ( n_CloseFileAppl( "ESTC1065_I6", &Kp_FBOTRSLNK ) == ERR )
		ExitPgm( ERR_XX , "" );	

	//[013]

	if ( n_CloseFileAppl( "ESTC1065_I7", &( bd_RuptPrmLoa.pf_InputFil) ) == ERR )
		ExitPgm( ERR_XX , "" );	
		
	if ( n_CloseFileAppl( "ESTC1065_I8", &( bd_RuptPerFr.pf_InputFil) ) == ERR )
		ExitPgm( ERR_XX , "" );		

	//[013]			

	if ( n_CloseFileAppl( "ESTC1065_I9", &( bd_RuptUprDac.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );		
		
	if ( n_CloseFileAppl( "ESTC1065_I10", &( bd_RuptLoaRat.pf_InputFil) ) == ERR )
		ExitPgm( ERR_XX , "" );	
				
	if ( n_CloseFileAppl( "ESTC1065_I11", &( bd_RuptPerFci.pf_InputFil) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;
							
	if ( n_CloseFileAppl( "ESTC1065_O1", &Kp_OutputFilResSii ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1065_O2", &Kp_OutputFilResSiiAno ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESTC1065_O3", &p_OutputFutures ) == ERR )
		ExitPgm( ERR_XX , "" );

	// [11]
	if ( n_CloseFileAppl( "ESTC1065_O4", &Kp_OutputFilGtRest ) == ERR )
        ExitPgm( ERR_XX , "" ) ;
	
	if ( n_EndPgm() == ERR )
		ExitPgm( ERR_XX , "" );

	exit(OK);
}


/*==============================================================================
objet :
	fonction d'initialisation de la variable de gestion de rupture du fichier
	maitre.

retour :
	0K
==============================================================================*/
int n_InitPerUw(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitPerUw" );

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) );

	/* ouverture du fichier maitre Perimetre de souscription */
	if ( n_OpenFileAppl( "ESTC1065_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR;

	pbd_Rupt->n_NbRupture = 1;

   pbd_Rupt->n_ConditionRupture[0]=n_TestRupturePER;
   pbd_Rupt->n_ActionFirst[0]=n_ActionFistRupturePER;
   
   pbd_Rupt->n_ActionLigne=n_ActionLignePER;   
   
	/* Fonction lancee en rupture derniere */
	pbd_Rupt->n_ActionLast[0] = n_ActionLastRupturePER ;   

	pbd_Rupt->c_Separ = '~';

	RETURN_VAL( OK );
}

/*==============================================================================
objet :
	fonction lancée à la rupture sur le fichier maître

retour :
	0 ---> pas de rupture
	1 ---> rupture
==============================================================================*/
int n_TestRupturePER(
   char *ptsz_LigneSuiv[],
   char *ptsz_LigneCour[]
)
{
  DEBUT_FCT("n_TestRupturePER");

	if (strcmp(ptsz_LigneSuiv[PER_CTR_NF], ptsz_LigneCour[PER_CTR_NF])!=0) return(1);
	if (strcmp(ptsz_LigneSuiv[PER_END_NT], ptsz_LigneCour[PER_END_NT])!=0) return(1);
	if (strcmp(ptsz_LigneSuiv[PER_SEC_NF], ptsz_LigneCour[PER_SEC_NF])!=0) return(1);
	if (strcmp(ptsz_LigneSuiv[PER_UWY_NF], ptsz_LigneCour[PER_UWY_NF])!=0) return(1);
	if (strcmp(ptsz_LigneSuiv[PER_UW_NT], ptsz_LigneCour[PER_UW_NT])!=0) return(1);

	return( 0 );
}

/*==============================================================================
objet : fonction lancée à la rupture première sur le fichier maître

retour :
	OK ---> traitement correctement effectué
	ERR --> problème rencontré
==============================================================================*/
int n_ActionFistRupturePER(char **pbd_InRec_Cur)
{
	DEBUT_FCT("n_ActionFistRupturePER");

	kc_FlagAcc = 'N';
	
	  c_UPR_FLG = 'N';       // [11]
    c_DAC_FLG = 'N';       // [11]
    Kd_UPR = 0.0;          // [11]
    Kd_DAC = 0.0;          // [11]
    c_COME_FLG = 'N';
    c_PRME_FLG = 'N';
    Kd_PRME = 0.0 ;
    Kd_COME = 0.0 ;
	  Kd_Prmrest = 0.0 ;    /* montant des estimations de primes restantes "non acquises "      [11] */ 
    Kd_Commrest = 0.0;    /* montant des estimations de commission restantes "non acquises"   [11] */
    
    kn_est_ITDP = 0 ;    // Variable de calcul de l'ITD Premium 
    
    //REQ 10.13
    Kd_DACVAR = 0.0 ;
    Kd_DACBRK = 0.0 ;
    Kd_COMEVAR = 0.0 ;
    Kd_COMEBRK = 0.0 ;
    c_DACVAR_FLG = 'N';
    c_DACBRK_FLG = 'N';
    c_COMEVAR_FLG = 'N';
    c_COMEBRK_FLG = 'N';


		n_InitVariables( ) ;

	kc_TRTNP_BILAN = 'N'; //quand TRTNP et année de souscription supèrieure à date bilan -2
	if (atoi(pbd_InRec_Cur[PER_UWY_NF]) > kn_MIN_ICLODAT_A && pbd_InRec_Cur[PER_CTRNAT_CT][0] == 'N')
		kc_TRTNP_BILAN = 'Y';
		
		
	/* initialisation du tableau Ktbd_Par et du nombre de postes */
	memset( Ktbd_Par, 0, sizeof( T_TabPart ) * NB_PAR_MAX) ;
	Kn_Par_Nbp = NB_PAR_MAX - 1 ;

	// initialisation du tableau Ktbd_EstGt 
	memset( Ktbd_EstGt, 0, sizeof( T_ESTGT ) * NB_PAR_MAX) ; 

	// initialisation du tableau Ktn_FamUwy et du compteur de postes
	memset( Ktn_FamUwy, 0, sizeof( short ) * NB_UWY_MAX) ;
	Kn_Fam_Nbl = NB_UWY_MAX - 1 ;


  //[013]
	/* synchronisation avec le fichier annexe Perimetre de souscription */
	n_ProcessingRuptureSyncVar( &bd_RuptPerFr, pbd_InRec_Cur ) ;

  //[021]
	n_ProcessingRuptureSyncVar( &bd_RuptUprDac, pbd_InRec_Cur );


         n_remaining_amounts(pbd_InRec_Cur);
  

	//[013
	/* synchronisation avec le fichier des Primes  */
	n_ProcessingRuptureSyncVar( &bd_RuptPrmLoa, pbd_InRec_Cur ) ;

	//[013
	/* synchronisation avec le fichier des taux de charges */
	n_ProcessingRuptureSyncVar( &bd_RuptLoaRat, pbd_InRec_Cur ) ;
	
	
	n_ProcessingRuptureSyncVar( &bd_RuptDlGtaa, pbd_InRec_Cur );		

	return OK ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePER( char **pbd_InRec_Cur )
{

	DEBUT_FCT( "n_ActionLignePER" ) ;

	/* synchronisation avec le fichier annexe famille des charges iterees */
	n_ProcessingRuptureSyncVar( &bd_RuptPerFci, pbd_InRec_Cur ) ;
 		
  
	RETURN_VAL( OK ) ;
}




/*==============================================================================
objet :
	fonction lancee en rupture derniere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRupturePER( char **pbd_InRec_Cur  )
{

	char	MsgAno[300] ; 	/* message d'anomalie */

	DEBUT_FCT( "n_ActionLastRupturePER" ) ;


	/****************************************************************************/
	/* tests de depassement de tableau et generation d'anomalies eventuellement */
	/****************************************************************************/


	/* tableaux des participations Ktbd_Par et Ktbd_EstGt */
	if ( Kn_Par_Nbp < 0 )
	{
		sprintf(MsgAno,  "The participation records number for the contract ( CTR %s /END %s /SEC %s ) overflows the program memory capacity",
			pbd_InRec_Cur[PER_CTR_NF], pbd_InRec_Cur[PER_END_NT], pbd_InRec_Cur[PER_SEC_NF] ) ;

		RETURN_VAL ( OK ) ;
	}

	/* tableaux des familles de charges iterees Ktbd_FamCha_02 et Ktn_FamUwy */
	if ( Kn_Fam_Nbp < 0 )
	{
		sprintf(MsgAno,"The underwriting year number for the contract ( CTR %s /END %s /SEC %s ) overflows the program memory capacity",
			pbd_InRec_Cur[PER_CTR_NF], pbd_InRec_Cur[PER_END_NT], pbd_InRec_Cur[PER_SEC_NF] ) ;

		RETURN_VAL ( OK ) ;
	}

	/* tableau des familles de charges iterees Ktbd_FamCha_02 */
	if ( Kn_Fam_Nbp >= NB_FAM_MAX )
	{
		sprintf(MsgAno,"The reiterated charges families number for the contract ( CTR %s /END %s /SEC %s ) overflows the program memory capacity",
			pbd_InRec_Cur[PER_CTR_NF], pbd_InRec_Cur[PER_END_NT], pbd_InRec_Cur[PER_SEC_NF] ) ;

		RETURN_VAL ( OK ) ;
	}


	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription »
	avec l’esclave « DTSTATGTXX »

retour :
	OK
==============================================================================*/
int n_InitDlGtaa( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitDlGtaa" );

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) );

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC1065_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncDlGtaa;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneDlGtaa;
	
	/* fonction d'action pere sans fils --> CALCUL AT INCEPTION Uniquement si NORME est soit I17G, I17P, ou I17L*/ 
		
	//printf("DANS n_InitDlGtaa Ksz_NORME =%s \n", Ksz_NORME);	
		
	if (strcmp(Ksz_NORME, "I17G") ==0 || strcmp(Ksz_NORME, "I17P") == 0 || strcmp(Ksz_NORME, "I17L") == 0 ) 
	{ 		
			pbd_Rupt->n_PereSansFils = n_ActionPereSansFilsDlGtaa;
	}

	pbd_Rupt->c_Separ = '~';

	RETURN_VAL( OK );
}

// [11] new function n_InitUprDac

/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription »
	avec l’esclave « UPRDAC »

retour :
	OK
==============================================================================*/
int n_InitUprDac( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitUprDac" );

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) );

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC1065_I9", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncUprDac;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneUprDac;
	
	pbd_Rupt->n_PereSansFils=n_ActionPereSansFilsUprDac;

	pbd_Rupt->c_Separ = '~';

	RETURN_VAL( OK );
}

// [11] new function n_ConditionSyncUprDac

/*==============================================================================
objet :
	fonction de test de synchronisation

retour :
	0	---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
	> 0   	---> pbd_InRecOwne> > pbd_InRecChild
	< 0   	---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncUprDac(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret;

	DEBUT_FCT( "n_ConditionSyncUprDac" );

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GT_END_NT] ) ) != 0 ) return ret;
        if ( ( ret = atoi( pbd_InRecOwner[PER_SEC_NF] ) - atoi( pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GT_UW_NT] ) ) != 0 ) return ret;

	RETURN_VAL( 0 );
}



// [11] function n_ActionPereSansFilsUprDac
/**************************************************************************/
/*** Objet : fonction lancee quand aucune ligne du fichier UPR_DAC_PRM_COMM      ***/
/***         ne correspond a la ligne courante du fichier maitre           ***/
/***                                                                    ***/
/*** Nom : n_ActionPereSansFilsUprDac                           ***/
/***                                                                    ***/
/*** Parametres:                                                        ***/
/***    i ptsz_LigneMaitre  : pointeur sur la ligne du maitre           ***/
/***                                                                    ***/
/*** Retour:                                                            ***/
/***    OK si pas d'erreur,                                             ***/
/***    ERR si erreur.                                                  ***/
/**************************************************************************/

int n_ActionPereSansFilsUprDac(char *ptsz_LigneMaitre[])
{
  DEBUT_FCT("n_ActionPereSansFilsUprDac");

  c_UPR_FLG = 'N';       
  c_DAC_FLG = 'N';       
  c_PRME_FLG = 'N';       
  c_COME_FLG = 'N';
  
  Kd_UPR = 0.0;
  Kd_DAC = 0.0;
  Kd_PRME = 0.0;
  Kd_COME = 0.0;

  // REQ 10.13
  c_DACVAR_FLG = 'N';
  c_DACBRK_FLG = 'N';
  c_COMEVAR_FLG = 'N';
  c_COMEBRK_FLG = 'N';
  Kd_DACVAR = 0.0;
  Kd_DACBRK = 0.0;
  Kd_COMEVAR = 0.0;
  Kd_COMEBRK = 0.0;

  RETURN_VAL(OK);
}




/*==============================================================================
objet :
	fonction de test de synchronisation

retour :
	0	---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
	> 0   	---> pbd_InRecOwne> > pbd_InRecChild
	< 0   	---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncDlGtaa(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret;

	DEBUT_FCT( "n_ConditionSyncDlGtaa" );

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GT_END_NT] ) ) != 0 ) return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GT_UW_NT] ) ) != 0 ) return ret;

//	if ( strcmp(pbd_InRecChild[GT_ORICOD_LS], "EBSACC") == 0 )
//printf("--> n_ConditionSyncDlGtaa -- CTR_NF : %s - UWY_NF : %s - sec %s\n",pbd_InRecOwner[PER_CTR_NF],pbd_InRecOwner[PER_UWY_NF],pbd_InRecOwner[PER_SEC_NF]);

	RETURN_VAL( 0 );
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneDlGtaa(
	char **pbd_InRecOwner , /* adresse de la ligne du maitre */
	char **pbd_InRecChild ) /* adresse de la ligne de l'esclave */
{

	char   sz_Trncod[9];
	char   sz_Dblcod[2];
	char   sz_Seg[12];
	char   sz_Amt[21];
	char   sz_Cur[4];
	double d_Amt;
	double d_taux;      // Taux de conversion en devise
	double d_FUTURE_LOSRAT_R;  // [10] Future Loss Ratio
	double d_ResAdj_LOSRAT_R;  // [10] Reserving Adjustment Loss Ratio
  double d_LOSRAT_R ;        // [10] selected Loss Ratio according to many rules 	
  double d_OULR_R ;          // [10] Omega UW Loss Ratio 
	double d_IPLR_R ;          // [10] IFRS17 Priced Loss Ratio
  char   c_PrcFLG_B ;          // [10] xAct/FW IFRS priced flag
	char   c_LR_rule;             // [10] LR calculation rule
	char   MsgAno[300];
	int    n_indice;
	int	 n_Ssd = 0;
	int	 n_Uwy = 0;
	

	double 	d_PbCalAmt = 0 ;	/* montant calcule de PB */
	double  d_PapCalAmt = 0 ;	/* montant calcule de PAP */
	double  d_PbRetAmt = 0 ;	/* montant retenu de PB */
	double  d_PapRetAmt = 0 ;	/* montant retenu de PAP */
	char	sz_PbOriCod[25] ;
	char	sz_PapOriCod[25] ;
	
	int n_PbPap_Nbp, i =0 ;
	
	
	//[013] Variables intermediaires au calcul de d_BC et d_RP
	
	double d_RP = 0; // Resultat du calcul de la prime de reconstitution
	double d_BC = 0; // Resultat du calcul du Burning Cost
	double d_BC_01 = 0; // Calcul brut du Burning Cost
	double        // Future Brokerage
	       //Kd_FuturCharge = 0 ,    // Future Fixed Charge
	       //Kd_FuturVarCharge = 0 , // Future Variable Charge	       
	       Kd_ITDWrittenPrem = 0;  // ITD Written Premium
	       
	double d_CANEGP_M = 0 ;    // [037]

	

	DEBUT_FCT( "n_ActionLigneDlGtaa" );

	memset( sz_Cur, 0, sizeof(sz_Cur) );
	memset( sz_Seg, 0, sizeof(sz_Seg) );

	memset(pFutures, 0 , sizeof (T_FUTURES));// on remet la structure a vide
	
/* [013] Deb Charges Iterees */	

	
	memset( Ktbd_FamCha, 0, ( NB_FAM_MAX * sizeof( T_TabFamCharIt ) ) ) ;
	memset( Ktbd_FamCha_02, 0, ( NB_FAM_MAX * sizeof( T_TabFamCharIt ) ) ) ;

	Kn_NbFam = 0 ;
	Kn_Fam_Nbp = 0;

	/* affectation des postes du tableau Ktbd_EstGt */
	Ktbd_EstGt[Kn_Par_Nbp].UWY_NF = atoi( pbd_InRecOwner[PER_UWY_NF] ) ;
	Ktbd_EstGt[Kn_Par_Nbp].UW_NT = (char)( atoi( pbd_InRecOwner[PER_UW_NT] ) ) ;
	Ktbd_EstGt[Kn_Par_Nbp].SSD_CF = (char)( atoi( pbd_InRecOwner[PER_SSD_CF] ) ) ;
	strcpy( Ktbd_EstGt[Kn_Par_Nbp].DIV_NT, pbd_InRecOwner[PER_DIV_NT] ) ;
	strcpy( Ktbd_EstGt[Kn_Par_Nbp].EGPCUR_CF, pbd_InRecOwner[PER_EGPCUR_CF] ) ;
	Ktbd_EstGt[Kn_Par_Nbp].ACCESB_CF = (char)( atoi( pbd_InRecOwner[PER_ACCESB_CF] ) ) ;
	Ktbd_EstGt[Kn_Par_Nbp].CED_NF = atoi( pbd_InRecOwner[PER_CED_NF] ) ;
	Ktbd_EstGt[Kn_Par_Nbp].PRD_NF = atoi( pbd_InRecOwner[PER_PRD_NF] ) ;
	Ktbd_EstGt[Kn_Par_Nbp].GENPRMPAY_NF = atoi( pbd_InRecOwner[PER_GENPRMPAY_NF] ) ;
	strcpy( Ktbd_EstGt[Kn_Par_Nbp].GANPAYORD_NT, pbd_InRecOwner[PER_GANPAYORD_NT] ) ;
	Ktbd_EstGt[Kn_Par_Nbp].DIFMTH_NF = (char)( atoi( pbd_InRecOwner[PER_DIFMTH_NF] ) ) ;
	Ktbd_EstGt[Kn_Par_Nbp].SEGSA_B = *pbd_InRecOwner[PER_SEGSA_B]; //sinistralité

	/* affectation des postes du tableau des participations */
	Ktbd_Par[Kn_Par_Nbp].UWY_NF = atoi( pbd_InRecOwner[PER_UWY_NF] ) ;
	Ktbd_Par[Kn_Par_Nbp].CTCOM_B = (char)( atoi( pbd_InRecOwner[PER_CTBCOM_B] ) ) ;
	Ktbd_Par[Kn_Par_Nbp].PRFCOMEXI_B = (char)( atoi( pbd_InRecOwner[PER_PRFCOMEXI_B] ) ) ;
	Ktbd_Par[Kn_Par_Nbp].LOSCTBEXI_B = (char)( atoi( pbd_InRecOwner[PER_LOSCTBEXI_B] ) ) ;
	Ktbd_Par[Kn_Par_Nbp].CTBTYP_CT = (char)( atoi( pbd_InRecOwner[PER_CTBTYP_CT] ) ) ;
	Ktbd_Par[Kn_Par_Nbp].PRFCOM_R = atof( pbd_InRecOwner[PER_PRFCOM_R] ) ;
	Ktbd_Par[Kn_Par_Nbp].LOSCTB_R = atof( pbd_InRecOwner[PER_LOSCTB_R] ) ;
	Ktbd_Par[Kn_Par_Nbp].CTBGENFEE_R = atof( pbd_InRecOwner[PER_CTBGENFEE_R] ) ;
	Ktbd_Par[Kn_Par_Nbp].RESTRFTYP_CF = (char)( atoi( pbd_InRecOwner[PER_RESTRFTYP_CF] ) ) ;
	Ktbd_Par[Kn_Par_Nbp].RESTRFDUR_N = (char)( atoi( pbd_InRecOwner[PER_RESTRFDUR_N] ) ) ;
  Ktbd_Par[Kn_Par_Nbp].SSD_CF = (char)( atoi( pbd_InRecOwner[PER_SSD_CF] ) ) ;
  strcpy( Ktbd_Par[Kn_Par_Nbp].EGPCUR_CF, pbd_InRecOwner[PER_EGPCUR_CF] ) ;

  Ktbd_Par[Kn_Par_Nbp].SECACCSTS_CT = (char)( atoi( pbd_InRecOwner[PER_SECACCSTS_CT] ) ) ;

	/* valeur par defaut si le fichier des estimations dommages ne participe pas */
	Ktbd_EstGt[Kn_Par_Nbp].LOSADMMOD_CT = 'A' ; /* mode de gestion par defaut */
	Ktbd_EstGt[Kn_Par_Nbp].LOSENTAMT_M = 0 ; /* montant manuel par defaut */
	Ktbd_EstGt[Kn_Par_Nbp].PBADMMOD_CT = 'A' ; /* mode de gestion par defaut */
	Ktbd_EstGt[Kn_Par_Nbp].PBENTAMT_M = 0 ; /* montant manuel par defaut */
	Ktbd_EstGt[Kn_Par_Nbp].PAPADMMOD_CT = 'A' ; /* mode de gestion par defaut */
	Ktbd_EstGt[Kn_Par_Nbp].PAPENTAMT_M = 0 ; /* montant manuel par defaut */	
	
	Ktn_FamUwy[Kn_Fam_Nbl] = Kn_Fam_Nbp ;	
	
/* [013] Fin Charges Iteres */	
	
// Alimentation de la structure 
//
	pFutures->SSD_CF= atoi(pbd_InRecChild[GT_SSD_CF]);
	pFutures->ESB_CF= atoi(pbd_InRecChild[GT_ESB_CF]); 
	pFutures->END_NT= atoi(pbd_InRecChild[GT_END_NT]); 
	pFutures->SEC_NF= atoi(pbd_InRecChild[GT_SEC_NF]); 
	pFutures->UWY_NF= atoi(pbd_InRecChild[GT_UWY_NF]); 

	pFutures->CTR_NF= pbd_InRecChild[GT_CTR_NF];
	pFutures->SEG_NF= pbd_InRecChild[GT_SEG_NF];
	pFutures->SCOEGP_M= atof(pbd_InRecChild[GT_SCOEGP_M]); 



		n_type_trn_cd = n_check_trncd_cf(pbd_InRecChild[GT_TRNCOD_CF], &kn_est_ITDP );

#ifdef TRACE_2		
		if ( n_type_trn_cd != OTHER)
			printf("\n DAns n_ActionLigneDlGtaa trn_cd = %s type %d ctr=%s  ; kn_est_ITDP[%d]", pbd_InRecChild[GT_TRNCOD_CF], n_type_trn_cd , pbd_InRecChild[GT_CTR_NF], kn_est_ITDP  ); 
#endif

		
		// [013] Recherche de l'ITD Written Premium 
	if ( kn_est_ITDP == ITDP) // &&  == 'Y')   (n_type_trn_cd == ITDP)
	{		
  
			//printf("\n TESTS ITD PREMIUM trn_cd = %s ; Kd_ITDWrittenPrem_BRUTE [%lf] ; type %d ctr=%s ", pbd_InRecChild[GT_TRNCOD_CF], atof(pbd_InRecChild[GT_AMT_M]), n_type_trn_cd , pbd_InRecChild[GT_CTR_NF]  ); 			
		
			Kd_ITDWrittenPrem = fabs( atof(pbd_InRecChild[GT_AMT_M])) ;
	}
	
		
		
	strcpy( sz_Dblcod, "" );
	//en cas de TRT NON PROPRE ne pas tenir compte du EBSACC quand l'année de souscription est supèrieure à la date de bilan -2
	if ( (strcmp(pbd_InRecChild[GT_ORICOD_LS], "EBSACC") == 0 || kc_TRTNP_BILAN == 'Y' || fabs(Kd_UPR) > 0.1 ) && kc_FlagAcc == 'N')
	{
		if (pbd_InRecOwner[PER_SECACCSTS_CT][0] == '9' && kc_TRTNP_BILAN == 'Y')
			kc_FlagAcc = 'N';
		else
			kc_FlagAcc = 'Y';

		if (strcmp(pbd_InRecOwner[PER_CTRNAT_CT], "N")==0) 
			kc_FlagPNAseul = 'N';// forcer le flag à non pour les traités non prop
		else 
			kc_FlagPNAseul = (atof(pbd_InRecChild[GT_AMT_M]) - atof(pbd_InRecChild[GT_RETAMT_M]) == 0 ? 'Y' : 'N' );

		kd_AmtcPNA = 0;
		kd_AmtcPRM = 0;
		kd_AmtcPRT = 0;        //[06]
		
		Kd_PrmAmt = 0;				// Future Fixe Premium
		Kd_PrmVarAmt = 0;			// Future Variable Premium
		Kd_Claim_Amt = 0;			// Future Claim
	  k_TCom = 0 ;       	// Commission Rate	  //[027]
	  Kd_FuturBrk = 0;
	  Kd_FuturCharge = 0 ;
	  	
	}
	if (strcmp(pbd_InRecChild[GT_ORICOD_LS], "EBSACC") != 0)
	{
		if ( kc_FlagAcc == 'N' ) RETURN_VAL( OK );

		n_Ssd = (char) atoi( pbd_InRecOwner[PER_SSD_CF] );
		n_Uwy = atoi( pbd_InRecOwner[PER_UWY_NF] );
		strcpy(sz_Seg, pbd_InRecOwner[PER_SEG_NF]);

		
		
     //************************  LOSS RATIO SELECTION RULES [10] JYP IFRS17 req 10.6 ************************************//
     //**                                                                                                              **//
     //**     	                                                                                                       **//

	 
	 //****** 1) recherche du Loss Ratio des FUTURES    *******************************************/
	 
	    if ( (n_indice = n_RechPosteTSEGEST(n_Ssd, sz_Seg, n_Uwy, "ATU" ) ) == -1 )
		{
			if ( (n_indice = n_RechPosteTSEGEST(n_Ssd, "*", n_Uwy, "ATU") ) == -1 )
			{
				// Pas de segment en synchro
				pbd_InRecChild[GT_ORICOD_LS] = "PAS_SYNCHRO_SEG ATU";
				n_WriteCols( Kp_OutputFilResSiiAno, pbd_InRecChild, SEPARATEUR, 0 );
				// RETURN_VAL( OK );  [001]
			}
		}
		// [001]
		if (n_indice == -1) d_FUTURE_LOSRAT_R = 0;
		else d_FUTURE_LOSRAT_R = Ktbd_Segest[n_indice].LOSRAT_R;
		



     //***** 2) recherche du Reserving Adjustment Loss Ratio  ***************************************/
	  
		if ( (n_indice = n_RechPosteTSEGEST(n_Ssd, sz_Seg, n_Uwy, "VWX") ) == -1 )
		{
			if ( (n_indice = n_RechPosteTSEGEST(n_Ssd, "*", n_Uwy,"VWX") ) == -1 )
			{
				// Pas de segment en synchro
				pbd_InRecChild[GT_ORICOD_LS] = "PAS_SYNCHRO_SEG VWX";
				n_WriteCols( Kp_OutputFilResSiiAno, pbd_InRecChild, SEPARATEUR, 0 );
				// RETURN_VAL( OK );  [001]
			}
		}
		// [001]
		if (n_indice == -1) d_ResAdj_LOSRAT_R = 0;
		else d_ResAdj_LOSRAT_R = Ktbd_Segest[n_indice].LOSRAT_R;
		


		
		
     //***** 3) recherche du Omega UW Loss Ratio  ***************************************************/
	
	   d_OULR_R =  atof(pbd_InRecOwner[PER_PMLRAT_R]) ;
	  

      //***** 4) recherche du IFRS17 Priced Loss Ratio  ********************************************/


	 c_PrcFLG_B = '0';
	 if (pbd_InRecOwner[PER_PRC_FLG_CT] != NULL)
	 {
		 	if (pbd_InRecOwner[PER_PRC_FLG_CT][0] != '\0') 
		       c_PrcFLG_B = pbd_InRecOwner[PER_PRC_FLG_CT][0];	   	  	 
	 }

	 d_IPLR_R =  atof(pbd_InRecOwner[PER_IPLR_R]) ;

	   
	  //***** 5) RULES : choix du Loss Ratio  ********************************************/

	   
       if (c_PrcFLG_B == '1' )
	   {
		   c_LR_rule = '1';
		   d_LOSRAT_R = d_IPLR_R + d_ResAdj_LOSRAT_R ;
	   }
	   else if ( strcmp(pbd_InRecOwner[PER_CTRNAT_CT],"P") == 0   )
	   {
		   c_LR_rule = '2' ;
	       d_LOSRAT_R =  d_OULR_R + d_ResAdj_LOSRAT_R ;
	   }
	   else if ( d_FUTURE_LOSRAT_R > 0   )
	   {
		   c_LR_rule = '3' ; 
	       d_LOSRAT_R = d_FUTURE_LOSRAT_R ;
	   }
       else 
	   { 
		   c_LR_rule = '4' ;
	       d_LOSRAT_R = 0.0	;   
	   }


		pFutures->LOSRAT_R = d_LOSRAT_R ;

	
     //**                                                                                                              **//
     //**     	                                                                                                       **//		
     //************************   recherche du Loss Ratio des FUTURES : [10] JYP IFRS17 req 10.6 ************************//

		
/* // debug
   if (strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0000778") == 0)
{ */

		/* Recherche taux pour conversion du montant acceptation en devise aliment */
		d_taux = 1;

		sprintf( sz_Cur, "%s", pbd_InRecOwner[PER_EGPCUR_CF] );
		if ( strcmp( pbd_InRecChild[GT_CUR_CF], pbd_InRecOwner[PER_EGPCUR_CF] ) != 0 )
		{
			sprintf( sz_Cur, "%s", pbd_InRecOwner[PER_EGPCUR_CF] );
			d_taux = d_GetTaux( Kp_InputFilExc, (char) atoi( pbd_InRecChild[GT_SSD_CF] ), atoi( pbd_InRecChild[GT_BALSHEY_NF] ), pbd_InRecChild[GT_CUR_CF], pbd_InRecOwner[PER_EGPCUR_CF] );
		}

		/* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
		if ( d_taux < 0 )
		{
			sprintf( MsgAno, "The rates of acceptation currency ( %s ) and EGPI currency ( %s ) aren't known for the perimeter contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) and BALSHEY %s \n", pbd_InRecChild[GT_CUR_CF], pbd_InRecOwner[PER_EGPCUR_CF], pbd_InRecChild[GT_CTR_NF],  pbd_InRecChild[GT_END_NT], pbd_InRecChild[GT_SEC_NF], pbd_InRecChild[GT_UWY_NF], pbd_InRecChild[GT_UW_NT], pbd_InRecChild[GT_BALSHEY_NF] );
			n_WriteAno( MsgAno );
			/* montant positionne a zero */
			d_Amt = 0;
		}
		else
		{
			// Gestion prime future et sinistre
			//	kd_AmtcPNA =0;
			pFutures->TAUX= d_taux ;
			pFutures->CUR_CF= sz_Cur; 


			if ( strcmp(pbd_InRecChild[GT_TRNCOD_CF], "1A100002") == 0 )
			{
				kd_AmtcPNA = atof(pbd_InRecChild[GT_AMT_M]) * d_taux;
				//pFutures->AMTCPNA = kd_AmtcPNA ;
				pFutures->AMTCPNA= Kd_UPR ;
				
#ifdef TRACE_PNA_VERSUS_UPR				
			//printf(" PNA VERSUS UPR :  pbd_InRecOwner[PER_CTR_NF]%s ; pbd_InRecChild[GT_CTR_NF]%s ; PER_END_NT%s ; PER_SEC_NF%s ; PER_UWY_NF%s ; pbd_InRecChild[GT_UWY_NF][%s] ; pbd_InRecChild[GT_UW_NT][%s] ; pbd_InRecChild[GT_BALSHEY_NF][%s] ; Ancienne VErsion PNA kd_AmtcPNA[%-3.f] ; Version New Kd_UPR =[%-3.f] ; d_taux[%-3.f] \n", pbd_InRecOwner[PER_CTR_NF, pbd_InRecChild[GT_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF],  pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_UW_NT], pbd_InRecChild[GT_BALSHEY_NF], kd_AmtcPNA, Kd_UPR, d_taux );
			printf(" PNA VERSUS UPR : PER_CTR_NF, GT_CTR_NF, PER_END_NT, PER_SEC_NF, PER_UWY_NF , kd_AmtcPNA, Kd_UPR, d_taux : %s ; %s ; %s ; %s ; %s ; %-3.f; %-3.f ; %-3.f \n", pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF],  pbd_InRecOwner[PER_UWY_NF],  kd_AmtcPNA, Kd_UPR, d_taux );			
#endif
			}
			
			
			/* Le TRNCOD 1A110003 Correspond à la prime Porte Feuille "PREMPTF" */
			
      if (strcmp(pbd_InRecChild[GT_TRNCOD_CF], "1A110003") == 0 )
      {
				kd_AmtcPRT = atof(pbd_InRecChild[GT_AMT_M]) * d_taux;    //[06]
      }			
						
			
			if ( strcmp(pbd_InRecChild[GT_TRNCOD_CF], "1A110002") == 0 )  // On revient sur la precedente version :			
			{
				kd_AmtcPRM = atof(pbd_InRecChild[GT_AMT_M]) * d_taux;						
				
				pFutures->AMTCPRM_M = kd_AmtcPRM ;											// ITD Premium

				// Calcul prime future 
				// R02-01 : Future Fixed Premium (10001) = EGPI – ITD Written Premium
			  //[013] Le montant d'estimaion de la Future Premium est 0 dans le cas des FAC.

			 if (pbd_InRecOwner[PER_CANEGP_M] != NULL)
			  	d_CANEGP_M = atof(pbd_InRecOwner[PER_CANEGP_M]) ;
			  
				if (strcmp(pbd_InRecOwner[PER_CTRNAT_CT], "F")==0)
					d_Amt = 0;
				else
				// [037] d_Amt = (atof(pbd_InRecOwner[PER_SCOEGP_M]) + pbd_InRecOwner[PER_CANEGP_M]) - kd_AmtcPRM;  // ajout de CANEGP_M dans le calcul
				d_Amt = (atof(pbd_InRecOwner[PER_SCOEGP_M]) + d_CANEGP_M) - kd_AmtcPRM;  // ajout de CANEGP_M dans le calcul								
				
				sprintf( sz_Amt, "%-.3f", d_Amt );
				strcpy( sz_Trncod, "1A100012" );
			  pFutures->TRNCOD = sz_Trncod;					
				
				Kd_PrmAmt = d_Amt;
				pFutures->FUFPREMIUM = d_Amt;   		// Future Fixe Premium

				pbd_InRecChild[GT_RETAMT_M] = "0";
				pbd_InRecChild[GT_RETINTAMT_M] = "0";
				pbd_InRecChild[GT_TRNCOD_CF] = sz_Trncod;
				pbd_InRecChild[GT_DBLTRNCOD_CF] = sz_Dblcod;
				pbd_InRecChild[GT_AMT_M] = sz_Amt;
				pbd_InRecChild[GT_CUR_CF] = sz_Cur;

#ifdef TRACE_FUTURE_FIXE_PREMIUM							
			printf(" 01 Future Fixe Premium pbd_InRecOwner[PER_CTR_NF][%s] ; pFutures->FUFPREMIUM[%lf] ; Kd_PrmAmt %-3.f ; EGPI_SCOR[%lf] ; Kd_ITDPREMIUM[%lf] ; d_taux[%lf]\n", pbd_InRecOwner[PER_CTR_NF], Kd_PrmAmt, Kd_PrmAmt, atof(pbd_InRecOwner[PER_SCOEGP_M]), atof(pbd_InRecChild[GT_AMT_M]), d_taux );			
#endif	
					
				n_EcrireLog(); 					

				if ( fabs(atof(sz_Amt)) > 1  ) // [030] if ( fabs(atof(sz_Amt)) > 1 && kc_FlagPNAseul == 'N' ) 
				{

#ifdef TRACE_FUTURE_FIXE_PREMIUM							
			printf(" TRACE_FUTURE_FIXE_PREMIUM Future Fixe Premium pbd_InRecOwner[PER_CTR_NF], pbd_InRec_Cur[PER_END_NT], pbd_InRec_Cur[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], GT_TRNCOD_CF, Kd_PrmAmt, EGPI_SCOR, pbd_InRecChild[GT_AMT_M], d_taux, kd_AmtcPRM  : %s ; %s ; %s; %s ; %s ; %-.3f ; %-.3f; %-.3f ; %-.3f ; %-.3f\n", pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF],  pbd_InRecChild[GT_TRNCOD_CF], Kd_PrmAmt, atof(pbd_InRecOwner[PER_SCOEGP_M]), atof(pbd_InRecChild[GT_AMT_M]), d_taux , kd_AmtcPRM);			
#endif
	 					
					n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );
				}
				
				//[014]
				// Calcul Sinistre futur
				/*if ( kc_FlagPNAseul == 'Y' ) d_Amt = 0;
				d_Amt -= kd_AmtcPNA;
				d_Amt *= (d_LOSRAT_R*100) * -1;
				sprintf( sz_Amt, "%-.3f", d_Amt );
				strcpy( sz_Trncod, "1A494302" ); 
				*/
				
				// R03 - 02 : Future Claim calculation rule
				// Future claims = (Future Fixed Premium - UPR) * Selected Loss Ratio
				
				
				// VErsion Avec l'ancien calcul : Utilisation de kd_AmtcPNA à la place de Kd_UPR							
				
				//[042] Ne plus calculer de Future Claims si Future Prime = 0 et UPR = 0. 
				
				if (Kd_PrmAmt == 0 && Kd_UPR ==0)	
						d_Amt = 0 ;
				else					
						d_Amt = (Kd_PrmAmt - Kd_UPR) * d_LOSRAT_R * 100.0 * (-1); //[015] [016] [18]	
				
				//d_Amt = (Kd_PrmAmt - kd_AmtcPNA) * d_LOSRAT_R *100* (-1);		//	[015]	 [016]	[018]					
				
				sprintf( sz_Amt, "%-.3f", d_Amt );
				strcpy( sz_Trncod, "1A494302" );
			  pFutures->TRNCOD = sz_Trncod;						
					
				Kd_Claim_Amt = d_Amt;
				pFutures->FUCLAIM = d_Amt;											// Future Fixed Claims

				pbd_InRecChild[GT_TRNCOD_CF] = sz_Trncod;
				pbd_InRecChild[GT_AMT_M] = sz_Amt;		


                sprintf(ksz_message, "%s %s sec %s %s %s seg:%s: R(ATU)%.6f R(VWX)%.6f: PrcR:%.6f: UwR:%.6f: rule:%c %.6f FLG:%c NAT:%s amts: %.6f %.6f %.6f",
                 pbd_InRecOwner[PER_CTR_NF],pbd_InRecOwner[PER_END_NT],
                 pbd_InRecOwner[PER_SEC_NF] ,pbd_InRecOwner[PER_UWY_NF] ,pbd_InRecOwner[PER_UW_NT] ,
                 sz_Seg , d_FUTURE_LOSRAT_R, d_ResAdj_LOSRAT_R  ,d_IPLR_R,d_OULR_R ,c_LR_rule,d_LOSRAT_R,
                 c_PrcFLG_B,pbd_InRecOwner[PER_CTRNAT_CT], Kd_PrmAmt , Kd_UPR , d_Amt ) ;

        	n_WriteLog('I',ksz_message);




#ifdef TRACE_FUTURE_CLAIMS
      if (strcmp("17T009687", pbd_InRecOwner[PER_CTR_NF]) == 0 && atoi(pbd_InRecOwner[PER_UWY_NF]) == 2018)							
			printf("0000 TRACE_FUTURE_CLAIMS Future Claim calculation pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], GT_TRNCOD_CF, pFutures->FUCLAIM, Kd_Claim_Amt, kd_AmtcPNA Kd_UPR, Kd_PrmAmt, d_LOSRAT_R  %s ;%s; %s; %s ; %s ; %-.3f ; %-.3f ; %-.3f  %f; %-.3f] ; %-.3f\n", pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF],  pbd_InRecChild[GT_TRNCOD_CF],pFutures->FUCLAIM, Kd_Claim_Amt, kd_AmtcPNA, Kd_UPR, Kd_PrmAmt, d_LOSRAT_R);			
#endif
				
				n_EcrireLog(); 				

				if ( fabs(atof(sz_Amt)) > 1)
				{ 
					
#ifdef TRACE_FUTURE_CLAIMS	
      if (strcmp("17T009687", pbd_InRecOwner[PER_CTR_NF]) == 0 && atoi(pbd_InRecOwner[PER_UWY_NF]) == 2018)							
			printf(" TRACE_FUTURE_CLAIMS Future Claim calculation pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], GT_TRNCOD_CF, pFutures->FUCLAIM, Kd_Claim_Amt, kd_AmtcPNA KdUPR, Kd_PrmAmt, d_LOSRAT_R  %s ;%s; %s; %s ; %s ; %-.3f ; %-.3f ; %-.3f  %f; %-.3f] ; %-.3f\n", pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF],  pbd_InRecChild[GT_TRNCOD_CF],pFutures->FUCLAIM, Kd_Claim_Amt, kd_AmtcPNA,Kd_UPR, Kd_PrmAmt, d_LOSRAT_R);			
#endif					
					n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );
					
 				}					
					

			// [014] Fin Gestion "Future Brokerage" REGLE 04 - 05--> des taux de courtage : 1A120032 : calcul a intergrer	
			// [051] Replacement of brokerage rate 1A120032 by 1A120062
					
			//} ON INCLUT LE CALCUL DE LA FUTURE VARIABLE PREMIUM DANS LA CONDITION DU CALCUL DES PRIME

			// R02-02 : Future Variable Premium : contract nature = 'N'
									
			if ( *pbd_InRecOwner[PER_CTRNAT_CT] == 'N' )
			{			
			  		
				//[014] [028] DEB FUTURE VARIABLE PREMIUM
	
			/* si taux de prime variable */
			if ( *pbd_InRecOwner[PER_PRMFLCRAT_B] == '1' )
			{
				/* si prime non forfaitaire */
				if ( *pbd_InRecOwner[PER_FLAPRM_B] == '0' )
				{

					/* si il existe une ligne au moins une prime estimee
					ou cedante pour l'affaire en cours */
//					if ( Kc_Pe==1 && strcmp(pbd_InRecOwner[PERExtend_ESTPRMTYP_CT], "1")!=0)
					//if ( Kc_Pe==1 && n_Check_Prov==1 )
					
					{
						/*********************************************/
						/* appel du module de calcul de Burning Cost */
						/*********************************************/
							
					if (atof( pbd_InRecOwner[PER_CUTSHA_R] ) != 0)
					{ 
						d_BC_01 = d_CalculBurningCost( (char)( atoi( pbd_InRecOwner[PER_SUPLOATYP_CT] ) ),
 							//atof( pbd_InRecOwner[PER_SBJPRM_M] ), //[028] ==> (Kd_PrmAmt-kd_AmtcPNA) / d_CUTSHA_R   (Future Fixe - UPR) / d_CUTSHA_R  // (Kd_PrmAmt-Kd_UPR) / ( atof( pbd_InRecOwner[PER_PRMMINEFF_R]) *  atof( pbd_InRecOwner[PER_CUTSHA_R])
 							((Kd_PrmAmt-Kd_UPR) / ( atof( pbd_InRecOwner[PER_PRMMINEFF_R]) *  atof( pbd_InRecOwner[PER_CUTSHA_R]) * atof( pbd_InRecOwner[PER_RIDSHA_R] ) )),
 							Kd_Claim_Amt,
							atof( pbd_InRecOwner[PER_PRMMINEFF_R] ), 
							atof( pbd_InRecOwner[PER_PRMMAXEFF_R] ),
							atof( pbd_InRecOwner[PER_PRMEFFLOA_M] ), 
							atof( pbd_InRecOwner[PER_PRMEFFLOA_R] ),
							atof( pbd_InRecOwner[PER_CUTSHA_R] ), 
							atof( pbd_InRecOwner[PER_RIDSHA_R] ),
							(char)( atoi( pbd_InRecOwner[PER_LIARIDSHA_B] ) ) ) ;	
					
					// Calcul du BC final :
					
					d_BC = d_BC_01 -(Kd_PrmAmt-Kd_UPR) ;  // 
													
							
#ifdef TRACE_BURNING_COST
		if ( (strcmp("02U036859", pbd_InRecOwner[PER_CTR_NF] ) == 0  || strcmp("20T008824", pbd_InRecOwner[PER_CTR_NF] ) == 0 || strcmp("20U006533", pbd_InRecOwner[PER_CTR_NF] ) == 0  ) && (atoi(pbd_InRecOwner[PER_UWY_NF]) == 2019) )
			printf(" CALCUL BC DONNEES ENTREE EBS CTR_NF,  UWY, SECTION  :  atoi( pbd_InRecOwner[PER_SUPLOATYP_CT] ), atof( pbd_InRecOwner[PER_SBJPRM_M] ), Kd_PrmAmt,  Kd_UPR, (Kd_PrmAmt - Kd_UPR), Kd_Claim_Amt, atof( pbd_InRecOwner[PER_PRMMINEFF_R] ), atof( pbd_InRecOwner[PER_PRMMAXEFF_R] ), atof( pbd_InRecOwner[PER_PRMEFFLOA_M] ), atof( pbd_InRecOwner[PER_PRMEFFLOA_R] ), atof( pbd_InRecOwner[PER_CUTSHA_R] ), atof( pbd_InRecOwner[PER_RIDSHA_R] ), atoi( pbd_InRecOwner[PER_LIARIDSHA_B] ), d_BC, d_BC_01: %s; %d ; %d; %d ; %f ; %f ; %f ; %f ; %f ; %f ; %f ; %f ; %f ; %f ; %f ; %d ; %f ; %f \n",  
			pbd_InRecOwner[PER_CTR_NF], atoi(pbd_InRecOwner[PER_UWY_NF]), atoi( pbd_InRecOwner[PER_SEC_NF] ), atoi( pbd_InRecOwner[PER_SUPLOATYP_CT] ), atof( pbd_InRecOwner[PER_SBJPRM_M] ), Kd_PrmAmt,  Kd_UPR, Kd_PrmAmt - Kd_UPR, Kd_Claim_Amt, atof( pbd_InRecOwner[PER_PRMMINEFF_R] ), atof( pbd_InRecOwner[PER_PRMMAXEFF_R] ), atof( pbd_InRecOwner[PER_PRMEFFLOA_M] ), atof( pbd_InRecOwner[PER_PRMEFFLOA_R] ), atof( pbd_InRecOwner[PER_CUTSHA_R] ), atof( pbd_InRecOwner[PER_RIDSHA_R] ), atoi( pbd_InRecOwner[PER_LIARIDSHA_B] ), d_BC, d_BC_01 );
#endif							
				}		
					else
						printf(" CONTRAT Assiete de prime d_CUTSHA_R = 0  CONTRAT %s`\n", pbd_InRecOwner[PER_CTR_NF]) ;							
					}
				}				
				else
				{
					/********************************************************/
					/* appel du module de calcul de Prime de reconstitution */
					/********************************************************/
						
					d_RP = (d_CalculPrimeReconstitution( 
					(char)( atoi( pbd_InRecOwner[PER_REIEXI_B] ) ),  
					(char)( atoi( pbd_InRecOwner[PER_REIUNL_B] ) ),  
					(char)( atoi( pbd_InRecOwner[PER_REIFRE_B] ) ),  
					(char)( atoi( pbd_InRecOwner[PER_REINBR_N] ) ),  
					atof( pbd_InRecOwner[PER_SBJPRM_M] ),
					Kd_Claim_Amt,   
					(Kd_PrmAmt-Kd_UPR), 					
					// with other UPR (Kd_PrmAmt-kd_AmtcPNA), 									                          
					atof( pbd_InRecOwner[PER_LAYCAP_M] ),
					atof( pbd_InRecOwner[PER_CUTSHA_R] ), 
					atof( pbd_InRecOwner[PER_RIDSHA_R] ),
					(char)( atoi( pbd_InRecOwner[PER_LIARIDSHA_B] ) ), 
					Ktbd_Rec ) - (Kd_PrmAmt-Kd_UPR));		// with other UPR : Ktbd_Rec ) - (Kd_PrmAmt-kd_AmtcPNA));																		  
					
#ifdef TRACE_PRIME_RECONSTITUTION
	printf(" 01 CALCUL DE LA PRIME DE RECONSTITUTION  PER_CTR_NF, PER_END_NT, PER_SEC_NF, PER_UWY_NF, GT_TRNCOD_CF,  d_RP, Kd_Claim_Amt, Kd_PrmAmt,  kd_AmtcPNA, Kd_UPR,  d_LOSRAT_R : %s ;%s ;%s ;%s ;%s;%-3.f;%-3.f;%-3.f ;%-3.f ; %f;  %-3.f ;\n", pbd_InRecOwner[PER_CTR_NF], pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_TRNCOD_CF], d_RP, Kd_Claim_Amt, Kd_PrmAmt,kd_AmtcPNA, Kd_UPR, d_LOSRAT_R);
#endif						

				}
			}
			else
			{
				/********************************************************/
				/* appel du module de calcul de Prime de reconstitution */
				/********************************************************/
					
				d_RP = (d_CalculPrimeReconstitution( 
					(char)( atoi( pbd_InRecOwner[PER_REIEXI_B] ) ),  
					(char)( atoi( pbd_InRecOwner[PER_REIUNL_B] ) ),  
					(char)( atoi( pbd_InRecOwner[PER_REIFRE_B] ) ),  
					(char)( atoi( pbd_InRecOwner[PER_REINBR_N] ) ),  
					atof( pbd_InRecOwner[PER_SBJPRM_M] ),
					Kd_Claim_Amt,   
					(Kd_PrmAmt-Kd_UPR), // with other UPR :	(Kd_PrmAmt-kd_AmtcPNA), 									                          
					atof( pbd_InRecOwner[PER_LAYCAP_M] ),
					atof( pbd_InRecOwner[PER_CUTSHA_R] ), 
					atof( pbd_InRecOwner[PER_RIDSHA_R] ),
					(char)( atoi( pbd_InRecOwner[PER_LIARIDSHA_B] ) ), 
					Ktbd_Rec ) - (Kd_PrmAmt-Kd_UPR));		 // with other UPR : Ktbd_Rec ) - (Kd_PrmAmt-kd_AmtcPNA));																		  
					
#ifdef TRACE_PRIME_RECONSTITUTION
	printf(" 02 CALCUL DE LA PRIME DE RECONSTITUTION  PER_CTR_NF, PER_END_NT, PER_SEC_NF, PER_UWY_NF, GT_TRNCOD_CF,  d_RP, Kd_Claim_Amt, Kd_PrmAmt,  kd_AmtcPNA, Kd_UPR, d_LOSRAT_R : %s ;%s ;%s ;%s ;%s;%-3.f;%-3.f;%-3.f ;%-3.f ; %f; %-3.f ;\n", pbd_InRecOwner[PER_CTR_NF], pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_TRNCOD_CF], d_RP, Kd_Claim_Amt, Kd_PrmAmt,kd_AmtcPNA, Kd_UPR, d_LOSRAT_R);
#endif

			}				// Future Variable Premium (10002) = Reinstatement Premium + Burning Cost Premium (MONTANT* (d_BC+ d_RP)
				
				d_Amt = d_RP + d_BC ;
			}
			else
			{ 		
				d_Amt = 0 ; // on ne calcule pas les Futures pour les FAC et les Proportionnels.		
			}
			 												
			sprintf( sz_Amt, "%-.3f", d_Amt );
			strcpy( sz_Trncod, "1A100022" ); 				
			pFutures->TRNCOD = sz_Trncod;						
		 	
			pFutures->FUVPREMIUM = d_Amt;				// Future Variable premium,
			Kd_PrmVarAmt = d_Amt ; 							// Sauvegarde de la Future Variable Premium	
			
			n_EcrireLog(); 	

			if ( fabs(atof(sz_Amt)) > 1)
			{ 
	
#ifdef TRACE_FUTURE_VARIABLE_PREMIUM							
	printf(" Future TRACE_FUTURE_VARIABLE_PREMIUM pbd_InRecOwner[PER_CTR_NF], END_NT, PER_SEC_NF, UWY_NF, GT_TRNCOD_CF, Kd_PrmVarAmt, REINSTATEMENT_PREMIUM, BURNING_COST : %s ; %s ; %s; %s ; %s; %-.3f ; %-.3f ; %-.3f \n", pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF],  pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_TRNCOD_CF], Kd_PrmVarAmt, d_RP, d_BC);			
#endif					
				n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );				
			 
			}					
				//[013] FIN FUTURE VARIABLE PREMIUM					
		
		
		// [014] Deb Gestion "Future Brokerage" 
		// REGLE 04 - 05--> des taux de courtage : 1A120032 : calcul a intergrer
		// [051] replacement of brokerage rate 1A120032 by 1A120062 
		// [016] R04-05 : Assumed Future Brokerage =  Brokerage Rate * Future Fixed Premium * -1
		//       Assumed Future Brokerage =  Brokerage Rate * Future Fixed Premium
		//       Kd_BrkRat : Brokerage Rate calculated and stored FLOARAT_EBS file						
		
			if ( fabs(Kd_PrmAmt) >= 1  && (*pbd_InRecOwner[PER_CTRNAT_CT] != 'N'))  // Cas des FAC et TRAITES PROPORTIONNELS
			{
		
#ifdef TRACE_FUTURE_BROKERAGE							                                                                                                                                                					
			printf(" 0000 TRACE_FUTURE_BROKERAGE Future Brokerage pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], GT_TRNCOD_CF, Kd_FuturBrk, Kd_BrkRat, Kd_PrmAmt : %s ;  %s ; %s ; %s ; %s ;  %-.3f ; %-.3f ; %-.3f \n", pbd_InRecOwner[PER_CTR_NF], pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF],  pbd_InRecChild[GT_TRNCOD_CF], Kd_FuturBrk, Kd_BrkRat, Kd_PrmAmt);					
#endif			
			  
			  d_Amt = Kd_BrkRat * Kd_PrmAmt  ; 						//[016]   (-1); Attention le signe (-1) est deja pris en compte a l'extraction du taux de la table LOARAT
			  Kd_FuturBrk = d_Amt ; 
				pFutures->FUBROKER = d_Amt;											// Future Brokerage			  
			  
			}					

		// [039] Calcul FUTURE BROKERAGE NOUVELLE FORMULE, Uniquement pour les Non Proportionnels
		/****************************************************************************************************/
		/*  Assumed Future Brokerage =  Brokerage Rate * Future Fixed Premium * -1                          */
		/*                              + Brokerage Rate * Future Variable Premium * -1 (If Burning Cost)   */
		/*                              + Reinstatement Brokerage Rate * Future Variable Premiums * -1      */
		/****************************************************************************************************/
				
		/* Brokerage Rate * Future Fixed Premium * -1) + (Reinstatement Brokerage Rate (TFAMCH.RECBRK_R) * Future Variable Premiums * -1) */
			
			if (*pbd_InRecOwner[PER_CTRNAT_CT] == 'N')
			{
				if ( *pbd_InRecOwner[PER_FLAPRM_B] == '0' && *pbd_InRecOwner[PER_PRMFLCRAT_B] == '1' )
				{
           Kd_FuturBrk = (Kd_PrmAmt * Kd_BrkRat) + (Kd_PrmVarAmt * Kd_BrkRat);
        }
				else
				{
           Kd_FuturBrk = (Kd_PrmAmt * Kd_BrkRat) + (Kd_PrmVarAmt * atof(pbd_InRecOwner[PER_RECBRK_R]) * (-1));
        }
			}

			sprintf( sz_Amt, "%-.3f", Kd_FuturBrk );
      // [051] strcpy( sz_Trncod, "1A120032" );
      strcpy( sz_Trncod, "1A120062" ); 
      pFutures->TRNCOD = sz_Trncod;
      
      n_EcrireLog();

      if ( fabs(atof(sz_Amt)) > 1)
      {
#ifdef TRACE_FUTURE_BROKERAGE                                                                                                                                                                                  
         printf(" TRACE_FUTURE_BROKERAGE Future Brokerage pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], GT_TRNCOD_CF, Kd_FuturBrk, Kd_BrkRat, pFutures->FUBROKER : %s ;  %s ; %s ; %s ; %s ;  %-.3f ; %-.3f ; %-.3f \n", pbd_InRecOwner[PER_CTR_NF], pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF],  pbd_InRecChild[GT_TRNCOD_CF], Kd_FuturBrk, Kd_BrkRat, pFutures->FUBROKER);
#endif        	
        	
           n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );
      }	
        	



				// INCLURE CALCUL FUTURE CHARGES DANS CONDITION 1

		//} // On inclut le calcul des FUTURES VARIABLES PREMIUM DANS LA CONDITION "1A110002"			


			// [013] Gestion de la Future Charge Fixe et de la Future Charge Variable


			
			// gestion Charge future : 1A120002 Correspond aux commissions actuellement
			// Assumed Future Fixed Charges = Fixed Commission Rate  * Future Fixed Premium (R04 - 01)
				
			
			/*******************************************************************************************************************/
			/*      Le calcul des FUTURS  CHARGES SE BASE SUR LE TRNCOD "1A120002", defini dans ESID2003A au step 80 et 90 ;   */ 
			/*      le PRS_CF utilise est le 713, Ancienne formule du prog ESTC1064                                            */ //027
			/*******************************************************************************************************************/
			
			//[038] if ( strcmp(pbd_InRecChild[GT_TRNCOD_CF], "1A120002") == 0 && ((kd_AmtcPRM + kd_AmtcPRT) != 0) && kc_FlagPNAseul == 'N' )  	//027]	
			
		
			// [043] if ( strcmp(pbd_InRecChild[GT_TRNCOD_CF], "1A120002") == 0 && ((kd_AmtcPRM + kd_AmtcPRT) != 0) )			
			//if ( (strcmp(pbd_InRecChild[GT_TRNCOD_CF], "1A120002") == 0 || (Kd_SurComRat != 0)  ) && ((kd_AmtcPRM + kd_AmtcPRT) != 0)  )	
			//{ 
				pFutures->AMTCEXP_M = atof(pbd_InRecChild[GT_AMT_M]);
				 
				// DEb [013] Calcul charge future --> Future Charge Fixe : 
				// Assumed Future Fixed Charges = Fixed Commission Rate  * Future Fixed Premium

				
				// Calcul de la valeur de Fixed Commission Rate, par appel de d_CalculChargesCommissions :

#ifdef TRACE_5
			if (strcmp(pbd_InRecOwner[PER_CTR_NF], "20T010203") == 0)
			{ 
				printf("DANS CONDITION CHARGES : PER_CTR_NF=%s FUTURE_PRIME =%-3.f; kd_AmtcPRM =%-3.f ; kd_AmtcPRT =%-3.f ; TRNCOD=%s\n", pbd_InRecOwner[PER_CTR_NF], Kd_PrmAmt, kd_AmtcPRM, kd_AmtcPRT, pbd_InRecChild[GT_TRNCOD_CF]);
				printf("0000 Future Fixe Charge pbd_InRecOwner : [PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_TRNCOD_CF], pbd_InRecChild[GT_AMT_M], pFutures->FUFEXP,  k_TCom,  Kd_PrmAmt, kd_AmtcPRM_ITD, kd_AmtcPRT_PFOLIO, Kd_Claim_Amt, Kd_PrmAmt :  %s ;%s ; %s ; %s ; %s ; %-3.f ; %lf ; %lf ; %-3.f ; %-3.f ; %-3.f ; %-3.f ; %-3.f\n", pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_TRNCOD_CF], atof(pbd_InRecChild[GT_AMT_M]), pFutures->FUFEXP, k_TCom, Kd_PrmAmt, kd_AmtcPRM, kd_AmtcPRT, Kd_Claim_Amt, Kd_PrmAmt);			
			  printf(" 02 DANS CONDITION CHARGES FUTURE_PRIME=%-3.f ; PER_COMTYP_CT=%d\n", atof(pbd_InRecOwner[PER_SCOEGP_M]) - kd_AmtcPRM, atoi( pbd_InRecOwner[PER_COMTYP_CT]));
			  printf("\n COnditions de calcul de la Future Fixe Charge : Type commission = pbd_InRecOwner[PER_COMTYP_CT][%s] ; Prime Net Commission = pbd_InRecOwner[PER_PRMNETCOM_B][%s]: \n", pbd_InRecOwner[PER_COMTYP_CT], pbd_InRecOwner[PER_PRMNETCOM_B]);
			}

#endif							

	/***********************************************************************************/
	/* Appel de la fonction d_CalculChargesCommissions de calcul du Taux de Commission */
	/***********************************************************************************/
	
			  
				  k_TCom = d_CalculChargesCommissions(
												(char)( atoi( pbd_InRecOwner[PER_PRMNETCOM_B] ) ),
												( *pbd_InRecOwner[PER_CTRNAT_CT] == 'F' ? 1 : (char)( atoi( pbd_InRecOwner[PER_COMTYP_CT] ) ) ),
												atof( pbd_InRecOwner[PER_FIXCOM_R] ),
												atof( pbd_InRecOwner[PER_MAXCOM_R] ),
												atof( pbd_InRecOwner[PER_MINRATCLP_R] ),
												atof( pbd_InRecOwner[PER_MINCOM_R] ),
												atof( pbd_InRecOwner[PER_MAXRATCLP_R] ),
												Kd_Claim_Amt,
												//(Kd_PrmAmt-kd_AmtcPNA), 		// Montant Prime future Fixe + Montant UPR / PNA [015] (Kd_PrmAmt-Kd_UPR), 
												(Kd_PrmAmt-Kd_UPR),
												Kn_NbFam,   
												Ktbd_FamCha 
												) ;	
												
				// La future Charge fixe n est calculée que si le type de commission est fixe (COMTYP != 	 )et La FUTURE FIXE PREMIUM  != 0)	
				
// [034] 				if (strcmp(pbd_InRecOwner[PER_CTRNAT_CT], "F")==0 || ( *pbd_InRecOwner[PER_COMTYP_CT]  == '2' || *pbd_InRecOwner[PER_COMTYP_CT]  == '4' || *pbd_InRecOwner[PER_COMTYP_CT]  == '5') )    

				if (strcmp(pbd_InRecOwner[PER_CTRNAT_CT], "F")==0 || ( *pbd_InRecOwner[PER_COMTYP_CT]  == '2')) 
					d_Amt = 0;
				else
				{ 
					//d_Amt = k_TCom*Kd_PrmAmt * (-1) ;				// [016]  //Si TYP_COMMISSION != "2" Alors 

					// 		Calcul charge future fixe Ancienne formule
					
					
				//	d_Amt = (atof(pbd_InRecChild[GT_AMT_M]) * d_taux / (kd_AmtcPRM + kd_AmtcPRT)) * (Kd_PrmAmt); //[06] [011]			
					
					
					//d_Amt = (-1) * (Kd_ComRat + Kd_SurComRat + Kd_Tax) * (Kd_PrmAmt) ; //[043] 
					d_Amt =  (Kd_ComRat + Kd_SurComRat + Kd_Tax) * (Kd_PrmAmt) ; //[043] Les montants sont deja negatifs, ne palus tenir compte du (-1)
								

#ifdef TRACE_FUTURE_FIXE_CHARGE							
			printf("000 Future Fixe Charge pbd_InRecOwner : [PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecOwner[PER_COMTYP_CT], pbd_InRecChild[GT_TRNCOD_CF], pbd_InRecChild[GT_AMT_M], d_taux, pFutures->FUFEXP,  k_TCom,  Kd_PrmAmt, kd_AmtcPRM_ITD, kd_AmtcPRT_PFOLIO ; Kd_ComRat; Kd_SurComRat; Kd_Tax; NEW_Fixed_Commission_Rate; FUTURE_CHARGE :  %s ;%s ; %s ; %s ; %d; %s ; %-3.f ; %-3.f ; %-3.f ; %-3.f ; %-3.f ; %-3.f ; %-3.f ; %f ; %f ;%f ; %f ; %f \n", pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], atoi(pbd_InRecOwner[PER_COMTYP_CT]), pbd_InRecChild[GT_TRNCOD_CF], atof(pbd_InRecChild[GT_AMT_M]), d_taux, d_Amt, k_TCom, Kd_PrmAmt, kd_AmtcPRM, kd_AmtcPRT, Kd_ComRat, Kd_SurComRat, Kd_Tax, (Kd_ComRat + Kd_SurComRat + Kd_Tax), ((Kd_ComRat + Kd_SurComRat + Kd_Tax) * Kd_PrmAmt));			
#endif


			  }	
			  	
				sprintf( sz_Amt, "%-.3f", d_Amt );
				strcpy( sz_Trncod, "1A120012" );	
			  pFutures->TRNCOD = sz_Trncod;								    							    
				
				Kd_FuturCharge  = d_Amt;			
				
				pFutures->FUFEXP = d_Amt;											// Future Fixed Charge				

				pbd_InRecChild[GT_RETAMT_M] = "0";
				pbd_InRecChild[GT_RETINTAMT_M] = "0";
				pbd_InRecChild[GT_TRNCOD_CF] = sz_Trncod;
				pbd_InRecChild[GT_DBLTRNCOD_CF] = sz_Dblcod;
				pbd_InRecChild[GT_AMT_M] = sz_Amt;
				pbd_InRecChild[GT_CUR_CF] = sz_Cur;
				
#ifdef TRACE_FUTURE_FIXE_CHARGE							
			printf("00 Future Fixe Charge pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecOwner[PER_COMTYP_CT], pbd_InRecChild[GT_TRNCOD_CF], pFutures->FUFEXP,  k_TCom,  Kd_PrmAmt :  %s ;%s ; %s ; %s ; %d ;%s ; %lf ; %lf ; %lf \n", pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], atoi(pbd_InRecOwner[PER_COMTYP_CT]), pbd_InRecChild[GT_TRNCOD_CF], pFutures->FUFEXP, k_TCom, Kd_PrmAmt);			
#endif				
				
				n_EcrireLog(); 

				if ( fabs(atof(sz_Amt)) > 1)
				{
					
#ifdef TRACE_FUTURE_FIXE_CHARGE							
			printf(" 01 Future Fixe Charge pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecOwner[PER_COMTYP_CT], pbd_InRecChild[GT_TRNCOD_CF], pFutures->FUFEXP,  k_TCom,  Kd_PrmAmt :  %s ;%s ; %s ; %s ;%s ; %s ; %lf ; %lf ; %lf \n", pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecOwner[PER_COMTYP_CT], pbd_InRecChild[GT_TRNCOD_CF], pFutures->FUFEXP, k_TCom, Kd_PrmAmt);			
#endif						
					 
					n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );	
				}
					
				// Fin [013]  Calcul charge future --> Future Charge Fixe
				
				// Deb [013]  Calcul charge Variable future  --> Future Charge Variable : "1A120022"						


		
	/* complement des affectations des postes du tableau des participations */ 
			// [032] Ktbd_Par[Kn_Par_Nbp].PRMAMT_M = Kd_PrmAmt-Kd_UPR ;   	// [015] Future Fixed Premium (calculated in R02-01) - UPR == [Prime Acquise Comptabilisee + prime cedante ] --> kd_AmtcPNA
			// [032] Ktbd_Par[Kn_Par_Nbp].ACCRES_M = Kd_PrmAmt-Kd_UPR + ( Kd_FuturCharge - Kd_DAC + Kd_Claim_Amt + Kd_FuturBrk) ; // [015] Rsesult Account
			
			Ktbd_Par[Kn_Par_Nbp].PRMAMT_M = Kd_PrmAmt ;   	// [015] Future Fixed Premium (calculated in R02-01) - UPR == [Prime Acquise Comptabilisee + prime cedante ] --> kd_AmtcPNA
			Ktbd_Par[Kn_Par_Nbp].ACCRES_M = Kd_PrmAmt-Kd_UPR + ( Kd_FuturCharge - Kd_DAC + Kd_Claim_Amt + Kd_FuturBrk) ; // [015] Rsesult Account			
			
//			Ktbd_Par[Kn_Par_Nbp].ACCRES_M = Kd_PrmAmt-kd_AmtcPNA - ( Kd_FuturCharge + Kd_DAC + Kd_Claim_Amt) ; // [015] Rsesult Account			


#ifdef TRACE_FUTURE_VARIABLE_CHARGE	
			printf(" PRIME (P) : [PER_CTR_NF],  Fut_Prime, Prime01,  Kd_PrmAmt,   Kd_UPR, kd_AmtcPNA : %s ; %-3.f ;  %-3.f ; %-3.f ; %-3.f ; %-3.f\n", 
			                            pbd_InRecOwner[PER_CTR_NF], Kd_PrmAmt, Kd_PrmAmt-kd_AmtcPNA, Kd_PrmAmt, Kd_UPR, kd_AmtcPNA);							
			printf(" Result Account (Rc) : [PER_CTR_NF], Result_Account, Kd_PrmAmt, Kd_UPR, kd_AmtcPNA, Kd_FuturCharge, Kd_DAC, Kd_Claim_Amt, Kd_FuturBrk : %s ; %-3.f ; %-3.f ; %-3.f; %-3.f; %-3.f ; %-3.f ; %-3.f ; %-3.f\n", 
			                            pbd_InRecOwner[PER_CTR_NF], (Kd_PrmAmt-kd_AmtcPNA - ( Kd_FuturCharge + Kd_DAC + Kd_Claim_Amt)), Kd_PrmAmt, Kd_UPR, kd_AmtcPNA, Kd_FuturCharge, Kd_DAC, Kd_Claim_Amt, Kd_FuturBrk);			
#endif

	/* incrementation du nombre de postes du tableau Ktbd_Par */
	Kn_Par_Nbp -= 1 ;

	/* incrementation du nombre de postes du tableau Ktbd_FamCha_02 */
	if ( atoi( pbd_InRecOwner[PER_CTBTYP_CT] ) == 2 )
		Kn_Fam_Nbl -= 1 ;

	/*********************************************************************/
	/* Appel de la fonction n_CalculPartBenefPert de calcul de PB et PAP */
	/*********************************************************************/

	n_PbPap_Nbp = n_CalculPartBenefPert( ( NB_PAR_MAX - Kn_Par_Nbp - 1 ), &Ktbd_Par[Kn_Par_Nbp + 1],
		&Ktn_FamUwy[Kn_Fam_Nbp + 1], &Ktbd_FamCha_02[Kn_Fam_Nbp + 1], tbd_PbPap ) ;
		

	for ( i = 0; i < n_PbPap_Nbp ; i++ )
	{
		/* positionnement du montant calcule PB */
		if ( tbd_PbPap[i].PBEX == 1 )
		{
			/* cas ou les PB/PAP ne sont pas calculables */
			if ( tbd_PbPap[i].CTCOM_B == 0 )
			{
				strcpy( sz_PbOriCod, "Account" ) ;
				d_PbCalAmt = Ktbd_EstGt[Kn_Par_Nbp + 1 + i].PB_M ;
			}
			else
			{
				strcpy( sz_PbOriCod, "CloP" ) ;
				d_PbCalAmt = tbd_PbPap[i].PB ;
			}
		}				
		
		Kd_PB= d_PbCalAmt ; // Resultat du calcul de la PB
		
#ifdef TRACE_5
        if (strcmp(pbd_InRecOwner[PER_CTR_NF], "20T010203") == 0 )	
					printf(" MZ 02 Affichage : Profit(PB)  : Contrat [%s];  ; pbd_InRec_Cur[PER_END_NT][%s]; pbd_InRec_Cur[PER_SEC_NF][%s] ;pbd_InRecOwner[PER_UWY_NF]%s; Kd_PB[%lf] ; \n", pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF],pbd_InRecOwner[PER_UWY_NF], Kd_PB); 
#endif		

		/* positionnement du montant calcule PAP */
		if ( tbd_PbPap[i].PAPEX == 1 )
		{
			/* cas ou les PB/PAP ne sont pas calculables */
			if ( tbd_PbPap[i].CTCOM_B == 0 )
			{
				strcpy( sz_PapOriCod, "Account" ) ;
				d_PapCalAmt = Ktbd_EstGt[Kn_Par_Nbp + 1 + i].PAP_M ;
			}
			else
			{
				strcpy( sz_PapOriCod, "CloP" ) ;
				d_PapCalAmt = tbd_PbPap[i].PAP ;
			}
			Kd_PAP = d_PapCalAmt;   // Resultat du calcul de la PAP						
			
		}

		/* positionnement du montant retenu PB */
		if ( Ktbd_EstGt[Kn_Par_Nbp + 1 + i].PBADMMOD_CT == 'A' )
			d_PbRetAmt = d_PbCalAmt ;
		else	d_PbRetAmt = Ktbd_EstGt[Kn_Par_Nbp + 1 + i].PBENTAMT_M ;

#ifdef TRACE_5		
					printf(" MZ 05 Affichage :  montant retenu PB : Contrat [%s] ; pbd_InRecOwner[PER_END_NT][%s]; pbd_InRecOwner[PER_SEC_NF][%s] ;  pbd_InRecOwner[PER_UWY_NF]%s; d_PbRetAmt[%lf] ; \n", pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF] , pbd_InRecOwner[PER_UWY_NF],  d_PbRetAmt); 
#endif


		/* positionnement du montant retenu PAP */
		if ( Ktbd_EstGt[Kn_Par_Nbp + 1 + i].PAPADMMOD_CT == 'A' )
			d_PapRetAmt = d_PapCalAmt ;
		else	d_PapRetAmt = Ktbd_EstGt[Kn_Par_Nbp + 1 + i].PAPENTAMT_M ;

#ifdef TRACE_5	
 				if (strcmp(pbd_InRecOwner[PER_CTR_NF], "20T010203") == 0 )		
					printf(" MZ 06 Affichage :  montant retenu PAP : Contrat [%s] ; pbd_InRecOwner[PER_END_NT][%s]; pbd_InRecOwner[PER_SEC_NF][%s] ; pbd_InRecOwner[PER_UWY_NF]%s ; d_PapRetAmt[%lf] ; \n", pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF] , pbd_InRecOwner[PER_UWY_NF],  d_PapRetAmt); 
#endif			

	}
	
	/*Ecriture de Kd_PB + Kd_PAP Spira 78628 [045]*/
    sprintf( sz_Amt, "%-.3f", Kd_PB + Kd_PAP );
    strcpy( sz_Trncod, "1A120072" );
    pbd_InRecChild[GT_RETAMT_M] = "0";
    pbd_InRecChild[GT_RETINTAMT_M] = "0";
    pbd_InRecChild[GT_TRNCOD_CF] = sz_Trncod;
    pbd_InRecChild[GT_DBLTRNCOD_CF] = sz_Dblcod;
    pbd_InRecChild[GT_AMT_M] = sz_Amt;
    pbd_InRecChild[GT_CUR_CF] = sz_Cur;

    if ( fabs(atof(sz_Amt)) > 1)
    {
      n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );
    }
					

		/**************************************************************************/
		/*          Formules de Calcul de la Future Variable Charge               */
		/**     									                                               **/
		/**         d_Amt = Kd_PB + Kd_PAP +  Kd_SC                              **/
		/**                                                                      **/                                                 
		/**       AVEC   Kd_SC = k_TCom*(Kd_PrmAmt-Kd_UPR)                       **/ //[015]
		/**       AVEC   Kd_SC = (-1) k_TCom * Kd_PrmAmt                         **/ //[031]		
		/**************************************************************************/


				// Le taux de commission est égale à zero lorsque le type de commission n'est pas variable ;
							
				
				if (atoi( pbd_InRecOwner[PER_COMTYP_CT])  != 2)   // Si TYP_COMMISSION != 2 Alors k_Tcom = 0
					Kd_SC = 0.0 ;
				else 
					//Kd_SC = (-1)* k_TCom*(Kd_PrmAmt-Kd_UPR);	//[031]
					Kd_SC = (-1)* k_TCom*Kd_PrmAmt;		
							
                                /*Ecriture de Kd_SC Spira 78628 [045]*/
                                sprintf( sz_Amt, "%-.3f", Kd_SC );
                                strcpy( sz_Trncod, "1A120052" );
                                pbd_InRecChild[GT_RETAMT_M] = "0";
                                pbd_InRecChild[GT_RETINTAMT_M] = "0";
                                pbd_InRecChild[GT_TRNCOD_CF] = sz_Trncod;
                                pbd_InRecChild[GT_DBLTRNCOD_CF] = sz_Dblcod;
                                pbd_InRecChild[GT_AMT_M] = sz_Amt;
                                pbd_InRecChild[GT_CUR_CF] = sz_Cur;
                
                                if ( fabs(atof(sz_Amt)) > 1)
                                {
                                  n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );
                                }

					// with other UPR : Kd_SC = (-1)* k_TCom*(Kd_PrmAmt-kd_AmtcPNA)	 ; // Le kTCom multiplié par (-1) Kd_SC = k_TCom*(Kd_PrmAmt-Kd_UPR)	 ;

				if (strcmp(pbd_InRecOwner[PER_CTRNAT_CT], "F")==0)  //[014]
					d_Amt = 0.0;
				else
					d_Amt = Kd_PB + Kd_PAP +  Kd_SC ;   //[015]  

			 
		 } /* Calcul des FUTUR CHARGES */ // INCLUSION Du CALCUL DES CHARGES FIXES ET VARIABLE
		 
		
		}	
  //} //Pour debug
		//n_EcrireLog();
	}
	
	RETURN_VAL( OK );
}			
			

//[41]
// function n_ActionPereSansFilsDlGtaa  [41]
/****************************************************************************************/
/*** Objet : fonction lancee quand aucune ligne du fichier DLGTAA                     ***/
/***    ne correspond a la ligne courante du fichier IADPERICASE                      ***/
/***    Elle permet de calculer les FUTURE AT INCEPTION ; on considere                ***/
/***    que la NORME est différente "EBS" et "IFRS" pour entrer dans cette fonction.  ***/
/***																																									***/
/*** Nom : n_ActionPereSansFilsDlGtaa                           				              ***/
/***                                                                                  ***/
/*** Parametres:                                                                      ***/
/***    i pbd_InRecOwner  : pointeur sur la ligne du maitre IADPERICASE               ***/
/***                                                                                  ***/
/*** Retour:                                                                          ***/
/***    OK si pas d'erreur,                                                           ***/
/***    ERR si erreur.                                                                ***/
/****************************************************************************************/

int n_ActionPereSansFilsDlGtaa(char *pbd_InRecOwner[]) 
{

  //int i;
  double d_aliment;
  char sz_aliment[22];
	char   sz_Cur[4];
	double d_Amt = 0; 
  char *pbd_InRecChild[GT_NBCOL+1];

  //char sz_DETTRNCOD[6];


	char   sz_Trncod[9];
	char   sz_Dblcod[2];
	char   sz_Seg[12];
	char   sz_Amt[21];
	double d_taux;      			 // Taux de conversion en devise
	double d_FUTURE_LOSRAT_R;  // [10] Future Loss Ratio
	double d_ResAdj_LOSRAT_R;  // [10] Reserving Adjustment Loss Ratio
  double d_LOSRAT_R ;        // [10] selected Loss Ratio according to many rules 	
  double d_OULR_R ;          // [10] Omega UW Loss Ratio 
	double d_IPLR_R ;          // [10] IFRS17 Priced Loss Ratio
  char   c_PrcFLG_B ;        // [10] xAct/FW IFRS priced flag
	char   c_LR_rule;          // [10] LR calculation rule
	//char   MsgAno[300];
	int    n_indice;
	int	 n_Ssd = 0;
	int	 n_Uwy = 0;
	
	double  Kd_PrmAmt    = 0;
	double  Kd_FuturBrk = 0 ;
	double  Kd_Claim_Amt = 0 ;
	double 	d_PbCalAmt = 0 ;	/* montant calcule de PB */
	double  d_PapCalAmt = 0 ;	/* montant calcule de PAP */
	double  d_PbRetAmt = 0 ;	/* montant retenu de PB */
	double  d_PapRetAmt = 0 ;	/* montant retenu de PAP */
	char	sz_PbOriCod[25] ;
	char	sz_PapOriCod[25] ;
	
	int n_PbPap_Nbp, i =0 ;
	
	
	//[013] Variables intermediaires au calcul de d_BC et d_RP
	
	double d_RP = 0; // Resultat du calcul de la prime de reconstitution
	double d_BC = 0; // Resultat du calcul du Burning Cost
	double d_BC_01 = 0; // Calcul brut du Burning Cost
	double Kd_FuturCharge = 0 ;    // Future Fixed Charge
	double Kd_FuturVarCharge = 0; // Future Variable Charge	
	
	double d_CANEGP_M = 0 ;    //[037]   
	
	d_taux = 1 ;

	


  DEBUT_FCT("n_ActionPereSansFilsDlGtaa");
  
  // CALCUL DES FUTURES AT INCEPTION ;
  
  
  memset( sz_Cur, 0, sizeof(sz_Cur) );	
	sprintf( sz_Cur, "%s", pbd_InRecOwner[PER_EGPCUR_CF] );
  
  
  
   /* Eclatement de la Ksz_CloDat date AAAAMMJJ en 3 chaines de caractere */
  sscanf( Ksz_CloDat, "%4s%2s%2s", Ksz_Annee_bilan, Ksz_Mois_bilan, Ksz_Jour_bilan ) ; 
  strcpy( sz_Dblcod, "" );
  
 // printf(" n_ActionPereSansFilsDlGtaa : CTR_NF; END_NT ; SEC_NF ; UWY_NF ; EGPI : %s ; %s ; %s ; %s ; %.3lf ;  \n", pbd_InRecOwner[PER_CTR_NF], pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], atof(pbd_InRecOwner[PER_SCOEGP_M]) ) ;

    for(i=0;i<GT_NBCOL;i++)
        pbd_InRecChild[i]="" ;

    pbd_InRecChild[GT_NBCOL] = 0 ;

    /* Calcul du taux de conversion (cours: 31/12/exercice precedent) Kp_InputFilExc */ 

    d_taux=d_GetTaux( Kp_InputFilExc,
                      (char)atoi(pbd_InRecOwner[PER_SSD_CF]),
                      (short)atoi(pbd_InRecOwner[PER_UWY_NF])-1,
                      pbd_InRecOwner[PER_EGPCUR_CF],
                      pbd_InRecOwner[PER_PCPCUR_CF] );

    if (d_taux>0)
    {
        // Conversion de l'aliment brut SCOR
        d_aliment=atof(pbd_InRecOwner[PER_SCOEGP_M]);
        // Conversion
        d_aliment *= d_taux;
    }
    else
        d_aliment=-1;

    sprintf(sz_aliment,"%.3lf",d_aliment); 

    pbd_InRecChild[GT_SSD_CF]= pbd_InRecOwner[PER_SSD_CF];
    pbd_InRecChild[GT_ESB_CF]= pbd_InRecOwner[PER_ACCESB_CF];


    pbd_InRecChild[GT_CTR_NF]= pbd_InRecOwner[PER_CTR_NF];
    pbd_InRecChild[GT_END_NT]= pbd_InRecOwner[PER_END_NT];
    pbd_InRecChild[GT_SEC_NF]= pbd_InRecOwner[PER_SEC_NF];
    pbd_InRecChild[GT_UWY_NF]= pbd_InRecOwner[PER_UWY_NF];
    pbd_InRecChild[GT_UW_NT]=  pbd_InRecOwner[PER_UW_NT];
    pbd_InRecChild[GT_ACY_NF]= pbd_InRecOwner[PER_UWY_NF];


    pbd_InRecChild[GT_CUR_CF]= pbd_InRecOwner[PER_PCPCUR_CF]; 
    pbd_InRecChild[GT_CED_NF]= pbd_InRecOwner[PER_CED_NF];
    pbd_InRecChild[GT_BRK_NF]= pbd_InRecOwner[PER_PRD_NF];
    pbd_InRecChild[GT_PAY_NF]= pbd_InRecOwner[PER_GENPRMPAY_NF];
    pbd_InRecChild[GT_KEY_NF]= pbd_InRecOwner[PER_GANPAYORD_NT];

    // GT enrichi
    pbd_InRecChild[GT_ESTCUR_CF]=pbd_InRecOwner[PER_PCPCUR_CF];
    pbd_InRecChild[GT_NAT_CF]=   pbd_InRecOwner[PER_NAT_CF];

/*    memset(sz_DETTRNCOD, 0, sizeof(sz_DETTRNCOD));
    if (atoi(pbd_InRecOwner[PER_NAT_CF]) >= 30)
    {
        strcpy (sz_DETTRNCOD , "10110");
    }
    else
    {
        strcpy (sz_DETTRNCOD , "10000");
    }

        pbd_InRecChild[GT_ACMTRS_NT]= "1010";
*/   
    
    pbd_InRecChild[GT_ESTCTR_NF]=   pbd_InRecOwner[PER_ESTCTR_NF];
    pbd_InRecChild[GT_ESTSEC_NF]=   pbd_InRecOwner[PER_ESTSEC_NF];
    pbd_InRecChild[GT_LOB_CF]=      pbd_InRecOwner[PER_LOB_CF];
    pbd_InRecChild[GT_SCOEGP_M]=    sz_aliment;
    pbd_InRecChild[GT_ESTCRB_CT]=   pbd_InRecOwner[PER_ESTCRB_CT];
    pbd_InRecChild[GT_LIFTRTTYP_CF]=pbd_InRecOwner[PER_LIFTRTTYP_CF];
    pbd_InRecChild[GT_ACCADMTYP_CT]=pbd_InRecOwner[PER_ACCADMTYP_CT];
    pbd_InRecChild[GT_SECSTS_CT]=   pbd_InRecOwner[PER_SECSTS_CT];
    pbd_InRecChild[GT_PRD_NF]=      pbd_InRecOwner[PER_PRD_NF];
    pbd_InRecChild[GT_SEG_NF]=      pbd_InRecOwner[PER_SEG_NF];
    pbd_InRecChild[GT_COMACC_B]=    "0";
        

    pbd_InRecChild[GT_DETTRS_CF] = "";
    pbd_InRecChild[GT_ESTUWY_NF]="";
    pbd_InRecChild[GT_PROPER_N]= pbd_InRecOwner[PER_ACCFRQ_CT];
    pbd_InRecChild[GT_UWGRP_CF]= pbd_InRecOwner[PER_UWGRP_CF];
    pbd_InRecChild[GT_RTOCTY_CF]="";
    
    pbd_InRecChild[GT_BALSHEY_NF] = Ksz_Annee_bilan ;       	
		pbd_InRecChild[GT_BALSHRMTH_NF] = Ksz_Mois_bilan ;         	
		pbd_InRecChild[GT_BALSHRDAY_NF] = Ksz_Jour_bilan ; 
		
		pbd_InRecChild[GT_RETSCOSTRMTH_NF] = Ksz_Mois_bilan ;	
		pbd_InRecChild[GT_RETSCOENDMTH_NF] = Ksz_Mois_bilan ;

		memset(pFutures, 0 , sizeof (T_FUTURES));// on remet la structure a vide
	
/* [013] Deb Charges Iterees */	

	
	memset( Ktbd_FamCha, 0, ( NB_FAM_MAX * sizeof( T_TabFamCharIt ) ) ) ;
	memset( Ktbd_FamCha_02, 0, ( NB_FAM_MAX * sizeof( T_TabFamCharIt ) ) ) ;

	Kn_NbFam = 0 ;
	Kn_Fam_Nbp = 0;

	/* affectation des postes du tableau Ktbd_EstGt */
	Ktbd_EstGt[Kn_Par_Nbp].UWY_NF = atoi( pbd_InRecOwner[PER_UWY_NF] ) ;
	Ktbd_EstGt[Kn_Par_Nbp].UW_NT = (char)( atoi( pbd_InRecOwner[PER_UW_NT] ) ) ;
	Ktbd_EstGt[Kn_Par_Nbp].SSD_CF = (char)( atoi( pbd_InRecOwner[PER_SSD_CF] ) ) ;
	strcpy( Ktbd_EstGt[Kn_Par_Nbp].DIV_NT, pbd_InRecOwner[PER_DIV_NT] ) ;
	strcpy( Ktbd_EstGt[Kn_Par_Nbp].EGPCUR_CF, pbd_InRecOwner[PER_EGPCUR_CF] ) ;
	Ktbd_EstGt[Kn_Par_Nbp].ACCESB_CF = (char)( atoi( pbd_InRecOwner[PER_ACCESB_CF] ) ) ;
	Ktbd_EstGt[Kn_Par_Nbp].CED_NF = atoi( pbd_InRecOwner[PER_CED_NF] ) ;
	Ktbd_EstGt[Kn_Par_Nbp].PRD_NF = atoi( pbd_InRecOwner[PER_PRD_NF] ) ;
	Ktbd_EstGt[Kn_Par_Nbp].GENPRMPAY_NF = atoi( pbd_InRecOwner[PER_GENPRMPAY_NF] ) ;
	strcpy( Ktbd_EstGt[Kn_Par_Nbp].GANPAYORD_NT, pbd_InRecOwner[PER_GANPAYORD_NT] ) ;
	Ktbd_EstGt[Kn_Par_Nbp].DIFMTH_NF = (char)( atoi( pbd_InRecOwner[PER_DIFMTH_NF] ) ) ;
	Ktbd_EstGt[Kn_Par_Nbp].SEGSA_B = *pbd_InRecOwner[PER_SEGSA_B]; //sinistralité

	/* affectation des postes du tableau des participations */
	Ktbd_Par[Kn_Par_Nbp].UWY_NF = atoi( pbd_InRecOwner[PER_UWY_NF] ) ;
	Ktbd_Par[Kn_Par_Nbp].CTCOM_B = (char)( atoi( pbd_InRecOwner[PER_CTBCOM_B] ) ) ;
	Ktbd_Par[Kn_Par_Nbp].PRFCOMEXI_B = (char)( atoi( pbd_InRecOwner[PER_PRFCOMEXI_B] ) ) ;
	Ktbd_Par[Kn_Par_Nbp].LOSCTBEXI_B = (char)( atoi( pbd_InRecOwner[PER_LOSCTBEXI_B] ) ) ;
	Ktbd_Par[Kn_Par_Nbp].CTBTYP_CT = (char)( atoi( pbd_InRecOwner[PER_CTBTYP_CT] ) ) ;
	Ktbd_Par[Kn_Par_Nbp].PRFCOM_R = atof( pbd_InRecOwner[PER_PRFCOM_R] ) ;
	Ktbd_Par[Kn_Par_Nbp].LOSCTB_R = atof( pbd_InRecOwner[PER_LOSCTB_R] ) ;
	Ktbd_Par[Kn_Par_Nbp].CTBGENFEE_R = atof( pbd_InRecOwner[PER_CTBGENFEE_R] ) ;
	Ktbd_Par[Kn_Par_Nbp].RESTRFTYP_CF = (char)( atoi( pbd_InRecOwner[PER_RESTRFTYP_CF] ) ) ;
	Ktbd_Par[Kn_Par_Nbp].RESTRFDUR_N = (char)( atoi( pbd_InRecOwner[PER_RESTRFDUR_N] ) ) ;
  Ktbd_Par[Kn_Par_Nbp].SSD_CF = (char)( atoi( pbd_InRecOwner[PER_SSD_CF] ) ) ;
  strcpy( Ktbd_Par[Kn_Par_Nbp].EGPCUR_CF, pbd_InRecOwner[PER_EGPCUR_CF] ) ;

  Ktbd_Par[Kn_Par_Nbp].SECACCSTS_CT = (char)( atoi( pbd_InRecOwner[PER_SECACCSTS_CT] ) ) ;

	/* valeur par defaut si le fichier des estimations dommages ne participe pas */
	Ktbd_EstGt[Kn_Par_Nbp].LOSADMMOD_CT = 'A' ; /* mode de gestion par defaut */
	Ktbd_EstGt[Kn_Par_Nbp].LOSENTAMT_M = 0 ; /* montant manuel par defaut */
	Ktbd_EstGt[Kn_Par_Nbp].PBADMMOD_CT = 'A' ; /* mode de gestion par defaut */
	Ktbd_EstGt[Kn_Par_Nbp].PBENTAMT_M = 0 ; /* montant manuel par defaut */
	Ktbd_EstGt[Kn_Par_Nbp].PAPADMMOD_CT = 'A' ; /* mode de gestion par defaut */
	Ktbd_EstGt[Kn_Par_Nbp].PAPENTAMT_M = 0 ; /* montant manuel par defaut */	
	
	Ktn_FamUwy[Kn_Fam_Nbl] = Kn_Fam_Nbp ;	
	
/* [013] Fin Charges Iteres */	
	
// Alimentation de la structure 
//
	pFutures->SSD_CF= (char)( atoi( pbd_InRecOwner[PER_SSD_CF] ) ) ;

	pFutures->SEC_NF= atoi(pbd_InRecChild[GT_SEC_NF]); 
	pFutures->UWY_NF=  atoi( pbd_InRecOwner[PER_UWY_NF] ) ;

	pFutures->CTR_NF= pbd_InRecChild[GT_CTR_NF];
	pFutures->SEG_NF= pbd_InRecChild[GT_SEG_NF];
	pFutures->SCOEGP_M= atof(pbd_InRecChild[GT_SCOEGP_M]); 
	
	
	
	{
		//if ( kc_FlagAcc == 'N' ) RETURN_VAL( OK );

		n_Ssd = (char) atoi( pbd_InRecOwner[PER_SSD_CF] );
		n_Uwy = atoi( pbd_InRecOwner[PER_UWY_NF] );
		strcpy(sz_Seg, pbd_InRecOwner[PER_SEG_NF]);

  //printf(" n_ActionPereSansFilsDlGtaa 02 : CTR_NF; END_NT ; SEC_NF ; UWY_NF ; EGPI : %s ; %s ; %s ; %s ; %.3lf ;  \n", pbd_InRecOwner[PER_CTR_NF], pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], atof(pbd_InRecOwner[PER_SCOEGP_M]) ) ;		
		
     //************************  LOSS RATIO SELECTION RULES [10] JYP IFRS17 req 10.6 ************************************//
     //**                                                                                                              **//
     //**     	                                                                                                       **//

	 
	 //****** 1) recherche du Loss Ratio des FUTURES    *******************************************/
	 
	  if ( (n_indice = n_RechPosteTSEGEST(n_Ssd, sz_Seg, n_Uwy, "ATU" ) ) == -1 )
		{
			if ( (n_indice = n_RechPosteTSEGEST(n_Ssd, "*", n_Uwy, "ATU") ) == -1 )
			{
				// Pas de segment en synchro
				pbd_InRecChild[GT_ORICOD_LS] = "PAS_SYNCHRO_SEG ATU";
				n_WriteCols( Kp_OutputFilResSiiAno, pbd_InRecChild, SEPARATEUR, 0 );
				// RETURN_VAL( OK );  [001]
			}
		}
		// [001]
		if (n_indice == -1) d_FUTURE_LOSRAT_R = 0;
		else d_FUTURE_LOSRAT_R = Ktbd_Segest[n_indice].LOSRAT_R;

     //***** 2) recherche du Reserving Adjustment Loss Ratio  ***************************************/
	  
		if ( (n_indice = n_RechPosteTSEGEST(n_Ssd, sz_Seg, n_Uwy, "VWX") ) == -1 )
		{
			if ( (n_indice = n_RechPosteTSEGEST(n_Ssd, "*", n_Uwy,"VWX") ) == -1 )
			{
				// Pas de segment en synchro
				pbd_InRecChild[GT_ORICOD_LS] = "PAS_SYNCHRO_SEG VWX";
				n_WriteCols( Kp_OutputFilResSiiAno, pbd_InRecChild, SEPARATEUR, 0 );
				// RETURN_VAL( OK );  [001]
			}
		}
		// [001]
		if (n_indice == -1) d_ResAdj_LOSRAT_R = 0;
		else d_ResAdj_LOSRAT_R = Ktbd_Segest[n_indice].LOSRAT_R;
		
     //***** 3) recherche du Omega UW Loss Ratio  ***************************************************/
	
	   d_OULR_R =  atof(pbd_InRecOwner[PER_PMLRAT_R]) ;
	  

      //***** 4) recherche du IFRS17 Priced Loss Ratio  ********************************************/


	 c_PrcFLG_B = '0';
	 if (pbd_InRecOwner[PER_PRC_FLG_CT] != NULL)
	 {
		 	if (pbd_InRecOwner[PER_PRC_FLG_CT][0] != '\0') 
		       c_PrcFLG_B = pbd_InRecOwner[PER_PRC_FLG_CT][0];	   	  	 
	 }

	 d_IPLR_R =  atof(pbd_InRecOwner[PER_IPLR_R]) ;

	   
	  //***** 5) RULES : choix du Loss Ratio  ********************************************/

	   
     if (c_PrcFLG_B == '1' )
	   {
		   c_LR_rule = '1';
		   d_LOSRAT_R = d_IPLR_R + d_ResAdj_LOSRAT_R ;
	   }
	   else if ( strcmp(pbd_InRecOwner[PER_CTRNAT_CT],"P") == 0   )
	   {
		   c_LR_rule = '2' ;
	       d_LOSRAT_R =  d_OULR_R + d_ResAdj_LOSRAT_R ;
	   }
	   else if ( d_FUTURE_LOSRAT_R > 0   )
	   {
		   c_LR_rule = '3' ; 
	       d_LOSRAT_R = d_FUTURE_LOSRAT_R ;
	   }
     else 
	   { 
		   c_LR_rule = '4' ;
	       d_LOSRAT_R = 0.0	;   
	   }


#ifdef TRACE_CLAIMS_RATIOS_INC		
	{
		printf("\nfetch %s req 10.6 key %s %s sec %s %s %s Seg:%s: FUTURE_LOSRAT_R(ATU):%f: ResAdj_LOSRAT_R(VWX):%f: pricedIPLR_R:%f: OULR_R:%f: rule:%c: choose LOSRAT_R:%f: PrcFLG_B:%c: CTRNAT:%s:\n", 
		 pbd_InRecChild[GT_TRNCOD_CF],pbd_InRecOwner[PER_CTR_NF],pbd_InRecOwner[PER_END_NT],pbd_InRecOwner[PER_SEC_NF] ,pbd_InRecOwner[PER_UWY_NF] ,pbd_InRecOwner[PER_UW_NT] ,
		 sz_Seg , d_FUTURE_LOSRAT_R, d_ResAdj_LOSRAT_R  ,d_IPLR_R,d_OULR_R ,c_LR_rule,d_LOSRAT_R,c_PrcFLG_B,pbd_InRecOwner[PER_CTRNAT_CT]) ; 		
  }
#endif

		
		pFutures->LOSRAT_R = d_LOSRAT_R ;

	
     //**                                                                                                              **//
     //**     	                                                                                                       **//		
     //************************   recherche du Loss Ratio des FUTURES : [10] JYP IFRS17 req 10.6 ************************//

		
		/* [049] At Inception, on n effectue pas de conversion de Monnaie */

		{
			// Gestion prime future et sinistre
			//	kd_AmtcPNA =0;
			pFutures->TAUX= d_taux ;
			pFutures->CUR_CF= sz_Cur; 

			pFutures->AMTCPNA= Kd_UPR ;
				
									
			//if ( strcmp(pbd_InRecChild[GT_TRNCOD_CF], "1A110002") == 0 )  // On revient sur la precedente version :			
			{				

				// Calcul prime future AT INCEPTION
				// R02-01 : Future Fixed Premium (10001) = EGPI – ITD Written Premium			
							  
		//	  if  ( (strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0027378") == 0	 || strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0019330") == 0 ) && 	atoi(pbd_InRecOwner[PER_UWY_NF]) == 2019)	
			 if (pbd_InRecOwner[PER_CANEGP_M] != NULL)
			  	d_CANEGP_M = atof(pbd_InRecOwner[PER_CANEGP_M]) ;
			          
				d_Amt = atof(pbd_InRecOwner[PER_SCOEGP_M]) + d_CANEGP_M;					
				
				sprintf( sz_Amt, "%-.3f", d_Amt );
				strcpy( sz_Trncod, "1110014" );							// TRNCOD AT INCEPTION CONACT ("1110014", "NORME") 
				strcat( sz_Trncod, Kc_Norme_Suf) ;
			  pFutures->TRNCOD = sz_Trncod;					
				
				Kd_PrmAmt = d_Amt;
				pFutures->FUFPREMIUM = d_Amt;   		// Future Fixe Premium AT INCEPTION

				pbd_InRecChild[GT_RETAMT_M] = "0";
				pbd_InRecChild[GT_RETINTAMT_M] = "0";
				pbd_InRecChild[GT_TRNCOD_CF] = sz_Trncod;
				pbd_InRecChild[GT_DBLTRNCOD_CF] = sz_Dblcod;
				pbd_InRecChild[GT_AMT_M] = sz_Amt;
				pbd_InRecChild[GT_CUR_CF] = sz_Cur;	
					
				//n_EcrireLog(); 					

			if ( fabs(atof(sz_Amt)) > 1  ) 
			{

#ifdef TRACE_FUTURE_FIXE_INC_PRM	
      if  ( (strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0033531") == 0 || strcmp(pbd_InRecOwner[PER_CTR_NF], "10F142934") ==0)	&& 	atoi(pbd_InRecOwner[PER_UWY_NF]) == 2019)							
			printf(" TRACE_FUTURE_FIXE_PREMIUM INCEPTION Future Fixe Premium pbd_InRecOwner[PER_CTR_NF], pbd_InRec_Cur[PER_END_NT], pbd_InRec_Cur[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], GT_TRNCOD_CF, Kd_PrmAmt, EGPI_SCOR, pbd_InRecChild[GT_AMT_M], d_taux, kd_AmtcPRM  : %s ; %s ; %s; %s ; %s ; %-.3f ; %-.3f; %-.3f ; %-.3f ; %-.3f\n", pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF],  pbd_InRecChild[GT_TRNCOD_CF], Kd_PrmAmt, atof(pbd_InRecOwner[PER_SCOEGP_M]), atof(pbd_InRecChild[GT_AMT_M]), d_taux , kd_AmtcPRM);			
#endif
	 					
					n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );
			}
				
				
				
				// VErsion Avec l'ancien calcul : Utilisation de kd_AmtcPNA à la place de Kd_UPR							
				
				//[042] Ne plus calculer de Future Claims si Future Prime = 0 et UPR = 0. 
				
			if (Kd_PrmAmt == 0 && Kd_UPR ==0)	
						d_Amt = 0 ;
			else					
						d_Amt = (Kd_PrmAmt - Kd_UPR) * d_LOSRAT_R * 100.0 * (-1); //[015] [016] [18]	
			
				
				sprintf( sz_Amt, "%-.3f", d_Amt );
				strcpy( sz_Trncod, "1149431");             						// TRNCOD AT INCEPTION CONACT ("1149431", "NORME")   : NORME ("I", "K", "M")
				strcat( sz_Trncod, Kc_Norme_Suf) ; 				
			  pFutures->TRNCOD = sz_Trncod;						
					
				Kd_Claim_Amt = d_Amt;
				pFutures->FUCLAIM = d_Amt;															// Future Fixed Claims AT INCEPTION

				pbd_InRecChild[GT_TRNCOD_CF] = sz_Trncod;
				pbd_InRecChild[GT_AMT_M] = sz_Amt;		
				
				//n_EcrireLog(); 				

			if ( fabs(atof(sz_Amt)) > 1)
			{ 
					
#ifdef TRACE_FUTURE_INC_CLM
      if  ( strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0027378") == 0	&& 	atoi(pbd_InRecOwner[PER_UWY_NF]) == 2019)			
			printf(" TRACE_FUTURE_CLAIMS INCEPTION Future Claim calculation pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], GT_TRNCOD_CF, pFutures->FUCLAIM, Kd_Claim_Amt, kd_AmtcPNA KdUPR, Kd_PrmAmt, d_LOSRAT_R  %s ;%s; %s; %s ; %s ; %-.3f ; %-.3f ; %-.3f  %f; %-.3f] ; %-.3f\n", pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF],  pbd_InRecChild[GT_TRNCOD_CF],pFutures->FUCLAIM, Kd_Claim_Amt, kd_AmtcPNA,Kd_UPR, Kd_PrmAmt, d_LOSRAT_R);			
#endif					
					n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );
					
 			}					
									
//			if ( *pbd_InRecOwner[PER_CTRNAT_CT] == 'N' )
//			{			

	
			/* si taux de prime variable */
			if ( *pbd_InRecOwner[PER_PRMFLCRAT_B] == '1' )
			{
				/* si prime non forfaitaire */
				if ( *pbd_InRecOwner[PER_FLAPRM_B] == '0' )
				{
					

						/*********************************************/
						/* appel du module de calcul de Burning Cost */
						/*********************************************/
							
					if (atof( pbd_InRecOwner[PER_CUTSHA_R] ) != 0)
						d_BC_01 = d_CalculBurningCost( (char)( atoi( pbd_InRecOwner[PER_SUPLOATYP_CT] ) ),
 							//atof( pbd_InRecOwner[PER_SBJPRM_M] ), // ==> (Kd_PrmAmt-kd_AmtcPNA) / d_CUTSHA_R   (Future Fixe - UPR) / d_CUTSHA_R  // (Kd_PrmAmt-Kd_UPR) / ( atof( pbd_InRecOwner[PER_PRMMINEFF_R]) *  atof( pbd_InRecOwner[PER_CUTSHA_R])
 							((Kd_PrmAmt-Kd_UPR) / ( atof( pbd_InRecOwner[PER_PRMMINEFF_R]) *  atof( pbd_InRecOwner[PER_CUTSHA_R]))),
 							Kd_Claim_Amt,
							atof( pbd_InRecOwner[PER_PRMMINEFF_R] ), 
							atof( pbd_InRecOwner[PER_PRMMAXEFF_R] ),
							atof( pbd_InRecOwner[PER_PRMEFFLOA_M] ), 
							atof( pbd_InRecOwner[PER_PRMEFFLOA_R] ),
							atof( pbd_InRecOwner[PER_CUTSHA_R] ), 
							atof( pbd_InRecOwner[PER_RIDSHA_R] ),
							(char)( atoi( pbd_InRecOwner[PER_LIARIDSHA_B] ) ) ) ;	

					// Calcul du BC final :
					
					d_BC = d_BC_01 -(Kd_PrmAmt-Kd_UPR) ;
					
#ifdef TRACE_BURNING_COST_INC							
      if  ( (strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0027378") == 0	 || strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0019330") == 0 ) && 	atoi(pbd_InRecOwner[PER_UWY_NF]) == 2019)	
      { 		
	    printf(" 01 CALCUL BURNING COST INCEPTION PER_CTR_NF, PER_END_NT, PER_SEC_NF, PER_UWY_NF, GT_TRNCOD_CF,  d_BC, Kd_Claim_Amt, Kd_PrmAmt,  kd_AmtcPNA, Kd_UPR,  d_LOSRAT_R : %s ;%s ;%s ;%s ;%s;%-3.f;%-3.f;%-3.f ;%-3.f ; %f;  %-3.f ;\n", pbd_InRecOwner[PER_CTR_NF], pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_TRNCOD_CF], d_BC, Kd_Claim_Amt, Kd_PrmAmt,kd_AmtcPNA, Kd_UPR, d_LOSRAT_R);
		}	
#endif	
												
				}				
				else
				{
					/********************************************************/
					/* appel du module de calcul de Prime de reconstitution */
					/********************************************************/
						
					d_RP = (d_CalculPrimeReconstitution( 
					(char)( atoi( pbd_InRecOwner[PER_REIEXI_B] ) ),  
					(char)( atoi( pbd_InRecOwner[PER_REIUNL_B] ) ),  
					(char)( atoi( pbd_InRecOwner[PER_REIFRE_B] ) ),  
					(char)( atoi( pbd_InRecOwner[PER_REINBR_N] ) ),  
					atof( pbd_InRecOwner[PER_SBJPRM_M] ),
					Kd_Claim_Amt,   
					(Kd_PrmAmt-Kd_UPR), 					
					// with other UPR (Kd_PrmAmt-kd_AmtcPNA), 									                          
					atof( pbd_InRecOwner[PER_LAYCAP_M] ),
					atof( pbd_InRecOwner[PER_CUTSHA_R] ), 
					atof( pbd_InRecOwner[PER_RIDSHA_R] ),
					(char)( atoi( pbd_InRecOwner[PER_LIARIDSHA_B] ) ), 
					Ktbd_Rec ) - (Kd_PrmAmt-Kd_UPR));		// with other UPR : Ktbd_Rec ) - (Kd_PrmAmt-kd_AmtcPNA));																		  
					
#ifdef TRACE_PRIME_RECONSTITUTION_INC
      if  ( (strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0027378") == 0	 || strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0019330") == 0 ) && 	atoi(pbd_InRecOwner[PER_UWY_NF]) == 2019)	
      { 		
			printf(" TRACE_FUTURE_CLAIMS INCEPTION Future Claim calculation pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], GT_TRNCOD_CF, pFutures->FUCLAIM, Kd_Claim_Amt, kd_AmtcPNA KdUPR, Kd_PrmAmt, d_LOSRAT_R  %s ;%s; %s; %s ; %s ; %-.3f ; %-.3f ; %-.3f  %f; %-.3f] ; %-.3f\n", pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF],  pbd_InRecChild[GT_TRNCOD_CF],pFutures->FUCLAIM, Kd_Claim_Amt, kd_AmtcPNA,Kd_UPR, Kd_PrmAmt, d_LOSRAT_R);			
	    printf(" 01 CALCUL DE LA PRIME DE RECONSTITUTION INCEPTION PER_CTR_NF, PER_END_NT, PER_SEC_NF, PER_UWY_NF, GT_TRNCOD_CF,  d_RP, Kd_Claim_Amt, Kd_PrmAmt,  kd_AmtcPNA, Kd_UPR,  d_LOSRAT_R : %s ;%s ;%s ;%s ;%s;%-3.f;%-3.f;%-3.f ;%-3.f ; %f;  %-3.f ;\n", pbd_InRecOwner[PER_CTR_NF], pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_TRNCOD_CF], d_RP, Kd_Claim_Amt, Kd_PrmAmt,kd_AmtcPNA, Kd_UPR, d_LOSRAT_R);
		}
#endif						

				}
			}
			else
			{
				/********************************************************/
				/* appel du module de calcul de Prime de reconstitution */
				/********************************************************/
					
				d_RP = (d_CalculPrimeReconstitution( 
					(char)( atoi( pbd_InRecOwner[PER_REIEXI_B] ) ),  
					(char)( atoi( pbd_InRecOwner[PER_REIUNL_B] ) ),  
					(char)( atoi( pbd_InRecOwner[PER_REIFRE_B] ) ),  
					(char)( atoi( pbd_InRecOwner[PER_REINBR_N] ) ),  
					atof( pbd_InRecOwner[PER_SBJPRM_M] ),
					Kd_Claim_Amt,   
					(Kd_PrmAmt-Kd_UPR), // with other UPR :	(Kd_PrmAmt-kd_AmtcPNA), 									                          
					atof( pbd_InRecOwner[PER_LAYCAP_M] ),
					atof( pbd_InRecOwner[PER_CUTSHA_R] ), 
					atof( pbd_InRecOwner[PER_RIDSHA_R] ),
					(char)( atoi( pbd_InRecOwner[PER_LIARIDSHA_B] ) ), 
					Ktbd_Rec ) - (Kd_PrmAmt-Kd_UPR));		 // with other UPR : Ktbd_Rec ) - (Kd_PrmAmt-kd_AmtcPNA));																		  
					
#ifdef TRACE_PRIME_RECONSTITUTION_INC
      if  ( (strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0027378") == 0	 || strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0019330") == 0 ) && 	atoi(pbd_InRecOwner[PER_UWY_NF]) == 2019)	
	printf(" 02 CALCUL DE LA PRIME DE RECONSTITUTION INCEPTION  PER_CTR_NF, PER_END_NT, PER_SEC_NF, PER_UWY_NF, GT_TRNCOD_CF,  d_RP, Kd_Claim_Amt, Kd_PrmAmt,  kd_AmtcPNA, Kd_UPR, d_LOSRAT_R : %s ;%s ;%s ;%s ;%s;%-3.f;%-3.f;%-3.f ;%-3.f ; %f; %-3.f ;\n", pbd_InRecOwner[PER_CTR_NF], pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_TRNCOD_CF], d_RP, Kd_Claim_Amt, Kd_PrmAmt,kd_AmtcPNA, Kd_UPR, d_LOSRAT_R);
#endif

			}				// Future Variable Premium (10002) = Reinstatement Premium + Burning Cost Premium (MONTANT* (d_BC+ d_RP)
				
				d_Amt = d_RP + d_BC ;
				
//			} 
//			else 
//			{ 
//					d_Amt = 0 ; // on ne calcule pas les Futures pour les FAC et les Proportionnels.				
//			} 
								
				sprintf( sz_Amt, "%-.3f", d_Amt );
				strcpy( sz_Trncod, "1110015" ); 				 // METTRE A JOUR LE TRNCOD AT INCEPTION --> "1110015" + "NORME")   AVEC  NORME IN ("I", "K", "M")
				strcat( sz_Trncod, Kc_Norme_Suf) ;				
			  pFutures->TRNCOD = sz_Trncod;						
		 	
				pFutures->FUVPREMIUM = d_Amt;				// Future Variable premium,
				Kd_PrmVarAmt = d_Amt ; 							// Sauvegarde de la Future Variable Premium		
				
				//n_EcrireLog(); 				

			if ( fabs(atof(sz_Amt)) > 1)
			{ 
	
#ifdef TRACE_FUTURE_VAR_INC_PRM	
      if  ( (strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0027378") == 0	 || strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0019330") == 0 ) && 	atoi(pbd_InRecOwner[PER_UWY_NF]) == 2019)							
	printf(" Future Variable Premium INCEPTION pbd_InRecOwner[PER_CTR_NF], END_NT, PER_SEC_NF, UWY_NF, GT_TRNCOD_CF, Kd_PrmVarAmt, REINSTATEMENT_PREMIUM, BURNING_COST : %s ; %s ; %s; %s ; %s; %-.3f ; %-.3f ; %-.3f \n", pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF],  pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_TRNCOD_CF], Kd_PrmVarAmt, d_RP, d_BC);			
#endif						
					n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );				
			}
			  
			  
		// [014] Deb Gestion "Future Brokerage" AT Inception 
		// [016] R04-05 : Assumed Future Brokerage =  Brokerage Rate * Future Fixed Premium * -1
		// Assumed Future Brokerage =  Brokerage Rate * Future Fixed Premium
		// Kd_BrkRat : Brokerage Rate calculated and stored FLOARAT_EBS file						
		
			if ( fabs(Kd_PrmAmt) >= 1  && (*pbd_InRecOwner[PER_CTRNAT_CT] != 'N'))  // Cas des FAC et TRAITES PROPORTIONNELS
			{
								  
			  d_Amt = Kd_BrkRat * Kd_PrmAmt  ; 						//[016]   (-1); Attention le signe (-1) est deja pris en compte a l'extraction du taux de la table LOARAT
			  Kd_FuturBrk = d_Amt ; 
				pFutures->FUBROKER = d_Amt;									// Future Brokerage	
				
#ifdef TRACE_FUTURE_INC_BROKERAGE	
      if  ( (strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0027378") == 0	 || strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0019330") == 0 ) && 	atoi(pbd_InRecOwner[PER_UWY_NF]) == 2019)							                                                                                                                                                					
			printf(" 0000 TRACE_FUTURE_INC_BROKERAGE Future Brokerage pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], GT_TRNCOD_CF, Kd_FuturBrk, Kd_BrkRat, Kd_PrmAmt : %s ;  %s ; %s ; %s ; %s ;  %-.3f ; %-.3f ; %-.3f \n", pbd_InRecOwner[PER_CTR_NF], pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF],  pbd_InRecChild[GT_TRNCOD_CF], Kd_FuturBrk, Kd_BrkRat, Kd_PrmAmt);					
#endif						  
			  
			}					

		// [039] Calcul FUTURE BROKERAGE NOUVELLE FORMULE, Uniquement pour les Non Proportionnels
		/****************************************************************************************************/
		/*  Assumed Future Brokerage =  Brokerage Rate * Future Fixed Premium * -1                          */
		/*                              + Brokerage Rate * Future Variable Premium * -1 (If Burning Cost)   */
		/*                              + Reinstatement Brokerage Rate * Future Variable Premiums * -1      */
		/****************************************************************************************************/
				
		/* Brokerage Rate * Future Fixed Premium * -1) + (Reinstatement Brokerage Rate (TFAMCH.RECBRK_R) * Future Variable Premiums * -1) */
			
			if (*pbd_InRecOwner[PER_CTRNAT_CT] == 'N')
			{
				if ( *pbd_InRecOwner[PER_FLAPRM_B] == '0' && *pbd_InRecOwner[PER_PRMFLCRAT_B] == '1' )
				{
           Kd_FuturBrk = (Kd_PrmAmt * Kd_BrkRat) + (Kd_PrmVarAmt * Kd_BrkRat);
        }
				else
				{
           Kd_FuturBrk = (Kd_PrmAmt * Kd_BrkRat) + (Kd_PrmVarAmt * atof(pbd_InRecOwner[PER_RECBRK_R]) * (-1));
        }
			}
  
      sprintf( sz_Amt, "%-.3f", Kd_FuturBrk );
			strcpy( sz_Trncod, "1112016" );	
			strcat( sz_Trncod, Kc_Norme_Suf) ; 				
			pFutures->TRNCOD = sz_Trncod;	
           
      n_EcrireLog();

      if ( fabs(atof(sz_Amt)) > 1)
      {
#ifdef TRACE_FUTURE_INC_BROKERAGE
      if  ( (strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0027378") == 0	 || strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0019330") == 0 ) && 	atoi(pbd_InRecOwner[PER_UWY_NF]) == 2019)	                                                                                                                                                                                  
         printf(" TRACE_FUTURE_INC_BROKERAGE Future Brokerage pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], GT_TRNCOD_CF, Kd_FuturBrk, Kd_BrkRat, pFutures->FUBROKER : %s ;  %s ; %s ; %s ; %s ;  %-.3f ; %-.3f ; %-.3f \n", pbd_InRecOwner[PER_CTR_NF], pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF],  pbd_InRecChild[GT_TRNCOD_CF], Kd_FuturBrk, Kd_BrkRat, pFutures->FUBROKER);
#endif        	
        	
           n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );
      }				  
							
		} // On inclut le calcul des FUTURES VARIABLES PREMIUM DANS LA CONDITION "1A110002"			

			
			// gestion Charge future : 1A120002 Correspond aux commissions actuellement
			// Assumed Future Fixed Charges = Fixed Commission Rate  * Future Fixed Premium (R04 - 01)
				
			
			/*******************************************************************************************************************/
			/*      Le calcul des FUTURS  CHARGES SE BASE SUR LE TRNCOD "1A120002", defini dans ESID2003A au step 80 et 90 ;   */ 
			/*      le PRS_CF utilise est le 713, Ancienne formule du prog ESTC1064                                            */ //027
			/*******************************************************************************************************************/
			
			//[038] if ( strcmp(pbd_InRecChild[GT_TRNCOD_CF], "1A120002") == 0 && ((kd_AmtcPRM + kd_AmtcPRT) != 0) && kc_FlagPNAseul == 'N' )  	//027]	
				
			//if ( strcmp(pbd_InRecChild[GT_TRNCOD_CF], "1A120002") == 0 && ((kd_AmtcPRM + kd_AmtcPRT) != 0) )				
			{ 
				pFutures->AMTCEXP_M = atof(pbd_InRecChild[GT_AMT_M]);
				 
				// DEb [013] Calcul charge future --> Future Charge Fixe : 
				// Assumed Future Fixed Charges = Fixed Commission Rate  * Future Fixed Premium
				
				
				// Calcul de la valeur de Fixed Commission Rate, par appel de d_CalculChargesCommissions :							

	/***********************************************************************************/
	/* Appel de la fonction d_CalculChargesCommissions de calcul du Taux de Commission */
	/***********************************************************************************/
	
			  
				  k_TCom = d_CalculChargesCommissions(
												(char)( atoi( pbd_InRecOwner[PER_PRMNETCOM_B] ) ),
												( *pbd_InRecOwner[PER_CTRNAT_CT] == 'F' ? 1 : (char)( atoi( pbd_InRecOwner[PER_COMTYP_CT] ) ) ),
												atof( pbd_InRecOwner[PER_FIXCOM_R] ),
												atof( pbd_InRecOwner[PER_MAXCOM_R] ),
												atof( pbd_InRecOwner[PER_MINRATCLP_R] ),
												atof( pbd_InRecOwner[PER_MINCOM_R] ),
												atof( pbd_InRecOwner[PER_MAXRATCLP_R] ),
												Kd_Claim_Amt,
												//(Kd_PrmAmt-kd_AmtcPNA), 		// Montant Prime future Fixe + Montant UPR / PNA [015] (Kd_PrmAmt-Kd_UPR), 
												(Kd_PrmAmt-Kd_UPR),
												Kn_NbFam,   
												Ktbd_FamCha 
												) ;	
												
				// La future Charge fixe n est calculée que si le type de commission est fixe (COMTYP != 	 )et La FUTURE FIXE PREMIUM  != 0)	
				
// [034] 				if (strcmp(pbd_InRecOwner[PER_CTRNAT_CT], "F")==0 || ( *pbd_InRecOwner[PER_COMTYP_CT]  == '2' || *pbd_InRecOwner[PER_COMTYP_CT]  == '4' || *pbd_InRecOwner[PER_COMTYP_CT]  == '5') )    



				if ( ( *pbd_InRecOwner[PER_COMTYP_CT]  == '2')) 
					d_Amt = 0;
				else						
				//	d_Amt = (atof(pbd_InRecChild[GT_AMT_M]) * d_taux / (kd_AmtcPRM + kd_AmtcPRT)) * (Kd_PrmAmt); //[06] [011]					
				d_Amt =  (Kd_ComRat + Kd_SurComRat + Kd_Tax) * (Kd_PrmAmt) ; //[043] Les montants sont deja negatifs, ne palus tenir compte du (-1)
	
				sprintf( sz_Amt, "%-.3f", d_Amt );
				strcpy( sz_Trncod, "1112014" );	     // METTRE A JOUR LE TRNCOD AT INCEPTION --> "1112014" + "NORME")   AVEC  NORME IN ("I", "K", "M")
				strcat( sz_Trncod, Kc_Norme_Suf) ;				
			  pFutures->TRNCOD = sz_Trncod;								    							    
				
				Kd_FuturCharge  = d_Amt;			
				
				pFutures->FUFEXP = d_Amt;											//  Future fixed commissions	appele aussi FUTURE FIXE Charge		

				pbd_InRecChild[GT_RETAMT_M] = "0";
				pbd_InRecChild[GT_RETINTAMT_M] = "0";
				pbd_InRecChild[GT_TRNCOD_CF] = sz_Trncod;
				pbd_InRecChild[GT_DBLTRNCOD_CF] = sz_Dblcod;
				pbd_InRecChild[GT_AMT_M] = sz_Amt;
				pbd_InRecChild[GT_CUR_CF] = sz_Cur;
								
				
				//n_EcrireLog(); 

				if ( fabs(atof(sz_Amt)) > 1)
				{
					
#ifdef TRACE_FUTURE_INC_FIXE_CHARGE							
			printf(" 01 Future Fixe Charge Inc pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecOwner[PER_COMTYP_CT], pbd_InRecChild[GT_TRNCOD_CF], pFutures->FUFEXP,  k_TCom,  Kd_PrmAmt :  %s ;%s ; %s ; %s ;%s ; %s ; %lf ; %lf ; %lf \n", pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecOwner[PER_COMTYP_CT], pbd_InRecChild[GT_TRNCOD_CF], pFutures->FUFEXP, k_TCom, Kd_PrmAmt);			
#endif						
					 
					n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );	
				}
					
				
				// Deb [013]   Future Variable commissions INCEPTION future  --> Future Charge Variable : "1112015"		+ "NORME"  AVEC  NORME IN ("I", "K", "M")				


		
	/* complement des affectations des postes du tableau des participations */ 
			// [032] Ktbd_Par[Kn_Par_Nbp].PRMAMT_M = Kd_PrmAmt-Kd_UPR ;   	// [015] Future Fixed Premium (calculated in R02-01) - UPR == [Prime Acquise Comptabilisee + prime cedante ] --> kd_AmtcPNA
			// [032] Ktbd_Par[Kn_Par_Nbp].ACCRES_M = Kd_PrmAmt-Kd_UPR + ( Kd_FuturCharge - Kd_DAC + Kd_Claim_Amt + Kd_FuturBrk) ; // [015] Rsesult Account
			
			Ktbd_Par[Kn_Par_Nbp].PRMAMT_M = Kd_PrmAmt ;   	// [015] Future Fixed Premium (calculated in R02-01) - UPR == [Prime Acquise Comptabilisee + prime cedante ] --> kd_AmtcPNA
			Ktbd_Par[Kn_Par_Nbp].ACCRES_M = Kd_PrmAmt-Kd_UPR + ( Kd_FuturCharge - Kd_DAC + Kd_Claim_Amt + Kd_FuturBrk) ; // [015] Rsesult Account			
			
//			Ktbd_Par[Kn_Par_Nbp].ACCRES_M = Kd_PrmAmt-kd_AmtcPNA - ( Kd_FuturCharge + Kd_DAC + Kd_Claim_Amt) ; // [015] Rsesult Account			


#ifdef TRACE_FUTURE_INC_VARIABLE_CHARGE	
			printf(" PRIME (P) : Inc [PER_CTR_NF],  Fut_Prime, Prime01,  Kd_PrmAmt,   Kd_UPR, kd_AmtcPNA : %s ; %-3.f ;  %-3.f ; %-3.f ; %-3.f ; %-3.f\n", 
			                            pbd_InRecOwner[PER_CTR_NF], Kd_PrmAmt, Kd_PrmAmt-kd_AmtcPNA, Kd_PrmAmt, Kd_UPR, kd_AmtcPNA);							
			printf(" Result Account (Rc) : Inc [PER_CTR_NF], Result_Account, Kd_PrmAmt, Kd_UPR, kd_AmtcPNA, Kd_FuturCharge, Kd_DAC, Kd_Claim_Amt, Kd_FuturBrk : %s ; %-3.f ; %-3.f ; %-3.f; %-3.f; %-3.f ; %-3.f ; %-3.f ; %-3.f\n", 
			                            pbd_InRecOwner[PER_CTR_NF], (Kd_PrmAmt-kd_AmtcPNA - ( Kd_FuturCharge + Kd_DAC + Kd_Claim_Amt)), Kd_PrmAmt, Kd_UPR, kd_AmtcPNA, Kd_FuturCharge, Kd_DAC, Kd_Claim_Amt, Kd_FuturBrk);			
#endif

	/* incrementation du nombre de postes du tableau Ktbd_Par */
	Kn_Par_Nbp -= 1 ;

	/* incrementation du nombre de postes du tableau Ktbd_FamCha_02 */
	if ( atoi( pbd_InRecOwner[PER_CTBTYP_CT] ) == 2 )
		Kn_Fam_Nbl -= 1 ;

	/*********************************************************************/
	/* Appel de la fonction n_CalculPartBenefPert de calcul de PB et PAP */
	/*********************************************************************/

	n_PbPap_Nbp = n_CalculPartBenefPert( ( NB_PAR_MAX - Kn_Par_Nbp - 1 ), &Ktbd_Par[Kn_Par_Nbp + 1],
		&Ktn_FamUwy[Kn_Fam_Nbp + 1], &Ktbd_FamCha_02[Kn_Fam_Nbp + 1], tbd_PbPap ) ;
		

	for ( i = 0; i < n_PbPap_Nbp ; i++ )
	{
		/* positionnement du montant calcule PB */
		if ( tbd_PbPap[i].PBEX == 1 )
		{
			/* cas ou les PB/PAP ne sont pas calculables */
			if ( tbd_PbPap[i].CTCOM_B == 0 )
			{
				strcpy( sz_PbOriCod, "Account" ) ;
				d_PbCalAmt = Ktbd_EstGt[Kn_Par_Nbp + 1 + i].PB_M ;
			}
			else
			{
				strcpy( sz_PbOriCod, "CloP" ) ;
				d_PbCalAmt = tbd_PbPap[i].PB ;
			}
		}				
		
		Kd_PB= d_PbCalAmt ; // Resultat du calcul de la PB	

		/* positionnement du montant calcule PAP */
		if ( tbd_PbPap[i].PAPEX == 1 )
		{
			/* cas ou les PB/PAP ne sont pas calculables */
			if ( tbd_PbPap[i].CTCOM_B == 0 )
			{
				strcpy( sz_PapOriCod, "Account" ) ;
				d_PapCalAmt = Ktbd_EstGt[Kn_Par_Nbp + 1 + i].PAP_M ;
			}
			else
			{
				strcpy( sz_PapOriCod, "CloP" ) ;
				d_PapCalAmt = tbd_PbPap[i].PAP ;
			}
			Kd_PAP = d_PapCalAmt;   // Resultat du calcul de la PAP						
			
		}

		/* positionnement du montant retenu PB */
		if ( Ktbd_EstGt[Kn_Par_Nbp + 1 + i].PBADMMOD_CT == 'A' )
			d_PbRetAmt = d_PbCalAmt ;
		else	d_PbRetAmt = Ktbd_EstGt[Kn_Par_Nbp + 1 + i].PBENTAMT_M ;


		/* positionnement du montant retenu PAP */
		if ( Ktbd_EstGt[Kn_Par_Nbp + 1 + i].PAPADMMOD_CT == 'A' )
			d_PapRetAmt = d_PapCalAmt ;
		else	d_PapRetAmt = Ktbd_EstGt[Kn_Par_Nbp + 1 + i].PAPENTAMT_M ;			

	}
	
	/*Ecriture de Kd_PB + Kd_PAP Spira 78628 [045]*/
    sprintf( sz_Amt, "%-.3f", Kd_PB + Kd_PAP );
    strcpy( sz_Trncod, "1112019" );	   // "1112019"+ "NORME")   AVEC  NORME IN ("I", "K", "M") [052]
	strcat( sz_Trncod, Kc_Norme_Suf) ;
    pbd_InRecChild[GT_RETAMT_M] = "0";
    pbd_InRecChild[GT_RETINTAMT_M] = "0";
    pbd_InRecChild[GT_TRNCOD_CF] = sz_Trncod;
    pbd_InRecChild[GT_DBLTRNCOD_CF] = sz_Dblcod;
    pbd_InRecChild[GT_AMT_M] = sz_Amt;
    pbd_InRecChild[GT_CUR_CF] = sz_Cur;

    if ( fabs(atof(sz_Amt)) > 1)
    {
      n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );
    }
					

				// d_Amt = d_PbCalAmt + d_PapCalAmt +  d_SC ;

		/**************************************************************************/
		/*          Formules de Calcul de la Future Variable Charge               */
		/**     									                                               **/
		/**         d_Amt = Kd_PB + Kd_PAP +  Kd_SC                              **/
		/**                                                                      **/                                                 
		/**       AVEC   Kd_SC = k_TCom*(Kd_PrmAmt-Kd_UPR)                       **/ //[015]
		/**       AVEC   Kd_SC = (-1) k_TCom * Kd_PrmAmt                         **/ //[031]		
		/**************************************************************************/


				// Le taux de commission est égale à zero lorsque le type de commission n'est pas variable ;
							
				
				if (atoi( pbd_InRecOwner[PER_COMTYP_CT])  != 2)   // Si TYP_COMMISSION != 2 Alors k_Tcom = 0
					Kd_SC = 0.0 ;
				else 
					//Kd_SC = (-1)* k_TCom*(Kd_PrmAmt-Kd_UPR);	//[031]
					Kd_SC = (-1)* k_TCom*Kd_PrmAmt;		
								
                       		/*Ecriture de Kd_SC Spira 78628 [045]*/
                       	        sprintf( sz_Amt, "%-.3f", Kd_SC );
                       	        strcpy( sz_Trncod, "1112015" );	   // "1112015"+ "NORME")   AVEC  NORME IN ("I", "K", "M") [052]
				                strcat( sz_Trncod, Kc_Norme_Suf) ;    
                       	        pbd_InRecChild[GT_RETAMT_M] = "0";
                       	        pbd_InRecChild[GT_RETINTAMT_M] = "0";
                       	        pbd_InRecChild[GT_TRNCOD_CF] = sz_Trncod;
                       	        pbd_InRecChild[GT_DBLTRNCOD_CF] = sz_Dblcod;
                       	        pbd_InRecChild[GT_AMT_M] = sz_Amt;
                       	        pbd_InRecChild[GT_CUR_CF] = sz_Cur;

                       	        if ( fabs(atof(sz_Amt)) > 1)
                       	        {
                       	          n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );
                       	        }

					// with other UPR : Kd_SC = (-1)* k_TCom*(Kd_PrmAmt-kd_AmtcPNA)	 ; // Le kTCom multiplié par (-1) Kd_SC = k_TCom*(Kd_PrmAmt-Kd_UPR)	 ;

				/* [041] if (strcmp(pbd_InRecOwner[PER_CTRNAT_CT], "F")==0)  //[014]
					d_Amt = 0.0;
				else */
				
				d_Amt = Kd_PB + Kd_PAP +  Kd_SC ;   //[015]  
								
				/* [052]
				sprintf( sz_Amt, "%-.3f", d_Amt );					
				
				strcpy( sz_Trncod, "1112015" );	   // "1112015"+ "NORME")   AVEC  NORME IN ("I", "K", "M")
				strcat( sz_Trncod, Kc_Norme_Suf) ;					
			  pFutures->TRNCOD = sz_Trncod;		
			  */
			  Kd_FuturVarCharge = d_Amt;
				pFutures->FUVEXP = d_Amt;											// Future Variable Charge				
/* [052]
				pbd_InRecChild[GT_RETAMT_M] = "0";
				pbd_InRecChild[GT_RETINTAMT_M] = "0";
				pbd_InRecChild[GT_TRNCOD_CF] = sz_Trncod;
				pbd_InRecChild[GT_DBLTRNCOD_CF] = sz_Dblcod;
				pbd_InRecChild[GT_AMT_M] = sz_Amt;
				pbd_InRecChild[GT_CUR_CF] = sz_Cur;
										
				//n_EcrireLog(); 			  			
				
				if ( fabs(atof(sz_Amt)) > 1)
				{ 
					
#ifdef TRACE_FUTURE_INC_VARIABLE_CHARGE						
			printf(" Future Variable Charge Inception pbd_InRecOwner[PER_CTR_NF], pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pFutures->FUVEXP, Kd_PAP,  Kd_PB, k_TCom,  Kd_PrmAmt, kd_AmtcPNA ,Kd_UPR:  %s ; %s ; %s; %s ; %-3.f ; %-3.f ;%-3.f ; %-3.f ; %-3.f ; %-3.f ; %f \n", pbd_InRecOwner[PER_CTR_NF], pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pFutures->FUVEXP, Kd_PB, Kd_PAP, k_TCom, Kd_PrmAmt, kd_AmtcPNA,Kd_UPR);			
#endif					
					
					n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );						
			 }
*/
		 } /* Calcul des FUTUR CHARGES AT INCEPTION */
		}	

	}	

  RETURN_VAL(OK);
  
}

//[11] new function n_ActionLigneUprDac
/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneUprDac(
	char **pbd_InRecOwner , /* adresse de la ligne du maitre */
	char **pbd_InRecChild ) /* adresse de la ligne de l'esclave */
{

	char   MsgAno[300];
	char   sz_Cur[4];
	//double d_Amt;
	double d_taux;      // Taux de conversion en devise	
	
		memset( sz_Cur, 0, sizeof(sz_Cur) );	
		n_type_trn_cd = n_check_trncd_cf(pbd_InRecChild[GT_TRNCOD_CF], &kn_est_ITDP); 


		
// [033] Mise à jour Taux DAC, UPR si monnaie EGPI differe ligne DAC, UPR, PRME, COME

		/* Recherche taux pour conversion du montant acceptation en devise aliment */
		d_taux = 1;

		sprintf( sz_Cur, "%s", pbd_InRecOwner[PER_EGPCUR_CF] );
		if ( strcmp( pbd_InRecChild[GT_CUR_CF], pbd_InRecOwner[PER_EGPCUR_CF] ) != 0 )
		{
			sprintf( sz_Cur, "%s", pbd_InRecOwner[PER_EGPCUR_CF] );
			d_taux = d_GetTaux( Kp_InputFilExc, (char) atoi( pbd_InRecChild[GT_SSD_CF] ), atoi( pbd_InRecChild[GT_BALSHEY_NF] ), pbd_InRecChild[GT_CUR_CF], pbd_InRecOwner[PER_EGPCUR_CF] );
		}

		/* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
		if ( d_taux < 0 )
		{
			sprintf( MsgAno, "The rates of acceptation currency ( %s ) and EGPI currency ( %s ) aren't known for the perimeter contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) and BALSHEY %s \n", pbd_InRecChild[GT_CUR_CF], pbd_InRecOwner[PER_EGPCUR_CF], pbd_InRecChild[GT_CTR_NF],  pbd_InRecChild[GT_END_NT], pbd_InRecChild[GT_SEC_NF], pbd_InRecChild[GT_UWY_NF], pbd_InRecChild[GT_UW_NT], pbd_InRecChild[GT_BALSHEY_NF] );
			n_WriteAno( MsgAno );
			/* montant positionne a zero */
			Kd_UPR = 0;
			Kd_DAC = 0;
			Kd_PRME = 0;
			Kd_COME = 0;
			//REQ 10.13
                        Kd_DACVAR = 0;
                        Kd_DACBRK = 0;
                        Kd_COMEVAR = 0;
                        Kd_COMEBRK = 0;
		}
		else
		{ 	

#ifdef TRACE_UPR_DAC			
		printf(" UPR_DAC trn_cd, type, ctr, sec, uwy, GT_CUR, EGPI_CUR : %s ;%d ;%s ;%s; %s; %s; %s  \n", pbd_InRecChild[GT_TRNCOD_CF], n_type_trn_cd , pbd_InRecChild[GT_CTR_NF], pbd_InRecChild[GT_SEC_NF], pbd_InRecChild[GT_UWY_NF], pbd_InRecChild[GT_CUR_CF], pbd_InRecOwner[PER_EGPCUR_CF] ); 
#endif		
		if ( n_type_trn_cd == UPR )
		{
			c_UPR_FLG = 'Y';
			Kd_UPR += atof(pbd_InRecChild[GT_AMT_M])*d_taux;	
		}

		if ( n_type_trn_cd == DAC )
		{
			c_DAC_FLG = 'Y';
			Kd_DAC += atof(pbd_InRecChild[GT_AMT_M])*d_taux ;	
		}
		   
		if ( n_type_trn_cd == PRME )
		{
			c_PRME_FLG = 'Y';
			Kd_PRME += atof(pbd_InRecChild[GT_AMT_M]) ;	
		}	

		if ( n_type_trn_cd == COME )
		{
			c_COME_FLG = 'Y';
			Kd_COME += atof(pbd_InRecChild[GT_AMT_M]) ;	
		}
		if ( n_type_trn_cd == COMEVAR )
                {
                        c_COMEVAR_FLG = 'Y';
                        Kd_COMEVAR += atof(pbd_InRecChild[GT_AMT_M]) ;
                }
                if ( n_type_trn_cd == COMEBRK )
                {
                        c_COMEBRK_FLG = 'Y';
                        Kd_COMEBRK += atof(pbd_InRecChild[GT_AMT_M]) ;
                }
                if ( n_type_trn_cd == DACBRK )
                {
                        c_DACBRK_FLG = 'Y';
                        Kd_DACBRK += atof(pbd_InRecChild[GT_AMT_M])*d_taux ;
                }
                if ( n_type_trn_cd == DACVAR )
                {
                        c_DACVAR_FLG = 'Y';
                        Kd_DACVAR += atof(pbd_InRecChild[GT_AMT_M])*d_taux ;
                }	
		
   } // fin du ( d_taux < 0 )		
	
	
	RETURN_VAL( OK );
}



/*==============================================================================
objet:
        Lit le fichier binaire FSEGEST et le charge en memoire

==============================================================================*/
int n_ChargerTSEGEST( void )
{
	int i = 0 ;
	char sz_message[200];

	DEBUT_FCT("n_ChargerTSEGEST");


	char buffer[LGTH_SEGEST];
	char **tab=NULL;
	while (fgets( buffer, LGTH_SEGEST, Kp_InputFilSegest)!= NULL)
	{
		
		tab = split(buffer, SEPARATOR ,1);
		Ktbd_Segest[i].SSD_CF = atoi(tab[SEG_SSD_CF]);
		//Pour le segment spéciale * on ne prend que ce caractère !
		if ( tab[SEG_SEG_NF][0] == '*')
			strcpy(Ktbd_Segest[i].SEG_NF, "*");
		else
			strcpy(Ktbd_Segest[i].SEG_NF, tab[SEG_SEG_NF]);
		Ktbd_Segest[i].UWY_NF = atoi(tab[SEG_UWY_NF]);
		strcpy(Ktbd_Segest[i].CUR_CF, tab[SEG_CUR_CF]);
		Ktbd_Segest[i].SEGNAT_CT = *tab[SEG_SEGNAT_CT];
		Ktbd_Segest[i].CLMAMT_M = atof(tab[SEG_CLMAMT_M]);
		Ktbd_Segest[i].LOSRAT_R = atof(tab[SEG_LOSRAT_R]);
		Ktbd_Segest[i].AMORAT_CT = *tab[SEG_AMORAT_CT];
		Ktbd_Segest[i].SEGTYP_CT = *tab[SEG_SEGTYP_CT];		

		i++;

		if ( i > NB_SEGEST_MAX )
		{
			sprintf(sz_message,"la taille du tableau Ktbd_Segest depasse la taille allouee %d", i);
			n_WriteAno(sz_message);
			RETURN_VAL( i );
		}
	}


	RETURN_VAL( i );
}


/*==============================================================================
objet :
        fonction de recherche du segment
        1ere recherche avec exercice = 8888.
        Si pas trouve, recherche avec exercice du perimetre :
           soit le plus ancien, soit celui egal
retour :

==============================================================================*/
int n_RechPosteTSEGEST( char c_ssd, char *sz_seg, int n_uwy, char * sz_segtyps  )   // [10]
{
	int n_indice, n_indiceEx, n_ret;
	char c_flgSegest = 'N';
	n_indiceEx = -1;
	DEBUT_FCT("n_RechPosteTSEGEST");

	for( n_indice = 0; n_indice < Kn_NbLig_Segest; n_indice++ )
	{
		// Localisation filiale
		n_ret = (int) c_ssd - Ktbd_Segest[n_indice].SSD_CF;

		if ( n_ret < 0) 
		{
			if (c_flgSegest == 'N')
				RETURN_VAL( -1 ) ;
			else
			{
				RETURN_VAL(n_indiceEx);
			}
		}
		if ( n_ret > 0 ) continue ;
		else
		{
			// Localisation Segment
			if ( strcmp(sz_seg, Ktbd_Segest[n_indice].SEG_NF) != 0 && c_flgSegest == 'N' ) continue;
			if ( strcmp(sz_seg, Ktbd_Segest[n_indice].SEG_NF) != 0 && c_flgSegest == 'Y' ) {RETURN_VAL( n_indiceEx );}
			if ( strcmp(sz_seg, Ktbd_Segest[n_indice].SEG_NF) == 0 && strchr( sz_segtyps, Ktbd_Segest[n_indice].SEGTYP_CT )   ) // [10] IFRS17 req 10.6
			{
				// Localisation exercice
				if ( c_flgSegest == 'N' && strcmp(sz_segtyps, "ATU") == 0) n_indiceEx = n_indice;                    // Plus ancien exercice trouvé
				if ( Ktbd_Segest[n_indice].UWY_NF == n_uwy ) n_indiceEx = n_indice; // Exercice exact trouvé
				c_flgSegest = 'Y';
				if ( Ktbd_Segest[n_indice].UWY_NF == 8888 ) {RETURN_VAL( n_indice );} // Exercice 8888 trouvé prioritaire
			}
		}
	}
	if ( c_flgSegest == 'Y' ) {RETURN_VAL( n_indiceEx );}  // [001]
	else RETURN_VAL( -1 );	// Aucune occurence trouvée
}

/*==============================================================================
objet :
        fonction de sortie de la log FUTURES

==============================================================================*/
/*void n_EcrireLog()
{


	fprintf(p_OutputFutures ,"%i~%i~%s~%i~%i~%i~%s~%-.3f~%s~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~\n",
pFutures->SSD_CF, 
pFutures->ESB_CF, 
pFutures->CTR_NF,
pFutures->END_NT,
pFutures->SEC_NF,
pFutures->UWY_NF,
pFutures->SEG_NF,
pFutures->SCOEGP_M,
pFutures->CUR_CF,
pFutures->AMTCEXP_M,
pFutures->AMTCPRM_M,
pFutures->AMTCPNA,
pFutures->LOSRAT_R,
pFutures->TAUX,
pFutures->FUPREMIUM,
pFutures->FUCLAIM,
pFutures->FUEXP);
}
*/

/* */
void n_EcrireLog()
{


	fprintf(p_OutputFutures ,"%i~%i~%s~%i~%i~%i~%s~%-.3f~%s~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%s~\n",
pFutures->SSD_CF, 
pFutures->ESB_CF, 
pFutures->CTR_NF,
pFutures->END_NT,
pFutures->SEC_NF,
pFutures->UWY_NF,
pFutures->SEG_NF,
pFutures->SCOEGP_M,
pFutures->CUR_CF,
pFutures->AMTCEXP_M,
pFutures->AMTCPRM_M,
pFutures->AMTCPNA,
pFutures->LOSRAT_R,
pFutures->TAUX,
pFutures->FUFPREMIUM,
pFutures->FUVPREMIUM,
pFutures->FUCLAIM,
pFutures->FUFEXP,
pFutures->FUVEXP,
pFutures->FUBROKER,
pFutures->TRNCOD);
}
/**/



/*==============================================================================
objet :
  Chargement du tableau FBOTRSLNK
retour :
  Taille du tableau
==============================================================================*/
int n_ChargerFBOTRSLNK()
{
  int i = 0 ;
  char flg_tcode ;

  DEBUT_FCT("n_ChargerFBOTRSLNK");

  while (fread(&Ktbd_FBOTRSLNK[i], sizeof(T_FBOTRSLNK), 1, Kp_FBOTRSLNK) == 1)
    {
			
		if (   Ktbd_FBOTRSLNK[i].DETTRS_CF[1] == '1' || Ktbd_FBOTRSLNK[i].DETTRS_CF[1] == '4' 
			  || Ktbd_FBOTRSLNK[i].DETTRS_CF[1] == 'A' || Ktbd_FBOTRSLNK[i].DETTRS_CF[1] == 'E' ) 
			   flg_tcode = 'Y';
		else flg_tcode = 'N';
			
					
		if (  
( Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 101  && Ktbd_FBOTRSLNK[i].TRSTYP_NT ==3 && Ktbd_FBOTRSLNK[i].DETTRS_CF[7] == '2' && flg_tcode == 'Y' ) // Premium Estimates
                           ||( Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2010
                               || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2011
                               || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2012
                               || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2013
                               || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2019 ) // Commission Estimates [044]
                           ||( Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 103  && Ktbd_FBOTRSLNK[i].TRNTYP_CT < 100 && Ktbd_FBOTRSLNK[i].TRSPFX_CF == '1' && flg_tcode == 'Y' ) // UPR
                           ||( Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2030 ) // DAC [044]
                           ||( Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 1010 ) // ITDP
                           ||( Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2032 ) // DACVAR [044]
                           ||( Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2031 ) // DACBRK [044]
                           ||( Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2015
                               || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2016
                               || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2017
                               || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2018 ) // Commission Variable [044]
                           ||( Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2014 ) // Commission Brokerage [044]
                 )
                 {

		/*
 		printf("\nDETTRS_CF[%s];TRNTYP_CT[%d]-------TRSPFX_CF[%c];ACMTRSL0_NT[%d];ACMTRSL1_NT[%d];ACMTRSL2_NT[%d];ACMTRSL3_NT[%d];TRSTYP_NT[%d];DETTRS_CF[%s];PCPTRS_CF[%s];TRS_CF[%c];SUBTRS_CF[%s];ESTIM_NT[%d]\n", Ktbd_FBOTRSLNK[i].DETTRS_CF,Ktbd_FBOTRSLNK[i].TRNTYP_CT,
                Ktbd_FBOTRSLNK[i].TRSPFX_CF,       //char    TRSPFX_CF;
                Ktbd_FBOTRSLNK[i].ACMTRSL0_NT,     //short   ACMTRSL0_NT;
                Ktbd_FBOTRSLNK[i].ACMTRSL1_NT,     //short   ACMTRSL1_NT;
                Ktbd_FBOTRSLNK[i].ACMTRSL2_NT,     //short   ACMTRSL2_NT;
                Ktbd_FBOTRSLNK[i].ACMTRSL3_NT,     //short   ACMTRSL3_NT;
                Ktbd_FBOTRSLNK[i].TRSTYP_NT,       //short   TRSTYP_NT;
                Ktbd_FBOTRSLNK[i].DETTRS_CF,       //char        DETTRS_CF[9];
                Ktbd_FBOTRSLNK[i].PCPTRS_CF,       //char        PCPTRS_CF[3];
                Ktbd_FBOTRSLNK[i].TRS_CF,          //char        TRS_CF;
                Ktbd_FBOTRSLNK[i].SUBTRS_CF,       //char        SUBTRS_CF[3];
                Ktbd_FBOTRSLNK[i].ESTIM_NT         //short       ESTIM_NT;[%s][%c]
                );	
		       */
		  i += 1;				
         }


  
        if ( i > Kn_MaxLigFBOTRSLNK )
        {
            n_WriteAno("Depassement de capacite du tableau Ktbd_FBOTRSLNK");
            RETURN_VAL(-1);
        }

    }
  if ( i == 0 )
  {
     n_WriteAno("Fichier FBOTRSLNK vide");
     RETURN_VAL(-1);
  }
  
  RETURN_VAL(i);
}




// [11] fonction n_check_trncd_cf
/*==============================================================================
objet :
 fonction de recherche du trncod
retour :
         UPR   1  UPR
         DAC   2  DAC
         COME  3  Commission Estimates
         PRME  4  Premium Estimates
         ITDP  5  ITD Written Premium
         OTHER 6  Others
         DACVAR 7 // DAC Variable
         DACBRK 8 // DAC Brokerage
         COMEVAR 9 // Commissions Estimates Variable
         COMEBRK 10 // Commissions Estimates Brokerage

==============================================================================*/
int n_check_trncd_cf(char *sz_TrnCd, int *n_est_ITDP)
{
        int i ;
        char  flg_tcode;
        //n_est_ITDP = 0 ;
        
        

        DEBUT_FCT("n_check_trncd_cf");



        for ( i = 0; i <  Kn_FBOTRSLNK ; i++ )
        {
        if ( strcmp( sz_TrnCd, Ktbd_FBOTRSLNK[i].DETTRS_CF ) == 0 )
        {
                  

		   		if ( Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 1010 ) // ITDP ITD Written Premium 1010
		  		{
		  		//printf(" UN CAS :n_check_trncd_cf  Ktbd_FBOTRSLNK[i].ACMTRSL2_NT=%d ; Ktbd_FBOTRSLNK[i].ACMTRSL3_NT=%d \n", Ktbd_FBOTRSLNK[i].ACMTRSL2_NT, Ktbd_FBOTRSLNK[i].ACMTRSL3_NT) ;
					*n_est_ITDP = (int) ITDP ;
					}			        	


				if (   Ktbd_FBOTRSLNK[i].DETTRS_CF[1] == '1' || Ktbd_FBOTRSLNK[i].DETTRS_CF[1] == '4' 
					  || Ktbd_FBOTRSLNK[i].DETTRS_CF[1] == 'A' || Ktbd_FBOTRSLNK[i].DETTRS_CF[1] == 'E' ) 
			   		 flg_tcode = 'Y';
				else flg_tcode = 'N';

        	
        	
				if  ( Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 101  && Ktbd_FBOTRSLNK[i].TRSTYP_NT ==3 && Ktbd_FBOTRSLNK[i].DETTRS_CF[7] == '2' && Ktbd_FBOTRSLNK[i].TRSPFX_CF == '1' && flg_tcode == 'Y' ) // Premium Estimates
                                          RETURN_VAL(PRME);
                                else if ( Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2010
                                          || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2011
                                          || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2012
                                          || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2013
                                          || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2019 )  // Commission Estimates
                                          RETURN_VAL(COME);
                                else if ( Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 103 &&  Ktbd_FBOTRSLNK[i].TRNTYP_CT < 100 && Ktbd_FBOTRSLNK[i].TRSPFX_CF == '1' && flg_tcode == 'Y' )  // UPR
                                          RETURN_VAL(UPR);
                                else if ( Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2030)  // DAC
                                          RETURN_VAL(DAC);
                                else if ( Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 1010  ) // ITDP ITD Written Premium 1010
                                {
                                       // printf(" UN CAS : Ktbd_FBOTRSLNK[i].ACMTRSL2_NT=%d ; Ktbd_FBOTRSLNK[i].ACMTRSL3_NT=%d \n", Ktbd_FBOTRSLNK[i].ACMTRSL2_NT, Ktbd_FBOTRSLNK[i].ACMTRSL3_NT) ;
                                          RETURN_VAL(ITDP);
                                        }
                                 //REQ 10.13 [050]
                                else if ( Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2032 )//DAC Variable
                                          RETURN_VAL(DACVAR);
                                else if ( Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2031  )//DAC Brokerage
                                          RETURN_VAL(DACBRK);
                                else if ( Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2015
                                          || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2016
                                          || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2017
                                          || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2018 )//Commission Variable
                                          RETURN_VAL(COMEVAR);
                                else if ( Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2014  )// Commission Brokerage
                                          RETURN_VAL(COMEBRK);
                                else RETURN_VAL(OTHER); // OTHERS
				
				} // if 
				
	   } // for

        RETURN_VAL(OTHER);
}


//[013]

/*==============================================================================
objet :
  Initialisation de la synchronisation du maitre avec
  l'esclave « Montants de primes et charges »

retour :
  OK
==============================================================================*/
int n_InitPrmLoa(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_InitPrmLoa" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

  /* ouverture du fichier esclave */
  if ( n_OpenFileAppl( "ESTC1065_I7", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
    return ERR ;

  /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncPrmLoa ;

  /* fonction d'action sur la ligne courante */
  pbd_Rupt->n_ActionLigne = n_ActionLignePrmLoa ;

  pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  fonction de test de synchronisation

retour :
  0 ---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
  > 0     ---> pbd_InRecOwne> > pbd_InRecChild
  < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncPrmLoa(
  char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
  char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
  int ret ;

  DEBUT_FCT( "n_ConditionSyncPrmLoa" ) ;

  if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[PRMLOA_CTR_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[PRMLOA_END_NT] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[PRMLOA_SEC_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[PRMLOA_UWY_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[PRMLOA_UW_NT] ) ) != 0 ) return ret ;

  RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
  fonction lancee pour chaque ligne

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePrmLoa(
  char **ptb_InRecOwner , /* adresse de la ligne du maitre */
  char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
  DEBUT_FCT( "n_ActionLignePrmLoa" ) ;

  /* affectation des complements par affaire */
  switch ( atol( ptb_InRecChild[PRMLOA_ACMTRS_NT] ) )
  {
  case 10100 :
    Ktd_Comp[Charge_PRM] = atof( ptb_InRecChild[PRMLOA_ESTACC_M] ) ;
    Ktd_Comp[ChargeTaxe_PPNA] = atof( ptb_InRecChild[PRMLOA_RESERV_M] ) ;
    break ;
  case 10120 :
    Ktd_Comp[Charge_EPP] = atof( ptb_InRecChild[PRMLOA_ESTACC_M] ) ;
    Ktd_Comp[Charge_RPP] = atof( ptb_InRecChild[PRMLOA_RESERV_M] ) ;
    break ;
  case 10300 :
    Ktd_Comp[Taxe_PRM] = atof( ptb_InRecChild[PRMLOA_ESTACC_M] ) ;
    break ;
  case 10320 :
    Ktd_Comp[Taxe_EPP] = atof( ptb_InRecChild[PRMLOA_ESTACC_M] ) ;
    Ktd_Comp[Taxe_RPP] = atof( ptb_InRecChild[PRMLOA_RESERV_M] ) ;
    break ;
  case 10400 :
    Ktd_Comp[Courtage_PRM] = atof( ptb_InRecChild[PRMLOA_ESTACC_M] ) ;
    Ktd_Comp[Courtage_PPNA] = atof( ptb_InRecChild[PRMLOA_RESERV_M] ) ;
    break ;
  case 10401 :
    Ktd_Comp[Courtage_REC] = atof( ptb_InRecChild[PRMLOA_ESTACC_M] ) ;
    break ;
  case 10420 :
    Ktd_Comp[Courtage_EPP] = atof( ptb_InRecChild[PRMLOA_ESTACC_M] ) ;
    Ktd_Comp[Courtage_RPP] = atof( ptb_InRecChild[PRMLOA_RESERV_M] ) ;
    break ;
  }

  RETURN_VAL( OK ) ;
}

//[013]


//[013] DEB Fonctions de gestion synchro FLOARAT 


/*==============================================================================
objet : Initialisation de la synchronisation du maitre « PERICASE »
    	avec l’esclave « Taux de courtage »
retour :OK
==============================================================================*/
int n_InitLoaRat( T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitLoaRat" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;
	

	/* ouverture du fichier esclave des Taux de courtage */
	if ( n_OpenFileAppl( "ESTC1065_I10", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;		

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncLoaRat ;		


	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneLoaRat ;
	
	/* Fonction Pere Sans Fils */	
	pbd_Rupt->n_PereSansFils=n_ActionPereSansFilsLoaRat; //[026]

	pbd_Rupt->c_Separ = '~' ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet : fonction de test de synchronisation
retour :
	0	---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
	> 0   	---> pbd_InRecOwne> > pbd_InRecChild
	< 0   	---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncLoaRat(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncLoaRat" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[LOA_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[LOA_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[LOA_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[LOA_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[LOA_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneLoaRat(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneLoaRat" ) ;

	/* positionnement des taux de commissionnement, surcommissionnement, taxes et courtage */
	Kd_ComRat = -1 * atof( ptb_InRecChild[LOA_COMMIS_R] ) ;
	Kd_SurComRat = -1 * atof( ptb_InRecChild[LOA_OVECOM_R] ) ;
	Kd_Tax = -1 * atof( ptb_InRecChild[LOA_TAX_R] ) ;
	Kd_BrkRat = -1 * atof( ptb_InRecChild[LOA_BROKER_R] ) ;

	RETURN_VAL( OK ) ;
}


// function n_ActionPereSansFilsLoaRat  [026]
/**************************************************************************/
/*** Objet : fonction lancee quand aucune ligne du fichier FLOARAT      ***/
/***    ne correspond a la ligne courante du fichier IADPERICASE        ***/
/***                                                                    ***/
/*** Nom : n_ActionPereSansFilsLoaRat                           				***/
/***                                                                    ***/
/*** Parametres:                                                        ***/
/***    i ptsz_LigneMaitre  : pointeur sur la ligne du maitre           ***/
/***                                                                    ***/
/*** Retour:                                                            ***/
/***    OK si pas d'erreur,                                             ***/
/***    ERR si erreur.                                                  ***/
/**************************************************************************/

int n_ActionPereSansFilsLoaRat(char *ptsz_LigneMaitre[])
{
  DEBUT_FCT("n_ActionPereSansFilsLoaRat");
  
  Kd_BrkRat = 0.0;
  Kd_SurComRat = 0.0 ;
  

  RETURN_VAL(OK);
}
//[013] Fin Fonctions de gestion synchro FLOARAT

//[013] DEB Fonction de calcul de la future variable premium : 

/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription » avec
	l'esclave « fichier annexe du Perimetre de souscription IADPERIFR.dat »

retour :
	OK
==============================================================================*/
int n_InitPerFr(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitPerFr" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave GT cumule sur sinistres */
	if ( n_OpenFileAppl( "ESTC1065_I8", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;


	/* nombre de rupture a gerer sur le fichier de travail */
	pbd_Rupt->n_NbRupture = 1 ;

	/* fonction du test de rupture de niveau 1 */
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1PerFr ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncPerFr ;

	/* fonction lancee en rupture premiere */
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptPerFr ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLignePerFr ;

	/* Fonction lancee en rupture derniere */
	pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptPerFr ;

	pbd_Rupt->c_Separ = '~' ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction de test de synchronisation

retour :
	0	---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
	> 0   	---> pbd_InRecOwne> > pbd_InRecChild
	< 0   	---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncPerFr(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncPerFr" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[PERFR_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[PERFR_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[PERFR_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[PERFR_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[PERFR_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction de test de rupture de niveau 1

retour :
	0	---> pas de rupture
	sinon   	---> rupture
==============================================================================*/
int n_IsR1PerFr(
	char **pbd_InRec ,  /* adresse de la ligne en avance */
	char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
	int ret ;

	DEBUT_FCT( "n_IsR1PerFr" ) ;

	if ( ( ret = strcmp( pbd_InRec[PERFR_CTR_NF], pbd_InRec_Cur[PERFR_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[PERFR_END_NT], pbd_InRec_Cur[PERFR_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[PERFR_SEC_NF], pbd_InRec_Cur[PERFR_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[PERFR_UWY_NF], pbd_InRec_Cur[PERFR_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[PERFR_UW_NT], pbd_InRec_Cur[PERFR_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture premiere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRuptPerFr(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionFirstRuptPerFr" ) ;

	/* initialisation de la variable du rang de reconstitution */
	Kn_RecRnk = 0 ;

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePerFr(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLignePerFr" ) ;

	/* Affectation des postes du tableau de reconstitution par affaire */
	Ktbd_Rec[Kn_RecRnk].REIRNK_N = (char)( atoi( ptb_InRecChild[ PERFR_REIRNK_N ] ) ) ;
	Ktbd_Rec[Kn_RecRnk].REIPRMBAS_R = atof( ptb_InRecChild[ PERFR_REIPRMBAS_R ] ) ;
	Ktbd_Rec[Kn_RecRnk].REIPRM_M = atof( ptb_InRecChild[ PERFR_REIPRM_M] ) ;
	Ktbd_Rec[Kn_RecRnk].REIPRM_R = atof( ptb_InRecChild[ PERFR_REIPRM_R ] ) ;
	Ktbd_Rec[Kn_RecRnk].REIPROTMP_B = (char)( atoi( ptb_InRecChild[ PERFR_REIPROTMP_B ] ) ) ;

  /*printf(" Dans n_ActionLignePerFr : ptb_InRecChild[ PERFR_CTR_NF][%s] ; ptb_InRecChild[ PERFR_REIPRMBAS_R][%s] \n", ptb_InRecChild[ PERFR_CTR_NF], ptb_InRecChild[ PERFR_REIPRMBAS_R ]); 
   */

	/* incrementation du nombre de poste du tableau */
	Kn_RecRnk += 1 ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture derniere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptPerFr(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLastRuptPerFr" ) ;

	/* Positionnememt de la variable de participation */
	Kn_Pa += 16 ;

	RETURN_VAL ( OK ) ;
}

//[013] Fin Fonction de calcul de la future variable premium : 

//[013] DEB Fonctions de gestion des Charges itérées


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription » avec
	l'esclave « fichier annexe du Perimetre famille de charges iterees  »

retour :
	OK
==============================================================================*/
int n_InitPerFci(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitPerFci" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave famille de charges iterees  */
	if ( n_OpenFileAppl( "ESTC1065_I11", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer sur le fichier de travail */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncPerFci ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLignePerFci ;

	pbd_Rupt->c_Separ = '~' ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction de test de synchronisation

retour :
	0	---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
	> 0   	---> pbd_InRecOwne> > pbd_InRecChild
	< 0   	---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncPerFci(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncPerFci" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[PERFCI_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[PERFCI_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[PERFCI_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[PERFCI_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[PERFCI_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePerFci(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{

char  MsgAno[300];

	DEBUT_FCT( "n_ActionLignePerFci" ) ;
	
	/*if ( strcmp(ptb_InRecOwner[PER_CTR_NF], "05T002675" ) == 0 ) 
	printf(" \n n_ActionLignePerFci Kn_Fam_Nbp=%d  ptb_InRecOwner[PER_CTR_NF][%s], PER_CTBTYP_CT=%d ; \n", Kn_Fam_Nbp, ptb_InRecOwner[PER_CTR_NF], atoi( (ptb_InRecOwner)[PER_CTBTYP_CT] ));
		*/

	/* constitution du tableau des familles de charges iterees pour calcul des Taux Commissions */
	Ktbd_FamCha[Kn_NbFam].CHGTYP_B = (char)( atoi( ptb_InRecChild[PERFCI_CHGTYP_B] ) ) ;
	Ktbd_FamCha[Kn_NbFam].MAX_R = atof( ptb_InRecChild[PERFCI_MAX_R] ) ;
	Ktbd_FamCha[Kn_NbFam].MINRAT_R = atof( ptb_InRecChild[PERFCI_MINRAT_R] ) ;
	Ktbd_FamCha[Kn_NbFam].MIN_R = atof( ptb_InRecChild[PERFCI_MIN_R] ) ;
	Ktbd_FamCha[Kn_NbFam].MAXRAT_R = atof( ptb_InRecChild[PERFCI_MAXRAT_R] ) ;

	/* incrementation du compteur de poste du tableau */
	
	Kn_NbFam += 1 ;

/* Ecriture dans log si depassement du tableau */
  if ( Kn_NbFam > NB_FAM_MAX) {
          sprintf(MsgAno,"The number of Driving records (/CTR %s /SEC %s /UWY %s) overflows the program's storage capacity %d",
                  ptb_InRecChild[PERFCI_CTR_NF],
                  ptb_InRecChild[PERFCI_SEC_NF],
                  ptb_InRecChild[PERFCI_UWY_NF],
                  NB_FAM_MAX);
          n_WriteAno(MsgAno);
          RETURN_VAL(ERR);
  }
  
 
	/* constitution du tableau des familles de charges iterees pour calcul des PB et PAP*/
	
	/*if ( strcmp(ptb_InRecOwner[PER_CTR_NF], "05T002675" ) == 0 )
	printf(" \n n_ActionLignePerFci Kn_Fam_Nbp=%d  ptb_InRecOwner[PER_CTR_NF][%s], PER_CTBTYP_CT=%d ; \n", Kn_Fam_Nbp, ptb_InRecOwner[PER_CTR_NF], atoi( (ptb_InRecOwner)[PER_CTBTYP_CT] ));
	*/
	if ( atoi( (ptb_InRecOwner)[PER_CTBTYP_CT] ) == 2 )
	{
		
	/**/if ( strcmp(ptb_InRecOwner[PER_CTR_NF], "20T010203" ) == 0 )
		printf(" DANS ( (ptb_InRecOwner)[PER_CTBTYP_CT] ) == 2 In_ActionLignePerFci Kn_Fam_Nbp=%d\n", Kn_Fam_Nbp);	/**/ 	
		
		Ktbd_FamCha_02[Kn_Fam_Nbl][Kn_Fam_Nbp].CHGTYP_B = (char)( atoi( ptb_InRecChild[PERFCI_CHGTYP_B] ) ) ;
		Ktbd_FamCha_02[Kn_Fam_Nbl][Kn_Fam_Nbp].MAX_R = atof( ptb_InRecChild[PERFCI_MAX_R] ) ;
		Ktbd_FamCha_02[Kn_Fam_Nbl][Kn_Fam_Nbp].MINRAT_R = atof( ptb_InRecChild[PERFCI_MINRAT_R] ) ;
		Ktbd_FamCha_02[Kn_Fam_Nbl][Kn_Fam_Nbp].MIN_R = atof( ptb_InRecChild[PERFCI_MIN_R] ) ;
		Ktbd_FamCha_02[Kn_Fam_Nbl][Kn_Fam_Nbp].MAXRAT_R = atof( ptb_InRecChild[PERFCI_MAXRAT_R] ) ;
		Ktbd_FamCha_02[Kn_Fam_Nbl][Kn_Fam_Nbp].RATTYP_B = atof( ptb_InRecChild[PERFCI_RATTYP_B] ) ;

		/* incrementation du compteur de poste du tableau */
		Kn_Fam_Nbp += 1 ;
		
	/**/if ( strcmp(ptb_InRecOwner[PER_CTR_NF], "20T010203" ) == 0 )
	printf(" APRES INCEMENTATION :n_ActionLignePerFci Kn_Fam_Nbp=%d\n", Kn_Fam_Nbp);	/**/	
		
		if ( Kn_Fam_Nbp >= NB_FAM_MAX )
		{
			sprintf(MsgAno, "Depassement de capacite du tableau Ktbd_FamCha, agrandir le nombre de postes NB_FAM_MAX dans ESTC1019.h et estserv.*");
    	n_WriteAno(MsgAno);
      RETURN_VAL(ERR);
		}
		
	}  
  


	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction d'initialisation des variables de travail

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_InitVariables( void )
{
	DEBUT_FCT( "n_InitVariables" ) ;

 	/*Kc_AdmMod = 0 ;
	Kd_EntAmt = 0 ;
	Kd_RetAmt = 0 ;
	Kd_ClmAmt = 0 ;
	Kd_PrmAmt = 0 ;*/
	memset( Ktbd_FamCha, 0, ( NB_FAM_MAX * sizeof( T_TabFamCharIt ) ) ) ;
	memset( Ktbd_FamCha_02, 0, ( NB_FAM_MAX * sizeof( T_TabFamCharIt ) ) ) ;

	Kn_NbFam = 0 ;
	//printf(" \nDANS n_InitVariables Kn_Fam_Nbp=%d\n",Kn_Fam_Nbp );  
	Kn_Fam_Nbp = 0;
	/**Ksz_ComRat_i = 0 ;
	Kn_CtrEstPa = 0 ;	*/

	RETURN_VAL ( OK ) ;
}

//[013] FIN Fonctions de gestion des Charges itérées



/*==============================================================================
objet :
    IFRS17 req 10.1 
	  fonction de calcul des remainings premiums et remainings commissions

retour :	OK ---> traitement correctement effectue
      		ERR --> probleme rencontre
==============================================================================*/
int n_remaining_amounts( char **pbd_InRec_Cur )
{
	double Kd_Prmrest, Kd_Commrest;
	

		if ( (c_PRME_FLG == 'Y' || c_UPR_FLG == 'Y')
	        &&
	        ( fabs(Kd_UPR) > 0.0 ||  fabs(Kd_PRME) > 0.0 )		
			 )
		{
			
			// select the min amount between "Premium Estimates" and UPR
			// and post positive amount on 1A100112
			
			if ( Kd_PRME  > ( -1 * Kd_UPR ) ) 
				Kd_Prmrest = -1 * Kd_UPR ;
			else
				Kd_Prmrest = Kd_PRME    ; 

			
#ifdef TRACE_REMAINING_PRM_COMM			
			printf("\nNEW req 10.1 PRM key %s %s sec %s %s %s: Kd_PRME:%f newUPR:%f:  use:%f  \n", 
        			pbd_InRec_Cur[PER_CTR_NF],pbd_InRec_Cur[PER_END_NT],pbd_InRec_Cur[PER_SEC_NF] ,pbd_InRec_Cur[PER_UWY_NF] ,pbd_InRec_Cur[PER_UW_NT] ,
			        Kd_PRME , Kd_UPR ,   Kd_Prmrest  );
#endif					
  				
  
     n_EcrireGTremaining( pbd_InRec_Cur , pbd_InRec_Cur[PER_CTR_NF]  , Kd_Prmrest  ,  "1A100112", "1A100122" );
					
		}

  

		if ( (c_COME_FLG == 'Y' || c_DAC_FLG == 'Y')
	        &&
	        ( fabs(Kd_DAC) > 0.0 ||  fabs(Kd_COME) > 0.0 )		
			 )
		{
			
			
			
			// select the min amount between "Commission Estimates" and DAC, 
			// and post negative amount on 1A120112
			
			if ( -1 * Kd_COME  > Kd_DAC  )
				Kd_Commrest = -1 * Kd_DAC  ;
			else
				Kd_Commrest = -1 * (-1 * Kd_COME  )  ; 

#ifdef TRACE_REMAINING_PRM_COMM	
			printf("\nNEW req 10.1 COMM key %s %s sec %s %s %s: Kd_COME %f DAC:%f: use:%f: \n", 
        			pbd_InRec_Cur[PER_CTR_NF],pbd_InRec_Cur[PER_END_NT],pbd_InRec_Cur[PER_SEC_NF] ,pbd_InRec_Cur[PER_UWY_NF] ,pbd_InRec_Cur[PER_UW_NT] ,
			        Kd_COME, Kd_DAC ,Kd_Commrest );
#endif

		n_EcrireGTremaining( pbd_InRec_Cur , pbd_InRec_Cur[PER_CTR_NF]   , Kd_Commrest ,   "1A120112", "1A120122" );
	
					
		}

                //REQ 10.13 [050]
                if ( (c_COMEVAR_FLG == 'Y' || c_DACVAR_FLG == 'Y')
                &&
                ( fabs(Kd_DACVAR) > 0.0 ||  fabs(Kd_COMEVAR) > 0.0 )
                         )
                {
                        if ( -1 * Kd_COMEVAR  > Kd_DACVAR  )
                                Kd_Commrest = -1 * Kd_DACVAR  ;
                        else
                                Kd_Commrest = -1 * (-1 * Kd_COMEVAR  )  ;

                  //      printf("\nKd_Commrest %f Kd_COMEVAR %f Kd_DACVAR %f\n",Kd_Commrest,Kd_COMEVAR,Kd_DACVAR);
                        n_EcrireGTremaining( pbd_InRec_Cur , pbd_InRec_Cur[PER_CTR_NF]   , Kd_Commrest ,   "1A120312", "1A120322" );
                }
                if ( (c_COMEBRK_FLG == 'Y' || c_DACBRK_FLG == 'Y')
                &&
                ( fabs(Kd_DACBRK) > 0.0 ||  fabs(Kd_COMEBRK) > 0.0 )
                         )
                {
                        if ( -1 * Kd_COMEBRK  > Kd_DACBRK  )
                                Kd_Commrest = -1 * Kd_DACBRK  ;
                        else
                                Kd_Commrest = -1 * (-1 * Kd_COMEBRK  )  ;

                 //       printf("\nKd_Commrest %f Kd_COMEBRK %f Kd_DACBRK %f\n",Kd_Commrest,Kd_COMEBRK,Kd_DACBRK);
                        n_EcrireGTremaining( pbd_InRec_Cur , pbd_InRec_Cur[PER_CTR_NF]   , Kd_Commrest ,   "1A120412", "1A120422" );
                }

RETURN_VAL ( OK ) ;
} 

 

int n_EcrireGTremaining( char **pbd_InRec_Cur , char *CTR_NF, double d_Montant, char *account , char *cancel_account )
{
  char  *Gt[NB_COL_GT2 + 1] ; /* tableau de pointeurs a l'image du GT */	
  char  sz_Vide[2] = "" ;
  char  sz_Amt[30] ;    	/* zone de travail */
  
  char  sz_Acy[6] ;   		/* zone de travail */
  char  sz_Mth[4] ;   /* zone de travail */
  char  sz_Day[4] ;   /* zone de travail */
  char  sz_oricod [30];
  char  sz_zero[2];
  

#ifdef TRACE_2	
    printf("\nn_EcrireGTremaining : %s~%s~%10.3f~.....       GT2 : %s-%10.3f  ~~~~~~~~~~~~~~~~~~~~~GTA~~~~~~~~~~~~~~",
			 CTR_NF, account, d_Montant, cancel_account, d_Montant * -1 );
#endif	


   /* Eclatement de la date AAAAMMJJ en 3 chaines de caractere */
  sscanf( Ksz_CloDat, "%4s%2s%2s", sz_Acy, sz_Mth, sz_Day ) ; 
    
  
  sprintf(sz_Amt,"%f", d_Montant);
  strcpy(sz_oricod,"REMAINING");
  strcpy(sz_zero , "0");
 
 
  /******************************************************************/
  /* positionnement du tableau de pointeur avant ecriture en sortie */
  /******************************************************************/
  Gt[GT_SSD_CF] = pbd_InRec_Cur[PER_SSD_CF]  ; 
  Gt[GT_ESB_CF] = pbd_InRec_Cur[PER_ACCESB_CF] ;
  Gt[GT_BALSHEY_NF] = sz_Acy ;  //pbd_InRec_Cur[GT_BALSHEY_NF];      
  Gt[GT_BALSHRMTH_NF] = sz_Mth ; //pbd_InRec_Cur[GT_BALSHRMTH_NF] ; 
  Gt[GT_BALSHRDAY_NF] = sz_Day ; //pbd_InRec_Cur[GT_BALSHRDAY_NF] ; 
  //Gt[GT_DBLTRNCOD_CF] = sz_Vide ;
  Gt[GT_CTR_NF] = CTR_NF ;                      
  Gt[GT_END_NT] = pbd_InRec_Cur[PER_END_NT]  ;   
  Gt[GT_SEC_NF] = pbd_InRec_Cur[PER_SEC_NF];     
  Gt[GT_UWY_NF] = pbd_InRec_Cur[PER_UWY_NF] ;    
  Gt[GT_UW_NT]  = pbd_InRec_Cur[PER_UW_NT] ;      
  Gt[GT_OCCYEA_NF] = pbd_InRec_Cur[PER_CTRACCYEA_NF] ;
  Gt[GT_ACY_NF] = sz_Acy ;          //pbd_InRec_Cur[GT_ACY_NF] ;
  Gt[GT_SCOSTRMTH_NF] = sz_Mth ; // pbd_InRec_Cur[GT_SCOSTRMTH_NF] ;
  Gt[GT_SCOENDMTH_NF] = sz_Day ; // pbd_InRec_Cur[GT_SCOENDMTH_NF] ; 
  Gt[GT_CLM_NF] = sz_Vide ;
  Gt[GT_CUR_CF] =  pbd_InRec_Cur[PER_EGPCUR_CF] ; 
  Gt[GT_AMT_M] = sz_Amt ;
  Gt[GT_CED_NF] = pbd_InRec_Cur[PER_CED_NF] ; 
  Gt[GT_BRK_NF] = pbd_InRec_Cur[PER_PRD_NF] ; 
  Gt[GT_PAY_NF] = pbd_InRec_Cur[PER_PAYTIME_NF] ; 
  Gt[GT_KEY_NF] = pbd_InRec_Cur[PER_GANPAYORD_NT] ; 
  Gt[GT_RETCTR_NF] =  sz_Vide ; //pbd_InRec_Cur[GT_RETCTR_NF] ;
  Gt[GT_RETEND_NT] =  sz_Vide ; //pbd_InRec_Cur[GT_RETEND_NT] ; 
  Gt[GT_RETSEC_NF] =  sz_Vide ; //pbd_InRec_Cur[GT_RETSEC_NF] ; //sz_Vide ;
  Gt[GT_RTY_NF] = sz_Vide ;
  Gt[GT_RETUW_NT] = sz_Vide ;
  Gt[GT_RETOCCYEA_NF] = sz_Vide ;
  Gt[GT_RETACY_NF] = sz_Vide ;
  Gt[GT_RETSCOSTRMTH_NF] = sz_Vide ;
  Gt[GT_RETSCOENDMTH_NF] = sz_Vide ;
  Gt[GT_RCL_NF] = sz_Vide ;
  Gt[GT_RETCUR_CF] = sz_Vide ;
  Gt[GT_RETAMT_M] = sz_zero ;
  Gt[GT_PLC_NT] = sz_Vide ;
  Gt[GT_RTO_NF] = sz_Vide ;
  Gt[GT_INT_NF] = sz_Vide ;
  Gt[GT_RETPAY_NF] = sz_Vide ;
  Gt[GT_RETKEY_CF] = sz_Vide ;
  Gt[GT_RETINTAMT_M] = sz_zero ;   
//  Gt[GT_RETINTAMT_M + 1] = NULL ;

Gt[GT_ESTCUR_CF 	  ] = sz_Vide;	
Gt[GT_ESTAMT_M 		  ] = sz_Vide;				
Gt[GT_NAT_CF 		    ] = sz_Vide;
Gt[GT_ACMTRS_NT     ] = sz_Vide;         
Gt[GT_ESTCTR_NF     ] = sz_Vide;         
Gt[GT_ESTSEC_NF     ] = sz_Vide;         
Gt[GT_LOB_CF        ] = sz_Vide;   
Gt[GT_SCOEGP_M      ] = sz_Vide;  
Gt[GT_ESTCRB_CT     ] = sz_Vide;  
Gt[GT_LIFTRTTYP_CF  ] = sz_Vide;              
Gt[GT_ACCADMTYP_CT  ] = sz_Vide;              
Gt[GT_SECSTS_CT     ] = sz_Vide;  
Gt[GT_PRD_NF        ] = sz_Vide;
Gt[GT_SEG_NF        ] = sz_Vide;
Gt[GT_COMACC_B      ] = sz_Vide;
//Gt[GT_ADJCOD_CT     ] = sz_Vide;
Gt[GT_ORICOD_LS     ] = sz_oricod;
Gt[GT_ORICOD_CF     ] = sz_Vide;
Gt[GT_DETTRS_CF     ] = sz_Vide;
Gt[GT_ACCRET_B      ] = sz_Vide;
Gt[GT_ESTUWY_NF     ] = sz_Vide;
Gt[GT_LSTENDMTH_NF  ] = sz_Vide;
Gt[GT_PROPER_N      ] = sz_Vide;
Gt[GT_RTOCTY_CF     ] = sz_Vide;
Gt[GT_GAAP_NF       ] = sz_Vide;
Gt[GT_BRKSCOEGP_M   ] = sz_Vide;     
Gt[GT_UWGRP_CF      ] = sz_Vide;     
Gt[GT_PROPAGRES_B   ] = sz_Vide;
Gt[GT_PostBpc_B     ] = sz_Vide;
Gt[GT_SPIMOD_CT     ] = sz_Vide;
Gt[GT_RETAUTGEN_B   ] = sz_Vide;
Gt[GT_ACCTYP_NF] = NULL ;



   
   Gt[GT_TRNCOD_CF] = account ;
   Gt[GT_DBLTRNCOD_CF] = account;
   	  
   sprintf( sz_Amt, "%-.3f", d_Montant ) ;			
   n_WriteCols( Kp_OutputFilGtRest , Gt, SEPARATEUR, 0 ) ;
   //[048]n_WriteCols( Kp_OutputFilResSii, Gt, SEPARATEUR, 0 ) ;


   
   Gt[GT_TRNCOD_CF] = cancel_account ;
   Gt[GT_DBLTRNCOD_CF] = cancel_account;
   strcpy(sz_oricod,"REMAINING CANCEL");
  
   sprintf( sz_Amt, "%-.3f", d_Montant * -1 ) ;
   n_WriteCols( Kp_OutputFilGtRest , Gt, SEPARATEUR, 0 ) ;
   //[048]n_WriteCols( Kp_OutputFilResSii, Gt, SEPARATEUR, 0 ) ;

   
   
  RETURN_VAL(0);
	
}
 
 
