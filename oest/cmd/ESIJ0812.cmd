#!/bin/ksh
#===============================================================================
# Application Name      : ESTIMATION - AUTOMATIC ESTIMATE FILE LOADING
# SHELL script name     : ESIJ0812.cmd
# Creation date         : 26/02/2020
# Author                : L. Wernert
# description           : Estimates handling
#===============================================================================
# Change history
# 10/08/2020 | L. Wernert:	[87213]
# 08/10/2020 | S. Behague:	[90618] - I17-Estimates Interface_Management of File in the folder lifereserving/From
# 13/11/2020 | L. Wernert:	[88779] - IFRS17: REQ.LIF.EST02 - Automatic upload of estimates - lot3
# 12/01/2021 | S.Behague:spira 81643: APOLO QE : Propagation des postes de cash à partir des valeurs chargées en Cedent GAAP
# 16/04/2021 | TDE 91343
# 19/09/2022 | S.Behague:spira 105289: Mind - Error management improvement
# 03/10/2022 | S.Behague:spira 105691: NSMind - Generate the movement file in all cases
# 26/03/2025 | Mr JYP:spira 112434: NSMind : check file format and amount limits
# 05/05/2025 | Mr JYP:spira 112434: NSMind : check file format and amount limits
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd
. ${DUTI}/fctws.cmd


# Job Initialisation
JOBINIT

# Input parameters
#-----------------------------------------------------------------
FILEPATH=$1
USR_CF=$2
SSD_CF=$3
ESB_CF=$4
VISU_MONTH=$5
VISU_YEAR=$6
RUN_MODE=$7
#RUN_DATETIME=$8

		
# Variables
#-----------------------------------------------------------------
LAG_CF="E"
LOADING_MODE=1
RUN_DATETIME=`date +"%Y-%m-%d %H:%M:%S"`
RUN_DATETIME_STR=`date +"%Y%m%d_%H%M%S%3N"`
FILENAME=$(basename $FILEPATH)
FILENAME_WO_EXT=$(echo $FILENAME | cut -d\. -f1)
PROVIDER=$(echo ${FILENAME} | cut -d'_' -f8)
LOWER_BOUND_YEAR=4
HIGHER_BOUND_YEAR=4
export DEFAULT_SQL_LOGIN=${USER}


ECHO_LOG ""
ECHO_LOG "#========================================="
ECHO_LOG "# Processing: ${FILENAME}  ..."
ECHO_LOG "#========================================="
ECHO_LOG ""

NSTEP=${NJOB}_01
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Selection of the largest UPLDNO_NT from BEST..TLOADAUTOEST"
ISQL_BASE="BEST"
ISQL_QRY="select max(UPLDNO_NT) from BEST..TLOADAUTOEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_${RUN_DATETIME_STR}_UPLDNOMAX_NT_ISQL_O.dat
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_${RUN_DATETIME_STR}_UPLDNOMAX_NT_ISQLRES_O.dat
ISQL_RES

UPLDNOMAX_NT=`cat ${ISQL_FRES} | sed -e s/\ //g`


NSTEP=${NJOB}_02
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Select FILENO_NT from BEST..TLOADAUTOEST"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_${RUN_DATETIME_STR}_ISQL_SELECT_FILENO_NT.log 
ISQL_QRY="SELECT FILENO_NT from BEST..TLOADAUTOEST
					WHERE UPLDNO_NT = ${UPLDNOMAX_NT} AND SSD_CF = ${SSD_CF} AND
					ESB_CF = ${ESB_CF} AND FILEUNIXNAME_LL = '${FILENAME}' AND
					CREUSR_CF = '${USR_CF}' AND FILETYPE_NT = 1"
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_${RUN_DATETIME_STR}_FILENO_NT_FRES_O1.dat         
ISQL_RES

FILENO_NT=`cat ${ISQL_FRES} | cut -d_ -f1| sed -e s/\ //g`


NSTEP=${NJOB}_03
# Begin execksh
#---------------------------------------------------------------------------
LIBEL="Copy input file $FILEPATH to ${DFILT}/${FILENAME}"
EXECKSH_MODE=P
EXECKSH "cp ${FILEPATH} ${DFILT}/${FILENAME}"

STEP=${NJOB}_03A
# Begin execksh
#---------------------------------------------------------------------------
LIBEL="Delete input files ${FILEPATH}"
ECHO_LOG "-----------------------------------------------------"
ECHO_LOG "Step $NSTEP $LIBEL"
RMFIL "${FILEPATH}"


NSTEP=${NJOB}_04
# Begin SQL
#----------------------------------------------------------------------------
LIBEL="Update CRE_D in TLOADAUTOEST"
ISQL_BASE="BEST"
ISQL_QRY="execute BEST..PuTLOADAUTOEST_01_O2 ${SSD_CF}, ${ESB_CF}, '${FILENAME}', '${FILENAME}', '${PROVIDER}', '${USR_CF}', ${FILENO_NT}, ${UPLDNOMAX_NT}, 'U'"
ISQL


NSTEP=${NJOB}_05
# Begin awk
#------------------------------------------------------------------------------
LIBEL="Format and add empty fields in anticipation of the insertion in BTRAV..EST_ESIJ0810_PERIMETER"
ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "# Begin of step: $NSTEP $LIBEL : $FILENAME "
AWK_I=${DFILT}/${FILENAME}
AWK_O=${DFILT}/${NSTEP}_${NB_FILE}_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat

awk -v SSD_CF="${SSD_CF}"  -v ESB_CF="${ESB_CF}" -v USR_CF="${USR_CF}" '
BEGIN{ FS="~";
       OFS="~";
	   wrongfields=0 ; 
	   wrongamounts=0;
	   wronglines=0;
     }
{
		newamt = $12;
		if ( NF != 12 ) 
		{ wrongfields = wrongfields + 1 ; 
		  wronglines = wronglines + 1 ;
		  newamt="-999999999999999.998" ;
		}
	
		else if ( !( $12 ~ /^-?[0-9]{1,15}(.[0-9]{1,3})?$/ ) ) 
		{ wrongamounts = wrongamounts + 1 ;
		  wronglines = wronglines + 1 ;
		  newamt="-999999999999999.999" ;
		}

	 print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,newamt,NR,SSD_CF,ESB_CF,USR_CF
}
END{
print "TOTAL_END:" wrongfields ":" wrongamounts ":" wronglines
}
	 
