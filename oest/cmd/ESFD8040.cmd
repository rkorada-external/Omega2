#!/bin/ksh
#=============================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
# Date de creation              : 27/01/2022
# Auteur                        : JYP 
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Description : save granularity product code 
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
#[001] 27/01/2022 JYP : Spira 101782 : creation
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2

NJOB="ESFD9001"
. ${DCMD}/ESFD9001.cmd "${IDF_CT}"


# Launch applicative job ESFD8041
NJOB="ESFD8041"
${DCMD}/ESFD8041.cmd  2>&1 | ${TEE}



CHAINEND
