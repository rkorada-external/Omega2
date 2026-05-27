/**====================================================================================================
NOM DE L'APPLICATION          : AQUISITION EXPENSES CALCULATIONS
NOM DU SOURCE                 : ESFC3670.c
REVISION                      : V1
DATE DE CREATION              : 12/2018
AUTEUR                        : L.ELFAHIM
SQUELETTE DE BASE             : BATCH
REFERENCES DES SPECIFICATIONS : 
-------------------------------------------------------------------------------------------------------
DESCRIPTION :
	Ce programme manipule plusieurs fichiers en entree pour gerer le calcul des Acquisitions Expenses
	  
	 /  \   * POUR LA MAINTENABILITE DE CE PROGRAMME MERCI DE SIGNER  *
	/  ! \  * TOUTE MODIFICATION APPORTEE SUIVANT LE MODELE DESSOUS   *
	/______\ **********************************************************
-------------------------------------------------------------------------------------------------------
HISTORIQUE DES MODIFICATIONS :
<jj/mm/aaaa>   	<AUTEUR>    <SPIRA>		<DESCRIPTION DE LA MODIFICATION>
01/08/2019		LEL     	75803		ADAPTATION APRES MERGE REQ11.1 et REQ11.2
25/09/2019		LEL     	77591		GESTION DES ANOMALIES
06/11/2019		LEL     	81645		CHANGE REQUEST ( Change in FD )
14/11/2019		LEL     	82609		CHANGE REQUEST ( Change in FD )
08/01/2020		LEL     	82884		CHANGE INPUT FILE IN ORDER TO RETRIEVE UPR ENDING
24/03/2020		LEL     	79102		DO NOT TAKE INTO ACCOUNT TRNCODE AT INCEPTION
06/01/2021		LEL     	92596		INTEGRATE FUTURE AE IN EXPENSE CALCULATION
05/07/2022		JBD		    104778		Build new closing for I17S norm
======================================================================================================*/


/**----------------------------------------------------
	INCLUSION DES INTERFACES DES COMPOSANTS IMPORTES 
-------------------------------------------------------*/
#include <utctlib.h>
#include <estserv.h>
#include <stdarg.h>
#include <util.h>
#include <string.h>
#include "struct.h"
#include "estserv.h"
#include "ESFC3670.h"  
#include <time.h>

