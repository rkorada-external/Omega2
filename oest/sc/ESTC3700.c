/*==============================================================================
Nom de l'application          : Life Estimates Closing Multi-GAAP
Nom du source                 : ESTC3700.c
Révision                      : $Revision: 1.0 $
Date de création              : 06/03/2015
Auteur                        : Julien FONTANA
References des specifications : #################
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
    Life Estimates Closing Multi-GAAP - IO Automatisation
    Crée pour l'EST24BT
    Permet la gestion des Gaaps Parents et Local par le récepteur dans le cas
    d'une rétrocession de contrat en interne.
------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>

[001] 19/10/2015 RBE  :spot:29541 Correction: ne pas conduire la ligne en cas IO manuel
[002] 06/01/2016 RBE  :spot:29971 Correction: tenir compte du gaap interdit (gaap 5)
[003] 25/02/2019 RAF  :spot:70045 Add mount in ruptur
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
/* définition des constantes et macros privées */
/*---------------------------------------------*/

#define NB_GAAP             5
#define NB_SUBSTR_MAX       50000
#define BATCH_B             "1"
#define MONTANT_NULL        "0.000"
#define HEURE_TRAITEMENT    "23:59:05"


/*----------------------*/
/* Variables de travail */
/*----------------------*/

FILE                *Kp_OutputFilModLifep;  /* Pointeur sur le fichier en sortie*/
FILE                *Kp_SubTRSBpropFile;    /* Input File from TSUBTRSESBPROP */
FILE                *Kp_SubTRS;             /* Input File from TSUBTRS */

T_RUPTURE_VAR       pbd_RuptLifep;      /* Structure contenant le LIFEP */
T_RUPTURE_SYNC_VAR  pbd_RuptPERI;       /* Structure contenant le PERICASE */
T_SUBTRSESBPROP     Kbd_SUBTRSESBPROP;

T_SUBTRS SubtrsLigne;

char Ksz_Cre_D[22] = {'\0'};
char *Ksz_line[2][PRE_NBCOL + 1];
char *(Ksz_Gaap_MNT[NB_GAAP]);
char *(Sav_Gaap_MNT[NB_GAAP]);


int  Parent_Flag;
int  Local_Flag;
int  Update_gaap3 = 1; // Booleen
int  Update_gaap4 = 1; // Booleen
int  Update_gaap5 = 0; // Booleen
int  Conduire_parent = 1;
int  Conduire_local  = 1;

/*------------------*/
/*    Prototypes    */
/*------------------*/

int n_InitRuptLifep(T_RUPTURE_VAR *pbd_RuptLifep);
int n_ActionLigneLifep(char **pbd_RuptLifep);
int n_ActionLastRuptLifep(char **ptb_RuptLifep);
int n_ConditionRuptureLifep(char **ptd_InRec, char **ptd_InRec_Cur);

int n_InitRuptPeri(T_RUPTURE_SYNC_VAR *pbd_RuptPERI);
int n_ActionLignePeri(char **pbd_RuptPERI, char **pbd_RuptLifep);
int n_ConditionSyncPeri(char **pbd_RuptLifep, char **pbd_RuptPERI); /* Fonction de fin de syncronisation */

void clean_Ksz_Gaap_MNT();
int errorMsg(char *error);  /* Fonction d'appel en cas d'erreur */
void init_SubTrsLigne();

