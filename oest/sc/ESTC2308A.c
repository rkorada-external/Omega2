/*==============================================================================
nom de l'application          : ESTIMATION 
nom du source                 : ESTC2308.c
r�vision                      : 
date de cr�ation              : 26/03/2020
auteur                        : MZM
references des specifications :
squelette de base             : batch
------------------------------------------------------------------------------
description :
   :spira:79070 Application du LOFACTOR aux montants d'un fichier au format GT
   Entr�e : Un fichier au format GT, contenant en derniere colonne le LOFACTOR
   Sortie : Le fichier auquel est applique le LOFACTOR suivant les conditions bas�es sur le calcul de l'initial Loss Recovery

------------------------------------------------------------------------------
historique des modifications :
[001] initial version
[002] 12/08/2020 JYP :Spira:89218  : size tab FBOTRSLNK
[003] 25/11/2020 MZM :Spira:92010  : TNR - EBS Si LOFACTOR vide alors ventil� l'enregistrement tel quel
[004] 01/12/2020 MZM :Spira:88626  : Liste des TRNCOD d'application du LOFACTOR
[005] 07/01/2021 MZM :Spira:90406  : Liste des TRNCOD d'application du LOFACTOR
[006] 24/02/2021 MZM :Spira:92736  : Liste des TRNCOD d'application du LOFACTOR AE I17
[007] 10/12/2021 MZM :Spira:97734  : Montant Seuil d'application du LOFACTOR  
[008] 06/01/2022 MZM :Spira:101274  : Ajout Grouping 3540 d'application du LOFACTOR 
[009] 03/02/2022 MZM :Spira:100243  : Ajout Grouping 3172 - Future Risk Adjustment  d'application du LOFACTOR 
[010] 22/06/2023 MZM :Spira:110042  :  Extension of FBOPRSLNK bufferTalle Du Buffer Kn_MaxLigFBOTRSLNK Aggrandie
========================================================================================================*/ 

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
//#include "ESTC2308.h" 
#include "struct.h"
#include "estserv.h"



/*----------------------------------------*/
/* inclusion de version dans les binaires */
/*----------------------------------------*/
static char VERSION_ESTC2308A_C[150] = "__version__: ESTC2308.c version [010] 22/06/2023 : Spira 110042 MAJ BUFFER FBOTRSLNK"; 


/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* d�finition des constantes et macros priv�es */
/*---------------------------------------------*/



/*----------------------*/
/* Variables de travail */
/*----------------------*/


/*-----------------------------*/
/* Fonctions du fichier maitre */
/*-----------------------------*/

int n_InitRupture	   (T_RUPTURE_VAR  *pbd_Rupture);
int n_ActionLigneRupture   (char *ptsz_LigneCour[]);



#define Kn_MaxLigFBOTRSLNK   500000 //[010] 
#define LOFACT   1
#define OTHER 	 6  

#define GT_APPLY_LOFACTOR 71
#define GT_LOFACTOR 72
#define FBOPRSLNK_ACMTRSL3_NT  73




/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE   *Kp_OutputFilResSii;    /* pointeur sur le fichier de sortie format� avec les nouvelles colonnes */


T_RUPTURE_VAR    bd_RuptDLGTAR;   /* variable de gestion de la rupture sur le fichier DLGTAR ou DLGTR */



int n_InitDLGTAR             ( T_RUPTURE_VAR  *pbd_Rupt );
int n_ActionLigneDLGTAR			 ( char **pbd_InRec_Cur );


// int  n_ChargerFBOTRSLNK();                       
int n_check_trncd_cf(char **pbd_InRecChild);


FILE *Kp_InputFBOTRSLNK;                              

                            
// T_FBOTRSLNK Ktbd_FBOTRSLNK[Kn_MaxLigFBOTRSLNK]; 

