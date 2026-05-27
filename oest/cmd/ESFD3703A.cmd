#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Calcul des Cashflow 
# nom du script SHELL           : ESFD3703A.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 20/05/2019
# auteur                        : JYP - PERSEE
# references des specifications :
#-----------------------------------------------------------------------------
# description
#               Calculate cashflow in a separate chain/job (this part is extracted from ESID3703.cmd) 
#
#-----------------------------------------------------------------------------
#     historiques des modifications
#
#[001] 30/04/2019 :spira 70377 : JYP : duplicate cash part from ESID3703.cmd and readjust to be reused by IFRS17 VTOM I17G 
#[002] 21/08/2019 :spira 70377 : JYP : rename mappings
#[003] 26/08/2019 :spira 70377 : JYP : bugfix NORME
#[004] 26/08/2019 :spira 70377 : JYP : bugfix PARM_ICLODAT_D and ACMTRS
#[005] 28/08/2019 :spira 70377 : JYP : bugfix currencies
#[006] 10/10/2019 :spira 70377 : JYP : bugfix currencies
#[007] 25/10/2019 :spira 81978 : LEL : bugfix make calculation steps for total amount
#[008] 29/10/2019 :spira 81978 : JYP : bugfix empty line and merge INI/TOT files
#[009] 30/10/2019 :spira 81978 : JYP : bugfix total amount and X years amount
#[010] 31/01/2020 :spira 84167 : JYP : bugfix pattern ICR
#[011] 13/05/2020 :spira 83206 : CS  : REQ 11.7 - For contract incepting before closing date please adapt the pattern used for discounting change input ESTC1056A 
#[012] 31/08/2020 Charles Socie : SPIRA 88975  IFRS17 add Retropericase to ESTC1056A
#[013] 07/07/2020 :spira 83206 : JYP/Diaeddine/Charles  : REQ 11.7 - For contract incepting before closing date : bugfix Assumed 
#[014] 24/09/2020 :spira 83206 : JYP/Diaeddine/Charles  : REQ 11.7 - For contract incepting before closing date : bugfix pericase 
#[015] 27/09/2021 :spira 96349 : JYP : transition : final SEG_NF should have lenght 10   
#[016] 30/06/2021 :spira 96654 : JYP : retroNP total amount issue
#[017] 03/09/2021 :spira 97357 : JYP : transition trimestrielisation
#[018] 25/10/2021 :spira 98636 : JYP : bugfix retro amount 
#[019] 21/02/2022 :spira 91532 : DaD : bugfix add RI in condition step 100 
#[020] 11/09/2024 :spira 112082 : DaD : new ratio RALIC_R and RALRC_R for RAP
#===============================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd



#[010]
TRIM_NF=`echo ${PARM_ICLODAT_D} | cut -c5-6 | awk '{ if ($0==3) print "1"; if ($0==6) print "2"; if ($0==9) print "3"; if ($0==12) print "4" }'`
CLOPRD=`echo ${PARM_ICLODAT_D} | awk '{print substr($0,1,6)}'`


# Job Initialisation
JOBINIT


IDF_CT=$1



if [ "${PATTYP_CT}" = "CUR" ]
then
   TYPE_OUTPUT="DSI"
else if [ "${PATTYP_CT}" = "CKI" ]
then
   TYPE_OUTPUT="LKI"
else
   TYPE_OUTPUT="INI"
fi
fi


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> NORME......................: ${NORME}"
ECHO_LOG "#===> param_Request_id...........: ${param_Request_id}  "
ECHO_LOG "#===> param_Context_id...........: ${param_Context_id}  "
ECHO_LOG "#===> IDF_CT.....................: ${IDF_CT} "
ECHO_LOG "#===> PATCAT_CT..................: ${PATCAT_CT}  "
ECHO_LOG "#===> PATTYP_CT..................: ${PATTYP_CT}  "
ECHO_LOG "#===> CONTEXT_CT.................: ${CONTEXT_CT} "
ECHO_LOG "#===> TYPE_OUTPUT................: ${TYPE_OUTPUT}  "
ECHO_LOG "#===> PARM0_CRE_D................: ${PARM0_CRE_D}"
ECHO_LOG "#===> TYPINV0....................: ${TYPINV0}"
ECHO_LOG "#===> TRIM_NF....................: ${TRIM_NF}"
ECHO_LOG "#===> PARM_ICLODAT_D.............: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> CLOPRD.....................: ${CLOPRD}"
ECHO_LOG "#===> PARM_IS_TRN ...............: ${PARM_IS_TRN}"
ECHO_LOG "#....................... INPUT ..........................................."
ECHO_LOG "#===> EPO_FSEGPATTERN_ICR............: ${EPO_FSEGPATTERN_ICR}"
ECHO_LOG "#===> EST_IADPERICASE_STD............: ${EST_IADPERICASE_STD}"
ECHO_LOG "#===> EST_IRDPERICASE................: ${EST_IRDPERICASE}"
ECHO_LOG "#===> EPO_IADPERICASE................: ${EPO_IADPERICASE}"
ECHO_LOG "#....................... input from job ESFD3651 (interm) ........................."
ECHO_LOG "#===> ESF_GTSII_CASHFLOW_WK.............: ${ESF_GTSII_CASHFLOW_WK}"
ECHO_LOG "#===> ESF_TOTAL_CASHFLOW_WK.............: ${DFILI}/${ENV_PREFIX}_ESFD3650_${IDF_CT}_TOTAL_CASHFLOW_WK.dat "
ECHO_LOG "#....................... OUTPUT ..........................................."
ECHO_LOG "#===> ESF_GTSII_CASHFLOW..............: $ESF_GTSII_CASHFLOW       "
ECHO_LOG "#========================================================================="


