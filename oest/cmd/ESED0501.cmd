#!/bin/ksh
#=========================================================================================
# Application Name      : ESTIMATION - FILE LOADING FROM EST-PC CLOSING DATA ADJUSTMENT FILE
# SHELL script name     : ESED0501.cmd
# Creation date         : 16/01/2025
# Author                : HR
# description           : Asynchronous Job launched by the TP used to load closing data adjustment file
#===============================================================================
# historique des modifications
#   16/01/2025 HR       :spira 111771: creation
#   03/07/2025 HR       :US5854 spira 112908: Add a window to load Retro plan N+1 file
#   29/10/2025 HR       :US7358 IFRS 17 - Add a window to modify CSM PAFAM Q-1 (RATECSII) - Bug fix - Copie - Copie
#   12/01/2026 HR       :US8284 IFRS 17 - Add a window to modify CSM PAFAM Q-1 (RATECSII) - Bug fix - Copie
#=========================================================================================
# set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd
. ${DUTI}/fctws.cmd


#Input parameters
FILEID=${6}
FILEDATE=`echo ${9} | xargs`
LNCH_DATE_TIME="${10} ${11}"
RUN_DATETIME=`date +"%Y%m%d"`

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_01
#------------------------------------------------------------------------------
LIBEL="Select the input file and parameters"
FILENAME=`ls ${DUSERS}/*_ESED0501_*_${FILEDATE}.dat | tail -1 | cut -d'/' -f7`

USR_CF=`echo "${FILENAME}" | cut -d"_" -f3`
SITE_CF=`echo "${FILENAME}" | cut -d"_" -f4`
NORM_CF=`echo "${FILENAME}" | cut -d"_" -f5`
CLODAT_D_QPREV=`echo "${FILENAME}" | cut -d"_" -f6`
CLOTYP_CT=`echo "${FILENAME}" | cut -d"_" -f7`
CLODATATYP_CT=`echo "${FILENAME}" | cut -d"_" -f8`

PREVCLODYYYY=${CLODAT_D_QPREV:0:4}
PREVCLODMM=${CLODAT_D_QPREV:4:2}
PREVCLODDD=${CLODAT_D_QPREV:6:2}

NSTEP=${NJOB}_05
#----------------------------------------------------------------------------
LIBEL="Executing SQL query to get the site directory"
ISQL_BASE=BREF
ISQL_QRY="SELECT lower(a.BATCHUSER_CF) from BREF..TBATCHNIGHT a WHERE a.PRDSIT_CF = '${SITE_CF}' "
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_RES.log
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQL_SELECT_VSITE.dat
ISQL_RES

VSITE=`cat ${DFILT}/${NJOB}_05_${IB}_ISQL_SELECT_VSITE.dat | xargs`

if [ "${CLODATATYP_CT}" = "CSM" ]; then 

NSTEP=${NJOB}_10
LIBEL="Copy input file to temp"
#-----------------------------------------------------------------------------------------
WINFILENAME=`head -1 ${DUSERS}/${FILENAME}`
awk -F "~" -v var1="${CLODAT_D_QPREV}" -v var2="${LNCH_DATE_TIME}" -v var3="${USR_CF}" 'BEGIN{OFS="~";} NR > 1 {print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,NR-1,NULL,NULL,NULL,var3,NULL,var3,NULL,NULL}' ${DUSERS}/${FILENAME} > ${DFILT}/${NJOB}_10_${IB}_CSM_PAFAM.dat

NSTEP=${NJOB}_15
LIBEL="Copy perm FPLC file to temp"
#-----------------------------------------------------------------------------------------
FILENAMEPLC=`ls /scor/scordata/${VSITE}/perm/${ENV_PREFIX}_ESFD5010_FPLC_EBS_*_${CLODAT_D_QPREV}.dat | tail -1`
awk -F "~" 'BEGIN{OFS="~";}{print $0}' ${FILENAMEPLC} > ${DFILT}/${NJOB}_15_${IB}_FPLC.dat

NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="Convert input file from DOS to UNIX env"
dos2unix ${DFILT}/${NJOB}_10_${IB}_CSM_PAFAM.dat

else

NSTEP=${NJOB}_10
LIBEL="Copy input file to temp"
#-----------------------------------------------------------------------------------------
WINFILENAME=`head -1 ${DUSERS}/${FILENAME}`
awk -F "~" -v var1="${CLODAT_D_QPREV}" -v var2="${LNCH_DATE_TIME}" -v var3="${USR_CF}" 'BEGIN{OFS="~";} NR > 1 {print $1,$2,$3,$4,$5,NR-1,NULL,NULL,NULL,var3,NULL,var3,NULL,NULL}' ${DUSERS}/${FILENAME} > ${DFILT}/${NJOB}_10_${IB}_RETRO_N1.dat

NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="Convert input file from DOS to UNIX env"
dos2unix ${DFILT}/${NJOB}_10_${IB}_RETRO_N1.dat

fi 

if [ "${CLODATATYP_CT}" = "CSM" ]; then 

NSTEP=${NJOB}_30
#----------------------------------------------------------------------------
LIBEL="Executing ISQL procedure to delete data from the table BTRAV..EST_ESED0501_CSM_PAFAM_ADJ"
ISQL_BASE=BTRAV
ISQL_QRY="delete BTRAV..EST_ESED0501_CSM_PAFAM_ADJ where CREUSR_CF='${USR_CF}' "
ISQL

else

NSTEP=${NJOB}_30
#----------------------------------------------------------------------------
LIBEL="Executing ISQL procedure to delete data from the table BTRAV..EST_ESED0501_RETRO_N1_ADJ"
ISQL_BASE=BTRAV
ISQL_QRY="delete BTRAV..EST_ESED0501_RETRO_N1_ADJ where CREUSR_CF='${USR_CF}' "
ISQL

fi

if [ "${CLODATATYP_CT}" = "CSM" ]; then 

NSTEP=${NJOB}_40
# Begin BCP IN
#------------------------------------------------------------------------------
LIBEL="Import in temporary base the file BCP IN into BTRAV..EST_ESED0501_CSM_PAFAM_ADJ"
BCP_WAY="IN"; BCP_VER=""
BCP_TRUNCATE=NO
BCP_I=${DFILT}/${NJOB}_10_${IB}_CSM_PAFAM.dat
BCP_TABLE="BTRAV..EST_ESED0501_CSM_PAFAM_ADJ"
BCP

else

NSTEP=${NJOB}_40
# Begin BCP IN
#------------------------------------------------------------------------------
LIBEL="Import in temporary base the file BCP IN into BTRAV..EST_ESED0501_RETRO_N1_ADJ"
BCP_WAY="IN"; BCP_VER=""
BCP_TRUNCATE=NO
BCP_I=${DFILT}/${NJOB}_10_${IB}_RETRO_N1.dat
BCP_TABLE="BTRAV..EST_ESED0501_RETRO_N1_ADJ"
BCP

fi

NSTEP=${NJOB}_50
#------------------------------------------------------------------------------
LIBEL="Execute procedure to check data"
BCP_WAY="OUT"; BCP_VER="+"
BCP_QRY="exec BEST..PtCLOADJUSMENT_btrav_ano '${SITE_CF}','${NORM_CF}','${USR_CF}','${CLODATATYP_CT}' "
BCP_O=${DFILT}/${NSTEP}_${IB}_ERRORS.dat
BCP

NBERRORS=`cat ${DFILT}/${NJOB}_50_${IB}_ERRORS.dat | head -1`

JOB_ID='best26a'
 
if [ ${NBERRORS} -gt 0 ]; then

if [ "${CLODATATYP_CT}" = "CSM" ]; then 

NSTEP=${NJOB}_60
#----------------------------------------------------------------------------
LIBEL="Copy checked lines to TCTRRETANO"
ISQL_QRY=`CFTMP`
ISQL_BASE=BEST
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
INPUT_TEXT ${ISQL_QRY} <<EOF
USE BEST
go
 INSERT INTO BEST..TCTRRETANO 
   SELECT ${FILEID}, SSD_CF, ESB_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, 
          RETUW_NT, AMT_M, CUR_CF, NUMLINE_NT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, ANO_CT, ERRTYP_CT, '${WINFILENAME}'
     FROM BTRAV..EST_ESED0501_CSM_PAFAM_ADJ 
    WHERE CREUSR_CF='${USR_CF}'
go
exit
EOF
ISQL

else

NSTEP=${NJOB}_60
#----------------------------------------------------------------------------
LIBEL="Copy checked lines to TCTRRETANO"
ISQL_QRY=`CFTMP`
ISQL_BASE=BEST
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
INPUT_TEXT ${ISQL_QRY} <<EOF
USE BEST
go
 INSERT INTO BEST..TCTRRETANO 
   SELECT ${FILEID}, null, null, null, null, null, null, null, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, 
          RETUW_NT, null, null, NUMLINE_NT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, ANO_CT, ERRTYP_CT, '${WINFILENAME}'
     FROM BTRAV..EST_ESED0501_RETRO_N1_ADJ 
    WHERE CREUSR_CF='${USR_CF}'
go
exit
EOF
ISQL

fi

NSTEP=${NJOB}_70
# If any error stop job
LOGWRITE 1 '!!!! ERRORS detected in table best..TCTRRETANO  !!!!'
# Call the Tool box function to set the status to 10-Completed with Anomaly	
MAJOB "${JOB_ID}" "${USR_CF}" "${LNCH_DATE_TIME}"	

JOBEND

fi

if [ "${CLODATATYP_CT}" != "CSM" ]; then 

NSTEP=${NJOB}_80_1
#------------------------------------------------------------------------------
LIBEL="Retro N1 Reformat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_RETRO_N1.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_RETRO_N1.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 1:1 - 1:,
        RETEND_NT 2:1 - 2:,
        RETSEC_NF 3:1 - 3:,
        RTY_NF 4:1 - 4:,
        RETUW_NT 5:1 - 5:,
		FILLER5 1:1 - 5:
/OUTFILE ${SORT_O}
/REFORMAT FILLER5
exit
EOF
SORT

NSTEP=${NJOB}_80_2
#------------------------------------------------------------------------------
LIBEL="Retro N1 Remove duplicates"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_1_${IB}_RETRO_N1.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_RETRO_N1.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 1:1 - 1:,
        RETEND_NT 2:1 - 2:,
        RETSEC_NF 3:1 - 3:,
        RTY_NF 4:1 - 4:,
        RETUW_NT 5:1 - 5:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_90
