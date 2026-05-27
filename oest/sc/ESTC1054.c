/*==============================================================================
nom de l'application          : ESTIMATION Solvency
nom du source                 : ESTC1054.c
révision                      : $Revision: 1.2 $
date de création              : 15/06/2012
auteur                        : Roger Cassis
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   :spot:23802 - Creation du Delta (POSE - IFRS) ou (POCE - POSE) sur fichier DLDGTAA - format GT
                 et traduction des postes comptables IFRS en postes sécifiques EBS

------------------------------------------------------------------------------
historique des modifications :
    <jj/mm/aaaa><auteur>    <description de la modification>
[01] 01/08/2012 Florent     :spot:24041 fin de poste en 2 - Ajout dale bilan
[02] 06/09/2012 -=Dch=-     :spot:24041 ajout de print sur le jour bilan
[03] 15/10/2012 Roger       :spot:24041 Remise a blanc 14 colonnes OneGL
[04] 18/02/2013 Roger       :spot:24864 Synchro sur poste entier
[05] 06/04/2014 JBG         :spot:25773 Modify void main declaration to int main
[06] 10/04/2016 Florent     :spira:38697 ajustement pour écart entre IFRS et EBS : utilile le fichier FCLIENT pour info RETRO interne
[07] 01/08/2018 Roger       :spira:68628 calcul du Delta IFRS/POS,POC pour la liste de postes comptables. Pas d'ecriture si montants < abs(0.1).
[08] 29/08/2019 Rafael      :spira:78996 ajout trncod futur loss corridor
[09] 04/09/2019 Roger       :spira:63929-79427 Il faut prendre en compte les mouvements Retro interne (OI) donc on retire le test
[10] 03/10/2019 Rafael      :spira:81374 - gestion du cas ou le fichier maitre est vide, on passe le fichier esclave en maitre et on fait que l'action fils sans pere.
[11] 22/10/2019 MZM         :spira:73772 - Manage retro contract and merge input to cashflow calculations : Ajout des TRNCOD Des Future Remaining Estimates Commission / Premium
[12] 31/01/2020 Roger       :spira:84254 on remet en route le test de Retro interne pour ne pas calculer les OI (OI)
[13] 31/01/2020 HR          :spira:81813 - replacement of brokerage rate 1A120032 by 1A120062
[14] 19/05/2020 Roger       :spira:84339 - 84340 - Review of all trncods for Delta IFRS / POS / POC and reconduction for FilsSansPere
[15] 03/12/2020 Roger       :spira:92015 Omit opening into the Trncod list with suffix "3"
[16] 03/03/2021 Roger       :spira:92356 Add T. Code 11104012 to the list for cancelling
[17] 23/03/2021 Roger       :spira:95047 Add T. Code ULAE 46010 to the list for cancelling
[18] 27/09/2021 Roger       :spira:84340 back to previous versus
[19] 23/05/2022 MZM         :spira:104541 :Undue TC '1A120222' Poste genere a tor : MAJ fonction n_ActionFilsEbsSansPereIfrs
[20] 07/09/2022 MZM         :spira:106313 : Prod Q1 22 - Fac - No calculation future : (CF ESTC1068)
[21] 21/11/2022 MZM         :spira:107835 : REGRESSION EBS : Retour A a version ou le TRNCOD 1A120222 est générer et la suppression est effectuee dans le shell ESFD2231
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <sys/stat.h>
#include "struct.h"

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/
#define SEG_SEG_NF 5
#define SEG_EGPCUR_CF 6

/*----------------------*/
/* variables de travail */
/*----------------------*/
FILE  *Kp_OutputFilGtaDelta; /* pointeur sur le fichier de sortie Delta */

T_RUPTURE_VAR        bd_RuptIfrs;   /* variable de gestion de la rupture sur Ifrs */
T_RUPTURE_VAR        bd_RuptI17;   /* variable de gestion de la rupture sur I17 */
T_RUPTURE_SYNC_VAR   bd_RuptEbs;   /* variable de gestion de la synchronisation avec le fichier GTA en entree */

int n_InitIfrs        ( T_RUPTURE_VAR  *pbd_Rupt );
int n_InitI17        ( T_RUPTURE_VAR  *pbd_Rupt );
int n_ActionLigneIfrs ( char **pbd_InRec_Cur );

