#!/bin/ksh
#=============================================================================================
# APPLICATION NAME          		: ACF/PCA: Impact Revenue Calculation
# CHAIN                 			: ESFD3640.cmd
# REVISION                     		: V1   
# CREATION DATE              		: 09/08/2021
# AUTHOR                        	: L.ELFAHIM
#=============================================================================================
#---------------------------------------------------------------------------------------------
# DESCRIPTION - SPIRA 97373 - ACF/PCA: Impact Revenue Calculation
#---------------------------------------------------------------------------------------------
# CHANGES HISTORY :
#=============================================================================================
#	09/08/2021	LEL	SPIRA : 97373	ACF/PCA: Impact Revenue Calculation
#=============================================================================================

#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2

NJOB="ESFD9001"
# Launch job to set context
. ${DCMD}/ESFD9001.cmd  ${IDF_CT}

export TYPEINV0=$TYPEINV

# PERIMETER files preparation
NJOB="ESFD3641"
${DCMD}/ESFD3641.cmd   2>&1 | ${TEE}

if [ "${PARM_IS_TRN}" = "YES" ]
then
# Launch TRANSITION job
NJOB="ESFT0005"
${DCMD}/ESFT0005.cmd  2>&1 | ${TEE}
fi

# CSF files preparation
NJOB="ESFD3643"
${DCMD}/ESFD3643.cmd   2>&1 | ${TEE}

# UPR, ITD, CHARGES preparation
NJOB="ESFD3642"
${DCMD}/ESFD3642.cmd   2>&1 | ${TEE}

CHAINEND
