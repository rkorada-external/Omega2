/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTC1005.c
révision                      : $Revision: 1.2 $
date de création              : 29/07/1997
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   INTRODUCTION DES POSTES CUMULS, DES COMPTES COMPLETS ET CONVERSION EN DEVISE
ALIMENT

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    25/03/2004    M. DJELLOULI  Modification sur POSTES 10301 & 10311 - MOD01
    30/08/2004    M. DJELLOULI  SPOT 10422 - Modification des Date D'effet, Date d'échéance,    MOD02
                                            Durée des Polices, et Taux de Polices,
                                            pour LOB = '04' et SSD_CF = 2, 3, 12     ...           ...            ...              ...
    21/04/2005    M.DJELLOULI  SPOT 11416 - MOD03
                                          Pour charger Omega SAR, plutôt que de ne prendre que les provisions de clôture sur
                                          le bilan sauf les ouvertures on prend également les ouvertures pour les postes suivants :
                                          10321, 10331, 10341, 10351, 14201, 42181, 42411, 42891, 45101.

    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
[XX] 06/04/2014 JBG :spot:25773 Modify void main declaration to int main
[XX] 19/02/2015 F Maragnes :spot:28305 Ajout  Determination des sous code de regroupement pour distinguer les comptes complets/incomplet, sinistre paye/a payer
[07] 05/02/2016  Florent   :spot:29066 enlever le define du GT
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "struct.h"
#include "estserv.h"

/*---------------------------------------------*/
/* strcture contenant lignes esclaves cumulees */
/*---------------------------------------------*/
typedef struct {
  double  CC_Amt;
  long  CC_ACMTRS_CF;
} T_CUMUL_GT;


/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/
#define MAXLIG_RUPT 10000
#define INT(a) (((int)(a)-(int)('0')))
#define Kn_MaxPostes 2000       /* Le nombre max de postes est fixe a 2000 (modif O.Arik:28/05/2001 1000->2000 suite au dep. de mem.)*/

int     Kn_NbL, Kn_NbLRI, Kb_cond, Kb_condRI;
T_CUMUL_GT Ktb_CumulGt[MAXLIG_RUPT];
T_CUMUL_GT Ktb_CumulGtRI[MAXLIG_RUPT];

double CC_Amt_REC;

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE    *Kp_OutputFilPerUw ; /* pointeur sur le fichier de sortie Perimetre de souscription hors retro interne */
FILE    *Kp_OutputFilPerUwRI ; /* pointeur sur le fichier de sortie Perimetre de souscription retro interne - lob 04 - filiale 2,3*/
FILE    *Kp_OutputFilPerPrmd ; /* pointeur sur le fichier de sortie Perimetre des echeancier de primes provisionnelles */
FILE    *Kp_OutputFilGt ; /* pointeur sur le fichier de sortie GT */
FILE    *Kp_OutputFilGtRI ; /* pointeur sur le fichier de sortie GT */
FILE    *Kp_OutputFilGtREC ; /* pointeur sur le fichier de sortie GT */
FILE    *Kp_InputFilExc ; /* pointeur sur le fichier en entree des cours de change */
FILE    *Kp_InputFilTrsLnk ; /* pointeur sur le fichier en entree des postes cumuls */
FILE    *Kp_Dettrs;

T_RUPTURE_VAR       bd_RuptPerUw ; /* variable de gestion de la rupture sur le perimetre de souscription */
T_RUPTURE_SYNC_VAR  bd_RuptPerPrmd ; /* variable de gestion de la synchronisation avec le fichier perimetre des echeancier de primes provisionnelles  */
T_RUPTURE_SYNC_VAR  bd_RuptGt ; /* variable de gestion de la synchronisation avec le fichier GT */
T_RUPTURE_SYNC_VAR  bd_RuptCplAcc ; /* variable de gestion de la synchronisation avec le fichier des comptes complets */

T_TRSLNK Ktbd_TrsLnk[Kn_MaxPostes];
int Kn_NbLigTrslnk;

int Kn_Acy ;  /* variable de travail: annee de la periode compte complet */
unsigned char Kc_ScoEndMth ;  /* variable de travail: mois fin de la periode compte complet */

