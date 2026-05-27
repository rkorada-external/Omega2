/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTC1017.c
revision                      : $Revision: 1.7 $
date de creation              : 05/08/1997
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :   CALCUL DES CHARGES
------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>

   27/08/1998	  M.HA-THUC	Evol n° 1 - Commission originale multiple
				Synchro supplementaire avec la perimetre

   04/09/1998     M.HA-THUC     Evol n° 2 - Retrait pour compte commun (RPCC)
				Synchro supplementaires avec 1 nouveau GT

    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
---------------
MODIFICATION   : [004]
Auteur         : D.GATIBELZA
Date           : 13/07/2010
Version        : 10.2
Description    : ESTDOM17226 V10 Bug Commission Estimates

[005]  10/10/2010   R. Cassis    :spot:17226 - Ajout condition type de commission différent de 2
[006]  15/05/201*   M. NAJI      :spot:61503 -  traitement  de la taxe de base TAXBAS_CF
[007]  27/09/2018   MZM          :spira:69878 - Estimation de courtage + Estimation de commission sur FAC ayant des primes de RPCC
[008]  19/11/2018   MZM          :spira:70727 - PROD : issue on Brokerage Estimate amount for NP contract with brokerage rate on RIP brokerage rate 
[009]  06/05/2019   MZM          :spira70727  - Affichage en double du REC de courtage à tort	
[010]  21/05/2019   MZM          :spira70815  - Actual taxes canceled by Estimates wrongly 			 
[011]  17/09/2019   RAF          :spira:78591 - Remvove Ktd_Amt[Courtage_REC] in calcule Ktd_Comp[Courtage_PRM]
[012]  19/09/2019	MiS	 :spira:77463 - Calculation Minimum Variable Commission Estimates and Rest of Variable Commission Estimates
[013]  23/09/2019   R. Cassis    :spira:65656 - prs_cf is added as parameter for IFRS4 (710) or EBS (730)
[014]  23/09/2019	MiS	 :spira:77462 - split DAC Commission into DAC Fixed Commission and DAC Variable Commission
[015]  25/02/2020	MiS	 :REQ.P.09.6  - DAC IFRS17
[016]  21/09/2020       MiS      :spira 89186 - DAC definition alignment
[017]  03/02/2021   MZM          :spira 78325 - REinstatement Brokerage ACMTRS 10400 10401
[018]  05/03/2021	MiS	 :spira 90073 - DAC IFRS17- Take into account IFRS AE in DAC IFRS 17 calculation
[019]  01/04/2021	MiS	 :spira 86214 - compute Recieved Minimum Variable Commision
[020]  01/09/2021   MiS  :spira 97793 - Correction multicurrency
==============================================================================*/

/* 
#define TRACE_1
#define TRACE_2  */

#define DACBRKAE 	1
#define DACAE 		2
#define RECMIN		3
#define OTHER		0

#define Kn_MaxLigFBOTRSLNK      40000

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "struct.h"
#include <estserv.h>

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/
#include "ESTC1017.h"

/*----------------------------------------*/
/* inclusion de version dans les binaires */
/*----------------------------------------*/
static char VERSION_ESTC1017_C[150] = "__version__: ESTC1017.c version [018] 05/03/2021  DAC IFRS17- Take into account IFRS AE in DAC IFRS 17 calculation" ;

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/
FILE *Kp_OutputFilPrmLoa ;          /* pointeur sur le fichier de sortie Montants primes et charges */
FILE *Kp_FBOTRSLNK ;                /* pointeur sur le fichier FBOPRSLNK */
FILE *Kp_InputFilCurquot ;          /* pointeur sur le fichier FCURQUOT */

T_RUPTURE_VAR  	   	bd_RuptFt ;     /* variable de gestion de la rupture sur le GT */
T_RUPTURE_SYNC_VAR 	bd_RuptLoaRat ; /* variable de gestion de la synchronisation avec le fichier des taux de charges */
T_RUPTURE_SYNC_VAR 	bd_RuptGtLoa ;  /* variable de gestion de la synchronisation avec le GT des charges */
T_RUPTURE_SYNC_VAR 	bd_RuptGtFac ;  /* variable de gestion de la synchronisation avec le GT des primes estimees FAC et RPCC */
T_RUPTURE_SYNC_VAR 	bd_RuptPer ;    /* variable de gestion de la synchronisation avec le perimetre */
T_RUPTURE_SYNC_VAR 	bd_RuptGtRec ;  /* variable de gestion de la synchronisation avec le GT des REC */   /*** orhan ****/
T_RUPTURE_SYNC_VAR      bd_RuptAE ;     /* variable de gestion de la synchronisation avec le GT des AE [018] */
T_RUPTURE_SYNC_VAR	bd_RuptCumGta ; /*variable de gestion de la synchronisation avec le DLCUMGTAAR*/

int                     Kn_FBOTRSLNK ;
T_FBOTRSLNK             Ktbd_FBOTRSLNK[Kn_MaxLigFBOTRSLNK] ;


/*************/
double  Kd_Prme ;       /* montant de prime estimee                 */
double  Kd_Prmc ;       /* montant de prime cedante                 */
double	Kd_Ppnaea ;     /* montant de PPNA estimee                  */
double	Kd_Ppnac ;      /* montant de PPNA cedante                  */
double  Kd_Rppea ;      /* montant de RPP estime                    */
double  Kd_Rppc ;       /* montant de RPP cedante                   */
double  Kd_Lppnac ;     /* montant de liberation de PPNA cedante    */
double  Kd_Eppea ;      /* montant d' EPP estime                    */
double  Kd_Eppc ;       /* montant d' EPP cedante                   */
double  Kd_Rece ;       /* montant de reconstitution estime         */
double  Kd_Recc ;       /* montant de reconstitution cedante        */
double  Kd_Bce ;        /* montant de burning cost estime           */
double  Kd_Bcc ;        /* montant de burning cost cedante          */
double  Kd_Rpccc ;      /* montant de RPCC cedante                  */
double  Kd_Rpcce ;      /* montant de RPCC estime                   */

//[018]
double	Kd_DACAE ;
double	Kd_DACBRKAE ;

//[015]
double	Kd_PNAIFRS17 ;	/* Montant UPR IFRS17 */
double	Kd_DACIFRS17 ;
double  Kd_ITD ;
int 	Kd_PNAI17Method ; /* methode calcul PNAFAC */
double	Kd_EGPI ;

double  Kd_PrmAlim ;    /* [004] montant total de primes liées à l'aliment      */
double  Kd_PrmTot ;     /* montant total de primes                  */
double  Kd_EppTot ;     /* montant total d' EPP                     */
double  Kd_RppTot ;     /* montant total de RPP                     */
double  Kd_PpnaTot ;    /* montant total de PPNA                    */

// [012] Commissions Estimates
double	Kd_MinVarCE ;	/* Minimum Variable Commission Estimates */
double	Kd_ResVarCE ;	/* Rest of Variable Commission Estimates */
double	Kd_Tmin ;	/* Minimum Commission Rate */

//[019]
double Kd_RecievedMinVarCom;
double Kd_ITDRecVar;

// [014] Variable pour les Calculs de DAC
double Kd_DACfix ;	/* Dac Fixed */
double Kd_DACvar ;	/* DAC Variable */
double Kd_PrfCom ;	/* Profit Commission Rate */

double  Kd_ComRat ;     /* taux de commissionnement                 */
double  Kd_SurComRat ;  /* taux de surcommissionnement              */
// [006] double  Kd_Tax ;        /* taxes                                    */
double  Kd_TaxWP ;        // taxes  avec  prtefeuille  [006]                                  
double  Kd_TaxWO ;       // taxes  sans portefeuille  [006]                                */
double  Kd_BrkRat ;     /* taux de courtage                         */

double  Ktd_Amt[AMT_NBPOSTE] ;      /* tableau des montants provenant du GT par affaire */
double  Ktd_Comp[COMP_NBPOSTE] ;    /* tableau des complements de charges, taxes et courtage calcules par affaire */

short	Ks_ComTyp ;     /* type comptable                           */
char	Kc_CtrNat ;     /* nature du contrat                        */
char  Ksz_Prs[4];	    /* parametre de la chaine: type de poste '710'(IFRS4) ou '730'(EBS) [013] */

//[007]
char Ks_CtrNf[10] ;     /* Contrat */
char Ks_EgpCur[4] ;


int  Kn_Uwy ;           /* Annee Souscription */
int  Kn_SecNf ;         /* Section */

//[015]
char Ks_Secqua4Cf[2] ; /*Saisonnalité*/

int     Kn_PerPrmprtscl_B;
int     Kn_PerRecBrk_B;	/* indic d'existance sur REC                */
double  Kd_RecBrkRat ;	/* taux de courtage sur reconstitution      */

