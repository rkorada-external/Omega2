/**===============================================================================================
APPLICATION NAME          		: IFRS17 REVENUE CALCULATION RETRO P
PROGRAM NAME                 	: ESFC3692B.c
REVISION                      	: V1
CREATION DATE              		: 10/2020
AUTHOR                        	: L.ELFAHIM
---------------------------------------------------------------------------------------------------
DESCRIPTION :
	THIS PROGRAM AIMS TO HANDLE IFRS17 REVENUE CALCULATION FOR RETRO P PROPORTIONAL CONTRACTS
---------------------------------------------------------------------------------------------------
CHANGE HISTORY :

22/10/2019    	LEL    	70741  	INITIAL VERSION DEVELOPMENT
06/01/2020    	LEL  	82711   CR : REVENUE - INCLUDE DAC
22/01/2020    	LEL   	82837  	ADJUST REVENUE CALCULATION IN THE CASE OPENING FP=0 AND CHANGE IN EGPI<>0
17/03/2020    	LEL  	82711   CALCULATION DAC VARIABLES
11/06/2020    	LEL   	70741	DEACTIVATE CALCULATION DAC VARIABLES
23/07/2020    	LEL  	82711	REACTIVATE CALCULATION DAC VARIABLES
24/07/2020    	LEL  	79621	IMPLEMENTATION OF SPIRA
24/07/2020    	LEL   	88368	IMPLEMENTATION OF SPIRA
24/07/2020    	LEL   	88235	IMPLEMENTATION OF SPIRA
15/09/2020    	LEL  	89817	SPLIT MERGE CLAIM et RA ( 3201 && 3202 )
06/10/2020    	LEL    	87722	SPLIT ESFC3692 PROGRAM to ( ESFC3692B : RETRO NP && ESFC3692B : RETRO P )
10/12/2020    	LEL   	90446	IMPLEMENTATION OF FIRST CLOSING CONDITIONS OF CSUOE
24/12/2020    	LEL  	91111	EXTEND TO INCURRED RECEIVABLES/PREMIUM ESTIMATES
28/12/2020    	LEL  	92221	BDT ONLY FUTURE POSITIONS SHOULD BE CONSIDERED
29/12/2020    	LEL  	91113	ADD AN ADDITIONAL CONDITION TO LAUNCH REVENUE
25/01/2021   	LEL  	93211	MANAGE RETRO GRANULARITY
09/02/2021    	LEL   	92797	IFRS 17 - UPR AT FIRST CLOSING FOR GROSS UP
22/04/2021    	LEL    	95798	DESACTIVATE UPR OPENING
14/05/2021    	LEL    	95212	DELETE CASE INCEPTION STATUS EMPTY
18/06/2021    	LEL 	97096	OVERRIDING DATA FROM PREVIOUS PERIOD WHEN FIRST CLOSING
01/09/2021 		LEL 	97373	ACF/PCA: IMPACT REVENUE CALCULATION
02/02/2022      HR      100977  I17 - Criteria to compute Revenue / EXP / CSM
[001] 30/05/2022      DAD     104374  I17 revenue- Undue DSC calculation 
09/01/2023      HR      108366  REQ 11.06 - Adjust expected recievables EGPI position for rule R03-01 
23/01/2023 HR 108549 REQ 11.06 - Rule R03-01 not applied when DSC/FWD grp 1010 or 1051 does not exist
07/09/2023      DAD     110421  Include BDT/1010 in retro revenue calculation
==================================================================================================*/

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
	
	/***************************************************************************/
	/**  Ouverture Des fichiers en entree et Initialisation des structures     */
	/***************************************************************************/
	
	if ( n_OpenFileAppl ( "ESFC3692B_O1","wt",&Kp_OutputFil_REVENUE ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	/** Initialisation de la variable Kbd_Rup_LockedInRate */
	if ( n_Init_LockedInRate(&Kbd_Rup_LockedInRate) ) 
		ExitPgm ( ERR_XX , "" );
	
	/** Initialisation de la variable Kbd_Rupt_FORWARD */
	if ( n_Init_FORWARD(&Kbd_Rupt_FORWARD) ) 
		ExitPgm ( ERR_XX , "" );
	
	/** Lancement du traitement du fichier maitre */
	if (n_ProcessingRuptureVar(&Kbd_Rup_LockedInRate) == ERR) 
		ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
	
	/***************************************************************************/
	/**   Fermeture Des fichiers ouverts                                       */
	/***************************************************************************/
	if ( n_CloseFileAppl( "ESFC3692B_I1", &( Kbd_Rup_LockedInRate.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3692B_I2", &( Kbd_Rupt_FORWARD.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3692B_O1", &Kp_OutputFil_REVENUE ) == ERR ) 
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

	if ( n_OpenFileAppl ("ESFC3692B_I1", "rt", &(pbd_Rupt->pf_InputFil)))
		RETURN_VAL (ERR);
	
	pbd_Rupt->n_ActionLigne 		= n_ActionLigne_LockedInRate ;
	pbd_Rupt->c_Separ 				= '~' ;

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
	
	/** Lancement synchronisation avec le fichier FORWARD */
	n_ProcessingRuptureSyncVar( &Kbd_Rupt_FORWARD, ptb_InRec_Cur );
	
	RETURN_VAL(0) ;
}


/**===============================================================================
objet 	: Fonction initialisation synchro entre FORWARD et DSC_RAD_LKI
retour 	:	0	---> traitement correctement effectue
==================================================================================*/
int n_Init_FORWARD(T_RUPTURE_SYNC_VAR  *pbd_Sync)
{
	DEBUT_FCT("n_Init_FORWARD");

	memset( pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;
	n_OpenFileAppl ("ESFC3692B_I2", "rt", &(pbd_Sync->pf_InputFil));

	pbd_Sync->ConditionEndSync  	= n_CondSync_FORWARD ;        
	pbd_Sync->n_ActionLigne     	= n_ActionLigne_FORWARD ;
	pbd_Sync->n_PereSansFils     	= n_PereSansFils_FORWARD ; 
	pbd_Sync->n_FilsSansPere 		= n_FilsSansPere_FORWARD;	
	pbd_Sync->c_Separ      			= '~' ;
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction de test de synchro entre FORWARD et DSC_RAD_LKI
retour 	:	0  	---> synchro
			1  	---> non trouve
==============================================================================*/
int n_CondSync_FORWARD( char **pbd_InRecOwner , char **pbd_InRecChild )
{
	DEBUT_FCT("n_CondSync_FORWARD");
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
	if ( ( ret = strcmp( pbd_InRecOwner[CML_RETCUR_CF],pbd_InRecChild[CML_RETCUR_CF] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( pbd_InRecOwner[CML_PLC_NT]) - atoi( pbd_InRecChild[CML_PLC_NT] )) != 0 ) 	return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_NAT_CF], pbd_InRecChild[CML_NAT_CF] ) ) != 0 ) 			return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_TYP_CT], pbd_InRecChild[CML_TYP_CT] ) ) != 0 ) 			return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_PATCAT_CT],pbd_InRecChild[CML_PATCAT_CT] ) ) != 0 ) 	return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_ACMTRS3],pbd_InRecChild[CML_ACMTRS3] ) ) != 0 ) 		return ret;
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction lance a chaque ligne synchro entre FORWARD et DSC_RAD_LKI
retour 	:	0		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==============================================================================*/
int n_ActionLigne_FORWARD( char **pbd_InRecOwner ,char **pbd_InRecChild )
{
	DEBUT_FCT("n_ActionLigne_FORWARD");
	
	int 	ACMTRS3, j;
	char 	amount[AMN_LEN], ank_mnt[65][AMN_LEN], total_mnt[AMN_LEN];
	char 	amount2[AMN_LEN],amount3[AMN_LEN];
	CSM_RAT = 1;
        	
        //100977
        CSM_RAT_PREV = 0;
        LC_RAT_PREV = 0;

        if( strcmp(pbd_InRecOwner[CSM_PREVQ],"") != 0 )	{
         CSM_RAT_PREV = atof(pbd_InRecOwner[CSM_PREVQ]);
        }

        if( strcmp(pbd_InRecOwner[LC_PREVQ],"") != 0 )   {
         LC_RAT_PREV = atof(pbd_InRecOwner[LC_PREVQ]);
        }

	memset(amount,0, sizeof(amount));
	memset(amount2,0, sizeof(amount2));
	memset(amount3,0, sizeof(amount3));
	memset(total_mnt,0, sizeof(total_mnt));
	ACMTRS3 = atoi(pbd_InRecOwner[CML_ACMTRS3]);
	
	d_UPR_PREVQ			= atof(pbd_InRecOwner[UPR_PREVQ]);
	d_ITD_PREM_ACT		= atof(pbd_InRecOwner[ITD_PREM_ACT]);
	d_FIXED_CHARGE_ACT	= atof(pbd_InRecOwner[FIXED_CHARGE_ACT]);
	d_PREM_ESTM_PREVQ	= atof(pbd_InRecOwner[PREM_ESTM_PREVQ]);
	d_FUTURE_PREM_PREVQ = atof(pbd_InRecOwner[FUTURE_PREM_PREVQ]);
	d_REMAIN_ESTM_PREVQ	= atof(pbd_InRecOwner[REMAIN_ESTM_PREVQ]);
	
	//100977 if( fabs(d_FUTURE_PREM_PREVQ - d_UPR_PREVQ) > 1 )
	if ( CSM_RAT_PREV != 1 || LC_RAT_PREV != 1 )
	{	
		if( ACMTRS3 == 1051 || ACMTRS3 == 1010 )
		{	
			if( fabs(d_FUTURE_PREM_PREVQ + d_PREM_ESTM_PREVQ + d_REMAIN_ESTM_PREVQ) < 1 && fabs( d_UPR_PREVQ ) > 0 )
			{
				// 110421
				if( (ACMTRS3 == 1051 || ACMTRS3 == 1010) && strcmp(pbd_InRecOwner[CML_PATCAT_CT],"BDT") == 0 )
				{
					sprintf(amount , "%.3f" , atof(pbd_InRecOwner[CML_ACMAMT_MC]));
					pbd_InRecOwner[CML_ACMAMT_MC] = amount; 
					sprintf(amount2 , "%.3f" , atof(pbd_InRecOwner[CML_AN1]));
					pbd_InRecOwner[CML_AN1] = amount2;
					sprintf(amount3 , "%.3f" , atof(pbd_InRecOwner[CML_TOTAUX_MC]));
					pbd_InRecOwner[CML_TOTAUX_MC] = amount3; 
					//108366
					for( j = CML_AN2; j<= CML_AM_FIN; ++j )   
					{
						sprintf(ank_mnt [j-CML_AN2] , "%.3f" , atof(pbd_InRecOwner[j]) );
						pbd_InRecOwner[j] = ank_mnt [j-CML_AN2];

					//	pbd_InRecOwner[j] = "0.000"; 
					}
					pbd_InRecOwner[CML_PATCAT_CT] = "EXP";
					pbd_InRecOwner[CML_PATTYP_CT] = "EGPBD";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
					pbd_InRecOwner[CML_PATTYP_CT] = "EARBD";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
				}
				else if( ACMTRS3 == 1051 && strcmp(pbd_InRecOwner[CML_PATCAT_CT],"DSC") == 0 )
				{
					sprintf(amount , "%.3f" , atof(pbd_InRecOwner[CML_ACMAMT_MC]));
					pbd_InRecOwner[CML_ACMAMT_MC] = amount; 
					sprintf(amount2 , "%.3f" , atof(pbd_InRecOwner[CML_AN1]));
					pbd_InRecOwner[CML_AN1] = amount2;
					sprintf(amount3 , "%.3f" , atof(pbd_InRecOwner[CML_TOTAUX_MC]));
					pbd_InRecOwner[CML_TOTAUX_MC] = amount3; 
					//108366
					for( j = CML_AN2; j<= CML_AM_FIN; ++j )   
					{
						sprintf(ank_mnt [j-CML_AN2] , "%.3f" , atof(pbd_InRecOwner[j]) );
						pbd_InRecOwner[j] = ank_mnt [j-CML_AN2];

					//	pbd_InRecOwner[j] = "0.000"; 
					}
					pbd_InRecOwner[CML_PATCAT_CT] = "EXP";
					pbd_InRecOwner[CML_PATTYP_CT] = "EGPPR";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
					pbd_InRecOwner[CML_PATTYP_CT] = "EARPR";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
				}
				else
				{
					sprintf(amount , "%.3f" , atof(pbd_InRecOwner[CML_ACMAMT_MC]) + d_ITD_PREM_ACT + d_FIXED_CHARGE_ACT);
					pbd_InRecOwner[CML_ACMAMT_MC] = amount; 
					sprintf(amount2 , "%.3f" , atof(pbd_InRecOwner[CML_AN1]) + d_ITD_PREM_ACT + d_FIXED_CHARGE_ACT);
					pbd_InRecOwner[CML_AN1] = amount2;
					sprintf(amount3 , "%.3f" , atof(pbd_InRecOwner[CML_TOTAUX_MC]) + d_ITD_PREM_ACT + d_FIXED_CHARGE_ACT);
					pbd_InRecOwner[CML_TOTAUX_MC] = amount3; 
					//108366
					for( j = CML_AN2; j<= CML_AM_FIN; ++j )   
					{
						sprintf(ank_mnt [j-CML_AN2] , "%.3f" , atof(pbd_InRecOwner[j]) );
						pbd_InRecOwner[j] = ank_mnt [j-CML_AN2];

					//	pbd_InRecOwner[j] = "0.000"; 
					}
					pbd_InRecOwner[CML_PATCAT_CT] = "EXP";
					pbd_InRecOwner[CML_PATTYP_CT] = "EGPPR";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
					pbd_InRecOwner[CML_PATTYP_CT] = "EARPR";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
				}
			}
			else
			{
				if( strcmp(pbd_InRecOwner[EGPI_R1],"") != 0 )
				{
					sprintf(amount , "%.3f" , atof(pbd_InRecChild[CML_ACMAMT_MC]) * atof(pbd_InRecOwner[EGPI_R1]));
					pbd_InRecOwner[CML_ACMAMT_MC] = amount;				
					sprintf(total_mnt , "%.3f" , atof(pbd_InRecChild[CML_TOTAUX_MC]) * atof(pbd_InRecOwner[EGPI_R1]));
					pbd_InRecOwner[CML_TOTAUX_MC] = total_mnt; 
					for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
					{
						sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(pbd_InRecChild[j]) * atof(pbd_InRecOwner[EGPI_R1]));
						pbd_InRecOwner[j] = ank_mnt [j-CML_AN1];
					}
					// 110421
					if( (ACMTRS3 == 1051 || ACMTRS3 == 1010) && strcmp(pbd_InRecOwner[CML_PATCAT_CT],"BDT") == 0 )
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
				}
			}
		}
		else if ( ACMTRS3 == 2090 && strcmp(pbd_InRecChild[EGPI_R1],"") != 0)
		{
			sprintf(amount , "%.3f" , atof(pbd_InRecChild[CML_ACMAMT_MC]) * atof(pbd_InRecChild[EGPI_R1]));
			pbd_InRecOwner[CML_ACMAMT_MC] = amount;				
			sprintf(total_mnt , "%.3f" , atof(pbd_InRecChild[CML_TOTAUX_MC]) * atof(pbd_InRecChild[EGPI_R1]));
			pbd_InRecOwner[CML_TOTAUX_MC] = total_mnt; 
			for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
			{
				sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(pbd_InRecChild[j]) * atof(pbd_InRecChild[EGPI_R1]));
				pbd_InRecOwner[j] = ank_mnt [j-CML_AN1];
			}
			pbd_InRecOwner[CML_PATCAT_CT] = "EXP";
			pbd_InRecOwner[CML_PATTYP_CT] = "EGPAE";
			n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
			
			if( strcmp(pbd_InRecOwner[CSM_PREVQ],"") != 0 )
			{
				CSM_RAT = 1 - ((1 - atof(pbd_InRecOwner[CSM_Q]))/(1 - atof(pbd_InRecOwner[CSM_PREVQ])));
				if( strcmp(pbd_InRecOwner[CSM_PREVQ], "1") == 0 )
				{
					pbd_InRecOwner[CML_COMMENT] = "Division by 0, ratio forced to 1";
					CSM_RAT = 1;
				}
				sprintf(amount , "%.3f" , atof(pbd_InRecOwner[CML_ACMAMT_MC]) * CSM_RAT );
				pbd_InRecOwner[CML_ACMAMT_MC] = amount;				
				sprintf(total_mnt , "%.3f" , atof(pbd_InRecOwner[CML_TOTAUX_MC]) * CSM_RAT );
				pbd_InRecOwner[CML_TOTAUX_MC] = total_mnt; 
				for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
				{
					sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(pbd_InRecOwner[j]) * CSM_RAT );
					pbd_InRecOwner[j] = ank_mnt [j-CML_AN1];
				}
				pbd_InRecOwner[CML_PATTYP_CT] = "EARAE";
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);	
			}	
		}
		else
		{	
			if( strcmp(pbd_InRecOwner[EGPI_R2],"") != 0 && strcmp(pbd_InRecOwner[EARP_R1],"") != 0 )
			{
				sprintf(amount , "%.3f" , atof(pbd_InRecChild[CML_ACMAMT_MC]) * atof(pbd_InRecOwner[EGPI_R2]));
				pbd_InRecOwner[CML_ACMAMT_MC] = amount; 
				sprintf(total_mnt , "%.3f" , atof(pbd_InRecChild[CML_TOTAUX_MC]) * atof(pbd_InRecOwner[EGPI_R2]));
				pbd_InRecOwner[CML_TOTAUX_MC] = total_mnt; 
				for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
				{
					sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(pbd_InRecChild[j]) * atof(pbd_InRecOwner[EGPI_R2]));
					pbd_InRecOwner[j] = ank_mnt [j-CML_AN1]; 
				}
				/******************************************************************************** 
				*******							BDT~LKI TREATMENT 						*********
				*********************************************************************************/
				if( strcmp(pbd_InRecOwner[CML_PATCAT_CT],"BDT") == 0 )
				{
					pbd_InRecOwner[CML_PATCAT_CT] = "EXP";
					pbd_InRecOwner[CML_PATTYP_CT] = "EGPBD";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
					
					sprintf(amount , "%.3f" , atof(pbd_InRecChild[CML_ACMAMT_MC]) * atof(pbd_InRecOwner[EARP_R1]));
					pbd_InRecOwner[CML_ACMAMT_MC] = amount; 
					
					sprintf(total_mnt , "%.3f" , atof(pbd_InRecChild[CML_TOTAUX_MC]) * atof(pbd_InRecOwner[EARP_R1]));
					pbd_InRecOwner[CML_TOTAUX_MC] = total_mnt; 
					
					for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
					{
						sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(pbd_InRecChild[j]) * atof(pbd_InRecOwner[EARP_R1]));
						pbd_InRecOwner[j] = ank_mnt [j-CML_AN1]; 
					}
					pbd_InRecOwner[CML_PATTYP_CT] = "EARBD";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);

					RETURN_VAL (0);
				}
				/******************************************************************************** 
				*******							DSC~LKI TREATMENT						*********
				*********************************************************************************/
				if( strcmp(pbd_InRecOwner[CML_PATCAT_CT],"DSC") == 0 && ( ACMTRS3 == 2211 || ACMTRS3 == 3201 || ACMTRS3 == 2032 || ACMTRS3 == 3202 ))
				{
					pbd_InRecOwner[CML_PATCAT_CT] = "EXP";
					pbd_InRecOwner[CML_PATTYP_CT] = "EGPCL";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
					
					sprintf(amount , "%.3f" , atof(pbd_InRecChild[CML_ACMAMT_MC]) * atof(pbd_InRecOwner[EARP_R1]));
					pbd_InRecOwner[CML_ACMAMT_MC] = amount; 
					sprintf(total_mnt , "%.3f" , atof(pbd_InRecChild[CML_TOTAUX_MC]) * atof(pbd_InRecOwner[EARP_R1]));
					pbd_InRecOwner[CML_TOTAUX_MC] = total_mnt; 
					for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
					{
						sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(pbd_InRecChild[j]) * atof(pbd_InRecOwner[EARP_R1]));
						pbd_InRecOwner[j] = ank_mnt [j-CML_AN1]; 
					}
					pbd_InRecOwner[CML_PATTYP_CT] = "EARCL";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
					
					RETURN_VAL (0);
				}
				if( strcmp(pbd_InRecOwner[CML_PATCAT_CT],"DSC") == 0 && ( ACMTRS3 == 2053 || ACMTRS3 == 2031 || ACMTRS3 == 2035 ))
				{
					pbd_InRecOwner[CML_PATCAT_CT] = "EXP";
					pbd_InRecOwner[CML_PATTYP_CT] = "EGPAE";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
					
					sprintf(amount , "%.3f" , atof(pbd_InRecChild[CML_ACMAMT_MC]) * atof(pbd_InRecOwner[EARP_R1]));
					pbd_InRecOwner[CML_ACMAMT_MC] = amount;						
					sprintf(total_mnt , "%.3f" , atof(pbd_InRecChild[CML_TOTAUX_MC]) * atof(pbd_InRecOwner[EARP_R1]));
					pbd_InRecOwner[CML_TOTAUX_MC] = total_mnt; 
					for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
					{
						sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(pbd_InRecChild[j]) * atof(pbd_InRecOwner[EARP_R1]));
						pbd_InRecOwner[j] = ank_mnt [j-CML_AN1]; 
					}
					pbd_InRecOwner[CML_PATTYP_CT] = "EARAE";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
				
					RETURN_VAL (0);			
				}
				/******************************************************************************** 
				*******								RAD~LKI TREATMENT					*********
				*********************************************************************************/
				if( strcmp(pbd_InRecOwner[CML_PATCAT_CT],"RAD") == 0 )
				{
					pbd_InRecOwner[CML_PATCAT_CT] = "EXP";
					pbd_InRecOwner[CML_PATTYP_CT] = "EGPRA"; 
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
					
					sprintf(amount , "%.3f" , atof(pbd_InRecChild[CML_ACMAMT_MC]) * atof(pbd_InRecOwner[EARP_R1]));
					pbd_InRecOwner[CML_ACMAMT_MC] = amount; 
					sprintf(total_mnt , "%.3f" , atof(pbd_InRecChild[CML_TOTAUX_MC]) * atof(pbd_InRecOwner[EARP_R1]));
					pbd_InRecOwner[CML_TOTAUX_MC] = total_mnt; 
					for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
					{
						sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(pbd_InRecChild[j]) * atof(pbd_InRecOwner[EARP_R1]));
						pbd_InRecOwner[j] = ank_mnt [j-CML_AN1]; 
					}
					pbd_InRecOwner[CML_PATTYP_CT] = "EARRA";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
					
					RETURN_VAL (0);				
				}
			}				
		}
	}
	RETURN_VAL (0);
}
		
