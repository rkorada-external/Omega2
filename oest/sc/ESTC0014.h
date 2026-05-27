#ifndef __DELTA
#define __DELTA


#define DIF_SSD_CF 		0
#define DIF_CTR_NF 		1
#define DIF_END_NT 		2
#define DIF_SEC_NF 		3
#define DIF_UWY_NF 		4
#define DIF_UW_NT  		5
#define DIF_ACMTRS_NT 	6
#define DIF_TYPMNT_CT 	7
#define DIF_CUR_CF 		8
#define DIF_RETAMT_M 		9
#define DIF_AMT_M 		10
#define DIF_SSDS_CF		11



T_RUPTURE_VAR Kbd_ruptDIFGTRGTA;

int n_InitDIFGTRGTA(T_RUPTURE_VAR *pbd_Rupt);
int n_IsR1DIFGTRGTA(char **pbd_InRec, char **pbd_InRec_Cur);
int n_ActionF1DIFGTRGTA(char **pbd_InRec_Cur);
int n_ActionL1DIFGTRGTA(char **pbd_InRec_Cur);
int n_ActionLigneDIFGTRGTA(char **pbd_InRec_Cur);

FILE *Kp_OutputFileDiffGTAGTR;


#endif 
