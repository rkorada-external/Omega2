/**========================================================================================
APPLICATION NAME     		: CREATION DSC/LKI
PROGRAM                 	: ESFC3693.c
REVISION                    : V1
CREATION DATE              	: 20/2020
AUTOR               		: L.ELFAHIM
-------------------------------------------------------------------------------------------
DESCRIPTION : 	SPIRA 82711
	THIS PROGRAM AIMS TO CREATE DSC/LKI && FWD/LKI FICTITIOUS
-------------------------------------------------------------------------------------------
MODIFICATION HISTORY :
   <JJ/MM/AAAA>   	<AUTOR>     <SPIRA>		<MODIFICATION DISCRIPTION>
    20/02/2020    	LEL       	82711		INITIAL VERSION DEVELOPMENT
	10/12/2020    	LEL       	90839		INVERSE SIGN DSC/LKI DAC
	25/01/2021    	LEL       	93211		ADAPT RETRO PART
	01/01/2021    	LEL       	93580		ALIGN RETRO AND ASSUMED REGARDING INPUT FILES
	25/10/2021    	LEL       	98214		IFRS17 LOCAL- ACCRET_CF (R/RI) INCORRECT
	02/06/2022    	HR       	102733          REQ 11.02 - IFRS17 - No future maintenance expenses calculated at subsequent measurement
=========================================================================================*/

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

int  is_TRT(char *);

