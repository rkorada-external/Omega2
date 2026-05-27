/*==============================================================================
application name		    : Aggregate CPLIFEST_MVT
file name						    : ESTC2169.c
revision						    : 
creation date				    : 19/08/2019
author							    : L. Wernert
specification reference	: http://dcvprdxwikiu/xwiki/wiki/omega/view/PROD/RU-EST-LIF-902395
basic skeleton					: batch
--------------------------------------------------------------------------------
Description :
	The purpose of this program is to aggregate the quarterly estimates into yearly estimates
	IMPORTANT : The input estimates must be in ascending order of ACM_NF => (3, 6, 9, 12) 
	            for each key 

--------------------------------------------------------------------------------
Modificaton history :
[000] <jj/mm/aaaa>   <author>    <description>
[001]  24/11/2020    B.LAGHA     aggregation selon la regle RU-EST-LIF-902395 
==============================================================================*/

/*----------------------------------------------------------------------------*/
/*                          Include header file                               */
/*----------------------------------------------------------------------------*/
#include "ESTC2169.h"

/*==============================================================================
Object:
	entry point of the program

Return:
	In case of problems, the program exit is performed by the function ExitPgm().
	else, by call system exit().

Param:
	argc -> number of arguments of program
	argv -> array of parameters
==============================================================================*/
int				main(int argc, char *argv[])
{
	// Init signal
	InitSig();

	// global variable in ESTC2169.h
	amount = 0;
	lastMthMvt = 0;
	if (n_BeginPgm(argc, argv) == ERR)
		ExitPgm(ERR_XX, "BeginPgm failed !");

	// Open output files
	if (n_OpenFileAppl("ESTC2169_I2", "rb", &Kp_Subtrs) == ERR)
		ExitPgm(ERR_XX, "Opening FSUBTRS file failed !");
	if (n_OpenFileAppl("ESTC2169_O1", "wt", &Kp_aggregate_LIFEST_Q) == ERR)
		ExitPgm(ERR_XX, "Opening output file failed !");

	// init struct rupture
	if (n_initLIFEST_Q(&bd_RuptLIFEST_Q) == ERR)
		ExitPgm(ERR_XX, "Init struct CPLIFEST_MVT failed !");

	// load subtrs file:
	if (n_ChargerTsubTRS(Kp_Subtrs) == ERR)
		ExitPgm(ERR_XX, "Load SUBTRS failed !");
	init_SubTrsLigne();

	// Start of treatment CPLIFEST_MVT
	if (n_ProcessingRuptureVar(&bd_RuptLIFEST_Q) == ERR)
		ExitPgm(ERR_XX, "Treatment failed !");

	// Close output files
	if (n_CloseFileAppl("ESTC2169_O1", &Kp_aggregate_LIFEST_Q))
		ExitPgm(ERR_XX, "Close output file failed !");

	if (n_EndPgm() == ERR)
		ExitPgm(ERR_XX, "EndPgm failed !");
	exit(0);
}

/*==============================================================================
Object:
	Init of the breaking management structure

Return:
	0 -> no error

Param:
	pbd_Rupt -> struct of breaking LIFEST_Q
==============================================================================*/
int				n_initLIFEST_Q(T_RUPTURE_VAR *pbd_Rupt)
{
	DEBUT_FCT("n_initLIFEST_Q");
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));
	if (n_OpenFileAppl("ESTC2169_I1", "rt", &(pbd_Rupt->pf_InputFil)))
		RETURN_VAL(ERR);
	pbd_Rupt->n_NbRupture = 1;
	pbd_Rupt->n_ConditionRupture[0] = n_CondRuptLIFEST_Q;
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptLIFEST_Q;
	pbd_Rupt->n_ActionLigne = n_ActionLineLIFEST_Q;
	pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptLIFEST_Q;
	pbd_Rupt->c_Separ = '~';
	RETURN_VAL(0);
}

/*==============================================================================
object:
	comparison between the contract of the current line and 
	the contract of the next line

return:
	ret = 0			-> no ruptur
	ret != 0		-> ruptur

Param:
	ptb_InRec		-> next line
	ptb_InRec_Cur	-> current line
==============================================================================*/
int				n_CondRuptLIFEST_Q(char **ptb_InRec, char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_CondRuptLIFEST_Q");

	int			ret = 0;

	if ((ret = strcmp(ptb_InRec[TLIFEST_CTR_NF], ptb_InRec_Cur[TLIFEST_CTR_NF])) != 0)
		RETURN_VAL(ret);
	if ((ret = strcmp(ptb_InRec[TLIFEST_SEC_NF], ptb_InRec_Cur[TLIFEST_SEC_NF])) != 0)
		RETURN_VAL(ret);
	if ((ret = strcmp(ptb_InRec[TLIFEST_UWY_NF], ptb_InRec_Cur[TLIFEST_UWY_NF])) != 0)
		RETURN_VAL(ret);
	if ((ret = strcmp(ptb_InRec[TLIFEST_ACY_NF], ptb_InRec_Cur[TLIFEST_ACY_NF])) != 0)
		RETURN_VAL(ret);
	if ((ret = strcmp(ptb_InRec[TLIFEST_ACMTRS_NT], ptb_InRec_Cur[TLIFEST_ACMTRS_NT])) != 0)
		RETURN_VAL(ret);
	if ((ret = strcmp(ptb_InRec[TLIFEST_DETTRNCOD_CF], ptb_InRec_Cur[TLIFEST_DETTRNCOD_CF])) != 0)
		RETURN_VAL(ret);
	if ((ret = strcmp(ptb_InRec[TLIFEST_GAAP_NF], ptb_InRec_Cur[TLIFEST_GAAP_NF])) != 0)
		RETURN_VAL(ret);
	RETURN_VAL(ret);
}

