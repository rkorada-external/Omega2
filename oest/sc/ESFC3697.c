/**====================================================================================
APPLICATION NAME     		: FWD/LKI FICTITIOUS CALCULATION
PROGRAM                 	: ESFC3697.c
REVISION                    : V1
CREATION DATE              	: 12/2020
AUTOR               		: L.ELFAHIM
---------------------------------------------------------------------------------------
DESCRIPTION : 	SPIRA 82711
	THIS PROGRAM AIMS TO CREATE FWD/LKI FICTITIOUS
---------------------------------------------------------------------------------------
MODIFICATION HISTORY :
<JJ/MM/AAAA>   	<AUTOR>     <SPIRA>		<modification DISCRIPTION>
14/12/2020    	LEL       	90648		INITIAL VERSION DEVELOPMENT
13/01/2021    	LEL       	92977		ADD RETRO DAC/FWD
22/11/2021    	MiS       	100384		REQ 11.06 - IFRS 17 - DAC Q-1 not taken into account to form DSCxFWD
27/04/2022    	DAD       	102857		fix bug change prev_CloDat to cloDat for DAC/FWD creation
======================================================================================*/

/**----------------------------------------------------
	Import header files and libraries
-------------------------------------------------------*/
#include <utctlib.h>
#include <estserv.h>
#include <stdarg.h>
#include <util.h>
#include "struct.h"
#include <string.h>
#include "ESFC3640.h" 

/**-------------------------------------------------
	Treatement of main program         
----------------------------------------------------*/
int main( int argc,  char *argv[] )
{
	InitSig ();

	if (n_BeginPgm (argc, argv) == ERR)
		ExitPgm (ERR_XX, "");
	
	strcpy( Ksz_Prev_CloDat, psz_GetCharArgv(1) ) ;
	strcpy( Ksz_CloDat, psz_GetCharArgv(2) );

	sprintf(Ksz_Annee_bilan, "%.4s", Ksz_CloDat);
  	sprintf(Ksz_Mois_bilan, "%.2s", &Ksz_CloDat[4]);
  	sprintf(Ksz_Jour_bilan, "%.2s", &Ksz_CloDat[6]);
	
	/***************************************************************************/
	/**  Ouverture Des fichiers en entree et Initialisation des structures     */
	/***************************************************************************/
	if ( n_OpenFileAppl ( "ESFC3697_O1","wt",&Kp_OutputFil_DAC_FWD ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	/* Initialisation de la variable Kbd_Rup_DAC_CREATION */
	if ( n_Init_DAC_CREATION(&Kbd_Rup_DAC_CREATION) ) 
		ExitPgm ( ERR_XX , "" );
	
	/* Lancement du traitement du fichier maitre */
	if (n_ProcessingRuptureVar(&Kbd_Rup_DAC_CREATION) == ERR) 
		ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
	
	/***************************************************************************/
	/**   Fermeture Des fichiers ouverts                                       */
	/***************************************************************************/
	if ( n_CloseFileAppl( "ESFC3697_I1", &( Kbd_Rup_DAC_CREATION.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3697_O1", &Kp_OutputFil_DAC_FWD ) == ERR ) 
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
int n_Init_DAC_CREATION(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_Init_DAC_CREATION");
	
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

	if ( n_OpenFileAppl ("ESFC3697_I1", "rt", &(pbd_Rupt->pf_InputFil)))
		RETURN_VAL (ERR);

	pbd_Rupt->n_NbRupture 			= 0 ;
	pbd_Rupt->n_ActionLigne 		= n_ActionLigne_DAC_CREATION ;
	pbd_Rupt->c_Separ 				= '~';
	
	RETURN_VAL (0);
}

/**===========================================================================
objet 	: Fonction lancee a chaque rupture premiere sur CSUOE + PATTYP_CT
retour 	:	0  		---> traitement correctement effectue
			ERR 	---> probleme rencontre
==============================================================================*/
int n_ActionLigne_DAC_CREATION ( char **ptb_InRec_Cur )
{
	DEBUT_FCT("n_ActionLigne_DAC_CREATION"); 
	
	char amount[AMN_LEN];
	memset(amount,0, sizeof(amount));
	
	//if( strcmp(ptb_InRec_Cur[GT_CTR_NF],"TR0046143") == 0 && strcmp(ptb_InRec_Cur[GT_RETCTR_NF],"RP0002074") == 0 && strcmp(ptb_InRec_Cur[36],"54222") == 0 )

	ptb_InRec_Cur[CML_BALSHEY_NF] = Ksz_Annee_bilan;
  	ptb_InRec_Cur[CML_BALSHRMTH_NF] = Ksz_Mois_bilan;
  	ptb_InRec_Cur[CML_BALSHRDAY_NF] = Ksz_Jour_bilan;

	ptb_InRec_Cur[CML_OCCYEA_NF] = Ksz_Annee_bilan;
	ptb_InRec_Cur[CML_ACY_NF] = Ksz_Annee_bilan;
  	ptb_InRec_Cur[CML_SCOSTRMTH_NF] = Ksz_Mois_bilan;
  	ptb_InRec_Cur[CML_SCOENDMTH_NF] = Ksz_Mois_bilan;

	ptb_InRec_Cur[CML_RETOCCYEA_NF] = Ksz_Annee_bilan;
	ptb_InRec_Cur[CML_RETACY_NF] = Ksz_Annee_bilan;
  	ptb_InRec_Cur[CML_RETSCOSTRMTH_NF] = Ksz_Mois_bilan;
  	ptb_InRec_Cur[CML_RETSCOENDMTH_NF] = Ksz_Mois_bilan;

	if( *ptb_InRec_Cur[GT_GRPINISTS_CT] == '2' && atoi(ptb_InRec_Cur[GT_GRPFIRCLO_D]) <= atoi(Ksz_Prev_CloDat) && fabs(atof(ptb_InRec_Cur[INITIAL_AMNT])) > 0 ) 
	{
		sprintf(amount , "%.3f" , atof(ptb_InRec_Cur[INITIAL_AMNT]));
		ptb_InRec_Cur[CML_AN1] 			= amount;
		ptb_InRec_Cur[CML_ACMAMT_MC] 	= amount;
		ptb_InRec_Cur[CML_TOTAUX_MC] 	= amount;
		ptb_InRec_Cur[CML_PATTYP_CT] 	= "FWD";
		
		ptb_InRec_Cur[124] = 0;
		n_WriteCols(Kp_OutputFil_DAC_FWD,  ptb_InRec_Cur, '~', 0);
	}
	else
	{		
		ptb_InRec_Cur[CML_AN1] 			= "0.0";
		ptb_InRec_Cur[CML_ACMAMT_MC] 	= "0.0";
		ptb_InRec_Cur[CML_TOTAUX_MC] 	= "0.0";
		ptb_InRec_Cur[CML_PATTYP_CT] 	= "FWD";
		
		ptb_InRec_Cur[124] = 0;
		n_WriteCols(Kp_OutputFil_DAC_FWD,  ptb_InRec_Cur, '~', 0);	
	}	
		
	RETURN_VAL(0);
}