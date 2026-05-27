#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD3751.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 15\10\2019
# auteur                        : Arnaud RUFFAULT
#-----------------------------------------------------------------------------
# description
#  IFRS17 REQ 12.5 : CSM/LC accretion
#  IFRS17 REQ 12.6 : T>0 profitability before amortisation
#  IFRS17 REQ 12.9 : CSM amortization
#  IFRS17 SPIRA 84606 : CSM/LC accretion at transition
#  IFRS17 SPIRA 91422 : Add of new structure of index rate File 
#  IFRS17 SPIRA 91115 : Added ESF_DLCUMGTAAR_MVT input file
#  IFRS17 SPIRA 102520 : Added new sorting and merging syncsort commands
#  IFRS17 SPIRA 108263 : Added new steps from step 08 to 13
#  IFRS17 SPIRA 108953 : New key added in step 06
#-----------------------------------------------------------------------------
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctjsb.cmd

# Job Initialisation
JOBINIT

if [ -z "$PARM_IS_TRN" ]
then
   PARM_IS_TRN=NO
fi

ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ICLODAT_D........................................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> PREV_ICLODAT_D...................................................: ${PARM_PREV_ICLODAT_D}"
ECHO_LOG "#===> CLOTYP...........................................................: ${TYPEINV}"
ECHO_LOG "#===> NORME_CF.........................................................: ${NORME_CF}"
ECHO_LOG "#===> BATCHUSER........................................................: ${PARM_BATCHUSER}"
ECHO_LOG "#===> PARM_IS_TRN......................................................: ${PARM_IS_TRN}"

ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> EPO_FCURQUOT_TXT.................................................: ${EPO_FCURQUOT_TXT}"
ECHO_LOG "#===> EST_IADPERICASE_STD..............................................: ${EST_IADPERICASE_STD}"
ECHO_LOG "#===> EST_IADPERICASE_INI..............................................: ${EST_IADPERICASE_INI}"
ECHO_LOG "#===> ESF_GTSII_IFRS17_CSM.............................................: ${ESF_GTSII_IFRS17_CSM}"
ECHO_LOG "#===> ESF_GTSII_CSM....................................................: ${ESF_GTSII_CSM}"
ECHO_LOG "#===> ESF_GTSII_CSM_CASHFLOW_PREV......................................: ${ESF_GTSII_CSM_CASHFLOW_PREV}"
ECHO_LOG "#===> ESF_GTSII_ESCOMPTE_FWD...........................................: ${ESF_GTSII_ESCOMPTE_FWD}"
ECHO_LOG "#===> ESF_GTSII_ESCOMPTE...............................................: ${ESF_GTSII_ESCOMPTE}"
ECHO_LOG "#===> ESF_GTSII_ESCOMPTE_RAD...........................................: ${ESF_GTSII_ESCOMPTE_RAD}"
ECHO_LOG "#===> ESF_FSEGPROF_INI.................................................: ${ESF_FSEGPROF_INI}"
ECHO_LOG "#===> ESF_FSEGPROF_STD_PREVIOUS........................................: ${ESF_FSEGPROF_STD_PREVIOUS}"
ECHO_LOG "#===> ESF_CSM_LC_AMORT_PATTERN.........................................: ${ESF_CSM_LC_AMORT_PATTERN}"
ECHO_LOG "#===> ESF_CSM_LC_AMORT_PATTERN_PREV....................................: ${ESF_CSM_LC_AMORT_PATTERN_PREV}"
ECHO_LOG "#===> ESF_DLCUMGTAAR...................................................: ${ESF_DLCUMGTAAR}"
ECHO_LOG "#===> ESF_FSECIFRS.....................................................: ${ESF_FSECIFRS}"
if [ "${PARM_IS_TRN}" == "NO" ]
then
ECHO_LOG "#===> ESF_TRERETFACCTR.................................................: ${ESF_TRERETFACCTR}"
ECHO_LOG "#===> EPO_FCURSII......................................................: ${EPO_FCURSII}"
ECHO_LOG "#===> EST_FSEGPATTERN_DSC_f17..........................................: ${EST_FSEGPATTERN_DSC_f17}"
fi
if [ "${PARM_IS_TRN}" == "YES" ]
then
ECHO_LOG "#===> ESF_TRANSITION_FILE..............................................: ${ESF_TRANSITION_FILE}"
fi

ECHO_LOG "#===> ............ OUTPUT ................................................"
ECHO_LOG "#===> ESF_GTSII_CSM_TMP_CASHFLOW.......................................: ${ESF_GTSII_CSM_TMP_CASHFLOW}"
ECHO_LOG "#===> ESF_CSM_PROF.....................................................: ${ESF_CSM_PROF}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_1
#------------------------------------------------------------------------------
# Merge EST_IADPERICASE_STD with EST_IADPERICASE_INI without duplicate 
#-----------------------------------------------------------------------------
LIBEL=" Merge EST_IADPERICASE_STD with EST_IADPERICASE_INI without duplicate"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE_STD} 2000 1"
SORT_I2="${EST_IADPERICASE_INI} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PERICASE_MERGE.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
END_NT 4:1 - 4:,
SEC_NF 5:1 - 5:,
UWY_NF 6:1 - 6:,
UW_NT 7:1 - 7:
/KEYS CTR_NF,
END_NT,
SEC_NF,
UWY_NF,
UW_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_2
#------------------------------------------------------------------------------

# inputs files
export ESTJ0003_CONTRACT_PERICASE="${DFILT}/${NJOB}_1_${IB}_PERICASE_MERGE.dat"
export ESTJ0003_CONTRACT_RATE_INDEX="${ESF_TRERETFACCTR}"
export ESTJ0003_CSM_EGPPI_EARNE="${ESF_GTSII_IFRS17_CSM}"
export ESTJ0003_CSM_LKI="${ESF_GTSII_CSM}"
export ESTJ0003_CSM_PAFAM="${ESF_GTSII_CSM_CASHFLOW_PREV}"
export ESTJ0003_CURRENCY="${EPO_FCURSII}"
export ESTJ0003_DSC_FWD="${ESF_GTSII_ESCOMPTE_FWD}"
export ESTJ0003_DSC_LKI="${ESF_GTSII_ESCOMPTE}"
export ESTJ0003_RAD_LKI="${ESF_GTSII_ESCOMPTE_RAD}"
export ESTJ0003_PATTERN="${EST_FSEGPATTERN_DSC_f17}"
export ESTJ0003_SEGMENT_PROFITABILITY_INI="${ESF_FSEGPROF_INI}"
export ESTJ0003_SEGMENT_PROFITABILITY_PREV="${ESF_FSEGPROF_STD_PREVIOUS}"
export ESTJ0003_AMORTIZATION_PATTERN_CSM_LC_CURRENT_Q="${ESF_CSM_LC_AMORT_PATTERN}"
export ESTJ0003_AMORTIZATION_PATTERN_CSM_LC_PREVIOUS_Q="${ESF_CSM_LC_AMORT_PATTERN_PREV}"
export ESTJ0003_TRANSITION_FILE="${ESF_TRANSITION_FILE}"
export ESTJ0003_DLCUMGTAAR="${ESF_DLCUMGTAAR}"
export ESTJ0003_CURRENCY_EX_RATE="${EPO_FCURQUOT_TXT}"
export ESTJ0003_SECIFRS="${ESF_FSECIFRS}"

