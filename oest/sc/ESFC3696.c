/*================================================================================================================================
Nom de l'application          : IFRS17 REVENUE CALCULATION
Nom du source                 : ESFC3696.c
Revision                      : V1
Date de creation              : 10/2020
Auteur                        : L.ELFAHIM
Squelette de base             : Batch
References des specifications : 
----------------------------------------------------------------------------------------------------------------------------------
DESCRIPTION :
	CE PROGRAMME EST DESTINE A FAIRE LE CALCUL DE IFRS17 REVENUE POUR FWD SANS LKI CORRESPONDANT POUR RETRO P

HISTORIQUE DES MODIFICATIONS :
	<JJ/MM/AAAA>   	<AUTEUR>   	<SPIRA>		<DESCRIPTION DE LA MODIFICATION>
	12/10/2020   	LEL       	90051    	DEVELOPPEMENT DE LA VERSION INITIALE
	10/12/2020    	LEL       	90446		IMPLEMENTATION OF FIRST CLOSING CONDITIONS OF CSUOE
	24/12/2020    	LEL  		91111		EXTEND TO INCURRED RECEIVABLES/PREMIUM ESTIMATES (1010) AND CHANGE EGPI GROSS UP
	28/12/2020    	LEL  		92221		BDT ONLY FUTURE POSITIONS SHOULD BE CONSIDERED
	29/12/2020    	LEL  		91113		ADD AN ADDITIONAL CONDITION TO LAUNCH REVENUE
	28/01/2021   	LEL  		93211		MANAGE RETRO GRANULARITY
	09/02/2021    	LEL       	92797		IFRS 17 - UPR AT FIRST CLOSING FOR GROSS UP
	24/03/2021    	LEL       	92786		Manage GROUPING 1051 && 1010
	22/04/2021    	LEL       	95798		DESACTIVATE UPR OPENING
	14/05/2021    	LEL       	95212		DELETE CASE INCEPTION STATUS EMPTY
	18/06/2021    	LEL       	97096		OVERRIDING DATA FROM PREVIOUS PERIOD WHEN FIRST CLOSING
=================================================================================================================================*/

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
	
	n_DEBUG_LEVEL = atoi(psz_GetCharArgv(1));
	strcpy( Ksz_CloDat, psz_GetCharArgv(2));
	n_Quarter = n_GetIntArgv(3);
	
	/***************************************************************************/
	/**  Ouverture Des fichiers en entree et Initialisation des structures     */
	/***************************************************************************/
	
	if ( n_OpenFileAppl ( "ESFC3696_O1","wt",&Kp_OutputFil_REVENUE ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_OpenFileAppl ( "ESFC3696_O2","wt",&Kp_OutputFil_TRACE ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* Ouverture du fichier en entree des cours de change FCURQUOT */
	if ( n_OpenFileAppl ( "ESFC3696_I7","rb",&Kp_InputFilExc ) == ERR )
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
	
	/* Initialisation de la variable Kbd_Rupt_CASHFLOW_INI */
	if ( n_Init_CASHFLOW_INI(&Kbd_Rupt_CASHFLOW_INI) ) 
		ExitPgm ( ERR_XX , "" );
	
	/* Lancement du traitement du fichier maitre */
	if (n_ProcessingRuptureVar(&Kbd_Rup_LockedInRate) == ERR) 
		ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
	
	/***************************************************************************/
	/**   Fermeture Des fichiers ouverts                                       */
	/***************************************************************************/
	if ( n_CloseFileAppl( "ESFC3696_I1", &( Kbd_Rup_LockedInRate.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3696_I2", &( Kbd_Rupt_CASHFLOW_Q.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3696_I3", &( Kbd_Rupt_CASHFLOW_PREVQ.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3696_I4", &( Kbd_Rupt_ITD_PREM.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3696_I5", &( Kbd_Rupt_UPR_Q.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3696_I6", &( Kbd_Rupt_UPR_PREVQ.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3696_I7", &Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3696_I8", &( Kbd_Rupt_CASHFLOW_INI.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3696_O1", &Kp_OutputFil_REVENUE ) == ERR ) 
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3696_O2", &Kp_OutputFil_TRACE ) == ERR ) 
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
int n_Init_LockedInRate(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_Init_LockedInRate");
	
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

	if ( n_OpenFileAppl ("ESFC3696_I1", "rt", &(pbd_Rupt->pf_InputFil)))
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
	if ( ( ret = atoi( ptb_InRec[CML_END_NT] ) - atoi( ptb_InRec_Cur[CML_END_NT] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( ptb_InRec[CML_SEC_NF] ) - atoi( ptb_InRec_Cur[CML_SEC_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = strcmp( ptb_InRec[CML_UWY_NF], ptb_InRec_Cur[CML_UWY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( ptb_InRec[CML_UW_NT] ) - atoi( ptb_InRec_Cur[CML_UW_NT] ) ) != 0 ) 		return ret;
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
	
	// ASSUMED GLOBAL VARIABLES
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

/** ===========================================================================
objet 	: 	Fonction lancee a chaque ligne de repture
retour 	:	0  		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==============================================================================*/
int n_ActionLigne_LockedInRate( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionLigne_LockedInRate" ) ;

	int 	ACMTRS3, j;
	double	d_Ratio, d_Retro_Ratio;
	char 	amount[AMN_LEN], ank_mnt[65][AMN_LEN], total_mnt[AMN_LEN];
	
	char *origine_Cur [125];
	for( j = 0; j< 125; j++ ) origine_Cur[j] = ptb_InRec_Cur[j];
		
	memset(amount,0, sizeof(amount));
	memset(total_mnt,0, sizeof(total_mnt));
	ACMTRS3 = atoi(ptb_InRec_Cur[CML_ACMTRS3_NT2]);
	
	//if( strcmp( ptb_InRec_Cur[23], "RP0001966") == 0 && strcmp( ptb_InRec_Cur[26], "2018" ) == 0  && strcmp( ptb_InRec_Cur[7], "02T031570" ) == 0 && strcmp(ptb_InRec_Cur[CML_PATCAT_CT],"BDT" ) == 0 && ACMTRS3 == 1051 )
	
	// SPIRA 90446
	if (( *ptb_InRec_Cur[INI_STATUS] == '2' && atoi(ptb_InRec_Cur[FIRST_CLO_D]) == atoi(Ksz_CloDat)) || *ptb_InRec_Cur[INI_STATUS] == '1' )
	{	
		d_FUTURE_PREM_PREVQ = d_FUTURE_PREM_INI;
		d_UPR_PREVQ = d_REMAIN_ESTM_PREVQ = d_PREM_ESTM_PREVQ = 0;
	}
	// TRACE All amounts calculated
	if (n_DEBUG_LEVEL > 1)
	{
		fprintf(Kp_OutputFil_TRACE,
			"CSUOER %s~%s~%s~%s~%s|PLC %s|ACMTRSL3 %d|FP Q_1 %.3f|FP Q %.3f|WP %.3f|WP ACT %.3f|FC ACT %.3f|UPR Q_1 %.3f|UPR Q %.3f|P ESTM Q_1 %.3f|P ESTM Q %.3f|R ESTM Q_1 %.3f|R ESTM Q %.3f \n", 
			ptb_InRec_Cur[CML_RETCTR_NF],
			ptb_InRec_Cur[CML_RETEND_NT],
			ptb_InRec_Cur[CML_RETSEC_NF],
			ptb_InRec_Cur[CML_RTY_NF],
			ptb_InRec_Cur[CML_RETUW_NT],
			ptb_InRec_Cur[CML_PLC_NT],
			ACMTRS3,
			d_FUTURE_PREM_PREVQ,
			d_FUTURE_PREM_Q,
			d_ITD_PREM,
			d_ITD_PREM_ACT,
			d_FIXED_CHARGE_ACT,
			d_UPR_PREVQ,
			d_UPR_Q,
			d_PREM_ESTM_PREVQ,
			d_PREM_ESTM,
			d_REMAIN_ESTM_PREVQ,
			d_REMAIN_ESTM
		);
	}	
	if( fabs(d_FUTURE_PREM_PREVQ - d_UPR_PREVQ) > 1 )
	{	 
		if( ACMTRS3 == 1051 || ACMTRS3 == 1010 )
		{
			if( fabs(d_FUTURE_PREM_PREVQ + d_PREM_ESTM_PREVQ + d_REMAIN_ESTM_PREVQ) < 1 && fabs( d_UPR_PREVQ ) >= 1 )
			{
				ptb_InRec_Cur[CML_ACMAMT_MC] 	= "0.000";
				ptb_InRec_Cur[CML_TOTAUX_MC] 	= "0.000";
				for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
				{
					ptb_InRec_Cur[j] = "0.000"; 
				}
				if( ACMTRS3 == 1051 && strcmp(ptb_InRec_Cur[CML_PATCAT_CT],"BDT") == 0 )
				{
					ptb_InRec_Cur[CML_PATCAT_CT] = "EXP";
					ptb_InRec_Cur[CML_PATTYP_CT] = "EGPBD";
					n_WriteCols(Kp_OutputFil_REVENUE,  ptb_InRec_Cur, '~', 0);
					ptb_InRec_Cur[CML_PATTYP_CT] = "EARBD";
					n_WriteCols(Kp_OutputFil_REVENUE,  ptb_InRec_Cur, '~', 0);
				}
				else
				{
					ptb_InRec_Cur[CML_PATCAT_CT] = "EXP";
					ptb_InRec_Cur[CML_PATTYP_CT] = "EGPPR";
					n_WriteCols(Kp_OutputFil_REVENUE,  ptb_InRec_Cur, '~', 0);
					ptb_InRec_Cur[CML_PATTYP_CT] = "EARPR";
					n_WriteCols(Kp_OutputFil_REVENUE,  ptb_InRec_Cur, '~', 0);
				}
				RETURN_VAL (0);
			}
			if( fabs( d_FUTURE_PREM_PREVQ + d_PREM_ESTM_PREVQ + d_REMAIN_ESTM_PREVQ ) > 1 )
			{
				d_Retro_Ratio = ( d_FUTURE_PREM_Q + d_PREM_ESTM + d_REMAIN_ESTM + d_ITD_PREM_ACT )/( d_FUTURE_PREM_PREVQ + d_PREM_ESTM_PREVQ + d_REMAIN_ESTM_PREVQ );
				sprintf(amount , "%.3f" , atof(ptb_InRec_Cur[CML_ACMAMT_MC])* d_Retro_Ratio );
				ptb_InRec_Cur[CML_ACMAMT_MC] = amount;				
				sprintf(total_mnt , "%.3f" , atof(ptb_InRec_Cur[CML_TOTAUX_MC]) * d_Retro_Ratio );
				ptb_InRec_Cur[CML_TOTAUX_MC] = total_mnt; 
				for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
				{
					sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(ptb_InRec_Cur[j]) * d_Retro_Ratio );
					ptb_InRec_Cur[j] = ank_mnt [j-CML_AN1];
				}
				if( ACMTRS3 == 1051 && strcmp(ptb_InRec_Cur[CML_PATCAT_CT],"BDT") == 0 )
				{
					ptb_InRec_Cur[CML_PATCAT_CT] = "EXP";
					ptb_InRec_Cur[CML_PATTYP_CT] = "EGPBD";
					n_WriteCols(Kp_OutputFil_REVENUE,  ptb_InRec_Cur, '~', 0);
					ptb_InRec_Cur[CML_PATTYP_CT] = "EARBD";
					n_WriteCols(Kp_OutputFil_REVENUE,  ptb_InRec_Cur, '~', 0);
				}
				else
				{
					ptb_InRec_Cur[CML_PATCAT_CT] = "EXP";
					ptb_InRec_Cur[CML_PATTYP_CT] = "EGPPR";
					n_WriteCols(Kp_OutputFil_REVENUE,  ptb_InRec_Cur, '~', 0);
					ptb_InRec_Cur[CML_PATTYP_CT] = "EARPR";
					n_WriteCols(Kp_OutputFil_REVENUE,  ptb_InRec_Cur, '~', 0);
				}
			}
			else
			{ 
				ptb_InRec_Cur[CML_COMMENT] 		= "Division by 0, ratio forced to 1";
				if( ACMTRS3 == 1051 && strcmp(ptb_InRec_Cur[CML_PATCAT_CT],"BDT") == 0 )
				{
					ptb_InRec_Cur[CML_PATCAT_CT] = "EXP";
					ptb_InRec_Cur[CML_PATTYP_CT] = "EGPBD";
					n_WriteCols(Kp_OutputFil_REVENUE,  ptb_InRec_Cur, '~', 0);
					ptb_InRec_Cur[CML_PATTYP_CT] = "EARBD";
					n_WriteCols(Kp_OutputFil_REVENUE,  ptb_InRec_Cur, '~', 0);
				}
				else
				{
					ptb_InRec_Cur[CML_PATCAT_CT] = "EXP";
					ptb_InRec_Cur[CML_PATTYP_CT] = "EGPPR";
					n_WriteCols(Kp_OutputFil_REVENUE,  ptb_InRec_Cur, '~', 0);
					ptb_InRec_Cur[CML_PATTYP_CT] = "EARPR";
					n_WriteCols(Kp_OutputFil_REVENUE,  ptb_InRec_Cur, '~', 0);
				}
			}
			RETURN_VAL (0);
		}
		
		d_Retro_Ratio 	= ( d_FUTURE_PREM_Q + d_ITD_PREM - d_UPR_PREVQ )/( d_FUTURE_PREM_PREVQ - d_UPR_PREVQ );
		d_Ratio 		= ( d_FUTURE_PREM_Q - d_UPR_Q )/( d_FUTURE_PREM_PREVQ - d_UPR_PREVQ );
		
		sprintf(amount , "%.3f" , atof(ptb_InRec_Cur[CML_ACMAMT_MC]) * d_Retro_Ratio );
		ptb_InRec_Cur[CML_ACMAMT_MC] = amount; 
		sprintf(total_mnt , "%.3f" , atof(ptb_InRec_Cur[CML_TOTAUX_MC]) * d_Retro_Ratio );
		ptb_InRec_Cur[CML_TOTAUX_MC] = total_mnt; 
		for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
		{
			sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(ptb_InRec_Cur[j]) * d_Retro_Ratio );
			ptb_InRec_Cur[j] = ank_mnt [j-CML_AN1]; 
		}
		/******************************************************************************** 
		*******							BDT~LKI TREATMENT 						*********
		*********************************************************************************/
		if( strcmp(ptb_InRec_Cur[CML_PATCAT_CT],"BDT") == 0 )
		{
			ptb_InRec_Cur[CML_PATCAT_CT] = "EXP";
			ptb_InRec_Cur[CML_PATTYP_CT] = "EGPBD";
			n_WriteCols(Kp_OutputFil_REVENUE,  ptb_InRec_Cur, '~', 0);
			
			sprintf(amount , "%.3f" , atof(origine_Cur[CML_ACMAMT_MC]) * d_Ratio );
			ptb_InRec_Cur[CML_ACMAMT_MC] = amount; 
			
			sprintf(total_mnt , "%.3f" , atof(origine_Cur[CML_TOTAUX_MC]) * d_Ratio );
			ptb_InRec_Cur[CML_TOTAUX_MC] = total_mnt; 
			
			for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
			{
				sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(origine_Cur[j]) * d_Ratio );
				ptb_InRec_Cur[j] = ank_mnt [j-CML_AN1]; 
			}
			ptb_InRec_Cur[CML_PATTYP_CT] = "EARBD";
			n_WriteCols(Kp_OutputFil_REVENUE,  ptb_InRec_Cur, '~', 0);

			RETURN_VAL (0);
		}
		/******************************************************************************** 
		*******							DSC~LKI TREATMENT						*********
		*********************************************************************************/
		if( strcmp(ptb_InRec_Cur[CML_PATCAT_CT],"DSC") == 0 && ( ACMTRS3 == 2211 || ACMTRS3 == 3201 || ACMTRS3 == 2032 || ACMTRS3 == 3202 ))
		{
			ptb_InRec_Cur[CML_PATCAT_CT] = "EXP";
			ptb_InRec_Cur[CML_PATTYP_CT] = "EGPCL";
			n_WriteCols(Kp_OutputFil_REVENUE,  ptb_InRec_Cur, '~', 0);
			
			sprintf(amount , "%.3f" , atof(origine_Cur[CML_ACMAMT_MC]) * d_Ratio );
			ptb_InRec_Cur[CML_ACMAMT_MC] = amount; 
			sprintf(total_mnt , "%.3f" , atof(origine_Cur[CML_TOTAUX_MC]) * d_Ratio );
			ptb_InRec_Cur[CML_TOTAUX_MC] = total_mnt; 
			for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
			{
				sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(origine_Cur[j]) * d_Ratio );
				ptb_InRec_Cur[j] = ank_mnt [j-CML_AN1]; 
			}
			ptb_InRec_Cur[CML_PATTYP_CT] = "EARCL";
			n_WriteCols(Kp_OutputFil_REVENUE,  ptb_InRec_Cur, '~', 0);
			
			RETURN_VAL (0);
		}
		if( strcmp(ptb_InRec_Cur[CML_PATCAT_CT],"DSC") == 0 && ( ACMTRS3 == 2053 || ACMTRS3 == 2090 || ACMTRS3 == 2031 || ACMTRS3 == 2035 ))
		{
			ptb_InRec_Cur[CML_PATCAT_CT] = "EXP";
			ptb_InRec_Cur[CML_PATTYP_CT] = "EGPAE";
			n_WriteCols(Kp_OutputFil_REVENUE,  ptb_InRec_Cur, '~', 0);
			
			sprintf(amount , "%.3f" , atof(origine_Cur[CML_ACMAMT_MC]) * d_Ratio );
			ptb_InRec_Cur[CML_ACMAMT_MC] = amount;						
			sprintf(total_mnt , "%.3f" , atof(origine_Cur[CML_TOTAUX_MC]) * d_Ratio );
			ptb_InRec_Cur[CML_TOTAUX_MC] = total_mnt; 
			for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
			{
				sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(origine_Cur[j]) * d_Ratio );
				ptb_InRec_Cur[j] = ank_mnt [j-CML_AN1]; 
			}
			ptb_InRec_Cur[CML_PATTYP_CT] = "EARAE";
			n_WriteCols(Kp_OutputFil_REVENUE,  ptb_InRec_Cur, '~', 0);
		
			RETURN_VAL (0);			
		}
		/******************************************************************************** 
		*******								RAD~LKI TREATMENT					*********
		*********************************************************************************/
		if( strcmp(ptb_InRec_Cur[CML_PATCAT_CT],"RAD") == 0 )
		{
			ptb_InRec_Cur[CML_PATCAT_CT] = "EXP";
			ptb_InRec_Cur[CML_PATTYP_CT] = "EGPRA"; 
			n_WriteCols(Kp_OutputFil_REVENUE,  ptb_InRec_Cur, '~', 0);
			
			sprintf(amount , "%.3f" , atof(origine_Cur[CML_ACMAMT_MC]) * d_Ratio );
			ptb_InRec_Cur[CML_ACMAMT_MC] = amount; 
			sprintf(total_mnt , "%.3f" , atof(origine_Cur[CML_TOTAUX_MC]) * d_Ratio );
			ptb_InRec_Cur[CML_TOTAUX_MC] = total_mnt; 
			for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
			{
				sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(origine_Cur[j]) * d_Ratio );
				ptb_InRec_Cur[j] = ank_mnt [j-CML_AN1]; 
			}
			ptb_InRec_Cur[CML_PATTYP_CT] = "EARRA";
			n_WriteCols(Kp_OutputFil_REVENUE,  ptb_InRec_Cur, '~', 0);
		
			RETURN_VAL (0);				
		}
	}		

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
	n_OpenFileAppl ("ESFC3696_I2", "rt", &(pbd_Sync->pf_InputFil));

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
retour 	:	0		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==============================================================================*/
int n_ActionLigne_CASHFLOW_Q( char **pbd_InRecOwner ,char **pbd_InRecChild )
{
	DEBUT_FCT("n_ActionLigne_CASHFLOW_Q");
	double 	d_taux = 1;
	char 	MsgAno[150];
	
	if ( strcmp( pbd_InRecOwner[GT_EGPICUR_CF], pbd_InRecChild[CML_ACMCUR_CF] ) != 0 )
	{	
		d_taux = d_GetTaux( Kp_InputFilExc, 
							(char) atoi( pbd_InRecChild[CML_SSD_CF] ), 
							atoi( pbd_InRecChild[CML_BALSHEY_NF] ), 
							pbd_InRecChild[CML_ACMCUR_CF], 
							pbd_InRecOwner[GT_EGPICUR_CF] 
							);
		if ( d_taux < 0 )
		{
			sprintf( MsgAno, "No rate for RETRO :( CTR %s - END %s - SEC %s - UWY %s - UW %s )\n", 
			pbd_InRecChild[CML_RETCTR_NF],  
			pbd_InRecChild[CML_RETEND_NT], 
			pbd_InRecChild[CML_RETSEC_NF], 
			pbd_InRecChild[CML_RTY_NF], 
			pbd_InRecChild[CML_RETUW_NT] );
			
			n_WriteAno( MsgAno );
			d_taux 	= 1;	
		}
	}
	if( strcmp( pbd_InRecChild[CML_ACMTRS3_NT2], "1051" ) == 0 )
		d_FUTURE_PREM_Q += atof(pbd_InRecChild[CML_ACMAMT_MC]) * d_taux;
	else if( strcmp( pbd_InRecChild[CML_ACMTRS3_NT2], "2051" ) == 0 )
		d_FUT_FIXED_CHARGE += atof(pbd_InRecChild[CML_ACMAMT_MC]) * d_taux;
	else if( strcmp( pbd_InRecChild[CML_ACMTRS3_NT2], "2054" ) == 0 )
		d_FUTURE_OVERRIDE_COM += atof(pbd_InRecChild[CML_ACMAMT_MC]) * d_taux;
	else if( strcmp( pbd_InRecChild[CML_ACMTRS3_NT2], "1010" ) == 0 )
		d_PREM_ESTM += atof(pbd_InRecChild[CML_ACMAMT_MC]) * d_taux;
	else
		d_REMAIN_ESTM += atof(pbd_InRecChild[CML_ACMAMT_MC]) * d_taux;
		
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
	
	n_OpenFileAppl ("ESFC3696_I3", "rt", &(pbd_Sync->pf_InputFil));

	pbd_Sync->ConditionEndSync  	= n_CondSync_CASHFLOW_PREVQ ;        
	pbd_Sync->n_ActionLigne     	= n_ActionLigne_CASHFLOW_PREVQ ;           
	pbd_Sync->c_Separ      			= '~' ;
	
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
objet 	: Fonction lance a chaque ligne synchro entre CASHFLOW Q-1 et DSC_RAD_LKI
retour 	:	0		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==============================================================================*/
int n_ActionLigne_CASHFLOW_PREVQ( char **pbd_InRecOwner ,char **pbd_InRecChild )
{
	DEBUT_FCT("n_ActionLigne_CASHFLOW_PREVQ");
	double 	d_taux = 1;
	char 	MsgAno[150];
			
	if ( strcmp( pbd_InRecOwner[GT_EGPICUR_CF], pbd_InRecChild[CML_ACMCUR_CF] ) != 0 )
	{	
		d_taux = d_GetTaux( Kp_InputFilExc, 
							(char) atoi( pbd_InRecChild[CML_SSD_CF] ), 
							atoi( pbd_InRecChild[CML_BALSHEY_NF] ), 
							pbd_InRecChild[CML_ACMCUR_CF], 
							pbd_InRecOwner[GT_EGPICUR_CF] 
							);
		if ( d_taux < 0 )
		{
			sprintf( MsgAno, "No rate for RETRO :( CTR %s - END %s - SEC %s - UWY %s - UW %s )\n", 
			pbd_InRecChild[CML_RETCTR_NF],  
			pbd_InRecChild[CML_RETEND_NT], 
			pbd_InRecChild[CML_RETSEC_NF], 
			pbd_InRecChild[CML_RTY_NF], 
			pbd_InRecChild[CML_RETUW_NT] );
			
			n_WriteAno( MsgAno );
			d_taux 	= 1;	
		}
	}		
	if( strcmp( pbd_InRecChild[CML_ACMTRS3_NT2], "1051" ) == 0 )
		d_FUTURE_PREM_PREVQ += atof(pbd_InRecChild[CML_ACMAMT_MC]);
	else if( strcmp( pbd_InRecChild[CML_ACMTRS3_NT2], "1010" ) == 0 )
		d_PREM_ESTM_PREVQ += atof(pbd_InRecChild[CML_ACMAMT_MC]);
	else
		d_REMAIN_ESTM_PREVQ += atof(pbd_InRecChild[CML_ACMAMT_MC]);
	
	RETURN_VAL (0);
}

/**===============================================================================
objet 	: Fonction initialisation synchro entre CASHFLOW INI et PERIMETRE file
retour 	:	0	---> traitement correctement effectue
==================================================================================*/
int n_Init_CASHFLOW_INI(T_RUPTURE_SYNC_VAR  *pbd_Sync)
{
	DEBUT_FCT("n_Init_CASHFLOW_INI");

	memset( pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;
	
	n_OpenFileAppl ("ESFC3696_I8", "rt", &(pbd_Sync->pf_InputFil));

	pbd_Sync->ConditionEndSync  	= n_CondSync_CASHFLOW_INI ;        
	pbd_Sync->n_ActionLigne     	= n_ActionLigne_CASHFLOW_INI ;           
	pbd_Sync->c_Separ      			= '~' ;
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction de test de synchro entre CASHFLOW INI et PERIMETRE file
retour 	:	0  		---> synchro
			1  		---> non trouve
==============================================================================*/
int n_CondSync_CASHFLOW_INI( char **pbd_InRecOwner , char **pbd_InRecChild )
{
	DEBUT_FCT("n_CondSync_CASHFLOW_INI");
	int ret;
	
	if ( ( ret = strcmp( pbd_InRecOwner[CML_CTR_NF], pbd_InRecChild[CML_CTR_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_END_NT] ) - atoi( pbd_InRecChild[CML_END_NT] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_SEC_NF] ) - atoi( pbd_InRecChild[CML_SEC_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_UWY_NF], pbd_InRecChild[CML_UWY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_UW_NT] ) - atoi( pbd_InRecChild[CML_UW_NT] ) ) != 0 ) 	return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_RETCTR_NF], pbd_InRecChild[CML_RETCTR_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_RETEND_NT]) - atoi(pbd_InRecChild[CML_RETEND_NT])) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[CML_RETSEC_NF]) - atoi( pbd_InRecChild[CML_RETSEC_NF])) != 0)	return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_RTY_NF], pbd_InRecChild[CML_RTY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_RETUW_NT]) - atoi( pbd_InRecChild[CML_RETUW_NT] )) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[CML_PLC_NT]) - atoi( pbd_InRecChild[CML_PLC_NT] )) != 0 ) 	return ret ;
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction lance a chaque ligne synchro entre CSF INI et PERIMETRE 
retour 	:	0		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==============================================================================*/
int n_ActionLigne_CASHFLOW_INI( char **pbd_InRecOwner ,char **pbd_InRecChild )
{
	DEBUT_FCT("n_ActionLigne_CASHFLOW_INI");
	
	double 	d_taux = 1;
	char 	MsgAno[150];
	
	if ( strcmp( pbd_InRecOwner[GT_EGPICUR_CF], pbd_InRecChild[CML_ACMCUR_CF] ) != 0 )
	{	
		d_taux = d_GetTaux( Kp_InputFilExc, 
							(char) atoi( pbd_InRecChild[CML_SSD_CF] ), 
							atoi( pbd_InRecChild[CML_BALSHEY_NF] ), 
							pbd_InRecChild[CML_ACMCUR_CF], 
							pbd_InRecOwner[GT_EGPICUR_CF] 
							);
		if ( d_taux < 0 )
		{
			sprintf( MsgAno, "No rate for RETRO :( CTR %s - END %s - SEC %s - UWY %s - UW %s )\n", 
			pbd_InRecChild[CML_RETCTR_NF],  
			pbd_InRecChild[CML_RETEND_NT], 
			pbd_InRecChild[CML_RETSEC_NF], 
			pbd_InRecChild[CML_RTY_NF], 
			pbd_InRecChild[CML_RETUW_NT] );
			
			n_WriteAno( MsgAno );
			d_taux 	= 1;	
		}
	}		
	d_FUTURE_PREM_INI += atof(pbd_InRecChild[CML_ACMAMT_MC]) * d_taux;
	
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
	n_OpenFileAppl ("ESFC3696_I4", "rt", &(pbd_Sync->pf_InputFil));

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
	
	if ( ( ret = strcmp( pbd_InRecOwner[CML_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) 	!= 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_END_NT] ) - atoi( pbd_InRecChild[CML_END_NT] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_SEC_NF] ) - atoi( pbd_InRecChild[CML_SEC_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) 	!= 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_UW_NT] ) - atoi( pbd_InRecChild[CML_UW_NT] ) ) != 0 ) 	return ret;
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
	char 	MsgAno[150];
	
	if ( strcmp( pbd_InRecOwner[GT_EGPICUR_CF], pbd_InRecChild[GTSII_ACMCUR_CF] ) != 0 )
	{	
		d_taux = d_GetTaux( Kp_InputFilExc, 
							(char) atoi( pbd_InRecChild[GT_SSD_CF] ), 
							atoi( pbd_InRecChild[GT_BALSHEY_NF] ), 
							pbd_InRecChild[GTSII_ACMCUR_CF], 
							pbd_InRecOwner[GT_EGPICUR_CF] 
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
	if( strcmp( pbd_InRecChild[TRN_CODE], "1010" ) == 0 )	
		d_ITD_PREM += atof(pbd_InRecChild[GTSII_ACMAMT_MC]) * d_taux;
	if( strcmp(pbd_InRecChild[TRN_CODE], "1010" ) == 0 && 
		( strcmp( pbd_InRecChild[LINETYP_NF],"AC") == 0 || strcmp(pbd_InRecChild[LINETYP_NF],"AA") == 0 ))
		d_ITD_PREM_ACT += atof(pbd_InRecChild[GTSII_ACMAMT_MC]) * d_taux;
	if(( strcmp(pbd_InRecChild[TRN_CODE], "2010") == 0  || strcmp(pbd_InRecChild[TRN_CODE], "2013") == 0 || 
		strcmp(pbd_InRecChild[TRN_CODE], "2019") == 0 ) && 
		( strcmp(pbd_InRecChild[LINETYP_NF],"AC") == 0 || strcmp(pbd_InRecChild[LINETYP_NF],"AA") == 0 ))
		d_FIXED_CHARGE_ACT += atof(pbd_InRecChild[GTSII_ACMAMT_MC]) * d_taux;
	
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
	n_OpenFileAppl ("ESFC3696_I5", "rt", &(pbd_Sync->pf_InputFil));

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
	
	if ( ( ret = strcmp( pbd_InRecOwner[CML_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) 	!= 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_END_NT] ) - atoi( pbd_InRecChild[CML_END_NT] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_SEC_NF] ) - atoi( pbd_InRecChild[CML_SEC_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) 	!= 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_UW_NT] ) - atoi( pbd_InRecChild[CML_UW_NT] ) ) != 0 ) 	return ret;
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
	double 	d_taux = 1;
	char 	MsgAno[150];
	
	if ( strcmp( pbd_InRecOwner[GT_EGPICUR_CF], pbd_InRecChild[GTSII_ACMCUR_CF] ) != 0 )
	{	
		d_taux = d_GetTaux( Kp_InputFilExc, 
							(char) atoi( pbd_InRecChild[GT_SSD_CF] ), 
							atoi( pbd_InRecChild[GT_BALSHEY_NF] ),
							pbd_InRecChild[GTSII_ACMCUR_CF], 
							pbd_InRecOwner[GT_EGPICUR_CF] 
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
	if( strcmp( pbd_InRecChild[TRN_CODE], "1030" ) == 0 )
		d_UPR_Q += atof(pbd_InRecChild[GTSII_ACMAMT_MC]) * d_taux;
	
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
	n_OpenFileAppl ("ESFC3696_I6", "rt", &(pbd_Sync->pf_InputFil));

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
	
	if ( ( ret = strcmp( pbd_InRecOwner[CML_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) 	!= 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_END_NT] ) - atoi( pbd_InRecChild[CML_END_NT] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_SEC_NF] ) - atoi( pbd_InRecChild[CML_SEC_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) 	!= 0 ) 			return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_UW_NT] ) - atoi( pbd_InRecChild[CML_UW_NT] ) ) != 0 ) 	return ret;
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
	DEBUT_FCT("n_ActionLigne_UPR_PREVQ");
	double 	d_taux = 1;
	char 	MsgAno[150];
	
	if ( strcmp( pbd_InRecOwner[GT_EGPICUR_CF], pbd_InRecChild[GTSII_ACMCUR_CF] ) != 0 )
	{	
		d_taux = d_GetTaux( Kp_InputFilExc, 
							(char) atoi( pbd_InRecChild[GT_SSD_CF] ), 
							atoi( pbd_InRecChild[GT_BALSHEY_NF] ), 
							pbd_InRecChild[GTSII_ACMCUR_CF], 
							pbd_InRecOwner[GT_EGPICUR_CF] );
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
	d_UPR_PREVQ += atof(pbd_InRecChild[GTSII_ACMAMT_MC]) * d_taux;
	
	RETURN_VAL (0);
}