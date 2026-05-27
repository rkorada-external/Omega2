#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Risk Margin calculation
# nom du script SHELL           : ESPD3640.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 28/06/2018
# auteur                        : JYP - PERSEE
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  : SPIRA 069426 : REQ 00.01 - IFRS17 : split old ESPD3700 in 4 chains
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[001] 28/06/2018  1st version of chain with only "ESID3602 : Risk Margin calculation" 
#[001] 02/04/2019	 SPIRA 71570 remplacement du ESFD9001.cmd 
#[002] 22/12/2020 : M.NAJI : 	. SPIRA 91531 
#							 	. variabilisation du TYPEINV et NORME
# 								. Ajout de l'IDF_CT  préfixé par la norme
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

NSTEP=${NJOB}_450
LIBEL="Erase temporary files"
RMFIL "${DFILT}/*ESPD3640*.dat"
#


# Launch applicative job ESID3602A Risk Margin Calculation
NJOB="ESID3602A${TYPEINV}"
${DCMD}/ESID3602A.cmd ${PARM_CRE_D} ${PARM_INVCONSO_D} ${TYPEINV} 2>&1 | ${TEE}

CHAINEND
