#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Chaine de fusion des perimetres retrocession
# nom du script SHELL		: ESID1500.cmd
# revision			: $Revision:   1.8  $
# date de creation		: 02/09/97
# auteur			: CGI
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   Mix retrocession perimeters
#   Launch Applicatives jobs ESCD9001 and ESID1501
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================


#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_IRDPERICASE0
#	EST_IRVPERICASE0
# Output files
#	EST_IRDVPERICASE0
#-=-=-=-=-=-=-=-=-=-=-=
# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get Entry Parameters 
# ${EST_PARAM} is a global environment variable
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


# Launch applicative job ESID1501
NJOB="ESID1501"
${DCMD}/ESID1501.cmd  2>&1 | ${TEE}
 
CHAINEND
