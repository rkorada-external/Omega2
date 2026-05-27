#ifndef ESTC2062_H
# define ESTC2062_H

// Header files
# include "utctlib.h"
# include "struct.h"
# include "estserv.h"

// Global variables
FILE            *Kp_PrevInFile;  
FILE            *Kp_PrevOut1File;
FILE            *Kp_PrevOut2File;

T_RUPTURE_VAR    bd_RuptPrev;

// Q: Quarterly file / Y: Yearly file
char Ksz_Mode[2];                

// Functions
int n_InitPrev(T_RUPTURE_VAR *pbd_Rupt);
int n_IsR1Prev(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRuptPrev(char **ptb_InRec_Cur);
int n_ActionLignePrev(char **pbd_InRec_Cur);


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