/**-------------------------------------------------
	TRAITEMANT PRINCIPAL DU PROGRAMME                      
----------------------------------------------------*/
int main( int argc,  char *argv[] )
{
	InitSig ();

	if (n_BeginPgm (argc, argv) == ERR)
		ExitPgm (ERR_XX, "");
	
	strcpy( Norme_CF, psz_GetCharArgv(1) ) ;
	strcpy( Ksz_CloDat, psz_GetCharArgv(2) ) ;

	/** Retrieve norme */
	Norme = n_GetNorme( Norme_CF );
	if( Norme == 'R' )
	{
		n_WriteAno( "ERROR : Norme Incorrecte \n" );
		exit(1);
	}
	/** Eclatement de la date AAAAMMJJ en 3 chaines de caractere */
	sscanf( Ksz_CloDat, "%4s%2s%2s", Ksz_Annee_bilan, Ksz_Mois_bilan, Ksz_Jour_bilan ) ;
	
	/***************************************************************************/
	/**  OUVERTURE DES FICHIERS EN ENTREE ET INITIALISATION DES STRUCTURES     */
	/***************************************************************************/
	if ( n_OpenFileAppl ( "ESFC3670_O1","wt",&Kp_OutputFil_EXPENSES ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_OpenFileAppl ( "ESFC3670_O2","wt",&Kp_OutputANO ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	/** Initialisation de la variable Kbd_RuptPER */
	if ( n_InitPER(&Kbd_RuptPER) ) 
		ExitPgm ( ERR_XX , "" );
	
	/** Initialisation de la variable Kbd_RuptDLDGTAASIISO */
	if ( n_InitDLDGTAASIISO(&Kbd_RuptDLDGTAASIISO) ) 
		ExitPgm ( ERR_XX , "" );
	
	/** Lancement du traitement du fichier IADPERICASE */
	if ( n_ProcessingRuptureVar( &Kbd_RuptPER ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	/***************************************************************************/
	/**   FERMETURE DES FICHIERS OUVERTS                                       */
	/***************************************************************************/
	if ( n_CloseFileAppl( "ESFC3670_I1", &( Kbd_RuptPER.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3670_I2", &( Kbd_RuptDLDGTAASIISO.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3670_O1", &Kp_OutputFil_EXPENSES ) == ERR ) 
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3670_O1", &Kp_OutputANO ) == ERR ) 
		ExitPgm( ERR_XX , "" );

	if ( n_EndPgm () == ERR )
		ExitPgm (ERR_XX, "");
	
	exit(0);
}


/**============================================================================
OBJET : Fonction d'initialisation de la variable de rupture du fichier maitre.
RETOUR 	:	0  		---> traitement correctement effectue
			ERR 	---> probleme rencontre
===============================================================================*/
int n_InitPER(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_InitPER");
	
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

	if ( n_OpenFileAppl ("ESFC3670_I1", "rt", &(pbd_Rupt->pf_InputFil)))
		RETURN_VAL (ERR);

	pbd_Rupt->n_ActionLigne 		= n_ActionLignePER ;
	pbd_Rupt->c_Separ 				= '~' ;

	RETURN_VAL (0);
}

/**===========================================================================
OBJET 	: Fonction lancee a chaque ligne de repture
RETOUR 	:	0  		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==============================================================================*/
int n_ActionLignePER( char **pbd_InRec_Cur )
{
	DEBUT_FCT( "n_ActionLignePER" ) ;
	
	flag_Future 	= 0;
	AcqExpenses 	= 0.0;
	d_FUTURE_PREM 	= 0.0;			
	
	/** Lancement synchronisation avec le fils DLDGTAA_1051 Enrichit */
	n_ProcessingRuptureSyncVar( &Kbd_RuptDLDGTAASIISO, pbd_InRec_Cur ); 
	
	/** Check internal client */
	if( pbd_InRec_Cur[CLISSD][0] == 0 ) 
	{	
		if( pbd_InRec_Cur[ACQ_RAT_Q] != NULL && *pbd_InRec_Cur[ACQ_RAT_Q] != 0 )
		{	
			/** Contracts having Future alreary estimated */
			if ( flag_Future == 1 ) 
			{
				AcqExpenses = - atof(pbd_InRec_Cur[ACQ_RAT_Q]) * d_FUTURE_PREM;
				sprintf(TrnCod, "%s%c", "1143610", Norme); 	// 43611 : Refer to spec
				n_EcrireGT ( pbd_InRec_Cur, AcqExpenses, TrnCod );
			}
			else
			{
				fprintf(Kp_OutputANO,
					"No FUTURE PREMIUM FOUND for CSUOE %s~%s~%s~%s~%s )\n", 
					pbd_InRec_Cur[PER_CTR_NF],
					pbd_InRec_Cur[PER_END_NT], 
					pbd_InRec_Cur[PER_SEC_NF], 
					pbd_InRec_Cur[PER_UWY_NF], 
					pbd_InRec_Cur[PER_UW_NT]		
				);
			}
		}
		else
		{
			fprintf(Kp_OutputANO,
				"No Acquisition Ratio Q found for CSUOE ( %s~%s~%s~%s~%s )\n", 
				pbd_InRec_Cur[PER_CTR_NF],
				pbd_InRec_Cur[PER_END_NT], 
				pbd_InRec_Cur[PER_SEC_NF], 
				pbd_InRec_Cur[PER_UWY_NF], 
				pbd_InRec_Cur[PER_UW_NT] 
				);
		}			
	}
	else
	{
		fprintf(Kp_OutputANO,
			"CSUOE Internal contract ( %s~%s~%s~%s~%s )\n", 
			pbd_InRec_Cur[PER_CTR_NF],
			pbd_InRec_Cur[PER_END_NT], 
			pbd_InRec_Cur[PER_SEC_NF], 
			pbd_InRec_Cur[PER_UWY_NF], 
			pbd_InRec_Cur[PER_UW_NT] 
			);
	}			
	
	RETURN_VAL(0) ;
}

/**===============================================================================
OBJET 	: Fonction initialisation synchro entre DLDGTAASIISO et IADPERICASE
RETOUR 	: 0	---> traitement correctement effectue
==================================================================================*/
int n_InitDLDGTAASIISO(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_InitDLDGTAASIISO");

	memset( pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;
	
	n_OpenFileAppl ("ESFC3670_I2", "rt", &(pbd_Rupt->pf_InputFil));

	pbd_Rupt->n_NbRupture 		= 0;
	pbd_Rupt->ConditionEndSync  = n_ConditionSyncDLDGTAASIISO ;        
	pbd_Rupt->n_ActionLigne     = n_ActionLigneDLDGTAASIISO ;           
	pbd_Rupt->c_Separ      		= '~' ;
	
	RETURN_VAL (0);
}

/**===========================================================================
OBJET 	: Fonction de test conditions synchro entre DLDGTAASIISO et IADPERICASE
RETOUR 	:	0		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==============================================================================*/
int n_ConditionSyncDLDGTAASIISO( char **pbd_InRecOwner , char **pbd_InRecChild )
{
	DEBUT_FCT("n_ConditionSyncDLDGTAASIISO");
	int ret;
	
	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[PER_END_NT] ) - atoi( pbd_InRecChild[GT_END_NT] ) ) != 0 ) 	return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_SEC_NF] ) - atoi( pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) 	return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[PER_UW_NT] ) - atoi( pbd_InRecChild[GT_UW_NT] ) ) != 0 ) 		return ret ;
	
	RETURN_VAL (0);
}

/**==============================================================================
OBJET 	: Fonction lance a chaque ligne synchro entre DLDGTAASIISO et IADPERICASE
RETOUR 	: 0	---> traitement correctement effectue
=================================================================================*/
int n_ActionLigneDLDGTAASIISO( char **pbd_InRecOwner ,char **pbd_InRecChild )
{
	DEBUT_FCT("n_ActionLigneDLDGTAASIISO");
	flag_Future = 1;
	
	d_FUTURE_PREM += atof(pbd_InRecChild[ACMAMT_MC]);

	RETURN_VAL (0);
}

