#----------------------------------------------------------------------------
# FUNCTION: SEG_SNP_NEWRUN
#
# Input parameters:
#
# Subject: Function that process the snapshot on new segmentation results
# It has to be runned after saving the segmentation results
# Return 0 if OK, >0 otherwise
#----------------------------------------------------------------------------

SEG_SNP_NEWRUN() {
	# Used to log the function name
	SEG_LOG_FUNCTION="SEG_SNP_NEWRUN"
	
	time_1=`date +%s`; 
	SEG_LOG_DEBUG "Start Snapshot for new runs"
	
	# Join the list of frequencies to use in order to be used inside a in() statement
	SQL_FREQ=$(echo $SEG_FREQ | sed -r "s/([0-9]+)/'\1'/g")
	
	NSTEP=${NJOB}_SNP_NEWRUN_COMPUTATION
	LIBEL="Extract run to snapshot before inserting the new segmentation results"
	ISQL_BASE="BSEG"
	ISQL_QRY="select r.SGTRUN_NT, r.SGT_NT, r.SGTSNAP_B "
	ISQL_QRY+="from BSEG..TSEGRUNSCHED s "
	# Select last completed run for the segmentation type where the eval has been done
	ISQL_QRY+="inner join BSEG..TSEGRUN r ON r.SGT_NT = s.SGT_NT AND r.SGTEVAL_B = 1 AND r.SGTRUNSTS_CT = '5' "
	ISQL_QRY+="AND r.SGTRUNDAT_D = (select max(r1.SGTRUNDAT_D) from BSEG..TSEGRUN r1 where r1.SGTRUNSTS_CT = '5' and r1.SGTEVAL_B = 1 and r1.SGT_NT = s.SGT_NT) "
	# Select scheduled runs that ask for a snapshot AND an evaluation for the current date
	ISQL_QRY+="where s.SGTSNAP_B = 1 AND s.SGTEVAL_B = 1 AND s.SGTRUNDAT_D = convert(datetime, '${RUN_DATE}', 100) "
	ISQL_QRY+="UNION "
	ISQL_QRY+="select r.SGTRUN_NT, s.SGT_NT, r.SGTSNAP_B "
	ISQL_QRY+="from BEST..TSEGMENTATION s "
	# Select last completed run for the segmentation type where the eval has been done
	ISQL_QRY+="inner join BSEG..TSEGRUN r ON r.SGT_NT = s.SGT_NT AND r.SGTEVAL_B = 1 AND r.SGTRUNSTS_CT = '5' "
	ISQL_QRY+="inner join BEST..TSEGTYPE t on t.sgttyp_nt = s.sgttyp_nt "
	ISQL_QRY+="AND r.SGTRUNDAT_D = ( select max(r1.SGTRUNDAT_D) from BSEG..TSEGRUN r1 where r1.SGTRUNSTS_CT = '5' and r1.SGTEVAL_B = 1 and r1.SGT_NT = s.SGT_NT) "
	ISQL_QRY+="where s.SNPFREQ_CT in (${SQL_FREQ}) and s.sgtsts_cf = '3' and t.SGTTYPSTS_CT = '1' "
	ISQL_O=${DFILT}/${NSTEP}_${IB}_EXTRACT_SNP_NEWRUN.dat
	ISQL
	
	# call the common snapshot function
	SEG_SNP_PLAN=${DFILT}/${NSTEP}_${IB}_EXTRACT_SNP_NEWRUN.dat
	SEG_SNP
	
	time_2=`date +%s`; 
	SEG_LOG_DEBUG "End in $(expr $time_2 - $time_1) sec"
	
	return 0
}