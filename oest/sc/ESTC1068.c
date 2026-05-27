/*==============================================================================
nom de l'application          : ESTIMATION SOLVENCY
nom du source                 : ESTC1068.c
révision                      : 
date de création              : 07/01/2020
auteur                        : Roger Cassis
references des specifications : Spira 82279
squelette de base             : batch
------------------------------------------------------------------------------
description :
   :spira 82279 - Split Ancien ESTC1065 --> ESTC1067 : Calcul des Futures  Primes et Sinistres
                                        --> ESTC1068 : Calcul des Futures charges 
                 Avec Transformation des postes

1A120012 -> genere Future Fixed Charge
//1A120022 -> genere Future Variable Charge
1A120052 -> Genere Future Sliding Scale
1A120072 -> Genere Future PAP/PB
1A120032 -> genere Future Brokerage

AT INCEPTION : 




------------------------------------------------------------------------------
historique des modifications :

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
[049] 26/12/2019 MZM : spira 82279 : Floarat AT  Inception 
[050] 07/02/2020 MZM : spira 83722 : Future Profit Commission formula
[051] 31/01/2020 HR  : spira 81813 : replacement of brokerage rate 1A120032 by 1A120062 
[052] 26/12/2019 MZM : spira 82279 : Floarat AT  Inception split final ; impact sur nouveau ESTC1068
[053] 07/02/2020 MZM : spira 83722 : Future Profit Commission formula + traces
[054] 31/03/2020 MZM : spira 82047 : Initial future brokerage incorrect on some contracts
[055] 31/03/2020 MZM : spira 82761 : Initial future Slidding Scale
[056] 01/06/2020 MZM : Spira 87545 : UAT EBS KO - Future premium and commission assumed : Tri sur la section convertie en nombre
[057] 16/06/2020 HR  : Spira 86248 : Future Minimum Sliding Scale 
[058] 12/08/2020 JYP :Spira:89218  : size tab FBOPRSLNK
[059] 02/08/2020 HR : Spira 89270 : IFRS 4 / EBS alignement on commission type
[060] 14/09/2020 MZM : spira 82761 : Sliding Scale Rale calcule si COMTYP = 2
[061] 24/03/2021 MZM : spira:95046 : ANO PROD : MODIF des TRNCOD TEMPORAIRE "9L430003", "9L430002" "9L430102" "9L430602" en sortie du calcul des DAC
[062] 24/03/2021 MZM : spira:94866 : IFRS 17 - REQ 11.07 - Undexpected applied tax rate : TAx RAte : Synchro sur l'avenant numerique 
[063] 05/07/2022 JBD  :spira 104778:  Build new closing for I17S norm
[064] 08/09/2022 MZM : spira:106313 : Prod Q1 22 - Fac - No calculation future fixed commission : Evolution permettre le calcul pour FAC AT EBS 
[065] 19/03/2025 MZM :spira:111945 - BBNI Management
[066] 07/10/2025 MZM :US 5637 - EBS INI Management
[066] 22/01/2026 MZM :US 7847 - EBS INI Management
========================================================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "ESTC1068.h" 
#include "struct.h"
#include "estserv.h"
#include "estutil.c"

/*----------------------------------------*/
/* inclusion de version dans les binaires */
/*----------------------------------------*/
static char VERSION_ESTC1068_C[150] = "__version__: ESTC1068.c version [064] 08/09/2022 : Future Commission TYPE 1 FAC AT EBS "; 


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
#define PRME  4  // [11]
#define ITDP  5  // [13] ITD written premium 
#define OTHER 6  // [11]
#define NB_COL_GT2 71 //[11]

/* 
#define TRACE_1  1  // [11]
#define TRACE_2  2  // [11] more detailled traces
*/


//#define TRACE_UPR_DAC  1
//#define TRACE_FUTURE_VARIABLE_PREMIUM
//#define TRACE_FUTURE_FIXE_CHARGE
//#define TRACE_FUTURE_VARIABLE_CHARGE
//#define TRACE_FUTURE_PROFIT_COMMISSION
//#define TRACE_FUTURE_INC_PROFIT_COMMISSION
//#define TRACE_FUTURE_BROKERAGE

//#define TRACE_FUTURE_SLIDING_SCALE

//
//#define TRACE_5

//#define TRACE_FUTURE_FIXE_INC_PRM
//#define TRACE_FUTURE_INC_BROKERAGE
//#define TRACE_FUTURE_VAR_INC_PRM
//#define TRACE_FUTURE_INC_VARIABLE_CHARGE


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
                double DACFIX1;
                double DACVAR1; 
                double DACBRK;
								char*  TRNCOD;
                } T_FUTURES;

        T_FUTURES*      pFutures;	
	
		
	T_LIGNEREC   Ktbd_Rec[1000] ; /*Pointeur sur element du tableau de reconstit*/
	int 	Kn_RecRnk ;

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE   *Kp_OutputFilResSii;    /* pointeur sur le fichier de sortie formaté avec les nouvelles colonnes */
FILE   *Kp_OutputFilResSiiAno; /* pointeur sur le fichier de sortie des lignes sans segment */
FILE   *Kp_InputFilExc;        /* pointeur sur le fichier en entree des cours de change */
FILE   *Kp_InputFilSegest ;    /* pointeur sur le fichier binaire FSEGEST */
FILE   *p_OutputFutures; 	     /* Fichier de log pour les users [05] -=Dch=-  */

T_RUPTURE_VAR       bd_RuptPerUw;   /* variable de gestion de la rupture sur le perimetre de Accept ou Retro */
T_RUPTURE_SYNC_VAR  bd_RuptDlGtaa; /* variable de gestion de la synchronisation avec le fichier DTSTATGTx */


//[013]

T_RUPTURE_SYNC_VAR 	bd_RuptPerFci ; /* variable de gestion de la synchronisation avec le fichier annexe du perimetre famille de charges iterees */
T_RUPTURE_SYNC_VAR 	bd_RuptPerFr ;  /* variable de gestion de la synchronisation avec le pericase et fichier annexe du perimetre Annexe */


// [049] T_RUPTURE_SYNC_VAR  bd_RuptPrmLoa; 	/* Synchro avec le fichier des primes */
T_RUPTURE_SYNC_VAR  bd_RuptPerFct;  /* Synchro avec le fichier des Taxes */ //[049]

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

int Kn_Pa ;		/* variable de participations des fichiers esclaves */

int Kc_Pe ;		/* flag positionne a 1 si il existe au moins une prime  dans
				le Fichier de travail pour une affaire donnee */


T_RUPTURE_VAR  	   	bd_RuptFt ;     /* variable de gestion de la rupture sur le GT */
T_RUPTURE_SYNC_VAR 	bd_RuptLoaRat ; /* variable de gestion de la synchronisation avec le fichier des taux de charges */
T_RUPTURE_SYNC_VAR 	bd_RuptGtLoa ;  /* variable de gestion de la synchronisation avec le GT des charges */
T_RUPTURE_SYNC_VAR 	bd_RuptGtFac ;  /* variable de gestion de la synchronisation avec le GT des primes estimees FAC et RPCC */
T_RUPTURE_SYNC_VAR 	bd_RuptPer ;    /* variable de gestion de la synchronisation avec le perimetre */
T_RUPTURE_SYNC_VAR 	bd_RuptGtRec ;  /* variable de gestion de la synchronisation avec le GT des REC */   


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
double  Kd_BrkRat =0;   	 /* taux de courtage                         */ //[026]


double Kd_TaxGloWP = 0; 
double Kd_TaxGloWO = 0; 

double 	Kd_ManExpRate = 0 ;   /* Taux de Management Expense Rate */  

double Kd_PAP;					/* Loss Commission ou participation aux Pertes */
double Kd_PB ;          /* Profit ou Participation Benefices */

char  Kz_PbOriCod[30];  // Indicateur de calcul de la PB pour traces  "CloP" calculable sinon non calculable
char 	Kz_PapOriCod[30]; // Indicateur de calcul de la PAP pour traces

double Kd_ProfitCommission ; //[053]

double Kd_SC ;          /* Sliding Scale */

int	Kn_NbFam  ; 				/* nombre de postes du tableau Ktbd_FamCha */
//[013]
char 	Ksz_ComRat_i[20] ; 	/* zone de travail intermediaire */

