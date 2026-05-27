/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Extraction du premier changement de montant des dernieres previsions
nom du source                 : ESTC2043.c
date de creation              : 09/09/2010
auteur                        : D.GATIBELZA
------------------------------------------------------------------------------
description :   Comme le ESTC2040, on récupère les dernières prévisions,
                mais on vérifie si elle est différente de la prévision précédente, sinon, on récupère la précédente.
------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    20/12/2013   A.Ben Jeddou   Gestion des ruptures ( prendre uniquement les nouveaux CSU ou les CSU de M.estimation differentes)
[007] 10/10/2014 JBG  spot:25773 Left trim spaces on ESTMNT_M before ESTC2043 call
[008] 15/09/2015 SAS  spot 29372 Calcul de compléments sur AC complète [IN:040424] 
[009] 25/02/2019 RAF spot:70045: add mount in ruptur
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>


FILE            *Kp_PrevInFile;             // pointeur sur les previsions en entree
FILE            *Kp_PrevOut1File;           // pointeur sur les dernieres previsions en sortie

T_RUPTURE_VAR   bd_RuptPrev;                // gestion rupture sur les previsions


char *ltrim(char *);
int n_InitPrev(T_RUPTURE_VAR *pbd_Rupt);
int n_IsR1Prev(char **, char **);
int n_ActionFirstRupt1Prev(char **);
int n_IsR2Prev(char **, char **);
int n_ActionFirstRupt2Prev(char **);
int n_ActionLignePrev(char **);
int n_ActionLastRuptPrev(char **);

int n_NumLigneRupt = 0;
char **ptb_InRec_Cur_Prec;

char ptb_InRec_Cur_Prec_ESTMNT_M[30];

char ptb_InRec_Cur_Prec_CRE_D[30];
char ptb_InRec_Cur_Prec_ACMTRS_NT[6];
char ptb_InRec_Cur_Prec_ORICOD_LS[65];
char ptb_InRec_Cur_Prec_CREUSR_CF[6];
char ptb_InRec_Cur_Prec_LSTUPD_D[30];
char ptb_InRec_Cur_Prec_LSTUPDUSR_CF[6];

/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc , char *argv[])
{

    /* Initialisation des signaux */
    InitSig();

    if (n_BeginPgm(argc, argv)                                      == ERR) ExitPgm(ERR_XX, "");

    /* Ouverture des fichiers */
    if (n_OpenFileAppl("ESTC2043_O1", "w", &Kp_PrevOut1File)        == ERR) ExitPgm(ERR_XX, "");

    /* Initialisation de la varible bd_RuptPrev */
    if (n_InitPrev(&bd_RuptPrev)                                    == ERR) ExitPgm(ERR_XX, "");

    /* Lancement du traitement du fichier */
    if (n_ProcessingRuptureVar(&bd_RuptPrev)                        == ERR) ExitPgm(ERR_XX, "");

    /* Fermeture fichier */
    if (n_CloseFileAppl("ESTC2043_I1", &(bd_RuptPrev.pf_InputFil))  == ERR) ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC2043_O1", &Kp_PrevOut1File)            == ERR) ExitPgm(ERR_XX, "");

    if (n_EndPgm()                                                  == ERR) ExitPgm(ERR_XX, "");

    exit(OK);
}


