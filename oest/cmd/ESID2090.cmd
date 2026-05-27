#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS -
# nom du script SHELL           : ESID2090.cmd
# revision                      : $Revision:   1.1  $
# date de creation              : 09/1997
# auteur                        : CGI (KUHNA)
# references des specifications : 
#-----------------------------------------------------------------------------
# description 
#   Chain of preparation of data for acceptance closing period synthesis print
#   out
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#set -x


#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_FCURQUOT
#	EST_FLIBEL1
#	EST_FTRSLNK
#	EST_IADVPERICASE
#	EST_TOTGTAA
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

# Launch applicative job ESID2091
NJOB="ESID2091"
${DCMD}/ESID2091.cmd ${ICLODAT_D} ${CRE_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${DBCLO_D} 2>&1 | ${TEE}

# Launch applicative job ESID2092
NJOB="ESID2092"
LOOP_JOB_SSD ${DCMD}/ESID2092.cmd 99 2>&1 | ${TEE}

CHAINEND
