/*==============================================================================
Nom de l'application          : Life Estimates Closing Multi-GAAP
Nom du source                 : ESTC3710.c
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

#define GT_UNFILL_COL -1 // Colonne vide
#define GT_TO_PRE_END -2 // Fin Hashtab



/*----------------------*/
/* Variables de travail */
/*----------------------*/

FILE                *Kp_InputFil_LIFDRI;
FILE                *Kp_OutputFil_LIFEST_SEG;       /* Pointeur sur le fichier SEGMNT segmente en sortie*/

T_RUPTURE_VAR       pbd_RuptLIFEST;                 /* Structure contenant les PA / CTR */
T_RUPTURE_SYNC_VAR  pbd_SyncSRGTC;                /* Structure contenant le SRGTC issu de FDRYTRN */

T_LIFDRI_ALL        Kbd_PILOT[NB_MAX_PILOT];
char                *Kpz_ligne[PRE_NBCOL + 4] = {NULL};


/*------------------*/
/*    Prototypes    */
/*------------------*/

int n_InitRuptLIFEST(T_RUPTURE_VAR *);
int n_ConditionRupture(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRuptPrev(char **ptd_inRec_Cur_LIFEST);
int n_ActionLigneLIFEST(char **);

int n_InitSyncSRGTC(T_RUPTURE_SYNC_VAR *);
int n_ActionLigneSRGTC(char **, char **);
int n_ConditionSyncSRGTC(char **, char **);

void fillFieldCC(char **lineFormatLifest, char **lineToFill, int index);
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

    if (n_BeginPgm(argc, argv) == ERR)                                          ExitPgm(ERR_XX, "");

    if (n_OpenFileAppl("ESTC3710_O1", "wt", &Kp_OutputFil_LIFEST_SEG) == ERR)   ExitPgm(ERR_XX, "");
    if (n_OpenFileAppl("ESTC3710_I3", "rb", &Kp_InputFil_LIFDRI) == ERR)        ExitPgm(ERR_XX, "");
    if (n_InitRuptLIFEST(&pbd_RuptLIFEST))                                      ExitPgm(ERR_XX, "");
    if (n_InitSyncSRGTC(&pbd_SyncSRGTC))                                        ExitPgm(ERR_XX, "");
    if (n_ChargerPilot5000(Kp_InputFil_LIFDRI) == ERR)                          ExitPgm(ERR_XX, "");

    /* Lancement du traitement */
    if (n_ProcessingRuptureVar(&pbd_RuptLIFEST) == ERR)                         ExitPgm(ERR_XX, "");

    /* Fermeture de tout les fichiers ouverts */
    if (n_CloseFileAppl("ESTC3710_I1", &(pbd_RuptLIFEST.pf_InputFil)) == ERR)   ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC3710_I2", &(pbd_SyncSRGTC.pf_InputFil)) == ERR)    ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC3710_I3", &Kp_InputFil_LIFDRI) == ERR)             ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC3710_O1", &Kp_OutputFil_LIFEST_SEG) == ERR)        ExitPgm(ERR_XX , "");

    if (n_EndPgm() == ERR)                                                      ExitPgm(ERR_XX, "");

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

    // Ouverture du fichier LIFEP
    if (n_OpenFileAppl("ESTC3710_I1", "rt", &(pbd_RuptLIFEST->pf_InputFil)) == ERR)
        RETURN_VAL(errorMsg("LIFEST openning failed. Error in ESTC3710.\n"));

    pbd_RuptLIFEST->n_NbRupture             = 1;
    pbd_RuptLIFEST->n_ConditionRupture[0]   = n_ConditionRupture;
    pbd_RuptLIFEST->n_ActionFirst[0]        = n_ActionFirstRuptPrev;

    /* Fonction du test de rupture de niveau 1 */
    pbd_RuptLIFEST->n_ActionLigne           = n_ActionLigneLIFEST;

    pbd_RuptLIFEST->c_Separ                 = SEPARATEUR;

    RETURN_VAL(OK);
}

