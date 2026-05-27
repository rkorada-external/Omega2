/*==============================================================================
nom de l'application          : ESTIMATION IFRS17
nom du source                 : ESFC3650.c
revision                      : $Revision: 1.0 $
date de creation              : 20/05/2019
auteur                        : JYP - PERSEE
------------------------------------------------------------------------------
description :
 projet IFRS17 - spira 70377 - REQ 12.1 - Risk Adjustment Calculation


------------------------------------------------------------------------------
historique des modifications :
[001] 17/06/2019 JYP	:spira:70377 IFRS17 req 12.1 - creation - Risk Adjusment Calculation
[002] 09/07/2019 JYP	:spira:70377 IFRS17 req 12.1 - use MARKET file to map with ratio
[003] 13/08/2019 JYP	:spira:70377 IFRS17 req 12.1 - bugfix GRPGRP3_NT
[004] 26/08/2019 JYP	:spira:70377 IFRS17 req 12.1 - bugfix seglob
[005] 27/08/2019 JYP    :spira:70377 IFRS17 req 12.1 - bugfix ACMTRS
[005] 16/09/2019 JYP    :spira:70377 IFRS17 req 12.1 - bugfix SGMT_LS length
[006] 27/09/2019 JYP    :spira:70377 IFRS17 req 12.1 - bugfix reversed amounts
[007] 27/10/2019 JYP    :spira:70377 IFRS17 req 12.1 - add log
[008] 07/11/2019 JYP    :spira:70377 IFRS17 req 12.1 - bugix RETRO
[009] 20/01/2020 JYP    :spira:81988 IFRS17 req 12.1 - bugfix test fabs
[010] 07/02/2020 JYP    :spira:84167 IFRS17 req 12.1 - bugfix pattern
[011] 11/03/2020 JYP    :spira:82789 IFRS17 req 12.1 - bugfix Endorsment 2 digits 
[012] 09/04/2020 JYP    :spira:79070 IFRS17 req 11.7.2 : retroP retroNP at Inception
[013] 03/06/2020 JYP    :spira:86648 IFRS17 req 11.7.2 : for retroP use Gross setup
[014] 04/06/2020 JYP    :spira 87593 IFRS17 req 11.7.2 : change retroNP sort keys 
[015] 01/07/2020 JYP    :spira 87296 IFRS17 req 11.7.2 : retroP pattern not applied, bugfix ratio retroP
[016] 02/07/2020 JYP    :spira 87296 IFRS17 req 11.7.2 : retroP bugfix ratio SSD from accept
[017] 07/07/2020 JYP    :spira 83206 IFRS17 req 11.7.2 : retroP bugfix seg nf for pattern
[018] 04/08/2020 JYP    :spira 88234 IFRS17 : use grouping 751 3201 3010
[019] 11/08/2020 JYP    :spira 83206 IFRS17 req 11.7.2 : retroP log retroP
[020] 17/09/2020 JYP    :spira 87319 IFRS17 some RAD missing, synchro issue
[021] 30/06/2021 JYP    :spira 96654 IFRS17 : retroNP total amount issue
[022] 25/10/2021 JYP    :spira 98274 IFRS17 : change type A/R/AI/RI
[023] 10/08/2022 JYP    :spira 100297 IFRS17: RAD AE integration
[024] 01/09/2023 DAD    :spira 110165 : replacing initial amount by the total amount for both assumed and retro
[025] 11/09/2024 DAD    :spira 112082 : new ratio RALIC_R and RALRC_R for RAP
[026] 19/12/2025 HR     :spira 111392 : I17 - RA - Modify basis of calculations from current to lock in claims
================================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "struct.h"
#include "estserv.h"
#include "estutil.c"


/*----------------------------------------*/
/* inclusion de version dans les binaires */
/*----------------------------------------*/
static char VERSION_ESFC3650_C[151] = "__version__: ESFC3650.c version [025] 11/09/2024 - new ratio RALIC_R and RALRC_R for RAP" ;




/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE   *Kp_OutputFilResSii;    /* pointeur sur le fichier de sortie format� avec les nouvelles colonnes */
FILE   *Kp_OutputFilResSiiAno; /* pointeur sur le fichier de sortie des lignes sans segment */
FILE   *Kp_InputFilRaRat;     /* pointeur sur le fichier en entree des ratios RARAT  */
FILE   *p_OutputLogs; 	   /* Fichier de log   */
FILE   *Kp_OutputFilTotal;    /* pointeur sur le fichier de sortie format� avec les nouvelles colonnes, TOTAL amount */
// FILE   *Kp_OutputFilDldSIIGTAA; /* pointeur sur le fichier de sortie AA format? avec les nouvelles colonnes */
// FILE   *Kp_OutputFilDldSIIGTRA; /* pointeur sur le fichier de sortie RA format? avec les nouvelles colonnes */
// FILE   *Kp_CURQUOT;            /* pointeur sur le fichier curquot */
// FILE   *Kp_AE_EPOSOCI;         /* pointeur sur le fichier input AE */
	   
T_RUPTURE_VAR       bd_RuptPerUw;   /* variable de gestion de la rupture sur le perimetre de Accept ou Retro */
T_RUPTURE_SYNC_VAR  bd_RuptGTSIIA; /* variable de gestion de la synchronisation avec le fichier GTSII ESCOMPTE Assumed*/
T_RUPTURE_SYNC_VAR  bd_RuptGTSIIRNP; /* variable de gestion de la synchronisation avec le fichier GTSII ESCOMPTE retroNP */
T_RUPTURE_SYNC_VAR  bd_RuptGTSIIRP; /* variable de gestion de la synchronisation avec le fichier GTSII ESCOMPTE retroP */
T_RUPTURE_SYNC_VAR  bd_RuptRETSEC; /* variable de gestion de la synchronisation avec le fichier FWRETSEC */


char Ksz_norme_cf[10]  ;    
char Ksz_patcat_ct[10] ;
char Ksz_pattyp_ct[10] ;
char Ksz_context_ct[20] ;
char Ksz_iclodat_d[10];
char ksz_GRPGRP3_NT[20] ;


/* definition de la structure T_RARAT */
typedef struct {
  int SSD_CF ;
  short ESB_CF ; 
  char SEG_NF[12];
//  char NORME_CF [12];
  char CTRNAT_CT ;
  char DOMAIN_CF[8];
  double PRMRAT_R ;
  double RSRVRAT_R ;
  char SGMT_LS[17];
  double RALIC_R ;
  double RALRC_R ;

//char CLODAT_D [21];
//  char PER_CF[11];
} T_RARAT ;

#define NB_RARAT_MAX 10000
#define LGTH_RARAT 90
#define SEPARATOR        "~"
#define RAT_SSD_CF     0
#define RAT_ESB_CF     1
#define RAT_SEG_NF     2
#define RAT_NORME_CF   3
#define RAT_CTRNAT_CT  4
#define RAT_DOMAIN_CF  5
#define RAT_PRMRAT_R   6
#define RAT_RSRVRAT_R  7
#define RAT_SGMT_LS    8
#define RAT_RALIC_R   10
#define RAT_RALRC_R   11


#define GTSII_ACMTRS3_NT 51
#define GTSII_ACMTRS3_NT_ORIG 123
#define GTSII_GRPGRP3_NT 124
#define GTSII_CTRGRO_SEGNF 125
#define GTSII_CTRNAT_ACCEPT 126
#define GTSII_SSD_CF_ACCEPT 127

#define RETSEC_RETCTR_NF 0
#define RETSEC_RETEND_NT 1 
#define RETSEC_RETSEC_NF 2 
#define RETSEC_RTY_NF    3
#define RETSEC_RETUW_NT  4
#define RETSEC_CTRNAT_CT 5
#define RETSEC_SUBMRK_LS 6
#define RETSEC_MRKUNT_NT 7
#define RETSEC_SUBMRK_NT 8
#define RETSEC_GRPGRP3_NT 9

/* from ESFC3740 to produce GT-RAD as before */
// #define GTSII_AM01_M 54
// #define GT2_ACMTRS_NT 41
// #define GT2_ACMAMT_M 42
// #define GT2_AMT_M 18
// #define GT2_ACMCUR_CF 43
// #define GT2_ACCRET 48
// #define GT2_NORME 49
// #define GT2_PATCAT_CT 51
// #define GT2_PATTYP_CT 52
// #define GT2_TOTAUX_M 122
// #define GT2_ACMTRS3_NF 123
// #define GT2_TYP_CT 48
// #define GT2_NAT_CF 47
// #define GT2_GRPINIPRO_CF 124
// #define GT2_PARINIPRO_CF 125
// #define GT2_LOCINIPRO_CF 126
// //[05]
// #define GT2_LC_PAT_PREV 124
// #define GT2_CSM_PAT_PREV 125



T_RARAT Ktbd_rarat [NB_RARAT_MAX];   /* tableau permettant de charger en memoire FRARAT */
int Kn_NbLig_RaRat;   /* nombre de ratios dans le tableau */



char sz_message[200];
int  n_DEBUG_LEVEL;        

// char gsz_Annee[5], gsz_Mois[3], gsz_Jour[3]; // de la Date de cloture Ex: 20111201
// //double n_Total;
// double td_Total[4];
// char sz_NormeTotal[10] = "Z";

// int n_NormeCur;
// int temp_n_ChargerFBOPRSLNK;
// int temp_n_RechTrn;
// char sz_Clodat_d[9] = "19990101";
// char sz_Somme[21] = "";
// char sz_trncod[9];


int n_InitPerUw            ( T_RUPTURE_VAR  *pbd_Rupt );

int n_ActionLignePerUw (char **pbd_InRec_Cur);

