#!/bin/ksh
#===============================================================
# application name               : Export to UW abstract
# source name                    : ESEJ2031.cmd
# revision                       : $Revision:   1.0  $
# creation date                  : 27/11/2013
# author                         : Ashish Kumar Singh
# specifications references      : BTH-SEG-803647
#---------------------------------------------------------------
# description :
# Script that exports segmentation results to the UWAbstract schema
#
# parameters :
# $PRM = parameters file
#---------------------------------------------------------------
# modifications chronology:
#   20/02/2014    Nicolas Gasull    Move script content to ESEJ2031.cmd, externalizing it from segmentation night batch execution
#   02/12/2014    Nicolas Gasull    Fetch segmentation results from $DFILP instead of in any specific $DFILP's subfolder
#   30/03/2018	  Parth Patel	    SPIRA #67812 Make SEG results available in BO. STEPS: 01, 22, 23, 23_5, 24, 25, 32, 33, 33_5, 34, 35, 45_5, 46, 47, 50_5, 51, 54, 54_5, 55, 55_5, 56, 65
#   25/10/2018	  KBagwe		    New contracts sections are missing in TUWSEC [IN:071774]
#	21/05/2109	  Parth Patel		Modify the maximum record length of syncsort from 2048 to 3072 [IN:78469] STEPS: 10, 20, 30, 40
#	11/03/2020	  Parth Patel		Segmentation optimization [MOD 06] [IN:085489]
#===============================================================
#set -x

#*******************************************************************

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctws.cmd

JOBINIT

SEG_RESULTS_PATTERN_ASM="${DFILP}/${ENV_PREFIX}_SEG_${HOST_PRDSIT}_ASM_RESULT_*.dat"
SEG_RESULTS_PATTERN_RETRO="${DFILP}/${ENV_PREFIX}_SEG_${HOST_PRDSIT}_RETRO_RESULT_*.dat"

NSTEP=${NJOB}_SEG_LEG_UW_01
LIBEL="INITIALIZE VARIABLES"
STEPSTART
ASSCOLS=""	# COLUMNS OF ASSUMED TABLE TUWSECRA
RETCOLS=""	# COLUMNS OF RETRO TABLE TUWRETSECRA
FIRASSLEN=""	# NUMBER OF COLUMNS IN ASSUMED TABLE TUWSEC
ASSSTR=""	# STARTING COLUMN NUMBER OF TABLE TUWSECRA IN FILE
TOTASSLEN=""	# NUMBER OF COLUMNS IN MIXED ASSUMED FILE
TOTRETLEN=""	# NUMBER OF COLUMNS IN MIXED RETRO FILE
FIRRETLEN=""	# NUMBER OF COLUMNS IN RETRO TABLE TUWRETSEC
RETSTR=""	# STARTING COLUMN NUMBER OF TABLE TUWRETSECRA IN FILE
STEPEND $?


NSTEP=${NJOB}_SEG_LEG_UW_05
LIBEL="Concatenating latest segmentation results"
STEPSTART
SEG_RESULTS_ASM=${DFILT}/${NSTEP}_${IB}_SEG_${HOST_PRDSIT}_ASM_RESULTS.dat
SEG_RESULTS_RETRO=${DFILT}/${NSTEP}_${IB}_SEG_${HOST_PRDSIT}_RETRO_RESULTS.dat

# Concatenate last assumed results by segmentation if exist
if ls $SEG_RESULTS_PATTERN_ASM > /dev/null 2>&1 ; then
	cat $SEG_RESULTS_PATTERN_ASM > $SEG_RESULTS_ASM
else
	touch $SEG_RESULTS_ASM
fi

# Concatenate last retro results by segmentation if exist
if ls $SEG_RESULTS_PATTERN_RETRO > /dev/null 2>&1 ; then
	cat $SEG_RESULTS_PATTERN_RETRO > $SEG_RESULTS_RETRO
else
	touch $SEG_RESULTS_RETRO
fi
STEPEND $?


