#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD3771.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 20\11\2019
# auteur                        : Antoine GRUNWALD
#-----------------------------------------------------------------------------
# description
#  IFRS17 REQ 12.8 : CSM/LC amortization pattern calculation
#
#-----------------------------------------------------------------------------
# modif
# [01] 26/08/2022 Bhimasen 	SPIRA 105633 : I17PRD - Missing FP AE in CSM/LC pattern calculation
# [02] 16/10/2023 HR  	        SPIRA 110691 : I17 - Incorrect CSM/LC pattern calculation on internal assumed
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctjsb.cmd

# Job Initialisation
JOBINIT

ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ICLODAT_D...........................................................: ${PARM_ICLODAT_D}"

ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> EST_IADPERICASE_STD.................................................: ${EST_IADPERICASE_STD}"
ECHO_LOG "#===> EPO_FCURQUOT_TXT....................................................: ${EPO_FCURQUOT_TXT}"
ECHO_LOG "#===> EST_FBOPRSLNK_TXT...................................................: ${EST_FBOPRSLNK_TXT}"
ECHO_LOG "#===> EST_DLCUMGTAAR......................................................: ${EST_DLCUMGTAAR}"
ECHO_LOG "#===> EST_DLDGTAA.........................................................: ${EST_DLDGTAA}"
ECHO_LOG "#===> EST_DLSGTAA.........................................................: ${EST_DLSGTAA}"
ECHO_LOG "#===> ESF_DLRGTAA.........................................................: ${ESF_DLRGTAA}"
ECHO_LOG "#===> EST_IRDPERICASE0....................................................: ${EST_IRDPERICASE0}"
ECHO_LOG "#===> ESF_NDIC_NCB_STD....................................................: ${ESF_NDIC_NCB_STD}"
ECHO_LOG "#===> MANUAL_OVERWRITE....................................................: ${MANUAL_OVERWRITE}"

ECHO_LOG "#===> ............ OUTPUT ................................................."
ECHO_LOG "#===> ESF_CSM_LC_AMORT_PATTERN............................................: ${ESF_CSM_LC_AMORT_PATTERN}"
ECHO_LOG "#========================================================================="

if [ -e ${MANUAL_OVERWRITE} ]
then

NSTEP=${NJOB}_0
#------------------------------------------------------------------------------
LIBEL="Change sep and remove headers and move file to DFILT location"
awk -F "\t" 'OFS="~" {if (NR != 1 ) print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18}' ${MANUAL_OVERWRITE} > ${DFILT}/${NSTEP}_${IB}_MANUAL_OVERWRITE_AWK.dat

else

NSTEP=${NJOB}_0B
#------------------------------------------------------------------------------
LIBEL="Create manaual overwrite file if not existing at FTP location"
touch  ${DFILT}/${NJOB}_0_${IB}_MANUAL_OVERWRITE_AWK.dat

fi

#[02]
NSTEP=${NJOB}_1
#------------------------------------------------------------------------------
# Merge EST_DLDGTAA with EST_DLSGTAA and ESF_DLRGTAA
#-----------------------------------------------------------------------------
LIBEL=" Merge EST_DLDGTAA with EST_DLSGTAA "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLDGTAA} 2000 1"
SORT_I2="${EST_DLSGTAA} 2000 1"
SORT_I3="${ESF_DLRGTAA} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_EST_DLDGTAA_DLSGTAA_MERGE.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
ESB_CF 2:1 - 2:,
CTR_NF 8:1 - 8:,
END_NT 9:1 - 9:,
SEC_NF 10:1 - 10:,
UWY_NF 11:1 - 11:,
UW_NT 12:1 - 12:,
TRNCOD_CF 6:1 - 6:
/KEYS SSD_CF,
ESB_CF,
CTR_NF,
END_NT,
SEC_NF,
UWY_NF,
UW_NT,
TRNCOD_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_1A
#------------------------------------------------------------------------------
LIBEL="Delete duplicate rows"
sort -u ${DFILT}/${NJOB}_1_${IB}_EST_DLDGTAA_DLSGTAA_MERGE.dat > ${DFILT}/${NSTEP}_${IB}_EST_DLDGTAA_DLSGTAA.dat