int n_InitPerUw     ( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_IsR1PerUw     ( char **ptb_InRec, char **pbd_InRec_Cur ) ;
int n_ActionFirstRuptPerUw  ( char **ptb_InRec_Cur ) ;
int n_ActionLignePerUw    ( char **pbd_InRec_Cur ) ;

int n_InitGt      ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneGt   ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncGt   ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_IsR1Gt      ( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_ActionFirstRuptGtRI ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ActionLastRuptGtRI  ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_IsR2Gt      ( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_ActionFirstRuptGt   ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ActionLastRuptGt    ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitPerPrmd   ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLignePerPrmd  ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncPerPrmd  ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitCplAcc    ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneCplAcc   ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncCplAcc ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_ProcessingRuptureSyncVar (      T_RUPTURE_SYNC_VAR  *pbd_Rupt,       char **ptb_InRecOwner );

int n_ChargerTRSLNK ( short s_TrtCod ) ;
int n_RechPoste(char *sz_poste) ;
int n_RechPoste_CourtageREC(char *sz_poste, short n_acmtrs_nt);
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

  sprintf(Ksz_AnneeBilan, "%s", psz_GetCharArgv(1));

  if ( n_OpenFileAppl ( "ESTC1005_I7", "rb", &Kp_Dettrs ) == ERR )
    ExitPgm ( ERR_XX , "" );

  /* ouverture du fichier en entree des cours de change FCURQUOT */
  if ( n_OpenFileAppl ( "ESTC1005_I6", "rb", &Kp_InputFilExc ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier en entree des postes cumuls FTRSLNK */
  if ( n_OpenFileAppl ( "ESTC1005_I5", "rb", &Kp_InputFilTrsLnk ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier de sortie GT enrichi */
  if ( n_OpenFileAppl ( "ESTC1005_O1", "wt", &Kp_OutputFilGt ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier de sortie Perimetre de souscription */
  if ( n_OpenFileAppl ( "ESTC1005_O2", "wt", &Kp_OutputFilPerUw ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier de sortie Perimetre des echeanciers de primes provisionnelles */
  if ( n_OpenFileAppl ( "ESTC1005_O3", "wt", &Kp_OutputFilPerPrmd ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier de sortie Perimetre Retro Interne */
  if ( n_OpenFileAppl ( "ESTC1005_O4", "wt", &Kp_OutputFilPerUwRI ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier de sortie  TL Retro Interne */
  if ( n_OpenFileAppl ( "ESTC1005_O5", "wt", &Kp_OutputFilGtRI ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier de sortie  TL Retro Interne */
  if ( n_OpenFileAppl ( "ESTC1005_O6", "wt", &Kp_OutputFilGtREC ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptPerUw */
  if ( n_InitPerUw( &bd_RuptPerUw ) )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptPerPrmd */
  if ( n_InitPerPrmd( &bd_RuptPerPrmd ) )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptGt */
  if ( n_InitGt( &bd_RuptGt ) )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptCplAcc */
  if ( n_InitCplAcc( &bd_RuptCplAcc ) )
    ExitPgm( ERR_XX , "" ) ;

  /* Chargement des postes en memoire */
  /* modif O.Arik:29/05/2001 on sort en cas de dep. de memoire*/
  Kn_NbLigTrslnk = n_ChargerTRSLNK( 710 );
  if ( Kn_NbLigTrslnk > Kn_MaxPostes )
    ExitPgm( ERR_XX , "" ) ;


  /* lancement du traitement du fichier Perimetre de souscription IADPERICASE.dat */
  if ( n_ProcessingRuptureVar( &bd_RuptPerUw ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC1005_I1", &( bd_RuptPerUw.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC1005_I2", &( bd_RuptPerPrmd.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC1005_I3", &( bd_RuptGt.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC1005_I4", &( bd_RuptCplAcc.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC1005_I5", &Kp_InputFilTrsLnk ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC1005_I6", &Kp_InputFilExc ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl ( "ESTC1005_I7", &Kp_Dettrs ) == ERR )
    ExitPgm ( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTC1005_O1", &Kp_OutputFilGt ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC1005_O2", &Kp_OutputFilPerUw ) == ERR )
    ExitPgm( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTC1005_O3", &Kp_OutputFilPerPrmd ) == ERR )
    ExitPgm( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTC1005_O4", &Kp_OutputFilPerUwRI ) == ERR )
    ExitPgm( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTC1005_O5", &Kp_OutputFilGtRI ) == ERR )
    ExitPgm( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTC1005_O6", &Kp_OutputFilGtREC ) == ERR )
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
int n_InitPerUw(T_RUPTURE_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_InitPerUw" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

  /* ouverture du fichier maitre Perimetre de souscription */
  if ( n_OpenFileAppl( "ESTC1005_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
    RETURN_VAL(  ERR ) ;

  pbd_Rupt->n_NbRupture = 1 ;

  /* fonction d'action sur la ligne courante du fichier maitre */
  pbd_Rupt->n_ActionLigne = n_ActionLignePerUw ;

  /* fonction du test de rupture de niveau 1 */
  pbd_Rupt->n_ConditionRupture[0] = n_IsR1PerUw ;

  /* fonction lancee en rupture premiere */
  pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptPerUw ;

  pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  fonction de test de rupture de niveau 1

retour :
  0 ---> pas de rupture
  sinon     ---> rupture
==============================================================================*/
int n_IsR1PerUw(
  char **pbd_InRec ,  /* adresse de la ligne en avance */
  char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
  int ret ;

  DEBUT_FCT( "n_IsR1PerUw" ) ;

  if ( ( ret = strcmp( pbd_InRec[PER_CTR_NF], pbd_InRec_Cur[PER_CTR_NF] ) ) != 0 ) RETURN_VAL (ret) ;

  RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
  fonction lancee en rupture premiere

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRuptPerUw(
  char **ptb_InRec_Cur  ) /* adresse de la ligne courante */
{
  DEBUT_FCT( "n_ActionFirstRuptPerUw" ) ;

  /* initialisation des variables de travail */
  Kn_Acy = 0 ;
  Kc_ScoEndMth = 0 ;

  /* synchronisation avec le fichier des Comptes complets */
  n_ProcessingRuptureSyncVar( &bd_RuptCplAcc, ptb_InRec_Cur ) ;

  RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
  fonction lancee pour chaque ligne

retour :
  OK ---> traitement correctement effectue
  ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePerUw( char **ptb_InRec_Cur )
{
  DEBUT_FCT( "n_ActionLignePerUw" ) ;

  Kb_cond = (*ptb_InRec_Cur[PER_CTRRET_B] == '0');

// MOD02
  /* -------------------------------------------------------------------------------- */
  /* suite à la demande de T.Bovery                                                   */
  /* -------------------------------------------------------------------------------- */
  /* [on ne prends pas en compte]                 [on ecrit en sortie ssi]            */
  /*  - le contrat 02Z041517               <=>    CTR_NF<>02Z041517                   */
  /*  - le contrat 02G0X7677 ex 1993           et (CTR_NF<>02G0X7677 ou UWY_NF<>1993) */
  /*  - tous contrats tels que CED_NF=70130    et CED_NF<>70130                       */
  /* -------------------------------------------------------------------------------- */
  /* MOD02 Pays du Risque (PER_PCPRSKTRY_CF= FRA)   et Hors Retro Interne (PER_CTRRET_B == 0 )*/

  Kb_condRI = (
                ((strcmp(ptb_InRec_Cur[PER_PCPRSKTRY_CF], "FRA") == 0) && (strcmp(ptb_InRec_Cur[PER_LOB_CF], "04") == 0) &&
                 (strcmp(ptb_InRec_Cur[PER_CTRRET_B], "0") == 0) && (atoi(ptb_InRec_Cur[PER_SSD_CF]) == 2 || atoi(ptb_InRec_Cur[PER_SSD_CF]) == 3 || atoi(ptb_InRec_Cur[PER_SSD_CF]) == 12)) &&
                ((strcmp(ptb_InRec_Cur[PER_CTR_NF], "02Z041517")) &&
                 (strcmp(ptb_InRec_Cur[PER_CTR_NF], "02G0X7677") || strcmp(ptb_InRec_Cur[PER_UWY_NF], "1993")))
              );

  /* synchronisation avec le fichier Perimetre des echeances de primes provisionnelles */
  if (Kb_cond) n_ProcessingRuptureSyncVar( &bd_RuptPerPrmd, ptb_InRec_Cur );

  /* synchronisation avec le fichier GT */
  if (Kb_cond || Kb_condRI) n_ProcessingRuptureSyncVar( &bd_RuptGt, ptb_InRec_Cur );

  /* ecriture dans le Perimetre de souscription en sortie */
  if (Kb_cond) n_WriteCols( Kp_OutputFilPerUw, ptb_InRec_Cur, '~', 0 );

  if (Kb_condRI) n_WriteCols( Kp_OutputFilPerUwRI, ptb_InRec_Cur, '~', 0 );

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  Initialisation de la synchronisation du maitre « Perimetre de souscription »
  avec l’esclave « GT »

retour :
  OK
==============================================================================*/
int n_InitGt( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
  DEBUT_FCT( "n_InitGt" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

  /* ouverture du fichier esclave Primes et sinistres ultimes */
  if ( n_OpenFileAppl( "ESTC1005_I3", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
    RETURN_VAL (ERR )  ;

  /* nombre de rupture a gerer sur le fichier de travail */
  pbd_Rupt->n_NbRupture = 2 ;

  /* gestion de la rupture de niveau 1 (GtRI) */
  pbd_Rupt->n_ConditionRupture[0] = n_IsR1Gt ;
  pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptGtRI ;
  pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptGtRI ;

  /* gestion de la rupture de niveau 2 (Gt) */
  pbd_Rupt->n_ConditionRupture[1] = n_IsR2Gt ;
  pbd_Rupt->n_ActionFirst[1] = n_ActionFirstRuptGt ;
  pbd_Rupt->n_ActionLast[1] = n_ActionLastRuptGt ;

  /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncGt ;

  /* fonction d'action sur la ligne courante */
  pbd_Rupt->n_ActionLigne = n_ActionLigneGt ;

  pbd_Rupt->c_Separ = '~' ;

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
int n_ConditionSyncGt(
  char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
  char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
  int ret ;

  DEBUT_FCT( "n_ConditionSyncGt" ) ;

  if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) RETURN_VAL( ret ) ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GT_END_NT] ) ) != 0 ) RETURN_VAL( ret ) ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) RETURN_VAL( ret ) ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) RETURN_VAL( ret ) ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GT_UW_NT] ) ) != 0 ) RETURN_VAL( ret ) ;

  RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
  fonction de test de rupture de niveau 1

retour :
  0 ---> pas de rupture
  sinon     ---> rupture
==============================================================================*/
int n_IsR1Gt(
  char **pbd_InRec ,  /* adresse de la ligne en avance */
  char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
  int ret ;

  DEBUT_FCT( "n_IsR1Gt" ) ;

  if ( ( ret = strcmp( pbd_InRec[GT_CTR_NF], pbd_InRec_Cur[GT_CTR_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRec[GT_END_NT], pbd_InRec_Cur[GT_END_NT] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRec[GT_SEC_NF], pbd_InRec_Cur[GT_SEC_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRec[GT_UWY_NF], pbd_InRec_Cur[GT_UWY_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRec[GT_UW_NT], pbd_InRec_Cur[GT_UW_NT] ) ) != 0 ) return ret ;

  RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
  fonction lancee en rupture premiere

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRuptGtRI(
  char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
  char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
  DEBUT_FCT( "n_ActionFirstRuptGtRI" ) ;

  Kn_NbLRI = 0 ;

  RETURN_VAL ( OK ) ;

}


/*==============================================================================
objet :
  fonction lancee en rupture derniere GtRI (niveau 1)

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptGtRI(
  char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
  char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
  int l;

  DEBUT_FCT( "n_ActionLastRuptGtRI" ) ;

  for (l = 0; l < Kn_NbLRI; l++)
  {
    /*ajout une colonne pour retintamt_m */
    fprintf(Kp_OutputFilGtRI,
            "%s~%s~~~~~~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~~~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~~%ld~%-.3f~%s\n",
            pbd_InRecChild[GT_SSD_CF],
            pbd_InRecChild[GT_ESB_CF],
            pbd_InRecChild[GT_CTR_NF],
            pbd_InRecChild[GT_END_NT],
            pbd_InRecChild[GT_SEC_NF],
            pbd_InRecChild[GT_UWY_NF],
            pbd_InRecChild[GT_UW_NT],
            pbd_InRecChild[GT_OCCYEA_NF],
            pbd_InRecChild[GT_ACY_NF],
            pbd_InRecChild[GT_SCOSTRMTH_NF],
            pbd_InRecChild[GT_SCOENDMTH_NF],
            pbd_InRecChild[GT_CLM_NF],
            pbd_InRecChild[GT_CED_NF],
            pbd_InRecChild[GT_BRK_NF],
            pbd_InRecChild[GT_PAY_NF],
            pbd_InRecChild[GT_KEY_NF],
            Ktb_CumulGtRI[l].CC_ACMTRS_CF,
            Ktb_CumulGtRI[l].CC_Amt,
            pbd_InRecOwner[PER_EGPCUR_CF]);
  }

  RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
  fonction de test de rupture de niveau 2

retour :
  0 ---> pas de rupture
  sinon     ---> rupture
==============================================================================*/
int n_IsR2Gt(
  char **pbd_InRec ,  /* adresse de la ligne en avance */
  char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
  int ret ;

  DEBUT_FCT( "n_IsR2Gt" ) ;

  if ( ( ret = strcmp( pbd_InRec[GT_CTR_NF], pbd_InRec_Cur[GT_CTR_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRec[GT_END_NT], pbd_InRec_Cur[GT_END_NT] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRec[GT_SEC_NF], pbd_InRec_Cur[GT_SEC_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRec[GT_UWY_NF], pbd_InRec_Cur[GT_UWY_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRec[GT_UW_NT], pbd_InRec_Cur[GT_UW_NT] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRec[GT_ACY_NF], pbd_InRec_Cur[GT_ACY_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRec[GT_SCOENDMTH_NF], pbd_InRec_Cur[GT_SCOENDMTH_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRec[GT_SCOSTRMTH_NF], pbd_InRec_Cur[GT_SCOSTRMTH_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRec[GT_OCCYEA_NF], pbd_InRec_Cur[GT_OCCYEA_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRec[GT_CLM_NF], pbd_InRec_Cur[GT_CLM_NF] ) ) != 0 ) return ret ;

  RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
  fonction lancee en rupture premiere

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRuptGt(
  char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
  char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
  DEBUT_FCT( "n_ActionFirstRuptGt" ) ;

  Kn_NbL = 0 ;
  CC_Amt_REC = 0 ;

  RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
  fonction lancee en rupture derniere Gt

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptGt(
  char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
  char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
  int l;
  int ret ;

  DEBUT_FCT( "n_ActionLastRuptGt" ) ;

  for (l = 0; l < Kn_NbL; l++)
  {
    /*ajout une colonne pour retintamt_m */
    fprintf(Kp_OutputFilGt,
            "%s~%s~~~~~~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~~~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~~%ld~%-.3f~%s\n",
            pbd_InRecChild[GT_SSD_CF],
            pbd_InRecChild[GT_ESB_CF],
            pbd_InRecChild[GT_CTR_NF],
            pbd_InRecChild[GT_END_NT],
            pbd_InRecChild[GT_SEC_NF],
            pbd_InRecChild[GT_UWY_NF],
            pbd_InRecChild[GT_UW_NT],
            pbd_InRecChild[GT_OCCYEA_NF],
            pbd_InRecChild[GT_ACY_NF],
            pbd_InRecChild[GT_SCOSTRMTH_NF],
            pbd_InRecChild[GT_SCOENDMTH_NF],
            pbd_InRecChild[GT_CLM_NF],
            pbd_InRecChild[GT_CED_NF],
            pbd_InRecChild[GT_BRK_NF],
            pbd_InRecChild[GT_PAY_NF],
            pbd_InRecChild[GT_KEY_NF],
            Ktb_CumulGt[l].CC_ACMTRS_CF,
            Ktb_CumulGt[l].CC_Amt,
            pbd_InRecOwner[PER_EGPCUR_CF]);
  }

  if ( ( ret = strcmp( pbd_InRecOwner[PER_RECBRK_B], "1" ) ) == 0 )
  {
    /*ajout une colonne pour retintamt_m */
    fprintf(Kp_OutputFilGtREC,
            "%s~%s~~~~~~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~~~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~~%d~%-.3f~%s\n",
            pbd_InRecChild[GT_SSD_CF],
            pbd_InRecChild[GT_ESB_CF],
            pbd_InRecChild[GT_CTR_NF],
            pbd_InRecChild[GT_END_NT],
            pbd_InRecChild[GT_SEC_NF],
            pbd_InRecChild[GT_UWY_NF],
            pbd_InRecChild[GT_UW_NT],
            pbd_InRecChild[GT_OCCYEA_NF],
            pbd_InRecChild[GT_ACY_NF],
            pbd_InRecChild[GT_SCOSTRMTH_NF],
            pbd_InRecChild[GT_SCOENDMTH_NF],
            pbd_InRecChild[GT_CLM_NF],
            pbd_InRecChild[GT_CED_NF],
            pbd_InRecChild[GT_BRK_NF],
            pbd_InRecChild[GT_PAY_NF],
            pbd_InRecChild[GT_KEY_NF],
            10401,
            CC_Amt_REC,
            pbd_InRecOwner[PER_EGPCUR_CF]);
  }

  RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
  fonction lancee pour chaque ligne

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGt(
  char **ptb_InRecOwner , /* adresse de la ligne du maitre */
  char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
  int i, l;
  double d_Amt ;   /* montant acceptation */
  double d_Ratio ; /* ratio: devise acceptation/devise aliment */
  long  l_AcmTrs ; /* poste cumul */
  short n_type;
  int n_poste;

  char  MsgAno[300] ; /* message d'anomalie */

  DEBUT_FCT( "n_ActionLigneGt" ) ;

  /* Récupération du type de poste ds DETTRS */
  n_type = n_TypePoste(ptb_InRecChild[GT_TRNCOD_CF], Kp_Dettrs);


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
            n_poste == 41101 || n_poste == 41901 || n_poste == 42101 ||
            n_poste == 42111 || n_poste == 42141 || n_poste == 42151 ||
            n_poste == 42161 || n_poste == 42191 || n_poste == 42801 ||
            n_poste == 43101 || n_poste == 43701 || n_poste == 44101 ||
            n_poste == 48101 || n_poste == 48111 || n_poste == 48801 ||
            n_poste == 42401 || n_poste == 48121 || n_poste == 10301 ||
            n_poste == 10311 || n_poste == 10321 || n_poste == 10331 ||
            n_poste == 10341 || n_poste == 10351 || n_poste == 14201 ||
            n_poste == 42181 || n_poste == 42411 || n_poste == 42891 ||
            n_poste == 45101
          )
        )
      )
    )
  ) {

    /* affectation du montant acceptation */
    d_Amt = atof( ptb_InRecChild[GT_AMT_M] ) ;

    /* Synchronisation du fichier trslnk afin de recuperer ACMTRS_NT */
    i = n_RechPoste(ptb_InRecChild[GT_TRNCOD_CF]) ;
    if (i == -1) l_AcmTrs = 0 ;
    else l_AcmTrs = Ktbd_TrsLnk[i].ACMTRS_NT ;



    /* test: compte complet ? */
    if ( ( ( *ptb_InRecOwner[PER_CTRNAT_CT] == 'P' ) ||
           (( *ptb_InRecOwner[PER_CTRNAT_CT] == 'N' ) &&
            (( atoi( ptb_InRecOwner[PER_NAT_CF] ) == 40 ) || ( atoi( ptb_InRecOwner[PER_NAT_CF] ) == 41 )))
         )
         && l_AcmTrs == 20000 )
    {
      if ( ( ( atoi( ptb_InRecChild[GT_ACY_NF] ) < Kn_Acy ) ||
             ( ( atoi( ptb_InRecChild[GT_ACY_NF] ) == Kn_Acy ) &&
               ( atoi( ptb_InRecChild[GT_SCOENDMTH_NF] ) <= Kc_ScoEndMth ) ) ) )
      {
        if (atof( ptb_InRecChild[GT_TRNCOD_CF] ) > 11329999 )
        {
          l_AcmTrs = -20030 ;
        }
        else
        {
          l_AcmTrs = -20000 ;
        }
      }
    }

    /*FCharles en NP hors stop loss et annual aggregate tout est complet */
    /*ceci pour la ventilation du ESTC0626 */
    if ( ( ( *ptb_InRecOwner[PER_CTRNAT_CT] == 'N' ) &&
           (( atoi( ptb_InRecOwner[PER_NAT_CF] ) != 40 ) &&
            ( atoi( ptb_InRecOwner[PER_NAT_CF] ) != 41 ))
         ) && l_AcmTrs == 20000 )
    {
      l_AcmTrs = -20030 ;
    }


    if ( ( ( *ptb_InRecOwner[PER_CTRNAT_CT] == 'P' ) ||
           (( *ptb_InRecOwner[PER_CTRNAT_CT] == 'N' )  &&
            (( atoi( ptb_InRecOwner[PER_NAT_CF] ) == 40 ) || ( atoi( ptb_InRecOwner[PER_NAT_CF] ) == 41 )))
         )
         && l_AcmTrs == 20500 )
    {
      if ( ( ( atoi( ptb_InRecChild[GT_ACY_NF] ) < Kn_Acy ) ||
             ( ( atoi( ptb_InRecChild[GT_ACY_NF] ) == Kn_Acy ) &&
               ( atoi( ptb_InRecChild[GT_SCOENDMTH_NF] ) <= Kc_ScoEndMth ) ) ) )
      {
        if (atof( ptb_InRecChild[GT_TRNCOD_CF] ) > 11329999 )
        {
          l_AcmTrs = -20530 ;
        }
        else
        {
          l_AcmTrs = -20500 ;
        }
      }
    }

    /*FCharles en NP hors stop loss et annual aggregate tout est complet */
    /*ceci pour la ventilation du ESTC0626 */
    if ( ( ( *ptb_InRecOwner[PER_CTRNAT_CT] == 'N' ) &&
           (( atoi( ptb_InRecOwner[PER_NAT_CF] ) != 40 ) &&
            ( atoi( ptb_InRecOwner[PER_NAT_CF] ) != 41 ))
         ) && l_AcmTrs == 20500 )
    {
      l_AcmTrs = -20530 ;
    }

    /* conversion du montant acceptation en devise aliment */
    if ( strcmp( ptb_InRecChild[GT_CUR_CF], ptb_InRecOwner[PER_EGPCUR_CF] ) != 0 )
    {
      d_Ratio = d_GetTaux( Kp_InputFilExc, (char) atoi( ptb_InRecChild[GT_SSD_CF] ),
                           atoi( ptb_InRecChild[GT_BALSHEY_NF] ), ptb_InRecChild[GT_CUR_CF], ptb_InRecOwner[PER_EGPCUR_CF] ) ;

      /* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
      if ( d_Ratio < 0 )
      {
        sprintf( MsgAno, "The rates of acceptation currency ( %s ) and EGPI currency ( %s ) aren't known for the accounting transaction ( SSD %s - CTR %s - END %s - SEC %s - UWY %s - UW %s - Balance sheet date %s/%s/%s - TRNCOD %s - ACY %s - accounting period %s/%s ) \n",
                 ptb_InRecChild[GT_CUR_CF],  ptb_InRecOwner[PER_EGPCUR_CF], ptb_InRecChild[GT_SSD_CF],
                 ptb_InRecChild[GT_CTR_NF],  ptb_InRecChild[GT_END_NT], ptb_InRecChild[GT_SEC_NF],
                 ptb_InRecChild[GT_UWY_NF],  ptb_InRecChild[GT_UW_NT] , ptb_InRecChild[GT_BALSHRDAY_NF],
                 ptb_InRecChild[GT_BALSHRMTH_NF], ptb_InRecChild[GT_BALSHEY_NF], ptb_InRecChild[GT_TRNCOD_CF],
                 ptb_InRecChild[GT_ACY_NF], ptb_InRecChild[GT_SCOSTRMTH_NF], ptb_InRecChild[GT_SCOENDMTH_NF] ) ;
        n_WriteAno( MsgAno ) ;

        /* montant positionne a zero */
        d_Amt = 0 ;
      }
      else d_Amt *= d_Ratio ;
    }

    if (( l_AcmTrs != 0 ) && Kb_cond ) {

      for (l = 0; l < Kn_NbL; l++)
        if ( Ktb_CumulGt[l].CC_ACMTRS_CF == l_AcmTrs ) break ;

      if ( l == Kn_NbL )
      {
        Kn_NbL++ ;
        if (Kn_NbL == MAXLIG_RUPT + 1)
        {
          printf("la taille du tableau Ktb_CumulGt a ete depasse il faut augmenter MAXLIG_RUPT\n");
          return ERR;
        }
        Ktb_CumulGt[l].CC_Amt = d_Amt;
        Ktb_CumulGt[l].CC_ACMTRS_CF = l_AcmTrs;
      }
      else Ktb_CumulGt[l].CC_Amt += d_Amt;

      /* L'ensemble des postes comptable de courtage se trouve dans le poste de regroupement 10400
         Le courtage sur prime de REC 11140100 se trouve dans le poste 10400 et 10401
         Si le poste comptable a ete trouve une premiere fois associe au poste 10400, on verifie
         si il fait partie du poste 10401 plus restrictif, et on met de cote les montants correspondant au courtage sur prime de REC */
      if ( l_AcmTrs == 10400 )
      {
        if ( n_RechPoste_CourtageREC(ptb_InRecChild[GT_TRNCOD_CF], 10401 ) == TRUE )
          CC_Amt_REC += d_Amt;
      }
    }

    if (( l_AcmTrs == 20000 || l_AcmTrs == -20000 || l_AcmTrs == -20030 ||
          l_AcmTrs == 10000 || l_AcmTrs == 10010 || l_AcmTrs == 10020 || l_AcmTrs == 10030 || l_AcmTrs == 10130 ||
          l_AcmTrs == 10430 || l_AcmTrs == 10040 || l_AcmTrs == 28030 || l_AcmTrs == -20500 || l_AcmTrs == -20530 || l_AcmTrs == 20500  ) && Kb_condRI) {

      for (l = 0; l < Kn_NbLRI; l++)
        if ( Ktb_CumulGtRI[l].CC_ACMTRS_CF == l_AcmTrs ) break ;

      if ( l == Kn_NbLRI )
      {
        Kn_NbLRI++ ;
        if (Kn_NbLRI == MAXLIG_RUPT + 1)
        {
          printf("la taille du tableau Ktb_CumulGtRI a ete depasse il faut augmenter MAXLIG_RUPT\n");
          return ERR;
        }
        Ktb_CumulGtRI[l].CC_Amt = d_Amt;
        Ktb_CumulGtRI[l].CC_ACMTRS_CF = l_AcmTrs;
      }
      else Ktb_CumulGtRI[l].CC_Amt += d_Amt;
    }
  }
  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  Initialisation de la synchronisation du maitre « Perimetre de souscription »
  avec l'esclave « Perimetre des echeanciers primes provisionnelles »

retour :
  OK
==============================================================================*/
int n_InitPerPrmd(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_InitPerPrmd" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

  /* ouverture du fichier esclave Mouvements comptables */
  if ( n_OpenFileAppl( "ESTC1005_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
    RETURN_VAL ( ERR ) ;

  /* nombre de rupture a gerer sur le fichier */
  pbd_Rupt->n_NbRupture = 0 ;

  /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncPerPrmd ;

  /* fonction d'action sur la ligne courante */
  pbd_Rupt->n_ActionLigne = n_ActionLignePerPrmd ;

  pbd_Rupt->c_Separ = '~' ;

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
int n_ConditionSyncPerPrmd(
  char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
  char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
  int ret ;

  DEBUT_FCT( "n_ConditionSyncPerPrmd" ) ;

  if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[PERPRMD_CTR_NF] ) ) != 0 ) RETURN_VAL( ret ) ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[PERPRMD_END_NT] ) ) != 0 ) RETURN_VAL( ret ) ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[PERPRMD_SEC_NF] ) ) != 0 ) RETURN_VAL( ret ) ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[PERPRMD_UWY_NF] ) ) != 0 ) RETURN_VAL( ret ) ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[PERPRMD_UW_NT] ) ) != 0 ) RETURN_VAL( ret ) ;

  RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
  fonction lancee pour chaque ligne

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePerPrmd(
  char **ptb_InRecOwner , /* adresse de la ligne du maitre */
  char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
  double d_PrmDue ;
  double d_Ratio ;
  char  **PerPrmd ; /* tableau de pointeur permettant de sauvegarder la ligne du perimetre
         des echeances de primes */
  char sz_PrmDueAmt[30] ; /* zone de travail: montant de prime */
  char sz_EgpCur[4] ; /* zone de travail: devise aliment */
  char  MsgAno[300] ; /* message d'anomalie */

  DEBUT_FCT( "n_ActionLignePerPrmd" ) ;

  /* conversion en devise aliment */

  /* sauvegarde de la ligne courante */
  PerPrmd = ptb_InRecChild ;
  d_PrmDue = atof( ptb_InRecChild[PERPRMD_PRMDUE_M] ) ;
  strcpy( sz_EgpCur, ptb_InRecChild[PERPRMD_PRMDUECUR_CF] ) ;

  PerPrmd[PERPRMD_PRMDUE_M] = sz_PrmDueAmt ;
  PerPrmd[PERPRMD_PRMDUECUR_CF] = sz_EgpCur ;

  /* conversion si la devise de prime est differente de la devise aliment */
  if ( strcmp( ptb_InRecChild[PERPRMD_PRMDUECUR_CF], ptb_InRecOwner[PER_EGPCUR_CF] ) != 0 )
  {
    d_Ratio = d_GetTaux( Kp_InputFilExc, (char) atoi( ptb_InRecChild[PERPRMD_SSD_CF] ),
                         ( atoi( ptb_InRecChild[PERPRMD_UWY_NF] ) - 1 ), ptb_InRecChild[PERPRMD_PRMDUECUR_CF],
                         ptb_InRecOwner[PER_EGPCUR_CF] ) ;

    /* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
    if ( d_Ratio < 0 )
    {
      sprintf( MsgAno, "The rates of premium currency ( %s ) and EGPI currency ( %s ) aren't known for the provision premium perimeter contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) \n",
               ptb_InRecChild[PERPRMD_PRMDUECUR_CF],
               ptb_InRecOwner[PER_EGPCUR_CF],
               ptb_InRecChild[PERPRMD_CTR_NF],
               ptb_InRecChild[PERPRMD_END_NT],
               ptb_InRecChild[PERPRMD_SEC_NF],
               ptb_InRecChild[PERPRMD_UWY_NF],
               ptb_InRecChild[PERPRMD_UW_NT] ) ;
      n_WriteAno( MsgAno ) ;

      /* montant positionne a zero */
      d_PrmDue = 0 ;
    }
    else  d_PrmDue *= d_Ratio ;

    strcpy( sz_EgpCur, ptb_InRecOwner[PER_EGPCUR_CF] ) ;
  }

  sprintf( sz_PrmDueAmt, "%-.3f", d_PrmDue ) ;

  /* ecriture en sortie */
  n_WriteCols( Kp_OutputFilPerPrmd, PerPrmd, '~', 0 ) ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  Initialisation de la synchronisation du maitre « Perimetre de souscription » avec
  l'esclave « Fichier des comptes complets »

retour :
  OK
==============================================================================*/
int n_InitCplAcc(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_InitCplAcc" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

  /* ouverture du fichier esclave GT cumule sur sinistres */
  if ( n_OpenFileAppl( "ESTC1005_I4", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
    RETURN_VAL (ERR) ;

  /* nombre de rupture a gerer sur le fichier de travail */
  pbd_Rupt->n_NbRupture = 0 ;

  /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncCplAcc ;

  /* fonction d'action sur la ligne courante */
  pbd_Rupt->n_ActionLigne = n_ActionLigneCplAcc ;

  pbd_Rupt->c_Separ = '~' ;

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

  if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[CMP_CTR_NF] ) ) != 0 ) RETURN_VAL( ret ) ;

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

  /* recherche de la derniere periode de compte complet */
  if ( ( atoi( ptb_InRecChild[CMP_ACY_NF] ) > Kn_Acy ) ||
       ( ( atoi( ptb_InRecChild[CMP_ACY_NF] ) == Kn_Acy ) &&
         ( atoi( ptb_InRecChild[CMP_SCOENDMTH_NF] ) > Kc_ScoEndMth ) ) )
  {
    Kn_Acy = atoi( ptb_InRecChild[CMP_ACY_NF] ) ;
    Kc_ScoEndMth = (char) atoi( ptb_InRecChild[CMP_SCOENDMTH_NF] ) ;
  }

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet:
  Lit le fichier binaire des postes et les met en memoire

==============================================================================*/
int n_ChargerTRSLNK( short s_TrtCod )
{
  int i = 0 ;
  char  MsgAno[300] ; /* message d'anomalie */

  DEBUT_FCT("n_ChargerTRSLNK");

  while ( fread( &Ktbd_TrsLnk[i], sizeof( T_TRSLNK ), 1, Kp_InputFilTrsLnk ) == 1 )
  {
    if ( Ktbd_TrsLnk[i].PRS_CF == s_TrtCod )
      i += 1 ;
    if ( i > Kn_MaxPostes )
    {

      sprintf(MsgAno, "la taille du tableau Ktbd_TrsLnk depasse la taille allouee %d", i);
      n_WriteAno(MsgAno);
      RETURN_VAL( i );
    }
  }
  RETURN_VAL( i );
}


/*==============================================================================
objet :
  fonction de recherche du poste
retour :
  0   ---> Pas de rupture
  < 0     ---> On n'est pas arrive au bloc synchrone
  > 0     ---> On a depasse le bloc synchrone
==============================================================================*/
int n_RechPoste(char *sz_poste)
{
  int n_indice, ret;

  DEBUT_FCT("n_RechPoste");

  n_indice = 0;

  while (1 == 1)
  {
    /* Comparaison des codes */
    ret = strcmp(sz_poste, Ktbd_TrsLnk[n_indice].DETTRS_CF);

    /* S'ils sont egaux, retourner l'indice */
    if (ret == 0) RETURN_VAL(n_indice);

    /* Si la ligne est passee, retourner -1 (echec) */
    if (ret < 0) RETURN_VAL(-1);

    /* Ligne suivante */
    n_indice++;

    /* Si on est a la fin du tableau, echec */
    if (n_indice >= Kn_NbLigTrslnk) RETURN_VAL(-1);
  }
}

/*==============================================================================
objet :
        Fonction de recherche appelee lorsqu'on est sur un poste faisant partie
        du poste de regroupement 10400, incluant tout ce qui concerne le courtage.
        On verifie si le poste comptable fait partie du
        poste de regroupement "courtage sur prime de REC" : poste 10401
retour :
        0               ---> Pas de rupture
        < 0     ---> On n'est pas arrive au bloc synchrone
        > 0     ---> On a depasse le bloc synchrone
==============================================================================*/
int n_RechPoste_CourtageREC(char *sz_poste, short n_acmtrs_nt)
{
  int n_indice, ret;

  DEBUT_FCT("n_RechPoste_CourtageREC");

  n_indice = 0;

  while (1 == 1)
  {
    ret = strcmp(sz_poste, Ktbd_TrsLnk[n_indice].DETTRS_CF);

    /* Lorsqu'on a trouve la ligne correspondant au poste comptable,
       on teste le poste de regroupement */
    if ( ret == 0 )
    {
      if ( Ktbd_TrsLnk[n_indice].ACMTRS_NT == n_acmtrs_nt )
        RETURN_VAL(TRUE);
    }

    /* Si la ligne est passee, retourner -1 (echec) */
    if (ret < 0) RETURN_VAL(FALSE);

    /* Ligne suivante */
    n_indice++;

    /* Si on est a la fin du tableau, echec */
    if (n_indice >= Kn_NbLigTrslnk) RETURN_VAL(-1);
  }
}

