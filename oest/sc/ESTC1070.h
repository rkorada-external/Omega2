/*==============================================================================
 Nom de l'application          : Loader programs V2
 Nom du source                 : ESTC1070.h
 Revision                      : 
 Date de creation              : 15/06/2015
 Auteur                        : -=Dch=-   
 References des specifications : voir ESTC1070.c
 Squelette de base             : batch
------------------------------------------------------------------------------
________________
MODIFICATION    
		Auteur:         Date:           ref:        Description:    
[001]  -=Dch=-  	15/06/2015 		:spot:28941		SOLVENCY II - ULAE
[002] 03/09/2018 Charles Socie : EXT-IFRS17-903121  REQ 10.02 Cash flow: more detailed granularity ( split between variable and fixed premiums) add CML_ACMTRS3_NT
[003] 20/03/2024 DAD : spira 110913  - add LOBN2_NF, UWY_NF_2 for COL_CUMUL and CTRNAT_CT, UWY_NF, LOBN2_NF for COL_RATIO
==============================================================================*/

#ifndef __ESTC1070
#define __ESTC1070



#define LONGBUF 	3000


/* Structures des donn�es de sortie
** Objet  : EssaiBatchOut
** Sortie : ESTC1070_O1
*/


enum COL_CUMUL {
		CML_SSD_CF	= 0,
		CML_ESB_CF	,
		CML_BALSHEY_NF	,
		CML_BALSHRMTH_NF	,
		CML_BALSHRDAY_NF	,
		CML_TRNCOD_CF	,
		CML_DBLTRNCOD_CF	,
		CML_CTR_NF	,
		CML_END_NT	,
		CML_SEC_NF	,
		CML_UWY_NF	,
		CML_UW_NT	,
		CML_OCCYEA_NF	,
		CML_ACY_NF	,
		CML_SCOSTRMTH_NF	,
		CML_SCOENDMTH_NF	,
		CML_CLM_NF	,
		CML_CUR_CF	,
		CML_AMT_M	,
		CML_CED_NF	,
		CML_BRK_NF	,
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
		CML_RETAMT_M,
		CML_PLC_NT,
		CML_RTO_NF,
		CML_INT_NF,
		CML_RETPAY_NF,
		CML_RETKEY_CF,
		CML_RETINTAMT_M,
		CML_ACMTRS_NT,
		CML_ACMAMT_M,
		CML_ACMCUR_CF,
		CML_PRS_CF,
		CML_SEG_NF,
		CML_LOB_CF,
		CML_NAT_CF,
		CML_TYP_CT,
		CML_PATTYP,
		CML_SEGLOB_CF,
		CML_ACMTRS3_NT,
		CML_LOBN2_NF,
		CML_UWY_NF_2,
};

enum COL_RATIO {
		RTO_SSD_CF =0,
		RTO_ESB_CF ,
		RTO_PER_CF ,
		RTO_CLOSING_D,
		RTO_RATIO_NF, 
		RTO_CREUSR_CF , 
		RTO_CRE_D, 
		RTO_CTRNAT_CT, 
		RTO_UWY_NF,
		RTO_LOBN2_NF
};

	



#endif /* __ESTC1070 */
