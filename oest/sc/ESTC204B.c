/*==============================================================================
Application name         : Driving file format conversion from BCP to binary
source name              : ESTC204B.c
revision                 : $Revision: $
creation date            : 02/10/2019
author                   : L. Wernert
specifications reference : 
------------------------------------------------------------------------------
description :
	Converts driving file from BCP format to binary

------------------------------------------------------------------------------
Change history :
<jj/mm/aaaa>		<author>		<spot>		<description>
...           		...        ...          ...
==============================================================================*/

#include "ESTC204B.h"


int main(int argc, char *argv[])
{
	/* Initialisation des signaux */
	InitSig();

	if (n_BeginPgm(argc, argv) == ERR)
		ExitPgm(ERR_XX, "");

	strcpy(ksz_quarter, psz_GetCharArgv(1));
	
	if (n_OpenFileAppl("ESTC204B_I1", "rt", &Kp_PilotIFil) == ERR)
		ExitPgm(ERR_XX, "");

	if (n_OpenFileAppl("ESTC204B_O1", "wb", &Kp_PilotOFil) == ERR)
		ExitPgm(ERR_XX, "");
		
  if (n_InitPrev(&bd_RuptPrev))
		ExitPgm(ERR_XX, "");
	
  if (n_ProcessingRuptureVar(&bd_RuptPrev) == ERR)
		ExitPgm(ERR_XX, "");

	if (n_CloseFileAppl("ESTC204B_I1", &Kp_PilotIFil))
		ExitPgm(ERR_XX, "");
	
	if (n_CloseFileAppl("ESTC204B_O1", &Kp_PilotOFil))
		ExitPgm(ERR_XX, "");
	
	if (n_EndPgm() == ERR)
		ExitPgm(ERR_XX, "");

	exit(0) ;
}


int n_InitPrev(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_InitPrev");

	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

	if (n_OpenFileAppl("ESTC204B_I1", "rt", &(pbd_Rupt->pf_InputFil)))
		RETURN_VAL (ERR);

	pbd_Rupt->n_NbRupture = 0;
	if (ksz_quarter[0] == '0')
		pbd_Rupt->n_ActionLigne = n_loadDrivingYearly;
	else
		pbd_Rupt->n_ActionLigne = n_loadDrivingQuarterly;
		
	pbd_Rupt->c_Separ = '~';

	RETURN_VAL (0);
}

int n_loadDrivingYearly(char **ptb_InRec_Cur)
{
	
	T_LIFDRI_ALL bd_lu;
	
	DEBUT_FCT("n_loadDrivingYearly");
	memset(&bd_lu, 0, sizeof(bd_lu));
	
	strcpy(bd_lu.CTR_NF, ptb_InRec_Cur[CTR_NF]);
	
	bd_lu.END_NT = atoi(ptb_InRec_Cur[END_NT]);
	
	bd_lu.SEC_NF = atoi(ptb_InRec_Cur[SEC_NF]);
	
	bd_lu.UWY_NF = atoi(ptb_InRec_Cur[UWY_NF]);
	
	bd_lu.UW_NT = atoi(ptb_InRec_Cur[UW_NT]);
	
	strcpy(bd_lu.CRE_D, ptb_InRec_Cur[CRE_D]);
	
	bd_lu.BALSHEY_NF = atoi(ptb_InRec_Cur[BALSHEY_NF]);
	
	bd_lu.BALSHTMTH_NF = atoi(ptb_InRec_Cur[BALSHTMTH_NF]);
	
	bd_lu.ACY_NF = atoi(ptb_InRec_Cur[ACY_NF]);
	
	bd_lu.SSD_CF = atoi(ptb_InRec_Cur[SSD_CF]);
	
	bd_lu.AUTUPD_B = atoi(ptb_InRec_Cur[AUTUPD_B]);
	
	bd_lu.COMACC_B = atoi(ptb_InRec_Cur[COMACC_B]);
	
	bd_lu.CMT_NT = atoi(ptb_InRec_Cur[CMT_NT]);

	strcpy(bd_lu.CREUSR_CF, ptb_InRec_Cur[CREUSR_CF]);
	
	strcpy(bd_lu.LSTUPD_D, ptb_InRec_Cur[LSTUPD_D]);
	
	strcpy(bd_lu.LSTUPDUSR_CF, ptb_InRec_Cur[LSTUPDUSR_CF]);
	
	bd_lu.PROPAG_RES_B = atoi(ptb_InRec_Cur[PROPAG_RES_B]);
	
	bd_lu.SEGUPD_B = atoi(ptb_InRec_Cur[SEGUPD_B]);

	if (fwrite(&bd_lu, sizeof(T_LIFDRI_ALL), 1, Kp_PilotOFil) <= 0) RETURN_VAL(1);

	RETURN_VAL(0);
}


int n_loadDrivingQuarterly(char **ptb_InRec_Cur)
{
	
	T_LIFDRI_ALL_QUARTER bd_lu;
	
	DEBUT_FCT("n_loadDrivingQuarterly");
	memset(&bd_lu, 0, sizeof(bd_lu));
	
	strcpy(bd_lu.CTR_NF, ptb_InRec_Cur[CTR_NF_Q]);
	
	bd_lu.END_NT = atoi(ptb_InRec_Cur[END_NT_Q]);
	
	bd_lu.SEC_NF = atoi(ptb_InRec_Cur[SEC_NF_Q]);
	
	bd_lu.UWY_NF = atoi(ptb_InRec_Cur[UWY_NF_Q]);
	
	bd_lu.UW_NT = atoi(ptb_InRec_Cur[UW_NT_Q]);
	
	strcpy(bd_lu.CRE_D, ptb_InRec_Cur[CRE_D_Q]);
	
	bd_lu.BALSHEY_NF = atoi(ptb_InRec_Cur[BALSHEY_NF_Q]);
	
	bd_lu.BALSHTMTH_NF = atoi(ptb_InRec_Cur[BALSHTMTH_NF_Q]);
	
	bd_lu.ACY_NF = atoi(ptb_InRec_Cur[ACY_NF_Q]);
	
	bd_lu.ACM_NF = atoi(ptb_InRec_Cur[ACM_NF_Q]);
	
	bd_lu.SSD_CF = atoi(ptb_InRec_Cur[SSD_CF_Q]);

	bd_lu.AUTUPD_B = atoi(ptb_InRec_Cur[AUTUPD_B_Q]);
	
	bd_lu.COMACC_B = atoi(ptb_InRec_Cur[COMACC_B_Q]);
	
	bd_lu.CMT_NT = atoi(ptb_InRec_Cur[CMT_NT_Q]);
	
	strcpy(bd_lu.CREUSR_CF, ptb_InRec_Cur[CREUSR_CF_Q]);
	
	strcpy(bd_lu.LSTUPD_D, ptb_InRec_Cur[LSTUPD_D_Q]);
	
	strcpy(bd_lu.LSTUPDUSR_CF, ptb_InRec_Cur[LSTUPDUSR_CF_Q]);
	
	bd_lu.PROPAG_RES_B = atoi(ptb_InRec_Cur[PROPAG_RES_B_Q]);
	
	bd_lu.SEGUPD_B = atoi(ptb_InRec_Cur[SEGUPD_B_Q]);

	if (fwrite(&bd_lu, sizeof(T_LIFDRI_ALL_QUARTER), 1, Kp_PilotOFil) <= 0) RETURN_VAL(1);

	RETURN_VAL(0);
}