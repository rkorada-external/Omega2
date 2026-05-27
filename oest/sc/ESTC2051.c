/*==============================================================================
nom de l'application          : 
nom du source                 : ESTC2051.c
revision                      : 
date de creation              : 04/10/2016
auteur                        : S.Behague
references des specifications : 
squelette de base             : batch
------------------------------------------------------------------------------
description :
------------------------------------------------------------------------------
historique des modifications :
<jj/mm/aaaa>   <auteur>    <description de la modification>
# [001] 18/10/2016 SBE :spot:31343 - Spira 30649 - Propagation Réserves
# [002] 10/01/2019 S.Behague    :REQ.L.02.05: Evolution quarterly
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
FILE       *Kp_PrevIFil,                // Pointeur sur les previsions en entree
           *Kp_CplaccIFil,              // Pointeur sur le fichier CPLACC en entree
           *Kp_PrevOFil;                 // Pointeur sur les previsions en sortie

T_RUPTURE_VAR       bd_RuptPrev;          // gestion rupture sur Prev
T_RUPTURE_SYNC_VAR  bd_RuptCplacc;        // gestion synchro Cplacc

int n_InitPrev(T_RUPTURE_VAR *pbd_Rupt) ;
int n_ActionLignePrev(char **pbd_InRec_Cur);
int n_IsR1Prev(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRuptPrev ( char **ptb_InRec_Cur);

int n_InitCplacc(T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int n_ActionLigneCplacc(char **ptb_InRecOwner,char **pbd_InRecChild);
int n_ConditionSyncCplacc(char **ptb_InRecOwner,char **pbd_InRecChild);
int n_ActionPrevSansCplacc(char **ptb_InRecOwner); /* PereSansFils */
int n_ActionCplaccsansPrev(char **ptb_InRecOwner); /* FilsSansPere */

int Synchro=0;

/*==============================================================================
objet :     point d'entree du programme
retour :    En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{
    InitSig () ;

    if ( n_BeginPgm (argc  ,argv) == ERR ) ExitPgm ( ERR_XX , "" );

    // ouverture des fichiers
    if ( n_OpenFileAppl ("ESTC2051_O1","wt",&Kp_PrevOFil) == ERR )              ExitPgm ( ERR_XX , "" );

    // Initialisation de la variable bd_RuptPrev
    if ( n_InitPrev(&bd_RuptPrev) )                             ExitPgm ( ERR_XX , "" );
    // Initialisation de la variable bd_RuptCplacc
    if ( n_InitCplacc(&bd_RuptCplacc) )                         ExitPgm ( ERR_XX , "" );

    if ( n_ProcessingRuptureVar (&bd_RuptPrev) == ERR )       ExitPgm ( ERR_XX , "" );


    if (n_CloseFileAppl ("ESTC2051_I1",&(bd_RuptPrev.pf_InputFil)))               ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC2051_I3",&(bd_RuptCplacc.pf_InputFil)))             ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC2051_O1",&Kp_PrevOFil))                             ExitPgm ( ERR_XX , "" );

    if ( n_EndPgm () == ERR )                               ExitPgm ( ERR_XX , "" );

    exit(0);
}


/*==============================================================================
objet :     fonction d'initialisation de la variable de gestion de rupture du GT.
retour :    0
==============================================================================*/
int n_InitPrev(T_RUPTURE_VAR  *pbd_Rupt)
{
    DEBUT_FCT("n_InitPrev");

    memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

    if ( n_OpenFileAppl ("ESTC2051_I1","rt",&(pbd_Rupt->pf_InputFil)))
        RETURN_VAL (ERR);

    pbd_Rupt->n_NbRupture = 1;
    pbd_Rupt->n_ConditionRupture[0] = n_IsR1Prev;
    pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptPrev;

    pbd_Rupt->n_ActionLigne = n_ActionLignePrev;

    pbd_Rupt->c_Separ = '~' ;

    RETURN_VAL (0);
}

/*==============================================================================
objet :     fonction de test de rupture du niveau 1
retour :    0   ---> Pas de rupture
            1   ---> rupture
==============================================================================*/
int n_IsR1Prev(char **ptb_InRec,char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_IsR1Prev");

    if (strcmp(ptb_InRec[PRE_CTR_NF],ptb_InRec_Cur[PRE_CTR_NF])!=0)           RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_ACY_NF],ptb_InRec_Cur[PRE_ACY_NF])!=0)           RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_ESTMTH_NF],ptb_InRec_Cur[PRE_ESTMTH_NF])!=0)     RETURN_VAL(1);

    RETURN_VAL (0);
}

