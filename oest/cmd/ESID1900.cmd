#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Annulations
# nom du script SHELL		: ESID1900.cmd
# revision			: $Revision:   1.1  $
# date de creation		: 02/09/97
# auteur			: CGI
# references des specifications	: ESCOM2F.doc
#-----------------------------------------------------------------------------
# description
#   Chain of reverse
#
#   Launch applicative jobs ESCD9001 and ESID1901
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================
# Call generic functions
. ${DUTI}/fctgen.cmd


#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_CURGTA
#	EST_CURGTR
#	EST_GTA
#	EST_GTR
#	EST_IGTAA0
#	EST_IGTAR0
#	EST_IGTR0
# Output files
#	EST_DLAGTAA0
#	EST_DLAGTAR0
#	EST_DLAGTR0
#	EST_IGTAA0
#	EST_IGTAR0
#	EST_IGTR0
#-=-=-=-=-=-=-=-=-=-=-=

# Chain Initialization variables
CHAININIT $0 $1

#  Get entry parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6


NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}

# Launch applicative job ESID1901
NJOB="ESID1901"
${DCMD}/ESID1901.cmd ${CLODAT_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} 2>&1 | ${TEE}
 

CHAINEND