int n_InitEbs                   ( T_RUPTURE_SYNC_VAR *pbd_Rupt );
int n_ActionLigneEbs            ( char **ptb_InRecOwner, char **pbd_InRecChild );
int n_ActionFilsEbsSansPereIfrs ( char ** );
int n_ActionPereIfrsSansFilsEbs ( char ** );
int n_EcrireGT                  ( char ** );

int n_ConditionSyncEbs          ( char **ptb_InRecOwner, char **pbd_InRecChild );

int n_ProcessingRuptureSyncVar  ( T_RUPTURE_SYNC_VAR  *pbd_Rupt, char **ptb_InRecOwner );

char   ksz_Amt[25];
char   ksz_RetAmt[25];
char   ksz_RetIntAmt[25];
char   Ksz_AnneeBilan[5];  // [001]
char   Ksz_MoisBilan[3];   // [001]
char   Ksz_JourBilan[3];   // [001]
char   Kc_Accret;          /* Type de fichier traité : Accept ou Retro (A/R) */
char   Kc_Futur;           // Traitement postes Futur (Y/N) [07]
/* [09] [12] */
static T_TCLIENT *Ktbd_TCLIENT;
static FILE  *Kp_InputFilTCLIENT;
size_t Kn_TCLIENT;

static int n_EstRetroInterne( int CLI_NF );
static int n_compareRetroInterne(const void *elt1 , const void *elt2);
static int n_ChargerTCLIENT( char *EnvFile);
static void n_finTCLIENT();

static int n_IsTrncodDelta( char ** );  // [07]

/*==============================================================================
objet : Point d'entree du programme

retour : En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
         Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc  , char *argv[])
{
  /* Initialisation des signaux */
  InitSig ();

  if ( n_BeginPgm ( argc, argv ) == ERR )
    ExitPgm( ERR_XX , "" );

  // [001]
  /* recuperation des arguments passes au programme */
  strncpy(Ksz_AnneeBilan, psz_GetCharArgv(1), 4);
  strncpy(Ksz_MoisBilan, psz_GetCharArgv(1) + 4, 2);
  strncpy(Ksz_JourBilan, psz_GetCharArgv(1) + 6, 2);
  Ksz_AnneeBilan[4] = 0;
  Ksz_MoisBilan[2] = 0;
  Ksz_JourBilan[2] = 0;
  Kc_Accret = *(psz_GetCharArgv(2));
  Kc_Futur = *(psz_GetCharArgv(3));  // [07]
  printf("date bilan : %s %s %s %c %c\n", Ksz_AnneeBilan, Ksz_MoisBilan, Ksz_JourBilan, Kc_Accret, Kc_Futur);
/* [09] [12] */
  //Chargement des clients de retro interne : TCLIENT
  if ( n_ChargerTCLIENT("ESTC1054_I3") != 1 ) ExitPgm( ERR_XX , "" );

  /* ouverture du fichier de sortie GT */
  if ( n_OpenFileAppl ( "ESTC1054_O1", "wt", &Kp_OutputFilGtaDelta ) == ERR )
    ExitPgm( ERR_XX , "" );

  /* Initialisation de la variable bd_RuptIfrs */
  if ( n_InitIfrs( &bd_RuptIfrs ) )
    ExitPgm( ERR_XX , "" );

  /* Initialisation de la variable bd_RuptEbs */
  if ( n_InitEbs( &bd_RuptEbs ) )
    ExitPgm( ERR_XX , "" );

  /* lancement du traitement du fichier Pere Ifrs */
  if ( n_ProcessingRuptureVar( &bd_RuptIfrs ) == ERR )
    ExitPgm( ERR_XX , "" );

	// file I2 is empty, slave become master ! (closing at inception case)
	if (bd_RuptIfrs.l_CntRecRead == 0)
	{
  		if ( n_InitI17( &bd_RuptI17 ) )
    		ExitPgm( ERR_XX , "" );
  		if ( n_ProcessingRuptureVar( &bd_RuptI17 ) == ERR )
    		ExitPgm( ERR_XX , "" );
	}
  if ( n_CloseFileAppl( "ESTC1054_I1", &( bd_RuptEbs.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTC1054_I2", &( bd_RuptIfrs.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTC1054_O1", &Kp_OutputFilGtaDelta ) == ERR )
    ExitPgm( ERR_XX , "" );
/* [09] [12] */
  //Libération de la mémoire allouée par le fichier binaire TCLIENT
  n_finTCLIENT();

  if ( n_EndPgm() == ERR )
    ExitPgm( ERR_XX , "" );

  exit(OK);
}

