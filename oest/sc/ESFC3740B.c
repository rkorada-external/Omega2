/*==============================================================================
 Nom de l'application          : ESTIMATION IFRS17
 Nom du source                 : ESFC3740B.c
 Revision                      : $Revision: 1$
 Date de creation              : 30/09/2020
 Auteur                        : HR
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
 Description :
   

------------------------------------------------------------------------------
     Historique des modifications :

28/09/2022    	HR    	106766  	INITIAL VERSION DEVELOPMENT
08/02/2023    	HR    	108588  	Undiscounted and discounted RA booked on last endorsment
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>
#include "estutil.c"
#include "ESTC3001.h"
#include <utctlib.h>
#include <util.h>
#include <stdarg.h>
#include "ESFC3740.h"

#define GT_ACCRET_IN 72

char 	amount1[30], amount2[30], amount3[30], amount4[30], amount5[30];

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
	
	if ( n_OpenFileAppl ( "ESFC3740B_O1","wt",&Kp_OutputFil_FILE ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	/** Initialisation de la variable Kbd_Rup_FILE */
	if ( n_Init_FILE(&Kbd_Rup_FILE) ) 
		ExitPgm ( ERR_XX , "" );

    /** lancement du traitement*/
	if (n_ProcessingRuptureVar(&Kbd_Rup_FILE) == ERR) 
		ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
	
	/***************************************************************************/
	/**   Fermeture Des fichiers ouverts                                       */
	/***************************************************************************/
	if ( n_CloseFileAppl( "ESFC3740B_I1", &( Kbd_Rup_FILE.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3740B_O1", &Kp_OutputFil_FILE ) == ERR ) 
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
int n_Init_FILE(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_Init_FILE");
	
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

	if ( n_OpenFileAppl ("ESFC3740B_I1", "rt", &(pbd_Rupt->pf_InputFil)))
		RETURN_VAL (ERR);

	pbd_Rupt->n_NbRupture 			= 1 ;
	pbd_Rupt->n_ConditionRupture[0] = n_IsRupt_FILE;
	pbd_Rupt->n_ActionFirst[0] 		= n_ActionFirstRupt_FILE;
	pbd_Rupt->n_ActionLast[0]       = n_ActionLastRupt_FILE;
	pbd_Rupt->n_ActionLigne 		= n_ActionLigne_FILE;
	pbd_Rupt->c_Separ 				= '~' ;
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction de test de rupture du niveau 1
retour	: 	0   ---> Rupture
			1   ---> Pas de rupture
==============================================================================*/
int n_IsRupt_FILE(char **ptb_InRec, char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_IsRupt_FILE");
	int ret;

	if ( ( ret = strcmp( ptb_InRec[GT_CTR_NF], ptb_InRec_Cur[GT_CTR_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( ptb_InRec[GT_SEC_NF]) - atoi( ptb_InRec_Cur[GT_SEC_NF])) != 0)	return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_UWY_NF], ptb_InRec_Cur[GT_UWY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( ptb_InRec[GT_UW_NT]) - atoi( ptb_InRec_Cur[GT_UW_NT] )) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_RETCTR_NF], ptb_InRec_Cur[GT_RETCTR_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( ptb_InRec[GT_RETEND_NT]) - atoi(ptb_InRec_Cur[GT_RETEND_NT])) != 0 ) return ret ;
	if ( ( ret = atoi( ptb_InRec[GT_RETSEC_NF]) - atoi( ptb_InRec_Cur[GT_RETSEC_NF])) != 0)	return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_RTY_NF], ptb_InRec_Cur[GT_RTY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( ptb_InRec[GT_RETUW_NT]) - atoi( ptb_InRec_Cur[GT_RETUW_NT] )) != 0 ) return ret ;
//	if ( ( ret = strcmp( ptb_InRec[GT2_PATCAT_CT], ptb_InRec_Cur[GT2_PATCAT_CT] ) ) != 0 ) 			return ret;
//	if ( ( ret = strcmp( ptb_InRec[GT2_PATTYP_CT],ptb_InRec_Cur[GT2_PATTYP_CT] ) ) != 0 ) 	return ret;
//	if ( ( ret = strcmp( ptb_InRec[GT2_ACMTRS3_NF],ptb_InRec_Cur[GT2_ACMTRS3_NF] ) ) != 0 ) 		return ret;
//	if ( ( ret = atoi( ptb_InRec[GT2_TYP_CT]) - atoi(ptb_InRec_Cur[GT2_TYP_CT])) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_TRNCOD_CF], ptb_InRec_Cur[GT_TRNCOD_CF] ) ) != 0 )	return ret;
//	if ( ( ret = strcmp( ptb_InRec[GT_ACCRET_IN], ptb_InRec_Cur[GT_ACCRET_IN] ) ) != 0 )	return ret;
	if ( ( ret = atoi( ptb_InRec[GT_PLC_NT]) - atoi( ptb_InRec_Cur[GT_PLC_NT] )) != 0 ) return ret ;
	if ( ( ret = atoi( ptb_InRec[GT_RTO_NF]) - atoi( ptb_InRec_Cur[GT_RTO_NF] )) != 0 ) return ret ;
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction de rupture du niveau 1
==============================================================================*/
int n_ActionFirstRupt_FILE( char **ptb_InRec_Cur )
{
	DEBUT_FCT("n_ActionFirstRupt_FILE");
    
	/** COMMON INITIALISATION */
	memset(amount1,0, sizeof(amount1));
    memset(amount2,0, sizeof(amount2));
    memset(amount3,0, sizeof(amount3));	
    memset(amount4,0, sizeof(amount4));	
    memset(amount5,0, sizeof(amount5));	
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction lance a fin rupture
retour 	:	0		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==============================================================================*/
int n_ActionLastRupt_FILE( char **pbd_InRecOwner )
{
	DEBUT_FCT("n_ActionLast_FILE");

	pbd_InRecOwner[GT2_ACMAMT_M] = amount1;				
	pbd_InRecOwner[GT2_AMT_M] = amount2; 
	pbd_InRecOwner[GT_RETAMT_M] = amount4; 
	pbd_InRecOwner[GT_RETINTAMT_M] = amount5; 
//	pbd_InRecOwner[GT2_TOTAUX_M] = amount3; 
					
    n_WriteCols(Kp_OutputFil_FILE,  pbd_InRecOwner, '~', 0);
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction lance a chaque ligne PERIMETER
retour 	:	0		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==============================================================================*/
int n_ActionLigne_FILE( char **pbd_InRecOwner )
{
	DEBUT_FCT("n_ActionLigne_FILE");

	sprintf(amount1 , "%.3f" , atof(amount1) + atof(pbd_InRecOwner[GT2_ACMAMT_M]));
	sprintf(amount2 , "%.3f" , atof(amount2) + atof(pbd_InRecOwner[GT2_AMT_M]));
	sprintf(amount4 , "%.3f" , atof(amount4) + atof(pbd_InRecOwner[GT_RETAMT_M]));
	sprintf(amount5 , "%.3f" , atof(amount5) + atof(pbd_InRecOwner[GT_RETINTAMT_M]));
//	sprintf(amount3 , "%.3f" , atof(amount3) + atof(pbd_InRecOwner[GT2_TOTAUX_M]));

	RETURN_VAL (0);
}
