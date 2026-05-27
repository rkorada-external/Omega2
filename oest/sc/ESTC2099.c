/*==============================================================================
nom de l'application          : Ajouter les bases de Calculs
nom du source                 : ESTC2099.c
revision                      :
date de creation              : 22/04/2014
auteur                        : R. Ben Ezzine
references des specifications :
squelette de base             : batch
------------------------------------------------------------------------------
description :
------------------------------------------------------------------------------
historique des modifications :
<jj/mm/aaaa>   <auteur>  <SPOT>     <description de la modification>
 18/09/2015     RBE                 Création
[001] 12/03/2019 sbehague    :spira:70044 REQ.L.02.05: Evolution quarterly
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>

#define NB_MAX_TRSLNK 20000
char                Ksz_CRE_D[22] = {'\0'};
int                 Kn_NbLigTrslnk = 0;
T_TRSLNK_RET        Kbd_TRSLNK[NB_MAX_TRSLNK];

T_RUPTURE_VAR   bd_RuptPrev;                // gestion rupture sur les previsions

FILE        *Kp_TrslnkFil;
FILE        *Kp_LifestO1Fil;
FILE        *Kp_LifestAno;
FILE        *Kp_LifestI2Fil;

typedef struct {
    char    PRS_CF[4];
    char    ACMTRS[5];
    char    DETTRNCOD[6];
} T_ACMTRS_DET;

T_ACMTRS_DET Kbd_Acmtrs_det[10];

#define HEURE_TRAITEMENT "23:59:52"

int     Kn_Acmtrs_det = 0;

char    Ksz_old_DETTRNCOD[6];

int n_InitPrev(T_RUPTURE_VAR *pbd_Rupt);
int n_IsR1Prev(char **, char **);
int n_ActionLignePrev(char **);
int n_ChargerTRSLNK(FILE* Kp_TrslnkFil);
char* n_FindACMTRS(char *dettrncod);
int n_ReconduirePrevision (char **ptb_InRec_Cur);

/*==============================================================================
objet :     point d'entree du programme
retour :    En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc, char *argv[])
{
    // Initialisation des signaux
    InitSig();

    if (n_BeginPgm(argc, argv) == ERR) ExitPgm(ERR_XX, "");

    sprintf(Ksz_CRE_D, "%s %s", psz_GetCharArgv(1), HEURE_TRAITEMENT);


    // Ouverture des fichiers
    if (n_OpenFileAppl("ESTC2099_O1", "wt", &Kp_LifestO1Fil)     == ERR) ExitPgm(ERR_XX, "");
    if (n_OpenFileAppl("ESTC2099_O2", "wt", &Kp_LifestAno)       == ERR) ExitPgm(ERR_XX, "");
    if (n_OpenFileAppl("ESTC2099_I1", "rb", &Kp_TrslnkFil)       == ERR) ExitPgm(ERR_XX, "");


    // Chargement en memoire du fichier pilotage
    if (n_ChargerTRSLNK(Kp_TrslnkFil)                            == ERR) ExitPgm(ERR_XX, "");

    /* Initialisation de la varible bd_RuptPrev */
    if (n_InitPrev(&bd_RuptPrev)                                 == ERR) ExitPgm(ERR_XX, "");

    /* Lancement du traitement du fichier */
    if (n_ProcessingRuptureVar(&bd_RuptPrev)                     == ERR) ExitPgm(ERR_XX, "");

    // Fermeture des fichiers
    if (n_CloseFileAppl("ESTC2099_I1", &Kp_TrslnkFil)            == ERR) ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC2099_I2", &bd_RuptPrev.pf_InputFil) == ERR) ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC2099_O1", &Kp_LifestO1Fil)          == ERR) ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC2099_O2", &Kp_LifestAno)            == ERR) ExitPgm(ERR_XX, "");


    if (n_EndPgm() == ERR) ExitPgm(ERR_XX, "");

    exit(OK);
}
/*************** Fin Main ****************/

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
    memset(Kbd_Acmtrs_det , 0 , sizeof(Kbd_Acmtrs_det));

    if (n_OpenFileAppl("ESTC2099_I2", "rt", &(pbd_Rupt->pf_InputFil)) == ERR)
        RETURN_VAL(ERR);

    pbd_Rupt->n_NbRupture           = 1;

    pbd_Rupt->n_ConditionRupture[0] = n_IsR1Prev;

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
    int ret = 0;
    DEBUT_FCT("n_IsR1Prev");

    if ((ret = strcmp(ptb_InRec[PRE_CTR_NF],       ptb_InRec_Cur[PRE_CTR_NF]))       != 0) RETURN_VAL(ret);
    if ((ret = strcmp(ptb_InRec[PRE_END_NT],       ptb_InRec_Cur[PRE_END_NT]))       != 0) RETURN_VAL(ret);
    if ((ret = strcmp(ptb_InRec[PRE_SEC_NF],       ptb_InRec_Cur[PRE_SEC_NF]))       != 0) RETURN_VAL(ret);
    if ((ret = strcmp(ptb_InRec[PRE_UWY_NF],       ptb_InRec_Cur[PRE_UWY_NF]))       != 0) RETURN_VAL(ret);
    if ((ret = strcmp(ptb_InRec[PRE_UW_NT],        ptb_InRec_Cur[PRE_UW_NT]))        != 0) RETURN_VAL(ret);
    if ((ret = strcmp(ptb_InRec[PRE_ACY_NF],       ptb_InRec_Cur[PRE_ACY_NF]))       != 0) RETURN_VAL(ret);
    if ((ret = strcmp(ptb_InRec[PRE_ESTMTH_NF],    ptb_InRec_Cur[PRE_ESTMTH_NF]))    != 0) RETURN_VAL(ret);
    //if (strcmp(ptb_InRec[PRE_ACMTRS_NT],           ptb_InRec_Cur[PRE_ACMTRS_NT])     != 0) RETURN_VAL(1);
    if ((ret = strcmp(ptb_InRec[PRE_DETTRNCOD_CF], ptb_InRec_Cur[PRE_DETTRNCOD_CF])) != 0) RETURN_VAL(ret);
    if ((ret = strcmp(ptb_InRec[PRE_GAAP_NF],      ptb_InRec_Cur[PRE_GAAP_NF]))      != 0) RETURN_VAL(ret);

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

    memset(Kbd_Acmtrs_det , 0 , sizeof(Kbd_Acmtrs_det));

    n_FindACMTRS(ptb_InRec_Cur[PRE_DETTRNCOD_CF]);

    n_ReconduirePrevision(ptb_InRec_Cur);

    RETURN_VAL(OK);
}


