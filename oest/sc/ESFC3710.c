/*===========================================================================================
NOM DE L'APPLICATION          : INITIAL PROFITABILITY
NOM DU SOURCE                 : ESFC3710.C
REVISION                      : 1.0
DATE DE CREATION              : 02/09/2019
AUTEUR                        : RAFAEL VIEVILLE
REFERENCES DES SPECIFICATIONS : 
SQUELETTE DE BASE             : BATCH
---------------------------------------------------------------------------------------------
DESCRIPTION :
	INITIAL PROFITABILITY AT CSUOE/CSUOEP LEVEL
	http://dcvprdxwikiu/xwiki/wiki/omega/view/DEV/BPR-EST-909027

--------------------------------------------------------------------------------------------
HISTORIQUE DES MODIFICATIONS :
<JJ/MM/AAAA>   	<AUTHOR>   		<SPIRA> 	<DESCRIPTION OF A CHANGE>
02/09/2019    	V.RAFAEL  		79070		DEV INITIAL VERSION
24/03/2020    	L.ELFAHIM       79070		CODE REVIEW && INDENTATION
25/03/2020    	L.ELFAHIM       79070		RETRO P && RETRO NP IMPLEMENTATION
14/05/2020    	L.ELFAHIM       79070		AJOUT POSITION 2054 FOR RETRO P && RETRO NP 
19/05/2020    	L.ELFAHIM       79070		CSM INITIAL RETRO NP && DAY ONE GAIN RETRO NP 
01/07/2020    	L.ELFAHIM       87912		REVERT INITIAL CSM  && ONE DAY GAIN
28/07/2020    	L.ELFAHIM       88235		IMPACT CHANGE GROUPING ON REQ12.2   
11/09/2020      H.REDOULY       89495     	IFRS 17 - Change in CSMxLKI sign
24/11/2020      L.ELFAHIM       91098     	Bug Fix
=========================================================================================*/

/*--------------------------------------------------*/
/*                 include header                   */
/*--------------------------------------------------*/
#include "ESFC3710.h"

/*==============================================================================
OBJECT:
	ENTRY POINT OF THE PROGRAM
RETURN:
	IN CASE OF PROBLEMS, THE PROGRAM EXIT IS PERFORMED BY THE FUNCTION EXITPGM().
	ELSE, BY CALL SYSTEM EXIT().
PARAM:
	ARGC -> NUMBER OF ARGUMENTS OF PROGRAM
	ARGV -> ARRAY OF PARAMETERS
==============================================================================*/
int main(int argc, char *argv[])
{
	// Init signal
	InitSig();

	if (n_BeginPgm(argc, argv) == ERR)
		ExitPgm(ERR_XX , "");

	// Open output file
	if (n_OpenFileAppl("ESFC3710_O1", "wt", &Kp_OutputCashFlow) == ERR)
		ExitPgm(ERR_XX, "");

	// Init struct for treatment input file
	if (n_InitCashFlow(&bd_RuptCashFlow) == ERR)
		ExitPgm(ERR_XX, "");

	// Begin of treatment
	if ( n_ProcessingRuptureVar(&bd_RuptCashFlow) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	// Close output file
	if (n_CloseFileAppl("ESFC3710_O1", &Kp_OutputCashFlow) == ERR)
		ExitPgm(ERR_XX ,"");
	if (n_EndPgm() == ERR)
		ExitPgm(ERR_XX, "");
	exit(0);
}

/*==============================================================================
OBJET :
	FONCTION D'INITIALISATION DE LA VARIABLE DE GESTION DE RUPTURE DU FICHIER
	MAITRE.
RETOUR :
	0K
==============================================================================*/
int n_InitCashFlow(T_RUPTURE_VAR *pbd_Rupt)
{
	DEBUT_FCT("n_InitPerUw");

	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));
	
	if (n_OpenFileAppl("ESFC3710_I1", "rt", &pbd_Rupt->pf_InputFil))
		return ERR;
	
	pbd_Rupt->n_NbRupture 			= 1 ;
	pbd_Rupt->n_ConditionRupture[0] = n_CondRuptCashFlow;
	pbd_Rupt->n_ActionFirst[0] 		= n_ActionFirstCashFlow;
	pbd_Rupt->n_ActionLigne 		= n_ActionLineCashFlow;
	pbd_Rupt->n_ActionLast[0] 		= n_ActionLastCashFlow;
	pbd_Rupt->c_Separ 				= '~';
	
	RETURN_VAL(OK);
}