#------------------------------------------------------------------------------
LIBEL="Rename RETRO N+1 file"

  awk -F "~" 'BEGIN{OFS="~";}{print $0}' ${DFILT}/${NJOB}_80_1_${IB}_RETRO_N1.dat > ${DFILT}/${ENV_PREFIX}_ESFD5040_${NORM_CF}_RETRO_PLAN_${CLODAT_D_QPREV}.dat

NSTEP=${NJOB}_100
#------------------------------------------------------------------------------
LIBEL="Copy RETRO N+1 file"

  awk -F "~" 'BEGIN{OFS="~";}{print $0}' ${DFILT}/${ENV_PREFIX}_ESFD5040_${NORM_CF}_RETRO_PLAN_${CLODAT_D_QPREV}.dat > /scor/scordata/${VSITE}/perm/${ENV_PREFIX}_ESFD5040_${NORM_CF}_RETRO_PLAN_${CLODAT_D_QPREV}.dat

JOBEND

else

NSTEP=${NJOB}_80_1
#------------------------------------------------------------------------------
LIBEL="Select the CSM file"
FILEARCH=`ls /scor/scordata/${VSITE}/perm/${ENV_PREFIX}_ESFD3760_${NORM_CF}_UOA_PRO_STD_GTSII_CSM_CASHFLOW_${CLOTYP_CT}_${CLODAT_D_QPREV}_ARCH.dat | tail -1 | cut -d'/' -f6`
FILEORIG=`ls /scor/scordata/${VSITE}/perm/${ENV_PREFIX}_ESFD3760_${NORM_CF}_UOA_PRO_STD_GTSII_CSM_CASHFLOW_${CLOTYP_CT}_${CLODAT_D_QPREV}.dat | tail -1 | cut -d'/' -f6`

if [ "${FILEARCH}" != "" ]; then 
 UOAFILE="${FILEARCH}"
else
 if [ "${FILEORIG}" != "" ]; then
 
  awk -F "~" 'BEGIN{OFS="~";}{print $0}' /scor/scordata/${VSITE}/perm/${ENV_PREFIX}_ESFD3760_${NORM_CF}_UOA_PRO_STD_GTSII_CSM_CASHFLOW_${CLOTYP_CT}_${CLODAT_D_QPREV}.dat > /scor/scordata/${VSITE}/perm/${ENV_PREFIX}_ESFD3760_${NORM_CF}_UOA_PRO_STD_GTSII_CSM_CASHFLOW_${CLOTYP_CT}_${CLODAT_D_QPREV}_ARCH.dat

  UOAFILE="${FILEORIG}"
 else
  UOAFILE=""

NSTEP=${NJOB}_80_2
#----------------------------------------------------------------------------
LIBEL="Insert error in TCTRRETANO"
ISQL_QRY=`CFTMP`
ISQL_BASE=BEST
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
INPUT_TEXT ${ISQL_QRY} <<EOF
USE BEST
go
 INSERT INTO BEST..TCTRRETANO 
   SELECT ${FILEID}, SSD_CF, ESB_CF, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
          NULL, NULL, NULL, NUMLINE_NT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, 172, 'B', '${WINFILENAME}'
     FROM BTRAV..EST_ESED0501_CSM_PAFAM_ADJ 
    WHERE CREUSR_CF='${USR_CF}' AND NUMLINE_NT=1
go
exit
EOF
ISQL

NSTEP=${NJOB}_80_3
# If any error stop job
LOGWRITE 1 '!!!! ERRORS detected in table best..TCTRRETANO  !!!!'
# Call the Tool box function to set the status to 10-Completed with Anomaly	
MAJOB "${JOB_ID}" "${USR_CF}" "${LNCH_DATE_TIME}"	
  
  JOBEND
 fi
fi

NSTEP=${NJOB}_90
LIBEL="Copy perm CSM file to temp"
#-----------------------------------------------------------------------------------------
ECHO_LOG "CSM File taken into account ${UOAFILE}"
awk -F "~" 'BEGIN{OFS="~";}{print $0}' /scor/scordata/${VSITE}/perm/${UOAFILE} > ${DFILT}/${NJOB}_90_${IB}_UOA_PRO_STD_GTSII_CSM_CASHFLOW.dat

NSTEP=${NJOB}_100
#-------------------------------
LIBEL="Filter CSM PAFAM"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_90_${IB}_UOA_PRO_STD_GTSII_CSM_CASHFLOW.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_NON_CSM_PAFAM.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
        PATCAT_CT             52:1 -   52:,
        PATTYP_CT             53:1 -   53:
/CONDITION RESTRICTION PATCAT_CT="CSM" AND PATTYP_CT="PAFAM"
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
/OUTFILE ${SORT_O2}
/OMIT RESTRICTION
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_110
#-------------------------------
LIBEL="Split CSM PAFAM "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100_${IB}_CSM_PAFAM.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_PURE_ASSUMED.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_PROP_RETRO_AND_INTERNAL_ASSUMED_R_RI.dat 2000 1"
SORT_O3="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_NONPROP_RETRO.dat 2000 1"
SORT_O4="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_PROP_RETRO_AND_INTERNAL_ASSUMED_AI.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
        CTR_NF              8:1 - 8:,
        RETCTR_NF           24:1 - 24:,
		PLC_NT           36:1 - 36:
/CONDITION COND1 RETCTR_NF=""
/CONDITION COND2 CTR_NF!="" AND RETCTR_NF!="" AND PLC_NT!=""
/CONDITION COND3 CTR_NF=""
/CONDITION COND4 CTR_NF!="" AND RETCTR_NF!="" AND PLC_NT=""
/OUTFILE ${SORT_O}
/INCLUDE COND1
/OUTFILE ${SORT_O2}
/INCLUDE COND2
/OUTFILE ${SORT_O3}
/INCLUDE COND3
/OUTFILE ${SORT_O4}
/INCLUDE COND4
/COPY
exit
EOF
SORT


NSTEP=${NJOB}_115_1
LIBEL="Copy perm DSCCUR file to temp"
#-----------------------------------------------------------------------------------------
awk -F "~" 'BEGIN{OFS="~";}{print $0}' /scor/scordata/${VSITE}/perm/${ENV_PREFIX}_ESCJ0660_FCURSII.dat > ${DFILT}/${NJOB}_115_1_${IB}_FCURSII.dat

NSTEP=${NJOB}_115_2
#------------------------------------------------------------------------------
LIBEL="Pure assumed with match"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_CSM_PAFAM.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CUR_CF          15:1 - 15:,
        PER_CUR_CF       1:1 - 1:,
        PER_DSCCUR_CF    3:1 - 3:,
		ALLCOLS          1:1 - 27:
/joinkeys
       CUR_CF
/INFILE ${DFILT}/${NJOB}_115_1_${IB}_FCURSII.dat 2000 1 "~"
/joinkeys
       PER_CUR_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE   ${SORT_O}
/REFORMAT
        leftside:ALLCOLS, rightside:PER_DSCCUR_CF 
exit
EOF
SORT

NSTEP=${NJOB}_120
#--------------------------------
LIBEL="Split and Reformat input file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_115_2_${IB}_CSM_PAFAM.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_PURE_ASSUMED.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_PROP_RETRO_AND_INTERNAL_ASSUMED_R_RI.dat 2000 1"
SORT_O3="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_NONPROP_RETRO.dat 2000 1"
SORT_O4="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_PROP_RETRO_AND_INTERNAL_ASSUMED_AI.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
        SSD_CF            1:1 -   1:EN,
        ESB_CF            2:1 -   2:EN,
        NAT_CF            3:1 -   3:,
        CTR_NF            4:1 -   4:,
        END_NT            5:1 -   5:,
        SEC_NF            6:1 -   6:,
        UWY_NF            7:1 -   7:,
        UW_NT             8:1 -   8:,
        RETCTR_NF         9:1 -   9:,
        RETEND_NT        10:1 -  10:,
        RETSEC_NF        11:1 -  11:,
        RTY_NF           12:1 -  12:,
        RETUW_NT         13:1 -  13:,
        AMT_M            14:1 -  14:,
        CUR_CF           15:1 -  15:,
        SEG_NF           16:1 -  16:,
        LOB_CF           17:1 -  17:,
        ACCRET_CF        18:1 -  18:,
        NUMLINE_NT       19:1 -  19:,
        CLODAT_D         20:1 -  20:,
        LNCH_D           21:1 -  21:,
	    CRE_D            22:1 -  22:,	
        USR_CF           23:1 -  23:,
	    LST_D            24:1 -  24:,	
        LSTUSR_CF        25:1 -  25:,
	    ANO_CT           26:1 -  26:,	
        ERRTYP_CT        27:1 -  27:,
        DSCCUR_CF        28:1 -  28:		
/KEYS
        SSD_CF,
        ESB_CF,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        CUR_CF
/CONDITION COND1 ACCRET_CF="A"
/CONDITION COND2 ((ACCRET_CF="R" OR ACCRET_CF="RI") AND (NAT_CF="F" OR NAT_CF="P"))
/CONDITION COND3 (ACCRET_CF="R" OR ACCRET_CF="RI") AND NAT_CF="N"
/CONDITION COND4 ACCRET_CF="AI"
/DERIVEDFIELD FILLER1 "~"
/DERIVEDFIELD FILLER2 5"~"
/DERIVEDFIELD FILLER3 64"0~"
/DERIVEDFIELD FILLER5 4"~"
/DERIVEDFIELD FILLER4 7"~"
/DERIVEDFIELD NORME "${NORM_CF}~"
/DERIVEDFIELD TYPEREC "CSM~PAFAM~"
/OUTFILE ${SORT_O}
/INCLUDE COND1
/REFORMAT SSD_CF,ESB_CF,FILLER2,CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,FILLER2,CUR_CF,FILLER2,RETCTR_NF,RETEND_NT,RETSEC_NF,RTY_NF,RETUW_NT,
          FILLER2,CUR_CF,FILLER1,FILLER4,AMT_M,CUR_CF,FILLER1,SEG_NF,LOB_CF,NAT_CF,FILLER1,NORME,FILLER1,TYPEREC,FILLER1,AMT_M,FILLER3,FILLER1,DSCCUR_CF,FILLER1,AMT_M,FILLER1,NUMLINE_NT 
