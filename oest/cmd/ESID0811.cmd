#!/bin/ksh
#=========================================================================================
# Application Name      : ESTIMATION - FILE LOADING FROM EST-LIFE ESTIMATION FILE
# SHELL script name     : ESID0811.cmd
# Creation date         : 21/01/2013
# Author                : Ashish Kumar Singh
# description           : Asynchronous Job launched by the TP used to load estimation file
#===============================================================================
# historique des modifications
#   13/06/2017	SA	: [31752] - Add Anomaly check for '10-Abnormality Completion' tagging.
#   04/09/2017	LW	: [MOD_2] - Management of Quarterly Estimates (+rearrangement)
#   27/12/2018	LW	: [MOD_4] - Spira 73959: [Apolo - QE] TLIFESTD - Remove the Field ACCFRQ_CT
#	13/02/2019	LW	: [MOD_5] - REQ.L.02.03: Aggregation problem 
#	13/03/2019	ThD	: [MOD_6] - Spira 73413: Avoid Time out in WS by spliting treatment by contract
#	19/03/2019  LW  : [MOD_3] - Spira 73919: Adjust error codes in BTRAV..EST_ESID0811_PERIMETER relative to the lines of the loaded file
#	19/03/2019	LW	:	[MOD_7] - Spira 73413: Add a control on the webservice output files to check their existence
#   22/03/2019	LW	:	[MOD_8] - Spira 73413: Move the insertions inside the condition which tests the anomaly output file and the TLIFEST output file
#   16/04/2019  ThD     :       [Mod_9]          Spira 77674
#   16/04/2019  ThD     :       [Mod_10]          Spira 77555
#   26/04/2019  MIS	:	Spira 77454 Edit conditions for Warning ano
#   02/05/2019  MIS	:	Spira 77130 Add Step 265
#   09/05/2019  MIS	:	Spira 77454 Edit conditions
#	20/09/2019	L. Wernert	: [78745] - Change the uniqueness key
#	10/04/2020	L. Wernert	:	[82192]	-	Modifications in order to handle the estimate automatic file loading
#   22/07/2020 HR       :       Spira 83914 Apolo - QE: DAC VOBA Computation of NET GROSS AMORTIZATION
#   12/11/2020 S.Behague:spira 87924: APOLO QE : Traitement Failed si estimations trimestrielles et annuelles sur un traité Quaterly
#   13/11/2020 L. Wernert : [88779]	- IFRS17: REQ.LIF.EST02 - Automatic upload of estimates - lot3 
#   08/01/2021 S.Behague:spira 81643: APOLO QE : Propagation des postes de cash à partir des valeurs chargées en Cedent GAAP
#   13/01/2021 B.LAGHA  :spira 85919: Gestion des doublons [MOD_020]
#   03/02/2021 B.LAGHA  :spira 92307: Initialisation de ERRORCODE_CT a null dans BTRAV..EST_ESID0811_PERIMETER (step 70)
#   10/02/2021 B.LAGHA  :spira 67721: Pour des fins d'affichage Les numeros de lignes du fichier a charger commence a ZERO (awk avant step 10)
#   08/03/2021 B.LAGHA  :spira 67721: Corriger le calcul des numeros de lignes 
#   18/05/2021 HR       :spira 96244: Step 250 duplicates issue (step 132)  
#   20/10/2022 S.Behague:spira 105691: NSMind - Generate the movement file in all cases
#=========================================================================================
# set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd
. ${DUTI}/fctws.cmd


#Input parameters
LOADING_MODE=1
USR_CF=${2}
SSD_CF=${3}
ESB_CF=${4}
VISU_MONTH=${5}
VISU_YEAR=${6}
HIGHER_BOUND_YEAR=${7}
LOWER_BOUND_YEAR=${8}
LAG_CF=${9}
FILE_DATE_CRD=${10}
LNCH_DATE_TIME="${11} ${12}"
# [MOD_2]
RUN_DATETIME=`date +"%Y%m%d"`
RUN_MODE="M"


echo $LNCH_DATE_TIME

# Job Initialisation
JOBINIT

# for better show on GUI : 
# Initialize the number of the first line to 0 because PiCTRANO_02_O2 increments it with 1
#-----------------------------------------------------------------------------------------
awk -F "~" 'BEGIN{OFS="~";}{if ($1) {print $1,$2,$3,$7,$8,$9,$10,$11,$12,NR} else {print $4,$5,$6,$7,$8,$9,$10,$11,$12,NR}}' ${DUSERS}/${PCH}ESID0811_${SSD_CF}_${ESB_CF}_${USR_CF}_${FILE_DATE_CRD}.dat > ${DFILT}/${NJOB}_AWK_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat

NSTEP=${NJOB}_10
# Begin SQL
#------------------------------------------------------------------------------
LIBEL="Update the status of the file loading in TLOADEST"
ISQL_BASE="BEST"
ISQL_QRY="execute BEST..PuTLOADEST_04_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}', 1"
ISQL


NSTEP=${NJOB}_20
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Delete work table containing previous movement file BTRAV..EST_ESID0811_PERIMETER"
ISQL_BASE="BTRAV"
ISQL_QRY="delete BTRAV..EST_ESID0811_PERIMETER where USR_CF = '${USR_CF}' and ESB_CF = ${ESB_CF} and SSD_CF = ${SSD_CF}"
ISQL


NSTEP=${NJOB}_30
# Begin shell
#------------------------------------------------------------------------------
LIBEL="Convert input file from DOS to UNIX env"
dos2unix ${DFILT}/${NJOB}_AWK_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat


