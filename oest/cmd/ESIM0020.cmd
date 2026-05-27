#!/bin/ksh
#=============================================================================
# nom de l'application      : ESTIMATES
#                           : COMPANY DEBITOR/CREDITOR 
# nom du script SHELL       : ESIM0020.cmd
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
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1 

# Recupere les parametres d'entree
set  `GETPRM ${DPRM}/ESIM0020.prm`
SSD_CF=$1
# Launch applicative job ESIM0020  
NJOB="ESIM0021"
${DCMD}/ESIM0021.cmd ${SSD_CF} ${HOST_PRDSIT} 2>&1 | ${TEE}


CHAINEND
