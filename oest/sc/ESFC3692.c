/*=============================================================================================================================
APPLICATION NAME          		: IFRS17 REVENUE CALCULATION
PROGRAM NAME                 	: ESFC3692.c
REVISION                      	: V1
CREATION DATE              		: 10/2019
AUTHOR                        	: L.ELFAHIM
-------------------------------------------------------------------------------------------------------------------------------
DESCRIPTION :
	THIS PROGRAM AIMS TO HANDLE IFRS17 REVENUE CALCULATION FOR RETRO NO PROPORTIONAL CONTRACTS

-------------------------------------------------------------------------------------------------------------------------------
	/  \   	* FOR THE MAINTENANCE OF THIS PROGRAM PLEASE SIGN  *
	/  ! \  * ANY MODIFICATIONS TO THE FOLLOWING MODEL BELOW   *
	/______\ *********************************************************

CHANGE HISTORY :
	<JJ/MM/AAAA>   	<AUTHOR>    	<SPIRA>		<MODIFICATION DESCRIPTION>
	22/10/2019    	L.ELFAHIM       xxxxx    	INITIAL VERSION DEVELOPMENT
	06/01/2020    	L.ELFAHIM       82711    	CR : REVENUE - INCLUDE DAC
	22/01/2020    	L.ELFAHIM       82837   	ADJUST REVENUE CALCULATION IN THE CASE OPENING FP=0 AND CHANGE IN EGPI<>0
	17/03/2020    	L.ELFAHIM       82711   	CALCULATION DAC VARIABLES
	11/06/2020    	L.ELFAHIM       70741		DEACTIVATE CALCULATION DAC VARIABLES
	23/07/2020    	L.ELFAHIM       82711		REACTIVATE CALCULATION DAC VARIABLES
	24/07/2020    	L.ELFAHIM       79621		IMPLEMENTATION OF SPIRA
	24/07/2020    	L.ELFAHIM       88368		IMPLEMENTATION OF SPIRA
	24/07/2020    	L.ELFAHIM       88235		IMPLEMENTATION OF SPIRA
	15/09/2020    	L.ELFAHIM       89817		SPLIT MERGE CLAIM et RA ( 3201 && 3202 )
==================================================================================================================================*/

/**----------------------------------------------------
	Inclusion des fichiers entete 
-------------------------------------------------------*/
#include <utctlib.h>
#include <estserv.h>
#include <stdarg.h>
#include <util.h>
#include "struct.h"
#include "estutil.c"
#include "ESFC3690.h"  

