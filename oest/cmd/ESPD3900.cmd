#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE (ecritures post omega)
# nom du script SHELL           : ESPD3900.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 20/06/2005
# auteur                        : J. Ribot
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Generation of Infocenter tables
#
# Launch applicative jobs ESCD9001 ESID3901 3902
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 31/10/2012 Roger Cassis :spot:24041 - Solvency 2 - test conditions pour lancement EBS
#[002] 22/12/2020 : M.NAJI :. SPIRA 91531 
#							. prise en compte de l'IDF_CT comme 2ème paramètres de la chaine 
#							. remplacement de ESCD9001 par ESPD9001

#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT="$2"
OPTION='I'

NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd "${IDF_CT}"

# Launch applicative job ESPD3901
if [ "${NORME_CF}" = "I4I" ] 
then
	NJOB="ESPD3901IFRS"
	${DCMD}/ESPD3901.cmd ${OPTION} ${PARM_CRE_D} ${PARM_CONSOYEA} 2>&1 | ${TEE}
fi
if [ "${NORME_CF}" = "EBS" ] 
then
	NJOB="ESPD3902EBS"
	${DCMD}/ESPD3902.cmd ${OPTION} ${PARM_CRE_D} ${PARM_CONSOYEA} ${PARM_INVCONSO_D} EBS 2>&1 | ${TEE}
fi

CHAINEND
