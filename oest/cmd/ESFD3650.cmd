#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 req 12.1 
# nom du script SHELL           : ESFD3650.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 02/04/2019
# auteur                        : JYP - PERSEE
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  : SPIRA REQ 12.01 - IFRS17- Closing schedule : Risk Adjustement calculation
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[001] 02/04/2019 JYP : Risk Adjusment Calculations
#[002] 30/0832021 : M.AJI SPIRA:91532 EST_PARAM n'est plu utilisé
#===========================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2
DEBUGLEVEL=$3  # ESFC3650.log level : 0=default/minimum  1=medium  >=2 more detailled  



NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd ${IDF_CT}


# Launch applicative job ESFD3651 
NJOB="ESFD3651${TYPEINV}"
${DCMD}/ESFD3651.cmd ${IDF_CT} ${DEBUGLEVEL} 2>&1 | ${TEE}


# Launch applicative job ESFD3703A
NJOB="ESFD3703A${TYPEINV}"
${DCMD}/ESFD3703A.cmd ${IDF_CT} 2>&1 | ${TEE}


CHAINEND
