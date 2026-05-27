#!/bin/ksh
#===========================================================================================
# Application Name          : Compare CMGTR monthly files to CURGTR year file
# SHELL	Script Name	        : PMUM0015.cmd
# Revision			            : $Revision: 1.1 $
# Creation Date             : 2009.06.24 (AAAA.MM.DD)
# Author                    : PhV
# Specifications References	:
#-------------------------------------------------------------------------------------------
# Description
#    Compare CMGTR monthly file to CURGTR history file
#    [SPOT17557] - Controles CMGT / GT pour Mutré
#
# Input files
#    $DFILP/${ENV_PREFIX}_ESID7050_CMGTR_*.dat
#    $DFILP/${ENV_PREFIX}_ESIX7000_CURGTR.dat
#
# Output files
#    $DFILT/${ENV_PREFIX}_ESIX7000_CURGTR_FILTERED_SUMMARIZED.dat (= Extract CURGTR with filter)
#    $DFILT/${ENV_PREFIX}_ESIX7000_CURGTR_FILTERED_SUMMARIZED2.dat (= Clean-Up on CURGTR_FILTERED_SUMMARIZED.dat)
#    $DFILT/${ENV_PREFIX}_ESID7050_CMGTR_FILTERED_SUMMARIZED.dat (= Extract CMGTR with filter)
#    $DFILT/${ENV_PREFIX}_ESID7050_CMGTR_FILTERED_SUMMARIZED2.dat (= Clean-Up on ${ENV_PREFIX}_ESID7050_CMGTR_*.dat)
#    $DFILT/${ENV_PREFIX}_ESID7050_CMGTR_Result.dat (= Result Process Log)
#
#-------------------------------------------------------------------------------------------
# Job Launched By           : PMUM0010.cmd
#-------------------------------------------------------------------------------------------
# Modifications History     :
#[001] 11/01/2016 Roger Cassis   :spot:29985 - Normalisation ENV_PREFIX dans noms de fichiers et gestion des fichiers GT pour le mois 12.
#===========================================================================================
#set -x

# ------------------------ -
# - Call generic functions
# ------------------------ -
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# - ------------------------------------- -
# - Get input parameters
# -    1. BALSHTYEA_NF = Ann‰e de cloture
# -    2. BALSHTMTH_NF = Mois de cloture
# - ------------------------------------- -
balshtyea_nf_param=$1
balshtmth_nf_param=$2

# - ------------------ -
# - Job Initialisation -
# - ------------------ -
JOBINIT

# - ------------------------ -
# - Variables Initialisation
# - ------------------------ -

# - NJOB
NJOB="PMUM0015"

# - BALSHTMTH_NF Check
# -    Because BALSHTMTH_NF can be '6' OR '06', Sql condition must use these 2 forms to retrieve datas.
# -    1. balshtmth_nf_test is temp variable.
# -    2. balshtmth_nf_1Digit contains balshtmth_nf_param on 1 digit if it's possible (Month < 10).
# -    3. balshtmth_nf_2Digits contains balshtmth_nf_param on 2 digits. (Month >= 10; add a '0' at the beginning).
#-     4. balshtmth_nf_sql contains balshtmth_nf_1Digit.
balshtmth_nf_test=0
balshtmth_nf_1Digit=0
balshtmth_nf_2Digits=0
balshtmth_nf_sql=0

balshtmth_nf_test=`echo ${balshtmth_nf_param}|cut -c1`

#- balshtmth_nf_param < 10 or not ?
if [ ${balshtmth_nf_param} = 1 ]; then
   # - balshtmth_nf_param contains only 1 Digit.
   balshtmth_nf_sql=${balshtmth_nf_param}
   balshtmth_nf_1Digit=${balshtmth_nf_param}
   balshtmth_nf_2Digits=0${balshtmth_nf_param}