NSTEP=${NJOB}_SEG_LEG_UW_10
# Sort Assumed Contracts from segmentation batch results
#----------------------------------------------------------------------------
LIBEL="Sort Assumed Contracts from segmentation batch results"
SORT_WDIR=${SORTWORK}
SORT_FS=$'\x1c'
SORT_CMD=`CFTMP`
SORT_I="$SEG_RESULTS_ASM 3072 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ASSUMED_TSEGRUNRES_O.dat"
ASSUMED_SEG_RESULT_FILE=${SORT_O}
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	CTR_NF 7:1 - 7:9,
	SEC_NF 10:1 - 10:EN,
	UWY_NF 8:1 - 8:EN,
	UW_NT 9:1 - 9:EN
/KEYS 
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT
exit
EOF
SORT	


NSTEP=${NJOB}_SEG_LEG_UW_20
# Sort Retro Contracts from segmentation batch results
#----------------------------------------------------------------------------
LIBEL="Sort Retro Contracts from segmentation batch results"
SORT_WDIR=${SORTWORK}
SORT_FS=$'\x1c'
SORT_CMD=`CFTMP`
SORT_I="$SEG_RESULTS_RETRO 3072 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_RETRO_TSEGRUNRES_O.dat"
RETRO_SEG_RESULT_FILE=${SORT_O}
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	CTR_NF 7:1 - 7:9,
	SEC_NF 10:1 - 10:EN,
	UWY_NF 8:1 - 8:EN,
	RTO_NF 9:1 - 9:EN
/KEYS
	CTR_NF,
	SEC_NF,
	UWY_NF,
	RTO_NF
exit
EOF
# Sort descending RTO: BUs prefer always having the highest RTO in case there are different segments for the same C/S/U but different RTOs
SORT


NSTEP=${NJOB}_22
# Get column list of TUWSECRA
#----------------------------------------------------------------------------
LIBEL="Get column list of BSBO..TUWSECRA"
BCP_WAY="OUT"; BCP_VER="+"; BCP_FS=','
BCP_O=${DFILT}/${NSTEP}_${IB}_${PRG}TUWSECRA_COLUMNS_O.dat
BCP_QRY="SELECT SGTRQST_T from BEST..TSEGUWTABLE where SGTUWTAB_CF = 'TUWSECRA'"
BCP


NSTEP=${NJOB}_23
#-----------------------------------------------------------------------------
LIBEL="Convert Delimiter tilde to comma"
AWK_I=${DFILT}/${NJOB}_22_${IB}_${PRG}TUWSECRA_COLUMNS_O.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_${PRG}TUWSECRA_COMMA_O.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="," }
    { \$1 = \$1; print \$0 }
exit
EOF
AWK

NSTEP=${NJOB}_23_5
LIBEL="ASSIGN COLUMNS TO VARIABLE"
STEPSTART
ASSCOLS=`cat ${DFILT}/${NJOB}_23_${IB}_${PRG}TUWSECRA_COMMA_O.dat`
STEPEND $?

# [MOD 6]
NSTEP=${NJOB}_SEG_LEG_UW_24
# Extract Assumed Contracts from BSBO..TUWSEC
#----------------------------------------------------------------------------
LIBEL="BCP out BSBO..TUWSEC"
BCP_WAY="OUT"; BCP_VER=""; BCP_FS=$'\x1c'
BCP_O=${DFILT}/${NSTEP}_${IB}_${PRG}_TUWSEC_O.dat
BCP_TABLE="BSBO..TUWSEC partition PUWSEC_${USR}"
#BCP_QRY="select a.* from BSBO..TUWSEC a inner join BREF..TBATCHSSD b on a.ssd_Cf = b.ssd_cf and b.batchuser_cf = suser_name()"
BCP

