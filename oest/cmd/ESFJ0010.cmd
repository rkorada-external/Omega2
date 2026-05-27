#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - PREREQUIS OPTIMISATION ESFD2220.cmd
#                                  split ARCSTATGTA ; convert Binary to TEXT
# nom du script SHELL           : ESFJ0011.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 12/07/2019
# auteur                        : M.NAJI
# references des specifications :
#-----------------------------------------------------------------------------
# description :
#               split ARCSTATGTA ; convert Binary to TEXT
#
#-----------------------------------------------------------------------------
# historique des modifications :
#[001] 12/07/2019 : M.NAJI cration 
#[002] 20/11/2020 R. Cassis  :spira:99999 Mise en commentaire ESFJ0012
#===============================================================================

#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

CHAININIT $0 $1

# Launch  job ESFJ0011
JOB="ESFJ0011"
${DCMD}/ESFJ0011.cmd $DFILP/${ENV_PREFIX}_ESIX7000_ARCSTATGTA.dat 4 2>&1 | ${TEE}

# Launch  job ESFJ0012 [002]
#JOB="ESFJ0012"
#${DCMD}/ESFJ0012.cmd  2>&1 | ${TEE}

CHAINEND

