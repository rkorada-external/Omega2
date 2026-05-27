/*==============================================================================
application name				: Reformat CPLACC and LSTMTH file 
file name						: ESTC2054.c
revision						: 
create date						: 22/01/2019
autor							: R. Vieville
specification reference			: 
basic skeleton					: batch
--------------------------------------------------------------------------------
describe :
	for each contract in EST_FCPLACC0 and EST_FLSTMTH
	get only one line with month equal to 12 in the case to yaerly and
	in the case of qyarterly only one line with the biggest month between
	3, 6, 9 and 12. For that we need to now code crible so we synchronize
	with IARVPERICASE4


--------------------------------------------------------------------------------
Change history :
==============================================================================*/

/*----------------------------------------------------------------------------*/
/*                        Include interface component                         */
/*----------------------------------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>

/*----------------------------------------------------------------------------*/
/*                             Global Variable                                */
/*----------------------------------------------------------------------------*/

FILE				*Kp_CPLACC;				// pointer to the output file CPLACC
FILE				*Kp_LSTMTH;				// pointer to the output file LSTMTH

T_RUPTURE_VAR		bd_RuptPERI;			// manage ruptur PERICASE

T_RUPTURE_SYNC_VAR	bd_RuptCPL;				// manage syncro CPLACC
T_RUPTURE_SYNC_VAR	bd_RuptLST;				// manage syncro LSTMTH

int					Kb_SyncCPL;				// indicator sycro CPLACC
int					Kb_SyncLST;				// indicator sycro LSTMTH

/*----------------------------------------------------------------------------*/
/*                             Function in file                               */
/*----------------------------------------------------------------------------*/
// function for PERICASE
int				n_initPERI(T_RUPTURE_VAR *pbd_Rupt);
int				n_CondRuptPERI(char **ptb_InRec, char **ptb_InRec_Cur);
int				n_ActionLastRuptPERI(char **ptb_InRec);

// function for CPLACC
int				n_initCPLACC(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int				n_ConditionRuptCPL(char **ptb_InRec, char **ptb_InRec_Cur);
int				n_ActionFirstRuptCPL(char **ptb_InRecOwner, char **ptb_InRecChild);
int				n_ConditionSyncCPL(char **pbd_InRecOwner, char **pbd_InRecChild);

// function for CPLACC
int				n_initLSTMTH(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int				n_ConditionRuptLST(char **ptb_InRec, char **ptb_InRec_Cur);
int				n_ActionFirstRuptLST(char **ptb_InRecOwner, char **ptb_InRecChild);
int				n_ConditionSyncLST(char **pbd_InRecOwner, char **pbd_InRecChild);

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
	if (n_BeginPgm(argc, argv) == ERR)
		ExitPgm(ERR_XX, "");

	// Open output files
	if (n_OpenFileAppl("ESTC2054_O1", "wt", &Kp_CPLACC) == ERR)
		ExitPgm(ERR_XX, "");
	if (n_OpenFileAppl("ESTC2054_O2", "wt", &Kp_LSTMTH) == ERR)
		ExitPgm(ERR_XX, "");

	// init struct rupture
	if (n_initCPLACC(&bd_RuptCPL))
		ExitPgm(ERR_XX, "");
	if (n_initLSTMTH(&bd_RuptLST))
		ExitPgm(ERR_XX, "");
	if (n_initPERI(&bd_RuptPERI))
		ExitPgm(ERR_XX, "");

	// Start of treatment CPLACC
	if (n_ProcessingRuptureVar(&bd_RuptPERI) == ERR)
		ExitPgm(ERR_XX, "");

	// Close output files
	if (n_CloseFileAppl("ESTC2054_O1", &Kp_CPLACC))
		ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl("ESTC2054_O2", &Kp_LSTMTH))
		ExitPgm(ERR_XX, "");

	if (n_EndPgm() == ERR)
		ExitPgm(ERR_XX, "");
	exit(0);
}

/*==============================================================================
object:
	Init of the breaking management structure

return:
	0	-> no error

Param:
	pbd_Rupt -> struct of breaking
==============================================================================*/
int				n_initPERI(T_RUPTURE_VAR *pbd_Rupt)
{
	DEBUT_FCT("n_initCPLACC");
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));
	if (n_OpenFileAppl("ESTC2054_I1", "rt", &(pbd_Rupt->pf_InputFil)))
		RETURN_VAL(ERR);
	pbd_Rupt->n_NbRupture = 1;
	pbd_Rupt->n_ConditionRupture[0] = n_CondRuptPERI;
	pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptPERI;
	pbd_Rupt->c_Separ = '~';
	RETURN_VAL(0);
}

