#!/bin/ksh
#===============================================================================
# Application Name      : ESTIMATION - AUTOMATIC FILE LOADING
# SHELL script name     : ESIJ0811.cmd
# Creation date         : 24/02/2020
# Author                : L. Wernert
# description           : Preparing files (save, retrieve)
#===============================================================================
# Change history
# 27/07/2020 | L. Wernert:	[87623]	- File name of back-up in lifereseving/fromsave
# 10/08/2020 | L. Wernert:	[87213] - Automatic upload of estimates - lot2
# 04/12/2020 | L. Wernert:	[91288] - I17: Tech - Feeding of field "File_LL" of table BEST..TLOADAUTOEST
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Initialise JOB
JOBINIT

# Entry parameters
set -x
LIF_RES_FR=$1
LIF_RES_FRSV=$2
set +x

# Variables
DATETIME_SVG=`date +"%Y%m%d%H%M%S"`


#-----------------------------------------------------------------
# Unzip file(s)
#-----------------------------------------------------------------
for ZIP_FILE in ${LIF_RES_FR}/*ESIJ0810*.zip; do
	[ -e "$ZIP_FILE" ] || continue
	ECHO_LOG ""
	ECHO_LOG "#========================================="
	ECHO_LOG "# Unzipping archives"
	unzip -d ${LIF_RES_FR} $ZIP_FILE
	ECHO_LOG "#========================================="
	RMFIL "$ZIP_FILE"
	ECHO_LOG ""
done


# Set the globbing 
FILES=(`ls -tr ${LIF_RES_FR}/*ESIJ0810*.@(dat|txt)`)


NSTEP=${NJOB}_10
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Selection of the max UPLDNO_NT + 1 from BEST..TLOADAUTOEST"
ISQL_BASE="BEST"
ISQL_QRY="select max(UPLDNO_NT) + 1 from BEST..TLOADAUTOEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_MAXUPLDNO_ISQL_O.dat
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_MAXUPLDNO_ISQLRES_O.dat
ISQL_RES

UPLDNOMAX_NT=`cat ${ISQL_FRES} | sed -e s/\ //g`
if [ "$UPLDNOMAX_NT" -eq NULL ]; then UPLDNOMAX_NT=1; fi


NSTEP=${NJOB}_20
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Selection of the largest FILENO_NT from BEST..TLOADAUTOEST"
ISQL_BASE="BEST"
ISQL_QRY="select max(FILENO_NT) from BEST..TLOADAUTOEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_MAXFILENO_NT_ISQL_O.dat
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_MAXFILENO_NT_ISQLRES_O.dat
ISQL_RES

FILENOMAX_NT=`cat ${ISQL_FRES} | sed -e s/\ //g`
if [ "$FILENOMAX_NT" -eq NULL ]; then FILENOMAX_NT=0; fi


#-----------------------------------------------------------------
# Zip file to LIF_RES_FRSV 
# Begin upload tracking
#-----------------------------------------------------------------
for FILE in "${FILES[@]}"; do
	[ -e "$FILE" ] || continue
	
	# Unix conversion
	dos2unix ${FILE}

	# Checking if the file is not empty
	if [ ! -s "$FILE" ]
	then
		ECHO_LOG ""
		ECHO_LOG "#========================================="
		ECHO_LOG "# WARNING: The file $FILE is empty."
		ECHO_LOG "#========================================="
		ECHO_LOG ""
		continue
	fi

	# Increment file counter
	((FILENOMAX_NT++))

	
	# Set file names for tracking
	FILENAME_ORG=$(basename $FILE)
	FILENAME_SRV="$(echo $FILENAME_ORG | cut -d\. -f1).dat"
	
	# Get the number of lines in the file
	NB_LINES=$(awk 'END {print NR}' $FILE)

	# Extract file information from its name
	SSD_CF=$(echo ${FILENAME_ORG} | cut -d'_' -f4)
	ESB_CF=$(echo ${FILENAME_ORG} | cut -d'_' -f5)
	USR_CF=$(echo ${FILENAME_ORG} | cut -d'_' -f6 | tr '[:lower:]' '[:upper:]')
	FILE_DATE=$(echo ${FILENAME_ORG} | cut -d'_' -f7)
	PROVIDER=$(echo ${FILENAME_ORG} | cut -d\. -f1 | cut -d'_' -f8)


	NSTEP=${NJOB}_30
	#----------------------------------------------------------------------------
	LIBEL="ZIP ${FILENAME_ORG} to ${LIF_RES_FRSV}"
	ZIP_MODE="Z"
	ZIP_ODIR="${LIF_RES_FRSV}"
	ZIP_I="${LIF_RES_FR}/${FILENAME_ORG}"
	ZIP_O="svg_${DATETIME_SVG}_${ENV_PREFIX}_ESIJ0810_UP_${SSD_CF}_${ESB_CF}_${USR_CF}_${FILE_DATE}_${PROVIDER}.zip"
	ZIP_OPT=""
	ZIP


	NSTEP=${NJOB}_40
	# Begin SQL
	#----------------------------------------------------------------------------
	LIBEL="Start of file upload tracking"
	ISQL_BASE="BEST"
	ISQL_QRY="execute BEST..PuTLOADAUTOEST_01_O2 ${SSD_CF}, ${ESB_CF}, '${FILENAME_ORG}', '${FILENAME_SRV}', '${PROVIDER}', '${USR_CF}', ${FILENOMAX_NT}, ${UPLDNOMAX_NT}, 'I', 5, ${NB_LINES}"
	ISQL
	
	# Display file information
	ECHO_LOG "# FILE $FILENOMAX_NT: $(basename $FILE)"
	
	
	# Replace .txt file extension with .dat
	if [ "${FILENAME_ORG##*.}" = "txt" ]; then mv ${FILE} "${LIF_RES_FR}/$(echo $FILENAME_ORG | cut -d\. -f1).dat"; fi
	
done


JOBEND