NSTEP=${NJOB}_10
LIBEL="touch GTSII file : ${ESF_GTSII_CASHFLOW}  "
EXECKSH_MODE=P
EXECKSH "touch ${ESF_GTSII_CASHFLOW} "


# transition option 
if [ "${PARM_IS_TRN}" = "YES" ] 
then
CONTEXT_CT="TRN"
fi


if [ -s ${EPO_FSEGPATTERN_ICR} ]
then

  PATTERN_CATEGORY="ICR  "

 #[011] add Context_ct, Closing_date and I3  
  NSTEP=${NJOB}_50
  #-----------------------------------------------------------------------------
  LIBEL="CSF CALCULATION - produce undiscounted GTSII file "
  PRG=ESTC1056A
  FPRM=`CFTMP`
  INPUT_TEXT ${FPRM} << EOF
TRIM_NF ${TRIM_NF}
PATTERN_CATEGORY ${PATTERN_CATEGORY}
CONTEXT_CT ${CONTEXT_CT}
CLOSINGDATE ${PARM_ICLODAT_D}
exit
EOF
  export ${PRG}_PRM=${FPRM}
  export ${PRG}_HOST_PRDSIT=${HOST_PRDSIT}
  #[013]
  export ${PRG}_I1=${ESF_GTSII_CASHFLOW_WK}
  export ${PRG}_I2=${EPO_FSEGPATTERN_ICR}
  export ${PRG}_I3=${EPO_IADPERICASE}
  export ${PRG}_I4=${EST_IRDPERICASE}
  export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_ESTC1056A_CASHFLOW.dat
  export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FSEGPATTERN_NOTUSED.dat
  export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_ESTC1056A_REMAINTOPAY_ULAE.dat
  export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_REMAINTOPAY_FHNI.dat
  EXECPRG
else

  NSTEP=${NJOB}_55
  # Copie fichiers
  #------------------------------------------------------------------------------
  LIBEL="CSF CALCULATION touch temporary cashflow file, no pattern file "
  EXECKSH_MODE=P
  EXECKSH "touch ${DFILT}/${NJOB}_50_${IB}_ESTC1056A_CASHFLOW.dat "
  
fi




# SORT  CASHFLOW
NSTEP=${NJOB}_70
#-----------------------------------------------------------------------------
LIBEL="Risk ADJ - SORT and overwrite the cashflow GTSII file "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_ESTC1056A_CASHFLOW.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IDF_CT}_GTSII_CASHFLOW_INI_AMT.dat OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
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
        ACMTRS_NT        42:1 - 42:3,
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
        PATCAT1_CT       52:1 - 52:3,
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
/SUMMARIZE TOTAL AM01_M, TOTAL AM02_M, TOTAL AM03_M, TOTAL AM04_M, TOTAL AM05_M, TOTAL AM06_M, TOTAL AM07_M, TOTAL AM08_M, TOTAL AM09_M, TOTAL AM10_M,
           TOTAL AM11_M, TOTAL AM12_M, TOTAL AM13_M, TOTAL AM14_M, TOTAL AM15_M, TOTAL AM16_M, TOTAL AM17_M, TOTAL AM18_M, TOTAL AM19_M, TOTAL AM20_M,
           TOTAL AM21_M, TOTAL AM22_M, TOTAL AM23_M, TOTAL AM24_M, TOTAL AM25_M, TOTAL AM26_M, TOTAL AM27_M, TOTAL AM28_M, TOTAL AM29_M, TOTAL AM30_M,
           TOTAL AM31_M, TOTAL AM32_M, TOTAL AM33_M, TOTAL AM34_M, TOTAL AM35_M, TOTAL AM36_M, TOTAL AM37_M, TOTAL AM38_M, TOTAL AM39_M, TOTAL AM40_M,
           TOTAL AM41_M, TOTAL AM42_M, TOTAL AM43_M, TOTAL AM44_M, TOTAL AM45_M, TOTAL AM46_M, TOTAL AM47_M, TOTAL AM48_M, TOTAL AM49_M, TOTAL AM50_M,
           TOTAL AM51_M, TOTAL AM52_M, TOTAL AM53_M, TOTAL AM54_M, TOTAL AM55_M, TOTAL AM56_M, TOTAL AM57_M, TOTAL AM58_M, TOTAL AM59_M, TOTAL AM60_M,
           TOTAL AM61_M, TOTAL AM62_M, TOTAL AM63_M, TOTAL AM64_M, TOTAL AM65_M,
           TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M, TOTAL ACMAMT_M, TOTAL TOTAUX_M
