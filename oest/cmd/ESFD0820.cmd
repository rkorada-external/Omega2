#!/bin/ksh
#=============================================================================
# nom de l'application		: L&H - Automate treaty update (NTAP) 
#
# nom du script SHELL		  : ESFD0820.cmd
# revision			          : $Revision:   1.0  $
# date de creation		    : 11/04/2024
# auteur			            : S.Behague
# spira                   : 110557
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   L&H - Automate treaty update (NTAP)
#-----------------------------------------------------------------------------
# historique des modifications
# [01] - S.Behague 11/04/2024:spira:110557 - création
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


# Launch applicative job ESFD0821
NJOB="ESFD0821"
${DCMD}/ESFD0821.cmd ${CRE_D} ${PARM_BALSHEYEA_NF} ${PARM_ICLODAT_D}


# Closing the Chain
CHAINEND