/**-------------------------------------------------
	Traitemant principale du programme                      
----------------------------------------------------*/
int main( int argc,  char *argv[] )
{
	InitSig ();

	if (n_BeginPgm (argc, argv) == ERR)
		ExitPgm (ERR_XX, "");
	
	n_DEBUG_LEVEL = atoi(psz_GetCharArgv(1) );
	
	/***************************************************************************/
	/**  Ouverture Des fichiers en entree et Initialisation des structures     */
	/***************************************************************************/
	
	if ( n_OpenFileAppl ( "ESFC3692_O1","wt",&Kp_OutputFil_REVENUE ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_OpenFileAppl ( "ESFC3692_O2","wt",&Kp_OutputFil_TRACE ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* Ouverture du fichier en entree des cours de change FCURQUOT */
	if ( n_OpenFileAppl ( "ESFC3692_I7","rb",&Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	/* Initialisation de la variable Kbd_Rup_LockedInRate */
	if ( n_Init_LockedInRate(&Kbd_Rup_LockedInRate) ) 
		ExitPgm ( ERR_XX , "" );
	
	/* Initialisation de la variable Kbd_Rupt_CASHFLOW_Q */
	if ( n_Init_CASHFLOW_Q(&Kbd_Rupt_CASHFLOW_Q) ) 
		ExitPgm ( ERR_XX , "" );
	
	/* Initialisation de la variable Kbd_Rupt_CASHFLOW_PREVQ */
	if ( n_Init_CASHFLOW_PREVQ(&Kbd_Rupt_CASHFLOW_PREVQ) ) 
		ExitPgm ( ERR_XX , "" );
	
	/* Initialisation de la variable Kbd_Rupt_ITD_PREM */
	if ( n_Init_ITD_PREM(&Kbd_Rupt_ITD_PREM) ) 
		ExitPgm ( ERR_XX , "" );
	
	/* Initialisation de la variable Kbd_Rupt_UPR_Q */
	if ( n_Init_UPR_Q(&Kbd_Rupt_UPR_Q) ) 
		ExitPgm ( ERR_XX , "" );
	
	/* Initialisation de la variable Kbd_Rupt_UPR_PREVQ */
	if ( n_Init_UPR_PREVQ(&Kbd_Rupt_UPR_PREVQ) ) 
		ExitPgm ( ERR_XX , "" );
	
	/* Initialisation de la variable Kbd_Rupt_FORWARD */
	if ( n_Init_FORWARD(&Kbd_Rupt_FORWARD) ) 
		ExitPgm ( ERR_XX , "" );
	
	/* Lancement du traitement du fichier maitre */
	if (n_ProcessingRuptureVar(&Kbd_Rup_LockedInRate) == ERR) 
		ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
	
	/***************************************************************************/
	/**   Fermeture Des fichiers ouverts                                       */
	/***************************************************************************/
	if ( n_CloseFileAppl( "ESFC3692_I1", &( Kbd_Rup_LockedInRate.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3692_I2", &( Kbd_Rupt_CASHFLOW_Q.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3692_I3", &( Kbd_Rupt_CASHFLOW_PREVQ.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3692_I4", &( Kbd_Rupt_ITD_PREM.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3690_I5", &( Kbd_Rupt_UPR_Q.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3692_I6", &( Kbd_Rupt_UPR_PREVQ.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3692_I7", &Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3692_I8", &( Kbd_Rupt_FORWARD.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3692_O1", &Kp_OutputFil_REVENUE ) == ERR ) 
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3692_O2", &Kp_OutputFil_TRACE ) == ERR ) 
		ExitPgm( ERR_XX , "" );
	
	if ( n_EndPgm () == ERR )
		ExitPgm (ERR_XX, "");
	
	exit(0);
}

/**============================================================================
objet : Fonction d'initialisation de la variable de rupture du fichier maitre.
retour 	:	0  	---> traitement correctement effectue
		ERR 	---> probleme rencontre
===============================================================================*/
int n_Init_LockedInRate(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_Init_LockedInRate");
	
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

	if ( n_OpenFileAppl ("ESFC3692_I1", "rt", &(pbd_Rupt->pf_InputFil)))
		RETURN_VAL (ERR);

	pbd_Rupt->n_NbRupture 			= 1 ;
	pbd_Rupt->n_ConditionRupture[0] = n_IsRupt_LockedInRate;
	pbd_Rupt->n_ActionFirst[0] 		= n_ActionFirstRuptPER;
	pbd_Rupt->n_ActionLigne 		= n_ActionLigne_LockedInRate ;
	pbd_Rupt->c_Separ 				= '~' ;

	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction de test de rupture du niveau 1
retour	: 	0   ---> Rupture
		1   ---> Pas de rupture
==============================================================================*/
int n_IsRupt_LockedInRate(char **ptb_InRec, char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_IsRupt_LockedInRate");
	int ret;
	
	if ( ( ret = strcmp( ptb_InRec[CML_CTR_NF], ptb_InRec_Cur[CML_CTR_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( ptb_InRec[CML_END_NT] ) - atoi( ptb_InRec_Cur[CML_END_NT] ) ) != 0 ) 	return ret ;
	if ( ( ret = atoi( ptb_InRec[CML_SEC_NF] ) - atoi( ptb_InRec_Cur[CML_SEC_NF] ) ) != 0 ) 	return ret ;
	if ( ( ret = strcmp( ptb_InRec[CML_UWY_NF], ptb_InRec_Cur[CML_UWY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( ptb_InRec[CML_UW_NT] ) - atoi( ptb_InRec_Cur[CML_UW_NT] ) ) != 0 ) 		return ret ;
	if ( ( ret = strcmp( ptb_InRec[CML_RETCTR_NF], ptb_InRec_Cur[CML_RETCTR_NF] ) ) != 0 ) 		return ret;
	if ( ( ret = atoi( ptb_InRec[CML_RETEND_NT]) - atoi(ptb_InRec_Cur[CML_RETEND_NT])) != 0 ) 	return ret ;
	if ( ( ret = atoi( ptb_InRec[CML_RETSEC_NF]) - atoi( ptb_InRec_Cur[CML_RETSEC_NF])) != 0)	return ret ;
	if ( ( ret = strcmp( ptb_InRec[CML_RTY_NF], ptb_InRec_Cur[CML_RTY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( ptb_InRec[CML_RETUW_NT]) - atoi( ptb_InRec_Cur[CML_RETUW_NT] )) != 0 ) 	return ret ;
	if ( ( ret = atoi( ptb_InRec[CML_PLC_NT]) - atoi( ptb_InRec_Cur[CML_PLC_NT] )) != 0 ) 		return ret ;

	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction de rupture du niveau 1
==============================================================================*/
int n_ActionFirstRuptPER( char **ptb_InRec_Cur )
{
	DEBUT_FCT("n_ActionFirstRuptPER");
	
	/* RETRO GLOBAL VARIABLES */
	d_UPR_Q 				= 0.0;
	d_ITD_PREM 				= 0.0;
	d_UPR_PREVQ 			= 0.0;
	d_FIXED_CHARGE			= 0.0;
	d_FUTURE_PREM_Q 		= 0.0;
	d_FUT_FIXED_CHARGE		= 0.0;
	d_FUTURE_PREM_PREVQ 	= 0.0;
	d_FUTURE_OVERRIDE_COM 	= 0.0;
	
	// LANCEMENT SYNCHRONISATION AVEC LE FICHIER ITD_PREM  
	n_ProcessingRuptureSyncVar( &Kbd_Rupt_ITD_PREM, ptb_InRec_Cur );
	
	// LANCEMENT SYNCHRONISATION AVEC LE FICHIER CASHFLOW_Q 
	n_ProcessingRuptureSyncVar( &Kbd_Rupt_CASHFLOW_Q, ptb_InRec_Cur ); 
	
	// LANCEMENT SYNCHRONISATION AVEC LE FICHIER CASHFLOW_PREVQ  
	n_ProcessingRuptureSyncVar( &Kbd_Rupt_CASHFLOW_PREVQ, ptb_InRec_Cur );
	
	// LANCEMENT SYNCHRONISATION AVEC LE FICHIER UPR_Q  
	n_ProcessingRuptureSyncVar( &Kbd_Rupt_UPR_Q, ptb_InRec_Cur );
	
	// LANCEMENT SYNCHRONISATION AVEC LE FICHIER UPR_PREVQ  
	n_ProcessingRuptureSyncVar( &Kbd_Rupt_UPR_PREVQ, ptb_InRec_Cur );

	RETURN_VAL (0);
}

/** ===========================================================================
objet 	: 	Fonction lancee a chaque ligne de repture
retour 	:	0  		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==============================================================================*/
int n_ActionLigne_LockedInRate( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionLigne_LockedInRate" ) ;
	
	// Lancement synchronisation avec le fichier FORWARD  
	n_ProcessingRuptureSyncVar( &Kbd_Rupt_FORWARD, ptb_InRec_Cur );
	
	RETURN_VAL(0) ;
}


/**===============================================================================
objet 	: Fonction initialisation synchro entre CASHFLOW et DSC_RAD_LKI
retour 	:	0	---> traitement correctement effectue
==================================================================================*/
int n_Init_FORWARD(T_RUPTURE_SYNC_VAR  *pbd_Sync)
{
	DEBUT_FCT("n_Init_FORWARD");

	memset( pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;
	n_OpenFileAppl ("ESFC3692_I8", "rt", &(pbd_Sync->pf_InputFil));

	pbd_Sync->ConditionEndSync  	= n_CondSync_FORWARD ;        
	pbd_Sync->n_ActionLigne     	= n_ActionLigne_FORWARD ;
	pbd_Sync->n_FilsSansPere     	= n_FilsSansPere_FORWARD ; 
	pbd_Sync->n_PereSansFils     	= n_PereSansFils_FORWARD ; 	
	pbd_Sync->c_Separ      			= '~' ;
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction de test de synchro entre CASHFLOW et DSC_RAD_LKI
retour 	:	0  	---> synchro
			1  	---> non trouve
==============================================================================*/
int n_CondSync_FORWARD( char **pbd_InRecOwner , char **pbd_InRecChild )
{
	DEBUT_FCT("n_CondSync_FORWARD");
	int ret;
	
	if ( ( ret = strcmp( pbd_InRecOwner[CML_CTR_NF], pbd_InRecChild[CML_CTR_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_END_NT] ) - atoi( pbd_InRecChild[CML_END_NT] ) ) != 0 ) 	return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[CML_SEC_NF] ) - atoi( pbd_InRecChild[CML_SEC_NF] ) ) != 0 ) 	return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_UWY_NF], pbd_InRecChild[CML_UWY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_UW_NT] ) - atoi( pbd_InRecChild[CML_UW_NT] ) ) != 0 ) 	return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_RETCTR_NF], pbd_InRecChild[CML_RETCTR_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_RETEND_NT]) - atoi(pbd_InRecChild[CML_RETEND_NT])) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[CML_RETSEC_NF]) - atoi( pbd_InRecChild[CML_RETSEC_NF])) != 0)	return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_RTY_NF], pbd_InRecChild[CML_RTY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_RETUW_NT]) - atoi( pbd_InRecChild[CML_RETUW_NT] )) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_RETCUR_CF],pbd_InRecChild[CML_RETCUR_CF] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_PLC_NT]) - atoi( pbd_InRecChild[CML_PLC_NT] )) != 0 ) 	return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_NAT_CF], pbd_InRecChild[CML_NAT_CF] ) ) != 0 ) 			return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_TYP_CT], pbd_InRecChild[CML_TYP_CT] ) ) != 0 ) 			return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_PATCAT_CT],pbd_InRecChild[CML_PATCAT_CT] ) ) != 0 ) 	return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_ACMTRS3_NT2],pbd_InRecChild[CML_ACMTRS3_NT2] ) ) != 0 ) return ret;
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction lance a chaque ligne synchro entre CASHFLOW et DSC_RAD_LKI
retour 	:	0		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==============================================================================*/
int n_ActionLigne_FORWARD( char **pbd_InRecOwner ,char **pbd_InRecChild )
{
	DEBUT_FCT("n_ActionLigne_FORWARD");
	
	// VARIABLE DECLARATION
	int 	ACMTRS3, j;
	double	d_Ratio = 1, d_Retro_Ratio = 1;
	char 	amount[AMN_LEN], ank_mnt[65][AMN_LEN], total_mnt[AMN_LEN];
	
	// COMMON INITIALISATION
	memset(amount,0, sizeof(amount));
	memset(total_mnt,0, sizeof(total_mnt));
	ACMTRS3 = atoi(pbd_InRecOwner[CML_ACMTRS3_NT2]);
	
	if( ACMTRS3 == 1051 )
	{	
		if( fabs( d_FUTURE_PREM_PREVQ ) < 1 && fabs( d_UPR_PREVQ ) >= 1 )
		{
			sprintf(amount , "%.3f" , d_FUTURE_PREM_Q + d_ITD_PREM + d_FUT_FIXED_CHARGE + d_FIXED_CHARGE + d_FUTURE_OVERRIDE_COM );
			// CALCULATION OF THE CASHFLOW FOR ACMAMT_MC
			pbd_InRecOwner[CML_ACMAMT_MC] = amount; 
			// CALCULATION OF THE CASHFLOW FOR AN1 AMOUNT
			pbd_InRecOwner[CML_AN1] = amount;
			// CALCULATION OF THE CASHFLOW FOR TOTAL_AMOUNT
			pbd_InRecOwner[CML_TOTAUX_MC] = amount; 
			// OTHER AMOUNTS FROM AN2
			for( j = CML_AN2; j<= CML_AM_FIN; ++j )   
			{
				pbd_InRecOwner[j] = "0.000"; 
			}					
		}
		else
		{
			if( fabs( d_FUTURE_PREM_PREVQ ) > 1 )
			{
				d_Retro_Ratio = ( d_FUTURE_PREM_Q + d_ITD_PREM )/( d_FUTURE_PREM_PREVQ );
			}
			else
				pbd_InRecOwner[CML_COMMENT] = "Division by 0, ratio forced to 1";
		
			sprintf(amount , "%.3f" , atof(pbd_InRecChild[CML_ACMAMT_MC]) * d_Retro_Ratio );
			pbd_InRecOwner[CML_ACMAMT_MC] = amount;
							
			sprintf(total_mnt , "%.3f" , atof(pbd_InRecChild[CML_TOTAUX_MC]) * d_Retro_Ratio );
			pbd_InRecOwner[CML_TOTAUX_MC] = total_mnt; 
			
			for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
			{
				sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(pbd_InRecChild[j]) * d_Retro_Ratio );
				pbd_InRecOwner[j] = ank_mnt [j-CML_AN1];
			}				
		}
		if( strcmp(pbd_InRecOwner[CML_PATCAT_CT],"BDT") == 0 && strcmp(pbd_InRecOwner[CML_PATTYP_CT], "LKI") == 0 )
		{
			pbd_InRecOwner[CML_PATCAT_CT] = "EXP";
			pbd_InRecOwner[CML_PATTYP_CT] = "EGPBD";
			n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
			pbd_InRecOwner[CML_PATTYP_CT] = "EARBD";
			n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
		}
		else
		{
			pbd_InRecOwner[CML_PATCAT_CT] = "EXP";
			pbd_InRecOwner[CML_PATTYP_CT] = "EGPPR";
			n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
			pbd_InRecOwner[CML_PATTYP_CT] = "EARPR";
			n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
		}	
		//--------------------------- CHANGE IN ESTIMATES -----------------------//
		if (n_DEBUG_LEVEL > 1)
		{
			fprintf(Kp_OutputFil_TRACE,
				"EGPI and EARNED RATIO ( CSUOE %s~%s~%s~%s~%s | CSUOER %s~%s~%s~%s~%s |PLC %s | ACMTRS3 %d | FuturePrem Q_1 %.3f | FuturePrem Q %.3f | WrittenPrem %.3f | FutureFixCharge %.3f | FixedCharge %.3f| Upr Q_1 %.3f | d_FUTURE_OVERRIDE_COM %.3f | d_Retro_Ratio %.3f )\n", 
				pbd_InRecOwner[CML_CTR_NF],
				pbd_InRecOwner[CML_END_NT],
				pbd_InRecOwner[CML_SEC_NF],
				pbd_InRecOwner[CML_UWY_NF],
				pbd_InRecOwner[CML_UW_NT],
				pbd_InRecOwner[CML_RETCTR_NF],
				pbd_InRecOwner[CML_RETEND_NT],
				pbd_InRecOwner[CML_RETSEC_NF],
				pbd_InRecOwner[CML_RTY_NF],
				pbd_InRecOwner[CML_RETUW_NT],
				pbd_InRecOwner[CML_PLC_NT],
				ACMTRS3,
				d_FUTURE_PREM_PREVQ,
				d_FUTURE_PREM_Q,
				d_ITD_PREM,
				d_FUT_FIXED_CHARGE,
				d_FIXED_CHARGE,
				d_UPR_PREVQ, 
				d_FUTURE_OVERRIDE_COM,
				d_Retro_Ratio
				);
		}
		RETURN_VAL (0);
	}
	else
	{
		//------------------------------ CHANGE IN EGPI ------------------------------------// 
		if( fabs( d_FUTURE_PREM_PREVQ - d_UPR_PREVQ ) > 1 )
		{
			d_Retro_Ratio = ( d_FUTURE_PREM_Q + d_ITD_PREM - d_UPR_PREVQ )/( d_FUTURE_PREM_PREVQ - d_UPR_PREVQ );
			d_Ratio 	= ( d_FUTURE_PREM_Q - d_UPR_Q )/( d_FUTURE_PREM_PREVQ - d_UPR_PREVQ );
		}
		else
			pbd_InRecOwner[CML_COMMENT] = "Division by 0, ratio forced to 1";
		
		// CALCULATION OF CASHFLOW FOR ACMAMT_MC 
		sprintf(amount , "%.3f" , atof(pbd_InRecChild[CML_ACMAMT_MC]) * d_Retro_Ratio );
		pbd_InRecOwner[CML_ACMAMT_MC] = amount; 
		
		// CALCULATION OF CASHFLOW FOR TOTAL_AMOUNT
		sprintf(total_mnt , "%.3f" , atof(pbd_InRecChild[CML_TOTAUX_MC]) * d_Retro_Ratio );
		pbd_InRecOwner[CML_TOTAUX_MC] = total_mnt; 
		
		// CALCULATION OF CASHFLOW FOR ANK YEAR
		for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
		{
			sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(pbd_InRecChild[j]) * d_Retro_Ratio );
			pbd_InRecOwner[j] = ank_mnt [j-CML_AN1]; 
		}
		/******************************************************************************** 
		*******				BDT~LKI TREATMENT 			*********
		*********************************************************************************/
		if( strcmp(pbd_InRecOwner[CML_PATCAT_CT],"BDT") == 0 )
		{
			pbd_InRecOwner[CML_PATCAT_CT] = "EXP";
			pbd_InRecOwner[CML_PATTYP_CT] = "EGPBD";
			n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
			// ------------------------ CHANGE IN ESTIMATES ----------------------//
			sprintf(amount , "%.3f" , atof(pbd_InRecChild[CML_ACMAMT_MC]) * d_Ratio );
			pbd_InRecOwner[CML_ACMAMT_MC] = amount; 
			
			sprintf(total_mnt , "%.3f" , atof(pbd_InRecChild[CML_TOTAUX_MC]) * d_Ratio );
			pbd_InRecOwner[CML_TOTAUX_MC] = total_mnt; 
			
			for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
			{
				sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(pbd_InRecChild[j]) * d_Ratio );
				pbd_InRecOwner[j] = ank_mnt [j-CML_AN1]; 
			}
			pbd_InRecOwner[CML_PATTYP_CT] = "EARBD";
			n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);

			// TRACE FILE FOR DEBUG
			if (n_DEBUG_LEVEL > 1)
			{
				fprintf(Kp_OutputFil_TRACE,
					"EGPI and EARNED RATIO ( CSUOE %s~%s~%s~%s~%s | CSUOER %s~%s~%s~%s~%s | PLC %s | ACMTRS3 %d | FuturePrem Q_1 %.3f | FuturePrem Q %.3f | Upr Q_1 %.3f | Upr Q %.3f | Written_prem %.3f | EGPI Ratio %.3f | EARNED Ratio %.3f )\n", 
					pbd_InRecOwner[CML_CTR_NF],
					pbd_InRecOwner[CML_END_NT],
					pbd_InRecOwner[CML_SEC_NF],
					pbd_InRecOwner[CML_UWY_NF],
					pbd_InRecOwner[CML_UW_NT],
					pbd_InRecOwner[CML_RETCTR_NF],
					pbd_InRecOwner[CML_RETEND_NT],
					pbd_InRecOwner[CML_RETSEC_NF],
					pbd_InRecOwner[CML_RTY_NF],
					pbd_InRecOwner[CML_RETUW_NT],
					pbd_InRecOwner[CML_PLC_NT],
					ACMTRS3,
					d_FUTURE_PREM_PREVQ,
					d_FUTURE_PREM_Q,
					d_UPR_PREVQ, 
					d_UPR_Q, 
					d_ITD_PREM, 
					d_Retro_Ratio,
					d_Ratio
					);
			}
			RETURN_VAL (0);
		}
		/******************************************************************************** 
		*******				DSC~LKI TREATMENT			*********
		*********************************************************************************/
		if( strcmp(pbd_InRecOwner[CML_PATCAT_CT],"DSC") == 0 && ( ACMTRS3 == 2211 || ACMTRS3 == 3201 || ACMTRS3 == 2032 || ACMTRS3 == 3202 ) )
		{
			pbd_InRecOwner[CML_PATCAT_CT] = "EXP";
			pbd_InRecOwner[CML_PATTYP_CT] = "EGPCL";
			n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
			//--------------------------- CHANGE IN ESTIMATES -----------------------//
			sprintf(amount , "%.3f" , atof(pbd_InRecChild[CML_ACMAMT_MC]) * d_Ratio );
			pbd_InRecOwner[CML_ACMAMT_MC] = amount; 
			
			sprintf(total_mnt , "%.3f" , atof(pbd_InRecChild[CML_TOTAUX_MC]) * d_Ratio );
			pbd_InRecOwner[CML_TOTAUX_MC] = total_mnt; 
			
			for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
			{
				sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(pbd_InRecChild[j]) * d_Ratio );
				pbd_InRecOwner[j] = ank_mnt [j-CML_AN1]; 
			}
			pbd_InRecOwner[CML_PATTYP_CT] = "EARCL";
			n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
			
			// TRACE FILE FOR DEBUG
			if (n_DEBUG_LEVEL > 1)
			{
				fprintf(Kp_OutputFil_TRACE,
					"EGPI and EARNED RATIO ( CSUOE %s~%s~%s~%s~%s | CSUOER %s~%s~%s~%s~%s | PLC %s | ACMTRS3 %d | FuturePrem Q_1 %.3f | FuturePrem Q %.3f | Upr Q_1 %.3f | Upr Q %.3f | Written_prem %.3f | EGPI Ratio %.3f | EARNED Ratio %.3f )\n", 
					pbd_InRecOwner[CML_CTR_NF],
					pbd_InRecOwner[CML_END_NT],
					pbd_InRecOwner[CML_SEC_NF],
					pbd_InRecOwner[CML_UWY_NF],
					pbd_InRecOwner[CML_UW_NT],
					pbd_InRecOwner[CML_RETCTR_NF],
					pbd_InRecOwner[CML_RETEND_NT],
					pbd_InRecOwner[CML_RETSEC_NF],
					pbd_InRecOwner[CML_RTY_NF],
					pbd_InRecOwner[CML_RETUW_NT],
					pbd_InRecOwner[CML_PLC_NT],
					ACMTRS3,
					d_FUTURE_PREM_PREVQ,
					d_FUTURE_PREM_Q,
					d_UPR_PREVQ, 
					d_UPR_Q, 
					d_ITD_PREM, 
					d_Retro_Ratio,
					d_Ratio
					);
			}
			RETURN_VAL (0);
		}
		if( strcmp(pbd_InRecOwner[CML_PATCAT_CT],"DSC") == 0 && ( ACMTRS3 == 2053 || ACMTRS3 == 2090 || ACMTRS3 == 2031 || ACMTRS3 == 2035 ) )
		{
			pbd_InRecOwner[CML_PATCAT_CT] = "EXP";
			pbd_InRecOwner[CML_PATTYP_CT] = "EGPAE";
			n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
			//--------------------------- CHANGE IN ESTIMATES -----------------------//
			sprintf(amount , "%.3f" , atof(pbd_InRecChild[CML_ACMAMT_MC]) * d_Ratio );
			pbd_InRecOwner[CML_ACMAMT_MC] = amount;
										
			sprintf(total_mnt , "%.3f" , atof(pbd_InRecChild[CML_TOTAUX_MC]) * d_Ratio );
			pbd_InRecOwner[CML_TOTAUX_MC] = total_mnt; 

			for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
			{
				sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(pbd_InRecChild[j]) * d_Ratio );
				pbd_InRecOwner[j] = ank_mnt [j-CML_AN1]; 
			}
			pbd_InRecOwner[CML_PATTYP_CT] = "EARAE";
			n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
			
			// TRACE FILE FOR DEBUG
			if (n_DEBUG_LEVEL > 1)
			{
				fprintf(Kp_OutputFil_TRACE,
					"EGPI and EARNED RATIO( CSUOE %s~%s~%s~%s~%s | CSUOER %s~%s~%s~%s~%s | PLC %s | ACMTRS3 %d | FuturePrem Q_1 %.3f | FuturePrem Q %.3f | Upr Q_1 %.3f | Upr Q %.3f | Written_prem %.3f | EGPI Ratio %.3f | EARNED Ratio %.3f )\n", 
					pbd_InRecOwner[CML_CTR_NF],
					pbd_InRecOwner[CML_END_NT],
					pbd_InRecOwner[CML_SEC_NF],
					pbd_InRecOwner[CML_UWY_NF],
					pbd_InRecOwner[CML_UW_NT],
					pbd_InRecOwner[CML_RETCTR_NF],
					pbd_InRecOwner[CML_RETEND_NT],
					pbd_InRecOwner[CML_RETSEC_NF],
					pbd_InRecOwner[CML_RTY_NF],
					pbd_InRecOwner[CML_RETUW_NT],
					pbd_InRecOwner[CML_PLC_NT],
					ACMTRS3,
					d_FUTURE_PREM_PREVQ,
					d_FUTURE_PREM_Q,
					d_UPR_PREVQ, 
					d_UPR_Q, 
					d_ITD_PREM, 
					d_Retro_Ratio,
					d_Ratio
					);
			}
			RETURN_VAL (0);			
		}
		/******************************************************************************** 
		*******				RAD~LKI TREATMENT			*********
		*********************************************************************************/
		if( strcmp(pbd_InRecOwner[CML_PATCAT_CT],"RAD") == 0 &&  ACMTRS3 == 3201 )
		{
			pbd_InRecOwner[CML_PATCAT_CT] = "EXP";
			pbd_InRecOwner[CML_PATTYP_CT] = "EGPRA"; 
			n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
			// ------------------------ CHANGE IN ESTIMATES ----------------------// 
			sprintf(amount , "%.3f" , atof(pbd_InRecChild[CML_ACMAMT_MC]) * d_Ratio );
			pbd_InRecOwner[CML_ACMAMT_MC] = amount; 
			
			sprintf(total_mnt , "%.3f" , atof(pbd_InRecChild[CML_TOTAUX_MC]) * d_Ratio );
			pbd_InRecOwner[CML_TOTAUX_MC] = total_mnt; 
			
			for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
			{
				sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(pbd_InRecChild[j]) * d_Ratio );
				pbd_InRecOwner[j] = ank_mnt [j-CML_AN1]; 
			}
			pbd_InRecOwner[CML_PATTYP_CT] = "EARRA";
			n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
			
			// TRACE FILE FOR DEBUG
			if (n_DEBUG_LEVEL > 1)
			{
				fprintf(Kp_OutputFil_TRACE,
					"RETRO EGPI and EARNED RATIO(CSUOE %s~%s~%s~%s~%s | CSUOER %s~%s~%s~%s~%s| PLC %s | ACMTRS3 %d | FuturePrem Q_1 %.3f | FuturePrem Q %.3f | Upr Q_1 %.3f | Upr Q %.3f | Written_prem %.3f | Assumed Ratio %.3f | Ratio %.3f )\n", 
					pbd_InRecOwner[CML_CTR_NF],
					pbd_InRecOwner[CML_END_NT],
					pbd_InRecOwner[CML_SEC_NF],
					pbd_InRecOwner[CML_UWY_NF],
					pbd_InRecOwner[CML_UW_NT],
					pbd_InRecOwner[CML_RETCTR_NF],
					pbd_InRecOwner[CML_RETEND_NT],
					pbd_InRecOwner[CML_RETSEC_NF],
					pbd_InRecOwner[CML_RTY_NF],
					pbd_InRecOwner[CML_RETUW_NT],
					pbd_InRecOwner[CML_PLC_NT],
					ACMTRS3,
					d_FUTURE_PREM_PREVQ,
					d_FUTURE_PREM_Q,
					d_UPR_PREVQ, 
					d_UPR_Q, 
					d_ITD_PREM, 
					d_Retro_Ratio,
					d_Ratio
					);
			}
			RETURN_VAL (0);				
		}	
	}
	
	RETURN_VAL (0);
}
		
