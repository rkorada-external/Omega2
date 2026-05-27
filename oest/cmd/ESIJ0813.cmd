#!/bin/ksh
#===============================================================================
# Application Name      : ESTIMATION - AUTOMATIC FILE LOADING
# SHELL script name     : ESIJ0813.cmd
# Creation date         : 14/08/2020
# Author                : L. Wernert
# description           : Sending summary emails and generate reports
#===============================================================================
# Change history
# 05/10/2020 | L. Wernert:	[90501]  - I17: Interface of estimates upload
# 17/11/2021 | B. LAGHA  :	[98809]  - Replace sendmail commande with SENDMAIL fct.
# 06/05/2022 | Mr JYP    :	[112434] - Ns Mind, add checks on amount
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Initialise JOB
JOBINIT

# Entry parameters
#-----------------------------------------------------------------
set -x
LIF_RES_FR=$1
LIF_RES_TO=$2
EMPTY_DIR=$3
TEST_MAIL=$4
set +x

# Misc. parameters
#-----------------------------------------------------------------
if [ -z "$TEST_MAIL" ]
then
	set `GETPRM ${DPRM}/ESIJ0810.prm`
	RECIPIENTS[0]=$1
	RECIPIENTS[1]=$2
	RECIPIENTS[2]=$3
	#RECIPIENTS[3]=$4  
else
	RECIPIENTS[0]=$TEST_MAIL
	echo -e "#============================= \033[1;33mTEST MODE: ON\033[0m ============================="
	echo -e "# The report will be sent to the defined recipient: \033[1;33m$RECIPIENTS\033[0m"
	ECHO_LOG "#========================================================================="
fi


# Variables
# ------------------------------------
ENVIRONNEMENT=`echo ${SRV} | cut -c1-3 `
RUN_DATETIME=`date +"%Y-%m-%d %H:%M:%S"`
RUN_DATETIME_STR=`date +"%Y%m%d_%H%M%S"`
SENDER="est.auto.loading.report"
SUBJECT="${ENV_PREFIX}-AUTOMATIC ESTIMATION UPLOAD: FILE-LOADING REPORT ON ${RUN_DATETIME} from $ENVIRONNEMENT "
SITE=${USER}


NSTEP=${NJOB}_10
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Selection of the max UPLDNO_NT from BEST..TLOADAUTOEST"
ISQL_BASE="BEST"
ISQL_QRY="select max(UPLDNO_NT) from BEST..TLOADAUTOEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_MAXUPLDNO_ISQL_O.dat
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_MAXUPLDNO_ISQLRES_O.dat
ISQL_RES

UPLDNOMAX_NT=`cat ${ISQL_FRES} | sed -e s/\ //g`


NSTEP=${NJOB}_20
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="Generate email body"
BCP_WAY="OUT";
BCP_VER="+";
BCP_O=${DFILT}/${NJOB}_ctlfile.dat
BCP_QRY="execute BEST..PsTLOADAUTOEST_01_O2 'EST AUTO', '${LIF_RES_FR}', '${RUN_DATETIME}', '${ENV_PREFIX}', ${UPLDNOMAX_NT}, ${EMPTY_DIR}"
BCP


NSTEP=${NJOB}_25
LIBEL="Mailing to users"
#-----------------------------------------------------------------
# Send emails to recipients
#-----------------------------------------------------------------
MAIL_SENDER="${SENDER}"
MAIL_ADR="$(echo ${RECIPIENTS[@]} | sed  -e 's/ \+/, /g')"
MAIL_SUBJECT="${SUBJECT}"
MAIL_CONTENT="${DFILT}/${NJOB}_ctlfile.dat"
SENDMAIL