# tmp files
export ESTJ0003_CSM_ACCRE="${DFILT}/${NJOB}_1_${IB}_CSM_ACCRE.dat"
export ESTJ0003_MERGED_CSM_PAFAM_LKI="${DFILT}/${NJOB}_1_${IB}_MERGED_CSM_PAFAM_LKI.dat"
export ESTJ0003_PERICASE_LIGHT="${DFILT}/${NJOB}_1_${IB}_PERICASE_LIGHT.dat"
export ESTJ0003_SORTED_AMORTIZATION_PATTERN_CSM_LC_CURRENT_Q_A="${DFILT}/${NJOB}_1_${IB}_SORTED_AMORTIZATION_PATTERN_CSM_LC_CURRENT_Q_A.dat"
export ESTJ0003_SORTED_AMORTIZATION_PATTERN_CSM_LC_CURRENT_Q_R="${DFILT}/${NJOB}_1_${IB}_SORTED_AMORTIZATION_PATTERN_CSM_LC_CURRENT_Q_R.dat"
export ESTJ0003_SORTED_AMORTIZATION_PATTERN_CSM_LC_PREVIOUS_Q_A="${DFILT}/${NJOB}_1_${IB}_SORTED_AMORTIZATION_PATTERN_CSM_LC_PREVIOUS_Q_A.dat"
export ESTJ0003_SORTED_AMORTIZATION_PATTERN_CSM_LC_PREVIOUS_Q_R="${DFILT}/${NJOB}_1_${IB}_SORTED_AMORTIZATION_PATTERN_CSM_LC_PREVIOUS_Q_R.dat"
export ESTJ0003_SORTED_CONTRACT_RATE_INDEX_ASSUMED="${DFILT}/${NJOB}_1_${IB}_SORTED_CONTRACT_RATE_INDEX_A.dat"
export ESTJ0003_SORTED_CONTRACT_RATE_INDEX_RETRO="${DFILT}/${NJOB}_1_${IB}_SORTED_CONTRACT_RATE_INDEX_R.dat"
export ESTJ0003_SORTED_CSM_ACCRE_A="${DFILT}/${NJOB}_1_${IB}_SORTED_CSM_ACCRE_A.dat"
export ESTJ0003_SORTED_CSM_ACCRE_RP="${DFILT}/${NJOB}_1_${IB}_SORTED_CSM_ACCRE_RP.dat"
export ESTJ0003_SORTED_CSM_ACCRE_RNP="${DFILT}/${NJOB}_1_${IB}_SORTED_CSM_ACCRE_RNP.dat"
export ESTJ0003_SORTED_CSM_EGPPI_EARNE_A="${DFILT}/${NJOB}_1_${IB}_SORTED_CSM_EGPPI_EARNE_A.dat"
export ESTJ0003_SORTED_CSM_EGPPI_EARNE_RP="${DFILT}/${NJOB}_1_${IB}_SORTED_CSM_EGPPI_EARNE_RP.dat"
export ESTJ0003_SORTED_CSM_EGPPI_EARNE_RNP="${DFILT}/${NJOB}_1_${IB}_SORTED_CSM_EGPPI_EARNE_RNP.dat"
export ESTJ0003_SORTED_DSC_FWD_A="${DFILT}/${NJOB}_1_${IB}_SORTED_DSC_FWD_A.dat"
export ESTJ0003_SORTED_DSC_FWD_RP="${DFILT}/${NJOB}_1_${IB}_SORTED_DSC_FWD_RP.dat"
export ESTJ0003_SORTED_DSC_FWD_RNP="${DFILT}/${NJOB}_1_${IB}_SORTED_DSC_FWD_RNP.dat"
export ESTJ0003_SORTED_DSC_LKI_A="${DFILT}/${NJOB}_1_${IB}_SORTED_DSC_LKI_A.dat"
export ESTJ0003_SORTED_DSC_LKI_RP="${DFILT}/${NJOB}_1_${IB}_SORTED_DSC_LKI_RP.dat"
export ESTJ0003_SORTED_DSC_LKI_RNP="${DFILT}/${NJOB}_1_${IB}_SORTED_DSC_LKI_RNP.dat"
export ESTJ0003_SORTED_RAD_LKI_A="${DFILT}/${NJOB}_1_${IB}_SORTED_RAD_LKI_A.dat"
export ESTJ0003_SORTED_RAD_LKI_RP="${DFILT}/${NJOB}_1_${IB}_SORTED_RAD_LKI_RP.dat"
export ESTJ0003_SORTED_RAD_LKI_RNP="${DFILT}/${NJOB}_1_${IB}_SORTED_RAD_LKI_RNP.dat"
export ESTJ0003_SORTED_MERGED_CSM_PAFAM_LKI_A="${DFILT}/${NJOB}_1_${IB}_SORTED_MERGED_CSM_PAFAM_LKI_A.dat"
export ESTJ0003_SORTED_MERGED_CSM_PAFAM_LKI_RP="${DFILT}/${NJOB}_1_${IB}_SORTED_MERGED_CSM_PAFAM_LKI_RP.dat"
export ESTJ0003_SORTED_MERGED_CSM_PAFAM_LKI_RNP="${DFILT}/${NJOB}_1_${IB}_SORTED_MERGED_CSM_PAFAM_LKI_RNP.dat"
export ESTJ0003_SORTED_PERICASE_LIGHT="${DFILT}/${NJOB}_1_${IB}_SORTED_PERICASE_LIGHT.dat"
export ESTJ0003_SORTED_PROFITABILITY_BY_CONTRACT="${DFILT}/${NJOB}_1_${IB}_SORTED_PROFITABILITY_BY_CONTRACT.dat"
export ESTJ0003_SORTED_SEGMENT_PROFITABILITY_INI="${DFILT}/${NJOB}_1_${IB}_SORTED_SEGMENT_PROFITABILITY_INI.dat"
export ESTJ0003_SORTED_SEGMENT_PROFITABILITY_PREV="${DFILT}/${NJOB}_1_${IB}_SORTED_SEGMENT_PROFITABILITY_PREV.dat"
export ESTJ0003_SORTED_CONTRACT_TRANSITION_A="${DFILT}/${NJOB}_1_${IB}_SORTED_TRANSITION_A.dat"
export ESTJ0003_SORTED_CONTRACT_TRANSITION_RP="${DFILT}/${NJOB}_1_${IB}_SORTED_TRANSITION_RP.dat"
export ESTJ0003_SORTED_CONTRACT_TRANSITION_RNP="${DFILT}/${NJOB}_1_${IB}_SORTED_TRANSITION_RNP.dat"
export ESTJ0003_AMORTIZATION_PATTERN_CSM_LC_KEY_RECOVERY="${DFILT}/${NJOB}_1_${IB}_AMORTIZATION_PATTERN_CSM_LC_KEY_RECOVERY.dat"
export ESTJ0003_SORTED_AMORTIZATION_PATTERN_CSM_LC_A_KEY_RECOVERY="${DFILT}/${NJOB}_1_${IB}_SORTED_AMORTIZATION_PATTERN_CSM_LC_A_KEY_RECOVERY.dat"
export ESTJ0003_SORTED_AMORTIZATION_PATTERN_CSM_LC_RP_KEY_RECOVERY="${DFILT}/${NJOB}_1_${IB}_SORTED_AMORTIZATION_PATTERN_CSM_LC_RP_KEY_RECOVERY.dat"
export ESTJ0003_SORTED_AMORTIZATION_PATTERN_CSM_LC_RNP_KEY_RECOVERY="${DFILT}/${NJOB}_1_${IB}_SORTED_AMORTIZATION_PATTERN_CSM_LC_RNP_KEY_RECOVERY.dat"
export ESTJ0003_SORTED_CSM_ACCRE_BY_CSUO_A="${DFILT}/${NJOB}_1_${IB}_SORTED_CSM_ACCRE_BY_CSUO_A.dat"
export ESTJ0003_SORTED_CSM_ACCRE_BY_CSUO_RP="${DFILT}/${NJOB}_1_${IB}_SORTED_CSM_ACCRE_BY_CSUO_RP.dat"
export ESTJ0003_SORTED_CSM_ACCRE_BY_CSUO_RNP="${DFILT}/${NJOB}_1_${IB}_SORTED_CSM_ACCRE_BY_CSUO_RNP.dat"
export ESTJ0003_SORTED_DLCUMGTAAR_A="${DFILT}/${NJOB}_1_${IB}_SORTED_DLCUMGTAAR_A.dat"
export ESTJ0003_SORTED_DLCUMGTAAR_RP="${DFILT}/${NJOB}_1_${IB}_SORTED_DLCUMGTAAR_RP.dat"
export ESTJ0003_SORTED_DLCUMGTAAR_RNP="${DFILT}/${NJOB}_1_${IB}_SORTED_DLCUMGTAAR_RNP.dat"
export ESTJ0003_SORTED_CONTRACT_PERICASE="${DFILT}/${NJOB}_1_${IB}_SORTED_CONTRACT_PERICASE.dat"
export ESTJ0003_SORTED_SECIFRS="${DFILT}/${NJOB}_1_${IB}_SORTED_SECIFRS.dat"
export ESTJ0003_CONTRACT_RATE_INDEX_RECOVERY_PARTIALLY_RECOVERED="${DFILT}/${NJOB}_1_${IB}_CONTRACT_RATE_INDEX_RECOVERY_PARTIALLY_RECOVERED.dat"
export ESTJ0003_SORTED_CONTRACT_RATE_INDEX_RECOVERY_PARTIALLY_RECOVERED_A="${DFILT}/${NJOB}_1_${IB}_SORTED_CONTRACT_RATE_INDEX_RECOVERY_PARTIALLY_RECOVERED_A.dat"
export ESTJ0003_SORTED_CONTRACT_RATE_INDEX_RECOVERY_PARTIALLY_RECOVERED_RNP="${DFILT}/${NJOB}_1_${IB}_SORTED_CONTRACT_RATE_INDEX_RECOVERY_PARTIALLY_RECOVERED_RNP.dat"
export ESTJ0003_SORTED_CONTRACT_RATE_INDEX_RECOVERY_PARTIALLY_RECOVERED_RP="${DFILT}/${NJOB}_1_${IB}_SORTED_CONTRACT_RATE_INDEX_RECOVERY_PARTIALLY_RECOVERED_RP.dat"
export ESTJ0003_CONTRACT_RATE_INDEX_RECOVERY_FULLY_RECOVERED="${DFILT}/${NJOB}_1_${IB}_CONTRACT_RATE_INDEX_RECOVERY_FULLY_RECOVERED.dat"
export ESTJ0003_SORTED_CONTRACT_RATE_INDEX_RECOVERY_FULLY_RECOVERED_A="${DFILT}/${NJOB}_1_${IB}_SORTED_CONTRACT_RATE_INDEX_RECOVERY_FULLY_RECOVERED_A.dat"
export ESTJ0003_SORTED_CONTRACT_RATE_INDEX_RECOVERY_FULLY_RECOVERED_RNP="${DFILT}/${NJOB}_1_${IB}_SORTED_CONTRACT_RATE_INDEX_RECOVERY_FULLY_RECOVERED_RNP.dat"
export ESTJ0003_SORTED_CONTRACT_RATE_INDEX_RECOVERY_FULLY_RECOVERED_RP="${DFILT}/${NJOB}_1_${IB}_SORTED_CONTRACT_RATE_INDEX_RECOVERY_FULLY_RECOVERED_RP.dat"

# outputs files
export ESTJ0003_AGGREGATION_CASHFLOW="${ESF_GTSII_CSM_CASHFLOW}"
export ESTJ0003_PROFITABILITY_BY_CONTRACT="${ESF_CSM_PROF}"

# CMD variable
export SYNCSORT_CMD_ESTJ0003_MERGE_FILE=${DCMD}/ESTS0005.cmd
export SYNCSORT_CMD_ESTJ0003_SORT_CASHFLOW_BY_CTR_ID=${DCMD}/ESTS0053.cmd
export SYNCSORT_CMD_ESTJ0003_SORT_RATE_INDEX_BY_CTR_ID=${DCMD}/ESTS0048.cmd
export SYNCSORT_CMD_ESTJ0003_SORT_AMORTIZATION_PATTERN_BY_CTR_ID=${DCMD}/ESTS0022.cmd
export SYNCSORT_CMD_ESTJ0003_SORT_CONTRACT_PERICASE_LIGHT_BY_SEGMENT_ID=${DCMD}/ESTS0014.cmd
export SYNCSORT_CMD_ESTJ0003_SORT_SEGMENT_PROFITABILITY_BY_SEGMENT_ID=${DCMD}/ESTS0001.cmd
export SYNCSORT_CMD_ESTJ0003_SORT_PROFITABILITY_BY_CONTRACT_BY_CTR_ID=${DCMD}/ESTS0017.cmd
export SYNCSORT_CMD_ESTJ0003_SORT_TRANSITION_BY_CTR_ID=${DCMD}/ESTS0024.cmd
export SYNCSORT_CMD_ESTJ0003_SORT_CASHFLOW_FOR_AMORT_BY_CTR_ID=${DCMD}/ESTS0036.cmd
export SYNCSORT_CMD_ESTJ0003_SORT_CASHFLOW_FOR_ACCRE_BY_CTR_ID=${DCMD}/ESTS0034.cmd
export SYNCSORT_CMD_ESTJ0003_SORT_AMORTIZATION_PATTERN_KEY_RECOVERY_BY_CTR_ID=${DCMD}/ESTS0035.cmd
export SYNCSORT_CMD_ESTJ0003_SORT_DLCUMGTAAR_BY_CTR_ID=${DCMD}/ESTS0042.cmd
export SYNCSORT_CMD_ESTJ0003_SORT_CONTRACT_PERICASE_BY_CSUOE=${DCMD}/ESTS0003.cmd
export SYNCSORT_CMD_ESTJ0003_SORT_SECIFRS_BY_CSUOE=${DCMD}/ESTS0055.cmd
export SYNCSORT_CMD_ESTJ0003_SORT_RATE_INDEX_EXTENDED_BY_CSUOE_A_FOR_RP=${DCMD}/ESTS0061.cmd
export SYNCSORT_CMD_ESTJ0003_SORT_RATE_INDEX_EXTENDED_BY_CSUOE_R_FOR_RP=${DCMD}/ESTS0062.cmd

# Jar execution
JSB_CHAIN="estj0003"
JSB_PARAMS="cloDate=${PARM_ICLODAT_D} prevCloDate=${PARM_PREV_ICLODAT_D} cloType=${TYPEINV} normcf=${NORME_CF} cloUser=${PARM_BATCHUSER} isTrnMode=${PARM_IS_TRN}"
EXECJSB

NSTEP=${NJOB}_03
#------------------------------------------------------------------------------
# Sort ESF_GTSII_CSM_CASHFLOW For Assume Contracts 
#-----------------------------------------------------------------------------
LIBEL="Sort ESF_GTSII_CSM_CASHFLOW For Assume Contracts"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_GTSII_CSM_CASHFLOW} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_CASHFLOW_ASSUME.dat 20001 "
INPUT_TEXT ${SORT_CMD} <<EOF

