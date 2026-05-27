#!/bin/ksh
#=================================================================================
# nom de l'application          : IRFS17 NIGHT CLOSING
# nom du script SHELL           : ESFD3780.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 04\06\2020
# auteur                        : Cyril AVINENS
#---------------------------------------------------------------------------------
# Description
#	Spira #85996
#	IFRS17 REQ05 : Profitability Interface SAS > O2
#---------------------------------------------------------------------------------
#=================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
IDF_CT=$2

# Launch job to set context
NJOB="ESFD9001"
. ${DCMD}/ESFD9001.cmd ${IDF_CT}

# Launch applicative job ESFD3861
NJOB="ESFD3861${TYPEINV}"
${DCMD}/ESFD3861.cmd | ${TEE}

# Launch applicative job ESFD3862
NJOB="ESFD3862${TYPEINV}"
${DCMD}/ESFD3862.cmd | ${TEE}

CHAINEND