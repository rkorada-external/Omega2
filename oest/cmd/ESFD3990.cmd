#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD3990.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 13\01\2021
# auteur                        : NBD
#-----------------------------------------------------------------------------
# description
#  IFRS17 REQ 22.6 : Annual limit flag 
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

# Launch applicative job ESFD3991 Putflag for the annual limit 
NJOB="ESFD3991${TYPEINV}"
${DCMD}/ESFD3991.cmd 2>&1 | ${TEE}

CHAINEND
