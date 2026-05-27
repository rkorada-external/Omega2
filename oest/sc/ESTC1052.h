/*==============================================================================
[000] 26/04/2012 Roger Cassis   :spot:23802 - Nouveau .h pour Solvency
------------------------------------------------------------------------------
historique des modifications :
[001] jj/mm/aaaa prog name      :spot:xxxxx
================================================================================*/

#ifndef __ESTC1052
#define __ESTC1052

/*
** Objet  : FPLATXCUM (Maitre)
** Entree : RETM0532_I1
** Cle    : (RETCTR_NF, RETSEC_NF, RTY_NF) (3 champs) */
#define PLA_RETCTR_NF       0
#define PLA_RETSEC_NF       1
#define PLA_RTY_NF          2
#define PLA_PLC_NT          3
#define PLA_RETSIGSHA_TOT_R 4
#define PLA_RETSIGSHA_INT_R 5
#define PLA_RETSIGSHA_QOT_R 6
#define PLA_RTO_NF          7       //[001]
#define PLA_NBLIGNES        8       //[001]

T_RUPTURE_VAR Kbd_ruptFPLATXCUM;

int n_InitFPLATXCUM(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLigneFPLATXCUM(char **pbd_InRec_Cur);


/*
** Objet  : FACCTRTGT (Esclave --> FPLATXCUM)
** Entree : RETM0532_I2
** Cle    : (RETCTR_NF, RETSEC_NF, RTY_NF) (3 champs) */
#define GT_SSD_CF           0
#define GT_ESB_CF           1
#define GT_BALSHEY_NF       2
#define GT_BALSHRMTH_NF     3
#define GT_BALSHRDAY_NF     4
#define GT_TRNCOD_CF        5
#define GT_DBLTRNCOD_CF     6
#define GT_CTR_NF           7
#define GT_END_NT           8
#define GT_SEC_NF           9
#define GT_UWY_NF           10
#define GT_UW_NT            11
#define GT_OCCYEA_NF        12
#define GT_ACY_NF           13
#define GT_SCOSTRMTH_NF     14
#define GT_SCOENDMTH_NF     15
#define GT_CLM_NF           16
#define GT_CUR_CF           17
#define GT_AMT_M            18
#define GT_CED_NF           19
#define GT_BRK_NF           20
#define GT_PAY_NF           21
#define GT_KEY_NF           22
#define GT_RETCTR_NF        23
#define GT_RETEND_NT        24
#define GT_RETSEC_NF        25
#define GT_RETRTY_NF        26
#define GT_RETUW_NT         27
#define GT_RETOCCYEA_NF     28
#define GT_RETACY_NF        29
#define GT_RETSCOSTRMTH_NF  30
#define GT_RETSCOENDMTH_NF  31
#define GT_RCL_NF           32
#define GT_RETCUR_CF        33
#define GT_RETAMT_M         34
#define GT_PLC_NT           35
#define GT_RTO_NF           36
#define GT_INT_NF           37
#define GT_RETPAY_NF        38
#define GT_RETKEY_CF        39
#define GT_RETINTAMT_M      40

T_RUPTURE_SYNC_VAR Kbd_ruptFACCTRTGT;

int n_InitSyncFACCTRTGT         (T_RUPTURE_SYNC_VAR *);
int n_ConditionSyncFACCTRTGT    (char **, char **);
int n_InitFACCTRTGT             (T_RUPTURE_SYNC_VAR  *);
int n_ActionLigneSyncFACCTRTGT  (char **, char **);
int n_ActionFsPFACCTRTGT        (char **);


/*
** Objet  : GT
** Sortie : RETM0532_O1 */
FILE *Kp_OutputFileGT;


#endif /* __RETM0532 */

