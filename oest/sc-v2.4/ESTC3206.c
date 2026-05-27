/*==============================================================================
nom de l'application          : ESTIMATION lot 32
nom du source                 : ESTC3206.c
révision                      : $Revision:   1.6  $
date de création              : 27/06/1997
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   Mise a jour des ultimes ( nouvelle version du 17/10/97 : ajout prime de compétence et ACR )


------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	   ...           ...            ...              ...
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "estserv.h"
#include "ESTC3206.h"
	
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

FILE 		*Kp_OutputFilUlt ; /* pointeur sur le fichier de sortie Primes et sinistres ultimes */
FILE 		*Kp_OutputFilCplAmt ; /* pointeur sur le fichier de sortie Montants stats par affaire */
FILE 		*Kp_OutputFilUw ; /* pointeur sur le fichier de sortie Souscription */
FILE 		*Kp_OutputFilRmd ; /* pointeur sur le fichier de sortie Agenda */
FILE		*Kp_FilAutPar ; /* pointeur sur le fichier parametrage des automatismes en entree */

T_RUPTURE_VAR  	   	bd_RuptAff; /* variable de gestion de la rupture sur la liste des affaires */

T_RUPTURE_SYNC_VAR 	bd_RuptUlt; /* variable de gestion de la synchronisation avec 
						le fichier des Primes et sinistres ultimes */
T_RUPTURE_SYNC_VAR 	bd_RuptRec; /* variable de gestion de la synchronisation avec 
						le fichier des Parametres de reconstitution */
T_RUPTURE_SYNC_VAR 	bd_RuptMvt; /* variable de gestion de la synchronisation avec 
						le fichier des Mouvements comptables */

char Kc_TypTrait ; 	/* argument du programme correspondant au type de traitement
					'Q' quotidien et 'R' reprise */
int Kn_Pa ;			/* variable de participations des fichiers esclaves */
int Kn_RecRnk ;		/* variable correspondant au rang de reconstitutions par affaire */
short Kn_NbLigneAutPar ; 	/* nombre de lignes du tableau de parametrage des automatismes */ 
T_AUTPAR Kbd_AutPar[NB_AUTPAR_MAX] ; /* tableau de parametrage des automatismes */

T_AFFAIRE Kbd_Aff ; 	/* variable intermediaire de type Liste des affaires */
T_ULTIME Kbd_Ult ; 	/* variable intermediaire de type Primes et sinistres ultimes */
T_PCSAMT Kbd_Pcs ; 	/* variable intermediaire de type Montants prime, charge et sinistre */
T_LIGNEREC Kbd_Rec[NB_REC_MAX] ; /* variable intermediaire Tableau de reconstitution */

T_ULTIME Kbd_UltOut ; 	/* variable de sortie de type Primes et sinistres ultimes */
T_SOUS Kbd_Uw ; 		/* variable de sortie de type Souscription */
T_STATS Kbd_CplAmt ;	/* variable de sortie de type Montants Stats*/
T_AGENDA Kbd_Rmd ;	/* variable de sortie Agenda */