NSTEP=${NJOB}_40
# Begin sort
#-----------------------------------------------------------------
LIBEL="Sort input file according to contract/section/uwy"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I=${DFILT}/${NJOB}_AWK_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
SORT_O=${DFILT}/${NSTEP}_SORT_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:, SEC_NF 2:1 - 2:EN, UWY_NF 3:1 - 3:EN, ACY_NF 5:1 - 5:EN, NUMLINE_NT 10:1 - 10:EN
/KEYS   CTR_NF, SEC_NF, UWY_NF, ACY_NF, NUMLINE_NT
exit
EOF
SORT

# [MOD_2] - START
NSTEP=${NJOB}_50
# Begin shell
#------------------------------------------------------------------------------
LIBEL="Checking for duplicate row"
cat ${DFILT}/${NJOB}_40_SORT_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat | awk 'x[$1,$2,$3,$4,$5,$7,$8]++' FS="~" | awk 'BEGIN{FS="~"}{print $1"~0~"$2"~1~"'${SSD_CF}'"~L~""'${USR_CF}'""~126~"$10"~"$3"~"$5"~1~""'${ESB_CF}'""~""'${USR_CF}'""~"$8"~"$7;}' > ${DFILT}/${NJOB}_${IB}_TCTRANO_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat

# [MOD_020] - START #
#------------------------------------------------------------------------------
ERRORLine=`awk 'END {print NR}' ${DFILT}/${NJOB}_${IB}_TCTRANO_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat`
JOB_ID='best06a'
if [ ${ERRORLine} -gt 0 ]; then
	NSTEP=${NJOB}_55
	#------------------------------------------------------------------------------
	LIBEL="Delete work table containing previous movement errors file BTRAV..EST_ESID0811_TCTRANO"
	ISQL_BASE="BTRAV"
	ISQL_QRY="delete BTRAV..EST_ESID0811_TCTRANO where USR_CF = '${USR_CF}' and SSD_CF = ${SSD_CF} and ESB_CF = ${ESB_CF}"
	ISQL

	NSTEP=${NJOB}_55A
	#----------------------------------------------------------------------------
	LIBEL="BCP IN BTRAV..EST_ESID0811_TCTRANO: Insert errors detected by the web service estimateLoaderProcess"
	BCP_WAY="IN"; BCP_VER=""
	BCP_I="${DFILT}/${NJOB}_${IB}_TCTRANO_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat"
	BCP_TABLE=BTRAV..EST_ESID0811_TCTRANO
	BCP

	NSTEP=${NJOB}_55B
	#----------------------------------------------------------------------------
	LIBEL="Launch BEST..PiCTRANO_02_O2 to save data in BEST..TCTRANO from data BTRAV..EST_ESID0811_TCTRANO"
	ISQL_BASE="BEST"
	ISQL_QRY="execute BEST..PiCTRANO_02_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}', '${RUN_DATETIME}', '${RUN_MODE}', ''"
	ISQL

	echo 'ERRORLine      = ' ${ERRORLine}
	echo 'JOB_ID         = ' ${JOB_ID}
	echo 'USR_CF         = ' ${USR_CF}
	echo 'LNCH_DATE_TIME = ' ${LNCH_DATE_TIME}

    NSTEP=${NJOB}_55C
	#------------------------------------------------------------------------------
	LIBEL="Error lines detected in BEST..TCTRANO regarding USR_CF and SSD_CF"
	LOGWRITE 1 '!!!! ERRORS detected in table best..TCTRANO  !!!!'
	# Call the Tool box function to set the status to 10-Completed with anomalies	
	MAJOB "${JOB_ID}" "${USR_CF}" "${LNCH_DATE_TIME}"	

	NSTEP=${NJOB}_55D
	#------------------------------------------------------------------------------
	LIBEL="Update the status of the file loading in TLOADEST"
	ISQL_BASE="BEST"
	ISQL_QRY="execute BEST..PuTLOADEST_04_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}', 10"
	ISQL
    
	LIBEL="Erase temporary files"
	#RMFIL "${DFILT}/${NJOB}_*${IB}*.dat"
	#RMFIL ${DUSERS}/${PCH}ESID0811_${SSD_CF}_${ESB_CF}_${USR_CF}_${FILE_DATE_CRD}.dat

	JOBEND
fi
#------------------------------------------------------------------------------
# [MOD_020] - END #


NSTEP=${NJOB}_60
# Begin cut
#------------------------------------------------------------------------------
LIBEL="Generate estimation file perimeter - cut and uniq"
awk '!x[$1,$2,$3,$4,$5,$7,$8]++' FS="~"  ${DFILT}/${NJOB}_40_SORT_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat | cut -d "~" -f1,2,3,4,5,7,8,10 > ${DFILT}/${NSTEP}_UNIQ_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
# [MOD_2] - END


NSTEP=${NJOB}_70
# Begin awk
#------------------------------------------------------------------------------
LIBEL="Format and add empty fields in anticipation of the insertion in BTRAV..EST_ESID0811_PERIMETER"
AWK_I=${DFILT}/${NJOB}_60_UNIQ_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
AWK_O=${DFILT}/${NSTEP}_AWK_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
         {print \$1,\$2,\$3,\$4,\$5,\$8,0,1,${SSD_CF},${ESB_CF},"${USR_CF}",\$7,\$6,0,0,0,0,0,0,0,""}

exit
EOF
AWK


NSTEP=${NJOB}_80
# Begin BCP IN
#------------------------------------------------------------------------------
LIBEL="Import in temporary base the estimation file perimeter BCP IN into BTRAV..EST_ESID0811_PERIMETER"
BCP_WAY="IN"; BCP_VER=""
BCP_TRUNCATE=NO
BCP_I=${DFILT}/${NJOB}_70_AWK_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_TABLE="BTRAV..EST_ESID0811_PERIMETER"
BCP


