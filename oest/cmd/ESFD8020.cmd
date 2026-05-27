#!/bin/ksh
#=================================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD8020.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 06\10\2021
# auteur                        : Arnaud RUFFAULT
#---------------------------------------------------------------------------------
# description
#  Auto-renewal of estimates patterns and ratios
#
#---------------------------------------------------------------------------------
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


if [ ${TYPEINV} = "INV" -o ${TYPEINV} = "POS" ]
then

if [ ${NORME_CF} = "I4I" -a ${PARM_SEQ_MODE} = "1" ]
then
	# Launch applicative job ESFD8021
	NJOB="ESFD8021${TYPEINV}"
	${DCMD}/ESFD8021.cmd | ${TEE}
fi

if [ ${NORME_CF} = "EBS" ]
then
	# Launch applicative job ESFD8022
	NJOB="ESFD8022${TYPEINV}"
	${DCMD}/ESFD8022.cmd | ${TEE}
fi

if [ ${NORME_CF:0:3} = "I17" ]
then
	# Launch applicative job ESFD8023
	NJOB="ESFD8023${TYPEINV}"
	${DCMD}/ESFD8023.cmd | ${TEE}
fi


if [ ${NORME_CF} = "I4I" -a ${PARM_SEQ_MODE} = "0" ]
then
ECHO_LOG "Nothing to do when NORME_CF = I4I and PARM_SEQ_MODE = 0"
fi

else

ECHO_LOG "TYPEINV is not INV or POS, nothing to do"

fi



CHAINEND