#!/bin/ksh
#=============================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 update product code 
# Auteur                        : JYP/TD
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Description
#
#  - BDA- Impact on Omega closing
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
#[001] 14/02/2022 JYP : Spira 101831 : update product code on local
#[002] 25/02/2022 JYP : Spira 101831 : update product code and gaap_code on local
#[003] 03/02/2023 JYP : Spira 108760 : add defaulting products for local
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2

# Get entry parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
ICLODAT_D=$7
CLODAT_D=$8
CONSOYEA=${22}
CONSOMTH=${23}
export PARM_BATCHUSER=${31}
BLCSHTYEALOC_NF=${36}
BLCSHTMTHLOC_NF=${37}

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs0} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}


#======= GAAP CODES ===============
NJOB="ESFD3811_ESL_FTECLEDALO"
${DCMD}/ESFD3811.cmd ${ESL_FTECLEDALO} ${EST_GAAPCOD_MAPPING} 2>&1 | ${TEE}

NJOB="ESFD3811_ESL_FTECLEDALO_MTH"
${DCMD}/ESFD3811.cmd ${ESL_FTECLEDALO_MTH} ${EST_GAAPCOD_MAPPING} 2>&1 | ${TEE} 


NJOB="ESFD3811_ESL_FTECLEDALO_MVT"
${DCMD}/ESFD3811.cmd ${ESL_FTECLEDALO_MVT} ${EST_GAAPCOD_MAPPING} 2>&1 | ${TEE}


NJOB="ESFD3813_ESL_FTECLEDRLO"
${DCMD}/ESFD3813.cmd ${ESL_FTECLEDRLO} ${EST_GAAPCOD_MAPPING} 2>&1 | ${TEE}

#======= PRODUCT CODES ===============

NJOB="ESFD3819_FTECLEDALO"
${DCMD}/ESFD3819.cmd ${ESL_FTECLEDALO} ${ESF_FCTRI17PRD_NEW}  2>&1 | ${TEE}

NJOB="ESFD3819_FTECLEDALO_MTH"
${DCMD}/ESFD3819.cmd ${ESL_FTECLEDALO_MTH} ${ESF_FCTRI17PRD_NEW}  2>&1 | ${TEE}

NJOB="ESFD3819_FTECLEDALO_MVT"
${DCMD}/ESFD3819.cmd ${ESL_FTECLEDALO_MVT} ${ESF_FCTRI17PRD_NEW}  2>&1 | ${TEE}


# Launch applicative job ESFD3818_FTECLEDR_MVT
NJOB="ESFD3818_FTECLEDRLO"
${DCMD}/ESFD3818.cmd ${ESL_FTECLEDRLO} ${ESF_FCTRI17PRD_NEW}  2>&1 | ${TEE}


#======= PRODUCT CODES DEFAULTING ===============

# Launch applicative job ESFD3949
NJOB="ESFD3949_FTECLEDALO_MVT"
${DCMD}/ESFD3949.cmd ${ESL_FTECLEDALO_MVT} ${ESF_FCTRI17PRD_NEW} 2>&1 | ${TEE}


CHAINEND
