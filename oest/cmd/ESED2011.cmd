#=============================================================================
# FUNCTION					: SIM_PROCESS
# nom du script SHELL		: ESED2011.cmd
# revision			        : $Revision:   1.0  $
# date de creation		    : 18/11/2013
# auteur			        : N. GASULL
# references des specifications	: 
#-----------------------------------------------------------------------------
# description : 
# Launch the segmentation process for simulation
#-----------------------------------------------------------------------------
# Modification history:
# 18/11/2013	NGA: Creation  
# 15/01/2015	NGA: Fixing cleaning of work files, sorting final data for better performance and filtering on level 0 like in ESEJ2017 (regular segmentation process)
# 26/05/2021	MOD 3: Parth : SPIRA 96589 Pass Concurrency factor from job to java batch to limit the number of threads
# 19/07/2021	MOD 4: Parth : SPIRA 96590 
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctws.cmd

SGTRUN_NT=$1
# MOD 4
CON_FAC=$2
SGTTYPMOD_NT=$3
RUN_DATE="$(date +'%Y%m%d')"
DEFAULT_ERR_MSG="Unexpected error while running simulation. Please check the batch exectution logs."

echo $CON_FAC
echo $SGTTYPMOD_NT

#===============================================================================
# Definitions of Job functions
#===============================================================================

SIM_PROCESS() {

	if [ "$PERIMETER_SCOPE_CT" = "2" ] ; then
		LETTERED_SCOPE="RETRO"
	else
		LETTERED_SCOPE="ASM"
	fi
	
	# Find DFILP for PRDSIT_CF's associated user. We will find there the perimeter file
	case $PRDSIT_CF in
		SGP1 )
			PRDSIT_USER=ubas
			;;
		FRA1 )
			PRDSIT_USER=ubeu
			;;
		USA1 )
			PRDSIT_USER=ubam
			;;
		* )
			ECHO_LOG "ERROR" "Unknown PRDSIT_CF: $PRDSIT_CF" >&2
			echo "Unknown PRDSIT_CF: $PRDSIT_CF" > $ERR_MSG_FILE
			return 11
			;;
	esac

	INPUT_FILE_BASENAME="${ENV_PREFIX}_SEG_SIM_${PRDSIT_CF}_${LETTERED_SCOPE}_PERIMETER"
	DFILP_UBXX=$(echo "$DFILP" | sed 's/\/'`whoami`'\//\/'$PRDSIT_USER'\//')
	
	ECHO_LOG "INFO" "Processing ${INPUT_FILE_BASENAME}"
	
	NEW_PERIMETER="${DFILP_UBXX}/${INPUT_FILE_BASENAME}.dat"
	ORIGINAL_PERIMETER="${DFILP}/${INPUT_FILE_BASENAME}.dat"
	WORK_PERIMETER="${DFILT}/${INPUT_FILE_BASENAME}.dat"
	UPDATED_PERIMETER="${DFILT}/${INPUT_FILE_BASENAME}_UPDATED.dat"
	RUN_RESULT="${DFILT}/${INPUT_FILE_BASENAME}_RESULT_${SGTRUN_NT}.dat"
	RUN_RESULT_SORT="${DFILT}/${INPUT_FILE_BASENAME}_RESULT_SORT_${SGTRUN_NT}.dat"
	ERROR_PERIMETER="${DFILT}/${INPUT_FILE_BASENAME}_ERROR_${SGTRUN_NT}.dat"
	AGG_PERIMETER="${DFILT}/${INPUT_FILE_BASENAME}_AGG.dat"
	
	# Cleaning old work files
	NSTEP=${NJOB}_CLEAN_PREVIOUS_WORK_FILES
	LIBEL="Cleaning existing previous work files"
	RMFIL "$WORK_PERIMETER $UPDATED_PERIMETER $RUN_RESULT $RUN_RESULT_SORT $ERROR_PERIMETER $AGG_PERIMETER"
	
	# Check if the main segmentation process produced a new perimeter file. In that case, take it.
	if [ "$DFILP_UBXX" != "$DFILP" -a -r "$NEW_PERIMETER" ] ; then
		NSTEP=${NJOB}_SIM_${PRDSIT_CF}_${LETTERED_SCOPE}_TAKE_NEW_PERIMETER
		LIBEL="Move the new perimeter from segmentation main process to ubgl's \$DFILP"
		STEPSTART
		mv -f "$NEW_PERIMETER" "$ORIGINAL_PERIMETER"
		STEPEND $?
	fi
	
	# Copy the perimeter to the temporary work path
	cp "$ORIGINAL_PERIMETER" "$WORK_PERIMETER" 2> /dev/null
	if [ $? -ne 0 ] ; then
		ECHO_LOG "ERROR" "Couldn't handle the night batch perimeter file: ${ORIGINAL_PERIMETER}. Full segmentation has to run once first." >&2
		echo "Simulation perimeter unavailable" > $ERR_MSG_FILE
		return 11
	fi

