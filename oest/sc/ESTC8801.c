/*==============================================================================
nom de l'application          : ESTIMATION
nom du source                 : ESTC8801.c
révision                      : $Revision: 1.2 $
date de création              : 13/03/1998
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   Enrichissement du GT entree avant remontee dans la table TTECLEDA

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    16/09/1998     M.HA-THUC  rajout de 2 champs supplementaires dans
        les tables TTECLEDA
          - ESTCRB_CT : code crible
          - ESTCTR_NF : traite de rattachement

    13/03/2000     O.GIRAUX rajout de 11 champs supplementaires dans
        les tables TTECLEDA
          - ESBACC_NF   : Etablissement Acceptation ESB_CF
          - ORGCED_NF     : Cedante d'origine
          - CEDHORDNBR_NT   : Segment groupe pour la cedante
          - CEDSORDNBR_NT   : Segment filiale pour la cedante d'origine
          - ORGCEDHORDNBR_NT  : Segment groupe pour la cédante d'origine
          - ORGCEDSORDNBR_NT  : Segment filiale pour la cédante d'origine
          - BRKHORDNBR_NT   : Segment groupe pour le courtier Acceptation
          - BRKSORDNBR_NT   : Segment filiale pour le courtier Acceptation
          - FACADMTYP_CT    : Segmentation FACT
          - CLIIND_NF (CLI_NF)  :
          - HORDNBR_NT (integer)

 27/03/2008 J. Ribot  SPOT 15219  ASE15 : recompilation des programmes C
[004] 18/06/2015 DFI  SPOT:28947   filtre des analytiques dans la generation de l'interface 1GL 05/02/2016 Florent   :spot:29066 suite au GLT à 71 colonnes, 16 nouvelles colonnes dans les 2 tables TTCLEDA et R
[005] 24/06/2016 R. cassis :spot:30790 Correction sur l'ORICOD_LS remis a blanc en cas de Fils sans pere pour contrats NP alloc venanrt de ESID2561
[001] 11/09/2018 M.NAJI  add UWY_NF  spira 57605
[002]  18/02/2019 sauvegarde des infos du maitre pendant la première synchro avec FCTRGROc, car  elle ne se fait pas sur la clé 
[006] 25/10/2023 MZM :Spira:110772 Empty origin on some retro reclass transactions 
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "struct.h"
#define CTRGRO_UWY_NF 20 //dernier champs

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/
#include "ESTC8802.h"

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/
#define Kn_MaxPostes 1000 /* Le nombre max de postes est fixe a 1000 */

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE    *Kp_OutputFilGtaa ;   /* pointeur sur le fichier de sortie GTAA */
FILE    *Kp_OutputFilGtar ;   /* pointeur sur le fichier de sortie GTAR */
FILE    *Kp_InputFilSobblob ;   /* pointeur sur le fichier binaire des codes produits */

T_RUPTURE_VAR       bd_RuptPer ;  /* variable de gestion de la rupture sur le
          perimetre IADVPERICASE */
T_RUPTURE_SYNC_VAR  bd_RuptTotGtaa ; /* variable de gestion de la synchronisation avec
          le fichier TOTGTAA */
T_RUPTURE_SYNC_VAR  bd_RuptCtrGro ; /* variable de gestion de la synchronisation avec
          le fichier FCTRGRO */
T_RUPTURE_SYNC_VAR  bd_RuptCplAcc ; /* variable de gestion de la synchronisation avec
          le fichier FCPLACC */
T_RUPTURE_SYNC_VAR  bd_RuptTotGtar ; /* variable de gestion de la synchronisation avec
          le fichier TOTGTAR */

char  Ksz_Acy[5] ;    /* annee de compte complet */
char  Ksz_Seg[15] ;   /* segment de l'affaire */
char  Ksz_Vrs[11] ;   /* numero de version */
char  Ksz_CplAccUpd[50] ; /* date d'effet du compte complet */

T_SOBBLOB Ktbd_Sobblob[Kn_MaxPostes] ;  /* tableau contenant les codes produits par Lob - Sob */
int Kn_NbLigSobblob ;     /* nombre de lignes charges dans le tableau */

char  *Ksz_Prdcod ;   /* code produit */

//[002]
char CTRGRO_CTR_SYNC[10] ="";
char CTRGRO_END_SYNC[5]  ="";
char CTRGRO_SEC_SYNC[5]   ="";
char CTRGRO_UWY_SYNC[5] ="";

