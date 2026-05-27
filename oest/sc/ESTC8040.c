/*==============================================================================
nom de l'application          : Filtre des ecarts lifest-GT en fonction de seuils
nom du source                 : ESTC8040.c
date de creation              : 03/08/2015
auteur                        : G. Bonnerue
references des specifications : EST26
squelette de base             : batch
------------------------------------------------------------------------------
description :
                Filtre des ecarts lifest-GT en fonction de seuils
Modifications :
[001] MBO : Spira 43178 - 42603
[002] MBO 29/12/2015 : Spira 42600 - 42603
[003] MBO 04/02/2016 : patch prev [002]
[004] DFI 22/01/2016 : spot 29095 augmentation du nombre de lignes de TCALL pouvant être traitées
[005] MMA 21/04/2016 : spot 30506  SPIRA 45213 : Correction de l'identification de la notification
                                                     AVANT : SSD/ESB/UWGRP  => APRES : SSD/ESB/CTR/SEC/UWY/UWGRP
[006] MMA 05/09/2016 : Spot31174   SPIRA 54523 : Suppression de la rupture sur le DIFF_CUR_CF
                                                 Modification du comportement des anomalies PereSansFils -> FilsSansPere
[007] MMA 17/11/2016 : SPIRA 57346 : Les postes de dépots (SubTRS.TRSTYPE_CT == 4) ne doivent pas faire l'objetr de calcul d'écart compta > estim
[008] DFI 03/04/2017 : SPIRA 59462 : EST26B : Comparaison ecart vs seuil doit se faire sur le montant de l'écart converti en devise filiale
[009] DFI 01/06/2017 : SPIRA 61515 : EST26B : Correction dans l'appel a gettaux pour fournir correctement le SSD
==============================================================================*/

#include <utctlib.h>
#include <struct.h>
#include <estserv.h>
#include <string.h>
#include <stdlib.h>

#define TRACE_CTR

#define T_MAX_CALL 50000  // [004]
#define T_MAX_SUBTRS 5000

//[003]
#define EST26A  0
#define EST26B  1

#define DEBIT   1
#define CREDIT  2
//![003]

typedef struct {
    char SSD[4];
    char ESB[2];
    char CTR[10];
    char SEC[4];
    char UWY[5];
    char ACY[5];
    char SCOENDMTH[4];
} T_CALL;


/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE  *Kp_CMPfile;      //pointeur sur le fichier de complément;
FILE  *Kp_Seuilt;
FILE  *Curquot;
FILE  *Kp_SubTRSFile;   //pointeur sur fichier FSUBTRS
FILE  *Kp_OutExitf;     //Fichier de sortie de la table d'appel;
FILE  *Kp_AnoFile;
FILE  *Kp_OutTwo;

T_RUPTURE_VAR           bd_RuptSEUIL;   /* gestion rupture sur pilotage */
T_RUPTURE_SYNC_VAR      bd_RuptMvt;     /* gestion rupture sur prev */
T_RUPTURE_VAR           bd_RuptCall;    /* gestion rupture sur call */

int   kn_mode;         //Gestion du mode A ou B de l'évocard EST26
int   kn_balshey;
char  ks_CLODAT[9] = {'\0'};
char  ks_date[18] = {'\0'};
char  ks_VAC_NT[2] = {'\0'};
int   kn_Call = 0;
T_CALL    tpdb_CALL_LIST[T_MAX_CALL];
T_SUBTRS  subtrs[T_MAX_SUBTRS];

enum
{
    DIFF_SSD_CF = 0,
    DIFF_ESB_CF,        //1
    DIFF_LSTUPDUSR_CF,    //2
    DIFF_CTR_NF,        //3
    DIFF_SEC_NF,        //4
    DIFF_UWY_NF,        //5
    DIFF_ACY_NF,        //6
    DIFF_DETTRNCOD_CF,    //7
    DIFF_CUR_CF,        //8
    DIFF_ACCMNT_M,        //9
    DIFF_ESTCUR_CF,        //10
    DIFF_ESTMNT_M,        //11
    DIFF_DIFFMNT_M,        //12
    DIFF_SCOENDMTH_NF,    //13
    DIFF_GAP_D,            //14
    DIFF_VAC_NT,        //15
    DIFF_GAPSTS_NT,        //16
    DIFF_CMT_NT,        //17
    DIFF_UWGRP_CF        //18
};

