#----------------------------------------------------------------------------
# FUNCTION: SORT_PERIMETER
#
# Input parameters:
# - SORT_INPUT_FILE: Input file to sort
# - SORT_OUTPUT_FILE: Target output file
# - PERIMETER_SCOPE : The scope (ASM or RETRO)
#
# Subject: Sort the input perimeter file depending on the scope
# ctr_nf, sec_nf, uwy_nf, uw_nt, end_nt for assumed
# ctr_nf, uwy_nf, rto_nf for retro
# 
# Return 0 if OK, >0 otherwise
#----------------------------------------------------------------------------

SORT_PERIMETER() {
	# Used to log the function name
	SORT_PERIMETER="SEG_PROCESS"
	
	SEG_LOG_DEBUG "Sort perimeter file ${SORT_INPUT_FILE} to ${SORT_OUTPUT_FILE}"

	# Check the input parameters
	if [[ "${PERIMETER_SCOPE}" != "ASM" && "${PERIMETER_SCOPE}" != "RETRO" ]]; then
		SEG_LOG_INFO "Unknown perimeter scope $PERIMETER_SCOPE - should be ASM or RETRO"
		exit 12
	fi
	
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${SORT_INPUT_FILE} 2048 1"
	SORT_O="${SORT_OUTPUT_FILE} OVERWRITE"
	SORT_FS=$'\x1c'
	
	if [[ "${PERIMETER_SCOPE}" == "ASM" ]]; then
	INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
		CTR_NF  1:1 -  1:,
		UWY_NF  2:1 -  2:EN,
		UW_NT	3:1 -  3:EN,
		END_NT	4:1 -  4:EN,
		SEC_NF	5:1 -  5:EN
/KEYS
		CTR_NF,
		SEC_NF,
		UWY_NF,
		UW_NT,
		END_NT
exit
EOF
	else
	INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
		CTR_NF  1:1 -  1:,
		UWY_NF  2:1 -  2:EN,
		SEC_NF	3:1 -  3:EN,
		RTO_NF	4:1 -  4:EN
/KEYS
		CTR_NF,
		UWY_NF,
		SEC_NF,
		RTO_NF
exit
EOF
	fi
		SORT
	
	SEG_LOG_DEBUG "Sort input file  ${SORT_INPUT_FILE} to ${SORT_OUTPUT_FILE} finished"
	
	return 0
}

#----------------------------------------------------------------------------
# FUNCTION: SP_SEGPERIMEXTRACT
#
# Input parameters:
# - PERIMETER_SCOPE: The scope (ASM or RETRO)
# - PERIMETER_TABLE: The table to extract (TSEGUWASMSEC or TSEGUWRETPLC)
#
# Subject: Function that create the stored procedure PsSEGPERIMEXTRACT used to extract 
# the current perimeter from TSEGUWASMSEC or TSEGUWRETPLC table
# This stored procedure takes the scope to extract in parameter
# The function will generate a SQL output file to execute using ISQL
# 
# Return 0 if OK, >0 otherwise
#----------------------------------------------------------------------------

