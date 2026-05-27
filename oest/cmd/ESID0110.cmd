#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESID0110.cmd
# revision                      : $Revision: 1.0 
# date de creation              : 25/03/2015
# auteur                        : Roger cassis
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Generation of Estimates File :spot:28483
#-----------------------------------------------------------------------------
# historiques des modifications
#[xxx] prog. name  JJ/MM/AAAA :spot:xxxxx - Comment
#======================================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs0} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}

if [ ${EST_ESID0060_COND1} = "N"  -a ${EST_ESID0060_COND3} = "N" ]
then
	# Launch applicative job ESID0111
	NJOB="ESID0111"
	${DCMD}/ESID0111.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} 2>&1 | ${TEE}
fi

CHAINEND
