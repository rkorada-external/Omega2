#!/bin/ksh
#=============================================================================
# nom de l'application          : UTILITAIRE POUR LE NON ENCHAINEMENT NETMONITOR
#                                                                
# nom du script SHELL           : NMLINK00.cmd
# revision                      : $Revision: 1.1 $
# date de creation              : 27/05/98
# auteur                        : S.C.O.R.    
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#   Permet de ne pas executer les UP suivantes dans Netmonitor
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

NJOB="NMLINK01"
# Launch applicative job NMLINK01
${DUTI}/NMLINK01.cmd 2>&1 | ${TEE}

CHAINEND