int n_InitGTSIIA		      ( T_RUPTURE_SYNC_VAR *pbd_Rupt );
int n_InitGTSIIRNP		      ( T_RUPTURE_SYNC_VAR *pbd_Rupt );
int n_InitGTSIIRP		      ( T_RUPTURE_SYNC_VAR *pbd_Rupt );
int n_InitRETSEC		      ( T_RUPTURE_SYNC_VAR *pbd_Rupt );
int n_ActionLigneGTSII    ( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ActionLigneGTSIIRNP    ( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ActionLigneGTSIIRP    ( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ActionLigneRETSEC    ( char **pbd_InRecOwner, char **pbd_InRecChild );

int n_ActionPereSansFilsRetSec(char **ptsz_LigneMaitre);
int n_ActionPereSansFilsGTSIIRP(char **ptsz_LigneMaitre);
int n_ActionPereSansFilsGTSIIRNP(char **ptsz_LigneMaitre);
int n_ActionPereSansFilsGTSIIA(char **ptsz_LigneMaitre);

int n_ActionFilsSansPereGTSIIA  ( char **ptb_InRecChild ) ;
int n_ActionFilsSansPereGTSIIRP  ( char **ptb_InRecChild ) ;
int n_ActionFilsSansPereGTSIIRNP  ( char **ptb_InRecChild ) ;
	   

int n_ConditionSyncGTSII  ( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ConditionSyncGTSIIRNP  ( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ConditionSyncGTSIIRP  ( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ConditionSyncRETSEC  ( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ChargerTRARAT  ( void ) ;
int n_RechTRARAT( int c_ssd, short c_esb_cf , char *sz_seg , char c_ctrnat_cf, char * sz_domain_cf );


int n_RA_processing    ( char **pbd_InRecOwner, char **pbd_InRecChild );

int n_ProcessingRuptureSyncVar (T_RUPTURE_SYNC_VAR  *pbd_Rupt, char **pbd_InRecOwner );

int n_ActionFirstRuptGTSII ( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ActionFirstRuptGTSIIRNP ( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ActionFirstRuptGTSIIRP ( char **pbd_InRecOwner, char **pbd_InRecChild );
	
	
int n_IsR1GTSII( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_IsR1GTSIIRNP( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_IsR1GTSIIRP( char **pbd_InRecOwner, char **pbd_InRecChild );

int n_WriteLogLevel( int c_level , char * sz_message );

// int writeLine(char **ptb_InRecChild, char *sz_Clodat_d, const char *sz_inittrncod, char *sz_Somme, const char *sz_amctrs3);
// char n_GetNorme(const char *Norme_CF);

// char Ksz_DBLTRNCOD_CF[9]; /* Poste contrepartie */
// int n_PosteContre(char *sz_trncod, FILE *Kp_Dettrs);
// FILE   *Kp_GetDbltrncod; /* Pointeur sur le fichier des poste de contrepartie */


char * trim(char *);



int    kn_MIN_ICLODAT_A; //date bilan -2 (dans le ESID2003)

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

  
	sprintf(sz_message,"\nRunning with %s\n", VERSION_ESFC3650_C);
	printf(sz_message);
	
  strcpy(Ksz_norme_cf   , psz_GetCharArgv(1) ) ;   
  strcpy(Ksz_patcat_ct  , psz_GetCharArgv(2) ) ;
  strcpy(Ksz_pattyp_ct  , psz_GetCharArgv(3) ) ;
  strcpy(Ksz_context_ct , psz_GetCharArgv(4) ) ;
  strcpy(Ksz_iclodat_d  , psz_GetCharArgv(5) ) ;
  n_DEBUG_LEVEL = (int) atoi(psz_GetCharArgv(6) );
  strcpy(ksz_GRPGRP3_NT,"");

	n_WriteLogLevel(0, sz_message);
	

	/* ouverture du fichier en entree des ratios RARAT  */
	if ( n_OpenFileAppl ( "ESFC3650_I3","rb",&Kp_InputFilRaRat ) == ERR )
		ExitPgm( ERR_XX , "" );



  /* Ouverture du fichier contenant le poste de contrepartie */
  //  if (n_OpenFileAppl("ESFC3650_I8", "rt", &Kp_GetDbltrncod) == ERR) {
  //     ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileApplGetDbltrncod");
  //  }
      
  //  if (n_OpenFileAppl("ESFC3650_I9", "rt", &Kp_CURQUOT) == ERR) {
  //     ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl CURQUOT");
  //  }

  //  if (n_OpenFileAppl("ESFC3650_I10", "rt", &Kp_AE_EPOSOCI) == ERR) {
  //     ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl AE_EPOSOCI");
  //  }
  	  
	/* ouverture du fichier de sortie des resultats par affaire */
	if ( n_OpenFileAppl ( "ESFC3650_O1","wt",&Kp_OutputFilResSii ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_OpenFileAppl ( "ESFC3650_O3","wt",&Kp_OutputFilTotal ) == ERR )
		ExitPgm( ERR_XX , "" );


	/* ouverture du fichier de sortie des resultats par affaire */
	if ( n_OpenFileAppl ( "ESFC3650_O2","wt",&Kp_OutputFilResSiiAno ) == ERR )
		ExitPgm( ERR_XX , "" );


	// if ( n_OpenFileAppl ( "ESFC3650_O4","wt",&Kp_OutputFilDldSIIGTAA ) == ERR )
	// 	ExitPgm( ERR_XX , "" );

	// if ( n_OpenFileAppl ( "ESFC3650_O5","wt",&Kp_OutputFilDldSIIGTRA ) == ERR )
	// 	ExitPgm( ERR_XX , "" );


	/* Initialisation de la variable bd_RuptPerUw */
	if ( n_InitPerUw( &bd_RuptPerUw ) )
		ExitPgm( ERR_XX , "" );


	/* Initialisation de la variable bd_RuptGTSIIA */
	if ( n_InitGTSIIA( &bd_RuptGTSIIA ) )
		ExitPgm( ERR_XX , "" );


     /* Initialisation de la variable bd_RuptGTSIIRNP */
     if ( n_InitGTSIIRNP( &bd_RuptGTSIIRNP ) )
                ExitPgm( ERR_XX , "" );

     /* Initialisation de la variable bd_RuptGTSIIRP */
     if ( n_InitGTSIIRP( &bd_RuptGTSIIRP ) )
                ExitPgm( ERR_XX , "" );


     /* Initialisation de la variable bd_RuptRETSEC */
     if ( n_InitRETSEC( &bd_RuptRETSEC ) )
                ExitPgm( ERR_XX , "" );



  /* Chargement de TRARAT en memoire */
   Kn_NbLig_RaRat = n_ChargerTRARAT( ) ;

   if ( Kn_NbLig_RaRat > NB_RARAT_MAX )
                ExitPgm( ERR_XX , "Error NB_RARAT_MAX " );



	/* lancement du traitement du fichier Perimetre de souscription IADPERICASE.dat */
	if ( n_ProcessingRuptureVar( &bd_RuptPerUw ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESFC3650_I1", &( bd_RuptPerUw.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESFC3650_I2", &( bd_RuptGTSIIA.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESFC3650_I3", &Kp_InputFilRaRat ) == ERR )
		ExitPgm( ERR_XX , "" );


    if ( n_CloseFileAppl( "ESFC3650_I5", &( bd_RuptGTSIIRNP.pf_InputFil ) ) == ERR )
        ExitPgm( ERR_XX , "" );

    if ( n_CloseFileAppl( "ESFC3650_I7", &( bd_RuptGTSIIRP.pf_InputFil ) ) == ERR )
        ExitPgm( ERR_XX , "" );

    if ( n_CloseFileAppl( "ESFC3650_I6", &( bd_RuptRETSEC.pf_InputFil ) ) == ERR )
        ExitPgm( ERR_XX , "" );

  //  if (n_CloseFileAppl("ESFC3650_I8", &(Kp_GetDbltrncod)) == ERR) 
  //     ExitPgm(ERR_XX, "Probleme lors de la fermeture du fichier FDETTRS");
     
  //  if (n_CloseFileAppl("ESFC3650_I9", &(Kp_CURQUOT)) == ERR) 
  //     ExitPgm(ERR_XX, "Probleme lors de la fermeture du fichier CURQUOT");

  //  if (n_CloseFileAppl("ESFC3650_I10", &(Kp_AE_EPOSOCI)) == ERR) 
  //     ExitPgm(ERR_XX, "Probleme lors de la fermeture du fichier AE_EPOSOCI");

	if ( n_CloseFileAppl( "ESFC3650_O1", &Kp_OutputFilResSii ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESFC3650_O3", &Kp_OutputFilTotal ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESFC3650_O2", &Kp_OutputFilResSiiAno ) == ERR )
		ExitPgm( ERR_XX , "" );

	// if ( n_CloseFileAppl( "ESFC3650_O4", &Kp_OutputFilDldSIIGTAA ) == ERR )
	// 	ExitPgm( ERR_XX , "" );

	// if ( n_CloseFileAppl( "ESFC3650_O5", &Kp_OutputFilDldSIIGTRA ) == ERR )
	// 	ExitPgm( ERR_XX , "" );


	if ( n_EndPgm() == ERR )
		ExitPgm( ERR_XX , "" );

	exit(OK);
}


/*==============================================================================
objet :
	fonction d'initialisation de la variable de gestion de rupture du fichier
	maitre.

retour :
	0K
==============================================================================*/
int n_InitPerUw(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitPerUw" );

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) );

	/* ouverture du fichier maitre Perimetre de souscription */
	if ( n_OpenFileAppl( "ESFC3650_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR;


       pbd_Rupt->n_NbRupture = 0;

        /* fonction d'action sur la ligne courante du fichier maitre */
        pbd_Rupt->n_ActionLigne = n_ActionLignePerUw;

        pbd_Rupt->c_Separ = '~';

	RETURN_VAL( OK );
}


/*==============================================================================
objet : fonction lanc�e � la rupture premi�re sur le fichier ma�tre

retour :
	OK ---> traitement correctement effectu�
	ERR --> probl�me rencontr�
==============================================================================*/


int n_ActionLignePerUw(char **pbd_InRec_Cur)
{
        DEBUT_FCT("n_ActionLignePerUw");


  sprintf(sz_message,"lignePERICASE ~%s~%s~%s~%s~%s~%s~%s",
  pbd_InRec_Cur[PER_CTR_NF],pbd_InRec_Cur[PER_END_NT],
  pbd_InRec_Cur[PER_SEC_NF], pbd_InRec_Cur[PER_UWY_NF], pbd_InRec_Cur[PER_UW_NT] , pbd_InRec_Cur[PER_CTRTYP_CT],pbd_InRec_Cur[PER_CTRNAT_CT] );

  n_WriteLogLevel(1,sz_message);


if ( strcmp(pbd_InRec_Cur[PER_CTRTYP_CT],"RET" ) != 0 )            // Assumed
  n_ProcessingRuptureSyncVar( &bd_RuptGTSIIA, pbd_InRec_Cur );

if ( strcmp(pbd_InRec_Cur[PER_CTRTYP_CT],"RET" ) == 0 && strcmp(pbd_InRec_Cur[PER_CTRNAT_CT] , "N") == 0  )  // retroNP
{
  n_ProcessingRuptureSyncVar( &bd_RuptRETSEC, pbd_InRec_Cur );
  n_ProcessingRuptureSyncVar( &bd_RuptGTSIIRNP, pbd_InRec_Cur );
}
else if ( strcmp(pbd_InRec_Cur[PER_CTRTYP_CT],"RET" ) == 0 && strcmp(pbd_InRec_Cur[PER_CTRNAT_CT] , "P") == 0  )  // retroP
{
  n_ProcessingRuptureSyncVar( &bd_RuptGTSIIRP, pbd_InRec_Cur );
}

        return OK ;
}






/*==============================================================================
 * objet :
 *         Initialisation de la synchronisation du maitre avec l esclave GTSII Assumed 
 *
 *                 retour :
 *                         OK
 ==============================================================================*/

int n_InitGTSIIA( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
        DEBUT_FCT( "n_InitGTSIIA" );

        memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) );

        /* ouverture du fichier esclave */
        if ( n_OpenFileAppl( "ESFC3650_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
                return ERR;

        /* nombre de rupture a gerer */
        pbd_Rupt->n_NbRupture = 1;

        /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
        pbd_Rupt->ConditionEndSync = n_ConditionSyncGTSII;

        /* fonction d'action sur la ligne courante */
        pbd_Rupt->n_ActionLigne = n_ActionLigneGTSII;
        pbd_Rupt->n_PereSansFils= n_ActionPereSansFilsGTSIIA;
  	    pbd_Rupt->n_FilsSansPere= n_ActionFilsSansPereGTSIIA ;

        /* fonction du test de rupture de niveau 1 */
        pbd_Rupt->n_ConditionRupture[0] = n_IsR1GTSII ;
        
        /* fonction lancee en rupture niveau 1 */
        pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptGTSII ;


        pbd_Rupt->c_Separ = '~';

        RETURN_VAL( OK );
}

int n_InitGTSIIRNP( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
        DEBUT_FCT( "n_InitGTSIIRNP" );

        memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) );

        /* ouverture du fichier esclave */
        if ( n_OpenFileAppl( "ESFC3650_I5", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
                return ERR;

        /* nombre de rupture a gerer */
        pbd_Rupt->n_NbRupture = 1;

        /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
        pbd_Rupt->ConditionEndSync = n_ConditionSyncGTSIIRNP;

        /* fonction d'action sur la ligne courante */
        pbd_Rupt->n_ActionLigne = n_ActionLigneGTSIIRNP;

       /* fonction du test de rupture de niveau 1 */
       pbd_Rupt->n_ConditionRupture[0] = n_IsR1GTSIIRNP ;

       /* fonction lancee en rupture niveau 1 */
       pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptGTSIIRNP ;

       pbd_Rupt->n_PereSansFils=n_ActionPereSansFilsGTSIIRNP;
	   
	   pbd_Rupt->n_FilsSansPere = n_ActionFilsSansPereGTSIIRNP ;

       pbd_Rupt->c_Separ = '~';

       RETURN_VAL( OK );
}


int n_InitGTSIIRP( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
        DEBUT_FCT( "n_InitGTSIIRP" );

        memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) );

        /* ouverture du fichier esclave */
        if ( n_OpenFileAppl( "ESFC3650_I7", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
                return ERR;

        /* nombre de rupture a gerer */
        pbd_Rupt->n_NbRupture = 1;

        /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
        pbd_Rupt->ConditionEndSync = n_ConditionSyncGTSIIRP;

        /* fonction d'action sur la ligne courante */
        pbd_Rupt->n_ActionLigne = n_ActionLigneGTSIIRP;

       /* fonction du test de rupture de niveau 1 */
       pbd_Rupt->n_ConditionRupture[0] = n_IsR1GTSIIRP ;
       
       /* fonction lancee en rupture niveau 1 */
       pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptGTSIIRP ;
	    
       pbd_Rupt->n_PereSansFils=n_ActionPereSansFilsGTSIIRP;
	   
	   pbd_Rupt->n_FilsSansPere = n_ActionFilsSansPereGTSIIRP ;

        pbd_Rupt->c_Separ = '~';

        RETURN_VAL( OK );
}




int n_InitRETSEC( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
        DEBUT_FCT( "n_InitRETSEC" );

        memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) );

        /* ouverture du fichier esclave */
        if ( n_OpenFileAppl( "ESFC3650_I6", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
                return ERR;

        /* nombre de rupture a gerer */
        pbd_Rupt->n_NbRupture = 0;

        /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
        pbd_Rupt->ConditionEndSync = n_ConditionSyncRETSEC;

        /* fonction d'action sur la ligne courante */
        pbd_Rupt->n_ActionLigne = n_ActionLigneRETSEC;

        pbd_Rupt->n_PereSansFils=n_ActionPereSansFilsRetSec;

        pbd_Rupt->c_Separ = '~';

        RETURN_VAL( OK );
}




/*==============================================================================
objet :
	fonction de test de synchronisation

retour :
	0	---> pbd_InRecOwner = pbd_InRecChild ( egalit� de rubrique a synchroniser)
	> 0   	---> pbd_InRecOwne> > pbd_InRecChild
	< 0   	---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncGTSII(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret;

	DEBUT_FCT( "n_ConditionSyncGTSII" );

/*
    sprintf(sz_message,"\n--> n_ConditionSyncGTSII-A -- CTR_NF END_NT sec UWY_NF UW_NT ~%s~%s~%s~%s~%s NAT %s TYP %s PATTYP %s  cat %s typ %s id %s norm %s nat_cf %s\n",
      pbd_InRecOwner[PER_CTR_NF],pbd_InRecOwner[PER_END_NT],
      pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecOwner[PER_UW_NT],
      pbd_InRecChild[GTSII_NAT_CF],pbd_InRecChild[GTSII_TYP_CT],pbd_InRecChild[GTSII_PATTYP_CT],
      pbd_InRecChild[GTSII3_PATCAT_CT],pbd_InRecChild[GTSII3_PATTYP_CT],pbd_InRecChild[GTSII3_PATTERN_ID] ,
      pbd_InRecChild[GTSII3_NORME_CF],
      pbd_InRecOwner[PER_CTRNAT_CT] );
    n_WriteLogLevel(1,sz_message);	 
*/
	
	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GTSII_CTR_NF] ) ) != 0 ) return ret;
	if ( ( ret = atoi( pbd_InRecOwner[PER_END_NT] ) - atoi(pbd_InRecChild[GTSII_END_NT] ) ) != 0 ) return ret;
	if ( ( ret = atoi( pbd_InRecOwner[PER_SEC_NF] ) - atoi(pbd_InRecChild[GTSII_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GTSII_UWY_NF] ) ) != 0 ) return ret;
	if ( ( ret = atoi( pbd_InRecOwner[PER_UW_NT]) - atoi(pbd_InRecChild[GTSII_UW_NT] ) ) != 0 ) return ret;




	RETURN_VAL( 0 );
}


int n_ConditionSyncGTSIIRNP(
        char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
        char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
        int ret;

        DEBUT_FCT( "n_ConditionSyncGTSIIRNP" );

        sprintf(sz_message,"\n--> n_ConditionSyncGTSIIRNP -- CTR_NF END_NT sec UWY_NF UW_NT ~%s~%s~%s~%s~%s NAT %s TYP %s PATTYP %s  cat %s typ %s id %s norm %s nat_cf %s\n",
        pbd_InRecOwner[PER_CTR_NF],pbd_InRecOwner[PER_END_NT],
        pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecOwner[PER_UW_NT],
        pbd_InRecChild[GTSII_NAT_CF],pbd_InRecChild[GTSII_TYP_CT],pbd_InRecChild[GTSII_PATTYP_CT],
        pbd_InRecChild[GTSII3_PATCAT_CT],pbd_InRecChild[GTSII3_PATTYP_CT],pbd_InRecChild[GTSII3_PATTERN_ID] ,
        pbd_InRecChild[GTSII3_NORME_CF],
        pbd_InRecOwner[PER_CTRNAT_CT] );

        n_WriteLogLevel(1,sz_message);

        if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GTSII_RETCTR_NF] ) ) != 0 ) return ret;
        if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GTSII_RTY_NF] ) ) != 0 ) return ret;
        if ( ( ret = atoi( pbd_InRecOwner[PER_SEC_NF] ) - atoi( pbd_InRecChild[GTSII_RETSEC_NF] ) ) != 0 ) return ret ;
        if ( ( ret = atoi( pbd_InRecOwner[PER_END_NT] ) - atoi(pbd_InRecChild[GTSII_RETEND_NT]  ) ) != 0 ) return ret;
        if ( ( ret = atoi( pbd_InRecOwner[PER_UW_NT] ) - atoi(pbd_InRecChild[GTSII_RETUW_NT] ) ) != 0 ) return ret;


        RETURN_VAL( 0 );
}




int n_ConditionSyncGTSIIRP(
        char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
        char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
        int ret;

        DEBUT_FCT( "n_ConditionSyncGTSIIRP" );

        sprintf(sz_message,"\n--> n_ConditionSyncGTSIIRP -- CTR_NF END_NT sec UWY_NF UW_NT ~%s~%s~%s~%s~%s NAT %s TYP %s PATTYP %s  cat %s typ %s id %s norm %s nat_cf %s\n",
        pbd_InRecOwner[PER_CTR_NF],pbd_InRecOwner[PER_END_NT],
        pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecOwner[PER_UW_NT],
        pbd_InRecChild[GTSII_NAT_CF],pbd_InRecChild[GTSII_TYP_CT],pbd_InRecChild[GTSII_PATTYP_CT],
        pbd_InRecChild[GTSII3_PATCAT_CT],pbd_InRecChild[GTSII3_PATTYP_CT],pbd_InRecChild[GTSII3_PATTERN_ID] ,
        pbd_InRecChild[GTSII3_NORME_CF],
        pbd_InRecOwner[PER_CTRNAT_CT] );

        n_WriteLogLevel(1,sz_message);

        if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GTSII_RETCTR_NF] ) ) != 0 ) return ret;
        if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GTSII_RTY_NF] ) ) != 0 ) return ret;
        if ( ( ret = atoi( pbd_InRecOwner[PER_SEC_NF] ) - atoi( pbd_InRecChild[GTSII_RETSEC_NF] ) ) != 0 ) return ret ;
        if ( ( ret = atoi( pbd_InRecOwner[PER_END_NT] ) - atoi(pbd_InRecChild[GTSII_RETEND_NT]  ) ) != 0 ) return ret;
        if ( ( ret = atoi( pbd_InRecOwner[PER_UW_NT] ) - atoi(pbd_InRecChild[GTSII_RETUW_NT] ) ) != 0 ) return ret;


        RETURN_VAL( 0 );
}



