#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE - Generation des fichiers CMGT
# nom du script SHELL           : ESID7050.cmd
# revision                      : $Revision: 1.8 $
# date de creation              : 08/03/2011
# auteur                        : P.PEZOUT
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#   :spot:21408 - Update estimates
#
#-----------------------------------------------------------------------------
# historique des modifications
# <JJ/MM/AAAA>  <Programmer name>   <description>
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1
# Get entry parameters
# ${EST_PARAM} is a global environment variable
#SSDs0 subsidiaries of all closing years
#CLODAT0_D closing year label
set `GETPRM ${EST_PARAM}`
SSDs0=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT0_D=$6
SEGTYP_CT=$8

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs0} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT0_D} ${CLODAT0_D}       

# Launch applicative job ESID7001
NJOB="ESID7051"
${DCMD}/ESID7051.cmd  ${BALSHTYEA_NF} ${BALSHTMTH_NF} 2>&1 | ${TEE}

CHAINEND
