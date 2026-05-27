/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTC2020.c
révision                      : $Revision: 1.3 $
date de création              : 22/06/2004
auteur                        : J.Ribot
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   FILTRE SUR LA RETRO INTERNE - BASCULEMENT DE LA RETROCESSION VERS L'ACCEPTATION
DE LA FILIALE RETROCESSIONNAIRE

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    10/12/2004     J. Ribot   il faut envoyer les mvts a zero !!! mise en commentaire de la ligne
                                                    && fabs(atof(ptb_InRecChild[PRE_ESTMNT_M])) >= 0.001 )
    14/02/2008     J. Ribot   SPOT 14961 prise en compte du taux de placement
    14/02/2008     J. Ribot   SPOT 11064 correspondance 1150 et 2145
    20/02/2008     J. Ribot   SPOT 14634 correspondance 2150 et 1140
    06/03/2008     J. Ribot   SPOT 14633 la cre_d des mvts retro interne passe de "23:59:45" a "23:59:05"
    25/06/2013     Prajakta   Phase1B migration code changes for warning removal
_________________
MODIFICATION    [005]
Auteur:         D.GATIBELZA
Date:           22/07/2008
Version:        8.1
Description:    ESTDOM15823 Echange interne  agrandissement d'un tableau en memoire pour charger les références internes
                passage de MAX_SSDACTR 20000 à : MAX_SSDACTR 50000

[006] 14/11/2013 -=Dch=-       :spot:25773  - Omega 2B modification de colonnes pour LIFEST
[XXX] 02/06/2014 JBG :spot:25773 Warnings suppress in compile
[007] 23/07/2014 ABJ :spot:25773 Modification of init_SubTrsAssoLigne()
[008] 23/07/2014 ABJ :spot:25773 ajout des informations d'origines(ctr,uwy,sec), ajout de l ACMTRS au niveau de la rupture
[009] 25/07/2014 ABJ :spot:25773 ajout des lignes avec montant vide
[010] 28/07/2014 ABJ  spot:25773 modification des montant --0 a 0
[011] 02/09/2014 SBE :spot:25773 modification gaapdiff --0 à 0
[012] 02/09/2014 SBE :spot:25773 sprintf sans - dans la chaine de caractère
[013] 21/10/2014 SBE :spot:25773 ajout initialisation accpar
[014] 23/10/2015 RBE :spot:29565 correction des gestions des années futures (> bilan)
[015] 03/11/2015 SBE :spot:29565 correction des gestions des années futures (> bilan) + correction bug Fuite mémoire DETTRNCOD
[016] 06/09/2016 RBE :spot:31159 Correction: Mise à jour de la filiale d'origine (Retro)
[017] 06/04/2018 SBE :spira:56493 TCodes 2 1 12110 0 and 4 1 12110 0 are not transform the same way using association rule
[018] 27/03/2019 S.Behague    :spira 70044:REQ.L.02.05: Evolution quarterly
=============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "struct.h"
#include "estserv.h"


/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/


/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/
#define MAX_SSDACTR 500000       //[005] 20000                    /*  jr 11/09/2003 ancien = 12500  */

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE    *Kp_OutputFilPrev ;   /* pointeur sur le fichier de sortie PREV */
FILE    *Kp_InputFilPeri ;  /* pointeur sur le fichier en entree des postes comptables */
FILE    *Kp_InputFilSsdActr ; /* pointeur sur le fichier des correspondances retro vers acceptation */
FILE    *Kp_SubTRSAssoFile;

T_RUPTURE_VAR   bd_RuptPlc ;    /* variable de gestion de la synchronisation avec le fichier des placements */
T_RUPTURE_VAR           bd_RuptTACCPAR;
T_RUPTURE_VAR           bd_RuptPrev;
T_RUPTURE_SYNC_VAR  bd_RuptPre ;  /* variable de gestion de la rupture sur le PREV */
T_RUPTURE_SYNC_VAR   bd_RuptPer; /* gestion synchro perimetre-previsions */

T_DETTRS Ktbd_DetTrs[MAX_TDETTRS] ;     /* tableau des postes comptables */
//short Kn_DetTrs_Nbp ;     /* compteur du nombre de postes du tableau Ktbd_DetTrs */

T_SSDACTR Ktbd_SsdActr[MAX_SSDACTR] ;   /* tableau des correspondances retro vers acceptation */
/*short Kn_SsdActr_Nbp ; *//* compteur du nombre de postes du tableau Ktbd_SsdActr */ /** Commented for Phase1b migration **/
int Kn_SsdActr_Nbp ; /** Added for Phase1b migration **/
char Ksz_cloprd[9]; /* date de valeur de l'inventaire en cours (parametre du programme) */
char Ksz_dbclo_d[9];  /* date d'arrete (parametre du programme) */
char Ksz_cre_d[9];  /* date de traitement (parametre du programme) */
char Ksz_balmth_d[3];  /* mois de traitement (parametre du programme) */

char Kc_PLA_RTY_NF[5];
char Kc_PLA_SSDRTO_B;
char Kc_PLA_RETOVRCOM_B;
long Kc_PLA_Plc;
char Kc_PLA_pay_NF[6];
T_SUBTRSASSO SubTrsAssoLigne;

char Ksav_Ctr[10] ; /* contrat */
char Ksav_Sec[4] ;  /* section */
char Ksav_PLA_RTY_NF[5];
char Ksav_PLA_SSDRTO_B;
char Ksav_PLA_RETOVRCOM_B;
long Ksav_PLA_Plc;
double Ksav_RETSIGSHA;

char  Ksz_Cre[20] ; /* date de creation des previsions en sortie */

int n_ChargerSSDACTR( void ) ;
int n_RechercheSSDACTR( char *RetCtr, short Rty, long Plc, unsigned char RetSec ) ;

