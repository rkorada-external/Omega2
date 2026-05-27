#!/bin/ksh
#=============================================================================
# nom de l'application          : Portfolio/Sub-Portfolio Fetching
# nom du script SHELL           : ESEJ2060.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 09/10/2020
# auteur                        : KBagwe
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  : SPIRA 88477  : Portfolio/Sub-Portfolio Fetching
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


# Launch applicative job ESEJ2061
NJOB="ESEJ2061"
${DCMD}/ESEJ2061.cmd  2>&1 | ${TEE}


CHAINEND