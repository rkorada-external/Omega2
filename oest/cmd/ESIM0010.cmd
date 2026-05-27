#!/bin/ksh
#=============================================================================
# nom de l'application      : ESTIMATE
#                           : AGEING BALANCE
# nom du script SHELL       : ESIM0010.cmd
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
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1 

# Recupere les parametres d'entree
set `GETPRM ${DPRM}/ESIM0010.prm` 
DATE_T=$1
SSD_CF=$2

# Launch applicative job ESIM0010  
NJOB="ESIM0011"
${DCMD}/ESIM0011.cmd ${DATE_T} ${SSD_CF} ${HOST_PRDSIT} 2>&1 | ${TEE}


CHAINEND
