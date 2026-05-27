#!/bin/ksh
#=============================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 EBS : Spira 107203
# Revision                      : $Revision:   1.0  $
# Date de creation              : 18/10/2022
# Auteur                        : HR
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Description
# 
#  - BDA- Impact on Omega closing
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
#[001] 18/07/2023 : JYP/TD : SPIRA 109764: manage NEWCOLS1_NF=CRE_D, GEMPRMPAY_NF=empty, other SAP fields empty
#[002] 15/12/2023 : JYP    : SPIRA 110086: new SAP filter based on SAP table
#[003] 15/01/2025 : JYP    : SPIRA 112324: rounding estimates amounts calculations 
#[004] 05/03/2025 : JYP    : SPIRA 112324: rounding estimates amounts calculations 
#[005] 03/04/2025 : JYP    : SPIRA 112324: rounding estimates amounts calculations
#[006] 22/07/2025 : JYP    : US 5559 spira 113075 : SERQS split files by site
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Recupere les parametres d'entree
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$5
DBCLO_D=$6
CLODAT_D=$7
INVCONSO_D=${21}
CONSOYEA=${22}
CONSOMTH=${23}
BLCSHTYEALOC_NF=${36}
BLCSHTMTHLOC_NF=${37}
export EST_SORT_CONDITION_AS=`grep EST_SORT_CONDITION_AS $EST_PARAM | cut -d"'" -f2 `
export EST_SORT_CONDITION_EU=`grep EST_SORT_CONDITION_EU $EST_PARAM | cut -d"'" -f2 `
export EST_SORT_CONDITION_AM=`grep EST_SORT_CONDITION_AM $EST_PARAM | cut -d"'" -f2 `

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}


#------------- get parameter SAP activated or not -----
set `GETPRM ${DPRM}/SAP_I4I_ENV.prm`

if [[ "${SRV}" = "PRD_TPO2" ]]
then
        export ENV_SAP=${1}
else
        export ENV_SAP=${2}
fi
export SAP_GAAPFILTER_FLAG=`grep -v "#" ${DPRM}/ESLD3910_SAPGAAPFILTER.prm | grep "^LOCAL " | cut -d" " -f2 `

set `GETPRM ${DPRM}/CLOSING_ROUNDING.prm`
export ROUNDING_FILTER_FLG=${1}
export ROUNDING_APPLY_MAX_AMT=${2}
export ROUNDING_EXCLUDE_LIMIT_AMT=${3}
#-------------------------------------------------------


# Launch applicative job for TL split by site
NJOB="ESFD3935${TYPEINV}"
${DCMD}/ESFD3935.cmd $EPO_FTECLEDASO_MVT $ESF_FTECLEDA_MVT_TOAS $ESF_FTECLEDA_MVT_TOEU $ESF_FTECLEDA_MVT_TOAM  $ESF_FTECLEDA_MVT_FROMAS $ESF_FTECLEDA_MVT_FROMEU $ESF_FTECLEDA_MVT_FROMAM  2>&1 | ${TEE}
 


#----------------- Launch applicative job GAAP_CODE on external files 
PARALLEL_JOB_INIT 2

if [ "$DEFAULT_SQL_LOGIN" != "ubas" ]
then
	NJOB="ESFD3811_${NORME_CF}_AS"
	PARALLEL_JOB "${DCMD}/ESFD3811.cmd ${PARAM_DFILPAS}/$ESF_FTECLEDA_MVT_TOAS  ${EPO_GAAPCOD_MAPPING_FROMAS}"
fi 
if [ "$DEFAULT_SQL_LOGIN" != "ubeu" ]
then
	NJOB="ESFD3811_${NORME_CF}_EU"
	PARALLEL_JOB "${DCMD}/ESFD3811.cmd ${PARAM_DFILPEU}/$ESF_FTECLEDA_MVT_TOEU ${EPO_GAAPCOD_MAPPING_FROMEU}"
fi 
if [ "$DEFAULT_SQL_LOGIN" != "ubam" ]
then
	NJOB="ESFD3811_${NORME_CF}_AM"
	PARALLEL_JOB "${DCMD}/ESFD3811.cmd ${PARAM_DFILPAM}/$ESF_FTECLEDA_MVT_TOAM ${EPO_GAAPCOD_MAPPING_FROMAM}"
fi 
PARALLEL_JOB_END


#----------------- Launch applicative job PRD_CODE on external files 
PARALLEL_JOB_INIT 2
if [ "$DEFAULT_SQL_LOGIN" != "ubas" ]
then
	NJOB="ESFD3819_${NORME_CF}_AS"
	PARALLEL_JOB "${DCMD}/ESFD3819.cmd ${PARAM_DFILPAS}/$ESF_FTECLEDA_MVT_TOAS  ${ESF_FCTRI17PRD_FROMAS}"
fi 
if [ "$DEFAULT_SQL_LOGIN" != "ubeu" ]
then
	NJOB="ESFD3819_${NORME_CF}_EU"
	PARALLEL_JOB "${DCMD}/ESFD3819.cmd ${PARAM_DFILPEU}/$ESF_FTECLEDA_MVT_TOEU  ${ESF_FCTRI17PRD_FROMEU}"
fi 
if [ "$DEFAULT_SQL_LOGIN" != "ubam" ]
then
	NJOB="ESFD3819_${NORME_CF}_AM"
	PARALLEL_JOB "${DCMD}/ESFD3819.cmd ${PARAM_DFILPAM}/$ESF_FTECLEDA_MVT_TOAM  ${ESF_FCTRI17PRD_FROMAM}"
fi 
PARALLEL_JOB_END


# Launch applicative job for TL split
 NJOB="ESPD3911${TYPEINV}"
 ${DCMD}/ESPD3911.cmd  2>&1 | ${TEE}

#=== update SAP_FIELDS for ESF_FTECLEDA_DELTA
NJOB="ESFD3932${TYPEINV}"
${DCMD}/ESFD3932.cmd "$CRE_D" "Y" "N" | ${TEE}

# Launch applicative job for rounding split 
NJOB="ESFD3933${TYPEINV}"
${DCMD}/ESFD3933.cmd  | ${TEE}

#=== update SAP_FIELDS for EPO_FTECLEDA_RMN
export ESF_FTECLEDA_DELTA=$EPO_FTECLEDA_RMN 
NJOB="ESFD3932RMN"
${DCMD}/ESFD3932.cmd "$CRE_D" "N" "Y" | ${TEE}

# Launch applicative job for rounding split on RMN
NJOB="ESFD3933${TYPEINV}"
${DCMD}/ESFD3933.cmd  | ${TEE}



CHAINEND
