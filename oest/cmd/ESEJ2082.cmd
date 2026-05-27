#!/bin/ksh
#=============================================================================
# nom de l'application : DIP/Omega
# nom du script SHELL  : ESEJ2082.cmd
# date de creation     : 24/05/2021
# auteur               : KBhimasen 
# references des specifications :
#-----------------------------------------------------------------------------
# description:
# Omega/DIP interface for pattern management  
#
# 
#-----------------------------------------------------------------------------
# historiques des modifications
# [01] KBhimasen 28/09/2021	:Spira#96840 Discount - Illiquidity segment management	: Changes in step#45
#===============================================================================
# set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctpar.cmd

# SubJob Initialisation
SUBJOBINIT

#Step 1 Read input parameters
USR_CF=${1}
SSD_CF=${2}
DATA_TYPE=${3}
CLOS_TYPE=${4}
CLOS_DATE=${5}
LIGNES=${6}
LAG_CF=${7}
CUR_DATE=${8}
FILENAME=${9}

NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="Check if file exists at FTP location"
if [ ! -e ${FILENAME} ]
then
echo "file not found at the location  ${FILENAME}" > ${DFILT}/${NSTEP}_${IB}_SQL_O1.dat
EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_SQL_O1.dat ${DFILT}/output_${DATA_TYPE}_${CUR_DATE}.dat"
SUBJOBEND 99
fi

NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="Checking for closing period"
ISQL_BASE="BREF"
ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.dat
ISQL_QRY="declare  @close_type CHAR (3) ,@clos_date datetime,@p_inv_clodat_d datetime ,@p_inv_per_cf   char(3) exec BREF..PsCALEND_EBS '${CUR_DATE}',1,@clos_date OUTPUT, @close_type OUTPUT,null,null,@p_inv_clodat_d OUTPUT,@p_inv_per_cf OUTPUT "
ISQL

CLOSE_DATE=`sed -n '8p' ${DFILT}/${NJOB}_10_${IB}_SQL_O1.dat`
P_CLODAT_D=$(echo ${CLOSE_DATE} | awk '{print substr($0,1,11)}')
P_PER_CF=$(echo ${CLOSE_DATE} | awk '{print substr($0,21,3)}')
P_INV_CLODAT_D=$(echo ${CLOSE_DATE} | awk '{print substr($0,25,11)}')
P_INV_PER_CF=$(echo ${CLOSE_DATE} | awk '{print substr($0,45,3)}')
CLODAT_D=$(date -d"$P_CLODAT_D" +'%Y%m%d')
if [ "${P_INV_CLODAT_D}" != 'NULL NULL' ]
then
	INV_CLODAT_D=$(date -d"$P_INV_CLODAT_D" +'%Y%m%d')
fi

if [ "${CLODAT_D}" == "${CLOS_DATE}" ]
then 
	PER_CF=${P_PER_CF}
elif [[ "${INV_CLODAT_D}" != '' && "${INV_CLODAT_D}" == "${CLOS_DATE}" ]]
then
	PER_CF=${P_INV_PER_CF}
else 
	echo "Closing Date in the file name is not matching with Calendar date (" ${CLODAT_D} ")" > ${DFILT}/${NSTEP}_${IB}_SQL_O1.dat
	EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_SQL_O1.dat ${DFILT}/output_${DATA_TYPE}_${CUR_DATE}.dat"
JOBEND 99
fi

FULLFILENAME=DIP_${DATA_TYPE}_${CLOS_TYPE}_${CLOS_DATE}_${CUR_DATE}.dat

ECHO_LOG ""
ECHO_LOG "#========================================================================="

ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> FILENAME................: ${FILENAME}"
ECHO_LOG "#===> FULLFILENAME................: ${FULLFILENAME}"
ECHO_LOG "#===> DATA_TYPE................: ${DATA_TYPE}"
ECHO_LOG "#===> CLOS_DATE................: ${CLOS_DATE}"
ECHO_LOG "#===> CLOS_TYPE................: ${CLOS_TYPE}"
ECHO_LOG "#===> PER_CF................: ${PER_CF}"
ECHO_LOG "#===> USR_CF................: ${USR_CF}"
ECHO_LOG "#===> SSD_CF................: ${SSD_CF}"
ECHO_LOG "#===> CUR_DATE................: ${CUR_DATE}"
ECHO_LOG "#===> LAG_CF................: ${LAG_CF}"
ECHO_LOG "#===> LIGNES................: ${LIGNES}"

ECHO_LOG "#========================================================================="