/*==============================================================================
object:
	comparison between the contract of the current line and 
	the contract of the next line

return:
	0	-> no ruptur
	1	-> ruptur

Param:
	ptb_InRec		-> next line
	ptb_InRec_Cur	-> current line
==============================================================================*/
int				n_CondRuptPERI(char **ptb_InRec, char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_CondRuptPERI");
	if (strcmp(ptb_InRec[PER_CTR_NF], ptb_InRec_Cur[PER_CTR_NF]) != 0)
		RETURN_VAL(1);
	RETURN_VAL(0);
}

/*==============================================================================
object:
	action breaking in father file
	call syncro and init variable syncro to 0

return:
	0	-> no prob

Param:
	array of line father
==============================================================================*/
int				n_ActionLastRuptPERI(char **ptb_InRec)
{
	Kb_SyncCPL = 0;
	Kb_SyncLST = 0;
	n_ProcessingRuptureSyncVar(&bd_RuptCPL, ptb_InRec);
	n_ProcessingRuptureSyncVar(&bd_RuptLST, ptb_InRec);
	return (0);
}

/*==============================================================================
object:
	Init of the syncro management structure

return:
	0	-> ok
	ERR	-> open file fail 

Param:
	struct of syncro
==============================================================================*/
int				n_initCPLACC(T_RUPTURE_SYNC_VAR *pbd_Rupt)
{
	DEBUT_FCT("n_initCPL");
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR));
	if (n_OpenFileAppl("ESTC2054_I2", "rt", &(pbd_Rupt->pf_InputFil)))
		RETURN_VAL(ERR);
	pbd_Rupt->n_NbRupture = 1;
	pbd_Rupt->n_ConditionRupture[0] = n_ConditionRuptCPL;
	pbd_Rupt->ConditionEndSync = n_ConditionSyncCPL;
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptCPL;
	pbd_Rupt->c_Separ = '~' ;
	RETURN_VAL(0);
}

/*==============================================================================
object:
	Breaking if CTR current line and CTR next line != or ACY current line and
	ACY next line !=

return:
	ret	-> difference between current line and next line (strcmp)

Param:
	ptb_InRec		-> next line
	ptb_InRec_Cur	-> current line
==============================================================================*/
int				n_ConditionRuptCPL(char **ptb_InRec, char **ptb_InRec_Cur)
{
	int			ret;

	DEBUT_FCT("n_ConditionRuptCPL");
	if ((ret = strcmp(ptb_InRec[CMP_CTR_NF], ptb_InRec_Cur[CMP_CTR_NF])) != 0)
		RETURN_VAL(ret);
	if ((ret = strcmp(ptb_InRec[CMP_ACY_NF], ptb_InRec_Cur[CMP_ACY_NF])) != 0)
		RETURN_VAL(ret);
	RETURN_VAL(0);
}

/*==============================================================================
object:
	Syncro with CPLACC file, compare contract between IARVPERICASE4 and
	EST_FCPLACC0

return:
	ret	-> difference between current line and next line (strcmp)

Param:
	ptb_InRecOwner		-> father file (IARVPERICASE4)
	ptb_InRecChild		-> child file (EST_FCPLACC0)
==============================================================================*/
int				n_ConditionSyncCPL(char **pbd_InRecOwner, char **pbd_InRecChild)
{
	int			ret;

	DEBUT_FCT("n_ConditionSyncCPL");
	if ((ret = strcmp(pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[CMP_CTR_NF])) != 0)
		RETURN_VAL(ret);
	RETURN_VAL(0);
}

/*==============================================================================
object:
	if contract is not quarterly (code crible different of T and U)
	check if month equal 12 (the SORT befor this program save all line with
	month 3, 6, 9 or 12 and we want save only month 12 for yearly contract).
	Kb_SyncLST is used for write only the first line.
	if contract is quarterly write line because we want save the biggest month
	between 3, 6, 9 and 12 (cf SORT int step 145 and 146)

return:
	0	-> no problem

Param:
	ptb_InRecOwner		-> father file (IARVPERICASE4)
	ptb_InRecChild		-> child file (EST_FCPLACC0)
==============================================================================*/
int				n_ActionFirstRuptCPL(char **ptb_InRecOwner, char **ptb_InRecChild)
{
	DEBUT_FCT("n_ActionFirstRuptCPL");
	if (ptb_InRecOwner[PER_ESTCRB_CT][0] != 'T' && ptb_InRecOwner[PER_ESTCRB_CT][0] != 'U')
	{
		if (Kb_SyncCPL == 0 && atoi(ptb_InRecChild[CMP_SCOENDMTH_NF]) == 12)
		{
			Kb_SyncCPL = 1;
			n_WriteCols(Kp_CPLACC, ptb_InRecChild, SEPARATEUR, 0);
		}
	}
	else
	{
		Kb_SyncCPL = 1;
		n_WriteCols(Kp_CPLACC, ptb_InRecChild, SEPARATEUR, 0);
	}
	RETURN_VAL(0);
}