# [MOD 6]
NSTEP=${NJOB}_SEG_LEG_UW_25
# Extract Assumed Contracts from BSBO..TUWSECRA
#----------------------------------------------------------------------------
LIBEL="BCP out BSBO..TUWSECRA"
BCP_WAY="OUT"; BCP_VER=""; BCP_FS=$'\x1c'
BCP_O=${DFILT}/${NSTEP}_${IB}_${PRG}_TUWSECRA_O.dat
BCP_TABLE="BSBO..TUWSECRA partition PUWSECRA_${USR}"
#BCP_QRY="select a.* from BSBO..TUWSECRA a inner join BREF..TBATCHSSD b on a.ssd_Cf = b.ssd_cf and b.batchuser_cf = suser_name()"
BCP

# [MOD 6]
NSTEP=${NJOB}_26
#------------------------------------------------------------------------------
LIBEL="Calculate number of columns in TUWSECRA" 
ISQL_QRY=`CFTMP`
ISQL_BASE=BSBO
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
INPUT_TEXT ${ISQL_QRY} << EOF
SELECT top 1 count(1)
FROM BSBO..syscolumns sc  INNER JOIN BSBO..sysobjects so ON sc.id = so.id 
WHERE so.name = 'TUWSECRA' And sc.status3=0 order by sc.colid asc
go
exit
EOF
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_FRES_O1.dat
ISQL_INFO

TUWSECRA_COL=`cat ${ISQL_FRES} | sed '1,\$s/ //g'`

# [MOD 6]
NSTEP=${NJOB}_SEG_LEG_UWMERGE_30
# Vertial Merge
#------------------------------------------------------------------------------
LIBEL="Sort and merge assumed contracts from BSBO..TUWSEC and BSBO..TUWSECRA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_FS=$'\x1c'
SORT_I="${DFILT}/${NJOB}_SEG_LEG_UW_24_${IB}_${PRG}_TUWSEC_O.dat 3072 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_MERGE_ASSUMED_TUWSEC_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF_F1 1:1 - 1:,
        UWY_NF_F1 2:1 - 2:,
        UW_NT_F1  3:1 - 3:,
        END_NT_F1 4:1 - 4:,
        SEC_NF_F1 5:1 - 5:,
        SSD_CF_F1 6:1 - 6:,
		REST_COL_F1 1:,
        CTR_NF_F2 1:1 - 1:,
        UWY_NF_F2 2:1 - 2:,
        UW_NT_F2  3:1 - 3:,
        SEC_NF_F2 5:1 - 5:,
        END_NT_F2 4:1 - 4:,
        SSD_CF_F2 6:1 - 6:,
		REST_COL_F2 7:1 - ${TUWSECRA_COL}:
/JOINKEYS CTR_NF_F1,
          UWY_NF_F1,
          UW_NT_F1,
          END_NT_F1,
          SEC_NF_F1,
          SSD_CF_F1
/INFILE ${DFILT}/${NJOB}_SEG_LEG_UW_25_${IB}_${PRG}_TUWSECRA_O.dat 3072 1 X"1C"
/JOINKEYS CTR_NF_F2,
          UWY_NF_F2,
          UW_NT_F2,
          END_NT_F2,
          SEC_NF_F2,
          SSD_CF_F2
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT leftside :REST_COL_F1,
          rightside :REST_COL_F2
exit
EOF
SORT


NSTEP=${NJOB}_SEG_LEG_UW_31
# Sort Assumed Contracts from BSBO..TUWSEC
#----------------------------------------------------------------------------
LIBEL="Sort Assumed Contracts from BSBO..TUWSEC"
SORT_WDIR=${SORTWORK}
SORT_FS=$'\x1c'
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_SEG_LEG_UWMERGE_30_${IB}_SORT_MERGE_ASSUMED_TUWSEC_O.dat 3072 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ASSUMED_TUWSEC_O.dat"
ASSUMED_UWA_FILE=${SORT_O}
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	CTR_NF 1:1 - 1:9,
	SEC_NF 5:1 - 5:EN,
	UWY_NF 2:1 - 2:EN,
	UW_NT  3:1 - 3:EN
