#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INTRADAY
# nom du script SHELL           : ESDJ1010.cmd
# revision                      : $Revision:   1.0$
# date de creation              : 20/08/15
# auteur                        : NES
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Launch applicative jobs ESCD9001 ESCJ0061 ESEH1101 ESEH1103
#-----------------------------------------------------------------------------
# historique des modifications
# [001]     DFI     28/02/2017  spira58664: nettoyage fichiers intraday
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get the input parameters :
# ${EST_PARAM} is a global environment varible
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=${SSDs0}
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6
SEGTYP_CT=$8


NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}

OPTION='Q'

# Launch applicative job ESCJ0061
NJOB="ESCJ0061"
${DCMD}/ESCJ0061.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} 2>&1 | ${TEE}

# Launch applicative job ESEH1101
NJOB="ESEH1101"
${DCMD}/ESEH1101.cmd ${SEGTYP_CT} ${DBCLO_D} 2>&1 | ${TEE}

# Launch applicative job ESEH1103
NJOB="ESEH1103"
${DCMD}/ESEH1103.cmd ${SEGTYP_CT} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${CLODAT_D} ${OPTION} 2>&1 | ${TEE}

NSTEP=${NCHAIN}_000
# [001]
# Suppression des fichiers present dans le répertoire DFILI plus ancien # que 14 jours (exclus)
#------------------------------------------------------------------------------
LIBEL="Erase intraday files older than 1 day"
EXECKSH_MODE=P
EXECKSH "find ${DFILI} -mtime +1 -name \"${NCHAIN}*.dat*\" -exec sh -c 'exec /bin/rm -vf \"\$@\" ' inline.cmd '{}' +"

CHAINEND