' $AWK_I > $AWK_O
RC=$?
if [ ! $RC -eq 0 ]
then
    ECHO_LOG "Error $RC calling awk  , stop the job here "
	STEPEND $RC
fi 

ECHO_LOG "# End of step  : $NSTEP : return code = $RC "
ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG ""


	 
NSTEP=${NJOB}_07
# check file format
#------------------------------------------------------------------------------
LIBEL="check file format and amounts warnings/errors "
ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "# Begin of step: $NSTEP $LIBEL"
lastline=`tail -1 ${DFILT}/${NJOB}_05_${NB_FILE}_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat | grep "^TOTAL_END:" `
wrongfields=`echo $lastline | cut -d":" -f2 ` 
wrongamounts=`echo $lastline | cut -d":" -f3 ` 
wronglines=`echo $lastline | cut -d":" -f4 ` 

grep -v "^TOTAL_END:" ${DFILT}/${NJOB}_05_${NB_FILE}_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat > ${DFILT}/${NJOB}_07_${NB_FILE}_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
wc -l ${DFILT}/${NJOB}_07_${NB_FILE}_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
	
if [ $wrongfields -eq 0 ] && [ $wrongamounts -eq 0 ]
then
  ECHO_LOG "FILE accepted : amounts and fields have the correct format  "
else 
  ECHO_LOG "ERROR DETECTED : $wrongamounts wrong amounts not numeric(18,3) :  $wrongfields wrong lines without 12 fields : total $wronglines wrong lines   "
  ECHO_LOG "ERROR DETECTED : continue loading the file with value -999999999999999.999 , to be rejected later  "  
fi 

ECHO_LOG "# End of step  : $NSTEP "
ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG ""


NSTEP=${NJOB}_10
# Begin BCP IN
#------------------------------------------------------------------------------
LIBEL="Import the input file into the perimeter table: BTRAV..EST_ESIJ0810_PERIMETER"
BCP_WAY="IN"; BCP_VER=""
BCP_TRUNCATE=YES
BCP_I=${DFILT}/${NJOB}_07_${NB_FILE}_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_TABLE="BTRAV..EST_ESIJ0810_PERIMETER"
BCP


NSTEP=${NJOB}_20
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="Format controls on the input file"
BCP_WAY="OUT";
BCP_VER="+";
BCP_O=${DFILT}/${NSTEP}_FORMAT_ANO_FILE_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_QRY="execute BEST..PsLIFEST_18_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}', ${FILENO_NT}"
BCP


# Job stopped if any error
if [ -s ${DFILT}/${NSTEP}_FORMAT_ANO_FILE_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat ]
then
	NSTEP=${NJOB}_30
	#----------------------------------------------------------------------------
	LIBEL="BCP IN BTRAV..EST_ESID0811_TCTRANO: Insert format errors detected"
	BCP_WAY="IN"; BCP_VER=""
	BCP_TRUNCATE="YES"
	BCP_I="${DFILT}/${NJOB}_20_FORMAT_ANO_FILE_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat"
	BCP_TABLE="BTRAV..EST_ESID0811_TCTRANO"
	BCP
	
	
	NSTEP=${NJOB}_40
	#----------------------------------------------------------------------------
	LIBEL="Launch BEST..PiCTRANO_02_O2 to save data in BEST..TCTRANO / BEST..TANOUPLD"
	ISQL_BASE="BEST"
	ISQL_QRY="execute BEST..PiCTRANO_02_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}', '${RUN_DATETIME}', '${RUN_MODE}', '${FILENAME}', ${FILENO_NT}"
	ISQL
	

	NSTEP=${NJOB}_45
	# Begin SQL
	#----------------------------------------------------------------------------
	LIBEL="Update of the file status: 10"
	ISQL_BASE="BEST"
	ISQL_QRY="execute BEST..PuTLOADAUTOEST_01_O2 ${SSD_CF}, ${ESB_CF}, '${FILENAME}', '${FILENAME}', '${PROVIDER}', '${USR_CF}', ${FILENO_NT}, ${UPLDNOMAX_NT}, 'U', 10"
	ISQL

	NSTEP=${NJOB}_50
	# Erase temporary files
	#-----------------------------------------------------------------------------
	LIBEL="Erase temporary files"
	RMFIL "${DFILT}/${NJOB}_*${IB}*.dat"
	
	STEP=${NJOB}_55
	# Begin execksh
	#---------------------------------------------------------------------------
	LIBEL="Delete input files ${FILEPATH}"
	ECHO_LOG "-----------------------------------------------------"
	ECHO_LOG "Step $NSTEP $LIBEL"
	RMFIL "${FILEPATH}"
	
	JOBEND
fi


NSTEP=${NJOB}_50
# ------------------------------------
LIBEL="BCP OUT of BTRAV..EST_ESIJ0810_PERIMETER"
BCP_WAY="OUT"; BCP_VER="+";BCP_SPECIAL_OPT=""
BCP_O=${DFILT}/${NSTEP}_FULL_PERIMETER_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_QRY="SELECT * FROM BTRAV..EST_ESIJ0810_PERIMETER order by NUMLINE_NT ASC"
BCP


NSTEP=${NJOB}_60
# Begin sort
# ------------------------------------
LIBEL="Format conversion from full perimeter (12) to perimeter (10)"   
awk -F "~" 'BEGIN{OFS="~";}{if ($1) {print $1,$2,$3,$7,$8,$9,$10,$11,$12,NR} else {print $4,$5,$6,$7,$8,$9,$10,$11,$12,NR}}' ${DFILT}/${NJOB}_50_FULL_PERIMETER_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat > ${DFILT}/${NSTEP}_AWK_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat


NSTEP=${NJOB}_70
# Begin sort
#-----------------------------------------------------------------
LIBEL="Sort input file according to contract/section/uwy"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I=${DFILT}/${NJOB}_60_AWK_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
SORT_O=${DFILT}/${NSTEP}_SORT_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}_${RUN_DATETIME_STR}.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:, SEC_NF 2:1 - 2:EN, UWY_NF 3:1 - 3:EN, ACY_NF 5:1 - 5:EN, NUMLINE_NT 10:1 - 10:EN
/KEYS   CTR_NF, SEC_NF, UWY_NF, ACY_NF, NUMLINE_NT
exit
EOF
SORT


