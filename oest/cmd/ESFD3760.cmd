#!/bin/ksh
#===================================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD3760.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 10\10\2019
# auteur                        : Cyril AVINENS
#-----------------------------------------------------------------------------------
# description
#  IFRS17 REQ 12.7 : UoA signature at subsequent measurement
#
#-----------------------------------------------------------------------------------
#===================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
IDF_CT=$2

# Launch job to set context
NJOB="ESFD9001"
. ${DCMD}/ESFD9001.cmd ${IDF_CT}

# Launch applicative job ESFD3762
NJOB="ESFD3762${TYPEINV}"
${DCMD}/ESFD3762.cmd | ${TEE}

# Launch applicative job ESFD3761
NJOB="ESFD3761${TYPEINV}"
${DCMD}/ESFD3761.cmd | ${TEE}

CHAINEND