int n_ConditionSyncRETSEC(
        char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
        char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
        int ret;

        DEBUT_FCT( "n_ConditionSyncRETSEC" );


        if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[RETSEC_RETCTR_NF] ) ) != 0 ) return ret;
        if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[RETSEC_RTY_NF] ) ) != 0 ) return ret;
        if ( ( ret = atoi( pbd_InRecOwner[PER_SEC_NF] ) - atoi( pbd_InRecChild[RETSEC_RETSEC_NF] ) ) != 0 ) return ret ;
        /*if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[RETSEC_RETEND_NT] ) ) != 0 ) return ret;
        if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[RETSEC_RETUW_NT] ) ) != 0 ) return ret;
	*/



        RETURN_VAL( 0 );
}





/*==============================================================================
objet :
  fonction de test de rupture de niveau 1

retour :
  0 ---> pas de rupture
  sinon     ---> rupture
==============================================================================*/
int n_IsR1GTSII(
  char **pbd_InRec ,  /* adresse de la ligne en avance */
  char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
  int ret ;

  DEBUT_FCT( "n_IsR1GTSII" ) ;

if ( ( ret = strcmp( pbd_InRec[GTSII_PLC_NT], pbd_InRec_Cur[GTSII_PLC_NT] ) ) != 0 ) RETURN_VAL (ret) ;
if ( ( ret = strcmp( pbd_InRec[GTSII_RTO_NF], pbd_InRec_Cur[GTSII_RTO_NF] ) ) != 0 ) RETURN_VAL (ret) ;
if ( ( ret = strcmp( pbd_InRec[GTSII_ACMTRS_NT], pbd_InRec_Cur[GTSII_ACMTRS_NT] ) ) != 0 ) RETURN_VAL (ret) ;
	
	
	
  RETURN_VAL( 0 ) ;
}



int n_IsR1GTSIIRNP(
  char **pbd_InRec ,  /* adresse de la ligne en avance */
  char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
  int ret ;

  DEBUT_FCT( "n_IsR1GTSIIRNP" ) ;

if ( ( ret = strcmp( pbd_InRec[GTSII_PLC_NT], pbd_InRec_Cur[GTSII_PLC_NT] ) ) != 0 ) RETURN_VAL (ret) ;
if ( ( ret = strcmp( pbd_InRec[GTSII_RTO_NF], pbd_InRec_Cur[GTSII_RTO_NF] ) ) != 0 ) RETURN_VAL (ret) ;
if ( ( ret = strcmp( pbd_InRec[GTSII_ACMTRS_NT], pbd_InRec_Cur[GTSII_ACMTRS_NT] ) ) != 0 ) RETURN_VAL (ret) ;



  RETURN_VAL( 0 ) ;
}


