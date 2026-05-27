/*==============================================================================
application name				: Aggregate CPLIFEST_MVT
file name						: ESTC2167.c
revision						: 
create date						: 4/02/2019
autor							: R. Vieville
specification reference			: 
basic skeleton					: batch
--------------------------------------------------------------------------------
describe :
	The purpose of this programme is to aggregate the lines of CPLIFEST_MVT
	according to the spec define at this URL: 
		http://dcvprdxwikiu/xwiki/wiki/omega/view/PROD/RU-EST-LIF-902395	

--------------------------------------------------------------------------------
Change history :
==============================================================================*/

/*----------------------------------------------------------------------------*/
/*                          Include header file                               */
/*----------------------------------------------------------------------------*/
#include "ESTC2167.h"

/*==============================================================================
Object:
	entry point of the program

Return:
	In case of problems, the program exit is performed by the function ExitPgm().
	else, by call system exit().

Param:
	argc -> number of arguments of program
	argv -> array of parameters
[001] 25/11/2019 S.Behague :spira:91872 Apolo - TLIFESTD alimentée uniquement sur le quarter 4
[002] 12/05/2021 S.Behague :spira:91254 APOLO QE : GRID - Pas de beginning sur les postes de réserves pour ACY suivnant une ACY complete - Copy
==============================================================================*/
int				main(int argc, char *argv[])
{
	// Init signal
	InitSig();

	// global variable in ESTC2167.h
	amount_upd = 0;
	amount = 0;
	
	lastMthMvt = 0;
	if (n_BeginPgm(argc, argv) == ERR)
		ExitPgm(ERR_XX, "BeginPgm failed !");

	// Open output files
	if (n_OpenFileAppl("ESTC2167_I3", "rb", &Kp_Subtrs) == ERR)
		ExitPgm(ERR_XX, "Open FSUBTRS file failed !");
	if (n_OpenFileAppl("ESTC2167_O1", "wt", &Kp_aggregate_MVT) == ERR)
		ExitPgm(ERR_XX, "Open output file failed !");

	// init struct rupture
	if (n_initCPLIFEST_MVT(&bd_RuptCPLIFEST_MVT) == ERR)
		ExitPgm(ERR_XX, "Init struct CPLIFEST_MVT failed !");
	if (n_initCPLIFEST(&bd_RuptCPLIFEST) == ERR)
		ExitPgm(ERR_XX, "Init struct CPLIFEST failed !");

	// load subtrs file:
	if (n_ChargerTsubTRS(Kp_Subtrs) == ERR)
		ExitPgm(ERR_XX, "Load SUBTRS failed !");
	init_SubTrsLigne();

	// Start of treatment CPLIFEST_MVT
	if (n_ProcessingRuptureVar(&bd_RuptCPLIFEST_MVT) == ERR)
		ExitPgm(ERR_XX, "Treatment failed !");

	// Close output files
	if (n_CloseFileAppl("ESTC2167_O1", &Kp_aggregate_MVT))
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
	pbd_Rupt -> struct of breaking CPLIFEST_MVT
==============================================================================*/
int				n_initCPLIFEST_MVT(T_RUPTURE_VAR *pbd_Rupt)
{
	DEBUT_FCT("n_initCPLIFEST");
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));
	if (n_OpenFileAppl("ESTC2167_I1", "rt", &(pbd_Rupt->pf_InputFil)))
		RETURN_VAL(ERR);
	pbd_Rupt->n_NbRupture = 1;
	pbd_Rupt->n_ConditionRupture[0] = n_CondRuptCPLIFEST_MVT;
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptCPLIFEST_MVT;
	pbd_Rupt->n_ActionLigne = n_ActionLineCPLIFEST_MVT;
	pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptCPLIFEST_MVT;
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
int				n_CondRuptCPLIFEST_MVT(char **ptb_InRec, char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_CondRuptCPLIFEST_MVT");

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
	If contract is RESERVE(3)/DEPOSIT(4)/BALANCE(6) and the contract is begining
	set amount to ESTMNT_M (cf aggregate rules)

return:
	0	-> no prob

Param:
	array of line father
==============================================================================*/
int				n_ActionFirstRuptCPLIFEST_MVT(char **ptb_InRec)
{
	int			ret;

	amount = 0; amount_upd = 0;
	mois3 = 0;
	mois6 = 0;
	mois9 = 0;
	mois12 = 0;
	
	ret = n_FindTsubTRS(&subtrsLine, ptb_InRec[TLIFEST_DETTRNCOD_CF]);
	
	if (subtrsLine.TRSTYPE_CT == 3 || subtrsLine.TRSTYPE_CT == 4 ||
		subtrsLine.TRSTYPE_CT == 6)
	{
		if (ptb_InRec[TLIFEST_ACMTRS_NT][3] == '4' &&
			atoi(ptb_InRec[TLIFEST_ESTMTH_NF]) == 3)
		{
			amount = atoi(ptb_InRec[TLIFEST_ESTMNT_M]);
			amount_upd = 1;
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
int				n_ActionLineCPLIFEST_MVT(char **ptb_InRec)
{
	int			ret;

	ret = n_FindTsubTRS(&subtrsLine, ptb_InRec[TLIFEST_DETTRNCOD_CF]);
	
	mois3 += ( atoi(ptb_InRec[TLIFEST_ESTMTH_NF]) == 3 ) ? 3 : 0;
	mois6 += ( atoi(ptb_InRec[TLIFEST_ESTMTH_NF]) == 6 ) ? 6 : 0;	
	mois9 += ( atoi(ptb_InRec[TLIFEST_ESTMTH_NF]) == 9 ) ? 9 : 0;
	mois12 += ( atoi(ptb_InRec[TLIFEST_ESTMTH_NF]) == 12 ) ? 12 : 0;
		
		
	if (subtrsLine.TRSTYPE_CT == 1 || subtrsLine.TRSTYPE_CT == 5)
	{
		amount += atof(ptb_InRec[TLIFEST_ESTMNT_M]);
		amount_upd = 1;
	}

	n_WriteCols(Kp_aggregate_MVT, ptb_InRec, '~', 0);
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
int				n_ActionLastRuptCPLIFEST_MVT(char **ptb_InRec)
{
	lastMthMvt = atoi(ptb_InRec[TLIFEST_ESTMTH_NF]);

	n_ProcessingRuptureSyncVar(&bd_RuptCPLIFEST, ptb_InRec);

	if (amount_upd == 1)
	{
		sprintf(newAmount, "%.3f", amount);
		ptb_InRec[TLIFEST_ESTMNT_M] = newAmount;
		ptb_InRec[TLIFEST_ESTMTH_NF] = "13";

		n_WriteCols(Kp_aggregate_MVT, ptb_InRec, '~', 0);
	}
	RETURN_VAL(0);
}

/*==============================================================================
Object:
	Init of the breaking management structure

Return:
	0 -> no error

Param:
	pbd_Rupt -> struct of breaking CPLIFEST
==============================================================================*/
int				n_initCPLIFEST(T_RUPTURE_SYNC_VAR *pbd_Rupt)
{
	DEBUT_FCT("n_initCPLIFEST");
	
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR));
	n_OpenFileAppl ("ESTC2167_I2","rt",&(pbd_Rupt->pf_InputFil));
	pbd_Rupt->n_NbRupture = 1;
	pbd_Rupt->n_ConditionRupture[0] = n_ConditionRuptCPLIFEST;
	pbd_Rupt->ConditionEndSync = n_ConditionSyncCPLIFEST;
	pbd_Rupt->n_ActionLigne = n_ActionRuptCPLIFEST;
	pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptCPLIFEST;
	pbd_Rupt->n_ActionFirst[0] = n_ActionLastRuptCPLIFEST;
	pbd_Rupt->c_Separ = '~' ;
	RETURN_VAL(0);
}

/*==============================================================================
object:
	comparison between the contract of the current line in slave file and 
	the contract of the last line in naster file

return:
	no return

Param:
	ptb_InRecOwner -> master file (CPLIFEST_MVT)
	ptb_InRecChild -> slave file (CPLIFEST)
==============================================================================*/
int				n_ConditionSyncCPLIFEST(char **ptb_InRecOwner, char **ptb_InRecChild)
{
	DEBUT_FCT("n_ConditionSyncCPLIFEST");

	int			ret;

	if ((ret = strcmp(ptb_InRecOwner[TLIFEST_CTR_NF], ptb_InRecChild[TLIFEST_CTR_NF])) != 0)
		return (ret);
	if ((ret = strcmp(ptb_InRecOwner[TLIFEST_SEC_NF], ptb_InRecChild[TLIFEST_SEC_NF])) != 0)
		return (ret);
	if ((ret = strcmp(ptb_InRecOwner[TLIFEST_UWY_NF], ptb_InRecChild[TLIFEST_UWY_NF])) != 0)
		return (ret);
	if ((ret = strcmp(ptb_InRecOwner[TLIFEST_ACY_NF], ptb_InRecChild[TLIFEST_ACY_NF])) != 0)
		return (ret);
	if ((ret = strcmp(ptb_InRecOwner[TLIFEST_ACMTRS_NT], ptb_InRecChild[TLIFEST_ACMTRS_NT])) != 0)
		return (ret);
	if ((ret = strcmp(ptb_InRecOwner[TLIFEST_DETTRNCOD_CF], ptb_InRecChild[TLIFEST_DETTRNCOD_CF])) != 0)
		return (ret);
	if ((ret = strcmp(ptb_InRecOwner[TLIFEST_GAAP_NF], ptb_InRecChild[TLIFEST_GAAP_NF])) != 0)
		return (ret);
	return (ret);
}

/*==============================================================================
object:
	comparison between the contract of the current line in slave file and 
	the contract of the last line in naster file

return:
	ret = 0 -> no ruptur
	ret != 0 -> ruptur

Param:
	ptb_InRecOwner -> master file (CPLIFEST_MVT)
	ptb_InRecChild -> slave file (CPLIFEST)
==============================================================================*/
int				n_ConditionRuptCPLIFEST(char **ptb_InRecOwner, char **ptb_InRecChild)
{
	DEBUT_FCT("n_ConditionRuptCPLIFEST");
	int			ret;

	if ((ret = strcmp(ptb_InRecOwner[TLIFEST_CTR_NF], ptb_InRecChild[TLIFEST_CTR_NF])) != 0)
		return (ret);
	if ((ret = strcmp(ptb_InRecOwner[TLIFEST_SEC_NF], ptb_InRecChild[TLIFEST_SEC_NF])) != 0)
		return (ret);
	if ((ret = strcmp(ptb_InRecOwner[TLIFEST_UWY_NF], ptb_InRecChild[TLIFEST_UWY_NF])) != 0)
		return (ret);
	if ((ret = strcmp(ptb_InRecOwner[TLIFEST_ACY_NF], ptb_InRecChild[TLIFEST_ACY_NF])) != 0)
		return (ret);
	if ((ret = strcmp(ptb_InRecOwner[TLIFEST_ACMTRS_NT], ptb_InRecChild[TLIFEST_ACMTRS_NT])) != 0)
		return (ret);
	if ((ret = strcmp(ptb_InRecOwner[TLIFEST_DETTRNCOD_CF], ptb_InRecChild[TLIFEST_DETTRNCOD_CF])) != 0)
		return (ret);
	if ((ret = strcmp(ptb_InRecOwner[TLIFEST_GAAP_NF], ptb_InRecChild[TLIFEST_GAAP_NF])) != 0)
		return (ret);
	return (ret);
}

/*==============================================================================
object:
	This function is called for each line sync with CPLIFEST_MVT
	Addes ESTMTNT to previous value if the month is less than
	last month in CPLIFEST_MVT and if contract is CASH(1) or FLOW(5)

return:
	ret = 0 -> no prob

Param:
	ptb_InRecOwner -> master file (CPLIFEST_MVT)
	ptb_InRecChild -> slave file (CPLIFEST)
==============================================================================*/
int				n_ActionRuptCPLIFEST(char **ptb_InRecOwner, char **ptb_InRecChild)
{

	//if (lastMthMvt < atoi(ptb_InRecChild[TLIFEST_ESTMTH_NF]))
	//{
		int			ret;
		double amountToAdd = 0;
		
		ret = n_FindTsubTRS(&subtrsLine, ptb_InRecChild[TLIFEST_DETTRNCOD_CF]);
		amountToAdd = 0;
		if (subtrsLine.TRSTYPE_CT == 1 || subtrsLine.TRSTYPE_CT == 5)
		{
			if ( atoi(ptb_InRecChild[TLIFEST_ESTMTH_NF]) == 3 )
				amountToAdd = ( mois3 == atoi(ptb_InRecChild[TLIFEST_ESTMTH_NF]) ) ? 0 : atof(ptb_InRecChild[TLIFEST_ESTMNT_M]);

			if ( atoi(ptb_InRecChild[TLIFEST_ESTMTH_NF]) == 6 )
				amountToAdd = ( mois6 == atoi(ptb_InRecChild[TLIFEST_ESTMTH_NF]) ) ? 0 : atof(ptb_InRecChild[TLIFEST_ESTMNT_M]);

			if ( atoi(ptb_InRecChild[TLIFEST_ESTMTH_NF]) == 9 )
				amountToAdd = ( mois9 == atoi(ptb_InRecChild[TLIFEST_ESTMTH_NF]) ) ? 0 : atof(ptb_InRecChild[TLIFEST_ESTMNT_M]);

			if ( atoi(ptb_InRecChild[TLIFEST_ESTMTH_NF]) == 12 )
				amountToAdd = ( mois12 == atoi(ptb_InRecChild[TLIFEST_ESTMTH_NF]) ) ? 0 : atof(ptb_InRecChild[TLIFEST_ESTMNT_M]);

			//amount += atof(ptb_InRecChild[TLIFEST_ESTMNT_M]);
			
			amount += amountToAdd;
			amount_upd = 1;
			
		}
	//}
	return (0);
}

/*==============================================================================
object:
	This function is called for the first line sync with CPLIFEST_MVT
	Set amount to ESTMNT of 1th quarter if contract is RESER(3)/DEPO(4)/BALAMCE(6)

return:
	ret = 0 -> no prob

Param:
	ptb_InRecOwner -> master file (CPLIFEST_MVT)
	ptb_InRecChild -> slave file (CPLIFEST)
==============================================================================*/
int				n_ActionFirstRuptCPLIFEST(char **ptb_InRecOwner, char **ptb_InRecChild)
{
	int			ret;

	ret = n_FindTsubTRS(&subtrsLine, ptb_InRecChild[TLIFEST_DETTRNCOD_CF]);
	if (subtrsLine.TRSTYPE_CT == 3 || subtrsLine.TRSTYPE_CT == 4 ||
		subtrsLine.TRSTYPE_CT == 6)
	{
		amount = 0;
		if (ptb_InRecChild[TLIFEST_ACMTRS_NT][3] == '4' &&
			atoi(ptb_InRecChild[TLIFEST_ESTMTH_NF]) == 3)
		{
			amount = atoi(ptb_InRecChild[TLIFEST_ESTMNT_M]);
			amount_upd = 1;
		}
	}
	RETURN_VAL(0);

}

/*==============================================================================
object:
	This function is called for the last line sync with CPLIFEST_MVT
	Set amount to ESTMNT of 4th quarter if contract is RESER(3)/DEPO(4)/BALAMCE(6)

return:
	0 -> no prob

Param:
	ptb_InRecOwner -> master file (CPLIFEST_MVT)
	ptb_InRecChild -> slave file (CPLIFEST)
==============================================================================*/
int				n_ActionLastRuptCPLIFEST(char **ptb_InRecOwner, char **ptb_InRecChild)
{
	int			ret;
		
	ret = n_FindTsubTRS(&subtrsLine, ptb_InRecChild[TLIFEST_DETTRNCOD_CF]);

	if (subtrsLine.TRSTYPE_CT == 3 || subtrsLine.TRSTYPE_CT == 4 ||
		subtrsLine.TRSTYPE_CT == 6)
	{
		//amount = 0;
		if (ptb_InRecChild[TLIFEST_ACMTRS_NT][3] == '3' &&
			atoi(ptb_InRecChild[TLIFEST_ESTMTH_NF]) == 12)
		{
			amount = 0;  // Si libération, on ne remet pas à zéro, car on garde le 1er trimestre pour l'agrégat TLIFEST
		  amount = atof(ptb_InRecChild[TLIFEST_ESTMNT_M]);
			amount_upd = 1;
		}
	}
	return (0);
}

/*==============================================================================
object:
	This function init all variable in struct subtrs

return:
	no return

Param:
	no param
==============================================================================*/
static void		init_SubTrsLigne(void)
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
