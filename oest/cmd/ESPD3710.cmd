#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 SOLVENCY - Calcul des Cashflow et valeur escompte
# nom du script SHELL           : ESPD3710.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 25/04/2018
# auteur                        : MZM
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  :spira:65651: Generation des NP Allocation EBS
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 22/12/2020 : M.NAJI :. SPIRA 91531 
#							. prise en compte de l'IDF_CT comme 2ème paramètres de la chaine 
#							. remplacement de ESCD9001 par ESPD9001
#===============================================================================
#
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT="$2"

NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd "${IDF_CT}" 

# Launch applicative job ESID3704 Allocation des NP
NJOB="ESPD3711${TYPEINV}"
${DCMD}/ESPD3711.cmd "${PARM_CRE_D}" "${PARM_CLODAT_D}" "${TYPEINV}" "${PARM_BALSHEYEA_NF}" "${PARM_BALSHTMTH_NF}" "${PARM_ICLODAT_D}" 2>&1 | ${TEE}


CHAINEND
