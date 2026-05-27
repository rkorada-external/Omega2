/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTR7607.c
révision                      : $Revision: 1.2 $
date de création              : 09/09/1997
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   PREPARATION DE L'ETAT SYNTHETIQUE DE CONTROLE D'INVENTAIRE ACCEPTATION - ETAPE 1

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    11/05/1998    F.BOULAROT   Calcul des cumuls pour les lignes NON AFFECTES
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
#include "ESTR7607.h"

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/



/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE 		*Kp_OutputFilReport ; /* pointeur sur le fichier de sortie preparation de l'edition */

double		Kd_Amt_fel[14] ; /* tableau des montants cumules par poste cumul pour un triplet: filiale/etablissement/Lob */
double		Kd_Amt_fe[5][14] ; /* tableau des montants cumules par poste cumul pour un couple: filiale/etablissement */
double		Kd_Amt_f[5][14] ; /* tableau des montants cumules par poste cumul pour une filiale */

T_RUPTURE_VAR  	bd_RuptFti ; /* variable de gestion de la rupture sur le fichier de travail */

int n_InitFti	 		( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_IsR1Fti			( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_IsR2Fti			( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_IsR3Fti			( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_ActionFirstRupt1Fti	( char **pbd_InRec_Cur ) ;
int n_ActionFirstRupt2Fti	( char **pbd_InRec_Cur ) ;
int n_ActionFirstRupt3Fti	( char **pbd_InRec_Cur ) ;
int n_ActionLigneFti		( char **pbd_InRec_Cur ) ;
int n_ActionLastRupt1Fti	( char **pbd_InRec_Cur ) ;
int n_ActionLastRupt2Fti	( char **pbd_InRec_Cur ) ;
int n_ActionLastRupt3Fti	( char **pbd_InRec_Cur ) ;



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
	if ( n_OpenFileAppl ( "ESTR7607_O1","wt",&Kp_OutputFilReport ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptFti */
	if ( n_InitFti( &bd_RuptFti ) )
		ExitPgm( ERR_XX , "" ) ;

	/* lancement du traitement du fichier intermediaire */
	if ( n_ProcessingRuptureVar( &bd_RuptFti ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTR7607_O1", &Kp_OutputFilReport ) == ERR )
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
	if ( n_OpenFileAppl( "ESTR7607_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 3 ;

	/* fonction du test de rupture de niveau 1 */
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1Fti ;

	/* fonction du test de rupture de niveau 2 */
	pbd_Rupt->n_ConditionRupture[1] = n_IsR2Fti ;

	/* fonction du test de rupture de niveau 3 */
	pbd_Rupt->n_ConditionRupture[2] = n_IsR3Fti ;

	/* Fonction lancee en rupture premiere de niveau 1 */
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRupt1Fti ;

	/* Fonction lancee en rupture premiere de niveau 2 */
	pbd_Rupt->n_ActionFirst[1] = n_ActionFirstRupt2Fti ;

	/* Fonction lancee en rupture premiere de niveau 3 */
	pbd_Rupt->n_ActionFirst[2] = n_ActionFirstRupt3Fti ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneFti ;

	/* Fonction lancee en rupture derniere de niveau 1 */
	pbd_Rupt->n_ActionLast[0] = n_ActionLastRupt1Fti ;

	/* Fonction lancee en rupture derniere de niveau 2 */
	pbd_Rupt->n_ActionLast[1] = n_ActionLastRupt2Fti ;

	/* Fonction lancee en rupture derniere de niveau 3 */
	pbd_Rupt->n_ActionLast[2] = n_ActionLastRupt3Fti ;

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

	if ( ( ret = strcmp( pbd_InRec[FTIA_SSD_CF], pbd_InRec_Cur[FTIA_SSD_CF] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction de test de rupture de niveau 2

retour :
	0	---> pas de rupture
	sinon   	---> rupture
==============================================================================*/
int n_IsR2Fti(
	char **pbd_InRec ,  /* adresse de la ligne en avance */
	char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
	int ret ;

	DEBUT_FCT( "n_IsR2Fti" ) ;

	if ( ( ret = strcmp( pbd_InRec[FTIA_SSD_CF], pbd_InRec_Cur[FTIA_SSD_CF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[FTIA_ESB_CF], pbd_InRec_Cur[FTIA_ESB_CF] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction de test de rupture de niveau 3

retour :
	0	---> pas de rupture
	sinon   	---> rupture
==============================================================================*/
int n_IsR3Fti(
	char **pbd_InRec ,  /* adresse de la ligne en avance */
	char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
	int ret ;

	DEBUT_FCT( "n_IsR3Fti" ) ;

	if ( ( ret = strcmp( pbd_InRec[FTIA_SSD_CF], pbd_InRec_Cur[FTIA_SSD_CF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[FTIA_ESB_CF], pbd_InRec_Cur[FTIA_ESB_CF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[FTIA_LOB_CF], pbd_InRec_Cur[FTIA_LOB_CF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[FTIA_CTRNAT_CT], pbd_InRec_Cur[FTIA_CTRNAT_CT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[FTIA_WRKCAT_CT], pbd_InRec_Cur[FTIA_WRKCAT_CT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture premiere de niveau 1

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRupt1Fti( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionFirstRupt1Fti" ) ;

	/* tableau des montants cumules par poste cumul pour une filiale */
	memset( Kd_Amt_f, 0, sizeof( Kd_Amt_f ) ) ;

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture premiere de niveau 2

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRupt2Fti( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionFirstRupt2Fti" ) ;

	/* tableau des montants cumules par poste cumul pour un couple: filiale/etablissement */
	memset( Kd_Amt_fe, 0, sizeof( Kd_Amt_fe ) ) ;

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture premiere de niveau 3

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRupt3Fti( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionFirstRupt3Fti" ) ;

	/* tableau des montants cumules par poste cumul pour un triplet: filiale/etablissement/Lob */
	memset( Kd_Amt_fel, 0, sizeof( Kd_Amt_fel ) ) ;

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
	switch( atol( ptb_InRec_Cur[FTIA_ACMTRS_NT] ) )
	{
	case 10000 :
		Kd_Amt_fel[ACMTRS_10000] = atof( ptb_InRec_Cur[FTIA_AMT_M] ) ;

		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'F' )
		{
			Kd_Amt_f[FAC][ACMTRS_10000] += Kd_Amt_fel[ACMTRS_10000] ;
			Kd_Amt_fe[FAC][ACMTRS_10000] += Kd_Amt_fel[ACMTRS_10000] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'P' )
		{
			Kd_Amt_f[PROP][ACMTRS_10000] += Kd_Amt_fel[ACMTRS_10000] ;
			Kd_Amt_fe[PROP][ACMTRS_10000] += Kd_Amt_fel[ACMTRS_10000] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[FTIA_WRKCAT_CT] == '1' )
		{
			Kd_Amt_f[NPROP_WK][ACMTRS_10000] += Kd_Amt_fel[ACMTRS_10000] ;
			Kd_Amt_fe[NPROP_WK][ACMTRS_10000] += Kd_Amt_fel[ACMTRS_10000] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[FTIA_WRKCAT_CT] == '2' )
		{
			Kd_Amt_f[NPROP_CAT][ACMTRS_10000] += Kd_Amt_fel[ACMTRS_10000] ;
			Kd_Amt_fe[NPROP_CAT][ACMTRS_10000] += Kd_Amt_fel[ACMTRS_10000] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'X' )
		{
			Kd_Amt_f[NAFF][ACMTRS_10000] += Kd_Amt_fel[ACMTRS_10000] ;
			Kd_Amt_fe[NAFF][ACMTRS_10000] += Kd_Amt_fel[ACMTRS_10000] ;
		}
		break ;

	case 10030 :
		Kd_Amt_fel[ACMTRS_10030] = atof( ptb_InRec_Cur[FTIA_AMT_M] ) ;

		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'F' )
		{
			Kd_Amt_f[FAC][ACMTRS_10030] += Kd_Amt_fel[ACMTRS_10030] ;
			Kd_Amt_fe[FAC][ACMTRS_10030] += Kd_Amt_fel[ACMTRS_10030] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'P' )
		{
			Kd_Amt_f[PROP][ACMTRS_10030] += Kd_Amt_fel[ACMTRS_10030] ;
			Kd_Amt_fe[PROP][ACMTRS_10030] += Kd_Amt_fel[ACMTRS_10030] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[FTIA_WRKCAT_CT] == '1' )
		{
			Kd_Amt_f[NPROP_WK][ACMTRS_10030] += Kd_Amt_fel[ACMTRS_10030] ;
			Kd_Amt_fe[NPROP_WK][ACMTRS_10030] += Kd_Amt_fel[ACMTRS_10030] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[FTIA_WRKCAT_CT] == '2' )
		{
			Kd_Amt_f[NPROP_CAT][ACMTRS_10030] += Kd_Amt_fel[ACMTRS_10030] ;
			Kd_Amt_fe[NPROP_CAT][ACMTRS_10030] += Kd_Amt_fel[ACMTRS_10030] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'X' )
		{
			Kd_Amt_f[NAFF][ACMTRS_10030] += Kd_Amt_fel[ACMTRS_10030] ;
			Kd_Amt_fe[NAFF][ACMTRS_10030] += Kd_Amt_fel[ACMTRS_10030] ;
		}
		break ;

	case 10031 :
		Kd_Amt_fel[ACMTRS_10031] = atof( ptb_InRec_Cur[FTIA_AMT_M] ) ;

		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'F' )
		{
			Kd_Amt_f[FAC][ACMTRS_10031] += Kd_Amt_fel[ACMTRS_10031] ;
			Kd_Amt_fe[FAC][ACMTRS_10031] += Kd_Amt_fel[ACMTRS_10031] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'P' )
		{
			Kd_Amt_f[PROP][ACMTRS_10031] += Kd_Amt_fel[ACMTRS_10031] ;
			Kd_Amt_fe[PROP][ACMTRS_10031] += Kd_Amt_fel[ACMTRS_10031] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[FTIA_WRKCAT_CT] == '1' )
		{
			Kd_Amt_f[NPROP_WK][ACMTRS_10031] += Kd_Amt_fel[ACMTRS_10031] ;
			Kd_Amt_fe[NPROP_WK][ACMTRS_10031] += Kd_Amt_fel[ACMTRS_10031] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[FTIA_WRKCAT_CT] == '2' )
		{
			Kd_Amt_f[NPROP_CAT][ACMTRS_10031] += Kd_Amt_fel[ACMTRS_10031] ;
			Kd_Amt_fe[NPROP_CAT][ACMTRS_10031] += Kd_Amt_fel[ACMTRS_10031] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'X' )
		{
			Kd_Amt_f[NAFF][ACMTRS_10031] += Kd_Amt_fel[ACMTRS_10031] ;
			Kd_Amt_fe[NAFF][ACMTRS_10031] += Kd_Amt_fel[ACMTRS_10031] ;
		}
		break ;

	case 10100 :
		Kd_Amt_fel[ACMTRS_10100] = atof( ptb_InRec_Cur[FTIA_AMT_M] ) ;

		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'F' )
		{
			Kd_Amt_f[FAC][ACMTRS_10100] += Kd_Amt_fel[ACMTRS_10100] ;
			Kd_Amt_fe[FAC][ACMTRS_10100] += Kd_Amt_fel[ACMTRS_10100] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'P' )
		{
			Kd_Amt_f[PROP][ACMTRS_10100] += Kd_Amt_fel[ACMTRS_10100] ;
			Kd_Amt_fe[PROP][ACMTRS_10100] += Kd_Amt_fel[ACMTRS_10100] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[FTIA_WRKCAT_CT] == '1' )
		{
			Kd_Amt_f[NPROP_WK][ACMTRS_10100] += Kd_Amt_fel[ACMTRS_10100] ;
			Kd_Amt_fe[NPROP_WK][ACMTRS_10100] += Kd_Amt_fel[ACMTRS_10100] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[FTIA_WRKCAT_CT] == '2' )
		{
			Kd_Amt_f[NPROP_CAT][ACMTRS_10100] += Kd_Amt_fel[ACMTRS_10100] ;
			Kd_Amt_fe[NPROP_CAT][ACMTRS_10100] += Kd_Amt_fel[ACMTRS_10100] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'X' )
		{
			Kd_Amt_f[NAFF][ACMTRS_10100] += Kd_Amt_fel[ACMTRS_10100] ;
			Kd_Amt_fe[NAFF][ACMTRS_10100] += Kd_Amt_fel[ACMTRS_10100] ;
		}
		break ;

	case 10130 :
		Kd_Amt_fel[ACMTRS_10130] = atof( ptb_InRec_Cur[FTIA_AMT_M] ) ;

		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'F' )
		{
			Kd_Amt_f[FAC][ACMTRS_10130] += Kd_Amt_fel[ACMTRS_10130] ;
			Kd_Amt_fe[FAC][ACMTRS_10130] += Kd_Amt_fel[ACMTRS_10130] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'P' )
		{
			Kd_Amt_f[PROP][ACMTRS_10130] += Kd_Amt_fel[ACMTRS_10130] ;
			Kd_Amt_fe[PROP][ACMTRS_10130] += Kd_Amt_fel[ACMTRS_10130] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[FTIA_WRKCAT_CT] == '1' )
		{
			Kd_Amt_f[NPROP_WK][ACMTRS_10130] += Kd_Amt_fel[ACMTRS_10130] ;
			Kd_Amt_fe[NPROP_WK][ACMTRS_10130] += Kd_Amt_fel[ACMTRS_10130] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[FTIA_WRKCAT_CT] == '2' )
		{
			Kd_Amt_f[NPROP_CAT][ACMTRS_10130] += Kd_Amt_fel[ACMTRS_10130] ;
			Kd_Amt_fe[NPROP_CAT][ACMTRS_10130] += Kd_Amt_fel[ACMTRS_10130] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'X' )
		{
			Kd_Amt_f[NAFF][ACMTRS_10130] += Kd_Amt_fel[ACMTRS_10130] ;
			Kd_Amt_fe[NAFF][ACMTRS_10130] += Kd_Amt_fel[ACMTRS_10130] ;
		}
		break ;

	case 10400 :
		Kd_Amt_fel[ACMTRS_10400] = atof( ptb_InRec_Cur[FTIA_AMT_M] ) ;

		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'F' )
		{
			Kd_Amt_f[FAC][ACMTRS_10400] += Kd_Amt_fel[ACMTRS_10400] ;
			Kd_Amt_fe[FAC][ACMTRS_10400] += Kd_Amt_fel[ACMTRS_10400] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'P' )
		{
			Kd_Amt_f[PROP][ACMTRS_10400] += Kd_Amt_fel[ACMTRS_10400] ;
			Kd_Amt_fe[PROP][ACMTRS_10400] += Kd_Amt_fel[ACMTRS_10400] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[FTIA_WRKCAT_CT] == '1' )
		{
			Kd_Amt_f[NPROP_WK][ACMTRS_10400] += Kd_Amt_fel[ACMTRS_10400] ;
			Kd_Amt_fe[NPROP_WK][ACMTRS_10400] += Kd_Amt_fel[ACMTRS_10400] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[FTIA_WRKCAT_CT] == '2' )
		{
			Kd_Amt_f[NPROP_CAT][ACMTRS_10400] += Kd_Amt_fel[ACMTRS_10400] ;
			Kd_Amt_fe[NPROP_CAT][ACMTRS_10400] += Kd_Amt_fel[ACMTRS_10400] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'X' )
		{
			Kd_Amt_f[NAFF][ACMTRS_10400] += Kd_Amt_fel[ACMTRS_10400] ;
			Kd_Amt_fe[NAFF][ACMTRS_10400] += Kd_Amt_fel[ACMTRS_10400] ;
		}
		break ;

	case 10430 :
		Kd_Amt_fel[ACMTRS_10430] = atof( ptb_InRec_Cur[FTIA_AMT_M] ) ;

		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'F' )
		{
			Kd_Amt_f[FAC][ACMTRS_10430] += Kd_Amt_fel[ACMTRS_10430] ;
			Kd_Amt_fe[FAC][ACMTRS_10430] += Kd_Amt_fel[ACMTRS_10430] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'P' )
		{
			Kd_Amt_f[PROP][ACMTRS_10430] += Kd_Amt_fel[ACMTRS_10430] ;
			Kd_Amt_fe[PROP][ACMTRS_10430] += Kd_Amt_fel[ACMTRS_10430] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[FTIA_WRKCAT_CT] == '1' )
		{
			Kd_Amt_f[NPROP_WK][ACMTRS_10430] += Kd_Amt_fel[ACMTRS_10430] ;
			Kd_Amt_fe[NPROP_WK][ACMTRS_10430] += Kd_Amt_fel[ACMTRS_10430] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[FTIA_WRKCAT_CT] == '2' )
		{
			Kd_Amt_f[NPROP_CAT][ACMTRS_10430] += Kd_Amt_fel[ACMTRS_10430] ;
			Kd_Amt_fe[NPROP_CAT][ACMTRS_10430] += Kd_Amt_fel[ACMTRS_10430] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'X' )
		{
			Kd_Amt_f[NAFF][ACMTRS_10430] += Kd_Amt_fel[ACMTRS_10430] ;
			Kd_Amt_fe[NAFF][ACMTRS_10430] += Kd_Amt_fel[ACMTRS_10430] ;
		}
		break ;

	case 20000 :
		Kd_Amt_fel[ACMTRS_20000] = atof( ptb_InRec_Cur[FTIA_AMT_M] ) ;

		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'F' )
		{
			Kd_Amt_f[FAC][ACMTRS_20000] += Kd_Amt_fel[ACMTRS_20000] ;
			Kd_Amt_fe[FAC][ACMTRS_20000] += Kd_Amt_fel[ACMTRS_20000] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'P' )
		{
			Kd_Amt_f[PROP][ACMTRS_20000] += Kd_Amt_fel[ACMTRS_20000] ;
			Kd_Amt_fe[PROP][ACMTRS_20000] += Kd_Amt_fel[ACMTRS_20000] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[FTIA_WRKCAT_CT] == '1' )
		{
			Kd_Amt_f[NPROP_WK][ACMTRS_20000] += Kd_Amt_fel[ACMTRS_20000] ;
			Kd_Amt_fe[NPROP_WK][ACMTRS_20000] += Kd_Amt_fel[ACMTRS_20000] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[FTIA_WRKCAT_CT] == '2' )
		{
			Kd_Amt_f[NPROP_CAT][ACMTRS_20000] += Kd_Amt_fel[ACMTRS_20000] ;
			Kd_Amt_fe[NPROP_CAT][ACMTRS_20000] += Kd_Amt_fel[ACMTRS_20000] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'X' )
		{
			Kd_Amt_f[NAFF][ACMTRS_20000] += Kd_Amt_fel[ACMTRS_20000] ;
			Kd_Amt_fe[NAFF][ACMTRS_20000] += Kd_Amt_fel[ACMTRS_20000] ;
		}
		break ;

	case 20030 :
		Kd_Amt_fel[ACMTRS_20030] = atof( ptb_InRec_Cur[FTIA_AMT_M] ) ;

		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'F' )
		{
			Kd_Amt_f[FAC][ACMTRS_20030] += Kd_Amt_fel[ACMTRS_20030] ;
			Kd_Amt_fe[FAC][ACMTRS_20030] += Kd_Amt_fel[ACMTRS_20030] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'P' )
		{
			Kd_Amt_f[PROP][ACMTRS_20030] += Kd_Amt_fel[ACMTRS_20030] ;
			Kd_Amt_fe[PROP][ACMTRS_20030] += Kd_Amt_fel[ACMTRS_20030] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[FTIA_WRKCAT_CT] == '1' )
		{
			Kd_Amt_f[NPROP_WK][ACMTRS_20030] += Kd_Amt_fel[ACMTRS_20030] ;
			Kd_Amt_fe[NPROP_WK][ACMTRS_20030] += Kd_Amt_fel[ACMTRS_20030] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[FTIA_WRKCAT_CT] == '2' )
		{
			Kd_Amt_f[NPROP_CAT][ACMTRS_20030] += Kd_Amt_fel[ACMTRS_20030] ;
			Kd_Amt_fe[NPROP_CAT][ACMTRS_20030] += Kd_Amt_fel[ACMTRS_20030] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'X' )
		{
			Kd_Amt_f[NAFF][ACMTRS_20030] += Kd_Amt_fel[ACMTRS_20030] ;
			Kd_Amt_fe[NAFF][ACMTRS_20030] += Kd_Amt_fel[ACMTRS_20030] ;
		}
		break ;

	case 20031 :
		Kd_Amt_fel[ACMTRS_20031] = atof( ptb_InRec_Cur[FTIA_AMT_M] ) ;

		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'F' )
		{
			Kd_Amt_f[FAC][ACMTRS_20031] += Kd_Amt_fel[ACMTRS_20031] ;
			Kd_Amt_fe[FAC][ACMTRS_20031] += Kd_Amt_fel[ACMTRS_20031] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'P' )
		{
			Kd_Amt_f[PROP][ACMTRS_20031] += Kd_Amt_fel[ACMTRS_20031] ;
			Kd_Amt_fe[PROP][ACMTRS_20031] += Kd_Amt_fel[ACMTRS_20031] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[FTIA_WRKCAT_CT] == '1' )
		{
			Kd_Amt_f[NPROP_WK][ACMTRS_20031] += Kd_Amt_fel[ACMTRS_20031] ;
			Kd_Amt_fe[NPROP_WK][ACMTRS_20031] += Kd_Amt_fel[ACMTRS_20031] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[FTIA_WRKCAT_CT] == '2' )
		{
			Kd_Amt_f[NPROP_CAT][ACMTRS_20031] += Kd_Amt_fel[ACMTRS_20031] ;
			Kd_Amt_fe[NPROP_CAT][ACMTRS_20031] += Kd_Amt_fel[ACMTRS_20031] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'X' )
		{
			Kd_Amt_f[NAFF][ACMTRS_20031] += Kd_Amt_fel[ACMTRS_20031] ;
			Kd_Amt_fe[NAFF][ACMTRS_20031] += Kd_Amt_fel[ACMTRS_20031] ;
		}
		break ;

	case 24030 :
		Kd_Amt_fel[ACMTRS_24030] = atof( ptb_InRec_Cur[FTIA_AMT_M] ) ;

		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'F' )
		{
			Kd_Amt_f[FAC][ACMTRS_24030] += Kd_Amt_fel[ACMTRS_24030] ;
			Kd_Amt_fe[FAC][ACMTRS_24030] += Kd_Amt_fel[ACMTRS_24030] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'P' )
		{
			Kd_Amt_f[PROP][ACMTRS_24030] += Kd_Amt_fel[ACMTRS_24030] ;
			Kd_Amt_fe[PROP][ACMTRS_24030] += Kd_Amt_fel[ACMTRS_24030] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[FTIA_WRKCAT_CT] == '1' )
		{
			Kd_Amt_f[NPROP_WK][ACMTRS_24030] += Kd_Amt_fel[ACMTRS_24030] ;
			Kd_Amt_fe[NPROP_WK][ACMTRS_24030] += Kd_Amt_fel[ACMTRS_24030] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[FTIA_WRKCAT_CT] == '2' )
		{
			Kd_Amt_f[NPROP_CAT][ACMTRS_24030] += Kd_Amt_fel[ACMTRS_24030] ;
			Kd_Amt_fe[NPROP_CAT][ACMTRS_24030] += Kd_Amt_fel[ACMTRS_24030] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'X' )
		{
			Kd_Amt_f[NAFF][ACMTRS_24030] += Kd_Amt_fel[ACMTRS_24030] ;
			Kd_Amt_fe[NAFF][ACMTRS_24030] += Kd_Amt_fel[ACMTRS_24030] ;
		}
		break ;

	case 24031 :
		Kd_Amt_fel[ACMTRS_24031] = atof( ptb_InRec_Cur[FTIA_AMT_M] ) ;

		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'F' )
		{
			Kd_Amt_f[FAC][ACMTRS_24031] += Kd_Amt_fel[ACMTRS_24031] ;
			Kd_Amt_fe[FAC][ACMTRS_24031] += Kd_Amt_fel[ACMTRS_24031] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'P' )
		{
			Kd_Amt_f[PROP][ACMTRS_24031] += Kd_Amt_fel[ACMTRS_24031] ;
			Kd_Amt_fe[PROP][ACMTRS_24031] += Kd_Amt_fel[ACMTRS_24031] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[FTIA_WRKCAT_CT] == '1' )
		{
			Kd_Amt_f[NPROP_WK][ACMTRS_24031] += Kd_Amt_fel[ACMTRS_24031] ;
			Kd_Amt_fe[NPROP_WK][ACMTRS_24031] += Kd_Amt_fel[ACMTRS_24031] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[FTIA_WRKCAT_CT] == '2' )
		{
			Kd_Amt_f[NPROP_CAT][ACMTRS_24031] += Kd_Amt_fel[ACMTRS_24031] ;
			Kd_Amt_fe[NPROP_CAT][ACMTRS_24031] += Kd_Amt_fel[ACMTRS_24031] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'X' )
		{
			Kd_Amt_f[NAFF][ACMTRS_24031] += Kd_Amt_fel[ACMTRS_24031] ;
			Kd_Amt_fe[NAFF][ACMTRS_24031] += Kd_Amt_fel[ACMTRS_24031] ;
		}
		break ;

	case 22000 :
		Kd_Amt_fel[ACMTRS_22000] = atof( ptb_InRec_Cur[FTIA_AMT_M] ) ;

		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'F' )
		{
			Kd_Amt_f[FAC][ACMTRS_22000] += Kd_Amt_fel[ACMTRS_22000] ;
			Kd_Amt_fe[FAC][ACMTRS_22000] += Kd_Amt_fel[ACMTRS_22000] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'P' )
		{
			Kd_Amt_f[PROP][ACMTRS_22000] += Kd_Amt_fel[ACMTRS_22000] ;
			Kd_Amt_fe[PROP][ACMTRS_22000] += Kd_Amt_fel[ACMTRS_22000] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[FTIA_WRKCAT_CT] == '1' )
		{
			Kd_Amt_f[NPROP_WK][ACMTRS_22000] += Kd_Amt_fel[ACMTRS_22000] ;
			Kd_Amt_fe[NPROP_WK][ACMTRS_22000] += Kd_Amt_fel[ACMTRS_22000] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[FTIA_WRKCAT_CT] == '2' )
		{
			Kd_Amt_f[NPROP_CAT][ACMTRS_22000] += Kd_Amt_fel[ACMTRS_22000] ;
			Kd_Amt_fe[NPROP_CAT][ACMTRS_22000] += Kd_Amt_fel[ACMTRS_22000] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'X' )
		{
			Kd_Amt_f[NAFF][ACMTRS_22000] += Kd_Amt_fel[ACMTRS_22000] ;
			Kd_Amt_fe[NAFF][ACMTRS_22000] += Kd_Amt_fel[ACMTRS_22000] ;
		}
		break ;

	case 23000 :
		Kd_Amt_fel[ACMTRS_23000] = atof( ptb_InRec_Cur[FTIA_AMT_M] ) ;

		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'F' )
		{
			Kd_Amt_f[FAC][ACMTRS_23000] += Kd_Amt_fel[ACMTRS_23000] ;
			Kd_Amt_fe[FAC][ACMTRS_23000] += Kd_Amt_fel[ACMTRS_23000] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'P' )
		{
			Kd_Amt_f[PROP][ACMTRS_23000] += Kd_Amt_fel[ACMTRS_23000] ;
			Kd_Amt_fe[PROP][ACMTRS_23000] += Kd_Amt_fel[ACMTRS_23000] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[FTIA_WRKCAT_CT] == '1' )
		{
			Kd_Amt_f[NPROP_WK][ACMTRS_23000] += Kd_Amt_fel[ACMTRS_23000] ;
			Kd_Amt_fe[NPROP_WK][ACMTRS_23000] += Kd_Amt_fel[ACMTRS_23000] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[FTIA_WRKCAT_CT] == '2' )
		{
			Kd_Amt_f[NPROP_CAT][ACMTRS_23000] += Kd_Amt_fel[ACMTRS_23000] ;
			Kd_Amt_fe[NPROP_CAT][ACMTRS_23000] += Kd_Amt_fel[ACMTRS_23000] ;
		}
		if ( *ptb_InRec_Cur[FTIA_CTRNAT_CT] == 'X' )
		{
			Kd_Amt_f[NAFF][ACMTRS_23000] += Kd_Amt_fel[ACMTRS_23000] ;
			Kd_Amt_fe[NAFF][ACMTRS_23000] += Kd_Amt_fel[ACMTRS_23000] ;
		}
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
int n_ActionLastRupt1Fti( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionLastRupt1Fti" ) ;

	/* ecriture dans le fichier en sortie preparation de l'edition pour un traite FAC */
	if ( Kd_Amt_f[FAC][ACMTRS_10000] != 0 || Kd_Amt_f[FAC][ACMTRS_10030] != 0 || Kd_Amt_f[FAC][ACMTRS_10031] != 0 ||
	     Kd_Amt_f[FAC][ACMTRS_10100] != 0 || Kd_Amt_f[FAC][ACMTRS_10130] != 0 || Kd_Amt_f[FAC][ACMTRS_10400] != 0 ||
	     Kd_Amt_f[FAC][ACMTRS_10430] != 0 || Kd_Amt_f[FAC][ACMTRS_20000] != 0 || Kd_Amt_f[FAC][ACMTRS_20030] != 0 ||
	     Kd_Amt_f[FAC][ACMTRS_20031] != 0 || Kd_Amt_f[FAC][ACMTRS_22000] != 0 || Kd_Amt_f[FAC][ACMTRS_23000] != 0 ||
	     Kd_Amt_f[FAC][ACMTRS_24030] != 0 || Kd_Amt_f[FAC][ACMTRS_24031] != 0  )
		fprintf( Kp_OutputFilReport, "%s~256~ZZ~F~~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f\n",
			ptb_InRec_Cur[FTIA_SSD_CF], ( Kd_Amt_f[FAC][ACMTRS_10000] ), ( Kd_Amt_f[FAC][ACMTRS_10030] ),
			( Kd_Amt_f[FAC][ACMTRS_10031] ), ( Kd_Amt_f[FAC][ACMTRS_10100] ), ( Kd_Amt_f[FAC][ACMTRS_10130] ),
			( Kd_Amt_f[FAC][ACMTRS_10400] ), ( Kd_Amt_f[FAC][ACMTRS_10430] ), ( Kd_Amt_f[FAC][ACMTRS_20000] ),
			( Kd_Amt_f[FAC][ACMTRS_20030] ), ( Kd_Amt_f[FAC][ACMTRS_20031] ), ( Kd_Amt_f[FAC][ACMTRS_22000] ),
			( Kd_Amt_f[FAC][ACMTRS_23000] ), ( Kd_Amt_f[FAC][ACMTRS_24030] ), ( Kd_Amt_f[FAC][ACMTRS_24031] ) ) ;

	/* ecriture dans le fichier en sortie preparation de l'edition pour un traite PROP */
	if ( Kd_Amt_f[PROP][ACMTRS_10000] != 0 || Kd_Amt_f[PROP][ACMTRS_10030] != 0 || Kd_Amt_f[PROP][ACMTRS_10031] != 0 ||
	     Kd_Amt_f[PROP][ACMTRS_10100] != 0 || Kd_Amt_f[PROP][ACMTRS_10130] != 0 || Kd_Amt_f[PROP][ACMTRS_10400] != 0 ||
	     Kd_Amt_f[PROP][ACMTRS_10430] != 0 || Kd_Amt_f[PROP][ACMTRS_20000] != 0 || Kd_Amt_f[PROP][ACMTRS_20030] != 0 ||
	     Kd_Amt_f[PROP][ACMTRS_20031] != 0 || Kd_Amt_f[PROP][ACMTRS_22000] != 0 || Kd_Amt_f[PROP][ACMTRS_23000] != 0 ||
	     Kd_Amt_f[PROP][ACMTRS_24030] != 0 || Kd_Amt_f[PROP][ACMTRS_24031] != 0  )
		fprintf( Kp_OutputFilReport, "%s~256~ZZ~P~~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f\n",
			ptb_InRec_Cur[FTIA_SSD_CF], ( Kd_Amt_f[PROP][ACMTRS_10000] ), ( Kd_Amt_f[PROP][ACMTRS_10030] ),
			( Kd_Amt_f[PROP][ACMTRS_10031] ), ( Kd_Amt_f[PROP][ACMTRS_10100] ), ( Kd_Amt_f[PROP][ACMTRS_10130] ),
			( Kd_Amt_f[PROP][ACMTRS_10400] ), ( Kd_Amt_f[PROP][ACMTRS_10430] ), ( Kd_Amt_f[PROP][ACMTRS_20000] ),
			( Kd_Amt_f[PROP][ACMTRS_20030] ), ( Kd_Amt_f[PROP][ACMTRS_20031] ), ( Kd_Amt_f[PROP][ACMTRS_22000] ),
			( Kd_Amt_f[PROP][ACMTRS_23000] ), ( Kd_Amt_f[PROP][ACMTRS_24030] ), ( Kd_Amt_f[PROP][ACMTRS_24031] ) ) ;

	/* ecriture dans le fichier en sortie preparation de l'edition pour un traite NON PROP et WORKING */
	if ( Kd_Amt_f[NPROP_WK][ACMTRS_10000] != 0 || Kd_Amt_f[NPROP_WK][ACMTRS_10030] != 0 || Kd_Amt_f[NPROP_WK][ACMTRS_10031] != 0 ||
	     Kd_Amt_f[NPROP_WK][ACMTRS_10100] != 0 || Kd_Amt_f[NPROP_WK][ACMTRS_10130] != 0 || Kd_Amt_f[NPROP_WK][ACMTRS_10400] != 0 ||
	     Kd_Amt_f[NPROP_WK][ACMTRS_10430] != 0 || Kd_Amt_f[NPROP_WK][ACMTRS_20000] != 0 || Kd_Amt_f[NPROP_WK][ACMTRS_20030] != 0 ||
	     Kd_Amt_f[NPROP_WK][ACMTRS_20031] != 0 || Kd_Amt_f[NPROP_WK][ACMTRS_22000] != 0 || Kd_Amt_f[NPROP_WK][ACMTRS_23000] != 0 ||
	     Kd_Amt_f[NPROP_WK][ACMTRS_24030] != 0 || Kd_Amt_f[NPROP_WK][ACMTRS_24031] != 0  )
		fprintf( Kp_OutputFilReport, "%s~256~ZZ~N~1~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f\n",
			ptb_InRec_Cur[FTIA_SSD_CF], ( Kd_Amt_f[NPROP_WK][ACMTRS_10000] ), ( Kd_Amt_f[NPROP_WK][ACMTRS_10030] ),
			( Kd_Amt_f[NPROP_WK][ACMTRS_10031] ), ( Kd_Amt_f[NPROP_WK][ACMTRS_10100] ), ( Kd_Amt_f[NPROP_WK][ACMTRS_10130] ),
			( Kd_Amt_f[NPROP_WK][ACMTRS_10400] ), ( Kd_Amt_f[NPROP_WK][ACMTRS_10430] ), ( Kd_Amt_f[NPROP_WK][ACMTRS_20000] ),
			( Kd_Amt_f[NPROP_WK][ACMTRS_20030] ), ( Kd_Amt_f[NPROP_WK][ACMTRS_20031] ), ( Kd_Amt_f[NPROP_WK][ACMTRS_22000] ),
			( Kd_Amt_f[NPROP_WK][ACMTRS_23000] ), ( Kd_Amt_f[NPROP_WK][ACMTRS_24030] ), ( Kd_Amt_f[NPROP_WK][ACMTRS_24031] ) ) ;

	/* ecriture dans le fichier en sortie preparation de l'edition pour un traite NON PROP et CAT */
	if ( Kd_Amt_f[NPROP_CAT][ACMTRS_10000] != 0 || Kd_Amt_f[NPROP_CAT][ACMTRS_10030] != 0 || Kd_Amt_f[NPROP_CAT][ACMTRS_10031] != 0 ||
	     Kd_Amt_f[NPROP_CAT][ACMTRS_10100] != 0 || Kd_Amt_f[NPROP_CAT][ACMTRS_10130] != 0 || Kd_Amt_f[NPROP_CAT][ACMTRS_10400] != 0 ||
	     Kd_Amt_f[NPROP_CAT][ACMTRS_10430] != 0 || Kd_Amt_f[NPROP_CAT][ACMTRS_20000] != 0 || Kd_Amt_f[NPROP_CAT][ACMTRS_20030] != 0 ||
	     Kd_Amt_f[NPROP_CAT][ACMTRS_20031] != 0 || Kd_Amt_f[NPROP_CAT][ACMTRS_22000] != 0 || Kd_Amt_f[NPROP_CAT][ACMTRS_23000] != 0 ||
	     Kd_Amt_f[NPROP_CAT][ACMTRS_24030] != 0 || Kd_Amt_f[NPROP_CAT][ACMTRS_24031] != 0  )
		fprintf( Kp_OutputFilReport, "%s~256~ZZ~N~2~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f\n",
			ptb_InRec_Cur[FTIA_SSD_CF], ( Kd_Amt_f[NPROP_CAT][ACMTRS_10000] ), ( Kd_Amt_f[NPROP_CAT][ACMTRS_10030] ),
			( Kd_Amt_f[NPROP_CAT][ACMTRS_10031] ), ( Kd_Amt_f[NPROP_CAT][ACMTRS_10100] ), ( Kd_Amt_f[NPROP_CAT][ACMTRS_10130] ),
			( Kd_Amt_f[NPROP_CAT][ACMTRS_10400] ), ( Kd_Amt_f[NPROP_CAT][ACMTRS_10430] ), ( Kd_Amt_f[NPROP_CAT][ACMTRS_20000] ),
			( Kd_Amt_f[NPROP_CAT][ACMTRS_20030] ), ( Kd_Amt_f[NPROP_CAT][ACMTRS_20031] ), ( Kd_Amt_f[NPROP_CAT][ACMTRS_22000] ),
			( Kd_Amt_f[NPROP_CAT][ACMTRS_23000] ), ( Kd_Amt_f[NPROP_CAT][ACMTRS_24030] ), ( Kd_Amt_f[NPROP_CAT][ACMTRS_24031] ) ) ;

	/* ecriture dans le fichier en sortie preparation de l'edition pour un traite NAFF */
	if ( Kd_Amt_f[NAFF][ACMTRS_10000] != 0 || Kd_Amt_f[NAFF][ACMTRS_10030] != 0 || Kd_Amt_f[NAFF][ACMTRS_10031] != 0 ||
	     Kd_Amt_f[NAFF][ACMTRS_10100] != 0 || Kd_Amt_f[NAFF][ACMTRS_10130] != 0 || Kd_Amt_f[NAFF][ACMTRS_10400] != 0 ||
	     Kd_Amt_f[NAFF][ACMTRS_10430] != 0 || Kd_Amt_f[NAFF][ACMTRS_20000] != 0 || Kd_Amt_f[NAFF][ACMTRS_20030] != 0 ||
	     Kd_Amt_f[NAFF][ACMTRS_20031] != 0 || Kd_Amt_f[NAFF][ACMTRS_22000] != 0 || Kd_Amt_f[NAFF][ACMTRS_23000] != 0 ||
	     Kd_Amt_f[NAFF][ACMTRS_24030] != 0 || Kd_Amt_f[NAFF][ACMTRS_24031] != 0  )
		fprintf( Kp_OutputFilReport, "%s~256~ZZ~X~~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f\n",
			ptb_InRec_Cur[FTIA_SSD_CF], ( Kd_Amt_f[NAFF][ACMTRS_10000] ), ( Kd_Amt_f[NAFF][ACMTRS_10030] ),
			( Kd_Amt_f[NAFF][ACMTRS_10031] ), ( Kd_Amt_f[NAFF][ACMTRS_10100] ), ( Kd_Amt_f[NAFF][ACMTRS_10130] ),
			( Kd_Amt_f[NAFF][ACMTRS_10400] ), ( Kd_Amt_f[NAFF][ACMTRS_10430] ), ( Kd_Amt_f[NAFF][ACMTRS_20000] ),
			( Kd_Amt_f[NAFF][ACMTRS_20030] ), ( Kd_Amt_f[NAFF][ACMTRS_20031] ), ( Kd_Amt_f[NAFF][ACMTRS_22000] ),
			( Kd_Amt_f[NAFF][ACMTRS_23000] ), ( Kd_Amt_f[NAFF][ACMTRS_24030] ), ( Kd_Amt_f[NAFF][ACMTRS_24031] ) ) ;

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture derniere de niveau 2

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRupt2Fti( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionLastRupt2Fti" ) ;

	/* ecriture dans le fichier en sortie preparation de l'edition pour un traite FAC */
	if ( Kd_Amt_fe[FAC][ACMTRS_10000] != 0 || Kd_Amt_fe[FAC][ACMTRS_10030] != 0 || Kd_Amt_fe[FAC][ACMTRS_10031] != 0 ||
	     Kd_Amt_fe[FAC][ACMTRS_10100] != 0 || Kd_Amt_fe[FAC][ACMTRS_10130] != 0 || Kd_Amt_fe[FAC][ACMTRS_10400] != 0 ||
	     Kd_Amt_fe[FAC][ACMTRS_10430] != 0 || Kd_Amt_fe[FAC][ACMTRS_20000] != 0 || Kd_Amt_fe[FAC][ACMTRS_20030] != 0 ||
	     Kd_Amt_fe[FAC][ACMTRS_20031] != 0 || Kd_Amt_fe[FAC][ACMTRS_22000] != 0 || Kd_Amt_fe[FAC][ACMTRS_23000] != 0 ||
	     Kd_Amt_fe[FAC][ACMTRS_24030] != 0 || Kd_Amt_fe[FAC][ACMTRS_24031] != 0  )
		fprintf( Kp_OutputFilReport, "%s~%s~ZZ~F~~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f\n",
			ptb_InRec_Cur[FTIA_SSD_CF], ptb_InRec_Cur[FTIA_ESB_CF], ( Kd_Amt_fe[FAC][ACMTRS_10000] ), ( Kd_Amt_fe[FAC][ACMTRS_10030] ),
			( Kd_Amt_fe[FAC][ACMTRS_10031] ), ( Kd_Amt_fe[FAC][ACMTRS_10100] ), ( Kd_Amt_fe[FAC][ACMTRS_10130] ),
			( Kd_Amt_fe[FAC][ACMTRS_10400] ), ( Kd_Amt_fe[FAC][ACMTRS_10430] ), ( Kd_Amt_fe[FAC][ACMTRS_20000] ),
			( Kd_Amt_fe[FAC][ACMTRS_20030] ), ( Kd_Amt_fe[FAC][ACMTRS_20031] ), ( Kd_Amt_fe[FAC][ACMTRS_22000] ),
			( Kd_Amt_fe[FAC][ACMTRS_23000] ), ( Kd_Amt_fe[FAC][ACMTRS_24030] ), ( Kd_Amt_fe[FAC][ACMTRS_24031] ) ) ;

	/* ecriture dans le fichier en sortie preparation de l'edition pour un traite PROP */
	if ( Kd_Amt_fe[PROP][ACMTRS_10000] != 0 || Kd_Amt_fe[PROP][ACMTRS_10030] != 0 || Kd_Amt_fe[PROP][ACMTRS_10031] != 0 ||
	     Kd_Amt_fe[PROP][ACMTRS_10100] != 0 || Kd_Amt_fe[PROP][ACMTRS_10130] != 0 || Kd_Amt_fe[PROP][ACMTRS_10400] != 0 ||
	     Kd_Amt_fe[PROP][ACMTRS_10430] != 0 || Kd_Amt_fe[PROP][ACMTRS_20000] != 0 || Kd_Amt_fe[PROP][ACMTRS_20030] != 0 ||
	     Kd_Amt_fe[PROP][ACMTRS_20031] != 0 || Kd_Amt_fe[PROP][ACMTRS_22000] != 0 || Kd_Amt_fe[PROP][ACMTRS_23000] != 0 ||
	     Kd_Amt_fe[PROP][ACMTRS_24030] != 0 || Kd_Amt_fe[PROP][ACMTRS_24031] != 0  )
		fprintf( Kp_OutputFilReport, "%s~%s~ZZ~P~~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f\n",
			ptb_InRec_Cur[FTIA_SSD_CF], ptb_InRec_Cur[FTIA_ESB_CF], ( Kd_Amt_fe[PROP][ACMTRS_10000] ), ( Kd_Amt_fe[PROP][ACMTRS_10030] ),
			( Kd_Amt_fe[PROP][ACMTRS_10031] ), ( Kd_Amt_fe[PROP][ACMTRS_10100] ), ( Kd_Amt_fe[PROP][ACMTRS_10130] ),
			( Kd_Amt_fe[PROP][ACMTRS_10400] ), ( Kd_Amt_fe[PROP][ACMTRS_10430] ), ( Kd_Amt_fe[PROP][ACMTRS_20000] ),
			( Kd_Amt_fe[PROP][ACMTRS_20030] ), ( Kd_Amt_fe[PROP][ACMTRS_20031] ), ( Kd_Amt_fe[PROP][ACMTRS_22000] ),
			( Kd_Amt_fe[PROP][ACMTRS_23000] ), ( Kd_Amt_fe[PROP][ACMTRS_24030] ), ( Kd_Amt_fe[PROP][ACMTRS_24031] ) ) ;

	/* ecriture dans le fichier en sortie preparation de l'edition pour un traite NON PROP et WORKING */
	if ( Kd_Amt_fe[NPROP_WK][ACMTRS_10000] != 0 || Kd_Amt_fe[NPROP_WK][ACMTRS_10030] != 0 || Kd_Amt_fe[NPROP_WK][ACMTRS_10031] != 0 ||
	     Kd_Amt_fe[NPROP_WK][ACMTRS_10100] != 0 || Kd_Amt_fe[NPROP_WK][ACMTRS_10130] != 0 || Kd_Amt_fe[NPROP_WK][ACMTRS_10400] != 0 ||
	     Kd_Amt_fe[NPROP_WK][ACMTRS_10430] != 0 || Kd_Amt_fe[NPROP_WK][ACMTRS_20000] != 0 || Kd_Amt_fe[NPROP_WK][ACMTRS_20030] != 0 ||
	     Kd_Amt_fe[NPROP_WK][ACMTRS_20031] != 0 || Kd_Amt_fe[NPROP_WK][ACMTRS_22000] != 0 || Kd_Amt_fe[NPROP_WK][ACMTRS_23000] != 0 ||
	     Kd_Amt_fe[NPROP_WK][ACMTRS_24030] != 0 || Kd_Amt_fe[NPROP_WK][ACMTRS_24031] != 0  )
		fprintf( Kp_OutputFilReport, "%s~%s~ZZ~N~1~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f\n",
			ptb_InRec_Cur[FTIA_SSD_CF], ptb_InRec_Cur[FTIA_ESB_CF], ( Kd_Amt_fe[NPROP_WK][ACMTRS_10000] ), ( Kd_Amt_fe[NPROP_WK][ACMTRS_10030] ),
			( Kd_Amt_fe[NPROP_WK][ACMTRS_10031] ), ( Kd_Amt_fe[NPROP_WK][ACMTRS_10100] ), ( Kd_Amt_fe[NPROP_WK][ACMTRS_10130] ),
			( Kd_Amt_fe[NPROP_WK][ACMTRS_10400] ), ( Kd_Amt_fe[NPROP_WK][ACMTRS_10430] ), ( Kd_Amt_fe[NPROP_WK][ACMTRS_20000] ),
			( Kd_Amt_fe[NPROP_WK][ACMTRS_20030] ), ( Kd_Amt_fe[NPROP_WK][ACMTRS_20031] ), ( Kd_Amt_fe[NPROP_WK][ACMTRS_22000] ),
			( Kd_Amt_fe[NPROP_WK][ACMTRS_23000] ), ( Kd_Amt_fe[NPROP_WK][ACMTRS_24030] ), ( Kd_Amt_fe[NPROP_WK][ACMTRS_24031] ) ) ;

	/* ecriture dans le fichier en sortie preparation de l'edition pour un traite NON PROP et CAT */
	if ( Kd_Amt_fe[NPROP_CAT][ACMTRS_10000] != 0 || Kd_Amt_fe[NPROP_CAT][ACMTRS_10030] != 0 || Kd_Amt_fe[NPROP_CAT][ACMTRS_10031] != 0 ||
	     Kd_Amt_fe[NPROP_CAT][ACMTRS_10100] != 0 || Kd_Amt_fe[NPROP_CAT][ACMTRS_10130] != 0 || Kd_Amt_fe[NPROP_CAT][ACMTRS_10400] != 0 ||
	     Kd_Amt_fe[NPROP_CAT][ACMTRS_10430] != 0 || Kd_Amt_fe[NPROP_CAT][ACMTRS_20000] != 0 || Kd_Amt_fe[NPROP_CAT][ACMTRS_20030] != 0 ||
	     Kd_Amt_fe[NPROP_CAT][ACMTRS_20031] != 0 || Kd_Amt_fe[NPROP_CAT][ACMTRS_22000] != 0 || Kd_Amt_fe[NPROP_CAT][ACMTRS_23000] != 0 ||
	     Kd_Amt_fe[NPROP_CAT][ACMTRS_24030] != 0 || Kd_Amt_fe[NPROP_CAT][ACMTRS_24031] != 0  )
		fprintf( Kp_OutputFilReport, "%s~%s~ZZ~N~2~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f\n",
			ptb_InRec_Cur[FTIA_SSD_CF], ptb_InRec_Cur[FTIA_ESB_CF], ( Kd_Amt_fe[NPROP_CAT][ACMTRS_10000] ), ( Kd_Amt_fe[NPROP_CAT][ACMTRS_10030] ),
			( Kd_Amt_fe[NPROP_CAT][ACMTRS_10031] ), ( Kd_Amt_fe[NPROP_CAT][ACMTRS_10100] ), ( Kd_Amt_fe[NPROP_CAT][ACMTRS_10130] ),
			( Kd_Amt_fe[NPROP_CAT][ACMTRS_10400] ), ( Kd_Amt_fe[NPROP_CAT][ACMTRS_10430] ), ( Kd_Amt_fe[NPROP_CAT][ACMTRS_20000] ),
			( Kd_Amt_fe[NPROP_CAT][ACMTRS_20030] ), ( Kd_Amt_fe[NPROP_CAT][ACMTRS_20031] ), ( Kd_Amt_fe[NPROP_CAT][ACMTRS_22000] ),
			( Kd_Amt_fe[NPROP_CAT][ACMTRS_23000] ), ( Kd_Amt_fe[NPROP_CAT][ACMTRS_24030] ), ( Kd_Amt_fe[NPROP_CAT][ACMTRS_24031] ) ) ;

	/* ecriture dans le fichier en sortie preparation de l'edition pour un traite NAFF */
	if ( Kd_Amt_fe[NAFF][ACMTRS_10000] != 0 || Kd_Amt_fe[NAFF][ACMTRS_10030] != 0 || Kd_Amt_fe[NAFF][ACMTRS_10031] != 0 ||
	     Kd_Amt_fe[NAFF][ACMTRS_10100] != 0 || Kd_Amt_fe[NAFF][ACMTRS_10130] != 0 || Kd_Amt_fe[NAFF][ACMTRS_10400] != 0 ||
	     Kd_Amt_fe[NAFF][ACMTRS_10430] != 0 || Kd_Amt_fe[NAFF][ACMTRS_20000] != 0 || Kd_Amt_fe[NAFF][ACMTRS_20030] != 0 ||
	     Kd_Amt_fe[NAFF][ACMTRS_20031] != 0 || Kd_Amt_fe[NAFF][ACMTRS_22000] != 0 || Kd_Amt_fe[NAFF][ACMTRS_23000] != 0 ||
	     Kd_Amt_fe[NAFF][ACMTRS_24030] != 0 || Kd_Amt_fe[NAFF][ACMTRS_24031] != 0  )
		fprintf( Kp_OutputFilReport, "%s~%s~ZZ~X~~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f\n",
			ptb_InRec_Cur[FTIA_SSD_CF], ptb_InRec_Cur[FTIA_ESB_CF], ( Kd_Amt_fe[NAFF][ACMTRS_10000] ), ( Kd_Amt_fe[NAFF][ACMTRS_10030] ),
			( Kd_Amt_fe[NAFF][ACMTRS_10031] ), ( Kd_Amt_fe[NAFF][ACMTRS_10100] ), ( Kd_Amt_fe[NAFF][ACMTRS_10130] ),
			( Kd_Amt_fe[NAFF][ACMTRS_10400] ), ( Kd_Amt_fe[NAFF][ACMTRS_10430] ), ( Kd_Amt_fe[NAFF][ACMTRS_20000] ),
			( Kd_Amt_fe[NAFF][ACMTRS_20030] ), ( Kd_Amt_fe[NAFF][ACMTRS_20031] ), ( Kd_Amt_fe[NAFF][ACMTRS_22000] ),
			( Kd_Amt_fe[NAFF][ACMTRS_23000] ), ( Kd_Amt_fe[NAFF][ACMTRS_24030] ), ( Kd_Amt_fe[NAFF][ACMTRS_24031] ) ) ;

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture derniere de niveau 3

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRupt3Fti( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionLastRupt3Fti" ) ;

	/* ecriture dans le fichier en sortie preparation de l'edition */
	if ( Kd_Amt_fel[ACMTRS_10000] != 0 || Kd_Amt_fel[ACMTRS_10030] != 0 || Kd_Amt_fel[ACMTRS_10031] != 0 ||
	     Kd_Amt_fel[ACMTRS_10100] != 0 || Kd_Amt_fel[ACMTRS_10130] != 0 || Kd_Amt_fel[ACMTRS_10400] != 0 ||
	     Kd_Amt_fel[ACMTRS_10430] != 0 || Kd_Amt_fel[ACMTRS_20000] != 0 || Kd_Amt_fel[ACMTRS_20030] != 0 ||
	     Kd_Amt_fel[ACMTRS_20031] != 0 || Kd_Amt_fel[ACMTRS_22000] != 0 || Kd_Amt_fel[ACMTRS_23000] != 0 ||
	     Kd_Amt_fel[ACMTRS_24030] != 0 || Kd_Amt_fel[ACMTRS_24031] != 0  )
		fprintf( Kp_OutputFilReport, "%s~%s~%s~%s~%s~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f\n",
			ptb_InRec_Cur[FTIA_SSD_CF], ptb_InRec_Cur[FTIA_ESB_CF], ptb_InRec_Cur[FTIA_LOB_CF],
			ptb_InRec_Cur[FTIA_CTRNAT_CT], ptb_InRec_Cur[FTIA_WRKCAT_CT], ( Kd_Amt_fel[ACMTRS_10000] ),
			( Kd_Amt_fel[ACMTRS_10030] ), ( Kd_Amt_fel[ACMTRS_10031] ), ( Kd_Amt_fel[ACMTRS_10100] ),
			( Kd_Amt_fel[ACMTRS_10130] ), ( Kd_Amt_fel[ACMTRS_10400] ), ( Kd_Amt_fel[ACMTRS_10430] ),
			( Kd_Amt_fel[ACMTRS_20000] ), ( Kd_Amt_fel[ACMTRS_20030] ), ( Kd_Amt_fel[ACMTRS_20031] ),
			( Kd_Amt_fel[ACMTRS_22000] ), ( Kd_Amt_fel[ACMTRS_23000] ), ( Kd_Amt_fel[ACMTRS_24030] ),
			( Kd_Amt_fel[ACMTRS_24031] ) ) ;

	RETURN_VAL ( OK ) ;
}



