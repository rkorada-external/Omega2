/*==============================================================================
nom de l'application          : ESTIMATION (ecriture post omega)
nom du source                 : ESPO1001.c
révision                      : $Revision: 1.1.1.1 $
date de création              : 06/10/1998
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
  Pour charger Omega SAR fichier FCTRSTAT
   	Introduction des postes cumuls, conversions en monnaie aliment, etc...

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
[002] 13/07/2012 Dch - R. Cassis   :spot:23802  Ajout champ PRS_CF dans Synchro pour Solvency
[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main
[004] 19/03/2018 R. Cassis  :spira:67929 Agrandissement du tableau de la ttrslnk de 2000 à 10000
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
//[004]
#define MAX_POSTE	10000
#define INT(a) (((int)(a)-(int)('0')))

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE 		*Kp_OutputFil ; 	/* pointeur sur le fichier de sortie */
FILE 		*Kp_InputFilCurquot ; 	/* pointeur sur le fichier en entree des cours de change */
FILE 		*Kp_InputFilTrsLnk ; 	/* pointeur sur le fichier en entree des postes cumuls */
FILE 		*Kp_Dettrs;


T_RUPTURE_VAR  	   	bd_RuptPer ; 	/* variable de gestion de la rupture sur le perimetre */
T_RUPTURE_SYNC_VAR 	bd_RuptTotGta ; /* variable de gestion de la synchronisation avec le fichier TOTGTAA */
T_RUPTURE_SYNC_VAR 	bd_RuptUndSta ; /* variable de gestion de la synchronisation avec le fichier FUNDSTA */


T_TRSLNK 	Ktbd_TrsLnk[MAX_POSTE] ;
int 		Kn_NbLigTrslnk ;

int		Kn_Acy ;		/* Annee dernier compte complet */
unsigned char	Kc_ScoEndMth ;		/* Mois dernier compte complet */
unsigned int	Kn_Periode ;		/* Kc_ScoEndMth * 100 + Kn_Acy */