enum
{
    SEUIL_SSD_CF = 0,
    SEUIL_ESB_CF,
    SEUIL_CUR_CF,
    SEUIL_AMT_M,
    SEUIL_AMT2_M,
    SEUIL_CREUSR_CF,
    SEUIL_CRE_D,
    SEUIL_LSTUPDUSR_CF,
    SEUIL_LSTUPD_D,
    SEUIL_TIMESTAMP
};

/*------------------*/
/*    Prototypes    */
/*------------------*/

int n_ActionLignePrev(char **ptb_InRec_Cur);
int n_ActionLigneCall(char **ptb_InRec_Cur);
int n_InitSEUIL(T_RUPTURE_VAR  *pbd_Rupt);
int n_InitMvt(T_RUPTURE_SYNC_VAR  *pbd_Rupt);
int n_InitCall(T_RUPTURE_VAR  *pbd_Rupt);
int n_ConditionSyncMvt (char **pbd_InRecOwner , char **pbd_InRecChild);
int n_ActionLigneMvt(char **ptb_InRecOwner , char **ptb_InRecChild);
int n_ActionFilsSansPere(char **ptb_InRec);                                    //[006]
int   WriteFormating(char **ptb_InRecChild);
int   WriteFormatingB(char **ptb_InRecChild);
int n_Is_In_Call(char* SSD, char* ESB, char* CTR, char* SEC, char* UWY, char* ACY);
int  n_Find_SCOENDMTH(char* SSD, char* ESB, char* CTR, char* SEC, char* UWY, char* ACY);