else
   # - balshtmth_nf_param contains 2 Digits.
   if [ ${balshtmth_nf_test} = 0 ]; then
      #- balshtmth_nf_param begins with a '0'
      #- SQL condition will be constructed thanks to balshtmth_nf_param without '0' at the beginning.
      balshtmth_nf_sql=`echo ${balshtmth_nf_param}|cut -c2`
   	balshtmth_nf_1Digit=${balshtmth_nf_sql}
   	balshtmth_nf_2Digits=${balshtmth_nf_param}
   else
      #- balshtmth_nf_param begins without a '1'
      #- SQL condition will be constructed thanks to balshtmth_nf_param with all digits.
      balshtmth_nf_sql=${balshtmth_nf_param}
      balshtmth_nf_1Digit=${balshtmth_nf_param}
      balshtmth_nf_2Digits=${balshtmth_nf_param}
   fi
fi

# - CURGTR Source File Directory & Name
CURGTR_SourceFile="${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat"
#[001]
if [ "${balshtmth_nf_param}" = "12" ]
then
	cp ${DARCH}/${ENV_PREFIX}_ESIX7000_CURGTR_${balshtyea_nf_param}${balshtmth_nf_param}.arc  ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR.dat
	CURGTR_SourceFile="${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR.dat"
fi
# - CMGTR Source File Directory & Name
CMGTR_SourceFile=`ls -t ${EST_CMGTR}_*_${balshtyea_nf_param}${balshtmth_nf_param}_*_*.dat | head -1`

# - Total records on CMGTR_SourceFile
TotalRecordCMGTR=0
# - Total records on CURGTR_SourceFile
TotalRecordCURGTR=0
# - Total records Present into CURGTR and not into CMGTR
TotalRecordPresentIntoCurgtr=0
# - Total records Present into CMGTR and not into CURGTR
TotalRecordPresentIntoCmgtr=0
# - Total records Present into CURGTR and into CMGTR
TotalRecordPresentIntoThese2Files=0

# - -------------------------- -
# - Step : 05-09
# -    Temporary file clean-up
# - -------------------------- -
NSTEP=${NJOB}_05
LIBEL="Temporary file ${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR*_FILTERED_SUMMARIZED*.dat clean-up"
RMFIL "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR*_FILTERED_SUMMARIZED*.dat"

NSTEP=${NJOB}_06
LIBEL="Temporary file ${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTR*_FILTERED_SUMMARIZED*.dat clean-up"
RMFIL "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTR*_FILTERED_SUMMARIZED*.dat"

NSTEP=${NJOB}_07
LIBEL="Temporary file ${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat clean-up"
RMFIL "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"

NSTEP=${NJOB}_08
LIBEL="Temporary file ${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result_OK.dat clean-up"
RMFIL "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result_OK.dat"

NSTEP=${NJOB}_09
LIBEL="Temporary file ${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result_KO.dat clean-up"
RMFIL "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result_KO.dat"

# - ---------------------------------------------------------------------- -
# - Step : 10
# -    Extract ${ENV_PREFIX}_ESIX7000_CURGTR.dat with filter
# -       Filter on BALSHEY_NF (= Year), BALSHRMTH_NF (= Month)
# -       Filter on TRNCOD_CD = "2" OR "4" (= Retrocession)
# -
# -    => Result : ${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTR_FILTERED_SUMMARIZED.dat
# - ---------------------------------------------------------------------- -
NSTEP=${NJOB}_10
LIBEL="Extract ${ENV_PREFIX}_ESIX7000_CURGTR.dat with filter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$CURGTR_SourceFile 1000 1"
SORT_O="${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTR_FILTERED_SUMMARIZED.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        TRNCOD_CF 6:1 - 6:1,
        RETCTR_NF 24:1 - 24:,
        RETSEC_NF 26:1 - 26:,
        RETRTY_NF 27:1 - 27:,
        RETAMT_M 35:1 - 35:EN 15/3
/KEYS
        BALSHEY_NF,
        BALSHRMTH_NF,
        RETCTR_NF,
        RETSEC_NF,
        RETRTY_NF
/SUMMARIZE
        TOTAL RETAMT_M