/**===========================================================================
objet 	: Fonction lance a chaque ligne synchro entre CASHFLOW et DSC_RAD_LKI
retour 	:	0		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==============================================================================*/
int n_PereSansFils_FORWARD( char **pbd_InRecOwner )
{
	/* R03-01bis:Case where discount forward not found in EGPI Expected Position calculation */
	
	DEBUT_FCT("n_PereSansFils_FORWARD");
	int 	j;
	
	pbd_InRecOwner[CML_COMMENT] 	= "FWD not found";
	pbd_InRecOwner[CML_ACMAMT_MC] 	= "0.000";
	pbd_InRecOwner[CML_TOTAUX_MC] 	= "0.000";
	
	for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
	{
		pbd_InRecOwner[j] 	= "0.000";
	}
	
	if( strcmp(pbd_InRecOwner[CML_ACMTRS3_NT2],"3201") == 0 && strcmp(pbd_InRecOwner[CML_PATCAT_CT],"RAD") == 0 && strcmp(pbd_InRecOwner[CML_PATTYP_CT],"LKI") == 0 )
	{
		pbd_InRecOwner[CML_PATCAT_CT] 	= "EXP";
		pbd_InRecOwner[CML_PATTYP_CT] 	= "EGPRA"; 
		n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
		pbd_InRecOwner[CML_PATTYP_CT] 	= "EARRA"; 
		n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
		RETURN_VAL (0);
	}
	else if( strcmp(pbd_InRecOwner[CML_PATCAT_CT],"BDT") == 0 && strcmp(pbd_InRecOwner[CML_PATTYP_CT], "LKI") == 0 )
	{
		pbd_InRecOwner[CML_PATCAT_CT] 	= "EXP";
		pbd_InRecOwner[CML_PATTYP_CT] 	= "EGPBD";
		n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
		pbd_InRecOwner[CML_PATTYP_CT] 	= "EARBD"; 
		n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
		RETURN_VAL (0);
	}
	else
	{
		switch( atoi( pbd_InRecOwner[CML_ACMTRS3_NT2] ) )
		{
			case 1051: 
			{
				pbd_InRecOwner[CML_PATCAT_CT] 	= "EXP";
				pbd_InRecOwner[CML_PATTYP_CT] 	= "EGPPR";
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
				pbd_InRecOwner[CML_PATTYP_CT] 	= "EARPR"; 
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
				break;
			}
			case 2211:
			case 3201:
			case 3202:
			case 2032:
			{
				pbd_InRecOwner[CML_PATCAT_CT] 	= "EXP";
				pbd_InRecOwner[CML_PATTYP_CT] 	= "EGPCL";
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
				pbd_InRecOwner[CML_PATTYP_CT] 	= "EARCL"; 
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
				break;
			}
			case 2053:
			case 2090:
			case 2031:
			case 2035:
			{
				pbd_InRecOwner[CML_PATCAT_CT] 	= "EXP";
				pbd_InRecOwner[CML_PATTYP_CT] 	= "EGPAE";
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
				pbd_InRecOwner[CML_PATTYP_CT] 	= "EARAE"; 
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
				break;
			}
			default  : break;
		}
	}	
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction lance a chaque ligne synchro entre CASHFLOW et DSC_RAD_LKI
retour 	:	0		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==============================================================================*/
int n_FilsSansPere_FORWARD( char **pbd_InRecChild )
{
	DEBUT_FCT("n_ActionLigne_FORWARD");
	
	RETURN_VAL (0);
}

/**===============================================================================
objet 	: Fonction initialisation synchro entre CASHFLOW et DSC_RAD_LKI
retour 	:	0	---> traitement correctement effectue
==================================================================================*/
int n_Init_CASHFLOW_Q(T_RUPTURE_SYNC_VAR  *pbd_Sync)
{
	DEBUT_FCT("n_Init_CASHFLOW_Q");

	memset( pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;
	n_OpenFileAppl ("ESFC3692_I2", "rt", &(pbd_Sync->pf_InputFil));

	pbd_Sync->ConditionEndSync  	= n_CondSync_CASHFLOW_Q ;        
	pbd_Sync->n_ActionLigne     	= n_ActionLigne_CASHFLOW_Q ;           
	pbd_Sync->c_Separ      			= '~' ;
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction de test de synchro entre CASHFLOW et DSC_RAD_LKI
retour 	:	0  	---> synchro
		1  	---> non trouve
==============================================================================*/
int n_CondSync_CASHFLOW_Q( char **pbd_InRecOwner , char **pbd_InRecChild )
{
	DEBUT_FCT("n_CondSync_CASHFLOW_Q");
	int ret;
	
	if ( ( ret = strcmp( pbd_InRecOwner[CML_CTR_NF], pbd_InRecChild[CML_CTR_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_END_NT] ) - atoi( pbd_InRecChild[CML_END_NT] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_SEC_NF] ) - atoi( pbd_InRecChild[CML_SEC_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_UWY_NF], pbd_InRecChild[CML_UWY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_UW_NT] ) - atoi( pbd_InRecChild[CML_UW_NT] ) ) != 0 ) 	return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_RETCTR_NF], pbd_InRecChild[CML_RETCTR_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_RETEND_NT]) - atoi(pbd_InRecChild[CML_RETEND_NT])) != 0 ) return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_RETSEC_NF]) - atoi( pbd_InRecChild[CML_RETSEC_NF])) != 0)	return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_RTY_NF], pbd_InRecChild[CML_RTY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_RETUW_NT]) - atoi( pbd_InRecChild[CML_RETUW_NT] )) != 0 ) return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_PLC_NT]) - atoi( pbd_InRecChild[CML_PLC_NT] )) != 0 ) 	return ret;
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction lance a chaque ligne synchro entre CASHFLOW et DSC_RAD_LKI
retour 	:	0	---> traitement correctement effectue
		ERR 	---> probleme rencontre
