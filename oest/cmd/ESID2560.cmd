#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Fusion de la retrocession
# nom du script SHELL		: ESID2560.cmd
# revision			: $Revision:   1.3  $
# date de creation		: 26/05/97
# auteur			: CGI
# references des specifications	: ESCOM02F.doc
#-----------------------------------------------------------------------------
# description
#   Chain of retrocession merge
#
# Launch applicative jobs ESCD9001 ESID2561
#
#-----------------------------------------------------------------------------
# historique des modifications
#[001] 22/02/2006      M.DJELLOULI     SPOT12055 - Impression Ventilation NP - ESID2562.cmd
#[002] 23/04/2018 Roger Cassis :spira:61675 On envoie la CLODAT_D au ESID2561
#[003] 30/10/2019 M. NAJI       :spot:81838 	- ajout du mode IFRS4 avec un IDF_CT
#						-  suppression ESID2562.cmd , Ventilation NP print-out

#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT="$2"

if [ "${IDF_CT}" = "I4_LIFE___" ]
then
        IDF_CT=""
fi


if [ "${IDF_CT}" != "" ]
then
	NJOB="ESCD9001"
        # Launch applicative job ESCD9001
        . ${DCMD}/ESFD9001.cmd "${IDF_CT}"
        EXECKSH "cp ${EST_IGTAR0}    ${EST_IGTAR}   " 2>&1 | ${TEE}
fi


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

if [ "${IDF_CT}" = "" ]
then
	# Launch applicative job ESCD9001
	NJOB="ESCD9001"
	. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}
fi

# Launch applicative job ESID2561
#[002]
NJOB="ESID2561"
${DCMD}/ESID2561.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${ICLODAT_D} ${CRE_D} ${CLODAT_D} 2>&1 | ${TEE}

#------------------------------------------------------------------------------
# Ventilation NP print-out
#------------------------------------------------------------------------------
# Launch applicative job ESID2562
#NJOB="ESID2562"
#LOOP_AS_PRINT ${DCMD}/ESID2562.cmd 2>&1 | ${TEE}

CHAINEND
