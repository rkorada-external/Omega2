#!/bin/ksh
#=============================================================================
# nom de l'application          : Get data - COMMUNS
# nom du script SHELL           : ESGETDT0.cmd
# revision                      : 
# date de creation              : 13/07/2018
# auteur                        : 
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#  Copy permanent files from IFRS4
# parameters: 
#		ESGETDT0.env
#
#-----------------------------------------------------------------------------
# historiques des modifications
# Modifié le            Par                 Desc.
#
#---------------
#MODIFICATION   : [
#Auteur         : M.NAJI
#Date           : 13/07/2018
#Version        : 1.0
#Description    : Copie les fichiers permanents avec la nouvelle nomenclature qui integre le context
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd



# Chain Initialization variables
CHAININIT $0 $1


# Get entry parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
ICLODAT_D=$7
CLODAT_D=$8
INVCONSO_D=${21}
CONSOYEA_NF=${22}
CONSOMTH_NF=${23}

NJOB="ESCD9001_IFRS17"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001_IFRS17.cmd ${SSDs0} ${SSDs0} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

# Launch applicative job ESCJ0001
NJOB="ESCJ0001"
${DCMD}/ESGETDT1.cmd  2>&1 | ${TEE}

CHAINEND

