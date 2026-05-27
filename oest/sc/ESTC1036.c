/*==============================================================================
nom de l'application          : Remove quarterly
nom du source                 : ESTC1036.c
revision                      : $Revision: 1.0 $
date de creation              : 05/08/2019
auteur                        : Rafael vieivlle
references des specifications : 
squelette de base             : batch
------------------------------------------------------------------------------
description :
   Remove quarterly row in FLIFESTY0

------------------------------------------------------------------------------
historique des modifications :
==============================================================================*/

#include "ESTC1036.h" 

/*==============================================================================
objet :
	Entry point of the program

Return:
	In case of problems, the program exit is performed by the function ExitPgm().
	else, by call system exit().

Param:
	argc -> number of arguments of program
	argv -> array of parameters
==============================================================================*/
int		main(int argc, char *argv[])
{
	/* Initialisation des signaux */
	InitSig();

	if (n_BeginPgm(argc, argv) == ERR)
		ExitPgm(ERR_XX, "");

	// Open output file
	if (n_OpenFileAppl("ESTC1036_O1", "wt", &Kp_outputLIFEST) == ERR)
		ExitPgm(ERR_XX, "Open FLIFESTY0 failed !");

	// init LIFEST file (master)
	if (n_initLIFEST(&bd_RuptLIFEST) == ERR)
		ExitPgm(ERR_XX, "Init LIFEST failed !");

	// init PERICASE file (slave)
	if (n_initPERICASE(&bd_RuptPERICASE) == ERR)
		ExitPgm(ERR_XX, "Init PERICASE failed !");

	/* lancement du traitement du fichier Perimetre de souscription IADPERICASE.dat */
	if (n_ProcessingRuptureVar(&bd_RuptLIFEST) == ERR)
		ExitPgm(ERR_XX, "");

	if (n_CloseFileAppl("ESTC1036_O1", &(bd_RuptLIFEST.pf_InputFil)) == ERR)
		ExitPgm(ERR_XX, "");

	exit(0) ;
}

/*==============================================================================
objet :
	Init of the ruptur management structure

Return:
	0 -> no error
Param:
	pbd_Rupt -> struct of ruptur LIFEST
==============================================================================*/

int				n_initLIFEST(T_RUPTURE_VAR *pbd_Rupt)
{
	DEBUT_FCT("n_initLIFEST");
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));
	if (n_OpenFileAppl("ESTC1036_I1", "rt", &(pbd_Rupt->pf_InputFil)))
		RETURN_VAL(ERR);
	pbd_Rupt->n_NbRupture = 1;
	pbd_Rupt->n_ConditionRupture[0] = n_CondRuptLIFEST;
	pbd_Rupt->n_ActionLigne = n_ActionLineLIFEST;
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstLIFEST;
	pbd_Rupt->c_Separ = '~';
	RETURN_VAL(0);
}

/*==============================================================================
objet :
	comparison between the contract of the current line and 
	the contract of the next line

Return:
	ret = 0			-> no ruptur
	ret != 0		-> ruptur

Param:
	ptb_InRec		-> next line
	ptb_InRec_Cur	-> current line
==============================================================================*/
int				n_CondRuptLIFEST(char **ptb_InRec, char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_CondRuptLIFEST");

	int			ret = 0;

	if ((ret = strcmp(ptb_InRec[PRE_CTR_NF], ptb_InRec_Cur[PRE_CTR_NF])) != 0)
		RETURN_VAL(ret);
	if ((ret = strcmp(ptb_InRec[PRE_SEC_NF], ptb_InRec_Cur[PRE_SEC_NF])) != 0)
		RETURN_VAL(ret);
	RETURN_VAL(ret);
}

/*==============================================================================
objet :
	Action for the first line in ruptur.
	Call syncro with PERICASE (slave) for get code crible.

Return:
	0 -> no prob

Param:
	ptb_InRec -> current line (master)
==============================================================================*/

int				n_ActionFirstLIFEST(char **ptb_InRec)
{
	n_ProcessingRuptureSyncVar(&bd_RuptPERICASE, ptb_InRec);
	return (0);
}

/*==============================================================================
objet :
	Function call for all line in ruptur.
	write line if code crible is not qurterly

Return:
	0 -> no prob

Param:
	ptb_InRec -> current line in ruptur
==============================================================================*/

int				n_ActionLineLIFEST(char **ptb_InRec)
{
	if (crible != 'T' && crible != 'U')
		n_WriteCols(Kp_outputLIFEST, ptb_InRec, '~', 0);
	return 0;
}

/*==============================================================================
objet :
	Init of the ruptur management structure

Return:
	0 -> no error

Param:
	pbd_Rupt -> struct of ruptur PERICASE
==============================================================================*/
int				n_initPERICASE(T_RUPTURE_SYNC_VAR *pbd_Rupt)
{
	DEBUT_FCT("n_initPERICASE");
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR));
	if (n_OpenFileAppl("ESTC1036_I2", "rt", &(pbd_Rupt->pf_InputFil)))
		RETURN_VAL(ERR);
	pbd_Rupt->n_NbRupture = 1;
	pbd_Rupt->n_ConditionRupture[0] = n_ConditionRuptPERICASE;
	pbd_Rupt->ConditionEndSync = n_ConditionSyncPERICASE;
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstPERICASE;
	pbd_Rupt->c_Separ = '~';
	RETURN_VAL(0);
}

/*==============================================================================
objet :
	comparison between the line of LIFEST and the line of PERICASE

Return:
	ret = 0			-> no ruptur
	ret != 0		-> ruptur

Param:
	ptb_InRecOwner	-> lifest line
	ptb_InRecChild	-> pericase line
==============================================================================*/
int				n_ConditionRuptPERICASE(char **ptb_InRecOwner, char **ptb_InRecChild)
{
	DEBUT_FCT("n_CondRuptLIFEST");

	int			ret = 0;

	if ((ret = strcmp(ptb_InRecOwner[PRE_CTR_NF], ptb_InRecChild[PER_CTR_NF])) != 0)
		RETURN_VAL(ret);
	if ((ret = strcmp(ptb_InRecOwner[PRE_SEC_NF], ptb_InRecChild[PER_SEC_NF])) != 0)
		RETURN_VAL(ret);
	RETURN_VAL(ret);
}

/*==============================================================================
objet :
	comparison between the line of LIFEST and the line of PERICASE

Return:
	ret = 0			-> no ruptur
	ret != 0		-> ruptur

Param:
	ptb_InRecOwner	-> lifest line
	ptb_InRecChild	-> pericase line
==============================================================================*/
int				n_ConditionSyncPERICASE(char **ptb_InRecOwner, char **ptb_InRecChild)
{
	DEBUT_FCT("n_CondRuptLIFEST");

	int			ret = 0;

	if ((ret = strcmp(ptb_InRecOwner[PRE_CTR_NF], ptb_InRecChild[PER_CTR_NF])) != 0)
		RETURN_VAL(ret);
	if ((ret = strcmp(ptb_InRecOwner[PRE_SEC_NF], ptb_InRecChild[PER_SEC_NF])) != 0)
		RETURN_VAL(ret);
	RETURN_VAL(ret);
}

/*==============================================================================
objet :
	Function call for all line syncro
	get code crible.

Return:
	0 -> no prob

Param:
	argc -> number of arguments of program
	argv -> array of parameters
==============================================================================*/
int				n_ActionFirstPERICASE(char **ptb_InRecOwner, char **ptb_InRecChild)
{
	crible = *ptb_InRecChild[PER_ESTCRB_CT]; // get the first ESTCRB char
	return (0);
}

