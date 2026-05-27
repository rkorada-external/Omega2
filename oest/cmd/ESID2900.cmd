#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Rejets / Reconduction
# nom du script SHELL		: ESID2900.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 10/09/97
# auteur			: CGI
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   Chain of retrocession reversal and carried forward entries generation
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================
#set -x


#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_TOTGTAA
#	EST_TOTGTAR
#	EST_TOTGTR
# Output files
#	EST_DLREJGTAA
#	EST_DLREJGTAR
#	EST_DLREJGTR
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Recupere les parametres d'entree
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
ICLODAT_D=$7
CLODAT_D=$8

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}


# Launch applicative job ESID2901
NJOB="ESID2901"
${DCMD}/ESID2901.cmd ${ICLODAT_D} ${BALSHTMTH_NF} 2>&1 | ${TEE}

CHAINEND
