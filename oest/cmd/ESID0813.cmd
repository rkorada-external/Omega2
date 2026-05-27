#! /bin/ksh
#============================================================================================
# Application Name         : ESTIMATION - FILE LOADING FROM EST-LIFE ESTIMATION FILE
# SHELL script name        : ESID0813.cmd
# Creation date            : 10/03/2014
# Author                   : Ashish Kumar Singh 
# description              : Asynchronous Job launched by the TP used to load estimation file
#============================================================================================
# trace UNIX
###############################################
# Do not modify                               #
# TMP_PIPELINE_DIR        ${DFILT}/temp/      #
#                                             #
###############################################
# set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctws.cmd

# Get input parameters
USR_CF=$1
SSD_CF=$2
ESB_CF=$3
VISU_MONTH=${4}
VISU_YEAR=${5}
HIGHER_BOUND_YEAR=${6}
LOWER_BOUND_YEAR=${7}
LOADING_MODE=${8}
LAG_CF=${9}

# Job Initialisation
JOBINIT

export CURRENT_DATE=`date '+%d/%m/%Y %H:%M:%S:%SS'`


NSTEP=${NJOB}_05
#----------------------------------------------------------------------------
LIBEL="Estimate File Loading"
WS_BATCH_NAME=estimateLoaderProcess
WS_PARAMS_TEXT << EOF
INPUT_FILE      ${DFILT}/${NCHAIN}_ESID0812_25_SORT_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
EST_LIFE_PROC3_FILE	${DFILT}/${NCHAIN}_ESID0812_50_EXTRACT_LIFE_EST_GRID_PROC_3_${SSD_CF}_${ESB_CF}_${USR_CF}.dat	
EST_LIFE_PROC4_FILE	${DFILT}/${NCHAIN}_ESID0812_55_EXTRACT_LIFE_EST_GRID_PROC_4_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
EST_LIFE_GEN_INFO_FILE	${DFILT}/${NCHAIN}_ESID0812_70_CONCAT_GENERAL_INFO_EST_GRID_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
EST_LIFE_COMAC_FILE	${DFILT}/${NCHAIN}_ESID0812_75_EXTRACT_RETRO_EST_GRID_COMAC_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
EST_MOVEMENT_FILE	${DFILT}/${NCHAIN}_ESID0812_80_EXTRACT_MOVEMENT_FILES_${SSD_CF}_${ESB_CF}_${USR_CF}.dat	
EST_MOVEMENT_GEN_INFO_FILE	${DFILT}/${NCHAIN}_ESID0812_85_EXTRACT_MVMT_GEN_INFO_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
TMP_PIPELINE_DIR	${DFILT}/temp/${SSD_CF}_${ESB_CF}_${USR_CF}
USR_CF		${USR_CF}
SSD_CF		${SSD_CF}
ESB_CF		${ESB_CF}
PRS_CF		569
LAG_CF	 	${LAG_CF}	
VISU_MONTH	${VISU_MONTH}
VISU_YEAR	${VISU_YEAR}
CURRENT_DATE	${CURRENT_DATE}	
EOF
WS_OUTPUT_FILE=${DFILT}/${NSTEP}_${IB}_${WS_BATCH_NAME}_O.dat
WS_BATCH


NSTEP=${NJOB}_10
# Begin rm
#-----------------------------------------------------------------
LIBEL="Deleting job temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_${WS_BATCH_NAME}_O.dat"


# END of JOB
JOBEND

