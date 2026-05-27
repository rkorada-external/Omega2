/*==============================================================================
nom de l'application          : ESTIMATION
nom du source                 : ESTF0002.c
revision                      : $Revision: 1.2 $
date de creation              : 02/04/1998
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
	CONTROLE DE DOUBLONS ET DE COHERENCES SUR LE FICHIER EN ENTREE ISSUE
DE L'IBNR TOOL, POUR CHARGEMENT DE TLABOCY

------------------------------------------------------------------------------
historique des modifications :
<jj/mm/aaaa> <auteur>  <description de la modification>
 21/06/1999 Yves B.     Le champ SEG_NF ne doit pas depasser 8 caracteres
                        sauf a new york (10 caracteres)
 27/03/2008 J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
 06/04/2014 JBG         :spot:25773 Modify void main declaration to int main
 11/05/2017 Florent     :spira:58025 ajout de la version de la segmentation
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
#define LABOCY_VRS_NF   0
#define LABOCY_SSD_CF		1
#define LABOCY_SEGTYP_CT	2
#define LABOCY_SEG_NF		3
#define LABOCY_UWY_NF		4
#define LABOCY_CRE_D		5
#define LABOCY_OCCYEA_NF	6
#define LABOCY_SPIRAT_R		7

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE 		*Kp_OutputFilAno ; 	/* pointeur sur le fichier de sortie des anomalies */

T_RUPTURE_VAR  	bd_RuptLabOcy ; 	/* variable de gestion de la rupture sur le fichier en entree */

char	Ksz_Usr[5] ;			/* parametre correspondant au code utilisateur */
char	Ksz_LabOcy_Typ[2] ;		/* parametre correspondant au type du fichier entree */
char	Ksz_Date[30] ;			/* parametre correspondant a la date de traitement */
char	Ksz_LogTyp[2] ;			/* parametre correspondant au type de message */
char	Ksz_Format_Msg[50] ;		/* parametre correspondant au message d'ano pour les formats */
char	Ksz_Dupkey_Msg[50] ;		/* parametre correspondant au message d'ano pour les doublons */
char	Ksz_Row_Msg[20] ;		/* parametre */
char	Ksz_Col_Msg[20] ;		/* parametre */
char	Ksz_Nbenr_Msg[50] ;		/* parametre correspondant au message d'ano pour le nombre de champs */

int Kn_Doublons ;			/* nombre de doublons sur la cle de rupture */
int	Kn_NbrChampsAno ;		/* nombre d'anomalies sur le nombre de champs */
int	Kn_SsdAno ;			/* nombre d'anomalies sur le champs SSD_CF */
int	Kn_SegtypAno ;			/* nombre d'anomalies sur le champs SEGTYP_CT */
int	Kn_SegAno ; 			/* nombre d'anomalies sur le champs SEG_NF */
int	Kn_UwyAno ;			/* nombre d'anomalies sur le champs UWY_NF */
int	Kn_OccYeaAno ;			/* nombre d'anomalies sur le champs OCCYEA_NF */
int	Kn_SpiRatAno ;			/* nombre d'anomalies sur le champs SPIRAT_R */

short Ks_LigneCourVide ;		/* variable correspondant a l'indication "ligne courante vide ?" */
short Ks_LigneSuivVide ;		/* variable correspondant a l'indication "ligne suivante vide ?" */

