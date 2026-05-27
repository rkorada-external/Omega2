/*==============================================================================
nom de l'application          : MaoC
nom du source                 : ESFC3890.c
révision                      :
date de création              :02/09/2020
auteur                        : MiS
references des specifications : REQ.P.11.9
squelette de base             : batch
------------------------------------------------------------------------------
description :
   		Calcul des futures primes et futures sinistre
                avec Transformation des postes

------------------------------------------------------------------------------
historique des modifications :
[001] 05/08/2020 MiS : Spira 77469 : REQ11.9 - AOC- Experience Adjustement
[002] 22/09/2021 MiS : Spira 98965 : REQ 11.09 - I17 - Expected Brokerage transactions adjustments
[003] 29/09/2021 MiS : Spira 99030 : REQ11.9 - Change in Current Internal Acquisition Expenses
[004] 29/09/2021 MiS : Spira 97099 : IFRS 17 - REQ11.9 - AOC Transactions calculations issues
[005] 30/09/2021 MiS : Spira 97099 : Correction Doublon DAC Brokerage IFRS17
[006] 29/10/2021 MiS : Spira 99266 : Change in the rule of first closing for macro AoC
[007] 08/11/2021 MiS : Spira 100138: Extraction Rule Change
[008] 06/12/2021 DaD : Spira 97099 : Bug Fix calculations issues for sec> 10
[009] 13/12/2021 DaD : Spira 100138 : Bug Fix DAC Brokerage IFRS17
[010] 14/02/2022 DaD : Spira 101435 : REQ 11.09 - update extraction grouping 2032, 2022 
[011] 28/02/2022 HR  : Spira 101277 : AoC - internal assumed
[012]  05/07/2022  JBD     :spira 104778:  Build new closing for I17S norm
[013] 25/08/2023 MZM : spira ESFD3890 - extend RA ratios array size : NB_RARAT_MAX and NB_EXPRAT_MAX 
[014] 15/07/2024 DAD : spira 110953 : Bug Fix ULR selection issues
[015] 09/10/2024 DAD : spira 112047 : Bug Fix R01-00 of REQ11.9 - AOC- Experience Adjustment
========================================================================================================*/
 
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "struct.h"
#include <estserv.h>
#include "estutil.c"

/*----------------------------------------*/
/* inclusion de version dans les binaires */
/*----------------------------------------*/
static char VERSION_ESFC3890_C[150] = "__version__: ESFC3890.c version [015] 09/10/2024 DAD : spira 112047 : Bug Fix R01-00 of REQ11.9" ;

#define Kn_MaxLigFBOTRSLNK	60000
#define LGTH_SEGEST		100
#define NB_SEGEST_MAX		10000
#define NB_COL_GT2		71

#define SEG_SSD_CF    		0
#define SEG_SEG_NF    	 	1
#define SEG_UWY_NF    	 	2
#define SEG_CUR_CF    	 	3
#define SEG_SEGNAT_CT 	 	4
#define SEG_CLMAMT_M  	 	5
#define SEG_LOSRAT_R  	 	6
#define SEG_AMORAT_CT 	 	7
#define SEG_SEGTYP_CT 	 	8

#define MARKET_CTR_NF           0
#define MARKET_END_NT           1
#define MARKET_SEC_NF           2
#define MARKET_UWY_NF           3
#define MARKET_UW_NT            4
#define MARKET_CTRNAT_CT        5
#define MARKET_SEG_NF           6
#define MARKET_LBL_NF           7
#define MARKET_SGMT_NF          8
#define MARKET_GTSII_GRPGRP3_NF 9

#define ULTIM_CTR_NF		0
#define ULTIM_END_NT		1
#define ULTIM_SEC_NF		2
#define ULTIM_UWY_NF		3
#define ULTIM_UW_NT		4
#define ULTIM_SSD_CF		5
#define ULTIM_SEG_NF            100
#define ULTIM_AMORAT_CT  	102
#define ULTIM_ACTCLMAMT_M       104
#define ULTIM_ACTLOSRAT_R       105

#define NB_RARAT_MAX 		50000   //013 taille de 10000 a 50000
#define LGTH_RARAT 		90

#define RAT_SSD_CF     		0
#define RAT_ESB_CF     		1
#define RAT_SEG_NF     		2
#define RAT_NORME_CF   		3
#define RAT_CTRNAT_CT  		4
#define RAT_DOMAIN_CF  		5
#define RAT_PRMRAT_R   		6
#define RAT_RSRVRAT_R  		7
#define RAT_SGMT_LS    		8

#define NB_EXPRAT_MAX            50000   //013 taille de 10000 a 50000
#define LGTH_EXPRAT              90

#define EXP_SSD_CF              0
#define EXP_ESB_CF              1
#define EXP_SEGID_CF            2
#define EXP_SEG_CF              3
#define EXP_PLBL_CF             4
#define EXP_VRS_NF              5
#define EXP_CTRNAT_CT           6
#define EXP_IAERAT_R            7
#define EXP_IMERAT_R		8

// [006]
#define FACCTR_CTR_NF		0
#define FACCTR_END_NT		1
#define FACCTR_SEC_NF		2
#define FACCTR_UWY_NF		3
#define FACCTR_UW_NT		4
#define FACCTR_RATEINDEX_CTG	5
#define FACCTR_RATEINDEX_CTP	6
#define FACCTR_RATEINDEX_CTL	7
#define FACCTR_TYPE		8
#define FACCTR_SSD_CF		9
#define FACCTR_ESB_CF		10
#define FACCTR_GRPINISTS_CT	11
#define FACCTR_PARINISTS_CT	12
#define FACCTR_LOCINISTS_CT	13
#define FACCTR_GRPFIRCLO_D	14
#define FACCTR_PARFIRCLO_D	15
#define FACCTR_LOCFIRCLO_D	16
#define FACCTR_GRPIFRSTRA_CT	17
#define FACCTR_PARIFRSTRA_CT	18
#define FACCTR_LOCIFRSTRA_CT	19

#define SEPARATOR		"~"
#define PRM			1
#define UPR			2
#define UCLM			3
#define ULKI			4
#define EBRK			5
#define BRK			6
#define DACBRK			7
#define DACI17			8
#define EIAE			9
#define EIME			10
#define VARC			11
#define DACVAR			12
#define VARPRM			13
#define ULKI2                   14
#define EBRK2                   15
#define BRK2                    16
#define EIME2			17
#define OTHER			18

/* definition de la structure T_RARAT */
typedef struct 
{
	int 	SSD_CF ;
	short 	ESB_CF ;
	char 	SEG_NF[12];
	char 	CTRNAT_CT ;
	char 	DOMAIN_CF[8];
	double 	PRMRAT_R ;
	double 	RSRVRAT_R ;
	char 	SGMT_LS[17];
} T_RARAT ;

/* definition de la structure T_EXPRAT */
typedef struct 
{
	int 	SSD_CF ;
	short 	ESB_CF ;
	int 	SEGID_CF ;
	char  	SEG_CF[20] ;
	int 	PLBL_CF ;
	char 	VRS_NF[8] ;
	char 	CTRNAT_CT ;
	double 	IAERAT_R ;
	double 	IMERAT_R ;
} T_EXPRAT ;

/* Variable de gestion de Rupture */

T_RUPTURE_VAR			bd_RuptPer ;		/* Variable de gestion de la rupture du PERICASE */
T_RUPTURE_SYNC_VAR		bd_RuptGtSii ;		/* Variable de gestion de la rupture */
T_RUPTURE_SYNC_VAR		bd_RuptGtSiiPrev ;	/* Variable de gestion de la rupture */
T_RUPTURE_SYNC_VAR		bd_RuptGt ;		/* Variable de gestion de la rupture */
T_RUPTURE_SYNC_VAR		bd_RuptGtR ;		/* Variable de gestion de la rupture */
T_RUPTURE_SYNC_VAR              bd_RuptUltim ;          /* Variable de gestion de la rupture */
T_RUPTURE_SYNC_VAR              bd_RuptMarket ;         /* Variable de gestion de la rupture */
T_RUPTURE_SYNC_VAR              bd_RuptFacctr ;         /* Variable de gestion de la rupture [006] */

/* Variable de Travail */

FILE			*Kp_InputFilSegest ;		/* pointeur sur le fichier binaire FSEGEST */
FILE			*Kp_OutputFilGt ;		/* pointeur sur le Fichier de sortie */
FILE			*Kp_FBOTRSLNK ;			/* pointeur sur le fichier FBOPRSLNK */
FILE			*Kp_InputFilRaRat ;		/* pointeur sur le fichier RaRat */
FILE			*Kp_InputFilExpRat ;		/* pointeur sur le fichier ExpRat */
FILE			*Kp_InputFilCurquot ;		/* pointeur sur le fichier FCURQUOT */

int			Kn_FBOTRSLNK ;
T_FBOTRSLNK 		Ktbd_FBOTRSLNK[Kn_MaxLigFBOTRSLNK] ;
T_SEGEST_SOLVENCY	Ktbd_Segest[NB_SEGEST_MAX] ;	/* tableau permettant de charger en memoire FSEGEST */
int 			Kn_NbLig_Segest ;		/* nombre de postes dans le tableau */

T_RARAT			Ktbd_rarat [NB_RARAT_MAX] ;	/* tableau permettant de charger en memoire FRARAT */
int			Kn_NbLig_RaRat ;		/* nombre de ratios dans le tableau */

T_EXPRAT                Ktbd_Exprat [NB_EXPRAT_MAX] ;     /* tableau permettant de charger en memoire EXPRAT */
int                     Kn_NbLig_ExpRat ;                /* nombre de ratios dans le tableau */

int 			t ;

char			Ksz_Norme[5] ;
char			Kc_Norme_Suf[2] ;

char                    Ksz_PrevClodat[9] ; //[006]
char			Ksz_Clodat[9] ;
int			Kn_CloDatD, Kn_CloDatM, Kn_CloDatY ;

int			flag_compute; //[006]

char			Ksz_TypeInv[5]; // [002]

double			Kd_EarnedPrm;
double			Kd_EarnedClaims;
double			Kd_CurLoss;
double			Kd_CurRat;
double			Kd_CurRA;
double			Kd_CurBrk;
double			Kd_CurIAE;
double			Kd_CurIME;
double			Kd_CurVarCom;
double			Kd_CurVarPrm;

