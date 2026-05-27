#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS
#              			: 
# nom du script SHELL           : ESTD1000.cmd
# revision                      : $Revision:   1.0  $
# date de creation              :
# auteur                        : 
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#  	Sort of STATGTA and ARCSTATGTA files. 
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd


# Chain Initialization variables
CHAININIT $0 $1

# Launch applicative job ESTD1001
NJOB="ESTD1001"
${DCMD}/ESTD1001.cmd 2>&1 | ${TEE}

CHAINEND