int n_InitPer	 		( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLignePer		( char **pbd_InRec_Cur ) ;
int n_ActionF1Per   		( char **pbd_InRec_Cur ) ;
int n_IsR1Per                   ( char **pbd_InRec, char **pbd_InRec_Cur ) ;

int n_InitTotGta		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneTotGta		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncTotGta	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitUndSta		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneUndSta		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncUndSta	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;


int n_ProcessingRuptureSyncVar (
			T_RUPTURE_SYNC_VAR  *pbd_Rupt,
			char **ptb_InRecOwner );

int n_ChargerTRSLNK ( short s_TrtCod ) ;
int n_RechPoste(char *sz_poste) ;
int n_TypePoste(char *sz_poste, FILE *) ;


int n_InitVariables( void );


char Ksz_AnneeBilan[5];

double		Kd_CaccPrm ;	/* variable de travail */
double		Kd_CaccEpp ;	/* variable de travail */
double		Kd_CaccRpp ;	/* variable de travail */
double		Kd_CaccPna ;	/* variable de travail */
double		Kd_CaccResPrm ;	/* variable de travail */
double		Kd_CaccRpccp ;	/* variable de travail */
double		Kd_CaccLoa ;	/* variable de travail */
double		Kd_CaccBrk ;	/* variable de travail */
double		Kd_CaccFar ;	/* variable de travail */
double		Kd_CaccFar2 ;	/* variable de travail */
double		Kd_CaccSp ;	/* variable de travail */
double		Kd_CaccEps ;	/* variable de travail */
double		Kd_CaccRps ;	/* variable de travail */
double		Kd_CaccSap ;	/* variable de travail */
double		Kd_CaccPbPap ;	/* variable de travail */
double		Kd_CaccLoss ;	/* variable de travail */
double		Kd_CaccSnem ;	/* variable de travail */
double		Kd_CaccRpccs ;	/* variable de travail */
double		Kd_CaccResn ;	/* variable de travail */
double		Kd_CaccRes ;	/* variable de travail */
double		Kd_CaccAcr ;	/* variable de travail */

double		Kd_IaccPrm ;	/* variable de travail */
double		Kd_IaccEpp ;	/* variable de travail */
double		Kd_IaccRpp ;	/* variable de travail */
double		Kd_IaccPna ;	/* variable de travail */
double		Kd_IaccResPrm ;	/* variable de travail */
double		Kd_IaccRpccp ;	/* variable de travail */
double		Kd_IaccLoa ;	/* variable de travail */
double		Kd_IaccBrk ;	/* variable de travail */
double		Kd_IaccFar ;	/* variable de travail */
double		Kd_IaccFar2 ;	/* variable de travail */
double		Kd_IaccSp ;	/* variable de travail */
double		Kd_IaccEps ;	/* variable de travail */
double		Kd_IaccRps ;	/* variable de travail */
double		Kd_IaccSap ;	/* variable de travail */
double		Kd_IaccPbPap ;	/* variable de travail */
double		Kd_IaccLoss ;	/* variable de travail */
double		Kd_IaccSnem ;	/* variable de travail */
double		Kd_IaccRpccs ;	/* variable de travail */
double		Kd_IaccResn ;	/* variable de travail */
double		Kd_IaccRes ;	/* variable de travail */
double		Kd_IaccAcr ;	/* variable de travail */

double		Kd_EstPrm ;	/* variable de travail */
double		Kd_EstEpp ;	/* variable de travail */
double		Kd_EstRpp ;	/* variable de travail */
double		Kd_EstPna ;	/* variable de travail */
double		Kd_EstResPrm ;	/* variable de travail */
double		Kd_EstRpccp ;	/* variable de travail */
double		Kd_EstLoa ;	/* variable de travail */
double		Kd_EstBrk ;	/* variable de travail */
double		Kd_EstFar ;	/* variable de travail */
double		Kd_EstFar2 ;	/* variable de travail */
double		Kd_EstSp ;	/* variable de travail */
double		Kd_EstEps ;	/* variable de travail */
double		Kd_EstRps ;	/* variable de travail */
double		Kd_EstSap ;	/* variable de travail */
double		Kd_EstPbPap ;	/* variable de travail */
double		Kd_EstLoss ;	/* variable de travail */
double		Kd_EstSnem ;	/* variable de travail */
double		Kd_EstRpccs ;	/* variable de travail */
double		Kd_EstBlkPl ;	/* variable de travail */
double		Kd_EstBlkOsl ;	/* variable de travail */
double		Kd_EstIbnr2 ;	/* variable de travail */
double		Kd_EstResn ;	/* variable de travail */
double		Kd_EstRes ;	/* variable de travail */
double		Kd_EstAcr ;	/* variable de travail */

double		Kd_SpePrm ;	/* variable de travail */
double		Kd_SpeEpp ;	/* variable de travail */
double		Kd_SpeRpp ;	/* variable de travail */
double		Kd_SpePna ;	/* variable de travail */
double		Kd_SpeResPrm ;	/* variable de travail */
double		Kd_SpeRpccp ;	/* variable de travail */
double		Kd_SpeLoa ;	/* variable de travail */
double		Kd_SpeBrk ;	/* variable de travail */
double		Kd_SpeFar ;	/* variable de travail */
double		Kd_SpeFar2 ;	/* variable de travail */
double		Kd_SpeSp ;	/* variable de travail */
double		Kd_SpeEps ;	/* variable de travail */
double		Kd_SpeRps ;	/* variable de travail */
double		Kd_SpeSap ;	/* variable de travail */
double		Kd_SpePbPap ;	/* variable de travail */
double		Kd_SpeLoss ;	/* variable de travail */
double		Kd_SpeSnem ;	/* variable de travail */
double		Kd_SpeRpccs ;	/* variable de travail */
double		Kd_SpeBlkPl ;	/* variable de travail */
double		Kd_SpeBlkOsl ;	/* variable de travail */
double		Kd_SpeIbnr2 ;	/* variable de travail */
double		Kd_SpeResn ;	/* variable de travail */
double		Kd_SpeRes ;	/* variable de travail */
double		Kd_SpeAcr ;	/* variable de travail */

double		Kd_Amt_Max = 999999999999999.000 ;

static char Ksz_Vide[1]="";


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

	sprintf(Ksz_AnneeBilan,"%s",psz_GetCharArgv(1));


  if ( n_OpenFileAppl ( "ESPO1001_I6","rb",&Kp_Dettrs ) == ERR )
    ExitPgm ( ERR_XX , "" );

	/* ouverture du fichier en entree des cours de change FCURQUOT */
	if ( n_OpenFileAppl ( "ESPO1001_I4","rb",&Kp_InputFilCurquot ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier en entree des postes cumuls FTRSLNK */
	if ( n_OpenFileAppl ( "ESPO1001_I3","rb",&Kp_InputFilTrsLnk ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier de sortie */
	if ( n_OpenFileAppl ( "ESPO1001_O1","wt",&Kp_OutputFil ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPer */
	if ( n_InitPer( &bd_RuptPer ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptTotGta */
	if ( n_InitTotGta( &bd_RuptTotGta ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptUndSta */
	if ( n_InitUndSta( &bd_RuptUndSta ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Chargement des postes en memoire */
	Kn_NbLigTrslnk = n_ChargerTRSLNK( 713 );

        if ( Kn_NbLigTrslnk > MAX_POSTE )
        {
                 n_WriteAno( "depassement de capacite du tableau Ktbd_TrsLnk" );
                 ExitPgm( ERR_XX , "" ) ;
         }


	/* lancement du traitement du fichier maitre */
	if ( n_ProcessingRuptureVar( &bd_RuptPer ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESPO1001_I1", &( bd_RuptPer.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESPO1001_I2", &( bd_RuptTotGta.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESPO1001_I3", &Kp_InputFilTrsLnk ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESPO1001_I4", &Kp_InputFilCurquot ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESPO1001_I5", &( bd_RuptUndSta.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl ( "ESTC1005_I6",&Kp_Dettrs ) == ERR )
    ExitPgm ( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESPO1001_O1", &Kp_OutputFil ) == ERR )
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

	/* ouverture du fichier maitre */
	if ( n_OpenFileAppl( "ESPO1001_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	pbd_Rupt->n_NbRupture = 1 ;

	/* fonction d'action Rupture 1 */
	pbd_Rupt->n_ActionFirst[0] = n_ActionF1Per ;

	/* fonction d'action sur la ligne courante du fichier maitre */
	pbd_Rupt->n_ActionLigne = n_ActionLignePer ;

        /* fonction du test de rupture de niveau 1 */
        pbd_Rupt->n_ConditionRupture[0] = n_IsR1Per ;

	pbd_Rupt->c_Separ = SEPARATEUR ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
        fonction de test de rupture de niveau 1

retour :
        0       ---> pas de rupture
        sinon   ---> rupture
==============================================================================*/
int n_IsR1Per(
        char **pbd_InRec ,  /* adresse de la ligne en avance */
        char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
        int ret ;

        DEBUT_FCT( "n_IsR1Per" ) ;

        if ( ( ret = strcmp( pbd_InRec[PER_CTR_NF], pbd_InRec_Cur[PER_CTR_NF] ) ) != 0 ) return ret ;

        RETURN_VAL( 0 ) ;
}

/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionF1Per( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionLignePer" ) ;


	/* initialisation des variables */
	Kn_Periode = 0 ;

	/* synchronisation */
	n_ProcessingRuptureSyncVar( &bd_RuptUndSta, ptb_InRec_Cur ) ;

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

         /* synchronisation avec le fichier fils */
        n_ProcessingRuptureSyncVar( &bd_RuptTotGta, ptb_InRec_Cur ) ;

        RETURN_VAL( OK ) ;
}




/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l’esclave

retour :
	OK
==============================================================================*/
int n_InitTotGta( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitTotGta" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESPO1001_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncTotGta ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneTotGta ;

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
int n_ConditionSyncTotGta(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncTotGta" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GT_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GT_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneTotGta(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	char	c_TypCum = 0 ;	/* indicateur sur le type de cumul 	*/
				/* 	'C' cedante compte complet 	*/
				/* 	'I' cedante compte incomplet 	*/
				/* 	'E' estimee hors service 	*/
				/* 	'S' Service		 	*/
	int 	i ;
	long	l_AcmTrs = 0 ;	/* poste cumul */
	double	d_Taux ;	/* taux de conversion */
	double	d_Amt ;		/* montant */
	char	MsgAno[300] ;	/* message d'anomalie */
  short	n_type;
  int	n_poste;
  int 	n_oricod = 710; // prendra comme valeur soit 730 si ptb_InRecChild[GT_ORICOD_LS] == "EBSGTA", sinon 710 ( par défaut) [002]

  DEBUT_FCT( "n_ActionLigneTotGta" ) ;

  /* Récupération du type de poste ds DETTRS */
  n_type = n_TypePoste(ptb_InRecChild[GT_TRNCOD_CF],Kp_Dettrs);


  /*
  ** On ne cumule que les provisions du bilan hors L0. Les provisions sont identifiées
  ** grace au TRSTYP_CF (=3) de TDETTRS et les libérations d'ouverture à ne pas cumuler
  ** sont telles que leur suffixe=1 & TRNCOD[3-7] dans {LST}
  */
  n_poste = 10000 * INT(ptb_InRecChild[GT_TRNCOD_CF][2]) +
             1000 * INT(ptb_InRecChild[GT_TRNCOD_CF][3]) +
              100 * INT(ptb_InRecChild[GT_TRNCOD_CF][4]) +
               10 * INT(ptb_InRecChild[GT_TRNCOD_CF][5]) +
                    INT(ptb_InRecChild[GT_TRNCOD_CF][6]);

  /* MOD01 - Ajout des POSTES 10301 & 10311 */
  /* MOD02 - 10321, 10331, 10341, 10351, 14201, 42181, 42411, 42891, 45101 */
  if (
      ( *ptb_InRecOwner[PER_CTRNAT_CT] == 'P' ) ||
      ( atoi( ptb_InRecOwner[PER_NAT_CF] ) == 40 ) ||
      ( atoi( ptb_InRecOwner[PER_NAT_CF] ) == 41 ) ||
      !(
	(
	 n_type == 3 && atoi(ptb_InRecChild[GT_BALSHEY_NF]) < atoi(Ksz_AnneeBilan)
	) ||
	(
	 n_type == 3 && (
			 ptb_InRecChild[GT_TRNCOD_CF][7] == '1' ||
			 (
			  n_poste==41101 || n_poste==41901 || n_poste==42101 ||
			  n_poste==42111 || n_poste==42141 || n_poste==42151 ||
			  n_poste==42161 || n_poste==42191 || n_poste==42801 ||
			  n_poste==43101 || n_poste==43701 || n_poste==44101 ||
			  n_poste==48101 || n_poste==48111 || n_poste==48801 ||
			  n_poste==42401 || n_poste==48121 || n_poste==10301 ||
			  n_poste==10311 || n_poste==10321 || n_poste==10331 ||
			  n_poste==10341 || n_poste==10351 || n_poste==14201 ||
			  n_poste==42181 || n_poste==42411 || n_poste==42891 ||
			  n_poste==45101
			 )
			)
	)
       )
     ) {

    /* Poste service */
    /*****************/
    if ( ptb_InRecChild[GT_TRNCOD_CF][1] >= '4' )
      c_TypCum = 'S' ;


    /* On sort de la fonction si l'indicateur n'a pas ete positionne */
    /*****************************************************************/
    if ( c_TypCum == 0 )
      RETURN_VAL( OK ) ;


    /* Recherche du poste cumul */
    /****************************/
    i = n_RechPoste( ptb_InRecChild[GT_TRNCOD_CF] ) ;

    if ( i == -1 )
      RETURN_VAL( OK ) ;
    else	l_AcmTrs = Ktbd_TrsLnk[i].ACMTRS_NT ;


    /* Conversion en monnaie aliment */
    /*********************************/
    if ( strcmp( ptb_InRecOwner[PER_EGPCUR_CF], ptb_InRecChild[GT_CUR_CF] ) != 0 )
      {
	d_Taux = d_GetTaux( Kp_InputFilCurquot, (char) atoi( ptb_InRecChild[GT_SSD_CF] ),
			    atoi( ptb_InRecChild[GT_BALSHEY_NF] ), ptb_InRecChild[GT_CUR_CF], ptb_InRecOwner[PER_EGPCUR_CF] ) ;

	if ( d_Taux < 0 )
	  {
	    /* generation d'une anomalie */
	    sprintf( MsgAno, "The rates of acceptance currency ( %s ) and EGPI currency ( %s ) aren't known for the subsidiary %s in %s and for the contract ( CTR_NF %s - END_NT %s - SEC_NF %s - UWY_NF %s - UW_NT %s )\n",
		     ptb_InRecChild[GT_CUR_CF],
		     ptb_InRecOwner[PER_EGPCUR_CF],
		     ptb_InRecChild[GT_SSD_CF],
		     ptb_InRecChild[GT_BALSHEY_NF],
		     ptb_InRecChild[GT_CTR_NF],
		     ptb_InRecChild[GT_END_NT],
		     ptb_InRecChild[GT_SEC_NF],
		     ptb_InRecChild[GT_UWY_NF],
		     ptb_InRecChild[GT_UW_NT] ) ;

	    n_WriteAno( MsgAno ) ;

	    RETURN_VAL( OK ) ;
	  }
      }
    else	d_Taux = 1 ;

    d_Amt = d_Taux * atof( ptb_InRecChild[GT_AMT_M] ) ;



    /* Ecriture en sortie */
    /**********************/
    if ( d_Amt != 0 )

  /* initialisation des variables de travail */
  /*******************************************/
   n_InitVariables( ) ;
//	       l_AcmTrs,
//	       c_TypCum,
//	       d_Amt ) ;

 	/* Cumul des montants */
	switch( l_AcmTrs )
	{
	case 10000 :
			Kd_SpePrm = d_Amt ;
			break ;

	case 12000 :
			Kd_SpeResPrm += d_Amt ;
			break ;

	case 13000 :
			Kd_SpeResPrm += d_Amt ;
			break ;

	case 10020 :
			Kd_SpeEpp = d_Amt ;
			break ;

	case 10010 :
			Kd_SpeRpp = d_Amt ;
			break ;

	case 10030 :
			Kd_SpePna = d_Amt ;
			break ;

	case 19000 :
			Kd_SpeRpccp = d_Amt ;
			break ;

	case 10100 :
			Kd_SpeLoa = d_Amt ;
			break ;

	case 10130 :
			Kd_SpeFar = d_Amt ;
			break ;

	case 20000 :
			Kd_SpeSp = d_Amt ;
			break ;

	case 20020 :
			Kd_SpeEps = d_Amt ;
			break ;

	case 20010 :
			Kd_SpeRps = d_Amt ;
			break ;

	case 21000 :
			Kd_SpeLoss = d_Amt ;
			break ;

	case 20030 :
			Kd_SpeSap = d_Amt ;
			break ;

	case 26030 :
			Kd_SpeAcr = d_Amt ;
			break ;

	case 28030 :
			Kd_SpeSnem = d_Amt ;
			break ;

	case 29000 :
			Kd_SpeRpccs = d_Amt ;
			break ;

	case 25000 :
			Kd_SpeBlkPl = d_Amt ;
			break ;

	case 25030 :
			Kd_SpeBlkOsl = d_Amt ;
			break ;

	case 24030 :
			Kd_SpeIbnr2 = d_Amt ;
			break ;

	case 10400 :
			Kd_SpeBrk = d_Amt ;
			break ;

	case 10430 :
			Kd_SpeFar2 = d_Amt ;
			break ;

	case 22000 :
			Kd_SpePbPap += d_Amt ;
			break ;

	case 23000 :
			Kd_SpePbPap += d_Amt ;
			break ;
	}

	/* calcul des champs cumules */
	/*****************************/
	Kd_CaccResn = Kd_CaccPrm + Kd_CaccEpp + Kd_CaccRpp + Kd_CaccPna +
		Kd_CaccResPrm + Kd_CaccRpccp + Kd_CaccLoa + Kd_CaccFar +
		Kd_CaccSp + Kd_CaccEps + Kd_CaccRps + Kd_CaccSap +
		Kd_CaccLoss + Kd_CaccAcr + Kd_CaccSnem + Kd_CaccRpccs ;
	Kd_CaccRes = Kd_CaccResn + Kd_CaccBrk + Kd_CaccFar2 + Kd_CaccPbPap ;

	Kd_IaccResn = Kd_IaccPrm + Kd_IaccEpp + Kd_IaccRpp + Kd_IaccPna +
		Kd_IaccResPrm + Kd_IaccRpccp + Kd_IaccLoa + Kd_IaccFar +
		Kd_IaccSp + Kd_IaccEps + Kd_IaccRps + Kd_IaccSap +
		Kd_IaccLoss + Kd_IaccAcr + Kd_IaccSnem + Kd_IaccRpccs ;
	Kd_IaccRes = Kd_IaccResn + Kd_IaccBrk + Kd_IaccFar2 + Kd_IaccPbPap ;

	Kd_EstResn = Kd_EstPrm + Kd_EstEpp + Kd_EstRpp + Kd_EstPna +
		Kd_EstResPrm + Kd_EstRpccp + Kd_EstLoa + Kd_EstFar +
		Kd_EstSp + Kd_EstEps + Kd_EstRps + Kd_EstSap +
		Kd_EstLoss + Kd_EstAcr + Kd_EstSnem + Kd_EstRpccs +
		Kd_EstBlkPl + Kd_EstBlkOsl + Kd_EstIbnr2 ;
	Kd_EstRes = Kd_EstResn + Kd_EstBrk + Kd_EstFar2 + Kd_EstPbPap ;

	Kd_SpeResn = Kd_SpePrm + Kd_SpeEpp + Kd_SpeRpp + Kd_SpePna +
		Kd_SpeResPrm + Kd_SpeRpccp + Kd_SpeLoa + Kd_SpeFar +
		Kd_SpeSp + Kd_SpeEps + Kd_SpeRps + Kd_SpeSap +
		Kd_SpeLoss + Kd_SpeAcr + Kd_SpeSnem + Kd_SpeRpccs +
		Kd_SpeBlkPl + Kd_SpeBlkOsl + Kd_SpeIbnr2 ;
	Kd_SpeRes = Kd_SpeResn + Kd_SpeBrk + Kd_SpeFar2 + Kd_SpePbPap ;
	
	if (strcmp(ptb_InRecChild[GT_ORICOD_LS], "EBSGTA")==0)
	{
		// on modifie la valeur par défaut pour le prs_cf [002]
		n_oricod = 730;
	}

	/* ecriture en sortie au format de TCTRSTAT */
	/********************************************/
	fprintf( Kp_OutputFil, "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%s~%s~%s~%s~%s~%s~%s~%s~%s~%d\n",
		ptb_InRecChild[GT_CTR_NF],                 //  ptb_InRec_Cur[CTRSTAT_CTR_NF],
		ptb_InRecChild[GT_END_NT],                 //  ptb_InRec_Cur[CTRSTAT_END_NT],
		ptb_InRecChild[GT_SEC_NF],                 //  ptb_InRec_Cur[CTRSTAT_SEC_NF],
		ptb_InRecChild[GT_UWY_NF],                 //  ptb_InRec_Cur[CTRSTAT_UWY_NF],
		ptb_InRecChild[GT_UW_NT],                //  ptb_InRec_Cur[CTRSTAT_UW_NT],

		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_SSD_CF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ESB_CF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_SECINC_D],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_EXP_D],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_DIFMTH_NF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_CTRNAT_CT],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_CTRRET_B],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_SECSTS_CT],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_LOB_CF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_TOP_CF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_SOB_CF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_PRDCOD_CT],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_NAT_CF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_GAR_CF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_DIV_NT],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_PCPRSKTRY_CF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_USRCRTCOD_CT],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_USRCRTVAL_LM],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_SECQUA_CF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_SECQUA2_CF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_SECQUA3_CF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_SECQUA4_CF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_SECQUA5_CF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_WRKCAT_CT],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_UWGRP_CF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ADMGRP_CF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_UWORG_CF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ANLCTY_NF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_CED_NF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ORGCED_NF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_PRD_NF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_REITYP_CF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ACCADMTYP_CF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_SECACCSTS_CT],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ACCFRQ_CT],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_CMPACCPER_NF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_LSTCEDPER_NF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_PRMPRTSCL_B],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ERNPRMADM_B],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_INSPOL_R],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_POLDURMTH_NF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_COMTYP_CT],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_COM_R],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_MINCOM_R],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_OVRCOM_R],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_TAX_R],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_BRK_R],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_REIEXI_B],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_REIFRE_B],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_PRFCOMEXI_B],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_LOSCTBEXI_B],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_LOSCOREXI_B],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_CBIRETCED_R],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_PBIRETCED_R],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_CBERETCED_R],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_PBERETCED_R],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_EGPCUR_CF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_SBJPRM_M],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_SBJPRMCPT_M],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_SBJCPTDEF_B],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_SCOSHA_R],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_PMLRAT_R],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_SCOEGP_M],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_QUOT_CT],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_PRMFINEFF_R],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_PRMMAXEFF_R],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_PRMFINACT_R],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_PRMMAXACT_R],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_CLMPRMACT_R],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_PRMPRT_M],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_EGPRPCC_M],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_CALAMTPRM_M],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ENTAMTPRM_M],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_RETAMTPRM_M],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ADMMODPRM_CT],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_CALAMTCLM_M],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ENTAMTCLM_M],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_RETAMTCLM_M],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ADMMODCLM_CT],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_RESPRM_M],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ULTPMLRAT_R],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ULTCRE_D],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ULTORICOD_LS],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ULTUPDUSR_CF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_FLAPRM_M],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_PRVPRM_M],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_LAYCAP_M],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ESTVRS_NF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ESTSEG_NF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ESTCUR_CF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ESTAMORAT_CT],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ESTPRMAMT_M],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ESTCLMAMT_M],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ESTLOSRAT_R],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ACTVRS_NF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ACTSEG_NF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ACTCUR_CF],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ACTAMORAT_CT],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ACTPRMAMT_M],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ACTCLMAMT_M],
		Ksz_Vide,                      //ptb_InRec_Cur[CTRSTAT_ACTLOSRAT_R],
		Kd_CaccPrm,
		Kd_CaccEpp,
		Kd_CaccRpp,
		Kd_CaccPna,
		Kd_CaccResPrm,
		Kd_CaccRpccp,
		Kd_CaccLoa,
		Kd_CaccBrk,
		Kd_CaccFar,
		Kd_CaccFar2,
		Kd_CaccSp,
		Kd_CaccEps,
		Kd_CaccRps,
		Kd_CaccSap,
		Kd_CaccPbPap,
		Kd_CaccLoss,
		Kd_CaccSnem,
		Kd_CaccRpccs,
		Kd_CaccResn,
		Kd_CaccRes,
		Kd_CaccAcr,
		Kd_IaccPrm,
		Kd_IaccEpp,
		Kd_IaccRpp,
		Kd_IaccPna,
		Kd_IaccResPrm,
		Kd_IaccRpccp,
		Kd_IaccLoa,
		Kd_IaccBrk,
		Kd_IaccFar,
		Kd_IaccFar2,
		Kd_IaccSp,
		Kd_IaccEps,
		Kd_IaccRps,
		Kd_IaccSap,
		Kd_IaccPbPap,
		Kd_IaccLoss,
		Kd_IaccSnem,
		Kd_IaccRpccs,
		Kd_IaccResn,
		Kd_IaccRes,
		Kd_IaccAcr,
		Kd_EstPrm,
		Kd_EstEpp,
		Kd_EstRpp,
		Kd_EstPna,
		Kd_EstResPrm,
		Kd_EstRpccp,
		Kd_EstLoa,
		Kd_EstBrk,
		Kd_EstFar,
		Kd_EstFar2,
		Kd_EstSp,
		Kd_EstEps,
		Kd_EstRps,
		Kd_EstSap,
		Kd_EstPbPap,
		Kd_EstLoss,
		Kd_EstSnem,
		Kd_EstRpccs,
		Kd_EstBlkPl,
		Kd_EstBlkOsl,
		Kd_EstIbnr2,
		Kd_EstResn,
		Kd_EstRes,
		Kd_EstAcr,
		Kd_SpePrm,
		Kd_SpeEpp,
		Kd_SpeRpp,
		Kd_SpePna,
		Kd_SpeResPrm,
		Kd_SpeRpccp,
		Kd_SpeLoa,
		Kd_SpeBrk,
		Kd_SpeFar,
		Kd_SpeFar2,
		Kd_SpeSp,
		Kd_SpeEps,
		Kd_SpeRps,
		Kd_SpeSap,
		Kd_SpePbPap,
		Kd_SpeLoss,
		Kd_SpeSnem,
		Kd_SpeRpccs,
		Kd_SpeBlkPl,
		Kd_SpeBlkOsl,
		Kd_SpeIbnr2,
		Kd_SpeResn,
		Kd_SpeRes,
		Kd_SpeAcr,
		Ksz_Vide,              //ptb_InRec_Cur[CTRSTAT_CEDHORDNBR_NT],
		Ksz_Vide,              //ptb_InRec_Cur[CTRSTAT_CEDSORDNBR_NT],
		Ksz_Vide,              //ptb_InRec_Cur[CTRSTAT_ORGCEDHORDNBR_NT],
		Ksz_Vide,              //ptb_InRec_Cur[CTRSTAT_ORGCEDSORDNBR_NT],
		Ksz_Vide,              //ptb_InRec_Cur[CTRSTAT_BRKHORDNBR_NT],
		Ksz_Vide,              //ptb_InRec_Cur[CTRSTAT_BRKSORDNBR_NT],
	  Ksz_Vide,              //	ptb_InRec_Cur[ULTIM_FACADMTYP_B],
    Ksz_Vide,   /* CLIIND_NF */
    Ksz_Vide,  /* HORDNBR_NT */
	n_oricod);  // [002]

