/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTC1601.c
révision                      : $Revision: 1.2 $
date de création              : 02/06/1997
auteur                        : Yves BOURDAILLET
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :

	PREPARATION ET FORMATAGE DU FICHIER PERMANENT EST_FSEGACT
	Synthese des resultats de l inventaire par segments de l'actuariat

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
/* definition des constantes et macros privees */
/* position des champs dans le fichier d entree*/
/*---------------------------------------------*/
# define ACCMVT_SSD_CF 0
# define ACCMVT_SEG_NF 1
# define ACCMVT_UWY_NF 2
# define ACCMVT_CUR_CF 3
# define ACCMVT_ACMTRS_NT 4
# define ACCMVT_VRS_NF 5
# define ACCMVT_AMTSTAT_M 6
# define ACCMVT_AMTBIL_M 7

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE 	*Kp_OutputFilSegAct ; 		/* pointeur sur le fichier de sortie FSEGACT
						contenant les resultats de l inventaire par
									segments de l actuariat */

/* variables de cumul des montants au cours STATISTIQUE */
double Kd_Stat_Prm ;	/* primes */
double Kd_Stat_Prm_Rpcc ;/* primes RPCC */
double Kd_Stat_Epp_Rpp ;/* EPP et RPP */
double Kd_Stat_Recons ;	/* primes de reconstitution et primes de burning cost*/
double Kd_Stat_Prm_Acq ;/* primes acquises (prime + PNA + E/RPP) */
double Kd_Stat_Chg_Acq ;/* charges acquises (charge + FAR1 + charges sur portefeuille */
double Kd_Stat_Court_Acq ;/* courtage acquis (courtage + FARcourtage + courtage/portefeuille */
double Kd_Stat_Cpte_Compl ;/* (SP + SAP) comptes complets */
double Kd_Stat_Cpte_Incompl ;/* SP comptes incomplets */
double Kd_Stat_Rpcc ;/* ( SP  SAP ) RPCC */
double Kd_Stat_Ibnr2 ;	/* IBNR2 */
double Kd_Stat_Pb_Pap ;	/* PB + PAP */
double Kd_Stat_Loss_Corri ; /* Loss corridor */



/* variables de cumul des montants au cours BILAN */
double Kd_Bil_Prm ;
double Kd_Bil_Prm_Rpcc ;
double Kd_Bil_Epp_Rpp ;
double Kd_Bil_Recons ;
double Kd_Bil_Prm_Acq ;
double Kd_Bil_Chg_Acq ;
double Kd_Bil_Court_Acq ;
double Kd_Bil_Cpte_Compl ;
double Kd_Bil_Cpte_Incompl ;
double Kd_Bil_Rpcc ;
double Kd_Bil_Ibnr2 ;
double Kd_Bil_Pb_Pap ;
double Kd_Bil_Loss_Corri ;


T_RUPTURE_VAR  	bd_RuptAccMvt ; /* variable de gestion de la rupture sur le fichier de travail */

