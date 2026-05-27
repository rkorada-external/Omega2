/*==============================================================================
 Nom de l'application          : Loader programs V2
 Nom du source                 : ESTC2060.c
 Revision                      : $Revision: 1.0 $
 Date de creation              : 04/10/2018
 Auteur                        : Quentin Desmettre
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :
    Calculation of simulated fund with held and remaining to pay
------------------------------------------------------------------------------
 Historique des modifications :
[01]  05/03/2019 Charles SOCIE Spira: 74543 REQ 10.9 Only Cash Funds held needs to be selected fo simulated fund held 
[02]  18/02/2021 KBagwe	91633 - NRT Jan 2021- Delta INT/IN2 on grouping 702 and 902
[01]  01/09/2021 Charles SOCIE Spira: 92644 FHNI split (702 and 902)
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion of the imported components             */
/*--------------------------------------------------*/
#include <utctlib.h>
//#include <struct.h>
#include "ESTC3001A.h"
#include "ESTC2060.h"


/*-----------*/
/* Constants */
/*-----------*/

/* DEBUG mode : 1 to activate, 0 to deactivate*/
#define DEBUG 0

#define ACCRET_CF 48

/*--------------------------------------------*/
/* Rupture variables                          */
/*--------------------------------------------*/
T_RUPTURE_VAR bd_ruptFWHNotBooked;  /* rupture variable for NOTBOOKED file           (ESTC2060_I1) */

T_RUPTURE_SYNC_VAR bd_ruptCSF; 		/* rupture variable for CASHFLOW file 			 (ESTC2060_I2) */
T_RUPTURE_SYNC_VAR bd_ruptCSF2; 		/* rupture variable for CASHFLOW file 			 (ESTC2060_I2) */
T_RUPTURE_SYNC_VAR bd_ruptICR; 		/* rupture variable for ICR file 				 (ESTC2060_I3) */
T_RUPTURE_SYNC_VAR bd_ruptICR2; 		/* rupture variable for ICR file 				 (ESTC2060_I3) */

T_RUPTURE_SYNC_VAR bd_ruptRMTP_FWH;      /* rupture variable for REMAINTOPAY_FWH file 	 (ESTC2060_I4) */

/*--------------------------------------------*/
/* File variables							  */
/*--------------------------------------------*/
FILE *Kp_OutputSIMU_CASHFLOW;
FILE *Kp_OutputSIMU_RMTP_FWH;
FILE *Kp_OutputBOOKED_FWH;

/*--------------------------------------------*/
/* Functions prototypes						  */
/*--------------------------------------------*/
int n_InitFWHNotBooked          ( T_RUPTURE_VAR * pbd_Rupt );
int n_ActionLigneFWHNotBooked   ( char ** ptb_InRecCur );

