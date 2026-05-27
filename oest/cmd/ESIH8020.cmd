#!/bin/ksh
#=============================================================================
# nom de l'application      : ESTIMATE
#                           : AGEING BALANCE
# nom du script SHELL       : ESIH8020.cmd
# revision                  : $Revision:   1.0  $
# date de creation          : 05/02/2008
# auteur                    : VAN DE VELDE JF
# references des specifications : 
#-----------------------------------------------------------------------------
# description :  TRAITEMENT SECIFIQUE A LA FILIALE 19 SCOR U.K ( ex REVIOS )
#  SELECT THE MOVEMENTS OF THE TABLE BSTA..TCURTRS (acceptance - retrocession) 
#  UPDATING OF THE TABLE BSTA..TDEBCRED_2
#----------------------------------------------------------------------------
# historiques des modifications :
#  <jj/mm/aaaa>	  <auteur>	 <description de la modification>
#
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1 

# Get Input parameters
set `GETPRM ${DPRM}/ESIH8020.prm` 
DATE_T=$1
FORCE_DTE=$2
SSD_CF=$3
echo "${DCMD}/ESIH8021.cmd ${DATE_T} ${FORCE_DTE} ${SSD_CF}"
# 
# Launch applicative job ESIH8020  
NJOB="ESIH8021"
${DCMD}/ESIH8021.cmd ${DATE_T} ${FORCE_DTE} ${SSD_CF} N 2>&1 | ${TEE}


CHAINEND
