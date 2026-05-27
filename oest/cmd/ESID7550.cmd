#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Cumul des Primes Facs
# nom du script SHELL           : ESID7550.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 09/1998
# auteur                        : CGI
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#    Accumulation of facultative premium
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#set -x


#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_ARCSTATGTA
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters 
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=${SSDs0}
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}

# Launch applicative job ESID7551
NJOB="ESID7551"
${DCMD}/ESID7551.cmd 2>&1 | ${TEE}

CHAINEND