int n_IsR1GTSIIRP(
  char **pbd_InRec ,  /* adresse de la ligne en avance */
  char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
  int ret ;

  DEBUT_FCT( "n_IsR1GTSIIRP" ) ;

if ( ( ret = strcmp( pbd_InRec[GTSII_PLC_NT], pbd_InRec_Cur[GTSII_PLC_NT] ) ) != 0 ) RETURN_VAL (ret) ;
if ( ( ret = strcmp( pbd_InRec[GTSII_RTO_NF], pbd_InRec_Cur[GTSII_RTO_NF] ) ) != 0 ) RETURN_VAL (ret) ;
if ( ( ret = strcmp( pbd_InRec[GTSII_ACMTRS_NT], pbd_InRec_Cur[GTSII_ACMTRS_NT] ) ) != 0 ) RETURN_VAL (ret) ;



  RETURN_VAL( 0 ) ;
}





/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGTSII(
	char **pbd_InRecOwner , /* adresse de la ligne du maitre */
	char **pbd_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneGTSII" );


	sprintf(sz_message,"--> n_ActionLigneGTSII %s -- CTR_NF END_NT sec UWY_NF UW_NT ~%s~%s~%s~%s~%s NAT %s TYP %s PATTYP %s  cat %s typ %s id %s norm %s nat_cf %s acmtrs %s \n",
      pbd_InRecOwner[PER_CTRTYP_CT],
      pbd_InRecOwner[PER_CTR_NF],pbd_InRecOwner[PER_END_NT],
      pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecOwner[PER_UW_NT],
      pbd_InRecChild[GTSII_NAT_CF],pbd_InRecChild[GTSII_TYP_CT],pbd_InRecChild[GTSII_PATTYP_CT],
      pbd_InRecChild[GTSII3_PATCAT_CT],pbd_InRecChild[GTSII3_PATTYP_CT],pbd_InRecChild[GTSII3_PATTERN_ID] ,
      pbd_InRecChild[GTSII3_NORME_CF],
      pbd_InRecOwner[PER_CTRNAT_CT] ,
      pbd_InRecChild[GTSII_ACMTRS_NT] ); 
  n_WriteLogLevel(1,sz_message);



if ( strcmp(pbd_InRecOwner[PER_CTRTYP_CT],"RET" ) != 0 )  
	n_RA_processing(pbd_InRecOwner ,pbd_InRecChild ) ;	


	RETURN_VAL( OK );
}


int n_ActionLigneGTSIIRNP(
        char **pbd_InRecOwner , /* adresse de la ligne du maitre */
        char **pbd_InRecChild ) /* adresse de la ligne de l'esclave */
{

        DEBUT_FCT( "n_ActionLigneGTSIIRNP" );


        sprintf(sz_message,"--> n_ActionLigneGTSIIRNP %s -- CTR_NF END_NT sec UWY_NF UW_NT ~%s~%s~%s~%s~%s NAT %s TYP %s PATTYP %s  cat %s typ %s id %s norm %s nat_cf %s acmtrs %s CTRA %s \n",
      pbd_InRecOwner[PER_CTRTYP_CT],
      pbd_InRecOwner[PER_CTR_NF],pbd_InRecOwner[PER_END_NT],
      pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecOwner[PER_UW_NT],
      pbd_InRecChild[GTSII_NAT_CF],pbd_InRecChild[GTSII_TYP_CT],pbd_InRecChild[GTSII_PATTYP_CT],
      pbd_InRecChild[GTSII3_PATCAT_CT],pbd_InRecChild[GTSII3_PATTYP_CT],pbd_InRecChild[GTSII3_PATTERN_ID] ,
      pbd_InRecChild[GTSII3_NORME_CF],
      pbd_InRecOwner[PER_CTRNAT_CT] ,
      pbd_InRecChild[GTSII_ACMTRS_NT], 
      pbd_InRecChild[GTSII_CTR_NF] );
  n_WriteLogLevel(1,sz_message);



if ( strcmp(pbd_InRecOwner[PER_CTRTYP_CT],"RET" ) == 0 && strcmp(pbd_InRecOwner[PER_CTRNAT_CT] , "N") == 0  )  
        n_RA_processing(pbd_InRecOwner ,pbd_InRecChild ) ;



        RETURN_VAL( OK );
}



int n_ActionLigneGTSIIRP(
        char **pbd_InRecOwner , /* adresse de la ligne du maitre */
        char **pbd_InRecChild ) /* adresse de la ligne de l'esclave */
{


        DEBUT_FCT( "n_ActionLigneGTSIIRP" );


        sprintf(sz_message,"--> n_ActionLigneGTSIIRP %s -- CTR_NF END_NT sec UWY_NF UW_NT ~%s~%s~%s~%s~%s NAT %s TYP %s PATTYP %s  cat %s typ %s id %s norm %s nat_cf %s acmtrs %s CTRA %s \n",
      pbd_InRecOwner[PER_CTRTYP_CT],
      pbd_InRecOwner[PER_CTR_NF],pbd_InRecOwner[PER_END_NT],
      pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecOwner[PER_UW_NT],
      pbd_InRecChild[GTSII_NAT_CF],pbd_InRecChild[GTSII_TYP_CT],pbd_InRecChild[GTSII_PATTYP_CT],
      pbd_InRecChild[GTSII3_PATCAT_CT],pbd_InRecChild[GTSII3_PATTYP_CT],pbd_InRecChild[GTSII3_PATTERN_ID] ,
      pbd_InRecChild[GTSII3_NORME_CF],
      pbd_InRecOwner[PER_CTRNAT_CT] ,
      pbd_InRecChild[GTSII_ACMTRS_NT], 
      pbd_InRecChild[GTSII_CTR_NF] );
  n_WriteLogLevel(1,sz_message);



 if ( strcmp(pbd_InRecOwner[PER_CTRTYP_CT],"RET" ) == 0 && strcmp(pbd_InRecOwner[PER_CTRNAT_CT] , "P") == 0 )  
     n_RA_processing(pbd_InRecOwner ,pbd_InRecChild ) ;


     RETURN_VAL( OK );
}




/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRuptGTSII(
	char **pbd_InRecOwner , /* adresse de la ligne du maitre */
	char **pbd_InRecChild ) /* adresse de la ligne de l'esclave */
{
  
	DEBUT_FCT( "n_ActionFirstRuptGTSII" );



/* STOP using rupture level for Assumed, calculation done at ActionLigne  

sprintf(sz_message,"--> n_ActionFirstRuptGTSII RETRO %s -- CTR_NF END_NT sec UWY_NF UW_NT ~%s~%s~%s~%s~%s PLC %s RTO %s typ %s  NAT %s TYP %s PATTYP %s  cat %s typ %s id %s norm %s nat_cf %s acmtrs %s \n",
      pbd_InRecOwner[PER_CTRTYP_CT],
      pbd_InRecOwner[PER_CTR_NF],pbd_InRecOwner[PER_END_NT],
      pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecOwner[PER_UW_NT],
      pbd_InRecChild[GTSII_PLC_NT],pbd_InRecChild[GTSII_RTO_NF],  pbd_InRecOwner[PER_CTRTYP_CT],    
      pbd_InRecChild[GTSII_NAT_CF],pbd_InRecChild[GTSII_TYP_CT],pbd_InRecChild[GTSII_PATTYP_CT],
      pbd_InRecChild[GTSII3_PATCAT_CT],pbd_InRecChild[GTSII3_PATTYP_CT],pbd_InRecChild[GTSII3_PATTERN_ID] ,
      pbd_InRecChild[GTSII3_NORME_CF],
      pbd_InRecOwner[PER_CTRNAT_CT] ,
      pbd_InRecChild[GTSII_ACMTRS_NT] ); 

n_WriteLogLevel(1,sz_message);




if ( strcmp(pbd_InRecOwner[PER_CTRTYP_CT],"RET" ) == 0 )  
	n_RA_processing(pbd_InRecOwner ,pbd_InRecChild ) ;	


*/


	RETURN_VAL( OK );
}


int n_ActionFirstRuptGTSIIRNP(
        char **pbd_InRecOwner , /* adresse de la ligne du maitre */
        char **pbd_InRecChild ) /* adresse de la ligne de l'esclave */
{

        DEBUT_FCT( "n_ActionFirstRuptGTSIIRNP" );


/* Stop using this rupture , calculation done at ActionLigne 

sprintf(sz_message,"--> n_ActionFirstRuptGTSIIRNP RETRO %s -- CTR_NF END_NT sec UWY_NF UW_NT ~%s~%s~%s~%s~%s PLC %s RTO %s typ %s  NAT %s TYP %s PATTYP %s  cat %s typ %s id %s norm %s nat_cf %s acmtrs %s CTRA %s \n",
      pbd_InRecOwner[PER_CTRTYP_CT],
      pbd_InRecOwner[PER_CTR_NF],pbd_InRecOwner[PER_END_NT],
      pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecOwner[PER_UW_NT],
      pbd_InRecChild[GTSII_PLC_NT],pbd_InRecChild[GTSII_RTO_NF],  pbd_InRecOwner[PER_CTRTYP_CT],
      pbd_InRecChild[GTSII_NAT_CF],pbd_InRecChild[GTSII_TYP_CT],pbd_InRecChild[GTSII_PATTYP_CT],
      pbd_InRecChild[GTSII3_PATCAT_CT],pbd_InRecChild[GTSII3_PATTYP_CT],pbd_InRecChild[GTSII3_PATTERN_ID] ,
      pbd_InRecChild[GTSII3_NORME_CF],
      pbd_InRecOwner[PER_CTRNAT_CT] ,
      pbd_InRecChild[GTSII_ACMTRS_NT] ,
      pbd_InRecChild[GTSII_CTR_NF] );

n_WriteLogLevel(1,sz_message);


if ( strcmp(pbd_InRecOwner[PER_CTRTYP_CT],"RET" ) == 0 )
        n_RA_processing(pbd_InRecOwner ,pbd_InRecChild ) ;

*/


        RETURN_VAL( OK );
}



int n_ActionFirstRuptGTSIIRP(
        char **pbd_InRecOwner , /* adresse de la ligne du maitre */
        char **pbd_InRecChild ) /* adresse de la ligne de l'esclave */
{

        DEBUT_FCT( "n_ActionFirstRuptGTSIIRP" );


/* Stop using this rupture , calculation done at ActionLigne 

sprintf(sz_message,"--> n_ActionFirstRuptGTSIIRP RETRO %s -- CTR_NF END_NT sec UWY_NF UW_NT ~%s~%s~%s~%s~%s PLC %s RTO %s typ %s  NAT %s TYP %s PATTYP %s  cat %s typ %s id %s norm %s nat_cf %s acmtrs %s CTRA %s \n",
      pbd_InRecOwner[PER_CTRTYP_CT],
      pbd_InRecOwner[PER_CTR_NF],pbd_InRecOwner[PER_END_NT],
      pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecOwner[PER_UW_NT],
      pbd_InRecChild[GTSII_PLC_NT],pbd_InRecChild[GTSII_RTO_NF],  pbd_InRecOwner[PER_CTRTYP_CT],
      pbd_InRecChild[GTSII_NAT_CF],pbd_InRecChild[GTSII_TYP_CT],pbd_InRecChild[GTSII_PATTYP_CT],
      pbd_InRecChild[GTSII3_PATCAT_CT],pbd_InRecChild[GTSII3_PATTYP_CT],pbd_InRecChild[GTSII3_PATTERN_ID] ,
      pbd_InRecChild[GTSII3_NORME_CF],
      pbd_InRecOwner[PER_CTRNAT_CT] ,
      pbd_InRecChild[GTSII_ACMTRS_NT] ,
      pbd_InRecChild[GTSII_CTR_NF] );

n_WriteLogLevel(1,sz_message);


if ( strcmp(pbd_InRecOwner[PER_CTRTYP_CT],"RET" ) == 0 )
        n_RA_processing(pbd_InRecOwner ,pbd_InRecChild ) ;

*/

        RETURN_VAL( OK );
}