/CONDITION COND_ACCEPT ( TYP_CT EQ "A" ) 
/DERIVEDFIELD PATCAT_CT_NEW "${PATCAT_CT}~"
/DERIVEDFIELD NORME_CF_NEW "${NORME_CF}~"
/DERIVEDFIELD PATTYP_CT1 "I"
/DERIVEDFIELD PATTYP_CT2  IF COND_ACCEPT THEN "A" ELSE "R" 
/DERIVEDFIELD PATTYP_CT345 "${TYPE_OUTPUT}~"
/DERIVEDFIELD STRVIDE "~"
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD ACMAMT_MC ACMAMT_M COMPRESS
/DERIVEDFIELD AM01_MC AM01_M COMPRESS
/DERIVEDFIELD AM02_MC AM02_M COMPRESS
/DERIVEDFIELD AM03_MC AM03_M COMPRESS
/DERIVEDFIELD AM04_MC AM04_M COMPRESS
/DERIVEDFIELD AM05_MC AM05_M COMPRESS
/DERIVEDFIELD AM06_MC AM06_M COMPRESS
/DERIVEDFIELD AM07_MC AM07_M COMPRESS
/DERIVEDFIELD AM08_MC AM08_M COMPRESS
/DERIVEDFIELD AM09_MC AM09_M COMPRESS
/DERIVEDFIELD AM10_MC AM10_M COMPRESS
/DERIVEDFIELD AM11_MC AM11_M COMPRESS
/DERIVEDFIELD AM12_MC AM12_M COMPRESS
/DERIVEDFIELD AM13_MC AM13_M COMPRESS
/DERIVEDFIELD AM14_MC AM14_M COMPRESS
/DERIVEDFIELD AM15_MC AM15_M COMPRESS
/DERIVEDFIELD AM16_MC AM16_M COMPRESS
/DERIVEDFIELD AM17_MC AM17_M COMPRESS
/DERIVEDFIELD AM18_MC AM18_M COMPRESS
/DERIVEDFIELD AM19_MC AM19_M COMPRESS
/DERIVEDFIELD AM20_MC AM20_M COMPRESS
/DERIVEDFIELD AM21_MC AM21_M COMPRESS
/DERIVEDFIELD AM22_MC AM22_M COMPRESS
/DERIVEDFIELD AM23_MC AM23_M COMPRESS
/DERIVEDFIELD AM24_MC AM24_M COMPRESS
/DERIVEDFIELD AM25_MC AM25_M COMPRESS
/DERIVEDFIELD AM26_MC AM26_M COMPRESS
/DERIVEDFIELD AM27_MC AM27_M COMPRESS
/DERIVEDFIELD AM28_MC AM28_M COMPRESS
/DERIVEDFIELD AM29_MC AM29_M COMPRESS
/DERIVEDFIELD AM30_MC AM30_M COMPRESS
/DERIVEDFIELD AM31_MC AM31_M COMPRESS
/DERIVEDFIELD AM32_MC AM32_M COMPRESS
/DERIVEDFIELD AM33_MC AM33_M COMPRESS
/DERIVEDFIELD AM34_MC AM34_M COMPRESS
/DERIVEDFIELD AM35_MC AM35_M COMPRESS
/DERIVEDFIELD AM36_MC AM36_M COMPRESS
/DERIVEDFIELD AM37_MC AM37_M COMPRESS
/DERIVEDFIELD AM38_MC AM38_M COMPRESS
/DERIVEDFIELD AM39_MC AM39_M COMPRESS
/DERIVEDFIELD AM40_MC AM40_M COMPRESS
/DERIVEDFIELD AM41_MC AM41_M COMPRESS
/DERIVEDFIELD AM42_MC AM42_M COMPRESS
/DERIVEDFIELD AM43_MC AM43_M COMPRESS
/DERIVEDFIELD AM44_MC AM44_M COMPRESS
/DERIVEDFIELD AM45_MC AM45_M COMPRESS
/DERIVEDFIELD AM46_MC AM46_M COMPRESS
/DERIVEDFIELD AM47_MC AM47_M COMPRESS
/DERIVEDFIELD AM48_MC AM48_M COMPRESS
/DERIVEDFIELD AM49_MC AM49_M COMPRESS
/DERIVEDFIELD AM50_MC AM50_M COMPRESS
/DERIVEDFIELD AM51_MC AM51_M COMPRESS
/DERIVEDFIELD AM52_MC AM52_M COMPRESS
/DERIVEDFIELD AM53_MC AM53_M COMPRESS
/DERIVEDFIELD AM54_MC AM54_M COMPRESS
/DERIVEDFIELD AM55_MC AM55_M COMPRESS
/DERIVEDFIELD AM56_MC AM56_M COMPRESS
/DERIVEDFIELD AM57_MC AM57_M COMPRESS
/DERIVEDFIELD AM58_MC AM58_M COMPRESS
/DERIVEDFIELD AM59_MC AM59_M COMPRESS
/DERIVEDFIELD AM60_MC AM60_M COMPRESS
/DERIVEDFIELD AM61_MC AM61_M COMPRESS
/DERIVEDFIELD AM62_MC AM62_M COMPRESS
/DERIVEDFIELD AM63_MC AM63_M COMPRESS
/DERIVEDFIELD AM64_MC AM64_M COMPRESS
/DERIVEDFIELD AM65_MC AM65_M COMPRESS
/DERIVEDFIELD TOTAUX_MC TOTAUX_M COMPRESS
/KEYS SSD_CF,
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
      PLC_NT,
      RTO_NF,
      CUR_CF,
      RETCUR_CF,
      ACMCUR_CF,
      ACMTRS_NT,
      TYP_CT,
      PATCAT_CT,
      PATTYP_CT,
      ACMTRS3_NT
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF
     ,ESB_CF
     ,BALSHEY_NF
     ,BALSHRMTH_NF
     ,BALSHRDAY_NF
     ,TRNCOD_CF
     ,DBLTRNCOD_CF
     ,CTR_NF
     ,END_NT
     ,SEC_NF
     ,UWY_NF
     ,UW_NT
     ,OCCYEA_NF
     ,ACY_NF
     ,SCOSTRMTH_NF
     ,SCOENDMTH_NF
     ,CLM_NF
     ,CUR_CF
     ,AMT_MC
     ,CED_NF
     ,BRK_NF
     ,PAY_NF
     ,KEY_NF
     ,RETCTR_NF
     ,RETEND_NT
     ,RETSEC_NF
     ,RTY_NF
     ,RETUW_NT
     ,RETOCCYEA_NF
     ,RETACY_NF
     ,RETSCOSTRMTH_NF
     ,RETSCOENDMTH_NF
     ,RCL_NF
     ,RETCUR_CF
     ,RETAMT_MC
     ,PLC_NT
     ,RTO_NF
     ,INT_NF
     ,RETPAY_NF
     ,RETKEY_CF
     ,RETINTAMT_MC
     ,ACMTRS_NT
     ,STRVIDE
     ,TOTAUX_MC
     ,ACMCUR_CF
     ,PRS_CF
     ,SEG_NF
     ,LOB_CF
     ,NAT_CF
     ,TYP_CT
     ,NORME_CF_NEW
     ,RATING_CF
     ,PATCAT_CT_NEW
     ,PATTYP_CT1
     ,PATTYP_CT2
     ,PATTYP_CT345
     ,PATTERN_ID
     ,AM01_MC
     ,AM02_MC
     ,AM03_MC
     ,AM04_MC
     ,AM05_MC
     ,AM06_MC
     ,AM07_MC
     ,AM08_MC
     ,AM09_MC
     ,AM10_MC
     ,AM11_MC
     ,AM12_MC
     ,AM13_MC
     ,AM14_MC
     ,AM15_MC
     ,AM16_MC
     ,AM17_MC
     ,AM18_MC
     ,AM19_MC
     ,AM20_MC
     ,AM21_MC
     ,AM22_MC
     ,AM23_MC
     ,AM24_MC
     ,AM25_MC
     ,AM26_MC
     ,AM27_MC
     ,AM28_MC
     ,AM29_MC
     ,AM30_MC
     ,AM31_MC
     ,AM32_MC
     ,AM33_MC
     ,AM34_MC
     ,AM35_MC
     ,AM36_MC
     ,AM37_MC
     ,AM38_MC
     ,AM39_MC
     ,AM40_MC
     ,AM41_MC
     ,AM42_MC
     ,AM43_MC
     ,AM44_MC
     ,AM45_MC
     ,AM46_MC
     ,AM47_MC
     ,AM48_MC
     ,AM49_MC
     ,AM50_MC
     ,AM51_MC
     ,AM52_MC
     ,AM53_MC
     ,AM54_MC
     ,AM55_MC
     ,AM56_MC
     ,AM57_MC
     ,AM58_MC
     ,AM59_MC
     ,AM60_MC
     ,AM61_MC
     ,AM62_MC
     ,AM63_MC
     ,AM64_MC
     ,AM65_MC
     ,COEF_LOB
     ,DSCCUR_CF
     ,COMMENT
     ,TOTAUX_MC
     ,ACMTRS3_NT
