#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE - Fichiers SRV vers RA
# nom du script SHELL           : ESID8120.cmd
# revision                      : 
# date de creation              : 27/07/2016
# auteur                        : Roger Cassis
# references des specifications : :spot:31717 Export fichiers SRV vers RA
#-----------------------------------------------------------------------------
# description
#  Préparation des fichiers SRV pour chargement dans RA
#
# Launch applicative jobs ESCD9001 ESID8121
#
#-----------------------------------------------------------------------------
# historiques des modifications 
#[001] 24/01/2019 R. cassis   :spira:75574 Renommage de la 2eme execution des memes jobs avec les lettres A et B dans le nom des jobs
#[002] 03/12/2020 B. Lagha    :spira:91417 Ajouter la variable SSDESPLAN_LL et ICLODAT_D comme parametre de ESID8121
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
set `GETPRM ${EST_PARAM1}`
ICLODAT_D=${7}
SSDESPLAN_LL=${28}
set `GETPRM ${EST_PARAM}`
SSDs0=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6
CLODATMAX_D=${22}
INVCONSO_D=${33}


set `GETPRM ${DFILP}/${ENV_PREFIX}_ESCJ0000_PARM1.dat`
ICLODAT=$7
EXEPLAN=${34}
VSRPLAN=${35}

NJOB="ESCD9001"
# Launch applicative job ESCD9001 for files YYYYTRIM
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs0} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT}

# Launch applicative job ESID8121 for files YYYYTRIM
NJOB="ESID8121A"
${DCMD}/ESID8121.cmd ${CRE_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CLODAT_D} ${CLODATMAX_D} ${INVCONSO_D} SRV SRV T ${EXEPLAN} ${VSRPLAN} ${SSDs0} ${SSDESPLAN_LL} ${ICLODAT_D} 2>&1 | ${TEE}

NJOB="ESCD9001"
# Launch applicative job ESCD9001 for files YYYY1231
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs0} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${BALSHTYEA_NF}1231

# Launch applicative job ESID8121 for files YYYY1231
NJOB="ESID8121B"
${DCMD}/ESID8121.cmd ${CRE_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CLODAT_D} ${CLODATMAX_D} ${INVCONSO_D} SRV SRV Y ${EXEPLAN} ${VSRPLAN} ${SSDs0} ${SSDESPLAN_LL} ${ICLODAT_D} 2>&1 | ${TEE}

CHAINEND
