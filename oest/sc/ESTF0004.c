/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION
nom du source                 : ESTF0004.c
revision                      : $Revision: 1.2 $
date de creation              : 01/04/1998 - 22/08/2004
auteur                        : M.HA-THUC - M. DJELLOULI
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
	CONTROLE DE DOUBLONS ET DE COHERENCES SUR LE FICHIER EN ENTREE ISSUE
DE L'IBNR TOOL, POUR CHARGEMENT DE TCTRGRO

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    22/08/2004    M. DJELLOULI  Pgm Calqué sur le PGM ESTF0001.c avec génération
                                           d'un fichier au Format BEST..TCTRANO
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
	   ...           ...            ...              ...
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/


/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/
/* definition du caractere separateur */
#define SEPARATEUR '~'

/* definition de la position des champs du fichier en entree */
#define CTRGRO_CTR_NF		0
#define CTRGRO_END_NT 		1
#define CTRGRO_SEC_NF 		2
#define CTRGRO_SSD_CF		3
#define CTRGRO_SEGTYP_CT	4
#define CTRGRO_SEG_NF		5


/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE 		*Kp_OutputFilAno ; 	/* pointeur sur le fichier de sortie des anomalies */

FILE 		*Kp_OutputFilTctAno ; 	/* pointeur sur le fichier de sortie des anomalies au Format TCTRANO */

T_RUPTURE_VAR  	bd_RuptCtrGro ; 	/* variable de gestion de la rupture sur le fichier en entree */

char	Ksz_Usr[5] ;			/* parametre correspondant au code utilisateur */
char	Ksz_CtrGro_Typ[2] ;		/* parametre correspondant au type du fichier entree */
char	Ksz_Date[30] ;			/* parametre correspondant a la date de traitement */
char	Ksz_LogTyp[2] ;			/* parametre correspondant au type de message */
char	Ksz_Format_Msg[50] ;		/* parametre correspondant au message d'ano pour les formats */
char	Ksz_Dupkey_Msg[50] ;		/* parametre correspondant au message d'ano pour les doublons */
char	Ksz_Row_Msg[20] ;		/* parametre */
char	Ksz_Col_Msg[20] ;		/* parametre */
char	Ksz_Nbenr_Msg[50] ;		/* parametre correspondant au message d'ano pour le nombre de champs */
char Ksz_VrsNf [4];             /* Parametre N° de Version */
char Ksz_SegTypCT[2];       /* Parametre Type de Segment */

int 	Kn_Doublons ;			/* nombre de doublons sur la cle de rupture */
int	Kn_NbrChampsAno ;		/* nombre d'anomalies sur le nombre de champs */
int	Kn_CtrAno ;			/* nombre d'anomalies sur le champs CTR_NF */
int	Kn_EndAno ;			/* nombre d'anomalies sur le champs END_NT */
int	Kn_SecAno ;			/* nombre d'anomalies sur le champs SEC_NF */
int	Kn_SsdAno ;			/* nombre d'anomalies sur le champs SSD_CF */
int	Kn_SegtypAno ;			/* nombre d'anomalies sur le champs SEGTYP_CT */
int	Kn_SegAno ; 			/* nombre d'anomalies sur le champs SEG_NF */

short Ks_LigneCourVide ;		/* variable correspondant a l'indication "ligne courante vide ?" */
short Ks_LigneSuivVide ;		/* variable correspondant a l'indication "ligne suivante vide ?" */

