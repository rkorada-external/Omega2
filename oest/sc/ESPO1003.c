/*==============================================================================
nom de l'application          : ESTIMATION
nom du source                 : ESPO1003.c
révision                      : $Revision: 0 $
date de création              : 07/12/2012
auteur                        : Florent
references des specifications : :spot:24041
squelette de base             : batch
------------------------------------------------------------------------------
description : Generation d'un fichier au format TCTRSTAT
------------------------------------------------------------------------------
historique des modifications :
[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include "struct.h"
#include "ESPO1002.h" //oui oui c'est bien le ESPO1002 !! car il prend aussi le fichier FSTAT, les define des colonnes CTRSTAT_*

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/
#define NB_SEGEST_MAX 10000
#define SEG_SSD_CF     0
#define SEG_SEG_NF     1
#define SEG_UWY_NF     2
#define SEG_CUR_CF     3
#define SEG_SEGNAT_CT  4
#define SEG_CLMAMT_M   5
#define SEG_LOSRAT_R   6
#define SEG_AMORAT_CT  7
T_SEGEST_SOLVENCY Ktbd_Segest[NB_SEGEST_MAX]; 	/* tableau permettant de charger en memoire FSEGEST */
int Kn_NbLig_Segest = 0;   /* nombre de postes dans le tableau */

/*----------------------*/
/* variables de travail */
/*----------------------*/
FILE 		*Kp_OutputFil ; /* pointeur sur le fichier de sortie */
T_RUPTURE_VAR bd_RuptTSEGEST; /* pour chargement tableau TSEGEST */
T_RUPTURE_VAR  	   	bd_RuptUltimates ; /* variable de gestion de la rupture sur le fichier maitre */

int n_InitTSEGEST(T_RUPTURE_VAR  *pbd_Rupt);
int n_ActionLigneTSEGEST( char **ptb_InRecTSEGEST );
double d_RechPosteTSEGEST( int n_ssd, char *sz_seg, int n_uwy, double d_taux );

