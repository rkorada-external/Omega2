/*==============================================================================
 Nom de l'application          : Loader programs V2
 Nom du source                 : ESTC2070.c
 Revision                      : $Revision: 1.0 $
 Date de creation              : 18/04/2019
 Auteur                        : Charles Socie
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :
    REQ11.5 - Discount forward data should be stored
------------------------------------------------------------------------------
 Historique des modifications :

[001] HR SPIRA 82685 : struct.h
==============================================================================*/



/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
//#include <structA.h>
#include <struct.h>
#include "ESTC3001A.h"


/*--------------------------------------------*/
/* Rupture variables                          */
/*--------------------------------------------*/
T_RUPTURE_VAR Kp_InputEscompte;

T_RUPTURE_SYNC_VAR Kp_InputDsc;

/*--------------------------------------------*/
/* File variables							  */
/*--------------------------------------------*/

FILE *Kp_OutputBatch;

/*--------------------------------------------*/
/* Functions prototypes						  */
/*--------------------------------------------*/
int n_InitEscompte          ( T_RUPTURE_VAR * pbd_Rupt );
int n_ActionLigneEscompte   ( char ** ptb_InRecCur );
int n_ActionPereSansFilsEscompte (char **pdb_InRecOwner);

int n_InitDiscount			( T_RUPTURE_SYNC_VAR  *pbd_Rupt );

int n_ConditionSyncCSUOE 		( char **pbd_InRecOwner,  char **pbd_InRecChild  );
int n_ActionLigneMatchingLigne		( char **pbd_InRecOwner,  char **pbd_InRecChild  );

//définition des variables d'input
char sz_Clodat_d[9] = "";
char sz_Patcat_ct[5] = "";
char sz_Pattyp_ct[5] = "";
char sz_Norm_cf[2] = "";

/*--------------------------------------------*/
/* Definition of constants and private macros */
/*--------------------------------------------*/