#MOD 3
	# Simulation Java batch
	NSTEP=${NJOB}_SIM_PROCESS
	LIBEL="Simulation execution"
	WS_BATCH_NAME=segmentationSimulation
	WS_PARAMS_TEXT <<EOF
INPUT_FILE ${WORK_PERIMETER}
PERIMETER_SCOPE ${PERIMETER_SCOPE_CT}
PRDSIT_CF ${PRDSIT_CF}
SEGMENTATION_RUN ${SGTRUN_NT}
RUN_DATE ${RUN_DATE}
CONCURRENCY_FACTOR	${CON_FAC}
EOF
	WS_BATCH

	if [ "$SGTTYPMOD_NT" != "2" ] ; then

		if [ -z "$TABLES_CREATED" ] ; then
			NSTEP=${NJOB}_CREATE_RESULT_TABLE_${LETTERED_SCOPE}
			LIBEL="Create results & error tables for run $SGTRUN_NT"
			ISQL_BASE="BSEG"
			ISQL_QRY=$(sed "s/#sgtrunNt/$SGTRUN_NT/g" "$DDDL/BSEG_SEGRESULTSCREATE.tab")
			ISQL_O=${DFILT}/${NSTEP}_${IB}_${FILE_ID}_CREATE_RESULT_TABLE_${SGTRUN_NT}_${LETTERED_SCOPE}.log
			ISQL
		fi
	
		# Handle run results
		NSTEP=${NJOB}_SORT_RESULTS_${SGTRUN_NT}_${PERIMETER_SCOPE}
		LIBEL="Sorting results of run $SGTRUN_NT to improve index creation performance"
		SORT_WDIR=${SORTWORK}
		SORT_CMD=`CFTMP`
		SORT_I="$RUN_RESULT 1000 1"
		SORT_O="$RUN_RESULT_SORT"
		SORT_FS=$'\x1c'
		INPUT_TEXT $SORT_CMD <<EOF
		/FIELDS
			SGMT_NF 1:1 -  1:,
			CTR_NF 4:1 -  4:,
			UWY_NF 5:1 -  5:EN,
			UW_NT 6:1 -  6:EN,
			SEC_NF 7:1 -  7:EN,
			RTO_NF 8:1 -  8:EN,
			SGTLVL_NT 2:1 -  2:EN
		/KEYS
			SGMT_NF,
			CTR_NF,
			UWY_NF,
			UW_NT,
			SEC_NF,
			RTO_NF
		/CONDITION
			LVL0 SGTLVL_NT = 0
		/INCLUDE
			LVL0
exit
EOF
		SORT

	else

		if [ -z "$TABLES_CREATED" ] ; then

			NSTEP=${NJOB}_CREATE_RETRO_RESULT_TABLES_${SGTRUN_NT}_${LETTERED_SCOPE}
			LIBEL="Create results & error tables for retro run $SGTRUN_NT (with SGTRUL_NT)"
			ISQL_BASE="BSEG"
			ISQL_QRY="use BSEG
go

