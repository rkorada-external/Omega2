/*==============================================================================
nom de l'application          : ESTIMATION
nom du source                 : ESTC3603.c
révision                      : $Revision: 1.4 $
date de création              : 16/09/1998
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   	Generation d'un fichier au format de la table TULTIMATES
de l'infocentre.

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
    06/05/2008   J. Ribot    SPOT 15219  ASE15 : modif alimentation des colonnes Kc_Ult_AdmModPrm et  Kc_Ult_AdmModClm
------------------------------
  20/07/2007    D.GATIBELZA  [003]
                             - 15219 ASE15 correction sur la modif précédente
[04] 04/09/2012 :spot:24041 - Ajout parametre segtyp_ct pour Solvency 2                             
[05] 06/04/2014 JBG :spot:25773 Modify void main declaration to int main
[06} 20/11/2014 Florent :spot:27747 enlevé les define du PERExtend_ et mis dans le struc.h, ajout 2 devises tarif
[07} 26/11/2015 Florent :spot:29486 :SPIRA:42208 limite pour des taux passée à 9999.99999999
[08] 11/09/2018 add UWY_NF  spira 57605
[09]  18/02/2019 sauvegarde des infos du maitre pendant la première synchro avec FCTRGROc, car  elle ne se fait pas sur la clé 
 
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include "struct.h"
#include "estserv.h"
#define CTRGRO_UWY_NF 20 //dernier champs

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/


/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/

#define	NB_SEGEST_MAX	10000
#define NB_SOBBLOB_MAX	1000

/* Position des champs dans le fichier des taux places cumules FSHARE */
#define SHA_CTR_NF	0
#define SHA_END_NT	1
#define SHA_SEC_NF	2
#define SHA_UWY_NF	3
#define SHA_UW_NT	4
#define SHA_RETCEDRI_R	5
#define SHA_RETCEDRE_R	6

/* Position des champs dans le fichier des registres d'arrivee FAPR */
#define APR_SSD_CF		0
#define APR_CTR_NF		1
#define APR_SCOENDMTH_NF	2
#define APR_ACY_NF		3

/* Position des champs dans le fichier des registres d'arrivee FAPR */
#define PROT_SSD_CF		0
#define PROT_CTR_NF		1
#define PROT_END_NT		2
#define PROT_SEC_NF		3
#define PROT_UWY_NF		4
#define PROT_UW_NT		5
#define PROT_LAYTYP_CT		6
#define PROT_LAYCOS_M		7
#define PROT_LAYPLCSHA_R	8


/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE 		*Kp_OutputFilUltimates ; /* pointeur sur le fichier de sortie */
FILE 		*Kp_InputFilSegest ;	 /* pointeur sur le fichier binaire FSEGEST */
FILE 		*Kp_InputFilSobblob ;	 /* pointeur sur le fichier binaire FSOBBLOB */
FILE 		*Kp_InputFilExc ; 	 /* pointeur sur le fichier binaire FCURQUOT */
FILE 		*Kp_InputFilCplacc ; 	 /* pointeur sur le fichier binaire FCPLACC */

T_RUPTURE_VAR  	   	bd_RuptPer ; 	/* variable de gestion de la rupture sur le perimetre */
T_RUPTURE_SYNC_VAR 	bd_RuptGro ; 	/* variable de gestion de la synchronisation avec le fichier FCTRGRO */
T_RUPTURE_SYNC_VAR 	bd_RuptUnd ; 	/* variable de gestion de la synchronisation avec le fichier FUNDSTA */
T_RUPTURE_SYNC_VAR 	bd_RuptUlt ; 	/* variable de gestion de la synchronisation avec le fichier FCTRULT */
T_RUPTURE_SYNC_VAR 	bd_RuptApr ; 	/* variable de gestion de la synchronisation avec le fichier FAPR */
T_RUPTURE_SYNC_VAR 	bd_RuptProt ; 	/* variable de gestion de la synchronisation avec le fichier FAMPROT */
T_RUPTURE_SYNC_VAR 	bd_RuptPerFct ; /* variable de gestion de la synchronisation avec le fichier IADPERIFCT */
T_RUPTURE_SYNC_VAR 	bd_RuptCedBil ; /* variable de gestion de la synchronisation avec le fichier FCEDBIL bilan en cours */
T_RUPTURE_SYNC_VAR 	bd_RuptCedAnt ; /* variable de gestion de la synchronisation avec le fichier FCEDANT bilan anterieur */
T_RUPTURE_SYNC_VAR 	bd_RuptCplacc ; /* variable de gestion de la synchronisation avec le fichier FCPLACC */


T_SEGEST	Ktbd_Segest[NB_SEGEST_MAX] ; 	/* tableau permettant de charger en memoire FSEGEST */
int		Kn_NbLig_Segest ;    	/* nombre de postes dans le tableau */

T_SOBBLOB 	Ktbd_Sobblob[NB_SOBBLOB_MAX] ;	/* tableau permettant de charger en memoire FSOBBLOB */
int 		Kn_NbLig_Sobblob ;	/* nombre de postes dans le tableau */

double		Kd_Com ;		/* taux de commission */
double		Kd_Tax ;		/* taux de taxes */

double		Kd_CbiRetCed ;		/* taux de retro de part placee en retro interne bilan en cours */
double		Kd_PbiRetCed ;		/* taux de retro de part placee en retro interne bilan precedent */
double		Kd_CbeRetCed ;		/* taux de retro de part placee en retro externe bilan en cours */
double		Kd_PbeRetCed ;		/* taux de retro de part placee en retro externe bilan precedent */

double 		Kd_EgpRpcc ;		/* aliment RPCC */

int		Kn_Gro_Vrsest ;		/* version active en estimation */
int		Kn_Gro_Vrsact ;		/* version active en actuariat */
char		Ksz_Gro_Segest[11] ;	/* segment en estimation */
char		Ksz_Gro_Segact[11] ;	/* segment en actuariat */

char		Ksz_Und_ComAcc[7] ;	/* derniere periode de compte complet - FUNDSTA */
int 		Kn_Und_ComAcc ;		/* derniere periode de compte complet - FUNDSTA */
double		Kd_Und_CaccPrm ;	/* prime comptes complets - FUNDSTA */
double		Kd_Und_CaccUpr ;	/* PNA comptes complets - FUNDSTA */
double		Kd_Und_CaccClm ;	/* sinistres comptes complets - FUNDSTA */
double		Kd_Und_CaccLoa ;	/* charges comptes complets - FUNDSTA */
double		Kd_Und_CaccAcr ;	/* ACR comptes complets - FUNDSTA */
double		Kd_Und_AccPrm ;		/* prime comptes complets - FUNDSTA */
double		Kd_Und_AccUpr ;		/* PNA comptes complets - FUNDSTA */
double		Kd_Und_AccClm ;		/* sinistres comptes complets - FUNDSTA */
double		Kd_Und_AccLoa ;		/* charges comptes complets - FUNDSTA */
double		Kd_Und_AccAcr ;		/* ACR comptes complets - FUNDSTA */


char		Ksz_Apr_RecAcc[7] ;	/* derniere periode de compte recue - FAPR */

double		Kd_Ult_CalAmtPrm ;	/* aliment propose - FCTRULT */
double		Kd_Ult_EntAmtPrm ;	/* aliment manuel - FCTRULT */
double		Kd_Ult_RetAmtPrm ;	/* aliment retenu - FCTRULT */
char		Kc_Ult_AdmModPrm[2] ;	/* mode de gestion aliment - FCTRULT */      // 06/05/2008 spot 15219
double		Kd_Ult_ResPrm ;		/* prime de BC et Rec - FCTRULT */
double		Kd_Ult_CalAmtClm ;	/* sinistre propose - FCTRULT */
double		Kd_Ult_EntAmtClm ;	/* sinistre manuel - FCTRULT */
double		Kd_Ult_RetAmtClm ;	/* sinistre retenu - FCTRULT */
char		Kc_Ult_AdmModClm[2] ;	/* mode de gestion sinistre - FCTRULT */       // 06/05/2008 spot 15219
char		Ksz_Ult_OriCod[17] ;	/* origine de la position - FCTRULT */
char		Ksz_Ult_Cre[9] ;	/* date de la position - FCTRULT */
char		Ksz_Ult_UpdUsr[11] ;	/* responsable de la position - FCTRULT */

