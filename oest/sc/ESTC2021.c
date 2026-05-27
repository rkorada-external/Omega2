

/*==============================================================================
nom de l'application          : spira 43323
nom du source                 : ESTC2021.c
revision                      : $Revision: 1.4 $
date de creation              : 15/01/2015
auteur                        : S. ASKRI
references des specifications :
squelette de base             : batch
------------------------------------------------------------------------------
description :


------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <utctlib.h>
#include <struct.h>
#include "estserv.h"


/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*---------------------------------------------*/
#define BATCH_B                 "1"

/*----------------------*/
/* variables de travail */
/*----------------------*/
 
FILE                     *Kp_PrevOutFile;

T_RUPTURE_VAR             bd_RuptSpiLifest;
T_RUPTURE_SYNC_VAR        bd_SyncPrev; 

/*--------------------*/
/* procedures locales */
/*--------------------*/

int     n_InitSpiLifest(T_RUPTURE_VAR *ptd_Rupt) ;
int     n_ConditionRupture1(char **ptb_InRec, char **ptb_InRec_Cur);
int     n_ActionLastRuptLifest1(char **ptb_InRec_Cur);

int     n_InitSyncLifest(T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int     n_ConditionSyncPrev(char **bd_RuptPrev, char **bd_RuptSpiLifest); 
int     n_ActionLigne(char **pbd_InRecOwner , char **pbd_InRecChild);

/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{
    /* Initialisation des signaux */
    InitSig () ;

    if (n_BeginPgm(argc  ,argv) == ERR)                                         ExitPgm ( ERR_XX , "");

    /* ouverture des fichiers */
    if (n_OpenFileAppl ("ESTC2021_O", "wt", &Kp_PrevOutFile) == ERR)            ExitPgm( ERR_XX, "Cannot open ESTC2021_O file! ");

     /* Initialisation de la varible bd_RuptPrev */
    if (n_InitSpiLifest(&bd_RuptSpiLifest) == ERR)                                  ExitPgm( ERR_XX, "Call of n_InitSpiLifest() fails");
    if (n_InitSyncLifest(&bd_SyncPrev) == ERR)                                  ExitPgm( ERR_XX, "Call of n_InitSpiLifest() fails");

    /* Lancement du traitement du fichier */
    if (n_ProcessingRuptureVar(&bd_RuptSpiLifest) == ERR)                       ExitPgm( ERR_XX, "Call of n_ProcessingRuptureVar() fails");

    /* fermeture des fichiers */
    if (n_CloseFileAppl ("ESTC2021_I1",&(bd_RuptSpiLifest.pf_InputFil))== ERR ) ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC2021_I2",&(bd_SyncPrev.pf_InputFil))== ERR)       ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC2021_O",&Kp_PrevOutFile)== ERR)                   ExitPgm ( ERR_XX , "" );

    if ( n_EndPgm () == ERR )                                                   ExitPgm ( ERR_XX , "" );

    exit(OK) ;
}

/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du
        fichier maitre.

retour :
        OK
==============================================================================*/
int n_InitSpiLifest(T_RUPTURE_VAR *pbd_Rupt)
{
  DEBUT_FCT("n_InitSpiLifest");
  memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

  if (n_OpenFileAppl("ESTC2021_I1", "rt", &(pbd_Rupt->pf_InputFil)) != OK)     RETURN_VAL(ERR);

  pbd_Rupt->n_NbRupture                   = 1;
  pbd_Rupt->n_ConditionRupture[0]         = n_ConditionRupture1;
  pbd_Rupt->n_ActionLast[0]               = n_ActionLastRuptLifest1 ;

  pbd_Rupt->c_Separ                       = SEPARATEUR;

  RETURN_VAL(OK);
}



/*==============================================================================
objet :     Condition de rupture LIFEP
retour:     0 ----> OK
==============================================================================*/
int n_ConditionRupture1(char **ptb_InRec, char **ptb_InRec_Cur)
{
    int ret = 0;
    DEBUT_FCT("n_ConditionRupture");

   if ((ret = strcmp(ptb_InRec[PRE_CTR_NF],       ptb_InRec_Cur[PRE_CTR_NF]))       != 0)           RETURN_VAL(ret);
   if ((ret = strcmp(ptb_InRec[PRE_SEC_NF],       ptb_InRec_Cur[PRE_SEC_NF]))       != 0)           RETURN_VAL(ret);
   if ((ret = strcmp(ptb_InRec[PRE_UWY_NF],       ptb_InRec_Cur[PRE_UWY_NF]))       != 0)           RETURN_VAL(ret);
   if ((ret = strcmp(ptb_InRec[PRE_ACY_NF],       ptb_InRec_Cur[PRE_ACY_NF]))       != 0)           RETURN_VAL(ret);
   if ((ret = strcmp(ptb_InRec[PRE_ESTMTH_NF],    ptb_InRec_Cur[PRE_ESTMTH_NF]))    != 0)           RETURN_VAL(ret);
   if ((ret = strcmp(ptb_InRec[PRE_ACMTRS_NT],    ptb_InRec_Cur[PRE_ACMTRS_NT]))    != 0)           RETURN_VAL(ret);
   if ((ret = strcmp(ptb_InRec[PRE_DETTRNCOD_CF], ptb_InRec_Cur[PRE_DETTRNCOD_CF])) != 0)           RETURN_VAL(ret);
   if ((ret = strcmp(ptb_InRec[PRE_GAAP_NF],      ptb_InRec_Cur[PRE_GAAP_NF]))      != 0)           RETURN_VAL(ret);

    RETURN_VAL(OK);
}



