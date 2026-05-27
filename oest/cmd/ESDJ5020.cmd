#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                             Intra Day Job
# nom du script SHELL		: ESDJ5020.cmd
# revision					: $Revision:   1.0  $
# date de creation			: 28/07/2015
# auteur					: JFO
# references des specifications	: EST38 - EST52
#-----------------------------------------------------------------------------
# description
#   Intra Day Job to check diff in file upload and 
#
# Launch applicative jobs ESCD9001 ESDJ5021
#-----------------------------------------------------------------------------
# historiques des modifications
# [001] 	JFO 	spot29095: Création du fichier
# [002]		MBO		spot30691:spira43333: ajout des champs necessaire à la trimestrialisation
# [003]		MBO		spot30691: spira43333: récupération ICLODAT pour la trimestrialisation
# [004]     DFI     28/02/2017  spira58664: nettoyage fichiers intraday
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get the parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6
ICLODAT_D=${102} #[003]

#[002]
echo "SSDs0=$SSDs0
SSDs=$SSDs
BALSHTYEA_NF=$BALSHTYEA_NF
BALSHTMTH_NF=$BALSHTMTH_NF
CRE_D=$CRE_D
DBCLO_D=$DBCLO_D
CLODAT_D=$CLODAT_D
ICLODAT_D=$ICLODAT_D" #[003]
#![002]

# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}

# Launch applicative job ESID2022
NJOB="ESDJ5021"
${DCMD}/ESDJ5021.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CLODAT_D} ${ICLODAT_D} 2>&1 | ${TEE} #[002] #[003]

NSTEP=${NCHAIN}_000
# [004]
# Suppression des fichiers present dans le répertoire DFILI plus ancien # que 14 jours (exclus)
#------------------------------------------------------------------------------
LIBEL="Erase intraday files older than 14 days"
EXECKSH_MODE=P
EXECKSH "find ${DFILI} -mtime +14 -name \"${NCHAIN}*.dat*\" -exec sh -c 'exec /bin/rm -vf \"\$@\" ' inline.cmd '{}' +"

CHAINEND
