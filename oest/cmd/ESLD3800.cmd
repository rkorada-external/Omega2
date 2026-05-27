#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#              			        : Formatage des ecritures post omega Local GTA et GTR au format GLT
# nom du script SHELL           : ESLD3800.cmd
# revision                      : 
# date de creation              : 04/07/2017
# auteur                        : R. Cassis
# references des specifications : Spira:61508
#-----------------------------------------------------------------------------
# description
#   Formatage des ecritures post omega Local GTA et GTR au format GLT
#
#-----------------------------------------------------------------------------
# historiques des modifications
#---------------
#[xxx] JJ/MM/AAAA Prog. name :spira:xxxxx Comment
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
CONSOYEA=${22}
CONSOMTH=${23}
BLCSHTYEALOC_NF=${36}
BLCSHTMTHLOC_NF=${37}


NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs0} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

# Launch applicative job ESLD3801  SOCIAL LOCAL
NJOB="ESLD3801"
${DCMD}/ESLD3801.cmd ${CRE_D} ${CONSOYEA} ${CONSOMTH} ${BLCSHTYEALOC_NF} ${BLCSHTMTHLOC_NF} 2>&1 | ${TEE}

CHAINEND