NSTEP=${NJOB}_90
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="Update ACCADMTYP_CT, RETRO_B in BTRAV..EST_ESID0811_PERIMETER and look for errors"
ISQL_BASE="BTRAV"
ISQL_QRY="execute BEST..PsLIFEST_16_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}', '${RUN_MODE}'"
ISQL


# [MOD_2] - START
NSTEP=${NJOB}_95
#----------------------------------------------------------------------------
LIBEL="Launch BEST..PiCTRANO_02_O2 to save data in BEST..TCTRANO from data BTRAV..EST_ESID0811_TCTRANO"
ISQL_BASE="BEST"
ISQL_QRY="execute BEST..PiCTRANO_02_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}', '${RUN_DATETIME}', '${RUN_MODE}', ''"
ISQL


NSTEP=${NJOB}_100
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Search lines in BEST..TCTRANO regarding USR_CF and SSD_CF"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_SELECT_TCTRANO.log 
ISQL_QRY="select count(*) from BEST..TCTRANO 
          where SSD_CF=${SSD_CF} and SEGTYP_CT='L' and SEG_NF = '${USR_CF}' and NUMLINE_NT != 0 and ANO_CT != 1"
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_FRES_O1.dat         

ISQL_RES

ERRORLine=`cat ${ISQL_FRES} | cut -d_ -f1| sed -e s/\ //g`
JOB_ID='best06a'

echo 'ERRORLine      = ' ${ERRORLine}
echo 'JOB_ID         = ' ${JOB_ID}
echo 'USR_CF         = ' ${USR_CF}
echo 'LNCH_DATE_TIME = ' ${LNCH_DATE_TIME}
 
# If error lines exist in BEST..TCTRANO, create a warning message, update TTASKQUEUE and stop the execution
#----------------------------------------------------------------------------------------------
if [ "${ERRORLine}" != '0' ]  
then
    NSTEP=${NJOB}_110
	#------------------------------------------------------------------------------
	LIBEL="Error lines detected in BEST..TCTRANO regarding USR_CF and SSD_CF"
	LOGWRITE 1 '!!!! ERRORS detected in table best..TCTRANO  !!!!'
	# Call the Tool box function to set the status to 10-Completed with anomalies	
	MAJOB "${JOB_ID}" "${USR_CF}" "${LNCH_DATE_TIME}"	


	NSTEP=${NJOB}_115
	# Begin SQL
	#------------------------------------------------------------------------------
	LIBEL="Update the status of the file loading in TLOADEST"
	ISQL_BASE="BEST"
	ISQL_QRY="execute BEST..PuTLOADEST_04_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}', 10"
	ISQL
    

	LIBEL="Erase temporary files"
	#RMFIL "${DFILT}/${NJOB}_*${IB}*.dat"
	#RMFIL ${DUSERS}/${PCH}ESID0811_${SSD_CF}_${ESB_CF}_${USR_CF}_${FILE_DATE_CRD}.dat

	JOBEND
fi

# [MOD_4] - START
NSTEP=${NJOB}_120
# Begin awk
#------------------------------------------------------------------------------
LIBEL="Format and add empty fields in anticipation of the insertion in BTRAV..EST_ESID0811_TLIFESTQ"
AWK_I=${DFILT}/${NJOB}_40_SORT_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
AWK_O=${DFILT}/${NSTEP}_QUARTERLY_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
         {print \$1,0,\$2,\$3,1,"${RUN_DATETIME}",0,0,\$5,\$8,\$7,\$4,0,0,"${SSD_CF}",\$6,\$9,0,"","${USR_CF}","${RUN_DATETIME}","${USR_CF}","",0,0,0,0,0,0}

exit
EOF
AWK
# [MOD_4] - END

NSTEP=${NJOB}_130
# Begin BCP IN
#------------------------------------------------------------------------------
LIBEL="Import the quarterly file (containing yearly and/or quarterly estimates) in temporary perimeter base: BCP IN into BTRAV..EST_ESID0811_TLIFESTQ"
BCP_WAY="IN"; BCP_VER=""
BCP_TRUNCATE=YES
BCP_I=${DFILT}/${NJOB}_120_QUARTERLY_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_TABLE="BTRAV..EST_ESID0811_TLIFESTQ"
BCP

# [MOD_5] - START
NSTEP=${NJOB}_131
# Begin ISQL
#------------------------------------------------------------------------------
LIBEL="Apply Aggregation rules on quarterly estimates"
ISQL_BASE="BEST"
ISQL_QRY="execute BEST..PiLIFEST_05_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}'"
ISQL
# [MOD_5] - END

#SPIRA 83914 / 96244 now step 255
#NSTEP=${NJOB}_132
# Begin ISQL
#------------------------------------------------------------------------------
#LIBEL="VOBA DAC quarterly estimates"
#ISQL_BASE="BEST"
#ISQL_QRY="execute BEST..PiLIFEST_10"
#ISQL

# [MOD_5] - START
NSTEP=${NJOB}_135
# Begin ISQL
#------------------------------------------------------------------------------
LIBEL="Apply Aggregation rules on quarterly estimates"
ISQL_BASE="BEST"
ISQL_QRY="execute BEST..PiLIFEST_02_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}'"
ISQL
# [MOD_5] - END


NSTEP=${NJOB}_140Bis
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="Extracts yearly loaded estimates out of BTRAV..EST_ESID0811_TLIFESTQ"
BCP_WAY="OUT";
BCP_VER="+";
BCP_O=${DFILT}/${NSTEP}_${IB}_OUTPUT_YEARLY_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_QRY="execute BEST..PsLIFEST_13_O2"
BCP
# [MOD_2] - END