/OUTFILE ${SORT_O2}
/INCLUDE COND2
/REFORMAT SSD_CF,ESB_CF,FILLER2,CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,FILLER2,CUR_CF,FILLER2,RETCTR_NF,RETEND_NT,RETSEC_NF,RTY_NF,RETUW_NT,
          FILLER2,CUR_CF,FILLER1,FILLER4,AMT_M,CUR_CF,FILLER1,SEG_NF,LOB_CF,NAT_CF,FILLER1,NORME,FILLER1,TYPEREC,FILLER1,AMT_M,FILLER3,FILLER1,DSCCUR_CF,FILLER1,AMT_M,FILLER1,NUMLINE_NT 
/OUTFILE ${SORT_O3}
/INCLUDE COND3
/REFORMAT SSD_CF,ESB_CF,FILLER2,CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,FILLER2,FILLER1,FILLER2,RETCTR_NF,RETEND_NT,RETSEC_NF,RTY_NF,RETUW_NT,
          FILLER2,CUR_CF,FILLER1,FILLER4,AMT_M,CUR_CF,FILLER1,SEG_NF,LOB_CF,NAT_CF,FILLER1,NORME,FILLER1,TYPEREC,FILLER1,AMT_M,FILLER3,FILLER1,DSCCUR_CF,FILLER1,AMT_M,FILLER1,NUMLINE_NT 
/OUTFILE ${SORT_O4}
/INCLUDE COND4
/REFORMAT SSD_CF,ESB_CF,FILLER2,CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,FILLER2,CUR_CF,FILLER2,RETCTR_NF,RETEND_NT,RETSEC_NF,RTY_NF,RETUW_NT,
          FILLER2,CUR_CF,FILLER1,FILLER4,AMT_M,CUR_CF,FILLER1,SEG_NF,LOB_CF,NAT_CF,FILLER1,NORME,FILLER1,TYPEREC,FILLER1,AMT_M,FILLER3,FILLER1,DSCCUR_CF,FILLER1,AMT_M,FILLER1,NUMLINE_NT 
exit
EOF
SORT

NSTEP=${NJOB}_130
#------------------------------------------------------------------------------
LIBEL="Pure assumed with match"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_CSM_PAFAM_PURE_ASSUMED.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_PURE_ASSUMED.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
    FIELDS1           3:1 -  7:,
    CTR_NF            8:1 -  8:,
    END_NT            9:1 -  9:,
    SEC_NF           10:1 - 10:,
    UWY_NF           11:1 - 11:,
    UW_NT            12:1 - 12:,
    FIELDS2          13:1 - 17:,
    CUR_CF           18:1 - 18:,
    FIELDS3          19:1 - 23:,
    RETCTR_NF        24:1 - 24:,
    RETEND_NT        25:1 - 25:,
    RETSEC_NF        26:1 - 26:,
    RTY_NF           27:1 - 27:,
    RETUW_NT         28:1 - 28:,
    RETCUR_CF        34:1 - 34:,
    PLC_NT           36:1 - 36:,
    RTO_NF           37:1 - 37:,
    FIELDS5          38:1 - 41:,
    ACMAMT_M         43:1 - 43:EN 15/3,
    ACMCUR_CF        44:1 - 44:,
    FIELDS6          46:1 - 48:,
    NORME_CF         50:1 - 50:,
    FIELDS7          51:1 - 53:,
    PATTERN_ID       54:1 - 54:,
    AMALL_M          55:1 - 119:,
    DSCCUR_CF       121:1 - 121:,
    TOTAUX_M        123:1 - 123:EN 15/3,
    PER_COMMENT     122:1 - 122:,
    PER_SSD_CF        1:1 -  1:EN,					
    PER_ESB_CF        2:1 -  2:EN,
    PER_CTR_NF            8:1 -  8:,
    PER_END_NT            9:1 -  9:,
    PER_SEC_NF           10:1 - 10:,
    PER_UWY_NF           11:1 - 11:,
    PER_UW_NT            12:1 - 12:,
    PER_CUR_CF           18:1 - 18:,
    PER_FIELDS1       3:1 -  7:,
    PER_FIELDS2      13:1 - 17:,
    PER_FIELDS3      19:1 - 23:,
    PER_FIELDS4      29:1 - 33:,
    PER_RETAMT_M     35:1 - 35:EN 15/3,
    PER_FIELDS5      38:1 - 42:,
    PER_PRS_CF       45:1 - 45:,
    PER_TYP_CT       49:1 - 49:,
    PER_FIELDS7      51:1 - 53:,
    PER_COEF_LOB    120:1 - 120:,
	PER_ACMTRS3_NT      124:1 - 124:
/joinkeys
        CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
       ,CUR_CF
/INFILE ${DFILT}/${NJOB}_110_${IB}_CSM_PAFAM_PURE_ASSUMED.dat 2000 1 "~"
/joinkeys
        PER_CTR_NF
       ,PER_END_NT
       ,PER_SEC_NF
       ,PER_UWY_NF
       ,PER_UW_NT
       ,PER_CUR_CF
/OUTFILE   ${SORT_O}
/REFORMAT rightside:PER_SSD_CF,PER_ESB_CF,PER_FIELDS1,leftside:CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,rightside:PER_FIELDS2,leftside:CUR_CF,rightside:PER_FIELDS3,leftside:RETCTR_NF,RETEND_NT,RETSEC_NF,RTY_NF,RETUW_NT,
          rightside:PER_FIELDS4,leftside:RETCUR_CF,rightside:PER_RETAMT_M, leftside:PLC_NT,RTO_NF,rightside:PER_FIELDS5,leftside:ACMAMT_M,ACMCUR_CF,rightside:PER_PRS_CF,
		  leftside:FIELDS6,rightside:PER_TYP_CT,leftside:NORME_CF,rightside:PER_FIELDS7,leftside:PATTERN_ID,AMALL_M,rightside:PER_COEF_LOB,leftside:DSCCUR_CF,rightside:PER_COMMENT,leftside:TOTAUX_M,rightside:PER_ACMTRS3_NT
exit
EOF
SORT

NSTEP=${NJOB}_130_2
#------------------------------------------------------------------------------
LIBEL="Initial pure assumed no match"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_CSM_PAFAM_PURE_ASSUMED.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_PURE_ASSUMED.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF          8:1 - 8:,
        END_NT          9:1 - 9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        CUR_CF          18:1 - 18:,
        PER_CTR_NF       8:1 - 8:,
        PER_END_NT       9:1 - 9:,
        PER_SEC_NF      10:1 - 10:,
        PER_UWY_NF      11:1 - 11:,
        PER_UW_NT       12:1 - 12:,
        PER_CUR_CF      18:1 - 18:,
        ALL_COLS1        1:1 - 124:
/joinkeys
        CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
       ,CUR_CF
/INFILE ${DFILT}/${NJOB}_130_${IB}_CSM_PAFAM_PURE_ASSUMED.dat 2000 1 "~"
/joinkeys
        PER_CTR_NF
       ,PER_END_NT
       ,PER_SEC_NF
       ,PER_UWY_NF
       ,PER_UW_NT
       ,PER_CUR_CF
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE   ${SORT_O}
/REFORMAT
        leftside:ALL_COLS1
exit
EOF
SORT

NSTEP=${NJOB}_135_1
#------------------------------------------------------------------------------
LIBEL="Break down by PLC input rows Prop and Internal Assumed"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_CSM_PAFAM_PROP_RETRO_AND_INTERNAL_ASSUMED_R_RI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_PROP_RETRO_AND_INTERNAL_ASSUMED_R_RI.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        ALL_COLS1        1:1 - 35:,
		FILLER1          1:1 - 35:,
		FILLER2          38:1 - 125:,
       PER_RETCTR_NF   3:1 - 3:,
       PER_RETEND_NT   4:1 - 4:,
       PER_RETSEC_NF   5:1 - 5:,
       PER_RTY_NF      6:1 - 6:,
       PER_RETUW_NT    7:1 - 7:,
       PER_PLC_NT      8:1 - 8:,
	   PER_RTO_NF     10:1 - 10:,
	   PER_TAUX       16:1 - 16:
/joinkeys
        RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
/INFILE ${DFILT}/${NJOB}_15_${IB}_FPLC.dat 2000 1 "~"
/joinkeys
        PER_RETCTR_NF
       ,PER_RETEND_NT
       ,PER_RETSEC_NF
       ,PER_RTY_NF
       ,PER_RETUW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE   ${SORT_O}
/REFORMAT
        leftside:FILLER1, rightside:PER_PLC_NT, PER_RTO_NF, leftside:FILLER2, rightside:PER_TAUX
exit
EOF
SORT

NSTEP=${NJOB}_135_2
LIBEL="input rows Prop and Internal Assumed calculation by PLC rate"

awk -F"~" 'BEGIN{ FS="\~"; OFS="\~" } {if ($126 != "" && $43 != "" && $55 != "" && $123 != "") { $43 = sprintf("%.3lf", $43 * $126); $55 = sprintf("%.3lf", $55 * $126); $123 = sprintf("%.3lf", $123 * $126); } }1' ${DFILT}/${NJOB}_135_1_${IB}_CSM_PAFAM_PROP_RETRO_AND_INTERNAL_ASSUMED_R_RI.dat > ${DFILT}/${NJOB}_135_2_${IB}_CSM_PAFAM_PROP_RETRO_AND_INTERNAL_ASSUMED_R_RI.dat

