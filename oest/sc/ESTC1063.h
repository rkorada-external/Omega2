/*==============================================================================
[000] 01/10/2012 Roger Cassis   :spot:24041 - Nouveau .h pour Solvency
------------------------------------------------------------------------------
historique des modifications :
[001] jj/mm/aaaa prog name      :spot:xxxxx
================================================================================*/

/*
** Objet  : FPLATXCUM (Maitre)
** Entree : ESTC1063_I1
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

/*
** Objet  : GTSIIPIVOT (Esclave --> FPLATXCUM)
** Entree : ESTC1063_I2
** Cle    : (RETCTR_NF, RETSEC_NF, RTY_NF) (3 champs) */
#define GTSII2_SSD_CF       0  
#define GTSII2_ESB_CF       1 
#define GTSII2_CTR_NF       2 
#define GTSII2_END_NT       3 
#define GTSII2_SEC_NF       4 
#define GTSII2_UWY_NF       5 
#define GTSII2_UW_NT        6 
#define GTSII2_ACMCUR_CF    7 
#define GTSII2_CED_NF       8 
#define GTSII2_BRK_NF       9 
#define GTSII2_PAY_NF      10
#define GTSII2_KEY_NF      11
#define GTSII2_RETCTR_NF   12
#define GTSII2_RETEND_NT   13
#define GTSII2_RETSEC_NF   14
#define GTSII2_RTY_NF      15
#define GTSII2_RETUW_NT    16
#define GTSII2_RETCUR_CF   17
#define GTSII2_PLC_NT      18
#define GTSII2_RTO_NF      19
#define GTSII2_SEGLOB_CF   20
#define GTSII2_ULR_M       21
#define GTSII2_ULRY_NF     22
#define GTSII2_WPREMIUM_M  23
#define GTSII2_WCHARGES_M  24
#define GTSII2_WCLAIM_M    25
#define GTSII2_UPR_R       26
#define GTSII2_SCOEGP_M    27
#define GTSII2_FPREMIUM_M  28
#define GTSII2_UCR_R       29
#define GTSII2_PRCO_M      30
#define GTSII2_PRCI_M      31
#define GTSII2_NORME_CF    32
#define GTSII2_PRMDSC_R    33
#define GTSII2_CLMDSC_R    34
#define GTSII2_BDTRAT_R    35
#define GTSII2_PRMRESD_M   36
#define GTSII2_PRMRESB_M   37


