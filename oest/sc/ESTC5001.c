/*==============================================================================
Nom de l'application          : Life Estimates Closing Multi-GAAP
Nom du source                 : ESTC5001.c
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

[001]     JFO     29/07/2015  spot29095: Création du fichier
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

FILE             *Kp_OutputFilDetail; /* Pointeur sur le fichier en sortie*/
FILE             *Kp_InputFAVERATE;   /* Input File from FCURQUOT         */
FILE             *Kp_TESB;            /* Input File from TESB             */

T_RUPTURE_VAR    pbd_RuptDetail;      /* Structure contenant le Detail    */

T_ESB            Kbd_Esb[NB_ESB_MAX];

T_FAVERATE_RATIO pdb_FAVERATE[T_MAX_CUR];

int              Kn_NbLigPilot = 0;

char             quarter[3];

/*------------------*/
/*    Prototypes    */
/*------------------*/

int n_InitRuptDetail(T_RUPTURE_VAR *pbd_RuptDetail);
int n_ActionLigneDetail(char **pbd_RuptDetail);

double conv_montant(char *cur_from, char *cur_to, double mnt);
int    charger_FAVERATE(FILE *Kp_InputFAVERATE);
void   deconcat_FAVERATE(char *line, T_FAVERATE_RATIO *allCur);
int    recherche_cur_ref(int ssd, int esb);
char   *extract_btwn_tild(char *line, int nb_tild);
int    n_ChargEsb(FILE *Kp_TESB);
int    errorMsg(char *error);


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

    sprintf(quarter, "%s", psz_GetCharArgv(1));

    if (n_BeginPgm(argc, argv) == ERR)                                      ExitPgm(ERR_XX, "");

    if (n_OpenFileAppl("ESTC5001_O1", "wt", &Kp_OutputFilDetail) == ERR)    ExitPgm(ERR_XX, "");
    if (n_OpenFileAppl("ESTC5001_I2", "rb", &Kp_TESB) == ERR)               ExitPgm(ERR_XX, "");
    if (n_OpenFileAppl("ESTC5001_I3", "rt", &Kp_InputFAVERATE) == ERR)      ExitPgm(ERR_XX, "");

    if (n_InitRuptDetail(&pbd_RuptDetail) == ERR)                           ExitPgm(ERR_XX, "");
    if (charger_FAVERATE(Kp_InputFAVERATE) == ERR)                          ExitPgm(ERR_XX, "");
    if (n_ChargEsb(Kp_TESB) == ERR)                                         ExitPgm(ERR_XX, "");

    /* Lancement du traitement */
    if (n_ProcessingRuptureVar(&pbd_RuptDetail) == ERR)                     ExitPgm(ERR_XX, "");

    /* Fermeture de tout les fichiers ouverts */
    if (n_CloseFileAppl("ESTC5001_I1", &pbd_RuptDetail.pf_InputFil) == ERR) ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC5001_I2", &Kp_TESB) == ERR)                    ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC5001_I3", &Kp_InputFAVERATE) == ERR)           ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC5001_O1", &Kp_OutputFilDetail) == ERR)         ExitPgm(ERR_XX, "");

    if (n_EndPgm() == ERR)                                                  ExitPgm(ERR_XX, "");

    exit(OK);
}


/*==============================================================================
objet :     Initialisation de la structure de rupture du Detail
retour:     OK
==============================================================================*/
int n_InitRuptDetail(T_RUPTURE_VAR *pbd_RuptDetail)
{
    DEBUT_FCT("n_InitRuptDetail");

    memset(pbd_RuptDetail, 0, sizeof(T_RUPTURE_VAR));

    // Ouverture du fichier Detail
    if (n_OpenFileAppl("ESTC5001_I1", "rt", &(pbd_RuptDetail->pf_InputFil)) == ERR)
        RETURN_VAL(errorMsg("Detail openning failed. Error in ESTC5001.\n"));

    pbd_RuptDetail->n_NbRupture   = 0;
    pbd_RuptDetail->n_ActionLigne = n_ActionLigneDetail;
    pbd_RuptDetail->c_Separ       = SEPARATEUR;

    RETURN_VAL(OK);
}