/KEYS
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_32
# Get column list of TUWRETSECRA
#----------------------------------------------------------------------------
LIBEL="Get column list of BSBO..TUWRETSECRA"
BCP_WAY="OUT"; BCP_VER="+"; BCP_FS=','
BCP_O=${DFILT}/${NSTEP}_${IB}_${PRG}TUWRETSECRA_COLUMNS_O.dat
BCP_QRY="SELECT SGTRQST_T from BEST..TSEGUWTABLE where SGTUWTAB_CF = 'TUWRETSECRA'"
BCP


NSTEP=${NJOB}_33
#-----------------------------------------------------------------------------
LIBEL="Convert Delimiter tilde to comma"
AWK_I=${DFILT}/${NJOB}_32_${IB}_${PRG}TUWRETSECRA_COLUMNS_O.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_${PRG}TUWRETSECRA_COMMA_O.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="," }
    { \$1 = \$1; print \$0 }
exit
EOF
AWK

NSTEP=${NJOB}_33_5
LIBEL="ASSIGN COLUMNS TO VARIABLE"
STEPSTART
RETCOLS=`cat ${DFILT}/${NJOB}_33_${IB}_${PRG}TUWRETSECRA_COMMA_O.dat`
STEPEND $?

# [MOD 6]
NSTEP=${NJOB}_SEG_LEG_UW_34
# Extract Assumed Contracts from BSBO..TUWRETSEC
#----------------------------------------------------------------------------
LIBEL="BCP out BSBO..TUWRETSEC"
BCP_WAY="OUT"; BCP_VER=""; BCP_FS=$'\x1c'
BCP_O=${DFILT}/${NSTEP}_${IB}_${PRG}_TUWRETSEC_O.dat
BCP_TABLE="BSBO..TUWRETSEC partition PUWRETSEC_${USR}"
#BCP_QRY="select a.* from BSBO..TUWRETSEC a inner join BREF..TBATCHSSD b on a.ssd_Cf = b.ssd_cf and b.batchuser_cf = suser_name()"
BCP

# [MOD 6]
NSTEP=${NJOB}_SEG_LEG_UW_35
# Extract Assumed Contracts from BSBO..TUWRETSECRA
#----------------------------------------------------------------------------
LIBEL="BCP out BSBO..TUWRETSECRA"
BCP_WAY="OUT"; BCP_VER=""; BCP_FS=$'\x1c'
BCP_O=${DFILT}/${NSTEP}_${IB}_${PRG}_TUWRETSECRA_O.dat
BCP_TABLE="BSBO..TUWRETSECRA partition PUWRETSECRA_${USR}"
#BCP_QRY="select a.* from BSBO..TUWRETSECRA a inner join BREF..TBATCHSSD b on a.ssd_Cf = b.ssd_cf and b.batchuser_cf = suser_name()"
BCP

# [MOD 6]
NSTEP=${NJOB}_36
#------------------------------------------------------------------------------
LIBEL="Calculate number of columns in TUWRETSECRA" 
ISQL_QRY=`CFTMP`
ISQL_BASE=BSBO
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
INPUT_TEXT ${ISQL_QRY} << EOF
SELECT top 1 count(1)
FROM BSBO..syscolumns sc  INNER JOIN BSBO..sysobjects so ON sc.id = so.id 
WHERE so.name = 'TUWRETSECRA' And sc.status3=0 order by sc.colid asc
go
exit
EOF
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_FRES_O1.dat
ISQL_INFO

TUWRETSECRA_COL=`cat ${ISQL_FRES} | sed '1,\$s/ //g'`

