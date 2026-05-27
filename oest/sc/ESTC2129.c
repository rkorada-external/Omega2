/*==============================================================================
nom de l'application          : Generation Retrocession
nom du source                 : ESTC2129.c
revision                      : $Revision: 1.13 $
date de creation              : 05/01/2015
auteur                        : A. BEN JEDDOU
references des specif ications : 
squelette de base             : batch
------------------------------------------------------------------------------
description :
                Calcul des previsions retrocession

------------------------------------------------------------------------------
historique des modif ications :
   <jj/mm/aaaa>   <auteur>    <description de la modif ication>
[001] 20/03/2015 ABJ  spot:28514 Recuperation de la devise et du contrat d origine   
[002] 25/03/2015 SAS  spot: 28512 prise en compte des postes analytics
[003] 12/03/2019 sbehague    :spira:70044 REQ.L.02.05: Evolution quarterly
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE                *Kp_PrevOutFile;    /* pointeur sur les previsions en sortie */

T_RUPTURE_VAR       bd_RuptPrev;        /* gestion rupture sur placement */
T_RUPTURE_SYNC_VAR  bd_RuptPrevS;       /* gestion rupture sur prev */
T_RUPTURE_SYNC_VAR  bd_RuptPeri;        /* gestion rupture sur le pericase */

