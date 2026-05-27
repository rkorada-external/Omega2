#!/bin/ksh
#=============================================================================
# nom de l'application          : EBS
# nom du script SHELL           : ESFD5020.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 10\02\2021
# auteur                        : Cyril AVINENS
# references des specifications :
#-----------------------------------------------------------------------------
# Description
#  Extend a pericase EBS with TCR/TSECIFRS data in order to generate a IFRS17 pericase
#-----------------------------------------------------------------------------
#[001] 08/11/2022 DAD  : Spira 107518 : add new job ESFD5024 for Generate IADPERICASE DUMMY STD 
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

if [ ${TYPEINV} = "INV" -o ${TYPEINV} = "POS" ] 
then


ECHO_LOG "#============================================================================"
ECHO_LOG "#===> CONTEXT_CT.............................................................: ${CONTEXT_CT}"
ECHO_LOG "#============================================================================"

	# Launch applicative job ESFD5021
	NJOB="ESFD5021${TYPEINV}"
	${DCMD}/ESFD5021.cmd | ${TEE}

if [ ${CONTEXT_CT} = "INI" ] 
then
	# Launch applicative job ESFD5022
	NJOB="ESFD5022${TYPEINV}"
	${DCMD}/ESFD5022.cmd ${EST_IRDPERICASE} ${EST_IRDPERICASE_I17} | ${TEE}
	
	# Launch applicative job ESFD5023
	NJOB="ESFD5023${TYPEINV}"
	${DCMD}/ESFD5023.cmd | ${TEE}
	
	# Launch applicative job ESFD5022
	NJOB="ESFD5022${TYPEINV}"
	${DCMD}/ESFD5022.cmd ${EST_IADPERICASE_DUMMY} ${EST_IADPERICASE_DUMMY_I17} | ${TEE}
	
fi

if [ ${CONTEXT_CT} = "STD" ] 
then
	# Launch applicative job ESFD5022
	NJOB="ESFD5022${TYPEINV}"
	${DCMD}/ESFD5022.cmd ${EST_IRDPERICASE0} ${EST_IRDPERICASE0_I17} | ${TEE}
	
	# Launch applicative job ESFD5022
	NJOB="ESFD5022${TYPEINV}"
	${DCMD}/ESFD5022.cmd ${EST_OIRDVPERICASE} ${EST_OIRDVPERICASE_I17} | ${TEE}
	
	#[001]
	# Launch applicative job ESFD5024
	NJOB="ESFD5024${TYPEINV}"
	${DCMD}/ESFD5024.cmd | ${TEE}
	
fi
else

ECHO_LOG ""
ECHO_LOG "#============================================================================"
ECHO_LOG "# Batch run only when TYPEINV = INV or POS "
ECHO_LOG "# TYPEINV = ${TYPEINV} "
ECHO_LOG "#============================================================================"
ECHO_LOG ""

fi

CHAINEND
