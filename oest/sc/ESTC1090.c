/*=====================================================================================================
Nom de l'application          : Maintenance Expenses Calculation
Nom du source                 : ESTC1090.c
Revision                      : V1
Date de creation              : 03/2019
Auteur                        : L.ELFAHIM
Squelette de base             : Batch
References des specifications : 
--------------------------------------------------------------------------------------------------------
Description :
	Ce programme manipule plusieurs fichiers en entree pour gerer :
	Maintenance Expenses Calculations
-------------------------------------------------------------------------------------------------------
Historique des modifications :
	<jj/mm/aaaa>   	<auteur>    <SPIRA>		<description de la modification>
	20/02/2019 		L.ELFAHIM	71570		Developpement de la version initiale
	24/07/2019		L.ELFAHIM	79992		Filtres et Jointures des fichiers
	10/09/2019		L.ELFAHIM	79992		Gerer la date du bilan
	25/09/2019		L.ELFAHIM	79992		Ajouter fichier gestion des anomalies   
========================================================================================================*/

/**--------------------------------------------------
 Inclusion des interfaces des composants importes 
--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <util.h>
#include <stdarg.h>
#include "estserv.h"
#include "estutil.c"
#include "ESTC1090.h"
#include "ESTC3001.h"   /* Fichier commun avec des autres programmes contenant la structure du fichier GTSII_CASHFLOW */


/**===========================================================================
 Objet 		: 	Point d'entree du programme                                               									
 Nom 		: 	main     						
 Parametres	: 	int argc    : Nombre d'arguments sur la ligne de commande;
				char **argv : parametres										
 Retour		:								
				En cas de probleme, sortie par ExitPgm(ERRCODE)
				sinon appel systeme exit(OK)						
=============================================================================*/
int main( int argc, char **argv )
{
	pbd_Rupture = malloc(sizeof(T_RUPTURE_VAR));
	pbd_Sync = malloc(sizeof(T_RUPTURE_SYNC_VAR));

	/** Initialisation des signaux */
	InitSig () ;

	if (n_BeginPgm(argc, argv) == ERR) 
		ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_BeginPGM.");
	
	/** Recuperation des parametres */
	strcpy( Norme_CF, psz_GetCharArgv(1) ) ;
	strcpy( Ksz_CloDat, psz_GetCharArgv(2) ) ;
	
	/** Eclatement de la date AAAAMMJJ en 3 chaines de caractere */
	sscanf( Ksz_CloDat, "%4s%2s%2s", Ksz_Annee_bilan, Ksz_Mois_bilan, Ksz_Jour_bilan ) ;

	/** Ouverture des fichiers en sortie */
	if (n_OpenFileAppl("ESTC1090_O1", "wt", &Kp_OutputBatch)== ERR ) 
		ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier FTTECLEDSII_OUT." );

	if ( n_OpenFileAppl ( "ESTC1090_O2","wt",&Kp_OutputANO ) == ERR )
		ExitPgm( ERR_XX , "" );	
	
	/** Initialisation des variables de gestion de ruptures */
	if (n_InitRupture(pbd_Rupture)== ERR ) 
		ExitPgm(ERR_XX, "Problème lors de l'exécution de la méthode pdb_Rupture");
		
	/** Initialisation de la structure de synchronisation */
	if (n_InitSync(pbd_Sync) == ERR) 
		ExitPgm(ERR_XX, "Erreur appel fonction n_InitSync");						
	
	/** Lancement du traitement du fichier maitre */
	if (n_ProcessingRuptureVar(pbd_Rupture) == ERR) 
		ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
	
	/** Fermeture des fichiers Ouverts */
	if (n_CloseFileAppl("ESTC1090_I1", &(pbd_Sync->pf_InputFil)) == ERR)  
		ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier FTTECLEDSII.");
	
	if (n_CloseFileAppl("ESTC1090_I2", &(pbd_Rupture->pf_InputFil)) == ERR)  
		ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier FULAERAT.");
	
	if (n_CloseFileAppl("ESTC1090_O1", &Kp_OutputBatch) == ERR)          
		ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier OUTPUT_FILE.");
	
	if (n_CloseFileAppl("ESTC1090_O2", &Kp_OutputANO) == ERR)          
		ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier OUTPUT_FILE_ANO.");

	if (n_EndPgm() == ERR) 
		ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_EndPgm.");

	/** libération mémoire */
	free(pbd_Rupture);
	free(pbd_Sync);

	exit(OK);

}

