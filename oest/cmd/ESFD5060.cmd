#!/bin/ksh
#=============================================================================
# nom de l'application          : Get data - COMMUNS
# nom du script SHELL           : ESFD5060.cmd
# revision                      : 
# date de creation              : 31/03/2025
# auteur                        : 
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#  Copy permanent files from IFRS4
# parameters: 
#		ESFD5060.env
#
#-----------------------------------------------------------------------------
# historiques des modifications
# Modifié le            Par                 Desc.
#
#---------------
#MODIFICATION   : [
#Auteur         : MZM
#Date           : 31/03/2025
#Version        : 1.0
#Description    : Extraction quatidienne des  fichiers BBNI
#
#[001] 23/07/2025 MZM: US 6245 CUT OFF BBNI MANAGEMENT
#===============================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd


# Chain Initialization variables
CHAININIT $0 $1

IDF_CT="$2"



NJOB="ESFD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESFD9001.cmd "$IDF_CT"

# Extracting the number of days to substract on the pos booking date
set `GETPRM ${DPRM}/ESFD5060.prm`
export X_DAYS=$1

ECHO_LOG "#===> GREP ON...............................................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> GREP IN...............................................................: ${DPRM}/ESFD5060.prm"
export QUARTER_END_FOUND=`grep ${PARM_ICLODAT_D} ${DPRM}/ESFD5060.prm | cut -d' ' -f 2` 
ECHO_LOG "#===> QUARTER_END_FOUND.....................................................: ${QUARTER_END_FOUND}"
ECHO_LOG "#===> PARAM_CUR_PSTOMGEND17_D....................................................: ${PARAM_CUR_PSTOMGEND17_D}"
ECHO_LOG "#===> X_DAYS................................................................: ${X_DAYS}"


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

## greater than or equal REplace ge with gt 

if [ $PARM_CRE_D -gt $LIMIT_DATE ] ;
then 
	ECHO_LOG "#===> NO EXECUTION OF ESFD5061 PARM_CRE_D exceeds LIMIT_DATE.....................................................: $PARM_CRE_D >	 $LIMIT_DATE"
else 

	ECHO_LOG "#===> EXECUTION OF ESFD5061 PARM_CRE_D less or equal LIMIT_DATE..................................................: $PARM_CRE_D <=	 $LIMIT_DATE"

# Launch applicative job ESFD5061
NJOB="ESFD5061"
${DCMD}/ESFD5061.cmd "${PARM_CRE_D}"  "$PARM_BALSHEYEA_NF" "$PARM_BALSHTMTH_NF" "$PARM_ICLODAT_D" "$PARM_CLODAT_D" 2>&1 | ${TEE}

fi

## EBS INI AND EBS BBNI

NJOB="ESFD5062"
${DCMD}/ESFD5062.cmd  2>&1 | ${TEE}


CHAINEND