/*==============================================================================
objet :
retour:
==============================================================================*/
int n_ActionLigneDetail(char **pbd_RuptDetail)
{
    int     ssd = 0;

    char buff_previfrsamt[20]  = {'\0'};
    char buff_ifrsamt[20]      = {'\0'};
    char buff_plnifrsamt[20]   = {'\0'};
    char buff_prevprntamt[20]  = {'\0'};
    char buff_prntamt[20]      = {'\0'};
    char buff_plnprntamt[20]   = {'\0'};
    char buff_prevlocalamt[20] = {'\0'};
    char buff_localamt[20]     = {'\0'};
    char buff_plnlocalamt[20]  = {'\0'};

    DEBUT_FCT("n_ActionLigneDetail");

    ssd = atoi(pbd_RuptDetail[DETAIL_SSD_CF]);

    char cur_ref[4] = {'\0'};
    int  cur_ref_index = -1;
    cur_ref_index = recherche_cur_ref(atoi(pbd_RuptDetail[DETAIL_SSD_CF]), atoi(pbd_RuptDetail[DETAIL_ESB_CF]));
    if (cur_ref_index >= 0)
        strncpy(cur_ref, Kbd_Esb[cur_ref_index].THRHLDCUR, 3);
    else
        strncpy(cur_ref, "EUR", 3);

    sprintf(buff_previfrsamt,  "%-.3f", conv_montant(pbd_RuptDetail[DETAIL_CUR_CF], cur_ref , atof(pbd_RuptDetail[DETAIL_PREVIFRSAMT_M])));
    sprintf(buff_ifrsamt,      "%-.3f", conv_montant(pbd_RuptDetail[DETAIL_CUR_CF], cur_ref, atof(pbd_RuptDetail[DETAIL_IFRSAMT_M])));
    sprintf(buff_plnifrsamt,   "%-.3f", conv_montant(pbd_RuptDetail[DETAIL_CUR_CF], cur_ref, atof(pbd_RuptDetail[DETAIL_PLNIFRSAMT_M])));
    sprintf(buff_prevprntamt,  "%-.3f", conv_montant(pbd_RuptDetail[DETAIL_CUR_CF], cur_ref, atof(pbd_RuptDetail[DETAIL_PREVPRNTAMT_M])));
    sprintf(buff_prntamt,      "%-.3f", conv_montant(pbd_RuptDetail[DETAIL_CUR_CF], cur_ref, atof(pbd_RuptDetail[DETAIL_PRNTAMT_M])));
    sprintf(buff_plnprntamt,   "%-.3f", conv_montant(pbd_RuptDetail[DETAIL_CUR_CF], cur_ref, atof(pbd_RuptDetail[DETAIL_PLNPRNTAMT_M])));
    sprintf(buff_prevlocalamt, "%-.3f", conv_montant(pbd_RuptDetail[DETAIL_CUR_CF], cur_ref, atof(pbd_RuptDetail[DETAIL_PREVLOCALAMT_M])));
    sprintf(buff_localamt,     "%-.3f", conv_montant(pbd_RuptDetail[DETAIL_CUR_CF], cur_ref, atof(pbd_RuptDetail[DETAIL_LOCALAMT_M])));
    sprintf(buff_plnlocalamt,  "%-.3f", conv_montant(pbd_RuptDetail[DETAIL_CUR_CF], cur_ref, atof(pbd_RuptDetail[DETAIL_PLNLOCALAMT_M])));

    pbd_RuptDetail[DETAIL_PREVIFRSAMT_M]  = buff_previfrsamt;
    pbd_RuptDetail[DETAIL_IFRSAMT_M]      = buff_ifrsamt;
    pbd_RuptDetail[DETAIL_PLNIFRSAMT_M]   = buff_plnifrsamt;
    pbd_RuptDetail[DETAIL_PREVPRNTAMT_M]  = buff_prevprntamt;
    pbd_RuptDetail[DETAIL_PRNTAMT_M]      = buff_prntamt;
    pbd_RuptDetail[DETAIL_PLNPRNTAMT_M]   = buff_plnprntamt;
    pbd_RuptDetail[DETAIL_PREVLOCALAMT_M] = buff_prevlocalamt;
    pbd_RuptDetail[DETAIL_LOCALAMT_M]     = buff_localamt;
    pbd_RuptDetail[DETAIL_PLNLOCALAMT_M]  = buff_plnlocalamt;
    pbd_RuptDetail[DETAIL_QUARTER_B]      = quarter;

    pbd_RuptDetail[DETAIL_CUR_CF]         = cur_ref;

    n_WriteCols(Kp_OutputFilDetail, pbd_RuptDetail, SEPARATEUR, 0);

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
retour:
==============================================================================*/
double conv_montant(char *cur_from, char *cur_to    , double mnt)
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
                errorMsg("Valeur T_MAX_CUR atteinte ! Modifier ESTC5001.h !");
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
objet : Extrait le parametre a la position nb_tild dans une ligne
separee par des SEPARATEUR
retour: Parametre a la position nb_tild si succes
==============================================================================*/
char *extract_btwn_tild(char *line, int nb_tild)
{
    int     i = 0;
    int     j = 0;
    int     k;

    while (line[i] && j < nb_tild)
    {
        if (line[i] == SEPARATEUR)
            j++;
        i++;
    }
    if (line[i] == SEPARATEUR)
        i++;
    k = i;
    while (line[k] && line[k] != SEPARATEUR)
        k++;
    return (strndup(&line[i], k - i));
}


/*==============================================================================
objet :
retour :
==============================================================================*/
int    recherche_cur_ref(int ssd, int esb)
{
    int     i;

    for (i = 0; i < NB_ESB_MAX; ++i)
    {
        if (ssd == Kbd_Esb[i].SSD && esb == Kbd_Esb[i].ESB)
            return (i);
    }
    return (-1);
}

/*==============================================================================
objet :
   fonction d'extraction des donnees de la table TSUBSID de la base BREF
   Sont extraits le libelle (court) filiale, le code langue, la monnaie filiale
retour : OK
     ERR
==============================================================================*/
int n_ChargEsb(FILE *p_Libelle)
{
    char * line = NULL;
    size_t len = 0;
    int     i = 0;

    DEBUT_FCT ("n_ChargEsb");

    memset(Kbd_Esb, 0, sizeof(Kbd_Esb));

    while (getline(&line, &len, p_Libelle) != -1)
    {
        if (i <= NB_ESB_MAX)
        {
            Kbd_Esb[i].SSD      = atoi(extract_btwn_tild(line, 0));
            Kbd_Esb[i].ESB      = atoi(extract_btwn_tild(line, 1));
            strncpy(Kbd_Esb[i].THRHLDCUR, extract_btwn_tild(line, 11), 3);
        }
        else
            RETURN_VAL(errorMsg("Allocated space too small. Increase NB_ESB_MAX. Error in ESTC5001.\n"));
        i++;
    }
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