/*==============================================================================
objet :
	In Closing at inception the master file can be empty, so the slave file
	become master and the defaut action is action son without father
	in the clasic case.

retour : 0K
==============================================================================*/
int n_InitI17(T_RUPTURE_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_InitIfrs17" );

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) );

  /* ouverture du fichier esclave */
  if ( n_OpenFileAppl( "ESTC1054_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
    return ERR;

  /* nombre de rupture a gerer */
  pbd_Rupt->n_NbRupture = 0;

  /* fonction d'action sur la ligne courante */
  pbd_Rupt->n_ActionLigne = n_ActionFilsEbsSansPereIfrs;

  pbd_Rupt->c_Separ = SEPARATEUR;

  RETURN_VAL( OK );
}

/*==============================================================================
objet : fonction d'initialisation de la variable de gestion de rupture du fichier maitre.

retour : 0K
==============================================================================*/
int n_InitIfrs(T_RUPTURE_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_InitIfrs" );

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) );

  /* ouverture du fichier esclave */
  if ( n_OpenFileAppl( "ESTC1054_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
    return ERR;

  /* nombre de rupture a gerer */
  pbd_Rupt->n_NbRupture = 0;

  /* fonction d'action sur la ligne courante */
  pbd_Rupt->n_ActionLigne = n_ActionLigneIfrs;

  pbd_Rupt->c_Separ = SEPARATEUR;

  RETURN_VAL( OK );
}

/*==============================================================================
objet : fonction lancee pour chaque ligne

retour : OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneIfrs( char **ptb_InRec_Cur )
{
  DEBUT_FCT( "n_ActionLigneIfrs" );

  /* synchronisation avec le fichier GT */
  n_ProcessingRuptureSyncVar( &bd_RuptEbs, ptb_InRec_Cur );

  RETURN_VAL( OK );
}