NSTEP=${NJOB}_2
#------------------------------------------------------------------------------

# inputs files
export ESTJ0005_CONTRACT_PERICASE="${EST_IADPERICASE_STD}"
export ESTJ0005_CURRENCY_EX_RATE="${EPO_FCURQUOT_TXT}"
export ESTJ0005_FTBOPRSLNK="${EST_FBOPRSLNK_TXT}"
export ESTJ0005_DLCUMGTAAR="${EST_DLCUMGTAAR}"
export ESTJ0005_FUTURE="${DFILT}/${NJOB}_1A_${IB}_EST_DLDGTAA_DLSGTAA.dat"
export ESTJ0005_CONTRACT_PERICASE_R="${EST_IRDPERICASE0}"
export ESTJ0005_NDIC_NCB_STD="${ESF_NDIC_NCB_STD}"
export ESTJ0005_MANUAL_OVERWRITE="${DFILT}/${NJOB}_0_${IB}_MANUAL_OVERWRITE_AWK.dat"

# tmp files
export ESTJ0005_SORTED_DLCUMGTAAR="${DFILT}/${NJOB}_1_${IB}_SORTED_DLCUMGTAAR.dat"
export ESTJ0005_SORTED_FUTURE="${DFILT}/${NJOB}_1_${IB}_SORTED_FUTURE.dat"
export ESTJ0005_SORTED_CONTRACT_PERICASE="${DFILT}/${NJOB}_1_${IB}_SORTED_CONTRACT_PERICASE.dat"
export ESTJ0005_AMORTIZATION_PATTERN_CSM_LC_A="${DFILT}/${NJOB}_1_${IB}_AMORTIZATION_PATTERN_CSM_LC_A.dat"
export ESTJ0005_AMORTIZATION_PATTERN_CSM_LC_R="${DFILT}/${NJOB}_1_${IB}_AMORTIZATION_PATTERN_CSM_LC_R.dat"
export ESTJ0005_SORTED_AMORTIZATION_PATTERN_CSM_LC_A="${DFILT}/${NJOB}_1_${IB}_SORTED_AMORTIZATION_PATTERN_CSM_LC_A.dat"
export ESTJ0005_SORTED_CONTRACT_PERICASE_R="${DFILT}/${NJOB}_1_${IB}_SORTED_CONTRACT_PERICASE_R.dat"
export ESTJ0005_SORTED_NDIC_NCB_STD="${DFILT}/${NJOB}_1_${IB}_SORTED_NDIC_NCB_STD.dat"
export ESTJ0005_SORTED_MANUAL_OVERWRITE="${DFILT}/${NJOB}_1_${IB}_SORTED_MANUAL_OVERWRITE.dat"
export ESTJ0005_BUSINESS_LOGS="${DFILT}/${NJOB}_1_${IB}_BUSINESS_JAVALOGS.log"

# outputs files
export ESTJ0005_CSM_LC_AMORTIZATION_PATTERN="${ESF_CSM_LC_AMORT_PATTERN}"

# CMD variable
export SYNCSORT_CMD_ESTJ0005_SORT_CONTRACT_PERICASE_BY_CTR_ID=${DCMD}/ESTS0056.cmd
export SYNCSORT_CMD_ESTJ0005_SORT_FUTURE_BY_CTR_ID=${DCMD}/ESTS0015.cmd
export SYNCSORT_CMD_ESTJ0005_SORT_DLCUMGTAAR_BY_CTR_ID=${DCMD}/ESTS0012.cmd
export SYNCSORT_CMD_ESTJ0005_MERGE_FILE=${DCMD}/ESTS0005.cmd
export SYNCSORT_CMD_ESTJ0005_SORT_NDIC_NCB_BY_CTR_ID=${DCMD}/ESTS0033.cmd
export SYNCSORT_CMD_ESTJ0005_MANUAL_OVERWRITE_BY_CTR_ID=${DCMD}/ESTS0059.cmd

# Jar execution
JSB_CHAIN="estj0005"
JSB_PARAMS="cloDate=${PARM_ICLODAT_D}"
EXECJSB

NSTEP=${NJOB}_3
#------------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*${IB}*.dat "

JOBEND