NSTEP=${NJOB}_80
# Begin shell
#------------------------------------------------------------------------------
LIBEL="Checking for duplicate row"
cat ${DFILT}/${NJOB}_70_SORT_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}_${RUN_DATETIME_STR}.dat | awk 'x[$1,$2,$3,$4,$5,$7,$8]++' FS="~" | awk 'BEGIN{FS="~"}{print $1"~0~"$2"~1~"'${SSD_CF}'"~L~""'${USR_CF}'""~126~"$10"~"$3"~"$5"~1~""'${ESB_CF}'""~""'${USR_CF}'""~"$8"~"$7;}' > ${DFILT}/${NJOB}_${IB}_TANOUPLD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${RUN_DATETIME_STR}.dat


NSTEP=${NJOB}_90
# Begin cut
#------------------------------------------------------------------------------
LIBEL="Generate estimation file perimeter - cut and uniq"
awk '!x[$1,$2,$3,$5,$7,$8]++' FS="~"  ${DFILT}/${NJOB}_70_SORT_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}_${RUN_DATETIME_STR}.dat | cut -d "~" -f1,2,3,4,5,7,8,10 > ${DFILT}/${NSTEP}_UNIQ_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat


NSTEP=${NJOB}_100
# Begin awk
#------------------------------------------------------------------------------
LIBEL="Format and add empty fields in anticipation of the insertion in BTRAV..EST_ESID0811_PERIMETER"
AWK_I=${DFILT}/${NJOB}_90_UNIQ_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
AWK_O=${DFILT}/${NSTEP}_AWK_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
         {print \$1,\$2,\$3,\$4,\$5,\$8,0,1,${SSD_CF},${ESB_CF},"${USR_CF}",\$7,\$6,0,0,3,0,0,0,0,""}

exit
EOF
AWK


NSTEP=${NJOB}_120
# Begin BCP IN
#------------------------------------------------------------------------------
LIBEL="BCP IN into BTRAV..EST_ESID0811_PERIMETER"
BCP_WAY="IN"; BCP_VER=""
BCP_TRUNCATE=YES
BCP_I=${DFILT}/${NJOB}_100_AWK_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_TABLE="BTRAV..EST_ESID0811_PERIMETER"
BCP


NSTEP=${NJOB}_130
#------------------------------------------------------------------------------
LIBEL="Update ACCADMTYP_CT, RETRO_B in BTRAV..EST_ESID0811_PERIMETER and look for errors"
ISQL_BASE="BTRAV"
ISQL_QRY="execute BEST..PsLIFEST_16_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}', '${RUN_MODE}'"
ISQL


NSTEP=${NJOB}_140
#----------------------------------------------------------------------------
LIBEL="Launch BEST..PiCTRANO_02_O2 to save data in BEST..TANOUPLD from data BTRAV..EST_ESID0811_TCTRANO"
ISQL_BASE="BEST"
ISQL_QRY="execute BEST..PiCTRANO_02_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}', '${RUN_DATETIME}', '${RUN_MODE}', '${FILENAME}', ${FILENO_NT}"
ISQL


NSTEP=${NJOB}_150
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Search lines in BEST..TANOUPLD"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_${RUN_DATETIME_STR}_ISQL_SELECT_TANOUPLD.log 
ISQL_QRY="SELECT count(*) from BEST..TANOUPLD 
					WHERE FILEID_CF = 
						(SELECT MAX(FILEID_CF) from BEST..TANOUPLD 
						WHERE SEGTYP_CT ='L' AND 
						SEG_NF = '${USR_CF}' AND
						FILENAME_LL = '${FILENAME}' AND
						CRE_D = '${RUN_DATETIME}')"
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_${RUN_DATETIME_STR}_FRES_O1.dat         

ISQL_RES

ERRORS=`cat ${ISQL_FRES} | cut -d_ -f1| sed -e s/\ //g`


# If error lines exist in BEST..TANOUPLD, display a warning message and stop the execution
#----------------------------------------------------------------------------------------------
if [ "${ERRORS}" != '0' ]  
then
	ECHO_LOG "# Errors			=  ${ERRORS}"
	ECHO_LOG "# USR_CF         	=  ${USR_CF}"
	ECHO_LOG "# FILENAME        =  ${FILENAME}"
	ECHO_LOG "# LNCH_DATE_TIME 	=  ${RUN_DATETIME}"


	NSTEP=${NJOB}_155
	# Begin SQL
	#----------------------------------------------------------------------------
	LIBEL="Update of the file status: 10"
	ISQL_BASE="BEST"
	ISQL_QRY="execute BEST..PuTLOADAUTOEST_01_O2 ${SSD_CF}, ${ESB_CF}, '${FILENAME}', '${FILENAME}', '${PROVIDER}', '${USR_CF}', ${FILENO_NT}, ${UPLDNOMAX_NT}, 'U', 10"
	ISQL


	NSTEP=${NJOB}_160
	# Erase temporary files
	#------------------------------------------------------------------------------
	LIBEL="Erase temporary files"
	RMFIL "${DFILT}/${NJOB}_*${IB}*.dat"

	NSTEP=${NJOB}_165
	# Begin execksh
	#---------------------------------------------------------------------------
	LIBEL="Delete input files ${FILEPATH}"
	ECHO_LOG "-----------------------------------------------------"
	ECHO_LOG "Step $NSTEP $LIBEL"	
	RMFIL "${FILEPATH}"
	
	JOBEND
fi


NSTEP=${NJOB}_170
# Begin awk
#------------------------------------------------------------------------------
LIBEL="Format and add empty fields in anticipation of the insertion in BTRAV..EST_ESID0811_TLIFESTQ"
AWK_I=${DFILT}/${NJOB}_70_SORT_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}_${RUN_DATETIME_STR}.dat
AWK_O=${DFILT}/${NSTEP}_QUARTERLY_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
         {print \$1,0,\$2,\$3,1,"${RUN_DATETIME}",0,0,\$5,\$8,\$7,\$4,0,0,"${SSD_CF}",\$6,\$9,0,"","${USR_CF}","${RUN_DATETIME}","${USR_CF}","",0,0,0,0,0,0}

exit
EOF
AWK


NSTEP=${NJOB}_180
# Begin BCP IN
#------------------------------------------------------------------------------
LIBEL="Import the quarterly file (containing yearly and/or quarterly estimates) in temporary perimeter base: BCP IN into BTRAV..EST_ESID0811_TLIFESTQ"
BCP_WAY="IN"; BCP_VER=""
BCP_TRUNCATE=YES
BCP_I=${DFILT}/${NJOB}_170_QUARTERLY_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_TABLE="BTRAV..EST_ESID0811_TLIFESTQ"
BCP