double			Kd_WrittenPrm;
double			Kd_UPR;
double			Kd_UClaims;
double			Kd_ULKI;
double			Kd_ULR;
double			Kd_RA;
double			Kd_ExpBrk;
double			Kd_Brk;
double			Kd_DACBrk;
double			Kd_DACBrkI17;
double			Kd_IAERat;
double			Kd_IAE;
double			Kd_IME;
double			Kd_VarCom;
double			Kd_DACVar;
double			Kd_VarPrm;
double			Kd_IncClaims;
double			Kd_IncAcCost;

/* Fonctions */

int n_ProcessingRuptureSyncVar 	(T_RUPTURE_SYNC_VAR  *pbd_Rupt, char **pbd_InRecOwner );

int n_InitPer            	( T_RUPTURE_VAR  *pbd_Rupt );
int n_ConditionSyncPer       	(char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionLignePer		(char **pbd_InRec_Cur);

int n_InitGtSii			( T_RUPTURE_SYNC_VAR *pbd_Rupt );
int n_ActionLigneGtSii    	( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ConditionSyncGtSii  	( char **pbd_InRecOwner, char **pbd_InRecChild );

int n_InitGt                 	( T_RUPTURE_SYNC_VAR *pbd_Rupt );
int n_ActionLigneGt          	( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ConditionSyncGt        	( char **pbd_InRecOwner, char **pbd_InRecChild );

int n_InitGtR                 	( T_RUPTURE_SYNC_VAR *pbd_Rupt );
int n_ActionLigneGtR          	( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ConditionSyncGtR        	( char **pbd_InRecOwner, char **pbd_InRecChild );

int n_InitUltim			( T_RUPTURE_SYNC_VAR  *pbd_Rupt );
int n_ActionLigneUltim          ( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ConditionSyncUltim        ( char **pbd_InRecOwner, char **pbd_InRecChild );

int n_InitMarket                ( T_RUPTURE_SYNC_VAR  *pbd_Rupt );
int n_ActionLigneMarket         ( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ConditionSyncMarket       ( char **pbd_InRecOwner, char **pbd_InRecChild );

// [006]
int n_InitFacctr                ( T_RUPTURE_SYNC_VAR  *pbd_Rupt );
int n_ActionLigneFacctr         ( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ConditionSyncFacctr       ( char **pbd_InRecOwner, char **pbd_InRecChild );

int n_ChargerFBOTRSLNK		();
int n_check_trncd_cf		( char *sz_TrnCd );
int n_calcul_aoc		( char **pbd_InRec_Cur );

int n_ChargerTSEGEST		();
int n_RechPosteTSEGEST		( int n_ssd, char *sz_seg, int n_uwy, char * sz_segtyps );

int n_ChargerTRARAT		();
int n_RechTRARAT		( int c_ssd, short c_esb_cf , char *sz_seg , char c_ctrnat_cf, char * sz_domain_cf );

int n_ChargerEXPRAT             ();
int n_RechEXPRAT		( int c_ssd, short c_esb_cf , int c_plbl , char c_ctrnat_cf );

int n_EcrireGt			( char **pbd_InRec_Cur , char *CTR_NF, double d_Montant, char *account );

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
        InitSig ();

        if ( n_BeginPgm ( argc, argv ) == ERR )
                ExitPgm( ERR_XX , "" );

        printf("Running with %s  \n", VERSION_ESFC3890_C);

	/* Extraction Norme */
        strcpy(Ksz_Norme, psz_GetCharArgv( 1 ) ) ;

	/* Extraction Clodat */
	strcpy(Ksz_Clodat, psz_GetCharArgv( 2 ) ) ;
	o_ExtractionAnneeMoisJour(Ksz_Clodat, &Kn_CloDatY, &Kn_CloDatM, &Kn_CloDatD);

	// [002]
	/* Extraction TypeInv */
        strcpy(Ksz_TypeInv, psz_GetCharArgv( 3 ) ) ;

	// [006]
	/* Extraction Prev_Clodat */
        strcpy(Ksz_PrevClodat, psz_GetCharArgv( 4 ) ) ;

	printf("ARGUMENT RECUP Kn_Norme %s Ksz_Clodat %s Ksz_TypeInv %s Ksz_PrevClodat %s\n", Ksz_Norme, Ksz_Clodat, Ksz_TypeInv, Ksz_PrevClodat);

        /* Determination du Suffice pour les TRNCOD Des Future At INCEPTION */

        if ( strncmp(Ksz_Norme, "I17G", 4) == 0 || strncmp(Ksz_Norme, "I17S", 4) == 0) //[12]
                strcpy(Kc_Norme_Suf, "I"); //Kc_Norme_Suf = 'I';
        if ( strncmp(Ksz_Norme, "I17P", 4) == 0)
                strcpy(Kc_Norme_Suf, "K"); //Kc_Norme_Suf = 'K';
        if ( strncmp(Ksz_Norme, "I17L", 4) == 0)
                strcpy(Kc_Norme_Suf, "M"); //Kc_Norme_Suf = 'M' ;

	/* ouverture du fichier en entree FCURQUOT */
	if ( n_OpenFileAppl ( "ESFC3890_I3","rb",&Kp_InputFilCurquot ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier en entree FSEGEST */
	if ( n_OpenFileAppl ( "ESFC3890_I6","rb",&Kp_InputFilSegest ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier en entree des ratios RARAT  */
        if ( n_OpenFileAppl ( "ESFC3890_I7","rb",&Kp_InputFilRaRat ) == ERR )
                ExitPgm( ERR_XX , "" );

	/* ouverture du fichier en entree des ratios EXPRAT  */
        if ( n_OpenFileAppl ( "ESFC3890_I8","rb",&Kp_InputFilExpRat ) == ERR )
                ExitPgm( ERR_XX , "" );

        /* Ouverture du fichier en entree FBOTRSLNK */
	if (n_OpenFileAppl("ESFC3890_I9", "rb", &Kp_FBOTRSLNK) == ERR )
        	ExitPgm(ERR_XX ,"cannot open Kp_FBOTRSLNK ");

        /* ouverture du fichier de sortie des resultats par affaire */
        if ( n_OpenFileAppl ( "ESFC3890_O1","wt",&Kp_OutputFilGt ) == ERR )
                ExitPgm( ERR_XX , "" );

	/* Chargement du tableau TRSLNK*/
	Kn_FBOTRSLNK = n_ChargerFBOTRSLNK();
	if ( Kn_FBOTRSLNK == -1 )
        	ExitPgm( ERR_XX , "Taille tableau FBOTRSLNK insuffisante " ) ;

	/* Chargement de TSEGEST en memoire */
        Kn_NbLig_Segest = n_ChargerTSEGEST( ) ;

	if ( Kn_NbLig_Segest > NB_SEGEST_MAX )
		ExitPgm( ERR_XX , "" );

	/* Chargement de TRARAT en memoire */
	Kn_NbLig_RaRat = n_ChargerTRARAT( ) ;

	if ( Kn_NbLig_RaRat > NB_RARAT_MAX )
                ExitPgm( ERR_XX , "Error NB_RARAT_MAX " );

	/* Chargement de TRARAT en memoire */
        Kn_NbLig_ExpRat = n_ChargerEXPRAT( ) ;

        if ( Kn_NbLig_ExpRat > NB_EXPRAT_MAX )
                ExitPgm( ERR_XX , "Error NB_EXPRAT_MAX " );

        /* Initialisation de la variable bd_RuptPer */
        if ( n_InitPer( &bd_RuptPer ) )
                ExitPgm( ERR_XX , "" );

        /* Initialisation de la variable bd_RuptGtSii */
        if ( n_InitGtSii( &bd_RuptGtSii ) )
                ExitPgm( ERR_XX , "" );

		// [006]
        /* Initialisation de la variable bd_RuptFacctr */
        if ( n_InitFacctr( &bd_RuptFacctr ) )
                ExitPgm( ERR_XX , "" );

        /* Initialisation de la variable bd_RuptGt */
        if ( n_InitGt( &bd_RuptGt ) )
                ExitPgm( ERR_XX , "" );

        /* Initialisation de la variable bd_RuptGtR */
//        if ( n_InitGtR( &bd_RuptGtR ) )
//                ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptUltim */
	if ( n_InitUltim( &bd_RuptUltim ) )
		ExitPgm( ERR_XX , "" );

	/* Initialisation de la variable bd_RuptMarket */
        if ( n_InitMarket( &bd_RuptMarket ) )
                ExitPgm( ERR_XX , "" );

        /* lancement du traitement du fichier Perimetre de souscription IADPERICASE.dat */
        if ( n_ProcessingRuptureVar( &bd_RuptPer ) == ERR )
                ExitPgm( ERR_XX , "" );

        if ( n_CloseFileAppl( "ESFC3890_I1", &( bd_RuptPer.pf_InputFil ) ) == ERR )
                ExitPgm( ERR_XX , "" );

        if ( n_CloseFileAppl( "ESFC3890_I2", &( bd_RuptGtSii.pf_InputFil ) ) == ERR )
                ExitPgm( ERR_XX , "" );

        if ( n_CloseFileAppl( "ESFC3890_I3", &Kp_InputFilCurquot ) == ERR )
                ExitPgm( ERR_XX , "" );

        if ( n_CloseFileAppl( "ESFC3890_I4", &( bd_RuptGt.pf_InputFil ) ) == ERR )
                ExitPgm( ERR_XX , "" );

//        if ( n_CloseFileAppl( "ESFC3890_I5", &( bd_RuptGtR.pf_InputFil ) ) == ERR )
//                ExitPgm( ERR_XX , "" );

        if ( n_CloseFileAppl( "ESFC3890_I6", &Kp_InputFilSegest ) == ERR )
                ExitPgm( ERR_XX , "" );

        if ( n_CloseFileAppl( "ESFC3890_I7", &Kp_InputFilRaRat ) == ERR )
                ExitPgm( ERR_XX , "" );

        if ( n_CloseFileAppl( "ESFC3890_I8", &Kp_InputFilExpRat ) == ERR )
                ExitPgm( ERR_XX , "" );

        if ( n_CloseFileAppl( "ESFC3890_I9", &Kp_FBOTRSLNK ) == ERR )
                ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESFC3890_I10", &( bd_RuptUltim.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESFC3890_I11", &( bd_RuptMarket.pf_InputFil ) ) == ERR )
                ExitPgm( ERR_XX , "" );

	// [006]
	if ( n_CloseFileAppl( "ESFC3890_I12", &( bd_RuptFacctr.pf_InputFil ) ) == ERR )
                ExitPgm( ERR_XX , "" );

        if ( n_CloseFileAppl( "ESFC3890_O1", &Kp_OutputFilGt ) == ERR )
                ExitPgm( ERR_XX , "" );

        if ( n_EndPgm() == ERR )
                ExitPgm( ERR_XX , "" );

        exit(OK);
}

/*==============================================================================
objet :
        Initialise les variables a 0

retour :
        0K
==============================================================================*/
int n_InitVariables( )
{
	DEBUT_FCT( "n_InitVariables" );

	// [006]	
	flag_compute = 1;

        Kd_EarnedPrm = 0 ;
        Kd_EarnedClaims = 0 ;
        Kd_CurLoss = 0 ;
        Kd_CurRat = 0 ;
        Kd_CurRA = 0 ;
        Kd_CurBrk = 0 ;
        Kd_CurIAE = 0 ;
        Kd_CurIME = 0 ;
        Kd_CurVarCom = 0 ;
        Kd_CurVarPrm = 0 ;

	Kd_WrittenPrm = 0 ;
        Kd_UPR = 0 ;
        Kd_UClaims = 0 ;
        Kd_ULKI = 0 ;
        Kd_ULR = 0 ;
        Kd_RA = 0 ;
        Kd_ExpBrk = 0 ;
        Kd_Brk = 0 ;
        Kd_DACBrk = 0 ;
        Kd_DACBrkI17 = 0 ;
        Kd_IAERat = 0 ;
        Kd_IAE = 0 ;
        Kd_IME = 0 ;
        Kd_VarCom = 0 ;
        Kd_DACVar = 0 ;
        Kd_VarPrm = 0 ;
	
	Kd_IncClaims = 0 ;
	Kd_IncAcCost = 0 ;

	RETURN_VAL( OK ) ;
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
        DEBUT_FCT( "n_InitPer" );

        memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) );

        /* ouverture du fichier maitre Perimetre de souscription */
        if ( n_OpenFileAppl( "ESFC3890_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
                return ERR;

        pbd_Rupt->n_NbRupture = 1;
	pbd_Rupt->n_ConditionRupture[0]=n_ConditionSyncPer;
	pbd_Rupt->n_ActionFirst[0]=n_ActionLignePer;

        pbd_Rupt->c_Separ = '~';

        RETURN_VAL( OK );
}

/*==============================================================================
objet :
        fonction lancé a  la rupture sur le fichier maîte

retour :
        0 ---> pas de rupture
        1 ---> rupture
==============================================================================*/
int n_ConditionSyncPer(
   char *ptsz_LigneSuiv[],
   char *ptsz_LigneCour[]
)
{
  DEBUT_FCT("n_ConditionSyncPer");

        if (strcmp(ptsz_LigneSuiv[PER_CTR_NF], ptsz_LigneCour[PER_CTR_NF])!=0) return(1);
        if (strcmp(ptsz_LigneSuiv[PER_END_NT], ptsz_LigneCour[PER_END_NT])!=0) return(1);
        if (strcmp(ptsz_LigneSuiv[PER_SEC_NF], ptsz_LigneCour[PER_SEC_NF])!=0) return(1);
        if (strcmp(ptsz_LigneSuiv[PER_UWY_NF], ptsz_LigneCour[PER_UWY_NF])!=0) return(1);
        if (strcmp(ptsz_LigneSuiv[PER_UW_NT], ptsz_LigneCour[PER_UW_NT])!=0) return(1);

        return( 0 );
}

/*==============================================================================
objet : fonction lancéea rupturedu fichier maîtr

retour :
        OK ---> traitement correctement effectuée
        ERR --> problème rencontréon
==============================================================================*/
int n_ActionLignePer(char **pbd_InRec_Cur)
{
    DEBUT_FCT("n_ActionLignePer");

	n_InitVariables( );
	
	n_ProcessingRuptureSyncVar(&bd_RuptFacctr, pbd_InRec_Cur ); // [006]
	n_ProcessingRuptureSyncVar( &bd_RuptGtSii, pbd_InRec_Cur );
    n_ProcessingRuptureSyncVar( &bd_RuptGt, pbd_InRec_Cur );
	n_ProcessingRuptureSyncVar( &bd_RuptUltim, pbd_InRec_Cur );
	n_ProcessingRuptureSyncVar( &bd_RuptMarket, pbd_InRec_Cur );

    // [015]
    int	compute_aoc = 0;
    if ( (strncmp(Ksz_Norme, "I17G", 4) == 0 || strncmp(Ksz_Norme, "I17S", 4) == 0) && atoi(pbd_InRec_Cur[PER_CTRRET_B]) == 1 ) {
        compute_aoc = 0;
    } else {
        compute_aoc = 1;
    }

    //[011] //[12]
    if ( compute_aoc == 1 ) { 
        n_calcul_aoc(pbd_InRec_Cur);
    }

    RETURN_VAL(OK);
}

/*==============================================================================
objet : Initialisation de la synchronisation du maitre avec l'esclave
retour :    OK
==============================================================================*/
int n_InitGtSii( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
        DEBUT_FCT( "n_InitGtSii" );

        memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) );

        /* ouverture du fichier esclave */
        if ( n_OpenFileAppl( "ESFC3890_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
                return ERR;

        /* nombre de rupture a gerer */
        pbd_Rupt->n_NbRupture = 0;
        /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
        pbd_Rupt->ConditionEndSync = n_ConditionSyncGtSii;
        /* fonction d'action sur la ligne courante */
        pbd_Rupt->n_ActionLigne = n_ActionLigneGtSii;


        pbd_Rupt->c_Separ = '~';

        RETURN_VAL( OK );
}

/*==============================================================================
objet :
        fonction de test de synchronisation

retour :
        0       ---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)s
        > 0     ---> pbd_InRecOwne> > pbd_InRecChild    < 0     ---> pbd_InRecOwne> < pbd_InRecChild
        < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncGtSii(
        char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
        char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
        int ret;

        DEBUT_FCT( "n_ConditionSyncGtsii" );

        if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) return ret;
        if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GT_END_NT] ) ) != 0 ) return ret;
        if ( ( ret = atoi( pbd_InRecOwner[PER_SEC_NF] ) - atoi( pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) return ret ;
        if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) return ret;
        if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GT_UW_NT] ) ) != 0 ) return ret;

        RETURN_VAL( 0 );
}

/*==============================================================================
objet :
        fonction lancee pour chaque ligne

retour :        OK ---> traitement correctement effectue
                ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGtSii(
        char **pbd_InRecOwner , /* adresse de la ligne du maitre */
        char **pbd_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneGtSii" );

	int n_type_trn_cd;
        int flg_date;
	double Ratio;
	char MsgAno[300];

        if(     atoi(pbd_InRecChild[GT_BALSHEY_NF]) == Kn_CloDatY
                && (atoi(pbd_InRecChild[GT_BALSHRMTH_NF]) <= Kn_CloDatM)
                && (atoi(pbd_InRecChild[GT_BALSHRMTH_NF]) > Kn_CloDatM - 3))
                flg_date = 1 ;
        else
                flg_date = 0 ;

        n_type_trn_cd = n_check_trncd_cf(pbd_InRecChild[GT_TRNCOD_CF]);

        Ratio = d_GetTaux(Kp_InputFilCurquot, (char) atoi(pbd_InRecChild[GT_SSD_CF]), atoi(pbd_InRecChild[GT_UWY_NF]), pbd_InRecChild[GT_CUR_CF], pbd_InRecOwner[PER_EGPCUR_CF]);

        if (Ratio <= 0 )
        {
                sprintf( MsgAno, "The rates of currency ( %s ) is not known for the perimeter contract ( CTR %s - SEC %s - UWY %s - UW %s) and BALSHEY %i \n",
                        pbd_InRecChild[GT_CUR_CF],
                        pbd_InRecChild[GT_CTR_NF],
                        pbd_InRecChild[GT_SEC_NF],
                        pbd_InRecChild[GT_UWY_NF],
                        pbd_InRecChild[GT_UW_NT],
                        atoi(pbd_InRecChild[GT_BALSHEY_NF]));

                n_WriteAno( MsgAno );
                return 0;
        }

        if ( n_type_trn_cd == ULKI && flg_date == 1 )
        {
                Kd_ULKI += Ratio * atof(pbd_InRecChild[GT_AMT_M]) ;
        }

	// [007]
	if ( n_type_trn_cd == ULKI2 && flg_date == 1 )
        {
                Kd_ULKI += -1 * Ratio * atof(pbd_InRecChild[GT_AMT_M]) ;
        }

	if ( n_type_trn_cd == EIAE && flg_date == 1 )
        {
                Kd_IAE += Ratio * atof(pbd_InRecChild[GT_AMT_M]) ;
        }

	if ( n_type_trn_cd == EIME && flg_date == 1 )
        {
                Kd_IME += Ratio * atof(pbd_InRecChild[GT_AMT_M]) ;
        }

        // [008]
        if ( n_type_trn_cd == EIME2 && flg_date == 1 )
        {
                Kd_IME += -1 * Ratio * atof(pbd_InRecChild[GT_AMT_M]) ;
        }

	if ( n_type_trn_cd == EBRK && flg_date == 1 )
        {
                Kd_ExpBrk += Ratio * atof(pbd_InRecChild[GT_AMT_M]) ;
        }

	// [007]
	if ( n_type_trn_cd == EBRK2 && flg_date == 1 )
        {
                Kd_ExpBrk += -1 * Ratio * atof(pbd_InRecChild[GT_AMT_M]) ;
        }

        if ( n_type_trn_cd == BRK && flg_date == 1 )
        {
                Kd_Brk += Ratio * atof(pbd_InRecChild[GT_AMT_M]) ;
        }

	// [007]
	if ( n_type_trn_cd == BRK2 && flg_date == 1 )
        {
                Kd_Brk += -1 * Ratio * atof(pbd_InRecChild[GT_AMT_M]) ;
        }

	// [005]
        // [009]
        if ( n_type_trn_cd == DACI17 && flg_date == 1 )
        {
                Kd_DACBrkI17 += Ratio * atof(pbd_InRecChild[GT_AMT_M]) ;
        }

        RETURN_VAL( OK );
}

/*==============================================================================
objet : Initialisation de la synchronisation du maitre avec l'esclave
retour :    OK
==============================================================================*/
int n_InitGt( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
        DEBUT_FCT( "n_InitGt" );

        memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) );

        /* ouverture du fichier esclave */
        if ( n_OpenFileAppl( "ESFC3890_I4", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
                return ERR;

        /* nombre de rupture a gerer */
        pbd_Rupt->n_NbRupture = 0;
        /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
        pbd_Rupt->ConditionEndSync = n_ConditionSyncGt;
        /* fonction d'action sur la ligne courante */
        pbd_Rupt->n_ActionLigne = n_ActionLigneGt;


        pbd_Rupt->c_Separ = '~';

        RETURN_VAL( OK );
}

/*==============================================================================
objet :
        fonction de test de synchronisation

retour :
        0       ---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)s
        > 0     ---> pbd_InRecOwne> > pbd_InRecChild    < 0     ---> pbd_InRecOwne> < pbd_InRecChild
        < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncGt(
        char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
        char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
        int ret;

        DEBUT_FCT( "n_ConditionSyncGt" );

        if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) return ret;
        if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GT_END_NT] ) ) != 0 ) return ret;
        if ( ( ret = atoi( pbd_InRecOwner[PER_SEC_NF] ) - atoi( pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) return ret ;
        if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) return ret;
        if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GT_UW_NT] ) ) != 0 ) return ret;

        RETURN_VAL( 0 );
}

/*==============================================================================
objet :
        fonction lancee pour chaque ligne

retour :        OK ---> traitement correctement effectue
                ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGt(
        char **pbd_InRecOwner , /* adresse de la ligne du maitre */
        char **pbd_InRecChild ) /* adresse de la ligne de l'esclave */
{
	int n_type_trn_cd;
	int flg_date;
	double Ratio;
	char MsgAno[300];  /* message anomalie */

	DEBUT_FCT( "n_ActionLigneGt" );
	
	if(	atoi(pbd_InRecChild[GT_BALSHEY_NF]) == Kn_CloDatY
		&& (atoi(pbd_InRecChild[GT_BALSHRMTH_NF]) <= Kn_CloDatM)
		&& (atoi(pbd_InRecChild[GT_BALSHRMTH_NF]) > Kn_CloDatM - 3))
		flg_date = 1 ;
	else
		flg_date = 0 ;

        n_type_trn_cd = n_check_trncd_cf(pbd_InRecChild[GT_TRNCOD_CF]);

	Ratio = d_GetTaux(Kp_InputFilCurquot, (char) atoi(pbd_InRecChild[GT_SSD_CF]), atoi(pbd_InRecChild[GT_UWY_NF]), pbd_InRecChild[GT_CUR_CF], pbd_InRecOwner[PER_EGPCUR_CF]);

	if (Ratio <= 0 )
	{
		sprintf( MsgAno, "The rates of currency ( %s ) is not known for the perimeter contract ( CTR %s - SEC %s - UWY %s - UW %s) and BALSHEY %i \n",
			pbd_InRecChild[GT_CUR_CF],
			pbd_InRecChild[GT_CTR_NF],
			pbd_InRecChild[GT_SEC_NF],
			pbd_InRecChild[GT_UWY_NF],
			pbd_InRecChild[GT_UW_NT],
			atoi(pbd_InRecChild[GT_BALSHEY_NF]));
		
		n_WriteAno( MsgAno );
		return 0;
	}

	if ( n_type_trn_cd == PRM && flg_date == 1 )
	{
	        Kd_WrittenPrm += Ratio * atof(pbd_InRecChild[GT_AMT_M]) ;
	}
	if ( n_type_trn_cd == UPR && flg_date == 1 )
	{
	        Kd_UPR += Ratio * atof(pbd_InRecChild[GT_AMT_M]) ;
	}
	if ( n_type_trn_cd == UCLM && flg_date == 1 )
	{
	        Kd_UClaims += Ratio * atof(pbd_InRecChild[GT_AMT_M]) ;
	}
	if ( n_type_trn_cd == EBRK && flg_date == 1 )
        {
                Kd_ExpBrk += Ratio * atof(pbd_InRecChild[GT_AMT_M]) ;
        }
	if ( n_type_trn_cd == BRK && flg_date == 1 )
        {
                Kd_Brk += Ratio * atof(pbd_InRecChild[GT_AMT_M]) ;
        }
	// [007]
	if ( n_type_trn_cd == EBRK2 && flg_date == 1 )
        {
                Kd_ExpBrk += -1 * Ratio * atof(pbd_InRecChild[GT_AMT_M]) ;
        }
        if ( n_type_trn_cd == BRK2 && flg_date == 1 )
        {
                Kd_Brk += -1 * Ratio * atof(pbd_InRecChild[GT_AMT_M]) ;
        }
	if ( n_type_trn_cd == DACBRK && flg_date == 1 )
        {
                Kd_DACBrk += Ratio * atof(pbd_InRecChild[GT_AMT_M]) ;
        }

        // [009]
	// if ( n_type_trn_cd == DACI17 && flg_date == 1 )
        // {
        //         Kd_DACBrkI17 += Ratio * atof(pbd_InRecChild[GT_AMT_M]) ;
        // }

	if ( n_type_trn_cd == VARC && flg_date == 1 )
        {
                Kd_VarCom += Ratio * atof(pbd_InRecChild[GT_AMT_M]) ;
        }
	if ( n_type_trn_cd == DACVAR && flg_date == 1 )
        {
                Kd_DACVar += Ratio * atof(pbd_InRecChild[GT_AMT_M]) ;
        }
	if ( n_type_trn_cd == VARPRM && flg_date == 1 )
        {
                Kd_VarPrm += Ratio * atof(pbd_InRecChild[GT_AMT_M]) ;
        }

        RETURN_VAL( OK );
}

//[006]
/*==============================================================================
objet : Initialisation de la synchronisation du maitre avec l'esclave
retour :    OK
==============================================================================*/
int n_InitFacctr( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
        DEBUT_FCT( "n_InitFacctr" );

        memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) );

        /* ouverture du fichier esclave */
        if ( n_OpenFileAppl( "ESFC3890_I12", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
                return ERR;

        /* nombre de rupture a gerer */
        pbd_Rupt->n_NbRupture = 0;
        /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
        pbd_Rupt->ConditionEndSync = n_ConditionSyncFacctr;
        /* fonction d'action sur la ligne courante */
        pbd_Rupt->n_ActionLigne = n_ActionLigneFacctr;


        pbd_Rupt->c_Separ = '~';

        RETURN_VAL( OK );
}

/*==============================================================================
objet :
        fonction de test de synchronisation

retour :
        0       ---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)s
        > 0     ---> pbd_InRecOwne> > pbd_InRecChild    < 0     ---> pbd_InRecOwne> < pbd_InRecChild
        < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncFacctr(
        char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
        char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
        int ret;

        DEBUT_FCT( "n_ConditionSyncFacctr" );

        if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[FACCTR_CTR_NF] ) ) != 0 ) return ret;
        if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[FACCTR_END_NT] ) ) != 0 ) return ret;
        if ( ( ret = atoi( pbd_InRecOwner[PER_SEC_NF] ) - atoi( pbd_InRecChild[FACCTR_SEC_NF] ) ) != 0 ) return ret ;
        if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[FACCTR_UWY_NF] ) ) != 0 ) return ret;
        if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[FACCTR_UW_NT] ) ) != 0 ) return ret;

        RETURN_VAL( 0 );
}


/*==============================================================================
                ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneFacctr(
        char **pbd_InRecOwner , /* adresse de la ligne du maitre */
        char **pbd_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT("n_ActionLigneFacctr");

	int 	IncStatus = -1; // Inception status
	char	FirstCloDat[9] = "";
	char	IncDat[9] = "";

	strcpy(IncDat, pbd_InRecOwner[PER_CTRINC_D]);

	if ( strncmp(Ksz_Norme, "I17G", 4) == 0 || strncmp(Ksz_Norme, "I17S", 4) == 0)    //[12]
	{
                IncStatus = atoi(pbd_InRecChild[FACCTR_GRPINISTS_CT]);
		strcpy(FirstCloDat,pbd_InRecChild[FACCTR_GRPFIRCLO_D]);
	}
        if ( strncmp(Ksz_Norme, "I17P", 4) == 0)
	{
                IncStatus = atoi(pbd_InRecChild[FACCTR_PARINISTS_CT]);
		strcpy(FirstCloDat,pbd_InRecChild[FACCTR_PARFIRCLO_D]);
	}
        if ( strncmp(Ksz_Norme, "I17L", 4) == 0)
        {
		IncStatus = atoi(pbd_InRecChild[FACCTR_LOCINISTS_CT]);
		strcpy(FirstCloDat,pbd_InRecChild[FACCTR_LOCFIRCLO_D]);
	}

	if ( ((IncStatus == 2 && strcmp(FirstCloDat, "") != 0 && atoi(FirstCloDat) <= atoi(Ksz_PrevClodat)) && atoi(IncDat) <= atoi(Ksz_PrevClodat))  || IncStatus == 9)
		t = 0;
        else 
	{ 
		if ( (IncStatus == 1 || IncStatus == 2) && atoi(IncDat) <= atoi(Ksz_Clodat))
			t = 1;
		else
			flag_compute = 0;
	}

        RETURN_VAL( OK );
}
// [006]

/*==============================================================================
objet:
        Lit le fichier binaire FSEGEST et le charge en memoire

==============================================================================*/
int n_ChargerTSEGEST( void )
{
	int i = 0 ;
	char sz_message[200];
	
	DEBUT_FCT("n_ChargerTSEGEST");
	
	char buffer[LGTH_SEGEST];
	char **tab=NULL;

	while (fgets( buffer, LGTH_SEGEST, Kp_InputFilSegest)!= NULL)
	{
		tab = split(buffer, SEPARATOR ,1);
		Ktbd_Segest[i].SSD_CF = atoi(tab[SEG_SSD_CF]);

		//Pour le segment spéciale * on ne prend que ce caractè
		if ( tab[SEG_SEG_NF][0] == '*')
			strcpy(Ktbd_Segest[i].SEG_NF, "*");
		else
			strcpy(Ktbd_Segest[i].SEG_NF, tab[SEG_SEG_NF]);

		Ktbd_Segest[i].UWY_NF = atoi(tab[SEG_UWY_NF]);
		strcpy(Ktbd_Segest[i].CUR_CF, tab[SEG_CUR_CF]);
		Ktbd_Segest[i].SEGNAT_CT = *tab[SEG_SEGNAT_CT];
		Ktbd_Segest[i].CLMAMT_M = atof(tab[SEG_CLMAMT_M]);
		Ktbd_Segest[i].LOSRAT_R = atof(tab[SEG_LOSRAT_R]);
		Ktbd_Segest[i].AMORAT_CT = *tab[SEG_AMORAT_CT];
		Ktbd_Segest[i].SEGTYP_CT = *tab[SEG_SEGTYP_CT];
		
		i++;
		
		if ( i > NB_SEGEST_MAX )
		{
			sprintf(sz_message,"la taille du tableau Ktbd_Segest depasse la taille allouee %d", i);
			n_WriteAno(sz_message);
			RETURN_VAL( i );
		}
	}

	RETURN_VAL( i );
}


/*==============================================================================
objet :
        Recherche de la ligne correspondant au SSD, SEG, UWY en parametre
retour :
	indice de la ligne correspondant sinon -1
==============================================================================*/
int n_RechPosteTSEGEST( int n_ssd, char *sz_seg, int n_uwy, char * sz_segtyps ) 
{
       int n_indice, n_indiceEx, n_ret;
        char c_flgSegest = 'N';
        n_indiceEx = -1;

        DEBUT_FCT("n_RechPosteTSEGEST");

        for( n_indice = 0; n_indice < Kn_NbLig_Segest; n_indice++ )
        {
                // Localisation filiale
                n_ret = n_ssd - Ktbd_Segest[n_indice].SSD_CF;

                if ( n_ret < 0)
                {
                        if (c_flgSegest == 'N')
                                RETURN_VAL( -1 ) ;
                        else
                        {
                                RETURN_VAL(n_indiceEx);
                        }
                }
                if ( n_ret > 0 ) continue ;
                else
                {
                        // Localisation Segment
                        if ( strcmp(sz_seg, Ktbd_Segest[n_indice].SEG_NF) != 0 && c_flgSegest == 'N' ) continue;
                        // if ( strcmp(sz_seg, Ktbd_Segest[n_indice].SEG_NF) != 0 && c_flgSegest == 'Y' ) {RETURN_VAL( n_indiceEx );} // [014]
                        if ( strcmp(sz_seg, Ktbd_Segest[n_indice].SEG_NF) == 0 && strchr( sz_segtyps, Ktbd_Segest[n_indice].SEGTYP_CT )   ) // [10] IFRS17 req 10.6
                        {
				//[004]
                                // Localisation exercice
                                //if ( c_flgSegest == 'N' && strcmp(sz_segtyps, "ATU") == 0) n_indiceEx = n_indice;                    // Plus ancien exercice trouv�
                                if ( Ktbd_Segest[n_indice].UWY_NF == n_uwy ) n_indiceEx = n_indice; // Exercice exact trouv�
                                c_flgSegest = 'Y';
                                //if ( Ktbd_Segest[n_indice].UWY_NF == 8888 ) {RETURN_VAL( n_indice );} // Exercice 8888 trouvé prioritaie
                        }
                }
        }
        if ( c_flgSegest == 'Y' ) {RETURN_VAL( n_indiceEx );}  // [001]
        else RETURN_VAL( -1 );  // Aucune occurence trouvé 
}

/*==============================================================================
objet:
        Lit le fichier FRARAT et le charge en memoire

==============================================================================*/
int n_ChargerTRARAT( void )
{
	int i = 0 ;
	char sz_message[200];

	DEBUT_FCT("n_ChargerTRARAT");
	
	char buffer[LGTH_RARAT];
	char **tab=NULL;

	while (fgets( buffer, LGTH_RARAT, Kp_InputFilRaRat)!= NULL)
	{
		tab = split(buffer, SEPARATOR ,1);
		Ktbd_rarat[i].SSD_CF = atoi(tab[RAT_SSD_CF]);
		
		//Pour le segment speciale * on ne prend que ce caractere !
		if ( tab[RAT_SEG_NF][0] == '*')
			strcpy(Ktbd_rarat[i].SEG_NF, "*");
		else
			strcpy(Ktbd_rarat[i].SEG_NF, tab[RAT_SEG_NF]);
		
		
		Ktbd_rarat[i].ESB_CF = atoi(tab[RAT_ESB_CF]);
		
		Ktbd_rarat[i].CTRNAT_CT = *tab[RAT_CTRNAT_CT];
		strcpy(Ktbd_rarat[i].DOMAIN_CF, tab[RAT_DOMAIN_CF]);
		
		Ktbd_rarat[i].PRMRAT_R = atof(tab[RAT_PRMRAT_R]);
		Ktbd_rarat[i].RSRVRAT_R = atof(tab[RAT_RSRVRAT_R]);
		
		strcpy(Ktbd_rarat[i].SGMT_LS, tab[RAT_SGMT_LS]);
		
		i++;
		if ( i > NB_RARAT_MAX )
		{
			sprintf(sz_message,"la taille du tableau Ktbd_rarat depasse la taille allouee %d", i);
			n_WriteAno(sz_message);
			RETURN_VAL( i );
		}
	}
	
	RETURN_VAL( i );
}

/*==============================================================================
objet :
        fonction de recherche des ratios

retour :

==============================================================================*/
int n_RechTRARAT( int c_ssd, short c_esb_cf , char *sz_seg , char c_ctrnat_cf, char * sz_domain_cf )
{
	int n_indice,n_ret;
	
	DEBUT_FCT("n_RechTRARAT");

	for( n_indice = 0; n_indice < Kn_NbLig_RaRat; n_indice++ )
	{
		// Localisation filiale
		n_ret =  c_ssd - Ktbd_rarat[n_indice].SSD_CF;
		if ( n_ret < 0 ) RETURN_VAL( -1 ) ;
		if ( n_ret > 0 ) continue ;
	
		// Localisation ESB_CF
		n_ret =  c_esb_cf - Ktbd_rarat[n_indice].ESB_CF;
		if ( n_ret < 0 ) RETURN_VAL( -1 ) ;
		if ( n_ret > 0 ) continue ;
	
		// Localisation Segment
		if ( strcmp(sz_seg, Ktbd_rarat[n_indice].SGMT_LS) < 0 ) RETURN_VAL( -1 ) ;
		if ( strcmp(sz_seg, Ktbd_rarat[n_indice].SGMT_LS) > 0 ) continue;
	
		// Localisation contract nature
		n_ret =  c_ctrnat_cf - Ktbd_rarat[n_indice].CTRNAT_CT;
		if ( n_ret < 0 ) RETURN_VAL( -1 ) ;
		if ( n_ret > 0 ) continue ;
	
		// Localisation Domain
		if ( strcmp(sz_domain_cf, Ktbd_rarat[n_indice].DOMAIN_CF) < 0 ) RETURN_VAL( -1 ) ;
		if ( strcmp(sz_domain_cf, Ktbd_rarat[n_indice].DOMAIN_CF) > 0 ) continue;
		
		RETURN_VAL( n_indice );
	}
	RETURN_VAL( -1 );  // Aucune occurence trouve
}

/*==============================================================================
objet:
        Lit le fichier EXPRAT et le charge en memoire

==============================================================================*/
int n_ChargerEXPRAT( void )
{
        int i = 0 ;
        char sz_message[200];

        DEBUT_FCT("n_ChargerEXPRAT");

        char buffer[LGTH_EXPRAT];
        char **tab=NULL;

        while (fgets( buffer, LGTH_EXPRAT, Kp_InputFilExpRat)!= NULL)
        {
                tab = split(buffer, SEPARATOR ,1);
                Ktbd_Exprat[i].SSD_CF = atoi(tab[EXP_SSD_CF]);

                Ktbd_Exprat[i].ESB_CF = atoi(tab[EXP_ESB_CF]);

		Ktbd_Exprat[i].SEGID_CF = atoi(tab[EXP_SEGID_CF]);

		strcpy(Ktbd_Exprat[i].SEG_CF, tab[EXP_SEG_CF]);

		Ktbd_Exprat[i].PLBL_CF = atoi(tab[EXP_PLBL_CF]);

                strcpy(Ktbd_Exprat[i].VRS_NF, tab[EXP_VRS_NF]);

		Ktbd_Exprat[i].CTRNAT_CT = *tab[EXP_CTRNAT_CT];

                Ktbd_Exprat[i].IAERAT_R = atof(tab[EXP_IAERAT_R]);

                Ktbd_Exprat[i].IMERAT_R = atof(tab[EXP_IMERAT_R]);

                i++;
                if ( i > NB_EXPRAT_MAX )
                {
                        sprintf(sz_message,"la taille du tableau Ktbd_Exprat depasse la taille allouee %d", i);
                        n_WriteAno(sz_message);
                        RETURN_VAL( i );
                }
        }

        RETURN_VAL( i );
}

/*==============================================================================
objet :
        fonction de recherche des ratios

retour :

==============================================================================*/
int n_RechEXPRAT( int c_ssd, short c_esb_cf , int c_plbl , char c_ctrnat_cf )
{
        int n_indice,n_ret;

        DEBUT_FCT("n_RechEXPRAT");

        for( n_indice = 0; n_indice < Kn_NbLig_ExpRat; n_indice++ )
        {
                // Localisation filiale
                n_ret =  c_ssd - Ktbd_Exprat[n_indice].SSD_CF;
                if ( n_ret < 0 ) RETURN_VAL( -1 ) ;
                if ( n_ret > 0 ) continue ;

                // Localisation ESB_CF
                n_ret =  c_esb_cf - Ktbd_Exprat[n_indice].ESB_CF;
                if ( n_ret < 0 ) RETURN_VAL( -1 ) ;
                if ( n_ret > 0 ) continue ;

                // Localisation Parent Label
		n_ret =  c_plbl - Ktbd_Exprat[n_indice].PLBL_CF;                
		if ( n_ret < 0 ) RETURN_VAL( -1 ) ;
		if ( n_ret > 0 ) continue ;

                // Localisation contract nature
                n_ret =  c_ctrnat_cf - Ktbd_Exprat[n_indice].CTRNAT_CT;
                if ( n_ret < 0 ) RETURN_VAL( -1 ) ;
                if ( n_ret > 0 ) continue ;

                RETURN_VAL( n_indice );
        }
        RETURN_VAL( -1 );  // Aucune occurence trouve
}

/*==============================================================================
objet :
  Chargement du tableau FBOTRSLNK
retour :
  Taille du tableau
==============================================================================*/
int n_ChargerFBOTRSLNK()
{
	int i = 0 ;
	char flg_tcode ;
	
	DEBUT_FCT("n_ChargerFBOTRSLNK");
	
	while (fread(&Ktbd_FBOTRSLNK[i], sizeof(T_FBOTRSLNK), 1, Kp_FBOTRSLNK) == 1)
	{
		if (	Ktbd_FBOTRSLNK[i].TRSPFX_CF == '1' &&
			(Ktbd_FBOTRSLNK[i].DETTRS_CF[1] == '1' || Ktbd_FBOTRSLNK[i].DETTRS_CF[1] == '4'
			|| Ktbd_FBOTRSLNK[i].DETTRS_CF[1] == 'A' || Ktbd_FBOTRSLNK[i].DETTRS_CF[1] == 'E' 
			|| Ktbd_FBOTRSLNK[i].DETTRS_CF[1] == '7'))
			flg_tcode = 'Y';
		else flg_tcode = 'N';

		if
		(
			((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 1010
                        || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 1013 || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 1014)
                        && Ktbd_FBOTRSLNK[i].TRNTYP_CT < 100
                        && flg_tcode == 'Y') || // PRM

			((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 1030
                        || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 1020)
                        && Ktbd_FBOTRSLNK[i].TRNTYP_CT < 100
                        && flg_tcode == 'Y') || // UPR
			
			((Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 301 || Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 302
                        || Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 303 || Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 306
                        || Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 307 || Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 308
                        || Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 309)
                        && Ktbd_FBOTRSLNK[i].TRNTYP_CT <= 100 // [007]
                        && flg_tcode == 'Y') || // UCLM

			((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 3096
                        || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 3086) // [007]
			&& Ktbd_FBOTRSLNK[i].DETTRS_CF[7] == Kc_Norme_Suf[0]
                        && flg_tcode == 'Y') || // ULKI

			// [007]
			((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 4222)
                        && Ktbd_FBOTRSLNK[i].DETTRS_CF[7] == Kc_Norme_Suf[0]
                        && flg_tcode == 'Y') || // ULKI2
			
			// [002]
			((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2043 || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2053
			|| Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2026 || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2036)
                        && flg_tcode == 'Y') || // EBRK

                        ((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2048 || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2058
                        || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2153 || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT ==2158)
                        && Ktbd_FBOTRSLNK[i].DETTRS_CF[7] == Kc_Norme_Suf[0]
                        && flg_tcode == 'Y') || // EBRK

			((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 4201)
                        && Ktbd_FBOTRSLNK[i].DETTRS_CF[7] == Kc_Norme_Suf[0]
                        && flg_tcode == 'Y') || // EBRK2

                        ((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2014)
                        && flg_tcode == 'Y') || // BRK

                        ((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2023
                        || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2033)
                        && Ktbd_FBOTRSLNK[i].DETTRS_CF[7] == Kc_Norme_Suf[0]
                        && flg_tcode == 'Y') || //BRK

			((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 4221)
                        && Ktbd_FBOTRSLNK[i].DETTRS_CF[7] == Kc_Norme_Suf[0]
                        && flg_tcode == 'Y') || //BRK2

                        ((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2021 || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2031)
                        && Ktbd_FBOTRSLNK[i].TRNTYP_CT < 100
                        && flg_tcode == 'Y') || //DACBRK

                        ((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2035)
                        && flg_tcode == 'Y') || // DACI17

                        ((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2025)
                        && Ktbd_FBOTRSLNK[i].DETTRS_CF[7] == Kc_Norme_Suf[0]
                        && flg_tcode == 'Y') || // DACI17

                        (Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2091
                        && Ktbd_FBOTRSLNK[i].DETTRS_CF[7] == Kc_Norme_Suf[0]
                        && flg_tcode == 'Y') || //EIAE

                        // [008]
                        ((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 3104 || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 3114
                        || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 3116
                        || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 3107
                        || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 3117
                        )
                        && Ktbd_FBOTRSLNK[i].DETTRS_CF[7] == Kc_Norme_Suf[0]
                        && flg_tcode == 'Y') || //EIME

                        // [008]
                        (Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 4224
                        && Ktbd_FBOTRSLNK[i].DETTRS_CF[7] == Kc_Norme_Suf[0]
                        && flg_tcode == 'Y') || //EIME2
			
			// [002]

                        ((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2015 || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2016
                        || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2017 || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2018)
                        && flg_tcode == 'Y') || // VARC

                        // [010]
                        ((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2022 || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2032)
                        && Ktbd_FBOTRSLNK[i].TRNTYP_CT < 100
                        && flg_tcode == 'Y') || // DACVAR

                        (Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 1011 && flg_tcode == 'Y') // VARPRM
		)
		{
			i += 1;
		}

		if ( i > Kn_MaxLigFBOTRSLNK )
		{
			n_WriteAno("Depassement de capacite du tableau Ktbd_FBOTRSLNK");
			RETURN_VAL(-1);
		}
	}
	if ( i == 0 )
	{
		n_WriteAno("Fichier FBOTRSLNK vide");
		RETURN_VAL(-1);
	}
	
	RETURN_VAL(i);
}


/*==============================================================================
objet :
	fonction de recherche du trncod
retour :
	PRM	1	Written Premium
	UPR	2	UPR
	UCLM	3	Undiscounted Earned Claims
	ULKI	4	Discount/Unwind credit earned claim LKI
	EBRK	5	Expected Brokerage
	BRK	6	Brokerage
	DACBRK	7	DAC Brokerage
	DACI17	8	DAC Brokerage IFRS17
	EIAE	9	Earned IAE
	EIME	10	Earned IME
	VARC	11	Variable Commissions
	DACVAR	12	DAC Variable
	VARPRM	13	Variable Premiums
	ULKI2	14	Discount/Unwind credit earned claim LKI
	EBRK2	15	Expected Brokerage
	BRK2	16	Brokerage
	EIME2	17	Earned IME
	OTHER	18	
==============================================================================*/
int n_check_trncd_cf(char *sz_TrnCd)
{
	int i ;
	char  flg_tcode;

	DEBUT_FCT("n_check_trncd_cf");

	for ( i = 0; i <  Kn_FBOTRSLNK ; i++ )
	{
        	if ( strcmp( sz_TrnCd, Ktbd_FBOTRSLNK[i].DETTRS_CF ) == 0 )
		{
			if (	(Ktbd_FBOTRSLNK[i].DETTRS_CF[1] == '1' || Ktbd_FBOTRSLNK[i].DETTRS_CF[1] == '4'
				|| Ktbd_FBOTRSLNK[i].DETTRS_CF[1] == 'A' || Ktbd_FBOTRSLNK[i].DETTRS_CF[1] == 'E'
				|| Ktbd_FBOTRSLNK[i].DETTRS_CF[1] == '7') // [002]
				&& Ktbd_FBOTRSLNK[i].TRSPFX_CF == '1')
				flg_tcode = 'Y';
			else
				flg_tcode = 'N';
	
			if (	(Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 1010
				|| Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 1013 || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 1014)
				&& Ktbd_FBOTRSLNK[i].TRNTYP_CT < 100
				&& flg_tcode == 'Y')
				RETURN_VAL(PRM) ;

			else if((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 1030
                                || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 1020)
				&& Ktbd_FBOTRSLNK[i].TRNTYP_CT < 100
                                && flg_tcode == 'Y')
				RETURN_VAL(UPR) ;

			else if((Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 301 || Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 302
				|| Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 303 || Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 306
				|| Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 307 || Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 308
				|| Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 309)
				&& Ktbd_FBOTRSLNK[i].TRNTYP_CT <= 100 // [007]
                                && flg_tcode == 'Y')
				RETURN_VAL(UCLM) ;

			else if((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 3096
				|| Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 3086)
				&& Ktbd_FBOTRSLNK[i].DETTRS_CF[7] == Kc_Norme_Suf[0] 
				&& flg_tcode == 'Y')
				RETURN_VAL(ULKI) ;

			// [007]
                        else if((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 4222)
                                && Ktbd_FBOTRSLNK[i].DETTRS_CF[7] == Kc_Norme_Suf[0]
                                && flg_tcode == 'Y')
                                RETURN_VAL(ULKI2) ;

			// [002]
			else if((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2043 || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2053
				|| Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2026 || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2036)
				&& flg_tcode == 'Y')
				RETURN_VAL(EBRK) ;

                        else if((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2048 || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2058
                                || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2153 || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT ==2158)
                                && Ktbd_FBOTRSLNK[i].DETTRS_CF[7] == Kc_Norme_Suf[0] 
                                && flg_tcode == 'Y')
                                RETURN_VAL(EBRK) ;

			// [007]
			else if((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 4201)
                                && Ktbd_FBOTRSLNK[i].DETTRS_CF[7] == Kc_Norme_Suf[0]
                                && flg_tcode == 'Y')
                                RETURN_VAL(EBRK2) ;

			else if((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2014)
				&& flg_tcode == 'Y')
				RETURN_VAL(BRK) ;

                        else if((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2023
                                || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2033)
                                && Ktbd_FBOTRSLNK[i].DETTRS_CF[7] == Kc_Norme_Suf[0]
                                && flg_tcode == 'Y')
                                RETURN_VAL(BRK) ;

			// [007]
			else if((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 4221)
                                && Ktbd_FBOTRSLNK[i].DETTRS_CF[7] == Kc_Norme_Suf[0]
                                && flg_tcode == 'Y')
                                RETURN_VAL(BRK) ;

			else if((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2021 || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2031)
				&& Ktbd_FBOTRSLNK[i].TRNTYP_CT < 100
				&& flg_tcode == 'Y')
				RETURN_VAL(DACBRK) ;

			else if((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2035)
				&& flg_tcode == 'Y')
				RETURN_VAL(DACI17) ;

			else if((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2025)
                                && Ktbd_FBOTRSLNK[i].DETTRS_CF[7] == Kc_Norme_Suf[0]
                                && flg_tcode == 'Y')
                                RETURN_VAL(DACI17) ;

			else if(Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2091 
				&& Ktbd_FBOTRSLNK[i].DETTRS_CF[7] == Kc_Norme_Suf[0]
				&& flg_tcode == 'Y')
				RETURN_VAL(EIAE) ;

                        // [008]
			else if((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 3104 || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 3114
				|| Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 3116
                                || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 3107
                                || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 3117
                                )
				&& Ktbd_FBOTRSLNK[i].DETTRS_CF[7] == Kc_Norme_Suf[0]
				&& flg_tcode == 'Y')
				RETURN_VAL(EIME) ;

                        // [008]
			else if(Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 4224
				&& Ktbd_FBOTRSLNK[i].DETTRS_CF[7] == Kc_Norme_Suf[0]
				&& flg_tcode == 'Y')
				RETURN_VAL(EIME2) ;

			// [002]
			else if((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2015 || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2016
				|| Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2017 || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2018)
				&& flg_tcode == 'Y')
				RETURN_VAL(VARC) ;

                        // [010]
			else if((Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2022 || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2032)
                                && Ktbd_FBOTRSLNK[i].TRNTYP_CT < 100
				&& flg_tcode == 'Y')
				RETURN_VAL(DACVAR) ;

			else if(Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 1011 && flg_tcode == 'Y')
				RETURN_VAL(VARPRM) ;
		}
	}

	RETURN_VAL(OTHER) ;
}

/*==============================================================================
objet :
	Fonction Calcul des Current
retour :
	OK quand la fonction se termine
==============================================================================*/
int n_calcul_aoc(char **pbd_InRec_Cur)
{
	DEBUT_FCT("n_calcul_aoc");
	
	char sz_Trncod[9];

	Kd_EarnedPrm =  Kd_WrittenPrm + Kd_UPR;
        Kd_EarnedClaims = Kd_UClaims + Kd_ULKI ;
	
	// Calcul Current Ratio
	if ( t == 1 )
                Kd_CurRat = 1;
    else
	{
		if (fabs(Kd_UClaims) < 1)
			Kd_CurRat = 0;
		else
            Kd_CurRat = (-1) * Kd_EarnedPrm * Kd_ULR * (100/Kd_UClaims);
	}
	// Calcul Current Loss
        if( t != 1 && Kd_ULR ==0 ) // Si t > 1 et ULR = 0, on ne calcule pas Current Loss
		Kd_CurLoss = 0 ;
	else
		Kd_CurLoss = Kd_EarnedClaims * Kd_CurRat ;
	
	// Calcul Current Risk Adjustment
        Kd_CurRA = Kd_CurLoss * Kd_RA ;

	// Calcul Current Brokerage
	if ( t == 1 )
	        Kd_CurBrk =  Kd_Brk + Kd_DACBrk + Kd_DACBrkI17 ;
	else
		Kd_CurBrk = Kd_ExpBrk + Kd_DACBrkI17;

	// Calcul Current Internal Acquisition Expenses
	//[003]
       	Kd_CurIAE =  Kd_IAE ;
	
	// Calcul Current Internal Maintenance Expenses
        Kd_CurIME = Kd_IME * Kd_CurRat ;

	// Calcul Current Variable Commissions
	if ( t == 1 )
	        Kd_CurVarCom = Kd_VarCom + Kd_DACVar ;
	else
		Kd_CurVarCom = Kd_CurRat * (Kd_VarCom + Kd_DACVar) ;

	// CalculCurrent Variable Premiums
	if ( t == 1 )
	        Kd_CurVarPrm = Kd_VarPrm ;
	else
		Kd_CurVarPrm = Kd_CurRat * Kd_VarPrm ;

	Kd_IncClaims = Kd_CurLoss + Kd_CurVarCom + Kd_CurVarPrm ;

	Kd_IncAcCost = ( (-1)*Kd_CurLoss - Kd_CurVarCom - Kd_CurVarPrm ) ;

    // [006]
    if( fabs(Kd_CurRat) > 0 && flag_compute == 1 ) {
        strcpy( sz_Trncod, "99999119" );
        n_EcrireGt(pbd_InRec_Cur , pbd_InRec_Cur[PER_CTR_NF], Kd_CurRat , sz_Trncod);
    }


	if( fabs(Kd_IncClaims) > 0 && flag_compute == 1 ) {
		strcpy( sz_Trncod, "1149491" );
		strcat( sz_Trncod, Kc_Norme_Suf) ;
		n_EcrireGt(pbd_InRec_Cur , pbd_InRec_Cur[PER_CTR_NF], Kd_IncClaims , sz_Trncod);
	}

	if( fabs(Kd_CurRA) > 0 && flag_compute == 1 ) {
        strcpy( sz_Trncod, "1142791" );
        strcat( sz_Trncod, Kc_Norme_Suf) ;
        n_EcrireGt(pbd_InRec_Cur , pbd_InRec_Cur[PER_CTR_NF], Kd_CurRA , sz_Trncod);
        strcpy( sz_Trncod, "1142792" );
        strcat( sz_Trncod, Kc_Norme_Suf) ;
        n_EcrireGt(pbd_InRec_Cur , pbd_InRec_Cur[PER_CTR_NF], -Kd_CurRA , sz_Trncod);
    }

	if( fabs(Kd_CurBrk) > 0 && flag_compute == 1 ) {
        strcpy( sz_Trncod, "1112491" );
        strcat( sz_Trncod, Kc_Norme_Suf) ;
        n_EcrireGt(pbd_InRec_Cur , pbd_InRec_Cur[PER_CTR_NF], Kd_CurBrk , sz_Trncod);
        strcpy( sz_Trncod, "1112492" );
        strcat( sz_Trncod, Kc_Norme_Suf) ;
        n_EcrireGt(pbd_InRec_Cur , pbd_InRec_Cur[PER_CTR_NF], -Kd_CurBrk , sz_Trncod);
    }

	if( fabs(Kd_CurIAE) > 0 && flag_compute == 1 ) {
        strcpy( sz_Trncod, "1110291" );
        strcat( sz_Trncod, Kc_Norme_Suf) ;
        n_EcrireGt(pbd_InRec_Cur , pbd_InRec_Cur[PER_CTR_NF], Kd_CurIAE , sz_Trncod);
        strcpy( sz_Trncod, "1110292" );
        strcat( sz_Trncod, Kc_Norme_Suf) ;
        n_EcrireGt(pbd_InRec_Cur , pbd_InRec_Cur[PER_CTR_NF], -Kd_CurIAE , sz_Trncod);
    }

	if( fabs(Kd_CurIME) > 0 && flag_compute == 1 ) {
        strcpy( sz_Trncod, "1146091" );
        strcat( sz_Trncod, Kc_Norme_Suf) ;
        n_EcrireGt(pbd_InRec_Cur , pbd_InRec_Cur[PER_CTR_NF], Kd_CurIME , sz_Trncod);
        strcpy( sz_Trncod, "1146092" );
        strcat( sz_Trncod, Kc_Norme_Suf) ;
        n_EcrireGt(pbd_InRec_Cur , pbd_InRec_Cur[PER_CTR_NF], -Kd_CurIME , sz_Trncod);
    }

	if( fabs(Kd_IncAcCost) > 0 && flag_compute == 1 ) {
        strcpy( sz_Trncod, "1149492" );
        strcat( sz_Trncod, Kc_Norme_Suf) ;
        n_EcrireGt(pbd_InRec_Cur , pbd_InRec_Cur[PER_CTR_NF], Kd_IncAcCost , sz_Trncod);
    }

	RETURN_VAL(OK) ;
}

/*==============================================================================
objet :
        Initialisation de la synchronisation du maitre ▒ Ultim ▒

retour :
        OK
==============================================================================*/
int n_InitUltim( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
        DEBUT_FCT( "n_InitUltim" );

        memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) );

        /* ouverture du fichier esclave */
        if ( n_OpenFileAppl( "ESFC3890_I10", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
                return ERR;

        /* nombre de rupture a gerer */
        pbd_Rupt->n_NbRupture = 0;

        /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
        pbd_Rupt->ConditionEndSync = n_ConditionSyncUltim;

        /* fonction d'action sur la ligne courante */
        pbd_Rupt->n_ActionLigne = n_ActionLigneUltim;
        pbd_Rupt->c_Separ = '~';

        RETURN_VAL( OK );
}

/*==============================================================================
objet :
        fonction de test de synchronisation

retour :
        0       ---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)ss
        > 0     ---> pbd_InRecOwne> > pbd_InRecChild    < 0     ---> pbd_InRecOwne> < pbd_InRecChild
        < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncUltim(
        char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
        char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
        int ret;

        DEBUT_FCT( "n_ConditionSyncUltim" );

        if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[ULTIM_CTR_NF] ) ) != 0 ) return ret;
        if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[ULTIM_END_NT] ) ) != 0 ) return ret;
        if ( ( ret = atoi(pbd_InRecOwner[PER_SEC_NF]) - atoi(pbd_InRecChild[MARKET_SEC_NF]) ) != 0 ) return ret;
        if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[ULTIM_UWY_NF] ) ) != 0 ) return ret;
        if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[ULTIM_UW_NT] ) ) != 0 ) return ret;

        RETURN_VAL( 0 );
}

/*==============================================================================
objet :
        fonction lancee pour chaque ligne

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneUltim( char **pbd_InRecOwner, char **pbd_InRecChild )
{
        char  sz_LOSRAT_R[30] ;    /* zone de travail */
        char  sz_Seg[12];
        int   n_indice = -1;
        int   n_Ssd = 0;
        int   n_Uwy = 0;

        DEBUT_FCT( "n_ActionLigneUltim" ) ;

        /* Recherche dans le fichier FSEGEST */

        n_Ssd = (char) atoi( pbd_InRecChild[ULTIM_SSD_CF] );
        n_Uwy = atoi( pbd_InRecChild[ULTIM_UWY_NF] );
        strcpy(sz_Seg, pbd_InRecChild[ULTIM_SEG_NF]);

	if(strcmp(Ksz_TypeInv, "INV") == 0)
		n_indice = n_RechPosteTSEGEST(n_Ssd, sz_Seg, n_Uwy, "A");
	else if(strcmp(Ksz_TypeInv, "POS") == 0)
		n_indice = n_RechPosteTSEGEST(n_Ssd, sz_Seg, n_Uwy, "T");
	else if(strcmp(Ksz_TypeInv, "POC") == 0)
        	n_indice = n_RechPosteTSEGEST(n_Ssd, sz_Seg, n_Uwy, "U");

        if (n_indice >= 0)
        {
                sprintf(sz_LOSRAT_R, "%-.8lf", Ktbd_Segest[n_indice].LOSRAT_R);
                Kd_ULR = atof(sz_LOSRAT_R);
        }
        else
        {
                Kd_ULR = 0.00000000;
        }

        RETURN_VAL( OK ) ;
}

/*==============================================================================
objet :
        Initialisation de la synchronisation du maitre ▒~V~R Ultim ▒~V~R

retour :
        OK
==============================================================================*/
int n_InitMarket( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
        DEBUT_FCT( "n_InitMarket" );

        memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) );

        /* ouverture du fichier esclave */
        if ( n_OpenFileAppl( "ESFC3890_I11", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
                return ERR;

        /* nombre de rupture a gerer */
        pbd_Rupt->n_NbRupture = 0;

        /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
        pbd_Rupt->ConditionEndSync = n_ConditionSyncMarket;

        /* fonction d'action sur la ligne courante */
        pbd_Rupt->n_ActionLigne = n_ActionLigneMarket;
        pbd_Rupt->c_Separ = '~';

        RETURN_VAL( OK );
}

/*==============================================================================
objet :
        fonction de test de synchronisation

retour :
        0       ---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)sse
        > 0     ---> pbd_InRecOwne> > pbd_InRecChild    < 0     ---> pbd_InRecOwne> < pbd_InRecChild
        < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncMarket(
        char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
        char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
        int ret;

        DEBUT_FCT( "n_ConditionSyncMarket" );

        if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[MARKET_CTR_NF] ) ) != 0 ) return ret;
        if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[MARKET_END_NT] ) ) != 0 ) return ret;
        if ( ( ret = atoi(pbd_InRecOwner[PER_SEC_NF]) - atoi(pbd_InRecChild[MARKET_SEC_NF]) ) != 0 ) return ret;
        if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[MARKET_UWY_NF] ) ) != 0 ) return ret;
        if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[MARKET_UW_NT] ) ) != 0 ) return ret;

        RETURN_VAL( 0 );
}

/*==============================================================================
objet :
        fonction lancee pour chaque ligne

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneMarket( char **pbd_InRecOwner, char **pbd_InRecChild )
{
        char  sz_Seg[12];
        int   n_indice = 0;
        int   n_Ssd = 0;
        short s_Esb = 0;
        char  c_CtrNat;
        char  sz_domain[10];
	int   n_plbl =0;
        DEBUT_FCT( "n_ActionLigneUltim" ) ;

        n_Ssd = atoi( pbd_InRecOwner[PER_SSD_CF] );
        s_Esb = (short) atoi(pbd_InRecOwner[PER_ACCESB_CF]);
        strcpy(sz_Seg, pbd_InRecChild[MARKET_GTSII_GRPGRP3_NF]);
        c_CtrNat = *pbd_InRecOwner[PER_CTRNAT_CT];

        if ( strcmp(pbd_InRecOwner[PER_CTRTYP_CT],"RET" ) != 0 )
        {
                strcpy(sz_domain,"Gross"); // Assumed
        }
        else
        {
                strcpy(sz_domain,"");
        }

        n_indice = n_RechTRARAT( n_Ssd , s_Esb , sz_Seg , c_CtrNat, sz_domain);
        if ( n_indice != -1 )
        {
                Kd_RA = Ktbd_rarat[n_indice].RSRVRAT_R;
        }

	n_plbl = atoi(pbd_InRecChild[MARKET_LBL_NF]);

	n_indice = n_RechEXPRAT( n_Ssd , s_Esb , n_plbl , c_CtrNat);
	if ( n_indice != -1 )
	{
		Kd_IAERat = Ktbd_Exprat[n_indice].IAERAT_R;
	}



        RETURN_VAL( OK ) ;
}

/*==============================================================================
objet :
        Ecrit en sortie

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_EcrireGt( char **pbd_InRec_Cur , char *CTR_NF, double d_Montant, char *account )
{
	DEBUT_FCT("n_EcrireGt");
	
	char  *Gt[NB_COL_GT2 + 1] ;	/* tableau de pointeurs a l'image du GT */
	char  sz_Vide[2] = "" ;
	char  sz_Amt[30] ;      	/* zone de travail */
	
	char  sz_Acy[6] ;             	/* zone de travail */
	char  sz_Mth[4] ;   		/* zone de travail */
	char  sz_Day[4] ;   		/* zone de travail */
	char  sz_zero[2];
	
	char   sz_Dblcod[9];
	
	 /* Eclatement de la date AAAAMMJJ en 3 chaines de caractere */
	sscanf( Ksz_Clodat, "%4s%2s%2s", sz_Acy, sz_Mth, sz_Day ) ;
	
	
	sprintf(sz_Amt,"%f", d_Montant);
	
	strcpy( sz_Dblcod, "" );      //[057] Initialisation
	strcpy(sz_zero , "0");

	/******************************************************************/
	/* positionnement du tableau de pointeur avant ecriture en sortie */
	/******************************************************************/

	Gt[GT_SSD_CF] = pbd_InRec_Cur[PER_SSD_CF]  ;
	Gt[GT_ESB_CF] = pbd_InRec_Cur[PER_ACCESB_CF] ;
	Gt[GT_BALSHEY_NF] = sz_Acy ;
	Gt[GT_BALSHRMTH_NF] = sz_Mth ;
	Gt[GT_BALSHRDAY_NF] = sz_Day ;
	Gt[GT_CTR_NF] = CTR_NF ;
	Gt[GT_END_NT] = pbd_InRec_Cur[PER_END_NT]  ;
	Gt[GT_SEC_NF] = pbd_InRec_Cur[PER_SEC_NF];
	Gt[GT_UWY_NF] = pbd_InRec_Cur[PER_UWY_NF] ;
	Gt[GT_UW_NT]  = pbd_InRec_Cur[PER_UW_NT] ;
	Gt[GT_OCCYEA_NF] = pbd_InRec_Cur[PER_CTRACCYEA_NF] ;
	Gt[GT_ACY_NF] = sz_Acy ;
	Gt[GT_SCOSTRMTH_NF] = sz_Mth ;
	Gt[GT_SCOENDMTH_NF] = sz_Mth ;
	Gt[GT_CLM_NF] = sz_Vide ;
	Gt[GT_CUR_CF] =  pbd_InRec_Cur[PER_EGPCUR_CF] ;
	Gt[GT_CED_NF] = pbd_InRec_Cur[PER_CED_NF] ;
	Gt[GT_BRK_NF] = pbd_InRec_Cur[PER_PRD_NF] ;
	Gt[GT_PAY_NF] = pbd_InRec_Cur[PER_PAYTIME_NF] ;
	Gt[GT_KEY_NF] = pbd_InRec_Cur[PER_GANPAYORD_NT] ;
	Gt[GT_RETCTR_NF] =  sz_Vide ;
	Gt[GT_RETEND_NT] =  sz_Vide ;
	Gt[GT_RETSEC_NF] =  sz_Vide ;
	Gt[GT_RTY_NF] = sz_Vide ;
	Gt[GT_RETUW_NT] = sz_Vide ;
	Gt[GT_RETOCCYEA_NF] = sz_Vide ;
	Gt[GT_RETACY_NF] = sz_Vide ;
	Gt[GT_RETSCOSTRMTH_NF] = sz_Vide ;
	Gt[GT_RETSCOENDMTH_NF] = sz_Vide ;
	Gt[GT_RCL_NF] = sz_Vide ;
	Gt[GT_RETCUR_CF] = sz_Vide ;
	Gt[GT_RETAMT_M] = sz_zero ;
	Gt[GT_PLC_NT] = sz_Vide ;
	Gt[GT_RTO_NF] = sz_Vide ;
	Gt[GT_INT_NF] = sz_Vide ;
	Gt[GT_RETPAY_NF] = sz_Vide ;
	Gt[GT_RETKEY_CF] = sz_Vide ;
	Gt[GT_RETINTAMT_M] = sz_Vide ;
	Gt[GT_ESTCUR_CF] = sz_Vide;
        Gt[GT_ESTAMT_M] = sz_Vide;
        Gt[GT_NAT_CF] = sz_Vide;
        Gt[GT_ACMTRS_NT] = sz_Vide;
        Gt[GT_ESTCTR_NF] = sz_Vide;
        Gt[GT_ESTSEC_NF] = sz_Vide;
        Gt[GT_LOB_CF] = sz_Vide;
        Gt[GT_SCOEGP_M] = sz_Vide;
        Gt[GT_ESTCRB_CT] = sz_Vide;
        Gt[GT_LIFTRTTYP_CF] = sz_Vide;
        Gt[GT_ACCADMTYP_CT] = sz_Vide;
        Gt[GT_SECSTS_CT] = sz_Vide;
        Gt[GT_PRD_NF] = sz_Vide;
        Gt[GT_SEG_NF] = sz_Vide;
        Gt[GT_COMACC_B] = sz_Vide;
	Gt[GT_ADJCOD_CT] = sz_Vide;
        Gt[GT_ORICOD_CF] = sz_Vide;
        Gt[GT_DETTRS_CF] = sz_Vide;
        Gt[GT_ACCRET_B] = sz_Vide;
        Gt[GT_ESTUWY_NF] = sz_Vide;
        Gt[GT_LSTENDMTH_NF] = sz_Vide;
        Gt[GT_PROPER_N] = sz_Vide;
        Gt[GT_RTOCTY_CF] = sz_Vide;
        Gt[GT_GAAP_NF] = sz_Vide;
        Gt[GT_BRKSCOEGP_M] = sz_Vide;
        Gt[GT_UWGRP_CF] = sz_Vide;
        Gt[GT_PROPAGRES_B] = sz_Vide;
        Gt[GT_PostBpc_B] = sz_Vide;
        Gt[GT_SPIMOD_CT] = sz_Vide;
        Gt[GT_RETAUTGEN_B] = sz_Vide;
        Gt[GT_ACCTYP_NF] = NULL ;

	sprintf( sz_Amt, "%-.3f", d_Montant ) ;

        Gt[GT_RETAMT_M] = "0";
        Gt[GT_RETINTAMT_M] = "0";
        Gt[GT_TRNCOD_CF] = account;
        Gt[GT_DBLTRNCOD_CF] = sz_Dblcod;
        Gt[GT_AMT_M] = sz_Amt;

        if ( fabs(atof(sz_Amt)) > 0  )
        {
        	n_WriteCols( Kp_OutputFilGt, Gt, SEPARATEUR, 0 );
        }

	RETURN_VAL(OK);
}
