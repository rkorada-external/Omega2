#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Inventaire vie
# nom du script SHELL		: ESID8040.cmd
# date de creation		: 01/08/15
# auteur			: GBO
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   Life
#
# Launch applicative jobs ESCD9001,ESID0112, ESID8041
#-----------------------------------------------------------------------------
# historique des modifications :
# [001]      MMA     13/04/2016 SPOT 31090  SPIRA 48161 Modification du paramètre $DATE pour l'apel ESIID8040
# [002]		 MMA	 25/01/2017 			SPIRA 58705 Ajout du paramètre ${BALSHTYEA_NF} lors de l'appel de lESID8041
#===============================================================================


# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1


ECHO_LOG "#"
MODE_NT=1
VAC_NT=0
ECHO_LOG "# Valeur de MODE_NT => ${MODE_NT}"
ECHO_LOG "#"


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
DATE=$5							# [001]

# Launch applicative job ESCD9001
NJOB="ESCD9001"
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

# Launch applicative job ESID0112
NJOB="ESID0112"
${DCMD}/ESID0112.cmd ${BALSHTYEA_NF} ${CRE_D} ${CLODAT_D} ${BALSHTMTH_NF}

# Launch applicative job ESID8041
NJOB="ESID8041"
${DCMD}/ESID8041.cmd ${MODE_NT} ${CLODAT_D} ${DATE} ${VAC_NT} ${BALSHTYEA_NF} 2>&1 | ${TEE}  #[002]

CHAINEND
