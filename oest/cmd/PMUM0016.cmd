#!/bin/ksh
#=================================================================================
# Application Name              : ESTIMATIONS - INVENTAIRE
#              			              Compare CMGTAA monthly files to CURGTA year file
# Shell Script Name             : PMUM0016.cmd
# Revision                      : $Revision:   1.0  $
# Creation Date                 : 2009.06.16 (AAAA.MM.DD)
# Author                        : PhV
# Specifications References     :
#---------------------------------------------------------------------------------
# Description
#    Compare CMGTAA monthly file to CURGTA history file (= PMUM0016 job)
#    [SPOT17557] - Controles CMGT / GT pour Mutré
#
# Input files
#    $DPRM\${ENV_PREFIX}_ESID7050_CMGTAA_*.dat
#    $DPRM\${ENV_PREFIX}_ESIX7000_CURGTA.dat
#
# Output files
#    $DFILT/${ENV_PREFIX}_ESIX7000_CURGTA_FILTERED_SUMMARIZED.dat (= Extract CURGTA with filter)
#    $DFILT/${ENV_PREFIX}_ESIX7000_CURGTA_FILTERED_SUMMARIZED2.dat (= Clean-Up on CURGTA_FILTERED_SUMMARIZED.dat)
#    $DFILT/${ENV_PREFIX}_ESID7050_CMGTAA_FILTERED_SUMMARIZED.dat (= Extract CMGTAA with filter)
#    $DFILT/${ENV_PREFIX}_ESID7050_CMGTAA_FILTERED_SUMMARIZED2.dat (= Clean-Up on ${ENV_PREFIX}_ESID7050_CMGTAA_*.dat)
#    $DFILT/${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat (= Result Process Log)
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
# -    1. BALSHTYEA_NF = Année de cloture
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
NJOB="PMUM0016"

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

# - CURGTA Source File Directory & Name
CURGTA_SourceFile="${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat"
#[001]
if [ "${balshtmth_nf_param}" = "12" ]
then
	cp ${DARCH}/${ENV_PREFIX}_ESIX7000_CURGTA_${balshtyea_nf_param}${balshtmth_nf_param}.arc ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTA.dat
	CURGTA_SourceFile="${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTA.dat"
fi
# - CMGTAA Source File
CMGTAA_SourceFile=`ls -t ${EST_CMGTAA}_*_${balshtyea_nf_param}${balshtmth_nf_param}_*_*.dat | head -1`

# - Total records on CMGTAA_SourceFile
TotalRecordCMGTAA=0
# - Total records on CURGTA_SourceFile
TotalRecordCURGTA=0
# - Total records Present into CURGTA and not into CMGTAA
TotalRecordPresentIntoCURGTA=0
# - Total records Present into CMGTAA and not into CURGTA
TotalRecordPresentIntoCmgtaa=0
# - Total records Present into CURGTA and into CMGTAA
TotalRecordPresentIntoThese2Files=0

# - -------------------------- -
# - Step : 05-09
# -    Temporary file clean-up
# - -------------------------- -
NSTEP=${NJOB}_05
LIBEL="Temporary file ${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA*_FILTERED_SUMMARIZED*.dat clean-up"
RMFIL "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA*_FILTERED_SUMMARIZED*.dat"

NSTEP=${NJOB}_06
LIBEL="Temporary file ${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTA*_FILTERED_SUMMARIZED*.dat clean-up"
RMFIL "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTA*_FILTERED_SUMMARIZED*.dat"

NSTEP=${NJOB}_07
LIBEL="Temporary file ${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat clean-up"
RMFIL "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"

NSTEP=${NJOB}_08
LIBEL="Temporary file ${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result_OK.dat clean-up"
RMFIL "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result_OK.dat"

NSTEP=${NJOB}_09
LIBEL="Temporary file ${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result_KO.dat clean-up"
RMFIL "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result_KO.dat"