/*==============================================================================
  objet :     Fonction lancee a chaque rupture derniere sur contrat/ACY
  ==============================================================================*/
int n_ActionFirstRuptPrev (char **ptb_InRec_Cur)
{
    Synchro = 0;
    n_ProcessingRuptureSyncVar(&bd_RuptCplacc, ptb_InRec_Cur);
    RETURN_VAL (0);
}

/*==============================================================================
objet :     fonction lancee pour chaque ligne du GT
retour :    0 ----> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePrev(char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionLignePrev");

    if ( Synchro == 0 )
    {
        n_WriteCols(Kp_PrevOFil,ptb_InRec_Cur,SEPARATEUR,0);
    }

	RETURN_VAL (0);
}


/*==============================================================================
objet :     Initialisation de la synchronisation du GT avec les previsions
retour :    0
==============================================================================*/
int n_InitCplacc(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
    DEBUT_FCT("n_InitCplacc");

    memset( pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

    /* ouverture du fichier previsions */
    n_OpenFileAppl ("ESTC2051_I2","rt",&(pbd_Rupt->pf_InputFil));

    pbd_Rupt->n_NbRupture = 0;

    /* fonction du test de la ligne du GT avec les previsions */
    pbd_Rupt->ConditionEndSync = n_ConditionSyncCplacc;

    /* fonction d'action quand le GT est seul */
    pbd_Rupt->n_PereSansFils = n_ActionPrevSansCplacc;

    /* fonction d'action quand les previsions sont seules */
    pbd_Rupt->n_FilsSansPere = n_ActionCplaccsansPrev;

    /* fonction d'action sur la ligne courante du fichier previsions */
    pbd_Rupt->n_ActionLigne = n_ActionLigneCplacc;
    
    pbd_Rupt->c_Separ = '~';

 	RETURN_VAL (0);
}

/*==============================================================================
objet :     fonction de test de synchro
retour :    0 ---> synchro
            sinon, non trouve
==============================================================================*/

int n_ConditionSyncCplacc(  char **pbd_InRecOwner, char **pbd_InRecChild  )
{
    int ret;
	
    DEBUT_FCT("n_ConditionSyncCplacc");

    if ((ret=strcmp(pbd_InRecOwner[PRE_CTR_NF],  pbd_InRecChild[CMP_CTR_NF]))!=0)          RETURN_VAL (ret);
    if ((ret=strcmp(pbd_InRecOwner[PRE_ACY_NF],  pbd_InRecChild[CMP_ACY_NF]))!=0)          RETURN_VAL (ret);
    if ((ret=strcmp(pbd_InRecOwner[PRE_ESTMTH_NF],  pbd_InRecChild[CMP_SCOENDMTH_NF]))!=0) RETURN_VAL (ret);
    
    RETURN_VAL (0);
}

/*==============================================================================
objet : fonction lancee pour chaque ligne des cplacc synchronisee avec les previsions
retour: 0 ----> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/

int n_ActionLigneCplacc( char **ptb_InRecOwner, char **ptb_InRecChild )
{
    DEBUT_FCT("n_ActionLigneCplacc");

    // Si Synchro, l'année de compte est en compte complet
    // on ne redirige pas la ligne en sortie

    Synchro = 1;
    RETURN_VAL (0);
}

/*==============================================================================
objet :     fonction lancee quand le GT est seul (pas de previsions)
retour :    0 ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
                        // adresse de la ligne du GT
int n_ActionPrevSansCplacc( char **ptb_InRec )
{
    // On redirige la ligne vers le fichier de sortie, car la synchro sur l'année de compte
    // ne retourne rien. Donc acy non complète, on peut reporter les réserves
    //n_WriteCols(Kp_PrevOFil,ptb_InRec,SEPARATEUR,0);
    
    RETURN_VAL (0);
}

/*==============================================================================
objet :     fonction lancee quand les previsions sont seules (pas de GT)
retour :    OK ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
                        // adresse de la ligne des previsions */
int n_ActionCplaccsansPrev( char **ptb_InRec )
{
    RETURN_VAL (0);
}