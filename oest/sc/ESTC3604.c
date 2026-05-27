/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION
nom du source                 : ESTC3604.c
révision                      : $Revision: 1.1.1.1 $
date de création              : 06/10/1998
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   	Introduction des postes cumuls, conversions en monnaie aliment, etc...

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	   ...           ...            ...              ...
    25/03/2004    M. DJELLOULI Modification sur POSTES 10301 & 10311 - MOD01
    21/04/2005    M.DJELLOULI  SPOT 11416 - MOD02
                                          Pour charger Omega SAR, plutôt que de ne prendre que les provisions de clôture sur
                                          le bilan sauf les ouvertures on prend également les ouvertures pour les postes suivants :
                                          10321, 10331, 10341, 10351, 14201, 42181, 42411, 42891, 45101.
[003] 12/07/2012 R. CASSIS    :spot:23802 Modifications tests des postes comptables
[004] 11/01/2013 -=Dch=-  	  :spot:24041 modifications des postes
[005] 23/06/2016 S. ASKRI     :spot:30806 EBS - AE issues on the program ESTC3604 
[006] 18/01/2018 R. CASSIS    :spira:67103 Aghrandissement du tableau ttrslnk de 2000 a 10000
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
//#define MAX_POSTE	2000  [006]
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
T_RUPTURE_SYNC_VAR 	bd_RuptArcGta ; /* variable de gestion de la synchronisation avec le fichier ARCSTATGTA */
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

int n_InitArcGta		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneArcGta		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncArcGta	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

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

