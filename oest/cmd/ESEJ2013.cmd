#----------------------------------------------------------------------------
# FUNCTION: SEG_PROCESS
#
# Input parameters:
#	- PERIMETER_SCOPE: Perimeter scope (ASS or RETRO)
#	- PERIMETER_SCOPE_CT : Perimeter scope reference value (1 for ASM, 2 for RETRO)
#	- PERIMETER_TABLE: The target perimeter table (TSEGUWRETPLC or TSEGUWASMSEC) for a given production site

# Subject: Function that process the segmentation.
# It will check if the perimeter has changed based on the definition in table BEST..TUWSECCOLUMN
# Then it updates the perimeter schema if needed, and the data for contracts of the current production site.
# And at the end it process the segmentation/aggregation
# It will generate 3 output files :
# - updated perimeter
# - results
# - errors
#
# Return 0 if OK, >0 otherwise
# MOD01	Parth	12/11/2020	SPIRA 91638	Pass Concurrency Factor to Batch web from parameter file
#----------------------------------------------------------------------------

SEG_PROCESS() {
	# Used to log the function name
	SEG_LOG_FUNCTION="SEG_PROCESS"
	
	# used to identify generated files of this function
	FILE_ID="2013_${HOST_PRDSIT}_${PERIMETER_SCOPE}"
	
	SEG_LOG_INFO "Start Segmentation Process"

	# Check the input parameters
	if [[ "${PERIMETER_SCOPE}" != "ASM" && "${PERIMETER_SCOPE}" != "RETRO" ]]; then
		SEG_LOG_INFO "Unknown perimeter scope $PERIMETER_SCOPE - should be ASM or RETRO"
		exit 12
	fi
	
	# The target perimeter table depends on the production site
	PERIMETER_TABLE_PRDSIT=${PERIMETER_TABLE}_${HOST_PRDSIT}
	
	#-----------------------------------
	# Stored procedure to check if the perimeter table schema changed
	# it takes the perimeter scope (assumed or retro) in parameter
	# it retrieves the criteria and result columns and compare them to the existing schema
	#-----------------------------------
	time_1=`date +%s`; 
	
	# Check if the perimeter table exists in DB. If not, then we consider that the perimeter is modified
	NSTEP=${NJOB}_CHECK_${PERIMETER_TABLE_PRDSIT}
	LIBEL="Check that the perimeter table exists in BTRAVI"
	BCP_WAY="OUT"; BCP_VER="+";
	BCP_O=${DFILT}/${NSTEP}_${IB}_${FILE_ID}_CHECK_${PERIMETER_TABLE_PRDSIT}.dat
	BCP_QRY="select OBJECT_ID('BTRAVI..${PERIMETER_TABLE_PRDSIT}')"
	BCP

	# Retrieve the value of the object id
	PERIMETER_TABLE_OBJECT_ID=($(cat ${DFILT}/${NSTEP}_${IB}_${FILE_ID}_CHECK_${PERIMETER_TABLE_PRDSIT}.dat))

	# If the object is empty, the table doesn't exist in DB
	# We also consider that the perimeter has changed
	EXISTING_PERIMETER_TABLE="true"
	SEG_PERIM_FILE="${DFILP}/${ENV_PREFIX}_SEG_${HOST_PRDSIT}_${PERIMETER_SCOPE}_PERIMETER.dat"
	DFILT_SEG_PERIM_FILE="${DFILT}/${NJOB}_${IB}_SEG_${HOST_PRDSIT}_${PERIMETER_SCOPE}_PERIMETER.dat"
	
	if [ -z "${PERIMETER_TABLE_OBJECT_ID}" ]; then
		EXISTING_PERIMETER_TABLE="false"
		PERIMETER_CHANGED="true"

		# If a seg perimeter file exists whereas the perimeter table exists, it has great chances to be outdated. Remove it.
		if [ -s "$SEG_PERIM_FILE" ] ; then
			NSTEP=${NJOB}_CLEAR_SEG_PERIM_FILE
			LIBEL="$SEG_PERIM_FILE is outdated, removing this perimeter file"
			RMFIL $SEG_PERIM_FILE
		fi
	
	# Otherwise, check that the existing perimeter file matches BTRAVI perimeter table
	elif [ -s "$SEG_PERIM_FILE" ] ; then

		NSTEP=${NJOB}_CHECK_MATCH_${PERIMETER_TABLE_PRDSIT}_WITH_DFILP
		LIBEL="Count perimeter columns in BTRAVI perimeter table to check integrity with \$DFILP perimeter file"
		BCP_WAY="OUT"; BCP_VER="+";
		BCP_O=${DFILT}/${NSTEP}_${IB}_${FILE_ID}_CHECK_MATCH_${PERIMETER_TABLE_PRDSIT}_COUNT.dat
		BCP_QRY="SELECT count(sc.name) FROM BTRAVI..syscolumns sc INNER JOIN BTRAVI..sysobjects so ON sc.id = so.id WHERE so.name = '${PERIMETER_TABLE_PRDSIT}'"
		BCP
		
		btraviColCount=$(cat $BCP_O)
		segPerimFileColCount=$(head -1 "$SEG_PERIM_FILE" | sed 's/'$'\x1c''/'$'\x1c''\n/g' | wc -l)
		# Count for the first line only, then add a line return for each separator and count lines
		
		if [ $btraviColCount -ne $segPerimFileColCount ] ; then
			NSTEP=${NJOB}_CLEAR_SEG_PERIM_FILE
			LIBEL="$SEG_PERIM_FILE doesn't match BTRAVI..${PERIMETER_TABLE_PRDSIT}. Removing this perimeter file"
			RMFIL $SEG_PERIM_FILE
		fi
	fi
	
	SEG_LOG_INFO "Perimeter existing: ${EXISTING_PERIMETER_TABLE}" 	
	
	#
	# The table exist in DB, we now check if the schema has been modified
	#
	if [ "${EXISTING_PERIMETER_TABLE}" = "true" ]; then
	
		# Extract column from TSEGUWCOLUMN. The perimeter schema has it should be
		SEG_LOG_DEBUG "Extract TSEGUWCOLUMN"
		NSTEP=${NJOB}_COLUMN_CHECK_TARGET_${PERIMETER_SCOPE}
		TSEGUWCOLUMN_O=${DFILT}/${NSTEP}_${IB}_${FILE_ID}_TSEGUWCOLUMN.dat
		
		LIBEL="Select column from TSEGUWCOLUMN"
		BCP_WAY="OUT"; BCP_VER="+"; BCP_FS=" "
		BCP_O=${TSEGUWCOLUMN_O}
		BCP_QRY="select c.SGTUWCOL_CF as columnname, c.SGTUWTYP_CT as type, c.SGTUWPRE_NB as precision, c.SGTUWSCA_NB as scale, c.SGTUWLEN_NB as length, st.usertype as usertype "
		BCP_QRY+="from BEST..TSEGUWCOLUMN c "
		BCP_QRY+="INNER JOIN BEST..systypes st ON c.SGTUWTYP_CT = st.name "
		BCP_QRY+="WHERE c.SGTUWTAB_CF = '${PERIMETER_TABLE}' "
		BCP_QRY+="UNION "
		BCP_QRY+="select 'SEG_' + ltrim(str(s.sgttyp_nt)) + '_LVL_' + ltrim(str(l.sgtlvl_ct)) as columnname, 'int' as type, null as precision, null as scale, null as length, 7 as usertype "
		BCP_QRY+="from BEST..TSEGMENTATION s "
		BCP_QRY+="inner join BEST..TSEGMENTLVL l on l.sgt_nt = s.sgt_nt and l.sgtver_nt = s.sgtver_nt "
		BCP_QRY+="inner join BEST..TSEGTYPE t on t.sgttyp_nt = s.sgttyp_nt "
		BCP_QRY+="where s.sgtsts_cf = '3' and t.SGTTYPSTS_CT = '1' and t.SGTSCOPE_CT in ('3', '${PERIMETER_SCOPE_CT}') "
		BCP_QRY+="UNION "
		BCP_QRY+="select 'SEG_LABEL_' + ltrim(str(s.sgttyp_nt)) + '_LVL_' + ltrim(str(l.sgtlvl_ct)) as columnname, 'varchar' as type, null as precision, null as scale, null as length, 7 as usertype "
		BCP_QRY+="from BEST..TSEGMENTATION s "
		BCP_QRY+="inner join BEST..TSEGMENTLVL l on l.sgt_nt = s.sgt_nt and l.sgtver_nt = s.sgtver_nt "
		BCP_QRY+="inner join BEST..TSEGTYPE t on t.sgttyp_nt = s.sgttyp_nt "
		BCP_QRY+="where s.sgtsts_cf = '3' and t.SGTTYPSTS_CT = '1' and t.SGTSCOPE_CT in ('3', '${PERIMETER_SCOPE_CT}') "
		BCP_QRY+="order by columnname ASC "
		BCP
			
		# Extract the existing perimeter schema
		SEG_LOG_DEBUG "Extract perimeter table $PERIMETER_TABLE_PRDSIT"
		NSTEP=${NJOB}_COLUMN_CHECK_CURRENT_${PERIMETER_SCOPE}
		PERIMETERCOLUMN_O=${DFILT}/${NSTEP}_${IB}_${FILE_ID}_PERIMETER_COLUMN.dat
		
		LIBEL="Select column from perimeter table"
		BCP_WAY="OUT"; BCP_VER="+"; BCP_FS=" "
		BCP_O=${PERIMETERCOLUMN_O}
		BCP_QRY="SELECT convert(char(16), sc.name) as columnname, convert(char(32), st.name) as type, st.prec as precision, st.scale as scale, sc.length as length,st.usertype as usertype "
		BCP_QRY+="FROM BTRAVI..syscolumns sc "
		BCP_QRY+="INNER JOIN BTRAVI..sysobjects so ON sc.id = so.id INNER JOIN BTRAVI..systypes st ON sc.usertype = st.usertype "
		BCP_QRY+="WHERE so.name = '${PERIMETER_TABLE_PRDSIT}' ORDER BY sc.name ASC"
		BCP
		
		# Compare the 2 result files
		# The file is composed of column name - type - precision - scale - length - usertype
		# It parses first the perimeter result file. 
		# It puts in an array the key column name - usertype (and optionnaly if char or varchar - length)
		# Then it parses the seconde file. Build again the key and check if it exists in the previous array
		# Then result is stored in an output file
		NSTEP=${NJOB}_COLUMN_CHECK_${PERIMETER_SCOPE}
		COLUMN_CHECK_O=${DFILT}/${NSTEP}_${IB}_${FILE_ID}_PERIMETER_COMPARE_RESULT.dat
		
		SEG_LOG_DEBUG "Columns comparison" 	
		
		awk 'BEGIN {FS = OFS = "[ ]*"} NR==FNR{if( $7 == 1 || $7 == 2 ){++a[$2"-"$7"-"$6]}else{++a[$2"-"$7]}next} \
			{if((($7 == 1 || $7 == 2) && !a[$2"-"$7"-"$6]) || ($7 != 1 && $7 != 2 && !a[$2"-"$7])){print $0}}' \
			${PERIMETERCOLUMN_O} ${TSEGUWCOLUMN_O} >> ${COLUMN_CHECK_O}
		
		
		# Same process but we start by parsing the second file and compare it with the perimeter file
		# Exclude some columns of the check (technical columns)
		awk 'BEGIN {FS = OFS = "[ ]*"} NR==FNR{if( $7 == 1 || $7 == 2 ){++a[$2"-"$7"-"$6]}else{++a[$2"-"$7]}next} \
			{if($2 != "ROWID_NT" && $2 != "CRE_D" && $2 != "LSTUPD_D" && \
				$2 != "timestamp" && ((($7 == 1 || $7 == 2) && !a[$2"-"$7"-"$6]) || ($7 != 1 && $7 != 2 && !a[$2"-"$7]))){print $0}}' \
			${TSEGUWCOLUMN_O} ${PERIMETERCOLUMN_O} >> ${COLUMN_CHECK_O}
		
		COLUMN_CHECK_FILE_SIZE="`stat -c %s ${COLUMN_CHECK_O}`"
		SEG_LOG_DEBUG "SEG_PROCESS - ${PERIMETER_SCOPE} - output file size $COLUMN_CHECK_FILE_SIZE" 	
		
		PERIMETER_CHANGED="false"
		if [ "${COLUMN_CHECK_FILE_SIZE}" != "0" ]; then
			PERIMETER_CHANGED="true"
		fi
		
		time_2=`date +%s`;
		SEG_LOG_INFO "Perimeter modified: ${PERIMETER_CHANGED} in $(expr $time_2 - $time_1) sec" 	
		
		# Delete files
		rm -f ${TSEGUWCOLUMN_O}
		rm -f ${PERIMETERCOLUMN_O}
	else
		SEG_LOG_DEBUG "Dummy perimeter table creation for Java batch usage"
		
		# stored procedure with perimeter scope in parameter
		LIBEL="Create dummy perimeter table"
		NSTEP=${NJOB}_DUMMY_PERIM_CREATION_${PERIMETER_SCOPE}
		ISQL_BASE="BTRAVI"
		ISQL_QRY="execute BTRAVI..PtSEGPERIMCREATE_01 '${PERIMETER_TABLE}', '${PERIMETER_SCOPE_CT}', '${HOST_PRDSIT}'"
		ISQL_O=${DFILT}/${NSTEP}_${IB}_${FILE_ID}_PERIMETER_TABLE_CREATION.log
		ISQL
	
		NSTEP=${NJOB}_DUMMY_PERIM_RENAME_${PERIMETER_SCOPE}
		LIBEL="Rename dummy perimeter table"
		ISQL_BASE="BTRAVI"
		ISQL_QRY="sp_rename ${PERIMETER_TABLE_PRDSIT}_TMP, ${PERIMETER_TABLE_PRDSIT}"
		ISQL_O=${DFILT}/${NSTEP}_${IB}_${FILE_ID}_RENAME_PERIMETER_TABLE.log
		ISQL
	fi
	
	#-----------------------------------
	# Create the new perimeter table with a temporary name 
	# The table will be renamed after inserting results
	# to update the other production site data by adding/removing columns
	#-----------------------------------
	
	time_3=`date +%s`;
	SEG_LOG_DEBUG "Temporary perimeter table creation" 	
	
	# stored procedure with perimeter scope in parameter
	LIBEL="Create temporary perimeter table"
	NSTEP=${NJOB}_PERIM_CREATION_${PERIMETER_SCOPE}
	ISQL_BASE="BTRAVI"
	ISQL_QRY="execute BTRAVI..PtSEGPERIMCREATE_01 '${PERIMETER_TABLE}', '${PERIMETER_SCOPE_CT}', '${HOST_PRDSIT}'"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_${FILE_ID}_PERIMETER_TABLE_CREATION.log
	ISQL
	
	time_4=`date +%s`;
	SEG_LOG_INFO "End of perimeter updates in $(expr $time_4 - $time_3) sec"
	
	#-----------------------------------
	# If the perimeter file for the current production site of the previous run
	# doesn't exist, then extract it from the perimeter table
	# -----------------------------------
	NSTEP=${NJOB}_EXTRACT_PERIMETER_${PERIMETER_SCOPE}
	if [ ! -f ${SEG_PERIM_FILE} ]; then
	
		# If the perimeter table doesn't exist, create an empty file
		if [ "${EXISTING_PERIMETER_TABLE}" = "false" ]; then
			EXECKSH "touch ${SEG_PERIM_FILE}"
			
		# Else extract data from the perimeter table
		else 
			time_5=`date +%s`;
			SEG_LOG_DEBUG "Extract Perimeter for production site ${HOST_PRDSIT}"  	
			
			# This SQL request has to be a select * because the schema of this table may changed at any time
			LIBEL='Extract Perimeter'
			BCP_WAY="OUT"; BCP_VER="+"; BCP_FS=$'\x1c'
			BCP_O=${DFILT}/${NSTEP}_${IB}_${FILE_ID}_PERIMETER_UNSORT.dat
			BCP_QRY="select * from BTRAVI..${PERIMETER_TABLE_PRDSIT}"
			BCP
			
			# Sort it
			SORT_INPUT_FILE=${DFILT}/${NSTEP}_${IB}_${FILE_ID}_PERIMETER_UNSORT.dat
			SORT_OUTPUT_FILE=${SEG_PERIM_FILE}
			SORT_PERIMETER		
		
			# Delete the unsort file
			rm -f ${SORT_INPUT_FILE}
			
			time_6=`date +%s`;
			SEG_LOG_INFO "End of current perimeter extract in $(expr $time_6 - $time_5) sec"
		fi
	fi
	
	
	#-----------------------------------
	# Extract of the new perimeter
	# BCP out based on the query stored in TSEGUWTABLE => stored procedure which takes the perimeter scope in parameter
	#-----------------------------------
	
	# Create the stored procedure used to extract the perimeter
	# Parameters are the same as the current function PERIMETER_SCOPE and PERIMETER_TABLE
	# It generates the SP PsSEGNEWPERIMEXTRACT_${PERIMETER_SCOPE}
	time_7=`date +%s`;
	
	SP_SEGNEWPERIMEXTRACT
	
	SEG_LOG_DEBUG "Extract the new perimeter for production site ${HOST_PRDSIT}"  
	
	# Execute the dynamic stored procedure
	NSTEP=${NJOB}_EXTRACT_PERIMETER_${PERIMETER_SCOPE}
	LIBEL='Extract Perimeter'
	BCP_WAY="OUT"; BCP_VER="+"; BCP_FS=$'\x1c'
	BCP_O=${DFILT}/${NSTEP}_${IB}_${FILE_ID}_EXTRACT_NEW_PERIMETER_UNSORT.dat
	BCP_QRY="execute BTRAVI..PsSEGEXTRACT_${PERIMETER_SCOPE}_${HOST_PRDSIT}"
	BCP
	
	# Sort it to be able to compare line by line 
	# with the existing perimeter file => need to have the same order
	NEW_PERIMETER=${DFILT}/${NSTEP}_${IB}_${FILE_ID}_EXTRACT_NEW_PERIMETER.dat
	
	SEG_LOG_DEBUG "Sort new perimeter file"  
	SORT_INPUT_FILE=${DFILT}/${NSTEP}_${IB}_${FILE_ID}_EXTRACT_NEW_PERIMETER_UNSORT.dat
	SORT_OUTPUT_FILE=${NEW_PERIMETER}
	SORT_PERIMETER
	
	# Delete the unsort file
	rm -f ${SORT_INPUT_FILE}
	
	time_8=`date +%s`;
	SEG_LOG_INFO "End of new perimeter extract in $(expr $time_8 - $time_7) sec"  
	
	#-----------------------------------
	# Merge the existing perimeter file with the new extracted one
	# Update the schema if needed
	#-----------------------------------
	
	time_9=`date +%s`;
	SEG_LOG_DEBUG "Update perimeter java batch"  


	# Create the output file of the update perimeter batch, add the good rights on it (read/write) 
	NSTEP=${NJOB}_01_${HOST_PRDSIT}_PREPARE_PERIMETER_UPDATE_${PERIMETER_SCOPE}
	LIBEL="Prepare temporary files for perimeter update"
	STEPSTART

	UPDATEPERIM_OUTPUT_FILE=${DFILT_SEG_PERIM_FILE%.dat}_TMP.dat
	SEG_PERIM_OUTPUT_FILE=${UPDATEPERIM_OUTPUT_FILE%.dat}_UPDATED.dat

	rm -f $DFILT_SEG_PERIM_FILE $UPDATEPERIM_OUTPUT_FILE $SEG_PERIM_OUTPUT_FILE 2>&1
	cp $SEG_PERIM_FILE $DFILT_SEG_PERIM_FILE
	cat /dev/null > $UPDATEPERIM_OUTPUT_FILE
	cat /dev/null > $SEG_PERIM_OUTPUT_FILE

	STEPEND $?

	# java batch
	NSTEP=${NJOB}_01_${HOST_PRDSIT}_UPDATE_PERIMETER_${PERIMETER_SCOPE}
	WS_BATCH_NAME=segmentationUpdatePerimeter
	LIBEL="Update perimeter"
	WS_PARAMS_TEXT << EOF
CURRENT_PERIMETER_FILE	${DFILT_SEG_PERIM_FILE}
NEW_PERIMETER_FILE	${NEW_PERIMETER}
PERIMETER_SCOPE	${PERIMETER_SCOPE_CT}
EOF
	WS_BATCH

	time_10=`date +%s`;
	SEG_LOG_INFO "End of update perimeter Java batch in $(expr $time_10 - $time_9) sec"  

	#-----------------------------------
	# Process the segmentation and aggregation based on the merge perimeter file
	#-----------------------------------
	NSTEP=${NJOB}_01_${HOST_PRDSIT}_SEGMENTATION_${PERIMETER_SCOPE}
	
	time_11=`date +%s`;
	SEG_LOG_DEBUG "Segmentation process java batch"  
	SEG_LOG_INFO "Concurrency Factor is: $CON_FACTOR"
	
	# Need to start the group segmentation
	START_GROUP_SEGMENTATION_VALUE=$([ ${FIRST_PRDSITCF} == ${HOST_PRDSIT} ] && echo "true" || echo "false")
	
	# java batch
	WS_BATCH_NAME=segmentationProductionEngine
	LIBEL="Process segmentation process"
	WS_PARAMS_TEXT << EOF
INPUT_FILE	${UPDATEPERIM_OUTPUT_FILE}
CONCURRENCY_FACTOR	${CON_FACTOR}
PERIMETER_SCOPE	${PERIMETER_SCOPE_CT}
RUN_DATE	${RUN_DATE}
RUN_FREQUENCIES ${SEG_FREQ}
START_GROUP_SEGMENTATION ${START_GROUP_SEGMENTATION_VALUE}
EOF
	WS_BATCH

	NSTEP=${NJOB}_01_${HOST_PRDSIT}_CLEANUP
	# Begin cleanup
	#-----------------------------------------------------------------
	LIBEL="Deleting job temporary files"
	RMFIL "$NEW_PERIMETER $DFILT_SEG_PERIM_FILE"

	time_12=`date +%s`;
	SEG_LOG_INFO "End of segmentation Java batch in $(expr $time_12 - $time_11) sec"  
	SEG_LOG_INFO "End of full process in $(expr $time_12 - $time_1) sec"  

	return 0
}