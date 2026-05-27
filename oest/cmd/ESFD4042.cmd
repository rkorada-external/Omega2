#!/bin/ksh
#=============================================================================
# nom de l'application          : I17G -APP4 (TL and cashflow data aggregation)
# nom du script SHELL           : ESFD4042.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 10\03\2021
# auteur                        : Charles SOCIE
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  TI17CTRINFO update table
#
#-----------------------------------------------------------------------------
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctjsb.cmd

# Job Initialisation
JOBINIT

PERICASEA_EXTEND=${DFILT}/${ENV_PREFIX}_ESFD4040_ESFD4041${TYPEINV}_65_${IB}_MERGE_PERICASE_EXTEND_CSM_LC_PATTERN_FLAG_RATIO_ASSUMED.dat
PERICASER_EXTEND=${DFILT}/${ENV_PREFIX}_ESFD4040_ESFD4041${TYPEINV}_65_${IB}_PERICASE_EXTEND_RETRO.dat
FLORETFACTOR_EXTEND=${DFILT}/${ENV_PREFIX}_ESFD4040_ESFD4041${TYPEINV}_65_${IB}_MERGE_EST_RATIO_RETRO_P_EXTEND_CSM_LC_PATTERN_FLAG_LOFACTOR.dat

ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> PERICASEA_EXTEND.................................................: ${PERICASEA_EXTEND}"
ECHO_LOG "#===> PERICASER_EXTEND.................................................: ${PERICASER_EXTEND}"
ECHO_LOG "#===> FLORETFACTOR_EXTEND..............................................: ${FLORETFACTOR_EXTEND}"
ECHO_LOG "#===> MANUAL_OVERWRITE.................................................: ${MANUAL_OVERWRITE}"
ECHO_LOG "#===> ............ OUTPUT ................................................."
ECHO_LOG "#===> MERGE_PERICASE_EXTENDED..........................................: ${MERGE_PERICASE_EXTENDED}"
ECHO_LOG "#========================================================================="

if [ -e ${MANUAL_OVERWRITE} ]
then

NSTEP=${NJOB}_1
#------------------------------------------------------------------------------
LIBEL="Change sep and remove headers and move file to DFILT location"
awk -F "\t" 'OFS="~" {if (NR != 1 ) print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18}' ${MANUAL_OVERWRITE} > ${DFILT}/${NSTEP}_${IB}_MANUAL_OVERWRITE_AWK.dat

else

NSTEP=${NJOB}_1B
#------------------------------------------------------------------------------
LIBEL="Create manaual overwrite file if not existing at FTP location"
touch  ${DFILT}/${NJOB}_1_${IB}_MANUAL_OVERWRITE_AWK.dat

fi

NSTEP=${NJOB}_2
#------------------------------------------------------------------------------
# inputs files
export ESTJ0013_PERICASE_EXTENDED="${PERICASEA_EXTEND}"
export ESTJ0013_FLORETFACTOR_EXTENDED="${FLORETFACTOR_EXTEND}"
export ESTJ0013_PERICASE_RETRO_EXTEND="${PERICASER_EXTEND}"
export ESTJ0013_MANUAL_OVERWRITE="${DFILT}/${NJOB}_1_${IB}_MANUAL_OVERWRITE_AWK.dat"

# tmp files
export ESTJ0013_PERICASE_EXTENDED_NODUPLICATE="${DFILT}/${NJOB}_2_${IB}_PERICASE_EXTENDED_NODUPLICATE.dat"
export ESTJ0013_MERGE_PERICASE_EXTENDED="${DFILT}/${NJOB}_2_${IB}_MERGE_PERICASE_EXTENDED.dat"
export ESTJ0013_SORTED_PERICASE_EXTENDED="${DFILT}/${NJOB}_2_${IB}_SORTED_PERICASE_EXTENDED.dat"
export ESTJ0013_SORTED_MANUAL_OVERWRITE="${DFILT}/${NJOB}_2_${IB}_SORTED_MANUAL_OVERWRITE.dat"

# outputs files
export ESTJ0013_MERGE_PERICASE_EXTENDED_COMMENT="${MERGE_PERICASE_EXTENDED}"

# CMD variable
export SYNCSORT_CMD_ESTJ0013_MERGE_FILES=${DCMD}/ESTS0005.cmd
export SYNCSORT_CMD_ESTJ0013_SORT_MANUAL_OVERWRITE_BY_CTR_ID=${DCMD}/ESTS0059.cmd
export SYNCSORT_CMD_ESTJ0013_SORT_PERICASE_EXTENDED_BY_CTR_ID=${DCMD}/ESTS0060.cmd

# Jar execution
JSB_CHAIN="estj0013"
JSB_PARAMS="cloDate=${PARM_ICLODAT_D}"
EXECJSB

NSTEP=${NJOB}_3
#------------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*${IB}*.dat "

JOBEND