/*==============================================================================
OBJECT:
	COMPARISON BETWEEN THE CONTRACT OF THE CURRENT LINE AND 
	THE CONTRACT OF THE NEXT LINE
RETURN:
	RET = 0			-> NO RUPTUR
	RET != 0		-> RUPTUR
PARAM:
	PTB_INREC		-> NEXT LINE
	PTB_INREC_CUR	-> CURRENT LINE
==============================================================================*/
int n_CondRuptCashFlow(char **ptb_InRec, char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_CondRuptCPLIFEST_MVT");

	int	ret = 0;

	if ((  ret = strcmp(ptb_InRec[CTR_NF], ptb_InRec_Cur[CTR_NF])) != 0 )				RETURN_VAL(ret);
	if ( ( ret = atoi( ptb_InRec[END_NT]) - atoi(ptb_InRec_Cur[END_NT])) != 0 ) 		RETURN_VAL(ret);
	if ( ( ret = atoi( ptb_InRec[SEC_NF]) - atoi(ptb_InRec_Cur[SEC_NF])) != 0 ) 		RETURN_VAL(ret);
	if ((  ret = strcmp(ptb_InRec[UWY_NF], ptb_InRec_Cur[UWY_NF])) != 0)				RETURN_VAL(ret);
	if ( ( ret = atoi( ptb_InRec[UW_NT]) - atoi(ptb_InRec_Cur[UW_NT])) != 0 ) 			RETURN_VAL(ret);
	if ((  ret = strcmp(ptb_InRec[RETCTR_NF], ptb_InRec_Cur[RETCTR_NF])) != 0)			RETURN_VAL(ret);
	if ( ( ret = atoi( ptb_InRec[RETEND_NT]) - atoi(ptb_InRec_Cur[RETEND_NT])) != 0 ) 	RETURN_VAL(ret);
	if ( ( ret = atoi( ptb_InRec[RETSEC_NF]) - atoi(ptb_InRec_Cur[RETSEC_NF])) != 0 ) 	RETURN_VAL(ret);
	if ((  ret = strcmp(ptb_InRec[RTY_NF], ptb_InRec_Cur[RTY_NF])) != 0)				RETURN_VAL(ret);
	if ( ( ret = atoi( ptb_InRec[RETUW_NT]) - atoi(ptb_InRec_Cur[RETUW_NT])) != 0 ) 	RETURN_VAL(ret);
	if ( ( ret = atoi( ptb_InRec[PLC_NT]) - atoi(ptb_InRec_Cur[PLC_NT])) != 0 ) 		RETURN_VAL(ret);
	
	RETURN_VAL(ret);
}

/*==============================================================================
OBJECT:
	THIS FUNCTION IS CALLED FOR ALL LINE OF THE BREAK.
RETURN:
	0	-> NO PROB
PARAM:
	ARRAY OF LINE FATHER
==============================================================================*/
int n_ActionLineCashFlow(char **ptb_InRec)
{
	if ( !strcmp(ptb_InRec[PATTYP_CT], "LKI") )
	{
		int acmtrs3 	= atoi(ptb_InRec[ACMTRS3_NT2]);
		
		if (!strcmp(ptb_InRec[PATCAT_CT], "BDT"))
		{
			totaux += atof(ptb_InRec[TOTAUX_MC]);
			acmamt += atof(ptb_InRec[ACMAMT_MC]);
			n_AdditionAnk(ptb_InRec);
			csm = 1;
		}
		else if (!strcmp(ptb_InRec[PATCAT_CT], "RAD") && acmtrs3 == 3201)
		{
			totaux += atof(ptb_InRec[TOTAUX_MC]);
			acmamt += atof(ptb_InRec[ACMAMT_MC]);
			n_AdditionAnk(ptb_InRec);
			csm = 1;
		}
		else if (!strcmp(ptb_InRec[PATCAT_CT], "DSC"))
		{
			if (
				acmtrs3 == 1051 || acmtrs3 == 2053 || acmtrs3 == 3201 ||
				acmtrs3 == 3202 || acmtrs3 == 3115 || acmtrs3 == 2090 
			)
			{
				totaux += atof(ptb_InRec[TOTAUX_MC]);
				acmamt += atof(ptb_InRec[ACMAMT_MC]);
				n_AdditionAnk(ptb_InRec);
				csm = 1;
			}
		}
	}	
	
	return (0);
}

