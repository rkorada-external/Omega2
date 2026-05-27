#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - CONTROLE DES ESTIMATIONS
#                                 Chaine de MAJ des estimations en comptabilite
# nom du script SHELL		: ESEJ9999_bis.cmd
# revision			: $Revision:   1.9  $
# date de creation		: 09/09/2008
# auteur			: Dominique Ourmiah
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   SPOT 16010 : Copie all‚g‚e du ESEJ1000.cmd
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

NJOB="ESCD9001_bis"
# Launch applicative job ESCD9001_bis
. ${DCMD}/ESCD9001_bis.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}

# Launch applicative job ESEJ1001_bis
NJOB="ESEJ1001_bis"
${DCMD}/ESEJ1001_bis.cmd ${UPDULTTYP_CT} ${CLODAT_D} 2>&1 | ${TEE}

# Launch applicative job ESEJ1002_bis
NJOB="ESEJ1002_bis"
${DCMD}/ESEJ1002_bis.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF}  ${SSDs0} 2>&1 | ${TEE}

# Launch applicative job ESEJ1003_bis
NJOB="ESEJ1003_bis"
${DCMD}/ESEJ1003_bis.cmd ${UPDULTTYP_CT} ${CRE_D} 2>&1 | ${TEE}

# Launch applicative job ESEJ1004_bis
NJOB="ESEJ1004_bis"
${DCMD}/ESEJ1004_bis.cmd ${UPDULTTYP_CT} ${CRE_D} ${CLODAT_D} 2>&1 | ${TEE}

CHAINEND
