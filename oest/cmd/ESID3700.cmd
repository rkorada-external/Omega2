#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 SOLVENCY - Calcul des Cashflow et valeur escompte
# nom du script SHELL           : ESID3700.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 20/04/2012
# auteur                        : Roger Cassis
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  :spot:23802 Calcul des Cashflow et valeur escompte
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[001] 13/08/2012 :spot:24041 - SOLVENCY 2 : Modification ICLODAT en CLODAT dans ESCD9001 (8eme parm)
#[002] 19/09/2012 :spot:24041 - SOLVENCY 2 : Ajout de la  CLODAT dans l'appel ESID3702 pour le prg ESTC1061
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

# Launch applicative job ESID3701 Calcul des Cashflow et valeur escompte
NJOB="ESID3701"
#${DCMD}/ESID3701.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${ICLODAT_D} INV 2>&1 | ${TEE}

# Launch applicative job ESID3702 Calcul des Cashflow et valeur escompte
NJOB="ESID3702"
${DCMD}/ESID3702.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${ICLODAT_D} INV 2>&1 | ${TEE}

# Launch applicative job ESID3703 Calcul des Cashflow et valeur escompte
NJOB="ESID3703"
${DCMD}/ESID3703.cmd ${CRE_D} ${ICLODAT_D} INV 2>&1 | ${TEE}

# Launch applicative job ESID3703 ANNULATION DES PNAS
NJOB="ESID3705${TYPEINV}"
#${DCMD}/ESID3705.cmd ${CRE_D} ${ICLODAT_D} INV 2>&1 | ${TEE}

CHAINEND