/*==============================================================================
objet :     point d'entree du programme
retour :    En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/

int main(int argc , char *argv[])
{
    /* int n_logsig_1 =0;
     int n_logsig_2 =0;*/
    char bal[5] = {0};


    /* Initialisation des signaux */
    InitSig () ;

    if ( n_BeginPgm (argc  , argv) == ERR )
        ExitPgm ( ERR_XX , "" );

    kn_mode = n_GetIntArgv(1);
    strncpy(ks_CLODAT, psz_GetCharArgv(2), 8);
    strncpy(ks_date, psz_GetCharArgv(3), 18);
    strncpy(ks_VAC_NT, psz_GetCharArgv(4), 1);
    strncpy(bal, ks_CLODAT, 4);
    kn_balshey = atoi(bal);

    printf("kn_mode: %i\nCLODAT: %s\nLAST SR: %s\nVAC: %s\n", kn_mode, ks_CLODAT, ks_date, ks_VAC_NT);

    /* Ouverture des fichiers en sortie */
    if ( n_OpenFileAppl ("ESTC8040_O1", "wt", &Kp_OutExitf) == ERR )
        ExitPgm ( ERR_XX , "Error : Kp_OutExitf file cannot load.\n" );

    if ( n_OpenFileAppl ("ESTC8040_O2", "wt", &Kp_AnoFile) == ERR )
        ExitPgm ( ERR_XX , "Error : Kp_AnoFile file cannot load.\n" );

    if ( n_OpenFileAppl ("ESTC8040_O3", "wt", &Kp_OutTwo) == ERR )
        ExitPgm ( ERR_XX , "Error : Kp_OutTwo file cannot load.\n" );

    if (n_OpenFileAppl ("ESTC8040_I4", "rb", &Curquot) == ERR )
        ExitPgm ( ERR_XX , "Error : Curquot file cannot load.\n" );

    if (n_OpenFileAppl ("ESTC8040_I5", "rb", &Kp_SubTRSFile) == ERR )
        ExitPgm ( ERR_XX , "Error : Kp_SubTRSFile file cannot load.\n" );

    if (n_ChargerTsubTRS(Kp_SubTRSFile) == ERR)
        ExitPgm ( ERR_XX , "n_ChargerTsubTRS failed" );

    if ( n_InitMvt(&bd_RuptMvt) )
        ExitPgm ( ERR_XX , "n_InitMvt failed" );

    if ( n_InitCall(&bd_RuptCall) )
        ExitPgm ( ERR_XX , "n_InitCall failed" );

    if ( n_InitSEUIL(&bd_RuptSEUIL) )
        ExitPgm ( ERR_XX , "n_InitSEUIL failed" );

    if ( n_ProcessingRuptureVar (&bd_RuptCall) == ERR )
        ExitPgm ( ERR_XX , "n_ProcessingRuptureVar failed" );

    if ( n_ProcessingRuptureVar (&bd_RuptSEUIL) == ERR )
        ExitPgm ( ERR_XX , "n_ProcessingRuptureVar failed" );

    /* Fermeture fichier */
    if (n_CloseFileAppl ("ESTC8040_I1", &bd_RuptMvt.pf_InputFil) == ERR)
        ExitPgm ( ERR_XX , "n_CloseFileAppl I1 failed" );

    if (n_CloseFileAppl ("ESTC8040_I2", &bd_RuptSEUIL.pf_InputFil) == ERR)
        ExitPgm ( ERR_XX , "n_CloseFileAppl I2 failed" );

    if (n_CloseFileAppl ("ESTC8040_I3", &bd_RuptCall.pf_InputFil) == ERR)
        ExitPgm ( ERR_XX , "n_CloseFileAppl I3 failed" );

    if (n_CloseFileAppl ("ESTC8040_I4", &Curquot) == ERR)
        ExitPgm ( ERR_XX , "n_CloseFileAppl I4 failed" );

    if (n_CloseFileAppl ("ESTC8040_I5", &Kp_SubTRSFile) == ERR)
        ExitPgm ( ERR_XX , "n_CloseFileAppl I5 failed" );

    if (n_CloseFileAppl ("ESTC8040_O1", &Kp_OutExitf) == ERR)
        ExitPgm ( ERR_XX , "n_CloseFileAppl O1 failed" );

    if (n_CloseFileAppl ("ESTC8040_O2", &Kp_AnoFile) == ERR)
        ExitPgm ( ERR_XX , "n_CloseFileAppl O2 failed" );

    if (n_CloseFileAppl ("ESTC8040_O3", &Kp_OutTwo) == ERR)
        ExitPgm ( ERR_XX , "n_CloseFileAppl O3 failed" );

    if ( n_EndPgm () == ERR )
        ExitPgm ( ERR_XX , "n_EndPgm failed" );

    exit(0);
}

/*==============================================================================
objet : fonction d'initialisation de la variable de gestion de rupture du
        fichier maitre.
retour :    0
==============================================================================*/
int n_InitSEUIL(T_RUPTURE_VAR  *pbd_Rupt)
{

    DEBUT_FCT("n_InitPrev");

    memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

    if ( n_OpenFileAppl ("ESTC8040_I2", "rt", &(pbd_Rupt->pf_InputFil)))
        RETURN_VAL (ERR);

    pbd_Rupt->n_NbRupture = 0;

    pbd_Rupt->n_ActionLigne = n_ActionLignePrev ;

    pbd_Rupt->c_Separ = '~' ;

    RETURN_VAL (0);
}


/*==============================================================================
objet : fonction lancee pour chaque ligne du maitre
retour :    0 ----> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePrev(char **ptb_InRec_Cur)
{
    n_ProcessingRuptureSyncVar (&bd_RuptMvt, ptb_InRec_Cur);
    RETURN_VAL (0);
}

/*==============================================================================
objet : fonction d'initialisation de la variable de gestion de rupture du
        fichier maitre.
retour :    0
==============================================================================*/
int n_InitCall(T_RUPTURE_VAR  *pbd_Rupt)
{

    DEBUT_FCT("n_InitCall");

    memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

    if ( n_OpenFileAppl ("ESTC8040_I3", "rt", &(pbd_Rupt->pf_InputFil)))
        RETURN_VAL (ERR);

    pbd_Rupt->n_NbRupture = 0;

    pbd_Rupt->n_ActionLigne = n_ActionLigneCall ;

    pbd_Rupt->c_Separ = '~' ;

    RETURN_VAL (0);
}


