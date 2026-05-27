/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Extraction des dernieres previsions
nom du source                 : ESTC2040.c
revision                      : $Revision:   1.0  $
date de creation              : 03/10/1997
auteur                        : P. Louveau
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :   
                Traitement permettant de scinder en deux fichiers les dernieres
                previsions des autres.
                 
------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
           ...           ...            ...              ...
[001] 15/01/2019 S.Behague    :REQ.L.02.05: Evolution quarterly
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


FILE            *Kp_PrevInFile;                 /* pointeur sur les previsions en entree */     
FILE            *Kp_PrevOut1File;               /* pointeur sur les dernieres previsions en sortie */
FILE            *Kp_PrevOut2File;               /* pointeur sur les previsions en sortie */

T_RUPTURE_VAR    bd_RuptPrev;                   /* gestion rupture sur les previsions */


int n_InitPrev(T_RUPTURE_VAR *pbd_Rupt);
int n_IsR1Prev(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRuptPrev(char **ptb_InRec_Cur);
int n_ActionLignePrev(char **pbd_InRec_Cur);


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

        /* Ouverture des fichiers */
        if ( n_OpenFileAppl ("ESTC2040_O1","wt",&Kp_PrevOut1File) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2040_O2","wt",&Kp_PrevOut2File) == ERR )
                ExitPgm ( ERR_XX , "" );

        /* Initialisation de la varible bd_RuptPrev */
        if ( n_InitPrev(&bd_RuptPrev) )
                ExitPgm ( ERR_XX , "" );

        /* Lancement du traitement du fichier */
        if ( n_ProcessingRuptureVar (&bd_RuptPrev) == ERR )
                ExitPgm ( ERR_XX , "" );

        /* Fermeture fichier */
        if (n_CloseFileAppl ("ESTC2040_I1",&(bd_RuptPrev.pf_InputFil)) == ERR)
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2040_O1",&Kp_PrevOut1File) == ERR)
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2040_O2",&Kp_PrevOut2File) == ERR)
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
int n_InitPrev(T_RUPTURE_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitPrev");

        memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

        if ( n_OpenFileAppl ("ESTC2040_I1","rt",&(pbd_Rupt->pf_InputFil)))
                RETURN_VAL (ERR);

        pbd_Rupt->n_NbRupture = 1 ;
        pbd_Rupt->n_ConditionRupture[0] = n_IsR1Prev;
        pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptPrev;

        pbd_Rupt->n_ActionLigne = n_ActionLignePrev ;

        pbd_Rupt->c_Separ = '~' ;

        RETURN_VAL (0);
}


/*==============================================================================
objet :
        fonction de test de rupture niveau 1 sur
                Contrat/Section/Exercice/Annee de compte

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR1Prev(char **ptb_InRec,char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_IsR1Prev");

        if (strcmp(ptb_InRec[PRE_CTR_NF],ptb_InRec_Cur[PRE_CTR_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PRE_SEC_NF],ptb_InRec_Cur[PRE_SEC_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PRE_UWY_NF],ptb_InRec_Cur[PRE_UWY_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PRE_ACY_NF],ptb_InRec_Cur[PRE_ACY_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PRE_ESTMTH_NF],ptb_InRec_Cur[PRE_ESTMTH_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PRE_ACMTRS_NT],ptb_InRec_Cur[PRE_ACMTRS_NT])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PRE_DETTRNCOD_CF],ptb_InRec_Cur[PRE_DETTRNCOD_CF])!=0) // Ajout Rupture PRE_DETTRNCOD_CF 07012014
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PRE_GAAP_NF],ptb_InRec_Cur[PRE_GAAP_NF])!=0) // Ajout rupture PRE_GAAP_NF 07/02/2014 pour avoir toutes les lignes de GAAP en sortie
                RETURN_VAL(1);
        RETURN_VAL (0);
}



/*==============================================================================
objet :
        Fonction lancee a chaque rupture premiere de niveau 1
==============================================================================*/
int n_ActionFirstRuptPrev (char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionFirstRuptPrev");

    /* ecriture dans le 1er fichier de sortie */
    /*printf("Ecriture 1er fichier...");*/
    n_WriteCols(Kp_PrevOut1File,ptb_InRec_Cur,'~',0);
    /*printf("OK\n");*/

    RETURN_VAL (0);
}


/*==============================================================================
objet :
        fonction lancee pour chaque ligne du fichier des previsions

retour :
        0 ----> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePrev(char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionLignePrev");

    if ( b_IsRupture(&bd_RuptPrev, F1) == FALSE ) {
        /*printf("Ecriture 2e fichier...");*/
        n_WriteCols(Kp_PrevOut2File,ptb_InRec_Cur,'~',0);
        /*printf("OK\n");*/
    }
    
    RETURN_VAL (0);
}






