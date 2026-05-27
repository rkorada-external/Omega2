#----------------------------------------------------------------------------
# FUNCTION: SEGMENTATION
#
# Input parameters:
# - RUN_DATE: The date of the run (used to retrieve scheduled run)
# - SEG_FREQ: Frequencies to process
#
# Subject: Launch the full segmentation process
# - snapshot of old and new runs
# - segmentation process of ASS and RETRO perimeter
# - Prepare the simulation perimeter
# - Copy of results to UW and MIS database
# 
# Return 0 if OK, >0 otherwise
# [001] 14/04/2022 Dad spira : 103830 fix PARALLEL_INIT parameter
#----------------------------------------------------------------------------

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctpar.cmd
. ${DUTI}/fctws.cmd

# Include segmentation functions
. ${DCMD}/ESEJ2012.cmd
. ${DCMD}/ESEJ2013.cmd
. ${DCMD}/ESEJ2014.cmd
. ${DCMD}/ESEJ2015.cmd
. ${DCMD}/ESEJ2016.cmd
. ${DCMD}/ESEJ2017.cmd
. ${DCMD}/ESEJ2020.cmd

# Define exception management
. ${DCMD}/ESEJ2018.cmd

SEG_ERROR() {
	ANO_FILE="$(ls -1rt $DFILT/${NJOB}*.ano 2> /dev/null | tail -1)"
	
	if [ -n "$ANO_FILE" -a "$ANO_FILE" != "$LAST_ANO_FILE" ] ; then
		# Print the first line after the first "Server Message" occurence, if found
		awk '
			BEGIN {FS = ":"}
			$1 == "Server Message" {getline; print; exit}' "$ANO_FILE"
	fi
}

# Detect last .ano file (from previous runs) in order to avoid it in error management
LAST_ANO_FILE="$(ls -1rt $DFILT/${NJOB}*.ano 2> /dev/null | tail -1)"

# Initialisation of the Job
JOBINIT

# Initialize the logs
SEG_LOG_INIT

SEG_LOG_INFO "Start the segmentation process"

#======================
# Snapshot and segmentation process
#======================
PARALLEL_INIT 3

# Run the snapshot before saving new segmentation results
NSTEP=${NJOB}_SEG_SNP_OLDRUN
PARALLEL SEG_SNP_OLDRUN

# update the perimeter and process segmentation/aggregation for the assumed perimeter
NSTEP=${NJOB}_SEG_PROCESS_ASM
PERIMETER_SCOPE="ASM"
PERIMETER_SCOPE_CT="1"
PERIMETER_TABLE="TSEGUWASMSEC"
PARALLEL SEG_PROCESS

# update the perimeter and process segmentation/aggregation for the retro perimeter
NSTEP=${NJOB}_SEG_PROCESS_RETRO
PERIMETER_SCOPE="RETRO"
PERIMETER_SCOPE_CT="2"
PERIMETER_TABLE="TSEGUWRETPLC"
PARALLEL SEG_PROCESS

PARALLEL_END

# Batch plan is now initialized

#======================
# Insert results
#======================
	
# Store assumed results
NSTEP=${NJOB}_SEG_STORE_RESULT_ASM
PERIMETER_SCOPE="ASM"
PERIMETER_TABLE="TSEGUWASMSEC"
PERIMETER_SCOPE_CT="1"
SEG_STORE_RESULT

RUNS_FOR_MIS="$RUNS_TO_COMPLETE"

# Store retro results
NSTEP=${NJOB}_SEG_STORE_RESULT_RETRO
PERIMETER_SCOPE="RETRO"
PERIMETER_TABLE="TSEGUWRETPLC"
PERIMETER_SCOPE_CT="2"
SEG_STORE_RESULT

RUNS_FOR_MIS="$RUNS_FOR_MIS $RUNS_TO_COMPLETE"

#======================
# Snapshot
#======================
# Run the snapshot on new segmentation results
NSTEP=${NJOB}_SEG_SNP_NEWRUN
SEG_SNP_NEWRUN


#======================
# Update the simulation perimeter
#======================
NSTEP=${NJOB}_SEG_SIM
time_1=`date +%s`; 
SEG_LOG_DEBUG "Start Simulation update"

# Copy perimeter file for all production sites
for scope in `find ${DFILP} -name "${ENV_PREFIX}_SEG_${HOST_PRDSIT}_*_PERIMETER.dat" -printf "%f\n" | sed "s/${ENV_PREFIX}_SEG_${HOST_PRDSIT}_\(.*\)\_PERIMETER\.dat/\1/"`
do
	SEG_LOG_INFO "SEG_SIM - Copy perimeter for scope ${scope}"
	rm -f ${DFILP}/${ENV_PREFIX}_SEG_SIM_${HOST_PRDSIT}_${scope}_PERIMETER.dat
	cp ${DFILP}/${ENV_PREFIX}_SEG_${HOST_PRDSIT}_${scope}_PERIMETER.dat ${DFILP}/${ENV_PREFIX}_SEG_SIM_${HOST_PRDSIT}_${scope}_PERIMETER.dat
	chmod g+w ${DFILP}/${ENV_PREFIX}_SEG_SIM_${HOST_PRDSIT}_${scope}_PERIMETER.dat
done

time_2=`date +%s`; 
SEG_LOG_DEBUG "End simulation update in $(expr $time_2 - $time_1) sec"


#======================
# SCOR legacy
#======================
NSTEP=${NJOB}_SEG_LEG_MIS
SEG_LEG_MIS

# No need for exception handling any more (and we want to avoid its execution further)
EXCEPTION () {
echo "#"
}

#======================
# Handle Diary notifications management
#======================
FINALIZE_SEGMENTATION

SEG_LOG_INFO "End of the segmentation process"

JOBEND
