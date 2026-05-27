/**=======================================================================================
APPLICATION NAME          	: ACF/PCA: Expenses calculation
SOURCE NAME                 : ESFC3635.c
REVISION                   	: V1
CREATION DATE              	: 09/2021
AUTOR                       : L.ELFAHIM
TYPE             			: Batch 
-----------------------------------------------------------------------------------------
DESCRIPTION :
	THIS PROGRAM MANIPULATES SEVERAL INPUT FILES TO MANAGE :
	ACF/PCA: EXPENSES CALCULATION
-----------------------------------------------------------------------------------------
MODIFICATION HISTORY :
26/08/2021      LEL   	97351       ACF/PCA: EXPENSES CALCULATION	
=========================================================================================*/

/**----------------------------------------------------
	Inclusion des fichiers entete 
-------------------------------------------------------*/
#include <utctlib.h>
#include <estserv.h>
#include <stdarg.h>
#include <util.h>
#include "struct.h"
#include "estutil.c"
#include "ESFC3630.h"
#include "ESTC3001.h"

/** ESTC3001.h Fichier commun avec des autres programmes contenant la structure du fichier GTSII_CASHFLOW */

/**-------------------------------------------------
	Traitemant principale du programme                      
----------------------------------------------------*/
int main( int argc,  char *argv[] )
{
	InitSig ();

	if (n_BeginPgm (argc, argv) == ERR)
		ExitPgm (ERR_XX, "");
	
	strcpy( Ksz_CloDat, psz_GetCharArgv(1) );
	strcpy( Norme_CF, psz_GetCharArgv(2) );
	
	/** Call function to retrieve norme */
	Norme = n_GetNorme( Norme_CF );
	if( Norme == 'R' )
	{
		n_WriteAno( "ERROR : Norme Incorrecte \n" );
		exit(1);
	}
	
	/** Eclatement de la date AAAAMMJJ en 3 chaines de caractere */
	sscanf( Ksz_CloDat, "%4s%2s%2s", Ksz_Annee_bilan, Ksz_Mois_bilan, Ksz_Jour_bilan );
	
	/***************************************************************************/
	/**  Ouverture Des fichiers en entree et Initialisation des structures     */
	/***************************************************************************/
	
	if ( n_OpenFileAppl ( "ESFC3635_O1","wt",&Kp_OutputBatch ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_OpenFileAppl ( "ESFC3635_O2","wt",&Kp_OutputANO ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_OpenFileAppl ( "ESFC3635_O3","wt",&Kp_OutputFil_EXPENSES ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	/** Initialisation de la variable pbd_Rupture */
	if ( n_InitRupture(&pbd_Rupture) ) 
		ExitPgm ( ERR_XX , "" );

	/** Initialisation de la variable pbd_Sync */
	if ( n_InitSync(&pbd_Sync) ) 
		ExitPgm ( ERR_XX , "" );
	
	/** Initialisation de la variable Kbd_Rupt_CASHFLOW */
	if ( n_Init_CASHFLOW(&Kbd_Rupt_CASHFLOW) ) 
		ExitPgm ( ERR_XX , "" );

	/** Lancement du traitement du fichier maitre */
	if (n_ProcessingRuptureVar(&pbd_Rupture) == ERR) 
		ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
	
	/***************************************************************************/
	/**   Fermeture Des fichiers ouverts                                       */
	/***************************************************************************/
	if ( n_CloseFileAppl( "ESFC3635_I1", &( pbd_Rupture.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3635_I2", &( pbd_Sync.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3635_I3", &( Kbd_Rupt_CASHFLOW.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3635_O1", &Kp_OutputBatch ) == ERR ) 
		ExitPgm( ERR_XX , "" );
	
	if (n_CloseFileAppl("ESFC3635_O2", &Kp_OutputANO) == ERR)          
		ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier OUTPUT_FILE_ANO");
	
	if ( n_CloseFileAppl( "ESFC3635_O3", &Kp_OutputFil_EXPENSES ) == ERR ) 
		ExitPgm( ERR_XX , "" );
	
	if ( n_EndPgm () == ERR )
		ExitPgm (ERR_XX, "");
	
	exit(0);
}

/**============================================================================
objet : Fonction d'initialisation de la variable de rupture du fichier maitre.
retour 	:	0  		---> traitement correctement effectue
			ERR 	---> probleme rencontre
===============================================================================*/
int n_InitRupture(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_InitRupture");
	
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

	if ( n_OpenFileAppl ("ESFC3635_I1", "rt", &(pbd_Rupt->pf_InputFil)))
		RETURN_VAL (ERR);

	pbd_Rupt->n_NbRupture 			= 0 ;
	pbd_Rupt->n_ActionLigne 		= n_ActionLigneMaitre;
	pbd_Rupt->c_Separ 				= '~' ;
	
	RETURN_VAL (0);
}


/**===========================================================================
objet 	: Function launched for each perimeter line
==============================================================================*/
int n_ActionLigneMaitre( char **ptb_InRec_Cur )
{
	DEBUT_FCT("n_ActionLigneMaitre");
	
	if( strcmp(ptb_InRec_Cur[PER_RET_FLAG], "YES") == 0 )
	{	
		if (( *ptb_InRec_Cur[RET_INI_STATUS] == '2' && atoi(ptb_InRec_Cur[RET_FIRST_CLO_D]) == atoi(Ksz_CloDat)) 
			|| *ptb_InRec_Cur[RET_INI_STATUS] == '1' 
		)
		{
			n_ProcessingRuptureSyncVar( &pbd_Sync, ptb_InRec_Cur );
		}
		else if (*ptb_InRec_Cur[RET_INI_STATUS] == '2' && atoi(ptb_InRec_Cur[RET_FIRST_CLO_D]) < atoi(Ksz_CloDat))
		{
			n_ProcessingRuptureSyncVar( &Kbd_Rupt_CASHFLOW, ptb_InRec_Cur );
		}	
	}
	RETURN_VAL (0);
}

/**===============================================================================
objet 	: Fonction initialisation synchro entre CASHFLOW et PERIMETER
retour 	:	0	---> traitement correctement effectue
==================================================================================*/

int n_InitSync(T_RUPTURE_SYNC_VAR  *pbd_Sync)
{
	DEBUT_FCT("n_InitSync");
	
	memset( pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;
	n_OpenFileAppl ("ESFC3635_I2", "rt", &(pbd_Sync->pf_InputFil));
	
	pbd_Sync->ConditionEndSync  	= n_ConditionSync ;        
	pbd_Sync->n_ActionLigne     	= n_ActionLigneSync ;
	pbd_Sync->n_PereSansFils     	= n_PereSansFils_Sync;		
	pbd_Sync->c_Separ      			= '~' ;
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction de test de synchro entre CASHFLOW et PERIMETER
retour 	:	0  	---> synchro
			1  	---> non trouve
==============================================================================*/
int n_ConditionSync( char **pbd_InRecOwner , char **pbd_InRecChild )
{
	DEBUT_FCT("n_ConditionSync");
	int ret;
	
	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[CML_RETCTR_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[PER_END_NT] ) - atoi( pbd_InRecChild[CML_RETEND_NT] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( pbd_InRecOwner[PER_SEC_NF] ) - atoi( pbd_InRecChild[CML_RETSEC_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[CML_RTY_NF] ) ) != 0 ) 				return ret;
	if ( ( ret = atoi( pbd_InRecOwner[PER_UW_NT] ) - atoi( pbd_InRecChild[CML_RETUW_NT] ) ) != 0 ) 		return ret;
	if ( ( ret = atoi( pbd_InRecOwner[PER_PLC_NT]) - atoi( pbd_InRecChild[CML_PLC_NT] )) != 0 ) 		return ret;
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction de test de synchro entre CASHFLOW et PERIMETER
retour 	:	0  	---> synchro
			1  	---> non trouve
==============================================================================*/
int n_ActionLigneSync( char **pbd_InRecOwner , char **pbd_InRecChild )
{
	DEBUT_FCT("n_ActionLigneSync");
	
	int j;
	double AMT_ANk, AMT_TOTAL, AcqExpPaid = 0.0;
	char amount[AMN_LEN], amount_ANk[65][AMN_LEN], amount_Total[AMN_LEN];
	
	AMT_TOTAL 	= atof(pbd_InRecChild[CML_TOTAUX_MC]);
	
	memset(amount,0, sizeof(amount));
	memset(amount_Total,0, sizeof(amount_Total));
	
	/** CHECK IF THE COLUMN EXIST */
	if( strcmp(pbd_InRecChild[CSM_Q], "") != 0 )
	{
		/** CALCULATION OF THE CASHFLOW FOR ACMAMT_M */
		pbd_InRecChild[CML_ACMAMT_MC] = pbd_InRecChild[CML_TOTAUX_MC];
			
		/** CALCULATION OF THE CASHFLOW FOR TOTAL AMOUNTS */
		sprintf(amount_Total , "%.3f" , AMT_TOTAL * atof(pbd_InRecChild[CSM_Q]) );
		pbd_InRecChild[CML_TOTAUX_MC] = amount_Total;  
			
		/** CALCULATION OF THE CASHFLOW FOR ANK YEAR */
		for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
		{
			AMT_ANk = atof(pbd_InRecChild[j]);
			sprintf( amount_ANk [j-CML_AN1], "%.3f" , AMT_ANk * atof(pbd_InRecChild[CSM_Q]) );
			pbd_InRecChild[j] = amount_ANk [j-CML_AN1];
		}
		
		pbd_InRecChild[CML_BALSHEY_NF] 		= Ksz_Annee_bilan ;
		pbd_InRecChild[CML_BALSHRMTH_NF] 	= Ksz_Mois_bilan ;
		pbd_InRecChild[CML_BALSHRDAY_NF] 	= Ksz_Jour_bilan ;

		pbd_InRecChild[124] = 0;
		n_WriteCols(Kp_OutputBatch, pbd_InRecChild, '~', 0);
		
		/** ACQUISITION PAID CALCULATION */
		AcqExpPaid = atof(pbd_InRecChild[CML_ACMAMT_MC]) - atof(pbd_InRecChild[CML_TOTAUX_MC]);
		sprintf(TrnCod, "%s%c", "2143614", Norme);		
		n_EcrireGT ( pbd_InRecOwner, AcqExpPaid, TrnCod );
	}
	else
	{
		fprintf(Kp_OutputANO,
				"No CSM PATTERN Q found for CSUOE ( %s~%s~%s~%s~%s ) \n", 
				pbd_InRecChild[CML_CTR_NF],
				pbd_InRecChild[CML_END_NT], 
				pbd_InRecChild[CML_SEC_NF], 
				pbd_InRecChild[CML_UWY_NF], 
				pbd_InRecChild[CML_UW_NT] 
				);
	}
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction lance a chaque ligne synchro entre CSF et Peremiter file
retour 	:	0		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==============================================================================*/
int n_PereSansFils_Sync( char **pbd_InRecOwner )
{
	DEBUT_FCT("n_PereSansFils_Sync");

	fprintf(Kp_OutputANO,
			"IAE Initial not found for CSUOE ( %s~%s~%s~%s~%s ) \n", 
			pbd_InRecOwner[PER_CTR_NF],
			pbd_InRecOwner[PER_END_NT], 
			pbd_InRecOwner[PER_SEC_NF], 
			pbd_InRecOwner[PER_UWY_NF], 
			pbd_InRecOwner[PER_UW_NT] 
			);
	RETURN_VAL (0);
}

/**===============================================================================
objet 	: Fonction initialisation synchro entre CASHFLOW et PERIMETER
retour 	:	0	---> traitement correctement effectue
==================================================================================*/
int n_Init_CASHFLOW(T_RUPTURE_SYNC_VAR  *pbd_Sync)
{
	DEBUT_FCT("n_Init_CASHFLOW");
	
	memset( pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;
	n_OpenFileAppl ("ESFC3635_I3", "rt", &(pbd_Sync->pf_InputFil));
	
	pbd_Sync->ConditionEndSync  	= n_CondSync_CSF ;        
	pbd_Sync->n_ActionLigne     	= n_ActionLigne_CSF ;
	pbd_Sync->n_PereSansFils     	= n_PereSansFils_CSF;	
	pbd_Sync->c_Separ      			= '~' ;
	
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction de test de synchro entre CASHFLOW et PERIMETER
retour 	:	0  	---> synchro
			1  	---> non trouve
==============================================================================*/
int n_CondSync_CSF( char **pbd_InRecOwner , char **pbd_InRecChild )
{
	DEBUT_FCT("n_CondSync_CSF");
	int ret;
	
	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[CML_RETCTR_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[PER_END_NT] ) - atoi( pbd_InRecChild[CML_RETEND_NT] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( pbd_InRecOwner[PER_SEC_NF] ) - atoi( pbd_InRecChild[CML_RETSEC_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[CML_RTY_NF] ) ) != 0 ) 				return ret;
	if ( ( ret = atoi( pbd_InRecOwner[PER_UW_NT] ) - atoi( pbd_InRecChild[CML_RETUW_NT] ) ) != 0 ) 		return ret;
	if ( ( ret = atoi( pbd_InRecOwner[PER_PLC_NT]) - atoi( pbd_InRecChild[CML_PLC_NT] )) != 0 ) 		return ret;
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction de test de synchro entre CASHFLOW et PERIMETER
retour 	:	0  	---> synchro
			1  	---> non trouve
==============================================================================*/
int n_ActionLigne_CSF( char **pbd_InRecOwner , char **pbd_InRecChild )
{
	DEBUT_FCT("n_ActionLigne_CSF");
	
	int j;
	double AMT_ANk, AMT_TOTAL, CSM_RATIO, AcqExpPaid = 0.0;
	char amount[AMN_LEN], amount_ANk[65][AMN_LEN], amount_Total[AMN_LEN];
	
	AMT_TOTAL 	= atof(pbd_InRecChild[CML_TOTAUX_MC]);
	memset(amount,0, sizeof(amount));
	memset(amount_Total,0, sizeof(amount_Total));

	/** CHECK IF THE COLUMN EXIST */
	if( strcmp(pbd_InRecChild[CSM_PREVQ], "") != 0 )
	{
		CSM_RATIO = 1 - ((1 - atof(pbd_InRecChild[CSM_Q]))/(1 - atof(pbd_InRecChild[CSM_PREVQ])));
		if( strcmp(pbd_InRecChild[CSM_PREVQ], "1") == 0 )
		{
			pbd_InRecChild[CML_COMMENT] = "Division by 0, ratio forced to 1";
			CSM_RATIO = 1;
		}
		/** CALCULATION OF THE CASHFLOW FOR ACMAMT_M */
		pbd_InRecChild[CML_ACMAMT_MC] = pbd_InRecChild[CML_TOTAUX_MC];
			
		/** CALCULATION OF THE CASHFLOW FOR TOTAL AMOUNTS */
		sprintf(amount_Total , "%.3f" , AMT_TOTAL * CSM_RATIO);
		pbd_InRecChild[CML_TOTAUX_MC] = amount_Total; 
	
		/** CALCULATION OF THE CASHFLOW FOR ANK YEAR */
		for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
		{
			AMT_ANk = atof(pbd_InRecChild[j]);
			sprintf( amount_ANk [j-CML_AN1], "%.3f" , AMT_ANk * CSM_RATIO);
			pbd_InRecChild[j] = amount_ANk [j-CML_AN1];
		}
		pbd_InRecChild[CML_BALSHEY_NF] 		= Ksz_Annee_bilan ;
		pbd_InRecChild[CML_BALSHRMTH_NF] 	= Ksz_Mois_bilan ;
		pbd_InRecChild[CML_BALSHRDAY_NF] 	= Ksz_Jour_bilan ;

		pbd_InRecChild[124] = 0;
		n_WriteCols(Kp_OutputBatch, pbd_InRecChild, '~', 0);
		
		/** ACQUISITION PAID CALCULATION */
		AcqExpPaid = atof(pbd_InRecChild[CML_ACMAMT_MC]) - atof(pbd_InRecChild[CML_TOTAUX_MC]);
		sprintf(TrnCod, "%s%c", "2143614", Norme);		
		n_EcrireGT ( pbd_InRecOwner, AcqExpPaid, TrnCod );
	}
	else
	{
		fprintf(Kp_OutputANO,
				"CSM PATTERN Q-1 not found for CSUOE ( %s~%s~%s~%s~%s ) \n", 
				pbd_InRecChild[CML_CTR_NF],
				pbd_InRecChild[CML_END_NT], 
				pbd_InRecChild[CML_SEC_NF], 
				pbd_InRecChild[CML_UWY_NF], 
				pbd_InRecChild[CML_UW_NT] 
				);
	}
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction lance a chaque ligne synchro entre CSF et Peremiter file
retour 	:	0		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==============================================================================*/
int n_PereSansFils_CSF( char **pbd_InRecOwner )
{
	DEBUT_FCT("n_PereSansFils_CSF");
	
	fprintf(Kp_OutputANO,
			"IAE Previous not found for CSUOE ( %s~%s~%s~%s~%s ) \n", 
			pbd_InRecOwner[PER_CTR_NF],
			pbd_InRecOwner[PER_END_NT], 
			pbd_InRecOwner[PER_SEC_NF], 
			pbd_InRecOwner[PER_UWY_NF], 
			pbd_InRecOwner[PER_UW_NT] 
			);
	RETURN_VAL (0);
}

/**===============================================================================
OBJET:	Cette fonction permet d ecrire des resultas dans le Fichier : EST_EXPENSES 
==================================================================================*/
int n_EcrireGT( char **pbd_InRec_Cur, double d_Montant, char *trn_Code )
{
	char  sz_Acy[5] ;
	char  sz_Amt[22] ; 
	char  *Gt[NB_COL_GTR] ; 	
	char  sz_ScoStrMth[3] ;   	
	char  sz_ScoEndMth[3] ;   	
	
	strcpy(sz_Acy, Ksz_Annee_bilan );
	strcpy(sz_ScoStrMth, Ksz_Mois_bilan );
	strcpy(sz_ScoEndMth, Ksz_Mois_bilan );

	sprintf( sz_Amt, "%-.3f", d_Montant ) ;
	
	Gt[GT_SSD_CF] 			= pbd_InRec_Cur[PER_SSD_CF] ; 
	Gt[GT_ESB_CF] 			= pbd_InRec_Cur[PER_ACCESB_CF] ;
	Gt[GT_BALSHEY_NF] 		= Ksz_Annee_bilan ;  			     
	Gt[GT_BALSHRMTH_NF] 	= Ksz_Mois_bilan ; 				
	Gt[GT_BALSHRDAY_NF] 	= Ksz_Jour_bilan ; 				
	Gt[GT_TRNCOD_CF] 		= trn_Code ; 					
	Gt[GT_DBLTRNCOD_CF] 	= "" ;
	Gt[GT_CTR_NF] 			= "" ;                      
	Gt[GT_END_NT] 			= "" ;   
	Gt[GT_SEC_NF] 			= "" ;     
	Gt[GT_UWY_NF] 			= "" ;    
	Gt[GT_UW_NT] 			= "" ;    	
	Gt[GT_OCCYEA_NF] 		= "" ; 				
	Gt[GT_ACY_NF] 			= "" ;          			
	Gt[GT_SCOSTRMTH_NF] 	= "" ; 				
	Gt[GT_SCOENDMTH_NF] 	= "" ; 				
	Gt[GT_CLM_NF] 			= "" ;
	Gt[GT_CUR_CF] 			= pbd_InRec_Cur[PER_PCPCUR_CF] ;
	Gt[GT_AMT_M] 			= sz_Amt; ; 				
	Gt[GT_CED_NF] 			= "" ; 
	Gt[GT_BRK_NF] 			= "" ; 					
	Gt[GT_PAY_NF] 			= "" ; 					
	Gt[GT_KEY_NF] 			= "" ; 					
	Gt[GT_RETCTR_NF] 		= pbd_InRec_Cur[PER_CTR_NF] ;  			
	Gt[GT_RETEND_NT] 		= pbd_InRec_Cur[PER_END_NT] ; 			
	Gt[GT_RETSEC_NF] 		= pbd_InRec_Cur[PER_SEC_NF] ;   			
	Gt[GT_RTY_NF] 			= pbd_InRec_Cur[PER_UWY_NF] ;    
	Gt[GT_RETUW_NT] 		= pbd_InRec_Cur[PER_UW_NT] ;  
	Gt[GT_RETOCCYEA_NF] 	= sz_Acy ;
	Gt[GT_RETACY_NF] 		= sz_Acy ;
	Gt[GT_RETSCOSTRMTH_NF] 	= sz_ScoStrMth ;
	Gt[GT_RETSCOENDMTH_NF] 	= sz_ScoEndMth ;
	Gt[GT_RCL_NF] 			= "" ;
	Gt[GT_RETCUR_CF] 		= pbd_InRec_Cur[PER_PCPCUR_CF] ; 
	Gt[GT_RETAMT_M] 		= sz_Amt ;
	Gt[GT_PLC_NT] 			= pbd_InRec_Cur[PER_PLC_NT] ;
	Gt[GT_RTO_NF] 			= pbd_InRec_Cur[PER_RTO] ;
	Gt[GT_INT_NF] 			= pbd_InRec_Cur[PER_INT] ;
	Gt[GT_RETPAY_NF] 		= pbd_InRec_Cur[PER_PAY] ;
	Gt[GT_RETKEY_CF] 		= pbd_InRec_Cur[PER_KEY] ;
	Gt[GT_RETINTAMT_M] 		= sz_Amt;
	Gt[GT_ESTCUR_CF] 		= pbd_InRec_Cur[PER_PCPCUR_CF] ;
	Gt[GT_ESTAMT_M] 		= "" ;
	Gt[GT_NAT_CF] 			= "" ;  				
	Gt[GT_ACMTRS_NT] 		= "" ; 
	Gt[GT_ESTCTR_NF] 		= "" ; 
	Gt[GT_ESTSEC_NF] 		= "" ;
	Gt[GT_LOB_CF] 			= pbd_InRec_Cur[PER_LOB_CF] ; 
	Gt[GT_SCOEGP_M] 		= "" ; 				
	Gt[GT_ESTCRB_CT] 		= "" ;
	Gt[GT_LIFTRTTYP_CF] 	= "" ;	
	Gt[GT_ACCADMTYP_CT] 	= "" ; 
	Gt[GT_SECSTS_CT] 		= "" ; 				
	Gt[GT_PRD_NF] 			= "" ; 
	Gt[GT_SEG_NF] 			= "" ; 	
	Gt[GT_COMACC_B] 		= "" ; 
	Gt[GT_ADJCOD_CT] 		= "" ;
	Gt[GT_ORICOD_CF] 		= "" ;	
	Gt[GT_DETTRS_CF] 		= "" ; 				
	Gt[GT_ACCRET_B] 		= "" ; 
	Gt[GT_ESTUWY_NF] 		= "" ; 					
	Gt[GT_LSTENDMTH_NF] 	= "" ; 	
	Gt[GT_PROPER_N] 		= "" ; 
	Gt[GT_RTOCTY_CF] 		= "" ;
	Gt[GT_SPIMOD_CT] 		= "" ;
	Gt[GT_GAAP_NF] 			= "" ;
	Gt[GT_BRKSCOEGP_M] 		= NULL ;
			
	n_WriteCols( Kp_OutputFil_EXPENSES , Gt, SEPARATEUR, 0 ) ;
	
	RETURN_VAL(0);
}

/**===========================================================================
objet	:	Fonction pour retourner symbole norme a rensigner dans TRNCOD 
retour 	:   Caractere a renseigner dans TRNCOD	
=============================================================================*/
char n_GetNorme( const char *Norme_CF )
{
	if( strcmp(Norme_CF, "I17G") == 0 )		return 'I';
	else if ( strcmp(Norme_CF, "I17P") == 0 )	return 'K';
	else if ( strcmp(Norme_CF, "I17L") == 0 )	return 'M'; 
	else return 'R';
}