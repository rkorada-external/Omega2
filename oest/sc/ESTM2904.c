/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTM2904.c
révision                      : $Revision: 1.2 $
date de creation              : 21/04/1998
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   TRAITEMENT DES RECONDUCTIONS DU BILAN 1997 SUR L'ANCIEN SYSTEME - GTR -
POUR LES FILIALES PARISIENNES

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
	   ...           ...            ...              ...
[002] 27/06/2014 R. Cassis :spot:25036 Modifie compteur du NB_DETTRS_MAX (triplé)
[XXX] 09/10/2014  JBG  :spot:25773  suppress warning: unused variables
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

#define NB_POSTE_MAX 5000	   /* Le nombre max de postes est fixe a 1000 [002] */
#define NB_DETTRS_MAX 30000	/* Le nombre max de postes est fixe a 7000 [002] */


typedef struct {
        char		DETTRS_CF[9] ;
        char		RENV_B ;
        char	        PROPCRBTRS_CF[9] ;
        char	        NPROPTRS_CF[9] ;
	char		FACTRS_CF[9] ;
        char	        IBNRSSDTRS_CF[9] ;
} T_ACCTRSF ;

typedef struct {
	char         	DETTRS_CF[9] ;
	char         	CTRSCOD_CF[9] ;
	unsigned char   TRSTYP_CT ;
	char         	RETTRSCOD_CF[9] ;
	unsigned char   RET_B ;
	unsigned char   COMP_B ;
} T_DETTRS;

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE 		*Kp_OutputFilRecond ; 	/* pointeur sur le fichier de sortie des reconductions */
FILE 		*Kp_InputFilAccTrsf ; 	/* pointeur sur le fichier en entree des transformations de postes */
FILE 		*Kp_InputFilDetTrs ; 	/* pointeur sur le fichier en entree FDETTRS */

T_RUPTURE_VAR  	   	bd_RuptPer ; 	/* variable de gestion de la rupture sur le perimetre */
T_RUPTURE_SYNC_VAR 	bd_RuptRecond ; /* variable de gestion de la synchronisation */

T_ACCTRSF	Ktbd_AccTrsf[NB_POSTE_MAX] ;
int		Kn_NbLigAccTrsf ;	/* nombre de lignes du tableau Ktbd_AccTrsf */
T_DETTRS	Ktbd_DetTrs[NB_DETTRS_MAX] ;
int		Kn_NbLigDetTrs ;	/* nombre de lignes du tableau Ktbd_DetTrs */
char		Ksz_Annee[5]	;

