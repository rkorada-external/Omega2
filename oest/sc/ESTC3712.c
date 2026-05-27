/*==============================================================================
Nom de l'application          : Life Estimates Closing Multi-GAAP
Nom du source                 : ESTC3712.c
Révision                      : $Revision: 1.0 $
Date de création              : 19/06/2015
Auteur                        : Paul GARNIER
References des specifications : #################
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
    Calcul automatique de la prévision de sinistralité en fonction de la
    segestation
------------------------------------------------------------------------------
historique des modifications :
     <jj/mm/aaaa>   <auteur>    <description de la modification>
[01]  02/05/2016     SAS         Spot 30300:EST39
=============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "struct.h"
#include "estserv.h"


/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*---------------------------------------------*/

#define HEURE_TRAITEMENT    "23:59:05"

#define PRE_COMACC_B         1
#define PRE_VRS_NF           2
#define PRE_SEG_NF           3
#define PRE_SEGTYP_CT        4


/*------------------------------------------------*/
/* Structure utilisee des ruptures des prévisions */
/*------------------------------------------------*/

// Outputfile structure
enum PERISEG_STRUCT {
    PERISEG_SSD_CF = 0,
    PERISEG_SEG_NF,
    PERISEG_VRS_NF,
    PERISEG_UWY_NF,
    PERISEG_ACY_NF,
    PERISEG_LOSS_R,
    PERISEG_MONTANT_M,
    PERISEG_NB_COLS,
};

/*----------------------*/
/* Variables de travail */
/*----------------------*/

FILE                *Kp_InputFil_CURCOT;            /* Pointeur sur le fichier LIFEST en sortie du 3711.c */
FILE                *Kp_OutputFil_LIFEST;           /* Pointeur sur le fichier SEGMNT en sortie */
FILE                *Kp_OutputFil_PERISEG;          /* Pointeur sur le fichier SEGMNT en sortie */


T_RUPTURE_VAR       pbd_RuptLIFEST;                 /* Structure contenant les PA / CTR */
T_RUPTURE_SYNC_VAR  pbd_SyncSEGEST;                 /* Structure contenant le FSEGEST */

char                *Ksz_line[PERISEG_NB_COLS + 6] = {NULL};
double              Kn_sum1510 = 0.0;

double              LOSSRAT;
double              MNTSINISTRE;
char                AMORAT;
char                *DEVISE;

/*------------------*/
/*    Prototypes    */
/*------------------*/

int n_InitRuptLIFEST(T_RUPTURE_VAR *pbd_RuptLIFEST);
int n_IsRLIFEST(char **ptb_InRecCur, char **pbd_InRecNext);
int n_ActionFirstRuptLIFEST(char **pbd_RuptLIFEST);
int n_ActionLastRuptLIFEST(char **pbd_RuptLIFEST);
int n_ActionLigneLIFEST(char **pbd_RuptLIFEST);

int n_InitSyncSEGEST(T_RUPTURE_SYNC_VAR *pbd_SyncSEGEST);
int n_ConditionSyncSEGEST(char **ptb_RuptLIFEST, char **pbd_SyncSEGEST);
int n_ActionLigneSyncSEGEST(char **ptb_RuptLIFEST, char **pbd_SyncSEGEST);

int errorMsg(char *error);  /* Fonction d'appel en cas d'erreur */


