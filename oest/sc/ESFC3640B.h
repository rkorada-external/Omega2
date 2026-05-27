/**=======================================================================================================
NOM DE L'APPLICATION          : ACF/PCA: RATIO CALCULATION
NOM DU SOURCE                 : ESFC3640B.h
REVISION                      : V1
DATE DE CREATION              : 06/2022
AUTEUR                        : HR
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
	- ESFC3640B.c 	====> ASSUMED
	- ESFC3641B.c	====> RETRO P
	- ESFC3642B.c	====> RETRO NP
----------------------------------------------------------------------------------------------------------
HISTORIQUE DES MODIFICATIONS :
<JJ/MM/AAAA>   	<AUTEUR> 	<SPIRA>		<DESCRIPTION DE LA MODIFICATION>
20/06/2022      HR          102519      IFRS17 revenue- Endorsement management 
=========================================================================================================*/

#ifndef __ESFC3640B
#define __ESFC3640B

/**----------------------------------------------------
	DEFINE VARIABLES            
-------------------------------------------------------*/

#define SEPARATOR 	 		"~"
		
/**----------------------------------------------------
	DECLARATION DES FICHIERS DU TRAVAIL            
-------------------------------------------------------*/
FILE *Kp_OutputFilRatio;
/**-----------------------------------------------------------------------/
	DECLARATION DES STRUCTURES DE REPTURE ET SYNCHRONISATION
--------------------------------------------------------------------------*/  
//compteur de rupture
int n_RuptCount;
T_RUPTURE_VAR Kbd_Rup_RATIO; 

/**--------------------------------------------------------------------------------/
	DECLARATION DE PROTOTYPE DES FONCTIONS 
----------------------------------------------------------------------------------*/
/**  ACCEPT && RETRO MANAGEMENT **/

int n_Init_RATIO(T_RUPTURE_VAR  *pbd_Rupt);
int n_ActionLigne_RATIO( char **ptb_InRec_Cur );
int n_ActionLastRupt_RATIO ( char **ptb_InRec_Cur );
int n_ActionFirstRupt_RATIO ( char **ptb_InRec_Cur );
int n_IsRupt_RATIO(char **ptb_InRec, char **ptb_InRec_Cur);

/**--------------------------------------------------------------------/
	DECLARATION DES VARIABLES GLOBALES POUR ACCEPT ET RETRO
-----------------------------------------------------------------------*/
double 	d_UPR_Q;
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

char 	Ksz_CloDat[9];

char   	COMMENT1_CF[50],
		COMMENT2_CF[50],
		COMMENT3_CF[50],
		COMMENT_CF[160];

/**-------------------------------------------------------/
	DECLARATION DES ENUMMERATIONS
----------------------------------------------------------*/

enum ESF_RATIO_ASSUMED {
  A_CTR_NF= 0,
  A_END_NT,
  A_SEC_NF,
  A_UWY_NF,
  A_UW_NT,
  A_EGPI_R1,
  A_EGPI_R2,
  A_EARP_R1,
  A_FUTURE_PREM_PREVQ,
  A_FUTURE_PREM_Q,
  A_PREM_ESTM_PREVQ,
  A_PREM_ESTM,
  A_REMAIN_ESTM_PREVQ,  
  A_REMAIN_ESTM,
  A_FIXED_CHARGE_ACT,
  A_ITD_PREM_ACT,
  A_ITD_PREM,
  A_UPR_PREVQ,
  A_UPR_Q,
  A_COMMENT_CF,
  A_CSM_Q,
  A_CSM_PREV_Q,
  A_LC_Q,
  A_LC_PREV_Q,
  A_GRPINISTS_CT,
  A_GRPFIRCLO_D
 };


enum ESF_RATIO_RET_P {
  RP_CTR_NF= 0,
  RP_END_NT,
  RP_SEC_NF,
  RP_UWY_NF,
  RP_UW_NT,
  RP_RETCTR_NF,
  RP_RETEND_NT,
  RP_RETSEC_NF,
  RP_RETUWY_NF,
  RP_RETUW_NT,
  RP_PLC_NT,
  RP_EGPI_R1,
  RP_EGPI_R2,
  RP_EARP_R1,
  RP_FUTURE_PREM_PREVQ,
  RP_FUTURE_PREM_Q,
  RP_PREM_ESTM_PREVQ,
  RP_PREM_ESTM,
  RP_REMAIN_ESTM_PREVQ,  
  RP_REMAIN_ESTM,
  RP_FIXED_CHARGE_ACT,
  RP_ITD_PREM_ACT,
  RP_ITD_PREM,
  RP_UPR_PREVQ,
  RP_UPR_Q,
  RP_COMMENT_CF,
  RP_FILLER1,
  RP_FILLER2,
  RP_CSM_Q,
  RP_CSM_PREV_Q,
  RP_LC_Q,
  RP_LC_PREV_Q,
  RP_GRPINISTS_CT,
  RP_GRPFIRCLO_D
};


enum ESF_RATIO_RET_NP {
  RNP_CTR_NF= 0,
  RNP_END_NT,
  RNP_SEC_NF,
  RNP_UWY_NF,
  RNP_UW_NT,
  RNP_PLC_NT,
  RNP_EGPI_R1,
  RNP_EGPI_R2,
  RNP_EARP_R1,
  RNP_FUTURE_PREM_PREVQ,
  RNP_FUTURE_PREM_Q,
  RNP_PREM_ESTM_PREVQ,
  RNP_PREM_ESTM,
  RNP_REMAIN_ESTM_PREVQ,  
  RNP_REMAIN_ESTM,
  RNP_FIXED_CHARGE_ACT,
  RNP_ITD_PREM_ACT,
  RNP_ITD_PREM,
  RNP_UPR_PREVQ,
  RNP_UPR_Q,
  RNP_COMMENT_CF,
  RNP_CSM_Q,
  RNP_CSM_PREV_Q,
  RNP_LC_Q,
  RNP_LC_PREV_Q,
  RNP_GRPINISTS_CT,
  RNP_GRPFIRCLO_D
};

#endif /* __ESFC3640B */
