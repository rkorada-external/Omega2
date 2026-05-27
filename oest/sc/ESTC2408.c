/*==============================================================================
nom de l'application          : ESTIMATION 
nom du source                 : ESTC2408.c
révision                      : 
date de création              : 05/10/2021
auteur                        : MZM
references des specifications :
squelette de base             : batch
------------------------------------------------------------------------------
description :
   spira:87852 Application des Taxes su fichier GTR ou GTAR
   Entrée : Un fichier au format GT, contenant sur 72 premieres  olonnes les Donnees du GTAR et les 20 colonnes suivantes les données du TAXE RETRO MANAGEMENT
   Sortie : Le fichier auquel est applique les Taxes sur les montants Retro suivant les conditions basées sur le calcul de la Taxe Retro

------------------------------------------------------------------------------
historique des modifications :
[001] initial version   
========================================================================================================*/ 

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
//#include "ESTC2408.h" 
#include "struct.h"
#include "estserv.h"



/*----------------------------------------*/
/* inclusion de version dans les binaires */
/*----------------------------------------*/
static char VERSION_ESTC2408_C[150] = "__version__: ESTC2408.c version [001]  20/10/2021 : Spira 87852 Init "; 


/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/



/*----------------------*/
/* Variables de travail */
/*----------------------*/


/*-----------------------------*/
/* Fonctions du fichier maitre */
/*-----------------------------*/

int n_InitRupture	   (T_RUPTURE_VAR  *pbd_Rupture);
int n_ActionLigneRupture   (char *ptsz_LigneCour[]);



#define RETCTR_NF_F2      	72 
#define RTY_NF_F2         	73
#define PLC_NT_F2      			74
#define RETPRMTAX_CT_F2     75
#define PLCRETPRMTAX_R_F2   76
#define TAXTRNCOD_CF_F2     77 

#define NB_COL_GT2 79   





/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE   *Kp_OutputFilResSii;    /* pointeur sur le fichier de sortie formaté avec les nouvelles colonnes */


T_RUPTURE_VAR    bd_RuptDLGTAR;   /* variable de gestion de la rupture sur le fichier DLGTAR ou DLGTR */



int n_InitDLGTAR             ( T_RUPTURE_VAR  *pbd_Rupt );
int n_ActionLigneDLGTAR			 ( char **pbd_InRec_Cur );

                             
char Ksz_PRS[4];
short s_Prs;

extern int Ksz_Argc ;