// ----------------------------------------------------------------------------
// objet:  Lit le fichier binaire des postes et les met en memoire
// ----------------------------------------------------------------------------
int n_ChargerTRSLNK(FILE* Kp_TrslnkFil)
{
    T_TRSLNK_RET bd_Lu;
    Kn_NbLigTrslnk = 0;

    DEBUT_FCT("n_ChargerTRSLNK");

    while (fread(&bd_Lu, sizeof(T_TRSLNK_RET), 1, Kp_TrslnkFil) > 0)
    {
        if ( Kn_NbLigTrslnk + 1 >=  NB_MAX_TRSLNK) //NB_MAX_TRSLNK == 2000
            RETURN_VAL(ERR);
        if (bd_Lu.PRS_CF == 50)
            Kbd_TRSLNK[Kn_NbLigTrslnk++] = bd_Lu;
    }
    RETURN_VAL(OK);
}


/*==========================================================================
       Objet :    Recuperer l'ACMTR grace au DETTRNCOD selon LOB
       Nom:       n_FindACMTRS

       Parametres:
                  pointure sur stucture T_ACCPAR
                  Acmtrs

       Retour:    0/-1
===========================================================================*/
char* n_FindACMTRS(char* dettrncod) {

    int n_indice;

    Kn_Acmtrs_det = 0;
    for  (n_indice = 0; n_indice < Kn_NbLigTrslnk; n_indice++ )
    {
        // S'ils sont egaux, sauvegarder l'acmtrs, dettrncod et prs_cf
        if (strncmp(dettrncod, Kbd_TRSLNK[n_indice].DETTRNCOD_CF, 5) == 0)
        {
            sprintf(Kbd_Acmtrs_det[Kn_Acmtrs_det].ACMTRS, "%d", Kbd_TRSLNK[n_indice].ACMTRS_NT);
            sprintf(Kbd_Acmtrs_det[Kn_Acmtrs_det].DETTRNCOD, "%s", Kbd_TRSLNK[n_indice].DETTRNCOD_CF);
            sprintf(Kbd_Acmtrs_det[Kn_Acmtrs_det].PRS_CF, "%d", Kbd_TRSLNK[n_indice].PRS_CF);
            //printf("\033[34;1mKbd_TRSLNK[%i] = %s\t%s\t%s\t%s\n\033[0m", Kn_Acmtrs_det, dettrncod, Kbd_Acmtrs_det[Kn_Acmtrs_det].ACMTRS, Kbd_Acmtrs_det[Kn_Acmtrs_det].DETTRNCOD, Kbd_Acmtrs_det[Kn_Acmtrs_det].PRS_CF);

            //printf(" ACMTRS en cours %s _ %s\n", Kbd_Acmtrs_det[n_indice].ACMTRS, Kbd_Acmtrs_det[n_indice].DETTRNCOD);
            Kn_Acmtrs_det++;
        }
    }
    return "0";
}

