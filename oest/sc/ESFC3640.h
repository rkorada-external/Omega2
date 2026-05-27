/**=======================================================================================================
NOM DE L'APPLICATION          : ACF/PCA: RATIO CALCULATION
NOM DU SOURCE                 : ESFC3640.h
REVISION                      : V1
DATE DE CREATION              : 08/2021
AUTEUR                        : L.ELFAHIM
SQUELETTE DE BASE             : BATCH
REFERENCES DES SPECIFICATIONS : 
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
DESCRIPTION :
	CETTE INTERFACE EST DESTINEE A FAIRE LE CALCUL DE ACF/PCA RATIO
	
	 /  \   
	/  ! \  
	/______\ 
       
	CE FICHIER HEADER EST APPELLE DANS LES PROGRAMES SUIVANTS ET GERE ASSUMED && RETRO P AND RETRO NP
	- ESFC3640.c 	====> ASSUMED
	- ESFC3641.c	====> RETRO P
	- ESFC3642.c 	====> RETRO NP
----------------------------------------------------------------------------------------------------------
HISTORIQUE DES MODIFICATIONS :
<JJ/MM/AAAA>   	<AUTEUR> 	<SPIRA>		<DESCRIPTION DE LA MODIFICATION>
09/08/2021      LEL     	97373       DEVELOPMENT OF INITIAL VERSION
25/10/2021    	LEL       	98214		IFRS17 LOCAL- ACCRET_CF (R/RI) INCORRECT
22/11/2021      MiS     	100384		REQ 11.06 - IFRS 17 - DAC Q-1 not taken into account to form DSCxFWD
02/06/2022      HR     	        102733		REQ 11.02 - IFRS17 - No future maintenance expenses calculated at subsequent measurement
=========================================================================================================*/

#ifndef __ESFC3640
#define __ESFC3640

/**----------------------------------------------------
	DEFINE VARIABLES            
-------------------------------------------------------*/
#define LINETYP_NF			12
#define AMN_LEN 			30
#define GT_EGPICUR_CF		31
#define PLC_NT				32
#define RET_NAT_CF			47			
#define TRN_CODE			51
#define CML_AN2				55
#define SEGMENT				45
#define LINE_OF_BUSINESS	46
#define EGPICUR_CF			77
#define CTRRET_B			78
#define SSDRTO_B			78
#define TRANS_CODE			112	
#define TRN_TYPE			113
#define CML_ACMTRS3_NT2		123
#define INITIAL_AMNT		128		
#define GT_GRPINISTS_CT		126
#define GT_GRPFIRCLO_D		127

#define SEPARATOR 	 		"~"
#define MAX_SSDACTR 		400000			
/**----------------------------------------------------
	DECLARATION DES FICHIERS DU TRAVAIL            
-------------------------------------------------------*/
FILE *Kp_InputFilExc;        				
FILE *Kp_OutputFilRatio;
FILE *Kp_InputFilSsdActr;
FILE *Kp_OutputFil_DAC_LKI;					
FILE *Kp_OutputFil_DAC_FWD;
/**-----------------------------------------------------------------------/
	DECLARATION DES STRUCTURES DE REPTURE ET SYNCHRONISATION
--------------------------------------------------------------------------*/  
T_RUPTURE_VAR Kbd_Rup_TRERETFACCTR; 
T_RUPTURE_VAR Kbd_Rup_DAC_CREATION;  	

T_RUPTURE_SYNC_VAR Kbd_Rupt_UPR_Q;  
T_RUPTURE_SYNC_VAR Kbd_Rupt_ITD_PREM;   
T_RUPTURE_SYNC_VAR Kbd_Rupt_UPR_PREVQ;
T_RUPTURE_SYNC_VAR Kbd_Rupt_CASHFLOW_Q;
T_RUPTURE_SYNC_VAR Kbd_Rupt_CASHFLOW_INI;
T_RUPTURE_SYNC_VAR Kbd_Rupt_CASHFLOW_PREVQ;

/**--------------------------------------------------------------------------------/
	DECLARATION DE PROTOTYPE DES FONCTIONS 
----------------------------------------------------------------------------------*/
/**  ACCEPT && RETRO MANAGEMENT **/
int n_ActionFirstRuptPER( char **ptb_InRec_Cur );
int n_Init_TRERETFACCTR(T_RUPTURE_VAR  *pbd_Rupt);
int n_ActionLigne_TRERETFACCTR( char **ptb_InRec_Cur );
int n_IsRupt_TRERETFACCTR(char **ptb_InRec, char **ptb_InRec_Cur);