==============================================================================*/
int n_ActionLigne_CASHFLOW_Q( char **pbd_InRecOwner ,char **pbd_InRecChild )
{
	DEBUT_FCT("n_ActionLigne_CASHFLOW_Q");
	double 	d_taux = 1;
	char 	MsgAno[200];
	
	if ( strcmp( pbd_InRecOwner[GT_EGPICUR_CF], pbd_InRecChild[CML_RETCUR_CF] ) != 0 )
	{	
		d_taux = d_GetTaux( Kp_InputFilExc, (char) atoi( pbd_InRecChild[CML_SSD_CF] ), atoi( pbd_InRecChild[CML_BALSHEY_NF] ), pbd_InRecChild[CML_RETCUR_CF], pbd_InRecOwner[GT_EGPICUR_CF] );
		if ( d_taux < 0 )
		{
			sprintf( MsgAno, "No rate for RETRO :(CURR %s - CURR %s - CTR %s - END %s - SEC %s - UWY %s - UW %s - BALSHEY %s)\n", 
			pbd_InRecChild[CML_RETCUR_CF], 
			pbd_InRecOwner[GT_EGPICUR_CF], 
			pbd_InRecChild[CML_RETCTR_NF],  
			pbd_InRecChild[CML_RETEND_NT], 
			pbd_InRecChild[CML_RETSEC_NF], 
			pbd_InRecChild[CML_RTY_NF], 
			pbd_InRecChild[CML_RETUW_NT], 
			pbd_InRecChild[CML_BALSHEY_NF] );
			
			n_WriteAno( MsgAno );
			d_taux 	= 1;	
		}
	}
	if( strcmp( pbd_InRecChild[CML_ACMTRS3_NT2], "1051" ) == 0 )
	{
		d_FUTURE_PREM_Q += atof(pbd_InRecChild[CML_ACMAMT_MC]) * d_taux;
		//printf("FUTURE PREM Q :  %.3f \n",d_FUTURE_PREM_Q);
	}
	else if( strcmp( pbd_InRecChild[CML_ACMTRS3_NT2], "2051" ) == 0 )
	{
		d_FUT_FIXED_CHARGE += atof(pbd_InRecChild[CML_ACMAMT_MC]) * d_taux;
		//printf("FUT FIXED CHARGE :  %.3f \n",d_FUT_FIXED_CHARGE);
	}
	else
	{
		d_FUTURE_OVERRIDE_COM += atof(pbd_InRecChild[CML_ACMAMT_MC]) * d_taux;
		//printf("FUT OVERRIDE COMISSION :  %.3f \n",d_FUTURE_OVERRIDE_COM);
	}
	
	RETURN_VAL (0);
}

