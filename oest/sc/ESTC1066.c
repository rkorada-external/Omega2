/*==============================================================================
nom de l'application          : ESTIMATION SOLVENCY
nom du source                 : ESTC1066
révision                      : $Revision: 1.0 $
date de création              : 03/10/2018
auteur                        : MZM
references des specifications :
squelette de base             : batch
------------------------------------------------------------------------------
description :
   :REQ10.7 et REQ10.8 - Calcul des primes et charges futures et des primes sinistre
                 avec Transformation des postes pour la RETRO NP
:spira:70671:Future premium for retro NP contracts ; 
:spira:70782:Future claim for retro NP contracts                 
	 : En entree
	   	- FIRDPERICASE --> Fichier IRDPERICASE TRIEE
	   	- FTECLEDRSO -->    
	   	- FPLACEMT0  -->  Fichier des PLACEMENTS --> Permet d'extraire PLA_RETSIGSHA_R Placement share value
	   	- FBOTRSLNK 
	   	- FCURQUOT
	   	- F_ITD_PREMIUM --> Fichier des ITD Premium obtenu via la procedure stockée BSAR_PsRETITDPRM_01 et du fichier FTECLEDRSO
	   	- F_UPR  -->  Fichier des UPR obtenu à partir de la PS BSAR_PsRETITDPRM_01 et du fichier FTECLEDRSO
	 
	 En SOrtie
	 		- Fichier contenant les FUTURES RETRO EPO_DLDGTR_E
	 		- Fichier LOG a destination des Utilisateurs
	 		- Fichier Anomalies	
	  
	 
	 
2A100012 = Future Premium
2A494302 = Future Claim
         

------------------------------------------------------------------------------
historique des modifications :
[01] 27/03/2019 MZM :spira:76743 Retro NetPremium Multiple currency
[02] 04/06/2019 MZM :spira:76743 Retro Net premium, multiple currencies : Champ PER_EGPCUR_CF Monnaie de 
[04] 16/10/2019 MZM :spira:73772:Manage retro contract and merge input to cashflow calculations,
																 (2A100112) : Calcul des Future Premium Written Remaining Estimates
																 (2A100122) : Annulation Calcul des Future Premium Written Remaining Estimates 
                                 (2A120112) : Future Fixed Commission Written Remaining Estimates  
                                 (2A120122) : Annulation des Future Fixed Commission Written Remaining Estimates 
[05] 09/12/2019 MZM :spira:70671 Alimentation Systématiques des champs RETEND_NT et RETUW_NT des Retro FUTURE à partir du PERICASE V2                                 
[06] 03/02/2020 NLD :spira 84531 No future premium Q42019 position on several Retro NP contracts 
[07] 04/05/2020 MZM :spira 85847 Change in future claim formula // Activer des la livraisonde la spira 85714
[08] 05/05/2020 RC  :spira:83691 TRSPFX_CF test must be done on 2 not 1 when searching FBOPRSLNK becaus they are Retro trncod 
[09] 15/05/2020 MZM :Spira:84900 : REQ10.1/RE10/.13: change Remaining 
[10] 18/05/2020 MZM :Spira:81349 : REQ 10.7 Future Premium = Net Retro Premium : Filtre effectue aussi dans l'ESTC1066 en plus du Shell ESPD2571 sur poste "21101105"
[11] 24/07/2020 MZM :Spira:83120 : Multiple Currency 
[12] 05/08/2020 MZM :Spira:86100 : REQ 11.07 Inconsistent rule for the different CFs when abs(EGPI<=1) at init
[13] 12/08/2020 JYP :Spira:89218 : taille tableau FBOPRSLNK
[14] 13/04/2021 MZM :Spira:89705 : Retro NP Future claims - UPR currency : Convertir UPR en monnaire PERICASE
[015] 24/06/2021 MZM :Spira:97112 : expiry date > closing date" applies only for the calculation of retro future premium 
                                   and not for the calculation of the retro future claims or any other future item?
                                   Suppression du test sur la condition RetronetPremium = 0 
[016] 12/10/2021 MZM :Spira:97112 :Reintegration de la condition  "RetronetPremium = 0" Pas de calcul de FUTURE RETRO PREMIUM      
[017] 05/07/2022  JBD :spira 104778:  Build new closing for I17S norm

================================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "ESTC1066.h" 
#include "struct.h"
#include "estserv.h"
#include "estutil.c"

/*----------------------------------------*/
/* inclusion de version dans les binaires */
/*----------------------------------------*/
static char VERSION_ESTC1066_C[150] = "__version__: ESTC1066.c [16] MZM 20211012 RetronetPremium zero Pas de FUTPRM \n" ;

 
/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/
#define NB_TRSLNK_MAX 30000   //  [002]
#define SEPARATOR 	 "~"

#define Kn_MaxLigFBOTRSLNK   60000 // 
#define Kn_MaxPostes 100000	/* Le nombre max de postes est fixe a 100000 */
//#define UPR   1
//#define ITD   3
//#define OTHER 6 

#define UPR   1 
#define DAC   2 
#define COME  3 
#define PRME  4 
#define ITD   5 
#define OTHER 6 



#define NB_COL_GT 41 

/*
#define TRACE_UPR 
#define TRACE_FUTURE_RETRO_CLAIMS
#define TRACE_ITDPREMIUM 
#define TRACE_FUTURE_RETRO_PREMIUM
#define TRACE_CALCUL_RETSIGSHA_R
#define TRACE_RETNETPRM_PRICING_LF
#define TRACE_ConditionSyncITDPRM 
*/

/*#define TRACE_UPR 
#define TRACE_REMAINING_PRM
#define TRACE_REMAINING_PRM_ANN
#define TRACE_REMAINING_COMM
#define TRACE_REMAINING_COMM_ANN
*/
/*----------------------------------*/

// Ajout d'une structure pour stocker les colonnes de sorties de log

typedef struct T_FUT_LOGS{
		char* RETCTR_NF;
		short RETEND_NT;
		short RETSEC_NF;
		short RTY_NF;
		double SCOEGP_M;
		char*  RETCUR_CF;
		double AMTCEXP_M;
		double AMTCPRM_M;
		double UPRAMT;
		double LOSRAT_R;
		double TAUX;
		double FURETPREMIUM;	
		double FURETCLAIM;
		double FURETEXP;
	  char*  TRNCOD;					
		} T_FUTURES;	

	T_FUTURES*	pFutures;

// Structure de placement : colonne Total de placement

typedef struct {
  unsigned char SSD_CF;
  unsigned char ESB_CF;
  char RETCTR_NF[10];
  unsigned char RETEND_NT;
  unsigned char RETSEC_NF;
  short RTY_NF;
  unsigned char RETUW_NT;
  int PLC_NT;
  int RTO_NF;
  double RETSIGSHA_R0;
  double TOTRETSIGSHA_R0; 
} T_PLACEMENT;

T_PLACEMENT* pPlacement;

	int 	Kn_RecRnk ;

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE   *Kp_OutputFilResSii;    /* pointeur sur le fichier de sortie formaté avec les nouvelles colonnes */
FILE   *Kp_OutputFilResSiiAno; /* pointeur sur le fichier de sortie des lignes sans segment */


FILE   *Kp_InputFilExc;        /* pointeur sur le fichier en entree des cours de change */
FILE   *p_OutputFutures; 	   /* Fichier de log pour les users [05] -=Dch=-  */

T_RUPTURE_VAR       bd_RuptPerUw;   /* variable de gestion de la rupture sur le perimetre de Accept ou Retro */
T_RUPTURE_SYNC_VAR  bd_RuptITDPRM; 	/* variable de gestion de la rupture sur le perimetre  Retro */
T_RUPTURE_SYNC_VAR 	bd_RuptFPLACEMENT; /* variable de gestion de la synchronisation avec le fichier des Placements */  


