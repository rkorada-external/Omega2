#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Inventaire dommages
# nom du script SHELL           : SPLITFL0.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 12/07/2019
# auteur                        : M.NAJI
# references des specifications :
#-----------------------------------------------------------------------------
# description :
#              SPLIT ARCSTATGTA
#
#-----------------------------------------------------------------------------
# historique des modifications :
#[001] 12/07/2019 : M.NAJI cration 
#===============================================================================

#set -x




# Call generic functions
. ${DUTI}/fctgen.cmd

CHAININIT $0 $1


# Launch  job SPLITFL1
JOB="SPLITFL1"
${DCMD}/SPLITFL1.cmd $FILE_TO_SPLIT 4 2>&1 | ${TEE}


CHAINEND

