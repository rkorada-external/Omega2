#!/bin/ksh
#=================================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD3780.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 26\02\2020
# auteur                        : Antoine GRUNWALD
#---------------------------------------------------------------------------------
# description
#  IFRS17 REQ 12.10 : CSM/LC Booking calculation
#
#---------------------------------------------------------------------------------
#=================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
IDF_CT=$2

# Launch job to set context
NJOB="ESFD9001"
. ${DCMD}/ESFD9001.cmd ${IDF_CT}

# Launch applicative job ESFD3781
NJOB="ESFD3781${TYPEINV}"
${DCMD}/ESFD3781.cmd | ${TEE}

CHAINEND