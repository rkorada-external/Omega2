#include "utctlib.h"
/* Position des champs dans le perimetre */
#define SEPARATEUR '~'
#define PER_SSD_CF 0
#define PER_SEGTYP_CT 1
#define PER_CTR_NF 2
#define PER_END_NT 3
#define PER_SEC_NF 4
#define PER_UWY_NF 5
#define PER_UW_NT 6
#define PER_ACCESB_CF 7
#define PER_ADMMODPRM_CT 8
#define PER_ANLCTY_CF 9
#define PER_CAN_DT 10
#define PER_CED_NF 11
#define PER_CLICTY_CF 12
#define PER_CLINAT_CF 13
#define PER_CLMACT_M 14
#define PER_COMTYP_CT 15
#define PER_CTBGENFEE_R 16
#define PER_CTBTYP_CT 17
#define PER_CTRINC_D 18
#define PER_CTRRET_B 19
#define PER_CUTSHA_R 20
#define PER_DIV_NT 21
#define PER_EGPCUR_CF 22
#define PER_ESTCRB_CT 23
#define PER_ESTCTR_NF 24
#define PER_ESTEND_B 25
#define PER_ESTSEC_NF 26
#define PER_EXP_D 27
#define PER_FIXCOM_R 28
#define PER_FRSUWY_NF 29
#define PER_GANPAYORD_NT 30
#define PER_GAR_CF 31
#define PER_GENPRMPAY_NF 32
#define PER_GENPRMSEN_NF 33
#define PER_INSPOL_R 34
#define PER_LAYCAP_M 35
#define PER_LIFTRTTYP_CF 36
#define PER_LOB_CF 37
#define PER_LOSCOREXI_B 38
#define PER_LOSCORHIG_R 39
#define PER_LOSCORLOW_R 40
#define PER_LOSCORRAT_R 41
#define PER_LOSCTB_R 42
#define PER_LOSCTBEXI_B 43
#define PER_MAXCOM_R 44
#define PER_MAXRATCLP_R 45
#define PER_MINCOM_R 46
#define PER_MINRATCLP_R 47
#define PER_NAT_CF 48
#define PER_ORDNBR_NT 49
#define PER_PCPCUR_CF 50
#define PER_PCPRSKTRY_CF 51
#define PER_POLDURMTH_NF 52
#define PER_PRD_NF 53
#define PER_PRFCOM_R 54
#define PER_PRFCOMEXI_B 55
#define PER_PRMEFFLOA_M 56
#define PER_PRMEFFLOA_R 57
#define PER_PRMFIXEFF_R 58
#define PER_PRMFLCRAT_B 59
#define PER_PRMMAXEFF_R 60
#define PER_PRMMINEFF_R 61
#define PER_PRMNETCOM_B 62
#define PER_PRMPRTSCL_B 63
#define PER_REIEXI_B 64
#define PER_REIFRE_B 65
#define PER_REINBR_N 66
#define PER_REIUNL_B 67
#define PER_RESTRFDUR_N 68
#define PER_RESTRFTYP_CF 69
#define PER_SBJCPTDEF_B 70
#define PER_SBJPRM_M 71
#define PER_SCLCOMEXI_B 72
#define PER_SCLCTBEXI_B 73
#define PER_SCOEGP_M 74
#define PER_SCOINC_D 75
#define PER_SECACCSTS_CT 76
#define PER_SECINC_D 77
#define PER_SECSTS_CT 78
#define PER_SEG_NF 79
#define PER_SOB_CF 80
#define PER_SUBNAT_CF 81
#define PER_SUPLOATYP_CT 82
#define PER_TOP_CF 83
#define PER_CTRNAT_CT 84
#define PER_UWGRP_CF 85
#define PER_ACCFRQ_CT 86
#define PER_WRKCAT_CT 87
#define PER_ORGINC_D 88
#define PER_LIARIDSHA_B 89
#define PER_FLAPRM_B 90
#define PER_RIDSHA_R 91
#define PER_CTBCALLVL_CF 92
#define PER_CTBCOM_B 93
#define PER_PRMPRT_M 94
#define PER_PRMPRTCUR_CF 95
#define PER_ACCADMTYP_CT 96
#define PER_SBJPRMCUR_CF 97
#define PER_CTRSTS_CT 98
#define PER_OVRCOM_R 99
#define PER_OVRCOMTYP_CT 100
#define PER_TAXCNDEXI_B 101
#define PER_PRDBRK_R 102
#define PER_ACCBRK_R 103
#define PER_LIACUR_CF 104
#define PER_ERNPRMADM_B 105
#define PER_RETCTRCAT_CF 106
#define PER_CLECUTPER_B 107
#define PER_CLECUTPER_NB 108
#define PER_ORICUR_B 109
#define PER_RETACCADM_B 110
#define PER_SSDRTO_B 111
#define PER_RAICOM_B 112
#define PER_DIFMTH_NF 113
#define PER_NBCOL 113



/* position des champs dans le perimetre annexe PERIFR */

#define PERFR_CTR_NF 0
#define PERFR_END_NT 1
#define PERFR_SEC_NF 2
#define PERFR_UWY_NF 3
#define PERFR_UW_NT 4
#define PERFR_REILIN_NT 5
#define PERFR_REIPRM_M 6
#define PERFR_REIPRM_R 7
#define PERFR_REIPRMBAS_R 8
#define PERFR_REIRNK_N 9
#define PERFR_SEGTYP_CT 10
#define PERFR_SSD_CF 11


/* position des champs dans le perimetre des echeances de primes 
provisionnelles*/

#define PERPRMD_CTR_NF 0
#define PERPRMD_END_NT 1
#define PERPRMD_SEC_NF 2
#define PERPRMD_UWY_NF 3
#define PERPRMD_UW_NT 4
#define PERPRMD_PRMDUE_D 5
#define PERPRMD_PRMDUE_M 6
#define PERPRMD_PRMDUECUR_CF 7
#define PERPRMD_PRMLIN_NT 8
#define PERPRMD_SEGTYP_CT 9
#define PERPRMD_SSD_CF 10


