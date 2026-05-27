

/*==============================================================================
nom de l'application          : spira 37827
nom du source                 : ESTC7606.c
revision                      : $Revision: 1.4 $
date de creation              : 01/07/2015
auteur                        : S. ASKRI
references des specifications :
squelette de base             : batch
------------------------------------------------------------------------------
description :


------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
[01] 04/02/2016    SASKRI      spot:30136 optimisation de l'ESID2030
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

#define HEURE_TRAITEMENT        "23:59:05"
#define MONTANT_ZERO            "0.000"
#define BATCH_B                 "1"

/*----------------------*/
/* variables de travail */
/*----------------------*/
 
FILE                     *Kp_PrevOutFile;

T_RUPTURE_VAR             bd_RuptLifep;
T_RUPTURE_SYNC_VAR        pbd_RuptPERI;       /* Structure contenant le PERICASE */
T_RUPTURE_SYNC_VAR        bd_SyncPrev; 

/*--------------------*/
/* procedures locales */
/*--------------------*/

int     n_InitLifep(T_RUPTURE_VAR *ptd_Rupt) ;
int     n_ConditionRupture1(char **ptb_InRec, char **ptb_InRec_Cur);
int     n_ActionLastRuptLifep1(char **ptb_InRec_Cur);

int     n_InitSyncPeri(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int     n_ConditionSyncPeri(char **pbd_LIFEP, char **pbd_RuptP) ;
int     n_ActionLignePeri(char **pbd_RuptP , char **pbd_InRecChild);

int     n_InitSyncLifest(T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int     n_ConditionSyncPrev(char **bd_RuptPrev, char **bd_RuptLifep); 
int     n_ActionLigne(char **pbd_InRecOwner , char **pbd_InRecChild);
int     n_ActionFilsSansPere (char **ptb_InRec_Cur);


char  Ksz_Ctr[10] ;      /* contrat */
char  Ksz_Sec[3] ;       /* section */
char  Ksz_Uwy[6];        /* exercice */
char  Ksz_max[6];

char  peri_ctr[10];
char  peri_sec[3];
char  peri_uwy[6];

int  Parent_Flag;
int  Local_Flag;

char  Ksz_Cre_D[22] = {'\0'};
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

    if (n_BeginPgm(argc  ,argv) == ERR)                                        ExitPgm ( ERR_XX , "");

         // Recuperation des parametres
    sprintf(Ksz_Cre_D, "%s %s", psz_GetCharArgv(1), HEURE_TRAITEMENT);

    /* ouverture des fichiers */
    if (n_OpenFileAppl ("ESTC7606_O", "wt", &Kp_PrevOutFile) == ERR)           ExitPgm( ERR_XX, "Cannot open ESTC7606_O file! ");

     /* Initialisation de la varible bd_RuptPrev */
    if (n_InitLifep(&bd_RuptLifep) == ERR)                                     ExitPgm( ERR_XX, "Call of n_InitLifep() fails");
    if (n_InitSyncPeri(&pbd_RuptPERI) )                                        ExitPgm( ERR_XX, "Call of n_InitLifep() fails");
    if (n_InitSyncLifest(&bd_SyncPrev) == ERR)                                 ExitPgm( ERR_XX, "Call of n_InitLifep() fails");

    /* Lancement du traitement du fichier */
    if (n_ProcessingRuptureVar(&bd_RuptLifep) == ERR)                          ExitPgm( ERR_XX, "Call of n_ProcessingRuptureVar() fails");

    /* fermeture des fichiers */
    if (n_CloseFileAppl ("ESTC7606_I1",&(bd_RuptLifep.pf_InputFil))== ERR )    ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC7606_I2",&(pbd_RuptPERI.pf_InputFil)) == ERR)    ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC7606_I3",&(bd_SyncPrev.pf_InputFil))== ERR)      ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC7606_O",&Kp_PrevOutFile)== ERR)                  ExitPgm ( ERR_XX , "" );

    if ( n_EndPgm () == ERR )                                                  ExitPgm ( ERR_XX , "" );

    exit(OK) ;
}

/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du
        fichier maitre.

retour :
        OK