NSTEP=${NJOB}_140
#------------------------------------------------------------------------------
LIBEL="Prop retro and internal assumed with match"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_135_2_${IB}_CSM_PAFAM_PROP_RETRO_AND_INTERNAL_ASSUMED_R_RI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_PROP_RETRO_AND_INTERNAL_ASSUMED_R_RI.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
    FIELDS1           3:1 -  7:,
    CTR_NF            8:1 -  8:,
    END_NT            9:1 -  9:,
    SEC_NF           10:1 - 10:,
    UWY_NF           11:1 - 11:,
    UW_NT            12:1 - 12:,
    FIELDS2          13:1 - 17:,
    CUR_CF           18:1 - 18:,
    FIELDS3          19:1 - 23:,
    RETCTR_NF        24:1 - 24:,
    RETEND_NT        25:1 - 25:,
    RETSEC_NF        26:1 - 26:,
    RTY_NF           27:1 - 27:,
    RETUW_NT         28:1 - 28:,
    RETCUR_CF        34:1 - 34:,
    PLC_NT           36:1 - 36:,
    RTO_NF           37:1 - 37:,
    FIELDS5          38:1 - 41:,
    ACMAMT_M         43:1 - 43:EN 15/3,
    ACMCUR_CF        44:1 - 44:,
    FIELDS6          46:1 - 48:,
    NORME_CF         50:1 - 50:,
    FIELDS7          51:1 - 53:,
    PATTERN_ID       54:1 - 54:,
    AMALL_M          55:1 - 119:,
    DSCCUR_CF       121:1 - 121:,
    TOTAUX_M        123:1 - 123:EN 15/3,
    PER_COMMENT     122:1 - 122:,
    PER_SSD_CF        1:1 -  1:EN,					
    PER_ESB_CF        2:1 -  2:EN,
    PER_FIELDS1       3:1 -  7:,
    PER_FIELDS2      13:1 - 17:,
    PER_FIELDS3      19:1 - 23:,
    PER_FIELDS4      29:1 - 33:,
    PER_RETAMT_M     35:1 - 35:EN 15/3,
    PER_FIELDS5      38:1 - 42:,
    PER_PRS_CF       45:1 - 45:,
    PER_TYP_CT       49:1 - 49:,
    PER_FIELDS7      51:1 - 53:,
    PER_COEF_LOB    120:1 - 120:,
	PER_ACMTRS3_NT      124:1 - 124:,
    PER_CTR_NF       8:1 - 8:,
    PER_END_NT       9:1 - 9:,
    PER_SEC_NF      10:1 - 10:,
    PER_UWY_NF      11:1 - 11:,
    PER_UW_NT       12:1 - 12:,
    PER_CUR_CF      18:1 - 18:,
    PER_RETCTR_NF       24:1 - 24:,
    PER_RETEND_NT       25:1 - 25:,
    PER_RETSEC_NF       26:1 - 26:,
    PER_RTY_NF          27:1 - 27:,
    PER_RETUW_NT        28:1 - 28:,
    PER_PLC_NT          36:1 - 36:
/joinkeys
        CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
       ,CUR_CF
       ,RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
	   ,PLC_NT
/INFILE ${DFILT}/${NJOB}_110_${IB}_CSM_PAFAM_PROP_RETRO_AND_INTERNAL_ASSUMED_R_RI.dat 2000 1 "~"
/joinkeys
        PER_CTR_NF
       ,PER_END_NT
       ,PER_SEC_NF
       ,PER_UWY_NF
       ,PER_UW_NT
       ,PER_CUR_CF
       ,PER_RETCTR_NF
       ,PER_RETEND_NT
       ,PER_RETSEC_NF
       ,PER_RTY_NF
       ,PER_RETUW_NT
	   ,PER_PLC_NT
/OUTFILE   ${SORT_O}
/REFORMAT rightside:PER_SSD_CF,PER_ESB_CF,PER_FIELDS1,leftside:CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,rightside:PER_FIELDS2,leftside:CUR_CF,rightside:PER_FIELDS3,leftside:RETCTR_NF,RETEND_NT,RETSEC_NF,RTY_NF,RETUW_NT,
          rightside:PER_FIELDS4,leftside:RETCUR_CF,rightside:PER_RETAMT_M, leftside:PLC_NT,RTO_NF,rightside:PER_FIELDS5,leftside:ACMAMT_M,ACMCUR_CF,rightside:PER_PRS_CF,
		  leftside:FIELDS6,rightside:PER_TYP_CT,leftside:NORME_CF,rightside:PER_FIELDS7,leftside:PATTERN_ID,AMALL_M,rightside:PER_COEF_LOB,leftside:DSCCUR_CF,rightside:PER_COMMENT,leftside:TOTAUX_M,rightside:PER_ACMTRS3_NT
exit
EOF
SORT

NSTEP=${NJOB}_140_1
#------------------------------------------------------------------------------
LIBEL="Prop retro and internal assumed with match"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_CSM_PAFAM_PROP_RETRO_AND_INTERNAL_ASSUMED_AI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_PROP_RETRO_AND_INTERNAL_ASSUMED_AI.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
    FIELDS1           3:1 -  7:,
    CTR_NF            8:1 -  8:,
    END_NT            9:1 -  9:,
    SEC_NF           10:1 - 10:,
    UWY_NF           11:1 - 11:,
    UW_NT            12:1 - 12:,
    FIELDS2          13:1 - 17:,
    CUR_CF           18:1 - 18:,
    FIELDS3          19:1 - 23:,
    RETCTR_NF        24:1 - 24:,
    RETEND_NT        25:1 - 25:,
    RETSEC_NF        26:1 - 26:,
    RTY_NF           27:1 - 27:,
    RETUW_NT         28:1 - 28:,
    RETCUR_CF        34:1 - 34:,
    PLC_NT           36:1 - 36:,
    RTO_NF           37:1 - 37:,
    FIELDS5          38:1 - 41:,
    ACMAMT_M         43:1 - 43:EN 15/3,
    ACMCUR_CF        44:1 - 44:,
    FIELDS6          46:1 - 48:,
    NORME_CF         50:1 - 50:,
    FIELDS7          51:1 - 53:,
    PATTERN_ID       54:1 - 54:,
    AMALL_M          55:1 - 119:,
    DSCCUR_CF       121:1 - 121:,
    TOTAUX_M        123:1 - 123:EN 15/3,
    PER_COMMENT     122:1 - 122:,
    PER_SSD_CF        1:1 -  1:EN,					
    PER_ESB_CF        2:1 -  2:EN,
    PER_FIELDS1       3:1 -  7:,
    PER_FIELDS2      13:1 - 17:,
    PER_FIELDS3      19:1 - 23:,
    PER_FIELDS4      29:1 - 33:,
    PER_RETAMT_M     35:1 - 35:EN 15/3,
    PER_FIELDS5      38:1 - 42:,
    PER_PRS_CF       45:1 - 45:,
    PER_TYP_CT       49:1 - 49:,
    PER_FIELDS7      51:1 - 53:,
    PER_COEF_LOB    120:1 - 120:,
	PER_ACMTRS3_NT      124:1 - 124:,
    PER_CTR_NF       8:1 - 8:,
    PER_END_NT       9:1 - 9:,
    PER_SEC_NF      10:1 - 10:,
    PER_UWY_NF      11:1 - 11:,
    PER_UW_NT       12:1 - 12:,
    PER_CUR_CF      18:1 - 18:,
    PER_RETCTR_NF       24:1 - 24:,
    PER_RETEND_NT       25:1 - 25:,
    PER_RETSEC_NF       26:1 - 26:,
    PER_RTY_NF          27:1 - 27:,
    PER_RETUW_NT        28:1 - 28:,
    PER_PLC_NT          36:1 - 36:
/joinkeys
        CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
       ,CUR_CF
       ,RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
/INFILE ${DFILT}/${NJOB}_110_${IB}_CSM_PAFAM_PROP_RETRO_AND_INTERNAL_ASSUMED_AI.dat 2000 1 "~"
/joinkeys
        PER_CTR_NF
       ,PER_END_NT
       ,PER_SEC_NF
       ,PER_UWY_NF
       ,PER_UW_NT
       ,PER_CUR_CF
       ,PER_RETCTR_NF
       ,PER_RETEND_NT
       ,PER_RETSEC_NF
       ,PER_RTY_NF
       ,PER_RETUW_NT
/OUTFILE   ${SORT_O}
/REFORMAT rightside:PER_SSD_CF,PER_ESB_CF,PER_FIELDS1,leftside:CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,rightside:PER_FIELDS2,leftside:CUR_CF,rightside:PER_FIELDS3,leftside:RETCTR_NF,RETEND_NT,RETSEC_NF,RTY_NF,RETUW_NT,
          rightside:PER_FIELDS4,leftside:RETCUR_CF,rightside:PER_RETAMT_M, leftside:PLC_NT,RTO_NF,rightside:PER_FIELDS5,leftside:ACMAMT_M,ACMCUR_CF,rightside:PER_PRS_CF,
		  leftside:FIELDS6,rightside:PER_TYP_CT,leftside:NORME_CF,rightside:PER_FIELDS7,leftside:PATTERN_ID,AMALL_M,rightside:PER_COEF_LOB,leftside:DSCCUR_CF,rightside:PER_COMMENT,leftside:TOTAUX_M,rightside:PER_ACMTRS3_NT
exit
EOF
SORT

NSTEP=${NJOB}_140_2
#------------------------------------------------------------------------------
LIBEL="Initial Prop retro and internal assumed no match"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_CSM_PAFAM_PROP_RETRO_AND_INTERNAL_ASSUMED_R_RI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_PROP_RETRO_AND_INTERNAL_ASSUMED_R_RI.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF          8:1 - 8:,
        END_NT          9:1 - 9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        CUR_CF          18:1 - 18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
		PLC_NT          36:1 - 36:,
        PER_CTR_NF       8:1 - 8:,
        PER_END_NT       9:1 - 9:,
        PER_SEC_NF      10:1 - 10:,
        PER_UWY_NF      11:1 - 11:,
        PER_UW_NT       12:1 - 12:,
        PER_CUR_CF      18:1 - 18:,
        PER_RETCTR_NF       24:1 - 24:,
        PER_RETEND_NT       25:1 - 25:,
        PER_RETSEC_NF       26:1 - 26:,
        PER_RTY_NF          27:1 - 27:,
        PER_RETUW_NT        28:1 - 28:,
		PER_PLC_NT          36:1 - 36:,
        ALL_COLS1        1:1 - 124:
/joinkeys
        CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
       ,CUR_CF
       ,RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
	   ,PLC_NT
/INFILE ${DFILT}/${NJOB}_140_${IB}_CSM_PAFAM_PROP_RETRO_AND_INTERNAL_ASSUMED_R_RI.dat 2000 1 "~"
/joinkeys
        PER_CTR_NF
       ,PER_END_NT
       ,PER_SEC_NF
       ,PER_UWY_NF
       ,PER_UW_NT
       ,PER_CUR_CF
       ,PER_RETCTR_NF
       ,PER_RETEND_NT
       ,PER_RETSEC_NF
       ,PER_RTY_NF
       ,PER_RETUW_NT
	   ,PER_PLC_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE   ${SORT_O}
