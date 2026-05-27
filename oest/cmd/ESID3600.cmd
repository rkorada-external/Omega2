#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 SOLVENCY - Calcul des Cashflow et valeur escompte
# nom du script SHELL           : ESID3600.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 14/11/2012
# auteur                        : Roger Cassis
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  :spot:24041 Prise en compte PNA dans Solvency
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[00x] jj/mm/aaaa :spot:xxxxx - Commentaires
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
ICLODAT_D=$7
CLODAT_D=$8

TYPEINV="INV"

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

# Launch applicative job ESID3601 ANNULATION DES PNAS
NJOB="ESID3601${TYPEINV}"
${DCMD}/ESID3601.cmd ${CRE_D} ${ICLODAT_D} INV 2>&1 | ${TEE}

CHAINEND
