/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTC1020.c
révision                      : $Revision: 1.2 $
date de création              : 22/08/1997
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   MISE A JOUR DES PRIMES PAR PERIODE DE COMPTE

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
   De maniere execptionnelle ( erreur de compta) on peut avoir pour WFCOD=8000  une cle double . Ce qui entraine une erreur dans la remontee en table de EARIPP. Pour eviter cela on genere une erreur ou l on reconduit les 2 lignes en entree dans une ano et on ecrit aucune de ces lignes dans le fichier de sortie.
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
[002] 18/04/2012 Roger Cassis  :spot:23802 - Ajout colonne PRS_CF pour Solvency
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
#include "ESTC1020.h"

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/* tableau a 2 dimensions pour stocker les val  */
/* du fichier d entree sur deux lignes en cas de*/
/* doublons					*/
/*---------------------------------------------*/

#define DOU_REFPRM_M	0
#define DOU_WPPORT_M	1
#define DOU_WFTYP_CF	2
#define NB_COL_DOU	3

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE 		*Kp_OutputFilCalPre ; /* pointeur sur le fichier de sortie Primes par periode de compte */
FILE 		*Kp_OutputFilEarIpp ; /* pointeur sur le fichier de sortie Acquisitions d'entree de portefeuille */

double Kd_BcR_Prme ;	/* prime de BC et reconstitution estimee */
double Kd_BcR_Prmc ;	/* prime de BC et reconstitution cedante */
double Kd_Prme	    ;	/* prime estimee */
double Kd_Prmc     ;	/* prime cedante */
double Kd_Pnae     ;    /* prime non acquise estimee */
double Kd_Pnac     ;    /* prime non acquise cedante */
int    Kn_compteur ;	/* permet d eviter l ecriture de doublons dans EARIPP */

char *KDoubleIpp[NB_COL_DOU +1][2] ; /*  tableau de pointeur stockant deux lignes du fichiers */

T_RUPTURE_VAR  	bd_RuptFt ; /* variable de gestion de la rupture sur le fichier de travail */

