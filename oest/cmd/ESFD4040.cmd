#!/bin/ksh
#=============================================================================
# nom de l'application          : Discount at current and locked in rate calculation 
# nom du script SHELL           : ESFD4040.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 10\03\2021
# auteur                        : Charles SOCIE
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  TI17CTRINFO update table
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[001]
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
IDF_CT=$2

NJOB="ESFD9001"
# Launch job to set context
. ${DCMD}/ESFD9001.cmd  ${IDF_CT}

# Launch applicative job ESFD4041 Creation of pericase extended file
NJOB="ESFD4041${TYPEINV}"
${DCMD}/ESFD4041.cmd  2>&1 | ${TEE}

# Launch applicative job ESFD4042 merge of pericase extended file and delte duplicate
NJOB="ESFD4042${TYPEINV}"
${DCMD}/ESFD4042.cmd  2>&1 | ${TEE}

# Launch applicative job ESFD4043 Insertion of pericase extended file in data base
NJOB="ESFD4043${TYPEINV}"
${DCMD}/ESFD4043.cmd  2>&1 | ${TEE}

CHAINEND