# [MOD 6]
NSTEP=${NJOB}_SEG_LEG_UWMERGE_40
# Vertial Merge
#------------------------------------------------------------------------------
LIBEL="Sort and merge assumed contracts from BSBO..TUWRETSEC and BSBO..TUWRETSECRA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_FS=$'\x1c'
SORT_I="${DFILT}/${NJOB}_SEG_LEG_UW_34_${IB}_${PRG}_TUWRETSEC_O.dat 3072 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_MERGE_RETRO_TUWRETSEC_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF_F1 1:1 - 1:,
        RTY_NF_F1 2:1 - 2:,
        RETSEC_NF_F1 3:1 - 3:,
        SSD_CF_F1 4:1 - 4:,
		REST_COLS_F1 1:,
        RETCTR_NF_F2 1:1 - 1:,
        RTY_NF_F2 2:1 - 2:,
        RETSEC_NF_F2 3:1 - 3:,
        SSD_CF_F2 4:1 - 4:,
		REST_COLS_F2 5:1 - ${TUWRETSECRA_COL}:
/JOINKEYS RETCTR_NF_F1,
          RTY_NF_F1,
          RETSEC_NF_F1,
          SSD_CF_F1
/INFILE ${DFILT}/${NJOB}_SEG_LEG_UW_35_${IB}_${PRG}_TUWRETSECRA_O.dat 3072 1 X"1C"
/JOINKEYS RETCTR_NF_F2,
          RTY_NF_F2,
          RETSEC_NF_F2,
          SSD_CF_F2
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT leftside :REST_COLS_F1,
          rightside :REST_COLS_F2
exit
EOF
SORT


NSTEP=${NJOB}_SEG_LEG_UW_41
# Sort Retro Contracts from BSBO..TUWRETSEC
#----------------------------------------------------------------------------
LIBEL="Sort Retro Contracts from BSBO..TUWRETSEC"
SORT_WDIR=${SORTWORK}
SORT_FS=$'\x1c'
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_SEG_LEG_UWMERGE_40_${IB}_SORT_MERGE_RETRO_TUWRETSEC_O.dat 3072 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_RETRO_TUWRETSEC_O.dat"
RETRO_UWA_FILE=${SORT_O}
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	RETCTR_NF 1:1 - 1:9,
	RETSEC_NF 3:1 - 3:EN,
	RTY_NF 2:1 - 2:EN
/KEYS
	RETCTR_NF,
	RETSEC_NF,
	RTY_NF
exit
EOF
SORT



UPDATED_ASSUMED_UWA="`echo ${ASSUMED_UWA_FILE}|cut -d'.' -f1`_TMP.dat"
UPDATED_RETRO_UWA="`echo ${RETRO_UWA_FILE}|cut -d'.' -f1`_TMP.dat"

NSTEP=${NJOB}_SEG_LEG_UW_43
# Create destination files (initialize good permissions)
#----------------------------------------------------------------------------
LIBEL="Prepare temporary files for perimeter update"
STEPSTART
touch "$UPDATED_ASSUMED_UWA" "$UPDATED_RETRO_UWA"
STEPEND $?


NSTEP=${NJOB}_SEG_LEG_UW_45
# Begin webservice
#----------------------------------------------------------------------------
LIBEL="Export to UWAbstract"
WS_BATCH_NAME=segmentationUpdateUWA
WS_PARAMS_TEXT << EOF
ASSUMED_SEG_RESULT_FILE		${ASSUMED_SEG_RESULT_FILE}
RETRO_SEG_RESULT_FILE		${RETRO_SEG_RESULT_FILE}
ASSUMED_UWA_FILE		${ASSUMED_UWA_FILE}
RETRO_UWA_FILE			${RETRO_UWA_FILE}
EOF
WS_OUTPUT_FILE=${DFILT}/${NSTEP}_${IB}_${WS_BATCH_NAME}_O.dat
WS_BATCH

if [ -s ${UPDATED_ASSUMED_UWA} ]
then


NSTEP=${NJOB}_45_5
LIBEL="ASSIGN NUMBER OF COLUMNS IN OUTPUT FILE TO VARIALBE"
STEPSTART
TOTASSLEN=`awk -F$'\x1c' '{print NF; exit}' $UPDATED_ASSUMED_UWA`
STEPEND $?


