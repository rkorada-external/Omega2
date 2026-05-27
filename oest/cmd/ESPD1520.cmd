#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -
#                                 Comptabilisation des ecritures de Post Omega
#
# nom du script SHELL		: ESPD1520.cmd
# revision			: $Revision:   1.2  $
# date de creation		: 20/09/2005
# auteur			: J. Ribot
# references des specifications	:   SPOT 5085.doc
#-----------------------------------------------------------------------------
# description
#         Special entries booking
#
# Launch applicative jobs ESCD9001 ESPD1521
#
#-----------------------------------------------------------------------------
# historique des modifications
#[001] 11/03/2015 P. Menant       :spot 28122 - EST48, ajout du parametre ICLODAT_D a ESPD1521
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
INVCONSO_D=${21}
CONSOYEA=${22}

# Launch applicative job ESCD9001
NJOB="ESCD9001"
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

# Launch applicative job ESPD1521
#[001] ajout de ICLODAT_D
NJOB="ESPD1521"
${DCMD}/ESPD1521.cmd ${INVCONSO_D} ${CONSOYEA} ${ICLODAT_D} 2>&1 | ${TEE}

CHAINEND
