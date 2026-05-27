/*==============================================================================
 Nom de l'application          : ESTIMATION IFRS17
 Nom du source                 : ESFC374*.c
 Revision                      : $Revision: 1.0 $
 Date de creation              : 05/08/2020
 Auteur                        : L. DOAN
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
 Description :
   -- IFRS 17 GLT transcode generation

------------------------------------------------------------------------------
     Historique des modifications :
[01] 05/08/2020 Linh DOAN  :spira:87876 : rebuild GLT transformation
[02] 21/09/2020 Linh DOAN  :spira:87920 : NDIC accounting
[03] 05/10/2020 Linh DOAN  :spira:88483 : add grouping 1010 and 1011
[04] 07/10/2021 Linh DOAN  :spira 90502 : fix error retro
[05] 07/02/2022 HR         :spira 100977 : I17 - Criteria to compute Revenue / EXP / CSM
[06] 25/10/2022 HR         :spira 106766 Revenue - endorsement management
[07] 06/03/2023 HR         :spira 108973: Change in EGPI position- estimates incorrect on some retro NP - Copy
==============================================================================*/

#ifndef __EST_ESFC3740
#define __EST_ESFC3740

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/
#define GT_ACMTRS3_NT 71
#define GT_ACMTRS3_NT2 128
#define GTSII_AM01_M 54
#define GT2_ACMTRS_NT 41
#define GT2_ACMAMT_M 42
#define GT2_AMT_M 18
#define GT2_ACMCUR_CF 43
#define GT2_ACCRET 48
#define GT2_NORME 49
#define GT2_PATCAT_CT 51
#define GT2_PATTYP_CT 52
#define GT2_TOTAUX_M 122
#define GT2_ACMTRS3_NF 123
#define GT2_TYP_CT 48
#define GT2_NAT_CF 47
#define GT2_GRPINIPRO_CF 124
#define GT2_PARINIPRO_CF 125
#define GT2_LOCINIPRO_CF 126
//[05]
#define GT2_LC_PAT_PREV 124
#define GT2_CSM_PAT_PREV 125
#define GT2_CSM_PAT_PREV_RP 126
#define GT2_CTRCAT_CF 127





#define Kn_MaxPostes 100000 /* Le nombre max de postes est fixe a 100000 */
/* Structure pour la recuperation des donnees dans le fichier binaire FBOPRSLNK */
#define Kn_MaxLigFBOPRSLNK 40000 // [002]

#define Kn_MaxData 50 // 2 indices *  3 categories
#define Kn_CategoriesSize 2

//SPIRA 106766
FILE *Kp_OutputFil_FILE;	
//SPIRA 106766
T_RUPTURE_VAR Kbd_Rup_FILE;
//SPIRA 106766
int n_Init_FILE(T_RUPTURE_VAR  *pbd_Rupt);
int n_ActionLigne_FILE( char **ptb_InRec_Cur );
int n_ActionLastRupt_FILE ( char **ptb_InRec_Cur );
int n_ActionFirstRupt_FILE ( char **ptb_InRec_Cur );
int n_IsRupt_FILE(char **ptb_InRec, char **ptb_InRec_Cur);

typedef struct
{
  short  valuePresent;
  double firstValue;
  double secondValue;
  short acmtrs3_code;
} PairData;