/*==============================================================================
objet:
        Calculation of Risk Adjustment Initial Amount

==============================================================================*/
int n_RA_processing    ( char **pbd_InRecOwner, char **pbd_InRecChild )
{
int indice;
char sz_domain[10], sz_pattyp_ct[7] , sz_Amt[30]; //, sz_seg_test[30];
double prmrat_R , rsrvrat_R, kd_Initial_Amount, kd_basis_amount, kd_Total_Amount,kd_basis_total_amount;
char  sz_Vide[2] = "" ;
char  sz_Acy[6] ;    
char  sz_Mth[4] ;   
char  sz_Day[4] ;    
char  sz_Seglob[30];
char  sz_SegNF[30];
char  c_ctrnat_cf; 
int  sz_ssd_cf;


	

DEBUT_FCT( "n_RA_processing" );

prmrat_R  = 0.0 ; 
rsrvrat_R = 0.0 ;
kd_Initial_Amount = 0.0;
kd_Total_Amount = 0.0;
kd_basis_amount = 0.0 ;
kd_basis_total_amount = 0.0;
strcpy(sz_pattyp_ct,"");
strcpy(sz_domain,"");
strcpy(sz_SegNF,"");





sprintf(sz_message,"--> n_RA_processing  %s CTR END_NT SEC UWY_NF UW_NT ~%s~%s~%s~%s~%s PER_SEG_NF (%s) GTSII_SEG_NF(%s) CTRGRO_SEG_NF(%s) \n",
      pbd_InRecOwner[PER_CTRTYP_CT],
      pbd_InRecOwner[PER_CTR_NF],pbd_InRecOwner[PER_END_NT],
      pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecOwner[PER_UW_NT],
      pbd_InRecOwner[PER_SEG_NF], pbd_InRecChild[GTSII_SEG_NF] , pbd_InRecChild[GTSII_CTRGRO_SEGNF] );     
n_WriteLogLevel(1,sz_message);

if ( strcmp(pbd_InRecOwner[PER_CTRTYP_CT],"RET" ) != 0 ) // Assumed case
	{
      strcpy(sz_domain,"Gross"); // Assumed
      kd_basis_amount = atof(pbd_InRecChild[GTSII_AMT_M]) ;
	  kd_basis_total_amount = atof(pbd_InRecChild[GTSII3_TOTAUX_M]);
      strcpy(ksz_GRPGRP3_NT,pbd_InRecChild[GTSII_GRPGRP3_NT] );
      c_ctrnat_cf = *pbd_InRecOwner[PER_CTRNAT_CT];
	  sz_ssd_cf = (int) atoi(pbd_InRecOwner[PER_SSD_CF]);
 }
else if ( strcmp(pbd_InRecOwner[PER_CTRTYP_CT],"RET" ) == 0 && strcmp(pbd_InRecOwner[PER_CTRNAT_CT],"P") == 0) 
{ 
     strcpy(sz_domain,"Gross");
     kd_basis_amount = atof(pbd_InRecChild[GTSII_RETAMT_M]) ;
	 kd_basis_total_amount = atof(pbd_InRecChild[GTSII3_TOTAUX_M]);
     strcpy(ksz_GRPGRP3_NT,pbd_InRecChild[GTSII_GRPGRP3_NT] );
     c_ctrnat_cf = *pbd_InRecChild[GTSII_CTRNAT_ACCEPT] ;
	 sz_ssd_cf = (int) atoi(pbd_InRecChild[GTSII_SSD_CF_ACCEPT]) ;
}
else if ( strcmp(pbd_InRecOwner[PER_CTRTYP_CT],"RET" ) == 0 && strcmp(pbd_InRecOwner[PER_CTRNAT_CT],"N") == 0) 
{
     strcpy(sz_domain,"RetroNP");
     kd_basis_amount = atof(pbd_InRecChild[GTSII_RETAMT_M]) ;
	 kd_basis_total_amount = atof(pbd_InRecChild[GTSII3_TOTAUX_M]);
     c_ctrnat_cf = *pbd_InRecOwner[PER_CTRNAT_CT];
	 sz_ssd_cf = (int) atoi(pbd_InRecOwner[PER_SSD_CF]);
}
else
{
    strcpy(sz_domain,"");
    kd_basis_amount = 0.0 ;
	kd_basis_total_amount = 0.0;
	c_ctrnat_cf = 0;
}		



/* calculate Incurred RA initial amount , using reserves ratio */ 
if ( strcmp(pbd_InRecChild[GTSII_ACMTRS3_NT_ORIG],"3010") == 0 ) 
{	
  
   indice = n_RechTRARAT( sz_ssd_cf , (short) atoi(pbd_InRecOwner[PER_ACCESB_CF]) , ksz_GRPGRP3_NT , c_ctrnat_cf, sz_domain);
   //indice = n_RechTRARAT( 24 , 4, "1255", 'F', "");

  if ( indice != -1 ) {
    // [025] spira 112083 - new ratio RALIC_R and RALRC_R for RAP
    if (strcmp(Ksz_patcat_ct,"RAP") == 0) {
        rsrvrat_R = Ktbd_rarat[indice].RALIC_R;
    } else {
        rsrvrat_R = Ktbd_rarat[indice].RSRVRAT_R;
    }
  }


  // [024] [026]
	//kd_Initial_Amount =  kd_basis_total_amount * rsrvrat_R ;
    kd_Initial_Amount =  atof(pbd_InRecChild[GTSII3_ACMAMT_MC]) * rsrvrat_R ;

	sprintf(sz_message,"%s%c~%s~%s~%s~%s~%s~Rratio301 %.8f basis %.5f RA %.5f sgmt %s dom %s nat %c %d %d %s",
      pbd_InRecOwner[PER_CTRTYP_CT],*pbd_InRecOwner[PER_CTRNAT_CT],pbd_InRecOwner[PER_CTR_NF],pbd_InRecOwner[PER_END_NT],
      pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecOwner[PER_UW_NT],
      rsrvrat_R, kd_basis_amount , kd_Initial_Amount ,  ksz_GRPGRP3_NT ,sz_domain,c_ctrnat_cf,sz_ssd_cf,atoi(pbd_InRecOwner[PER_ACCESB_CF]), pbd_InRecChild[GTSII_CTR_NF]);     
    n_WriteLogLevel(0,sz_message);

	//kd_Total_Amount =  kd_basis_total_amount * rsrvrat_R ;
	kd_Total_Amount =  atof(pbd_InRecChild[GTSII3_ACMAMT_MC]) * rsrvrat_R ;

	sprintf(sz_message,"%s%c~%s~%s~%s~%s~%s~Rratio301 %.8f basisT %.5f RA %.5f sgmt %s dom %s nat %c %d %d %s",
      pbd_InRecOwner[PER_CTRTYP_CT],*pbd_InRecOwner[PER_CTRNAT_CT],pbd_InRecOwner[PER_CTR_NF],pbd_InRecOwner[PER_END_NT],
      pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecOwner[PER_UW_NT],
      rsrvrat_R, kd_basis_total_amount , kd_Total_Amount ,  ksz_GRPGRP3_NT ,sz_domain,c_ctrnat_cf,sz_ssd_cf,atoi(pbd_InRecOwner[PER_ACCESB_CF]), pbd_InRecChild[GTSII_CTR_NF]);     
    n_WriteLogLevel(0,sz_message);

}	


/* calculate Remaining RA initial amount , using premium ratio */ 
if ( strcmp(pbd_InRecChild[GTSII_ACMTRS3_NT_ORIG],"3201") == 0) 
{	
   indice = n_RechTRARAT( sz_ssd_cf , (short) atoi(pbd_InRecOwner[PER_ACCESB_CF]) , ksz_GRPGRP3_NT , c_ctrnat_cf, sz_domain);
   //indice = n_RechTRARAT( 24 , 4, "1255", 'F', "");

  if ( indice != -1 ) {
    // [025] spira 112083 - new ratio RALIC_R and RALRC_R for RAP
    if (strcmp(Ksz_patcat_ct,"RAP") == 0) {
        prmrat_R = Ktbd_rarat[indice].RALRC_R;
    } else {
        prmrat_R = Ktbd_rarat[indice].PRMRAT_R;
    }
  }

  // [024] [026]
	//kd_Initial_Amount =  kd_basis_total_amount * prmrat_R ;
    kd_Initial_Amount = atof(pbd_InRecChild[GTSII3_ACMAMT_MC]) * prmrat_R ;
	
	sprintf(sz_message,"%s%c~%s~%s~%s~%s~%s~Pratio320 %.8f basis %.5f RA %.5f sgmt %s dom %s nat %c %d %d %s",
      pbd_InRecOwner[PER_CTRTYP_CT],*pbd_InRecOwner[PER_CTRNAT_CT],pbd_InRecOwner[PER_CTR_NF],pbd_InRecOwner[PER_END_NT],
      pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecOwner[PER_UW_NT],
      prmrat_R, kd_basis_amount , kd_Initial_Amount , ksz_GRPGRP3_NT ,sz_domain, c_ctrnat_cf,sz_ssd_cf,atoi(pbd_InRecOwner[PER_ACCESB_CF]),pbd_InRecChild[GTSII_CTR_NF]);     
    n_WriteLogLevel(0,sz_message);

	//026 kd_Total_Amount =  kd_basis_total_amount * prmrat_R ;
	kd_Total_Amount =  atof(pbd_InRecChild[GTSII3_ACMAMT_MC]) * prmrat_R ;
	
  	  sprintf(sz_message,"%s%c~%s~%s~%s~%s~%s~Pratio320 %.8f basisT %.5f RA %.5f sgmt %s dom %s nat %c %d %d %s",
      pbd_InRecOwner[PER_CTRTYP_CT],*pbd_InRecOwner[PER_CTRNAT_CT],pbd_InRecOwner[PER_CTR_NF],pbd_InRecOwner[PER_END_NT],
      pbd_InRecOwner[PER_SEC_NF], pbd_InRecOwner[PER_UWY_NF], pbd_InRecOwner[PER_UW_NT],
      prmrat_R, kd_basis_total_amount , kd_Total_Amount , ksz_GRPGRP3_NT ,sz_domain, c_ctrnat_cf,sz_ssd_cf,atoi(pbd_InRecOwner[PER_ACCESB_CF]),pbd_InRecChild[GTSII_CTR_NF]);     
      n_WriteLogLevel(0,sz_message);
	
}


/***************** Ecriture dans les fichiers de sortie  */
if ( fabs(kd_Initial_Amount) > 0.01  )
{

sprintf( sz_Amt, "%-.3f", kd_Initial_Amount ) ;
pbd_InRecChild[GTSII_AMT_M] = sz_Amt ;
pbd_InRecChild[GTSII_ACMAMT_MC] = sz_Amt;
pbd_InRecChild[GTSII_RETAMT_M] =sz_Amt ;
pbd_InRecChild[GTSII_RETINTAMT_M] =sz_Amt ;


/* Eclatement de la date AAAAMMJJ en 3 chaines de caractere */
sscanf( Ksz_iclodat_d, "%4s%2s%2s", sz_Acy, sz_Mth, sz_Day ) ;
pbd_InRecChild[GTSII_BALSHEY_NF] = sz_Acy;
pbd_InRecChild[GTSII_BALSHRMTH_NF] = sz_Mth;
pbd_InRecChild[GTSII_BALSHRDAY_NF] = sz_Day;

if ( strcmp(pbd_InRecOwner[PER_CTRTYP_CT],"RET" ) == 0 )
		strcpy(sz_pattyp_ct , "ICRET") ;
else	strcpy(sz_pattyp_ct , "ICACC") ;		
	
pbd_InRecChild[GTSII_PATTYP_CT] = sz_pattyp_ct  ;


// for test
//strcpy(sz_seg_test , "MNCASUAI202019");
//pbd_InRecChild[GTSII_SEGLOB_CF] = sz_seg_test; 
	

if ( strcmp(pbd_InRecOwner[PER_CTRTYP_CT],"RET" ) == 0 && strcmp(pbd_InRecOwner[PER_CTRNAT_CT],"P") == 0  ) // retroP
{
   sprintf(sz_SegNF,"%s",	pbd_InRecChild[GTSII_CTRGRO_SEGNF]) ;
   
	if ( strlen(trim(pbd_InRecChild[GTSII_CTRGRO_SEGNF] ))== 0 )
         sprintf(sz_Seglob, "*%s",   pbd_InRecChild[GTSII_UWY_NF] );   
	else sprintf(sz_Seglob, "%s%s", pbd_InRecChild[GTSII_CTRGRO_SEGNF] , pbd_InRecChild[GTSII_UWY_NF]  );
  	  
}
else if ( strcmp(pbd_InRecOwner[PER_CTRTYP_CT],"RET" ) == 0 && strcmp(pbd_InRecOwner[PER_CTRNAT_CT],"N") == 0  ) // retroNP
{
    sprintf(sz_SegNF,"%s" , pbd_InRecChild[GTSII_SEG_NF] ) ;
	sprintf(sz_Seglob,"%s%s", pbd_InRecOwner[PER_LOB_CF],pbd_InRecChild[GTSII_RTY_NF]);    
}
else // Assumed 	
{
    sprintf(sz_SegNF,"%s" , pbd_InRecChild[GTSII_SEG_NF] ) ;
	
  if ( strlen(trim(pbd_InRecOwner[PER_SEG_NF]))== 0 )
      {
       sprintf(sz_Seglob, "*%s",   pbd_InRecChild[GTSII_UWY_NF] );   
      }
  else
      {
       sprintf(sz_Seglob, "%s%s", pbd_InRecOwner[PER_SEG_NF],  pbd_InRecChild[GTSII_UWY_NF] ); 
      }
}

	  

pbd_InRecChild[GTSII_SEGLOB_CF] = sz_Seglob  ;
pbd_InRecChild[GTSII_SEG_NF] = sz_SegNF;
	 
//pbd_InRecChild[GTSII_ACMTRS_NT] = pbd_InRecChild[GTSII_ACMTRS3_NT_ORIG] ;
pbd_InRecChild[GTSII_ACMTRS3_NT] = sz_Vide ;

// write SII initial amount 	
n_WriteCols(Kp_OutputFilResSii, pbd_InRecChild,'~', 52 ,	
GTSII_SSD_CF ,
GTSII_ESB_CF ,			  
GTSII_BALSHEY_NF ,			  
GTSII_BALSHRMTH_NF ,
GTSII_BALSHRDAY_NF ,
GTSII_TRNCOD_CF ,
GTSII_DBLTRNCOD_CF ,
GTSII_CTR_NF ,
GTSII_END_NT ,
GTSII_SEC_NF ,
GTSII_UWY_NF ,
GTSII_UW_NT ,
GTSII_OCCYEA_NF ,
GTSII_ACY_NF ,
GTSII_SCOSTRMTH_NF ,
GTSII_SCOENDMTH_NF ,
GTSII_CLM_NF ,
GTSII_CUR_CF ,
GTSII_AMT_M ,
GTSII_CED_NF ,
GTSII_BRK_NF ,
GTSII_PAY_NF ,
GTSII_KEY_NF ,
GTSII_RETCTR_NF ,
GTSII_RETEND_NT ,
GTSII_RETSEC_NF ,
GTSII_RTY_NF ,
GTSII_RETUW_NT ,
GTSII_RETOCCYEA_NF ,
GTSII_RETACY_NF ,
GTSII_RETSCOSTRMTH_NF ,
GTSII_RETSCOENDMTH_NF ,
GTSII_RCL_NF ,
GTSII_RETCUR_CF ,
GTSII_RETAMT_M ,
GTSII_PLC_NT ,
GTSII_RTO_NF ,
GTSII_INT_NF ,
GTSII_RETPAY_NF ,
GTSII_RETKEY_CF ,
GTSII_RETINTAMT_M ,
GTSII_ACMTRS_NT ,
GTSII_ACMAMT_MC ,
GTSII_ACMCUR_CF ,
GTSII_PRS_CF ,
GTSII_SEG_NF ,
GTSII_LOB_CF ,
GTSII_NAT_CF ,
GTSII_TYP_CT ,
GTSII_PATTYP_CT ,
GTSII_SEGLOB_CF ,
GTSII_ACMTRS3_NT_ORIG 
);

//################################## write TL initial amount  ################################## 
// if ( strcmp(Ksz_context_ct,"STD") == 0 ) 
// {	
// 	if ( strcmp(pbd_InRecChild[GTSII_ACMTRS3_NT_ORIG],"3010") == 0 ) 
// 		writeLine(pbd_InRecChild, Ksz_iclodat_d , "42781", pbd_InRecChild[GTSII_AMT_M]  ,"3173");

// 	if ( strcmp(pbd_InRecChild[GTSII_ACMTRS3_NT_ORIG],"3201") == 0 ) 
// 		writeLine(pbd_InRecChild, Ksz_iclodat_d , "42780", pbd_InRecChild[GTSII_AMT_M]  ,"3172");
// }

// if ( strcmp(Ksz_context_ct,"INI") == 0 ) 
// {	
// 	if ( strcmp(pbd_InRecChild[GTSII_ACMTRS3_NT_ORIG],"3201") == 0 ) 
// 		writeLine(pbd_InRecChild, Ksz_iclodat_d , "42770", pbd_InRecChild[GTSII_AMT_M]  ,"3174");
// }
//################################## end write TL initial amount  #################################



//##################################  write SII total amount ########################################
sprintf( sz_Amt, "%-.3f", kd_Total_Amount ) ;
pbd_InRecChild[GTSII_AMT_M] = sz_Amt ;
pbd_InRecChild[GTSII_ACMAMT_MC] = sz_Amt;
pbd_InRecChild[GTSII_RETAMT_M] =sz_Amt ;
pbd_InRecChild[GTSII_RETINTAMT_M] =sz_Amt ;

n_WriteCols(Kp_OutputFilTotal, pbd_InRecChild,'~', 52 ,	
GTSII_SSD_CF ,
GTSII_ESB_CF ,			  
GTSII_BALSHEY_NF ,			  
GTSII_BALSHRMTH_NF ,
GTSII_BALSHRDAY_NF ,
GTSII_TRNCOD_CF ,
GTSII_DBLTRNCOD_CF ,
GTSII_CTR_NF ,
GTSII_END_NT ,
GTSII_SEC_NF ,
GTSII_UWY_NF ,
GTSII_UW_NT ,
GTSII_OCCYEA_NF ,
GTSII_ACY_NF ,
GTSII_SCOSTRMTH_NF ,
GTSII_SCOENDMTH_NF ,
GTSII_CLM_NF ,
GTSII_CUR_CF ,
GTSII_AMT_M ,
GTSII_CED_NF ,
GTSII_BRK_NF ,
GTSII_PAY_NF ,
GTSII_KEY_NF ,
GTSII_RETCTR_NF ,
GTSII_RETEND_NT ,
GTSII_RETSEC_NF ,
GTSII_RTY_NF ,
GTSII_RETUW_NT ,
GTSII_RETOCCYEA_NF ,
GTSII_RETACY_NF ,
GTSII_RETSCOSTRMTH_NF ,
GTSII_RETSCOENDMTH_NF ,
GTSII_RCL_NF ,
GTSII_RETCUR_CF ,
GTSII_RETAMT_M ,
GTSII_PLC_NT ,
GTSII_RTO_NF ,
GTSII_INT_NF ,
GTSII_RETPAY_NF ,
GTSII_RETKEY_CF ,
GTSII_RETINTAMT_M ,
GTSII_ACMTRS_NT ,
GTSII_ACMAMT_MC ,
GTSII_ACMCUR_CF ,
GTSII_PRS_CF ,
GTSII_SEG_NF ,
GTSII_LOB_CF ,
GTSII_NAT_CF ,
GTSII_TYP_CT ,
GTSII_PATTYP_CT ,
GTSII_SEGLOB_CF ,
GTSII_ACMTRS3_NT_ORIG 
);

//##################################  End write SII total amount ########################################

} /***************** End Ecriture dans les fichiers de sortie  */


	RETURN_VAL( OK );
}