int n_InitAff	 	( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLigneAff	( char **pbd_InRec_Cur ) ;

int n_InitUlt		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneUlt	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncUlt	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitRec		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneRec	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncRec	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_IsR1Rec		( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_ActionFirstRuptRec( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ActionLastRuptRec	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitMvt		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneMvt( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncMvt	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_IsR1Mvt		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ActionLastRuptMvt	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_ProcessingRuptureSyncVar (
			T_RUPTURE_SYNC_VAR  *pbd_Rupt, 
			char **ptb_InRecOwner );

int n_InitVariables( T_AFFAIRE *pbd_Aff, T_ULTIME *pbd_Ult, T_PCSAMT *pbd_Pcs, T_LIGNEREC *pbd_Rec, 
	T_ULTIME *pbd_UltOut, T_SOUS *pbd_Uw, T_STATS *pbd_CplAmt, T_AGENDA *pbd_Rmd ) ;

int n_CopyAff( char **ptb_InRecOwner, T_AFFAIRE *pbd_Aff ) ; 
int n_CopyUlt( char **ptb_InRecChild, T_ULTIME *pbd_Ult ) ; 
int n_CopyPcs( char **ptb_InRecChild, T_PCSAMT *pbd_Pcs ) ; 
int n_CopyRec( char **ptb_InRecChild, T_LIGNEREC *pbd_Rec ) ; 

int n_ChargerAutPar( void ) ;

int n_UpdateUltUw( T_AFFAIRE *pbd_Aff, T_ULTIME *pbd_Ult, T_PCSAMT *pbd_Pcs, T_LIGNEREC *pbd_Rec,
	T_AUTPAR *pbd_AutPar, short n_NbPoste, T_ULTIME *pbd_UltOut, T_SOUS *pbd_Uw  ) ;
int n_UpdateCplAmt( T_AFFAIRE *pbd_Aff, T_PCSAMT *pbd_Pcs, T_STATS *pbd_CplAmt  ) ;
int n_UpdateRmd( T_AFFAIRE *pbd_Aff, T_PCSAMT *pbd_Pcs, T_ULTIME *pbd_UltOut, T_AGENDA *pbd_Rmd ) ;

int n_WriteUlt( FILE *Kp_OutputFil, T_ULTIME *pbd_UltOut ) ;
int n_WriteCplAmt( FILE *Kp_OutputFil, T_STATS *pbd_CplAmt ) ;
int n_WriteUw( FILE *Kp_OutputFil, T_SOUS *pbd_Uw ) ;
int n_WriteRmd( FILE *Kp_OutputFil, T_AGENDA *pbd_Rmd ) ;


/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
void main(int argc  , char *argv[])
{
	/* Initialisation des signaux */
	InitSig () ;

	if ( n_BeginPgm ( argc, argv ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* recuperation du type de traitement 'Q' ou 'R' passe en argument */
	Kc_TypTrait = *( psz_GetCharArgv( 1 ) ) ;

	/* ouverture du fichier de sortie Primes et sinistres ultimes */
	if ( n_OpenFileAppl ( "ESTC3206_O1","wt",&Kp_OutputFilUlt ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier de sortie Montants stats par affaire */
	if ( n_OpenFileAppl ( "ESTC3206_O2","wt",&Kp_OutputFilCplAmt ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier de sortie Souscription */
	if ( n_OpenFileAppl ( "ESTC3206_O3","wt",&Kp_OutputFilUw ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier de sortie Agenda */
	if ( n_OpenFileAppl ( "ESTC3206_O4","wt",&Kp_OutputFilRmd ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptAff */
	if ( n_InitAff( &bd_RuptAff ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptUlt */
	if ( n_InitUlt( &bd_RuptUlt ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptRec */
	if ( n_InitRec( &bd_RuptRec ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptMvt */
	if ( n_InitMvt( &bd_RuptMvt ) )
		ExitPgm( ERR_XX , "" ) ;

	/* chargement en memoire du fichier de parametrage des automatismes ESTAUTPAR.dat */
	n_ChargerAutPar( ) ; 

	/* lancement du traitement du fichier Liste des affaires ESTCTRLIS_02.dat */	
	if ( n_ProcessingRuptureVar( &bd_RuptAff ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3206_I1", &( bd_RuptMvt.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3206_I2", &( bd_RuptRec.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3206_I3", &( bd_RuptUlt.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3206_I4", &( bd_RuptAff.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3206_O1", &Kp_OutputFilUlt ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3206_02", &Kp_OutputFilCplAmt ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC3206_03", &Kp_OutputFilUw ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC3206_04", &Kp_OutputFilRmd ) == ERR )
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
n_InitAff(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitAff" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier maitre Liste des affaires */
	if ( n_OpenFileAppl( "ESTC3206_I4", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction d'action sur la ligne courante du fichier Liste des affaires */
	pbd_Rupt->n_ActionLigne = n_ActionLigneAff ;

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
int n_ActionLigneAff( char **ptb_InRec_Cur )
{
	char	MsgAno[300] ; /* message d'anomalie */
	
	DEBUT_FCT( "n_ActionLigneAff" ) ;

	/* initialisation de la variable de participation des fichiers */
	Kn_Pa = 0 ; 

	/* initialisation des variables intermediaires et de sortie */
	n_InitVariables( &Kbd_Aff, &Kbd_Ult, &Kbd_Pcs, Kbd_Rec, &Kbd_UltOut, &Kbd_Uw, &Kbd_CplAmt, &Kbd_Rmd ) ; 

	/* synchronisation avec le fichier Primes et sinistres ultimes */
	n_ProcessingRuptureSyncVar( &bd_RuptUlt, ptb_InRec_Cur ) ;

	/* synchronisation avec le fichier Mouvement comptable */
	n_ProcessingRuptureSyncVar( &bd_RuptMvt, ptb_InRec_Cur ) ;

	/* synchronisation avec le fichier Parametres de reconstitution */
	n_ProcessingRuptureSyncVar( &bd_RuptRec, ptb_InRec_Cur ) ;

	/* generation d'une anomalie si le fichier des Primes et sinistres ultimes ne participe pas */
	if ( Kn_Pa == 2 || Kn_Pa == 4 || Kn_Pa == 6 )
	{
		if ( Kbd_Aff.SECACCSTS_CT != 'C' ) ; /* etat comptable de la section */
		{
		sprintf( MsgAno, "L'affaire (Contrat %s /Avenant %s /Section %s /Exercice %s /Numero ex %s) n'existe pas dans le fichier des Primes et Sinistres ultimes",
		ptb_InRec_Cur[AFF_CTR_NF], ptb_InRec_Cur[AFF_END_NT], ptb_InRec_Cur[AFF_SEC_NF],   
		ptb_InRec_Cur[AFF_UWY_NF], ptb_InRec_Cur[AFF_UW_NT] ) ;

		n_WriteAno ( MsgAno ) ; /* Generation d'une ANOMLIE */	
		}
	}

	/* lancement du traitement principal si les 3 fichiers "Liste des affaires, Primes et
sinistres ultimes et Mouvements comptables participent */
	if ( Kn_Pa == 3 || Kn_Pa == 7 )
	{
		/* mise a jour des variables de sortie Kbd_UltOut et Kbd_Uw */
		n_UpdateUltUw( &Kbd_Aff, &Kbd_Ult, &Kbd_Pcs, Kbd_Rec, Kbd_AutPar, Kn_NbLigneAutPar, &Kbd_UltOut, &Kbd_Uw  ) ;

		/* mise a jour de la variable de sortie Kbd_CplAmt */
		n_UpdateCplAmt( &Kbd_Aff, &Kbd_Pcs, &Kbd_CplAmt  ) ;

		/* mise a jour de la variable de sortie Kbd_Rmd */
		if ( Kc_TypTrait == 'Q' )
		n_UpdateRmd( &Kbd_Aff, &Kbd_Pcs, &Kbd_UltOut, &Kbd_Rmd ) ;	
	}

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Liste des affaires » avec
	l’esclave « Primes et sinistres ultimes »

retour :
	OK
==============================================================================*/
n_InitUlt( T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitUlt" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave Primes et sinistres ultimes */
	if ( n_OpenFileAppl( "ESTC3206_I3", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR ) 
		return ERR ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncUlt ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneUlt ;

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
int n_ConditionSyncUlt(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncUlt" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[AFF_CTR_NF], pbd_InRecChild[ULT_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[AFF_END_NT], pbd_InRecChild[ULT_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[AFF_SEC_NF], pbd_InRecChild[ULT_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[AFF_UWY_NF], pbd_InRecChild[ULT_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[AFF_UW_NT], pbd_InRecChild[ULT_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneUlt(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{	
	DEBUT_FCT( "n_ActionLigneUlt" ) ;

	/* Positionnement de la variable de participation */
	Kn_Pa += 1 ;

	/* Copie des rubriques du fichier Liste des affaires vers une variable */
	n_CopyAff( ptb_InRecOwner, &Kbd_Aff ) ;

	/* Copie de certaines rubriques du fichier Primes et sinistres ultimes 
	vers une variable */
	n_CopyUlt( ptb_InRecChild, &Kbd_Ult ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Liste des affaires » avec
	l'esclave « Mouvements comptables »

retour :
	OK
==============================================================================*/
n_InitMvt(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitMvt" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave Mouvements comptables */
	if ( n_OpenFileAppl( "ESTC3206_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR ) 
		return ERR ;

	/* nombre de rupture a gerer sur le fichier Mouvements comptables */
	pbd_Rupt->n_NbRupture = 1 ;

	/* fonction du test de rupture de niveau 1 */
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1Mvt ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncMvt ;

	/* Fonction lancee en rupture derniere */
	pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptMvt ;

	/* fonction d'action sur la ligne courante */
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
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncMvt" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[AFF_CTR_NF], pbd_InRecChild[MVT_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[AFF_END_NT], pbd_InRecChild[MVT_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[AFF_SEC_NF], pbd_InRecChild[MVT_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[AFF_UWY_NF], pbd_InRecChild[MVT_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[AFF_UW_NT], pbd_InRecChild[MVT_UW_NT] ) ) != 0 ) return ret ;

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
	DEBUT_FCT( "n_ActionLigneSyncMvt" ) ;

	/* Copie des rubriques du fichier Mouvements comptables vers une variable de type PcsAmt */
	n_CopyPcs( ptb_InRecChild, &Kbd_Pcs ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction de test de rupture de niveau 1

retour :
	0	---> pas de rupture
	sinon   	---> rupture
==============================================================================*/
int n_IsR1Mvt(
	char **pbd_InRec ,  /* adresse de la ligne en avance */
	char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
	int ret ;

	DEBUT_FCT( "n_IsR1Mvt" ) ;

	if ( ( ret = strcmp( pbd_InRec[MVT_CTR_NF], pbd_InRec_Cur[MVT_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[MVT_END_NT], pbd_InRec_Cur[MVT_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[MVT_SEC_NF], pbd_InRec_Cur[MVT_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[MVT_UWY_NF], pbd_InRec_Cur[MVT_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[MVT_UW_NT], pbd_InRec_Cur[MVT_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture derniere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptMvt( 
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{		
	DEBUT_FCT( "n_ActionLastRuptMvt" ) ;

	/* Positionnememt de la variable de participation */
	Kn_Pa += 2 ;

	RETURN_VAL ( OK ) ;
}




/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Liste des affaires » avec
	l'esclave « Parametres de reconstitution »

retour :
	OK
==============================================================================*/
n_InitRec(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitRec" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave Parametres de reconstitution */
	if ( n_OpenFileAppl( "ESTC3206_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR ) 
		return ERR ;

	/* nombre de rupture a gerer sur le fichier Parametres de reconstitution */
	pbd_Rupt->n_NbRupture = 1 ;

	/* fonction du test de rupture de niveau 1 */
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1Rec ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncRec ;

	/* fonction lancee en rupture premiere */
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptRec ;

	/* Fonction lancee en rupture derniere */
	pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptRec ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneRec ;

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
int n_ConditionSyncRec(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncRec" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[AFF_CTR_NF], pbd_InRecChild[REC_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[AFF_END_NT], pbd_InRecChild[REC_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[AFF_SEC_NF], pbd_InRecChild[REC_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[AFF_UWY_NF], pbd_InRecChild[REC_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[AFF_UW_NT], pbd_InRecChild[REC_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction de test de rupture de niveau 1

retour :
	0	---> pas de rupture
	sinon   	---> rupture
==============================================================================*/
int n_IsR1Rec(
	char **pbd_InRec ,  /* adresse de la ligne en avance */
	char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
	int ret ;

	DEBUT_FCT( "n_IsR1Rec" ) ;

	if ( ( ret = strcmp( pbd_InRec[REC_CTR_NF], pbd_InRec_Cur[REC_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[REC_END_NT], pbd_InRec_Cur[REC_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[REC_SEC_NF], pbd_InRec_Cur[REC_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[REC_UWY_NF], pbd_InRec_Cur[REC_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[REC_UW_NT], pbd_InRec_Cur[REC_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture premiere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRuptRec(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{		
	DEBUT_FCT( "n_ActionFirstRuptRec" ) ;

	/* initialisation de la variable du rang de reconstitution */
	Kn_RecRnk = 0 ;

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneRec(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{	
	DEBUT_FCT( "n_ActionLigneRec" ) ;

	/* Copie des rubriques du fichier Parametres de reconstitution vers une variable de type LigneRec */
	n_CopyRec( ptb_InRecChild, &Kbd_Rec[ Kn_RecRnk++ ] ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture derniere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptRec(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{		
	DEBUT_FCT( "n_ActionLastRuptRec" ) ;

	/* Positionnememt de la variable de participation */
	Kn_Pa += 4 ;

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction de chargement du fichier de parametrage des automatismes

retour :	0

==============================================================================*/
int n_ChargerAutPar( ) 
{
	int n_EOF = 0 ;
	T_AUTPAR bd_Lu ;

	DEBUT_FCT( "n_ChargerAutPar" ) ;

	/* ouverture du fichier ESTAUTPAR.dat */
	if ( n_OpenFileAppl ( "ESTC3206_I5","rb",&Kp_FilAutPar ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* initialisation du compteur de ligne du fichier ESTAUTPAR.dat */
	Kn_NbLigneAutPar = 0 ;

	/* initialisation du tableau de parametrage des automatismes */
	memset( Kbd_AutPar, 0, ( NB_AUTPAR_MAX * sizeof( T_AUTPAR ) ) ) ; 

	/* chargement du tableau Parametrage des automatismes */
	Kn_NbLigneAutPar = fread( Kbd_AutPar, sizeof( T_AUTPAR ), NB_AUTPAR_MAX, Kp_FilAutPar ) ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction d'initialisation des variables intermediaire au traitement principal	 
	et des variables d'ecriture dans les fichiers de sortie.

	retour :	0

==============================================================================*/
int n_InitVariables( T_AFFAIRE *pbd_Aff, /* adresse de la variable intermediaire Liste des affaires */
	T_ULTIME *pbd_Ult, 	/* adresse de la variable intermediaire Primes et sinistres ultimes */
	T_PCSAMT *pbd_Pcs,	/* adresse de la variable intermediaire Montants prime, charge et sinistre */
	T_LIGNEREC *pbd_Rec, 	/* adresse de la variable intermediaire Tableau de reconstitution */ 
	T_ULTIME *pbd_UltOut, 	/* adresse de la variable de sortie Primes et sinistres ultimes */
	T_SOUS *pbd_Uw, /* adresse de la variable de sortie Souscription */
	T_STATS *pbd_CplAmt, 	/* adresse de la variable de sortie Montants Stats */
	T_AGENDA *pbd_Rmd )  	/* adresse de la variable de sortie Agenda */

{
	DEBUT_FCT( "n_InitVariables" ) ;

	memset( pbd_Aff, 0, sizeof( T_AFFAIRE ) ) ;
	memset( pbd_Ult, 0, sizeof( T_ULTIME ) )  ;
	memset( pbd_Pcs, 0, sizeof( T_PCSAMT ) ) ;
	memset( pbd_Rec, 0, ( NB_REC_MAX * sizeof( T_LIGNEREC ) ) ) ;
	memset( pbd_UltOut, 0, sizeof( T_ULTIME ) ) ;
	memset( pbd_Uw, 0, sizeof( T_SOUS ) ) ;
	memset( pbd_CplAmt, 0, sizeof( T_STATS ) ) ;
	memset( pbd_Rmd, 0, sizeof( T_AGENDA ) ) ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction de copie des rubriques du fichier Liste des affaires vers une 
variable intermediaire

retour :	0

==============================================================================*/
int n_CopyAff( char **ptb_InRecOwner, /* adresse de la ligne courante du fichier Liste des Affaires */
	T_AFFAIRE *pbd_Aff ) /* adresse de la variable intermediaire Liste des affaires */
{
	DEBUT_FCT( "n_CopyAff" ) ;

	strcpy( pbd_Aff->CTR_NF, ptb_InRecOwner[AFF_CTR_NF] ) ;
	pbd_Aff->UWY_NF = atoi( ptb_InRecOwner[AFF_UWY_NF] ) ;
	pbd_Aff->UW_NT = (char)( atoi( ptb_InRecOwner[AFF_UW_NT] ) ) ;
	pbd_Aff->END_NT = (char)( atoi( ptb_InRecOwner[AFF_END_NT] ) ) ;
	pbd_Aff->SEC_NF = (char)( atoi( ptb_InRecOwner[AFF_SEC_NF] ) ) ;
	pbd_Aff->DIV_NT = (char)( atoi( ptb_InRecOwner[AFF_DIV_NT] ) ) ;
	strcpy( pbd_Aff->UWRSPUSR_CF, ptb_InRecOwner[AFF_UWRSPUSR_CF] ) ;
	strcpy( pbd_Aff->ADMUSR_CF, ptb_InRecOwner[AFF_ADMUSR_CF] ) ;
	strcpy( pbd_Aff->SECLAB_LM, ptb_InRecOwner[AFF_SECLAB_LM] ) ;
	pbd_Aff->SSD_CF = (char)( atoi( ptb_InRecOwner[AFF_SSD_CF] ) ) ;
	pbd_Aff->SECACCSTS_CT = (char)( atoi( ptb_InRecOwner[AFF_SECACCSTS_CT] ) ) ;
	pbd_Aff->ESTEND_B = (char)( atoi( ptb_InRecOwner[AFF_ESTEND_B] ) ) ;
	pbd_Aff->EVTCOD_NF = (char)( atoi( ptb_InRecOwner[AFF_EVTCOD_NF] ) ) ;
	pbd_Aff->CTRNAT_CT = *ptb_InRecOwner[AFF_CTRNAT_CT] ;
	pbd_Aff->ESTUPDTYP_CT = *ptb_InRecOwner[AFF_ESTUPDTYP_CT] ;
	strcpy( pbd_Aff->LOB_CF, ptb_InRecOwner[AFF_LOB_CF] ) ;
	strcpy( pbd_Aff->SOB_CF, ptb_InRecOwner[AFF_SOB_CF] ) ;
	strcpy( pbd_Aff->PCPRSKTRY_CF, ptb_InRecOwner[AFF_PCPRSKTRY_CF] ) ;
	pbd_Aff->ACCADMTYP_CT= (char)( atoi( ptb_InRecOwner[AFF_ACCADMTYP_CT] ) ) ;
	pbd_Aff->SCOORGEGP_M= atof( ptb_InRecOwner[AFF_SCOORGEGP_M] ) ;
	pbd_Aff->SCOGLOEGP_M= atof( ptb_InRecOwner[AFF_SCOGLOEGP_M] ) ;
	strcpy( pbd_Aff->EGPCUR_CF, ptb_InRecOwner[AFF_EGPCUR_CF] ) ;
	pbd_Aff->PMLRAT_R= atof( ptb_InRecOwner[AFF_PMLRAT_R] ) ;
	pbd_Aff->CUTSHA_R= atof( ptb_InRecOwner[AFF_CUTSHA_R] ) ;
	pbd_Aff->RIDSHA_R= atof( ptb_InRecOwner[AFF_RIDSHA_R] ) ;
	pbd_Aff->LIARIDSHA_B= (char)( atoi( ptb_InRecOwner[AFF_LIARIDSHA_B] ) ) ;
	pbd_Aff->SCOEGPCAL_B= (char)( atoi( ptb_InRecOwner[AFF_SCOEGPCAL_B] ) ) ;
	pbd_Aff->EGPLESSCO_M= atof( ptb_InRecOwner[AFF_EGPLESSCO_M] ) ;
	pbd_Aff->PRMFLCRAT_B= (char)( atoi( ptb_InRecOwner[AFF_PRMFLCRAT_B] ) ) ;
	pbd_Aff->PRMFIXEFF_R= atof( ptb_InRecOwner[AFF_PRMFIXEFF_R] ) ;
	pbd_Aff->PRMMINEFF_R= atof( ptb_InRecOwner[AFF_PRMMINEFF_R] ) ;
	pbd_Aff->PRMMAXEFF_R= atof( ptb_InRecOwner[AFF_PRMMAXEFF_R] ) ;
	pbd_Aff->SUPLOATYP_CT= (char)( atoi( ptb_InRecOwner[AFF_SUPLOATYP_CT] ) ) ;
	pbd_Aff->PRMEFFLOA_M= atof( ptb_InRecOwner[AFF_PRMEFFLOA_M] ) ;
	pbd_Aff->PRMEFFLOA_R= atof( ptb_InRecOwner[AFF_PRMEFFLOA_R] ) ;
	strcpy( pbd_Aff->SBJPRMCUR_CF, ptb_InRecOwner[AFF_SBJPRMCUR_CF] ) ;
	pbd_Aff->ESTSBJPRM_M= atof( ptb_InRecOwner[AFF_ESTSBJPRM_M] ) ;
	pbd_Aff->DEFSBJPRM_M= atof( ptb_InRecOwner[AFF_DEFSBJPRM_M] ) ;
	pbd_Aff->SBJPRMCPT_M= atof( ptb_InRecOwner[AFF_SBJPRMCPT_M] ) ;
	pbd_Aff->REIEXI_B= (char)( atoi( ptb_InRecOwner[AFF_REIEXI_B] ) ) ;
	pbd_Aff->REIUNL_B= (char)( atoi( ptb_InRecOwner[AFF_REIUNL_B] ) ) ;
	pbd_Aff->REIFRE_B= (char)( atoi( ptb_InRecOwner[AFF_REIFRE_B] ) ) ;
	pbd_Aff->REINBR_N= (char)( atoi( ptb_InRecOwner[AFF_REINBR_N] ) ) ;
	pbd_Aff->LAYCAP_M= atof( ptb_InRecOwner[AFF_LAYCAP_M] ) ;
	pbd_Aff->FLAPRM_B= (char)( atoi( ptb_InRecOwner[AFF_FLAPRM_B] ) ) ;
	pbd_Aff->SBJCPTDEF_B= (char)( atoi( ptb_InRecOwner[AFF_SBJCPTDEF_B] ) ) ;
	pbd_Aff->PMDEGPCUR_M= atof( ptb_InRecOwner[AFF_PMDEGPCUR_M] ) ;
	pbd_Aff->CPLACCY_NF= atoi( ptb_InRecOwner[AFF_CPLACCY_NF] ) ;
	pbd_Aff->SCOLSTMTH_NF= (char)( atoi( ptb_InRecOwner[AFF_SCOLSTMTH_NF] ) ) ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction de copie des rubriques du fichier Primes et sinistres ultimes
 vers une variable intermediaire

retour :	0

==============================================================================*/
int n_CopyUlt( char **ptb_InRecChild, /* adresse de la ligne courante du fichier Primes et sinistres ultimes */
	T_ULTIME *pbd_Ult ) /* adresse de la variable intermediaire Primes et sinistres ultimes */
{
	DEBUT_FCT( "n_CopyUlt" ) ;

	strcpy( pbd_Ult->CTR_NF, ptb_InRecChild[ULT_CTR_NF] ) ;
	pbd_Ult->UWY_NF = atoi( ptb_InRecChild[ULT_UWY_NF] ) ;
	pbd_Ult->UW_NT = (char)( atoi( ptb_InRecChild[ULT_UW_NT] ) ) ;
	pbd_Ult->END_NT = (char)( atoi( ptb_InRecChild[ULT_END_NT] ) ) ;
	pbd_Ult->SEC_NF = (char)( atoi( ptb_InRecChild[ULT_SEC_NF] ) ) ;
	strcpy( pbd_Ult->CRE_D, ptb_InRecChild[ULT_CRE_D] ) ;
	pbd_Ult->SSD_CF = (char)( atoi( ptb_InRecChild[ULT_SSD_CF] ) ) ;
	pbd_Ult->DIV_NT = (char)( atoi( ptb_InRecChild[ULT_DIV_NT] ) ) ;
	strcpy( pbd_Ult->CUR_CF, ptb_InRecChild[ULT_CUR_CF] ) ;
	pbd_Ult->CALAMTPRM_M = atof( ptb_InRecChild[ULT_CALAMTPRM_M] ) ;
	pbd_Ult->ENTAMTPRM_M = atof( ptb_InRecChild[ULT_ENTAMTPRM_M] ) ;
	pbd_Ult->RETAMTPRM_M = atof( ptb_InRecChild[ULT_RETAMTPRM_M] ) ;
	pbd_Ult->ADMMODPRM_CT = *ptb_InRecChild[ULT_ADMMODPRM_CT] ;
	pbd_Ult->RESPRM_M = atof( ptb_InRecChild[ULT_RESPRM_M] ) ;
	pbd_Ult->CALAMTCLM_M = atof( ptb_InRecChild[ULT_CALAMTCLM_M] ) ;
	pbd_Ult->ENTAMTCLM_M = atof( ptb_InRecChild[ULT_ENTAMTCLM_M] ) ;
	pbd_Ult->RETAMTCLM_M = atof( ptb_InRecChild[ULT_RETAMTCLM_M] ) ;
	pbd_Ult->ADMMODCLM_CT = *ptb_InRecChild[ULT_ADMMODCLM_CT] ;
	strcpy( pbd_Ult->ORICOD_LS, ptb_InRecChild[ULT_ORICOD_LS] ) ;
	strcpy( pbd_Ult->UPDUSR_CF, ptb_InRecChild[ULT_UPDUSR_CF] ) ;
	pbd_Ult->ULTUPDTYP_CF = *ptb_InRecChild[ULT_ULTUPDTYP_CF] ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction de copie des rubriques du fichier Mouvement comptable
 vers une variable intermediaire

retour :	0
	
==============================================================================*/
int n_CopyPcs( char **ptb_InRecChild, /* adresse de la ligne courante du fichier Mouvements comptables */ 
	T_PCSAMT *pbd_Pcs ) /* adresse de la variable intermediaire Montants prime, charge et sinistre */
{
	DEBUT_FCT( "n_CopyPcs" ) ;

	/* copie des montants de primes pour les postes cumules 10000, -10000, -12000, -13000, 10050 et -10050 */
	if ( strcmp( ptb_InRecChild[MVT_ACMTRS_NT], "10000" ) == 0 )
	{
		pbd_Pcs->PRMAMT_M[POSTCUM_10000] = atof( ptb_InRecChild[ MVT_EGPCUR_M ] ) ;
		return( 0 ) ;
	}
	if ( strcmp( ptb_InRecChild[MVT_ACMTRS_NT], "-10000" ) == 0 )
	{
		pbd_Pcs->PRMAMT_M[POSTCUM_10000c] = atof( ptb_InRecChild[ MVT_EGPCUR_M ] ) ;
		return( 0 ) ;
	}
	if ( strcmp( ptb_InRecChild[MVT_ACMTRS_NT], "-12000" ) == 0 )
	{
		pbd_Pcs->PRMAMT_M[POSTCUM_12000c] = atof( ptb_InRecChild[ MVT_EGPCUR_M ] ) ;
		return( 0 ) ;
	}
	if ( strcmp( ptb_InRecChild[MVT_ACMTRS_NT], "-13000" ) == 0 )
	{
		pbd_Pcs->PRMAMT_M[POSTCUM_13000c] = atof( ptb_InRecChild[ MVT_EGPCUR_M ] ) ;
		return( 0 ) ;
	}
	if ( strcmp( ptb_InRecChild[MVT_ACMTRS_NT], "10050" ) == 0 )
	{
		pbd_Pcs->PRMAMT_M[POSTCUM_10050] = atof( ptb_InRecChild[ MVT_EGPCUR_M ] ) ;
		return( 0 ) ;
	}
	if ( strcmp( ptb_InRecChild[MVT_ACMTRS_NT], "-10050" ) == 0 )
	{
		pbd_Pcs->PRMAMT_M[POSTCUM_10050c] = atof( ptb_InRecChild[ MVT_EGPCUR_M ] ) ;
		return( 0 ) ;
	}


	/* copie des montants de charges pour les postes cumules 10100 et -10100 */
	if ( strcmp( ptb_InRecChild[MVT_ACMTRS_NT], "10100" ) == 0 )
	{
		pbd_Pcs->CHAAMT_M[POSTCUM_10100] = atof( ptb_InRecChild[ MVT_EGPCUR_M ] ) ;
		return( 0 ) ;
	}
	if ( strcmp( ptb_InRecChild[MVT_ACMTRS_NT], "-10100" ) == 0 )
	{
		pbd_Pcs->CHAAMT_M[POSTCUM_10100c] = atof( ptb_InRecChild[ MVT_EGPCUR_M ] ) ;
		return( 0 ) ;
	}

	/* copie des montants de sinistres pour les postes cumules 20000, -20000, 20050 et -20050 */
	if ( strcmp( ptb_InRecChild[MVT_ACMTRS_NT], "20000" ) == 0 )
	{
		pbd_Pcs->CLMAMT_M[POSTCUM_20000] = atof( ptb_InRecChild[ MVT_EGPCUR_M ] ) ;
		return( 0 ) ;
	}
	if ( strcmp( ptb_InRecChild[MVT_ACMTRS_NT], "-20000" ) == 0 )
	{
		pbd_Pcs->CLMAMT_M[POSTCUM_20000c] = atof( ptb_InRecChild[ MVT_EGPCUR_M ] ) ;
		return( 0 ) ;
	}
	if ( strcmp( ptb_InRecChild[MVT_ACMTRS_NT], "20050" ) == 0 )
	{
		pbd_Pcs->CLMAMT_M[POSTCUM_20050] = atof( ptb_InRecChild[ MVT_EGPCUR_M ] ) ;
		return( 0 ) ;
	}
	if ( strcmp( ptb_InRecChild[MVT_ACMTRS_NT], "-20050" ) == 0 )
	{
		pbd_Pcs->CLMAMT_M[POSTCUM_20050c] = atof( ptb_InRecChild[ MVT_EGPCUR_M ] ) ;
		return( 0 ) ;
	}


	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction de copie des rubriques du fichier Parametres de 
 reconstitution vers une variable

retour :	0
	
==============================================================================*/
int n_CopyRec( char **ptb_InRecChild, /* adresse de la ligne courante du fichier des parametres de reconstitution */
	T_LIGNEREC *pbd_Rec ) /* adresse de la variable intermediaire Tableau de reconstitution */
{
	DEBUT_FCT( "n_CopyRec" ) ;

	pbd_Rec->REIRNK_N = (char)( atoi( ptb_InRecChild[REC_REIRNK_N] ) ) ;
	pbd_Rec->REIPRMBAS_R = atof( ptb_InRecChild[REC_REIPRMBAS_R] ) ;
	pbd_Rec->REIPRM_M = atof( ptb_InRecChild[REC_REIPRM_M] ) ;
	pbd_Rec->REIPRM_R = atof( ptb_InRecChild[REC_REIPRM_R] ) ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction de mise a jour des variables de sortie des fichiers Primes et sinistres
ultimes, et Souscription apres application des regles de gestion

retour :	0
	
==============================================================================*/

int n_UpdateUltUw( 
	T_AFFAIRE *pbd_Aff, /* adresse de la variable intermediaire Liste des affaires */
	T_ULTIME *pbd_Ult, /* adresse de la variable intermediaire Primes et sinistres ultimes */
	T_PCSAMT *pbd_Pcs, /* adresse de la variable intermediaire Montants prime, charge et sinistre */
	T_LIGNEREC *pbd_Rec, /* adresse de la variable intermediaire Tableau de reconstitution */ 
	T_AUTPAR *pbd_AutPar, /* adresse du tableau de parametrage des automatismes */
	short	n_NbPoste, /* nombre de poste du tableau de parametrage des automatismes */
	T_ULTIME *pbd_UltOut, /* adresse de la variable de sortie Primes et sinistres ultimes */
	T_SOUS *pbd_Uw ) /* adresse de la variable de sortie Souscription */
{
	double		d_RT0_ParRat ; /* taux de parametrage positionne par la regle de transition 0 (RT0) */
	unsigned char	c_RT0_NbrTri ; /* nombre de trimestres positionne par RT0 */

	char			c_RT1P_AdmMod ; /* mode de gestion positionne par RT1 (type de traitement P) */
	char			c_RT1S_AdmMod ; /* mode de gestion positionne par RT1 (type de traitement S) */
	char			sz_RT1_CtrOldCat[8] ; /* categorie d'age positionne par RT1 */
	unsigned char 	c_RT1_EstEnd ; /* top estimations terminees positionne par RT1 */
	char			c_RT2P_AdmMod ; /* mode de gestion positionne par RT2 (type de traitement P) */
	char			c_RT3P_AdmMod ; /* mode de gestion positionne par RT3 (type de traitement P) */
	char			c_RT3S_AdmMod ; /* mode de gestion positionne par RT3 (type de traitement S) */

	double 		d_RC1_RetAmtPrm ; /* montant retenu de prime ultime positionne par RC1 */
	double 		d_RC2_RetAmtClm ; /* montant retenu de sinistre ultime positionne par RC2 */
	double 		d_RC3_RetAmtPrm ; /* montant retenu de prime ultime positionne par RC3 */
	double 		d_RC5_RetAmtPrm ; /* montant retenu de prime ultime positionne par RC5 */

	double 		d_FC1_GroTotEgp ; /* aliment 100% brut SCOR calcule positionne par FC1 */
	double 		d_FC2_GroTotEgp ; /* aliment 100% brut SCOR calcule positionne par FC2 */
	double		d_FC2_GroEgp ; /* aliment brut SCOR positionne par FC2 */
	double		d_FC3_BurCosPrm ; /* prime de burning cost positionnee par FC3 */
	double 		d_FC4_RecPrm ; /* prime de reconstitution positionne par FC4 */
	double		d_FC34_SbjPrm ; /* assiette de prime utilisee par FC3 et FC4 */

	double		d_RatioStat ;	/* ratio compte complet */
	double		d_CalAmtClm ;	/* sinistralite proposee ramenee au ratio comte complet */
	char		sz_CalAmtClm[20] ; /* zone de travail */
	double		d_RetAmtClm ;	/* sinistralite retenue */
	
	char			sz_HeureSyst[9] ; /* heure systeme */
	char			sz_Space[2] = " " ; /* espace necessaire au formatage de la date-heure */
	

	DEBUT_FCT( "n_UpdateUltUw" ) ;

	/* ------------------------ */
	/* appel de la fonction RT0 */
	/* ------------------------ */
	d_RT0_ParRat = d_ExtractionParamAuto( pbd_Aff->CTRNAT_CT, pbd_Aff->FLAPRM_B, pbd_Aff->LOB_CF,
		pbd_Aff->SOB_CF, pbd_Aff->PCPRSKTRY_CF, pbd_Aff->ACCADMTYP_CT, pbd_Aff->SSD_CF,
		pbd_AutPar, n_NbPoste, &c_RT0_NbrTri ) ;

	/* initialisation de l'enregistrement des ultimes */
	*pbd_UltOut = *pbd_Ult ;


	/* ---------------------- */
	/* TRAITES PROPORTIONNELS */
	/* ---------------------- */

	if ( pbd_Aff->CTRNAT_CT == 'P' )
	{
		/* ------------------------------------------------- */
		/* appel de la fonction RT1 (type de traitement P )" */
		/* ------------------------------------------------- */	
		c_RT1P_AdmMod = c_TransitionTraitProp( pbd_Aff->UWY_NF, pbd_Aff->ACCADMTYP_CT, d_RT0_ParRat,
			c_RT0_NbrTri, ( pbd_Pcs->PRMAMT_M[POSTCUM_10000] + pbd_Pcs->PRMAMT_M[POSTCUM_10000c] ), 
			pbd_UltOut->ENTAMTPRM_M, pbd_Aff->SCOORGEGP_M, 'P', pbd_Ult->ADMMODPRM_CT, 
			pbd_Aff->CPLACCY_NF, pbd_Aff->SCOLSTMTH_NF, &c_RT1_EstEnd, sz_RT1_CtrOldCat ) ;

		/* calcul du ratio compte complet */
			d_RatioStat = ( ( pbd_Pcs->PRMAMT_M[POSTCUM_10000c] + pbd_Pcs->PRMAMT_M[POSTCUM_10050c] ) == 0 ? 0 : ( ( pbd_Pcs->CLMAMT_M[POSTCUM_20000c] + pbd_Pcs->CLMAMT_M[POSTCUM_20050c] ) / ( pbd_Pcs->PRMAMT_M[POSTCUM_10000c] + pbd_Pcs->PRMAMT_M[POSTCUM_10050c] ) ) ) ;

		if ( pbd_Aff->ESTUPDTYP_CT == 'U' && c_RT1P_AdmMod == 'M' )
		{
			/* calcul de la sinistralite retenue par rapport a la prime retenue ( application du ratio stat ) */
			d_CalAmtClm = d_RatioStat * pbd_UltOut->RETAMTPRM_M ;

			/* affectation de la variable de sortie Primes et sinistres ultimes */ 
			pbd_UltOut->CALAMTPRM_M = pbd_Pcs->PRMAMT_M[POSTCUM_10000] + pbd_Pcs->PRMAMT_M[POSTCUM_10000c] ;
			pbd_UltOut->CALAMTCLM_M = d_CalAmtClm ;
			pbd_UltOut->ULTUPDTYP_CF = 'U' ;	
		}
		else
		{
		/* ------------------------------------------------- */
		/* appel de la fonction RT1 (type de traitement S )" */
		/* ------------------------------------------------- */	
			c_RT1S_AdmMod = c_TransitionTraitProp( pbd_Aff->UWY_NF, pbd_Aff->ACCADMTYP_CT, d_RT0_ParRat,
				c_RT0_NbrTri, ( pbd_Pcs->PRMAMT_M[POSTCUM_10000] + pbd_Pcs->PRMAMT_M[POSTCUM_10000c] ),
				pbd_UltOut->ENTAMTPRM_M, pbd_Aff->SCOORGEGP_M, 'S', pbd_Ult->ADMMODCLM_CT, 
				pbd_Aff->CPLACCY_NF, pbd_Aff->SCOLSTMTH_NF, &c_RT1_EstEnd, sz_RT1_CtrOldCat ) ;

			/*------------------------- */
			/* appel de la fonction RC1 */
			/* ------------------------ */
			d_RC1_RetAmtPrm = d_RegleChoixPrimeTraitProp( c_RT1P_AdmMod, 
			( pbd_Pcs->PRMAMT_M[POSTCUM_10000] + pbd_Pcs->PRMAMT_M[POSTCUM_10000c] ), pbd_UltOut->ENTAMTPRM_M ) ;

			/* calcul de la sinistralite retenue par rapport a la prime retenue ( application du ratio stat ) */
			sprintf( sz_CalAmtClm, "%-.3f", d_RatioStat * d_RC1_RetAmtPrm ) ;
			d_CalAmtClm = atof( sz_CalAmtClm ) ;
		
			/* ------------------------ */
			/* appel de la fonction RC2 */
			/* ------------------------ */
			d_RC2_RetAmtClm = d_RegleChoixSinistreTraitProp( c_RT1S_AdmMod, 
				( ( pbd_UltOut->ENTAMTPRM_M == 0 ) ? 0 : ( -1 * pbd_UltOut->ENTAMTCLM_M / pbd_UltOut->ENTAMTPRM_M ) ),
				( (  d_RC1_RetAmtPrm  == 0 ) ? 0 : ( -1 * d_CalAmtClm /  d_RC1_RetAmtPrm  ) ),
				d_RC1_RetAmtPrm  ) ;

			/* ------------------------ */
			/* appel de la fonction FC1 */
			/* ------------------------ */
			d_FC1_GroTotEgp = d_CalculAliment100TraitProp( d_RC1_RetAmtPrm, pbd_Aff->CUTSHA_R, 
				pbd_Aff->RIDSHA_R, pbd_Aff->LIARIDSHA_B ) ;

			/* modification et formatage de la date de creation */
			RecSysDate( pbd_UltOut->CRE_D, sz_HeureSyst ) ;
			FormatTime( sz_HeureSyst, sz_HeureSyst ) ;
			strcat( pbd_UltOut->CRE_D, sz_Space ) ;
			strcat( pbd_UltOut->CRE_D, sz_HeureSyst ) ;

			/* affectation de la variable de sortie Primes et sinistres ultimes */	
			pbd_UltOut->CALAMTPRM_M = pbd_Pcs->PRMAMT_M[POSTCUM_10000] + pbd_Pcs->PRMAMT_M[POSTCUM_10000c] ;
			pbd_UltOut->RETAMTPRM_M = d_RC1_RetAmtPrm ;
			pbd_UltOut->ADMMODPRM_CT = c_RT1P_AdmMod ;
			pbd_UltOut->CALAMTCLM_M = d_CalAmtClm ;
			pbd_UltOut->RETAMTCLM_M = d_RC2_RetAmtClm ;
			pbd_UltOut->ADMMODCLM_CT = c_RT1S_AdmMod ;
			strcpy( pbd_UltOut->ORICOD_LS, "Account" ) ;
			strcpy( pbd_UltOut->UPDUSR_CF, "ESTJ3210" ) ;
			pbd_UltOut->ULTUPDTYP_CF = 'I' ;

			/* affectation de la variable de sortie Souscription */	
			strcpy( pbd_Uw->CTR_NF, pbd_Aff->CTR_NF ) ;
			pbd_Uw->UWY_NF = pbd_Aff->UWY_NF ;
			pbd_Uw->UW_NT = pbd_Aff->UW_NT ;
			pbd_Uw->END_NT = pbd_Aff->END_NT ;
			pbd_Uw->SEC_NF = pbd_Aff->SEC_NF ;
			pbd_Uw->CTRNAT_CT = pbd_Aff->CTRNAT_CT;
			pbd_Uw->ADMMODCTR_CT = c_RT1P_AdmMod ;
			pbd_Uw->ESTEND_B = c_RT1_EstEnd ;
			pbd_Uw->ESTUPDTYP_CT = 'I' ;
			pbd_Uw->SCOGLOEGP_M = d_RC1_RetAmtPrm ;
			pbd_Uw->PMLRAT_R = ( d_RC1_RetAmtPrm == 0 ? 0 : ( -1 * d_RC2_RetAmtClm / d_RC1_RetAmtPrm ) ) ;

			if ( c_RT1P_AdmMod == 'A' )
			{
				pbd_Uw->TOTCLM_M = d_FC1_GroTotEgp ;
				pbd_Uw->SCOEGPCAL_B = 1 ;
			}
			else
			{
				pbd_Uw->TOTCLM_M = pbd_Aff->EGPLESSCO_M ;
				pbd_Uw->SCOEGPCAL_B = pbd_Aff->SCOEGPCAL_B ;
 			}
		}
			
		/* si la condition n'est pas verifiee pas de mise a jour */
		if ( pbd_UltOut->CALAMTPRM_M != pbd_Ult->CALAMTPRM_M ||
			pbd_UltOut->ENTAMTPRM_M != pbd_Ult->ENTAMTPRM_M ||
			pbd_UltOut->RETAMTPRM_M != pbd_Ult->RETAMTPRM_M ||
			pbd_UltOut->ADMMODPRM_CT != pbd_Ult->ADMMODPRM_CT ||
			pbd_UltOut->CALAMTCLM_M != pbd_Ult->CALAMTCLM_M ||
			pbd_UltOut->ENTAMTCLM_M != pbd_Ult->ENTAMTCLM_M ||
			pbd_UltOut->RETAMTCLM_M != pbd_Ult->RETAMTCLM_M ||
			pbd_UltOut->ADMMODCLM_CT != pbd_Ult->ADMMODCLM_CT )
		{
			n_WriteUlt( Kp_OutputFilUlt, pbd_UltOut ) ;
			if ( pbd_UltOut->ULTUPDTYP_CF == 'I' )
				n_WriteUw( Kp_OutputFilUw, pbd_Uw ) ;
		}	
	}

	/* ------------------------------------------------------- */
	/* TRAITES NON PROPORTIONNELS TARIFICATION NON FORFAITAIRE */
	/* ------------------------------------------------------- */

	if ( pbd_Aff->CTRNAT_CT == 'N' && pbd_Aff->FLAPRM_B == 0 )
	{
		/* ----------------------------------------------- */
		/* appel de la fonction RT2 (type de traitement P) */
		/* ----------------------------------------------- */
		c_RT2P_AdmMod = c_TransitionTraitNonProp( d_RT0_ParRat, pbd_Pcs->PRMAMT_M[POSTCUM_10000c], pbd_UltOut->ENTAMTPRM_M,
			pbd_Aff->SCOORGEGP_M, pbd_Aff->FLAPRM_B, pbd_Aff->SBJCPTDEF_B, 'P', pbd_Ult->ADMMODPRM_CT ) ;
		
		if ( pbd_Aff->ESTUPDTYP_CT == 'U' && c_RT2P_AdmMod == 'M' )
		{
			/* "pas de mise a jour de la prime ultime" */ ;
		}
		else
		{
			if ( c_RT2P_AdmMod == 'A' )
			{
			/*	pbd_UltOut->ENTAMTPRM_M = pbd_Ult->ENTAMTPRM_M ; */
				d_FC34_SbjPrm = pbd_Aff->SBJPRMCPT_M ;
			}
			else
			{
			/*	pbd_UltOut->ENTAMTPRM_M = pbd_Aff->SCOGLOEGP_M ; */
				d_FC34_SbjPrm = ( pbd_Aff->DEFSBJPRM_M == 0 ? pbd_Aff->ESTSBJPRM_M : pbd_Aff->DEFSBJPRM_M ) ;
			}

			/* ------------ */
			/* appel de FC2 */
			/* ------------ */
			d_FC2_GroTotEgp = d_CalculAlimentAssietteTraitNonProp( 0,
				pbd_Aff->CUTSHA_R, pbd_Aff->RIDSHA_R, pbd_Aff->LIARIDSHA_B, pbd_Aff->PRMFLCRAT_B,
				pbd_Aff->PRMFIXEFF_R, pbd_Aff->PRMMINEFF_R, pbd_Aff->PRMMAXEFF_R,
				pbd_Aff->FLAPRM_B, pbd_Aff->SBJPRMCPT_M, &d_FC2_GroEgp ) ;

			/* ------------ */
			/* appel de RC3 */
			/* ------------ */
			d_RC3_RetAmtPrm = d_RegleChoixPrimeTraitNonProp( c_RT2P_AdmMod, d_FC2_GroEgp,
				pbd_UltOut->ENTAMTPRM_M, pbd_Aff->PMDEGPCUR_M, pbd_Aff->CUTSHA_R, 
				pbd_Aff->RIDSHA_R, pbd_Aff->LIARIDSHA_B ) ;

			/* ------------------------ */
			/* appel de la fonction FC1 */
			/* ------------------------ */
			d_FC1_GroTotEgp = d_CalculAliment100TraitProp( d_RC3_RetAmtPrm , pbd_Aff->CUTSHA_R, 
				pbd_Aff->RIDSHA_R, pbd_Aff->LIARIDSHA_B ) ;

			/* --------------------------------- */
			/* Calcul de la sinistralite retenue */
			/* --------------------------------- */
			/* Principe : si le mode de gestion sinistre = M ou F alors conservation du S/P initial
			d'où recalcul de la sinistralite sinon conservation de la sinistralite initiale */
			if ( pbd_Ult->ADMMODCLM_CT == 'M' || pbd_Ult->ADMMODCLM_CT == 'F' )
				d_RetAmtClm = ( pbd_Ult->RETAMTPRM_M == 0 ? 0 : ( d_RC3_RetAmtPrm * pbd_Ult->RETAMTCLM_M / pbd_Ult->RETAMTPRM_M ) ) ;				
			else	d_RetAmtClm = pbd_Ult->RETAMTCLM_M ;

			if ( pbd_Aff->PRMFLCRAT_B == 1 )
			{
				/* ------------ */
				/* appel de FC3 */
				/* ------------ */
				d_FC3_BurCosPrm = d_CalculBurningCost( pbd_Aff->SUPLOATYP_CT, d_FC34_SbjPrm,
					d_RetAmtClm, pbd_Aff->PRMMINEFF_R, pbd_Aff->PRMMAXEFF_R,
					pbd_Aff->PRMEFFLOA_M, pbd_Aff->PRMEFFLOA_R, pbd_Aff->CUTSHA_R,
					pbd_Aff->RIDSHA_R, pbd_Aff->LIARIDSHA_B ) ;
			}
			else
			{
				/* ------------ */
				/* appel de FC4 */
				/* ------------ */
				d_FC4_RecPrm = d_CalculPrimeReconstitution( pbd_Aff->REIEXI_B, 
					pbd_Aff->REIUNL_B, pbd_Aff->REIFRE_B, pbd_Aff->REINBR_N,
					d_FC34_SbjPrm, d_RetAmtClm, d_RC3_RetAmtPrm, pbd_Aff->LAYCAP_M,
					pbd_Aff->CUTSHA_R, pbd_Aff->RIDSHA_R, pbd_Aff->LIARIDSHA_B,	pbd_Rec ) ;
			}

			/* modification et formatage de la date de creation */
			RecSysDate( pbd_UltOut->CRE_D, sz_HeureSyst ) ;
			FormatTime( sz_HeureSyst, sz_HeureSyst ) ;
			strcat( pbd_UltOut->CRE_D, sz_Space ) ;
			strcat( pbd_UltOut->CRE_D, sz_HeureSyst ) ;
			
			/* affectation de la variable de sortie Primes et sinistres ultimes */	
			pbd_UltOut->CALAMTPRM_M = d_FC2_GroEgp ;
			pbd_UltOut->RETAMTPRM_M = d_RC3_RetAmtPrm ;
			pbd_UltOut->RETAMTCLM_M = d_RetAmtClm ;
			pbd_UltOut->ADMMODPRM_CT = c_RT2P_AdmMod ;
			pbd_UltOut->RESPRM_M = d_FC3_BurCosPrm + d_FC4_RecPrm ;
			strcpy( pbd_UltOut->ORICOD_LS, "Account" ) ;
			strcpy( pbd_UltOut->UPDUSR_CF, "ESEJ1000" ) ;
			pbd_UltOut->ULTUPDTYP_CF = 'I' ;


			/* affectation de la variable de sortie Souscription */	
			strcpy( pbd_Uw->CTR_NF, pbd_Aff->CTR_NF ) ;
			pbd_Uw->UWY_NF = pbd_Aff->UWY_NF ;
			pbd_Uw->UW_NT = pbd_Aff->UW_NT ;
			pbd_Uw->END_NT = pbd_Aff->END_NT ;
			pbd_Uw->SEC_NF = pbd_Aff->SEC_NF ;
			pbd_Uw->CTRNAT_CT = pbd_Aff->CTRNAT_CT;
			pbd_Uw->ADMMODCTR_CT = c_RT2P_AdmMod ;
			pbd_Uw->ESTUPDTYP_CT = 'I' ;
			pbd_Uw->SCOGLOEGP_M = d_RC3_RetAmtPrm ;
			pbd_Uw->PMLRAT_R = ( ( d_RC3_RetAmtPrm == 0 ) ? 0 : ( -1 * pbd_UltOut->RETAMTCLM_M / d_RC3_RetAmtPrm ) ) ;
			pbd_Uw->ESTEND_B = 0 ;

			if ( c_RT2P_AdmMod == 'A' )
			{
				pbd_Uw->TOTCLM_M = d_FC1_GroTotEgp ;
				pbd_Uw->SCOEGPCAL_B = 1 ;
			}
			else
			{
				pbd_Uw->TOTCLM_M = pbd_Aff->EGPLESSCO_M ;
				pbd_Uw->SCOEGPCAL_B = pbd_Aff->SCOEGPCAL_B ;	
			}
		}

		/* si la condition n'est pas verifiee pas de mise a jour */
		if ( pbd_UltOut->CALAMTPRM_M != pbd_Ult->CALAMTPRM_M ||
			pbd_UltOut->ENTAMTPRM_M != pbd_Ult->ENTAMTPRM_M ||
			pbd_UltOut->RETAMTPRM_M != pbd_Ult->RETAMTPRM_M ||
			pbd_UltOut->ADMMODPRM_CT != pbd_Ult->ADMMODPRM_CT ||
			pbd_UltOut->RESPRM_M != pbd_Ult->RESPRM_M )
		{
			n_WriteUlt( Kp_OutputFilUlt, pbd_UltOut ) ;
			if ( pbd_UltOut->ULTUPDTYP_CF == 'I' )
				n_WriteUw( Kp_OutputFilUw, pbd_Uw ) ;
		}
	}

	/* --------------------------------------------------- */
	/* TRAITES NON PROPORTIONNELS TARIFICATION FORFAITAIRE */
	/* --------------------------------------------------- */

	if ( pbd_Aff->CTRNAT_CT == 'N' && pbd_Aff->FLAPRM_B == 1 )
	{
		/* ----------------------------------------------- */
		/* appel de la fonction RT2 (type de traitement P) */
		/* ----------------------------------------------- */
		c_RT2P_AdmMod = c_TransitionTraitNonProp( d_RT0_ParRat, pbd_Pcs->PRMAMT_M[POSTCUM_10000c], pbd_UltOut->ENTAMTPRM_M,
			pbd_Aff->SCOORGEGP_M, pbd_Aff->FLAPRM_B, pbd_Aff->SBJCPTDEF_B, 'P', pbd_Ult->ADMMODPRM_CT ) ;
	
		if ( pbd_Aff->ESTUPDTYP_CT == 'U' && c_RT2P_AdmMod == 'M' )
		{
			/* affectation de la variable de sortie Primes et sinistres ultimes */ 
			pbd_UltOut->CALAMTPRM_M = pbd_Pcs->PRMAMT_M[POSTCUM_10000c] ;
			pbd_UltOut->ULTUPDTYP_CF = 'U' ;	
		}
		else
		{
			if ( c_RT2P_AdmMod == 'A' )
			{
			/*	pbd_UltOut->ENTAMTPRM_M = pbd_Ult->ENTAMTPRM_M ; */
				d_FC34_SbjPrm = pbd_Aff->SBJPRMCPT_M ;
			}
			else
			{
			/*	pbd_UltOut->ENTAMTPRM_M = pbd_Aff->SCOGLOEGP_M ; */
				d_FC34_SbjPrm = pbd_Aff->DEFSBJPRM_M ;
			}

			/* ------------ */
			/* appel de RC3 */
			/* ------------ */
			d_RC3_RetAmtPrm = d_RegleChoixPrimeTraitNonProp( c_RT2P_AdmMod,  pbd_Pcs->PRMAMT_M[POSTCUM_10000c],
				pbd_UltOut->ENTAMTPRM_M, pbd_Aff->PMDEGPCUR_M, pbd_Aff->CUTSHA_R, 
				pbd_Aff->RIDSHA_R, pbd_Aff->LIARIDSHA_B  ) ;

			/* ------------ */
			/* appel de FC2 */
			/* ------------ */
			d_FC2_GroTotEgp = d_CalculAlimentAssietteTraitNonProp( d_RC3_RetAmtPrm,
				pbd_Aff->CUTSHA_R, pbd_Aff->RIDSHA_R, pbd_Aff->LIARIDSHA_B, pbd_Aff->PRMFLCRAT_B,
				pbd_Aff->PRMFIXEFF_R, pbd_Aff->PRMMINEFF_R, pbd_Aff->PRMMAXEFF_R,
				pbd_Aff->FLAPRM_B, pbd_Aff->SBJPRMCPT_M, &d_FC2_GroEgp ) ;

			/* --------------------------------- */
			/* Calcul de la sinistralite retenue */
			/* --------------------------------- */
			/* Principe : si le mode de gestion sinistre = M ou F alors conservation du S/P initial
			d'où recalcul de la sinistralite sinon conservation de la sinistralite initiale */
			if ( pbd_Ult->ADMMODCLM_CT == 'M' || pbd_Ult->ADMMODCLM_CT == 'F' )
				d_RetAmtClm = ( pbd_Ult->RETAMTPRM_M == 0 ? 0 : ( d_RC3_RetAmtPrm * pbd_Ult->RETAMTCLM_M / pbd_Ult->RETAMTPRM_M ) ) ;				
			else	d_RetAmtClm = pbd_Ult->RETAMTCLM_M ;

			/* ------------ */
			/* appel de FC4 */
			/* ------------ */
			d_FC4_RecPrm = d_CalculPrimeReconstitution( pbd_Aff->REIEXI_B, 
				pbd_Aff->REIUNL_B, pbd_Aff->REIFRE_B, pbd_Aff->REINBR_N,
				d_FC34_SbjPrm, d_RetAmtClm, d_RC3_RetAmtPrm, pbd_Aff->LAYCAP_M,
				pbd_Aff->CUTSHA_R, pbd_Aff->RIDSHA_R, pbd_Aff->LIARIDSHA_B,	pbd_Rec ) ;

			/* modification et formatage de la date de creation */
			RecSysDate( pbd_UltOut->CRE_D, sz_HeureSyst ) ;
			FormatTime( sz_HeureSyst, sz_HeureSyst ) ;
			strcat( pbd_UltOut->CRE_D, sz_Space ) ;
			strcat( pbd_UltOut->CRE_D, sz_HeureSyst ) ;

			/* affectation de la variable de sortie Primes et sinistres ultimes */	
			pbd_UltOut->CALAMTPRM_M = pbd_Pcs->PRMAMT_M[POSTCUM_10000c] ;
			pbd_UltOut->RETAMTPRM_M = d_RC3_RetAmtPrm ;
			pbd_UltOut->RETAMTCLM_M = d_RetAmtClm ;
			pbd_UltOut->ADMMODPRM_CT = c_RT2P_AdmMod ;
			pbd_UltOut->RESPRM_M = d_FC4_RecPrm ;
			strcpy( pbd_UltOut->ORICOD_LS, "Account" ) ;
			strcpy( pbd_UltOut->UPDUSR_CF, "ESEJ1000" ) ;
			pbd_UltOut->ULTUPDTYP_CF = 'I' ;

			/* affectation de la variable de sortie Souscription */	
			strcpy( pbd_Uw->CTR_NF, pbd_Aff->CTR_NF ) ;
			pbd_Uw->UWY_NF = pbd_Aff->UWY_NF ;
			pbd_Uw->UW_NT = pbd_Aff->UW_NT ;
			pbd_Uw->END_NT = pbd_Aff->END_NT ;
			pbd_Uw->SEC_NF = pbd_Aff->SEC_NF ;
			pbd_Uw->CTRNAT_CT = pbd_Aff->CTRNAT_CT;
			pbd_Uw->ESTEND_B = 0 ;
			pbd_Uw->ADMMODCTR_CT = c_RT2P_AdmMod ;
			pbd_Uw->ESTUPDTYP_CT = 'I' ;
			pbd_Uw->SCOGLOEGP_M = d_RC3_RetAmtPrm ;
			pbd_Uw->PMLRAT_R = ( ( d_RC3_RetAmtPrm == 0 ) ? 0 : ( -1 * pbd_UltOut->RETAMTCLM_M / d_RC3_RetAmtPrm ) ) ;

			if ( c_RT2P_AdmMod == 'A' )
			{
				pbd_Uw->TOTCLM_M = d_FC2_GroTotEgp ;
				pbd_Uw->SCOEGPCAL_B = 1 ;
			}
			else
			{
				pbd_Uw->TOTCLM_M = pbd_Aff->EGPLESSCO_M ;
				pbd_Uw->SCOEGPCAL_B = pbd_Aff->SCOEGPCAL_B ;	
			}
		}

		/* si la condition n'est pas verifiee pas de mise a jour */
		if ( pbd_UltOut->CALAMTPRM_M != pbd_Ult->CALAMTPRM_M ||
			pbd_UltOut->ENTAMTPRM_M != pbd_Ult->ENTAMTPRM_M ||
			pbd_UltOut->RETAMTPRM_M != pbd_Ult->RETAMTPRM_M ||
			pbd_UltOut->ADMMODPRM_CT != pbd_Ult->ADMMODPRM_CT )
		{
			n_WriteUlt( Kp_OutputFilUlt, pbd_UltOut ) ;
			if ( pbd_UltOut->ULTUPDTYP_CF == 'I' )
				n_WriteUw( Kp_OutputFilUw, pbd_Uw ) ;
		}
	}

	/* ------------ */
	/* FACULTATIVES */
	/* ------------ */

	if ( pbd_Aff->CTRNAT_CT == 'F' )
	{
		/* ----------------------------------------------- */
		/* appel de la fonction RT3 (type de traitement P) */
		/* ----------------------------------------------- */
		c_RT3P_AdmMod = c_TransitionFac( d_RT0_ParRat, pbd_Pcs->PRMAMT_M[POSTCUM_10000c], 
			pbd_UltOut->ENTAMTPRM_M, 'P', pbd_Ult->ADMMODPRM_CT ) ;

		if ( pbd_Aff->ESTUPDTYP_CT == 'U' && c_RT3P_AdmMod == 'M' )
		{
			/* affectation de la variable de sortie Primes et sinistres ultimes */ 
			pbd_UltOut->CALAMTPRM_M = pbd_Pcs->PRMAMT_M[POSTCUM_10000c] ;
			pbd_UltOut->ULTUPDTYP_CF = 'U' ;	
		}
		else
		{
			/* if ( c_RT3P_AdmMod == 'A' )
				pbd_UltOut->ENTAMTPRM_M = pbd_Ult->ENTAMTPRM_M ;
			else	pbd_UltOut->ENTAMTPRM_M = pbd_Aff->SCOGLOEGP_M ; */

			/* ------------ */
			/* appel de RC5 */
			/* ------------ */
			d_RC5_RetAmtPrm = d_RegleChoixPrimeFac( c_RT3P_AdmMod,
				 pbd_Pcs->PRMAMT_M[POSTCUM_10000c], pbd_UltOut->ENTAMTPRM_M ) ;

			/* --------------------------------- */
			/* Calcul de la sinistralite retenue */
			/* --------------------------------- */
			/* Principe : si le mode de gestion sinistre = M ou F alors conservation du S/P initial
			d'où recalcul de la sinistralite sinon conservation de la sinistralite initiale */
			if ( pbd_Ult->ADMMODCLM_CT == 'M' || pbd_Ult->ADMMODCLM_CT == 'F' )
				d_RetAmtClm = ( pbd_Ult->RETAMTPRM_M == 0 ? 0 : ( d_RC5_RetAmtPrm * pbd_Ult->RETAMTCLM_M / pbd_Ult->RETAMTPRM_M ) ) ;				
			else	d_RetAmtClm = pbd_Ult->RETAMTCLM_M ;
		
			/* modification et formatage de la date de creation */
			RecSysDate( pbd_UltOut->CRE_D, sz_HeureSyst ) ;
			FormatTime( sz_HeureSyst, sz_HeureSyst ) ;
			strcat( pbd_UltOut->CRE_D, sz_Space ) ;
			strcat( pbd_UltOut->CRE_D, sz_HeureSyst ) ;
	
			/* affectation de la variable de sortie Primes et sinistres ultimes */	
			pbd_UltOut->CALAMTPRM_M = pbd_Pcs->PRMAMT_M[POSTCUM_10000c] ;
			pbd_UltOut->RETAMTPRM_M = d_RC5_RetAmtPrm ;
			pbd_UltOut->RETAMTCLM_M = d_RetAmtClm ;
			pbd_UltOut->ADMMODPRM_CT = c_RT3P_AdmMod ;
			strcpy( pbd_UltOut->ORICOD_LS, "Account" ) ;
			strcpy( pbd_UltOut->UPDUSR_CF, "ESEJ1000" ) ;
			pbd_UltOut->ULTUPDTYP_CF = 'I' ;

			/* affectation de la variable de sortie Souscription */	
			strcpy( pbd_Uw->CTR_NF, pbd_Aff->CTR_NF ) ;
			pbd_Uw->UWY_NF = pbd_Aff->UWY_NF ;
			pbd_Uw->UW_NT = pbd_Aff->UW_NT ;
			pbd_Uw->END_NT = pbd_Aff->END_NT ;
			pbd_Uw->SEC_NF = pbd_Aff->SEC_NF ;
			pbd_Uw->CTRNAT_CT = pbd_Aff->CTRNAT_CT;
			pbd_Uw->ADMMODCTR_CT = c_RT2P_AdmMod ;
			pbd_Uw->ESTUPDTYP_CT = 'I' ;
		}

		/* si la condition n'est pas verifiee pas de mise a jour */
		if ( pbd_UltOut->CALAMTPRM_M != pbd_Ult->CALAMTPRM_M ||
			pbd_UltOut->ENTAMTPRM_M != pbd_Ult->ENTAMTPRM_M ||
			pbd_UltOut->RETAMTPRM_M != pbd_Ult->RETAMTPRM_M ||
			pbd_UltOut->ADMMODPRM_CT != pbd_Ult->ADMMODPRM_CT )
		{
			n_WriteUlt( Kp_OutputFilUlt, pbd_UltOut ) ;
			if ( pbd_UltOut->ULTUPDTYP_CF == 'I' )
				n_WriteUw( Kp_OutputFilUw, pbd_Uw ) ;
		}	
	}
	
	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction de mise a jour de la variable de sortie du fichier Montants stats
par affaire

retour :	0
	
==============================================================================*/
int n_UpdateCplAmt( T_AFFAIRE *pbd_Aff, T_PCSAMT *pbd_Pcs, T_STATS *pbd_CplAmt ) 
{
	DEBUT_FCT( "n_UpdateCplAmt" ) ;

	/* affectation de la variable de sortie Montants Stats par affaire */	
	strcpy( pbd_CplAmt->CTR_NF, pbd_Aff->CTR_NF ) ;
	pbd_CplAmt->UWY_NF = pbd_Aff->UWY_NF ;
	pbd_CplAmt->UW_NT = pbd_Aff->UW_NT ;
	pbd_CplAmt->END_NT = pbd_Aff->END_NT ;
	pbd_CplAmt->SEC_NF = pbd_Aff->SEC_NF ;
	pbd_CplAmt->PRMCPLACC_M = pbd_Pcs->PRMAMT_M[POSTCUM_10000c] ;
	pbd_CplAmt->UPRCPLACC_M = pbd_Pcs->PRMAMT_M[POSTCUM_10050c] ;
	pbd_CplAmt->CLMCPLACC_M = pbd_Pcs->CLMAMT_M[POSTCUM_20000c] + pbd_Pcs->CLMAMT_M[POSTCUM_20050c]  ;
	pbd_CplAmt->ACRCPLACC_M = pbd_Pcs->CLMAMT_M[POSTCUM_20050c] ;
	pbd_CplAmt->CHACPLACC_M = pbd_Pcs->CHAAMT_M[POSTCUM_10100c]  ;
	pbd_CplAmt->RESCPLACC_M = pbd_Pcs->PRMAMT_M[POSTCUM_12000c]	+ pbd_Pcs->PRMAMT_M[POSTCUM_13000c] ;  
	pbd_CplAmt->ACCPRM_M = pbd_Pcs->PRMAMT_M[POSTCUM_10000c] + pbd_Pcs->PRMAMT_M[POSTCUM_10000] ;
	pbd_CplAmt->ACCUPR_M = pbd_Pcs->PRMAMT_M[POSTCUM_10050c] + pbd_Pcs->PRMAMT_M[POSTCUM_10050] ; 
	pbd_CplAmt->ACCCLM_M = pbd_Pcs->CLMAMT_M[POSTCUM_20000c] + pbd_Pcs->CLMAMT_M[POSTCUM_20000] + pbd_Pcs->CLMAMT_M[POSTCUM_20050] + pbd_Pcs->CLMAMT_M[POSTCUM_20050c] ;
	pbd_CplAmt->ACCACR_M = pbd_Pcs->CLMAMT_M[POSTCUM_20050] + pbd_Pcs->CLMAMT_M[POSTCUM_20050c] ;
	pbd_CplAmt->ACCCHA_M = pbd_Pcs->CHAAMT_M[POSTCUM_10100c] + pbd_Pcs->CHAAMT_M[POSTCUM_10100]   ;
	pbd_CplAmt->ACY_NF = pbd_Aff->CPLACCY_NF ;
	pbd_CplAmt->SCOENDMTH_NF = pbd_Aff->SCOLSTMTH_NF ;

	/* ecriture de la ligne dans le fichier en sortie */
	n_WriteCplAmt( Kp_OutputFilCplAmt, pbd_CplAmt ) ;
	
	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction de mise a jour de la variable de sortie du fichier Agenda

retour :	0
	
==============================================================================*/
int n_UpdateRmd( T_AFFAIRE *pbd_Aff, T_PCSAMT *pbd_Pcs, T_ULTIME *pbd_UltOut, T_AGENDA *pbd_Rmd ) 
{
	DEBUT_FCT( "n_UpdateRmd" ) ;

	/* affectation de la variable de sortie Agenda */	
	if ( pbd_Aff->EVTCOD_NF == 1 )
		strcpy( pbd_Rmd->RMDOBJ_LL, "Saisie de compte" ) ;
	if ( pbd_Aff->EVTCOD_NF == 2 )
		strcpy( pbd_Rmd->RMDOBJ_LL, "Modification de l'assiette comptable" ) ;
	if ( pbd_Aff->EVTCOD_NF == 3 )
		strcpy( pbd_Rmd->RMDOBJ_LL, "Saisie de compte complet" ) ;

	if ( pbd_Aff->CTRNAT_CT == 'F' )
	{
		strcpy( pbd_Rmd->RMDDOM_CT, "FAC" ) ;
		sprintf( pbd_Rmd->RMDENTIDT_CT, "%s/%d-%d/%d/%d/%d", pbd_Aff->CTR_NF, pbd_Aff->UWY_NF,
			pbd_Aff->UW_NT, pbd_Aff->END_NT, pbd_Aff->DIV_NT, pbd_Aff->SEC_NF ) ;
	}
	else 
	{
		strcpy( pbd_Rmd->RMDDOM_CT, "TRT" ) ;
		sprintf( pbd_Rmd->RMDENTIDT_CT, "%s/%d/%d", pbd_Aff->CTR_NF, pbd_Aff->UWY_NF,
			 pbd_Aff->SEC_NF ) ;
	}

	if ( pbd_Aff->CTRNAT_CT == 'P' )
	{
		sprintf( pbd_Rmd->CMT_T, "Periode stat = %d - %d", pbd_Aff->CPLACCY_NF, pbd_Aff->SCOLSTMTH_NF ) ;
		sprintf( pbd_Rmd->CMT_T, "%s   ***   Primes stat = %-.0f", pbd_Rmd->CMT_T, pbd_Pcs->PRMAMT_M[POSTCUM_10000c] ) ;
		sprintf( pbd_Rmd->CMT_T, "%s * Primes comptables = %-.0f", pbd_Rmd->CMT_T, ( pbd_Pcs->PRMAMT_M[POSTCUM_10000c] + pbd_Pcs->PRMAMT_M[POSTCUM_10000] ) ) ;
		sprintf( pbd_Rmd->CMT_T, "%s * Primes ultimes = %-.0f", pbd_Rmd->CMT_T, pbd_UltOut->RETAMTPRM_M ) ;
		sprintf( pbd_Rmd->CMT_T, "%s   ***   Sinistres stat = %-.0f", pbd_Rmd->CMT_T, ( pbd_Pcs->CLMAMT_M[POSTCUM_20000c] + pbd_Pcs->CLMAMT_M[POSTCUM_20050c] ) ) ;
		sprintf( pbd_Rmd->CMT_T, "%s * Sinistres comptables = %-.0f", pbd_Rmd->CMT_T, ( pbd_Pcs->CLMAMT_M[POSTCUM_20000c] + pbd_Pcs->CLMAMT_M[POSTCUM_20000] + pbd_Pcs->CLMAMT_M[POSTCUM_20050] + pbd_Pcs->CLMAMT_M[POSTCUM_20050c] ) ) ;
		sprintf( pbd_Rmd->CMT_T, "%s   ***   S/P stat = %-.2f %%", pbd_Rmd->CMT_T, ( ( pbd_Pcs->PRMAMT_M[POSTCUM_10000c] + pbd_Pcs->PRMAMT_M[POSTCUM_10050c] ) == 0 ? 0 : -100 * ( pbd_Pcs->CLMAMT_M[POSTCUM_20000c] + pbd_Pcs->CLMAMT_M[POSTCUM_20050c] ) / ( pbd_Pcs->PRMAMT_M[POSTCUM_10000c] + pbd_Pcs->PRMAMT_M[POSTCUM_10050c] ) ) ) ;							
		sprintf( pbd_Rmd->CMT_T, "%s * S/P ultime = %-.2f %%", pbd_Rmd->CMT_T, ( pbd_UltOut->RETAMTPRM_M == 0 ? 0 : -100 * ( pbd_UltOut->RETAMTCLM_M / pbd_UltOut->RETAMTPRM_M ) ) ) ;							
	}
	else
	{
		sprintf( pbd_Rmd->CMT_T, "Primes comptabilisees = %-.0f", pbd_Pcs->PRMAMT_M[POSTCUM_10000c] ) ;							
		sprintf( pbd_Rmd->CMT_T, "%s * Primes ultimes retenues = %-.0f", pbd_Rmd->CMT_T, pbd_UltOut->RETAMTPRM_M  ) ;							
		sprintf( pbd_Rmd->CMT_T, "%s   ***   Sinistres comptabilises = %-.0f", pbd_Rmd->CMT_T, ( pbd_Pcs->CLMAMT_M[POSTCUM_20000c] + pbd_Pcs->CLMAMT_M[POSTCUM_20050c] ) ) ;							
		sprintf( pbd_Rmd->CMT_T, "%s   ***   S/P compte complet = %-.2f %%", pbd_Rmd->CMT_T, ( pbd_Pcs->PRMAMT_M[POSTCUM_10000c] == 0 ? 0 : -100 * ( ( pbd_Pcs->CLMAMT_M[POSTCUM_20000c] + pbd_Pcs->CLMAMT_M[POSTCUM_20050c] ) / pbd_Pcs->PRMAMT_M[POSTCUM_10000c] ) ) ) ;							
		sprintf( pbd_Rmd->CMT_T, "%s * S/P ultime retenu = %-.2f %%", pbd_Rmd->CMT_T, ( pbd_UltOut->RETAMTPRM_M == 0 ? 0 : -100 * ( pbd_UltOut->RETAMTCLM_M / pbd_UltOut->RETAMTPRM_M ) ) ) ;			
	}

	strcpy( pbd_Rmd->UWRSPUSR_CF, pbd_Aff->UWRSPUSR_CF ) ;
	strcpy( pbd_Rmd->ADMUSR_CF, pbd_Aff->ADMUSR_CF ) ;
	strcpy( pbd_Rmd->RMDENTLAB_LL, pbd_Aff->SECLAB_LM ) ;

	/* ecriture dans le fichier Agenda en sortie */
	n_WriteRmd( Kp_OutputFilRmd, pbd_Rmd ) ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction d'ecriture dans le fichier Primes et sinistres ultimes 

retour :	0
	
==============================================================================*/
int n_WriteUlt( FILE *Kp_OuputFil, T_ULTIME *pbd_UltOut )
{
	DEBUT_FCT( "n_WriteUlt" ) ;

	fprintf( Kp_OuputFil, "%s~%d~%d~%d~%d~%s~%d~%d~%s~%-.3f~%-.3f~%-.3f~%c~%-.3f~%-.3f~%-.3f~%-.3f~%c~%s~%s~%c\n",
		pbd_UltOut->CTR_NF, pbd_UltOut->UWY_NF, pbd_UltOut->UW_NT, pbd_UltOut->END_NT,
		pbd_UltOut->SEC_NF, pbd_UltOut->CRE_D, pbd_UltOut->SSD_CF, pbd_UltOut->DIV_NT,
		pbd_UltOut->CUR_CF, pbd_UltOut->CALAMTPRM_M, pbd_UltOut->ENTAMTPRM_M, 
		pbd_UltOut->RETAMTPRM_M, pbd_UltOut->ADMMODPRM_CT, pbd_UltOut->RESPRM_M,
		pbd_UltOut->CALAMTCLM_M, pbd_UltOut->ENTAMTCLM_M, pbd_UltOut->RETAMTCLM_M,
		pbd_UltOut->ADMMODCLM_CT, pbd_UltOut->ORICOD_LS, pbd_UltOut->UPDUSR_CF,
		pbd_UltOut->ULTUPDTYP_CF ) ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction d'ecriture dans le fichier Souscription 

retour :	0
	
==============================================================================*/
int n_WriteUw( FILE *Kp_OutputFil, T_SOUS *pbd_Uw ) 
{
	DEBUT_FCT( "n_WriteUw" ) ;

	fprintf( Kp_OutputFil, "%s~%d~%d~%d~%d~%c~%-.3f~%-.3f~%d~%c~%d~%c~%-.8f\n", 
		pbd_Uw->CTR_NF, pbd_Uw->UWY_NF, pbd_Uw->UW_NT, pbd_Uw->END_NT, pbd_Uw->SEC_NF, 
		pbd_Uw->CTRNAT_CT, pbd_Uw->SCOGLOEGP_M, pbd_Uw->TOTCLM_M, pbd_Uw->SCOEGPCAL_B, pbd_Uw->ADMMODCTR_CT,
		pbd_Uw->ESTEND_B, pbd_Uw->ESTUPDTYP_CT, pbd_Uw->PMLRAT_R ) ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction d'ecriture dans le fichier Montants Stats par affaire 

retour :	0
	
==============================================================================*/
int n_WriteCplAmt( FILE *Kp_OutputFil, T_STATS *pbd_CplAmt ) 
{
	DEBUT_FCT( "n_WriteCplAmt" ) ;

	fprintf( Kp_OutputFil, "%s~%d~%d~%d~%d~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%d~%d\n", 
		pbd_CplAmt->CTR_NF, pbd_CplAmt->UWY_NF, pbd_CplAmt->UW_NT, pbd_CplAmt->END_NT, 
		pbd_CplAmt->SEC_NF, pbd_CplAmt->PRMCPLACC_M , pbd_CplAmt->UPRCPLACC_M , pbd_CplAmt->CLMCPLACC_M, pbd_CplAmt->ACRCPLACC_M, pbd_CplAmt->CHACPLACC_M,
		pbd_CplAmt->RESCPLACC_M, pbd_CplAmt->ACCPRM_M, pbd_CplAmt->ACCUPR_M, pbd_CplAmt->ACCCLM_M, pbd_CplAmt->ACCACR_M, pbd_CplAmt->ACCCHA_M, pbd_CplAmt->ACY_NF, pbd_CplAmt->SCOENDMTH_NF ) ;
		
	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction d'ecriture dans le fichier Agenda

retour :	0
	
==============================================================================*/
int n_WriteRmd( FILE *Kp_OutputFil, T_AGENDA *pbd_Rmd )
{
	DEBUT_FCT( "n_WriteRmd" ) ;

	fprintf( Kp_OutputFil, "%s~%s~%s~%s~%s~%s~%s\n", pbd_Rmd->UWRSPUSR_CF, pbd_Rmd->ADMUSR_CF,
		pbd_Rmd->RMDOBJ_LL, pbd_Rmd->RMDDOM_CT, pbd_Rmd->RMDENTLAB_LL, pbd_Rmd->RMDENTIDT_CT,
		pbd_Rmd->CMT_T ) ;

	RETURN_VAL( 0 ) ;
}