exit
EOF
SORT


#------START---[007]
NSTEP=${NJOB}_75
if [ -s ${EPO_FSEGPATTERN_ICR} ]
then
	PATTERN_CATEGORY="ICR  "
	#-----------------------------------------------------------------------------
	LIBEL="CSF CALCULATION - PRODUCE UNDISCOUNTED GTSII FOR TOTAL AMOUNT..."
	PRG=ESTC1056A
	FPRM=`CFTMP`
	INPUT_TEXT ${FPRM} << EOF
	TRIM_NF ${TRIM_NF}
	PATTERN_CATEGORY ${PATTERN_CATEGORY}
	CONTEXT_CT ${CONTEXT_CT}
	CLOSINGDATE ${PARM_ICLODAT_D}
	exit
EOF
	export ${PRG}_PRM=${FPRM}
	export ${PRG}_HOST_PRDSIT=${HOST_PRDSIT}
	export ${PRG}_I1=${DFILI}/${ENV_PREFIX}_ESFD3650_${IDF_CT}_TOTAL_CASHFLOW_WK.dat
	export ${PRG}_I2=${EPO_FSEGPATTERN_ICR}
	export ${PRG}_I3=${EPO_IADPERICASE}
    export ${PRG}_I4=${EST_IRDPERICASE}
	export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_ESTC1056A_CASHFLOW.dat
	export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FSEGPATTERN_NOTUSED.dat
	export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_ESTC1056A_REMAINTOPAY_ULAE.dat
	export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_REMAINTOPAY_FHNI.dat
	EXECPRG