int n_InitPerUw            ( T_RUPTURE_VAR  *pbd_Rupt );
int n_TestRupturePER       (char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionFistRupturePER (char **pbd_InRec_Cur);  
int n_ActionLignePER			 ( char **pbd_InRec_Cur );
int n_ActionLastRupturePER (char **pbd_InRec_Cur);


int n_InitDlGtaa		      ( T_RUPTURE_SYNC_VAR *pbd_Rupt );
int n_ActionLigneDlGtaa    ( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ConditionSyncDlGtaa  ( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ActionLastDlGtaa    ( char **pbd_InRecOwner, char **pbd_InRecChild ); // [053]



int n_ConditionRuptureDlGtaa (char **, char **) ; //[053] 

//[41] 
int n_ActionPereSansFilsDlGtaa(char **ptsz_LigneMaitre);


// [11]
T_RUPTURE_SYNC_VAR  bd_RuptUprDac; /* variable de gestion de la synchronisation avec le fichier UPR_DAC_PRM_COMM */
int n_InitUprDac		   ( T_RUPTURE_SYNC_VAR *pbd_Rupt );
int n_ActionLigneUprDac    ( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ConditionSyncUprDac  ( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ActionPereSansFilsUprDac(char **ptsz_LigneMaitre);


int n_ProcessingRuptureSyncVar (T_RUPTURE_SYNC_VAR  *pbd_Rupt, char **pbd_InRecOwner );

void n_EcrireLog();  // sortie de la log FUTURES

int n_InitVariables( void ) ;


FILE *Kp_FBOTRSLNK;                              

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
double  Kd_DACFIX;
double  Kd_DACVAR;
double  Kd_DACBRK;
double  Kd_LOSSCORR ;
double  Kd_UPR_DAC_F_B_V;
double  KdSC ; 
double  Kd_PRME;
double  Kd_COME;
char   c_UPR_FLG;       // [11]
char   c_DAC_FLG;       // [11]
char   c_PRME_FLG;        
char   c_COME_FLG;        

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
double Kd_Rc;					  // Result Account

double Kd_ManExp ;      // Management Expense
double Kd_ProfitCommission ; // [053] Profit Commission

double Kd_RESULT_ACC = 0 ;  //Formule du Result Account sans les FUTURE Charges, Brokerage et LossCorridor Calcules dans ESTC1068

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

	printf("Running with %s  \n", VERSION_ESTC1068_C);
	


  if (Ksz_Argc == 3)
  { 
 
  	  strcpy(Ksz_NORME, psz_GetCharArgv(3));
  	  //printf("NB_ARGUMENT 03 RECUP Ksz_Argc %d Ksz_NORME = %s\n", Ksz_Argc, Ksz_NORME);   	  
  }
  else
  { 
  	  strcpy(Ksz_NORME, "EBS");
  	  //printf("NB_ARGUMENT Classique RECUP Ksz_Argc %d Kn_NORME %s\n", Ksz_Argc, Ksz_NORME);   	  
  }

	
	kn_MIN_ICLODAT_A = atoi(psz_GetCharArgv(1));
    strcpy( Ksz_CloDat, psz_GetCharArgv(2) ) ;
     	 	
	
	
	/* Determination du Suffice pour les TRNCOD Des Future At INCEPTION */ // strncmp(Ksz_NORME, "I17G", 4) == 0) 	
	
	if ( strncmp(Ksz_NORME, "I17G", 4) == 0 || strncmp(Ksz_NORME, "I17S", 4) == 0)    //[063]
		strcpy(Kc_Norme_Suf, "I"); //Kc_Norme_Suf = 'I';  
	if ( strncmp(Ksz_NORME, "I17P", 4) == 0)  
		strcpy(Kc_Norme_Suf, "K"); //Kc_Norme_Suf = 'K';		
	if ( strncmp(Ksz_NORME, "I17L", 4) == 0) 
		strcpy(Kc_Norme_Suf, "M"); //Kc_Norme_Suf = 'M' ;  		    


	/* ouverture du fichier en entree des cours de change FCURQUOT */
	if ( n_OpenFileAppl ( "ESTC1068_I3","rb",&Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" );     
	
	/* ouverture du fichier de sortie des resultats par affaire */
	if ( n_OpenFileAppl ( "ESTC1068_O1","wt",&Kp_OutputFilResSii ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* ouverture du fichier de sortie des resultats par affaire */
	if ( n_OpenFileAppl ( "ESTC1068_O2","wt",&Kp_OutputFilResSiiAno ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* ouverture du fichier de sortie des logs */
	if ( n_OpenFileAppl ( "ESTC1068_O3","wt",&p_OutputFutures ) == ERR )
		ExitPgm( ERR_XX , "" );	
		
		
	pFutures = (T_FUTURES *) calloc(1,sizeof(T_FUTURES)); 

	/* Initialisation de la variable bd_RuptPerUw */
	if ( n_InitPerUw( &bd_RuptPerUw ) )
		ExitPgm( ERR_XX , "" );	

	/* Initialisation de la variable FLOARAT */
	if ( n_InitLoaRat( &bd_RuptLoaRat ) )
		ExitPgm( ERR_XX , "" );			  	

	/* Initialisation de la variable bd_RuptDlGtaa */
	if ( n_InitDlGtaa( &bd_RuptDlGtaa ) )
		ExitPgm( ERR_XX , "" );

	/* Initialisation de la variable bd_RuptPerFci */
	if ( n_InitPerFci( &bd_RuptPerFci ) )
		ExitPgm( ERR_XX , "" ) ;

	/* lancement du traitement du fichier Perimetre de souscription IADPERICASE.dat */
	if ( n_ProcessingRuptureVar( &bd_RuptPerUw ) == ERR )		
		ExitPgm( ERR_XX , "" );
	

	if ( n_CloseFileAppl( "ESTC1068_I1", &( bd_RuptPerUw.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1068_I2", &( bd_RuptDlGtaa.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1068_I3", &Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1068_I4", &( bd_RuptLoaRat.pf_InputFil) ) == ERR )
		ExitPgm( ERR_XX , "" );	
				
	if ( n_CloseFileAppl( "ESTC1068_I5", &( bd_RuptPerFci.pf_InputFil) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;
		
	//[013]

	//if ( n_CloseFileAppl( "ESTC1068_I6", &( bd_RuptPrmLoa.pf_InputFil) ) == ERR )
	//	ExitPgm( ERR_XX , "" );	
				
							
	if ( n_CloseFileAppl( "ESTC1068_O1", &Kp_OutputFilResSii ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1068_O2", &Kp_OutputFilResSiiAno ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESTC1068_O3", &p_OutputFutures ) == ERR )
		ExitPgm( ERR_XX , "" );

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
	if ( n_OpenFileAppl( "ESTC1068_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
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
    Kd_DACFIX = 0.0 ;
    Kd_DACVAR = 0.0 ;
    Kd_LOSSCORR = 0.0 ;
    
    Kd_UPR_DAC_F_B_V = 0.0;
    
    c_COME_FLG = 'N';
    c_PRME_FLG = 'N';
    Kd_PRME = 0.0 ;
    Kd_COME = 0.0 ;
	  Kd_Prmrest = 0.0 ;    /* montant des estimations de primes restantes "non acquises "      [11] */ 
    Kd_Commrest = 0.0;    /* montant des estimations de commission restantes "non acquises"   [11] */
    
    kn_est_ITDP = 0 ;    // Variable de calcul de l'ITD Premium 


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
	/* synchronisation avec le fichier annexe Perimetre de souscription *
	n_ProcessingRuptureSyncVar( &bd_RuptPerFr, pbd_InRec_Cur ) ;
  */
  /*[021]
	n_ProcessingRuptureSyncVar( &bd_RuptUprDac, pbd_InRec_Cur );
  */
  
	////[013
	///* synchronisation avec le fichier des Primes  */
	//n_ProcessingRuptureSyncVar( &bd_RuptPrmLoa, pbd_InRec_Cur ) ;  

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
int n_InitDlGtaa(T_RUPTURE_SYNC_VAR   *pbd_Rupt ) 
{
	DEBUT_FCT( "n_InitDlGtaa" );

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) );  

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC1068_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 1;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncDlGtaa;
	
	pbd_Rupt->n_ConditionRupture[0] = n_ConditionRuptureDlGtaa;
	

	/* fonction d'action sur la ligne courante */

	pbd_Rupt->n_ActionLigne = n_ActionLigneDlGtaa;
	
	/* fonction d'action last Rupture*/
	pbd_Rupt->n_ActionLast[0] = n_ActionLastDlGtaa; //[053]
	
	/* fonction d'action pere sans fils --> CALCUL AT INCEPTION Uniquement si NORME est soit I17G, I17P, ou I17L*/ 
		
		
// Inutile avec le Split

	//if (strcmp(Ksz_NORME, "I17G") ==0 || strcmp(Ksz_NORME, "I17P") == 0 || strcmp(Ksz_NORME, "I17L") == 0 ) 
	//{ 		
	//		pbd_Rupt->n_PereSansFils = n_ActionPereSansFilsDlGtaa;
	//}

	pbd_Rupt->c_Separ = '~';

	RETURN_VAL( OK );
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
	if ( ( ret = atoi( pbd_InRecOwner[PER_END_NT] ) - atoi( pbd_InRecChild[GT_END_NT] ) ) != 0 ) return ret ; //( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GT_END_NT] ) ) != 0 ) return ret;
	if ( ( ret = atoi( pbd_InRecOwner[PER_SEC_NF] ) - atoi( pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) return ret ; //[056] if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) return ret;
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


	DEBUT_FCT( "n_ActionLigneDlGtaa" );

    /* Données des FUTURE PREMIUMS ET FUTURES SINISTRES */
    
		/* INPUT

				1A100012 -> genere Future Fixed Premium
				1A100022 -> genere Future Variable Premium
				1A494302 -> Genere Future CLAIMS
				
				9L100092 -> Genere Future UPR
				
				9L430003 -> DAC Brokerage				
				9L430002 -> DAC Fix 
				9L430102 -> DAC Variable
				

*/    
    
			
			if ( strcmp(pbd_InRecChild[GT_TRNCOD_CF], "1A100022") == 0 ) // Future Variable Premium
			{
				Kd_PrmVarAmt = atof(pbd_InRecChild[GT_AMT_M]) ;      
			}	
			
			if ( strcmp(pbd_InRecChild[GT_TRNCOD_CF], "1A494302") == 0 ) // Future Claim
			{
				Kd_Claim_Amt = atof(pbd_InRecChild[GT_AMT_M]) ;
			}		
			
			if ( strcmp(pbd_InRecChild[GT_TRNCOD_CF], "9L100092") == 0 ) // Future UPR --> TRNCOD A REDEFINR
			{
				Kd_UPR = atof(pbd_InRecChild[GT_AMT_M]) ;
			}	
			
			if ( strcmp(pbd_InRecChild[GT_TRNCOD_CF], "9L430003") == 0 ) // Future DAC BROKERAGE
			{
				Kd_DACBRK = atof(pbd_InRecChild[GT_AMT_M]) ;
			}				
			
			if ( strcmp(pbd_InRecChild[GT_TRNCOD_CF], "9L430002") == 0 ) // Future DAC Fix
			{
				Kd_DACFIX = atof(pbd_InRecChild[GT_AMT_M]) ;
			}		
			
			if ( strcmp(pbd_InRecChild[GT_TRNCOD_CF], "9L430102") == 0 ) // Future DAC Variable
			{
				Kd_DACVAR = atof(pbd_InRecChild[GT_AMT_M]) ;
			}								
			
			/* Le TRNCOD 1A200712 Correspond à la FUTURE LOSS Corridor */
			
      if (strcmp(pbd_InRecChild[GT_TRNCOD_CF], "1A200712") == 0 )
      {
				Kd_LOSSCORR = atof(pbd_InRecChild[GT_AMT_M]) ;
      }			
      
			/* Le TRNCOD 1A100002 Correspond à la FUTURE Result_Account_Intermediare */
			
      if (strcmp(pbd_InRecChild[GT_TRNCOD_CF], "1A100002") == 0 )
      {
				Kd_RESULT_ACC = atof(pbd_InRecChild[GT_AMT_M]);

      }	
           	
			
			if ( strcmp(pbd_InRecChild[GT_TRNCOD_CF], "1A100012") == 0 )  	
			{				
				Kd_PrmAmt = atof(pbd_InRecChild[GT_AMT_M]) ;
			}
					
		
    	//if (( strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0014443") == 0 ||strcmp(pbd_InRecOwner[PER_CTR_NF], "17T009948") == 0 ) && (atoi(pbd_InRecOwner[PER_SEC_NF]) == 1) && (atoi(pbd_InRecOwner[PER_UWY_NF]) == 2019) )                                                                                                                         
    	//{ 
			//	printf(" Result Account 00006 Rc_new ; [PER_CTR_NF], Result_Account, Kd_PrmAmt, Kd_SC, Kd_UPR, Kd_FuturCharge, Kd_DAC, Kd_Claim_Amt ; %s ; %f ; %f ; %f ; %f; %f ; %f ; %f  \n", 
		  //                          pbd_InRecOwner[PER_CTR_NF], (Kd_PrmAmt  + Kd_PrmVarAmt + Kd_SC -Kd_UPR - (Kd_DACFIX + Kd_DACVAR + Kd_DACBRK) + Kd_FuturCharge + Kd_FuturBrk + Kd_Claim_Amt + Kd_LOSSCORR), Kd_PrmAmt, Kd_SC, Kd_UPR, Kd_FuturCharge, Kd_DAC, Kd_Claim_Amt);			
			//}		
	 	
	
	RETURN_VAL(OK);	
	
}
				

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
	if ( n_OpenFileAppl( "ESTC1068_I4", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
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
	//[062]if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[LOA_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_END_NT] ) - atoi( pbd_InRecChild[LOA_END_NT] ) ) != 0 ) return ret ; 
	//if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[LOA_SEC_NF] ) ) != 0 ) return ret ;
		if ( ( ret = atoi( pbd_InRecOwner[PER_SEC_NF] ) - atoi( pbd_InRecChild[LOA_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[LOA_UWY_NF] ) ) != 0 ) return ret ;
	//if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[LOA_UW_NT] ) ) != 0 ) return ret ;
		if ( ( ret = atoi( pbd_InRecOwner[PER_UW_NT] ) - atoi( pbd_InRecChild[LOA_UW_NT] ) ) != 0 ) return ret ;

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
	
	//if (strcmp(ptb_InRecChild[LOA_CTR_NF], "02U037904") == 0)
	//printf(" n_ActionLigneLoaRat ; Kd_ComRat=%f ; Kd_SurComRat=%f ; Kd_Tax=%f ;  Kd_BrkRat=%f\n", Kd_ComRat, Kd_SurComRat, Kd_Tax, Kd_BrkRat) ; 

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


/*==============================================================================
objet :
  Initialisation de la synchronisation du maitre avec
  l'esclave « Montants de primes et charges »

retour :
  OK
==============================================================================*/
//int n_InitPrmLoa(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
//{
//  DEBUT_FCT( "n_InitPrmLoa" ) ;
//
//  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;
//
//  /* ouverture du fichier esclave */
//  if ( n_OpenFileAppl( "ESTC1068_I6", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
//    return ERR ;
//
//  /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
//  pbd_Rupt->ConditionEndSync = n_ConditionSyncPrmLoa ;
//
//  /* fonction d'action sur la ligne courante */
//  pbd_Rupt->n_ActionLigne = n_ActionLignePrmLoa ;
//
//  pbd_Rupt->c_Separ = '~' ;
//
//  RETURN_VAL( OK ) ;
//}
//

/*==============================================================================
objet :
  fonction de test de synchronisation

retour :
  0 ---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
  > 0     ---> pbd_InRecOwne> > pbd_InRecChild
  < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
//int n_ConditionSyncPrmLoa(
//  char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
//  char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
//{
//  int ret ;
//
//  DEBUT_FCT( "n_ConditionSyncPrmLoa" ) ;
//
//  if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[PRMLOA_CTR_NF] ) ) != 0 ) return ret ;
//  if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[PRMLOA_END_NT] ) ) != 0 ) return ret ;
//  if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[PRMLOA_SEC_NF] ) ) != 0 ) return ret ;
//  if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[PRMLOA_UWY_NF] ) ) != 0 ) return ret ;
//  if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[PRMLOA_UW_NT] ) ) != 0 ) return ret ;
//
//  RETURN_VAL( 0 ) ;
//}
//
//
///*==============================================================================
//objet :
//  fonction lancee pour chaque ligne
//
//retour :  OK ---> traitement correctement effectue
//    ERR --> probleme rencontre
//==============================================================================*/
//int n_ActionLignePrmLoa(
//  char **ptb_InRecOwner , /* adresse de la ligne du maitre */
//  char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
//{
//  DEBUT_FCT( "n_ActionLignePrmLoa" ) ;
//
//  /* affectation des complements par affaire */
//  switch ( atol( ptb_InRecChild[PRMLOA_ACMTRS_NT] ) )
//  {
//  case 10100 :
//    Ktd_Comp[Charge_PRM] = atof( ptb_InRecChild[PRMLOA_ESTACC_M] ) ;
//    Ktd_Comp[ChargeTaxe_PPNA] = atof( ptb_InRecChild[PRMLOA_RESERV_M] ) ;
//    break ;
//  case 10120 :
//    Ktd_Comp[Charge_EPP] = atof( ptb_InRecChild[PRMLOA_ESTACC_M] ) ;
//    Ktd_Comp[Charge_RPP] = atof( ptb_InRecChild[PRMLOA_RESERV_M] ) ;
//    break ;
//  case 10300 :
//    Ktd_Comp[Taxe_PRM] = atof( ptb_InRecChild[PRMLOA_ESTACC_M] ) ;
//    break ;
//  case 10320 :
//    Ktd_Comp[Taxe_EPP] = atof( ptb_InRecChild[PRMLOA_ESTACC_M] ) ;
//    Ktd_Comp[Taxe_RPP] = atof( ptb_InRecChild[PRMLOA_RESERV_M] ) ;
//    break ;
//  case 10400 :
//    Ktd_Comp[Courtage_PRM] = atof( ptb_InRecChild[PRMLOA_ESTACC_M] ) ;
//    Ktd_Comp[Courtage_PPNA] = atof( ptb_InRecChild[PRMLOA_RESERV_M] ) ;
//    break ;
//  case 10401 :
//    Ktd_Comp[Courtage_REC] = atof( ptb_InRecChild[PRMLOA_ESTACC_M] ) ;
//    break ;
//  case 10420 :
//    Ktd_Comp[Courtage_EPP] = atof( ptb_InRecChild[PRMLOA_ESTACC_M] ) ;
//    Ktd_Comp[Courtage_RPP] = atof( ptb_InRecChild[PRMLOA_RESERV_M] ) ;
//    break ;
//  }
//
//  RETURN_VAL( OK ) ;
//}
//



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
	if ( n_OpenFileAppl( "ESTC1068_I5", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
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
	//[062]if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[PERFCI_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_END_NT] ) - atoi( pbd_InRecChild[PERFCI_END_NT] ) ) != 0 ) return ret ;	
	if ( ( ret = atoi( pbd_InRecOwner[PER_SEC_NF] ) - atoi( pbd_InRecChild[PERFCI_SEC_NF] ) ) != 0 ) return ret ; //[056] if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[PERFCI_SEC_NF] ) ) != 0 ) return ret ;
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
	

	if ( atoi( (ptb_InRecOwner)[PER_CTBTYP_CT] ) == 2 )
	{
		
	/*if ( strcmp(ptb_InRecOwner[PER_CTR_NF], "20T010203" ) == 0 )
		printf(" DANS ( (ptb_InRecOwner)[PER_CTBTYP_CT] ) == 2 In_ActionLignePerFci Kn_Fam_Nbp=%d\n", Kn_Fam_Nbp);	*/ 	
		
		Ktbd_FamCha_02[Kn_Fam_Nbl][Kn_Fam_Nbp].CHGTYP_B = (char)( atoi( ptb_InRecChild[PERFCI_CHGTYP_B] ) ) ;
		Ktbd_FamCha_02[Kn_Fam_Nbl][Kn_Fam_Nbp].MAX_R = atof( ptb_InRecChild[PERFCI_MAX_R] ) ;
		Ktbd_FamCha_02[Kn_Fam_Nbl][Kn_Fam_Nbp].MINRAT_R = atof( ptb_InRecChild[PERFCI_MINRAT_R] ) ;
		Ktbd_FamCha_02[Kn_Fam_Nbl][Kn_Fam_Nbp].MIN_R = atof( ptb_InRecChild[PERFCI_MIN_R] ) ;
		Ktbd_FamCha_02[Kn_Fam_Nbl][Kn_Fam_Nbp].MAXRAT_R = atof( ptb_InRecChild[PERFCI_MAXRAT_R] ) ;
		Ktbd_FamCha_02[Kn_Fam_Nbl][Kn_Fam_Nbp].RATTYP_B = atof( ptb_InRecChild[PERFCI_RATTYP_B] ) ;

		/* incrementation du compteur de poste du tableau */
		Kn_Fam_Nbp += 1 ;
		
	/*if ( strcmp(ptb_InRecOwner[PER_CTR_NF], "20T010203" ) == 0 )
	printf(" APRES INCEMENTATION :n_ActionLignePerFci Kn_Fam_Nbp=%d\n", Kn_Fam_Nbp);	*/	
		
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
	
	Kd_SurComRat =0;
	Kd_Tax = 0;   
	Kd_BrkRat =0;	
	
	
	Kd_PrmAmt = 0;				// Future Fixe Premium
	Kd_PrmVarAmt = 0;			// Future Variable Premium
	Kd_Claim_Amt = 0;			// Future Claim
	
	Kd_FuturBrk = 0;
	Kd_FuturCharge = 0 ;	
	
	Kd_DACBRK  = 0;    
	Kd_DACFIX = 0;	
 	Kd_DACVAR = 0;	
 	Kd_LOSSCORR = 0;	
 	Kd_RESULT_ACC = 0;		
	
	
	memset( Ktbd_FamCha, 0, ( NB_FAM_MAX * sizeof( T_TabFamCharIt ) ) ) ;
	memset( Ktbd_FamCha_02, 0, ( NB_FAM_MAX * sizeof( T_TabFamCharIt ) ) ) ;

	Kn_NbFam = 0 ;
	//printf(" \nDANS n_InitVariables Kn_Fam_Nbp=%d\n",Kn_Fam_Nbp );  
	Kn_Fam_Nbp = 0;
	//Ksz_ComRat_i = 0 ;
	/*Kn_CtrEstPa = 0 ;	*/

	RETURN_VAL ( OK ) ;
}

//[013] FIN Fonctions de gestion des Charges itérées



/*==============================================================================
objet :
  Test de rupture sur CTR_NF/END_NT/SEC_NF/UWY_NF/UW_NT
        pour le fichier pere (DLDGTA)

retour :
  0 ---> pas de rupture
        1 ---> rupture
==============================================================================*/
int n_ConditionRuptureDlGtaa(char ** tpsz_ReadBufferDlGtaa,
                                 char ** tpsz_ReadBufferDlGtaa_Cur)
{

  if (strcmp(tpsz_ReadBufferDlGtaa[GT_CTR_NF], tpsz_ReadBufferDlGtaa_Cur[GT_CTR_NF]) != 0)
    return (1);

  if (strcmp(tpsz_ReadBufferDlGtaa[GT_END_NT], tpsz_ReadBufferDlGtaa_Cur[GT_END_NT]) != 0)
    return (1);

  if (strcmp(tpsz_ReadBufferDlGtaa[GT_SEC_NF], tpsz_ReadBufferDlGtaa_Cur[GT_SEC_NF]) != 0)
    return (1);

  if (strcmp(tpsz_ReadBufferDlGtaa[GT_UWY_NF], tpsz_ReadBufferDlGtaa_Cur[GT_UWY_NF]) != 0)
    return (1);

  if (strcmp(tpsz_ReadBufferDlGtaa[GT_UW_NT], tpsz_ReadBufferDlGtaa_Cur[GT_UW_NT]) != 0)
    return (1);
    
    //printf(" DANS n_ConditionRuptureDlGtaa\n") ;

  return (0);
}




/*==============================================================================
objet :
  Fonction lancee en rupture derniere sur l'DlGtaa
        pour le fichier DlGtaa

retour :
  OK --->
        ERR --->
==============================================================================*/
int n_ActionLastDlGtaa(
	char **pbd_InRecOwner , /* adresse de la ligne du maitre */
	char **pbd_InRecChild ) /* adresse de la ligne de l'esclave */
{

	char   sz_Trncod[9];
	char   sz_Dblcod[2];
	char   sz_Amt[21];
	char   sz_Cur[4];
	double d_Amt;
	double d_taux;      // Taux de conversion en devise
	char	MsgAno[300] ; 	/* message d'anomalie */	

	double 	d_PbCalAmt = 0 ;	/* montant calcule de PB */
	double  d_PapCalAmt = 0 ;	/* montant calcule de PAP */
	double  d_PbRetAmt = 0 ;	/* montant retenu de PB */
	double  d_PapRetAmt = 0 ;	/* montant retenu de PAP */
	char	sz_PbOriCod[25] ;
	char	sz_PapOriCod[25] ;
	
	double Kd_Rc = 0 ;      //Rc =Result Account
	double Kd_Rc0 = 0 ;

        double d_MinComRate = 0;	

	double Kd_ManExp = 0;   // Management Expense
	double Kd_ProfitCommission = 0; //[053] Profit Commission 
	
	int n_PbPap_Nbp, i =0 ;
	

	DEBUT_FCT( "n_ActionLastDlGtaa" );

        //[057] repup du taux de commisssion mini 
        d_MinComRate = atof( pbd_InRecOwner[PER_MINCOM_R] );
        //if ( strcmp(pbd_InRecOwner[PER_CTR_NF], "02T033668") == 0)
        //printf("d_MinComRate %lf", d_MinComRate);

	memset( sz_Cur, 0, sizeof(sz_Cur) );

	memset(pFutures, 0 , sizeof (T_FUTURES));// on remet la structure a vide
	
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

	  strcpy( sz_Dblcod, "" );


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



		kd_AmtcPNA = 0;
		kd_AmtcPRM = 0;
		kd_AmtcPRT = 0;        //[06]		
	  k_TCom = 0 ;       	// Commission Rate	  //[027]


    /* Données des FUTURE PREMIUMS ET FUTURES SINISTRES */
    
 
		// printf(" 0002 TRACE_FUTURE_VARPRM Future  pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], GT_TRNCOD_CF, Kd_PrmVarAmt ; %s ;  %s ; %s ; %s ; %s ; %-.3f \n", pbd_InRecOwner[PER_CTR_NF], pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF],  pbd_InRecChild[GT_TRNCOD_CF],  Kd_PrmVarAmt);					

      Kd_Rc +=  Kd_PrmAmt + Kd_PrmVarAmt +Kd_Claim_Amt +(-1)* Kd_UPR_DAC_F_B_V ;	

			
			/*
			printf(" 0002 TRACE_FUTURE_CLAIM Future  pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], GT_TRNCOD_CF, Kd_Claim_Amt ; Kd_Rc ; Kd_Rc00 ; %s ;  %s ; %s ; %s ; %s ; %f ; %f ; %f \n", pbd_InRecOwner[PER_CTR_NF], pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF],  pbd_InRecChild[GT_TRNCOD_CF],  Kd_Claim_Amt, Kd_Rc, Kd_Rc00);					
			printf(" 0003 TRACE_FUTURE_UPR Future  pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], GT_TRNCOD_CF, Kd_UPR ; %s ;  %s ; %s ; %s ; %s ; %-.3f \n", pbd_InRecOwner[PER_CTR_NF], pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF],  pbd_InRecChild[GT_TRNCOD_CF],  Kd_UPR);									
			printf(" 0005 TRACE_FUTURE_BROKERAGE Future  pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], GT_TRNCOD_CF, Kd_DAC ; %s ;  %s ; %s ; %s ; %s ; %-.3f \n", pbd_InRecOwner[PER_CTR_NF], pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF],  pbd_InRecChild[GT_TRNCOD_CF],  Kd_DAC);									
			printf(" 0005 TRACE_FUTURE_DACFIX Future  pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], GT_TRNCOD_CF, Kd_DAC ; %s ;  %s ; %s ; %s ; %s ; %-.3f \n", pbd_InRecOwner[PER_CTR_NF], pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF],  pbd_InRecChild[GT_TRNCOD_CF],  Kd_DAC);									
			printf(" 0005 TRACE_FUTURE_DACVAR Future  pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], GT_TRNCOD_CF, Kd_DAC ; %s ;  %s ; %s ; %s ; %s ; %-.3f \n", pbd_InRecOwner[PER_CTR_NF], pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF],  pbd_InRecChild[GT_TRNCOD_CF],  Kd_DAC);									
			printf(" 0005 TRACE_FUTURE_LOSS_COR Future  pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], GT_TRNCOD_CF, Kd_DAC ; %s ;  %s ; %s ; %s ; %s ; %-.3f \n", pbd_InRecOwner[PER_CTR_NF], pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF],  pbd_InRecChild[GT_TRNCOD_CF],  Kd_DAC);									
		  */
		  
											

	/***********************************************************************************/
	/* Appel de la fonction d_CalculChargesCommissions de calcul du Taux de Commission */
	/***********************************************************************************/
		
			//if (strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0034621") == 0 &&  (atoi(pbd_InRecOwner[PER_UWY_NF]) == 2018) &&  (atoi(pbd_InRecOwner[PER_SEC_NF]) == 3) )   
			 	  k_TCom = d_CalculChargesCommissions(
												(char)( atoi( pbd_InRecOwner[PER_PRMNETCOM_B] ) ),
												( *pbd_InRecOwner[PER_CTRNAT_CT] == 'F' ? 1 : (char)( atoi( pbd_InRecOwner[PER_COMTYP_CT] ) ) ),
												atof( pbd_InRecOwner[PER_FIXCOM_R] ),
												atof( pbd_InRecOwner[PER_MAXCOM_R] ),
												atof( pbd_InRecOwner[PER_MINRATCLP_R] ),
												atof( pbd_InRecOwner[PER_MINCOM_R] ),
												atof( pbd_InRecOwner[PER_MAXRATCLP_R] ),
												Kd_Claim_Amt,
												(Kd_PrmAmt-Kd_UPR),
												Kn_NbFam,   
												Ktbd_FamCha 
												) ;												     												
																			
				/*								
				 La future Charge fixe n est calculée que si le type de commission est fixe (COMTYP != 2 	 ) et La FUTURE FIXE PREMIUM  != 0)					
				 [054] if (strcmp(pbd_InRecOwner[PER_CTRNAT_CT], "F")==0 || ( *pbd_InRecOwner[PER_COMTYP_CT]  == '2' )
	       [057] ajout d_MinComRate et on calcul pour les contrats type 1 2 3 ou 4		
				 [059]	
			  */		

	  if (
               (
                (*pbd_InRecOwner[PER_COMTYP_CT]  == '1' || *pbd_InRecOwner[PER_COMTYP_CT]  == '2'|| *pbd_InRecOwner[PER_COMTYP_CT]  == '3'|| *pbd_InRecOwner[PER_COMTYP_CT]  == '5') 
                && ( strcmp(pbd_InRecOwner[PER_CTRNAT_CT], "F") != 0 ) 
                )
               
              || 
               (  
                 
                 (strcmp(pbd_InRecOwner[PER_CTRNAT_CT], "F") == 0) && (*pbd_InRecOwner[PER_COMTYP_CT]  == '1')  //64
                               
                 
               ) 
             )  

				{ 					
					//d_Amt = (-1) * (Kd_ComRat + Kd_SurComRat + Kd_Tax) * (Kd_PrmAmt) ; //[043]
		      //[057] ajout d_MinComRate et on calcul pour les contrats type 1 2 3 ou 4

					//d_Amt =  (Kd_ComRat + Kd_SurComRat + Kd_Tax + (-1) * d_MinComRate) * (Kd_PrmAmt) ; //[043] Les montants sont deja negatifs, ne palus tenir compte du (-1)



 								
					d_Amt =  ( (-1) * atof( pbd_InRecOwner[PER_FIXCOM_R] ) + Kd_SurComRat + Kd_Tax + (-1) * d_MinComRate) * (Kd_PrmAmt) ; //[043] Les montants sont deja negatifs, ne palus tenir compte du (-1)								

#ifdef TRACE_FUTURE_FIXE_CHARGE	
     if (strcmp(pbd_InRecOwner[PER_CTR_NF], "FA0103900") == 0 &&  (atoi(pbd_InRecOwner[PER_UWY_NF]) == 2021)) //|| strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0039810") == 0 || strcmp(pbd_InRecOwner[PER_CTR_NF], "20T010203") == 0 || strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0017952") == 0 ||  (atoi(pbd_InRecOwner[PER_UWY_NF]) == 2017 && strcmp(pbd_InRecOwner[PER_CTR_NF], "01F008021") == 0 ) ) 
			{
					//printf("000 Future Fixe Charge pbd_InRecOwner ; [PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecOwner[PER_COMTYP_CT], pbd_InRecChild[GT_TRNCOD_CF], pbd_InRecChild[GT_AMT_M], pFutures->FUFEXP,  k_TCom,  Kd_PrmAmt, Kd_Claim_Amt, kd_AmtcPRT_PFOLIO ; Kd_ComRat; Kd_SurComRat; Kd_Tax; NEW_Fixed_Commission_Rate; FUTURE_CHARGE ;  %s ;%s ; %s ; %s ; %d; %s ; %f ; %f ; %f ; %f ; %f ; %f ; %f  ; %f ; %f \n", pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], atoi(pbd_InRecOwner[PER_COMTYP_CT]), pbd_InRecChild[GT_TRNCOD_CF], atof(pbd_InRecChild[GT_AMT_M]), d_Amt, k_TCom, Kd_PrmAmt,  Kd_ComRat, Kd_SurComRat, Kd_Tax, (Kd_ComRat + Kd_SurComRat + Kd_Tax), ((Kd_ComRat + Kd_SurComRat + Kd_Tax) * Kd_PrmAmt));			  		
					printf(" RETEST =  ERREUR TEST Kd_SurComRat = %f;  PER_FIXCOM_R=%f; d_Amt=%f Kd_PrmAmt=%f ; d_MinComRate= %f ; Kd_Tax=%f \n",Kd_SurComRat, atof( pbd_InRecOwner[PER_FIXCOM_R] ) ,d_Amt, Kd_PrmAmt,d_MinComRate, Kd_Tax);
			}
#endif

			  }	
			  else
					d_Amt = 0;						  
			  	
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
			//printf("00 Future Fixe Charge pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecOwner[PER_COMTYP_CT], pbd_InRecChild[GT_TRNCOD_CF], pFutures->FUFEXP,  k_TCom,  Kd_PrmAmt ;  %s ;%s ; %s ; %s ; %d ;%s ; %lf ; %lf ; %lf \n", pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], atoi(pbd_InRecOwner[PER_COMTYP_CT]), pbd_InRecChild[GT_TRNCOD_CF], pFutures->FUFEXP, k_TCom, Kd_PrmAmt);			
#endif				
				
				n_EcrireLog(); 

				if ( fabs(atof(sz_Amt)) > 1)
				{
					
#ifdef TRACE_FUTURE_FIXE_CHARGE	
		if (strcmp(pbd_InRecOwner[PER_CTR_NF], "10F155652") == 0 || strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0039810") == 0 || strcmp(pbd_InRecOwner[PER_CTR_NF], "20T010203") == 0 || strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0017952") == 0 ||  (atoi(pbd_InRecOwner[PER_UWY_NF]) == 2017 && strcmp(pbd_InRecOwner[PER_CTR_NF], "01F008021") == 0 ) ) 
			printf(" 01 Future Fixe Charge pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecOwner[PER_COMTYP_CT], pbd_InRecChild[GT_TRNCOD_CF], pFutures->FUFEXP,  k_TCom,  Kd_PrmAmt ;  %s ;%s ; %s ; %s ;%s ; %s ; %lf ; %lf ; %lf \n", pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecOwner[PER_COMTYP_CT], pbd_InRecChild[GT_TRNCOD_CF], pFutures->FUFEXP, k_TCom, Kd_PrmAmt);			
#endif						
					 
					n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );	
				}
				
      
      Kd_Rc +=  Kd_FuturCharge	;	 //Result Account 	
			 
					
				// Fin [013]  Calcul charge future --> Future Charge Fixe
				
			
				
				// Calcul du Kd_SC Sliding Scale "1A120052"
				//[057] on calcul pour type 2 et 4
				//[060] if ( atoi( pbd_InRecOwner[PER_COMTYP_CT])  != 2  && atoi( pbd_InRecOwner[PER_COMTYP_CT])  != 4 ) 
                                // Si TYP_COMMISSION != 2 Alors k_Tcom = 0								
				
				if ( atoi( pbd_InRecOwner[PER_COMTYP_CT])  != 2) 
				{
						Kd_SC = 0.0 ;
				}                                
				else 
                                                Kd_SC = (Kd_ComRat - (-1) * d_MinComRate) * Kd_PrmAmt;	
           
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
#ifdef TRACE_FUTURE_SLIDING_SCALE	 
      //if (strcmp(pbd_InRecOwner[PER_CTR_NF], "XXXXXX") == 0 &&  (atoi(pbd_InRecOwner[PER_UWY_NF]) == 2020) &&  (atoi(pbd_InRecOwner[PER_SEC_NF]) == 1) ) //|| strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0039810") == 0 || strcmp(pbd_InRecOwner[PER_CTR_NF], "20T010203") == 0 || strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0017952") == 0 ||  (atoi(pbd_InRecOwner[PER_UWY_NF]) == 2017 && strcmp(pbd_InRecOwner[PER_CTR_NF], "01F008021") == 0 ) ) 
      if ( (strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0034621") == 0 &&  (atoi(pbd_InRecOwner[PER_UWY_NF]) == 2018) &&  (atoi(pbd_InRecOwner[PER_SEC_NF]) == 3)) || 
      	   (strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0030490") == 0 &&  (atoi(pbd_InRecOwner[PER_UWY_NF]) == 2020) &&  (atoi(pbd_InRecOwner[PER_SEC_NF]) == 1))
      	)    
			printf("000 TRACE_FUTURE_SLIDING_SCALE;PER_CTR_NF;PER_END_NT]; PER_SEC_NF]; PER_UWY_NF]; PER_COMTYP_CT; Kn_NbFam; GT_TRNCOD_CF;k_TCom;Kd_PrmAmt;Kd_Claim_Amt;PER_FIXCOM_R ; PER_MAXCOM_R;PER_MINRATCLP_R;PER_MINCOM_R; PER_MAXRATCLP_R;Kd_ComRat;Kd_SurComRat;Kd_Tax;Kd_SC;FUTURE_SLIDING_02 ; %s ;%s ; %s ; %s ; %d; %d ; %s ; %f  ; %f ; %f ; %f ; %f ; %f ; %f ; %f ; %f ; %f ; %f ; %f ; %f  \n", 
												pbd_InRecOwner[PER_CTR_NF],  
												pbd_InRecOwner[PER_END_NT], 
												pbd_InRecOwner[PER_SEC_NF], 
												pbd_InRecOwner[PER_UWY_NF], 
												atoi(pbd_InRecOwner[PER_COMTYP_CT]), 
												Kn_NbFam,
												pbd_InRecChild[GT_TRNCOD_CF], 
												k_TCom, 
												Kd_PrmAmt, 
												Kd_Claim_Amt, 
												atof( pbd_InRecOwner[PER_FIXCOM_R] ),
												atof( pbd_InRecOwner[PER_MAXCOM_R] ),
												atof( pbd_InRecOwner[PER_MINRATCLP_R] ),
												atof( pbd_InRecOwner[PER_MINCOM_R] ),
												atof( pbd_InRecOwner[PER_MAXRATCLP_R] ), 
												Kd_ComRat, 
												Kd_SurComRat, 
												Kd_Tax, 
												Kd_SC, 
												(((-1)*k_TCom - (-1) * d_MinComRate) * Kd_PrmAmt));			
#endif             	
             	
               n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );
             }	
       
       
      Kd_Rc +=  Kd_SC;  //Result Account
        

		// [014] Deb Gestion "Future Brokerage" 
		// REGLE 04 - 05--> des taux de courtage : 1A120032 : calcul a intergrer
		// [051] replacement of brokerage rate 1A120032 by 1A120062
		// [016] R04-05 : Assumed Future Brokerage =  Brokerage Rate * Future Fixed Premium * -1
		//       Assumed Future Brokerage =  Brokerage Rate * Future Fixed Premium

             
				if ( fabs(Kd_PrmAmt) >= 1  && (*pbd_InRecOwner[PER_CTRNAT_CT] != 'N'))  // Cas des FAC et TRAITES PROPORTIONNELS
				{
		
#ifdef TRACE_FUTURE_BROKERAGE	
			if (strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0014443") == 0 || strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0039810") == 0 || strcmp(pbd_InRecOwner[PER_CTR_NF], "20T010203") == 0 || strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0017952") == 0 ||  (atoi(pbd_InRecOwner[PER_UWY_NF]) == 2017 && strcmp(pbd_InRecOwner[PER_CTR_NF], "01F008021") == 0 ) ) 						                                                                                                                                                					
					printf(" 0000 TRACE_FUTURE_BROKERAGE Future Brokerage pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], GT_TRNCOD_CF, Kd_FuturBrk, Kd_BrkRat, Kd_PrmAmt ; %s ;  %s ; %s ; %s ; %s ;  %-.3f ; %-.3f ; %-.3f \n", pbd_InRecOwner[PER_CTR_NF], pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF],  pbd_InRecChild[GT_TRNCOD_CF], Kd_FuturBrk, Kd_BrkRat, Kd_PrmAmt);					
#endif			
			  
			  	d_Amt = Kd_BrkRat * Kd_PrmAmt  ; 		//[016]   (-1); Attention le signe (-1) est deja pris en compte a l'extraction du taux de la table LOARAT
			  	Kd_FuturBrk = d_Amt ; 
					pFutures->FUBROKER = d_Amt;					// Future Brokerage			  
			  
				}	                                     
            																		
			  /* Condition de calcul des FUTURE BROKERAGE et VARIABLE CHARGES */
			  
#ifdef TRACE_FUTURE_BROKERAGE	
      if (strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0014443") == 0 || strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0039810") == 0 || strcmp(pbd_InRecOwner[PER_CTR_NF], "20T010203") == 0 || strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0017952") == 0 ||  (atoi(pbd_InRecOwner[PER_UWY_NF]) == 2017 && strcmp(pbd_InRecOwner[PER_CTR_NF], "01F008021") == 0 ) ) 						                                                                                                                                                					
			printf(" 0000AA TRACE_FUTURE_BROKERAGE Future Brokerage pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], GT_TRNCOD_CF, Kd_FuturBrk, Kd_BrkRat, Kd_PrmAmt ; %s ;  %s ; %s ; %s ; %s ;  %-.3f ; %-.3f ; %-.3f \n", pbd_InRecOwner[PER_CTR_NF], pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF],  pbd_InRecChild[GT_TRNCOD_CF], Kd_FuturBrk, Kd_BrkRat, Kd_PrmAmt);					
#endif		
							
						

		// [039] Calcul FUTURE BROKERAGE NOUVELLE FORMULE, Uniquement pour les Non Proportionnels
		/****************************************************************************************************/
		/*  Assumed Future Brokerage =  Brokerage Rate * Future Fixed Premium * -1                          */
		/*                              + Brokerage Rate * Future Variable Premium * -1 (If Burning Cost)   */
		/*                              + Reinstatement Brokerage Rate * Future Variable Premiums * -1      */
		/****************************************************************************************************/
		
		/*if Non Proportional Treaty 
		 {
		 	 if (NOT Flat Premium (TFAMCOTP..PER_FLAPRM_B = 0) and Variable Rate (TFAMCOTP..PRMFLCRAT_B = 1) (Burning Cost calculation)
		 	 		(Brokerage Rate * Future Fixed Premium * -1) + (Brokerage Rate * Future Variable Premium * -1)
		 	 else
		 	 	(Brokerage Rate * Future Fixed Premium * -1) + (Reinstatement Brokerage Rate (TFAMCH.RECBRK_R) * Future Variable Premiums * -1)
		 }
		
			if (strcmp(pbd_InRecOwner[PER_CTR_NF], "17T008138") == 0 && (atoi(pbd_InRecOwner[PER_SEC_NF]) == 1) && (atoi(pbd_InRecOwner[PER_UWY_NF]) == 2015) )
			printf(" DONNEES AVANT CTR =%s ; UWY = %d ; SECT = %d ; PER_CTRNAT_CT=%s ; PER_FLAPRM_B=%s ; PER_PRMFLCRAT_B=%s ; Kd_PrmAmt=%f ; Kd_BrkRat=%f ; Kd_PrmVarAmt=%f ; PER_RECBRK_R=%f   PER_FLAPRM_B_02=%d ; PER_PRMFLCRAT_B_02=%d; BROK1=%f ; BROK2=%f \n", pbd_InRecOwner[PER_CTR_NF], atoi(pbd_InRecOwner[PER_UWY_NF]), atoi(pbd_InRecOwner[PER_SEC_NF]), pbd_InRecOwner[PER_CTRNAT_CT], pbd_InRecOwner[PER_FLAPRM_B], pbd_InRecOwner[PER_PRMFLCRAT_B], Kd_PrmAmt, Kd_BrkRat, Kd_PrmVarAmt, atof(pbd_InRecOwner[PER_RECBRK_R]), atoi(pbd_InRecOwner[PER_FLAPRM_B]), atoi(pbd_InRecOwner[PER_PRMFLCRAT_B]) ,(Kd_PrmAmt * Kd_BrkRat) + (Kd_PrmVarAmt * Kd_BrkRat) , (Kd_PrmAmt * Kd_BrkRat) + (Kd_PrmVarAmt * atof(pbd_InRecOwner[PER_RECBRK_R]) * (-1)));	
		*/
			
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
      strcpy( sz_Trncod, "1A120062" );  				// [051] replacement of brokerage rate 1A120032 by 1A120062
      pFutures->TRNCOD = sz_Trncod; 
			pbd_InRecChild[GT_RETAMT_M] = "0";
			pbd_InRecChild[GT_RETINTAMT_M] = "0";
			pbd_InRecChild[GT_TRNCOD_CF] = sz_Trncod;
			pbd_InRecChild[GT_DBLTRNCOD_CF] = sz_Dblcod;
			pbd_InRecChild[GT_AMT_M] = sz_Amt;
			pbd_InRecChild[GT_CUR_CF] = sz_Cur;

      
      n_EcrireLog();

      if ( fabs(atof(sz_Amt)) > 1)
      {
#ifdef TRACE_FUTURE_BROKERAGE 
      if (strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0014443") == 0 || strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0039810") == 0 || strcmp(pbd_InRecOwner[PER_CTR_NF], "20T010203") == 0 || strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0017952") == 0 ||  (atoi(pbd_InRecOwner[PER_UWY_NF]) == 2017 && strcmp(pbd_InRecOwner[PER_CTR_NF], "01F008021") == 0 ) ) 						                                                                                                                                                					
         printf(" TRACE_FUTURE_BROKERAGE Future Brokerage pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], GT_TRNCOD_CF, Kd_FuturBrk, Kd_BrkRat, pFutures->FUBROKER ; %s ;  %s ; %s ; %s ; %s ;  %-.3f ; %-.3f ; %-.3f \n", pbd_InRecOwner[PER_CTR_NF], pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF],  pbd_InRecChild[GT_TRNCOD_CF], Kd_FuturBrk, Kd_BrkRat, pFutures->FUBROKER);
#endif        	
        	
           n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );
      }	

 			
 			Kd_Rc +=  Kd_FuturBrk ; // [050] Result Account
 			

		
		 // Fin Calcul Brokerage
		 	
	
	/* complement des affectations des postes du tableau des participations */ 

		{ 
			Ktbd_Par[Kn_Par_Nbp].PRMAMT_M = Kd_PrmAmt ;   	// [015] Future Fixed Premium (calculated in R02-01) - UPR == [Prime Acquise Comptabilisee + prime cedante ] --> kd_AmtcPNA
			//[053] Ktbd_Par[Kn_Par_Nbp].ACCRES_M = Kd_PrmAmt-Kd_UPR + ( Kd_FuturCharge - Kd_DACFIX + Kd_Claim_Amt + Kd_FuturBrk) ; // [015] Rsesult Account										
			
			//Ktbd_Par[Kn_Par_Nbp].ACCRES_M =  Kd_PrmAmt  + Kd_PrmVarAmt + Kd_SC - (Kd_UPR_DAC_F_B_V) + Kd_FuturCharge + Kd_FuturBrk + Kd_Claim_Amt + Kd_LOSSCORR ;
			
			Kd_Rc0 = Kd_PrmAmt  + Kd_PrmVarAmt + Kd_SC -Kd_UPR - (Kd_DACFIX + Kd_DACVAR + Kd_DACBRK) + Kd_FuturCharge + Kd_FuturBrk + Kd_Claim_Amt + Kd_LOSSCORR ; // [050] Result Account
			
			Ktbd_Par[Kn_Par_Nbp].ACCRES_M = Kd_Rc0 ;

#ifdef TRACE_FUTURE_VARIABLE_CHARGE	 
	if (  (( strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0034621") == 0  ) && (atoi(pbd_InRecOwner[PER_SEC_NF]) == 3) && (atoi(pbd_InRecOwner[PER_UWY_NF]) == 2018) )  
		  || (( strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0028718") == 0  ) && (atoi(pbd_InRecOwner[PER_SEC_NF]) == 1) && (atoi(pbd_InRecOwner[PER_UWY_NF]) == 2019) ) 
		 )
      { 							
			printf(" Result Account (Rc_new) : CTR;UNDE;SECT;UWY; Result_Account; Kd_Rc0; Ktbd_Par[Kn_Par_Nbp].ACCRES_M; Ktbd_Par[Kn_Par_Nbp].PRMAMT_M ; Kd_PrmAmt; Kd_PrmVarAmt; Kd_SC, Kd_UPR, Kd_FuturCharge, Kd_DACFIX, Kd_DACVAR, Kd_DACBRK, Kd_Claim_Amt, Kd_FuturBrk ; Kd_LOSSCORR;  %s~%s~%s~%s~ ; %f ; %f ; %f ; %f ;%f ;  %f ; %f ; %f; %f ; %f ; %f ; %f ; %f ; %f ; %f \n", 
			                            pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], (Kd_PrmAmt  + Kd_PrmVarAmt + Kd_SC -Kd_UPR - (Kd_DACFIX + Kd_DACVAR + Kd_DACBRK) + Kd_FuturCharge + Kd_FuturBrk + Kd_Claim_Amt + Kd_LOSSCORR), Kd_Rc0, Ktbd_Par[Kn_Par_Nbp].ACCRES_M, Ktbd_Par[Kn_Par_Nbp].PRMAMT_M, Kd_PrmAmt, Kd_PrmVarAmt, Kd_SC, Kd_UPR, Kd_FuturCharge, Kd_DACFIX, Kd_DACVAR, Kd_DACBRK, Kd_Claim_Amt, Kd_FuturBrk, Kd_LOSSCORR);			
			}
#endif   

	/* incrementation du nombre de postes du tableau Ktbd_Par */
	Kn_Par_Nbp -= 1 ;

	/* incrementation du nombre de postes du tableau Ktbd_FamCha_02 */
	if ( atoi( pbd_InRecOwner[PER_CTBTYP_CT] ) == 2 )
		Kn_Fam_Nbl -= 1 ;

	/*********************************************************************/
	/* Appel de la fonction n_CalculPartBenefPert de calcul de PB et PAP */
	/*********************************************************************/

#ifdef TRACE_FUTURE_VARIABLE_CHARGE	
	if (  (( strcmp(pbd_InRecOwner[PER_CTR_NF], "20T008267") == 0  ) && (atoi(pbd_InRecOwner[PER_SEC_NF]) == 1) && (atoi(pbd_InRecOwner[PER_UWY_NF]) == 2019) )  
		  || (( strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0028718") == 0  ) && (atoi(pbd_InRecOwner[PER_SEC_NF]) == 1) && (atoi(pbd_InRecOwner[PER_UWY_NF]) == 2019) ) 
		 ) 
#endif		                                                                                                          

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

			if (strcmp(sz_PbOriCod, "CloP") == 0)
		  	strcpy( Kz_PbOriCod, "PB_Calculable" ) ; 	
		  else 
		  	strcpy( Kz_PbOriCod, "PB_Non_Calculable" ) ; 			
		
		
#ifdef TRACE_FUTURE_PROFIT_COMMISSION
      if (( strcmp(pbd_InRecOwner[PER_CTR_NF], "06T004696") == 0 ||strcmp(pbd_InRecOwner[PER_CTR_NF], "17T010060") == 0 ) && (atoi(pbd_InRecOwner[PER_SEC_NF]) == 1) && (atoi(pbd_InRecOwner[PER_UWY_NF]) == 2019) )  
					printf(" MZ 02 Affichage ; Profit(PB)  ; CESU %s~%s~%s~%s~; Kd_PB[%lf] ; \n", pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF],pbd_InRecOwner[PER_UWY_NF], Kd_PB); 
#endif		

		/* positionnement du montant calcule PAP */
		if ( tbd_PbPap[i].PAPEX == 1 )
		{
			/* cas ou les PB/PAP ne sont pas calculables */                   //CTCOM_B;           /*Indic de participation    1  (Clop)-> calculable, 0 (Account) sinon */
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
			
			if (strcmp(sz_PapOriCod, "CloP") == 0)
		  	strcpy( Kz_PapOriCod, "PaP_Calculable" ) ; 	
		  else 
		  	strcpy( Kz_PapOriCod, "PaP_Non_Calculable" ) ; 			  							
			
		}

		/* positionnement du montant retenu PB */
		if ( Ktbd_EstGt[Kn_Par_Nbp + 1 + i].PBADMMOD_CT == 'A' )
			d_PbRetAmt = d_PbCalAmt ;
		else	d_PbRetAmt = Ktbd_EstGt[Kn_Par_Nbp + 1 + i].PBENTAMT_M ;

#ifdef TRACE_FUTURE_PROFIT_COMMISSION
     if (( strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0028718") == 0  ) && (atoi(pbd_InRecOwner[PER_SEC_NF]) == 1) && (atoi(pbd_InRecOwner[PER_UWY_NF]) == 2019) )  
					printf(" MZ 05 Affichage ;Montant REtenu Kd_PB  ; CESU %s~%s~%s~%s~; Kd_PB=%f ; Kd_PAP=%f ; Kz_PbOriCod=%s ; Kz_PapOriCod=%s \n", pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF] , pbd_InRecOwner[PER_UWY_NF],  Kd_PB, Kd_PAP, Kz_PbOriCod, Kz_PapOriCod); 
#endif


		/* positionnement du montant retenu PAP */
		if ( Ktbd_EstGt[Kn_Par_Nbp + 1 + i].PAPADMMOD_CT == 'A' )
			d_PapRetAmt = d_PapCalAmt ;
		else	d_PapRetAmt = Ktbd_EstGt[Kn_Par_Nbp + 1 + i].PAPENTAMT_M ;		

	}
	
	
	  // [053] 
	  
		/*******************************************************************************************/
		/* 	[053] 		PCR (Profit Commission Rate) and  Management Expenses rates									 */
		/* 			 Profit Commission Rate =  Kd_ComRat = -1 * atof( ptb_InRecChild[LOA_COMMIS_R] ) ; */
		/*       Management Expenses rates = pbd_InRecOwner[PER_CTBGENFEE_R]                       */
		/***                                                                  								  ****/
		/*       Ce calcul est effectué dans la fonction n_CalculPartBenefPert                     */
		/*       Seule la formule du Rc doit etre modifiée                                         */
		/* *****************************************************************************************/	  
	  /* */
	  Kd_ManExpRate = atof( pbd_InRecOwner[PER_CTBGENFEE_R]) ; 
		Kd_ManExp = (-1)* Kd_PrmAmt * Kd_ManExpRate ;      
		
		if (Kd_Rc0 + Kd_ManExp > 0)
		  Kd_ProfitCommission = (Kd_Rc0 + Kd_ManExp) * Kd_ComRat   ; // Kd_ComRat est extrait avec un taux * (-1)
		else
		  Kd_ProfitCommission = 0;
		/* */ 
		
		
	/*Ecriture de Kd_PB + Kd_PAP Spira 78628 [045]*/
    
    sprintf( sz_Amt, "%-.3f", Kd_PB + Kd_PAP );
   
    //[053]sprintf( sz_Amt, "%-.3f", Kd_ProfitCommission ); 
         
    strcpy( sz_Trncod, "1A120072" );
    pbd_InRecChild[GT_RETAMT_M] = "0";
    pbd_InRecChild[GT_RETINTAMT_M] = "0";
    pbd_InRecChild[GT_TRNCOD_CF] = sz_Trncod;
    pbd_InRecChild[GT_DBLTRNCOD_CF] = sz_Dblcod;
    pbd_InRecChild[GT_AMT_M] = sz_Amt;
    pbd_InRecChild[GT_CUR_CF] = sz_Cur;

   	
   	if ( fabs(atof(sz_Amt)) > 1 )
    {
#ifdef TRACE_FUTURE_PROFIT_COMMISSION

      if (( strcmp(pbd_InRecOwner[PER_CTR_NF], "TR0028718") == 0 ||strcmp(pbd_InRecOwner[PER_CTR_NF], "17T009948") == 0 ) && (atoi(pbd_InRecOwner[PER_SEC_NF]) == 1) && (atoi(pbd_InRecOwner[PER_UWY_NF]) == 2019) )                                                                                                                                                                                  
					printf(" TRACE_FUTURE_PROFIT_COMMISSION ; GT_ORICOD_LS ; pbd_InRecOwner[PER_CTR_NF];  pbd_InRecOwner[PER_END_NT]; pbd_InRecOwner[PER_SEC_NF]; pbd_InRecOwner[PER_UWY_NF] ; Fut_Profit_Com ;Kd_PrmAmt; Kd_PrmVarAmt; Kd_Rc0; Kd_ManExp; Kd_DACFIX; Kd_DACVAR; Kd_DACBRK; Kd_FuturCharge; Kd_FuturBrk; Kd_ComRat; Kd_LOSSCORR ; Kd_Claim_Amt ; ManExpRate ; Kd_PB ; Kd_PAP;  %s; %s~%s~%s~%s ; %f; %f ; %f ; %f ; %f ; %f ; %f ; %f ; %f ; %f ; %f ; %f ; %f ; %f ; %f ; %f \n",
          pbd_InRecChild[GT_ORICOD_LS], pbd_InRecOwner[PER_CTR_NF],  pbd_InRecOwner[PER_END_NT], pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], atof(pbd_InRecChild[GT_AMT_M]), Kd_PrmAmt, Kd_PrmVarAmt, Kd_Rc0, Kd_ManExp, Kd_DACFIX, Kd_DACVAR, Kd_DACBRK, Kd_FuturCharge, Kd_FuturBrk, Kd_ComRat, Kd_LOSSCORR, Kd_Claim_Amt, atof(pbd_InRecOwner[PER_CTBGENFEE_R]), Kd_PB, Kd_PAP);
    	
#endif    	
		
      n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );
    }
					

		/**************************************************************************/
		/*          Formules de Calcul de la Future Variable Charge               */
		/**     									                                               **/
		/**         d_Amt = Kd_PB + Kd_PAP +  Kd_SC                              **/
		/**                                                                      **/                                                 
		/**       AVEC   Kd_SC = Kd_ComRat * Kd_PrmAmt                           **/ //[031]		
		/**************************************************************************/
		       
		
				// Le taux de commission est égale à zero lorsque le type de commission n'est pas variable ;		


				//if (strcmp(pbd_InRecOwner[PER_CTRNAT_CT], "F")==0)  //[053]
				if ( strcmp(pbd_InRecOwner[PER_CTRNAT_CT], "F")==0 && ( (strcmp(Ksz_NORME, "I17G") !=0 && strcmp(Ksz_NORME, "I17P") != 0 && strcmp(Ksz_NORME, "I17L") != 0 && strcmp(Ksz_NORME, "I17S") != 0 && strcmp(Ksz_NORME, "INI") != 0  && strcmp(Ksz_NORME, "BBNI") != 0 ) ) 	)   //[063] //[65] ////[066]
					d_Amt = 0.0;
				else
					d_Amt = Kd_PB + Kd_PAP +  Kd_SC ;   //[015]  

			 
		 } /* Calcul des FUTURE BROKERAGES et VARIABLES CHARGES */ 
		 
	
	RETURN_VAL(OK);	
	
}
				
