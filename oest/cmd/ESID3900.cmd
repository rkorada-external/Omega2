#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESID3900.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 13/07/1999
# auteur                        : ASCOTT
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#   Generation of Infocenter tables
#
# Launch applicative jobs ESCD9001 ESID3901 3902
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 25/05/2012 Roger Cassis :spot:23802 - refonte entiere pour Solvency
#[002] 29/06/2021 Mehdi NAJI : SPIRA 91532 supression du bloc avec la condition EST_ESID2000_COND1
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
# ${EST_PARAM} is a global environment variable
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
ICLODAT_D=$7
CLODAT_D=$8

OPTION='I'

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

# Launch applicative job ESID3901
NJOB="ESID3901I"
${DCMD}/ESID3901.cmd ${OPTION} ${CRE_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${ICLODAT_D} IFRS 2>&1 | ${TEE}
i
#[002]
#if [ "${EST_ESID2000_COND1}" = "Y" ]     # option EBS ?
#then
#
#	# Launch applicative job ESID3901
#	NJOB="ESID3901E"
#	${DCMD}/ESID3901.cmd ${OPTION} ${CRE_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${ICLODAT_D} EBS 2>&1 | ${TEE}
#
#fi

# Launch applicative job ESID3901
NJOB="ESID3902"
${DCMD}/ESID3902.cmd 2>&1 | ${TEE}

CHAINEND
