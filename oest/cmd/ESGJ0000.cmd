#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESGJ000.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 16/07/2025
# auteur                        : M.NAJI
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#   
#-----------------------------------------------------------------------------
# historiques des modifications

#===============================================================================
#set -x



# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1



# Launch job ESGD001
NJOB="ESGD001"
${DCMD}/ESGJ0001.cmd  2>&1 | ${TEE}

CHAINEND
