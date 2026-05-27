#ifndef __ESTC2148
#define __ESTC2148

/*==============================================================================
nom de l'application          : Calcul de DAC
nom du source                 : ESTC2148.c
date de creation              : 26/07/2010
auteur                        : D.GATIBELZA
squelette de base             : batch
------------------------------------------------------------------------------
description :   ESTVIE19177 V10 Mettre en place un calcul spécial de DAC
                pour Köln automatic DAC calculation taking into account the fanancing commission,
                the technical result,
                the interest on deposit
------------------------------------------------------------------------------*/

FILE    *Fichier_O1;                                            // Fichier en sortie : LIFEST_O1
FILE    *Fichier_O2;                                            // Fichier de log en sortie
FILE    *FichierTLIFDRI_I5;


void DEBUT_FONCTION                     (char *);

char Ksz_DateJour[11];      /* Date de traitement */
char Ksz_AnneeBilan[5];
char Ksz_MoisBilan[3];
char Ksz_DateJour_Mod[18];


// -------------------------------------------------------------
// PERIMETRE
// -------------------------------------------------------------
struct {
    char CTR_NF[10];
    char UWY_NF[5];
    char UW_NT[3];
    char END_NT[3];
    char SEC_NF[3];
}T_SECSTS_RESIL[200];

int nbSECSTS_RESIL=0;

#define NB_MAX_CTR_SEC_UWY      1000
typedef struct {
    char CTR_NF[10];
    int SEC_NF;
    int UWY_NF;
    int CNATYP;
}T_CNATYP;

int nbCtrSecUwy=NB_MAX_CTR_SEC_UWY;
T_CNATYP STR_CNATYP[NB_MAX_CTR_SEC_UWY];

int RechercheCNATYP(char **pbd_InRecGT);

int n_InitPERIMETRE                     (T_RUPTURE_VAR  *);     // Initialisation de traitement du fichier PERIMETRE
int n_ConditionRupture_PERIMETRE_0      (char **, char **);     //
int n_ActionRuptureFirst_PERIMETRE_0    (char **);              //
int n_ActionLigne_PERIMETRE             (char **);              //
int n_ActionRuptureLast_PERIMETRE_0     (char **);              //

T_RUPTURE_VAR bd_RuptPERIMETRE;                                 // Gestion rupture sur le perimetre
int Resilie =0;


// -------------------------------------------------------------
// TFAMCNA
// -------------------------------------------------------------
#define         CNA_CTR_NF           0
#define         CNA_UWY_NF           1
#define         CNA_UW_NT            2
#define         CNA_END_NT           3
#define         CNA_SEC_NF           4
#define         CNA_ACY_NF           5
#define         CNA_CNACONSO_R       6
#define         CNA_CNASOCI_R        7
#define         CNA_ADMEXP_R         8
#define         CNA_COMMEN_L         9
#define         CNA_CRE_D            8
#define         CNA_CREUSR_CF        9
#define         CNA_LSTUPD_D        10
#define         CNA_LSTUPDUSR_CF    11


#define NB_MAX_UWY_TFAMCNA          100
typedef struct {
    int uwy_nf;
    int acy_nf[100];
    double tx[100];
    int nb_taux;
}T_FAMCNA;

int n_InitTFAMCNA_I4                    (T_RUPTURE_SYNC_VAR  *);// Initialisation de traitement du fichier TFAMCNA
int n_ActionLigneTFAMCNA_I4             (char **,  char **);    // à chaque ligne du fichier TFAMCNA_I4
int n_ConditionSyncPERIMETRE_TFAMCNA    (char **,  char **);    // Condition pour synchroniser avec le PERIMETRE
int n_ConditionRupture_TFAMCNA_I4_0     (char **,  char **);    //
//int n_ActionRuptureFirst_TFAMCNA_I4_0   (char **,  char **);    //
int n_ActionRuptureLast_TFAMCNA_I4_0    (char **,  char **);    //


int n_ChargerTABLEAU_TFAMCNA            (char **, int, T_FAMCNA *);
double n_TauxFamcna                     (T_FAMCNA *, int, int, int);

