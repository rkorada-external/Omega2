#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#              			            : Generation des ouvertures annuelles des ecritures Locales
# nom du script SHELL           : ESLD2900.cmd
# revision                      : 
# date de creation              : 04/07/2017
# auteur                        : R. Cassis
# references des specifications : Spira:61508
#-----------------------------------------------------------------------------
# description:
#
#-----------------------------------------------------------------------------
# historiques des modifications
#---------------
#[001] 07/04/2020 R. Cassis :spira:76698 On month 12, this chain is processed for Local annual opening
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Recupere les parametres d'entree
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$5
DBCLO_D=$6
CLODAT_D=$7
INVCONSO_D=${21}
CONSOYEA=${22}
CONSOMTH=${23}
BLCSHTYEALOC_NF=${36}
BLCSHTMTHLOC_NF=${37}

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

# Launch applicative job ESLD2901
NJOB="ESLD2901"
${DCMD}/ESLD2901.cmd ${CRE_D} ${CONSOYEA} ${CONSOMTH} ${INVCONSO_D} ${BLCSHTYEALOC_NF} ${BLCSHTMTHLOC_NF} 2>&1 | ${TEE}

# Launch applicative job ESLD2902
NJOB="ESLD2902"
${DCMD}/ESLD2902.cmd ${BLCSHTYEALOC_NF} ${BLCSHTMTHLOC_NF} 2>&1 | ${TEE}

CHAINEND
