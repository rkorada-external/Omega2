#!/bin/ksh
#=================================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD5030.cmd
# revision                      : $Revision:   1.0 $
# date de creation              : 28\09\2022
# auteur                        : Florian CULIOLI
#---------------------------------------------------------------------------------
# description
# Onerous Q+1
#  Generation of a row a pericase INI INV/POS 
#
#---------------------------------------------------------------------------------
# modif
# [01] 25/11/2022 FCI 	SPIRA 105587 : Onerous Q+1 - Add flagged onerous contracts in perimeter
# [02] 20/11/2023 FCI 	SPIRA 110735 : Fac accepted- new logic
# [03] 18/01/2024 FCI 	SPIRA 111124 : Stop onerous Q+1 extract at cut off date
# [04] 09/02/2024 FCI 	SPIRA 101193 : EBS / I17 - Fac Accepted
# [05] 22/01/2025 JYP 	SPIRA 112643 : In transition mode, don't stop ESFD5000, ESFD5010,ESFD5030 after cut off date
# [06] 30/06/2025 MZM 	SPIRA 113120 : Cut off date management
# [07] 23/07/2025 MZM   US 6250 : Cut off date management
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

if [ ${TYPEINV} = "POS" -o ${TYPEINV} = "POC" -o ${TYPEINV} = "POCB" ]
then

# Extracting the number of days to substract on the pos booking date
set `GETPRM ${DPRM}/ESFD5000.prm`
export X_DAYS=$1
export QUARTER_END_FOUND=`grep ${PARM_ICLODAT_D} ${DPRM}/ESFD5000.prm | cut -d' ' -f 2` 

ECHO_LOG "#===> CURRENT_DATE..........................................................: ${PARM_CRE_D}"
ECHO_LOG "#===> GREP ON...............................................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> GREP IN...............................................................: ${DPRM}/ESFD5000.prm"
ECHO_LOG "#===> PARM_PSTOMGEND17_D....................................................: ${PARM_PSTOMGEND17_D}"
ECHO_LOG "#===> X_DAYS................................................................: ${X_DAYS}"
ECHO_LOG "#===> PARM_CRE_D............................................................: ${PARM_CRE_D}"
ECHO_LOG "#===> OVERWRITE QUARTER_END_FOUND IN PARAM FILE ............................: ${QUARTER_END_FOUND}"
ECHO_LOG "#===> NORME_CF..............................................................: ${NORME_CF}"
ECHO_LOG "#===> PARM_IS_TRN ..........................................................: ${PARM_IS_TRN} "

pattern="(\d{2})\/(\d{2})\/(\d{4})"
if [ -z "$QUARTER_END_FOUND" -o "$QUARTER_END_FOUND" -eq "NONE" ];
then
	if [[ $QUARTER_END_FOUND =~ $pattern ]]; then
	export LIMIT_DATE=$(date --date="${.sh.match[3]}${.sh.match[2]}${.sh.match[1]}" +%Y%m%d)
	ECHO_LOG "#===>  LIMIT IS PRM QUARTER_END_FOUND .................................: $LIMIT_DATE"
	else
	export v_pos_booking_minus_days=$(date --date="${PARM_PSTOMGEND17_D} -${X_DAYS} day" +%Y%m%d)
	ECHO_LOG "#===> OVERWRITE OF LIMIT WITH (PARM_PSTOMGEND17_D - X_DAYS)  .................................: $v_pos_booking_minus_days"
	export LIMIT_DATE=$(date --date="${v_pos_booking_minus_days}" +%Y%m%d)
	fi
fi

if [ -z "$PARM_IS_TRN" ]
then
 export PARM_IS_TRN=NO
fi

ECHO_LOG "#===> LIMIT_DATE.....................................................: ${LIMIT_DATE}"

## greater than or equal ==>Replace with greather than gt 
if [ $PARM_CRE_D -gt $LIMIT_DATE ] && [ "$PARM_IS_TRN" != "YES" ] ;
then 
	ECHO_LOG "#===> NO EXECUTION OF ESFD5031 & ESFD5032 because PARM_CRE_D exceeds LIMIT_DATE.....................................................: $PARM_CRE_D > $LIMIT_DATE"
else 
 ECHO_LOG "#===> Because PARM_CRE_D in range of LIMIT_DATE.....................................................: $PARM_CRE_D <= $LIMIT_DATE"

 if [ ${NORME_CF} = "EBS" ] 
 then
	ECHO_LOG "#===> EXECUTION OF ESFD5033 & ESFD5034"
	#Launch applicative job ESFD5033
	NJOB="ESFD5033${TYPEINV}"
	${DCMD}/ESFD5033.cmd | ${TEE}

	#Launch applicative job ESFD5033
	NJOB="ESFD5034${TYPEINV}"
	${DCMD}/ESFD5034.cmd | ${TEE}
 else
	ECHO_LOG "#===> EXECUTION OF ESFD5031 & ESFD5032"

	# Launch applicative job ESFD5031
	NJOB="ESFD5031${TYPEINV}"
	${DCMD}/ESFD5031.cmd | ${TEE}


	# Launch applicative job ESFD5032
	NJOB="ESFD5032${TYPEINV}"
	${DCMD}/ESFD5032.cmd | ${TEE}
 fi
fi

if [ ${TYPEINV} != "POS" -a ${TYPEINV} != "POC" -a ${TYPEINV} != "POCB" ] 
then

ECHO_LOG ""
ECHO_LOG "#============================================================================"
ECHO_LOG "# Batch run only when TYPEINV = POS or POC(B)"
ECHO_LOG "# TYPEINV = ${TYPEINV} "
ECHO_LOG "#============================================================================"
ECHO_LOG ""

fi

fi

CHAINEND
