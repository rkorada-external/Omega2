#!/bin/ksh
#=============================================================================
# nom de l'application          : I17G -APP4 (TL and cashflow data aggregation)
# nom du script SHELL           : ESF8000.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 18\09\2019
# auteur                        : Antoine GRUNWALD
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  IFRS17 REQ 12.3, REQ 12.7 and REQ 12.11 : TRETIFRS, TSECIFRS and TSEGPROF tables update
#-----------------------------------------------------------------------------
#[001] 26/01/2021 JYP : SPIRA 91991 : I17L/P not yet implemented
#[002] 02/01/2021 JYP : SPIRA 91991 : I17L/P activation
#[003] 28/11/2022 SURAJ P : SPIRA 107641 : Update table TI17CTRSML by closing
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


if [ ${NORME_CF} != "I17S" ] 
then
# Launch applicative job ESFD8001
NJOB="ESFD8001${TYPEINV}"
${DCMD}/ESFD8001.cmd | ${TEE}
	# Launch applicative job ESFD8004
	NJOB="ESFD8004${TYPEINV}"
	${DCMD}/ESFD8004.cmd | ${TEE}	
else
	# Launch applicative job ESFD8002
	NJOB="ESFD8002${TYPEINV}"
	${DCMD}/ESFD8002.cmd | ${TEE}
fi

# Launch applicative job ESFD8003
NJOB="ESFD8003${TYPEINV}"
${DCMD}/ESFD8003.cmd | ${TEE}



CHAINEND
