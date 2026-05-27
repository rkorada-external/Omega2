#! /bin/ksh
#============================================================================
# application name               : Data comparator
# source name                    : ESDC1000.cmd
# revision                       : $Revision:   0.1  $
# extraction date                : 27/01/2020
# author                         : Lagha Belaid
# specifications reference       :
#                                :
#----------------------------------------------------------------------------
# description                    : compar data between envirenments
#
# parameters                     :
#
# environement file (by default is "=")
# prm file   : this fille must be contain the parameters needed for data reporting
#
#----------------------------------------------------------------------------
# modifications chronology       :
# [01] 26/05/2021 D.DASILVATEIXEIRA : SPIRA 99999 add filter ZOOM_ACT
# [02] 27/05/2021 D.DASILVATEIXEIRA : SPIRA 99999 auto RENV and RENV
# [03] 31/05/2021 D.DASILVATEIXEIRA : SPIRA 99999 fix error handling
# [04] 16/06/2021 D.DASILVATEIXEIRA : SPIRA 99999 fix bug PRV_DATE empty
# [05] 16/07/2021 D.DASILVATEIXEIRA : SPIRA 99999 fix bug compare faile and update code structure
# [06] 29/07/2021 D.DASILVATEIXEIRA : SPIRA 99999 fix bug comparison of the same files when LENV == RENV
# [07] 03/05/2022 D.DASILVATEIXEIRA : SPIRA 99999 get ICLODAT_D for EST_PARAM of LENV
# [08] 20/02/2023 D.DASILVATEIXEIRA : SPIRA 99999 add new job ESDC0003 for delivered components between DATE1 and DATE2
#============================================================================


# call generic functions
#------------------------------------------------------------------------------
. ${DUTI}/fctgen.cmd
. ${DUTI}/functions/fctgen/GETSTRUCT


# Chain Initialization variables
#----------------------------------------------------------------------------
CHAININIT $0 $1

# env

#------------------------------------------------------------------------------
# Get the parameters
#-------------------
FPARM=$2
FPRM=$3

if [ "${FPARM}" = "" ]; then
   FPARM=`CFTMP`
   FPRM='ESDC0000'
#    cat ${DPRM}/ESDC0000.prm | sed 's/^ *//g;/^$/d' | sed 's/ \+/="/' | sed 's/ *$/"/'
   cat ${DPRM}/ESDC0000.prm | sed 's/^ *//g;/^$/d' | sed 's/ \+/="/' | sed 's/ *$/"/' > ${FPARM}

else
	FPARM=`CFTMP`
	FPRM=$2
	cat ${DPRM}/${FPRM}.prm | sed 's/^ *//g;/^$/d' | sed 's/ \+/="/' | sed 's/ *$/"/' > ${FPARM}

fi


SITE=$(echo $DFILI | awk -F'/' '{
               N=NF-1;
               if ($N == "ubeu" || $N == "ubas" || $N == "ubam" || $N == "ubgl")
               {print $N } else {print "ubeu"}
              }' 2>/dev/null)

# [02]
LENV_Check=`cat ${DPRM}/${FPRM}.prm  |grep 'LENV' |cut -d" " -f2`
RENV_Check=`cat ${DPRM}/${FPRM}.prm  |grep 'RENV' |cut -d" " -f2`
# [02]
if [ "${LENV_Check}" = "" ]; then
	LENV_Check=`echo $PRD_SRV | awk -F'_' '{ print $1 }'`
	sed -i -e s/LENV=.*/LENV=\"${LENV_Check}\"/ ${FPARM}
fi
# [02]
if [ "${RENV_Check}" = "" ]; then
	RENV_Check=`echo $PRD_SRV | awk -F'_' '{ print $1 }'`
	sed -i -e s/RENV=.*/RENV=\"${RENV_Check}\"/ ${FPARM}
fi

# [07]
if [ "${LENV_Check}" = "PRD" ]
then
    LENV_PREFIX=P

elif [ "${LENV_Check}" = "DEV" ]
then
    LENV_PREFIX=D
elif [[ "${LENV_Check}" = "CNV" || "${LENV_Check}" = "CNVZ" ]]
then
    LENV_PREFIX=C
