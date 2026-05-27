#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - EBS / I17 Cancellation and Booking
# nom du script SHELL           : ESFD7000.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 02/02/2021
# auteur                        : Roger Cassis
# references des specifications : Spira : 91379
#-----------------------------------------------------------------------------
# description
#  IFRS17 Spira : 91379 Demand, Quaterly and Yearly I17 Booking
#-----------------------------------------------------------------------------
#[001] 03/11/2021 R.CASSIS SPIRA 91532 : ESFD7003 tourne pas au dernier trimestre annuel
#[002] 15/12/2021 R.CASSIS SPIRA 100487-101117 : Ajustage conditions pour posting EBS et I17
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


# Launch applicative job ESFD7001 Append into CUR
NJOB="ESFD7001${VNORME}${TYPEINV}"
${DCMD}/ESFD7001.cmd | ${TEE}

# Launch applicative job ESFD7002 generate Reject data
NJOB="ESFD7002${VNORME}${TYPEINV}"
${DCMD}/ESFD7002.cmd | ${TEE}

CHAINEND
