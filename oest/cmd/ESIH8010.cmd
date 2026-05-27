#!/bin/ksh
#=============================================================================
# nom de l'application      : ESTIMATES
#                           : COMPANY DEBITOR/CREDITOR 
# nom du script SHELL       : ESIH8010.cmd
# revision                  : $Revision:   1.0  $
# date de creation          : 16/07/98
# auteur                    : VAN DE VELDE JF
# references des specifications : 
#-----------------------------------------------------------------------------
# description :
#   SELECT THE MOVEMENTS OF THE TABLES TTCLEDA_X AND TTCLEDR_X 
#   UPDATING OF THE TABLE BSTA..TDEBCRED
#-----------------------------------------------------------------------------
# historiques des modifications :
#  <jj/mm/aaaa>	<auteur>	<description de la modification>
#  26/01/1999	van de velde	use LOOP to ssd	
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd   
# Chain Initialization variables
CHAININIT $0 $1 

# Get input parameters
set  `GETPRM ${DPRM}/ESIH8010.prm`
DATE_T=$1
FORCE_DTE=$2
SSD_CF=$3


# Launch applicative job ESIH8011  
NJOB="ESIH8011"
LOOP_JOB_SSD ${DCMD}/ESIH8011.cmd ${SSD_CF} ${DATE_T} ${FORCE_DTE} ${HOST_PRDSIT} 2>&1 | ${TEE}


CHAINEND
