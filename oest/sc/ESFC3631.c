/**=======================================================================================
APPLICATION NAME          	: ACF/PCA: Expenses calculation
SOURCE NAME                 : ESFC3631.c
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
	
	/** Eclatement de la date AAAAMMJJ en 3 chaines de caractere */
	sscanf( Ksz_CloDat, "%4s%2s%2s", Ksz_Annee_bilan, Ksz_Mois_bilan, Ksz_Jour_bilan );
	
	/***************************************************************************/
	/**  Ouverture Des fichiers en entree et Initialisation des structures     */
	/***************************************************************************/
	
	if ( n_OpenFileAppl ( "ESFC3631_O1","wt",&Kp_OutputBatch ) == ERR )
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
	if ( n_CloseFileAppl( "ESFC3631_I1", &( pbd_Rupture.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3631_I2", &( pbd_Sync.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3631_I3", &( Kbd_Rupt_CASHFLOW.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3631_O1", &Kp_OutputBatch ) == ERR ) 
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

	if ( n_OpenFileAppl ("ESFC3631_I1", "rt", &(pbd_Rupt->pf_InputFil)))
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
	
	/** DOUBLE CHECK THE FIRST ONE IS DONE ON SHELL SIDE */
	if(	strcmp(ptb_InRec_Cur[CML_ACMTRS_NT],"314")		== 0  
		&& strcmp(ptb_InRec_Cur[CML_PATCAT_CT],"CSF")	== 0 
		&& strcmp(ptb_InRec_Cur[CML_PATTYP_CT],"INF") 	== 0 
		&& fabs( atof(ptb_InRec_Cur[CML_ACMAMT_MC]) ) 	>  0 
	)
	{	
		if (( *ptb_InRec_Cur[INI_STATUS] == '2' && atoi(ptb_InRec_Cur[FIRST_CLO_D]) == atoi(Ksz_CloDat)) 
			|| *ptb_InRec_Cur[INI_STATUS] == '1' 
		)
		{
			n_ProcessingRuptureSyncVar( &pbd_Sync, ptb_InRec_Cur );
		}
		else if (*ptb_InRec_Cur[INI_STATUS] == '2' && atoi(ptb_InRec_Cur[FIRST_CLO_D]) < atoi(Ksz_CloDat))
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
	DEBUT_FCT("n_Init_ITD_PREM");
	
	memset( pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;
	n_OpenFileAppl ("ESFC3631_I2", "rt", &(pbd_Sync->pf_InputFil));
	
	pbd_Sync->ConditionEndSync  	= n_ConditionSync ;        
	pbd_Sync->n_ActionLigne     	= n_ActionLigneSync ;           
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
	
	if ( ( ret = strcmp( pbd_InRecOwner[CML_CTR_NF], pbd_InRecChild[CML_CTR_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_END_NT] ) - atoi( pbd_InRecChild[CML_END_NT] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_SEC_NF] ) - atoi( pbd_InRecChild[CML_SEC_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_UWY_NF], pbd_InRecChild[CML_UWY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_UW_NT] ) - atoi( pbd_InRecChild[CML_UW_NT] ) ) != 0 ) 	return ret;
	
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
	double AMT_M, AMT_ANk, AMT_TOTAL;
	char amount[AMN_LEN], amount_ANk[65][AMN_LEN], amount_Total[AMN_LEN];
	
	AMT_M 		= atof(pbd_InRecChild[CML_ACMAMT_MC]);
	AMT_TOTAL 	= atof(pbd_InRecChild[CML_TOTAUX_MC]);
	
	memset(amount,0, sizeof(amount));
	memset(amount_Total,0, sizeof(amount_Total));
	
	/** CHECK IF THE COLUMN EXIST */
	if( pbd_InRecOwner[EARP_R1] != NULL && *pbd_InRecOwner[EARP_R1] != 0 )
	{
		/** CALCULATION OF THE CASHFLOW FOR ACMAMT_M */
		sprintf(amount , "%.3f" , AMT_M * atof(pbd_InRecOwner[EARP_R1]) );
		pbd_InRecChild[CML_ACMAMT_MC] = amount;
			
		/** CALCULATION OF THE CASHFLOW FOR TOTAL AMOUNTS */
		sprintf(amount_Total , "%.3f" , AMT_TOTAL * atof(pbd_InRecOwner[EARP_R1]) );
		pbd_InRecChild[CML_TOTAUX_MC] = amount_Total;  
			
		/** CALCULATION OF THE CASHFLOW FOR ANK YEAR */
		for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
		{
			AMT_ANk = atof(pbd_InRecChild[j]);
			sprintf( amount_ANk [j-CML_AN1], "%.3f" , AMT_ANk * atof(pbd_InRecOwner[EARP_R1]) );
			pbd_InRecChild[j] = amount_ANk [j-CML_AN1];
		}
		
		pbd_InRecChild[CML_BALSHEY_NF] 		= Ksz_Annee_bilan ;
		pbd_InRecChild[CML_BALSHRMTH_NF] 	= Ksz_Mois_bilan ;
		pbd_InRecChild[CML_BALSHRDAY_NF] 	= Ksz_Jour_bilan ;

		pbd_InRecChild[124] = 0;
		n_WriteCols(Kp_OutputBatch, pbd_InRecChild, '~', 0);
	}
	
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
	n_OpenFileAppl ("ESFC3631_I3", "rt", &(pbd_Sync->pf_InputFil));
	
	pbd_Sync->ConditionEndSync  	= n_CondSync_CSF ;        
	pbd_Sync->n_ActionLigne     	= n_ActionLigne_CSF ;           
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
	
	if ( ( ret = strcmp( pbd_InRecOwner[CML_CTR_NF], pbd_InRecChild[CML_CTR_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_END_NT] ) - atoi( pbd_InRecChild[CML_END_NT] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_SEC_NF] ) - atoi( pbd_InRecChild[CML_SEC_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_UWY_NF], pbd_InRecChild[CML_UWY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_UW_NT] ) - atoi( pbd_InRecChild[CML_UW_NT] ) ) != 0 ) 	return ret;
	
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
	double AMT_M, AMT_ANk, AMT_TOTAL;
	char amount[AMN_LEN], amount_ANk[65][AMN_LEN], amount_Total[AMN_LEN];
	
	AMT_M 		= atof(pbd_InRecChild[CML_ACMAMT_MC]);
	AMT_TOTAL 	= atof(pbd_InRecChild[CML_TOTAUX_MC]);
	
	memset(amount,0, sizeof(amount));
	memset(amount_Total,0, sizeof(amount_Total));
	
	/** CHECK IF THE COLUMN EXIST */
	if( pbd_InRecOwner[EARP_R1] != NULL && *pbd_InRecOwner[EARP_R1] != 0 )
	{
		/** CALCULATION OF THE CASHFLOW FOR ACMAMT_M */
		sprintf(amount , "%.3f" , AMT_M * atof(pbd_InRecOwner[EARP_R1]) );
		pbd_InRecChild[CML_ACMAMT_MC] = amount;
			
		/** CALCULATION OF THE CASHFLOW FOR TOTAL AMOUNTS */
		sprintf(amount_Total , "%.3f" , AMT_TOTAL * atof(pbd_InRecOwner[EARP_R1]) );
		pbd_InRecChild[CML_TOTAUX_MC] = amount_Total;  
			
		/** CALCULATION OF THE CASHFLOW FOR ANK YEAR */
		for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
		{
			AMT_ANk = atof(pbd_InRecChild[j]);
			sprintf( amount_ANk [j-CML_AN1], "%.3f" , AMT_ANk * atof(pbd_InRecOwner[EARP_R1]) );
			pbd_InRecChild[j] = amount_ANk [j-CML_AN1];
		}
		
		pbd_InRecChild[CML_BALSHEY_NF] 		= Ksz_Annee_bilan ;
		pbd_InRecChild[CML_BALSHRMTH_NF] 	= Ksz_Mois_bilan ;
		pbd_InRecChild[CML_BALSHRDAY_NF] 	= Ksz_Jour_bilan ;

		pbd_InRecChild[124] = 0;
		n_WriteCols(Kp_OutputBatch, pbd_InRecChild, '~', 0);
	}
	
	RETURN_VAL (0);
}