if [ "${DATA_TYPE}" != "DSC" ]
then

	NSTEP=${NJOB}_15
	#------------------------------------------------------------------------------
	LIBEL="Call ESID0902"
	NSUBJOB=ESID0902_${DATA_TYPE}
	${DCMD}/ESID0902.cmd ${USR_CF} ${SSD_CF} ${CUR_DATE} ${DATA_TYPE} ${PER_CF} ${CLOS_DATE} ${LAG_CF} ${FILENAME} 2>&1 | ${TEE}
 
elif [ "${DATA_TYPE}" == "DSC" ]
then
	
	NSTEP=${NJOB}_20
	#------------------------------------------------------------------------------
	LIBEL=" Move file from FTP location to temporary location(DFILT)"
	EXECKSH "mv ${FILENAME} ${DFILT}/${NSTEP}_${IB}_DIP_${DATA_TYPE}_${CLOS_DATE}_${CLOS_TYPE}_${CUR_DATE}.dat"

	NSTEP=${NJOB}_25
	#------------------------------------------------------------------------------
	LIBEL="Convert carriage-returns to Unix"
	EXECKSH "dos2unix ${DFILT}/${NJOB}_20_${IB}_DIP_${DATA_TYPE}_${CLOS_DATE}_${CLOS_TYPE}_${CUR_DATE}.dat"
	
	NSTEP=${NJOB}_30
	#-----------------------------------------------------------------------------
	LIBEL="Add line number to file"
	awk -v CREUSR_CF=${USR_CF} -v CRE_D=${CUR_DATE} -v PATCAT_CT=${DATA_TYPE}  'BEGIN{FS="\t"; OFS="~"}   {if (NR != 1 )	{print $1,PATCAT_CT,$7,$3,$4,$5,$6,CRE_D,CREUSR_CF,NR-2,TOTAUX,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$70,$71,$72,$2}	}' ${DFILT}/${NJOB}_20_${IB}_DIP_${DATA_TYPE}_${CLOS_DATE}_${CLOS_TYPE}_${CUR_DATE}.dat > ${DFILT}/${NJOB}_30_${IB}_DF_${DATA_TYPE}_${SSD_CF}_AWK.dat
	
	NSTEP=${NJOB}_35
    #------------------------------------------------------------------------------
    LIBEL="Delete BTRAV..EST_ESID0821_TPATTERNSII"
    ISQL_BASE="BTRAV"
    ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.dat
    ISQL_QRY="Delete BTRAV..EST_ESID0821_TPATTERNSII where CREUSR_CF = '${USR_CF}'"
    ISQL
		
	NSTEP=${NJOB}_40
    #------------------------------------------------------------------------------
    LIBEL="Load  File in BTRAV..EST_ESID0821_TPATTERNSII"
    BCP_WAY="IN"; BCP_VER=""
    BCP_I="${DFILT}/${NJOB}_30_${IB}_DF_${DATA_TYPE}_${SSD_CF}_AWK.dat"
    BCP_TABLE="BTRAV..EST_ESID0821_TPATTERNSII"
    BCP
		
	NSTEP=${NJOB}_45
	# Begin isql
	#------------------------------------------------------------------------------
	LIBEL="Check Anamolies"
	ISQL_BASE="BEST"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
	ISQL_QRY="exec PtPATTERNSII_btrav_ano '${LAG_CF}', ${SSD_CF}, '${CUR_DATE}', '${USR_CF}', ${LIGNES}, 0, '${DATA_TYPE}', 0,'${CLOS_DATE}','${PER_CF}', '' "
	ISQL
		
	echo 'File' ${FULLFILENAME} 'is Fail' >> ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		
	FILE="${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat"

	NUMBER=0
	while IFS= read -r line
	do
	if [[ $line =~ "rows affected" || $line =~ "row affected" ]]; then
	NUMBER=$(echo "${line//[!0-9]/}")
	break
	fi
	done < "$FILE"

	if [ ${NUMBER} -ne 0 ]
	then
		
		EXECKSH "mv $FILE ${DFILT}/output_${DATA_TYPE}_${CUR_DATE}.dat"
		SUBJOBEND 99
	else
		NSTEP=${NJOB}_50
		#------------------------------------------------------------------------------
		LIBEL="Call ESID0100"
		NJOB=ESID0100
		${DCMD}/ESID0100.cmd = ${USR_CF} "${CUR_DATE}" ${DATA_TYPE} ${PER_CF} ${CLOS_DATE} ${LAG_CF} ${SSD_CF} ${LIGNES}
		fi
fi
		
NSTEP=${NJOB}_55
# Erase temporary files
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"
RMFIL "${DFILT}/${NSUBJOB}*_${IB}_*.dat"
		
SUBJOBEND