/*==============================================================================
objet : Initialisation de la synchronisation du maitre « Perimetre retro »
        avec l'esclave « Ebs »

retour : OK
==============================================================================*/
int n_InitEbs( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
  DEBUT_FCT( "n_InitEbs" );

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) );

  /* ouverture du fichier maitre Perimetre de souscription */
  if ( n_OpenFileAppl( "ESTC1054_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
    return ERR;

  pbd_Rupt->n_NbRupture = 0;

  /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncEbs;

  /* fonction d'action sur la ligne courante du fichier eclave */
  pbd_Rupt->n_ActionLigne = n_ActionLigneEbs;
  pbd_Rupt->n_FilsSansPere = n_ActionFilsEbsSansPereIfrs;
  pbd_Rupt->n_PereSansFils = n_ActionPereIfrsSansFilsEbs;

  pbd_Rupt->c_Separ = SEPARATEUR;

  RETURN_VAL( OK );
}

/*==============================================================================
objet : fonction de test de synchronisation

retour : = 0 ---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
         > 0 ---> pbd_InRecOwner > pbd_InRecChild
         < 0 ---> pbd_InRecOwner < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncEbs(
  char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
  char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
  int ret;
  char trn_pere[9], trn_fils[9] ;
  char * pere;
  char * fils;

  memset(trn_pere, 0, sizeof(trn_pere));
  memset(trn_fils, 0, sizeof(trn_fils));

  pere = pbd_InRecOwner[GT_TRNCOD_CF];
  fils = pbd_InRecChild[GT_TRNCOD_CF];

  trn_pere[0] =  pere[0];
  trn_fils[0] =  fils[0];

  strcat(trn_pere, pere + 2);
  strcat(trn_fils, fils + 2);

  //printf("JourBilan: %s\n", Ksz_JourBilan);
  DEBUT_FCT( "n_ConditionSyncEbs" );

  if ( Kc_Accret == 'A' )
  {
    if ( ( ret = strcmp( pbd_InRecOwner[GT_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) return ret;
    if ( ( ret = strcmp( pbd_InRecOwner[GT_END_NT], pbd_InRecChild[GT_END_NT] ) ) != 0 ) return ret;
    if ( ( ret = atoi(pbd_InRecOwner[GT_SEC_NF]) - atoi(pbd_InRecChild[GT_SEC_NF]) ) != 0 ) return ret;
    if ( ( ret = strcmp( pbd_InRecOwner[GT_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) return ret;
    if ( ( ret = strcmp( pbd_InRecOwner[GT_UW_NT], pbd_InRecChild[GT_UW_NT] ) ) != 0 ) return ret;
    if ( ( ret = strcmp( pbd_InRecOwner[GT_CUR_CF], pbd_InRecChild[GT_CUR_CF] ) ) != 0 ) return ret;
    if ( ( ret = strcmp( pbd_InRecOwner[GT_TRNCOD_CF], pbd_InRecChild[GT_TRNCOD_CF] ) ) != 0 ) return ret;  //[004]
    if ( ( ret = strcmp( pbd_InRecOwner[GT_OCCYEA_NF], pbd_InRecChild[GT_OCCYEA_NF] ) ) != 0 ) return ret;
    if ( ( ret = strcmp( pbd_InRecOwner[GT_ACY_NF], pbd_InRecChild[GT_ACY_NF] ) ) != 0 ) return ret;
    if ( ( ret = atoi(pbd_InRecOwner[GT_SCOSTRMTH_NF]) - atoi(pbd_InRecChild[GT_SCOSTRMTH_NF]) ) != 0 ) return ret;
    if ( ( ret = atoi(pbd_InRecOwner[GT_SCOENDMTH_NF]) - atoi(pbd_InRecChild[GT_SCOENDMTH_NF]) ) != 0 ) return ret;
    if ( ( ret = strcmp( pbd_InRecOwner[GT_CLM_NF], pbd_InRecChild[GT_CLM_NF] ) ) != 0 ) return ret;
  }
  else
  {
    if ( ( ret = strcmp( pbd_InRecOwner[GT_RETCTR_NF], pbd_InRecChild[GT_RETCTR_NF] ) ) != 0 ) return ret;
    if ( ( ret = strcmp( pbd_InRecOwner[GT_RETEND_NT], pbd_InRecChild[GT_RETEND_NT] ) ) != 0 ) return ret;
    if ( ( ret = atoi(pbd_InRecOwner[GT_RETSEC_NF]) - atoi(pbd_InRecChild[GT_RETSEC_NF]) ) != 0 ) return ret;
    if ( ( ret = strcmp( pbd_InRecOwner[GT_RTY_NF], pbd_InRecChild[GT_RTY_NF] ) ) != 0 ) return ret;
    if ( ( ret = strcmp( pbd_InRecOwner[GT_RETUW_NT], pbd_InRecChild[GT_RETUW_NT] ) ) != 0 ) return ret;
    if ( ( ret = strcmp( pbd_InRecOwner[GT_RETCUR_CF], pbd_InRecChild[GT_RETCUR_CF] ) ) != 0 ) return ret;
    if ( ( ret = strcmp( trn_pere, trn_fils ) ) != 0 ) return ret;
    if ( ( ret = strcmp( pbd_InRecOwner[GT_RETOCCYEA_NF], pbd_InRecChild[GT_RETOCCYEA_NF] ) ) != 0 ) return ret;
    if ( ( ret = strcmp( pbd_InRecOwner[GT_RETACY_NF], pbd_InRecChild[GT_RETACY_NF] ) ) != 0 ) return ret;
    if ( ( ret = atoi(pbd_InRecOwner[GT_RETSCOSTRMTH_NF]) - atoi(pbd_InRecChild[GT_RETSCOSTRMTH_NF]) ) != 0 ) return ret;
    if ( ( ret = atoi(pbd_InRecOwner[GT_RETSCOENDMTH_NF]) - atoi(pbd_InRecChild[GT_RETSCOENDMTH_NF]) ) != 0 ) return ret;
    if ( ( ret = strcmp( pbd_InRecOwner[GT_PLC_NT], pbd_InRecChild[GT_PLC_NT] ) ) != 0 ) return ret;
    if ( ( ret = strcmp( pbd_InRecOwner[GT_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) return ret;
    if ( ( ret = strcmp( pbd_InRecOwner[GT_END_NT], pbd_InRecChild[GT_END_NT] ) ) != 0 ) return ret;
    if ( ( ret = atoi(pbd_InRecOwner[GT_SEC_NF]) - atoi(pbd_InRecChild[GT_SEC_NF]) ) != 0 ) return ret;
    if ( ( ret = strcmp( pbd_InRecOwner[GT_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) return ret;
    if ( ( ret = strcmp( pbd_InRecOwner[GT_UW_NT], pbd_InRecChild[GT_UW_NT] ) ) != 0 ) return ret;
    if ( ( ret = strcmp( pbd_InRecOwner[GT_CUR_CF], pbd_InRecChild[GT_CUR_CF] ) ) != 0 ) return ret;
    if ( ( ret = strcmp( pbd_InRecOwner[GT_ACY_NF], pbd_InRecChild[GT_ACY_NF] ) ) != 0 ) return ret;
    if ( ( ret = atoi(pbd_InRecOwner[GT_SCOSTRMTH_NF]) - atoi(pbd_InRecChild[GT_SCOSTRMTH_NF]) ) != 0 ) return ret;
    if ( ( ret = atoi(pbd_InRecOwner[GT_SCOENDMTH_NF]) - atoi(pbd_InRecChild[GT_SCOENDMTH_NF]) ) != 0 ) return ret;
  }

  RETURN_VAL( 0 );
}

/*==============================================================================
objet : fonction lancee pour chaque ligne

retour : OK  ---> traitement correctement effectue
         ERR ---> probleme rencontre
==============================================================================*/
int n_ActionLigneEbs(
  char **ptb_InRecOwner, /* adresse de la ligne du maitre */
  char **ptb_InRecChild) /* adresse de la ligne de l'esclave */
{
  double d_Amt;             /* montant acceptation */
  double d_RetAmt;          /* montant Retrocession */
  double d_RetIntAmt;       /* montant Retrocession */

  DEBUT_FCT("n_ActionLigneEbs");

  //Si le poste ne fait pas partie des postes du delta, on sort
  if (n_IsTrncodDelta(ptb_InRecOwner) == 0)
    RETURN_VAL( OK );
/* [09] [12] */
  //Si un contrat acceptation issu de la retro interne on sort
  if (n_EstRetroInterne( atoi(ptb_InRecOwner[GT_CED_NF])) == 1)
    RETURN_VAL( OK );

  /* Application du Delta EBS - IFRS ou EBSCO - EBSSO */
  d_Amt = atof(ptb_InRecChild[GT_AMT_M]) - atof(ptb_InRecOwner[GT_AMT_M]);
  d_RetAmt = atof(ptb_InRecChild[GT_RETAMT_M]) - atof(ptb_InRecOwner[GT_RETAMT_M]);
  d_RetIntAmt = atof(ptb_InRecChild[GT_RETINTAMT_M]) - atof(ptb_InRecOwner[GT_RETINTAMT_M]);
  sprintf(ksz_Amt, "%-.3f", d_Amt);
  sprintf(ksz_RetAmt, "%-.3f", d_RetAmt);
  sprintf(ksz_RetIntAmt, "%-.3f", d_RetIntAmt);

  if (atof(ptb_InRecOwner[GT_AMT_M]) != 0 || atof(ptb_InRecChild[GT_AMT_M]) != 0)
    ptb_InRecOwner[GT_AMT_M] = ksz_Amt;
  if (atof(ptb_InRecOwner[GT_RETAMT_M]) != 0 || atof(ptb_InRecChild[GT_RETAMT_M]) != 0)
    ptb_InRecOwner[GT_RETAMT_M] = ksz_RetAmt;
  if (atof(ptb_InRecOwner[GT_RETINTAMT_M]) != 0 || atof(ptb_InRecChild[GT_RETINTAMT_M]) != 0)
    ptb_InRecOwner[GT_RETINTAMT_M] = ksz_RetIntAmt;
/*
if (strncmp( ptb_InRecOwner[GT_TRNCOD_CF], "1131000", 7 ) == 0)
	printf("===> n_ActionLigneEbs 1 - GT_TRNCOD_CF = %s - GT_CTR_NF = %s - GT_RETCTR_NF = %s\n", ptb_InRecOwner[GT_TRNCOD_CF], ptb_InRecOwner[GT_CTR_NF], ptb_InRecOwner[GT_RETCTR_NF]);
*/
  RETURN_VAL(n_EcrireGT(ptb_InRecOwner));
}

/*==============================================================================
objet : fonction lancee quand le Fils n'a pas de Pere

retour: OK ---> traitement correctement effectue
        ERR --> probleme rencontre
dans ce cas on reporte telle quelle la ligne dans le fichier en sortie
==============================================================================*/
int  n_ActionFilsEbsSansPereIfrs( char **ptb_InRecChild )
{
  DEBUT_FCT( "n_ActionFilsEbsSansPereIfrs" );

/* [14] reconduction for son without father but let internal retro test
  // [07]
  //Si le poste ne fait pas partie des postes du delta, on sort
  if (n_IsTrncodDelta(ptb_InRecChild) == 0)
    RETURN_VAL( OK );
// [09] [12]
*/
  //Si un contrat acceptation issu de la retro interne on sort
  if (n_EstRetroInterne( atoi(ptb_InRecChild[GT_CED_NF])) == 1)
    RETURN_VAL( OK );

  //Reconduction du mouvement du Fils
  RETURN_VAL(n_EcrireGT(ptb_InRecChild));
}

/*==============================================================================
objet : fonction lancee quand le Fils n'a pas de Pere

retour: OK ---> traitement correctement effectue
        ERR --> probleme rencontre
dans ce cas on reporte telle quelle la ligne dans le fichier en sortie
==============================================================================*/
int  n_ActionPereIfrsSansFilsEbs( char **ptb_InRecOwner )
{

  DEBUT_FCT( "n_ActionPereIfrsSansFilsEbs" );

/* [07]
  //uniquement dans le cas de ce compte IFRS IBNR: END SCOR IBNR2
  if ((strncmp( ptb_InRecOwner[GT_TRNCOD_CF], "11494102", 8 ) ) != 0 )
    RETURN_VAL( OK );
*/
  // [07]
  //Si le poste ne fait pas partie des postes du delta, on sort
  if (n_IsTrncodDelta(ptb_InRecOwner) == 0)
    RETURN_VAL( OK );
/* [09] [12] */
  //Si un contrat acceptation issu de la retro interne on sort
  if (n_EstRetroInterne( atoi(ptb_InRecOwner[GT_CED_NF])) == 1)
    RETURN_VAL( OK );

  /* Application du Delta - IFRS */
  sprintf(ksz_Amt, "%-.3f", atof(ptb_InRecOwner[GT_AMT_M]) * -1);
  sprintf(ksz_RetAmt, "%-.3f", atof(ptb_InRecOwner[GT_RETAMT_M]) * -1);
  sprintf(ksz_RetIntAmt, "%-.3f", atof(ptb_InRecOwner[GT_RETINTAMT_M]) * -1);

  if (atof(ptb_InRecOwner[GT_AMT_M]) != 0)
    ptb_InRecOwner[GT_AMT_M] = ksz_Amt;
  if (atof(ptb_InRecOwner[GT_RETAMT_M]) != 0)
    ptb_InRecOwner[GT_RETAMT_M] = ksz_RetAmt;
  if (atof(ptb_InRecOwner[GT_RETINTAMT_M]) != 0)
    ptb_InRecOwner[GT_RETINTAMT_M] = ksz_RetIntAmt;

  RETURN_VAL(n_EcrireGT(ptb_InRecOwner));
}

/*==============================================================================
objet : fonction lancee quand le Fils n'a pas de Pere

retour: OK ---> traitement correctement effectue
        ERR --> probleme rencontre
dans ce cas on reporte telle quelle la ligne dans le fichier en sortie
On transforme les postes IFRS en postes EBS
==============================================================================*/
int  n_EcrireGT(char **ptb_InRec )
{
  int  n_Col;
  char sz_Trncod[9];
  char sz_Trncod2[2];     /* 2eme position du poste comptable */

  DEBUT_FCT( "n_EcrireGT" );

  // [07] Si montants nulls, pas d'ecriture
  if (fabs(atof(ptb_InRec[GT_AMT_M])) <= 0.100 &&
  	  fabs(atof(ptb_InRec[GT_RETAMT_M])) <= 0.100 &&
  	  fabs(atof(ptb_InRec[GT_RETINTAMT_M])) <= 0.100 )
  	RETURN_VAL( OK );
  	
  /* Affectation des postes identifiant une écriture Delta IFRS/EBS */
  strcpy(sz_Trncod, ptb_InRec[GT_TRNCOD_CF]);
  strncpy(sz_Trncod2, ptb_InRec[GT_TRNCOD_CF] + 1, 1);
  sz_Trncod2[1] = 0;

  // be careful, in case I17G the tnrcod is 1120071(I|K|M) and this function change them by 1A200712 (trncod futur loss corridor)
  if (strncmp(ptb_InRec[GT_TRNCOD_CF], "1120071", 7) && atoi(sz_Trncod2) > 0 && atoi(sz_Trncod2) <= 9 )
  {
    sz_Trncod[0] = 0;
    strncat(sz_Trncod, ptb_InRec[GT_TRNCOD_CF], 1);
    switch ( atoi(sz_Trncod2) )
    {
    case 1 :
      strncat(sz_Trncod, "A", 1);
      break ;
    case 2 :
      strncat(sz_Trncod, "B", 1);
      break ;
    case 3 :
      strncat(sz_Trncod, "D", 1);
      break ;
    case 4 :
      strncat(sz_Trncod, "E", 1);
      break ;
    case 5 :
      strncat(sz_Trncod, "G", 1);
      break ;
    case 6 :
      strncat(sz_Trncod, "H", 1);
      break ;
    case 7 :
      strncat(sz_Trncod, "J", 1);
      break ;
    case 8 :
      strncat(sz_Trncod, "K", 1);
      break ;
    case 9 :
      strncat(sz_Trncod, "L", 1);
      break ;
    }
    strncat(sz_Trncod, ptb_InRec[GT_TRNCOD_CF] + 2, 5);
    sz_Trncod[7] = '2'; // [001]
    sz_Trncod[8] = 0; // [001]
  }

  /* Transfert des colonnes */
  for (n_Col = GT_BUKRS_CF; ptb_InRec[n_Col] != NULL && n_Col <= GT_ZZRECONKEY_CF; n_Col++)
  { //ces colonnes sont toujours à vide
    ptb_InRec[n_Col] = "";
  }

  // [001]
  ptb_InRec[GT_BALSHEY_NF] = Ksz_AnneeBilan;
  ptb_InRec[GT_BALSHRMTH_NF] = Ksz_MoisBilan;
  ptb_InRec[GT_BALSHRDAY_NF] = Ksz_JourBilan;

  if ( b_IsBlankOrEmpty(Ksz_JourBilan))
  {
    ptb_InRec[GT_BALSHRDAY_NF] = "1" ; // jour bilan par défaut
  }

  ptb_InRec[GT_DBLTRNCOD_CF] = "";

  /* reconduction en sortie de la ligne du Perimetre avec le Ebs */
  ptb_InRec[GT_TRNCOD_CF] = sz_Trncod;
  ptb_InRec[GT_ORICOD_LS] = "EBSGTA";
  n_WriteCols(Kp_OutputFilGtaDelta, ptb_InRec, SEPARATEUR, 0);

  RETURN_VAL( OK );
}
/*==============================================================================
objet : Fonction de chargement du fichier binaire des correspondances retro vers
acceptation

retour :  0 ok / 1 erreur
==============================================================================*/
/* [09] [12] */
static int n_ChargerTCLIENT( char *EnvFile)
{
  struct stat sb;

  DEBUT_FCT( "n_ChargerTCLIENT" );

  if (stat(getenv(EnvFile), &sb) == -1) {
    perror("n_ChargerTCLIENT stat");
    return 0;
  }

  Kn_TCLIENT = (size_t)(sb.st_size / sizeof( T_TCLIENT));
  if ( ((size_t)(sb.st_size % sizeof( T_TCLIENT))) != 0 ) {
    sprintf(Gbd_Tech.sz_Write,"Error : %s(%s) not a FCLIENT file\n",getenv(EnvFile),EnvFile);
    n_WriteLog('E',Gbd_Tech.sz_Write);
    return 0;
  }
  
  if ( n_OpenFileAppl ( EnvFile, "rb", &Kp_InputFilTCLIENT ) == ERR )
    return 0;

  if ( (Ktbd_TCLIENT = ( T_TCLIENT *)calloc(sizeof(T_TCLIENT), Kn_TCLIENT)) == NULL)
    return 0;

  if ( fread( Ktbd_TCLIENT, sizeof( T_TCLIENT ), Kn_TCLIENT, Kp_InputFilTCLIENT ) != Kn_TCLIENT)
  {
    ferror(Kp_InputFilTCLIENT);
    n_finTCLIENT();
    return 0;
  }
  qsort(Ktbd_TCLIENT, Kn_TCLIENT, sizeof( T_TCLIENT), n_compareRetroInterne);

  return 1;
}

/*==============================================================================
objet : Fonction de comparaison utilisee pour la recherche si le contrat est issue de la retro interne

retour : 0 égal
        -1 inférieur
         1 supérieur 
==============================================================================*/
/* [09] [12] */
static int n_compareRetroInterne(const void *elt1 , const void *elt2)
{
  T_TCLIENT * item1 =  (T_TCLIENT *)elt1;
  T_TCLIENT * item2 =  (T_TCLIENT *)elt2;

  if (item1->CLI_NF != item2->CLI_NF )
    return item1->CLI_NF - item2->CLI_NF > 0 ? 1 : - 1;

  return 0;
}

/*==============================================================================
objet : Fonction de recherche si le contrat est issue de la retro interne

retour : 0 non / 1 oui
==============================================================================*/
/* [09] [12] */
static int n_EstRetroInterne( int CLI_NF )
{
  T_TCLIENT key;
  T_TCLIENT  *item;

  memset( &key, 0, sizeof( T_TCLIENT ) ) ;
  key.CLI_NF = CLI_NF;

  if (Ktbd_TCLIENT == NULL || Kn_TCLIENT == 0 ) return 0;

  item = ( T_TCLIENT *)bsearch((const void *)&key, (const void *)Ktbd_TCLIENT, Kn_TCLIENT, sizeof(T_TCLIENT), n_compareRetroInterne);

  if (item != NULL) return 1;

  return 0;
}

// [07]
// [08]
// [14]
/*==============================================================================
objet : Fonction de recherche si le poste fait partie du Delta IFRS4/POSE ou POSE/POCE

retour : 0 non / 1 oui
==============================================================================*/
static int n_IsTrncodDelta( char **ptb_InRec )
{
	if ((strncmp(ptb_InRec[GT_TRNCOD_CF], "1",1) == 0 || strncmp(ptb_InRec[GT_TRNCOD_CF], "2",1) == 0) &&
		  (strncmp(ptb_InRec[GT_TRNCOD_CF]+7, "3",1) != 0) &&  // [15] Pas les ouvertures
	    (strncmp(ptb_InRec[GT_TRNCOD_CF]+1, "1101202",7) == 0 || strncmp(ptb_InRec[GT_TRNCOD_CF]+1, "1101302",7) == 0 ||
	     strncmp(ptb_InRec[GT_TRNCOD_CF]+1, "1104012",7) == 0 ||  // [16]
	     strncmp(ptb_InRec[GT_TRNCOD_CF]+1, "1120302",7) == 0 || strncmp(ptb_InRec[GT_TRNCOD_CF]+1, "1122002",7) == 0 ||
	     strncmp(ptb_InRec[GT_TRNCOD_CF]+1, "1140002",7) == 0 || strncmp(ptb_InRec[GT_TRNCOD_CF]+1, "1140102",7) == 0 ||
	     strncmp(ptb_InRec[GT_TRNCOD_CF]+1, "1150002",7) == 0 || strncmp(ptb_InRec[GT_TRNCOD_CF]+1, "1494102",7) == 0 ||
	     // ULAE
	     strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "46012",5) == 0 || strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "46013",5) == 0 ||
	     strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "46014",5) == 0 || strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "46111",5) == 0 ||
	     strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "46112",5) == 0 || strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "46113",5) == 0 ||
	     strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "46114",5) == 0 || strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "46010",5) == 0 ||   // [17]
	     // RISK MARGIN
	     strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "49451",5) == 0 || strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "49452",5) == 0 ||
	     strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "49453",5) == 0 || strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "49454",5) == 0 ||
	     strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "49455",5) == 0 ||
	     // DISCOUNT
	     strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "10071",5) == 0 || strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "10072",5) == 0 ||
	     strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "10073",5) == 0 || strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "10074",5) == 0 ||
	     strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "10075",5) == 0 || strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "41601",5) == 0 ||
	     strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "41602",5) == 0 || strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "41603",5) == 0 ||
	     strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "41604",5) == 0 || strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "41605",5) == 0 ||
	     strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "42601",5) == 0 || strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "42602",5) == 0 ||
	     strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "42603",5) == 0 || strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "42604",5) == 0 ||
	     strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "42605",5) == 0
	    )
		 )
		return 1;

	else
		if ((Kc_Futur == 'Y') &&
		    (strncmp(ptb_InRec[GT_TRNCOD_CF], "1",1) == 0 || strncmp(ptb_InRec[GT_TRNCOD_CF], "2",1) == 0) &&
		    (strncmp(ptb_InRec[GT_TRNCOD_CF]+1, "A",1) == 0 || strncmp(ptb_InRec[GT_TRNCOD_CF]+1, "E",1) == 0) &&
		    (strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "10002",5) == 0 || strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "12005",5) == 0 ||
		     strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "12006",5) == 0 || strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "12007",5) == 0 ||
		     strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "12030",5) == 0 || strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "20071",5) == 0 ||
		     strncmp(ptb_InRec[GT_TRNCOD_CF]+2, "49430",5) == 0)
		   )
			return 1;

 	return 0;
}
/* [09] [12] */
void n_finTCLIENT()
{
  free(Ktbd_TCLIENT);
  Ktbd_TCLIENT = NULL;
}

