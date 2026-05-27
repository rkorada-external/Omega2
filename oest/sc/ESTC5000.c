/*==============================================================================
Nom de l'application          : Life Estimates Closing Multi-GAAP
Nom du source                 : ESTC5000.c
Révision                      : $Revision: 1.0 $
Date de création              : 29/07/2015
Auteur                        : Julien FONTANA
References des specifications : EST38 - EST52
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
Intra day job to create detailled table
------------------------------------------------------------------------------
historique des modifications :

[001]     JFO     29/07/2015  spot29095: Création du fichier
[002]     MBO     21/12/2015  spot29095: Pas d'affichage des ligne qu'avec des '0' dans le champs DETAIL_*_M
[003]     MBO     07/03/2016  spot30352: spira:44672 correction, pour la date avant start_d c'est ">" et non pas ">="
[004]     MBO     07/06/2016  spot30691: ajout de du champ QUARTER_B
[005]     MBO     29/06/2016  spot30691:spira51465 trimestrialisation
[006]     MBO     06/07/2016  spot30898:spira51465 oublie de l'init de SUBTRASSO
=============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include "ESTC5000.h"
#include "estserv.h"
//#include "struct.h"
#include <estserv.h>
#include <float.h>
#include <struct.h>
#include <utctlib.h>
#include <util.h>

#define Kn_MaxPostes    5000//[005]
#define COL             57//[005]
#define PRE_ACMDET_NT   54//[005]
#define PRE_VAL         55//[005]

typedef struct
{
  char              Dettrncod1[6];
  char              Dettrncod2[6];
  int               Code;
} T_DEF_DettCod;

/*----------------------*/
/* Variables de travail */
/*----------------------*/

FILE                *Kp_OutputDETAIL;
FILE                *Kp_InputFAVERATE;

T_RUPTURE_VAR       pbd_RuptVarCall;
T_RUPTURE_SYNC_VAR  pbd_RuptSyncVarMvt;
T_RUPTURE_SYNC_VAR  pbd_RuptSyncVarOpen;
T_RUPTURE_SYNC_VAR  pbd_RuptSyncVarPlan;

T_CSU_TEMP          tpdb_CSU_OPENING[T_MAX_CSU];
T_CSU_TEMP          tpdb_CSU_MVT[T_MAX_CSU];
T_CSU_TEMP          tpdb_CSU_PLAN[T_MAX_CSU];

T_FAVERATE_RATIO    pdb_FAVERATE[T_MAX_CUR];


T_CALL              tpdb_CALL_LIST[T_MAX_CALL];
int                 Kn_NbLigCall        = 0;
T_MVT               tpdb_MVT_LIST[T_MAX_MVT];
int                 Kn_NbLigMVT        = 0;

int                 tn_LIST_IDS[T_MAX_LIST_IDS];

int                 Kn_NbLigPilot       = 0;

int                 n_CSU_OPENING_Index = 0;
int                 n_CSU_MVT1_Index    = 0;
int                 n_CSU_MVT2_Index    = 0;
int                 n_CSU_MVT3_Index    = 0;
int                 n_CSU_PLAN_Index    = 0;

int                 Kn_annee;
char                Ksz_date[11];

char                acmtrs[5]; //[005]
char                dettacmtrs[12]; //[005]

char                *(ttpsz_DetailLine[DETAIL_NBPERIOD][DETAIL_NBCOLS + 3]); //[005]

static FILE         *Kp_SubTRSAssoFile;//[005]

T_SUBTRSASSO        Kbd_SubTRSASSO[10000];//[005]

static T_SUBTRSASSO     SubTrsAssoLigne;//[005]

/*----------------------*/
/*      Prototypes      */
/*----------------------*/

int n_InitRuptCall(T_RUPTURE_VAR *pbd_RuptVarCall);
int ActionLastCall(char **tpsz_InRec_CALL);
int n_ConditionRuptCall(char **tpsz_InRec_CALL, char **tpsz_InRec);
int n_ActionLigneCALL(char **tpsz_InRec_CALL);


int n_InitRuptMvt(T_RUPTURE_SYNC_VAR *pbd_RuptSyncVarMvt);
int ActionLigneSyncMvt(char **tpsz_InRec_CALL, char **tpsz_InRec_MVT);
int ConditionEndSyncMvt(char **tpsz_InRec_CALL, char **tpsz_InRec_MVT);

int n_InitRuptOpen(T_RUPTURE_SYNC_VAR *pbd_RuptSyncVarOpen);
int ActionLigneSyncOpen(char **tpsz_InRec_CALL, char **tpsz_InRec);
int ConditionEndSyncOpen(char **tpsz_InRec_CALL, char **tpsz_InRec);

int n_InitRuptPLAN(T_RUPTURE_SYNC_VAR *pdb_RuptPLAN);
int n_ActionLignePLAN(char **tpsz_InRec_CALL, char **tpsz_InRec_PLAN);
int n_ConditionSyncPLAN(char **tpsz_InRec_CALL, char **tpsz_InRec_PLAN);

int rech_cur_mnt_MVT(T_MVT *tab, int acy, int dettrncod, char gaap, char *cur, double *mnt, char *date, char is_end); //[003]
int rech_cur_mnt(T_CSU_TEMP *tab, int acy, int dettrncod, char gaap, char *cur, double *mnt);
double conv_montant(char *cur_from, char *cur_to, double mnt);
int charger_FAVERATE(FILE *Kp_InputFAVERATE);
void deconcat_FAVERATE(char *line, T_FAVERATE_RATIO *allCur);
int errorMsg(char *error);

int Creat_DETTACMTRS(char **ttpsz_DetailLine); //[005]
int n_ReturnDett(int Asso, int contx, char *DETRNCOD); //[005]