int n_InitAccMvt	 	( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_TestRupt1		( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_ActionLigneAccMvt		( char **pbd_InRec_Cur ) ;
int n_ActionFirstRupt1		( char **pbd_InRec_Cur ) ;
int n_ActionLastRupt1		( char **pbd_InRec_Cur ) ;

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

	/* ouverture du fichier de sortie de l inventaire par segment de l actuariat */
	if ( n_OpenFileAppl ( "ESTC1601_O1","wt",&Kp_OutputFilSegAct ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptAccMvt */
	if ( n_InitAccMvt( &bd_RuptAccMvt ) )
		ExitPgm( ERR_XX , "" ) ;

	/* lancement du traitement du fichier de travail */
	if ( n_ProcessingRuptureVar( &bd_RuptAccMvt ) == ERR )
			ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1601_I1", &( bd_RuptAccMvt.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1601_O1", &Kp_OutputFilSegAct ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	exit(OK) ;
}

/*==============================================================================
objet :
	fonction d'initialisation de la variable de gestion de rupture du fichier
	maitre.
retour :
	0K
==============================================================================*/
int n_InitAccMvt(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitAccMvt" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier */
	if ( n_OpenFileAppl( "ESTC1601_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 1 ;

	/* fonction du test de rupture de niveau 1 */
	pbd_Rupt->n_ConditionRupture[0] = n_TestRupt1 ;

	/* Fonction lancee en rupture premiere */
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRupt1 ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneAccMvt ;

	/* Fonction lancee en rupture derniere */
	pbd_Rupt->n_ActionLast[0] = n_ActionLastRupt1 ;

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
int n_TestRupt1(
	char **pbd_InRec ,  /* adresse de la ligne en avance */
	char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
	int ret ;

	DEBUT_FCT( "n_TestRupt1" ) ;

	/* test sur SSD_CF */
	if ( ( ret = ( atoi( pbd_InRec[ACCMVT_SSD_CF] ) - atoi( pbd_InRec_Cur[ACCMVT_SSD_CF] ) ) ) != 0 ) return ret ;
	/* test sur SEG_NF */
	if ( ( ret = strcmp( pbd_InRec[ACCMVT_SEG_NF], pbd_InRec_Cur[ACCMVT_SEG_NF] ) ) != 0 ) return ret ;
	/* test sur UWY_NF */
	if ( ( ret = strcmp( pbd_InRec[ACCMVT_UWY_NF], pbd_InRec_Cur[ACCMVT_UWY_NF] ) ) != 0 ) return ret ;
	/* test sur CUR_CF */
	if ( ( ret = strcmp( pbd_InRec[ACCMVT_CUR_CF], pbd_InRec_Cur[ACCMVT_CUR_CF] ) ) != 0 ) return ret ;
	RETURN_VAL( 0 ) ;
}

/*==============================================================================
objet :
	fonction lancee en rupture premiere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRupt1( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionFirstRupt1" ) ;

	/* initialisation de tous les montants */
	Kd_Stat_Prm = 0 ;
	Kd_Stat_Prm_Rpcc = 0 ;
	Kd_Stat_Epp_Rpp = 0 ;
	Kd_Stat_Recons = 0 ;
	Kd_Stat_Prm_Acq = 0 ;
	Kd_Stat_Chg_Acq = 0 ;
	Kd_Stat_Court_Acq = 0 ;
	Kd_Stat_Cpte_Compl = 0 ;
	Kd_Stat_Cpte_Incompl = 0 ;
	Kd_Stat_Rpcc = 0 ;
	Kd_Stat_Ibnr2 = 0 ;
	Kd_Stat_Pb_Pap = 0 ;
	Kd_Stat_Loss_Corri = 0 ;
	Kd_Bil_Prm = 0 ;
	Kd_Bil_Prm_Rpcc = 0 ;
	Kd_Bil_Epp_Rpp = 0 ;
	Kd_Bil_Recons = 0 ;
	Kd_Bil_Prm_Acq = 0 ;
	Kd_Bil_Chg_Acq = 0 ;
	Kd_Bil_Court_Acq = 0 ;
	Kd_Bil_Cpte_Compl = 0 ;
	Kd_Bil_Cpte_Incompl = 0 ;
	Kd_Bil_Rpcc = 0 ;
	Kd_Bil_Ibnr2 = 0 ;
	Kd_Bil_Pb_Pap = 0 ;
	Kd_Bil_Loss_Corri = 0 ;

	RETURN_VAL( 0 ) ;
}
/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneAccMvt( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionLigneAccMvt" ) ;

	/* Cumul des differents montants */
	/* suivant le poste de regroupement */

	switch ( atol ( ptb_InRec_Cur[ACCMVT_ACMTRS_NT] ) )
	{
	case 10000 :
			Kd_Stat_Prm += atof ( ptb_InRec_Cur[ACCMVT_AMTSTAT_M] ) ;
			Kd_Stat_Prm_Acq += atof ( ptb_InRec_Cur[ACCMVT_AMTSTAT_M] ) ;
			Kd_Bil_Prm += atof ( ptb_InRec_Cur[ACCMVT_AMTBIL_M] ) ;
			Kd_Bil_Prm_Acq += atof ( ptb_InRec_Cur[ACCMVT_AMTBIL_M] ) ;
			break ;
	case 10010 :
			Kd_Stat_Epp_Rpp += atof ( ptb_InRec_Cur[ACCMVT_AMTSTAT_M] ) ;
			Kd_Stat_Prm_Acq += atof ( ptb_InRec_Cur[ACCMVT_AMTSTAT_M] ) ;
			Kd_Bil_Epp_Rpp += atof ( ptb_InRec_Cur[ACCMVT_AMTBIL_M] ) ;
			Kd_Bil_Prm_Acq += atof ( ptb_InRec_Cur[ACCMVT_AMTBIL_M] ) ;
			break ;
	case 10020 :
			Kd_Stat_Epp_Rpp += atof ( ptb_InRec_Cur[ACCMVT_AMTSTAT_M] ) ;
			Kd_Stat_Prm_Acq += atof ( ptb_InRec_Cur[ACCMVT_AMTSTAT_M] ) ;
			Kd_Bil_Epp_Rpp += atof ( ptb_InRec_Cur[ACCMVT_AMTBIL_M] ) ;
			Kd_Bil_Prm_Acq += atof ( ptb_InRec_Cur[ACCMVT_AMTBIL_M] ) ;
			break ;
	case 12000 :
			Kd_Stat_Recons += atof ( ptb_InRec_Cur[ACCMVT_AMTSTAT_M] ) ;
			Kd_Bil_Recons += atof ( ptb_InRec_Cur[ACCMVT_AMTBIL_M] ) ;
			break ;
	case 13000 :
			Kd_Stat_Recons += atof ( ptb_InRec_Cur[ACCMVT_AMTSTAT_M] ) ;
			Kd_Bil_Recons += atof ( ptb_InRec_Cur[ACCMVT_AMTBIL_M] ) ;
			break ;
	case 10030 :
			Kd_Stat_Prm_Acq += atof ( ptb_InRec_Cur[ACCMVT_AMTSTAT_M] ) ;
			Kd_Bil_Prm_Acq += atof ( ptb_InRec_Cur[ACCMVT_AMTBIL_M] ) ;
			break ;
	case 10100 :
			Kd_Stat_Chg_Acq += atof ( ptb_InRec_Cur[ACCMVT_AMTSTAT_M] ) ;
			Kd_Bil_Chg_Acq += atof ( ptb_InRec_Cur[ACCMVT_AMTBIL_M] ) ;
			break ;
	case 10400 :
			Kd_Stat_Court_Acq += atof ( ptb_InRec_Cur[ACCMVT_AMTSTAT_M] ) ;
			Kd_Bil_Court_Acq += atof ( ptb_InRec_Cur[ACCMVT_AMTBIL_M] ) ;
			break ;
	case -20000 :
			Kd_Stat_Cpte_Compl += atof ( ptb_InRec_Cur[ACCMVT_AMTSTAT_M] ) ;
			Kd_Bil_Cpte_Compl += atof ( ptb_InRec_Cur[ACCMVT_AMTBIL_M] ) ;
			break ;
	case 20000 :
			Kd_Stat_Cpte_Incompl += atof ( ptb_InRec_Cur[ACCMVT_AMTSTAT_M] ) ;
			Kd_Bil_Cpte_Incompl += atof ( ptb_InRec_Cur[ACCMVT_AMTBIL_M] ) ;
			break ;
	case 24030 :
			Kd_Stat_Ibnr2 += atof ( ptb_InRec_Cur[ACCMVT_AMTSTAT_M] ) ;
			Kd_Bil_Ibnr2 += atof ( ptb_InRec_Cur[ACCMVT_AMTBIL_M] ) ;
			break ;
	case 22000 :
			Kd_Stat_Pb_Pap += atof ( ptb_InRec_Cur[ACCMVT_AMTSTAT_M] ) ;
			Kd_Bil_Pb_Pap += atof ( ptb_InRec_Cur[ACCMVT_AMTBIL_M] ) ;
			break ;
	case 21000 :
			Kd_Stat_Loss_Corri += atof ( ptb_InRec_Cur[ACCMVT_AMTSTAT_M] ) ;
			Kd_Bil_Loss_Corri += atof ( ptb_InRec_Cur[ACCMVT_AMTBIL_M] ) ;
			break ;
	case 19000 :
			Kd_Stat_Prm_Rpcc += atof ( ptb_InRec_Cur[ACCMVT_AMTSTAT_M] ) ;
			Kd_Bil_Prm_Rpcc += atof ( ptb_InRec_Cur[ACCMVT_AMTBIL_M] ) ;
			break ;
	case 29000 :
			Kd_Stat_Rpcc += atof ( ptb_InRec_Cur[ACCMVT_AMTSTAT_M] ) ;
			Kd_Bil_Rpcc += atof ( ptb_InRec_Cur[ACCMVT_AMTBIL_M] ) ;

	}      /* fin du switch */
	RETURN_VAL( OK ) ;
}
/*==============================================================================
objet :
	fonction lancee en rupture derniere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRupt1( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionLastRupt1" ) ;

	/* Ecriture d une ligne dans le fichier FSEGACT */

	fprintf( Kp_OutputFilSegAct, "%s~%s~%s~%s~%s~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f\n",
		ptb_InRec_Cur[ACCMVT_SSD_CF], ptb_InRec_Cur[ACCMVT_SEG_NF],
		ptb_InRec_Cur[ACCMVT_UWY_NF], ptb_InRec_Cur[ACCMVT_CUR_CF], ptb_InRec_Cur[ACCMVT_VRS_NF],
		Kd_Stat_Prm, Kd_Stat_Prm_Rpcc, Kd_Stat_Epp_Rpp, Kd_Stat_Recons, Kd_Stat_Prm_Acq,
		Kd_Stat_Chg_Acq, Kd_Stat_Court_Acq , Kd_Stat_Cpte_Compl,
		Kd_Stat_Cpte_Incompl, Kd_Stat_Rpcc, Kd_Stat_Ibnr2, Kd_Stat_Pb_Pap,
		Kd_Stat_Loss_Corri,
		Kd_Bil_Prm, Kd_Bil_Prm_Rpcc, Kd_Bil_Epp_Rpp, Kd_Bil_Recons, Kd_Bil_Prm_Acq,
		Kd_Bil_Chg_Acq, Kd_Bil_Court_Acq, Kd_Bil_Cpte_Compl,
		Kd_Bil_Cpte_Incompl, Kd_Bil_Rpcc, Kd_Bil_Ibnr2, Kd_Bil_Pb_Pap,
		Kd_Bil_Loss_Corri ) ;
           RETURN_VAL( OK ) ;
}