/*==============================================================================
objet   :   Point d'entree du programme
retour  :   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc, char *argv[])
{
    int ret = 0;
    /* Initialisation des signaux */
    InitSig();

    if (n_BeginPgm(argc, argv) == ERR)                                                 ExitPgm(ERR_XX, "");

    // Recuperation des parametres
    sprintf(Ksz_Cre_D, "%s %s", psz_GetCharArgv(1), HEURE_TRAITEMENT);

    if (n_OpenFileAppl("ESTC3700_O1", "wt", &Kp_OutputFilModLifep) == ERR)             ExitPgm(ERR_XX, "");
    if (n_OpenFileAppl ("ESTC3700_I3", "rb", &Kp_SubTRSBpropFile) == ERR)              ExitPgm(ERR_XX, "");
    if ((ret = n_ChargerSUBTRSESBPROP(Kp_SubTRSBpropFile)) == ERR)
    {
        printf("Lu avant err: %d\n", ret); // Ne pas retirer sinon SEGFAULT...
        RETURN_VAL(errorMsg("Error loading Kbd_SUBTRSESBPROP. Error in ESTC3700.\n")); ExitPgm(ERR_XX, "");
    }

    if (n_OpenFileAppl ("ESTC3700_I4", "rb", &Kp_SubTRS) == ERR)                       ExitPgm(ERR_XX, "");
    if ((ret = n_ChargerTsubTRS(Kp_SubTRS)) == ERR)
    {
        printf("Lu avant err: %d\n", ret); // Ne pas retirer sinon SEGFAULT...
        RETURN_VAL(errorMsg("Error loading Kbd_SUBTRS. Error in ESTC3700.\n"));        ExitPgm(ERR_XX, "");
    }
    // initialisation de la structure retour
    init_SubTrsLigne();
    if (n_InitRuptPeri(&pbd_RuptPERI))                                                 ExitPgm(ERR_XX, "");
    if (n_InitRuptLifep(&pbd_RuptLifep))                                               ExitPgm(ERR_XX, "");
    clean_Ksz_Gaap_MNT();


    /* Lancement du traitement */
    if (n_ProcessingRuptureVar(&pbd_RuptLifep) == ERR)                                 ExitPgm(ERR_XX, "");

    /* Fermeture de tout les fichiers ouverts */
    if (n_CloseFileAppl("ESTC3700_I1", &pbd_RuptLifep.pf_InputFil) == ERR)             ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC3700_I2", &pbd_RuptPERI.pf_InputFil) == ERR)              ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC3700_I3", &Kp_SubTRSBpropFile) == ERR)                    ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC3700_I4", &Kp_SubTRS) == ERR)                             ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC3700_O1", &Kp_OutputFilModLifep) == ERR)                  ExitPgm(ERR_XX, "");

    if (n_EndPgm() == ERR)                                                             ExitPgm(ERR_XX, "");

    exit(OK);
}


