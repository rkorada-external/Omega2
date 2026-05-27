#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD3921.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 18\06\2020
# auteur                        : KBagwe
#-----------------------------------------------------------------------------
# description
#  undiscounted NDIC (Non-Distinct Investment Component) base amounts calculation
#
#-----------------------------------------------------------------------------
# modif
# [01] 18/09/2020 C.SOCIE	SPIRA 88615 : LOCAL- change in NDIC batch architecture add new input ESF_DLDGTAA_NDIC
# [02] 01/04/2021 CAS 		SPIRA 94906 : NDI at closing - Change in VTOM
# [03] 28/01/2022 Bhimasen 	SPIRA 98794 : NDIC- curency issue
# [04] 08/22/2022 J.B-D 	SPIRA 106362 : Add [ IDF_CT = "I17G_ESFD3920"]
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctjsb.cmd

# Job Initialisation
JOBINIT

# Get input parameters
ECHO_LOG "#======================================================================"
ECHO_LOG "#===> ICLODAT_D........................................................: ${PARM_ICLODAT_D}"
if [ ${NORME_CF} = "EBS" ] || [ ${IDF_CT} = "I17G_ESFD3920" ]
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
ECHO_LOG "#===> EST_IADPERICASE_FILTERED.........................................: ${EST_IADPERICASE_FILTERED}"
ECHO_LOG "#===> EPO_FCURQUOT_TXT.................................................: ${EPO_FCURQUOT_TXT}"
ECHO_LOG "#===> ESF_GTSII_GLOBAL_CASHFLOW........................................: ${ESF_GTSII_GLOBAL_CASHFLOW}"
ECHO_LOG "#===> EST_NDIC_FLOARAT.................................................: ${EST_NDIC_FLOARAT}"
ECHO_LOG "#===> ESF_NDIC_NCB.....................................................: ${ESF_NDIC_NCB}"
ECHO_LOG "#===> EST_DLCUMGTAAR...................................................: ${EST_DLCUMGTAAR}"
ECHO_LOG "#===> EST_DLCUMGTAAR_PREV..............................................: ${EST_DLCUMGTAAR_PREV}"
ECHO_LOG "#===> ESF_GTSII_GLOBAL_CASHFLOW_PREV...................................: ${ESF_GTSII_GLOBAL_CASHFLOW_PREV}"
ECHO_LOG "#===> ESF_DLSGTAA_FILTERED.............................................: ${ESF_DLSGTAA_FILTERED}"

ECHO_LOG "#===> ............ OUTPUT ............................................."
ECHO_LOG "#===> EST_ACC_NDIC_AMOUNT..............................................: ${EST_ACC_NDIC_AMOUNT}"

ECHO_LOG "#======================================================================"

NSTEP=${NJOB}_0
#------------------------------------------------------------------------------
# inputs files
export ESTJ0008_CONTRACT_PERICASE="${EST_IADPERICASE_FILTERED}"
export ESTJ0008_NCB="${ESF_NDIC_NCB}"
export ESTJ0008_CURRENCY_EX_RATE="${EPO_FCURQUOT_TXT}"
export ESTJ0008_FUTURE="${ESF_GTSII_GLOBAL_CASHFLOW}"
export ESTJ0008_FLOARAT="${EST_NDIC_FLOARAT}"
export ESTJ0008_DLCUMGTAAR="${EST_DLCUMGTAAR}"
export ESTJ0008_DLCUMGTAAR_PREV="${EST_DLCUMGTAAR_PREV}"
export ESTJ0008_FUTURE_PREV="${ESF_GTSII_GLOBAL_CASHFLOW_PREV}"
export ESTJ0008_DLSGTAA="${ESF_DLSGTAA_FILTERED}"

# tmp files
export ESTJ0008_SORTED_FUTURE="${DFILT}/${NJOB}_1_${IB}_SORTED_FUTURE.dat"
export ESTJ0008_SORTED_CONTRACT_PERICASE="${DFILT}/${NJOB}_1_${IB}_SORTED_CONTRACT_PERICASE.dat"
export ESTJ0008_SORTED_FLOARAT="${DFILT}/${NJOB}_1_${IB}_SORTED_FLOARAT.dat"
export ESTJ0008_SORTED_NCB="${DFILT}/${NJOB}_1_${IB}_SORTED_NCB.dat"
export ESTJ0008_SORTED_DLCUMGTAAR="${DFILT}/${NJOB}_1_${IB}_SORTED_DLCUMGTAAR.dat"
export ESTJ0008_SORTED_DLCUMGTAAR_PREV="${DFILT}/${NJOB}_1_${IB}_SORTED_DLCUMGTAAR_PREV.dat"
export ESTJ0008_SORTED_FUTURE_PREV="${DFILT}/${NJOB}_1_${IB}_SORTED_FUTURE_PREV.dat"
export ESTJ0008_SORTED_DLSGTAA="${DFILT}/${NJOB}_1_${IB}_SORTED_DLSGTAA.dat"

# outputs files
export ESTJ0008_ACC_NDIC_COMPUTATION=${EST_ACC_NDIC_AMOUNT}

# CMD variable
export SYNCSORT_CMD_ESTJ0008_SORT_CONTRACT_PERICASE_BY_CTR_ID=${DCMD}/ESTS0003.cmd
export SYNCSORT_CMD_ESTJ0008_SORT_FUTURE_BY_CTR_ID=${DCMD}/ESTS0004.cmd
export SYNCSORT_CMD_ESTJ0008_SORT_FLOARAT_BY_CTR_ID=${DCMD}/ESTS0027.cmd
export SYNCSORT_CMD_ESTJ0008_SORT_NCB_BY_CTR_ID=${DCMD}/ESTS0033.cmd
export SYNCSORT_CMD_ESTJ0008_SORT_DLCUMGTAAR_BY_CTR_ID=${DCMD}/ESTS0046.cmd
export SYNCSORT_CMD_ESTJ0008_SORT_DLCUMGTAAR_PREV_BY_CTR_ID=${DCMD}/ESTS0046.cmd
export SYNCSORT_CMD_ESTJ0008_SORT_FUTURE_PREV_BY_CTR_ID=${DCMD}/ESTS0004.cmd
export SYNCSORT_CMD_ESTJ0008_SORT_DLSGTAA_BY_CTR_ID=${DCMD}/ESTS0066.cmd


# Jar execution
JSB_CHAIN="estj0008"
JSB_PARAMS="cloDate=${PARM_ICLODAT_D} prevCloDate=${PARM_PREV_ICLODAT_D} normcf=${NORME_CF_TO_USE} contextCt=${CONTEXT_CT_TO_USE}"
# JSB_JAR_PATH="${DJAVA}/OMEGA-IFRS17-0.0.1-SNAPSHOT.jar"
EXECJSB

NSTEP=${NJOB}_1
#------------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*${IB}*_SORTED_*.dat"

JOBEND