/**===========================================================================
 Objet 		: 	initialisation de la structure de rupture                                               									
 Nom 		: 	n_InitRupture     						
 Parametres	: 	i pbd_Rupture : pointeur sur la structure de rupture										
 Retour		:								
				OK si pas d'erreur,						
				ERR si erreur.							
=============================================================================*/
int n_InitRupture( T_RUPTURE_VAR *pbd_Rupture )
{
	DEBUT_FCT("n_InitRupture");
	memset(pbd_Rupture, 0, sizeof(T_RUPTURE_VAR));

	/* Ouverture du fichier maitre */
	if (n_OpenFileAppl("ESTC1090_I2", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) 
	{
		RETURN_VAL(ERR);
	}
	pbd_Rupture->n_NbRupture 	= 0;
	pbd_Rupture->n_ActionLigne 	= n_ActionLigneMaitre;
	pbd_Rupture->c_Separ		= '~';

	RETURN_VAL(OK);
}

/**=============================================================================
 Objet 		: 	fonction lancee pour chaque ligne en rupture premiere du maintre                                                									
 Nom 		: 	n_ActionLigneMaitre     						
 Parametres	: 	i ptsz_LigneCour : pointeur sur la ligne courante
 Retour		:	OK si pas d'erreur,					
				ERR si erreur.																	
===============================================================================*/
int n_ActionLigneMaitre( char *ptsz_LigneCour[] )
{
	DEBUT_FCT("n_ActionLigneMaitre");
	
	// Synchronisation avec le fichier esclave à chaque rupture 
	n_ProcessingRuptureSyncVar( pbd_Sync, ptsz_LigneCour );
	
	RETURN_VAL(OK);
}

/**===========================================================================
 Objet 		: 	initialisation de la synchronisation du maitre avec l'esclave                                                									
 Nom 		: 	n_InitSync     						
 Parametres	: 	i pbd_Sync : pointeur sur la structure de synchro										
 Retour		:								
				OK si pas d'erreur,						
				ERR si erreur.							
=============================================================================*/
int n_InitSync( T_RUPTURE_SYNC_VAR  *pbd_Sync )
{
	DEBUT_FCT("n_InitSync");
	memset(pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR));

	/* Ouverture du fichier esclave  */
	if (n_OpenFileAppl("ESTC1090_I1", "rt", &(pbd_Sync->pf_InputFil)) == ERR) 
	{
		RETURN_VAL(ERR);
	}
	pbd_Sync->ConditionEndSync	=	n_ConditionSync;
	pbd_Sync->n_ActionLigne		=	n_ActionLigneSync;
	pbd_Sync->n_FilsSansPere	=	n_ActionFilsSansPere;
	pbd_Sync->n_PereSansFils	=	n_ActionPereSansFils; //SPIRA 77591
	pbd_Sync->c_Separ='~';

	RETURN_VAL(OK);
}

/**=============================================================================
 Objet 		: 	synchronisation maitre esclave                                                									
 Nom 		: 	n_ConditionSync     						
 Parametres	: 	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre
				i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave
 Retour		:	0 si synchronise,				
				<0 si la ligne esclave est depassee,
				>0 si la ligne esclave n'est pas depassee.
===============================================================================*/
int n_ConditionSync( char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[] )
{
	int ret;

	DEBUT_FCT( "n_ConditionSync" );
	
	if ( ( ret = atoi(ptsz_LigneMaitre[RTO_SSD_CF]) - atoi(ptsz_LigneEsclave[CML_SSD_CF]) ) != 0 ) return ret;  
	if ( ( ret = atoi(ptsz_LigneMaitre[RTO_ESB_CF]) - atoi(ptsz_LigneEsclave[CML_ESB_CF]) ) != 0 ) return ret;  
	
	return 0;
}

