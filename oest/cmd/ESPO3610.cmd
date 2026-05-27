#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 SOLVENCY - Calcul des Cashflow only
# nom du script SHELL           : ESPD3610.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 28/06/2018
# auteur                        : JYP - PERSEE
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  : SPIRA 069426 : REQ 00.01 - IFRS17- Closing schedule : split old ESPD3700 in separate chains , this one manage cashflow only 
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[001] 28/06/2018 JYP : SPIRA 069426 : new chain for cashflow calculation only
#[002] 28/09/2020 : JYP : SPIRA 83609 : microAOC, manage multi instance IDF_CT
#[035] 02/11/2020 M.NAJI SPIRA 91421  : -optimisation, isolement des steps pour les mettre dans une chaine à part 
#===============================================================================
#set -x

IDF_CT=$2

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2

NJOB="ESFD9001"
# Launch applicative job ESCD9001
#. ${DCMD}/ESCD9001_IFRS17.cmd ${SSDs0} ${SSDs0} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}
. ${DCMD}/ESFD9001.cmd "$IDF_CT"


NSTEP=${NJOB}_450
LIBEL="Erase temporary files"
RMFIL "${DFILT}/*ESID3610*.dat"
#

# Launch applicative job ESFD3611
NJOB="ESFD3611${TYPEINV}"
${DCMD}/ESFD3611.cmd ${PARM_CONSOYEA} ${PARM_CONSOMTH} ${PARM_INVCONSO_D} ${TYPEINV} 2>&1 | ${TEE}


# Launch applicative job ESFD3612 Calcul des Cashflow et valeur escompte
NJOB="ESFD3612${TYPEINV}"
${DCMD}/ESFD3612.cmd ${PARM_CONSOYEA} ${PARM_CONSOMTH} ${PARM_INVCONSO_D} ${TYPEINV} 2>&1 | ${TEE}

# Launch applicative job ESFD3613 Calcul des Cashflow et valeur escompte
NJOB="ESFD3613${TYPEINV}"
${DCMD}/ESFD3613.cmd ${PARM_CRE_D} ${PARM_INVCONSO_D} ${TYPEINV} 2>&1 | ${TEE}


CHAINEND