/**===============================================================================
objet 	: Fonction initialisation synchro entre CASHFLOW Q-1 et IADPERICASE
retour 	:	0	---> traitement correctement effectue
==================================================================================*/
int n_Init_CASHFLOW_PREVQ(T_RUPTURE_SYNC_VAR  *pbd_Sync)
{
	DEBUT_FCT("n_Init_CASHFLOW_PREVQ");

	memset( pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;
	
	n_OpenFileAppl ("ESFC3692_I3", "rt", &(pbd_Sync->pf_InputFil));

	pbd_Sync->ConditionEndSync  	= n_CondSync_CASHFLOW_PREVQ ;        
	pbd_Sync->n_ActionLigne     	= n_ActionLigne_CASHFLOW_PREVQ ;           
	pbd_Sync->c_Separ      		= '~' ;
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction de test de synchro entre CASHFLOW Q-1 et PERICASE
retour 	:	0  		---> synchro
			1  		---> non trouve
==============================================================================*/
int n_CondSync_CASHFLOW_PREVQ( char **pbd_InRecOwner , char **pbd_InRecChild )
{
	DEBUT_FCT("n_CondSync_CASHFLOW_PREVQ");
	int ret;
	
	if ( ( ret = strcmp( pbd_InRecOwner[CML_CTR_NF], pbd_InRecChild[CML_CTR_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_END_NT] ) - atoi( pbd_InRecChild[CML_END_NT] ) ) != 0 ) 	return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[CML_SEC_NF] ) - atoi( pbd_InRecChild[CML_SEC_NF] ) ) != 0 ) 	return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_UWY_NF], pbd_InRecChild[CML_UWY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_UW_NT] ) - atoi( pbd_InRecChild[CML_UW_NT] ) ) != 0 ) 	return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_RETCTR_NF], pbd_InRecChild[CML_RETCTR_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_RETEND_NT]) - atoi(pbd_InRecChild[CML_RETEND_NT])) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[CML_RETSEC_NF]) - atoi( pbd_InRecChild[CML_RETSEC_NF])) != 0)	return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_RTY_NF], pbd_InRecChild[CML_RTY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_RETUW_NT]) - atoi( pbd_InRecChild[CML_RETUW_NT] )) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[CML_PLC_NT]) - atoi( pbd_InRecChild[CML_PLC_NT] )) != 0 ) 	return ret ;
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction lance a chaque ligne synchro entre CASHFLOW Q-1 et DSC_RAD_LKI
retour 	:	0		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==============================================================================*/
int n_ActionLigne_CASHFLOW_PREVQ( char **pbd_InRecOwner ,char **pbd_InRecChild )
{
	DEBUT_FCT("n_ActionLigne_CASHFLOW_PREVQ");
	double 	d_taux = 1;
	char 	MsgAno[200];
	
	//if( strcmp( pbd_InRecOwner[23], "02N000654") == 0 && strcmp( pbd_InRecOwner[26], "2020" ) == 0 && strcmp( pbd_InRecOwner[35], "11" ) == 0 )
	if ( strcmp( pbd_InRecOwner[GT_EGPICUR_CF], pbd_InRecChild[CML_RETCUR_CF] ) != 0 )
	{	
		d_taux = d_GetTaux( Kp_InputFilExc, (char) atoi( pbd_InRecChild[CML_SSD_CF] ), atoi( pbd_InRecChild[CML_BALSHEY_NF] ), pbd_InRecChild[CML_RETCUR_CF], pbd_InRecOwner[GT_EGPICUR_CF] );
		if ( d_taux < 0 )
		{
			sprintf( MsgAno, "No rate for RETRO :(CURR %s - CURR %s - CTR %s - END %s - SEC %s - UWY %s - UW %s - BALSHEY %s)\n", 
			pbd_InRecChild[CML_RETCUR_CF], 
			pbd_InRecOwner[GT_EGPICUR_CF], 
			pbd_InRecChild[CML_RETCTR_NF],  
			pbd_InRecChild[CML_RETEND_NT], 
			pbd_InRecChild[CML_RETSEC_NF], 
			pbd_InRecChild[CML_RTY_NF], 
			pbd_InRecChild[CML_RETUW_NT], 
			pbd_InRecChild[CML_BALSHEY_NF] );
			
			n_WriteAno( MsgAno );
			d_taux 	= 1;	
		}
	}		
	d_FUTURE_PREM_PREVQ += atof(pbd_InRecChild[CML_ACMAMT_MC]) * d_taux;
	
	RETURN_VAL (0);
}


