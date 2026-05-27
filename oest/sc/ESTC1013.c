/*==============================================================================
nom de l'application          : Calcul de PNA,EPP,RPP
nom du source                 : ESTC1013.c
revision                      : $Revision:   1.12  $
date de creation              : 19/05/2006
auteur                        : J. Ribot
references des specifications :
squelette de base             : batch
------------------------------------------------------------------------------
description :
   En entree : perimetre IADPERICASE,
               fichier de travail des traites.
   En sortie : fichier de travail des traites (pour chaque ligne du fichier de
               travail .
------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <utctlib.h>
#include <struct.h>

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE  *Kp_FTTr_Fil;            /* pointeurs sur les fichiers en sortie */

T_RUPTURE_VAR bd_RuptPer;    /* gestion rupture sur Per */
T_RUPTURE_SYNC_VAR  bd_RuptFtr; /* gestion synchro Per */

int n_InitFtr(T_RUPTURE_SYNC_VAR  *pbd_Rupt);
int n_ActionLigneFtr(char **ptb_InRecOwner,char **pbd_InRecChild) ;
int n_ConditionSyncFtr(char **ptb_InRecOwner,char **pbd_InRecChild);

int n_InitPer(T_RUPTURE_VAR *pbd_Rupt) ;
int n_ActionLignePer(char **pbd_InRec_Cur);
int n_IsR1Per(char **ptb_InRec,char **ptb_InRec_Cur);
int n_ActionFirstRuptPer ( char **ptb_InRec_Cur);

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

        if ( n_BeginPgm (argc  ,argv) == ERR )
                ExitPgm ( ERR_XX , "" );

        /* ouverture des fichiers en sortie */

        if ( n_OpenFileAppl ("ESTC1013_O1","wt",&Kp_FTTr_Fil) == ERR )
                ExitPgm ( ERR_XX , "" );


        /* Initialisation de la varible bd_RuptFtr */
        if ( n_InitFtr(&bd_RuptFtr) )
                ExitPgm ( ERR_XX , "" );

        /* Initialisation de la varible bd_RuptPer */
        if ( n_InitPer (&bd_RuptPer) )
                ExitPgm ( ERR_XX , "" );

        /* lancement du traitement du fichier */
        if ( n_ProcessingRuptureVar (&bd_RuptPer) == ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC1013_O1",&Kp_FTTr_Fil))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl("ESTC1013_I2",&(bd_RuptFtr.pf_InputFil))== ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC1013_I1",&(bd_RuptPer.pf_InputFil)))
                ExitPgm ( ERR_XX , "" );

        if ( n_EndPgm () == ERR )
                ExitPgm ( ERR_XX , "" );

        exit(OK) ;

}

/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du
        fichier travail.

retour :
        OK
==============================================================================*/
int n_InitFtr(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitFtr");

        memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR));

        if ( n_OpenFileAppl ("ESTC1013_I2","rt",&(pbd_Rupt->pf_InputFil)))
                ExitPgm ( ERR_XX , "" );

        pbd_Rupt->n_NbRupture = 0  ;

        /* fonction du test de la ligne du maitre avec l'esclave */
        pbd_Rupt->ConditionEndSync      = n_ConditionSyncFtr;

        pbd_Rupt->n_ActionLigne = n_ActionLigneFtr ;

        pbd_Rupt->c_Separ = '~' ;

        RETURN_VAL(OK);
}

/*==============================================================================
objet :
        fonction lancee pour chaque ligne fichier travail

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneFtr(
        char **ptb_InRecOwner ,/* adresse de la ligne du maitre */
        char **ptb_InRecChild  /* adresse de la ligne de l'esclave */
)
{
        n_WriteCols(Kp_FTTr_Fil,ptb_InRecChild,'~',0);

        RETURN_VAL(OK);
}


/*==============================================================================
objet :
        Initialisation du maitre

retour :
        OK
==============================================================================*/
int n_InitPer(T_RUPTURE_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitPer");

        memset( pbd_Rupt,0,sizeof(T_RUPTURE_VAR) ) ;

        /* ouverture du fichier esclave */
        n_OpenFileAppl ("ESTC1013_I1","rt",&(pbd_Rupt->pf_InputFil));

        pbd_Rupt->n_NbRupture = 1  ;
        pbd_Rupt->n_ConditionRupture[0] = n_IsR1Per;
        pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptPer;

        pbd_Rupt->n_ActionLigne         = n_ActionLignePer ;

        pbd_Rupt->c_Separ               = '~' ;

        RETURN_VAL(OK);
}

/*==============================================================================
objet :
        fonction de test de rupture du niveau 1

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR1Per(char **ptb_InRec,char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_IsR1Per");

    if ((strcmp(ptb_InRec[PER_CTR_NF],ptb_InRec_Cur[PER_CTR_NF])!=0)||
    (strcmp(ptb_InRec[PER_END_NT],ptb_InRec_Cur[PER_END_NT])!=0)||
    (strcmp(ptb_InRec[PER_UWY_NF],ptb_InRec_Cur[PER_UWY_NF])!=0)||
    (strcmp(ptb_InRec[PER_UW_NT],ptb_InRec_Cur[PER_UW_NT])!=0)||
    (strcmp(ptb_InRec[PER_SEC_NF],ptb_InRec_Cur[PER_SEC_NF])!=0))
    RETURN_VAL(1);

        RETURN_VAL(0);
}

/*==============================================================================
objet :
        Fonction lancee a chaque rupture premiere
==============================================================================*/
int n_ActionFirstRuptPer ( char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_ActionFirstRuptPer");

        /* synchronisation du fichier de travail */
        n_ProcessingRuptureSyncVar (&bd_RuptFtr, ptb_InRec_Cur) ;

        RETURN_VAL(0);
}

/*==============================================================================
objet :
        fonction de test de rupture du niveau 1
retour :
        0       ---> Pas de rupture
        < 0     ---> On n'est pas arrive au bloc synchrone
        > 0     ---> On a depasse le bloc synchrone
==============================================================================*/
int n_ConditionSyncFtr(
        char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
        char **pbd_InRecChild  /* adresse de la ligne de l'esclave */
        )
{
        int ret ;

        DEBUT_FCT("n_ConditionSyncFtr");

            if ((ret=strcmp(pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[FT_CTR_NF]))!= 0) return ret;
            if ((ret=strcmp(pbd_InRecOwner[PER_END_NT], pbd_InRecChild[FT_END_NT]))!= 0) return ret;
            if ((ret=strcmp(pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[FT_SEC_NF]))!= 0) return ret;
            if ((ret=strcmp(pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[FT_UWY_NF]))!= 0) return ret;
            if ((ret=strcmp(pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[FT_UW_NT]))!= 0) return ret;

        RETURN_VAL(0);
}



/*==============================================================================
objet :
        fonction lancee pour chaque ligne des postes regroupes
retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePer( char **ptb_InRec_Cur )

{
        DEBUT_FCT("n_ActionLignePer");

        RETURN_VAL(OK);
}

