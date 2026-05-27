/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION Solvency
nom du source                 : ESTC1053.c
révision                      : $Revision: 1.2 $
date de création              : 31/05/2012
auteur                        : Roger Cassis
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   :spot:23802 Affectation du segment dans le perimetre Retro

------------------------------------------------------------------------------
historique des modifications :
[001] 31/08/2012 Roger Cassis :spot:24041 Solvency 2
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include "struct.h"

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/
#define SEG_SEG_NF 5
#define SEG_EGPCUR_CF 6
#define SEG_SCOEGP_M 7     // (001]

/*----------------------*/
/* variables de travail */
/*----------------------*/
FILE   *Kp_OutputFilPerUw ; /* pointeur sur le fichier de sortie Perimetre retro */

T_RUPTURE_VAR        bd_RuptPerUw ; /* variable de gestion de la rupture sur le perimetre de	souscription */
T_RUPTURE_SYNC_VAR   bd_RuptSeg ;   /* variable de gestion de la synchronisation avec le fichier Segment en entree */

int n_InitPerUw             ( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLignePerUw      ( char **pbd_InRec_Cur ) ;
int n_ActionPereSansFilsSeg ( char ** );

int n_InitSeg           ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneSeg    ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncSeg  ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_ProcessingRuptureSyncVar (	T_RUPTURE_SYNC_VAR  *pbd_Rupt, char **ptb_InRecOwner );


/*==============================================================================
objet : Point d'entree du programme

retour : En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
         Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc  , char *argv[])
{
	/* Initialisation des signaux */
	InitSig () ;

	if ( n_BeginPgm ( argc, argv ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier de sortie GT */
	if ( n_OpenFileAppl ( "ESTC1053_O1","wt",&Kp_OutputFilPerUw ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPerUw */
	if ( n_InitPerUw( &bd_RuptPerUw ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptSeg */
	if ( n_InitSeg( &bd_RuptSeg ) )
		ExitPgm( ERR_XX , "" ) ;

	/* lancement du traitement du fichier Perimetre de souscription IADPERICASE.dat */
	if ( n_ProcessingRuptureVar( &bd_RuptPerUw ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1053_I1", &( bd_RuptPerUw.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1053_I2", &( bd_RuptSeg.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1053_O1", &Kp_OutputFilPerUw ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_EndPgm() == ERR )
		ExitPgm( ERR_XX , "" );

	exit(OK) ;
}


/*==============================================================================
objet : fonction d'initialisation de la variable de gestion de rupture du fichier maitre.

retour : 0K
==============================================================================*/
int n_InitPerUw(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitPerUw" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier maitre Perimetre de souscription */
	if ( n_OpenFileAppl( "ESTC1053_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction d'action sur la ligne courante du fichier maitre */
	pbd_Rupt->n_ActionLigne = n_ActionLignePerUw ;

	pbd_Rupt->c_Separ = SEPARATEUR ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet : fonction lancee pour chaque ligne

retour : OK ---> traitement correctement effectue
	      ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePerUw( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionLignePerUw" ) ;

	/* synchronisation avec le fichier GT */
	n_ProcessingRuptureSyncVar( &bd_RuptSeg, ptb_InRec_Cur ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet : Initialisation de la synchronisation du maitre « Perimetre retro »
        avec l’esclave « Seg »

retour : OK
==============================================================================*/
int n_InitSeg( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitSeg" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC1053_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncSeg ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneSeg ;
	pbd_Rupt->n_PereSansFils = n_ActionPereSansFilsSeg ;  // fonction d'action quand le maitre PerUw n'a pas de fils Seg
	
	pbd_Rupt->c_Separ = SEPARATEUR ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet : fonction de test de synchronisation

retour : = 0 ---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
         > 0 ---> pbd_InRecOwner > pbd_InRecChild
         < 0 ---> pbd_InRecOwner < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncSeg(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncSeg" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[PERFR_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[PERFR_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = atoi(pbd_InRecOwner[PER_SEC_NF]) - atoi(pbd_InRecChild[PERFR_SEC_NF]) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[PERFR_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT],  pbd_InRecChild[PERFR_UW_NT]  ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet : fonction lancee pour chaque ligne

retour : OK  ---> traitement correctement effectue
         ERR ---> probleme rencontre
==============================================================================*/
int n_ActionLigneSeg(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	int    n_Col=0;
	char	 *Irdpericase[PER_NBCOL+1] ; /* tableau de pointeur a l'image du fichier Perimetre en sortie */

	DEBUT_FCT( "n_ActionLigneSeg" ) ;

	for(n_Col=0;n_Col<PER_NBCOL;n_Col++)
	{
		Irdpericase[n_Col] = ptb_InRecOwner[n_Col];
	}

	Irdpericase[PER_SEG_NF] = ptb_InRecChild[SEG_SEG_NF];
	Irdpericase[PER_EGPCUR_CF] = ptb_InRecChild[SEG_EGPCUR_CF];
	Irdpericase[PER_SCOEGP_M] = ptb_InRecChild[SEG_SCOEGP_M];      // [001]

	/* reconduction en sortie de la ligne du Perimetre avec le segment */
   n_WriteCols(Kp_OutputFilPerUw, Irdpericase, '~', 0);
	
	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet : fonction lancee quand le pere n'a pas de fils GT

retour: OK ---> traitement correctement effectue
        ERR --> probleme rencontre
dans ce cas on reporte telle quelle la ligne dans le fichier en sortie
==============================================================================*/
int  n_ActionPereSansFilsSeg(char **ptb_InRecOwner )
{
	int    n_Col=0;
	char	 *Irdpericase[PER_NBCOL+1] ; /* tableau de pointeur a l'image du fichier Perimetre en sortie */

	DEBUT_FCT( "n_ActionPereSansFilsSeg" ) ;

	for(n_Col=0;n_Col<PER_NBCOL;n_Col++)
	{
		Irdpericase[n_Col] = ptb_InRecOwner[n_Col];
	}

	/* reconduction en sortie de la ligne du Perimetre avec le segment */
   n_WriteCols(Kp_OutputFilPerUw, Irdpericase, '~', 0);
	
	RETURN_VAL( OK ) ;
}