/**==============================================================================
objet 	: Fonction initialisation synchro entre ITD_PREM et DSC_RAD_LKI
retour 	:	0	---> traitement correctement effectue
=================================================================================*/
int n_Init_ITD_PREM(T_RUPTURE_SYNC_VAR  *pbd_Sync)
{
	DEBUT_FCT("n_Init_ITD_PREM");

	memset( pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;
	n_OpenFileAppl ("ESFC3692_I4", "rt", &(pbd_Sync->pf_InputFil));

	pbd_Sync->ConditionEndSync  	= n_CondSync_ITD_PREM ;        
	pbd_Sync->n_ActionLigne     	= n_ActionLigne_ITD_PREM ;           
	pbd_Sync->c_Separ      			= '~' ;
	
	RETURN_VAL (0);
}

/**===============================================================================
objet 	: Fonction de test conditions synchro entre ITD_PREM et DSC_RAD_LKI
retour 	:	0		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==================================================================================*/
int n_CondSync_ITD_PREM( char **pbd_InRecOwner , char **pbd_InRecChild )
{
	DEBUT_FCT("n_CondSync_ITD_PREM");
	int ret;
	
	if ( ( ret = strcmp( pbd_InRecOwner[CML_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_END_NT] ) - atoi( pbd_InRecChild[GT_END_NT] ) ) != 0 ) 	return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[CML_SEC_NF] ) - atoi( pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) 	return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_UW_NT] ) - atoi( pbd_InRecChild[GT_UW_NT] ) ) != 0 ) 		return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_RETCTR_NF], pbd_InRecChild[GT_RETCTR_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_RETEND_NT]) - atoi(pbd_InRecChild[GT_RETEND_NT])) != 0 ) 	return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[CML_RETSEC_NF]) - atoi( pbd_InRecChild[GT_RETSEC_NF])) != 0)	return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_RTY_NF], pbd_InRecChild[GT_RTY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_RETUW_NT]) - atoi( pbd_InRecChild[GT_RETUW_NT] )) != 0 ) 	return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[CML_PLC_NT]) - atoi( pbd_InRecChild[GT_PLC_NT] )) != 0 ) 		return ret ;
	
	RETURN_VAL (0);
}