int n_InitFt                ( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_IsR1Ft                ( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_ActionFirstRuptFt     ( char **pbd_InRec_Cur ) ;
int n_ActionLigneFt		    ( char **pbd_InRec_Cur ) ;
int n_ActionLastRuptFt      ( char **pbd_InRec_Cur ) ;

int n_InitLoaRat            ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneLoaRat     ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncLoaRat   ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;

int n_InitGtLoa             ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneGtLoa      ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncGtLoa    ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;

int n_InitPer               ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLignePer        ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncPer      ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;

int n_InitGtFac             ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneGtFac      ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncGtFac    ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;

//[018]
int n_InitAE                ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneAE         ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncAE       ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;

//[019]
int n_InitCumGta            ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneCumGta     ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncCumGta   ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;

int n_ChargerFBOTRSLNK          ();
int n_check_trncd_cf            ( char *sz_TrnCd );

/*** orhan ****/
int n_InitGtRec             ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneGtRec      ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncGtRec    ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;

/**************/
int n_ProcessingRuptureSyncVar ( T_RUPTURE_SYNC_VAR  *pbd_Rupt, char **ptb_InRecOwner );

int n_InitVariables( void ) ;
int n_CalculComplementEPP( void ) ;
int n_CalculComplementRPP( void ) ;
int n_CalculComplementPrimes( void ) ;
int n_CalculComplementPPNA( void ) ;

char Ksz_Clodat[9] ; // [015]
char Ksz_Expdat[9] ; // [015]

char Ksz_Norme[5] ; //[018]

/*==============================================================================
objet : point d'entree du programme
retour: En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc  , char *argv[])
{
    /* Initialisation des signaux */
    InitSig () ;

	printf("Running with %s  \n", VERSION_ESTC1017_C);        

    if ( n_BeginPgm ( argc, argv ) == ERR )
        ExitPgm( ERR_XX , "" ) ;

  /* recuperation des parametres de la chaine */
  strcpy( Ksz_Prs, psz_GetCharArgv( 1 ) ) ;  // [011]
  printf("---> Ksz_Prs : %s\n",Ksz_Prs);

  /* recuperation de la Clodat */
  strcpy(Ksz_Clodat, psz_GetCharArgv( 2 ) ); // [015]
  printf("---> Ksz_Clodat : %s\n",Ksz_Clodat);

  /* recuperation de la Norme */
  strcpy(Ksz_Norme, psz_GetCharArgv( 3 ) ); // [015]
  printf("---> Ksz_Norme : %s\n",Ksz_Norme);

    /* ouverture du fichier de sortie des montants de primes et charges */
    if ( n_OpenFileAppl ( "ESTC1017_O1","wt",&Kp_OutputFilPrmLoa ) == ERR )
        ExitPgm( ERR_XX , "" ) ;

    /* Ouverture du fichier en entree FBOTRSLNK */
    if (n_OpenFileAppl("ESTC1017_I8", "rb", &Kp_FBOTRSLNK) == ERR )
        ExitPgm(ERR_XX ,"cannot open Kp_FBOTRSLNK ");

    /* ouverture du fichier en entree FCURQUOT */
    if ( n_OpenFileAppl ( "ESTC1017_I10","rb",&Kp_InputFilCurquot ) == ERR )
        ExitPgm( ERR_XX , "" ) ;

   /* Chargement du tableau TRSLNK*/
    Kn_FBOTRSLNK = n_ChargerFBOTRSLNK();
    if ( Kn_FBOTRSLNK == -1 )
        ExitPgm( ERR_XX , "Taille tableau FBOTRSLNK insuffisante " ) ;

    /* Initialisation de la variable bd_RuptFt*/
    if ( n_InitFt( &bd_RuptFt) )
        ExitPgm( ERR_XX , "" ) ;

    /* Initialisation de la variable bd_RuptLoaRat */
    if ( n_InitLoaRat( &bd_RuptLoaRat ) )
        ExitPgm( ERR_XX , "" ) ;

    /* Initialisation de la variable bd_RuptGtLoa */
    if ( n_InitGtLoa( &bd_RuptGtLoa ) )
        ExitPgm( ERR_XX , "" ) ;

    /* Initialisation de la variable bd_RuptGtFac */
    if ( n_InitGtFac( &bd_RuptGtFac ) )
        ExitPgm( ERR_XX , "" ) ;

    /* Initialisation de la variable bd_RuptPer */
    if ( n_InitPer( &bd_RuptPer ) )
        ExitPgm( ERR_XX , "" ) ;

    /*** orhan ***/
    /* Initialisation de la variable bd_RuptLoaRat */
    if ( n_InitGtRec( &bd_RuptGtRec ) )
        ExitPgm( ERR_XX , "" ) ;
    /**************/

    //[018]
    if ( n_InitAE( &bd_RuptAE ) )
	ExitPgm( ERR_XX , "" ) ;

    //[019]
    if ( n_InitCumGta( &bd_RuptCumGta ) )
        ExitPgm( ERR_XX , "" ) ;

    /* lancement du traitement du fichier de travail */
    if ( n_ProcessingRuptureVar( &bd_RuptFt) == ERR )
        ExitPgm( ERR_XX , "" ) ;

    if ( n_CloseFileAppl( "ESTC1017_I1", &( bd_RuptFt.pf_InputFil ) ) == ERR )
        ExitPgm( ERR_XX , "" ) ;

    if ( n_CloseFileAppl( "ESTC1017_I2", &( bd_RuptLoaRat.pf_InputFil ) ) == ERR )
        ExitPgm( ERR_XX , "" ) ;

    if ( n_CloseFileAppl( "ESTC1017_I3", &( bd_RuptGtLoa.pf_InputFil ) ) == ERR )
        ExitPgm( ERR_XX , "" ) ;

    if ( n_CloseFileAppl( "ESTC1017_I4", &( bd_RuptPer.pf_InputFil ) ) == ERR )
        ExitPgm( ERR_XX , "" ) ;

    if ( n_CloseFileAppl( "ESTC1017_I5", &( bd_RuptGtFac.pf_InputFil ) ) == ERR )
        ExitPgm( ERR_XX , "" ) ;

    /**** orhan ****/
    if ( n_CloseFileAppl( "ESTC1017_I6", &( bd_RuptGtRec.pf_InputFil ) ) == ERR )
        ExitPgm( ERR_XX , "" ) ;
    /***************/

    if ( n_CloseFileAppl( "ESTC1017_I7", &( bd_RuptAE.pf_InputFil ) ) == ERR )
        ExitPgm( ERR_XX , "" ) ;
   
    //|018]
    if ( n_CloseFileAppl( "ESTC1017_I8", &Kp_FBOTRSLNK ) == ERR )
        ExitPgm( ERR_XX , "" );

    if ( n_CloseFileAppl( "ESTC1017_I9", &( bd_RuptCumGta.pf_InputFil ) ) == ERR )
        ExitPgm( ERR_XX , "" ) ;

    if ( n_CloseFileAppl( "ESTC1017_I10", &Kp_InputFilCurquot ) == ERR )
        ExitPgm( ERR_XX , "" );

    if ( n_CloseFileAppl( "ESTC1017_O1", &Kp_OutputFilPrmLoa ) == ERR )
        ExitPgm( ERR_XX , "" );

    if ( n_EndPgm() == ERR )
        ExitPgm( ERR_XX , "" );

  exit(OK) ;
}


/*==============================================================================
objet : fonction d'initialisation de la variable de gestion de rupture du fichier maitre.
retour: 0K
==============================================================================*/
int n_InitFt(T_RUPTURE_VAR  *pbd_Rupt)
{
    DEBUT_FCT( "n_InitFt" ) ;

    memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

    /* ouverture du fichier maitre Fichier de travail */
    if ( n_OpenFileAppl( "ESTC1017_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
        return ERR ;

    pbd_Rupt->n_NbRupture = 1 ;                         /* nombre de rupture a gerer */
    pbd_Rupt->n_ConditionRupture[0] = n_IsR1Ft ;        /* fonction du test de rupture de niveau 1 */
    pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptFt ;  /* fonction lancee en rupture premiere */
    pbd_Rupt->n_ActionLigne = n_ActionLigneFt ;         /* fonction d'action sur la ligne courante */
    pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptFt ;    /* Fonction lancee en rupture derniere */

    pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet : fonction de test de rupture de niveau 1
retour :    0	---> pas de rupture
        sinon   ---> rupture
==============================================================================*/
/* adresse de la ligne en avance, adresse de la ligne courante */
int n_IsR1Ft( char **pbd_InRec,	char **pbd_InRec_Cur  ) 
{
  int ret;

    DEBUT_FCT( "n_IsR1Ft" ) ;

    if ( ( ret = strcmp( pbd_InRec[FT_CTR_NF], pbd_InRec_Cur[FT_CTR_NF] ) ) != 0 ) return ret ;
    if ( ( ret = strcmp( pbd_InRec[FT_END_NT], pbd_InRec_Cur[FT_END_NT] ) ) != 0 ) return ret ;
    if ( ( ret = strcmp( pbd_InRec[FT_SEC_NF], pbd_InRec_Cur[FT_SEC_NF] ) ) != 0 ) return ret ;
    if ( ( ret = strcmp( pbd_InRec[FT_UWYDIS_NF], pbd_InRec_Cur[FT_UWYDIS_NF] ) ) != 0 ) return ret ;
    if ( ( ret = strcmp( pbd_InRec[FT_UW_NT], pbd_InRec_Cur[FT_UW_NT] ) ) != 0 ) return ret ;

  RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet : fonction lancee en rupture premiere
retour :    OK ---> traitement correctement effectue
		    ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRuptFt( char **pbd_InRec_Cur  )
{
    DEBUT_FCT( "n_ActionFirstRuptFt" ) ;

    /* initialisation des variables de travail */
    n_InitVariables( ) ;

  RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet : fonction lancee pour chaque ligne
retour :    OK ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneFt( char **pbd_InRec_Cur )
{
    DEBUT_FCT( "n_ActionLigneFt" ) ;
    if (strcmp( pbd_InRec_Cur[FT_WFCOD_NT], "99999" ) != 0)
    { 
      /* cumuls des montants de prime, EPP, PPNA, RPP, reconstitution et burning cost */
      Kd_Ppnaea += atof( pbd_InRec_Cur[FT_PPNAEA_M] ) ;
      Kd_Ppnac += atof( pbd_InRec_Cur[FT_PPNAC_M] ) ;
      Kd_Rppea += atof( pbd_InRec_Cur[FT_RPPEA_M] ) ;
      Kd_Rppc += atof( pbd_InRec_Cur[FT_RPPC_M] ) ;
      Kd_Lppnac += atof( pbd_InRec_Cur[FT_LPPNAC_M] ) ;
      Kd_Eppea += atof( pbd_InRec_Cur[FT_EPPEA_M] ) ;
      Kd_Eppc += atof( pbd_InRec_Cur[FT_EPPC_M] ) ;
      Kd_Rece += atof( pbd_InRec_Cur[FT_RECE_M] ) ;
      Kd_Recc += atof( pbd_InRec_Cur[FT_RECC_M] ) ;
      Kd_Bce += atof( pbd_InRec_Cur[FT_BCE_M] ) ;
      Kd_Bcc += atof( pbd_InRec_Cur[FT_BCC_M] ) ;
      Kd_ITD += atof( pbd_InRec_Cur[FT_PRM_M] ) ;

	if ( strcmp( pbd_InRec_Cur[FT_WFCOD_NT], "10000" ) == 0 &&  *pbd_InRec_Cur[FT_WFTYP_CF] == 'E' )
        Kd_Prme = atof( pbd_InRec_Cur[FT_PRM_M] ) ;
	if ( strcmp( pbd_InRec_Cur[FT_WFCOD_NT], "10000" ) == 0 &&  *pbd_InRec_Cur[FT_WFTYP_CF] == 'C' )
        Kd_Prmc = atof( pbd_InRec_Cur[FT_PRM_M] ) ;
    }
    else
    {
 	Kd_PNAIFRS17 += atof( pbd_InRec_Cur[FT_PPNAC_M] ) ;    
	Kd_PNAI17Method = atoi ( pbd_InRec_Cur[FT_ACCADMTYP_CT] ) ;
    }
  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet : fonction lancee en rupture derniere
retour :    OK ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptFt(	char **pbd_InRec_Cur  )
{
  char *PrmLoa[NB_COL_PRMLOA + 1] ; /* tableau de pointeur a l'image du fichier des montants de primes et charges */
  char sz_Prm[30] ;     /* variable intermediaire */
  char sz_CmpPrm[30] ;  /* variable intermediaire */
  char sz_ProPrm[30] ;  /* variable intermediaire */

    DEBUT_FCT( "n_ActionLastRuptFt" ) ;

/*
#ifdef TRACE_1
printf("!!!! CTR_NF[%s][%s]\n", pbd_InRec_Cur[FT_CTR_NF], pbd_InRec_Cur[FT_UWY_NF]);
#endif
*/

    /*******************************************************/
    /* synchronisation avec le fichier des taux de charges */
    /*******************************************************/
    n_ProcessingRuptureSyncVar( &bd_RuptLoaRat, pbd_InRec_Cur ) ;

    /************************************************/
    /* synchronisation avec le fichier du Perimetre */
    /************************************************/
    n_ProcessingRuptureSyncVar( &bd_RuptPer, pbd_InRec_Cur ) ;

    /*****************************************/
    /* synchronisation avec le fichier du GT */
    /*****************************************/
    n_ProcessingRuptureSyncVar( &bd_RuptGtLoa, pbd_InRec_Cur ) ;

    /***************************************************/
    /* Evol n° 2 - Synchro avec le fichier DLGTAFACPRE */
    /***************************************************/
    n_ProcessingRuptureSyncVar( &bd_RuptGtFac, pbd_InRec_Cur ) ;

    /***************************************************/
    /*  Synchro avec le fichier DSUMGTAAREC (prise en compte du */
    /*  courtage sur prime REC                         */
    /***************************************************/
    n_ProcessingRuptureSyncVar( &bd_RuptGtRec, pbd_InRec_Cur ) ;

    /*****************************************/
    /* synchronisation avec le fichier AE */
    /*****************************************/
    n_ProcessingRuptureSyncVar( &bd_RuptAE, pbd_InRec_Cur ) ;

    /*****************************************/
    /* synchronisation avec le fichier DLCUMGTAAR */
    /*****************************************/
    n_ProcessingRuptureSyncVar( &bd_RuptCumGta, pbd_InRec_Cur ) ;

    /***********************************************/
    /* calcul des Primes, EPP, RPP et PPNA totales */
    /***********************************************/
    Kd_PrmTot = Kd_Prme + Kd_Prmc + ( Kd_Rece + Kd_Recc ) + ( Kd_Bce + Kd_Bcc ) ;
    Kd_PrmAlim = Kd_Prme + Kd_Prmc ;                                                    //[004]
    Kd_RppTot = Kd_Rppc + Kd_Rppea ;
    Kd_PpnaTot = Kd_Ppnaea + Kd_Ppnac + Kd_Lppnac ;

    if ( Kn_PerPrmprtscl_B == 0 )
        Kd_EppTot = Kd_Eppea + Kd_Eppc ;
    else
        Kd_EppTot = Kd_Eppea ;

    /******************************************************/
    /* calcul des complements de charges, taxes, courtage */
    /******************************************************/
    n_CalculComplementEPP( ) ;
    n_CalculComplementRPP( ) ;
    n_CalculComplementPrimes( ) ;
    n_CalculComplementPPNA( ) ;

    /************************************************************************/
    /* ecriture en sortie dans le fichier des montants de primes et charges */
    /************************************************************************/
    PrmLoa[PRMLOA_CTR_NF] = pbd_InRec_Cur[FT_CTR_NF] ;
    PrmLoa[PRMLOA_END_NT] = pbd_InRec_Cur[FT_END_NT] ;
    PrmLoa[PRMLOA_SEC_NF] = pbd_InRec_Cur[FT_SEC_NF] ;
    PrmLoa[PRMLOA_UWY_NF] = pbd_InRec_Cur[FT_UWYDIS_NF] ;
    PrmLoa[PRMLOA_UW_NT] = pbd_InRec_Cur[FT_UW_NT] ;
    PrmLoa[PRMLOA_PRS_CF] = Ksz_Prs ;  // [011] "710" ;
    PrmLoa[PRMLOA_SSD_CF] = pbd_InRec_Cur[FT_SSD_CF] ;
    PrmLoa[PRMLOA_CUR_CF] = pbd_InRec_Cur[FT_EGPCUR_CF] ;
    PrmLoa[PRMLOA_RECACC_M] = sz_Prm ;
    PrmLoa[PRMLOA_ESTACC_M] = sz_CmpPrm ;
    PrmLoa[PRMLOA_RESERV_M] = sz_ProPrm ;
    PrmLoa[PRMLOA_RESERV_M + 1] = NULL ;

    /* entree de portefeuille prime - poste cumul = 10020 */
    PrmLoa[PRMLOA_ACMTRS_NT] = "10020" ;
    sprintf( sz_Prm, "%-.3f", Kd_Eppc ) ;
    sprintf( sz_CmpPrm, "%-.3f", Kd_Eppea ) ;
    sprintf( sz_ProPrm, "%-.3f", ( Kd_Rppc + Kd_Rppea ) ) ;
    n_WriteCols( Kp_OutputFilPrmLoa, PrmLoa, SEPARATEUR, 0 ) ;

    /* primes et primes provisionnelles - poste cumul = 10000 */
    PrmLoa[PRMLOA_ACMTRS_NT] = "10000" ;
    sprintf( sz_Prm, "%-.3f", ( Kd_Prmc + Kd_Recc + Kd_Bcc ) ) ;
    sprintf( sz_CmpPrm, "%-.3f", ( Kd_Prme + Kd_Rece + Kd_Bce ) ) ;
    sprintf( sz_ProPrm, "%-.3f", ( Kd_Ppnac + Kd_Ppnaea + Kd_Lppnac ) ) ;
    n_WriteCols( Kp_OutputFilPrmLoa, PrmLoa, SEPARATEUR, 0 ) ;

    /* charges reçues sur EPP - poste cumul = 10120 */
    PrmLoa[PRMLOA_ACMTRS_NT] = "10120" ;
    sprintf( sz_Prm, "%-.3f", Ktd_Amt[Charge_EPP] ) ;
    sprintf( sz_CmpPrm, "%-.3f", Ktd_Comp[Charge_EPP] ) ;
    sprintf( sz_ProPrm, "%-.3f", Ktd_Comp[Charge_RPP] ) ;
    n_WriteCols( Kp_OutputFilPrmLoa, PrmLoa, SEPARATEUR, 0 ) ;

    /* taxes reçues sur EPP - poste cumul = 10320 */
    PrmLoa[PRMLOA_ACMTRS_NT] = "10320" ;
    sprintf( sz_Prm, "%-.3f", Ktd_Amt[Taxe_EPP] ) ;
    sprintf( sz_CmpPrm, "%-.3f", Ktd_Comp[Taxe_EPP] ) ;
    sprintf( sz_ProPrm, "%-.3f", Ktd_Comp[Taxe_RPP] ) ;
    n_WriteCols( Kp_OutputFilPrmLoa, PrmLoa, SEPARATEUR, 0 ) ;

    /* courtage reçue sur EPP - poste cumul = 10420 */
    PrmLoa[PRMLOA_ACMTRS_NT] = "10420" ;
    sprintf( sz_Prm, "%-.3f", Ktd_Amt[Courtage_EPP] ) ;
    sprintf( sz_CmpPrm, "%-.3f", Ktd_Comp[Courtage_EPP] ) ;
    sprintf( sz_ProPrm, "%-.3f", Ktd_Comp[Courtage_RPP] ) ;
    n_WriteCols( Kp_OutputFilPrmLoa, PrmLoa, SEPARATEUR, 0 ) ;

    /* charges reçues sur prime - poste cumul = 10100 */
    if ((Ks_ComTyp == 1) || (Ks_ComTyp == 3) || (Ks_ComTyp == 4) || (Ks_ComTyp == 5))
    {
    PrmLoa[PRMLOA_ACMTRS_NT] = "10100" ;
    sprintf( sz_Prm, "%-.3f", ( Ktd_Amt[ChargeCom_PRM] + Ktd_Amt[ChargeSurCom_PRM] ) ) ;
    sprintf( sz_CmpPrm, "%-.3f", ( Ktd_Comp[ChargeCom_PRM] + Ktd_Comp[ChargeSurCom_PRM] ) ) ;
    sprintf( sz_ProPrm, "%-.3f", Kd_DACfix + Kd_DACvar );//Ktd_Comp[ChargeTaxe_PPNA]) ; DAC1 Ancien
    n_WriteCols( Kp_OutputFilPrmLoa, PrmLoa, SEPARATEUR, 0 ) ;
    }
    else
    {
    PrmLoa[PRMLOA_ACMTRS_NT] = "10100" ;
    sprintf( sz_Prm, "%-.3f", Ktd_Amt[ChargeCom_PRM] + Ktd_Amt[ChargeSurCom_PRM] ) ;
    sprintf( sz_CmpPrm, "%-.3f", Kd_MinVarCE + Kd_ResVarCE ) ;
    sprintf( sz_ProPrm, "%-.3f", Kd_DACfix + Kd_DACvar );// Ktd_Comp[ChargeTaxe_PPNA]) ; // DAC1 Ancien
    n_WriteCols( Kp_OutputFilPrmLoa, PrmLoa, SEPARATEUR, 0 ) ;
    }

    /* taxes reçues sur prime - poste cumul = 10300 */
    PrmLoa[PRMLOA_ACMTRS_NT] = "10300" ;
    sprintf( sz_Prm, "%-.3f", Ktd_Amt[Taxe_PRM] ) ;
    sprintf( sz_CmpPrm, "%-.3f", Ktd_Comp[Taxe_PRM] ) ;
    sprintf( sz_ProPrm, "%-.3f", Kd_RecievedMinVarCom) ; // Recieved Minimum Variable Commissions Charge
    n_WriteCols( Kp_OutputFilPrmLoa, PrmLoa, SEPARATEUR, 0 ) ;

    /* courtage reçues sur prime - poste cumul = 10400 */
    PrmLoa[PRMLOA_ACMTRS_NT] = "10400" ;
    sprintf( sz_Prm, "%-.3f", Ktd_Amt[Courtage_PRM] ) ;
    //[009]sprintf( sz_CmpPrm, "%-.3f", Ktd_Comp[Courtage_PRM] + Ktd_Comp[Courtage_REC] );  
    sprintf( sz_CmpPrm, "%-.3f", Ktd_Comp[Courtage_PRM] );       
    //printf(" DEBUG Ks_CtrNf %s :%-.3f, %-.3f",Ks_CtrNf, Ktd_Comp[Courtage_PRM], Ktd_Comp[Courtage_REC] );
    sprintf( sz_ProPrm, "%-.3f", Ktd_Comp[Courtage_PPNA] ) ;
    n_WriteCols( Kp_OutputFilPrmLoa, PrmLoa, SEPARATEUR, 0 ) ;

    /**************************************************************/
    /*Minimum Variable Commission Estimate, Rest of Variable [012]*/
    /*              DAC Fixed, DAC Variable [014]                 */
    /**************************************************************/

    if ((Ks_ComTyp == 1) || (Ks_ComTyp == 3) || (Ks_ComTyp == 4) || (Ks_ComTyp == 5))
    {
        PrmLoa[PRMLOA_ACMTRS_NT] = "12021";
        sprintf( sz_Prm, "%-.3f", 0.000 ) ;
        sprintf( sz_CmpPrm, "%-.3f", 0.000 ) ;
        sprintf( sz_ProPrm, "%-.3f", Kd_DACfix ) ; //[014]
        n_WriteCols( Kp_OutputFilPrmLoa, PrmLoa, SEPARATEUR, 0 ) ;

        PrmLoa[PRMLOA_ACMTRS_NT] = "12030";
        sprintf( sz_Prm, "%-.3f", 0.000 ) ;
        sprintf( sz_CmpPrm, "%-.3f", 0.000 ) ;
        sprintf( sz_ProPrm, "%-.3f", Kd_DACvar ) ; //[014]
        n_WriteCols( Kp_OutputFilPrmLoa, PrmLoa, SEPARATEUR, 0 ) ;  
    }
    if (Ks_ComTyp == 2) 
    {
        PrmLoa[PRMLOA_ACMTRS_NT] = "12021";
        sprintf( sz_Prm, "%-.3f", (Ktd_Amt[ChargeCom_PRM] + Ktd_Amt[ChargeSurCom_PRM]) ) ;
        sprintf( sz_CmpPrm, "%-.3f", (Kd_MinVarCE + Ktd_Comp[ChargeSurCom_PRM]) );
        sprintf( sz_ProPrm, "%-.3f", Kd_DACfix ) ; //[014]
        n_WriteCols( Kp_OutputFilPrmLoa, PrmLoa, SEPARATEUR, 0 ) ;
     
        PrmLoa[PRMLOA_ACMTRS_NT] = "12030";
        sprintf( sz_Prm, "%-.3f", 0.000 ) ;
        sprintf( sz_CmpPrm, "%-.3f", Kd_ResVarCE ) ;
        sprintf( sz_ProPrm, "%-.3f", Kd_DACvar ) ; //[014]
        n_WriteCols( Kp_OutputFilPrmLoa, PrmLoa, SEPARATEUR, 0 ) ;
    }
    
    /*Ecriture DAC REQ9.4*/
   /* 
    PrmLoa[PRMLOA_ACMTRS_NT] = "43000";
    sprintf( sz_Prm, "%-.3f", 0.000 ) ;
    sprintf( sz_CmpPrm, "%-.3f", 0.000 );
    sprintf( sz_ProPrm, "%-.3f", Kd_DACfix ) ; //[014]
    n_WriteCols( Kp_OutputFilPrmLoa, PrmLoa, SEPARATEUR, 0 ) ;

    PrmLoa[PRMLOA_ACMTRS_NT] = "43010";
    sprintf( sz_Prm, "%-.3f", 0.000 ) ;
    sprintf( sz_CmpPrm, "%-.3f", 0.000 ) ;
    sprintf( sz_ProPrm, "%-.3f", Kd_DACvar ) ; //[014]
    n_WriteCols( Kp_OutputFilPrmLoa, PrmLoa, SEPARATEUR, 0 ) ;
*/

    if (Kn_PerRecBrk_B==1)
    {
        /* courtage reçues sur REC  - poste cumul = 10401 */
        PrmLoa[PRMLOA_ACMTRS_NT] = "10401" ;

        sprintf( sz_Prm, "%-.3f", Ktd_Amt[Courtage_REC]  ) ;        
        
        //[009]sprintf( sz_CmpPrm, "%-.3f", Ktd_Comp[Courtage_REC] ) ;
        sprintf( sz_CmpPrm, "%-.3f", Ktd_Comp[Courtage_PRM] + Ktd_Comp[Courtage_REC] ); 
        
        sprintf( sz_ProPrm, "%-.3f", Kd_DACIFRS17);

#ifdef TRACE_1      
      if (strcmp(Ks_CtrNf, "11T003051") ==0  &&   Kn_Uwy == 2013 && Kn_SecNf == 1 ) 
      { 
       printf(" DEBUG 007 Kn_PerRecBrk_B, Ks_CtrNf, Ktd_Amt[Courtage_REC], Ktd_Comp[Courtage_REC], sz_CmpPrm : %d; %s ; %-.3f ; %-.3f ; %s \n",Kn_PerRecBrk_B, Ks_CtrNf, Ktd_Amt[Courtage_REC], Ktd_Comp[Courtage_REC], sz_CmpPrm );        
       printf(" DEBUG 007 Kn_PerRecBrk_B, Ks_CtrNf, Ktd_Amt[Courtage_PRM], Ktd_Comp[Courtage_PRM], sz_CmpPrm : %d; %s ; %-.3f ; %-.3f ; %s \n",Kn_PerRecBrk_B, Ks_CtrNf, Ktd_Amt[Courtage_PRM], Ktd_Comp[Courtage_PRM], sz_CmpPrm );  
      }
#endif        
        n_WriteCols( Kp_OutputFilPrmLoa, PrmLoa, SEPARATEUR, 0 ) ;
    }
    else
    {
        /* courtage reâ–’ues sur REC  - poste cumul = 10401 */
        PrmLoa[PRMLOA_ACMTRS_NT] = "10401" ;
        sprintf( sz_Prm, "%-.3f", 0.000  ) ;
        sprintf( sz_CmpPrm, "%-.3f", 0.000 );
        sprintf( sz_ProPrm, "%-.3f", Kd_DACIFRS17);
        n_WriteCols( Kp_OutputFilPrmLoa, PrmLoa, SEPARATEUR, 0 ) ;
    }
  RETURN_VAL ( OK ) ;
}



/*==============================================================================
objet : Initialisation de la synchronisation du maitre « FT »
    	avec l’esclave « Taux de charges »
retour :OK
==============================================================================*/
int n_InitLoaRat( T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitLoaRat" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave des Taux de charges */
	if ( n_OpenFileAppl( "ESTC1017_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncLoaRat ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneLoaRat ;

	pbd_Rupt->c_Separ = '~' ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet : fonction de test de synchronisation
retour :
	0	---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
	> 0   	---> pbd_InRecOwne> > pbd_InRecChild
	< 0   	---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncLoaRat(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncLoaRat" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[FT_CTR_NF], pbd_InRecChild[LOA_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[FT_END_NT], pbd_InRecChild[LOA_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[FT_SEC_NF], pbd_InRecChild[LOA_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[FT_UWYDIS_NF], pbd_InRecChild[LOA_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[FT_UW_NT], pbd_InRecChild[LOA_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneLoaRat(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneLoaRat" ) ;

	/* positionnement des taux de commissionnement, surcommissionnement, taxes et courtage */
	Kd_ComRat = -1 * atof( ptb_InRecChild[LOA_COMMIS_R] ) ;
	Kd_SurComRat = -1 * atof( ptb_InRecChild[LOA_OVECOM_R] ) ;
// [006]	Kd_Tax = -1 * atof( ptb_InRecChild[LOA_TAX_R] ) ;
	Kd_TaxWP = -1 * atof( ptb_InRecChild[LOA_TAX_R] ) ;   // [006]
	Kd_TaxWO = -1 * atof( ptb_InRecChild[LOA_TAXWO_R] ) ;  // [006]
	Kd_BrkRat = -1 * atof( ptb_InRecChild[LOA_BROKER_R] ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l'esclave « GT »

retour :
	OK
==============================================================================*/
int n_InitGtLoa(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitGtLoa" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave GT */
	if ( n_OpenFileAppl( "ESTC1017_I3", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncGtLoa ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneGtLoa ;

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
int n_ConditionSyncGtLoa(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncGtLoa" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[FT_CTR_NF], pbd_InRecChild[GTE_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[FT_END_NT], pbd_InRecChild[GTE_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[FT_SEC_NF], pbd_InRecChild[GTE_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[FT_UWYDIS_NF], pbd_InRecChild[GTE_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[FT_UW_NT], pbd_InRecChild[GTE_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGtLoa(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneGtLoa" ) ;

	/* affectation des montants du GT par affaire */
	switch( atol( ptb_InRecChild[GTE_ACMTRS_NT] ) )
    {
	    case 10120 :
	    	Ktd_Amt[Charge_EPP] = atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
	    	break ;
	    case 10320 :
	    	Ktd_Amt[Taxe_EPP] = atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
	    	break ;
	    case 10420 :
	    	Ktd_Amt[Courtage_EPP] = atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
	    	break ;
	    case 10100 :
	    	Ktd_Amt[ChargeCom_PRM] = atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
	    	break ;
	    /*********************************************/
	    /* Evol n° 1 - Commission originale multiple */
	    /*********************************************/
	    case 10200 :
	    	Ktd_Amt[ChargeSurCom_PRM] = atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
	    	break ;
	    case 10300 :
	    	Ktd_Amt[Taxe_PRM] = atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
	    	break ;
	    case 10400 :
	    	Ktd_Amt[Courtage_PRM] = atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
	    	break ;
	    case 10130 :
	    	Ktd_Amt[ChargeTaxe_PPNA] += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
	    	break ;
	    case 10430 :
	    	Ktd_Amt[Courtage_PPNA] += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
	    	break ;
	    case 10110 :
	    	Ktd_Amt[Charge_RPP] = atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
	    	break ;
	    case 10310 :
	    	Ktd_Amt[Taxe_RPP] = atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
	    	break ;
	    case 10410 :
	    	Ktd_Amt[Courtage_RPP] = atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
	    	break ;
	    case 10140 :
	    	Ktd_Amt[ChargeTaxe_PPNA] += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
	    	break ;
	    case 10440 :
	    	Ktd_Amt[Courtage_PPNA] += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
	    	break ;
	    /************************************************/
	    /* Evol n° 2 - Retrait pour compte commun   	*/
	    /* Le filtre du fichier en entree a ete modifie	*/
	    /* afin de recuperer la prime RPCC cedante en	*/
	    /* plus des charges.				*/
	    /************************************************/
	    case 19000 :
	            if (Kc_CtrNat == 'F')
	    	   Kd_Rpccc += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
	    	break ;
	}

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet : Initialisation de la synchronisation du maitre avec l'esclave « Perimetre »
retour :    OK
==============================================================================*/
int n_InitPer(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitPer" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave Perimetre */
	if ( n_OpenFileAppl( "ESTC1017_I4", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncPer ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLignePer ;

	pbd_Rupt->c_Separ = '~' ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet : fonction de test de synchronisation
retour :
	0	---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
	> 0   	---> pbd_InRecOwne> > pbd_InRecChild
	< 0   	---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncPer(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncPer" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[FT_CTR_NF], pbd_InRecChild[PER_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[FT_END_NT], pbd_InRecChild[PER_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[FT_SEC_NF], pbd_InRecChild[PER_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[FT_UWYDIS_NF], pbd_InRecChild[PER_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[FT_UW_NT], pbd_InRecChild[PER_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet : fonction lancee pour chaque ligne
retour :    OK ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePer(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
    DEBUT_FCT( "n_ActionLignePer" ) ;

    Ks_ComTyp = atoi( ptb_InRecChild[PER_COMTYP_CT] ) ;
    Kc_CtrNat =(char) (*ptb_InRecChild[PER_CTRNAT_CT]) ;
    
    Kn_Uwy = atoi( ptb_InRecChild[PER_UWY_NF] ) ;
    Kn_SecNf = atoi( ptb_InRecChild[PER_SEC_NF] ) ;    
    
    strcpy(Ks_CtrNf, ptb_InRecChild[PER_CTR_NF]);    
    strcpy(Ks_Secqua4Cf, ptb_InRecChild[PER_SECQUA4_CF]);
    strcpy(Ks_EgpCur,ptb_InRecChild[PER_EGPCUR_CF]); // [020]
	
    Kn_PerPrmprtscl_B = atoi(ptb_InRecChild[PER_PRMPRTSCL_B]);

    Kn_PerRecBrk_B = atoi(ptb_InRecChild[PER_RECBRK_B]);
    Kd_RecBrkRat = atof(ptb_InRecChild[PER_RECBRK_R]);
   
    //[012] 
    Kd_Tmin = atof(ptb_InRecChild[PER_MINCOM_R])*(-1);
    
    //[014]
    Kd_PrfCom = atof(ptb_InRecChild[PER_PRFCOM_R])*(-1);
    
    //[015]
    strcpy(Ksz_Expdat ,ptb_InRecChild[PER_EXP_D]);
    Kd_EGPI = atof(ptb_InRecChild[PER_SCOEGP_M]);
  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :	Initialisation de la synchronisation du maitre avec l'esclave « GT »
retour : OK
==============================================================================*/
int n_InitGtFac(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitGtFac" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave GT */
	if ( n_OpenFileAppl( "ESTC1017_I5", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncGtFac ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneGtFac ;
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
int n_ConditionSyncGtFac(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncGtFac" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[FT_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[FT_END_NT], pbd_InRecChild[GT_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[FT_SEC_NF], pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[FT_UWYDIS_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[FT_UW_NT], pbd_InRecChild[GT_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet : fonction lancee pour chaque ligne
retour :    OK ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGtFac(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneGtFac" ) ;

	/* Cumul du montant de RPCC estime */
	if ( strcmp( ptb_InRecChild[GT_TRNCOD_CF], "11107002" ) == 0 )
		Kd_Rpcce += atof( ptb_InRecChild[GT_AMT_M] ) ;

	RETURN_VAL( OK ) ;
}

/*==============================================================================
objet : Initialisation de la synchronisation du maitre avec l'esclave « GT »
retour :    OK
==============================================================================*/
int n_InitGtRec(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitGtRec" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave GT */
	if ( n_OpenFileAppl( "ESTC1017_I6", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncGtRec ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneGtRec ;
	pbd_Rupt->c_Separ = '~' ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet : fonction de test de synchronisation
retour :
	0	---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
	> 0   	---> pbd_InRecOwne> > pbd_InRecChild
	< 0   	---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncGtRec(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncGtRec" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[FT_CTR_NF], pbd_InRecChild[GTE_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[FT_END_NT], pbd_InRecChild[GTE_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[FT_SEC_NF], pbd_InRecChild[GTE_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[FT_UWYDIS_NF], pbd_InRecChild[GTE_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[FT_UW_NT], pbd_InRecChild[GTE_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet : fonction lancee pour chaque ligne
retour :    OK ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGtRec(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneGtRec" ) ;

	/* affectation des montants du GT pour REC */
	Ktd_Amt[Courtage_REC] = atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;

	RETURN_VAL( OK ) ;
}


//[018]
/*==============================================================================
objet : Initialisation de la synchronisation du maitre avec l'esclave â–’ GT â–’
retour :    OK
==============================================================================*/
int n_InitAE(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
        DEBUT_FCT( "n_InitAE" ) ;

        memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

        /* ouverture du fichier esclave GT */
        if ( n_OpenFileAppl( "ESTC1017_I7", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
                return ERR ;

        /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
        pbd_Rupt->ConditionEndSync = n_ConditionSyncAE ;

        /* fonction d'action sur la ligne courante */
        pbd_Rupt->n_ActionLigne = n_ActionLigneAE ;
        pbd_Rupt->c_Separ = '~' ;

        RETURN_VAL( OK ) ;
}


/*==============================================================================
objet : fonction de test de synchronisation
retour :
        0       ---> pbd_InRecOwner = pbd_InRecChild ( egalitâ–’ de rubrique a synchroniser)
        > 0     ---> pbd_InRecOwne> > pbd_InRecChild
        < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncAE(
        char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
        char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
        int ret ;

        DEBUT_FCT( "n_ConditionSyncAE" ) ;

        if ( ( ret = strcmp( pbd_InRecOwner[FT_CTR_NF], pbd_InRecChild[GTE_CTR_NF] ) ) != 0 ) return ret ;
        if ( ( ret = strcmp( pbd_InRecOwner[FT_END_NT], pbd_InRecChild[GTE_END_NT] ) ) != 0 ) return ret ;
        if ( ( ret = strcmp( pbd_InRecOwner[FT_SEC_NF], pbd_InRecChild[GTE_SEC_NF] ) ) != 0 ) return ret ;
        if ( ( ret = strcmp( pbd_InRecOwner[FT_UWYDIS_NF], pbd_InRecChild[GTE_UWY_NF] ) ) != 0 ) return ret ;
        if ( ( ret = strcmp( pbd_InRecOwner[FT_UW_NT], pbd_InRecChild[GTE_UW_NT] ) ) != 0 ) return ret ;

        RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet : fonction lancee pour chaque ligne
retour :    OK ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneAE(
        char **pdb_InRecOwner , /* adresse de la ligne du maitre */
        char **pdb_InRecChild ) /* adresse de la ligne de l'esclave */
{
        DEBUT_FCT( "n_ActionLigneAE" ) ;
	
	int n_type_trn_cd;
	double Ratio;

        n_type_trn_cd = n_check_trncd_cf(pdb_InRecChild[GTE_TRNCOD_CF]);

        Ratio = d_GetTaux(Kp_InputFilCurquot, (char) atoi(pdb_InRecChild[GTE_SSD_CF]), atoi(pdb_InRecChild[GTE_UWY_NF]), pdb_InRecChild[GTE_CUR_CF], Ks_EgpCur);

	if ( n_type_trn_cd == DACAE )
	{
		Kd_DACAE += Ratio * atof(pdb_InRecChild[GTE_AMT_M]) ;
	}
	if ( n_type_trn_cd == DACBRKAE )
        {
                Kd_DACBRKAE += Ratio * atof(pdb_InRecChild[GTE_AMT_M]) ;
        }

        RETURN_VAL( OK ) ;
}
//[018]

//[019]
/*==============================================================================
objet : Initialisation de la synchronisation du maitre avec l'esclave â–’~V~R GT â–’~V~R
retour :    OK
==============================================================================*/
int n_InitCumGta(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
        DEBUT_FCT( "n_InitCumGta" ) ;

        memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

        /* ouverture du fichier esclave GT */
        if ( n_OpenFileAppl( "ESTC1017_I9", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
                return ERR ;

        /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
        pbd_Rupt->ConditionEndSync = n_ConditionSyncCumGta ;

        /* fonction d'action sur la ligne courante */
        pbd_Rupt->n_ActionLigne = n_ActionLigneCumGta ;
        pbd_Rupt->c_Separ = '~' ;

        RETURN_VAL( OK ) ;
}


/*==============================================================================
objet : fonction de test de synchronisation
retour :
        0       ---> pbd_InRecOwner = pbd_InRecChild ( egalitâ–’~V~R de rubrique a synchroniser)
        > 0     ---> pbd_InRecOwne> > pbd_InRecChild
        < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncCumGta(
        char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
        char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
        int ret ;

        DEBUT_FCT( "n_ConditionSyncCumGta" ) ;

        if ( ( ret = strcmp( pbd_InRecOwner[FT_CTR_NF], pbd_InRecChild[GTE_CTR_NF] ) ) != 0 ) return ret ;
        if ( ( ret = strcmp( pbd_InRecOwner[FT_END_NT], pbd_InRecChild[GTE_END_NT] ) ) != 0 ) return ret ;
        if ( ( ret = strcmp( pbd_InRecOwner[FT_SEC_NF], pbd_InRecChild[GTE_SEC_NF] ) ) != 0 ) return ret ;
        if ( ( ret = strcmp( pbd_InRecOwner[FT_UWYDIS_NF], pbd_InRecChild[GTE_UWY_NF] ) ) != 0 ) return ret ;
        if ( ( ret = strcmp( pbd_InRecOwner[FT_UW_NT], pbd_InRecChild[GTE_UW_NT] ) ) != 0 ) return ret ;

        RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet : fonction lancee pour chaque ligne
retour :    OK ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneCumGta(
        char **pdb_InRecOwner , /* adresse de la ligne du maitre */
        char **pdb_InRecChild ) /* adresse de la ligne de l'esclave */
{
        DEBUT_FCT( "n_ActionLigneCumGta" ) ;

	int n_type_trn_cd;
	double Ratio;

        n_type_trn_cd = n_check_trncd_cf(pdb_InRecChild[GTE_TRNCOD_CF]);
	
        // [020]
	Ratio = d_GetTaux(Kp_InputFilCurquot, (char) atoi(pdb_InRecChild[GTE_SSD_CF]), atoi(pdb_InRecChild[GTE_UWY_NF]), pdb_InRecChild[GTE_CUR_CF], Ks_EgpCur);

        if ( n_type_trn_cd == RECMIN )
        {
                 Kd_ITDRecVar += Ratio * atof(pdb_InRecChild[GTE_AMT_M]) ;
        }

        RETURN_VAL( OK ) ;
}
//[019]


/*==============================================================================
objet : fonction d'initialisation des variables de travail
retour :    OK ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_InitVariables( void )
{

	DEBUT_FCT( "n_InitVariables" ) ;

	/* initialisation des montants du fichier de travail */
	Kd_Prme = 0 ;
	Kd_Prmc = 0 ;
	Kd_Ppnaea = 0 ;
	Kd_Ppnac = 0 ;
	Kd_Rppea = 0 ;
	Kd_Rppc = 0 ;
	Kd_Lppnac = 0 ;
	Kd_Eppea = 0 ;
	Kd_Eppc = 0 ;
	Kd_Rece = 0 ;
	Kd_Recc = 0 ;
	Kd_Bce = 0 ;
	Kd_Bcc = 0 ;
	Kd_Rpccc = 0 ;
	Kd_Rpcce = 0 ;
	
	/* initialisation des taux de charges */
	Kd_ComRat = 0 ;
	Kd_SurComRat = 0 ;
//[006]	Kd_Tax = 0 ;
	Kd_TaxWP = 0 ; // [006]
	Kd_TaxWO = 0 ; // [006]
	Kd_BrkRat = 0 ;
	Kd_Tmin = 0 ; // [012]
	Kd_PrfCom = 0 ; // Profit Commission Rate [014]

	/* initialisation du type de commission */
	Ks_ComTyp = 0 ;
	
	/* initialisation Minimum et Rest of Variable Commission Estimate [012] */
	Kd_MinVarCE = 0 ;
	Kd_ResVarCE = 0 ;

	/* Initalisation DAC fixed et DAC Variable [014] */
	Kd_DACfix = 0 ;
	Kd_DACvar = 0 ;
	
	/* Initialisation DAC IFRS17 [015] */
	Kd_DACIFRS17 = 0 ;
	Kd_ITD = 0;
        Kd_PNAIFRS17 = 0 ;
	Kd_PNAI17Method = 0 ;

	//[018]
	Kd_DACAE = 0 ;
	Kd_DACBRKAE = 0 ;

	//[019]
	Kd_RecievedMinVarCom = 0;
	Kd_ITDRecVar= 0;

	/* initialisation du tableau des montants du GT */
	memset( Ktd_Amt, 0, sizeof( Ktd_Amt ) ) ;

	/* initialisation du tableau des complements de charges, taxes et courtage */
	memset( Ktd_Comp, 0, sizeof( Ktd_Comp ) ) ;

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet : fonction de calcul des complements de charges, taxes et taux de courtage
        sur EPP
retour :    OK ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_CalculComplementEPP( void )
{
	DEBUT_FCT( "n_CalculComplementEPP" ) ;

	/* complement de charges sur EPP */
	Ktd_Comp[Charge_EPP] = ( Kd_ComRat + Kd_SurComRat ) * Kd_EppTot - Ktd_Amt[Charge_EPP] ;

	/* complement de taxes sur EPP */
//[006] 	Ktd_Comp[Taxe_EPP] = Kd_Tax * Kd_EppTot - Ktd_Amt[Taxe_EPP] ;
 	Ktd_Comp[Taxe_EPP] = Kd_TaxWP * Kd_EppTot - Ktd_Amt[Taxe_EPP] ;

	/* complement de courtage sur EPP */
	Ktd_Comp[Courtage_EPP] = Kd_BrkRat * Kd_EppTot - Ktd_Amt[Courtage_EPP] ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet : fonction de calcul des complements de charges, taxes et taux de courtage
        sur RPP
retour :    OK ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_CalculComplementRPP( void )
{
	DEBUT_FCT( "n_CalculComplementRPP" ) ;

	/* complement de charges sur RPP */
	Ktd_Comp[Charge_RPP] = ( Kd_ComRat + Kd_SurComRat ) * Kd_RppTot - Ktd_Amt[Charge_RPP] ;

	/* complement de taxes sur RPP */
//[006]	Ktd_Comp[Taxe_RPP] = Kd_Tax * Kd_RppTot - Ktd_Amt[Taxe_RPP] ;
	Ktd_Comp[Taxe_RPP] = Kd_TaxWP * Kd_RppTot - Ktd_Amt[Taxe_RPP] ;

	/* complement de courtage sur RPP */
	Ktd_Comp[Courtage_RPP] = Kd_BrkRat * Kd_RppTot - Ktd_Amt[Courtage_RPP] ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet : fonction de calcul des complements de charges, taxes et taux de courtage
        sur Primes
retour :    OK ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_CalculComplementPrimes( void )
{
	DEBUT_FCT( "n_CalculComplementPrimes" ) ;

	/************************************************/
	/* Evol n° 1 - Commission origine multiple	*/
	/* On force le complement de charge de 		*/
	/* commissions a zero si la prime estimee = 0 	*/
	/* et type de commission = 3			*/
	/************************************************/

/* 24 janvier 2002 FCharles pas de commission estimee sur com manuelle */

	/************************************************/
	/* Evol n° 2 - Retrait pour compte commun  	*/
	/* On soustrait a la prime totale la prime 	*/
	/* RPCC estimee et cedante pour le calcul	*/
	/* des complements de charges			*/
	/************************************************/
	
#ifdef TRACE_1
printf("-- Evol n° 2 - On soustrait a la prime totale, la prime RPCC estimee et cedante pour le calcul des complements de charges\n");
printf("-- if ( (Ks_ComTyp[%d] == 3 && Kd_Prme[%lf] == 0) || Ks_ComTyp[%d] == 4 )\n", Ks_ComTyp, Kd_Prme, Ks_ComTyp);
#endif
	/* complement de charges de commissions sur Primes */
	if ( ( Kd_Prme == 0 && Ks_ComTyp != 2 ) || Ks_ComTyp == 4 || Ks_ComTyp == 5 )  //[004] et [005]
	{                                                           //[004]
		Ktd_Comp[ChargeCom_PRM] = 0 ;                           //[004]
#ifdef TRACE_1                                                  //[004]
printf("-- Ktd_Comp[ChargeCom_PRM] = 0 ;\n");                   //[004]
#endif                                                          //[004]
	}                                                           //[004]
	else                                                        //[004]
	{                                                           //[004]
		
		/*************************************************************************************************/
		/* Nouveau Calcul Commissions Estimates REQ 9.5 [012]                                            */
		/* MinVar = -1 * (Tmin * (PrmAlim - (Rpcce + Rpccc)) - received Commission's on premiums charges */
		/* ResVar = (Tvar - Tmin) * (Kd_PrmAlim - (Rpcce + Rpccc))                                       */
		/*************************************************************************************************/

		if((Ks_ComTyp == 1) || (Ks_ComTyp == 3))
		{
			if (Kc_CtrNat == 'F')
				Ktd_Comp[ChargeCom_PRM] = ( Kd_ComRat ) * ( Kd_PrmAlim + ( Kd_Rpccc ) ) - Ktd_Amt[ChargeCom_PRM] ;
			else
				Ktd_Comp[ChargeCom_PRM] = ( Kd_ComRat ) * ( Kd_PrmAlim - ( Kd_Rpcce + Kd_Rpccc ) ) - Ktd_Amt[ChargeCom_PRM] ;
		}
		if(Ks_ComTyp == 2) // [012]
		{
			Kd_RecievedMinVarCom = Kd_Tmin * (Kd_Prmc - Kd_Rpccc) - Kd_ITDRecVar;
                        Kd_MinVarCE = ( Kd_Tmin ) * ( Kd_PrmAlim - ( Kd_Rpcce + Kd_Rpccc ) ) - (Kd_RecievedMinVarCom + Kd_ITDRecVar) ; 
                        Kd_ResVarCE = ( Kd_ComRat - Kd_Tmin ) * ( Kd_PrmAlim - ( Kd_Rpcce + Kd_Rpccc ) )- ( Ktd_Amt[ChargeCom_PRM] -(Kd_RecievedMinVarCom + Kd_ITDRecVar));
		}
		/******************************/
		/* Fin de Modification REQ9.5 */
		/******************************/
		
#ifdef TRACE_1
printf("-- Ktd_Comp[ChargeCom_PRM][%lf] = ( Kd_ComRat[%lf] ) * ( Kd_PrmAlim[%lf] - ( Kd_Rpcce[%lf] + Kd_Rpccc[%lf] ) ) - Ktd_Amt[ChargeCom_PRM][%lf] ;\n",      //[004] Kd_PrmTot remplacé par Kd_PrmAlim
    Ktd_Comp[ChargeCom_PRM], Kd_ComRat, Kd_PrmAlim, Kd_Rpcce, Kd_Rpccc, Ktd_Amt[ChargeCom_PRM]);                                                                //[004] Kd_PrmTot remplacé par Kd_PrmAlim
#endif
	}                                                           //[004]

	/* complement de charges de surcommissions sur Primes */
	if ( ( Kd_Prme == 0) || Ks_ComTyp == 4 )                    //[004]
	{                                                           //[004]
	    Ktd_Comp[ChargeSurCom_PRM] = 0;                         //[004]
	}                                                           //[004]
	else                                                        //[004]
	{                                                           //[004]
			if (Kc_CtrNat == 'F')																		//[007]
    					Ktd_Comp[ChargeSurCom_PRM] = ( Kd_SurComRat ) * ( Kd_PrmAlim + ( Kd_Rpccc ) ) - Ktd_Amt[ChargeSurCom_PRM] ;   //[007] Montant Kd_Rpcce s'annule
    	else
    		    	Ktd_Comp[ChargeSurCom_PRM] = ( Kd_SurComRat ) * ( Kd_PrmAlim - ( Kd_Rpcce + Kd_Rpccc ) ) - Ktd_Amt[ChargeSurCom_PRM] ; 
    		    	
    		                                           //[004] Kd_PrmTot remplacé par Kd_PrmAlim
#ifdef TRACE_1
printf("/* complement de charges de surcommissions sur Primes */\n");
printf("-- Ks_CtrNf%s : Ktd_Comp[ChargeSurCom_PRM][%lf] = ( Kd_SurComRat[%lf] ) * ( Kd_PrmAlim[%lf] - ( Kd_Rpcce[%lf] + Kd_Rpccc[%lf] ) ) - Ktd_Amt[ChargeSurCom_PRM][%lf] ;\n",     //[004] Kd_PrmTot remplacé par Kd_PrmAlim
    Ks_CtrNf, Ktd_Comp[ChargeSurCom_PRM], Kd_SurComRat, Kd_PrmAlim, Kd_Rpcce, Kd_Rpccc, Ktd_Amt[ChargeSurCom_PRM]);                                                               //[004] Kd_PrmTot remplacé par Kd_PrmAlim
#endif
    }                                                           //|004]

	/* complement de taxes sur Primes */
//[006]	Ktd_Comp[Taxe_PRM] = Kd_Tax * ( Kd_PrmTot - ( Kd_Rpcce + Kd_Rpccc ) ) - Ktd_Amt[Taxe_PRM] ;

		//[[007]]
	if (Kc_CtrNat == 'F')	
	{ 	
			// [010] Ktd_Comp[Taxe_PRM] = (Kd_TaxWP + Kd_TaxWO)  * ( Kd_PrmTot + ( Kd_Rpccc ) ) - Ktd_Amt[Taxe_PRM] ; //[007] Montant Kd_Rpcce Supprime [010] Kd_TaxWP contient la somme de Kd_TaxWP et Kd_TaxWO
			
			Ktd_Comp[Taxe_PRM] = (Kd_TaxWP )  * ( Kd_PrmTot + ( Kd_Rpccc ) ) - Ktd_Amt[Taxe_PRM] ; //[007] Montant Kd_Rpcce Supprime	
					
//#ifdef TRACE_1 //[010]
if (strcmp("20F038833", Ks_CtrNf) == 0 )
	{
				printf("/* complement de taxes sur Primes */\n");
				printf("-- Ks_CtrNf%s : Ktd_Comp[Taxe_PRM][%lf] = (Kd_TaxWP[%lf] )  * ( Kd_PrmTot[%lf] + ( Kd_Rpccc[%lf] ) ) - Ktd_Amt[Taxe_PRM][%lf] ;\n",     
    			Ks_CtrNf, Ktd_Comp[Taxe_PRM], Kd_TaxWP,  Kd_PrmTot, Kd_Rpccc, Ktd_Amt[Taxe_PRM]);                                                               //[004] Kd_PrmTot remplacé par Kd_PrmAlim
	}
//#endif						
			
	}
	else
	{ 
			//[008]Ktd_Comp[Taxe_PRM] = (Kd_TaxWP + Kd_TaxWO)  * ( Kd_PrmTot - ( Kd_Rpcce + Kd_Rpccc ) ) - Ktd_Amt[Taxe_PRM] ;		
			Ktd_Comp[Taxe_PRM] = (Kd_TaxWP + Kd_TaxWO)  * ( Kd_PrmTot + ( Kd_Rpccc ) ) - Ktd_Amt[Taxe_PRM] ; //[008]
	
#ifdef TRACE_2
printf("/* complement de taxes sur Primes */\n");
printf("NP Ks_CtrNf %s : Ktd_Comp[Taxe_PRM][%lf] = (Kd_TaxWP[%lf] + Kd_TaxWO[%lf])  * ( Kd_PrmTot[%lf] + ( Kd_Rpccc[%lf] ) ) - Ktd_Amt[Taxe_PRM][%lf] ;\n",     
    Ks_CtrNf, Ktd_Comp[Taxe_PRM], Kd_TaxWP, Kd_TaxWO, Kd_PrmTot, Kd_Rpccc, Ktd_Amt[Taxe_PRM]);                                                               //[004] Kd_PrmTot remplacé par Kd_PrmAlim
#endif
	}			

	/************************************************/
	/* Evol n° 3 - Prise en compte de la   	        */
	/* notion de courtage sur reconstitution 	    */
	/* ds le calcul du complement de courtage	    */
	/* sur Primes 					                */
	/************************************************/

	/* complement de courtage sur Primes */
	
		//[[007]]
	//if (Kc_CtrNat == 'F')			
	//{ 

		//Ktd_Comp[Courtage_PRM] = Kd_BrkRat * ( Kd_PrmTot + (  Kd_Rpccc ) - ( Kd_Rece + Kd_Recc ) ) - (Ktd_Amt[Courtage_PRM] - Ktd_Amt[Courtage_REC]); //[007] Montant Kd_Rpcce supprime
		Ktd_Comp[Courtage_PRM] = Kd_BrkRat * ( Kd_PrmTot + (  Kd_Rpccc ) - ( Kd_Rece + Kd_Recc ) ) - (Ktd_Amt[Courtage_PRM]); //[007] Montant Kd_Rpcce supprime [011] Raf - 78591

#ifdef TRACE_1
printf("/* complement de courtage sur Primes Version A LIVRER*/\n");
printf("--Ks_CtrNf %s : Ktd_Comp[Courtage_PRM][%lf] = ( Kd_BrkRat[%lf] ) * ( Kd_PrmTot[%lf]  + Kd_Rpccc[%lf] ) ) - (Ktd_Amt[Courtage_PRM][%lf] -Ktd_Amt[Courtage_REC][%lf]) ;\n",     //[004] Kd_PrmTot remplacé par Kd_PrmTot
    Ks_CtrNf, Ktd_Comp[Courtage_PRM], Kd_BrkRat, Kd_PrmTot,  Kd_Rpccc, Ktd_Amt[Courtage_PRM], Ktd_Amt[Courtage_REC]);                                                               //[004] Kd_PrmTot remplacé par Kd_PrmAlim
#endif


 //} 	
 // else
  //{ 
  	//[008] Ktd_Comp[Courtage_PRM] = Kd_BrkRat * ( Kd_PrmTot - ( Kd_Rpcce + Kd_Rpccc ) - ( Kd_Rece + Kd_Recc ) ) - (Ktd_Amt[Courtage_PRM] - Ktd_Amt[Courtage_REC]);  	
  	//Ktd_Comp[Courtage_PRM] = Kd_BrkRat * ( Kd_PrmTot + (  Kd_Rpccc ) - ( Kd_Rece + Kd_Recc ) ) - (Ktd_Amt[Courtage_PRM] - Ktd_Amt[Courtage_REC]);  
  	//Ktd_Comp[Courtage_PRM] = Kd_BrkRat * ( Kd_PrmTot + (  Kd_Rpccc ) - ( Kd_Rece + Kd_Recc ) ) - (Ktd_Amt[Courtage_PRM]); // [011] Raf - 78591 

//#ifdef TRACE_2
//printf("/* complement de courtage sur Primes Version A LIVRER NP */\n");
//printf(" AUTRE  NP Ks_CtrNf %s : Ktd_Comp[Courtage_PRM][%lf] = Kd_BrkRat[%lf] * ( Kd_PrmTot[%lf] + (  Kd_Rpccc[%lf] ) - ( Kd_Rece[%lf] + Kd_Recc[%lf] ) ) - (Ktd_Amt[Courtage_PRM][%lf] - Ktd_Amt[Courtage_REC][%lf]); \n",
//         Ks_CtrNf, Ktd_Comp[Courtage_PRM], Kd_BrkRat, Kd_PrmTot,  Kd_Rpccc, Kd_Rece, Kd_Recc, Ktd_Amt[Courtage_PRM], Ktd_Amt[Courtage_REC]);
//printf(" NP Ks_CtrNf %s : Ktd_Comp[Courtage_PRM][%lf] = ( Kd_BrkRat[%lf] ) * ( Kd_PrmTot[%lf]  + Kd_Rpccc[%lf] ) ) - (Ktd_Amt[Courtage_PRM][%lf] -Ktd_Amt[Courtage_REC][%lf]) ;\n",     //[004] Kd_PrmTot remplacé par Kd_PrmTot
//    Ks_CtrNf, Ktd_Comp[Courtage_PRM], Kd_BrkRat, Kd_PrmTot,  Kd_Rpccc, Ktd_Amt[Courtage_PRM], Ktd_Amt[Courtage_REC]);                                                               //[004] Kd_PrmTot remplacé par Kd_PrmAlim
//#endif
  	
  //}	
  	

	/* complement de courtage sur REC */
	if (Kn_PerRecBrk_B==1)
	{
	Ktd_Comp[Courtage_REC] = (-1)* Kd_RecBrkRat * ( Kd_Rece + Kd_Recc ) - Ktd_Amt[Courtage_REC] ;
	}

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet : fonction de calcul des complements de charges, taxes et taux de courtage
        sur PPNA
retour :    OK ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_CalculComplementPPNA( void )
{
	DEBUT_FCT( "n_CalculComplementPPNA" ) ;
	//[015]
 	int n_CloDatD, n_CloDatM, n_CloDatY, n_ExpDatD, n_ExpDatM, n_ExpDatY;

	/* complement de charges + taxes sur PPNA */
//[006] 	Ktd_Comp[ChargeTaxe_PPNA] = ( Kd_ComRat + Kd_SurComRat + Kd_Tax ) * Kd_PpnaTot - Ktd_Amt[ChargeTaxe_PPNA] ;

//[010] Kd_TaxWO
  if (Kc_CtrNat == 'F')	
 		Ktd_Comp[ChargeTaxe_PPNA] = ( Kd_ComRat + Kd_SurComRat + Kd_TaxWP ) * Kd_PpnaTot - Ktd_Amt[ChargeTaxe_PPNA] ;
  else
 		Ktd_Comp[ChargeTaxe_PPNA] = ( Kd_ComRat + Kd_SurComRat + (Kd_TaxWP + Kd_TaxWO) ) * Kd_PpnaTot - Ktd_Amt[ChargeTaxe_PPNA] ; 		

	/* complement de courtage sur PPNA */
  Ktd_Comp[Courtage_PPNA] = Kd_BrkRat * Kd_PpnaTot - Ktd_Amt[Courtage_PPNA] ;
  /* Calcul DAC IFRS17 [015] */

    o_ExtractionAnneeMoisJour(Ksz_Clodat, &n_CloDatY, &n_CloDatM, &n_CloDatD);
    o_ExtractionAnneeMoisJour(Ksz_Expdat, &n_ExpDatY, &n_ExpDatM, &n_ExpDatD);

  /************************************************************************************************************/
  /* Nouveau calcul DAC Fixed, DAC Variable REQ 9.4 [014]                                                     */
  /* Si facultatif et COMTYP = 1                                                                              */
  /*    Kd_DACfix = (Kd_ComRat + Kd_SurComRat + (Kd_TaxWP) ) * Kd_PpnaTot - Ktd_Amt[ChargeTaxe_PPNA]          */
  /* Sinon                                                                                                    */
  /*    Si COMTYP = 1                                                                                         */
  /*     Kd_DACfix = (Kd_ComRat + Kd_SurComRat + (Kd_TaxWP) ) * Kd_PpnaTot - Ktd_Amt[ChargeTaxe_PPNA]         */
  /*     Kd_DACvar = 0                                                                                        */ 
  /*    Si COMTYP = 2                                                                                         */
  /*     Kd_DACfix = (Kd_Tmin + Kd_SurComRat + (Kd_TaxWP + Kd_TaxWO)) * Kd_PpnaTot - Ktd_Amt[ChargeTaxe_PPNA] */
  /*     Kd_DACvar = (Kd_ComRat - Kd_Tmin) * Kd_PpnaTot - Ktd_Amt[ChargeTaxe_PPNA]                            */
  /************************************************************************************************************/

  if (Kc_CtrNat == 'F')
  {	
      if ((Ks_ComTyp == 1) || (Ks_ComTyp == 3) || (Ks_ComTyp == 4) || (Ks_ComTyp == 5))
      {
          Kd_DACfix = (Kd_ComRat + Kd_SurComRat + (Kd_TaxWP) ) * Kd_PpnaTot - Ktd_Amt[ChargeTaxe_PPNA];
	  //Kd_DACvar = (Kd_PrfCom) * Kd_PpnaTot;
      }
  }
  else
  {
      if ((Ks_ComTyp == 1) || (Ks_ComTyp == 3) || (Ks_ComTyp == 4) || (Ks_ComTyp == 5))
      {
          Kd_DACfix = (Kd_ComRat + Kd_SurComRat + (Kd_TaxWO + Kd_TaxWP) ) * Kd_PpnaTot - Ktd_Amt[ChargeTaxe_PPNA];
          Kd_DACvar = 0; //(Kd_PrfCom) * Kd_PpnaTot;
      }
      if (Ks_ComTyp == 2)
      {
          Kd_DACfix = (Kd_Tmin + Kd_SurComRat + (Kd_TaxWP + Kd_TaxWO) ) * Kd_PpnaTot - Ktd_Amt[ChargeTaxe_PPNA];
          Kd_DACvar = (Kd_ComRat - Kd_Tmin) * Kd_PpnaTot;
      }
  }
  /*******************************/
  /* Fin de Modification REQ 9.4 */
  /*******************************/
   /* Calcul DAC IFRS17 [015] */
  if (strcmp(Ksz_Norme, "EBS") == 0)
  {
    if(Kc_CtrNat == 'F')
    {
      Kd_PNAIFRS17 = Kd_PNAIFRS17 * Kd_EGPI ;
    }
  
  
    if((Kc_CtrNat == 'N' && (strcmp(Ks_Secqua4Cf, "20") == 0 || strcmp(Ks_Secqua4Cf, "21") == 0 || strcmp(Ks_Secqua4Cf, "22") == 0)) &&(nbJours_Entre_Deux_Dates(n_CloDatD, n_CloDatM, n_CloDatY, n_ExpDatD, n_ExpDatM, n_ExpDatY) > 0))
    {
       Kd_PNAIFRS17 = Kd_PNAIFRS17 - Kd_ITD;
    }
    if ((Kc_CtrNat == 'N' && (strcmp(Ks_Secqua4Cf, "20") == 0 || strcmp(Ks_Secqua4Cf, "21") == 0 || strcmp(Ks_Secqua4Cf, "22") == 0)) || (Kc_CtrNat == 'F' && Kd_PNAI17Method == 3))
    {
      Kd_DACIFRS17 = Kd_BrkRat * (Kd_PNAIFRS17) ;
      Kd_DACIFRS17 = Kd_DACIFRS17 - (Ktd_Comp[Courtage_PPNA] + Ktd_Amt[ChargeTaxe_PPNA] + Kd_DACBRKAE) - (Kd_DACfix + Ktd_Amt[Courtage_PPNA] + Kd_DACAE);
    }
    else
    {
          Kd_DACIFRS17 = 0;
    }
  }
 
	RETURN_VAL( OK ) ;
}

//[018]
int n_check_trncd_cf(char *sz_TrnCd)
{
        int i ;
        char  flg_tcode;

        DEBUT_FCT("n_check_trncd_cf");

        for ( i = 0; i <  Kn_FBOTRSLNK ; i++ )
        {
                if ( strcmp( sz_TrnCd, Ktbd_FBOTRSLNK[i].DETTRS_CF ) == 0 )
                {
                        if (    Ktbd_FBOTRSLNK[i].DETTRS_CF[1] == '4'
                                && Ktbd_FBOTRSLNK[i].TRSPFX_CF == '1')
                                flg_tcode = 'Y';
                        else
                                flg_tcode = 'N';

                        if (	Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2031
				&& Ktbd_FBOTRSLNK[i].TRNTYP_CT < 100
                                && flg_tcode == 'Y')
                                RETURN_VAL(DACBRKAE) ;

                        if (    Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2030
                                && Ktbd_FBOTRSLNK[i].TRNTYP_CT < 100
                                && flg_tcode == 'Y')
                                RETURN_VAL(DACAE) ;

                    	if (	Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2010
                        	&& (strcmp(Ktbd_FBOTRSLNK[i].DETTRS_CF,"11120210") == 0 || strcmp(Ktbd_FBOTRSLNK[i].DETTRS_CF,"11120000") == 0))
				RETURN_VAL(RECMIN);
                }
        }

        RETURN_VAL(OTHER) ;
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
               	if (    Ktbd_FBOTRSLNK[i].DETTRS_CF[1] == '4'
                        && Ktbd_FBOTRSLNK[i].TRSPFX_CF == '1')
                        flg_tcode = 'Y';
                else
                        flg_tcode = 'N';

                if ( (  Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2031
                        && Ktbd_FBOTRSLNK[i].TRNTYP_CT < 100
                        && flg_tcode == 'Y') ||
                   

                    (    Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2030
                        && Ktbd_FBOTRSLNK[i].TRNTYP_CT < 100
                        && flg_tcode == 'Y') ||

                    (    Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 2010
			&& (strcmp(Ktbd_FBOTRSLNK[i].DETTRS_CF,"11120210") == 0 || strcmp(Ktbd_FBOTRSLNK[i].DETTRS_CF,"11120000") == 0)) )
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

