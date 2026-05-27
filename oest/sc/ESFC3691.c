/*===========================================================================================
Nom de l'application          : CSM EGPII/EARNE  CALCULATION
Nom du source                 : ESFC3691.c
Revision                      : V1
Date de creation              : 07/2019
Auteur                        : L.ELFAHIM
Squelette de base             : Batch
References des specifications : 
---------------------------------------------------------------------------------------------
DESCRIPTION :
	Ce programme est destine a faire le calcul de CSM EGPII/EARNE

---------------------------------------------------------------------------------------------
HISTORIQUE DES MODIFICATIONS :
   <jj/mm/aaaa>   	<auteur>     	<SPIRA>		<description de la modification>
    17/07/2019    	L.ELFAHIM       79845		Developpement de la version initiale*
    18/10/2019    	L.ELFAHIM       79845    	RETRO NP key : CSUOE + placement
=============================================================================================*/

/**----------------------------------------------------
	Import header files and libraries
-------------------------------------------------------*/
#include <utctlib.h>
#include <estserv.h>
#include <stdarg.h>
#include <util.h>
#include "struct.h"
#include <string.h>
#include "ESFC3690.h" 

/**-------------------------------------------------
	Treatement of main program         
----------------------------------------------------*/
int main( int argc,  char *argv[] )
{
	InitSig ();

	if (n_BeginPgm (argc, argv) == ERR)
		ExitPgm (ERR_XX, "");
	
	/***************************************************************************/
	/**  Ouverture Des fichiers en entree et Initialisation des structures     */
	/***************************************************************************/
	
	if ( n_OpenFileAppl ( "ESFC3691_O1","wt",&Kp_OutputFil_CSM ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	/* Initialisation de la variable Kbd_Rup_CSM_CALCUL */
	if ( n_Init_CSM_CALCULATION(&Kbd_Rup_CSM_CALCUL) ) 
		ExitPgm ( ERR_XX , "" );
	
	/* Lancement du traitement du fichier maitre */
	if (n_ProcessingRuptureVar(&Kbd_Rup_CSM_CALCUL) == ERR) 
		ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
	
	/***************************************************************************/
	/**   Fermeture Des fichiers ouverts                                       */
	/***************************************************************************/
	if ( n_CloseFileAppl( "ESFC3691_I1", &( Kbd_Rup_CSM_CALCUL.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3691_O1", &Kp_OutputFil_CSM ) == ERR ) 
		ExitPgm( ERR_XX , "" );

	if ( n_EndPgm () == ERR )
		ExitPgm (ERR_XX, "");
	
	exit(0);
}

/**===============================================================================
objet : Fonction d'initialisation de la variable de rupture du fichier principal.
retour 	:	0  		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==================================================================================*/
int n_Init_CSM_CALCULATION(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_Init_CSM_CALCULATION");
	
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

	if ( n_OpenFileAppl ("ESFC3691_I1", "rt", &(pbd_Rupt->pf_InputFil)))
		RETURN_VAL (ERR);

	pbd_Rupt->n_NbRupture 			= 1 ;
	pbd_Rupt->n_ConditionRupture[0] = n_IsRupt_CSM_CALCUL;
	pbd_Rupt->n_ActionFirst[0] 		= n_ActionFirstRupt_CSM_CALCUL;
	pbd_Rupt->n_ActionLigne 		= n_ActionLigne_CSM_CALCUL ;
	pbd_Rupt->n_ActionLast[0] 		= n_ActionLasrRupt_CSM_CALCUL;
	pbd_Rupt->c_Separ 				= '~' ;

	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction de test de rupture du niveau 1
retour	: 	0   ---> Rupture
			1   ---> Pas de rupture
==============================================================================*/
int n_IsRupt_CSM_CALCUL(char **ptb_InRec, char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_IsRupt_CSM_CALCUL");
	
	/*** Key to manage Accept Contracts  ***/
	if ( strcmp(ptb_InRec[CML_CTR_NF], ptb_InRec_Cur[CML_CTR_NF]) !=0 ) 		return(1);
	if ( strcmp(ptb_InRec[CML_END_NT], ptb_InRec_Cur[CML_END_NT]) !=0 ) 		return(1);   
	if ( strcmp(ptb_InRec[CML_SEC_NF], ptb_InRec_Cur[CML_SEC_NF]) !=0 ) 		return(1);
	if ( strcmp(ptb_InRec[CML_UWY_NF], ptb_InRec_Cur[CML_UWY_NF]) !=0 ) 		return(1);
	if ( strcmp(ptb_InRec[CML_UW_NT],  ptb_InRec_Cur[CML_UW_NT])  !=0 ) 		return(1);
	if ( strcmp(ptb_InRec[CML_RETCTR_NF], ptb_InRec_Cur[CML_RETCTR_NF]) !=0 ) 	return(1);
	if ( strcmp(ptb_InRec[CML_RETEND_NT], ptb_InRec_Cur[CML_RETEND_NT]) !=0 ) 	return(1);   
	if ( strcmp(ptb_InRec[CML_RETSEC_NF], ptb_InRec_Cur[CML_RETSEC_NF]) !=0 ) 	return(1);
	if ( strcmp(ptb_InRec[CML_RTY_NF], ptb_InRec_Cur[CML_RTY_NF]) !=0) 			return(1);
	if ( strcmp(ptb_InRec[CML_RETUW_NT], ptb_InRec_Cur[CML_RETUW_NT]) !=0 ) 	return(1);
	if ( strcmp(ptb_InRec[CML_PLC_NT], ptb_InRec_Cur[CML_PLC_NT]) !=0 ) 		return(1);
	if ( strcmp(ptb_InRec[CML_ACMCUR_CF], ptb_InRec_Cur[CML_ACMCUR_CF]) !=0 ) 	return(1);				
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction lancee a chaque rupture premiere sur CSUOE + PATTYP_CT 
retour 	:	0  		--> traitement correctement effectue
			ERR 	---> probleme rencontre
==============================================================================*/
int n_ActionFirstRupt_CSM_CALCUL ( char **ptb_InRec_Cur )
{
	DEBUT_FCT("n_ActionFirstRupt_CSM_CALCUL");
		
	int 	j;
		
	/* Initialisation of global variables for aggregation */
	d_ACMAMT_EGPPI	= 0.0;
	d_TOTAUX_EGPPI	= 0.0;
	d_ACMAMT_EARNE 	= 0.0;
	d_TOTAUX_EARNE	= 0.0;
	
	/* Initialisation of ank year amounts */
	for( j = 0; j<= 65; ++j )   
	{
		Ksz_Tab_EGPPI[j]= 0.0;
	}
	for( j = 0; j<= 65; ++j )   
	{
		Ksz_Tab_EARNE[j]= 0.0;
	}
	
	RETURN_VAL(0);
}

/**===========================================================================
objet 	: Fonction lancee a chaque rupture premiere sur CSUOE + PATTYP_CT
retour 	:	0  		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==============================================================================*/
int n_ActionLigne_CSM_CALCUL ( char **ptb_InRec_Cur )
{
	DEBUT_FCT("n_ActionLigne_CSM_CALCUL"); 		
	int 	j;
		
	strncpy(Ksz_PATTYP, ptb_InRec_Cur[CML_PATTYP_CT], 3);
	
	if( strcmp(ptb_InRec_Cur[CML_PATCAT_CT],"EXP") == 0 && strcmp(Ksz_PATTYP,"EGP") == 0 )  
	{
		d_ACMAMT_EGPPI += atof( ptb_InRec_Cur[CML_ACMAMT_MC] );
		d_TOTAUX_EGPPI += atof( ptb_InRec_Cur[CML_TOTAUX_MC] );
		
		/* Initialisation of ank amount year */
		for( j = 0; j<= 65; ++j )   
		{
			Ksz_Tab_EGPPI[j] += atof( ptb_InRec_Cur[j + AN1_56] );
		}
	}
	else if ( strcmp(ptb_InRec_Cur[CML_PATCAT_CT],"EXP") == 0 && strcmp(Ksz_PATTYP,"EAR") == 0)
	{
		d_ACMAMT_EARNE += atof( ptb_InRec_Cur[CML_ACMAMT_MC] );
		d_TOTAUX_EARNE += atof( ptb_InRec_Cur[CML_TOTAUX_MC] );
		
		/* Initialisation of ank amount year */
		for( j = 0; j<= 65; ++j )   
		{
			Ksz_Tab_EARNE[j] += atof( ptb_InRec_Cur[j + AN1_56] );
		}
	}
	
	RETURN_VAL(0);
}

/**===========================================================================
objet 	: Fonction lancee a chaque rupture premiere sur CSUOE + PATTYP_CT
retour 	:	0  		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==============================================================================*/
int n_ActionLasrRupt_CSM_CALCUL ( char **ptb_InRec_Cur )
{
	DEBUT_FCT("n_ActionLasrRupt_CSM_CALCUL \n");
	
	int j;
	char amount[AMN_LEN], ank_mnt[65][AMN_LEN], total_mnt[AMN_LEN];
	
	memset(amount,0, sizeof(amount));
	memset(total_mnt,0, sizeof(total_mnt));
		
	/* To take into account only IFRS17 revenue lines calculated before */
	if( strcmp(ptb_InRec_Cur[CML_PATCAT_CT],"EXP") == 0 )
	{
		/**  P&L post EGPI calculation  **/
		/* Calculation of the CSM for ACMAMT_MC */
		sprintf(amount , "%.3f" , d_ACMAMT_EGPPI );
		ptb_InRec_Cur[CML_ACMAMT_MC] = amount; 
		
		/* Calculation of the CSM for TOTAL_AMOUNT */
		sprintf(total_mnt , "%.3f" , d_TOTAUX_EGPPI );
		ptb_InRec_Cur[CML_TOTAUX_MC] = total_mnt;
		
		/* Calculation of the CSM for ANk YEAR */
		for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
		{
			sprintf(ank_mnt [j-CML_AN1] , "%.3f" , Ksz_Tab_EGPPI[j - AN1_56] );
			ptb_InRec_Cur[j] = ank_mnt [j-CML_AN1]; 
		}	
		ptb_InRec_Cur[CML_PATCAT_CT] 	= "CSM";
		ptb_InRec_Cur[CML_PATTYP_CT] 	= "EGPPI";
		ptb_InRec_Cur[CML_ACMTRS3_NT2]  = "3330";
		ptb_InRec_Cur[CML_ACMTRS_NT]   	= "170";
		ptb_InRec_Cur[CML_COMMENT]   	= "";
	
		n_WriteCols(Kp_OutputFil_CSM,  ptb_InRec_Cur, '~', 0);
		
		/**  P&L post EARNE calculation  **/
		/* Calculation of the CSM for ACMAMT_MC  */
		sprintf(amount , "%.3f" , d_ACMAMT_EARNE );
		ptb_InRec_Cur[CML_ACMAMT_MC] = amount; 
		
		/* Calculation of the CSM for TOTAL_AMOUNT */
		sprintf(total_mnt , "%.3f" , d_TOTAUX_EARNE );
		ptb_InRec_Cur[CML_TOTAUX_MC] = total_mnt;
		
		/* Calculation of the CSM for ANk YEAR  */
		for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
		{
			sprintf(ank_mnt [j-CML_AN1] , "%.3f" , Ksz_Tab_EARNE[j - 54] );
			ptb_InRec_Cur[j] = ank_mnt [j-CML_AN1]; 
		}
		ptb_InRec_Cur[CML_PATCAT_CT] 	= "CSM";
		ptb_InRec_Cur[CML_PATTYP_CT] 	= "EARNE";
		ptb_InRec_Cur[CML_ACMTRS3_NT2] 	= "3330";
		ptb_InRec_Cur[CML_ACMTRS_NT]   	= "170";
		ptb_InRec_Cur[CML_COMMENT] 		= "";
		
		n_WriteCols(Kp_OutputFil_CSM,  ptb_InRec_Cur, '~', 0);
	}
	
	RETURN_VAL(0);
}