==============================================================================*/
int n_InitLifep(T_RUPTURE_VAR *pbd_Rupt)
{
  DEBUT_FCT("n_InitLifep");
  memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

  if (n_OpenFileAppl("ESTC7606_I1", "rt", &(pbd_Rupt->pf_InputFil)) != OK)     RETURN_VAL(ERR);

  pbd_Rupt->n_NbRupture                   = 1;
  pbd_Rupt->n_ConditionRupture[0]         = n_ConditionRupture1;
  pbd_Rupt->n_ActionLast[0]               = n_ActionLastRuptLifep1 ;

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

    RETURN_VAL(OK);
}



/*==============================================================================
objet :
        fonction lancee pour la derniere rupture du maitre

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptLifep1(char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionLastRuptLifep");

    strcpy(Ksz_Ctr         , ptb_InRec_Cur[PRE_CTR_NF]);
    strcpy(Ksz_Sec         , ptb_InRec_Cur[PRE_SEC_NF]);
    strcpy(Ksz_max         , ptb_InRec_Cur[PRE_UWY_NF]);
   
   /* synchronisation du fichier PRE pour chaque ligne */
    if (n_ProcessingRuptureSyncVar (&pbd_RuptPERI, ptb_InRec_Cur) == ERR)         RETURN_VAL(ERR);
    if (n_ProcessingRuptureSyncVar (&bd_SyncPrev, ptb_InRec_Cur) == ERR)          RETURN_VAL(ERR);

    RETURN_VAL(OK);
}


// /*==============================================================================
// objet :     Initialisation de la structure de rupture syncronisée du LIFEP
// retour:     OK
// ==============================================================================*/
int n_InitSyncPeri(T_RUPTURE_SYNC_VAR *pbd_Rupt)
{
    DEBUT_FCT("n_InitRuptPeri");
    memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR));

    // Ouverture du fichier Peri
     n_OpenFileAppl ("ESTC7606_I2","rt",&(pbd_Rupt->pf_InputFil));  

      pbd_Rupt->n_NbRupture = 0;

    /* fonction d'action sur la ligne courante */ 
      pbd_Rupt->ConditionEndSync      = n_ConditionSyncPeri; 
      pbd_Rupt->n_ActionLigne         = n_ActionLignePeri;    

      pbd_Rupt->c_Separ               = '~';

    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   fonction de test de synchronisation
retour  :   0   ---> pbd_RuptLifep = pbd_RuptPERI (égalité de rubrique à synchroniser)
            !=0 ---> Pas de syncronisation
==============================================================================*/
int n_ConditionSyncPeri(char **pbd_InRecOwner, 
                        char **pbd_InRecChild)   /* adresse de la ligne du LIFEP puis du PERICASE */
{
    int     ret;
    DEBUT_FCT("n_ConditionSyncPeri");

    if ((ret = strcmp(pbd_InRecOwner[PRE_CTR_NF], pbd_InRecChild[PER_CTR_NF])) != 0)  RETURN_VAL(ret);
    if ((ret = strcmp(pbd_InRecOwner[PRE_SEC_NF], pbd_InRecChild[PER_SEC_NF])) != 0)  RETURN_VAL(ret);

    RETURN_VAL(OK);
}



