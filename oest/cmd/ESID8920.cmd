#!/bin/ksh
#=============================================================================
# nom de l'application      : ESTIMATE
#                           : Company Creditor/Debitor by simulation
# nom du script SHELL       : ESID89200.cmd
# revision                  :
# date de creation          : 03/12/2009
# auteur                    : JF VDV
# references des specifications :
#-----------------------------------------------------------------------------
# description :  [18356] - Mise en place d'un traitement SDC par simulation
#----------------------------------------------------------------------------
# historiques des modifications :
#  <jj/mm/aaaa>	  <auteur>	 <description de la modification>
#
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd
# Chain Initialization variables
CHAININIT $0 $1

# Get Input parameters
set `GETPRM ${DPRM}/ESID8920.prm`
DATE_T=$1
FORCE_DTE=$2
SSD_CF=$3
SIMULATION=$4
#
# Launch applicative job ESIH8011
NJOB="ESIH8011"
LOOP_JOB_SSD ${DCMD}/ESIH8011.cmd ${SSD_CF} ${DATE_T} ${FORCE_DTE} ${HOST_PRDSIT} ${SIMULATION} 2>&1 | ${TEE}

CHAINEND