T_RUPTURE_SYNC_VAR bd_RuptTFAMCNA_I4;                           // Gestion rupture
int nb_TFAMCNA=0;
int curs_TACCPAR=0;
int nb_UWY_TFAMCNA_INT=0;
int nb_UWY_TFAMCNA_AE=0;
T_FAMCNA INT[NB_MAX_UWY_TFAMCNA];
T_FAMCNA AE[NB_MAX_UWY_TFAMCNA];



// -------------------------------------------------------------
// LIFEST
// -------------------------------------------------------------
int n_InitLIFEST_I2                     (T_RUPTURE_SYNC_VAR *); // Initialisation du taitement du fichier LIFEST_I2
int n_ActionLigneLIFEST_I2              (char **,  char **);    // à chaque ligne du fichier LIFEST_I2
int n_ConditionRupture_LIFEST_I2        (char **,  char **);    //
int n_ActionRuptureFirst_LIFEST_I2      (char **,  char **);    //
int n_ActionRuptureLast_LIFEST_I2       (char **,  char **);    //
int n_ConditionRupture_LIFEST_I2_0      (char **,  char **);    //
int n_ActionRuptureFirst_LIFEST_I2_0    (char **,  char **);    //
int n_ConditionSyncPERIMETRE_LIFEST     (char **,  char **);    // Condition pour synchroniser avec le PERIMETRE

int n_isRESILIE                         (char **);

T_RUPTURE_SYNC_VAR bd_RuptLIFEST_I2;                            // Gestion synchro avec le GT


// -------------------------------------------------------------
// TACCPAR
// -------------------------------------------------------------
typedef struct {
    int  uwy_nf;
    char acmtrs[1000][9];
    int  nb_acmtrs;
}T_POSTE_ACCPAR;


int n_InitTACCPAR                       (T_RUPTURE_VAR  *);     // Initialisation de traitement du fichier TACCPAR
int n_ActionLigneTACCPAR                (char **);              // à chaque ligne du fichier TACCPAR_I3
int n_isPOSTE_ACCPAR                    (char *, T_POSTE_ACCPAR *);
int n_ChargerTABLEAU_TACCPAR            (char **, int, T_POSTE_ACCPAR *);
char *n_RechercheTACCPAR                (char **, int, int);
char sz_DETTRS[2][9];
char sz_RETCOD[2][2];
char sz_ADJSIG[2][2];
char sz_SPIMOD[2][2];
char sz_ADJCOD[2][2];
char sz_DETTRNCOD[2][6]; //abir
T_RUPTURE_VAR bd_RuptTACCPAR;                                   // Gestion rupture



// -------------------------------------------------------------
// TLIFDRI
// -------------------------------------------------------------
#define NB_MAX_LIFDRI 150000
int n_ChargerTLIFDRI                    ();
int nb_TLIFDRI=0;
int curs_TLIFDRI=0;

int n_ACY_DernierCompteComplet          (char *);

int UWY_NF_premier=0;
int UWY_NF_dernier=0;

int ACCEPTouRETRO=0;


// -------------------------------------------------------------
// DAC
// -------------------------------------------------------------
int IDAC_ACMTRS[2]={1193, 2193};
int IDAC_ACMTRS_LIB[2]={1194, 2194};
int SDAC_ACMTRS[2]={1183, 2183};

double ligne_SDAC1[2];
double ligne_SDAC2[2];
double *SDAC_prec[2];
double *SDAC_cur[2];

double ligne_IDAC1[2];
double ligne_IDAC2[2];
double *IDAC_prec[2];
double *IDAC_cur[2];

T_POSTE_ACCPAR SDAC[2];



// -------------------------------------------------------------
// TFR
// -------------------------------------------------------------
T_POSTE_ACCPAR RESTEC;



// -------------------------------------------------------------
// PROFIT COMMISSION ( PC )
// -------------------------------------------------------------
#define PC_ACCEPT "1160"
#define PC_RETRO  "2160"

// -------------------------------------------------------------
// VARIABLES de CALCUL
// -------------------------------------------------------------
double WP[2];
double TFR=0.0;
double PC[2];

#define ACCEPT  0
#define RETRO   1


#endif /* __ESTC2148 */
