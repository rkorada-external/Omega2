#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -
#                                 Comptabilisation des ecritures de services
#
# nom du script SHELL		: ESID1520.cmd
# revision			: $Revision:   1.2  $
# date de creation		: 03/09/2003
# auteur			: J. Ribot
# references des specifications	:   SPOT EST6481.doc
#-----------------------------------------------------------------------------
# description
#         Special entries booking
#
# Launch applicative jobs ESCD9001 ESID1521
#
#-----------------------------------------------------------------------------
# historique des modifications
#[001] 27/01/2015 S.Behague    :spot 28122 - Ajout Step ESID1523.cmd
#[002] 18/07/2016 MMA & RKE   :SPOT30985: Integration de traitement pour RA
#[003] 24/01/2019 R. cassis   :spira:75574 Renommage de la 2eme execution des memes jobs avec la lettre B dans le nom des jobs
# 
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get the parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
ICLODAT_D=$7
CLODAT_D=$8

# Launch applicative job ESCD9001
NJOB="ESCD9001"
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

# Launch applicative job ESID1521
NJOB="ESID1521"
${DCMD}/ESID1521.cmd 2>&1 | ${TEE}

# Launch applicative job ESID1522
NJOB="ESID1522"
${DCMD}/ESID1522.cmd ${ICLODAT_D} ${BALSHTYEA_NF} 2>&1 | ${TEE}

# Launch applicative job ESID1523
NJOB="ESID1523"
${DCMD}/ESID1523.cmd ${ICLODAT_D} ${BALSHTYEA_NF} 2>&1 | ${TEE}

NJOB="ESID1524"																				
${DCMD}/ESID1524.cmd ${ICLODAT_D} ${CLODAT_D} ${CRE_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF}  2>&1 | ${TEE}





if [ "${ICLODAT_MTH}" != "12"   ]
then
NJOB="ESCD9001"
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} "${BALSHTYEA_NF}1231"

# Launch applicative job ESID1521
NJOB="ESID1521B"
${DCMD}/ESID1521.cmd 2>&1 | ${TEE}

# Launch applicative job ESID1522
NJOB="ESID1522B"
${DCMD}/ESID1522.cmd "${BALSHTYEA_NF}1231" ${BALSHTYEA_NF} 2>&1 | ${TEE}

# Launch applicative job ESID1523
NJOB="ESID1523B"
${DCMD}/ESID1523.cmd "${BALSHTYEA_NF}1231" ${BALSHTYEA_NF} 2>&1 | ${TEE}

fi

CHAINEND
