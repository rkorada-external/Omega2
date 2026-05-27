#!/bin/ksh
#=============================================================================
# nom de l'application         : ESTIMATION - EBS / I17 Opening data Generation
# nom du script SHELL          : ESFD2900.cmd
# revision                     : $Revision:   1.2  $
# date de creation             : 23/12/2020
# auteur                       : Roger Cassis
# references des specifications: spira:91379
#-----------------------------------------------------------------------------
# description
#  IFRS17 Spira : 91379 I17 - Opening data Generation and add it to CUR_FTECLEDA-R files
#-----------------------------------------------------------------------------
#[001] 15/12/2021 R.CASSIS :spira:101117 Adaptation a la norme EBS
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
IDF_CT=$2

# Launch job to set context
NJOB="ESFD9001"
. ${DCMD}/ESFD9001.cmd ${IDF_CT}

# Launch applicative job ESFD2901
NJOB="ESFD2901${NORME_CF}${TYPEINV}"
${DCMD}/ESFD2901.cmd | ${TEE}

CHAINEND