/*==============================================================================
objet : fonction lancee pour chaque ligne du maitre
retour :    0 ----> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneCall(char **ptb_InRec_Cur)
{
    if (kn_Call >= T_MAX_CALL)
    {
        printf("Depassement du nombre de lignes TCALL pouvant etre traitees : %i\n", T_MAX_CALL);
        RETURN_VAL(ERR);
    }

    strcpy(tpdb_CALL_LIST[kn_Call].SSD, ptb_InRec_Cur[0]);
    strcpy(tpdb_CALL_LIST[kn_Call].ESB, ptb_InRec_Cur[1]);
    strcpy(tpdb_CALL_LIST[kn_Call].CTR, ptb_InRec_Cur[2]);
    strcpy(tpdb_CALL_LIST[kn_Call].UWY, ptb_InRec_Cur[3]);
    strcpy(tpdb_CALL_LIST[kn_Call].SEC, ptb_InRec_Cur[4]);
    strcpy(tpdb_CALL_LIST[kn_Call].ACY, ptb_InRec_Cur[5]);
    strcpy(tpdb_CALL_LIST[kn_Call].SCOENDMTH, ptb_InRec_Cur[6]);

    ++kn_Call;

    RETURN_VAL(OK);
}


/*==============================================================================
objet : Initialisation de la synchronisation du maitre avec l'esclave Perim
retour :    OK
==============================================================================*/
int n_InitMvt(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
    DEBUT_FCT("n_InitMvt");

    memset( pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;

    /* ouverture du fichier esclave */
    n_OpenFileAppl ("ESTC8040_I1", "rt", &(pbd_Rupt->pf_InputFil));

    pbd_Rupt->n_NbRupture = 0;

    pbd_Rupt->ConditionEndSync      = n_ConditionSyncMvt ;
    pbd_Rupt->n_ActionLigne         = n_ActionLigneMvt ;
    pbd_Rupt->n_FilsSansPere        = n_ActionFilsSansPere; //[006]


    pbd_Rupt->c_Separ               = '~' ;

    RETURN_VAL (OK);
}

/*==============================================================================
objet :     fonction de test de synchro
retour :    0       ---> pbd_InRecOwner = pbd_InRecChild
                        ( egalite de rubriques a synchroniser)
            > 0     ---> pbd_InRecOwne> > pbd_InRecChild
            < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncMvt (char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
                        char **pbd_InRecChild  /* adresse de la ligne de l'esclave */ )
{
    int ret;

    DEBUT_FCT("n_ConditionSyncMvt");


    if ( (ret = strcmp(pbd_InRecOwner[SEUIL_SSD_CF], pbd_InRecChild[DIFF_SSD_CF])) != 0 )
        RETURN_VAL (ret);
    if ( (ret = strcmp(pbd_InRecOwner[SEUIL_ESB_CF], pbd_InRecChild[DIFF_ESB_CF])) != 0 )
        RETURN_VAL (ret);
    //  [006]
    /*    if ( (ret = strcmp(pbd_InRecOwner[SEUIL_CUR_CF], pbd_InRecChild[DIFF_CUR_CF])) != 0 )
            RETURN_VAL (ret);*/

    RETURN_VAL (0);
}

