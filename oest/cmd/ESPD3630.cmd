#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 SOLVENCY - UPR Cancellation
# nom du script SHELL           : ESPD3630.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 28/06/2018
# auteur                        : JYP - PERSEE
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  : SPIRA 069426 : REQ 00.01 - IFRS17- Closing schedule - chain to call UPR cancellation only
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[001] 28/06/2018 chain to call UPR cancellation only
#[002] 11/06/2020 M.NAJI   :spira: 87596 Add IDF_CT and replace ESCD9001 with ESFD9001
#[003] 10/11/2020 M.NAJI   :spira: 91420 Optimisatin , split en 4 jobs et // 3 jobs
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT="$2"

NJOB="ESCD9001_IFRS17"
# Launch applicative job ESCD9001
. ${DCMD}/ESFD9001.cmd "$IDF_CT"  

NSTEP=${NJOB}_450
LIBEL="Erase temporary files"
RMFIL "${DFILT}/*ESPO3630*.dat"

# Launch applicative job ESPD3631 UPR Cancellation
NJOB="ESPD3631${TYPEINV}"
${DCMD}/ESPD3631.cmd ${PARM_CRE_D} ${PARM_INVCONSO_D} ${TYPEINV} 2>&1 | ${TEE}



PARALLEL_JOB_INIT 3


# Launch applicative job ESPD3632 UPR Cancellation
NJOB="ESPD3632${TYPEINV}"
PARALLEL_JOB "${DCMD}/ESPD3632.cmd ${PARM_CRE_D} ${PARM_INVCONSO_D} ${TYPEINV} "


# Launch applicative job ESPD3633 UPR Cancellation
NJOB="ESPD3633${TYPEINV}"
PARALLEL_JOB "${DCMD}/ESPD3633.cmd ${PARM_CRE_D} ${PARM_INVCONSO_D} ${TYPEINV}  "


# Launch applicative job ESPD3634 UPR Cancellation
NJOB="ESPD3634${TYPEINV}"
PARALLEL_JOB "${DCMD}/ESPD3634.cmd ${PARM_CRE_D} ${PARM_INVCONSO_D} ${TYPEINV} " 

PARALLEL_JOB_END

CHAINEND
