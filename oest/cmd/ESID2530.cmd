#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS -
# nom du script SHELL           : ESID2530.cmd
# revision                      : $Revision:   1.4  $
# date de creation              : 09/1997
# auteur                        : CGI
# references des specifications : 
#-----------------------------------------------------------------------------
# description : 
#               Print out of matching report file launch chain
#
# Launch applicative jobs ESCD9001 ESID2531 ESID2532 ESID2533
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
RETTHRESHOLD_R=${15}

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

# Launch applicative job ESID2531
NJOB="ESID2531"
${DCMD}/ESID2531.cmd ${ICLODAT_D} ${BALSHTYEA_NF} ${RETTHRESHOLD_R} 2>&1 | ${TEE}

# Launch applicative job ESID2532
NJOB="ESID2532"
${DCMD}/ESID2532.cmd ${ICLODAT_D} ${CRE_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${DBCLO_D} 2>&1 | ${TEE}

# Launch applicative job ESID2533
NJOB="ESID2533"
LOOP_JOB_SSD ${DCMD}/ESID2533.cmd 99 2>&1 | ${TEE}

CHAINEND
