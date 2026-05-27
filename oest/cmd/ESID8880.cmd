#!/bin/ksh
#=============================================================================
# nom de l'application      : ESTIMATE
#                           : AGEING BALANCE
# nom du script SHELL       : ESID8880.cmd
# revision                  : $Revision:   1.0  $
# date de creation          : 10/12/2002
# auteur                    : D.GATIBELZA
# references des specifications : 
#-----------------------------------------------------------------------------
# description :
#----------------------------------------------------------------------------
# historiques des modifications :
#  <jj/mm/aaaa>	  <auteur>	 <description de la modification>
#   03/12/2002  D.GATIBELZA  Rajout de la possibilité de demande de simulation.
#                            ( Paramètre supplémentaire SIMULATION )
#
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1 

# Get Input parameters
set `GETPRM ${DPRM}/ESID8880.prm` 
DATE_T=$1
FORCE_DTE=$2
SSD_CF=$3
SIMULATION=$4
# 
# Launch applicative job ESIH8001  
NJOB="ESIH8001"
${DCMD}/ESIH8001.cmd ${DATE_T} ${FORCE_DTE} ${SSD_CF} ${SIMULATION} 2>&1 | ${TEE}

CHAINEND