NSTEP=${NJOB}_46
#------------------------------------------------------------------------------
LIBEL="Calculate number of columns in TUWSEC" 
ISQL_QRY=`CFTMP`
ISQL_BASE=BSBO
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
INPUT_TEXT ${ISQL_QRY} << EOF
SELECT top 1 count(1)
FROM BSBO..syscolumns sc  INNER JOIN BSBO..sysobjects so ON sc.id = so.id 
WHERE so.name = 'TUWSEC' And sc.status3=0 order by sc.colid asc
go
exit
EOF
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_FRES_O1.dat
ISQL_INFO



NSTEP=${NJOB}_47
#-----------------------------------------------------------------
LIBEL="CUT THE FILE TO GET COLUMNS FOR TABLE TUWSEC"
EXECKSH_MODE=P
FIRASSLEN=`cat ${ISQL_FRES} | sed '1,\$s/ //g'`
EXECKSH "cut -d$'\x1c' -f1-$FIRASSLEN $UPDATED_ASSUMED_UWA > ${DFILT}/${NJOB}_SEG_LEG_UW_50_${IB}_UPDATED_TUWSEC_I.dat"

	NSTEP=${NJOB}_SEG_LEG_UW_50
	#----------------------------------------------------------------------------
	LIBEL="BCP IN BSBO..TUWSEC"
	BCP_WAY="IN"; BCP_FS=$'\x1c'; BCP_VER=""
	BCP_TRUNCATE="YES"
	BCP_PARTITION="YES"
	BCP_UPDATE_INDEX_STAT="YES"
	BCP_I=${DFILT}/${NJOB}_SEG_LEG_UW_50_${IB}_UPDATED_TUWSEC_I.dat
	BCP_TABLE=BSBO..TUWSEC
	BCP


NSTEP=${NJOB}_50_5
#-----------------------------------------------------------------
LIBEL="CUT THE FILE TO GET COLUMNS FOR  TABLE TUWSECRA"
EXECKSH_MODE=P
ASSSTR=`expr ${FIRASSLEN} + 1`
if [ ! -z "${ASSCOLS}" -a "${ASSCOLS}" != " " ]
then
	EXECKSH "cut -d$'\x1c' -f1-6,$ASSSTR-$TOTASSLEN $UPDATED_ASSUMED_UWA > ${DFILT}/${NJOB}_SEG_LEG_UW_51_${IB}_UPDATED_TUWSECRA_I.dat"
else
        EXECKSH "cut -d$'\x1c' -f1-6 $UPDATED_ASSUMED_UWA > ${DFILT}/${NJOB}_SEG_LEG_UW_51_${IB}_UPDATED_TUWSECRA_I.dat"
fi

	NSTEP=${NJOB}_SEG_LEG_UW_51
	#----------------------------------------------------------------------------
	LIBEL="BCP IN BSBO..TUWSECRA"
	BCP_WAY="IN"; BCP_FS=$'\x1c'; BCP_VER=""
	BCP_TRUNCATE="YES"
	BCP_PARTITION="YES"
	BCP_UPDATE_INDEX_STAT="YES"
	BCP_I=${DFILT}/${NJOB}_SEG_LEG_UW_51_${IB}_UPDATED_TUWSECRA_I.dat
	BCP_TABLE=BSBO..TUWSECRA
	BCP

fi

if [ -s ${UPDATED_RETRO_UWA} ]
then

TOTRETLEN=`awk -F$'\x1c' '{print NF; exit}' $UPDATED_RETRO_UWA`

NSTEP=${NJOB}_54
#------------------------------------------------------------------------------
LIBEL="Calculate number of columns in TUWRETSEC"
ISQL_QRY=`CFTMP`
ISQL_BASE=BSBO
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
INPUT_TEXT ${ISQL_QRY} << EOF
SELECT top 1 count(1)
FROM BSBO..syscolumns sc  INNER JOIN BSBO..sysobjects so ON sc.id = so.id 
WHERE so.name = 'TUWRETSEC' And sc.status3=0 order by sc.colid asc
go
exit
EOF
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_FRES_O1.dat
ISQL_INFO