/* position des champs dans le perimetre annexe famille des charges taxes */

#define PERFCT_CTR_NF 0
#define PERFCT_END_NT 1
#define PERFCT_SEC_NF 2
#define PERFCT_UWY_NF 3
#define PERFCT_UW_NT 4
#define PERFCT_SEGTYP_CT 5
#define PERFCT_SSD_CF 6
#define PERFCT_TAX_R 7
#define PERFCT_TAXLIN_NT 8
#define PERFCT_TAXTYP_CT 9


/* position des champs dans le perimetre annexe famille des charges iterees */

#define PERFCI_CTR_NF 0
#define PERFCI_END_NT 1
#define PERFCI_SEC_NF 2
#define PERFCI_UWY_NF 3
#define PERFCI_UW_NT 4
#define PERFCI_CHGLIN_NT 5
#define PERFCI_CHGTYP_B 6
#define PERFCI_MAX_R 7
#define PERFCI_MAXRAT_R 8
#define PERFCI_MIN_R 9
#define PERFCI_MINRAT_R 10
#define PERFCI_RATTYP_B 11
#define PERFCI_SEGTYP_CT 12
#define PERFCI_SSD_CF 13


/* Position des champs dans les postes regroupes */

#define TRS_ACMTRS_NT 0
#define TRS_DETTRS_CF 1
#define TRS_NBCOL 2


/* Position des champs dans le GT */

#define GT_SSD_CF 0
#define GT_ESB_CF 1
#define GT_BALSHEY_NF 2
#define GT_BALSHRMTH_NF 3
#define GT_BALSHRDAY_NF 4
#define GT_TRNCOD_CF 5
#define GT_DBLTRNCOD_CF 6
#define GT_CTR_NF 7
#define GT_END_NT 8
#define GT_SEC_NF 9
#define GT_UWY_NF 10
#define GT_UW_NT 11
#define GT_OCCYEA_NF 12
#define GT_ACY_NF 13
#define GT_SCOSTRMTH_NF 14
#define GT_SCOENDMTH_NF 15
#define GT_CLM_NF 16
#define GT_CUR_CF 17
#define GT_AMT_M 18
#define GT_CED_NF 19
#define GT_BRK_NF 20
#define GT_PAY_NF 21
#define GT_KEY_NF 22
#define GT_RETCTR_NF 23
#define GT_RETEND_NT 24
#define GT_RETSEC_NF 25
#define GT_RTY_NF 26
#define GT_RETUW_NT 27
#define GT_RETOCCYEA_NF 28
#define GT_RETACY_NF 29
#define GT_RETSCOSTRMTH_NF 30
#define GT_RETSCOENDMTH_NF 31
#define GT_RCL_NF 32
#define GT_RETCUR_CF 33
#define GT_RETAMT_M 34
#define GT_PLC_NT 35
#define GT_RTO_NF 36
#define GT_INT_NF 37
#define GT_RETPAY_NF 38
#define GT_RETKEY_CF 39
#define GT_ESTCUR_CF 40
#define GT_ESTAMT_M 41
#define GT_NAT_CF 42
#define GT_ACMTRS_NT 43
#define GT_ESTCTR_NF 44
#define GT_ESTSEC_NF 45
#define GT_LOB_CF 46
#define GT_SCOEGP_M 47
#define GT_ESTCRB_CT 48
#define GT_LIFTRTTYP_CF 49
#define GT_ACCADMTYP_CT 50
#define GT_SECSTS_CT 51
#define GT_PRD_NF 52
#define GT_SEG_NF 53
#define GT_COMACC_B 54
#define GT_ADJCOD_CT 55
#define GT_RETCOD_CT 56
#define GT_DETTRS_CF 57
#define GT_ADJSIG_B 58
#define GT_ESTUWY_NF 59
#define GT_LSTENDMTH_NF 60
#define GT_PROPER_N 61
#define GT_RTOCTY_CF 62
#define GT_SPIMOD_CT 63
#define GT_BRKSCOEGP_M 64
#define GT_NBCOL 65


/* Position des champs dans le GT enrichi */

#define GTE_SSD_CF 0
#define GTE_ESB_CF 1
#define GTE_BALSHEY_NF 2
#define GTE_BALSHRMTH_NF 3
#define GTE_BALSHRDAY_NF 4
#define GTE_TRNCOD_CF 5
#define GTE_DBLTRNCOD_CF 6
#define GTE_CTR_NF 7
#define GTE_END_NT 8
#define GTE_SEC_NF 9
#define GTE_UWY_NF 10
#define GTE_UW_NT 11
#define GTE_OCCYEA_NF 12
#define GTE_ACY_NF 13
#define GTE_SCOSTRMTH_NF 14
#define GTE_SCOENDMTH_NF 15
#define GTE_CLM_NF 16
#define GTE_CUR_CF 17
#define GTE_AMT_M 18
#define GTE_CED_NF 19
#define GTE_BRK_NF 20
#define GTE_PAY_NF 21
#define GTE_KEY_NF 22
#define GTE_RETCTR_NF 23
#define GTE_RETEND_NT 24
#define GTE_RETSEC_NF 25
#define GTE_RTY_NF 26
#define GTE_RETUW_NT 27
#define GTE_RETOCCYEA_NF 28
#define GTE_RETACY_NF 29
#define GTE_RETSCOSTRMTH_NF 30
#define GTE_RETSCOENDMTH_NF 31
#define GTE_RCL_NF 32
#define GTE_RETCUR_CF 33
#define GTE_RETAMT_M 34
#define GTE_PLC_NT 35
#define GTE_RTO_NF 36
#define GTE_INT_NF 37
#define GTE_RETPAY_NF 38
#define GTE_RETKEY_CF 39
#define GTE_ACMTRS_NT 40
#define GTE_ACMAMT_M 41
#define GTE_ACMCUR_CF 42


/* Position des champs dans le GT cumule pour les estimations avec les */
/* exercices de survenance */

