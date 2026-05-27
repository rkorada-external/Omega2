/**===========================================================================================================
NOM DE L'APPLICATION          : ACF/PCA: RATIO CALCULATION
NOM DU SOURCE                 : ESFC3642B.c
REVISION                      : V1
DATE DE CREATION              : 06/2022
AUTEUR                        : HR
SQUELETTE DE BASE             : Batch
REFERENCES DES SPECIFICATIONS : 
--------------------------------------------------------------------------------------------------------------
DESCRIPTION :
	CE PROGRAMME EST DESTINE AU CALCUL DE ACF/PCA RATIO
	for RETRO NP
--------------------------------------------------------------------------------------------------------------
	 /  \   * POUR LA MAINTENABILITE DE CE PROGRAMME MERCI DE SIGNER  *
	/  ! \  * TOUTE MODIFICATION APPORTEE SUIVANT LE MODELE DESSOUS   *
	/______\ **********************************************************

HISTORIQUE DES MODIFICATIONS :
	<JJ/MM/AAAA>   	<AUTEUR>  	<SPIRA>		<DESCRIPTION DE LA MODIFICATION>
	22/06/2022    	HR    		102519    	DEVELOPPEMENT DE LA VERSION INITIALE
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
#include "ESFC3640B.h"  

/**-------------------------------------------------
	Traitemant principale du programme                      
----------------------------------------------------*/
int main( int argc,  char *argv[] )
{
	InitSig ();

	if (n_BeginPgm (argc, argv) == ERR)
		ExitPgm (ERR_XX, "");
	
	strcpy(Ksz_CloDat, psz_GetCharArgv(1));
	
	/***************************************************************************/
	/**  Ouverture Des fichiers en entree et Initialisation des structures     */
	/***************************************************************************/
	
	if ( n_OpenFileAppl ( "ESFC3642B_O1","wt",&Kp_OutputFilRatio ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	/* Initialisation de la variable Kbd_Rup_TRERETFACCTR */
	if ( n_Init_RATIO(&Kbd_Rup_RATIO) ) 
		ExitPgm ( ERR_XX , "" );

	/* Lancement du traitement du fichier maitre */
	if (n_ProcessingRuptureVar(&Kbd_Rup_RATIO) == ERR) 
		ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
	
	/***************************************************************************/
	/**   Fermeture Des fichiers ouverts                                       */
	/***************************************************************************/
	if ( n_CloseFileAppl( "ESFC3642B_I1", &( Kbd_Rup_RATIO.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3642B_O1", &Kp_OutputFilRatio ) == ERR ) 
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
int n_Init_RATIO(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_Init_RATIO");
	
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

	if ( n_OpenFileAppl ("ESFC3642B_I1", "rt", &(pbd_Rupt->pf_InputFil)))
		RETURN_VAL (ERR);

	pbd_Rupt->n_NbRupture 			= 1 ;
	pbd_Rupt->n_ConditionRupture[0] = n_IsRupt_RATIO;
	pbd_Rupt->n_ActionFirst[0] 		= n_ActionFirstRupt_RATIO;
	pbd_Rupt->n_ActionLast[0]       = n_ActionLastRupt_RATIO;
	pbd_Rupt->n_ActionLigne 		= n_ActionLigne_RATIO;
	pbd_Rupt->c_Separ 				= '~' ;
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction de test de rupture du niveau 1
retour	: 	0   ---> Rupture
			1   ---> Pas de rupture
==============================================================================*/
int n_IsRupt_RATIO(char **ptb_InRec, char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_IsRupt_RATIO");
	int ret;
	
	if ( ( ret = strcmp( ptb_InRec[RNP_CTR_NF], ptb_InRec_Cur[RNP_CTR_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( ptb_InRec[RNP_SEC_NF] ) - atoi( ptb_InRec_Cur[RNP_SEC_NF] ) ) != 0 ) 	return ret;
	if ( ( ret = strcmp( ptb_InRec[RNP_UWY_NF], ptb_InRec_Cur[RNP_UWY_NF] ) ) != 0 ) 			return ret;
	if ( ( ret = atoi( ptb_InRec[RNP_UW_NT] ) - atoi( ptb_InRec_Cur[RNP_UW_NT] ) ) != 0 ) 		return ret;
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction de rupture du niveau 1
==============================================================================*/
int n_ActionFirstRupt_RATIO( char **ptb_InRec_Cur )
{
	DEBUT_FCT("n_ActionFirstRupt_RATIO");
	
	n_RuptCount = 0;
	
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
	d_FUTURE_OVERRIDE_COM	= 0.0; 
  
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction lance a fin rupture
retour 	:	0		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==============================================================================*/
int n_ActionLastRupt_RATIO( char **pbd_InRecOwner )
{
	DEBUT_FCT("n_ActionLast_RATIO");
	
	/** VARIABLE DECLARATION & INITIALISATION */
	double	EGPI_R1, 
			EGPI_R2, 
			EARP_R1;
	sprintf(COMMENT1_CF , "%s" , "");
	sprintf(COMMENT2_CF , "%s" , "");
	sprintf(COMMENT3_CF , "%s" , "");	
	
	//only when RCSUO ( Retro Contract / section / UWY / Order ) more than one
	if ( n_RuptCount > 1 ) {

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
	
	/** WRITE RETRO NP OUTPUT RATIO FILE */
	fprintf(Kp_OutputFilRatio,
			"%s~%s~%s~%s~%s~%s~%.5f~%.5f~%.5f~%.3f~%.3f~%.3f~%.3f~%.3f~%.3f~%.3f~%.3f~%.3f~%.3f~%.3f~%s \n", 
			pbd_InRecOwner[RNP_CTR_NF],
			"", //pbd_InRecOwner[RNP_END_NT], 
			pbd_InRecOwner[RNP_SEC_NF], 
			pbd_InRecOwner[RNP_UWY_NF], 
			pbd_InRecOwner[RNP_UW_NT],
			"", //pbd_InRecOwner[RNP_PLC_NT],
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
	}		
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction lance a chaque ligne PERIMETER
retour 	:	0		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==============================================================================*/
int n_ActionLigne_RATIO( char **pbd_InRecOwner )
{
	DEBUT_FCT("n_ActionLigne_RATIO");
	
	    n_RuptCount += 1;
	
		d_FUTURE_PREM_PREVQ += atof(pbd_InRecOwner[RNP_FUTURE_PREM_PREVQ]);
		d_FUTURE_PREM_Q += atof(pbd_InRecOwner[RNP_FUTURE_PREM_Q]);
		d_PREM_ESTM_PREVQ += atof(pbd_InRecOwner[RNP_PREM_ESTM_PREVQ]);
		d_PREM_ESTM += atof(pbd_InRecOwner[RNP_PREM_ESTM]);
		d_REMAIN_ESTM_PREVQ += atof(pbd_InRecOwner[RNP_REMAIN_ESTM_PREVQ]);
		d_REMAIN_ESTM += atof(pbd_InRecOwner[RNP_REMAIN_ESTM]);
		d_FIXED_CHARGE_ACT += atof(pbd_InRecOwner[RNP_FIXED_CHARGE_ACT]);
		d_ITD_PREM_ACT += atof(pbd_InRecOwner[RNP_ITD_PREM_ACT]);
		d_ITD_PREM += atof(pbd_InRecOwner[RNP_ITD_PREM]);
		d_UPR_PREVQ += atof(pbd_InRecOwner[RNP_UPR_PREVQ]);
		d_UPR_Q += atof(pbd_InRecOwner[RNP_UPR_Q]);
	
	RETURN_VAL (0);
}