int n_InitCtrGro	 	( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_IsR1CtrGro		( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_ActionFirstRuptCtrGro	( char **pbd_InRec_Cur ) ;
int n_ActionLigneCtrGro		( char **pbd_InRec_Cur ) ;
int n_ActionLastRuptCtrGro	( char **pbd_InRec_Cur ) ;

int n_IsInteger( char *sz_Champs ) ;
int n_EcrireAno( int Col, int NbrAno ) ;
int n_NbrChamps( char **pbd_InRec_Cur ) ;
int n_EcrireAnoNbrChamps( int NbrAno ) ;


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
	strcpy( Ksz_Usr, psz_GetCharArgv( 1 ) ) ;
	strcpy( Ksz_CtrGro_Typ, psz_GetCharArgv( 2 ) ) ;
	strcpy( Ksz_Date, psz_GetCharArgv( 3 ) ) ;
	strcpy( Ksz_LogTyp, psz_GetCharArgv( 4 ) ) ;
	strcpy( Ksz_Format_Msg, psz_GetCharArgv( 5 ) ) ;
	strcpy( Ksz_Dupkey_Msg, psz_GetCharArgv( 6 ) ) ;
	strcpy( Ksz_Row_Msg, psz_GetCharArgv( 7 ) ) ;
	strcpy( Ksz_Col_Msg, psz_GetCharArgv( 8 ) ) ;
	strcpy( Ksz_Nbenr_Msg, psz_GetCharArgv( 9 ) ) ;
	strcpy( Ksz_VrsNf, psz_GetCharArgv( 10 ) ) ;
	strcpy( Ksz_SegTypCT, psz_GetCharArgv( 11 ) ) ;

	/* ouverture du fichier de sortie des anomalies */
	if ( n_OpenFileAppl ( "ESTF0004_O1","wt",&Kp_OutputFilAno ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier de sortie des anomalies au Format TCTRANO */
	if ( n_OpenFileAppl ( "ESTF0004_O2","wt",&Kp_OutputFilTctAno ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptCtrGro */
	if ( n_InitCtrGro( &bd_RuptCtrGro ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation des compteurs d'anomalies sur les formats */
	Kn_CtrAno = 0 ;
	Kn_EndAno = 0 ;
	Kn_SecAno = 0 ;
	Kn_SsdAno = 0 ;
	Kn_SegtypAno = 0 ;
	Kn_SegAno = 0 ;
	Kn_NbrChampsAno = 0 ;

	/* initialisation des variables "ligne vide ?" */
	Ks_LigneCourVide = 0 ;
	Ks_LigneSuivVide = 0 ;

	/* lancement du traitement */
	if ( n_ProcessingRuptureVar( &bd_RuptCtrGro ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Ecriture en sortie du fichier des anomalies ( formats incorrects ) */
	if ( Kn_CtrAno != 0 )
		n_EcrireAno( 1, Kn_CtrAno ) ;

	if ( Kn_EndAno != 0 )
		n_EcrireAno( 2, Kn_EndAno ) ;

	if ( Kn_SecAno != 0 )
		n_EcrireAno( 3, Kn_SecAno ) ;

	if ( Kn_SsdAno != 0 )
		n_EcrireAno( 4, Kn_SsdAno ) ;

	if ( Kn_SegtypAno != 0 )
		n_EcrireAno( 5, Kn_SegtypAno ) ;

	if ( Kn_SegAno != 0 )
		n_EcrireAno( 6, Kn_SegAno ) ;

	if ( Kn_NbrChampsAno != 0 )
		n_EcrireAnoNbrChamps( Kn_NbrChampsAno ) ;

	if ( n_CloseFileAppl( "ESTF0004_I1", &( bd_RuptCtrGro.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTF0004_O1", &Kp_OutputFilAno ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTF0004_O2", &Kp_OutputFilTctAno ) == ERR )
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
int n_InitCtrGro(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitCtrGro" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier */
	if ( n_OpenFileAppl( "ESTF0004_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 1 ;

	/* fonction du test de rupture de niveau 1 */
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1CtrGro ;

	/* Fonction lancee en rupture premiere */
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptCtrGro ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneCtrGro ;

	/* Fonction lancee en rupture derniere */
	pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptCtrGro ;

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
int n_IsR1CtrGro(
	char **pbd_InRec ,  /* adresse de la ligne en avance */
	char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
	int ret ;

	DEBUT_FCT( "n_IsR1CtrGro" ) ;

	/* la ligne courante est-elle vide ? */
	if ( pbd_InRec_Cur[0][0] == '\r' )
	{
		Ks_LigneCourVide = 1 ;
		RETURN_VAL( 1 ) ;
	}
	else
		Ks_LigneCourVide = 0 ;

	/* la ligne suivante est-elle vide ? */
	if ( pbd_InRec[0][0] == '\r' )
	{
		Ks_LigneSuivVide = 1 ;
		RETURN_VAL( 1 ) ;
	}
	else
		Ks_LigneSuivVide = 0 ;

	if ( ( ret = strcmp( pbd_InRec[CTRGRO_CTR_NF], pbd_InRec_Cur[CTRGRO_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[CTRGRO_END_NT], pbd_InRec_Cur[CTRGRO_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[CTRGRO_SEC_NF], pbd_InRec_Cur[CTRGRO_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[CTRGRO_SSD_CF], pbd_InRec_Cur[CTRGRO_SSD_CF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[CTRGRO_SEGTYP_CT], pbd_InRec_Cur[CTRGRO_SEGTYP_CT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[CTRGRO_SEG_NF], pbd_InRec_Cur[CTRGRO_SEG_NF] ) ) != 0 ) return ret ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture premiere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRuptCtrGro( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionFirstRuptCtrGro" ) ;

	/* si la ligne est vide, on sort sans traitement */
	if ( Ks_LigneCourVide == 1 )
	{
		RETURN_VAL( OK ) ;
	}

	/* initialisation des compteurs de doublons */
	Kn_Doublons = 0 ;

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneCtrGro( char **ptb_InRec_Cur )
{
	char *p_EoL ;

	DEBUT_FCT( "n_ActionLigneCtrGro" ) ;

	/* si la ligne courante est vide, on sort sans traitement */
	if ( Ks_LigneCourVide == 1 )
	{
		RETURN_VAL( OK ) ;
	}

	/* On ecrase le caractere de fin de ligne par un zero */
	p_EoL = memchr( ptb_InRec_Cur[0], '\r', MAX_LINESIZE ) ;
	if ( p_EoL != NULL )
		*p_EoL = 0 ;

	/* Calcul du nombre de doublons sur la cle de rupture */
	Kn_Doublons += 1 ;

	/* Verification du nombre de champs a 6 */
	if ( n_NbrChamps( ptb_InRec_Cur ) == FALSE )
	{
		Kn_NbrChampsAno += 1 ;

		/* on sort directement sans faire les tests suivants */
		RETURN_VAL( OK ) ;
	}

	/* Controle du champs CTR_NF: char(9) et obligatoire */
	if ( *ptb_InRec_Cur[CTRGRO_CTR_NF] == 0 || strlen( ptb_InRec_Cur[CTRGRO_CTR_NF] ) != 9 )
		Kn_CtrAno += 1 ;

	/* Controle du champs END_NT: int et obligatoire */
	if ( *ptb_InRec_Cur[CTRGRO_END_NT] == 0 || n_IsInteger( ptb_InRec_Cur[CTRGRO_END_NT] ) == FALSE )
		Kn_EndAno += 1 ;

	/* Controle du champs SEC_NF: int et obligatoire */
	if ( *ptb_InRec_Cur[CTRGRO_SEC_NF] == 0 || n_IsInteger( ptb_InRec_Cur[CTRGRO_SEC_NF] ) == FALSE )
		Kn_SecAno += 1 ;

	/* Controle du champs SSD_CF: int et obligatoire */
	if ( *ptb_InRec_Cur[CTRGRO_SSD_CF] == 0 || n_IsInteger( ptb_InRec_Cur[CTRGRO_SSD_CF] ) == FALSE )
		Kn_SsdAno += 1 ;

	/* Controle du champs SEGTYP_CT: char(1) et obligatoire */
	if ( *ptb_InRec_Cur[CTRGRO_SEGTYP_CT] == 0 || strlen( ptb_InRec_Cur[CTRGRO_SEGTYP_CT] ) != 1 )
		Kn_SegtypAno += 1 ;

	/* Controle du champs SEG_NF: char(8) est obligatoire -- sauf NY : 10 caracteres */
        if ( atoi(ptb_InRec_Cur[CTRGRO_SSD_CF]) == 10)
             {
	      if ( *ptb_InRec_Cur[CTRGRO_SEG_NF] == 0 || strlen( ptb_InRec_Cur[CTRGRO_SEG_NF] ) <= 0 || strlen( ptb_InRec_Cur[CTRGRO_SEG_NF] ) > 10 )
		Kn_SegAno += 1 ;
             }
        else  if ( *ptb_InRec_Cur[CTRGRO_SEG_NF] == 0 || strlen( ptb_InRec_Cur[CTRGRO_SEG_NF] ) <= 0 || strlen( ptb_InRec_Cur[CTRGRO_SEG_NF] ) > 8 )
		Kn_SegAno += 1 ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture derniere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptCtrGro( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionLastRuptCtrGro" ) ;

	/* si la ligne est vide, on sort sans traitement */
	if ( Ks_LigneCourVide == 1 )
	{
		RETURN_VAL( OK ) ;
	}

	/* Ecriture en sortie du fichier des anomalies ( doublons sur la cle ) */
	if ( Kn_Doublons > 1 )
	{

		fprintf( Kp_OutputFilAno, "%s~%s~%s : %d %s %s/%s/%s/%s/%s/%s~%s\n",
			Ksz_Usr,
			Ksz_LogTyp,
			Ksz_CtrGro_Typ,
			Kn_Doublons,
			Ksz_Dupkey_Msg,
			ptb_InRec_Cur[CTRGRO_CTR_NF],
			ptb_InRec_Cur[CTRGRO_END_NT],
			ptb_InRec_Cur[CTRGRO_SEC_NF],
			ptb_InRec_Cur[CTRGRO_SSD_CF],
			ptb_InRec_Cur[CTRGRO_SEGTYP_CT],
			ptb_InRec_Cur[CTRGRO_SEG_NF],
			Ksz_Date ) ;

		fprintf( Kp_OutputFilTctAno, "%s~%s~%s~%s~%s~%s~%s~%s~%s\n",
			ptb_InRec_Cur[CTRGRO_CTR_NF],
			ptb_InRec_Cur[CTRGRO_END_NT],
			ptb_InRec_Cur[CTRGRO_SEC_NF],
			Ksz_VrsNf,
			ptb_InRec_Cur[CTRGRO_SSD_CF],
			Ksz_SegTypCT,
			ptb_InRec_Cur[CTRGRO_SEG_NF],
			"100",          // ANo CT ?? Quel Code ?
			"0") ;

       }


	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction de controle d'un champs numerique

retour :	TRUE ---> le champs est de type numerique
		FALSE --> le champs n'est pas de type numerique
==============================================================================*/
int n_IsInteger( char *sz_Champs )
{
	int i ;

	for( i = 0; sz_Champs[i] != 0;  i++ )
	{
		if ( sz_Champs[i] > '9' || sz_Champs[i] < '0' )
			return( FALSE ) ;
	}

	return( TRUE ) ;
}


/*==============================================================================
objet :
	fonction d'ecriture dans le fichier des anomalies ( message d'anomalie
sur la colonne passee en argument

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_EcrireAno( int Col, int NbrAno )
{
	/* Ecriture en sortie du fichier des anomalies */
	fprintf( Kp_OutputFilAno, "%s~%s~%s : %s %d : %d %s~%s\n",
		Ksz_Usr,
		Ksz_LogTyp,
		Ksz_CtrGro_Typ,
		Ksz_Col_Msg,
		Col,
		NbrAno,
		Ksz_Format_Msg,
		Ksz_Date ) ;

	return( 0 ) ;
}


/*==============================================================================
objet :
	fonction de verification du nombre de champs de la ligne courante

retour :	TRUE si le nombre de champs est 6
		FALSE si different
==============================================================================*/
int n_NbrChamps( char **pbd_InRec_Cur )
{

	/* test sur le dernier champs */
	if ( pbd_InRec_Cur[CTRGRO_SEG_NF] == NULL )
		return( FALSE ) ;
	else
	{
		/* test sur le suivant */
		if ( pbd_InRec_Cur[CTRGRO_SEG_NF + 1] == NULL )
			return( TRUE ) ;
		else	return( FALSE ) ;
	}
}


/*==============================================================================
objet :
	fonction d'ecriture dans le fichier des anomalies liees au nombre
de champs de l'enregistrement

retour :	0
==============================================================================*/
int n_EcrireAnoNbrChamps( int NbrAno )
{
	/* Ecriture en sortie du fichier des anomalies */
	fprintf( Kp_OutputFilAno, "%s~%s~%s : %d %s~%s\n",
		Ksz_Usr,
		Ksz_LogTyp,
		Ksz_CtrGro_Typ,
		NbrAno,
		Ksz_Nbenr_Msg,
		Ksz_Date ) ;

	return( 0 ) ;
}