#define GTESTCUMUL1_CTR_NF 0
#define GTESTCUMUL1_END_NT 1
#define GTESTCUMUL1_SEC_NF 2
#define GTESTCUMUL1_UWY_NF 3
#define GTESTCUMUL1_UW_NT 4
#define GTESTCUMUL1_OCCYEA_NF 5
#define GTESTCUMUL1_ACMTRS_NT 6
#define GTESTCUMUL1_ACMAMT_M 7
#define GTESTCUMUL1_SEG_NF 8

/* Position des champs dans le GT cumule pour les estimations sans les */
/* exercices de survenance */

#define GTESTCUMUL2_CTR_NF 0
#define GTESTCUMUL2_END_NT 1
#define GTESTCUMUL2_SEC_NF 2
#define GTESTCUMUL2_UWY_NF 3
#define GTESTCUMUL2_UW_NT 4
#define GTESTCUMUL2_ACMTRS_NT 5
#define GTESTCUMUL2_ACMAMT_M 6
#define GTESTCUMUL2_SEG_NF 7

/* Position des champs dans le Fichier de Travail */

#define FT_CLODAT_D 0
#define FT_CTR_NF 1
#define FT_END_NT 2
#define FT_SEC_NF 3
#define FT_UWY_NF 4
#define FT_UW_NT 5
#define FT_ACY_NF 6
#define FT_SCOSTRMTH_NF 7
#define FT_SCOENDMTH_NF 8
#define FT_UWYDIS_NF 9
#define FT_SSD_CF 10
#define FT_WFCOD_NT 11
#define FT_WFTYP_CF 12
#define FT_EGPCUR_CF 13
#define FT_PRM_M 14
#define FT_PPNAC_M 15
#define FT_PPNAEA_M 16
#define FT_RPPC_M 17
#define FT_RPPEA_M 18
#define FT_LPPNAC_M 19
#define FT_EPPC_M 20
#define FT_EPPEA_M 21
#define FT_RECC_M 22
#define FT_RECE_M 23
#define FT_BCC_M 24
#define FT_BCE_M 25
#define FT_SHR_R 26
#define FT_ACCADMTYP_CT 27


/* Position des champs dans les previsions */

#define PRE_SSD_CF 0
#define PRE_CTR_NF 1
#define PRE_END_NT 2
#define PRE_SEC_NF 3
#define PRE_UWY_NF 4
#define PRE_UW_NT 5
#define PRE_ACY_NF 6
#define PRE_CRE_D 7
#define PRE_PRS_CF 8
#define PRE_ACMTRS_NT 9
#define PRE_BALSHEY_NF 10
#define PRE_BALSHTMTH_NF 11
#define PRE_CUR_CF 12
#define PRE_ESTMNT_M 13
#define PRE_UPD_NF 14
#define PRE_LOB_CF 15
#define PRE_ACCSTS_CT 16
#define PRE_ACCADMTYP_CT 17
#define PRE_ESTCRB_CT 18
#define PRE_CED_NF 19
#define PRE_BRK_NF 20
#define PRE_PAY_NF 21
#define PRE_GANPAYORD_NT 22
#define PRE_ADJCOD_CT 23
#define PRE_RETCOD_CT 24
#define PRE_DETTRS_CF 25
#define PRE_ADJSIG_B 26
#define PRE_ESB_CF 27
#define PRE_LIFTRTTYP_CF 28
#define PRE_INDSUP_B 29
#define PRE_ORICOD_LS 30
#define PRE_CREUSR_CF 31
#define PRE_LSTUPD_D 32
#define PRE_LSTUPDUSR_CF 33
#define PRE_SPIMOD_CT 34
#define PRE_NAT_CF 35
#define PRE_NBCOL 36


/* positions des champs dans le fichier de placement issu de la table retro
   TPLACEMT*/

#define PLC_RETCTR_NF         0
#define PLC_RTY_NF            1
#define PLC_PLC_NT            2
#define PLC_PLCVER_NT         3
#define PLC_SSD_CF            4
#define PLC_INT_NF            5
#define PLC_UDWAGE_NF         6
#define PLC_PLCCENT_NT        7
#define PLC_RTO_NF            8
#define PLC_PLCSTS_CT         9
#define PLC_PLCSTS_D         10
#define PLC_CTC_NT           11
#define PLC_SSDRTO_B         12
#define PLC_VALLCK_B         13
#define PLC_CTRMAI_D         14
#define PLC_TRTPROMAI_D      15
#define PLC_COVNOTREC_D      16
#define PLC_SIGREC_D         17
#define PLC_SIGRMD_D         18
#define PLC_PLCCMT_NT        19
#define PLC_RETACTSHA_R      20
#define PLC_RETACTUNT_N      21
#define PLC_RETACTLIA_M      22
#define PLC_RETPOTUNT_N      23
#define PLC_RETPOTLIA_M      24
#define PLC_RETPOTSHA_R      25
#define PLC_RETSIGSHA_R      26
#define PLC_LEARNK_N         27
#define PLC_MINPRMLCK_B      28
#define PLC_LATSETPRM_NT     29
#define PLC_ACCDIS_B         30
#define PLC_PAY_NF           31
#define PLC_KEY_CF           32
#define PLC_RTOREF_LS        33
#define PLC_PLCINC_D         34
#define PLC_CAN_DT           35
#define PLC_PARCMU_B         36
#define PLC_PNO_D            37
#define PLC_PNORMD_D         38
#define PLC_PLCCON_D         39
#define PLC_DEFPLCSEN_D      40
#define PLC_GENRMD_D         41
#define PLC_GENRMDCMT_NT     42
#define PLC_FUNWIT_B         43
#define PLC_CTRFUNCON_B      44
#define PLC_ACCPLC_B         45
#define PLC_RTOCTY_CF        46
#define PLC_RENPLC_B         47
#define PLC_CTRPROCON_B      48
#define PLC_CTRCOMCON_B      49
#define PLC_FIXCOM_R         50
#define PLC_SUBACCLOC_B      51
#define PLC_RETOVRCOM_B      52
#define PLC_OVRCOM_R         53
#define PLC_PROPLA_B         54
#define PLC_CONPLC_B         55
#define PLC_HIS_B            56
#define PLC_RAICOM_B         57
#define PLC_ACKSEN_D         58
#define PLC_PNOSCO_B         59
#define PLC_ACCCTC_NT        60
#define PLC_CRE_D            61
#define PLC_CREUSR_CF        62
#define PLC_LSTUPD_D         63
#define PLC_LSTUPDUSR_CF     64
#define PLC_NBCOL            65

