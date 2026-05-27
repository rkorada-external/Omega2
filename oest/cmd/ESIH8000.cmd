#!/bin/ksh
#=============================================================================
# nom de l'application      : ESTIMATE
#                           : AGEING BALANCE
# nom du script SHELL       : ESIH8000.cmd
# revision                  : $Revision:   1.0  $
# date de creation          : 16/07/98
# auteur                    : VAN DE VELDE JF
# references des specifications : 
#-----------------------------------------------------------------------------
# description :
#  SELECT THE MOVEMENTS OF THE TABLE BSTA..TCURTRS (acceptance - retrocession) 
#  UPDATING OF THE TABLE BSTA..TDEBCRED
#----------------------------------------------------------------------------
# historiques des modifications :
#  <jj/mm/aaaa>	  <auteur>	 <description de la modification>
#   18/12/2002  D.GATIBELZA  Rajout de la variable de simulation.
#                            ( Parametre SIMULATION force a 'N')
#
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1 

# Get Input parameters
set `GETPRM ${DPRM}/ESIH8000.prm` 
DATE_T=$1
FORCE_DTE=$2
SSD_CF=$3
# 
# Launch applicative job ESIH8000  
NJOB="ESIH8001"
${DCMD}/ESIH8001.cmd ${DATE_T} ${FORCE_DTE} ${SSD_CF} N 2>&1 | ${TEE}


CHAINEND