# [81643] - START
NSTEP=${NJOB}_185
# Begin ISQL
#------------------------------------------------------------------------------
LIBEL="Apply Aggregation rules on quarterly estimates"
ISQL_BASE="BEST"
ISQL_QRY="execute BEST..PiLIFEST_05_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}'"
ISQL
# [81643] - END

NSTEP=${NJOB}_190
# Begin ISQL
#------------------------------------------------------------------------------
LIBEL="Apply Aggregation rules on quarterly estimates"
ISQL_BASE="BEST"
ISQL_QRY="execute BEST..PiLIFEST_02_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}'"
ISQL



NSTEP=${NJOB}_200
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="Extracts yearly loaded estimates out of BTRAV..EST_ESID0811_TLIFESTQ"
BCP_WAY="OUT";
BCP_VER="+";
BCP_O=${DFILT}/${NSTEP}_OUTPUT_YEARLY_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_QRY="execute BEST..PsLIFEST_13_O2"
BCP



NSTEP=${NJOB}_210
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="Export estimation grids from file loading perimeter proc 3"
BCP_WAY="OUT";
BCP_VER="+";
BCP_O=${DFILT}/${NSTEP}_${IB}_EXTRACT_LIFE_EST_GRID_PROC_3_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_QRY="execute BEST..PsLIFEST_03_O2 0, 0, 0, 0, ${SSD_CF}, ${ESB_CF}, ${VISU_MONTH}, ${VISU_YEAR}, '${LAG_CF}', '', '${USR_CF}', ${HIGHER_BOUND_YEAR}, ${LOWER_BOUND_YEAR}, ${LOADING_MODE}"
BCP


NSTEP=${NJOB}_220
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="Export estimation grids from file loading perimeter proc 4"
BCP_WAY="OUT";
BCP_VER="+";
BCP_O=${DFILT}/${NSTEP}_${IB}_EXTRACT_LIFE_EST_GRID_PROC_4_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_QRY="execute BEST..PsLIFEST_04_O2 0, 0, 0, 0, ${SSD_CF}, ${ESB_CF}, ${VISU_MONTH}, ${VISU_YEAR}, '${LAG_CF}', '', '${USR_CF}', ${HIGHER_BOUND_YEAR}, ${LOWER_BOUND_YEAR}, ${LOADING_MODE}"
BCP


NSTEP=${NJOB}_230
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="Export ASSUMED estimation general information from file loading perimeter"
BCP_WAY="OUT";
BCP_VER="+";
BCP_O=${DFILT}/${NSTEP}_${IB}_EXTRACT_ASSUMED_EST_GRID_GENERAL_INFO_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_QRY="execute BEST..PsLIFEST_01_O2 0, 0, 0, 0, ${SSD_CF}, ${ESB_CF}, 0, 0, '', '${LAG_CF}', '${USR_CF}', ${LOWER_BOUND_YEAR}, ${HIGHER_BOUND_YEAR}, ${LOADING_MODE}"
BCP


NSTEP=${NJOB}_240
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="Export RETRO estimation general information from file loading perimeter"
BCP_WAY="OUT";
BCP_VER="+";
BCP_O=${DFILT}/${NSTEP}_${IB}_EXTRACT_RETRO_EST_GRID_GENERAL_INFO_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_QRY="execute BEST..PsLIFEST_06_O2 0, 0, 0, 0, ${SSD_CF}, ${ESB_CF}, 0, 0, '', '${LAG_CF}', '${USR_CF}', ${LOWER_BOUND_YEAR}, ${HIGHER_BOUND_YEAR}, ${LOADING_MODE}"
BCP


NSTEP=${NJOB}_250
# Concat GENERAL INFO files
#---------------------------------------------------------------
LIBEL="Concat TLIFEST files"
cat ${DFILT}/${NJOB}_230_${IB}_EXTRACT_ASSUMED_EST_GRID_GENERAL_INFO_${SSD_CF}_${ESB_CF}_${USR_CF}.dat > ${DFILT}/${NSTEP}_${IB}_CONCAT_GENERAL_INFO_EST_GRID_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
cat ${DFILT}/${NJOB}_240_${IB}_EXTRACT_RETRO_EST_GRID_GENERAL_INFO_${SSD_CF}_${ESB_CF}_${USR_CF}.dat >> ${DFILT}/${NSTEP}_${IB}_CONCAT_GENERAL_INFO_EST_GRID_${SSD_CF}_${ESB_CF}_${USR_CF}.dat


NSTEP=${NJOB}_260
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="Export Complete account and auto update information for each estimation grid"
BCP_WAY="OUT";
BCP_VER="+";
BCP_O=${DFILT}/${NSTEP}_${IB}_EXTRACT_RETRO_EST_GRID_COMAC_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_QRY="execute BEST..PsLIFEST_15_O2 0, 0, 0, 0, ${VISU_MONTH}, ${VISU_YEAR}, '', ${SSD_CF}, ${ESB_CF}, '${USR_CF}', ${HIGHER_BOUND_YEAR}, ${LOWER_BOUND_YEAR}, ${LOADING_MODE}"
BCP


NSTEP=${NJOB}_270
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="Export movement files from file loading perimeter"
BCP_WAY="OUT";
BCP_VER="+";
BCP_O=${DFILT}/${NSTEP}_${IB}_EXTRACT_MOVEMENT_FILES_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_QRY="execute BEST..PsLIFMOD2_01_O2 '', 0, ${VISU_YEAR}, ${VISU_MONTH}, null, 0, '${LAG_CF}', '${USR_CF}', ${SSD_CF}, ${ESB_CF} , ${LOADING_MODE}"
BCP


NSTEP=${NJOB}_280
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="Export movement files general information from file loading perimeter"
BCP_WAY="OUT";
BCP_VER="+";
BCP_O=${DFILT}/${NSTEP}_${IB}_EXTRACT_MVMT_GEN_INFO_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_QRY="execute BEST..PsLIFMOD_01_O2 '', null, ${VISU_YEAR}, ${VISU_MONTH}, null, 0, 0, '${USR_CF}', ${SSD_CF}, ${ESB_CF} , ${LOADING_MODE}"
BCP

