/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTC2310.c
révision                      : $Revision: 1.2 $
date de création              : 16/09/1997
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   PRISE EN COMPTE DES RETARDS A LA PART

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

FILE 		*Kp_OutputFilGt ; /* pointeur sur le fichier de sortie GT */

T_RUPTURE_VAR 			bd_RuptPlc ; /* variable de gestion de la rupture sur le fichier des placements */
T_RUPTURE_SYNC_VAR  	   	bd_RuptGt ; /* variable de gestion de la synchronisation avec le GT */


int n_InitPlc	 		( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLignePlc		( char **pbd_InRec_Cur ) ;

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

	/* ouverture du fichier en sortie GT */
	if ( n_OpenFileAppl ( "ESTC2310_O1","wt",&Kp_OutputFilGt ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptGt */
	if ( n_InitGt( &bd_RuptGt ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPlc */
	if ( n_InitPlc( &bd_RuptPlc ) )
		ExitPgm( ERR_XX , "" ) ;

	/* lancement du traitement du fichier Perimetre de souscription */
	if ( n_ProcessingRuptureVar( &bd_RuptPlc ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2310_I1", &( bd_RuptGt.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2310_I2", &( bd_RuptPlc.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2310_O1", &Kp_OutputFilGt ) == ERR )
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
int n_InitPlc(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitPlc" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier maitre GT */
	if ( n_OpenFileAppl( "ESTC2310_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction d'action sur la ligne courante du fichier maitre */
	pbd_Rupt->n_ActionLigne = n_ActionLignePlc ;

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
int n_ActionLignePlc( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionLignePlc" ) ;

	/* synchronisation avec le fichier GT des derniers placements */
	n_ProcessingRuptureSyncVar( &bd_RuptGt, ptb_InRec_Cur ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « GT »
	avec l’esclave « fichier des derniers placements »

retour :
	OK
==============================================================================*/
int n_InitGt( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitGt" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC2310_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
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

	if ( ( ret = strcmp( pbd_InRecOwner[PLA_RETCTR_NF], pbd_InRecChild[GT_RETCTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PLA_RETEND_NT], pbd_InRecChild[GT_RETEND_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PLA_RETSEC_NF], pbd_InRecChild[GT_RETSEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PLA_RTY_NF], pbd_InRecChild[GT_RTY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PLA_RETUW_NT], pbd_InRecChild[GT_RETUW_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PLA_PLC_NT], pbd_InRecChild[GT_PLC_NT] ) ) != 0 ) return ret ;

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
	DEBUT_FCT( "n_ActionLignePlc" ) ;

	/* mise a jour des champs: esb/cedante/courtier/payeur/cle payeur retro */
	ptb_InRecChild[GT_ESB_CF] = ptb_InRecOwner[PLA_ESB_CF] ;
	ptb_InRecChild[GT_RTO_NF] = ptb_InRecOwner[PLA_RTO_NF] ;
	ptb_InRecChild[GT_INT_NF] = ptb_InRecOwner[PLA_INT_NF] ;
	ptb_InRecChild[GT_RETPAY_NF] = ptb_InRecOwner[PLA_PAY_NF] ;
	ptb_InRecChild[GT_RETKEY_CF] = ptb_InRecOwner[PLA_KEY_CF] ;

	n_WriteCols( Kp_OutputFilGt, ptb_InRecChild, SEPARATEUR, 0 ) ;

	RETURN_VAL( OK ) ;
}







