#!/bin/ksh
#=========================================================================================
# Application Name      : ESTIMATION - FILE LOADING FROM EST-LIFE Cash Flow Adjustments
# SHELL script name     : ESID0891.cmd
# Creation date         : 20/03/2018
# Author                : Lilian Wernert
# description           : Asynchronous Job launched by the TP used to make conformity control of Cash Flow Adjustments
#-----------------------------------------------------------------------------
# Asynchronous Job launched by the TP 
#-----------------------------------------------------------------------------
# Change history
#------------------------------------------------------------------------------------------
#   07/06/2018   LW : [69018] -  Add the ESB_CF to the selection criteria of the query retrieving the number of anomalies
#   14/06/2018   LW : [69187] -  Delete all old entries in PERIMETER at each new file loading
#	06/02/2019   TDE : [71677] [MOD03] - Add line numbering defore SORTING to keep upload line Order
#   22/03/2019   B.L : [76191] - Management of the closing date 
#   01/10/2020   B.L : [90421] - Management of the closing date replace CLODATE_D with DBCLO_D in the condition
#   02/12/2020   B.L : [92081] - Management of the closing date - get the laste booked CLODATE_D
#   10/09/2021   B.L : [93181] - Add two new columns to TCASHFLOWADJ (UWYPLAN_NF and VRSPLAN_NF)
#===============================================================================
#=========================================================================================
# set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd
. ${DUTI}/fctws.cmd

#Input parameters
USR_CF=${2}
SSD_CF=${3}
ESB_CF=${4}
FILE_DATE_CRD=${5}
LNCH_DATE_TIME="$6 $7"

# Job Initialisation
JOBINIT

awk -F "~" 'BEGIN{OFS="~";}{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,NR}' ${DUSERS}/${PCH}ESID0891_${SSD_CF}_${ESB_CF}_${USR_CF}_${FILE_DATE_CRD}.dat > ${DFILT}/${NJOB}_AWK_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat

NSTEP=${NJOB}_10
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Selection of the largest TRN_NT from BEST..TCASHFLOWADJ"
ISQL_BASE="BEST"
ISQL_QRY="select max(TRN_NT) from BEST..TCASHFLOWADJ"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat
ISQL_RES

#The largest TRN_NT is affected to TRNMAX_NT
TRNMAX_NT=`cat ${ISQL_FRES} | sed -e s/\ //g`

# Init de la var pour le comptage des lignes
NBL_NT=0


NSTEP=${NJOB}_15
# Begin SQL
#------------------------------------------------------------------------------
LIBEL="Update the status of the file loading in TLOADEST"
ISQL_BASE="BEST"
ISQL_QRY="execute BEST..PuTLOADEST_01_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}', 1"
ISQL


NSTEP=${NJOB}_20
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Delete old error entries"
ISQL_BASE="BTRAV"
ISQL_QRY="delete BTRAV..EST_ESID0891_TCTRANO where SSD_CF=${SSD_CF} and ESB_CF=${ESB_CF} and SEG_NF = '${USR_CF}'"
ISQL


NSTEP=${NJOB}_30
# Begin shell
#------------------------------------------------------------------------------
LIBEL="Convert input file from DOS to UNIX env"
dos2unix ${DFILT}/${NJOB}_AWK_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat


NSTEP=${NJOB}_40
#Exec Ksh to Rename the New Business file
#-----------------------------------------------------------------------------
if test -s ${DFILT}/${NJOB}_AWK_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
then
  LIBEL="Exec Ksh to Rename the Cash Flow file "
  EXECKSH " mv "${DFILT}/${NJOB}_AWK_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat"
                                      ${DFILT}/${NSTEP}_${IB}_ESID0891_${SSD_CF}_${USR_CF}.dat"
fi


# --[69187]
NSTEP=${NJOB}_50
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Delete perimeter of old entries"
ISQL_BASE="BTRAV"
ISQL_QRY="delete BTRAV..EST_ESID0891_PERIMETER"
ISQL

NSTEP=${NJOB}_60
# Begin sort
#-----------------------------------------------------------------
LIBEL="Sort input file according to adj. type/contract/section/uwy/acy/trans. code/cashflow quarter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I=${DFILT}/${NJOB}_40_${IB}_ESID0891_${SSD_CF}_${USR_CF}.dat
SORT_O=${DFILT}/${NSTEP}_SORT_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS ADJTYP_CF 1:1 - 1:, CTR_NF 2:1 - 2:, SEC_NF 3:1 - 3:EN, UWY_NF 4:1 - 4:EN, ACY_NF 5:1 - 5:EN, TRNCOD_CF 6:1 - 6:, CFQUARTER_CF 7:1 - 7:
/KEYS   ADJTYP_CF, CTR_NF, SEC_NF, UWY_NF, ACY_NF, TRNCOD_CF, CFQUARTER_CF
exit
EOF
SORT


NSTEP=${NJOB}_70
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Selection of the current closing date (CLODAT_D) from BEST..TREQJOBPLAN"
ISQL_BASE="BEST"
ISQL_QRY=`CFTMP`
INPUT_TEXT ${ISQL_QRY} <<EOF
select convert(varchar,MAX(CLODAT_D),112) from BEST..TREQJOBPLAN
where CLODAT_D < (
    select MAX(CLODAT_D) from BEST..TREQJOBPLAN
    where DBCLO_D  <= getdate() and REQCOD_CT = 'D')
and REQCOD_CT = 'D'
exit
EOF
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat
ISQL_RES

# CLODAT_D is affected
CLODAT_D=`cat ${ISQL_FRES} | sed -e s/\ //g`


