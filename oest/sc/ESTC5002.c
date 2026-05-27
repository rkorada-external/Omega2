/*==============================================================================
Nom de l'application          : Life Estimates Closing Multi-GAAP
Nom du source                 : ESTC5002.c
Révision                      : $Revision: 1.0 $
Date de création              : 29/07/2015
Auteur                        : Julien FONTANA
References des specifications : EST38 - EST52
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
    Intra day job to convert currency based on ESB currency
------------------------------------------------------------------------------
historique des modifications :

[001]   JFO     29/07/2015  spot29095: Création du fichier
[002]   MBO     29/02/2016  spot:30266 (pas de spira) correction warning Makefile
[003]   MBO     22/03/2016  spot:30352:spira:44672 : ajout des millisecondes dans END_D, START_D, CRE_D
[004]   MBO     07/06/2016  spot:30691:spira:43333 : ajout du champs QUARTER_B
=============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include "struct.h"
#include "estserv.h"
#include <ESTC5000.h>

/*----------------------*/
/* Variables de travail */
/*----------------------*/

#define NB_PERIOD       2
#define NB_GAAP         3
#define NB_ACY          5
#define NB_GLOBAL_LINE 30
#define NB_ELEM        30
#define MAX_ELEM_SIZE  500
#define MNT_ZERO       "0.000"

FILE            *Kp_OutputFilGLOBAL;    /* Pointeur sur le fichier en sortie */

T_RUPTURE_VAR   pbd_RuptDetail;
T_RUPTURE_VAR   pbd_RuptIDCall;
T_RUPTURE_VAR   pbd_RuptSUBTRSBASE;

T_ID_CALL       st_ID_CALL[T_MAX_CALL];
T_SUBTRSB       st_SUBTRSBASE[T_MAX_BASE];


int             Kn_ligne_Period  = 0;
int             Kn_ligne_Gaap    = 0;
int             Kn_ligne_ACY     = 0;
int             Kn_ligne_CALL    = 0;
int             Kn_ligne_SUBTRSB = 0;
int             Kn_id_cf         = 0;
int             Kn_year          = 0;

char            Ksz_TXCHA[9]     = {'\0'};
char            Ksz_DLINV[9]     = {'\0'};
int             Ksz_BALSHYEA     = 0;

char            global_lines[NB_PERIOD][NB_GAAP][NB_ACY][NB_ELEM][MAX_ELEM_SIZE];

/*------------------*/
/*    Prototypes    */
/*------------------*/

int n_InitRuptDetail(T_RUPTURE_VAR *pbd_RuptDetail);
int ActionLigneDetail(char **pbd_RuptDetail);
int ActionFirstDetail(char **pbd_RuptDetail);
int ActionLastDetail(char **pbd_RuptDetail);
int ConditionRuptDetail(char **tpsz_InRec_Detail, char **tpsz_InRec);

int n_InitRuptIDCall(T_RUPTURE_VAR *pbd_RuptIDCall);
int ActionLigneIDCall(char **pbd_RuptIDCall);

