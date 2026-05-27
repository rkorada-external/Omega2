#!/bin/ksh
#=================================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD3761.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 10\10\2019
# auteur                        : Cyril AVINENS
#---------------------------------------------------------------------------------
# description
#  IFRS17 REQ 12.7 : UoA signature at subsequent measurement
#
#---------------------------------------------------------------------------------
#=================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctjsb.cmd

# Job Initialisation
JOBINIT

ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ICLODAT_D........................................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> PREV_ICLODAT_D...................................................: ${PARM_PREV_ICLODAT_D}"
ECHO_LOG "#===> CLOTYP...........................................................: ${TYPEINV}"
ECHO_LOG "#===> NORME_CF.........................................................: ${NORME_CF}"
ECHO_LOG "#===> BATCHUSER........................................................: ${PARM_BATCHUSER}"

ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> EPO_FCURQUOT_TXT.................................................: ${EPO_FCURQUOT_TXT}"
ECHO_LOG "#===> EST_IADPERICASE_MERGE............................................: ${EST_IADPERICASE_MERGE}"
ECHO_LOG "#===> ESF_GTSII_CSM_TMP_CASHFLOW.......................................: ${ESF_GTSII_CSM_TMP_CASHFLOW}"
ECHO_LOG "#===> ESF_FSEGPROF_INI.................................................: ${ESF_FSEGPROF_INI}"
ECHO_LOG "#===> ESF_FSEGPROF_STD_PREVIOUS........................................: ${ESF_FSEGPROF_STD_PREVIOUS}"
ECHO_LOG "#===> ESF_CSM_PROF.....................................................: ${ESF_CSM_PROF}"
ECHO_LOG "#===> ESF_CSM_LC_AMORT_PATTERN.........................................: ${ESF_CSM_LC_AMORT_PATTERN}"

ECHO_LOG "#===> ............ OUTPUT ................................................."
ECHO_LOG "#===> ESF_FSEGPROF_STD.................................................: ${ESF_FSEGPROF_STD}"
ECHO_LOG "#===> ESF_CSM_PROF_CUR.................................................: ${ESF_CSM_PROF_CUR}"
ECHO_LOG "#===> ESF_GTSII_CSM_CASHFLOW...........................................: ${ESF_GTSII_CSM_CASHFLOW}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_1
#------------------------------------------------------------------------------

# inputs files
export ESTJ0004_CURRENCY="${EPO_FCURQUOT_TXT}"
export ESTJ0004_CONTRACT_PERICASE="${EST_IADPERICASE_MERGE}"
export ESTJ0004_CASHFLOW_AGGREGATION="${ESF_GTSII_CSM_TMP_CASHFLOW}"
export ESTJ0004_INITIAL_PROFITABILITY="${ESF_FSEGPROF_INI}"
export ESTJ0004_PREVIOUS_PROFITABILITY="${ESF_FSEGPROF_STD_PREVIOUS}"
export ESTJ0004_PROFITABILITY_BY_CONTRACT_PREV="${ESF_CSM_PROF}"
export ESTJ0004_AMORTIZATION_PATTERN_CSM_LC_CURRENT_Q="${ESF_CSM_LC_AMORT_PATTERN}"