/*==============================================================================
object:
	This function is called for the first line of the break.
	If the TRSTYPE_CT is RESERVE(3)/DEPOSIT(4)/BALANCE(6) and the line is a beginning
	then set the amount to ESTMNT_M (cf aggregate rules)

return:
	0	-> no prob

Param:
	array of line father
==============================================================================*/
int n_ActionFirstRuptLIFEST_Q(char **ptb_InRec)
{
	int ret;

	amount = 0;
	ret = n_FindTsubTRS(&subtrsLine, ptb_InRec[TLIFEST_DETTRNCOD_CF]);
	if (subtrsLine.TRSTYPE_CT == 3 || subtrsLine.TRSTYPE_CT == 4 ||
		subtrsLine.TRSTYPE_CT == 6)
	{
		if (ptb_InRec[TLIFEST_ACMTRS_NT][3] == '4' &&
			atoi(ptb_InRec[TLIFEST_ESTMTH_NF]) == 3)
		{
			amount = atoi(ptb_InRec[TLIFEST_ESTMNT_M]);
		}
	}
	RETURN_VAL(0);
}

/*==============================================================================
object:
	This function is called for all line of the break.

return:
	0	-> no prob

Param:
	array of line father
==============================================================================*/
int n_ActionLineLIFEST_Q(char **ptb_InRec)
{
	int ret;

	ret = n_FindTsubTRS(&subtrsLine, ptb_InRec[TLIFEST_DETTRNCOD_CF]);
	if (subtrsLine.TRSTYPE_CT == 1 || subtrsLine.TRSTYPE_CT == 5)
	{
		amount += atof(ptb_InRec[TLIFEST_ESTMNT_M]);
	}
	RETURN_VAL(0);
}

/*==============================================================================
object:
	This function is called for the last line of the break.
	Call the sync for retrive the missing amount in CPLIFEST_MVT.
	Once the sync is finished we replace the amount of the line with the new amount.
	we can write line in output file.

return:
	0	-> no prob

Param:
	array of line father
==============================================================================*/
int n_ActionLastRuptLIFEST_Q(char **ptb_InRec)
{
	int ret;

	ret = n_FindTsubTRS(&subtrsLine, ptb_InRec[TLIFEST_DETTRNCOD_CF]);
	if (subtrsLine.TRSTYPE_CT == 3 || subtrsLine.TRSTYPE_CT == 4 ||
		subtrsLine.TRSTYPE_CT == 6)
	{
		if (ptb_InRec[TLIFEST_ACMTRS_NT][3] == '3')
		{
			amount = atof(ptb_InRec[TLIFEST_ESTMNT_M]);
		}
	}
	
	sprintf(newAmount, "%.3f", amount);
	ptb_InRec[TLIFEST_ESTMNT_M] = newAmount;
	ptb_InRec[TLIFEST_ESTMTH_NF] = "13";
	n_WriteCols(Kp_aggregate_LIFEST_Q, ptb_InRec, '~', 0);
	RETURN_VAL(0);
}

/*==============================================================================
object:
	This function init all variable in struct subtrs

return:
	no return

Param:
	no param
==============================================================================*/
static void init_SubTrsLigne(void)
{
	strcpy(subtrsLine.DETTRNCOD_CF, "");
	strcpy(subtrsLine.SUBTRS_GL,"");
	strcpy(subtrsLine.SUBTRS_GS,"");
	strcpy(subtrsLine.SUBTRSEXP_D,"");
	strcpy(subtrsLine.SUBTRSINC_D,"");
	strcpy(subtrsLine.LOGSIG_CT,"");
	strcpy(subtrsLine.LOB_CF,"");
	subtrsLine.CMT_NT =0;
	subtrsLine.TRSINPUTTYPE_CT = 0;
	subtrsLine.TRSNATURE_CT = 0 ;
	subtrsLine.TRSTYPE_CT = 0;
	subtrsLine.TRSPURERETRO_B = 0;
	subtrsLine.DACTYPE_B   = 0;
	subtrsLine.COMPLEMENT_B = 0;
	subtrsLine.NEWBALSHEETPROPAG_B = 0;
	subtrsLine.CELLPROTECEXC_B = 0;
}