# - ---------------------------------------------------------------------- -
# - Step : 10
# -    Extract ${ENV_PREFIX}_ESIX7000_CURGTA.dat with filter
# -       Filter on BALSHEY_NF (= Year), BALSHRMTH_NF (= Month)
# -       Filter on TRNCOD_CD = "1" OR "3" (= Acceptance / Acceptation)
# -
# -    => Result : ${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTA_FILTERED_SUMMARIZED.dat
# - ---------------------------------------------------------------------- -
NSTEP=${NJOB}_10
LIBEL="Extract ${ENV_PREFIX}_ESIX7000_CURGTA.dat with filter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$CURGTA_SourceFile 1000 1"
SORT_O="${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTA_FILTERED_SUMMARIZED.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        TRNCOD_CF 6:1 - 6:1,
        CTR_NF 8:1 - 8:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        AMT_M 19:1 - 19:EN 15/3
/KEYS
        BALSHEY_NF,
        BALSHRMTH_NF,
        CTR_NF,
        SEC_NF,
        UWY_NF
/SUMMARIZE
        TOTAL AMT_M
/CONDITION
        WHERE BALSHEY_NF="${balshtyea_nf_param}"
          AND (BALSHRMTH_NF="${balshtmth_nf_sql}"
           OR BALSHRMTH_NF="0${balshtmth_nf_sql}")
          AND (TRNCOD_CF = "1"
           OR TRNCOD_CF = "3")
/INCLUDE
        WHERE
/OUTFILE
        ${SORT_O}
/REFORMAT
        BALSHEY_NF,
        BALSHRMTH_NF,
        CTR_NF,
        SEC_NF,
        UWY_NF,
        AMT_M
exit
EOF
SORT

# - 1. Replace BALSHEY_NF~balshtmth_nf_1Digit with BALSHEY_NF~balshtmth_nf_2Digits
sed "s/$balshtyea_nf_param~$balshtmth_nf_1Digit/$balshtyea_nf_param~$balshtmth_nf_2Digits/g" ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTA_FILTERED_SUMMARIZED.dat > ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTA_FILTERED_SUMMARIZED2.dat

# - 2. No space allowed. Delete them.
mv -f ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTA_FILTERED_SUMMARIZED2.dat ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTA_FILTERED_SUMMARIZED.dat
sed 's/ //g' ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTA_FILTERED_SUMMARIZED.dat > ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTA_FILTERED_SUMMARIZED2.dat
mv -f ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTA_FILTERED_SUMMARIZED2.dat ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTA_FILTERED_SUMMARIZED.dat

# -       3. Sum
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTA_FILTERED_SUMMARIZED.dat 1000 1"
SORT_O="${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTA_FILTERED_SUMMARIZED2.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
        BALSHEY_NF 1:1 - 1:,
        BALSHRMTH_NF 2:1 - 2:,
        CTR_NF 3:1 - 3:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:,
        AMT_M 6:1 - 6:EN 15/3
/KEYS
        BALSHEY_NF,
        BALSHRMTH_NF,
        CTR_NF,
        SEC_NF,
        UWY_NF
/SUMMARIZE
        TOTAL AMT_M
/OUTFILE
        ${SORT_O}
/REFORMAT
        BALSHEY_NF,
        BALSHRMTH_NF,
        CTR_NF,
        SEC_NF,
        UWY_NF,
        AMT_M
exit
EOF
SORT

# - 4. No space allowed. Delete them.
mv -f ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTA_FILTERED_SUMMARIZED2.dat ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTA_FILTERED_SUMMARIZED.dat
sed 's/ //g' ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTA_FILTERED_SUMMARIZED.dat > ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTA_FILTERED_SUMMARIZED2.dat

# - ----------------------------------------------------------------------------- -
# - Step : 15
# -    Extract ${ENV_PREFIX}_ESID7050_CMGTAA_*.dat with filter
# -       Filter on BALSHEY_NF (= Year), BALSHRMTH_NF (= Month)
# -       Filter on TRNCOD_CD = "1" OR "3" (= Accpetance / Acceptation)
# -
# -    => Result : ${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_FILTERED_SUMMARIZED.dat
# - ----------------------------------------------------------------------------- -
NSTEP=${NJOB}_15
LIBEL="Extract ${ENV_PREFIX}_ESID7050_CMGTAA_*.dat with filter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$CMGTAA_SourceFile 1000 1"
SORT_O="${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_FILTERED_SUMMARIZED.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        TRNCOD_CF 6:1 - 6:1,
        CTR_NF 8:1 - 8:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        AMT_M 19:1 - 19:EN 15/3
