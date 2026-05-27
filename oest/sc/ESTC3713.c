/*==============================================================================
Nom de l'application          : Life Estimates Closing Multi-GAAP
Nom du source                 : ESTC3713.c
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
[01]  13/04/2016      SAS        création des postes 1480 dans la grille 
[02]  03/05/2016      SAS        plantage INT fct FREE
[03]  10/05/2016      SBE :spot:30300 - EST39 Correction
[04]  16/06/2016      DFI :spot:30300 - Ajout des postes manquants pour le poste 1480 cree
[05]  12/07/2016      SBE :spot:30914 - Pb écrasement mémoire
[06]  17/11/2016      SAS :spot:31495 - le calcul de la sinistralité n'est pas correct
=============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>


/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*---------------------------------------------*/

#define HEURE_TRAITEMENT        "23:59:52"
#define MONTANT_ZERO            "0.000"
#define ACMTRS_1480             "1480"                 // [01]
#define DETTRNCOD_1480          "59000"                // [01]
#define PRS_1480                "500"                  // [04]
#define INDSUP_1480             "0"                    // [04]
#define CREUSR_1480             "dbo"                  // [04]
#define GAPDIFF_1480            "0.000"                // [04]
#define PROPOGATION_1480        "1"                    // [04]
#define PRE_COMACC_B            1
#define PRE_VRS_NF              2
#define PRE_SEG_NF              3
#define PRE_SEGTYP_CT           4
#define BATCH_B                 "1"
#define LSTUPDUSER_CF           "dbo"
#define ORICOD_LS               "segmentation"
#define Kn_MaxPostes            20000  
#define dtrs                    "        "
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

// static FILE *Kp_TrslnkFil;
// static int n_ChargerTRSLNK ();

typedef struct S_Poste {
    char                *(line[PRE_NBCOL + PRE_SEGTYP_CT + 1]);     // Ligne au format prevision

    char                *VRS_NF;                                    // Version de la segmentation
    char                *SEG_NF;                                    // Segement
    char                *SEGTYP_CT;                                 // Segement type

    char                COMACC_B;                                   // Booleen (Y == CC, N == pas CC)
    char                Cas;
    // Cas == 'A' -> Primes acquises = 0
    // Cas == 'B' -> Sinistre/Prime traité SUPERIEUR Sinistre/Prime segement
    // Cas == 'C' -> Sinistre/Prime traité INFERIEUR OU EGAL Sinistre/Prime segement
    // Cas == 'D' -> Comptes complets

    double              sinistralite;
    double              ComptaSinex;
    double              Alloc1SINEX;
    double              Alloc2SINEX;
    double              Alloc3SINEX;
    double              Alloc3STAsre;
    double              MONTANT_M;
    double              sum_1510_all;
    double              Sp;
    double              LOSSR;
} T_Poste;

typedef enum {
    poste_1220 = 0, // ACMTRS = 1220 -> Compta sinistre (issu de FDRYTRN)
    poste_1243,     // ACMTRS = 1243 -> Libérations de provisions
    poste_1244,     // ACMTRS = 1244 -> Constitutions de provisions
    poste_1510,     // ACMTRS = 1510 -> Prime Acquise (PA issu de 2045 issu de 3026A)
    poste_SEG,      // Sinistralite associee au traite
    nb_poste,       // doit toujours etre a la dernière place sinon sigsegv
} e_poste;

typedef struct S_traite
{
    int                 sentinel;
    T_Poste             postes[nb_poste];

    struct S_traite     *prev;
    struct S_traite     *next;
} T_traite;


/*----------------------*/
/* Variables de travail */
/*----------------------*/
FILE                *Kp_InputFil_CURCOT;            /* Pointeur sur le fichier LIFEST en sortie du 3711.c */
FILE                *Kp_InputFil_LIFEST;            /* Pointeur sur le fichier LIFEST en sortie du 3711.c */
FILE                *Kp_TACCPAR;                    // Pointeur sur le fichier accpar en entree
FILE                *Kp_InputFil_PERISEG;           /* Pointeur sur le fichier SEGMNT en sortie */
FILE                *Kp_SubTrsesBrop;
FILE                *Kp_OutputFil_LIFEST;           /* Pointeur sur le fichier LIFEST  en sortie */
FILE                *Kp_OutputFil_LOG;              /* Pointeur sur le fichier ANO/LOG en sortie */
FILE                *Kp_PilotIFil;               // Pointeur sur le fichier pilotage en entree
FILE                *Kp_PilotOFil;               // Pointeur sur le fichier pilotage en sortie

T_RUPTURE_VAR       pbd_RuptPERISEG;                /* Structure contenant les PA / CTR */
T_RUPTURE_SYNC_VAR  pbd_SyncLIFEST;                 /* Structure contenant le FSEGEST */
T_RUPTURE_SYNC_VAR  pbd_SyncPERICASE;               /* Structure contenant le FSEGEST */

T_LIFDRI_ALL        Kbd_PILOT[NB_MAX_PILOT];    // Fichier pilotage charge en memoire
int                 Kn_NbLigPilot;              // Nombre de lignes dans le fichier pilotage
//e_poste             Kn_nbPoste = -1;
int                 Kn_nbPoste = -1;
int                 kn_traiter = 0;
int                 Kn_nbPoste1243 = 0;
int                 kn_traiter_max = 0;
char                *acadmtyp;
char                Ksz_Cre_D[22];
char                Ksz_year_D[6];
char                Ksz_mth_D[6];
char                *ksz_ACMTRS[] = {"1220",
                                     "1243",
                                     "1244",
                                     "1510",
                                     NULL
                                    };
char                *((*ksn_SavMNT)[PRE_NBCOL + 6]);
double              d_somme_Alloc3SINEX=0;
double              d_taux_Alloc3=0;

T_traite            *Kbd_traite = NULL;
T_traite            *Kbd_lib = NULL;
T_SUBTRSESBPROP     pbd_SubTrsesBrop;
T_ACCPAR            pbd_TACCPAR;                     // table Taccpar pour les autre DETTERNCOD
int                 Kn_NbLigTACCPARFile = 0;

T_LIFDRI_ALL   *Kpbd_CPPILOT=NULL;	        // Tableau des complement PILOT
int             Kn_NbLigCPPilot=0;          // nombre de complement PILOT

/*------------------*/
/*    Prototypes    */
/*------------------*/
int n_InitPERISEG(T_RUPTURE_VAR *pbd_RuptPERISEG);
int n_IsRPERISEG(char **ptd_RuptPERISEG, char **ptd_RuptPERISEG_Cur);
int n_ActionLastRuptPERISEG(char **pbd_RuptPERISEG);
int n_ActionLignePERISEG(char **pbd_RuptPERISEG);

int n_InitSyncPERICASE(T_RUPTURE_SYNC_VAR *pbd_SyncPERICASE);
int n_ConditionSyncPERICASE(char **ptd_SyncLIFEST, char **ptd_SyncPERICASE);
int n_ActionLignePERICASE(char **ptd_SyncLIFEST, char **ptd_SyncPERICASE);

int n_InitSyncLIFEST(T_RUPTURE_SYNC_VAR *pbd_SyncLIFEST);
int n_ConditionSyncLIFEST(char **ptd_RuptPERISEG, char **ptd_SyncLIFEST);
int n_ConditionRuptLIFEST(char **ptd_SyncLIFEST, char **ptd_SyncLIFEST_Cur);
int n_ActionLigneLIFEST(char **ptd_RuptPERISEG, char **ptd_SyncLIFEST);
int n_ActionLastSyncLIFEST(char **ptd_RuptPERISEG, char **ptd_SyncLIFEST);

void Cas_A_PA_NULL(T_Poste *s_poste);
void Cas_B_SPT_sup_SPS(T_Poste *s_poste);
void Cas_C_part1_SPT_inf_or_equal_SPS(T_Poste * s_poste);
void Cas_C_part2_SPT_inf_or_equal_SPS();
void Cas_D_CC(T_Poste *s_poste);

int ecrire1480(T_Poste *s_poste);
int n_RechPoste(char *sz_poste, int N);

void effectuerLiberation();
int save1243ToLiberation();
int n_writePoste_PRE(T_Poste *poste);
int writeLog(T_Poste *pbd_Segment);
int n_writePoste();
int n_ajouterPoste(char **ptb_InRecCur);

int findRefTraite(char *ctrLIB);
int n_linkchain(T_traite **linklist);
void initT_Poste(T_Poste * poste);
void cleanElem(T_traite * Kbd_traite);
void cpyAllCol(T_Poste *dest, char **ref);
void goFirstElem(T_traite **linklist);
void goLastElem(T_traite **linklist);
void RecupAcadmtyp(T_traite **linklist);
int errorMsg(char *error);  /* Fonction d'appel en cas d'erreur */