/*==============================================================================
OBJECT:
	THIS FUNCTION IS CALLED FOR THE FIRST LINE OF THE BREAK.
	INIT ALL VARIBLE USE IN THIS PROGRAMME
RETURN:
	0	-> NO PROB
PARAM:
	ARRAY OF LINE FATHER
==============================================================================*/
int n_ActionFirstCashFlow(char **ptb_InRec)
{
	csm 	= 0;
	totaux 	= 0.0;
	acmamt 	= 0.0;
	memset(ank, 0, sizeof(ank));
	strcpy(cur, ptb_InRec[CUR_CF]);
	strcpy(acmcur, ptb_InRec[ACMCUR_CF]);
	strcpy(dsccur, ptb_InRec[DSCCUR_CF]);
	strcpy(patcat, "CSM");
	strcpy(pattyp, "LKI");
	strcpy(patid, "");
	strcpy(acmtrs, "170");
	strcpy(acmtrs3, "3330");

	return (0);
}

/*==============================================================================
OBJECT:
	THIS FUNCTION IS CALLED FOR THE LASR LINE OF THE BREAK.
	ASSIGN NEW VALUE AND WRITE IN OUTPUT FILE
RETURN:
	0	-> NO PROB
PARAM:
	ARRAY OF LINE FATHER
==============================================================================*/
int n_ActionLastCashFlow(char **ptb_InRec)
{
	int	i = 0;
	int	an;
	char	*res;
	char	tot[30];
	char	acm[30];
	
	//if( strcmp( ptb_InRec[RETCTR_NF], "02N000554") == 0 && strcmp( ptb_InRec[RTY_NF], "2020" ) == 0 && strcmp( ptb_InRec[PLC_NT], "33" ) == 0)
	if (csm)
	{
		ptb_InRec[ACMTRS_NT] 	= acmtrs;
		ptb_InRec[ACMTRS3_NT2] 	= acmtrs3;
		ptb_InRec[PATCAT_CT] 	= patcat;
		ptb_InRec[PATTYP_CT] 	= pattyp;
		ptb_InRec[PATTERN_ID] 	= patid;
		ptb_InRec[CUR_CF] 		= cur;
		ptb_InRec[ACMCUR_CF] 	= acmcur;
		ptb_InRec[DSCCUR_CF] 	= dsccur;
                // 89495 sign changed tot, acm ank[i]
		sprintf(tot, "%.3f", (-1) * totaux);
		sprintf(acm, "%.3f", (-1) * acmamt);
		ptb_InRec[TOTAUX_MC] 	= tot;
		ptb_InRec[ACMAMT_MC] 	= acm;
		ptb_InRec[AMT_MC] 		= acm;
		ptb_InRec[RETAMT_MC] 	= acm;
		for (an = AN1; an <= AN65; an++)
		{
			res = (char *)malloc(sizeof(char) * 50);
			sprintf(res, "%.3f", (-1) * ank[i]);
			ptb_InRec[an] = res;
			i++;
		}
		n_WriteCols(Kp_OutputCashFlow, ptb_InRec, '~', 0);
		for (an = AN1; an < AN65; an++)
		{
			free(ptb_InRec[an]);
		}
	}
	return (0);
}

/*==============================================================================
OBJECT:
	THIS FUNCTION IS CALLED FOR FILL ARRAY OF 65 YEARS.
RETURN:
	NO RETURN 
PARAM:
	ARRAY OF LINE FATHER
==============================================================================*/
static void n_AdditionAnk( char **ptb_InRec )
{
	int i = 0;
	int an;

	for ( an = AN1; an <= AN65; an++ )
	{
		ank[i] += atof(ptb_InRec[an]);
		i++;
	}
}
