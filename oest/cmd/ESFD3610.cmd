#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 - Closing at inception
# nom du script SHELL           : ESFD3610.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 28/08/2019
# auteur                        : JYP - PERSEE
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  : SPIRA 70537 : REQ 11.7 - IFRS17 Closing : cashflow calculation at inception
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[001] 28/08/2019 JYP : SPIRA 70537 : REQ 11.7 - IFRS17 Closing : cashflow calculation at inception
#[002] 21/07/2020 LEL : SPIRA 84240 : CSF - TRANSITION MODE
#[003] 27/02/2021 M.NAJI: SPIRA 93531 ajout des quotes dans le if
#[004] 19/08/2021 JYP : SPIRA 92591: AE at inception 
#[005] 08/09/2023 MZM : SPIRA 109430 IO DUM : MERGE CASHFLOWS PREVIOUS DUMMY AND NEW CASHFLOW DUMMY 
#===============================================================================
#set -x

IDF_CT=$2
TRN_FLAG=$3

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1



NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd ${IDF_CT}

if [ "$CONTEXT_CT" = "INI" ]
then 
# Launch applicative job ESFD3614 : AE at inception
NJOB="ESFD3614${TYPEINV}"
${DCMD}/ESFD3614.cmd  2>&1 | ${TEE} 
fi

# Launch applicative job ESFD3611
NJOB="ESFD3611${TYPEINV}"
${DCMD}/ESFD3611.cmd ${PARM_CONSOYEA} ${PARM_CONSOMTH} ${PARM_INVCONSO_D} ${TYPEINV}  ${IDF_CT}  2>&1 | ${TEE}

	# Launch applicative job ESID3702A Calcul des Cashflow et valeur escompte
	#NJOB="ESID3702A${TYPEINV}"
	#${DCMD}/ESID3702A.cmd  ${PARM_CONSOYEA} ${PARM_CONSOMTH} ${PARM_INVCONSO_D} ${TYPEINV} $IDF_CT ${TRN_FLAG} 2>&1 | ${TEE} 

# Launch applicative job ESFD3612 Calcul des Cashflow et valeur escompte
NJOB="ESFD3612${TYPEINV}"
${DCMD}/ESFD3612.cmd ${PARM_CONSOYEA} ${PARM_CONSOMTH} ${PARM_INVCONSO_D} ${TYPEINV}  ${IDF_CT} 2>&1 | ${TEE}


if [ "${PARM_IS_TRN}" = "YES" ]
then
# Launch TRANSITION job
NJOB="ESFT0004"
${DCMD}/ESFT0004.cmd  2>&1 | ${TEE}
fi

	# Launch applicative job ESID3703A Calcul des Cashflow et valeur escompte
	#NJOB="ESID3703A${TYPEINV}"
	#${DCMD}/ESID3703A.cmd ${PARM_CRE_D} ${PARM_INVCONSO_D} ${TYPEINV} $IDF_CT ${TRN_FLAG} 2>&1 | ${TEE} 

# Launch applicative job ESFD3613 Calcul des Cashflow et valeur escompte
NJOB="ESFD3613${TYPEINV}"
${DCMD}/ESFD3613.cmd ${PARM_CRE_D} ${PARM_INVCONSO_D} ${TYPEINV} ${IDF_CT} 2>&1 | ${TEE}



CHAINEND
