#!/bin/ksh
#=============================================================================
# nom de l'application		: INVENTAIRE 
#                                 Retour des resultats de l'inventaire pour
#				 l'actuariat
#				  bilan en cours
# nom du script SHELL		: ESID2600.cmd
# revision			: $Revision:   1.1  $
# date de creation		: 27/05/98
# auteur			: C.G.I. (M.HA-THUC)
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#	Sending of Closing period process results to actuary
#
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================
#set -x

#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_FCPLACC
#	EST_FCTRGRO
#	EST_FCURQUOT
#	EST_FSEGACTBILANT
#	EST_FSEGMENT
#	EST_FTRSLNK
#	EST_TOTGTAA
#	EST_TOTGTAR
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1


# Get the parameters
# ${EST_PARAM} is a global environment variable 
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

# Launch applicative job ESID2601
NJOB="ESID2601"
${DCMD}/ESID2601.cmd 2>&1 | ${TEE}


CHAINEND

