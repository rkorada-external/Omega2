/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTR7613.c
révision                      : $Revision: 1.2 $
date de création              : 12/09/1997
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   PREPARATION DE L'ETAT SYNTHETIQUE DE CONTROLE D'INVENTAIRE RETROCESSION - ETAPE 2

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
#include "ESTR7613.h"

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/



/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE 		*Kp_OutputFilReport ; /* pointeur sur le fichier de sortie preparation de l'edition */

T_RUPTURE_VAR  	bd_RuptFti ; /* variable de gestion de la rupture sur le fichier de travail */

double		Kd_Amt_fl[14] ; /* tableau des montants cumules par poste cumul pour un couple: filiale/Lob */

int n_InitFti	 		( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_IsR1Fti			( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_ActionFirstRuptFti	( char **pbd_InRec_Cur ) ;
int n_ActionLigneFti		( char **pbd_InRec_Cur ) ;
int n_ActionLastRuptFti	( char **pbd_InRec_Cur ) ;



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

	/* ouverture du fichier de sortie preparation de l'edition */
	if ( n_OpenFileAppl ( "ESTR7613_O1","wt",&Kp_OutputFilReport ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptFti */
	if ( n_InitFti( &bd_RuptFti ) )
		ExitPgm( ERR_XX , "" ) ;

	/* lancement du traitement du fichier intermediaire */
	if ( n_ProcessingRuptureVar( &bd_RuptFti ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTR7613_O1", &Kp_OutputFilReport ) == ERR )
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
int n_InitFti(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitFti" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier */
	if ( n_OpenFileAppl( "ESTR7613_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 1 ;

	/* fonction du test de rupture de niveau 1 */
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1Fti ;

	/* Fonction lancee en rupture premiere de niveau 1 */
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptFti ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneFti ;

	/* Fonction lancee en rupture derniere de niveau 1 */
	pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptFti ;

	pbd_Rupt->c_Separ = '~' ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction de test de rupture de niveau 1

retour :
	0	---> pas de rupture
	sinon   	---> rupture
==============================================================================*/
int n_IsR1Fti(
	char **pbd_InRec ,  /* adresse de la ligne en avance */
	char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
	int ret ;

	DEBUT_FCT( "n_IsR1Fti" ) ;

	if ( ( ret = strcmp( pbd_InRec[FTIR_SSD_CF], pbd_InRec_Cur[FTIR_SSD_CF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[FTIR_LOB_CF], pbd_InRec_Cur[FTIR_LOB_CF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[FTIR_CTRNAT_CT], pbd_InRec_Cur[FTIR_CTRNAT_CT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture premiere de niveau 1

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRuptFti( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionFirstRuptFti" ) ;

	/* tableau des montants cumules par poste cumul pour un couple: filiale/Lob */
	memset( Kd_Amt_fl, 0, sizeof( Kd_Amt_fl ) ) ;

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneFti( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionLigneFti" ) ;

	/* affectation des postes du tableau Kd_Amt_fel */
	switch( atol( ptb_InRec_Cur[FTIR_ACMTRS_NT] ) )
	{
	case 10000 :
		Kd_Amt_fl[ACMTRS_10000] = atof( ptb_InRec_Cur[FTIR_AMT_M] ) ;
		break ;

	case 10030 :
		Kd_Amt_fl[ACMTRS_10030] = atof( ptb_InRec_Cur[FTIR_AMT_M] ) ;
		break ;

	case 10031 :
		Kd_Amt_fl[ACMTRS_10031] = atof( ptb_InRec_Cur[FTIR_AMT_M] ) ;
		break ;

	case 10100 :
		Kd_Amt_fl[ACMTRS_10100] = atof( ptb_InRec_Cur[FTIR_AMT_M] ) ;
		break ;

	case 10130 :
		Kd_Amt_fl[ACMTRS_10130] = atof( ptb_InRec_Cur[FTIR_AMT_M] ) ;
		break ;

	case 10200 :
		Kd_Amt_fl[ACMTRS_10200] = atof( ptb_InRec_Cur[FTIR_AMT_M] ) ;
		break ;

	case 10430 :
		Kd_Amt_fl[ACMTRS_10430] = atof( ptb_InRec_Cur[FTIR_AMT_M] ) ;
		break ;

	case 20000 :
		Kd_Amt_fl[ACMTRS_20000] = atof( ptb_InRec_Cur[FTIR_AMT_M] ) ;
		break ;

	case 20030 :
		Kd_Amt_fl[ACMTRS_20030] = atof( ptb_InRec_Cur[FTIR_AMT_M] ) ;
		break ;

	case 20031 :
		Kd_Amt_fl[ACMTRS_20031] = atof( ptb_InRec_Cur[FTIR_AMT_M] ) ;
		break ;

	case 22000 :
		Kd_Amt_fl[ACMTRS_22000] = atof( ptb_InRec_Cur[FTIR_AMT_M] ) ;
		break ;

	case 24030 :
		Kd_Amt_fl[ACMTRS_24030] = atof( ptb_InRec_Cur[FTIR_AMT_M] ) ;
		break ;

	case 24031 :
		Kd_Amt_fl[ACMTRS_24031] = atof( ptb_InRec_Cur[FTIR_AMT_M] ) ;
		break ;
	}

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture derniere de niveau 1

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptFti( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionLastRuptFti" ) ;

	/* ecriture dans le fichier en sortie preparation de l'edition */
	if ( Kd_Amt_fl[ACMTRS_10000] != 0 || Kd_Amt_fl[ACMTRS_10030] != 0 || Kd_Amt_fl[ACMTRS_10031] != 0 ||
	     Kd_Amt_fl[ACMTRS_10100] != 0 || Kd_Amt_fl[ACMTRS_10130] != 0 || Kd_Amt_fl[ACMTRS_10200] != 0 ||
	     Kd_Amt_fl[ACMTRS_10430] != 0 || Kd_Amt_fl[ACMTRS_20000] != 0 || Kd_Amt_fl[ACMTRS_20030] != 0 ||
	     Kd_Amt_fl[ACMTRS_20031] != 0 || Kd_Amt_fl[ACMTRS_22000] != 0 ||
	     Kd_Amt_fl[ACMTRS_24030] != 0 || Kd_Amt_fl[ACMTRS_24031] != 0  )
		fprintf( Kp_OutputFilReport, "%s~%s~%s~%s~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f\n",
			ptb_InRec_Cur[FTIR_SSD_CF], ptb_InRec_Cur[FTIR_ESB_CF], ptb_InRec_Cur[FTIR_LOB_CF],
			ptb_InRec_Cur[FTIR_CTRNAT_CT], Kd_Amt_fl[ACMTRS_10000],
			Kd_Amt_fl[ACMTRS_10030], Kd_Amt_fl[ACMTRS_10031], Kd_Amt_fl[ACMTRS_10100],
			Kd_Amt_fl[ACMTRS_10130], Kd_Amt_fl[ACMTRS_10200], Kd_Amt_fl[ACMTRS_10430],
			Kd_Amt_fl[ACMTRS_20000], Kd_Amt_fl[ACMTRS_20030], Kd_Amt_fl[ACMTRS_20031],
			Kd_Amt_fl[ACMTRS_22000], Kd_Amt_fl[ACMTRS_24030], Kd_Amt_fl[ACMTRS_24031] ) ;

	RETURN_VAL ( OK ) ;
}