/*==============================================================================
objet   :   Point d'entree du programme
retour  :   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc, char *argv[])
{
    /* Initialisation des signaux */
    InitSig();

    if (n_BeginPgm(argc, argv) == ERR)                                      ExitPgm(ERR_XX, "");

    if (n_OpenFileAppl("ESTC3712_O1", "wt", &Kp_OutputFil_PERISEG) == ERR)  ExitPgm(ERR_XX, "");
    if (n_OpenFileAppl("ESTC3712_O2", "wt", &Kp_OutputFil_LIFEST) == ERR)   ExitPgm(ERR_XX, "");
    if (n_OpenFileAppl("ESTC3712_I3", "rb", &Kp_InputFil_CURCOT) == ERR)    ExitPgm(ERR_XX, "");
    if (n_InitRuptLIFEST(&pbd_RuptLIFEST) == ERR)                           ExitPgm(ERR_XX, "");
    if (n_InitSyncSEGEST(&pbd_SyncSEGEST) == ERR)                           ExitPgm(ERR_XX, "");

    /* Lancement du traitement */
    if (n_ProcessingRuptureVar(&pbd_RuptLIFEST) == ERR)                     ExitPgm(ERR_XX, "");

    /* Fermeture de tout les fichiers ouverts */
    if (n_CloseFileAppl("ESTC3712_I1", &pbd_RuptLIFEST.pf_InputFil) == ERR) ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC3712_I2", &pbd_SyncSEGEST.pf_InputFil) == ERR) ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC3712_I3", &Kp_InputFil_CURCOT) == ERR)         ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC3712_O1", &Kp_OutputFil_PERISEG) == ERR)       ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC3712_O2", &Kp_OutputFil_LIFEST) == ERR)        ExitPgm(ERR_XX, "");

    if (n_EndPgm() == ERR)                                                  ExitPgm(ERR_XX, "");

    exit(OK);
}



/*==============================================================================
objet :     Initialisation de la structure de rupture du LIFEST
retour:     0 ----> OK
            ERR --> Error
==============================================================================*/
int n_InitRuptLIFEST(T_RUPTURE_VAR *pbd_RuptLIFEST)
{
    DEBUT_FCT("n_InitRuptLIFEST");
    memset(pbd_RuptLIFEST, 0, sizeof(T_RUPTURE_VAR));

    // Ouverture du fichier LIFEST
    if (n_OpenFileAppl("ESTC3712_I1", "rt", &(pbd_RuptLIFEST->pf_InputFil)) == ERR)
        RETURN_VAL(errorMsg("LIFEST openning failed. Error in ESTC3712.\n"));

    pbd_RuptLIFEST->n_NbRupture              = 1;

    /* Fonction du test de rupture de niveau 1 */
    pbd_RuptLIFEST->n_ConditionRupture[0]    = n_IsRLIFEST;
    pbd_RuptLIFEST->n_ActionFirst[0]         = n_ActionFirstRuptLIFEST;
    pbd_RuptLIFEST->n_ActionLast[0]          = n_ActionLastRuptLIFEST;
    pbd_RuptLIFEST->n_ActionLigne            = n_ActionLigneLIFEST;


    pbd_RuptLIFEST->c_Separ                  = SEPARATEUR;

    RETURN_VAL(OK);
}


