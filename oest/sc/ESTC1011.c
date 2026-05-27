/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION
nom du source                 : ESTC1011.c
révision                      : $Revision: 1.2 $
date de création              : 30/04/1999
auteur                        : B.MONTAGNAC (ASCOTT)
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   Cumul des primes cédantes et estimées pour les contrats SNEM

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	  29/01/03      J. Ribot    ajout 1 champs a NULL en sortie pour retintamt_m
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
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
/* définition des constantes et macros privées */
/*---------------------------------------------*/


/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE *Kp_OutputFilGtSNEM ;          /* pointeur sur le fichier de sortie GT */

T_RUPTURE_VAR      bd_RuptPerSNEM ; /* variable de gestion de la rupture sur le perimetre SNEM */

T_RUPTURE_SYNC_VAR bd_RuptGtSNEM ;  /* variable de gestion de la synchronisation avec le fichier GTSNEM */

T_RUPTURE_SYNC_VAR bd_RuptGtPRE ;   /* variable de gestion de la synchronisation avec le fichier GTPRE */

char Ksz_GtOut[256];
int Kb_foundSNEM, Kb_foundPRE;
double Kd_AMT_M;

int n_InitPerSNEM 		( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLignePerSNEM	( char **pbd_InRec_Cur ) ;

int n_InitGtSNEM		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneGtSNEM		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncGtSNEM	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitGtPRE			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneGtPRE		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncGtPRE	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_ProcessingRuptureSyncVar (T_RUPTURE_SYNC_VAR  *pbd_Rupt, char **ptb_InRecOwner );


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

  /* ouverture du fichier de sortie GT enrichi */
  if ( n_OpenFileAppl ( "ESTC1011_O1","wt",&Kp_OutputFilGtSNEM ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptPerSNEM */
  if ( n_InitPerSNEM( &bd_RuptPerSNEM ) )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptGtSNEM */
  if ( n_InitGtSNEM( &bd_RuptGtSNEM ) )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptGtPRE */
  if ( n_InitGtPRE( &bd_RuptGtPRE ) )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_ProcessingRuptureVar( &bd_RuptPerSNEM ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC1011_I1", &( bd_RuptPerSNEM.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC1011_I2", &( bd_RuptGtSNEM.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC1011_I3", &( bd_RuptGtPRE.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC1011_O1", &Kp_OutputFilGtSNEM ) == ERR )
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
int n_InitPerSNEM(T_RUPTURE_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_InitPerSNEM" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

  /* ouverture du fichier maitre Perimetre de souscription */
  if ( n_OpenFileAppl( "ESTC1011_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
    RETURN_VAL(  ERR ) ;

  pbd_Rupt->n_NbRupture = 0 ;

  /* fonction d'action sur la ligne courante du fichier maitre */
  pbd_Rupt->n_ActionLigne = n_ActionLignePerSNEM ;

  pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePerSNEM( char **ptb_InRec_Cur )
{
  char **ptb_GtRec = (char**)NULL;

  DEBUT_FCT( "n_ActionLignePerSNEM" ) ;

  /*if (!strcmp("02Z042951",ptb_InRec_Cur[PER_CTR_NF]) && !strcmp("1987",ptb_InRec_Cur[PER_UWY_NF])) toto=1; else toto=0;*/

  /* Initialisation des variables globales */
  Kb_foundSNEM=0;
  Kb_foundPRE=0;
  Kd_AMT_M = 0;

  /* Synchronisation avec le DSUMGTAASNEM => cumule les AMT_M, fixe Kptb_GtSNEM */
  n_ProcessingRuptureSyncVar( &bd_RuptGtSNEM, ptb_InRec_Cur );

  /* Synchronisation avec le DSUMGTAAPRE => cumule les AMT_M, fixe Kptb_GtPRE */
  n_ProcessingRuptureSyncVar( &bd_RuptGtPRE, ptb_InRec_Cur );


  /* Ecriture des informations en sortie */
  if ( ( Kb_foundSNEM || Kb_foundPRE ) && fabs(Kd_AMT_M) >= 0.001 ){
    /*if (toto) printf("   [MASTER]:{écriture} %s~%-.3lf~%s\n", Ksz_GtOut, Kd_AMT_M, ptb_InRec_Cur[PER_EGPCUR_CF]);*/
    fprintf(Kp_OutputFilGtSNEM, "%s~%-.3lf~%s\n", Ksz_GtOut, Kd_AMT_M, ptb_InRec_Cur[PER_EGPCUR_CF]);
  }
  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription »
	avec l’esclave « GT »

retour :
	OK
==============================================================================*/
int n_InitGtSNEM( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
  DEBUT_FCT( "n_InitGtSNEM" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

  /* ouverture du fichier esclave DSUMGTAASNEM */
  if ( n_OpenFileAppl( "ESTC1011_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
    RETURN_VAL (ERR )  ;

  /* nombre de rupture a gerer sur le fichier de travail */
  pbd_Rupt->n_NbRupture = 0 ;

  /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncGtSNEM ;

  /* fonction d'action sur la ligne courante */
  pbd_Rupt->n_ActionLigne = n_ActionLigneGtSNEM ;

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
int n_ConditionSyncGtSNEM(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
  int ret ;

  DEBUT_FCT( "n_ConditionSyncGtSNEM" ) ;

  if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GTE_CTR_NF] ) ) != 0 ) RETURN_VAL( ret ) ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GTE_END_NT] ) ) != 0 ) RETURN_VAL( ret ) ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GTE_SEC_NF] ) ) != 0 ) RETURN_VAL( ret ) ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GTE_UWY_NF] ) ) != 0 ) RETURN_VAL( ret ) ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GTE_UW_NT] ) ) != 0 ) RETURN_VAL( ret ) ;

  RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGtSNEM(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{

  DEBUT_FCT( "n_ActionLigneGtSNEM" ) ;

  /* on ne cumule que les postes 10000, les autres sont reconduits */
  if ( atoi(ptb_InRecChild[GTE_ACMTRS_NT]) == 10000 ) {
    Kd_AMT_M += atof( ptb_InRecChild[GTE_ACMAMT_M] );
    Kb_foundSNEM = 1;

    sprintf(Ksz_GtOut,"%s~%s~~~~~~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~~~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~~%ld",
	    ptb_InRecChild[GTE_SSD_CF],
	    ptb_InRecChild[GTE_ESB_CF],
	    ptb_InRecChild[GTE_CTR_NF],
	    ptb_InRecChild[GTE_END_NT],
	    ptb_InRecChild[GTE_SEC_NF],
	    ptb_InRecChild[GTE_UWY_NF],
	    ptb_InRecChild[GTE_UW_NT],
	    ptb_InRecChild[GTE_OCCYEA_NF],
	    ptb_InRecChild[GTE_ACY_NF],
	    ptb_InRecChild[GTE_SCOSTRMTH_NF],
	    ptb_InRecChild[GTE_SCOENDMTH_NF],
	    ptb_InRecChild[GTE_CLM_NF],
	    ptb_InRecChild[GTE_CED_NF],
	    ptb_InRecChild[GTE_BRK_NF],
	    ptb_InRecChild[GTE_PAY_NF],
	    ptb_InRecChild[GTE_KEY_NF],
	    10000);
  }
  else
    fprintf(Kp_OutputFilGtSNEM,

	    "%s~%s~~~~~~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~~~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~~%s~%s~%s\n",
	    ptb_InRecChild[GTE_SSD_CF],
	    ptb_InRecChild[GTE_ESB_CF],
	    ptb_InRecChild[GTE_CTR_NF],
	    ptb_InRecChild[GTE_END_NT],
	    ptb_InRecChild[GTE_SEC_NF],
	    ptb_InRecChild[GTE_UWY_NF],
	    ptb_InRecChild[GTE_UW_NT],
	    ptb_InRecChild[GTE_OCCYEA_NF],
	    ptb_InRecChild[GTE_ACY_NF],
	    ptb_InRecChild[GTE_SCOSTRMTH_NF],
	    ptb_InRecChild[GTE_SCOENDMTH_NF],
	    ptb_InRecChild[GTE_CLM_NF],
	    ptb_InRecChild[GTE_CED_NF],
	    ptb_InRecChild[GTE_BRK_NF],
	    ptb_InRecChild[GTE_PAY_NF],
	    ptb_InRecChild[GTE_KEY_NF],
	    ptb_InRecChild[GTE_ACMTRS_NT],
	    ptb_InRecChild[GTE_ACMAMT_M],
	    ptb_InRecOwner[PER_EGPCUR_CF]);

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription »
	avec l’esclave « GT »

retour :
	OK
==============================================================================*/
int n_InitGtPRE( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
  DEBUT_FCT( "n_InitGtPRE" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

  /* ouverture du fichier esclave DLGTAAPRE */
  if ( n_OpenFileAppl( "ESTC1011_I3", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
    RETURN_VAL (ERR )  ;

  /* nombre de rupture a gerer sur le fichier de travail */
  pbd_Rupt->n_NbRupture = 0 ;

  /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncGtPRE ;

  /* fonction d'action sur la ligne courante */
  pbd_Rupt->n_ActionLigne = n_ActionLigneGtPRE ;

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
int n_ConditionSyncGtPRE(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
  int ret ;

  DEBUT_FCT( "n_ConditionSyncGtPRE" ) ;

  if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) RETURN_VAL( ret ) ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GT_END_NT] ) ) != 0 ) RETURN_VAL( ret ) ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) RETURN_VAL( ret ) ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) RETURN_VAL( ret ) ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GT_UW_NT] ) ) != 0 ) RETURN_VAL( ret ) ;

  RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGtPRE(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{

  DEBUT_FCT( "n_ActionLigneGtPRE" ) ;

  /* cumul du montant acceptation */
  Kd_AMT_M += atof( ptb_InRecChild[GT_AMT_M] ) ;
  Kb_foundPRE = 1;
  sprintf(Ksz_GtOut,"%s~%s~~~~~~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~~~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~~%ld",
	  ptb_InRecChild[GTE_SSD_CF],
	  ptb_InRecChild[GTE_ESB_CF],
	  ptb_InRecChild[GTE_CTR_NF],
	  ptb_InRecChild[GTE_END_NT],
	  ptb_InRecChild[GTE_SEC_NF],
	  ptb_InRecChild[GTE_UWY_NF],
	  ptb_InRecChild[GTE_UW_NT],
	  ptb_InRecChild[GTE_OCCYEA_NF],
	  ptb_InRecChild[GTE_ACY_NF],
	  ptb_InRecChild[GTE_SCOSTRMTH_NF],
	  ptb_InRecChild[GTE_SCOENDMTH_NF],
	  ptb_InRecChild[GTE_CLM_NF],
	  ptb_InRecChild[GTE_CED_NF],
	  ptb_InRecChild[GTE_BRK_NF],
	  ptb_InRecChild[GTE_PAY_NF],
	  ptb_InRecChild[GTE_KEY_NF],
	  10000);

  RETURN_VAL( OK ) ;
}
