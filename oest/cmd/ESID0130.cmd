#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESID0130.cmd
# revision                      : $Revision: 1.0 
# date de creation              : 21/08/2019
# auteur                        : Rafael Vieville
# references des specifications :
#-----------------------------------------------------------------------------
# description
#-----------------------------------------------------------------------------
# historiques des modifications
#[xxx] prog. name  JJ/MM/AAAA :spot:xxxxx - Comment
#======================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1
set -x

set `GETPRM ${EST_PARAM}`
# Get entry parameters
SSDs0=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6
set +x

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs0} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}

# Launch applicative job ESID0111
NJOB="ESID0131"
${DCMD}/ESID0131.cmd | ${TEE}

CHAINEND
