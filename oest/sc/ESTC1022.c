/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTC1022.c
révision                      : $Revision: 1.2 $
date de création              : 26/08/1997
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   PURGE DE L'HISTORIQUE DE LA TABLE DES ESTIMATIONS SAUF LA DERNIERE LIGNE

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
	   ...           ...            ...              ...
[001] 11/04/2018 S.Behague     :spira 65703 FORCAGE IBNR : Ajouter l'obligation de renseigner un commentaire lorsque le mode de gestion est FORCE (Aucune modification, recompilation pour prise en compte structure FCTREST)
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
#define NB_SSD_MAX	50		/* nombre maxi de filiales de l'inventaire */


/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE	*Kp_InputFilSsd ; 		/* pointeur sur le fichier en entree des filiales concernees par l'inventaire */
FILE 	*Kp_OutputFilCtrEst ; 		/* pointeur sur le fichier de sortie Estimations dommages compose des dernieres lignes de
					par affaire et par poste cumul de tous les inventaires sauf le dernier inventaire */
FILE 	*Kp_OutputFilCtrEstLosPbPap ; 	/* pointeur sur le fichier de sortie Estimations dommages pour les postes
					cumuls des Loss Corridor, PB, PAP du dernier inventaire */
FILE 	*Kp_OutputFilCtrEstCv ; 	/* pointeur sur le fichier de sortie Estimations dommages pour le poste cumul
					des commissions variables du dernier inventaire */
FILE 	*Kp_OutputFilCtrEstClm ; 	/* pointeur sur le fichier de sortie Estimations dommages pour le poste cumul
					des sinistres du dernier inventaire */

short	Kts_Ssd[NB_SSD_MAX] ;		/* tableau des filiales en 1er passage de l'inventaire */
int	Ktn_LstCloDat[NB_SSD_MAX] ; 	/* tableau des dates de l'avant dernier inventaire pour les filiales en 1er passage */
short	Kn_i = 0 ;			/* compteur des tableaux */
short	Kn_Ssd_Nbp ;			/* nombre de postes du tableau Kts_Ssd */
short	Kn_LstCloDat_Nbp ;		/* nombre de postes du tableau Ktn_LstCloDat */

char	Ksz_TypInv[2] ; 		/* argument: type d'inventaire principal ou annexe */
char	Ksz_CloDat[9] ; 		/* argument: libelle d'inventaire */
char	Ksz_SsdList[100] ; 		/* argument: liste des filiales en 1er passage sous la forme d'une chaine de caractere
					separees par des '_' et commençant par un '_' */
char	Ksz_LstCloDatList[200] ; 	/* argument: liste des dates des avant-derniers libelles d'inventaire
					separees par des '_' et commençant par un '_' */

T_RUPTURE_VAR  	bd_RuptCtrEst ; /* variable de gestion de la rupture sur le fichier de travail */