int n_InitPerim (T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int n_ActionLignePerim  (char **ptb_InRecOwner, char **pbd_InRecChild) ;
int n_ConditionSyncPerim(char **ptb_InRecOwner, char **pbd_InRecChild);

int n_IniPrev (T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int n_ActionLignePre(char **ptb_InRecOwner, char **pbd_InRecChild) ;
int n_ConditionSyncPre(char **ptb_InRecOwner, char **pbd_InRecChild);

int n_IsR1Prev(char **ptb_InRec, char **ptb_InRec_Cur);
int n_IsR2Prev(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRupt1Prev(char **ptb_InRecOwner, char **pbd_InRecChild);
int n_ActionFirstRupt2Prev(char **ptb_InRecOwner, char **pbd_InRecChild);

int n_IsR1Plc(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionLastRuptPlc(char **ptb_InRec_Cur);
int n_ActionFirstRuptPlc(char **ptb_InRec_Cur);
int Kb_rupt1;       /* 1 si rupture de niveau 1, 0 sinon */

int n_InitPlc(T_RUPTURE_VAR *pbd_Rupt) ;
int n_ActionLignePlc(char **pbd_InRec_Cur);
int n_ActionFilsSansPerePRE(char **ptb_InRecOwner );   /*  jr 11 09 2003 */

int n_InitTACCPAR(T_RUPTURE_VAR  *pbd_Rupt);
int n_ActionLigneTACCPAR( char **ptb_InRecTACCPAR );
int n_RechercheTACCPAR( int ACMTRS );

typedef struct {
  int  Dettrs[1000];
  int  Acmtrs[1000];
  int  nb_acmtrs;
} T_POSTE_ACCPAR_DET;
T_POSTE_ACCPAR_DET ACM_DETT;

void init_SubTrsAssoLigne();
char* b_Parentoi = "1";
double  montant_Gap2 = 0;
double  newdiffgap4 = 0;


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
  /* Recuperation des parametres du programme */
  /* periode courante */
  strcpy(Ksz_cloprd, psz_GetCharArgv(1));
  /* date d'arrete */
  strcpy(Ksz_dbclo_d, psz_GetCharArgv(2));
  /* date de traitement */
  strcpy(Ksz_cre_d, psz_GetCharArgv(3));
  /* mois bilan en cours */
  strcpy(Ksz_balmth_d, psz_GetCharArgv(4));

  /* Formatage de la date de creation des previsions en sortie */

  sprintf( Ksz_Cre, "%s %s", Ksz_cre_d, "23:59:05" ) ;


  /* ouverture du fichier binaire en entree des correspondances retro vers acceptation */
  if ( n_OpenFileAppl ( "ESTC2020_I3", "rb", &Kp_InputFilSsdActr ) == ERR )
    ExitPgm( ERR_XX , "" ) ;


  if ( n_OpenFileAppl ("ESTC2020_I6", "rb", &Kp_SubTRSAssoFile) == ERR )
    ExitPgm ( ERR_XX , "" );
  if ( n_ChargerTsubTRSAsso(Kp_SubTRSAssoFile) == ERR )      ExitPgm( ERR_XX , "" ); 

  /* ouverture du fichier en sortie PREV */
  if ( n_OpenFileAppl ( "ESTC2020_O1", "wt", &Kp_OutputFilPrev ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if (n_InitTACCPAR(&bd_RuptTACCPAR) )
    ExitPgm ( ERR_XX , "" );
  /* Initialisation de la variable bd_RuptPre */


  /* Initialisation de la variable bd_RuptPlc */
  if ( n_InitPlc( &bd_RuptPlc ) )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptPre */
  if ( n_IniPrev( &bd_RuptPre ) )
    ExitPgm( ERR_XX , "" ) ;

// if ( n_InitPerim( &bd_RuptPer ) )
//    ExitPgm( ERR_XX , "" ) ;
//

  /* chargement de la table TSSDACTR en memoire */
  Kn_SsdActr_Nbp = n_ChargerSSDACTR( ) ;
  if ( Kn_SsdActr_Nbp >= MAX_SSDACTR )
    ExitPgm( ERR_XX , "Taille tableau TSSDACTR insuffisante " ) ;

  /* lancement du traitement du fichier ACCPAR */
  if ( n_ProcessingRuptureVar( &bd_RuptTACCPAR ) == ERR )     //[013]
    ExitPgm( ERR_XX , "" ) ;                                //[013]

  /* lancement du traitement du fichier PLAC */
  if ( n_ProcessingRuptureVar( &bd_RuptPlc ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC2020_I1", &( bd_RuptPlc.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC2020_I2", &( bd_RuptPre.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC2020_I3", &Kp_InputFilSsdActr ) == ERR )
    ExitPgm( ERR_XX , "" ) ;


  if (n_CloseFileAppl ("ESTC2020_I5", &(bd_RuptTACCPAR.pf_InputFil)) == ERR)
    ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTC2020_I6", &Kp_SubTRSAssoFile) == ERR)
    ExitPgm ( ERR_XX , "" );

//   if (n_CloseFileAppl ("ESTC2135_I6",&(bd_RuptPer.pf_InputFil)) == ERR)
//        ExitPgm ( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTC2020_O1", &Kp_OutputFilPrev ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_EndPgm() == ERR )
    ExitPgm( ERR_XX , "" );

  exit( OK ) ;
}

///*==============================================================================
//objet :
//        Initialisation de la synchronisation du maitre avec l'esclave Perim
//
//retour :
//        OK
//==============================================================================*/
//int n_InitPerim(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
//{
//        DEBUT_FCT("n_InitPerim");
//
//        memset( pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;
//
//        /* ouverture du fichier esclave */
//        n_OpenFileAppl ("ESTC2020_I6","rt",&(pbd_Rupt->pf_InputFil));
//
//        pbd_Rupt->n_NbRupture = 0;
//
//        /* fonction du test de la ligne du maitre avec l'esclave */
//        pbd_Rupt->ConditionEndSync      = n_ConditionSyncPerim ;
//
//        /* fonction d'action sur la ligne courante du fichier esclave */
//        pbd_Rupt->n_ActionLigne         = n_ActionLignePerim ;
//
//        pbd_Rupt->c_Separ               = '~' ;
//
//        RETURN_VAL (OK);
//}
//



/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du
        fichier maitre.

retour :
        OK
==============================================================================*/

int n_InitPlc( T_RUPTURE_VAR  *pbd_Rupt )
{
  DEBUT_FCT( "n_InitPlc" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

  /* ouverture du fichier esclave */
  if ( n_OpenFileAppl( "ESTC2020_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
    return ERR ;

  /* nombre de rupture a gerer */
  pbd_Rupt->n_NbRupture = 1 ;
  pbd_Rupt->n_ConditionRupture[0] = n_IsR1Plc;

  pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptPlc;

  /* fonction d'action sur la ligne courante */
  pbd_Rupt->n_ActionLigne = n_ActionLignePlc ;

  pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptPlc ;

  pbd_Rupt->c_Separ = SEPARATEUR ;

  RETURN_VAL( OK ) ;
}

/*==============================================================================
objet :
  fonction d'initialisation de la variable de gestion de rupture du fichier
  maitre.

retour :
  0K
==============================================================================*/
int n_IniPrev(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_IniPrev" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

  /* ouverture du fichier esclave PREV */
  if ( n_OpenFileAppl( "ESTC2020_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) )
    return ERR ;

  /* nombre de rupture a gerer */
  pbd_Rupt->n_NbRupture = 1 ;

// pbd_Rupt->n_ConditionRupture[1] = n_IsR1Prev;
  pbd_Rupt->n_ConditionRupture[0] = n_IsR2Prev;


//  pbd_Rupt->n_ActionFirst[1] = n_ActionFirstRupt1Prev;
  pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRupt2Prev;


  /* fonction du test de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncPre ;

  /* fonction d'action sur la ligne courante du fichier esclave */
  pbd_Rupt->n_ActionLigne = n_ActionLignePre ;

  /* fonction d'action quand le maitre n'a pas de fils PRE */
  pbd_Rupt->n_FilsSansPere = n_ActionFilsSansPerePRE;

  pbd_Rupt->c_Separ        = SEPARATEUR ;

  RETURN_VAL(OK);
}

/*==============================================================================
objet :
        fonction de test de rupture du niveau 1

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR1Plc(char **ptb_InRec, char **ptb_InRec_Cur)
{
  int ret;

  DEBUT_FCT("n_IsR1Plc");
//printf("n_IsR1Plc ptb_InRec [%s] ptb_InRec_Cur [%s]\n", ptb_InRec[PLA_RETCTR_NF], ptb_InRec_Cur[PLA_RETCTR_NF]);
  Kb_rupt1 = 0;

  if ( ( ret = strcmp(ptb_InRec[PLA_RETCTR_NF], ptb_InRec_Cur[PLA_RETCTR_NF])) != 0)
    return ret;
  if ( ( ret = strcmp(ptb_InRec[PLA_RETSEC_NF], ptb_InRec_Cur[PLA_RETSEC_NF])) != 0)
    return ret;
  if ( ( ret = strcmp(ptb_InRec[PLA_RTY_NF], ptb_InRec_Cur[PLA_RTY_NF])) != 0)
    return ret;
  RETURN_VAL (0);
}
/*==============================================================================
objet :
        fonction de test de rupture du niveau 1

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR1Prev(char **ptb_InRec, char **ptb_InRec_Cur)
{
  int ret;

  DEBUT_FCT("n_IsR1Prev");
  if ( ( ret = strcmp(ptb_InRec[PRE_CTR_NF], ptb_InRec_Cur[PRE_CTR_NF])) != 0)
    return ret;
  if ( ( ret = strcmp(ptb_InRec[PRE_SEC_NF], ptb_InRec_Cur[PRE_SEC_NF])) != 0)
    return ret;
  if ( ( ret = strcmp(ptb_InRec[PRE_UWY_NF], ptb_InRec_Cur[PRE_UWY_NF])) != 0)
    return ret;
  RETURN_VAL (0);
}
/*==============================================================================
objet :
        fonction de test de rupture du niveau 1

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR2Prev(char **ptb_InRec, char **ptb_InRec_Cur)
{
  int ret;

  DEBUT_FCT("n_IsR2Prev");
  if ( ( ret = strcmp(ptb_InRec[PRE_CTR_NF], ptb_InRec_Cur[PRE_CTR_NF])) != 0)
    return ret;
  if ( ( ret = strcmp(ptb_InRec[PRE_SEC_NF], ptb_InRec_Cur[PRE_SEC_NF])) != 0)
    return ret;
  if ( ( ret = strcmp(ptb_InRec[PRE_UWY_NF], ptb_InRec_Cur[PRE_UWY_NF])) != 0)
    return ret;
  if ( ( ret = strcmp(ptb_InRec[PRE_UWY_NF], ptb_InRec_Cur[PRE_UWY_NF])) != 0)
    return ret;
  if ( ( ret = strcmp(ptb_InRec[PRE_ACY_NF ], ptb_InRec_Cur[PRE_ACY_NF ])) != 0)
    return ret;
  if ( ( ret = strcmp(ptb_InRec[PRE_ESTMTH_NF ], ptb_InRec_Cur[PRE_ESTMTH_NF ])) != 0)
    return ret;
  if ( (ret = strcmp(ptb_InRec[PRE_ACMTRS_NT], ptb_InRec_Cur[PRE_ACMTRS_NT])) != 0 ) //[008]
    return ret;
  if ( (ret = strcmp(ptb_InRec[PRE_DETTRNCOD_CF], ptb_InRec_Cur[PRE_DETTRNCOD_CF])) != 0 )
    return ret;
  RETURN_VAL (0);
}

///*==============================================================================
//objet :
//  fonction lancee en rupture premiere
//
//retour :  OK ---> traitement correctement effectue
//    ERR --> probleme rencontre
//==============================================================================*/
//int n_ActionFirstRupt1Prev(
//  char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
//  char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
//{
//  DEBUT_FCT( "n_ActionFirstRupt1Prev" ) ;
//  b_Parentoi = 0;
//  montant_Gap2=0;
//
//    n_ProcessingRuptureSyncVar (&bd_RuptPer, pbd_InRecChild) ;
//
//  RETURN_VAL ( OK ) ;
//}


/*==============================================================================
objet :
  fonction lancee en rupture premiere

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRupt2Prev(
  char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
  char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
  DEBUT_FCT( "n_ActionFirstRupt1Prev" ) ;
  //strcpy(b_Parentoi ,"0");
  montant_Gap2 = 0;
  newdiffgap4 = 0;

  RETURN_VAL (OK);
}


/*==============================================================================
objet :
        fonction lancee pour chaque ligne du maitre

retour :
        0 ----> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptPlc (char **ptb_InRec_Cur) /* adresse de la ligne du maitre */

{
  DEBUT_FCT("n_ActionLastRuptPlc");

  /* lancement synchro */

  strcpy(Ksav_Ctr              , ptb_InRec_Cur[PLA_RETCTR_NF]);
  strcpy(Ksav_Sec              , ptb_InRec_Cur[PLA_RETSEC_NF]);
  strcpy(Ksav_PLA_RTY_NF       , ptb_InRec_Cur[PLA_RTY_NF]);
  Ksav_PLA_SSDRTO_B = atoi(ptb_InRec_Cur[PLA_SSDRTO_B]);
  Ksav_PLA_RETOVRCOM_B = atoi(ptb_InRec_Cur[PLA_RETOVRCOM_B]);
  Ksav_PLA_Plc = atoi(ptb_InRec_Cur[PLA_PLC_NT]);
  Ksav_RETSIGSHA = atof( ptb_InRec_Cur[PLA_RETSIGSHA_R] );

  Kc_PLA_SSDRTO_B = *ptb_InRec_Cur[PLA_SSDRTO_B];
  Kc_PLA_RETOVRCOM_B = *ptb_InRec_Cur[PLA_RETOVRCOM_B];
  Kc_PLA_Plc = atol( ptb_InRec_Cur[PLA_PLC_NT]);
  strcpy(Kc_PLA_pay_NF, ptb_InRec_Cur[PLA_PAY_NF]);

  RETURN_VAL (0);
}

/*==============================================================================
objet :
        fonction lancee pour chaque ligne du maitre

retour :
        0 ----> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRuptPlc  (char **ptb_InRec_Cur) /* adresse de la ligne du maitre */

{
  DEBUT_FCT("n_ActionFirstRuptPlc");

// printf("n_ActionFirstRuptPlc..[%s]\n", ptb_InRec_Cur[PLA_RETCTR_NF]);
  /* lancement synchro */

 // strcpy(Ksav_Ctr              , ptb_InRec_Cur[PLA_RETCTR_NF]);
 // strcpy(Ksav_Sec              , ptb_InRec_Cur[PLA_RETSEC_NF]);
//  strcpy(Ksav_PLA_RTY_NF       , ptb_InRec_Cur[PLA_RTY_NF]);
//  Ksav_PLA_SSDRTO_B = atoi(ptb_InRec_Cur[PLA_SSDRTO_B]);
//  Ksav_PLA_RETOVRCOM_B = atoi(ptb_InRec_Cur[PLA_RETOVRCOM_B]);
//  Ksav_PLA_Plc = atoi(ptb_InRec_Cur[PLA_PLC_NT]);
//  Ksav_RETSIGSHA = atof( ptb_InRec_Cur[PLA_RETSIGSHA_R] );
//
//  Kc_PLA_SSDRTO_B = *ptb_InRec_Cur[PLA_SSDRTO_B];
//
//  Kc_PLA_RETOVRCOM_B = *ptb_InRec_Cur[PLA_RETOVRCOM_B];
//
//  Kc_PLA_Plc = atol( ptb_InRec_Cur[PLA_PLC_NT]);
//
//  strcpy(Kc_PLA_pay_NF, ptb_InRec_Cur[PLA_PAY_NF]);
//


  RETURN_VAL (0);
}

/*==============================================================================
objet :
  fonction lancee pour chaque ligne

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePlc(
  char **ptb_InRec_Cur ) /* adresse de la ligne de l'esclave */
{
  DEBUT_FCT( "n_ActionLignePlc" ) ;


  /* synchronisation du fichier PRE pour chaque ligne */
  n_ProcessingRuptureSyncVar (&bd_RuptPre, ptb_InRec_Cur) ;

  RETURN_VAL( OK ) ;
}

//
///*==============================================================================
//objet :
//  fonction lancee pour chaque ligne
//
//retour :  OK ---> traitement correctement effectue
//    ERR --> probleme rencontre
//==============================================================================*/
//int n_ActionLignePerim(
//   char **ptb_InRecOwner ,/* adresse de la ligne du maitre */
//        char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
//{
//  DEBUT_FCT( "n_ActionLignePerim" ) ;
//
//  strcpy(b_Parentoi,ptb_InRecChild[PER_PARENTOI_B]);
//
//  RETURN_VAL( OK ) ;
//}


/*==============================================================================
objet :
  fonction de test de synchronisation

retour :
  0 ---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
  > 0     ---> pbd_InRecOwne> > pbd_InRecChild
  < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncPre(
  char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
  char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
  int ret ;

  DEBUT_FCT( "n_ConditionSyncPre" ) ;


  if ( ( ret = strcmp( pbd_InRecOwner[PLA_RETCTR_NF], pbd_InRecChild[PRE_CTR_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PLA_RETSEC_NF], pbd_InRecChild[PRE_SEC_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PLA_RTY_NF], pbd_InRecChild[PRE_UWY_NF] ) ) != 0 ) return ret ;

  RETURN_VAL( 0 ) ;
}

/*==============================================================================
objet :
  fonction de test de synchronisation

retour :
  0 ---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
  > 0     ---> pbd_InRecOwne> > pbd_InRecChild
  < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncPerim(
  char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
  char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
  int ret ;

  DEBUT_FCT( "n_ConditionSyncPre" ) ;


  if ( ( ret = strcmp( pbd_InRecOwner[PRE_CTR_NF], pbd_InRecChild[PER_CTR_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PRE_SEC_NF], pbd_InRecChild[PER_SEC_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PRE_UWY_NF], pbd_InRecChild[PER_UWY_NF] ) ) != 0 ) return ret ;

  RETURN_VAL( 0 ) ;
}
/*==============================================================================
objet :
  fonction lancee pour chaque ligne
PER
retour :
  OK ---> traitement correctement effectue
  ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePre(
  char **ptb_InRecOwner ,/* adresse de la ligne du maitre */
  char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
  int i;
  double d_amt = 0;
  double  diff_Gap = 0;
  char sz_d_amt [50];
  char sz_d_difgap [50];
  char sz_TrnCodAccpt[9] ; /* variable de travail : poste comptable retrocession */
  int  n_type_poste;
  int  n_poste_1;          /* poste en sortie */
  char  MsgAno[300] ;
  char  sz_lib_oricod[14] = "RETRO INTERNE";
  // Omega 2 B
  char ssd_cf[3], uwynf[5], uwnt[5], endnt[5], secnf[4], acmtrs[5];
  int reslt = 0;
  char sz_DeTTRN[6];
  int post_modif;
  char Ori_Ctr[10];
  char Ori_Sec[2];
  char Ori_Uwy[5];

  DEBUT_FCT( "n_ActionLignePre" ) ;

  // modif abir pour enlever les job  1-12

  init_SubTrsAssoLigne();

// printf("n_ActionLignePre..\n");

  /* traitement principal */

  strcpy(Ksav_Ctr              , ptb_InRecOwner[PLA_RETCTR_NF]);
  strcpy(Ksav_Sec              , ptb_InRecOwner[PLA_RETSEC_NF]);
  strcpy(Ksav_PLA_RTY_NF       , ptb_InRecOwner[PLA_RTY_NF]);

  Kc_PLA_SSDRTO_B = *ptb_InRecOwner[PLA_SSDRTO_B];

  Kc_PLA_RETOVRCOM_B = *ptb_InRecOwner[PLA_RETOVRCOM_B];

  Kc_PLA_Plc = atol( ptb_InRecOwner[PLA_PLC_NT]);

  strcpy(Kc_PLA_pay_NF, ptb_InRecOwner[PLA_PAY_NF]);


  if ( Kc_PLA_SSDRTO_B == '1')
    // JR  mis en commentaire le 10/12/2004 il faut envoyer les mvts a zero !!!
    //  && fabs(atof(ptb_InRecChild[PRE_ESTMNT_M])) >= 0.001 )
  {
    /* recherche de la correspondance dans la table TSSDACTR */
    i = n_RechercheSSDACTR( ptb_InRecChild[PRE_CTR_NF], atoi( ptb_InRecChild[PRE_UWY_NF] ),
                            Kc_PLA_Plc, (char) atoi( ptb_InRecChild[PRE_SEC_NF] ) ) ;
    /* si la recherche dans TSSDACTR n'aboutit pas, generation
    d'une anomalie et pas d'ecriture en sortie */
    if ( i == -1 )
    {
      sprintf( MsgAno, "the research in BRET..TSSDACTR failed for the contract ( RETCTR_NF %s - RTY_NF %s - RETSEC_NF %s - RETUW_NT %s - PLC_NT %ld ) \n",
               ptb_InRecChild[PRE_CTR_NF],
               ptb_InRecChild[PRE_UWY_NF],
               ptb_InRecChild[PRE_SEC_NF],
               ptb_InRecChild[PRE_UW_NT],
               Kc_PLA_Plc ) ;

      n_WriteAno( MsgAno ) ;
    }
    else
    {
      /* calcul du poste acceptation a partir du poste retrocession */
      /* type_poste correspondant aux 3 derniers chiffres */

      n_type_poste = atoi(ptb_InRecChild[PRE_ACMTRS_NT]) % 1000;
      n_poste_1 = 1000 + n_type_poste;

      /* calcul du poste acceptation a partir du poste retrocession */
      strcpy( sz_TrnCodAccpt, ptb_InRecChild[PRE_DETTRS_CF] ) ;
      strcpy (sz_DeTTRN, ptb_InRecChild[PRE_DETTRNCOD_CF] ) ;
      sz_DeTTRN[5] = 0;
      post_modif = 0;
      switch ( atoi(ptb_InRecChild[PRE_ACMTRS_NT]) )
      {
      case 2150:
        n_poste_1 = 1140;
        post_modif = 1;
        break;
      case 2145:
        n_poste_1 = 1150;
        post_modif = 1;
        break;
      }

      if ( post_modif == 1)
      {
        sprintf(sz_TrnCodAccpt, "%d", n_RechercheTACCPAR(n_poste_1)); //[013]
        sz_TrnCodAccpt[8] = 0;

        ptb_InRecChild[PRE_DETTRS_CF] = sz_TrnCodAccpt;

        strcpy(sz_DeTTRN, ptb_InRecChild[PRE_DETTRS_CF] + 2);
        sz_DeTTRN[5] = 0;

        /* [017] - Spira 56493 - On ne remplace pas le Poste d'origine par le poste associé à l'ACMTRS */
        /* ptb_InRecChild[PRE_DETTRNCOD_CF] = sz_DeTTRN; */
      }

      /* Poste retard transforme en poste estime */

      if ( sz_TrnCodAccpt[7] == '4' )
        sz_TrnCodAccpt[7] = '2' ;/* suffixe force a 2 */ // a enlever

      /* transformation des L0 en liberations variables
               valable jusqu a la fin du bilan 1999           */

      /*    if ( sz_TrnCodAccpt[6] == '1' )
            sz_TrnCodAccpt[6] = '0' ; septieme caractere force a 0 */

      /* Cas de la surcommission */
      if ( strcmp( ptb_InRecChild[PRE_DETTRNCOD_CF] , "12110" ) == 0 )
      {
        if ( Kc_PLA_RETOVRCOM_B == '1' )
        {
          reslt = n_FindTsubTRSAsso(&SubTrsAssoLigne, 7, 1, ptb_InRecChild[PRE_DETTRNCOD_CF]); // [017]
          if (reslt != -1)
            ptb_InRecChild[PRE_DETTRNCOD_CF] = SubTrsAssoLigne.DETTRNCOD2_CF;
        }
        else
        {
          reslt = n_FindTsubTRSAsso(&SubTrsAssoLigne, 7, 2, ptb_InRecChild[PRE_DETTRNCOD_CF]); // [017]
          if (reslt != -1)
          {
            ptb_InRecChild[PRE_DETTRNCOD_CF] = SubTrsAssoLigne.DETTRNCOD2_CF;
          }
        }
      }

      //    else {
      //
      //      /* Le poste est-t-il dans TDETTRS */
      //      j=n_GetPosDettrs(sz_TrnCodAccpt,Ktbd_DetTrs,Kn_DetTrs_Nbp);
      //
      //      /* si la recherche dans TDETTRS n'aboutit pas, generation
      //         d'une anomalie et pas d'ecriture en sortie */
      //      if ((j != -1)&&(b_IsBlankOrEmpty( Ktbd_DetTrs[j].RETTRSCOD_CF) == FALSE))
      //        strcpy( sz_TrnCodAccpt, Ktbd_DetTrs[j].RETTRSCOD_CF ) ;
      //
      //      else {
      //        /*      printf ("prefixe");  */
      //        /* Prefixe retrocession change en prefixe acceptation */
      if ( sz_TrnCodAccpt[0] == '2' )
        sz_TrnCodAccpt[0] = '1' ;/* prefixe 2, force a 1 */

      if ( sz_TrnCodAccpt[0] == '4' )
        sz_TrnCodAccpt[0] = '3' ;/* prefixe 4, force a 3 */
      //      }
      //    }


      //   d_amt =  atof(ptb_InRecChild[PRE_ESTMNT_M]) * -1;
      //   sprintf(d_amt = atof(ptb_InRecChild[PRE_ESTMNT_M]) * atof(ptb_InRecOwner[PLA_RETSIGSHA_R]) ) * -1 ;         // SPOT 14961 14/02/2008


      //    printf("\n");
      //  printf("********   amt *************");
      //  printf("  amt = %-.3lf  \n",  d_amt);
      //    printf("\n");
      sprintf(ssd_cf, "%d", Ktbd_SsdActr[i].RTOSSD_CF);
      sprintf(uwynf , "%d" , Ktbd_SsdActr[i].UWY_NF);
      sprintf(uwnt, "%d", Ktbd_SsdActr[i].UW_NT);
      sprintf(endnt, "%d", Ktbd_SsdActr[i].END_NT);
      sprintf(secnf, "%d", Ktbd_SsdActr[i].SEC_NF);
      sprintf(acmtrs , "%d", n_poste_1);

      sprintf(Ori_Ctr, "%s", ptb_InRecChild[PRE_CTR_NF]); //[008]
      Ori_Ctr[9] = 0;
      sprintf(Ori_Sec, "%s", ptb_InRecChild[PRE_SEC_NF]);
      Ori_Sec[1] = 0;
      sprintf(Ori_Uwy, "%s", ptb_InRecChild[PRE_UWY_NF]);
      Ori_Uwy[4] = 0;

      ptb_InRecChild[PRE_ORISSD_CF] = ptb_InRecChild[PRE_SSD_CF];

      ptb_InRecChild[PRE_SSD_CF] = ssd_cf;
      ptb_InRecChild[PRE_CTR_NF] =  Ktbd_SsdActr[i].CTR_NF;      //ptb_InRecChild[PRE_CTR_NF],
      ptb_InRecChild[PRE_END_NT] = endnt;
      ptb_InRecChild[PRE_SEC_NF] = secnf;
      ptb_InRecChild[PRE_UWY_NF] = uwynf;
      ptb_InRecChild[PRE_UW_NT] =  uwnt;
      ptb_InRecChild[PRE_CRE_D] = Ksz_Cre;
      ptb_InRecChild[PRE_ACMTRS_NT] = acmtrs;

      ptb_InRecChild[PRE_PAY_NF] = Kc_PLA_pay_NF;
      ptb_InRecChild[PRE_DETTRS_CF] = sz_TrnCodAccpt;
      ptb_InRecChild[PRE_ORICOD_LS] = sz_lib_oricod;
      ptb_InRecChild[PRE_CLOPRD] =   Ksz_cloprd ;
      ptb_InRecChild[PRE_DBCLO_D] = Ksz_dbclo_d;
      ptb_InRecChild[PRE_ORICRE_D] = Ksz_cre_d;


      ptb_InRecChild[PRE_ORICTR_NF] = Ori_Ctr;
      ptb_InRecChild[PRE_ORISEC_NF] = Ori_Sec;
      ptb_InRecChild[PRE_ORIUWY_NF] = Ori_Uwy;

      ptb_InRecChild[PRE_BALSHTMTH_NF] = Ksz_balmth_d;


      // Gestion des montant
      d_amt = (atof(ptb_InRecChild[PRE_ESTMNT_M]) * atof(ptb_InRecOwner[PLA_RETSIGSHA_R]) ) * -1;
      diff_Gap = (atof(ptb_InRecChild[PRE_GAAPDIFF_M])  * atof(ptb_InRecOwner[PLA_RETSIGSHA_R]) ) * -1;



      // if ( atoi(ptb_InRecChild[PRE_GAAP_NF])==2)
      //   {
      //     montant_Gap2= d_amt;

      //   }
      //   if ((atoi(ptb_InRecChild[PRE_GAAP_NF])==3) && (strcmp(b_Parentoi ,"0")==0))
      //   {
      //     newdiffgap4= diff_Gap * -1 ;
      //     diff_Gap = 0;
      //   }
      // if ((atoi(ptb_InRecChild[PRE_GAAP_NF])==3) && (strcmp(b_Parentoi ,"1")==0))
      //   {
      //     //d_amt= montant_Gap2;
      //     diff_Gap = 0;
      //   }

      // if ( (atoi(ptb_InRecChild[PRE_GAAP_NF])==4) || (atoi(ptb_InRecChild[PRE_GAAP_NF])==5) )
      //     {
      //    //d_amt= montant_Gap2;
      //     if( (strcmp(b_Parentoi ,"1")==0) || (atoi(ptb_InRecChild[PRE_GAAP_NF])==5))
      //      {
      //      diff_Gap = 0;
      //      }
      //      else  // pbd_InRecChild[PRE_GAAP_NF])==3 && (strcmp(b_Parentoi ,"0") => on garde M3 dans le Gap 3 et on est gap 4 => diff gap = M2- M3
      //      diff_Gap =  newdiffgap4;

      //     }




      if (fabs(d_amt) < 0.001)    //[010]
        d_amt = 0;
      if (fabs(diff_Gap) < 0.001)    //[011]
        diff_Gap = 0;
      sprintf(sz_d_amt, "%.3lf" , d_amt);
      ptb_InRecChild[PRE_ESTMNT_M] = sz_d_amt;
      sprintf(sz_d_difgap, "%.3lf" , diff_Gap);
      ptb_InRecChild[PRE_GAAPDIFF_M] = sz_d_difgap;


//[009]
      n_WriteCols(Kp_OutputFilPrev , ptb_InRecChild, '~', 0 );
    }
  }

  RETURN_VAL( OK ) ;
}

/*==============================================================================
objet :
        fonction lancee quand le pere n'a pas de fils GT
retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre

==============================================================================*/

int n_ActionFilsSansPerePRE(
  char **ptb_InRecChild   /* adresse de la ligne du maitre */
)
{
  int i;
  double d_amt = 0;
  double  diff_Gap = 0;
  char sz_d_amt [50];
  char sz_d_difgap [50];
  char sz_TrnCodAccpt[9] ; /* variable de travail : poste comptable retrocession */
  int  n_type_poste;
  int  n_poste_1;          /* poste en sortie */
  char  MsgAno[300] ;
  char  sz_lib_oricod[14] = "RETRO INTERNE";
  char ssd_cf[3], uwynf[5], uwnt[5], endnt[5], secnf[4], acmtrs[5];
  int reslt = 0;
  char sz_DeTTRN[6];
  int post_modif;
  char Ori_Ctr[10] = "";
  char Ori_Sec[2] = "";
  char Ori_Uwy[5] = "";

  DEBUT_FCT("n_ActionFilsSansPerePRE");
  init_SubTrsAssoLigne();

//printf("n_ActionFilsSansPerePRE..PREVISION SANS PLACEMENT [%s] Ksav_Ctr[%s]\n", ptb_InRecChild[PRE_CTR_NF], Ksav_Ctr);

  /* traitement principal */
  if ( (strcmp(ptb_InRecChild[PRE_CTR_NF], Ksav_Ctr) == 0 ) &&
       (strcmp(ptb_InRecChild[PRE_SEC_NF], Ksav_Sec) == 0 )  )
  {
    if ( Kc_PLA_SSDRTO_B == '1')
      // JR  mis en commentaire le 10/12/2004 il faut envoyer les mvts a zero !!!
      //  && fabs(atof(ptb_InRecChild[PRE_ESTMNT_M])) >= 0.001 )
    {
      /* recherche de la correspondance dans la table TSSDACTR */
      i = n_RechercheSSDACTR( ptb_InRecChild[PRE_CTR_NF], atoi (Ksav_PLA_RTY_NF),
                              Kc_PLA_Plc, (char) atoi( ptb_InRecChild[PRE_SEC_NF] ) ) ;

      /* si la recherche dans TSSDACTR n'aboutit pas, generation
         d'une anomalie et pas d'ecriture en sortie */

      if ( i == -1 )
      {
        sprintf( MsgAno, "the research in BRET..TSSDACTR failed for the contract ( RETCTR_NF %s - RTY_NF %s - RETSEC_NF %s - RETUW_NT %s - PLC_NT %ld ) \n",
                 ptb_InRecChild[PRE_CTR_NF],
                 ptb_InRecChild[PRE_UWY_NF],
                 ptb_InRecChild[PRE_SEC_NF],
                 ptb_InRecChild[PRE_UW_NT],
                 Kc_PLA_Plc ) ;

        n_WriteAno( MsgAno ) ;
      }
      else
      {

        /* calcul du poste acceptation a partir du poste retrocession */
        /* type_poste correspondant aux 3 derniers chiffres */
        n_type_poste = atoi(ptb_InRecChild[PRE_ACMTRS_NT]) % 1000;
        n_poste_1 = 1000 + n_type_poste;

        /* calcul du poste acceptation a partir du poste retrocession */
        strcpy( sz_TrnCodAccpt, ptb_InRecChild[PRE_DETTRS_CF] ) ;
        strcpy (sz_DeTTRN, ptb_InRecChild[PRE_DETTRNCOD_CF] ) ;
        sz_DeTTRN[5] = 0;
        post_modif = 0;
        switch ( atoi(ptb_InRecChild[PRE_ACMTRS_NT]) )
        {
        case 2150:
          n_poste_1 = 1140;
          post_modif = 1;
          break;

        case 2145:
          n_poste_1 = 1150;
          post_modif = 1;
          break;
        }


        if ( post_modif == 1)
        {
          sprintf(sz_TrnCodAccpt, "%d", n_RechercheTACCPAR(n_poste_1));
          sz_TrnCodAccpt[8] = 0;
          ptb_InRecChild[PRE_DETTRS_CF] = sz_TrnCodAccpt;
          strcpy(sz_DeTTRN, ptb_InRecChild[PRE_DETTRS_CF] + 2);
          sz_DeTTRN[5] = 0;
          /* [017] - Spira 56493 - On ne remplace pas le Poste d'origine par le poste associé à l'ACMTRS */
          /* ptb_InRecChild[PRE_DETTRNCOD_CF] = sz_DeTTRN; */
        }
        /* Poste retard transforme en poste estime */

        if ( sz_TrnCodAccpt[7] == '4' )
          sz_TrnCodAccpt[7] = '2' ;/* suffixe force a 2 */


        /* Cas de la surcommission */
        if ( strcmp( ptb_InRecChild[PRE_DETTRNCOD_CF] , "12110" ) == 0 )
        {

          if ( Kc_PLA_RETOVRCOM_B == '1' )
          {
            reslt = n_FindTsubTRSAsso(&SubTrsAssoLigne, 7, 1, ptb_InRecChild[PRE_DETTRNCOD_CF]);
            if (reslt != -1)
              ptb_InRecChild[PRE_DETTRNCOD_CF] = SubTrsAssoLigne.DETTRNCOD1_CF;
          }
          else
          {
            reslt = n_FindTsubTRSAsso(&SubTrsAssoLigne, 7, 2, ptb_InRecChild[PRE_DETTRNCOD_CF]);
            if (reslt != -1)
              ptb_InRecChild[PRE_DETTRNCOD_CF] = SubTrsAssoLigne.DETTRNCOD1_CF;


          }
        }

        if ( sz_TrnCodAccpt[0] == '2' )
          sz_TrnCodAccpt[0] = '1' ;/* prefixe 2, force a 1 */

        if ( sz_TrnCodAccpt[0] == '4' )
          sz_TrnCodAccpt[0] = '3' ;/* prefixe 4, force a 3 */





        sprintf(ssd_cf, "%d" , Ktbd_SsdActr[i].RTOSSD_CF);
        sprintf(uwynf , "%d" , Ktbd_SsdActr[i].UWY_NF);
        sprintf(uwnt, "%d", Ktbd_SsdActr[i].UW_NT);
        sprintf(endnt, "%d", Ktbd_SsdActr[i].END_NT);
        sprintf(secnf, "%d", Ktbd_SsdActr[i].SEC_NF);
        sprintf(acmtrs , "%d", n_poste_1);

        sprintf(Ori_Ctr, "%s", ptb_InRecChild[PRE_CTR_NF]); //[008]
        Ori_Ctr[9] = 0;
        sprintf(Ori_Sec, "%s", ptb_InRecChild[PRE_SEC_NF]);
        Ori_Sec[1] = 0;
        sprintf(Ori_Uwy, "%s", ptb_InRecChild[PRE_UWY_NF]);
        Ori_Uwy[4] = 0;

        ptb_InRecChild[PRE_ORISSD_CF] = ptb_InRecChild[PRE_SSD_CF];

        ptb_InRecChild[PRE_SSD_CF] = ssd_cf;
        ptb_InRecChild[PRE_CTR_NF] = Ktbd_SsdActr[i].CTR_NF;
        ptb_InRecChild[PRE_END_NT] = endnt;
        ptb_InRecChild[PRE_SEC_NF] = secnf;
        ptb_InRecChild[PRE_UW_NT] = uwnt;
//        ptb_InRecChild[PRE_UWY_NF] = uwynf;
        ptb_InRecChild[PRE_CRE_D] = Ksz_Cre;
        ptb_InRecChild[PRE_ACMTRS_NT] = acmtrs;

        ptb_InRecChild[PRE_PAY_NF] = Kc_PLA_pay_NF;
        ptb_InRecChild[PRE_DETTRS_CF] = sz_TrnCodAccpt;
        ptb_InRecChild[PRE_ORICOD_LS] = sz_lib_oricod;

        ptb_InRecChild[PRE_CLOPRD] =   Ksz_cloprd ;
        ptb_InRecChild[PRE_DBCLO_D] = Ksz_dbclo_d;
        ptb_InRecChild[PRE_ORICRE_D] = Ksz_cre_d;


        ptb_InRecChild[PRE_ORICTR_NF] = Ori_Ctr;
        ptb_InRecChild[PRE_ORISEC_NF] = Ori_Sec;
        ptb_InRecChild[PRE_ORIUWY_NF] = Ori_Uwy;

        ptb_InRecChild[PRE_BALSHTMTH_NF] = Ksz_balmth_d;

        // Gestion des montant
        d_amt = ( atof(ptb_InRecChild[PRE_ESTMNT_M]) * Ksav_RETSIGSHA ) * -1;
        diff_Gap = (atof(ptb_InRecChild[PRE_GAAPDIFF_M])  * Ksav_RETSIGSHA ) * -1;

        if (fabs(d_amt) < 0.001)    //[010]
          d_amt = 0;

        if (fabs(diff_Gap) < 0.001)    //[011]
          diff_Gap = 0;

        sprintf(sz_d_amt, "%.3lf", d_amt);               //[012]
        ptb_InRecChild[PRE_ESTMNT_M] = sz_d_amt;
        sprintf(sz_d_difgap, "%.3lf" , diff_Gap);    //[012]
        ptb_InRecChild[PRE_GAAPDIFF_M] = sz_d_difgap;

        n_WriteCols(Kp_OutputFilPrev , ptb_InRecChild, '~' , 0);


      }
    }
  }
  RETURN_VAL( OK ) ;
}

/*==============================================================================
objet :
  fonction de chargement du fichier binaire des correspondances retro vers
acceptation

retour :  le nombre d'enregistrements charges dans le tableau

==============================================================================*/
int n_ChargerSSDACTR( void )
{
  DEBUT_FCT( "n_ChargerSSDACTR" ) ;

  RETURN_VAL( fread( Ktbd_SsdActr, sizeof( T_SSDACTR ), MAX_SSDACTR, Kp_InputFilSsdActr ) ) ;
}


/*==============================================================================
objet :
  fonction de recherche des correspondances retro vers acceptation

retour :  le numero de poste dans le tableau si la fonction a trouve
    sinon -1
==============================================================================*/
int n_RechercheSSDACTR( char *RetCtr, short Rty, long Plc, unsigned char RetSec )
{
  int i, ret1, ret2, ret3, ret4;

  for ( i = 0; i < Kn_SsdActr_Nbp; i++ )
  {
    ret1 = strcmp( RetCtr, Ktbd_SsdActr[i].RETCTR_NF ) ;
    if ( ret1 == 0 )
    {
      ret2 = Rty - Ktbd_SsdActr[i].RTY_NF ;
      if ( ret2 == 0 )
      {
        ret3 = Plc - Ktbd_SsdActr[i].PLC_NT ;
        if ( ret3 == 0 )
        {
          ret4 = RetSec - Ktbd_SsdActr[i].RETSEC_NF ;
          if ( ret4 == 0 )
            return ( i ) ;
          else if ( ret4 < 0 ) return ( -1 ) ;
        }
        else if ( ret3 < 0 ) return ( -1 ) ;
      }
      else if ( ret2 < 0 ) return ( -1 ) ;
    }
    else if ( ret1 < 0 ) return ( -1 ) ;
  }

  return ( -1 ) ;
}
/*==========================================================================
     Objet :    Initialisation de la structure TRSASSO

     Nom:       init_SubTrsAssoLigne

     Parametres:


     Retour:    0
===========================================================================*/
void init_SubTrsAssoLigne()
{

  strcpy (SubTrsAssoLigne.ASSOTYP_CT, ""); //[007]
  SubTrsAssoLigne.CTX_NT = 0;
  strcpy (SubTrsAssoLigne.DETTRNCOD1_CF, "");
  strcpy(SubTrsAssoLigne.CTX_LL, "");
  strcpy (SubTrsAssoLigne.DETTRNCOD2_CF, "");
  strcpy (SubTrsAssoLigne.DETTRNCOD3_CF, "");
  SubTrsAssoLigne.GUI_B = 0;
  SubTrsAssoLigne.ACMTRS_NT = 0;
  strcpy(SubTrsAssoLigne.CRE_D, "");
  strcpy(SubTrsAssoLigne.CREUSR_CF, "");
  strcpy(SubTrsAssoLigne.LSTUPD_D, "");
  strcpy(SubTrsAssoLigne.LSTUPDUSR_CF, "");
}

/*==============================================================================
objet :     Initialisation du fichier
retour:     OK
==============================================================================*/
int n_InitTACCPAR(T_RUPTURE_VAR  *pbd_Rupt)
{
  DEBUT_FCT("n_InitTACCPAR");

  memset( pbd_Rupt, 0, sizeof(T_RUPTURE_VAR) ) ;

  // ouverture du fichier esclave
  n_OpenFileAppl ("ESTC2020_I5", "rt", &(pbd_Rupt->pf_InputFil));

  pbd_Rupt->n_NbRupture           = 0  ;
  pbd_Rupt->n_ActionLigne         = n_ActionLigneTACCPAR;
  pbd_Rupt->c_Separ   = '~' ;

  RETURN_VAL(OK);
}



/*==============================================================================
objet : fonction lancee pour chaque ligne du perimetre
retour: OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneTACCPAR( char **ptb_InRecTACCPAR )
{
  ACM_DETT.Acmtrs[ACM_DETT.nb_acmtrs] = atoi( ptb_InRecTACCPAR[ACC_ACMTRS_NT]);
  ACM_DETT.Dettrs[ACM_DETT.nb_acmtrs] = atoi(ptb_InRecTACCPAR[ACC_DETTRS_CF]);

  ACM_DETT.nb_acmtrs++;

  return (0);
  RETURN_VAL(OK);
}

/*=============================================================================*/
int n_RechercheTACCPAR( int ACMTRS )
{
  int i = 0;
  for (i = 0; i <= ACM_DETT.nb_acmtrs; i++)
  {
    if (ACM_DETT.Acmtrs[i] == ACMTRS)
      return (ACM_DETT.Dettrs[i]);
  }

  return 99999999;
}
