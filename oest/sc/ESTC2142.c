/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Mise au format GT des complements
nom du source                 : ESTC2142.c
revision                      : $Revision:   1.1  $
date de creation              : 03/09/1997
auteur                        : P. Louveau
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :
                Intervertit les donnees acceptation et retrocession pour
                les postes retrocessions


------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    26 01 2004     J Ribot    on ne reconduit pas les postes "Other financial income"
                               11819992 21819992 31819992 41819992 (fiche SPOT 10126)
            ...           ...            ...              ...
[002] 12/08/2014 R. Cassis :spot:25773 Omega 2B : Back to Prod release : Move Accept amount to Retro amount.
[003] 14/08/2014 ABJ  spot:25773 Activation du Test pour tous les GAAP 
[004] 05/09/2014 ABJ  spot:25773 Suppression des Test en dure  
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


FILE            *Kp_GtInFile;                   /* fichier GT en entree */
FILE            *Kp_GtOutRetroFile;             /* fichier GT retro en sortie */
FILE            *Kp_GtOutAcceptFile;            /* fichier GT acceptation en sortie */

T_RUPTURE_VAR           bd_RuptGT;    /* gestion rupture */

int n_InitGT(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLigneGT(char **pbd_InRec_Cur);



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
        if ( n_OpenFileAppl ("ESTC2142_O1","wt",&Kp_GtOutAcceptFile) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2142_O2","wt",&Kp_GtOutRetroFile) == ERR )
                ExitPgm ( ERR_XX , "" );

        /* Initialisation de la varible bd_RuptGT */
        if ( n_InitGT(&bd_RuptGT) )
                ExitPgm ( ERR_XX , "" );

        /* Lancement du traitement du fichier */
        if ( n_ProcessingRuptureVar (&bd_RuptGT) == ERR )
                ExitPgm ( ERR_XX , "" );

        /* Fermeture fichier */
        if (n_CloseFileAppl ("ESTC2142_I1",&(bd_RuptGT.pf_InputFil)) == ERR)
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2142_O1",&Kp_GtOutAcceptFile) == ERR)
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2142_O2",&Kp_GtOutRetroFile) == ERR)
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
int n_InitGT(T_RUPTURE_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitGT");

        memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

        if ( n_OpenFileAppl ("ESTC2142_I1","rt",&(pbd_Rupt->pf_InputFil)))
                RETURN_VAL (ERR);

        pbd_Rupt->n_NbRupture = 0 ;
        pbd_Rupt->n_ActionLigne = n_ActionLigneGT ;

        pbd_Rupt->c_Separ = '~' ;

        RETURN_VAL (0);
}



/*==============================================================================
objet :
        fonction d'echange de pointeurs

retour :
        0 ----> traitement correctement effectue
==============================================================================*/
int n_EchangerZone (char **ptr1, char **ptr2)
{
    char *sz_zone_accept;
    char *sz_zone_retro;

    DEBUT_FCT("n_EchangerZone");

    sz_zone_accept = (*ptr1);
    sz_zone_retro  = (*ptr2);

    *ptr1 = sz_zone_retro;
    *ptr2 = sz_zone_accept;

    RETURN_VAL (0);
}



/*==============================================================================
objet :
        fonction lancee pour chaque ligne du maitre

retour :
        0 ----> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGT(char **ptb_InRec_Cur)
{
    char        type_poste;     /* 1er chiffre du poste:  retrocession= 2 ou 4 */
  

    DEBUT_FCT("n_ActionLigneGT");

    type_poste = ptb_InRec_Cur[GT_TRNCOD_CF][0];


  //[004]


    /* si poste retro, ... */
    if ( (type_poste == '2') || (type_poste == '4') )
    {
/*        printf("poste retro => echange des donnees\n"); */
        /* echange des donnees Acceptation et Retrocession */
        n_EchangerZone (&ptb_InRec_Cur[GT_CTR_NF], &ptb_InRec_Cur[GT_RETCTR_NF]);
        n_EchangerZone (&ptb_InRec_Cur[GT_END_NT], &ptb_InRec_Cur[GT_RETEND_NT]);
        n_EchangerZone (&ptb_InRec_Cur[GT_SEC_NF], &ptb_InRec_Cur[GT_RETSEC_NF]);
        n_EchangerZone (&ptb_InRec_Cur[GT_UWY_NF], &ptb_InRec_Cur[GT_RTY_NF]);
        n_EchangerZone (&ptb_InRec_Cur[GT_UW_NT], &ptb_InRec_Cur[GT_RETUW_NT]);
        n_EchangerZone (&ptb_InRec_Cur[GT_OCCYEA_NF], &ptb_InRec_Cur[GT_RETOCCYEA_NF]);
        n_EchangerZone (&ptb_InRec_Cur[GT_ACY_NF], &ptb_InRec_Cur[GT_RETACY_NF]);
        n_EchangerZone (&ptb_InRec_Cur[GT_SCOSTRMTH_NF], &ptb_InRec_Cur[GT_RETSCOSTRMTH_NF]);
        n_EchangerZone (&ptb_InRec_Cur[GT_SCOENDMTH_NF], &ptb_InRec_Cur[GT_RETSCOENDMTH_NF]);
        n_EchangerZone (&ptb_InRec_Cur[GT_CLM_NF], &ptb_InRec_Cur[GT_RCL_NF]);
        n_EchangerZone (&ptb_InRec_Cur[GT_CUR_CF], &ptb_InRec_Cur[GT_RETCUR_CF]);
        n_EchangerZone (&ptb_InRec_Cur[GT_AMT_M], &ptb_InRec_Cur[GT_RETAMT_M]);   // [002]
        
        
        
        
        
        

        /* ecriture dans le fichier de sortie retro: GT simple */
        ptb_InRec_Cur[GT_CED_NF] = "";
        ptb_InRec_Cur[GT_BRK_NF] = "";
        ptb_InRec_Cur[GT_PAY_NF] = "";
        ptb_InRec_Cur[GT_KEY_NF] = "";
        ptb_InRec_Cur[GT_ESTCUR_CF] = NULL;
        n_WriteCols(Kp_GtOutRetroFile, ptb_InRec_Cur,'~',0);

        RETURN_VAL (0);
    }

    /* Reconduction des complements acceptation dans le fichier de sortie acceptation */
    /* en format GT simple */
/*    printf("poste accept\n"); */
    ptb_InRec_Cur[GT_ESTCUR_CF] = NULL;
    n_WriteCols(Kp_GtOutAcceptFile,ptb_InRec_Cur,'~',0);

    RETURN_VAL (0);
}










