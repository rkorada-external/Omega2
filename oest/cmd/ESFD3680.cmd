#!/bin/ksh
#=============================================================================
# nom de l'application          : Merge RAD and RAP
# nom du script SHELL           : ESFD3680.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 01\11\2024
# auteur                        : David Teixeira
# references des specifications :
#-----------------------------------------------------------------------------
# description
#
#-----------------------------------------------------------------------------
# historiques des modifications 
#===============================================================================
#=================================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
IDF_CT=$2

NJOB="ESFD9001"
# Launch job to set context
. ${DCMD}/ESFD9001.cmd  ${IDF_CT}


# Launch applicative job ESFD3681
NJOB="ESFD3681"
${DCMD}/ESFD3681.cmd 2>&1 | ${TEE}


CHAINEND