NSTEP=${NJOB}_140
# Begin sort
#-----------------------------------------------------------------
LIBEL="Sort yearly loaded estimates according to contract/section/uwy"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I=${DFILT}/${NJOB}_140Bis_${IB}_OUTPUT_YEARLY_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_OUTPUT_YEARLY_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:, SEC_NF 2:1 - 2:EN, UWY_NF 3:1 - 3:EN, ACY_NF 5:1 - 5:EN, NUMLINE_NT 10:1 - 10:EN
/KEYS   CTR_NF, SEC_NF, UWY_NF, ACY_NF, NUMLINE_NT
exit
EOF
SORT


NSTEP=${NJOB}_150
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="Export estimation grids from file loading perimeter proc 3"
BCP_WAY="OUT";
BCP_VER="+";
BCP_O=${DFILT}/${NSTEP}_${IB}_EXTRACT_LIFE_EST_GRID_PROC_3_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_QRY="execute BEST..PsLIFEST_03_O2 0, 0, 0, 0, ${SSD_CF}, ${ESB_CF}, ${VISU_MONTH}, ${VISU_YEAR}, '${LAG_CF}', '', '${USR_CF}', ${HIGHER_BOUND_YEAR}, ${LOWER_BOUND_YEAR}, ${LOADING_MODE}"
BCP


NSTEP=${NJOB}_160
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="Export estimation grids from file loading perimeter proc 4"
BCP_WAY="OUT";
BCP_VER="+";
BCP_O=${DFILT}/${NSTEP}_${IB}_EXTRACT_LIFE_EST_GRID_PROC_4_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_QRY="execute BEST..PsLIFEST_04_O2 0, 0, 0, 0, ${SSD_CF}, ${ESB_CF}, ${VISU_MONTH}, ${VISU_YEAR}, '${LAG_CF}', '', '${USR_CF}', ${HIGHER_BOUND_YEAR}, ${LOWER_BOUND_YEAR}, ${LOADING_MODE}"
BCP


NSTEP=${NJOB}_170
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="Export ASSUMED estimation general information from file loading perimeter"
BCP_WAY="OUT";
BCP_VER="+";
BCP_O=${DFILT}/${NSTEP}_${IB}_EXTRACT_ASSUMED_EST_GRID_GENERAL_INFO_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_QRY="execute BEST..PsLIFEST_01_O2 0, 0, 0, 0, ${SSD_CF}, ${ESB_CF}, 0, 0, '', '${LAG_CF}', '${USR_CF}', ${LOWER_BOUND_YEAR}, ${HIGHER_BOUND_YEAR}, ${LOADING_MODE}"
BCP


NSTEP=${NJOB}_180
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="Export RETRO estimation general information from file loading perimeter"
BCP_WAY="OUT";
BCP_VER="+";
BCP_O=${DFILT}/${NSTEP}_${IB}_EXTRACT_RETRO_EST_GRID_GENERAL_INFO_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_QRY="execute BEST..PsLIFEST_06_O2 0, 0, 0, 0, ${SSD_CF}, ${ESB_CF}, 0, 0, '', '${LAG_CF}', '${USR_CF}', ${LOWER_BOUND_YEAR}, ${HIGHER_BOUND_YEAR}, ${LOADING_MODE}"
BCP


NSTEP=${NJOB}_190
# Concat GENERAL INFO files
#---------------------------------------------------------------
LIBEL="Concat TLIFEST files"
cat ${DFILT}/${NJOB}_170_${IB}_EXTRACT_ASSUMED_EST_GRID_GENERAL_INFO_${SSD_CF}_${ESB_CF}_${USR_CF}.dat > ${DFILT}/${NSTEP}_${IB}_CONCAT_GENERAL_INFO_EST_GRID_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
cat ${DFILT}/${NJOB}_180_${IB}_EXTRACT_RETRO_EST_GRID_GENERAL_INFO_${SSD_CF}_${ESB_CF}_${USR_CF}.dat >> ${DFILT}/${NSTEP}_${IB}_CONCAT_GENERAL_INFO_EST_GRID_${SSD_CF}_${ESB_CF}_${USR_CF}.dat


NSTEP=${NJOB}_200
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="Export Complete account and auto update information for each estimation grid"
BCP_WAY="OUT";
BCP_VER="+";
BCP_O=${DFILT}/${NSTEP}_${IB}_EXTRACT_RETRO_EST_GRID_COMAC_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_QRY="execute BEST..PsLIFEST_15_O2 0, 0, 0, 0, ${VISU_MONTH}, ${VISU_YEAR}, '', ${SSD_CF}, ${ESB_CF}, '${USR_CF}', ${HIGHER_BOUND_YEAR}, ${LOWER_BOUND_YEAR}, ${LOADING_MODE}"
BCP


NSTEP=${NJOB}_210
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="Export movement files from file loading perimeter"
BCP_WAY="OUT";
BCP_VER="+";
BCP_O=${DFILT}/${NSTEP}_${IB}_EXTRACT_MOVEMENT_FILES_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_QRY="execute BEST..PsLIFMOD2_01_O2 '', 0, ${VISU_YEAR}, ${VISU_MONTH}, null, 0, '${LAG_CF}', '${USR_CF}', ${SSD_CF}, ${ESB_CF} , ${LOADING_MODE}"
BCP


NSTEP=${NJOB}_220
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="Export movement files general information from file loading perimeter"
BCP_WAY="OUT";
BCP_VER="+";
BCP_O=${DFILT}/${NSTEP}_${IB}_EXTRACT_MVMT_GEN_INFO_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_QRY="execute BEST..PsLIFMOD_01_O2 '', null, ${VISU_YEAR}, ${VISU_MONTH}, null, 0, 0, '${USR_CF}', ${SSD_CF}, ${ESB_CF} , ${LOADING_MODE}"
BCP