//      fprintf( Kp_OutputFil, "%s~%s~%s~%s~%s~%ld~%c~%-.3f\n",
//	       ptb_InRecChild[GT_CTR_NF],
//	       ptb_InRecChild[GT_END_NT],
//	       ptb_InRecChild[GT_SEC_NF],
//	       ptb_InRecChild[GT_UWY_NF],
//	       ptb_InRecChild[GT_UW_NT],
//	       l_AcmTrs,
//	       c_TypCum,
//	       d_Amt ) ;
//
  }

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l’esclave

retour :
	OK
==============================================================================*/
int n_InitUndSta( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitUndSta" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESPO1001_I5", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncUndSta ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneUndSta ;

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
int n_ConditionSyncUndSta(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncUndSta" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[CMP_CTR_NF] ) ) != 0 ) return ret ;
/*	if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[UND_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[UND_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[UND_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[UND_UW_NT] ) ) != 0 ) return ret ;
*/
	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneUndSta(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneUndSta" ) ;

	/* Recherche de la derniere periode de compte complet */
	Kn_Periode = max(Kn_Periode, atoi( ptb_InRecChild[CMP_ACY_NF] ) * 100 + atoi( ptb_InRecChild[CMP_SCOENDMTH_NF] )) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet:
	Lit le fichier binaire des postes et les met en memoire

==============================================================================*/
int n_ChargerTRSLNK( short s_TrtCod )
{
	int i = 0 ;

	DEBUT_FCT("n_ChargerTRSLNK");

	while ( fread( &Ktbd_TrsLnk[i], sizeof( T_TRSLNK ), 1, Kp_InputFilTrsLnk ) == 1 )
	{
		if ( Ktbd_TrsLnk[i].PRS_CF == s_TrtCod )
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
		ret=strcmp(sz_poste,Ktbd_TrsLnk[n_indice].DETTRS_CF);

		/* S'ils sont egaux, retourner l'indice */
		if (ret==0) RETURN_VAL(n_indice);

		/* Si la ligne est passee, retourner -1 (echec) */
		if (ret<0) RETURN_VAL(-1);

		/* Ligne suivante */
		n_indice++;

		/* Si on est a la fin du tableau, echec */
		if (n_indice>=Kn_NbLigTrslnk) RETURN_VAL(-1);
	}
}

/*==============================================================================
objet :
	fonction d'initialisation

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_InitVariables( void )
{
	DEBUT_FCT( "n_InitVariables" ) ;

	Kd_CaccPrm = 0 ;
	Kd_CaccEpp = 0 ;
	Kd_CaccRpp = 0 ;
	Kd_CaccPna = 0 ;
	Kd_CaccResPrm = 0 ;
	Kd_CaccRpccp = 0 ;
	Kd_CaccLoa = 0 ;
	Kd_CaccBrk = 0 ;
	Kd_CaccFar = 0 ;
	Kd_CaccFar2 = 0 ;
	Kd_CaccSp = 0 ;
	Kd_CaccEps = 0 ;
	Kd_CaccRps = 0 ;
	Kd_CaccSap = 0 ;
	Kd_CaccPbPap = 0 ;
	Kd_CaccLoss = 0 ;
	Kd_CaccSnem = 0 ;
	Kd_CaccRpccs = 0 ;
	Kd_CaccResn = 0 ;
	Kd_CaccRes = 0 ;
	Kd_CaccAcr = 0 ;

	Kd_IaccPrm = 0 ;
	Kd_IaccEpp = 0 ;
	Kd_IaccRpp = 0 ;
	Kd_IaccPna = 0 ;
	Kd_IaccResPrm = 0 ;
	Kd_IaccRpccp = 0 ;
	Kd_IaccLoa = 0 ;
	Kd_IaccBrk = 0 ;
	Kd_IaccFar = 0 ;
	Kd_IaccFar2 = 0 ;
	Kd_IaccSp = 0 ;
	Kd_IaccEps = 0 ;
	Kd_IaccRps = 0 ;
	Kd_IaccSap = 0 ;
	Kd_IaccPbPap = 0 ;
	Kd_IaccLoss = 0 ;
	Kd_IaccSnem = 0 ;
	Kd_IaccRpccs = 0 ;
	Kd_IaccResn = 0 ;
	Kd_IaccRes = 0 ;
	Kd_IaccAcr = 0 ;

	Kd_EstPrm = 0 ;
	Kd_EstEpp = 0 ;
	Kd_EstRpp = 0 ;
	Kd_EstPna = 0 ;
	Kd_EstResPrm = 0 ;
	Kd_EstRpccp = 0 ;
	Kd_EstLoa = 0 ;
	Kd_EstBrk = 0 ;
	Kd_EstFar = 0 ;
	Kd_EstFar2 = 0 ;
	Kd_EstSp = 0 ;
	Kd_EstEps = 0 ;
	Kd_EstRps = 0 ;
	Kd_EstSap = 0 ;
	Kd_EstPbPap = 0 ;
	Kd_EstLoss = 0 ;
	Kd_EstSnem = 0 ;
	Kd_EstRpccs = 0 ;
	Kd_EstBlkPl = 0 ;
	Kd_EstBlkOsl = 0 ;
	Kd_EstIbnr2 = 0 ;
	Kd_EstResn = 0 ;
	Kd_EstRes = 0 ;
	Kd_EstAcr = 0 ;

	Kd_SpePrm = 0 ;
	Kd_SpeEpp = 0 ;
	Kd_SpeRpp = 0 ;
	Kd_SpePna = 0 ;
	Kd_SpeResPrm = 0 ;
	Kd_SpeRpccp = 0 ;
	Kd_SpeLoa = 0 ;
	Kd_SpeBrk = 0 ;
	Kd_SpeFar = 0 ;
	Kd_SpeFar2 = 0 ;
	Kd_SpeSp = 0 ;
	Kd_SpeEps = 0 ;
	Kd_SpeRps = 0 ;
	Kd_SpeSap = 0 ;
	Kd_SpePbPap = 0 ;
	Kd_SpeLoss = 0 ;
	Kd_SpeSnem = 0 ;
	Kd_SpeRpccs = 0 ;
	Kd_SpeBlkPl = 0 ;
	Kd_SpeBlkOsl = 0 ;
	Kd_SpeIbnr2 = 0 ;
	Kd_SpeResn = 0 ;
	Kd_SpeRes = 0 ;
	Kd_SpeAcr = 0 ;

	RETURN_VAL( OK ) ;
}