/FIELDS
	SSD_CF            1:1 -  1:EN,					
    ESB_CF            2:1 -  2:EN,
    BALSHEY_NF        3:1 -  3:,
    BALSHRMTH_NF      4:1 -  4:,
    BALSHRDAY_NF      5:1 -  5:,
    TRNCOD_CF         6:1 -  6:,
    DBLTRNCOD_CF      7:1 -  7:,
    CTR_NF            8:1 -  8:,
    END_NT            9:1 -  9:EN 15/3,
    SEC_NF           10:1 - 10:,
    UWY_NF           11:1 - 11:,
    UW_NT            12:1 - 12:,
    OCCYEA_NF        13:1 - 13:,
    ACY_NF           14:1 - 14:,
    SCOSTRMTH_NF     15:1 - 15:EN,
    SCOENDMTH_NF     16:1 - 16:EN,
    CLM_NF           17:1 - 17:,
    CUR_CF           18:1 - 18:,
    AMT_M            19:1 - 19:EN 15/3,
    CED_NF           20:1 - 20:,
    BRK_NF           21:1 - 21:,
    PAY_NF           22:1 - 22:,
    KEY_NF           23:1 - 23:,
    RETCTR_NF        24:1 - 24:,
    RETEND_NT        25:1 - 25:,
    RETSEC_NF        26:1 - 26:,
    RTY_NF           27:1 - 27:,
    RETUW_NT         28:1 - 28:,
    RETOCCYEA_NF     29:1 - 29:,
    RETACY_NF        30:1 - 30:,
    RETSCOSTRMTH_NF  31:1 - 31:EN,
    RETSCOENDMTH_NF  32:1 - 32:EN,
    RCL_NF           33:1 - 33:,
    RETCUR_CF        34:1 - 34:,
    RETAMT_M         35:1 - 35:EN 15/3,
    PLC_NT           36:1 - 36:,
    RTO_NF           37:1 - 37:,
    INT_NF           38:1 - 38:,
    RETPAY_NF        39:1 - 39:,
    RETKEY_CF        40:1 - 40:,
    RETINTAMT_M      41:1 - 41:EN 15/3,
    ACMTRS_NT        42:1 - 42:,
    ACMAMT_M         43:1 - 43:EN 15/3,
    ACMCUR_CF        44:1 - 44:,
    PRS_CF           45:1 - 45:,
    SEG_NF           46:1 - 46:,
    LOB_CF           47:1 - 47:,
    NAT_CF           48:1 - 48:,
    TYP_CT           49:1 - 49:,
    NORME_CF         50:1 - 50:,
    RATING_CF        51:1 - 51:,
    PATCAT_CT        52:1 - 52:,
    PATTYP_CT        53:1 - 53:,
    PATTERN_ID       54:1 - 54:,
    AM01_M           55:1 - 55:EN 15/3,
    AM02_M           56:1 - 56:EN 15/3,
    AM03_M           57:1 - 57:EN 15/3,
    AM04_M           58:1 - 58:EN 15/3,
    AM05_M           59:1 - 59:EN 15/3,
    AM06_M           60:1 - 60:EN 15/3,
    AM07_M           61:1 - 61:EN 15/3,
    AM08_M           62:1 - 62:EN 15/3,
    AM09_M           63:1 - 63:EN 15/3,
    AM10_M           64:1 - 64:EN 15/3,
    AM11_M           65:1 - 65:EN 15/3,
    AM12_M           66:1 - 66:EN 15/3,
    AM13_M           67:1 - 67:EN 15/3,
    AM14_M           68:1 - 68:EN 15/3,
    AM15_M           69:1 - 69:EN 15/3,
    AM16_M           70:1 - 70:EN 15/3,
    AM17_M           71:1 - 71:EN 15/3,
    AM18_M           72:1 - 72:EN 15/3,
    AM19_M           73:1 - 73:EN 15/3,
    AM20_M           74:1 - 74:EN 15/3,
    AM21_M           75:1 - 75:EN 15/3,
    AM22_M           76:1 - 76:EN 15/3,
    AM23_M           77:1 - 77:EN 15/3,
    AM24_M           78:1 - 78:EN 15/3,
    AM25_M           79:1 - 79:EN 15/3,
    AM26_M           80:1 - 80:EN 15/3,
    AM27_M           81:1 - 81:EN 15/3,
    AM28_M           82:1 - 82:EN 15/3,
    AM29_M           83:1 - 83:EN 15/3,
    AM30_M           84:1 - 84:EN 15/3,
    AM31_M           85:1 - 85:EN 15/3,
    AM32_M           86:1 - 86:EN 15/3,
    AM33_M           87:1 - 87:EN 15/3,
    AM34_M           88:1 - 88:EN 15/3,
    AM35_M           89:1 - 89:EN 15/3,
    AM36_M           90:1 - 90:EN 15/3,
    AM37_M           91:1 - 91:EN 15/3,
    AM38_M           92:1 - 92:EN 15/3,
    AM39_M           93:1 - 93:EN 15/3,
    AM40_M           94:1 - 94:EN 15/3,
    AM41_M           95:1 - 95:EN 15/3,
    AM42_M           96:1 - 96:EN 15/3,
    AM43_M           97:1 - 97:EN 15/3,
    AM44_M           98:1 - 98:EN 15/3,
    AM45_M           99:1 - 99:EN 15/3,
    AM46_M          100:1 - 100:EN 15/3,
    AM47_M          101:1 - 101:EN 15/3,
    AM48_M          102:1 - 102:EN 15/3,
    AM49_M          103:1 - 103:EN 15/3,
    AM50_M          104:1 - 104:EN 15/3,
    AM51_M          105:1 - 105:EN 15/3,
    AM52_M          106:1 - 106:EN 15/3,
    AM53_M          107:1 - 107:EN 15/3,
    AM54_M          108:1 - 108:EN 15/3,
    AM55_M          109:1 - 109:EN 15/3,
    AM56_M          110:1 - 110:EN 15/3,
    AM57_M          111:1 - 111:EN 15/3,
    AM58_M          112:1 - 112:EN 15/3,
    AM59_M          113:1 - 113:EN 15/3,
    AM60_M          114:1 - 114:EN 15/3,
    AM61_M          115:1 - 115:EN 15/3,
    AM62_M          116:1 - 116:EN 15/3,
    AM63_M          117:1 - 117:EN 15/3,
    AM64_M          118:1 - 118:EN 15/3,
    AM65_M          119:1 - 119:EN 15/3,
    COEF_LOB        120:1 - 120:,
    DSCCUR_CF       121:1 - 121:,
    COMMENT         122:1 - 122:,
    TOTAUX_M        123:1 - 123:EN 15/3,
    ACMTRS3_NT      124:1 - 124:

/KEYS
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT,
	END_NT DESC
	
/CONDITION ASSUM_CTR TYP_CT = "A" OR TYP_CT = "AI"
/INCLUDE ASSUM_CTR
/OUTFILE ${SORT_O}

exit
EOF
SORT

NSTEP=${NJOB}_04
#-----------------------------------------------------------------------------
# Sort ESF_GTSII_CSM_CASHFLOW For Retro Contracts 
#-----------------------------------------------------------------------------
LIBEL="Sort ESF_GTSII_CSM_CASHFLOW For Retro Contracts"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_GTSII_CSM_CASHFLOW} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_CASHFLOW_RETRO.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF            1:1 -  1:EN,					
    ESB_CF            2:1 -  2:EN,
    BALSHEY_NF        3:1 -  3:,
    BALSHRMTH_NF      4:1 -  4:,
    BALSHRDAY_NF      5:1 -  5:,
    TRNCOD_CF         6:1 -  6:,
    DBLTRNCOD_CF      7:1 -  7:,
    CTR_NF            8:1 -  8:,
    END_NT            9:1 -  9:EN 15/3,
    SEC_NF           10:1 - 10:,
    UWY_NF           11:1 - 11:,
    UW_NT            12:1 - 12:,
    OCCYEA_NF        13:1 - 13:,
    ACY_NF           14:1 - 14:,
    SCOSTRMTH_NF     15:1 - 15:EN,
    SCOENDMTH_NF     16:1 - 16:EN,
    CLM_NF           17:1 - 17:,
    CUR_CF           18:1 - 18:,
    AMT_M            19:1 - 19:EN 15/3,
    CED_NF           20:1 - 20:,
    BRK_NF           21:1 - 21:,
    PAY_NF           22:1 - 22:,
    KEY_NF           23:1 - 23:,
    RETCTR_NF        24:1 - 24:,
    RETEND_NT        25:1 - 25:,
    RETSEC_NF        26:1 - 26:,
    RTY_NF           27:1 - 27:,
    RETUW_NT         28:1 - 28:,
    RETOCCYEA_NF     29:1 - 29:,
    RETACY_NF        30:1 - 30:,
    RETSCOSTRMTH_NF  31:1 - 31:EN,
    RETSCOENDMTH_NF  32:1 - 32:EN,
    RCL_NF           33:1 - 33:,
    RETCUR_CF        34:1 - 34:,
    RETAMT_M         35:1 - 35:EN 15/3,
    PLC_NT           36:1 - 36:,
    RTO_NF           37:1 - 37:,
    INT_NF           38:1 - 38:,
    RETPAY_NF        39:1 - 39:,
    RETKEY_CF        40:1 - 40:,
    RETINTAMT_M      41:1 - 41:EN 15/3,
    ACMTRS_NT        42:1 - 42:,
    ACMAMT_M         43:1 - 43:EN 15/3,
    ACMCUR_CF        44:1 - 44:,
    PRS_CF           45:1 - 45:,
    SEG_NF           46:1 - 46:,
    LOB_CF           47:1 - 47:,
    NAT_CF           48:1 - 48:,
    TYP_CT           49:1 - 49:,
    NORME_CF         50:1 - 50:,
    RATING_CF        51:1 - 51:,
    PATCAT_CT        52:1 - 52:,
    PATTYP_CT        53:1 - 53:,
    PATTERN_ID       54:1 - 54:,
    AM01_M           55:1 - 55:EN 15/3,
    AM02_M           56:1 - 56:EN 15/3,
    AM03_M           57:1 - 57:EN 15/3,
    AM04_M           58:1 - 58:EN 15/3,
    AM05_M           59:1 - 59:EN 15/3,
    AM06_M           60:1 - 60:EN 15/3,
    AM07_M           61:1 - 61:EN 15/3,
    AM08_M           62:1 - 62:EN 15/3,
    AM09_M           63:1 - 63:EN 15/3,
    AM10_M           64:1 - 64:EN 15/3,
    AM11_M           65:1 - 65:EN 15/3,
    AM12_M           66:1 - 66:EN 15/3,
    AM13_M           67:1 - 67:EN 15/3,
    AM14_M           68:1 - 68:EN 15/3,
    AM15_M           69:1 - 69:EN 15/3,
    AM16_M           70:1 - 70:EN 15/3,
    AM17_M           71:1 - 71:EN 15/3,
    AM18_M           72:1 - 72:EN 15/3,
    AM19_M           73:1 - 73:EN 15/3,
    AM20_M           74:1 - 74:EN 15/3,
    AM21_M           75:1 - 75:EN 15/3,
    AM22_M           76:1 - 76:EN 15/3,
    AM23_M           77:1 - 77:EN 15/3,
    AM24_M           78:1 - 78:EN 15/3,
    AM25_M           79:1 - 79:EN 15/3,
    AM26_M           80:1 - 80:EN 15/3,
    AM27_M           81:1 - 81:EN 15/3,
    AM28_M           82:1 - 82:EN 15/3,
    AM29_M           83:1 - 83:EN 15/3,
    AM30_M           84:1 - 84:EN 15/3,
    AM31_M           85:1 - 85:EN 15/3,
    AM32_M           86:1 - 86:EN 15/3,
    AM33_M           87:1 - 87:EN 15/3,
    AM34_M           88:1 - 88:EN 15/3,
    AM35_M           89:1 - 89:EN 15/3,
    AM36_M           90:1 - 90:EN 15/3,
    AM37_M           91:1 - 91:EN 15/3,
    AM38_M           92:1 - 92:EN 15/3,
    AM39_M           93:1 - 93:EN 15/3,
    AM40_M           94:1 - 94:EN 15/3,
    AM41_M           95:1 - 95:EN 15/3,
    AM42_M           96:1 - 96:EN 15/3,
    AM43_M           97:1 - 97:EN 15/3,
    AM44_M           98:1 - 98:EN 15/3,
    AM45_M           99:1 - 99:EN 15/3,
    AM46_M          100:1 - 100:EN 15/3,
    AM47_M          101:1 - 101:EN 15/3,
    AM48_M          102:1 - 102:EN 15/3,
    AM49_M          103:1 - 103:EN 15/3,
    AM50_M          104:1 - 104:EN 15/3,
    AM51_M          105:1 - 105:EN 15/3,
    AM52_M          106:1 - 106:EN 15/3,
    AM53_M          107:1 - 107:EN 15/3,
    AM54_M          108:1 - 108:EN 15/3,
    AM55_M          109:1 - 109:EN 15/3,
    AM56_M          110:1 - 110:EN 15/3,
    AM57_M          111:1 - 111:EN 15/3,
    AM58_M          112:1 - 112:EN 15/3,
    AM59_M          113:1 - 113:EN 15/3,
    AM60_M          114:1 - 114:EN 15/3,
    AM61_M          115:1 - 115:EN 15/3,
    AM62_M          116:1 - 116:EN 15/3,
    AM63_M          117:1 - 117:EN 15/3,
    AM64_M          118:1 - 118:EN 15/3,
    AM65_M          119:1 - 119:EN 15/3,
    COEF_LOB        120:1 - 120:,
    DSCCUR_CF       121:1 - 121:,
    COMMENT         122:1 - 122:,
    TOTAUX_M        123:1 - 123:EN 15/3,
    ACMTRS3_NT      124:1 - 124:
/KEYS
	RETCTR_NF,
	RETSEC_NF,
	RTY_NF,
	RETUW_NT,
	RETEND_NT DESC
	
	
/CONDITION RETRO_CTR TYP_CT = "R" OR TYP_CT = "RI"
/INCLUDE RETRO_CTR
/OUTFILE ${SORT_O}

exit
EOF
SORT

