/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION lot 23
nom du source                 : ESTC2338.c
révision                      : $Revision: 1.2 $
date de création              : 26/07/1999
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
Filtre du GT par rapport au perimetre retro :  on enleve les postes de PNA/FAR
pour les contrats retro de categories 01 (pool)
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

FILE 		*Kp_OutputFilGt ; /* pointeur sur le fichier de sortie GT */

T_RUPTURE_VAR  	   	bd_RuptPerUw ; /* variable de gestion de la rupture sur le perimetre de
						souscription */
T_RUPTURE_SYNC_VAR 	bd_RuptGt ; /* variable de gestion de la synchronisation avec
						le fichier GT en entree */

int n_InitPerUw	 		( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLignePerUw		( char **pbd_InRec_Cur ) ;

int n_InitGt			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneGt		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncGt		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;


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

	/* ouverture du fichier de sortie GT */
	if ( n_OpenFileAppl ( "ESTC2338_O1","wt",&Kp_OutputFilGt ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPerUw */
	if ( n_InitPerUw( &bd_RuptPerUw ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptGt */
	if ( n_InitGt( &bd_RuptGt ) )
		ExitPgm( ERR_XX , "" ) ;

	/* lancement du traitement du fichier Perimetre de souscription IADPERICASE.dat */
	if ( n_ProcessingRuptureVar( &bd_RuptPerUw ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2338_I1", &( bd_RuptPerUw.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2338_I2", &( bd_RuptGt.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2338_O1", &Kp_OutputFilGt ) == ERR )
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
	if ( n_OpenFileAppl( "ESTC2338_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
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

	/* synchronisation avec le fichier GT */
	n_ProcessingRuptureSyncVar( &bd_RuptGt, ptb_InRec_Cur ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription »
	avec l’esclave « GT »

retour :
	OK
==============================================================================*/
int n_InitGt( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitGt" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC2338_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncGt ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneGt ;

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
int n_ConditionSyncGt(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncGt" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_RETCTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GT_RETEND_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GT_RETSEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_RTY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GT_RETUW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGt(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneGt" ) ;

	/* On ne garde pas les postes de PNA-FAR pour les contrats
           Retro de categorie 01 les pools */

        if (
             (   strncmp( ptb_InRecChild[GT_TRNCOD_CF] + 2, "41000", 5 ) != 0
              && strncmp( ptb_InRecChild[GT_TRNCOD_CF] + 2, "43000", 5 ) != 0
              && strncmp( ptb_InRecChild[GT_TRNCOD_CF] + 2, "41100", 5 ) != 0
              && strncmp( ptb_InRecChild[GT_TRNCOD_CF] + 2, "43100", 5 ) != 0
             ) ||
             (   atoi (ptb_InRecOwner[PER_RETCTRCAT_CF]) != 1 )
           )
           {
           ptb_InRecChild[GT_TRNCOD_CF] = "99999999" ;
           n_WriteCols( Kp_OutputFilGt, ptb_InRecChild, SEPARATEUR, 0 ) ;
           }

	RETURN_VAL( OK ) ;
}



