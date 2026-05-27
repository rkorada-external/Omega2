#! /bin/ksh
#===============================================================================
# application name               : Compare data already extracted by EXTJ0010
# source name                    : ESDC1001.cmd
# revision                       : $Revision:   0.1  $
# extraction date                : 27/01/2020
# author                         : Lagha Belaid
# specifications reference       :
#                                :
#-------------------------------------------------------------------------------
# description                    : aCompare data already extracted by EXTJ0010
#
# parameters                     :
#   1. FPARM - File containes parametres of comparaison
#
#-------------------------------------------------------------------------------
# modifications chronology       :
# [01] 26/05/2021 D.DASILVATEIXEIRA : SPIRA 99999 add filter ZOOM_ACT
# [02] 31/05/2021 D.DASILVATEIXEIRA : SPIRA 99999 fix error handling
# [03] 01/06/2021 D.DASILVATEIXEIRA : SPIRA 99999 fix display TTECLEDA
# [04] 09/06/2021 D.DASILVATEIXEIRA : SPIRA 99999 attachment zip file
# [05] 16/06/2021 D.DASILVATEIXEIRA : SPIRA 99999 add function generate html and RECIPIENT_I
# [06] 15/11/2021 D.DASILVATEIXEIRA : SPIRA 97731 fix bug and comment attachment zip file
# [07] 20/02/2023 D.DASILVATEIXEIRA : SPIRA 99999 new table for extract of new job ESDC0003
#===============================================================================

# call generic functions
#------------------------------------------------------------------------------
. ${DUTI}/fctgen.cmd


# Job Initialization variables
#----------------------------------------------------------------------------
FPARM=$1
FPRM=$2

# Job Initialisation
#-------------------
JOBINIT

NSTEP=${NJOB}_01
#
#------------------------------------------------------------------------------

# Variables
# ------------------------------------
RUN_DATETIME=`date +"%Y-%m-%d %H:%M:%S"`
RUN_DATETIME_STR=`date +"%Y%m%d_%H%M%S"`

SERVER=`echo ${PRD_SRV} |cut -d_ -f1`
SENDER="EST.AUTO.TNR.REPORT"

MACRO_SII_ACT=`cat ${DPRM}/${FPRM}.prm |grep MACROSII_ACT | awk -F" " '{ print $2 }'`
ZOOM_ACT=`cat ${DPRM}/${FPRM}.prm |grep ZOOM_ACT | awk -F" " '{ print $2 }'`
SHOW_COMPONENT=`cat ${DPRM}/${FPRM}.prm |grep SHOW_COMPONENT | awk -F" " '{ print $2 }'`

# DATE1=`cat ${DPRM}/ESDC0000.prm | grep DATE1 | awk -F" " '{ print $2 }'`
# DATE2=`cat ${DPRM}/ESDC0000.prm | grep DATE2 | awk -F" " '{ print $2 }'`
DATE1=$(GETV ${FPARM} DATE1)
DATE2=$(GETV ${FPARM} DATE2)

echo "Do we report on MACROSII : ${MACRO_SII_ACT}"
echo "Do we report on ZOOM : ${ZOOM_ACT}"

if [[ ${SERVER} == "DEV" ]]; then
	RECEIPT=`cat ${DPRM}/${FPRM}.prm |grep RECIPIENT_D | awk -F" " '{ print $2 }'`
elif [[ ${SERVER} == "ITK" || ${SERVER} == "IN2" ]]; then
	RECEIPT=`cat ${DPRM}/${FPRM}.prm |grep RECIPIENT_I | awk -F" " '{ print $2 }'`
else
	RECEIPT=`cat ${DPRM}/${FPRM}.prm |grep RECIPIENT_P | awk -F" " '{ print $2 }'`
fi

echo "Recipient Loaded"

