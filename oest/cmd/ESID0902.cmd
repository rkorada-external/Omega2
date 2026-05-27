#!/bin/ksh
#=============================================================================
# nom de l'application : Risk Adjustment
# nom du script SHELL  : ESID0902.cmd
# date de creation     : 13/09/2021
# auteur               : KBhimasen
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   control et fabrication du fichier d'�valuation des RISK
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[01] FCI Spira 110445 Interface DIP - manual upload should not overwrite DIP data
#===============================================================================
# set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Custumised Error handling
EXCEPTION () {

# Si le traitement va jusqu a la fin la fonction EXCEPTION ne doit rien faire
if test ${V_TESTEXCEPTION} -ne 0
   then
      # Cartouche de debut exception  ----------
      EXCEPTION_INIT

      if test ${V_RETURNCODE} -ne ${V_ANOMALY_CHECK}   # To avoid SP call in case of anamoly raised by coherence check step.
      then
        # Begin isql
        #------------------------------------------------------------------------------
        LIBEL="Insert Error code for batch failure"
        ISQL_BASE="BEST"
        ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
        ISQL_QRY="exec PiANOCOHRCHK_01 ${SSD_CF}, '${USR_CF}', ${V_MESS}, '', '${CLOS_DATE}', '${CLOS_PER}' "
        ISQL_FRES=${DFILT}/${NSTEP}_${IB}_FRES_O1.dat
        ISQL
      fi

      # Cartouche de fin exception  ----------
      EXCEPTION_END
fi
}


# Job Initialisation
SUBJOBINIT


#Step 1 Read input parameters
USR_CF=${1}
SSD_CF=${2}
CUR_DATE=${3}
DATA_TYPE=${4}
CLOS_PER=${5}
CLOS_DATE=${6}
LAG_CF=${7}
INPUT_FILE=${8}

V_MESS=''
V_TESTEXCEPTION=1
V_RETURNCODE=0
V_ANOMALY_CHECK=9999     #To avoid PiANODTLOAD_01 SP call again in case of anamoly raised by coherence check step.

FILENAME=${INPUT_FILE}

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> USR_CF......................: ${USR_CF}"
ECHO_LOG "#===> SSD_CF......................: ${SSD_CF}"
ECHO_LOG "#===> CUR_DATE....................: ${CUR_DATE}  "
ECHO_LOG "#===> DATA_TYPE...................: ${DATA_TYPE}  "
ECHO_LOG "#===> CLOS_PER....................: ${CLOS_PER}"
ECHO_LOG "#===> CLOS_DATE...................: ${CLOS_DATE}"
ECHO_LOG "#===> LAG_CF........................: ${LAG_CF}"


ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> FILENAME................: ${FILENAME}"

ECHO_LOG "#========================================================================="


V_MESS=3029
NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="Check if file exists at FTP location"
if [ ! -e ${FILENAME} ]
then
echo "file not found at the location  ${FILENAME}"
JOBEND 99
fi

V_MESS=3031
NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL=" Move file from FTP location to temporary location(DFILT)"
EXECKSH "mv ${FILENAME} ${DFILT}/${NSTEP}_${IB}_DF_${DATA_TYPE}_${SSD_CF}.dat"

V_MESS=3031
NSTEP=${NJOB}_15
#------------------------------------------------------------------------------
LIBEL="Convert carriage-returns to Unix"
EXECKSH "dos2unix ${DFILT}/${NJOB}_10_${IB}_DF_${DATA_TYPE}_${SSD_CF}.dat"


