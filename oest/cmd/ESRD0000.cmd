#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - REPORTING
# nom du script SHELL           : ESRD0000.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 23/11/2000
# auteur                        : HAMAÏMI J
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#   Generation of Infocenter table TBOIBNR
#
# Launch applicative jobs ESCD9001 ESRD0001
#
#-----------------------------------------------------------------------------
# historiques des modifications
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

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

# Launch applicative job ESRD0001
NJOB="ESRD0001"
${DCMD}/ESRD0001.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${ICLODAT_D} 2>&1 | ${TEE}

CHAINEND
