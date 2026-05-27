#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17/EBS
# nom du script SHELL           : ESPT0030.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 08\10\2019
# auteur                        : Cyril AVINENS
#-----------------------------------------------------------------------------
# description
#  		IFRS17/EBS : Manualy Pattern renewal process, spira 99072
#
#-----------------------------------------------------------------------------
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Extracting all inputs data to renewal manualy pattern
set `GETPRM ${DPRM}/ESPT0030.prm`

export P_ICLODAT_D=$1
export P_NORME_CF=$2
export P_TYPEINV=$3
export P_OBJECT=$4


IDF_CT=${P_NORME_CF}_ESPT0030
	

# Launch job to set context
NJOB="ESFD9001"
. ${DCMD}/ESFD9001.cmd ${IDF_CT}



# Launch applicative job ESPT0031
NJOB="ESPT0031${P_TYPEINV}"
${DCMD}/ESPT0031.cmd | ${TEE}

CHAINEND