if [ "${DATA_TYPE}" = "RA" ]
then

        NSTEP=${NJOB}_20
        #------------------------------------------------------------------------------
        LIBEL="Add line number to file"
        awk -v USR_CF=${USR_CF} 'BEGIN{FS="\t"; OFS="~"}  {if (NR != 1 ) {print NR,USR_CF,$1,$2,$3,$4,$5,$6,$7,$8} }' ${DFILT}/${NJOB}_10_${IB}_DF_${DATA_TYPE}_${SSD_CF}.dat > ${DFILT}/${NJOB}_20_${IB}_DF_${DATA_TYPE}_${SSD_CF}_AWK.dat

		V_MESS=3031
        NSTEP=${NJOB}_25
        #------------------------------------------------------------------------------
        LIBEL="Truncate ULAE Ratio Working Table BTRAV..ESID0901_TRARAT"
        ISQL_BASE="BTRAV"
        ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
        ISQL_QRY="Delete BTRAV..ESID0901_TRARAT where USR_CF = '${USR_CF}'"
        ISQL

		V_MESS=3031
        NSTEP=${NJOB}_30
        #------------------------------------------------------------------------------
        LIBEL="Load Risk Margin File in BTRAV...TRARAT"
        BCP_WAY="IN"; BCP_VER=""
        BCP_I="${DFILT}/${NJOB}_20_${IB}_DF_${DATA_TYPE}_${SSD_CF}_AWK.dat"
        BCP_TABLE="BTRAV..ESID0901_TRARAT"
        BCP
		
		V_MESS=3031
		NSTEP=${NJOB}_31
		# Begin isql
		#MOD01
		#------------------------------------------------------------------------------
		LIBEL="Coherence checks"
		ISQL_BASE="BEST"
		ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		ISQL_QRY="exec PiANOCOHRCHK_01 ${SSD_CF}, '${USR_CF}', 0, '${DATA_TYPE}', '${CLOS_DATE}', '${CLOS_PER}'"
		ISQL_FRES=${DFILT}/${NSTEP}_${IB}_FRES_O1.dat
		ISQL_INFO
		
		
		RET_STATUS=`cat ${ISQL_FRES}`
		if [ ${RET_STATUS} -eq 1 ]
		then
			 V_RETURNCODE=${3031}
		         trap EXCEPTION 0
		         return V_RETURNCODE
		fi
		
		V_MESS=3031
        NSTEP=${NJOB}_35
        #------------------------------------------------------------------------------
        LIBEL="Update table BEST..TRARAT"
        ISQL_BASE="BEST"
        ISQL_O=${DFILT}/${NSTEP}_${IB}_RaRatio_ISQL.log
        ISQL_QRY="exec PiRaRatio_01 ${SSD_CF}, '${CLOS_DATE}', '${CLOS_PER}', '${USR_CF}'"
        ISQL
		
		NSTEP=${NJOB}_38
        #------------------------------------------------------------------------------
        LIBEL="Truncate Table BTRAV...TRARAT"
        ISQL_BASE="BTRAV"
        ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
        ISQL_QRY="Delete BTRAV..ESID0901_TRARAT where USR_CF = '${USR_CF}'"
        ISQL

elif [ "${DATA_TYPE}" = "RATIO" ]
then
       	NSTEP=${NJOB}_40
		#------------------------------------------------------------------------------
		LIBEL="Add line number to file"
        awk -v USR_CF=${USR_CF} 'BEGIN{FS="\t"; OFS="~"}  {if (NR != 1 ) {print NR,USR_CF,$1,$2,$3,$4,$5,$6,$7} }' ${DFILT}/${NJOB}_10_${IB}_DF_${DATA_TYPE}_${SSD_CF}.dat > ${DFILT}/${NJOB}_40_${IB}_DF_${DATA_TYPE}_${SSD_CF}_AWK.dat
       
	V_MESS=3031
        NSTEP=${NJOB}_45
        #------------------------------------------------------------------------------
        LIBEL="Truncate ULAE Ratio Working Table BTRAV..TEXPRAT"
        ISQL_BASE="BTRAV"
        ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
        ISQL_QRY="Delete BTRAV..TEXPRAT where USR_CF = '${USR_CF}'"
        ISQL

	V_MESS=3031
        NSTEP=${NJOB}_50
        #------------------------------------------------------------------------------
        LIBEL="Load Risk Margin File in BTRAV...TEXPRAT"
        BCP_WAY="IN"; BCP_VER=""
        BCP_I="${DFILT}/${NJOB}_40_${IB}_DF_${DATA_TYPE}_${SSD_CF}_AWK.dat"
        BCP_TABLE="BTRAV..TEXPRAT"
        BCP

		V_MESS=3031
		NSTEP=${NJOB}_52
		# Begin isql
		#MOD01
		#------------------------------------------------------------------------------
		LIBEL="Coherence checks"
		ISQL_BASE="BEST"
		ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		ISQL_QRY="exec PiANOCOHRCHK_01 ${SSD_CF}, '${USR_CF}', 0, '${DATA_TYPE}', '${CLOS_DATE}', '${CLOS_PER}'"
		ISQL_FRES=${DFILT}/${NSTEP}_${IB}_FRES_O1.dat
		ISQL_INFO
		
		
		RET_STATUS=`cat ${ISQL_FRES}`
		if [ ${RET_STATUS} -eq 1 ]
		then
			 V_RETURNCODE=${3031}
		         trap EXCEPTION 0
		         return V_RETURNCODE
		fi

		V_MESS=3031
        NSTEP=${NJOB}_55
        #------------------------------------------------------------------------------
        LIBEL="Update table BEST..TEXPRAT"
        ISQL_BASE="BEST"
        ISQL_O=${DFILT}/${NSTEP}_${IB}_RaRatio_ISQL.log
        ISQL_QRY="exec PiExpratio_01  ${SSD_CF}, '${CLOS_DATE}', '${CLOS_PER}', '${USR_CF}'"
        ISQL
		
		NSTEP=${NJOB}_58
        #------------------------------------------------------------------------------
        LIBEL="Truncate Table BTRAV...TEXPRAT"
        ISQL_BASE="BTRAV"
        ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
        ISQL_QRY="Delete BTRAV..TEXPRAT where USR_CF = '${USR_CF}'"
        ISQL

# [01] all elif condition
elif [ "${DATA_TYPE}" = "FHNI" -o "${DATA_TYPE}" = "LKR" -o  "${DATA_TYPE}" = "FWD" ]
then