int n_InitRuptSUBTRSBASE(T_RUPTURE_VAR *pbd_RuptSUBTRSBASE);
int ActionLigneSUBTRSBASE(char **pbd_RuptSUBTRSBASE);
int is_in_base(char *acmtrs, char *dettrncod);
int index_ref_id(int detail_id_cf);
void add_char_float(char *result, char *value1);
void sub_char_float(char *result, char *value_to_add); //[002] correction warning Makefile
void diff_char_float(char *result, char *value1, char *value2);
int errorMsg(char *error);


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

    // Derniere modif du taux de change
    sprintf(Ksz_TXCHA, "%s", psz_GetCharArgv(1));
    // Derniere date d'inventaire
    sprintf(Ksz_DLINV, "%s", psz_GetCharArgv(2));

    Ksz_BALSHYEA = atoi(psz_GetCharArgv(3));

    if (n_OpenFileAppl("ESTC5002_O1", "wt", &Kp_OutputFilGLOBAL) == ERR)        ExitPgm(ERR_XX, "");

    if (n_InitRuptIDCall(&pbd_RuptIDCall) == ERR)                               ExitPgm(ERR_XX, "");
    if (n_InitRuptSUBTRSBASE(&pbd_RuptSUBTRSBASE) == ERR)                       ExitPgm(ERR_XX, "");
    if (n_InitRuptDetail(&pbd_RuptDetail) == ERR)                               ExitPgm(ERR_XX, "");

    /* Remplissages des structures */
    if (n_ProcessingRuptureVar(&pbd_RuptIDCall) == ERR)                         ExitPgm(ERR_XX, "");
    if (n_ProcessingRuptureVar(&pbd_RuptSUBTRSBASE) == ERR)                     ExitPgm(ERR_XX, "");

    /* Lancement du traitement */
    if (n_ProcessingRuptureVar(&pbd_RuptDetail) == ERR)                         ExitPgm(ERR_XX, "");

    /* Fermeture de tout les fichiers ouverts */
    if (n_CloseFileAppl("ESTC5002_O1", &Kp_OutputFilGLOBAL) == ERR)             ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC5002_I1", &pbd_RuptIDCall.pf_InputFil) == ERR)     ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC5002_I2", &pbd_RuptSUBTRSBASE.pf_InputFil) == ERR) ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC5002_I3", &pbd_RuptDetail.pf_InputFil) == ERR)     ExitPgm(ERR_XX, "");

    if (n_EndPgm() == ERR)                                                      ExitPgm(ERR_XX, "");

    exit(OK);
}


