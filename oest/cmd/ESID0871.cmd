#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - CONTROLE DE COHERENCE
#				  ajustements de plan ( fichier utilisateurs )
# nom du script SHELL		: ESID0871.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 27/02/2015
# auteur			: Capgemini (P.-É Marx)
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   Conformity control of plan adjustments
#
# Asynchronous Job launched by the TP 
#-----------------------------------------------------------------------------
# historiques des modifications
#------------------------------------------------------------------------------------------
#   05/08/2017		SA        : [31752] -  Tag BTEC..TTASKQUEUE for anomaly condition.
#		03/08/2019		R. Vieville: [74405] - Photo plan : batch/ fichier de chargement
#		25/04/2022		S.Behague :spira:82745: Chargement Ajustements Plan : erreur sur numero de lignes de la liste des anomalies
#===============================================================================
# set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd
. ${DUTI}/fctws.cmd

#Recupere arguments d'entree
USR_CF=$2
SSD_CF=$3
LNCH_DATE_TIME="$6 $7"
BATCH_MODE='batch'
#[74405] - START
ESB_CF=$4
FILE_DATE_CRD=${5}
#[74405] - END

#TP = st if you want to have extended log trace
#export TP=st

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_04
# Begin SQL
#------------------------------------------------------------------------------
LIBEL="Update the status of the file loading in TLOADEST"
ISQL_BASE="BEST"
ISQL_QRY="execute BEST..PuTLOADEST_03_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}', 1"
ISQL


NSTEP=${NJOB}_05
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Delete of old plan adjustments"
ISQL_BASE="BTRAV"
ISQL_QRY="delete BTRAV..EST_ESID0871_TESTLIFPLN
          where SSD_CF=${SSD_CF} and LSTUPDUSR_CF = '${USR_CF}'"
ISQL

NSTEP=${NJOB}_10
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Selection of the largest TRN_NT from BTRAV..EST_ESID0871_TESTLIFPLN"
ISQL_BASE="BTRAV"
ISQL_QRY="select max(TRN_NT) from BTRAV..EST_ESID0871_TESTLIFPLN"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat
ISQL_RES

#The largest TRN_NT is affected to TRNMAX_NT
TRNMAX_NT=`cat ${ISQL_FRES} | sed -e s/\ //g`

# Init de la var pour le comptage des lignes
NBL_NT=2

dos2unix ${DUSERS}/${PCH}ESID0871_${SSD_CF}_${ESB_CF}_${USR_CF}_${FILE_DATE_CRD}.dat
NSTEP=${NJOB}_12
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="REFORMAT OF ESID0871_SSD_USR file to BTRAV..EST_ESID0871_TESTLIFPLN FORMAT"

SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DUSERS}/${PCH}ESID0871_${SSD_CF}_${ESB_CF}_${USR_CF}_${FILE_DATE_CRD}.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_${SSD_CF}_${USR_CF}.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        TRNCOD_CF 2:1 - 2:,
        PLAN_NF 3:1 - 3:,
        CTR_NF 4:1 - 4:,
        END_NT 5:1 - 5:,
        SEC_NF 6:1 - 6:,
        UWY_NF 7:1 - 7:,
        UW_NT 8:1 - 8:,
        OCCYEA_NF 9:1 - 9:,
        ACY_NF 10:1 - 10:,
        SCOSTRMTH_NF 11:1 - 11:,
        SCOENDMTH_NF 12:1 - 12:,
        CUR_CF 13:1 - 13:,
        AMT_M 14:1 - 14:,
        RETCTR_NF 15:1 - 15:,
        RETEND_NT 16:1 - 16:,
        RETSEC_NF 17:1 - 17:,
        RTY_NF 18:1 - 18:,
        RETUW_NT 19:1 - 19:,
        PLC_NT 20:1 - 20:,
        RETOCCYEA_NF 21:1 - 21:,
        RETACY_NF 22:1 - 22:,
        RETSCOSTRMTH_NF 23:1 - 23:,
        RETSCOENDMTH_NF 24:1 - 24:,
        RETCUR_CF 25:1 - 25:,
        RETAMT_M 26:1 - 26:,
        COMAC_LL 27:1 - 27:,
        POSTBPC_B 28:1 - 28:
/DERIVEDFIELD SEPA "~"
/COPY
/OUTFILE ${SORT_O}
   /REFORMAT SEPA,
             SSD_CF,
             SEPA,
             PLAN_NF,
             SEPA,
             SEPA,
             SEPA,
             TRNCOD_CF,
             SEPA,
             CTR_NF,
             END_NT,
             SEC_NF,
             UWY_NF,
             UW_NT,
             OCCYEA_NF,
             ACY_NF,
             SCOSTRMTH_NF,
             SCOENDMTH_NF,
             CUR_CF,
             AMT_M,
             SEPA,
             SEPA,
             SEPA,
             SEPA,
             RETCTR_NF,
             RETEND_NT,
             RETSEC_NF,
             RTY_NF,
             RETUW_NT,
             PLC_NT,
             RETOCCYEA_NF,
             RETACY_NF,
             RETSCOSTRMTH_NF,
             RETSCOENDMTH_NF,
             RETCUR_CF,
             RETAMT_M,
             SEPA,
             SEPA,
             SEPA,
             SEPA,
             COMAC_LL,
             SEPA,
             SEPA,
             SEPA,
             SEPA,
             POSTBPC_B
