#!/bin/ksh
#=============================================================================
# nom de l'application          : Get data - COMMUNS
# nom du script SHELL           : ESARCH00.cmd
# revision                      : 
# date de creation              : 14/04/2022
# auteur                        : 
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#  extraction 
# parameters: 
#		ESARCH00.env
#
#-----------------------------------------------------------------------------
# historiques des modifications
# Modifié le            Par                 Desc.
#
#---------------
#MODIFICATION   : [
#Auteur         : M.NAJI
#Date           : 20/04/2022
#Version        : 1.0
#Description    : Archivage des fichier permanant
#===============================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd


# Chain Initialization variables
CHAININIT $0 $1

IDF_CT="$2"



NJOB="ESFD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESFD9001.cmd "$IDF_CT"
#export PARM_ICLODAT_D="20220331"

# Launch applicative job ESCJ0661
NJOB="ESARCH01"
${DCMD}/ESARCH01.cmd 2>&1 | ${TEE}


CHAINEND

