#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD3970.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 06\10\2020
# auteur                        : NBriand
#-----------------------------------------------------------------------------
# description
#  NDIC Cashflow calculation
#
#-----------------------------------------------------------------------------
#  
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

# Launch applicative job ESFD3971
NJOB="ESFD3971${TYPEINV}"
${DCMD}/ESFD3971.cmd 2>&1 | ${TEE}

CHAINEND

