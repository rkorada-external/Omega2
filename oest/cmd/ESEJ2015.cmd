#----------------------------------------------------------------------------
# FUNCTION: SEG_SNP_OLDRUN
#
# Input parameters:
#
# Subject: Function that process the snapshot on old segmentation results
# It has to be runned before saving the segmentation results
# Return 0 if OK, >0 otherwise
#----------------------------------------------------------------------------

SEG_SNP_OLDRUN() {
	# Used to log the function name
	SEG_LOG_FUNCTION="SEG_SNP_OLDRUN"
	
	time_1=`date +%s`; 
	SEG_LOG_DEBUG "Start Snapshot for old run"
		
	NSTEP=${NJOB}_SNP_OLDRUN_COMPUTATION
	LIBEL="Extract run to snapshot before inserting the new segmentation results"
	ISQL_BASE="BSEG"
	ISQL_QRY="select r.SGTRUN_NT, r.SGT_NT, r.SGTSNAP_B "
	ISQL_QRY+="from BSEG..TSEGRUNSCHED s "
	# Select last completed run for the segmentation type where the eval has been done
	ISQL_QRY+="inner join BSEG..TSEGRUN r ON r.SGT_NT = s.SGT_NT AND r.SGTEVAL_B = 1 AND r.SGTRUNSTS_CT = '5' "
	ISQL_QRY+="AND r.SGTRUNDAT_D = (select max(r1.SGTRUNDAT_D) from BSEG..TSEGRUN r1 where r1.SGTRUNSTS_CT = '5' and r1.SGTEVAL_B = 1 and r1.SGT_NT = s.SGT_NT)"
	# Select scheduled runs that ask only for a snapshot without evaluation for the current date
	ISQL_QRY+="where s.SGTSNAP_B = 1 AND s.SGTEVAL_B = 0 AND s.SGTRUNDAT_D = convert(datetime, '${RUN_DATE}', 100)"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_EXTRACT_SNP_OLDRUN.dat
	ISQL
		
	# call the common snapshot function
	SEG_SNP_PLAN=${DFILT}/${NSTEP}_${IB}_EXTRACT_SNP_OLDRUN.dat
	SEG_SNP
	
	time_2=`date +%s`; 
	SEG_LOG_DEBUG "End in $(expr $time_2 - $time_1) sec"
	
	return 0
}