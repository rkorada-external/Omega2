/**===========================================================================================================
NOM DE L'APPLICATION          : ACF/PCA: IMPACT REVENUE CALCULATION
NOM DU SOURCE                 : ESFC3640.c
REVISION                      : V1
DATE DE CREATION              : 08/2021
AUTEUR                        : L.ELFAHIM
SQUELETTE DE BASE             : Batch
REFERENCES DES SPECIFICATIONS : 
--------------------------------------------------------------------------------------------------------------
DESCRIPTION :
	CE PROGRAMME EST DESTINE AU CALCUL DE ACF/PCA RATIO
	for ASSUMED
--------------------------------------------------------------------------------------------------------------
	 /  \   * POUR LA MAINTENABILITE DE CE PROGRAMME MERCI DE SIGNER  *
	/  ! \  * TOUTE MODIFICATION APPORTEE SUIVANT LE MODELE DESSOUS   *
	/______\ **********************************************************

HISTORIQUE DES MODIFICATIONS :
	<JJ/MM/AAAA>   	<AUTEUR>  	<SPIRA>		<DESCRIPTION DE LA MODIFICATION>
	12/08/2021    	LEL    		97373    	DEVELOPPEMENT DE LA VERSION INITIALE
	11/10/2021    	LEL    		99008     	I17 - RATIOS ROUNDING
	02/06/2022    	HR    		102733          REQ 11.02 - IFRS17 - No future maintenance expenses calculated at subsequent measurement
===========================================================================================================*/

/**----------------------------------------------------
	Inclusion des fichiers entete 
-------------------------------------------------------*/
#include <utctlib.h>
#include <estserv.h>
#include <stdarg.h>
#include <util.h>
#include "struct.h"
#include "estutil.c"
#include "ESFC3640.h"  