/*==============================================================================
objet : fonction lancee pour chaque ligne des previsions synchronisee
        avec les mouvements comptables
retour :    OK ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/

int n_ActionLigneMvt(char **ptb_InRecOwner , /* adresse de la ligne du maitre */
                     char **ptb_InRecChild)  /* adresse de la ligne de l'esclave */
{
    double Diff = 0.0;
    char Diffmnt[50];
    memset(Diffmnt, 0, 50);

    T_SUBTRS SubTRS;

    double accmnt = atof(ptb_InRecChild[DIFF_ACCMNT_M]);
    double estmnt = atof(ptb_InRecChild[DIFF_ESTMNT_M]);

    // taux de devise (Euro/Dollar, Yen/Franc, ...)
    double Taux = d_GetTaux(Curquot, (char)atoi(ptb_InRecChild[DIFF_SSD_CF]), //[009]
                            (short)atoi(ptb_InRecChild[DIFF_UWY_NF]),
                            ptb_InRecChild[DIFF_ESTCUR_CF],
                            ptb_InRecChild[DIFF_CUR_CF]);

    // [008]
    double Taux_ecart = d_GetTaux(Curquot, (char)atoi(ptb_InRecChild[DIFF_SSD_CF]), //[009]
                                  (short)atoi(ptb_InRecChild[DIFF_UWY_NF]),
                                  ptb_InRecChild[DIFF_CUR_CF],
                                  ptb_InRecOwner[SEUIL_CUR_CF]);


    if (n_FindTsubTRS(&SubTRS, ptb_InRecChild[DIFF_DETTRNCOD_CF]) == -1)
    {
        printf("DIFF_DETTRNCOD_CF non trouve dans SBTRS\n");
        return (OK);
    }

    //[007]
    if (SubTRS.TRSTYPE_CT == 4)
    {
        return (OK);
    }

    ptb_InRecChild[DIFF_GAP_D] = ks_date;

    if (Taux <= 0 || Taux_ecart <= 0) // [008]
    {
    	n_WriteCols(Kp_AnoFile, ptb_InRecChild, SEPARATEUR, 0); //[009]
        RETURN_VAL(OK);
    }
    accmnt *= Taux;

    if (kn_mode == EST26A)
    {
        ptb_InRecChild[DIFF_VAC_NT] = ks_VAC_NT;
        Diff = abs(estmnt - accmnt);
        if (Diff * Taux_ecart >= atof(ptb_InRecOwner[SEUIL_AMT_M])) // [008]
        {
            sprintf(Diffmnt, "%-.3f", Diff);
            ptb_InRecChild[DIFF_DIFFMNT_M] = Diffmnt;
            WriteFormating(ptb_InRecChild);
        }
    }
    else if (kn_mode == EST26B)
    {
        if (atoi(ptb_InRecChild[DIFF_ACY_NF]) < (kn_balshey - 1) ||
                atoi(ptb_InRecChild[DIFF_ACY_NF]) > kn_balshey ||
                atoi(SubTRS.LOGSIG_CT) == 0)
            RETURN_VAL(OK);
        Diff = accmnt - estmnt;
        if (atoi(SubTRS.LOGSIG_CT) == DEBIT)
            Diff *= -1;
        if (Diff * Taux_ecart >= atof(ptb_InRecOwner[SEUIL_AMT2_M])) // [008]
        {
            sprintf(Diffmnt, "%-.3f", Diff);
            ptb_InRecChild[DIFF_DIFFMNT_M] = Diffmnt;
            WriteFormatingB(ptb_InRecChild);
        }
    }
    else
    {
        printf("kn_mode(%d) != EST26A(%d) && kn_mode != EST26B(%d)\n", kn_mode, EST26A, EST26B);
        RETURN_VAL(ERR);
    }
    RETURN_VAL(OK);
}