char Ksz_AnneeBilan[5];


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


        if ( n_OpenFileAppl ( "ESTC3604_I7","rb",&Kp_Dettrs ) == ERR )
                ExitPgm ( ERR_XX , "" );

	/* ouverture du fichier en entree des cours de change FCURQUOT */
	if ( n_OpenFileAppl ( "ESTC3604_I5","rb",&Kp_InputFilCurquot ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier en entree des postes cumuls FTRSLNK */
	if ( n_OpenFileAppl ( "ESTC3604_I4","rb",&Kp_InputFilTrsLnk ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier de sortie */
	if ( n_OpenFileAppl ( "ESTC3604_O1","wt",&Kp_OutputFil ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPer */
	if ( n_InitPer( &bd_RuptPer ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptArcGta */
	if ( n_InitArcGta( &bd_RuptArcGta ) )
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

	if ( n_CloseFileAppl( "ESTC3604_I1", &( bd_RuptPer.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3604_I2", &( bd_RuptArcGta.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3604_I3", &( bd_RuptTotGta.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3604_I4", &Kp_InputFilTrsLnk ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3604_I5", &Kp_InputFilCurquot ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3604_I6", &( bd_RuptUndSta.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

        if ( n_CloseFileAppl ( "ESTC1005_I7",&Kp_Dettrs ) == ERR )
                ExitPgm ( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC3604_O1", &Kp_OutputFil ) == ERR )
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
	if ( n_OpenFileAppl( "ESTC3604_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
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

        /* aucun traitement si le contrat est termine */
/* FCharles 06/04/2000
        if ( atoi( ptb_InRec_Cur[PER_SECACCSTS_CT] ) == 9 )
                RETURN_VAL( OK ) ; */

        /* synchronisation avec les fichiers fils */
        n_ProcessingRuptureSyncVar( &bd_RuptArcGta, ptb_InRec_Cur ) ;
        n_ProcessingRuptureSyncVar( &bd_RuptTotGta, ptb_InRec_Cur ) ;

        RETURN_VAL( OK ) ;
}



/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l’esclave

retour :
	OK
==============================================================================*/
int n_InitArcGta( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitArcGta" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC3604_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncArcGta ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneArcGta ;

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
int n_ConditionSyncArcGta(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncArcGta" ) ;

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
int n_ActionLigneArcGta(
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
  double	d_Taux;	/* taux de conversion */
  double	d_Amt;	/* montant */
  char	MsgAno[300] ;	/* message d'anomalie */
  short	n_type;
  int	n_poste;

  DEBUT_FCT( "n_ActionLigneArcGta" ) ;

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

    /* Pas de traitement pour les lignes retro */
    /*******************************************/
    if ( ptb_InRecChild[GT_TRNCOD_CF][0] == '2' || ptb_InRecChild[GT_TRNCOD_CF][0] == '4' )
      RETURN_VAL( OK ) ;


    /* Poste cedante */
    /*****************/
    if ( ptb_InRecChild[GT_TRNCOD_CF][1] < '4' && ptb_InRecChild[GT_TRNCOD_CF][7] < '2' )
      {
	/* Proportionnel */
	if ( ( *ptb_InRecOwner[PER_CTRNAT_CT] == 'P' ) ||
             ( atoi( ptb_InRecOwner[PER_NAT_CF] ) == 40 ) ||
             ( atoi( ptb_InRecOwner[PER_NAT_CF] ) == 41 ) )
	  {
	    /* Comptes complets */
	    if ( atoi( ptb_InRecChild[GT_ACY_NF] ) * 100 +  atoi( ptb_InRecChild[GT_SCOENDMTH_NF] ) <= Kn_Periode )
	      c_TypCum = 'C' ;

	    /* Comptes incomplets */
	    else	c_TypCum = 'I' ;
	  }
	/* Non prop ou Facs */
	else	c_TypCum = 'C' ;
      }


    /* Poste estime hors service */
    /*****************************/
// [003]
//    if ( ptb_InRecChild[GT_TRNCOD_CF][1] < '4' && ptb_InRecChild[GT_TRNCOD_CF][7] >= '2' )
	if ( (ptb_InRecChild[GT_TRNCOD_CF][1] == '1' || ptb_InRecChild[GT_TRNCOD_CF][1] == '2' || 
		   ptb_InRecChild[GT_TRNCOD_CF][1] == '3' || ptb_InRecChild[GT_TRNCOD_CF][1] == 'A' || 
		   ptb_InRecChild[GT_TRNCOD_CF][1] == 'B' || ptb_InRecChild[GT_TRNCOD_CF][1] == 'D' || 
		   ptb_InRecChild[GT_TRNCOD_CF][1] == 'Z' || ptb_InRecChild[GT_TRNCOD_CF][1] == 'M' || 
		   ptb_InRecChild[GT_TRNCOD_CF][1] == 'F') && ptb_InRecChild[GT_TRNCOD_CF][7] >= '2' )
		c_TypCum = 'E' ;
		
	
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
      fprintf( Kp_OutputFil, "%s~%s~%s~%s~%s~%ld~%c~%-.3f~%s~%s~%s~%s~%s~%s~%s~%s\n",
	       ptb_InRecChild[GT_CTR_NF],
	       ptb_InRecChild[GT_END_NT],
	       ptb_InRecChild[GT_SEC_NF],
	       ptb_InRecChild[GT_UWY_NF],
	       ptb_InRecChild[GT_UW_NT],
	       l_AcmTrs,
	       c_TypCum,
	       d_Amt,
		   ptb_InRecOwner[PER_EGPCUR_CF],
           ptb_InRecChild[GT_SSD_CF],
           ptb_InRecChild[GT_ESB_CF],
           ptb_InRecChild[GT_BALSHEY_NF],
		   ptb_InRecOwner[PER_CED_NF],
           ptb_InRecChild[GT_BRK_NF],
           ptb_InRecChild[GT_PAY_NF],
           ptb_InRecChild[GT_KEY_NF]
		   ) ;

  }

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
	if ( n_OpenFileAppl( "ESTC3604_I3", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
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

    /* Poste cedante */
    /*****************/
    if ( ptb_InRecChild[GT_TRNCOD_CF][1] < '4' && ptb_InRecChild[GT_TRNCOD_CF][7] < '2' )
      {
	/* Proportionnel */
	if ( ( *ptb_InRecOwner[PER_CTRNAT_CT] == 'P' ) ||
             ( atoi( ptb_InRecOwner[PER_NAT_CF] ) == 40 ) ||
             ( atoi( ptb_InRecOwner[PER_NAT_CF] ) == 41 ) )
	  {
	    /* Comptes complets */
	    if ( atoi( ptb_InRecChild[GT_ACY_NF] ) * 100 +  atoi( ptb_InRecChild[GT_SCOENDMTH_NF] ) <= Kn_Periode )
	      c_TypCum = 'C' ;

	    /* Comptes incomplets */
	    else	c_TypCum = 'I' ;
	  }
	/* Non prop ou Facs */
	else	c_TypCum = 'C' ;
      }


    /* Poste estime hors service */
    /*****************************/
// [003]
//    if ( ptb_InRecChild[GT_TRNCOD_CF][1] < '4' && ptb_InRecChild[GT_TRNCOD_CF][7] >= '2' )
	if ( (ptb_InRecChild[GT_TRNCOD_CF][1] == '1' || ptb_InRecChild[GT_TRNCOD_CF][1] == '2' || 
		   ptb_InRecChild[GT_TRNCOD_CF][1] == '3' || ptb_InRecChild[GT_TRNCOD_CF][1] == 'A' || 
		   ptb_InRecChild[GT_TRNCOD_CF][1] == 'B' || ptb_InRecChild[GT_TRNCOD_CF][1] == 'D' || 
		   ptb_InRecChild[GT_TRNCOD_CF][1] == 'Z' || ptb_InRecChild[GT_TRNCOD_CF][1] == 'M' || 
		   ptb_InRecChild[GT_TRNCOD_CF][1] == 'F') && ptb_InRecChild[GT_TRNCOD_CF][7] >= '2' )
      c_TypCum = 'E' ;


    /* Poste service */
    /*****************/
// [003]
// [005]
//    if ( ptb_InRecChild[GT_TRNCOD_CF][1] >= '4' )
	if (( ptb_InRecChild[GT_TRNCOD_CF][1] == '4' || ptb_InRecChild[GT_TRNCOD_CF][1] == '5' || 
		  ptb_InRecChild[GT_TRNCOD_CF][1] == '6' || ptb_InRecChild[GT_TRNCOD_CF][1] == '7' || 
		  ptb_InRecChild[GT_TRNCOD_CF][1] == '8' || ptb_InRecChild[GT_TRNCOD_CF][1] == '9' || 
		  ptb_InRecChild[GT_TRNCOD_CF][1] == 'E' || ptb_InRecChild[GT_TRNCOD_CF][1] == 'G' || 
		  ptb_InRecChild[GT_TRNCOD_CF][1] == 'H' || ptb_InRecChild[GT_TRNCOD_CF][1] == 'J' || 
		  ptb_InRecChild[GT_TRNCOD_CF][1] == 'K' || ptb_InRecChild[GT_TRNCOD_CF][1] == 'L' || 
		  ptb_InRecChild[GT_TRNCOD_CF][1] == 'V' || ptb_InRecChild[GT_TRNCOD_CF][1] == 'W' || 
		  ptb_InRecChild[GT_TRNCOD_CF][1] == 'X' || ptb_InRecChild[GT_TRNCOD_CF][1] == 'N' || 
		  ptb_InRecChild[GT_TRNCOD_CF][1] == 'Y' || ptb_InRecChild[GT_TRNCOD_CF][1] == 'U' ) 
		  && (atoi(ptb_InRecChild[GT_BALSHEY_NF]) == atoi(Ksz_AnneeBilan)))
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
      fprintf( Kp_OutputFil, "%s~%s~%s~%s~%s~%ld~%c~%-.3f~%s~%s~%s~%s~%s~%s~%s~%s\n",
	       ptb_InRecChild[GT_CTR_NF],
	       ptb_InRecChild[GT_END_NT],
	       ptb_InRecChild[GT_SEC_NF],
	       ptb_InRecChild[GT_UWY_NF],
	       ptb_InRecChild[GT_UW_NT],
	       l_AcmTrs,
	       c_TypCum,
	       d_Amt ,
		   ptb_InRecOwner[PER_EGPCUR_CF],
           ptb_InRecChild[GT_SSD_CF],
           ptb_InRecChild[GT_ESB_CF],
           ptb_InRecChild[GT_BALSHEY_NF],
		   ptb_InRecOwner[PER_CED_NF],
           ptb_InRecChild[GT_BRK_NF],
           ptb_InRecChild[GT_PAY_NF],
           ptb_InRecChild[GT_KEY_NF]
		   ) ;

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
	if ( n_OpenFileAppl( "ESTC3604_I6", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
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