/* Champs des placements utilises pour la generation retrocession */
#define PLA_SSD_CF 0
#define PLA_ESB_CF 1
#define PLA_RETCTR_NF 2
#define PLA_RETEND_NT 3
#define PLA_RETSEC_NF 4
#define PLA_RTY_NF 5
#define PLA_RETUW_NT 6
#define PLA_PLC_NT 7
#define PLA_OVRCOM_R 8
#define PLA_RTO_NF 9
#define PLA_INT_NF 10
#define PLA_PAY_NF 11
#define PLA_KEY_CF 12
#define PLA_ORICUR_B 13
#define PLA_SSDRTO_B 14
#define PLA_RETSIGSHA_R 15
#define PLA_LOB_CF 16
#define PLA_RAICOM_B 17
#define PLA_RETOVRCOM_B 18
#define PLA_CTR_NF 19
#define PLA_END_NT 20
#define PLA_SEC_NF 21
#define PLA_UWY_NF 22
#define PLA_UW_NT 23
#define PLA_CUR_CF 24
#define PLA_CESSH_R 25
#define PLA_CLMFUN_R 26
#define PLA_URRFUN_R 27
#define PLA_CLMFUNINT_R 28
#define PLA_URRFUNINT_R 29
#define PLA_NBCOL 30

/* Position des champs dans les comptes complets */

#define CMP_SSD_CF 0
#define CMP_CTR_NF 1
#define CMP_ACY_NF 2
#define CMP_SCOSTRMTH_NF 3
#define CMP_SCOENDMTH_NF 4
#define CMP_NBCOL 5

/* Position des champs dans le fichier TPINTWIT */
#define TPINTWIT_RETCTR_NF 0
#define TPINTWIT_RTY_NF 1
#define TPINTWIT_PLC_NT 2
#define TPINTWIT_PLCVER_NT 3
#define TPINTWIT_RETTRTCUR_CF 4
#define TPINTWIT_CLMFUNINT_R 5
#define TPINTWIT_URRFUNINT_R 6
#define TPINTWIT_IBNFUNINT_R 7
#define TPINTWIT_SSD_CF 8
#define TPINTWIT_CRE_D 9
#define TPINTWIT_CREUSR_CF 10
#define TPINTWIT_LSTUPD_D 11
#define TPINTWIT_LSTUPDUSR_CF 12

/* Position des champs dans le fichier TINTWIT */
#define TINTWIT_RETCTR_NF 0
#define TINTWIT_RTY_NF 1
#define TINTWIT_RETTRTCUR_CF 2
#define TINTWIT_CLMFUNINT_R 3
#define TINTWIT_URRFUNINT_R 4
#define TINTWIT_IBNFUNINT_R 5
#define TINTWIT_CRE_D 6
#define TINTWIT_CREUSR_CF 7
#define TINTWIT_LSTUPD_D 8
#define TINTWIT_LSTUPDUSR_CF 9

/* Position des champs dans le fichier TDEPOSIT */

#define TDEPOSIT_RETCTR_NF 0
#define TDEPOSIT_RTY_NF 1
#define TDEPOSIT_SSD_CF 2
#define TDEPOSIT_CLMFUNMOD_CT 3
#define TDEPOSIT_CLMFUN_R 4
#define TDEPOSIT_URRFUNMOD_CT 5
#define TDEPOSIT_URRFUN_R 6
#define TDEPOSIT_IBNFUNMOD_CT 7
#define TDEPOSIT_IBNFUN_R 8
#define TDEPOSIT_DEPADM_CT 9
#define TDEPOSIT_DEPORI_B 10
#define TDEPOSIT_CANDEP_B 11
#define TDEPOSIT_CRE_D 12
#define TDEPOSIT_CREUSR_CF 13
#define TDEPOSIT_LSTUPD_D 14
#define TDEPOSIT_LSTUPDUSR_CF 15
#define TDEPOSIT_NBCOL 16

/* Position des champs dans le fichier TPFUNWIT */

#define TPFUNWIT_RETCTR_NF 0
#define TPFUNWIT_RTY_NF 1
#define TPFUNWIT_PLC_NT 2
#define TPFUNWIT_PLCVER_NT 3
#define TPFUNWIT_SSD_CF 4
#define TPFUNWIT_CLMFUNMOD_CT 5
#define TPFUNWIT_CLMFUN_R 6
#define TPFUNWIT_URRFUNMOD_CT 7
#define TPFUNWIT_URRFUN_R 8
#define TPFUNWIT_IBNFUNMOD_CT 9
#define TPFUNWIT_IBNFUN_R 10
#define TPFUNWIT_DEPADM_CT 11
#define TPFUNWIT_DEPORI_B 12
#define TPFUNWIT_CANDEP_B 13
#define TPFUNWIT_CRE_D 14
#define TPFUNWIT_CREUSR_CF 15
#define TPFUNWIT_LSTUPD_D 16
#define TPFUNWIT_LSTUPDUSR_CF 17
#define TPFUNWIT_NBCOL 18

/* Position des champs dans le fichier FCTRGRO */

#define CTRGRO_CTR_NF 0
#define CTRGRO_END_NT 1 
#define CTRGRO_SEC_NF 2 
#define CTRGRO_VRS_NF 3 
#define CTRGRO_SSD_CF 4 
#define CTRGRO_SEGTYP_CT 5 
#define CTRGRO_SEG_NF 6


/* Position des champs dans le fichier PERICASEEST */