int n_InitCtrEst	 	( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_IsR1CtrEst		( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_ActionLigneCtrEst		( char **pbd_InRec_Cur ) ;
int n_ActionLastRuptCtrEst	( char **pbd_InRec_Cur ) ;

int n_ChargerTabSsd( char *liste ) ;
int n_ChargerTabLstCloDat( char *liste ) ;



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

	/* recuperation des arguments passes au programme */
	strcpy( Ksz_TypInv, psz_GetCharArgv( 1 ) ) ;
	strcpy( Ksz_CloDat, psz_GetCharArgv( 2 ) ) ;
	strcpy( Ksz_LstCloDatList, psz_GetCharArgv( 3 ) ) ;
	strcpy( Ksz_SsdList, psz_GetCharArgv( 4 ) ) ;

	/* ouverture du fichier de sortie des estimations dommages */
	if ( n_OpenFileAppl ( "ESTC1022_O1","wt",&Kp_OutputFilCtrEstLosPbPap ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier de sortie des estimations dommages */
	if ( n_OpenFileAppl ( "ESTC1022_O2","wt",&Kp_OutputFilCtrEstCv ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier de sortie des estimations dommages */
	if ( n_OpenFileAppl ( "ESTC1022_O3","wt",&Kp_OutputFilCtrEstClm ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier de sortie des estimations dommages */
	if ( n_OpenFileAppl ( "ESTC1022_O4","wt",&Kp_OutputFilCtrEst ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptCtrEst */
	if ( n_InitCtrEst( &bd_RuptCtrEst ) )
		ExitPgm( ERR_XX , "" ) ;

	/* initialisation des tableaux Kts_Ssd et Ktn_LstCloDat */
	memset( Kts_Ssd, 0, sizeof( Kts_Ssd ) ) ;
	memset( Ktn_LstCloDat, 0, sizeof( Ktn_LstCloDat ) ) ;

	/* chargement des tableau des filiales en 1er passage */
	Kn_Ssd_Nbp = n_ChargerTabSsd( Ksz_SsdList ) ;
	Kn_LstCloDat_Nbp = n_ChargerTabLstCloDat( Ksz_LstCloDatList ) ;

	/* generation d'une anomalie si les tableaux sont de tailles differentes et
	sortie du programme */
	if ( Kn_Ssd_Nbp != Kn_LstCloDat_Nbp )
	{
		n_WriteAno( "The list of subsidary in first way and the list of last closing period date are different" ) ;
		ExitPgm( ERR_XX , "" ) ;
	}

	/* lancement du traitement du fichier de travail en inventaire principal uniquement */
	if ( *Ksz_TypInv == 'P' )
	{
		if ( n_ProcessingRuptureVar( &bd_RuptCtrEst ) == ERR )
			ExitPgm( ERR_XX , "" ) ;
	}

	if ( n_CloseFileAppl( "ESTC1022_I1", &( bd_RuptCtrEst.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1022_O1", &Kp_OutputFilCtrEstLosPbPap ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1022_02", &Kp_OutputFilCtrEstCv ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1022_03", &Kp_OutputFilCtrEstClm ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1022_04", &Kp_OutputFilCtrEst ) == ERR )
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
int n_InitCtrEst(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitCtrEst" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier */
	if ( n_OpenFileAppl( "ESTC1022_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 1 ;

	/* fonction du test de rupture de niveau 1 */
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1CtrEst ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneCtrEst ;

	/* Fonction lancee en rupture derniere */
	pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptCtrEst ;

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
int n_IsR1CtrEst(
	char **pbd_InRec ,  /* adresse de la ligne en avance */
	char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
	int ret ;

	DEBUT_FCT( "n_IsR1CtrEst" ) ;

	if ( ( ret = ( atoi( pbd_InRec[EST_SSD_CF] ) - atoi( pbd_InRec_Cur[EST_SSD_CF] ) ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[EST_CTR_NF], pbd_InRec_Cur[EST_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[EST_END_NT], pbd_InRec_Cur[EST_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[EST_SEC_NF], pbd_InRec_Cur[EST_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[EST_UWY_NF], pbd_InRec_Cur[EST_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[EST_UW_NT], pbd_InRec_Cur[EST_UW_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[EST_CLODAT_D], pbd_InRec_Cur[EST_CLODAT_D] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[EST_ACMTRS_NT], pbd_InRec_Cur[EST_ACMTRS_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneCtrEst( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionLigneCtrEst" ) ;

	/* incrementation du compteur */
	if ( atoi( ptb_InRec_Cur[EST_SSD_CF] ) > Kts_Ssd[Kn_i] && ( Kn_i < Kn_Ssd_Nbp ) )
		Kn_i += 1 ;

	/******************************************/
	/* Ecriture dans le fichier FCTREST purge */
	/******************************************/

	/* 1er cas: filiales en 2eme, 3eme, ... passage */
	if ( atoi( ptb_InRec_Cur[EST_SSD_CF] ) != Kts_Ssd[Kn_i] )
		n_WriteCols( Kp_OutputFilCtrEst, ptb_InRec_Cur, SEPARATEUR, 0 ) ;

	/* 2eme cas: filiales en 1er passage */
	if ( atoi( ptb_InRec_Cur[EST_SSD_CF] ) == Kts_Ssd[Kn_i] &&
		atoi(ptb_InRec_Cur[EST_CLODAT_D] ) != Ktn_LstCloDat[Kn_i] )
		n_WriteCols( Kp_OutputFilCtrEst, ptb_InRec_Cur, SEPARATEUR, 0 ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture derniere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptCtrEst( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionLastRuptCtrEst" ) ;

	/******************************************/
	/* Ecriture dans le fichier FCTREST purge */
	/******************************************/

	/* filiales en 1er passage */
	if ( atoi( ptb_InRec_Cur[EST_SSD_CF] ) == Kts_Ssd[Kn_i] &&
		atoi( ptb_InRec_Cur[EST_CLODAT_D] ) == Ktn_LstCloDat[Kn_i] )
		n_WriteCols( Kp_OutputFilCtrEst, ptb_InRec_Cur, SEPARATEUR, 0 ) ;

	/**************************************************************/
	/* Ecriture dans les fichiers dFCTREST filtres sur les ACMTRS */
	/**************************************************************/

	/* 1er cas: filiales en 1er passage */
	if ( atoi( ptb_InRec_Cur[EST_SSD_CF] ) == Kts_Ssd[Kn_i] &&
		atoi( ptb_InRec_Cur[EST_CLODAT_D] ) == Ktn_LstCloDat[Kn_i] )
	{
		/* ecriture dans le fichier des estimations dommages du poste cumul commission variable */
		if ( atoi( ptb_InRec_Cur[EST_ACMTRS_NT] ) == 10100 )
			n_WriteCols( Kp_OutputFilCtrEstCv, ptb_InRec_Cur, SEPARATEUR, 0 ) ;

		/* ecriture dans le fichier des estimations dommages du poste cumul sinistre */
		if ( atoi( ptb_InRec_Cur[EST_ACMTRS_NT] ) == 20000 )
			n_WriteCols( Kp_OutputFilCtrEstClm, ptb_InRec_Cur, SEPARATEUR, 0 ) ;

		/* ecriture dans le fichier des estimations dommages des postes cumuls
		Loss Corridor, PB et PAP */
		if ( atoi( ptb_InRec_Cur[EST_ACMTRS_NT] ) == 21000 || atoi( ptb_InRec_Cur[EST_ACMTRS_NT] ) == 22000 ||
			atoi( ptb_InRec_Cur[EST_ACMTRS_NT] ) == 23000 )
			n_WriteCols( Kp_OutputFilCtrEstLosPbPap, ptb_InRec_Cur, SEPARATEUR, 0 ) ;
	}

	/* 2eme cas: filiales en 2eme, 3eme, ... passage */
	if ( atoi( ptb_InRec_Cur[EST_SSD_CF] ) != Kts_Ssd[Kn_i] &&
		strcmp( ptb_InRec_Cur[EST_CLODAT_D], Ksz_CloDat ) == 0 )
	{
		/* ecriture dans le fichier des estimations dommages du poste cumul commission variable */
		if ( atoi( ptb_InRec_Cur[EST_ACMTRS_NT] ) == 10100 )
			n_WriteCols( Kp_OutputFilCtrEstCv, ptb_InRec_Cur, SEPARATEUR, 0 ) ;

		/* ecriture dans le fichier des estimations dommages du poste cumul sinistre */
		if ( atoi( ptb_InRec_Cur[EST_ACMTRS_NT] ) == 20000 )
			n_WriteCols( Kp_OutputFilCtrEstClm, ptb_InRec_Cur, SEPARATEUR, 0 ) ;

		/* ecriture dans le fichier des estimations dommages des postes cumuls
		Loss Corridor, PB et PAP */
		if ( atoi( ptb_InRec_Cur[EST_ACMTRS_NT] ) == 21000 || atoi( ptb_InRec_Cur[EST_ACMTRS_NT] ) == 22000 ||
			atoi( ptb_InRec_Cur[EST_ACMTRS_NT] ) == 23000 )
			n_WriteCols( Kp_OutputFilCtrEstLosPbPap, ptb_InRec_Cur, SEPARATEUR, 0 ) ;
	}

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction de chargement du tableau des filiales en 1er passage d'inventaire

retour :	le nombre de filiales en 1er passage
==============================================================================*/
int n_ChargerTabSsd( char *liste )
{
	char *a ;
	int  i ;

	DEBUT_FCT( "n_ChargerTabSsd" ) ;

	/* cas ou il n'y a pas de filiale en premier passage d'inventaire */
	if ( strcmp( liste, "_" ) == 0 )
		return ( 0 ) ;

	a = liste ;

	for ( i = 0; i <= NB_SSD_MAX && a ; i++ )
	{
		Kts_Ssd[i] = atoi( a+1 ) ;

		a=strchr( a+1, '_' ) ;
	}

	RETURN_VAL ( i ) ;
}


/*==============================================================================
objet :
	fonction de chargement du tableau des dates des avant-derniers libelles
d'inventaire pour les filiales en 1er passage

retour :	le nombre de libelles d'inventaire deconcatener
==============================================================================*/
int n_ChargerTabLstCloDat( char *liste )
{
	char *a ;
	int  i ;

	DEBUT_FCT( "n_ChargerTabLstCloDat" ) ;

	/* cas ou la chaine est egale a "_" */
	if ( strcmp( liste, "_" ) == 0 )
		return ( 0 ) ;

	a = liste ;

	for ( i = 0; i <= NB_SSD_MAX && a ; i++ )
	{
		Ktn_LstCloDat[i] = atoi( a+1 ) ;

		a=strchr( a+1, '_' ) ;
	}

	RETURN_VAL ( i ) ;
}
