#!/bin/ksh
#=============================================================================
# nom de l'application      : ESTIMATE
#                           : AGEING BALANCE a partir de la date de document en mode simulation
# nom du script SHELL       : ESID8890.cmd
# revision                  : $Revision:   1.0  $
# date de creation          : 13/05/2008
# auteur                    : JF VDV
# references des specifications :
#-----------------------------------------------------------------------------
# description :
#----------------------------------------------------------------------------
# historiques des modifications :
#  <jj/mm/aaaa>	  <auteur>	 <description de la modification>

#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get Input parameters
set `GETPRM ${DPRM}/ESID8890.prm`
DATE_T=$1
FORCE_DTE=$2
SSD_CF=$3
SIMULATION=$4
#
# Launch applicative job ESIH8021
NJOB="ESIH8021"
${DCMD}/ESIH8021.cmd ${DATE_T} ${FORCE_DTE} ${SSD_CF} ${SIMULATION} 2>&1 | ${TEE}

CHAINEND