#define CASEEST_CTR_NF 0
#define CASEEST_END_NT 1 
#define CASEEST_SEC_NF 2 
#define CASEEST_UWY_NF 3
#define CASEEST_UW_NT  4
#define CASEEST_EGPCUR_CF 5
#define CASEEST_CTRNAT_CT 6
#define CASEEST_Pai_M 7
#define CASEEST_SEG_NF 8
#define CASEEST_Scii_M 9
#define CASEEST_Scci_M 10
#define CASEEST_PAi_M  11
#define CASEEST_Psi_M  12
#define CASEEST_Ssi_M  13
#define CASEEST_Ssi_CT 14
#define CASEEST_CALAMTPRM_M 15
#define CASEEST_ENTAMTPRM_M 16
#define CASEEST_ADMMODPRM_CT 17
#define CASEEST_CALAMTCLM_M 18
#define CASEEST_ENTAMTCLM_M 19


/* Position des champs dans le fichier PERICASEACT  */

#define CASEACT_CTR_NF 0
#define CASEACT_END_NT 1 
#define CASEACT_SEC_NF 2 
#define CASEACT_UWY_NF 3
#define CASEACT_UW_NT  4
#define CASEACT_EGPCUR_CF 5
#define CASEACT_CTRNAT_CT 6
#define CASEACT_Pai_M 7
#define CASEACT_SEG_NF 8
#define CASEACT_Scii_M 9
#define CASEACT_Scci_M 10
#define CASEACT_PAi_M  11
#define CASEACT_Psi_M  12
#define CASEACT_Ssi_M  13
#define CASEACT_Sai_M  14
#define CASEACT_Sai_CT 15
#define CASEACT_PAai_M 16
#define CASEACT_ENTAMT_M 17


/* Position des champs dans le fichier des estimations par segment/exercice */

#define SEGEST1_SSD_CF 0
#define SEGEST1_SEG_NF 1
#define SEGEST1_UWY_NF 2
#define SEGEST1_CUR_CF 3
#define SEGEST1_SEGNAT_CT 4
#define SEGEST1_Ss_M 5
#define SEGEST1_SP_R 6
#define SEGEST1_SP_CT 7


/* Position des champs dans le fichier des estimations par segment/exercice/ */
/* devise de l'aliment */

#define SEGEST2_SEG_NF 0
#define SEGEST2_UWY_NF 1
#define SEGEST2_EGPCUR_CF 2
#define SEGEST2_CUR_CF 3
#define SEGEST2_SEGNAT_CT 4
#define SEGEST2_Ss_M 5
#define SEGEST2_Ps_M 6
#define SEGEST2_PAa_M 7
#define SEGEST2_Sc_M 8
#define SEGEST2_PA_M 9
#define SEGEST2_Pa_M 10
#define SEGEST2_Sa_M 11


/* Position des champs dans le fichier des ventilations par segment/exercice/ */
/* exercice de survenance */

#define LABOCY_VRS_NF 0
#define LABOCY_SSD_CF 1
#define LABOCY_SEGTYP_CT 2
#define LABOCY_SEG_NF 3
#define LABOCY_UWY_NF 4
#define LABOCY_CRE_D 5
#define LABOCY_OCCYEA_NF 6
#define LABOCY_SPIRAT_R 7


/* Position des champs dans le fichier des ventilations par segment/exercice/ */
/* exercice de survenance utile pour les estimations */

#define LABOCYEST_SEG_NF 0
#define LABOCYEST_UWY_NF 1
#define LABOCYEST_OCCYEA_NF 2
#define LABOCYEST_SPIRAT_R 3
#define LABOCYEST_Sc_M 4


/* Position des champs dans le fichier des ultimes */

#define ULT_CTR_NF 0
#define ULT_END_NT 1
#define ULT_SEC_NF 2
#define ULT_UWY_NF 3
#define ULT_UW_NT 4
#define ULT_CRE_D 5
#define ULT_SSD_CF 6
#define ULT_DIV_NT 7
#define ULT_CUR_CF 8
#define ULT_CALAMTPRM_M 9
#define ULT_ENTAMTPRM_M 10
#define ULT_RETAMTPRM_M 11
#define ULT_ADMMODPRM_CT 12
#define ULT_RESPRM_M 13
#define ULT_CALAMTCLM_M 14
#define ULT_ENTAMTCLM_M 15
#define ULT_RETAMTCLM_M 16
#define ULT_ADMMODCLM_CT 17
#define ULT_ORICOD_LS 18
#define ULT_UPDUSR_CF 19
#define ULT_CREUSR_CF 20
#define ULT_LSTUPD_D 21
#define ULT_LSTUPDUSR_CF 22


/* Position des champs dans le fichier des dommages */

#define EST_CTR_NF 0
#define EST_END_NT 1
#define EST_SEC_NF 2
#define EST_UWY_NF 3
#define EST_UW_NT 4
#define EST_CRE_D 5
#define EST_PRS_CF 6
#define EST_ACMTRS_NT 7
#define EST_SSD_CF 8
#define EST_DIV_NT 9
#define EST_CUR_CF 10
#define EST_CALAMT_M 11
#define EST_ENTAMT_M 12
#define EST_RETAMT_M 13
#define EST_ADMMOD_CT 14
#define EST_CLODAT_D 15
#define EST_ORICOD_LS 16
#define EST_UPDUSR_CF 17
#define EST_CREUSR_CF 18
#define EST_LSTUPD_D 19
#define EST_LSTUPDUSR_CF 20


/* Position de champs dans le fichier des charges iterees */

#define CHG2_CTR_NF 0
#define CHG2_END_NT 1
#define CHG2_SEC_NF 2
#define CHG2_UWY_NF 3 
#define CHG2_UW_NT  4
#define CHG2_CHGLIN_NT 5
#define CHG2_RATTYP_B 6
#define CHG2_MAX_R 7
#define CHG2_MINRAT_R 8
#define CHG2_MIN_R 9
#define CHG2_MAXRAT_R 10


/* Positions des champs des postes cumules */