export CURRENT_DATE=`date '+%d/%m/%Y %H:%M:%S:%SS'`


for CTR in `cat ${DFILT}/${NJOB}_200_OUTPUT_YEARLY_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat |cut -d"~" -f1 |sort -u`
do
	touch ${DFILT}/${NJOB}_${IB}_TLIFEST_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat
	touch ${DFILT}/${NJOB}_${IB}_TLIFMOD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat
	touch ${DFILT}/${NJOB}_${IB}_TLIFPEN_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat
	touch ${DFILT}/${NJOB}_${IB}_TLIFMOD2UPD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat
	touch ${DFILT}/${NJOB}_${IB}_TLIFMOD2INS_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat
	touch ${DFILT}/${NJOB}_${IB}_TANOUPLD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat
	touch ${DFILT}/${NJOB}_${IB}_THRESHOLD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat

	cat ${DFILT}/${NJOB}_200_OUTPUT_YEARLY_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat |grep $CTR > ${DFILT}/${NJOB}_200_OUTPUT_YEARLY_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
	cat ${DFILT}/${NJOB}_210_${IB}_EXTRACT_LIFE_EST_GRID_PROC_3_${SSD_CF}_${ESB_CF}_${USR_CF}.dat |grep $CTR > ${DFILT}/${NJOB}_210_${IB}_EXTRACT_LIFE_EST_GRID_PROC_3_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
	cat ${DFILT}/${NJOB}_220_${IB}_EXTRACT_LIFE_EST_GRID_PROC_4_${SSD_CF}_${ESB_CF}_${USR_CF}.dat |grep $CTR > ${DFILT}/${NJOB}_220_${IB}_EXTRACT_LIFE_EST_GRID_PROC_4_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
	cat ${DFILT}/${NJOB}_250_${IB}_CONCAT_GENERAL_INFO_EST_GRID_${SSD_CF}_${ESB_CF}_${USR_CF}.dat |grep $CTR > ${DFILT}/${NJOB}_250_${IB}_CONCAT_GENERAL_INFO_EST_GRID_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
	cat ${DFILT}/${NJOB}_260_${IB}_EXTRACT_RETRO_EST_GRID_COMAC_${SSD_CF}_${ESB_CF}_${USR_CF}.dat |grep $CTR > ${DFILT}/${NJOB}_260_${IB}_EXTRACT_RETRO_EST_GRID_COMAC_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
	cat ${DFILT}/${NJOB}_270_${IB}_EXTRACT_MOVEMENT_FILES_${SSD_CF}_${ESB_CF}_${USR_CF}.dat |grep $CTR > ${DFILT}/${NJOB}_270_${IB}_EXTRACT_MOVEMENT_FILES_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
	cat ${DFILT}/${NJOB}_280_${IB}_EXTRACT_MVMT_GEN_INFO_${SSD_CF}_${ESB_CF}_${USR_CF}.dat |grep $CTR > ${DFILT}/${NJOB}_280_${IB}_EXTRACT_MVMT_GEN_INFO_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat


	NSTEP=${NJOB}_290
	#----------------------------------------------------------------------------
	LIBEL="Call the web service estimateLoaderProcess for ${CTR}"
	WS_BATCH_NAME=estimateLoaderProcess
WS_PARAMS_TEXT << EOF
INPUT_FILE		${DFILT}/${NJOB}_200_OUTPUT_YEARLY_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
EST_LIFE_PROC3_FILE     ${DFILT}/${NJOB}_210_${IB}_EXTRACT_LIFE_EST_GRID_PROC_3_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
EST_LIFE_PROC4_FILE     ${DFILT}/${NJOB}_220_${IB}_EXTRACT_LIFE_EST_GRID_PROC_4_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
EST_LIFE_GEN_INFO_FILE  ${DFILT}/${NJOB}_250_${IB}_CONCAT_GENERAL_INFO_EST_GRID_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
EST_LIFE_COMAC_FILE     ${DFILT}/${NJOB}_260_${IB}_EXTRACT_RETRO_EST_GRID_COMAC_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
EST_MOVEMENT_FILE       ${DFILT}/${NJOB}_270_${IB}_EXTRACT_MOVEMENT_FILES_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
EST_MOVEMENT_GEN_INFO_FILE      ${DFILT}/${NJOB}_280_${IB}_EXTRACT_MVMT_GEN_INFO_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
TMP_PIPELINE_DIR        ${DFILT}/
TLIFEST_OUTPUT_FILE     ${DFILT}/${NJOB}_${IB}_TLIFEST_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat
TLIFMOD_OUTPUT_FILE     ${DFILT}/${NJOB}_${IB}_TLIFMOD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat
TLIFPEN_OUTPUT_FILE  ${DFILT}/${NJOB}_${IB}_TLIFPEN_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat
TLIFMOD2UPD_OUTPUT_FILE     ${DFILT}/${NJOB}_${IB}_TLIFMOD2UPD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat
TLIFMOD2INS_OUTPUT_FILE       ${DFILT}/${NJOB}_${IB}_TLIFMOD2INS_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat
TCTRANO_OUTPUT_FILE      ${DFILT}/${NJOB}_${IB}_TANOUPLD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat
THRESHOLD_OUTPUT_FILE    ${DFILT}/${NJOB}_${IB}_THRESHOLD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat
USR_CF          ${USR_CF}
SSD_CF          ${SSD_CF}
ESB_CF          ${ESB_CF}
PRS_CF          569
LAG_CF          ${LAG_CF}
VISU_MONTH      ${VISU_MONTH}
VISU_YEAR       ${VISU_YEAR}
CURRENT_DATE    ${CURRENT_DATE}
FORCETRESHOLD   1
EOF
	WS_OUTPUT_FILE=${DFILT}/${NSTEP}_${IB}_${WS_BATCH_NAME}_O_${CTR}_${RUN_DATETIME_STR}.dat
	WS_BATCH


	if [ -s ${DFILT}/${NJOB}_${IB}_TANOUPLD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat ] && [ ! -s ${DFILT}/${NJOB}_${IB}_TLIFEST_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat ]
	then
		cat ${DFILT}/${NJOB}_${IB}_TANOUPLD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat >> ${DFILT}/${NJOB}_${IB}_WS_ERROR_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${RUN_DATETIME_STR}.dat
		cat ${DFILT}/${NJOB}_${IB}_TANOUPLD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat >> ${DFILT}/${NJOB}_${IB}_WS_ERROR_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat
	fi


	# If the ws retrieves an empty anomaly file => cat to get all lines of the processed contracts	
	if [ ! -s ${DFILT}/${NJOB}_${IB}_WS_ERROR_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat ]
	then
		cat ${DFILT}/${NJOB}_${IB}_TLIFEST_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat >> ${DFILT}/${NJOB}_${IB}_TLIFEST_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${RUN_DATETIME_STR}.dat
		cat ${DFILT}/${NJOB}_${IB}_TLIFMOD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat >> ${DFILT}/${NJOB}_${IB}_TLIFMOD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${RUN_DATETIME_STR}.dat
		cat ${DFILT}/${NJOB}_${IB}_TLIFPEN_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat >> ${DFILT}/${NJOB}_${IB}_TLIFPEN_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${RUN_DATETIME_STR}.dat
		cat ${DFILT}/${NJOB}_${IB}_TLIFMOD2UPD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat >> ${DFILT}/${NJOB}_${IB}_TLIFMOD2UPD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${RUN_DATETIME_STR}.dat
		cat ${DFILT}/${NJOB}_${IB}_TLIFMOD2INS_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat >> ${DFILT}/${NJOB}_${IB}_TLIFMOD2INS_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${RUN_DATETIME_STR}.dat
		cat ${DFILT}/${NJOB}_${IB}_THRESHOLD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat >> ${DFILT}/${NJOB}_${IB}_THRESHOLD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${RUN_DATETIME_STR}.dat
		cat ${DFILT}/${NSTEP}_${IB}_estimateLoaderProcess_O_${CTR}_${RUN_DATETIME_STR}.dat >> ${DFILT}/${NSTEP}_${IB}_estimateLoaderProcess_O.dat
		
		if [ -s ${DFILT}/${NJOB}_${IB}_TANOUPLD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat ]
		then
			ECHO_LOG "# WEB SERVICE: warning(s) detected for the CTR ${CTR}"
			cat ${DFILT}/${NJOB}_${IB}_TANOUPLD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat >> ${DFILT}/${NJOB}_${IB}_TANOUPLD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${RUN_DATETIME_STR}.dat
		else
			ECHO_LOG "# WEB SERVICE: No errors detected for the CTR ${CTR}"
		fi
	else
		cat ${DFILT}/${NJOB}_${IB}_TANOUPLD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}_${RUN_DATETIME_STR}.dat >> ${DFILT}/${NJOB}_${IB}_TANOUPLD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${RUN_DATETIME_STR}.dat
		ECHO_LOG "# WEB SERVICE: Errors detected for the CTR ${CTR}"
	fi
