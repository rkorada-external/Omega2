#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#              			        : Integration des ecritures locales trimestrielles et annuelles dans les fichiers GT
# nom du script SHELL           : ESLD8830.cmd
# revision                      : 
# date de creation              : 04/07/2017
# auteur                        : R. Cassis
# references des specifications : Spira:61508
#-----------------------------------------------------------------------------
# description:
#    Integration des clotures et annulations trimestrielles ou 
#    clotures et ouvertures annuelles des ecritures locales dans les fichiers GT
#
#
#-----------------------------------------------------------------------------
# historiques des modifications
#---------------
#[xxx] JJ/MM/AAAA Prog. name :spira:xxxxx Comment
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Input Parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=${SSDs0}
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
CLODAT_D=$8
RETTHRESHOLD_R=${15}
INVCONSO_D=${21}
BOOKING_D=${18}
CONSOYEA=${22}
CONSOMTH=${23}

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}

# Launch applicative job ESLD8831
NJOB="ESLD8831"
#${DCMD}/ESLD8831.cmd ${CRE_D} ${BOOKING_D} ${CONSOYEA} ${CONSOMTH} ${RETTHRESHOLD_R} 2>&1 | ${TEE}

# Launch applicative job ESLD8833
NJOB="ESLD8833"
#${DCMD}/ESLD8833.cmd ${CONSOYEA} ${CONSOMTH} ${INVCONSO_D} ${CRE_D} 2>&1 | ${TEE}

CHAINEND