else
	#------------------------------------------------------------------------------
	LIBEL="CSF CALCULATION touch temporary cashflow file, no pattern file"
	EXECKSH_MODE=P
	EXECKSH "touch ${DFILT}/${NJOB}_75_${IB}_ESTC1056A_CASHFLOW.dat "
fi

NSTEP=${NJOB}_80
#-----------------------------------------------------------------------------
LIBEL="Risk ADJ - SORT AND OVERWRITE THE CASHFLOW GTSII FOR TOTAL AMOUNT... "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75_${IB}_ESTC1056A_CASHFLOW.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IDF_CT}_GTSII_CASHFLOW_TOT_AMT.dat OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
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
        ACMTRS_NT        42:1 - 42:3,
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
        PATCAT1_CT       52:1 - 52:3,
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
/SUMMARIZE TOTAL AM01_M, TOTAL AM02_M, TOTAL AM03_M, TOTAL AM04_M, TOTAL AM05_M, TOTAL AM06_M, TOTAL AM07_M, TOTAL AM08_M, TOTAL AM09_M, TOTAL AM10_M,
           TOTAL AM11_M, TOTAL AM12_M, TOTAL AM13_M, TOTAL AM14_M, TOTAL AM15_M, TOTAL AM16_M, TOTAL AM17_M, TOTAL AM18_M, TOTAL AM19_M, TOTAL AM20_M,
           TOTAL AM21_M, TOTAL AM22_M, TOTAL AM23_M, TOTAL AM24_M, TOTAL AM25_M, TOTAL AM26_M, TOTAL AM27_M, TOTAL AM28_M, TOTAL AM29_M, TOTAL AM30_M,
           TOTAL AM31_M, TOTAL AM32_M, TOTAL AM33_M, TOTAL AM34_M, TOTAL AM35_M, TOTAL AM36_M, TOTAL AM37_M, TOTAL AM38_M, TOTAL AM39_M, TOTAL AM40_M,
           TOTAL AM41_M, TOTAL AM42_M, TOTAL AM43_M, TOTAL AM44_M, TOTAL AM45_M, TOTAL AM46_M, TOTAL AM47_M, TOTAL AM48_M, TOTAL AM49_M, TOTAL AM50_M,
           TOTAL AM51_M, TOTAL AM52_M, TOTAL AM53_M, TOTAL AM54_M, TOTAL AM55_M, TOTAL AM56_M, TOTAL AM57_M, TOTAL AM58_M, TOTAL AM59_M, TOTAL AM60_M,
           TOTAL AM61_M, TOTAL AM62_M, TOTAL AM63_M, TOTAL AM64_M, TOTAL AM65_M,
           TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M, TOTAL ACMAMT_M, TOTAL TOTAUX_M
