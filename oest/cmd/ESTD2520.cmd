#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATES - 
#                                 Preparation of anterior cession and placement files
# nom du script SHELL           : ESTD2520.cmd
# revision                      : $Revision:   1.4  $
# date de creation              : 06/10/1997
# auteur                        : CGI
# references des specifications : 
#-----------------------------------------------------------------------------
# description :
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

# Get parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$2   
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
ICLODAT_D=$7
CLODAT_D=$8

# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

# Launch applicative job ESTD2521 
NJOB="ESTD2521"
${DCMD}/ESTD2521.cmd 2>&1 | ${TEE} 

CHAINEND