done


NSTEP=${NJOB}_295
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Delete previous treatments from BTRAV..EST_ESID0811_TCTRANO"
ISQL_BASE="BTRAV"
ISQL_QRY="delete BTRAV..EST_ESID0811_TCTRANO where SEG_NF = '${USR_CF}' and ESB_CF = ${ESB_CF} and SSD_CF = ${SSD_CF}"
ISQL


NSTEP=${NJOB}_300
#----------------------------------------------------------------------------
LIBEL="BCP IN BTRAV..EST_ESID0811_TCTRANO: Insert errors detected by the web service estimateLoaderProcess"
BCP_WAY="IN"; BCP_VER=""
BCP_I="${DFILT}/${NJOB}_${IB}_TANOUPLD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${RUN_DATETIME_STR}.dat"
BCP_TABLE=BTRAV..EST_ESID0811_TCTRANO
BCP


NSTEP=${NJOB}_310
# Begin SQL
#------------------------------------------------------------------------------
LIBEL="Update the ERRORCODE_CT of BTRAV..EST_ESID0811_PERIMETER"
ISQL_BASE="BEST"
ISQL_QRY="execute BEST..PuTCTRANO_01_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}'"
ISQL


if [ -s "${DFILT}/${NJOB}_${IB}_TLIFEST_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${RUN_DATETIME_STR}.dat" ] && [ ! -s "${DFILT}/${NJOB}_${IB}_WS_ERROR_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${RUN_DATETIME_STR}.dat" ]
then

	NSTEP=${NJOB}_315
	# Begin awk
	#------------------------------------------------------------------------------
	LIBEL="Change ORICOD_LS for TLIFEST output file"
	AWK_I=${DFILT}/${NJOB}_${IB}_TLIFEST_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${RUN_DATETIME_STR}.dat
	AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_TLIFEST_AUTO_${SSD_CF}_${ESB_CF}_${USR_CF}_${RUN_DATETIME_STR}.dat
	AWK_CMD=`CFTMP`
	INPUT_TEXT ${AWK_CMD} <<EOF
	BEGIN{ FS="\~"; OFS="\~" }
		{print \$1,\$2,\$3,\$4,\$5,\$6,\$7,\$8,\$9,\$10,\$11,\$12,\$13,\$14,\$15,\$16,\$17,\$18,"AutoLoadESIJ0810",\$20,\$21,\$22,\$23,\$24,\$25,\$26,\$27,\$28,\$29}
	exit
