#!/bin/ksh
#=============================================================================
# nom de l'application          : I17G 
# nom du script SHELL           : 
# revision                      : $Revision:   1.0  $
# date de creation              : 08/09/2020
# auteur                        : Nicolas BRIAND
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  IFRS17 REQ , SAP posting
#-----------------------------------------------------------------------------
#[001] 14/06/2023 JYP/TD : spira 109764: update NEWCOLS1_NF=DBCLO_D, GEMPRMPAY_NF=empty 
#[002] 18/07/2023 JYP/TD : SPIRA 109764: update NEWCOLS1_NF=CRE_D instead of DBCLO_D
#[003] 15/01/2025 JYP    : spira 112324 : rounding estimates amounts calculations
#[004] 03/04/2025 JYP    : spira 112324 : rounding estimates amounts calculations  
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
IDF_CT=$2

# Launch job to set context
NJOB="ESFD9001"
. ${DCMD}/ESFD9001.cmd ${IDF_CT}

set `GETPRM ${DPRM}/CLOSING_ROUNDING.prm`
export ROUNDING_FILTER_FLG=${1}
export ROUNDING_APPLY_MAX_AMT=${2}
export ROUNDING_EXCLUDE_LIMIT_AMT=${3}

# Launch applicative job ESFD3931
NJOB="ESFD3931${TYPEINV}"
${DCMD}/ESFD3931.cmd | ${TEE}

NJOB="ESFD3933${TYPEINV}"
${DCMD}/ESFD3933.cmd  | ${TEE}

NJOB="ESFD3932${TYPEINV}"
${DCMD}/ESFD3932.cmd "$CRE_D" "N" "N" | ${TEE}


CHAINEND