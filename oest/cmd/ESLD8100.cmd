#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                               : Formatage des fichiers GLT, ULTIMATES pour chargement dans Netezza
# nom du script SHELL           : ESLD8100.cmd
# revision                      : 
# date de creation              : 03/10/2017
# auteur                        : Roger Cassis
# references des specifications : Spira:61508
#-----------------------------------------------------------------------------
# description
#  Formatage des fichiers Estimation : GLT, Ultimates pour chargement dans Netezza
#
# Launch applicative jobs ESCD9001 ESID8101
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[xxx] JJ/MM/AAAA Prog. name :spira:xxxxx Comment
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
SSDs=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
ICLODAT_D=$7
CLODAT_D=$8
INVCONSO_D=${21}
BLCSHTYEALOC_NF=${36}
BLCSHTMTHLOC_NF=${37}

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
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

NORME=LOC
TYPEINV=POS

# Launch applicative job ESPD8101
NJOB="ESID8101"
${DCMD}/ESID8101.cmd ${CRE_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${ICLODAT_D} ${ICLODAT_D} ${INVCONSO_D} ${NORME} ${TYPEINV} ${BLCSHTYEALOC_NF} ${BLCSHTMTHLOC_NF} 2>&1 | ${TEE}

CHAINEND
