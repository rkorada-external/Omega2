#!/bin/ksh
#=============================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 DELTA posting ,  update product code 
# Revision                      : $Revision:   1.0  $
# Date de creation              : 19/01/2022
# Auteur                        : JYP/TD/Roger
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Description
#
#  - BDA- Impact on Omega closing
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
#[001] 19/01/2022 JYP : Spira 96729 : DELTA posting ,  update product code 
#[002] 07/02/2023 JYP : Spira 108760: override empty product code 
#[003] 10/02/2023 JYP : Spira 108760: override empty product code 
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2

NJOB="ESFD9001"
. ${DCMD}/ESFD9001.cmd "${IDF_CT}"


# Launch applicative job ESID3821$TYPEINV 
NJOB="ESID3821${TYPEINV}"
${DCMD}/ESID3821.cmd  2>&1 | ${TEE}


NJOB="ESFD3819$TYPEINV"
${DCMD}/ESFD3819.cmd ${EST_FTECLEDA_MVT_QTD_TMP} ${ESF_FCTRI17PRD} "ALL" 2>&1 | ${TEE}


# Launch applicative job ESFD3949
NJOB="ESFD3949_FTECLEDA_MVT_QTD"
${DCMD}/ESFD3949.cmd ${EST_FTECLEDA_MVT_QTD_TMP} ${ESF_FCTRI17PRD} 2>&1 | ${TEE}


# Launch applicative job ESID3822$TYPEINV 
NJOB="ESID3822${TYPEINV}"
${DCMD}/ESID3822.cmd  2>&1 | ${TEE}



CHAINEND