int   WriteFormatingB(char **ptb_InRecChild)
{
    char  *format[17];
    char *Out2[7];                                        //[005]

    if (atof(ptb_InRecChild[DIFF_ACCMNT_M]) == 0)
        RETURN_VAL (0);

    format[0] = ptb_InRecChild[DIFF_SSD_CF];
    format[1] = ptb_InRecChild[DIFF_ESB_CF];
    format[2] = "    ";
    format[3] = ptb_InRecChild[DIFF_CTR_NF];
    format[4] = ptb_InRecChild[DIFF_SEC_NF];
    format[5] = ptb_InRecChild[DIFF_UWY_NF];
    format[6] = ptb_InRecChild[DIFF_ACY_NF];
    format[7] = ptb_InRecChild[DIFF_DETTRNCOD_CF];
    format[8] = ptb_InRecChild[DIFF_ACCMNT_M];
    format[9] = ptb_InRecChild[DIFF_ESTMNT_M];
    format[10] = ptb_InRecChild[DIFF_DIFFMNT_M];
    format[11] = ks_CLODAT;
    format[12] = ptb_InRecChild[DIFF_GAP_D];
    format[13] = ptb_InRecChild[DIFF_GAPSTS_NT];
    format[14] = ptb_InRecChild[DIFF_CUR_CF];
    format[15] = ptb_InRecChild[DIFF_CMT_NT];
    format[16] = NULL;

    n_WriteCols(Kp_OutExitf, format, SEPARATEUR, 0);

    // remplissage de Kp_OutTwo
    //  [005]    Correction de l'identification de la notification
    Out2[0] = ptb_InRecChild[DIFF_SSD_CF];
    Out2[1] = ptb_InRecChild[DIFF_ESB_CF];
    Out2[2] = ptb_InRecChild[DIFF_CTR_NF];
    Out2[3] = ptb_InRecChild[DIFF_SEC_NF];
    Out2[4] = ptb_InRecChild[DIFF_UWY_NF];
    Out2[5] = ptb_InRecChild[DIFF_UWGRP_CF];
    Out2[6] = NULL;
    //  [\005]
    n_WriteCols(Kp_OutTwo, Out2, SEPARATEUR, 0);

    RETURN_VAL (OK);
}

int   WriteFormating(char **ptb_InRecChild)
{
    char* format[18];
    char* Out2[7];                                        //[005]
    int sco;
    char sco_in_char[5];

    // Si pas dans TCALL => return
    if (n_Is_In_Call( ptb_InRecChild[DIFF_SSD_CF] ,
                      ptb_InRecChild[DIFF_ESB_CF] ,
                      ptb_InRecChild[DIFF_CTR_NF] ,
                      ptb_InRecChild[DIFF_SEC_NF] ,
                      ptb_InRecChild[DIFF_UWY_NF] ,
                      ptb_InRecChild[DIFF_ACY_NF]) == 0)
    {

        return (0);
    }
    else

        if (atof(ptb_InRecChild[DIFF_ACCMNT_M]) == 0)
            RETURN_VAL (0);

    format[0] = ptb_InRecChild[DIFF_SSD_CF];
    format[1] = ptb_InRecChild[DIFF_ESB_CF];
    format[2] = "    ";
    format[3] = ptb_InRecChild[DIFF_CTR_NF];
    format[4] = ptb_InRecChild[DIFF_SEC_NF];
    format[5] = ptb_InRecChild[DIFF_UWY_NF];
    format[6] = ptb_InRecChild[DIFF_ACY_NF];
    format[7] = ptb_InRecChild[DIFF_DETTRNCOD_CF];
    format[8] = ptb_InRecChild[DIFF_ACCMNT_M];
    format[9] = ptb_InRecChild[DIFF_ESTMNT_M];
    format[10] = ptb_InRecChild[DIFF_DIFFMNT_M];
    /*  format[11] = ptb_InRecChild[DIFF_SCOENDMTH_NF];*/
    sco = n_Find_SCOENDMTH(ptb_InRecChild[DIFF_SSD_CF] ,
                           ptb_InRecChild[DIFF_ESB_CF] ,
                           ptb_InRecChild[DIFF_CTR_NF] ,
                           ptb_InRecChild[DIFF_SEC_NF] ,
                           ptb_InRecChild[DIFF_UWY_NF] ,
                           ptb_InRecChild[DIFF_ACY_NF]);
    sprintf(sco_in_char, "%d", sco);
    format[11] = sco_in_char;
    //strcpy (format[11], sco_in_char);
    format[12] = ptb_InRecChild[DIFF_GAP_D];
    format[13] = ptb_InRecChild[DIFF_VAC_NT];
    format[14] = ptb_InRecChild[DIFF_GAPSTS_NT];
    format[15] = ptb_InRecChild[DIFF_CUR_CF];
    format[16] = ptb_InRecChild[DIFF_CMT_NT];
    format[17] = NULL;

    n_WriteCols(Kp_OutExitf, format, SEPARATEUR, 0);

    // remplissage de kp_OutTwo
    //  [005]    Correction de l'identification de la notification
    Out2[0] = ptb_InRecChild[DIFF_SSD_CF];
    Out2[1] = ptb_InRecChild[DIFF_ESB_CF];
    Out2[2] = ptb_InRecChild[DIFF_CTR_NF];
    Out2[3] = ptb_InRecChild[DIFF_SEC_NF];
    Out2[4] = ptb_InRecChild[DIFF_UWY_NF];
    Out2[5] = ptb_InRecChild[DIFF_UWGRP_CF];
    Out2[6] = NULL;
    //  [\005]
    n_WriteCols(Kp_OutTwo, Out2, SEPARATEUR, 0);


    RETURN_VAL (OK);
}


