/**=======================================================================================
APPLICATION NAME          	: Maintenance Expenses Calculation
SOURCE NAME                 : ESFC3630.c
REVISION                   	: V1
CREATION DATE              	: 03/2019
AUTOR                       : L.ELFAHIM
TYPE             			: Batch 
-----------------------------------------------------------------------------------------
DESCRIPTION :
	THIS PROGRAM MANIPULATES SEVERAL INPUT FILES TO MANAGE :
	MAINTENANCE EXPENSES CALCULATIONS
-----------------------------------------------------------------------------------------
MODIFICATIONS HISTORY :
	20/02/2019 		LEL		71570		Developpement de la version initiale
	24/07/2019		LEL		79992		Filtres et Jointures des fichiers
	10/09/2019		LEL		79992		Gerer la date du bilan
	25/09/2019		LEL		79992		Ajouter fichier gestion des anomalies
	26/08/2021      LEL   	97351       ACF/PCA: EXPENSES CALCULATION	
=========================================================================================*/
/**--------------------------------------------------
 Inclusion des interfaces des composants importes 
--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <util.h>
#include <stdarg.h>
#include "estserv.h"
#include "estutil.c"
#include "ESFC3630.h"
#include "ESTC3001.h"
  
/** ESTC3001.h Fichier commun avec des autres programmes contenant la structure du fichier GTSII_CASHFLOW */

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
	/** Initialisation des signaux */
	InitSig () ;

	if (n_BeginPgm(argc, argv) == ERR) 
		ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_BeginPGM.");
	
	/** Recuperation des parametres */
	strcpy( Norme_CF, psz_GetCharArgv(1) );
	strcpy( Ksz_CloDat, psz_GetCharArgv(2) );
	//printf("%s~%s \n", Norme_CF, Ksz_CloDat);
	
	/** Eclatement de la date AAAAMMJJ en 3 chaines de caractere */
	sscanf( Ksz_CloDat, "%4s%2s%2s", Ksz_Annee_bilan, Ksz_Mois_bilan, Ksz_Jour_bilan );

	/** Ouverture des fichiers en sortie */
	if (n_OpenFileAppl("ESFC3630_O1", "wt", &Kp_OutputBatch)== ERR ) 
		ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier FTTECLEDSII_OUT." );

	if ( n_OpenFileAppl ( "ESFC3630_O2","wt",&Kp_OutputANO ) == ERR )
		ExitPgm( ERR_XX , "" );	
	
	/** Initialisation des variables de gestion de ruptures */
	if (n_InitRupture(&pbd_Rupture)== ERR )
		ExitPgm(ERR_XX, "Problème lors de l'exécution de la méthode pdb_Rupture");
		
	/** Initialisation de la structure de synchronisation */
	if (n_InitSync(&pbd_Sync) == ERR) 
		ExitPgm(ERR_XX, "Erreur appel fonction n_InitSync");						
	
	/** Lancement du traitement du fichier maitre */
	if (n_ProcessingRuptureVar(&pbd_Rupture) == ERR) 
		ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
	
	/** Fermeture des fichiers Ouverts */
	if (n_CloseFileAppl("ESFC3630_I1", &(pbd_Sync.pf_InputFil)) == ERR)  
		ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier FTTECLEDSII.");
	
	if (n_CloseFileAppl("ESFC3630_I2", &(pbd_Rupture.pf_InputFil)) == ERR)  
		ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier FULAERAT.");
	
	if (n_CloseFileAppl("ESFC3630_O1", &Kp_OutputBatch) == ERR)          
		ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier OUTPUT_FILE.");
	
	if (n_CloseFileAppl("ESFC3630_O2", &Kp_OutputANO) == ERR)          
		ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier OUTPUT_FILE_ANO.");

	if (n_EndPgm() == ERR) 
		ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_EndPgm.");

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
	if (n_OpenFileAppl("ESFC3630_I2", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) 
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
	
	/** Synchronisation avec le fichier esclave à chaque rupture */
	n_ProcessingRuptureSyncVar( &pbd_Sync, ptsz_LigneCour );
	
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
	if (n_OpenFileAppl("ESFC3630_I1", "rt", &(pbd_Sync->pf_InputFil)) == ERR) 
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
	if ( ( ret = strcmp(ptsz_LigneMaitre[RTO_CTRNAT_CT], ptsz_LigneEsclave[CML_NAT_CF]) ) != 0 ) return ret;
	if ( ( ret = atoi(ptsz_LigneMaitre[RTO_UWY_NF]) - atoi(ptsz_LigneEsclave[IME_UWY_NF]) ) != 0 ) return ret;
	if ( ( ret = atoi(ptsz_LigneMaitre[RTO_LOBN2_NF]) - atoi(ptsz_LigneEsclave[IME_LOBN2_NF]) ) != 0 ) return ret;
	
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
	
	/** DOUBLE CHECK THE FIRST ONE IS DONE ON SHELL SIDE */
	if(	strcmp(ptsz_LigneEsclave[CML_ACMTRS_NT],"314")		== 0  
		&& strcmp(ptsz_LigneEsclave[CML_PATCAT_CT],"CSF")	== 0 
		&& strcmp(ptsz_LigneEsclave[CML_PATTYP_CT],"INF") 	== 0 
		&&  AMT_M != 0 
	)
	{
		/** CHECK IF THE COLUMN EXIST & CLOSING AT INCEPTION */
		if( ptsz_LigneEsclave[MAINT_RATIO] != NULL && *ptsz_LigneEsclave[MAINT_RATIO] != 0 )
		{		
			/** CALCULATION OF THE CASHFLOW FOR ACMAMT_M */
			sprintf(amount , "%.3f" , ( AMT_M/Ratio ) * atof(ptsz_LigneEsclave[MAINT_RATIO]) );
			ptsz_LigneEsclave[CML_ACMAMT_MC] = amount;
				
			/** CALCULATION OF THE CASHFLOW FOR TOTAL AMOUNTS */
			sprintf(amount_Total , "%.3f" , ( AMT_TOTAL/Ratio )* atof(ptsz_LigneEsclave[MAINT_RATIO]) );
			ptsz_LigneEsclave[CML_TOTAUX_MC] = amount_Total;  
				
			/** CALCULATION OF THE CASHFLOW FOR ANK YEAR */
			for( j = CML_AN1; j<= CML_AM_FIN; ++j )   
			{
				AMT_ANk = atof(ptsz_LigneEsclave[j]);
				sprintf( amount_ANk [j-CML_AN1], "%-.3f" , ( AMT_ANk/Ratio )* atof(ptsz_LigneEsclave[MAINT_RATIO]) );
				ptsz_LigneEsclave[j] = amount_ANk [j-CML_AN1];
			}
				
			ptsz_LigneEsclave[CML_NORME_CF] 	= Norme_CF ;
			ptsz_LigneEsclave[CML_BALSHEY_NF] 	= Ksz_Annee_bilan ;
			ptsz_LigneEsclave[CML_BALSHRMTH_NF] = Ksz_Mois_bilan ;
			ptsz_LigneEsclave[CML_BALSHRDAY_NF] = Ksz_Jour_bilan ;

			ptsz_LigneEsclave[124] = 0;
			n_WriteCols(Kp_OutputBatch, ptsz_LigneEsclave, '~', 0);
		}
		else
		{
			fprintf(Kp_OutputANO,
				"No Maintenance Ratio found for Leger (SSD_CF %s - ESB_CF %s) CSUOE ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) NAT %s - LOBN2 %s - UWY %s \n", 
				ptsz_LigneEsclave[CML_SSD_CF],
				ptsz_LigneEsclave[CML_ESB_CF],
				ptsz_LigneEsclave[CML_CTR_NF],
				ptsz_LigneEsclave[CML_END_NT], 
				ptsz_LigneEsclave[CML_SEC_NF], 
				ptsz_LigneEsclave[CML_UWY_NF], 
				ptsz_LigneEsclave[CML_UW_NT], 
				ptsz_LigneEsclave[CML_NAT_CF], 
				ptsz_LigneEsclave[IME_LOBN2_NF], 
				ptsz_LigneEsclave[IME_UWY_NF]
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
	
	/** SPIRA 77591 */
	fprintf(Kp_OutputANO,
		"No EBS ULAE cashflow found for Leger (SSD_CF %s - ESB_CF %s) CSUOE ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) NAT %s - LOBN2 %s - UWY %s \n", 
		ptsz_LigneEsclave[CML_SSD_CF],
		ptsz_LigneEsclave[CML_ESB_CF],
		ptsz_LigneEsclave[CML_CTR_NF],
		ptsz_LigneEsclave[CML_END_NT], 
		ptsz_LigneEsclave[CML_SEC_NF], 
		ptsz_LigneEsclave[CML_UWY_NF], 
		ptsz_LigneEsclave[CML_UW_NT], 
		ptsz_LigneEsclave[CML_NAT_CF], 
		ptsz_LigneEsclave[IME_LOBN2_NF], 
		ptsz_LigneEsclave[IME_UWY_NF]
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
	
	/** SPIRA 77591 */
	fprintf(Kp_OutputANO,
		"No ULAE Ratio found for ( SSD_CF %s - ESB_CF %s - CTRNAT_CT %s - LOBN2_NF %s - UWY_NF %s) \n", 
		ptsz_LigneMaitre[RTO_SSD_CF],
		ptsz_LigneMaitre[RTO_ESB_CF],
		ptsz_LigneMaitre[RTO_CTRNAT_CT],
		ptsz_LigneMaitre[RTO_LOBN2_NF],
		ptsz_LigneMaitre[RTO_UWY_NF]
		);
	
	RETURN_VAL(OK);
}