SP_SEGNEWPERIMEXTRACT() {
	# Used to log the function name
	SEG_LOG_FUNCTION="SEG_PROCESS"
	
	SEG_LOG_DEBUG "Create perimeter extract stored procedure for ${PERIMETER_SCOPE} and ${HOST_PRDSIT}"

	# Check the input parameters
	if [[ "${PERIMETER_SCOPE}" != "ASM" && "${PERIMETER_SCOPE}" != "RETRO" ]]; then
		SEG_LOG_INFO "Unknown perimeter scope $PERIMETER_SCOPE - should be ASM or RETRO"
		exit 12
	fi
	
	SP_O=${DFILT}/${NSTEP}_${IB}_SP_PsSEGEXTRACT_${PERIMETER_SCOPE}.prc
	EXECKSH "touch ${SP_O}"
	
	SP_NAME="PsSEGEXTRACT_${PERIMETER_SCOPE}_${HOST_PRDSIT}"
	
	echo "USE BTRAVI" >> $SP_O
	echo "go" >> $SP_O
	echo "IF OBJECT_ID('${SP_NAME}') IS NOT NULL" >> $SP_O
	echo "BEGIN" >> $SP_O
	echo "	DROP PROCEDURE ${SP_NAME}" >> $SP_O
	echo "	IF OBJECT_ID('${SP_NAME}') IS NOT NULL" >> $SP_O
	echo "		PRINT '<<< FAILED DROPPING PROCEDURE ${SP_NAME} >>>'" >> $SP_O
	echo "	ELSE" >> $SP_O
	echo "		PRINT '<<< DROPPED PROCEDURE ${SP_NAME} >>>'" >> $SP_O
	echo "	END" >> $SP_O
	echo "go" >> $SP_O
	
	echo "" >> $SP_O
	
	echo "Create procedure ${SP_NAME} as" >> $SP_O
	echo "	set nocount on" >> $SP_O
	echo "" >> $SP_O
	echo "declare @prdsitCf varchar(4)" >> $SP_O
	echo "select @prdsitCf='${HOST_PRDSIT}'" >> $SP_O
	echo "" >> $SP_O
	
	NSTEP=${NJOB}_SP_EXTRACT_PERIM_${PERIMETER_SCOPE}_REQUEST
	LIBEL="Retrieve extracting SQL request for table ${PERIMETER_TABLE}"
	ISQL_BASE="BEST"
	ISQL_QRY="select SGTRQST_T from TSEGUWTABLE where SGTUWTAB_CF='${PERIMETER_TABLE}'"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_01_02_${HOST_PRDSIT}_${PERIMETER_SCOPE}_SQL_RQST.dat
	ISQL
	
	# Extract the SQL request from the output file
	awk 'BEGIN {FS = OFS = "[ ]*"} NR==FNR{if( $2 != "SGTRQST_T" && $2 !~ "[-]" && $2 != "row"){ print $0} }' \
		${DFILT}/${NSTEP}_${IB}_01_02_${HOST_PRDSIT}_${PERIMETER_SCOPE}_SQL_RQST.dat >> $SP_O
	
	echo "" >> $SP_O
	echo "	return 0" >> $SP_O
	echo "go" >> $SP_O
	
	echo "" >> $SP_O
	
	echo "EXEC sp_procxmode '${SP_NAME}', 'unchained'" >> $SP_O
	echo "go" >> $SP_O
	echo "IF OBJECT_ID('${SP_NAME}') IS NOT NULL" >> $SP_O
	echo "	PRINT '<<< CREATED PROCEDURE ${SP_NAME} >>>'" >> $SP_O
	echo "ELSE" >> $SP_O
	echo "	PRINT '<<< FAILED CREATING PROCEDURE ${SP_NAME} >>>'" >> $SP_O
	echo "go" >> $SP_O
	echo "GRANT EXECUTE ON ${SP_NAME} TO GOMEGA" >> $SP_O
	echo "GRANT ALL ON ${SP_NAME} TO GDBBATCH" >> $SP_O
	echo "go" >> $SP_O
	
	#
	# Execute the stored procedure
	#
	NSTEP=${NJOB}_SP_EXTRACT_PERIM_${PERIMETER_SCOPE}_EXECUTE
	LIBEL="Create stored procedure ${SP_NAME}"
	ISQL_BASE="BTRAVI"
	ISQL_QRY=$SP_O
	ISQL_O=${DFILT}/${NSTEP}_${IB}_01_02_${HOST_PRDSIT}_${PERIMETER_SCOPE}_SP_CREATION.log
	ISQL
	
	SEG_LOG_DEBUG "Extract perimeter stored procedure for $PERIMETER_SCOPE finished"
	
	# Delete files
	# rm -f ${DFILT}/${NSTEP}_${IB}_01_02_${HOST_PRDSIT}_${PERIMETER_SCOPE}_SQL_RQST.dat
	
	return 0
}

#----------------------------------------------------------------------------
# FUNCTION: SEG_LOG_INIT
# Input parameters: 
# Subject: Initialize the logger (create log file)
#----------------------------------------------------------------------------
SEG_LOG_INIT(){
	> ${DFILT}/${NJOB}_${HOST_PRDSIT}.log
}

#----------------------------------------------------------------------------
# FUNCTION: SEG_LOG
# Input parameters:
#	- Level of the message (DEBUG or INFO)
#	- Message to log
# Subject: Log messages related to the segmentation process
#----------------------------------------------------------------------------
SEG_LOG() {
	# Check the number of parameters
	if [ $# -lt 2 ]; then
		return 0
	fi

	if [ "${SEG_LOG_LVL}" = "DEBUG" -a \( "$1" = "DEBUG" -o  "$1" = "INFO" \) -o \( "${SEG_LOG_LVL}" = "INFO" -a "$1" = "INFO" \) ]; then
		MSG=("$1");
	
		if [ -n "${SEG_LOG_FUNCTION}" ]; then
			MSG+=("${SEG_LOG_FUNCTION}");
		fi
		
		if [ -n "${PERIMETER_SCOPE}" ]; then
			MSG+=("${PERIMETER_SCOPE}");
		fi
		
		MSG+=("$2");
		MSG=$(printf " - %s" "${MSG[@]}"); 
		MSG=${MSG:3}
		
		echo "$(date +'%Y/%m/%d %H:%M:%S') - ${MSG}" >> ${DFILT}/${NJOB}_${HOST_PRDSIT}.log
	fi
}

#----------------------------------------------------------------------------
# FUNCTION: SEG_LOG_DEBUG
# Input parameters:
#	- Message to log
# Subject: Log messages related to the segmentation process in DEBUG mode
#----------------------------------------------------------------------------
SEG_LOG_DEBUG(){
	SEG_LOG "DEBUG" "$1"
}

#----------------------------------------------------------------------------
# FUNCTION: SEG_LOG_INFO
# Input parameters:
#	- Message to log
# Subject: Log messages related to the segmentation process in INFO mode
#----------------------------------------------------------------------------
SEG_LOG_INFO(){
	SEG_LOG "INFO" "$1"
}