/* List of Nature bivalues*/
typedef enum
{
  FIRST_POST,  
  //12.1
  RA_FUTURE,                    //Future RA OCI	42730|4103  : RAD/DSI/320/3201 , AMT = RAD/DSI - RAD/LKI
  RA_INCURRED,                  //Incurred RA OCI	42740|4123 : RAD/DSI/301/3010 , AMT = RAD/DSI - RAD/LKI : (RA_INCURRED) 
  //11.6
  CHG_EST_FUTURE_FIX_PRE,       // Change in Estimates - Future Receivables 12121|6500 : EXP/EARPR/105/1051	
  CHG_EGPI_FUTURE_FIX_PRE,      // Change in EGPI - Future Receivables	10121|6520 : EXP/EGPPR/105/1051
  CHG_EST_DAC_BRK,              // Change in Estimates - DAC Brokerage	43062|6200 : EXP/EARAE/203/2031
  CHG_EGPI_DAC_BRK,             // Change in EGPI - DAC Brokerage	43065|6220 : EXP/EGPAE/203/2031 
  CHG_EST_DAC_VAR,              // Change in Estimates - DAC Variables	43063|6100 : EXP/EARCL/203/2032  
  CHG_EGPI_DAC_VAR,             // Change in EGPI - DAC Variables	43066|6120 :  EXP/EGPCL/203/2032
  CHG_EST_DAC_BRK17,            // Change in Estimates - DAC Brokerage IFRS17, 43064|6200 : EXP/EARAE/203/2035
  CHG_EGPI_DAC_BRK17,           // Change in EGPI - DAC Brokerage IFRS17	43067|6220 : EXP/EGPAE/203/2035 
  CHG_EST_FUTURE_BRKR,          // Change in Estimates - Future Acquisition Cost, 12200|6200 : EXP/EARAE/205/2053 
  CHG_EGPI_FUTURE_BRKR,         // Change in EGPI - Future Acquisition Cost 12220|6220 :  EXP/EGPAE/205/2053		
  CHG_EST_FUTURE_CLM,           // CHG_EST_FUTURE_CLM, Change in Estimates - Future Claim	49100|6100 :  EXP/EARCL/320/*
  CHG_EGPI_FUTURE_CLM,          // CHG_EGPI_FUTURE_CLM, Change in EGPI - Future Claim	49120|6120 : EXP/EGPCL/320/*
  CHG_EST_FUTURE_ACQU_EXP,      // CHG_EST_FUTURE_ACQU_EXP //Change in Estimates - Acquisition expenses 43667|6600 :  /EXP/EARAE/209/2090	
  CHG_EGPI_FUTURE_ACQU_EXP,     // CHG_EGPI_FUTURE_ACQU_EXP, Change in EGPI - Acquisition expenses	43666|6620 : EXP/EGPAE/209/2090	
  CHG_EST_MAINT_EXP,            // CHG_EST_MAINT_EXP, Change in Estimates - Maintenance expense future	46077|6640 : EXP/EARME/314/3115	
  CHG_EGPI_MAINT_EXP,           // CHG_EGPI_MAINT_EXP, Change in EGPI - Maintenance expense future	46076|6660 : EXP/EGPME/314/3115   
  CHG_EST_RA,                   //CHG_EST_RA, Change in Estimates - Risk adjustment	49300|6300 : EXP/EARRA/320/3201
  CHG_EGPI_RA,                  //CHG_EGPI_RA, Change in EGPI - Risk adjustment, 49320	6320 : EXP/EGPRA/320/3201	
  CHG_EST_BDT,                  //CHG_EST_BDT, Change in Estimates - Bad debt	49350|6100 : EXP/EARBD/( * )/( * )
  CHG_EGPI_BDT,                 // CHG_EGPI_BDT, Change in EGPI - Bad debt	49440|6120 : EXP/EGPBD/*/*
  CHG_EST_NDIC,                 // CHG_EST_NDIC Change in Estimates - NDIC, 49340|6100 : EXP/EARNE/221/2211
  CHG_EGPI_NDIC,                // CHG_EST_NDIC Change in EGPI - NDIC,49360|6120: EXP/EGPPI/221/2211
  INI_BDT_LKI,                  // INI_BDT_LKI - Bad debt INI	41611|3225 : min (Total  Amount (BDT / LKI / 105 + BDT / LKI / 205 + BDT / LKI / 320) , 0)
  CHG_IAE_FUTURE_UNDIS,		// Internal Aquisition Expenses Future Undiscounted	43610|2090 : CSF/PRACC

  //CHG_EGPI_FUTURE_VAR_PRE, // fixed premium and variable premium
  //CHG_EGPI_FUTURE_VAR_CHRG, // fixed charges and variable charges
 
  //CHG_EST_FUTURE_LOSS_CORRIDOR,
  //CHG_EGPI_FUTURE_LOSS_CORRIDOR,
    
  //CHG_EST_FUTURE_VAR_PRE, // estimation fixed premium and variable premium
  //CHG_EST_FUTURE_VAR_CHRG, // estimation  fixed charges and variable charges
  //CHG_EST_FUTURE_FIX_CHRG,  
  //CHG_EGPI_FUTURE_FIX_CHRG, 
  
  //
  LAST_POST
} Postion_GT;


/* Structure pour la recuperation des donnees dans le fichier binaire FBOPRSLNK */

#define Kn_MaxFPRSMAP 3000 // [002]

#define TRSCODE_SIZE 5
#define MAXLINE 1000
#define SEPARATOR        "~"


typedef struct
{
  short grp750;
  short grp751;
  char trscodeLKI[TRSCODE_SIZE];
  char trscodeDSI[TRSCODE_SIZE];
  char trscodeFWD[TRSCODE_SIZE];
  double dsiValue;
} PrsMapData;

typedef enum
{
  PRSMAP_PRS_CF,
  PRSMAP_ACMTRS_NT,
  PRSMAP_PARM1, //-- PR, CL or NULL
  PRSMAP_PARM2, //-- 750 grouping for discount
  PRSMAP_PARM3, //-- 751 grouping for discount
  PRSMAP_PARM4, //-- Discount sign
  PRSMAP_PARM5, //-- LKI --INI
  PRSMAP_PARM6, //-- LKI --STD
  PRSMAP_PARM7, //-- DSI
  PRSMAP_PARM8, //-- FWD
  PRSMAP_PARM9, // not used
  PRSMAP_PARM10 // not used
} PrsMapDataIndex;

