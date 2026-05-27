#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD4010.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 23\03\2021
# auteur                        : AGD
#-----------------------------------------------------------------------------
# description
#  IFRS17 REQ PAA
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

# Launch applicative job ESFD4011
NJOB="ESFD4011${TYPEINV}"
${DCMD}/ESFD4011.cmd 2>&1 | ${TEE}

CHAINEND
