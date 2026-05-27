/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTC1024.c
révision                      : $Revision: 1.2 $
date de création              : 03/07/1998
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   DETERMINATION DES TAUX DE CHARGES POUR LES SNEMS

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>

   27/08/1998	  M.HA-THUC	Suppression de la synchro avec FURRDAC
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include "estserv.h"
#include "struct.h"

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/
#include "ESTC1016.h"

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE 		*Kp_OutputFilLoaRat ; /* pointeur sur le fichier de sortie Taux de charges */

T_RUPTURE_VAR  	   	bd_RuptPerUw ; /* variable de gestion de la rupture sur le
					perimetre de souscription */
T_RUPTURE_SYNC_VAR 	bd_RuptPerFct ; /* variable de gestion de la synchronisation avec
					le fichier annexe du perimetre famille des charges taxes */


char Ksz_CloDat[9] ;    /* parametre de la chaine: libelle d'inventaire */
char Ksz_Cre[20] ;    	/* date systeme */
char Ksz_TypInv[2] ;	/* parametre de la chaine: type d'inventaire P ou A */

double	Kd_TaxGlo ; 	/* taux global de taxes par affaire */
double  Kd_ComRat ;	/* taux de surcommission */


int n_InitPerUw	 		( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLignePerUw		( char **pbd_InRec_Cur ) ;

int n_InitPerFct		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLignePerFct		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncPerFct	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;


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
	char	sz_SysTime[9] ;

	/* Initialisation des signaux */
	InitSig () ;

	if ( n_BeginPgm ( argc, argv ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* recuperation des parametres de la chaine */
	/* strcpy( Ksz_Cre, psz_GetCharArgv( 1 ) ) ; modification du 03/02/98 */
	strcpy( Ksz_CloDat, psz_GetCharArgv( 2 ) ) ;
	strcpy( Ksz_TypInv, psz_GetCharArgv( 3 ) ) ;

	/* modification et formatage de la date de creation */
	RecSysDate( Ksz_Cre, sz_SysTime ) ;
	FormatTime( sz_SysTime, sz_SysTime ) ;
	strcat( Ksz_Cre, " " ) ;
	strcat( Ksz_Cre, sz_SysTime ) ;

	/* ouverture du fichier de sortie des taux de charges */
	if ( n_OpenFileAppl ( "ESTC1024_O1","wt",&Kp_OutputFilLoaRat ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPerUw */
	if ( n_InitPerUw( &bd_RuptPerUw ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPerFct */
	if ( n_InitPerFct( &bd_RuptPerFct ) )
		ExitPgm( ERR_XX , "" ) ;

	/* lancement du traitement du fichier Perimetre de souscription IADPERICASE.dat */
	if ( n_ProcessingRuptureVar( &bd_RuptPerUw ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1024_I1", &( bd_RuptPerUw.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1024_I2", &( bd_RuptPerFct.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1024_O1", &Kp_OutputFilLoaRat ) == ERR )
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
int n_InitPerUw(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitPerUw" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier maitre Perimetre de souscription */
	if ( n_OpenFileAppl( "ESTC1024_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction d'action sur la ligne courante du fichier maitre */
	pbd_Rupt->n_ActionLigne = n_ActionLignePerUw ;

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
int n_ActionLignePerUw( char **ptb_InRec_Cur )
{
	char *LoaRat[NB_COL_LOARAT + 1] ; /* tableau de pointeur a l'image du fichier de sortie
		Taux de charge */
	char sz_ComRat[20] ; /* zone de travail intermediaire */
	char sz_SurComRat[20] ; /* zone de travail intermediaire */
	char sz_ResRat[20] ; /* zone de travail intermediaire */
	char sz_GloCouRat[20] ; /* zone de travail intermediaire */

	double d_SurComRat = 0 ; /* taux de surcommission */
	double d_ResRat = 0 ; /* taux restitue */
	double d_GloCouRat = 0 ; /* taux de courtage global */

	char	MsgAno[300] ;	/* message d'anomalie */

	DEBUT_FCT( "n_ActionLignePerUw" ) ;

	/* initialisation des variables de travail */
	Kd_TaxGlo = 0 ;
	Kd_ComRat = 0 ;

	/* Si on est en commission variable -> anomalie */
	if ( atoi( ptb_InRec_Cur[PER_COMTYP_CT] ) == 2 )
	{
		sprintf( MsgAno, "The commission type for this following contract with SNEM ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) is sliding scale commission\n",
			ptb_InRec_Cur[PER_CTR_NF], ptb_InRec_Cur[PER_END_NT],  ptb_InRec_Cur[PER_SEC_NF], ptb_InRec_Cur[PER_UWY_NF], ptb_InRec_Cur[PER_UW_NT] ) ;
		n_WriteAno( MsgAno ) ;

		/* on force le taux de surcommission a 0 */
		Kd_ComRat = 0 ;
	}
	else
	{
		/********************************************************/
		/* calcul de commissions fixes ou originales */
		/********************************************************/
		Kd_ComRat = d_CalculChargesCommissions(
			(char)( atoi( ptb_InRec_Cur[PER_PRMNETCOM_B] ) ),
			(char)( atoi( ptb_InRec_Cur[PER_COMTYP_CT] ) ),
			atof( ptb_InRec_Cur[PER_FIXCOM_R] ),
			atof( ptb_InRec_Cur[PER_MAXCOM_R] ),
			atof( ptb_InRec_Cur[PER_MINRATCLP_R] ),
			atof( ptb_InRec_Cur[PER_MINCOM_R] ),
			atof( ptb_InRec_Cur[PER_MAXRATCLP_R] ),
			0, 0, 0, NULL ) ;
	}

	/****************************/
	/* calcul de surcommissions */
	/****************************/
	if ( atof( ptb_InRec_Cur[PER_OVRCOM_R] ) == 0 )
		d_SurComRat = 0 ;
	else
	{
		if ( atoi( ptb_InRec_Cur[PER_OVRCOMTYP_CT] ) == 0 )
			d_SurComRat = atof ( ptb_InRec_Cur[PER_OVRCOM_R] ) ;
		if ( atoi( ptb_InRec_Cur[PER_OVRCOMTYP_CT] ) == 1 )
			d_SurComRat = atof ( ptb_InRec_Cur[PER_OVRCOM_R] ) * ( 1 - Kd_ComRat ) ;
	}

	/* synchronisation avec le fichier Perimetre annexe famille des charges taxes */
	/* Remarque: la place de cette synchro est importante car le taux de commission retenu
	doit etre calcule au prealable */
	n_ProcessingRuptureSyncVar( &bd_RuptPerFct, ptb_InRec_Cur ) ;

	/*******************/
	/* calcul de taxes */
	/*******************/
	if ( *ptb_InRec_Cur[PER_TAXCNDEXI_B] == '1' )
		d_ResRat = Kd_TaxGlo ;

	/**********************/
	/* calcul de courtage */
	/**********************/
	/* cas ou le taux de courtage 1 est exprime sur prime brute */
	if ( *ptb_InRec_Cur[PER_PRDBRKTYP_CT] == '0' )
		d_GloCouRat = atof( ptb_InRec_Cur[PER_PRDBRK_R] ) ;

	/* cas ou le taux de courtage 1 est exprime sur prime nette */
	if ( *ptb_InRec_Cur[PER_PRDBRKTYP_CT] == '1' )
		d_GloCouRat = ( atof( ptb_InRec_Cur[PER_PRDBRK_R] ) * ( 1 - Kd_ComRat ) ) ;

	/* cas ou le taux de courtage 2 est exprime sur prime brute */
	if ( *ptb_InRec_Cur[PER_ACCBRKTYP_CT] == '0' )
		d_GloCouRat += atof( ptb_InRec_Cur[PER_ACCBRK_R] ) ;

	/* cas ou le taux de courtage 2 est exprime sur prime nette */
	if ( *ptb_InRec_Cur[PER_ACCBRKTYP_CT] == '1' )
		d_GloCouRat += ( atof( ptb_InRec_Cur[PER_ACCBRK_R] ) * ( 1 - Kd_ComRat ) ) ;

	/********************************************************/
	/* ecriture dans le fichier en sortie Taux statistiques */
	/********************************************************/
	LoaRat[LOA_CTR_NF] = ptb_InRec_Cur[PER_CTR_NF] ;
	LoaRat[LOA_END_NT] = ptb_InRec_Cur[PER_END_NT] ;
	LoaRat[LOA_SEC_NF] = ptb_InRec_Cur[PER_SEC_NF] ;
	LoaRat[LOA_UWY_NF] = ptb_InRec_Cur[PER_UWY_NF] ;
	LoaRat[LOA_UW_NT] = ptb_InRec_Cur[PER_UW_NT] ;
	LoaRat[LOA_SSD_CF] = ptb_InRec_Cur[PER_SSD_CF] ;
	LoaRat[LOA_COMMIS_R] = sz_ComRat ;
	LoaRat[LOA_OVECOM_R] = sz_SurComRat ;
	LoaRat[LOA_TAX_R] = sz_ResRat ;
	LoaRat[LOA_BROKER_R] = sz_GloCouRat ;
	LoaRat[LOA_BROKER_R + 1] = NULL ;

	sprintf( sz_ComRat, "%-.8f", Kd_ComRat ) ;
	sprintf( sz_SurComRat, "%-.8f", d_SurComRat ) ;
	sprintf( sz_ResRat, "%-.8f", d_ResRat ) ;
	sprintf( sz_GloCouRat, "%-.8f", d_GloCouRat ) ;

	n_WriteCols( Kp_OutputFilLoaRat, LoaRat, SEPARATEUR, 0 ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription » avec
	l'esclave « Perimetre annexe famille des charges taxes »

retour :
	OK
==============================================================================*/
int n_InitPerFct(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitPerFct" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave famille des charges taxes */
	if ( n_OpenFileAppl( "ESTC1024_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer sur le fichier de travail */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncPerFct ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLignePerFct ;

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
int n_ConditionSyncPerFct(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncPerFct" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[PERFCT_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[PERFCT_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[PERFCT_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[PERFCT_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[PERFCT_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePerFct(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLignePerFct" ) ;

	/* CALCUL DU TAUX GLOBAL DE TAXE */
	/* cas ou le taux de taxe est exprime sur prime brute */
	if ( *ptb_InRecChild[PERFCT_TAXTYP_CT] == '0' )
		Kd_TaxGlo += atof( ptb_InRecChild[PERFCT_TAX_R] ) ;

	/* cas ou le taux de taxe est exprime sur prime nette */
	if ( *ptb_InRecChild[PERFCT_TAXTYP_CT] == '1' )
		Kd_TaxGlo += ( atof( ptb_InRecChild[PERFCT_TAX_R] ) * ( 1 - Kd_ComRat ) ) ;

	RETURN_VAL( OK ) ;
}