else
    LENV_PREFIX=T
fi

typeset -n LENVSRC=$(GETV ${FPARM} LENV)
typeset -n RENVSRC=$(GETV ${FPARM} RENV)

export LENV_INTERM=$(echo "${LENVSRC}")/${SITE}/interm
export RENV_INTERM=$(echo "${RENVSRC}")/${SITE}/interm

# [07]
export LENV_PERM=$(echo "${LENVSRC}")/${SITE}/perm 

# import parameters
#------------------
echo "Read param from ${LENV_PERM}/${LENV_PREFIX}_${EST_PARAM}" 2>&1 | ${TEE}
# [07]
export IF17CLODAT_D=$(sed -n 's/ *//g;/^EBS *~ *PARM_ICLODAT_D *~/p' ${LENV_PERM}/${LENV_PREFIX}_${EST_PARAM} | rev | cut -d~ -f1 | rev | uniq)
export IF4CLODAT_D=$(sed -n 's/ *//g;/^I4I *~ *PARM0_ICLODAT_D *~/p' ${LENV_PERM}/${LENV_PREFIX}_${EST_PARAM} | rev | cut -d~ -f1 | rev | uniq)

# [01]
ZOOM_ACT=`cat ${DPRM}/${FPRM}.prm |grep ZOOM_ACT | awk -F" " '{ print $2 }'`
SHOW_COMPONENT=`cat ${DPRM}/${FPRM}.prm |grep SHOW_COMPONENT | awk -F" " '{ print $2 }'`

# [05]
FN_CHECKDATE(){
	LST_DATE=`ls -t ${INTERM}/*${FILE_N}-EXFP* |head -1 | rev |cut -d. -f2 | cut -d_ -f1 | rev`
	PRV_DATE=`ls -t ${INTERM}/*${FILE_N}-EXFP* |head -2 | grep -v ${LST_DATE} |rev |cut -d. -f2 | cut -d_ -f1 | rev`

	if [ "$PRV_DATE" == "" ]; then
		PRV_DATE=$LST_DATE
	fi

	DATE_CHECK=`cat ${DPRM}/${FPRM}.prm  |grep $file~ |grep ${TYPE_DATE} | awk -F" " '{ print $2 }'`

	if [[ $DATE_CHECK == *"/"* ]]; then
		RESULT=`cat ${DPRM}/${FPRM}.prm  |grep $file~ |grep ${TYPE_DATE} | awk -F~ '{ print $2 }' | sed 's/^ *//g;/^$/d' | sed 's/ \+/="/' | sed 's/ *$/"/'`
		echo $RESULT >> ${FPARM}
	else
		if [[ $LENV_Check == $RENV_Check ]]; then
			# [06]
			if [[ $TYPE_DATE == "RDATE" ]]; then
				RESULT="${TYPE_DATE}=\"$LST_DATE\""
				echo $RESULT >> ${FPARM}
			else
				RESULT="${TYPE_DATE}=\"$PRV_DATE\""
				echo $RESULT >> ${FPARM}
			fi
		else
			RESULT="${TYPE_DATE}=\"$LST_DATE\""
			echo $RESULT >> ${FPARM}
		fi
	fi
}

# [05]
FN_COMPARE_INFO(){
	echo "# "
	echo "# Comparaison done : ${LENV_Check} vs ${RENV_Check}"
	echo "# Source Directory ${LENV_Check} for date ref : ${LENV_INTERM}"
	echo "# Source Directory ${RENV_Check} for date ref : ${RENV_INTERM}"
	echo "# Date Ref : ${LDATE_DEF}"
	echo "# Date compared to Ref : ${RDATE_DEF}"
	echo "# "
	echo "# FPARM for $file"
	cat ${FPARM} | sed 's/^/# /'
	echo "# End of FPARM for $file"
}

# [05]
FN_COMPARE_DISABLE(){
	echo "#"
	echo "#========================================================================="
	echo "# Comparison : DISABLE"
	echo "#"
	echo "# ZOOM ACT : ${ZOOM_ACT}"
	echo "# FILE NAME : ${FILE_N}"
	echo "#========================================================================="
	echo "#"
}

