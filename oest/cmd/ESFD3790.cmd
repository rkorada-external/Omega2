#!/bin/ksh
#=================================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD3790.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 10\12\2019
# auteur                        : Cyril AVINENS
#---------------------------------------------------------------------------------
# description
#  IFRS17 REQ 12.11 : Net position indicator calculation
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

# Launch applicative job ESFD3791
NJOB="ESFD3791${TYPEINV}"
${DCMD}/ESFD3791.cmd | ${TEE}

CHAINEND