SITE=${USER}
LENV=$(GETV ${FPARM} LENV)
RENV=$(GETV ${FPARM} RENV)
LDATE=$(GETV ${FPARM} LDATE | sed -e 's/ *//g' |  sed -e 's/\///g')
RDATE=$(GETV ${FPARM} RDATE | sed -e 's/ *//g' |  sed -e 's/\///g')

I17_CLODAT=`date -d "${IF17CLODAT_D}" +'%d/%m/%Y'`
I4_CLODAT=`date -d "${IF4CLODAT_D}" +'%d/%m/%Y'`

DATE1_D=`date -d "${DATE1}" +'%d/%m/%Y'`
DATE2_D=`date -d "${DATE2}" +'%d/%m/%Y'`


if [ "${LENV}" == "${RENV}" ]; then 
	SUBJECT="${LENV}-${HOST_PRDSIT}-${I17_CLODAT}-TNR CHECK ON ${RUN_DATETIME}"
	SUBJECT_I4="${LENV}-${HOST_PRDSIT}-${I4_CLODAT}-TNR CHECK ON ${RUN_DATETIME} IFRS4"
else
	SUBJECT="${LENV} vs ${RENV}-${HOST_PRDSIT}-${I17_CLODAT}-TNR CHECK ON ${RUN_DATETIME}"
	SUBJECT_I4="${LENV} vs ${RENV}-${HOST_PRDSIT}-${I4_CLODAT}-TNR CHECK ON ${RUN_DATETIME} IFRS4"
fi

#-----------------------------------------------------------------
# IDENTIFY FILE
#-----------------------------------------------------------------
SUFFIX=$(echo $DFILT | awk -F'/' '{
        N=NF-1;
        if ($N == "ubeu" || $N == "ubas" || $N == "ubam" || $N == "ubgl")
        {print $N "/" $NF} else {print "ubeu/temporaire"}
        }' 2>/dev/null)

LIST=`grep LEFT_TYPE ${DPRM}/${FPRM}.prm |cut -d" " -f2`
echo "List Loaded OK"

#-----------------------------------------------------------------
# FUNCTIONS CREATE HTML BODY
#-----------------------------------------------------------------
HTMLINIT(){
	echo '<!DOCTYPE html>' > $1
	echo '<html lang="en" xmlns="http://www.w3.org/1999/xhtml">' >> $1
	echo '<head>' >> $1
	echo -e '\t<meta charset="UTF-8">' >> $1
	echo -e '\t<meta name="viewport" content="width=device-width,initial-scale=1">' >> $1
	echo -e '\t<meta name="x-apple-disable-message-reformatting">' >> $1
	echo -e '\t<!--[if mso]>' >> $1
	echo -e '\t<noscript>' >> $1
	echo -e '\t\t<xml>' >> $1
	echo -e '\t\t\t<o:OfficeDocumentSettings>' >> $1
	echo -e '\t\t\t\t<o:PixelsPerInch>96</o:PixelsPerInch>' >> $1
	echo -e '\t\t\t</o:OfficeDocumentSettings>' >> $1
	echo -e '\t\t</xml>' >> $1
	echo -e '\t</noscript>' >> $1
	echo -e '\t<![endif]-->' >> $1
	echo '</head>' >> $1
	echo '<body>' >> $1
}

HTMLEND(){
	echo '</body>' >> $1
	echo '</html>' >> $1
}

