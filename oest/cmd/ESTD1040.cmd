#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS
#                               : 
# nom du script SHELL           : ESTD1040.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 09/11/2000
# auteur                        : Roger Cassis
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#  	Merge of STATGTA file. 
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd


# Chain Initialization variables
CHAININIT $0 $1

# Launch applicative job ESTD1041
NJOB="ESTD1041"
${DCMD}/ESTD1041.cmd 2>&1 | ${TEE}

CHAINEND
