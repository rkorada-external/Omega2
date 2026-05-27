#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - COMMUNS
# nom du script SHELL           : ESCJ0004.cmd
# date de creation              : 08/10/2020
# auteur                        : Mehdi NAJI
#-----------------------------------------------------------------------------
# description:  Mise à joure de TREQJOBPLAN si une demande est faite dans TI17REQJOBPLAN
#
# job launched by ESCJ0000.cmd
#-----------------------------------------------------------------------------
# Modification Records
#---------------
#MODIFICATION   :
#[000]  08/10/2020  M.NAJI: Spira 87596 Mise à joure de TREQJOBPLAN si une demande est faite dans TI17REQJOBPLAN
#[000]  12/09/2022  M.NAJI: Spira 106737 Add I4IQPOS,I4IYPOS if  I4IQPOSP,I4IYPOSP
#[003]  02/12/2022  M.NAJI: SPIRA 88053  création automatique request dans TI17REQJOBPLAN
#[004]  30/06/2024  M.NAJI: SPIRA 999999 Fix Settlement accounting - Issue on Europe closing on Saturday
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Job Initialisation
JOBINIT

# Parameters
DBCLO_D=$1

set `GETPRM ${DPRM}/RQSTAUTO.prm`
HEADER=${1}
MAILS="${2}\nCc:${3}"


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> C/BEST..PuREQJOBPLAN_03/RE_D..........: ${CRE_D}"
ECHO_LOG "#===> DBCLO_D........: ${DBCLO_D}"
ECHO_LOG "#===> BALSHTMTH_NF...: ${BALSHTMTH_NF}"
ECHO_LOG "#===> MAILS..........: ${MAILS}"
ECHO_LOG "#===> USER.......... : $USER"
ECHO_LOG "#===> LOGNAME....... : $LOGNAME"
ECHO_LOG "#===> DEFAULT_SQL_LOGIN: $DEFAULT_SQL_LOGIN"
ECHO_LOG "#========================================================================="



if [ "${DEFAULT_SQL_LOGIN}" = "ubas" ]
then

	NSTEP=${NJOB}_01
	# Begin bcp
	#------------------------------------------------------------------------------
	LIBEL="Copie des demandes nouveau mode vers l'ancien mode"
	BCP_WAY="OUT"
	BCP_VER="+"
	BCP_FS=";"
	BCP_O=${DFILT}/${NSTEP}_${IB}_BCPOUT-PiTI17REQJOBPLAN_AUTO.dat
	BCP_QRY="execute  BEST..PiTI17REQJOBPLAN_AUTO_04  '${DBCLO_D}' "
	BCP


	NSTEP=${NJOB}_02
	# SPLIT rows of MAIL and log
	#-----------------------------------------------------------------------------
	LIBEL="SPLIT rows of MAIL and log"
	SORT_WDIR=${SORTWORK}
	SORT_FS=";"
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${NJOB}_01_${IB}_BCPOUT-PiTI17REQJOBPLAN_AUTO.dat 1000 1"
	SORT_O="${DFILT}/${NSTEP}_${IB}_BCPOUT-PiTI17REQJOBPLAN_AUTO_MAIL.dat"
	SORT_O2="${DFILT}/${NSTEP}_${IB}_BCPOUT-PiTI17REQJOBPLAN_AUTO_LOG.dat"
	INPUT_TEXT ${SORT_CMD} <<EOF
	/FIELDS
					type         	1:1 -  1:,
					num         	20:1 -  20:EN,
					all_cols        2:1 - 20:
	/KEYS
			num
	/CONDITION COND_MAIL type EQ "MAIL"
	/OUTFILE  ${SORT_O} OVERWRITE
	/INCLUDE COND_MAIL
	/REFORMAT all_cols
	/OUTFILE  ${SORT_O2} OVERWRITE
	/OMIT COND_MAIL
	exit
EOF
	SORT


	if [ -s "${DFILT}/${NJOB}_02_${IB}_BCPOUT-PiTI17REQJOBPLAN_AUTO_MAIL.dat" ]
	then
		NSTEP=${NJOB}_03
		#----------------------------------------------------------------------------
		LIBEL="add Header"
		AWK_I=${DFILT}/${NJOB}_02_${IB}_BCPOUT-PiTI17REQJOBPLAN_AUTO_MAIL.dat
		AWK_O=${DFILT}/${NSTEP}_${IB}_BCPOUT-PiTI17REQJOBPLAN_AUTO_MAIL.csv
		AWK_PARAM=" -v header=$HEADER "
		AWK_CMD=`CFTMP`
		INPUT_TEXT ${AWK_CMD} <<EOF
		BEGIN{print header}{print \$0}
		exit