TABLEBODY(){
	awk -F';' -v col1=$TABLE_LCOL -v col2=$TABLE_RCOL -v col3=$TABLE_DCOL "BEGIN{
        print \"<table style='font-family:arial; font-size:12px; border-collapse:collapse' cellspacing='0' cellpadding='2' align='centre' width='1000px'>\"
    }
    {
        print \"\t<tr>\"
        for(i=1; i<=NF; i++){
            if( NR == 1 ){
                print \"\t\t<th bgcolor='#000000' style='color:#ffffff'>\" \$i \"</th>\"
            }
            else if ( NR == 2 ){
                print \"\t\t<th bgcolor='#17657D' style='color:#ffffff'>\" \$i \"</th>\"
            }
            else if((i >= col3 ) && NR > 2 ){
                print \"\t\t<td bgcolor='#FFC7BB'>\" \$i \"</td>\"
            }
            else if((i >= col2 ) && NR > 2 ){
                print \"\t\t<td bgcolor='#FFFDC7'>\" \$i \"</td>\"
            }
            else if((i >= col1 ) && NR > 2 ){
                print \"\t\t<td bgcolor='#C9FFCE'>\" \$i \"</td>\"
            }
            else{
                print \"\t\t<td>\" \$i \"</td>\"
            }
        }
        print \"\t</tr>\"
    }
    END{
        print \"</table>\"
    }" $CSV_FILE >> $1

	CSV_FILE=""
	TABLE_LCOL=""
	TABLE_RCOL=""
	TABLE_DCOL=""
}

LIBEL="CREATE HTML FILE"
STEPSTART

HTMLINIT $DFILT/${NJOB}_mailI4.html
HTMLINIT $DFILT/${NJOB}_mail.html


if [[ ($SHOW_COMPONENT == "Yes") || ($SHOW_COMPONENT == "YES") || ($SHOW_COMPONENT == "yes") || ($SHOW_COMPONENT == "Y") ]]; then
	echo "<p style='font-family:arial; font-size:20px'>Delivered components between ${DATE1_D} and ${DATE2_D} </p>" >> $DFILT/${NJOB}_mailI4.html
	echo "<p style='font-family:arial; font-size:20px'>Delivered components between ${DATE1_D} and ${DATE2_D} </p>" >> $DFILT/${NJOB}_mail.html

	# DAT_FILE="${DFILT}/TNR-EXTRACT-COMPONENTS-${DATE1}_${DATE2}_REPORT.dat"
	# echo "<p>" >> $DFILT/${NJOB}_mailI4.html
	# cat $DAT_FILE >> $DFILT/${NJOB}_mailI4.html
	# echo "</p>" >> $DFILT/${NJOB}_mailI4.html

	# echo "<p>" >> $DFILT/${NJOB}_mail.html
	# cat $DAT_FILE >> $DFILT/${NJOB}_mail.html
	# echo "</p>" >> $DFILT/${NJOB}_mail.html


	CSV_FILE="${DFILT}/TNR-EXTRACT-COMPONENTS-${DATE1}_${DATE2}_REPORT.csv"
	TABLE_LCOL=6
	TABLE_RCOL=99
	TABLE_DCOL=99
	TABLEBODY $DFILT/${NJOB}_mailI4.html
	
	CSV_FILE="${DFILT}/TNR-EXTRACT-COMPONENTS-${DATE1}_${DATE2}_REPORT.csv"
	TABLE_LCOL=6
	TABLE_RCOL=99
	TABLE_DCOL=99
	TABLEBODY $DFILT/${NJOB}_mail.html
fi