int n_ChargerPilot();
int n_EcrireCPLLIFDRI();
int n_RechPilot (char *sz_ctr, char *sz_sec, char *sz_acy);
int ksz_indexPilot = 0;
int n_AddCPLIFDRI(T_LIFDRI_ALL *pbd_new) ;
int n_EcrireCPLLIFDRI();

/*==============================================================================
objet   :   Point d'entree du programme
retour  :   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc, char *argv[])
{
    /* Initialisation des signaux */
    InitSig();

    if (n_BeginPgm(argc, argv) == ERR)                                          ExitPgm(ERR_XX, "");

    // Recuperation des parametres
    sprintf(Ksz_Cre_D, "%s %s", psz_GetCharArgv(1), HEURE_TRAITEMENT);
    strcpy(Ksz_year_D, psz_GetCharArgv(2));
    strcpy(Ksz_mth_D,  psz_GetCharArgv(3));
    
    
    if (n_OpenFileAppl("ESTC3713_O1", "wt", &Kp_OutputFil_LIFEST) == ERR)       ExitPgm(ERR_XX, "");
    if (n_OpenFileAppl("ESTC3713_O2", "wt", &Kp_OutputFil_LOG)    == ERR)       ExitPgm(ERR_XX, "");
    if (n_OpenFileAppl("ESTC3713_O3", "wt", &Kp_PilotOFil)        == ERR)       ExitPgm(ERR_XX, "");
    if (n_OpenFileAppl("ESTC3713_I4", "rb", &Kp_InputFil_CURCOT)  == ERR)       ExitPgm(ERR_XX, "");
    if (n_OpenFileAppl("ESTC3713_I5", "rb", &Kp_TACCPAR)          == ERR)       ExitPgm(ERR_XX, "");
    if (n_OpenFileAppl("ESTC3713_I6", "rb", &Kp_SubTrsesBrop)     == ERR)       ExitPgm(ERR_XX, "");
    if (n_OpenFileAppl("ESTC3713_I7", "rb", &Kp_PilotIFil)        == ERR)       ExitPgm(ERR_XX, "");

	n_ChargerPilot5000(Kp_PilotIFil) ;                                                 // RechPilot5000

    if (n_InitPERISEG(&pbd_RuptPERISEG)         == ERR)                         ExitPgm(ERR_XX, "");
    if (n_InitSyncLIFEST(&pbd_SyncLIFEST)       == ERR)                         ExitPgm(ERR_XX, "");

    if (n_InitSyncPERICASE(&pbd_SyncPERICASE)   == ERR)                         ExitPgm(ERR_XX, "");

    if (n_ChargerTsubTAACCPAR(Kp_TACCPAR)       == ERR)                         ExitPgm(ERR_XX, "");
    if (n_ChargerSUBTRSESBPROP(Kp_SubTrsesBrop) == ERR)                         ExitPgm(ERR_XX, "");
    if (n_linkchain(&Kbd_traite)                == ERR)                         ExitPgm(ERR_XX, "");

    /* Lancement du traitement */
    if (n_ProcessingRuptureVar(&pbd_RuptPERISEG) == ERR)                        ExitPgm(ERR_XX, "");

    // Ecriture de LIFDRI + le complement en binaire
    n_EcrireCPLLIFDRI();
    
    /* Fermeture de tout les fichiers ouverts */
    if (n_CloseFileAppl("ESTC3713_I1", &pbd_RuptPERISEG.pf_InputFil)    == ERR) ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC3713_I2", &pbd_SyncLIFEST.pf_InputFil)     == ERR) ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC3713_I3", &pbd_SyncPERICASE.pf_InputFil)   == ERR) ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC3713_I4", &Kp_InputFil_CURCOT)             == ERR) ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC3713_I5", &Kp_TACCPAR)                     == ERR) ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC3713_I6", &Kp_SubTrsesBrop)                == ERR) ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC3713_I7", &Kp_PilotIFil)                   == ERR) ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC3713_O1", &Kp_OutputFil_LIFEST)            == ERR) ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC3713_O2", &Kp_OutputFil_LOG)               == ERR) ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC3713_O3", &Kp_PilotOFil)                   == ERR) ExitPgm(ERR_XX, "");

    if (n_EndPgm() == ERR)                                                      ExitPgm(ERR_XX, "");

    exit(OK);
}



