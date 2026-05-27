#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS -
# nom du script SHELL           : ESID2590.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 09/1997
# auteur                        : CGI
# references des specifications : 
#-----------------------------------------------------------------------------
# description  
#   Chain of retrocession closing period synthesis print out launch chain
#-----------------------------------------------------------------------------
# historiques des modifications :
#===============================================================================
#set -x


#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_FCURQUOT
#	EST_FLIBEL1
#	EST_FTRSLNK
#	EST_IADVPERICASE
#	EST_IRDVPERICASE
#	EST_TOTGTAR
#-=-=-=-=-=-=-=-=-=-=-=

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

# Launch applicative job ESID2591
NJOB="ESID2591"
${DCMD}/ESID2591.cmd ${ICLODAT_D} ${CRE_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${DBCLO_D} 2>&1 | ${TEE}

# Launch applicative job ESID2592
NJOB="ESID2592"
LOOP_JOB_SSD ${DCMD}/ESID2592.cmd 99 2>&1 | ${TEE}

CHAINEND