/REFORMAT
        leftside:ALL_COLS1
exit
EOF
SORT

NSTEP=${NJOB}_140_3
#------------------------------------------------------------------------------
LIBEL="Initial Prop retro and internal assumed no match"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_CSM_PAFAM_PROP_RETRO_AND_INTERNAL_ASSUMED_AI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_PROP_RETRO_AND_INTERNAL_ASSUMED_AI.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF          8:1 - 8:,
        END_NT          9:1 - 9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        CUR_CF          18:1 - 18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
		PLC_NT          36:1 - 36:,
        PER_CTR_NF       8:1 - 8:,
        PER_END_NT       9:1 - 9:,
        PER_SEC_NF      10:1 - 10:,
        PER_UWY_NF      11:1 - 11:,
        PER_UW_NT       12:1 - 12:,
        PER_CUR_CF      18:1 - 18:,
        PER_RETCTR_NF       24:1 - 24:,
        PER_RETEND_NT       25:1 - 25:,
        PER_RETSEC_NF       26:1 - 26:,
        PER_RTY_NF          27:1 - 27:,
        PER_RETUW_NT        28:1 - 28:,
		PER_PLC_NT          36:1 - 36:,
        ALL_COLS1        1:1 - 124:
/joinkeys
        CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
       ,CUR_CF
       ,RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
/INFILE ${DFILT}/${NJOB}_140_1_${IB}_CSM_PAFAM_PROP_RETRO_AND_INTERNAL_ASSUMED_AI.dat 2000 1 "~"
/joinkeys
        PER_CTR_NF
       ,PER_END_NT
       ,PER_SEC_NF
       ,PER_UWY_NF
       ,PER_UW_NT
       ,PER_CUR_CF
       ,PER_RETCTR_NF
       ,PER_RETEND_NT
       ,PER_RETSEC_NF
       ,PER_RTY_NF
       ,PER_RETUW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE   ${SORT_O}
/REFORMAT
        leftside:ALL_COLS1
exit
EOF
SORT

NSTEP=${NJOB}_145_1
#------------------------------------------------------------------------------
LIBEL="Break down by PLC input rows Non Prop retro"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_CSM_PAFAM_NONPROP_RETRO.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_NONPROP_RETRO.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        ALL_COLS1        1:1 - 35:,
		FILLER1          1:1 - 35:,
		FILLER2          38:1 - 125:,
       PER_RETCTR_NF   3:1 - 3:,
       PER_RETEND_NT   4:1 - 4:,
       PER_RETSEC_NF   5:1 - 5:,
       PER_RTY_NF      6:1 - 6:,
       PER_RETUW_NT    7:1 - 7:,
       PER_PLC_NT      8:1 - 8:,
	   PER_RTO_NF     10:1 - 10:,
	   PER_TAUX       16:1 - 16:
	   
/joinkeys
        RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
/INFILE ${DFILT}/${NJOB}_15_${IB}_FPLC.dat 2000 1 "~"
/joinkeys
        PER_RETCTR_NF
       ,PER_RETEND_NT
       ,PER_RETSEC_NF
       ,PER_RTY_NF
       ,PER_RETUW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE   ${SORT_O}
/REFORMAT
        leftside:FILLER1, rightside:PER_PLC_NT, PER_RTO_NF, leftside:FILLER2, rightside:PER_TAUX
exit
EOF
SORT

NSTEP=${NJOB}_145_2
LIBEL="PLC input rows Non Prop retro calculation by PLC rate"

awk -F"~" 'BEGIN{ FS="\~"; OFS="\~" } {if ($126 != "" && $43 != "" && $55 != "" && $123 != "") { $43 = sprintf("%.3lf", $43 * $126); $55 = sprintf("%.3lf", $55 * $126); $123 = sprintf("%.3lf", $123 * $126); } }1' ${DFILT}/${NJOB}_145_1_${IB}_CSM_PAFAM_NONPROP_RETRO.dat > ${DFILT}/${NJOB}_145_2_${IB}_CSM_PAFAM_NONPROP_RETRO.dat

NSTEP=${NJOB}_150
#------------------------------------------------------------------------------
LIBEL="Non prop with match"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_145_2_${IB}_CSM_PAFAM_NONPROP_RETRO.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_NONPROP_RETRO.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
    FIELDS1           3:1 -  7:,
    CTR_NF            8:1 -  8:,
    END_NT            9:1 -  9:,
    SEC_NF           10:1 - 10:,
    UWY_NF           11:1 - 11:,
    UW_NT            12:1 - 12:,
    FIELDS2          13:1 - 17:,
    CUR_CF           18:1 - 18:,
    FIELDS3          19:1 - 23:,
    RETCTR_NF        24:1 - 24:,
    RETEND_NT        25:1 - 25:,
    RETSEC_NF        26:1 - 26:,
    RTY_NF           27:1 - 27:,
    RETUW_NT         28:1 - 28:,
    RETCUR_CF        34:1 - 34:,
    PLC_NT           36:1 - 36:,
    RTO_NF           37:1 - 37:,
    FIELDS5          38:1 - 41:,
    ACMAMT_M         43:1 - 43:EN 15/3,
    ACMCUR_CF        44:1 - 44:,
    FIELDS6          46:1 - 48:,
    NORME_CF         50:1 - 50:,
    FIELDS7          51:1 - 53:,
    PATTERN_ID       54:1 - 54:,
    AMALL_M          55:1 - 119:,
    DSCCUR_CF       121:1 - 121:,
    TOTAUX_M        123:1 - 123:EN 15/3,
    PER_COMMENT     122:1 - 122:,
    PER_SSD_CF        1:1 -  1:EN,					
    PER_ESB_CF        2:1 -  2:EN,
    PER_FIELDS1       3:1 -  7:,
    PER_FIELDS2      13:1 - 17:,
    PER_FIELDS3      19:1 - 23:,
    PER_FIELDS4      29:1 - 33:,
    PER_RETAMT_M     35:1 - 35:EN 15/3,
    PER_FIELDS5      38:1 - 42:,
    PER_PRS_CF       45:1 - 45:,
    PER_TYP_CT       49:1 - 49:,
    PER_FIELDS7      51:1 - 53:,
    PER_COEF_LOB    120:1 - 120:,
	PER_ACMTRS3_NT      124:1 - 124:,
    PER_RETCTR_NF       24:1 - 24:,
    PER_RETEND_NT       25:1 - 25:,
    PER_RETSEC_NF       26:1 - 26:,
    PER_RTY_NF          27:1 - 27:,
    PER_RETUW_NT        28:1 - 28:,
    PER_RETCUR_CF       34:1 - 34:,
    PER_PLC_NT          36:1 - 36:
/joinkeys
        RETCUR_CF
       ,RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
	   ,PLC_NT
/INFILE ${DFILT}/${NJOB}_110_${IB}_CSM_PAFAM_NONPROP_RETRO.dat 2000 1 "~"
/joinkeys
        PER_RETCUR_CF
       ,PER_RETCTR_NF
       ,PER_RETEND_NT
       ,PER_RETSEC_NF
       ,PER_RTY_NF
       ,PER_RETUW_NT
	   ,PER_PLC_NT
/OUTFILE   ${SORT_O}
/REFORMAT rightside:PER_SSD_CF,PER_ESB_CF,PER_FIELDS1,leftside:CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,rightside:PER_FIELDS2,leftside:CUR_CF,rightside:PER_FIELDS3,leftside:RETCTR_NF,RETEND_NT,RETSEC_NF,RTY_NF,RETUW_NT,
          rightside:PER_FIELDS4,leftside:RETCUR_CF,rightside:PER_RETAMT_M, leftside:PLC_NT,RTO_NF,rightside:PER_FIELDS5,leftside:ACMAMT_M,ACMCUR_CF,rightside:PER_PRS_CF,
		  leftside:FIELDS6,rightside:PER_TYP_CT,leftside:NORME_CF,rightside:PER_FIELDS7,leftside:PATTERN_ID,AMALL_M,rightside:PER_COEF_LOB,leftside:DSCCUR_CF,rightside:PER_COMMENT,leftside:TOTAUX_M,rightside:PER_ACMTRS3_NT
exit
EOF
SORT

NSTEP=${NJOB}_150_2
#------------------------------------------------------------------------------
LIBEL="Initial Non prop no match"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_CSM_PAFAM_NONPROP_RETRO.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_NONPROP_RETRO.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS RETCUR_CF       34:1 - 34:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        PER_RETCUR_CF       34:1 - 34:,
        PER_RETCTR_NF       24:1 - 24:,
        PER_RETEND_NT       25:1 - 25:,
        PER_RETSEC_NF       26:1 - 26:,
        PER_RTY_NF          27:1 - 27:,
        PER_RETUW_NT        28:1 - 28:,
        ALL_COLS1        1:1 - 124:
/joinkeys
        RETCUR_CF
       ,RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
/INFILE ${DFILT}/${NJOB}_150_${IB}_CSM_PAFAM_NONPROP_RETRO.dat 2000 1 "~"
/joinkeys
        PER_RETCUR_CF
       ,PER_RETCTR_NF
       ,PER_RETEND_NT
       ,PER_RETSEC_NF
       ,PER_RTY_NF
       ,PER_RETUW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE   ${SORT_O}
/REFORMAT
        leftside:ALL_COLS1
exit
EOF
SORT

NSTEP=${NJOB}_165
#------------------------------------------------------------------------------
LIBEL="Merge input rows"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_CSM_PAFAM_PURE_ASSUMED.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_135_2_${IB}_CSM_PAFAM_PROP_RETRO_AND_INTERNAL_ASSUMED_R_RI.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_145_2_${IB}_CSM_PAFAM_NONPROP_RETRO.dat 2000 1"
SORT_I4="${DFILT}/${NJOB}_120_${IB}_CSM_PAFAM_PROP_RETRO_AND_INTERNAL_ASSUMED_AI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_MERGED.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF          8:1 - 8:,
        END_NT          9:1 - 9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        CUR_CF          18:1 - 18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
		RETCUR_CF       34:1 - 34:,
		PLC_NT          36:1 - 36:,
        ALL_COLS1        1:1 - 125:
