/*==============================================================================
application name				: Aggregate LIFDRID
file name						: ESTC2168.c
revision						: 
create date						: 4/02/2019
autor							: R. Vieville
specification reference			: 
basic skeleton					: batch
--------------------------------------------------------------------------------
describe :
	The purpose of this programme is to aggregate the lines of CPLIFDRID befor
	insert into TLIFDRI

--------------------------------------------------------------------------------
Change history :
==============================================================================*/

/*----------------------------------------------------------------------------*/
/*                          Include header file                               */
/*----------------------------------------------------------------------------*/
#include "ESTC2168.h"

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

	//printf("%s\n", psz_GetCharArgv(1));
	// global variable in ESTC2168.h
	if (n_BeginPgm(argc, argv) == ERR)
		ExitPgm(ERR_XX, "BeginPgm failed !");

//	nbLines = 0;
	strcpy(cre_d, psz_GetCharArgv(1));
	// Open output files
	if (n_OpenFileAppl("ESTC2168_O1", "wt", &Kp_aggregate_LIFDRI) == ERR)
		ExitPgm(ERR_XX, "Open LIFDRI file failed !");

	// init struct rupture
	if (n_initLIFDRI(&bd_RuptLIFDRI) == ERR)
		ExitPgm(ERR_XX, "Init struct LIFDRI failed !");

	// Start of treatment LIFDRI
	if (n_ProcessingRuptureVar(&bd_RuptLIFDRI) == ERR)
		ExitPgm(ERR_XX, "Treatment failed !");

	// Close output files
	if (n_CloseFileAppl("ESTC2168_O1", &Kp_aggregate_LIFDRI))
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
	pbd_Rupt -> struct of breaking LIFDRI
==============================================================================*/
int				n_initLIFDRI(T_RUPTURE_VAR *pbd_Rupt)
{
	DEBUT_FCT("n_initLIFDRI");
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));
	if (n_OpenFileAppl("ESTC2168_I1", "rt", &(pbd_Rupt->pf_InputFil)))
		RETURN_VAL(ERR);
	pbd_Rupt->n_NbRupture = 1;
	pbd_Rupt->n_ConditionRupture[0] = n_CondRuptLIFDRI;
	pbd_Rupt->n_ActionLigne = n_ActionLineLIFDRI;
	pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptLIFDRI;
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
int				n_CondRuptLIFDRI(char **ptb_InRec, char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_CondRuptCPLIFEST_MVT");

	int			ret = 0;

	if ((ret = strcmp(ptb_InRec[LIFDRI_CTR_NF], ptb_InRec_Cur[LIFDRI_CTR_NF])) != 0)
		RETURN_VAL(ret);
	if ((ret = strcmp(ptb_InRec[LIFDRI_SEC_NF], ptb_InRec_Cur[LIFDRI_SEC_NF])) != 0)
		RETURN_VAL(ret);
	if ((ret = strcmp(ptb_InRec[LIFDRI_UWY_NF], ptb_InRec_Cur[LIFDRI_UWY_NF])) != 0)
		RETURN_VAL(ret);
	RETURN_VAL(ret);
}

/*==============================================================================
object:
	This function is called for all line of the break.
	incriease variable nbLine for know if 

return:
	0	-> no prob

Param:
	array of line father
==============================================================================*/
int				n_ActionLineLIFDRI(char **ptb_InRec)
{
//	nbLines++;
	RETURN_VAL(0);
}

/*==============================================================================
object:
	This function is called for the last line of the break.

return:
	0	-> no prob

Param:
	array of line father
==============================================================================*/
int				n_ActionLastRuptLIFDRI(char **ptb_InRec)
{
	if (atoi(ptb_InRec[LIFDRI_ACM_NF]) == 12)
	{
		char	new_cre_d[20];

		sprintf(new_cre_d, "%s %s", cre_d, "23:59:10");
		ptb_InRec[LIFDRI_CRE_D] = new_cre_d;
		n_WriteCols(Kp_aggregate_LIFDRI, ptb_InRec, '~', 0);
	}
//	nbLines = 0;
	RETURN_VAL(0);
}
