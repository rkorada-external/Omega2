/**===============================================================================================
APPLICATION NAME          		: IFRS17 REVENUE CALCULATION ASSUMED
PROGRAM NAME                 	: ESFC3690B.c
REVISION                      	: V1
CREATION DATE              		: 09/2022
AUTHOR                        	: HR
---------------------------------------------------------------------------------------------------
DESCRIPTION :
	THIS PROGRAM AIMS TO HANDLE IFRS17 REVENUE CALCULATION FOR ASSUMED CONTRACTS
---------------------------------------------------------------------------------------------------
CHANGE HISTORY :

28/09/2022    	HR    	106766  	INITIAL VERSION DEVELOPMENT
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

char 	amount[AMN_LEN], ank_mnt[65][AMN_LEN], total_mnt[AMN_LEN];

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
	
	if ( n_OpenFileAppl ( "ESFC3690B_O1","wt",&Kp_OutputFil_FILE ) == ERR )
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
	if ( n_CloseFileAppl( "ESFC3690B_I1", &( Kbd_Rup_FILE.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3690B_O1", &Kp_OutputFil_FILE ) == ERR ) 
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

	if ( n_OpenFileAppl ("ESFC3690B_I1", "rt", &(pbd_Rupt->pf_InputFil)))
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
	
	if ( ( ret = strcmp( ptb_InRec[CML_CTR_NF], ptb_InRec_Cur[CML_CTR_NF] ) ) != 0 ) 			return ret;
	//if ( ( ret = atoi( ptb_InRec[CML_END_NT] ) - atoi( ptb_InRec_Cur[CML_END_NT] ) ) != 0 ) 	return ret;
	if ( ( ret = atoi( ptb_InRec[CML_SEC_NF] ) - atoi( ptb_InRec_Cur[CML_SEC_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = strcmp( ptb_InRec[CML_UWY_NF], ptb_InRec_Cur[CML_UWY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( ptb_InRec[CML_UW_NT] ) - atoi( ptb_InRec_Cur[CML_UW_NT] ) ) != 0 ) 	return ret;
	//if ( ( ret = strcmp( ptb_InRec[CML_CUR_CF],ptb_InRec_Cur[CML_CUR_CF] ) ) != 0 ) 			return ret;
	if ( ( ret = strcmp( ptb_InRec[CML_TYP_CT], ptb_InRec_Cur[CML_TYP_CT] ) ) != 0 ) 			return ret;
	if ( ( ret = strcmp( ptb_InRec[CML_PATCAT_CT], ptb_InRec_Cur[CML_PATCAT_CT] ) ) != 0 ) 			return ret;
	if ( ( ret = strcmp( ptb_InRec[CML_PATTYP_CT],ptb_InRec_Cur[CML_PATTYP_CT] ) ) != 0 ) 	return ret;
	if ( ( ret = strcmp( ptb_InRec[CML_ACMTRS3],ptb_InRec_Cur[CML_ACMTRS3] ) ) != 0 ) 		return ret;
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction de rupture du niveau 1
==============================================================================*/
int n_ActionFirstRupt_FILE( char **ptb_InRec_Cur )
{
	DEBUT_FCT("n_ActionFirstRupt_FILE");
    
	int j;
	
	/** COMMON INITIALISATION */
	memset(amount,0, sizeof(amount));
	memset(total_mnt,0, sizeof(total_mnt));
	
	for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
	{
		sprintf(ank_mnt [j-CML_AN1] , "%.3f" , 0.000);
	}
	
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

    int j;

	pbd_InRecOwner[CML_ACMAMT_MC] = amount;				
	pbd_InRecOwner[CML_TOTAUX_MC] = total_mnt; 
	for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
	{
		pbd_InRecOwner[j] = ank_mnt [j-CML_AN1];
	}
					
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

    int j;
	
	sprintf(amount , "%.3f" , atof(amount) + atof(pbd_InRecOwner[CML_ACMAMT_MC]));
	sprintf(total_mnt , "%.3f" , atof(total_mnt) + atof(pbd_InRecOwner[CML_TOTAUX_MC]));
	for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
	{
		sprintf(ank_mnt [j-CML_AN1] , "%.3f" , atof(ank_mnt [j-CML_AN1]) + atof(pbd_InRecOwner[j]));
	}

	RETURN_VAL (0);
}
