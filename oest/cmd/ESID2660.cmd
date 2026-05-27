#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Fusion des GT LIFE et P&C
# nom du script SHELL		: ESID2660.cmd
# revision			: $Revision:   1.1  $
# date de creation		: 30/01/2020
# auteur			: CGI
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   Chain of merge of LIFE and P&C file
#
# Launch applicative jobs ESCD9001 ESID2661
#
#-----------------------------------------------------------------------------
# historique des modifications
#[001] 30/10/2019 M. NAJI       :SPIRA 81838 split LIFE and P&C

#===============================================================================
#
#

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1


#  Get Entry Parameters
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

# Launch applicative job ESID2661
NJOB="ESID2661"
${DCMD}/ESID2661.cmd  2>&1 | ${TEE}


CHAINEND
