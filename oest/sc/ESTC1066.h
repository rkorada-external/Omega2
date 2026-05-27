/*==============================================================================
nom de l'application          : ESTIMATION 
nom du source                 : ESTC1066.h
révision                      : $Revision: 1.0 $
date de création              : 03/02/2019
auteur                        : MZM
references des specifications :
squelette de base             : batch
------------------------------------------------------------------------------
description :
   :REQ10.4 et REQ10.5 - Calcul des REtro Future primes, Claims for NP
#												 :spira:70671:Future premium for retro NP contracts ; 
#												 :spira:70782:Future claim for retro NP contracts 

------------------------------------------------------------------------------
historique des modifications :
[01]
================================================================================*/




 /* nombre de colonne du fichier des montants de primes et charges */

#define NB_COL_ITDPRM     	10     

#define ITD_RETCTR_NF       0
#define ITD_RTY_NF          1
#define ITD_RETSEC_NF       2	    
#define ITD_SSD_CF	        3    
#define ITD_ESB_CF	        4    
#define ITD_TRNCOD_CF       5  
#define ITD_CLODAT_D        6  
#define ITD_CUR_CF          7    
#define ITD_AMT_M           8 


/* Definition des colonnes du fichier placement qui ont ete rajoutes au IRDPERICASE */

/* PLC_NT_PLA, RTO_NF_PLA, RETSIGSHA_R, TOTRETSIGSHA_R */

#define PLC_NT_PLA       207  
#define RTO_NF_PLA       208 
#define RETSIGSHA_R      209    
#define TOTRETSIGSHA_R   210


/* Definition des colonnes du fichier placement qui ont ete rajoutes au IRDPERICASE */

/* PLC_NT_PLA, RTO_NF_PLA, RETSIGSHA_R, TOTRETSIGSHA_R */

#define PER_PLC_NT_PLA       206  
#define PER_RTO_NF_PLA       207 
#define PER_RETSIGSHA_R      208    
#define PER_TOTRETSIGSHA_R   209

       
/* PLC_NT_PLA, RTO_NF_PLA, RETSIGSHA_R, TOTRETSIGSHA_R */

#define GT_PLC_NT_PLA       73  
#define GT_RTO_NF_PLA       74 
#define GT_RETSIGSHA_R      75    
#define GT_TOTRETSIGSHA_R   76
       

                   

 /* definition de le structure Nouvelle */

typedef struct {
  char    			RETCTR_NF[10] ;
  short         RTY_NF ;
  double   			PRICEDLR_RT ;
  unsigned char RETSEC_NF ;
  unsigned char SSD_CF ;
  char          CTR_NF[10] ;
  short         UWY_NF ;
  unsigned char UW_NT ;
  unsigned char SEC_NF ;
  unsigned char END_NT ;
} T_SRETIFRD ;


/* Definition de la structure des ITP Premiums Retro 

typedef struct {
	char 					ITD_RETCTR_NF[10]  ;             
	short				  ITD_RTY_NF;           
	unsigned char ITD_RETSEC_NF	;               
	unsigned char ITD_SSD_CF	  ;                         
	unsigned char ITD_ESB_CF	  ;                        
	char          ITD_TRNCOD_CF[9];
	char 					ITD_CLODAT_D[18];            
	char 					ITD_CUR_CF[4]	;
	double 				ITD_AMT_M ;               
} T_SITDPRM;     
*/   




/* definition de la structure T_ESTGT */
typedef struct
{
  short         UWY_NF;
  unsigned char UW_NT;
  unsigned char SSD_CF;
  char          DIV_NT[4];
  char          EGPCUR_CF[4];
  unsigned char ACCESB_CF;
  int           CED_NF;
  int           PRD_NF;
  int           GENPRMPAY_NF;
  char          GANPAYORD_NT[3];
  double        PB_M;
  double        PAP_M;
  char          LOSADMMOD_CT;
  double        LOSENTAMT_M;
  double        LOSRETAMT_M;
  char          PBADMMOD_CT;
  double        PBENTAMT_M;
  double        PBRETAMT_M;
  char          PAPADMMOD_CT;
  double        PAPENTAMT_M;
  double        PAPRETAMT_M;
  char          DIFMTH_NF;
  char          SEGSA_B;
} T_ESTGT;



 /* nombre de colonne du fichier GT */

#define NB_COL_GT	41


 /* nombre de poste du tableau des complements */

#define COMP_NBPOSTE		12



 /* definition de la structure T_PCACM */

