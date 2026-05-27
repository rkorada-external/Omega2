#!/bin/ksh
#=============================================================================
# nom de l'application          : I17G - Transition File generation
# nom du script SHELL           : ESFT0010.cmd
# revision                      : 
# date de creation              : 18\06\2020
# auteur                        : Arnaud RUFFAULT
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  The goal of this chain is to initialize the Transition File (CSUOE perimeter for Assumed and CU perimeter for Retro)
#-----------------------------------------------------------------------------
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

if [ ${PARM_IS_TRN} = "YES" ]
then

echo  "#============================================================================================"  2>&1 | ${TEE}
echo  "#=== TRANSITION is activated"  2>&1 | ${TEE}
echo  "#============================================================================================"  2>&1 | ${TEE}


# Launch applicative job ESFT0021
NJOB="ESFT0021${TYPEINV}"
${DCMD}/ESFT0021.cmd | ${TEE}

# Launch applicative job ESFT0022
NJOB="ESFT0022${TYPEINV}"
${DCMD}/ESFT0022.cmd | ${TEE}

else
	echo  "#============================================================================================"  2>&1 | ${TEE}
	echo  "#=== TRANSITION not activated, to do so, put TI17TRAPERMFIL as VTOM parameter on ESFJ0000 ==="  2>&1 | ${TEE}
	echo  "#============================================================================================"  2>&1 | ${TEE}
fi

CHAINEND