/CONDITION
        WHERE BALSHEY_NF="${balshtyea_nf_param}"
          AND (BALSHRMTH_NF="${balshtmth_nf_sql}"
           OR BALSHRMTH_NF="0${balshtmth_nf_sql}")
          AND (TRNCOD_CF = "2"
           OR TRNCOD_CF = "4")
/INCLUDE
        WHERE
/OUTFILE
        ${SORT_O}
/REFORMAT
        BALSHEY_NF,
        BALSHRMTH_NF,
        RETCTR_NF,
        RETSEC_NF,
        RETRTY_NF,
        RETAMT_M
exit
EOF
SORT

# - 1. Replace BALSHEY_NF~balshtmth_nf_1Digit with BALSHEY_NF~balshtmth_nf_2Digits
sed "s/$balshtyea_nf_param~$balshtmth_nf_1Digit/$balshtyea_nf_param~$balshtmth_nf_2Digits/g" ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTR_FILTERED_SUMMARIZED.dat > ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTR_FILTERED_SUMMARIZED2.dat

# - 2. No space allowed. Delete them.
mv -f ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTR_FILTERED_SUMMARIZED2.dat ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTR_FILTERED_SUMMARIZED.dat
sed 's/ //g' ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTR_FILTERED_SUMMARIZED.dat > ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTR_FILTERED_SUMMARIZED2.dat
mv -f ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTR_FILTERED_SUMMARIZED2.dat ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTR_FILTERED_SUMMARIZED.dat

# -       3. Sum
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTR_FILTERED_SUMMARIZED.dat 1000 1"
SORT_O="${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTR_FILTERED_SUMMARIZED2.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
        BALSHEY_NF 1:1 - 1:,
        BALSHRMTH_NF 2:1 - 2:,
        RETCTR_NF 3:1 - 3:,
        RETSEC_NF 4:1 - 4:,
        RETRTY_NF 5:1 - 5:,
        RETAMT_M 6:1 - 6:EN 15/3
/KEYS
        BALSHEY_NF,
        BALSHRMTH_NF,
        RETCTR_NF,
        RETSEC_NF,
        RETRTY_NF
/SUMMARIZE
        TOTAL RETAMT_M
/OUTFILE
        ${SORT_O}
/REFORMAT
        BALSHEY_NF,
        BALSHRMTH_NF,
        RETCTR_NF,
        RETSEC_NF,
        RETRTY_NF,
        RETAMT_M
exit
EOF
SORT

# - 4. No space allowed. Delete them.
mv -f ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTR_FILTERED_SUMMARIZED2.dat ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTR_FILTERED_SUMMARIZED.dat
sed 's/ //g' ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTR_FILTERED_SUMMARIZED.dat > ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTR_FILTERED_SUMMARIZED2.dat

# - ----------------------------------------------------------------------------- -
# - Step : 15
# -    Extract ${ENV_PREFIX}_ESID7050_CMGTR_*.dat with filter
# -       Filter on BALSHEY_NF (= Year), BALSHRMTH_NF (= Month)
# -       Filter on TRNCOD_CD = "2" OR "4" (= Retrocession)
# -
# -    => Result : ${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_FILTERED_SUMMARIZED.dat
# - ----------------------------------------------------------------------------- -
NSTEP=${NJOB}_15
LIBEL="Extract ${ENV_PREFIX}_ESID7050_CMGTR_*.dat with filter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$CMGTR_SourceFile 1000 1"
SORT_O="${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_FILTERED_SUMMARIZED.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        TRNCOD_CF 6:1 - 6:1,
        RETCTR_NF 24:1 - 24:,
        RETSEC_NF 26:1 - 26:,
        RETRTY_NF 27:1 - 27:,
        RETAMT_M 35:1 - 35:EN 15/3
/KEYS
        BALSHEY_NF,
        BALSHRMTH_NF,
        RETCTR_NF,
        RETSEC_NF,
        RETRTY_NF
/SUMMARIZE
        TOTAL RETAMT_M
