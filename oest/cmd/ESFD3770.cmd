#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD3770.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 20\11\2019
# auteur                        : Antoine GRUNWALD
#-----------------------------------------------------------------------------
# description
#  IFRS17 REQ 12.8 : CSM/LC amortization pattern calculation
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

# Launch applicative job ESFD3771
NJOB="ESFD3771${TYPEINV}"
${DCMD}/ESFD3771.cmd | ${TEE}

CHAINEND