/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION
nom du source                 : ESTC3601.c
révision                      : $Revision: 1.2 $
date de création              : 11/09/1998
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :


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

FILE 		*Kp_OutputFilSha ; /* pointeur sur le fichier de sortie */

T_RUPTURE_VAR  	   	bd_RuptPla ; /* variable de gestion de la rupture sur le fichier des placements */
T_RUPTURE_SYNC_VAR 	bd_RuptCes ; /* variable de gestion de la synchronisation avec le fichier versements */

double Kd_ShaRi ;		/* cumul de la part placee en retro interne */
double Kd_ShaRe ; 		/* cumul de la part placee en retro externe */

int n_InitPla	 		( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLignePla		( char **pbd_InRec_Cur ) ;
int n_IsR1Pla			( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_ActionFirstRuptPla		( char **ptb_InRec_Cur ) ;
int n_ActionLastRuptPla		( char **ptb_InRec_Cur ) ;
int n_InitCes			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneCes		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncCes		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;


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

	/* ouverture du fichier de sortie */
	if ( n_OpenFileAppl ( "ESTC3601_O1","wt",&Kp_OutputFilSha ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPla */
	if ( n_InitPla( &bd_RuptPla ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptCes */
	if ( n_InitCes( &bd_RuptCes ) )
		ExitPgm( ERR_XX , "" ) ;

	/* lancement du traitement du fichier maitre */
	if ( n_ProcessingRuptureVar( &bd_RuptPla ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3601_I1", &( bd_RuptPla.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3601_I2", &( bd_RuptCes.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3601_O1", &Kp_OutputFilSha ) == ERR )
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
int n_InitPla(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitPla" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier maitre */
	if ( n_OpenFileAppl( "ESTC3601_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	pbd_Rupt->n_NbRupture = 1 ;

	/* fonction du test de rupture de niveau 1 */
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1Pla ;

	/* Fonction lancee en rupture premiere */
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptPla ;

	/* fonction d'action sur la ligne courante du fichier maitre */
	pbd_Rupt->n_ActionLigne = n_ActionLignePla ;

	/* Fonction lancee en rupture derniere */
	pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptPla ;

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
int n_IsR1Pla(
	char **pbd_InRec ,  /* adresse de la ligne en avance */
	char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
	int ret ;

	DEBUT_FCT( "n_IsR1Pla" ) ;

	if ( ( ret = strcmp( pbd_InRec[PLA_RETCTR_NF], pbd_InRec_Cur[PLA_RETCTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRec[PLA_RETEND_NT] ) - atoi( pbd_InRec_Cur[PLA_RETEND_NT] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRec[PLA_RETSEC_NF] ) - atoi( pbd_InRec_Cur[PLA_RETSEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRec[PLA_RTY_NF] ) - atoi( pbd_InRec_Cur[PLA_RTY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRec[PLA_RETUW_NT] ) - atoi( pbd_InRec_Cur[PLA_RETUW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture premiere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRuptPla( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionFirstRuptPla" ) ;

	/* Initialisation des variables */
	Kd_ShaRi = 0 ;
	Kd_ShaRe = 0 ;

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePla( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionLignePla" ) ;

	/* Part placee en retro interne ou externe */
	if ( atoi( ptb_InRec_Cur[PLA_SSDRTO_B] ) == 1 )
		Kd_ShaRi = atof( ptb_InRec_Cur[PLA_RETSIGSHA_R] ) ;
	else	Kd_ShaRe = atof( ptb_InRec_Cur[PLA_RETSIGSHA_R] ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture derniere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptPla( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionLastRuptPla" ) ;

	/* synchronisation avec le fichier fils */
	n_ProcessingRuptureSyncVar( &bd_RuptCes, ptb_InRec_Cur ) ;

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l’esclave

retour :
	OK
==============================================================================*/
int n_InitCes( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitCes" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC3601_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncCes ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneCes ;

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
int n_ConditionSyncCes(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncCes" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PLA_RETCTR_NF], pbd_InRecChild[CES_RETCTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PLA_RETEND_NT] ) - atoi( pbd_InRecChild[CES_RETEND_NT] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PLA_RETSEC_NF] ) - atoi( pbd_InRecChild[CES_RETSEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PLA_RTY_NF] ) - atoi( pbd_InRecChild[CES_RTY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PLA_RETUW_NT] ) - atoi( pbd_InRecChild[CES_RETUW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneCes(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	double 	d_ShaCumRi ;		/* zone de travail */
	double 	d_ShaCumRe ;		/* zone de travail */

	DEBUT_FCT( "n_ActionLigneCes" ) ;

	/* Calcul des taux de part placee */
	d_ShaCumRi = Kd_ShaRi * atof( ptb_InRecChild[CES_CESSH_R] ) ;
	d_ShaCumRe = Kd_ShaRe * atof( ptb_InRecChild[CES_CESSH_R] ) ;

	/* Ecriture en sortie */
	fprintf( Kp_OutputFilSha, "%s~%s~%s~%s~%s~%-.8f~%-.8f\n",
		ptb_InRecChild[CES_CTR_NF],
		ptb_InRecChild[CES_END_NT],
		ptb_InRecChild[CES_SEC_NF],
		ptb_InRecChild[CES_UWY_NF],
		ptb_InRecChild[CES_UW_NT],
		d_ShaCumRi,
		d_ShaCumRe ) ;

	RETURN_VAL( OK ) ;
}



