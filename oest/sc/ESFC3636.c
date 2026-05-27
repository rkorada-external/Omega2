/**=======================================================================================
APPLICATION NAME          	: ACF/PCA: Expenses calculation
SOURCE NAME                 : ESFC3636.c
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
15/09/2021      LEL   	97351       ACF/PCA: EXPENSES CALCULATION	
03/03/2022      JBD   	102523      remove the minus sign in rule R03-09 
05/07/2022		JBD		104778		Build new closing for I17S norm
06/01/2023		HR		107803		ULAE Paid - Incorrect or Missing amounts
22/02/2023	MiS	108484		Condition for IME Paid Calculation
09/03/2023      HR      108447      IAE and IME Paid - Add conversion 
16/05/2023      HR      108487      IAE and IME Paid - Add conversion 
22/05/2023      HR      109577      I17 - Calculate IME Paid on run off contracts 
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

#define OWNER_CUR_CF  26
 
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
	strcpy( Ksz_PrevCloDat, psz_GetCharArgv(3) );
	
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
	
	if ( n_OpenFileAppl ( "ESFC3636_O1","wt",&Kp_OutputBatch ) == ERR )
		ExitPgm( ERR_XX , "" );

	/** Ouverture du fichier en entree des cours de change FCURQUOT */
	if ( n_OpenFileAppl ( "ESFC3636_I5","rb",&Kp_InputFilExc ) == ERR )
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
	
	/** Initialisation de la variable Kbd_Rupt_PER */
        if ( n_Init_PER(&Kbd_Rupt_PER) )
                ExitPgm ( ERR_XX , "" );

	/** Lancement du traitement du fichier maitre */
	if (n_ProcessingRuptureVar(&pbd_Rupture) == ERR) 
		ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
	
	/***************************************************************************/
	/**   Fermeture Des fichiers ouverts                                       */
	/***************************************************************************/
	if ( n_CloseFileAppl( "ESFC3636_I1", &( pbd_Rupture.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3636_I2", &( pbd_Sync.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3636_I3", &( Kbd_Rupt_CASHFLOW.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESFC3636_I4", &( Kbd_Rupt_PER.pf_InputFil ) ) == ERR )
                ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESFC3636_I5", &Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3636_O1", &Kp_OutputBatch ) == ERR ) 
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

	if ( n_OpenFileAppl ("ESFC3636_I1", "rt", &(pbd_Rupt->pf_InputFil)))
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
	
	/** INITIALISATION OF PAID AMOUNT */
	flag = 0;
	n_MAINT_PAID = 0.0;
	n_ProcessingRuptureSyncVar( &Kbd_Rupt_PER, ptb_InRec_Cur);
	if (atoi(Ksz_IncCloDat) <= atoi(Ksz_CloDat))
	{
		if ((*ptb_InRec_Cur[GRPINISTS_CT] == '2' || *ptb_InRec_Cur[GRPINISTS_CT] == '9') && atoi(ptb_InRec_Cur[GRPFIRCLO_D]) <= atoi(Ksz_PrevCloDat))
		{
			n_ProcessingRuptureSyncVar( &Kbd_Rupt_CASHFLOW, ptb_InRec_Cur );
			if( flag == 1)
			{
				sprintf(TrnCod, "%s%c", "1146074", Norme);
				n_EcrireGT( ptb_InRec_Cur, + n_MAINT_PAID /4, TrnCod );
			}	
		}
		else if ( *ptb_InRec_Cur[GRPINISTS_CT] == '1'
			|| ( *ptb_InRec_Cur[GRPINISTS_CT] == '2' && atoi(ptb_InRec_Cur[GRPFIRCLO_D]) == atoi(Ksz_CloDat))  
		)
		{
			n_ProcessingRuptureSyncVar( &pbd_Sync, ptb_InRec_Cur );
			if( flag == 1)
			{
				sprintf(TrnCod, "%s%c", "1146074", Norme);
				n_EcrireGT( ptb_InRec_Cur, + n_MAINT_PAID /4, TrnCod );
			}	
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
	n_OpenFileAppl ("ESFC3636_I2", "rt", &(pbd_Sync->pf_InputFil));
	
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
	
	if ( ( ret = strcmp( pbd_InRecOwner[CTR_NF], pbd_InRecChild[CML_CTR_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[END_NT] ) - atoi( pbd_InRecChild[CML_END_NT] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( pbd_InRecOwner[SEC_NF] ) - atoi( pbd_InRecChild[CML_SEC_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[UWY_NF], pbd_InRecChild[CML_UWY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[UW_NT] ) - atoi( pbd_InRecChild[CML_UW_NT] ) ) != 0 ) 	return ret;
	//if ( ( ret = strcmp( pbd_InRecOwner[OWNER_CUR_CF], pbd_InRecChild[CML_CUR_CF] ) ) != 0 ) 	return ret;
	
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
	flag = 1;

	double 	d_taux = 1;
	char 	MsgAno[150];
	
	if ( strcmp( pbd_InRecOwner[OWNER_CUR_CF], pbd_InRecChild[CML_CUR_CF] ) != 0 )
	{	
		d_taux = d_GetTaux( Kp_InputFilExc, 
							(char) atoi( pbd_InRecChild[CML_SSD_CF] ), 
							atoi( Ksz_Annee_bilan ), 
							pbd_InRecChild[CML_CUR_CF], 
							pbd_InRecOwner[OWNER_CUR_CF] 
							);
		if ( d_taux < 0 )
		{
			sprintf( MsgAno, "No rate for :( CTR %s - END %s - SEC %s - UWY %s - UW %s )\n", 
			pbd_InRecChild[CML_CTR_NF],  
			pbd_InRecChild[CML_END_NT], 
			pbd_InRecChild[CML_SEC_NF], 
			pbd_InRecChild[CML_UWY_NF], 
			pbd_InRecChild[CML_UW_NT] );
			
			n_WriteAno( MsgAno );
			d_taux 	= 1;	
		}
	}

    n_MAINT_PAID += atof(pbd_InRecChild[CML_AN1]) * d_taux;
	
	/** MAINTENANCE EXPENSES PAID AGGREGATION */	
	//n_MAINT_PAID += atof(pbd_InRecChild[CML_AN1]);
	
	pbd_InRecOwner[CUR_NF] 	= pbd_InRecChild[CML_CUR_CF];
	pbd_InRecOwner[CED_NF] 	= pbd_InRecChild[CML_CED_NF]; 
	pbd_InRecOwner[BRK_NF] 	= pbd_InRecChild[CML_BRK_NF]; 
	pbd_InRecOwner[PAY_NF]	= pbd_InRecChild[CML_PAY_NF]; 
	pbd_InRecOwner[KEY_NF]	= pbd_InRecChild[CML_KEY_NF];
	
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
	n_OpenFileAppl ("ESFC3636_I3", "rt", &(pbd_Sync->pf_InputFil));
	
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
	
	if ( ( ret = strcmp( pbd_InRecOwner[CTR_NF], pbd_InRecChild[CML_CTR_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[END_NT] ) - atoi( pbd_InRecChild[CML_END_NT] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( pbd_InRecOwner[SEC_NF] ) - atoi( pbd_InRecChild[CML_SEC_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[UWY_NF], pbd_InRecChild[CML_UWY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[UW_NT] ) - atoi( pbd_InRecChild[CML_UW_NT] ) ) != 0 ) 	return ret;
//	if ( ( ret = strcmp( pbd_InRecOwner[OWNER_CUR_CF] , pbd_InRecChild[CML_CUR_CF] ) ) != 0 ) 	return ret;
	
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
	flag = 1;

	double 	d_taux = 1;
	char 	MsgAno[150];
	
	if ( strcmp( pbd_InRecOwner[OWNER_CUR_CF], pbd_InRecChild[CML_CUR_CF] ) != 0 )
	{	
		d_taux = d_GetTaux( Kp_InputFilExc, 
							(char) atoi( pbd_InRecChild[CML_SSD_CF] ), 
							atoi( Ksz_Annee_bilan ), 
							pbd_InRecChild[CML_CUR_CF], 
							pbd_InRecOwner[OWNER_CUR_CF] 
							);
		if ( d_taux < 0 )
		{
			sprintf( MsgAno, "No rate for :( CTR %s - END %s - SEC %s - UWY %s - UW %s )\n", 
			pbd_InRecChild[CML_CTR_NF],  
			pbd_InRecChild[CML_END_NT], 
			pbd_InRecChild[CML_SEC_NF], 
			pbd_InRecChild[CML_UWY_NF], 
			pbd_InRecChild[CML_UW_NT] );
			
			n_WriteAno( MsgAno );
			d_taux 	= 1;	
		}
	}
	
	n_MAINT_PAID += atof(pbd_InRecChild[CML_AN1]) * d_taux;

	/** MAINTENANCE EXPENSES PAID AGGREGATION */	
	//n_MAINT_PAID += atof(pbd_InRecChild[CML_AN1]);
	
	pbd_InRecOwner[CUR_NF] 	= pbd_InRecChild[CML_CUR_CF];
	pbd_InRecOwner[CED_NF] 	= pbd_InRecChild[CML_CED_NF]; 
	pbd_InRecOwner[BRK_NF] 	= pbd_InRecChild[CML_BRK_NF]; 
	pbd_InRecOwner[PAY_NF]	= pbd_InRecChild[CML_PAY_NF]; 
	pbd_InRecOwner[KEY_NF]	= pbd_InRecChild[CML_KEY_NF];
	
	RETURN_VAL (0);
}

/**===============================================================================
objet   : Fonction initialisation synchro entre PERICASE et PERIMETER
retour  :       0       ---> traitement correctement effectue
==================================================================================*/
int n_Init_PER(T_RUPTURE_SYNC_VAR  *pbd_Sync)
{
        DEBUT_FCT("n_Init_PER");

        memset( pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;
        n_OpenFileAppl ("ESFC3636_I4", "rt", &(pbd_Sync->pf_InputFil));

        pbd_Sync->ConditionEndSync      = n_CondSync_PER ;
        pbd_Sync->n_ActionLigne         = n_ActionLigne_PER ;
        pbd_Sync->c_Separ                       = '~' ;

        RETURN_VAL (0);
}

/**===========================================================================
objet   : Fonction de test de synchro entre PERICASE et PERIMETER
retour  :       0       ---> synchro
                        1       ---> non trouve
==============================================================================*/
int n_CondSync_PER( char **pbd_InRecOwner , char **pbd_InRecChild )
{
        DEBUT_FCT("n_CondSync_PER");
        int ret;
	
        if ( ( ret = strcmp( pbd_InRecOwner[CTR_NF], pbd_InRecChild[PER_CTR_NF] ) ) != 0 )                      return ret;
        if ( ( ret = atoi( pbd_InRecOwner[END_NT] ) - atoi( pbd_InRecChild[PER_END_NT] ) ) != 0 )       return ret;
        if ( ( ret = atoi( pbd_InRecOwner[SEC_NF] ) - atoi( pbd_InRecChild[PER_SEC_NF] ) ) != 0 )       return ret;
        if ( ( ret = strcmp( pbd_InRecOwner[UWY_NF], pbd_InRecChild[PER_UWY_NF] ) ) != 0 )                      return ret;
        if ( ( ret = atoi( pbd_InRecOwner[UW_NT] ) - atoi( pbd_InRecChild[PER_UW_NT] ) ) != 0 )         return ret;

        RETURN_VAL (0);
}

/**===========================================================================
objet   : Fonction de test de synchro entre PERICASE et PERIMETER
retour  :       0       ---> synchro
                        1       ---> non trouve
==============================================================================*/
int n_ActionLigne_PER( char **pbd_InRecOwner , char **pbd_InRecChild )
{
        DEBUT_FCT("n_ActionLigne_PER");

        /** Inception Date **/
        strcpy(Ksz_IncCloDat,pbd_InRecChild[PER_CTRINC_D]);

        RETURN_VAL (0);
}


/**===============================================================================
objet:	Cette fonction permet d ecrire des resultas dans le Fichier : EST_EXPENSES 
=================================================================================*/
int n_EcrireGT( char **pbd_InRec_Cur, double d_Montant, char *trn_Code )
{
	char *Gt[NB_COL_GT] ; 
	char sz_Amt[18+1] ;
	
	sprintf( sz_Amt, "%-.3f", d_Montant ) ;

	Gt[GT_SSD_CF] 				= pbd_InRec_Cur[SSD_CF] ; 
	Gt[GT_ESB_CF] 				= pbd_InRec_Cur[ESB_CF] ;
	Gt[GT_BALSHEY_NF] 			= Ksz_Annee_bilan ;		     
	Gt[GT_BALSHRMTH_NF] 		= Ksz_Mois_bilan;				
	Gt[GT_BALSHRDAY_NF] 		= Ksz_Jour_bilan; 				
	Gt[GT_TRNCOD_CF] 			= trn_Code ;			
	Gt[GT_DBLTRNCOD_CF] 		= "" ;				
	Gt[GT_CTR_NF] 				= pbd_InRec_Cur[CTR_NF] ;                      
	Gt[GT_END_NT] 				= pbd_InRec_Cur[END_NT] ;   
	Gt[GT_SEC_NF] 				= pbd_InRec_Cur[SEC_NF] ;     
	Gt[GT_UWY_NF] 				= pbd_InRec_Cur[UWY_NF] ;    
	Gt[GT_UW_NT] 				= pbd_InRec_Cur[UW_NT] ;      
	Gt[GT_OCCYEA_NF] 			= Ksz_Annee_bilan;				
	Gt[GT_ACY_NF] 				= Ksz_Annee_bilan;  			
	Gt[GT_SCOSTRMTH_NF] 		= Ksz_Mois_bilan; 				
	Gt[GT_SCOENDMTH_NF] 		= Ksz_Mois_bilan;				
	Gt[GT_CLM_NF] 				= "" ;
	Gt[GT_CUR_CF] 				= pbd_InRec_Cur[OWNER_CUR_CF];
	Gt[GT_AMT_M] 				= sz_Amt ; 					
	Gt[GT_CED_NF] 				= pbd_InRec_Cur[CED_NF]; 
	Gt[GT_BRK_NF] 				= pbd_InRec_Cur[BRK_NF]; 					
	Gt[GT_PAY_NF] 				= pbd_InRec_Cur[PAY_NF]; 					
	Gt[GT_KEY_NF] 				= pbd_InRec_Cur[KEY_NF];
	Gt[GT_RETCTR_NF] 			= "";
	Gt[GT_RETEND_NT] 			= "";
	Gt[GT_RETSEC_NF] 			= "";
	Gt[GT_RTY_NF] 				= "";
	Gt[GT_RETUW_NT] 			= "";
	Gt[GT_RETOCCYEA_NF] 		= "";
	Gt[GT_RETACY_NF] 			= "";
	Gt[GT_RETSCOSTRMTH_NF] 		= "";
	Gt[GT_RETSCOENDMTH_NF] 		= "";
	Gt[GT_RCL_NF] 				= "";
	Gt[GT_RETCUR_CF] 			= "";
	Gt[GT_RETAMT_M] 			= "";
	Gt[GT_PLC_NT] 				= "";
	Gt[GT_RTO_NF] 				= "";
	Gt[GT_INT_NF] 				= "";
	Gt[GT_RETPAY_NF] 			= "";
	Gt[GT_RETKEY_CF] 			= "";
	Gt[GT_RETINTAMT_M] 			= "";
	Gt[GT_RETINTAMT_M + 1] 		= NULL ;	
			
	n_WriteCols( Kp_OutputBatch , Gt, SEPARATEUR, 0 ) ;

	RETURN_VAL(0);
}

/**===========================================================================
objet	:	Fonction pour retourner symbole norme a rensigner dans TRNCOD 
retour 	:   Caractere a renseigner dans TRNCOD	
=============================================================================*/
char n_GetNorme( const char *Norme_CF )
{
	if( strcmp(Norme_CF, "I17G") == 0 || strcmp(Norme_CF, "I17S") == 0)		return 'I';
	else if ( strcmp(Norme_CF, "I17P") == 0 )	return 'K';
	else if ( strcmp(Norme_CF, "I17L") == 0 )	return 'M'; 
	else return 'R';
}
