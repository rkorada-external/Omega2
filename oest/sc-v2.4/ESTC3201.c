/*==============================================================================
nom de l'application          : ESTIMATION lot 32
nom du source                 : ESTC3201.c
révision                      : $Revision:   1.0  $
date de création              : 23/06/1997
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   Mise en phase des lignes comptables - liste des affaires
	- suppression des affaires de la liste des affaires n'ayant pas de mouvement comptable
	- suppression des lignes pour lesquelles il n'existe pas d'affaire dans la liste des affaires


------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	   ...           ...            ...              ...
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include "ESTC3201.h"
	
/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE 		*Kp_OutputFilMvt ; /* pointeur sur le fichier de sortie liste des affaires */
FILE 		*Kp_OutputFilAff ; /* pointeur sur le fichier de sortie mouvement comptable */
T_RUPTURE_VAR  	   	bd_RuptAff; /* variable de gestion de la rupture sur la liste des affaires */
T_RUPTURE_SYNC_VAR 	bd_RuptMvt; /* variable de gestion de la synchronisation */

int n_InitMvt		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ConditionSyncMvt	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_IsR1Mvt		( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_ActionFirstRuptMvt( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ActionLigneMvt	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitAff	 	( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLigneAff	( char **pbd_InRec_Cur ) ;

int n_ProcessingRuptureSyncVar (
			T_RUPTURE_SYNC_VAR  *pbd_Rupt, 
			char **ptb_InRecOwner );


/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
void main(int argc  , char *argv[])
{

	/* Initialisation des signaux */
	InitSig () ;

	if ( n_BeginPgm ( argc, argv ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier de sortie Mouvement comptable */
	if ( n_OpenFileAppl ( "ESTC3201_O1","wt",&Kp_OutputFilMvt ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier de sortie Liste des affaires */
	if ( n_OpenFileAppl ( "ESTC3201_O2","wt",&Kp_OutputFilAff ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptMvt */
	if ( n_InitMvt( &bd_RuptMvt ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptAff */
	if ( n_InitAff( &bd_RuptAff ) )
		ExitPgm( ERR_XX , "" ) ;

	/* lancement du traitement du fichier Liste des affaires ESTCTRLIS_01.dat */	
	if ( n_ProcessingRuptureVar( &bd_RuptAff ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3201_I1", &( bd_RuptMvt.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3201_I2", &( bd_RuptAff.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3201_O1", &Kp_OutputFilMvt ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3201_02", &Kp_OutputFilAff ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_EndPgm() == ERR )
		ExitPgm( ERR_XX , "" );

	exit(OK) ;
}


/*==============================================================================
objet :
	fonction d'initialisation de la variable de gestion de rupture du fichier
	maitre.

retour :
	0K
==============================================================================*/
n_InitAff(T_RUPTURE_VAR  *pbd_Rupt)
{

	DEBUT_FCT( "n_InitAff" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier maitre Liste des affaires */
	if ( n_OpenFileAppl( "ESTC3201_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction d'action sur la ligne courante du fichier Liste des affaires */
	pbd_Rupt->n_ActionLigne = n_ActionLigneAff ;

	pbd_Rupt->c_Separ = '~' ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneAff( char **ptb_InRec_Cur )
{

	DEBUT_FCT( "n_ActionLigneAff" ) ;

	/* synchronisation du fichier mouvement comptable pour chaque ligne */
	n_ProcessingRuptureSyncVar( &bd_RuptMvt, ptb_InRec_Cur ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Liste des affaires » avec
	l’esclave « Mouvement comptable »

retour :
	OK
==============================================================================*/
n_InitMvt(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{

	DEBUT_FCT( "n_InitMvt" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave Mouvement comptable */
	if ( n_OpenFileAppl( "ESTC3201_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR ) 
		return ERR ;

	/* nombre de rupture a gerer sur le fichier mouvements comptables */
	pbd_Rupt->n_NbRupture = 1 ;

	/* fonction de test de rupture de niveau 1 */
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1Mvt ;

	/* fonction du test de synchronisation de la ligne du maitre Liste des affaires avec l'esclave Mouvement comptable */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncMvt ;

	/* fonction lancee en rupture premiere */
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptMvt ;

	/* fonction d'action sur la ligne courante du fichier Mouvement comptable */
	pbd_Rupt->n_ActionLigne = n_ActionLigneMvt ;

	pbd_Rupt->c_Separ = '~' ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction de test de rupture de niveau 1

retour :
	0	---> pas de rupture
	!= 0   	---> rupture
==============================================================================*/
int n_IsR1Mvt(
	char **pbd_InRec, 	/* adresse de la ligne en avance */
	char **pbd_InRec_Cur )	/* adresse de la ligne courante */ 
{

	int ret ;

	DEBUT_FCT( "n_IsR1Mvt" ) ;

	if ( ( ret = strcmp( pbd_InRec[MVT_CTR_NF], pbd_InRec_Cur[MVT_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[MVT_END_NT], pbd_InRec_Cur[MVT_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[MVT_SEC_NF], pbd_InRec_Cur[MVT_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[MVT_UWY_NF], pbd_InRec_Cur[MVT_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[MVT_UW_NT], pbd_InRec_Cur[MVT_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction de test de synchronisation

retour :
	0	---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
	> 0   	---> pbd_InRecOwne> > pbd_InRecChild
	< 0   	---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncMvt(
	char **pbd_InRecOwner , /* adresse de la ligne du maitre Liste des affaires */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave Mouvement comptable */
{

	int ret ;

	DEBUT_FCT( "n_ConditionSyncMvt" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[AFF_CTR_NF], pbd_InRecChild[MVT_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[AFF_END_NT], pbd_InRecChild[MVT_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[AFF_SEC_NF], pbd_InRecChild[MVT_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[AFF_UWY_NF], pbd_InRecChild[MVT_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[AFF_UW_NT], pbd_InRecChild[MVT_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture premiere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRuptMvt(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre Liste des affaires */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave Mouvement comptable */

{	
	DEBUT_FCT( "n_ActionFirstRuptMvt" ) ;

	/* Ecriture dans le fichier Liste des affaires */
	n_WriteCols( Kp_OutputFilAff, ptb_InRecOwner, '~', 0 ) ;

	RETURN_VAL( OK ) ;
}



/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneMvt(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre Liste des affaires */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave Mouvement comptable */

{	
	
	DEBUT_FCT( "n_ActionLigneMvt" ) ;

	/* Affectation des rubriques du fichier Mouvement comptable */
	ptb_InRecChild[MVT_CTRNAT_CT] = ptb_InRecOwner[AFF_CTRNAT_CT] ;
	ptb_InRecChild[MVT_CPLACCY_NF] = ptb_InRecOwner[AFF_CPLACCY_NF] ;
	ptb_InRecChild[MVT_SCOLSTMTH_NF] = ptb_InRecOwner[AFF_SCOLSTMTH_NF] ;
	ptb_InRecChild[MVT_EGPCUR_CF] = ptb_InRecOwner[AFF_EGPCUR_CF] ;

	/* Ecriture dans le fichier Mouvement comptable */
	n_WriteCols( Kp_OutputFilMvt, ptb_InRecChild, '~', 0 ) ;

	RETURN_VAL( OK ) ;
}