/*==============================================================================
objet :     Initialisation de la structure de rupture du TCTRGRO
retour:     0 ----> OK
            ERR --> Error
==============================================================================*/
int n_InitSyncSRGTC(T_RUPTURE_SYNC_VAR *pbd_SyncSRGTC)
{
    DEBUT_FCT("n_InitRuptTCTRGRO");
    memset(pbd_SyncSRGTC, 0, sizeof(T_RUPTURE_SYNC_VAR));

    // Ouverture du fichier Peri
    if (n_OpenFileAppl("ESTC3710_I2", "rt", &(pbd_SyncSRGTC->pf_InputFil)) == ERR)
        RETURN_VAL(errorMsg("PERICASE openning failed. Error in ESTC3710.\n"));

    pbd_SyncSRGTC->n_NbRupture       = 0;

    /* fonction d'action sur la ligne courante */
    pbd_SyncSRGTC->n_ActionLigne     = n_ActionLigneSRGTC;

    /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
    pbd_SyncSRGTC->ConditionEndSync  = n_ConditionSyncSRGTC;

    pbd_SyncSRGTC->c_Separ           = SEPARATEUR;

    RETURN_VAL(OK);
}


/*==============================================================================
objet :     Condition de rupture LIFEST
retour:     0 ----> OK
==============================================================================*/
int n_ConditionRupture(char **ptb_InRec, char **ptb_InRec_Cur)
{
    int ret = 0;
    DEBUT_FCT("n_ConditionRupture");

    if ((ret = strcmp(ptb_InRec[PRE_CTR_NF],    ptb_InRec_Cur[PRE_CTR_NF]))     != 0)    RETURN_VAL(ret);
    if ((ret = strcmp(ptb_InRec[PRE_END_NT],    ptb_InRec_Cur[PRE_END_NT]))     != 0)    RETURN_VAL(ret);
    if ((ret = strcmp(ptb_InRec[PRE_SEC_NF],    ptb_InRec_Cur[PRE_SEC_NF]))     != 0)    RETURN_VAL(ret);
    if ((ret = strcmp(ptb_InRec[PRE_UWY_NF],    ptb_InRec_Cur[PRE_UWY_NF]))     != 0)    RETURN_VAL(ret);
    if ((ret = strcmp(ptb_InRec[PRE_UW_NT],     ptb_InRec_Cur[PRE_UW_NT]))      != 0)    RETURN_VAL(ret);
    if ((ret = strcmp(ptb_InRec[PRE_ACY_NF],    ptb_InRec_Cur[PRE_ACY_NF]))     != 0)    RETURN_VAL(ret);
    if ((ret = strcmp(ptb_InRec[PRE_ACMTRS_NT], ptb_InRec_Cur[PRE_ACMTRS_NT]))  != 0)    RETURN_VAL(ret);

    RETURN_VAL(OK);
}