int n_InitPerUw            ( T_RUPTURE_VAR  *pbd_Rupt );
int n_TestRupturePER       (char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionFistRupturePER (char **pbd_InRec_Cur);  
int n_ActionLignePER			 ( char **pbd_InRec_Cur );


int n_InitITDPRM		      ( T_RUPTURE_SYNC_VAR *pbd_Rupt );
int n_ActionLigneITDPRM    ( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ActionPereSansFilsITDPRM(char **ptsz_LigneMaitre);  
int n_ActionLastITDPRM(char **pbd_InRecOwner, char **pbd_InRecChild); 
int n_ConditionSyncITDPRM  ( char **pbd_InRecOwner, char **pbd_InRecChild );

T_RUPTURE_SYNC_VAR  bd_RuptUpr; /* variable de gestion de la synchronisation avec le fichier UPR */
int n_InitUpr		   ( T_RUPTURE_SYNC_VAR *pbd_Rupt );
int n_ActionLigneUpr    ( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ConditionSyncUpr  ( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ActionPereSansFilsUpr(char **ptsz_LigneMaitre);


int n_ProcessingRuptureSyncVar (T_RUPTURE_SYNC_VAR  *pbd_Rupt, char **pbd_InRecOwner );

void n_EcrireLog();  // sortie de la log FUTURES


int n_InitPLACEMENT2( T_RUPTURE_SYNC_VAR  *bd_RuptFPLACEMENT);
int n_ConditionSyncGTR_PLACEMENT2( char **ptGTR, char **ptPLACEMENT2 );
int n_ActionLignePLACEMENT2( char **ptGTR, char **ptPLACEMENT2 );
int n_ActionPereSansFilsPLACEMENT2(char **ptsz_LigneMaitre);


int n_ChargerFBOTRSLNK();                 
int n_check_trncd_cf(char *sz_TrnCd); 
int n_rech_trncd_itd(char *sz_TrnCd); 

FILE *Kp_FBOTRSLNK;                              

int Kn_FBOTRSLNK ;                               
T_FBOTRSLNK Ktbd_FBOTRSLNK[Kn_MaxLigFBOTRSLNK];  

T_TRSLNK Ktbd_TrsLnk[Kn_MaxPostes];

int Kn_NbLigTrslnk;

int n_type_trn_cd;                               
char Ksz_CloDat[10]        ;                          
char Ksz_gte_esb_cf[5]     ;                     
char Ksz_Annee_bilan[5]    ;                     
char Ksz_Mois_bilan[3]     ;                     
char Ksz_Jour_bilan[3]     ;                     
char Ksz_PerCedNf[50]      ;                     
char Ksz_PerPrdNf[50]      ;                     
char Ksz_PerGenPrmPayNf[50];                     
char Ksz_PerGanPayOrdNt[50];                        

double  Kd_UPR = 0 ;        							// Montant Retro UPR 
double  Kd_RetNetPrm  = 0;  				// Montant Retro Net PREMIUM
 
double  Kd_Prmrest ;    /* montant des estimations de primes restantes "non acquises "      [11] */ 
double  Kd_Commrest;    /* montant des estimations de commission restantes "non acquises"   [11] */
double  Kd_UPR;         // [11]
double  Kd_DAC;         // [11]
double  Kd_PRME;
double  Kd_COME;
char   c_DAC_FLG;       // [11]
char   c_PRME_FLG;        
char   c_COME_FLG;


char   c_UPR_FLG;       
char   c_NETP_FLG;   

double kd_RETSIGSHA_R;				 // Placement Share VAlue 
char Ksz_PLC_NT[20]      ;     // Placement No
char Ksz_RTO_NF[20]      ;     // Placement RTO

char   kc_TRTNP_BILAN = 'N';   //quand TRTNP et année de souscription supèrieure à date bilan -2
double kd_AmtcPRM;             // Montant sauvegarde
double kd_UPRAMT;             // Montant sauvegarde
double kd_AmtcPRT;             //[06]
int    kn_MIN_ICLODAT_A; 			 //date bilan -2 (dans le ESID2003)

double Kd_RetPrmAmt  = 0;					// Montant Retro Future Premium

double Kd_retro_pricing_LR = 0; // Montant Retro Future Pricing

double Kd_ITDWrittenPrem = 0 ;    // Montant ITD Premium

double kTOT_RETSIGSHA_R = 1 ;     // Part total des placement sur la cle (CTR, SEC, RTY)

char ** Ks_LastITD; //last  sync with ITD [11]

//[012]
char  Ksz_NORME[5] ;       //  NORME : 'EBS' ; 'IFRS' ; 'I17G' ; 'I17L' ; 'I17P' 
char  Kc_Norme_Suf[1] ; // = 'Z';  // SUFFICE DE LA Norme pour construire le TRNCOD des FUTURES AT INCEPTION (Kc_Norme_Suf : GROUP --> 'I' ; PARENT --> 'P' ; LOCAL --> 'M')

//double Kd_Claim_RetAmt ;	  // Montant Retro Future Claims



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

	printf("Running with %s  ", VERSION_ESTC1066_C);
	
	kn_MIN_ICLODAT_A = atoi(psz_GetCharArgv(1));
    strcpy( Ksz_CloDat, psz_GetCharArgv(2) ) ;
    
  	 strcpy(Ksz_NORME, psz_GetCharArgv(3)); //[012]
    

   /* Eclatement de la date AAAAMMJJ en 3 chaines de caractere */
    sscanf( Ksz_CloDat, "%4s%2s%2s", Ksz_Annee_bilan, Ksz_Mois_bilan, Ksz_Jour_bilan ) ;


	/* ouverture du fichier en entree des cours de change FCURQUOT */
	if ( n_OpenFileAppl ( "ESTC1066_I4","rb",&Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* [11] ouverture du fichier en entree FBOTRSLNK */
    if (n_OpenFileAppl("ESTC1066_I5", "rb", &Kp_FBOTRSLNK) == ERR )
        ExitPgm(ERR_XX ,"cannot open Kp_FBOTRSLNK ");
        
	/* ouverture du fichier de sortie des resultats par affaire */
	if ( n_OpenFileAppl ( "ESTC1066_O1","wt",&Kp_OutputFilResSii ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* ouverture du fichier de sortie des resultats par affaire */
	if ( n_OpenFileAppl ( "ESTC1066_O2","wt",&Kp_OutputFilResSiiAno ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* ouverture du fichier de sortie des logs */
	if ( n_OpenFileAppl ( "ESTC1066_O3","wt",&p_OutputFutures ) == ERR )
		ExitPgm( ERR_XX , "" );


    /* Chargement du tableau TRSLNK pour les postes 750 */       
    Kn_FBOTRSLNK = n_ChargerFBOTRSLNK();                         
    if ( Kn_FBOTRSLNK == -1 )                                    
    		ExitPgm( ERR_XX , "Taille tableau FBOTRSLNK insuffisante " ) ; 
		
		
	pFutures = (T_FUTURES *) calloc(1,sizeof(T_FUTURES)); 
	
	pPlacement = (T_PLACEMENT *) calloc(1,sizeof(T_PLACEMENT)); 

	/* Initialisation de la variable bd_RuptPerUw */
	if ( n_InitPerUw( &bd_RuptPerUw ) )
		ExitPgm( ERR_XX , "" );
		

	/* Initialisation de la variable n_InitPLACEMENT2 */

	if ( n_InitPLACEMENT2( &bd_RuptFPLACEMENT ) )
		ExitPgm( ERR_XX , "" );	
			

	/* Initialisation de la variable bd_RuptITDPRM */
	if ( n_InitITDPRM( &bd_RuptITDPRM ) )
		ExitPgm( ERR_XX , "" ); 

	/* Initialisation de la variable bd_RuptUpr */
	if ( n_InitUpr( &bd_RuptUpr ) )
		ExitPgm( ERR_XX , "" );



	/* lancement du traitement du fichier Perimetre de souscription IRDPERICASE.dat */
	if ( n_ProcessingRuptureVar( &bd_RuptPerUw ) == ERR )
		ExitPgm( ERR_XX , "" );
				

	if ( n_CloseFileAppl( "ESTC1066_I1", &( bd_RuptPerUw.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1066_I2", &( bd_RuptITDPRM.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ); 
		
	if ( n_CloseFileAppl( "ESTC1066_I4", &Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" );
		
	if ( n_CloseFileAppl( "ESTC1066_I3", &( bd_RuptFPLACEMENT.pf_InputFil) ) == ERR )
		ExitPgm( ERR_XX , "" );		

	if ( n_CloseFileAppl( "ESTC1066_I5", &Kp_FBOTRSLNK ) == ERR )
		ExitPgm( ERR_XX , "" );						

	if ( n_CloseFileAppl( "ESTC1066_I6", &( bd_RuptUpr.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );	

							
	if ( n_CloseFileAppl( "ESTC1066_O1", &Kp_OutputFilResSii ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1066_O2", &Kp_OutputFilResSiiAno ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESTC1066_O3", &p_OutputFutures ) == ERR )
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
	if ( n_OpenFileAppl( "ESTC1066_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR;

	pbd_Rupt->n_NbRupture = 1;

   pbd_Rupt->n_ConditionRupture[0]=n_TestRupturePER;
   pbd_Rupt->n_ActionFirst[0]=n_ActionFistRupturePER;   
   pbd_Rupt->n_ActionLigne=n_ActionLignePER;   
  

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
	int ret;
	
  DEBUT_FCT("n_TestRupturePER");

	if (strcmp(ptsz_LigneSuiv[PER_CTR_NF], ptsz_LigneCour[PER_CTR_NF])!=0) return(1);
	if ( ( ret = (atoi(ptsz_LigneSuiv[PER_SEC_NF]) - atoi(ptsz_LigneCour[PER_SEC_NF] )) ) != 0 ) return ret;	
  if ( ( ret = (atoi(ptsz_LigneSuiv[PER_UWY_NF]) - atoi(ptsz_LigneCour[PER_UWY_NF]) ) ) != 0 )  return ret;
  	
  if ( ( ret = (atoi(ptsz_LigneSuiv[PER_PLC_NT_PLA]) - atoi(ptsz_LigneCour[PER_PLC_NT_PLA]) ) ) != 0 )  return ret;	
	//[003]if (strcmp(ptsz_LigneSuiv[PER_RTO_NF_PLA], ptsz_LigneCour[PER_RTO_NF_PLA])!=0) return(1);		


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
	
		c_UPR_FLG = 'N';   
    Kd_UPR = 0.0; 
      		 
    c_DAC_FLG = 'N'; 
    Kd_DAC = 0.0;   
     
    c_COME_FLG = 'N';
    Kd_PRME = 0.0 ;
        
    c_PRME_FLG = 'N';
    Kd_COME = 0.0 ;
    
	  Kd_Prmrest = 0.0 ;    // montant des estimations de primes restantes "non acquises "   
    Kd_Commrest = 0.0;    // montant des estimations de commission restantes "non acquises"


    Kd_retro_pricing_LR =0.0 ; 
    Kd_RetNetPrm = 0.0;  
    
    Kd_ITDWrittenPrem = 0.0 ; 

 	  
 	  Ks_LastITD = NULL; //[11]

		kc_TRTNP_BILAN = 'N'; //quand TRTNP et année de souscription supèrieure à date bilan -2
	
		if (atoi(pbd_InRec_Cur[PER_UWY_NF]) > kn_MIN_ICLODAT_A && pbd_InRec_Cur[PER_CTRNAT_CT][0] == 'N')
		kc_TRTNP_BILAN = 'Y';

		/* synchronisation avec le fichier des UPR  */
			n_ProcessingRuptureSyncVar( &bd_RuptUpr, pbd_InRec_Cur );	

		/* synchronisation avec le fichier des Placements n_InitPLACEMENT2 */
			n_ProcessingRuptureSyncVar( &bd_RuptFPLACEMENT, pbd_InRec_Cur ) ;
	
		/* synchronisation avec le fichier GTR_ITDPRM --> Pour les ITDPREMIUM */	
			n_ProcessingRuptureSyncVar( &bd_RuptITDPRM, pbd_InRec_Cur );		

	return OK ;
}  

int n_ActionLignePER(char **pbd_InRec_Cur)
{
	DEBUT_FCT("n_ActionLignePER");

	Kd_retro_pricing_LR = atof(pbd_InRec_Cur[PER_IPLR_R]); // Sauvegarde de la retro Pricing LR

	Kd_RetNetPrm = atof(pbd_InRec_Cur[PER_FLAPROPRM_M]); // Sauvegarde de la Retro Premium Net

#ifdef TRACE_RETNETPRM_PRICING_LF
	printf(" TRACE_RETRO_NET_PREMIUM ET PRICING_LOSS_RATIO : CTR_NF, SECTION, UWY, Kd_RetNetPrm, Kd_retro_pricing_LR : %s ;  %d ;  %d ;  %-.3f ; %-.3f  \n", pbd_InRec_Cur[PER_CTR_NF], atoi(pbd_InRec_Cur[PER_SEC_NF]), atoi(pbd_InRec_Cur[PER_UWY_NF]), Kd_RetNetPrm, Kd_retro_pricing_LR);
#endif
	
	if (Ks_LastITD != NULL) 
		n_ActionLastITDPRM(pbd_InRec_Cur, Ks_LastITD); 

	return OK;
}



/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription »
	avec l’esclave « DTSTATGTXX »

retour :
	OK
==============================================================================*/
int n_InitITDPRM( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitITDPRM" );

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) );


	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC1066_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR;


	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncITDPRM;
	

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneITDPRM;	
	
	/* Fonction Pere Sans Fils */	
	pbd_Rupt->n_PereSansFils=n_ActionPereSansFilsITDPRM; 
	

	pbd_Rupt->c_Separ = '~';

	RETURN_VAL( OK );
}


// function n_ActionPereSansFilsITDPRM 
/**************************************************************************/
/*** Objet : fonction lancee quand aucune ligne du fichier FITDPRM      ***/
/***    ne correspond a la ligne courante du fichier IADPERICASE        ***/
/***                                                                    ***/
/*** Nom : n_ActionPereSansFilsITDPRM                           				***/
/***                                                                    ***/
/*** Parametres:                                                        ***/
/***    i ptsz_LigneMaitre  : pointeur sur la ligne du maitre           ***/
/***                                                                    ***/
/*** Retour:                                                            ***/
/***    OK si pas d'erreur,                                             ***/
/***    ERR si erreur.                                                  ***/
/**************************************************************************/

int n_ActionPereSansFilsITDPRM( char **pbd_InRecOwner )
{
  int i;
  //double d_taux = 1; //d_aliment,
  //char sz_aliment[22];

	char   sz_Dblcod[2];
	char   sz_Amt[21];
	char   sz_Cur[4];
	double d_Amt; 
  char *pbd_InRecChild[GT_NBCOL+1];

  char   sz_Trncod[9];
  //char sz_DETTRNCOD[6];
  
    DEBUT_FCT("n_ActionPereSansFilsITDPRM");
    
    for(i=0;i<GT_NBCOL;i++)
        pbd_InRecChild[i]="" ;

    pbd_InRecChild[GT_NBCOL] = 0 ;

    /* Calcul du taux de conversion (cours: 31/12/exercice precedent)
    d_taux=d_GetTaux( Kp_CoursFil,
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

    sprintf(sz_aliment,"%.3lf",d_aliment); */

    pbd_InRecChild[GT_SSD_CF]= pbd_InRecOwner[PER_SSD_CF];
    pbd_InRecChild[GT_ESB_CF]= pbd_InRecOwner[PER_ACCESB_CF];


    pbd_InRecChild[GT_RETCTR_NF]= pbd_InRecOwner[PER_CTR_NF];
    pbd_InRecChild[GT_RETEND_NT]= pbd_InRecOwner[PER_END_NT];
    pbd_InRecChild[GT_RETSEC_NF]= pbd_InRecOwner[PER_SEC_NF];
    pbd_InRecChild[GT_RTY_NF]= pbd_InRecOwner[PER_UWY_NF];
    pbd_InRecChild[GT_RETUW_NT]=  pbd_InRecOwner[PER_UW_NT];
    pbd_InRecChild[GT_RETACY_NF]= pbd_InRecOwner[PER_UWY_NF];


    pbd_InRecChild[GT_RETCUR_CF]= pbd_InRecOwner[PER_PCPCUR_CF]; 
    pbd_InRecChild[GT_CED_NF]= pbd_InRecOwner[PER_CED_NF];
    pbd_InRecChild[GT_BRK_NF]= pbd_InRecOwner[PER_PRD_NF];
    pbd_InRecChild[GT_RETPAY_NF]= pbd_InRecOwner[PER_GENPRMPAY_NF];
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
    //pbd_InRecChild[GT_SCOEGP_M]=    sz_aliment;
    pbd_InRecChild[GT_ESTCRB_CT]=   pbd_InRecOwner[PER_ESTCRB_CT];
    pbd_InRecChild[GT_LIFTRTTYP_CF]=pbd_InRecOwner[PER_LIFTRTTYP_CF];
    pbd_InRecChild[GT_ACCADMTYP_CT]=pbd_InRecOwner[PER_ACCADMTYP_CT];
    pbd_InRecChild[GT_SECSTS_CT]=   pbd_InRecOwner[PER_SECSTS_CT];
    pbd_InRecChild[GT_PRD_NF]=      pbd_InRecOwner[PER_PRD_NF];
    pbd_InRecChild[GT_SEG_NF]=      pbd_InRecOwner[PER_SEG_NF];
    pbd_InRecChild[GT_COMACC_B]=    "0";
        

/*    if ( atoi( pbd_InRecOwner[PER_SECACCSTS_CT] ) == 9 )
    {
        pbd_InRecChild[GT_ADJCOD_CT] = "9" ;
    }
*/
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
	    
    


	  Kd_retro_pricing_LR =  atof(pbd_InRecOwner[PER_IPLR_R]) ;	// Sauvegarde de la retro Pricing LR 
	 		 
		Kd_RetNetPrm = atof(pbd_InRecOwner[PER_FLAPROPRM_M]); 		// Sauvegarde de la Retro Premium Net 
	
 
	
// Alimentation de la structure de LOG pour FUTURE RETRO
                                                         
		
	strcpy( sz_Dblcod, "" );
 

// 	if (strcmp(pbd_InRecOwner[PER_CTRNAT_CT], "N") != 0 || (atoi(pbd_InRecOwner[PER_EXP_D]) - atoi(Ksz_CloDat) <= 0 ) )

		sprintf( sz_Cur, "%s", pbd_InRecOwner[PER_PCPCUR_CF] );  // Prise en compte du la monnaire du PERICASE RETRO  systematique ; Conversion non effectué
		{
								
				//|012] if ( strcmp(pbd_InRecOwner[PER_CTRNAT_CT], "N")==0 && Kd_RetNetPrm !=0) Condition || (Kd_RetNetPrm ==0) supprimée )
				//[015] Ajout  || (atoi(pbd_InRecOwner[PER_EXP_D]) - atoi(Ksz_CloDat) < 0 )
				//[015] if ( ( (strcmp(pbd_InRecOwner[PER_CTRNAT_CT], "N") !=0 ) || (Kd_RetNetPrm ==0) ) || (atoi(pbd_InRecOwner[PER_EXP_D]) - atoi(Ksz_CloDat) <= 0 ) ||
				//|016]  Condition || (Kd_RetNetPrm ==0) Reintegrée )

 				if ( ( strcmp(pbd_InRecOwner[PER_CTRNAT_CT], "N") !=0   )      ||
 					   (atoi(pbd_InRecOwner[PER_EXP_D]) - atoi(Ksz_CloDat) <= 0 )  ||
 					   ( Kd_RetNetPrm ==0 )           ||
						 ( ( strcmp(Ksz_NORME, "I17G") ==0 || 
                              strcmp(Ksz_NORME, "I17S") == 0 ||   //[017]
							   strcmp(Ksz_NORME, "I17P") == 0 || 
							   strcmp(Ksz_NORME, "I17L") == 0  ) &&  (fabs(Kd_RetNetPrm) <= 1) 
						 )
					 )
			
					d_Amt = 0;	
					
				else					
				{ 
					d_Amt = (-1)*Kd_RetNetPrm * atof(pbd_InRecOwner[PER_RETSIGSHA_R])  ;   // d_Amt = (-1) * ( (Kd_RetNetPrm * atof(pbd_InRecOwner[PER_RETSIGSHA_R])) + Kd_ITDWrittenPrem) ;	
						
#ifdef TRACE_FUTURE_RETRO_PREMIUM							
			printf(" n_ActionPereSansFilsITDPRM DEB CALCUL  : GT_RETCTR_NF, GT_RETSEC_NF, pbd_InRecChild[GT_RTY_NF], PER_CTR_NF, GT_TRNCOD_CF, GT_RETAMT_M, Kd_RetNetPrm, Kd_UPR, kd_RETSIGSHA_R, PLC : %s ; %s ; %s ; %s; %s ; %-.3f ; %-.3f ;  %-.3f; %-.3f; %d \n", pbd_InRecChild[GT_RETCTR_NF], pbd_InRecChild[GT_RETSEC_NF], pbd_InRecChild[GT_RTY_NF], pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_TRNCOD_CF], d_Amt,  Kd_RetNetPrm, Kd_UPR, atof(pbd_InRecOwner[PER_RETSIGSHA_R]), atoi(pbd_InRecOwner[PER_PLC_NT_PLA]) );			
#endif						
		
				}													
					
				
				sprintf( sz_Amt, "%-.3f", d_Amt );
				strcpy( sz_Trncod, "2A100012" );
			  pFutures->TRNCOD = sz_Trncod;					
				
				Kd_RetPrmAmt = d_Amt;  
				pFutures->FURETPREMIUM = d_Amt;   		// Retro Future Fixe Premium

				//pbd_InRecChild[GT_RETAMT_M] = "0";
				//pbd_InRecChild[GT_RETINTAMT_M] = "0";
				pbd_InRecChild[GT_TRNCOD_CF] = sz_Trncod;
				pbd_InRecChild[GT_DBLTRNCOD_CF] = sz_Dblcod;
				pbd_InRecChild[GT_AMT_M] = " ";
				pbd_InRecChild[GT_RETAMT_M] = sz_Amt;
				pbd_InRecChild[GT_RETCUR_CF] = sz_Cur;
											
				pbd_InRecChild[GT_RTO_NF] = pbd_InRecOwner[PER_RTO_NF_PLA] ; // Ksz_RTO_NF;		
				pbd_InRecChild[GT_PLC_NT] = pbd_InRecOwner[PER_PLC_NT_PLA] ; //Ksz_PLC_NT;   
																											 					
#ifdef TRACE_FUTURE_RETRO_PREMIUM							
			if (strcmp(pbd_InRecOwner[PER_CTR_NF], "02N000499")==0 &&  atoi(pbd_InRecOwner[UWY_NF])==2020 && atoi(pbd_InRecOwner[SEC_NF])==1 )
			{ 
				printf(" n_ActionPereSansFilsITDPRM INTER CALCUL  : GT_RETCTR_NF, GT_RETSEC_NF, pbd_InRecChild[GT_RTY_NF], PER_CTR_NF, GT_TRNCOD_CF, GT_RETAMT_M, Kd_RetNetPrm, Kd_UPR, kd_RETSIGSHA_R, PLC, Kd_RetPrmAmt, Kd_UPR , Kd_retro_pricing_LR : %s ; %s ; %s ; %s; %s ; %-.3f ; %-.3f ;  %-.3f; %-.3f; %d ; %f ; %f : %f\n", pbd_InRecChild[GT_RETCTR_NF], pbd_InRecChild[GT_RETSEC_NF], pbd_InRecChild[GT_RTY_NF], pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_TRNCOD_CF], atof(pbd_InRecChild[GT_RETAMT_M]),  Kd_RetNetPrm, Kd_UPR, atof(pbd_InRecOwner[PER_RETSIGSHA_R]), atoi(pbd_InRecOwner[PER_PLC_NT_PLA]), Kd_RetPrmAmt, Kd_UPR, Kd_retro_pricing_LR );		
				printf(" Kd_RetPrmAmt = %f ; Kd_UPR = %f; Kd_retro_pricing_LR = %f ;  VERIF %f \n", Kd_RetPrmAmt, Kd_UPR, Kd_retro_pricing_LR, (Kd_RetPrmAmt - Kd_UPR ) * Kd_retro_pricing_LR * (-1) *100  );
			}
#endif	
				
				//n_EcrireLog(); 					

				if ( fabs(atof(sz_Amt)) > 1 )
				{

#ifdef TRACE_FUTURE_RETRO_PREMIUM		 						
			printf(" n_ActionPereSansFilsITDPRM RESULTAT CALCUL  : GT_RETCTR_NF, GT_RETSEC_NF, pbd_InRecChild[GT_RTY_NF], PER_CTR_NF, GT_TRNCOD_CF, GT_RETAMT_M, Kd_RetNetPrm, Kd_UPR, kd_RETSIGSHA_R, PLC  : %s ; %s ; %s ; %s; %s ; %-.3f ; %-.3f ;  %-.3f; %-.3f; %d \n", pbd_InRecChild[GT_RETCTR_NF], pbd_InRecChild[GT_RETSEC_NF], pbd_InRecChild[GT_RTY_NF], pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_TRNCOD_CF], atof(pbd_InRecChild[GT_RETAMT_M]),  Kd_RetNetPrm, Kd_UPR, atof(pbd_InRecOwner[PER_RETSIGSHA_R]), atoi(pbd_InRecOwner[PER_PLC_NT_PLA]) );		
#endif
					n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );
				}
				else
					Kd_RetPrmAmt = 0 ; //[015]

				/**********************************************************
    									FUTURE CLAIMS 
				***********************************************************/

				if (strcmp(pbd_InRecOwner[PER_CTRNAT_CT], "N")==0 || (Kd_retro_pricing_LR != 0 ))
					d_Amt = (Kd_RetPrmAmt - Kd_UPR ) * Kd_retro_pricing_LR * (-1) *100; 		//[07]d_Amt = (Kd_RetPrmAmt - Kd_UPR ) * Kd_retro_pricing_LR * (-1) ; 			
				else 
					d_Amt = 0.0 ;
					
#ifdef TRACE_FUTURE_RETRO_CLAIMS	
	if (strcmp(pbd_InRecOwner[PER_CTR_NF], "02N000499")==0 &&  atoi(pbd_InRecOwner[UWY_NF])==2020 && atoi(pbd_InRecOwner[SEC_NF])==1 )
	printf(" n_ActionPereSansFilsITDPRM : CTR_NF=%s ; Kd_retro_pricing_LR=%f ; Kd_UPR =%f ; Kd_RetPrmAmt=%f ;  FUTURE_CLAIM_PRG=%f\n", pbd_InRecOwner[PER_CTR_NF], Kd_retro_pricing_LR, Kd_UPR, Kd_RetPrmAmt, (Kd_RetPrmAmt - Kd_UPR ) * Kd_retro_pricing_LR * (-1)*100 )	;				
#endif						
					
										
				sprintf( sz_Amt, "%-.3f", d_Amt );  
				strcpy( sz_Trncod, "2A494302" );
			  pFutures->TRNCOD = sz_Trncod;						

				pbd_InRecChild[GT_TRNCOD_CF] = sz_Trncod;
				pbd_InRecChild[GT_RETAMT_M] = sz_Amt;		
				
								
#ifdef TRACE_FUTURE_RETRO_CLAIMS							
			printf(" n_ActionPereSansFilsITDPRM INTER CALCUL  : GT_RETCTR_NF, GT_RETSEC_NF, pbd_InRecChild[GT_RTY_NF], PER_CTR_NF, GT_TRNCOD_CF, GT_RETAMT_M, Kd_RetNetPrm, Kd_UPR : %s ; %s ; %s ; %s; %s ; %-.3f ; %-.3f ;  %-.3f \n", pbd_InRecChild[GT_RETCTR_NF], pbd_InRecChild[GT_RETSEC_NF], pbd_InRecChild[GT_RTY_NF], pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_TRNCOD_CF], atof(pbd_InRecChild[GT_RETAMT_M]),  Kd_RetNetPrm, Kd_UPR );			
#endif					

				if ( fabs(atof(sz_Amt)) > 1 )
				{							

#ifdef TRACE_FUTURE_RETRO_CLAIMS		 						
			printf(" n_ActionPereSansFilsITDPRM RESULTAT CALCUL : GT_RETCTR_NF, GT_RETSEC_NF, pbd_InRecChild[GT_RTY_NF], PER_CTR_NF, GT_TRNCOD_CF,  GT_RETAMT_M,  Kd_RetNetPrm, Kd_UPR : %s ; %s ; %s ; %s ; %s ; %-.3f ; %-.3f ; %-.3f\n", pbd_InRecChild[GT_RETCTR_NF], pbd_InRecChild[GT_RETSEC_NF], pbd_InRecChild[GT_RTY_NF], pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_TRNCOD_CF], atof(pbd_InRecChild[GT_RETAMT_M]),  Kd_RetNetPrm, Kd_UPR);			
#endif
	 					
					n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );
				}				

			// [04] DEBUT Remaining Estimates 

/*****************************************************************************************************
*** [04]                  min amount between "Premium    Estimates" and UPR --> 2A100112
***                       ANNULATION  Commission Remaining Estimate         --> 2A100122   
*****************************************************************************************************/ 

		if ( (c_PRME_FLG == 'Y' || c_UPR_FLG == 'Y')
	        &&
	        ( fabs(Kd_UPR) > 0.0 ||  fabs(Kd_PRME) > 0.0 )		
			 )
		{
			
			// select the min amount between "Premium Estimates" and UPR
			// and post positive amount on 2A100112
			
			if ( Kd_PRME  > ( -1 * Kd_UPR ) ) 
				Kd_Prmrest = -1 * Kd_UPR ;
			else
				Kd_Prmrest = Kd_PRME    ; 
				
			//Kd_Prmrest = min(max(0.0, Kd_PRME),max(0.0, -1 * Kd_UPR)); // [09] 					

			
#ifdef TRACE_REMAINING_PRM	
			printf("\nNEW req 10.1 PRM key %s %s sec %s %s %s: Kd_PRME:%f newUPR:%f:  Kd_Prmrest:%f  \n", 
        			pbd_InRecOwner[PER_CTR_NF],pbd_InRecOwner[PER_END_NT],pbd_InRecOwner[PER_SEC_NF] ,pbd_InRecOwner[PER_UWY_NF] ,pbd_InRecOwner[PER_UW_NT] ,
			        Kd_PRME , Kd_UPR ,   Kd_Prmrest  );
#endif					

				
				sprintf( sz_Amt, "%-.3f", Kd_Prmrest );
				strcpy( sz_Trncod, "2A100112" );
			  pFutures->TRNCOD = sz_Trncod;						
					

				pbd_InRecChild[GT_TRNCOD_CF] = sz_Trncod;
				pbd_InRecChild[GT_RETAMT_M] = sz_Amt;		
				
				n_EcrireLog(); 				

				if ( fabs(atof(sz_Amt)) > 1)
				{ 
					
#ifdef TRACE_REMAINING_PRM
			printf("FINAL n_ActionPereSansFilsITDPRM TRACE_REMAINING_PRM:  GT_RETCTR_NF, GT_RETSEC_NF, pbd_InRecChild[GT_RTY_NF], PER_CTR_NF, GT_TRNCOD_CF, Kd_RetPrmAmt, EGPI_SCOR, Kd_Prmrest, kd_RETSIGSHA_R, kTOT_RETSIGSHA_R, Kd_ITDWrittenPrem, d_taux, Kd_UPR, Kd_retro_pricing_LR: %s ; %s ;%s ; %s ; %s ; %-.3f ; %-.3f ; %-.3f ; %-.3f ; %-.3f ; %-.3f ; %-.3f; %-.3f ; %-.3f\n", pbd_InRecChild[GT_RETCTR_NF], pbd_InRecChild[GT_RETSEC_NF], pbd_InRecChild[GT_RTY_NF], pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_TRNCOD_CF], Kd_RetPrmAmt, atof(pbd_InRecOwner[PER_SCOEGP_M]), Kd_Prmrest,  atof(pbd_InRecOwner[PER_RETSIGSHA_R]), kTOT_RETSIGSHA_R, Kd_ITDWrittenPrem, d_taux, Kd_UPR, Kd_retro_pricing_LR);												
#endif					
					n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );
					
					
				}
				
		   // Annulation REMAINING PREMIUM ESTIMATE 2A100122
				d_Amt = Kd_Prmrest*(-1) ; 
				sprintf( sz_Amt, "%-.3f", d_Amt );
				strcpy( sz_Trncod, "2A100122" );
			  pFutures->TRNCOD = sz_Trncod;						
					

				pbd_InRecChild[GT_TRNCOD_CF] = sz_Trncod;
				pbd_InRecChild[GT_RETAMT_M] = sz_Amt;		
				
				n_EcrireLog(); 				

				if ( fabs(atof(sz_Amt)) > 1)
				{ 
					
#ifdef TRACE_REMAINING_PRM_ANN
			printf("FINAL n_ActionPereSansFilsITDPRM TRACE_REMAINING_PRM_ANN :  GT_RETCTR_NF, GT_RETSEC_NF, pbd_InRecChild[GT_RTY_NF], PER_CTR_NF, GT_TRNCOD_CF,  Kd_RetPrmAmt, EGPI_SCOR, Kd_Prmrest, kd_RETSIGSHA_R, kTOT_RETSIGSHA_R, Kd_ITDWrittenPrem, d_taux, Kd_UPR, Kd_retro_pricing_LR: %s ; %s ;%s ; %s ; %s ; %-.3f ; %-.3f ; %-.3f ; %-.3f ; %-.3f ; %-.3f ; %-.3f; %-.3f ; %-.3f\n", pbd_InRecChild[GT_RETCTR_NF], pbd_InRecChild[GT_RETSEC_NF], pbd_InRecChild[GT_RTY_NF], pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_TRNCOD_CF], Kd_RetPrmAmt, atof(pbd_InRecOwner[PER_SCOEGP_M]), Kd_Prmrest*(-1),  atof(pbd_InRecOwner[PER_RETSIGSHA_R]), kTOT_RETSIGSHA_R, Kd_ITDWrittenPrem, d_taux, Kd_UPR, Kd_retro_pricing_LR);												
#endif					
					n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );					
					
				}

 		}

/*****************************************************************************************************
*** [04]                 min amount between "Commission Estimates" and DAC --> 2A120112
***                      ANNULATION  Commission Remaining Estimate         --> 2A120122   
*****************************************************************************************************/                             

		if ( (c_COME_FLG == 'Y' || c_DAC_FLG == 'Y')
	        &&
	        ( fabs(Kd_DAC) > 0.0 ||  fabs(Kd_COME) > 0.0 )		
			 )
		{
			
			
			
			// select the min amount between "Commission Estimates" and DAC, 
			// and post negative amount on 2A120112
			
			if ( -1 * Kd_COME  > Kd_DAC  )
				Kd_Commrest = -1 * Kd_DAC  ;
			else
				Kd_Commrest = -1 * (-1 * Kd_COME  )  ; 
				
		//Kd_Commrest = (-1) * min(max(0.0, -1 * Kd_COME), max( 0.0, Kd_DAC)); // [09]	

#ifdef TRACE_REMAINING_COMM	
			printf("\nNEW req 10.1  n_ActionPereSansFilsITDPRM COMM key %s %s sec %s %s %s: Kd_COME %f DAC:%f: use:%f: \n", 
        			pbd_InRecOwner[PER_CTR_NF],pbd_InRecOwner[PER_END_NT],pbd_InRecOwner[PER_SEC_NF] ,pbd_InRecOwner[PER_UWY_NF] ,pbd_InRecOwner[PER_UW_NT] ,
			        Kd_COME, Kd_DAC ,Kd_Commrest );
#endif


				sprintf( sz_Amt, "%-.3f", Kd_Commrest );
				strcpy( sz_Trncod, "2A120112" );
			  pFutures->TRNCOD = sz_Trncod;						
					

				pbd_InRecChild[GT_TRNCOD_CF] = sz_Trncod;
				pbd_InRecChild[GT_RETAMT_M] = sz_Amt;		
				
				n_EcrireLog(); 				

				if ( fabs(atof(sz_Amt)) > 1)
				{ 
					
#ifdef TRACE_REMAINING_COMM
			printf("FINAL n_ActionPereSansFilsITDPRM TRACE_REMAINING_COMM:  GT_RETCTR_NF, GT_RETSEC_NF, pbd_InRecChild[GT_RTY_NF], PER_CTR_NF, GT_TRNCOD_CF, Kd_RetPrmAmt, EGPI_SCOR, Kd_Commrest, kd_RETSIGSHA_R, kTOT_RETSIGSHA_R, Kd_ITDWrittenPrem, d_taux, Kd_UPR, Kd_retro_pricing_LR: %s ; %s ;%s ; %s ; %s ; %-.3f ; %-.3f ; %-.3f ; %-.3f ; %-.3f ; %-.3f ; %-.3f; %-.3f ; %-.3f\n", pbd_InRecChild[GT_RETCTR_NF], pbd_InRecChild[GT_RETSEC_NF], pbd_InRecChild[GT_RTY_NF], pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_TRNCOD_CF], Kd_RetPrmAmt, atof(pbd_InRecOwner[PER_SCOEGP_M]), Kd_Commrest,  atof(pbd_InRecOwner[PER_RETSIGSHA_R]), kTOT_RETSIGSHA_R, Kd_ITDWrittenPrem, d_taux, Kd_UPR, Kd_retro_pricing_LR);												
#endif					
					n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );
										
				}
				
		   // Annulation n_ActionPereSansFilsITDPRM REMAINING COMMISSION ESTIMATE 2A120122
				d_Amt = Kd_Commrest *(-1) ; 
				sprintf( sz_Amt, "%-.3f", d_Amt );
				strcpy( sz_Trncod, "2A120122" );
			  pFutures->TRNCOD = sz_Trncod;						
					

				pbd_InRecChild[GT_TRNCOD_CF] = sz_Trncod;
				pbd_InRecChild[GT_RETAMT_M] = sz_Amt;		
				
				n_EcrireLog(); 				

				if ( fabs(atof(sz_Amt)) > 1)
				{ 
					
#ifdef TRACE_REMAINING_COMM_ANN
			printf("FINAL n_ActionPereSansFilsITDPRM TRACE_REMAINING_COMM_ANN:  GT_RETCTR_NF, GT_RETSEC_NF, pbd_InRecChild[GT_RTY_NF], PER_CTR_NF, GT_TRNCOD_CF, Kd_RetPrmAmt, EGPI_SCOR, Kd_Commrest, kd_RETSIGSHA_R, kTOT_RETSIGSHA_R, Kd_ITDWrittenPrem, d_taux, Kd_UPR, Kd_retro_pricing_LR: %s ; %s ;%s ; %s ; %s ; %-.3f ; %-.3f ; %-.3f ; %-.3f ; %-.3f ; %-.3f ; %-.3f; %-.3f ; %-.3f\n", pbd_InRecChild[GT_RETCTR_NF], pbd_InRecChild[GT_RETSEC_NF], pbd_InRecChild[GT_RTY_NF], pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_TRNCOD_CF], Kd_RetPrmAmt, atof(pbd_InRecOwner[PER_SCOEGP_M]), Kd_Commrest,  atof(pbd_InRecOwner[PER_RETSIGSHA_R]), kTOT_RETSIGSHA_R, Kd_ITDWrittenPrem, d_taux, Kd_UPR, Kd_retro_pricing_LR);												
#endif					
					n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );					
					
				}	
					
		}
			// [ 04] n_ActionPereSansFilsITDPRM FIN Remaining Estimates

							
				
		}

	       Kd_RetPrmAmt = 0;      
	       Kd_ITDWrittenPrem = 0;
	       
	        

  RETURN_VAL(OK);
}    

/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription »
	avec l’esclave « UPR »

retour :
	OK
==============================================================================*/
int n_InitUpr( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitUpr" );

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) );


	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC1066_I6", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR;


	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncUpr;
	

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneUpr;
	
	
	pbd_Rupt->n_PereSansFils=n_ActionPereSansFilsUpr;

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
int n_ConditionSyncUpr(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret;

	DEBUT_FCT( "n_ConditionSyncUpr" );
	

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_RETCTR_NF] ) ) != 0 ) return ret; 
	if ( ( ret = (atoi(pbd_InRecOwner[PER_SEC_NF]) - atoi(pbd_InRecChild[GT_RETSEC_NF] )) ) != 0 ) return ret;	
  if ( ( ret = (atoi(pbd_InRecOwner[PER_UWY_NF]) - atoi(pbd_InRecChild[GT_RTY_NF]) ) ) != 0 )  return ret;
  	
  if ( ( ret = (atoi(pbd_InRecOwner[PER_PLC_NT_PLA]) - atoi(pbd_InRecChild[GT_PLC_NT]) ) ) != 0 )  return ret;
	

	RETURN_VAL( 0 );
}



