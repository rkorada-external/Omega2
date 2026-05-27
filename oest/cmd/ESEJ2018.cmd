#----------------------------------------------------------------------------
# Diary notifications WS Call JOB
#
# Input parameters:
# Author :		N. GASULL
# Subject:		Diary notifications
# Parameters:
#	N/A
# Description:
#	Call diary notifications service in order to provide notifications depending on the current batch.
# Return 0 if OK, >0 otherwise
#----------------------------------------------------------------------------

FINALIZE_SEGMENTATION() {

	segErr=
	if [ -n "$STEP_ERR" -a "$STEP_ERR" -gt 0 ] ; then
	
		# SEG_ERROR can either be a function that prints an error message or an error message string
		if [ -n "$(whence SEG_ERROR)" ] ; then
			# Execute as a function, and store result
			segErr="$(SEG_ERROR)"
		elif [ -n "$SEG_ERROR" ] ; then
			segErr="$SEG_ERROR"
		fi
		if [ -z "$segErr" ] ; then
			segErr="segmenation couldn't be finalized properly, please contact an administrator."
		fi
		
		SEG_LOG_INFO "Segmentation failed with error: $segErr"
	fi
	
	# Escape quotes
	segErr="$(echo $segErr | sed "s/'/''/g")"
	
	NSTEP=${NJOB}_UPDATE_RUN_ERRORS
	LIBEL="Unfinished runs in error"
	ISQL_BASE="BSEG"
	ISQL_QRY="update TSEGRUN set SGTRUNSTS_CT='6', SGTRUNERR_CT='$STEP_ERR', SGTRUNERR_LL='${segErr:0:255}', LSTUPD_D=getDate(), LSTUPDUSR_CF=suser_name() where SGTRUNSTS_CT not in ('4', '5', '6') and SGTSIMU_B=0"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_${FILE_ID}_UPDATE_RUN_ERRORS.log
	ISQL

	NSTEP=${NJOB}_NOTIFICATIONS
	LIBEL="Handle diary notifications for runs in the batch plan"
	WS_BATCH_NAME=segmentationNotification
	WS_BATCH
}

EXCEPTION() {
	EXCEPTION_INIT
	FINALIZE_SEGMENTATION
	EXCEPTION_END
}