NSTEP=${NJOB}_05
#-----------------------------------------------------------------------------
# Sort Assume file based on CSUO 
#-----------------------------------------------------------------------------
LIBEL="Sort assume file based on CSUO"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_03_${IB}_CSM_CASHFLOW_ASSUME.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_CASHFLOW_ASSUME_SUMMARIZE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF            1:1 -  1:EN,					
    ESB_CF            2:1 -  2:EN,
    BALSHEY_NF        3:1 -  3:,
    BALSHRMTH_NF      4:1 -  4:,
    BALSHRDAY_NF      5:1 -  5:,
    TRNCOD_CF         6:1 -  6:,
    DBLTRNCOD_CF      7:1 -  7:,
    CTR_NF            8:1 -  8:,
    END_NT            9:1 -  9:,
    SEC_NF           10:1 - 10:,
    UWY_NF           11:1 - 11:,
    UW_NT            12:1 - 12:,
    OCCYEA_NF        13:1 - 13:,
    ACY_NF           14:1 - 14:,
    SCOSTRMTH_NF     15:1 - 15:EN,
    SCOENDMTH_NF     16:1 - 16:EN,
    CLM_NF           17:1 - 17:,
    CUR_CF           18:1 - 18:,
    FILLER1			  1:1 - 18:,
    AMT_M            19:1 - 19:EN 15/3,
    CED_NF           20:1 - 20:,
    BRK_NF           21:1 - 21:,
    PAY_NF           22:1 - 22:,
    KEY_NF           23:1 - 23:,
    RETCTR_NF        24:1 - 24:,
    RETEND_NT        25:1 - 25:,
    RETSEC_NF        26:1 - 26:,
    RTY_NF           27:1 - 27:,
    RETUW_NT         28:1 - 28:,
    RETOCCYEA_NF     29:1 - 29:,
    RETACY_NF        30:1 - 30:,
    RETSCOSTRMTH_NF  31:1 - 31:EN,
    RETSCOENDMTH_NF  32:1 - 32:EN,
    RCL_NF           33:1 - 33:,
    RETCUR_CF        34:1 - 34:,
    FILLER2	     	 20:1 - 34:,
    RETAMT_M         35:1 - 35:EN 15/3,
    PLC_NT           36:1 - 36:,
    RTO_NF           37:1 - 37:,
    INT_NF           38:1 - 38:,
    RETPAY_NF        39:1 - 39:,
    RETKEY_CF        40:1 - 40:,
    FILLER3    	     36:1 - 40:,
    RETINTAMT_M      41:1 - 41:EN 15/3,
    ACMTRS_NT        42:1 - 42:,
    FILLER4	     	 42:1 - 42:,
    ACMAMT_M         43:1 - 43:EN 15/3,
    ACMCUR_CF        44:1 - 44:,
    PRS_CF           45:1 - 45:,
    SEG_NF           46:1 - 46:,
    LOB_CF           47:1 - 47:,
    NAT_CF           48:1 - 48:,
    TYP_CT           49:1 - 49:,
    NORME_CF         50:1 - 50:,
    RATING_CF        51:1 - 51:,
    PATCAT_CT        52:1 - 52:,
    PATTYP_CT        53:1 - 53:,
    PATTERN_ID       54:1 - 54:,
    AM01_M           55:1 - 55:EN 15/3,
    AM02_M           56:1 - 56:EN 15/3,
    AM03_M           57:1 - 57:EN 15/3,
    AM04_M           58:1 - 58:EN 15/3,
    AM05_M           59:1 - 59:EN 15/3,
    AM06_M           60:1 - 60:EN 15/3,
    AM07_M           61:1 - 61:EN 15/3,
    AM08_M           62:1 - 62:EN 15/3,
    AM09_M           63:1 - 63:EN 15/3,
    AM10_M           64:1 - 64:EN 15/3,
    AM11_M           65:1 - 65:EN 15/3,
    AM12_M           66:1 - 66:EN 15/3,
    AM13_M           67:1 - 67:EN 15/3,
    AM14_M           68:1 - 68:EN 15/3,
    AM15_M           69:1 - 69:EN 15/3,
    AM16_M           70:1 - 70:EN 15/3,
    AM17_M           71:1 - 71:EN 15/3,
    AM18_M           72:1 - 72:EN 15/3,
    AM19_M           73:1 - 73:EN 15/3,
    AM20_M           74:1 - 74:EN 15/3,
    AM21_M           75:1 - 75:EN 15/3,
    AM22_M           76:1 - 76:EN 15/3,
    AM23_M           77:1 - 77:EN 15/3,
    AM24_M           78:1 - 78:EN 15/3,
    AM25_M           79:1 - 79:EN 15/3,
    AM26_M           80:1 - 80:EN 15/3,
    AM27_M           81:1 - 81:EN 15/3,
    AM28_M           82:1 - 82:EN 15/3,
    AM29_M           83:1 - 83:EN 15/3,
    AM30_M           84:1 - 84:EN 15/3,
    AM31_M           85:1 - 85:EN 15/3,
    AM32_M           86:1 - 86:EN 15/3,
    AM33_M           87:1 - 87:EN 15/3,
    AM34_M           88:1 - 88:EN 15/3,
    AM35_M           89:1 - 89:EN 15/3,
    AM36_M           90:1 - 90:EN 15/3,
    AM37_M           91:1 - 91:EN 15/3,
    AM38_M           92:1 - 92:EN 15/3,
    AM39_M           93:1 - 93:EN 15/3,
    AM40_M           94:1 - 94:EN 15/3,
    AM41_M           95:1 - 95:EN 15/3,
    AM42_M           96:1 - 96:EN 15/3,
    AM43_M           97:1 - 97:EN 15/3,
    AM44_M           98:1 - 98:EN 15/3,
    AM45_M           99:1 - 99:EN 15/3,
    AM46_M          100:1 - 100:EN 15/3,
    AM47_M          101:1 - 101:EN 15/3,
    AM48_M          102:1 - 102:EN 15/3,
    AM49_M          103:1 - 103:EN 15/3,
    AM50_M          104:1 - 104:EN 15/3,
    AM51_M          105:1 - 105:EN 15/3,
    AM52_M          106:1 - 106:EN 15/3,
    AM53_M          107:1 - 107:EN 15/3,
    AM54_M          108:1 - 108:EN 15/3,
    AM55_M          109:1 - 109:EN 15/3,
    AM56_M          110:1 - 110:EN 15/3,
    AM57_M          111:1 - 111:EN 15/3,
    AM58_M          112:1 - 112:EN 15/3,
    AM59_M          113:1 - 113:EN 15/3,
    AM60_M          114:1 - 114:EN 15/3,
    AM61_M          115:1 - 115:EN 15/3,
    AM62_M          116:1 - 116:EN 15/3,
    AM63_M          117:1 - 117:EN 15/3,
    AM64_M          118:1 - 118:EN 15/3,
    AM65_M          119:1 - 119:EN 15/3,
    COEF_LOB        120:1 - 120:,
    DSCCUR_CF       121:1 - 121:,
    COMMENT         122:1 - 122:,
    FILLER44_54		 44:1 - 54:,
	FILLER120_122   120:1 - 122:,
    TOTAUX_M        123:1 - 123:EN 15/3,
    ACMTRS3_NT      124:1 - 124:

/KEYS
	SSD_CF,
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT,
	ESB_CF,
	ACMTRS_NT,
	ACMCUR_CF,
	TYP_CT,
	NORME_CF,
	PATCAT_CT,
	PATTYP_CT,
	ACMTRS3_NT
	
/STABLE
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M, TOTAL ACMAMT_M,
		   TOTAL AM01_M, TOTAL AM02_M, TOTAL AM03_M, TOTAL AM04_M, TOTAL AM05_M, TOTAL AM06_M, TOTAL AM07_M, TOTAL AM08_M, TOTAL AM09_M, TOTAL AM10_M,
           TOTAL AM11_M, TOTAL AM12_M, TOTAL AM13_M, TOTAL AM14_M, TOTAL AM15_M, TOTAL AM16_M, TOTAL AM17_M, TOTAL AM18_M, TOTAL AM19_M, TOTAL AM20_M,
           TOTAL AM21_M, TOTAL AM22_M, TOTAL AM23_M, TOTAL AM24_M, TOTAL AM25_M, TOTAL AM26_M, TOTAL AM27_M, TOTAL AM28_M, TOTAL AM29_M, TOTAL AM30_M,
           TOTAL AM31_M, TOTAL AM32_M, TOTAL AM33_M, TOTAL AM34_M, TOTAL AM35_M, TOTAL AM36_M, TOTAL AM37_M, TOTAL AM38_M, TOTAL AM39_M, TOTAL AM40_M,
           TOTAL AM41_M, TOTAL AM42_M, TOTAL AM43_M, TOTAL AM44_M, TOTAL AM45_M, TOTAL AM46_M, TOTAL AM47_M, TOTAL AM48_M, TOTAL AM49_M, TOTAL AM50_M,
           TOTAL AM51_M, TOTAL AM52_M, TOTAL AM53_M, TOTAL AM54_M, TOTAL AM55_M, TOTAL AM56_M, TOTAL AM57_M, TOTAL AM58_M, TOTAL AM59_M, TOTAL AM60_M,
           TOTAL AM61_M, TOTAL AM62_M, TOTAL AM63_M, TOTAL AM64_M, TOTAL AM65_M, 
		   TOTAL TOTAUX_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD ACMAMT_MC ACMAMT_M COMPRESS
/DERIVEDFIELD AM01_MC AM01_M COMPRESS
/DERIVEDFIELD AM02_MC AM02_M COMPRESS
/DERIVEDFIELD AM03_MC AM03_M COMPRESS
/DERIVEDFIELD AM04_MC AM04_M COMPRESS
/DERIVEDFIELD AM05_MC AM05_M COMPRESS
/DERIVEDFIELD AM06_MC AM06_M COMPRESS
/DERIVEDFIELD AM07_MC AM07_M COMPRESS
/DERIVEDFIELD AM08_MC AM08_M COMPRESS
/DERIVEDFIELD AM09_MC AM09_M COMPRESS
/DERIVEDFIELD AM10_MC AM10_M COMPRESS
/DERIVEDFIELD AM11_MC AM11_M COMPRESS
/DERIVEDFIELD AM12_MC AM12_M COMPRESS
/DERIVEDFIELD AM13_MC AM13_M COMPRESS
/DERIVEDFIELD AM14_MC AM14_M COMPRESS
/DERIVEDFIELD AM15_MC AM15_M COMPRESS
/DERIVEDFIELD AM16_MC AM16_M COMPRESS
/DERIVEDFIELD AM17_MC AM17_M COMPRESS
/DERIVEDFIELD AM18_MC AM18_M COMPRESS
/DERIVEDFIELD AM19_MC AM19_M COMPRESS
/DERIVEDFIELD AM20_MC AM20_M COMPRESS
/DERIVEDFIELD AM21_MC AM21_M COMPRESS
/DERIVEDFIELD AM22_MC AM22_M COMPRESS
/DERIVEDFIELD AM23_MC AM23_M COMPRESS
/DERIVEDFIELD AM24_MC AM24_M COMPRESS
/DERIVEDFIELD AM25_MC AM25_M COMPRESS
/DERIVEDFIELD AM26_MC AM26_M COMPRESS
/DERIVEDFIELD AM27_MC AM27_M COMPRESS
/DERIVEDFIELD AM28_MC AM28_M COMPRESS
/DERIVEDFIELD AM29_MC AM29_M COMPRESS
/DERIVEDFIELD AM30_MC AM30_M COMPRESS
/DERIVEDFIELD AM31_MC AM31_M COMPRESS
/DERIVEDFIELD AM32_MC AM32_M COMPRESS
/DERIVEDFIELD AM33_MC AM33_M COMPRESS
/DERIVEDFIELD AM34_MC AM34_M COMPRESS
/DERIVEDFIELD AM35_MC AM35_M COMPRESS
/DERIVEDFIELD AM36_MC AM36_M COMPRESS
/DERIVEDFIELD AM37_MC AM37_M COMPRESS
/DERIVEDFIELD AM38_MC AM38_M COMPRESS
/DERIVEDFIELD AM39_MC AM39_M COMPRESS
/DERIVEDFIELD AM40_MC AM40_M COMPRESS
/DERIVEDFIELD AM41_MC AM41_M COMPRESS
/DERIVEDFIELD AM42_MC AM42_M COMPRESS
/DERIVEDFIELD AM43_MC AM43_M COMPRESS
/DERIVEDFIELD AM44_MC AM44_M COMPRESS
/DERIVEDFIELD AM45_MC AM45_M COMPRESS
/DERIVEDFIELD AM46_MC AM46_M COMPRESS
/DERIVEDFIELD AM47_MC AM47_M COMPRESS
/DERIVEDFIELD AM48_MC AM48_M COMPRESS
/DERIVEDFIELD AM49_MC AM49_M COMPRESS
/DERIVEDFIELD AM50_MC AM50_M COMPRESS
/DERIVEDFIELD AM51_MC AM51_M COMPRESS
/DERIVEDFIELD AM52_MC AM52_M COMPRESS
/DERIVEDFIELD AM53_MC AM53_M COMPRESS
/DERIVEDFIELD AM54_MC AM54_M COMPRESS
/DERIVEDFIELD AM55_MC AM55_M COMPRESS
/DERIVEDFIELD AM56_MC AM56_M COMPRESS
/DERIVEDFIELD AM57_MC AM57_M COMPRESS
/DERIVEDFIELD AM58_MC AM58_M COMPRESS
/DERIVEDFIELD AM59_MC AM59_M COMPRESS
/DERIVEDFIELD AM60_MC AM60_M COMPRESS
/DERIVEDFIELD AM61_MC AM61_M COMPRESS
/DERIVEDFIELD AM62_MC AM62_M COMPRESS
/DERIVEDFIELD AM63_MC AM63_M COMPRESS
/DERIVEDFIELD AM64_MC AM64_M COMPRESS
/DERIVEDFIELD AM65_MC AM65_M COMPRESS
/DERIVEDFIELD TOTAUX_MC TOTAUX_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT
	FILLER1,
	AMT_MC,
	FILLER2,
	RETAMT_MC,
	FILLER3,
	RETINTAMT_MC,
	FILLER4,
	ACMAMT_MC,
	FILLER44_54
	,AM01_MC
	,AM02_MC
	,AM03_MC
	,AM04_MC
	,AM05_MC
	,AM06_MC
	,AM07_MC
	,AM08_MC
	,AM09_MC
	,AM10_MC
	,AM11_MC
	,AM12_MC
	,AM13_MC
	,AM14_MC
	,AM15_MC
	,AM16_MC
	,AM17_MC
	,AM18_MC
	,AM19_MC
	,AM20_MC
	,AM21_MC
	,AM22_MC
	,AM23_MC
	,AM24_MC
	,AM25_MC
	,AM26_MC
	,AM27_MC
	,AM28_MC
	,AM29_MC
	,AM30_MC
	,AM31_MC
	,AM32_MC
	,AM33_MC
	,AM34_MC
	,AM35_MC
	,AM36_MC
	,AM37_MC
	,AM38_MC
	,AM39_MC
	,AM40_MC
	,AM41_MC
	,AM42_MC
	,AM43_MC
	,AM44_MC
	,AM45_MC
	,AM46_MC
	,AM47_MC
	,AM48_MC
	,AM49_MC
	,AM50_MC
	,AM51_MC
	,AM52_MC
	,AM53_MC
	,AM54_MC
	,AM55_MC
	,AM56_MC
	,AM57_MC
	,AM58_MC
	,AM59_MC
	,AM60_MC
	,AM61_MC
	,AM62_MC
	,AM63_MC
	,AM64_MC
	,AM65_MC
	,FILLER120_122
	,TOTAUX_MC
	,ACMTRS3_NT
	