for LIST in `grep LEFT_TYPE ${DPRM}/${FPRM}.prm |cut -d" " -f2`
do
	EXCEPTION_PROCESS=ON

	TABLE_TYPE=`echo ${LIST} | rev | cut -d- -f2- | rev | cut -d- -f3-`
	TABLE_TYPE_SHORT=`echo ${TABLE_TYPE} | cut -d- -f1`

	if [[ "${TABLE_TYPE}" =~ "-I4$" ]]; then 
		MAIL_BODY=$DFILT/${NJOB}_mailI4.html
	else
		MAIL_BODY=$DFILT/${NJOB}_mail.html
	fi

	LIBEL="Start the loop ${TABLE_TYPE}"
	STEPSTART
	# echo "Start the loop ${TABLE_TYPE}"
	# [06]
	CSV_FN=`ls -t ${DFILT}/*${LIST}*${LENV}-${LDATE}*${RENV}-${RDATE}* | head -1` # après
	echo $CSV_FN

	if [[ ("${TABLE_TYPE}" == "TTECLEDSII" || "${TABLE_TYPE}" == "TTECLEDSII-I4") && ("${CSV_FN}" != "") ]]; then
		#-----------------------------------------------------------------
		# CALCULATE DIFF ON CSV FILE
		#-----------------------------------------------------------------
		awk 'BEGIN { FS=";"; OFS=";"; s="" } \
		{
			if (NR == 1) print $0";;;"
			if (NR == 2) print $0";Diff TOTAL;Diff TOTAL INI;DIFF ROWS"
			if (NR > 2) print $0";"$11-$8";"$12-$9";"$13-$10
		}' $CSV_FN > ${DFILT}/${NJOB}_${TABLE_TYPE}_withDIFF.csv

		#-----------------------------------------------------------------
		# PREPARE EMAIL BODY TO BE SENT
		#-----------------------------------------------------------------
		CSV_FILE=${DFILT}/${NJOB}_${TABLE_TYPE}_withDIFF.csv
		TABLE_LCOL=8
		TABLE_RCOL=11
		TABLE_DCOL=14

		echo "<p style='font-family:arial; font-size:20px'>Casflow assumed and retro (${TABLE_TYPE_SHORT})</p>" >> $MAIL_BODY
		TABLEBODY $MAIL_BODY

	elif [[ ("${TABLE_TYPE}" == "TTECLEDSIIMACRO" || "${TABLE_TYPE}" == "TTECLEDSIIMACRO-I4") && ("${CSV_FN}" != "") && (${MACRO_SII_ACT} == "Yes") ]]; then
		#-----------------------------------------------------------------
		# CALCULATE DIFF ON CSV FILE
		#-----------------------------------------------------------------
		awk 'BEGIN { FS=";"; OFS=";"; s="" } \
		{
			if (NR == 1) print $0";"
			if (NR == 2) print $0";DIFF ROWS"
			if (NR > 2) print $0";"$10-$9
		}' $CSV_FN > ${DFILT}/${NJOB}_${TABLE_TYPE}_withDIFF.csv

		#-----------------------------------------------------------------
		# PREPARE EMAIL BODY TO BE SENT
		#-----------------------------------------------------------------
		CSV_FILE=${DFILT}/${NJOB}_${TABLE_TYPE}_withDIFF.csv
		TABLE_LCOL=9
		TABLE_RCOL=10
		TABLE_DCOL=11

		echo "<p style='font-family:arial;font-size:20px;'>Cashflow summary (${TABLE_TYPE_SHORT})</p>" >> $MAIL_BODY
		TABLEBODY $MAIL_BODY
        
	elif [[ ("${TABLE_TYPE}" == "TTECLEDSIIZOOM" || "${TABLE_TYPE}" == "TTECLEDSIIZOOM-I4") && ("${CSV_FN}" != "") && (${ZOOM_ACT} == "Yes") ]]; then
		#-----------------------------------------------------------------
		# CALCULATE DIFF ON CSV FILE
		#-----------------------------------------------------------------
		awk 'BEGIN { FS=";"; OFS=";"; s="" } \
		{
			if (NR == 1) print $0";;;"
			if (NR == 2) print $0";Diff TOTAL;Diff TOTAL INI;DIFF ROWS"
			if (NR > 2) print $0";"$24-$21";"$25-$22";"$26-$23
		}' $CSV_FN > ${DFILT}/${NJOB}_${TABLE_TYPE}_withDIFF.csv

		#-----------------------------------------------------------------
		# REDUCE THE SCOPE FOR EMAIL
		#-----------------------------------------------------------------
		cat ${DFILT}/${NJOB}_${TABLE_TYPE}_withDIFF.csv | head -2 > ${DFILT}/${NJOB}_${TABLE_TYPE}_withDIFF_ZOOM.csv

		for ACMTRS in `cat ${DFILT}/${NJOB}_${TABLE_TYPE}_withDIFF.csv | cut -d";" -f7 |sort -u |grep -v ACMTRS` 
		do 
			grep ";${ACMTRS};" ${DFILT}/${NJOB}_${TABLE_TYPE}_withDIFF.csv | awk -F';' '{ 
				if( $27 < 0 ){
					array[NR]+= $27 * -1
				}else{
					array[NR]+= $27
				}
				if(array[NR] >= 10 || array[NR] <= -10){
					printf "%s~%s\n", array[NR], $0
				}
			}' | sort -r -t'~' -nk1 | cut -d"~" -f2 | head -3
		done >> ${DFILT}/${NJOB}_${TABLE_TYPE}_withDIFF_ZOOM.csv

		#-----------------------------------------------------------------
		# PREPARE EMAIL BODY TO BE SENT
		#-----------------------------------------------------------------
		CSV_FILE=${DFILT}/${NJOB}_${TABLE_TYPE}_withDIFF_ZOOM.csv
		TABLE_LCOL=21
		TABLE_RCOL=24
		TABLE_DCOL=27

		echo "<p style='font-family:arial;font-size:20px;'>Cashflow summary (${TABLE_TYPE_SHORT})</p>" >> $MAIL_BODY
		echo "<p style=font-family:arial;font-size:10px;>Full delta available here : ${DFILT}/${NJOB}_${TABLE_TYPE}_withDIFF.csv</p>" >> $MAIL_BODY
		TABLEBODY $MAIL_BODY

		#-----------------------------------------------------------------
		# ZIP CSV FILE
		#-----------------------------------------------------------------
		# CLOSING_DATE=`cat ${DFILT}/${NJOB}_${TABLE_TYPE}_withDIFF.csv | head -1 | cut -d";" -f24 | cut -d":" -f2 | sed 's/\///g' | sed 's/ \+//g'`

		# gzip -c ${DFILT}/${NJOB}_${TABLE_TYPE}_withDIFF.csv > ${DFILT}/${TABLE_TYPE}_${CLOSING_DATE}.gz

	elif [[ ("${TABLE_TYPE}" == "TTECLEDAZOOM" || "${TABLE_TYPE}" == "TTECLEDAZOOM-I4") && ("${CSV_FN}" != "") && (${ZOOM_ACT} == "Yes") ]]; then
		#-----------------------------------------------------------------
		# CALCULATE DIFF ON CSV FILE
		#-----------------------------------------------------------------
		awk 'BEGIN { FS=";"; OFS=";"; s="" } \
		{
			if (NR == 1) print $0";;"
			if (NR == 2) print $0";Diff TOTAL;DIFF ROWS"
			if (NR > 2) print $0";"$19-$17";"$20-$18
		}' $CSV_FN > ${DFILT}/${NJOB}_${TABLE_TYPE}_withDIFF.csv

		#-----------------------------------------------------------------
		# REDUCE THE SCOPE FOR EMAIL
		#-----------------------------------------------------------------
		cat ${DFILT}/${NJOB}_${TABLE_TYPE}_withDIFF.csv | head -2 > ${DFILT}/${NJOB}_${TABLE_TYPE}_withDIFF_ZOOM.csv

		for ACMTRS in `cat ${DFILT}/${NJOB}_${TABLE_TYPE}_withDIFF.csv | cut -d";" -f2 |sort -u |grep -v ACMTRS`
		do
			grep ";${ACMTRS};" ${DFILT}/${NJOB}_${TABLE_TYPE}_withDIFF.csv | awk -F';' '{ 
				if( $21 < 0 ){
					array[NR]+= $21 * -1
				}else{
					array[NR]+= $21
				}

				if(array[NR] >= 10 || array[NR] <= -10){
					printf "%s~%s\n", array[NR], $0
				}
			}' | sort -r -t'~' -nk1 | cut -d"~" -f2 | head -3
		done >> ${DFILT}/${NJOB}_${TABLE_TYPE}_withDIFF_ZOOM.csv

		#-----------------------------------------------------------------
		# PREPARE EMAIL BODY TO BE SENT
		#-----------------------------------------------------------------
		CSV_FILE=${DFILT}/${NJOB}_${TABLE_TYPE}_withDIFF_ZOOM.csv
		TABLE_LCOL=17
		TABLE_RCOL=19
		TABLE_DCOL=21

		echo "<p style='font-family:arial;font-size:20px;'>Sample of Accounting delta (${TABLE_TYPE_SHORT})</p>" >> $MAIL_BODY
		echo "<p style=font-family:arial;font-size:10px;>Full delta available here : ${DFILT}/${NJOB}_${TABLE_TYPE}_withDIFF.csv</p>" >> $MAIL_BODY
		TABLEBODY $MAIL_BODY

		#-----------------------------------------------------------------
		# ZIP CSV FILE
		#-----------------------------------------------------------------
		# CLOSING_DATE=`cat ${DFILT}/${NJOB}_${TABLE_TYPE}_withDIFF.csv | head -1 | cut -d";" -f18 | cut -d":" -f2 | sed 's/\///g' | sed 's/ \+//g'`

		# gzip -c ${DFILT}/${NJOB}_${TABLE_TYPE}_withDIFF.csv > ${DFILT}/${TABLE_TYPE}_${CLOSING_DATE}.gz

	elif [[ ("${TABLE_TYPE}" == "TTECLEDR" || "${TABLE_TYPE}" == "TTECLEDR-I4") && ("${CSV_FN}" != "") || ("${TABLE_TYPE}" == "TTECLEDA" || "${TABLE_TYPE}" == "TTECLEDA-I4") && ("${CSV_FN}" != "") ]]; then
		#-----------------------------------------------------------------
		# CALCULATE DIFF ON CSV FILE
		#-----------------------------------------------------------------
		if [[ "${TABLE_TYPE}" == "TTECLEDR" || "${TABLE_TYPE}" == "TTECLEDR-I4" ]]; then
			TYPE="Retro"
		else
			TYPE="Assumed"
		fi

		awk 'BEGIN { FS=";"; OFS=";"; s="" } \
		{
			if (NR == 1) print $0";;"
			if (NR == 2) print $0";Diff TOTAL;DIFF ROWS"
			if (NR > 2) print $0";"$6-$4";"$7-$5
		}' $CSV_FN > ${DFILT}/${NJOB}_${TABLE_TYPE}_withDIFF.csv

		#-----------------------------------------------------------------
		# PREPARE EMAIL BODY TO BE SENT FOR TTECLEDA SCTRUCT
		#-----------------------------------------------------------------
		CSV_FILE=${DFILT}/${NJOB}_${TABLE_TYPE}_withDIFF.csv
		TABLE_LCOL=4
		TABLE_RCOL=6
		TABLE_DCOL=8

		echo "<p style='font-family:arial;font-size:20px;'>Accounting ${TYPE} (${TABLE_TYPE_SHORT})</p>" >> $MAIL_BODY
		TABLEBODY $MAIL_BODY
	else
		echo "" >>  ${MAIL_BODY}
	fi

	STEPEND 0
	EXCEPTION_PROCESS=""
