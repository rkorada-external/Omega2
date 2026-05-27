#!/bin/ksh
#=============================================================================
# nom de l'application          : Omega extract generation
# nom du script SHELL           : ESFT0010.cmd
# revision                      : 
# date de creation              : 30\06\2020
# auteur                        : Arnaud RUFFAULT
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  The goal of this chain is to generate the omega extract file
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

# Get Chain parameters
set `GETPRM ${DPRM}/ESFT0010.prm`
export PARM_TRA_Q_DATE=$1

# Launch applicative job ESFT0011
NJOB="ESFT0011${TYPEINV}"
${DCMD}/ESFT0011.cmd | ${TEE}

else
	echo  "#============================================================================================"  2>&1 | ${TEE}
	echo  "#=== TRANSITION not activated, to do so, put TI17TRAPERMFIL as VTOM parameter on ESFJ0000 ==="  2>&1 | ${TEE}
	echo  "#============================================================================================"  2>&1 | ${TEE}
fi

CHAINEND