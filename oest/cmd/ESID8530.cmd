#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#              			: Injection du Rapprochement Retro
# nom du script SHELL           : ESID8530.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 31/10/1997
# auteur                        : LE ROY ( CGI )
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#  Injection of Retrocession Comparison into the Infocenter
#
# Launch applicative jobs ESCD9001 ESID8531
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization Variables
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

# Launch applicative job ESID8531
NJOB="ESID8531"
${DCMD}/ESID8531.cmd ${CRE_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${ICLODAT_D} 2>&1 | ${TEE}

CHAINEND