#define DEBUG 0



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
		printf("appel de main \n");
	#endif
  
	if (n_BeginPgm(argc, argv) == ERR) 
		ExitPgm(ERR_XX, "Issue when calling function n_BeginPGM.");
	
		// chargement de la date de clotûre fournie au programme
	  strcpy(sz_Clodat_d, psz_GetCharArgv(1));
	  strcpy(sz_Patcat_ct, psz_GetCharArgv(2));
	  strcpy(sz_Pattyp_ct, psz_GetCharArgv(3));
	  strcpy(sz_Norm_cf, psz_GetCharArgv(4));
	
	/* Opening of the output file EST_SIMU_CASHFLOW.dat */
	if ( n_OpenFileAppl ( "ESTC2070_O1","wt",&Kp_OutputBatch ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* Init of the variable Kp_InputEscompte */
	if ( n_InitEscompte( &Kp_InputEscompte ) )
		ExitPgm( ERR_XX , "" );

	/* Init of the variable Kp_InputDsc */
	if ( n_InitDiscount( &Kp_InputDsc ) )
		ExitPgm( ERR_XX , "" );

	/* treatment of the file GTSII_NOTBOOKED_FWH */
	if ( n_ProcessingRuptureVar( &Kp_InputEscompte ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* Closing of opened files */
	if ( n_CloseFileAppl( "ESTC2070_I1", &(Kp_InputEscompte.pf_InputFil) ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC2070_I2", &(Kp_InputDsc.pf_InputFil) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESTC2070_O1", &Kp_OutputBatch ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_EndPgm() == ERR )
		ExitPgm( ERR_XX , "" );

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
int n_InitEscompte( T_RUPTURE_VAR * pbd_Rupt )
{
	DEBUT_FCT( "n_InitEscompte" );

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) );
	
	#if DEBUG == 1
		printf("appel de n_InitEscompte \n");
	#endif

	/* Opening of the input file CASHFLOW */
	if ( n_OpenFileAppl ( "ESTC2070_I1","rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	pbd_Rupt->n_NbRupture = 0;

	/* Function called on the current line in the CASHFLOW file */
	pbd_Rupt->n_ActionLigne = n_ActionLigneEscompte;

	pbd_Rupt->c_Separ = '~';

	RETURN_VAL( OK );
	
}

/*==============================================================================
 Object :
   Actions to do for the current line of the file GTSII_NOTBOOKED_FWH

 Parameter(s) :
   char ** ptb_InRecCur : current line

 Return :
   OK
==============================================================================*/
int n_ActionLigneEscompte   ( char ** ptb_InRecCur )
{
	
	DEBUT_FCT( "n_ActionLigneEscompte" );
	
	#if DEBUG == 1
		printf("appel de n_ActionLigneEscompte \n");
	#endif

	n_ProcessingRuptureSyncVar(&Kp_InputDsc, ptb_InRecCur);
	
	RETURN_VAL(OK);
	
}

/*==============================================================================
 Object :
   Initialisation of the rupture variable for the file MERGE_SORT_REMAINTOPAY

 Parameter(s) :
   T_RUPTURE_SYNC_VAR * pbd_Rupt : rupture variable

 Return :
   If there is an issue, return ERR
   else return OK
==============================================================================*/
int n_InitDiscount( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitDiscount" );
	
	#if DEBUG == 1
		printf("appel de n_InitDiscount \n");
	#endif

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) );

	/* Opening of the input file Discount */
	if ( n_OpenFileAppl ( "ESTC2070_I2","rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* Number of rupture to manage */
	pbd_Rupt->n_NbRupture = 0;

	/* Synchronisation test between the master and the child */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncCSUOE;

	/* Function called on the current line in the CASHFLOW file */
	pbd_Rupt->n_ActionLigne = n_ActionLigneMatchingLigne;
	
	pbd_Rupt->n_PereSansFils = n_ActionPereSansFilsEscompte;
	
	pbd_Rupt->c_Separ = '~';

	RETURN_VAL( OK );
}

/*==============================================================================
 Object :
   Key of the synchronization between FCTRFWH and MERGE_SORT_REMAINTOPAY file

 Parameter(s) :
   char **pbd_InRecOwner : FCTRFWH file
   char **pbd_InRecChild : MERGE_SORT_REMAINTOPAY file 

 Return :
   If the lines have the same keys, return 0
   else return the result of the first strcmp with a difference
==============================================================================*/
int n_ConditionSyncCSUOE (char **pbd_InRecOwner, char **pbd_InRecChild)
{
	int ret;

	DEBUT_FCT( "n_ConditionSyncCSUOE" );

	#if DEBUG == 1
		printf("appel de n_ConditionSyncCSUOE \n");
	#endif

	if(strcmp(pbd_InRecOwner[CML_CTR_NF],"") != 0){
		if ( ( ret = strcmp( pbd_InRecOwner[CML_SSD_CF], pbd_InRecChild[CML_SSD_CF] ) ) != 0 ) RETURN_VAL(ret);
		if ( ( ret = strcmp( pbd_InRecOwner[CML_CTR_NF], pbd_InRecChild[CML_CTR_NF] ) ) != 0 ) RETURN_VAL(ret);
		if ( ( ret = strcmp( pbd_InRecOwner[CML_SEC_NF], pbd_InRecChild[CML_SEC_NF] ) ) != 0 ) RETURN_VAL(ret);
		if ( ( ret = strcmp( pbd_InRecOwner[CML_UWY_NF], pbd_InRecChild[CML_UWY_NF] ) ) != 0 ) RETURN_VAL(ret);
		if ( ( ret = strcmp( pbd_InRecOwner[CML_END_NT], pbd_InRecChild[CML_END_NT] ) ) != 0 ) RETURN_VAL(ret);
		if ( ( ret = strcmp( pbd_InRecOwner[CML_UW_NT], pbd_InRecChild[CML_UW_NT] ) ) != 0 ) RETURN_VAL(ret);
		if ( ( ret = strcmp( pbd_InRecOwner[CML_CUR_CF], pbd_InRecChild[CML_CUR_CF] ) ) != 0 ) RETURN_VAL(ret);
		if ( ( ret = strcmp( pbd_InRecOwner[CML_ACMTRS_NT], pbd_InRecChild[CML_ACMTRS_NT] ) ) != 0 ) RETURN_VAL(ret);
		if ( ( ret = strcmp( pbd_InRecOwner[CML_PATCAT_CT], pbd_InRecChild[CML_PATCAT_CT] ) ) != 0 ) RETURN_VAL(ret); 
		if ( ( ret = strcmp( pbd_InRecOwner[CML_ACMTRS3_NT2], pbd_InRecChild[CML_ACMTRS3_NT2] ) ) != 0 ) RETURN_VAL(ret);  
		if ( ( ret = strcmp( pbd_InRecOwner[CML_TRNCOD_CF], pbd_InRecChild[CML_TRNCOD_CF] ) ) != 0 ) RETURN_VAL(ret); 
	}
	else{
		if ( ( ret = strcmp( pbd_InRecOwner[CML_SSD_CF], pbd_InRecChild[CML_SSD_CF] ) ) != 0 ) RETURN_VAL(ret);
		if ( ( ret = strcmp( pbd_InRecOwner[CML_RETCTR_NF], pbd_InRecChild[CML_RETCTR_NF] ) ) != 0 ) RETURN_VAL(ret);
		if ( ( ret = strcmp( pbd_InRecOwner[CML_RETSEC_NF], pbd_InRecChild[CML_RETSEC_NF] ) ) != 0 ) RETURN_VAL(ret);
		if ( ( ret = strcmp( pbd_InRecOwner[CML_RTY_NF], pbd_InRecChild[CML_RTY_NF] ) ) != 0 ) RETURN_VAL(ret);
		if ( ( ret = strcmp( pbd_InRecOwner[CML_RETEND_NT], pbd_InRecChild[CML_RETEND_NT] ) ) != 0 ) RETURN_VAL(ret);
		if ( ( ret = strcmp( pbd_InRecOwner[CML_RETUW_NT], pbd_InRecChild[CML_RETUW_NT] ) ) != 0 ) RETURN_VAL(ret);
		if ( ( ret = strcmp( pbd_InRecOwner[CML_RETCUR_CF], pbd_InRecChild[CML_RETCUR_CF] ) ) != 0 ) RETURN_VAL(ret);
		if ( ( ret = strcmp( pbd_InRecOwner[CML_ACMTRS_NT], pbd_InRecChild[CML_ACMTRS_NT] ) ) != 0 ) RETURN_VAL(ret);
		if ( ( ret = strcmp( pbd_InRecOwner[CML_PATCAT_CT], pbd_InRecChild[CML_PATCAT_CT] ) ) != 0 ) RETURN_VAL(ret); 
		if ( ( ret = strcmp( pbd_InRecOwner[CML_ACMTRS3_NT2], pbd_InRecChild[CML_ACMTRS3_NT2] ) ) != 0 ) RETURN_VAL(ret);  
		if ( ( ret = strcmp( pbd_InRecOwner[CML_TRNCOD_CF], pbd_InRecChild[CML_TRNCOD_CF] ) ) != 0 ) RETURN_VAL(ret); 
	}

	RETURN_VAL( 0 );
	
}

/*==============================================================================
 Object :
   Actions to do each time the files Cashflow file  and Discount are synchronized correctly

 Parameter(s) :
   char **pbd_InRecOwner : Cashflow file 
   char **pbd_InRecChild : Discount file 

 Return :
   OK
==============================================================================*/
int n_ActionLigneMatchingLigne(
	char **pbd_InRecOwner ,  /* line in the Cashflow file */
	char **pbd_InRecChild  ) /* line in the Discount file */
{
	int i = 0;
	double result = 0;
	char acmtrs3[5];
	double var1;
	double var2;
	double total;
	double acmamt;
	char ** var = malloc(PATTERNSII_ANNEES * sizeof(char*));
	for(i = 0 ;i<PATTERNSII_ANNEES; i++){
		var[i] = malloc(200 * sizeof(char));
	}
	

	DEBUT_FCT( "n_ActionLigneMatchingLigne" );
	
	#if DEBUG == 1
		printf("appel de n_ActionLigneMatchingLigne \n");
		for(i = 0; i< 124;i++){
			printf("pbd_InRecOwner[%d] = %s\n",i,pbd_InRecOwner[i]);
		}
	#endif

	for(i = 0 ;i<PATTERNSII_ANNEES; i++){
		strcpy(var[i],"");
	}
	for (i=0;i<PATTERNSII_ANNEES;i++){
		result = 0 ;
		var1 = 0;
		var2 = 0;
		var1 =  atof(pbd_InRecOwner[CML_AN1+i]) ;
		var2 =  atof(pbd_InRecChild[CML_AN1+i]);
		result = var1 - var2;
		sprintf(var[i],"%f",result);

	#if DEBUG == 1
		printf("result = %f - %f = %f and atof(pbd_InRecOwner[%d]) = %f , atof(pbd_InRecChild[CML_AN1+i]) %f , = %f\n",var1,var2,result,CML_AN1+i,atof(pbd_InRecOwner[CML_AN1+i]), atof(pbd_InRecChild[CML_AN1+i]),  atof(pbd_InRecOwner[CML_AN1+i])- atof(pbd_InRecChild[CML_AN1+i]));
	#endif
	}

	for(i=0;i<PATTERNSII_ANNEES;i++){
		pbd_InRecOwner[CML_AN1+i] = var[i];
	}

	acmamt = atof(pbd_InRecOwner[CML_ACMAMT_MC])- atof(pbd_InRecChild[CML_ACMAMT_MC]);

	total = atof(pbd_InRecOwner[CML_TOTAUX_MC])- atof(pbd_InRecChild[CML_TOTAUX_MC]);

	sprintf(acmtrs3,"%s",pbd_InRecOwner[CML_ACMTRS3_NT2]);
	
	sprintf(pbd_InRecOwner[CML_ACMAMT_MC],"%f",acmamt);
	sprintf(pbd_InRecOwner[CML_TOTAUX_MC],"%f",total);
	
	sprintf(pbd_InRecOwner[CML_ACMTRS3_NT2],"%s",acmtrs3);
	strcpy(pbd_InRecOwner[CML_PATTYP_CT],"UWD");

	n_WriteCols(Kp_OutputBatch, pbd_InRecOwner, '~' , 0);
	for(i = 0 ;i<PATTERNSII_ANNEES; i++){
		free(var[i]);
	}

	free(var);
	RETURN_VAL(OK);
}



/*==============================================================================
 Object :
   Actions to do when the line in the master file couldn't be synchronize with the child file

 Parameter(s) :
   char ** pdb_InRecOwner : current line of the master file

 Return :
   OK
==============================================================================*/
int n_ActionPereSansFilsEscompte (char **pdb_InRecOwner)
{
	DEBUT_FCT( "n_ActionPereSansFilsEscompte" );
	
	/* debug mode only */
	#if DEBUG == 1
		printf("call of n_ActionPereSansFilsEscompte\n");
	#endif
	
	//n_WriteCols(Kp_OutputBatch, pdb_InRecOwner, '~' , 0);
	
	RETURN_VAL (OK);
}