export CURRENT_DATE=`date '+%d/%m/%Y %H:%M:%S:%SS'`

# [MOD_6] - START
for CTR in `cat ${DFILT}/${NJOB}_140_${IB}_OUTPUT_YEARLY_${SSD_CF}_${ESB_CF}_${USR_CF}.dat |cut -d"~" -f1 |sort -u`
do

touch ${DFILT}/${NJOB}_${IB}_TLIFEST_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
touch ${DFILT}/${NJOB}_${IB}_TLIFMOD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
touch ${DFILT}/${NJOB}_${IB}_TLIFPEN_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
touch ${DFILT}/${NJOB}_${IB}_TLIFMOD2UPD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
touch ${DFILT}/${NJOB}_${IB}_TLIFMOD2INS_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
touch ${DFILT}/${NJOB}_${IB}_TCTRANO_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
touch ${DFILT}/${NJOB}_${IB}_THRESHOLD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat

cat ${DFILT}/${NJOB}_140_${IB}_OUTPUT_YEARLY_${SSD_CF}_${ESB_CF}_${USR_CF}.dat |grep $CTR > ${DFILT}/${NJOB}_140_${IB}_OUTPUT_YEARLY_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
cat ${DFILT}/${NJOB}_150_${IB}_EXTRACT_LIFE_EST_GRID_PROC_3_${SSD_CF}_${ESB_CF}_${USR_CF}.dat |grep $CTR > ${DFILT}/${NJOB}_150_${IB}_EXTRACT_LIFE_EST_GRID_PROC_3_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
cat ${DFILT}/${NJOB}_160_${IB}_EXTRACT_LIFE_EST_GRID_PROC_4_${SSD_CF}_${ESB_CF}_${USR_CF}.dat |grep $CTR > ${DFILT}/${NJOB}_160_${IB}_EXTRACT_LIFE_EST_GRID_PROC_4_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
cat ${DFILT}/${NJOB}_190_${IB}_CONCAT_GENERAL_INFO_EST_GRID_${SSD_CF}_${ESB_CF}_${USR_CF}.dat |grep $CTR > ${DFILT}/${NJOB}_190_${IB}_CONCAT_GENERAL_INFO_EST_GRID_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
cat ${DFILT}/${NJOB}_200_${IB}_EXTRACT_RETRO_EST_GRID_COMAC_${SSD_CF}_${ESB_CF}_${USR_CF}.dat |grep $CTR > ${DFILT}/${NJOB}_200_${IB}_EXTRACT_RETRO_EST_GRID_COMAC_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
cat ${DFILT}/${NJOB}_210_${IB}_EXTRACT_MOVEMENT_FILES_${SSD_CF}_${ESB_CF}_${USR_CF}.dat |grep $CTR > ${DFILT}/${NJOB}_210_${IB}_EXTRACT_MOVEMENT_FILES_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
cat ${DFILT}/${NJOB}_220_${IB}_EXTRACT_MVMT_GEN_INFO_${SSD_CF}_${ESB_CF}_${USR_CF}.dat |grep $CTR > ${DFILT}/${NJOB}_220_${IB}_EXTRACT_MVMT_GEN_INFO_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat

# [MOD_2] - START
NSTEP=${NJOB}_230
#----------------------------------------------------------------------------
LIBEL="Call the web service estimateLoaderProcess for ${CTR}"
WS_BATCH_NAME=estimateLoaderProcess
WS_PARAMS_TEXT << EOF
INPUT_FILE		${DFILT}/${NJOB}_140_${IB}_OUTPUT_YEARLY_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
EST_LIFE_PROC3_FILE     ${DFILT}/${NJOB}_150_${IB}_EXTRACT_LIFE_EST_GRID_PROC_3_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
EST_LIFE_PROC4_FILE     ${DFILT}/${NJOB}_160_${IB}_EXTRACT_LIFE_EST_GRID_PROC_4_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
EST_LIFE_GEN_INFO_FILE  ${DFILT}/${NJOB}_190_${IB}_CONCAT_GENERAL_INFO_EST_GRID_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
EST_LIFE_COMAC_FILE     ${DFILT}/${NJOB}_200_${IB}_EXTRACT_RETRO_EST_GRID_COMAC_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
EST_MOVEMENT_FILE       ${DFILT}/${NJOB}_210_${IB}_EXTRACT_MOVEMENT_FILES_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
EST_MOVEMENT_GEN_INFO_FILE      ${DFILT}/${NJOB}_220_${IB}_EXTRACT_MVMT_GEN_INFO_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
TMP_PIPELINE_DIR        ${DFILT}/
TLIFEST_OUTPUT_FILE     ${DFILT}/${NJOB}_${IB}_TLIFEST_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
TLIFMOD_OUTPUT_FILE     ${DFILT}/${NJOB}_${IB}_TLIFMOD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
TLIFPEN_OUTPUT_FILE  ${DFILT}/${NJOB}_${IB}_TLIFPEN_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
TLIFMOD2UPD_OUTPUT_FILE     ${DFILT}/${NJOB}_${IB}_TLIFMOD2UPD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
TLIFMOD2INS_OUTPUT_FILE       ${DFILT}/${NJOB}_${IB}_TLIFMOD2INS_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
TCTRANO_OUTPUT_FILE      ${DFILT}/${NJOB}_${IB}_TCTRANO_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
THRESHOLD_OUTPUT_FILE    ${DFILT}/${NJOB}_${IB}_THRESHOLD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat
USR_CF          ${USR_CF}
SSD_CF          ${SSD_CF}
ESB_CF          ${ESB_CF}
PRS_CF          569
LAG_CF          ${LAG_CF}
VISU_MONTH      ${VISU_MONTH}
VISU_YEAR       ${VISU_YEAR}
CURRENT_DATE    ${CURRENT_DATE}
FORCETRESHOLD   0
EOF
WS_OUTPUT_FILE=${DFILT}/${NSTEP}_${IB}_${WS_BATCH_NAME}_O_${CTR}.dat
WS_BATCH
# [MOD_2] - END