/*==============================================================================
objet :
        fonction d'ecriture d'une prevision dans le fichier adequat
retour :
        OK ---> traitement correctement effectue
==============================================================================*/
int n_ReconduirePrevision (char **ptb_InRec_Cur)
{
    int n_indice = 0;

    DEBUT_FCT("n_ReconduirePrevision");

    //printf("Kbd_Acmtrs_det[n_indice].ACMTRS [%s]\n", Kbd_Acmtrs_det[0].ACMTRS);
    for (n_indice = 0; n_indice < Kn_Acmtrs_det; n_indice++)
    {

        //printf(" DETTRNCOD a chercher %s \n", ptb_InRec_Cur[PRE_DETTRNCOD_CF]);
        //printf("Kbd_Acmtrs_det[n_indice].ACMTRS [%s]\n", Kbd_Acmtrs_det[n_indice].ACMTRS);

        if ( strcmp(Kbd_Acmtrs_det[n_indice].ACMTRS, "") != 0)
        {
            ptb_InRec_Cur[PRE_ACMTRS_NT]      = Kbd_Acmtrs_det[n_indice].ACMTRS;
            //ptb_InRec_Cur[PRE_DETTRNCOD_CF] = Kbd_Acmtrs_det[n_indice].DETTRNCOD;

            if ( strcmp(Kbd_Acmtrs_det[n_indice].PRS_CF, "") != 0)
            {
                ptb_InRec_Cur[PRE_PRS_CF]      = Kbd_Acmtrs_det[n_indice].PRS_CF;
            }
            //printf("Ecriture [%s][%s]\n", ptb_InRec_Cur[PRE_DETTRNCOD_CF], ptb_InRec_Cur[PRE_UWY_NF]);
            ptb_InRec_Cur[PRE_ORICOD_LS] = "BASE CALC";
            n_WriteCols(Kp_LifestO1Fil, ptb_InRec_Cur, SEPARATEUR, 0);

        }
        else
        {
            n_WriteCols(Kp_LifestAno, ptb_InRec_Cur, SEPARATEUR, 0);
        }
    }

    RETURN_VAL (OK);
}
