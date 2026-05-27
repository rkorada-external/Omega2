/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION lot 32
nom du source                 : ESTC3203.c
révision                      : $Revision: 1.2 $
date de création              : 25/06/1997
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description : Affectation du poste cumul


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
#include "ESTC3203.h"

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

FILE 		*Kp_OutputFilMvt ; /* pointeur sur le fichier de sortie mouvement comptable */
T_RUPTURE_VAR  	   	bd_RuptTrsLnk; /* variable de gestion de la rupture sur les postes cumules */
T_RUPTURE_SYNC_VAR 	bd_RuptMvt; /* variable de gestion de la synchronisation */

int n_InitTrsLnk	 		( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLigneTrsLnk		( char **pbd_InRec_Cur ) ;

int n_InitMvt			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneMvt		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncMvt		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

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

	/* ouverture du fichier de sortie Mouvements comptables */
	if ( n_OpenFileAppl ( "ESTC3203_O1","wt",&Kp_OutputFilMvt ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptMvt */
	if ( n_InitMvt( &bd_RuptMvt ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptTrsLnk */
	if ( n_InitTrsLnk( &bd_RuptTrsLnk ) )
		ExitPgm( ERR_XX , "" ) ;

	/* lancement du traitement du fichier Postes cumules */
	if ( n_ProcessingRuptureVar( &bd_RuptTrsLnk ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3203_I1", &( bd_RuptMvt.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3203_I2", &( bd_RuptTrsLnk.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3203_O1", &Kp_OutputFilMvt ) == ERR )
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
int n_InitTrsLnk(T_RUPTURE_VAR  *pbd_Rupt)
{

	DEBUT_FCT( "n_InitTrsLnk" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier maitre Mouvements comptables */
	if ( n_OpenFileAppl( "ESTC3203_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction d'action sur la ligne courante du fichier Postes cumules */
	pbd_Rupt->n_ActionLigne = n_ActionLigneTrsLnk ;

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
int n_ActionLigneTrsLnk( char **ptb_InRec_Cur )
{

	DEBUT_FCT( "n_ActionLigneTrsLnk" ) ;

	/* synchronisation du fichier mouvement comptable pour chaque ligne */
	n_ProcessingRuptureSyncVar( &bd_RuptMvt, ptb_InRec_Cur ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la variable de gestion de synchronisation

retour :
	OK
==============================================================================*/
int n_InitMvt(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{

	DEBUT_FCT( "n_InitMvt" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave Mouvement comptables */
	if ( n_OpenFileAppl( "ESTC3203_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncMvt ;

	/* fonction d'action sur la ligne courante du fichier Postes cumules */
	pbd_Rupt->n_ActionLigne = n_ActionLigneMvt ;

	pbd_Rupt->c_Separ = '~' ;

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
int n_ConditionSyncMvt(
	char **pbd_InRecOwner , /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{

	int ret ;

	DEBUT_FCT( "n_ConditionSyncMvt" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[LNK_DETTRS_CF], pbd_InRecChild[MVT_TRNCOD_CF] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneMvt(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */

{
	int n_AcmTrs = 0 ;
	char sz_AcmTrs[30] ;

	DEBUT_FCT( "n_ActionLigneMvt" ) ;

	/* Affectation du poste cumul a l'ecriture comptable */
	ptb_InRecChild[MVT_ACMTRS_NT] = sz_AcmTrs ;
	strcpy( sz_AcmTrs, ptb_InRecOwner[LNK_ACMTRS_NT] ) ;

	if ( 	( *ptb_InRecChild[MVT_CTRNAT_CT] == 'N' ) ||
	 	( *ptb_InRecChild[MVT_CTRNAT_CT] == 'F' ) ||
		( *ptb_InRecChild[MVT_CTRNAT_CT] == 'P' &&
	    	( ( atoi( ptb_InRecChild[MVT_ACY_NF] ) < atoi( ptb_InRecChild[MVT_CPLACCY_NF] ) ) ||
		( ( atoi( ptb_InRecChild[MVT_ACY_NF] ) == atoi( ptb_InRecChild[MVT_CPLACCY_NF] ) ) &&
		( atoi( ptb_InRecChild[MVT_SCOENDMTH_NF] ) <= atoi( ptb_InRecChild[MVT_SCOLSTMTH_NF] ) ) ) ) ) )
	{
	n_AcmTrs = atoi( ptb_InRecChild[MVT_ACMTRS_NT] ) * -1 ;
	sprintf( ptb_InRecChild[MVT_ACMTRS_NT], "%d", n_AcmTrs )  ;
	}

	/* Ecriture dans le fichier Mouvement comptable */
	n_WriteCols( Kp_OutputFilMvt, ptb_InRecChild, '~', 0 ) ;

	RETURN_VAL( OK ) ;
}