/*==============================================================================
objet :     Initialisation de la structure de rupture LIFEST (dernier mvt)
retour:     OK
==============================================================================*/
int n_InitRuptDetail(T_RUPTURE_VAR *pbd_RuptDetail)
{
    DEBUT_FCT("n_InitRuptDetail");

    memset(pbd_RuptDetail, 0, sizeof(T_RUPTURE_SYNC_VAR));

    // Ouverture de la table d'appel
    if (n_OpenFileAppl("ESTC5002_I3", "rt", &(pbd_RuptDetail->pf_InputFil)) == ERR)
        RETURN_VAL(errorMsg("Lifest openning failed. Error in ESTC5002.\n"));

    pbd_RuptDetail->n_NbRupture           = 1;
    pbd_RuptDetail->n_ConditionRupture[0] = ConditionRuptDetail;
    pbd_RuptDetail->n_ActionFirst[0]      = ActionFirstDetail;
    pbd_RuptDetail->n_ActionLast[0]       = ActionLastDetail;
    pbd_RuptDetail->n_ActionLigne         = ActionLigneDetail;
    pbd_RuptDetail->c_Separ               = SEPARATEUR;

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
retour:
==============================================================================*/
int ActionFirstDetail(char **pbd_RuptDetail)
{
    int i;
    DEBUT_FCT("ActionFirstDetail");

    if ((Kn_id_cf = index_ref_id(atoi(pbd_RuptDetail[DETAIL_ID_CF]))) == -1)
        RETURN_VAL(errorMsg("Unable to find reference id. Error in ESTC5002.\n"));

    for (Kn_ligne_Period = 0; Kn_ligne_Period < NB_PERIOD; ++Kn_ligne_Period)
        for (Kn_ligne_Gaap = 0; Kn_ligne_Gaap < NB_GAAP; ++Kn_ligne_Gaap)
            for (Kn_ligne_ACY = 0; Kn_ligne_ACY < NB_ACY; ++Kn_ligne_ACY)
            {
                for (i = 0; i < NB_ELEM; ++i)
                {
                    memset(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][i], 0, MAX_ELEM_SIZE);
                }
                strcpy(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_PREMLSTAMT_M], MNT_ZERO);
                strcpy(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_PREMAMT_M], MNT_ZERO);
                strcpy(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFPREMAMT_M], MNT_ZERO);
                strcpy(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_PLNPREMAMT_M], MNT_ZERO);
                strcpy(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_TECRESLSTAMT_M], MNT_ZERO);
                strcpy(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_TECRESAMT_M], MNT_ZERO);
                strcpy(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFTECRESAMT_M], MNT_ZERO);
                strcpy(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_PLNTECRESAMT_M], MNT_ZERO);
                strcpy(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_FINTECCOMLSTAMT_M], MNT_ZERO);
                strcpy(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_FINTECCOMAMT_M], MNT_ZERO);
                strcpy(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFFINTECCOMAMT_M], MNT_ZERO);
                strcpy(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_PLNFINTECCOMAMT_M], MNT_ZERO);
            }

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
retour:
==============================================================================*/
int ActionLigneDetail(char **pbd_RuptDetail)
{
    int     Kn_ligne_Period;
    int     detail_acy = 0;
    char    buff[20] = {'\0'};
    DEBUT_FCT("ActionLigneDetail");

    detail_acy = atoi(pbd_RuptDetail[DETAIL_ACY_NF]);
    Kn_ligne_Period = pbd_RuptDetail[DETAIL_PERIOD_NT][0] - '1';

    // printf("Ksz_BALSHYEA[%d] - detail_acy[%d] => %d\n",
    //         Ksz_BALSHYEA,      detail_acy,       Ksz_BALSHYEA - detail_acy);

    if (Ksz_BALSHYEA - detail_acy == 0)
        Kn_ligne_ACY = 0;
    else if (Ksz_BALSHYEA - detail_acy == 1)
        Kn_ligne_ACY = 1;
    else if (Ksz_BALSHYEA - detail_acy == 2)
        Kn_ligne_ACY = 2;
    else if (Ksz_BALSHYEA - detail_acy == 3)
        Kn_ligne_ACY = 3;
    else if (Ksz_BALSHYEA - detail_acy == 4)
        Kn_ligne_ACY = 4;
    else
    {
        // RETURN_VAL(errorMsg("Abnormal Year. Error in ESTC5002.\n"));
        RETURN_VAL(OK);
    }

    for (Kn_ligne_Gaap = 0; Kn_ligne_Gaap < NB_GAAP; ++Kn_ligne_Gaap)
    {
        sprintf(buff, "%d", st_ID_CALL[Kn_id_cf].ID_CF);
        strcpy(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_ID_CF], buff);

        global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_UPDTYP_CT][0]        = st_ID_CALL[Kn_id_cf].UPDTYP_CT;
        strcpy(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_SSD_CF]       , st_ID_CALL[Kn_id_cf].SSD_CF);
        strcpy(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_ESB_CF]       , st_ID_CALL[Kn_id_cf].ESB_CF);
        strcpy(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_LSTUPDUSR_CF] , st_ID_CALL[Kn_id_cf].LSTUPDUSR_CF);

        global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_GAAP_NT][0]          = Kn_ligne_Gaap   + '2';
        global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_PERIOD_NT][0]        = Kn_ligne_Period + '1';

        strcpy(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_ACY_NF]       , pbd_RuptDetail[DETAIL_ACY_NF]);
        strcpy(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_CUR_CF]       , pbd_RuptDetail[DETAIL_CUR_CF]);

        strcpy(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_LSTUPDCUR_D]  , Ksz_TXCHA);
        strcpy(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_LSTUSRUPD_D]  , Ksz_DLINV);
        strcpy(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_END_D]        , st_ID_CALL[Kn_id_cf].END_D);

        strcpy(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_QUARTER_B]    , pbd_RuptDetail[DETAIL_QUARTER_B]);

        switch (Kn_ligne_Gaap) {

        // gaap 2
        case 0:
            if (is_in_base("1010", pbd_RuptDetail[DETAIL_DETTRNCOD_CF]))
            {
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_PREMLSTAMT_M] , pbd_RuptDetail[DETAIL_PREVIFRSAMT_M]);
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_PREMAMT_M]    , pbd_RuptDetail[DETAIL_IFRSAMT_M]);
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFPREMAMT_M], pbd_RuptDetail[DETAIL_IFRSAMT_M]);
                sub_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFPREMAMT_M], pbd_RuptDetail[DETAIL_PREVIFRSAMT_M]);
                //diff_char_float(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFPREMAMT_M], pbd_RuptDetail[DETAIL_IFRSAMT_M], pbd_RuptDetail[DETAIL_PREVIFRSAMT_M]);
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_PLNPREMAMT_M] , pbd_RuptDetail[DETAIL_PLNIFRSAMT_M]);
            }
            if (is_in_base("1400", pbd_RuptDetail[DETAIL_DETTRNCOD_CF]))
            {
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_TECRESLSTAMT_M] , pbd_RuptDetail[DETAIL_PREVIFRSAMT_M]);
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_TECRESAMT_M]    , pbd_RuptDetail[DETAIL_IFRSAMT_M]);
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFTECRESAMT_M], pbd_RuptDetail[DETAIL_IFRSAMT_M]);
                sub_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFTECRESAMT_M], pbd_RuptDetail[DETAIL_PREVIFRSAMT_M]);
                //diff_char_float(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFTECRESAMT_M], pbd_RuptDetail[DETAIL_IFRSAMT_M], pbd_RuptDetail[DETAIL_PREVIFRSAMT_M]);
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_PLNTECRESAMT_M] , pbd_RuptDetail[DETAIL_PLNIFRSAMT_M]);
            }
            if (is_in_base("1460", pbd_RuptDetail[DETAIL_DETTRNCOD_CF]))
            {
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_FINTECCOMLSTAMT_M] , pbd_RuptDetail[DETAIL_PREVIFRSAMT_M]);
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_FINTECCOMAMT_M]    , pbd_RuptDetail[DETAIL_IFRSAMT_M]);
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFFINTECCOMAMT_M], pbd_RuptDetail[DETAIL_IFRSAMT_M]);
                sub_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFFINTECCOMAMT_M], pbd_RuptDetail[DETAIL_PREVIFRSAMT_M]);
                //diff_char_float(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFFINTECCOMAMT_M], pbd_RuptDetail[DETAIL_IFRSAMT_M], pbd_RuptDetail[DETAIL_PREVIFRSAMT_M]);
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_PLNFINTECCOMAMT_M] , pbd_RuptDetail[DETAIL_PLNIFRSAMT_M]);
            }
            break;

        // gaap 3
        case 1:
            if (is_in_base("1010", pbd_RuptDetail[DETAIL_DETTRNCOD_CF]))
            {
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_PREMLSTAMT_M] , pbd_RuptDetail[DETAIL_PREVPRNTAMT_M]);
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_PREMAMT_M]    , pbd_RuptDetail[DETAIL_PRNTAMT_M]);
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFPREMAMT_M], pbd_RuptDetail[DETAIL_PRNTAMT_M]);
                sub_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFPREMAMT_M], pbd_RuptDetail[DETAIL_PREVPRNTAMT_M]);
                //diff_char_float(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFPREMAMT_M], pbd_RuptDetail[DETAIL_PRNTAMT_M], pbd_RuptDetail[DETAIL_PREVPRNTAMT_M]);
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_PLNPREMAMT_M] , pbd_RuptDetail[DETAIL_PLNPRNTAMT_M]);
            }
            if (is_in_base("1400", pbd_RuptDetail[DETAIL_DETTRNCOD_CF]))
            {
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_TECRESLSTAMT_M] , pbd_RuptDetail[DETAIL_PREVPRNTAMT_M]);
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_TECRESAMT_M]    , pbd_RuptDetail[DETAIL_PRNTAMT_M]);
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFTECRESAMT_M], pbd_RuptDetail[DETAIL_PRNTAMT_M]);
                sub_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFTECRESAMT_M], pbd_RuptDetail[DETAIL_PREVPRNTAMT_M]);
                //diff_char_float(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFTECRESAMT_M], pbd_RuptDetail[DETAIL_PRNTAMT_M], pbd_RuptDetail[DETAIL_PREVPRNTAMT_M]);
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_PLNTECRESAMT_M] , pbd_RuptDetail[DETAIL_PLNPRNTAMT_M]);
            }
            if (is_in_base("1460", pbd_RuptDetail[DETAIL_DETTRNCOD_CF]))
            {
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_FINTECCOMLSTAMT_M] , pbd_RuptDetail[DETAIL_PREVPRNTAMT_M]);
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_FINTECCOMAMT_M]    , pbd_RuptDetail[DETAIL_PRNTAMT_M]);
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFFINTECCOMAMT_M], pbd_RuptDetail[DETAIL_PRNTAMT_M]);
                sub_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFFINTECCOMAMT_M], pbd_RuptDetail[DETAIL_PREVPRNTAMT_M]);
                //diff_char_float(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFFINTECCOMAMT_M], pbd_RuptDetail[DETAIL_PRNTAMT_M], pbd_RuptDetail[DETAIL_PREVPRNTAMT_M]);
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_PLNFINTECCOMAMT_M] , pbd_RuptDetail[DETAIL_PLNPRNTAMT_M]);
            }
            break;

        // gaap 4
        case 2:
            if (is_in_base("1010", pbd_RuptDetail[DETAIL_DETTRNCOD_CF]))
            {
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_PREMLSTAMT_M] , pbd_RuptDetail[DETAIL_PREVLOCALAMT_M]);
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_PREMAMT_M]    , pbd_RuptDetail[DETAIL_LOCALAMT_M]);
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFPREMAMT_M], pbd_RuptDetail[DETAIL_LOCALAMT_M]);
                sub_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFPREMAMT_M], pbd_RuptDetail[DETAIL_PREVLOCALAMT_M]);
                //diff_char_float(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFPREMAMT_M], pbd_RuptDetail[DETAIL_LOCALAMT_M], pbd_RuptDetail[DETAIL_PREVLOCALAMT_M]);
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_PLNPREMAMT_M] , pbd_RuptDetail[DETAIL_PLNLOCALAMT_M]);
            }
            if (is_in_base("1400", pbd_RuptDetail[DETAIL_DETTRNCOD_CF]))
            {
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_TECRESLSTAMT_M] , pbd_RuptDetail[DETAIL_PREVLOCALAMT_M]);
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_TECRESAMT_M]    , pbd_RuptDetail[DETAIL_LOCALAMT_M]);
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFTECRESAMT_M], pbd_RuptDetail[DETAIL_LOCALAMT_M]);
                sub_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFTECRESAMT_M], pbd_RuptDetail[DETAIL_PREVLOCALAMT_M]);
                //diff_char_float(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFTECRESAMT_M], pbd_RuptDetail[DETAIL_LOCALAMT_M], pbd_RuptDetail[DETAIL_PREVLOCALAMT_M]);
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_PLNTECRESAMT_M] , pbd_RuptDetail[DETAIL_PLNLOCALAMT_M]);
            }
            if (is_in_base("1460", pbd_RuptDetail[DETAIL_DETTRNCOD_CF]))
            {
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_FINTECCOMLSTAMT_M] , pbd_RuptDetail[DETAIL_PREVLOCALAMT_M]);
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_FINTECCOMAMT_M]    , pbd_RuptDetail[DETAIL_LOCALAMT_M]);
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFFINTECCOMAMT_M], pbd_RuptDetail[DETAIL_LOCALAMT_M]);
                sub_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFFINTECCOMAMT_M], pbd_RuptDetail[DETAIL_PREVLOCALAMT_M]);
                //diff_char_float(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFFINTECCOMAMT_M], pbd_RuptDetail[DETAIL_LOCALAMT_M], pbd_RuptDetail[DETAIL_PREVLOCALAMT_M]);
                add_char_float (global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_PLNFINTECCOMAMT_M] , pbd_RuptDetail[DETAIL_PLNLOCALAMT_M]);
            }
            break;

        default:
            RETURN_VAL(errorMsg("Abnormal Gaap. Error in ESTC5002.\n"));
            break;
        }

    }

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
retour:
==============================================================================*/
int ActionLastDetail(char **pbd_RuptDetail)
{
    // char global_line[25][20];

    DEBUT_FCT("ActionLastDetail");

    for (Kn_ligne_Period = 0; Kn_ligne_Period < NB_PERIOD; ++Kn_ligne_Period)
    {
        for (Kn_ligne_Gaap = 0; Kn_ligne_Gaap < NB_GAAP; ++Kn_ligne_Gaap)
        {
            for (Kn_ligne_ACY = 0; Kn_ligne_ACY < NB_ACY; ++Kn_ligne_ACY)
            {
                if (strcmp(global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_ID_CF], "") != 0)
                {
                    fprintf(Kp_OutputFilGLOBAL, "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s\n", //[004]
                            global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_ID_CF],
                            global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_UPDTYP_CT],
                            global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_SSD_CF],
                            global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_ESB_CF],
                            global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_LSTUPDUSR_CF],
                            global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_GAAP_NT],
                            global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_PERIOD_NT],
                            global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_ACY_NF],
                            global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_CUR_CF],
                            global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_PREMLSTAMT_M],
                            global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_PREMAMT_M],
                            global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFPREMAMT_M],
                            global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_PLNPREMAMT_M],
                            global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_TECRESLSTAMT_M],
                            global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_TECRESAMT_M],
                            global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFTECRESAMT_M],
                            global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_PLNTECRESAMT_M],
                            global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_FINTECCOMLSTAMT_M],
                            global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_FINTECCOMAMT_M],
                            global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_DIFFFINTECCOMAMT_M],
                            global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_PLNFINTECCOMAMT_M],
                            global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_LSTUPDCUR_D],
                            global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_LSTUSRUPD_D],
                            global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_END_D],
                            global_lines[Kn_ligne_Period][Kn_ligne_Gaap][Kn_ligne_ACY][GLOBAL_QUARTER_B]); //[004]
                }
            }
        }
    }

    RETURN_VAL(OK);
}

