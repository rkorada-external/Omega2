#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATES - 
#                                 Calcul des SNEMs 
# nom du script SHELL           : ESID2100.cmd
# revision                      : $Revision:   1.3  $
# date de creation              : 05/08/1998
# auteur                        : CGI
# references des specifications : 
#-----------------------------------------------------------------------------
# description :
#	Compute of SNEMs
# 
# Launch applicative jobs ESCD9001 ESID2101
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

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

# Launch applicative job ESID2101 
NJOB="ESID2101"
${DCMD}/ESID2101.cmd ${ICLODAT_D} ${BALSHTYEA_NF} 2>&1 | ${TEE} 

CHAINEND