/CONDITION
        WHERE BALSHEY_NF="${balshtyea_nf_param}"
          AND (BALSHRMTH_NF="${balshtmth_nf_sql}"
           OR BALSHRMTH_NF="0${balshtmth_nf_sql}")
          AND (TRNCOD_CF = "2"
           OR TRNCOD_CF = "4")
/INCLUDE
        WHERE
/OUTFILE
        ${SORT_O}
/REFORMAT
        BALSHEY_NF,
        BALSHRMTH_NF,
        RETCTR_NF,
        RETSEC_NF,
        RETRTY_NF,
        RETAMT_M
exit
EOF
SORT

# - 1. Replace BALSHEY_NF~balshtmth_nf_1Digit with BALSHEY_NF~balshtmth_nf_2Digits
sed "s/$balshtyea_nf_param~$balshtmth_nf_1Digit/$balshtyea_nf_param~$balshtmth_nf_2Digits/g" ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_FILTERED_SUMMARIZED.dat > ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_FILTERED_SUMMARIZED2.dat

# - 2. No space allowed. Delete them.
mv -f ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_FILTERED_SUMMARIZED2.dat ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_FILTERED_SUMMARIZED.dat
sed 's/ //g' ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_FILTERED_SUMMARIZED.dat > ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_FILTERED_SUMMARIZED2.dat
mv -f ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_FILTERED_SUMMARIZED2.dat ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_FILTERED_SUMMARIZED.dat

# -       3. Sum
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_FILTERED_SUMMARIZED.dat 1000 1"
SORT_O="${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_FILTERED_SUMMARIZED2.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
        BALSHEY_NF 1:1 - 1:,
        BALSHRMTH_NF 2:1 - 2:,
        RETCTR_NF 3:1 - 3:,
        RETSEC_NF 4:1 - 4:,
        RETRTY_NF 5:1 - 5:,
        RETAMT_M 6:1 - 6:EN 15/3
/KEYS
        BALSHEY_NF,
        BALSHRMTH_NF,
        RETCTR_NF,
        RETSEC_NF,
        RETRTY_NF
/SUMMARIZE
        TOTAL RETAMT_M
/OUTFILE
        ${SORT_O}
/REFORMAT
        BALSHEY_NF,
        BALSHRMTH_NF,
        RETCTR_NF,
        RETSEC_NF,
        RETRTY_NF,
        RETAMT_M
exit
EOF
SORT

# - 4. No space allowed. Delete them.
mv -f ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_FILTERED_SUMMARIZED2.dat ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_FILTERED_SUMMARIZED.dat
sed 's/ //g' ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_FILTERED_SUMMARIZED.dat > ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_FILTERED_SUMMARIZED2.dat

# - ------------------------------ -
# - Step : 20
# -    Diff between CURGTR & CMGTR
# - ------------------------------ -
NSTEP=${NJOB}_20
LIBEL="Diff between CURGTR & CMGTR"

# - Result File Log Creation (= Process Stats)
echo "- -------------------------------------------------------------------- -" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "- Shell Script Name :" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "-    PMUM0015.cmd" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "- Description       :" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "-    Comparison between 2 files" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "-       1. $CURGTR_SourceFile" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "-       2. $CMGTR_SourceFile" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "- Detail            :" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "-    1. This file shows the error list for this comparison" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "-    2. A summary on Total records for this process." >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "- Information       :" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "-    OK - (3)  = 0 && (4)  = 0" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "-    KO - (3) != 0 && (4) != 0" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "- -------------------------------------------------------------------- -" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"

# - Total Records into ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CURGTR_FILTERED_SUMMARIZED2.dat
TotalRecordCURGTR=`wc -l < ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTR_FILTERED_SUMMARIZED2.dat`

# - Total Records into ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_FILTERED_SUMMARIZED2.dat
TotalRecordCMGTR=`wc -l < ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_FILTERED_SUMMARIZED2.dat`