/CONDITION COND_ACCEPT ( TYP_CT EQ "A" ) 
/DERIVEDFIELD PATCAT_CT_NEW "${PATCAT_CT}~"
/DERIVEDFIELD NORME_CF_NEW "${NORME_CF}~"
/DERIVEDFIELD PATTYP_CT1 "I"
/DERIVEDFIELD PATTYP_CT2  IF COND_ACCEPT THEN "A" ELSE "R" 
/DERIVEDFIELD PATTYP_CT345 "${TYPE_OUTPUT}~"
/DERIVEDFIELD STRVIDE "~"
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD ACMAMT_MC ACMAMT_M COMPRESS
/DERIVEDFIELD AM01_MC AM01_M COMPRESS
/DERIVEDFIELD AM02_MC AM02_M COMPRESS
/DERIVEDFIELD AM03_MC AM03_M COMPRESS
/DERIVEDFIELD AM04_MC AM04_M COMPRESS
/DERIVEDFIELD AM05_MC AM05_M COMPRESS
/DERIVEDFIELD AM06_MC AM06_M COMPRESS
/DERIVEDFIELD AM07_MC AM07_M COMPRESS
/DERIVEDFIELD AM08_MC AM08_M COMPRESS
/DERIVEDFIELD AM09_MC AM09_M COMPRESS
/DERIVEDFIELD AM10_MC AM10_M COMPRESS
/DERIVEDFIELD AM11_MC AM11_M COMPRESS
/DERIVEDFIELD AM12_MC AM12_M COMPRESS
/DERIVEDFIELD AM13_MC AM13_M COMPRESS
/DERIVEDFIELD AM14_MC AM14_M COMPRESS
/DERIVEDFIELD AM15_MC AM15_M COMPRESS
/DERIVEDFIELD AM16_MC AM16_M COMPRESS
/DERIVEDFIELD AM17_MC AM17_M COMPRESS
/DERIVEDFIELD AM18_MC AM18_M COMPRESS
/DERIVEDFIELD AM19_MC AM19_M COMPRESS
/DERIVEDFIELD AM20_MC AM20_M COMPRESS
/DERIVEDFIELD AM21_MC AM21_M COMPRESS
/DERIVEDFIELD AM22_MC AM22_M COMPRESS
/DERIVEDFIELD AM23_MC AM23_M COMPRESS
/DERIVEDFIELD AM24_MC AM24_M COMPRESS
/DERIVEDFIELD AM25_MC AM25_M COMPRESS
/DERIVEDFIELD AM26_MC AM26_M COMPRESS
/DERIVEDFIELD AM27_MC AM27_M COMPRESS
/DERIVEDFIELD AM28_MC AM28_M COMPRESS
/DERIVEDFIELD AM29_MC AM29_M COMPRESS
/DERIVEDFIELD AM30_MC AM30_M COMPRESS
/DERIVEDFIELD AM31_MC AM31_M COMPRESS
/DERIVEDFIELD AM32_MC AM32_M COMPRESS
/DERIVEDFIELD AM33_MC AM33_M COMPRESS
/DERIVEDFIELD AM34_MC AM34_M COMPRESS
/DERIVEDFIELD AM35_MC AM35_M COMPRESS
/DERIVEDFIELD AM36_MC AM36_M COMPRESS
/DERIVEDFIELD AM37_MC AM37_M COMPRESS
/DERIVEDFIELD AM38_MC AM38_M COMPRESS
/DERIVEDFIELD AM39_MC AM39_M COMPRESS
/DERIVEDFIELD AM40_MC AM40_M COMPRESS
/DERIVEDFIELD AM41_MC AM41_M COMPRESS
/DERIVEDFIELD AM42_MC AM42_M COMPRESS
/DERIVEDFIELD AM43_MC AM43_M COMPRESS
/DERIVEDFIELD AM44_MC AM44_M COMPRESS
/DERIVEDFIELD AM45_MC AM45_M COMPRESS
/DERIVEDFIELD AM46_MC AM46_M COMPRESS
/DERIVEDFIELD AM47_MC AM47_M COMPRESS
/DERIVEDFIELD AM48_MC AM48_M COMPRESS
/DERIVEDFIELD AM49_MC AM49_M COMPRESS
/DERIVEDFIELD AM50_MC AM50_M COMPRESS
/DERIVEDFIELD AM51_MC AM51_M COMPRESS
/DERIVEDFIELD AM52_MC AM52_M COMPRESS
/DERIVEDFIELD AM53_MC AM53_M COMPRESS
/DERIVEDFIELD AM54_MC AM54_M COMPRESS
/DERIVEDFIELD AM55_MC AM55_M COMPRESS
/DERIVEDFIELD AM56_MC AM56_M COMPRESS
/DERIVEDFIELD AM57_MC AM57_M COMPRESS
/DERIVEDFIELD AM58_MC AM58_M COMPRESS
/DERIVEDFIELD AM59_MC AM59_M COMPRESS
/DERIVEDFIELD AM60_MC AM60_M COMPRESS
/DERIVEDFIELD AM61_MC AM61_M COMPRESS
/DERIVEDFIELD AM62_MC AM62_M COMPRESS
/DERIVEDFIELD AM63_MC AM63_M COMPRESS
/DERIVEDFIELD AM64_MC AM64_M COMPRESS
/DERIVEDFIELD AM65_MC AM65_M COMPRESS
/DERIVEDFIELD TOTAUX_MC TOTAUX_M COMPRESS
/KEYS SSD_CF,
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
      PLC_NT,
      RTO_NF,
      CUR_CF,
      RETCUR_CF,
      ACMCUR_CF,
      ACMTRS_NT,
      TYP_CT,
      PATCAT_CT,
      PATTYP_CT,
      ACMTRS3_NT
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF
     ,ESB_CF
     ,BALSHEY_NF
     ,BALSHRMTH_NF
     ,BALSHRDAY_NF
     ,TRNCOD_CF
     ,DBLTRNCOD_CF
     ,CTR_NF
     ,END_NT
     ,SEC_NF
     ,UWY_NF
     ,UW_NT
     ,OCCYEA_NF
     ,ACY_NF
     ,SCOSTRMTH_NF
     ,SCOENDMTH_NF
     ,CLM_NF
     ,CUR_CF
     ,AMT_MC
     ,CED_NF
     ,BRK_NF
     ,PAY_NF
     ,KEY_NF
     ,RETCTR_NF
     ,RETEND_NT
     ,RETSEC_NF
     ,RTY_NF
     ,RETUW_NT
     ,RETOCCYEA_NF
     ,RETACY_NF
     ,RETSCOSTRMTH_NF
     ,RETSCOENDMTH_NF
     ,RCL_NF
     ,RETCUR_CF
     ,RETAMT_MC
     ,PLC_NT
     ,RTO_NF
     ,INT_NF
     ,RETPAY_NF
     ,RETKEY_CF
     ,RETINTAMT_MC
     ,ACMTRS_NT
     ,STRVIDE
     ,TOTAUX_MC
     ,ACMCUR_CF
     ,PRS_CF
     ,SEG_NF
     ,LOB_CF
     ,NAT_CF
     ,TYP_CT
     ,NORME_CF_NEW
     ,RATING_CF
     ,PATCAT_CT_NEW
     ,PATTYP_CT1
     ,PATTYP_CT2
     ,PATTYP_CT345
     ,PATTERN_ID
     ,AM01_MC
     ,AM02_MC
     ,AM03_MC
     ,AM04_MC
     ,AM05_MC
     ,AM06_MC
     ,AM07_MC
     ,AM08_MC
     ,AM09_MC
     ,AM10_MC
     ,AM11_MC
     ,AM12_MC
     ,AM13_MC
     ,AM14_MC
     ,AM15_MC
     ,AM16_MC
     ,AM17_MC
     ,AM18_MC
     ,AM19_MC
     ,AM20_MC
     ,AM21_MC
     ,AM22_MC
     ,AM23_MC
     ,AM24_MC
     ,AM25_MC
     ,AM26_MC
     ,AM27_MC
     ,AM28_MC
     ,AM29_MC
     ,AM30_MC
     ,AM31_MC
     ,AM32_MC
     ,AM33_MC
     ,AM34_MC
     ,AM35_MC
     ,AM36_MC
     ,AM37_MC
     ,AM38_MC
     ,AM39_MC
     ,AM40_MC
     ,AM41_MC
     ,AM42_MC
     ,AM43_MC
     ,AM44_MC
     ,AM45_MC
     ,AM46_MC
     ,AM47_MC
     ,AM48_MC
     ,AM49_MC
     ,AM50_MC
     ,AM51_MC
     ,AM52_MC
     ,AM53_MC
     ,AM54_MC
     ,AM55_MC
     ,AM56_MC
     ,AM57_MC
     ,AM58_MC
     ,AM59_MC
     ,AM60_MC
     ,AM61_MC
     ,AM62_MC
     ,AM63_MC
     ,AM64_MC
     ,AM65_MC
     ,COEF_LOB
     ,DSCCUR_CF
     ,COMMENT
     ,TOTAUX_MC
     ,ACMTRS3_NT