//  function n_ActionPereSansFilsUpr
/**************************************************************************/
/*** Objet : fonction lancee quand aucune ligne du fichier UPR     ***/
/***         ne correspond a la ligne courante du fichier maitre        ***/
/***                                                                    ***/
/*** Nom : n_ActionPereSansFilsUpr                           ***/
/***                                                                    ***/
/*** Parametres:                                                        ***/
/***    i ptsz_LigneMaitre  : pointeur sur la ligne du maitre           ***/
/***                                                                    ***/
/*** Retour:                                                            ***/
/***    OK si pas d'erreur,                                             ***/
/***    ERR si erreur.                                                  ***/
/**************************************************************************/

int n_ActionPereSansFilsUpr(char *ptsz_LigneMaitre[])
{
  DEBUT_FCT("n_ActionPereSansFilsUpr");
  
  c_NETP_FLG = 'N';  
  c_UPR_FLG = 'N';       
  c_DAC_FLG = 'N';       
  c_PRME_FLG = 'N';       
  c_COME_FLG = 'N';
  
  Kd_UPR = 0.0;
  Kd_DAC = 0.0;
  Kd_PRME = 0.0;
  Kd_COME = 0.0;

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
int n_ConditionSyncITDPRM(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret;

	DEBUT_FCT( "n_ConditionSyncITDPRM" );
	

#ifdef TRACE_ConditionSyncITDPRM
	  printf(" AVANT SYNC DANS n_ConditionSyncITDPRM : CTR_NF %s ; UWY = %d ; SEC %s ; PER_PLC_NT_PLA = [%d]  ; PER_RTO_NF_PLA =[%s] ; \n RETCTR_NF=%s ; RETSEC[%s] ; RTY[%d] ; GT_PLC_NT = [%d]  ; GT_RTO_NF[%s] \n", pbd_InRecOwner[PER_CTR_NF], atoi(pbd_InRecOwner[PER_UWY_NF]), pbd_InRecOwner[PER_SEC_NF], atoi(pbd_InRecOwner[PER_PLC_NT_PLA]), pbd_InRecOwner[PER_RTO_NF_PLA], pbd_InRecChild[GT_RETCTR_NF], pbd_InRecChild[GT_RETSEC_NF], atoi(pbd_InRecChild[GT_RTY_NF]), atoi(pbd_InRecChild[GT_PLC_NT]), pbd_InRecChild[GT_RTO_NF] );
#endif
	 
                                                                  
	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_RETCTR_NF] ) ) != 0 ) return ret;	
	if ( ( ret = (atoi(pbd_InRecOwner[PER_SEC_NF]) - atoi(pbd_InRecChild[GT_RETSEC_NF] )) ) != 0 ) return ret;	
  if ( ( ret = (atoi(pbd_InRecOwner[PER_UWY_NF]) - atoi(pbd_InRecChild[GT_RTY_NF]) ) ) != 0 )  return ret;			

  if ( ( ret = (atoi(pbd_InRecOwner[PER_PLC_NT_PLA]) - atoi(pbd_InRecChild[GT_PLC_NT]) ) ) != 0 )  return ret;			  		
