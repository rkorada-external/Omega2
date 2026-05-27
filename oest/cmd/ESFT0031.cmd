#!/bin/ksh
#=============================================================================
# nom de l'application          : Initialization of Transition Run Off Contracts
# nom du script SHELL           : ESFT0031.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 13\01\2021
# auteur                        : Cyril AVINENS
##-----------------------------------------------------------------------------
# modifications
#  [001] ART Spira#102324  Transition I17 - Update internal assumed related to run off identification
#[002] 04/07/2022 : SPIRA 104778: JBD : Build new closing for I17S norm 
#[003] 15/11/2024 : Spira 112366: Mr JYP: transition China, manage Run Off dates with parameters
#-----------------------------------------------------------------------------
#=============================================================================

## Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT


#============
#============ get parameters from PRM 
export ESFT0030_PRM=${DPRM}/ESFT0030.prm
#set `GETPRM ${ESFT0030_PRM}`
export RECOD_DATE_LIMIT=`grep "^RECOD_DATE_LIMIT" $ESFT0030_PRM | cut -d" " -f2-  `
export RATE_INDEX_START=`grep "^RATE_INDEX_START" $ESFT0030_PRM | cut -d" " -f2-  `


# Parameters
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> NORME_CF............................................................: ${NORME_CF}"
ECHO_LOG "#===> RECOD_DATE_LIMIT....................................................: ${RECOD_DATE_LIMIT}"
ECHO_LOG "#===> RATE_INDEX_START....................................................: ${RATE_INDEX_START}"

ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> EST_IADPERICASE_STD.................................................: ${EST_IADPERICASE_STD}"
ECHO_LOG "#===> ESF_IADPERICASE_TRN.................................................: ${ESF_IADPERICASE_TRN}"
ECHO_LOG "#===> ESF_IRDPERICASE0_P_TRN..............................................: ${ESF_IRDPERICASE0_P_TRN}"
ECHO_LOG "#===> ESF_IRDPERICASE0_PNP_TRN............................................: ${ESF_IRDPERICASE0_PNP_TRN}"
ECHO_LOG "#===> ESF_ILL_BUCKET......................................................: ${ESF_ILL_BUCKET}"
ECHO_LOG "#========================================================================="


NSTEP=${NJOB}_01
#------------------------------------------------------------------------------
LIBEL="check parameters "