int n_Init_CASHFLOW_Q(T_RUPTURE_SYNC_VAR  *pbd_Rupt);
int n_CondSync_CASHFLOW_Q( char **pbd_InRecOwner , char **pbd_InRecChild );
int n_ActionLigne_CASHFLOW_Q( char **pbd_InRecOwner , char **pbd_InRecChild );

int n_Init_CASHFLOW_PREVQ(T_RUPTURE_SYNC_VAR  *pbd_Rupt);
int n_CondSync_CASHFLOW_PREVQ( char **pbd_InRecOwner , char **pbd_InRecChild );
int n_ActionLigne_CASHFLOW_PREVQ( char **pbd_InRecOwner , char **pbd_InRecChild );

int n_Init_CASHFLOW_INI(T_RUPTURE_SYNC_VAR  *pbd_Rupt);
int n_CondSync_CASHFLOW_INI( char **pbd_InRecOwner , char **pbd_InRecChild );
int n_ActionLigne_CASHFLOW_INI( char **pbd_InRecOwner , char **pbd_InRecChild );

int n_Init_ITD_PREM(T_RUPTURE_SYNC_VAR  *pbd_Rupt);
int n_CondSync_ITD_PREM( char **pbd_InRecOwner , char **pbd_InRecChild );  
int n_ActionLigne_ITD_PREM( char **pbd_InRecOwner , char **pbd_InRecChild );

int n_Init_UPR_Q(T_RUPTURE_SYNC_VAR  *pbd_Rupt);
int n_CondSync_UPR_Q( char **pbd_InRecOwner , char **pbd_InRecChild );
int n_ActionLigne_UPR_Q( char **pbd_InRecOwner ,char **pbd_InRecChild );

int n_Init_UPR_PREVQ(T_RUPTURE_SYNC_VAR  *pbd_Rupt);
int n_CondSync_UPR_PREVQ( char **pbd_InRecOwner , char **pbd_InRecChild );
int n_ActionLigne_UPR_PREVQ( char **pbd_InRecOwner ,char **pbd_InRecChild );

/**  DAC FICTIF MANAGEMENT  **/
int n_ChargerSSDACTR( void );
int n_Init_DAC_CREATION(T_RUPTURE_VAR  *pbd_Rupt);
int n_ActionLigne_DAC_CREATION ( char **ptb_InRec_Cur );
int n_ActionLasrRupt_DAC_CREATION ( char **ptb_InRec_Cur );
int n_ActionFirstRupt_DAC_CREATION ( char **ptb_InRec_Cur );
int n_IsRupt_DAC_CREATION(char **ptb_InRec, char **ptb_InRec_Cur);
int n_RechercheSSDACTR( char *RetCtr, short Rty, long Plc, unsigned char RetSec );

/**--------------------------------------------------------------------/
	DECLARATION DES VARIABLES GLOBALES POUR ACCEPT ET RETRO
-----------------------------------------------------------------------*/
double 	d_UPR_Q;
double 	d_DAC_AMT;
double 	d_ITD_PREM;
double	d_PREM_ESTM; 				 					
double	d_REMAIN_ESTM;
double 	d_ITD_PREM_ACT;	
double 	d_FUTURE_PREM_Q;
double 	d_FUTURE_PREM_INI;
double 	d_FIXED_CHARGE_ACT;
double 	d_FUT_FIXED_CHARGE;
double	d_FUTURE_OVERRIDE_COM;

double 	d_UPR_PREVQ;
double	d_PREM_ESTM_PREVQ;
double 	d_FUTURE_PREM_PREVQ; 
double	d_REMAIN_ESTM_PREVQ;

char   	Norme_CF[5];
char 	Ksz_CloDat[9];
char 	Blcshyear[5];

char   	COMMENT1_CF[50],
		COMMENT2_CF[50],
		COMMENT3_CF[50],
		COMMENT_CF[160];

char 	Ksz_PATTYP[4];
char 	Ksz_Mois_bilan[3]; 
char 	Ksz_Jour_bilan[3]; 
char 	Ksz_Annee_bilan[5];				
char 	Ksz_Prev_CloDat[9];	

int		Kn_SsdActr_Nbp;