exit
EOF
SORT

NSTEP=${NJOB}_06
#-----------------------------------------------------------------------------
# Sort retro file based on CSUO 
#-----------------------------------------------------------------------------
LIBEL="Sort retro file based on CSUO"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_04_${IB}_CSM_CASHFLOW_RETRO.dat 2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_CASHFLOW_RETRO_SUMMARIZE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF            1:1 -  1:EN,					
    ESB_CF            2:1 -  2:EN,
    BALSHEY_NF        3:1 -  3:,
    BALSHRMTH_NF      4:1 -  4:,
    BALSHRDAY_NF      5:1 -  5:,
    TRNCOD_CF         6:1 -  6:,
    DBLTRNCOD_CF      7:1 -  7:,
    CTR_NF            8:1 -  8:,
    END_NT            9:1 -  9:,
    SEC_NF           10:1 - 10:,
    UWY_NF           11:1 - 11:,
    UW_NT            12:1 - 12:,
    OCCYEA_NF        13:1 - 13:,
    ACY_NF           14:1 - 14:,
    SCOSTRMTH_NF     15:1 - 15:EN,
    SCOENDMTH_NF     16:1 - 16:EN,
    CLM_NF           17:1 - 17:,
    CUR_CF           18:1 - 18:,
    FILLER1	     	  1:1  - 18:,
    AMT_M            19:1 - 19:EN 15/3,
    CED_NF           20:1 - 20:,
    BRK_NF           21:1 - 21:,
    PAY_NF           22:1 - 22:,
    KEY_NF           23:1 - 23:,
    RETCTR_NF        24:1 - 24:,
    RETEND_NT        25:1 - 25:,
    RETSEC_NF        26:1 - 26:,
    RTY_NF           27:1 - 27:,
    RETUW_NT         28:1 - 28:,
    RETOCCYEA_NF     29:1 - 29:,
    RETACY_NF        30:1 - 30:,
    RETSCOSTRMTH_NF  31:1 - 31:EN,
    RETSCOENDMTH_NF  32:1 - 32:EN,
    RCL_NF           33:1 - 33:,
    RETCUR_CF        34:1 - 34:,
    FILLER2	     	 20:1 - 34:,
    RETAMT_M         35:1 - 35:EN 15/3,
    PLC_NT           36:1 - 36:,
    RTO_NF           37:1 - 37:,
    INT_NF           38:1 - 38:,
    RETPAY_NF        39:1 - 39:,
    RETKEY_CF        40:1 - 40:,
    FILLER3	     	 36:1 - 40:,
    RETINTAMT_M      41:1 - 41:EN 15/3,
    ACMTRS_NT        42:1 - 42:,
    FILLER4	    	 42:1 - 42:,
    ACMAMT_M         43:1 - 43:EN 15/3,
    ACMCUR_CF        44:1 - 44:,
    PRS_CF           45:1 - 45:,
    SEG_NF           46:1 - 46:,
    LOB_CF           47:1 - 47:,
    NAT_CF           48:1 - 48:,
    TYP_CT           49:1 - 49:,
    NORME_CF         50:1 - 50:,
    RATING_CF        51:1 - 51:,
    PATCAT_CT        52:1 - 52:,
    PATTYP_CT        53:1 - 53:,
    PATTERN_ID       54:1 - 54:,
    AM01_M           55:1 - 55:EN 15/3,
    AM02_M           56:1 - 56:EN 15/3,
    AM03_M           57:1 - 57:EN 15/3,
    AM04_M           58:1 - 58:EN 15/3,
    AM05_M           59:1 - 59:EN 15/3,
    AM06_M           60:1 - 60:EN 15/3,
    AM07_M           61:1 - 61:EN 15/3,
    AM08_M           62:1 - 62:EN 15/3,
    AM09_M           63:1 - 63:EN 15/3,
    AM10_M           64:1 - 64:EN 15/3,
    AM11_M           65:1 - 65:EN 15/3,
    AM12_M           66:1 - 66:EN 15/3,
    AM13_M           67:1 - 67:EN 15/3,
    AM14_M           68:1 - 68:EN 15/3,
    AM15_M           69:1 - 69:EN 15/3,
    AM16_M           70:1 - 70:EN 15/3,
    AM17_M           71:1 - 71:EN 15/3,
    AM18_M           72:1 - 72:EN 15/3,
    AM19_M           73:1 - 73:EN 15/3,
    AM20_M           74:1 - 74:EN 15/3,
    AM21_M           75:1 - 75:EN 15/3,
    AM22_M           76:1 - 76:EN 15/3,
    AM23_M           77:1 - 77:EN 15/3,
    AM24_M           78:1 - 78:EN 15/3,
    AM25_M           79:1 - 79:EN 15/3,
    AM26_M           80:1 - 80:EN 15/3,
    AM27_M           81:1 - 81:EN 15/3,
    AM28_M           82:1 - 82:EN 15/3,
    AM29_M           83:1 - 83:EN 15/3,
    AM30_M           84:1 - 84:EN 15/3,
    AM31_M           85:1 - 85:EN 15/3,
    AM32_M           86:1 - 86:EN 15/3,
    AM33_M           87:1 - 87:EN 15/3,
    AM34_M           88:1 - 88:EN 15/3,
    AM35_M           89:1 - 89:EN 15/3,
    AM36_M           90:1 - 90:EN 15/3,
    AM37_M           91:1 - 91:EN 15/3,
    AM38_M           92:1 - 92:EN 15/3,
    AM39_M           93:1 - 93:EN 15/3,
    AM40_M           94:1 - 94:EN 15/3,
    AM41_M           95:1 - 95:EN 15/3,
    AM42_M           96:1 - 96:EN 15/3,
    AM43_M           97:1 - 97:EN 15/3,
    AM44_M           98:1 - 98:EN 15/3,
    AM45_M           99:1 - 99:EN 15/3,
    AM46_M          100:1 - 100:EN 15/3,
    AM47_M          101:1 - 101:EN 15/3,
    AM48_M          102:1 - 102:EN 15/3,
    AM49_M          103:1 - 103:EN 15/3,
    AM50_M          104:1 - 104:EN 15/3,
    AM51_M          105:1 - 105:EN 15/3,
    AM52_M          106:1 - 106:EN 15/3,
    AM53_M          107:1 - 107:EN 15/3,
    AM54_M          108:1 - 108:EN 15/3,
    AM55_M          109:1 - 109:EN 15/3,
    AM56_M          110:1 - 110:EN 15/3,
    AM57_M          111:1 - 111:EN 15/3,
    AM58_M          112:1 - 112:EN 15/3,
    AM59_M          113:1 - 113:EN 15/3,
    AM60_M          114:1 - 114:EN 15/3,
    AM61_M          115:1 - 115:EN 15/3,
    AM62_M          116:1 - 116:EN 15/3,
    AM63_M          117:1 - 117:EN 15/3,
    AM64_M          118:1 - 118:EN 15/3,
    AM65_M          119:1 - 119:EN 15/3,
    COEF_LOB        120:1 - 120:,
    DSCCUR_CF       121:1 - 121:,
    COMMENT         122:1 - 122:,
    FILLER44_54		 44:1 - 54:,
	FILLER120_122  120:1 - 122:,
    TOTAUX_M        123:1 - 123:EN 15/3,
	ACMTRS3_NT      124:1 - 124:
/KEYS
	SSD_CF,
	RETCTR_NF,
	RETSEC_NF,
	RTY_NF,
	RETUW_NT,
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT,
	ESB_CF,
	PLC_NT,
	ACMTRS_NT,
	ACMCUR_CF,
	TYP_CT,
	NORME_CF,
	PATCAT_CT,
	PATTYP_CT,
	ACMTRS3_NT
	
/STABLE	
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M, TOTAL ACMAMT_M,
		   TOTAL AM01_M, TOTAL AM02_M, TOTAL AM03_M, TOTAL AM04_M, TOTAL AM05_M, TOTAL AM06_M, TOTAL AM07_M, TOTAL AM08_M, TOTAL AM09_M, TOTAL AM10_M,
           TOTAL AM11_M, TOTAL AM12_M, TOTAL AM13_M, TOTAL AM14_M, TOTAL AM15_M, TOTAL AM16_M, TOTAL AM17_M, TOTAL AM18_M, TOTAL AM19_M, TOTAL AM20_M,
           TOTAL AM21_M, TOTAL AM22_M, TOTAL AM23_M, TOTAL AM24_M, TOTAL AM25_M, TOTAL AM26_M, TOTAL AM27_M, TOTAL AM28_M, TOTAL AM29_M, TOTAL AM30_M,
           TOTAL AM31_M, TOTAL AM32_M, TOTAL AM33_M, TOTAL AM34_M, TOTAL AM35_M, TOTAL AM36_M, TOTAL AM37_M, TOTAL AM38_M, TOTAL AM39_M, TOTAL AM40_M,
           TOTAL AM41_M, TOTAL AM42_M, TOTAL AM43_M, TOTAL AM44_M, TOTAL AM45_M, TOTAL AM46_M, TOTAL AM47_M, TOTAL AM48_M, TOTAL AM49_M, TOTAL AM50_M,
           TOTAL AM51_M, TOTAL AM52_M, TOTAL AM53_M, TOTAL AM54_M, TOTAL AM55_M, TOTAL AM56_M, TOTAL AM57_M, TOTAL AM58_M, TOTAL AM59_M, TOTAL AM60_M,
           TOTAL AM61_M, TOTAL AM62_M, TOTAL AM63_M, TOTAL AM64_M, TOTAL AM65_M, 
		   TOTAL TOTAUX_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD ACMAMT_MC ACMAMT_M COMPRESS
