#!/bin/ksh
#=========================================================================================
# Application Name      : ESTIMATION - AUTOMATIC ESTIMATE FILE LOADING
# SHELL script name     : ESIJ0810.cmd
# Creation date         : 22/02/2020
# Author                : L. Wernert
# description           : ESTIMATION - AUTOMATIC FILE LOADING
#===============================================================================
# Change history
# 10/08/2020 | L. Wernert:	[87213] - Automatic upload of estimates - lot2
# 27/06/2022 | S. Behague:	spira:105289: Mind - Error management improvement
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# CHAIN initialization
CHAININIT $0 $1

export CHAINSTOP_ON_JOBABORT="NO"

# Entry parameters
set -x
TEST_MAIL=$2
set +x

# Est. parameters
# ------------------------------------
set `GETPRM ${EST_PARAM}`
set -x
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
set +x

# Variable initialization
set -x
RUN_MODE="A"
EMPTY_DIR="N"
#RUN_DATETIME=`date +"%Y%m%d%H%M%S"`
set +x


# Number of files to process
NB_FILE=$(find ${LIF_RES_FR} -maxdepth 1 \( -name "*ESIJ0810*.dat" -o -name "*ESIJ0810*.zip" -o -name "*ESIJ0810*.txt" \) | wc -l)

#=========================================
# Check if there are files to process
#=========================================
if [ $NB_FILE -gt 0 ]
then
	#=========================================
	# ESIJ0811: Retrieving and preparing files
	#=========================================
	NJOB="ESIJ0811"
	${DCMD}/ESIJ0811.cmd ${LIF_RES_FR} ${LIF_RES_FRSV} 2>&1 | ${TEE}


	#=========================================
	# ESIJ0812: Life estimates processing 
	#=========================================
	# Counter
	NB_FILE=0
	for FILE in `ls -tr ${LIF_RES_FR}/*ESIJ0810*.dat`; do
		# Checking the existence of the file
		[ -e "$FILE" ] || continue
		
		FILENAME=$(basename $FILE)

		SSD_CF=$(echo ${FILENAME} | cut -d'_' -f4)
		ESB_CF=$(echo ${FILENAME} | cut -d'_' -f5)
		USR_CF=$(echo ${FILENAME} | cut -d'_' -f6 | tr '[:lower:]' '[:upper:]')
		
		NJOB="ESIJ0812"
		${DCMD}/ESIJ0812.cmd ${FILE} ${USR_CF} ${SSD_CF} ${ESB_CF} ${BALSHTMTH_NF} ${BALSHTYEA_NF} ${RUN_MODE} 2>&1 | ${TEE}
		if [ "$?" -ne "0" ]; then
			ECHO_LOG ""
			ECHO_LOG "#========================================="
			ECHO_LOG "# ERROR: Technical problem occured during estimate treatment of the file: ${FILENAME}"
			ECHO_LOG "#========================================="
			ECHO_LOG ""
			break
		fi

		((NB_FILE++))
	done

	ECHO_LOG ""
	ECHO_LOG "#========================================="
	ECHO_LOG "# Processed file(s): ${NB_FILE}"
	ECHO_LOG "#========================================="
	ECHO_LOG ""
else
	ECHO_LOG ""
	ECHO_LOG "#========================================="
	ECHO_LOG "# INFO: No file(s) to process"
	ECHO_LOG "#========================================="
	ECHO_LOG ""
	
	EMPTY_DIR="Y"
fi


#=========================================
# Reporting
#=========================================
# Launch applicative job ESIJ0813
# Callback and mails
NJOB="ESIJ0813"
${DCMD}/ESIJ0813.cmd ${LIF_RES_FR} ${LIF_RES_TO} ${EMPTY_DIR} ${TEST_MAIL} 2>&1 | ${TEE}


CHAINEND