/**===============================================================================
OBJET:	Cette fonction permet d ecrire des resultas dans le Fichier : EST_EXPENSES 
==================================================================================*/
int n_EcrireGT( char **pbd_InRec_Cur, double d_Montant, char *trn_Code )
{
	char  sz_Acy[5] ; 
	char  sz_Amt[22]; 
	char  *Gt[NB_COL_GT]; 		  		
	char  sz_ScoStrMth[3];   	
	char  sz_ScoEndMth[3];   	
	
	strcpy(sz_Acy, Ksz_Annee_bilan );
	strcpy(sz_ScoStrMth, Ksz_Mois_bilan );
	strcpy(sz_ScoEndMth, Ksz_Mois_bilan );

	sprintf( sz_Amt, "%-.3f", d_Montant );

	Gt[GT_SSD_CF] 			= pbd_InRec_Cur[PER_SSD_CF]; 
	Gt[GT_ESB_CF] 			= pbd_InRec_Cur[PER_ACCESB_CF];
	Gt[GT_BALSHEY_NF] 		= Ksz_Annee_bilan;  			     
	Gt[GT_BALSHRMTH_NF] 	= Ksz_Mois_bilan; 				
	Gt[GT_BALSHRDAY_NF] 	= Ksz_Jour_bilan; 				
	Gt[GT_TRNCOD_CF] 		= trn_Code; 					
	Gt[GT_DBLTRNCOD_CF] 	= "" ; 				
	Gt[GT_CTR_NF] 			= pbd_InRec_Cur[PER_CTR_NF];                      
	Gt[GT_END_NT] 			= pbd_InRec_Cur[PER_END_NT];   
	Gt[GT_SEC_NF] 			= pbd_InRec_Cur[PER_SEC_NF];     
	Gt[GT_UWY_NF] 			= pbd_InRec_Cur[PER_UWY_NF];    
	Gt[GT_UW_NT] 			= pbd_InRec_Cur[PER_UW_NT];      
	Gt[GT_OCCYEA_NF] 		= sz_Acy; 				
	Gt[GT_ACY_NF] 			= sz_Acy;          			
	Gt[GT_SCOSTRMTH_NF] 	= sz_ScoStrMth; 				
	Gt[GT_SCOENDMTH_NF] 	= sz_ScoEndMth; 				
	Gt[GT_CLM_NF] 			= "" ;
	Gt[GT_CUR_CF] 			= pbd_InRec_Cur[PER_EGPCUR_CF];	
	Gt[GT_AMT_M] 			= sz_Amt ; 					
	Gt[GT_CED_NF] 			= pbd_InRec_Cur[PER_CED_NF]; 
	Gt[GT_BRK_NF] 			= pbd_InRec_Cur[PER_PRD_NF]; 					
	Gt[GT_PAY_NF] 			= pbd_InRec_Cur[PER_GENPRMPAY_NF]; 					
	Gt[GT_KEY_NF] 			= pbd_InRec_Cur[PER_GANPAYORD_NT]; 					
	Gt[GT_RETCTR_NF] 		= "" ;				 
	Gt[GT_RETEND_NT] 		= "" ;				
	Gt[GT_RETSEC_NF] 		= "" ;				 
	Gt[GT_RTY_NF] 			= "" ;
	Gt[GT_RETUW_NT] 		= "" ;
	Gt[GT_RETOCCYEA_NF] 	= "" ;
	Gt[GT_RETACY_NF] 		= "" ;
	Gt[GT_RETSCOSTRMTH_NF] 	= "" ;
	Gt[GT_RETSCOENDMTH_NF] 	= "" ;
	Gt[GT_RCL_NF] 			= "" ;
	Gt[GT_RETCUR_CF] 		= "" ;
	Gt[GT_RETAMT_M] 		= "" ;
	Gt[GT_PLC_NT] 			= "" ;
	Gt[GT_RTO_NF] 			= "" ;
	Gt[GT_INT_NF] 			= "" ;
	Gt[GT_RETPAY_NF] 		= "" ;
	Gt[GT_RETKEY_CF] 		= "" ;
	Gt[GT_RETINTAMT_M] 		= "" ;
	Gt[GT_RETINTAMT_M + 1] 	= NULL ;
			
	n_WriteCols( Kp_OutputFil_EXPENSES , Gt, SEPARATEUR, 0 ) ;

	RETURN_VAL(0);
}

/**===========================================================================
objet	:	Fonction pour retourner symbole norme a rensigner dans TRNCOD 
retour 	:   Caractere a renseigner dans TRNCOD	
=============================================================================*/
char n_GetNorme( const char *Norme_CF )
{
  if (strcmp(Norme_CF, "I17G") == 0 || strcmp(Norme_CF, "I17S") == 0)		return 'I';
  else if ( strcmp(Norme_CF, "I17P") == 0 )	return 'K';
  else if ( strcmp(Norme_CF, "I17L") == 0 )	return 'M'; 
  else return 'R';
}