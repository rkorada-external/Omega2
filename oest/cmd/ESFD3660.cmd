#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD3660.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 26\06\2019
# auteur                        : Antoine GRUNWALD
#-----------------------------------------------------------------------------
# description
#  IFRS17 REQ 11.5 : Forward discount and unwind discount calculation
#
#-----------------------------------------------------------------------------
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
IDF_CT=$2

# Launch job to set context
NJOB="ESFD9001"
. ${DCMD}/ESFD9001.cmd ${IDF_CT}

# Launch applicative job ESFD3662
NJOB="ESFD3662${TYPEINV}"
${DCMD}/ESFD3662.cmd | ${TEE}

# Launch applicative job ESFD3661
NJOB="ESFD3661${TYPEINV}"
${DCMD}/ESFD3661.cmd | ${TEE}

CHAINEND
