#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS
#                               : 
# nom du script SHELL           : ESTD1010.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 12/10/2000
# auteur                        : Roger Cassis
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#  	Sort of ARCSTATGTR file. 
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd


# Chain Initialization variables
CHAININIT $0 $1

# Launch applicative job ESTD1011
NJOB="ESTD1011"
${DCMD}/ESTD1011.cmd 2>&1 | ${TEE}

CHAINEND