/*==============================================================================
objet :     Initialisation de la structure de rupture du PERISEG
retour:     0 ----> OK
            ERR --> Error
==============================================================================*/
int n_InitPERISEG(T_RUPTURE_VAR *pbd_RuptPERISEG)
{
    DEBUT_FCT("n_InitPERISEG");
    memset(pbd_RuptPERISEG, 0, sizeof(T_RUPTURE_VAR));

    // Ouverture du fichier PERISEG
    if (n_OpenFileAppl("ESTC3713_I2", "rt", &(pbd_RuptPERISEG->pf_InputFil)) == ERR)
        RETURN_VAL(errorMsg("PERISEG openning failed. Error in ESTC3713.\n"));

    pbd_RuptPERISEG->n_NbRupture                 = 1;
    pbd_RuptPERISEG->n_ConditionRupture[0]       = n_IsRPERISEG;
    pbd_RuptPERISEG->n_ActionLast[0]             = n_ActionLastRuptPERISEG;

    pbd_RuptPERISEG->n_ActionLigne               = n_ActionLignePERISEG;

    pbd_RuptPERISEG->c_Separ                     = SEPARATEUR;

    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   Test rupture PERISEG
retour  :   0 ---> traitement correctement effectue
==============================================================================*/
int n_IsRPERISEG(char **ptd_RuptPERISEG, char **ptd_RuptPERISEG_Cur)
{
    int     ret = 0;
    DEBUT_FCT("n_IsRPERISEG");

    if ((ret = strcmp(ptd_RuptPERISEG[PERISEG_SSD_CF], ptd_RuptPERISEG_Cur[PERISEG_SSD_CF])) != 0) RETURN_VAL(ret);
    if ((ret = strcmp(ptd_RuptPERISEG[PERISEG_SEG_NF], ptd_RuptPERISEG_Cur[PERISEG_SEG_NF])) != 0) RETURN_VAL(ret);
    if ((ret = strcmp(ptd_RuptPERISEG[PERISEG_VRS_NF], ptd_RuptPERISEG_Cur[PERISEG_VRS_NF])) != 0) RETURN_VAL(ret);
    if ((ret = strcmp(ptd_RuptPERISEG[PERISEG_UWY_NF], ptd_RuptPERISEG_Cur[PERISEG_UWY_NF])) != 0) RETURN_VAL(ret);

    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   Fonction lancee à la derniere rupture du PERISEG
retour  :   0 ---> traitement correctement effectue
==============================================================================*/
int n_ActionLastRuptPERISEG(char **pbd_RuptPERISEG)
{
    T_traite *tmp;
    DEBUT_FCT("n_ActionLastRuptPERISEG");

    if (Kbd_lib == NULL)
        RETURN_VAL(OK);

    goFirstElem(&Kbd_lib);
    tmp = Kbd_lib;
    while (Kbd_lib->next != NULL)
    {
        tmp = Kbd_lib->next;
        cleanElem(Kbd_lib);
        Kbd_lib = tmp;
    }
    Kbd_lib = NULL;

    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   Fonction lancee à chaque ligne PERISEG
retour  :   0 ---> traitement correctement effectue
==============================================================================*/
int n_ActionLignePERISEG(char **pbd_RuptPERISEG)
{
    DEBUT_FCT("n_ActionLignePERISEG");

    if (n_ProcessingRuptureSyncVar(&pbd_SyncLIFEST, pbd_RuptPERISEG) == ERR)
        RETURN_VAL(errorMsg("Pn_ProcessingRuptureSyncVar LIFEST - PERISEG failed. Error in ESTC3713.\n"));

    RETURN_VAL(OK);
}


/*==============================================================================
objet :     Initialisation de la structure de rupture du PERICASE
retour:     0 ----> OK
            ERR --> Error
==============================================================================*/
int n_InitSyncPERICASE(T_RUPTURE_SYNC_VAR *pbd_SyncPERICASE)
{
    DEBUT_FCT("n_InitSyncLIFEST");
    memset(pbd_SyncPERICASE, 0, sizeof(T_RUPTURE_SYNC_VAR));

    // Ouverture du fichier Peri
    if (n_OpenFileAppl("ESTC3713_I3", "rt", &(pbd_SyncPERICASE->pf_InputFil)) == ERR)
        RETURN_VAL(errorMsg("PERICASE openning failed. Error in ESTC3713.\n"));

    pbd_SyncPERICASE->n_NbRupture                 = 0;

    pbd_SyncPERICASE->ConditionEndSync            = n_ConditionSyncPERICASE;
    pbd_SyncPERICASE->n_ActionLigne               = n_ActionLignePERICASE;

    pbd_SyncPERICASE->c_Separ                     = SEPARATEUR;

    RETURN_VAL(OK);
}


/*==============================================================================
objet :     Condition de syncronisation entre LIFEST et PERICASE
==============================================================================*/
int n_ConditionSyncPERICASE(char **ptd_SyncLIFEST, char **ptd_SyncPERICASE)
{
    int ret = 0;
    DEBUT_FCT("n_ConditionSyncPERICASE");

    if ((ret = strcmp(ptd_SyncLIFEST[PRE_CTR_NF], ptd_SyncPERICASE[PER_CTR_NF])) != 0) RETURN_VAL (ret);
    if ((ret = strcmp(ptd_SyncLIFEST[PRE_SEC_NF], ptd_SyncPERICASE[PER_SEC_NF])) != 0) RETURN_VAL (ret);
    if ((ret = strcmp(ptd_SyncLIFEST[PRE_UWY_NF], ptd_SyncPERICASE[PER_UWY_NF])) != 0) RETURN_VAL (ret);

    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   Fonction lancee à chaque ligne PERICASE
retour  :   0 ---> traitement correctement effectue
==============================================================================*/
int n_ActionLignePERICASE(char **ptd_SyncLIFEST, char **ptd_SyncPERICASE)
{
    char    tmpBuffer[30] = {0};
    double  d_taux;
    double  d_montant;
    DEBUT_FCT("n_ActionLignePERICASE");

    if ((d_taux = d_GetTaux(Kp_InputFil_CURCOT,
                            (char)atoi(ptd_SyncLIFEST[PRE_SSD_CF]),
                            (short)atoi(ptd_SyncLIFEST[PRE_BALSHEY_NF]),
                            ptd_SyncLIFEST[PRE_CUR_CF], ptd_SyncPERICASE[PER_PCPCUR_CF])) != -1)
    {
        d_montant = atof(ptd_SyncLIFEST[PRE_ESTMNT_M]) * d_taux;
        sprintf(tmpBuffer, "%.3lf", d_montant);
        ptd_SyncLIFEST[PRE_ESTMNT_M]    = strdup(tmpBuffer);
        ptd_SyncLIFEST[PRE_CUR_CF]      = ptd_SyncPERICASE[PER_PCPCUR_CF];
    }
    else
        RETURN_VAL(errorMsg("Pas de taux associer a la devise demandee\n"));
    acadmtyp = strdup(ptd_SyncPERICASE[PER_ACCADMTYP_CT]);
    RETURN_VAL(OK);
}

/*==============================================================================
objet :     Initialisation de la structure de rupture du LIFEST
retour:     0 ----> OK
            ERR --> Error
==============================================================================*/
int n_InitSyncLIFEST(T_RUPTURE_SYNC_VAR *pbd_SyncLIFEST)
{
    DEBUT_FCT("n_InitSyncLIFEST");
    memset(pbd_SyncLIFEST, 0, sizeof(T_RUPTURE_SYNC_VAR));

    // Ouverture du fichier Peri
    if (n_OpenFileAppl("ESTC3713_I1", "rt", &(pbd_SyncLIFEST->pf_InputFil)) == ERR)
        RETURN_VAL(errorMsg("LIFEST openning failed. Error in ESTC3713.\n"));

    pbd_SyncLIFEST->n_NbRupture                 = 1;
    pbd_SyncLIFEST->n_ConditionRupture[0]       = n_ConditionRuptLIFEST;
    pbd_SyncLIFEST->n_ActionLast[0]             = n_ActionLastSyncLIFEST;

    pbd_SyncLIFEST->ConditionEndSync            = n_ConditionSyncLIFEST;
    pbd_SyncLIFEST->n_ActionLigne               = n_ActionLigneLIFEST;

    pbd_SyncLIFEST->c_Separ                     = SEPARATEUR;

    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   fonction de test de synchronisation
retour  :   0   ---> pbd_RuptLIFEST = ptd_RuptPERISEG (égalité de rubrique à synchroniser)
            1   ---> Pas de syncronisation
==============================================================================*/
int n_ConditionSyncLIFEST(char **ptd_RuptPERISEG, char **ptd_SyncLIFEST)
{
    int     ret = 0;
    DEBUT_FCT("n_ConditionSyncLIFEST");

    if ((ret = strcmp(ptd_RuptPERISEG[PERISEG_SEG_NF], ptd_SyncLIFEST[PRE_NBCOL + PRE_SEG_NF])) != 0)   RETURN_VAL(ret);
    if ((ret = strcmp(ptd_RuptPERISEG[PERISEG_SSD_CF], ptd_SyncLIFEST[PRE_SSD_CF])) != 0)               RETURN_VAL(ret);
    if ((ret = strcmp(ptd_RuptPERISEG[PERISEG_UWY_NF], ptd_SyncLIFEST[PRE_UWY_NF])) != 0)               RETURN_VAL(ret);
    if ((ret = strcmp(ptd_RuptPERISEG[PERISEG_ACY_NF], ptd_SyncLIFEST[PRE_ACY_NF])) != 0)               RETURN_VAL(ret);

    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   fonction de test de synchronisation
retour  :   0   ---> pbd_RuptLIFEST = ptd_SyncLIFEST_Cur (égalité de rubrique à synchroniser)
            1   ---> Pas de syncronisation
==============================================================================*/
int n_ConditionRuptLIFEST(char **ptd_SyncLIFEST, char **ptd_SyncLIFEST_Cur)
{
    int     ret = 0;
    DEBUT_FCT("n_ConditionSyncLIFEST");

    if ((ret = strcmp(ptd_SyncLIFEST[PRE_NBCOL + PRE_SEG_NF], ptd_SyncLIFEST_Cur[PRE_NBCOL + PRE_SEG_NF])) != 0)    RETURN_VAL(ret);
    if ((ret = strcmp(ptd_SyncLIFEST[PRE_SSD_CF], ptd_SyncLIFEST_Cur[PRE_SSD_CF])) != 0)                            RETURN_VAL(ret);
    if ((ret = strcmp(ptd_SyncLIFEST[PRE_UWY_NF], ptd_SyncLIFEST_Cur[PRE_UWY_NF])) != 0)                            RETURN_VAL(ret);
    if ((ret = strcmp(ptd_SyncLIFEST[PRE_ACY_NF], ptd_SyncLIFEST_Cur[PRE_ACY_NF])) != 0)                            RETURN_VAL(ret);

    RETURN_VAL(OK);
}

/*==============================================================================
objet   :   Fonction lancee à chaque ligne LIFEST
retour  :   0 ---> traitement correctement effectue
==============================================================================*/
int n_ActionLigneLIFEST(char **ptd_RuptPERISEG, char **ptd_SyncLIFEST)
{
    int     i = 0;
    DEBUT_FCT("n_ActionLigneLIFEST");
    
    // Réinitialisation données rupture précédente
    d_somme_Alloc3SINEX = 0;
    d_taux_Alloc3 = 0;
    
    if (ptd_SyncLIFEST[PRE_GAAP_NF][0] != '1')
        RETURN_VAL(OK);


    if (Kn_nbPoste > -1 )
    {
        if (strcmp(ptd_SyncLIFEST[PRE_CTR_NF], Kbd_traite->postes[Kn_nbPoste].line[PRE_CTR_NF]) != 0)
        {
            if (n_linkchain(&Kbd_traite) == ERR)
                RETURN_VAL(ERR);
        }
    }

    Kn_nbPoste = -1;
    for (i = 0; ksz_ACMTRS[i] != NULL; ++i)
    {
        if (strcmp(ptd_SyncLIFEST[PRE_ACMTRS_NT], ksz_ACMTRS[i]) == 0)
        {
            Kn_nbPoste = i;
            break;
        }
    }
    if (Kn_nbPoste == -1)
        RETURN_VAL(errorMsg("ACMTRS != 1243 / 1244 / 1220 / 1510 in LIFEST. Error in ESTC3713.\n"));

    // Renseignement des valeurs de la ligne prévision dans Poste.line
    // Si on passe ici, au moins un des autres postes de la structure est renseigné
    cpyAllCol(&(Kbd_traite->postes[poste_SEG]), ptd_SyncLIFEST);    // [03]
    Kbd_traite->postes[poste_SEG].LOSSR            = atof(ptd_RuptPERISEG[PERISEG_LOSS_R]) * 100;     //[01]
    Kbd_traite->postes[poste_SEG].sum_1510_all     = atof(ptd_RuptPERISEG[PERISEG_MONTANT_M]);
    Kbd_traite->postes[poste_SEG].COMACC_B         = ptd_SyncLIFEST[PRE_NBCOL + PRE_COMACC_B][0];

    Kbd_traite->postes[poste_SEG].VRS_NF           = strdup(ptd_RuptPERISEG[PERISEG_VRS_NF]);
    Kbd_traite->postes[poste_SEG].SEG_NF           = strdup(ptd_RuptPERISEG[PERISEG_SEG_NF]);
    Kbd_traite->postes[poste_SEG].SEGTYP_CT        = strdup(ptd_SyncLIFEST[PRE_NBCOL + PRE_SEGTYP_CT]);

    n_ajouterPoste(ptd_SyncLIFEST);
    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   Remplit la structure contenant les postes
retour  :   Ok
==============================================================================*/
int n_ajouterPoste(char **ptb_InRecCur)
{
    DEBUT_FCT("n_ajouterPoste");

    // [03] On effectue les initialisations avant les premières vérifications.

    ptb_InRecCur[PRE_NBCOL + PRE_SEGTYP_CT + 1] = NULL;
    cpyAllCol(&(Kbd_traite->postes[Kn_nbPoste]), ptb_InRecCur);


    // On ajoute les informations supplementaires
    Kbd_traite->postes[Kn_nbPoste].COMACC_B  = ptb_InRecCur[PRE_NBCOL + PRE_COMACC_B][0];
    Kbd_traite->postes[Kn_nbPoste].VRS_NF    = strdup(ptb_InRecCur[PRE_NBCOL + PRE_VRS_NF   ]);
    Kbd_traite->postes[Kn_nbPoste].SEG_NF    = strdup(ptb_InRecCur[PRE_NBCOL + PRE_SEG_NF   ]);
    Kbd_traite->postes[Kn_nbPoste].SEGTYP_CT = strdup(ptb_InRecCur[PRE_NBCOL + PRE_SEGTYP_CT]);
    Kbd_traite->postes[Kn_nbPoste].MONTANT_M = atoi(ptb_InRecCur[PRE_ESTMNT_M]);

    if (Kn_nbPoste == poste_1510)
        if (strcmp(ptb_InRecCur[PRE_DETTRNCOD_CF], "XXXXX") != 0)
        {
            ptb_InRecCur[PRE_NBCOL] = NULL;
            n_WriteCols(Kp_OutputFil_LIFEST, ptb_InRecCur, SEPARATEUR, 0);
            RETURN_VAL(OK);
        }

    if (Kn_nbPoste == poste_1243 || Kn_nbPoste == poste_1244)
    {
        memset(&pbd_TACCPAR, 0, sizeof(pbd_TACCPAR));
        if (n_FindTsubTAACPAR(&pbd_TACCPAR, (short)atoi(ksz_ACMTRS[Kn_nbPoste])) != -1)
        {
            if (strcmp(ptb_InRecCur[PRE_DETTRNCOD_CF], pbd_TACCPAR.DETTRNCOD_CF) != 0)
            {
                ptb_InRecCur[PRE_NBCOL] = NULL;
                ptb_InRecCur[PRE_ESTMNT_M] = MONTANT_ZERO;
                n_WriteCols(Kp_OutputFil_LIFEST, ptb_InRecCur, SEPARATEUR, 0);
                RETURN_VAL(OK);
            }
        }
        else
        {
            RETURN_VAL(ERR);
        }
    }

    RETURN_VAL(OK);
}

/*=============================================================================
objet: Recuperer l'information du type comptable du contrat afin que ça soit utilise 
       pour attribué une bonne valeur à l'uwy lorsque les libérations sont produites
[06] 
=============================================================================*/
void RecupAcadmtyp(T_traite **linklist)
{
    T_traite *currentTraite;
    int i = 0;
    goFirstElem(&Kbd_traite);                                           
    currentTraite = Kbd_traite;     
    while (currentTraite != NULL)           
    {
        i = 0;
            while (i < nb_poste)
            {
                if (*(currentTraite->postes[i].line) != NULL)
                {
                    if (n_ProcessingRuptureSyncVar(&pbd_SyncPERICASE, currentTraite->postes[i].line) == ERR)
                        errorMsg("n_ProcessingRuptureSyncVar PERICASE - LIFEST failed. Error in ESTC3713.\n");
    
                     currentTraite->postes[i].line[PRE_NBCOL] = acadmtyp;
                 } 
                 i++; 
            }
        currentTraite = currentTraite->next;
    }
}

/*==============================================================================
objet   :   Fonction lancee à la derniere rupture LIFEST
retour  :   0 ---> traitement correctement effectue
==============================================================================*/
int n_ActionLastSyncLIFEST(char **ptd_RuptPERISEG, char **ptd_SyncLIFEST)
{
    double  SPcontrat_R;
    T_traite *currentTraite;
    T_traite *tmp;
    
    DEBUT_FCT("n_ActionLastSyncLIFEST");

    RecupAcadmtyp(&Kbd_traite);  //[06] 

    //effectuerLiberation();
    goFirstElem(&Kbd_traite);
    currentTraite = Kbd_traite;
    while (currentTraite != NULL)
    {
        /*les différents cas*/

        if (currentTraite->postes[poste_1510].MONTANT_M == 0)    //PA est null
        {
            Cas_A_PA_NULL(currentTraite->postes);
        }
        else
        {
            /*comptaSINEX-s/p-*/
            if (currentTraite->postes[poste_SEG].COMACC_B == 'Y')
            {
                SPcontrat_R = (currentTraite->postes[poste_1244].MONTANT_M  +
                           currentTraite->postes[poste_1243].MONTANT_M  +
                           currentTraite->postes[poste_1220].MONTANT_M) /
                          currentTraite->postes[poste_1510].MONTANT_M;
            }
            else 
            {
                SPcontrat_R = (currentTraite->postes[poste_1244].MONTANT_M  +
                           currentTraite->postes[poste_1220].MONTANT_M) /
                           currentTraite->postes[poste_1510].MONTANT_M;
            }

            //if (SPcontrat_R > currentTraite->postes[poste_SEG].LOSSR)            
            if ( (SPcontrat_R > currentTraite->postes[poste_SEG].LOSSR && currentTraite->postes[poste_SEG].LOSSR <= 0 ) || (SPcontrat_R < 0 && currentTraite->postes[poste_SEG].LOSSR > 0 ) )
            {
                Cas_B_SPT_sup_SPS(currentTraite->postes);
            }
            else if (SPcontrat_R <= currentTraite->postes[poste_SEG].LOSSR)
            {
                Cas_C_part1_SPT_inf_or_equal_SPS(currentTraite->postes);
            }
            else if (currentTraite->postes[poste_SEG].COMACC_B == 'Y')
            {
                Cas_D_CC(currentTraite->postes);
            }
        }
        currentTraite = currentTraite->next;
    }
    d_taux_Alloc3 = Kbd_traite->postes[poste_SEG].sum_1510_all / d_somme_Alloc3SINEX;
    
    Cas_C_part2_SPT_inf_or_equal_SPS();

    //calcul des provisions de cloture dans le poste 1243
    currentTraite = Kbd_traite;
    while (currentTraite != NULL)
    {
        if (currentTraite->postes[poste_SEG].Cas == 'A' || currentTraite->postes[poste_SEG].Cas == 'B')
        {
            currentTraite->postes[poste_1243].MONTANT_M = currentTraite->postes[poste_1220].MONTANT_M;
        }
        currentTraite = currentTraite->next;
    }

    save1243ToLiberation();
    effectuerLiberation();
    n_writePoste();

    if (Kbd_traite != NULL)
    {
        while (Kbd_traite->next != NULL)
        {
            tmp = Kbd_traite->next;
            cleanElem(Kbd_traite);
            Kbd_traite = tmp;
        }
        if (Kbd_traite != NULL)
            cleanElem(Kbd_traite);
        Kbd_traite = NULL;
        n_linkchain(&Kbd_traite);
    }
    Kn_nbPoste = -1;
    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   PA est null
retour  :   Ok
==============================================================================*/
void Cas_A_PA_NULL(T_Poste *s_poste)
{
    DEBUT_FCT("Cas_A_PA_NULL");

    s_poste[poste_SEG].ComptaSinex  = (s_poste[poste_SEG].COMACC_B == 'Y') ? s_poste[poste_1244].MONTANT_M + s_poste[poste_1243].MONTANT_M + s_poste[poste_1220].MONTANT_M :
                                      s_poste[poste_1244].MONTANT_M + s_poste[poste_1220].MONTANT_M;
    s_poste[poste_SEG].Alloc1SINEX  = 0;
    s_poste[poste_SEG].Alloc2SINEX  = s_poste[poste_1244].MONTANT_M + s_poste[poste_1220].MONTANT_M;
    s_poste[poste_SEG].Alloc3SINEX  = 0;
    s_poste[poste_SEG].Alloc3STAsre = 0;
    s_poste[poste_SEG].sinistralite = 0;
    s_poste[poste_SEG].MONTANT_M    = s_poste[poste_1244].MONTANT_M + s_poste[poste_1220].MONTANT_M;
    s_poste[poste_SEG].Sp           = 0;
    s_poste[poste_SEG].Cas          = 'A';
}


/*==============================================================================
objet   :   S/P traité supérieur à S/P segement
retour  :   Ok
==============================================================================*/
void Cas_B_SPT_sup_SPS(T_Poste *s_poste)
{
    DEBUT_FCT("Cas_B_SPT_sup_SPS");

    s_poste[poste_SEG].ComptaSinex  = (s_poste[poste_SEG].COMACC_B == 'Y') ? s_poste[poste_1244].MONTANT_M + s_poste[poste_1243].MONTANT_M + s_poste[poste_1220].MONTANT_M :
                                      s_poste[poste_1244].MONTANT_M + s_poste[poste_1220].MONTANT_M;
    s_poste[poste_SEG].Alloc1SINEX  = s_poste[poste_1244].MONTANT_M + s_poste[poste_1220].MONTANT_M;
    s_poste[poste_SEG].Alloc2SINEX  = 0;
    s_poste[poste_SEG].Alloc3SINEX  = 0;
    s_poste[poste_SEG].Alloc3STAsre = 0;
    s_poste[poste_SEG].sinistralite = 0;
    s_poste[poste_SEG].MONTANT_M    = s_poste[poste_1244].MONTANT_M + s_poste[poste_1220].MONTANT_M;
    s_poste[poste_SEG].Sp           = s_poste[poste_SEG].MONTANT_M / s_poste[poste_1510].MONTANT_M;
    s_poste[poste_SEG].Cas          = 'B';
}


/*==============================================================================
objet   :   S/P traité inférieur ou égal à S/P segement
retour  :   Ok
==============================================================================*/
void Cas_C_part1_SPT_inf_or_equal_SPS(T_Poste * s_poste)
{
    double taux;
    DEBUT_FCT("Cas_C_part1_SPT_inf_or_equal_SPS");

    taux = s_poste[poste_SEG].LOSSR;
    s_poste[poste_SEG].ComptaSinex     = (s_poste[poste_SEG].COMACC_B == 'Y') ? s_poste[poste_1244].MONTANT_M + s_poste[poste_1243].MONTANT_M + s_poste[poste_1220].MONTANT_M :
                                         s_poste[poste_1244].MONTANT_M + s_poste[poste_1220].MONTANT_M;
    s_poste[poste_SEG].Alloc1SINEX     = 0;
    s_poste[poste_SEG].Alloc2SINEX     = s_poste[poste_1244].MONTANT_M + s_poste[poste_1220].MONTANT_M;

    if (taux == 0.0)
    {
        s_poste[poste_SEG].Alloc3SINEX = s_poste[poste_1510].MONTANT_M;
    }
    else
    {
        s_poste[poste_SEG].Alloc3SINEX = s_poste[poste_1510].MONTANT_M - s_poste[poste_SEG].ComptaSinex * (taux * 100);
    }

    //s_poste[poste_SEG].Alloc3STAsre    = s_poste[poste_1510].MONTANT_M - s_poste[poste_SEG].Alloc2SINEX;
    s_poste[poste_SEG].Cas             = 'C';
    d_somme_Alloc3SINEX = d_somme_Alloc3SINEX + s_poste[poste_SEG].Alloc3SINEX;

}


/*==============================================================================
objet   :   S/P traité inférieur ou égal à S/P segement
retour  :   Ok
==============================================================================*/
void Cas_C_part2_SPT_inf_or_equal_SPS()
{
    double  sum_alloc_1_2_all   = 0.0, // Somme des sinistralites exterieures
            sum_alloc_3c        = 0.0; // Somme des Primes Acquises pour la sinistralite attendue
    T_traite *currentTraite;
    DEBUT_FCT("Cas_C_part2_SPT_inf_or_equal_SPS");

    currentTraite = Kbd_traite;
    while (currentTraite != NULL)
    {
            if (currentTraite->postes[poste_SEG].Cas == 'C')
            {
                currentTraite->postes[poste_SEG].Alloc3STAsre = currentTraite->postes[poste_SEG].Alloc3SINEX * d_taux_Alloc3;
            }
            currentTraite = currentTraite->next;
    }
    
    currentTraite = Kbd_traite;
    while (currentTraite != NULL)
    {

        sum_alloc_1_2_all    += currentTraite->postes[poste_SEG].Alloc1SINEX + currentTraite->postes[poste_SEG].Alloc2SINEX;
        if (currentTraite->postes[poste_SEG].Cas == 'C')
        {
            sum_alloc_3c     += currentTraite->postes[poste_SEG].Alloc3STAsre;
        }
        
        currentTraite = currentTraite->next;
    }
    sum_alloc_3c -=  sum_alloc_1_2_all;
        
    currentTraite = Kbd_traite;
    while (currentTraite != NULL)
    {
        if (currentTraite->postes[poste_SEG].Cas == 'C')
        {
            if (sum_alloc_3c != 0.0)
                //currentTraite->postes[poste_SEG].sinistralite  = (currentTraite->postes[poste_SEG].sum_1510_all - sum_alloc_1_2_all) / sum_alloc_3c;
                currentTraite->postes[poste_SEG].sinistralite  = currentTraite->postes[poste_SEG].Alloc1SINEX + currentTraite->postes[poste_SEG].Alloc2SINEX +currentTraite->postes[poste_SEG].Alloc3STAsre;
            else
                currentTraite->postes[poste_SEG].sinistralite = 0.0;

            currentTraite->postes[poste_SEG].MONTANT_M     = currentTraite->postes[poste_SEG].Alloc1SINEX + currentTraite->postes[poste_SEG].Alloc2SINEX + currentTraite->postes[poste_SEG].sinistralite;
            //currentTraite->postes[poste_SEG].Sp            = currentTraite->postes[poste_SEG].MONTANT_M / currentTraite->postes[poste_1510].MONTANT_M;
            currentTraite->postes[poste_SEG].Sp            = currentTraite->postes[poste_SEG].Alloc3STAsre / currentTraite->postes[poste_1510].MONTANT_M;
            currentTraite->postes[poste_1243].MONTANT_M    = currentTraite->postes[poste_SEG].MONTANT_M - currentTraite->postes[poste_1244].MONTANT_M;
        }
        currentTraite = currentTraite->next;
    }
}


/*==============================================================================
objet   :   Comptes complets
retour  :   Ok
==============================================================================*/
void Cas_D_CC(T_Poste *s_poste)
{
    DEBUT_FCT("Cas_D_CC");

    s_poste[poste_SEG].ComptaSinex = s_poste[poste_1244].MONTANT_M + s_poste[poste_1243].MONTANT_M + s_poste[poste_1220].MONTANT_M;
    s_poste[poste_SEG].Alloc1SINEX  = 0;
    s_poste[poste_SEG].Alloc2SINEX  = s_poste[poste_1243].MONTANT_M + s_poste[poste_1244].MONTANT_M + s_poste[poste_1220].MONTANT_M;
    s_poste[poste_SEG].Alloc3SINEX  = 0;
    s_poste[poste_SEG].Alloc3STAsre = 0;
    s_poste[poste_SEG].sinistralite = 0;
    s_poste[poste_SEG].MONTANT_M    = s_poste[poste_1243].MONTANT_M + s_poste[poste_1244].MONTANT_M + s_poste[poste_1220].MONTANT_M;
    s_poste[poste_SEG].Sp           = s_poste[poste_SEG].MONTANT_M / s_poste[poste_1510].MONTANT_M;
    s_poste[poste_SEG].Cas          = 'D';
}


/*==============================================================================
objet   :   Ecrit un poste dans le fichier LIFEST
retour  :   Ok
==============================================================================*/
int n_writePoste_PRE(T_Poste *poste)
{
    char    tmp[30] = {'\000'};
    char    gaap[2] = {'\000', '\000'};

    DEBUT_FCT("n_writePoste_PRE");

    if (poste->line[PRE_CTR_NF] == NULL)
        RETURN_VAL(OK);

    sprintf(tmp, "%.3lf", poste->MONTANT_M);
    poste->line[PRE_ESTMNT_M] = tmp;

    for (gaap[0] = '1'; gaap[0] <= '5'; ++(gaap[0]))
    {

        if (n_RechSUBTRSESBPROP(&pbd_SubTrsesBrop, poste->line[PRE_DETTRNCOD_CF], poste->line[PRE_SSD_CF], poste->line[PRE_ESB_CF]) != -1)
        {
            switch (gaap[0])
            {
            case '1':
                if (pbd_SubTrsesBrop.GAAP1TRS_CT == 3)
                    poste->line[PRE_ESTMNT_M] = MONTANT_ZERO;
                break;

            case '2':
                if (pbd_SubTrsesBrop.GAAP2TRS_CT == 3)
                    poste->line[PRE_ESTMNT_M] = MONTANT_ZERO;
                break;

            case '3':
                if (pbd_SubTrsesBrop.GAAP3TRS_CT == 3)
                    poste->line[PRE_ESTMNT_M] = MONTANT_ZERO;
                break;

            case '4':
                if (pbd_SubTrsesBrop.GAAP4TRS_CT == 3)
                    poste->line[PRE_ESTMNT_M] = MONTANT_ZERO;
                break;

            case '5':
                if (pbd_SubTrsesBrop.GAAP5TRS_CT == 3)
                    poste->line[PRE_ESTMNT_M] = MONTANT_ZERO;
                break;
            }
        }

        poste->line[PRE_GAAP_NF]        = gaap;
        poste->line[PRE_BATCH_B]        = BATCH_B;
        poste->line[PRE_CRE_D]          = Ksz_Cre_D;
        poste->line[PRE_LSTUPDUSR_CF]   = LSTUPDUSER_CF;
        poste->line[PRE_ORICOD_LS]      = ORICOD_LS;
        poste->line[PRE_NBCOL]          = NULL;

        n_WriteCols(Kp_OutputFil_LIFEST, poste->line, SEPARATEUR, 0);
    }
   

    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   Demande l'écriture de tous les postes
retour  :   Ok
==============================================================================*/
int n_writePoste()
{
    T_traite *currentTraite;
    T_LIFDRI_ALL bd_new;
    int Kn_SyncPilot = 0;
    int ksz_indexPilot = 0
    
    DEBUT_FCT("n_writePoste");

    goFirstElem(&Kbd_traite);
    currentTraite = Kbd_traite;

    while (currentTraite != NULL)
    {
        writeLog(currentTraite->postes);
      
        if (currentTraite->postes[poste_SEG].Cas == 'C')
        {
            n_writePoste_PRE(&(currentTraite->postes[poste_1243]));
            n_writePoste_PRE(&(currentTraite->postes[poste_1244]));

            ecrire1480(&(currentTraite->postes[poste_SEG]));             // [01]
        }
        
        // Ecriture CPLIFDRI CTR/SEC/UWY/ACY
        Kn_SyncPilot = n_RechPilot5000 ( currentTraite->postes[poste_SEG].line,PRE_CTR_NF ,PRE_SEC_NF, PRE_ACY_NF, &ksz_indexPilot);
        
        if (Kn_SyncPilot>=0)
        {
            bd_new=Kbd_PILOT[Kn_SyncPilot];
            if (bd_new.COMACC_B != 1)
            {
                bd_new.UPD_NF='I';
                strcpy(bd_new.CRE_D,Ksz_Cre_D);
                strcpy(bd_new.LSTUPD_D, Ksz_Cre_D);
                bd_new.SEGUPD_B = 1;
                n_AddCPLIFDRI(&bd_new);
            }
        }
        else  // Sinon, creation de toute piece de l'enregistrement
        {
            bd_new.UPD_NF='I';
            bd_new.SSD_CF=atoi(currentTraite->postes[poste_SEG].line[PRE_SSD_CF]);
            sprintf(bd_new.CTR_NF,"%.9s",currentTraite->postes[poste_SEG].line[PRE_CTR_NF]);
            bd_new.END_NT=atoi(currentTraite->postes[poste_SEG].line[PRE_END_NT]);
            bd_new.SEC_NF=atoi(currentTraite->postes[poste_SEG].line[PRE_SEC_NF]);
            bd_new.UWY_NF=atoi(currentTraite->postes[poste_SEG].line[PRE_UWY_NF]);
            bd_new.UW_NT=atoi(currentTraite->postes[poste_SEG].line[PRE_UW_NT]);
            bd_new.ACY_NF=atoi(currentTraite->postes[poste_SEG].line[PRE_ACY_NF]);
            bd_new.BALSHEY_NF=atoi(Ksz_year_D);
            bd_new.BALSHTMTH_NF=atoi(Ksz_mth_D);
            bd_new.AUTUPD_B=1;
            bd_new.COMACC_B=0;
            bd_new.SEGUPD_B = 1;
            bd_new.PROPAG_RES_B=0;
            strcpy(bd_new.CRE_D,Ksz_Cre_D);
            bd_new.CMT_NT=0;          
            strcpy(bd_new.CREUSR_CF, LSTUPDUSER_CF);
            strcpy(bd_new.LSTUPDUSR_CF, LSTUPDUSER_CF);
            strcpy(bd_new.LSTUPD_D, Ksz_Cre_D);
            n_AddCPLIFDRI(&bd_new);
        }
        // Fin création CPLIFDRI
        currentTraite = currentTraite->next;
    }

    RETURN_VAL(OK);
}

/*==============================================================================
objet   :   Ecrit une ligne dan le fichier de log
retour  :   OK --> permet l'arret du programme
==============================================================================*/
int writeLog(T_Poste *pbd_Segment)
{
    char        *pz_ligne[23] = {NULL};
    int         j = 0;
    char        tmp[30] = {0};
    DEBUT_FCT("writeLog");

    fprintf(Kp_OutputFil_LOG, "SSD_CF~CTR_NF~END_NT~SEC_NF~UWY_NF~ACY_NF~VRS_NF~PERISEG_NF~SEGTYP_CT~COMACC_B~ACMTRS~CUR_CF~Sinistralite~Alloc1SINEX~Alloc2SINEX~Alloc3STAsre~MONTANT_M~Sp~LOSSR~SinistreTotal~Cas\n");

    for (j = 0; j < nb_poste; ++j)
    {
        // On réecrit le format toute les 50 lignes
        if (poste_1220 <= j && j <= poste_1510)
        {
            pz_ligne[0]  = pbd_Segment[j].line[PRE_SSD_CF];
            pz_ligne[1]  = pbd_Segment[j].line[PRE_CTR_NF];
            pz_ligne[2]  = pbd_Segment[j].line[PRE_END_NT];
            pz_ligne[3]  = pbd_Segment[j].line[PRE_SEC_NF];
            pz_ligne[4]  = pbd_Segment[j].line[PRE_UWY_NF];
            pz_ligne[5]  = pbd_Segment[j].line[PRE_ACY_NF];
            pz_ligne[10] = pbd_Segment[j].line[PRE_ACMTRS_NT];
            pz_ligne[11] = pbd_Segment[j].line[PRE_CUR_CF];
        }
        else
        {
            pz_ligne[0]  = "";
            pz_ligne[1]  = "";
            pz_ligne[2]  = "";
            pz_ligne[3]  = "";
            pz_ligne[4]  = "";
            pz_ligne[5]  = "";
            pz_ligne[10] = "";
            pz_ligne[11] = "";
        }
        if (pbd_Segment[poste_SEG].VRS_NF != NULL)
            pz_ligne[6]  = pbd_Segment[poste_SEG].VRS_NF;
        else
            pz_ligne[6]  = "";

        if (pbd_Segment[poste_SEG].SEG_NF != NULL)
            pz_ligne[7]  = pbd_Segment[poste_SEG].SEG_NF;
        else
            pz_ligne[7]  = "";

        if (pbd_Segment[poste_SEG].SEGTYP_CT != NULL)
            pz_ligne[8]  = pbd_Segment[poste_SEG].SEGTYP_CT;
        else
            pz_ligne[8]  = "";

        tmp[0]  = pbd_Segment[j].COMACC_B;
        tmp[1] = '\000';
        pz_ligne[9] = strdup(tmp);
        tmp[0] = '\000';

        sprintf(tmp, "%.3lf", pbd_Segment[j].sinistralite);
        pz_ligne[12] = strdup(tmp);
        memset(tmp, 0, 30);

        sprintf(tmp, "%.3lf", pbd_Segment[j].Alloc1SINEX);
        pz_ligne[13] = strdup(tmp);
        memset(tmp, 0, 30);

        sprintf(tmp, "%.3lf", pbd_Segment[j].Alloc2SINEX);
        pz_ligne[14] = strdup(tmp);
        memset(tmp, 0, 30);

        sprintf(tmp, "%.3lf", pbd_Segment[j].Alloc3STAsre);
        pz_ligne[15] = strdup(tmp);
        memset(tmp, 0, 30);

        sprintf(tmp, "%.3lf", pbd_Segment[j].MONTANT_M);
        pz_ligne[16] = strdup(tmp);
        memset(tmp, 0, 30);

        sprintf(tmp, "%.3lf", pbd_Segment[j].Sp);
        pz_ligne[17] = strdup(tmp);
        memset(tmp, 0, 30);

        sprintf(tmp, "%.3lf", pbd_Segment[j].LOSSR);
        pz_ligne[18] = strdup(tmp);
        memset(tmp, 0, 30);

        sprintf(tmp, "%.3lf", pbd_Segment[j].sum_1510_all);
        pz_ligne[19] = strdup(tmp);
        memset(tmp, 0, 30);

        sprintf(tmp, "%c", pbd_Segment[j].Cas);
        pz_ligne[20] = strdup(tmp);
        memset(tmp, 0, 30);

        pz_ligne[21] = NULL;

        n_WriteCols(Kp_OutputFil_LOG, pz_ligne, SEPARATEUR, 0);
    }

    RETURN_VAL(OK);
}


int n_linkchain(T_traite **linklist)
{
    int i = 0;
    if ((*linklist) == NULL)
    {
        if (((*linklist) = malloc(sizeof(T_traite))) == NULL)
            RETURN_VAL(ERR);
        (*linklist)->prev = NULL;
        (*linklist)->next = NULL;
        (*linklist)->sentinel = 0;
    }
    else
    {
        if (((*linklist)->next = malloc(sizeof(T_traite))) == NULL)
            RETURN_VAL(ERR);
        (*linklist)->next->prev = (*linklist);
        (*linklist) = (*linklist)->next;
        (*linklist)->next = NULL;
        (*linklist)->sentinel = (*linklist)->prev->sentinel + 1;
    }

    for (i = 0; i < nb_poste; ++i)
    {
        initT_Poste(&((*linklist)->postes[i]));
    }

    RETURN_VAL(OK);
}


void initT_Poste(T_Poste *poste)
{
    int i;

    for (i = 0; i <= (PRE_NBCOL + PRE_SEGTYP_CT); ++i)
        poste->line[i] = NULL;

    poste->VRS_NF           = NULL;
    poste->SEG_NF           = NULL;
    poste->SEGTYP_CT        = NULL;
    poste->COMACC_B         = 0;
    poste->Cas              = 0;
    poste->sinistralite     = 0.0;
    poste->ComptaSinex      = 0.0;
    poste->Alloc1SINEX      = 0.0;
    poste->Alloc2SINEX      = 0.0;
    poste->Alloc3SINEX      = 0.0;
    poste->Alloc3STAsre     = 0.0;
    poste->MONTANT_M        = 0.0;
    poste->sum_1510_all     = 0.0;
    poste->Sp               = 0.0;
    poste->LOSSR            = 0.0;
}


void cleanElem(T_traite *traite)
{
    int i;

    if (traite != NULL)
    {
        for (i = 0; i < nb_poste; ++i)
        {
            if (traite->postes[i].VRS_NF != NULL)
            {
                free(traite->postes[i].VRS_NF);
                traite->postes[i].VRS_NF = NULL;
            }

            if (traite->postes[i].SEG_NF != NULL)
            {
                free(traite->postes[i].SEG_NF);
                traite->postes[i].SEG_NF = NULL;
            }

            if (traite->postes[i].SEGTYP_CT != NULL)
            {
                free(traite->postes[i].SEGTYP_CT);
                traite->postes[i].SEGTYP_CT = NULL;
            }
            if (traite->next != NULL)
            {
                //free(traite->next);
                traite->next = NULL;
            }
            if (traite->prev != NULL)
            {
                //free(traite->prev);
                traite->next = NULL;
            }
        }
        free(traite);
        traite = NULL;
    }
}


/*==============================================================================
objet   :   Assigne les montants 1243 annee precedante dans 1244 annee en cours
retour  :   Ok
==============================================================================*/
void effectuerLiberation()
{
    T_traite *tmp;
    T_traite *lib;
    DEBUT_FCT("effectuerLiberation");

    if (Kbd_lib == NULL)
        return;
    goFirstElem(&Kbd_lib);
    goFirstElem(&Kbd_traite);
    lib = Kbd_lib;
    while (lib != NULL)
    {
        findRefTraite(lib->postes[poste_1244].line[PRE_CTR_NF]);

        if (Kbd_traite->postes[poste_1244].line != NULL)
        {
            lib->postes[poste_1244].line[PRE_NBCOL + PRE_SEGTYP_CT + 1] = NULL;
            cpyAllCol(&(Kbd_traite->postes[poste_1244]), lib->postes[poste_1244].line);
            Kbd_traite->postes[poste_1244].line[PRE_ACMTRS_NT] = "1244";
            
            if (i_LiberationExeP1(1243, atoi(Kbd_traite->postes[poste_1244].line[PRE_NBCOL]))) //[06]
                snprintf(Kbd_traite->postes[poste_1244].line[PRE_UWY_NF], 5, "%d", (atoi(Kbd_traite->postes[poste_1244].line[PRE_UWY_NF]) + 1));
            
            snprintf(Kbd_traite->postes[poste_1244].line[PRE_ACY_NF], 5, "%d", (atoi(Kbd_traite->postes[poste_1244].line[PRE_ACY_NF]) + 1));
            
            if (n_FindTsubTAACPAR(&pbd_TACCPAR, (short)1244) != -1)
                Kbd_traite->postes[poste_1244].line[PRE_DETTRNCOD_CF] = pbd_TACCPAR.DETTRNCOD_CF;

            // On ajoute les informations supplementaires
            Kbd_traite->postes[poste_1244].COMACC_B  = lib->postes[poste_1244].COMACC_B;
            Kbd_traite->postes[poste_1244].VRS_NF    = strdup(lib->postes[poste_1244].line[PRE_NBCOL + PRE_VRS_NF   ]);
            Kbd_traite->postes[poste_1244].SEG_NF    = strdup(lib->postes[poste_1244].line[PRE_NBCOL + PRE_SEG_NF   ]);
            Kbd_traite->postes[poste_1244].SEGTYP_CT = strdup(lib->postes[poste_1244].line[PRE_NBCOL + PRE_SEGTYP_CT]);
        }
        Kbd_traite->postes[poste_1244].MONTANT_M = lib->postes[poste_1244].MONTANT_M;

        lib = lib->next;
    }

    if (Kbd_lib != NULL)
        while (Kbd_lib->next != NULL)
        {
            tmp = Kbd_lib->next;
            cleanElem(Kbd_lib);
            Kbd_lib = tmp;
        }
    Kbd_lib = NULL;

}


/*==============================================================================
objet   :   Stockage des 1243 de l'annee courante
retour  :   Ok
==============================================================================*/
int save1243ToLiberation()
{
    T_traite *tmp;
    DEBUT_FCT("save1243ToLiberation");

    goFirstElem(&Kbd_traite);
    tmp = Kbd_traite;
    while (tmp != NULL)
    {
        if (tmp->postes[poste_1243].line[PRE_CTR_NF] != NULL)
        {

            if (n_linkchain(&Kbd_lib) == ERR)
                RETURN_VAL(ERR);
            tmp->postes[poste_1243].line[PRE_NBCOL + PRE_SEGTYP_CT + 1] = NULL;
            cpyAllCol(&(Kbd_lib->postes[poste_1244]), tmp->postes[poste_1243].line);
            Kbd_lib->postes[poste_1244].COMACC_B  = tmp->postes[poste_1243].COMACC_B;

            Kbd_lib->postes[poste_1244].VRS_NF    = strdup(tmp->postes[poste_1243].line[PRE_NBCOL + PRE_VRS_NF   ]);
            Kbd_lib->postes[poste_1244].SEG_NF    = strdup(tmp->postes[poste_1243].line[PRE_NBCOL + PRE_SEG_NF   ]);
            Kbd_lib->postes[poste_1244].SEGTYP_CT = strdup(tmp->postes[poste_1243].line[PRE_NBCOL + PRE_SEGTYP_CT]);

            Kbd_lib->postes[poste_1244].MONTANT_M = tmp->postes[poste_1243].MONTANT_M * -1;
        }
        tmp = tmp->next;
    }

    RETURN_VAL(OK);
}


/*==============================================================================
objet   :
retour  :
==============================================================================*/
int findRefTraite(char *ctrLIB)
{
    e_poste ref_post = 0;
    DEBUT_FCT("findRefTraite");

    while (Kbd_traite->next != NULL)
    {
        for (ref_post = 0; ref_post < nb_poste; ++ref_post)
        {
            if (Kbd_traite->postes[ref_post].line[PRE_CTR_NF] != NULL)
            {
                if (strcmp(ctrLIB, Kbd_traite->postes[ref_post].line[PRE_CTR_NF]) == 0)
                    RETURN_VAL(OK);
            }
        }

        Kbd_traite = Kbd_traite->next;
    }

    for (ref_post = 0; ref_post < nb_poste; ++ref_post)
    {
        if (Kbd_traite->postes[ref_post].line[PRE_CTR_NF] != NULL)
        {
            if (strcmp(ctrLIB, Kbd_traite->postes[ref_post].line[PRE_CTR_NF]) == 0)
                RETURN_VAL(OK);
        }
    }
    n_linkchain(&Kbd_traite);

    RETURN_VAL(OK);
}


/*==============================================================================
objet   :
retour  :
==============================================================================*/
void cpyAllCol(T_Poste *dest, char **ref)
{
    int i;
    DEBUT_FCT("cpyAllCol");

    for (i = 0; ref[i] != NULL; ++i)
        dest->line[i] = strdup(ref[i]);
}


/*==============================================================================
objet   :
retour  :
==============================================================================*/
void goFirstElem(T_traite **linklist)
{
    DEBUT_FCT("goFirstElem");

    if (*linklist != NULL)
        while ((*linklist)->prev != NULL)
            (*linklist) = (*linklist)->prev;
}


/*==============================================================================
objet   :
retour  :
==============================================================================*/
void goLastElem(T_traite **linklist)
{
    DEBUT_FCT("goLastElem");

    if (*linklist != NULL)
        while ((*linklist)->next != NULL)
            (*linklist) = (*linklist)->next;
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

/*===========================================================================
objet   : recuperer les  s/p des traite
retour  :ecrire les postes 1480 dans la grille [01] 
============================================================================*/
int ecrire1480(T_Poste *poste)
{
    char    tmp[50];
    char    gap[3] = {0}, gaap[2] = {'\000', '\000'};;
    int     n_lob, Life;

    DEBUT_FCT("ecrire1480");

    if (poste->line[PRE_CTR_NF] == NULL)
        RETURN_VAL(OK);

    sprintf(tmp, "%.3lf", poste->Sp*100);
    poste->line[PRE_ESTMNT_M] = tmp;
    

        for (gaap[0] = '1'; gaap[0] <= '5'; ++(gaap[0]))
    {

        if (n_RechSUBTRSESBPROP(&pbd_SubTrsesBrop, poste->line[PRE_DETTRNCOD_CF], poste->line[PRE_SSD_CF], poste->line[PRE_ESB_CF]) != -1)
        {
            switch (gaap[0])
            {
            case '1':
                if (pbd_SubTrsesBrop.GAAP1TRS_CT == 3)
                {
                    poste->line[PRE_ESTMNT_M] = MONTANT_ZERO;
                    snprintf(gap, 3, "%d", 2);
                }
                
                break;

            case '2':
                if (pbd_SubTrsesBrop.GAAP2TRS_CT == 3)
                {
                    poste->line[PRE_ESTMNT_M] = MONTANT_ZERO;
                    snprintf(gap, 3, "%s", "A");
                }
                
                break;

            case '3':
                if (pbd_SubTrsesBrop.GAAP3TRS_CT == 3)
                {
                    poste->line[PRE_ESTMNT_M] = MONTANT_ZERO;
                    snprintf(gap, 3, "%s", "C");
                }
                break;

            case '4':
                if (pbd_SubTrsesBrop.GAAP4TRS_CT == 3)
                {
                    poste->line[PRE_ESTMNT_M] = MONTANT_ZERO;
                    snprintf(gap, 3, "%s", "E");
                }
                break;

            case '5':
                if (pbd_SubTrsesBrop.GAAP5TRS_CT == 3)
                {
                    poste->line[PRE_ESTMNT_M] = MONTANT_ZERO;
                    snprintf(gap, 3, "%s", "G");
                }
                break;
            }
        }

    poste->line[PRE_ACMTRS_NT]      = ACMTRS_1480;
    poste->line[PRE_DETTRNCOD_CF]   = DETTRNCOD_1480;
    poste->line[PRE_PRS_CF]         = PRS_1480;         //[04]
    poste->line[PRE_INDSUP_B]       = INDSUP_1480;      //[04]
    poste->line[PRE_CREUSR_CF]      = CREUSR_1480;      //[04]
    poste->line[PRE_LSTUPD_D]       = Ksz_Cre_D;        //[04]
    poste->line[PRE_GAAPDIFF_M]     = GAPDIFF_1480;     //[04]
    poste->line[PRE_PROPAGATION_B]  = PROPOGATION_1480; //[04]

    n_lob = atoi(poste->line[PRE_LOB_CF]);

    //Synchronisation du fichier trslnk afin de recuperer ACMTRS_NT
    if (n_lob == 30) 
     {
        Life = 1;
     }else if (n_lob == 31)
    {
         Life = 3;
    }

    poste->line[PRE_DETTRS_CF] = dtrs;
    //sprintf(poste->line[PRE_DETTRS_CF], "%d%d%s%s", Life, 1, DETTRNCOD_1480, gap);

        poste->line[PRE_GAAP_NF]        = gaap;
        poste->line[PRE_BATCH_B]        = BATCH_B;
        poste->line[PRE_CRE_D]          = Ksz_Cre_D;
        poste->line[PRE_LSTUPDUSR_CF]   = LSTUPDUSER_CF;
        poste->line[PRE_ORICOD_LS]      = ORICOD_LS;
        poste->line[PRE_NBCOL]          = NULL;

        n_WriteCols(Kp_OutputFil_LIFEST, poste->line, SEPARATEUR, 0);
    }
    

    RETURN_VAL(OK);
}

/*=============================================================================
objet:
        ajoute une ligne dans le tableau Kpbd_CPPILOT et la remplie avec *pb_new
Parametre:
        la nouvelle ligne*pb_new
Retour:
        -> OK
=============================================================================*/

int n_AddCPLIFDRI(T_LIFDRI_ALL *pbd_new)
{
	int i;


	DEBUT_FCT("n_AddCPLIFDRI");
	for(i=0;i<Kn_NbLigCPPilot;i++)
	{
		if (strcmp(pbd_new->CTR_NF,Kpbd_CPPILOT[i].CTR_NF)==0 &&
			pbd_new->SEC_NF == Kpbd_CPPILOT[i].SEC_NF	  &&
			pbd_new->ACY_NF == Kpbd_CPPILOT[i].ACY_NF)

				RETURN_VAL(OK);
	}

	Kn_NbLigCPPilot++ ;
	Kpbd_CPPILOT = (T_LIFDRI_ALL *)realloc(Kpbd_CPPILOT,sizeof(T_LIFDRI_ALL)*Kn_NbLigCPPilot);
	Kpbd_CPPILOT[Kn_NbLigCPPilot-1]=*pbd_new ;

	RETURN_VAL(OK)	;

}

/*=============================================================================
objet:
        Ecrit le tableau lifdri(Kbd_PILOT) et le tableau (Kpbd_CPPILOT) des
        complement dans le fichier de sortie binaire CPLIFDRI.

Retour:
        -> OK
=============================================================================*/
int n_EcrireCPLLIFDRI()
{
	DEBUT_FCT("n_EcrireCPLLIFDRI");

    fwrite(Kbd_PILOT	,sizeof(T_LIFDRI_ALL),Kn_NbLigPilot		,Kp_PilotOFil);
    fwrite(Kpbd_CPPILOT	,sizeof(T_LIFDRI_ALL),Kn_NbLigCPPilot	,Kp_PilotOFil);

	if ( Kpbd_CPPILOT ) free(Kpbd_CPPILOT), Kpbd_CPPILOT=NULL;

	RETURN_VAL(OK)	;
}