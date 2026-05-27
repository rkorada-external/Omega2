/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Generation RETRO
nom du source                 : ESTC2133.c
revision                      : $Revision:   1.0  $
date de creation              : 25/09/1997
auteur                        : P. Louveau
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :
                Recherche du taux d'interet sur depot SAP et REC

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
           ...           ...            ...              ...
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
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

FILE            *PlacemtInFile;                 /* fichier des placements en entree */
FILE            *DepotFile;                     /* fichier des taux d'interets sur depots */
FILE            *DepotPlcFile;                  /* fichier des taux d'interets sur depots placements */
FILE            *PlacemtOutFile;                /* fichier des placements en sortie */

T_RUPTURE_VAR           bd_RuptPlc;            /* gestion rupture sur les placements */
T_RUPTURE_SYNC_VAR      bd_RuptDep;            /* gestion rupture sur les depots */
T_RUPTURE_SYNC_VAR      bd_RuptDepp;           /* gestion rupture sur les depots placements */


int n_InitPlc(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLignePlc(char **pbd_InRec_Cur);
int n_IsR1Plc(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRupt1Plc(char **ptb_InRec_Cur);
int n_IsR2Plc(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRupt2Plc(char **ptb_InRec_Cur);

int n_InitDep(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncDep (char **pbd_InRecOwner, char **pbd_InRecChild);
int n_ActionLigneDep(char **ptb_InRecOwner, char **ptb_InRecChild);
/*int n_ActionPereSansFils(char **ptb_InRec);
*/
int n_InitDepp(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncDepp (char **pbd_InRecOwner, char **pbd_InRecChild);
int n_ActionLigneDepp(char **ptb_InRecOwner, char **ptb_InRecChild);

double  Taux_sinistres, Taux_primes;            /* taux d'interet */
double  Taux_sinistres_plc, Taux_primes_plc;    /* taux d'interet placement */



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

        /* Ouverture des fichiers en sortie */
        if ( n_OpenFileAppl ("ESTC2133_O1","wt",&PlacemtOutFile) == ERR )
                ExitPgm ( ERR_XX , "" );

        /* Initialisation des variables de synchro */
        if ( n_InitPlc(&bd_RuptPlc) )
                ExitPgm ( ERR_XX , "" );

        if ( n_InitDep(&bd_RuptDep) )
                ExitPgm ( ERR_XX , "" );

        if ( n_InitDepp(&bd_RuptDepp) )
                ExitPgm ( ERR_XX , "" );

        /* Lancement du traitement du fichier */
        if ( n_ProcessingRuptureVar (&bd_RuptPlc) == ERR )
                ExitPgm ( ERR_XX , "" );

        /* Fermeture fichier */
        if (n_CloseFileAppl ("ESTC2133_I1",&(bd_RuptPlc.pf_InputFil)) == ERR)
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2133_I2",&(bd_RuptDep.pf_InputFil)) == ERR)
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2133_I3",&(bd_RuptDepp.pf_InputFil)) == ERR)
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2133_O1",&PlacemtOutFile) == ERR)
                ExitPgm ( ERR_XX , "" );

        if ( n_EndPgm () == ERR )
                ExitPgm ( ERR_XX , "" );

        exit(0);
}


/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du
        fichier maitre.
retour :
        0
==============================================================================*/
int n_InitPlc(T_RUPTURE_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitPlc");

        memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

        if ( n_OpenFileAppl ("ESTC2133_I1","rt",&(pbd_Rupt->pf_InputFil)))
                RETURN_VAL (ERR);

        pbd_Rupt->n_NbRupture = 2 ;
        /* rupture de niveau 1 */
        pbd_Rupt->n_ConditionRupture[0] = n_IsR1Plc;
        pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRupt1Plc;
        /* rupture de niveau 2 */
        pbd_Rupt->n_ConditionRupture[1] = n_IsR2Plc;
        pbd_Rupt->n_ActionFirst[1] = n_ActionFirstRupt2Plc;

        pbd_Rupt->n_ActionLigne = n_ActionLignePlc ;

        pbd_Rupt->c_Separ = '~' ;

        RETURN_VAL (0);
}


/*==============================================================================
objet :
        Initialisation de la synchronisation du maitre avec l'esclave Perim

retour :
        OK
==============================================================================*/
int n_InitDep(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitDep");

        memset( pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

        /* ouverture du fichier esclave */
        n_OpenFileAppl ("ESTC2133_I2","rt",&(pbd_Rupt->pf_InputFil));

        pbd_Rupt->n_NbRupture = 0;

        pbd_Rupt->ConditionEndSync      = n_ConditionSyncDep ;
        pbd_Rupt->n_ActionLigne         = n_ActionLigneDep ;
/*        pbd_Rupt->n_PereSansFils        = n_ActionPereSansFils;
*/
        pbd_Rupt->c_Separ               = '~' ;

        RETURN_VAL (OK);
}



/*==============================================================================
objet :
        Initialisation de la synchronisation du maitre avec l'esclave Perim

retour :
        OK
==============================================================================*/
int n_InitDepp(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitDepp");

        memset( pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

        /* ouverture du fichier esclave */
        n_OpenFileAppl ("ESTC2133_I3","rt",&(pbd_Rupt->pf_InputFil));

        pbd_Rupt->n_NbRupture = 0;

        pbd_Rupt->ConditionEndSync      = n_ConditionSyncDepp ;
        pbd_Rupt->n_ActionLigne         = n_ActionLigneDepp ;
/*        pbd_Rupt->n_PereSansFils        = n_ActionPereSansFils;
*/
        pbd_Rupt->c_Separ               = '~' ;

        RETURN_VAL (OK);
}



/*==============================================================================
objet :
        fonction de test de synchro

retour :
        0       ---> pbd_InRecOwner = pbd_InRecChild
                        ( egalite de rubriques a synchroniser)
        > 0     ---> pbd_InRecOwne> > pbd_InRecChild
        < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncDep (char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
                        char **pbd_InRecChild  /* adresse de la ligne de l'esclave */ )
{
        int ret;

        DEBUT_FCT("n_ConditionSyncDep");

        if( (ret = strcmp(pbd_InRecOwner[PLA1_RETCTR_NF],pbd_InRecChild[TINTWIT_RETCTR_NF])) != 0 )
                RETURN_VAL (ret);
        if( (ret = strcmp(pbd_InRecOwner[PLA1_RTY_NF],pbd_InRecChild[TINTWIT_RTY_NF])) != 0 )
                RETURN_VAL (ret);

        RETURN_VAL (0);
}



/*==============================================================================
objet :
        2eme fonction de test de synchro

retour :
        0       ---> pbd_InRecOwner = pbd_InRecChild
                        ( egalite de rubriques a synchroniser)
        > 0     ---> pbd_InRecOwne> > pbd_InRecChild
        < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncDepp (char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
                        char **pbd_InRecChild   /* adresse de la ligne de l'esclave */ )
{
        int ret;

        DEBUT_FCT("n_ConditionSyncDepp");

        if( (ret = strcmp(pbd_InRecOwner[PLA1_RETCTR_NF],pbd_InRecChild[TPINTWIT_RETCTR_NF])) != 0 )
                RETURN_VAL (ret);
        if( (ret = strcmp(pbd_InRecOwner[PLA1_RTY_NF],pbd_InRecChild[TPINTWIT_RTY_NF])) != 0 )
                RETURN_VAL (ret);
        if( (ret = strcmp(pbd_InRecOwner[PLA1_PLC_NT],pbd_InRecChild[TPINTWIT_PLC_NT])) != 0 )
                RETURN_VAL (ret);

        RETURN_VAL (0);
}



/*==============================================================================
objet :
        fonction de test de rupture niveau 1 sur
                Contrat/Exercice de retrocession

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR1Plc(char **ptb_InRec,char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_IsR1Plc");

        if (strcmp(ptb_InRec[PLA1_RETCTR_NF],ptb_InRec_Cur[PLA1_RETCTR_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PLA1_RTY_NF],ptb_InRec_Cur[PLA1_RTY_NF])!=0)
                RETURN_VAL(1);

        RETURN_VAL (0);
}



/*==============================================================================
objet :
        fonction de test de rupture niveau 1 sur
                Contrat/Exercice de retrocession

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR2Plc(char **ptb_InRec,char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_IsR2Plc");

        if (strcmp(ptb_InRec[PLA1_RETCTR_NF],ptb_InRec_Cur[PLA1_RETCTR_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PLA1_RTY_NF],ptb_InRec_Cur[PLA1_RTY_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PLA1_PLC_NT],ptb_InRec_Cur[PLA1_PLC_NT])!=0)
                RETURN_VAL(1);

        RETURN_VAL (0);
}


/*==============================================================================
objet :
        Fonction lancee a chaque rupture premiere de niveau 1
==============================================================================*/
int n_ActionFirstRupt1Plc (char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionFirstRupt1Prev");

    Taux_sinistres = -1;
    Taux_primes    = -1;

    /* Lancement de la synchronisation avec le fichier des conditions de depots */
    n_ProcessingRuptureSyncVar (&bd_RuptDep, ptb_InRec_Cur);

    RETURN_VAL (0);
}


/*==============================================================================
objet :
        Fonction lancee a chaque rupture premiere de niveau 1
==============================================================================*/
int n_ActionFirstRupt2Plc (char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionFirstRupt2Prev");

    Taux_sinistres_plc = -1;
    Taux_primes_plc    = -1;

    /* Lancement de la synchronisation avec le fichier des conditions de depots placements */
    n_ProcessingRuptureSyncVar (&bd_RuptDepp, ptb_InRec_Cur);

    RETURN_VAL (0);
}



/*==============================================================================
objet :
        fonction lancee pour chaque ligne du maitre

retour :
        0 ----> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePlc(char **ptb_InRec_Cur)
{
    char sz_prime[25];
    char sz_sinistre[25];
    char sz_taux_nul[] = "0";

    DEBUT_FCT("n_ActionLignePlc");

    /* Taux d'interet sinistre */
    if (Taux_sinistres_plc != -1)
    {
        sprintf(sz_sinistre, "%.3lf", Taux_sinistres_plc);
        ptb_InRec_Cur[PLA1_CLMFUNINT_R] = sz_sinistre;
    }
    else if (Taux_sinistres != -1)
    {
        sprintf(sz_sinistre, "%.3lf", Taux_sinistres);
        ptb_InRec_Cur[PLA1_CLMFUNINT_R] = sz_sinistre;
    }
    else ptb_InRec_Cur[PLA1_CLMFUNINT_R] = sz_taux_nul;


    /* Taux d'interet prime */
    if (Taux_primes_plc != -1)
    {
        sprintf(sz_prime, "%.3lf", Taux_primes_plc);
        ptb_InRec_Cur[PLA1_URRFUNINT_R] = sz_prime;
    }
    else if (Taux_primes != -1)
    {
        sprintf(sz_prime, "%.3lf", Taux_primes);
        ptb_InRec_Cur[PLA1_URRFUNINT_R] = sz_prime;
    }
    else ptb_InRec_Cur[PLA1_URRFUNINT_R] = sz_taux_nul;


    sprintf(ptb_InRec_Cur[PLA1_RETEND_NT], "0");
    sprintf(ptb_InRec_Cur[PLA1_END_NT], "0");
    n_WriteCols(PlacemtOutFile,ptb_InRec_Cur,'~',0);

    RETURN_VAL (0);
}



/*==============================================================================
objet :
        fonction lancee pour chaque ligne des placements synchronisee
        avec les conditions de depots placements (TPINTWIT)

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneDepp(
        char **ptb_InRecOwner ,         /* adresse de la ligne du maitre */
        char **ptb_InRecChild)          /* adresse de la ligne de l'esclave */
{
    DEBUT_FCT("n_ActionLigneDepp");

/*    printf("SYNCHRO Conditions depots placement\n"); */

    if ( b_IsBlankOrEmpty(ptb_InRecChild[TPINTWIT_CLMFUNINT_R]) == FALSE )
        Taux_sinistres_plc = atof(ptb_InRecChild[TPINTWIT_CLMFUNINT_R]);          /* sinistres */
    else Taux_sinistres_plc = 0;

    if ( b_IsBlankOrEmpty(ptb_InRecChild[TPINTWIT_URRFUNINT_R]) == FALSE )
        Taux_primes_plc = atof(ptb_InRecChild[TPINTWIT_URRFUNINT_R]);       /* primes */
    else Taux_primes_plc = 0;

    RETURN_VAL (OK);
}


/*==============================================================================
objet :
        fonction lancee pour chaque ligne des placements synchronisee
        avec les conditions de depots  (TINTWIT)

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneDep(
        char **ptb_InRecOwner ,         /* adresse de la ligne du maitre */
        char **ptb_InRecChild)          /* adresse de la ligne de l'esclave */
{
    DEBUT_FCT("n_ActionLigneDep");

/*    printf("SYNCHRO Conditions depots\n"); */

    if ( b_IsBlankOrEmpty(ptb_InRecChild[TINTWIT_CLMFUNINT_R]) == FALSE )
        Taux_sinistres = atof(ptb_InRecChild[TINTWIT_CLMFUNINT_R]);          /* sinistres */
    else Taux_sinistres = 0;

    if ( b_IsBlankOrEmpty(ptb_InRecChild[TINTWIT_URRFUNINT_R]) == FALSE )
        Taux_primes = atof(ptb_InRecChild[TINTWIT_URRFUNINT_R]);             /* primes */
    else Taux_primes = 0;


    RETURN_VAL (OK);
}










