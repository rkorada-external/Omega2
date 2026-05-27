#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS -
# nom du script SHELL           : ESRD2530.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 01/2001
# auteur                        : O. Arik
# references des specifications : 
#-----------------------------------------------------------------------------
# description : 
#              This chain allows to check if retroactive effects are correctly
#              applied in retrocession accounting.
#              It compares (gross transactions data * cession rates) file and 
#              retrocession accounting file
#
# Launch applicative jobs ESCD9001 ESRD2531
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
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

# Launch applicative job ESRD2531
NJOB="ESRD2531"
${DCMD}/ESRD2531.cmd ${ICLODAT_D} 2>&1 | ${TEE}


CHAINEND
