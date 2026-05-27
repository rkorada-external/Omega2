#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 renommage des fichier EST pour les traitements ecritures post omega
# nom du script SHELL		: ESPT-1_0.cmd
# revision			:
# date de creation		: 09/01/2021
# auteur			: M. NAJI
# references des specifications	: spot 91531
#-----------------------------------------------------------------------------
# description
#   Restore original name of ESPT* filed 
#
#
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2

NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd "${IDF_CT}" 
#set -x
if [ "$3" != ""  ] 
then 
	export CLODAT="$3"
	export PARM_ICLODAT_D="$3"
	export PARM0_ICLODAT_D="$3"
	. $DFILT/${NCHAIN}_${IDF_CT}_${IB}_PERM.dat
fi
set +x 

# Launch applicative job ESPT-1_1
NJOB="ESPT0001"
${DCMD}/ESPT0011.cmd  2>&1 | ${TEE}


CHAINEND

