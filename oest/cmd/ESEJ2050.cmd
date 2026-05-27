#!/bin/ksh
#=============================================================================
# nom de l'application          : 1.04 
#                                 Batch MAIN IFRS17 LOB
# nom du script SHELL           : ESEJ2050.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 02/04/2019
# auteur                        : Charles SOCIE
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  : SPIRA 71007  : REQ 1.04 - IFRS17: batch to calculate Main LOB and Main EGPI
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[001]
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1


# Launch applicative job ESEJ2051
NJOB="ESEJ2051"
${DCMD}/ESEJ2051.cmd  2>&1 | ${TEE}


CHAINEND




















