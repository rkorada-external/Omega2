#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATION - INVENTAIRE
# nom du script SHELL		: ESFJ0065.cmd
# revision					: $Revision:   1.2  $
# date de creation			: 29/06/2020
# auteur					s: Charles Socie
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#  This chain get TL files from the estimation chain ESFD2553
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd

# Job Initialisation
JOBINIT


# Get parameters
TYPEINV=$1

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV..................: ${TYPEINV}"
ECHO_LOG "#===> CLOPRD...................: ${CLOPRD}"
ECHO_LOG "#===> EXTCHAIN_SII.............: ${EXTCHAIN_SII}"
ECHO_LOG "#===> REMOTE_SITE..............: ${REMOTE_SITE}"
ECHO_LOG "#===> DLEIFTECLEDSIIEP.........: ${ESF_DLEIFTECLEDSIIEP}"
ECHO_LOG "#========================================================================="

ECHO_LOG "#===> Sauvegarde fichier avant retraitement"
gzip -c ${ESF_DLEIFTECLEDSIIEP} > ${DSAV}/${SVG}_${ENV_PREFIX}_ESFD3820_DLEIFTECLEDSIIEP_${TYPEINV}.dat.gz

NSTEP=${NJOB}_10
#---------------------------------------------------------------------------
LIBEL="Get files from directories and merge them"
GET_FILES_DIR=${REMOTE_SITE}
GET_FILES_PREFIX=${EXTCHAIN_SII}
GET_FILES_MERGE="YES"
GET_FILES_O=${DFILT}/${NSTEP}_${IB}_DLEIFTECLEDSII_O_${NORME_CF}.dat
GET_FILES

NSTEP=${NJOB}_15
#---------------------------------------------------------------------------
LIBEL="Screening and sorting received file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I="${DFILT}/${NJOB}_10_${IB}_DLEIFTECLEDSII_O_${NORME_CF}.dat 2000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLEIFTECLEDSII_O_${NORME_CF}.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CLOPRD    125:1 - 125:,
        DBCLO_D   126:1 - 126:,
        CRE2_D    127:1 - 127:,
        ORGSSD_CF 128:1 - 128:
/CONDITION CURRENT_PRD CLOPRD EQ "${CLOPRD}"
/INCLUDE CURRENT_PRD
exit
EOF
SORT

#[003]
NSTEP=${NJOB}_16
#---------------------------------------------------------------------------
# Get the SubSiDiaries list that are going to be treated from internal exchanges
# SSD is the first column of the file
# Extract first column from file and get unique values
#---------------------------------------------------------------------------
LIBEL="Get subsidiaries to be treated"
SORT_I=${DFILT}/${NJOB}_15_${IB}_SORT_DLEIFTECLEDSII_O_${NORME_CF}.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_SSDLST_O_${NORME_CF}.dat
echo $SORT_I
echo $SORT_O

#[004]
cut -d~ -f1,128 ${SORT_I} | sort | uniq > $SORT_O

echo "FINI"

#[003] [004]
if [ -s ${DFILT}/${NJOB}_16_${IB}_SORT_SSDLST_O_${NORME_CF}.dat ]
then
  NSTEP=${NJOB}_17
  #---------------------------------------------------------------------------
  # Set subsidiaries that are going to be treated on 1 line
  # and create a condition statement to be used in a SORT command
  #---------------------------------------------------------------------------
  LIBEL="SSD Condition creation"
  COND_SSD=`cat ${DFILT}/${NJOB}_16_${IB}_SORT_SSDLST_O_${NORME_CF}.dat | awk -v flg=Y 'BEGIN{FS="~"} {if (flg=="Y") {flg="N"} else {print " OR ";} print "(SSD_CF="\$1 " AND ORGSSD_CF="\$2 ")";}'`
else
  # Condition bidon : pour ne rien omettre
  COND_SSD="SSD_CF=999 and ORGSSD_CF=999"