/**-------------------------------------------------
	Traitemant principale du programme                      
----------------------------------------------------*/
int main( int argc,  char *argv[] )
{
	InitSig ();

	if (n_BeginPgm (argc, argv) == ERR)
		ExitPgm (ERR_XX, "");
	
	strcpy(Ksz_CloDat, psz_GetCharArgv(1));
	strcpy(Blcshyear, psz_GetCharArgv(2));
	
	/***************************************************************************/
	/**  Ouverture Des fichiers en entree et Initialisation des structures     */
	/***************************************************************************/
	
	if ( n_OpenFileAppl ( "ESFC3640_O1","wt",&Kp_OutputFilRatio ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	/** Ouverture du fichier en entree des cours de change FCURQUOT */
	if ( n_OpenFileAppl ( "ESFC3640_I7","rb",&Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	/** Initialisation de la variable Kbd_Rup_TRERETFACCTR */
	if ( n_Init_TRERETFACCTR(&Kbd_Rup_TRERETFACCTR) ) 
		ExitPgm ( ERR_XX , "" );

	/** Initialisation de la variable Kbd_Rupt_CASHFLOW_Q */
	if ( n_Init_CASHFLOW_Q(&Kbd_Rupt_CASHFLOW_Q) ) 
		ExitPgm ( ERR_XX , "" );
	
	/** Initialisation de la variable Kbd_Rupt_CASHFLOW_PREVQ */
	if ( n_Init_CASHFLOW_PREVQ(&Kbd_Rupt_CASHFLOW_PREVQ) ) 
		ExitPgm ( ERR_XX , "" );

	/** Initialisation de la variable Kbd_Rupt_ITD_PREM */
	if ( n_Init_ITD_PREM(&Kbd_Rupt_ITD_PREM) ) 
		ExitPgm ( ERR_XX , "" );
	
	/** Initialisation de la variable Kbd_Rupt_UPR_Q */
	if ( n_Init_UPR_Q(&Kbd_Rupt_UPR_Q) ) 
		ExitPgm ( ERR_XX , "" );
	
	/** Initialisation de la variable Kbd_Rupt_UPR_PREVQ */
	if ( n_Init_UPR_PREVQ(&Kbd_Rupt_UPR_PREVQ) ) 
		ExitPgm ( ERR_XX , "" );
	
	/** Initialisation de la variable Kbd_Rupt_CASHFLOW_INI */
	if ( n_Init_CASHFLOW_INI(&Kbd_Rupt_CASHFLOW_INI) ) 
		ExitPgm ( ERR_XX , "" );

	/** Lancement du traitement du fichier maitre */
	if (n_ProcessingRuptureVar(&Kbd_Rup_TRERETFACCTR) == ERR) 
		ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
	
	/***************************************************************************/
	/**   Fermeture Des fichiers ouverts                                       */
	/***************************************************************************/
	if ( n_CloseFileAppl( "ESFC3640_I1", &( Kbd_Rup_TRERETFACCTR.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3640_I2", &( Kbd_Rupt_CASHFLOW_Q.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3640_I3", &( Kbd_Rupt_CASHFLOW_PREVQ.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3640_I4", &( Kbd_Rupt_ITD_PREM.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESFC3640_I5", &( Kbd_Rupt_UPR_Q.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3640_I6", &( Kbd_Rupt_UPR_PREVQ.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3640_I7", &Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3640_I8", &( Kbd_Rupt_CASHFLOW_INI.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3640_O1", &Kp_OutputFilRatio ) == ERR ) 
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
int n_Init_TRERETFACCTR(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_Init_TRERETFACCTR");
	
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

	if ( n_OpenFileAppl ("ESFC3640_I1", "rt", &(pbd_Rupt->pf_InputFil)))
		RETURN_VAL (ERR);

	pbd_Rupt->n_NbRupture 			= 1 ;
	pbd_Rupt->n_ConditionRupture[0] = n_IsRupt_TRERETFACCTR;
	pbd_Rupt->n_ActionFirst[0] 		= n_ActionFirstRuptPER;
	pbd_Rupt->n_ActionLigne 		= n_ActionLigne_TRERETFACCTR ;
	pbd_Rupt->c_Separ 				= '~' ;
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction de test de rupture du niveau 1
retour	: 	0   ---> Rupture
			1   ---> Pas de rupture
==============================================================================*/
int n_IsRupt_TRERETFACCTR(char **ptb_InRec, char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_IsRupt_TRERETFACCTR");
	int ret;
	
	if ( ( ret = strcmp( ptb_InRec[CTR_NF], ptb_InRec_Cur[CTR_NF] ) ) != 0 ) 		return ret;
	if ( ( ret = atoi( ptb_InRec[END_NT] ) - atoi( ptb_InRec_Cur[END_NT] ) ) != 0 ) return ret;
	if ( ( ret = atoi( ptb_InRec[SEC_NF] ) - atoi( ptb_InRec_Cur[SEC_NF] ) ) != 0 ) return ret;
	if ( ( ret = strcmp( ptb_InRec[UWY_NF], ptb_InRec_Cur[UWY_NF] ) ) != 0 ) 		return ret;
	if ( ( ret = atoi( ptb_InRec[UW_NT] ) - atoi( ptb_InRec_Cur[UW_NT] ) ) != 0 ) 	return ret;
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction de rupture du niveau 1
==============================================================================*/
int n_ActionFirstRuptPER( char **ptb_InRec_Cur )
{
	DEBUT_FCT("n_ActionFirstRuptPER");
	
	/* ASSUMED GLOBAL VARIABLES */
	d_UPR_Q 				= 0.0;
	d_ITD_PREM 				= 0.0;
	d_PREM_ESTM				= 0.0;
	d_UPR_PREVQ 			= 0.0;
	d_REMAIN_ESTM			= 0.0;
	d_ITD_PREM_ACT 			= 0.0;
	d_FUTURE_PREM_Q 		= 0.0;
	d_FUTURE_PREM_INI		= 0.0;
	d_PREM_ESTM_PREVQ  		= 0.0;
	d_FUT_FIXED_CHARGE		= 0.0;
	d_FIXED_CHARGE_ACT		= 0.0;
	d_FUTURE_PREM_PREVQ 	= 0.0;
	d_REMAIN_ESTM_PREVQ 	= 0.0; 
	
	// LANCEMENT SYNCHRONISATION AVEC LE FICHIER ITD_PREM  
	n_ProcessingRuptureSyncVar( &Kbd_Rupt_ITD_PREM, ptb_InRec_Cur );

	// LANCEMENT SYNCHRONISATION AVEC LE FICHIER CASHFLOW_Q 
	n_ProcessingRuptureSyncVar( &Kbd_Rupt_CASHFLOW_Q, ptb_InRec_Cur );
	
	// LANCEMENT SYNCHRONISATION AVEC LE FICHIER CASHFLOW_PREVQ  
	n_ProcessingRuptureSyncVar( &Kbd_Rupt_CASHFLOW_PREVQ, ptb_InRec_Cur );
	
	// LANCEMENT SYNCHRONISATION AVEC LE FICHIER CASHFLOW_INI  
	n_ProcessingRuptureSyncVar( &Kbd_Rupt_CASHFLOW_INI, ptb_InRec_Cur );
	
	// LANCEMENT SYNCHRONISATION AVEC LE FICHIER UPR_Q  
	n_ProcessingRuptureSyncVar( &Kbd_Rupt_UPR_Q, ptb_InRec_Cur );
	
	// LANCEMENT SYNCHRONISATION AVEC LE FICHIER UPR_PREVQ  
	n_ProcessingRuptureSyncVar( &Kbd_Rupt_UPR_PREVQ, ptb_InRec_Cur );
  
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction lance a chaque ligne synchro entre CASHFLOW et DSC_RAD_LKI
retour 	:	0		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==============================================================================*/
int n_ActionLigne_TRERETFACCTR( char **pbd_InRecOwner )
{
	DEBUT_FCT("n_ActionLigne_TRERETFACCTR");
	
	/** VARIABLE DECLARATION & INITIALISATION */
	double	EGPI_R1, 
			EGPI_R2, 
			EARP_R1;
			
	sprintf(COMMENT1_CF , "%s" , "");
	sprintf(COMMENT2_CF , "%s" , "");
	sprintf(COMMENT3_CF , "%s" , "");
	
	/** CHECK INITIALISATION CONDITIONS of CONTRACTS */	
	if (( *pbd_InRecOwner[GRPINISTS_CT] == '2' && atoi(pbd_InRecOwner[GRPFIRCLO_D]) == atoi(Ksz_CloDat)) 
		|| *pbd_InRecOwner[GRPINISTS_CT] == '1' )
	{
		d_FUTURE_PREM_PREVQ = d_FUTURE_PREM_INI;
		d_UPR_PREVQ = d_REMAIN_ESTM_PREVQ = d_PREM_ESTM_PREVQ = 0;
	}
	
	/** RATIO'S CALCULATION */	
	if( fabs( d_FUTURE_PREM_PREVQ + d_PREM_ESTM_PREVQ + d_REMAIN_ESTM_PREVQ ) < 1 )
	{
		EGPI_R1 = 1;
		sprintf(COMMENT1_CF , "%s" , "EGPI_R1 forced to 1");
	}
	else
	{
		EGPI_R1 = ( d_FUTURE_PREM_Q + d_PREM_ESTM + d_REMAIN_ESTM + d_ITD_PREM_ACT )/( d_FUTURE_PREM_PREVQ + d_PREM_ESTM_PREVQ + d_REMAIN_ESTM_PREVQ );	
		if( fabs(EGPI_R1) > 10 )
		{
			EGPI_R1 = (10 * EGPI_R1/fabs(EGPI_R1));
			sprintf(COMMENT1_CF , "%s" , "abs EGPI_R1 > 10");
		}
	}
	
	if( fabs(d_FUTURE_PREM_PREVQ - d_UPR_PREVQ) < 1 )
	{
		EGPI_R2 = EARP_R1 = 1;
		sprintf(COMMENT2_CF , "%s" , "EGPI_R2 forced to 1");
		sprintf(COMMENT3_CF , "%s" , "EARP_R1 forced to 1");
	}
	else
	{
		EGPI_R2 = ( d_FUTURE_PREM_Q + d_ITD_PREM - d_UPR_PREVQ )/( d_FUTURE_PREM_PREVQ - d_UPR_PREVQ );
		if( fabs(EGPI_R2) > 10 )
		{
			EGPI_R2 = (10 * EGPI_R2/fabs(EGPI_R2));
			sprintf(COMMENT2_CF , "%s" , "abs EGPI_R2 > 10");
		}
		EARP_R1 = ( d_FUTURE_PREM_Q - d_UPR_Q )/( d_FUTURE_PREM_PREVQ - d_UPR_PREVQ );
		if( fabs(EARP_R1) > 10 )
		{
			EARP_R1 = (10 * EARP_R1/fabs(EARP_R1));
			sprintf(COMMENT3_CF , "%s" , "abs EARP_R1 > 10");
		}
	}
	
	sprintf(COMMENT_CF, "%s | %s | %s", COMMENT1_CF, COMMENT2_CF, COMMENT3_CF);
	
	/** WRITE ASSUMED OUTPUT RATIO FILE */
	fprintf(Kp_OutputFilRatio,
			"%s~%s~%s~%s~%s~%.5f~%.5f~%.5f~%.3f~%.3f~%.3f~%.3f~%.3f~%.3f~%.3f~%.3f~%.3f~%.3f~%.3f~%s \n", 
			pbd_InRecOwner[CTR_NF],
			pbd_InRecOwner[END_NT], 
			pbd_InRecOwner[SEC_NF], 
			pbd_InRecOwner[UWY_NF], 
			pbd_InRecOwner[UW_NT],
			EGPI_R1,
			EGPI_R2,
			EARP_R1,
			d_FUTURE_PREM_PREVQ,
			d_FUTURE_PREM_Q,
			d_PREM_ESTM_PREVQ,
			d_PREM_ESTM,
			d_REMAIN_ESTM_PREVQ,  
			d_REMAIN_ESTM,
			d_FIXED_CHARGE_ACT,
			d_ITD_PREM_ACT,
			d_ITD_PREM,
			d_UPR_PREVQ,
			d_UPR_Q,
			COMMENT_CF
			);			
	
	RETURN_VAL (0);
}

/**===============================================================================
objet 	: Fonction initialisation synchro entre CASHFLOW et PERIMETER
retour 	:	0	---> traitement correctement effectue
==================================================================================*/
int n_Init_CASHFLOW_Q(T_RUPTURE_SYNC_VAR  *pbd_Sync)
{
	DEBUT_FCT("n_Init_CASHFLOW_Q");

	memset( pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;
	n_OpenFileAppl ("ESFC3640_I2", "rt", &(pbd_Sync->pf_InputFil));

	pbd_Sync->ConditionEndSync  	= n_CondSync_CASHFLOW_Q ;        
	pbd_Sync->n_ActionLigne     	= n_ActionLigne_CASHFLOW_Q ;           
	pbd_Sync->c_Separ      			= '~' ;
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction de test de synchro entre CASHFLOW et PERIMETER
retour 	:	0  	---> synchro
			1  	---> non trouve
==============================================================================*/
int n_CondSync_CASHFLOW_Q( char **pbd_InRecOwner , char **pbd_InRecChild )
{
	DEBUT_FCT("n_CondSync_CASHFLOW_Q");
	int ret;
	
	if ( ( ret = strcmp( pbd_InRecOwner[CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[END_NT] ) - atoi( pbd_InRecChild[GT_END_NT] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( pbd_InRecOwner[SEC_NF] ) - atoi( pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[UW_NT] ) - atoi( pbd_InRecChild[GT_UW_NT] ) ) != 0 ) 		return ret;
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction lance a chaque ligne synchro entre CASHFLOW et PERIMETER
retour 	:	0		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==============================================================================*/
int n_ActionLigne_CASHFLOW_Q( char **pbd_InRecOwner ,char **pbd_InRecChild )
{
	DEBUT_FCT("n_ActionLigne_CASHFLOW_Q");
	
	if( strcmp( pbd_InRecChild[CML_ACMTRS3_NT2], "1051" ) == 0 )
		d_FUTURE_PREM_Q += atof(pbd_InRecChild[CML_ACMAMT_MC]);
	else if( strcmp( pbd_InRecChild[CML_ACMTRS3_NT2], "2051" ) == 0 )
		d_FUT_FIXED_CHARGE += atof(pbd_InRecChild[CML_ACMAMT_MC]);
	else if( strcmp( pbd_InRecChild[CML_ACMTRS3_NT2], "1010" ) == 0 )
		d_PREM_ESTM += atof(pbd_InRecChild[CML_ACMAMT_MC]);
	else
		d_REMAIN_ESTM += atof(pbd_InRecChild[CML_ACMAMT_MC]);
	
	RETURN_VAL (0);
}

/**===============================================================================
objet 	: Fonction initialisation synchro entre CASHFLOW Q-1 et PERIMETER
retour 	:	0	---> traitement correctement effectue
==================================================================================*/
int n_Init_CASHFLOW_PREVQ(T_RUPTURE_SYNC_VAR  *pbd_Sync)
{
	DEBUT_FCT("n_Init_CASHFLOW_PREVQ");

	memset( pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;
	
	n_OpenFileAppl ("ESFC3640_I3", "rt", &(pbd_Sync->pf_InputFil));

	pbd_Sync->ConditionEndSync  	= n_CondSync_CASHFLOW_PREVQ ;        
	pbd_Sync->n_ActionLigne     	= n_ActionLigne_CASHFLOW_PREVQ ;           
	pbd_Sync->c_Separ      			= '~' ;
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction de test de synchro entre CASHFLOW Q-1 et PERIMETER
retour 	:	0  		---> synchro
			1  		---> non trouve
==============================================================================*/
int n_CondSync_CASHFLOW_PREVQ( char **pbd_InRecOwner , char **pbd_InRecChild )
{
	DEBUT_FCT("n_CondSync_CASHFLOW_PREVQ");
	int ret;
	
	if ( ( ret = strcmp( pbd_InRecOwner[CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[END_NT] ) - atoi( pbd_InRecChild[GT_END_NT] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( pbd_InRecOwner[SEC_NF] ) - atoi( pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[UW_NT] ) - atoi( pbd_InRecChild[GT_UW_NT] ) ) != 0 ) 		return ret;
	
	RETURN_VAL (0);
}

/**===============================================================================
objet 	: Fonction lance a chaque ligne synchro entre CASHFLOW Q-1 et PERIMETER
retour 	:	0		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==================================================================================*/
int n_ActionLigne_CASHFLOW_PREVQ( char **pbd_InRecOwner ,char **pbd_InRecChild )
{
	DEBUT_FCT("n_ActionLigne_CASHFLOW_PREVQ");
	
	if( strcmp( pbd_InRecChild[CML_ACMTRS3_NT2], "1051" ) == 0 )
		d_FUTURE_PREM_PREVQ += atof(pbd_InRecChild[CML_ACMAMT_MC]);
	else if( strcmp( pbd_InRecChild[CML_ACMTRS3_NT2], "1010" ) == 0 )
		d_PREM_ESTM_PREVQ += atof(pbd_InRecChild[CML_ACMAMT_MC]);
	else
		d_REMAIN_ESTM_PREVQ += atof(pbd_InRecChild[CML_ACMAMT_MC]);
	
	RETURN_VAL (0);
}

/**===============================================================================
objet 	: Fonction initialisation synchro entre CASHFLOW INI et PERIMETER file
retour 	:	0	---> traitement correctement effectue
==================================================================================*/
int n_Init_CASHFLOW_INI(T_RUPTURE_SYNC_VAR  *pbd_Sync)
{
	DEBUT_FCT("n_Init_CASHFLOW_INI");

	memset( pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;
	
	n_OpenFileAppl ("ESFC3640_I8", "rt", &(pbd_Sync->pf_InputFil));

	pbd_Sync->ConditionEndSync  	= n_CondSync_CASHFLOW_INI ;        
	pbd_Sync->n_ActionLigne     	= n_ActionLigne_CASHFLOW_INI ;           
	pbd_Sync->c_Separ      			= '~' ;
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction de test de synchro entre CASHFLOW INI et PERIMETER file
retour 	:	0  		---> synchro
			1  		---> non trouve
==============================================================================*/
int n_CondSync_CASHFLOW_INI( char **pbd_InRecOwner , char **pbd_InRecChild )
{
	DEBUT_FCT("n_CondSync_CASHFLOW_INI");
	int ret;
	
	if ( ( ret = strcmp( pbd_InRecOwner[CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[END_NT] ) - atoi( pbd_InRecChild[GT_END_NT] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( pbd_InRecOwner[SEC_NF] ) - atoi( pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[UW_NT] ) - atoi( pbd_InRecChild[GT_UW_NT] ) ) != 0 ) 		return ret;
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction lance a chaque ligne synchro entre CSF INI et PERIMETER 
retour 	:	0		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==============================================================================*/
int n_ActionLigne_CASHFLOW_INI( char **pbd_InRecOwner ,char **pbd_InRecChild )
{
	DEBUT_FCT("n_ActionLigne_CASHFLOW_INI");
			
	d_FUTURE_PREM_INI += atof(pbd_InRecChild[CML_ACMAMT_MC]);
	
	RETURN_VAL (0);
}

/**==============================================================================
objet 	: Fonction initialisation synchro entre Perimeter et ITD_PREM
retour 	:	0	---> traitement correctement effectue
=================================================================================*/
int n_Init_ITD_PREM(T_RUPTURE_SYNC_VAR  *pbd_Sync)
{
	DEBUT_FCT("n_Init_ITD_PREM");
	
	memset( pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;
	n_OpenFileAppl ("ESFC3640_I4", "rt", &(pbd_Sync->pf_InputFil));

	pbd_Sync->ConditionEndSync  	= n_CondSync_ITD_PREM ;        
	pbd_Sync->n_ActionLigne     	= n_ActionLigne_ITD_PREM ;           
	pbd_Sync->c_Separ      			= '~' ;
	
	RETURN_VAL (0);
}

/**===============================================================================
objet 	: Fonction de test conditions synchro entre Perimeter et ITD_PREM
retour 	:	0		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==================================================================================*/
int n_CondSync_ITD_PREM( char **pbd_InRecOwner , char **pbd_InRecChild )
{
	DEBUT_FCT("n_CondSync_ITD_PREM");
	int ret;
	
	if ( ( ret = strcmp( pbd_InRecOwner[CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[END_NT] ) - atoi( pbd_InRecChild[GT_END_NT] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( pbd_InRecOwner[SEC_NF] ) - atoi( pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[UW_NT] ) - atoi( pbd_InRecChild[GT_UW_NT] ) ) != 0 ) 		return ret;
	
	RETURN_VAL (0);
}

/**=================================================================================
objet 	: 	Fonction lance a chaque ligne synchro entre Perimeter et ITD_PREM
retour 	:	0	---> traitement correctement effectue
====================================================================================*/ 
int n_ActionLigne_ITD_PREM( char **pbd_InRecOwner ,char **pbd_InRecChild )
{
	DEBUT_FCT("n_ActionLigne_ITD_PREM");
	double 	d_taux = 1;
	char 	MsgAno[150];
	
	if ( strcmp( pbd_InRecOwner[GT_EGPICUR_CF], pbd_InRecChild[GTSII_ACMCUR_CF] ) != 0 )
	{	
		d_taux = d_GetTaux( Kp_InputFilExc, 
							(char) atoi( pbd_InRecChild[GT_SSD_CF] ), 
							atoi(Blcshyear),                           //atoi( pbd_InRecChild[GT_BALSHEY_NF] ), 
							pbd_InRecChild[GTSII_ACMCUR_CF], 
							pbd_InRecOwner[GT_EGPICUR_CF] 
							);
		if ( d_taux < 0 )
		{
			sprintf( MsgAno, "No rate for :( CTR %s - END %s - SEC %s - UWY %s - UW %s )\n", 
			pbd_InRecChild[GT_CTR_NF],  
			pbd_InRecChild[GT_END_NT], 
			pbd_InRecChild[GT_SEC_NF], 
			pbd_InRecChild[GT_UWY_NF], 
			pbd_InRecChild[GT_UW_NT] );
			
			n_WriteAno( MsgAno );
			d_taux 	= 1;	
		}                                    
	}
    	
	if( strcmp( pbd_InRecChild[TRN_CODE], "1010" ) == 0 )	
		d_ITD_PREM += atof(pbd_InRecChild[GTSII_ACMAMT_MC]) * d_taux;
	if( strcmp(pbd_InRecChild[TRN_CODE], "1010" ) == 0 && 
		( strcmp( pbd_InRecChild[LINETYP_NF],"AC") == 0  || strcmp(pbd_InRecChild[LINETYP_NF],"AA") == 0 ))
		d_ITD_PREM_ACT += atof(pbd_InRecChild[GTSII_ACMAMT_MC]) * d_taux;
	if(( strcmp(pbd_InRecChild[TRN_CODE], "2010") == 0  || strcmp(pbd_InRecChild[TRN_CODE], "2013") == 0 || 
		 strcmp(pbd_InRecChild[TRN_CODE], "2019") == 0 ) && 
		( strcmp(pbd_InRecChild[LINETYP_NF],"AC") == 0  || strcmp(pbd_InRecChild[LINETYP_NF],"AA") == 0 ))
		d_FIXED_CHARGE_ACT += atof(pbd_InRecChild[GTSII_ACMAMT_MC]) * d_taux;	
	
	RETURN_VAL (0);
}

/**==============================================================================
objet 	: 	Fonction initialisation synchro entre Perimeter et UPR
retour 	:	0	---> traitement correctement effectue
=================================================================================*/
int n_Init_UPR_Q(T_RUPTURE_SYNC_VAR  *pbd_Sync)
{
	DEBUT_FCT("n_Init_UPR_Q");
    
	memset( pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;
	n_OpenFileAppl ("ESFC3640_I5", "rt", &(pbd_Sync->pf_InputFil));

	pbd_Sync->ConditionEndSync  	= n_CondSync_UPR_Q ;        
	pbd_Sync->n_ActionLigne     	= n_ActionLigne_UPR_Q ;           
	pbd_Sync->c_Separ      			= '~' ;
	
	RETURN_VAL (0);
}

/**===============================================================================
objet 	: 	Fonction de test conditions synchro entre Perimeter et UPR
retour 	:	0		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==================================================================================*/
int n_CondSync_UPR_Q( char **pbd_InRecOwner , char **pbd_InRecChild )
{
	DEBUT_FCT("n_CondSync_UPR_Q");
	int ret;
	
	if ( ( ret = strcmp( pbd_InRecOwner[CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[END_NT] ) - atoi( pbd_InRecChild[GT_END_NT] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( pbd_InRecOwner[SEC_NF] ) - atoi( pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[UW_NT] ) - atoi( pbd_InRecChild[GT_UW_NT] ) ) != 0 ) 		return ret;
	
	RETURN_VAL (0);
}

/**=================================================================================
objet 	: 	Fonction lance a chaque ligne synchro entre Perimeter et UPR
retour 	:	0	---> traitement correctement effectue
====================================================================================*/ 
int n_ActionLigne_UPR_Q( char **pbd_InRecOwner ,char **pbd_InRecChild )
{
	DEBUT_FCT("n_ActionLigne_UPR_Q");
	double 	d_taux = 1;
	char 	MsgAno[150];
	
	//if( strcmp( pbd_InRecOwner[CTR_NF], "10F132462") == 0 && strcmp( pbd_InRecOwner[UWY_NF], "2021" ) == 0 )
	if ( strcmp( pbd_InRecOwner[GT_EGPICUR_CF], pbd_InRecChild[GTSII_ACMCUR_CF] ) != 0 )
	{	
		d_taux = d_GetTaux( Kp_InputFilExc, 
							(char) atoi( pbd_InRecChild[GT_SSD_CF] ), 
							atoi(Blcshyear),                         //atoi( pbd_InRecChild[GT_BALSHEY_NF] ), 
							pbd_InRecChild[GTSII_ACMCUR_CF], 
							pbd_InRecOwner[GT_EGPICUR_CF] 
							);
		if ( d_taux < 0 )
		{
			sprintf( MsgAno, "No rate for :( CTR %s - END %s - SEC %s - UWY %s - UW %s )\n", 
			pbd_InRecChild[GT_CTR_NF],  
			pbd_InRecChild[GT_END_NT], 
			pbd_InRecChild[GT_SEC_NF], 
			pbd_InRecChild[GT_UWY_NF], 
			pbd_InRecChild[GT_UW_NT] );
			
			n_WriteAno( MsgAno );
			d_taux 	= 1;	
		}
	}
	if( strcmp( pbd_InRecChild[TRN_CODE], "1030" ) == 0 )
		d_UPR_Q += atof(pbd_InRecChild[GTSII_ACMAMT_MC]) * d_taux;
	
	RETURN_VAL (0);
}

/**==============================================================================
objet 	: 	Fonction initialisation synchro entre Perimeter et UPR PREV
retour 	:	0	---> traitement correctement effectue
=================================================================================*/
int n_Init_UPR_PREVQ(T_RUPTURE_SYNC_VAR  *pbd_Sync)
{
	DEBUT_FCT("n_Init_UPR_PREVQ");

	memset( pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;
	n_OpenFileAppl ("ESFC3640_I6", "rt", &(pbd_Sync->pf_InputFil));

	pbd_Sync->ConditionEndSync  	= n_CondSync_UPR_PREVQ ;        
	pbd_Sync->n_ActionLigne     	= n_ActionLigne_UPR_PREVQ ;
	pbd_Sync->c_Separ      			= '~' ;
	
	RETURN_VAL (0);
}

/**===============================================================================
objet 	: 	Fonction de test conditions synchro entre le Perimeter et UPR PREV
retour 	:	0		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==================================================================================*/
int n_CondSync_UPR_PREVQ( char **pbd_InRecOwner , char **pbd_InRecChild )
{
	DEBUT_FCT("n_CondSync_UPR_PREVQ");
	int ret;
	
	if ( ( ret = strcmp( pbd_InRecOwner[CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[END_NT] ) - atoi( pbd_InRecChild[GT_END_NT] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( pbd_InRecOwner[SEC_NF] ) - atoi( pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[UW_NT] ) - atoi( pbd_InRecChild[GT_UW_NT] ) ) != 0 ) 		return ret;
	
	RETURN_VAL (0);
}

/**=================================================================================
objet 	: 	Fonction lance a chaque ligne synchro entre Perimeter et UPR PREV
retour 	:	0	---> traitement correctement effectue
====================================================================================*/
int n_ActionLigne_UPR_PREVQ( char **pbd_InRecOwner ,char **pbd_InRecChild )
{
	DEBUT_FCT("n_ActionLigne_UPR_PREVQ");
	double 	d_taux = 1;
	char 	MsgAno[150];
	
	if ( strcmp( pbd_InRecOwner[GT_EGPICUR_CF], pbd_InRecChild[GTSII_ACMCUR_CF] ) != 0 )
	{	
		d_taux = d_GetTaux( Kp_InputFilExc, 
							(char) atoi( pbd_InRecChild[GT_SSD_CF] ), 
							atoi(Blcshyear),                                     //atoi( pbd_InRecChild[GT_BALSHEY_NF] ), 
							pbd_InRecChild[GTSII_ACMCUR_CF], 
							pbd_InRecOwner[GT_EGPICUR_CF]
							);
		if ( d_taux < 0 )
		{
			sprintf( MsgAno, "No rate for :( CTR %s - END %s - SEC %s - UWY %s - UW %s )\n", 
			pbd_InRecChild[GT_CTR_NF],  
			pbd_InRecChild[GT_END_NT], 
			pbd_InRecChild[GT_SEC_NF], 
			pbd_InRecChild[GT_UWY_NF], 
			pbd_InRecChild[GT_UW_NT]);
			
			n_WriteAno( MsgAno );
			d_taux 	= 1;	
		}
	}
	d_UPR_PREVQ += atof(pbd_InRecChild[GTSII_ACMAMT_MC]) * d_taux;
	
	RETURN_VAL (0);
}
