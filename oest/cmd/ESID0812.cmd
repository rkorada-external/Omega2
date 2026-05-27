#!/bin/ksh
#=========================================================================================
# Application Name      : ESTIMATION - FILE LOADING FROM EST-LIFE ESTIMATION FILE
# SHELL script name     : ESID0812.cmd
# Creation date         : 13/03/2014
# Author                : Ashish Kumar Singh
# description           : Asynchronous Job launched by the TP used to load estimation file
#=========================================================================================
# set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd
. ${DUTI}/fctws.cmd

#Input parameters
USR_CF=${1}
SSD_CF=${2}
ESB_CF=${3}
VISU_MONTH=${4}
VISU_YEAR=${5}
HIGHER_BOUND_YEAR=${6}
LOWER_BOUND_YEAR=${7}
LOADING_MODE=${8}
LAG_CF=${9}

# Initialization JOB
JOBINIT

awk -F "~" 'BEGIN{OFS="~";}{if ($1) {print $1,$2,$3,$7,$8,$9,$10,$11,$12,NR} else {print $4,$5,$6,$7,$8,$9,$10,$11,$12,NR}}' ${DUSERS}/${PCH}ESID0811_${SSD_CF}_${ESB_CF}_${USR_CF}.dat > ${DFILT}/${PCH}ESID0811_AWK_${SSD_CF}_${ESB_CF}_${USR_CF}.dat


NSTEP=${NJOB}_15
# Begin isql 
#------------------------------------------------------------------------------
LIBEL="Delete work table containing previous movement file BTRAV..EST_ESID0811_PERIMETER"
ISQL_BASE="BTRAV"
ISQL_QRY="delete BTRAV..EST_ESID0811_PERIMETER where USR_CF = '${USR_CF}' and ESB_CF = ${ESB_CF} and SSD_CF = ${SSD_CF}"
ISQL


#################################################################################
# STEP2 Prepare file and perimeter												#
#################################################################################
NSTEP=${NJOB}_20
# Begin isql 
#------------------------------------------------------------------------------
LIBEL="Convert input file from DOS to UNIX env" 
dos2unix ${DFILT}/${PCH}ESID0811_AWK_${SSD_CF}_${ESB_CF}_${USR_CF}.dat


NSTEP=${NJOB}_25
# Begin sort
#-----------------------------------------------------------------
LIBEL="Sort input file according to contract/section/uwy" 
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I=${DFILT}/${PCH}ESID0811_AWK_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
SORT_O=${DFILT}/${NSTEP}_SORT_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS	CTR_NF 1:1 - 1:9, SEC_NF 2:1 - 2:1, UWY_NF 3:1 - 3:4, ACY_NF 5:1 - 5:4
/KEYS	CTR_NF, SEC_NF, UWY_NF, ACY_NF
exit
EOF
SORT


NSTEP=${NJOB}_30
# Begin cut 
#------------------------------------------------------------------------------
LIBEL="Generate estimation file perimeter - cut and uniq" 
#cut -d '~' -f1,2,3 ${DFILT}/${NJOB}_25_SORT_${SSD_CF}_${ESB_CF}_${USR_CF}.dat | uniq > ${DFILT}/${NSTEP}_UNIQ_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
awk '!x[$1,$2,$3]++' FS="~"  ${DFILT}/${NJOB}_25_SORT_${SSD_CF}_${ESB_CF}_${USR_CF}.dat | cut -d "~" -f1,2,3,10 > ${DFILT}/${NSTEP}_UNIQ_${SSD_CF}_${ESB_CF}_${USR_CF}.dat


NSTEP=${NJOB}_35
# Begin sed 
#------------------------------------------------------------------------------
LIBEL="Complete estimation file perimeter with SSD_CF - ESB_CF - USR_CF"
sed 's/\(.*\)/\1~''0~1~'"${SSD_CF}"'~'"${ESB_CF}"'~'"${USR_CF}"~0~0~3~0~0~0~0~0'/' ${DFILT}/${NJOB}_30_UNIQ_${SSD_CF}_${ESB_CF}_${USR_CF}.dat > ${DFILT}/${NSTEP}_SED_${SSD_CF}_${ESB_CF}_${USR_CF}.dat


NSTEP=${NJOB}_40
# Begin BCP IN 
#------------------------------------------------------------------------------
LIBEL="Import in temporary base the estimation file perimeter BCP IN into BTRAV..EST_ESID0811_PERIMETER"
BCP_WAY="IN"; BCP_VER=""
BCP_TRUNCATE=NO
BCP_I=${DFILT}/${NJOB}_35_SED_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_TABLE="BTRAV..EST_ESID0811_PERIMETER"
BCP


NSTEP=${NJOB}_45
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="Update ACCADMTYP and RETROB of BTRAV..EST_ESID0811_PERIMETER" 
ISQL_BASE="BTRAV"
ISQL_QRY="execute BEST..PsLIFEST_16_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}'"
ISQL


