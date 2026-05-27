#!/bin/ksh
#=============================================================================
# nom de l'application          : Management in cashflow and discount calculation 
# nom du script SHELL           : ESFD3980.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 27\10\2020
# auteur                        : Charles SOCIE
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  IFRS17 SPIRA 87988- IO management in cashflow and discount calculation
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

export EXTCHAIN=${ENV_PREFIX}_3980${NORME_CF}
export EXTCHAIN_SII=${ENV_PREFIX}_3980${NORME_CF}
export NCHAIN=${ENV_PREFIX}_3980${NORME_CF}
export NCHAIN_SHORT=3980${NORME_CF}

NJOB="TEFJ0011SII"
# Launch technical job TEFJ0011 for SII file
# Fetching of TL files from the estimation chain ESID2550 for SII 
${DUTI}/TEFJ0011.cmd 2>&1 | ${TEE}

# Launch applicative job ESFJ0065
# DLEIFTECLEDSIIEI File generation
NJOB="ESFJ0065"
${DCMD}/ESFJ0065.cmd ${TYPEINV} 2>&1 | ${TEE}

# Launch applicative job ESFD3821 Discount at current and locked in rate
NJOB="ESFD3821${TYPEINV}"
${DCMD}/ESFD3821.cmd ${PARM_ICLODAT_D}  2>&1 | ${TEE}

# Launch applicative job ESFD2553
NJOB="ESFD2553"
${DCMD}/ESFD2553.cmd ${TYPEINV} ${NORME} 2>&1 | ${TEE}

export NCHAIN=${ENV_PREFIX}_ESFD3980
export NCHAIN_SHORT=ESFD3980
export EXTCHAIN=${ENV_PREFIX}_ESFD3980
export EXTCHAIN_SII=${ENV_PREFIX}_ESFD3980

CHAINEND