EOF
		AWK

		
		NSTEP=${NJOB}_04
		# zip file to send 
		#----------------------------------------------------------------------------
		LIBEL="zip file to send "
		ZIP_ODIR=""
		ZIP_I="${DFILT}/${NJOB}_03_${IB}_BCPOUT-PiTI17REQJOBPLAN_AUTO_MAIL.csv"
		ZIP_O="${DFILT}/${NSTEP}_${IB}_BCPOUT-PiTI17REQJOBPLAN_AUTO_MAIL.zip"
		ZIP_OPT=""
		ZIP_MODE="Z"
		ZIP

		
		NSTEP=${NJOB}_05
		#----------------------------------------------------------------------------
		LIBEL="send log file"
		MAIL_ADR=${MAILS}
		MAIL_SENDER=requests-update@scor.com
		MAIL_SUBJECT="Automatic requests update"
		MAIL_FILE=${DFILT}/${NJOB}_04_${IB}_BCPOUT-PiTI17REQJOBPLAN_AUTO_MAIL.zip
		#MAIL_CONTENT="${DFILT}/${NJOB}_03_${IB}_BCPOUT-PiTI17REQJOBPLAN_AUTO_MAIL.csv"
		SENDMAIL 
	fi

fi


NSTEP=${NJOB}_06
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Check request"
ISQL_BASE="BEST"
ISQL_O="${DFILP}/${NCHAIN}_REQUESTS.dat"
ISQL_QRY="BEST..PsCheckRequest_01 '${DBCLO_D}'"
ISQL

NSTEP=${NJOB}_07
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Add I4IQPOS,I4IYPOS if  I4IQPOSP,I4IYPOSP"
ISQL_BASE="BEST"
ISQL_O="${DFILI}/${NCHAIN}_ADD_POS.dat"
ISQL_QRY="
	delete best..TI17REQJOBPLAN
	where 1=1
	and REQCOD_CT in ('I4IQPOS','I4IYPOS')
	and  UPDUSR_CF = 'ESCJ'
	and   launch_d  =NULL
	and   dbclo_d  <= '${DBCLO_D}'
	and   site_cf   = '${HOST_PRDSIT}'


	insert best..TI17REQJOBPLAN  (SSD_CF,BALSHEYEA_NF,BALSHTMTH_NF,CLODAT_D,REQCOD_CT,CRE_D,DBCLO_D,LAUNCH_D,CLOTYP_CT,NORME_CF,CLOPER_LS,VRS_NF,UPDUSR_CF,START_D,END_D,SITE_CF,CMT_NT) 
	select SSD_CF,BALSHEYEA_NF,BALSHTMTH_NF,CLODAT_D,substring(REQCOD_CT,1,7),CRE_D,DBCLO_D,LAUNCH_D,CLOTYP_CT,NORME_CF,CLOPER_LS,VRS_NF,'ESCJ',START_D,END_D,SITE_CF,CMT_NT
	from best..TI17REQJOBPLAN
	where 1=1
	and REQCOD_CT in ('I4IQPOSP','I4IYPOSP')
	and   launch_d = NULL
	and   dbclo_d  <= '${DBCLO_D}'
	and   site_cf   = '${HOST_PRDSIT}'
	
	select * from 
	best..TI17REQJOBPLAN
	where 1=1
	and  UPDUSR_CF = 'ESCJ'
	and  launch_d  =NULL
	and  dbclo_d  <= '${DBCLO_D}'
	and  site_cf   = '${HOST_PRDSIT}'
"
ISQL

NSTEP=${NJOB}_10
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Copie des demandes nouveau mode vers l'ancien mode"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILP}/${NCHAIN}_MODE.dat
BCP_LOG=${DFILT}/${NSTEP}_${IB}_BCPOUT.log
BCP_QRY="execute BEST..PuREQJOBPLAN_03  '${DBCLO_D}' "
BCP



NSTEP=${NJOB}_15
# Begin isql
#------------------------------------------------------------------------------
LIBEL="delete I4IQPOS,I4IYPOS if  I4IQPOSP,I4IYPOSP and user=ESCJ"
ISQL_BASE="BEST"
ISQL_O="${DFILI}/${NCHAIN}_DEL_POS.dat"
ISQL_QRY="
	delete best..TI17REQJOBPLAN
	where 1=1
	and REQCOD_CT in ('I4IQPOS','I4IYPOS')
	and  UPDUSR_CF = 'ESCJ'
	and   launch_d  =NULL
	and   dbclo_d  <= '${DBCLO_D}'
	and   site_cf   = '${HOST_PRDSIT}'
	
	select * from 
	best..TI17REQJOBPLAN
	where 1=1
	and  UPDUSR_CF = 'ESCJ'
	and  launch_d  =NULL
	and  dbclo_d  <= '${DBCLO_D}'
	and  site_cf   = '${HOST_PRDSIT}'
"
ISQL


# End of Job
JOBEND

