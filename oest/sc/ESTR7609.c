/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTR7609.c
révision                      : $Revision: 1.2 $
date de création              : 11/09/1997
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   INJECTION DU TYPE DE NATURE ACCEPTATION

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
	   ...           ...            ...              ...
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "struct.h"


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

FILE 		*Kp_OutputFilGta ; /* pointeur sur le fichier de sortie GTA */


T_RUPTURE_VAR  	   	bd_RuptPerUw ; /* variable de gestion de la rupture sur le perimetre de
						souscription */
T_RUPTURE_SYNC_VAR 	bd_RuptGtar ; /* variable de gestion de la synchronisation avec
						le fichier GTAr */


int n_InitPerUw	 		( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLignePerUw		( char **pbd_InRec_Cur ) ;

int n_InitGtar			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ConditionSyncGtar		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ActionLigneGtar		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ActionFilsSansPereGtar	( char **pbd_InRecChild ) ;

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
int main(int argc  , char *argv[])
{
	/* Initialisation des signaux */
	InitSig () ;

	if ( n_BeginPgm ( argc, argv ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier de sortie GTA */
	if ( n_OpenFileAppl ( "ESTR7609_O1","wt",&Kp_OutputFilGta ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPerUw */
	if ( n_InitPerUw( &bd_RuptPerUw ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptGtar */
	if ( n_InitGtar( &bd_RuptGtar ) )
		ExitPgm( ERR_XX , "" ) ;

	/* lancement du traitement du fichier Perimetre de souscription IADPERICASE.dat */
	if ( n_ProcessingRuptureVar( &bd_RuptPerUw ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTR7609_I1", &( bd_RuptPerUw.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTR7609_I2", &( bd_RuptGtar.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTR7609_O1", &Kp_OutputFilGta ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

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
int n_InitPerUw(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitPerUw" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier maitre Perimetre de souscription */
	if ( n_OpenFileAppl( "ESTR7609_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction d'action sur la ligne courante du fichier maitre */
	pbd_Rupt->n_ActionLigne = n_ActionLignePerUw ;

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
int n_ActionLignePerUw( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionLignePerUw" ) ;

	/* synchronisation avec le fichier GTAr */
	n_ProcessingRuptureSyncVar( &bd_RuptGtar, ptb_InRec_Cur ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription »
	avec l’esclave « GTAr »

retour :
	OK
==============================================================================*/
int n_InitGtar( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitGtar" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTR7609_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncGtar ;

	/* fonction d'action quand l'esclave n'a pas de maitre */
	pbd_Rupt->n_FilsSansPere = n_ActionFilsSansPereGtar ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneGtar ;

	pbd_Rupt->c_Separ = SEPARATEUR ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction de test de synchronisation

retour :
	0	---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
	> 0   	---> pbd_InRecOwne> > pbd_InRecChild
	< 0   	---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncGtar(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncGta" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GT_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GT_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGtar(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneGtar" ) ;

	/* memorisation de la nature de l'affaire */
	ptb_InRecChild[GT_RETKEY_CF + 1] = ptb_InRecOwner[PER_CTRNAT_CT] ;

	/* ecriture en sortie du fichier GTA */
	n_WriteCols( Kp_OutputFilGta, ptb_InRecChild, SEPARATEUR, 0 ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee quand le fils n'a pas de maitre

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFilsSansPereGtar(
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionFilsSansPereGtar" ) ;

	/* affectation de la nature de l'affaire */
	ptb_InRecChild[GT_RETKEY_CF + 1] = "X" ;

	/* ecriture en sortie du fichier GTA */
	n_WriteCols( Kp_OutputFilGta, ptb_InRecChild, SEPARATEUR, 0 ) ;

	RETURN_VAL( OK ) ;
}