NSTEP=${NJOB}_80
# Begin awk
# [MOD03]
#------------------------------------------------------------------------------
LIBEL="Add relevant data to the input file"
AWK_I=${DFILT}/${NJOB}_60_SORT_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
AWK_O=${DFILT}/${NSTEP}_SORT_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
         {print \$1,\$2,\$3,\$4,\$5,\$6,\$7,\$8,\$9,\$10,\$11,0,${SSD_CF},${ESB_CF},"${USR_CF}","${CLODAT_D}",0," "," "," ",0,\$12,"",""}
exit
EOF
AWK

NSTEP=${NJOB}_90
# Introduction of TRN_NT in the Special Entries File
# [MOD03]
#----------------------------------------------------------------------------
LIBEL="Introduction of TRN_NT and lines numbers in the Special Entries File"
AWK_I=${DFILT}/${NJOB}_80_SORT_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
AWK_PARAM="TRNMAX=${TRNMAX_NT}"
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

   print \$0;
}
exit
EOF
AWK


NSTEP=${NJOB}_100
# Begin cut
# [MOD03]
#------------------------------------------------------------------------------
LIBEL="Generate cash flow file perimeter - cut and uniq"
awk '!x[$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22]++' FS="~"  ${DFILT}/${NJOB}_90_${IB}_AWK_SVC_O.dat | cut -d "~" -f1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 > ${DFILT}/${NSTEP}_UNIQ_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat


NSTEP=${NJOB}_110
# Begin shell
#------------------------------------------------------------------------------
LIBEL="Checking for duplicate row"
cat ${DFILT}/${NJOB}_80_SORT_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat | awk 'x[$3,$5,$6,$7]++' FS="~" | awk 'BEGIN{FS="~"}{print $3"~0~"$5"~1~"'${SSD_CF}'"~N~""'${USR_CF}'""~126~"$11"~1~""'${ESB_CF}'""~"$6"~"$6;}' > ${DFILT}/${NSTEP}_${IB}_TCTRANO_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat


NSTEP=${NJOB}_120
# Begin BCP IN
#------------------------------------------------------------------------------
LIBEL="Import the cash flow file in temporary perimeter base: BCP IN into BTRAV..EST_ESID0891_PERIMETER"
BCP_WAY="IN"; BCP_VER=""
#BCP_TRUNCATE=NO
BCP_I=${DFILT}/${NJOB}_100_UNIQ_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_TABLE="BTRAV..EST_ESID0891_PERIMETER"
BCP


NSTEP=${NJOB}_130
# Begin SQL
#------------------------------------------------------------------------------
LIBEL="Check for errors in BTRAV..EST_ESID0891_PERIMETER"
ISQL_BASE="BTRAV"
ISQL_QRY="execute BEST..PsCASHFLOW_01_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}'"
ISQL


NSTEP=${NJOB}_140
# Begin SQL
#------------------------------------------------------------------------------
LIBEL="Insert in BEST..TCTRANO in case of anomalies, in BEST..TCASHFLOWADJ otherwise"
ISQL_BASE="BEST"
ISQL_QRY="execute BEST..PiTCASHFLOWADJ_01_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}'"
ISQL

#-- [69018]
NSTEP=${NJOB}_150
# Begin isql
#------------------------------------------------------------------------------
LIBEL="research lines in best..TCTRANO to USR_CF and SSD_CF"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_SELECT_TCTRANO.log 
ISQL_QRY="select count(*) from BTRAV..EST_ESID0891_TCTRANO 
          where SSD_CF=${SSD_CF} and ESB_CF=${ESB_CF} and SEGTYP_CT='F' and SEG_NF = '${USR_CF}' and NUMLINE_NT != 0 and ANO_CT != 1"
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_FRES_O1.dat         
ISQL_RES

ERRORLine=`cat ${ISQL_FRES} | cut -d_ -f1| sed -e s/\ //g`
JOB_ID='best24a'

echo 'ERRORLine      = ' ${ERRORLine}
echo 'JOB_ID         = ' ${JOB_ID}
echo 'USR_CF         = ' ${USR_CF}
echo 'LNCH_DATE_TIME = ' ${LNCH_DATE_TIME}
 
#If exists lines into table best..TCTRANO, create a warning message and update TTASKQUEUE.
#----------------------------------------------------------------------------------------------
if [ "${ERRORLine}" != '0' ]  
then
    NSTEP=${NJOB}_155
	LIBEL="UPDATE btec_TTASKQUEUE to USR_CF and SSD_CF"
    ISQL_BASE="BTEC"
    ISQL_QRY="exec sp_upd_tkq_6 '${JOB_ID}','${USR_CF}','${LNCH_DATE_TIME}'"
    ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_UPDATE_TTASKQUEUE.log 
    ISQL

	LOGWRITE 1 '!!!! ERRORS detected in table best..TCTRANO  !!!!'
fi


NSTEP=${NJOB}_160
# Begin SQL
#------------------------------------------------------------------------------
LIBEL="Update the status of the file loading in TLOADEST"
ISQL_BASE="BEST"
ISQL_QRY="execute BEST..PuTLOADEST_01_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}', 10"
ISQL

#NSTEP=${NJOB}_120
#  Begin BCP IN
#------------------------------------------------------------------------------
#LIBEL="BCP IN BTRAV..EST_ESID0891_TCTRANO"
#BCP_WAY="IN"
#BCP_VER=""
#BCP_I=${DFILT}/${NJOB}_90_${IB}_TCTRANO_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
#BCP_TABLE="BTRAV..EST_ESID0891_TCTRANO"
#BCP                                                                            


NSTEP=${NJOB}_170
# Erase temporary files
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"
RMFIL ${DUSERS}/${PCH}ESID0891_${SSD_CF}_${ESB_CF}_${USR_CF}_${FILE_DATE_CRD}.dat


JOBEND
