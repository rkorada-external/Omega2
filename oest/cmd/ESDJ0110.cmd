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
# [001] 	JFO 	29/07/2015 	spot29095: Création du fichier
# [002]     DFI     28/02/2017  spira58664: nettoyage fichiers intraday
#===============================================================================


# Call generic functions
. ${DUTI}/fctgen.cmd

export IT=$2

FORCE_OPENNING=${#}
if [[ $FORCE_OPENNING -eq 3 ]]; then
	echo "#
# -------------------------------------------------
#
#   Parametre 3 present, lancement forcé de 
#   la generation de la grille d'ouverture.
#
# -------------------------------------------------
#
#   Param 3 is present, Opening grid 
#   will be generated.
#
# -------------------------------------------------
#"
fi

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

# Launch applicative job ESID0111
NJOB="ESDJ0112${IT}"
${DCMD}/ESDJ0112.cmd ${BALSHTYEA_NF} ${CRE_D} ${CLODAT_D} ${BALSHTMTH_NF} ${FORCE_OPENNING} 2>&1 | ${TEE} 

NSTEP=${NCHAIN}_000
# [002]
# Suppression des fichiers present dans le répertoire DFILI plus ancien # que 14 jours (exclus)
#------------------------------------------------------------------------------
LIBEL="Erase intraday files older than 1 day"
EXECKSH_MODE=P
EXECKSH "find ${DFILI} -mtime +1 -name \"${NCHAIN}*.dat*\" -exec sh -c 'exec /bin/rm -vf \"\$@\" ' inline.cmd '{}' +"

CHAINEND
