#!/bin/ksh
#=============================================================================
# nom de l'application          : DIP/OMEGA interface
# nom du script SHELL           : ESEJ2080.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 06/04/2021
# auteur                        : Bhimasen Karri
# references des specifications :
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#
#===============================================================================
# set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1


# Launch applicative job ESEJ2081
NJOB="ESEJ2081"
${DCMD}/ESEJ2081.cmd  2>&1 | ${TEE}


CHAINEND