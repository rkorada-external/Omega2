#!/bin/ksh
#=============================================================================
# nom de l'application		: L&H - Automate treaty update (NTAP) 
#
# nom du script SHELL		  : ESFD0830.cmd
# revision			          : $Revision:   1.0  $
# date de creation		    : 29/04/2024
# auteur			            : S.Behague
# spira                   : 110557
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   L&H - Automate treaty update (NTAP)
#-----------------------------------------------------------------------------
# historique des modifications
# [01] - S.Behague 29/04/2024:spira:110557 - création
# [02] - S.Behague 01/10/2024:spira:111993 - NTAP automation - Parameters management
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2


#Get input parameters of ESCJ0000.prm
set `GETPRM ${DPRM}/ESCJ0000.prm`
CRE_D=$1

NJOB="ESFD9001"
. ${DCMD}/ESFD9001.cmd "${IDF_CT}"


#Get input parameters of ESFD0830.prm
set `GETPRM ${DPRM}/ESFD0830.prm`
UPDATE_DELAY_INF=$1
UPDATE_DELAY_SUP=$2


# Launch applicative job ESFD0831
NJOB="ESFD0831"
${DCMD}/ESFD0831.cmd ${CRE_D} ${PARAM_CUR_BOOKING_D} ${UPDATE_DELAY_INF} ${PARAM_CUR_PSTOMGEND17_D} ${UPDATE_DELAY_SUP} 


# Closing the Chain
CHAINEND