/**=================================================================================
objet 	: 	Fonction lance a chaque ligne synchro entre ITD_PREM et DSC_RAD_LKI
retour 	:	0	---> traitement correctement effectue
====================================================================================*/ 
int n_ActionLigne_ITD_PREM( char **pbd_InRecOwner ,char **pbd_InRecChild )
{
	DEBUT_FCT("n_ActionLigne_ITD_PREM");
	double 	d_taux = 1;
	char 	MsgAno[200];
		
	//if( strcmp( pbd_InRecChild[GT_RETCTR_NF], "02N000653") == 0 && strcmp( pbd_InRecChild[GT_RTY_NF], "2019" ) == 0  && strcmp( pbd_InRecChild[GT_RTO_NF], "12753" ) == 0 )
	if ( strcmp( pbd_InRecOwner[GT_EGPICUR_CF], pbd_InRecChild[GT_RETCUR_CF] ) != 0 )
	{	
		d_taux = d_GetTaux( Kp_InputFilExc, (char) atoi( pbd_InRecChild[GT_SSD_CF] ), atoi( pbd_InRecChild[GT_BALSHEY_NF] ), pbd_InRecChild[GT_RETCUR_CF], pbd_InRecOwner[GT_EGPICUR_CF] );
		if ( d_taux < 0 )
		{
			sprintf( MsgAno, "No rate for RETRO :(CURR %s - CURR %s - CTR %s - END %s - SEC %s - UWY %s - UW %s - BALSHEY %s)\n", 
			pbd_InRecChild[GT_RETCUR_CF], 
			pbd_InRecOwner[GT_EGPICUR_CF], 
			pbd_InRecChild[GT_RETCTR_NF],  
			pbd_InRecChild[GT_RETEND_NT], 
			pbd_InRecChild[GT_RETSEC_NF], 
			pbd_InRecChild[GT_RTY_NF], 
			pbd_InRecChild[GT_RETUW_NT], 
			pbd_InRecChild[GT_BALSHEY_NF] );
			
			n_WriteAno( MsgAno );
			d_taux 	= 1;	
		}
	}
	if( strcmp( pbd_InRecChild[RET_TRN_CODE], "1010" ) == 0 )
	{		
		d_ITD_PREM += atof(pbd_InRecChild[GT_RETAMT_M]) * d_taux;
		//printf(" d_ITD_PREM :  %.3f \n",atof(pbd_InRecChild[GT_RETAMT_M]) * d_taux);
	}
	else
	{
		d_FIXED_CHARGE += atof(pbd_InRecChild[GT_RETAMT_M]) * d_taux;
		//printf(" SUM FIXED CHARGE :  %.3f \n",d_FIXED_CHARGE);
	}
	
	RETURN_VAL (0);
}

