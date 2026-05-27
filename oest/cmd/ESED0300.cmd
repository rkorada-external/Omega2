#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - CONTROLE DES ESTIMATIONS
#                                 Chaine de lancement des ventilations des S/P
# nom du script SHELL		: ESED0300.cmd
# revision			: $Revision:   1.4  $
# date de creation		: 01/08/97
# auteur			: CGI
# references des specifications	: ESTSEG06.doc
#-----------------------------------------------------------------------------
# description
#   Launch ventilation after a PB request
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================


#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_ARCSTATGTA
#	EST_FCURQUOT
#	EST_FTRSLNK
#	EST_GTA
#	EST_SADPERICASE0
#	EST_SADPERIFR0
#	EST_STATGTA
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get input parameters
set `GETPRM ${EST_PARAM}`
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6
SEGTYPULT_CT=${80}
SSDULT_LL=${81}
VRS_LL=${82}

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDULT_LL} ${SSDULT_LL} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}   


# Launch applicative job ESED0301
NJOB="ESED0301"
${DCMD}/ESED0301.cmd ${CRE_D} ${SEGTYPULT_CT} ${SSDULT_LL} ${VRS_LL} 2>&1 | ${TEE}

CHAINEND