/*==============================================================================
objet :
        fonction lancee pour la derniere rupture du maitre

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptLifest1(char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionLastRuptLifest");
  
    if (n_ProcessingRuptureSyncVar (&bd_SyncPrev, ptb_InRec_Cur) == ERR)          RETURN_VAL(ERR);

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
        Initialisation de la synchronisation du maitre avec l'esclave Lifest

retour :
        OK
==============================================================================*/
int n_InitSyncLifest(T_RUPTURE_SYNC_VAR  *pbd_SyncPrev)
{
    DEBUT_FCT("n_InitSyncLifest");
    memset( pbd_SyncPrev,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

    /* ouverture du fichier esclave */
    n_OpenFileAppl ("ESTC2021_I2","rt",&(pbd_SyncPrev->pf_InputFil));

    /* fonction du test de la ligne du maitre avec l'esclave */
    pbd_SyncPrev->ConditionEndSync      = n_ConditionSyncPrev;

     /* fonction d'action pour chaque ligne du lifest synchronisee avec le maitre */
    pbd_SyncPrev->n_ActionLigne         = n_ActionLigne;
    
    pbd_SyncPrev->c_Separ               = '~' ;

    RETURN_VAL(OK);
}



/*==============================================================================
objet :
        fonction de synchronisation

retour :
        0       ---> pbd_InRecOwner = pbd_InRecChild
                        ( egalite de rubriques a synchroniser)
        > 0     ---> pbd_InRecOwne> > pbd_InRecChild
        < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncPrev(
        char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
        char **pbd_InRecChild  /* adresse de la ligne de l'esclave */
        )
{
    int ret;

    DEBUT_FCT("n_ConditionSyncPrev");

   if ((ret = strcmp(pbd_InRecOwner[PRE_CTR_NF],       pbd_InRecChild[PRE_CTR_NF]))       != 0)           RETURN_VAL(ret);
   if ((ret = strcmp(pbd_InRecOwner[PRE_SEC_NF],       pbd_InRecChild[PRE_SEC_NF]))       != 0)           RETURN_VAL(ret);
   if ((ret = strcmp(pbd_InRecOwner[PRE_UWY_NF],       pbd_InRecChild[PRE_UWY_NF]))       != 0)           RETURN_VAL(ret);
   if ((ret = strcmp(pbd_InRecOwner[PRE_ACY_NF],       pbd_InRecChild[PRE_ACY_NF]))       != 0)           RETURN_VAL(ret);
   if ((ret = strcmp(pbd_InRecOwner[PRE_ESTMTH_NF],    pbd_InRecChild[PRE_ESTMTH_NF]))    != 0)           RETURN_VAL(ret);
   if ((ret = strcmp(pbd_InRecOwner[PRE_ACMTRS_NT],    pbd_InRecChild[PRE_ACMTRS_NT]))    != 0)           RETURN_VAL(ret);
   if ((ret = strcmp(pbd_InRecOwner[PRE_DETTRNCOD_CF], pbd_InRecChild[PRE_DETTRNCOD_CF])) != 0)           RETURN_VAL(ret);
   if ((ret = strcmp(pbd_InRecOwner[PRE_GAAP_NF],      pbd_InRecChild[PRE_GAAP_NF]))      != 0)           RETURN_VAL(ret);


    RETURN_VAL(0);
}


// ==============================================================================
// objet :     fonction lancee pour chaque ligne Lifest synchronisee avec le maitre
// retour :    0 ---> traitement correctement effectue
//             ERR --> probleme rencontre
// ==============================================================================
 int n_ActionLigne(char **pbd_InRecOwner , char **pbd_InRecChild)
 {
  
  char *psz_ligne[PRE_NBCOL+1];
  int j;

  DEBUT_FCT("n_ActionLigne");

  for (j = 0; j < PRE_NBCOL; j++)
    {
       psz_ligne[j]    = pbd_InRecChild[j];
    }
  psz_ligne[PRE_NBCOL] = NULL;


  n_WriteCols(Kp_PrevOutFile, psz_ligne, SEPARATEUR, 0);
  
  RETURN_VAL (0);
 }
