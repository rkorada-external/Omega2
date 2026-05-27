#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESID2020.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 22/06/2004
# auteur                        : J.Ribot
# references des specifications : ESID2020.doc
#-----------------------------------------------------------------------------
# description
#   Generation of the acceptance TL for retrocessionnaire subsidiaries
#
# Launch applicative jobs ESCD9001 ESID2021 2022
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
ICLODAT_D=$7
CLODAT_D=$8
RETTHRESHOLD_R=${15}

# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

# # Launch applicative job ESID2021
# NJOB="ESID2021"
# ${DCMD}/ESID2021.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${RETTHRESHOLD_R} ${CRE_D} ${DBCLO_D} 2>&1 | ${TEE}

# Launch applicative job ESID2022
NJOB="ESID2022"
${DCMD}/ESID2022.cmd 2>&1 | ${TEE}

CHAINEND