//[003]	if ( ( ret = strcmp( pbd_InRecOwner[PER_RTO_NF_PLA], pbd_InRecChild[GT_RTO_NF] ) ) != 0 ) return ret;

#ifdef TRACE_ConditionSyncITDPRM	
	  printf(" APRES SYNC DANS n_ConditionSyncITDPRM : CTR_NF %s ; UWY = %d ; SEC %s ; PER_PLC_NT_PLA = [%d]  ; PER_RTO_NF_PLA =[%s] ; \n RETCTR_NF=%s ; RETSEC[%s] ; RTY[%d] ; GT_PLC_NT = [%d]  ; GT_RTO_NF[%s] \n", pbd_InRecOwner[PER_CTR_NF], atoi(pbd_InRecOwner[PER_UWY_NF]), pbd_InRecOwner[PER_SEC_NF], atoi(pbd_InRecOwner[PER_PLC_NT_PLA]), pbd_InRecOwner[PER_RTO_NF_PLA], pbd_InRecChild[GT_RETCTR_NF], pbd_InRecChild[GT_RETSEC_NF], atoi(pbd_InRecChild[GT_RTY_NF]), atoi(pbd_InRecChild[GT_PLC_NT]), pbd_InRecChild[GT_RTO_NF] );
#endif


	RETURN_VAL( 0 );
}

