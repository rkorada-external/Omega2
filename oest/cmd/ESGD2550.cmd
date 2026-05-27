#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESGD2550.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 03/10/1997
# auteur                        : M.NAJI
# references des specifications : ESGD2550.doc
#-----------------------------------------------------------------------------
# description
#   
#-----------------------------------------------------------------------------
# historiques des modifications
# 16/09/2025 M.NAJI US6929 SERQS I17  update IDF_CT ==> I17G_SERQS_MERGE	
#===============================================================================
#set -x



# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT="$2"

# Launch job to set context
NJOB="ESFD9001"
. ${DCMD}/ESFD9001.cmd ${IDF_CT}


# Get entry parameters
set `GETPRM ${DPRM}/ESGD255V${DEV_TEST}.prm`
VSERQS_I4I=${1}
VSERQS_EBS=${2}
VSERQS_I17G=${3}
VSERQS_I17P=${4}
VSERQS_I17L=${5}

if [ "$VNORME" = "I4I" ]; then
	if [ "${VSERQS_I4I}" != "YES" ]; then
		ECHO_LOG "=============================================================================="
		ECHO_LOG "............................		 NO SERQS MODE on IFRS4"
		ECHO_LOG "=============================================================================="
		CHAINEND
	fi
fi

if [ "$VNORME" = "EBS" ]; then
	if [ "${VSERQS_EBS}" != "YES" ]; then
		ECHO_LOG "=============================================================================="
		ECHO_LOG "............................		 NO SERQS MODE on EBS"
		ECHO_LOG "=============================================================================="
		CHAINEND
	fi
fi

if [ "$VNORME" = "I17G" ]; then
	if [ "${VSERQS_I17G}" != "YES" ]; then
		ECHO_LOG "=============================================================================="
		ECHO_LOG "............................		 NO SERQS MODE on I17G"
		ECHO_LOG "=============================================================================="
		CHAINEND
	fi
fi

if [ "$VNORME" = "I17P" ]; then
	if [ "${VSERQS_I17P}" != "YES" ]; then
		ECHO_LOG "=============================================================================="
		ECHO_LOG "............................		 NO SERQS MODE on I17P"
		ECHO_LOG "=============================================================================="
		CHAINEND
	fi
fi


if [ "$VNORME" = "I17L" ]; then
	if [ "${VSERQS_I17L}" != "YES" ]; then
		ECHO_LOG "=============================================================================="
		ECHO_LOG "............................		 NO SERQS MODE on I17L"
		ECHO_LOG "=============================================================================="
		CHAINEND
	fi
fi


if [ "$IDF_CT" = "I4I_EBS_ESGD2550_SERQS_MERGE" ]; then
	# Launch job ESGD2551
	NJOB="ESGD2551"
	${DCMD}/ESGD2551.cmd  2>&1 | ${TEE}

	CHAINEND
fi


# Extracting the number of days to substract on the pos booking date
set `GETPRM ${DPRM}/ESFD5000.prm`
export X_DAYS=$1
export QUARTER_END_FOUND=`grep ${PARM_ICLODAT_D} ${DPRM}/ESFD5000.prm | cut -d' ' -f 2`

ECHO_LOG "#===> X_DAYS................................................................: ${X_DAYS}"
ECHO_LOG "#===> OVERWRITE QUARTER_END_FOUND IN PARAM FILE ............................: ${QUARTER_END_FOUND}"

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

	if [ "$IDF_CT" = "EBS_ESGD2550_SERQS_MERGE" ]; then
		# Launch job ESGD2551_EBS
		NJOB="ESGD2551_EBS"
		${DCMD}/ESGD2551_EBS.cmd  2>&1 | ${TEE}
	fi

	if [ "$IDF_CT" = "I17G_SERQS_MERGE" ]; then
		# Launch job ESGD2551_I17G
		NJOB="ESGD2551_$VNORME"
		${DCMD}/ESGD2551_I17.cmd  2>&1 | ${TEE}
	fi
fi


while IFS= read -r row
do 

	row=`echo $row | sed  s'/\t/  /'g | tr -s ' '  `
	tableau=($row)
	export LEFT_FILE=${tableau[0]}
	export RIGHT_FILE=${tableau[1]}

	
	if ! [ -v ${tableau[1]} ]; then

		#ECHO_LOG "#==============================================================="
		#ECHO_LOG "#======>  ${tableau[1]}  not used"
		#ECHO_LOG "#======>  $RIGHT_FILE: `eval echo '$'${RIGHT_FILE}`"
		#ECHO_LOG "#==============================================================="

		continue
	fi


	chaine=${tableau[2]}
	export LEFT_FIELDS=""
	export LEFT_KEYS=""
	IFS=',' read -r -A  array <<< $chaine
    sep=""
    for i in "${!array[@]}"; do
        LEFT_FIELDS+="$sep col_left$((i+1))  ${array[i]}:1 -${array[i]}:"
        LEFT_KEYS+="$sep col_left$((i+1))"
        sep=" ,"
    done
#
	chaine=${tableau[3]}
	export RIGHT_FIELDS=""
	export RIGHT_KEYS=""
	IFS=',' read -r -A  array <<< $chaine
    sep=""
    for i in "${!array[@]}"; do
        RIGHT_FIELDS+="$sep col_right$((i+1))  ${array[i]}:1 -${array[i]}:"
        RIGHT_KEYS+="$sep col_right$((i+1))"
        sep=" ,"
    done
#
#
	chaine=${tableau[4]}  
	export FIELDS_SORT=""
	export KEYS_SORT=""
    if [ "$chaine" != "" ]; then
		sep=""
		IFS=',' read -r -A array <<< "$chaine"
		for i in "${!array[@]}";do
			FIELDS_SORT+="$sep col$((i+1))  ${array[i]}:1 -${array[i]}:"
			KEYS_SORT+="$sep col$((i+1))"
			sep=" ,"
    	done   
	fi

	  
    if [ "$FIELDS_SORT" != "" ]; then
        export FIELDS_SORT="/FIELDS $FIELDS_SORT"
        export KEYS_SORT="/KEYS $KEYS_SORT"
    fi    


	# Launch merge $LEFT_FILE $RIGHT_FILE
	NJOB="ESGD2552_MERGE_${RIGHT_FILE}"
	${DCMD}/ESGD2552.cmd  2>&1 | ${TEE}

done <  $DPRM/ESGD255M.prm


if [[ "$VNORME"  == I17* ]] ;  then
	# Launch applicative job ESFD5042
	NJOB="ESFD5042${TYPEINV}"
	${DCMD}/ESFD5042.cmd ${EST_FCES_5030} ${EST_FCES_5010} ${EST_FCES} | ${TEE}

fi

CHAINEND
