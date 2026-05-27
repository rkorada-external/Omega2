/**============================================================================================
NOM DE L'APPLICATION          : IFRS17 REVENUE & CSM CALCULATION
NOM DU SOURCE                 : ESFC3690.h
REVISION                      : V1
DATE DE CREATION              : 06/2019
AUTEUR                        : L.ELFAHIM
SQUELETTE DE BASE             : BATCH
REFERENCES DES SPECIFICATIONS : 
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
DESCRIPTION :
	CETTE INTERFACE EST DESTINEE A FAIRE LE CALCUL DE IFRS17 REVENUE ET LA CSM
	
	 /  \   
	/  ! \  
	/______\ 
       
	CE FICHIER HEADER EST APPELLE DANS LES PROGRAMES SUIVANTS ET GERE ASSUMED && RETRO P AND RETRO NP
	- ESFC3690.c
	- ESFC3691.c
	- ESFC3692A.c
	- ESFC3692B.c
---------------------------------------------------------------------------------------------------
06/06/2019 	LEL 	70741  	Developpement de la version initiale
27/12/2019 	LEL 	82837   Adjust revenue calculation in the case opening FP=0 and change in EGPI<>0
20/02/2020 	LEL 	82711	INITIAL VERSION DEVELOPMENT
10/12/2020 	LEL  	90446	IMPLEMENTATION OF FIRST CLOSING CONDITIONS OF CSUOE
10/12/2020 	LEL 	90839	INVERSE SIGN DSC/LKI DAC 
23/12/2020 	LEL 	91111	EXTEND TO INCURRED RECEIVABLES/PREMIUM ESTIMATES
01/01/2021 	LEL   	93580	ALIGN RETRO AND ASSUMED REGARDING INPUT FILES
31/08/2021 	LEL 	97373	ACF/PCA: IMPACT REVENUE CALCULATION
02/02/2022  HR      100977  I17 - Criteria to compute Revenue / EXP / CSM
28/09/2022 	HR		106766	Revenue - endorsement management
====================================================================================================*/

#ifndef __ESFC3690
#define __ESFC3690

/**----------------------------------------------------
	DEFINE VARIABLES            
-------------------------------------------------------*/
#define AN1_56					54
#define CML_AN2					55
#define AMN_LEN 				30											
#define CML_ACMTRS3     		123		

#define EGPI_R1					125
#define EGPI_R2					126
#define EARP_R1					127
#define FUTURE_PREM_PREVQ		128	
#define FUTURE_PREM_Q			129
#define PREM_ESTM_PREVQ			130
#define PREM_ESTM				131
#define REMAIN_ESTM_PREVQ		132
#define REMAIN_ESTM				133
#define FIXED_CHARGE_ACT		134
#define ITD_PREM_ACT			135
#define ITD_PREM				136
#define UPR_PREVQ				137			
#define UPR_Q					138
#define CSM_Q					139
#define CSM_PREVQ				140	
//100977
#define LC_Q					141
#define LC_PREVQ				142	
 
#define SEPARATOR 	 			"~"

/**----------------------------------------------------
d_REMAIN_ESTM_PREVQ;	DECLARATION DES FICHIERS DU TRAVAIL            
-------------------------------------------------------*/
FILE *Kp_OutputFil_CSM;									
FILE *Kp_OutputFil_REVENUE;
//SPIRA 106766
FILE *Kp_OutputFil_FILE;				
/**-----------------------------------------------------------------------/
	DECLARATION DES STRUCTURES DE REPTURE ET SYNCHRONISATION
--------------------------------------------------------------------------*/  
T_RUPTURE_VAR Kbd_Rup_LockedInRate;

T_RUPTURE_VAR Kbd_Rup_CSM_CALCUL;
	
T_RUPTURE_SYNC_VAR Kbd_Rupt_FORWARD;    

//SPIRA 106766
T_RUPTURE_VAR Kbd_Rup_FILE;

/**--------------------------------------------------------------------------------/
	DECLARATION DE PROTOTYPE DES FONCTIONS 
----------------------------------------------------------------------------------*/
/**  ACCEPT && RETRO MANAGEMENT **/
int n_Init_LockedInRate(T_RUPTURE_VAR  *pbd_Rupt);
int n_ActionLigne_LockedInRate( char **ptb_InRec_Cur );