/*==============================================================================
objet :
retour:
==============================================================================*/
int main(int argc, char *argv[])
{
    /* Initialisation des signaux */
    InitSig();

    if (n_BeginPgm(argc, argv) == ERR)                                           ExitPgm(ERR_XX, "");

    /* Recuperation de l annee bilan */
    strcpy(Ksz_date, psz_GetCharArgv(1));
    Kn_annee = atoi(Ksz_date);

    if (n_OpenFileAppl("ESTC5000_O1", "wt", &Kp_OutputDETAIL) == ERR)            ExitPgm(ERR_XX, "");
    if (n_OpenFileAppl("ESTC5000_I5", "rt", &Kp_InputFAVERATE) == ERR)           ExitPgm(ERR_XX, "");
    if (n_OpenFileAppl("ESTC5000_I6", "rb", &Kp_SubTRSAssoFile) == ERR)          ExitPgm(ERR_XX, "Cannot open ESTC2056_I1 file!");

    if (n_InitRuptCall(&pbd_RuptVarCall) == ERR)                                 ExitPgm(ERR_XX, "");
    if (n_InitRuptMvt(&pbd_RuptSyncVarMvt) == ERR)                               ExitPgm(ERR_XX, "");
    if (n_InitRuptOpen(&pbd_RuptSyncVarOpen) == ERR)                             ExitPgm(ERR_XX, "");
    if (n_InitRuptPLAN(&pbd_RuptSyncVarPlan) == ERR)                             ExitPgm(ERR_XX, "");

    if (charger_FAVERATE(Kp_InputFAVERATE) == ERR)                               ExitPgm(ERR_XX, "");
    if (n_ChargerTsubTRSAsso(Kp_SubTRSAssoFile) == ERR)                          ExitPgm(ERR_XX, ""); //[006]

    if (n_ProcessingRuptureVar(&pbd_RuptVarCall) == ERR)                         ExitPgm(ERR_XX, "");

    if (n_CloseFileAppl("ESTC5000_I1", &pbd_RuptVarCall.pf_InputFil) == ERR)     ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC5000_I2", &pbd_RuptSyncVarMvt.pf_InputFil) == ERR)  ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC5000_I3", &pbd_RuptSyncVarOpen.pf_InputFil) == ERR) ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC5000_I4", &pbd_RuptSyncVarPlan.pf_InputFil) == ERR) ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC5000_I5", &Kp_InputFAVERATE) == ERR)                ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC5000_I6", &Kp_SubTRSAssoFile) == ERR)               ExitPgm(ERR_XX, "Cannot close properly ESTC2056_I1 file!");
    if (n_CloseFileAppl("ESTC5000_O1", &Kp_OutputDETAIL) == ERR)                 ExitPgm(ERR_XX, "");

    if (n_EndPgm() == ERR)                                                       ExitPgm(ERR_XX, "");

    exit(OK);
}