done

HTMLEND $DFILT/${NJOB}_mailI4.html
HTMLEND $DFILT/${NJOB}_mail.html

STEPEND 0
#-----------------------------------------------------------------
# FUNCTIONS CREATE BODY MAIL
#-----------------------------------------------------------------
BOUNDARY="---boundary$$--"
INIT_MAIL(){
	echo "From: ${SENDER}";
	echo "To: ${RECEIPT}";
	echo "Subject: $1";
	echo "MIME-Version: 1.0";
	echo "Content-Type: multipart/mixed; boundary=\"${BOUNDARY}\"";
}

END_MAIL(){
	echo "--${BOUNDARY}--";
}

HTMLBODY_MAIL(){
	echo "--${BOUNDARY}";
	echo "Content-Type: text/html";
	cat $1;
}

ATTACHEMENT_MAIL(){
	echo "--${BOUNDARY}";
	echo "Content-Type: application/gzip";
	echo "Content-Transfer-Encoding: base64";
	echo "Content-Disposition: attachment; filename=\"$(basename $1)\"";
	echo "";
	base64 $1;
}

NSTEP=${NJOB}_02
LIBEL="Send emails to recipients"
STEPSTART

#-----------------------------------------------------------------
# Send emails to recipients
#-----------------------------------------------------------------
ECHO_LOG "#"
ECHO_LOG "#"
ECHO_LOG "#========================================================================="
ECHO_LOG "# Sending summary email "
ECHO_LOG "# Sender: ${SENDER}"
ECHO_LOG "# Recipient: ${RECEIPT}"
if [ "${ZOOM_ACT}" == "Yes" ]; then
	# GZ_FILE_TTECLEDSIIZOOM=`ls -t ${DFILT}/TTECLEDSIIZOOM_*.gz | head -1`
	# GZ_FILE_TTECLEDA=`ls -t ${DFILT}/TTECLEDAZOOM_*.gz | head -1`

	(
		INIT_MAIL "${SUBJECT}"
		HTMLBODY_MAIL $DFILT/${NJOB}_mail.html
		# ATTACHEMENT_MAIL $GZ_FILE_TTECLEDSIIZOOM
		# ATTACHEMENT_MAIL $GZ_FILE_TTECLEDA
		END_MAIL
	) | sendmail -t
