#ifndef ESTC204B_H
#define ESTC204B_H

// Header files
#include "utctlib.h"
#include "struct.h"

FILE		*Kp_PilotIFil,
				*Kp_PilotOFil;	

char ksz_quarter[2];

T_RUPTURE_VAR bd_RuptPrev; 

int n_InitPrev(T_RUPTURE_VAR *pbd_Rupt);
int n_loadDrivingQuarterly(char **ptb_InRec_Cur);
int n_loadDrivingYearly(char **ptb_InRec_Cur);


// Enums
enum TLIFDRI_ALL_COLS {
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	CRE_D,
	BALSHEY_NF,
	BALSHTMTH_NF,
	ACY_NF,
	SSD_CF,
	AUTUPD_B,
	COMACC_B,
	CMT_NT,
	CREUSR_CF,
	LSTUPD_D,
	LSTUPDUSR_CF,
	PROPAG_RES_B,
	SEGUPD_B
} TY;

enum TLIFDRI_QUARTER_COLS {
	CTR_NF_Q,
	END_NT_Q,
	SEC_NF_Q,
	UWY_NF_Q,
	UW_NT_Q,
	CRE_D_Q,
	BALSHEY_NF_Q,
	BALSHTMTH_NF_Q,
	ACY_NF_Q,
	ACM_NF_Q,
	SSD_CF_Q,
	AUTUPD_B_Q,
	COMACC_B_Q,
	CMT_NT_Q,
	CREUSR_CF_Q,
	LSTUPD_D_Q,
	LSTUPDUSR_CF_Q,
	PROPAG_RES_B_Q,
	SEGUPD_B_Q
} TQ;

#endif
