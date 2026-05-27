#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Save fichiers EST pour les traitements ecritures post omega
# nom du script SHELL		: ESPT7000.cmd
# revision			:
# date de creation		: 04/07/2005
# auteur			: J. Ribot
# references des specifications	: spot 5085
#-----------------------------------------------------------------------------
# description
#   Accounting transaction integration in daily LT ( set 28 )
#
# Launch applicative jobs ESCD9001 ESPT0001
#
#-----------------------------------------------------------------------------
# historique des modifications
#[001] 20/06/2012 JF VDV    :[23390] - Amenagements SOLVENCY II ajout INVCONSO_D
#[002] 09/10/2015 R. cassis :spot:28941 - Ajout job ESPT0002 pour extraction de donnees en base
#[003] 29/10/2015 R. Cassis :spot:29514 - On prend la date INVSERV_D au lieu de INVCONSO_D qui avait un trimestre de retard
#[004] 27/06/2016 R. Cassis :spot:30793 - Si Mutre, on execute pas le job pour POS EBS
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get the parameters
set `GETPRM ${EST_PARAM}`

SSDs0=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT0_D=$6
SEGTYP_CT=$8
INVSERV_D=${36}

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs0} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT0_D} ${CLODAT0_D}

# Launch applicative job ESPT0001
NJOB="ESPT0001"
${DCMD}/ESPT0001.cmd ${INVSERV_D} 2>&1 | ${TEE}

#[004]
if [ "${HOST_PRDSIT}" = "FRAM" ]
then
	CHAINEND
fi

# Launch applicative job ESPT0002 [002]
NJOB="ESPT0002"
${DCMD}/ESPT0002.cmd ${INVSERV_D} 2>&1 | ${TEE}

CHAINEND

