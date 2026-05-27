#!/bin/ksh
#=================================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD3991.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 13\01\2021
# auteur                        : NBD
#---------------------------------------------------------------------------------
# description
#  IFRS17 REQ 22.6 : Annual limit flag
#
#---------------------------------------------------------------------------------
#=================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctjsb.cmd 

# Job Initialisation
JOBINIT

# Get input parameters

ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ICLODAT_D........................................................: ${PARM_ICLODAT_D}"

ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> EPO_FCURQUOT_TXT.................................................: ${EPO_FCURQUOT_TXT}"
ECHO_LOG "#===> EST_DLCUMGTAAR...................................................: ${EST_DLCUMGTAAR}"
ECHO_LOG "#===> EST_ANN_LIMIT_FAC................................................: ${EST_ANN_LIMIT_FAC}"
ECHO_LOG "#===> EST_ANN_LIMIT_TRT................................................: ${EST_ANN_LIMIT_TRT}"

ECHO_LOG "#===> ............ OUTPUT ................................................."
ECHO_LOG "#===> EST_FLAG_ANN_LMT.................................................: ${EST_FLAG_ANN_LMT}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_1
#------------------------------------------------------------------------------

# inputs files
export ESTJ0011_EPO_FCURQUOT_TXT="${EPO_FCURQUOT_TXT}"
export ESTJ0011_EST_DLCUMGTAAR="${EST_DLCUMGTAAR}"
export ESTJ0011_EST_ANN_LIMIT_FAC="${EST_ANN_LIMIT_FAC}"
export ESTJ0011_EST_ANN_LIMIT_TRT="${EST_ANN_LIMIT_TRT}"

# tmp files
export ESTJ0011_SORTED_EST_DLCUMGTAAR="${DFILT}/${NJOB}_1_${IB}_SORTED_EST_DLCUMGTAAR.dat"
export ESTJ0011_SORTED_EST_ANN_LIMIT_FAC="${DFILT}/${NJOB}_1_${IB}_SORTED_ANN_LIMIT_FAC.dat"
export ESTJ0011_PAID_CLAIMS_FAC_EXTENDED_WITH_DIVISION="${DFILT}/${NJOB}_1_${IB}_PAID_CLAIMS_FAC_EXTENDED_WITH_DIVISION.dat"
export ESTJ0011_SORTED_PAID_CLAIMS_FAC_EXTENDED_WITH_DIVISION="${DFILT}/${NJOB}_1_${IB}_SORTED_PAID_CLAIMS_FAC_EXTENDED_WITH_DIVISION.dat"
export ESTJ0011_SORTED_EST_ANN_LIMIT_TRT="${DFILT}/${NJOB}_1_${IB}_SORTED_ANN_LIMIT_TRT.dat"
export ESTJ0011_EST_FLAG_ANN_LMT_TRT="${DFILT}/${NJOB}_1_${IB}_FLAG_ANN_LMT_TRT.dat"
export ESTJ0011_EST_FLAG_ANN_LMT_FAC="${DFILT}/${NJOB}_1_${IB}_FLAG_ANN_LMT_FAC.dat"

# outputs files
export ESTJ0011_EST_FLAG_ANN_LMT_MERGE="${EST_FLAG_ANN_LMT}"

# CMD variable
export SYNCSORT_CMD_ESTJ0011_SORT_DLCUMGTAAR_BY_CTR_ID=${DCMD}/ESTS0043.cmd
export SYNCSORT_CMD_ESTJ0011_SORT_EST_ANN_LIMIT_FILE=${DCMD}/ESTS0044.cmd
export SYNCSORT_CMD_ESTJ0011_SORT_PAID_CLAIMS_EXTENDED=${DCMD}/ESTS0045.cmd
export SYNCSORT_CMD_ESTJ0011_MERGE_FILE=${DCMD}/ESTS0005.cmd

# Jar execution
JSB_CHAIN="estj0011"
JSB_PARAMS="cloDate=${PARM_ICLODAT_D}"
EXECJSB

NSTEP=${NJOB}_2
#------------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*${IB}*.dat "

JOBEND