#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE 
#                                 SHERPA
# nom du script SHELL		: ESID1020.cmd
# revision			: 
# date de creation		: 10/07/98
# auteur			: L.Capomazza
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   Life
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================
#set -x

#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_FTECLEDA
#	EST_FTECLEDR
#	EST_FSUBSID
#	EST_FCURQUOT
# Output files
#	EST_FTECLEDG
#	EST_FTECLEDD
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

#Get the parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
ICLODAT_D=$7
CLODAT_D=$8

export EST_ESID1020_GONOGO="Y"

# Launch applicative job ESCD9001
NJOB="ESCD9001"
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

# Launch applicative job ESID1021
NJOB="ESID1021"
${DCMD}/ESID1021.cmd ${CLODAT_D} 2>&1 | ${TEE}

# Launch applicative job ESID1022
NJOB="ESID1022"
${DCMD}/ESID1022.cmd ${CLODAT_D} 2>&1 | ${TEE}

CHAINEND