/KEYS   CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
       ,CUR_CF
       ,RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
	   ,RETCUR_CF
	   ,PLC_NT
/OUTFILE   ${SORT_O}
/REFORMAT
        ALL_COLS1
exit
EOF
SORT

NSTEP=${NJOB}_170
#------------------------------------------------------------------------------
LIBEL="Filter input rows no match"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_165_${IB}_CSM_PAFAM_MERGED.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_NEW_ROWS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF          8:1 - 8:,
        END_NT          9:1 - 9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        CUR_CF          18:1 - 18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
		RETCUR_CF       34:1 - 34:,
		PLC_NT          36:1 - 36:,
        PER_CTR_NF       8:1 - 8:,
        PER_END_NT       9:1 - 9:,
        PER_SEC_NF      10:1 - 10:,
        PER_UWY_NF      11:1 - 11:,
        PER_UW_NT       12:1 - 12:,
        PER_CUR_CF      18:1 - 18:,
        PER_RETCTR_NF       24:1 - 24:,
        PER_RETEND_NT       25:1 - 25:,
        PER_RETSEC_NF       26:1 - 26:,
        PER_RTY_NF          27:1 - 27:,
        PER_RETUW_NT        28:1 - 28:,
		PER_RETCUR_CF       34:1 - 34:,
		PER_PLC_NT          36:1 - 36:,
        ALL_COLS1        1:1 - 125:
/joinkeys
        CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
       ,RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
	   ,PLC_NT
/INFILE ${DFILT}/${NJOB}_100_${IB}_CSM_PAFAM.dat 2000 1 "~"
/joinkeys
        PER_CTR_NF
       ,PER_END_NT
       ,PER_SEC_NF
       ,PER_UWY_NF
       ,PER_UW_NT
       ,PER_RETCTR_NF
       ,PER_RETEND_NT
       ,PER_RETSEC_NF
       ,PER_RTY_NF
       ,PER_RETUW_NT
	   ,PER_PLC_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE   ${SORT_O}
/REFORMAT
        leftside:ALL_COLS1
exit
EOF
SORT

NSTEP=${NJOB}_171
#------------------------------------------------------------------------------
LIBEL="Filter input rows no match"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_115_2_${IB}_CSM_PAFAM.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_NEW_ROWS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
        SSD_CF            1:1 -   1:EN,
        ESB_CF            2:1 -   2:EN,
        NAT_CF            3:1 -   3:,
        CTR_NF            4:1 -   4:,
        END_NT            5:1 -   5:,
        SEC_NF            6:1 -   6:,
        UWY_NF            7:1 -   7:,
        UW_NT             8:1 -   8:,
        RETCTR_NF         9:1 -   9:,
        RETEND_NT        10:1 -  10:,
        RETSEC_NF        11:1 -  11:,
        RTY_NF           12:1 -  12:,
        RETUW_NT         13:1 -  13:,
        AMT_M            14:1 -  14:,
        CUR_CF           15:1 -  15:,
        SEG_NF           16:1 -  16:,
        LOB_CF           17:1 -  17:,
        ACCRET_CF        18:1 -  18:,
        NUMLINE_NT       19:1 -  19:,
        CLODAT_D         20:1 -  20:,
        LNCH_D           21:1 -  21:,
	    CRE_D            22:1 -  22:,	
        USR_CF           23:1 -  23:,
	    LST_D            24:1 -  24:,	
        LSTUSR_CF        25:1 -  25:,
	    ANO_CT           26:1 -  26:,	
        ERRTYP_CT        27:1 -  27:,
        DSCCUR_CF        28:1 -  28:,	
        PER_CTR_NF       8:1 - 8:,
        PER_END_NT       9:1 - 9:,
        PER_SEC_NF      10:1 - 10:,
        PER_UWY_NF      11:1 - 11:,
        PER_UW_NT       12:1 - 12:,
        PER_CUR_CF      18:1 - 18:,
        PER_RETCTR_NF       24:1 - 24:,
        PER_RETEND_NT       25:1 - 25:,
        PER_RETSEC_NF       26:1 - 26:,
        PER_RTY_NF          27:1 - 27:,
        PER_RETUW_NT        28:1 - 28:,
		PER_RETCUR_CF       34:1 - 34:,
		PER_PLC_NT          36:1 - 36:,
        ALL_COLS1        1:1 - 27:
/joinkeys
        CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
       ,RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
	   ,CUR_CF
/INFILE ${DFILT}/${NJOB}_100_${IB}_CSM_PAFAM.dat 2000 1 "~"
/joinkeys
        PER_CTR_NF
       ,PER_END_NT
       ,PER_SEC_NF
       ,PER_UWY_NF
       ,PER_UW_NT
       ,PER_RETCTR_NF
       ,PER_RETEND_NT
       ,PER_RETSEC_NF
       ,PER_RTY_NF
       ,PER_RETUW_NT
	   ,PER_CUR_CF
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE   ${SORT_O}
/REFORMAT
        leftside:ALL_COLS1
exit
EOF
SORT

NSTEP=${NJOB}_171_2
#------------------------------------------------------------------------------
LIBEL="Filter input rows with match"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_115_2_${IB}_CSM_PAFAM.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_NEW_ROWS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
        SSD_CF            1:1 -   1:EN,
        ESB_CF            2:1 -   2:EN,
        NAT_CF            3:1 -   3:,
        CTR_NF            4:1 -   4:,
        END_NT            5:1 -   5:,
        SEC_NF            6:1 -   6:,
        UWY_NF            7:1 -   7:,
        UW_NT             8:1 -   8:,
        RETCTR_NF         9:1 -   9:,
        RETEND_NT        10:1 -  10:,
        RETSEC_NF        11:1 -  11:,
        RTY_NF           12:1 -  12:,
        RETUW_NT         13:1 -  13:,
        AMT_M            14:1 -  14:,
        CUR_CF           15:1 -  15:,
        SEG_NF           16:1 -  16:,
        LOB_CF           17:1 -  17:,
        ACCRET_CF        18:1 -  18:,
        NUMLINE_NT       19:1 -  19:,
        CLODAT_D         20:1 -  20:,
        LNCH_D           21:1 -  21:,
	    CRE_D            22:1 -  22:,	
        USR_CF           23:1 -  23:,
	    LST_D            24:1 -  24:,	
        LSTUSR_CF        25:1 -  25:,
	    ANO_CT           26:1 -  26:,	
        ERRTYP_CT        27:1 -  27:,
        DSCCUR_CF        28:1 -  28:,	
        PER_CTR_NF       8:1 - 8:,
        PER_END_NT       9:1 - 9:,
        PER_SEC_NF      10:1 - 10:,
        PER_UWY_NF      11:1 - 11:,
        PER_UW_NT       12:1 - 12:,
        PER_CUR_CF      18:1 - 18:,
        PER_RETCTR_NF       24:1 - 24:,
        PER_RETEND_NT       25:1 - 25:,
        PER_RETSEC_NF       26:1 - 26:,
        PER_RTY_NF          27:1 - 27:,
        PER_RETUW_NT        28:1 - 28:,
		PER_RETCUR_CF       34:1 - 34:,
		PER_PLC_NT          36:1 - 36:,
        ALL_COLS1        1:1 - 27:
/joinkeys
        CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
       ,RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
	   ,CUR_CF
/INFILE ${DFILT}/${NJOB}_100_${IB}_CSM_PAFAM.dat 2000 1 "~"
/joinkeys
        PER_CTR_NF
       ,PER_END_NT
       ,PER_SEC_NF
       ,PER_UWY_NF
       ,PER_UW_NT
       ,PER_RETCTR_NF
       ,PER_RETEND_NT
       ,PER_RETSEC_NF
       ,PER_RTY_NF
       ,PER_RETUW_NT
	   ,PER_CUR_CF
/OUTFILE   ${SORT_O}
/REFORMAT
        leftside:ALL_COLS1
exit
EOF
SORT

NSTEP=${NJOB}_172_1
#------------------------------------------------------------------------------
LIBEL="Information new rows ano management step 1"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_171_${IB}_CSM_PAFAM_NEW_ROWS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_NEW_ROWS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
        SSD_CF            1:1 -   1:EN,
        ESB_CF            2:1 -   2:EN,
        NAT_CF            3:1 -   3:,
        CTR_NF            4:1 -   4:,
        END_NT            5:1 -   5:,
        SEC_NF            6:1 -   6:,
        UWY_NF            7:1 -   7:,
        UW_NT             8:1 -   8:,
        RETCTR_NF         9:1 -   9:,
        RETEND_NT        10:1 -  10:,
        RETSEC_NF        11:1 -  11:,
        RTY_NF           12:1 -  12:,
        RETUW_NT         13:1 -  13:,
        AMT_M            14:1 -  14:,
        CUR_CF           15:1 -  15:,
        SEG_NF           16:1 -  16:,
        LOB_CF           17:1 -  17:,
        ACCRET_CF        18:1 -  18:,
        NUMLINE_NT       19:1 -  19:,
        CLODAT_D         20:1 -  20:,
        LNCH_D           21:1 -  21:,
	    CRE_D            22:1 -  22:,	
        USR_CF           23:1 -  23:,
	    LST_D            24:1 -  24:,	
        LSTUSR_CF        25:1 -  25:,
	    ANO_CT           26:1 -  26:,	
        ERRTYP_CT        27:1 -  27:,
        ALL_COLS1        1:1 - 25:
/KEYS
        CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
       ,RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
	   ,CUR_CF
/DERIVEDFIELD ANOINFO "20066~I"
/OUTFILE   ${SORT_O}
/REFORMAT
        ALL_COLS1, ANOINFO
exit
EOF
SORT

