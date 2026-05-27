#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE ecritures post omega
# nom du script SHELL           : ESPD8900.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 20/06/2005
# auteur                        : J. Ribot
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Generation of Infocenter tables
#
# Launch applicative jobs ESCD9001 ESID8901 8902
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 06/12/2012 R. cassis :spot:24041 - Solvency 2
#[002] 22/12/2020 : M.NAJI : . SPIRA 91531 
#							. prise en compte de l'IDF_CT comme 2ème paramètres de la chaine 
#							. remplacement de ESCD9001 par ESPD9001
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters

OPTION='I'
IDF_CT=$2

NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd "${IDF_CT}" 

# Launch applicative job ESPD8901
NJOB="ESPD8901${NORME_CF}"
${DCMD}/ESPD8901.cmd ${PARM_SUFFTABLE} "$NORME_CF" 2>&1 | ${TEE}

CHAINEND
