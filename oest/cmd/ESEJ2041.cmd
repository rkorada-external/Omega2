#!/bin/ksh
#=============================================================================
# application name               : SEGMENTATION - CREATE MISSING INDEXES
# source name                    : ESEJ2041.cmd
# revision                       : $Revision:   1.0  $
# creation date                  : 31/03/2014
# author                         : P. AVISSEAU
# specifications references      : 
#-----------------------------------------------------------------------------
# description :
# Create indexes for completed Group Segmentations
#-----------------------------------------------------------------------------
# Modification history:
#   <dd/mm/yyyy>  <author>          <comment>
#    23/05/2014    P. AVISSEAU       Remove retrieval of table name, which
#                                    caused error in bcp out
#=============================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

JOBINIT

# Create indexes on Infomega
SWITCH_SRV ${INF_SRV}


NSTEP=${NJOB}_05
# List tables without indexes that belong to the current user
#----------------------------------------------------------------------------
LIBEL="List segmentation tables without indexes belonging to ${USR}"
BCP_WAY="OUT"; BCP_VER="+";
TABLES_WITHOUT_INDEXES=$(CFTMP)
BCP_O=${TABLES_WITHOUT_INDEXES}
BCP_QRY="SELECT CONVERT (CHAR(3), SUBSTRING(t.name, 8, 3)) AS TABLE_TYPE,
	CONVERT (INT, SUBSTRING (t.name, 12, LEN (t.name))) AS RUN_ID
FROM BSEG..sysobjects t
WHERE t.type = 'U'
AND (t.name LIKE 'TSEGRUNRES%' OR t.name LIKE 'TSEGRUNERR%')
AND t.loginame = suser_name()
AND NOT EXISTS (SELECT 1 FROM BSEG..sysindexes i WHERE t.id = i.id AND i.indid > 0)"
BCP_FS='\t'
BCP


NSTEP=${NJOB}_10
# Create indexes for each table without index
#----------------------------------------------------------------------------
LIBEL="Create indexes for each table without index"
while read TABLE_TYPE RUN_ID; do

	# echo "type:${TABLE_TYPE} id:${RUN_ID}"

	if [ "${TABLE_TYPE}" = "RES" ]; then
		NSTEP=${NJOB}_10_${RUN_ID}_RESULTS
		LIBEL="Create index for run ${RUN_ID} on results table TSEGRUNRES_${RUN_ID}"
		ISQL_BASE="BSEG"
		IDX_FILE="${DDDL}/BSEG_SEGRESULTSINDEX.idx"
		if [ ! -s ${IDX_FILE} ]; then
			IDX_FILE="${DDDL}/INF/BSEG_SEGRESULTSINDEX.idx"
		fi
		ISQL_QRY=$(sed "s/#sgtrunNt/${RUN_ID}/g" ${IDX_FILE})
		ISQL_O=${DFILT}/${NSTEP}_${IB}_${RUN_ID}_${TABLE_TYPE}.log
		ISQL
	fi

	if [ "${TABLE_TYPE}" = "ERR" ]; then
		NSTEP=${NJOB}_10_${RUN_ID}_ERRORS
		LIBEL="Create index for run ${RUN_ID} on errors table TSEGRUNERR_${RUN_ID}"
		ISQL_BASE="BSEG"
		IDX_FILE="${DDDL}/BSEG_SEGERRORSINDEX.idx"
		if [ ! -s ${IDX_FILE} ]; then
			IDX_FILE="${DDDL}/INF/BSEG_SEGERRORSINDEX.idx"
		fi
		ISQL_QRY=$(sed "s/#sgtrunNt/${RUN_ID}/g" ${IDX_FILE})
		ISQL_O=${DFILT}/${NSTEP}_${IB}_${RUN_ID}_${TABLE_TYPE}.log
		ISQL
	fi

done < ${TABLES_WITHOUT_INDEXES}


NSTEP=${NJOB}_90
# Begin rm
#-----------------------------------------------------------------
LIBEL="Deleting job temporary files"
RMFIL "${DFILT}/${NJOB}_*_${IB}_*"

JOBEND
