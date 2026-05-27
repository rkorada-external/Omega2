#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS Controle des Operations internes
#                                 
# nom du script SHELL		: ESRD0010.cmd
# revision			: 
# date de creation		: 15/12/00
# auteur			: S.LLORENTE
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#
# Traitement effectue uniquement si la table BEST..TREQJOB est toppee
# Cumul par postes des fichiers GTA et GTR sur les sites paris, singapour et 
# new-york.
# Envoi vers le site de paris
#
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================


# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get parameters
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

# Launch applicative job ESRD0011
NJOB="ESRD0011"
${DCMD}/ESRD0011.cmd  ${CRE_D} 2>&1 | ${TEE}

# Launch applicative job ESRD0012
NJOB="ESRD0012"
${DCMD}/ESRD0012.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${CLODAT_D} 2>&1 | ${TEE}


CHAINEND