int n_InitFt	 		( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_IsR1Ft			( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_ActionFirstRuptFt		( char **pbd_InRec_Cur ) ;
int n_ActionLigneFt		( char **pbd_InRec_Cur ) ;
int n_ActionLastRuptFt		( char **pbd_InRec_Cur ) ;



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

	/* ouverture du fichier de sortie Acquisitions d'entree de portefeuille */
	if ( n_OpenFileAppl ( "ESTC1020_O1","wt",&Kp_OutputFilEarIpp ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier de sortie Primes par periode de compte */
	if ( n_OpenFileAppl ( "ESTC1020_O2","wt",&Kp_OutputFilCalPre ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptFt */
	if ( n_InitFt( &bd_RuptFt ) )
		ExitPgm( ERR_XX , "" ) ;

	/* lancement du traitement du fichier de travail */
	if ( n_ProcessingRuptureVar( &bd_RuptFt ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1020_I1", &( bd_RuptFt.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1020_O1", &Kp_OutputFilEarIpp ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1020_O2", &Kp_OutputFilCalPre ) == ERR )
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
int n_InitFt(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitFt" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier de travail */
	if ( n_OpenFileAppl( "ESTC1020_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 1 ;

	/* fonction du test de rupture de niveau 1 */
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1Ft ;

	/* fonction lancee en rupture premiere */
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptFt ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneFt ;

	/* Fonction lancee en rupture derniere */
	pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptFt ;

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
int n_IsR1Ft(
	char **pbd_InRec ,  /* adresse de la ligne en avance */
	char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
	int ret ;

	DEBUT_FCT( "n_IsR1Ft" ) ;

	if ( ( ret = strcmp( pbd_InRec[FT_CTR_NF], pbd_InRec_Cur[FT_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[FT_END_NT], pbd_InRec_Cur[FT_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[FT_SEC_NF], pbd_InRec_Cur[FT_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[FT_UWYDIS_NF], pbd_InRec_Cur[FT_UWYDIS_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[FT_UW_NT], pbd_InRec_Cur[FT_UW_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[FT_ACY_NF], pbd_InRec_Cur[FT_ACY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[FT_SCOSTRMTH_NF], pbd_InRec_Cur[FT_SCOSTRMTH_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[FT_SCOENDMTH_NF], pbd_InRec_Cur[FT_SCOENDMTH_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[FT_WFCOD_NT], pbd_InRec_Cur[FT_WFCOD_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[FT_PRS_CF], pbd_InRec_Cur[FT_PRS_CF] ) ) != 0 ) return ret ;              // [002]

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture premiere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRuptFt( char **pbd_InRec_Cur  )
{
	DEBUT_FCT( "n_ActionFirstRuptFt" ) ;

	/* initialisation des montants de primes */
	Kd_Prme = 0 ;
	Kd_Prmc = 0 ;
	Kd_BcR_Prme = 0 ;
	Kd_BcR_Prmc = 0 ;
	Kd_Pnae = 0 ;
	Kd_Pnac = 0 ;
	Kn_compteur = 0 ;

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneFt( char **ptb_InRec_Cur )
{

	char sz_Rpp[30] ;	/* variable intermediaire */
	double d_Rpp     ;   /* prime rpp */

	DEBUT_FCT( "n_ActionLigneFt" ) ;

	/****************************************************************/
	/* Compteur detectant les doublons 				*/
	/* Stockage temporaire de la ligne d entree			*/
	/****************************************************************/
	if ( atol( ptb_InRec_Cur[FT_WFCOD_NT] ) == 8000 )
	{

		d_Rpp = atof( ptb_InRec_Cur[FT_RPPC_M] ) + atof( ptb_InRec_Cur[FT_RPPEA_M] ) ;
		sprintf( sz_Rpp, "%-.3f", d_Rpp ) ;

		KDoubleIpp[DOU_REFPRM_M][Kn_compteur] = ptb_InRec_Cur[FT_PRM_M] ;
		KDoubleIpp[DOU_WPPORT_M][Kn_compteur] = sz_Rpp;
		KDoubleIpp[DOU_WFTYP_CF][Kn_compteur] = ptb_InRec_Cur[FT_WFTYP_CF] ;
		KDoubleIpp[DOU_WFTYP_CF + 1][Kn_compteur] = NULL ;
		Kn_compteur += 1 ;
	}

	/* affectation des montants de primes estimees et cedantes */
	if ( atol( ptb_InRec_Cur[FT_WFCOD_NT] ) == 10000 )
	{
		if ( *ptb_InRec_Cur[FT_WFTYP_CF] == 'E' )
			Kd_Prme = atof( ptb_InRec_Cur[FT_PRM_M] ) ;

		if ( *ptb_InRec_Cur[FT_WFTYP_CF] == 'C' )
			Kd_Prmc = atof( ptb_InRec_Cur[FT_PRM_M] ) ;

		Kd_BcR_Prme += atof( ptb_InRec_Cur[FT_BCE_M] ) + atof( ptb_InRec_Cur[FT_RECE_M] ) ;
		Kd_BcR_Prmc += atof( ptb_InRec_Cur[FT_BCC_M] ) + atof( ptb_InRec_Cur[FT_RECC_M] ) ;

		Kd_Pnae += atof( ptb_InRec_Cur[FT_PPNAEA_M]) + atof(ptb_InRec_Cur[FT_RPPEA_M]) ;
		Kd_Pnac += atof( ptb_InRec_Cur[FT_PPNAC_M]) + atof(ptb_InRec_Cur[FT_RPPC_M]) + atof(ptb_InRec_Cur[FT_LPPNAC_M]) ;
	}

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture derniere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptFt( char **ptb_InRec_Cur  )
{
	char *CalPre[NB_COL_CALPRE + 1] ; /* tableau de pointeur a l'image du fichier des
		primes par periode de compte */

	char *EarIpp[NB_COL_EARIPP + 1] ; /* tableau de pointeur a l'image du fichier des
		acquisitions d'entree de portefeuille */

	char sz_Prme[30] ;	/* variable intermediaire */
	char sz_Prmc[30] ;	/* variable intermediaire */
	char sz_Pnae[30] ;	/* variable intermediaire */
	char sz_Pnac[30] ;	/* variable intermediaire */
	char sz_BcR_Prme[30] ;	/* variable intermediaire */
	char sz_BcR_Prmc[30] ;	/* variable intermediaire */
	char sz_Rpp[30] ;	/* variable intermediaire */
	double d_Rpp     ;   /* prime rpp reconduite dans le fichier EARIPP */
        char    MsgAno[600] ; /* message d'anomalie */

	DEBUT_FCT( "n_ActionLastRuptFt" ) ;

	/****************************************************************/
	/* ecriture en sortie des acquisitions d'entree de portefeuille */
	/****************************************************************/
	if ( atol( ptb_InRec_Cur[FT_WFCOD_NT] ) == 8000 )
	{
		if ( Kn_compteur == 1)
		{
			EarIpp[EAR_CTR_NF] = ptb_InRec_Cur[FT_CTR_NF] ;
			EarIpp[EAR_END_NT] = ptb_InRec_Cur[FT_END_NT] ;
			EarIpp[EAR_SEC_NF] = ptb_InRec_Cur[FT_SEC_NF] ;
			EarIpp[EAR_UWY_NF] = ptb_InRec_Cur[FT_UWYDIS_NF] ;
			EarIpp[EAR_UW_NT] = ptb_InRec_Cur[FT_UW_NT] ;
			EarIpp[EAR_ACY_NF] = ptb_InRec_Cur[FT_ACY_NF] ;
			EarIpp[EAR_SCOSTRMTH_NF] = ptb_InRec_Cur[FT_SCOSTRMTH_NF] ;
			EarIpp[EAR_SCOENDMTH_NF] = ptb_InRec_Cur[FT_SCOENDMTH_NF] ;
			EarIpp[EAR_SSD_CF] = ptb_InRec_Cur[FT_SSD_CF] ;
			EarIpp[EAR_CUR_CF] = ptb_InRec_Cur[FT_EGPCUR_CF] ;
			EarIpp[EAR_REFPRM_M] = ptb_InRec_Cur[FT_PRM_M] ;
			EarIpp[EAR_WPPORT_M] = sz_Rpp ;
			EarIpp[EAR_PRS_CF] = ptb_InRec_Cur[FT_PRS_CF] ;               // [002]
			EarIpp[EAR_PRS_CF + 1] = NULL ;                               // [002]

			d_Rpp = atof( ptb_InRec_Cur[FT_RPPC_M] ) + atof( ptb_InRec_Cur[FT_RPPEA_M] ) ;
			sprintf( sz_Rpp, "%-.3f", d_Rpp ) ;

			n_WriteCols( Kp_OutputFilEarIpp, EarIpp, SEPARATEUR, 0 ) ;
		}
		else
		{
			d_Rpp = atof( ptb_InRec_Cur[FT_RPPC_M] ) + atof( ptb_InRec_Cur[FT_RPPEA_M] ) ;
			sprintf( sz_Rpp, "%-.3f", d_Rpp ) ;

			sprintf( MsgAno, "There was a duplicate key for these 2 lines: CTR: %s - END: %s - SEC - %s UWY: %s - UW: %s - ACY: %s - SCOSTRMTH: %s - SCOENDMTH: %s - SSD: %s - CUR: %s \n Line 1: REFPRM: %s - WPPORT: %s - WFTYP: %s \n Line 2: REFPRM %s - WPPORT: %s - WFTYP: %s ",
			ptb_InRec_Cur[FT_CTR_NF] , ptb_InRec_Cur[FT_END_NT] ,
			ptb_InRec_Cur[FT_SEC_NF] , ptb_InRec_Cur[FT_UWYDIS_NF] ,
			ptb_InRec_Cur[FT_UW_NT] , ptb_InRec_Cur[FT_ACY_NF] ,
			ptb_InRec_Cur[FT_SCOSTRMTH_NF] , ptb_InRec_Cur[FT_SCOENDMTH_NF] ,
			ptb_InRec_Cur[FT_SSD_CF] , ptb_InRec_Cur[FT_EGPCUR_CF] ,
			ptb_InRec_Cur[FT_PRM_M] , sz_Rpp , ptb_InRec_Cur[FT_WFTYP_CF] ,
			KDoubleIpp[DOU_REFPRM_M][0] ,
			KDoubleIpp[DOU_WPPORT_M][0] ,
			KDoubleIpp[DOU_WFTYP_CF][0] ) ;

			n_WriteAno( MsgAno ) ;
		}
	}


	/*******************************************************/
	/* ecriture en sortie des primes par periode de compte */
	/*******************************************************/
	if ( atol( ptb_InRec_Cur[FT_WFCOD_NT] ) == 10000 )
	{
		sprintf( sz_Prmc, "%-.3f", Kd_Prmc ) ;
		sprintf( sz_Prme, "%-.3f", Kd_Prme ) ;
		sprintf( sz_BcR_Prmc, "%-.3f", Kd_BcR_Prmc ) ;
		sprintf( sz_BcR_Prme, "%-.3f", Kd_BcR_Prme ) ;
		sprintf( sz_Pnac, "%-.3f", Kd_Pnac ) ;
		sprintf( sz_Pnae, "%-.3f", Kd_Pnae ) ;

		CalPre[CAL_CTR_NF] = ptb_InRec_Cur[FT_CTR_NF] ;
		CalPre[CAL_END_NT] = ptb_InRec_Cur[FT_END_NT] ;
		CalPre[CAL_SEC_NF] = ptb_InRec_Cur[FT_SEC_NF] ;
		CalPre[CAL_UWY_NF] = ptb_InRec_Cur[FT_UWYDIS_NF] ;
		CalPre[CAL_UW_NT] = ptb_InRec_Cur[FT_UW_NT] ;
		CalPre[CAL_ACY_NF] = ptb_InRec_Cur[FT_ACY_NF] ;
		CalPre[CAL_SCOSTRMTH_NF] = ptb_InRec_Cur[FT_SCOSTRMTH_NF] ;
		CalPre[CAL_SCOENDMTH_NF] = ptb_InRec_Cur[FT_SCOENDMTH_NF] ;
		CalPre[CAL_SSD_CF] = ptb_InRec_Cur[FT_SSD_CF] ;
		CalPre[CAL_CUR_CF] = ptb_InRec_Cur[FT_EGPCUR_CF] ;
		CalPre[CAL_RECPRM_M] = sz_Prmc ;
		CalPre[CAL_BRRECPRM_M] = sz_BcR_Prmc ;
		CalPre[CAL_ESTPRM_M] = sz_Prme ;
		CalPre[CAL_BRESTPRM_M] = sz_BcR_Prme ;
		CalPre[CAL_URNRECPRM_M] = sz_Pnac ;
		CalPre[CAL_URNESTPRM_M] = sz_Pnae ;
		CalPre[CAL_PRS_CF] = ptb_InRec_Cur[FT_PRS_CF] ;               // [002]
		CalPre[CAL_PRS_CF + 1] = NULL ;                               // [002]

		n_WriteCols( Kp_OutputFilCalPre, CalPre, SEPARATEUR, 0 ) ;
	}

	RETURN_VAL ( OK ) ;
}





