/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION lot 32
nom du source                 : ESTC3205.c
révision                      : $Revision: 1.2 $
date de création              : 26/06/1997
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description : 	Conversion des montants en devise de l'aliment
   	- Recherche taux de conversion de la monnaie origine acceptation


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
#include "ESTC3205.h"

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
T_RUPTURE_VAR  	   	bd_RuptExc; /* variable de gestion de la rupture sur le fichier des cours de change */
T_RUPTURE_SYNC_VAR 	bd_RuptMvt; /* variable de gestion de la synchronisation */

int n_InitMvt		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneMvt	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncMvt	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ActionFilsSansPereMvt ( char **ptb_InRecChild ) ;

int n_InitExc	 	( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLigneExc	( char **pbd_InRec_Cur ) ;

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

	/* ouverture du fichier de sortie Mouvement comptable */
	if ( n_OpenFileAppl ( "ESTC3205_O1","wt",&Kp_OutputFilMvt ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptMvt */
	if ( n_InitMvt( &bd_RuptMvt ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptExc */
	if ( n_InitExc( &bd_RuptExc ) )
		ExitPgm( ERR_XX , "" ) ;

	/* lancement du traitement du fichier Cours de change */
	if ( n_ProcessingRuptureVar( &bd_RuptExc ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3205_I1", &( bd_RuptMvt.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3205_I2", &( bd_RuptExc.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3205_O1", &Kp_OutputFilMvt ) == ERR )
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
int n_InitExc(T_RUPTURE_VAR  *pbd_Rupt)
{

	DEBUT_FCT( "n_InitExc" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier maitre Cours de change */
	if ( n_OpenFileAppl( "ESTC3205_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction d'action sur la ligne courante du fichier maitre */
	pbd_Rupt->n_ActionLigne = n_ActionLigneExc ;

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
int n_ActionLigneExc( char **ptb_InRec_Cur )
{

	DEBUT_FCT( "n_ActionLigneExc" ) ;

	/* synchronisation du fichier mouvement comptable pour chaque ligne */
	n_ProcessingRuptureSyncVar( &bd_RuptMvt, ptb_InRec_Cur ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction d'initialisation de la variable de gestion de synchronisation.

retour :
	OK
==============================================================================*/
int n_InitMvt(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{

	DEBUT_FCT( "n_InitMvt" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave Mouvement comptable */
	if ( n_OpenFileAppl( "ESTC3205_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncMvt ;

	/* fonction d'action sur la ligne courante du fichier Mouvement comptable */
	pbd_Rupt->n_ActionLigne = n_ActionLigneMvt ;

	/* fonction d'action quand l'esclave n'a pas de maitre */
	pbd_Rupt->n_FilsSansPere = n_ActionFilsSansPereMvt ;

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
	char **pbd_InRecOwner , /* adresse de la ligne du maitre Liste des affaires */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave Mouvement comptable */
{

	int ret ;

	DEBUT_FCT( "n_ConditionSyncMvt" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[EXC_SSD_CF], pbd_InRecChild[MVT_SSD_CF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[EXC_CUR_CF], pbd_InRecChild[MVT_EGPCUR_CF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[EXC_EXCYEA_NF], pbd_InRecChild[MVT_BALSHEY_NF] ) ) != 0 ) return ret ;

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
	double d_PmdEgp = 0 ;
	char	sz_PmdEgp[30] ;

	DEBUT_FCT( "n_ActionLigneMvt" ) ;

	/* Affectation des rubriques du fichier Mouvement comptable */
	ptb_InRecChild[MVT_EGPCUR_R] = ptb_InRecOwner[EXC_EXC_R] ;
	ptb_InRecChild[MVT_EGPCUR_M] = sz_PmdEgp ;

	/* Calcul du montant en devise de l'aliment */
	d_PmdEgp = atof( ptb_InRecChild[MVT_AMT_M] ) /  atof( ptb_InRecChild[MVT_EGPCUR_R] ) * atof( ptb_InRecChild[MVT_CUR_R] ) ;
	sprintf( ptb_InRecChild[MVT_EGPCUR_M], "%18.3f", d_PmdEgp ) ;

	/* Ecriture dans le fichier Mouvement comptable */
	n_WriteCols( Kp_OutputFilMvt, ptb_InRecChild, '~', 0 ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee quand l'esclave n'a pas de maitre

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFilsSansPereMvt(
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */

{
	char	MsgAno[300] ; /* message d'anomalie */

	DEBUT_FCT( "n_ActionFilsSansPereMvt" ) ;

	sprintf( MsgAno, "The EGPI currency %s of this (Subsidary %s - Balancesheet year %s - Contract %s - End %s - Sec %s - UWY %s - UW %s) doesn't exist in the exchange currency table BREF..TCURQUOT\n",
		ptb_InRecChild[MVT_EGPCUR_CF], ptb_InRecChild[MVT_SSD_CF],  ptb_InRecChild[MVT_BALSHEY_NF],
		ptb_InRecChild[MVT_CTR_NF],  ptb_InRecChild[MVT_END_NT],  ptb_InRecChild[MVT_SEC_NF],
		ptb_InRecChild[MVT_UWY_NF],  ptb_InRecChild[MVT_UW_NT] ) ;

	n_WriteAno( MsgAno ) ;

	RETURN_VAL( OK ) ;
}