/*==============================================================================
objet :
retour:
==============================================================================*/
int ConditionRuptDetail(char **ptd_InRec, char **ptd_InRec_Cur)
{
    int     ret = 0;
    DEBUT_FCT("n_ConditionSyncDetail");

    if ((ret = strcmp(ptd_InRec[DETAIL_ID_CF], ptd_InRec_Cur[DETAIL_ID_CF])) != 0) RETURN_VAL(ret);

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
retour:     OK
==============================================================================*/
int n_InitRuptIDCall(T_RUPTURE_VAR *pbd_RuptIDCall)
{
    DEBUT_FCT("n_InitRuptIDCall");

    memset(pbd_RuptIDCall, 0, sizeof(T_RUPTURE_SYNC_VAR));

    // Ouverture de la table d'appel
    if (n_OpenFileAppl("ESTC5002_I1", "rt", &(pbd_RuptIDCall->pf_InputFil)) == ERR)
        RETURN_VAL(errorMsg("Lifest openning failed. Error in ESTC5002.\n"));

    pbd_RuptIDCall->n_NbRupture   = 0;
    pbd_RuptIDCall->n_ActionLigne = ActionLigneIDCall;
    pbd_RuptIDCall->c_Separ       = SEPARATEUR;

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
retour:
==============================================================================*/
int ActionLigneIDCall(char **pbd_RuptIDAYCall)
{
    DEBUT_FCT("ActionLigneIDCall");

    if (Kn_ligne_CALL >= T_MAX_CALL)
        ExitPgm(ERR_XX, "T_MAX_CALL capacity exceeded");

    st_ID_CALL[Kn_ligne_CALL].ID_CF          = atoi(pbd_RuptIDAYCall[CALL_ID_CF]);
    st_ID_CALL[Kn_ligne_CALL].UPDTYP_CT          = *pbd_RuptIDAYCall[CALL_UPDTYP_CT];
    strncpy(st_ID_CALL[Kn_ligne_CALL].SSD_CF,        pbd_RuptIDAYCall[CALL_SSD_CF],         3);
    strncpy(st_ID_CALL[Kn_ligne_CALL].ESB_CF,        pbd_RuptIDAYCall[CALL_ESB_CF],         3);
    strncpy(st_ID_CALL[Kn_ligne_CALL].LSTUPDUSR_CF,  pbd_RuptIDAYCall[CALL_LSTUPDUSR_CF],   9);
    strncpy(st_ID_CALL[Kn_ligne_CALL].END_D,         pbd_RuptIDAYCall[CALL_END_D],          22); //[003]

    ++Kn_ligne_CALL;

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
retour:     OK
==============================================================================*/
int n_InitRuptSUBTRSBASE(T_RUPTURE_VAR *pbd_RuptSUBTRSBASE)
{
    DEBUT_FCT("n_InitRuptSUBTRSBASE");

    memset(pbd_RuptSUBTRSBASE, 0, sizeof(T_RUPTURE_SYNC_VAR));

    // Ouverture de la table d'appel
    if (n_OpenFileAppl("ESTC5002_I2", "rt", &(pbd_RuptSUBTRSBASE->pf_InputFil)) == ERR)
        RETURN_VAL(errorMsg("SUBTRSBASE openning failed. Error in ESTC5002.\n"));

    pbd_RuptSUBTRSBASE->n_NbRupture   = 0;
    pbd_RuptSUBTRSBASE->n_ActionLigne = ActionLigneSUBTRSBASE;
    pbd_RuptSUBTRSBASE->c_Separ       = SEPARATEUR;

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
retour:
==============================================================================*/
int ActionLigneSUBTRSBASE(char **pbd_RuptSUBTRSBASE)
{

    DEBUT_FCT("ActionLigneSUBTRSBASE");

    strcpy(st_SUBTRSBASE[Kn_ligne_SUBTRSB].ACMTRS_NT,    pbd_RuptSUBTRSBASE[FSUBTRSBASE_ACMTRS_NT]);
    strcpy(st_SUBTRSBASE[Kn_ligne_SUBTRSB].DETTRNCOD_CF, pbd_RuptSUBTRSBASE[FSUBTRSBASE_DETTRNCOD_CF]);

    ++Kn_ligne_SUBTRSB;

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
retour:
==============================================================================*/
int is_in_base(char *acmtrs, char *dettrncod)
{
    int i;
    DEBUT_FCT("is_in_base");

    for (i = 0; i < Kn_ligne_SUBTRSB; ++i)
    {
        if (strcmp(acmtrs, st_SUBTRSBASE[i].ACMTRS_NT) == 0 && strcmp(dettrncod, st_SUBTRSBASE[i].DETTRNCOD_CF) == 0)
        {
            return 1;
        }
    }
    return 0;
}


/*==============================================================================
objet :
retour:
==============================================================================*/
int index_ref_id(int detail_id_cf)
{
    int i;
    for (i = 0; i < Kn_ligne_CALL; ++i)
    {
        if (st_ID_CALL[i].ID_CF == detail_id_cf)
        {
            return i;
        }
    }
    return -1;
}


/*==============================================================================
objet :
retour:
==============================================================================*/
void add_char_float(char *result, char *value_to_add)
{
    char buff[25] = {'\0'};
    DEBUT_FCT("add_char_float");

    sprintf(buff, "%-.3f", atof(result) + atof(value_to_add));
    strcpy(result, buff);
}

/*==============================================================================
objet :
retour:
==============================================================================*/
void sub_char_float(char *result, char *value_to_add)
{
    char buff[25] = {'\0'};
    DEBUT_FCT("sub_char_float");

    sprintf(buff, "%-.3f", atof(result) - atof(value_to_add));
    strcpy(result, buff);
}

/*==============================================================================
objet :
retour:
==============================================================================*/
void diff_char_float(char *result, char *value1, char *value2)
{
    char buff[25] = {'\0'};
    DEBUT_FCT("diff_char_float");

    sprintf(buff, "%-.3f", atof(value1) - atof(value2));
    strcpy(result, buff);
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
