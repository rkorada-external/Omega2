/*==============================================================================
 Nom de l'application          : Loader programs V2
 Nom du source                 : ESTC1058.c
 Revision                      : $Revision: 1.4 $
 Date de creation              : 09/01/2012
 Auteur                        : gensource v2.0 (auto)
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
     Historique des modifications :
[01] 01/06/2012 -=Dch=-  :spot:23937 SOLVENCY II
[02] 10/01/2013 R. cassis  :spot:24041 livraison Solvency 2
[03] 13/05/2016 Florent    :spot:30543 on passe à 65 années
[04] 03/09/2018 Charles Socie : EXT-IFRS17-903121  REQ 10.02 add RBD_ACMTRS3_NT
==============================================================================*/
#ifndef __ESTC1058
#define __ESTC1058

/*--------------------------------------------------*/
/* Prototype des fonctions                          */
/*--------------------------------------------------*/
int    n_InitRfrBatchIN(T_RUPTURE_VAR *pbd_Rupt);
int    n_ActionLigneRfrBatchIN(char **pbd_InRec_Cur);
void   ChargementRating();
void   ChargementPattern();
long   getFileNbLigne(FILE * fl);
void   freeTableau(char** tab);
char** split(char* chaine, const char* delim, int vide);
void   addPattern( char **tab, int idx);

/*
** Objet  : EssaiBatchOut
** Sortie : ESTC1058_O1
*/
typedef struct {
    char  retroc[6];
    char  RATING_CF[4];
//  char   NORME_CF[21];
} T_RATING;

enum COL_D {
    RBD_SSD_CF = 0,
    RBD_ESB_CF,
    RBD_BALSHEY_NF,
    RBD_BALSHRMTH_NF,
    RBD_BALSHRDAY_NF,
    RBD_TRNCOD_CF ,
    RBD_DBLTRNCOD_CF,
    RBD_CTR_NF,
    RBD_END_NT,
    RBD_SEC_NF,
    RBD_UWY_NF,
    RBD_UW_NT ,
    RBD_OCCYEA_NF ,
    RBD_ACY_NF,
    RBD_SCOSTRMTH_NF,
    RBD_SCOENDMTH_NF,
    RBD_CLM_NF,
    RBD_CUR_CF,
    RBD_AMT_M ,
    RBD_CED_NF,
    RBD_BRK_NF,
    RBD_PAY_NF,
    RBD_KEY_NF,
    RBD_RETCTR_NF,
    RBD_RETEND_NT,
    RBD_RETSEC_NF,
    RBD_RTY_NF,
    RBD_RETUW_NT,
    RBD_RETOCCYEA_NF,
    RBD_RETACY_NF,
    RBD_RETSCOSTRMTH_NF,
    RBD_RETSCOENDMTH_NF,
    RBD_RCL_NF,
    RBD_RETCUR_CF,
    RBD_RETAMT_M,
    RBD_PLC_NT,
    RBD_RTO_NF,
    RBD_INT_NF,
    RBD_RETPAY_NF,
    RBD_RETKEY_CF,
    RBD_RETINTAMT_M,
    RBD_ACMTRS_NT,
    RBD_ACMAMT_MC,
    RBD_ACMCUR_CF,
    RBD_PRS_CF,
    RBD_SEG_NF,
    RBD_LOB_CF,
    RBD_NAT_CF,
    RBD_TYP_CT,
    RBD_NORME,
    RBD_RATING,
    RBD_PATCAT,
    RBD_PATTYP,
    RBD_PAT_NF,
    RBD_AN1,
    RBD_ACMTRS3_NT  = PATTERNSII_ANNEES + RBD_AN1 + 4

};

#endif /* __ESTC1058 */