/*==============================================================================
objet :     Initialisation de la structure de rupture du LIFEST
retour:     0 ----> OK
            ERR --> Error
==============================================================================*/
int n_InitSyncSEGEST(T_RUPTURE_SYNC_VAR *pbd_SyncSEGEST)
{
    DEBUT_FCT("n_InitSyncLIFEST");
    memset(pbd_SyncSEGEST, 0, sizeof(T_RUPTURE_SYNC_VAR));

    // Ouverture du fichier Peri
    if (n_OpenFileAppl("ESTC3712_I2", "rt", &(pbd_SyncSEGEST->pf_InputFil)) == ERR)
        RETURN_VAL(errorMsg("PERICASE openning failed. Error in ESTC3712.\n"));

    pbd_SyncSEGEST->n_NbRupture                 = 0;
    pbd_SyncSEGEST->ConditionEndSync            = n_ConditionSyncSEGEST;
    pbd_SyncSEGEST->n_ActionLigne               = n_ActionLigneSyncSEGEST;

    pbd_SyncSEGEST->c_Separ                     = SEPARATEUR;

    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   fonction de test de rupture de niveau 1
retour  :   0       ---> pas de rupture
            sinon   ---> rupture
==============================================================================*/
int n_ConditionSyncSEGEST(char **ptb_RuptLIFEST, char **ptd_SyncSEGEST)
{
    int     ret = 0;
    DEBUT_FCT("n_IsR1LIFEST");

    if ((ret = strcmp(ptb_RuptLIFEST[PRE_NBCOL + PRE_SEG_NF], ptd_SyncSEGEST[SEG_SEG_NF])) != 0)    RETURN_VAL(ret);
    if ((ret = strcmp(ptb_RuptLIFEST[PRE_SSD_CF], ptd_SyncSEGEST[SEG_SSD_CF])) != 0)                RETURN_VAL(ret);
    if ((ret = strcmp(ptb_RuptLIFEST[PRE_UWY_NF], ptd_SyncSEGEST[SEG_UWY_NF])) != 0)                RETURN_VAL(ret);
    if ((ret = strcmp(ptb_RuptLIFEST[PRE_ACY_NF], ptd_SyncSEGEST[SEG_ACY_NF])) != 0)                RETURN_VAL(ret);


    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   fonction de test de rupture de niveau 1
retour  :   0       ---> pas de rupture
            sinon   ---> rupture
==============================================================================*/
int n_IsRLIFEST(char **ptb_RuptLIFEST, char **ptb_RuptLIFEST_CUR)
{
    int     ret = 0;
    DEBUT_FCT("n_IsR1LIFEST");

    if ((ret = strcmp(ptb_RuptLIFEST[PRE_NBCOL + PRE_SEG_NF], ptb_RuptLIFEST_CUR[PRE_NBCOL + PRE_SEG_NF])) != 0)    RETURN_VAL(ret);
    if ((ret = strcmp(ptb_RuptLIFEST[PRE_SSD_CF], ptb_RuptLIFEST_CUR[PRE_SSD_CF])) != 0)                            RETURN_VAL(ret);
    if ((ret = strcmp(ptb_RuptLIFEST[PRE_UWY_NF], ptb_RuptLIFEST_CUR[PRE_UWY_NF])) != 0)                            RETURN_VAL(ret);
    if ((ret = strcmp(ptb_RuptLIFEST[PRE_ACY_NF], ptb_RuptLIFEST_CUR[PRE_ACY_NF])) != 0)                            RETURN_VAL(ret);


    RETURN_VAL(OK);
}


/*==============================================================================
objet   :
retour  :   0 ---> traitement correctement effectue
==============================================================================*/
int n_ActionLigneSyncSEGEST(char **ptb_RuptLIFEST, char **ptd_SyncSEGEST)
{
    DEBUT_FCT("n_ActionLigneSyncSEGEST");

    LOSSRAT     = atof(ptd_SyncSEGEST[SEG_LOSRAT_R]);
    MNTSINISTRE = atof(ptd_SyncSEGEST[SEG_CLMAMT_M]);
    AMORAT      = ptd_SyncSEGEST[SEG_AMORAT_CT][0];
    DEVISE      = ptd_SyncSEGEST[SEG_CUR_CF];

    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   Fonction lancee à chaque ligne LIFEST
retour  :   0 ---> traitement correctement effectue
==============================================================================*/
int n_ActionLigneLIFEST(char **pbd_RuptLIFEST)
{
    char    tmpBuffer[30] = {0};
    double  d_taux;
    double  d_montant;
    DEBUT_FCT("n_ActionLigneLIFEST");

    if ((d_taux = d_GetTaux(Kp_InputFil_CURCOT,
                            (char)atoi(pbd_RuptLIFEST[PRE_SSD_CF]),
                            (short)atoi(pbd_RuptLIFEST[PRE_BALSHEY_NF]),
                            pbd_RuptLIFEST[PRE_CUR_CF], DEVISE)) != -1 )
    {
        d_montant = atof(pbd_RuptLIFEST[PRE_ESTMNT_M]) * d_taux;
        sprintf(tmpBuffer, "%.3lf", d_montant);
        pbd_RuptLIFEST[PRE_ESTMNT_M]    = tmpBuffer;
        pbd_RuptLIFEST[PRE_CUR_CF]      = DEVISE;
    }
    else
        RETURN_VAL(errorMsg("Pas de taux associer a la devise demandee\n"));

    if (strcmp(pbd_RuptLIFEST[PRE_DETTRNCOD_CF], "XXXXX") == 0)
        if ((strcmp(pbd_RuptLIFEST[PRE_ACMTRS_NT], "1510") == 0) && (pbd_RuptLIFEST[PRE_GAAP_NF][0] == '1'))   //[01]
            Kn_sum1510 += d_montant;

    n_WriteCols(Kp_OutputFil_LIFEST, pbd_RuptLIFEST, SEPARATEUR, 0);
    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   Fonction lancee à la première rupture
retour  :   0 ---> traitement correctement effectue
==============================================================================*/
int n_ActionFirstRuptLIFEST(char **pbd_RuptLIFEST)
{
    DEBUT_FCT("n_ActionFirstRuptLIFEST");

    LOSSRAT      = 0.0;
    MNTSINISTRE  = 0.0;
    Kn_sum1510   = 0.0;
    AMORAT       = 0;
    DEVISE       = "EUR";

    if (n_ProcessingRuptureSyncVar(&pbd_SyncSEGEST, pbd_RuptLIFEST) == ERR)
        RETURN_VAL(ERR);

    RETURN_VAL(OK);
}


/*==============================================================================
objet   :
retour  :   0 ---> traitement correctement effectue
==============================================================================*/
int n_ActionLastRuptLIFEST(char **pbd_RuptLIFEST)
{
    char tmpBuffer[30] = {0};
    DEBUT_FCT("n_ActionFirstRuptLIFEST");

    if (AMORAT == 'R')
    {

        sprintf(tmpBuffer, "%.10lf", LOSSRAT);
        Ksz_line[PERISEG_LOSS_R] = strdup(tmpBuffer);
        memset(tmpBuffer, 0, sizeof(*tmpBuffer) * 30);

        if (LOSSRAT != 0.0)
        {
            sprintf(tmpBuffer, "%.3lf", Kn_sum1510 * (LOSSRAT * 100));
            Ksz_line[PERISEG_MONTANT_M] = strdup(tmpBuffer);
        }
        else
        {
            sprintf(tmpBuffer, "%.3lf", 0.0);
            Ksz_line[PERISEG_MONTANT_M] = strdup(tmpBuffer);
        }
    }
    else if (AMORAT == 'S')
    {
        if (Kn_sum1510 != 0.0)
        {
            sprintf(tmpBuffer, "%.10lf", MNTSINISTRE / Kn_sum1510);
            Ksz_line[PERISEG_LOSS_R] = strdup(tmpBuffer);
            memset(tmpBuffer, 0, sizeof(*tmpBuffer) * 30);

            sprintf(tmpBuffer, "%.3lf", MNTSINISTRE);
            Ksz_line[PERISEG_MONTANT_M] = strdup(tmpBuffer);
        }
        else
        {
            sprintf(tmpBuffer, "%.10lf", 0.0);
            Ksz_line[PERISEG_LOSS_R] = strdup(tmpBuffer);
            memset(tmpBuffer, 0, sizeof(*tmpBuffer) * 30);

            sprintf(tmpBuffer, "%.3lf", 0.0);
            Ksz_line[PERISEG_MONTANT_M] = strdup(tmpBuffer);
        }
    }
    else
    {
        sprintf(tmpBuffer, "%.10lf", 0.0);
        Ksz_line[PERISEG_LOSS_R] = strdup(tmpBuffer);
        memset(tmpBuffer, 0, sizeof(*tmpBuffer) * 30);

        sprintf(tmpBuffer, "%.3lf", 0.0);
        Ksz_line[PERISEG_MONTANT_M] = strdup(tmpBuffer);
    }


    Ksz_line[PERISEG_SEG_NF] = pbd_RuptLIFEST[PRE_NBCOL + PRE_SEG_NF];
    Ksz_line[PERISEG_VRS_NF] = pbd_RuptLIFEST[PRE_NBCOL + PRE_VRS_NF];
    Ksz_line[PERISEG_SSD_CF] = pbd_RuptLIFEST[PRE_SSD_CF];
    Ksz_line[PERISEG_UWY_NF] = pbd_RuptLIFEST[PRE_UWY_NF];
    Ksz_line[PERISEG_ACY_NF] = pbd_RuptLIFEST[PRE_ACY_NF];

    n_WriteCols(Kp_OutputFil_PERISEG, Ksz_line, SEPARATEUR, 0);

    free(Ksz_line[PERISEG_LOSS_R]);
    free(Ksz_line[PERISEG_MONTANT_M]);

    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   Fonction d'affichage de message d'erreur
retour  :   ERR --> permet l'arret du programme
==============================================================================*/
int errorMsg(char *error)   // error : message d'erreur à écrire
{
    char    MsgAno[100];    /* message d'anomalie */

    sprintf(MsgAno, error);
    n_WriteAno(MsgAno);

    RETURN_VAL(ERR);
}