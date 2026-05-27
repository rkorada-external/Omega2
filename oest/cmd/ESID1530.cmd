#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Inventaire vie
# nom du script SHELL		: ESID1530.cmd
# revision			: $Revision:   1.8  $
# date de creation		: 29/06/2004
# auteur			: J. Ribot
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   Life
#   Launch applicative jobs ESCD9001 ESID2032 and ESID2041
#-----------------------------------------------------------------------------
# historique des modifications
#  20 01 2005  J. Ribot    ajout appel du ESID1531.cmd pour suivi modif ESTIMATIONS
# [001] 25/06/2014 JBG :spot:25773 - Add an argument in ESID3028 calling
# [002] 14/10/2014 JBG :spot:25773 Ajout du mois bilan pour le ESID3028
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get the parameters
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
NJOB="ESCD9001"
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

# Launch applicative job ESID1531
NJOB="ESID1531"
${DCMD}/ESID1531.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} 2>&1 | ${TEE}

CHAINEND