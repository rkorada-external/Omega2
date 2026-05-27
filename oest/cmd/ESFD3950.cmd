#!/bin/ksh
#=================================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD3950.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 14\10\2020
# auteur                        : Charles SOCIE
#---------------------------------------------------------------------------------
# description
#  IFRS17 NDIC RETRO
#
#---------------------------------------------------------------------------------
# modif
# [01] 23/03/2022 Bhimasen 	SPIRA 98794 : NDIC- curency issue
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


# R01-19 - I17G Incurred Retro NDIC AEs retrieval as follow :
#   agregates I17G AE by placement              on ESFD3953.cmd
#   filter I17G AE by placementwith FBOPRSLNK   on ESFD3953.cmd
#   filter NDIC incurred AE                     on ESTS0067.cmd and java estj0010

# Launch applicative job ESFD3952
NJOB="ESFD3952${TYPEINV}"
${DCMD}/ESFD3952.cmd | ${TEE}


# Launch applicative job ESFD3953
NJOB="ESFD3953${TYPEINV}"
${DCMD}/ESFD3953.cmd | ${TEE}


# Launch applicative job ESFD3951
NJOB="ESFD3951${TYPEINV}"
${DCMD}/ESFD3951.cmd | ${TEE}

CHAINEND