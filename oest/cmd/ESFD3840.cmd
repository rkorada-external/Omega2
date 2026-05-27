#!/bin/ksh
#=============================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Spira BDA : Merge GTL files from EBS and IFRS17
# Nom du script SHELL           : ESFD3840.cmd
# Revision                      : $Revision:   1.0  $
# Date de creation              : 05/05/2020
# Auteur                        : Linh.DOAN
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Description
# Merge cashflow and discount files
#  - filtre  Maintenance Expenses cashflow 
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
#       <indice>        <jj/mm/aaaa>    <auteur>        <spira>                 <description de la modification>
#       [001]           05/05/2020      Linh DOAN      xxxx 			Merge GLT files  from EBS and IFRS17
#       [002]           16/12/2021      Mr JYP        SPIRA 101025  override I17PRODCOD_CT code before RA
#       [003]           25/02/2025      Mr JYP        SPIRA 112324  rounding estimates amounts calculations
#       [004]           05/04/2025      Mr JYP        SPIRA 112324  rounding estimates amounts calculations
#       [005]           29/07/2025      Mr JYP        US 5559 spira 113075 : SERQS split files by site
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1


#IDF_CT=I17G_GLT_MRG_STD

IDF_CT=$2




NJOB="ESFD9001"
# Launch job to set context
. ${DCMD}/ESFD9001.cmd ${IDF_CT}

set `GETPRM ${DPRM}/CLOSING_ROUNDING.prm`
export ROUNDING_FILTER_FLG=${1}
export ROUNDING_APPLY_MAX_AMT=${2}
export ROUNDING_EXCLUDE_LIMIT_AMT=${3}


# REQ 08.01 :Merge IFRS17 and EBS GLT files
NJOB="ESFD3841${TYPEINV}"
${DCMD}/ESFD3841.cmd ${IDF_CT}  2>&1 | ${TEE}


NJOB="ESFD3949_I17XA"
${DCMD}/ESFD3949.cmd ${ESF_FTECLEDA_MVT} ${ESF_FCTRI17PRD_NEW} 2>&1 | ${TEE}

# Launch applicative job for rounding split on TTECLEDR
NJOB="ESFD3934_I17XR"
${DCMD}/ESFD3934.cmd  2>&1 | ${TEE}


NJOB="ESFD3936R${TYPEINV}"
${DCMD}/ESFD3936.cmd $ESF_FTECLEDR_MVT  $ESF_FTECLEDR_TOAS $ESF_FTECLEDR_TOEU $ESF_FTECLEDR_TOAM  $ESF_FTECLEDR_FROMAS $ESF_FTECLEDR_FROMEU $ESF_FTECLEDR_FROMAM  2>&1 | ${TEE}

NJOB="ESFD3948_I17XR"
${DCMD}/ESFD3948.cmd ${ESF_FTECLEDR_LOCAL} ${ESF_FCTRI17PRD_NEW} 2>&1 | ${TEE}


#----------------- Launch applicative job GAAP_CODE on external files
PARALLEL_JOB_INIT 2

if [ "$DEFAULT_SQL_LOGIN" != "ubas" ]
then
		NJOB="ESFD3813_${NORME_CF}_AS"
		PARALLEL_JOB "${DCMD}/ESFD3813.cmd ${PARAM_DFILPAS}/${ESF_FTECLEDR_TOAS} ${EPO_GAAPCOD_MAPPING_FROMAS}"
fi
if [ "$DEFAULT_SQL_LOGIN" != "ubeu" ]
then
		NJOB="ESFD3813_${NORME_CF}_EU"
		PARALLEL_JOB "${DCMD}/ESFD3813.cmd ${PARAM_DFILPEU}/${ESF_FTECLEDR_TOEU} ${EPO_GAAPCOD_MAPPING_FROMEU}"
fi
if [ "$DEFAULT_SQL_LOGIN" != "ubam" ]
then
		NJOB="ESFD3813_${NORME_CF}_AM"
		PARALLEL_JOB "${DCMD}/ESFD3813.cmd ${PARAM_DFILPAM}/${ESF_FTECLEDR_TOAM} ${EPO_GAAPCOD_MAPPING_FROMAM}"
fi
PARALLEL_JOB_END


#----------------- Launch applicative job PRD_CODE on external files
PARALLEL_JOB_INIT 2
if [ "$DEFAULT_SQL_LOGIN" != "ubas" ]
then
       NJOB="ESFD3818_${NORME_CF}_AS"
       PARALLEL_JOB "${DCMD}/ESFD3818.cmd ${PARAM_DFILPAS}/${ESF_FTECLEDR_TOAS}  ${ESF_FCTRI17PRD_FROMAS}"	
fi
if [ "$DEFAULT_SQL_LOGIN" != "ubeu" ]
then
       NJOB="ESFD3818_${NORME_CF}_EU"
       PARALLEL_JOB "${DCMD}/ESFD3818.cmd ${PARAM_DFILPEU}/${ESF_FTECLEDR_TOEU}  ${ESF_FCTRI17PRD_FROMEU}"
fi
if [ "$DEFAULT_SQL_LOGIN" != "ubam" ]
then
       NJOB="ESFD3818_${NORME_CF}_AM"
       PARALLEL_JOB "${DCMD}/ESFD3818.cmd ${PARAM_DFILPAM}/${ESF_FTECLEDR_TOAM}  ${ESF_FCTRI17PRD_FROMAM}"
fi
PARALLEL_JOB_END




CHAINEND
 

 
