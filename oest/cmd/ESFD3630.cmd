#!/bin/ksh
#===================================================================================================
# APPLICATION NAME         	: ESTIMATIONS - INVENTAIRE
# CHAIN NAME           		: ESFD3630.cmd
# REVISION                	: V1
# CREATION DATE            	: 20/02/2019
# AUTOR        				: L.ELFAHIM
#---------------------------------------------------------------------------------------------------
# DESCRIPTION :
# THIS CHAIN IS INTENDED TO MANAGE EXPENSES CALCULATION:
#  	- Inflated Incurred maintenance expenses prospective stock
#  	- Inflated Remaining maintenance expenses prospective stock
#	SPIRA 71570 : REQ 11.02 	- mainteance Expenses calculation:
#	SPIRA 69814 : REQ 11.01 	- Acquisition Expenses Calculation 
#	SPIRA 70537 : REQ 11.07 	- Acquisition Expenses Calculation && Maintenance at INCEPTION
#	SPIRA 79102 : REQ 11.03 	- RETRO NP Acquisition Expenses Calculation 
#	SPIRA XXXXX : REQ 11.07.02 	- RETRO NP Acquisition Expenses Calculation at INCEPTION
#	SPIRA 97351 : REQ 11/1,2,3 	- ACF/PCA: EXPENSES CALCULATION
#---------------------------------------------------------------------------------------------------
# MODIFICATION HISTORY:
#===================================================================================================
# <INDEX>	<JJ/MM/AAAA>   	<AUTOR>   	<SPIRA> 	< MODIFICATION DESCRIPTION>
#[000] 		20/02/2019 		LEL 		71570 		MAINTENANCE EXPENSES CALCULATION 
#[001]    	29/04/2019      JYP  		71570 		AVOID FAILURE FOR REQUEST WITHOUT TYPINV
#[002]     	12/02/2020      LEL 		79102 		RETRO NP EXPENSES MANAGEMENT
#[003]     	26/08/2021      LEL      	97351       ACF/PCA: EXPENSES CALCULATION
#[004]     	13/10/2021      LEL      	99572       NO MORE IAE CALCULATION ON RETRO : REMOVE job ESFD3672 
#[005]     	22/05/2023      HR      	108487      IAE and IME Paid - Add conversion 
#===================================================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1         
IDF_CT=$2

NJOB="ESFD9001"
# Launch job to set context
. ${DCMD}/ESFD9001.cmd  ${IDF_CT}

# LAUNCH APPLICATIVE JOB ESFD3631 MAINTEANCE EXPENSES MANAGEMENT
NJOB="ESFD3631_${TYPEINV}"
${DCMD}/ESFD3631.cmd ${PARM_ICLODAT_D} ${PER_CF}  2>&1 | ${TEE}

if [ ${CONTEXT_CT} = "INI" ]
then
# LAUNCH APPLICATIVE JOB ESFD3671 ACQUISITION EXPENSES CALCULATION ASSUMED INI
NJOB="ESFD3671_${TYPEINV}"
${DCMD}/ESFD3671.cmd ${PARM_ICLODAT_D} ${TYPEINV}  2>&1 | ${TEE}
elif [ ${CONTEXT_CT} = "STD" ]
then
# LAUNCH APPLICATIVE JOB ESFD3632 RETRIEVE ACQUISITION EXPENSES PREVIOUS 
NJOB="ESFD3632_${TYPEINV}"
${DCMD}/ESFD3632.cmd ${PARM_ICLODAT_D} ${PER_CF} ${PARM_PREV_ICLODAT_D} 2>&1 | ${TEE}
fi 

CHAINEND