/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc  , char *argv[])
{


   //pbd_Rupture=malloc(sizeof(T_RUPTURE_VAR));
	
	/* Initialisation des signaux */
	InitSig ();
	

	if ( n_BeginPgm ( argc, argv ) == ERR )
		ExitPgm( ERR_XX , "" );

	printf("Running with %s  \n", VERSION_ESTC2408_C);
	
  //strcpy( Ksz_PRS, psz_GetCharArgv(1) ) ;  
  //s_Prs = atoi(Ksz_PRS);   	 		
        
	/* ouverture du fichier de sortie des resultats par affaire */
	if ( n_OpenFileAppl ( "ESTC2408_O1","wt",&Kp_OutputFilResSii ) == ERR )
		ExitPgm( ERR_XX , "" );

	printf("Running with 0000%s  \n", VERSION_ESTC2408_C);

	/* Initialisation de la variable bd_RuptDLGTAR */
	if ( n_InitDLGTAR( &bd_RuptDLGTAR ) )
		ExitPgm( ERR_XX , "" );


	/* lancement du traitement du fichier DLDGTAR */
	if ( n_ProcessingRuptureVar( &bd_RuptDLGTAR ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC2408_I1", &( bd_RuptDLGTAR.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC2408_O1", &Kp_OutputFilResSii ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_EndPgm() == ERR )
		ExitPgm( ERR_XX , "" );

	exit(OK);
}


/*==============================================================================
objet :
	fonction d'initialisation de la variable de gestion de rupture du fichier
	maitre.

retour :
	0K
==============================================================================*/
int n_InitDLGTAR(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitDLGTAR" );

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) );

	/* ouverture du fichier maitre Perimetre de souscription */
	if ( n_OpenFileAppl( "ESTC2408_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR;
		
   pbd_Rupt->n_ActionLigne= n_ActionLigneDLGTAR ; 		
  
	 pbd_Rupt->c_Separ = '~';

	RETURN_VAL( OK );
}

/*==============================================================================
objet :
	fonction lancée à la rupture sur le fichier maître

retour :
	0 ---> pas de rupture
	1 ---> rupture
==============================================================================*/
int n_TestRuptureDLGTAR(
   char *ptsz_LigneSuiv[],
   char *ptsz_LigneCour[]
)
{
  DEBUT_FCT("n_TestRuptureDLGTAR");
  
  //printf("DANS TESTS RUPTURE \n");

	if (strcmp(ptsz_LigneSuiv[GT_CTR_NF], ptsz_LigneCour[GT_CTR_NF])!=0) return(1);
	if (strcmp(ptsz_LigneSuiv[GT_END_NT], ptsz_LigneCour[GT_END_NT])!=0) return(1);
	if (strcmp(ptsz_LigneSuiv[GT_SEC_NF], ptsz_LigneCour[GT_SEC_NF])!=0) return(1);
	if (strcmp(ptsz_LigneSuiv[GT_UWY_NF], ptsz_LigneCour[GT_UWY_NF])!=0) return(1);
	if (strcmp(ptsz_LigneSuiv[GT_UW_NT], ptsz_LigneCour[GT_UW_NT])!=0) return(1);

	return( 0 );
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneDLGTAR(char **pbd_InRecChild ) 
{


	char   sz_Amt[21];
	char   sz_RetAmt[21];
	char   sz_RetIntAmt[21];
		
	double d_Amt = 0;
	double d_RetAmt = 0;	
	double d_RetIntAmt = 0;		


	

		DEBUT_FCT( "n_ActionLigneDLGTAR" );
		
   //printf("DANS n_ActionLigneDLGTAR : pbd_InRecChild[GT_TRNCOD_CF]=%s ;n_type_trn_cd = %d ; LOFACT=%d\n", pbd_InRecChild[GT_TRNCOD_CF], n_type_trn_cd, LOFACT);		



	{	  
		//if (strcmp(pbd_InRecChild[GT_CTR_NF], "05T001636") == 0   && atoi(pbd_InRecChild[GT_UWY_NF]) == 2019 && strcmp(pbd_InRecChild[GT_TRNCOD_CF], "2A121212") == 0)
		//	printf("\n TESTS APPLYING LOFACTOR  CESU = %s~%s~%s~%s~%f~%s~ ; RESU = %s~%s~%s~%s~%f~%f~  (atof(pbd_InRecChild[GT_LOFACTOR])=%f ; pbd_InRecChild[GT_LOFACTOR]=%s\n", pbd_InRecChild[GT_CTR_NF],  pbd_InRecChild[PER_END_NT],  pbd_InRecChild[GT_SEC_NF], pbd_InRecChild[GT_UWY_NF], atof(pbd_InRecChild[GT_AMT_M]), pbd_InRecChild[GT_TRNCOD_CF], pbd_InRecChild[GT_RETCTR_NF],  pbd_InRecChild[GT_RETEND_NT],  pbd_InRecChild[GT_RETSEC_NF], pbd_InRecChild[GT_RTY_NF], atof(pbd_InRecChild[GT_RETAMT_M]), atof(pbd_InRecChild[GT_RETINTAMT_M]), atof(pbd_InRecChild[GT_LOFACTOR]), pbd_InRecChild[GT_LOFACTOR]  ); 			
		
			//d_Amt = atof(pbd_InRecChild[GT_AMT_M]) * atof(pbd_InRecChild[PLCRETPRMTAX_R_F2]);
			d_Amt = 0.0 ;
			sprintf( sz_Amt, "%-.3f", d_Amt );
			
		  d_RetAmt = atof(pbd_InRecChild[GT_RETAMT_M]) * atof(pbd_InRecChild[PLCRETPRMTAX_R_F2]);
		  sprintf( sz_RetAmt, "%-.3f", d_RetAmt );
		  
		  d_RetIntAmt = atof(pbd_InRecChild[GT_RETINTAMT_M]) * atof(pbd_InRecChild[PLCRETPRMTAX_R_F2]);	
		  sprintf( sz_RetIntAmt, "%-.3f", d_RetIntAmt );		  	  
	}
/*
  {

			d_Amt = atof(pbd_InRecChild[GT_AMT_M]) ;
			sprintf( sz_Amt, "%-.3f", d_Amt );
			
		  d_RetAmt = atof(pbd_InRecChild[GT_RETAMT_M]);
		  sprintf( sz_RetAmt, "%-.3f", d_RetAmt );
		  
		  d_RetIntAmt = atof(pbd_InRecChild[GT_RETINTAMT_M]) ;	
		  sprintf( sz_RetIntAmt, "%-.3f", d_RetIntAmt );  	
  }
	*/

  strcpy(pbd_InRecChild[GT_TRNCOD_CF], pbd_InRecChild[TAXTRNCOD_CF_F2]) ; // Nouveau TRNCOD De cumul des Taxes Appliquees
  
	pbd_InRecChild[GT_AMT_M] = sz_Amt;
	pbd_InRecChild[GT_RETAMT_M] = sz_RetAmt;
	pbd_InRecChild[GT_RETINTAMT_M] = sz_RetIntAmt ;
								

	if ( fabs(atof(sz_Amt)) > 0 || fabs(atof(sz_RetAmt)) > 0 || fabs(atof(sz_RetIntAmt)) > 0 ) 
	{	 					
				n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );
	}	

	
	RETURN_VAL( OK );
}			
			



 
 