#define ACC_ACMTRS_NT 0
#define ACC_PRS_CF 1
#define ACC_ADJCOD_CT 2
#define ACC_RETCOD_CT 3
#define ACC_DETTRS_CF 4
#define ACC_ADJSIG_B 5
#define ACC_SPIMOD_CT 6
#define ACC_NBCOL 7

/* position des champs dans le fichier des versements en entree */
/* de l'operateur de versement */
#define CES_CTR_NF 0
#define CES_END_NT 1
#define CES_SEC_NF 2
#define CES_UWY_NF 3
#define CES_UW_NT 4
#define CES_RETCTR_NF 5
#define CES_RETEND_NT 6
#define CES_RETSEC_NF 7
#define CES_RTY_NF 8
#define CES_RETUW_NT 9
#define CES_CESACCSTA_N 10
#define CES_CESACCEND_N 11
#define CES_CESSH_R 12
#define CES_SSD_CF 13
#define CES_ESB_CF 14
#define CES_RETCTRCAT_CF 15
#define CES_ACCADMTYP_CT 16
#define CES_RETACCADM_B 17
#define CES_CLECUTPER_B 18
#define CES_CLECUTPER_NB 19   
#define CES_LOB_CF 20
#define CES_CUR_CF 21
#define CES_NBCOL 22

/* Structure de la liste des mois de fin de periode par contrat */
#define MTH_RETCTR_NF 0
#define MTH_LSTENDMTH_NF 1
#define MTH_NBCOL 2

/* Structure du fichier d'anomalies */

#define ANO_ANOCOD_CF 0
#define ANO_UWGRP_CF 1
#define ANO_CTR_NF 2
#define ANO_SEC_NF 3
#define ANO_UWY_NF 4
#define ANO_ACY_NF 5
#define ANO_ACMTRS_NT 6
#define ANO_PCPCUR_CF 7
#define ANO_SSD_CF 8
#define ANO_NBCOL 9

/* Position des champs du fichier FDETTRS (correspondant a la table TDETTRS */
/* de la base BREF */

#define DETTRS_DETTRS_CF 0
#define DETTRS_CTRSCOD_CF 4


/* Liste des anomalies */

#define A_TraiteParDefaut 1             /* 2032, utilisation du traite/defaut */
#define A_SegmentParDefaut 2            /* 2032, utilisation du seg./defaut */
#define A_TraiteModifie 3               /* 2032, evolution du traite */
#define A_SegmentModifie 4              /* 2032, evolution du segment */
#define A_PasDeTraiteParDefaut 5        /* 2032, ano: traite/defaut absent */
#define A_PasDeSegmentParDefaut 6       /* 2032, ano: segment/defaut absent */
#define A_CribleN 7                     /* 2035, ano: trouve crible N */
#define A_Type1 8                       /* 2035, ano: type comptable = 1 */
#define A_ChmtDev 9                     /* 2035, conversion du montant */
#define A_Lib 10                        /* 2035, liberation (effacee) */
#define A_Type45 11                     /* 2035, ano: trouve type 4 ou 5 */
#define A_SigneComplementAnormal 12     /* 2113, signe et montant incompatible */
#define A_Type2 13                      /* 2035, ano: type comptable = 2 */
#define A_Type3 14                      /* 2035, ano: type comptable = 3 */
#define A_NbAno 15                      /* Nombre de messages d'anomalie */

/* Format du fichier utilise pour l'edition de l'etat synthetique de
controle inventaire acceptation*/
#define     SYNA_SSD_CF     0
#define     SYNA_ESB_CF     1
#define     SYNA_LOB_CF     2
#define     SYNA_CTRNAT_CT  3
#define     SYNA_WRKCAT_CT  4
#define     SYNA_AMT10000_M 5
#define     SYNA_AMT10030_M 6
#define     SYNA_AMT10031_M 7
#define     SYNA_AMT10100_M 8
#define     SYNA_AMT10130_M 9
#define     SYNA_AMT10400_M 10
#define     SYNA_AMT10430_M 11
#define     SYNA_AMT20000_M 12
#define     SYNA_AMT20030_M 13
#define     SYNA_AMT20031_M 14
#define     SYNA_AMT22000_M 15
#define     SYNA_AMT23000_M 16
#define     SYNA_AMT24030_M 17
#define     SYNA_AMT24031_M 18

/* Format du fichier utilise pour l'edition de l'etat synthetique de
controle inventaire retrocession*/
#define     SYNR_SSD_CF     0
#define     SYNR_ESB_CF     1
#define     SYNR_LOB_CF     2
#define     SYNR_CTRNAT_CT  3
#define     SYNR_AMT10000_M 4
#define     SYNR_AMT10030_M 5
#define     SYNR_AMT10031_M 6
#define     SYNR_AMT10100_M 7
#define     SYNR_AMT10130_M 8
#define     SYNR_AMT10200_M 9
#define     SYNR_AMT10430_M 10
#define     SYNR_AMT20000_M 11
#define     SYNR_AMT20030_M 12
#define     SYNR_AMT20031_M 13
#define     SYNR_AMT22000_M 14
#define     SYNR_AMT24030_M 15
#define     SYNR_AMT24031_M 16

/* Position des champs dans le fichier des identifiants */

#define IDENT_CTR_NF 0
#define IDENT_END_NT 1
#define IDENT_SEC_NF 2
#define IDENT_UWY_NF 3
#define IDENT_UW_NT 4

/*Postion des champs dans le fichier de rapprochement */
  