export i=1
for file in `cat ${DPRM}/${FPRM}.prm | awk -F~ '{ print $1}' |grep F |sort -u`
do
	# [02]
	echo LENV=\"${LENV_Check}\" > ${FPARM}
	echo RENV=\"${RENV_Check}\" >> ${FPARM}

	FILE_N=`cat ${DPRM}/${FPRM}.prm |grep $file~LEFT_TYPE |awk -F" " '{ print $2 }'`

	LST_DATE=""
	PRV_DATE=""
	INTERM=$LENV_INTERM
	TYPE_DATE="LDATE"
	FN_CHECKDATE

	LST_DATE=""
	PRV_DATE=""
	INTERM=$RENV_INTERM
	TYPE_DATE="RDATE"
	FN_CHECKDATE

	LDATE_DEF=`cat ${FPARM}	|grep 'LDATE' |cut -d" " -f2`
	RDATE_DEF=`cat ${FPARM} |grep 'RDATE' |cut -d" " -f2`

	if [ $i == 1 ]; then 
		DATE1=$(GETV ${FPARM} LDATE | sed -e 's/ *//g' |  sed -e 's/\///g')
		DATE2=$(GETV ${FPARM} RDATE | sed -e 's/ *//g' |  sed -e 's/\///g')
	fi

	cat ${DPRM}/${FPRM}.prm |grep $file~ |grep -v 'NAME=\|LDATE\|RDATE' | awk -F~ '{ print $2 }' | sed 's/^ *//g;/^$/d' | sed 's/ \+/="/' | sed 's/ *$/"/' >> ${FPARM}

	# Show compare info on log
	FN_COMPARE_INFO 2>&1 | ${TEE}

	# [01]
	ZOOM_CHECK="True"
	if [[ ($FILE_N == *"ZOOM"*) && ($ZOOM_ACT != "Yes") ]]; then
		ZOOM_CHECK="False"
	fi

	NJOB=ESDC0001
	# Call ESDC0001 JOB 
	#------------------
	if [ $ZOOM_CHECK = "True" ]; then
		$DCMD/ESDC0001.cmd ${FPARM} 2>&1 | ${TEE}
	else
		# Show disable compare on log
		FN_COMPARE_DISABLE 2>&1 | ${TEE}
	fi
	
	let i=i+1
done

# [08]
SHOW_COMPONENT_CHECK="false"
if [[ ($SHOW_COMPONENT == "Yes") || ($SHOW_COMPONENT == "YES") || ($SHOW_COMPONENT == "yes") || ($SHOW_COMPONENT == "Y") ]]; then
	SHOW_COMPONENT_CHECK="true"
fi





# Call ESDC0003 JOB
# ------------------ # [08]
DATE1_PRM=`cat ${DPRM}/${FPRM}.prm | grep DATE1 | awk -F" " '{ print $2 }' | sed -e 's/ *//g' |  sed -e 's/\///g'`
DATE2_PRM=`cat ${DPRM}/${FPRM}.prm | grep DATE2 | awk -F" " '{ print $2 }' | sed -e 's/ *//g' |  sed -e 's/\///g'`

if [ "${DATE1_PRM}" == "" ]; then
    echo DATE1=\"${DATE1}\" >> ${FPARM}
else
	echo DATE1=\"${DATE1_PRM}\" >> ${FPARM}
fi

if [ "${DATE2_PRM}" == "" ]; then
	echo DATE2=\"${DATE2}\" >> ${FPARM}
else
	echo DATE2=\"${DATE2_PRM}\" >> ${FPARM}
fi

if [ $SHOW_COMPONENT_CHECK == "true" ]; then
	NJOB=ESDC0003
	$DCMD/ESDC0003.cmd ${FPARM} 2>&1 | ${TEE}
else
	echo "ESDC0003 DISABLE"
fi

NJOB=ESDC0002
# Call ESDC0002 JOB
# ------------------
$DCMD/ESDC0002.cmd ${FPARM} ${FPRM} 2>&1 | ${TEE}

# End of chain
#----------------------------------------------------------------------------
CHAINEND