fi
ECHO_LOG  "COND_SSD => ${COND_SSD}"

#[003]
NSTEP=${NJOB}_19
#---------------------------------------------------------------------------
LIBEL="Remove SSD that are going to be treated"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I="${ESF_DLEIFTECLEDSIIEP} 2000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLEIFTECLEDSIIEP_O_${NORME_CF}.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF      1:1 -   1:EN,
        ORGSSD_CF 128:1 - 128:EN
/CONDITION COND_SSD $COND_SSD
/OMIT COND_SSD
exit
EOF
SORT

#[003] [004]
NSTEP=${NJOB}_20
#---------------------------------------------------------------------------
LIBEL="Screening and sorting old file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I="${DFILT}/${NJOB}_19_${IB}_SORT_DLEIFTECLEDSIIEP_O_${NORME_CF}.dat 2000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLEIFTECLEDSIIEP_O_${NORME_CF}.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CLOPRD    125:1 - 125:,
        DBCLO_D   126:1 - 126:,
        CRE2_D    127:1 - 127:,
        ORGSSD_CF 128:1 - 128:
/CONDITION CURRENT_PRD CLOPRD EQ "${CLOPRD}"
/INCLUDE CURRENT_PRD
exit
EOF
SORT

#[005]
cut -d~ -f1,127,128 ${DFILT}/${NJOB}_15_${IB}_SORT_DLEIFTECLEDSII_O_${NORME_CF}.dat | awk -F~ '{ print $1 "~" $3 "~" $2; }' | sort -u > ${DFILT}/${NJOB}_21_${IB}_SORT_DLEIFTECLEDSIICOND_O_${NORME_CF}.dat
nbrec=`wc -l ${DFILT}/${NJOB}_21_${IB}_SORT_DLEIFTECLEDSIICOND_O_${NORME_CF}.dat | cut -d" " -f1`
ssdOld=`head -1 ${DFILT}/${NJOB}_21_${IB}_SORT_DLEIFTECLEDSIICOND_O_${NORME_CF}.dat | cut -d~ -f1`
orgssdOld=`head -1 ${DFILT}/${NJOB}_21_${IB}_SORT_DLEIFTECLEDSIICOND_O_${NORME_CF}.dat | cut -d~ -f2`
dateOld=`head -1 ${DFILT}/${NJOB}_21_${IB}_SORT_DLEIFTECLEDSIICOND_O_${NORME_CF}.dat | cut -d~ -f3`

#[005]
NSTEP=${NJOB}_22
# Construit les conditions SSD_CF and CRE2_D pour filtrer les entrees OI
#-----------------------------------------------------------------------------
LIBEL="Construit les conditions SSD_CF and CRE2_D pour filtrer les entrees OI"
AWK_I=${DFILT}/${NJOB}_21_${IB}_SORT_DLEIFTECLEDSIICOND_O_${NORME_CF}.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLEIFTECLEDSIICOND_O_${NORME_CF}.dat
AWK_PARAM=" -v nbrec=${nbrec} -v ssdOld=${ssdOld} -v orgssdOld=${orgssdOld} -v dateOld=${dateOld} -v first=y "
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
{
  ssdNew = \$1
  orgssdNew = \$2
  dateNew = \$3
  if (ssdOld != ssdNew || orgssdOld != orgssdNew)
  {
    if (first == "n") s1 = s1 " OR "
    else
    {
      s1 = ""
      first = "n"
    }
    print s1 "(SSD_CF = " ssdOld " and CRE2_D = " dateOld " and ORGSSD_CF = " orgssdOld ")"
    s1 = ""
  }
  ssdOld = ssdNew
  dateOld = dateNew
  orgssdOld = orgssdNew
  if (FNR == nbrec)
  {
    if (first == "n") s1 = s1 " OR "
    print s1 "(SSD_CF = " ssdOld " and CRE2_D = " dateOld " and ORGSSD_CF = " orgssdOld ")"
  }
}
exit
EOF
AWK

