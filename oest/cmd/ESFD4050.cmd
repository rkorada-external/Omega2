#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS4 - EBS - IFRS17  
# nom du script SHELL           : ESFD4050.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 06/01/2022
# auteur                        : M.NAJI
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  SPIRA 101493:  Optimisation et préparation des fichier pour  ESFD4020, 
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[001] 
#===============================================================================
#set -x

IDF_CT=$2
TRN_FLAG=$3

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2

NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd ${IDF_CT}

# Launch applicative job ESFD4051 fusion ARCSTATGTA et ARCSTATGTAR (ACTUAL ONLY)
NJOB="ESFD4051"
${DCMD}/ESFD4051.cmd   2>&1 | ${TEE} 


# Launch applicative job ESFD4051 Calcul des Cashflow et valeur escompte
NJOB="ESFD4052"
${DCMD}/ESFD4052.cmd   "${PARM_INVCONSO_D}" 	 2>&1 | ${TEE} 

CHAINEND