/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneITDPRM(
		char **pbd_InRecOwner, /* adresse de la ligne du maitre */
		char **pbd_InRecChild) /* adresse de la ligne de l'esclave */
{

	char sz_Dblcod[2];
	//char sz_Amt[21];
	char sz_Cur[4];	
	double d_taux; // Taux de conversion en devise
	char MsgAno[300];

	int n_rech_itd = 0;

	Ks_LastITD = pbd_InRecChild;

	//double kTOT_RETSIGSHA_R ;

	DEBUT_FCT("n_ActionLigneITDPRM");

	memset(sz_Cur, 0, sizeof(sz_Cur));

	memset(pFutures, 0, sizeof(T_FUTURES)); // on remet la structure a vide

	Kd_retro_pricing_LR = atof(pbd_InRecOwner[PER_IPLR_R]); // Sauvegarde de la retro Pricing LR

	Kd_RetNetPrm = atof(pbd_InRecOwner[PER_FLAPROPRM_M]); // Sauvegarde de la Retro Premium Net



	n_rech_itd = n_rech_trncd_itd(pbd_InRecChild[GT_TRNCOD_CF]);


	strcpy(sz_Dblcod, "");

	/* Recherche taux pour conversion du montant Retro en devise aliment */
	d_taux = 1;


	//[02]if ( strcmp( pbd_InRecChild[GT_CUR_CF], pbd_InRecOwner[PER_EGPCUR_CF] ) != 0 )
	sprintf(sz_Cur, "%s", pbd_InRecOwner[PER_PCPCUR_CF]); // [06] force PER_PCPCUR_CF au lieu PER_EGPCUR_CF
	

	if (strcmp(pbd_InRecChild[GT_RETCUR_CF], pbd_InRecOwner[PER_PCPCUR_CF]) != 0)
	{
		//[02]sprintf( sz_Cur, "%s", pbd_InRecOwner[PER_EGPCUR_CF] );
		//[02]d_taux = d_GetTaux( Kp_InputFilExc, (char) atoi( pbd_InRecChild[GT_SSD_CF] ), atoi( pbd_InRecChild[GT_BALSHEY_NF] ), pbd_InRecChild[GT_CUR_CF], pbd_InRecOwner[PER_EGPCUR_CF] );

		//sprintf( sz_Cur, "%s", pbd_InRecOwner[PER_PCPCUR_CF] );   // [06] déactiver cette ligne, remplacer PER_EGPCUR_CF par PER_PCPCUR_CF et GT_CUR_CF par  GT_RETCUR_CF dans la fontion d_GetTaux


  if (strcmp("02N000499", pbd_InRecOwner[PER_CTR_NF]) == 0 && atoi(pbd_InRecOwner[PER_UWY_NF]) == 2020)
  	printf(" 03 SSD=%d ; balshey = %d ; GT_RETCUR_CF %s , PER_PCPCUR_CF %s; RETCTR_NF=%s; ITD=%f; %s ; taux converti = %f\n", atoi(pbd_InRecChild[GT_SSD_CF]), atoi(pbd_InRecChild[GT_BALSHEY_NF]), pbd_InRecChild[GT_RETCUR_CF], pbd_InRecOwner[PER_PCPCUR_CF], pbd_InRecOwner[PER_CTR_NF], atof(pbd_InRecChild[GT_RETAMT_M]), pbd_InRecChild[GT_RETCUR_CF], d_taux) ;


		d_taux = d_GetTaux(Kp_InputFilExc, (char)atoi(pbd_InRecChild[GT_SSD_CF]), atoi(pbd_InRecChild[GT_BALSHEY_NF]), pbd_InRecChild[GT_RETCUR_CF], pbd_InRecOwner[PER_PCPCUR_CF]);
		
  if (strcmp("02N000499", pbd_InRecOwner[PER_CTR_NF]) == 0 && atoi(pbd_InRecOwner[PER_UWY_NF]) == 2020)
  	printf(" 04 SSD=%d ; balshey = %d ; GT_RETCUR_CF %s , PER_PCPCUR_CF %s; RETCTR_NF=%s; ITD=%f; %s ; taux converti = %f\n", atoi(pbd_InRecChild[GT_SSD_CF]), atoi(pbd_InRecChild[GT_BALSHEY_NF]), pbd_InRecChild[GT_RETCUR_CF], pbd_InRecOwner[PER_PCPCUR_CF], pbd_InRecOwner[PER_CTR_NF], atof(pbd_InRecChild[GT_RETAMT_M]), pbd_InRecChild[GT_RETCUR_CF], d_taux) ;

		
		
	}

	/* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
	if (d_taux < 0)
	{
		sprintf(MsgAno, "The rates of acceptation currency ( %s ) and EGPI currency ( %s ) aren't known for the perimeter contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) and BALSHEY %s \n", pbd_InRecChild[GT_RETCUR_CF], sz_Cur, pbd_InRecChild[GT_RETCTR_NF], pbd_InRecChild[GT_RETEND_NT], pbd_InRecChild[GT_RETSEC_NF], pbd_InRecChild[GT_RTY_NF], pbd_InRecChild[GT_UW_NT], pbd_InRecChild[GT_BALSHEY_NF]);
		n_WriteAno(MsgAno);
		/* montant positionne a zero */
		// d_Amt = 0; //descative , aggregation
		
		if (strcmp("02N000499", pbd_InRecOwner[PER_CTR_NF]) == 0 && atoi(pbd_InRecOwner[PER_UWY_NF]) == 2020)	
			printf("The rates of acceptation currency ( %s ) and EGPI currency ( %s ) aren't known for the perimeter contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) and BALSHEY %s \n", pbd_InRecChild[GT_RETCUR_CF], sz_Cur, pbd_InRecChild[GT_RETCTR_NF], pbd_InRecChild[GT_RETEND_NT], pbd_InRecChild[GT_RETSEC_NF], pbd_InRecChild[GT_RTY_NF], pbd_InRecChild[GT_UW_NT], pbd_InRecChild[GT_BALSHEY_NF]);
		
	}
	else //[02] Reactivation du taux de conversion

	//[02]sprintf( sz_Cur, "%s", pbd_InRecOwner[PER_PCPCUR_CF] );  // Prise en compte du la monnaire du PERICASE RETRO  systematique ; Conversion non effectué
	{
		pFutures->TAUX = d_taux;
		pFutures->RETCUR_CF = sz_Cur;

		if (n_rech_itd == ITD)
			// changer vers cumul
			Kd_ITDWrittenPrem += atof(pbd_InRecChild[GT_RETAMT_M]) * d_taux; //[01]  Montant de l'ITD PREMIUM			

		// Calcul Retro future prime
		// R02-01 : Retro Future Premium (2A100012) =  (-1)*([Retro Net Premium] * [Placement share] + [ITD written Premium])

		//Le montant d'estimaion de la Future Premium est 0 lorque CTRNAT est different de "N" .
	}
	
	RETURN_VAL(OK);
}
			