/DERIVEDFIELD AM01_MC AM01_M COMPRESS
/DERIVEDFIELD AM02_MC AM02_M COMPRESS
/DERIVEDFIELD AM03_MC AM03_M COMPRESS
/DERIVEDFIELD AM04_MC AM04_M COMPRESS
/DERIVEDFIELD AM05_MC AM05_M COMPRESS
/DERIVEDFIELD AM06_MC AM06_M COMPRESS
/DERIVEDFIELD AM07_MC AM07_M COMPRESS
/DERIVEDFIELD AM08_MC AM08_M COMPRESS
/DERIVEDFIELD AM09_MC AM09_M COMPRESS
/DERIVEDFIELD AM10_MC AM10_M COMPRESS
/DERIVEDFIELD AM11_MC AM11_M COMPRESS
/DERIVEDFIELD AM12_MC AM12_M COMPRESS
/DERIVEDFIELD AM13_MC AM13_M COMPRESS
/DERIVEDFIELD AM14_MC AM14_M COMPRESS
/DERIVEDFIELD AM15_MC AM15_M COMPRESS
/DERIVEDFIELD AM16_MC AM16_M COMPRESS
/DERIVEDFIELD AM17_MC AM17_M COMPRESS
/DERIVEDFIELD AM18_MC AM18_M COMPRESS
/DERIVEDFIELD AM19_MC AM19_M COMPRESS
/DERIVEDFIELD AM20_MC AM20_M COMPRESS
/DERIVEDFIELD AM21_MC AM21_M COMPRESS
/DERIVEDFIELD AM22_MC AM22_M COMPRESS
/DERIVEDFIELD AM23_MC AM23_M COMPRESS
/DERIVEDFIELD AM24_MC AM24_M COMPRESS
/DERIVEDFIELD AM25_MC AM25_M COMPRESS
/DERIVEDFIELD AM26_MC AM26_M COMPRESS
/DERIVEDFIELD AM27_MC AM27_M COMPRESS
/DERIVEDFIELD AM28_MC AM28_M COMPRESS
/DERIVEDFIELD AM29_MC AM29_M COMPRESS
/DERIVEDFIELD AM30_MC AM30_M COMPRESS
/DERIVEDFIELD AM31_MC AM31_M COMPRESS
/DERIVEDFIELD AM32_MC AM32_M COMPRESS
/DERIVEDFIELD AM33_MC AM33_M COMPRESS
/DERIVEDFIELD AM34_MC AM34_M COMPRESS
/DERIVEDFIELD AM35_MC AM35_M COMPRESS
/DERIVEDFIELD AM36_MC AM36_M COMPRESS
/DERIVEDFIELD AM37_MC AM37_M COMPRESS
/DERIVEDFIELD AM38_MC AM38_M COMPRESS
/DERIVEDFIELD AM39_MC AM39_M COMPRESS
/DERIVEDFIELD AM40_MC AM40_M COMPRESS
/DERIVEDFIELD AM41_MC AM41_M COMPRESS
/DERIVEDFIELD AM42_MC AM42_M COMPRESS
/DERIVEDFIELD AM43_MC AM43_M COMPRESS
/DERIVEDFIELD AM44_MC AM44_M COMPRESS
/DERIVEDFIELD AM45_MC AM45_M COMPRESS
/DERIVEDFIELD AM46_MC AM46_M COMPRESS
/DERIVEDFIELD AM47_MC AM47_M COMPRESS
/DERIVEDFIELD AM48_MC AM48_M COMPRESS
/DERIVEDFIELD AM49_MC AM49_M COMPRESS
/DERIVEDFIELD AM50_MC AM50_M COMPRESS
/DERIVEDFIELD AM51_MC AM51_M COMPRESS
/DERIVEDFIELD AM52_MC AM52_M COMPRESS
/DERIVEDFIELD AM53_MC AM53_M COMPRESS
/DERIVEDFIELD AM54_MC AM54_M COMPRESS
/DERIVEDFIELD AM55_MC AM55_M COMPRESS
/DERIVEDFIELD AM56_MC AM56_M COMPRESS
/DERIVEDFIELD AM57_MC AM57_M COMPRESS
/DERIVEDFIELD AM58_MC AM58_M COMPRESS
/DERIVEDFIELD AM59_MC AM59_M COMPRESS
/DERIVEDFIELD AM60_MC AM60_M COMPRESS
/DERIVEDFIELD AM61_MC AM61_M COMPRESS
/DERIVEDFIELD AM62_MC AM62_M COMPRESS
/DERIVEDFIELD AM63_MC AM63_M COMPRESS
/DERIVEDFIELD AM64_MC AM64_M COMPRESS
/DERIVEDFIELD AM65_MC AM65_M COMPRESS
/DERIVEDFIELD TOTAUX_MC TOTAUX_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT
	FILLER1,
	AMT_MC,
	FILLER2,
	RETAMT_MC,
	FILLER3,
	RETINTAMT_MC,
	FILLER4,
	ACMAMT_MC,
	FILLER44_54
	,AM01_MC
	,AM02_MC
	,AM03_MC
	,AM04_MC
	,AM05_MC
	,AM06_MC
	,AM07_MC
	,AM08_MC
	,AM09_MC
	,AM10_MC
	,AM11_MC
	,AM12_MC
	,AM13_MC
	,AM14_MC
	,AM15_MC
	,AM16_MC
	,AM17_MC
	,AM18_MC
	,AM19_MC
	,AM20_MC
	,AM21_MC
	,AM22_MC
	,AM23_MC
	,AM24_MC
	,AM25_MC
	,AM26_MC
	,AM27_MC
	,AM28_MC
	,AM29_MC
	,AM30_MC
	,AM31_MC
	,AM32_MC
	,AM33_MC
	,AM34_MC
	,AM35_MC
	,AM36_MC
	,AM37_MC
	,AM38_MC
	,AM39_MC
	,AM40_MC
	,AM41_MC
	,AM42_MC
	,AM43_MC
	,AM44_MC
	,AM45_MC
	,AM46_MC
	,AM47_MC
	,AM48_MC
	,AM49_MC
	,AM50_MC
	,AM51_MC
	,AM52_MC
	,AM53_MC
	,AM54_MC
	,AM55_MC
	,AM56_MC
	,AM57_MC
	,AM58_MC
	,AM59_MC
	,AM60_MC
	,AM61_MC
	,AM62_MC
	,AM63_MC
	,AM64_MC
	,AM65_MC
	,FILLER120_122
	,TOTAUX_MC
	,ACMTRS3_NT

exit
EOF
SORT

NSTEP=${NJOB}_07
#--------------------------------------------------------------------------------
# Merging the summarize files both assume and retro  
#--------------------------------------------------------------------------------
LIBEL="Merging the summarize files both assume and retro "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_CSM_CASHFLOW_ASSUME_SUMMARIZE.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_06_${IB}_CSM_CASHFLOW_RETRO_SUMMARIZE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_CASHFLOW_ASSUME_RETRO_SUMMARIZE_MERGE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF            1:1 -  1:EN,					
    ESB_CF            2:1 -  2:EN,
    BALSHEY_NF        3:1 -  3:,
    BALSHRMTH_NF      4:1 -  4:,
    BALSHRDAY_NF      5:1 -  5:,
    TRNCOD_CF         6:1 -  6:,
    DBLTRNCOD_CF      7:1 -  7:,
    CTR_NF            8:1 -  8:,
    END_NT            9:1 -  9:EN 15/3,
    SEC_NF           10:1 - 10:,
    UWY_NF           11:1 - 11:,
    UW_NT            12:1 - 12:,
    OCCYEA_NF        13:1 - 13:,
    ACY_NF           14:1 - 14:,
    SCOSTRMTH_NF     15:1 - 15:EN,
    SCOENDMTH_NF     16:1 - 16:EN,
    CLM_NF           17:1 - 17:,
    CUR_CF           18:1 - 18:,
    AMT_M            19:1 - 19:EN 15/3,
    CED_NF           20:1 - 20:,
    BRK_NF           21:1 - 21:,
    PAY_NF           22:1 - 22:,
    KEY_NF           23:1 - 23:,
    RETCTR_NF        24:1 - 24:,
    RETEND_NT        25:1 - 25:,
    RETSEC_NF        26:1 - 26:,
    RTY_NF           27:1 - 27:,
    RETUW_NT         28:1 - 28:,
    RETOCCYEA_NF     29:1 - 29:,
    RETACY_NF        30:1 - 30:,
    RETSCOSTRMTH_NF  31:1 - 31:EN,
    RETSCOENDMTH_NF  32:1 - 32:EN,
    RCL_NF           33:1 - 33:,
    RETCUR_CF        34:1 - 34:,
    RETAMT_M         35:1 - 35:EN 15/3,
    PLC_NT           36:1 - 36:,
    RTO_NF           37:1 - 37:,
    INT_NF           38:1 - 38:,
    RETPAY_NF        39:1 - 39:,
    RETKEY_CF        40:1 - 40:,
    RETINTAMT_M      41:1 - 41:EN 15/3,
    ACMTRS_NT        42:1 - 42:,
    ACMAMT_M         43:1 - 43:EN 15/3,
    ACMCUR_CF        44:1 - 44:,
    PRS_CF           45:1 - 45:,
    SEG_NF           46:1 - 46:,
    LOB_CF           47:1 - 47:,
    NAT_CF           48:1 - 48:,
    TYP_CT           49:1 - 49:,
    NORME_CF         50:1 - 50:,
    RATING_CF        51:1 - 51:,
    PATCAT_CT        52:1 - 52:,
    PATTYP_CT        53:1 - 53:,
    PATTERN_ID       54:1 - 54:,
    AM01_M           55:1 - 55:EN 15/3,
    AM02_M           56:1 - 56:EN 15/3,
    AM03_M           57:1 - 57:EN 15/3,
    AM04_M           58:1 - 58:EN 15/3,
    AM05_M           59:1 - 59:EN 15/3,
    AM06_M           60:1 - 60:EN 15/3,
    AM07_M           61:1 - 61:EN 15/3,
    AM08_M           62:1 - 62:EN 15/3,
    AM09_M           63:1 - 63:EN 15/3,
    AM10_M           64:1 - 64:EN 15/3,
    AM11_M           65:1 - 65:EN 15/3,
    AM12_M           66:1 - 66:EN 15/3,
    AM13_M           67:1 - 67:EN 15/3,
    AM14_M           68:1 - 68:EN 15/3,
    AM15_M           69:1 - 69:EN 15/3,
    AM16_M           70:1 - 70:EN 15/3,
    AM17_M           71:1 - 71:EN 15/3,
    AM18_M           72:1 - 72:EN 15/3,
    AM19_M           73:1 - 73:EN 15/3,
    AM20_M           74:1 - 74:EN 15/3,
    AM21_M           75:1 - 75:EN 15/3,
    AM22_M           76:1 - 76:EN 15/3,
    AM23_M           77:1 - 77:EN 15/3,
    AM24_M           78:1 - 78:EN 15/3,
    AM25_M           79:1 - 79:EN 15/3,
    AM26_M           80:1 - 80:EN 15/3,
    AM27_M           81:1 - 81:EN 15/3,
    AM28_M           82:1 - 82:EN 15/3,
    AM29_M           83:1 - 83:EN 15/3,
    AM30_M           84:1 - 84:EN 15/3,
    AM31_M           85:1 - 85:EN 15/3,
    AM32_M           86:1 - 86:EN 15/3,
    AM33_M           87:1 - 87:EN 15/3,
    AM34_M           88:1 - 88:EN 15/3,
    AM35_M           89:1 - 89:EN 15/3,
    AM36_M           90:1 - 90:EN 15/3,
    AM37_M           91:1 - 91:EN 15/3,
    AM38_M           92:1 - 92:EN 15/3,
    AM39_M           93:1 - 93:EN 15/3,
    AM40_M           94:1 - 94:EN 15/3,
    AM41_M           95:1 - 95:EN 15/3,
    AM42_M           96:1 - 96:EN 15/3,
    AM43_M           97:1 - 97:EN 15/3,
    AM44_M           98:1 - 98:EN 15/3,
    AM45_M           99:1 - 99:EN 15/3,
    AM46_M          100:1 - 100:EN 15/3,
    AM47_M          101:1 - 101:EN 15/3,
    AM48_M          102:1 - 102:EN 15/3,
    AM49_M          103:1 - 103:EN 15/3,
    AM50_M          104:1 - 104:EN 15/3,
    AM51_M          105:1 - 105:EN 15/3,
    AM52_M          106:1 - 106:EN 15/3,
    AM53_M          107:1 - 107:EN 15/3,
    AM54_M          108:1 - 108:EN 15/3,
    AM55_M          109:1 - 109:EN 15/3,
    AM56_M          110:1 - 110:EN 15/3,
    AM57_M          111:1 - 111:EN 15/3,
    AM58_M          112:1 - 112:EN 15/3,
    AM59_M          113:1 - 113:EN 15/3,
    AM60_M          114:1 - 114:EN 15/3,
    AM61_M          115:1 - 115:EN 15/3,
    AM62_M          116:1 - 116:EN 15/3,
    AM63_M          117:1 - 117:EN 15/3,
    AM64_M          118:1 - 118:EN 15/3,
    AM65_M          119:1 - 119:EN 15/3,
    COEF_LOB        120:1 - 120:,
    DSCCUR_CF       121:1 - 121:,
    COMMENT         122:1 - 122:,
    TOTAUX_M        123:1 - 123:EN 15/3,
	ACMTRS3_NT      124:1 - 124:

