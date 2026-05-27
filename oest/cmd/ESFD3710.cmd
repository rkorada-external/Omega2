#!/bin/ksh
#=============================================================================
# nom de l'application          : Initial profitability at CSUOE level
# nom du script SHELL           : ESFD3710.cmd
# revision                      : $Revision:   1.0
# date de creation              : 24/07/2019
# auteur                        : Rafael Vieville
# references des specifications :
#-----------------------------------------------------------------------------
# description:
#	"http://dcvprdxwikiu/xwiki/wiki/omega/view/DEV/BPR-EST-909027"
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2

NJOB="ESFD9001"
# Launch job to set context
. ${DCMD}/ESFD9001.cmd "${IDF_CT}"

# Launch applicative job ESFD3711 Discount at current and locked in rate
NJOB="ESFD3711"
${DCMD}/ESFD3711.cmd 2>&1 | ${TEE}

CHAINEND
