/*==============================================================================
nom de l'application          : Sorting latest forecasts of driving file
nom du source                 : ESTC2062.c
revision                      : $Revision: $
date de creation              : 23/09/2019
auteur                        : L. Wernert
references des specifications : 
squelette de base             : batch
------------------------------------------------------------------------------
Description : Sort driving file latest forecasts from the others by splitting them into two files
                 
------------------------------------------------------------------------------
Change hsitory :
<jj/mm/aaaa>   <author>    <spot>			<description>
		...						...        ...           ...
==============================================================================*/

#include <utctlib.h>
//#include <struct.h>
#include "ESTC2062.h"


/*==============================================================================
Description :
   Entry point

Return :
   Error -> ExitPgm()
   Otherwise -> exit()
==============================================================================*/
int main(int argc, char *argv[])
{
	InitSig();

	if (n_BeginPgm(argc, argv) == ERR)
		ExitPgm(ERR_XX, "");
	
	//Getting the mode: Y/Q        
	strcpy(Ksz_Mode, psz_GetCharArgv(1));

	if (n_OpenFileAppl("ESTC2062_O1", "wt", &Kp_PrevOut1File) == ERR)
		ExitPgm(ERR_XX, "");

	if (n_OpenFileAppl("ESTC2062_O2", "wt", &Kp_PrevOut2File) == ERR)
		ExitPgm(ERR_XX, "");

	if (n_InitPrev(&bd_RuptPrev))
		ExitPgm(ERR_XX, "");

	if (n_ProcessingRuptureVar(&bd_RuptPrev) == ERR)
		ExitPgm(ERR_XX, "");

	if (n_CloseFileAppl("ESTC2062_I1", &(bd_RuptPrev.pf_InputFil)) == ERR)
		ExitPgm(ERR_XX, "");

	if (n_CloseFileAppl("ESTC2062_O1", &Kp_PrevOut1File) == ERR)
		ExitPgm(ERR_XX, "");

	if (n_CloseFileAppl("ESTC2062_O2", &Kp_PrevOut2File) == ERR)
		ExitPgm(ERR_XX, "");

	if (n_EndPgm() == ERR)
		ExitPgm(ERR_XX, "");

	exit(0);
}


/*==============================================================================
Description : Init the rupture handling variable of the master file
Return :
	0
==============================================================================*/
int n_InitPrev(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_InitPrev");

	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

	if (n_OpenFileAppl("ESTC2062_I1", "rb", &(pbd_Rupt->pf_InputFil)))
		RETURN_VAL (ERR);

	pbd_Rupt->n_NbRupture = 1;
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1Prev;
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptPrev;

	pbd_Rupt->n_ActionLigne = n_ActionLignePrev;

	pbd_Rupt->c_Separ = '~';

	RETURN_VAL (0);
}


/*==============================================================================
Description : Level 1 rupture test
Key: 
	Yearly => Contract, Section, Underwriting Year, Accounting Year, Subsidiary, Balance Sheet Year, Balance Sheet Month
	Quarterly => Contract, Section, Underwriting Year, Accounting Year, Subsidiary, Balance Sheet Year, Balance Sheet Month, Accounting Month

Return :
	0   ---> No rupture
	1   ---> rupture
==============================================================================*/
int n_IsR1Prev(char **ptb_InRec,char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_IsR1Prev");
	if(Ksz_Mode[0] == 'Y') {
		if (strcmp(ptb_InRec[CTR_NF], ptb_InRec_Cur[CTR_NF]) != 0)
			RETURN_VAL(1);
		if (strcmp(ptb_InRec[SEC_NF], ptb_InRec_Cur[SEC_NF]) !=0)
			RETURN_VAL(1);
		if (strcmp(ptb_InRec[UWY_NF], ptb_InRec_Cur[UWY_NF]) != 0)
			RETURN_VAL(1);
		if (strcmp(ptb_InRec[ACY_NF], ptb_InRec_Cur[ACY_NF]) != 0)
			RETURN_VAL(1);
		if (strcmp(ptb_InRec[SSD_CF], ptb_InRec_Cur[SSD_CF]) != 0)
			RETURN_VAL(1);
		if (strcmp(ptb_InRec[BALSHEY_NF], ptb_InRec_Cur[BALSHEY_NF]) != 0)
			RETURN_VAL(1);
		if (strcmp(ptb_InRec[BALSHTMTH_NF], ptb_InRec_Cur[BALSHTMTH_NF]) != 0)
			RETURN_VAL(1);
	} else {
		if (strcmp(ptb_InRec[CTR_NF_Q], ptb_InRec_Cur[CTR_NF_Q]) != 0)
			RETURN_VAL(1);
		if (strcmp(ptb_InRec[SEC_NF_Q], ptb_InRec_Cur[SEC_NF_Q]) !=0)
			RETURN_VAL(1);
		if (strcmp(ptb_InRec[UWY_NF_Q], ptb_InRec_Cur[UWY_NF_Q]) != 0)
			RETURN_VAL(1);
		if (strcmp(ptb_InRec[ACY_NF_Q], ptb_InRec_Cur[ACY_NF_Q]) != 0)
			RETURN_VAL(1);
		if (strcmp(ptb_InRec[SSD_CF_Q], ptb_InRec_Cur[SSD_CF_Q]) != 0)
			RETURN_VAL(1);
		if (strcmp(ptb_InRec[BALSHEY_NF_Q], ptb_InRec_Cur[BALSHEY_NF_Q]) != 0)
			RETURN_VAL(1);
		if (strcmp(ptb_InRec[BALSHTMTH_NF_Q], ptb_InRec_Cur[BALSHTMTH_NF_Q]) != 0)
			RETURN_VAL(1);
		if (strcmp(ptb_InRec[ACM_NF_Q], ptb_InRec_Cur[ACM_NF_Q]) != 0)
	  	RETURN_VAL(1);
	}
	
	RETURN_VAL (0);
}



/*==============================================================================
Description :
	Fired at each level 1 primary break 
==============================================================================*/
int n_ActionFirstRuptPrev (char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_ActionFirstRuptPrev");

	n_WriteCols(Kp_PrevOut1File, ptb_InRec_Cur, '~', 0);
	RETURN_VAL (0);
}


/*==============================================================================
Description : 
	Fired for each line of the forecasts file

Return :
	0 ----> OK
	ERR --> Error encountered
==============================================================================*/
int n_ActionLignePrev(char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_ActionLignePrev");

  if (b_IsRupture(&bd_RuptPrev, F1) == FALSE) {
		n_WriteCols(Kp_PrevOut2File,ptb_InRec_Cur, '~', 0);
  }
  
  RETURN_VAL (0);
}
