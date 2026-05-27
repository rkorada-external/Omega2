#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 granularity
# nom du script SHELL           : ESFD3940.cmd
# date de creation              : 09/09/2020
# auteur                        : JYP - PERSEE
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  : IFRS17 Granularity product management
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[001] 09/09/2020 JYP : creation
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

IDF_CT=$2

# Chain Initialization variables
CHAININIT $0 $1


NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd ${IDF_CT}


# Launch applicative job ESFD3931 
NJOB="ESFD3941${TYPEINV}"
${DCMD}/ESFD3941.cmd 2>&1 | ${TEE}


CHAINEND