/*==============================================================================
[006]
objet :
      fonction lancee quand le fichier comptable participe seul

retour :
      OK ---> traitement correctement effectue
      ERR --> probleme rencontre
==============================================================================*/
int n_ActionFilsSansPere(char **ptb_InRec)
{
    n_WriteCols(Kp_AnoFile, ptb_InRec, SEPARATEUR, 0);

    RETURN_VAL (OK);
}

/*==============================================================================
objet :


retour :
      OK ---> traitement correctement effectue
      ERR --> probleme rencontre
==============================================================================*/
int n_Is_In_Call(char* SSD, char* ESB, char* CTR, char* SEC, char* UWY, char* ACY)
{
    int i;

    for (i = 0; i < kn_Call + 1; i++)
    {
        if (strcmp(tpdb_CALL_LIST[i].SSD , SSD) == 0 &&
                strcmp(tpdb_CALL_LIST[i].ESB , ESB) == 0 &&
                strcmp(tpdb_CALL_LIST[i].CTR , CTR) == 0 &&
                strcmp(tpdb_CALL_LIST[i].SEC , SEC) == 0 &&
                strcmp(tpdb_CALL_LIST[i].UWY , UWY) == 0 &&
                strcmp(tpdb_CALL_LIST[i].ACY , ACY) == 0)
        {
            return (1);
        }
    }
    return (0);
}

int n_Find_SCOENDMTH(char* SSD, char* ESB, char* CTR, char* SEC, char* UWY, char* ACY)
{
    int i;
    int SCOENDMTH_TMP = 0;

    for (i = 0; i < kn_Call + 1; i++)
    {
        if (strcmp(tpdb_CALL_LIST[i].SSD , SSD) == 0 &&
                strcmp(tpdb_CALL_LIST[i].ESB , ESB) == 0 &&
                strcmp(tpdb_CALL_LIST[i].CTR , CTR) == 0 &&
                strcmp(tpdb_CALL_LIST[i].SEC , SEC) == 0 &&
                strcmp(tpdb_CALL_LIST[i].UWY , UWY) == 0 &&
                strcmp(tpdb_CALL_LIST[i].ACY , ACY) == 0)
        {
            // if (atoi(tpdb_CALL_LIST[i].SCOENDMTH) > atoi(sco))
            //   strcpy(sco, tpdb_CALL_LIST[i].SCOENDMTH);
            if (atoi(tpdb_CALL_LIST[i].SCOENDMTH) > SCOENDMTH_TMP)
                SCOENDMTH_TMP = atoi(tpdb_CALL_LIST[i].SCOENDMTH);
        }
    }
    return SCOENDMTH_TMP;
}