int n_type_trn_cd;
// int Kn_FBOTRSLNK ;  
                             
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

	printf("Running with %s  \n", VERSION_ESTC2308A_C);
	
  //strcpy( Ksz_PRS, psz_GetCharArgv(1) ) ;  
  //s_Prs = atoi(Ksz_PRS);   	 		
  
 

	// /* ouverture du fichier en entree FBOTRSLNK */
    // if (n_OpenFileAppl("ESTC2308A_I2", "rb", &Kp_InputFBOTRSLNK) == ERR )
    //     ExitPgm(ERR_XX ,"cannot open Kp_InputFBOTRSLNK ");

        
	/* ouverture du fichier de sortie des resultats par affaire */
	if ( n_OpenFileAppl ( "ESTC2308A_O1","wt",&Kp_OutputFilResSii ) == ERR )
		ExitPgm( ERR_XX , "" );


    /* Chargement du tableau FBOTRSLNK pour les postes 750 */ 
    //strcpy(Ksz_PRS, s_Prs); // 750 remplace par variable
    
	// /* Chargement des postes en memoire */
	// Kn_FBOTRSLNK = n_ChargerFBOTRSLNK();  
    // if ( Kn_FBOTRSLNK == -1 )                                    
    // 		ExitPgm( ERR_XX , "Taille tableau FBOTRSLNK insuffisante " ) ; 	

	printf("Running with 0000%s  \n", VERSION_ESTC2308A_C);

	/* Initialisation de la variable bd_RuptDLGTAR */
	if ( n_InitDLGTAR( &bd_RuptDLGTAR ) )
		ExitPgm( ERR_XX , "" );


	/* lancement du traitement du fichier DLDGTAR */
	if ( n_ProcessingRuptureVar( &bd_RuptDLGTAR ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC2308A_I1", &( bd_RuptDLGTAR.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	// if ( n_CloseFileAppl( "ESTC2308A_I2", &Kp_InputFBOTRSLNK ) == ERR )
	// 	ExitPgm( ERR_XX , "" );	

	if ( n_CloseFileAppl( "ESTC2308A_O1", &Kp_OutputFilResSii ) == ERR )
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
	if ( n_OpenFileAppl( "ESTC2308A_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR;
		
   pbd_Rupt->n_ActionLigne= n_ActionLigneDLGTAR ; 		
  
	 pbd_Rupt->c_Separ = '~';

	RETURN_VAL( OK );
}

// /*==============================================================================
// objet :
// 	fonction lanc�e � la rupture sur le fichier ma�tre

// retour :
// 	0 ---> pas de rupture
// 	1 ---> rupture
// ==============================================================================*/
// int n_TestRuptureDLGTAR(
//    char *ptsz_LigneSuiv[],
//    char *ptsz_LigneCour[]
// )
// {
//   DEBUT_FCT("n_TestRuptureDLGTAR");
  
//   //printf("DANS TESTS RUPTURE \n");

// 	if (strcmp(ptsz_LigneSuiv[GT_CTR_NF], ptsz_LigneCour[GT_CTR_NF])!=0) return(1);
// 	if (strcmp(ptsz_LigneSuiv[GT_END_NT], ptsz_LigneCour[GT_END_NT])!=0) return(1);
// 	if (strcmp(ptsz_LigneSuiv[GT_SEC_NF], ptsz_LigneCour[GT_SEC_NF])!=0) return(1);
// 	if (strcmp(ptsz_LigneSuiv[GT_UWY_NF], ptsz_LigneCour[GT_UWY_NF])!=0) return(1);
// 	if (strcmp(ptsz_LigneSuiv[GT_UW_NT], ptsz_LigneCour[GT_UW_NT])!=0) return(1);

// 	return( 0 );
// }

 
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

	//int    n_indice;
	//int	 	n_Ssd = 0;
	//int	 	n_Uwy = 0;
	
	int  n_type_trn_cd = 0 ;

	

		DEBUT_FCT( "n_ActionLigneDLGTAR" );
		
		
		// TR0059005~0~1~2023
		
   //printf("DANS n_ActionLigneDLGTAR : pbd_InRecChild[GT_TRNCOD_CF]=%s ;n_type_trn_cd = %d ; LOFACT=%d\n", pbd_InRecChild[GT_TRNCOD_CF], n_type_trn_cd, LOFACT);		
   
   

		n_type_trn_cd = n_check_trncd_cf(pbd_InRecChild );
		
		//		if (strcmp(pbd_InRecChild[GT_CTR_NF], "TR0059005") == 0   && atoi(pbd_InRecChild[GT_UWY_NF]) == 2023 && ( strcmp(pbd_InRecChild[GT_TRNCOD_CF], "2110014I") == 0 || strcmp(pbd_InRecChild[GT_TRNCOD_CF], "2110061I") == 0)  )
		//	printf("\n V2 TESTS APPLYING LOFACTOR  CESU = %s~%s~%s~%s~%f~%s~ ; RESU = %s~%s~%s~%s~%f~%f~ ; n_type_trn_cd = %d ; (atof(pbd_InRecChild[GT_LOFACTOR])=%f ; pbd_InRecChild[GT_LOFACTOR]=%s\n", pbd_InRecChild[GT_CTR_NF],  pbd_InRecChild[PER_END_NT],  pbd_InRecChild[GT_SEC_NF], pbd_InRecChild[GT_UWY_NF], atof(pbd_InRecChild[GT_AMT_M]), pbd_InRecChild[GT_TRNCOD_CF], pbd_InRecChild[GT_RETCTR_NF],  pbd_InRecChild[GT_RETEND_NT],  pbd_InRecChild[GT_RETSEC_NF], pbd_InRecChild[GT_RTY_NF], atof(pbd_InRecChild[GT_RETAMT_M]), atof(pbd_InRecChild[GT_RETINTAMT_M]), n_type_trn_cd, atof(pbd_InRecChild[GT_LOFACTOR]), pbd_InRecChild[GT_LOFACTOR]  ); 			
		

		//Recherche Si on doit Appliquer le LOFACTOR sur l'enregistrement en cours // [005]
	if ( (n_type_trn_cd == LOFACT ) 
       && strcmp(pbd_InRecChild[GT_LOFACTOR], "") != 0 )  //[003] 
	{	  

			d_Amt = atof(pbd_InRecChild[GT_AMT_M]) * atof(pbd_InRecChild[GT_LOFACTOR]);
			sprintf( sz_Amt, "%-.3f", d_Amt );
					
			
		  d_RetAmt = atof(pbd_InRecChild[GT_RETAMT_M]) * atof(pbd_InRecChild[GT_LOFACTOR]);
		  sprintf( sz_RetAmt, "%-.3f", d_RetAmt );
		  
		  d_RetIntAmt = atof(pbd_InRecChild[GT_RETINTAMT_M]) * atof(pbd_InRecChild[GT_LOFACTOR]);	
		  sprintf( sz_RetIntAmt, "%-.3f", d_RetIntAmt );		  	  
	}
  else
  {

			d_Amt = atof(pbd_InRecChild[GT_AMT_M]) ;
			sprintf( sz_Amt, "%-.3f", d_Amt );
			
		  d_RetAmt = atof(pbd_InRecChild[GT_RETAMT_M]);
		  sprintf( sz_RetAmt, "%-.3f", d_RetAmt );
		  
		  d_RetIntAmt = atof(pbd_InRecChild[GT_RETINTAMT_M]) ;	
		  sprintf( sz_RetIntAmt, "%-.3f", d_RetIntAmt );  	
  }
	

 
	pbd_InRecChild[GT_AMT_M] = sz_Amt;
	pbd_InRecChild[GT_RETAMT_M] = sz_RetAmt;
	pbd_InRecChild[GT_RETINTAMT_M] = sz_RetIntAmt ;
								

	//[007]if ( fabs(atof(sz_Amt)) > 1 || fabs(atof(sz_RetAmt)) > 1 || fabs(atof(sz_RetIntAmt)) > 1 ) 
	if ( fabs(atof(sz_Amt)) > 0.001 || fabs(atof(sz_RetAmt)) > 0.001 || fabs(atof(sz_RetIntAmt)) > 0.001 ) 		
	{	 					
				pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]=0;
				n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );
	}	

	
	RETURN_VAL( OK );
}			
			