//function n_ActionLigneUpr
/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneUpr(
	char **pbd_InRecOwner , /* adresse de la ligne du maitre */
	char **pbd_InRecChild ) /* adresse de la ligne de l'esclave */
{
 
	char   MsgAno[300];
	char   sz_Cur[4];
	//double d_Amt;
	double d_taux;  
	
	c_UPR_FLG = 'N';	   
	
	n_type_trn_cd = n_check_trncd_cf(pbd_InRecChild[GT_TRNCOD_CF]); 
	
// [033] Mise à jour Taux DAC, UPR si monnaie EGPI differe ligne DAC, UPR, PRME, COME

		/* Recherche taux pour conversion du montant acceptation en devise aliment */
	d_taux = 1;

	//sprintf(sz_Cur, "%s", pbd_InRecOwner[PER_EGPCUR_CF]);
	sprintf(sz_Cur, "%s", pbd_InRecOwner[PER_PCPCUR_CF]);

	if (strcmp(pbd_InRecChild[GT_RETCUR_CF], pbd_InRecOwner[PER_PCPCUR_CF]) != 0)
	{

		// [06] remplacer PER_EGPCUR_CF par PER_PCPCUR_CF et GT_CUR_CF par  GT_RETCUR_CF dans la fontion d_GetTaux
		d_taux = d_GetTaux(Kp_InputFilExc, (char)atoi(pbd_InRecChild[GT_SSD_CF]), atoi(pbd_InRecChild[GT_BALSHEY_NF]), pbd_InRecChild[GT_RETCUR_CF], pbd_InRecOwner[PER_PCPCUR_CF]);
	}
	

	/* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
	if (d_taux < 0)
	{
		sprintf(MsgAno, "The rates of acceptation currency ( %s ) and EGPI currency ( %s ) aren't known for the perimeter contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) and BALSHEY %s \n", pbd_InRecChild[GT_RETCUR_CF], pbd_InRecOwner[PER_PCPCUR_CF], pbd_InRecChild[GT_CTR_NF], pbd_InRecChild[GT_END_NT], pbd_InRecChild[GT_SEC_NF], pbd_InRecChild[GT_UWY_NF], pbd_InRecChild[GT_UW_NT], pbd_InRecChild[GT_BALSHEY_NF]);
		n_WriteAno(MsgAno);
		/* montant positionne a zero */
		Kd_UPR = 0;
		Kd_DAC = 0;
		Kd_PRME = 0;
		Kd_COME = 0;
	}
		else
		{ 	

			           
#ifdef TRACE_UPR	
		if (strcmp("RN0001168", pbd_InRecOwner[PER_CTR_NF]) == 0 && atoi(pbd_InRecOwner[PER_UWY_NF]) == 2020)		
		printf(" AVANT SYNC DANS n_ConditionSyncUpr : pbd_InRecChild[GT_TRNCOD_CF], n_type_trn_cd, RETCTR, RETSEC, RTY, PLC_NT, RTO_NF, lig_upr, Kd_UPR: %s; %d; %s; %s; %s; %d ;%d ; %-3.f ; %-3.f\n", pbd_InRecChild[GT_TRNCOD_CF], n_type_trn_cd, pbd_InRecChild[GT_RETCTR_NF], pbd_InRecChild[GT_RETSEC_NF], pbd_InRecChild[GT_RTY_NF], atoi(pbd_InRecChild[GT_PLC_NT]), atoi(pbd_InRecChild[GT_RTO_NF]), atof(pbd_InRecChild[GT_RETAMT_M]), Kd_UPR );
#endif

			if ( 
						( atoi(pbd_InRecOwner[PER_PLC_NT_PLA]) - atoi(pbd_InRecChild[GT_PLC_NT] ) == 0 )  && 	
  	  			(strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_RETCTR_NF] ) == 0 ) &&
      			(atoi(pbd_InRecOwner[PER_SEC_NF]) - atoi(pbd_InRecChild[GT_RETSEC_NF])  == 0) &&	
      			(atoi(pbd_InRecOwner[PER_UWY_NF]) - atoi(pbd_InRecChild[GT_RTY_NF]) == 0 ) 	
      	)	
			{ 
					if ( n_type_trn_cd == UPR )  		
					{						
							Kd_UPR += atof(pbd_InRecChild[GT_RETAMT_M])*d_taux ;		//[014]	Kd_UPR += atof(pbd_InRecChild[GT_RETAMT_M])								
					}								

		
					if (n_type_trn_cd == DAC ) 			
					{
							c_DAC_FLG = 'Y';
							Kd_DAC += atof(pbd_InRecChild[GT_RETAMT_M])*d_taux ;	
					}
		   
					if ( n_type_trn_cd == PRME ) 		
					{
							c_PRME_FLG = 'Y';
							Kd_PRME += atof(pbd_InRecChild[GT_RETAMT_M])*d_taux ;	
					}	

					if ( n_type_trn_cd == COME )	
					{
							c_COME_FLG = 'Y';
							Kd_COME += atof(pbd_InRecChild[GT_RETAMT_M])*d_taux ;	
					}			
		  }

#ifdef TRACE_UPR			
	printf(" APRES SYNC DANS n_ConditionSyncUpr : pbd_InRecChild[GT_TRNCOD_CF], n_type_trn_cd, RETCTR, RETSEC, RTY, PLC_NT, RTO_NF, lig_upr, Kd_UPR, Kd_DAC : %s; %d; %s; %s; %s; %d ;%d ; %-3.f ; %-3.f; %-3.f\n", pbd_InRecChild[GT_TRNCOD_CF], n_type_trn_cd, pbd_InRecChild[GT_RETCTR_NF], pbd_InRecChild[GT_RETSEC_NF], pbd_InRecChild[GT_RTY_NF], atoi(pbd_InRecChild[GT_PLC_NT]), atoi(pbd_InRecChild[GT_RTO_NF]), atof(pbd_InRecChild[GT_RETAMT_M]), Kd_UPR, Kd_DAC );		
#endif		
	}
	RETURN_VAL( OK );
}



/*==============================================================================
objet :
        fonction de sortie de la log FUTURES a destination des Utilisateurs

==============================================================================*/
void n_EcrireLog()
{
/*
	printf("pFutures->RETCTR_NF=~%s~%i~%i~%i~%-.3f~%s~%-.3f~%-.3f~%-.3f~pFutures->FURETPREMIUM%-.3f~%-.3f~%s~\n", 
pFutures->RETCTR_NF,
pFutures->RETEND_NT,
pFutures->RETSEC_NF,
pFutures->RTY_NF,
pFutures->SCOEGP_M,
pFutures->RETCUR_CF,
pFutures->UPRAMT,
pFutures->LOSRAT_R,
pFutures->TAUX,
pFutures->FURETPREMIUM,
pFutures->FURETCLAIM,
pFutures->TRNCOD);
*/

	fprintf(p_OutputFutures ,"~%s~%i~%i~%i~%-.3f~%s~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%s~\n", 
pFutures->RETCTR_NF,
pFutures->RETEND_NT,
pFutures->RETSEC_NF,
pFutures->RTY_NF,
pFutures->SCOEGP_M,
pFutures->RETCUR_CF,
pFutures->UPRAMT,
pFutures->LOSRAT_R,
pFutures->TAUX,
pFutures->FURETPREMIUM,
pFutures->FURETCLAIM,
pFutures->TRNCOD);
}



// fonction n_ChargerFBOTRSLNK