/KEYS
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT

/OUTFILE ${SORT_O}

exit
EOF
SORT

NSTEP=${NJOB}_08
#-----------------------------------------------------------------------------
# Sort pericase file based on CSUOE DESC 
#-----------------------------------------------------------------------------
LIBEL="Sort retro file based on CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_1_${IB}_PERICASE_MERGE.dat 2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORTED_PERICASE_MERGE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF						3:1 - 3:,
	END_NT						4:1 - 4:EN 15/3,
	SEC_NF						5:1 - 5:,
	UWY_NF						6:1 - 6:,
	UW_NT						7:1 - 7:
	
/KEYS
		CTR_NF ,
        UWY_NF ,
        UW_NT ,
		SEC_NF ,
		END_NT DESC
		
/OUTFILE ${SORT_O}

exit
EOF
SORT

NSTEP=${NJOB}_09
#-----------------------------------------------------------------------------
# Summarise the pericase file to one record with highest END_NT
#-----------------------------------------------------------------------------
LIBEL="Summarise the pericase file based on CSUO"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_08_${IB}_SORTED_PERICASE_MERGE.dat 2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORTED_PERICASE_MERGE_SUMMARISED.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF						1:1 - 1:EN,
	CTR_NF						3:1 - 3:,
	END_NT						4:1 - 4:,
	SEC_NF						5:1 - 5:,
	UWY_NF						6:1 - 6:,
	UW_NT						7:1 - 7:,
	ACCESB_CF					8:1 - 8:EN,
	EGPCUR_CF					21:1 - 21:EN 15/3


/KEYS
		CTR_NF ,
		SEC_NF ,
        UWY_NF ,
		UW_NT
		
/STABLE	
/SUMMARIZE TOTAL EGPCUR_CF
/OUTFILE ${SORT_O}

exit
EOF
SORT

NSTEP=${NJOB}_10
#--------------------------------------------------------------------------------
# Taking END_NT from summarized pericase file for paired contracts 
#--------------------------------------------------------------------------------
LIBEL="Taking END_NT from summarized pericase file for paired contracts"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_07_${IB}_CSM_CASHFLOW_ASSUME_RETRO_SUMMARIZE_MERGE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_CASHFLOW_PAIRED.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF            1:1 -  1:,					
    ESB_CF            2:1 -  2:,
    BALSHEY_NF        3:1 -  3:,
    BALSHRMTH_NF      4:1 -  4:,
    BALSHRDAY_NF      5:1 -  5:,
    TRNCOD_CF         6:1 -  6:,
    DBLTRNCOD_CF      7:1 -  7:,
    CTR_NF            8:1 -  8:,
	FILLER1			  1:1 -  8:,
    END_NT            9:1 -  9:,
    SEC_NF           10:1 - 10:,
    UWY_NF           11:1 - 11:,
    UW_NT            12:1 - 12:,
    OCCYEA_NF        13:1 - 13:,
    ACY_NF           14:1 - 14:,
    SCOSTRMTH_NF     15:1 - 15:EN,
    SCOENDMTH_NF     16:1 - 16:EN,
    CLM_NF           17:1 - 17:,
    CUR_CF           18:1 - 18:,
    AMT_M            19:1 - 19:EN 15/3,
    CED_NF           20:1 - 20:,
    BRK_NF           21:1 - 21:,
    PAY_NF           22:1 - 22:,
    KEY_NF           23:1 - 23:,
    RETCTR_NF        24:1 - 24:,
    RETEND_NT        25:1 - 25:,
    RETSEC_NF        26:1 - 26:,
    RTY_NF           27:1 - 27:,
    RETUW_NT         28:1 - 28:,
    RETOCCYEA_NF     29:1 - 29:,
    RETACY_NF        30:1 - 30:,
    RETSCOSTRMTH_NF  31:1 - 31:EN,
    RETSCOENDMTH_NF  32:1 - 32:EN,
    RCL_NF           33:1 - 33:,
    RETCUR_CF        34:1 - 34:,
    RETAMT_M         35:1 - 35:EN 15/3,
    PLC_NT           36:1 - 36:,
    RTO_NF           37:1 - 37:,
    INT_NF           38:1 - 38:,
    RETPAY_NF        39:1 - 39:,
    RETKEY_CF        40:1 - 40:,
    RETINTAMT_M      41:1 - 41:EN 15/3,
    ACMTRS_NT        42:1 - 42:,
    ACMAMT_M         43:1 - 43:EN 15/3,
    ACMCUR_CF        44:1 - 44:,
    PRS_CF           45:1 - 45:,
    SEG_NF           46:1 - 46:,
    LOB_CF           47:1 - 47:,
    NAT_CF           48:1 - 48:,
    TYP_CT           49:1 - 49:,
    NORME_CF         50:1 - 50:,
    RATING_CF        51:1 - 51:,
    PATCAT_CT        52:1 - 52:,
    PATTYP_CT        53:1 - 53:,
    PATTERN_ID       54:1 - 54:,
    AM01_M           55:1 - 55:EN 15/3,
    AM02_M           56:1 - 56:EN 15/3,
    AM03_M           57:1 - 57:EN 15/3,
    AM04_M           58:1 - 58:EN 15/3,
    AM05_M           59:1 - 59:EN 15/3,
    AM06_M           60:1 - 60:EN 15/3,
    AM07_M           61:1 - 61:EN 15/3,
    AM08_M           62:1 - 62:EN 15/3,
    AM09_M           63:1 - 63:EN 15/3,
    AM10_M           64:1 - 64:EN 15/3,
    AM11_M           65:1 - 65:EN 15/3,
    AM12_M           66:1 - 66:EN 15/3,
    AM13_M           67:1 - 67:EN 15/3,
    AM14_M           68:1 - 68:EN 15/3,
    AM15_M           69:1 - 69:EN 15/3,
    AM16_M           70:1 - 70:EN 15/3,
    AM17_M           71:1 - 71:EN 15/3,
    AM18_M           72:1 - 72:EN 15/3,
    AM19_M           73:1 - 73:EN 15/3,
    AM20_M           74:1 - 74:EN 15/3,
    AM21_M           75:1 - 75:EN 15/3,
    AM22_M           76:1 - 76:EN 15/3,
    AM23_M           77:1 - 77:EN 15/3,
    AM24_M           78:1 - 78:EN 15/3,
    AM25_M           79:1 - 79:EN 15/3,
    AM26_M           80:1 - 80:EN 15/3,
    AM27_M           81:1 - 81:EN 15/3,
    AM28_M           82:1 - 82:EN 15/3,
    AM29_M           83:1 - 83:EN 15/3,
    AM30_M           84:1 - 84:EN 15/3,
    AM31_M           85:1 - 85:EN 15/3,
    AM32_M           86:1 - 86:EN 15/3,
    AM33_M           87:1 - 87:EN 15/3,
    AM34_M           88:1 - 88:EN 15/3,
    AM35_M           89:1 - 89:EN 15/3,
    AM36_M           90:1 - 90:EN 15/3,
    AM37_M           91:1 - 91:EN 15/3,
    AM38_M           92:1 - 92:EN 15/3,
    AM39_M           93:1 - 93:EN 15/3,
    AM40_M           94:1 - 94:EN 15/3,
    AM41_M           95:1 - 95:EN 15/3,
    AM42_M           96:1 - 96:EN 15/3,
    AM43_M           97:1 - 97:EN 15/3,
    AM44_M           98:1 - 98:EN 15/3,
    AM45_M           99:1 - 99:EN 15/3,
    AM46_M          100:1 - 100:EN 15/3,
    AM47_M          101:1 - 101:EN 15/3,
    AM48_M          102:1 - 102:EN 15/3,
    AM49_M          103:1 - 103:EN 15/3,
    AM50_M          104:1 - 104:EN 15/3,
    AM51_M          105:1 - 105:EN 15/3,
    AM52_M          106:1 - 106:EN 15/3,
    AM53_M          107:1 - 107:EN 15/3,
    AM54_M          108:1 - 108:EN 15/3,
    AM55_M          109:1 - 109:EN 15/3,
    AM56_M          110:1 - 110:EN 15/3,
    AM57_M          111:1 - 111:EN 15/3,
    AM58_M          112:1 - 112:EN 15/3,
    AM59_M          113:1 - 113:EN 15/3,
    AM60_M          114:1 - 114:EN 15/3,
    AM61_M          115:1 - 115:EN 15/3,
    AM62_M          116:1 - 116:EN 15/3,
    AM63_M          117:1 - 117:EN 15/3,
    AM64_M          118:1 - 118:EN 15/3,
    AM65_M          119:1 - 119:EN 15/3,
    COEF_LOB        120:1 - 120:,
    DSCCUR_CF       121:1 - 121:,
    COMMENT         122:1 - 122:,
    TOTAUX_M        123:1 - 123:EN 15/3,
	ACMTRS3_NT      124:1 - 124:,
	FILLER2			 10:1 - 124:,
	SSD_CF_P		  1:1 - 1:,
	CTR_NF_P		  3:1 - 3:,
	UWY_NF_P		  6:1 - 6:,
	UW_NT_P			  7:1 - 7:,
	END_NT_P		  4:1 - 4:,
	SEC_NF_P		  5:1 - 5:,
	ACCESB_CF_P		  8:1 - 8:

/joinkeys
        CTR_NF,
		SEC_NF,
        UWY_NF,
		UW_NT	
		
/INFILE ${DFILT}/${NJOB}_09_${IB}_SORTED_PERICASE_MERGE_SUMMARISED.dat 2000 1 "~"
/joinkeys
        CTR_NF_P,
		SEC_NF_P,
        UWY_NF_P,
		UW_NT_P

/OUTFILE ${SORT_O}
/REFORMAT
	leftside:FILLER1,rightside:END_NT_P,leftside:FILLER2

exit
EOF
SORT

