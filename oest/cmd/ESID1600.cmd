#!/bin/ksh
#=============================================================================
# nom de l'application		: INVENTAIRE 
#                                 Retour des resultats de l'inventaire pour
#				 l'actuariat bilans anterieurs
# nom du script SHELL		: ESID1600.cmd
# revision			: $Revision:   1.2  $
# date de creation		: 26/05/98
# auteur			: C.G.I. (M.HA-THUC)
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#	Sending	of Closing period process results to actuary
#
#	Launch applicative jobs ESCD9001 and ESID1601
#
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================
#set -x


#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_ARCSTATGTA
#	EST_FCPLACC0
#	EST_FCTRGRO0
#	EST_FCURQUOT
#	EST_FSEGMENT
#	EST_FTRSLNK
# Output files
#	EST_FSEGACTBILANT
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1


# Get the parameters
# ${EST_PARAM} is a global environment variable 
set `GETPRM ${EST_PARAM}` 
SSDs0=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6


NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs0} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}

# Launch applicative job ESID1601
NJOB="ESID1601"
${DCMD}/ESID1601.cmd 2>&1 | ${TEE}


CHAINEND