/*==============================================================================
objet :
 fonction de recherche du trncod
retour :
         LOFACT   1  
         OTHER    2  


==============================================================================*/
int n_check_trncd_cf(char **pbd_InRecChild)
{
    DEBUT_FCT("n_check_trncd_cf");

							
	if ( 	
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 1151) ||
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 1152) ||
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 2151) ||
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 2152) ||
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 2153) ||
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 3221) ||
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 3222) ||
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 3420) ||
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 2210) ||
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 4206) ||
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 3430) ||
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 6440) ||
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 2211) ||
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 3520) ||
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 3540) ||
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 3172) ||																				
				
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 1051) ||
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 1052) ||
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 1053) ||
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 1057) ||
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 2051) ||
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 2052) ||
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 2053) ||
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 2054) ||
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 2055) ||
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 2056) ||
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 2057) ||
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 3201) ||
			(atoi(pbd_InRecChild[FBOPRSLNK_ACMTRSL3_NT]) == 3202)     					

		) RETURN_VAL(LOFACT);  

        RETURN_VAL(OTHER);
}



// /*==============================================================================
// objet:
// 	Lit le fichier binaire des postes et les met en memoire

// ==============================================================================*/
// int n_ChargerFBOTRSLNK()
// {
// 	int i = 0;

// 	char sz_message[200];

