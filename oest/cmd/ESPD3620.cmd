#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Solvency - Extract discount + ULAE + Bad debt + GLT feeding 
# nom du script SHELL           : ESPD3620.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 28/06/2018
# auteur                        : JYP - PERSEE
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  : SPIRA 069426 : REQ 00.01 - IFRS17- Closing schedule  
#                   split old ESPD3700 in 4 separate chains , 
#                   this new chain manage Extract discount + ULAE + Bad debt + GLT feeding parts 
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[001] 28/06/2018 JYP : SPIRA 069426 : new chain for calculation of Extract discount + ULAE + Bad debt + GLT feeding
#[002] 22/12/2020 : M.NAJI : 	. SPIRA 91531 
#							 	. variabilisation du TYPEINV et NORME
# 								. Ajout de l'IDF_CT  préfixé par la norme
##===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT="$2"

NJOB="ESFD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESFD9001.cmd "$IDF_CT"  

NSTEP=${NJOB}_450
LIBEL="Erase temporary files"
RMFIL "${DFILT}/*ESID3620*.dat"
#

# Launch applicative job ESID3703B Calcul des Cashflow et valeur escompte
NJOB="ESID3703B${TYPEINV}"
${DCMD}/ESID3703B.cmd ${PARM_CRE_D} ${PARM_INVCONSO_D} ${TYPEINV} ${IDF_CT} 2>&1 | ${TEE}


CHAINEND