NSTEP=${NJOB}_172_2
#------------------------------------------------------------------------------
LIBEL="Information new rows ano management step 2 rows with match"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_171_2_${IB}_CSM_PAFAM_NEW_ROWS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_NEW_ROWS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
        SSD_CF            1:1 -   1:EN,
        ESB_CF            2:1 -   2:EN,
        NAT_CF            3:1 -   3:,
        CTR_NF            4:1 -   4:,
        END_NT            5:1 -   5:,
        SEC_NF            6:1 -   6:,
        UWY_NF            7:1 -   7:,
        UW_NT             8:1 -   8:,
        RETCTR_NF         9:1 -   9:,
        RETEND_NT        10:1 -  10:,
        RETSEC_NF        11:1 -  11:,
        RTY_NF           12:1 -  12:,
        RETUW_NT         13:1 -  13:,
        AMT_M            14:1 -  14:,
        CUR_CF           15:1 -  15:,
        SEG_NF           16:1 -  16:,
        LOB_CF           17:1 -  17:,
        ACCRET_CF        18:1 -  18:,
        NUMLINE_NT       19:1 -  19:,
        CLODAT_D         20:1 -  20:,
        LNCH_D           21:1 -  21:,
	    CRE_D            22:1 -  22:,	
        USR_CF           23:1 -  23:,
	    LST_D            24:1 -  24:,	
        LSTUSR_CF        25:1 -  25:,
	    ANO_CT           26:1 -  26:,	
        ERRTYP_CT        27:1 -  27:,
        ALL_COLS1        1:1 - 25:
/KEYS
        CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
       ,RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
	   ,CUR_CF
/DERIVEDFIELD ANOINFO "~"
/OUTFILE   ${SORT_O}
/REFORMAT
        ALL_COLS1, ANOINFO
exit
EOF
SORT

NSTEP=${NJOB}_172_3
#------------------------------------------------------------------------------
LIBEL="Information new rows ano management step 3 merge"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_172_1_${IB}_CSM_PAFAM_NEW_ROWS.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_172_2_${IB}_CSM_PAFAM_NEW_ROWS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_NEW_ROWS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
        SSD_CF            1:1 -   1:EN,
        ESB_CF            2:1 -   2:EN,
        NAT_CF            3:1 -   3:,
        CTR_NF            4:1 -   4:,
        END_NT            5:1 -   5:,
        SEC_NF            6:1 -   6:,
        UWY_NF            7:1 -   7:,
        UW_NT             8:1 -   8:,
        RETCTR_NF         9:1 -   9:,
        RETEND_NT        10:1 -  10:,
        RETSEC_NF        11:1 -  11:,
        RTY_NF           12:1 -  12:,
        RETUW_NT         13:1 -  13:,
        AMT_M            14:1 -  14:,
        CUR_CF           15:1 -  15:,
        SEG_NF           16:1 -  16:,
        LOB_CF           17:1 -  17:,
        ACCRET_CF        18:1 -  18:,
        NUMLINE_NT       19:1 -  19:,
        CLODAT_D         20:1 -  20:,
        LNCH_D           21:1 -  21:,
	    CRE_D            22:1 -  22:,	
        USR_CF           23:1 -  23:,
	    LST_D            24:1 -  24:,	
        LSTUSR_CF        25:1 -  25:,
	    ANO_CT           26:1 -  26:,	
        ERRTYP_CT        27:1 -  27:,
        ALL_COLS1        1:1 - 27:
/KEYS
        CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
       ,RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
	   ,CUR_CF
/OUTFILE   ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_172_4
#------------------------------------------------------------------------------
LIBEL="Information new rows ano management step 4 summarize"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_172_3_${IB}_CSM_PAFAM_NEW_ROWS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_NEW_ROWS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
        SSD_CF            1:1 -   1:EN,
        ESB_CF            2:1 -   2:EN,
        NAT_CF            3:1 -   3:,
        CTR_NF            4:1 -   4:,
        END_NT            5:1 -   5:,
        SEC_NF            6:1 -   6:,
        UWY_NF            7:1 -   7:,
        UW_NT             8:1 -   8:,
        RETCTR_NF         9:1 -   9:,
        RETEND_NT        10:1 -  10:,
        RETSEC_NF        11:1 -  11:,
        RTY_NF           12:1 -  12:,
        RETUW_NT         13:1 -  13:,
        AMT_M            14:1 -  14:,
        CUR_CF           15:1 -  15:,
        SEG_NF           16:1 -  16:,
        LOB_CF           17:1 -  17:,
        ACCRET_CF        18:1 -  18:,
        NUMLINE_NT       19:1 -  19:,
        CLODAT_D         20:1 -  20:,
        LNCH_D           21:1 -  21:,
	    CRE_D            22:1 -  22:,	
        USR_CF           23:1 -  23:,
	    LST_D            24:1 -  24:,	
        LSTUSR_CF        25:1 -  25:,
		ANO_CT           26:1 -  26:,
		ERRTYP_CT        27:1 -  27:,
        ALL_COLS1        1:1 - 27:
/KEYS
        CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
       ,RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
	   ,CUR_CF
/SUMMARIZE
/OUTFILE   ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_172_4
#----------------------------------------------------------------------------
LIBEL="Executing ISQL procedure to delete data from the table BTRAV..EST_ESED0501_CSM_PAFAM_ADJ"
ISQL_BASE=BTRAV
ISQL_QRY="delete BTRAV..EST_ESED0501_CSM_PAFAM_ADJ where CREUSR_CF='${USR_CF}' "
ISQL

NSTEP=${NJOB}_172_5
# Begin BCP IN
#------------------------------------------------------------------------------
LIBEL="Import in temporary base the file BCP IN into BTRAV..EST_ESED0501_CSM_PAFAM_ADJ"
BCP_WAY="IN"; BCP_VER=""
BCP_TRUNCATE=NO
BCP_I=${DFILT}/${NJOB}_172_4_${IB}_CSM_PAFAM_NEW_ROWS.dat
BCP_TABLE="BTRAV..EST_ESED0501_CSM_PAFAM_ADJ"
BCP


NSTEP=${NJOB}_172_6
#----------------------------------------------------------------------------
LIBEL="Copy checked lines to TCTRRETANO"
ISQL_QRY=`CFTMP`
ISQL_BASE=BEST
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
INPUT_TEXT ${ISQL_QRY} <<EOF
USE BEST
go
 INSERT INTO BEST..TCTRRETANO 
   SELECT ${FILEID}, SSD_CF, ESB_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, 
          RETUW_NT, AMT_M, CUR_CF, NUMLINE_NT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, ANO_CT, ERRTYP_CT, '${WINFILENAME}'
     FROM BTRAV..EST_ESED0501_CSM_PAFAM_ADJ 
    WHERE CREUSR_CF='${USR_CF}'
go
exit
EOF
ISQL

NSTEP=${NJOB}_175
#--------------------------------
LIBEL="Reformat input rows no match"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_170_${IB}_CSM_PAFAM_NEW_ROWS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_NEW_ROWS.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
    SSD_CF            1:1 -  1:EN,
    ESB_CF            2:1 -  2:EN,
    CTR_NF            8:1 -  8:,
    END_NT            9:1 -  9:EN,
    SEC_NF           10:1 - 10:,
    UWY_NF           11:1 - 11:,
    UW_NT            12:1 - 12:,
    CUR_CF           18:1 - 18:,
    RETCTR_NF        24:1 - 24:,
    RETEND_NT        25:1 - 25:,
    RETSEC_NF        26:1 - 26:,
    RTY_NF           27:1 - 27:,
    RETUW_NT         28:1 - 28:,
    RETCUR_CF        34:1 - 34:,
    PLC_NT           36:1 - 36:,
    RTO_NF           37:1 - 37:,
    ACMAMT_M         43:1 - 43:,
    ACMCUR_CF        44:1 - 44:,
    FIELDS1           6:1 - 18:,
    FIELDS1_BIS      20:1 - 34:,
    FIELDS2_BIS      36:1 - 41:,
    FIELDS2          46:1 - 54:,
    FIELDS3          56:1 - 122:
/KEYS   SSD_CF
       ,ESB_CF
       ,CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
       ,CUR_CF
       ,RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
       ,RETCUR_CF
       ,PLC_NT
/CONDITION NOTASSUMED CTR_NF = ""
/CONDITION NOTRETRO RETCTR_NF = ""
/DERIVEDFIELD FILLER1 "~"
/DERIVEDFIELD FILLER2 5"~"
/DERIVEDFIELD FILLER3 64"0~"
/DERIVEDFIELD FILLER5 2"~"
/DERIVEDFIELD FILLER4 6"~"
/DERIVEDFIELD NORME "${NORM_CF}~"
/DERIVEDFIELD TYPEREC "CSM~PAFAM~~"
/DERIVEDFIELD ACMTRS_NT "170~"
/DERIVEDFIELD PRS_CF "751~"
/DERIVEDFIELD AMT_M if NOTASSUMED then "" else ACMAMT_M
/DERIVEDFIELD RETAMT_M if NOTRETRO then "" else ACMAMT_M
/DERIVEDFIELD TOTAUX_M "0~"
/DERIVEDFIELD ACMTRS3_NT "3330"
/DERIVEDFIELD BALSH "${PREVCLODYYYY}~${PREVCLODMM}~${PREVCLODDD}~"
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,ESB_CF,BALSH,FIELDS1,AMT_M,FIELDS1_BIS,RETAMT_M,FIELDS2_BIS,ACMTRS_NT,ACMAMT_M,ACMCUR_CF,PRS_CF,FIELDS2,FILLER1,FIELDS3,TOTAUX_M,ACMTRS3_NT
exit
EOF
SORT
	
NSTEP=${NJOB}_185
#------------------------------------------------------------------------------
LIBEL="Merge input rows with match"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_130_${IB}_CSM_PAFAM_PURE_ASSUMED.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_140_${IB}_CSM_PAFAM_PROP_RETRO_AND_INTERNAL_ASSUMED_R_RI.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_150_${IB}_CSM_PAFAM_NONPROP_RETRO.dat 2000 1"
SORT_I4="${DFILT}/${NJOB}_140_1_${IB}_CSM_PAFAM_PROP_RETRO_AND_INTERNAL_ASSUMED_AI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_MERGED.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF          8:1 - 8:,
        END_NT          9:1 - 9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        CUR_CF          18:1 - 18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
		RETCUR_CF       34:1 - 34:,
		PLC_NT          36:1 - 36:,
        ALL_COLS1        1:1 - 124:
/KEYS   CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
       ,CUR_CF
       ,RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
	   ,RETCUR_CF
	   ,PLC_NT
/OUTFILE   ${SORT_O}
/REFORMAT ALL_COLS1
exit
EOF
SORT