/**===========================================================================
objet 	: Fonction lance a chaque ligne synchro entre FORWARD et DSC_RAD_LKI
retour 	:	0		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==============================================================================*/
int n_PereSansFils_FORWARD( char **pbd_InRecOwner )
{
	DEBUT_FCT("n_PereSansFils_FORWARD");
	int 	ACMTRS3, j;
	char 	amount[AMN_LEN], ank_mnt[65][AMN_LEN], total_mnt[AMN_LEN];
	char 	amount2[AMN_LEN],amount3[AMN_LEN];
	
	//100977
	CSM_RAT_PREV = 0;
	LC_RAT_PREV = 0;
	
	if( strcmp(pbd_InRecOwner[CSM_PREVQ],"") != 0 ) {
	 CSM_RAT_PREV = atof(pbd_InRecOwner[CSM_PREVQ]);
	}
	
	if( strcmp(pbd_InRecOwner[LC_PREVQ],"") != 0 )   {
	 LC_RAT_PREV = atof(pbd_InRecOwner[LC_PREVQ]);
	}

	CSM_RAT = 1;
	
	//if( fabs( atof(pbd_InRecOwner[FUTURE_PREM_PREVQ]) - atof(pbd_InRecOwner[UPR_PREVQ]) > 1 ))
	if ( CSM_RAT_PREV != 1 || LC_RAT_PREV != 1 )
	{
		memset(amount,0, sizeof(amount));
	    memset(amount2,0, sizeof(amount2));
	    memset(amount3,0, sizeof(amount3));		
		memset(total_mnt,0, sizeof(total_mnt));
		ACMTRS3 = atoi(pbd_InRecOwner[CML_ACMTRS3]);
		
		d_UPR_PREVQ			= atof(pbd_InRecOwner[UPR_PREVQ]);
		d_ITD_PREM_ACT		= atof(pbd_InRecOwner[ITD_PREM_ACT]);
		d_FIXED_CHARGE_ACT	= atof(pbd_InRecOwner[FIXED_CHARGE_ACT]);
		d_PREM_ESTM_PREVQ	= atof(pbd_InRecOwner[PREM_ESTM_PREVQ]);
		d_FUTURE_PREM_PREVQ = atof(pbd_InRecOwner[FUTURE_PREM_PREVQ]);
		d_REMAIN_ESTM_PREVQ	= atof(pbd_InRecOwner[REMAIN_ESTM_PREVQ]);
		
		if( ACMTRS3 == 1051 || ACMTRS3 == 1010 )
		{	
			if( fabs(d_FUTURE_PREM_PREVQ + d_PREM_ESTM_PREVQ + d_REMAIN_ESTM_PREVQ) < 1 && fabs( d_UPR_PREVQ ) > 0 )
			{

				if( ACMTRS3 == 1051 && strcmp(pbd_InRecOwner[CML_PATCAT_CT],"BDT") == 0 )
				{
					sprintf(amount , "%.3f" , atof(pbd_InRecOwner[CML_ACMAMT_MC]));
					pbd_InRecOwner[CML_ACMAMT_MC] = amount; 
					sprintf(amount2 , "%.3f" , atof(pbd_InRecOwner[CML_AN1]));
					pbd_InRecOwner[CML_AN1] = amount2;
					sprintf(amount3 , "%.3f" , atof(pbd_InRecOwner[CML_TOTAUX_MC]));
					pbd_InRecOwner[CML_TOTAUX_MC] = amount3; 
					//108366
					for( j = CML_AN2; j<= CML_AM_FIN; ++j )   
					{
						sprintf(ank_mnt [j-CML_AN2] , "%.3f" , atof(pbd_InRecOwner[j]) );
						pbd_InRecOwner[j] = ank_mnt [j-CML_AN2];

					//	pbd_InRecOwner[j] = "0.000"; 
					}
					pbd_InRecOwner[CML_PATCAT_CT] = "EXP";
					pbd_InRecOwner[CML_PATTYP_CT] = "EGPBD";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
					pbd_InRecOwner[CML_PATTYP_CT] = "EARBD";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
				}
				else if( ACMTRS3 == 1051 && strcmp(pbd_InRecOwner[CML_PATCAT_CT],"DSC") == 0 )
				{
					sprintf(amount , "%.3f" , atof(pbd_InRecOwner[CML_ACMAMT_MC]));
					pbd_InRecOwner[CML_ACMAMT_MC] = amount; 
					sprintf(amount2 , "%.3f" , atof(pbd_InRecOwner[CML_AN1]));
					pbd_InRecOwner[CML_AN1] = amount2;
					sprintf(amount3 , "%.3f" , atof(pbd_InRecOwner[CML_TOTAUX_MC]));
					pbd_InRecOwner[CML_TOTAUX_MC] = amount3; 
					//108366
					for( j = CML_AN2; j<= CML_AM_FIN; ++j )   
					{
						sprintf(ank_mnt [j-CML_AN2] , "%.3f" , atof(pbd_InRecOwner[j]) );
						pbd_InRecOwner[j] = ank_mnt [j-CML_AN2];

					//	pbd_InRecOwner[j] = "0.000"; 
					}
					pbd_InRecOwner[CML_PATCAT_CT] = "EXP";
					pbd_InRecOwner[CML_PATTYP_CT] = "EGPPR";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
					pbd_InRecOwner[CML_PATTYP_CT] = "EARPR";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
				}
				else
				{
					sprintf(amount , "%.3f" , atof(pbd_InRecOwner[CML_ACMAMT_MC]) + d_ITD_PREM_ACT + d_FIXED_CHARGE_ACT);
					pbd_InRecOwner[CML_ACMAMT_MC] = amount; 
					sprintf(amount2 , "%.3f" , atof(pbd_InRecOwner[CML_AN1]) + d_ITD_PREM_ACT + d_FIXED_CHARGE_ACT);
					pbd_InRecOwner[CML_AN1] = amount2;
					sprintf(amount3 , "%.3f" , atof(pbd_InRecOwner[CML_TOTAUX_MC]) + d_ITD_PREM_ACT + d_FIXED_CHARGE_ACT);
					pbd_InRecOwner[CML_TOTAUX_MC] = amount3; 
					//108366
					for( j = CML_AN2; j<= CML_AM_FIN; ++j )   
					{
						sprintf(ank_mnt [j-CML_AN2] , "%.3f" , atof(pbd_InRecOwner[j]) );
						pbd_InRecOwner[j] = ank_mnt [j-CML_AN2];

					//	pbd_InRecOwner[j] = "0.000"; 
					}
					pbd_InRecOwner[CML_PATCAT_CT] = "EXP";
					pbd_InRecOwner[CML_PATTYP_CT] = "EGPPR";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
					pbd_InRecOwner[CML_PATTYP_CT] = "EARPR";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
				}
			}
		}
		else
		{
				
			pbd_InRecOwner[CML_COMMENT] 	= "FWD not found";
			pbd_InRecOwner[CML_ACMAMT_MC] 	= "0.000";
			pbd_InRecOwner[CML_TOTAUX_MC] 	= "0.000";
			
			for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
			{
				pbd_InRecOwner[j] 	= "0.000";
			}
			if( strcmp(pbd_InRecOwner[CML_PATCAT_CT],"RAD") == 0 )
			{
				pbd_InRecOwner[CML_PATCAT_CT] 	= "EXP";
				pbd_InRecOwner[CML_PATTYP_CT] 	= "EGPRA"; 
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
				pbd_InRecOwner[CML_PATTYP_CT] 	= "EARRA"; 
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
				RETURN_VAL (0);
			}
			if( strcmp(pbd_InRecOwner[CML_PATCAT_CT],"BDT") == 0 )
			{
				pbd_InRecOwner[CML_PATCAT_CT] 	= "EXP";
				pbd_InRecOwner[CML_PATTYP_CT] 	= "EGPBD";
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
				pbd_InRecOwner[CML_PATTYP_CT] 	= "EARBD"; 
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
				RETURN_VAL (0);
			}
			if( strcmp(pbd_InRecOwner[CML_PATCAT_CT],"DSC") == 0 )
			{
				switch( atoi( pbd_InRecOwner[CML_ACMTRS3] ) )
				{
					case 1051:
					case 1010:			
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
		}
	}		
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction lance a chaque ligne synchro entre FORWARD et DSC_RAD_LKI
retour 	:	0		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==============================================================================*/
int n_FilsSansPere_FORWARD( char **pbd_InRecChild )
{
	DEBUT_FCT("n_FilsSansPere_FORWARD");
	
	int 	ACMTRS3, j;
	char 	amount[AMN_LEN], ank_mnt[65][AMN_LEN], total_mnt[AMN_LEN];
	char 	amount2[AMN_LEN],amount3[AMN_LEN];	
	CSM_RAT = 1;

        //100977	
        CSM_RAT_PREV = 0;
        LC_RAT_PREV = 0;

        if( strcmp(pbd_InRecChild[CSM_PREVQ],"") != 0 ) {
         CSM_RAT_PREV = atof(pbd_InRecChild[CSM_PREVQ]);
        }

        if( strcmp(pbd_InRecChild[LC_PREVQ],"") != 0 )   {
         LC_RAT_PREV = atof(pbd_InRecChild[LC_PREVQ]);
        }

	char *origine_Cur [125];
	for( j = 0; j< 125; j++ ) origine_Cur[j] = pbd_InRecChild[j];
		
	memset(amount,0, sizeof(amount));
	memset(amount2,0, sizeof(amount2));
	memset(amount3,0, sizeof(amount3));	
	memset(total_mnt,0, sizeof(total_mnt));
	ACMTRS3 = atoi(pbd_InRecChild[CML_ACMTRS3]);
	
	d_UPR_PREVQ			= atof(pbd_InRecChild[UPR_PREVQ]);
	d_ITD_PREM_ACT		= atof(pbd_InRecChild[ITD_PREM_ACT]);
	d_FIXED_CHARGE_ACT	= atof(pbd_InRecChild[FIXED_CHARGE_ACT]);
	d_PREM_ESTM_PREVQ	= atof(pbd_InRecChild[PREM_ESTM_PREVQ]);
	d_FUTURE_PREM_PREVQ = atof(pbd_InRecChild[FUTURE_PREM_PREVQ]);
	d_REMAIN_ESTM_PREVQ	= atof(pbd_InRecChild[REMAIN_ESTM_PREVQ]);
	
	//100977 if( fabs(d_FUTURE_PREM_PREVQ - d_UPR_PREVQ) > 1 )
	if ( CSM_RAT_PREV != 1 || LC_RAT_PREV != 1 )
	{	 
		if( ACMTRS3 == 1051 || ACMTRS3 == 1010 )
		{	
			if( fabs(d_FUTURE_PREM_PREVQ + d_PREM_ESTM_PREVQ + d_REMAIN_ESTM_PREVQ) < 1 && fabs( d_UPR_PREVQ ) > 0 )
			{
				pbd_InRecChild[CML_ACMAMT_MC] 	= "0.000";
				pbd_InRecChild[CML_TOTAUX_MC] 	= "0.000";
				for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
				{
					pbd_InRecChild[j] = "0.000"; 
				}
				if( ACMTRS3 == 1051 && strcmp(pbd_InRecChild[CML_PATCAT_CT],"BDT") == 0 )
				{
					pbd_InRecChild[CML_PATCAT_CT] = "EXP";
					pbd_InRecChild[CML_PATTYP_CT] = "EGPBD";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);
					pbd_InRecChild[CML_PATTYP_CT] = "EARBD";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);
				}
				else if( ACMTRS3 == 1051 && strcmp(pbd_InRecChild[CML_PATCAT_CT],"DSC") == 0 )
				{
					pbd_InRecChild[CML_PATCAT_CT] = "EXP";
					pbd_InRecChild[CML_PATTYP_CT] = "EGPPR";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);
					pbd_InRecChild[CML_PATTYP_CT] = "EARPR";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);
				}
				else
				{
					sprintf(amount , "%.3f" , d_ITD_PREM_ACT + d_FIXED_CHARGE_ACT);
					pbd_InRecChild[CML_ACMAMT_MC] = amount; 
					sprintf(amount2 , "%.3f" , d_ITD_PREM_ACT + d_FIXED_CHARGE_ACT);
					pbd_InRecChild[CML_AN1] = amount2;
					sprintf(amount3 , "%.3f" , d_ITD_PREM_ACT + d_FIXED_CHARGE_ACT);
					pbd_InRecChild[CML_TOTAUX_MC] = amount3; 
					for( j = CML_AN2; j<= CML_AM_FIN; ++j )   
					{
						pbd_InRecChild[j] = "0.000"; 
					}
					pbd_InRecChild[CML_PATCAT_CT] = "EXP"; // [001]
					pbd_InRecChild[CML_PATTYP_CT] = "EGPPR";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);
					pbd_InRecChild[CML_PATTYP_CT] = "EARPR";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);
				}
			}
			else if( strcmp(pbd_InRecChild[EGPI_R1],"") != 0 )
			{
				sprintf(amount , "%.3f" , atof(pbd_InRecChild[CML_ACMAMT_MC])* atof(pbd_InRecChild[EGPI_R1]));
				pbd_InRecChild[CML_ACMAMT_MC] = amount;				
				sprintf(total_mnt , "%.3f" , atof(pbd_InRecChild[CML_TOTAUX_MC]) * atof(pbd_InRecChild[EGPI_R1]));
				pbd_InRecChild[CML_TOTAUX_MC] = total_mnt; 
				for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
				{
					sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(pbd_InRecChild[j]) * atof(pbd_InRecChild[EGPI_R1]));
					pbd_InRecChild[j] = ank_mnt [j-CML_AN1];
				}
				if( ACMTRS3 == 1051 && strcmp(pbd_InRecChild[CML_PATCAT_CT],"BDT") == 0 )
				{
					pbd_InRecChild[CML_PATCAT_CT] = "EXP";
					pbd_InRecChild[CML_PATTYP_CT] = "EGPBD";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);
					pbd_InRecChild[CML_PATTYP_CT] = "EARBD";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);
				}
				else
				{
					pbd_InRecChild[CML_PATCAT_CT] = "EXP";
					pbd_InRecChild[CML_PATTYP_CT] = "EGPPR";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);
					pbd_InRecChild[CML_PATTYP_CT] = "EARPR";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);
				}
			}
			RETURN_VAL (0);	
		}
		if( ACMTRS3 == 2090 && strcmp(pbd_InRecChild[EGPI_R1],"") != 0 )
		{
			sprintf(amount , "%.3f" , atof(pbd_InRecChild[CML_ACMAMT_MC]) * atof(pbd_InRecChild[EGPI_R1]));
			pbd_InRecChild[CML_ACMAMT_MC] = amount;				
			sprintf(total_mnt , "%.3f" , atof(pbd_InRecChild[CML_TOTAUX_MC]) * atof(pbd_InRecChild[EGPI_R1]));
			pbd_InRecChild[CML_TOTAUX_MC] = total_mnt; 
			for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
			{
				sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(pbd_InRecChild[j]) * atof(pbd_InRecChild[EGPI_R1]));
				pbd_InRecChild[j] = ank_mnt [j-CML_AN1];
			}
			pbd_InRecChild[CML_PATCAT_CT] = "EXP";
			pbd_InRecChild[CML_PATTYP_CT] = "EGPAE";
			n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);
			
			if( strcmp(pbd_InRecChild[CSM_PREVQ],"") != 0 && fabs(atof(pbd_InRecChild[CSM_PREVQ])) > 0 )
			{
				CSM_RAT = (atof(pbd_InRecChild[CSM_Q]) - atof(pbd_InRecChild[CSM_PREVQ])) / atof(pbd_InRecChild[CSM_PREVQ]);
				sprintf(amount , "%.3f" , atof(pbd_InRecChild[CML_ACMAMT_MC]) * CSM_RAT );
				pbd_InRecChild[CML_ACMAMT_MC] = amount;				
				sprintf(total_mnt , "%.3f" , atof(pbd_InRecChild[CML_TOTAUX_MC]) * CSM_RAT );
				pbd_InRecChild[CML_TOTAUX_MC] = total_mnt; 
				for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
				{
					sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(pbd_InRecChild[j]) * CSM_RAT );
					pbd_InRecChild[j] = ank_mnt [j-CML_AN1];
				}
				pbd_InRecChild[CML_PATTYP_CT] = "EARAE";
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);	
			} else { //100977
      
				//CSM_RAT = (atof(pbd_InRecChild[CSM_Q]) - atof(pbd_InRecChild[CSM_PREVQ])) / atof(pbd_InRecChild[CSM_PREVQ]);
				CSM_RAT = 0;
                                sprintf(amount , "%.3f" , atof(pbd_InRecChild[CML_ACMAMT_MC]) * CSM_RAT );
				pbd_InRecChild[CML_ACMAMT_MC] = amount;				
				sprintf(total_mnt , "%.3f" , atof(pbd_InRecChild[CML_TOTAUX_MC]) * CSM_RAT );
				pbd_InRecChild[CML_TOTAUX_MC] = total_mnt; 
				for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
				{
					sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(pbd_InRecChild[j]) * CSM_RAT );
					pbd_InRecChild[j] = ank_mnt [j-CML_AN1];
				}
				pbd_InRecChild[CML_PATTYP_CT] = "EARAE";
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);	

                        }	
			RETURN_VAL (0);	
		}
		if( strcmp(pbd_InRecChild[EGPI_R2],"") != 0 && strcmp(pbd_InRecChild[EARP_R1],"") != 0 )
		{
			sprintf(amount , "%.3f" , atof(pbd_InRecChild[CML_ACMAMT_MC]) * atof(pbd_InRecChild[EGPI_R2]));
			pbd_InRecChild[CML_ACMAMT_MC] = amount; 
			sprintf(total_mnt , "%.3f" , atof(pbd_InRecChild[CML_TOTAUX_MC]) * atof(pbd_InRecChild[EGPI_R2]));
			pbd_InRecChild[CML_TOTAUX_MC] = total_mnt; 
			for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
			{
				sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(pbd_InRecChild[j]) * atof(pbd_InRecChild[EGPI_R2]));
				pbd_InRecChild[j] = ank_mnt [j-CML_AN1]; 
			}
			/******************************************************************************** 
			*******							BDT~LKI TREATMENT 						*********
			*********************************************************************************/
			if( strcmp(pbd_InRecChild[CML_PATCAT_CT],"BDT") == 0 )
			{
				pbd_InRecChild[CML_PATCAT_CT] = "EXP";
				pbd_InRecChild[CML_PATTYP_CT] = "EGPBD";
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);
				
				sprintf(amount , "%.3f" , atof(origine_Cur[CML_ACMAMT_MC]) * atof(pbd_InRecChild[EARP_R1]));
				pbd_InRecChild[CML_ACMAMT_MC] = amount; 
				
				sprintf(total_mnt , "%.3f" , atof(origine_Cur[CML_TOTAUX_MC]) * atof(pbd_InRecChild[EARP_R1]));
				pbd_InRecChild[CML_TOTAUX_MC] = total_mnt; 
				
				for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
				{
					sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(origine_Cur[j]) * atof(pbd_InRecChild[EARP_R1]));
					pbd_InRecChild[j] = ank_mnt [j-CML_AN1]; 
				}
				pbd_InRecChild[CML_PATTYP_CT] = "EARBD";
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);

				RETURN_VAL (0);
			}
			/******************************************************************************** 
			*******							DSC~LKI TREATMENT						*********
			*********************************************************************************/
			if( strcmp(pbd_InRecChild[CML_PATCAT_CT],"DSC") == 0 && ( ACMTRS3 == 2211 || ACMTRS3 == 3201 || ACMTRS3 == 2032 || ACMTRS3 == 3202 ))
			{
				pbd_InRecChild[CML_PATCAT_CT] = "EXP";
				pbd_InRecChild[CML_PATTYP_CT] = "EGPCL";
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);
				
				sprintf(amount , "%.3f" , atof(origine_Cur[CML_ACMAMT_MC]) * atof(pbd_InRecChild[EARP_R1]));
				pbd_InRecChild[CML_ACMAMT_MC] = amount; 
				sprintf(total_mnt , "%.3f" , atof(origine_Cur[CML_TOTAUX_MC]) * atof(pbd_InRecChild[EARP_R1]));
				pbd_InRecChild[CML_TOTAUX_MC] = total_mnt; 
				for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
				{
					sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(origine_Cur[j]) * atof(pbd_InRecChild[EARP_R1]));
					pbd_InRecChild[j] = ank_mnt [j-CML_AN1]; 
				}
				pbd_InRecChild[CML_PATTYP_CT] = "EARCL";
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);
				
				RETURN_VAL (0);
			}
			if( strcmp(pbd_InRecChild[CML_PATCAT_CT],"DSC") == 0 && ( ACMTRS3 == 2053 || ACMTRS3 == 2031 || ACMTRS3 == 2035 ))
			{
				pbd_InRecChild[CML_PATCAT_CT] = "EXP";
				pbd_InRecChild[CML_PATTYP_CT] = "EGPAE";
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);
				
				sprintf(amount , "%.3f" , atof(origine_Cur[CML_ACMAMT_MC]) * atof(pbd_InRecChild[EARP_R1]));
				pbd_InRecChild[CML_ACMAMT_MC] = amount;						
				sprintf(total_mnt , "%.3f" , atof(origine_Cur[CML_TOTAUX_MC]) * atof(pbd_InRecChild[EARP_R1]));
				pbd_InRecChild[CML_TOTAUX_MC] = total_mnt; 
				for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
				{
					sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(origine_Cur[j]) * atof(pbd_InRecChild[EARP_R1]));
					pbd_InRecChild[j] = ank_mnt [j-CML_AN1]; 
				}
				pbd_InRecChild[CML_PATTYP_CT] = "EARAE";
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);
			
				RETURN_VAL (0);			
			}
			/******************************************************************************** 
			*******								RAD~LKI TREATMENT					*********
			*********************************************************************************/
			if( strcmp(pbd_InRecChild[CML_PATCAT_CT],"RAD") == 0 )
			{
				pbd_InRecChild[CML_PATCAT_CT] = "EXP";
				pbd_InRecChild[CML_PATTYP_CT] = "EGPRA"; 
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);
				
				sprintf(amount , "%.3f" , atof(origine_Cur[CML_ACMAMT_MC]) * atof(pbd_InRecChild[EARP_R1]) );
				pbd_InRecChild[CML_ACMAMT_MC] = amount; 
				sprintf(total_mnt , "%.3f" , atof(origine_Cur[CML_TOTAUX_MC]) * atof(pbd_InRecChild[EARP_R1]) );
				pbd_InRecChild[CML_TOTAUX_MC] = total_mnt; 
				for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
				{
					sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(origine_Cur[j]) * atof(pbd_InRecChild[EARP_R1]) );
					pbd_InRecChild[j] = ank_mnt [j-CML_AN1]; 
				}
				pbd_InRecChild[CML_PATTYP_CT] = "EARRA";
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);
				
				RETURN_VAL (0);				
			}
		}			
	}
	RETURN_VAL (0);
}