int n_InitLabOcy	 	( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_IsR1LabOcy		( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_ActionFirstRuptLabOcy	( char **pbd_InRec_Cur ) ;
int n_ActionLigneLabOcy		( char **pbd_InRec_Cur ) ;
int n_ActionLastRuptLabOcy	( char **pbd_InRec_Cur ) ;

int n_IsInteger( char *sz_Champs ) ;
int n_IsNumeric( char *sz_Champs, int n_ent, int n_dec ) ;
int n_EcrireAnoFormat( int Col, int NbrAno ) ;
int n_EcrireAnoNbrChamps( int NbrAno ) ;
int n_NbrChamps( char **pbd_InRec_Cur ) ;


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
	strcpy( Ksz_LabOcy_Typ, psz_GetCharArgv( 2 ) ) ;
	strcpy( Ksz_Date, psz_GetCharArgv( 3 ) ) ;
	strcpy( Ksz_LogTyp, psz_GetCharArgv( 4 ) ) ;
	strcpy( Ksz_Format_Msg, psz_GetCharArgv( 5 ) ) ;
	strcpy( Ksz_Dupkey_Msg, psz_GetCharArgv( 6 ) ) ;
	strcpy( Ksz_Row_Msg, psz_GetCharArgv( 7 ) ) ;
	strcpy( Ksz_Col_Msg, psz_GetCharArgv( 8 ) ) ;
	strcpy( Ksz_Nbenr_Msg, psz_GetCharArgv( 9 ) ) ;

	/* ouverture du fichier de sortie des anomalies */
	if ( n_OpenFileAppl ( "ESTF0002_O1", "wt", &Kp_OutputFilAno ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptLabOcy */
	if ( n_InitLabOcy( &bd_RuptLabOcy ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation des compteurs d'anomalies sur les formats */
	Kn_SsdAno = 0 ;
	Kn_SegtypAno = 0 ;
	Kn_SegAno = 0 ;
	Kn_UwyAno = 0 ;
	Kn_OccYeaAno = 0 ;
	Kn_SpiRatAno = 0 ;
	Kn_NbrChampsAno = 0 ;

	/* initialisation des variables "ligne vide ?" */
	Ks_LigneCourVide = 0 ;
	Ks_LigneSuivVide = 0 ;

	/* lancement du traitement */
	if ( n_ProcessingRuptureVar( &bd_RuptLabOcy ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Ecriture en sortie du fichier des anomalies ( formats incorrects ) */
	if ( Kn_SsdAno != 0 )
		n_EcrireAnoFormat( LABOCY_SSD_CF, Kn_SsdAno ) ;

	if ( Kn_SegtypAno != 0 )
		n_EcrireAnoFormat( LABOCY_SEGTYP_CT, Kn_SegtypAno ) ;

	if ( Kn_SegAno != 0 )
		n_EcrireAnoFormat( LABOCY_SEG_NF, Kn_SegAno ) ;

	if ( Kn_UwyAno != 0 )
		n_EcrireAnoFormat( LABOCY_UWY_NF, Kn_UwyAno ) ;

	if ( Kn_OccYeaAno != 0 )
		n_EcrireAnoFormat( LABOCY_OCCYEA_NF, Kn_OccYeaAno ) ;

	if ( Kn_SpiRatAno != 0 )
		n_EcrireAnoFormat( LABOCY_SPIRAT_R, Kn_SpiRatAno ) ;

	if ( Kn_NbrChampsAno != 0 )
		n_EcrireAnoNbrChamps( Kn_NbrChampsAno ) ;

	if ( n_CloseFileAppl( "ESTF0002_I1", &( bd_RuptLabOcy.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTF0002_O1", &Kp_OutputFilAno ) == ERR )
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
int n_InitLabOcy(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitLabOcy" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier */
	if ( n_OpenFileAppl( "ESTF0002_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 1 ;

	/* fonction du test de rupture de niveau 1 */
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1LabOcy ;

	/* Fonction lancee en rupture premiere */
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptLabOcy ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneLabOcy ;

	/* Fonction lancee en rupture derniere */
	pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptLabOcy ;

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
int n_IsR1LabOcy(
  char **pbd_InRec ,  /* adresse de la ligne en avance */
  char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
	int ret ;

	DEBUT_FCT( "n_IsR1LabOcy" ) ;

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

	if ( ( ret = strcmp( pbd_InRec[LABOCY_VRS_NF], pbd_InRec_Cur[LABOCY_VRS_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[LABOCY_SSD_CF], pbd_InRec_Cur[LABOCY_SSD_CF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[LABOCY_SEGTYP_CT], pbd_InRec_Cur[LABOCY_SEGTYP_CT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[LABOCY_SEG_NF], pbd_InRec_Cur[LABOCY_SEG_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[LABOCY_UWY_NF], pbd_InRec_Cur[LABOCY_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[LABOCY_OCCYEA_NF], pbd_InRec_Cur[LABOCY_OCCYEA_NF] ) ) != 0 ) return ret ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture premiere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRuptLabOcy( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionFirstRuptLabOcy" ) ;

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
int n_ActionLigneLabOcy( char **ptb_InRec_Cur )
{
	char *p_EoL ;

	DEBUT_FCT( "n_ActionLigneLabOcy" ) ;

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

	/* Controle du champs SSD_CF: int et obligatoire */
	if ( *ptb_InRec_Cur[LABOCY_SSD_CF] == 0 || n_IsInteger( ptb_InRec_Cur[LABOCY_SSD_CF] ) == FALSE )
		Kn_SsdAno += 1 ;

	/* Controle du champs SEGTYP_CT: char(1) et obligatoire */
	if ( *ptb_InRec_Cur[LABOCY_SEGTYP_CT] == 0 || strlen( ptb_InRec_Cur[LABOCY_SEGTYP_CT] ) != 1 )
		Kn_SegtypAno += 1 ;

	/* Controle du champs SEG_NF: char(10) et obligatoire */
	if ( atoi(ptb_InRec_Cur[LABOCY_SSD_CF]) == 10)
	{
		if ( *ptb_InRec_Cur[LABOCY_SEG_NF] == 0 || strlen( ptb_InRec_Cur[LABOCY_SEG_NF] ) <= 0 || strlen( ptb_InRec_Cur[LABOCY_SEG_NF] ) > 10 )
			Kn_SegAno += 1 ;
	}
	else  if ( *ptb_InRec_Cur[LABOCY_SEG_NF] == 0 || strlen( ptb_InRec_Cur[LABOCY_SEG_NF] ) <= 0 || strlen( ptb_InRec_Cur[LABOCY_SEG_NF] ) > 8 )
		Kn_SegAno += 1 ;

	/* Controle du champs UWY_NF: int et obligatoire */
	if ( *ptb_InRec_Cur[LABOCY_UWY_NF] == 0 || n_IsInteger( ptb_InRec_Cur[LABOCY_UWY_NF] ) == FALSE )
		Kn_UwyAno += 1 ;

	/* Controle du champs OCCYEA_NF: int et obligatoire */
	if ( *ptb_InRec_Cur[LABOCY_OCCYEA_NF] == 0 || n_IsInteger( ptb_InRec_Cur[LABOCY_OCCYEA_NF] ) == FALSE )
		Kn_OccYeaAno += 1 ;

	/* Controle du champs SPIRAT_R: decimal(9.8) et obligatoire */
	if ( *ptb_InRec_Cur[LABOCY_SPIRAT_R] == 0 || n_IsNumeric( ptb_InRec_Cur[LABOCY_SPIRAT_R], 1, 8 ) == FALSE )
		Kn_SpiRatAno += 1 ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture derniere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptLabOcy( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionLastRuptLabOcy" ) ;

	/* si la ligne est vide, on sort sans traitement */
	if ( Ks_LigneCourVide == 1 )
	{
		RETURN_VAL( OK ) ;
	}

	/* Ecriture en sortie du fichier des anomalies ( doublons sur la cle ) */
	if ( Kn_Doublons > 1 )
		fprintf( Kp_OutputFilAno, "%s~%s~%s : %d %s %s/%s/%s/%s/%s/%s~%s\n",
		         Ksz_Usr,
		         Ksz_LogTyp,
		         Ksz_LabOcy_Typ,
		         Kn_Doublons,
		         Ksz_Dupkey_Msg,
		         ptb_InRec_Cur[LABOCY_VRS_NF],
		         ptb_InRec_Cur[LABOCY_SSD_CF],
		         ptb_InRec_Cur[LABOCY_SEGTYP_CT],
		         ptb_InRec_Cur[LABOCY_SEG_NF],
		         ptb_InRec_Cur[LABOCY_UWY_NF],
		         ptb_InRec_Cur[LABOCY_OCCYEA_NF],
		         Ksz_Date ) ;

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

	for ( i = 0; sz_Champs[i] != 0;  i++ )
	{
		if ( sz_Champs[i] > '9' || sz_Champs[i] < '0' )
			return ( FALSE ) ;
	}

	return ( TRUE ) ;
}


/*==============================================================================
objet :
	fonction de controle d'un champs de type decimal(18.3)

arguments:
	- champs a verifier
	- longueur maxi de la partie entiere
	- longueur maxi de la partie decimal

retour :	TRUE ---> le champs est de type decimal(18.3)
		FALSE --> le champs n'est pas de type decimal(18.3)
==============================================================================*/
int n_IsNumeric( char *sz_Champs, int n_ent, int n_dec )
{
	int i ;
	int n_PointLu = FALSE ;
	int n_LgEntiere = 0 ;
	int n_LgDec = 0 ;

	/* 1er cas: le premier caractere est un signe ( '+' ou '-' ) */
	if ( sz_Champs[0] == '+' || sz_Champs[0] == '-' )
	{
		for ( i = 1; sz_Champs[i] != 0;  i++ )
		{
			if ( sz_Champs[i] == '.' )
			{
				if ( n_PointLu == TRUE )
					return ( FALSE ) ;
				else	n_PointLu = TRUE ;
			}
			else
			{
				/* test sur la numericite du caractere */
				if ( sz_Champs[i] > '9' || sz_Champs[i] < '0' )
					return ( FALSE ) ;
				else
				{
					if ( n_PointLu == TRUE )
						n_LgDec += 1 ;
					else	n_LgEntiere += 1 ;
				}
			}
		}
	}

	/* 2eme cas: le premier caractere n'est pas un signe ( '+' ou '-' ) */
	else
	{
		for ( i = 0; sz_Champs[i] != 0;  i++ )
		{
			if ( sz_Champs[i] == '.' )
			{
				if ( n_PointLu == TRUE )
					return ( FALSE ) ;
				else	n_PointLu = TRUE ;
			}
			else
			{
				/* test sur la numericite du caractere */
				if ( sz_Champs[i] > '9' || sz_Champs[i] < '0' )
					return ( FALSE ) ;
				else
				{
					if ( n_PointLu == TRUE )
						n_LgDec += 1 ;
					else	n_LgEntiere += 1 ;
				}
			}
		}
	}

	/* test sur la longueur de la partie entiere */
	if ( n_LgEntiere > n_ent )
		return ( FALSE ) ;

	/* test sur la longueur de la partie decimale */
	if ( n_LgDec > n_dec )
		return ( FALSE ) ;

	return ( TRUE ) ;
}


/*==============================================================================
objet :
	fonction d'ecriture dans le fichier des anomalies liees au format
des champs ( message d'anomalie sur la colonne passee en argument )

retour :	0
==============================================================================*/
int n_EcrireAnoFormat( int Col, int NbrAno )
{
	/* Ecriture en sortie du fichier des anomalies */
	fprintf( Kp_OutputFilAno, "%s~%s~%s : %s %d : %d %s~%s\n",
	         Ksz_Usr,
	         Ksz_LogTyp,
	         Ksz_LabOcy_Typ,
	         Ksz_Col_Msg,
	         Col,
	         NbrAno,
	         Ksz_Format_Msg,
	         Ksz_Date ) ;

	return ( 0 ) ;
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
	         Ksz_LabOcy_Typ,
	         NbrAno,
	         Ksz_Nbenr_Msg,
	         Ksz_Date ) ;

	return ( 0 ) ;
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
	if ( pbd_InRec_Cur[LABOCY_SPIRAT_R] == NULL )
		return ( FALSE ) ;
	else
	{
		/* test sur le suivant */
		if ( pbd_InRec_Cur[LABOCY_SPIRAT_R + 1] == NULL )
			return ( TRUE ) ;
		else	return ( FALSE ) ;
	}
}