/*==============================================================================
objet :
  Chargement du tableau FBOTRSLNK
retour :
  Taille du tableau
==============================================================================*/
int n_ChargerFBOTRSLNK()
{
  int i = 0 ;

  DEBUT_FCT("n_ChargerFBOTRSLNK");

  while (fread(&Ktbd_FBOTRSLNK[i], sizeof(T_FBOTRSLNK), 1, Kp_FBOTRSLNK) == 1)
    {
				
		if    (  
						((Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 103) && (Ktbd_FBOTRSLNK[i].TRNTYP_CT < 100)) || 																					 // UPR			                 		  
		        ((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 1010) && (Ktbd_FBOTRSLNK[i].TRNTYP_CT < 100) && (Ktbd_FBOTRSLNK[i].TRSTYP_NT == 1 || Ktbd_FBOTRSLNK[i].TRSTYP_NT == 3) ) 		 // ITD
		      ) 
		 {		
          		 
         /* printf(" TBO DETTRS_CF[%s];TRNTYP_CT[%d]-------TRSPFX_CF[%c];ACMTRSL0_NT[%d];ACMTRSL1_NT[%d];ACMTRSL2_NT[%d];ACMTRSL3_NT[%d];TRSTYP_NT[%d];DETTRS_CF[%s];PCPTRS_CF[%s];TRS_CF[%c];SUBTRS_CF[%s];ESTIM_NT[%d]\n", Ktbd_FBOTRSLNK[i].DETTRS_CF,Ktbd_FBOTRSLNK[i].TRNTYP_CT,
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
                );	*/
               		   
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


/*==============================================================================
objet :
 fonction de recherche du trncod
retour :
         UPR   1  UPR
         OTHER 6  Others

==============================================================================*
int n_check_trncd_cf(char *sz_TrnCd)
{
        int i;

        DEBUT_FCT("n_check_trncd_cf");

        for ( i = 0; i <  Kn_FBOTRSLNK ; i++ )
        {
        	if ( strcmp( sz_TrnCd, Ktbd_FBOTRSLNK[i].DETTRS_CF ) == 0 )
        	{		        	
    						  
 							  if ( Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 103 )  // UPR
								  RETURN_VAL(UPR);
								  			    			  				  
								else RETURN_VAL(OTHER);	// OTHERS	 
					}
	   		}

        RETURN_VAL(OTHER);
}

*/

// [11] fonction n_check_trncd_cf
/*==============================================================================
objet :
 fonction de recherche du trncod
retour :
         UPR   1  UPR
         DAC   2  DAC
         COME  3  Commission Estimates
         PRME  4  Premium Estimates
         OTHER 6  Others

==============================================================================*/
int n_check_trncd_cf(char *sz_TrnCd)
{
        int i ;
       // char  flg_tcode;
        
        DEBUT_FCT("n_check_trncd_cf");

  for ( i = 0; i <  Kn_FBOTRSLNK ; i++ )
	{
     if ( strcmp( sz_TrnCd, Ktbd_FBOTRSLNK[i].DETTRS_CF ) == 0 )
     {          		        	        	
	 		if  ( Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 101  && Ktbd_FBOTRSLNK[i].TRSTYP_NT ==3 && Ktbd_FBOTRSLNK[i].DETTRS_CF[7] == '2' && Ktbd_FBOTRSLNK[i].TRSPFX_CF == '2' ) // Premium Estimates // [08]
			  RETURN_VAL(PRME);			    
	 		else if ( Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 201  && Ktbd_FBOTRSLNK[i].TRSTYP_NT ==3 && Ktbd_FBOTRSLNK[i].TRSPFX_CF == '2' )  // Commission Estimates // [08]
			  RETURN_VAL(COME);			    
	 		else if ( Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 103 &&  Ktbd_FBOTRSLNK[i].TRNTYP_CT < 100 && Ktbd_FBOTRSLNK[i].TRSPFX_CF == '2' )  // UPR // [08]
			  RETURN_VAL(UPR);			    
	 		else if ( Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 203 && Ktbd_FBOTRSLNK[i].TRNTYP_CT < 100  && Ktbd_FBOTRSLNK[i].TRSPFX_CF == '2' )  // DAC // [08]
			  RETURN_VAL(DAC);			  				  
	 		else RETURN_VAL(OTHER);	// OTHERS	 
		
		}  
		
	} 
  
  RETURN_VAL(OTHER);
}


int n_rech_trncd_itd(char *sz_TrnCd)
{
        int i;

        DEBUT_FCT("n_rech_trncd_itd");

        for ( i = 0; i <  Kn_FBOTRSLNK ; i++ )
        {
        	if ( strcmp( sz_TrnCd, Ktbd_FBOTRSLNK[i].DETTRS_CF ) == 0 )
        	{		        			  
 						if ( Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 1010 )  // [10] if ( (Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 1010)  && (Ktbd_FBOTRSLNK[i].TRSTYP_NT == 3) ) // ITD    
								RETURN_VAL(ITD);
								  			    			  				  
						else RETURN_VAL(OTHER);	// OTHERS	 
					}
	   		}

        RETURN_VAL(OTHER);
}

//==============================================================================
// objet  : Initialisation de la synchronisation du maitre « GTR »
//                                          avec l’esclave « Placements »
// retour : OK
//==============================================================================
int n_InitPLACEMENT2( T_RUPTURE_SYNC_VAR  *bd_RuptFPLACEMENT)
{
  DEBUT_FCT("n_InitPLACEMENT2") ;

  memset( bd_RuptFPLACEMENT, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

  // ouverture du fichier esclave des placements
  if ( n_OpenFileAppl( "ESTC1066_I3", "rt", &( bd_RuptFPLACEMENT->pf_InputFil ) ) == ERR )
    return ERR ;


  // fonction du test de synchronisation de la ligne du maitre avec l'esclave
  bd_RuptFPLACEMENT->ConditionEndSync  = n_ConditionSyncGTR_PLACEMENT2;
  bd_RuptFPLACEMENT->n_ActionLigne     = n_ActionLignePLACEMENT2;          // fonction d'action sur la ligne courante
  bd_RuptFPLACEMENT->n_PereSansFils		 = n_ActionPereSansFilsPLACEMENT2;
  bd_RuptFPLACEMENT->c_Separ           = SEPARATEUR ;
 

  RETURN_VAL( OK ) ;
}


//==============================================================================
// objet  : fonction de test de synchronisation avec le fichier PERICASE ( )
// retour :    0    ---> ptGTR = ptPLACEMENT2 ( egalité de rubrique a synchroniser)
//           > 0    ---> ptGTR > ptPLACEMENT2
//           < 0    ---> ptGTR < ptPLACEMENT2
//==============================================================================
int n_ConditionSyncGTR_PLACEMENT2( char **ptGTR, char **ptPLACEMENT2 )
{
  int ret;

  DEBUT_FCT("n_ConditionSyncGTR_PLACEMENT2") ;
  
   //printf(" DANS n_ConditionSyncGTR_PLACEMENT2 00  :PLA_RETCTR_NF%s; PLA_RTY_NF%d ;  PLA_RETSEC_NF%d\n", ptPLACEMENT2[PLA_RETCTR_NF],  atoi(ptPLACEMENT2[PLA_RTY_NF]),  atoi(ptPLACEMENT2[PLA_RETSEC_NF]) );

  if ( ( ret = ( strcmp(ptGTR[PER_CTR_NF], ptPLACEMENT2[PLA_RETCTR_NF] )  != 0 ) )) return ret; 
  if ( ( ret = ( atoi(ptGTR[PER_UWY_NF]) - atoi(ptPLACEMENT2[PLA_RTY_NF]) ) ) != 0 )  return ret;
  if ( ( ret = ( atoi(ptGTR[PER_SEC_NF]) - atoi(ptPLACEMENT2[PLA_RETSEC_NF]) ) ) != 0 )  return ret;	
  	
  if ( ( ret = ( atoi(ptGTR[PER_PLC_NT_PLA]) - atoi(ptPLACEMENT2[PLA_PLC_NT]) ) ) != 0 )  return ret; 
//[003]  if ( ( ret = ( strcmp(ptGTR[PER_RTO_NF_PLA], ptPLACEMENT2[PLA_RTO_NF] )  != 0 ) )) return ret;    	
  		 	
  	
  RETURN_VAL( 0 ) ;
}



//==============================================================================
// objet  : fonction lancee pour chaque ligne
// retour : OK ---> traitement correctement effectue
//          ERR --> probleme rencontre
//==============================================================================
int n_ActionLignePLACEMENT2( char **ptGTR, char **ptPLACEMENT2 )
{
  DEBUT_FCT("n_ActionLignePLACEMENT2") ;

  // recherche de la valeur du Placement share value
  
  kd_RETSIGSHA_R = atof(ptPLACEMENT2[PLA_RETSIGSHA_R])  ;
  //kTOT_RETSIGSHA_R = atof(ptPLACEMENT2[PLA_FIXCOM_R])  ;
  
  strcpy(Ksz_PLC_NT, ptPLACEMENT2[PLA_PLC_NT]) ;
  strcpy(Ksz_RTO_NF, ptPLACEMENT2[PLA_RTO_NF]) ;
  
  kTOT_RETSIGSHA_R = atof(ptPLACEMENT2[PLA_TOTRETSIGSHA_R])  ;

#ifdef TRACE_CALCUL_RETSIGSHA_R
    printf(" DANS n_ActionLignePLACEMENT2 : PLA_RETCTR_NF[], ptGTR[GT_RTY_NF]), atoi(ptPLACEMENT2[PLA_RTO_NF]), atoi(ptPLACEMENT2[PLA_PLC_NT]), atol(ptPLACEMENT2[PLA_RETSIGSHA_R]), kTOT_RETSIGSHA_R,  %s;%d;%d;%d;%-.3f;%-.3f \n", ptPLACEMENT2[PLA_RETCTR_NF], atoi(ptGTR[GT_RTY_NF]), atoi(ptPLACEMENT2[PLA_RTO_NF]), atoi(ptPLACEMENT2[PLA_PLC_NT]), atof(ptPLACEMENT2[PLA_RETSIGSHA_R]), kTOT_RETSIGSHA_R );
    printf(" 00 DANS n_ActionLignePLACEMENT2 : GT_RETCTR_NF, ptGTR[GT_RTY_NF]), atoi(ptGTR[GT_RTO_NF], atoi(ptGTR[GT_PLC_NT], atol(ptPLACEMENT2[PLA_RETSIGSHA_R]), kTOT_RETSIGSHA_R,  %s;%d;%d;%d;%d;%-.3f;%-.3f \n", ptGTR[GT_RETCTR_NF], atoi(ptGTR[GT_RTY_NF]), atoi(ptGTR[GT_RETSEC_NF]), atoi(ptGTR[GT_RTO_NF]), atoi(ptGTR[GT_PLC_NT]), atof(ptPLACEMENT2[PLA_RETSIGSHA_R]), kTOT_RETSIGSHA_R );
#endif

  RETURN_VAL( OK );
}


//  function n_ActionPereSansFilsPLACEMENT2
/**************************************************************************/
/*** Objet : fonction lancee quand aucune ligne du fichier PLACEMENT    ***/
/***         ne correspond a la ligne courante du fichier maitre        ***/
/***                                                                    ***/
/*** Nom : n_ActionPereSansFilsPLACEMENT2                               ***/
/***                                                                    ***/
/*** Parametres:                                                        ***/
/***    i ptsz_LigneMaitre  : pointeur sur la ligne du maitre           ***/
/***                                                                    ***/
/*** Retour:                                                            ***/
/***    OK si pas d'erreur,                                             ***/
/***    ERR si erreur.                                                  ***/
/**************************************************************************/

int n_ActionPereSansFilsPLACEMENT2(char *ptsz_LigneMaitre[])
{
  DEBUT_FCT("n_ActionPereSansFilsPLACEMENT2");

  kTOT_RETSIGSHA_R = 1 ;      
  kd_RETSIGSHA_R = 0.0;       


  RETURN_VAL(OK);
}


/**************************************************************************
objet :
	fonction lancee pour la dernière ligne

		retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
**************************************************************************/
int n_ActionLastITDPRM(
	char **pbd_InRecOwner, /* adresse de la ligne du maitre */
	char **pbd_InRecChild) /* adresse de la ligne de l'esclave */

{
	char sz_Trncod[9];
	char sz_Dblcod[2];
	char sz_Amt[21];
	char sz_Cur[4];
	double d_Amt;
	double d_taux; // Taux de conversion en devise
	//double d_RETRO_PRICING_LR ;       //  IFRS17  Retro pricing LR
	//char MsgAno[300];

	//int n_rech_itd = 0;

	double Kd_RTO_NF = 0; // Determine si la prime couvre ou non tous les placements
	double Kd_PLC_NT = 0; // Valeur du Placement issu de la PS --> bret..tracctrn
	double Kd_Claim_RetAmt = 0.0;

	//double kTOT_RETSIGSHA_R ;

	DEBUT_FCT("n_ActionLastITDPRM");
	

  strcpy(sz_Dblcod, "");

	//memset(sz_Cur, 0, sizeof(sz_Cur));

	//memset(pFutures, 0, sizeof(T_FUTURES)); // on remet la structure a vide

	Kd_retro_pricing_LR = atof(pbd_InRecOwner[PER_IPLR_R]); // Sauvegarde de la retro Pricing LR

	Kd_RetNetPrm = atof(pbd_InRecOwner[PER_FLAPROPRM_M]); // Sauvegarde de la Retro Premium Net
  d_taux = 1;

	//sprintf( sz_Cur, "%s", pbd_InRecOwner[PER_EGPCUR_CF] );

	//[02]if ( strcmp( pbd_InRecChild[GT_CUR_CF], pbd_InRecOwner[PER_EGPCUR_CF] ) != 0 )
	sprintf(sz_Cur, "%s", pbd_InRecOwner[PER_PCPCUR_CF]); // [06] force PER_PCPCUR_CF au lieu PER_EGPCUR_CF

	if (strcmp(pbd_InRecChild[GT_RETCUR_CF], pbd_InRecOwner[PER_PCPCUR_CF]) != 0)
	{

		d_taux = d_GetTaux(Kp_InputFilExc, (char)atoi(pbd_InRecChild[GT_SSD_CF]), atoi(pbd_InRecChild[GT_BALSHEY_NF]), pbd_InRecChild[GT_RETCUR_CF], pbd_InRecOwner[PER_PCPCUR_CF]);
	}

	// Alimentation de la structure de LOG pour FUTURE RETRO
	pFutures->RETEND_NT = atoi(pbd_InRecChild[GT_RETEND_NT]);
	pFutures->RETSEC_NF = atoi(pbd_InRecChild[GT_RETSEC_NF]);
	pFutures->RTY_NF = atoi(pbd_InRecChild[GT_RTY_NF]);
	pFutures->RETCTR_NF = pbd_InRecChild[GT_RETCTR_NF];
	pFutures->SCOEGP_M = atof(pbd_InRecChild[GT_SCOEGP_M]);

	Kd_RTO_NF = atof(pbd_InRecChild[GT_RTO_NF]);
	Kd_PLC_NT = atof(pbd_InRecChild[GT_PLC_NT]);
	
	
	//if (strcmp(pbd_InRecOwner[PER_CTR_NF], "RN0001168") == 0 && atoi(pbd_InRecOwner[PER_UWY_NF]) == 2020 && (atoi(pbd_InRecOwner[PER_SEC_NF]) == 1) && (atoi(pbd_InRecOwner[PER_PLC_NT_PLA]) == 1))
	//	printf(" DEBUG 010 n_ActionLastITDPRM CTRNF=%s ; UWY_NF=%d ; SEC_NF=%d ; RetroNetPremium=%f ; RETSHIGSHA=%f ; Kd_ITDWrittenPrem =%f ; pbd_InRecOwner[PER_PCPCUR_CF] = %s ; RetFutPremium = %f\n", pbd_InRecOwner[PER_CTR_NF], atoi(pbd_InRecOwner[UWY_NF]), atoi(pbd_InRecOwner[SEC_NF]), atof(pbd_InRecOwner[PER_FLAPROPRM_M]), atof(pbd_InRecOwner[PER_RETSIGSHA_R]), Kd_ITDWrittenPrem, pbd_InRecOwner[PER_PCPCUR_CF], (-1) * (atof(pbd_InRecOwner[PER_FLAPROPRM_M]) * atof(pbd_InRecOwner[PER_RETSIGSHA_R]) + Kd_ITDWrittenPrem));		

	//[015] Ajout  || (atoi(pbd_InRecOwner[PER_EXP_D]) - atoi(Ksz_CloDat) >= 0 ) et suppression de la condition && (Kd_RetNetPrm != 0)
	
	//[016] Ajout  || (atoi(pbd_InRecOwner[PER_EXP_D]) - atoi(Ksz_CloDat) >= 0 ) et reajout de la condition && (Kd_RetNetPrm != 0)	
	
	//[015]if (strcmp(pbd_InRecOwner[PER_CTRNAT_CT], "N") == 0 && (Kd_RetNetPrm != 0) && (atoi(pbd_InRecOwner[PER_EXP_D]) - atoi(Ksz_CloDat) > 0 ) )
	

	if (strcmp(pbd_InRecOwner[PER_CTRNAT_CT], "N") == 0 && (atoi(pbd_InRecOwner[PER_EXP_D]) - atoi(Ksz_CloDat) > 0 ) && (Kd_RetNetPrm != 0)) 
	{

		// d_Amt = (-1)* (atof(pbd_InRecOwner[PER_FLAPROPRM_M]) * atof(pbd_InRecOwner[PER_RETSIGSHA_R]) + atof(pbd_InRecChild[GT_RETAMT_M])* d_taux	);
		d_Amt = (-1) * (atof(pbd_InRecOwner[PER_FLAPROPRM_M]) * atof(pbd_InRecOwner[PER_RETSIGSHA_R]) + Kd_ITDWrittenPrem);
	}
	else
		d_Amt = 0;

	sprintf(sz_Amt, "%-.3f", d_Amt);
	strcpy(sz_Trncod, "2A100012");
	pFutures->TRNCOD = sz_Trncod;

	Kd_RetPrmAmt = d_Amt;
	pFutures->FURETPREMIUM = d_Amt; // Retro Future Fixe Premium

	//pbd_InRecChild[GT_RETAMT_M] = "0";
	//pbd_InRecChild[GT_RETINTAMT_M] = "0";
	pbd_InRecChild[GT_TRNCOD_CF] = sz_Trncod;
	pbd_InRecChild[GT_DBLTRNCOD_CF] = sz_Dblcod;
	pbd_InRecChild[GT_AMT_M] = " ";
	pbd_InRecChild[GT_RETAMT_M] = sz_Amt;
	pbd_InRecChild[GT_RETCUR_CF] = sz_Cur;

	pbd_InRecChild[GT_BALSHEY_NF] = Ksz_Annee_bilan;
	pbd_InRecChild[GT_BALSHRMTH_NF] = Ksz_Mois_bilan;
	pbd_InRecChild[GT_BALSHRDAY_NF] = Ksz_Jour_bilan;

	pbd_InRecChild[GT_RETSCOSTRMTH_NF] = Ksz_Mois_bilan;
	pbd_InRecChild[GT_RETSCOENDMTH_NF] = Ksz_Mois_bilan;

	pbd_InRecChild[GT_PLC_NT] = pbd_InRecOwner[PER_PLC_NT_PLA]; // PER_PLC_NT_PLA
	pbd_InRecChild[GT_RTO_NF] = pbd_InRecOwner[PER_RTO_NF_PLA]; // PER_RTO_NF_PLA

	pbd_InRecChild[GT_RETEND_NT] = pbd_InRecOwner[PER_END_NT]; // [05] PER_END_NT
	pbd_InRecChild[GT_RETUW_NT] = pbd_InRecOwner[PER_UW_NT];	 // [05] PER_UW_NT


	n_EcrireLog();

	if (fabs(atof(sz_Amt)) > 1)
	{


		n_WriteCols(Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0);
	}
	else
		Kd_RetPrmAmt = 0 ; //[015]

	/****************************************************************************/
	/* Computing automatically retro future claim for NP retrocession contracts */
	/****************************************************************************/

	// R02 - 02 : Future Claim calculation rule
	// Retro Future Claims ( 2A494302 ) = (Retro Future Premium - Retro UPR) * (retro pricing LR)*(-1)
	// retro pricing LR : BRET...TRETIFRS champ pricedlrR --> stocker dans PER_IPLR_R;

	//Le montant d'estimaion de la Future CLAIM est 0 lorque CTRNAT est different de "N" ou lorque le montant du retro_Pricing est à 0.
	
	
	if (strcmp(pbd_InRecOwner[PER_CTRNAT_CT], "N") == 0 || (Kd_retro_pricing_LR != 0)) 
		d_Amt = (Kd_RetPrmAmt - Kd_UPR) * Kd_retro_pricing_LR * (-1) * 100;             //|07] d_Amt = (Kd_RetPrmAmt - Kd_UPR ) * Kd_retro_pricing_LR * (-1) ;
	else
		d_Amt = 0.0;

	sprintf(sz_Amt, "%-.3f", d_Amt);
	strcpy(sz_Trncod, "2A494302");
	pFutures->TRNCOD = sz_Trncod;

	Kd_Claim_RetAmt = d_Amt;
	pFutures->FURETCLAIM = d_Amt; // RETRO Future Fixed Claims

	pbd_InRecChild[GT_TRNCOD_CF] = sz_Trncod;
	pbd_InRecChild[GT_RETAMT_M] = sz_Amt;

	n_EcrireLog();

	if (fabs(atof(sz_Amt)) > 1)
	{

		n_WriteCols(Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0);
	}

	// [04] DEBUT Remaining Estimates

	/*****************************************************************************************************
*** [04]                  min amount between "Premium    Estimates" and UPR --> 2A100112
***                       ANNULATION  Commission Remaining Estimate         --> 2A100122   
*****************************************************************************************************/

	if ((c_PRME_FLG == 'Y' || c_UPR_FLG == 'Y') &&
			(fabs(Kd_UPR) > 0.0 || fabs(Kd_PRME) > 0.0))
	{

		// select the min amount between "Premium Estimates" and UPR
		// and post positive amount on 2A100112

		if (Kd_PRME > (-1 * Kd_UPR))
			Kd_Prmrest = -1 * Kd_UPR;
		else
			Kd_Prmrest = Kd_PRME;

			//Kd_Prmrest = min(max(0.0, Kd_PRME),max(0.0, -1 * Kd_UPR)); // [09]


		sprintf(sz_Amt, "%-.3f", Kd_Prmrest);
		strcpy(sz_Trncod, "2A100112");
		pFutures->TRNCOD = sz_Trncod;

		pbd_InRecChild[GT_TRNCOD_CF] = sz_Trncod;
		pbd_InRecChild[GT_RETAMT_M] = sz_Amt;

		n_EcrireLog();

		if (fabs(atof(sz_Amt)) > 1)
		{

			n_WriteCols(Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0);
		}

		// Annulation REMAINING PREMIUM ESTIMATE 2A100122
		d_Amt = Kd_Prmrest * (-1);
		sprintf(sz_Amt, "%-.3f", d_Amt);
		strcpy(sz_Trncod, "2A100122");
		pFutures->TRNCOD = sz_Trncod;

		pbd_InRecChild[GT_TRNCOD_CF] = sz_Trncod;
		pbd_InRecChild[GT_RETAMT_M] = sz_Amt;

		n_EcrireLog();

		if (fabs(atof(sz_Amt)) > 1)
		{

			n_WriteCols(Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0);
		}
	}

	/*****************************************************************************************************
*** [04]                 min amount between "Commission Estimates" and DAC --> 2A120112
***                      ANNULATION  Commission Remaining Estimate         --> 2A120122   
*****************************************************************************************************/

	if ((c_COME_FLG == 'Y' || c_DAC_FLG == 'Y') &&
			(fabs(Kd_DAC) > 0.0 || fabs(Kd_COME) > 0.0))
	{

		// select the min amount between "Commission Estimates" and DAC,
		// and post negative amount on 2A120112

		if (-1 * Kd_COME > Kd_DAC)
			Kd_Commrest = -1 * Kd_DAC;
		else
			Kd_Commrest = -1 * (-1 * Kd_COME);

			//Kd_Commrest = (-1) * min(max(0.0, -1 * Kd_COME), max( 0.0, Kd_DAC)); // [09]


		sprintf(sz_Amt, "%-.3f", Kd_Commrest);
		strcpy(sz_Trncod, "2A120112");
		pFutures->TRNCOD = sz_Trncod;

		pbd_InRecChild[GT_TRNCOD_CF] = sz_Trncod;
		pbd_InRecChild[GT_RETAMT_M] = sz_Amt;

		n_EcrireLog();

		if (fabs(atof(sz_Amt)) > 1)
		{

			n_WriteCols(Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0);
		}

		// Annulation REMAINING COMMISSION ESTIMATE 2A120122
		d_Amt = Kd_Commrest * (-1);
		sprintf(sz_Amt, "%-.3f", d_Amt);
		strcpy(sz_Trncod, "2A120122");
		pFutures->TRNCOD = sz_Trncod;

		pbd_InRecChild[GT_TRNCOD_CF] = sz_Trncod;
		pbd_InRecChild[GT_RETAMT_M] = sz_Amt;

		n_EcrireLog();

		if (fabs(atof(sz_Amt)) > 1)
		{

			n_WriteCols(Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0);
		}
	}
	// [ 04] FIN Remaining Estimates

	RETURN_VAL(OK);
}