exit
EOF
SORT



NSTEP=${NJOB}_15
# Delete temporary files
#----------------------------------------------------------------------------
#LIBEL="Delete temporary files"
#RMFIL ${DFILT}/${NJOB}_10_${IB}_ISQL_O.dat
#RMFIL ${DFILT}/${NJOB}_10_${IB}_ISQLRES_O.dat

NSTEP=${NJOB}_20
# Introduction of TRN_NT and LSTUPDUSR_CF in the Plan Adjustments File
#----------------------------------------------------------------------------
LIBEL="Introduction of TRN_NT and LSTUPDUSR_CF and lines numbers in the Plan Adjustments File"
AWK_I=${DFILT}/${NJOB}_12_${IB}_SORT_${SSD_CF}_${USR_CF}.dat
AWK_PARAM=" TRNMAX=${TRNMAX_NT}  USR=${USR_CF} NBL=${NBL_NT}"
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_SVC_O.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN {
 FS="~"
 OFS="~"
}
{
   TRNMAX=TRNMAX+1;
   NBL=NBL+1;
   \$1=TRNMAX"~"\$1;
   \$45=USR;
   \$47=NBL;

   print \$0;
}
exit
EOF
AWK

NSTEP=${NJOB}_25
#  BCP IN in BTRAV..EST_ESID0871_TESTLIFPLN
#------------------------------------------------------------------------------
LIBEL="BCP IN of the plan adjustments file in BTRAV..EST_ESID0871_TESTLIFPLN"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_20_${IB}_AWK_SVC_O.dat
BCP_TABLE="BTRAV..EST_ESID0871_TESTLIFPLN"
BCP

NSTEP=${NJOB}_35
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Conformity control of plan adjustments"
ISQL_BASE="BEST"
ISQL_QRY="exec PiTLIFPLN_02_O2 ${SSD_CF}, '${USR_CF}', '${BATCH_MODE}'"
ISQL

#-- [31752] 
NSTEP=${NJOB}_40
# Begin isql
#------------------------------------------------------------------------------
LIBEL="research lines in best..TCTRANO to USR_CF and SSD_CF"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_SELECT_TCTRANO.log 
ISQL_QRY="select count(*) from BEST..TCTRANO 
          where SSD_CF=${SSD_CF} and SEGTYP_CT='P' and SEG_NF = '${USR_CF}' and NUMLINE_NT != 0 and ANO_CT != 1"
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_FRES_O1.dat         
ISQL_RES

ERRORLine=`cat ${ISQL_FRES} | cut -d_ -f1| sed -e s/\ //g`
JOB_ID='best22a'

echo 'ERRORLine      = ' ${ERRORLine}
echo 'JOB_ID         = ' ${JOB_ID}
echo 'USR_CF         = ' ${USR_CF}
echo 'LNCH_DATE_TIME = ' ${LNCH_DATE_TIME}
 
# If exists lines into table best..TCTRANO, create a warning message and update TASKQUEUE.
#----------------------------------------------------------------------------------------------
if [ "${ERRORLine}" != '0' ]  
then
    NSTEP=${NJOB}_45
    LOGWRITE 1 '!!!! ERRORS detected in table best..TCTRANO  !!!!'
    # Call the Tool box function to set the status to 10-Completed with Anomaly	
    MAJOB "${JOB_ID}" "${USR_CF}" "${LNCH_DATE_TIME}"	
	STEPWARNING 10
 	NSTEP=${NJOB}_45
	# Begin SQL
	#------------------------------------------------------------------------------
	LIBEL="Update the status of the file loading in TLOADEST"
	ISQL_BASE="BEST"
	ISQL_QRY="execute BEST..PuTLOADEST_03_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}', 10"
	ISQL
else
	NSTEP=${NJOB}_45
	# Begin SQL
	#------------------------------------------------------------------------------
	LIBEL="Update the status of the file loading in TLOADEST"
	ISQL_BASE="BEST"
	ISQL_QRY="execute BEST..PuTLOADEST_03_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}', 2"
	ISQL
#-- [31752] 
fi

NSTEP=${NJOB}_50
# Erase temporary files
#-----------------------------------------------------------------------------
#LIBEL="Erase temporary files"
#RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"
RMFIL ${DUSERS}/${PCH}ESID0871_${SSD_CF}_{${ESB_CF}_${USR_CF}_${FILE_DATE_CRD}.dat

JOBEND