if [ -s ${DFILT}/${NJOB}_${IB}_TCTRANO_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat ] && [ ! -s ${DFILT}/${NJOB}_${IB}_TLIFEST_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat ]
then
	cat ${DFILT}/${NJOB}_${IB}_TCTRANO_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat >> ${DFILT}/${NJOB}_${IB}_WS_ERROR_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
	cat ${DFILT}/${NJOB}_${IB}_TCTRANO_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat >> ${DFILT}/${NJOB}_${IB}_WS_ERROR_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat

fi

# [MOD_7] - START
# If the ws retrieves an empty anomaly file => cat to get all lines of the processed contracts	
if [ ! -s ${DFILT}/${NJOB}_${IB}_WS_ERROR_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat ]
then
	cat ${DFILT}/${NJOB}_${IB}_TLIFEST_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat >> ${DFILT}/${NJOB}_${IB}_TLIFEST_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
	cat ${DFILT}/${NJOB}_${IB}_TLIFMOD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat >> ${DFILT}/${NJOB}_${IB}_TLIFMOD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
	cat ${DFILT}/${NJOB}_${IB}_TLIFPEN_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat >> ${DFILT}/${NJOB}_${IB}_TLIFPEN_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
	cat ${DFILT}/${NJOB}_${IB}_TLIFMOD2UPD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat >> ${DFILT}/${NJOB}_${IB}_TLIFMOD2UPD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
	cat ${DFILT}/${NJOB}_${IB}_TLIFMOD2INS_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat >> ${DFILT}/${NJOB}_${IB}_TLIFMOD2INS_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
	cat ${DFILT}/${NJOB}_${IB}_THRESHOLD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat >> ${DFILT}/${NJOB}_${IB}_THRESHOLD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
	cat ${DFILT}/${NSTEP}_${IB}_estimateLoaderProcess_O_${CTR}.dat >> ${DFILT}/${NSTEP}_${IB}_estimateLoaderProcess_O.dat
	
	if [ -s ${DFILT}/${NJOB}_${IB}_TCTRANO_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat ]
	then
		echo "WARNING detected"
		cat ${DFILT}/${NJOB}_${IB}_TCTRANO_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat >> ${DFILT}/${NJOB}_${IB}_TCTRANO_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
	else
		echo "No errors detected by the webservice estimateLoaderProcess for the CTR ${CTR}"
	fi

# Else => cat to get all anomalies of the processed contracts
else
	cat ${DFILT}/${NJOB}_${IB}_TCTRANO_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}_${CTR}.dat >> ${DFILT}/${NJOB}_${IB}_TCTRANO_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
	echo "Errors detected by the webservice estimateLoaderProcess for the CTR ${CTR}"
fi
# [MOD_7] - END

done
# [MOD_6] - END

# [MOD_9] - BEG
NSTEP=${NJOB}_235
#----------------------------------------------------------------------------
LIBEL="BCP IN BTRAV..EST_ESID0811_TCTRANO: Insert errors detected by the web service estimateLoaderProcess"
BCP_WAY="IN"; BCP_VER=""
BCP_I="${DFILT}/${NJOB}_${IB}_TCTRANO_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat"
BCP_TABLE=BTRAV..EST_ESID0811_TCTRANO
BCP

# [MOD_3] - START
NSTEP=${NJOB}_240
# Begin SQL
#------------------------------------------------------------------------------
LIBEL="Update the ERRORCODE_CT of BTRAV..EST_ESID0811_PERIMETER"
ISQL_BASE="BEST"
ISQL_QRY="execute BEST..PuTCTRANO_01_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}'"
ISQL
# [MOD_3] - END
# [MOD_9] - END

#NSTEP=${NJOB}_250
#----------------------------------------------------------------------------
#LIBEL="BCP IN BEST...TLIFEST"
#BCP_WAY="IN"; BCP_VER=""
#BCP_I="${DFILT}/${NJOB}_${IB}_TLIFEST_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat"
#BCP_TABLE=BEST..TLIFEST
#BCP

# [MOD_6] - START

