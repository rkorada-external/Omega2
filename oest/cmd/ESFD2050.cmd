#!/bin/ksh
#=============================================================================
# nom de l'application          : Illiquidity : Extract ILL Bucket by CSUOE
# nom du script SHELL           : ESFD2050.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 21/09/2021
# auteur                        : JYP - PERSEE
# references des specifications : Illiquidity
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[001] 21/09/2021 : SPIRA 97283: JYP : Illiquidity - Extract ILL Bucket by CSUOE
#===============================================================================
# set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1


# Launch applicative job ESFD2050
NJOB="ESFD2051"
${DCMD}/ESFD2051.cmd  2>&1 | ${TEE}


CHAINEND