COND_SSDCRE2=`cat ${DFILT}/${NJOB}_22_${IB}_AWK_DLEIFTECLEDSIICOND_O_${NORME_CF}.dat`
ECHO_LOG  "COND_SSDCRE2 => ${COND_SSDCRE2}"

#[005]
if [ -s ${DFILT}/${NJOB}_22_${IB}_AWK_DLEIFTECLEDSIICOND_O_${NORME_CF}.dat ]
then
  NSTEP=${NJOB}_23
  #---------------------------------------------------------------------------
  LIBEL="Filtering input OI to take only last file if several extracted"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_NOINFILE="YES"
  SORT_I="${DFILT}/${NJOB}_15_${IB}_SORT_DLEIFTECLEDSII_O_${NORME_CF}.dat 2000 1"
  SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLEIFTECLEDSII_O_${NORME_CF}.dat
  INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF      1:1 -   1:EN,
        CRE2_D    127:1 - 127:EN,
        ORGSSD_CF 128:1 - 128:EN
/CONDITION LAST_FILE ${COND_SSDCRE2}
/INCLUDE LAST_FILE
exit
EOF
  SORT
else
  NSTEP=${NJOB}_24
  # Begin execksh
  #-----------------------------------------------------------------
  LIBEL="mv ${DFILT}/${NJOB}_15_${IB}_SORT_DLEIFTECLEDSII_O_${NORME_CF}.dat ${DFILT}/${NJOB}_23_${IB}_SORT_DLEIFTECLEDSII_O_${NORME_CF}.dat"
  EXECKSH_MODE=P
  EXECKSH "mv ${DFILT}/${NJOB}_15_${IB}_SORT_DLEIFTECLEDSII_O_${NORME_CF}.dat ${DFILT}/${NJOB}_23_${IB}_SORT_DLEIFTECLEDSII_O_${NORME_CF}.dat"
fi

NSTEP=${NJOB}_30
#[001] No more SUM /STABLE
#[001] Test on INV type added
#[002] SUM added because a SUMMARIZE has been added in the sending prg (ESID3703)
#[004]
#---------------------------------------------------------------------------
LIBEL="Summarizing file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_23_${IB}_SORT_DLEIFTECLEDSII_O_${NORME_CF}.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_20_${IB}_SORT_DLEIFTECLEDSIIEP_O_${NORME_CF}.dat 2000 1"
SORT_O=${ESF_DLEIFTECLEDSIIEP}
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
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
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:EN,
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
        FIN              55:1 - 119:,
        COEF_LOB        120:1 - 120:,
        DSCCUR_CF       121:1 - 121:,
        COMMENT         122:1 - 122:,
        TOTAUX_M        123:1 - 123:EN 15/3,
        CLISSD_NF       124:1 - 124:,
        CLOPRD          125:1 - 125:,
        DBCLO_D         126:1 - 126:,
        CRE2_D          127:1 - 127:,
        ORGSSD_CF       128:1 - 128:
/KEYS   SSD_CF,
        ESB_CF,
        BALSHEY_NF,
        BALSHRMTH_NF,
        BALSHRDAY_NF,
        TRNCOD_CF,
        DBLTRNCOD_CF,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        OCCYEA_NF,
        ACY_NF,
        SCOSTRMTH_NF,
        SCOENDMTH_NF,
        CED_NF,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        RETOCCYEA_NF,
        RETACY_NF,
        RETSCOSTRMTH_NF,
        RETSCOENDMTH_NF,
        PLC_NT,
        RTO_NF,
        ACMTRS_NT,
        ACMCUR_CF,
        PRS_CF,
        NORME_CF,
        RATING_CF,
        PATCAT_CT,
        PATTYP_CT,
        PATTERN_ID,
        DSCCUR_CF
exit
EOF
SORT

NSTEP=${NJOB}_35
#------------------------------------------------------------------------------
LIBEL="Remove temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