/*==============================================================================
left trim
==============================================================================*/
char *ltrim(char *s)
{
    while (isspace(*s)) s++;
    return s;
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

    memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

    if ( n_OpenFileAppl ("ESTC2043_I1", "rt", &(pbd_Rupt->pf_InputFil)))
        RETURN_VAL (ERR);

    pbd_Rupt->n_NbRupture           = 2;

    pbd_Rupt->n_ConditionRupture[0] = n_IsR1Prev;
    pbd_Rupt->n_ActionFirst[0]      = n_ActionFirstRupt1Prev;
    pbd_Rupt->n_ActionLast[0]       = n_ActionLastRuptPrev;

    pbd_Rupt->n_ConditionRupture[1] = n_IsR2Prev;
    pbd_Rupt->n_ActionFirst[1]      = n_ActionFirstRupt2Prev;

    pbd_Rupt->n_ActionLigne         = n_ActionLignePrev;
    pbd_Rupt->c_Separ               = SEPARATEUR;

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
        fonction de test de rupture niveau 1 sur
                Contrat/Section/Exercice/Annee de compte

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR1Prev(char **ptb_InRec, char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_IsR1Prev");

    if (strcmp(ptb_InRec[PRE_CTR_NF],       ptb_InRec_Cur[PRE_CTR_NF])       != 0) RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_END_NT],       ptb_InRec_Cur[PRE_END_NT])       != 0) RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_SEC_NF],       ptb_InRec_Cur[PRE_SEC_NF])       != 0) RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_UWY_NF],       ptb_InRec_Cur[PRE_UWY_NF])       != 0) RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_UW_NT],        ptb_InRec_Cur[PRE_UW_NT])        != 0) RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_ACY_NF],       ptb_InRec_Cur[PRE_ACY_NF])       != 0) RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_ESTMTH_NF],       ptb_InRec_Cur[PRE_ESTMTH_NF])       != 0) RETURN_VAL(1); // [009]
    if (strcmp(ptb_InRec[PRE_ACMTRS_NT],    ptb_InRec_Cur[PRE_ACMTRS_NT])    != 0) RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_ACMTRS_NT],    ptb_InRec_Cur[PRE_ACMTRS_NT])    != 0) RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_DETTRNCOD_CF], ptb_InRec_Cur[PRE_DETTRNCOD_CF]) != 0) RETURN_VAL(1); // Ajout Rupture PRE_DETTRNCOD_CF 07012014
    if (strcmp(ptb_InRec[PRE_GAAP_NF],      ptb_InRec_Cur[PRE_GAAP_NF])      != 0) RETURN_VAL(1); // Ajout Rupture PRE_GAAP_NF 07072014

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
        fonction de test de rupture niveau 2 sur

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR2Prev(char **ptb_InRec, char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_IsR2Prev");

    if (strcmp(ptb_InRec[PRE_CTR_NF],       ptb_InRec_Cur[PRE_CTR_NF])       != 0) RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_END_NT],       ptb_InRec_Cur[PRE_END_NT])       != 0) RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_SEC_NF],       ptb_InRec_Cur[PRE_SEC_NF])       != 0) RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_UWY_NF],       ptb_InRec_Cur[PRE_UWY_NF])       != 0) RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_UW_NT],        ptb_InRec_Cur[PRE_UW_NT])        != 0) RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_ACY_NF],       ptb_InRec_Cur[PRE_ACY_NF])       != 0) RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_ACMTRS_NT],    ptb_InRec_Cur[PRE_ACMTRS_NT])    != 0) RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_ESTMTH_NF],       ptb_InRec_Cur[PRE_ESTMTH_NF])       != 0) RETURN_VAL(1); // [009]
    if (strcmp(ptb_InRec[PRE_DETTRNCOD_CF], ptb_InRec_Cur[PRE_DETTRNCOD_CF]) != 0) RETURN_VAL(1); // Ajout Rupture PRE_DETTRNCOD_CF 07012014
    if (strcmp(ptb_InRec[PRE_GAAP_NF],      ptb_InRec_Cur[PRE_GAAP_NF])      != 0) RETURN_VAL(1); // Ajout Rupture PRE_GAAP_NF 07072014
    if (strcmp(ptb_InRec[PRE_ESTMNT_M],     ptb_InRec_Cur[PRE_ESTMNT_M])     != 0) RETURN_VAL(1);

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
        Fonction lancee a chaque rupture premiere de niveau 1
==============================================================================*/
int n_ActionFirstRupt1Prev (char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionFirstRuptPrev");

    // Sauvegarde des champs précédents

    strcpy(ptb_InRec_Cur_Prec_ESTMNT_M, ptb_InRec_Cur[PRE_ESTMNT_M]);
    n_WriteCols(Kp_PrevOut1File, ptb_InRec_Cur, SEPARATEUR, 0);

    n_NumLigneRupt = 0;

    RETURN_VAL(OK);
}


/*==============================================================================
objet : fonction lancee pour chaque ligne du maitre
retour :    0 ----> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePrev(char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionLignePrev");

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
        fonction lancee pour chaque ligne repture niveau 2
retour :
        0 ----> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRupt2Prev(char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionFirstRupt2Prev");

    if (atoll(ltrim(ptb_InRec_Cur_Prec_ESTMNT_M)) != atoll(ltrim(ptb_InRec_Cur[PRE_ESTMNT_M])))  //[008]
    {
        strcpy(ptb_InRec_Cur_Prec_ESTMNT_M, ptb_InRec_Cur[PRE_ESTMNT_M]);
        n_WriteCols(Kp_PrevOut1File, ptb_InRec_Cur, SEPARATEUR, 0);
    }

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
        Fonction lancee a chaque rupture dernière de niveau 1
==============================================================================*/
int n_ActionLastRuptPrev (char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionLastRuptPrev");

    RETURN_VAL(OK);
}
