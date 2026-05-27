#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - CONTROLE DES ESTIMATIONS 
#                                 Chaine de MAJ des estimations en comptabilite
# nom du script SHELL		: ESEJ1000.cmd
# revision			: $Revision:   1.9  $
# date de creation		: 19/06/97
# auteur			: C.G.I. (M.HA-THUC)
# references des specifications	: ESTIR32F.doc
#-----------------------------------------------------------------------------
# description
#   Update estimations in accountancy
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================
#set -x


#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_ARCSTATGTA
#	EST_FCURQUOT
#	EST_FTRSLNK
#	EST_GTA
#	EST_STATGTA
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get the parameters
# ${EST_PARAM} is a global environment variable 
set `GETPRM ${EST_PARAM}` 
#set -x
SSDs0=$1
SSDs=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6
UPDULTTYP_CT=${40}

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}

# Launch applicative job ESEJ1001
NJOB="ESEJ1001"
${DCMD}/ESEJ1001.cmd ${UPDULTTYP_CT} ${CLODAT_D} 2>&1 | ${TEE}

# Launch applicative job ESEJ1002
NJOB="ESEJ1002"
${DCMD}/ESEJ1002.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF}  ${SSDs0} 2>&1 | ${TEE}

# Launch applicative job ESEJ1003
NJOB="ESEJ1003"
${DCMD}/ESEJ1003.cmd ${UPDULTTYP_CT} ${CRE_D} 2>&1 | ${TEE}

# Launch applicative job ESEJ1004
NJOB="ESEJ1004"
${DCMD}/ESEJ1004.cmd ${UPDULTTYP_CT} ${CRE_D} ${CLODAT_D} 2>&1 | ${TEE}

CHAINEND