/*==============================================================================
objet   :   Fonction lancee pour chaque ligne synchronisee
retour  :   OK
==============================================================================*/
int n_ActionLignePeri(char **pbd_InRecOwner , char **pbd_InRecChild)
{

 DEBUT_FCT("n_ActionLignePeri");

    strcpy(peri_ctr         , pbd_InRecChild[PER_CTR_NF]);
    strcpy(peri_sec         , pbd_InRecChild[PER_SEC_NF]);
    strcpy(peri_uwy         , pbd_InRecChild[PER_UWY_NF]);

    // Check de la valeur du PER_PARENT_FLAG. NULL a la meme comportement que la valeur 1
    if (pbd_InRecChild[PER_PARENT_FLAG] != NULL)
    {
        if (pbd_InRecChild[PER_PARENT_FLAG][0] != '\0')
            Parent_Flag = atoi(pbd_InRecChild[PER_PARENT_FLAG]);
        else
            Parent_Flag = 1;
    }
    else
        Parent_Flag = 1;

    // Check de la valeur du PER_LOCAL_FLAG. NULL a la meme comportement que la valeur 1
    if (pbd_InRecChild[PER_LOCAL_FLAG] != NULL)
    {
        if (pbd_InRecChild[PER_LOCAL_FLAG][0] != '\0')
            Local_Flag = atoi(pbd_InRecChild[PER_LOCAL_FLAG]);
        else
            Local_Flag = 1;
    }
    else
        Local_Flag = 1;

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
    n_OpenFileAppl ("ESTC7606_I3","rt",&(pbd_SyncPrev->pf_InputFil));

    /* fonction du test de la ligne du maitre avec l'esclave */
    pbd_SyncPrev->ConditionEndSync      = n_ConditionSyncPrev;

     /* fonction d'action pour chaque ligne du lifest synchronisee avec le maitre */
    pbd_SyncPrev->n_ActionLigne         = n_ActionLigne;
    
    //pbd_SyncPrev->n_FilsSansPere        = n_ActionFilsSansPere; [01]
    
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

    if ( (ret = strcmp(pbd_InRecOwner[PRE_CTR_NF],pbd_InRecChild[PRE_CTR_NF]))             != 0 )               RETURN_VAL(ret);
    if ( (ret = strcmp(pbd_InRecOwner[PRE_SEC_NF],pbd_InRecChild[PRE_SEC_NF]))             != 0 )               RETURN_VAL(ret);
    //if ( (ret = strcmp(pbd_InRecOwner[PRE_UWY_NF],pbd_InRecChild[PRE_UWY_NF]))             != 0 )               RETURN_VAL(ret);


    RETURN_VAL(0);
}

/*==============================================================================
objet :
        fonction lancee pour chaque prevision sans pere RETRO
        
retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
//int n_ActionFilsSansPere(char **ptb_InRec_Cur)
//{
//	DEBUT_FCT("n_ActionFilsSansPere");
//
//   n_WriteCols(Kp_PrevOutFile, ptb_InRec_Cur, SEPARATEUR, 0);  	
//   
//	RETURN_VAL(OK);
//}


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

if((strcmp(pbd_InRecChild[PRE_CTR_NF], peri_ctr) == 0) && (strcmp(pbd_InRecChild[PRE_SEC_NF], peri_sec) == 0) ) //&& (strcmp(pbd_InRecChild[PRE_UWY_NF], peri_uwy) == 0))
{
if((strcmp(psz_ligne[PRE_GAAP_NF], "4") == 0) && (Local_Flag != 0))
{
      psz_ligne[PRE_CRE_D]      = Ksz_Cre_D;
      psz_ligne[PRE_BATCH_B]    = BATCH_B; 
      psz_ligne[PRE_ESTMNT_M]   = MONTANT_ZERO;
      psz_ligne[PRE_GAAPDIFF_M] = MONTANT_ZERO;

      n_WriteCols(Kp_PrevOutFile, psz_ligne, SEPARATEUR, 0);  
    }
    else if((strcmp(psz_ligne[PRE_GAAP_NF], "3") == 0) && (Parent_Flag != 0))
    {
        psz_ligne[PRE_CRE_D]      = Ksz_Cre_D;
      psz_ligne[PRE_BATCH_B]    = BATCH_B; 
      psz_ligne[PRE_ESTMNT_M]   = MONTANT_ZERO;
      psz_ligne[PRE_GAAPDIFF_M] = MONTANT_ZERO;

      n_WriteCols(Kp_PrevOutFile, psz_ligne, SEPARATEUR, 0);  
    } else
    if ((strcmp(psz_ligne[PRE_GAAP_NF], "4") != 0) && (strcmp(psz_ligne[PRE_GAAP_NF], "3") != 0))
    {
       psz_ligne[PRE_CRE_D]      = Ksz_Cre_D;
      psz_ligne[PRE_BATCH_B]    = BATCH_B; 
      psz_ligne[PRE_ESTMNT_M]   = MONTANT_ZERO;
      psz_ligne[PRE_GAAPDIFF_M] = MONTANT_ZERO;

      n_WriteCols(Kp_PrevOutFile, psz_ligne, SEPARATEUR, 0);
    }
  }
    
       RETURN_VAL (0);

 }