/**==============================================================================
objet 	: 	Fonction initialisation synchro entre UPR_Q et DSC_RAD_LKI
retour 	:	0	---> traitement correctement effectue
=================================================================================*/
int n_Init_UPR_Q(T_RUPTURE_SYNC_VAR  *pbd_Sync)
{
	DEBUT_FCT("n_Init_UPR_Q");

	memset( pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;
	n_OpenFileAppl ("ESFC3692_I5", "rt", &(pbd_Sync->pf_InputFil));

	pbd_Sync->ConditionEndSync  	= n_CondSync_UPR_Q ;        
	pbd_Sync->n_ActionLigne     	= n_ActionLigne_UPR_Q ;           
	pbd_Sync->c_Separ      			= '~' ;
	
	RETURN_VAL (0);
}

/**===============================================================================
objet 	: 	Fonction de test conditions synchro entre UPR_Q et DSC_RAD_LKI
retour 	:	0		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==================================================================================*/
int n_CondSync_UPR_Q( char **pbd_InRecOwner , char **pbd_InRecChild )
{
	DEBUT_FCT("n_CondSync_UPR_Q");
	int ret;
	
	if ( ( ret = strcmp( pbd_InRecOwner[CML_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_END_NT] ) - atoi( pbd_InRecChild[GT_END_NT] ) ) != 0 ) 	return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[CML_SEC_NF] ) - atoi( pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) 	return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_UW_NT] ) - atoi( pbd_InRecChild[GT_UW_NT] ) ) != 0 ) 		return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_RETCTR_NF], pbd_InRecChild[GT_RETCTR_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_RETEND_NT]) - atoi(pbd_InRecChild[GT_RETEND_NT])) != 0 ) 	return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[CML_RETSEC_NF]) - atoi( pbd_InRecChild[GT_RETSEC_NF])) != 0)	return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_RTY_NF], pbd_InRecChild[GT_RTY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_RETUW_NT]) - atoi( pbd_InRecChild[GT_RETUW_NT] )) != 0 ) 	return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[CML_PLC_NT]) - atoi( pbd_InRecChild[GT_PLC_NT] )) != 0 ) 		return ret ;
	
	RETURN_VAL (0);
}

/**=================================================================================
objet 	: 	Fonction lance a chaque ligne synchro entre UPR_Q et DSC_RAD_LKI
retour 	:	0	---> traitement correctement effectue
====================================================================================*/ 
int n_ActionLigne_UPR_Q( char **pbd_InRecOwner ,char **pbd_InRecChild )
{
	DEBUT_FCT("n_ActionLigne_UPR_Q");
	double 	d_taux = 1 ;
	char 	MsgAno[200];
	
	if ( strcmp( pbd_InRecOwner[GT_EGPICUR_CF], pbd_InRecChild[GT_RETCUR_CF] ) != 0 )
	{	
		d_taux = d_GetTaux( Kp_InputFilExc, (char) atoi( pbd_InRecChild[GT_SSD_CF] ), atoi( pbd_InRecChild[GT_BALSHEY_NF] ), pbd_InRecChild[GT_RETCUR_CF], pbd_InRecOwner[GT_EGPICUR_CF] );
		if ( d_taux < 0 )
		{
			sprintf( MsgAno, "No rate for RETRO :(CURR %s - CURR %s - CTR %s - END %s - SEC %s - UWY %s - UW %s - BALSHEY %s)\n", 
			pbd_InRecChild[GT_RETCUR_CF], 
			pbd_InRecOwner[GT_EGPICUR_CF], 
			pbd_InRecChild[GT_RETCTR_NF],  
			pbd_InRecChild[GT_RETEND_NT], 
			pbd_InRecChild[GT_RETSEC_NF], 
			pbd_InRecChild[GT_RTY_NF], 
			pbd_InRecChild[GT_RETUW_NT], 
			pbd_InRecChild[GT_BALSHEY_NF] );
			
			n_WriteAno( MsgAno );
			d_taux 	= 1;	
		}
	}
	d_UPR_Q += atof(pbd_InRecChild[GT_RETAMT_M]) * d_taux;
	
	RETURN_VAL (0);
}


/**==============================================================================
objet 	: 	Fonction initialisation synchro entre UPR_PREVQ et DSC_RAD_LKI
retour 	:	0	---> traitement correctement effectue
=================================================================================*/
int n_Init_UPR_PREVQ(T_RUPTURE_SYNC_VAR  *pbd_Sync)
{
	DEBUT_FCT("n_Init_UPR_PREVQ");

	memset( pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;
	n_OpenFileAppl ("ESFC3692_I6", "rt", &(pbd_Sync->pf_InputFil));

	pbd_Sync->ConditionEndSync  	= n_CondSync_UPR_PREVQ ;        
	pbd_Sync->n_ActionLigne     	= n_ActionLigne_UPR_PREVQ ;
	pbd_Sync->c_Separ      			= '~' ;
	
	RETURN_VAL (0);
}

/**===============================================================================
objet 	: 	Fonction de test conditions synchro entre RITD_PREM et DSC_RAD_LKI
retour 	:	0		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==================================================================================*/
int n_CondSync_UPR_PREVQ( char **pbd_InRecOwner , char **pbd_InRecChild )
{
	DEBUT_FCT("n_CondSync_UPR_PREVQ");
	int ret;
	
	if ( ( ret = strcmp( pbd_InRecOwner[CML_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_END_NT] ) - atoi( pbd_InRecChild[GT_END_NT] ) ) != 0 ) 	return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[CML_SEC_NF] ) - atoi( pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) 	return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_UW_NT] ) - atoi( pbd_InRecChild[GT_UW_NT] ) ) != 0 ) 		return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_RETCTR_NF], pbd_InRecChild[GT_RETCTR_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_RETEND_NT]) - atoi(pbd_InRecChild[GT_RETEND_NT])) != 0 ) 	return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[CML_RETSEC_NF]) - atoi( pbd_InRecChild[GT_RETSEC_NF])) != 0)	return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_RTY_NF], pbd_InRecChild[GT_RTY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_RETUW_NT]) - atoi( pbd_InRecChild[GT_RETUW_NT] )) != 0 ) 	return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[CML_PLC_NT]) - atoi( pbd_InRecChild[GT_PLC_NT] )) != 0 ) 		return ret ;
	
	RETURN_VAL (0);
}

/**=================================================================================
objet 	: 	Fonction lance a chaque ligne synchro entre RITD_PREM et DSC_RAD_LKI
retour 	:	0	---> traitement correctement effectue
====================================================================================*/ 
int n_ActionLigne_UPR_PREVQ( char **pbd_InRecOwner ,char **pbd_InRecChild )
{
	DEBUT_FCT("n_ActionLigne_Retro_UPR_PREVQ");
	double 	d_taux = 1;
	char 	MsgAno[200];

	if ( strcmp( pbd_InRecOwner[GT_EGPICUR_CF], pbd_InRecChild[GT_RETCUR_CF] ) != 0 )
	{	
		d_taux = d_GetTaux( Kp_InputFilExc, (char) atoi( pbd_InRecChild[GT_SSD_CF] ), atoi( pbd_InRecChild[GT_BALSHEY_NF] ), pbd_InRecChild[GT_RETCUR_CF], pbd_InRecOwner[GT_EGPICUR_CF] );
		if ( d_taux < 0 )
		{
			sprintf( MsgAno, "No rate for RETRO :(CURR %s - CURR %s - CTR %s - END %s - SEC %s - UWY %s - UW %s - BALSHEY %s)\n", 
			pbd_InRecChild[GT_RETCUR_CF], 
			pbd_InRecOwner[GT_EGPICUR_CF], 
			pbd_InRecChild[GT_RETCTR_NF],  
			pbd_InRecChild[GT_RETEND_NT], 
			pbd_InRecChild[GT_RETSEC_NF], 
			pbd_InRecChild[GT_RTY_NF], 
			pbd_InRecChild[GT_RETUW_NT], 
			pbd_InRecChild[GT_BALSHEY_NF] );
			
			n_WriteAno( MsgAno );
			d_taux 	= 1;	
		}
	}
	d_UPR_PREVQ += atof(pbd_InRecChild[GT_RETAMT_M]) * d_taux;
	
	RETURN_VAL (0);
}