/*==============================================================================
objet :
retour:
==============================================================================*/
int n_InitRuptCall(T_RUPTURE_VAR *pbd_RuptVarCall)
{
    DEBUT_FCT("n_InitRuptCall");

    memset(pbd_RuptVarCall, 0, sizeof(T_RUPTURE_VAR));

    if (n_OpenFileAppl("ESTC5000_I1", "rt", &(pbd_RuptVarCall->pf_InputFil)) == ERR)
        RETURN_VAL(errorMsg("MVT OPENING failed. Error in ESTC5000.\n"));

    pbd_RuptVarCall->n_NbRupture           = 1;
    pbd_RuptVarCall->n_ConditionRupture[0] = n_ConditionRuptCall;
    pbd_RuptVarCall->n_ActionLast[0]       = ActionLastCall;
    pbd_RuptVarCall->c_Separ               = SEPARATEUR;
    pbd_RuptVarCall->n_ActionLigne         = n_ActionLigneCALL;

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
retour:
==============================================================================*/
int n_ActionLigneCALL(char **tpsz_InRec_CALL)
{
    DEBUT_FCT("n_ActionLigneCALL");

    RETURN_VAL(OK);
}

/*==============================================================================
objet :
retour:
==============================================================================*/
int ActionLastCall(char **tpsz_InRec_CALL)
{
    int  i                       =    0;
    int  j                       =    0;
    int  callIndex               =    0;
    int  mvtIndex                =    0;
    int  acy                     =    0;
    int  acy_p                   =    0;
    int  dettrncod               =    0;
    int  dettrncod_p             =    0;
    char cur[4]                  = {'\0'};
    char cur_ref[4]              = {'\0'};
    char buff_id_cf[10]          = {'\0'};
    char buff_sec[20]            = {'\0'};
    char buff_acy[20]            = {'\0'};
    char buff_dettrncod[20]      = {'\0'};
    char buff_mvt1_ifrsamt[20]   = {'\0'};
    char buff_mvt1_prntamt[20]   = {'\0'};
    char buff_mvt1_localamt[20]  = {'\0'};
    char buff_mvt3_ifrsamt[20]   = {'\0'};
    char buff_mvt3_prntamt[20]   = {'\0'};
    char buff_mvt3_localamt[20]  = {'\0'};
    char buff_open_ifrsamt[20]   = {'\0'};
    char buff_open_prntamt[20]   = {'\0'};
    char buff_open_localamt[20]  = {'\0'};
    char buff_plan_ifrsamt[20]   = {'\0'};
    char buff_plan_prntamt[20]   = {'\0'};
    char buff_plan_localamt[20]  = {'\0'};
    double mnt;

    DEBUT_FCT("ActionLastCall");

    for (i = 0; i < DETAIL_NBPERIOD; ++i)
    {
        for (j = 0; j < DETAIL_NBCOLS + 2; ++j)
            ttpsz_DetailLine[i][j] = "";
        ttpsz_DetailLine[i][DETAIL_NBCOLS + 2] = NULL;
    }

    n_CSU_OPENING_Index = 0;
    n_CSU_PLAN_Index    = 0;

    memset(tpdb_CSU_OPENING,  0, sizeof(T_CSU_TEMP) * T_MAX_CSU);
    memset(tpdb_MVT_LIST,     0, sizeof(T_MVT)  * T_MAX_MVT);
    memset(tpdb_CSU_PLAN,     0, sizeof(T_CSU_TEMP) * T_MAX_CSU);
    memset(tpdb_CALL_LIST,    0, sizeof(T_CALL) * T_MAX_CALL);

    tpdb_CALL_LIST[0].ID_CF     =          atoi(tpsz_InRec_CALL[CALL_ID_CF]);
    tpdb_CALL_LIST[0].UPDTYP_CT =          atoi(tpsz_InRec_CALL[CALL_UPDTYP_CT]); // si c'est un chargement 0 et 1 si c'est un file upload
    strncpy(tpdb_CALL_LIST[0].SSD_CF,           tpsz_InRec_CALL[CALL_SSD_CF],       3);
    strncpy(tpdb_CALL_LIST[0].ESB_CF,           tpsz_InRec_CALL[CALL_ESB_CF],       3);
    strncpy(tpdb_CALL_LIST[0].LSTUPDUSR_CF,     tpsz_InRec_CALL[CALL_LSTUPDUSR_CF], 9);
    strncpy(tpdb_CALL_LIST[0].CTR_NF,           tpsz_InRec_CALL[CALL_CTR_NF],       9);
    tpdb_CALL_LIST[0].SEC_NF    =          atoi(tpsz_InRec_CALL[CALL_SEC_NF]);
    strcpy(tpdb_CALL_LIST[0].UWY_NF,            tpsz_InRec_CALL[CALL_UWY_NF]);
    strncpy(tpdb_CALL_LIST[0].START_D,          tpsz_InRec_CALL[CALL_START_D],      22);
    strncpy(tpdb_CALL_LIST[0].END_D,            tpsz_InRec_CALL[CALL_END_D],        22);

    n_ProcessingRuptureSyncVar(&pbd_RuptSyncVarMvt, tpsz_InRec_CALL);
    n_ProcessingRuptureSyncVar(&pbd_RuptSyncVarOpen, tpsz_InRec_CALL);
    n_ProcessingRuptureSyncVar(&pbd_RuptSyncVarPlan, tpsz_InRec_CALL);
    callIndex = 0;
    for (mvtIndex = 0; mvtIndex < Kn_NbLigMVT; ++mvtIndex)
    {
        acy = tpdb_MVT_LIST[mvtIndex].ACY;
        dettrncod = tpdb_MVT_LIST[mvtIndex].DETTRNCOD;
        if (acy != acy_p || dettrncod != dettrncod_p)
        {
            for (i = 0; i < 2; ++i)
            {
                snprintf(buff_id_cf, 10, "%d", tpdb_CALL_LIST[callIndex].ID_CF);
                ttpsz_DetailLine[i][DETAIL_ID_CF]        = buff_id_cf;

                ttpsz_DetailLine[i][DETAIL_SSD_CF]       = tpdb_CALL_LIST[callIndex].SSD_CF;
                ttpsz_DetailLine[i][DETAIL_ESB_CF]       = tpdb_CALL_LIST[callIndex].ESB_CF;
                ttpsz_DetailLine[i][DETAIL_LSTUPDUSR_CF] = tpdb_CALL_LIST[callIndex].LSTUPDUSR_CF;
                ttpsz_DetailLine[i][DETAIL_PERIOD_NT]    = (i == 1) ? "2" : "1";
                ttpsz_DetailLine[i][DETAIL_CTR_NF]       = tpdb_CALL_LIST[callIndex].CTR_NF;
                ttpsz_DetailLine[i][DETAIL_QUARTER_B]    = "0"; // [004]
                
                snprintf(buff_sec, 3, "%d", tpdb_CALL_LIST[callIndex].SEC_NF);
                ttpsz_DetailLine[i][DETAIL_SEC_NF]       = buff_sec;

                ttpsz_DetailLine[i][DETAIL_UWY_NF]       = tpdb_CALL_LIST[callIndex].UWY_NF;

                // tpdb_MVT_LIST   tpdb_CALL_LIST
                // ancien MVT3 = ligne de MVT où cre_d < call.end_d


                snprintf(buff_acy, 5, "%d", tpdb_MVT_LIST[mvtIndex].ACY);
                ttpsz_DetailLine[i][DETAIL_ACY_NF]       = buff_acy;

                snprintf(buff_dettrncod, 6, "%d",  tpdb_MVT_LIST[mvtIndex].DETTRNCOD);
                ttpsz_DetailLine[i][DETAIL_DETTRNCOD_CF] = buff_dettrncod;


                rech_cur_mnt_MVT(tpdb_MVT_LIST, acy, dettrncod, '2', cur_ref, &mnt, tpdb_CALL_LIST[callIndex].END_D, END); //[003]
                ttpsz_DetailLine[i][DETAIL_CUR_CF]       = cur_ref;
                snprintf(buff_mvt3_ifrsamt, 15, "%-.3f",  mnt);
                ttpsz_DetailLine[i][DETAIL_IFRSAMT_M]    = buff_mvt3_ifrsamt;

                rech_cur_mnt_MVT(tpdb_MVT_LIST, acy, dettrncod, '3', cur, &mnt, tpdb_CALL_LIST[callIndex].END_D, END); //[003]
                snprintf(buff_mvt3_prntamt, 15, "%-.3f", conv_montant(cur, cur_ref, mnt));
                ttpsz_DetailLine[i][DETAIL_PRNTAMT_M]    = buff_mvt3_prntamt;

                rech_cur_mnt_MVT(tpdb_MVT_LIST, acy, dettrncod, '4', cur, &mnt, tpdb_CALL_LIST[callIndex].END_D, END); //[003]
                snprintf(buff_mvt3_localamt, 15, "%-.3f", conv_montant(cur, cur_ref, mnt));
                ttpsz_DetailLine[i][DETAIL_LOCALAMT_M]   = buff_mvt3_localamt;

                if (i == 1) //PERIOD 2 QTD
                {
                    // ancien MVT1 = ligne de MVT où cre_d < call.start_d
                    // index = fct de recherchhe(tpdb_CALL_LIST[callIndex].START_D)    //ajouter acy dettrncod et le gaap
                    rech_cur_mnt_MVT(tpdb_MVT_LIST, acy, dettrncod, '2', cur, &mnt, tpdb_CALL_LIST[callIndex].START_D, START); //[003]
                    snprintf(buff_mvt1_ifrsamt, 15, "%-.3f", conv_montant(cur, cur_ref, mnt));
                    ttpsz_DetailLine[i][DETAIL_PREVIFRSAMT_M] = buff_mvt1_ifrsamt;

                    rech_cur_mnt_MVT(tpdb_MVT_LIST, acy, dettrncod, '3', cur, &mnt, tpdb_CALL_LIST[callIndex].START_D, START); //[003]
                    snprintf(buff_mvt1_prntamt, 15, "%-.3f", conv_montant(cur, cur_ref, mnt));
                    ttpsz_DetailLine[i][DETAIL_PREVPRNTAMT_M] = buff_mvt1_prntamt;

                    rech_cur_mnt_MVT(tpdb_MVT_LIST, acy, dettrncod, '4', cur, &mnt, tpdb_CALL_LIST[callIndex].START_D, START); //[003]
                    snprintf(buff_mvt1_localamt, 15, "%-.3f", conv_montant(cur, cur_ref, mnt));
                    ttpsz_DetailLine[i][DETAIL_PREVLOCALAMT_M] = buff_mvt1_localamt;
                }
                else //PERIOD 1 YTD
                {
                    rech_cur_mnt(tpdb_CSU_OPENING, acy, dettrncod, '2', cur, &mnt);
                    snprintf(buff_open_ifrsamt, 15, "%-.3f", conv_montant(cur, cur_ref, mnt));
                    ttpsz_DetailLine[i][DETAIL_PREVIFRSAMT_M] = buff_open_ifrsamt;

                    rech_cur_mnt(tpdb_CSU_OPENING, acy, dettrncod, '3', cur, &mnt);
                    snprintf(buff_open_prntamt, 15, "%-.3f", conv_montant(cur, cur_ref, mnt));
                    ttpsz_DetailLine[i][DETAIL_PREVPRNTAMT_M] = buff_open_prntamt;

                    rech_cur_mnt(tpdb_CSU_OPENING, acy, dettrncod, '4', cur, &mnt);
                    snprintf(buff_open_localamt, 15, "%-.3f", conv_montant(cur, cur_ref, mnt));
                    ttpsz_DetailLine[i][DETAIL_PREVLOCALAMT_M] = buff_open_localamt;
                }

                rech_cur_mnt(tpdb_CSU_PLAN, acy, dettrncod, '2', cur, &mnt);
                snprintf(buff_plan_ifrsamt, 15, "%-.3f", conv_montant(cur, cur_ref, mnt));
                ttpsz_DetailLine[i][DETAIL_PLNIFRSAMT_M] =  buff_plan_ifrsamt;

                rech_cur_mnt(tpdb_CSU_PLAN, acy, dettrncod, '3', cur, &mnt);
                snprintf(buff_plan_prntamt, 15, "%-.3f", conv_montant(cur, cur_ref, mnt));
                ttpsz_DetailLine[i][DETAIL_PLNPRNTAMT_M] =  buff_plan_prntamt;

                rech_cur_mnt(tpdb_CSU_PLAN, acy, dettrncod, '4', cur, &mnt);
                snprintf(buff_plan_localamt, 15, "%-.3f", conv_montant(cur, cur_ref, mnt));
                ttpsz_DetailLine[i][DETAIL_PLNLOCALAMT_M] =  buff_plan_localamt;

//[002]
                if (strcmp(ttpsz_DetailLine[i][DETAIL_IFRSAMT_M],       "0.000") != 0 ||
                    strcmp(ttpsz_DetailLine[i][DETAIL_PRNTAMT_M],       "0.000") != 0 ||
                    strcmp(ttpsz_DetailLine[i][DETAIL_LOCALAMT_M],      "0.000") != 0 ||
                    strcmp(ttpsz_DetailLine[i][DETAIL_PREVIFRSAMT_M],   "0.000") != 0 ||
                    strcmp(ttpsz_DetailLine[i][DETAIL_PREVPRNTAMT_M],   "0.000") != 0 ||
                    strcmp(ttpsz_DetailLine[i][DETAIL_PREVLOCALAMT_M],  "0.000") != 0 ||
                    strcmp(ttpsz_DetailLine[i][DETAIL_PLNIFRSAMT_M],    "0.000") != 0 ||
                    strcmp(ttpsz_DetailLine[i][DETAIL_PLNPRNTAMT_M],    "0.000") != 0 ||
                    strcmp(ttpsz_DetailLine[i][DETAIL_PLNLOCALAMT_M],   "0.000") != 0)
//![002]
                    Creat_DETTACMTRS(ttpsz_DetailLine[i]);//[005]
            }
        }
        acy_p = acy;
        dettrncod_p = dettrncod;
    }
    Kn_NbLigCall = 0;
    Kn_NbLigMVT = 0;
    RETURN_VAL(OK);
}

//[005]
/*==============================================================================
objet :
        fonction lancee pour chaque ligne du fichier des previsions

retour :
        0 ----> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int Creat_DETTACMTRS(char **ttpsz_DetailLine)
{
  int   j   = 0;
  int   tmp = 0;
  int   ret = 0;
  char  sz_acmtrs[5]   = {0};
  char  dett[3]        = {0};
  char  sz_dettrn[6];
  char  *psz_ligne[COL + 2] = {NULL};

  memset(&SubTrsAssoLigne, 0, sizeof(T_SUBTRSASSO));
  memset(dettacmtrs, 0, sizeof(*dettacmtrs) * 12);
  memset(sz_dettrn, 0, sizeof(sz_dettrn));

  DEBUT_FCT("n_ActionLignePrev");

  for (j = 0; j < DETAIL_NBCOLS + 2; j++)
    psz_ligne[j] = ttpsz_DetailLine[j];  
  psz_ligne[DETAIL_NBCOLS + 2] = NULL;

  if (n_FindTsubTRSAsso(&SubTrsAssoLigne, 1, 1, ttpsz_DetailLine[DETAIL_DETTRNCOD_CF]) != -1) //cas d'une constitution
  {
    tmp = 2;
    snprintf(dett,3, "%d", 3);        // pour la vérification des constitutions
    snprintf(sz_dettrn, 6, "%s", ttpsz_DetailLine[DETAIL_DETTRNCOD_CF]);
    snprintf(sz_acmtrs, 5, "%s", ttpsz_DetailLine[DETAIL_ACMTRS_NT]);
    sz_acmtrs[3] = '3';               //modification de la dernière valeur de l'acmtrs      
  }
  else  if (n_FindTsubTRSAssoCons(1, 1, ttpsz_DetailLine[DETAIL_DETTRNCOD_CF]) != -1) // cas d'une libération
  {
    tmp = 1;
    snprintf(dett,3, "%d", 4);       // pour la vérification des libérations
    ret = n_ReturnDett(1, 1, ttpsz_DetailLine[DETAIL_DETTRNCOD_CF]);
    sprintf(sz_dettrn, "%d", ret); 
    snprintf(sz_acmtrs, 5, "%s", ttpsz_DetailLine[DETAIL_ACMTRS_NT]);
    sz_acmtrs[3] = '3';
  }
  else if (n_FindTsubTRSAsso(&SubTrsAssoLigne, 5, 1, ttpsz_DetailLine[DETAIL_DETTRNCOD_CF]) != -1) // cas d'une entrée
  {
    tmp = 1;
    snprintf(dett,3, "%d", 1);       // pour la vérification des entrées
    snprintf(sz_dettrn, 6, "%s", ttpsz_DetailLine[DETAIL_DETTRNCOD_CF]);
    snprintf(sz_acmtrs, 5, "%s", ttpsz_DetailLine[DETAIL_ACMTRS_NT]);
    sz_acmtrs[3] = '1';
  }
  else if (n_FindTsubTRSAssoCons(5, 1, ttpsz_DetailLine[DETAIL_DETTRNCOD_CF]) != -1) // cas d'un retrait
  {
    tmp = 2;
    snprintf(dett,3, "%d", 2);      // pour la vérification des retraits
    ret = n_ReturnDett(5, 1, ttpsz_DetailLine[DETAIL_DETTRNCOD_CF]);  //récupération du dettrncod1
    sprintf(sz_dettrn, "%d", ret);
    snprintf(sz_acmtrs, 5, "%s", ttpsz_DetailLine[DETAIL_ACMTRS_NT]);
    sz_acmtrs[3] = '1';                                         //modification de la dernière valeur de l'acmtrs
  }
  else  //SINON -dans les autres cas-
  {
    tmp = 0;
    snprintf(dett,3, "%d", 0);
    snprintf(sz_dettrn, 6, "%s", ttpsz_DetailLine[DETAIL_DETTRNCOD_CF]); //récupération du dettrncod
    snprintf(sz_acmtrs, 5, "%s", ttpsz_DetailLine[DETAIL_ACMTRS_NT]);    //récupération de l'acmtrs
  }

  sprintf(dettacmtrs, "%s%s%d", sz_acmtrs, sz_dettrn, tmp); //valeur du nouveau champs --concaténation de l'acmtrs, dettrncod et tmp

  ttpsz_DetailLine[DETAIL_ACMDET_NT] = dettacmtrs;

  n_WriteCols(Kp_OutputDETAIL, ttpsz_DetailLine, SEPARATEUR, 0);
  
  RETURN_VAL(0);
}

/*==========================================================================
     Objet :    Recuperer le code détail (contre partie) d'un poste donné (pour un DETTRNCOD)
     à partir de la structure T_SUBTRSASSO grace a l association et le context

     Nom:       n_ReturnDett

     Parametres:
                pointeur sur stucture TRSASSO
                Association
                context
                DETTRNCOD lib

     Retour:    DETTRNCOD/-1
===========================================================================*/
int n_ReturnDett(int Asso, int contx, char *DETRNCOD)
{
  int i;

  for (i = 0; i < sizeof(T_SUBTRSASSO); i++)
    {
    if ((Asso == atoi(Kbd_SubTRSASSO[i].ASSOTYP_CT)) && (contx == Kbd_SubTRSASSO[i].CTX_NT) && ((strcmp(DETRNCOD, Kbd_SubTRSASSO[i].DETTRNCOD2_CF) == 0)))
    {
      return atoi(Kbd_SubTRSASSO[i].DETTRNCOD1_CF);
    }
  }
  return -1 ;
}
//![005]

/*==============================================================================
objet :
retour:
==============================================================================*/
int n_ConditionRuptCall(char **tpsz_InRec_CALL, char **tpsz_InRec)
{
    int     ret = 0;
    DEBUT_FCT("n_ConditionSyncMVT");

    if ((ret = strcmp(tpsz_InRec_CALL[CALL_SSD_CF], tpsz_InRec[CALL_SSD_CF])) != 0) RETURN_VAL(ERR);
    if ((ret = strcmp(tpsz_InRec_CALL[CALL_CTR_NF], tpsz_InRec[CALL_CTR_NF])) != 0) RETURN_VAL(ERR);
    if ((ret = strcmp(tpsz_InRec_CALL[CALL_SEC_NF], tpsz_InRec[CALL_SEC_NF])) != 0) RETURN_VAL(ERR);
    if ((ret = strcmp(tpsz_InRec_CALL[CALL_UWY_NF], tpsz_InRec[CALL_UWY_NF])) != 0) RETURN_VAL(ERR);

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
retour:
==============================================================================*/
int n_InitRuptMvt(T_RUPTURE_SYNC_VAR *pbd_RuptSyncVarMvt)
{
    DEBUT_FCT("n_InitRuptMvt");

    memset(pbd_RuptSyncVarMvt, 0, sizeof(T_RUPTURE_SYNC_VAR));

// Ouverture de la table d'appel
    if (n_OpenFileAppl("ESTC5000_I2", "rt", &(pbd_RuptSyncVarMvt->pf_InputFil)) == ERR)
        RETURN_VAL(errorMsg("Opening file I2 failed. Error in ESTC5000.\n"));

    pbd_RuptSyncVarMvt->n_NbRupture        = 0;
    pbd_RuptSyncVarMvt->n_ActionLigne      = ActionLigneSyncMvt;
    pbd_RuptSyncVarMvt->ConditionEndSync   = ConditionEndSyncMvt;
    pbd_RuptSyncVarMvt->c_Separ            = SEPARATEUR;

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
retour:
Warning: Les montants des postes retro sont inversés dans le fichier extrait de la grille
==============================================================================*/
int ActionLigneSyncMvt(char **tpsz_InRec_CALL, char **tpsz_InRec_MVT)
{
    DEBUT_FCT("ActionLigneSyncMvt");

    if (Kn_NbLigMVT >= T_MAX_MVT)
        RETURN_VAL(errorMsg("T_MAX_CALL Overflow. Error in ESTC5000.\n"));
    if (Kn_NbLigMVT == 0)
        memset(tpdb_MVT_LIST,    0, sizeof(T_MVT) * T_MAX_MVT);

    tpdb_MVT_LIST[Kn_NbLigMVT].ACY       = atoi(tpsz_InRec_MVT[PRE_ACY_NF]);
    strncpy(tpdb_MVT_LIST[Kn_NbLigMVT].CRE_D,           tpsz_InRec_MVT[PRE_CRE_D], 22);
    strncpy(tpdb_MVT_LIST[Kn_NbLigMVT].CUR,             tpsz_InRec_MVT[PRE_CUR_CF], 3);
    if (tpsz_InRec_MVT[PRE_ACMTRS_NT][0] == '2' || tpsz_InRec_MVT[PRE_ACMTRS_NT][0] == '4')
        tpdb_MVT_LIST[Kn_NbLigMVT].MNT       = atof(tpsz_InRec_MVT[PRE_ESTMNT_M]) * -1; //Warning
    else
        tpdb_MVT_LIST[Kn_NbLigMVT].MNT       = atof(tpsz_InRec_MVT[PRE_ESTMNT_M]);
    tpdb_MVT_LIST[Kn_NbLigMVT].DETTRNCOD = atoi(tpsz_InRec_MVT[PRE_DETTRNCOD_CF]);
    tpdb_MVT_LIST[Kn_NbLigMVT].GAAP      =      tpsz_InRec_MVT[PRE_GAAP_NF][0];

    strncpy(acmtrs, tpsz_InRec_MVT[PRE_ACMTRS_NT], 4);//[005]
    ttpsz_DetailLine[0][DETAIL_ACMTRS_NT] = acmtrs;//[005]
    ttpsz_DetailLine[1][DETAIL_ACMTRS_NT] = acmtrs;//[005]

    Kn_NbLigMVT++;

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
retour:
==============================================================================*/
int ConditionEndSyncMvt(char **tpsz_InRec_CALL, char **tpsz_InRec_MVT)
{
    int     ret = 0;
    DEBUT_FCT("n_ConditionSyncMVT");

    if ((ret = strcmp(tpsz_InRec_CALL[CALL_SSD_CF], tpsz_InRec_MVT[PRE_SSD_CF])) != 0) RETURN_VAL(ERR);
    if ((ret = strcmp(tpsz_InRec_CALL[CALL_CTR_NF], tpsz_InRec_MVT[PRE_CTR_NF])) != 0) RETURN_VAL(ERR);
    if ((ret = strcmp(tpsz_InRec_CALL[CALL_SEC_NF], tpsz_InRec_MVT[PRE_SEC_NF])) != 0) RETURN_VAL(ERR);
    if ((ret = strcmp(tpsz_InRec_CALL[CALL_UWY_NF], tpsz_InRec_MVT[PRE_UWY_NF])) != 0) RETURN_VAL(ERR);

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
retour:
==============================================================================*/
int n_InitRuptOpen(T_RUPTURE_SYNC_VAR *pbd_RuptSyncVarOpen)
{
    DEBUT_FCT("n_InitRuptOpen");

    memset(pbd_RuptSyncVarOpen, 0, sizeof(T_RUPTURE_SYNC_VAR));

// Ouverture de la table d'appel
    if (n_OpenFileAppl("ESTC5000_I3", "rt", &(pbd_RuptSyncVarOpen->pf_InputFil)) == ERR)
        RETURN_VAL(errorMsg("Opening file I3 failed. Error in ESTC5000.\n"));

    pbd_RuptSyncVarOpen->n_NbRupture        = 0;
    pbd_RuptSyncVarOpen->n_ActionLigne      = ActionLigneSyncOpen;
    pbd_RuptSyncVarOpen->ConditionEndSync   = ConditionEndSyncOpen;
    pbd_RuptSyncVarOpen->c_Separ            = SEPARATEUR;

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
retour:
==============================================================================*/
int ActionLigneSyncOpen(char **tpsz_InRec_CALL, char **tpsz_InRec_OPEN)
{
    DEBUT_FCT("ActionLigneSyncOpen");

    if (n_CSU_OPENING_Index >= T_MAX_CSU)
        RETURN_VAL(errorMsg("T_MAX_CSU Overflow. Error in ESTC5000.\n"));

    if (atoi(tpsz_InRec_OPEN[PRE_ACY_NF]) < Kn_annee - 4 || atoi(tpsz_InRec_OPEN[PRE_ACY_NF]) > Kn_annee)
        RETURN_VAL(OK);

    tpdb_CSU_OPENING[n_CSU_OPENING_Index].n_ACY       = atoi(tpsz_InRec_OPEN[PRE_ACY_NF]);
    tpdb_CSU_OPENING[n_CSU_OPENING_Index].n_DETTRNCOD = atoi(tpsz_InRec_OPEN[PRE_DETTRNCOD_CF]);
    tpdb_CSU_OPENING[n_CSU_OPENING_Index].c_GAAP      = tpsz_InRec_OPEN[PRE_GAAP_NF][0];
    strncpy(tpdb_CSU_OPENING[n_CSU_OPENING_Index].sz_CUR, tpsz_InRec_OPEN[PRE_CUR_CF], 3);
    tpdb_CSU_OPENING[n_CSU_OPENING_Index].sz_CUR[3]   = '\0';
    if (tpsz_InRec_OPEN[PRE_ACMTRS_NT][0] == '2' || tpsz_InRec_OPEN[PRE_ACMTRS_NT][0] == '4')
        tpdb_CSU_OPENING[n_CSU_OPENING_Index].d_MNT       = atof(tpsz_InRec_OPEN[PRE_ESTMNT_M]) * -1;
    else
        tpdb_CSU_OPENING[n_CSU_OPENING_Index].d_MNT       = atof(tpsz_InRec_OPEN[PRE_ESTMNT_M]);

    strncpy(acmtrs, tpsz_InRec_OPEN[PRE_ACMTRS_NT], 4);//[005]
    ttpsz_DetailLine[0][DETAIL_ACMTRS_NT] = acmtrs;//[005]
    ttpsz_DetailLine[1][DETAIL_ACMTRS_NT] = acmtrs;//[005]

    ++n_CSU_OPENING_Index;

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
retour:
==============================================================================*/
int ConditionEndSyncOpen(char **tpsz_InRec_CALL, char **tpsz_InRec_OPEN)
{
    int     ret = 0;
    DEBUT_FCT("ConditionEndSyncOpen");

    if ((ret = strcmp(tpsz_InRec_CALL[CALL_SSD_CF], tpsz_InRec_OPEN[PRE_SSD_CF])) != 0) RETURN_VAL(ERR);
    if ((ret = strcmp(tpsz_InRec_CALL[CALL_CTR_NF], tpsz_InRec_OPEN[PRE_CTR_NF])) != 0) RETURN_VAL(ERR);
    if ((ret = strcmp(tpsz_InRec_CALL[CALL_SEC_NF], tpsz_InRec_OPEN[PRE_SEC_NF])) != 0) RETURN_VAL(ERR);
    if ((ret = strcmp(tpsz_InRec_CALL[CALL_UWY_NF], tpsz_InRec_OPEN[PRE_UWY_NF])) != 0) RETURN_VAL(ERR);

    RETURN_VAL(OK);
}


/*==============================================================================
objet :     Initialisation de la structure de rupture LIFEST (dernier PLAN)
retour:     OK
==============================================================================*/
int n_InitRuptPLAN(T_RUPTURE_SYNC_VAR * pdb_RuptPLAN)
{
    DEBUT_FCT("n_InitRuptPLAN");

    memset(pdb_RuptPLAN, 0, sizeof(T_RUPTURE_SYNC_VAR));

// Ouverture de la table d'appel
    if (n_OpenFileAppl("ESTC5000_I4", "rt", &(pdb_RuptPLAN->pf_InputFil)) == ERR)
        RETURN_VAL(errorMsg("Openning PLAN failed. Error in ESTC5000.\n"));

    pdb_RuptPLAN->n_NbRupture           = 0;
    pdb_RuptPLAN->n_ActionLigne         = n_ActionLignePLAN;
    pdb_RuptPLAN->ConditionEndSync      = n_ConditionSyncPLAN;
    pdb_RuptPLAN->c_Separ               = SEPARATEUR;

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
retour:
==============================================================================*/
int n_ActionLignePLAN(char **tpsz_InRec_CALL, char **tpsz_InRec_PLAN)
{
    int acy = atoi(tpsz_InRec_PLAN[PLAN_ACY_NF]);

    DEBUT_FCT("n_ActionLignePLAN");

    if (n_CSU_PLAN_Index >= T_MAX_CSU - 3)
        RETURN_VAL(errorMsg("T_MAX_CSU Overflow. Error in ESTC5000.\n"));

    if (acy < Kn_annee - 4 || acy > Kn_annee)
        RETURN_VAL(OK);

// GAAP 2
    tpdb_CSU_PLAN[n_CSU_PLAN_Index].n_ACY       = acy;
    tpdb_CSU_PLAN[n_CSU_PLAN_Index].n_DETTRNCOD = atoi(tpsz_InRec_PLAN[PLAN_DETTRNCOD_CF]);
    tpdb_CSU_PLAN[n_CSU_PLAN_Index].c_GAAP      = '2';
    strncpy(tpdb_CSU_PLAN[n_CSU_PLAN_Index].sz_CUR, tpsz_InRec_PLAN[PLAN_CUR_CF], 3);
    tpdb_CSU_PLAN[n_CSU_PLAN_Index].sz_CUR[3]   = '\0';
    if (tpsz_InRec_PLAN[PLAN_ACMTRS_NT][0] == '2' || tpsz_InRec_PLAN[PLAN_ACMTRS_NT][0] == '4')
        tpdb_CSU_PLAN[n_CSU_PLAN_Index].d_MNT       = atof(tpsz_InRec_PLAN[PLAN_PRMNT_M]) * -1;
    else
        tpdb_CSU_PLAN[n_CSU_PLAN_Index].d_MNT       = atof(tpsz_InRec_PLAN[PLAN_PRMNT_M]);
    ++n_CSU_PLAN_Index;

// GAAP 3
    tpdb_CSU_PLAN[n_CSU_PLAN_Index].n_ACY       = acy;
    tpdb_CSU_PLAN[n_CSU_PLAN_Index].n_DETTRNCOD = atoi(tpsz_InRec_PLAN[PLAN_DETTRNCOD_CF]);
    tpdb_CSU_PLAN[n_CSU_PLAN_Index].c_GAAP      = '3';
    strncpy(tpdb_CSU_PLAN[n_CSU_PLAN_Index].sz_CUR, tpsz_InRec_PLAN[PLAN_CUR_CF], 3);
    tpdb_CSU_PLAN[n_CSU_PLAN_Index].sz_CUR[3]   = '\0';
    if (tpsz_InRec_PLAN[PLAN_ACMTRS_NT][0] == '2' || tpsz_InRec_PLAN[PLAN_ACMTRS_NT][0] == '4')
        tpdb_CSU_PLAN[n_CSU_PLAN_Index].d_MNT       = atof(tpsz_InRec_PLAN[PLAN_PR3MNT_M]) * -1;
    else
        tpdb_CSU_PLAN[n_CSU_PLAN_Index].d_MNT       = atof(tpsz_InRec_PLAN[PLAN_PR3MNT_M]);
    ++n_CSU_PLAN_Index;

// GAAP 4
    tpdb_CSU_PLAN[n_CSU_PLAN_Index].n_ACY       = acy;
    tpdb_CSU_PLAN[n_CSU_PLAN_Index].n_DETTRNCOD = atoi(tpsz_InRec_PLAN[PLAN_DETTRNCOD_CF]);
    tpdb_CSU_PLAN[n_CSU_PLAN_Index].c_GAAP      = '4';
    strncpy(tpdb_CSU_PLAN[n_CSU_PLAN_Index].sz_CUR, tpsz_InRec_PLAN[PLAN_CUR_CF], 3);
    tpdb_CSU_PLAN[n_CSU_PLAN_Index].sz_CUR[3]   = '\0';
    if (tpsz_InRec_PLAN[PLAN_ACMTRS_NT][0] == '2' || tpsz_InRec_PLAN[PLAN_ACMTRS_NT][0] == '4')
        tpdb_CSU_PLAN[n_CSU_PLAN_Index].d_MNT       = atof(tpsz_InRec_PLAN[PLAN_PR4MNT_M]) * -1;
    else
        tpdb_CSU_PLAN[n_CSU_PLAN_Index].d_MNT       = atof(tpsz_InRec_PLAN[PLAN_PR4MNT_M]);

    strncpy(acmtrs, tpsz_InRec_PLAN[PLAN_ACMTRS_NT], 4);//[005]
    ttpsz_DetailLine[0][DETAIL_ACMTRS_NT] = acmtrs;//[005]
    ttpsz_DetailLine[1][DETAIL_ACMTRS_NT] = acmtrs;//[005]

    ++n_CSU_PLAN_Index;

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
retour:
==============================================================================*/
int n_ConditionSyncPLAN(char **tpsz_InRec_CALL, char **tpsz_InRec_PLAN)
{
    int     ret = 0;
    DEBUT_FCT("n_ConditionRuptPLAN");

    if ((ret = strcmp(tpsz_InRec_CALL[CALL_SSD_CF], tpsz_InRec_PLAN[PLAN_SSD_CF])) != 0) RETURN_VAL(ERR);
    if ((ret = strcmp(tpsz_InRec_CALL[CALL_CTR_NF], tpsz_InRec_PLAN[PLAN_CTR_NF])) != 0) RETURN_VAL(ERR);
    if ((ret = strcmp(tpsz_InRec_CALL[CALL_SEC_NF], tpsz_InRec_PLAN[PLAN_SEC_NF])) != 0) RETURN_VAL(ERR);
    if ((ret = strcmp(tpsz_InRec_CALL[CALL_UWY_NF], tpsz_InRec_PLAN[PLAN_UWY_NF])) != 0) RETURN_VAL(ERR);

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
retour:
==============================================================================*/
double conv_montant(char *cur_from, char *cur_to, double mnt)
{
    int     i;
    double  d_ratio_from = 0.0;
    double  d_ratio_to   = 0.0;

    DEBUT_FCT("conv_montant");

    if (strcmp(cur_from, cur_to) == 0)
        return (mnt);

    for (i = 0; * (pdb_FAVERATE[i].sz_CUR) != '0'; ++i)
    {
        if (strcmp(pdb_FAVERATE[i].sz_CUR, cur_from) == 0)
            d_ratio_from = pdb_FAVERATE[i].d_ratio;

        if (strcmp(pdb_FAVERATE[i].sz_CUR, cur_to) == 0)
            d_ratio_to = pdb_FAVERATE[i].d_ratio;

        if (d_ratio_to != 0.0 && d_ratio_from != 0.0)
            break;
    }

    if (d_ratio_to == 0.0)
        errorMsg("Division par 0 !");

    mnt = mnt * d_ratio_from / d_ratio_to;

    return (mnt);
}


/*==============================================================================
objet :
retour:
==============================================================================*/
int rech_cur_mnt(T_CSU_TEMP *tab, int acy, int dettrncod, char gaap, char *cur, double *mnt)
{
    int i;

    DEBUT_FCT("rech_cur_mnt");

    for (i = 0; tab[i].n_ACY != 0; ++i)
    {
        if (tab[i].n_ACY == acy &&
            tab[i].n_DETTRNCOD == dettrncod &&
            tab[i].c_GAAP == gaap)
        {
            strncpy(cur, tab[i].sz_CUR, 3);
            cur[3] = '\0';
            *mnt = tab[i].d_MNT;

            RETURN_VAL(OK);
        }
    }
    strcpy(cur, "EUR");
    *mnt = 0.0;
    RETURN_VAL(OK);
}

/*==============================================================================
objet :
retour:
==============================================================================*/
int rech_cur_mnt_MVT(T_MVT *tab, int acy, int dettrncod, char gaap, char *cur, double *mnt, char *date, char is_end)
{
    int     i;

    DEBUT_FCT("rech_cur_mnt_MVT");

    for (i = 0; i < Kn_NbLigMVT; ++i)
    {
        if (tab[i].ACY == acy &&
            tab[i].DETTRNCOD == dettrncod &&
            tab[i].GAAP == gaap &&
            (is_end == END ? strcmp(date, tab[i].CRE_D) >= 0 : strcmp(date, tab[i].CRE_D) > 0)) //[003]
        {
            strncpy(cur, tab[i].CUR, 3);
            cur[3] = '\0';
            *mnt = tab[i].MNT;

            RETURN_VAL(OK);
        }
    }
    strcpy(cur, "EUR");
    *mnt = 0.0;
    RETURN_VAL(OK);
}



/*==============================================================================
objet :
retour:
==============================================================================*/
int charger_FAVERATE(FILE *Kp_InputFAVERATE)
{
    int     ssd     = 0;
    int     i       = 0;
    char    *bd_Lu  = NULL;
    size_t  len     = 0;

    DEBUT_FCT("charger_FAVERATE");

    while (i < T_MAX_CUR)
    {
        strcpy(pdb_FAVERATE[i].sz_CUR, "000");
        pdb_FAVERATE[i].d_ratio = 0.0;
        ++i;
    }

    while (getline(&bd_Lu, &len, Kp_InputFAVERATE) != -1)
    {
        if (ssd == 0)
            ssd = atoi(bd_Lu);

        if (ssd == atoi(bd_Lu))
        {
            if (Kn_NbLigPilot >= T_MAX_CUR)
                errorMsg("Valeur T_MAX_CUR atteinte ! Modifier ESTC5000.h !");
            deconcat_FAVERATE(bd_Lu, &pdb_FAVERATE[Kn_NbLigPilot]);
            ++Kn_NbLigPilot;
        }
        else
            RETURN_VAL(OK);
    }
    if (bd_Lu)
        free(bd_Lu);

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
retour:
==============================================================================*/
void deconcat_FAVERATE(char *line, T_FAVERATE_RATIO *allCur)
{
    int i = 0;
    int begin = 0;
    int nb_tild = 0;

    while (line[i] != '\0')
    {
        if (line[i] == SEPARATEUR)
        {
            line[i] = '\0';
            if (nb_tild == 1)
                strncpy(allCur->sz_CUR, line + begin, 3);
            ++nb_tild;
            begin = i + 1;
        }
        ++i;
    }
    if (nb_tild == 3)
        allCur->d_ratio = atof(line + begin);
}


/*==============================================================================
objet :     Fonction d'affichage de message d'erreur
retour:     ERR --> permet l'arret du programme
==============================================================================*/
int errorMsg(char *error)   // error : message d'erreur à écrire
{
    char    MsgAno[100];    /* message d'anomalie */

    sprintf(MsgAno, error);
    n_WriteAno(MsgAno);

    RETURN_VAL(ERR);
}
