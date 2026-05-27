/*==============================================================================
 Nom de l'application          : Loader programs V2
 Nom du source                 : ESTC2059.c
 Revision                      : $Revision: 1.0 $
 Date de creation              : 12/09/2018
 Auteur                        : Quentin Desmettre
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :
   Addition of curve rate data
------------------------------------------------------------------------------
 Historique des modifications :
[02]  10/01/2013 Quentin Desmettre : creation of program
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion of the imported components             */
/*--------------------------------------------------*/
#include <utctlib.h>
//#include <struct.h>
#include "ESTC3001.h"
#include "ESTC2060.h"

/*-----------*/
/* Constants */
/*-----------*/

/* DEBUG mode : 1 to activate, 0 to deactivate*/
#define DEBUG 0

/*--------------------------------------------*/
/* Rupture variables                          */
/*--------------------------------------------*/
T_RUPTURE_VAR bd_ruptFCTRfwhBooked;   /* EST_FCTR_FWH */
T_RUPTURE_SYNC_VAR bd_ruptGTA;        /* EST_FWHGTA */
T_RUPTURE_SYNC_VAR bd_ruptGTR;        /* EST_FWHGTR */

/*--------------------------------------------*/
/* File variables							  */
/*--------------------------------------------*/
FILE *Kp_InputFCTR_FWH;   /* EST_FCTR_FWH */
FILE *Kp_InputFWHGTA;     /* EST_FWHGTA */
FILE *Kp_InputFWHGTR;     /* EST_FWHGTR */

FILE *Kp_OutputNotBookedFWH;

/*--------------------------------------------*/
/* Functions prototypes						  */
/*--------------------------------------------*/
int n_InitFCTRFWH			( T_RUPTURE_VAR * pbd_Rupt );
int n_ActionLigneFCTRFWH	( char **pbd_InRec_Cur ) ;

int n_InitFWHGTA				( T_RUPTURE_SYNC_VAR * pbd_Rupt );
int n_InitFWHGTR				( T_RUPTURE_SYNC_VAR * pbd_Rupt );

int n_ConditionSyncFWHGTA		(char **pdb_InRecOwner, char **pdb_InRecChild);
int n_ConditionSyncFWHGTR		(char **pdb_InRecOwner, char **pdb_InRecChild);
int n_ActionPereSansFilsFWH (char **pdb_InRecOwner);
int compareint(char * str1, char * str2);

/*--------------------------------------------*/
/* Definition of constants and private macros */
/*--------------------------------------------*/