// 	DEBUT_FCT("n_ChargerFBOTRSLNK");
	
//   //printf(" DANS n_ChargerFBOTRSLNK i= %d Ktbd_FBOTRSLNK[i].PRS_CF = %d ; Ktbd_FBOTRSLNK[i].ACMTRS_NT= %d ; Ktbd_FBOTRSLNK[i].DETTRS_CF= %s\n",i, Ktbd_FBOTRSLNK[i].PRS_CF, Ktbd_FBOTRSLNK[i].ACMTRS_NT, Ktbd_FBOTRSLNK[i].DETTRS_CF );


// 	//Pour r�initialiser le buffer du fichier en lecture car sans cela � la 16537 �me ligne on a
// 	// que des lignes avec n'importe quoi dedans, le fflush r�sout cela
// 	fflush( Kp_InputFBOTRSLNK );

// 	while ( fread( &Ktbd_FBOTRSLNK[i], sizeof( T_FBOTRSLNK ), 1, Kp_InputFBOTRSLNK ) == 1 )
// 	{
// 		//if ( Ktbd_FBOTRSLNK[i].PRS_CF == s_PRS_CF )
// 			i += 1;
// 		if ( i > Kn_MaxLigFBOTRSLNK )
// 		{
// 			sprintf(sz_message,"la taille du tableau Ktbd_FBOTRSLNK depasse la taille allouee %d", i);
// 			n_WriteAno(sz_message);
// 			RETURN_VAL( i );
// 		}
		
// 		//printf(" DANS n_ChargerFBOTRSLNK i= %d Ktbd_FBOTRSLNK[i].PRS_CF = %d ; Ktbd_FBOTRSLNK[i].ACMTRS_NT= %d ; Ktbd_FBOTRSLNK[i].DETTRS_CF= %s\n",i, Ktbd_FBOTRSLNK[i].PRS_CF, Ktbd_FBOTRSLNK[i].ACMTRS_NT, Ktbd_FBOTRSLNK[i].DETTRS_CF );

// 	}

// 	RETURN_VAL( i );
// }



 
 