int n_InitPrev(T_RUPTURE_VAR *pbd_Rupt);
int n_IsRPrev(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionLastRuptPrev(char **ptb_InRec_Cur);
int n_ActionLignePrev(char **ptb_InRecOwner, char **ptb_InRecChild);

int n_InitPrevS(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSynchro(char **pbd_InRecOwner, char **pbd_InRecChild);
int n_ActionFilsSansPere(char **ptb_InRec_Cur);

int n_InitPeri(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSynchroPeri(char **pbd_InRecOwner, char **pbd_InRecChild);
int n_ActionLignePeri(char **ptb_InRec_Master, char **ptb_InRec_Slave);

int     Kn_annee;           /* Annee Bilan */
char    Ksz_Balshey[5];     /* Annee Bilan */
char    Ksz_Balshtmth[3];   /* Mois Bilan */
char    Ksz_Cre[20];        /* date de creation des previsions en sortie */
char    s_DateBilan[5];

/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc,char *argv[])
{
     char   sz_Cre[9];
     /* Initialisation des signaux */
     InitSig();

    if (n_BeginPgm(argc, argv) == ERR)
        ExitPgm(ERR_XX, "");

    /* Recuperation de l'annee bilan */
    strcpy(Ksz_Balshey, psz_GetCharArgv(1));
    Kn_annee = atoi(Ksz_Balshey);
    strcpy(s_DateBilan, Ksz_Balshey);

    /* Recuperation de la date de lancement du batch */
    strcpy(sz_Cre, psz_GetCharArgv(2));

    /* Recuperation du mois bilan */
    strcpy(Ksz_Balshtmth, psz_GetCharArgv(3));
    sprintf(Ksz_Cre, "%s %s", sz_Cre, "23:59:15");
    
    /* Ouverture des fichiers */
    if (n_OpenFileAppl("ESTC2129_O","wt",&Kp_PrevOutFile) == ERR)
        ExitPgm(ERR_XX, "");

    /* Initialisation de la varible bd_RuptPlc */
    if (n_InitPrev(&bd_RuptPrev) == ERR)
        ExitPgm(ERR_XX, "");
               
    if (n_InitPrevS(&bd_RuptPrevS) == ERR)
        ExitPgm(ERR_XX, "");

    if (n_InitPeri(&bd_RuptPeri) == ERR)
        ExitPgm(ERR_XX, "");

    if (n_ProcessingRuptureVar(&bd_RuptPrev) == ERR)
        ExitPgm(ERR_XX, "");

      /* Fermeture fichier */
    if (n_CloseFileAppl("ESTC2129_I1",&(bd_RuptPrev.pf_InputFil)) == ERR)
        ExitPgm(ERR_XX, "");

    if (n_CloseFileAppl("ESTC2129_I2",&(bd_RuptPrevS.pf_InputFil)) == ERR)
        ExitPgm(ERR_XX, "");

    if (n_CloseFileAppl("ESTC2129_O",&Kp_PrevOutFile) == ERR)
        ExitPgm(ERR_XX, "");

    if (n_EndPgm() == ERR)
        ExitPgm(ERR_XX, "");

    exit(OK);
}


/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du
        fichier maitre.
==============================================================================*/
int n_InitPrev(T_RUPTURE_VAR  *pbd_Rupt)
{
    DEBUT_FCT("n_InitPrev");

    memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

    if (n_OpenFileAppl("ESTC2129_I1","rt",&(pbd_Rupt->pf_InputFil)))
        RETURN_VAL(ERR);

    pbd_Rupt->n_NbRupture           = 1;
    pbd_Rupt->n_ConditionRupture[0] = n_IsRPrev;
    pbd_Rupt->n_ActionLast[0]       = n_ActionLastRuptPrev;
    pbd_Rupt->c_Separ               = SEPARATEUR;

    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   Initialisation de la synchronisation du maitre avec l'esclave
==============================================================================*/
int n_InitPrevS(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
    DEBUT_FCT("n_InitPrev");

    memset(pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR));

    if (n_OpenFileAppl("ESTC2129_I2","rt",&(pbd_Rupt->pf_InputFil)))
        RETURN_VAL(ERR);

    pbd_Rupt->n_NbRupture       = 0;
    pbd_Rupt->ConditionEndSync  = n_ConditionSynchro;
    pbd_Rupt->n_ActionLigne     = n_ActionLignePrev;
    pbd_Rupt->n_FilsSansPere    = n_ActionFilsSansPere;
    pbd_Rupt->c_Separ           = SEPARATEUR;

    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   Initialisation de la synchronisation du maitre avec l'esclave
==============================================================================*/
int n_InitPeri(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
    DEBUT_FCT("n_InitPeri");

    memset(pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR));

    if (n_OpenFileAppl("ESTC2129_I3","rt",&(pbd_Rupt->pf_InputFil)))
        RETURN_VAL(ERR);

    pbd_Rupt->n_NbRupture       = 0;
    pbd_Rupt->ConditionEndSync  = n_ConditionSynchroPeri;
    pbd_Rupt->n_ActionLigne     = n_ActionLignePeri;
    pbd_Rupt->c_Separ           = SEPARATEUR;

    RETURN_VAL(OK);
}

/*==============================================================================
objet :
        fonction de test de synchro
retour :
        0       ---> pbd_InRecOwner = pbd_InRecChild
                       (egalite de rubriques a synchroniser)
        > 0     ---> pbd_InRecOwne> > pbd_InRecChild
        < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSynchro(char **pbd_InRecOwner,/* adresse de la ligne du maitre */
                       char **pbd_InRecChild  /* adresse de la ligne de l'esclave */)
{
    int     ret = 0;

    DEBUT_FCT("n_ConditionSynchro");

    if ((ret = strcmp(pbd_InRecOwner[PRE_CTR_NF], pbd_InRecChild[PRE_CTR_NF])) != 0)
        RETURN_VAL(ret);
    if ((ret = strcmp(pbd_InRecOwner[PRE_END_NT], pbd_InRecChild[PRE_END_NT])) != 0)
        RETURN_VAL(ret);
    if ((ret = strcmp(pbd_InRecOwner[PRE_SEC_NF], pbd_InRecChild[PRE_SEC_NF])) != 0)
        RETURN_VAL(ret);
    if ((ret = strcmp(pbd_InRecOwner[PRE_UWY_NF], pbd_InRecChild[PRE_UWY_NF])) != 0)
        RETURN_VAL(ret);

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
        fonction de test de rupture du niveau 1
retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsRPrev(char **ptb_InRec, char **ptb_InRec_Cur)
{
    int     ret = 0;

    DEBUT_FCT("n_IsRPrev");

    if ((ret = strcmp(ptb_InRec[PRE_CTR_NF], ptb_InRec_Cur[PRE_CTR_NF])) != 0)
        RETURN_VAL(ret);
    if ((ret = strcmp(ptb_InRec[PRE_END_NT], ptb_InRec_Cur[PRE_END_NT])) != 0)
        RETURN_VAL(ret);
    if ((ret = strcmp(ptb_InRec[PRE_SEC_NF], ptb_InRec_Cur[PRE_SEC_NF])) != 0)
        RETURN_VAL(ret);
    if ((ret = strcmp(ptb_InRec[PRE_UWY_NF], ptb_InRec_Cur[PRE_UWY_NF])) != 0)
        RETURN_VAL(ret);    
    if ((ret = strcmp(ptb_InRec[PRE_ACY_NF], ptb_InRec_Cur[PRE_ACY_NF])) != 0)
        RETURN_VAL(ret);
    if ((ret = strcmp(ptb_InRec[PRE_ESTMTH_NF], ptb_InRec_Cur[PRE_ESTMTH_NF])) != 0)
        RETURN_VAL(ret);
  
    RETURN_VAL(OK);
}


/*==============================================================================
objet :
        fonction de test de synchro
retour :
        0       ---> pbd_InRecOwner = pbd_InRecChild
                       (egalite de rubriques a synchroniser)
        > 0     ---> pbd_InRecOwne> > pbd_InRecChild
        < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSynchroPeri(char **pbd_InRecOwner, char **pbd_InRecChild)
{
    int     ret = 0;

    DEBUT_FCT("n_ConditionSynchroPeri");

    if ((ret = strcmp(pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[PER_CTR_NF])) != 0)
        RETURN_VAL(ret);
    if ((ret = strcmp(pbd_InRecOwner[PER_END_NT], pbd_InRecChild[PER_END_NT])) != 0)
        RETURN_VAL(ret);
    if ((ret = strcmp(pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[PER_SEC_NF])) != 0)
        RETURN_VAL(ret);
    if ((ret = strcmp(pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[PER_UWY_NF])) != 0)
        RETURN_VAL(ret);

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
        fonction lancee pour chaque ligne du maitre

retour :
        0 ----> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptPrev(char **ptb_InRec_Cur)
{

    DEBUT_FCT("n_ActionLastRuptPrev");

    /* lancement synchro */
    n_ProcessingRuptureSyncVar(&bd_RuptPrevS, ptb_InRec_Cur);

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
        fonction lancee pour chaque prevision ne participant
        pas a aucun placement
==============================================================================*/
int n_ActionFilsSansPere(char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionFilsSansPere");

    n_WriteCols(Kp_PrevOutFile, ptb_InRec_Cur, SEPARATEUR, 0);
    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   fonction lancee pour chaque ligne synchronisee
==============================================================================*/
int n_ActionLignePrev(char **ptb_InRecOwner,    /* adresse de la ligne du maitre */
                      char **ptb_InRecChild)    /* adresse de la ligne de l'esclave */
{  
    char sz_montant_1[25];

    DEBUT_FCT("n_ActionLignePrev");

    sprintf(sz_montant_1, "%d", 0);
    ptb_InRecChild[PRE_CRE_D] = Ksz_Cre;
    ptb_InRecChild[PRE_ESTMNT_M] = sz_montant_1;
    
    ptb_InRecChild[PRE_BATCH_B] = "1"; // Ajout 08/01/2014 pour prise en compte nouveau champ PRE_BATCH_B dans la structure Lif EST
    ptb_InRecChild[PRE_ORICOD_LS] = "RETRO AUTO";
    strcpy(ptb_InRecChild[PRE_BALSHEY_NF], s_DateBilan);
    ptb_InRecChild[PRE_BALSHTMTH_NF] = Ksz_Balshtmth;

    ptb_InRecChild[PRE_CUR_CF]    = ptb_InRecOwner[PRE_CUR_CF];   //[001] 
    ptb_InRecChild[PRE_SPIMOD_CT] = ptb_InRecOwner[PRE_SPIMOD_CT];   //[002] 
    ptb_InRecChild[PRE_ORICTR_NF] = ptb_InRecOwner[PRE_ORICTR_NF]; 
    ptb_InRecChild[PRE_ORISEC_NF] = ptb_InRecOwner[PRE_ORISEC_NF]; 
    ptb_InRecChild[PRE_ORIUWY_NF] = ptb_InRecOwner[PRE_ORIUWY_NF]; 
    
    strcpy(ptb_InRecChild[PRE_CREUSR_CF], "dbo");
    ptb_InRecChild[PRE_LSTUPD_D]  = Ksz_Cre;
    strcpy(ptb_InRecChild[PRE_LSTUPDUSR_CF], "dbo");
    
    n_WriteCols(Kp_PrevOutFile, ptb_InRecChild, SEPARATEUR, 0);
    
    RETURN_VAL(OK);
}


/*==============================================================================
objet : fonction lancee pour chaque ligne du maitre
retour :    0 ----> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePeri(char **ptb_InRec_Master, char **ptb_InRec_Slave)
{
    DEBUT_FCT("n_ActionLignePeri");

    /* Conservation des ligne gérées manuellement par l'accept */
    if ((strcmp(ptb_InRec_Master[PER_PARENT_FLAG], "0") == 0) ||
        (strcmp(ptb_InRec_Master[PER_LOCAL_FLAG], "0") == 0))
        n_WriteCols(Kp_PrevOutFile, ptb_InRec_Master, SEPARATEUR, 0);

    RETURN_VAL(OK);
}