/*==============================================================================
objet:
        Lit le fichier FRARAT et le charge en memoire

==============================================================================*/
int n_ChargerTRARAT( void )
{
        int i = 0 ;


        DEBUT_FCT("n_ChargerTRARAT");

        //printf("\nstart n_ChargerTRARAT") ; fflush(stdout);
        
        char buffer[LGTH_RARAT];
        char **tab=NULL;
        while (fgets( buffer, LGTH_RARAT, Kp_InputFilRaRat)!= NULL)
        {
        //printf("\nn_ChargerTRARAT buffer=[%s] i=%d ", buffer, i  ) ; fflush(stdout);

                tab = split(buffer, SEPARATOR ,1);
                Ktbd_rarat[i].SSD_CF = atoi(tab[RAT_SSD_CF]);
 

                //Pour le segment speciale * on ne prend que ce caractre !
                if ( tab[RAT_SEG_NF][0] == '*')
                        strcpy(Ktbd_rarat[i].SEG_NF, "*");
                else
                        strcpy(Ktbd_rarat[i].SEG_NF, tab[RAT_SEG_NF]);


                Ktbd_rarat[i].ESB_CF = atoi(tab[RAT_ESB_CF]);
                //strcpy(Ktbd_rarat[i].NORME_CF, tab[RAT_NORME_CF]);

                Ktbd_rarat[i].CTRNAT_CT = *tab[RAT_CTRNAT_CT];
                strcpy(Ktbd_rarat[i].DOMAIN_CF, tab[RAT_DOMAIN_CF]);


                Ktbd_rarat[i].PRMRAT_R = atof(tab[RAT_PRMRAT_R]);
                Ktbd_rarat[i].RSRVRAT_R = atof(tab[RAT_RSRVRAT_R]);
                
                // [025] spira 112083 - new ratio RALIC_R and RALRC_R for RAP
                Ktbd_rarat[i].RALIC_R = atof(tab[RAT_RALIC_R]);
                Ktbd_rarat[i].RALRC_R = atof(tab[RAT_RALRC_R]);

                strcpy(Ktbd_rarat[i].SGMT_LS, tab[RAT_SGMT_LS]);

                i++;
                if ( i > NB_RARAT_MAX )
                {
                        sprintf(sz_message,"la taille du tableau Ktbd_rarat depasse la taille allouee %d", i);
                        n_WriteAno(sz_message);
                        RETURN_VAL( i );
                }
       
        }
        
       sprintf(sz_message,"n_ChargerTRARAT nb line = %d", i);
       n_WriteLogLevel(0,sz_message);

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
  
  if (n_DEBUG_LEVEL >= 2)
  {	
  sprintf(sz_message, "n_RechTRARAT before loop c_ssd %d  c_esb_cf %d sz_seg %s c_ctrnat_cf %c sz_domain_cf %s ",
           c_ssd, c_esb_cf , sz_seg , c_ctrnat_cf, sz_domain_cf ); 
  n_WriteLogLevel(2, sz_message )  ;       
  }


  for( n_indice = 0; n_indice < Kn_NbLig_RaRat; n_indice++ )
  {
    // Localisation filiale
    n_ret =  c_ssd - Ktbd_rarat[n_indice].SSD_CF;
    if ( n_ret < 0 ) RETURN_VAL( -1 ) ;
    if ( n_ret > 0 ) continue ;

 	  if (n_DEBUG_LEVEL >= 2)
  	n_WriteLogLevel(2,"ssd match"); 

    // Localisation ESB_CF
    n_ret =  c_esb_cf - Ktbd_rarat[n_indice].ESB_CF;
    if ( n_ret < 0 ) RETURN_VAL( -1 ) ;
    if ( n_ret > 0 ) continue ;

 	  if (n_DEBUG_LEVEL >= 2)
  	n_WriteLogLevel(2,"esb match");
    	
    // Localisation Segment
    if ( strcmp(sz_seg, Ktbd_rarat[n_indice].SGMT_LS) < 0 ) RETURN_VAL( -1 ) ;
    if ( strcmp(sz_seg, Ktbd_rarat[n_indice].SGMT_LS) > 0 ) continue;

 	  if (n_DEBUG_LEVEL >= 2)
  	n_WriteLogLevel(2,"seg_ls match");

    // Localisation contract nature
    n_ret =  c_ctrnat_cf - Ktbd_rarat[n_indice].CTRNAT_CT;
    if ( n_ret < 0 ) RETURN_VAL( -1 ) ;
    if ( n_ret > 0 ) continue ;

 	  if (n_DEBUG_LEVEL >= 2)
  	n_WriteLogLevel(2,"ctrnat match");
    	
    // Localisation Domain
    if ( strcmp(sz_domain_cf, Ktbd_rarat[n_indice].DOMAIN_CF) < 0 ) RETURN_VAL( -1 ) ;
    if ( strcmp(sz_domain_cf, Ktbd_rarat[n_indice].DOMAIN_CF) > 0 ) continue;

 	  if (n_DEBUG_LEVEL >= 2)
  	n_WriteLogLevel(2,"domain ALL match");
        	

    RETURN_VAL( n_indice );

  }
        
        RETURN_VAL( -1 );  // Aucune occurence trouve
}