/KEYS
        BALSHEY_NF,
        BALSHRMTH_NF,
        CTR_NF,
        SEC_NF,
        UWY_NF
/SUMMARIZE
        TOTAL AMT_M
/CONDITION
        WHERE BALSHEY_NF="${balshtyea_nf_param}"
          AND (BALSHRMTH_NF="${balshtmth_nf_sql}"
           OR BALSHRMTH_NF="0${balshtmth_nf_sql}")
          AND (TRNCOD_CF = "1"
           OR TRNCOD_CF = "3")
/INCLUDE
        WHERE
/OUTFILE
        ${SORT_O}
/REFORMAT
        BALSHEY_NF,
        BALSHRMTH_NF,
        CTR_NF,
        SEC_NF,
        UWY_NF,
        AMT_M
exit
EOF
SORT

# - 1. Replace BALSHEY_NF~balshtmth_nf_1Digit with BALSHEY_NF~balshtmth_nf_2Digits
sed "s/$balshtyea_nf_param~$balshtmth_nf_1Digit/$balshtyea_nf_param~$balshtmth_nf_2Digits/g" ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_FILTERED_SUMMARIZED.dat > ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_FILTERED_SUMMARIZED2.dat

# - 2. No space allowed. Delete them.
mv -f ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_FILTERED_SUMMARIZED2.dat ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_FILTERED_SUMMARIZED.dat
sed 's/ //g' ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_FILTERED_SUMMARIZED.dat > ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_FILTERED_SUMMARIZED2.dat
mv -f ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_FILTERED_SUMMARIZED2.dat ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_FILTERED_SUMMARIZED.dat

# -       3. Sum
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_FILTERED_SUMMARIZED.dat 1000 1"
SORT_O="${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_FILTERED_SUMMARIZED2.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
        BALSHEY_NF 1:1 - 1:,
        BALSHRMTH_NF 2:1 - 2:,
        CTR_NF 3:1 - 3:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:,
        AMT_M 6:1 - 6:EN 15/3
/KEYS
        BALSHEY_NF,
        BALSHRMTH_NF,
        CTR_NF,
        SEC_NF,
        UWY_NF
/SUMMARIZE
        TOTAL AMT_M
/OUTFILE
        ${SORT_O}
/REFORMAT
        BALSHEY_NF,
        BALSHRMTH_NF,
        CTR_NF,
        SEC_NF,
        UWY_NF,
        AMT_M
exit
EOF
SORT

# - 4. No space allowed. Delete them.
mv -f ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_FILTERED_SUMMARIZED2.dat ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_FILTERED_SUMMARIZED.dat
sed 's/ //g' ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_FILTERED_SUMMARIZED.dat > ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_FILTERED_SUMMARIZED2.dat

# - ------------------------------- -
# - Step : 20
# -    Diff between CURGTA & CMGTAA
# - ------------------------------- -
NSTEP=${NJOB}_20
LIBEL="Diff between CURGTA & CMGTAA"

# - Result File Log Creation (= Process Stats)
echo "- -------------------------------------------------------------------- -" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "- Shell Script Name :" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "-    PMUM0016.cmd" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "- Description       :" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "-    Comparison between 2 files" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "-       1. $CURGTA_SourceFile" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "-       2. $CMGTAA_SourceFile" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "- Detail            :" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "-    1. This file shows the error list for this comparison" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "-    2. A summary on Total records for this process." >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "- Information       :" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "-    OK - (3)  = 0 && (4)  = 0" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "-    KO - (3) != 0 && (4) != 0" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "- -------------------------------------------------------------------- -" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"

# - Total Records into ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CURGTA_FILTERED_SUMMARIZED2.dat
TotalRecordCURGTA=`wc -l < ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTA_FILTERED_SUMMARIZED2.dat`

# - Total Records into ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_FILTERED_SUMMARIZED2.dat
TotalRecordCMGTAA=`wc -l < ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_FILTERED_SUMMARIZED2.dat`