exit
EOF
SORT


ECHO_LOG "lines before joining INITIAL file + TOTAL file  "
wc -l "${DFILT}/${NJOB}_70_${IDF_CT}_GTSII_CASHFLOW_INI_AMT.dat"  
wc -l "${DFILT}/${NJOB}_80_${IDF_CT}_GTSII_CASHFLOW_TOT_AMT.dat"


NSTEP=${NJOB}_90
LIBEL="RETRIEVE INITIAL AMOUNT COLUMN FROM THE FIRST FILE and ADD IT TO SECOND FILE..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IDF_CT}_GTSII_CASHFLOW_TOT_AMT.dat 1000 1"
SORT_O=${ESF_GTSII_CASHFLOW}  
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CML_SSD_CF		1:1 	- 1:,
	CML_ESB_CF			2:1 	- 2:,
	CML_CTR_NF			8:1 	- 8:,
	CML_END_NT			9:1 	- 9:,
	CML_SEC_NF			10:1 	- 10:,
	CML_UWY_NF			11:1 	- 11:,
	CML_UW_NT			12:1 	- 12:,
	CML_SCOSTRMTH_NF	15:1 	- 15:,
	CML_SCOENDMTH_NF	16:1 	- 16:,
	CML_CUR_CF			18:1 	- 18:,
	CML_RETCTR_NF 		24:1 	- 24:,
	CML_RETEND_NT 		25:1 	- 25:,
	CML_RETSEC_NF 		26:1 	- 26:,
	CML_RTY_NF 			27:1 	- 27:,
	CML_RETUW_NT 		28:1 	- 28:,
	CML_RETSCOSTRMTH_NF	31:1 	- 31:,
	CML_RETSCOENDMTH_NF	32:1 	- 32:,
	CML_RETCUR_CF		34:1    - 34:,
	CML_PLC_NT			36:1 	- 36:,
	CML_RTO_NF			37:1 	- 37:,
	CML_ACMTRS_NT		42:1	- 42:,
	CML_ACMCUR_CF		44:1    - 44:,
	CML_PRS_CF			45:1	- 45:,
	CML_NAT_CF			48:1 	- 48:,
	CML_TYP_CT			49:1 	- 49:,
	CML_NORM_CF    		50:1 	- 50:,
	CML_PATCAT_CT		52:1 	- 52:,
	CML_PATTYP_CT		53:1 	- 53:,
	CML_PATTERN_ID		54:1 	- 54:,
	CML_PART_1    		1:1 	- 18:,
	CML_PART_2    		20:1 	- 34:,
	CML_PART_22			36:1    - 42:,
	CML_ACMTRS3_NT		124:1 	- 124:,
	CML_PART_3    		44:1 	- 124:,
	SSD_CF				1:1 	- 1:,
	ESB_CF				2:1 	- 2:,
	BALSHEY_NF			3:1 	- 3:,
	BALSHRMTH_NF		4:1 	- 4:,
	BALSHRDAY_NF		5:1 	- 5:,
	CTR_NF				8:1 	- 8:,
	END_NT				9:1 	- 9:,
	SEC_NF				10:1 	- 10:,
	UWY_NF				11:1 	- 11:,
	UW_NT				12:1 	- 12:,
	SCOSTRMTH_NF		15:1 	- 15:,
	SCOENDMTH_NF		16:1 	- 16:,
	CUR_CF				18:1 	- 18:,
	RETCTR_NF 			24:1 	- 24:,
	RETEND_NT 			25:1 	- 25:,
	RETSEC_NF 			26:1 	- 26:,
	RTY_NF 				27:1 	- 27:,
	RETUW_NT 			28:1 	- 28:,
	RETSCOSTRMTH_NF		31:1 	- 31:,
	RETSCOENDMTH_NF		32:1 	- 32:,
	RETCUR_CF        	34:1 	- 34:,
    RETAMT_M         	35:1 	- 35:EN 15/3,	
	PLC_NT				36:1 	- 36:,
	RTO_NF				37:1 	- 37:,
	ACMTRS_NT			42:1	- 42:,
	ACMCUR_CF        	44:1 	- 44:,
	PRS_CF				45:1	- 45:,
	AMT_MC				19:1 	- 19:,
	ACMAMT_MC			43:1	- 43:,
	NAT_CF				48:1 	- 48:,
	TYP_CT				49:1 	- 49:,
	NORM_CF    			50:1 	- 50:,
	PATCAT_CT			52:1 	- 52:,
	PATTYP_CT			53:1 	- 53:,
	ACMTRS3_NT			124:1 	- 124:
/joinkeys 
	CML_SSD_CF,	
	CML_CTR_NF,		
	CML_END_NT,		
	CML_SEC_NF,		
	CML_UWY_NF,		
	CML_UW_NT,
	CML_RETCTR_NF,
	CML_RETEND_NT,
	CML_RETSEC_NF,
	CML_RTY_NF, 
	CML_RETUW_NT,
	CML_PLC_NT,
	CML_RTO_NF,
	CML_CUR_CF,   
	CML_RETCUR_CF,
	CML_ACMCUR_CF,
	CML_ACMTRS_NT,
	CML_TYP_CT,		
	CML_PATCAT_CT,
	CML_PATTYP_CT,
	CML_ACMTRS3_NT	
/INFILE ${DFILT}/${NJOB}_70_${IDF_CT}_GTSII_CASHFLOW_INI_AMT.dat 1000 1 "~"  
/joinkeys
	SSD_CF,	
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
	PLC_NT,
	RTO_NF,
	CUR_CF ,   
	RETCUR_CF ,
	ACMCUR_CF ,
	ACMTRS_NT,
	TYP_CT,		
	PATCAT_CT,
	PATTYP_CT,
	ACMTRS3_NT	
/OUTFILE ${SORT_O} overwrite
/REFORMAT
		leftside:CML_PART_1,
		rightside:AMT_MC,
		leftside:CML_PART_2,
		rightside:RETAMT_M,
		leftside:CML_PART_22,
		rightside:ACMAMT_MC,
		leftside:CML_PART_3
exit
EOF
SORT
#------END---[007]


#[019]
if [ "${PARM_IS_TRN}" = "YES" ] 
then
NSTEP=${NJOB}_100
#-----------------------------------------------------------------------------
LIBEL="TRANSITION INI : retroP : final SEG_NF should have lenght 10 without ref_quarter  "
AWK_I=${ESF_GTSII_CASHFLOW}
AWK_O=$DFILT/${NJOB}_100_${IB}_GTSII_CASHFLOW_${IDF_CT}.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~";
       OFS="\~";
     }
 {
  if ( (\$49 == "R" || \$49 == "RI") && \$48 != "N" )
  {
  \$46=substr(\$46 , 1 , 10 );
  }
  print \$0;
 }
exit
EOF
AWK

EXECKSH_MODE=P
EXECKSH "cp $DFILT/${NJOB}_100_${IB}_GTSII_CASHFLOW_${IDF_CT}.dat ${ESF_GTSII_CASHFLOW}  " 

fi



JOBEND