NSTEP=${NJOB}_54_5
#-----------------------------------------------------------------
LIBEL="CUT THE FILE TO GET COLUMNS FOR  TABLE TUWRETSEC"
EXECKSH_MODE=P
FIRRETLEN=`cat ${ISQL_FRES} | sed '1,\$s/ //g'`
EXECKSH "cut -d$'\x1c' -f1-$FIRRETLEN $UPDATED_RETRO_UWA > ${DFILT}/${NJOB}_SEG_LEG_UW_55_${IB}_UPDATED_TUWRETSEC_I.dat"

	NSTEP=${NJOB}_SEG_LEG_UW_55
	#----------------------------------------------------------------------------
	LIBEL="BCP IN BSBO..TUWRETSEC"
	BCP_WAY="IN"; BCP_FS=$'\x1c'; BCP_VER=""
	BCP_TRUNCATE="YES"
	BCP_PARTITION="YES"
	BCP_UPDATE_INDEX_STAT="YES"
	BCP_I=${DFILT}/${NJOB}_SEG_LEG_UW_55_${IB}_UPDATED_TUWRETSEC_I.dat
	BCP_TABLE=BSBO..TUWRETSEC
	BCP
	

NSTEP=${NJOB}_55_5
#-----------------------------------------------------------------
LIBEL="CUT THE FILE TO GET COLUMNS FOR  TABLE TUWRETSECRA"
EXECKSH_MODE=P
RETSTR=`expr ${FIRRETLEN} + 1`
if [ ! -z "${RETCOLS}" -a "${RETCOLS}" != " " ]
then
        EXECKSH "cut -d$'\x1c' -f1-4,$RETSTR-$TOTRETLEN $UPDATED_RETRO_UWA > ${DFILT}/${NJOB}_SEG_LEG_UW_56_${IB}_UPDATED_TUWRETSECRA_I.dat"
else
        EXECKSH "cut -d$'\x1c' -f1-4 $UPDATED_RETRO_UWA > ${DFILT}/${NJOB}_SEG_LEG_UW_56_${IB}_UPDATED_TUWRETSECRA_I.dat"
fi

	NSTEP=${NJOB}_SEG_LEG_UW_56
	#----------------------------------------------------------------------------
	LIBEL="BCP IN BSBO..TUWRETSECRA"
	BCP_WAY="IN"; BCP_FS=$'\x1c'; BCP_VER=""
	BCP_TRUNCATE="YES"
	BCP_PARTITION="YES"
	BCP_UPDATE_INDEX_STAT="YES"
	BCP_I=${DFILT}/${NJOB}_SEG_LEG_UW_56_${IB}_UPDATED_TUWRETSECRA_I.dat
	BCP_TABLE=BSBO..TUWRETSECRA
	BCP
	
fi


NSTEP=${NJOB}_SEG_LEG_UW_60
# Begin rm
#-----------------------------------------------------------------
LIBEL="Deleting job temporary files"
RMFIL "$SEG_RESULTS_ASM $SEG_RESULTS_RETRO $ASSUMED_UWA_RAW_FILE $RETRO_UWA_RAW_FILE $ASSUMED_SEG_RESULT_FILE $RETRO_SEG_RESULT_FILE $ASSUMED_UWA_FILE $RETRO_UWA_FILE $UPDATED_ASSUMED_UWA $UPDATED_RETRO_UWA"


NSTEP=${NJOB}_SEG_LEG_UW_65
# Begin rm
#-----------------------------------------------------------------
LIBEL="Deleting job temporary files"
RMFIL "${DFILT}/${NJOB}_SEG_LEG_UW_50_${IB}_UPDATED_TUWSEC_I.dat ${DFILT}/${NJOB}_SEG_LEG_UW_51_${IB}_UPDATED_TUWSECRA_I.dat ${DFILT}/${NJOB}_SEG_LEG_UW_55_${IB}_UPDATED_TUWRETSEC_I.dat ${DFILT}/${NJOB}_SEG_LEG_UW_56_${IB}_UPDATED_TUWRETSECRA_I.dat"


JOBEND