/*==============================================================================
objet :
        affichage des traces ANO en fonction du parametre LEVEL

retour :

==============================================================================*/
int n_WriteLogLevel( int c_level , char * sz_message )
{
	if ( n_DEBUG_LEVEL  >= c_level )
		{
		//n_WriteAno(sz_message);
		n_WriteLog('I',sz_message);
		fflush(stdout);
	 }
	 
	 return(OK);
}




/**************************************************************************/
/*** Nom : n_ActionPereSansFilsRetSec                           ***/
/***                                                                    ***/
/*** Parametres:                                                        ***/
/***    i ptsz_LigneMaitre  : pointeur sur la ligne du maitre           ***/
/***                                                                    ***/
/*** Retour:                                                            ***/
/***    OK si pas d'erreur,                                             ***/
/***    ERR si erreur.                                                  ***/
/**************************************************************************/

int n_ActionPereSansFilsRetSec(char *ptsz_LigneMaitre[])
{
  DEBUT_FCT("n_ActionPereSansFilsRetSec");

  strcpy(ksz_GRPGRP3_NT,"");
  sprintf(sz_message, "SansFilsRETSEC CTR %s ksz_GRPGRP3_NT %s", ptsz_LigneMaitre[PER_CTR_NF] ,ksz_GRPGRP3_NT ) ;
  n_WriteLogLevel(1, sz_message )  ;       

  RETURN_VAL(OK);
}


/**************************************************************************/
/*** Nom : n_ActionPereSansFilsGTSIIRP                           ***/
/***                                                                    ***/
/*** Parametres:                                                        ***/
/***    i ptsz_LigneMaitre  : pointeur sur la ligne du maitre           ***/
/***                                                                    ***/
/*** Retour:                                                            ***/
/***    OK si pas d'erreur,                                             ***/
/***    ERR si erreur.                                                  ***/
/**************************************************************************/

int n_ActionPereSansFilsGTSIIRP(char *ptsz_LigneMaitre[])
{
  DEBUT_FCT("n_ActionPereSansFilsGTSIIRP");

  sprintf(sz_message,"SansFilsGTSIIRP ~%s~%s~%s~%s~%s~%s~%s",
  ptsz_LigneMaitre[PER_CTR_NF],ptsz_LigneMaitre[PER_END_NT],
  ptsz_LigneMaitre[PER_SEC_NF], ptsz_LigneMaitre[PER_UWY_NF], ptsz_LigneMaitre[PER_UW_NT] , ptsz_LigneMaitre[PER_CTRTYP_CT],ptsz_LigneMaitre[PER_CTRNAT_CT] );

  n_WriteLogLevel(0,sz_message);

  RETURN_VAL(OK);
}

/**************************************************************************/
/*** Nom : n_ActionPereSansFilsGTSIIRNP                           ***/
/***                                                                    ***/
/*** Parametres:                                                        ***/
/***    i ptsz_LigneMaitre  : pointeur sur la ligne du maitre           ***/
/***                                                                    ***/
/*** Retour:                                                            ***/
/***    OK si pas d'erreur,                                             ***/
/***    ERR si erreur.                                                  ***/
/**************************************************************************/


int n_ActionPereSansFilsGTSIIRNP(char *ptsz_LigneMaitre[])
{
  DEBUT_FCT("n_ActionPereSansFilsGTSIIRNP");

  sprintf(sz_message,"SansFilsGTSIIRNP ~%s~%s~%s~%s~%s~%s~%s",
  ptsz_LigneMaitre[PER_CTR_NF],ptsz_LigneMaitre[PER_END_NT],
  ptsz_LigneMaitre[PER_SEC_NF], ptsz_LigneMaitre[PER_UWY_NF], ptsz_LigneMaitre[PER_UW_NT] , ptsz_LigneMaitre[PER_CTRTYP_CT],ptsz_LigneMaitre[PER_CTRNAT_CT] );

  n_WriteLogLevel(0,sz_message);


  RETURN_VAL(OK);
}


/**************************************************************************/
/*** Nom : n_ActionPereSansFilsGTSIIA                           ***/
/***                                                                    ***/
/*** Parametres:                                                        ***/
/***    i ptsz_LigneMaitre  : pointeur sur la ligne du maitre           ***/
/***                                                                    ***/
/*** Retour:                                                            ***/
/***    OK si pas d'erreur,                                             ***/
/***    ERR si erreur.                                                  ***/
/**************************************************************************/

int n_ActionPereSansFilsGTSIIA(char *ptsz_LigneMaitre[])
{
  DEBUT_FCT("n_ActionPereSansFilsGTSIIA");

  sprintf(sz_message,"SansFilsGTSIIA ~%s~%s~%s~%s~%s~%s~%s",
  ptsz_LigneMaitre[PER_CTR_NF],ptsz_LigneMaitre[PER_END_NT],
  ptsz_LigneMaitre[PER_SEC_NF], ptsz_LigneMaitre[PER_UWY_NF], ptsz_LigneMaitre[PER_UW_NT] , ptsz_LigneMaitre[PER_CTRTYP_CT],ptsz_LigneMaitre[PER_CTRNAT_CT] );

  n_WriteLogLevel(0,sz_message);


  RETURN_VAL(OK);
}



/*==============================================================================
objet :
        fonction lancee pour chaque ligne fils sans pere

retour :        OK ---> traitement correctement effectue
                ERR --> probleme rencontre
==============================================================================*/
int n_ActionFilsSansPereGTSIIA(
                char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
 
  DEBUT_FCT( "n_ActionFilsSansPereGTSIIA" ) ;

  sprintf(sz_message,"SansPereGTSIIA ~%s~%s~%s~%s~%s~%s~%s",
  ptb_InRecChild[GTSII_CTR_NF],ptb_InRecChild[GTSII_END_NT],
  ptb_InRecChild[GTSII_SEC_NF], ptb_InRecChild[GTSII_UWY_NF], ptb_InRecChild[GTSII_UW_NT] , ptb_InRecChild[GTSII_TYP_CT],ptb_InRecChild[GTSII_NAT_CF] );

  n_WriteLogLevel(0,sz_message);
    
  
  RETURN_VAL( OK ) ;
}

int n_ActionFilsSansPereGTSIIRP(
                char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
 
  DEBUT_FCT( "n_ActionFilsSansPereGTSIIRP" ) ;

  sprintf(sz_message,"SansPereGTSIIRP ~%s~%s~%s~%s~%s~%s~%s",
  ptb_InRecChild[GTSII_RETCTR_NF],ptb_InRecChild[GTSII_RETEND_NT],
  ptb_InRecChild[GTSII_RETSEC_NF], ptb_InRecChild[GTSII_RTY_NF], ptb_InRecChild[GTSII_RETUW_NT] , ptb_InRecChild[GTSII_TYP_CT],ptb_InRecChild[GTSII_NAT_CF] );

  n_WriteLogLevel(0,sz_message);
    
  RETURN_VAL( OK ) ;
}


int n_ActionFilsSansPereGTSIIRNP(
                char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
 
  DEBUT_FCT( "n_ActionFilsSansPereGTSIIRNP" ) ;

  sprintf(sz_message,"SansPereGTSIIRNP ~%s~%s~%s~%s~%s~%s~%s",
  ptb_InRecChild[GTSII_RETCTR_NF],ptb_InRecChild[GTSII_RETEND_NT],
  ptb_InRecChild[GTSII_RETSEC_NF], ptb_InRecChild[GTSII_RTY_NF], ptb_InRecChild[GTSII_RETUW_NT] , ptb_InRecChild[GTSII_TYP_CT],ptb_InRecChild[GTSII_NAT_CF] );

  n_WriteLogLevel(0,sz_message);
    
  RETURN_VAL( OK ) ;
}




/*==============================================================================
 * objet :
 *         fonction lancee pour chaque ligne
 *
 *         retour :        OK ---> traitement correctement effectue
 *                         ERR --> probleme rencontre
 *                         ==============================================================================*/
int n_ActionLigneRETSEC(
        char **pbd_InRecOwner , /* adresse de la ligne du maitre */
        char **pbd_InRecChild ) /* adresse de la ligne de l'esclave */
{

  strcpy(ksz_GRPGRP3_NT,pbd_InRecChild[RETSEC_GRPGRP3_NT] );

  sprintf(sz_message, "LigneRETSEC CTR %s %s %s ksz_GRPGRP3_NT %s", pbd_InRecOwner[PER_CTR_NF],pbd_InRecChild[RETSEC_RETSEC_NF] , pbd_InRecChild[RETSEC_RTY_NF] , ksz_GRPGRP3_NT ) ;
  n_WriteLogLevel(1, sz_message )  ;       


  RETURN_VAL(OK);
}



/*
 *         Trim permet de supprimer les espaces dans une chaine de caract▒res,
 *                 si la chaine est vide (longueur =0), elle est retourn▒e tel que.
 *                         si la chaine contient des blancs, ils sont remplac▒s par des \0 et la chaine est renvoy▒e
 *                         */