-- Create results table
CREATE TABLE TSEGRUNRES_${SGTRUN_NT} (
SGMT_NF              USGMT_NF                       not null,
SGTLVL_NT            int                            not null,
SEGCTRTYP_CT         UBANVAL_CT                     null,
CTR_NF               UCTR_NF                        not null,
UWY_NF               UUWY_NF                        not null,
UW_NT                UUW_NT                         not null,
SEC_NF               USEC_NF                        not null,
RTO_NF               UCLI_NF                        not null,
SSD_CF				USSD_CF						   not null,
SGTRUL_NT			int							   null
)
lock datapages
go

GRANT ALL on TSEGRUNRES_${SGTRUN_NT} to GDBBATCH
GRANT SELECT on TSEGRUNRES_${SGTRUN_NT} to GOMEGA
GRANT SELECT on TSEGRUNRES_${SGTRUN_NT} to GCONSULT
GRANT SELECT on TSEGRUNRES_${SGTRUN_NT} to dbo
go

-- Create error results table
create table TSEGRUNERR_${SGTRUN_NT} (
SEGCTRTYP_CT         UBANVAL_CT                     null,
CTR_NF               UCTR_NF                        not null,
UWY_NF               UUWY_NF                        not null,
UW_NT                UUW_NT                         not null,
SEC_NF               USEC_NF                        not null,
END_NT               UEND_NT                        not null,
RTO_NF               UCLI_NF                        not null,
PLC_NT               UPLC_NT                        null,
SSD_CF				USSD_CF						   not null,
SGTERR_CT            char(12)                       not null,
SGTERR_LL            UL255                          null,

)
lock datapages
go

GRANT ALL on TSEGRUNERR_${SGTRUN_NT} to GDBBATCH
GRANT SELECT on TSEGRUNERR_${SGTRUN_NT} to GOMEGA
GRANT SELECT on TSEGRUNERR_${SGTRUN_NT} to GCONSULT
GRANT SELECT on TSEGRUNERR_${SGTRUN_NT} to dbo
go"
			ISQL_O=${DFILT}/${NSTEP}_${IB}_${FILE_ID}_CREATE_RETRO_RESULT_TABLES_${SGTRUN_NT}_${LETTERED_SCOPE}.log
			ISQL
		fi

		# Handle run results
		NSTEP=${NJOB}_SORT_RETRO_RESULTS_${SGTRUN_NT}_${PERIMETER_SCOPE}
		LIBEL="Sorting retro prop results of run $SGTRUN_NT to improve index creation performance"
		SORT_WDIR=${SORTWORK}
		SORT_CMD=`CFTMP`
		SORT_I="$RUN_RESULT 1000 1"
		SORT_O="$RUN_RESULT_SORT"
		SORT_FS=$'\x1c'
		INPUT_TEXT $SORT_CMD <<EOF
		/FIELDS
			SGMT_NF 1:1 -  1:,
			CTR_NF 4:1 -  4:,
			UWY_NF 5:1 -  5:EN,
			UW_NT 6:1 -  6:EN,
			SEC_NF 7:1 -  7:EN,
			RTO_NF 8:1 -  8:EN,
			SGTLVL_NT 2:1 -  2:EN,
			SGTRUL_NT 9:1 -  9:EN
		/KEYS
			SGMT_NF,
			CTR_NF,
			UWY_NF,
			UW_NT,
			SEC_NF,
			RTO_NF,
			SGTRUL_NT
		/CONDITION
			LVL0 SGTLVL_NT = 0
		/INCLUDE
			LVL0