/*==============================================================================
objet :     Initialisation de la structure de rupture du LIFEP
retour:     OK
==============================================================================*/
int n_InitRuptLifep(T_RUPTURE_VAR *pbd_RuptLifep)
{
    DEBUT_FCT("n_InitRuptLifep");

    memset(pbd_RuptLifep, 0, sizeof(T_RUPTURE_VAR));

    // Ouverture du fichier LIFEP
    if (n_OpenFileAppl("ESTC3700_I1", "rt", &(pbd_RuptLifep->pf_InputFil)) == ERR)
        RETURN_VAL(errorMsg("LIFEP openning failed. Error in ESTC3700.\n"));

    pbd_RuptLifep->n_NbRupture              = 1;
    pbd_RuptLifep->n_ConditionRupture[0]    = n_ConditionRuptureLifep;
    pbd_RuptLifep->n_ActionLast[0]          = n_ActionLastRuptLifep;

    pbd_RuptLifep->n_ActionLigne            = n_ActionLigneLifep;
    pbd_RuptLifep->c_Separ                  = SEPARATEUR;

    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   Fonction lancee à chaque rupture
retour  :   OK ---> traitement correctement effectue
==============================================================================*/
int n_ActionLigneLifep(char **pbd_RuptLifep)
{
    int  col = 0;
    DEBUT_FCT("n_ActionLigneLifep");

    if (n_ProcessingRuptureSyncVar(&pbd_RuptPERI, pbd_RuptLifep) == ERR)
        RETURN_VAL(errorMsg("n_ProcessingRuptureSyncVar failed. Error in ESTC3700.\n"));

    switch (pbd_RuptLifep[PRE_GAAP_NF][0]) {
    case '1':
        Sav_Gaap_MNT[0] = strdup(pbd_RuptLifep[PRE_ESTMNT_M]);
        n_WriteCols(Kp_OutputFilModLifep, pbd_RuptLifep, SEPARATEUR, 0);
        break;

    case '2':
        Sav_Gaap_MNT[1] = strdup(pbd_RuptLifep[PRE_ESTMNT_M]);
        n_WriteCols(Kp_OutputFilModLifep, pbd_RuptLifep, SEPARATEUR, 0);
        break;

    case '3':
        Update_gaap3 = 0;
        Sav_Gaap_MNT[2] = strdup(pbd_RuptLifep[PRE_ESTMNT_M]);
        for (col = 0; col < PRE_NBCOL; ++col)
        {
            if (pbd_RuptLifep[col] != NULL)
                Ksz_line[0][col] = strdup(pbd_RuptLifep[col]);
            else
                Ksz_line[0][col] = "";
        }
        break;

    case '4':
        Update_gaap4 = 0;
        Sav_Gaap_MNT[3] = strdup(pbd_RuptLifep[PRE_ESTMNT_M]);
        for (col = 0; col < PRE_NBCOL; ++col)
        {
            if (pbd_RuptLifep[col] != NULL)
                Ksz_line[1][col] = strdup(pbd_RuptLifep[col]);
            else
                Ksz_line[1][col] = "";
        }
        break;

    case '5':
    	Update_gaap5 = 1;
        Sav_Gaap_MNT[4] = strdup(pbd_RuptLifep[PRE_ESTMNT_M]);
        //pbd_RuptLifep[PRE_ESTMNT_M] = Ksz_Gaap_MNT[1]; // MNT du gaap 5 alimente via IFRS
        n_WriteCols(Kp_OutputFilModLifep, pbd_RuptLifep, SEPARATEUR, 0);
        break;

    default:
        n_WriteCols(Kp_OutputFilModLifep, pbd_RuptLifep, SEPARATEUR, 0);
        break;
    }

    RETURN_VAL(OK);
}


/*==============================================================================
objet :     n_ActionLastRuptLifep
retour:     0   ----> OK
            ERR ----> LOGICAL ERROR

###################     ###################
# PARENT # GAAP 3 #     #  LOCAL # GAAP 4 #
#  FLAG  # VALUE  #     #  FLAG  # VALUE  #
#        #        #     #        #        #
###################     ###################
#        #        #     #        #        #
#   0    # Manual #     #   0    # Manual #
#        #        #     #        #        #
###################     ###################
#   1    #        #     #   1    #        #
#   OR   #   G2   #     #   OR   #   G2   #
#  NULL  #  IFRS  #     #  NULL  #  IFRS  #
###################     ###################
#        #        #     #        #        #
#   2    #   G3   #     #   2    #   G3   #
#        #  LOCAL #     #        #  LOCAL #
###################     ###################
#        #        #     #        #        #
#   3    #   G4   #     #   3    #   G4   #
#        # PARENT #     #        # PARENT #
###################     ###################

G2 -> Montant du Gaap 2
G3 -> Montant du Gaap 3
G4 -> Montant du Gaap 4
==============================================================================*/
int n_ActionLastRuptLifep(char **ptb_RuptLifep)
{
    char    buff[30];
    DEBUT_FCT("n_ActionLastRuptLifep");

    ////////////////////////////
    // printf("uwy = %s\tacy = %s\n", ptb_RuptLifep[PRE_UWY_NF], ptb_RuptLifep[PRE_ACY_NF]);
    // printf("Parent_Flag = %d\tLocal_Flag = %d\n\n", Parent_Flag, Local_Flag);
    ////////////////////////////
    Conduire_parent = 1;
    Conduire_local = 1;

    switch (Parent_Flag) {
    case 0:
        Ksz_Gaap_MNT[2] = Sav_Gaap_MNT[2];  // Valeur Manuelle

        init_SubTrsLigne();
        n_FindTsubTRS(&SubtrsLigne, ptb_RuptLifep[PRE_DETTRNCOD_CF]);
        if (SubtrsLigne.TRSTYPE_CT != 1)
        {
        	Conduire_parent = 0;
        }
        break;

    case 1:
        Ksz_Gaap_MNT[2] = Sav_Gaap_MNT[1];  // Issu de Gaap 2 (IFRS)
        break;

    case 2:
        Ksz_Gaap_MNT[2] = Sav_Gaap_MNT[2];  // Issu de Gaap 3 (PARENT)
        break;

    case 3:
        Ksz_Gaap_MNT[2] = Sav_Gaap_MNT[3];  // Issu de Gaap 4 (LOCAL)
        break;

    default:
        RETURN_VAL(errorMsg("Bad Parent_Flag. Error in ESTC3700.\n"));
        break;
    }

    switch (Local_Flag) {
    case 0:
        Ksz_Gaap_MNT[3] = Sav_Gaap_MNT[3];  // Valeur Manuelle

        init_SubTrsLigne();
        n_FindTsubTRS(&SubtrsLigne, ptb_RuptLifep[PRE_DETTRNCOD_CF]);
        if (SubtrsLigne.TRSTYPE_CT != 1)
        {
        	Conduire_local = 0;
        }
        break;

    case 1:
        Ksz_Gaap_MNT[3] = Sav_Gaap_MNT[1];  // Issu de Gaap 2 (IFRS)
        break;

    case 2:
        Ksz_Gaap_MNT[3] = Sav_Gaap_MNT[2];  // Issu de Gaap 3 (PARENT)
        break;

    case 3:
        Ksz_Gaap_MNT[3] = Sav_Gaap_MNT[3];  // Issu de Gaap 4 (LOCAL)
        break;

    default:
        RETURN_VAL(errorMsg("Bad Local_Flag. Error in ESTC3700.\n"));
        break;
    }

    if ((n_RechSUBTRSESBPROP(&Kbd_SUBTRSESBPROP, ptb_RuptLifep[PRE_DETTRNCOD_CF], ptb_RuptLifep[PRE_SSD_CF], ptb_RuptLifep[PRE_ESB_CF])) != -1)
    {
        if (Kbd_SUBTRSESBPROP.GAAP3TRS_CT == 3)
            Ksz_Gaap_MNT[2] = MONTANT_NULL;

        if (Kbd_SUBTRSESBPROP.GAAP4TRS_CT == 3)
            Ksz_Gaap_MNT[3] = MONTANT_NULL;

        if (Kbd_SUBTRSESBPROP.GAAP5TRS_CT == 3)
            Ksz_Gaap_MNT[4] = MONTANT_NULL;
    }

    if (Update_gaap3 == 0)
    {
        memset(buff, 0, 30);
        sprintf(buff, "%.3lf", atof(Ksz_Gaap_MNT[2]));
        Ksz_line[0][PRE_ESTMNT_M] = buff;
        Ksz_line[0][PRE_CRE_D]    = Ksz_Cre_D;
        Ksz_line[0][PRE_BATCH_B]  = BATCH_B;

        if (Conduire_parent != 0)
           n_WriteCols(Kp_OutputFilModLifep, Ksz_line[0], SEPARATEUR, 0);
                  
        Update_gaap3 = 1;
        Conduire_parent = 1;
    }

    if (Update_gaap4 == 0)
    {
        memset(buff, 0, 30);
        sprintf(buff, "%.3lf", atof(Ksz_Gaap_MNT[3]));
        Ksz_line[1][PRE_ESTMNT_M] = buff;
        Ksz_line[1][PRE_CRE_D]    = Ksz_Cre_D;
        Ksz_line[1][PRE_BATCH_B]  = BATCH_B;

        if (Conduire_local != 0)
           n_WriteCols(Kp_OutputFilModLifep, Ksz_line[1], SEPARATEUR, 0);

        Update_gaap4 = 1;
        Conduire_local = 1;
    }

    if (Update_gaap5 == 1)
    {

        memset(buff, 0, 30);
        sprintf(buff, "%.3lf", atof(Ksz_Gaap_MNT[1]));
        ptb_RuptLifep[PRE_ESTMNT_M] = buff;

       if ((n_RechSUBTRSESBPROP(&Kbd_SUBTRSESBPROP, ptb_RuptLifep[PRE_DETTRNCOD_CF], ptb_RuptLifep[PRE_SSD_CF], ptb_RuptLifep[PRE_ESB_CF])) != -1)
	     {
	        if (Kbd_SUBTRSESBPROP.GAAP5TRS_CT == 3)
	           ptb_RuptLifep[PRE_ESTMNT_M] = MONTANT_NULL;
	     }

        ptb_RuptLifep[PRE_CRE_D]    = Ksz_Cre_D;
        ptb_RuptLifep[PRE_BATCH_B]  = BATCH_B;
        ptb_RuptLifep[PRE_GAAP_NF]  = "5";
        n_WriteCols(Kp_OutputFilModLifep, ptb_RuptLifep, SEPARATEUR, 0);
                  
        Update_gaap5 = 0;
    }

    clean_Ksz_Gaap_MNT();

    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   fonction de test de synchronisation
retour  :   0   ---> pbd_RuptLifep = pbd_RuptLifep (égalité de rubrique à synchroniser)
            !=0 ---> Pas de syncronisation
==============================================================================*/
int n_ConditionRuptureLifep(char **ptd_InRec, char **ptd_InRec_Cur)
{
    int     ret = 0;
    DEBUT_FCT("n_ConditionRuptureLifep");

    if ((ret = strcmp(ptd_InRec[PRE_CTR_NF],       ptd_InRec_Cur[PRE_CTR_NF]))       != 0)  RETURN_VAL(ret);
    if ((ret = strcmp(ptd_InRec[PRE_SEC_NF],       ptd_InRec_Cur[PRE_SEC_NF]))       != 0)  RETURN_VAL(ret);
    if ((ret = strcmp(ptd_InRec[PRE_UWY_NF],       ptd_InRec_Cur[PRE_UWY_NF]))       != 0)  RETURN_VAL(ret);
    if ((ret = strcmp(ptd_InRec[PRE_ACY_NF],       ptd_InRec_Cur[PRE_ACY_NF]))       != 0)  RETURN_VAL(ret);
    if ((ret = strcmp(ptd_InRec[PRE_ESTMTH_NF],    ptd_InRec_Cur[PRE_ESTMTH_NF]))    != 0)  RETURN_VAL(ret); // [003]
    if ((ret = strcmp(ptd_InRec[PRE_ACMTRS_NT],    ptd_InRec_Cur[PRE_ACMTRS_NT]))    != 0)  RETURN_VAL(ret);
	if ((ret = strcmp(ptd_InRec[PRE_BALSHEY_NF],   ptd_InRec_Cur[PRE_BALSHEY_NF]))   != 0)  RETURN_VAL(ret);
    if ((ret = strcmp(ptd_InRec[PRE_BALSHTMTH_NF], ptd_InRec_Cur[PRE_BALSHTMTH_NF])) != 0)  RETURN_VAL(ret);
    if ((ret = strcmp(ptd_InRec[PRE_DETTRNCOD_CF], ptd_InRec_Cur[PRE_DETTRNCOD_CF])) != 0)  RETURN_VAL(ret);

    RETURN_VAL(OK);
}


/*==============================================================================
objet :     Initialisation de la structure de rupture syncronisée du LIFEP
retour:     OK
==============================================================================*/
int n_InitRuptPeri(T_RUPTURE_SYNC_VAR * pbd_RuptPERI)
{
    DEBUT_FCT("n_InitRuptPeri");
    memset(pbd_RuptPERI, 0, sizeof(T_RUPTURE_SYNC_VAR));

    // Ouverture du fichier Peri
    if (n_OpenFileAppl("ESTC3700_I2", "rt", &(pbd_RuptPERI->pf_InputFil)) == ERR)
        RETURN_VAL(errorMsg("PERICASE openning failed. Error in ESTC3700.\n"));

    pbd_RuptPERI->n_NbRupture       = 0;

    /* fonction d'action sur la ligne courante */
    pbd_RuptPERI->n_ActionLigne     = n_ActionLignePeri;

    /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
    pbd_RuptPERI->ConditionEndSync  = n_ConditionSyncPeri;

    pbd_RuptPERI->c_Separ           = SEPARATEUR;

    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   Fonction lancee pour chaque ligne du PERICASE
retour  :   OK
==============================================================================*/
int n_ActionLignePeri(char **pbd_RuptLifep, char **pbd_RuptPERI)
{
    DEBUT_FCT("n_ActionLignePeri");

    // Check de la valeur du PER_PARENT_FLAG. NULL a la meme comportement que la valeur 1
    if (pbd_RuptPERI[PER_PARENT_FLAG] != NULL)
    {
        if (pbd_RuptPERI[PER_PARENT_FLAG][0] != '\0')
            Parent_Flag = atoi(pbd_RuptPERI[PER_PARENT_FLAG]);
        else
            Parent_Flag = 1;
    }
    else
        Parent_Flag = 1;

    // Check de la valeur du PER_LOCAL_FLAG. NULL a la meme comportement que la valeur 1
    if (pbd_RuptPERI[PER_LOCAL_FLAG] != NULL)
    {
        if (pbd_RuptPERI[PER_LOCAL_FLAG][0] != '\0')
            Local_Flag = atoi(pbd_RuptPERI[PER_LOCAL_FLAG]);
        else
            Local_Flag = 1;
    }
    else
        Local_Flag = 1;

    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   fonction de test de synchronisation
retour  :   0   ---> pbd_RuptLifep = pbd_RuptPERI (égalité de rubrique à synchroniser)
            !=0 ---> Pas de syncronisation
==============================================================================*/
int n_ConditionSyncPeri(char **pbd_LIFEP, char **pbd_RuptPERI)   /* adresse de la ligne du LIFEP puis du PERICASE */
{
    int     ret = 0;
    DEBUT_FCT("n_ConditionSyncPeri");

    if ((ret = strcmp(pbd_LIFEP[PRE_CTR_NF], pbd_RuptPERI[PER_CTR_NF])) != 0)  RETURN_VAL(ret);
    if ((ret = strcmp(pbd_LIFEP[PRE_SEC_NF], pbd_RuptPERI[PER_SEC_NF])) != 0)  RETURN_VAL(ret);
    if ((ret = strcmp(pbd_LIFEP[PRE_UWY_NF], pbd_RuptPERI[PER_UWY_NF])) != 0)  RETURN_VAL(ret);

    RETURN_VAL(OK);
}


/*==============================================================================
objet :     Initialisation de la structure de rupture syncronisée du LIFEP
==============================================================================*/
void clean_Ksz_Gaap_MNT()
{
    int i = 0;
    DEBUT_FCT("clean_Ksz_Gaap_MNT");

    for (i = 0; i < NB_GAAP; ++i)
    {
        Ksz_Gaap_MNT[i] = MONTANT_NULL;
        Sav_Gaap_MNT[i] = MONTANT_NULL;
    }
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
/*==========================================================================
     Objet :    Initialisation de la structure TRS

     Nom:       init_SubTrsLigne

     Parametres:


     Retour:    0
===========================================================================*/
void init_SubTrsLigne()
{
          strcpy(SubtrsLigne.DETTRNCOD_CF, "");
          strcpy(SubtrsLigne.SUBTRS_GL,"");
          strcpy(SubtrsLigne.SUBTRS_GS,"");
          strcpy(SubtrsLigne.SUBTRSEXP_D,"");
          strcpy(SubtrsLigne.SUBTRSINC_D,"");
          SubtrsLigne.CMT_NT =0;
          SubtrsLigne.TRSINPUTTYPE_CT = 0;
          SubtrsLigne.TRSNATURE_CT = 0 ;
          strcpy(SubtrsLigne.LOGSIG_CT,"");
          strcpy(SubtrsLigne.LOB_CF,"");
          SubtrsLigne.TRSTYPE_CT = 0;
          SubtrsLigne.TRSPURERETRO_B = 0;
          SubtrsLigne.DACTYPE_B   = 0;
          SubtrsLigne.COMPLEMENT_B = 0;
          SubtrsLigne.NEWBALSHEETPROPAG_B = 0;
          SubtrsLigne.CELLPROTECEXC_B = 0;
}