NSTEP=${NJOB}_11
#--------------------------------------------------------------------------------
# Taking upaired cashflow records as it is 
#--------------------------------------------------------------------------------
LIBEL="Taking upaired cashflow records as it is "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_07_${IB}_CSM_CASHFLOW_ASSUME_RETRO_SUMMARIZE_MERGE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_CASHFLOW_UNPAIRED.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF            1:1 -  1:,					
    ESB_CF            2:1 -  2:,
    BALSHEY_NF        3:1 -  3:,
    BALSHRMTH_NF      4:1 -  4:,
    BALSHRDAY_NF      5:1 -  5:,
    TRNCOD_CF         6:1 -  6:,
    DBLTRNCOD_CF      7:1 -  7:,
    CTR_NF            8:1 -  8:,
	FILLER1			  1:1 -  8:,
    END_NT            9:1 -  9:,
    SEC_NF           10:1 - 10:,
    UWY_NF           11:1 - 11:,
    UW_NT            12:1 - 12:,
    OCCYEA_NF        13:1 - 13:,
    ACY_NF           14:1 - 14:,
    SCOSTRMTH_NF     15:1 - 15:EN,
    SCOENDMTH_NF     16:1 - 16:EN,
    CLM_NF           17:1 - 17:,
    CUR_CF           18:1 - 18:,
    AMT_M            19:1 - 19:EN 15/3,
    CED_NF           20:1 - 20:,
    BRK_NF           21:1 - 21:,
    PAY_NF           22:1 - 22:,
    KEY_NF           23:1 - 23:,
    RETCTR_NF        24:1 - 24:,
    RETEND_NT        25:1 - 25:,
    RETSEC_NF        26:1 - 26:,
    RTY_NF           27:1 - 27:,
    RETUW_NT         28:1 - 28:,
    RETOCCYEA_NF     29:1 - 29:,
    RETACY_NF        30:1 - 30:,
    RETSCOSTRMTH_NF  31:1 - 31:EN,
    RETSCOENDMTH_NF  32:1 - 32:EN,
    RCL_NF           33:1 - 33:,
    RETCUR_CF        34:1 - 34:,
    RETAMT_M         35:1 - 35:EN 15/3,
    PLC_NT           36:1 - 36:,
    RTO_NF           37:1 - 37:,
    INT_NF           38:1 - 38:,
    RETPAY_NF        39:1 - 39:,
    RETKEY_CF        40:1 - 40:,
    RETINTAMT_M      41:1 - 41:EN 15/3,
    ACMTRS_NT        42:1 - 42:,
    ACMAMT_M         43:1 - 43:EN 15/3,
    ACMCUR_CF        44:1 - 44:,
    PRS_CF           45:1 - 45:,
    SEG_NF           46:1 - 46:,
    LOB_CF           47:1 - 47:,
    NAT_CF           48:1 - 48:,
    TYP_CT           49:1 - 49:,
    NORME_CF         50:1 - 50:,
    RATING_CF        51:1 - 51:,
    PATCAT_CT        52:1 - 52:,
    PATTYP_CT        53:1 - 53:,
    PATTERN_ID       54:1 - 54:,
    AM01_M           55:1 - 55:EN 15/3,
    AM02_M           56:1 - 56:EN 15/3,
    AM03_M           57:1 - 57:EN 15/3,
    AM04_M           58:1 - 58:EN 15/3,
    AM05_M           59:1 - 59:EN 15/3,
    AM06_M           60:1 - 60:EN 15/3,
    AM07_M           61:1 - 61:EN 15/3,
    AM08_M           62:1 - 62:EN 15/3,
    AM09_M           63:1 - 63:EN 15/3,
    AM10_M           64:1 - 64:EN 15/3,
    AM11_M           65:1 - 65:EN 15/3,
    AM12_M           66:1 - 66:EN 15/3,
    AM13_M           67:1 - 67:EN 15/3,
    AM14_M           68:1 - 68:EN 15/3,
    AM15_M           69:1 - 69:EN 15/3,
    AM16_M           70:1 - 70:EN 15/3,
    AM17_M           71:1 - 71:EN 15/3,
    AM18_M           72:1 - 72:EN 15/3,
    AM19_M           73:1 - 73:EN 15/3,
    AM20_M           74:1 - 74:EN 15/3,
    AM21_M           75:1 - 75:EN 15/3,
    AM22_M           76:1 - 76:EN 15/3,
    AM23_M           77:1 - 77:EN 15/3,
    AM24_M           78:1 - 78:EN 15/3,
    AM25_M           79:1 - 79:EN 15/3,
    AM26_M           80:1 - 80:EN 15/3,
    AM27_M           81:1 - 81:EN 15/3,
    AM28_M           82:1 - 82:EN 15/3,
    AM29_M           83:1 - 83:EN 15/3,
    AM30_M           84:1 - 84:EN 15/3,
    AM31_M           85:1 - 85:EN 15/3,
    AM32_M           86:1 - 86:EN 15/3,
    AM33_M           87:1 - 87:EN 15/3,
    AM34_M           88:1 - 88:EN 15/3,
    AM35_M           89:1 - 89:EN 15/3,
    AM36_M           90:1 - 90:EN 15/3,
    AM37_M           91:1 - 91:EN 15/3,
    AM38_M           92:1 - 92:EN 15/3,
    AM39_M           93:1 - 93:EN 15/3,
    AM40_M           94:1 - 94:EN 15/3,
    AM41_M           95:1 - 95:EN 15/3,
    AM42_M           96:1 - 96:EN 15/3,
    AM43_M           97:1 - 97:EN 15/3,
    AM44_M           98:1 - 98:EN 15/3,
    AM45_M           99:1 - 99:EN 15/3,
    AM46_M          100:1 - 100:EN 15/3,
    AM47_M          101:1 - 101:EN 15/3,
    AM48_M          102:1 - 102:EN 15/3,
    AM49_M          103:1 - 103:EN 15/3,
    AM50_M          104:1 - 104:EN 15/3,
    AM51_M          105:1 - 105:EN 15/3,
    AM52_M          106:1 - 106:EN 15/3,
    AM53_M          107:1 - 107:EN 15/3,
    AM54_M          108:1 - 108:EN 15/3,
    AM55_M          109:1 - 109:EN 15/3,
    AM56_M          110:1 - 110:EN 15/3,
    AM57_M          111:1 - 111:EN 15/3,
    AM58_M          112:1 - 112:EN 15/3,
    AM59_M          113:1 - 113:EN 15/3,
    AM60_M          114:1 - 114:EN 15/3,
    AM61_M          115:1 - 115:EN 15/3,
    AM62_M          116:1 - 116:EN 15/3,
    AM63_M          117:1 - 117:EN 15/3,
    AM64_M          118:1 - 118:EN 15/3,
    AM65_M          119:1 - 119:EN 15/3,
    COEF_LOB        120:1 - 120:,
    DSCCUR_CF       121:1 - 121:,
    COMMENT         122:1 - 122:,
    TOTAUX_M        123:1 - 123:EN 15/3,
	ACMTRS3_NT      124:1 - 124:,
	FILLER2			 10:1 - 124:,
	ALL_FIELDS		  1:1 - 124:,
	SSD_CF_P		  1:1 - 1:,
	CTR_NF_P		  3:1 - 3:,
	UWY_NF_P		  6:1 - 6:,
	UW_NT_P			  7:1 - 7:,
	END_NT_P		  4:1 - 4:,
	SEC_NF_P		  5:1 - 5:,
	ACCESB_CF_P		  8:1 - 8:

/joinkeys
        CTR_NF,
		SEC_NF,
        UWY_NF,
		UW_NT
		
		
/INFILE ${DFILT}/${NJOB}_09_${IB}_SORTED_PERICASE_MERGE_SUMMARISED.dat 2000 1 "~"
/joinkeys
        CTR_NF_P,
		SEC_NF_P,
        UWY_NF_P,
		UW_NT_P
		
       
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O}
/REFORMAT
	leftside:ALL_FIELDS

exit
EOF
SORT

NSTEP=${NJOB}_12
#--------------------------------------------------------------------------------
# Merge unpaired and  paired cashflow file
#--------------------------------------------------------------------------------
LIBEL="Merge unpaired and  paired cashflow file to generate ESF_GTSII_CSM_CASHFLOW"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_CSM_CASHFLOW_PAIRED.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_11_${IB}_CSM_CASHFLOW_UNPAIRED.dat 2000 1"
SORT_O="${ESF_GTSII_CSM_TMP_CASHFLOW} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF            1:1 -  1:EN,					
    ESB_CF            2:1 -  2:EN,
    BALSHEY_NF        3:1 -  3:,
    BALSHRMTH_NF      4:1 -  4:,
    BALSHRDAY_NF      5:1 -  5:,
    TRNCOD_CF         6:1 -  6:,
    DBLTRNCOD_CF      7:1 -  7:,
    CTR_NF            8:1 -  8:,
    END_NT            9:1 -  9:EN 15/3,
    SEC_NF           10:1 - 10:,
    UWY_NF           11:1 - 11:,
    UW_NT            12:1 - 12:,
    OCCYEA_NF        13:1 - 13:,
    ACY_NF           14:1 - 14:,
    SCOSTRMTH_NF     15:1 - 15:EN,
    SCOENDMTH_NF     16:1 - 16:EN,
    CLM_NF           17:1 - 17:,
    CUR_CF           18:1 - 18:,
    AMT_M            19:1 - 19:EN 15/3,
    CED_NF           20:1 - 20:,
    BRK_NF           21:1 - 21:,
    PAY_NF           22:1 - 22:,
    KEY_NF           23:1 - 23:,
    RETCTR_NF        24:1 - 24:,
    RETEND_NT        25:1 - 25:,
    RETSEC_NF        26:1 - 26:,
    RTY_NF           27:1 - 27:,
    RETUW_NT         28:1 - 28:,
    RETOCCYEA_NF     29:1 - 29:,
    RETACY_NF        30:1 - 30:,
    RETSCOSTRMTH_NF  31:1 - 31:EN,
    RETSCOENDMTH_NF  32:1 - 32:EN,
    RCL_NF           33:1 - 33:,
    RETCUR_CF        34:1 - 34:,
    RETAMT_M         35:1 - 35:EN 15/3,
    PLC_NT           36:1 - 36:,
    RTO_NF           37:1 - 37:,
    INT_NF           38:1 - 38:,
    RETPAY_NF        39:1 - 39:,
    RETKEY_CF        40:1 - 40:,
    RETINTAMT_M      41:1 - 41:EN 15/3,
    ACMTRS_NT        42:1 - 42:,
    ACMAMT_M         43:1 - 43:EN 15/3,
    ACMCUR_CF        44:1 - 44:,
    PRS_CF           45:1 - 45:,
    SEG_NF           46:1 - 46:,
    LOB_CF           47:1 - 47:,
    NAT_CF           48:1 - 48:,
    TYP_CT           49:1 - 49:,
    NORME_CF         50:1 - 50:,
    RATING_CF        51:1 - 51:,
    PATCAT_CT        52:1 - 52:,
    PATTYP_CT        53:1 - 53:,
    PATTERN_ID       54:1 - 54:,
    AM01_M           55:1 - 55:EN 15/3,
    AM02_M           56:1 - 56:EN 15/3,
    AM03_M           57:1 - 57:EN 15/3,
    AM04_M           58:1 - 58:EN 15/3,
    AM05_M           59:1 - 59:EN 15/3,
    AM06_M           60:1 - 60:EN 15/3,
    AM07_M           61:1 - 61:EN 15/3,
    AM08_M           62:1 - 62:EN 15/3,
    AM09_M           63:1 - 63:EN 15/3,
    AM10_M           64:1 - 64:EN 15/3,
    AM11_M           65:1 - 65:EN 15/3,
    AM12_M           66:1 - 66:EN 15/3,
    AM13_M           67:1 - 67:EN 15/3,
    AM14_M           68:1 - 68:EN 15/3,
    AM15_M           69:1 - 69:EN 15/3,
    AM16_M           70:1 - 70:EN 15/3,
    AM17_M           71:1 - 71:EN 15/3,
    AM18_M           72:1 - 72:EN 15/3,
    AM19_M           73:1 - 73:EN 15/3,
    AM20_M           74:1 - 74:EN 15/3,
    AM21_M           75:1 - 75:EN 15/3,
    AM22_M           76:1 - 76:EN 15/3,
    AM23_M           77:1 - 77:EN 15/3,
    AM24_M           78:1 - 78:EN 15/3,
    AM25_M           79:1 - 79:EN 15/3,
    AM26_M           80:1 - 80:EN 15/3,
    AM27_M           81:1 - 81:EN 15/3,
    AM28_M           82:1 - 82:EN 15/3,
    AM29_M           83:1 - 83:EN 15/3,
    AM30_M           84:1 - 84:EN 15/3,
    AM31_M           85:1 - 85:EN 15/3,
    AM32_M           86:1 - 86:EN 15/3,
    AM33_M           87:1 - 87:EN 15/3,
    AM34_M           88:1 - 88:EN 15/3,
    AM35_M           89:1 - 89:EN 15/3,
    AM36_M           90:1 - 90:EN 15/3,
    AM37_M           91:1 - 91:EN 15/3,
    AM38_M           92:1 - 92:EN 15/3,
    AM39_M           93:1 - 93:EN 15/3,
    AM40_M           94:1 - 94:EN 15/3,
    AM41_M           95:1 - 95:EN 15/3,
    AM42_M           96:1 - 96:EN 15/3,
    AM43_M           97:1 - 97:EN 15/3,
    AM44_M           98:1 - 98:EN 15/3,
    AM45_M           99:1 - 99:EN 15/3,
    AM46_M          100:1 - 100:EN 15/3,
    AM47_M          101:1 - 101:EN 15/3,
    AM48_M          102:1 - 102:EN 15/3,
    AM49_M          103:1 - 103:EN 15/3,
    AM50_M          104:1 - 104:EN 15/3,
    AM51_M          105:1 - 105:EN 15/3,
    AM52_M          106:1 - 106:EN 15/3,
    AM53_M          107:1 - 107:EN 15/3,
    AM54_M          108:1 - 108:EN 15/3,
    AM55_M          109:1 - 109:EN 15/3,
    AM56_M          110:1 - 110:EN 15/3,
    AM57_M          111:1 - 111:EN 15/3,
    AM58_M          112:1 - 112:EN 15/3,
    AM59_M          113:1 - 113:EN 15/3,
    AM60_M          114:1 - 114:EN 15/3,
    AM61_M          115:1 - 115:EN 15/3,
    AM62_M          116:1 - 116:EN 15/3,
    AM63_M          117:1 - 117:EN 15/3,
    AM64_M          118:1 - 118:EN 15/3,
    AM65_M          119:1 - 119:EN 15/3,
    COEF_LOB        120:1 - 120:,
    DSCCUR_CF       121:1 - 121:,
    COMMENT         122:1 - 122:,
    TOTAUX_M        123:1 - 123:EN 15/3,
	ACMTRS3_NT      124:1 - 124:

/KEYS
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT

/OUTFILE ${SORT_O}

exit
EOF
SORT


NSTEP=${NJOB}_13
#------------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*${IB}*.dat "

JOBEND