//only bivalues transcode
static char *TransCode[] = {
    "00000",        // not used
    //12.1
    "42730",        // rad  future RA_FUTURE,
    "42740",        // rad incurred  RA_INCURRED, 
    //11.6
    "12121",        // CHG_EST_FUTURE_FIX_PRE  // Change in Estimates - Future Receivables 12121|6500 : EXP/EARPR/105/1051	
    "10121",        // CHG_EGPI_FUTURE_FIX_PRE, Change in EGPI - Future Receivables	6520
    "43062",        // CHG_EST_DAC_BRK,Change in Estimates - DAC Brokerage	43062|6200 : EXP/EARAE/203/2031
    "43065",        // CHG_EGPI_DAC_BRK,Change in EGPI - DAC Brokerage	43065|6220 : EXP/EGPAE/203/2031 
    "43063",        // CHG_EST_DAC_VAR,Change in Estimates - DAC Variables	43063|6100 : EXP/EARCL/203/2032  
    "43066",        // CHG_EGPI_DAC_VAR,Change in EGPI - DAC Variables	43066|6120 :  EXP/EGPCL/203/2032
    "43064",        // CHG_EST_DAC_BRK17,Change in Estimates - DAC Brokerage IFRS17, 43064|6200 : EXP/EARAE/203/2035	
    "43067",        // CHG_EGPI_DAC_BRK17, Change in EGPI - DAC Brokerage IFRS17	43067|6220 : EXP/EGPAE/203/2035
    "12200",        // CHG_EST_FUTURE_BRKR,     // Change in Estimates - Future Acquisition Cost, 12200|6200 : EXP/EARAE/205/2053
    "12220",        // CHG_EGPI_FUTURE_BRKR,    // Change in EGPI - Future Acquisition Cost 12220|6220 :  EXP/EGPAE/205/2053	  
    "49100",        // CHG_EST_FUTURE_CLM, Change in Estimates - Future Claim	49100|6100 :  EXP/EARCL/320/*
    "49120",        // CHG_EGPI_FUTURE_CLM, Change in EGPI - Future Claim	49120|6120 : EXP/EGPCL/320/* 	
    "43667",        // CHG_EST_FUTURE_ACQU_EXP //Change in Estimates - Acquisition expenses 43667|6600 :  /EXP/EARAE/209/2090	
    "43666",        // CHG_EGPI_FUTURE_ACQU_EXP, Change in EGPI - Acquisition expenses	43666|6620 : EXP/EGPAE/209/2090	
    "46077",        // CHG_EST_MAINT_EXP, Change in Estimates - Maintenance expense future	46077|6640 : EXP/EARME/314/3115	
    "46075",        // CHG_EGPI_MAINT_EXP, /Change in EGPI - Maintenance expense future	46075|6660 : EXP/EGPME/314/3115 : old 46076
    "49300",        // CHG_EST_RA, Change in Estimates - Risk adjustment	49300|6300 : EXP/EARRA/320/3201	
    "49320",        // CHG_EGPI_RA, Change in EGPI - Risk adjustment, 49320|6320 : EXP/EGPRA/320/3201	
    "49350",        // CHG_EST_BDT : Change in Estimates - Bad debt	49350|6100 : EXP/EARBD/( * )/( * )	
    "49440",        // CHG_EGPI_BDT, Change in EGPI - Bad debt,	49440|6120 : EXP/EGPBD/( * )/( * )	
    "49340",        // CHG_EST_NDIC Change in Estimates - NDIC, 49340|6100 : EXP/EARNE/221/2211
    "49360",        // CHG_EGPI_NDIC Change in EGPI - NDIC,49360|6120: EXP/EGPPI/221/2211
    "41611",        // Initial Bad Debt, INI_BDT_LKI
    "43610",        // CHG_IAE_FUTURE_UNDIS Internal Aquisition Expenses Future Undiscounted     43610|2090 : CSF/PRACC
    //"49200",      // Change in Estimates  future loss corridor
    //"49220",      // CHG_EGPI_FUTURE_LOSS_CORRIDOR
    //"12120",      // CHG_EGPI_FUTURE_VAR_CHRG
    //"10102",      // CHG_EST_FUTURE_VAR_PRE, Change in Estimates  fixed premium and variable premium
    //"10122",      // CHG_EGPI_FUTURE_VAR_PRE Change in EGPI futures  variable premium
    //"12101",      // CHG_EST_FUTURE_FIX_CHRG ,
    //"10121",      // CHG_EGPI_FUTURE_FIX_CHRG  : TODO check avec Serge : 12121 origin >> 10121 
    
    "00000"         // not used
    };     // 2 indices


    //11.7
    //"42700",        // Initial RA LKI, INI_RAD_LKI>> direct
    //"41611",        // Initial Bad Debt, INI_BDT_LKI>> direct

#endif  /*__EST_ESFC3740 */
