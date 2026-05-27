#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 chargement CNA
# nom du script SHELL           : ESTD2530.cmd
# revision                      : $Revision:   1.24  $
# date de creation              : 22/01/04
# auteur                        : J. RIBOT
# references des specifications : SPOT-5079
#-----------------------------------------------------------------------------
# description
#   Life
#   Launch applicative jobs  ESTD2531
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================
#set -x


#-=-=-=-=-=-=-=-=-=-=-=
# Input files

#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get the parameters

# Launch applicative job ESTD2531
NJOB="ESTD2531"
${DCMD}/ESTD2531.cmd  2>&1 | ${TEE}

CHAINEND

