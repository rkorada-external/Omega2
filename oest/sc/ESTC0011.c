/*==============================================================================
nom de l'application          : ESTIMATION
nom du source                 : ESTC0011.c
révision                      : $Revision: 1.2 $
date de création              : 12 04 2001
auteur                        : S. Llorente
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   filtres sur le FTECLEDR:
   		placements valides (SSDRTO_B == 1)
		placements rachetes : synchro avec FPLACEMT1
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
#include "ESTC0011.h"
#include "ESTC8802.h"

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/


/*----------------------*/
/* variables de travail */
/*----------------------*/
int Kn_Sync; /* flag de synchro : le placement est de type rachete ie plcsts ==23 */


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

	/* ouverture du fichier de sortie GTR */
	if ( n_OpenFileAppl ( "ESTC0011_O1","wt",&Kp_OutputFilGtr ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptGtr */
	if ( n_InitGtr( &bd_RuptGtr ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPlc */
	if ( n_InitTotPlc( &bd_RuptPlc ) )
		ExitPgm( ERR_XX , "" ) ;

	/* lancement du traitement du fichier GTR */
	if ( n_ProcessingRuptureVar( &bd_RuptGtr ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC0011_I1", &( bd_RuptGtr.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC0011_I2", &( bd_RuptPlc.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC0011_O1", &Kp_OutputFilGtr ) == ERR )
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
int n_InitGtr(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitGtr" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	if ( n_OpenFileAppl( "ESTC0011_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	pbd_Rupt->n_NbRupture = 1 ;
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1Gtr ;
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptGtr ;
	pbd_Rupt->n_ActionLigne = n_ActionLigneGtr ;
	pbd_Rupt->c_Separ = SEPARATEUR ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction de test de rupture de niveau 1

retour :
	0	---> pas de rupture
	sinon   	---> rupture
==============================================================================*/
int n_IsR1Gtr( char **pbd_InRec ,  char **pbd_InRec_Cur  )
{
	int ret ;

	DEBUT_FCT( "n_IsR1Gtr" ) ;

	if ( ( ret = strcmp( pbd_InRec[TECLEDR_RETCTR_NF], pbd_InRec_Cur[TECLEDR_RETCTR_NF] ) ) != 0 ) RETURN_VAL (ret) ;
	if ( ( ret = strcmp( pbd_InRec[TECLEDR_RETEND_NT], pbd_InRec_Cur[TECLEDR_RETEND_NT] ) ) != 0 ) RETURN_VAL (ret) ;
	if ( ( ret = strcmp( pbd_InRec[TECLEDR_RETSEC_NF], pbd_InRec_Cur[TECLEDR_RETSEC_NF] ) ) != 0 ) RETURN_VAL (ret) ;
	if ( ( ret = strcmp( pbd_InRec[TECLEDR_RTY_NF], pbd_InRec_Cur[TECLEDR_RTY_NF] ) ) != 0 ) RETURN_VAL (ret) ;
	if ( ( ret = strcmp( pbd_InRec[TECLEDR_RETUW_NT], pbd_InRec_Cur[TECLEDR_RETUW_NT] ) ) != 0 ) RETURN_VAL (ret) ;
	if ( ( ret = strcmp( pbd_InRec[TECLEDR_PLC_NT], pbd_InRec_Cur[TECLEDR_PLC_NT] ) ) != 0 ) RETURN_VAL (ret) ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture premiere de niveau 1

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRuptGtr( char **ptb_InRec_Cur  )
{
	DEBUT_FCT( "n_ActionFirstRuptGtr" ) ;

	Kn_Sync = 0;

	/* synchronisation avec le fichier des placements */
	n_ProcessingRuptureSyncVar( &bd_RuptPlc, ptb_InRec_Cur ) ;

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGtr( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionLigneGtr" ) ;

	/* ecriture en sortie du GTR au format de TTECLEDR si le placement est valide
	   OU s'il est rachete */
	if ( ( atoi(ptb_InRec_Cur[TECLEDR_SSDRTO_B]) == 1 ) || (Kn_Sync == 1) )
		n_WriteCols( Kp_OutputFilGtr, ptb_InRec_Cur, SEPARATEUR, 0 ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « GTR »
	avec l’esclave « Placements »

retour :
	OK
==============================================================================*/
int n_InitTotPlc( T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitTotPlc" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave des placements */
	if ( n_OpenFileAppl( "ESTC0011_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	pbd_Rupt->ConditionEndSync = n_ConditionSyncPlc ;
	pbd_Rupt->n_ActionLigne = n_ActionLignePlc ;
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
int n_ConditionSyncPlc( char **pbd_InRecOwner ,  char **pbd_InRecChild  )
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncPlc" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[TECLEDR_RETCTR_NF], pbd_InRecChild[PLA_RETCTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[TECLEDR_RETEND_NT], pbd_InRecChild[PLA_RETEND_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[TECLEDR_RETSEC_NF], pbd_InRecChild[PLA_RETSEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[TECLEDR_RTY_NF], pbd_InRecChild[PLA_RTY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[TECLEDR_RETUW_NT], pbd_InRecChild[PLA_RETUW_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[TECLEDR_PLC_NT], pbd_InRecChild[PLA_PLC_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePlc( char **ptb_InRecOwner , char **ptb_InRecChild )
{
	DEBUT_FCT( "n_ActionLignePlc" ) ;

	Kn_Sync = 1;

	RETURN_VAL( OK ) ;
}