int n_InitPer     ( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_IsR1Per     ( char **ptb_InRec, char **pbd_InRec_Cur ) ;
int n_IsR2Per     ( char **ptb_InRec, char **pbd_InRec_Cur ) ;
int n_ActionFirstRupt1Per ( char **ptb_InRec_Cur ) ;
int n_ActionFirstRupt2Per ( char **ptb_InRec_Cur ) ;
int n_ActionLignePer    ( char **pbd_InRec_Cur ) ;

int n_InitTotGtaa     ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneTotGtaa  ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncTotGtaa  ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ActionFilsSansPereTotGtaa ( char **pbd_InRecChild ) ;

int n_InitCtrGro    ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneCtrGro   ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncCtrGro ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitCplAcc    ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneCplAcc   ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncCplAcc ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitTotGtar     ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneTotGtar  ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncTotGtar  ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ActionFilsSansPereTotGtar ( char **pbd_InRecChild ) ;


int n_ProcessingRuptureSyncVar (
  T_RUPTURE_SYNC_VAR  *pbd_Rupt,
  char **ptb_InRecOwner );


int n_ChargerSOBBLOB( void ) ;
char *n_RechProduit( char *sz_lob, char *sz_sob ) ;


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

  /* ouverture du fichier en entree des codes produits FSOBBLOB */
  if ( n_OpenFileAppl ( "ESTC8801_I6", "rb", &Kp_InputFilSobblob ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier de sortie GTAA */
  if ( n_OpenFileAppl ( "ESTC8801_O1", "wt", &Kp_OutputFilGtaa ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier de sortie GTAR */
  if ( n_OpenFileAppl ( "ESTC8801_O2", "wt", &Kp_OutputFilGtar ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptPer */
  if ( n_InitPer( &bd_RuptPer ) )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptTotGTaa */
  if ( n_InitTotGtaa( &bd_RuptTotGtaa ) )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptCtrGro */
  if ( n_InitCtrGro( &bd_RuptCtrGro ) )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptCplAcc */
  if ( n_InitCplAcc( &bd_RuptCplAcc ) )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptTotGTar */
  if ( n_InitTotGtar( &bd_RuptTotGtar ) )
    ExitPgm( ERR_XX , "" ) ;

  /* Chargement des codes produits en memoire */
  /* modif O.Arik:29/05/2001 on sort en cas de dep. de memoire*/
  Kn_NbLigSobblob = n_ChargerSOBBLOB( );
  if ( Kn_NbLigSobblob > Kn_MaxPostes )
    ExitPgm( ERR_XX , "" ) ;

  /* lancement du traitement du fichier Perimetre IADVPERICASE */
  if ( n_ProcessingRuptureVar( &bd_RuptPer ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC8801_I1", &( bd_RuptPer.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC8801_I2", &( bd_RuptTotGtaa.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC8801_I3", &( bd_RuptCtrGro.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC8801_I4", &( bd_RuptCplAcc.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC8801_I5", &( bd_RuptTotGtar.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC8801_I6", &Kp_InputFilSobblob ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC8801_O1", &Kp_OutputFilGtaa ) == ERR )
    ExitPgm( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTC8801_O2", &Kp_OutputFilGtar ) == ERR )
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
int n_InitPer(T_RUPTURE_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_InitPer" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

  /* ouverture du fichier maitre Perimetre */
  if ( n_OpenFileAppl( "ESTC8801_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
    return ERR ;

  pbd_Rupt->n_NbRupture = 2 ;

  /* fonction du test de rupture de niveau 1 */
  pbd_Rupt->n_ConditionRupture[0] = n_IsR1Per ;

  /* fonction du test de rupture de niveau 2 */
  pbd_Rupt->n_ConditionRupture[1] = n_IsR2Per ;

  /* fonction lancee en rupture premiere de niveau 1 */
  pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRupt1Per ;

  /* fonction lancee en rupture premiere de niveau 2 */
  pbd_Rupt->n_ActionFirst[1] = n_ActionFirstRupt2Per ;

  /* fonction d'action sur la ligne courante du fichier maitre */
  pbd_Rupt->n_ActionLigne = n_ActionLignePer ;

  pbd_Rupt->c_Separ = SEPARATEUR ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  fonction de test de rupture de niveau 1

retour :
  0 ---> pas de rupture
  sinon     ---> rupture
==============================================================================*/
int n_IsR1Per(
  char **pbd_InRec ,  /* adresse de la ligne en avance */
  char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
  int ret ;

  DEBUT_FCT( "n_IsR1Per" ) ;

  if ( ( ret = strcmp( pbd_InRec[PER_CTR_NF], pbd_InRec_Cur[PER_CTR_NF] ) ) != 0 ) RETURN_VAL (ret) ;

  RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
  fonction de test de rupture de niveau 2

retour :
  0 ---> pas de rupture
  sinon     ---> rupture
==============================================================================*/
int n_IsR2Per(
  char **pbd_InRec ,  /* adresse de la ligne en avance */
  char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
  int ret ;

  DEBUT_FCT( "n_IsR2Per" ) ;

  if ( ( ret = strcmp( pbd_InRec[PER_END_NT], pbd_InRec_Cur[PER_END_NT] ) ) != 0 ) RETURN_VAL (ret) ;
  if ( ( ret = strcmp( pbd_InRec[PER_SEC_NF], pbd_InRec_Cur[PER_SEC_NF] ) ) != 0 ) RETURN_VAL (ret) ;
  if ( ( ret = strcmp( pbd_InRec[PER_UWY_NF], pbd_InRec_Cur[PER_UWY_NF] ) ) != 0 ) RETURN_VAL (ret) ;

  RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
  fonction lancee en rupture premiere de niveau 1

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRupt1Per(
  char **ptb_InRec_Cur  ) /* adresse de la ligne courante */
{
  DEBUT_FCT( "n_ActionFirstRupt1Per" ) ;

  /* initialisation des variables de travail */
  strcpy( Ksz_Acy, "" ) ;
  strcpy( Ksz_CplAccUpd, "" ) ;

  /* synchronisation avec le fichier des Comptes complets */
  n_ProcessingRuptureSyncVar( &bd_RuptCplAcc, ptb_InRec_Cur ) ;

  RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
  fonction lancee en rupture premiere de niveau 2

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRupt2Per(
  char **ptb_InRec_Cur  ) /* adresse de la ligne courante */
{
  DEBUT_FCT( "n_ActionFirstRupt2Per" ) ;

 
  if (strcmp(CTRGRO_CTR_SYNC,ptb_InRec_Cur[PER_CTR_NF]) == 0 &&
		strcmp(CTRGRO_END_SYNC,ptb_InRec_Cur[PER_END_NT])== 0 &&
		strcmp(CTRGRO_SEC_SYNC,ptb_InRec_Cur[PER_SEC_NF])== 0 &&
		(   *CTRGRO_UWY_SYNC == 0 || 
			*CTRGRO_UWY_SYNC == '0'  ||
			strcmp(CTRGRO_UWY_SYNC,ptb_InRec_Cur[PER_UWY_NF])==0) ) // on garde le même segment car l'exrcice na pas changé ou  il est vide
		RETURN_VAL(OK);
	else  /* Synchronisation avec le fichier TCTRGRO pour recuperer le segment */
	{
		/* initialisation des variables de travail */
		strcpy( Ksz_Seg, "" ) ;
		strcpy( Ksz_Vrs, "" ) ;

		/* Synchronisation avec le fichier des regroupement d'affaires */
		n_ProcessingRuptureSyncVar( &bd_RuptCtrGro, ptb_InRec_Cur ) ;

	}
  RETURN_VAL ( OK ) ;
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

  /* si FAC recherche du code produit en fonction du couple Lob - Sob */
  if ( *ptb_InRec_Cur[PER_CTRNAT_CT] == 'F' )
    Ksz_Prdcod = n_RechProduit( ptb_InRec_Cur[PER_LOB_CF], ptb_InRec_Cur[PER_SOB_CF] ) ;
  else  Ksz_Prdcod = "" ;

  /* synchronisation avec le GTAA */
  n_ProcessingRuptureSyncVar( &bd_RuptTotGtaa, ptb_InRec_Cur ) ;

  /* synchronisation avec le GTAR */
  n_ProcessingRuptureSyncVar( &bd_RuptTotGtar, ptb_InRec_Cur ) ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  Initialisation de la synchronisation du maitre « Perimetre »
  avec l’esclave « TOTGTAA »

retour :
  OK
==============================================================================*/
int n_InitTotGtaa( T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_InitTotGtaa" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

  /* ouverture du fichier esclave TOTGTAA */
  if ( n_OpenFileAppl( "ESTC8801_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
    return ERR ;

  /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncTotGtaa ;

  /* fonction d'action sur la ligne courante */
  pbd_Rupt->n_ActionLigne = n_ActionLigneTotGtaa ;

  /* fonction d'action quand l'esclave n'a pas de maitre */
  pbd_Rupt->n_FilsSansPere = n_ActionFilsSansPereTotGtaa ;

  pbd_Rupt->c_Separ = SEPARATEUR ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  fonction de test de synchronisation

retour :
  0 ---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
  > 0     ---> pbd_InRecOwne> > pbd_InRecChild
  < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncTotGtaa(
  char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
  char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
  int ret ;

  DEBUT_FCT( "n_ConditionSyncTotGtaa" ) ;

  if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[TECLEDA_CTR_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[TECLEDA_END_NT] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[TECLEDA_SEC_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[TECLEDA_UWY_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[TECLEDA_UW_NT] ) ) != 0 ) return ret ;

  RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
  fonction lancee pour chaque ligne

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneTotGtaa(
  char **ptb_InRecOwner , /* adresse de la ligne du maitre */
  char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{

  DEBUT_FCT( "n_ActionLigneTotGtaa" ) ;

  /* rajout des champs supplementaire au GT en sortie */
  ptb_InRecChild[TECLEDA_LOBACC_CF] = ptb_InRecOwner[PER_LOB_CF] ;
  ptb_InRecChild[TECLEDA_LOBRET_CF] = "" ;  /* champs non renseigne */
  ptb_InRecChild[TECLEDA_SOBACC_CF] = ptb_InRecOwner[PER_SOB_CF] ;
  ptb_InRecChild[TECLEDA_SOBRET_CF] = "" ;  /* champs non renseigne */
  ptb_InRecChild[TECLEDA_TOPACC_CF] = ptb_InRecOwner[PER_TOP_CF] ;
  ptb_InRecChild[TECLEDA_TOPRET_CF] = "" ;  /* champs non renseigne */
  ptb_InRecChild[TECLEDA_NATACC_CF] = ptb_InRecOwner[PER_NAT_CF] ;
  ptb_InRecChild[TECLEDA_NATRET_CF] = "" ;  /* champs non renseigne */
  ptb_InRecChild[TECLEDA_GARACC_CF] = ptb_InRecOwner[PER_GAR_CF] ;
  ptb_InRecChild[TECLEDA_GARRET_CF] = "" ;  /* champs non renseigne */
  ptb_InRecChild[TECLEDA_PCPRSKTRYACC_CF] = ptb_InRecOwner[PER_PCPRSKTRY_CF] ;
  ptb_InRecChild[TECLEDA_PCPRSKTRYRET_CF] = "" ;  /* champs non renseigne */
  ptb_InRecChild[TECLEDA_USRCRTCODACC_CT] = ptb_InRecOwner[PER_USRCRTCOD_CT] ;
  ptb_InRecChild[TECLEDA_USRCRTCODRET_CT] = "" ;  /* champs non renseigne */
  ptb_InRecChild[TECLEDA_USRCRTVALACC_LM] = ptb_InRecOwner[PER_USRCRTVAL_LM] ;
  ptb_InRecChild[TECLEDA_USRCRTVALRET_LM] = "" ;  /* champs non renseigne */
  ptb_InRecChild[TECLEDA_CTRNAT_CT] = ptb_InRecOwner[PER_CTRNAT_CT] ;
  ptb_InRecChild[TECLEDA_RETCTRCAT_CF] = "" ; /* champs non renseigne */
  ptb_InRecChild[TECLEDA_WRKCAT_CT] = ptb_InRecOwner[PER_WRKCAT_CT] ;
  ptb_InRecChild[TECLEDA_PRDCOD_CT] = Ksz_Prdcod ;
  ptb_InRecChild[TECLEDA_ANLCTY_CF] = ptb_InRecOwner[PER_ANLCTY_CF] ;
  ptb_InRecChild[TECLEDA_ACCADMTYP_CT] = ptb_InRecOwner[PER_ACCADMTYP_CT] ;
  ptb_InRecChild[TECLEDA_RETACCTYP_CT] = "" ; /* champs non renseigne */
  ptb_InRecChild[TECLEDA_CTRRET_B] = ptb_InRecOwner[PER_CTRRET_B] ;
  ptb_InRecChild[TECLEDA_UWGRP_CF] = ptb_InRecOwner[PER_UWGRP_CF] ;
  ptb_InRecChild[TECLEDA_UWORG_CF] = ptb_InRecOwner[PER_UWORG_CF] ;
  ptb_InRecChild[TECLEDA_ESTCRB_CT] = ptb_InRecOwner[PER_ESTCRB_CT] ;
  ptb_InRecChild[TECLEDA_ESTCTR_NF] = ptb_InRecOwner[PER_ESTCTR_NF] ;

  ptb_InRecChild[TECLEDA_ESBACC_NF]       =  ptb_InRecOwner[PER_ACCESB_CF];
  ptb_InRecChild[TECLEDA_ORGCED_NF]   =  ptb_InRecOwner[PER_ORGCED_NF];
  ptb_InRecChild[TECLEDA_CEDHORDNBR_NT]   =  ptb_InRecOwner[PER_CEDHORDNBR_NT];
  ptb_InRecChild[TECLEDA_CEDSORDNBR_NT]   =  ptb_InRecOwner[PER_CEDSORDNBR_NT];
  ptb_InRecChild[TECLEDA_ORGCEDHORDNBR_NT] =  ptb_InRecOwner[PER_ORGCEDHORDNBR_NT];
  ptb_InRecChild[TECLEDA_ORGCEDSORDNBR_NT] =  ptb_InRecOwner[PER_ORGCEDSORDNBR_NT];
  ptb_InRecChild[TECLEDA_BRKHORDNBR_NT]   =  ptb_InRecOwner[PER_BRKHORDNBR_NT];
  ptb_InRecChild[TECLEDA_BRKSORDNBR_NT] =  ptb_InRecOwner[PER_BRKSORDNBR_NT];
  ptb_InRecChild[TECLEDA_FACADMTYP_CT]  =  ptb_InRecOwner[PER_FACADMTYP_B];
  ptb_InRecChild[TECLEDA_CLIIND_NF]   = "";
  ptb_InRecChild[TECLEDA_HORDNBR_NT]  = "";

  /* positionnement du segment et de la version */
  ptb_InRecChild[TECLEDA_VRS_NF] = Ksz_Vrs ;
  ptb_InRecChild[TECLEDA_SEG_NF] = Ksz_Seg ;

  /* positionnement de l'indicateur compte complet */
  if ( atoi( Ksz_Acy ) >= atoi( ptb_InRecChild[TECLEDA_ACY_NF] ) )
  {
    ptb_InRecChild[TECLEDA_COMACC_B] = "1" ;
    ptb_InRecChild[TECLEDA_CPLACCUPD_D] = Ksz_CplAccUpd ;
  }
  else
  {
    ptb_InRecChild[TECLEDA_COMACC_B] = "0" ;
    ptb_InRecChild[TECLEDA_CPLACCUPD_D] = "" ;
  }

  /* ecriture dans le GTAA en sortie */
  n_WriteCols( Kp_OutputFilGtaa, ptb_InRecChild, SEPARATEUR, 0 ) ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  fonction lancee quand le fils n'a pas de pere

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionFilsSansPereTotGtaa(
  char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{

	DEBUT_FCT( "n_ActionFilsSansPereTotGtaa" ) ;
	
	/* rajout des champs supplementaire au GT en sortie */
	ptb_InRecChild[TECLEDA_LOBACC_CF] = "" ;
	ptb_InRecChild[TECLEDA_LOBRET_CF] = "" ;
	ptb_InRecChild[TECLEDA_SOBACC_CF] = "" ;
	ptb_InRecChild[TECLEDA_SOBRET_CF] = "" ;
	ptb_InRecChild[TECLEDA_TOPACC_CF] = "" ;
	ptb_InRecChild[TECLEDA_TOPRET_CF] = "" ;
	ptb_InRecChild[TECLEDA_NATACC_CF] = "" ;
	ptb_InRecChild[TECLEDA_NATRET_CF] = "" ;
	ptb_InRecChild[TECLEDA_GARACC_CF] = "" ;
	ptb_InRecChild[TECLEDA_GARRET_CF] = "" ;
	ptb_InRecChild[TECLEDA_PCPRSKTRYACC_CF] = "" ;
	ptb_InRecChild[TECLEDA_PCPRSKTRYRET_CF] = "" ;
	ptb_InRecChild[TECLEDA_USRCRTCODACC_CT] = "" ;
	ptb_InRecChild[TECLEDA_USRCRTCODRET_CT] = "" ;
	ptb_InRecChild[TECLEDA_USRCRTVALACC_LM] = "" ;
	ptb_InRecChild[TECLEDA_USRCRTVALRET_LM] = "" ;
	ptb_InRecChild[TECLEDA_CTRNAT_CT] = "" ;
	ptb_InRecChild[TECLEDA_RETCTRCAT_CF] = "" ;
	ptb_InRecChild[TECLEDA_WRKCAT_CT] = "" ;
	ptb_InRecChild[TECLEDA_PRDCOD_CT] = "" ;
	ptb_InRecChild[TECLEDA_ANLCTY_CF] = "" ;
	ptb_InRecChild[TECLEDA_ACCADMTYP_CT] = "" ;
	ptb_InRecChild[TECLEDA_RETACCTYP_CT] = "" ;
	ptb_InRecChild[TECLEDA_CTRRET_B] = "0" ;
	ptb_InRecChild[TECLEDA_UWGRP_CF] = "" ;
	ptb_InRecChild[TECLEDA_UWORG_CF] = "" ;
	ptb_InRecChild[TECLEDA_ESTCRB_CT] = "" ;
	ptb_InRecChild[TECLEDA_ESTCTR_NF] = "" ;
	
	ptb_InRecChild[TECLEDA_ESBACC_NF]       =  "";
	ptb_InRecChild[TECLEDA_ORGCED_NF]   =  "";
	ptb_InRecChild[TECLEDA_CEDHORDNBR_NT]   =  "";
	ptb_InRecChild[TECLEDA_CEDSORDNBR_NT]   =  "";
	ptb_InRecChild[TECLEDA_ORGCEDHORDNBR_NT] =  "";
	ptb_InRecChild[TECLEDA_ORGCEDSORDNBR_NT] =  "";
	ptb_InRecChild[TECLEDA_BRKHORDNBR_NT]   =  "";
	ptb_InRecChild[TECLEDA_BRKSORDNBR_NT] =  "";
	ptb_InRecChild[TECLEDA_FACADMTYP_CT]  =  "";
	ptb_InRecChild[TECLEDA_CLIIND_NF]   = "";
	ptb_InRecChild[TECLEDA_HORDNBR_NT]  = "";
	
	/* positionnement du segment et de la version */
	ptb_InRecChild[TECLEDA_VRS_NF] = "" ;
	ptb_InRecChild[TECLEDA_SEG_NF] = "" ;
	
	ptb_InRecChild[TECLEDA_COMACC_B] = "0" ;
	ptb_InRecChild[TECLEDA_CPLACCUPD_D] = "" ;
	ptb_InRecChild[TECLEDA_ORICOD_LS] = "" ;
	
	/* ecriture dans le GTAA en sortie */
	n_WriteCols( Kp_OutputFilGtaa, ptb_InRecChild, SEPARATEUR, 0 ) ;
	
	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  Initialisation de la synchronisation du maitre « Perimetre » avec
  l'esclave « fichier des regroupements d'affaires »

retour :
  OK
==============================================================================*/
int n_InitCtrGro(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_InitCtrGro" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

  /* ouverture du fichier esclave FCTRGRO */
  if ( n_OpenFileAppl( "ESTC8801_I3", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
    return ERR ;

  /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncCtrGro ;

  /* fonction d'action sur la ligne courante */
  pbd_Rupt->n_ActionLigne = n_ActionLigneCtrGro ;

  pbd_Rupt->c_Separ = SEPARATEUR ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  fonction de test de synchronisation

retour :
  0 ---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
  > 0     ---> pbd_InRecOwne> > pbd_InRecChild
  < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncCtrGro(
  char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
  char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
  int ret ;

  DEBUT_FCT( "n_ConditionSyncCtrGro" ) ;

  if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[CTRGRO_CTR_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[CTRGRO_END_NT] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[CTRGRO_SEC_NF] ) ) != 0 ) return ret ;
  // si l'exercice dans CTRGRO est vide ou égale 0 , on considère qu'il y a synchro pour n'importe quel exercice
  if (   *pbd_InRecChild[CTRGRO_UWY_NF] == 0 || *pbd_InRecChild[CTRGRO_UWY_NF] == '0' ) return 0 ;
  // sinon il faut que l'exercie synchronise 
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[CTRGRO_UWY_NF] ) ) != 0 ) return ret ;

  RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
  fonction lancee pour chaque ligne

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneCtrGro(
  char **ptb_InRecOwner , /* adresse de la ligne du maitre */
  char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
  DEBUT_FCT( "n_ActionLigneCtrGro" ) ;

  
	strcpy(CTRGRO_CTR_SYNC,ptb_InRecChild[CTRGRO_CTR_NF]);
	strcpy(CTRGRO_END_SYNC,ptb_InRecChild[CTRGRO_END_NT]);
	strcpy(CTRGRO_SEC_SYNC,ptb_InRecChild[CTRGRO_SEC_NF]);
	strcpy(CTRGRO_UWY_SYNC,ptb_InRecChild[CTRGRO_UWY_NF]);

	  /* recherche du segment et du numero de version */
	  strcpy( Ksz_Seg, ptb_InRecChild[CTRGRO_SEG_NF] ) ;
	  strcpy( Ksz_Vrs, ptb_InRecChild[CTRGRO_VRS_NF] ) ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  Initialisation de la synchronisation du maitre « Perimetre »
  avec l'esclave « fichier des comptes complets »

retour :
  OK
==============================================================================*/
int n_InitCplAcc(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_InitCplAcc" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

  /* ouverture du fichier esclave FCPLACC */
  if ( n_OpenFileAppl( "ESTC8801_I4", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
    return ERR ;

  /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncCplAcc ;

  /* fonction d'action sur la ligne courante */
  pbd_Rupt->n_ActionLigne = n_ActionLigneCplAcc ;

  pbd_Rupt->c_Separ = SEPARATEUR ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  fonction de test de synchronisation

retour :
  0 ---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
  > 0     ---> pbd_InRecOwne> > pbd_InRecChild
  < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncCplAcc(
  char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
  char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
  int ret ;

  DEBUT_FCT( "n_ConditionSyncCplAcc" ) ;

  if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[CMP_CTR_NF] ) ) != 0 ) return ret ;

  RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
  fonction lancee pour chaque ligne

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneCplAcc(
  char **ptb_InRecOwner , /* adresse de la ligne du maitre */
  char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
  DEBUT_FCT( "n_ActionLigneCplAcc" ) ;

  /* recherche de la derniere annee de compte complet */
  if ( atoi( Ksz_Acy ) < atoi( ptb_InRecChild[CMP_ACY_NF] ) )
  {
    strcpy( Ksz_Acy, ptb_InRecChild[CMP_ACY_NF] ) ;
    strcpy( Ksz_CplAccUpd, ptb_InRecChild[CMP_LSTUPD_D] ) ;
  }

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  Initialisation de la synchronisation du maitre « Perimetre »
  avec l’esclave « TOTGTAR »

retour :
  OK
==============================================================================*/
int n_InitTotGtar( T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_InitTotGtar" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

  /* ouverture du fichier esclave TOTGTAR */
  if ( n_OpenFileAppl( "ESTC8801_I5", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
    return ERR ;

  /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncTotGtar ;

  /* fonction d'action sur la ligne courante */
  pbd_Rupt->n_ActionLigne = n_ActionLigneTotGtar ;

  /* fonction d'action quand l'esclave n'a pas de maitre */
  pbd_Rupt->n_FilsSansPere = n_ActionFilsSansPereTotGtar ;

  pbd_Rupt->c_Separ = SEPARATEUR ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  fonction de test de synchronisation

retour :
  0 ---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
  > 0     ---> pbd_InRecOwne> > pbd_InRecChild
  < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncTotGtar(
  char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
  char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
  int ret ;

  DEBUT_FCT( "n_ConditionSyncTotGtar" ) ;

  if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[TECLEDA_CTR_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[TECLEDA_END_NT] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[TECLEDA_SEC_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[TECLEDA_UWY_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[TECLEDA_UW_NT] ) ) != 0 ) return ret ;

  RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
  fonction lancee pour chaque ligne

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneTotGtar(
  char **ptb_InRecOwner , /* adresse de la ligne du maitre */
  char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{

  DEBUT_FCT( "n_ActionLigneTotGtar" ) ;

  /* rajout des champs supplementaire au GT en sortie */
  ptb_InRecChild[TECLEDA_LOBACC_CF] = ptb_InRecOwner[PER_LOB_CF] ;
  ptb_InRecChild[TECLEDA_LOBRET_CF] = "" ;  /* champs non renseigne */
  ptb_InRecChild[TECLEDA_SOBACC_CF] = ptb_InRecOwner[PER_SOB_CF] ;
  ptb_InRecChild[TECLEDA_SOBRET_CF] = "" ;  /* champs non renseigne */
  ptb_InRecChild[TECLEDA_TOPACC_CF] = ptb_InRecOwner[PER_TOP_CF] ;
  ptb_InRecChild[TECLEDA_TOPRET_CF] = "" ;  /* champs non renseigne */
  ptb_InRecChild[TECLEDA_NATACC_CF] = ptb_InRecOwner[PER_NAT_CF] ;
  ptb_InRecChild[TECLEDA_NATRET_CF] = "" ;  /* champs non renseigne */
  ptb_InRecChild[TECLEDA_GARACC_CF] = ptb_InRecOwner[PER_GAR_CF] ;
  ptb_InRecChild[TECLEDA_GARRET_CF] = "" ;  /* champs non renseigne */
  ptb_InRecChild[TECLEDA_PCPRSKTRYACC_CF] = ptb_InRecOwner[PER_PCPRSKTRY_CF] ;
  ptb_InRecChild[TECLEDA_PCPRSKTRYRET_CF] = "" ;  /* champs non renseigne */
  ptb_InRecChild[TECLEDA_USRCRTCODACC_CT] = ptb_InRecOwner[PER_USRCRTCOD_CT] ;
  ptb_InRecChild[TECLEDA_USRCRTCODRET_CT] = "" ;  /* champs non renseigne */
  ptb_InRecChild[TECLEDA_USRCRTVALACC_LM] = ptb_InRecOwner[PER_USRCRTVAL_LM] ;
  ptb_InRecChild[TECLEDA_USRCRTVALRET_LM] = "" ;  /* champs non renseigne */
  ptb_InRecChild[TECLEDA_CTRNAT_CT] = ptb_InRecOwner[PER_CTRNAT_CT] ;
  ptb_InRecChild[TECLEDA_RETCTRCAT_CF] = "" ; /* champs non renseigne */
  ptb_InRecChild[TECLEDA_WRKCAT_CT] = ptb_InRecOwner[PER_WRKCAT_CT] ;
  ptb_InRecChild[TECLEDA_PRDCOD_CT] = Ksz_Prdcod ;
  ptb_InRecChild[TECLEDA_ANLCTY_CF] = ptb_InRecOwner[PER_ANLCTY_CF] ;
  ptb_InRecChild[TECLEDA_ACCADMTYP_CT] = ptb_InRecOwner[PER_ACCADMTYP_CT] ;
  ptb_InRecChild[TECLEDA_RETACCTYP_CT] = "" ; /* champs non renseigne */
  ptb_InRecChild[TECLEDA_CTRRET_B] = ptb_InRecOwner[PER_CTRRET_B] ;
  ptb_InRecChild[TECLEDA_UWGRP_CF] = ptb_InRecOwner[PER_UWGRP_CF] ;
  ptb_InRecChild[TECLEDA_UWORG_CF] = ptb_InRecOwner[PER_UWORG_CF] ;
  ptb_InRecChild[TECLEDA_ESTCRB_CT] = ptb_InRecOwner[PER_ESTCRB_CT] ;
  ptb_InRecChild[TECLEDA_ESTCTR_NF] = ptb_InRecOwner[PER_ESTCTR_NF] ;

  ptb_InRecChild[TECLEDA_ESBACC_NF]       =  ptb_InRecOwner[PER_ACCESB_CF];
  ptb_InRecChild[TECLEDA_ORGCED_NF]   =  ptb_InRecOwner[PER_ORGCED_NF];
  ptb_InRecChild[TECLEDA_CEDHORDNBR_NT]   =  ptb_InRecOwner[PER_CEDHORDNBR_NT];
  ptb_InRecChild[TECLEDA_CEDSORDNBR_NT]   =  ptb_InRecOwner[PER_CEDSORDNBR_NT];
  ptb_InRecChild[TECLEDA_ORGCEDHORDNBR_NT] =  ptb_InRecOwner[PER_ORGCEDHORDNBR_NT];
  ptb_InRecChild[TECLEDA_ORGCEDSORDNBR_NT] =  ptb_InRecOwner[PER_ORGCEDSORDNBR_NT];
  ptb_InRecChild[TECLEDA_BRKHORDNBR_NT]   =  ptb_InRecOwner[PER_BRKHORDNBR_NT];
  ptb_InRecChild[TECLEDA_BRKSORDNBR_NT] =  ptb_InRecOwner[PER_BRKSORDNBR_NT];
  ptb_InRecChild[TECLEDA_FACADMTYP_CT]  =  ptb_InRecOwner[PER_FACADMTYP_B];
  ptb_InRecChild[TECLEDA_CLIIND_NF]   = "";
  ptb_InRecChild[TECLEDA_HORDNBR_NT]  = "";


  /* positionnement du segment et de la version */
  ptb_InRecChild[TECLEDA_VRS_NF] = Ksz_Vrs ;
  ptb_InRecChild[TECLEDA_SEG_NF] = Ksz_Seg ;

  /* positionnement de l'indicateur compte complet */
  if ( atoi( Ksz_Acy ) >= atoi( ptb_InRecChild[TECLEDA_ACY_NF] ) )
  {
    ptb_InRecChild[TECLEDA_COMACC_B] = "1" ;
    ptb_InRecChild[TECLEDA_CPLACCUPD_D] = Ksz_CplAccUpd ;
  }
  else
  {
    ptb_InRecChild[TECLEDA_COMACC_B] = "0" ;
    ptb_InRecChild[TECLEDA_CPLACCUPD_D] = "" ;
  }

  /* ecriture dans le GTAR en sortie */
  n_WriteCols( Kp_OutputFilGtar, ptb_InRecChild, SEPARATEUR, 0 ) ;

  RETURN_VAL( OK ) ;
}

/*==============================================================================
objet :
  fonction lancee quand le fils n'a pas de maitre

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionFilsSansPereTotGtar(
  char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionFilsSansPereTotGtar" ) ;
	
	/* rajout des champs supplementaire au GT en sortie */
	ptb_InRecChild[TECLEDA_LOBACC_CF] = "";
	ptb_InRecChild[TECLEDA_LOBRET_CF] = "" ;
	ptb_InRecChild[TECLEDA_SOBACC_CF] = "";
	ptb_InRecChild[TECLEDA_SOBRET_CF] = "" ;
	ptb_InRecChild[TECLEDA_TOPACC_CF] = "";
	ptb_InRecChild[TECLEDA_TOPRET_CF] = "" ;
	ptb_InRecChild[TECLEDA_NATACC_CF] = "";
	ptb_InRecChild[TECLEDA_NATRET_CF] = "" ;
	ptb_InRecChild[TECLEDA_GARACC_CF] = "";
	ptb_InRecChild[TECLEDA_GARRET_CF] = "";
	ptb_InRecChild[TECLEDA_PCPRSKTRYACC_CF] = "";
	ptb_InRecChild[TECLEDA_PCPRSKTRYRET_CF] = "" ;
	ptb_InRecChild[TECLEDA_USRCRTCODACC_CT] = "";
	ptb_InRecChild[TECLEDA_USRCRTCODRET_CT] = "" ;
	ptb_InRecChild[TECLEDA_USRCRTVALACC_LM] = "";
	ptb_InRecChild[TECLEDA_USRCRTVALRET_LM] = "" ;
	ptb_InRecChild[TECLEDA_CTRNAT_CT] = "";
	ptb_InRecChild[TECLEDA_RETCTRCAT_CF] = "" ;
	ptb_InRecChild[TECLEDA_WRKCAT_CT] = "";
	ptb_InRecChild[TECLEDA_PRDCOD_CT] = "";
	ptb_InRecChild[TECLEDA_ANLCTY_CF] = "";
	ptb_InRecChild[TECLEDA_ACCADMTYP_CT] = "";
	ptb_InRecChild[TECLEDA_RETACCTYP_CT] = "" ;
	ptb_InRecChild[TECLEDA_CTRRET_B] = "0";
	ptb_InRecChild[TECLEDA_UWGRP_CF] = "";
	ptb_InRecChild[TECLEDA_UWORG_CF] = "";
	ptb_InRecChild[TECLEDA_ESTCRB_CT] = "" ;
	ptb_InRecChild[TECLEDA_ESTCTR_NF] = "" ;
	
	ptb_InRecChild[TECLEDA_ESBACC_NF]       =  "";
	ptb_InRecChild[TECLEDA_ORGCED_NF]   =  "";
	ptb_InRecChild[TECLEDA_CEDHORDNBR_NT]   =  "";
	ptb_InRecChild[TECLEDA_CEDSORDNBR_NT]   =  "";
	ptb_InRecChild[TECLEDA_ORGCEDHORDNBR_NT] =  "";
	ptb_InRecChild[TECLEDA_ORGCEDSORDNBR_NT] =  "";
	ptb_InRecChild[TECLEDA_BRKHORDNBR_NT]   =  "";
	ptb_InRecChild[TECLEDA_BRKSORDNBR_NT] =  "";
	ptb_InRecChild[TECLEDA_FACADMTYP_CT]  =  "";
	ptb_InRecChild[TECLEDA_CLIIND_NF]   = "";
	ptb_InRecChild[TECLEDA_HORDNBR_NT]  = "";
	
	/* positionnement du segment et de la version */
	ptb_InRecChild[TECLEDA_VRS_NF] = "";
	ptb_InRecChild[TECLEDA_SEG_NF] = "";
	
	ptb_InRecChild[TECLEDA_COMACC_B] = "0" ;
	ptb_InRecChild[TECLEDA_CPLACCUPD_D] = "" ;
	if ( (strcmp(ptb_InRecChild[TECLEDA_ORICOD_LS], "ESID2561ESTC8805") != 0)  && (strcmp(ptb_InRecChild[TECLEDA_ORICOD_LS], "RECLASSP") != 0 )  && (strcmp(ptb_InRecChild[TECLEDA_ORICOD_LS], "RECLASSL") != 0 )  )    // [005] [006]   
		ptb_InRecChild[TECLEDA_ORICOD_LS]   = "" ;
	
	/* ecriture dans le TotGTAr en sortie */
	n_WriteCols( Kp_OutputFilGtar, ptb_InRecChild, SEPARATEUR, 0 ) ;
	
	RETURN_VAL( OK ) ;
}



/*==============================================================================
objet:
  Lit le fichier binaire et le charge en memoire

==============================================================================*/
int n_ChargerSOBBLOB( void )
{
  int i = 0 ;
  char sz_message[200];

  DEBUT_FCT("n_ChargerSOBBLOB");

  while ( fread( &Ktbd_Sobblob[i], sizeof( T_SOBBLOB ), 1, Kp_InputFilSobblob ) == 1 )
  {
    i += 1 ;
    if ( i > Kn_MaxPostes )
    {

      sprintf(sz_message, "la taille du tableau Ktbd_Sobblob depasse la taille allouee %d", i);
      n_WriteAno(sz_message);
      RETURN_VAL( i );
    }
  }

  RETURN_VAL( i );
}


/*==============================================================================
objet :
  fonction de recherche du produit
retour :
  0   ---> Pas de rupture
  < 0     ---> On n'est pas arrive au bloc synchrone
  > 0     ---> On a depasse le bloc synchrone
==============================================================================*/
char *n_RechProduit( char *sz_lob, char *sz_sob )
{
  int n_indice, ret;

  DEBUT_FCT("n_RechProduit");

  n_indice = 0;

  while (1 == 1)
  {
    /* Comparaison de la Lob */
    ret = strcmp( sz_lob, Ktbd_Sobblob[n_indice].LOB_CF);

    /* si egales, comparaison de la Sob */
    if ( ret == 0 )
    {
      ret = strcmp( sz_sob, Ktbd_Sobblob[n_indice].SOB_CF) ;

      if ( ret == 0 )
      {
				RETURN_VAL( Ktbd_Sobblob[n_indice].PRDCOD_CT ) ;			}
      else  n_indice += 1 ;
    }
    else
    {
      /* Ligne suivante */
      n_indice += 1 ;
    }

    /* Si on est a la fin du tableau, echec */
    if ( n_indice == Kn_NbLigSobblob ) RETURN_VAL( "" );
  }
}
