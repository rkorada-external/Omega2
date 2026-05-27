#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 SOLVENCY - Calcul des Cashflow et valeur escompte
# nom du script SHELL           : ESPD3700.cmd
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
#[001] 19/10/2012 R. Cassis :spot:24041: Adaptations Solvency
#[002] 20/01/2013 :spot:24698 - -=PhP=-  corrections pour la conso on appelle le ESID3601 au lieu du ESID3705
#[003] 16/03/2018 :spira:65651 : MZM : Allocation NP pour EBS : Création du shell ESID3704.cmd
#[004] 26/04/2018 Annulation de 003 spira 65651
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
INVCONSO_D=${21}
CONSOYEA_NF=${22}
CONSOMTH_NF=${23}


NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs0} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}
if [ "${EST_ESPD3700_COND1}" = "Y" ]
then
	TYPEINV=POS
else
	TYPEINV=POC
fi

NSTEP=${NJOB}_450
LIBEL="Erase temporary files"
RMFIL "${DFILT}/*ESID370*.dat"
#RMFIL "${DFILT}/*ESPD370*.gz"
#

# Launch applicative job ESID3702 Calcul des Cashflow et valeur escompte
NJOB="ESPD3702${TYPEINV}"
${DCMD}/ESID3702.cmd ${CONSOYEA_NF} ${CONSOMTH_NF} ${INVCONSO_D} ${TYPEINV} 2>&1 | ${TEE}

# Launch applicative job ESID3703 Calcul des Cashflow et valeur escompte
NJOB="ESPD3703${TYPEINV}"
${DCMD}/ESID3703.cmd ${CRE_D} ${INVCONSO_D} ${TYPEINV} 2>&1 | ${TEE}

# Launch applicative job ESID3703 ANNULATION DES PNAS
NJOB="ESPD3601${TYPEINV}"
${DCMD}/ESID3601.cmd ${CRE_D} ${INVCONSO_D} ${TYPEINV} 2>&1 | ${TEE}

# Launch applicative job ESID3703 ANNULATION DES PNAS
NJOB="ESPD3602${TYPEINV}"
${DCMD}/ESID3602.cmd ${CRE_D} ${INVCONSO_D} ${TYPEINV} 2>&1 | ${TEE}

CHAINEND