/**=============================================================================
 Objet 		: 	fonction lancee pour chaque ligne de l'esclave                                            									
 Nom 		: 	n_ActionLigneSync     						
 Parametres	: 	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre,
				i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave
 Retour		:	OK si pas d'erreur,						
				ERR si erreur
===============================================================================*/
int n_ActionLigneSync( char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[] )
{
	DEBUT_FCT("n_ActionLigneSync");
	
	int j;
	double Ratio, AMT_M, AMT_ANk, AMT_TOTAL;
	char amount[AMN_LEN], amount_ANk[65][AMN_LEN], amount_Total[AMN_LEN];
	
	Ratio 		= atof(ptsz_LigneMaitre[RTO_RATIO_NF]);
	AMT_M 		= atof(ptsz_LigneEsclave[CML_ACMAMT_MC]);
	AMT_TOTAL 	= atof(ptsz_LigneEsclave[CML_TOTAUX_MC]);
		
	memset(amount,0, sizeof(amount));
	memset(amount_Total,0, sizeof(amount_Total));
	
	/* double check the first one is done on shell side */
	if((strcmp(ptsz_LigneEsclave[CML_ACMTRS3_NT2],"3114")	== 0 || strcmp(ptsz_LigneEsclave[CML_ACMTRS3_NT2], "3115") == 0) &&
		strcmp(ptsz_LigneEsclave[CML_PATCAT_CT],"CSF") 	== 0 && strcmp(ptsz_LigneEsclave[CML_PATTYP_CT],"INF") == 0 &&  AMT_M != 0 )
	{
		//Check if the column exist
		if( ptsz_LigneEsclave[MAINT_RATIO] != NULL && *ptsz_LigneEsclave[MAINT_RATIO] != 0 )
		{
			// Calculation of the Cashflow for ACMAMT_M 
			sprintf(amount , "%.3f" ,  ( AMT_M/Ratio ) * atof(ptsz_LigneEsclave[MAINT_RATIO]) );
			ptsz_LigneEsclave[CML_ACMAMT_MC] = amount;
				
			// Calculation of the Cashflow for Total amounts 
			sprintf(amount_Total , "%.3f" , ( AMT_TOTAL/Ratio )* atof(ptsz_LigneEsclave[MAINT_RATIO]) );
			ptsz_LigneEsclave[CML_TOTAUX_MC] = amount_Total;  
				
			// Calculation of the Cashflow for ANk year 
			for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
			{
				AMT_ANk = atof(ptsz_LigneEsclave[j]);
				sprintf( amount_ANk [j-CML_AN1], "%-.3f" , ( AMT_ANk/Ratio )* atof(ptsz_LigneEsclave[MAINT_RATIO]) );
				ptsz_LigneEsclave[j] = amount_ANk [j-CML_AN1];
			}
			
			ptsz_LigneEsclave[CML_NORME_CF] = Norme_CF ;
			// SPIRA 79992	
			ptsz_LigneEsclave[CML_BALSHEY_NF] = Ksz_Annee_bilan ;
			ptsz_LigneEsclave[CML_BALSHRMTH_NF] = Ksz_Mois_bilan ;
			ptsz_LigneEsclave[CML_BALSHRDAY_NF] = Ksz_Jour_bilan ;
			
			ptsz_LigneEsclave[124] = 0;
			n_WriteCols(Kp_OutputBatch,  ptsz_LigneEsclave, '~', 0);
		}
		else
		{
			fprintf(Kp_OutputANO,
				"No Maintenance Ratio found for CSUOE ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) \n", 
				ptsz_LigneEsclave[CML_CTR_NF],
				ptsz_LigneEsclave[CML_END_NT], 
				ptsz_LigneEsclave[CML_SEC_NF], 
				ptsz_LigneEsclave[CML_UWY_NF], 
				ptsz_LigneEsclave[CML_UW_NT] 
				);
		}	
	}
	
	RETURN_VAL(OK);
}

/**=============================================================================
 Objet 		: 	fonction lancee quand aucune ligne du fichier maitre ne 
				correspond a la ligne courante du fichier esclave
 Nom 		: 	n_ActionFilsSansPere     						
 Parametres	: 	i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave
 Retour		:	OK si pas d'erreur,						
				ERR si erreur
===============================================================================*/
int n_ActionFilsSansPere( char *ptsz_LigneEsclave[] )
{
	DEBUT_FCT("n_ActionFilsSansPere");
	
	n_WriteCols(Kp_OutputBatch, ptsz_LigneEsclave, '~', 0);
	
	/* SPIRA 77591 */
	fprintf(Kp_OutputANO,
		"No EBS ULAE cashflow found for CSUOE ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) \n", 
		ptsz_LigneEsclave[CML_CTR_NF],
		ptsz_LigneEsclave[CML_END_NT], 
		ptsz_LigneEsclave[CML_SEC_NF], 
		ptsz_LigneEsclave[CML_UWY_NF], 
		ptsz_LigneEsclave[CML_UW_NT] 
		);
				
	RETURN_VAL(OK);
}

/**=============================================================================
 Objet 		: 	fonction lancee quand aucune ligne du fichier esclave ne 
				correspond a la ligne courante du fichier maitre
 Nom 		: 	n_ActionPereSansFils     						
 Parametres	: 	i ptsz_LigneMaitre : pointeur sur la ligne de l'esclave
 Retour		:	OK si pas d'erreur,						
				ERR si erreur
===============================================================================*/
int n_ActionPereSansFils( char *ptsz_LigneMaitre[] )
{
	DEBUT_FCT("n_ActionPereSansFils");
	
	/* SPIRA 77591 */
	fprintf(Kp_OutputANO,
		"No ULAE Ratio found for ( SSD_CF %s - ESB_CF %s ) \n", 
		ptsz_LigneMaitre[RTO_SSD_CF],
		ptsz_LigneMaitre[RTO_ESB_CF]
		);
	
	RETURN_VAL(OK);
}