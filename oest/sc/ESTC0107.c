/*==============================================================================
nom de l'application          : ESTIMATION 
nom du source                 : ESTC0107.c
révision                      : $Revision:   1.1  $
date de création              : 02/09/1998
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
	PERICASE : Conversion des montants d'assiette de primes, chargement effectif 
et portee en devise aliment
	PERIPRMD : Conversion des montants de primes en devise aliment

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	   ...           ...            ...              ...
[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
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

FILE 		*Kp_OutputFilPerUw ; /* pointeur sur le fichier de sortie Perimetre de souscription hors retro interne */
FILE 		*Kp_OutputFilPerPrmd ; /* pointeur sur le fichier de sortie Perimetre des
						echeancier de primes provisionnelles */
FILE 		*Kp_InputFilExc ; /* pointeur sur le fichier en entree des cours de change */

T_RUPTURE_VAR  	   	bd_RuptPerUw ; /* variable de gestion de la rupture sur le perimetre de
						souscription */
T_RUPTURE_SYNC_VAR 	bd_RuptPerPrmd ; /* variable de gestion de la synchronisation avec 
						le fichier perimetre des echeancier de primes provisionnelles  */

char Ksz_NbreMois[25];             /* Difference en nombre de mois */

int n_InitPerUw	 		( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLignePerUw		( char **pbd_InRec_Cur ) ;

int n_InitPerPrmd		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLignePerPrmd	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncPerPrmd	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ActionFilsSansPerePerPrmd	( char **pbd_InRecChild ) ; 

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

	/* ouverture du fichier en entree des cours de change FCURQUOT */
	if ( n_OpenFileAppl ( "ESTC0107_I3","rb",&Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier de sortie Perimetre de souscription */
	if ( n_OpenFileAppl ( "ESTC0107_O1","wt",&Kp_OutputFilPerUw ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier de sortie Perimetre des echeanciers de primes provisionnelles */
	if ( n_OpenFileAppl ( "ESTC0107_O2","wt",&Kp_OutputFilPerPrmd ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPerUw */
	if ( n_InitPerUw( &bd_RuptPerUw ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPerPrmd */
	if ( n_InitPerPrmd( &bd_RuptPerPrmd ) )
		ExitPgm( ERR_XX , "" ) ;

	/* lancement du traitement du fichier Perimetre de souscription IADPERICASE.dat */	
	if ( n_ProcessingRuptureVar( &bd_RuptPerUw ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC0107_I1", &( bd_RuptPerUw.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC0107_I2", &( bd_RuptPerPrmd.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC0107_I3", &Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC0107_O1", &Kp_OutputFilPerUw ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC0107_O2", &Kp_OutputFilPerPrmd ) == ERR )
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
n_InitPerUw(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitPerUw" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier maitre Perimetre de souscription */
	if ( n_OpenFileAppl( "ESTC0107_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		RETURN_VAL(  ERR ) ;

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
	double d_Ratio ; /* ratio: cours assiette de prime/cours aliment */
	double d_SbjPrmAmt ; 	/* variable de travail: montant assiette de prime */
	double d_EffLoaAmt ; 	/* variable de travail: montant de chargement effectif */
	double d_LayCapAmt ;	/* variable de travail: montant de portee */
	char sz_SbjPrmAmt[30] ;	/* zone de travail: montant assiette de prime */
	char sz_EffLoaAmt[30] ;	/* zone de travail: montant de chargement effectif */
	char sz_LayCapAmt[30] ;	/* zone de travail: montant de portee */
	char sz_Annee[5];
	char sz_Mois[3];


	char	MsgAno[300] ; /* message d'anomalie */

	DEBUT_FCT( "n_ActionLignePerUw" ) ;


	/* calcul du decalage */
	/*************************************/
   	/* Modfis du 22/06/98 - M.HA-THUC	*/
   	/* On calcule l'ecart pour chaque 	*/
   	/* exercice				*/
   	/*************************************/

   	if (*ptb_InRec_Cur[PER_CTRNAT_CT] != 'F') 
	{
      		sz_Annee[0] = ptb_InRec_Cur[PER_EXP_D][0];
      		sz_Annee[1] = ptb_InRec_Cur[PER_EXP_D][1];
      		sz_Annee[2] = ptb_InRec_Cur[PER_EXP_D][2];
      		sz_Annee[3] = ptb_InRec_Cur[PER_EXP_D][3];
      		sz_Annee[4] = '\0';
      		sz_Mois[0] = ptb_InRec_Cur[PER_EXP_D][4];
      		sz_Mois[1] = ptb_InRec_Cur[PER_EXP_D][5];
      		sz_Mois[2] = '\0';
      		sprintf(Ksz_NbreMois, "%d", - n_DureeEnMois(atoi(ptb_InRec_Cur[PER_UWY_NF]), 12, atoi(sz_Annee), atoi(sz_Mois)));
   	}
   	else 
	{
      		*Ksz_NbreMois = '\0';
   	}

   	ptb_InRec_Cur[PER_DIFMTH_NF] = Ksz_NbreMois;

		
	/* synchronisation avec le fichier Perimetre des echeances de primes provisionnelles */
	n_ProcessingRuptureSyncVar( &bd_RuptPerPrmd, ptb_InRec_Cur ) ;

	/* affectation des montants assiette de prime, chargement effectif et portee */
	d_SbjPrmAmt = atof( ptb_InRec_Cur[PER_SBJPRM_M] ) ; 	
	d_EffLoaAmt = atof( ptb_InRec_Cur[PER_PRMEFFLOA_M] ) ; 
	d_LayCapAmt = atof( ptb_InRec_Cur[PER_LAYCAP_M] ) ; 

	ptb_InRec_Cur[PER_SBJPRM_M] = sz_SbjPrmAmt ;
	ptb_InRec_Cur[PER_PRMEFFLOA_M] = sz_EffLoaAmt ;
	ptb_InRec_Cur[PER_LAYCAP_M] = sz_LayCapAmt ;

	/* conversion du montant de l'assiette de prime en devise aliment */
	if ( *ptb_InRec_Cur[PER_CTRNAT_CT] == 'N' && strcmp( ptb_InRec_Cur[PER_SBJPRMCUR_CF], ptb_InRec_Cur[PER_EGPCUR_CF] ) != 0 )
	{
		d_Ratio = d_GetTaux( Kp_InputFilExc, (char) atoi( ptb_InRec_Cur[PER_SSD_CF] ),
			( atoi( ptb_InRec_Cur[PER_UWY_NF] ) - 1 ), ptb_InRec_Cur[PER_SBJPRMCUR_CF], 
			ptb_InRec_Cur[PER_EGPCUR_CF] ) ;
		
		/* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
		if ( d_Ratio < 0 )
		{
		sprintf( MsgAno, "The rates of EGPI currency ( %s ) and subject premium currency ( %s ) aren't known for the perimeter contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) \n",
			ptb_InRec_Cur[PER_EGPCUR_CF], ptb_InRec_Cur[PER_SBJPRMCUR_CF], 
			ptb_InRec_Cur[PER_CTR_NF],  ptb_InRec_Cur[PER_END_NT],  
			ptb_InRec_Cur[PER_SEC_NF],  ptb_InRec_Cur[PER_UWY_NF],  
			ptb_InRec_Cur[PER_UW_NT] ) ;
		n_WriteAno( MsgAno ) ;

		/* montant de l'assiette de prime positionne a zero */
		d_SbjPrmAmt = 0 ;
		}
		else	d_SbjPrmAmt *= d_Ratio ;

		/* conversion du montant de chargement effectif en devise aliment */
		if ( atoi( ptb_InRec_Cur[PER_SUPLOATYP_CT] ) == 3 && d_Ratio < 0 )
			d_EffLoaAmt = 0 ;

		if ( atoi( ptb_InRec_Cur[PER_SUPLOATYP_CT] ) == 3 && d_Ratio >= 0 )
			d_EffLoaAmt *= d_Ratio ;
	}

	/* conversion du montant de portee en devise aliment */
	if ( *ptb_InRec_Cur[PER_CTRNAT_CT] == 'N' && strcmp( ptb_InRec_Cur[PER_LIACUR_CF], ptb_InRec_Cur[PER_EGPCUR_CF] ) != 0 )
	{
		d_Ratio = d_GetTaux( Kp_InputFilExc, (char) atoi( ptb_InRec_Cur[PER_SSD_CF] ),
			( atoi( ptb_InRec_Cur[PER_UWY_NF] ) - 1 ), ptb_InRec_Cur[PER_LIACUR_CF], 
			ptb_InRec_Cur[PER_EGPCUR_CF] ) ;
		
		/* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
		if ( d_Ratio < 0 )
		{
			sprintf( MsgAno, "The rates of EGPI currency ( %s ) and Layer capacity currency ( %s ) aren't known for the perimeter contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) \n",
				ptb_InRec_Cur[PER_EGPCUR_CF], ptb_InRec_Cur[PER_SBJPRMCUR_CF], 
				ptb_InRec_Cur[PER_CTR_NF],  ptb_InRec_Cur[PER_END_NT],  
				ptb_InRec_Cur[PER_SEC_NF],  ptb_InRec_Cur[PER_UWY_NF],  
				ptb_InRec_Cur[PER_UW_NT] ) ;
			n_WriteAno( MsgAno ) ;

			/* montants positionnes a zero */
			d_LayCapAmt = 0 ;
		}
		else	d_LayCapAmt *= d_Ratio ;
	}

	sprintf( sz_SbjPrmAmt, "%-.3f", d_SbjPrmAmt ) ;
	sprintf( sz_EffLoaAmt, "%-.3f", d_EffLoaAmt ) ;
	sprintf( sz_LayCapAmt, "%-.3f", d_LayCapAmt ) ;


	/* ecriture dans le Perimetre de souscription en sortie */
	n_WriteCols( Kp_OutputFilPerUw, ptb_InRec_Cur, '~', 0 ) ;
	
	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription » 
	avec l'esclave « Perimetre des echeanciers primes provisionnelles »

retour :
	OK
==============================================================================*/
n_InitPerPrmd(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitPerPrmd" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave Mouvements comptables */
	if ( n_OpenFileAppl( "ESTC0107_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR ) 
		RETURN_VAL ( ERR ) ;

	/* nombre de rupture a gerer sur le fichier */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncPerPrmd ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLignePerPrmd ;

	/* fonction d'action quand l'esclave n'a pas de maitre */
	pbd_Rupt->n_FilsSansPere = n_ActionFilsSansPerePerPrmd ;

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
int n_ConditionSyncPerPrmd(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncPerPrmd" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[PERPRMD_CTR_NF] ) ) != 0 ) RETURN_VAL( ret ) ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[PERPRMD_END_NT] ) ) != 0 ) RETURN_VAL( ret ) ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[PERPRMD_SEC_NF] ) ) != 0 ) RETURN_VAL( ret ) ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[PERPRMD_UWY_NF] ) ) != 0 ) RETURN_VAL( ret ) ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[PERPRMD_UW_NT] ) ) != 0 ) RETURN_VAL( ret ) ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePerPrmd(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	double d_PrmDue ;
	double d_Ratio ; 
	char	**PerPrmd ;	/* tableau de pointeur permettant de sauvegarder la ligne du perimetre
				des echeances de primes */
	char sz_PrmDueAmt[30] ; /* zone de travail: montant de prime */
	char sz_EgpCur[4] ; /* zone de travail: devise aliment */
	char	MsgAno[300] ; /* message d'anomalie */
	
	DEBUT_FCT( "n_ActionLignePerPrmd" ) ;

	/* sauvegarde de la ligne courante */
	PerPrmd = ptb_InRecChild ;
	d_PrmDue = atof( ptb_InRecChild[PERPRMD_PRMDUE_M] ) ;
	strcpy( sz_EgpCur, ptb_InRecChild[PERPRMD_PRMDUECUR_CF] ) ;

	PerPrmd[PERPRMD_PRMDUE_M] = sz_PrmDueAmt ;
	PerPrmd[PERPRMD_PRMDUECUR_CF] = sz_EgpCur ;

	/* conversion si la devise de prime est differente de la devise aliment */
	if( strcmp( ptb_InRecChild[PERPRMD_PRMDUECUR_CF], ptb_InRecOwner[PER_EGPCUR_CF] ) != 0 )
	{
		d_Ratio = d_GetTaux( Kp_InputFilExc, (char) atoi( ptb_InRecChild[PERPRMD_SSD_CF] ),
			( atoi( ptb_InRecChild[PERPRMD_UWY_NF] ) - 1 ), ptb_InRecChild[PERPRMD_PRMDUECUR_CF], 
			ptb_InRecOwner[PER_EGPCUR_CF] ) ;

		/* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
		if ( d_Ratio < 0 )
		{
		sprintf( MsgAno, "The rates of premium currency ( %s ) and EGPI currency ( %s ) aren't known for the provision premium perimeter contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) \n",
			ptb_InRecChild[PERPRMD_PRMDUECUR_CF],  ptb_InRecOwner[PER_EGPCUR_CF],
			ptb_InRecChild[PERPRMD_CTR_NF],  ptb_InRecChild[PERPRMD_END_NT],  
			ptb_InRecChild[PERPRMD_SEC_NF],  ptb_InRecChild[PERPRMD_UWY_NF],  
			ptb_InRecChild[PERPRMD_UW_NT] ) ;
		n_WriteAno( MsgAno ) ;

		/* montant positionne a zero */
		d_PrmDue = 0 ;		
		}
		else 	d_PrmDue *= d_Ratio ;

		strcpy( sz_EgpCur, ptb_InRecOwner[PER_EGPCUR_CF] ) ;
	}

	sprintf( sz_PrmDueAmt, "%-.3f", d_PrmDue ) ;

	/* ecriture dans le Perimetre des echeances de primes en sortie */
	n_WriteCols( Kp_OutputFilPerPrmd, PerPrmd, '~', 0 ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee quand le fils n'a pas de pere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFilsSansPerePerPrmd(
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{	
	DEBUT_FCT( "n_ActionFilsSansPerePerPrmd" ) ;

	/* ecriture dans le fichier en sortie */
	n_WriteCols( Kp_OutputFilPerPrmd, ptb_InRecChild, SEPARATEUR, 0 ) ;

	RETURN_VAL( OK ) ;
}