# - Total of records present into CURGTA AND NOT into CMGTAA
echo "- --------------------------------------------------- -" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "- Records which exist into CURGTA AND not into CMGTAA -" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "- BALSHEY_NF~BALSHRMTH_NF~CTR_NF~SEC_NF~UWY_NF~AMT_M  -" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "- --------------------------------------------------- -" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
`diff ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTA_FILTERED_SUMMARIZED2.dat ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_FILTERED_SUMMARIZED2.dat | grep "<" >> ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat`
TotalRecordPresentIntoCURGTA=`diff ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTA_FILTERED_SUMMARIZED2.dat ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_FILTERED_SUMMARIZED2.dat | grep "<" | wc -l`
echo "" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"

# - Total of records present into CMGTAA AND NOT into CURGTA
echo "- --------------------------------------------------- -" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "- Records which exist into CMGTAA AND not into CURGTA -" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "- BALSHEY_NF~BALSHRMTH_NF~CTR_NF~SEC_NF~UWY_NF~AMT_M  -" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "- --------------------------------------------------- -" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
`diff ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTA_FILTERED_SUMMARIZED2.dat ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_FILTERED_SUMMARIZED2.dat | grep ">" >> ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat`
TotalRecordPresentIntoCMGTAA=`diff ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTA_FILTERED_SUMMARIZED2.dat ${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_FILTERED_SUMMARIZED2.dat | grep ">" | wc -l`
echo "" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"

# - Total of records present into CMGTAA AND into CURGTA
let TotalRecordPresentIntoThese2Files=TotalRecordCMGTAA-TotalRecordPresentIntoCMGTAA


# - Summary of process
# - 1. On the screen...
echo ""
echo "- ---------------------------------------------------------------------- -"
echo "- Summary"
echo "- (1) - Total of record(s) into CURGTA File                        :" $TotalRecordCURGTA
echo "- (2) - Total of record(s) into CMGTAA File                        :" $TotalRecordCMGTAA
echo "- (3) - Total of record(s) present into CURGTA AND not into CMGTAA :" $TotalRecordPresentIntoCURGTA
echo "- (4) - Total of record(s) present into CMGTAA AND not into CURGTA :" $TotalRecordPresentIntoCMGTAA
echo "- (5) - Total of record(s) present into CURGTA AND into CMGTAA     :" $TotalRecordPresentIntoThese2Files
echo "- ---------------------------------------------------------------------- -"
echo ""

# - 2. On Result File Log...
echo "" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "- ---------------------------------------------------------------------- -" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "- Summary" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "- (1) - Total of record(s) into CURGTA File                        :" $TotalRecordCURGTA >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "- (2) - Total of record(s) into CMGTAA File                        :" $TotalRecordCMGTAA >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "- (3) - Total of record(s) present into CURGTA AND not into CMGTAA :" $TotalRecordPresentIntoCURGTA >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "- (4) - Total of record(s) present into CMGTAA AND not into CURGTA :" $TotalRecordPresentIntoCMGTAA >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "- (5) - Total of record(s) present into CURGTA AND into CMGTAA     :" $TotalRecordPresentIntoThese2Files >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "- ---------------------------------------------------------------------- -" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"
echo "" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result.dat"

# - Error or not Error ?, that is the question !
if [ $TotalRecordPresentIntoCURGTA -eq 0 -a $TotalRecordPresentIntoCMGTAA -eq 0 ]
then
   #- No Error !!! :o ) Creation of a OK File. FTP Transfert will be done in PMUM0014.cmd.
   echo "" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result_OK.dat"
else
   #- No Error !!! :o ( Creation of a KO File. FTP Transfert will NOT be done in PMUM0014.cmd.
   echo "" >> "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA_Result_KO.dat"
fi

# - ------------------------ -
# - Step : 95
# -    Erase temporary files
# - ------------------------ -
NSTEP=${NJOB}_95
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESIX7000_CURGTA*_FILTERED_SUMMARIZED*.dat"
RMFIL "${DFILT}/${NJOB}_${IB}_${ENV_PREFIX}_ESID7050_CMGTAA*_FILTERED_SUMMARIZED*.dat"

# - ----------------------------- -
# - Job Over - That's All Folks !
# - ----------------------------- -
JOBEND