int n_InitStatCSF				( T_RUPTURE_SYNC_VAR  *pbd_Rupt );
int n_ConditionSyncCASHFLOW 	( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ActionLigneCASHFLOW		( char **pbd_InRecOwner,  char **pbd_InRecChild  );

int n_ConditionRupture_OSL		(char  **pbd_InRecChild, char  **pbd_InRecChild_Cur);
int n_ActionRuptureFirst_OSL	( char **pbd_InRecOwner,  char **pbd_InRecChild  );

int n_ConditionRupture_IBNR		(char  **pbd_InRecChild, char  **pbd_InRecChild_Cur);
int n_ActionRuptureFirst_IBNR	( char **pbd_InRecOwner,  char **pbd_InRecChild  );

int n_InitStatICR				( T_RUPTURE_SYNC_VAR  *pbd_Rupt );
int n_ConditionSyncICR 			( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ActionLigneICR			( char **pbd_InRecOwner,  char **pbd_InRecChild  );

int n_ConditionRupture_INCPAT	(char  **pbd_InRecChild, char  **pbd_InRecChild_Cur);

int n_InitStatRMTP_FWH			(  T_RUPTURE_SYNC_VAR   *pbd_Rupt );
int n_ActionLigneRMTP_FWH	    ( char **pbd_InRecOwner,  char **pbd_InRecChild );

double *Calculation_SFH902			(double rate, double * OSL, double * IBNR, double * INCPAT, double csh);          //modif [01]
double *Calculation_SFH702			(double rate, double * INCPAT, double csh);          //modif [01]
double Calculation_SFHACMTRS902			(double rate, double OSL, double IBNR, double INCPAT, double csh);
double Calculation_SFHACMTRS702			(double rate, double INCPAT, double csh);
double *Calculation_RMTP		(double * SFH);
int WritingOutput	(FILE * OutputFile, double * v_SFH, char ** currentLine, char * PATTYP , char * ACMTRS_NT, char * ACMTRS3_NT, double cal_acmamt_m, double v_total);

int n_ConditionSyncBookedRMTP_FWH		(char **pdb_InRecOwner, char **pdb_InRecChild);
int n_ActionLigneFWHNotBookedAssumeRetro   ( char ** ptb_InRecCur  );
int RETURN_VAL_MOD(int ret);

/*--------------------------------------------*/
/* Definition of constants and private macros */
/*--------------------------------------------*/



char * cur_cashflow_line[CML_QUARTER_FC];

double v_OSL[PATTERNSII_ANNEES];
double v_IBNR[PATTERNSII_ANNEES];
double v_INCPAT902[PATTERNSII_ANNEES];
double v_INCPAT702[PATTERNSII_ANNEES];
double v_OSLACMTRS;
double v_IBNRACMTRS;
double v_INCPATACMTRS902;
double v_INCPATACMTRS702;
double v_RMTP_BOOKED[PATTERNSII_ANNEES];

double Calcul_SFH902[PATTERNSII_ANNEES];
double Calcul_SFH702[PATTERNSII_ANNEES];
double Calcul_SFHACMTRS902;
double Calcul_SFHACMTRS702;
double Calcul_RMTP[PATTERNSII_ANNEES];
int bool_csf = 0;		   // 1 - means write row to output file.
char asm_ret[2] = "A";		//Assume or internal retro
int bool_newCSFrow = 0; // 1- means new row.
int compareint(char * str1, char * str2);
int compareintStr(int str1, char * str2);


T_CSUOE_RETRO *  tdb_AssumeForRetro;

/* temporary variable for tests */
#if DEBUG == 1
int test_action1 = 0;
int test_action2 = 0;
int test_action3 = 0;
int test_action4 = 0;
int test_action5 = 0;
int test_condition1=0;
int test_condition2=0;
int test_condition3=0;
int test_condition4=0;
int test_condition5=0;

int test_calc    = 0;
int test_calc2   = 0;
int test_writing = 0;

int temp_count1 = 0;

clock_t start;
clock_t stop;

clock_t first_sync;
clock_t second_sync;

clock_t first_actionline = 0;
clock_t inits = 0;
clock_t second_actionline = 0;
#endif

/*==============================================================================
 Object :
   Entry of the program

 Parameter(s) :
   int argc    : Number of arguments on command line;
   char **argv : parameters

 Return :
   If there is an issue, exit with ExitPgm(ERRCODE)
   else system call exit(OK)
==============================================================================*/
int main(int argc, char **argv)
{
	
	/* Init of signals */
	InitSig () ;
	
	#if DEBUG == 1
		printf("debut de main\n");
	#endif

	if (n_BeginPgm(argc, argv) == ERR) 
		ExitPgm(ERR_XX, "Issue when calling function n_BeginPGM.");

	strncpy(asm_ret,psz_GetCharArgv(1), strlen(psz_GetCharArgv(1)));

	/* Opening of the output file EST_SIMU_CASHFLOW.dat */
	if ( n_OpenFileAppl ( "ESTC2060_O1","wt",&Kp_OutputSIMU_CASHFLOW ) == ERR )
		ExitPgm( ERR_XX , "" );
    		
	/* Opening of the output file EST_SIMU_REMAINTOPAY_FWH.dat */
	if ( n_OpenFileAppl ( "ESTC2060_O2","wt",&Kp_OutputSIMU_RMTP_FWH ) == ERR )
		ExitPgm( ERR_XX , "" );
    		
	/* Opening of the output file EST_SIMU_REMAINTOPAY_FWH.dat */
	if ( n_OpenFileAppl ( "ESTC2060_O3","wt",&Kp_OutputBOOKED_FWH ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* Init of the variable bd_ruptFWHNotBooked */
	if ( n_InitFWHNotBooked( &bd_ruptFWHNotBooked ) )
		ExitPgm( ERR_XX , "" );
	
	/* Init of the variable bd_ruptCSF */
	if ( n_InitStatCSF( &bd_ruptCSF ) )
		ExitPgm( ERR_XX , "" );
	
	/* Init of the variable bd_ruptICR */
	if ( n_InitStatICR( &bd_ruptICR ) )
		ExitPgm( ERR_XX , "" );
	
	/* Init of the variable bd_ruptCSF */
	if ( n_InitStatCSF( &bd_ruptCSF2 ) )
		ExitPgm( ERR_XX , "" );
	
	/* Init of the variable bd_ruptICR */
	if ( n_InitStatICR( &bd_ruptICR2 ) )
		ExitPgm( ERR_XX , "" );

	/* Init of the variable bd_ruptRMTP_FWH */
	if ( n_InitStatRMTP_FWH( &bd_ruptRMTP_FWH ) )
		ExitPgm( ERR_XX , "" );

	/* treatment of the file GTSII_NOTBOOKED_FWH */
	if ( n_ProcessingRuptureVar( &bd_ruptFWHNotBooked ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	/* treatment of the file BOOKED_FWH */


	/* Closing of opened files */
	if ( n_CloseFileAppl( "ESTC2060_I1", &(bd_ruptFWHNotBooked.pf_InputFil) ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC2060_I2", &(bd_ruptCSF.pf_InputFil) ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC2060_I3", &(bd_ruptICR.pf_InputFil) ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC2060_I4", &(bd_ruptRMTP_FWH.pf_InputFil) ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC2060_O1", &Kp_OutputSIMU_CASHFLOW ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC2060_O2", &Kp_OutputSIMU_RMTP_FWH ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC2060_O3", &Kp_OutputBOOKED_FWH ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_EndPgm() == ERR )
		ExitPgm( ERR_XX , "" );
	
	#if DEBUG == 1
		printf("first sync : %d\n", first_actionline);
		printf("inits : %d\n", inits);
		printf("second sync : %d\n", second_actionline);
	#endif

	exit(OK);
}

/*==============================================================================
 Object :
   Initialisation of the rupture variable for the file GTSII_NOTBOOKED_FWH 

 Parameter(s) :
   T_RUPTURE_VAR * pbd_Rupt : rupture variable

 Return :
   If there is an issue, return ERR
   else return OK
==============================================================================*/
int n_InitFWHNotBooked( T_RUPTURE_VAR * pbd_Rupt )
{
	#if DEBUG == 1
		printf("debut de n_InitFWHNotBooked\n");
	#endif
	
	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) );

	/* Opening of the input file GTSII_NOTBOOKED_FWH */
	if ( n_OpenFileAppl ( "ESTC2060_I1","rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	pbd_Rupt->n_NbRupture = 0;

	/* Function called on the current line in the NOTBOOKED_FWH file */
	pbd_Rupt->n_ActionLigne = n_ActionLigneFWHNotBooked;

	pbd_Rupt->c_Separ = '~';

	RETURN_VAL( OK );
	
}

/*==============================================================================
 Object :
   Actions to do for the current line of the file GTSII_NOTBOOKED_FWH
   It launch the function n_ActionLigneFWHNotBookedAssumeRetro twice: 
     - for the simulated cashflow output
	 - for the fund held remaintopay output

 Parameter(s) :
   char ** ptb_InRecCur : current line

 Return :
   OK
==============================================================================*/
int n_ActionLigneFWHNotBooked   ( char ** ptb_InRecCur )
{
	DEBUT_FCT( "n_ActionLigneFWHNotBooked" );
	
	if (strcmp(asm_ret, ptb_InRecCur[FWH_CTRTYP_NF]) != 0)
		RETURN_VAL(OK);
	
	#if DEBUG == 1
		start = clock();
	#endif
	
	n_ActionLigneFWHNotBookedAssumeRetro(ptb_InRecCur);
	
	#if DEBUG == 1
		first_actionline += clock() - start;
		start = clock();
	#endif

	
	#if DEBUG == 1
		second_actionline += clock() - start;
	#endif

	RETURN_VAL(OK);
}

/*==============================================================================
 Object :
   Synchronize both CASHFLOW and ICR files 
   Calculate the simulated fund held and the fund held remain to pay
   Write the new line in the output
   the synchronization of each file is done in two separate variable to use the same line twice (for accept and retro)

 Parameter(s) :
   char ** ptb_InRecCur : current line

 Return :
   OK
==============================================================================*/
int n_ActionLigneFWHNotBookedAssumeRetro   ( char ** ptb_InRecCur )
{
	double *v_SFH702;
	double v_sfhACMAMT702;
	double *v_RMTP702;
	double *v_SFH902;
	double v_sfhACMAMT902;
	double *v_RMTP902;
	int i;
	
	double v_rate = atof(ptb_InRecCur[FWH_CMLFUN_R]);
	double v_csh = atof(ptb_InRecCur[FWH_CLMFUNCAS_R]);
	

	
	
	/* CALCUL WITH FILES CASHFLOW AND ICR FOR THE OUTPUT FILE SIMU_CASHFLOW */
	
	/* Initialisation of the variables to store aggregated values OSL, IBNR and Incurred Pattern */
	memset( v_OSL, 0, sizeof( v_OSL ) );
	memset( v_IBNR, 0, sizeof( v_IBNR ) );
	memset( v_INCPAT902, 0, sizeof( v_INCPAT902 ) );
	memset( v_INCPAT702, 0, sizeof( v_INCPAT702 ) );
	
	if(tdb_AssumeForRetro != NULL){
		free(tdb_AssumeForRetro);
	}
		
	tdb_AssumeForRetro = malloc( RETRO_BUF * sizeof (T_CSUOE_RETRO));
	bool_newCSFrow =  1;
	
	if (strcmp(asm_ret, "A") == 0 )
	{
		
		/* Synchronisation with the file CASHFLOW - to calculate OSL and IBNR for the current line */
		n_ProcessingRuptureSyncVar(&bd_ruptCSF, ptb_InRecCur);
		
		/* Synchronisation with the file ICR - to calculate Incurred Pattern for the current line */
		n_ProcessingRuptureSyncVar(&bd_ruptICR, ptb_InRecCur);
	
	} else {
		

		/* Synchronisation with the file CASHFLOW - to calculate OSL and IBNR for the current line */
		n_ProcessingRuptureSyncVar(&bd_ruptCSF, ptb_InRecCur);
		
		/* Synchronisation with the file ICR - to calculate Incurred Pattern for the current line */
		n_ProcessingRuptureSyncVar(&bd_ruptICR, ptb_InRecCur);
		}

	if (bool_csf == 1)
		{
			/* Calculation of the Simulated Funds Held cashflow  				modif [01]*/ 
			if( v_rate != 0 && v_csh != 0) {
				double v_total902 = 0;
				char v_formattotal902[40];
				char v_formatsfh902[40];
				double rmntpAcmamt902 = 0;
				double v_total702 = 0;
				char v_formattotal702[40];
				char v_formatsfh702[40];
				double rmntpAcmamt702 = 0;

				if(strcmp(cur_cashflow_line[CML_ACMTRS_NT],"309") == 0 || strcmp(cur_cashflow_line[CML_ACMTRS_NT],"303") == 0 ){
					v_SFH902  = Calculation_SFH902(v_rate, v_OSL, v_IBNR, v_INCPAT902, v_csh);
				
					v_sfhACMAMT902  = Calculation_SFHACMTRS902(v_rate, v_OSLACMTRS, v_IBNRACMTRS, v_INCPATACMTRS902, v_csh);
					
					v_RMTP902 = Calculation_RMTP(v_SFH902);
					
									/* sum of the 65 years calculated */
					for(i=0;i<PATTERNSII_ANNEES;++i){
						v_total902 += v_SFH902[i];
					}
					
					sprintf(v_formattotal902, "%.2f", v_total902);
					sprintf(v_formatsfh902, "%.2f", v_total902);
					
					v_total902 = atof(v_formattotal902);
					v_sfhACMAMT902 = atof(v_formatsfh902);
					
					rmntpAcmamt902 =v_total902;
					
					/* Writing in the output file */
					
					if ( strcmp( asm_ret, "A" ) == 0 ){
						WritingOutput(Kp_OutputSIMU_CASHFLOW, v_SFH902, cur_cashflow_line, "CLACC", "902", "9028",v_sfhACMAMT902,v_total902);
					}else{
						WritingOutput(Kp_OutputSIMU_CASHFLOW, v_SFH902, cur_cashflow_line, "CLRET", "902", "9028",v_sfhACMAMT902, v_total902);
					}
					
					v_total902=0;
					/* sum of the 65 years calculated */
					for(i=0;i<PATTERNSII_ANNEES;++i){
						v_total902 += v_RMTP902[i];
					}
					
					WritingOutput(Kp_OutputSIMU_RMTP_FWH, v_RMTP902, cur_cashflow_line, "RMNTP", "902", "9028",rmntpAcmamt902, v_total902);
				}
				if(strcmp(cur_cashflow_line[CML_ACMTRS_NT],"320") == 0){
					v_SFH702  = Calculation_SFH702(v_rate, v_INCPAT702, v_csh);
					
					v_sfhACMAMT702  = Calculation_SFHACMTRS702(v_rate, v_INCPATACMTRS702, v_csh);
			
					v_RMTP702 = Calculation_RMTP(v_SFH702);

					/* sum of the 65 years calculated */
					for(i=0;i<PATTERNSII_ANNEES;++i){
						v_total702 += v_SFH702[i];
					}
					
					sprintf(v_formattotal702, "%.2f", v_total702);
					sprintf(v_formatsfh702, "%.2f", v_total702);
		
					v_total702 = atof(v_formattotal702);
					v_sfhACMAMT702 = atof(v_formatsfh702);	
					

					rmntpAcmamt702 =v_total702;
					/* Writing in the output file */
					
					if ( strcmp( asm_ret, "A" ) == 0 ){
						WritingOutput(Kp_OutputSIMU_CASHFLOW, v_SFH702, cur_cashflow_line, "CLACC", "702", "7029",v_sfhACMAMT702,v_total702);
					}else{
						WritingOutput(Kp_OutputSIMU_CASHFLOW, v_SFH702, cur_cashflow_line, "CLRET", "702", "7029",v_sfhACMAMT702, v_total702);
					}
					
					v_total702=0;
					/* sum of the 65 years calculated */
					for(i=0;i<PATTERNSII_ANNEES;++i){
						v_total702 += v_RMTP702[i];
					}	
					
					WritingOutput(Kp_OutputSIMU_RMTP_FWH, v_RMTP702, cur_cashflow_line, "RMNTP", "702", "7029",rmntpAcmamt702, v_total702);
				}
				
				v_INCPATACMTRS902 = 0;
				v_INCPATACMTRS702 = 0;
				v_OSLACMTRS = 0;
				v_IBNRACMTRS = 0;
				memset (cur_cashflow_line, 0, sizeof (cur_cashflow_line));
				bool_csf = 0;
			}
	}
	
	n_ProcessingRuptureSyncVar(&bd_ruptRMTP_FWH, ptb_InRecCur);	
	
	RETURN_VAL(OK);
}

/*==============================================================================
 Object :
   Initialization of the rupture variable for the CASHFLOW file

 Parameter(s) :
   T_RUPTURE_SYNC_VAR * pbd_Rupt : rupture variable

 Return :
   If there is an issue, return ERR
   else return OK
==============================================================================*/
int n_InitStatCSF( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitStatCSF" );
	
	#if DEBUG == 1
		printf("debut de n_InitStatCSF\n");
	#endif

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) );

	/* Opening of the input file EST_GTSII_CASHFLOW */
	if ( n_OpenFileAppl ( "ESTC2060_I2","rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* Number of rupture to manage */
	pbd_Rupt->n_NbRupture = 2;

	/* Synchronisation test between the master and the child */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncCASHFLOW;

	/* Function called on the current line in the CASHFLOW file */
	pbd_Rupt->n_ActionLigne = n_ActionLigneCASHFLOW;
	
    /* Rupture for OSL calculation */
    pbd_Rupt->n_ConditionRupture[0] = n_ConditionRupture_OSL;
    pbd_Rupt->n_ActionFirst[0]      = n_ActionRuptureFirst_OSL;
	
    /* Rupture for IBNR calculation */
    pbd_Rupt->n_ConditionRupture[1] = n_ConditionRupture_IBNR;
    pbd_Rupt->n_ActionFirst[1]      = n_ActionRuptureFirst_IBNR;
	
	pbd_Rupt->c_Separ = '~';

	RETURN_VAL( OK );
}

/*==============================================================================
 Object :
   Key of the synchronization between NOTBOOKED and CASHFLOW file

 Parameter(s) :
   T_RUPTURE_VAR * pbd_Rupt : rupture variable

 Return :
   If the lines have the same keys, return 0
   else return the result of the first strcmp with a difference
==============================================================================*/
int n_ConditionSyncCASHFLOW (char **pbd_InRecOwner, char **pbd_InRecChild)
{
	int ret;

	DEBUT_FCT( "n_ConditionSyncCASHFLOW" );
			
	if (bool_newCSFrow == 1){
		bool_newCSFrow = 0;
		strcpy (tdb_AssumeForRetro[0].CTR_NF,  pbd_InRecChild[CML_CTR_NF]);
		tdb_AssumeForRetro[0].END_NT = atoi(pbd_InRecChild[CML_END_NT]);
		tdb_AssumeForRetro[0].SEC_NF = atoi(pbd_InRecChild[CML_SEC_NF]);
		tdb_AssumeForRetro[0].UWY_NF = atoi(pbd_InRecChild[CML_UWY_NF]);
		tdb_AssumeForRetro[0].UW_NT  = atoi(pbd_InRecChild[CML_UW_NT])  ;
		strcpy (tdb_AssumeForRetro[0].CUR_CF,  pbd_InRecChild[CML_CUR_CF]);
	}
	
	ret = compareint(pbd_InRecOwner[FWH_SSD_CF],pbd_InRecChild[CML_SSD_CF]);
	if (ret !=0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
	
	if (strcmp( asm_ret, "A") == 0){	
			if ( ( ret = strcmp( pbd_InRecOwner[FWH_CTR_NF], pbd_InRecChild[CML_CTR_NF] ) ) != 0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
			
			ret = compareint(pbd_InRecOwner[FWH_SEC_NF],pbd_InRecChild[CML_SEC_NF]);
			if (ret !=0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
			ret = compareint(pbd_InRecOwner[FWH_UWY_NF],pbd_InRecChild[CML_UWY_NF]);
			if (ret !=0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
			ret = compareint(pbd_InRecOwner[FWH_END_NT],pbd_InRecChild[CML_END_NT]);
			if (ret !=0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
			ret = compareint(pbd_InRecOwner[FWH_UW_NT],pbd_InRecChild[CML_UW_NT]);
			if (ret !=0 ) RETURN_VAL(RETURN_VAL_MOD(ret));

 			if ( ( ret = strcmp( tdb_AssumeForRetro[0].CUR_CF, pbd_InRecChild[CML_CUR_CF] ) ) != 0 ) RETURN_VAL(RETURN_VAL_MOD(ret));

	}else{
			if ( ( ret = strcmp( pbd_InRecOwner[FWH_CTR_NF], pbd_InRecChild[CML_RETCTR_NF] ) ) != 0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
			
			ret = compareint(pbd_InRecOwner[FWH_SEC_NF],pbd_InRecChild[CML_RETSEC_NF]);
			if (ret !=0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
			ret = compareint(pbd_InRecOwner[FWH_UWY_NF],pbd_InRecChild[CML_UWY_NF]);
			if (ret !=0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
			ret = compareint(pbd_InRecOwner[FWH_END_NT],pbd_InRecChild[CML_RETEND_NT]);
			if (ret !=0 ) RETURN_VAL(RETURN_VAL_MOD(ret));

			ret = compareint(pbd_InRecOwner[FWH_PLC_NT],pbd_InRecChild[CML_PLC_NT]);
			if (ret !=0 ) RETURN_VAL(RETURN_VAL_MOD(ret));			
			ret = compareint(pbd_InRecOwner[FWH_RTO_NT],pbd_InRecChild[CML_RTO_NF]);
			if (ret !=0 ) RETURN_VAL(RETURN_VAL_MOD(ret));			
			
			//Assume
			if ( ( ret = strcmp( tdb_AssumeForRetro[0].CTR_NF, pbd_InRecChild[CML_CTR_NF] ) ) != 0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
			ret = compareintStr(tdb_AssumeForRetro[0].SEC_NF,pbd_InRecChild[CML_SEC_NF]);
			if (ret !=0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
			ret = compareintStr(tdb_AssumeForRetro[0].UWY_NF,pbd_InRecChild[CML_UWY_NF]);
			if (ret !=0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
			ret = compareintStr(tdb_AssumeForRetro[0].END_NT,pbd_InRecChild[CML_END_NT]);
			if (ret !=0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
			ret = compareintStr(tdb_AssumeForRetro[0].UW_NT,pbd_InRecChild[CML_UW_NT]);
			if (ret !=0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
 
			if ( ( ret = strcmp( tdb_AssumeForRetro[0].CUR_CF, pbd_InRecChild[CML_CUR_CF] ) ) != 0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
	}
	
	if ( ( ret = strcmp( asm_ret, pbd_InRecChild[ACCRET_CF] ) ) != 0 ) RETURN_VAL(ret);
	


	RETURN_VAL( 0 );
	
}

/* CASHFLOW file */
int n_ActionLigneCASHFLOW(
	char **pbd_InRecOwner ,  /* line in the NOTBOOKED file */
	char **pbd_InRecChild  ) /* line in the CASHFLOW file */
{
	DEBUT_FCT( "n_ActionLigneCASHFLOW" );

	#if DEBUG == 1
		printf("appel numero %d de n_ActionLigneCASHFLOW\n", ++test_action2);
	#endif

	int i;

	
	if(strcmp(pbd_InRecChild[CML_ACMTRS_NT], "303") == 0 && (strcmp(asm_ret, pbd_InRecChild[ACCRET_CF] )) == 0){
		v_OSLACMTRS += atof(pbd_InRecChild[CML_ACMAMT_MC]);	
		for (i=0;i<PATTERNSII_ANNEES;++i){
		v_OSL[i] += atof(pbd_InRecChild[CML_AM01_MC+i]);
		}
		
		if (bool_csf == 0)
		{	
			for(i=0;i<CML_QUARTER_FC;++i)
				cur_cashflow_line[i] = pbd_InRecChild[i];
			
			bool_csf = 1;
		}	

	}
	else if ( (strcmp(pbd_InRecChild[CML_ACMTRS_NT], "309") == 0 ) && (strcmp(asm_ret, pbd_InRecChild[ACCRET_CF] )) == 0){
		v_IBNRACMTRS += atof(pbd_InRecChild[CML_ACMAMT_MC]);
        for (i=0;i<PATTERNSII_ANNEES;++i)
			v_IBNR[i] += atof(pbd_InRecChild[CML_AM01_MC+i]);
	
		if (bool_csf == 0)
		{	
			for(i=0;i<CML_QUARTER_FC;++i)
				cur_cashflow_line[i] = pbd_InRecChild[i];
			
			bool_csf = 1;
		}	

	}

	
	RETURN_VAL(OK);
	
}

/* CASHFLOW file */
int n_ConditionRupture_OSL(char **pbd_InRecChild, char **pbd_InRecChild_Cur)
{
	
	#if DEBUG == 1
		printf("appel numero %d de n_ConditionRupture_OSL\n", ++test_condition2);
	#endif
	
    int ret=0;

    if( (ret = strcmp(pbd_InRecChild[CML_ACMTRS_NT], "303") ) != 0 ) RETURN_VAL(ret);
	
    RETURN_VAL(0);
	
}

/* CASHFLOW file */
int n_ActionRuptureFirst_OSL	( char **pbd_InRecOwner,  char **pbd_InRecChild  )
{
	#if DEBUG == 1
		printf("appel numero %d de n_ActionRuptureFirst_OSL\n", ++test_action3);
	#endif
	int i;
	for(i=0;i<CML_QUARTER_FC;++i){
				cur_cashflow_line[i] = pbd_InRecChild[i];
	}
	
	bool_csf = 1;
	
	RETURN_VAL(OK);
	
}

/* CASHFLOW file */
int n_ConditionRupture_IBNR		(char  **pbd_InRecChild, char  **pbd_InRecChild_Cur)
{
	#if DEBUG == 1
		printf("appel numero %d de n_ConditionRupture_IBNR\n", ++test_condition3);
	#endif
	
  // int ret=0;

    if( strcmp(pbd_InRecChild[CML_ACMTRS_NT], "309") != 0 ){
			RETURN_VAL(-1);
	}
  
    RETURN_VAL(0);
	
}

/* CASHFLOW file */
int n_ActionRuptureFirst_IBNR	( char **pbd_InRecOwner,  char **pbd_InRecChild  )
{
	#if DEBUG == 1
		printf("appel numero %d de n_ActionRuptureFirst_IBNR\n", ++test_action4);
	#endif
	
	RETURN_VAL(OK);
}

/*==============================================================================
 Object :
   Initialization of the rupture variable for the ICR file

 Parameter(s) :
   T_RUPTURE_SYNC_VAR * pbd_Rupt : rupture variable

 Return :
   If there is an issue, return ERR
   else return OK
==============================================================================*/
int n_InitStatICR( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitStatICR" );
	
	#if DEBUG == 1
		printf("debut de n_InitStatICR\n");
	#endif

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) );

	/* Opening of the input file GTSII_ICR */
	if ( n_OpenFileAppl ( "ESTC2060_I3","rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 1;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncICR;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneICR;
	
    /* Rupture for Incurred Pattern calculation */
    pbd_Rupt->n_ConditionRupture[0] = n_ConditionRupture_INCPAT;

	pbd_Rupt->c_Separ = '~';

	RETURN_VAL( OK );
}

/*==============================================================================
 Object :
   Key of the synchronization between NOTBOOKED and ICR file

 Parameter(s) :
   T_RUPTURE_VAR * pbd_Rupt : rupture variable

 Return :
   If the lines have the same keys, return 0
   else return the result of the first strcmp with a difference
==============================================================================*/
int n_ConditionSyncICR (char **pbd_InRecOwner, char **pbd_InRecChild)
{
	
	#if DEBUG == 1
		printf("appel numero %d de n_ConditionSyncICR\n", ++test_condition4);
	#endif
	
	int ret;	

	DEBUT_FCT( "n_ConditionSyncICR" );

	ret = compareint(pbd_InRecOwner[FWH_SSD_CF],pbd_InRecChild[CML_SSD_CF]);
	if (ret !=0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
	
	if (strcmp( asm_ret, "A") == 0){	
			if ( ( ret = strcmp( pbd_InRecOwner[FWH_CTR_NF], pbd_InRecChild[CML_CTR_NF] ) ) != 0 ) RETURN_VAL(ret);
			if ( ( ret = strcmp( pbd_InRecOwner[FWH_SEC_NF], pbd_InRecChild[CML_SEC_NF] ) ) != 0 ) RETURN_VAL(ret);
			if ( ( ret = strcmp( pbd_InRecOwner[FWH_UWY_NF], pbd_InRecChild[CML_UWY_NF] ) ) != 0 ) RETURN_VAL(ret);
			if ( ( ret = strcmp( pbd_InRecOwner[FWH_END_NT], pbd_InRecChild[CML_END_NT] ) ) != 0 ) RETURN_VAL(ret);
			if ( ( ret = strcmp( pbd_InRecOwner[FWH_UW_NT], pbd_InRecChild[CML_UW_NT] ) ) != 0 ) RETURN_VAL(ret);
			if ( ( ret = strcmp( tdb_AssumeForRetro[0].CUR_CF, pbd_InRecChild[CML_CUR_CF] ) ) != 0 ) RETURN_VAL(ret);
	}else{
			if ( ( ret = strcmp( pbd_InRecOwner[FWH_CTR_NF], pbd_InRecChild[CML_RETCTR_NF] ) ) != 0 ) RETURN_VAL(ret);
			if ( ( ret = strcmp( pbd_InRecOwner[FWH_END_NT], pbd_InRecChild[CML_RETEND_NT] ) ) != 0 ) RETURN_VAL(ret);			
			if ( ( ret = strcmp( pbd_InRecOwner[FWH_SEC_NF], pbd_InRecChild[CML_RETSEC_NF] ) ) != 0 ) RETURN_VAL(ret);
			if ( ( ret = strcmp( pbd_InRecOwner[FWH_UWY_NF], pbd_InRecChild[CML_RTY_NF] ) ) != 0 ) RETURN_VAL(ret);
			if ( ( ret = strcmp( pbd_InRecOwner[FWH_PLC_NT], pbd_InRecChild[CML_PLC_NT] ) ) != 0 ) RETURN_VAL(ret);
			if ( ( ret = strcmp( pbd_InRecOwner[FWH_RTO_NT], pbd_InRecChild[CML_RTO_NF] ) ) != 0 ) RETURN_VAL(ret);
			if ( ( ret = strcmp( tdb_AssumeForRetro[0].CTR_NF, pbd_InRecChild[CML_CTR_NF] ) ) != 0 ) RETURN_VAL(ret);
			if (  tdb_AssumeForRetro[0].END_NT != atoi(pbd_InRecChild[CML_END_NT]) ) RETURN_VAL(1);
			if (  tdb_AssumeForRetro[0].SEC_NF != atoi(pbd_InRecChild[CML_SEC_NF]) ) RETURN_VAL(1);
			if (  tdb_AssumeForRetro[0].UWY_NF != atoi(pbd_InRecChild[CML_UWY_NF]) ) RETURN_VAL(1);
			if (  tdb_AssumeForRetro[0].UW_NT  != atoi(pbd_InRecChild[CML_UW_NT]) ) RETURN_VAL(1);
			if ( ( ret = strcmp( tdb_AssumeForRetro[0].CUR_CF, pbd_InRecChild[CML_CUR_CF] ) ) != 0 ) RETURN_VAL(ret);

	}

 
	RETURN_VAL( 0 );
}



/* ICR file */
int n_ConditionRupture_INCPAT	(char  **pbd_InRecChild, char  **pbd_InRecChild_Cur)
{
	
	#if DEBUG == 1
		printf("appel numero %d de n_ConditionRupture_INCPAT\n", ++test_condition5);
	#endif
 

    RETURN_VAL(0);
	
}

/* ICR file */
int n_ActionLigneICR(
	char **pbd_InRecOwner ,  /* line in the NOTBOOKED file */
	char **pbd_InRecChild  ) /* line in the ICR file */
{
	DEBUT_FCT( "n_ActionLigneICR" );
	
	#if DEBUG == 1
		printf("appel numero %d de n_ActionLigneICR\n", ++test_action5);
	#endif
	
	int i;


	if (strcmp(pbd_InRecChild[CML_ACMTRS_NT], "309") == 0)
	{
		v_INCPATACMTRS902 += atof(pbd_InRecChild[CML_ACMAMT_MC]);
		for (i=0;i<PATTERNSII_ANNEES;++i){
			v_INCPAT902[i] += atof(pbd_InRecChild[CML_AM01_MC+i]);			
		}
	}
	if (strcmp(pbd_InRecChild[CML_ACMTRS_NT], "320") == 0)
	{
		v_INCPATACMTRS702 += atof(pbd_InRecChild[CML_ACMAMT_MC]);
		for (i=0;i<PATTERNSII_ANNEES;++i){
			v_INCPAT702[i] += atof(pbd_InRecChild[CML_AM01_MC+i]);			
		}
	}
	RETURN_VAL(OK);
}

/*==============================================================================
 Object :
   Initialization of the rupture variable for the REMAINTOPAY_FHNI file

 Parameter(s) :
   T_RUPTURE_SYNC_VAR * pbd_Rupt : rupture variable

 Return :
   If there is an issue, return ERR
   else return OK
==============================================================================*/
int n_InitStatRMTP_FWH( T_RUPTURE_SYNC_VAR  *pbd_Rupt  )
{
	#if DEBUG == 1
		printf("debut de n_InitStatRMTP_FWH\n");
	#endif
	
	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) );

	/* Opening of the input file GTSII_NOTBOOKED_FWH */
	if ( n_OpenFileAppl ( "ESTC2060_I4","rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	pbd_Rupt->n_NbRupture = 0;

	/* sync function */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncBookedRMTP_FWH;
	
	/* Function called on the current line in the NOTBOOKED_FWH file */
	pbd_Rupt->n_ActionLigne = n_ActionLigneRMTP_FWH;

	pbd_Rupt->c_Separ = '~';

	RETURN_VAL( OK );
}

/*==============================================================================
 Object :
   Key of the synchronization between EST_FCTR_FWH and BookedRMTP_FWH 

 Parameter(s) :
   T_RUPTURE_VAR * pbd_Rupt : rupture variable

 Return :
   If the lines have the same keys, return 0
   else return the result of the first strcmp with a difference
==============================================================================*/
int n_ConditionSyncBookedRMTP_FWH (char **pbd_InRecOwner, char **pbd_InRecChild)
{
/*
	int ret;
	
	DEBUT_FCT( "n_ConditionSyncBookedRMTP_FWH" );
	if ( ( ret = strcmp( asm_ret, pbd_InRecChild[ACCRET_CF] ) ) != 0 ) RETURN_VAL(ret);

	//if (atoi(pbd_InRecOwner[FWH_SSD_CF]) < atoi(pbd_InRecChild[CML_SSD_CF])){
	//	RETURN_VAL(-1);
//	}
	//if (atoi(pbd_InRecOwner[FWH_SSD_CF]) > atoi(pbd_InRecChild[CML_SSD_CF])){
	//	RETURN_VAL(1);
	//}	

	if (strcmp( asm_ret, "A") == 0){	
			if ( ( ret = strcmp( pbd_InRecOwner[FWH_SSD_CF], pbd_InRecChild[CML_SSD_CF]) ) != 0 ) RETURN_VAL(ret);
			if ( ( ret = strcmp( pbd_InRecOwner[FWH_CTR_NF], pbd_InRecChild[CML_CTR_NF] ) ) != 0 ) RETURN_VAL(ret);
			if ( ( ret = strcmp( pbd_InRecOwner[FWH_SEC_NF], pbd_InRecChild[CML_SEC_NF] ) ) != 0 ) RETURN_VAL(ret);
			if ( ( ret = strcmp( pbd_InRecOwner[FWH_UWY_NF], pbd_InRecChild[CML_UWY_NF] ) ) != 0 ) RETURN_VAL(ret);
			if ( ( ret = strcmp( pbd_InRecOwner[FWH_END_NT], pbd_InRecChild[CML_END_NT] ) ) != 0 ) RETURN_VAL(ret);
			if ( ( ret = strcmp( pbd_InRecOwner[FWH_UW_NT], pbd_InRecChild[CML_UW_NT] ) ) != 0 ) RETURN_VAL(ret);		 

	}else{
			if ( ( ret = strcmp( pbd_InRecOwner[FWH_SSD_CF], pbd_InRecChild[CML_SSD_CF] ) ) != 0 ) RETURN_VAL(ret);
			if ( ( ret = strcmp( pbd_InRecOwner[FWH_CTR_NF], pbd_InRecChild[CML_RETCTR_NF] ) ) != 0 ) RETURN_VAL(ret);
			if ( ( ret = strcmp( pbd_InRecOwner[FWH_END_NT], pbd_InRecChild[CML_RETEND_NT] ) ) != 0 ) RETURN_VAL(ret);		
			if ( ( ret = strcmp( pbd_InRecOwner[FWH_SEC_NF], pbd_InRecChild[CML_RETSEC_NF] ) ) != 0 ) RETURN_VAL(ret);
			//if ( ( ret = strcmp( pbd_InRecOwner[FWH_UW_NT], pbd_InRecChild[CML_RETUW_NT] ) ) != 0 ) RETURN_VAL(ret);
			if ( ( ret = strcmp( pbd_InRecOwner[FWH_PLC_NT], pbd_InRecChild[CML_PLC_NT] ) ) != 0 ) RETURN_VAL(ret);
			if ( ( ret = strcmp( pbd_InRecOwner[FWH_RTO_NT], pbd_InRecChild[CML_RTO_NF] ) ) != 0 ) RETURN_VAL(ret);			
	}
	
	*/
	RETURN_VAL( 0 );
}


/*==============================================================================
 Object :
   Actions to do for the current line of the file REMAINTOPAY_FHNI
   It calculate the fund held remain to pay then write in the output EST_BOOKED_FWH

 Parameter(s) :
   char ** ptb_InRecCur : current line

 Return :
   OK
==============================================================================*/
int n_ActionLigneRMTP_FWH   (  char **pbd_InRecOwner, char ** ptb_InRecCur )
{
	

	#if DEBUG == 1
		printf("appel numero %d de n_ActionLigneRMTP_FWH\n", ++test_action2);
	#endif
	
	DEBUT_FCT( "n_ActionLigneRMTP_FWH" );
	
	double * v_RMTP;
	
	int ret = 0;
	int i;
	
		
	memset( v_RMTP_BOOKED, 0, sizeof( v_RMTP_BOOKED ) );
	
	for (i=0;i<PATTERNSII_ANNEES;i++) {
		if(strcmp(ptb_InRecCur[CML_AM01_MC+i],"") == 0)
			ret = 1;
	}
	
	if(ret == 0 ) {
		for (i=0;i<PATTERNSII_ANNEES;++i)
		{
			v_RMTP_BOOKED[i] += atof(ptb_InRecCur[CML_AM01_MC+i]);
		}
		
		/* Calculation of the Remaintopay amounts */
		v_RMTP = Calculation_RMTP(v_RMTP_BOOKED);
		
		double v_total=0;
		
		/* sum of the 65 years calculated */
		for(i=0;i<PATTERNSII_ANNEES;++i)
			v_total += v_RMTP[i];
			
	
		/* Writing in the output file */
		WritingOutput(Kp_OutputBOOKED_FWH, v_RMTP, ptb_InRecCur, "RMNTP", ptb_InRecCur[CML_ACMTRS_NT], ptb_InRecCur[CML_ACMTRS3_NT2],  atof(ptb_InRecCur[CML_TOTAUX_MC]),v_total);
	}
	RETURN_VAL(OK);
}

/*==============================================================================
 Object :
   Synchronize both CASHFLOW and ICR files 
   Calculate the simulated fund held and the fund held remain to pay
   Write the new line in the output
   the synchronization of each file is done in two separate variable to use the same line twice (for accept and retro)

 Parameter(s) :
   char ** ptb_InRecCur : current line

 Return :
   OK
==============================================================================*/
double * Calculation_SFH902 (double rate, double * OSL, double * IBNR, double * INCPAT, double csh)
{
	#if DEBUG == 1
		printf("appel numero %d de Calculation_SFH\n", ++test_calc);
	#endif
	
	int i;
	
	memset( Calcul_SFH902, 0, sizeof( Calcul_SFH902 ) );
	
	for (i=0;i<PATTERNSII_ANNEES;i++)
	{ 
		Calcul_SFH902[i] = csh * rate * (OSL[i] + IBNR[i] - INCPAT[i]);			 // modif [01]
	}
	
	RETURN_VAL(Calcul_SFH902);
}

/*==============================================================================
 Object :
   Synchronize both CASHFLOW and ICR files 
   Calculate the simulated fund held and the fund held remain to pay
   Write the new line in the output
   the synchronization of each file is done in two separate variable to use the same line twice (for accept and retro)

 Parameter(s) :
   char ** ptb_InRecCur : current line

 Return :
   OK
==============================================================================*/
double * Calculation_SFH702 (double rate, double * INCPAT, double csh)
{
	#if DEBUG == 1
		printf("appel numero %d de Calculation_SFH\n", ++test_calc);
	#endif
	
	int i;
	
	memset( Calcul_SFH702, 0, sizeof( Calcul_SFH702 ) );
	
	for (i=0;i<PATTERNSII_ANNEES;i++)
	{ 
		Calcul_SFH702[i] = csh * rate * ( INCPAT[i] * -1);			 // modif [01]
	}
	
	RETURN_VAL(Calcul_SFH702);
}

/*==============================================================================
 Object :
   Synchronize both CASHFLOW and ICR files 
   Calculate the simulated fund held and the fund held remain to pay for the column ACMTRS
   Write the new line in the output
   the synchronization of each file is done in two separate variable to use the same line twice (for accept and retro)

 Parameter(s) :
   char ** ptb_InRecCur : current line

 Return :
   OK
==============================================================================*/
double Calculation_SFHACMTRS902 (double rate, double OSL, double IBNR, double INCPAT, double csh)
{
	#if DEBUG == 1
		printf("appel numero %d de Calculation_SFHACMTRS\n", ++test_calc);
	#endif

	Calcul_SFHACMTRS902 = csh * rate * (OSL + IBNR - INCPAT);	

	RETURN_VAL(Calcul_SFHACMTRS902);
}

/*==============================================================================
 Object :
   Synchronize both CASHFLOW and ICR files 
   Calculate the simulated fund held and the fund held remain to pay for the column ACMTRS
   Write the new line in the output
   the synchronization of each file is done in two separate variable to use the same line twice (for accept and retro)

 Parameter(s) :
   char ** ptb_InRecCur : current line

 Return :
   OK
==============================================================================*/
double Calculation_SFHACMTRS702 (double rate, double INCPAT, double csh)
{
	#if DEBUG == 1
		printf("appel numero %d de Calculation_SFHACMTRS2\n", ++test_calc);
	#endif

	Calcul_SFHACMTRS702 = csh * rate * ( INCPAT * -1);	

	RETURN_VAL(Calcul_SFHACMTRS702);
}

/*==============================================================================
 Object :
   Synchronize both CASHFLOW and ICR files 
   Calculate the simulated fund held and the fund held remain to pay
   Write the new line in the output
   the synchronization of each file is done in two separate variable to use the same line twice (for accept and retro)

 Parameter(s) :
   char ** ptb_InRecCur : current line

 Return :
   OK
==============================================================================*/
double * Calculation_RMTP (double * SFH)
{
	#if DEBUG == 1
		printf("appel numero %d de Calculation_RMTP\n", ++test_calc2);
	#endif
	
	int i,k;
	
	memset( Calcul_RMTP, 0, sizeof( Calcul_RMTP ) );
	
	for (k=0;k<PATTERNSII_ANNEES;k++)
	{
		Calcul_RMTP[k] = 0;
		for(i=k+1;i<PATTERNSII_ANNEES;i++)
		{
			Calcul_RMTP[k] += SFH[i];
		}
	}
	RETURN_VAL(Calcul_RMTP);
}

/*==============================================================================
 Object :
   Synchronize both CASHFLOW and ICR files 
   Calculate the simulated fund held and the fund held remain to pay
   Write the new line in the output
   the synchronization of each file is done in two separate variable to use the same line twice (for accept and retro)

 Parameter(s) :
   char ** ptb_InRecCur : current line

 Return :
   OK
==============================================================================*/
int WritingOutput	(FILE * OutputFile, double * v_SFH, char ** currentLine, char * PATTYP , char * ACMTRS_NT, char * ACMTRS3_NT, double  cal_acmamt_m, double v_total) 
{
	#if DEBUG == 1
		printf("appel numero %d de WritingOutput\n", ++test_writing);
	#endif
	
//	double v_total = 0;      /* temporary variable for total of years */
	char total_buf[LONGBUF]; /* temporary buffer for total of years */
	int i;
	
	char   buf[LONGBUF]; /* Output buffer */
	
	if ((v_total == 0 || v_total == 0.0) && !(strcmp(currentLine[CML_PATCAT_CT],"CSF") && (strncmp(PATTYP,"CLACC",5) || strncmp(PATTYP,"PRACC",5)) && (atoi(ACMTRS3_NT) == 7029 || atoi(ACMTRS3_NT) == 9028) && (v_total == 0 || v_total == 0.0) )){
			return 0;
	}

	char * outputLine[CML_AMT_EURO];
	memset ( outputLine, 0, sizeof( outputLine ) );
	for(i=0;i<CML_AMT_EURO;++i)
		outputLine[i] = currentLine[i];
	stpcpy(outputLine[CML_PATTYP_CT], PATTYP);
	outputLine[CML_ACMTRS_NT] = ACMTRS_NT;

	outputLine[CML_ACMTRS3_NT2] = ACMTRS3_NT;

	sprintf(total_buf, "%.3f", v_total);
	

	
	outputLine[CML_TOTAUX_MC] = total_buf;
	outputLine[CML_AMT_MC] = currentLine[CML_AMT_MC];
	

	sprintf(outputLine[CML_ACMAMT_MC], "%.2f", cal_acmamt_m);
 
    /* add the first column */
	sprintf(buf, "%s", outputLine[CML_SSD_CF]);
	
	/* add columns before years columns */
	for (i=CML_ESB_CF;i<CML_AM01_MC;++i)
	{
		sprintf(buf, "%s~%s", buf, outputLine[i]);
	}
	
	for (i=0;i<PATTERNSII_ANNEES;++i)
		sprintf(buf, "%s~%f", buf, v_SFH[i]);
	
	/* add columns after years columns */
	for (i=CML_COEF_LOB;i<CML_SEGMENT_SII+1;++i)
	{
		sprintf(buf, "%s~%s", buf, outputLine[i]);
	}
	
	fprintf(OutputFile, "%s\n", buf);
	
	RETURN_VAL (OK);
}

int RETURN_VAL_MOD(int ret){
	bool_newCSFrow= 1;
	bool_csf = 0;
	return ret;
}

int compareint(char * str1, char * str2){
	if (atoi(str1) < atoi(str2)){
		return -1;
	}
	if (atoi(str1) > atoi(str2)){
		return 1;
	}
 return 0;
}


int compareintStr(int str1, char * str2){
	if (str1 < atoi(str2)){
		return -1;
	}
	if (str1 > atoi(str2)){
		return 1;
	}
 return 0;
}
