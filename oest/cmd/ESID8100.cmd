#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                               : Formatage des fichiers GLT, ULTIMATES pour chargement dans Netezza
# nom du script SHELL           : ESID8100.cmd
# revision                      : 
# date de creation              : 11/12/2015
# auteur                        : Roger Cassis
# references des specifications : :spot:29903
#-----------------------------------------------------------------------------
# description
#  Formatage des fichiers Estimation : GLT, Ultimates pour chargement dans Netezza
#
# Launch applicative jobs ESCD9001 ESID8101
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 23/02/2016 R. Cassis :spot:30246 - Ajout gestion des Ultimates et Suppression fichiers avant le ESCD9001
#[002] 01/07/2022 D.Teixeira Spira: 104403 - Add new job ESID8102 Controle Period and Closing type 
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6
CLODATMAX_D=${22}
INVCONSO_D=${33}

# Pour tests
#BALSHTYEA_NF=2015
#BALSHTMTH_NF=12
#CRE_D=20151216
#CLODAT_D=20151231

#[001]
NSTEP=${NCHAIN}_${NJOB}_05
LIBEL="Erase Last Permanent files"
RMFIL "${DNZFILP}/${NCHAIN}_*.dat"

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs0} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}

# Launch applicative job ESID8101
NJOB="ESID8101"
${DCMD}/ESID8101.cmd ${CRE_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CLODAT_D} ${CLODATMAX_D} ${INVCONSO_D} IFRS INV 2>&1 | ${TEE}


# Launch applicative job ESID8102
NJOB="ESID8102"
${DCMD}/ESID8102.cmd I4I 2>&1 | ${TEE}

CHAINEND