else
	(
		INIT_MAIL "${SUBJECT}"
		HTMLBODY_MAIL $DFILT/${NJOB}_mail.html
		END_MAIL
	) | sendmail -t
fi
ECHO_LOG "#========================================================================="
ECHO_LOG "#"
ECHO_LOG "#"

#-----------------------------------------------------------------
# Send emails to recipients
#-----------------------------------------------------------------
ECHO_LOG "#"
ECHO_LOG "#"
ECHO_LOG "#========================================================================="
ECHO_LOG "# Sending summary email "
ECHO_LOG "# Sender: ${SENDER}"
ECHO_LOG "# Recipient: ${RECEIPT}"
if [ "${ZOOM_ACT}" == "Yes" ]; then
	# GZ_FILE_TTECLEDSIIZOOM_I4=`ls -t ${DFILT}/TTECLEDSIIZOOM-I4_*.gz | head -1`
	# GZ_FILE_TTECLEDA_I4=`ls -t ${DFILT}/TTECLEDAZOOM-I4_*.gz | head -1`

	(
		INIT_MAIL "${SUBJECT_I4}"
		HTMLBODY_MAIL $DFILT/${NJOB}_mailI4.html
		# ATTACHEMENT_MAIL $GZ_FILE_TTECLEDSIIZOOM_I4
		# ATTACHEMENT_MAIL $GZ_FILE_TTECLEDA_I4
		END_MAIL
	) | sendmail -t
else
	(
		INIT_MAIL "${SUBJECT_I4}"
		HTMLBODY_MAIL $DFILT/${NJOB}_mailI4.html
		END_MAIL
	) | sendmail -t
fi
ECHO_LOG "#========================================================================="
ECHO_LOG "#"
ECHO_LOG "#"

STEPEND 0

#-----------------------------------------------------------------
# REMOVE BODY FILE
#-----------------------------------------------------------------
echo "# Remove Files :"
echo "# $DFILT/${NJOB}_mail.html"
echo "# $DFILT/${NJOB}_mailI4.html"
rm $DFILT/${NJOB}_mail.html
rm $DFILT/${NJOB}_mailI4.html

# END Of Job
#------------------------------------------------------------------------------
JOBEND

