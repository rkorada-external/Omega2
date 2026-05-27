#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS Controle des Operations internes
#                                 
# nom du script SHELL		: ESRD0020.cmd
# revision			: 
# date de creation		: 15/12/00
# auteur			: S.LLORENTE
# references des specifications	: 
#-----------------------------------------------------------------------------
# Recuperation sur le site de paris des fichiers GTA et GTR cumules par postes 
# en provenance de paris, singapour et new-york.
# Concatenation des fichiers et mise en base (BSAR..TCTRLIO) des différences
# GTA-GTR detectees
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================


# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd
. ${DUTI}/fcttransfer.cmd


# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
# ${EST_PARAM} is a global environment variable
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6


NJOB="ESCD9001"
# Launch applicative job ESCD9001
# On appelle ce job pour tester le GONOGO, on n'a pas de noms de fichiers a construire
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}



# Get parameters
set `GETPRM ${DPRM}/ESRD0020.prm`
DATE_T=$1
GTAINIO_FRA1=$2
GTRINIO_FRA1=$3
GTAINIO_SGP1=$4
GTRINIO_SGP1=$5
GTAINIO_USA1=$6
GTRINIO_USA1=$7
MODE=$8


NJOB="TEFJ0011"
# Launch technical job TEFJ0011
${DUTI}/TEFJ0011.cmd 2>&1 | ${TEE}


# Launch applicative job ESRD0021
NJOB="ESRD0021"
LOOP_JOB_POOL ${DCMD}/ESRD0021.cmd SITE ${REMOTE_SITE} ${CRE_D} 2>&1 | ${TEE}


# Launch applicative job ESRD0022 - mode param
if [ $MODE -eq 0 ]
then
NJOB="ESRD0022"
${DCMD}/ESRD0022.cmd ${GTAINIO_FRA1} ${GTRINIO_FRA1} ${GTAINIO_SGP1} ${GTRINIO_SGP1} ${GTAINIO_USA1} ${GTRINIO_USA1} 2>&1 | ${TEE}
fi


# Launch applicative job ESRD0023 - mode auto
if [ $MODE -eq 1 ]
then

NJOB="ESRD0023"
${DCMD}/ESRD0023.cmd ${CRE_D} 2>&1 | ${TEE}
fi

CHAINEND
