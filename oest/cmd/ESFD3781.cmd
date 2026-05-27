#!/bin/ksh
#=================================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD3781.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 26\02\2020
# auteur                        : Antoine GRUNWALD
#---------------------------------------------------------------------------------
# description
#  IFRS17 REQ 12.10 : CSM/LC Booking calculation
#  calculation is done with assum and retro contract
#
#---------------------------------------------------------------------------------
#=================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctjsb.cmd

# Job Initialisation
JOBINIT

ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ICLODAT_D....................................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> CLOTYP.......................................................: ${TYPEINV}"
ECHO_LOG "#===> NORME_CF.....................................................: ${NORME_CF}"
ECHO_LOG "#===> BATCHUSER....................................................: ${PARM_BATCHUSER}"

ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> ESF_GTSII_CSM_CASHFLOW.......................................: ${ESF_GTSII_CSM_CASHFLOW}"
ECHO_LOG "#===> ESF_CSM_PROF.................................................: ${ESF_CSM_PROF}"
ECHO_LOG "#===> ESF_CSM_PROF_CUR.............................................: ${ESF_CSM_PROF_CUR}"
ECHO_LOG "#===> ESF_FTECLEDA.................................................: ${ESF_FTECLEDA}"
ECHO_LOG "#===> EST_FBOPRSLNK_TXT............................................: ${EST_FBOPRSLNK_TXT}"
ECHO_LOG "#===> ESF_FTECLEDR.................................................: ${ESF_FTECLEDR}"
ECHO_LOG "#===> EST_DLSGTAA..................................................: ${EST_DLSGTAA}"
ECHO_LOG "#===> EST_DLSGTAR..................................................: ${EST_DLSGTAR}"
ECHO_LOG "#===> EST_DLSGTR...................................................: ${EST_DLSGTR}"
ECHO_LOG "#===> ESF_FCURQUOT_TXT.............................................: ${ESF_FCURQUOT_TXT}"

ECHO_LOG "#===> ............ OUTPUT ................................................"
ECHO_LOG "#===> ESF_CSM_LC_FTECLEDA..........................................: ${ESF_CSM_LC_FTECLEDA}"
ECHO_LOG "#===> ESF_CSM_LC_FTECLEDR..........................................: ${ESF_CSM_LC_FTECLEDR}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_1
#------------------------------------------------------------------------------

# inputs files
export ESTJ0006_CSM_CASHFLOW="${ESF_GTSII_CSM_CASHFLOW}"
export ESTJ0006_PROFITABILITY_BY_CONTRACT_PREV_A="${ESF_CSM_PROF}"
export ESTJ0006_PROFITABILITY_BY_CONTRACT_A="${ESF_CSM_PROF_CUR}"
export ESTJ0006_TRANSACTION_A="${ESF_FTECLEDA}"
export ESTJ0006_FBOPRSLNK="${EST_FBOPRSLNK_TXT}"
export ESTJ0006_TRANSACTION_R="${ESF_FTECLEDR}"
export ESTJ0006_DLSGTAA="${EST_DLSGTAA}"
export ESTJ0006_DLSGTAR="${EST_DLSGTAR}"
export ESTJ0006_DLSGTR="${EST_DLSGTR}"
export ESTJ0006_CURRENCY="${ESF_FCURQUOT_TXT}"

# tmp files
export ESTJ0006_BUSINESS_LOGS="${DFILT}/${NJOB}_1_${IB}_BUSINESS_JAVALOGS.log"
export ESTJ0006_SORTED_CSM_CASHFLOW_A="${DFILT}/${NJOB}_1_${IB}_SORTED_CSM_CASHFLOW_A.dat"
export ESTJ0006_SORTED_CSM_CASHFLOW_RP="${DFILT}/${NJOB}_1_${IB}_SORTED_CSM_CASHFLOW_RP.dat"
export ESTJ0006_SORTED_CSM_CASHFLOW_RNP="${DFILT}/${NJOB}_1_${IB}_SORTED_CSM_CASHFLOW_RNP.dat"
export ESTJ0006_SORTED_PROFITABILITY_BY_CONTRACT_PREV_A="${DFILT}/${NJOB}_1_${IB}_SORTED_PROFITABILITY_BY_CONTRACT_PREV_A.dat"
export ESTJ0006_SORTED_TRANSACTION_A="${DFILT}/${NJOB}_1_${IB}_SORTED_TRANSACTION_A.dat"
export ESTJ0006_SORTED_TRANSACTION_R="${DFILT}/${NJOB}_1_${IB}_SORTED_TRANSACTION_R.dat"
export ESTJ0006_SORTED_PROFITABILITY_BY_CONTRACT_A="${DFILT}/${NJOB}_1_${IB}_SORTED_PROFITABILITY_BY_CONTRACT_A.dat"
export ESTJ0006_SORTED_DLSGT_A="${DFILT}/${NJOB}_1_${IB}_SORTED_DLSGT_A.dat"
export ESTJ0006_SORTED_DLSGT_R="${DFILT}/${NJOB}_1_${IB}_SORTED_DLSGT_R.dat"
export ESTJ0006_DLSGT_R="${DFILT}/${NJOB}_1_${IB}_DLSGT_R.dat"

# outputs files
export ESTJ0006_CSM_LC_BOOKING_A="${ESF_CSM_LC_FTECLEDA}"
export ESTJ0006_CSM_LC_BOOKING_R="${ESF_CSM_LC_FTECLEDR}"

# CMD variable
export SYNCSORT_CMD_ESTJ0006_SORT_CASHFLOW_BY_CTR_ID=${DCMD}/ESTS0053.cmd
export SYNCSORT_CMD_ESTJ0006_SORT_TRANSACTION_A_BY_CTR_ID=${DCMD}/ESTS0019.cmd
export SYNCSORT_CMD_ESTJ0006_SORT_PROFITABILITY_BY_CONTRACT_A_BY_CTR_ID=${DCMD}/ESTS0017.cmd
export SYNCSORT_CMD_ESTJ0006_SORT_TRANSACTION_R_BY_CTR_ID=${DCMD}/ESTS0011.cmd
export SYNCSORT_CMD_ESTJ0006_SORT_DLSGT_BY_CTR_ID=${DCMD}/ESTS0037.cmd
export SYNCSORT_CMD_ESTJ0006_MERGE=${DCMD}/ESTS0005.cmd

# Jar execution
JSB_CHAIN="estj0006"
JSB_PARAMS="cloDate=${PARM_ICLODAT_D} cloType=${TYPEINV} normcf=${NORME_CF} cloUser=${PARM_BATCHUSER}"
EXECJSB

NSTEP=${NJOB}_2
#------------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*${IB}*.dat "

JOBEND