# tmp files
export ESTJ0004_SORTED_CONTRACT_PERICASE="${DFILT}/${NJOB}_1_${IB}_SORTED_CONTRACT_PERICASE.dat"
export ESTJ0004_SORTED_CASHFLOW_AGGREGATION="${DFILT}/${NJOB}_1_${IB}_SORTED_CASHFLOW_AGGREGATION.dat"
export ESTJ0004_UOA_DATA_RECOVERY="${DFILT}/${NJOB}_1_${IB}_UOA_DATA_RECOVERY.dat"
export ESTJ0004_SORTED_UOA_DATA_RECOVERY="${DFILT}/${NJOB}_1_${IB}_SORTED_UOA_DATA_RECOVERY.dat"
export ESTJ0004_SORTED_INITIAL_PROFITABILITY="${DFILT}/${NJOB}_1_${IB}_SORTED_INITIAL_PROFITABILITY.dat"
export ESTJ0004_SORTED_PREVIOUS_PROFITABILITY="${DFILT}/${NJOB}_1_${IB}_SORTED_PREVIOUS_PROFITABILITY.dat"
export ESTJ0004_PERICASE_LIGHT="${DFILT}/${NJOB}_1_${IB}_PERICASE_LIGHT.dat"
export ESTJ0004_SORTED_PERICASE_LIGHT="${DFILT}/${NJOB}_1_${IB}_SORTED_PERICASE_LIGHT.dat"
export ESTJ0004_SORTED_SEGMENT_PROFITABILITY="${DFILT}/${NJOB}_1_${IB}_SORTED_SEGMENT_PROFITABILITY.dat"
export ESTJ0004_SORTED_PROFITABILITY_BY_CONTRACT_CUR="${DFILT}/${NJOB}_1_${IB}_SORTED_PROFITABILITY_BY_CONTRACT_CUR.dat"
export ESTJ0004_SORTED_PROFITABILITY_BY_CONTRACT_PREV="${DFILT}/${NJOB}_1_${IB}_SORTED_PROFITABILITY_BY_CONTRACT_PREV.dat"
export ESTJ0004_SORTED_CASHFLOW_PAMOR_PAFAM_PBAAC="${DFILT}/${NJOB}_1_${IB}_SORTED_CASHFLOW_PAMOR_PAFAM_PBAAC.dat"
export ESTJ0004_SORTED_CASHFLOW_WITHOUT_PAMOR_PAFAM_PBAAC="${DFILT}/${NJOB}_1_${IB}_SORTED_CASHFLOW_WITHOUT_PAMOR_PAFAM_PBAAC.dat"
export ESTJ0004_UPDATED_CASHFLOW_PAMOR_PAFAM_PBAAC="${DFILT}/${NJOB}_1_${IB}_UPDATED_CASHFLOW_PAMOR_PAFAM_PBAAC.dat"
export ESTJ0004_SORTED_AMORTIZATION_PATTERN_CSM_LC_CURRENT_Q_A="${DFILT}/${NJOB}_1_${IB}_SORTED_AMORTIZATION_PATTERN_CSM_LC_CURRENT_Q_A.dat"
export ESTJ0004_SORTED_AMORTIZATION_PATTERN_CSM_LC_CURRENT_Q_R="${DFILT}/${NJOB}_1_${IB}_SORTED_AMORTIZATION_PATTERN_CSM_LC_CURRENT_Q_R.dat"

# outputs files
export ESTJ0004_SEGMENT_PROFITABILITY="${ESF_FSEGPROF_STD}"
export ESTJ0004_PROFITABILITY_BY_CONTRACT_CUR="${ESF_CSM_PROF_CUR}"
export ESTJ0004_MERGED_CSM_CASHFLOW="${ESF_GTSII_CSM_CASHFLOW}"

# CMD variable
export SYNCSORT_CMD_ESTJ0004_SORT_CONTRACT_PERICASE_BY_CTR_ID=${DCMD}/ESTS0003.cmd
export SYNCSORT_CMD_ESTJ0004_SORT_CASHFLOW_BY_CTR_ID=${DCMD}/ESTS0004.cmd
export SYNCSORT_CMD_ESTJ0004_SORT_UOA_DATA_RECOVERY_BY_UOA_AC=${DCMD}/ESTS0018.cmd
export SYNCSORT_CMD_ESTJ0004_SORT_CONTRACT_PERICASE_LIGHT_BY_SEGMENT_ID=${DCMD}/ESTS0014.cmd
export SYNCSORT_CMD_ESTJ0004_SORT_SEGMENT_PROFITABILITY_BY_SEGMENT_ID=${DCMD}/ESTS0001.cmd
export SYNCSORT_CMD_ESTJ0004_SORT_PROFITABILITY_BY_CONTRACT_BY_CTR_ID=${DCMD}/ESTS0017.cmd
export SYNCSORT_CMD_ESTJ0004_SORT_CASHFLOW_PAMOR_PAFAM_PBAAC_BY_CTR_ID=${DCMD}/ESTS0031.cmd
export SYNCSORT_CMD_ESTJ0004_SORT_CASHFLOW_WITHOUT_PAMOR_PAFAM_PBAAC_BY_CTR_ID=${DCMD}/ESTS0032.cmd
export SYNCSORT_CMD_ESTJ0004_MERGE_CASHFLOW=${DCMD}/ESTS0005.cmd
export SYNCSORT_CMD_ESTJ0004_SORT_AMORTIZATION_PATTERN_BY_CTR_ID=${DCMD}/ESTS0022.cmd

# Jar execution
JSB_CHAIN="estj0004"
JSB_PARAMS="cloDate=${PARM_ICLODAT_D} prevCloDate=${PARM_PREV_ICLODAT_D} cloType=${TYPEINV} normcf=${NORME_CF} cloUser=${PARM_BATCHUSER}"
EXECJSB

NSTEP=${NJOB}_2
#------------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*${IB}*.dat "

JOBEND
