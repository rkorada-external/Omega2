#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Chaine de preparation des fichiers DTSTATGTA 
#                                 et VTSTATGTA
# nom du script SHELL		: ESID1010.cmd
# revision			: $Revision:   1.11  $
# date de creation		: 02/09/97
# auteur			: CGI
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   Preparing files DTSTATGTA et VSTATGTA
#   Launch applicative jobs ESCD9001 and ESID1011 
#-----------------------------------------------------------------------------
# historique des modifications
# [001]     DFI     28/02/2017  spira58664: nettoyage fichiers intraday
#===============================================================================


#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_ARCSTATGTA
#	EST_GTA
#	EST_IADVPERICASE0
#	EST_IRDVPERICASE0
#	EST_STATGTA
# Output files
#	EST_DTSTATGTAA0
#	EST_TSTATGTAANO
#	EST_VTSTATGTA0
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get the input parameters : 
# ${EST_PARAM} is a global environment varible 
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

export EST_ARCSTATGTA="${DFILP}/empty.dat"
export EST_ARCSTATGTA_ID="${DFILP}/empty.dat"

# Launch applicative job ESDJ7005
NJOB="ESDJ7005"
${DCMD}/ESDJ7005.cmd 2>&1 | ${TEE}

touch ${EST_STATGTR}

# Launch applicative job ESID1011
NJOB="ESID1011"
${DCMD}/ESID1011.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${SSDs0} 2>&1 | ${TEE} 

NSTEP=${NCHAIN}_000
# [001]
# Suppression des fichiers present dans le répertoire DFILI plus ancien # que 14 jours (exclus)
#------------------------------------------------------------------------------
LIBEL="Erase intraday files older than 14 days"
EXECKSH_MODE=P
EXECKSH "find ${DFILI} -mtime +14 -name \"${NCHAIN}*.dat*\" -exec sh -c 'exec /bin/rm -vf \"\$@\" ' inline.cmd '{}' +"

CHAINEND
