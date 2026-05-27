#!/bin/ksh
#=============================================================================
# nom de l'application          : Get data - COMMUNS
# nom du script SHELL           : ESARCH10.cmd
# revision                      : 
# date de creation              : 14/04/2022
# auteur                        : 
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#  extraction 
# parameters: 
#		ESARCH10.env
#
#-----------------------------------------------------------------------------
# historiques des modifications
# Modifié le            Par                 Desc.
#
#---------------
#MODIFICATION   : [
#Auteur         : M.NAJI
#Date           : 18/10/2022
#Version        : 1.0
#Description    : 12/02/2025 :M.NAJI SPIRA 112675 : Green IT- Improve closing files lifecycle
#===============================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

#set +x


# Chain Initialization variables
CHAININIT $0 $1

IDF_CT="$2"



NJOB="ESFD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESFD9001.cmd "$IDF_CT"


# Launch applicative job ESCJ0661
NJOB="ESARCH11"
${DCMD}/ESARCH11.cmd 2>&1 | ${TEE}

# Launch applicative job ESARCH12
NJOB="ESARCH12"
${DFILT}/${NCHAIN}_${IB}_ZIP_ESARCH12.cmd 2>&1 | ${TEE}

# Launch applicative job ESARCH13
NJOB="ESARCH13"
${DFILT}/${NCHAIN}_${IB}_REMOVE_ESARCH13.cmd 2>&1 | ${TEE}


CHAINEND

