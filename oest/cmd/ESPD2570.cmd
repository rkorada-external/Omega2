#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Inventaire 
# nom du script SHELL           : ESPD2570.cmd
# revision                      : $Revision:   1.1  $
# date de creation              : 01/12/2018
# auteur                        : MZM
# references des specifications :spira:70671:Future premium for retro NP contracts  
#																:spira:70782:Future claim for retro NP contracts
#-----------------------------------------------------------------------------
# description :
#   REQ10.7 et REQ10.8 Future premium and future claim for retro NP contracts
#
#   Launch application jobs ESCD9001 and ESPD2570 
#
#-----------------------------------------------------------------------------
# historique des modifications :
# [001] 22/12/2020 : M.NAJI : 	. SPIRA 91531 
#							 	. variabilisation du TYPEINV et NORME
# 								. Ajout de l'IDF_CT  préfixé par la norme
#
#===============================================================================
#set -x


#-=-=-=-=-=-=-=-=-=-=-=


# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd

# Chain Initialization variables
CHAININIT $0 $1


IDF_CT="$2"

NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd "$IDF_CT"


# Launch applicative job ESPD2570
NJOB="ESPD2571"
${DCMD}/ESPD2571.cmd ${TYPEINV} ${PARM_INVCONSO_D} 2>&1 | ${TEE}

CHAINEND

