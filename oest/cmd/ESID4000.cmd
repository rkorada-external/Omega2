#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Internal Retro
# nom du script SHELL           : ESID4000.cmd
# revision                      : $Revision:   1.1  $
# date de creation              : 15/01/2001
# auteur                        : O.GIRAUX
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  Internal Retro
#-----------------------------------------------------------------------------
# historiques des modifications
#
#  28/09/2004 J. Ribot ajout test sur Variante 7 (STAT REPORTING)
#                      ajout ESCJ0064.cmd        (Retro interne vie)
# [02] 26/11/2012 PPEZOUT :spot:24516 création, ECHANGES INTERNES POST OMEGA
#===============================================================================
#set -x

#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#
# Output files
#
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Recovers input parametrs
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
ICLODAT_D=$7
CLODAT_D=$8


NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

if [ ${EST_VARIANTE} = "7"   ]
then

EXTCHAIN=${EXTCHAIN_LIFE}

# Launch technical job TEFJ0011
NJOB="TEFJ0011"
${DUTI}/TEFJ0011.cmd 2>&1 | ${TEE}

# Launch applicative job ESCJ0064
NJOB="ESCJ0064"
${DCMD}/ESCJ0064.cmd 2>&1 | ${TEE}

CHAINEND

fi

NJOB="TEFJ0011"
# Launch technical job TEFJ0011
# Fetching of TL files from the estimation chain ESID2550
${DUTI}/TEFJ0011.cmd 2>&1 | ${TEE}

# Launch applicative job ESCJ0063
# GTEP File generation
NJOB="ESCJ0063"
${DCMD}/ESCJ0063.cmd INV 2>&1 | ${TEE}

# Launch applicative job ESID4001
# DLRIGTAA File generation
NJOB="ESID4001"
${DCMD}/ESID4001.cmd ${CRE_D} INV 2>&1 | ${TEE}

EXTCHAIN=${EXTCHAIN_LIFE}

# Launch technical job TEFJ0011
NJOB="TEFJ0011"
${DUTI}/TEFJ0011.cmd 2>&1 | ${TEE}

# Launch applicative job ESCJ0064
NJOB="ESCJ0064"
${DCMD}/ESCJ0064.cmd 2>&1 | ${TEE}


CHAINEND
