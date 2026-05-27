#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -  
#                                 Comptabilisation des ecritures de couverture
#				  
# nom du script SHELL		: ESID1550.cmd
# revision			: $Revision:   1.2  $
# date de creation		: 20/11/97
# auteur			: C.G.I. (M.HA-THUC)
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#         Special entries booking
#-----------------------------------------------------------------------------
# historique des modifications
#[01] 23/10/2015 Florent             :spot:29176 Comptabilité Rétro des PNA
#===============================================================================
#set -x


#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_FACCSUP
#	EST_FCES
#	EST_FCURCVSNI
#	EST_FCURQUOT
#	EST_FDETTRS
#	EST_FPLC
#	EST_FRETTRF
# EST_RETPNAGTR
# Output files
#	EST_DLRNPGTAA
#	EST_DLRNPGTAR
#	EST_DLRNPGTR
#-=-=-=-=-=-=-=-=-=-=-=

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

NJOB="ESCD9001"
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

NJOB="ESID1551"
${DCMD}/ESID1551.cmd ${ICLODAT_D} ${BALSHTYEA_NF} 2>&1 | ${TEE}

#PNA RETRO
NJOB="ESID1552"
${DCMD}/ESID1552.cmd ${BALSHTYEA_NF} 2>&1 | ${TEE}

CHAINEND
