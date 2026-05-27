#!/bin/ksh
#=============================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 EBS : Spira 107203
# Revision                      : $Revision:   1.0  $
# Date de creation              : 18/10/2022
# Auteur                        : HR
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Description
# 
#  - BDA- Impact on Omega closing
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
#       <indice>        <jj/mm/aaaa>    <auteur>        <spira>                 <description de la modification>
#====================================================================================================
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


# Launch applicative job for TL merge
NJOB="ESPD3971${TYPEINV}"
${DCMD}/ESPD3971.cmd 2>&1 | ${TEE}


CHAINEND