int n_InitPer	 		( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLignePer		( char **pbd_InRec_Cur ) ;

int n_InitRecond		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneRecond		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncRecond	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;


int n_ProcessingRuptureSyncVar (
			T_RUPTURE_SYNC_VAR  *pbd_Rupt,
			char **ptb_InRecOwner );

int n_ChargerACCTRSF( ) ;
int n_RechPoste( char *sz_poste ) ;
int n_ChargerDETTRS( ) ;
int n_RechContrepartie( char *sz_poste ) ;


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

	/* ouverture du fichier en entree des transformations de postes */
	if ( n_OpenFileAppl ( "ESTM2904_I3","rb",&Kp_InputFilAccTrsf ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier en entree FDETTRS */
	if ( n_OpenFileAppl ( "ESTM2904_I4","rb",&Kp_InputFilDetTrs ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier de sortie des reconductions */
	if ( n_OpenFileAppl ( "ESTM2904_O1","wt",&Kp_OutputFilRecond ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPer */
	if ( n_InitPer( &bd_RuptPer ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptRecond */
	if ( n_InitRecond( &bd_RuptRecond ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Chargement des postes en memoire */
	Kn_NbLigAccTrsf = n_ChargerACCTRSF( );
	Kn_NbLigDetTrs = n_ChargerDETTRS( );

	/* lancement du traitement du fichier Perimetre */
	if ( n_ProcessingRuptureVar( &bd_RuptPer ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTM2904_I1", &( bd_RuptPer.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTM2904_I2", &( bd_RuptRecond.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTM2904_I3", &Kp_InputFilAccTrsf ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTM2902_I4", &Kp_InputFilDetTrs ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTM2904_O1", &Kp_OutputFilRecond ) == ERR )
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
int n_InitPer(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitPer" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier maitre Perimetre */
	if ( n_OpenFileAppl( "ESTM2904_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		RETURN_VAL(  ERR ) ;

	/* fonction d'action sur la ligne courante du fichier maitre */
	pbd_Rupt->n_ActionLigne = n_ActionLignePer ;

	pbd_Rupt->c_Separ = SEPARATEUR ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePer( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionLignePer" ) ;

	/* synchronisation avec le fichier des reconductions en entree */
	n_ProcessingRuptureSyncVar( &bd_RuptRecond, ptb_InRec_Cur ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l’esclave

retour :
	OK
==============================================================================*/
int n_InitRecond( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitRecond" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTM2904_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		RETURN_VAL (ERR )  ;

	/* nombre de rupture a gerer sur le fichier de travail */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncRecond ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneRecond ;

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
int n_ConditionSyncRecond(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncRecond" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_RETCTR_NF] ) ) != 0 ) RETURN_VAL( ret ) ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GT_RETEND_NT] ) ) != 0 ) RETURN_VAL( ret ) ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GT_RETSEC_NF] ) ) != 0 ) RETURN_VAL( ret ) ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_RTY_NF] ) ) != 0 ) RETURN_VAL( ret ) ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GT_RETUW_NT] ) ) != 0 ) RETURN_VAL( ret ) ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneRecond(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	int 	i ;
	char	MsgAno[500] ;		/* message d'anomalies */
	char	sz_PosteDetail[5] ;	/* poste detaille */

	char	sz_trncod[9] ;		/* zone de travail */
	char	sz_dbltrncod[9] ;	/* zone de travail */
	char	sz_montantret[30] ;	/* zone de travail */

	DEBUT_FCT( "n_ActionLigneRecond" ) ;

	/* pas de transformation pour la vie - LOB = 30 ou 31 */
	if ( atoi(ptb_InRecOwner[PER_LOB_CF]) == 30 || atoi(ptb_InRecOwner[PER_LOB_CF]) == 31 )
		RETURN_VAL( OK ) ;

	/* recherche dans le tableau des correspondances */
	i = n_RechPoste( ptb_InRecChild[GT_TRNCOD_CF] ) ;

	/* si on ne trouve pas de postes dans le tableau, on sort */
	if ( i == -1 )
		RETURN_VAL( OK ) ;

	/* formatage du poste detaille avant traitement des IBNR */
	sprintf( sz_PosteDetail, "%5.5s", ptb_InRecChild[GT_TRNCOD_CF] + 2 ) ;

	/* traitement des IBNR */
	if ( strcmp( sz_PosteDetail, "44000" ) == 0 || strcmp( sz_PosteDetail, "44100" ) == 0 )
	{
		/* si filiale = 2 ou 3 ou 6 */
		if ( atoi( ptb_InRecOwner[PER_SSD_CF] ) == 2 || atoi( ptb_InRecOwner[PER_SSD_CF] ) == 3 || atoi( ptb_InRecOwner[PER_SSD_CF] ) == 6 )
			strcpy( sz_trncod, Ktbd_AccTrsf[i].IBNRSSDTRS_CF ) ;

		/* si filiale = 12 */
		if ( atoi( ptb_InRecOwner[PER_SSD_CF] ) == 12 )
			strcpy( sz_trncod, Ktbd_AccTrsf[i].PROPCRBTRS_CF ) ;

		/* annulation de l'ecriture en entree */
		sprintf( sz_montantret, "%-.3f", ( -1 * atof( ptb_InRecChild[GT_RETAMT_M] ) ) ) ;
		ptb_InRecChild[GT_RETAMT_M] = sz_montantret ;
		ptb_InRecChild[GT_BALSHRDAY_NF] = "2" ;

		n_WriteCols( Kp_OutputFilRecond, ptb_InRecChild, SEPARATEUR, 0 ) ;

		/* nouvelle ecriture avec le poste transforme */
		sprintf( sz_montantret, "%-.3f", ( -1 * atof( sz_montantret ) ) ) ;
		ptb_InRecChild[GT_TRNCOD_CF] = sz_trncod ;
		ptb_InRecChild[GT_DBLTRNCOD_CF] = sz_dbltrncod ;

		/* recherche de la contre-partie du poste transforme */
		i = n_RechContrepartie( ptb_InRecChild[GT_TRNCOD_CF] ) ;

		if ( i == -1 )
			strcpy( sz_dbltrncod, "" ) ;
		else	strcpy( sz_dbltrncod, Ktbd_DetTrs[i].CTRSCOD_CF ) ;

		n_WriteCols( Kp_OutputFilRecond, ptb_InRecChild, SEPARATEUR, 0 ) ;

		RETURN_VAL( OK ) ;
	}

	/* si le top renvoi = 1 alors generation d'une anomalie */
	if ( Ktbd_AccTrsf[i].RENV_B == 1 )
	{
		sprintf( MsgAno, "Renvoi : pas d'ecriture attendue pour le contrat ( %s ) et le poste ( %s )\n",
			ptb_InRecChild[GT_RETCTR_NF], ptb_InRecChild[GT_TRNCOD_CF] ) ;
		n_WriteAno( MsgAno ) ;

		RETURN_VAL( OK ) ;
	}
	else
	{
		/* FACS */
		if ( atoi( ptb_InRecOwner[PER_RETCTRCAT_CF] ) == 5 || atoi( ptb_InRecOwner[PER_RETCTRCAT_CF] ) == 7 || atoi( ptb_InRecOwner[PER_RETCTRCAT_CF] ) == 8 )
		{
			/* si aucune transformation = poste non renseigne */
			if ( *Ktbd_AccTrsf[i].FACTRS_CF == 0 )
				RETURN_VAL( OK ) ;

			/* si poste non affecte */
			if ( strcmp( Ktbd_AccTrsf[i].FACTRS_CF, "N/A" ) == 0 )
			{
				sprintf( MsgAno, "Non Affecte : pas d'ecriture attendue pour le contrat ( %s ) et le poste ( %s )\n",
					ptb_InRecChild[GT_RETCTR_NF], ptb_InRecChild[GT_TRNCOD_CF] ) ;
				n_WriteAno( MsgAno ) ;

				RETURN_VAL( OK ) ;
			}
			else
			{
				/* annulation de l'ecriture en entree */
				sprintf( sz_montantret, "%-.3f", ( -1 * atof( ptb_InRecChild[GT_RETAMT_M] ) ) ) ;
				ptb_InRecChild[GT_RETAMT_M] = sz_montantret ;
				ptb_InRecChild[GT_BALSHRDAY_NF] = "2" ;

				n_WriteCols( Kp_OutputFilRecond, ptb_InRecChild, SEPARATEUR, 0 ) ;

				/* nouvelle ecriture avec le poste transforme */
				sprintf( sz_montantret, "%-.3f", ( -1 * atof( sz_montantret ) ) ) ;
				ptb_InRecChild[GT_TRNCOD_CF] = Ktbd_AccTrsf[i].FACTRS_CF ;
				ptb_InRecChild[GT_DBLTRNCOD_CF] = sz_dbltrncod ;

				/* recherche de la contre-partie du poste transforme */
				i = n_RechContrepartie( ptb_InRecChild[GT_TRNCOD_CF] ) ;

				if ( i == -1 )
					strcpy( sz_dbltrncod, "" ) ;
				else	strcpy( sz_dbltrncod, Ktbd_DetTrs[i].CTRSCOD_CF ) ;

				n_WriteCols( Kp_OutputFilRecond, ptb_InRecChild, SEPARATEUR, 0 ) ;
			}
		}


		/* si traite proportionnel */
		/********************************************************/
		/* Rmq : le champs du perimetre ADMMODPRM_CT contient 	*/
		/* en realite le champs PRORETCTR_B 			*/
		/********************************************************/
		if ( ((atoi( ptb_InRecOwner[PER_RETCTRCAT_CF] )) == 1 || ( atoi( ptb_InRecOwner[PER_RETCTRCAT_CF] ) == 6 )) && ( *ptb_InRecOwner[PER_ADMMODPRM_CT] == '1' ) )
		{
			/* si aucune transformation = poste non renseigne */
			if ( *Ktbd_AccTrsf[i].PROPCRBTRS_CF == 0 )
				RETURN_VAL( OK ) ;

			/* si poste non affecte */
			if ( strcmp( Ktbd_AccTrsf[i].PROPCRBTRS_CF, "N/A" ) == 0 )
			{
				sprintf( MsgAno, "Non Affecte : pas d'ecriture attendue pour le contrat ( %s ) et le poste ( %s )\n",
					ptb_InRecChild[GT_RETCTR_NF], ptb_InRecChild[GT_TRNCOD_CF] ) ;
				n_WriteAno( MsgAno ) ;

				RETURN_VAL( OK ) ;
			}
			else
			{
				/* annulation de l'ecriture en entree */
				sprintf( sz_montantret, "%-.3f", ( -1 * atof( ptb_InRecChild[GT_RETAMT_M] ) ) ) ;
				ptb_InRecChild[GT_RETAMT_M] = sz_montantret ;
				ptb_InRecChild[GT_BALSHRDAY_NF] = "2" ;

				n_WriteCols( Kp_OutputFilRecond, ptb_InRecChild, SEPARATEUR, 0 ) ;

				/* nouvelle ecriture avec le poste transforme */
				sprintf( sz_montantret, "%-.3f", ( -1 * atof( sz_montantret ) ) ) ;
				ptb_InRecChild[GT_TRNCOD_CF] = Ktbd_AccTrsf[i].PROPCRBTRS_CF ;
				ptb_InRecChild[GT_DBLTRNCOD_CF] = sz_dbltrncod ;

				/* recherche de la contre-partie du poste transforme */
				i = n_RechContrepartie( ptb_InRecChild[GT_TRNCOD_CF] ) ;

				if ( i == -1 )
					strcpy( sz_dbltrncod, "" ) ;
				else	strcpy( sz_dbltrncod, Ktbd_DetTrs[i].CTRSCOD_CF ) ;

				n_WriteCols( Kp_OutputFilRecond, ptb_InRecChild, SEPARATEUR, 0 ) ;
			}
		}

		/* si traite non proportionnel */
		/********************************************************/
		/* Rmq : le champs du perimetre ADMMODPRM_CT contient 	*/
		/* en realite le champs PRORETCTR_B 			*/
		/********************************************************/
		if ( ((atoi( ptb_InRecOwner[PER_RETCTRCAT_CF] )) == 2 || ( atoi( ptb_InRecOwner[PER_RETCTRCAT_CF] ) == 6 )) && ( *ptb_InRecOwner[PER_ADMMODPRM_CT] == '0' ) )

		{
			/* si aucune transformation = poste non renseigne */
			if ( *Ktbd_AccTrsf[i].NPROPTRS_CF == 0 )
				RETURN_VAL( OK ) ;

			/* si poste non affecte */
			if ( strcmp( Ktbd_AccTrsf[i].NPROPTRS_CF, "N/A" ) == 0 )
			{
				sprintf( MsgAno, "Non Affecte : pas d'ecriture attendue pour le contrat ( %s ) et le poste ( %s )\n",
					ptb_InRecChild[GT_RETCTR_NF], ptb_InRecChild[GT_TRNCOD_CF] ) ;
				n_WriteAno( MsgAno ) ;

				RETURN_VAL( OK ) ;
			}
			else
			{
				/* annulation de l'ecriture en entree */
				sprintf( sz_montantret, "%-.3f", ( -1 * atof( ptb_InRecChild[GT_RETAMT_M] ) ) ) ;
				ptb_InRecChild[GT_RETAMT_M] = sz_montantret ;
				ptb_InRecChild[GT_BALSHRDAY_NF] = "2" ;

				n_WriteCols( Kp_OutputFilRecond, ptb_InRecChild, SEPARATEUR, 0 ) ;

				/* nouvelle ecriture avec le poste transforme */
				sprintf( sz_montantret, "%-.3f", ( -1 * atof( sz_montantret ) ) ) ;
				ptb_InRecChild[GT_TRNCOD_CF] = Ktbd_AccTrsf[i].NPROPTRS_CF ;
				ptb_InRecChild[GT_DBLTRNCOD_CF] = sz_dbltrncod ;

				/* recherche de la contre-partie du poste transforme */
				i = n_RechContrepartie( ptb_InRecChild[GT_TRNCOD_CF] ) ;

				if ( i == -1 )
					strcpy( sz_dbltrncod, "" ) ;
				else	strcpy( sz_dbltrncod, Ktbd_DetTrs[i].CTRSCOD_CF ) ;

				n_WriteCols( Kp_OutputFilRecond, ptb_InRecChild, SEPARATEUR, 0 ) ;
			}
		}
	}

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet:
	Lit le fichier binaire des transformation des postes et les charge en memoire

==============================================================================*/
int n_ChargerACCTRSF( )
{
	int i = 0 ;

	DEBUT_FCT("n_ChargerACCTRSF");

	while ( fread( &Ktbd_AccTrsf[i], sizeof( T_ACCTRSF ), 1, Kp_InputFilAccTrsf ) == 1 )
	{
		i += 1 ;
	}

	RETURN_VAL( i );
}


/*==============================================================================
objet:
	Lit le fichier binaire TDETTRS et les charge en memoire

==============================================================================*/
int n_ChargerDETTRS( )
{
	int i = 0 ;

	DEBUT_FCT("n_ChargerDETTRS");

	while ( fread( &Ktbd_DetTrs[i], sizeof( T_DETTRS ), 1, Kp_InputFilDetTrs ) == 1 )
	{
		i += 1 ;
	}

	RETURN_VAL( i );
}


/*==============================================================================
objet :
	fonction de recherche du poste
retour :
	0		---> Pas de rupture
	< 0   	---> On n'est pas arrive au bloc synchrone
	> 0   	---> On a depasse le bloc synchrone
==============================================================================*/
int n_RechPoste(char *sz_poste)
{
	int n_indice, ret;

	DEBUT_FCT("n_RechPoste");

	n_indice=0;

	while (1==1)
	{
		/* Comparaison des codes */
		ret=strcmp( sz_poste, Ktbd_AccTrsf[n_indice].DETTRS_CF );

		/* S'ils sont egaux, retourner l'indice */
		if (ret==0) RETURN_VAL(n_indice);

		/* Si la ligne est passee, retourner -1 (echec) */
		if (ret<0) RETURN_VAL(-1);

		/* Ligne suivante */
		n_indice++;

		/* Si on est a la fin du tableau, echec */
		if (n_indice>=Kn_NbLigAccTrsf) RETURN_VAL(-1);
	}
}


/*==============================================================================
objet :
	fonction de recherche du poste
retour :
	0		---> Pas de rupture
	< 0   	---> On n'est pas arrive au bloc synchrone
	> 0   	---> On a depasse le bloc synchrone
==============================================================================*/
int n_RechContrepartie(char *sz_poste)
{
	int n_indice, ret;

	DEBUT_FCT("n_RechContrepartie");

	n_indice=0;

	while (1==1)
	{
		/* Comparaison des codes */
		ret=strcmp( sz_poste, Ktbd_DetTrs[n_indice].DETTRS_CF );

		/* S'ils sont egaux, retourner l'indice */
		if (ret==0) RETURN_VAL(n_indice);

		/* Si la ligne est passee, retourner -1 (echec) */
		if (ret<0) RETURN_VAL(-1);

		/* Ligne suivante */
		n_indice++;

		/* Si on est a la fin du tableau, echec */
		if (n_indice>=Kn_NbLigDetTrs) RETURN_VAL(-1);
	}
}