if [ -s "${DFILT}/${NJOB}_${IB}_TLIFEST_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat" ] && [ ! -s "${DFILT}/${NJOB}_${IB}_WS_ERROR_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat" ]
then

	NSTEP=${NJOB}_250
	#----------------------------------------------------------------------------
	LIBEL="BCP IN BEST...TLIFEST"
	BCP_WAY="IN"; BCP_VER=""
	BCP_I="${DFILT}/${NJOB}_${IB}_TLIFEST_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat"
	BCP_TABLE=BEST..TLIFEST
	BCP

	# [MOD_6] - END

        #SPIRA 83914
        #SPIRA 96244 NSTEP=${NJOB}_132
        NSTEP=${NJOB}_255
        # Begin ISQL
        #------------------------------------------------------------------------------
        LIBEL="VOBA DAC quarterly estimates"
        ISQL_BASE="BEST"
        ISQL_QRY="execute BEST..PiLIFEST_10"
        ISQL

	# [MOD_2] - START
	NSTEP=${NJOB}_260
	# Begin ISQL
	#------------------------------------------------------------------------------
	LIBEL="Apply Beginning/Ending rules on quarterly estimates"
	ISQL_BASE="BEST"
	ISQL_QRY="execute BEST..PiLIFEST_03_O2"
	ISQL

  NSTEP=${NJOB}_265
  # Begin ISQL
  #------------------------------------------------------------------------------
  LIBEL="Calculate GAAP DIFF"
  ISQL_BASE="BEST"
  ISQL_QRY="execute BEST..PiLIFEST_04_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}'"
  ISQL	

	NSTEP=${NJOB}_270
	# Begin ISQL
	#------------------------------------------------------------------------------
	LIBEL="Complete the quarterly scope with additional data and update TLIFESTD"
	ISQL_BASE="BTRAV"
	ISQL_QRY="execute BEST..PuLIFEST_02_O2"
	ISQL
	# [MOD_2] - END


	NSTEP=${NJOB}_280
	# Begin isql
	#------------------------------------------------------------------------------
	LIBEL="Define new update ID"
	ISQL_BASE="BEST"
	ISQL_QRY="select max(ID_CF) from BEST..TIDLIFEST_CALL"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.log
	ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat 
	ISQL_RES

	MAX_CALL=`cat $ISQL_FRES`
	if [ -z "${MAX_CALL}" ]
	then
		MAX_CALL=0
	fi


	NSTEP=${NJOB}_290
	# Begin isql
	#------------------------------------------------------------------------------
	LIBEL="Define new update ID"
	ISQL_BASE="BEST"
	ISQL_QRY="select max(ID_CF) from BEST..TIDLIFEST_GLOBAL"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.log
	ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat 
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


	NSTEP=${NJOB}_300
	# Begin shell
	#------------------------------------------------------------------------------
	LIBEL="Upload's start and end date definition"
	UPD_D=`cat ${DFILT}/${NJOB}_${IB}_TLIFEST_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat | awk 'NR==1 { print $6 }' FS="~" | awk '{print substr($0, 0, length($0)-2)}'`
	CUPD_D=`date -d "${UPD_D}" "+%Y-%m-%d %r"`
	STR_D=`date -d "${CUPD_D}-1second" "+%Y-%m-%d %r"`
	END_D=`date -d "${CUPD_D}+1second" "+%Y-%m-%d %r"`
	STR_D=`date -d "${STR_D}" "+%b%e %Y %H:%M:%S%p"`
	END_D=`date -d "${END_D}" "+%b%e %Y %H:%M:%S%p"`

	touch ${DFILT}/${NJOB}_${IB}_TIDLIFEST_CALL_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat


	NSTEP=${NJOB}_310
	# Begin shell
	#------------------------------------------------------------------------------
	LIBEL="Generate file for calling table"
	args=(-vv1="${ID_CF}" -vv2="${SSD_CF}" -vv3="${ESB_CF}" -vv4="${USR_CF}" -vv5="${STR_D}" -vv6="${END_D}")
	cat ${DFILT}/${NJOB}_70_AWK_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat | awk "${args[@]}" 'BEGIN{FS="~"}{print v1"~1~"v2"~"v3"~"v4"~"$1"~"$2"~"$3"~0~"v5"~"v6;}' > ${DFILT}/${NJOB}_${IB}_TIDLIFEST_CALL_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat

  # [MOD_2] - START
	NSTEP=${NJOB}_315
	# Begin shell
	#------------------------------------------------------------------------------
	LIBEL="Generate file for calling table with uniq lignes"
	awk '!x[$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11]++' FS="~" ${DFILT}/${NJOB}_${IB}_TIDLIFEST_CALL_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat > ${DFILT}/${NJOB}_${IB}_TIDLIFEST_CALL_OUTPUT_FILE_UNIQ_${SSD_CF}_${ESB_CF}_${USR_CF}.dat


	NSTEP=${NJOB}_320
	# Begin BCP IN
	#------------------------------------------------------------------------------
	LIBEL="BCP IN BEST..TIDLIFEST_CALL"
	BCP_WAY="IN"; BCP_VER=""
	BCP_I="${DFILT}/${NJOB}_${IB}_TIDLIFEST_CALL_OUTPUT_FILE_UNIQ_${SSD_CF}_${ESB_CF}_${USR_CF}.dat"
	BCP_TABLE=BEST..TIDLIFEST_CALL
	BCP
  # [MOD_2] - END

	# [MOD_8] - START
  NSTEP=${NJOB}_330
	#----------------------------------------------------------------------------
	LIBEL="BCP IN BTRAV..EST_ESID0811_TLIFPEN"
	BCP_WAY="IN"; BCP_VER=""
	BCP_TRUNCATE="YES"
	BCP_I="${DFILT}/${NJOB}_${IB}_TLIFPEN_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat"
	BCP_TABLE=BTRAV..EST_ESID0811_TLIFPEN
	BCP


	NSTEP=${NJOB}_340
	#----------------------------------------------------------------------------
	LIBEL="BCP IN BTRAV..EST_ESID0811_TLIFMOD"
	BCP_WAY="IN"; BCP_VER=""
	BCP_TRUNCATE="YES"
	BCP_I="${DFILT}/${NJOB}_${IB}_TLIFMOD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat"
	BCP_TABLE=BTRAV..EST_ESID0811_TLIFMOD
	BCP


	NSTEP=${NJOB}_350
	#----------------------------------------------------------------------------
	LIBEL="BCP IN BTRAV..EST_ESID0811_TLIFMOD2 INSERT"
	BCP_WAY="IN"; BCP_VER=""
	BCP_TRUNCATE="YES"
	BCP_I="${DFILT}/${NJOB}_${IB}_TLIFMOD2INS_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat"
	BCP_TABLE=BTRAV..EST_ESID0811_TLIFMOD2
	BCP


	NSTEP=${NJOB}_360
	#----------------------------------------------------------------------------
	LIBEL="BCP IN BTRAV..EST_ESID0811_TLIFMOD2 UPDATE"
	BCP_WAY="IN"; BCP_VER=""
	#BCP_TRUNCATE="YES"
	BCP_I="${DFILT}/${NJOB}_${IB}_TLIFMOD2UPD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat"
	BCP_TABLE=BTRAV..EST_ESID0811_TLIFMOD2
	BCP


	NSTEP=${NJOB}_370
	#----------------------------------------------------------------------------
	LIBEL="Launch BEST..PuLIFMOD2_02_O2 to save data in BEST..LIFMOD2 from data in BTRAV..EST_ESID0811_TLIFMOD2"
	ISQL_BASE="BEST"
	ISQL_QRY="exec BEST..PuLIFMOD2_02_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}', '${RUN_MODE}'"
	ISQL


	NSTEP=${NJOB}_380
	# Begin isql
	#------------------------------------------------------------------------------
	LIBEL="Delete work table BTRAV..EST_ESID0811_THRESHOLD"
	ISQL_BASE="BTRAV"
	ISQL_QRY="delete BTRAV..EST_ESID0811_THRESHOLD where USR_CF = '${USR_CF}' and ESB_CF = ${ESB_CF} and SSD_CF = ${SSD_CF}"
	ISQL


	NSTEP=${NJOB}_390
	#----------------------------------------------------------------------------
	LIBEL="BCP IN BTRAV..EST_ESID0811_THRESHOLD"
	BCP_WAY="IN"; BCP_VER=""
	BCP_I="${DFILT}/${NJOB}_${IB}_THRESHOLD_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat"
	BCP_TABLE=BTRAV..EST_ESID0811_THRESHOLD
	BCP

