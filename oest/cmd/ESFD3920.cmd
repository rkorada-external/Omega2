#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD3920.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 18\06\2020
# auteur                        : KBagwe
#-----------------------------------------------------------------------------
# description
#  undiscounted NDIC (Non-Distinct Investment Component) base amounts calculation
#
#-----------------------------------------------------------------------------
# modif
# [01] 18/09/2020 C.SOCIE	SPIRA 88615 : LOCAL- change in NDIC batch architecture add ESFD3703A & ESID3702A
# [02] 01/04/2021 CAS 		SPIRA 94906 : NDI at closing - Change in VTOM
# [03] 28/01/2022 Bhimasen 	SPIRA 98794 : NDIC- curency issue
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

# R01-08 - NDIC incurred AE are I17G AE and are retrieved as follow :
#   filter I17G AE with FBOPRSLNK   on ESFD3923.cmd
#   filter NDIC incurred AE         on ESTS0066.cmd and java estj0008

# Launch applicative job ESFD3921
NJOB="ESFD3921${TYPEINV}"
${DCMD}/ESFD3921.cmd ${NORME_CF}  2>&1 | ${TEE}


# Launch applicative job ESFD3923
NJOB="ESFD3923${TYPEINV}"
${DCMD}/ESFD3923.cmd | ${TEE}


# Launch applicative job ESFD3922
NJOB="ESFD3922${TYPEINV}"
${DCMD}/ESFD3922.cmd | ${TEE}


CHAINEND