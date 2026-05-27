#!/bin/ksh
#=================================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD3951.cmd
# revision                      : $Revision:   1.0 $
# date de creation              : 14\10\2020
# auteur                        : Charles SOCIE
#---------------------------------------------------------------------------------
# description
#  undiscounted NDIC (Non-Distinct Investment Component) base amounts calculation for retro
#
#---------------------------------------------------------------------------------
# modif
# [01] 23/03/2022 Bhimasen 	SPIRA 98794 : NDIC- curency issue
# [02] 08/22/2022 J.B-D 	SPIRA 106362 : Add [ IDF_CT = "I17G_ESFD3950"]
# [03] 14/10/2022 FCI 	SPIRA 106509 : Add [ IDF_CT = "I17S_ESFD3950"]
#=================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctjsb.cmd

# Job Initialisation
JOBINIT

ECHO_LOG "#======================================================================"
ECHO_LOG "#===> ICLODAT_D........................................................: ${PARM_ICLODAT_D}"

if [ ${NORME_CF} = "EBS" ] || [ ${IDF_CT} = "I17G_ESFD3950" ] || [ ${IDF_CT} = "I17S_ESFD3950"]
then
	NORME_CF_TO_USE="I17G"
	CONTEXT_CT_TO_USE="STD"
else
	NORME_CF_TO_USE="${NORME_CF}"
	CONTEXT_CT_TO_USE="${CONTEXT_CT}"
	ECHO_LOG "#===> CONTEXT_CT.......................................................: ${CONTEXT_CT_TO_USE}"
fi
ECHO_LOG "#===> NORME_CF.........................................................: ${NORME_CF}"
ECHO_LOG "#===> PARM_ICLODAT_D...................................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> PARM_PREV_ICLODAT_D..............................................: ${PARM_PREV_ICLODAT_D}"

ECHO_LOG "#===> ............ INPUT .............................................."
ECHO_LOG "#===> EST_IRDPERICASE_FILTERED.........................................: ${EST_IRDPERICASE_FILTERED}"
ECHO_LOG "#===> EST_IADPERICASE..................................................: ${EST_IADPERICASE}"
ECHO_LOG "#===> EST_FPLC.........................................................: ${EST_FPLC}"
ECHO_LOG "#===> EST_FCES.........................................................: ${EST_FCES}"
ECHO_LOG "#===> EPO_FCURQUOT_TXT.................................................: ${EPO_FCURQUOT_TXT}"
ECHO_LOG "#===> ESF_NDIC_NCB_RET.................................................: ${ESF_NDIC_NCB_RET}"
ECHO_LOG "#===> ESF_NDIC_NCB.....................................................: ${ESF_NDIC_NCB}"
ECHO_LOG "#===> EST_NDIC_AUTO_RETRO..............................................: ${EST_NDIC_AUTO_RETRO}"
ECHO_LOG "#===> EST_DLCUMGTAAR_MVT...............................................: ${EST_DLCUMGTAAR}"
ECHO_LOG "#===> ESF_GTSII_GLOBAL_CASHFLOW........................................: ${ESF_GTSII_GLOBAL_CASHFLOW}"
ECHO_LOG "#===> EST_NDIC_FLOARAT.................................................: ${EST_NDIC_FLOARAT}"
ECHO_LOG "#===> EST_DLCUMGTAAR_PREV..............................................: ${EST_DLCUMGTAAR_PREV}"
ECHO_LOG "#===> ESF_GTSII_GLOBAL_CASHFLOW_PREV...................................: ${ESF_GTSII_GLOBAL_CASHFLOW_PREV}"
ECHO_LOG "#===> ESF_DLSGTAR_FILTERED.............................................: ${ESF_DLSGTAR_FILTERED}"

ECHO_LOG "#===> ............ OUTPUT ............................................."
ECHO_LOG "#===> EST_ACC_RETRO_NDIC_AMOUNT........................................: ${EST_ACC_RETRO_NDIC_AMOUNT}"
ECHO_LOG "#======================================================================"

