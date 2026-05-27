#!/bin/ksh
#=================================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD3890.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 20\08\2020
# auteur                        : Michael SEKBRAOUDINE
#---------------------------------------------------------------------------------
# description
#  IFRS17 REQ 11.9 : AOC- Experience Adjustement
#
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

# Launch applicative job ESFD3891
NJOB="ESFD3891"
${DCMD}/ESFD3891.cmd ${ICLODAT_D} | ${TEE}

CHAINEND

