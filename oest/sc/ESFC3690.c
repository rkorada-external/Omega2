/**==================================================================================================
NOM DE L'APPLICATION          : IFRS17 REVENUE CALCULATION ASSUMED
NOM DU SOURCE                 : ESFC3690.c
REVISION                      : V1
DATE DE CREATION              : 07/2019
AUTEUR                        : L.ELFAHIM
SQUELETTE DE BASE             : Batch
REFERENCES DES SPECIFICATIONS : 
------------------------------------------------------------------------------------------------------
DESCRIPTION :
	CE PROGRAMME EST DESTINE AU CALCUL DE IFRS17 REVENUE ASSUMED
------------------------------------------------------------------------------------------------------
	 /  \   * POUR LA MAINTENABILITE DE CE PROGRAMME MERCI DE SIGNER  *
	/  ! \  * TOUTE MODIFICATION APPORTEE SUIVANT LE MODELE DESSOUS   *
	/______\ **********************************************************

HISTORIQUE DES MODIFICATIONS :

06/06/2019    	LEL    	70741  	DEVELOPPEMENT DE LA VERSION INITIALE
30/09/2019    	LEL		70741  	STABILISATION ET AMELIORATION
03/10/2019    	LEL  	70741  	AJOUT FICHIER TRACES DES MONTANTS
18/10/2019    	LEL   	87722  	SEPARATE RETRO NP from OTHER TYPES
27/12/2019    	LEL  	82837  	ADJUST REVENUE CALCULATION IN THE CASE OPENING FP=0 AND CHANGE IN EGPI<>0
27/02/2020    	LEL  	82711	INITIAL VERSION OF DAC MANAGEMENT
11/06/2020    	LEL  	70741	DEACTIVATE DAC MANAGEMENT
23/07/2020    	LEL  	82711	REACTIVATE DAC MANAGEMENT
24/07/2020    	LEL  	79621	IMPLEMENTATION OF SPIRA
24/07/2020    	LEL  	88368	IMPLEMENTATION OF SPIRA
24/07/2020    	LEL  	88235	IMPLEMENTATION OF SPIRA
15/09/2020    	LEL  	89817	SPLIT MERGE CLAIM et RA ( 3201 && 3202 )
21/09/2020    	LEL 	90079	MANAGE SEC > 10  
10/12/2020    	LEL  	90446	IMPLEMENTATION OF FIRST CLOSING CONDITIONS OF CSUOE
23/12/2020    	LEL  	91111	EXTEND TO INCURRED RECEIVABLES/PREMIUM ESTIMATES
28/12/2020    	LEL  	91113	ADD AN ADDITIONAL CONDITION TO LAUNCH REVENUE
01/01/2021    	LEL    	93580	ALIGN RETRO AND ASSUMED REGARDING INPUT FILES
09/02/2021    	LEL    	92797	IFRS 17 - UPR AT FIRST CLOSING FOR GROSS UP
22/04/2021    	LEL   	95798	DESACTIVATE UPR OPENING
14/05/2021    	LEL    	95212	DELETE CASE INCEPTION STATUS EMPTY
18/06/2021    	LEL   	97096	OVERRIDING DATA FROM PREVIOUS PERIOD WHEN FIRST CLOSING
31/08/2021 	LEL 	97373	ACF/PCA: IMPACT REVENUE CALCULATION
13/12/2021 	HR 	100940	REQ 11.01 & 11.06 - I17 - Correction in the subsequent acq. exp. position calculation
02/02/2022      HR      100977  I17 - Criteria to compute Revenue / EXP / CSM
09/01/2023      HR      108366  REQ 11.06 - Adjust expected recievables EGPI position for rule R03-01
23/01/2023 HR 108549 REQ 11.06 - Rule R03-01 not applied when DSC/FWD grp 1010 or 1051 does not exist
=====================================================================================================*/

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
	
    strcpy (Norme_CF, psz_GetCharArgv(1));


	/***************************************************************************/
	/**  Ouverture Des fichiers en entree et Initialisation des structures     */
	/***************************************************************************/
	
	if ( n_OpenFileAppl ( "ESFC3690_O1","wt",&Kp_OutputFil_REVENUE ) == ERR )
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
	if ( n_CloseFileAppl( "ESFC3690_I1", &( Kbd_Rup_LockedInRate.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3690_I2", &( Kbd_Rupt_FORWARD.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3690_O1", &Kp_OutputFil_REVENUE ) == ERR ) 
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

	if ( n_OpenFileAppl ("ESFC3690_I1", "rt", &(pbd_Rupt->pf_InputFil)))
		RETURN_VAL (ERR);

	pbd_Rupt->n_NbRupture 			= 0 ;
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
	
	// Lancement synchronisation avec le fichier FORWARD  
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
	n_OpenFileAppl ("ESFC3690_I2", "rt", &(pbd_Sync->pf_InputFil));

	pbd_Sync->ConditionEndSync  	= n_CondSync_FORWARD;        
	pbd_Sync->n_ActionLigne     	= n_ActionLigne_FORWARD;
	pbd_Sync->n_PereSansFils     	= n_PereSansFils_FORWARD; 
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
	if ( ( ret = strcmp( pbd_InRecOwner[CML_CUR_CF],pbd_InRecChild[CML_CUR_CF] ) ) != 0 ) 			return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_NAT_CF], pbd_InRecChild[CML_NAT_CF] ) ) != 0 ) 			return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_TYP_CT], pbd_InRecChild[CML_TYP_CT] ) ) != 0 ) 			return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_PATCAT_CT],pbd_InRecChild[CML_PATCAT_CT] ) ) != 0 ) 	return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[CML_ACMTRS3],pbd_InRecChild[CML_ACMTRS3] ) ) != 0 ) 		return ret;
	//if ((ret = strcmp (pbd_InRecOwner[CML_KEY_NF], pbd_InRecChild[CML_KEY_NF])) != 0)
	//  return ret;
	
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
	
	/** VARIABLES DECLARATION */
	int 	ACMTRS3, j;
	char 	amount[AMN_LEN], ank_mnt[65][AMN_LEN], total_mnt[AMN_LEN];
	char 	amount2[AMN_LEN], amount3[AMN_LEN];

	//100940 CSM_RAT = 1;
	CSM_RAT = 0;

	//100977
	CSM_RAT_PREV = 0;
	LC_RAT_PREV = 0;

	if( strcmp(pbd_InRecOwner[CSM_PREVQ],"") != 0 )	{
	 CSM_RAT_PREV = atof(pbd_InRecOwner[CSM_PREVQ]);
	}

	if( strcmp(pbd_InRecOwner[LC_PREVQ],"") != 0 )   {
	 LC_RAT_PREV = atof(pbd_InRecOwner[LC_PREVQ]);
	}

	/** COMMON INITIALISATION */
	memset(amount,0, sizeof(amount));
	memset(amount2,0, sizeof(amount2));
	memset(amount3,0, sizeof(amount3));
	memset(total_mnt,0, sizeof(total_mnt));
	
	/** RETRIEVE DATA from THE CURSOR */
	ACMTRS3 = atoi( pbd_InRecOwner[CML_ACMTRS3] );
	
	d_UPR_PREVQ			= atof(pbd_InRecOwner[UPR_PREVQ]);
	d_ITD_PREM_ACT		= atof(pbd_InRecOwner[ITD_PREM_ACT]);
	d_FIXED_CHARGE_ACT	= atof(pbd_InRecOwner[FIXED_CHARGE_ACT]);
	d_PREM_ESTM_PREVQ	= atof(pbd_InRecOwner[PREM_ESTM_PREVQ]);
	d_FUTURE_PREM_PREVQ = atof(pbd_InRecOwner[FUTURE_PREM_PREVQ]);
	d_REMAIN_ESTM_PREVQ	= atof(pbd_InRecOwner[REMAIN_ESTM_PREVQ]);

	//100977 if( fabs(d_FUTURE_PREM_PREVQ - d_UPR_PREVQ) > 1 )
	if ( CSM_RAT_PREV != 1 ||  LC_RAT_PREV != 1 )
	{
		if( ACMTRS3 == 1051 || ACMTRS3 == 1010 )
		{	
			pbd_InRecOwner[CML_PATCAT_CT] = "EXP";
			if( fabs(d_FUTURE_PREM_PREVQ + d_PREM_ESTM_PREVQ + d_REMAIN_ESTM_PREVQ) < 1 && fabs( d_UPR_PREVQ ) > 0 )
			{
				if( ACMTRS3 == 1051 )
				{
                    sprintf(amount , "%.3f" , atof(pbd_InRecOwner[CML_ACMAMT_MC]));
					pbd_InRecOwner[CML_ACMAMT_MC] = amount; 
                    sprintf(amount2 , "%.3f" , atof(pbd_InRecOwner[CML_AN1]));
					pbd_InRecOwner[CML_AN1] = amount2;
					sprintf(amount3 , "%.3f" , atof(pbd_InRecOwner[CML_TOTAUX_MC]));
					pbd_InRecOwner[CML_TOTAUX_MC] = amount3; 
					//SPIRA 108366
					for( j = CML_AN2; j<= CML_AM_FIN; ++j )   
					{
						sprintf(ank_mnt [j-CML_AN2] , "%.3f" , atof(pbd_InRecOwner[j]) );
						pbd_InRecOwner[j] = ank_mnt [j-CML_AN2];
			
 					    //pbd_InRecOwner[j] = "0.000"; 
					}
				}
				else
				{
                    sprintf(amount , "%.3f" , atof(pbd_InRecOwner[CML_ACMAMT_MC]) + d_ITD_PREM_ACT + d_FIXED_CHARGE_ACT);
					pbd_InRecOwner[CML_ACMAMT_MC] = amount; 
                                        sprintf(amount2 , "%.3f" , atof(pbd_InRecOwner[CML_AN1]) + d_ITD_PREM_ACT + d_FIXED_CHARGE_ACT);
					pbd_InRecOwner[CML_AN1] = amount2;
					sprintf(amount3 , "%.3f" , atof(pbd_InRecOwner[CML_TOTAUX_MC]) + d_ITD_PREM_ACT + d_FIXED_CHARGE_ACT);
					pbd_InRecOwner[CML_TOTAUX_MC] = amount3; 
					//SPIRA 108366
					for( j = CML_AN2; j<= CML_AM_FIN; ++j )   
					{
						sprintf(ank_mnt [j-CML_AN2] , "%.3f" , atof(pbd_InRecOwner[j]) );
						pbd_InRecOwner[j] = ank_mnt [j-CML_AN2];
			
 					    //pbd_InRecOwner[j] = "0.000"; 
					}
				}
				pbd_InRecOwner[CML_PATTYP_CT] = "EGPPR";
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
				pbd_InRecOwner[CML_PATTYP_CT] = "EARPR";
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
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
					pbd_InRecOwner[CML_PATTYP_CT] = "EGPPR";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
					pbd_InRecOwner[CML_PATTYP_CT] = "EARPR";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);					
				}
			}
		}
		else if ( ACMTRS3 == 2090 || ACMTRS3 == 3115 )
		{
			pbd_InRecOwner[CML_PATCAT_CT] = "EXP";
			sprintf(amount , "%.3f" , atof(pbd_InRecChild[CML_ACMAMT_MC]) );
			pbd_InRecOwner[CML_ACMAMT_MC] = amount;				
			sprintf(total_mnt , "%.3f" , atof(pbd_InRecChild[CML_TOTAUX_MC]) );
			pbd_InRecOwner[CML_TOTAUX_MC] = total_mnt; 
			for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
			{
				sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(pbd_InRecChild[j]) );
				pbd_InRecOwner[j] = ank_mnt [j-CML_AN1];
			}
			if( ACMTRS3 == 2090 )
			{
				pbd_InRecOwner[CML_PATTYP_CT] = "EGPAE";
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);	
				if( strcmp(pbd_InRecOwner[CSM_PREVQ],"") != 0 )
				{
					//100940 CSM_RAT = 1 - ((1 - atof(pbd_InRecOwner[CSM_Q]))/(1 - atof(pbd_InRecOwner[CSM_PREVQ])));
                                        CSM_RAT = (1 - atof(pbd_InRecOwner[CSM_Q]))/(1 - atof(pbd_InRecOwner[CSM_PREVQ]));
					if( strcmp(pbd_InRecOwner[CSM_PREVQ], "1") == 0 )
					{
						//100940 pbd_InRecOwner[CML_COMMENT] = "Division by 0, ratio forced to 1";
						//100940 CSM_RAT = 1;
						pbd_InRecOwner[CML_COMMENT] = "Division by 0, ratio forced to 0";
						CSM_RAT = 0;
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
				} else { //100977
 
					//100940 CSM_RAT = 1 - ((1 - atof(pbd_InRecOwner[CSM_Q]))/(1 - atof(pbd_InRecOwner[CSM_PREVQ])));
                                        CSM_RAT = 1 - atof(pbd_InRecOwner[CSM_Q]);
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
				pbd_InRecOwner[CML_PATTYP_CT] = "EGPME";
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
				if( strcmp(pbd_InRecOwner[EARP_R1],"") != 0 )
				{
					sprintf(amount , "%.3f" , atof(pbd_InRecOwner[CML_ACMAMT_MC]) * atof(pbd_InRecOwner[EARP_R1]));
					pbd_InRecOwner[CML_ACMAMT_MC] = amount;				
					sprintf(total_mnt , "%.3f" , atof(pbd_InRecOwner[CML_TOTAUX_MC]) * atof(pbd_InRecOwner[EARP_R1]));
					pbd_InRecOwner[CML_TOTAUX_MC] = total_mnt; 
					for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
					{
						sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(pbd_InRecOwner[j]) * atof(pbd_InRecOwner[EARP_R1]));
						pbd_InRecOwner[j] = ank_mnt [j-CML_AN1];
					}
					pbd_InRecOwner[CML_PATTYP_CT] = "EARME";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);	
				}
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
	int 	j;
	
	/** VARIABLES DECLARATION */
	int 	ACMTRS3;
	char 	amount[AMN_LEN], ank_mnt[65][AMN_LEN], total_mnt[AMN_LEN];
	char 	amount2[AMN_LEN], amount3[AMN_LEN];
	
	//100977
	CSM_RAT_PREV = 0;
	LC_RAT_PREV = 0;

	if( strcmp(pbd_InRecOwner[CSM_PREVQ],"") != 0 )	{
	 CSM_RAT_PREV = atof(pbd_InRecOwner[CSM_PREVQ]);
	}

	if( strcmp(pbd_InRecOwner[LC_PREVQ],"") != 0 )   {
	 LC_RAT_PREV = atof(pbd_InRecOwner[LC_PREVQ]);
	}
	
    //100977 if( fabs( atof(pbd_InRecOwner[FUTURE_PREM_PREVQ]) - atof(pbd_InRecOwner[UPR_PREVQ]) > 1 )) 
    if ( CSM_RAT_PREV != 1 || LC_RAT_PREV != 1 )
	{
		/** RETRIEVE DATA from THE CURSOR */
		ACMTRS3 = atoi( pbd_InRecOwner[CML_ACMTRS3] );
		
		d_UPR_PREVQ			= atof(pbd_InRecOwner[UPR_PREVQ]);
		d_ITD_PREM_ACT		= atof(pbd_InRecOwner[ITD_PREM_ACT]);
		d_FIXED_CHARGE_ACT	= atof(pbd_InRecOwner[FIXED_CHARGE_ACT]);
		d_PREM_ESTM_PREVQ	= atof(pbd_InRecOwner[PREM_ESTM_PREVQ]);
		d_FUTURE_PREM_PREVQ = atof(pbd_InRecOwner[FUTURE_PREM_PREVQ]);
		d_REMAIN_ESTM_PREVQ	= atof(pbd_InRecOwner[REMAIN_ESTM_PREVQ]);

	    //108549 REQ 11.06 - Rule R03-01 not applied when DSC/FWD grp 1010 or 1051 does not exist
		if( ACMTRS3 == 1051 || ACMTRS3 == 1010 )
		{	
			if (fabs(d_FUTURE_PREM_PREVQ + d_PREM_ESTM_PREVQ + d_REMAIN_ESTM_PREVQ) < 1 && fabs( d_UPR_PREVQ ) > 0) {
				/** COMMON INITIALISATION */
				memset(amount,0, sizeof(amount));
				memset(amount2,0, sizeof(amount2));
				memset(amount3,0, sizeof(amount3));
				memset(total_mnt,0, sizeof(total_mnt));
				
				pbd_InRecOwner[CML_PATCAT_CT] = "EXP";
				if( ACMTRS3 == 1051 )
				{
					sprintf(amount , "%.3f" , atof(pbd_InRecOwner[CML_ACMAMT_MC]));
					pbd_InRecOwner[CML_ACMAMT_MC] = amount; 
					sprintf(amount2 , "%.3f" , atof(pbd_InRecOwner[CML_AN1]));
					pbd_InRecOwner[CML_AN1] = amount2;
					sprintf(amount3 , "%.3f" , atof(pbd_InRecOwner[CML_TOTAUX_MC]));
					pbd_InRecOwner[CML_TOTAUX_MC] = amount3; 
					//SPIRA 108366
					for( j = CML_AN2; j<= CML_AM_FIN; ++j )   
					{
						sprintf(ank_mnt [j-CML_AN2] , "%.3f" , atof(pbd_InRecOwner[j]) );
						pbd_InRecOwner[j] = ank_mnt [j-CML_AN2];
										//pbd_InRecOwner[j] = "0.000"; 
					}
				}
				else
				{
					sprintf(amount , "%.3f" , atof(pbd_InRecOwner[CML_ACMAMT_MC]) + d_ITD_PREM_ACT + d_FIXED_CHARGE_ACT);
					pbd_InRecOwner[CML_ACMAMT_MC] = amount; 
					sprintf(amount2 , "%.3f" , atof(pbd_InRecOwner[CML_AN1]) + d_ITD_PREM_ACT + d_FIXED_CHARGE_ACT);
					pbd_InRecOwner[CML_AN1] = amount2;
					sprintf(amount3 , "%.3f" , atof(pbd_InRecOwner[CML_TOTAUX_MC]) + d_ITD_PREM_ACT + d_FIXED_CHARGE_ACT);
					pbd_InRecOwner[CML_TOTAUX_MC] = amount3; 
					//SPIRA 108366
					for( j = CML_AN2; j<= CML_AM_FIN; ++j )   
					{
						sprintf(ank_mnt [j-CML_AN2] , "%.3f" , atof(pbd_InRecOwner[j]) );
						pbd_InRecOwner[j] = ank_mnt [j-CML_AN2];
										//pbd_InRecOwner[j] = "0.000"; 
					}
				}
				pbd_InRecOwner[CML_PATTYP_CT] = "EGPPR";
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
				pbd_InRecOwner[CML_PATTYP_CT] = "EARPR";
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
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
					case 2035:
					case 2031:
					{
						pbd_InRecOwner[CML_PATCAT_CT] 	= "EXP";
						pbd_InRecOwner[CML_PATTYP_CT] 	= "EGPAE";
						n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
						pbd_InRecOwner[CML_PATTYP_CT] 	= "EARAE"; 
						n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
						break;
					}
					case 3115:
					{
						pbd_InRecOwner[CML_PATCAT_CT] 	= "EXP";
						pbd_InRecOwner[CML_PATTYP_CT] 	= "EGPME";
						n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecOwner, '~', 0);
						pbd_InRecOwner[CML_PATTYP_CT] 	= "EARME"; 
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
	char 	amount2[AMN_LEN], amount3[AMN_LEN];
	//100940 CSM_RAT = 1
        CSM_RAT = 0;
	
        //100977
        CSM_RAT_PREV = 0;
        LC_RAT_PREV = 0;

        if( strcmp(pbd_InRecChild[CSM_PREVQ],"") != 0 )	{
         CSM_RAT_PREV = atof(pbd_InRecChild[CSM_PREVQ]);
        }

        if( strcmp(pbd_InRecChild[LC_PREVQ],"") != 0 )   {
         LC_RAT_PREV = atof(pbd_InRecChild[LC_PREVQ]);
        }

	char *origine_Cur [138];
	for( j = 0; j< 138; j++ ) origine_Cur[j] = pbd_InRecChild[j];
	
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
			pbd_InRecChild[CML_PATCAT_CT] = "EXP";
			if( fabs(d_FUTURE_PREM_PREVQ + d_PREM_ESTM_PREVQ + d_REMAIN_ESTM_PREVQ) < 1 && fabs( d_UPR_PREVQ ) > 0 )
			{
				if( ACMTRS3 == 1051 )
				{
					pbd_InRecChild[CML_ACMAMT_MC] 	= "0.000";
					pbd_InRecChild[CML_TOTAUX_MC] 	= "0.000";
					for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
					{
						pbd_InRecChild[j] = "0.000"; 
					}
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
				}
				pbd_InRecChild[CML_PATTYP_CT] = "EGPPR";
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);
				pbd_InRecChild[CML_PATTYP_CT] = "EARPR";
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);
			}
			else if( strcmp(pbd_InRecChild[EGPI_R1],"") != 0 )
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
				pbd_InRecChild[CML_PATTYP_CT] = "EGPPR";
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);
				
				pbd_InRecChild[CML_PATTYP_CT] = "EARPR";
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);
			}
		}
		else if ( ACMTRS3 == 2090 )
		{
			pbd_InRecChild[CML_PATCAT_CT] = "EXP";
			pbd_InRecChild[CML_PATTYP_CT] = "EGPAE";
			n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);	
			
			if( strcmp(pbd_InRecChild[CSM_PREVQ],"") != 0 && fabs(atof(pbd_InRecChild[CSM_PREVQ])) > 0 )
			{
				//100940 CSM_RAT = (atof(pbd_InRecChild[CSM_Q]) - atof(pbd_InRecChild[CSM_PREVQ])) / atof(pbd_InRecChild[CSM_PREVQ]);
                                CSM_RAT = (1 - atof(pbd_InRecChild[CSM_Q]))/(1 - atof(pbd_InRecChild[CSM_PREVQ]));
				if( strcmp(pbd_InRecChild[CSM_PREVQ], "1") == 0 )
				{
					pbd_InRecChild[CML_COMMENT] = "Division by 0, ratio forced to 0";
					CSM_RAT = 0;
				}
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


				//100940 CSM_RAT = (atof(pbd_InRecChild[CSM_Q]) - atof(pbd_InRecChild[CSM_PREVQ])) / atof(pbd_InRecChild[CSM_PREVQ]);
                                CSM_RAT = 1 - atof(pbd_InRecChild[CSM_Q]);
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
		}
		else if ( ACMTRS3 == 3115 )
		{
			pbd_InRecChild[CML_PATCAT_CT] = "EXP";
			pbd_InRecChild[CML_PATTYP_CT] = "EGPME";
			n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);
			
			if( strcmp(pbd_InRecChild[EARP_R1],"") != 0 )
			{
				sprintf(amount , "%.3f" , atof(pbd_InRecChild[CML_ACMAMT_MC]) * atof(pbd_InRecChild[EARP_R1]));
				pbd_InRecChild[CML_ACMAMT_MC] = amount;				
				sprintf(total_mnt , "%.3f" , atof(pbd_InRecChild[CML_TOTAUX_MC]) * atof(pbd_InRecChild[EARP_R1]));
				pbd_InRecChild[CML_TOTAUX_MC] = total_mnt; 
				for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
				{
					sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(pbd_InRecChild[j]) * atof(pbd_InRecChild[EARP_R1]));
					pbd_InRecChild[j] = ank_mnt [j-CML_AN1];
				}
				pbd_InRecChild[CML_PATTYP_CT] = "EARME";
				n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);	
			}
		}
		else
		{
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
				*******							DSC~FWD TREATMENT						*********
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
				*******								RAD~FWD TREATMENT					*********
				*********************************************************************************/
				if( strcmp(pbd_InRecChild[CML_PATCAT_CT],"RAD") == 0 )
				{
					pbd_InRecChild[CML_PATCAT_CT] = "EXP";
					pbd_InRecChild[CML_PATTYP_CT] = "EGPRA"; 
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
					pbd_InRecChild[CML_PATTYP_CT] = "EARRA";
					n_WriteCols(Kp_OutputFil_REVENUE,  pbd_InRecChild, '~', 0);
					
					RETURN_VAL (0);
				}
			}
		}			
	}
	RETURN_VAL (0);
}