fi

NSTEP=${NJOB}_400
#----------------------------------------------------------------------------
LIBEL="Launch BEST..PiCTRANO_02_O2 to save data in BEST..TCTRANO from data BTRAV..EST_ESID0811_TCTRANO"
ISQL_BASE="BEST"
ISQL_QRY="execute BEST..PiCTRANO_02_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}', '${RUN_DATETIME}', '${RUN_MODE}', '${FILENAME}'"
ISQL
# [MOD_8] - END


# [MOD_10]
#NSTEP=${NJOB}_410
# Begin webservice
#----------------------------------------------------------------------------
#LIBEL="Life Estimate Contracts"
#WS_BATCH_NAME=BAT36454
#WS_PARAMS_TEXT << EOF
#USR_CF          ${USR_CF}
#SSD_CF          ${SSD_CF}
#ESB_CF          ${ESB_CF}
#EOF
#WS_OUTPUT_FILE=${DFILT}/${NSTEP}_${IB}_${WS_BATCH_NAME}_O.dat
#WS_BATCH


#-- [31752] 
NSTEP=${NJOB}_420
# Begin isql
#------------------------------------------------------------------------------
LIBEL="research lines in best..TCTRANO to USR_CF and SSD_CF"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_SELECT_TCTRANO.log 
ISQL_QRY="select count(*) from BEST..TCTRANO 
          where SSD_CF=${SSD_CF} and SEGTYP_CT='L' and SEG_NF = '${USR_CF}' and NUMLINE_NT != 0 and ANO_CT != 1"
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_FRES_O1.dat         

ISQL_RES

ERRORLine=`cat ${ISQL_FRES} | cut -d_ -f1| sed -e s/\ //g`
JOB_ID='best06a'

echo 'ERRORLine      = ' ${ERRORLine}
echo 'JOB_ID         = ' ${JOB_ID}
echo 'USR_CF         = ' ${USR_CF}
echo 'LNCH_DATE_TIME = ' ${LNCH_DATE_TIME}
 
# If exists lines into table best..TCTRANO, create a warning message and update TASKQUEUE.
#----------------------------------------------------------------------------------------------
if [ "${ERRORLine}" != '0' ]  
then
    NSTEP=${NJOB}_430
    LOGWRITE 1 '!!!! ERRORS detected in table best..TCTRANO  !!!!'
    # Call the Tool box function to set the status to 10-Completed with Anomaly	
    MAJOB "${JOB_ID}" "${USR_CF}" "${LNCH_DATE_TIME}"	
    STEPWARNING 10
fi


NSTEP=${NJOB}_440
# Begin SQL
#------------------------------------------------------------------------------
LIBEL="Update the status of the file loading in TLOADEST"
ISQL_BASE="BEST"
ISQL_QRY="execute BEST..PuTLOADEST_04_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}', 10"
ISQL


NSTEP=${NJOB}_450
# Erase temporary files
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
#RMFIL "${DFILT}/${NJOB}_*${IB}*.dat"
#RMFIL ${DUSERS}/${PCH}ESID0811_${SSD_CF}_${ESB_CF}_${USR_CF}_${FILE_DATE_CRD}.dat

# [MOD_10]
NSTEP=${NJOB}_460
# Begin webservice
#----------------------------------------------------------------------------
LIBEL="Life Estimate Contracts"
WS_BATCH_NAME=BAT36454
WS_PARAMS_TEXT << EOF
USR_CF          ${USR_CF}
SSD_CF          ${SSD_CF}
ESB_CF          ${ESB_CF}
MODE			${RUN_MODE}
EOF
WS_OUTPUT_FILE=${DFILT}/${NSTEP}_${IB}_${WS_BATCH_NAME}_O.dat
WS_BATCH


JOBEND