NSTEP=${NJOB}_1
#------------------------------------------------------------------------------
# inputs files
export ESTJ0010_CURRENCY_EX_RATE="${EPO_FCURQUOT_TXT}"
export ESTJ0010_PERICASE_RETRO="${EST_IRDPERICASE_FILTERED}"
export ESTJ0010_PERICASE_ASSUM="${EST_IADPERICASE}"
export ESTJ0010_FPLC="${EST_FPLC}"
export ESTJ0010_FCES="${EST_FCES}"
export ESTJ0010_NCB_RETRO="${ESF_NDIC_NCB_RET}"
export ESTJ0010_NCB_ASSUM="${ESF_NDIC_NCB}"
export ESTJ0010_AUTO_RETRO="${EST_NDIC_AUTO_RETRO}"
export ESTJ0010_DLCUMGTAAR="${EST_DLCUMGTAAR}"
export ESTJ0010_FUTURE="${ESF_GTSII_GLOBAL_CASHFLOW}"
export ESTJ0010_FLOARAT="${EST_NDIC_FLOARAT}"
export ESTJ0010_DLCUMGTAAR_PREV="${EST_DLCUMGTAAR_PREV}"
export ESTJ0010_FUTURE_PREV="${ESF_GTSII_GLOBAL_CASHFLOW_PREV}"
export ESTJ0010_DLSGTAR="${ESF_DLSGTAR_FILTERED}"


# tmp files
export ESTJ0010_SORTED_PERICASE_RETRO="${DFILT}/${NJOB}_1_${IB}_SORTED_PERICASE_RETRO.dat"
export ESTJ0010_SORTED_PERICASE_ASSUM="${DFILT}/${NJOB}_1_${IB}_SORTED_PERICASE_ASSUM.dat"
export ESTJ0010_PERICASE_EXTENDED_ASSUM_RP="${DFILT}/${NJOB}_1_${IB}_PERICASE_EXTENDED_ASSUM_RP.dat"
export ESTJ0010_SORTED_PERICASE_EXTENDED_ASSUM_RP="${DFILT}/${NJOB}_1_${IB}_SORTED_PERICASE_EXTENDED_ASSUM_RP.dat"
export ESTJ0010_PERICASE_EXTENDED_RP="${DFILT}/${NJOB}_1_${IB}_PERICASE_EXTENDED_RP.dat"
export ESTJ0010_PERICASE_EXTENDED_RNP="${DFILT}/${NJOB}_1_${IB}_PERICASE_EXTENDED_RNP.dat"
export ESTJ0010_SORTED_PERICASE_EXTENDED_RP="${DFILT}/${NJOB}_1_${IB}_SORTED_PERICASE_EXTENDED_RP.dat"
export ESTJ0010_SORTED_PERICASE_EXTENDED_RNP="${DFILT}/${NJOB}_1_${IB}_SORTED_PERICASE_EXTENDED_RNP.dat"
export ESTJ0010_SORTED_FPLC="${DFILT}/${NJOB}_1_${IB}_SORTED_FPLC.dat"
export ESTJ0010_SORTED_FCES="${DFILT}/${NJOB}_1_${IB}_SORTED_FCES.dat"
export ESTJ0010_SORTED_NCB_RETRO="${DFILT}/${NJOB}_1_${IB}_SORTED_NCB_RETRO.dat"
export ESTJ0010_SORTED_NCB_ASSUM="${DFILT}/${NJOB}_1_${IB}_SORTED_NCB_ASSUM.dat"
export ESTJ0010_SORTED_AUTO_RETRO="${DFILT}/${NJOB}_1_${IB}_SORTED_AUTO_RETRO.dat"
export ESTJ0010_SORTED_DLCUMGTAAR_RP="${DFILT}/${NJOB}_1_${IB}_SORTED_DLCUMGTAAR_RP.dat"
export ESTJ0010_SORTED_DLCUMGTAAR_RNP="${DFILT}/${NJOB}_1_${IB}_SORTED_DLCUMGTAAR_RNP.dat"
export ESTJ0010_SORTED_FUTURE_RP="${DFILT}/${NJOB}_1_${IB}_SORTED_FUTURE_RP.dat"
export ESTJ0010_SORTED_FUTURE_RNP="${DFILT}/${NJOB}_1_${IB}_SORTED_FUTURE_RNP.dat"
export ESTJ0010_SORTED_DLCUMGTAAR_RP_PREV="${DFILT}/${NJOB}_1_${IB}_SORTED_DLCUMGTAAR_RP_PREV.dat"
export ESTJ0010_SORTED_DLCUMGTAAR_RNP_PREV="${DFILT}/${NJOB}_1_${IB}_SORTED_DLCUMGTAAR_RNP_PREV.dat"
export ESTJ0010_SORTED_FUTURE_RP_PREV="${DFILT}/${NJOB}_1_${IB}_SORTED_FUTURE_RP_PREV.dat"
export ESTJ0010_SORTED_FUTURE_RNP_PREV="${DFILT}/${NJOB}_1_${IB}_SORTED_FUTURE_RNP_PREV.dat"
export ESTJ0010_SORTED_FLOARAT="${DFILT}/${NJOB}_1_${IB}_SORTED_FLOARAT.dat"
export ESTJ0010_SORTED_DLSGTAR="${DFILT}/${NJOB}_1_${IB}_SORTED_DLSGTAR.dat"


