#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD3750.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 15\10\2019
# auteur                        : Arnaud RUFFAULT
#-----------------------------------------------------------------------------
# description
#  IFRS17 REQ 12.5 : CSM/LC accretion
#  IFRS17 REQ 12.6 : T>0 profitability before amortisation
#  IFRS17 REQ 12.9 : CSM amortization
#
#-----------------------------------------------------------------------------
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
IDF_CT=$2

# Launch job to set context
NJOB="ESFD9001"
. ${DCMD}/ESFD9001.cmd ${IDF_CT}

# Launch applicative job ESFD3751
NJOB="ESFD3751${TYPEINV}"
${DCMD}/ESFD3751.cmd | ${TEE}

CHAINEND