if [[ ${#RECOD_DATE_LIMIT} -ne 19 ]]; then
    ECHO_LOG "parameter RECOD_DATE_LIMIT should have length 19"
	STEPEND 2
fi
if [[ ${#RATE_INDEX_START} -ne 9 ]]; then
    ECHO_LOG "parameter RATE_INDEX_START should have length 9"
	STEPEND 3
fi

NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="Delete data from Working Table BTRAV..ESFT0030_ILLIQUIDITY_SEGMENT"
ISQL_BASE="BTRAV"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="Delete BTRAV..ESFT0030_ILLIQUIDITY_SEGMENT"
ISQL

NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="Load file into the working table BTRAV..ESFT0030_ILLIQUIDITY_SEGMENT"
BCP_WAY="IN"
BCP_VER=""
BCP_I="${ESF_ILL_BUCKET}"
BCP_TABLE="BTRAV..ESFT0030_ILLIQUIDITY_SEGMENT"
BCP

if [ -s "${ESF_IADPERICASE_TRN}" ]
then

NSTEP=${NJOB}_15
# Delete useless values before insert in table BTRAV..ESFT0030_IADPERICASE_STD for EST_IADPERICASE_STD
#-----------------------------------------------------------------------------
LIBEL="Delete useless values before insert in table BTRAV..ESFT0030_IADPERICASE_STD for EST_IADPERICASE_STD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE_STD} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_EST_IADPERICASE_STD.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF						3:1 - 3:,
	END_NT						4:1 - 4:,
	SEC_NF						5:1 - 5:,
	UWY_NF						6:1 - 6:,
	UW_NT						7:1 - 7:,
	CTRTYP_CT					188:1 -	188:
/KEYS
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT,
	END_NT
/OUTFILE ${SORT_O}
/REFORMAT
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT,
	END_NT,
	CTRTYP_CT
exit
EOF
SORT

NSTEP=${NJOB}_20
# Delete useless values before insert in table BTRAV..ESFT0030_TRN_IADPERICASE for ESF_IADPERICASE_TRN
#-----------------------------------------------------------------------------
LIBEL="Delete useless values before insert in table BTRAV..ESFT0030_TRN_IADPERICASE for ESF_IADPERICASE_TRN"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IADPERICASE_TRN} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ESF_IADPERICASE_TRN.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF						3:1 - 3:,
	END_NT						4:1 - 4:,
	SEC_NF						5:1 - 5:,
	UWY_NF						6:1 - 6:,
	UW_NT						7:1 - 7:,
	CTRTYP_CT					188:1 -	188:
/KEYS
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT,
	END_NT
/OUTFILE ${SORT_O}
/REFORMAT
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT,
	END_NT,
	CTRTYP_CT
exit
EOF
SORT

NSTEP=${NJOB}_25
#------------------------------------------------------------------------------
LIBEL="Delete data from Working Table BTRAV..ESFT0030_IADPERICASE_STD"
ISQL_BASE="BTRAV"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="Delete BTRAV..ESFT0030_IADPERICASE_STD"
ISQL

NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
LIBEL="Delete data from Working Table BTRAV..ESFT0030_TRN_IADPERICASE"
ISQL_BASE="BTRAV"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="Delete BTRAV..ESFT0030_TRN_IADPERICASE"
ISQL

NSTEP=${NJOB}_35
#------------------------------------------------------------------------------
LIBEL="Load file into the working table BTRAV..ESFT0030_IADPERICASE_STD"
BCP_WAY="IN"
BCP_VER=""
BCP_I="${DFILT}/${NJOB}_15_${IB}_EST_IADPERICASE_STD.dat"
BCP_TABLE="BTRAV..ESFT0030_IADPERICASE_STD"
BCP

NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
LIBEL="Load file into the working table BTRAV..ESFT0030_TRN_IADPERICASE"
BCP_WAY="IN"
BCP_VER=""
BCP_I="${DFILT}/${NJOB}_20_${IB}_ESF_IADPERICASE_TRN.dat"
BCP_TABLE="BTRAV..ESFT0030_TRN_IADPERICASE"
BCP

NSTEP=${NJOB}_45
#------------------------------------------------------------------------------
LIBEL="Update table BTRT..TSECIFRS/TCR and BFAC..TSECIFRS/TCR"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="exec PuSECIFRSCR_01 '${PARM_ICLODAT_D}', '${NORME_CF}', '${RECOD_DATE_LIMIT}','${RATE_INDEX_START}'"
ECHO_LOG "ISQL_QRY=$ISQL_QRY" 
ISQL

fi

if [ -s "${ESF_IRDPERICASE0_P_TRN}" -a -s "${ESF_IRDPERICASE0_PNP_TRN}" ]
then

NSTEP=${NJOB}_50
# Merge Transition Retro Files
#-----------------------------------------------------------------------------
LIBEL="Merge Transition Retro Files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IRDPERICASE0_P_TRN} 2000 1"
SORT_I2="${ESF_IRDPERICASE0_PNP_TRN} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ESF_IRDPERICASE_TRN_P_PNP.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/COPY
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_55
# Delete useless values before insert in table BTRAV..ESFT0030_TRN_IRDPERICASE for ESF_IRDPERICASE_TRN
#-----------------------------------------------------------------------------
LIBEL="Delete useless values before insert in table BTRAV..ESFT0030_TRN_IRDPERICASE for ESF_IRDPERICASE_TRN"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_ESF_IRDPERICASE_TRN_P_PNP.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ESF_IRDPERICASE_TRN.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	RETCTR_NF					3:1 - 3:,
	RTY_NF						6:1 - 6:
/KEYS
	RETCTR_NF,
	RTY_NF
/OUTFILE ${SORT_O}
/REFORMAT
	RETCTR_NF,
	RTY_NF
exit
EOF
SORT

NSTEP=${NJOB}_60
#------------------------------------------------------------------------------
LIBEL="Delete data from Working Table BTRAV..ESFT0030_IRDPERICASE_STD"
ISQL_BASE="BTRAV"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="Delete BTRAV..ESFT0030_IRDPERICASE_STD"
ISQL

NSTEP=${NJOB}_65
#------------------------------------------------------------------------------
LIBEL="Delete data from Working Table BTRAV..ESFT0030_TRN_IRDPERICASE"
ISQL_BASE="BTRAV"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="Delete BTRAV..ESFT0030_TRN_IRDPERICASE"
ISQL

NSTEP=${NJOB}_70
#------------------------------------------------------------------------------
LIBEL="Load file into the working table BTRAV..ESFT0030_TRN_IRDPERICASE"
BCP_WAY="IN"
BCP_VER=""
BCP_I="${DFILT}/${NJOB}_55_${IB}_ESF_IRDPERICASE_TRN.dat"
BCP_TABLE="BTRAV..ESFT0030_TRN_IRDPERICASE"
BCP

NSTEP=${NJOB}_75
#------------------------------------------------------------------------------
LIBEL="Insert data in table BTRAV..ESFT0030_IRDPERICASE_STD"
ISQL_BASE="BTRAV"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="exec BTRAV..PsRETIFRS_01 '${PARM_ICLODAT_D}', '${NORME_CF}'"
ECHO_LOG "ISQL_QRY=$ISQL_QRY" 
ISQL

NSTEP=${NJOB}_80
#------------------------------------------------------------------------------
LIBEL="Update table TRETIFRS on BRET for contracts in Scope"
ISQL_BASE="BRET"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="exec PuRETIFRS_04 '${PARM_ICLODAT_D}', '${NORME_CF}', '${RECOD_DATE_LIMIT}','${RATE_INDEX_START}'"
ECHO_LOG "ISQL_QRY=$ISQL_QRY" 
ISQL

fi

if [ ${NORME_CF} = "I17G" ] || [ ${NORME_CF} = "I17S" ]
then
NSTEP=${NJOB}_85
#------------------------------------------------------------------------------
LIBEL="Update table BFAC..TSECIFRS for internal assum related to run off"
ISQL_BASE="BFAC"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="exec PuSECIFRS_06 '${PARM_ICLODAT_D}'"
ECHO_LOG "ISQL_QRY=$ISQL_QRY" 
ISQL

NSTEP=${NJOB}_90
#------------------------------------------------------------------------------
LIBEL="Update table BTRT..TSECIFRS for internal assum related to run off"
ISQL_BASE="BTRT"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="exec PuSECIFRS_06 '${PARM_ICLODAT_D}'"
ECHO_LOG "ISQL_QRY=$ISQL_QRY" 
ISQL

fi

NSTEP=${NJOB}_95
#------------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*${IB}*.dat "

JOBEND