# outputs files
export ESTJ0010_ACC_NDIC_COMPUTATION="${EST_ACC_RETRO_NDIC_AMOUNT}"
export ESTJ0010_RETRO_TC_NDIC_COMPUTATION="${EST_RETRO_TC_NDIC_COMPUTATION}"

# CMD variable
export SYNCSORT_CMD_ESTJ0010_SORT_PERICASE_A_BY_CSUOE=${DCMD}/ESTS0003.cmd
export SYNCSORT_CMD_ESTJ0010_SORT_PERICASE_R_BY_CSUOER=${DCMD}/ESTS0020.cmd
export SYNCSORT_CMD_ESTJ0010_SORT_NCB_BY_CSUOER=${DCMD}/ESTS0033.cmd
export SYNCSORT_CMD_ESTJ0010_SORT_FPLC_BY_CSUOER=${DCMD}/ESTS0040.cmd
export SYNCSORT_CMD_ESTJ0010_SORT_FCES_BY_CSUOE=${DCMD}/ESTS0041.cmd
export SYNCSORT_CMD_ESTJ0010_SORT_PERICASE_EXTENDED_BY_CSUOER=${DCMD}/ESTS0021.cmd
export SYNCSORT_CMD_ESTJ0010_SORT_PERICASE_EXTENDED_BY_FULL_KEY=${DCMD}/ESTS0039.cmd
export SYNCSORT_CMD_ESTJ0010_SORT_AUTO_RETRO_BY_FULL_KEY=${DCMD}/ESTS0037.cmd
export SYNCSORT_CMD_ESTJ0010_SORT_DLCUMGTAAR_BY_FULL_KEY=${DCMD}/ESTS0047.cmd
export SYNCSORT_CMD_ESTJ0010_SORT_FUTURE_BY_FULL_KEY=${DCMD}/ESTS0050.cmd
export SYNCSORT_CMD_ESTJ0010_SORT_FLOARAT_BY_CSUOE=${DCMD}/ESTS0027.cmd
export SYNCSORT_CMD_ESTJ0010_SORT_DLCUMGTAAR_PREV_BY_FULL_KEY=${DCMD}/ESTS0047.cmd
export SYNCSORT_CMD_ESTJ0010_SORT_FUTURE_PREV_BY_FULL_KEY=${DCMD}/ESTS0050.cmd
export SYNCSORT_CMD_ESTJ0010_SORT_DLSGTAR_BY_FULL_KEY=${DCMD}/ESTS0067.cmd

# Jar execution
JSB_CHAIN="estj0010"
JSB_PARAMS="cloDate=${PARM_ICLODAT_D} prevCloDate=${PARM_PREV_ICLODAT_D} normcf=${NORME_CF_TO_USE} contextCt=${CONTEXT_CT_TO_USE}"
# JSB_JAR_PATH="${DJAVA}/OMEGA-IFRS17-0.0.1-SNAPSHOT.jar"
EXECJSB

NSTEP=${NJOB}_2
#------------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*${IB}*.dat"

JOBEND
