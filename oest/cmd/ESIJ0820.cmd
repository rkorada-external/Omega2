#!/bin/ksh
#=============================================================================
# nom de l'application		: L&H - Automate treaty update (NTAP) 
#
# nom du script SHELL		  : ESIJ0820.cmd
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

set `GETPRM ${EST_PARAM}`
BALSHYEA=$2
BALSHTMTH=$3


#Get input parameters of ESCJ0000.prm
set `GETPRM ${DPRM}/ESCJ0000.prm`
CRE_D=$1

#Get input parameters of ESIJ0820.prm
#set `GETPRM ${DPRM}/ESIJ0820.prm`
#BALSHYEA=$1
#BALSHTMTH=$2


# Variable initialisation 
# -------------------------------------
DATEJOUR=`date +"%m/%d/%Y"`
V_DATE_JOUR=`date +"%Y%m%d"`

# Launch applicative job ESIJ0821
NJOB="ESIJ0821"
${DCMD}/ESIJ0821.cmd ${CRE_D} ${BALSHYEA} ${BALSHTMTH}



# Closing the Chain
CHAINEND
