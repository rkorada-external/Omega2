#----------------------------------------------------------------------------
# FUNCTION: SEG_LEG_MIS
#
# Input parameters:
# Author : Ashish Kumar Singh
# Subject: Function that export segmentation results to the MIS schema
# Return 0 if OK, >0 otherwise
#----------------------------------------------------------------------------

SEG_LEG_MIS() {
	SEG_LOG_FUNCTION="SEG_LEG_MIS"

	time_1=`date +%s`; 
	SEG_LOG_DEBUG "Start legacy MIS"

NSTEP=${NJOB}_SEG_LEG_MIS_05
#-----------------------------------------------------------------
LIBEL="Create table BTRAVI..TEMPMIS"
ISQL_BASE="BTRAVI"
ISQL_QRY=${DDDL}/BTRAVI_TEMPMIS.tab
ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
ISQL


NSTEP=${NJOB}_SEG_LEG_MIS_10
#----------------------------------------------------------------------------
LIBEL="INSERT INTO BTRAVI..TEMPMIS"
ISQL_QRY=`CFTMP`
ISQL_BASE=BTRAVI
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
INPUT_TEXT ${ISQL_QRY} <<EOF
USE BTRAVI
go
INSERT
INTO
  TEMPMIS
  (
    SGT_NT,
    SGTRUN_NT,
    SGTVER_NT,
	SEGTYPE_CF
  )
	SELECT DISTINCT
	TS.SGT_NT,
    MAX (TR.SGTRUN_NT) AS SGTRUN_NT,
	TS.SGTVER_NT,
	(SELECT MAX(MSVT.SEGTYPE_CF) from BMIS..MIS_SEGMENT_VERSION_TABLE MSVT WHERE MSVT.SSD_CF = TS.SSD_CF
		AND MSVT.VERSION_NM = convert(varchar, TS.SGT_NT) + '-' + convert(varchar, TS.SGTVER_NT)) as SEGTYPE_CF
	FROM
	 BEST..TSEGMENTATION TS,
	 BSEG..TSEGRUN TR,
	 BEST..TSEGTYPE TT,
	 BSBO..TBOLSTTRT TBO
	WHERE
	 TS.SGT_NT = TR.SGT_NT
	 AND TS.SGTVER_NT  =TR.SGTVER_NT
	 AND TS.SGTTYP_NT = TT.SGTTYP_NT
	 AND TS.SGTGRAN_CT ='2'
	 AND TR.SGTSCOPE_CT ='1'
	 AND TT.SGTMGTLVL_CT = '3'
	 AND TS.BALAI_B =1
	 AND TR.SGTRUNSTS_CT ='5'
	 AND TR.PRDSIT_CF = TBO.PRDSIT_CF 
	 AND TR.SGTSIMU_B=0
	 AND TR.SGTOBSOLETE_B=0
	 AND TBO.TRTNAM_CF   = 'ESEJ2020'
	-- Shouldn't check exact last update date: snapshot runs are re-updated post-process.
	 AND TR.LSTUPD_D     > TBO.TRTDAT_D  
	 AND TBO.PRDSIT_CF   = '${HOST_PRDSIT}'
	GROUP BY
     TS.SGT_NT,
     TS.SGTVER_NT
go
exit
EOF
ISQL


#----------------------------------------------------------------------------
NSTEP=${NJOB}_SEG_LEG_MIS_11
LIBEL="SELECT Segmentation types to update in MIS"
BCP_WAY="OUT"
BCP_VER="+"
BCP_RS=","
BCP_O="$DFILT/${NSTEP}_segtypes.dat"
BCP_QRY="SELECT MSVT.SEGTYPE_CF
	FROM BMIS..MIS_SEGMENT_VERSION_TABLE MSVT,
	  BEST..TSEGMENTATION TS,
	  BTRAVI..tempMis TM
	WHERE
	  MSVT.SSD_CF = TS.SSD_CF
	AND MSVT.VERSION_NM = convert(varchar, TM.SGT_NT) + '-' + convert(varchar, TM.SGTVER_NT)
	AND TS.SGT_NT       = TM.SGT_NT
	AND TS.SGTVER_NT    = TM.SGTVER_NT"
BCP

SEGTYPE_UPDATE_LIST="$(cat $BCP_O 2> /dev/null)"
SEGTYPE_UPDATE_LIST="${SEGTYPE_UPDATE_LIST%,}"


#----------------------------------------------------------------------------
NSTEP=${NJOB}_SEG_LEG_MIS_13
# Remove old temporary files
rm -f "$DFILT/${NSTEP}_${HOST_PRDSIT}_tmp1" "$DFILT/${NSTEP}_${HOST_PRDSIT}_tmp2"
LIBEL="SELECT MAX of Segmentation type from BMIS..MIS_SEGMENT_VERSION_TABLE"
ISQL_O="$DFILT/${NSTEP}_${HOST_PRDSIT}_tmp1"
ISQL_QRY=`CFTMP`
INPUT_TEXT ${ISQL_QRY} <<EOF
	SELECT
		CASE WHEN MAX(SEGTYPE_CF) IS NULL
		THEN
			0
		ELSE
			MAX(SEGTYPE_CF)
	END
	FROM BMIS..MIS_SEGMENT_VERSION_TABLE
go
exit
EOF
ISQL

# Fetch the max SEGTYPE_CF: get ISQL out's 3rd row, delete spaces and truncate to 5 chars
sed -n -e 3p $DFILT/${NSTEP}_${HOST_PRDSIT}_tmp1 | sed '1,$s/ //g' > $DFILT/${NSTEP}_${HOST_PRDSIT}_tmp2
MAX_SEGTYPE_CF=`cat $DFILT/${NSTEP}_${HOST_PRDSIT}_tmp2 | awk '{print substr($0,1,5)}'`

# Remove temporary files
rm -f "$DFILT/${NSTEP}_${HOST_PRDSIT}_tmp1" "$DFILT/${NSTEP}_${HOST_PRDSIT}_tmp2"


#----------------------------------------------------------------------------
if [ -n "$SEGTYPE_UPDATE_LIST" ]
then
	NSTEP=${NJOB}_SEG_LEG_MIS_14
	LIBEL="Delete lines to update in BMIS..MIS_SEGMENT_VERSION_TABLE, BMIS..MIS_SEGMENT_TYPE_TABLE, BMIS..ACT_SEGMENT_XREF_TABLE and BMIS..MIS_SEGMENT_TABLE"
	ISQL_QRY=`CFTMP`
	INPUT_TEXT ${ISQL_QRY} <<EOF
		DELETE FROM BMIS..MIS_SEGMENT_VERSION_TABLE WHERE  SEGTYPE_CF in ($SEGTYPE_UPDATE_LIST)
	go
		DELETE FROM BMIS..MIS_SEGMENT_TYPE_TABLE WHERE  SEGTYPE_CF in ($SEGTYPE_UPDATE_LIST)
	go
		DELETE FROM BMIS..ACT_SEGMENT_XREF_TABLE WHERE  SEGTYPE_CF in ($SEGTYPE_UPDATE_LIST)
	go
		DELETE FROM BMIS..MIS_SEGMENT_TABLE WHERE  SEGTYPE_CF in ($SEGTYPE_UPDATE_LIST)
	go
	exit
EOF
	ISQL
fi

#----------------------------------------------------------------------------
NSTEP=${NJOB}_SEG_LEG_MIS_15
LIBEL="INSERT INTO BMIS..MIS_SEGMENT_VERSION_TABLE"
ISQL_QRY=`CFTMP`
ISQL_BASE=BTRAVI
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
INPUT_TEXT ${ISQL_QRY} <<EOF
USE BTRAVI
go
INSERT
INTO
  BMIS..MIS_SEGMENT_VERSION_TABLE
  (
	SSD_CF,
	SEGTYPE_CF,
	VERSION_NR,
	VERSION_NM,
	LSTUPD_D
  )
	SELECT
	  TS.SSD_CF,
	  CASE WHEN TM.SEGTYPE_CF is null
		  THEN (TM.BASENEWID_NT + $MAX_SEGTYPE_CF)
		  ELSE TM.SEGTYPE_CF
		  END AS SEGTYPE_CF,
	  0 AS VERSION_NR,
	  convert(varchar, TM.SGT_NT) + '-' + convert(varchar, TM.SGTVER_NT) AS VERSION_NM,
	  TR.LSTUPD_D
	FROM
	  BEST..TSEGMENTATION TS,
	  BSEG..TSEGRUN TR,
	  BTRAVI..tempMis TM
	WHERE
	  TS.SGT_NT      = TM.SGT_NT
	AND TS.SGTVER_NT =TM.SGTVER_NT
	AND TR.SGTRUN_NT =TM.SGTRUN_NT
go
exit
EOF
ISQL


#----------------------------------------------------------------------------
NSTEP=${NJOB}_SEG_LEG_MIS_20
LIBEL="INSERT INTO BMIS..MIS_SEGMENT_TYPE_TABLE"
ISQL_QRY=`CFTMP`
ISQL_BASE=BTRAVI
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
INPUT_TEXT ${ISQL_QRY} <<EOF
USE BTRAVI
go
INSERT
INTO
  BMIS..MIS_SEGMENT_TYPE_TABLE
  (
	SSD_CF,
	SEGTYPE_CF,
	SEGTYPE_NM,
	LSTUPD_D
  )
	SELECT
	  TS.SSD_CF,
	  CASE WHEN TM.SEGTYPE_CF is null
		  THEN (TM.BASENEWID_NT + $MAX_SEGTYPE_CF)
		  ELSE TM.SEGTYPE_CF
		  END AS SEGTYPE_CF,
	  TS.SGT_LM ,
	  TR.LSTUPD_D
	FROM
	  BEST..TSEGMENTATION TS,
	  BSEG..TSEGRUN TR,
	  BTRAVI..tempMis TM
	WHERE
	  TS.SGT_NT      = TM.SGT_NT
	AND TS.SGTVER_NT = TM.SGTVER_NT
	AND TR.SGTRUN_NT = TM.SGTRUN_NT
GO
exit
EOF
ISQL


# Iterating over batch plan defined in ESEJ2017.cmd
for run in $RUNS_FOR_MIS ; do

	nameref restabnme_var="RUN_${run}_RESTABNME"

	#-----------------------------------------------------------------------------
	NSTEP=${NJOB}_SEG_LEG_MIS_25_RUN_${run}
	ACT_SEGMENT_XREF_TABLE_O="${DFILT}/${NSTEP}_${IB}_BCP_ACT_SEGMENT_XREF_TABLE_O.dat"
	LIBEL="BCPOUT BMIS..ACT_SEGMENT_XREF_TABLE"
	BCP_WAY="OUT"
	BCP_VER="+"
	BCP_O=$ACT_SEGMENT_XREF_TABLE_O
	BCP_QRY="SELECT
	  TS.SSD_CF,
	  TRES.CTR_NF,
	  TRES.SEC_NF,
	  CASE WHEN TM.SEGTYPE_CF is null
		  THEN (TM.BASENEWID_NT + $MAX_SEGTYPE_CF)
		  ELSE TM.SEGTYPE_CF
		  END AS SEGTYPE_CF,
	  TRES.SGMT_NF,
	  CASE
		WHEN TRES.SGMT_NF > 0
		THEN
		  (
			SELECT
			  convert(char(10),SGMT.SGMT_LS)
			FROM
			  BEST..TSEGMT SGMT
			WHERE
			  SGMT.SGMT_NF     = TRES.SGMT_NF
			AND SGMT.SGT_NT    = TR.SGT_NT
			AND SGMT.SGTVER_NT = TR.SGTVER_NT
		  )
		ELSE
		  (
			SELECT
			  convert(char(10),TB.COLVAL_LS)
			FROM
			  BREF..TBANTECL TB
			WHERE
			  TB.COLVAL_CT = CONVERT(CHAR(5),TRES.SGMT_NF)
			AND TB.COL_LS  = 'SGTBALAITYP_CF'
			AND TB.LAG_CF  = 'E'
		  )
	  END AS SEG_CODE,
	  0   AS VERSION_NR,
	  TR.LSTUPD_D,
	  convert(char(25),TS.SGT_LM) AS SEGTYPE_NM,
	  NULL AS UWY_NF,
	  NULL AS EXCLUWY_SEL
	FROM
	  BEST..TSEGMENTATION TS,
	  BSEG..TSEGRUN TR,
	  ${restabnme_var} TRES,
	  BREF..TBATCHSSD TSSD ,
	  BTRAVI..tempMis  TM
	WHERE
		TR.SGTRUN_NT = $run
	AND TS.SGT_NT         = TM.SGT_NT
	AND TS.SGTVER_NT      = TM.SGTVER_NT
	AND TR.SGTRUN_NT      = TM.SGTRUN_NT
	AND TR.SGT_NT         = TM.SGT_NT
	AND TRES.SSD_CF       = TSSD.SSD_CF
	AND TSSD.BATCHUSER_CF = suser_name()"
	BCP


	if [ -s "$ACT_SEGMENT_XREF_TABLE_O" ] ; then
		NSTEP=${NJOB}_SEG_LEG_MIS_30_RUN_${run}
		#---------------------------------------------------------------
		LIBEL="BCP IN BMIS..ACT_SEGMENT_XREF_TABLE"
		BCP_WAY="IN"; BCP_VER=""
		BCP_I=$ACT_SEGMENT_XREF_TABLE_O
		BCP_TABLE="BMIS..ACT_SEGMENT_XREF_TABLE"
		BCP
	fi


	NSTEP=${NJOB}_SEG_LEG_MIS_35_RUN_${run}
	MIS_SEGMENT_TABLE_O="${DFILT}/${NSTEP}_${IB}_BCP_MIS_SEGMENT_TABLE_O.dat"
	#-----------------------------------------------------------------------------
	LIBEL="BCP OUT BMIS..MIS_SEGMENT_TABLE"
	BCP_WAY="OUT"
	BCP_VER="+"
	BCP_O=$MIS_SEGMENT_TABLE_O
	BCP_QRY="SELECT
		 TS.SSD_CF,
		 TSM.SGMT_NF AS SEG_ID,
		  CASE WHEN TM.SEGTYPE_CF is null
			  THEN (TM.BASENEWID_NT + $MAX_SEGTYPE_CF)
			  ELSE TM.SEGTYPE_CF
			  END AS SEGTYPE_CF,
		 0 AS VERSION_NR,
		 CONVERT(CHAR(10),TSM.SGMT_LS) AS SEG_CODE, 
		 TSM.SGMT_LL AS SEG_NM, '' AS SEG_RECAP, TR.LSTUPD_D
		FROM
			BEST..TSEGMENTATION TS,
			BEST..TSEGMT TSM,
			BSEG..TSEGRUN TR,
			BTRAVI..tempMis TM
		WHERE
			TR.SGTRUN_NT = $run
		AND TS.SGT_NT = TM.SGT_NT
		AND TS.SGTVER_NT = TM.SGTVER_NT
		AND TR.SGTRUN_NT = TM.SGTRUN_NT
		AND TS.SGT_NT = TSM.SGT_NT
		AND TS.SGTVER_NT = TSM.SGTVER_NT
		AND TR.SGT_NT = TS.SGT_NT

	UNION
		SELECT DISTINCT
		  TS.SSD_CF,
		  TRES.SGMT_NF AS SEG_ID,
		  CASE WHEN TM.SEGTYPE_CF is null
		  THEN (TM.BASENEWID_NT + $MAX_SEGTYPE_CF)
		  ELSE TM.SEGTYPE_CF
		  END AS SEGTYPE_CF,
		  0 AS VERSION_NR,
			(SELECT
				CONVERT(CHAR(10),TB.COLVAL_LS)
			FROM
				BREF..TBANTECL TB
			WHERE
				TB.COLVAL_CT = CONVERT(CHAR(5),TRES.SGMT_NF)
			AND TB.COL_LS  = 'SGTBALAITYP_CF'
			AND TB.LAG_CF  = 'E'
			) 	AS SEG_CODE,
			(SELECT
				TB1.COLVAL_LM
			FROM
				BREF..TBANTECL TB1
			WHERE
				TB1.COLVAL_CT = CONVERT(CHAR(5),TRES.SGMT_NF)
			AND TB1.COL_LS  = 'SGTBALAITYP_CF'
			AND TB1.LAG_CF  = 'E'
			) AS SEG_NM,
		'' AS SEG_RECAP,
		TR.LSTUPD_D
		FROM
			BEST..TSEGMENTATION TS,
			BSEG..TSEGRUN TR,
			${restabnme_var} TRES,
			BREF..TBATCHSSD TSSD,
			BTRAVI..tempMis TM
		WHERE
			TR.SGTRUN_NT = $run
		AND TS.SGT_NT         = TM.SGT_NT
		AND TS.SGTVER_NT      = TM.SGTVER_NT
		AND TR.SGTRUN_NT      = TM.SGTRUN_NT
		AND TR.SGT_NT         = TS.SGT_NT
		AND TRES.SSD_CF       = TSSD.SSD_CF
		AND TRES.SGMT_NF      < 1
		AND TRES.SGMT_NF 	  <> -2
		AND TSSD.BATCHUSER_CF = suser_name()"
	BCP

	if [ -s "$MIS_SEGMENT_TABLE_O" ] ; then
		NSTEP=${NJOB}_SEG_LEG_MIS_40_RUN_${run}
		#---------------------------------------------------------------
		LIBEL="BCP IN BMIS..MIS_SEGMENT_TABLE"
		BCP_WAY="IN"; BCP_VER=""
		BCP_I=$MIS_SEGMENT_TABLE_O
		BCP_TABLE="BMIS..MIS_SEGMENT_TABLE"
		BCP
	fi
	
	LIBEL="Deleting temporary MIS export files for run $run"
	RMFIL "$SEGTYPE_NM_O" "$ACT_SEGMENT_XREF_TABLE_O" "$MIS_SEGMENT_TABLE_O"
done


NSTEP=${NJOB}_SEG_LEG_MIS_45
#---------------------------------------------------------------
LIBEL="Drop table BTRAVI..TEMPMIS"
ISQL_QRY=`CFTMP`
ISQL_BASE=BTRAVI
ISQL_O=${DFILT}/${NSTEP}_SEG_LEG_MIS_${IB}_ISQL_O.dat
INPUT_TEXT ${ISQL_QRY} <<EOF
USE BTRAVI
go
IF OBJECT_ID('TEMPMIS') IS NOT NULL
BEGIN
    DROP TABLE TEMPMIS
    IF OBJECT_ID('TEMPMIS') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE TEMPMIS >>>'
    ELSE
        PRINT '<<< DROPPED TABLE TEMPMIS >>>'
END
go
exit
EOF
ISQL



NSTEP=${NJOB}_SEG_LEG_MIS_50
#---------------------------------------------------------------
LIBEL="update BSBO..TBOLSTTRT"
ISQL_QRY=`CFTMP`
ISQL_BASE=BTRAVI
ISQL_O=${DFILT}/${NSTEP}_SEG_LEG_MIS_${IB}_ISQL_O.dat
INPUT_TEXT ${ISQL_QRY} <<EOF
USE BSBO
go
update BSBO..TBOLSTTRT Set Trtdat_D = getDate() where TRTNAM_CF = 'ESEJ2020' and PRDSIT_CF = '${HOST_PRDSIT}'
go
exit
EOF
ISQL
	
	
NSTEP=${NJOB}_SEG_LEG_MIS_55
#-----------------------------------------------------------------
LIBEL="Deleting job temporary files"
RMFIL "${DFILT}/${NJOB}_SEG_LEG_MIS_*_${IB}_*.dat"

	time_2=`date +%s`; 
	SEG_LOG_DEBUG "End of legacy MIS in $(expr $time_2 - $time_1) sec"
return 0
}
