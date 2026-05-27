/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTC2319.c
révision                      : $Revision: 1.2 $
date de création              : 09/10/1997
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   CALCUL DES ECARTS

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
#include "estserv.h"


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

FILE 			*Kp_OutputFilFt ; /* pointeur sur le fichier de travail en sortie */
FILE 			*Kp_InputFilExc ; /* pointeur sur le fichier des cours en entree */

T_RUPTURE_VAR  	   	bd_RuptGtar ; 	/* variable de gestion de la rupture sur le GTRr */

T_RUPTURE_SYNC_VAR 	bd_RuptPlc1 ; 	/* variable de gestion de la synchronisation avec
						le fichier des derniers placements */
T_RUPTURE_SYNC_VAR 	bd_RuptPlc2 ; 	/* variable de gestion de la synchronisation avec
						le fichier des placements bilan - 1 */

double 	Kd_EcaPlc ;	/* ecart placement */
double  Kd_EcaExc ;	/* ecart change */
double  Kd_Plc1 ;	/* placement global issu du fichier des derniers placements */
double  Kd_Plc2 ;	/* placement global issu du fichier des placements bilan - 1 */


int n_InitGtar	 		( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_IsR1Gtar			( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_IsR2Gtar			( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_ActionFirstRupt1Gtar	( char **pbd_InRec_Cur ) ;
int n_ActionFirstRupt2Gtar	( char **pbd_InRec_Cur ) ;
int n_ActionLigneGtar		( char **pbd_InRec_Cur ) ;
int n_ActionLastRupt2Gtar	( char **pbd_InRec_Cur ) ;

int n_InitPlc1			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLignePlc1		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncPlc1		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitPlc2			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLignePlc2		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncPlc2		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ActionPereSansFilsPlc2	( char **pbd_InRecOwner ) ;


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

	/* ouverture du fichier de travail en sortie */
	if ( n_OpenFileAppl ( "ESTC2319_O1","wt",&Kp_OutputFilFt ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier en entree des cours de change FCURQUOT */
	if ( n_OpenFileAppl ( "ESTC2319_I4","rb",&Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptGtar */
	if ( n_InitGtar( &bd_RuptGtar ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPlc1 */
	if ( n_InitPlc1( &bd_RuptPlc1 ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPlc2r */
	if ( n_InitPlc2( &bd_RuptPlc2 ) )
		ExitPgm( ERR_XX , "" ) ;

	/* lancement du traitement du fichier GTRr */
	if ( n_ProcessingRuptureVar( &bd_RuptGtar ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2319_I1", &( bd_RuptGtar.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2319_I2", &( bd_RuptPlc1.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2319_I3", &( bd_RuptPlc2.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2319_I4", &Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2319_O1", &Kp_OutputFilFt ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_EndPgm() == ERR )
		ExitPgm( ERR_XX , "" );

	exit( OK ) ;
}


/*==============================================================================
objet :
	fonction d'initialisation de la variable de gestion de rupture du fichier
	maitre.

retour :
	0K
==============================================================================*/
int n_InitGtar(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitGtar" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier maitre GTAr */
	if ( n_OpenFileAppl( "ESTC2319_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 2 ;

	/* fonction du test de rupture de niveau 1 */
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1Gtar ;

	/* fonction du test de rupture de niveau 2 */
	pbd_Rupt->n_ConditionRupture[1] = n_IsR2Gtar ;

	/* fonction lancee en rupture premiere de niveau 1 */
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRupt1Gtar ;

	/* fonction lancee en rupture premiere de niveau 2 */
	pbd_Rupt->n_ActionFirst[1] = n_ActionFirstRupt2Gtar ;

	/* fonction d'action sur la ligne courante du fichier maitre */
	pbd_Rupt->n_ActionLigne = n_ActionLigneGtar ;

	/* Fonction lancee en rupture derniere de niveau 2 */
	pbd_Rupt->n_ActionLast[1] = n_ActionLastRupt2Gtar ;

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
int n_IsR1Gtar(
	char **ptb_InRec ,  /* adresse de la ligne en avance */
	char **ptb_InRec_Cur  ) /* adresse de la ligne courante */
{
	int ret ;

	DEBUT_FCT( "n_IsR1Gtar" ) ;

	if ( ( ret = strcmp( ptb_InRec[GT_RETCTR_NF], ptb_InRec_Cur[GT_RETCTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_RETEND_NT], ptb_InRec_Cur[GT_RETEND_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_RETSEC_NF], ptb_InRec_Cur[GT_RETSEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_RTY_NF], ptb_InRec_Cur[GT_RTY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_RETUW_NT], ptb_InRec_Cur[GT_RETUW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction de test de rupture de niveau 2

retour :
	0	---> pas de rupture
	sinon   	---> rupture
==============================================================================*/
int n_IsR2Gtar(
	char **ptb_InRec ,  /* adresse de la ligne en avance */
	char **ptb_InRec_Cur  ) /* adresse de la ligne courante */
{
	int ret ;

	DEBUT_FCT( "n_IsR2Gtar" ) ;

	if ( ( ret = strcmp( ptb_InRec[GT_RETCTR_NF], ptb_InRec_Cur[GT_RETCTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_RETEND_NT], ptb_InRec_Cur[GT_RETEND_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_RETSEC_NF], ptb_InRec_Cur[GT_RETSEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_RTY_NF], ptb_InRec_Cur[GT_RTY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_RETUW_NT], ptb_InRec_Cur[GT_RETUW_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_SSD_CF], ptb_InRec_Cur[GT_SSD_CF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_ESB_CF], ptb_InRec_Cur[GT_ESB_CF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_CTR_NF], ptb_InRec_Cur[GT_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_END_NT], ptb_InRec_Cur[GT_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_SEC_NF], ptb_InRec_Cur[GT_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_UWY_NF], ptb_InRec_Cur[GT_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_UW_NT], ptb_InRec_Cur[GT_UW_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_RETCUR_CF], ptb_InRec_Cur[GT_RETCUR_CF] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture premiere de niveau 1

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRupt1Gtar( char **pbd_InRec_Cur  )
{
	DEBUT_FCT( "n_ActionFirstRupt1Gtar" ) ;

	/* initialisation des placements globaux */
	Kd_Plc1 = 0 ;
	Kd_Plc2 = 0 ;

	/* synchronisation avec le fichier des derniers placements */
	n_ProcessingRuptureSyncVar( &bd_RuptPlc1, pbd_InRec_Cur ) ;

	/* synchronisation avec le fichier des placements bilan - 1 */
	n_ProcessingRuptureSyncVar( &bd_RuptPlc2, pbd_InRec_Cur ) ;

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture premiere de niveau 2

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRupt2Gtar( char **pbd_InRec_Cur  )
{
	DEBUT_FCT( "n_ActionFirstRupt2Gtar" ) ;

	/* initialisation des ecarts placement et change */
	Kd_EcaPlc = 0 ;
	Kd_EcaExc = 0 ;

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGtar( char **ptb_InRec_Cur )
{
	char	MsgAno[300] ;

	double	d_Ratio1 ; /* ( dernier cours CUR_CF pour l'annee bilan ) / ( dernier cours RETCUR_CF pour l'annee bilan ) */
	double  d_Ratio2 ; /* ( cours CUR_CF au 31/12/bilan - 1 ) / ( cours RETCUR_CF au 31/12/bilan - 1 ) */

	DEBUT_FCT( "n_ActionLigneGtar" ) ;

	/**********************************************************/
	/* Calcul des cours de change d'ouverture et d'inventaire */
	/**********************************************************/
	if ( strcmp( ptb_InRec_Cur[GT_CUR_CF], ptb_InRec_Cur[GT_RETCUR_CF] ) != 0 )
	{
		d_Ratio1 = d_GetTaux( Kp_InputFilExc, (char) atoi( ptb_InRec_Cur[GT_SSD_CF] ),
			atoi( ptb_InRec_Cur[GT_BALSHEY_NF] ), ptb_InRec_Cur[GT_CUR_CF], ptb_InRec_Cur[GT_RETCUR_CF] ) ;

		/* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
		if ( d_Ratio1 < 0 )
		{
			sprintf( MsgAno, "The rate of acceptance currency ( %s ) or the rate of retrocession currency ( %s ) for the year %s isn't known for the contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s - SSD %s ) \n",
				ptb_InRec_Cur[GT_CUR_CF], ptb_InRec_Cur[GT_RETCUR_CF], ptb_InRec_Cur[GT_BALSHEY_NF],
				ptb_InRec_Cur[GT_CTR_NF], ptb_InRec_Cur[GT_END_NT], ptb_InRec_Cur[GT_SEC_NF],
				ptb_InRec_Cur[GT_UWY_NF], ptb_InRec_Cur[GT_UW_NT], ptb_InRec_Cur[GT_SSD_CF] ) ;
			n_WriteAno( MsgAno ) ;

			d_Ratio1 = 0 ;
		}


		d_Ratio2 = d_GetTaux( Kp_InputFilExc, (char) atoi( ptb_InRec_Cur[GT_SSD_CF] ),
			atoi( ptb_InRec_Cur[GT_BALSHEY_NF] ) - 1, ptb_InRec_Cur[GT_CUR_CF], ptb_InRec_Cur[GT_RETCUR_CF] ) ;

		/* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
		if ( d_Ratio2 < 0 )
		{
			sprintf( MsgAno, "The rate of acceptance currency ( %s ) or the rate of retrocession currency ( %s ) for the year %d isn't known for the contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s - SSD %s ) \n",
				ptb_InRec_Cur[GT_CUR_CF], ptb_InRec_Cur[GT_RETCUR_CF], ( atoi( ptb_InRec_Cur[GT_BALSHEY_NF] ) ),
				ptb_InRec_Cur[GT_CTR_NF], ptb_InRec_Cur[GT_END_NT], ptb_InRec_Cur[GT_SEC_NF],
				ptb_InRec_Cur[GT_UWY_NF], ptb_InRec_Cur[GT_UW_NT], ptb_InRec_Cur[GT_SSD_CF] ) ;
			n_WriteAno( MsgAno ) ;

			d_Ratio2 = 1 ;
		}
	}
	else
	{
		/* les devises acceptation et retro sont identiques */
		d_Ratio1 = 1 ;
		d_Ratio2 = 1 ;
	}

	/* Generation d'une anomalie si la part cedee n'est pas renseignee dans le fichier
	des placements du bilan - 1 */
	if ( Kd_Plc2 == 0 )
	{
		sprintf( MsgAno, "The retro signed share is null in the placement file ( balance sheet year - 1 ) for the contract ( RETCTR %s - RETEND %s - RETSEC %s - RTY %s - RETUW %s ) \n",
			ptb_InRec_Cur[GT_RETCTR_NF], ptb_InRec_Cur[GT_RETEND_NT], ptb_InRec_Cur[GT_RETSEC_NF],
			ptb_InRec_Cur[GT_RTY_NF], ptb_InRec_Cur[GT_RETUW_NT] ) ;
		n_WriteAno( MsgAno ) ;

		Kd_Plc2 = 1 ;
	}

	/***********************************/
	/* Calcul des ecarts et des cumuls */
	/***********************************/
	Kd_EcaPlc += atof( ptb_InRec_Cur[GT_RETAMT_M] ) * ( 1 - ( Kd_Plc1 / Kd_Plc2 ) ) ;
	Kd_EcaExc += atof( ptb_InRec_Cur[GT_RETAMT_M] ) * ( Kd_Plc1 / Kd_Plc2 ) * ( 1 - ( d_Ratio1 / d_Ratio2 ) ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture derniere de niveau 2

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRupt2Gtar( char **ptb_InRec_Cur  )
{
	DEBUT_FCT( "n_ActionLastRupt2Gtar" ) ;

	/* ecriture d'une ligne en sortie dans le fichier de travail */
	fprintf( Kp_OutputFilFt, "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~~~~~%-.3f~%-.3f~~~~~~~~~\n",
		ptb_InRec_Cur[GT_SSD_CF], ptb_InRec_Cur[GT_ESB_CF], ptb_InRec_Cur[GT_CTR_NF],
		ptb_InRec_Cur[GT_END_NT], ptb_InRec_Cur[GT_SEC_NF], ptb_InRec_Cur[GT_UWY_NF],
		ptb_InRec_Cur[GT_UW_NT], ptb_InRec_Cur[GT_RETCTR_NF], ptb_InRec_Cur[GT_RETEND_NT],
		ptb_InRec_Cur[GT_RETSEC_NF], ptb_InRec_Cur[GT_RTY_NF], ptb_InRec_Cur[GT_RETUW_NT],
		ptb_InRec_Cur[GT_RETCUR_CF], Kd_EcaPlc, Kd_EcaExc ) ;

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « GTAr »
	avec l’esclave « fichier des derniers placements »

retour :
	OK
==============================================================================*/
int n_InitPlc1( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitPlc1" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC2319_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncPlc1 ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLignePlc1 ;

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
int n_ConditionSyncPlc1(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncPlc1" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[GT_RETCTR_NF], pbd_InRecChild[PLA_RETCTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[GT_RETEND_NT], pbd_InRecChild[PLA_RETEND_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[GT_RETSEC_NF], pbd_InRecChild[PLA_RETSEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[GT_RTY_NF], pbd_InRecChild[PLA_RTY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[GT_RETUW_NT], pbd_InRecChild[PLA_RETUW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePlc1(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLignePlc1" ) ;

	/* cumul de la part cedee */
	Kd_Plc1 += atof( ptb_InRecChild[PLA_RETSIGSHA_R] ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « GTAr »
	avec l’esclave « fichier des placements bilan - 1 »

retour :
	OK
==============================================================================*/
int n_InitPlc2( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitPlc2" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC2319_I3", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncPlc2 ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLignePlc2 ;

	/* fonction d'action lancee quand l'esclave n'a pas de maitre */
	pbd_Rupt->n_PereSansFils = n_ActionPereSansFilsPlc2 ;

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
int n_ConditionSyncPlc2(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncPlc2" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[GT_RETCTR_NF], pbd_InRecChild[PLA_RETCTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[GT_RETEND_NT], pbd_InRecChild[PLA_RETEND_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[GT_RETSEC_NF], pbd_InRecChild[PLA_RETSEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[GT_RTY_NF], pbd_InRecChild[PLA_RTY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[GT_RETUW_NT], pbd_InRecChild[PLA_RETUW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePlc2(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLignePlc2" ) ;

	/* cumul de la part cedee */
	Kd_Plc2 += atof( ptb_InRecChild[PLA_RETSIGSHA_R] ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee quand l'esclave n'a pas de maitre

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionPereSansFilsPlc2(
	char **ptb_InRecOwner ) /* adresse de la ligne du maitre */
{
	char	MsgAno[300] ;

	DEBUT_FCT( "n_ActionPereSansFilsPlc2" ) ;

	/* positionnement par defaut du placement global */
	Kd_Plc2 = 1 ;

	/* generation d'une anomalie */
	sprintf( MsgAno, "The TL retro contract ( RETCTR %s - RETEND %s - RETSEC %s - RTY %s - RETUW %s ) doesn't exist in the placement file of balance sheet year - 1\n",
		ptb_InRecOwner[GT_RETCTR_NF],  ptb_InRecOwner[GT_RETEND_NT], ptb_InRecOwner[GT_RETSEC_NF],
		ptb_InRecOwner[GT_RTY_NF], ptb_InRecOwner[GT_RETUW_NT] ) ;
	n_WriteAno( MsgAno ) ;

	RETURN_VAL( OK ) ;
}


