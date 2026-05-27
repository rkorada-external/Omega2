#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 renommage des fichier EST pour les traitements ecritures post omega
# nom du script SHELL		: ESPT-1_0.cmd
# revision			:
# date de creation		: 08/03/2021
# auteur			: M. NAJI
# references des specifications	: spot 91531
#-----------------------------------------------------------------------------
# description
#   Restore original name of ESPT* filed 
#
#
#-----------------------------------------------------------------------------
# historique des modifications
# 08/03/2021 M.NAJI spliter la chaine ESPT0010 en ESPT0010 et ESPT0020
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2

NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd "${IDF_CT}" 

# Launch applicative job ESPT-1_1
NJOB="ESPT0021"
${DCMD}/ESPT0021.cmd  2>&1 | ${TEE}

# Launch applicative job ESPT-1_2
NJOB="ESPT0022"
${DCMD}/ESPT0022.cmd  2>&1 | ${TEE}


CHAINEND