#[04]
		if [ "${DATA_TYPE}" = "FHNI" ]
		then
			V_MESS=3031
	        NSTEP=${NJOB}_60
	        #------------------------------------------------------------------------------
	        LIBEL="Add line number to file"
	        awk -v USR_CF=${USR_CF} 'BEGIN{FS="\t"; OFS="~"}  {if (NR != 1 ) {print NR,USR_CF,$1,"",$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$70,$71} }' ${DFILT}/${NJOB}_10_${IB}_DF_${DATA_TYPE}_${SSD_CF}.dat > ${DFILT}/${NJOB}_60_${IB}_DATA_FILE_AWK.dat
		else
			V_MESS=3031
	        NSTEP=${NJOB}_60
	        #------------------------------------------------------------------------------
	        LIBEL="Add line number to file"
	        awk -v USR_CF=${USR_CF} 'BEGIN{FS="\t"; OFS="~"}  {if (NR != 1 ) {print NR,USR_CF,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$70,$71,$72} }' ${DFILT}/${NJOB}_10_${IB}_DF_${DATA_TYPE}_${SSD_CF}.dat > ${DFILT}/${NJOB}_60_${IB}_DATA_FILE_AWK.dat
		fi

		V_MESS=3031
        NSTEP=${NJOB}_65
        #------------------------------------------------------------------------------
        LIBEL="Truncate FWH Ratio Working Table BTRAV..ESID0901_TFHWRATIO"
        ISQL_BASE="BTRAV"
        ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
        ISQL_QRY="Delete BTRAV..ESID0901_TFHWRATIO where USR_CF = '${USR_CF}'"
        ISQL

		V_MESS=3031
        NSTEP=${NJOB}_70
        #------------------------------------------------------------------------------
        LIBEL="Load Fund With Held File in BTRAV...ESID0901_TFHWRATIO"
        BCP_WAY="IN"; BCP_VER=""
        BCP_I="${DFILT}/${NJOB}_60_${IB}_DATA_FILE_AWK.dat"
        BCP_TABLE="BTRAV..ESID0901_TFHWRATIO"
        BCP

		V_MESS=3031
		NSTEP=${NJOB}_72
		# Begin isql
		#MOD01
		#------------------------------------------------------------------------------
		LIBEL="Coherence checks"
		ISQL_BASE="BEST"
		ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		ISQL_QRY="exec PiANOCOHRCHK_01 ${SSD_CF}, '${USR_CF}', 0, '${DATA_TYPE}', '${CLOS_DATE}', '${CLOS_PER}'"
		ISQL_FRES=${DFILT}/${NSTEP}_${IB}_FRES_O1.dat
		ISQL_INFO
		
		
		RET_STATUS=`cat ${ISQL_FRES}`
		if [ ${RET_STATUS} -eq 1 ]
		then
			 V_RETURNCODE=${V_MESS}
		         trap EXCEPTION 0
		         return V_RETURNCODE
		fi

		if [ "${DATA_TYPE}" = "LKR" ]
		then
			V_MESS=3031
			NSTEP=${NJOB}_80
			#------------------------------------------------------------------------------
			LIBEL="Update table BEST..TPATTERNSII and BEST..TPATSEGSII for LKR Data type"
			ISQL_BASE="BEST"
			ISQL_O=${DFILT}/${NSTEP}_${IB}_FHWRatio_ISQL.log
			ISQL_QRY="exec PiFhwLKIRatio_01  ${SSD_CF}, '${CLOS_DATE}', '${CLOS_PER}', '${USR_CF}'"
			ISQL
		else
			V_MESS=3031
			NSTEP=${NJOB}_81
			#------------------------------------------------------------------------------
			LIBEL="Update table BEST..TPATTERNSII and BEST..TPATSEGSII for FHNI and FWD Data type"
			ISQL_BASE="BEST"
			ISQL_O=${DFILT}/${NSTEP}_${IB}_FHWRatio_ISQL.log
			ISQL_QRY="exec PiFhwFHNIUWDRatio_01  ${SSD_CF}, '${CLOS_DATE}', '${CLOS_PER}', '${USR_CF}', '${DATA_TYPE}'"
			ISQL
			
		fi
		
		NSTEP=${NJOB}_85
        #------------------------------------------------------------------------------
        LIBEL="Truncate FWH Ratio Working Table BTRAV..ESID0901_TFHWRATIO"
        ISQL_BASE="BTRAV"
        ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
        ISQL_QRY="Delete BTRAV..ESID0901_TFHWRATIO where USR_CF = '${USR_CF}'"
        ISQL
fi

# JOBEND execute d office la fonction EXCEPTION, comme cette derniere est surchargee,
# il faut repositionner ce flag pour qu'elle retrouve son contenu initialement vide
#-----------------------------------------------------------------------------
V_TESTEXCEPTION=0

NSTEP=${NJOB}_85
# Erase temporary files
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

SUBJOBEND 