EOF
AWK


	NSTEP=${NJOB}_320
	#----------------------------------------------------------------------------
	LIBEL="BCP IN BEST...TLIFEST"
	BCP_WAY="IN"; BCP_VER=""
	BCP_I="${DFILT}/${NJOB}_315_${IB}_AWK_TLIFEST_AUTO_${SSD_CF}_${ESB_CF}_${USR_CF}_${RUN_DATETIME_STR}.dat"
	BCP_TABLE=BEST..TLIFEST
	BCP


	NSTEP=${NJOB}_330
	# Begin ISQL
	#------------------------------------------------------------------------------
	LIBEL="Apply Beginning/Ending rules on quarterly estimates"
	ISQL_BASE="BEST"
	ISQL_QRY="execute BEST..PiLIFEST_03_O2"
	ISQL


	NSTEP=${NJOB}_340
  # Begin ISQL
  #------------------------------------------------------------------------------
  LIBEL="Calculate GAAP DIFF"
  ISQL_BASE="BEST"
  ISQL_QRY="execute BEST..PiLIFEST_04_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}'"
  ISQL	

	NSTEP=${NJOB}_350
	# Begin ISQL
	#------------------------------------------------------------------------------
	LIBEL="Complete the quarterly scope with additional data and update TLIFESTD"
	ISQL_BASE="BTRAV"
	ISQL_QRY="execute BEST..PuLIFEST_02_O2 '${RUN_MODE}'"
	ISQL


	NSTEP=${NJOB}_360
	# Begin isql
	#------------------------------------------------------------------------------
	LIBEL="Define new update ID"
	ISQL_BASE="BEST"
	ISQL_QRY="select max(ID_CF) from BEST..TIDLIFEST_CALL"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.log
	ISQL_FRES=${DFILT}/${NSTEP}_${IB}_${RUN_DATETIME_STR}_ISQLRES_O.dat 
	ISQL_RES

	MAX_CALL=`cat $ISQL_FRES`
	if [ -z "${MAX_CALL}" ]
	then
		MAX_CALL=0
	fi


	NSTEP=${NJOB}_370
	# Begin isql
	#------------------------------------------------------------------------------
	LIBEL="Define new update ID"
	ISQL_BASE="BEST"
	ISQL_QRY="select max(ID_CF) from BEST..TIDLIFEST_GLOBAL"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_${RUN_DATETIME_STR}_ISQL_O.log
	ISQL_FRES=${DFILT}/${NSTEP}_${IB}_${RUN_DATETIME_STR}_ISQLRES_O.dat 
	ISQL_RES

	MAX_GLOBAL=`cat $ISQL_FRES`
	if [ -z "${MAX_GLOBAL}" ]
	then
		MAX_GLOBAL=0
	fi

	if [ ${MAX_CALL} -gt ${MAX_GLOBAL} ]
	then
		ID_CF=$((${MAX_CALL} + 1))
	else
		ID_CF=$((${MAX_GLOBAL} + 1))
	fi


	NSTEP=${NJOB}_380
	# Begin shell
	#------------------------------------------------------------------------------
	LIBEL="Upload's start and end date definition"
	UPD_D=`cat ${DFILT}/${NJOB}_${IB}_TLIFEST_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${RUN_DATETIME_STR}.dat | awk 'NR==1 { print $6 }' FS="~" | awk '{print substr($0, 0, length($0)-2)}'`
	CUPD_D=`date -d "${UPD_D}" "+%Y-%m-%d %r"`
	STR_D=`date -d "${CUPD_D}-1second" "+%Y-%m-%d %r"`
	END_D=`date -d "${CUPD_D}+1second" "+%Y-%m-%d %r"`
	STR_D=`date -d "${STR_D}" "+%b%e %Y %H:%M:%S%p"`
	END_D=`date -d "${END_D}" "+%b%e %Y %H:%M:%S%p"`

	touch ${DFILT}/${NJOB}_${IB}_TIDLIFEST_CALL_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat


	NSTEP=${NJOB}_390
	# Begin shell
	#------------------------------------------------------------------------------
	LIBEL="Generate file for calling table"
	args=(-vv1="${ID_CF}" -vv2="${SSD_CF}" -vv3="${ESB_CF}" -vv4="${USR_CF}" -vv5="${STR_D}" -vv6="${END_D}")
	cat ${DFILT}/${NJOB}_100_AWK_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat | awk "${args[@]}" 'BEGIN{FS="~"}{print v1"~1~"v2"~"v3"~"v4"~"$1"~"$2"~"$3"~0~"v5"~"v6;}' > ${DFILT}/${NJOB}_${IB}_TIDLIFEST_CALL_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat


	NSTEP=${NJOB}_400
	# Begin shell
	#------------------------------------------------------------------------------
	LIBEL="Generate file for calling table with uniq lignes"
	awk '!x[$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11]++' FS="~" ${DFILT}/${NJOB}_${IB}_TIDLIFEST_CALL_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat > ${DFILT}/${NJOB}_${IB}_TIDLIFEST_CALL_OUTPUT_FILE_UNIQ_${SSD_CF}_${ESB_CF}_${USR_CF}.dat


	NSTEP=${NJOB}_410
	# Begin BCP IN
	#------------------------------------------------------------------------------
	LIBEL="BCP IN BEST..TIDLIFEST_CALL"
	BCP_WAY="IN"; BCP_VER=""
	BCP_I="${DFILT}/${NJOB}_${IB}_TIDLIFEST_CALL_OUTPUT_FILE_UNIQ_${SSD_CF}_${ESB_CF}_${USR_CF}.dat"
	BCP_TABLE=BEST..TIDLIFEST_CALL
	BCP


  NSTEP=${NJOB}_420
	#----------------------------------------------------------------------------
	LIBEL="BCP IN BTRAV..EST_ESID0811_TLIFPEN"
	BCP_WAY="IN"; BCP_VER=""
	BCP_TRUNCATE="YES"
	BCP_I="${DFILT}/${NJOB}_${IB}_TLIFPEN_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${RUN_DATETIME_STR}.dat"
	BCP_TABLE=BTRAV..EST_ESID0811_TLIFPEN
	BCP
	
	
	NSTEP=${NJOB}_425
	# Begin awk
	#------------------------------------------------------------------------------
	LIBEL="Change ORICOD_LS for TLIFMOD output file"
	AWK_I=${DFILT}/${NJOB}_${IB}_TLIFMOD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${RUN_DATETIME_STR}.dat
	AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_TLIFMOD_AUTO_${SSD_CF}_${ESB_CF}_${USR_CF}_${RUN_DATETIME_STR}.dat
	AWK_CMD=`CFTMP`
	INPUT_TEXT ${AWK_CMD} <<EOF
	BEGIN{ FS="\~"; OFS="\~" }
		{print \$1,\$2,\$3,\$4,\$5,\$6,\$7,\$8,\$9,\$10,\$11,"AutoLoadESIJ0810",\$13,\$14,\$15,\$16,\$17,\$18,\$19}
	exit
