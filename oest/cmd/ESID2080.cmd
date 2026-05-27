#!/bin/ksh
#=============================================================================
# nom de l'application	: ESTIMATIONS - INVENTAIRE
#                       	Inventaire vie
# nom du script SHELL	: ESID2080.cmd 
# revision				: $Revision:   1.0  $
# date de creation		: 30/04/2019
# auteur				: s. behague
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   Life
#   Launch applicative jobs ESCD9001 and ESID2081
#-----------------------------------------------------------------------------
# historique des modifications
# [001] 16/09/2019 S.Behague :spira:81032 [TECH] Cleaning files of Life Closing
# [002] 28/11/2019 M.NAJI :spira:81838 un seul appel au ESID9001 suffit le reste est gÃrÃ©dans la table des mapping
# [003] 07/04/2022 S.Behague :spira:98141 IFRS17 FWH Bookings
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2
export IT=`echo $2 | awk -F"_" '{ print $2 }'`


NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd ${IDF_CT}

# [001] Effacement des anciens fichiers ESID2080
EXECKSH "rm -f ${DFILP}/${NCHAIN}*${PARM_ICLODAT_D}*"


# Launch applicative job ESID2081
NJOB="ESID2081"
${DCMD}/ESID2081.cmd  ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${CLODAT_D} 2>&1 | ${TEE}

CHAINEND
