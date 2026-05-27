#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESF4080.cmd
# date de creation              : 02/04/2025
# auteur                        : S. Behague
#-----------------------------------------------------------------------------
# description:
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#[001]  02/04/2025  S.Behague  : spira 111789
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

#=========
#========= Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2

NJOB="ESFD9001"
# Launch job to set context
. ${DCMD}/ESFD9001.cmd ${IDF_CT}


NJOB="ESFD4081"
${DCMD}/ESFD4081.cmd   2>&1 | ${TEE}



CHAINEND