#################################################################################
# STEP3 Extract estimation grid file according to estimation file perimeter             #
#################################################################################
NSTEP=${NJOB}_50
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="Export estimation grids from file loading perimeter proc 3" 
	BCP_WAY="OUT"; 
	BCP_VER="+"; 
	BCP_O=${DFILT}/${NSTEP}_EXTRACT_LIFE_EST_GRID_PROC_3_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
	BCP_QRY="execute BEST..PsLIFEST_03_O2 0, 0, 0, 0, ${SSD_CF}, ${ESB_CF}, ${VISU_MONTH}, ${VISU_YEAR}, '${LAG_CF}', '', '${USR_CF}', ${HIGHER_BOUND_YEAR}, ${LOWER_BOUND_YEAR}, ${LOADING_MODE}"
	BCP


NSTEP=${NJOB}_55
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="Export estimation grids from file loading perimeter proc 4" 
	BCP_WAY="OUT"; 
	BCP_VER="+"; 
	BCP_O=${DFILT}/${NSTEP}_EXTRACT_LIFE_EST_GRID_PROC_4_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
	BCP_QRY="execute BEST..PsLIFEST_04_O2 0, 0, 0, 0, ${SSD_CF}, ${ESB_CF}, ${VISU_MONTH}, ${VISU_YEAR}, '${LAG_CF}', '', '${USR_CF}', ${HIGHER_BOUND_YEAR}, ${LOWER_BOUND_YEAR}, ${LOADING_MODE}"
	BCP	
	

NSTEP=${NJOB}_60
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="Export ASSUMED estimation general information from file loading perimeter" 
	BCP_WAY="OUT"; 
	BCP_VER="+"; 
	BCP_O=${DFILT}/${NSTEP}_EXTRACT_ASSUMED_EST_GRID_GENERAL_INFO_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
	BCP_QRY="execute BEST..PsLIFEST_01_O2 0, 0, 0, 0, ${SSD_CF}, ${ESB_CF}, 0, 0, '', '${LAG_CF}', '${USR_CF}', ${LOWER_BOUND_YEAR}, ${HIGHER_BOUND_YEAR}, ${LOADING_MODE}"
	BCP	
		
NSTEP=${NJOB}_65
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="Export RETRO estimation general information from file loading perimeter" 
	BCP_WAY="OUT"; 
	BCP_VER="+"; 
	BCP_O=${DFILT}/${NSTEP}_EXTRACT_RETRO_EST_GRID_GENERAL_INFO_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
	BCP_QRY="execute BEST..PsLIFEST_06_O2 0, 0, 0, 0, ${SSD_CF}, ${ESB_CF}, 0, 0, '', '${LAG_CF}', '${USR_CF}', ${LOWER_BOUND_YEAR}, ${HIGHER_BOUND_YEAR}, ${LOADING_MODE}"
	BCP	

NSTEP=${NJOB}_70
# Concat GENERAL INFO files
#---------------------------------------------------------------
LIBEL="Concat TLIFEST files"
cat ${DFILT}/${NJOB}_60_EXTRACT_ASSUMED_EST_GRID_GENERAL_INFO_${SSD_CF}_${ESB_CF}_${USR_CF}.dat > ${DFILT}/${NSTEP}_CONCAT_GENERAL_INFO_EST_GRID_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
cat ${DFILT}/${NJOB}_65_EXTRACT_RETRO_EST_GRID_GENERAL_INFO_${SSD_CF}_${ESB_CF}_${USR_CF}.dat >> ${DFILT}/${NSTEP}_CONCAT_GENERAL_INFO_EST_GRID_${SSD_CF}_${ESB_CF}_${USR_CF}.dat	


NSTEP=${NJOB}_75
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="Export Complete account and auto update information for each estimation grid" 
	BCP_WAY="OUT"; 
	BCP_VER="+"; 
	BCP_O=${DFILT}/${NSTEP}_EXTRACT_RETRO_EST_GRID_COMAC_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
	BCP_QRY="execute BEST..PsLIFEST_15_O2 0, 0, 0, 0, ${VISU_MONTH}, ${VISU_YEAR}, '', ${SSD_CF}, ${ESB_CF}, '${USR_CF}', ${HIGHER_BOUND_YEAR}, ${LOWER_BOUND_YEAR}, ${LOADING_MODE}"
	BCP	


NSTEP=${NJOB}_80
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="Export movement files from file loading perimeter" 
	BCP_WAY="OUT"; 
	BCP_VER="+"; 
	BCP_O=${DFILT}/${NSTEP}_EXTRACT_MOVEMENT_FILES_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
	BCP_QRY="execute BEST..PsLIFMOD2_01_O2 '', 0, ${VISU_YEAR}, ${VISU_MONTH}, null, 0, '${LAG_CF}', '${USR_CF}', ${SSD_CF}, ${ESB_CF} , ${LOADING_MODE}" 
	BCP

	
NSTEP=${NJOB}_85
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="Export movement files general information from file loading perimeter" 
	BCP_WAY="OUT"; 
	BCP_VER="+"; 
	BCP_O=${DFILT}/${NSTEP}_EXTRACT_MVMT_GEN_INFO_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
	BCP_QRY="execute BEST..PsLIFMOD_01_O2 '', null, ${VISU_YEAR}, ${VISU_MONTH}, null, 0, 0, '${USR_CF}', ${SSD_CF}, ${ESB_CF} , ${LOADING_MODE}"
	BCP	

JOBEND