typedef struct
{
short		ACY_NF ;
unsigned char	SCOSTRMTH_NF ;
unsigned char	SCOENDMTH_NF ;
double		AMT_M ;
} T_PCACM ;


/* definition de la structure T_PCACM2 */

typedef struct
{
short		ACY_NF ;
unsigned char	SCOSTRMTH_NF ;
unsigned char	SCOENDMTH_NF ;
double		AMT_M ;
unsigned char	TRNCOD_SUFIX ;
} T_PCACM2 ;

	
 /* nombre de poste des tableaux du GT */

/*#define NB_GT_MAX	1000 modif o.arik 7/6/2001*/
#define NB_GT_MAX	2000

enum PERI_COLS {
				CTR_NF=0 ,
				END_NT,
				SEC_NF   ,
				UWY_NF   ,
				UW_NT,
				COND_EPP,
				COND_RPP,
				COND_TAX_EPP,
				COND_TAX_RPP,
				AMT_EPP ,
				AMT_RPP,
				COM_EPP,
				COM_RPP,
				TAX_EPP,
				TAX_RPP,
				DEVISE };

enum FORMAT_TECLEDR
{
  TECLEDR_SSD_CF = 0
  , TECLEDR_ESB_CF
  , TECLEDR_BALSHEY_NF
  , TECLEDR_BALSHRMTH_NF
  , TECLEDR_BALSHRDAY_NF
  , TECLEDR_TRNCOD_CF
  , TECLEDR_DBLTRNCOD_CF
  , TECLEDR_CTR_NF
  , TECLEDR_END_NT
  , TECLEDR_SEC_NF
  , TECLEDR_UWY_NF
  , TECLEDR_UW_NT
  , TECLEDR_OCCYEA_NF
  , TECLEDR_ACY_NF
  , TECLEDR_SCOSTRMTH_NF
  , TECLEDR_SCOENDMTH_NF
  , TECLEDR_CLM_NF
  , TECLEDR_CUR_CF
  , TECLEDR_AMT_M
  , TECLEDR_CED_NF
  , TECLEDR_BRK_NF
  , TECLEDR_PAY_NF
  , TECLEDR_KEY_NF
  , TECLEDR_RETCTR_NF
  , TECLEDR_RETEND_NT
  , TECLEDR_RETSEC_NF
  , TECLEDR_RTY_NF
  , TECLEDR_RETUW_NT
  , TECLEDR_RETOCCYEA_NF
  , TECLEDR_RETACY_NF
  , TECLEDR_RETSCOSTRMTH_NF
  , TECLEDR_RETSCOENDMTH_NF
  , TECLEDR_RCL_NF
  , TECLEDR_RETCUR_CF
  , TECLEDR_RETAMT_M
  , TECLEDR_PLC_NT
  , TECLEDR_RTO_NF
  , TECLEDR_INT_NF
  , TECLEDR_RETPAY_NF
  , TECLEDR_RETKEY_CF
  , TECLEDR_CRE_D
  , TECLEDR_CREUSR_CF
  , TECLEDR_LSTUPD_D
  , TECLEDR_LSTUPDUSR_CF
  , TECLEDR_LOBRET_CF
  , TECLEDR_SOBRET_CF
  , TECLEDR_TOPRET_CF
  , TECLEDR_NATRET_CF
  , TECLEDR_GARRET_CF
  , TECLEDR_PCPRSKTRYRET_CF
  , TECLEDR_USRCRTCODRET_CT
  , TECLEDR_USRCRTVALRET_LM
  , TECLEDR_RETCTRCAT_CF
  , TECLEDR_RETACCTYP_CT
  , TECLEDR_SSDRTO_B
  , TECLEDR_TRN_NT            //ajout des nouvelles colonnes du GT: 16 colonnes
  , TECLEDR_ORICOD_LS
  , TECLEDR_RETROAUTO_B
  , TECLEDR_SPEENTNAT_CF
  , TECLEDR_EVT_CF
  , TECLEDR_REVT_CF
  , TECLEDR_RETARDRETINT_B
  , TECLEDR_NEWCOLS1_CF
  , TECLEDR_NEWCOLS2_CF
  , TECLEDR_NEWCOLS3_CF
  , TECLEDR_NEWCOLS4_CF
  , TECLEDR_NEWCOLS5_CF
  , TECLEDR_NEWCOLS6_CF
  , TECLEDR_NEWCOLS7_CF
  , TECLEDR_NEWCOLS8_CF
  , TECLEDR_NEWCOLS9_CF
};

 
 
