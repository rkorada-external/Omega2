#!/bin/ksh
#===============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESID0120.cmd
# revision                      : $Revision: 1.0 
# date de creation              : 05/02/2019
# auteur                        : Rafael Vieville
# references des specifications :
#-------------------------------------------------------------------------------
# description
#   Generation of Estimates File :APOLO Quarterly
#-------------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
# set -x

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
echo ${EST_PARAM}


ECHO_LOG "#===> EST_PARAM ...............: ${EST_PARAM}"
ECHO_LOG "#===> BALSHTYEA_NF ............: ${BALSHTYEA_NF}"
ECHO_LOG "#===> BALSHTMTH_NF ............: ${BALSHTMTH_NF}"
ECHO_LOG "#===> CRE_D ...................: ${CRE_D}"

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs0} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}

NJOB="ESID0121"
# Launch applicative job ESID0111
${DCMD}/ESID0121.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} 2>&1 | ${TEE}

NJOB="ESID0122"
# Launch applicative job ESID0111
${DCMD}/ESID0122.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} 2>&1 | ${TEE}

CHAINEND
