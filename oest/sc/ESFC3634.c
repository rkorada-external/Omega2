/**=======================================================================================
APPLICATION NAME          	: ACF/PCA: Expenses calculation
SOURCE NAME                 : ESFC3634.c
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
	
	/***************************************************************************/
	/**  Ouverture Des fichiers en entree et Initialisation des structures     */
	/***************************************************************************/
	
	if ( n_OpenFileAppl ( "ESFC3634_O1","wt",&Kp_OutputBatch ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	/** Ouverture du fichier en entree des cours de change FCURQUOT */
	if ( n_OpenFileAppl ( "ESFC3634_I4","rb",&Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	/** Initialisation de la variable pbd_Rupture */
	if ( n_InitRupture(&pbd_Rupture) ) 
		ExitPgm ( ERR_XX , "" );
	
	/** Initialisation de la variable Kbd_Rupt_CASHFLOW */
	if ( n_Init_CASHFLOW(&Kbd_Rupt_CASHFLOW) ) 
		ExitPgm ( ERR_XX , "" );
	
	/** Initialisation de la variable Kbd_RuptDLGTAAPNAE */
	if ( n_InitSync(&Kbd_RuptDLGTAAPNAE) ) 
		ExitPgm ( ERR_XX , "" );

	/** Lancement du traitement du fichier maitre */
	if (n_ProcessingRuptureVar(&pbd_Rupture) == ERR) 
		ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
	
	/***************************************************************************/
	/**   Fermeture Des fichiers ouverts                                       */
	/***************************************************************************/
	if ( n_CloseFileAppl( "ESFC3634_I1", &( pbd_Rupture.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3634_I2", &( Kbd_Rupt_CASHFLOW.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3634_I3", &( Kbd_RuptDLGTAAPNAE.pf_InputFil ) ) == ERR ) 
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3634_I4", &Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3634_O1", &Kp_OutputBatch ) == ERR ) 
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

	if ( n_OpenFileAppl ("ESFC3634_I1", "rt", &(pbd_Rupt->pf_InputFil)))
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
	
	/** GLOBAL VARIABLES */
	d_UPR			= 0.0;
	d_FUTURE_PREM 	= 0.0;
	
	/** LANCEMENT SYNCHRONISATION AVEC LE FICHIER DES FUTURE  */
	n_ProcessingRuptureSyncVar( &Kbd_Rupt_CASHFLOW, ptb_InRec_Cur );

	/** LANCEMENT SYNCHRONISATION AVEC LE FICHIER DES UPR */
	n_ProcessingRuptureSyncVar( &Kbd_RuptDLGTAAPNAE, ptb_InRec_Cur );
	
	if( fabs( d_FUTURE_PREM + d_UPR ) > 1 )
	{
		ptb_InRec_Cur[PER_RET_FLAG] = "YES";
		n_WriteCols(Kp_OutputBatch,  ptb_InRec_Cur, '~', 0);
	}
	else
	{
		ptb_InRec_Cur[PER_RET_FLAG] = "NO";
		n_WriteCols(Kp_OutputBatch,  ptb_InRec_Cur, '~', 0);
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
	n_OpenFileAppl ("ESFC3634_I3", "rt", &(pbd_Sync->pf_InputFil));
	
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
	
	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_RETCTR_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[PER_END_NT] ) - atoi( pbd_InRecChild[GT_RETEND_NT] ) ) != 0 )		return ret;
	if ( ( ret = atoi( pbd_InRecOwner[PER_SEC_NF] ) - atoi( pbd_InRecChild[GT_RETSEC_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_RTY_NF] ) ) != 0 ) 				return ret;
	if ( ( ret = atoi( pbd_InRecOwner[PER_UW_NT] ) - atoi( pbd_InRecChild[GT_RETUW_NT] ) ) != 0 ) 		return ret;
	if ( ( ret = atoi( pbd_InRecOwner[PER_PLC_NT]) - atoi( pbd_InRecChild[GT_PLC_NT] )) != 0 ) 			return ret;
	
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
	double 	d_taux = 1 ;
	char 	MsgAno[150];
	
	if ( strcmp( pbd_InRecOwner[PER_PCPCUR_CF], pbd_InRecChild[GTSII_ACMCUR_CF] ) != 0 )
	{	
		d_taux = d_GetTaux( Kp_InputFilExc, 
							(char) atoi( pbd_InRecChild[GT_SSD_CF] ), 
							atoi( pbd_InRecChild[GT_BALSHEY_NF] ), 
							pbd_InRecChild[GTSII_ACMCUR_CF], 
							pbd_InRecOwner[PER_PCPCUR_CF] 
							);
		if ( d_taux < 0 )
		{
			sprintf( MsgAno, "No rate for RETRO :( CTR %s - END %s - SEC %s - UWY %s - UW %s )\n", 
			pbd_InRecChild[GT_RETCTR_NF],  
			pbd_InRecChild[GT_RETEND_NT], 
			pbd_InRecChild[GT_RETSEC_NF], 
			pbd_InRecChild[GT_RTY_NF], 
			pbd_InRecChild[GT_RETUW_NT] );
			
			n_WriteAno( MsgAno );
			d_taux 	= 1;	
		}
	}
	d_UPR += atof(pbd_InRecChild[GTSII_ACMAMT_MC]) * d_taux;
	
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
	n_OpenFileAppl ("ESFC3634_I2", "rt", &(pbd_Sync->pf_InputFil));
	
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
	
	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[CML_RETCTR_NF] ) ) != 0 ) 		return ret;
	if ( ( ret = atoi( pbd_InRecOwner[PER_END_NT]) - atoi(pbd_InRecChild[CML_RETEND_NT])) != 0 ) 	return ret;
	if ( ( ret = atoi( pbd_InRecOwner[PER_SEC_NF]) - atoi( pbd_InRecChild[CML_RETSEC_NF])) != 0)	return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[CML_RTY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[PER_UW_NT]) - atoi( pbd_InRecChild[CML_RETUW_NT] )) != 0 ) 	return ret;
	if ( ( ret = atoi( pbd_InRecOwner[PER_PLC_NT]) - atoi( pbd_InRecChild[CML_PLC_NT] )) != 0 ) 	return ret;
	
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
	
	double 	d_taux = 1;
	char 	MsgAno[150];

	if ( strcmp( pbd_InRecOwner[PER_PCPCUR_CF], pbd_InRecChild[CML_ACMCUR_CF] ) != 0 )
	{	
		d_taux = d_GetTaux( Kp_InputFilExc, 
							(char) atoi( pbd_InRecChild[CML_SSD_CF] ), 
							atoi( pbd_InRecChild[CML_BALSHEY_NF] ), 
							pbd_InRecChild[CML_ACMCUR_CF], 
							pbd_InRecOwner[PER_PCPCUR_CF] 
							);
		if ( d_taux < 0 )
		{
			sprintf( MsgAno, "No rate for RETRO :( CTR %s - END %s - SEC %s - UWY %s - UW %s )\n", 
					pbd_InRecChild[CML_RETCTR_NF],  
					pbd_InRecChild[CML_RETEND_NT], 
					pbd_InRecChild[CML_RETSEC_NF], 
					pbd_InRecChild[CML_RTY_NF], 
					pbd_InRecChild[CML_RETUW_NT] 
					);
			
			n_WriteAno( MsgAno );
			d_taux 	= 1;	
		}
	}
	d_FUTURE_PREM += atof(pbd_InRecChild[CML_ACMAMT_MC]) * d_taux;
	
	RETURN_VAL (0);
}