#define FRAPP_SSD_CF    0
#define FRAPP_ESB_CF    1
#define FRAPP_CTR_NF    2
#define FRAPP_END_NT    3
#define FRAPP_SEC_NF    4
#define FRAPP_UWY_NF    5
#define FRAPP_UW_NT     6
#define FRAPP_RETCTR_NF 7
#define FRAPP_RETEND_NT 8
#define FRAPP_RETSEC_NF 9
#define FRAPP_RTY_NF    10
#define FRAPP_RETUW_NT  11
#define FRAPP_RETCUR_CF 12
#define FRAPP_RETNAT_CF 13     /* Top retrocession Prop / Non Prop */
#define FRAPP_ACRES_M   14     /* Resultat comptable */
#define FRAPP_THRES_M   15     /* Resultat theorique */
#define FRAPP_AMT1_M    16     /* ecart brut */
#define FRAPP_AMT2_M    17     /* ecart de placement sur rejet de retard */
#define FRAPP_AMT3_M    18     /* ecart de change sur rejet de retard */ 
#define FRAPP_AMT4_M    19     /* ecart de placement sur les comptes */
#define FRAPP_AMT5_M    20     /* ecart de change sur les comptes */
#define FRAPP_AMT6_M    21     /* ecart d'effets retroactifs sur bilans 
                                  anterieurs */
#define FRAPP_AMT7_M    22     /* ecart d'ecriture de rachat */
#define FRAPP_AMT8_M    23     /* ecart de versement sur ouvertures 
                                  estimations / actualisees / service */
#define FRAPP_AMT9_M    24     /* ecart de placement sur ouvertures
                                  estimations / actualisees / service */
#define FRAPP_AMT10_M   25     /*  ecart de change sur ouvertures 
                                  estimations / actualisees / service */
#define FRAPP_AMT11_M   26     /* ecart de commission majoree */
#define FRAPP_AMT12_M   27     /* ecart epure */
#define FRAPP_FIN       28     /* fin */

#define TOUTTRAA_RETCTR_NF 0
#define TOUTTRAA_RTY_NF 1
#define TOUTTRAA_RETSEC_NF 2
#define TOUTTRAA_SSD_CF 3
#define TOUTTRAA_CTR_NF 4
#define TOUTTRAA_END_NT 5
#define TOUTTRAA_SEC_NF 6
#define TOUTTRAA_UW_NT 7
#define TOUTTRAA_UWY_NF 8
#define TOUTTRAA_SCOSTRMTH_NF 9
#define TOUTTRAA_SCOENDMTH_NF 10
#define TOUTTRAA_ACCYER_NF 11
#define TOUTTRAA_BLCSHT_D 12
#define TOUTTRAA_CLM_NF 13
#define TOUTTRAA_TRNCOD_CF 14
#define TOUTTRAA_ACPCUR_CF 15
#define TOUTTRAA_CED_M 16
#define TOUTTRAA_RETACT_CT 17
#define TOUTTRAA_OCCYEA_NF 18

#define TOUTTRAI_SSD_CF 0
#define TOUTTRAI_RETCTR_NF 1
#define TOUTTRAI_RTY_NF 2
#define TOUTTRAI_PLC_NT 3
#define TOUTTRAI_RETSEC_NF 4
#define TOUTTRAI_CTR_NF 5
#define TOUTTRAI_UW_NT 6
#define TOUTTRAI_UWY_NF 7
#define TOUTTRAI_END_NT 8
#define TOUTTRAI_SEC_NF 9
#define TOUTTRAI_RCL_NF 10
#define TOUTTRAI_TRNCOD_CF 11
#define TOUTTRAI_CUR_CF 12
#define TOUTTRAI_TRN_M 13
#define TOUTTRAI_OCCYEA_NF 14
#define TOUTTRAI_COMTRA_B 15
#define TOUTTRAI_ACCYER_NF 16

#define TACCTRAA_RETCTR_NF 0
#define TACCTRAA_RTY_NF 1
#define TACCTRAA_RETSEC_NF 2
#define TACCTRAA_SSD_CF 3
#define TACCTRAA_CTR_NF 4
#define TACCTRAA_END_NT 5
#define TACCTRAA_SEC_NF 6
#define TACCTRAA_UW_NT 7
#define TACCTRAA_UWY_NF 8
#define TACCTRAA_SCOSTRMTH_NF 9
#define TACCTRAA_SCOENDMTH_NF 10
#define TACCTRAA_ACCYER_NF 11
#define TACCTRAA_BLCSHT_D 12
#define TACCTRAA_CLM_NF 13
#define TACCTRAA_TRNCOD_CF 14
#define TACCTRAA_ACPCUR_CF 15
#define TACCTRAA_CED_M 16
#define TACCTRAA_RETACT_CT 17
#define TACCTRAA_OCCYEA_NF 18
#define TACCTRAA_CNVCUR_CF 19
#define TACCTRAA_CNVAMT_M 20
#define TACCTRAA_RETACCYER_NF 21
#define TACCTRAA_ACCTRTCUR_R 22

#define TACCTRAI_SSD_CF 0
#define TACCTRAI_RETCTR_NF 1
#define TACCTRAI_RTY_NF 2
#define TACCTRAI_PLC_NT 3
#define TACCTRAI_RETSEC_NF 4
#define TACCTRAI_CTR_NF 5
#define TACCTRAI_UW_NT 6
#define TACCTRAI_UWY_NF 7
#define TACCTRAI_SEC_NF 8
#define TACCTRAI_END_NT 9
#define TACCTRAI_TRNCOD_CF 10
#define TACCTRAI_CNVCUR_CF 11
#define TACCTRAI_CNVAMT_M 12
#define TACCTRAI_ACC_D 13
#define TACCTRAI_COMTRA_B 14

#define TCMUSPLI_SSD_CF 0
#define TCMUSPLI_RETCTR_NF 1
#define TCMUSPLI_RTY_NF 2
#define TCMUSPLI_RETSEC_NF 3
#define TCMUSPLI_CTR_NF 4
#define TCMUSPLI_UW_NT 5
#define TCMUSPLI_UWY_NF 6
#define TCMUSPLI_SEC_NF 7
#define TCMUSPLI_END_NT 8
#define TCMUSPLI_TRNCOD_CF 9
#define TCMUSPLI_CNVCUR_CF 10
#define TCMUSPLI_CNVAMT_M 11
#define TCMUSPLI_ACC_D 12

