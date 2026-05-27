#!/bin/ksh
#=============================================================================
# nom de l'application          : Management in cashflow and discount calculation  
# nom du script SHELL           : ESFD3821.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 05\03\2020
# auteur                        : Charles SOCIE
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  IFRS17 SPIRA 82584- IO management in cashflow and discount calculation
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[001] 04/08/2020 R. Cassis :spira: 79427  Remplacement du ESTC1081 par des tris et utilisation du fichier FPLATXCUM a la place du fichier FCLIENT pour l'info RI.
#[002] 20/01/2021 M.NAJI : spira 91531 rempacment de CRE_D par PARM_CRE_D
#[003] 22/03/2021 NBD : spira 93494 add new inputs of cashflows
#[004] 26/10/2021 JYP : spira 98274 add ICR file from cashflows
#[005] 0709/2022 DAD : spira 101279 add SEG_NF in KEYS of SORT step 40
#[006] 23/03/2023 Bhimasen : spira 107070 add new input file for merge pericase 
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Get input parameters
ICLODAT_D=$1

TYPETRT_CT="GT_SII"

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> NORME......................: ${NORME_CF}"
ECHO_LOG "#===> param_Request_id...........: ${param_Request_id}  "
ECHO_LOG "#===> param_Context_id...........: ${param_Context_id}  "
ECHO_LOG "#===> CONTEXT_CT.................: ${CONTEXT_CT}  "

ECHO_LOG "#===> ICLODAT_D......................: ${ICLODAT_D}"
ECHO_LOG "#===> PARM_CRE_D..........................: ${PARM_CRE_D}"
ECHO_LOG "#===> CLOPRD.........................: ${CLOPRD}"
ECHO_LOG "#===> TYPETRT_CT.....................: ${TYPETRT_CT}"


ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> ESF_FTECLEDSII.........................: ${ESF_FTECLEDSII}"
ECHO_LOG "#===> ESF_GTSII_GLOBAL_CASHFLOW..............: ${ESF_GTSII_GLOBAL_CASHFLOW}"
ECHO_LOG "#===> NDIC_CASHFLOW..........................: ${NDIC_CASHFLOW}"
ECHO_LOG "#===> ESF_GTSII_DUMMY_STD....................: ${ESF_GTSII_DUMMY_STD}"
ECHO_LOG "#===> ESF_GTSII_ONE_STD......................: ${ESF_GTSII_ONE_STD}"
ECHO_LOG "#===> EST_FPLC...............................: ${EST_FPLC}"
ECHO_LOG "#===> EST_FSSDACTR...........................: ${EST_FSSDACTR}"
ECHO_LOG "#===> EST_FDETTRS............................: ${EST_FDETTRS}"
ECHO_LOG "#===> ESF_IADPERICASE_I17_MERGE..............: ${ESF_IADPERICASE_I17_MERGE}"
ECHO_LOG "#===> EST_FCLIENT............................: ${EST_FCLIENT}"
ECHO_LOG "#===> ESF_GTSII_ICR .........................: ${ESF_GTSII_ICR}"

ECHO_LOG "#===> ............ OUTPUT FROM A REGION & INPUT TO ANOTHER REGION ................................................."
ECHO_LOG "#===> ESF_DLEIFTECLEDSIIEP...................: ${ESF_DLEIFTECLEDSIIEP}"

ECHO_LOG "#===> ............ OUTPUT ................................................."
ECHO_LOG "#===> ESF_DLEIFTECLEDSIIEI...................: ${ESF_DLEIFTECLEDSIIEI}"
ECHO_LOG "#===> ESF_FTECLEDSII_IFRS17..................: ${ESF_FTECLEDSII_IFRS17}"
ECHO_LOG "#========================================================================="