exit
EOF
		SORT	

	fi

	# Insert OK results
	NSTEP=${NJOB}_SIM_INSERT_RES
	LIBEL='Insert result in simulation table'
	BCP_WAY="IN"; BCP_VER=""; BCP_RMINFILE="NO"; BCP_TRUNCATE="NO"; BCP_FS=$'\x1c'
	BCP_I=${RUN_RESULT_SORT}
	BCP_TABLE=$RESTABNME_LL
	BCP
	
	# Insert results in error
	NSTEP=${NJOB}_SIM_INSERT_ERR
	LIBEL='Insert result in simulation errors table'
	BCP_WAY="IN"; BCP_VER=""; BCP_RMINFILE="NO"; BCP_TRUNCATE="NO"; BCP_FS=$'\x1c'
	BCP_I=${ERROR_PERIMETER}
	BCP_TABLE=$ERRTABNME_LL
	BCP

	if [ "$SGTTYPMOD_NT" != "2" ] ; then

		if [ -z "$TABLES_CREATED" ] ; then
			NSTEP=${NJOB}_CREATE_INDEX_${LETTERED_SCOPE}
			LIBEL="Create index for run $SGTRUN_NT results table"
			ISQL_BASE="BSEG"
			ISQL_QRY=$(sed "s/#sgtrunNt/$SGTRUN_NT/g" "$DDDL/BSEG_SEGRESULTSINDEX.tab")
			ISQL_O=${DFILT}/${NSTEP}_${IB}_${FILE_ID}_CREATE_INDEX_${SGTRUN_NT}.log
			ISQL
			
			TABLES_CREATED=definitely
		fi

	else

		if [ -z "$TABLES_CREATED" ] ; then
			NSTEP=${NJOB}_CREATE_RETRO_INDEX_${LETTERED_SCOPE}
			LIBEL="Create index for run $SGTRUN_NT results table"
			ISQL_BASE="BSEG"
			ISQL_QRY="use BSEG
go

create unique index ISEGRUNRES_${SGTRUN_NT}_00 on TSEGRUNRES_${SGTRUN_NT} (
	SGMT_NF ASC,
	CTR_NF ASC,
	UWY_NF ASC,
	UW_NT ASC,
	SEC_NF ASC,
	RTO_NF ASC,
	SGTLVL_NT ASC,
	SGTRUL_NT ASC
	
)
go

create unique index ISEGRUNERR_${SGTRUN_NT}_00 on TSEGRUNERR_${SGTRUN_NT} (
	CTR_NF ASC,
	UWY_NF ASC,
	UW_NT ASC,
	SEC_NF ASC,
	END_NT ASC,
	RTO_NF ASC
)
go"
			ISQL_O=${DFILT}/${NSTEP}_${IB}_${FILE_ID}_CREATE_RETRO_INDEX_${SGTRUN_NT}.log
			ISQL
			
			TABLES_CREATED=definitely
		fi

	fi

	# Update perimeter
	mv -f "$UPDATED_PERIMETER" "$ORIGINAL_PERIMETER"
	
	return 0
}

