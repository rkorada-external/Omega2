#!/bin/ksh
#=============================================================================
# nom de l'application		: L&H - Automate treaty update (NTAP) 
#
# nom du script SHELL		  : ESIJ0830.cmd
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
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd

# Chain Initialization variables
CHAININIT $0 $1

set `GETPRM ${EST_PARAM}`
BALSHYEA=$2
BALSHTMTH=$3

#Get input parameters of ESCJ0000.prm
set `GETPRM ${DPRM}/ESCJ0000.prm`
CRE_D=$1


# Variable initialisation 
# -------------------------------------
DATEJOUR=`date +"%m/%d/%Y"`
V_DATE_JOUR=`date +"%Y%m%d"`

# Launch applicative job ESIJ0831
NJOB="ESIJ0831"
${DCMD}/ESIJ0831.cmd ${CRE_D}


# Closing the Chain
CHAINEND