NSTEP=${NJOB}_05
#-----------------------------------------------------------------------------
LIBEL="Fusion des fichiers GTSII et eclatement en retro et accept"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDSII} 4000 1"
SORT_I2="${ESF_GTSII_GLOBAL_CASHFLOW} 4000 1"
SORT_I3="${NDIC_CASHFLOW} 4000 1"
SORT_I4="${ESF_GTSII_DUMMY_STD} 4000 1"
SORT_I5="${ESF_GTSII_ONE_STD} 4000 1"
SORT_I6="${ESF_GTSII_ICR} 4000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDSIICSFAA.dat "
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_DLDSIICSFAR.dat "
INPUT_TEXT ${SORT_CMD} <<EOF
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
        PATCAT1_CT       52:1 - 52:3,
        PATTYP_CT        53:1 - 53:,
        PATTYP1_CT       53:1 - 53:3,
        PATTERN_ID       54:1 - 54:,
        FIN              55:1 - 119:,
        COEF_LOB        120:1 - 120:,
        DSCCUR_CF       121:1 - 121:,
        COMMENT         122:1 - 122:,
        TOTAUX_M        123:1 - 123:EN 15/3,
        TIFI_M          124:1 - 124:EN 15/3,
	ACMTRS3_NT       125:1 - 125:
/CONDITION ACCEP_RNP_GT  TYP_CT  != "R" 
/CONDITION RETROP_GT  TYP_CT = "R"
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CUR_CF,	
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      ACMTRS_NT,
      PATCAT_CT,
      PATTYP_CT,
      NORME_CF,
      RATING_CF,
      ACMTRS3_NT
/OUTFILE ${SORT_O}
/INCLUDE ACCEP_RNP_GT
/OUTFILE ${SORT_O2}
/INCLUDE RETROP_GT
exit
EOF
SORT


NSTEP=${NJOB}_10
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sorting RR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_DLDSIICSFAR.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDSIIGTAR.dat "
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        FILLER1           1:1 - 18:,
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
        FILLER2          20:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        FILLER3          36:1 - 40:,
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
/SUMMARIZE TOTAL AM01_M, TOTAL AM02_M, TOTAL AM03_M, TOTAL AM04_M, TOTAL AM05_M, TOTAL AM06_M, TOTAL AM07_M, TOTAL AM08_M, TOTAL AM09_M, TOTAL AM10_M,
           TOTAL AM11_M, TOTAL AM12_M, TOTAL AM13_M, TOTAL AM14_M, TOTAL AM15_M, TOTAL AM16_M, TOTAL AM17_M, TOTAL AM18_M, TOTAL AM19_M, TOTAL AM20_M,
           TOTAL AM21_M, TOTAL AM22_M, TOTAL AM23_M, TOTAL AM24_M, TOTAL AM25_M, TOTAL AM26_M, TOTAL AM27_M, TOTAL AM28_M, TOTAL AM29_M, TOTAL AM30_M,
           TOTAL AM31_M, TOTAL AM32_M, TOTAL AM33_M, TOTAL AM34_M, TOTAL AM35_M, TOTAL AM36_M, TOTAL AM37_M, TOTAL AM38_M, TOTAL AM39_M, TOTAL AM40_M,
           TOTAL AM41_M, TOTAL AM42_M, TOTAL AM43_M, TOTAL AM44_M, TOTAL AM45_M, TOTAL AM46_M, TOTAL AM47_M, TOTAL AM48_M, TOTAL AM49_M, TOTAL AM50_M,
           TOTAL AM51_M, TOTAL AM52_M, TOTAL AM53_M, TOTAL AM54_M, TOTAL AM55_M, TOTAL AM56_M, TOTAL AM57_M, TOTAL AM58_M, TOTAL AM59_M, TOTAL AM60_M,
           TOTAL AM61_M, TOTAL AM62_M, TOTAL AM63_M, TOTAL AM64_M, TOTAL AM65_M,
           TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M, TOTAL ACMAMT_M, TOTAL TOTAUX_M
/KEYS   RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        PLC_NT,
        RETCUR_CF,
        ACMTRS_NT,
        ACMCUR_CF,
        PRS_CF,
        TYP_CT,
        NORME_CF,
        RATING_CF,
        PATCAT_CT,
        PATTYP_CT,
        PATTERN_ID,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        SSD_CF,
        ESB_CF,
	ACMTRS3_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_15
