#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD3720.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 29\08\2019
# auteur                        : Antoine GRUNWALD
#-----------------------------------------------------------------------------
# description
#  IFRS17 REQ 12.3 : CSM at CR level calculation
#
#-----------------------------------------------------------------------------
# modif
# [01] 18/01/2024 FCI 	SPIRA 101276 : Internal Assumed - IFRS 17 info
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


NCHAIN_PARAM=`echo ${ARG2_CHN_2} `
 
ECHO_LOG "#===> PARAMS_ESFD3720.............................: "
ECHO_LOG "#===> NCHAIN_PARAM................................: ${NCHAIN_PARAM}"
ECHO_LOG "#===> NCHAIN...(zip name).........................: ${NCHAIN}"
 
## Traitement specifique pour NTC TRNCOD INI  
if [ "${IDF_CT}" = "I17G_CSM_CRE_INI" ] 
then    
		NCHAIN_PARAM=CSM
fi 

export EXTCHAIN=${ENV_PREFIX}_${NCHAIN_PARAM}_${NORME_CF}
export NCHAIN_SHORT=${NCHAIN_PARAM}_${NORME_CF}

ECHO_LOG "#===> PARAMS_TEFJ0011.............................: "
ECHO_LOG "#===> EXTCHAIN..........GET_ZIP_CHAIN...................: ${EXTCHAIN}"
ECHO_LOG "#===> REMOTE_SITE.......GET_ZIP_I......................: ${REMOTE_SITE}"


NJOB="TEFJ0011"
# Launch technical job TEFJ0011
# Fetching of TL files from the estimation chain ESFD3720
${DUTI}/TEFJ0011.cmd ${IDF_CT}  2>&1 | ${TEE}


if [ ! -f ${DFILT}/TEFJ0011_05_*_GETSITES_O.dat ]; then
	ECHO_LOG "pas de GETSITES_O.dat "
else
	ECHO_LOG "#===> ${DFILT}/TEFJ0011_05_${IB}_GETSITES_O.dat.............................: existe"
fi

export OLD_CHAIN=${NCHAIN}


# Launch applicative job ESFD3721
NJOB="ESFD3721${TYPEINV}"
${DCMD}/ESFD3721.cmd | ${TEE}



CHAINEND