int n_Init_FORWARD(T_RUPTURE_SYNC_VAR  *pbd_Rupt);
int n_PereSansFils_FORWARD( char **pbd_InRecOwner );
int n_FilsSansPere_FORWARD( char **pbd_InRecChild );
int n_CondSync_FORWARD( char **pbd_InRecOwner , char **pbd_InRecChild );
int n_ActionLigne_FORWARD( char **pbd_InRecOwner ,char **pbd_InRecChild );

/**  CSM CALCULATION **/
int n_Init_CSM_CALCULATION(T_RUPTURE_VAR  *pbd_Rupt);
int n_IsRupt_CSM_CALCUL(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRupt_CSM_CALCUL ( char **ptb_InRec_Cur );
int n_ActionLasrRupt_CSM_CALCUL ( char **ptb_InRec_Cur );
int n_ActionLigne_CSM_CALCUL ( char **ptb_InRec_Cur );

//SPIRA 106766
int n_Init_FILE(T_RUPTURE_VAR  *pbd_Rupt);
int n_ActionLigne_FILE( char **ptb_InRec_Cur );
int n_ActionLastRupt_FILE ( char **ptb_InRec_Cur );
int n_ActionFirstRupt_FILE ( char **ptb_InRec_Cur );
int n_IsRupt_FILE(char **ptb_InRec, char **ptb_InRec_Cur);
/**--------------------------------------------------------------------/
	DECLARATION DES VARIABLES GLOBALES POUR ACCEPT ET RETRO
-----------------------------------------------------------------------*/
char   	Norme_CF[5];
char 	Ksz_CloDat[9];
char 	Ksz_PATTYP[4];
char 	Ksz_Mois_bilan[3]; 
char 	Ksz_Jour_bilan[3]; 
char 	Ksz_Annee_bilan[5];				
char 	Ksz_Prev_CloDat[9];

double 	d_UPR_Q;
double	d_ITD_PREM;
double	d_PREM_ESTM;
double	d_UPR_PREVQ;				 					
double	d_REMAIN_ESTM;
double	d_ITD_PREM_ACT;	
double	d_FUTURE_PREM_Q;
double	d_FUTURE_PREM_INI;
double	d_FIXED_CHARGE_ACT;
double	d_PREM_ESTM_PREVQ;
double	d_FUTURE_PREM_PREVQ; 
double	d_REMAIN_ESTM_PREVQ;

double	CSM_RAT; 
//100977
double  CSM_RAT_PREV;
double  LC_RAT_PREV;

/**-------------------------------------------------------/
	DECLARATION DES ENUMMERATIONS
----------------------------------------------------------*/
enum { PATTERNSII_ANNEES = 65 };
//11 chiffres dont 8 décimales et signe et séparateur décimal et séparateur ~
enum { TAILLE_PATTERNSII_TAUX = ((1 + 11 + 1 + 1) * PATTERNSII_ANNEES) + 1};  // "<3 entiers>.<8 décimales>~" x PATTERNSII_ANNEES taux + '\0'
//SSD_CF[3]/PATCAT_CT[6]/PATTYP_CT[6]/SEG_NF[11]/CUR_CF[4]/LOB_CF[3]/RATING_CF[6]/NORME_CF[6]/SEGNAT_CT[2]/BALSHEY_NF[5]/courbe_taux[TAILLE_COURBE_TAUX]
enum { TAILLE_CLE_PATTERNSII = 3 + 6 + 6 + 11 + 4 + 3 + 6 + 6 + 2 + 5 + TAILLE_PATTERNSII_TAUX };

typedef struct {
  char   SSD_CF[3];
  char   PATCAT_CT[6];
  char   PATTYP_CT[6];
  char   SEG_NF[11];
  short  UWY_NF;
  char   CUR_CF[4];
  char   LOB_CF[3];
  char   RATING_CF[6];
  char   NORME_CF[6];
  char   SEGNAT_CT[2];
  short  BALSHEY_NF;
  char   PATTERN_ID[22];
  char   CRE_D[22];
  char   CREUSR_CF[5];
  double TOTAUX;
  double AN[PATTERNSII_ANNEES];
} T_FPATTERNSII;

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

#endif /* __ESFC3690 */
