#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE Internal Retro
# nom du script SHELL           : ESPD2050.cmd
# revision                      : $Revision:   1.0 $
# date de creation              : 02/11/2015
# auteur                        : PPEZOUT
# references des specifications : :spot:29615 EST45 gestion des doubles bouclettes RETRO
#-----------------------------------------------------------------------------
# description: Internal Retro
#-----------------------------------------------------------------------------
# historiques des modifications
# [001] 22/12/2020 M.NAJI :	. SPIRA 91531 
#							. suppression du ESPD2052 qui n'existe pas
#							. Ajout de l'IDF_CT
#							. remplacer le ESCD9001 pas le ESPD9001 
# [002] 17/05/2021 JYP : SPIRA 91513 : regression EBS OI/AI files 
# [003] 27/12/2021 M.NAJI: SPIRA 101295 add norme to prefix of chain
#===============================================================================
#set -x

#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#
# Output files
#
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2

NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd "${IDF_CT}"

export NCHAIN=${ENV_PREFIX}_ESPD2050${NORME_CF}

if [ "${EST_ESPD2550_COND3}" = "Y" ]
then
	# Launch applicative job ESID2552 if no Request F (not the last day of Social Post Omega)
	NJOB="ESPD2552"
	${DCMD}/ESID2552.cmd ${TYPEINV} ${NORME_CF} 2>&1 | ${TEE}

	# Launch applicative job ESID2552 if no Request F (not the last day of Social Post Omega)
	NJOB="ESPD2553"
	${DCMD}/ESID2553.cmd ${TYPEINV} ${NORME_CF} 2>&1 | ${TEE}
fi

CHAINEND
