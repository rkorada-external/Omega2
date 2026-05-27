#ifndef ESFC3710_h
# define ESFC3710_H

// Header file
#include <util.h>
#include <utctlib.h>
#include "struct.h"

// All field of CASHFLOW file
enum CashFlow {
	SSD_CF,
	ESB_CF,
	BALSHEY_NF,
	BALSHRMTH_NF,
	BALSHRDAY_NF,
	TRNCOD_CF,
	DBLTRNCOD_CF,
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	OCCYEA_NF,
	ACY_NF,
	SCOSTRMTH_NF,
	SCOENDMTH_NF,
	CLM_NF,
	CUR_CF,
	AMT_MC,
	CED_NF,
	BRK_NF,
	PAY_NF,
	KEY_NF,
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF,
	RETUW_NT,
	RETOCCYEA_NF,
	RETACY_NF,
	RETSCOSTRMTH_NF,
	RETSCOENDMTH_NF,
	RCL_NF,
	RETCUR_CF,
	RETAMT_MC,
	PLC_NT,
	RTO_NF,
	INT_NF,
	RETPAY_NF,
	RETKEY_CF,
	RETINTAMT_MC,
	ACMTRS_NT,
	ACMAMT_MC,
	ACMCUR_CF,
	PRS_CF,
	SEG_NF,
	LOB_CF,
	NAT_CF,
	TYP_CT,
	NORME_CF,
	RATING_CF,
	PATCAT_CT,
	PATTYP_CT,
	PATTERN_ID,
	AN1,
	AN2,
	AN3,
	AN4,
	AN5,
	AN6,
	AN7,
	AN8,
	AN9,
	AN10,
	AN11,
	AN12,
	AN13,
	AN14,
	AN15,
	AN16,
	AN17,
	AN18,
	AN19,
	AN20,
	AN21,
	AN22,
	AN23,
	AN24,
	AN25,
	AN26,
	AN27,
	AN28,
	AN29,
	AN30,
	AN31,
	AN32,
	AN33,
	AN34,
	AN35,
	AN36,
	AN37,
	AN38,
	AN39,
	AN40,
	AN41,
	AN42,
	AN43,
	AN44,
	AN45,
	AN46,
	AN47,
	AN48,
	AN49,
	AN50,
	AN51,
	AN52,
	AN53,
	AN54,
	AN55,
	AN56,
	AN57,
	AN58,
	AN59,
	AN60,
	AN61,
	AN62,
	AN63,
	AN64,
	AN65,
	COEF_LOB,
	DSCCUR_CF,
	COMMENT,
	TOTAUX_MC,
	ACMTRS3_NT2
};

// Global variable
FILE *Kp_OutputCashFlow;		// pointer to outupt file
FILE *Kp_InputCashFlow;			// pointer to input file

T_RUPTURE_VAR	bd_RuptCashFlow;	// manage ruptur CashFlow

char 	
	cur[4],				// CUR_CF
	acmcur[4],			// CUR_CF
	dsccur[4],			// DSCCUR_CF
	patcat[4],			// PATCAT_CT
	pattyp[4],			// PATTYP_CT
	patid[1],			// PATTERN_ID
	acmtrs[4],			// ACMTRS_NT
	acmtrs3[4];			// ACMTRS3_NT2

double	
	totaux,				// Sum of TOTAU_M
	acmamt,				// Sum of ACMAMT_M
	ank[65];			// array of 65 years

int	csm;				// boolean for write line or not

// Function for input file
int	n_InitCashFlow(T_RUPTURE_VAR *pbd_Rupt);
int	n_CondRuptCashFlow(char **ptb_InRec, char **ptb_InRec_Cur);
int	n_ActionFirstCashFlow(char **ptb_InRec);
int	n_ActionLineCashFlow(char **ptb_InRec);
int	n_ActionLastCashFlow(char **ptb_InRec);

// Specific function for this programme
static void n_AdditionAnk(char **ptb_InRec);

#endif