#!/bin/ksh
#=============================================================================
# nom de l'application          : EBS
# nom du script SHELL           : ESFD5010.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 10\02\2021
# auteur                        : Cyril AVINENS
# references des specifications :
#-----------------------------------------------------------------------------
# Description
# If TYPEINV = INV => simply rename the IFRS4/EBS files.
#	If TYPEINV = POS => merge of IFRS4/EBS INV file with POS period from an IFRS4/EBS POS file
#-----------------------------------------------------------------------------
# [01] 13/02/2024 FCI 	SPIRA 111100 : Actuarial segment missing when future contract is finalized
# [02] 22/01/2025 JYP 	SPIRA 112643 : In transition mode, don't stop ESFD5000, ESFD5010,ESFD5030 after cut off date
# [03] 30/06/2025 MZM 	SPIRA 113120 : Cut off date management
# [04] 23/07/2025 MZM   US 6250 : Cut off date management
# [05] 10/10/2025 MZM   US 7046 : Cut off management - actuarial segment is empty on contracts taken into account the day of cut off
# [07] 26/02/2026 MZM   US 7046 : Cut off management - actuarial segment is empty on contracts taken into account the day of cut off / ADD ESFD5015 ONLY FOR FCTRGRO
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

## Ajout 1 JOUR A la DAte limite :
export LIMIT_DATE2=$LIMIT_DATE
export NB_JOUR_SG_ACTU=1
echo "LIMIT_DATE2 = $LIMIT_DATE2"
echo "NB_JOUR_SG_ACTU= $NB_JOUR_SG_ACTU"
export LIMIT_DATE=$(date --date="${LIMIT_DATE2} +${NB_JOUR_SG_ACTU} day" +%Y%m%d)

export LIMIT_DATE3=$(date --date="${LIMIT_DATE} +${NB_JOUR_SG_ACTU} day" +%Y%m%d)

ECHO_LOG "#===>  LIMIT IS PRM QUARTER_END_FOUND + 1 DAY .............................................: $LIMIT_DATE"


ECHO_LOG "#===>  LIMIT IS PRM QUARTER_END_FOUND FOR FCTRGRO + 2 DAY .................................: $LIMIT_DATE3"

if [ $PARM_CRE_D -ge $LIMIT_DATE3 ] && [ "$PARM_IS_TRN" != "YES" ] ;
then
        ECHO_LOG "#===> NO EXECUTION OF ESFD5015 NO UPDATE FCTRGRO because PARM_CRE_D exceeds LIMIT_DATE.....................................................: $PARM_CRE_D >= $LIMIT_DATE3"
else

                # Launch applicative job ESFD5015
                NJOB="ESFD5015${TYPEINV}"
                ${DCMD}/ESFD5015.cmd | ${TEE}


fi

## greater than ===> replace eq with gt
## greater than gt replace with ge to take into ACCOUNT ACtuarial Segment 
 
if [ $PARM_CRE_D -ge $LIMIT_DATE ] && [ "$PARM_IS_TRN" != "YES" ] ;
then 
	ECHO_LOG "#===> NO EXECUTION OF ESFD5011 or ESFD5012 or ESFD5013 or ESFD5014 because PARM_CRE_D exceeds LIMIT_DATE.....................................................: $PARM_CRE_D >= $LIMIT_DATE"
else

	if [ ${NORME_CF} = "EBS" -a ${TYPEINV} = "INV" ]
	then
		# Launch applicative job ESFD5011
		NJOB="ESFD5011${TYPEINV}"
		${DCMD}/ESFD5011.cmd | ${TEE}
	fi

	if [ ${NORME_CF} = "EBS" -a ${TYPEINV} = "POS" -a ${PARM_SEQ_MODE} = "1" ]
	then
		# Launch applicative job ESFD5011
		NJOB="ESFD5011${TYPEINV}"
		${DCMD}/ESFD5011.cmd | ${TEE}
	fi

	if [ ${NORME_CF} = "EBS" -a ${TYPEINV} = "POS" -a ${PARM_SEQ_MODE} = "0" ]
	then
		# Launch applicative job ESFD5012
		NJOB="ESFD5012${TYPEINV}"
		${DCMD}/ESFD5012.cmd | ${TEE}
	fi

	if [ ${NORME_CF:0:3} = "I17" -a ${TYPEINV} = "INV" ]
	then
		# Launch applicative job ESFD5013
		NJOB="ESFD5013${TYPEINV}"
		${DCMD}/ESFD5013.cmd | ${TEE}
	fi

	if [ ${NORME_CF:0:3} = "I17" -a ${TYPEINV} = "POS" ]
	then
		# Launch applicative job ESFD5014
		NJOB="ESFD5014${TYPEINV}"
		${DCMD}/ESFD5014.cmd | ${TEE}
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
