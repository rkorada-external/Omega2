#!/bin/ksh
#=============================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 EBS : Spira 88638
# Revision                      : $Revision:   1.0  $
# Date de creation              : 06/10/2020
# Auteur                        : Linh.DOAN
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Description
# 
#  - BDA- Impact on Omega closing
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
#       <indice>        <jj/mm/aaaa>    <auteur>        <spira>                 <description de la modification>
#       [001]           07/10/2020      Linh DOAN      88638 			SAP feedback
#       [002]           18/09/2023      JYP            110487 			clean SAP fields for remain file
#       [003]           15/12/2023      JYP            110086 			new SAP filter based on SAP table
#       [004]           03/04/2025      JYP            112324           rounding estimates amounts calculations
#       [005]           09/07/2025      JYP            113075 			SERQS split files by site
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2

  
NJOB="ESFD9001"
# Launch job to set context
. ${DCMD}/ESFD9001.cmd "${IDF_CT}" 


#------------- get parameter SAP -----
if [ "$NORME_CF" = "I4I" ]
then 
   set `GETPRM ${DPRM}/SAP_I4I_ENV.prm`
else 
   set `GETPRM ${DPRM}/SAP_ENV.prm`
fi 

if [[ "${SRV}" = "PRD_TPO2" ]]
then
        export ENV_SAP=${1}
else
        export ENV_SAP=${2}
fi

export SAP_GAAPFILTER_FLAG=`grep -v "#" ${DPRM}/ESPD3910_SAPGAAPFILTER.prm | grep "^${NORME_CF} " | cut -d" " -f2 `

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

# Launch applicative job for TL split
NJOB="ESFD3932${TYPEINV}"
${DCMD}/ESFD3932.cmd  "$CRE_D" "N" "Y" 2>&1 | ${TEE}

# Launch applicative job for rounding split 
NJOB="ESFD3933${TYPEINV}"
${DCMD}/ESFD3933.cmd  | ${TEE}

 

CHAINEND
