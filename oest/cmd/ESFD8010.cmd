#!/bin/ksh
#=============================================================================
# nom de l'application          : IFRS17 Booking
# nom du script SHELL           : ESF8010.cmd
# revision                      : 
# date de creation              : 10\04\2020
# auteur                        : Arnaud RUFFAULT
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  Spira 82867 IFRS 17- Booking (TSECIFRS, TCR update)
#  Spira 75828 IFRS17- Set FCLODAT_D (first closing date) during POS IFRS 17 booking
#
#-------------------------Modification----------------------------------------
#
# MOD1 29/04/2020 ?? 				Spira 86253 IFRS17 - retro contract Inception (TRETIFRS update)
# MOD2 18/02/2020 Charles SOCIE 	Spira 70380 REQ 1000.07 - Patterns, RA ratio and IFRS 17 expenses ratio automatic renewal
# MOD3 12/10/2021 A.RUFFAULT :spira:99072 EST - IFRS17/EBS- Isolate pattern renewal procees in dedicated batch chain
#-----------------------------------------------------------------------------
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

export USER_ESFD8010=BOOK

# Get entry parameters
IDF_CT=$2

# Launch job to set context
NJOB="ESFD9001"
. ${DCMD}/ESFD9001.cmd ${IDF_CT}

# Launch applicative job ESFD8011
NJOB="ESFD8011${TYPEINV}"
${DCMD}/ESFD8011.cmd | ${TEE}

# Launch applicative job ESFD8012
NJOB="ESFD8012${TYPEINV}"
${DCMD}/ESFD8012.cmd | ${TEE}

# Launch applicative job ESFD8013
NJOB="ESFD8013${TYPEINV}"
${DCMD}/ESFD8013.cmd | ${TEE}

# Launch applicative job ESFD8014
NJOB="ESFD8014${TYPEINV}"
${DCMD}/ESFD8014.cmd | ${TEE}

# Launch applicative job ESFD8015
NJOB="ESFD8015${TYPEINV}"
${DCMD}/ESFD8015.cmd | ${TEE}

#MOD1
# Launch applicative job ESFD8016
NJOB="ESFD8016${TYPEINV}"
${DCMD}/ESFD8016.cmd | ${TEE}

##MOD3
###MOD2
### Launch applicative job ESFD8016
##NJOB="ESFD8017${TYPEINV}"
##${DCMD}/ESFD8017.cmd | ${TEE}

CHAINEND
