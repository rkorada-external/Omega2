#!/bin/ksh
#=============================================================================
# nom de l'application          : Discount at current and locked in rate calculation 
# nom du script SHELL           : ESFD3620.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 14\02\2019
# auteur                        : Charles SOCIE
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  IFRS17 REQ 11.4 : Discount at current and locked in rate
#
#-----------------------------------------------------------------------------
# historiques des modifications 
#===============================================================================
#[001]
#[002] 29/06/2022 M.NAJI : SPIRA 86220 : Optimisation ESFD3620, remplacement ESFD3621 par ESFD3622 
#[003] 29/06/2022 M.NAJI : SPIRA 86220 : Provisoir pour le TNR activation du job ESFD3621  
#=================================================================================
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

##[003]
#if [ "$PARM_BATCHUSER" != "ubam" ]
#then
#	# Launch applicative job ESFD3621 original (provisoir) 
#	NJOB="ESFD3621${TYPEINV}"
#	${DCMD}/ESFD3621.cmd ${PARM_ICLODAT_D}  2>&1 | ${TEE}
#fi

# Launch applicative job ESFD3622 Discount at current and locked in rate
NJOB="ESFD3622${TYPEINV}"
${DCMD}/ESFD3622.cmd ${PARM_ICLODAT_D}  2>&1 | ${TEE}


CHAINEND