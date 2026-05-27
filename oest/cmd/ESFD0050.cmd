#!/bin/ksh
#=============================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
# Date de creation              : 08/11/2023
# Auteur                        : JYP 
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Description : granularity product code 
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
#[001] 08/11/2023 JYP : Spira 110086 : creation
#[002] 15/12/2023 JYP : Spira 110086 : manage prm
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

export IDF_CT=$2


NJOB="ESFD9001"
. ${DCMD}/ESFD9001.cmd "${IDF_CT}"

#------------- get parameter SAP -----
set `GETPRM ${DPRM}/SAP_I4I_ENV.prm`
if [[ "${SRV}" = "PRD_TPO2" ]]
then
        export ENV_SAP_I4I=${1}
else
        export ENV_SAP_I4I=${2}
fi
set `GETPRM ${DPRM}/SAP_ENV.prm`
if [[ "${SRV}" = "PRD_TPO2" ]]
then
        export ENV_SAP_NotI4I=${1}
else
        export ENV_SAP_NotI4I=${2}
fi
#-------------------------------------------------------


# Launch applicative job ESFD0041
NJOB="ESFD0051"
${DCMD}/ESFD0051.cmd  2>&1 | ${TEE}



CHAINEND