/**-------------------------------------------------
	Treatement of main program         
----------------------------------------------------*/
int main( int argc,  char *argv[] )
{
	InitSig ();

	if (n_BeginPgm (argc, argv) == ERR)
		ExitPgm (ERR_XX, "");
	
	strcpy( Norme_CF, psz_GetCharArgv(1) );
	strcpy( Ksz_CloDat, psz_GetCharArgv(2) ) ;
	strcpy( Blcshyear, psz_GetCharArgv(3) ) ;
	
	/** Eclatement de la date AAAAMMJJ en 3 chaines de caractere */
	sscanf( Ksz_CloDat, "%4s%2s%2s", Ksz_Annee_bilan, Ksz_Mois_bilan, Ksz_Jour_bilan ) ;
	
	/***************************************************************************/
	/**  Ouverture Des fichiers en entree et Initialisation des structures     */
	/***************************************************************************/
	/** ouverture du fichier binaire en entree des correspondances retro vs acceptation */
	if ( n_OpenFileAppl ( "ESFC3693_I3", "rb", &Kp_InputFilSsdActr ) == ERR )
		ExitPgm( ERR_XX , "" ) ;
	
	/** chargement de la table TSSDACTR */
	Kn_SsdActr_Nbp = n_ChargerSSDACTR( ) ;
	if ( Kn_SsdActr_Nbp >= MAX_SSDACTR )
		ExitPgm( ERR_XX , "Taille du tableau TSSDACTR insuffisante " );
	
	if ( n_OpenFileAppl ( "ESFC3693_O1","wt",&Kp_OutputFil_DAC_LKI ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	/** Ouverture du fichier en entree des cours de change FCURQUOT */
	if ( n_OpenFileAppl ( "ESFC3693_I2","rb",&Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	/** Initialisation de la variable Kbd_Rup_DAC_CREATION */
	if ( n_Init_DAC_CREATION(&Kbd_Rup_DAC_CREATION) ) 
		ExitPgm ( ERR_XX , "" );
	
	/** Lancement du traitement du fichier maitre */
	if (n_ProcessingRuptureVar(&Kbd_Rup_DAC_CREATION) == ERR) 
		ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
	
	/***************************************************************************/
	/**   Fermeture Des fichiers ouverts                                       */
	/***************************************************************************/
	if ( n_CloseFileAppl( "ESFC3693_I1", &( Kbd_Rup_DAC_CREATION.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3693_I2", &Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESFC3693_I3", &Kp_InputFilSsdActr ) == ERR )
    ExitPgm( ERR_XX , "" ) ;
	
	if ( n_CloseFileAppl( "ESFC3693_O1", &Kp_OutputFil_DAC_LKI ) == ERR ) 
		ExitPgm( ERR_XX , "" );

	if ( n_EndPgm () == ERR )
		ExitPgm (ERR_XX, "");
	
	exit(0);
}

/**=======================================================================
objet : Fonction de rupture du fichier principal :
retour 	:	0  	---> traitement correctement effectue
			ERR ---> probleme rencontre
=========================================================================*/
int n_Init_DAC_CREATION(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_Init_DAC_CREATION");
	
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

	if ( n_OpenFileAppl ("ESFC3693_I1", "rt", &(pbd_Rupt->pf_InputFil)))
		RETURN_VAL (ERR);

	pbd_Rupt->n_NbRupture 			= 1 ;
	pbd_Rupt->n_ActionLigne 		= n_ActionLigne_DAC_CREATION ;
	pbd_Rupt->n_ActionLast[0] 		= n_ActionLasrRupt_DAC_CREATION;
	pbd_Rupt->n_ActionFirst[0] 		= n_ActionFirstRupt_DAC_CREATION;
	pbd_Rupt->n_ConditionRupture[0] = n_IsRupt_DAC_CREATION;
	pbd_Rupt->c_Separ 				= '~';
	
	RETURN_VAL (0);
}

	
/**=======================================================================
objet 	: Fonction de test de rupture du niveau 1 :
retour	: 	0   ---> Rupture
			1   ---> Pas de rupture
=========================================================================*/
int n_IsRupt_DAC_CREATION(char **ptb_InRec, char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_IsRupt_DAC_CREATION");
	
	if ( strcmp(ptb_InRec[CML_CTR_NF], ptb_InRec_Cur[CML_CTR_NF]) !=0 ) 			return(1);
	if ( atoi( ptb_InRec[CML_END_NT]) - atoi(ptb_InRec_Cur[CML_END_NT]) != 0 ) 		return(1);
	if ( atoi( ptb_InRec[CML_SEC_NF]) - atoi(ptb_InRec_Cur[CML_SEC_NF]) != 0 ) 		return(1);	
	if ( strcmp(ptb_InRec[CML_UWY_NF], ptb_InRec_Cur[CML_UWY_NF]) !=0 ) 			return(1);
	if ( atoi( ptb_InRec[CML_UW_NT]) - atoi(ptb_InRec_Cur[CML_UW_NT]) != 0 ) 		return(1);	
	if ( strcmp( ptb_InRec[CML_RETCTR_NF],ptb_InRec_Cur[CML_RETCTR_NF] )  != 0 ) 	return(1);
	if ( atoi(ptb_InRec[CML_RETEND_NT]) - atoi(ptb_InRec_Cur[CML_RETEND_NT]) != 0 )	return(1);
	if ( atoi( ptb_InRec[CML_RETSEC_NF]) - atoi(ptb_InRec_Cur[CML_RETSEC_NF]) != 0)	return(1);
	if ( strcmp( ptb_InRec[CML_RTY_NF], ptb_InRec_Cur[CML_RTY_NF] ) != 0 ) 			return(1);
	if ( atoi( ptb_InRec[CML_RETUW_NT]) - atoi(ptb_InRec_Cur[CML_RETUW_NT] ) != 0 )	return(1);
	if ( atoi( ptb_InRec[CML_PLC_NT]) - atoi( ptb_InRec_Cur[CML_PLC_NT] ) != 0 ) 	return(1);
	if ( strcmp(ptb_InRec[TRN_CODE], ptb_InRec_Cur[TRN_CODE])  !=0 ) 				return(1);	
	
	RETURN_VAL (0);
}

/**=======================================================================
objet 	: Fonction lancee a chaque rupture premiere sur CSUOE + PATTYP_CT 
retour 	:	0  		---> traitement correctement effectue
			ERR 	---> probleme rencontre
=========================================================================*/
int n_ActionFirstRupt_DAC_CREATION ( char **ptb_InRec_Cur )
{
	DEBUT_FCT("n_ActionFirstRupt_DAC_CREATION");	
	
	d_DAC_AMT	= 0.0;
	
	RETURN_VAL(0);
}

/**=======================================================================
objet 	: Fonction lancee a chaque rupture premiere sur CSUOE + PATTYP_CT 
retour 	:	0  		---> traitement correctement effectue
			ERR 	---> probleme rencontre
=========================================================================*/
int n_ActionLigne_DAC_CREATION ( char **ptb_InRec_Cur )
{
	DEBUT_FCT("n_ActionLigne_DAC_CREATION"); 		
	
	double 	d_taux = 1;
	char 	MsgAno[150];
	
	if ( strncmp(ptb_InRec_Cur[CML_TRNCOD_CF], "1",  1) == 0 )
	{
		if ( strcmp( ptb_InRec_Cur[EGPICUR_CF], ptb_InRec_Cur[GTSII_ACMCUR_CF] ) != 0 )
		{	
			d_taux = d_GetTaux( Kp_InputFilExc, 
								(char) atoi( ptb_InRec_Cur[GT_SSD_CF] ), 
								atoi(Blcshyear), //atoi( ptb_InRec_Cur[GT_BALSHEY_NF] ), 
								ptb_InRec_Cur[GTSII_ACMCUR_CF], 
								ptb_InRec_Cur[EGPICUR_CF] 
								);
			if ( d_taux < 0 )
			{
				sprintf( MsgAno, "No rate for :( CTR %s - END %s - SEC %s - UWY %s - UW %s )\n", 
						ptb_InRec_Cur[GT_CTR_NF],  
						ptb_InRec_Cur[GT_END_NT], 
						ptb_InRec_Cur[GT_SEC_NF], 
						ptb_InRec_Cur[GT_UWY_NF], 
						ptb_InRec_Cur[GT_UW_NT] 
						);
				
				n_WriteAno( MsgAno );
				d_taux 	= 1;	
			}
		}
		d_DAC_AMT += atof( ptb_InRec_Cur[GTSII_ACMAMT_MC] )* d_taux;
		RETURN_VAL(0);
	}
	if ( strncmp(ptb_InRec_Cur[CML_TRNCOD_CF], "2",  1) == 0 )
	{
		if ( strcmp( ptb_InRec_Cur[EGPICUR_CF], ptb_InRec_Cur[GTSII_ACMCUR_CF] ) != 0 )
		{	
			d_taux = d_GetTaux( Kp_InputFilExc, 
								(char) atoi( ptb_InRec_Cur[GT_SSD_CF] ), 
								atoi(Blcshyear), //atoi( ptb_InRec_Cur[GT_BALSHEY_NF] ), 
								ptb_InRec_Cur[GTSII_ACMCUR_CF], 
								ptb_InRec_Cur[EGPICUR_CF] 
								);
			if ( d_taux < 0 )
			{
				sprintf( MsgAno, "No rate for :( CTR %s - END %s - SEC %s - UWY %s - UW %s )\n", 
						ptb_InRec_Cur[GT_RETCTR_NF],  
						ptb_InRec_Cur[GT_RETEND_NT],
						ptb_InRec_Cur[GT_RETSEC_NF], 
						ptb_InRec_Cur[GT_RTY_NF], 
						ptb_InRec_Cur[GT_RETUW_NT]
						);
				
				n_WriteAno( MsgAno );
				d_taux 	= 1;	
			}
		}
		d_DAC_AMT += atof( ptb_InRec_Cur[GTSII_ACMAMT_MC] )* d_taux;
	}
	RETURN_VAL(0);
}

/**=======================================================================
objet 	: Fonction lancee a chaque rupture premiere sur CSUOE + PATTYP_CT
retour 	:	0  		---> traitement correctement effectue
			ERR 	---> probleme rencontre
=========================================================================*/
int n_ActionLasrRupt_DAC_CREATION ( char **ptb_InRec_Cur )
{
	DEBUT_FCT("n_ActionLasrRupt_DAC_CREATION \n");
	
	int j, i;
	char amount[AMN_LEN];
	
	memset(amount,0, sizeof(amount));    
	sprintf(amount , "%.3f" , (-1) * d_DAC_AMT );
	
	if((*ptb_InRec_Cur[CML_TRNCOD_CF] == '1') || (*ptb_InRec_Cur[CML_TRNCOD_CF] == '3'))
	{
		if( *ptb_InRec_Cur[CTRRET_B] == '1' )
			ptb_InRec_Cur[CML_TYP_CT] 	= "AI";
		else
			ptb_InRec_Cur[CML_TYP_CT] 	= "A";
		
		ptb_InRec_Cur[CML_CUR_CF] 		= ptb_InRec_Cur[EGPICUR_CF];
		ptb_InRec_Cur[CML_AMT_MC] 		= amount;
		ptb_InRec_Cur[CML_RETCUR_CF] 	= ptb_InRec_Cur[EGPICUR_CF];
		ptb_InRec_Cur[CML_RETAMT_MC] 	= "0.0";
	}
	else
	{
		/** SEARCH RETRO CONTRACT WITHIN TABLE BRET..TSSDACTR */
		i = n_RechercheSSDACTR( ptb_InRec_Cur[GT_RETCTR_NF], atoi(ptb_InRec_Cur[GT_RTY_NF]),
								atol(ptb_InRec_Cur[GT_PLC_NT]),(char) atoi(ptb_InRec_Cur[GT_RETSEC_NF]));
								
		/** IF i = -1 THEN RETRO CONTRACT NOT FOUND WITHIN TABLE BRET..TSSDACTR */
		if ( i != -1  && *ptb_InRec_Cur[SSDRTO_B] == '1' )
			ptb_InRec_Cur[CML_TYP_CT] 	= "RI";
		else
			ptb_InRec_Cur[CML_TYP_CT] 	= "R";
		
		ptb_InRec_Cur[CML_CUR_CF] 		= ptb_InRec_Cur[EGPICUR_CF];
		ptb_InRec_Cur[CML_AMT_MC] 		= "0.0";
		ptb_InRec_Cur[CML_RETCUR_CF] 	= ptb_InRec_Cur[EGPICUR_CF];
		ptb_InRec_Cur[CML_RETAMT_MC] 	= amount;
	}
	
	if (is_TRT(ptb_InRec_Cur[GT_CTR_NF]) == 0)
		ptb_InRec_Cur[CML_NAT_CF] 	= "F";
	else
	{
		if (atoi(ptb_InRec_Cur[RET_NAT_CF]) < 30 ) 
			ptb_InRec_Cur[CML_NAT_CF] = "P";
		else 
			ptb_InRec_Cur[CML_NAT_CF] = "N";
	}
	ptb_InRec_Cur[CML_SEG_NF] 			= ptb_InRec_Cur[SEGMENT];
	ptb_InRec_Cur[CML_LOB_CF] 			= ptb_InRec_Cur[LINE_OF_BUSINESS];
	ptb_InRec_Cur[CML_OCCYEA_NF] 		= Ksz_Annee_bilan;
	ptb_InRec_Cur[CML_ACY_NF] 			= Ksz_Annee_bilan;
	ptb_InRec_Cur[CML_CLM_NF] 			= "";
	ptb_InRec_Cur[CML_RATING_CF] 		= "";
	ptb_InRec_Cur[CML_PATTERN_ID] 		= "";
	ptb_InRec_Cur[CML_COEF_LOB] 		= "";
	ptb_InRec_Cur[CML_DSCCUR_CF] 		= "";
	ptb_InRec_Cur[CML_COMMENT] 			= "";
	ptb_InRec_Cur[CML_ACMTRS_NT] 		= "203"; 
	ptb_InRec_Cur[CML_PRS_CF] 			= "751";
	ptb_InRec_Cur[CML_ACMAMT_MC] 		= amount;
	ptb_InRec_Cur[CML_ACMCUR_CF] 		= ptb_InRec_Cur[EGPICUR_CF];
	ptb_InRec_Cur[CML_AN1] 				= amount;
	ptb_InRec_Cur[CML_TOTAUX_MC] 		= amount;
	ptb_InRec_Cur[CML_NORME_CF] 		= Norme_CF;
	ptb_InRec_Cur[CML_BALSHRMTH_NF] 	= Ksz_Mois_bilan;
	ptb_InRec_Cur[CML_BALSHRDAY_NF] 	= Ksz_Jour_bilan;
	ptb_InRec_Cur[CML_BALSHEY_NF] 		= Ksz_Annee_bilan;
	ptb_InRec_Cur[CML_ACMTRS3_NT2] 		= ptb_InRec_Cur[TRN_CODE]; 
	ptb_InRec_Cur[CML_PATCAT_CT] 		= "DSC";
	for( j = CML_AN2; j<= CML_AM_FIN; ++j )   
	{
		ptb_InRec_Cur[j]				= "0.0";
	}
	ptb_InRec_Cur[CML_PATTYP_CT] 		= "LKI";
	n_WriteCols(Kp_OutputFil_DAC_LKI,  ptb_InRec_Cur, '~', 0);
	
	RETURN_VAL(0);
}

/**=======================================================================
	Renvoi 1 si TRT, 0 si FAC, -1 si pas une lettre !
=========================================================================*/
int is_TRT(char *contract)
{ 
	char thirdCar;
	thirdCar = toupper(contract[2]);

	char firstCar;
	firstCar = toupper(contract[0]);

	if(( thirdCar >= 'A' && thirdCar <= 'M') || firstCar == 'F') // FAC 
		return 0; 

	if(( thirdCar >= 'N' && thirdCar <= 'Z') || firstCar == 'T')  // TREATY
		return 1; 

	if( firstCar == 'R')  // RETRO
		return 2; 	
	
	return -1; 
}

/**=========================================================================
	Fonction de chargement du fichier binaire des correspondances retro vers
	acceptation:
	retour :  le nombre rows charges dans le tableau
============================================================================*/
int n_ChargerSSDACTR( void )
{
	DEBUT_FCT( "n_ChargerSSDACTR" ) ;

	RETURN_VAL( fread(Ktbd_SsdActr, sizeof( S_SSDACTR ), MAX_SSDACTR, Kp_InputFilSsdActr ));
}

/**=========================================================================
	Fonction de recherche des correspondances retro vers acceptation
	retour :  	le numero de poste dans le tableau si la fonction a trouve
				sinon -1
============================================================================*/
int n_RechercheSSDACTR( char *RetCtr, short Rty, long Plc, unsigned char RetSec )
{
	int i, ret1, ret2, ret3, ret4;

	for ( i = 0; i < Kn_SsdActr_Nbp; i++ )
	{
		ret1 = strcmp( RetCtr, Ktbd_SsdActr[i].RETCTR_NF );
		if ( ret1 == 0 )
		{
			ret2 = Rty - Ktbd_SsdActr[i].RTY_NF;
			if ( ret2 == 0 )
			{
				ret3 = Plc - Ktbd_SsdActr[i].PLACMENT_NT;
				if ( ret3 == 0 )
				{
					ret4 = RetSec - Ktbd_SsdActr[i].RETSEC_NF;
					if ( ret4 == 0 )
						return ( i );
					else if ( ret4 < 0 ) return ( -1 );
				}
				else if ( ret3 < 0 ) return ( -1 );
			}
			else if ( ret2 < 0 ) return ( -1 );
		}
		else if ( ret1 < 0 ) return ( -1 );
	}
	return ( -1 );
}
