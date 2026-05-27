#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS
#                               :
# nom du script SHELL           : ESTD1050.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 15/03/2001
# auteur                        : Roger Cassis
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  	Sort of ARCSTATGTA file.
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd


# Chain Initialization variables
CHAININIT $0 $1

# Launch applicative job ESTD1051
NJOB="ESTD1051"
${DCMD}/ESTD1051.cmd 2>&1 | ${TEE}

CHAINEND
