#!/bin/ksh
#=============================================================================
# nom de l'application          : Portfolio/Sub-Portfolio per norm to be stored on Life IFRS17 Retro subview.
# nom du script SHELL           : ESEJ2090.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 06/04/2021
# auteur                        : Bhimasen Karri
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  : SPIRA 88568  : IFRS17: RETRO - Level of aggregation - Standard Grouping of external Retro
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[001]
#===============================================================================
# set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1


# Launch applicative job ESEJ2091
NJOB="ESEJ2091"
${DCMD}/ESEJ2091.cmd  2>&1 | ${TEE}


CHAINEND