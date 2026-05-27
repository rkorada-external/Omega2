#!/bin/ksh
#=============================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
# Date de creation              : 24/01/2022
# Auteur                        : JYP 
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Description : granularity product code 
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
#[001] 24/01/2022 JYP : Spira 101782 : creation
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2
BOOKED_OPT="$3"

NJOB="ESFD9001"
. ${DCMD}/ESFD9001.cmd "${IDF_CT}"


# Launch applicative job ESFD0041
NJOB="ESFD0041"
${DCMD}/ESFD0041.cmd "$BOOKED_OPT"  2>&1 | ${TEE}


# Launch applicative job ESFD0042
NJOB="ESFD0042"
${DCMD}/ESFD0042.cmd  2>&1 | ${TEE}



CHAINEND
