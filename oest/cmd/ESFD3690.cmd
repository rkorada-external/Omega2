#!/bin/ksh
#=============================================================================================
# APPLICATION NAME          		: IFRS17 REVENUE&CSM CALCULATION
# CHAIN                 			: ESFD3691.cmd
# REVISION                     		: $Revision:   1.0 
# CREATION DATE              		: 15/06/2019
# AUTHOR                        	: L.ELFAHIM
#=============================================================================================
#---------------------------------------------------------------------------------------------
# DESCRIPTION - SPIRA 70741 - REQ 11.06 - IFRS17 REVENUE&CSM CALCULATION :
#	- Calculation scope and bases identification
#	- Retrieve Discount Forward Closing Positions
#	- Change in EGPI
#	- Change in ESTIMATES
#	- CSM calculation EGPI
#	- CSM calculation ESTIMATES
#---------------------------------------------------------------------------------------------
# CHANGES HISTORY :
#=============================================================================================
#	15/06/2019	LEL	SPIRA : 70741	DEVELOPMENT OF INITIAL VERSION
#	19/07/2019	JYP	SPIRA : 70741	UPDATE 
#	20/03/2020	LEL	SPIRA : 82711	ADD JOB ESFD3692: DAC VARIABLES
#	11/06/2020	LEL	SPIRA : 82711	DEACTIVATE JOB ESFD3692
#	23/07/2020	LEL	SPIRA : 82711	REACTIVATE JOB ESFD3692
#	28/10/2020	LEL	SPIRA : 85404	ADD TRANSITION MANAGEMENT JOB ESFT0005
#	29/12/2020 	LEL SPIRA : 91111	ADD JOB ESFD3693 : CSF FILES PREPARATION
#	31/08/2021 	LEL SPIRA : 97373	ACF/PCA: IMPACT REVENUE CALCULATION
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

export TYPEINV0=$TYPEINV0 

NJOB="ESFD3691"
${DCMD}/ESFD3691.cmd  $3 2>&1 | ${TEE}

CHAINEND