NSTEP=${NJOB}_190
# To BE ADDED or REPLACE ${DFILT}/${NJOB}_10_${IB}_CSM_PAFAM.dat
#------------------------------------------------------------------------------
LIBEL="Merge input rows"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_175_${IB}_CSM_PAFAM_NEW_ROWS.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_185_${IB}_CSM_PAFAM_MERGED.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_MERGED.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF          1:1 -  1:EN,					
        ESB_CF          2:1 -  2:EN,
        CTR_NF          8:1 - 8:,
        END_NT          9:1 - 9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        CUR_CF          18:1 - 18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
		RETCUR_CF       34:1 - 34:,
		PLC_NT          36:1 - 36:,
        ALL_COLS1        1:1 - 124:
/KEYS   SSD_CF
       ,ESB_CF
       ,CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
       ,CUR_CF
       ,RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
	   ,RETCUR_CF
	   ,PLC_NT
/SUMMARIZE	   
/OUTFILE   ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_200
# CURRENT CSM PAFAM EXCEPT ROWS TO UPDATE
#------------------------------------------------------------------------------
LIBEL="Merge initial rows with no match"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_130_2_${IB}_CSM_PAFAM_PURE_ASSUMED.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_140_2_${IB}_CSM_PAFAM_PROP_RETRO_AND_INTERNAL_ASSUMED_R_RI.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_150_2_${IB}_CSM_PAFAM_NONPROP_RETRO.dat 2000 1"
SORT_I4="${DFILT}/${NJOB}_140_3_${IB}_CSM_PAFAM_PROP_RETRO_AND_INTERNAL_ASSUMED_AI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM_MERGED.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF          8:1 - 8:,
        END_NT          9:1 - 9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        CUR_CF          18:1 - 18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
		RETCUR_CF       34:1 - 34:,
		PLC_NT          36:1 - 36:,
        ALL_COLS1        1:1 - 124:
/KEYS   CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
       ,CUR_CF
       ,RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
	   ,RETCUR_CF
	   ,PLC_NT
/OUTFILE   ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_210
# MERGE TO CREATE NEW CSM PAFAM
#------------------------------------------------------------------------------
LIBEL="Merge input rows"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_190_${IB}_CSM_PAFAM_MERGED.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_200_${IB}_CSM_PAFAM_MERGED.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_PAFAM.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF          8:1 - 8:,
        END_NT          9:1 - 9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        CUR_CF          18:1 - 18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
		RETCUR_CF       34:1 - 34:,
        PLC_NT          36:1 - 36:,		
        ALL_COLS1        1:1 - 124:
/KEYS   CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
       ,CUR_CF
       ,RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
	   ,RETCUR_CF
	   ,PLC_NT
/OUTFILE   ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_220
# NEW PERM FILE
#------------------------------------------------------------------------------
LIBEL="Merge input rows"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_210_${IB}_CSM_PAFAM.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_100_${IB}_NON_CSM_PAFAM.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_UOA_PRO_STD_GTSII_CSM_CASHFLOW.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
    SSD_CF            1:1 -  1:EN,					
    ESB_CF            2:1 -  2:EN,
    BALSHEY_NF        3:1 -  3:,
    BALSHRMTH_NF      4:1 -  4:,
    BALSHRDAY_NF      5:1 -  5:,
    TRNCOD_CF         6:1 -  6:,
    DBLTRNCOD_CF      7:1 -  7:,
    CTR_NF            8:1 -  8:,
    END_NT            9:1 -  9:EN,
    SEC_NF           10:1 - 10:,
    UWY_NF           11:1 - 11:,
    UW_NT            12:1 - 12:,
    OCCYEA_NF        13:1 - 13:,
    ACY_NF           14:1 - 14:,
    SCOSTRMTH_NF     15:1 - 15:EN,
    SCOENDMTH_NF     16:1 - 16:EN,
    CLM_NF           17:1 - 17:,
    CUR_CF           18:1 - 18:,
    AMT_M            19:1 - 19:EN 15/3,
    CED_NF           20:1 - 20:,
    BRK_NF           21:1 - 21:,
    PAY_NF           22:1 - 22:,
    KEY_NF           23:1 - 23:,
    RETCTR_NF        24:1 - 24:,
    RETEND_NT        25:1 - 25:,
    RETSEC_NF        26:1 - 26:,
    RTY_NF           27:1 - 27:,
    RETUW_NT         28:1 - 28:,
    RETOCCYEA_NF     29:1 - 29:,
    RETACY_NF        30:1 - 30:,
    RETSCOSTRMTH_NF  31:1 - 31:EN,
    RETSCOENDMTH_NF  32:1 - 32:EN,
    RCL_NF           33:1 - 33:,
    RETCUR_CF        34:1 - 34:,
    RETAMT_M         35:1 - 35:EN 15/3,
    PLC_NT           36:1 - 36:,
    RTO_NF           37:1 - 37:,
    INT_NF           38:1 - 38:,
    RETPAY_NF        39:1 - 39:,
    RETKEY_CF        40:1 - 40:,
    RETINTAMT_M      41:1 - 41:EN 15/3,
    ACMTRS_NT        42:1 - 42:,
    ACMAMT_M         43:1 - 43:EN 15/3,
    ACMCUR_CF        44:1 - 44:,
    PRS_CF           45:1 - 45:,
    SEG_NF           46:1 - 46:,
    LOB_CF           47:1 - 47:,
    NAT_CF           48:1 - 48:,
    TYP_CT           49:1 - 49:,
    NORME_CF         50:1 - 50:,
    RATING_CF        51:1 - 51:,
    PATCAT_CT        52:1 - 52:,
    PATTYP_CT        53:1 - 53:,
    PATTERN_ID       54:1 - 54:,
    AM01_M           55:1 - 55:EN 15/3,
    AM02_M           56:1 - 56:EN 15/3,
    AM03_M           57:1 - 57:EN 15/3,
    AM04_M           58:1 - 58:EN 15/3,
    AM05_M           59:1 - 59:EN 15/3,
    AM06_M           60:1 - 60:EN 15/3,
    AM07_M           61:1 - 61:EN 15/3,
    AM08_M           62:1 - 62:EN 15/3,
    AM09_M           63:1 - 63:EN 15/3,
    AM10_M           64:1 - 64:EN 15/3,
    AM11_M           65:1 - 65:EN 15/3,
    AM12_M           66:1 - 66:EN 15/3,
    AM13_M           67:1 - 67:EN 15/3,
    AM14_M           68:1 - 68:EN 15/3,
    AM15_M           69:1 - 69:EN 15/3,
    AM16_M           70:1 - 70:EN 15/3,
    AM17_M           71:1 - 71:EN 15/3,
    AM18_M           72:1 - 72:EN 15/3,
    AM19_M           73:1 - 73:EN 15/3,
    AM20_M           74:1 - 74:EN 15/3,
    AM21_M           75:1 - 75:EN 15/3,
    AM22_M           76:1 - 76:EN 15/3,
    AM23_M           77:1 - 77:EN 15/3,
    AM24_M           78:1 - 78:EN 15/3,
    AM25_M           79:1 - 79:EN 15/3,
    AM26_M           80:1 - 80:EN 15/3,
    AM27_M           81:1 - 81:EN 15/3,
    AM28_M           82:1 - 82:EN 15/3,
    AM29_M           83:1 - 83:EN 15/3,
    AM30_M           84:1 - 84:EN 15/3,
    AM31_M           85:1 - 85:EN 15/3,
    AM32_M           86:1 - 86:EN 15/3,
    AM33_M           87:1 - 87:EN 15/3,
    AM34_M           88:1 - 88:EN 15/3,
    AM35_M           89:1 - 89:EN 15/3,
    AM36_M           90:1 - 90:EN 15/3,
    AM37_M           91:1 - 91:EN 15/3,
    AM38_M           92:1 - 92:EN 15/3,
    AM39_M           93:1 - 93:EN 15/3,
    AM40_M           94:1 - 94:EN 15/3,
    AM41_M           95:1 - 95:EN 15/3,
    AM42_M           96:1 - 96:EN 15/3,
    AM43_M           97:1 - 97:EN 15/3,
    AM44_M           98:1 - 98:EN 15/3,
    AM45_M           99:1 - 99:EN 15/3,
    AM46_M          100:1 - 100:EN 15/3,
    AM47_M          101:1 - 101:EN 15/3,
    AM48_M          102:1 - 102:EN 15/3,
    AM49_M          103:1 - 103:EN 15/3,
    AM50_M          104:1 - 104:EN 15/3,
    AM51_M          105:1 - 105:EN 15/3,
    AM52_M          106:1 - 106:EN 15/3,
    AM53_M          107:1 - 107:EN 15/3,
    AM54_M          108:1 - 108:EN 15/3,
    AM55_M          109:1 - 109:EN 15/3,
    AM56_M          110:1 - 110:EN 15/3,
    AM57_M          111:1 - 111:EN 15/3,
    AM58_M          112:1 - 112:EN 15/3,
    AM59_M          113:1 - 113:EN 15/3,
    AM60_M          114:1 - 114:EN 15/3,
    AM61_M          115:1 - 115:EN 15/3,
    AM62_M          116:1 - 116:EN 15/3,
    AM63_M          117:1 - 117:EN 15/3,
    AM64_M          118:1 - 118:EN 15/3,
    AM65_M          119:1 - 119:EN 15/3,
    COEF_LOB        120:1 - 120:,
    DSCCUR_CF       121:1 - 121:,
    COMMENT         122:1 - 122:,
    TOTAUX_M        123:1 - 123:EN 15/3,
	ACMTRS3_NT      124:1 - 124:
/KEYS 
      SSD_CF,
      ESB_CF,
	  RETCUR_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CUR_CF
/OUTFILE   ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_24
LIBEL="Copy new CSM PAFAM file to perm"
#-----------------------------------------------------------------------------------------
awk -F "~" 'BEGIN{OFS="~";}{print $0}' ${DFILT}/${NJOB}_220_${IB}_UOA_PRO_STD_GTSII_CSM_CASHFLOW.dat > /scor/scordata/${VSITE}/perm/${ENV_PREFIX}_ESFD3760_${NORM_CF}_UOA_PRO_STD_GTSII_CSM_CASHFLOW_${CLOTYP_CT}_${CLODAT_D_QPREV}.dat

fi

JOBEND
