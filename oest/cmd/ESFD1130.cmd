#!/bin/ksh
#=============================================================================
# nom de l'application          : 11.04 
#                                 Discount at current and locked in rates
# nom du script SHELL           : ESFD1130.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 13/03/2019
# auteur                        : Charles SOCIE
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  : SPIRA 70378  : REQ 11.04 - IFRS17- Closing schedule : Discount at current and locked in rates 
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

# Get entry parameters
IDF_CT=$2

NJOB="ESFD9001"
# Launch job to set context
. ${DCMD}/ESFD9001.cmd  ${IDF_CT}

# Launch applicative job ESFD1131.cmd Discount at current and locked in rates
NJOB="ESFD1131${TYPEINV}"
${DCMD}/ESFD1131.cmd ${PARM_CRE_D} ${PATCAT_CT} ${PARM_BLCSHTYEA_NF} ${TYPEINV} ${PARM_ICLODAT_D} ${PARM_PSTOMGEND17_D} 2>&1 | ${TEE}


CHAINEND




