char *trim(char *s)
{
    char *ptr;

        /*if (!s)
 *         return (char*) NULL;   // handle NULL string
 *                 */
    if (!*s)
        return s;      // handle empty string
    for (ptr = s + strlen(s) - 1; (ptr >= s) && isspace(*ptr); --ptr);
    ptr[1] = '\0';
    return s;
}




/**************************************************************************/
// int writeLine(char **ptb_InRecChild, char *sz_Clodat_d, const char *sz_inittrncod, char *sz_Somme, const char *sz_amctrs3)
// {

//   static char sz_amctrs3_local[6] = "";

//   static char sz_trncod[9] = "";
//   static char sz_charicod[15] = "I17GGTA";

//   static int i;

//   static char *DldSIIGT[GT_NBCOL2 + 2]; // tableau de pointeur a l'image du fichier en sortie:  73 colonnes

//   static char norme = 'I';

//   //TODO get norme from input

//   norme = n_GetNorme(Ksz_norme_cf);
  
//   if (norme == 'R')
//   {
//     n_WriteAno("ERROR : Norme Incorrecte \n");
//     // skip this line
//     return 1;
//   }

  
//   // chargement de la date de clot?re fournie au programme

//   sprintf(gsz_Annee, "%.4s", sz_Clodat_d);
//   sprintf(gsz_Mois, "%.2s", &sz_Clodat_d[4]);
//   sprintf(gsz_Jour, "%.2s", &sz_Clodat_d[6]);
  
//   sprintf(sz_charicod, "%sGTA", Ksz_norme_cf);
//   sprintf(sz_amctrs3_local, "%.5s", sz_amctrs3);

//   memset(DldSIIGT, 0, sizeof(DldSIIGT));

//   DldSIIGT[GT_SSD_CF] = ptb_InRecChild[GT_SSD_CF];
//   DldSIIGT[GT_ESB_CF] = ptb_InRecChild[GT_ESB_CF];
//   DldSIIGT[GT_BALSHEY_NF] = gsz_Annee;
//   DldSIIGT[GT_BALSHRMTH_NF] = gsz_Mois;
//   DldSIIGT[GT_BALSHRDAY_NF] = gsz_Jour;
//   DldSIIGT[GT_DBLTRNCOD_CF] = "";
//   DldSIIGT[GT_CTR_NF] = ptb_InRecChild[GT_CTR_NF];
//   DldSIIGT[GT_END_NT] = ptb_InRecChild[GT_END_NT];
//   DldSIIGT[GT_SEC_NF] = ptb_InRecChild[GT_SEC_NF];
//   DldSIIGT[GT_UWY_NF] = ptb_InRecChild[GT_UWY_NF];
//   DldSIIGT[GT_UW_NT] = ptb_InRecChild[GT_UW_NT];
//   DldSIIGT[GT_OCCYEA_NF] = gsz_Annee;
//   DldSIIGT[GT_ACY_NF] = gsz_Annee;
//   DldSIIGT[GT_SCOSTRMTH_NF] = gsz_Mois;
//   DldSIIGT[GT_SCOENDMTH_NF] = gsz_Mois;
//   DldSIIGT[GT_CLM_NF] = "";
//   DldSIIGT[GT_CUR_CF] = ptb_InRecChild[GT2_ACMCUR_CF];
//   DldSIIGT[GT_AMT_M] = sz_Somme;
//   DldSIIGT[GT_CED_NF] = ptb_InRecChild[GT_CED_NF];
//   DldSIIGT[GT_BRK_NF] = ptb_InRecChild[GT_BRK_NF];
//   DldSIIGT[GT_PAY_NF] = ptb_InRecChild[GT_PAY_NF];
//   DldSIIGT[GT_KEY_NF] = ptb_InRecChild[GT_KEY_NF];
//   if (b_IsBlankOrEmpty(ptb_InRecChild[GT_RETCTR_NF]))
//   {
//     DldSIIGT[GT_RETCTR_NF] = "";
//     DldSIIGT[GT_RETEND_NT] = "";
//     DldSIIGT[GT_RETSEC_NF] = "";
//     DldSIIGT[GT_RTY_NF] = "";
//     DldSIIGT[GT_RETUW_NT] = "";
//     DldSIIGT[GT_RETOCCYEA_NF] = "";
//     DldSIIGT[GT_RETACY_NF] = "";
//     DldSIIGT[GT_RETSCOSTRMTH_NF] = "";
//     DldSIIGT[GT_RETSCOENDMTH_NF] = "";
//     DldSIIGT[GT_RCL_NF] = "";
//     DldSIIGT[GT_RETCUR_CF] = "";
//     DldSIIGT[GT_RETAMT_M] = "";
//     DldSIIGT[GT_PLC_NT] = "";
//     DldSIIGT[GT_RTO_NF] = "";
//     DldSIIGT[GT_INT_NF] = "";
//     DldSIIGT[GT_RETPAY_NF] = "";
//     DldSIIGT[GT_RETKEY_CF] = "";
//     DldSIIGT[GT_RETINTAMT_M] = "0"; // 0 pour l'instant - sera mis a jour dans autre prog
//   }
//   else
//   {
//     DldSIIGT[GT_RETCTR_NF] = ptb_InRecChild[GT_RETCTR_NF];
//     DldSIIGT[GT_RETEND_NT] = ptb_InRecChild[GT_RETEND_NT];
//     DldSIIGT[GT_RETSEC_NF] = ptb_InRecChild[GT_RETSEC_NF];
//     DldSIIGT[GT_RTY_NF] = ptb_InRecChild[GT_RTY_NF];
//     DldSIIGT[GT_RETUW_NT] = ptb_InRecChild[GT_RETUW_NT];
//     DldSIIGT[GT_RETOCCYEA_NF] = gsz_Annee;
//     DldSIIGT[GT_RETACY_NF] = gsz_Annee;
//     DldSIIGT[GT_RETSCOSTRMTH_NF] = gsz_Mois;
//     DldSIIGT[GT_RETSCOENDMTH_NF] = gsz_Mois;
//     DldSIIGT[GT_RCL_NF] = "";
//     DldSIIGT[GT_RETCUR_CF] = ptb_InRecChild[GT2_ACMCUR_CF];
//     DldSIIGT[GT_RETAMT_M] = sz_Somme;
//     DldSIIGT[GT_PLC_NT] = ptb_InRecChild[GT_PLC_NT];
//     DldSIIGT[GT_RTO_NF] = ptb_InRecChild[GT_RTO_NF];
//     DldSIIGT[GT_INT_NF] = ptb_InRecChild[GT_INT_NF];
//     DldSIIGT[GT_RETPAY_NF] = ptb_InRecChild[GT_RETPAY_NF];
//     DldSIIGT[GT_RETKEY_CF] = ptb_InRecChild[GT_RETKEY_CF];
//     DldSIIGT[GT_RETINTAMT_M] ="0"; // spira 98114
//   }

//   if (b_IsBlankOrEmpty(ptb_InRecChild[GT_CTR_NF]))
//   {
//     DldSIIGT[GT_CTR_NF] = "";
//     DldSIIGT[GT_END_NT] = "";
//     DldSIIGT[GT_SEC_NF] = "";
//     DldSIIGT[GT_UWY_NF] = "";
//     DldSIIGT[GT_UW_NT] = "";
//   }

//   // Remise a blanc de la fin de l'enregistrement
//   for (i = GT_BUKRS_CF; i < GT_NBCOL2; i++)
//   {
//     DldSIIGT[i] = "";
//   }

//   //TODO : check GT_ORICOD_LS, should I change it ?

//   DldSIIGT[GT_ORICOD_LS] = sz_charicod;

//   //strcpy(DldSIIGT[GT_ORICOD_LS],sz_charicod);

//   DldSIIGT[GT_ACMTRS3_NT] = sz_amctrs3_local;

//   if (strncmp(ptb_InRecChild[GT2_TYP_CT], "A", 1) == 0)
//   {
//     DldSIIGT[GT_RETINTAMT_M] = "0"; // spira 98114
//     sprintf(sz_trncod, "11%.5s%c", sz_inittrncod, norme);
//     DldSIIGT[GT_TRNCOD_CF] = sz_trncod;

//     n_PosteContre(sz_trncod, Kp_GetDbltrncod); //Ksz_DBLTRNCOD_CF
//     DldSIIGT[GT_DBLTRNCOD_CF]=Ksz_DBLTRNCOD_CF;

//     n_WriteCols(Kp_OutputFilDldSIIGTAA, DldSIIGT, SEPARATEUR, 0);
//   }
//   else
//   {
//     if (!b_IsBlankOrEmpty(ptb_InRecChild[GT_RETCTR_NF])){
//       DldSIIGT[GT_RETINTAMT_M] = sz_Somme; // spira 98114

//       sprintf(sz_trncod, "21%.5s%c", sz_inittrncod, norme);
//       DldSIIGT[GT_TRNCOD_CF] = sz_trncod;

//       n_PosteContre(sz_trncod, Kp_GetDbltrncod); //Ksz_DBLTRNCOD_CF
//       DldSIIGT[GT_DBLTRNCOD_CF]=Ksz_DBLTRNCOD_CF;

//       n_WriteCols(Kp_OutputFilDldSIIGTRA, DldSIIGT, SEPARATEUR, 0);
//       // doublication TECLEDA
//       n_WriteCols(Kp_OutputFilDldSIIGTAA, DldSIIGT, SEPARATEUR, 0);
//     }
//   }
//   return 0;
// }


// /**===========================================================================
// objet	:	Fonction pour retourner symbole norme a rensigner dans TRNCOD 
// retour 	:   Caractere a renseigner dans TRNCOD	
// ==============================================================================*/
// char n_GetNorme(const char *Norme_CF)
// {
//   if (strcmp(Norme_CF, "I17G") == 0 || strcmp(Norme_CF, "I17S") == 0) //[43]
//     return 'I';
//   else if (strcmp(Norme_CF, "I17P") == 0)
//     return 'K';
//   else if (strcmp(Norme_CF, "I17L") == 0)
//     return 'M';
//   else
//     return 'R';
// }




// int n_PosteContre(char *sz_trncod, FILE *Kp_Dettrs)
// {
//     static int b_PremierAppel=0;
//     static int n_NbreLignes;
//     static T_DETTRS bd_TDETTRS[MAX_TDETTRS];
//     int n_position;

//    DEBUT_FCT("n_PosteContre");
// //   printf("TRNCOD =  %s\n", sz_trncod);
// /* S'il s'agit du premier appel a la fonction, on charge la table en memoire */
//     if ( b_PremierAppel==0 ) {
//        n_NbreLignes = n_LoadTDETTRS(Kp_Dettrs, bd_TDETTRS);
// //       printf("n_NbreLignes =  %d\n", n_NbreLignes);	
//        b_PremierAppel=1;
//     }

// /* Calcul de la position du poste comptable dans la table TDETTRS */
//     n_position = n_GetPosDettrs(sz_trncod, bd_TDETTRS, n_NbreLignes);

// /* Si le poste n'est pas trouve dans la table on sort et on renvoie 0 */
//    if (n_position == -1) {
//          *Ksz_DBLTRNCOD_CF = '\0';
//    }

// /* On renvoie le type de poste trouve */
//    else {
//       strcpy(Ksz_DBLTRNCOD_CF, bd_TDETTRS[n_position].CTRSCOD_CF);
//    }
// //   printf("Contre partie =  %s \n", Ksz_DBLTRNCOD_CF);
//    RETURN_VAL(OK);
// }