#------------------------------------------------------------------------------
LIBEL="Computing acceptance TL for retrocessionaire subsidiaries..."
PRG=ESTC2315A
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLOPRD_D ${CLOPRD}
DBCLO_D ${ICLODAT_D}
PARM_CRE_D ${PARM_CRE_D}
TYPETRT_CT ${TYPETRT_CT}
NORME_CF ${NORME_CF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_DLDSIIGTAR.dat
export ${PRG}_I2=${EST_FPLC}
export ${PRG}_I3=${EST_FSSDACTR}
export ${PRG}_I4=${EST_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLEIFTECLEDSII.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_DLDSIIGTAR.dat
EXECPRG


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ESTC2315A "
ECHO_LOG "#===> Nombre de lignes AI generees "
wc -l ${DFILT}/${NJOB}_15_${IB}_ESTC2315A_DLEIFTECLEDSII.dat
ECHO_LOG "#===> Nombre de lignes RI+R origine "
wc -l ${DFILT}/${NJOB}_15_${IB}_ESTC2315A_DLDSIIGTAR.dat
ECHO_LOG "#===> Nombre de lignes RI origine "
grep ~RI ${DFILT}/${NJOB}_15_${IB}_ESTC2315A_DLDSIIGTAR.dat > ${DFILT}/${NJOB}_15_${IB}_ESTC2315A_DLDSIIGTAR_RI.dat
wc -l ${DFILT}/${NJOB}_15_${IB}_ESTC2315A_DLDSIIGTAR_RI.dat
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_20
#[018] correction sur le code �tablissement
#-----------------------------------------------------------------------------
LIBEL="SORT OF ESTC2315A_DLEIFTECLEDSII.dat echanges internes generes 'AI' "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_ESTC2315A_DLEIFTECLEDSII.dat 2000 1"
SORT_I2="${ESF_DLEIFTECLEDSIIEP} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLEIFTECLEDSII.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        FILLER1           1:1 - 18:,
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
        FILLER2          20:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:EN,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        FILLER3          36:1 - 40:,
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
        PATCAT1_CT       52:1 - 52:3,
        PATTYP_CT        53:1 - 53:,
        PATTERN_ID       54:1 - 54:,
        FILLER4          44:1 - 51:,
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
        CLISSD_NF       124:1 - 124:,
        CLOPRD          125:1 - 125:,
        DBCLO_D         126:1 - 126:,
        CRE2_D          127:1 - 127:,
        ORGSSD_CF       128:1 - 128:,
        FILLER5         124:1 - 128:,
	ACMTRS3_NT       133:1 - 133:
/SUMMARIZE TOTAL AM01_M, TOTAL AM02_M, TOTAL AM03_M, TOTAL AM04_M, TOTAL AM05_M, TOTAL AM06_M, TOTAL AM07_M, TOTAL AM08_M, TOTAL AM09_M, TOTAL AM10_M,
           TOTAL AM11_M, TOTAL AM12_M, TOTAL AM13_M, TOTAL AM14_M, TOTAL AM15_M, TOTAL AM16_M, TOTAL AM17_M, TOTAL AM18_M, TOTAL AM19_M, TOTAL AM20_M,
           TOTAL AM21_M, TOTAL AM22_M, TOTAL AM23_M, TOTAL AM24_M, TOTAL AM25_M, TOTAL AM26_M, TOTAL AM27_M, TOTAL AM28_M, TOTAL AM29_M, TOTAL AM30_M,
           TOTAL AM31_M, TOTAL AM32_M, TOTAL AM33_M, TOTAL AM34_M, TOTAL AM35_M, TOTAL AM36_M, TOTAL AM37_M, TOTAL AM38_M, TOTAL AM39_M, TOTAL AM40_M,
           TOTAL AM41_M, TOTAL AM42_M, TOTAL AM43_M, TOTAL AM44_M, TOTAL AM45_M, TOTAL AM46_M, TOTAL AM47_M, TOTAL AM48_M, TOTAL AM49_M, TOTAL AM50_M,
           TOTAL AM51_M, TOTAL AM52_M, TOTAL AM53_M, TOTAL AM54_M, TOTAL AM55_M, TOTAL AM56_M, TOTAL AM57_M, TOTAL AM58_M, TOTAL AM59_M, TOTAL AM60_M,
           TOTAL AM61_M, TOTAL AM62_M, TOTAL AM63_M, TOTAL AM64_M, TOTAL AM65_M,
           TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M, TOTAL ACMAMT_M, TOTAL TOTAUX_M
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
/DERIVEDFIELD CHAIN1_VIDE 1"~"
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        CUR_CF,
        RETCUR_CF,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        SSD_CF,
        ESB_CF,
        PLC_NT,
        ACMTRS_NT,
        ACMCUR_CF,
        PRS_CF,
        TYP_CT,
        NORME_CF,
        RATING_CF,
        PATCAT_CT,
        PATTYP_CT,
        PATTERN_ID,
        SEG_NF,
	ACMTRS3_NT
/OUTFILE ${SORT_O}
/REFORMAT FILLER1
         ,AMT_MC
         ,FILLER2
         ,RETAMT_MC
         ,FILLER3
         ,RETINTAMT_MC
         ,ACMTRS_NT
         ,ACMAMT_MC
         ,FILLER4
         ,PATCAT1_CT
         ,CHAIN1_VIDE
         ,PATTYP_CT
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
         ,FILLER5
	 ,ACMTRS3_NT
exit
EOF
SORT



NSTEP=${NJOB}_24
#------------------------------------------------------------------------------
LIBEL="Generate merge Pericase with IFRS Structure"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IADPERICASE_I17_MERGE} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FORMATTED_IADPERICASE_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	PERICASE			1:1 	- 206:
/DERIVEDFIELD EMPTY_IFRS_FIELDS "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT 
	PERICASE,
	EMPTY_IFRS_FIELDS
exit
EOF
SORT

NSTEP=${NJOB}_25
#------------------------------------------------------------------------------
LIBEL="Sort of Pericase file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_24_${IB}_FORMATTED_IADPERICASE_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT  7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="Current adding establishment code in TL ..."
PRG=ESTM7604A
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
PARM_CRE_D ${PARM_CRE_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_DLEIFTECLEDSII.dat
export ${PRG}_I2=${DFILT}/${NJOB}_25_${IB}_SORT_IADPERICASE_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLEIFTECLEDSII_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_ANOS_O.log
export ${PRG}_O3=${ESF_DLEIFTECLEDSIIEI}
EXECPRG

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ESTM7604 "
ECHO_LOG "#===> Nombre de lignes AI lues "
wc -l ${DFILT}/${NJOB}_20_${IB}_SORT_DLEIFTECLEDSII.dat
ECHO_LOG "#===> Nombre de lignes AI sans Etablissements interserveurs"
wc -l ${ESF_DLEIFTECLEDSIIEI}
ECHO_LOG "#===> Nombre de lignes AI avec Etablissements intraserveurs"
wc -l ${DFILT}/${NJOB}_30_${IB}_ESTM7604A_DLEIFTECLEDSII_O1.dat

NSTEP=${NJOB}_35
#------------------------------------------------------------------------------
LIBEL="Reformat for ACMTRSL3"
EXECKSH_MODE="W"
EXECKSH_I=${DFILT}/${NJOB}_30_${IB}_ESTM7604A_DLEIFTECLEDSII_O1.dat
EXECKSH_O=${DFILT}/${NSTEP}_${IB}_ESTM7604A_DLEIFTECLEDSII_O1_MOD.dat
EXECKSH "cut  -f1-123,129 -d~"


#[005] Add SEG_NF on KEYS
NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ${DFILT}/${NJOB}_05_${IB}_SORT_DLDSIICSFAA.dat                 : les lignes Accept
# ${DFILT}/${NJOB}_15_${IB}_ESTC2315A_DLDSIIGTAR.dat        : les lignes retro hors CSF et hors RMNTP, top�es R ou RI pour celles ayant particip� aux echanges internes
# ${DFILT}/${NJOB}_35_${IB}_ESTM7604_DLEIFTECLEDSII_O1.dat : les lignes accept issues de la retro interne
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
LIBEL="Fusion des fichiers GTSII et eclatement en retro et accept"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_DLDSIICSFAA.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_15_${IB}_ESTC2315A_DLDSIIGTAR.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_35_${IB}_ESTM7604A_DLEIFTECLEDSII_O1_MOD.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDSII.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        CTR1_NF           8:1 -  8:1,
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
        TYP1_CT          49:1 - 49:1,
        NORME_CF         50:1 - 50:,
        RATING_CF        51:1 - 51:,
        PATCAT_CT        52:1 - 52:,
        PATCAT1_CT       52:1 - 52:3,
        PATTYP_CT        53:1 - 53:,
        PATTYP1_CT       53:1 - 53:3,
        PATTERN_ID       54:1 - 54:,
        AM1_40           55:1 - 94:,
        AM41_65          95:1 - 119:,
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
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      CUR_CF,
      ACMCUR_CF,
      RETCUR_CF,	  
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      ACMTRS_NT,
      PRS_CF,
      PATCAT_CT,
      PATTYP_CT,
      TYP_CT,
      NORME_CF,
      RATING_CF,
      PATTERN_ID,
      SSD_CF,
      ESB_CF,
      SEG_NF,
      ACMTRS3_NT
/CONDITION pattyp  PATTYP_CT = ""
/CONDITION patcat  PATCAT_CT = ""
/CONDITION lobNONVIE  (LOB_CF != "" AND LOB_CF != "30" AND LOB_CF != "31")
/CONDITION lobacc  TYP1_CT = "A"
/DERIVEDFIELD PATTYP2 if  pattyp then "ER" else PATTYP_CT
/DERIVEDFIELD PATCAT2 if  patcat then "ER" else PATCAT_CT
/DERIVEDFIELD CUR_CF_NEW if lobacc then CUR_CF else RETCUR_CF
/DERIVEDFIELD CUR_CF_NEW2 if lobacc then CUR_CF else RETCUR_CF
/DERIVEDFIELD CLODAT_D "${ICLODAT_D}~"
/DERIVEDFIELD CLOTYP_CT "${TYPEINV}~"
/DERIVEDFIELD CLODAT_A "${ICLODAT_A}~"
/DERIVEDFIELD CLODAT_M "${ICLODAT_M}~"
/DERIVEDFIELD CLODAT_J "${ICLODAT_J}~"
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
/DERIVEDFIELD CHAIN1_VIDE 1"~"
/OUTFILE ${SORT_O}
/INCLUDE lobNONVIE
/REFORMAT
  SSD_CF
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
  ,CUR_CF_NEW
  ,AMT_M
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
  ,RETAMT_M
  ,PLC_NT
  ,RTO_NF
  ,INT_NF
  ,RETPAY_NF
  ,RETKEY_CF
  ,RETINTAMT_M
  ,ACMTRS_NT
  ,ACMAMT_M
  ,ACMCUR_CF
  ,PRS_CF
  ,SEG_NF
  ,LOB_CF
  ,NAT_CF
  ,TYP_CT
  ,NORME_CF
  ,RATING_CF
  ,PATCAT2
  ,PATTYP2
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
  ,CHAIN1_VIDE
exit
EOF
SORT

NSTEP=${NJOB}_45
#-----------------------------------------------------------------------------
LIBEL="Generation des lignes GT supplementaires pour Accept"
PRG=ESTC1075
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ICLODAT_D ${ICLODAT_D}
INPUTFILE 126
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_40_${IB}_SORT_FTECLEDSII.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDSII.dat  
EXECPRG

#####################################
#[001] debut

#NSTEP=${NJOB}_50
##-----------------------------------------------------------------------------
#LIBEL="Omit records with PATCAT_CT BDT and internal retrocessionaire"
#PRG=ESTC1081
#FPRM=`CFTMP`
#INPUT_TEXT ${FPRM} << EOF
#NORME_CF I17G
#exit
#EOF
#export ${PRG}_PRM=${FPRM}
#export ${PRG}_I1=${DFILT}/${NJOB}_45_${IB}_ESTC1075_FTECLEDSII.dat
#export ${PRG}_I2=${EST_FCLIENT}
#export ${PRG}_O1=${ESF_FTECLEDSII_IFRS17}
#EXECPRG

NSTEP=${NJOB}_50
# Filter T.code on ACMTRSL3_NT values
#---------------------------------------------------------------------------
LIBEL="Filter T.code on ACMTRSL3_NT values"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EPO_FPLATXCUM}
SORT_O=${DFILT}/${NSTEP}_${IB}_FPLATXCUM.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 1:1 - 1:
       ,RETSEC_NF 2:1 - 2:EN
       ,RETRTY_NF 3:1 - 3:
       ,RTO_NF    8:1 - 8:
/CONDITION rto RTO_NF != ""        
/KEYS RETCTR_NF, RETSEC_NF, RETRTY_NF, RTO_NF
/SUM
/INCLUDE rto
/REFORMAT RETCTR_NF, RETSEC_NF, RETRTY_NF, RTO_NF
exit
EOF
SORT

NSTEP=${NJOB}_55
# Get internal Retro info by Join with FPLATXCUM
#------------------------------------------------------------------------------
LIBEL="Get internal Retro info by Join with FPLATXCUM"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_45_${IB}_ESTC1075_FTECLEDSII.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDSII_IFRS17_O.dat OVERWRITE 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS RETCTR_NF    24:1 -  24:,
        RETSEC_NF    26:1 -  26:,
        RTY_NF       27:1 -  27:,
        RTO_NF       37:1 -  37:,
        COLS1         1:1 - 126:,
        F_RETCTR_NF   1:1 -   1:,
        F_RETSEC_NF   2:1 -   2:,
        F_RTY_NF      3:1 -   3:,
        F_RTO_NF      4:1 -   4:
/joinkeys
         RETCTR_NF   
        ,RETSEC_NF   
        ,RTY_NF   
        ,RTO_NF    
/INFILE ${DFILT}/${NJOB}_50_${IB}_FPLATXCUM.dat 100 1 "~"
/joinkeys
         F_RETCTR_NF   
        ,F_RETSEC_NF   
        ,F_RTY_NF   
        ,F_RTO_NF    
/JOIN UNPAIRED leftside
/OUTFILE ${SORT_O}
/REFORMAT
        leftside:COLS1
       ,rightside:F_RTO_NF
exit
EOF
SORT

NSTEP=${NJOB}_60
# Reformat FTECLEDSII to standard nb cols and Omit records with internal retro and PATCAT_CT = BDT
#---------------------------------------------------------------------------
LIBEL="Reformat FTECLEDSII to standard nb cols and Omit records with internal retro and PATCAT_CT = BDT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_55_${IB}_SORT_FTECLEDSII_IFRS17_O.dat 2000 1"
SORT_O=${ESF_FTECLEDSII_IFRS17}
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS NORME_CF    50:1 -  50:
       ,PATCAT_CT   52:1 -  52:
       ,RTO_NF     127:1 - 127:
       ,COLS1        1:1 - 126:
/COPY
/REFORMAT COLS1
exit
EOF
SORT

#/CONDITION toKeep RTO_NF = "" OR PATCAT_CT != "BDT" OR NORME_CF != "I17G"
#/INCLUDE toKeep

NSTEP=${NJOB}_70
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*${IB}*.dat"

#[001] fin
#####################################

JOBEND