EOF
AWK


	NSTEP=${NJOB}_430
	#----------------------------------------------------------------------------
	LIBEL="BCP IN BTRAV..EST_ESID0811_TLIFMOD"
	BCP_WAY="IN"; BCP_VER=""
	BCP_TRUNCATE="YES"
	BCP_I="${DFILT}/${NJOB}_425_${IB}_AWK_TLIFMOD_AUTO_${SSD_CF}_${ESB_CF}_${USR_CF}_${RUN_DATETIME_STR}.dat"
	BCP_TABLE=BTRAV..EST_ESID0811_TLIFMOD
	BCP


	NSTEP=${NJOB}_440
	#----------------------------------------------------------------------------
	LIBEL="BCP IN BTRAV..EST_ESID0811_TLIFMOD2 INSERT"
	BCP_WAY="IN"; BCP_VER=""
	BCP_TRUNCATE="YES"
	BCP_I="${DFILT}/${NJOB}_${IB}_TLIFMOD2INS_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${RUN_DATETIME_STR}.dat"
	BCP_TABLE=BTRAV..EST_ESID0811_TLIFMOD2
	BCP


	NSTEP=${NJOB}_450
	#----------------------------------------------------------------------------
	LIBEL="BCP IN BTRAV..EST_ESID0811_TLIFMOD2 UPDATE"
	BCP_WAY="IN"; BCP_VER=""
	BCP_I="${DFILT}/${NJOB}_${IB}_TLIFMOD2UPD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat"
	BCP_TABLE=BTRAV..EST_ESID0811_TLIFMOD2
	BCP


	NSTEP=${NJOB}_460
	#----------------------------------------------------------------------------
	LIBEL="Launch BEST..PuLIFMOD2_02_O2 to save data in BEST..LIFMOD2 from data in BTRAV..EST_ESID0811_TLIFMOD2"
	ISQL_BASE="BEST"
	ISQL_QRY="exec BEST..PuLIFMOD2_02_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}', '${RUN_MODE}'"
	ISQL


	NSTEP=${NJOB}_465
	#----------------------------------------------------------------------------
	LIBEL="BCP IN BTRAV..EST_ESID0811_THRESHOLD"
	BCP_WAY="IN"; BCP_VER=""
	BCP_TRUNCATE=YES
	BCP_I="${DFILT}/${NJOB}_${IB}_THRESHOLD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${RUN_DATETIME_STR}.dat"
	BCP_TABLE=BTRAV..EST_ESID0811_THRESHOLD
	BCP

fi


NSTEP=${NJOB}_470
#----------------------------------------------------------------------------
LIBEL="Launch BEST..PiCTRANO_02_O2 to save data in BEST..TANOUPLD from data BTRAV..EST_ESID0811_TCTRANO"
ISQL_BASE="BEST"
ISQL_QRY="execute BEST..PiCTRANO_02_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}', '${RUN_DATETIME}', '${RUN_MODE}', '${FILENAME}', ${FILENO_NT}"
ISQL


NSTEP=${NJOB}_480
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Search lines in BEST..TANOUPLD"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_${RUN_DATETIME_STR}_ISQL_SELECT_TANOUPLD.log 
ISQL_QRY="SELECT count(*) from BEST..TANOUPLD 
					WHERE FILEID_CF = 
						(SELECT MAX(FILEID_CF) from BEST..TANOUPLD 
						WHERE SEGTYP_CT ='L' AND 
						SEG_NF = '${USR_CF}' AND
						FILENAME_LL = '${FILENAME}' AND
						CRE_D = '${RUN_DATETIME}')"
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_${RUN_DATETIME_STR}_FRES_O1.dat         

ISQL_RES

ERRORS=`cat ${ISQL_FRES} | cut -d_ -f1| sed -e s/\ //g`


# If error lines exist in BEST..TANOUPLD, display a warning message and stop the execution
#----------------------------------------------------------------------------------------------
if [ "${ERRORS}" != '0' ]  
then
	ECHO_LOG "# Errors			=  ${ERRORS}"
	ECHO_LOG "# USR_CF         	=  ${USR_CF}"
	ECHO_LOG "# FILENAME        =  ${FILENAME}"
	ECHO_LOG "# LNCH_DATE_TIME 	=  ${RUN_DATETIME}"


	NSTEP=${NJOB}_490
	# Begin SQL
	#---------------------------------------------------------------------------
	LIBEL="Update of the file status: 10"
	ISQL_BASE="BEST"
	ISQL_QRY="execute BEST..PuTLOADAUTOEST_01_O2 ${SSD_CF}, ${ESB_CF}, '${FILENAME}', '${FILENAME}', '${PROVIDER}', '${USR_CF}', ${FILENO_NT}, ${UPLDNOMAX_NT}, 'U', 10"
	ISQL

	NSTEP=${NJOB}_495
	# Begin execksh
	ECHO_LOG "-----------------------------------------------------"
	LIBEL="Delete input files ${FILEPATH} "
	ECHO_LOG "Step $NSTEP $LIBEL"
	RMFIL "${FILEPATH}"
	
	
	NSTEP=${NJOB}_500
	# Erase temporary files
	#---------------------------------------------------------------------------
	LIBEL="Erase temporary files"
	ECHO_LOG "-----------------------------------------------------"
	LIBEL="Delete input files"
	RMFIL "${DFILT}/${NJOB}_*${IB}*.dat"
	

	JOBEND
fi


NSTEP=${NJOB}_485
# Begin webservice
#----------------------------------------------------------------------------
LIBEL="Check thresholds"
WS_BATCH_NAME=BAT36454
WS_PARAMS_TEXT << EOF
USR_CF          ${USR_CF}
SSD_CF          ${SSD_CF}
ESB_CF          ${ESB_CF}
MODE						${RUN_MODE}
EOF
WS_OUTPUT_FILE=${DFILT}/${NSTEP}_${IB}_${WS_BATCH_NAME}_${RUN_DATETIME_STR}_O.dat
WS_BATCH


NSTEP=${NJOB}_490
# Begin SQL
#----------------------------------------------------------------------------
LIBEL="Update of the file status: 2"
ISQL_BASE="BEST"
ISQL_QRY="execute BEST..PuTLOADAUTOEST_01_O2 ${SSD_CF}, ${ESB_CF}, '${FILENAME}', '${FILENAME}', '${PROVIDER}', '${USR_CF}', ${FILENO_NT}, ${UPLDNOMAX_NT}, 'U', 2"
ISQL


NSTEP=${NJOB}_500
# Begin execksh
#---------------------------------------------------------------------------
LIBEL="Delete input files $FILEPATH "
ECHO_LOG "-----------------------------------------------------"
ECHO_LOG "Step $NSTEP $LIBEL"
RMFIL "${FILEPATH}"


NSTEP=${NJOB}_510
# Erase temporary files
#---------------------------------------------------------------------------
LIBEL="Erase temporary files"
ECHO_LOG "-----------------------------------------------------"
ECHO_LOG "Step $NSTEP $LIBEL"
RMFIL "${DFILT}/${NJOB}_*${IB}*.dat"


JOBEND