int n_InitUltimates	 	( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLigneUltimates	( char **pbd_InRec_Cur ) ;

int n_ProcessingRuptureSyncVar (T_RUPTURE_SYNC_VAR  *pbd_Rupt, char **ptb_InRecOwner );
int n_InitVariables( void ) ;
/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc  , char *argv[])
{
	/* Initialisation des signaux */
	InitSig () ;

	if ( n_BeginPgm ( argc, argv ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier de sortie */
	if ( n_OpenFileAppl ( "ESPO1003_O1","wt",&Kp_OutputFil ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_InitTSEGEST(&bd_RuptTSEGEST) ) ExitPgm ( ERR_XX , "" );

	if ( n_InitUltimates( &bd_RuptUltimates ) )
		ExitPgm( ERR_XX , "" ) ;

  /* Chargement du fichier TSEGEST */
	if ( n_ProcessingRuptureVar (&bd_RuptTSEGEST) == ERR ) ExitPgm( ERR_XX , "" );

	/* lancement du traitement du fichier maitre */
	if ( n_ProcessingRuptureVar( &bd_RuptUltimates ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESPO1003_I1", &( bd_RuptUltimates.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESPO1003_I2", &( bd_RuptTSEGEST.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESPO1003_O1", &Kp_OutputFil ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_EndPgm() == ERR )
		ExitPgm( ERR_XX , "" );

	exit(OK) ;
}

/*==============================================================================
objet :     Initialisation du fichier TSEGEST
retour:     OK
==============================================================================*/
int n_InitTSEGEST(T_RUPTURE_VAR  *pbd_Rupt)
{
    DEBUT_FCT("n_InitTSEGEST");

    memset( pbd_Rupt,0,sizeof(T_RUPTURE_VAR) ) ;
		Kn_NbLig_Segest = 0;

    // ouverture du fichier esclave
    n_OpenFileAppl ("ESPO1003_I2","rt",&(pbd_Rupt->pf_InputFil));

    pbd_Rupt->n_NbRupture = 0  ;
    pbd_Rupt->n_ActionLigne = n_ActionLigneTSEGEST;
    pbd_Rupt->c_Separ = SEPARATEUR ;

  RETURN_VAL(OK);
}


/*==============================================================================
objet : fonction lancee pour chaque ligne du perimetre
retour: OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneTSEGEST( char **ptb_InRecTSEGEST )
{

	DEBUT_FCT("n_ActionLigneTSEGEST");

	Ktbd_Segest[Kn_NbLig_Segest].SSD_CF = atoi(ptb_InRecTSEGEST[SEG_SSD_CF]);
	strcpy(Ktbd_Segest[Kn_NbLig_Segest].SEG_NF,ptb_InRecTSEGEST[SEG_SEG_NF]);
	Ktbd_Segest[Kn_NbLig_Segest].UWY_NF = atoi(ptb_InRecTSEGEST[SEG_UWY_NF]);
	strcpy(Ktbd_Segest[Kn_NbLig_Segest].CUR_CF,ptb_InRecTSEGEST[SEG_CUR_CF]);
	Ktbd_Segest[Kn_NbLig_Segest].SEGNAT_CT = *ptb_InRecTSEGEST[SEG_SEGNAT_CT];
	Ktbd_Segest[Kn_NbLig_Segest].CLMAMT_M = atof(ptb_InRecTSEGEST[SEG_CLMAMT_M]);
	Ktbd_Segest[Kn_NbLig_Segest].LOSRAT_R = atof(ptb_InRecTSEGEST[SEG_LOSRAT_R]);
	Ktbd_Segest[Kn_NbLig_Segest].AMORAT_CT = *ptb_InRecTSEGEST[SEG_AMORAT_CT];

	Kn_NbLig_Segest++;

  RETURN_VAL(OK);
}

/*==============================================================================
objet : fonction de recherche du segment
retour : le taux trouvé
==============================================================================*/
double d_RechPosteTSEGEST( int n_ssd, char *sz_seg, int n_uwy, double d_taux )
{
	DEBUT_FCT("d_RechPosteTSEGEST");
	int n_indice = 0;/* Added for Phase1b Migration */ 
	for(n_indice = 0; n_indice < Kn_NbLig_Segest; n_indice++ )   /* Updated for Phase1b Migration */
	{
		if ( strcmp(sz_seg, Ktbd_Segest[n_indice].SEG_NF) == 0 && n_ssd == Ktbd_Segest[n_indice].SSD_CF && Ktbd_Segest[n_indice].UWY_NF == n_uwy )
			return Ktbd_Segest[n_indice].LOSRAT_R;
	}
	// Aucune occurence trouvée, on retourne le taux en entrée
	return d_taux;
}

/*==============================================================================
objet :
	fonction d'initialisation de la variable de gestion de rupture du fichier
	maitre.

retour :
	0K
==============================================================================*/
int n_InitUltimates(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitUltimates" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier maitre */
	if ( n_OpenFileAppl( "ESPO1003_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction d'action sur la ligne courante du fichier maitre */
	pbd_Rupt->n_ActionLigne = n_ActionLigneUltimates ;

	pbd_Rupt->c_Separ = SEPARATEUR ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneUltimates( char **ptb_InRec_Cur )
{
	char sz_ACTLOSRAT_R[12];
	DEBUT_FCT( "n_ActionLigneUltimates" ) ;

 	memset( sz_ACTLOSRAT_R, 0, sizeof(sz_ACTLOSRAT_R) );

  sprintf(sz_ACTLOSRAT_R,"%.8f",d_RechPosteTSEGEST(atoi(ptb_InRec_Cur[CTRSTAT_SSD_CF]),ptb_InRec_Cur[CTRSTAT_ACTSEG_NF],atoi(ptb_InRec_Cur[CTRSTAT_UWY_NF]),atof(ptb_InRec_Cur[CTRSTAT_ACTLOSRAT_R])));

	ptb_InRec_Cur[CTRSTAT_ACTLOSRAT_R] = sz_ACTLOSRAT_R;

	// ecriture en sortie au format de TCTRSTAT
	n_WriteCols( Kp_OutputFil, ptb_InRec_Cur, SEPARATEUR, 0 );

  RETURN_VAL( OK ) ;
}