/**-------------------------------------------------------/
	DECLARATION DES ENUMMERATIONS
----------------------------------------------------------*/
enum { PATTERNSII_ANNEES = 65 };
//11 chiffres dont 8 décimales et signe et séparateur décimal et séparateur ~
enum { TAILLE_PATTERNSII_TAUX = ((1 + 11 + 1 + 1) * PATTERNSII_ANNEES) + 1};  // "<3 entiers>.<8 décimales>~" x PATTERNSII_ANNEES taux + '\0'
//SSD_CF[3]/PATCAT_CT[6]/PATTYP_CT[6]/SEG_NF[11]/CUR_CF[4]/LOB_CF[3]/RATING_CF[6]/NORME_CF[6]/SEGNAT_CT[2]/BALSHEY_NF[5]/courbe_taux[TAILLE_COURBE_TAUX]
enum { TAILLE_CLE_PATTERNSII = 3 + 6 + 6 + 11 + 4 + 3 + 6 + 6 + 2 + 5 + TAILLE_PATTERNSII_TAUX };

enum COL_CUMUL {
  CML_SSD_CF = 0,
  CML_ESB_CF,
  CML_BALSHEY_NF,
  CML_BALSHRMTH_NF,
  CML_BALSHRDAY_NF,
  CML_TRNCOD_CF,
  CML_DBLTRNCOD_CF,
  CML_CTR_NF,
  CML_END_NT,
  CML_SEC_NF,
  CML_UWY_NF,
  CML_UW_NT,
  CML_OCCYEA_NF,
  CML_ACY_NF,
  CML_SCOSTRMTH_NF,
  CML_SCOENDMTH_NF,
  CML_CLM_NF,
  CML_CUR_CF,
  CML_AMT_MC,
  CML_CED_NF,
  CML_BRK_NF,
  CML_PAY_NF,
  CML_KEY_NF,
  CML_RETCTR_NF,
  CML_RETEND_NT,
  CML_RETSEC_NF,
  CML_RTY_NF,
  CML_RETUW_NT,
  CML_RETOCCYEA_NF,
  CML_RETACY_NF,
  CML_RETSCOSTRMTH_NF,
  CML_RETSCOENDMTH_NF,
  CML_RCL_NF,
  CML_RETCUR_CF,
  CML_RETAMT_MC,
  CML_PLC_NT,
  CML_RTO_NF,
  CML_INT_NF,
  CML_RETPAY_NF,
  CML_RETKEY_CF,
  CML_RETINTAMT_MC,
  CML_ACMTRS_NT,
  CML_ACMAMT_MC,
  CML_ACMCUR_CF,
  CML_PRS_CF,
  CML_SEG_NF,
  CML_LOB_CF,
  CML_NAT_CF,
  CML_TYP_CT,
  CML_NORME_CF,
  CML_PATTYP_1056 = CML_NORME_CF,
  CML_RATING_CF,
  CML_JOINTURE_1056 = CML_RATING_CF,
  CML_PATCAT_CT,
  CML_PATTYP_CT,
  CML_PATTERN_ID,
  CML_AN1,
  CML_AM01_MC = CML_AN1,
  CML_AM_FIN = CML_AM01_MC +  PATTERNSII_ANNEES - 1,
  CML_COEF_LOB,
  CML_DSCCUR_CF,
  CML_COMMENT,
  CML_TOTAUX_MC,
  CML_SEGMENT_SII,
  CML_SEGMENT_LE,
  CML_AMT_EURO,
  CML_RATIO = CML_AMT_EURO
};

enum TRERETFACCTR {
  CTR_NF= 0,
  END_NT,
  SEC_NF,
  UWY_NF,
  UW_NT,
  RATEINDEX_CTG,
  RATEINDEX_CTP,
  RATEINDEX_CTL,
  TYPE,
  SSD_CF,
  ESB_CF,
  GRPINISTS_CT,
  PARINISTS_CT,
  LOCINISTS_CT,
  GRPFIRCLO_D,
  PARFIRCLO_D,
  LOCFIRCLO_D,
  GRPIFRSTRA_CT,
  PARIFRSTRA_CT,
  LOCIFRSTRA_CT,
  FIELD1,
  FIELD2,
  FIELD3,
  FIELD4,
  FIELD5,
  FIELD6,
  RETCTR_NF,
  RETEND_NT,
  RETSEC_NF,
  RTY_NF,
  RETUW_NT
};

/** Structure specifique a ce programme */
typedef struct {
  char    		RETCTR_NF[10];
  short         RTY_NF ;
  int   		PLACMENT_NT;
  unsigned char RETSEC_NF;
  unsigned char SSD_CF;
  char        	CTR_NF[10];
  short      	UWY_NF;
  unsigned char UW_NT ;
  unsigned char	SEC_NF;
  unsigned char	END_NT;
  int   		CLISSD_NF;
  unsigned char RTOSSD_CF;
} S_SSDACTR ;

S_SSDACTR Ktbd_SsdActr[MAX_SSDACTR];

#endif /* __ESFC3640 */