/*==============================================================================
object:
	Init of the syncro management structure

return:
	0	-> ok
	ERR	-> open file fail 

Param:
	struct of syncro
==============================================================================*/
int				n_initLSTMTH(T_RUPTURE_SYNC_VAR *pbd_Rupt)
{
	DEBUT_FCT("n_initLSTMTH");
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR));
	if (n_OpenFileAppl("ESTC2054_I3", "rt", &(pbd_Rupt->pf_InputFil)))
		RETURN_VAL(ERR);
	pbd_Rupt->n_NbRupture = 1;
	pbd_Rupt->n_ConditionRupture[0] = n_ConditionRuptLST;
	pbd_Rupt->ConditionEndSync = n_ConditionSyncLST;
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptLST;
	pbd_Rupt->c_Separ = '~' ;
	RETURN_VAL(0);
}

/*==============================================================================
object:
	breaking between EST_FLSTMTH and PERICASE4 if contract or ACY is different
	between current line and next line in EST_FLSTMTH

return:
	ret	-> difference between current line and next line (strcmp)

Param:
	ptb_InRec		-> next line in EST_FLSTMTH
	ptb_InRec_Cur	-> current line in EST_FLSTMTH
==============================================================================*/
int				n_ConditionRuptLST(char **ptb_InRec, char **ptb_InRec_Cur)
{
	int			ret;

	DEBUT_FCT("n_ConditionRuptLST");
	if ((ret = strcmp(ptb_InRec[MTH_RETCTR_NF], ptb_InRec_Cur[MTH_RETCTR_NF])) != 0)
		RETURN_VAL(ret);
	if ((ret = strcmp(ptb_InRec[MTH_RETACCYER_NF], ptb_InRec_Cur[MTH_RETACCYER_NF])) != 0)
		RETURN_VAL(ret);
	RETURN_VAL(0);
}

/*==============================================================================
object:
	Condition syncro between IARVPERICASE4 and EST_FLSTMTH if contract is
	different

return:
	ret	-> difference between father contract and child contract (strcmp)
	
Param:
	ptb_InRecOwner		-> father file (IARVPERICASE4)
	ptb_InRecChild		-> child file (EST_FLSTMTH)
==============================================================================*/
int				n_ConditionSyncLST(char **pbd_InRecOwner, char **pbd_InRecChild)
{
	int			ret;

	DEBUT_FCT("n_ConditionSyncLST");
	if ((ret = strcmp(pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[MTH_RETCTR_NF])) != 0)
		RETURN_VAL(ret);
	RETURN_VAL(0);
}

/*==============================================================================
object:
	if contract is not quarterly (code crible different of T and U)
	check if month equal 12 (the SORT befor this program save all line with
	month 3, 6, 9 or 12 and we want save only month 12 for yearly contract).
	Kb_SyncLST is used for write only the first line.
	if contract is quarterly write line because we want save the biggest month
	between 3, 6, 9 and 12 (cf SORT int step 145 and 146)

return:
	0	-> no prob

Param:
	ptb_InRecOwner		-> father file (IARVPERICASE4)
	ptb_InRecChild		-> child file (EST_FLSTMTH)
==============================================================================*/
int				n_ActionFirstRuptLST(char **ptb_InRecOwner, char **ptb_InRecChild)
{
	DEBUT_FCT("n_ActionFirstRuptLST");
	if (ptb_InRecOwner[PER_ESTCRB_CT][0] != 'T' && ptb_InRecOwner[PER_ESTCRB_CT][0] != 'U')
	{
		if (Kb_SyncLST == 0 && atoi(ptb_InRecChild[MTH_LSTENDMTH_NF]) == 12)
		{
			Kb_SyncLST = 1;
			n_WriteCols(Kp_LSTMTH, ptb_InRecChild, SEPARATEUR, 0);
		}
	}
	else
	{
		Kb_SyncLST = 1;
		n_WriteCols(Kp_LSTMTH, ptb_InRecChild, SEPARATEUR, 0);
	}
	RETURN_VAL(0);
}