/* temporary variable for tests */
#if DEBUG == 1
int temp_init1 = 0;
int temp_init2 = 0;
int temp_init3 = 0;
int temp_action1 = 0;
int temp_sync1 = 0;
int temp_psf = 0;
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

	#if DEBUG == 1
		printf("call of main\n");
	#endif
	
	/* Init of signals */
	InitSig () ;

	if (n_BeginPgm(argc, argv) == ERR) 
		ExitPgm(ERR_XX, "Issue when calling function n_BeginPGM.");
	
	/* Opening of the output file */
	if ( n_OpenFileAppl ( "ESTC2059_O1","wt",&Kp_OutputNotBookedFWH ) == ERR )
		ExitPgm( ERR_XX , "" );
	

	/* Init of the variable bd_ruptFCTRfwhBooked */
	if ( n_InitFCTRFWH( &bd_ruptFCTRfwhBooked ) )
		ExitPgm( ERR_XX , "" );
	
	/* Init of the variable bd_ruptGTA */
	if ( n_InitFWHGTA( &bd_ruptGTA ) )
		ExitPgm( ERR_XX , "" );
	
	/* Init of the variable bd_ruptGTR */
	if ( n_InitFWHGTR( &bd_ruptGTR ) )
		ExitPgm( ERR_XX , "" );

	/* treatment of the file FCTR_FWH */
	if ( n_ProcessingRuptureVar( &bd_ruptFCTRfwhBooked ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* Closing of opened files */
	if ( n_CloseFileAppl( "ESTC2059_I1", &(bd_ruptFCTRfwhBooked.pf_InputFil) ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC2059_I2", &(bd_ruptGTA.pf_InputFil) ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC2059_I3", &(bd_ruptGTR.pf_InputFil) ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC2059_O1", &Kp_OutputNotBookedFWH ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_EndPgm() == ERR )
		ExitPgm( ERR_XX , "" );

	exit(OK);
}

/*==============================================================================
 Object :
   Initialisation of the rupture variable bd_ruptFCTRfwhBooked for the file EST_FCTR_FWH 

 Parameter(s) :
   T_RUPTURE_VAR * pbd_Rupt : rupture variable

 Return :
   If there is an issue, return ERR
   else return OK
==============================================================================*/
int n_InitFCTRFWH(T_RUPTURE_VAR * pbd_Rupt)
{
	DEBUT_FCT( "n_InitFCTRFWH" );

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) );

	/* Opening of the file FCTRFWH */
	if ( n_OpenFileAppl( "ESTC2059_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR;

	pbd_Rupt->n_NbRupture = 0;

	/* Function called on the current line in the CASHFLOW file */
	pbd_Rupt->n_ActionLigne = n_ActionLigneFCTRFWH;

	pbd_Rupt->c_Separ = '~';

	RETURN_VAL( OK );
}

/*==============================================================================
 Object :
   Actions to do for the current line of the file EST_FCTR_FWH
   It synchronizes with the file FWHGTA or FWHGTR depending on the type of contract (Accept/Retro)
   Then if it doesn't find a corresponding row, it will write the line of the master file in the output

 Parameter(s) :
   char ** ptb_InRecCur : current line

 Return :
   OK
==============================================================================*/
int n_ActionLigneFCTRFWH   ( char ** ptb_InRecCur )
{
	DEBUT_FCT( "n_ActionLigneFCTRFWH" );
	
	if ( strcmp(ptb_InRecCur[FWH_CTRTYP_NF], "A") == 0 )       /* if accept contract */
		n_ProcessingRuptureSyncVar(&bd_ruptGTA, ptb_InRecCur);
	else if ( strcmp(ptb_InRecCur[FWH_CTRTYP_NF], "R") == 0 )  /* if retro contract */
		n_ProcessingRuptureSyncVar(&bd_ruptGTR, ptb_InRecCur);
	else if (DEBUG == 1)
			printf("the contract type was not found (A/R)\n");
	
	RETURN_VAL(OK);
}

/*==============================================================================
 Object :
   Initialization of the rupture variable bd_ruptGTA for the file EST_FWHGTA

 Parameter(s) :
   T_RUPTURE_SYNC_VAR * pbd_Rupt : rupture variable

 Return :
   If there is an issue, return ERR
   else return OK
==============================================================================*/
int n_InitFWHGTA(T_RUPTURE_SYNC_VAR * pbd_Rupt)
{
	DEBUT_FCT( "n_InitFWHGTA" );
	
	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) );

	/* Opening of the file FWHGTA */
	if ( n_OpenFileAppl( "ESTC2059_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR;

	/* nb of rupture */
	pbd_Rupt->n_NbRupture = 0;
	
	/* sync function */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncFWHGTA;
	
	pbd_Rupt->n_PereSansFils = n_ActionPereSansFilsFWH;

	pbd_Rupt->c_Separ = '~';

	RETURN_VAL( OK );
}

/*==============================================================================
 Object :
   Initialization of the rupture variable bd_ruptGTR for the file EST_FWHGTR

 Parameter(s) :
   T_RUPTURE_SYNC_VAR * pbd_Rupt : rupture variable

 Return :
   If there is an issue, return ERR
   else return OK
==============================================================================*/
int n_InitFWHGTR(T_RUPTURE_SYNC_VAR * pbd_Rupt)
{
	DEBUT_FCT( "n_InitFWHGTR" );
	
	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) );

	/* Opening of the file FWHGTA */
	if ( n_OpenFileAppl( "ESTC2059_I3", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR;

	/* nb of rupture */
	pbd_Rupt->n_NbRupture = 0;
	
	/* sync function */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncFWHGTR;
	
	pbd_Rupt->n_PereSansFils = n_ActionPereSansFilsFWH;

	pbd_Rupt->c_Separ = '~';

	RETURN_VAL( OK );
}

/*==============================================================================
 Object :
   Key of the synchronization between EST_FCTR_FWH and EST_FWHGTA

 Parameter(s) :
   T_RUPTURE_VAR * pbd_Rupt : rupture variable

 Return :
   If the lines have the same keys, return 0
   else return the result of the first strcmp with a difference
==============================================================================*/
int n_ConditionSyncFWHGTA (char **pbd_InRecOwner, char **pbd_InRecChild)
{
	int ret;

	DEBUT_FCT( "n_ConditionSyncFWHGTA" );

	//if (strcmp( pbd_InRecOwner[FWH_CTR_NF], "17T010143" )  == 0 && strcmp( pbd_InRecOwner[FWH_UWY_NF], "2005" ) ){
	//	printf(" n_ConditionSyncICR pbd_InRecOwner: %s, %s,%s, %s,%s, %s\n",pbd_InRecOwner[FWH_SSD_CF],pbd_InRecOwner[FWH_CTR_NF],pbd_InRecOwner[FWH_SEC_NF],pbd_InRecOwner[FWH_UWY_NF],pbd_InRecOwner[FWH_END_NT],pbd_InRecOwner[FWH_UW_NT]  );
	//			printf("n_ConditionSyncICR pbd_InRecChild: %s, %s,%s, %s,%s, %s,%s \n",pbd_InRecChild[GT_SSD_CF],pbd_InRecChild[GT_CTR_NF],pbd_InRecChild[GT_SEC_NF],pbd_InRecChild[GT_UWY_NF],pbd_InRecChild[GT_END_NT],pbd_InRecChild[GT_UW_NT], pbd_InRecChild[GT_END_NT]  );

	//}
	ret = compareint(pbd_InRecOwner[FWH_SSD_CF],pbd_InRecChild[GT_SSD_CF]);
	if (ret !=0 ) RETURN_VAL(ret);
	ret = compareint(pbd_InRecOwner[FWH_ESB_CF],pbd_InRecChild[GT_ESB_CF]);
	if (ret !=0 ) RETURN_VAL(ret);
 
	if ( ( ret = strcmp( pbd_InRecOwner[FWH_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) RETURN_VAL(ret);
	
	ret = compareint(pbd_InRecOwner[FWH_END_NT],pbd_InRecChild[GT_END_NT]);
	if (ret !=0 ) RETURN_VAL(ret);
	ret = compareint(pbd_InRecOwner[FWH_SEC_NF],pbd_InRecChild[GT_SEC_NF]);
	if (ret !=0 ) RETURN_VAL(ret);
	ret = compareint(pbd_InRecOwner[FWH_UWY_NF],pbd_InRecChild[GT_UWY_NF]);
	if (ret !=0 ) RETURN_VAL(ret);
	ret = compareint(pbd_InRecOwner[FWH_UW_NT],pbd_InRecChild[GT_UW_NT]);
	if (ret !=0 ) RETURN_VAL(ret);
	
	RETURN_VAL( 0 );
}

/*==============================================================================
 Object :
   Key of the synchronization between EST_FCTR_FWH and EST_FWHGTR

 Parameter(s) :
   T_RUPTURE_VAR * pbd_Rupt : rupture variable

 Return :
   If the lines have the same keys, return 0
   else return the result of the first strcmp with a difference
==============================================================================*/
int n_ConditionSyncFWHGTR (char **pbd_InRecOwner, char **pbd_InRecChild)
{
	int ret;

	DEBUT_FCT( "n_ConditionSyncFWHGTR" );
	ret = compareint(pbd_InRecOwner[FWH_SSD_CF],pbd_InRecChild[GT_SSD_CF]);
	if (ret !=0 ) RETURN_VAL(ret);
	ret = compareint(pbd_InRecOwner[FWH_ESB_CF],pbd_InRecChild[GT_ESB_CF]);
	if (ret !=0 ) RETURN_VAL(ret);	
	
	if ( ( ret = strcmp( pbd_InRecOwner[FWH_CTR_NF], pbd_InRecChild[GT_RETCTR_NF] ) ) != 0 ) RETURN_VAL(ret);
	
	ret = compareint(pbd_InRecOwner[FWH_SEC_NF],pbd_InRecChild[GT_RETSEC_NF]);
	if (ret !=0 ) RETURN_VAL(ret);	
	ret = compareint(pbd_InRecOwner[FWH_UWY_NF],pbd_InRecChild[GT_RTY_NF]);
	if (ret !=0 ) RETURN_VAL(ret);	
	ret = compareint(pbd_InRecOwner[FWH_PLC_NT],pbd_InRecChild[GT_PLC_NT]);
	if (ret !=0 ) RETURN_VAL(ret);	
	ret = compareint(pbd_InRecOwner[FWH_RTO_NT],pbd_InRecChild[GT_RTO_NF]);
	if (ret !=0 ) RETURN_VAL(ret);		
	
	RETURN_VAL( 0 );
}

/*==============================================================================
 Object :
   Actions to do when the line in the master file couldn't be synchronize with the child file

 Parameter(s) :
   char ** pdb_InRecOwner : current line of the master file

 Return :
   OK
==============================================================================*/
int n_ActionPereSansFilsFWH (char **pdb_InRecOwner)
{
	DEBUT_FCT( "n_ActionPereSansFilsFWH" );
	
	/* debug mode only */
	#if DEBUG == 1
		printf("call number %d of n_ActionPereSansFilsFWH\n", ++temp_psf);
	#endif
	
	n_WriteCols(Kp_OutputNotBookedFWH, pdb_InRecOwner, '~' , 0);
	
	RETURN_VAL (OK);
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