#===============================================================================
# Simulation run status update. Will only affect runs that have not already been finished
# (which is useful to allow individual error processing against global status passing for group simulations)
# Usage: SIM_UPDATE_STATUS PRDSIT_CF SIM_STATUS [ERR_CODE ERR_MSG]
#
SIM_UPDATE_STATUS() {

	SIM_STATUS=$1

	# Error management
	if [ $# -ge 2 ] ; then
		ERR_CODE=$2
		shift 2
		ERR_MSG="$*"
		sim_err_setup="SGTRUNERR_CT='$ERR_CODE', SGTRUNERR_LL='$ERR_MSG',"
	else
		sim_err_setup=
	fi

	# Production site / group simulation management
	if [ -n "$PRDSIT_CF" ] ; then
		prdsit_criteria="and PRDSIT_CF='$PRDSIT_CF'"
	else
		PRDSIT_CF="GROUP"
		prdsit_criteria="and PRDSIT_CF is null"
	fi

	NSTEP=${NJOB}_SIM_UPDATE_STATUS_${PRDSIT_CF}
	LIBEL="Update simulation status"
	ISQL_BASE="BSEG"
	ISQL_QRY="	update BSEG..TSEGRUN set SGTRUNSTS_CT='$SIM_STATUS', $sim_err_setup LSTUPD_D=getDate(), LSTUPDUSR_CF=suser_name()
				where SGTRUNSTS_CT in ('1', '2') and SGTRUN_NT=$SGTRUN_NT $prdsit_criteria
			"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_UPDATE_SIM_STATUS.log
	ISQL
}

#===============================================================================
# Cleanup function to be called after 
#
CLEANUP() {
	returnCode=$1
	
	# Clean work files (in prod sites loop only)
	if [ -n "$PRDSIT_CF" ]; then
		NSTEP=${NJOB}_CLEAN_TMPS
		LIBEL="Cleaning temporary files"
		RMFIL "$WORK_PERIMETER ${RUN_RESULT} ${RUN_RESULT_SORT} ${ERROR_PERIMETER} $AGG_PERIMETER"
	fi
	
	if [ -z "$SIM_GROUP" ] ; then
		
		if [ "$returnCode" -ne 0 ] ; then
			
			if [ -s "$ERR_MSG_FILE" ] ; then
				errMsg=$(cat $ERR_MSG_FILE)
			fi
			if [ -z "$errMsg" ] ; then
				errMsg="$DEFAULT_ERR_MSG"
			fi
			
			SIM_UPDATE_STATUS 6 $returnCode $errMsg
		else
			SIM_UPDATE_STATUS 5
		fi
	else
		if [ $returnCode -eq 0 ] ; then
			SIM_UPDATE_STATUS 5
		else
			SIM_UPDATE_STATUS 6 11 "Not every night batch perimeter is available for this group segmentation. Please check the batch exectution logs for detailed information."
		fi
	fi
	
	rm -f $ERR_MSG_FILE
}

#===============================================================================
# Cleanup function to be called whatever the status of SIM_PROCESS
#
EXCEPTION() {
	EXCEPTION_INIT
	
	# Restore perimeter for next simulations
	if [ -s $WORK_PERIMETER ] ; then
		mv -n "$WORK_PERIMETER" "$ORIGINAL_PERIMETER"
	fi

	CLEANUP $STEP_ERR	
	EXCEPTION_END
}

#===============================================================================
# Job execution
#===============================================================================

# Move to Infomega/DW
NSTEP=${NJOB}_SRV_SWITCH_DW
LIBEL="Switch to DW server"
SWITCH_SRV ${INF_SRV}

# Delete obsolete runs and their results (previous night)
NSTEP=${NJOB}_DELETE_OBSOLETE_RUNS
LIBEL="Delete obsolete runs and associated results/errors"
ISQL_BASE="BSEG"
ISQL_QRY="-- Execute SP
	BSEG.dbo.PdSEGCLEANOBSOLETE_01"
ISQL_O=${DFILT}/${NSTEP}_${IB}_${FILE_ID}_DELETE_OBSOLETE_RUNS.log
ISQL

# Generating table names and setting them in associated run, considering possibility of user aliasing
NSTEP=${NJOB}_NAMING_TABLES_${SGTRUN_NT}
LIBEL="Generating table names and setting them in associated run $SGTRUN_NT"
ISQL_BASE="BSEG"
ISQL_QRY="
	UPDATE BSEG..TSEGRUN SET SGTRESTABNME_LL='BSEG.' + user_name() + '.TSEGRUNRES_${SGTRUN_NT}', SGTERRTABNME_LL='BSEG.' + user_name() + '.TSEGRUNERR_${SGTRUN_NT}', LSTUPD_D=getDate(), LSTUPDUSR_CF=suser_name() WHERE SGTRUN_NT=$SGTRUN_NT"
ISQL_O=${DFILT}/${NSTEP}_${IB}_NAMING_TABLES_${SGTRUN_NT}.log
ISQL

NSTEP=${NJOB}_SIM_FETCH_SCOPE
LIBEL="Retrieve data related to the segmentation type of the segmentation to run"
BCP_WAY="OUT"; BCP_VER="+"; BCP_FS="~"
BCP_O=${DFILT}/${NSTEP}_${IB}_SEGTYP_DATA.dat
BCP_QRY="select r.SGTSCOPE_CT, r.PRDSIT_CF, r.SGTRESTABNME_LL, r.SGTERRTABNME_LL from BSEG..TSEGRUN r where r.SGTSIMU_B=1 and r.SGTRUNSTS_CT='1' and r.SGTRUN_NT = ${SGTRUN_NT}"
BCP

#===============================================================================
# PROCESS SIMULATION FOR EACH "SCOPE" (PROD SITE + ACTUAL SCOPE)
# Read the BCP out lines according to the pattern: "PERIMETER_SCOPE PRDSIT_CF"
# 
backIFS="$IFS"
IFS="\r\n"
for scope_line in `cat "$BCP_O"` ; do
	IFS="$backIFS"
	if [ -z "$scope_line" ] ; then
		continue
	fi

	resultset_pattern=" *([1-3]) *~([A-Z]{3}1)? *~([A-Za-z0-9._]+)~([A-Za-z0-9._]+) *"
	sim_scope=`echo "$scope_line" | sed -r "s/${resultset_pattern}/\1/" | grep -E '^[1-3]$'`
	sim_prod_sites=`echo "$scope_line" | sed -r "s/${resultset_pattern}/\2/" | grep -E '^[A-Z]{3}1$'`
	RESTABNME_LL=$(echo "$scope_line" | sed -r "s/${resultset_pattern}/\3/" | grep -E '^[A-Za-z0-9._]+$')
	ERRTABNME_LL=$(echo "$scope_line" | sed -r "s/${resultset_pattern}/\4/" | grep -E '^[A-Za-z0-9._]+$')
	SIM_GROUP=
	TABLES_CREATED=

	# Define the global "scope"
	if [ -z "$sim_prod_sites" ] ; then
		# Either fetched production site or scope fetched is null. This is a group segmentation.
		sim_prod_sites="FRA1 SGP1 USA1"
		SIM_GROUP=yes
	fi

	sim_call_err=0
	for PRDSIT_CF in $sim_prod_sites ; do
		PERIMETER_SCOPE_CT=$sim_scope
		ERR_MSG_FILE=$(mktemp)
		SIM_PROCESS
		ret=$?
		sim_call_err=$(($sim_call_err + $ret))
		CLEANUP $ret
	done
	
	# Unsetting production site. Now handling group runs.
	PRDSIT_CF=
	CLEANUP $sim_call_err

	# Preparing results Aggregation for visualization performance optimization
	if [ "$SGTTYPMOD_NT" != "2" ] ; then
		NSTEP=${NJOB}_INSERT_RUNAGG_${SGTRUN_NT}
		LIBEL="Insert segmentation aggregated results for run $SGTRUN_NT"
		ISQL_BASE="BSEG"
		ISQL_QRY="INSERT INTO BSEG..TSEGRUNAGG (SGTRUN_NT, SGMT_NF, ROWCOUNT_NT, SGTRUL_NT) SELECT $SGTRUN_NT, SGMT_NF, count(*), null FROM $RESTABNME_LL GROUP BY SGMT_NF"
		ISQL_O=${DFILT}/${NSTEP}_${IB}_INSERT_RUNAGG_${SGTRUN_NT}.log
		ISQL
	else
		NSTEP=${NJOB}_INSERT_RUNAGG_${SGTRUN_NT}
		LIBEL="Insert segmentation aggregated results for run $SGTRUN_NT"
		ISQL_BASE="BSEG"
		ISQL_QRY="INSERT INTO BSEG..TSEGRUNAGG (SGTRUN_NT, SGMT_NF, ROWCOUNT_NT, SGTRUL_NT) SELECT $SGTRUN_NT, SGMT_NF, count(*), SGTRUL_NT FROM $RESTABNME_LL GROUP BY SGMT_NF, SGTRUL_NT"
		ISQL_O=${DFILT}/${NSTEP}_${IB}_INSERT_RUNAGG_${SGTRUN_NT}.log
		ISQL
	fi


done

NSTEP=${NJOB}_NOTIFICATIONS
LIBEL="Handle diary notifications for simulation runs"
WS_BATCH_NAME=segmentationNotification
WS_PARAMS_TEXT << EOF
SIMULATION_RUN	$SGTRUN_NT
EOF
# No diary notif for simulation # WS_BATCH


NSTEP=${NJOB}_REMOVE_SEGTYP_DATA_FILE
# Begin rm
#------------------------------------------------------------------------------
LIBEL="Step to remove segtyp_data temporary file"
RMFIL "${DFILT}/${NJOB}_SIM_FETCH_SCOPE_${IB}_SEGTYP_DATA.dat"