#define TCMUSPLIT_SSD_CF 0
#define TCMUSPLIT_RETCTR_NF 1
#define TCMUSPLIT_RTY_NF 2
#define TCMUSPLIT_RETSEC_NF 3
#define TCMUSPLIT_CTR_NF 4
#define TCMUSPLIT_UW_NT 5
#define TCMUSPLIT_UWY_NF 6
#define TCMUSPLIT_SEC_NF 7
#define TCMUSPLIT_END_NT 8
#define TCMUSPLIT_TRNCOD_CF 9
#define TCMUSPLIT_CNVCUR_CF 10
#define TCMUSPLIT_CNVAMT_M 11
#define TCMUSPLIT_ACC_D 12

/* Structure de stockage du fichier des segments d'analyse */

typedef struct {
CS_TINYINT      SSD_CF;
CS_SMALLINT     UWGRP_CF;
CS_CHAR         ANLCTY_CF[4];
CS_CHAR         CLINAT_CF[4];
CS_TINYINT      ORDNBR_NT;
CS_CHAR         SEG_NF[11];
} T_SEGPAR;


/* Structure de stockage du fichier des traites de rattachement */

typedef struct {
CS_TINYINT      SSD_CF;
CS_CHAR         LIFTRTTYP_CF[3];
CS_SMALLINT     UWGRP_CF;
CS_CHAR         ANLCTY_CF[4];
CS_CHAR         ESTCTR_NF[10];
} T_CTRFIC;


/* Structure de stockage du fichier de pilotage */

typedef struct {
CS_CHAR         CTR_NF[10];
CS_TINYINT      END_NT;
CS_TINYINT      SEC_NF;
CS_SMALLINT     UWY_NF;
CS_TINYINT      UW_NT;
CS_SMALLINT     ACY_NF;
CS_TINYINT      SSD_CF;
CS_SMALLINT     BALSHEY_NF;
CS_TINYINT      BALSHTMTH_NF;
CS_BIT          AUTUPD_B;
CS_BIT          COMACC_B;
CS_CHAR         CRE_D[18];
CS_CHAR         UPD_NF;
CS_INT          CMT_NT;
CS_CHAR         CREUSR_CF[5];
CS_CHAR         LSTUPD_D[50];
CS_CHAR         LSTUPDUSR_CF[5];
} T_LIFDRI;
  
typedef struct {
char            CLODAT_D[9];
char            CTR_NF[10];
int             END_NT;
int             SEC_NF;
int             UWY_NF;
int             UW_NT;
int             ACY_NF;
int             SCOSTRMTH_NF;
int             SCOENDMTH_NF;
int             UWYDIS_NF;
int             SSD_CF;
char            WFCOD_NT[6]; 
char            WFTYP_CF;
char            EGPCUR_CF[4];
double          PRM_M;
double          PPNAC_M;
double          PPNAEA_M;
double          RPPC_M; 
double          RPPEA_M;
double          LPPNAC_M;
double          EPPC_M;
double          EPPEA_M;
double          RECC_M;
double          RECE_M;
double          BCC_M;
double          BCE_M;
double          SHR_R;
int             ACCADMTYP_CT;
}T_FT ;

typedef struct {
short		PRS_CF;
short           ACMTRS_NT;
char            DETTRS_CF[9];
} T_TRSLNK;

typedef struct {
unsigned char   SSD_CF ;     
char            CLODAT_D[9] ; 
unsigned char   FSTWAY_B ;   
} T_LISTESSD ; 

typedef struct {
CS_SMALLINT     PRS_CF ;
CS_CHAR	 	TRNCOD_CF[9] ;
CS_CHAR		DETTRS_CF[9] ;
} T_RETPAR ;

typedef struct {
CS_CHAR		RETCTR_NF[10] ;
CS_SMALLINT	RTY_NF ;
CS_INT		PLC_NT ;
CS_TINYINT	UW_NT ;
CS_CHAR		CTR_NF[10] ;
CS_SMALLINT	UWY_NF ;
CS_INT		CLISSD_NF ;
CS_TINYINT	RTOSSD_CF ;
} T_SSDACTR ;


typedef struct	{
			char 		c_SSD_CF;
			short		s_ACMTRS_NT;
			char		sz_ACMTRS_LS[20];
		} T_ACMTRS;

typedef struct	{
			char 		c_SSD_CF;
			char		sz_LIB[17];
			char		sz_LAG_CF[2];
		} T_SUBSID;

typedef struct	{
			char 		sz_LAG_CF[2];
			int			n_COLVAL_CT;
			char		sz_COLVAL_LM[33];
		} T_BANTECL;

typedef struct	{
			short		s_GRP_CF;
			char 		c_SSD_CF;
			char		sz_GRP_LS[17];
		} T_GRP;


#define MAXROW_SUBSID	  100
#define MAXROW_ACMTRS	  500
#define MAXROW_BANTECL	10000
#define MAXROW_GRP	 1000



/* Structure de stockage du fichier de rapprochement */

typedef struct {
CS_TINYINT      SSD_CF;
CS_TINYINT      ESB_CF;
CS_CHAR         CTR_NF[10];
CS_TINYINT      END_NT;
CS_TINYINT      SEC_NF;
CS_SMALLINT     UWY_NF;
CS_TINYINT      UW_NT;
CS_CHAR         RETCTR_NF[10];
CS_TINYINT      RETEND_NT;
CS_TINYINT      RETSEC_NF;
CS_SMALLINT     RTY_NF;
CS_TINYINT      RETUW_NT;
CS_CHAR         RETCUR_CF[4];
CS_CHAR         RETNAT_CF;
CS_FLOAT        ACRES_M;
CS_FLOAT        THRES_M;
CS_FLOAT        AMT1_M;
CS_FLOAT        AMT2_M;
CS_FLOAT        AMT3_M;
CS_FLOAT        AMT4_M;
CS_FLOAT        AMT5_M;
CS_FLOAT        AMT6_M;
CS_FLOAT        AMT7_M;
CS_FLOAT        AMT8_M;
CS_FLOAT        AMT9_M;
CS_FLOAT        AMT10_M;
CS_FLOAT        AMT11_M;
CS_FLOAT        AMT12_M;
} T_FRAPP;