# If the directory is not empty, generate report files
#-----------------------------------------------------------------
if [ $EMPTY_DIR = "N" ]
then
	NSTEP=${NJOB}_30
	# Begin BCP OUT
	#------------------------------------------------------------------------------
	LIBEL="Generate general file for BTRAVI..BSTA_TUPLDESTGE01"
	BCP_WAY="OUT";
	BCP_VER="+";
	BCP_O=${DFILT}/${NSTEP}_${IB}_OUT_TUPLDESTGE01.dat
	BCP_QRY="execute BEST..PsTUPLDEST_01_O2 ${UPLDNOMAX_NT}, 'GE'"
	BCP


	NSTEP=${NJOB}_40
	# Begin BCP OUT
	#------------------------------------------------------------------------------
	LIBEL="Generate detailed file for BTRAVI..BSTA_TUPLDESTDET02"
	BCP_WAY="OUT";
	BCP_VER="+";
	BCP_O=${DFILT}/${NSTEP}_${IB}_OUT_TUPLDESTDET02.dat
	BCP_QRY="execute BEST..PsTUPLDEST_01_O2 ${UPLDNOMAX_NT}, 'DET'"
	BCP
	
	
	NSTEP=${NJOB}_45
	# Begin isql
	#------------------------------------------------------------------------------
	LIBEL="Delete data in BTRAV..EST_ESIJ0810_FILECONTENT"
	ISQL_BASE="BTRAV"
	ISQL_QRY="DELETE BTRAV..EST_ESIJ0810_FILECONTENT"
	ISQL
	
	
	NSTEP=${NJOB}_50
	#-----------------------------------------------------------
	LIBEL="Switch on server ${INF_SRV}"
	SWITCH_SRV ${INF_SRV}
  
  
	NSTEP=${NJOB}_60
	# Begin BCP IN
	#------------------------------------------------------------------------------
	LIBEL="Insert general file into BTRAVI..BSTA_TUPLDESTGE01"
	BCP_WAY="IN"; BCP_VER=""
	BCP_TRUNCATE=NO
	BCP_I=${DFILT}/${NJOB}_30_${IB}_OUT_TUPLDESTGE01.dat
	BCP_TABLE="BTRAVI..BSTA_TUPLDESTGE01"
	BCP


	NSTEP=${NJOB}_70
	# Begin BCP IN
	#------------------------------------------------------------------------------
	LIBEL="Insert detailed file into BTRAVI..BSTA_TUPLDESTDET02"
	BCP_WAY="IN"; BCP_VER=""
	BCP_TRUNCATE=NO
	BCP_I=${DFILT}/${NJOB}_40_${IB}_OUT_TUPLDESTDET02.dat
	BCP_TABLE="BTRAVI..BSTA_TUPLDESTDET02"
	BCP
else
	# Otherwise, create empty report files
	#-----------------------------------------------------------------
	touch ${DFILT}/${NJOB}_30_${IB}_OUT_TUPLDESTGE01.dat
	touch ${DFILT}/${NJOB}_40_${IB}_OUT_TUPLDESTDET02.dat
fi


NSTEP=${NJOB}_80
# Begin execksh
#---------------------------------------------------------------------------
LIBEL="Copy general report file to ${LIF_RES_TO}"
EXECKSH_MODE=P
EXECKSH "cp ${DFILT}/${NJOB}_30_${IB}_OUT_TUPLDESTGE01.dat ${LIF_RES_TO}/${ENV_PREFIX}_${SITE}_TUPLDESTGE01_${RUN_DATETIME_STR}.dat"


NSTEP=${NJOB}_90
# Begin execksh
#---------------------------------------------------------------------------
LIBEL="Copy detailed report file to ${LIF_RES_TO}"
EXECKSH_MODE=P
EXECKSH "cp ${DFILT}/${NJOB}_40_${IB}_OUT_TUPLDESTDET02.dat ${LIF_RES_TO}/${ENV_PREFIX}_${SITE}_TUPLDESTDET02_${RUN_DATETIME_STR}.dat"


NSTEP=${NJOB}_100
# Erase temporary files
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}_*${IB}*.dat"


JOBEND