# - Total of records present into CURGTR AND NOT into CMGTR
echo "- -------------------------------------------------------------- -" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "- Records which exist into CURGTR AND not into CMGTR             -" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "- BALSHEY_NF~BALSHRMTH_NF~RETCTR_NF~RETSEC_NF~RETRTY_NF~RETAMT_M -" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "- -------------------------------------------------------------- -" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
`diff ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTR_FILTERED_SUMMARIZED2.dat ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_FILTERED_SUMMARIZED2.dat | grep "<" >> ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat`
TotalRecordPresentIntoCurgtr=`diff ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTR_FILTERED_SUMMARIZED2.dat ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_FILTERED_SUMMARIZED2.dat | grep "<" | wc -l`
echo "" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"

# - Total of records present into CMGTR AND NOT into CURGTR
echo "- -------------------------------------------------------------- -" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "- Records which exist into CMGTR AND not into CURGTR             -" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "- BALSHEY_NF~BALSHRMTH_NF~RETCTR_NF~RETSEC_NF~RETRTY_NF~RETAMT_M -" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "- -------------------------------------------------------------- -" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
`diff ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTR_FILTERED_SUMMARIZED2.dat ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_FILTERED_SUMMARIZED2.dat | grep ">" >> ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat`
TotalRecordPresentIntoCmgtr=`diff ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTR_FILTERED_SUMMARIZED2.dat ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_FILTERED_SUMMARIZED2.dat | grep ">" | wc -l`
echo "" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"

# - Total of records present into CMGTR AND into CURGTR
let TotalRecordPresentIntoThese2Files=TotalRecordCURGTR-TotalRecordPresentIntoCmgtr

# - Summary of process
# - 1. On the screen...
echo ""
echo "- ---------------------------------------------------------------------- -"
echo "- Summary"
echo "- (1) - Total of record(s) into CURGTR File                       :" $TotalRecordCURGTR
echo "- (2) - Total of record(s) into CMGTR File                        :" $TotalRecordCMGTR
echo "- (3) - Total of record(s) present into CURGTR AND not into CMGTR :" $TotalRecordPresentIntoCurgtr
echo "- (4) - Total of record(s) present into CMGTR AND not into CURGTR :" $TotalRecordPresentIntoCmgtr
echo "- (5) - Total of record(s) present into CURGTR AND into CMGTR     :" $TotalRecordPresentIntoThese2Files
echo "- ---------------------------------------------------------------------- -"
echo ""

# - 2. On Result File Log...
echo "" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "- ---------------------------------------------------------------------- -" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "- Summary" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "- (1) - Total of record(s) into CURGTR File                       :" $TotalRecordCURGTR >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "- (2) - Total of record(s) into CMGTR File                        :" $TotalRecordCMGTR >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "- (3) - Total of record(s) present into CURGTR AND not into CMGTR :" $TotalRecordPresentIntoCurgtr >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "- (4) - Total of record(s) present into CMGTR AND not into CURGTR :" $TotalRecordPresentIntoCmgtr >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "- (5) - Total of record(s) present into CURGTR AND into CMGTR     :" $TotalRecordPresentIntoThese2Files >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "- ---------------------------------------------------------------------- -" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"
echo "" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result.dat"

# - Error or not Error ?, that is the question !
if [ $TotalRecordPresentIntoCurgtr -eq 0 -a $TotalRecordPresentIntoCmgtr -eq 0 ]
then
   #- No Error !!! :o ) Creation of a OK File. FTP Transfert will be done in PMUM0014.cmd.
   echo "" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result_OK.dat"
else
   #- No Error !!! :o ( Creation of a KO File. FTP Transfert will NOT be done in PMUM0014.cmd.
   echo "" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR_Result_KO.dat"
fi

# - ------------------------ -
# - Step : 95
# -    Erase temporary files
# - ------------------------ -
NSTEP=${NJOB}_95
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTR*_FILTERED_SUMMARIZED*.dat"
RMFIL "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTR*_FILTERED_SUMMARIZED*.dat"

# - ----------------------------- -
# - Job Over - That's All Folks !
# - ----------------------------- -
JOBEND