int		Kn_Balshey ; 		/* parametre : annee bilan */
char		Kc_Option ;		/* parametre : 	'I' pour inventaire
							'Q' pour quotidien */
char		Kc_Segtyp ;		/* [004] A pour IFRS, S pour EBS, T pour Post-omega social, U pour Post-omega conso */
//[09]
char CTRGRO_CTR_SYNC[10] ="";
char CTRGRO_END_SYNC[5]  ="";
char CTRGRO_SEC_SYNC[5]   ="";
char CTRGRO_UWY_SYNC[5] ="";

int n_InitPer	 		( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_IsR1Per			( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_IsR2Per			( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_ActionFirstRupt1Per	( char **ptb_InRec_Cur ) ;
int n_ActionFirstRupt2Per	( char **ptb_InRec_Cur ) ;
int n_ActionLignePer		( char **pbd_InRec_Cur ) ;

int n_InitGro			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneGro		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncGro		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitUnd			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneUnd		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncUnd		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitUlt			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneUlt		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncUlt		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitApr			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneApr		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncApr		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitProt			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneProt		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncProt		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitPerFct		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLignePerFct		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncPerFct	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitCedBil		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneCedBil		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncCedBil	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitCedAnt		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneCedAnt		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncCedAnt	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitCplacc			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneCplacc		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncCplacc	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;


int n_ProcessingRuptureSyncVar (
			T_RUPTURE_SYNC_VAR  *pbd_Rupt,
			char **ptb_InRecOwner );

int n_ChargerTSEGEST( void ) ;
int n_RechPosteTSEGEST( int n_vrs, char c_ssd, char c_segtyp, char *sz_seg, int n_uwy ) ;

int n_ChargerSOBBLOB( void ) ;
char *n_RechProduit( char *sz_lob, char *sz_sob ) ;

int n_InitVariables( void ) ;

enum TARIF_PREMIUM_TYPE { FLAT_PREMIUM=0, DEPOSIT_PREMIUM };
double GetPremium( char **pbd_PER_enr, int  iTarifPremium);

/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc  , char *argv[])
{
	char	MsgAno[300] ;
	char	c_ReturnStatus = 0 ;

	/* Initialisation des signaux */
	InitSig () ;

	if ( n_BeginPgm ( argc, argv ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Recuperation des arguments */
        Kn_Balshey = n_GetIntArgv(1) ;
	Kc_Option = *( psz_GetCharArgv(2) ) ;
	Kc_Segtyp = *( psz_GetCharArgv(3) ) ;  // [004]

	/* ouverture du fichier de sortie */
	if ( n_OpenFileAppl ( "ESTC3603_O1","wt",&Kp_OutputFilUltimates ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier en entree FSEGEST */
	if ( n_OpenFileAppl ( "ESTC3603_I2","rb",&Kp_InputFilSegest ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier en entree FSOBBLOB */
	if ( n_OpenFileAppl ( "ESTC3603_I11","rb",&Kp_InputFilSobblob ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier en entree FCURQUOT */
	if ( n_OpenFileAppl ( "ESTC3603_I12","rb",&Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPer */
	if ( n_InitPer( &bd_RuptPer ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptGro */
	if ( n_InitGro( &bd_RuptGro ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptUnd */
	if ( n_InitUnd( &bd_RuptUnd ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptUlt */
	if ( n_InitUlt( &bd_RuptUlt ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptApr */
	if ( n_InitApr( &bd_RuptApr ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptProt */
	if ( n_InitProt( &bd_RuptProt ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPerFct */
	if ( n_InitPerFct( &bd_RuptPerFct ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptCedBil */
	if ( n_InitCedBil( &bd_RuptCedBil ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptCedAnt */
	if ( n_InitCedAnt( &bd_RuptCedAnt ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptCedAnt */
	if ( n_InitCplacc( &bd_RuptCplacc ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Chargement de TSEGEST en memoire */
	Kn_NbLig_Segest = n_ChargerTSEGEST( ) ;

	/* Generation d'une anomalie si la taille du tableau est insuffisante */
	if ( Kn_NbLig_Segest > NB_SEGEST_MAX )
	{
		sprintf( MsgAno, "The size of SEGEST array is too small\n" ) ;
		n_WriteAno ( MsgAno ) ;

		/* code retour du prog = 1 pour arreter la chaine */
		c_ReturnStatus = 1 ;
	}

	/* Chargement des codes produits en memoire */
	Kn_NbLig_Sobblob = n_ChargerSOBBLOB( ) ;

	/* Generation d'une anomalie si la taille du tableau est insuffisante */
	if ( Kn_NbLig_Sobblob > NB_SOBBLOB_MAX )
	{
		sprintf( MsgAno, "The size of SOBBLOB array is too small\n" ) ;
		n_WriteAno ( MsgAno ) ;

		/* code retour du prog = 1 pour arreter la chaine */
		c_ReturnStatus = 1 ;
	}

	/* lancement du traitement du fichier maitre */
	if ( n_ProcessingRuptureVar( &bd_RuptPer ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3603_I1", &( bd_RuptPer.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3603_I2", &Kp_InputFilSegest ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3603_I3", &( bd_RuptGro.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3603_I4", &( bd_RuptUnd.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3603_I5", &( bd_RuptUlt.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3603_I6", &( bd_RuptApr.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3603_I7", &( bd_RuptProt.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3603_I8", &( bd_RuptPerFct.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3603_I9", &( bd_RuptCedBil.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3603_I10", &( bd_RuptCedAnt.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3603_I11", &Kp_InputFilSobblob ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3603_I12", &Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3603_I13", &( bd_RuptCplacc.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3603_O1", &Kp_OutputFilUltimates ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_EndPgm() == ERR )
		ExitPgm( ERR_XX , "" );

	exit( c_ReturnStatus ) ;
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
	if ( n_OpenFileAppl( "ESTC3603_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	pbd_Rupt->n_NbRupture = 2 ;

	/* fonction du test de rupture de niveau 1 */
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1Per ;

	/* fonction du test de rupture de niveau 2 */
	pbd_Rupt->n_ConditionRupture[1] = n_IsR2Per ;

	/* Fonction lancee en rupture premiere */
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRupt1Per ;

	/* Fonction lancee en rupture premiere */
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
	0	---> pas de rupture
	sinon   	---> rupture
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
	fonction de test de rupture de niveau 2

retour :
	0	---> pas de rupture
	sinon   	---> rupture
==============================================================================*/
int n_IsR2Per(
	char **pbd_InRec ,  /* adresse de la ligne en avance */
	char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
	int ret ;

	DEBUT_FCT( "n_IsR2Per" ) ;

	if ( ( ret = strcmp( pbd_InRec[PER_CTR_NF], pbd_InRec_Cur[PER_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRec[PER_END_NT] ) - atoi( pbd_InRec_Cur[PER_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRec[PER_SEC_NF] ) - atoi( pbd_InRec_Cur[PER_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRec[PER_UWY_NF] ) - atoi( pbd_InRec_Cur[PER_UWY_NF] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture premiere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRupt1Per( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionFirstRupt1Per" ) ;

	/* Initialisation de la derniere periode recue */
	*Ksz_Apr_RecAcc = 0 ;

	/* Synchronisation avec le fichier des registres d'arrivee */
	n_ProcessingRuptureSyncVar( &bd_RuptApr, ptb_InRec_Cur ) ;

	/* Synchronisation avec le fichier des comptes complets */
	Kn_Und_ComAcc = 0;
	n_ProcessingRuptureSyncVar( &bd_RuptCplacc, ptb_InRec_Cur ) ;

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture premiere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRupt2Per( char **ptb_InRec_Cur )
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
		/* Initialisation des champs */
		Kn_Gro_Vrsest = 0 ;
		Kn_Gro_Vrsact = 0 ;
		strcpy( Ksz_Gro_Segest, "" ) ;
		strcpy( Ksz_Gro_Segact, "" ) ;

		/* Synchronisation avec le fichier des regroupement d'affaires */
		n_ProcessingRuptureSyncVar( &bd_RuptGro, ptb_InRec_Cur ) ;

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
	char	*sz_vide = "" ;		/* chaine vide */
	char	MsgAno[300] ;		/* message d'anomalie */
	int 	n_ret_act ;		/* position dans FSEGEST pour Segtyp = 'A' */
	int 	n_ret_est ;		/* position dans FSEGEST pour segtyp = 'E' */

	char	c_Ssd = 0 ;		/* filiale */
	int	n_Uwy = 0 ;		/* exercice */
	char	*psz_PrdCod ;	/* code produit FAC */
	char	*psz_MinCom = "" ;	/* taux de commission mini */
	double	d_SurCom = 0 ;		/* taux de surcommission */
	char	sz_SurCom[15] = "" ;	/* taux de surcommission */
	char	sz_Tax[15] = "" ;	/* taux de taxes */
	double  d_Brk = 0 ;		/* taux de courtage */
	double	d_ScoSha = 0 ;		/* part SCOR */
	char	c_Quot ;		/* indicateur tarification */
	double 	d_Ratio ;		/* taux de conversion */
	char	sz_EgpRpcc[30] ;	/* aliment RPCC */
	char	sz_FlaPrm[30] ;		/* prime forfaitaire */
	char	sz_PrvPrm[30] ;		/* prime provisionnelle */
	char	*psz_EffSha = "" ;	/* taux effectif */
	char	*psz_ActSha = "" ;	/* taux actuariel */
	char	*psz_SbjPrm = "" ;	/* assiette de souscription */
	double	d_SbjPrm = 0 ;		/* assiette de souscription */
	double	d_SbjPrmCpt = 0 ;	/* assiette comptable */
	double 	d_CaccErnPrm = 0 ;	/* prime acquise comptes complets */
	double 	d_CaccPmlRat = 0 ;	/* ratio S/P comptes complets */
	double 	d_CaccLoa = 0 ;		/* ratio C/P comptes complets */
	double 	d_CaccRes = 0 ;		/* ratio R/P comptes complets */
	double 	d_AccErnPrm = 0 ;	/* prime acquise comptes incomplets */
	double 	d_AccPmlRat = 0 ;	/* ratio S/P comptes incomplets */
	double 	d_AccLoa = 0 ;		/* ratio C/P comptes incomplets */
	double 	d_AccRes = 0 ;		/* ratio R/P comptes incomplets */
	double 	d_UltPmlRat = 0 ;	/* ratio S/P ultimes retenus */
	unsigned char c_CtrRet = 0 ;	/* retro interne */
	unsigned char c_PrmPrtScl = 0 ;	/* indicateur de portefeuille echelonne */
	unsigned char c_ErnPrmAdm = 0 ;	/* indicateur prime acquise - emise */
	unsigned char c_ReiExi = 0 ;	/* presence de reconstitution */
	unsigned char c_ReiFre = 0 ;	/* reconstitution gratuite */
	unsigned char c_PrfComExi = 0 ;	/* presence de PB */
	unsigned char c_LosCtbExi = 0 ;	/* presence de PAP */
	unsigned char c_LosCorExi = 0 ;	/* presence de Loss */
	unsigned char c_SbjCptDef = 0 ;	/* top assiette definitive */


	DEBUT_FCT( "n_ActionLignePer" ) ;

	/* Conversion de champs avant calcul */
	/*************************************/
	c_Ssd = (char) atoi( ptb_InRec_Cur[PER_SSD_CF] ) ;
	n_Uwy = atoi( ptb_InRec_Cur[PER_UWY_NF] ) ;

	c_CtrRet = (char) atoi( ptb_InRec_Cur[PER_CTRRET_B] ) ;
	c_PrmPrtScl = (char) atoi( ptb_InRec_Cur[PER_PRMPRTSCL_B] ) ;
	c_ErnPrmAdm = (char) atoi( ptb_InRec_Cur[PER_ERNPRMADM_B] ) ;
	c_ReiExi = (char) atoi( ptb_InRec_Cur[PER_REIEXI_B] ) ;
	c_ReiFre = (char) atoi( ptb_InRec_Cur[PER_REIFRE_B] ) ;
	c_PrfComExi = (char) atoi( ptb_InRec_Cur[PER_PRFCOMEXI_B] ) ;
	c_LosCtbExi = (char) atoi( ptb_InRec_Cur[PER_LOSCTBEXI_B] ) ;
	c_LosCorExi = (char) atoi( ptb_InRec_Cur[PER_LOSCOREXI_B] ) ;
	c_SbjCptDef = (char) atoi( ptb_InRec_Cur[PER_SBJCPTDEF_B] ) ;


	/* Initialisation des variables */
	/********************************/
	n_InitVariables( ) ;        //[003]


	/********************************************/
	/* Synchronisation avec les autres fichiers */
	/********************************************/
	n_ProcessingRuptureSyncVar( &bd_RuptUnd, ptb_InRec_Cur ) ;
	n_ProcessingRuptureSyncVar( &bd_RuptUlt, ptb_InRec_Cur ) ;
	n_ProcessingRuptureSyncVar( &bd_RuptProt, ptb_InRec_Cur ) ;
	n_ProcessingRuptureSyncVar( &bd_RuptCedBil, ptb_InRec_Cur ) ;
	n_ProcessingRuptureSyncVar( &bd_RuptCedAnt, ptb_InRec_Cur ) ;
	/*n_ProcessingRuptureSyncVar( &bd_RuptCplacc, ptb_InRec_Cur ) ; */


	/*************************************/
	/* Determination des champs calcules */
	/*************************************/

	/* recherche du code produit - FAC uniquement */
	/**********************************************/
	if ( *ptb_InRec_Cur[PER_CTRNAT_CT] == 'F' )
	{
		psz_PrdCod = n_RechProduit( ptb_InRec_Cur[PER_LOB_CF], ptb_InRec_Cur[PER_SOB_CF] ) ;
	}
	else	psz_PrdCod = sz_vide ;


	/* calcul des taux de commission */
	/*********************************/
	if ( *ptb_InRec_Cur[PER_COMTYP_CT] == '2' )
	{
		Kd_Com = atof( ptb_InRec_Cur[PER_MAXCOM_R] ) ;
		psz_MinCom = ptb_InRec_Cur[PER_MINCOM_R] ;
	}
	else
	{
		if ( *ptb_InRec_Cur[PER_COMTYP_CT] == 0 )
		{
			Kd_Com = 0 ;
			psz_MinCom = sz_vide ;
		}
		else
		{
			Kd_Com = atof( ptb_InRec_Cur[PER_FIXCOM_R] ) ;
			psz_MinCom = sz_vide ;
		}
	}


	/* calcul du taux de surcommission */
	/***********************************/
	if ( *ptb_InRec_Cur[PER_OVRCOMTYP_CT] == '0' )
	{
		d_SurCom = atof( ptb_InRec_Cur[PER_OVRCOM_R] ) ;
		sprintf( sz_SurCom, "%-.8f", d_SurCom ) ;
	}

	if ( *ptb_InRec_Cur[PER_OVRCOMTYP_CT] == '1' )
	{
		d_SurCom = atof( ptb_InRec_Cur[PER_OVRCOM_R] ) * ( 1 - Kd_Com ) ;
		sprintf( sz_SurCom, "%-.8f", d_SurCom ) ;
	}


	/* synchro avec le perimetre des charges de taxes 	*/
	/* Attention ! la place de cette synchro est importante */
	/********************************************************/
	n_ProcessingRuptureSyncVar( &bd_RuptPerFct, ptb_InRec_Cur ) ;


	/* calcul du taux de taxes */
	/***************************/
	if ( *ptb_InRec_Cur[PER_TAXCNDEXI_B] == '1' )
	{
		Kd_Tax = ( fabs( Kd_Tax ) > 1 ? 0 : Kd_Tax ) ;
		sprintf( sz_Tax, "%-.8f", Kd_Tax ) ;
	}


	/* calcul du taux de courtage */
	/******************************/
	if ( *ptb_InRec_Cur[PER_PRDBRKTYP_CT] == '0' )
		d_Brk = atof( ptb_InRec_Cur[PER_PRDBRK_R] ) ;

	/* cas ou le taux de courtage 1 est exprime sur prime nette */
	if ( *ptb_InRec_Cur[PER_PRDBRKTYP_CT] == '1' )
		d_Brk = atof( ptb_InRec_Cur[PER_PRDBRK_R] ) * ( 1 - Kd_Com ) ;

	/* cas ou le taux de courtage 2 est exprime sur prime brute */
	if ( *ptb_InRec_Cur[PER_ACCBRKTYP_CT] == '0' )
		d_Brk += atof( ptb_InRec_Cur[PER_ACCBRK_R] ) ;

	/* cas ou le taux de courtage 2 est exprime sur prime nette */
	if ( *ptb_InRec_Cur[PER_ACCBRKTYP_CT] == '1' )
		d_Brk += atof( ptb_InRec_Cur[PER_ACCBRK_R] ) * ( 1 - Kd_Com ) ;


	/* calcul de l'assiette de souscription et conversions en monnaie aliment */
	/**************************************************************************/
	if ( *ptb_InRec_Cur[PER_DEFSBJPRM_M] == 0 )
		psz_SbjPrm = ptb_InRec_Cur[PER_ESTSBJPRM_M] ;
	else	psz_SbjPrm = ptb_InRec_Cur[PER_DEFSBJPRM_M] ;

	d_SbjPrm = atof( psz_SbjPrm ) ;
	d_SbjPrmCpt = atof( ptb_InRec_Cur[PER_SBJPRMCPT_M] ) ;

   if ( *ptb_InRec_Cur[PER_CTRNAT_CT] == 'N')
   {

	if ( strcmp( ptb_InRec_Cur[PER_EGPCUR_CF], ptb_InRec_Cur[PER_SBJPRMCUR_CF] ) != 0 )
	{
		d_Ratio = d_GetTaux( Kp_InputFilExc,
				c_Ssd,
				n_Uwy - 1,
				ptb_InRec_Cur[PER_SBJPRMCUR_CF],
				ptb_InRec_Cur[PER_EGPCUR_CF] ) ;

		/* generation d'une anomalie si pas de cours trouve */
		if ( d_Ratio < 0 )
                  {
		/*FCharles le 20/02/2001 deja repertorie dans le ESTC0103
			sprintf( MsgAno, "The rates of EGPI currency ( %s ) and subject premium currency ( %s ) aren't known in %d for the contract ( CTR_NF %s - END_NT %s - SEC_NF %s - UWY_NF %s - UW_NT %s )\n",
			ptb_InRec_Cur[PER_EGPCUR_CF],
			ptb_InRec_Cur[PER_SBJPRMCUR_CF],
			n_Uwy - 1,
			ptb_InRec_Cur[PER_CTR_NF],
			ptb_InRec_Cur[PER_END_NT],
			ptb_InRec_Cur[PER_SEC_NF],
			ptb_InRec_Cur[PER_UWY_NF],
			ptb_InRec_Cur[PER_UW_NT] ) ;

			n_WriteAno( MsgAno ) ;
*/
			/* les assiettes de prime sont forcees a zero */
/*			d_SbjPrm = 0 ;
			d_SbjPrmCpt = 0 ;*/
		}
	}
	else	d_Ratio = 1 ;

	d_SbjPrm *= d_Ratio ;
	d_SbjPrmCpt *= d_Ratio ;
   }


	/* calcul de la part SCOR  */
	/***************************/
	if (( *ptb_InRec_Cur[PER_LIARIDSHA_B] == '0' ) && ( *ptb_InRec_Cur[PER_CTRNAT_CT] != 'F'))
		d_ScoSha = atof( ptb_InRec_Cur[PER_RIDSHA_R] ) * atof( ptb_InRec_Cur[PER_CUTSHA_R] ) ;
	else	d_ScoSha = atof( ptb_InRec_Cur[PER_CUTSHA_R] ) ;


	/* calcul indicateur de tarification  */
	/**************************************/
	if ( *ptb_InRec_Cur[PER_FLAPRM_B] == '1' )
		c_Quot = 'P' ;		/* prime forfaitaire */
	else
	{
		if ( *ptb_InRec_Cur[PER_PRMFLCRAT_B] == '1' )
			c_Quot = 'V' ;	/* variable */
		else	c_Quot = 'F' ;	/* fixe */
	}


	/* calcul du taux effectif */
	/***************************/
	if ( *ptb_InRec_Cur[PER_PRMFLCRAT_B] == '0' )
		psz_EffSha = ptb_InRec_Cur[PER_PRMFIXEFF_R] ;

	if ( *ptb_InRec_Cur[PER_PRMFLCRAT_B] == '1' )
		psz_EffSha = ptb_InRec_Cur[PER_PRMMINEFF_R] ;


	/* calcul du taux actuariel */
	/****************************/
	if ( *ptb_InRec_Cur[PER_PRMFLCRAT_B] == '0' )
		psz_ActSha = ptb_InRec_Cur[PER_PRMFIXACT_R] ;

	if ( *ptb_InRec_Cur[PER_PRMFLCRAT_B] == '1' )
		psz_ActSha = ptb_InRec_Cur[PER_PRMMINACT_R] ;


	/* conversion de l'aliment RPCC en monnaie aliment */
	/***************************************************/
	if ( *ptb_InRec_Cur[PER_CTRNAT_CT] == 'F' && Kd_EgpRpcc != 0)
	{
		if ( strcmp( ptb_InRec_Cur[PER_PRTCUR_CF], ptb_InRec_Cur[PER_EGPCUR_CF] ) != 0 )
		{
			d_Ratio = d_GetTaux( Kp_InputFilExc,
				c_Ssd,
				n_Uwy - 1,
				ptb_InRec_Cur[PER_PRTCUR_CF],
				ptb_InRec_Cur[PER_EGPCUR_CF] ) ;
		}
		else 	d_Ratio = 1 ;

		/* generation d'une anomalie si pas de cours trouve */
		if ( d_Ratio < 0 )
		{
			sprintf( MsgAno, "The rates of EGPI currency ( %s ) and protection currency ( %s ) aren't known in %d for the contract ( CTR_NF %s - END_NT %s - SEC_NF %s - UWY_NF %s - UW_NT %s )\n",
			ptb_InRec_Cur[PER_EGPCUR_CF],
			ptb_InRec_Cur[PER_PRTCUR_CF],
			n_Uwy - 1,
                        ptb_InRec_Cur[PER_CTR_NF],
                        ptb_InRec_Cur[PER_END_NT],
                        ptb_InRec_Cur[PER_SEC_NF],
                        ptb_InRec_Cur[PER_UWY_NF],
                        ptb_InRec_Cur[PER_UW_NT] ) ;

			n_WriteAno( MsgAno ) ;

			/* aliment RPCC est force a zero */
			Kd_EgpRpcc = 0 ;
		}
		else 	Kd_EgpRpcc *= d_Ratio ;

		Kd_EgpRpcc = ( fabs( Kd_EgpRpcc ) > 999999999999999.000 ? 999999999999999.000 : Kd_EgpRpcc ) ;

		sprintf( sz_EgpRpcc, "%-.3f", Kd_EgpRpcc ) ;
	}
	else	strcpy( sz_EgpRpcc, sz_vide ) ;


	/* calcul de la prime forfaitaire en monnaie aliment */
	/*****************************************************/
	if ( *ptb_InRec_Cur[PER_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[PER_FLAPRM_B] == '1' )
	{
		sprintf( sz_FlaPrm, "%-.3f", GetPremium(ptb_InRec_Cur, FLAT_PREMIUM) ) ;
	}
	else 	strcpy( sz_FlaPrm, sz_vide ) ;


	/* calcul de la PMD en monnaie aliment */
	/***************************************/
	if ( *ptb_InRec_Cur[PER_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[PER_PRVPRM_B] == '1' )
	{
		/* cas : prime provisionnelle 1 */
		sprintf(sz_PrvPrm, "%-.3f", GetPremium(ptb_InRec_Cur, DEPOSIT_PREMIUM));
	}
	else	strcpy( sz_PrvPrm, sz_vide ) ;


	/* Recherche dans le fichier FSEGEST */
	/*************************************/

	/* pour l'actuariat */
	n_ret_act = n_RechPosteTSEGEST( Kn_Gro_Vrsact, c_Ssd, Kc_Segtyp, Ksz_Gro_Segact, n_Uwy ) ;  // [004]

	/* pour le controle des estimations */
	n_ret_est = n_RechPosteTSEGEST( Kn_Gro_Vrsest, c_Ssd, 'E', Ksz_Gro_Segest, n_Uwy ) ;


	/* Montants comptabilises */
	/**************************/
	d_CaccErnPrm = Kd_Und_CaccPrm + Kd_Und_CaccUpr ;
	d_CaccPmlRat = ( d_CaccErnPrm == 0 ? 0 : Kd_Und_CaccClm / d_CaccErnPrm ) ;
	d_CaccLoa = ( d_CaccErnPrm == 0 ? 0 : Kd_Und_CaccLoa / d_CaccErnPrm ) ;
	d_CaccRes = ( d_CaccErnPrm == 0 ? 0 : ( d_CaccErnPrm + Kd_Und_CaccClm + Kd_Und_CaccLoa ) / d_CaccErnPrm ) ;

	d_AccErnPrm = Kd_Und_AccPrm + Kd_Und_AccUpr ;
	d_AccPmlRat = ( d_AccErnPrm == 0 ? 0 : Kd_Und_AccClm / d_AccErnPrm ) ;
	d_AccLoa = ( d_AccErnPrm == 0 ? 0 : Kd_Und_AccLoa / d_AccErnPrm ) ;
	d_AccRes = ( d_AccErnPrm == 0 ? 0 : ( d_AccErnPrm + Kd_Und_AccClm + Kd_Und_AccLoa ) / d_AccErnPrm ) ;


	/* Ratio S/P ultimes */
	/*********************/
	d_UltPmlRat = ( Kd_Ult_RetAmtPrm == 0 ? 0 : ( Kd_Ult_RetAmtClm / (Kd_Ult_RetAmtPrm * 100 ) ) ) ;
	/* Modif OG 12/07/01, S/P liquide Traite est a present stocke en 1 pour 10000, division supple par 100 */


	/************************************************************************/
	/* Remarque : les 6 derniers champs concernant la segmentation		*/
	/* client sont pour l'instant forces a NULL; la regle de gestion	*/
	/* n'est pas encore figee.						*/
	/************************************************************************/


	/*********************************/
	/* Ecriture du fichier en sortie */
	/*********************************/
//                                 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46    47 48 49 50    51 52 53 54 55 56    57    58    59    60 61    62    63 64    65 66 67 68 69 70 71 72 73 74 75    76    77    78 79    80    81    82 83    84    85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 00 01 02 03 04 05 06 07    08    09    10    11    12    13    14    15    16    17    18    19    20    21    22    23    24    25    26    27    28    29    30    31    32    33    34    35    36    37    38    39    40    41    42    43    44    45    46    47    48    49    50    51    52    53    54    55    56    57    58    59    60    61    62    63    64    65    66    67    68    69    70    71    72    73    74    75    76    77    78    79    80    81    82    83    84    85    86    87    88    89    90    91    92    93    94    95    96    97 98 99 00 01 02 03 04 05
	fprintf( Kp_OutputFilUltimates, "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%d~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%d~%s~%d~%d~%s~%s~%s~%-.8f~%s~%s~%s~%-.8f~%d~%d~%d~%d~%d~%-.8f~%-.8f~%-.8f~%-.8f~%s~%-.3f~%-.3f~%d~%-.8f~%s~%s~%c~%s~%s~%s~%s~%s~%s~%s~%-.3f~%-.3f~%-.3f~%s~%-.3f~%-.3f~%-.3f~%s~%-.3f~%-.8f~%s~%s~%s~%s~%s~%s~%d~%s~%s~%c~%-.3f~%-.3f~%-.8f~%d~%s~%s~%c~%-.3f~%-.3f~%-.8f~%-.3f~%-.3f~%-.8f~%-.8f~%-.8f~%-.3f~%-.3f~%-.3f~%-.8f~%-.8f~%-.8f~%-.3f~%s~%s~%s~%s~%s~%s~%s\n",
		ptb_InRec_Cur[PER_CTR_NF],
		ptb_InRec_Cur[PER_END_NT],
		ptb_InRec_Cur[PER_SEC_NF],
		ptb_InRec_Cur[PER_UWY_NF],
		ptb_InRec_Cur[PER_UW_NT],
		ptb_InRec_Cur[PER_SSD_CF],
		ptb_InRec_Cur[PER_ACCESB_CF],
		ptb_InRec_Cur[PER_SECINC_D],
		ptb_InRec_Cur[PER_EXP_D],
		ptb_InRec_Cur[PER_DIFMTH_NF],
		ptb_InRec_Cur[PER_CTRNAT_CT],
		c_CtrRet,
		ptb_InRec_Cur[PER_SECSTS_CT],
		ptb_InRec_Cur[PER_LOB_CF],
		ptb_InRec_Cur[PER_TOP_CF],
		ptb_InRec_Cur[PER_SOB_CF],
		psz_PrdCod,
		ptb_InRec_Cur[PER_NAT_CF],
		ptb_InRec_Cur[PER_GAR_CF],
		ptb_InRec_Cur[PER_DIV_NT],
		ptb_InRec_Cur[PER_PCPRSKTRY_CF],
		ptb_InRec_Cur[PER_USRCRTCOD_CT],
		ptb_InRec_Cur[PER_USRCRTVAL_LM],
		ptb_InRec_Cur[PER_SECQUA_CF],
		ptb_InRec_Cur[PER_SECQUA2_CF],
		ptb_InRec_Cur[PER_SECQUA3_CF],
		ptb_InRec_Cur[PER_SECQUA4_CF],
		ptb_InRec_Cur[PER_SECQUA5_CF],
		ptb_InRec_Cur[PER_WRKCAT_CT],
		ptb_InRec_Cur[PER_UWGRP_CF],
		ptb_InRec_Cur[PER_ADMGRP_CF],
		ptb_InRec_Cur[PER_UWORG_CF],
		ptb_InRec_Cur[PER_ANLCTY_CF],
		ptb_InRec_Cur[PER_CED_NF],
		ptb_InRec_Cur[PER_ORGCED_NF],
		ptb_InRec_Cur[PER_PRD_NF],
		ptb_InRec_Cur[PER_REITYP_CF],
		ptb_InRec_Cur[PER_ACCADMTYP_CT],
		ptb_InRec_Cur[PER_SECACCSTS_CT],
		ptb_InRec_Cur[PER_ACCFRQ_CT],
		Kn_Und_ComAcc,
		Ksz_Apr_RecAcc,
		c_PrmPrtScl,
		c_ErnPrmAdm,
		ptb_InRec_Cur[PER_INSPOL_R],
		ptb_InRec_Cur[PER_POLDURMTH_NF],
		ptb_InRec_Cur[PER_COMTYP_CT],
		Kd_Com,
		psz_MinCom,
		sz_SurCom,
		sz_Tax,
		( fabs( d_Brk ) > 9.99 ? 0 : d_Brk ),
		c_ReiExi,
		c_ReiFre,
		c_PrfComExi,
		c_LosCtbExi,
		c_LosCorExi,
		( fabs( Kd_CbiRetCed ) > 9.99 ? 0 : Kd_CbiRetCed ),
		( fabs( Kd_PbiRetCed ) > 9.99 ? 0 : Kd_PbiRetCed ),
		( fabs( Kd_CbeRetCed ) > 9.99 ? 0 : Kd_CbeRetCed ),
		( fabs( Kd_PbeRetCed ) > 9.99 ? 0 : Kd_PbeRetCed ),
		ptb_InRec_Cur[PER_EGPCUR_CF],
		( fabs( d_SbjPrm ) > 999999999999999.000 ? 999999999999999.000 : d_SbjPrm ),
		( fabs( d_SbjPrmCpt ) > 999999999999999.000 ? 999999999999999.000 : d_SbjPrmCpt ),
		c_SbjCptDef,
		( fabs( d_ScoSha ) > 9.99 ? 0 : d_ScoSha ),
		ptb_InRec_Cur[PER_PMLRAT_R],
		ptb_InRec_Cur[PER_SCOEGP_M],
		c_Quot,
		psz_EffSha,
		ptb_InRec_Cur[PER_PRMMAXEFF_R],
		psz_ActSha,
		ptb_InRec_Cur[PER_PRMMAXACT_R],
		ptb_InRec_Cur[PER_CLMPRMACT_R],
		ptb_InRec_Cur[PER_PRMPRT_M],
		sz_EgpRpcc,
		Kd_Ult_CalAmtPrm,
		Kd_Ult_EntAmtPrm,
		Kd_Ult_RetAmtPrm,
		Kc_Ult_AdmModPrm,
		Kd_Ult_CalAmtClm,
		Kd_Ult_EntAmtClm,
		Kd_Ult_RetAmtClm,
		Kc_Ult_AdmModClm,
		Kd_Ult_ResPrm,
		( fabs( d_UltPmlRat ) > 9999.99999999 ? 0 : d_UltPmlRat ),
		Ksz_Ult_Cre,
		Ksz_Ult_OriCod,
		Ksz_Ult_UpdUsr,
		sz_FlaPrm,
		sz_PrvPrm,
		ptb_InRec_Cur[PER_LAYCAP_M],
		Kn_Gro_Vrsest,
		Ksz_Gro_Segest,
		( n_ret_est < 0 ? sz_vide : Ktbd_Segest[n_ret_est].CUR_CF ),
		( n_ret_est < 0 ? ' ' : Ktbd_Segest[n_ret_est].AMORAT_CT ),
		( n_ret_est < 0 ? 0 : Ktbd_Segest[n_ret_est].PRMAMT_M ),
		( n_ret_est < 0 ? 0 : Ktbd_Segest[n_ret_est].CLMAMT_M ),
		( n_ret_est < 0 ? 0 : Ktbd_Segest[n_ret_est].LOSRAT_R ),
		Kn_Gro_Vrsact,
		Ksz_Gro_Segact,
		( n_ret_act < 0 ? sz_vide : Ktbd_Segest[n_ret_act].CUR_CF ),
		( n_ret_act < 0 ? ' ' : Ktbd_Segest[n_ret_act].AMORAT_CT ),
		( n_ret_act < 0 ? 0 : Ktbd_Segest[n_ret_act].PRMAMT_M ),
		( n_ret_act < 0 ? 0 : Ktbd_Segest[n_ret_act].CLMAMT_M ),
		( n_ret_act < 0 ? 0 : Ktbd_Segest[n_ret_act].LOSRAT_R ),
		Kd_Und_CaccPrm,
		( fabs( d_CaccErnPrm ) > 999999999999999.000 ? 999999999999999.000 : d_CaccErnPrm ),
		( fabs( d_CaccPmlRat ) > 9999.99999999 ? 0 : d_CaccPmlRat ),
		( fabs( d_CaccLoa ) > 9999.99999999 ? 0 : d_CaccLoa ),
		( fabs( d_CaccRes ) > 9999.99999999 ? 0 : d_CaccRes ),
		Kd_Und_CaccAcr,
		Kd_Und_AccPrm,
		( fabs( d_AccErnPrm ) > 999999999999999.000 ? 999999999999999.000 : d_AccErnPrm ),
		( fabs( d_AccPmlRat ) > 9999.99999999 ? 0 : d_AccPmlRat ),
		( fabs( d_AccLoa ) > 9999.99999999 ? 0 : d_AccLoa ),
		( fabs( d_AccRes ) > 9999.99999999 ? 0 : d_AccRes ),
		Kd_Und_AccAcr,
                ptb_InRec_Cur[PER_CEDHORDNBR_NT],
                ptb_InRec_Cur[PER_CEDSORDNBR_NT],
                ptb_InRec_Cur[PER_ORGCEDHORDNBR_NT],
                ptb_InRec_Cur[PER_ORGCEDSORDNBR_NT],
                ptb_InRec_Cur[PER_BRKHORDNBR_NT],
                ptb_InRec_Cur[PER_BRKSORDNBR_NT],
		ptb_InRec_Cur[PER_FACADMTYP_B]) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l’esclave

retour :
	OK
==============================================================================*/
int n_InitGro( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitGro" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC3603_I3", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncGro ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneGro ;

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
int n_ConditionSyncGro(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncGro" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[CTRGRO_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_END_NT] ) - atoi( pbd_InRecChild[CTRGRO_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_SEC_NF] ) - atoi( pbd_InRecChild[CTRGRO_SEC_NF] ) ) != 0 ) return ret ;
	// si l'exercice dans CTRGRO est vide ou égale 0 , on considère qu'il y a synchro pour n'importe quel exercice
	if (   *pbd_InRecChild[CTRGRO_UWY_NF] == 0 || *pbd_InRecChild[CTRGRO_UWY_NF] == '0' ) return 0 ;
	// sinon il faut que l'exercie synchronise 
	if ( ( ret = atoi( pbd_InRecOwner[PER_UWY_NF] ) - atoi( pbd_InRecChild[CTRGRO_UWY_NF] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGro(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneGro" ) ;
	
	strcpy(CTRGRO_CTR_SYNC,ptb_InRecChild[CTRGRO_CTR_NF]);
	strcpy(CTRGRO_END_SYNC,ptb_InRecChild[CTRGRO_END_NT]);
	strcpy(CTRGRO_SEC_SYNC,ptb_InRecChild[CTRGRO_SEC_NF]);
	strcpy(CTRGRO_UWY_SYNC,ptb_InRecChild[CTRGRO_UWY_NF]);


	/* Sauvegarde de la version et du segment */
	if ( *ptb_InRecChild[CTRGRO_SEGTYP_CT] == 'A' )
	{
		Kn_Gro_Vrsact = atoi( ptb_InRecChild[CTRGRO_VRS_NF] ) ;
		strcpy( Ksz_Gro_Segact, ptb_InRecChild[CTRGRO_SEG_NF] ) ;
	}

	if ( *ptb_InRecChild[CTRGRO_SEGTYP_CT] == 'E' )
	{
		Kn_Gro_Vrsest = atoi( ptb_InRecChild[CTRGRO_VRS_NF] ) ;
		strcpy( Ksz_Gro_Segest, ptb_InRecChild[CTRGRO_SEG_NF] ) ;
	}

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l’esclave

retour :
	OK
==============================================================================*/
int n_InitUnd( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitUnd" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC3603_I4", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncUnd ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneUnd ;

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
int n_ConditionSyncUnd(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncUnd" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[UND_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_END_NT] ) - atoi( pbd_InRecChild[UND_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_SEC_NF] ) - atoi( pbd_InRecChild[UND_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_UWY_NF] ) - atoi( pbd_InRecChild[UND_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_UW_NT] ) - atoi( pbd_InRecChild[UND_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneUnd(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneUnd" ) ;


	Kd_Und_CaccPrm = atof( ptb_InRecChild[UND_CACCPRM_M] ) ;
	Kd_Und_CaccUpr = atof( ptb_InRecChild[UND_CACCUPR_M] ) ;
	Kd_Und_CaccClm = atof( ptb_InRecChild[UND_CACCCLM_M] ) ;
	Kd_Und_CaccLoa = atof( ptb_InRecChild[UND_CACCLOA_M] ) ;
	Kd_Und_CaccAcr = atof( ptb_InRecChild[UND_CACCACR_M] ) ;

	Kd_Und_AccPrm = atof( ptb_InRecChild[UND_ACCPRM_M] ) ;
	Kd_Und_AccUpr = atof( ptb_InRecChild[UND_ACCUPR_M] ) ;
	Kd_Und_AccClm = atof( ptb_InRecChild[UND_ACCCLM_M] ) ;
	Kd_Und_AccLoa = atof( ptb_InRecChild[UND_ACCLOA_M] ) ;
	Kd_Und_AccAcr = atof( ptb_InRecChild[UND_ACCACR_M] ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l’esclave

retour :
	OK
==============================================================================*/
int n_InitUlt( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitUlt" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC3603_I5", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncUlt ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneUlt ;

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
int n_ConditionSyncUlt(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncUlt" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[ULT_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_END_NT] ) - atoi( pbd_InRecChild[ULT_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_SEC_NF] ) - atoi( pbd_InRecChild[ULT_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_UWY_NF] ) - atoi( pbd_InRecChild[ULT_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_UW_NT] ) - atoi( pbd_InRecChild[ULT_UW_NT] ) ) != 0 ) return ret ;

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

	/* Sauvegarde de champs */
	Kd_Ult_CalAmtPrm = atof( ptb_InRecChild[ULT_CALAMTPRM_M] ) ;
	Kd_Ult_EntAmtPrm = atof( ptb_InRecChild[ULT_ENTAMTPRM_M] ) ;
	Kd_Ult_RetAmtPrm = atof( ptb_InRecChild[ULT_RETAMTPRM_M] ) ;
//	Kc_Ult_AdmModPrm = *ptb_InRecChild[ULT_ADMMODPRM_CT] ;
  strcpy( Kc_Ult_AdmModPrm, ptb_InRecChild[ULT_ADMMODPRM_CT] ) ;
	Kd_Ult_ResPrm = atof( ptb_InRecChild[ULT_RESPRM_M] ) ;
	Kd_Ult_CalAmtClm = atof( ptb_InRecChild[ULT_CALAMTCLM_M] ) ;
	Kd_Ult_EntAmtClm = atof( ptb_InRecChild[ULT_ENTAMTCLM_M] ) ;
	Kd_Ult_RetAmtClm = atof( ptb_InRecChild[ULT_RETAMTCLM_M] ) ;
//	Kc_Ult_AdmModClm = *ptb_InRecChild[ULT_ADMMODCLM_CT] ;
  strcpy( Kc_Ult_AdmModClm, ptb_InRecChild[ULT_ADMMODCLM_CT] ) ;
	strcpy( Ksz_Ult_OriCod, ptb_InRecChild[ULT_ORICOD_LS] ) ;
	strcpy( Ksz_Ult_Cre, ptb_InRecChild[ULT_CRE_D] ) ;
	strcpy( Ksz_Ult_UpdUsr, ptb_InRecChild[ULT_UPDUSR_CF] ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l’esclave

retour :
	OK
==============================================================================*/
int n_InitApr( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitApr" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC3603_I6", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncApr ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneApr ;

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
int n_ConditionSyncApr(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncApr" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[APR_CTR_NF] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneApr(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneApr" ) ;

	/* Sauvegarde de champs */
	sprintf( Ksz_Apr_RecAcc, "%d%02d",
		atoi( ptb_InRecChild[APR_ACY_NF] ),
		atoi( ptb_InRecChild[APR_SCOENDMTH_NF] ) ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l’esclave

retour :
	OK
==============================================================================*/
int n_InitProt( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitProt" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC3603_I7", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncProt ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneProt ;

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
int n_ConditionSyncProt(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncProt" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[PROT_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_END_NT] ) - atoi( pbd_InRecChild[PROT_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_SEC_NF] ) - atoi( pbd_InRecChild[PROT_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_UWY_NF] ) - atoi( pbd_InRecChild[PROT_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_UW_NT] ) - atoi( pbd_InRecChild[PROT_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneProt(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneProt" ) ;

	/* Calcul de l'aliment RPCC exprime en devise de protection */
	if ( *ptb_InRecChild[PROT_LAYTYP_CT] == '1' )
		Kd_EgpRpcc += atof( ptb_InRecChild[PROT_LAYCOS_M] ) * atof( ptb_InRecChild[PROT_LAYPLCSHA_R] ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l’esclave

retour :
	OK
==============================================================================*/
int n_InitPerFct( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitPerFct" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC3603_I8", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncPerFct ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLignePerFct ;

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
int n_ConditionSyncPerFct(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncPerFct" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[PERFCT_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_END_NT] ) - atoi( pbd_InRecChild[PERFCT_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_SEC_NF] ) - atoi( pbd_InRecChild[PERFCT_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_UWY_NF] ) - atoi( pbd_InRecChild[PERFCT_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_UW_NT] ) - atoi( pbd_InRecChild[PERFCT_UW_NT] ) ) != 0 ) return ret ;

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

	/* Calcul du taux global de taxes - taxe exprimee sur prime brute */
	 if ( *ptb_InRecChild[PERFCT_TAXTYP_CT] == '0' )
                Kd_Tax += atof( ptb_InRecChild[PERFCT_TAX_R] ) ;

	/* Calcul du taux global de taxes - taxe exprimee sur prime nete */
	 if ( *ptb_InRecChild[PERFCT_TAXTYP_CT] == '1' )
                Kd_Tax += atof( ptb_InRecChild[PERFCT_TAX_R] ) * ( 1 - Kd_Com ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l’esclave

retour :
	OK
==============================================================================*/
int n_InitCedBil( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitCedBil" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC3603_I9", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncCedBil ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneCedBil ;

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
int n_ConditionSyncCedBil(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncCedBil" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[SHA_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_END_NT] ) - atoi( pbd_InRecChild[SHA_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_SEC_NF] ) - atoi( pbd_InRecChild[SHA_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_UWY_NF] ) - atoi( pbd_InRecChild[SHA_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_UW_NT] ) - atoi( pbd_InRecChild[SHA_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneCedBil(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneCedBil" ) ;

	/* Sauvegarde de champs */
	Kd_CbiRetCed = atof( ptb_InRecChild[SHA_RETCEDRI_R] ) ;
	Kd_CbeRetCed = atof( ptb_InRecChild[SHA_RETCEDRE_R] ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l’esclave

retour :
	OK
==============================================================================*/
int n_InitCedAnt( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitCedAnt" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC3603_I10", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncCedAnt ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneCedAnt ;

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
int n_ConditionSyncCedAnt(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncCedAnt" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[SHA_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_END_NT] ) - atoi( pbd_InRecChild[SHA_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_SEC_NF] ) - atoi( pbd_InRecChild[SHA_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_UWY_NF] ) - atoi( pbd_InRecChild[SHA_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = atoi( pbd_InRecOwner[PER_UW_NT] ) - atoi( pbd_InRecChild[SHA_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneCedAnt(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneCedAnt" ) ;

	/* Sauvegarde de champs */
	Kd_PbiRetCed = atof( ptb_InRecChild[SHA_RETCEDRI_R] ) ;
	Kd_PbeRetCed = atof( ptb_InRecChild[SHA_RETCEDRE_R] ) ;

	RETURN_VAL( OK ) ;
}



/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l’esclave

retour :
	OK
==============================================================================*/
int n_InitCplacc( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitCplacc" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC3603_I13", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncCplacc ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneCplacc ;

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
int n_ConditionSyncCplacc(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncCplacc" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[CMP_CTR_NF] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneCplacc(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneCplacc" ) ;

	/* Sauvegarde de champs */
/*	sprintf( Ksz_Und_ComAcc, "%d%02d",
		atoi( ptb_InRecChild[CMP_ACY_NF] ),
		atoi( ptb_InRecChild[CMP_SCOENDMTH_NF] ) ) ;		*/
	Kn_Und_ComAcc = max(	Kn_Und_ComAcc,
				atoi( ptb_InRecChild[CMP_ACY_NF] )*100+ atoi( ptb_InRecChild[CMP_SCOENDMTH_NF] ) ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction d'initialisation des variables de travail

	retour :	0

==============================================================================*/
int n_InitVariables( void )

{
	DEBUT_FCT( "n_InitVariables" ) ;

	*Ksz_Und_ComAcc = 0 ;
	Kd_Und_CaccPrm = 0 ;
	Kd_Und_CaccUpr = 0 ;
	Kd_Und_CaccClm = 0 ;
	Kd_Und_CaccLoa = 0 ;
	Kd_Und_CaccAcr = 0 ;
	Kd_Und_AccPrm = 0 ;
	Kd_Und_AccUpr = 0 ;
	Kd_Und_AccClm = 0 ;
	Kd_Und_AccLoa = 0 ;
	Kd_Und_AccAcr = 0 ;

	Kd_Com = 0 ;
	Kd_CbiRetCed = 0 ;
	Kd_PbiRetCed = 0 ;
	Kd_CbeRetCed = 0 ;
	Kd_PbeRetCed = 0 ;
	Kd_EgpRpcc = 0 ;

	Kd_Ult_CalAmtPrm = 0 ;
	Kd_Ult_EntAmtPrm = 0 ;
	Kd_Ult_RetAmtPrm = 0 ;
//	Kc_Ult_AdmModPrm = ' ' ;
  strcpy( Kc_Ult_AdmModPrm, " " ) ;
	Kd_Ult_ResPrm = 0 ;
	Kd_Ult_CalAmtClm = 0 ;
	Kd_Ult_EntAmtClm = 0 ;
	Kd_Ult_RetAmtClm = 0 ;
//	Kc_Ult_AdmModClm = ' ' ;
  strcpy( Kc_Ult_AdmModClm, " " ) ;
	*Ksz_Ult_OriCod = 0 ;
	*Ksz_Ult_Cre = 0 ;
	*Ksz_Ult_UpdUsr = 0 ;

	Kd_Tax = 0 ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet:
        Lit le fichier binaire FSEGEST et le charge en memoire

==============================================================================*/
int n_ChargerTSEGEST( void )
{
        int i = 0 ;

        DEBUT_FCT("n_ChargerTSEGEST");

        while ( fread( &Ktbd_Segest[i], sizeof( T_SEGEST ), 1, Kp_InputFilSegest ) == 1 )
                i += 1 ;

        RETURN_VAL( i );
}


/*==============================================================================
objet :
        fonction de recherche du segment
retour :

==============================================================================*/
int n_RechPosteTSEGEST( int n_vrs, char c_ssd, char c_segtyp, char *sz_seg, int n_uwy )
{
        int n_indice, n_ret ;

        DEBUT_FCT("n_RechPosteTSEGEST");

        n_indice=0;

        for( n_indice = 0; n_indice < Kn_NbLig_Segest; n_indice++ )
        {
		/* comparaison du numero de version */
		n_ret = n_vrs - Ktbd_Segest[n_indice].VRS_NF ;

		if ( n_ret < 0 ) RETURN_VAL( -1 ) ;
		if ( n_ret > 0 ) continue ;
		else
		{
			/* comparaison de la filiale */
			n_ret = c_ssd - Ktbd_Segest[n_indice].SSD_CF ;

			if ( n_ret < 0 ) RETURN_VAL( -1 ) ;
			if ( n_ret > 0 ) continue ;
			else
			{
				/* comparaison du type de segment 'A' ou 'E' */
				if ( c_segtyp == Ktbd_Segest[n_indice].SEGTYP_CT )
				{
					/* comparaison du segment */
					n_ret = strcmp( sz_seg, Ktbd_Segest[n_indice].SEG_NF ) ;

					/*if ( n_ret < 0 ) RETURN_VAL( -1 ) ; */ /* Modif M.NAJI 31/12/1998*/
					if ( n_ret != 0 ) continue ;
					else
					{
						/* comparaison des exercices */
						n_ret = n_uwy - Ktbd_Segest[n_indice].UWY_NF ;

						if ( n_ret < 0 ) RETURN_VAL( -1 ) ;
						if ( n_ret > 0 ) continue ;
						else
						{
							/* ligne trouvee => retour de l'indice */
							RETURN_VAL( n_indice ) ;
						}
					}
				}
				else continue ;
			}
		}
        }
	/* si on ne trouve pas la ligne */
	RETURN_VAL( -1 ) ;
}


/*==============================================================================
objet:
	Lit le fichier binaire et le charge en memoire

==============================================================================*/
int n_ChargerSOBBLOB( void )
{
	int i = 0 ;

	DEBUT_FCT("n_ChargerSOBBLOB");

	while ( fread( &Ktbd_Sobblob[i], sizeof( T_SOBBLOB ), 1, Kp_InputFilSobblob ) == 1 )
		i += 1 ;

	RETURN_VAL( i );
}


/*==============================================================================
objet :
	fonction de recherche du produit
retour :
	0		---> Pas de rupture
	< 0   	---> On n'est pas arrive au bloc synchrone
	> 0   	---> On a depasse le bloc synchrone
==============================================================================*/
char *n_RechProduit( char *sz_lob, char *sz_sob )
{
	int n_indice, ret;

	DEBUT_FCT("n_RechProduit");

	n_indice=0;

	while (1==1)
	{
		/* Comparaison de la Lob */
		ret=strcmp( sz_lob, Ktbd_Sobblob[n_indice].LOB_CF);

		/* si egales, comparaison de la Sob */
		if ( ret == 0 )
		{
			ret=strcmp( sz_sob, Ktbd_Sobblob[n_indice].SOB_CF) ;

			if ( ret == 0 )
			{
				RETURN_VAL( Ktbd_Sobblob[n_indice].PRDCOD_CT ) ;			}
			else	n_indice += 1 ;
		}
		else
		{
			/* Ligne suivante */
			n_indice += 1 ;
		}

		/* Si on est a la fin du tableau, echec */
		if ( n_indice == Kn_NbLig_Sobblob ) RETURN_VAL( "" );
	}
}

double GetPremium(char **pbd_PER_enr, int  iTarifPremium)
{
	char	c_Ssd = 0;
	int	n_Uwy = 0;
	char	MsgAno[300];
	double d_Premium_temp = 0;
	double d_Ratio = 1;
	int i = 0;
	const int MAX_PREMIUM = 5;
	int iFlat_Premium[] = {PER_FLAPRM1_M, PER_FLAPRM2_M, PER_FLAPRM3_M, PER_FLAPRM4_M, PER_FLAPRM5_M};
	int iFlat_Currency[] = {PER_FLAPRMCU1_CF, PER_FLAPRMCU2_CF, PER_FLAPRMCU3_CF, PER_FLAPRMCU4_CF, PER_FLAPRMCU5_CF};
	int iDeposit_Premium[] = {PER_MINPRVPR1_M, PER_MINPRVPR2_M, PER_MINPRVPR3_M, PER_MINPRVPR4_M, PER_MINPRVPR5_M};
	int iDeposit_Currency[] = {PER_PRVPRMCU1_CF, PER_PRVPRMCU2_CF, PER_PRVPRMCU3_CF, PER_PRVPRMCU4_CF, PER_PRVPRMCU5_CF};
	char *pszTypePremium[] = {"Flat", "Deposit"};
	int *iptPremium;
	int *iptCurrency;
	double d_Premium = 0;

	if ( iTarifPremium == FLAT_PREMIUM )
	{
		iptPremium = iFlat_Premium;
		iptCurrency = iFlat_Currency;
	}
	else
	{
		iptPremium = iDeposit_Premium;
		iptCurrency = iDeposit_Currency;
	}

	c_Ssd = (char) atoi( pbd_PER_enr[PER_SSD_CF] ) ;
	n_Uwy = atoi( pbd_PER_enr[PER_UWY_NF] ) ;

	for (i = 0; i < MAX_PREMIUM; i++)
	{
		d_Premium_temp = atof(pbd_PER_enr[ iptPremium[i] ]);
		
		if ( strcmp(pbd_PER_enr[PER_EGPCUR_CF], pbd_PER_enr[ iptCurrency[i] ]) != 0 && d_Premium_temp != 0 )
		{
			d_Ratio = d_GetTaux(Kp_InputFilExc, c_Ssd, n_Uwy - 1, pbd_PER_enr[ iptCurrency[i] ], pbd_PER_enr[PER_EGPCUR_CF]);
		}
		else	d_Ratio = 1 ;

		/* generation d'une anomalie si pas de cours trouve */
		if ( d_Ratio < 0 )
		{
			sprintf( MsgAno, "The rates of EGPI currency ( %s ) and %s premium n°%d currency ( %s ) aren't known in %d for the contract ( CTR_NF %s - END_NT %s - SEC_NF %s - UWY_NF %s - UW_NT %s )\n",
				pbd_PER_enr[PER_EGPCUR_CF],pszTypePremium[iTarifPremium],i+1,pbd_PER_enr[ iptCurrency[i] ],n_Uwy - 1,pbd_PER_enr[PER_CTR_NF],pbd_PER_enr[PER_END_NT],pbd_PER_enr[PER_SEC_NF],pbd_PER_enr[PER_UWY_NF],pbd_PER_enr[PER_UW_NT]);

			n_WriteAno( MsgAno ) ;
			d_Premium_temp = 0 ;
		}
		else 	d_Premium_temp *= d_Ratio;

		d_Premium += d_Premium_temp;
	}

	if ( fabs(d_Premium) > 999999999999999.000) d_Premium = 999999999999999.000;

	return d_Premium;
}