/*==============================================================================
objet :     ActionFirstRuptPrev Previsions (LIFEST)
retour:     0 ----> OK
==============================================================================*/
int n_ActionFirstRuptPrev(char **ptd_inRec_Cur_LIFEST)
{

    DEBUT_FCT("n_ActionFirstRuptPrev");

    fillFieldCC(ptd_inRec_Cur_LIFEST, Kpz_ligne, PRE_NBCOL + 1);


    if (n_ProcessingRuptureSyncVar(&pbd_SyncSRGTC, ptd_inRec_Cur_LIFEST) == ERR)
        RETURN_VAL(ERR);

    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   Fonction lancee à la première rupture
retour  :   0 ---> traitement correctement effectue
==============================================================================*/
int n_ActionLigneLIFEST(char **ptd_inRec_Cur_LIFEST)
{
    int     i;
    int     j;
    char    *usedACMTRS[] = {"1243",
                             "1244",
                             "1510",
                             NULL
                            };
    DEBUT_FCT("n_ActionFirstRuptLIFEST");

    for (i = 0; usedACMTRS[i] != NULL; ++i)
    {
        // If ACMTRS == 1243, 1244 or 1510, writecol
        if (strcmp(usedACMTRS[i], ptd_inRec_Cur_LIFEST[PRE_ACMTRS_NT]) == 0)
        {
            for (j = 0; j < PRE_NBCOL; ++j)
            {
                Kpz_ligne[j] = ptd_inRec_Cur_LIFEST[j];
            }
            Kpz_ligne[j] = "";
            n_WriteCols(Kp_OutputFil_LIFEST_SEG, Kpz_ligne, SEPARATEUR, 0);
            RETURN_VAL(OK);
        }
    }

    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   Fonction lancee pour chaque ligne du SRGTC
retour  :   0 ----> traitement correctement effectue
==============================================================================*/
int n_ActionLigneSRGTC(char **ptd_RuptLIFEST, char **ptd_SyncSRGTC)
{
    char *pz_ligne[PRE_NBCOL + 3] = {NULL};
    int  i;
    int  ligne[] = {GT_SSD_CF,       // PRE_SSD_CF  =0      //0
                    GT_CTR_NF,       // PRE_CTR_NF          //1
                    GT_END_NT,       // PRE_END_NT          //2
                    GT_SEC_NF,       // PRE_SEC_NF          //3
                    GT_UWY_NF,       // PRE_UWY_NF          //4
                    GT_UW_NT,        // PRE_UW_NT           //5
                    GT_ACY_NF,       // PRE_ACY_NF          //6
                    GT_UNFILL_COL,   // PRE_CRE_D           //7
                    GT_UNFILL_COL,   // PRE_PRS_CF          //8
                    GT_ACMTRS_NT,    // PRE_ACMTRS_NT       //9
                    GT_BALSHEY_NF,   // PRE_BALSHEY_NF      //10
                    GT_BALSHRMTH_NF, // PRE_BALSHTMTH_NF    //11
                    GT_CUR_CF,       // PRE_CUR_CF          //12
                    GT_ESTAMT_M,     // PRE_ESTMNT_M        //13
                    GT_UNFILL_COL,   // PRE_INDSUP_B        //14
                    GT_UNFILL_COL,   // PRE_ORICOD_LS       //15
                    GT_UNFILL_COL,   // PRE_CREUSR_CF       //16
                    GT_UNFILL_COL,   // PRE_LSTUPD_D        //17
                    GT_UNFILL_COL,   // PRE_LSTUPDUSR_CF    //18
                    GT_UNFILL_COL,   // PRE_DETTRNCOD_CF    //19
                    GT_DETTRS_CF,    // PRE_DETTRS_CF       //20
                    GT_GAAP_NF,      // PRE_GAAP_NF         //21
                    GT_UNFILL_COL,   // PRE_GAAPDIFF_M      //22
                    GT_UNFILL_COL,   // PRE_PROPAGATION_B   //23
                    GT_UNFILL_COL,   // PRE_ESTMTH_NF       //24
                    GT_UNFILL_COL,   // PRE_ORICTR_NF       //25
                    GT_UNFILL_COL,   // PRE_ORISEC_NF       //26
                    GT_UNFILL_COL,   // PRE_ORIUWY_NF       //27
                    GT_UNFILL_COL,   // PRE_UPD_NF          //28
                    GT_LOB_CF,       // PRE_LOB_CF          //29
                    GT_UNFILL_COL,   // PRE_ACCSTS_CT       //30
                    GT_UNFILL_COL,   // PRE_ACCADMTYP_CT    //31
                    GT_ESTCRB_CT,    // PRE_ESTCRB_CT       //32
                    GT_CED_NF,       // PRE_CED_NF          //33
                    GT_BRK_NF,       // PRE_BRK_NF          //34
                    GT_SPIMOD_CT,    // PRE_SPIMOD_CT       //35
                    GT_PAY_NF,       // PRE_PAY_NF          //36
                    GT_NAT_CF,       // PRE_NAT_CF          //37
                    GT_UNFILL_COL,   // PRE_GANPAYORD_NT    //38
                    GT_ADJCOD_CT,    // PRE_ADJCOD_CT       //39
                    GT_UNFILL_COL,   // PRE_RETCOD_CT       //40
                    GT_ACCRET_B,     // PRE_ACCRET_B        //41
                    GT_ESB_CF,       // PRE_ESB_CF          //42
                    GT_LIFTRTTYP_CF, // PRE_LIFTRTTYP_CF    //43
                    GT_UWGRP_CF,     // PRE_UWGRP_CF        //44
                    GT_UNFILL_COL,   // PRE_CNATYP_CT       //45
                    GT_UNFILL_COL,   // PRE_RENOUV_B        //46
                    GT_UNFILL_COL,   // PRE_CLOPRD          //47
                    GT_UNFILL_COL,   // PRE_DBCLO_D         //48
                    GT_UNFILL_COL,   // PRE_ORICRE_D        //49
                    GT_UNFILL_COL,   // PRE_ORISSD_CF       //50
                    GT_UNFILL_COL,   // PRE_BATCH_B         //51
                    GT_UNFILL_COL,   // PRE_NBCOLNEW        //52
                    GT_UNFILL_COL,   // PRE_NBCOL           //53

                    GT_COMACC_B,     // Colonne pour booleen -> CC ? Y ou N

                    GT_TO_PRE_END    // END HASH TABLE
                   };
    DEBUT_FCT("n_ActionLigneSRGTC");

    if (strcmp(ptd_SyncSRGTC[GT_ACMTRS_NT], "1220") == 0)
    {
        for (i = 0; ligne[i] != GT_TO_PRE_END; ++i)
        {
            if (ligne[i] != GT_UNFILL_COL)
            {
                if (ligne[i] != GT_COMACC_B)
                {
                    pz_ligne[i] = ptd_SyncSRGTC[ligne[i]];
                    if (pz_ligne[i] == NULL)
                        pz_ligne[i] = "";
                }
                else // Ternaire CC
                    fillFieldCC(pz_ligne, pz_ligne, i);
            }
            else
                pz_ligne[i] = "";
        }
        pz_ligne[i] = NULL;
        n_WriteCols(Kp_OutputFil_LIFEST_SEG, pz_ligne, SEPARATEUR, 0);
    }
    RETURN_VAL(OK);
}

/*==============================================================================
objet   :   fonction de test de synchronisation
retour  :   0   ---> pbd_RuptLIFEST = pbd_RuptTCTRGRO (égalité de rubrique à synchroniser)
            1   ---> Pas de syncronisation
==============================================================================*/
int n_ConditionSyncSRGTC(char **ptd_RuptLIFEST, char **ptd_RuptSRGTC)
{
    int     ret = 0;
    DEBUT_FCT("n_ConditionSyncSRGTC");

    if ((ret = strcmp(ptd_RuptLIFEST[PRE_CTR_NF], ptd_RuptSRGTC[GT_CTR_NF])) != 0) RETURN_VAL(ret);
    if ((ret = strcmp(ptd_RuptLIFEST[PRE_SEC_NF], ptd_RuptSRGTC[GT_SEC_NF])) != 0) RETURN_VAL(ret);
    if ((ret = strcmp(ptd_RuptLIFEST[PRE_END_NT], ptd_RuptSRGTC[GT_END_NT])) != 0) RETURN_VAL(ret);
    if ((ret = strcmp(ptd_RuptLIFEST[PRE_SSD_CF], ptd_RuptSRGTC[GT_SSD_CF])) != 0) RETURN_VAL(ret);
    if ((ret = strcmp(ptd_RuptLIFEST[PRE_UWY_NF], ptd_RuptSRGTC[GT_UWY_NF])) != 0) RETURN_VAL(ret);
    if ((ret = strcmp(ptd_RuptLIFEST[PRE_ACY_NF], ptd_RuptSRGTC[GT_ACY_NF])) != 0) RETURN_VAL(ret);

    RETURN_VAL(OK);
}

/*==============================================================================
objet   :   Fonction d'affichage de message d'erreur
retour  :   ERR --> permet l'arret du programme
==============================================================================*/
void fillFieldCC(char **lineFormatLifest, char **lineToFill, int index)
{
    static int      Kn_indexLIFDRI  = 0;

    if (n_RechPilot5000(lineFormatLifest, PRE_CTR_NF , PRE_SEC_NF, PRE_ACY_NF, &Kn_indexLIFDRI) != -1)
    {
        if (Kbd_PILOT[Kn_indexLIFDRI].AUTUPD_B && Kbd_PILOT[Kn_indexLIFDRI].COMACC_B)
        {
            lineToFill[index] = "Y";
        }
        else
            lineToFill[index] = "N";
    }
    else
        lineToFill[index] = "N";
}

/*==============================================================================
objet   :   Fonction d'affichage de message d'erreur
retour  :   ERR --> permet l'arret du programme
==============================================================================*/
int errorMsg(char *error)   // error : message d'erreur à écrire
{
    char    MsgAno[100];

    sprintf(MsgAno, error);
    n_WriteAno(MsgAno);

    RETURN_VAL(ERR);
}