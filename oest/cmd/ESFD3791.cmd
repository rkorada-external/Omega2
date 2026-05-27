#!/bin/ksh
#=================================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD3791.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 10\12\2019
# auteur                        : Cyril AVINENS
#---------------------------------------------------------------------------------
# description
#  IFRS17 REQ 12.11 : Net position indicator calculation
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
ECHO_LOG "#===> CLOTYP...........................................................: ${TYPEINV}"
ECHO_LOG "#===> NORME_CF.........................................................: ${NORME_CF}"
ECHO_LOG "#===> BATCHUSER........................................................: ${PARM_BATCHUSER}"

ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> EPO_FCURQUOT_TXT.................................................: ${EPO_FCURQUOT_TXT}"
ECHO_LOG "#===> EST_IADPERICASE_STD..............................................: ${EST_IADPERICASE_STD}"
ECHO_LOG "#===> ESF_GTSII_ESCOMPTE_DSC...........................................: ${ESF_GTSII_ESCOMPTE_DSC}"
ECHO_LOG "#===> ESF_GTSII_ESCOMPTE_RAD...........................................: ${ESF_GTSII_ESCOMPTE_RAD}"

ECHO_LOG "#===> ............ OUTPUT ................................................."
ECHO_LOG "#===> ESF_FSEGPROF_SEG_STD.............................................: ${ESF_FSEGPROF_SEG_STD}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_1
#------------------------------------------------------------------------------

# inputs files
export ESTJ0007_CURRENCY="${EPO_FCURQUOT_TXT}"
export ESTJ0007_CONTRACT_PERICASE="${EST_IADPERICASE_STD}"
export ESTJ0007_DISCOUNT_CASHFLOW_DSC="${ESF_GTSII_ESCOMPTE_DSC}"
export ESTJ0007_DISCOUNT_CASHFLOW_RAD="${ESF_GTSII_ESCOMPTE_RAD}"

# tmp files
export ESTJ0007_SORTED_CONTRACT_PERICASE="${DFILT}/${NJOB}_1_${IB}_SORTED_CONTRACT_PERICASE.dat"
export ESTJ0007_MERGED_CASHFLOW="${DFILT}/${NJOB}_1_${IB}_MERGED_CASHFLOW.dat"
export ESTJ0007_SORTED_MERGED_CASHFLOW_ASSUMED="${DFILT}/${NJOB}_1_${IB}_SORTED_MERGED_CASHFLOW_ASSUMED.dat"
export ESTJ0007_SORTED_MERGED_CASHFLOW_RETRO="${DFILT}/${NJOB}_1_${IB}_SORTED_MERGED_CASHFLOW_RETRO.dat"
export ESTJ0007_SEGMENT_INDICATOR_RECOVERY="${DFILT}/${NJOB}_1_${IB}_SEGMENT_INDICATOR_RECOVERY.dat"
export ESTJ0007_SORTED_SEGMENT_INDICATOR_RECOVERY="${DFILT}/${NJOB}_1_${IB}_SORTED_SEGMENT_INDICATOR_RECOVERY.dat"
export ESTJ0007_SEGMENT_PROFITABILITY_INDICATOR_ASSUMED="${DFILT}/${NJOB}_1_${IB}_SEGMENT_PROFITABILITY_INDICATOR_ASSUMED.dat"
export ESTJ0007_SEGMENT_PROFITABILITY_INDICATOR_RETRO="${DFILT}/${NJOB}_1_${IB}_SEGMENT_PROFITABILITY_INDICATOR_RETRO.dat"

# outputs files
export ESTJ0007_SEGMENT_PROFITABILITY_INDICATOR="${ESF_FSEGPROF_SEG_STD}"

# CMD variable
export SYNCSORT_CMD_ESTJ0007_MERGE_FILE=${DCMD}/ESTS0005.cmd
export SYNCSORT_CMD_ESTJ0007_SORT_CONTRACT_PERICASE_BY_CTR_ID=${DCMD}/ESTS0003.cmd
export SYNCSORT_CMD_ESTJ0007_SORT_CASHFLOW_BY_CTR_ID_SPLIT_ASSUME_RETRO=${DCMD}/ESTS0006.cmd
export SYNCSORT_CMD_ESTJ0007_SORT_SEGMENT_INDICATOR_RECOVERY_BY_SEGMENT_ID=${DCMD}/ESTS0016.cmd

# Jar execution
JSB_CHAIN="estj0007"
JSB_PARAMS="cloDate=${PARM_ICLODAT_D} cloType=${TYPEINV} normcf=${NORME_CF} cloUser=${PARM_BATCHUSER}"
EXECJSB

NSTEP=${NJOB}_2
#------------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*${IB}*.dat "

JOBEND
