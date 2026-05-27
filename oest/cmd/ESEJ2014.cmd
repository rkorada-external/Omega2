#----------------------------------------------------------------------------
# FUNCTION: SEG_SNP
#
# Input parameters:
# SEG_SNP_PLAN  : File containing the list of segmentation run to snapshot
#
# Subject: Function that process the snapshot of a given list of segmentation run
# 	It extracts rows from the table BSTA..TSEGRUNRES and BSTA..TSEGRUNERR related to the runs 
#	and copies them to BSTA..TSEGRUNRES_H and TSEGRUNERR_H	
# Return 0 if OK, >0 otherwise
#----------------------------------------------------------------------------

SEG_SNP() {
	# Used to log the function name
	SEG_LOG_FUNCTION="SEG_SNP"
	
	SEG_LOG_DEBUG "SEG_SNP - Start snapshot"
	
	# The file SEG_SNP_PLAN contains the following columns:
	# - SGTRUN_NT: Id of the run to snapshot
	# - SGT_NT: Id of the segmentation related to the run
	# - SGTSNAP_B: Boolean that indicates if the run SGTRUN_NT has already been snapshoted
	
	# List of segmentation run ids to snapshot
	SEGRUN_NT_LIST=($(awk 'BEGIN {FS = OFS = "[ ]*"} {if( NR >= 3 && $4 != 1 && $4 != ""){print $2}}'  ${SEG_SNP_PLAN}))
	# List of segmentation run ids to snapshot, BUT already done in previous night batch
	COMPLETED_SEGRUN_NT_LIST=($(awk 'BEGIN {FS = OFS = "[ ]*"} {if( NR >= 3 && $4 == 1 && $4 != ""){print $2}}'  ${SEG_SNP_PLAN}))
	
	# If there is no element in the list => no run ids to snapshot
	if [ ${#SEGRUN_NT_LIST[*]} = 0 ]; then
		SEG_LOG_INFO "No run ids to snapshot"
		return 0
	fi
	
	SEG_LOG_DEBUG "Run ids to snapshot: ${SEGRUN_NT_LIST[*]}"
	
	# Join the list of run ids to snapshot
	SQL_SEGRUN_NT=$(printf ",%s" "${SEGRUN_NT_LIST[@]}")
	SQL_SEGRUN_NT=${SQL_SEGRUN_NT:1}
	
	# Update the run we snapshot to indicate that the process has been done 
	NSTEP=${NJOB}_SNP_UPDATE_STATUS
	LIBEL="Update runs snapshot status"
	ISQL_BASE="BSEG"
	ISQL_QRY="update BSEG..TSEGRUN set SGTSNAP_B=1, LSTUPD_D=getDate(), LSTUPDUSR_CF=suser_name() where SGTRUN_NT in(${SQL_SEGRUN_NT})"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_UPDATE_STATUS.log
	ISQL
	
	SEG_LOG_DEBUG "End snapshot"
	
	return 0
}