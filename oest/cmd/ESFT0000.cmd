#!/bin/ksh
#=========================================================================================================================
# APPLICATION NAME          		: TRANSITION
# CHAIN                 			: ESFT0000.cmd
# REVISION                     		: 1.0 
# CREATION DATE              		: 22/04/2020
# AUTHOR                        	: L.ELFAHIM
#=========================================================================================================================
#-------------------------------------------------------------------------------------------------------------------------
# DESCRIPTION - SPIRA 86487 - TRANSITION MANAGEMENT :
#
#-------------------------------------------------------------------------------------------------------------------------
# CHANGES HISTORY :
#=========================================================================================================================
# 	<JJ/MM/AAAA>   	<AUTHOR>   	<SPIRA> 	<DESCRIPTION OF A CHANGE>
#	22/04/2020		L.ELFAHIM	86487		DEVELOPMENT OF INITIAL VERSION
#	29/04/2020		L.ELFAHIM	82716		PROJECTIONS FROM INCEPTION TO TRANSITION DATE ONE-OFF STEP AND CSF
#   12/05/2020  	JYP         82719       add job ESFT0003 - RA files
#   08/06/2020  	JYP         82719       comment ESFT0002 - ICR/CSF files
#=========================================================================================================================

#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2

NJOB="ESFD9001"
# Launch job to set context
. ${DCMD}/ESFD9001.cmd  ${IDF_CT}

export TYPEINV0=$TYPEINV0

if [ ${PARM_IS_TRN} = "YES" ]
then
	# Launch TRANSITION jobs
	NJOB="ESFT0001"
	${DCMD}/ESFT0001.cmd  $3 2>&1 | ${TEE}

	#NJOB="ESFT0002"
	#${DCMD}/ESFT0002.cmd  2>&1 | ${TEE}

	NJOB="ESFT0003"
	${DCMD}/ESFT0003.cmd  2>&1 | ${TEE}
else
	echo  "#============================================================================================"  2>&1 | ${TEE}
	echo  "#=== TRANSITION not activated, to do so, put TI17TRAPERMFIL as VTOM parameter on ESFJ0000 ==="  2>&1 | ${TEE}
	echo  "#============================================================================================"  2>&1 | ${TEE}
fi

CHAINEND