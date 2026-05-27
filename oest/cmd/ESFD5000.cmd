#!/bin/ksh
#=================================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD5000.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 10\02\2021
# auteur                        : Arnaud RUFFAULT
#---------------------------------------------------------------------------------
# description
#  Generation of a row a pericase INI INV/POS 
#
#---------------------------------------------------------------------------------
# [01] 13/02/2024 FCI 	SPIRA 111100 : Actuarial segment missing when future contract is finalized
# [02] 22/01/2025 JYP 	SPIRA 112643 : In transition mode, don't stop ESFD5000, ESFD5010,ESFD5030 after cut off date
# [03] 30/06/2025 MZM 	SPIRA 113120 : Cut off date management
# [04] 23/07/2025 MZM   US 6250 : Cut off date management 
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

if [  ${TYPEINV} = "INV" -o ${TYPEINV} = "POS"	]
then

	# Extracting the number of days to substract on the pos booking date
	set `GETPRM ${DPRM}/ESFD5000.prm`
	export X_DAYS=$1

	ECHO_LOG "#===> GREP ON...............................................................: ${PARM_ICLODAT_D}"
	ECHO_LOG "#===> GREP IN...............................................................: ${DPRM}/ESFD5000.prm"
	export QUARTER_END_FOUND=`grep ${PARM_ICLODAT_D} ${DPRM}/ESFD5000.prm | cut -d' ' -f 2` 
	ECHO_LOG "#===> QUARTER_END_FOUND.....................................................: ${QUARTER_END_FOUND}"
	ECHO_LOG "#===> PARAM_CUR_PSTOMGEND17_D....................................................: ${PARAM_CUR_PSTOMGEND17_D}"
	ECHO_LOG "#===> X_DAYS................................................................: ${X_DAYS}"
	ECHO_LOG "#===> PARM_IS_TRN ..........................................................: ${PARM_IS_TRN} "

	pattern="(\d{2})\/(\d{2})\/(\d{4})"
	if [ -z "$QUARTER_END_FOUND" -o "$QUARTER_END_FOUND" -eq "NONE" ];
	then
		if [[ $QUARTER_END_FOUND =~ $pattern ]]; then
		export LIMIT_DATE=$(date --date="${.sh.match[3]}${.sh.match[2]}${.sh.match[1]}" +%Y%m%d)
		ECHO_LOG "#===>  LIMIT IS PRM QUARTER_END_FOUND .................................: $LIMIT_DATE"
		else
		export v_pos_booking_minus_days=$(date --date="${PARAM_CUR_PSTOMGEND17_D} -${X_DAYS} day" +%Y%m%d)
		ECHO_LOG "#===> OVERWRITE OF LIMIT WITH (PARAM_CUR_PSTOMGEND17_D - X_DAYS)  .................................: $v_pos_booking_minus_days"
		export LIMIT_DATE=$(date --date="${v_pos_booking_minus_days}" +%Y%m%d)
		fi
	fi

	if [ -z "$PARM_IS_TRN" ]
	then
	 export PARM_IS_TRN=NO
	fi

	## greater than or equal REplace ge with gt 
	if [ $PARM_CRE_D -gt $LIMIT_DATE ] && [ "$PARM_IS_TRN" != "YES" ];
	then 
		ECHO_LOG "#===> NO EXECUTION OF ESFD5001 & ESFD5002 because PARM_CRE_D exceeds LIMIT_DATE.....................................................: $PARM_CRE_D >	 $LIMIT_DATE"
	else 

		# Launch applicative job ESFD5001
		NJOB="ESFD5001${TYPEINV}"
		${DCMD}/ESFD5001.cmd | ${TEE}


		# Launch applicative job ESFD5002
		NJOB="ESFD5002${TYPEINV}"
		${DCMD}/ESFD5002.cmd | ${TEE}
	fi
fi

if [ ${TYPEINV} != "INV" -a ${TYPEINV} != "POS" ] 
then

ECHO_LOG ""
ECHO_LOG "#============================================================================"
ECHO_LOG "# Batch run only when TYPEINV = INV or POS "
ECHO_LOG "# TYPEINV = ${TYPEINV} "
ECHO_LOG "#============================================================================"
ECHO_LOG ""

fi

CHAINEND
