/*==============================================================================
Nom de l'application          : Maintenance Expenses Paid
Nom du source                 : ESTC1091.c
Revision                      : V1
Date de creation              : 01/03/2019
Auteur                        : L.EL-FAHIM
Squelette de base             : Batch
References des specifications : 
-------------------------------------------------------------------------------
Description :
	Ce programme manipule plusieurs fichiers en entree pour gerer :
	Maintenance Expenses Paid Calculation

-------------------------------------------------------------------------------
Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
       ...           ...            ...              ...
=============================================================================*/


/**--------------------------------------------------
 Inclusion des interfaces des composants importes 
--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <util.h>
#include <stdarg.h>
#include "estserv.h"
#include "estutil.c"
#include "ESTC1091.h"
#include "ESTC3001.h"   /* Fichier commun avec des autres programmes contenant la structure du fichier GTSII_CASHFLOW */

static char VERSION_ESTC1091_C[150] = "__version__: ESTC1091.c [1] 28/01/2021 17:00:00 spira 93539 @L.ELFAHIM";


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
	/** Initialisation des structures */
	pbd_Rupture = malloc(sizeof(T_RUPTURE_VAR));
	
	/** Initialisation des signaux */
	InitSig () ;

	if (n_BeginPgm(argc, argv) == ERR) 
		ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_BeginPGM.");
	
	printf("Running %s \n", VERSION_ESTC1091_C);
	
	/** Recuperation des parametres */
	
	
	strcpy(sz_Clodat_d, psz_GetCharArgv(1));
	
	sprintf(gsz_Annee, "%.4s", sz_Clodat_d);
	sprintf(gsz_Mois, "%.2s", &sz_Clodat_d[4]);
	sprintf(gsz_Jour, "%.2s", &sz_Clodat_d[6]);
  
	strcpy( Norme_CF, psz_GetCharArgv(2) ) ;
	
	Norme = n_GetNorme( Norme_CF );
	if( Norme == 'R' )
	{
		n_WriteAno( "ERROR : Norme Incorrecte \n" );
		exit(1);
	}
	
	/** Ouverture des fichiers de fichiers Ouput en sortie */
	if (n_OpenFileAppl("ESTC1091_O1", "wt", &kp_Output_EXPENSES)== ERR ) 
		ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier kp_Output_EXPENSES." );
	
	/** Initialisation des variables de gestion de ruptures */
	if (n_InitRupture(pbd_Rupture)== ERR ) 
		ExitPgm(ERR_XX, "Problème lors de l'exécution de la méthode pdb_Rupture");
		
	/** Lancement du traitement du fichier maitre */
	if (n_ProcessingRuptureVar(pbd_Rupture) == ERR) 
		ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
	
	/** Fermeture des fichiers Ouverts */
	if (n_CloseFileAppl("ESTC1091_I1", &(pbd_Rupture->pf_InputFil)) == ERR)  
		ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier GTSII_REMAININTOPAY_ULAEINF (Q-1)");
	
	if (n_CloseFileAppl("ESTC1091_O1", &kp_Output_EXPENSES) == ERR)          
		ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier ouput kp_Output_EXPENSES.");

	if (n_EndPgm() == ERR) 
		ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_EndPgm.");

	/** libération mémoire */
	free(pbd_Rupture);

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
	if (n_OpenFileAppl("ESTC1091_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) 
	{
		RETURN_VAL(ERR);
	}
	pbd_Rupture->n_NbRupture 			= 	1;
	pbd_Rupture->n_ConditionRupture[0]	=	n_TestRupture;
	pbd_Rupture->n_ActionFirst[0]		=	n_ActionFirstRupture;
	pbd_Rupture->n_ActionLigne 			= 	n_ActionLigneMaitre;
	pbd_Rupture->n_ActionLast[0]		=	n_ActionLastRupture;
	pbd_Rupture->c_Separ				= '~';

	RETURN_VAL(OK);
}


/**===========================================================================
objet 	: Fonction de test de rupture du niveau 1
retour	: 	0   ---> Rupture
			1   ---> Pas de rupture
==============================================================================*/
int n_TestRupture( char **ptb_InRec, char **ptb_InRec_Cur )
{
	DEBUT_FCT("n_TestRupture");

	if (strcmp(ptb_InRec[CML_CTR_NF], ptb_InRec_Cur[CML_CTR_NF])!=0 ) return(1);
	if (strcmp(ptb_InRec[CML_END_NT], ptb_InRec_Cur[CML_END_NT])!=0 ) return(1);   
	if (strcmp(ptb_InRec[CML_SEC_NF], ptb_InRec_Cur[CML_SEC_NF])!=0 ) return(1);
	if (strcmp(ptb_InRec[CML_UWY_NF], ptb_InRec_Cur[CML_UWY_NF])!=0 ) return(1);
	if (strcmp(ptb_InRec[CML_UW_NT],  ptb_InRec_Cur[CML_UW_NT]) !=0 ) return(1);

	RETURN_VAL (0);
}


/**===========================================================================
objet 	: Fonction de traitement de rupture du niveau 1
retour	: 	0   ---> OK
			1   ---> ERR
==============================================================================*/
int n_ActionFirstRupture( char *ptsz_LigneMaitre[] )
{
	DEBUT_FCT("n_ActionFirstRupture");
	
	// Initialisation of Amount Paid 
	n_MAINT_PAID = 0.0;

	RETURN_VAL(OK);
}

/**=============================================================================
 Objet 		: 	fonction lancee pour chaque ligne en rupture premiere du maintre                                                									
 Nom 		: 	n_ActionLigneMaitre     						
 Parametres	: 	i ptsz_LigneMaitre : pointeur sur la ligne courante
 Retour		:	OK si pas d'erreur,					
				ERR si erreur.																	
===============================================================================*/
int n_ActionLigneMaitre( char *ptsz_LigneMaitre[] )
{
	DEBUT_FCT("n_ActionLigneMaitre");
	
	/* MAINTENANCE EXPENSES PAID AGGREGATION */	
	//printf(" --- n_MAINT_PAID --- : %s \n", ptsz_LigneMaitre[CML_AN1]);
	n_MAINT_PAID += atof(ptsz_LigneMaitre[CML_AN1]);
	
	RETURN_VAL(OK);
}



/**===========================================================================
objet 	: Fonction de traitement de rupture deniere
retour	: 	0   ---> OK
			1   ---> ERR
==============================================================================*/
int n_ActionLastRupture( char *ptsz_LigneMaitre[] )
{
	DEBUT_FCT("n_ActionLastRupture");
	
	sprintf(TrnCod, "%s%c", "1146074", Norme);
	n_EcrireGT( ptsz_LigneMaitre, - n_MAINT_PAID /4, TrnCod );
	//printf(" --- n_MAINT_PAID --- : %lf \n", - n_MAINT_PAID /4);

	RETURN_VAL(OK);
}



/**===============================================================================
objet:	Cette fonction permet d ecrire des resultas dans le Fichier : EST_EXPENSES 

==================================================================================*/
int n_EcrireGT( char **pbd_InRec_Cur, double d_Montant, char *trn_Code )
{
	char *Gt[NB_COL_GT + 1] ; 	// tableau de pointeurs a l'image du GT
	char sz_Amt[18+1] ;
	
	sprintf( sz_Amt, "%-.3f", d_Montant ) ;
	//printf(" Amount %s \n",sz_Amt);

	//------------------------------------------------------------------
	// Ecriture GT format a partir du GTSII format 
	//------------------------------------------------------------------
	Gt[GT_SSD_CF] 				= pbd_InRec_Cur[CML_SSD_CF] ; 
	Gt[GT_ESB_CF] 				= pbd_InRec_Cur[CML_ESB_CF] ;
	Gt[GT_BALSHEY_NF] 			= gsz_Annee ;		     
	Gt[GT_BALSHRMTH_NF] 		= gsz_Mois;				
	Gt[GT_BALSHRDAY_NF] 		= gsz_Jour; 				
	Gt[GT_TRNCOD_CF] 			= trn_Code ;			
	Gt[GT_DBLTRNCOD_CF] 		= "" ;				
	Gt[GT_CTR_NF] 				= pbd_InRec_Cur[CML_CTR_NF] ;                      
	Gt[GT_END_NT] 				= pbd_InRec_Cur[CML_END_NT] ;   
	Gt[GT_SEC_NF] 				= pbd_InRec_Cur[CML_SEC_NF] ;     
	Gt[GT_UWY_NF] 				= pbd_InRec_Cur[CML_UWY_NF] ;    
	Gt[GT_UW_NT] 				= pbd_InRec_Cur[CML_UW_NT] ;      
	Gt[GT_OCCYEA_NF] 			= gsz_Annee;				
	Gt[GT_ACY_NF] 				= gsz_Annee;  			
	Gt[GT_SCOSTRMTH_NF] 		= gsz_Mois; 				
	Gt[GT_SCOENDMTH_NF] 		= gsz_Mois;				
	Gt[GT_CLM_NF] 				= "" ;
	Gt[GT_CUR_CF] 				= pbd_InRec_Cur[CML_CUR_CF] ;
	Gt[GT_AMT_M] 				= sz_Amt ; 					
	Gt[GT_CED_NF] 				= pbd_InRec_Cur[CML_CED_NF] ; 
	Gt[GT_BRK_NF] 				= pbd_InRec_Cur[CML_BRK_NF] ; 					
	Gt[GT_PAY_NF] 				= pbd_InRec_Cur[CML_PAY_NF] ; 					
	Gt[GT_KEY_NF] 				= pbd_InRec_Cur[CML_KEY_NF] ;
	if ( b_IsBlankOrEmpty(pbd_InRec_Cur[CML_RETCTR_NF]) )
	{
		Gt[GT_RETCTR_NF] 		= "";
		Gt[GT_RETEND_NT] 		= "";
		Gt[GT_RETSEC_NF] 		= "";
		Gt[GT_RTY_NF] 			= "";
		Gt[GT_RETUW_NT] 		= "";
		Gt[GT_RETOCCYEA_NF] 	= "";
		Gt[GT_RETACY_NF] 		= "";
		Gt[GT_RETSCOSTRMTH_NF] 	= "";
		Gt[GT_RETSCOENDMTH_NF] 	= "";
		Gt[GT_RCL_NF] 			= "";
		Gt[GT_RETCUR_CF] 		= "";
		Gt[GT_RETAMT_M] 		= "";
		Gt[GT_PLC_NT] 			= "";
		Gt[GT_RTO_NF] 			= "";
		Gt[GT_INT_NF] 			= "";
		Gt[GT_RETPAY_NF] 		= "";
		Gt[GT_RETKEY_CF] 		= "";
		Gt[GT_RETINTAMT_M] 		= "0";
	}
	else
	{	
		Gt[GT_RETCTR_NF] 		= pbd_InRec_Cur[CML_RETCTR_NF] ;				
		Gt[GT_RETEND_NT] 		= pbd_InRec_Cur[CML_RETEND_NT] ;						
		Gt[GT_RETSEC_NF] 		= pbd_InRec_Cur[CML_RETSEC_NF] ;					
		Gt[GT_RTY_NF] 			= pbd_InRec_Cur[CML_RTY_NF] ;
		Gt[GT_RETUW_NT] 		= pbd_InRec_Cur[CML_RETUW_NT] ;
		Gt[GT_RETOCCYEA_NF] 	= gsz_Annee;
		Gt[GT_RETACY_NF] 		= gsz_Annee;
		Gt[GT_RETSCOSTRMTH_NF] 	= gsz_Mois ;
		Gt[GT_RETSCOENDMTH_NF] 	= gsz_Mois ;
		Gt[GT_RCL_NF] 			= pbd_InRec_Cur[CML_RCL_NF] ;
		Gt[GT_RETCUR_CF] 		= pbd_InRec_Cur[CML_RETCUR_CF] ;
		Gt[GT_RETAMT_M] 		= pbd_InRec_Cur[CML_RETAMT_MC] ;
		Gt[GT_PLC_NT] 			= pbd_InRec_Cur[CML_PLC_NT] ;
		Gt[GT_RTO_NF] 			= pbd_InRec_Cur[CML_RTO_NF] ;
		Gt[GT_INT_NF] 			= pbd_InRec_Cur[CML_INT_NF] ;
		Gt[GT_RETPAY_NF] 		= pbd_InRec_Cur[CML_RETPAY_NF] ;
		Gt[GT_RETKEY_CF] 		= pbd_InRec_Cur[CML_RETKEY_CF] ;
		Gt[GT_RETINTAMT_M] 		= pbd_InRec_Cur[CML_RETINTAMT_MC] ;
	}
	Gt[GT_RETINTAMT_M + 1] 		= NULL ;	
			
	n_WriteCols( kp_Output_EXPENSES , Gt, SEPARATEUR, 0 ) ;

	RETURN_VAL(0);
}


/**===========================================================================
objet	:	Fonction pour retourner symbole norme a rensigner dans TRNCOD 
retour 	:   Caractere a renseigner dans TRNCOD	
==============================================================================*/
char n_GetNorme( const char *Norme_CF )
{
	if( strcmp(Norme_CF, "I17G") == 0 )	return 'I';
	else if ( strcmp(Norme_CF, "I17P") == 0 )	return 'K';
	else if ( strcmp(Norme_CF, "I17L") == 0 )	return 'M'; 
	else return 'R';
}

