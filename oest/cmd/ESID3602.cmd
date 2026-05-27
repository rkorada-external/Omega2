#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 RISK MARGIN DESIGN
# nom du script SHELL           : ESID3602.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 16/06/2015
# auteur                        : Roger CASSIS
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  :spot:28941 RISK MARGIN DESIGN
#-----------------------------------------------------------------------------
#     historiques des modifications
#[01] 03/06/2016 :spot:30543 Florent on passe à 65 années
#[02] 06/10/2016 :spot:31302 R. cassis Gestion du RISKMARGIN en mode SO et CO
#[03] 18/11/2016 :spira:57799 Florent  Mise au format à 71 colonnes pour le fichier EST_DLDSIIGTAA
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
CRE_D=$1
ICLODAT_D=$2
TYPEINV=$3

# Job Initialisation
JOBINIT

#[02]
if [ "${TYPEINV}" != "INV" ]
then
  EST_GTSII_ESCOMPTE_CLM=${EPO_GTSII_ESCOMPTE_CLM}
  EST_FCTRGROLESII=${EPO_FCTRGROLESII}
  EST_FCURQUOT=${EPO_FCURQUOT}
  EST_FRISKMSII=${EPO_FRISKMSII}
  EST_FTRSLNK=${EPO_FTRSLNK}
  EST_FDETTRS=${EPO_FDETTRS}
  if [ ${TYPEINV} = "POS" ]
  then
    EST_FTECLEDSII=${EPO_FTECLEDSIISO}
    EST_FRISKMSII=${EPO_FRISKMSIISO}
    EST_DLDSIIGTAA=${EPO_DLDSIIGTAASO}
		EST_GTSII_RISKMARGIN=${EPO_GTSII_RISKMARGINSO}
  else
    EST_FRISKMSII=${EPO_FRISKMSIICO}
    EST_FTECLEDSII=${EPO_FTECLEDSIICO}
    EST_DLDSIIGTAA=${EPO_DLDSIIGTAACO}
		EST_GTSII_RISKMARGIN=${EPO_GTSII_RISKMARGINCO}
  fi
fi

ICLODAT_A=`echo ${ICLODAT_D} | awk '{print substr($0,1,4)}'`

touch ${EST_GTSII_ESCOMPTE_CLM}
touch ${EST_FCTRGROLESII}
touch ${EST_FRISKMSII}

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> CRE_D.....................: ${CRE_D}"
ECHO_LOG "#===> ICLODAT_D.................: ${ICLODAT_D}"
ECHO_LOG "#===> TYPEINV...................: ${TYPEINV}"
ECHO_LOG "#....................INPUT.................."
ECHO_LOG "#===> EST_FCURQUOT..............: ${EST_FCURQUOT}"
ECHO_LOG "#===> EST_GTSII_ESCOMPTE_CLM....: ${EST_GTSII_ESCOMPTE_CLM}"
ECHO_LOG "#===> EST_FCTRGROLESII..........: ${EST_FCTRGROLESII}"
ECHO_LOG "#....................OUTPUT.................."
ECHO_LOG "#===> EST_GTSII_RISKMARGIN......: ${EST_GTSII_RISKMARGIN}"
ECHO_LOG "#===> EST_FTECLEDSII............: ${EST_FTECLEDSII}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="Sort of FCTRGROLESII"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCTRGROLESII} 500 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCTRGROLESII_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF    1:1 -  1:,
        END_NT    2:1 -  2:,
        SEC_NF    3:1 -  3:,
        UWY_NF    4:1 -  4:,
        UW_NT     5:1 -  5:,
        VRS_NF    6:1 -  6:,
        SSD_CF    7:1 -  7:,
        LE_NF     8:1 -  8:,
        SII_NF    9:1 -  9:,
        CLODAT_D  10:1 -  10:,
        PER_CF    11:1 -  11:,
        CRE_D     12:1 -  12:
/KEYS   CTR_NF,
        SEC_NF,
        UWY_NF
/SUM
/STABLE
exit
EOF
SORT

NSTEP=${NJOB}_20
# Sort of GTSII ESCOMPTE CLM
#-----------------------------------------------------------------------------
LIBEL="Extraction des sinistres et sinistres futurs discountes de GTSII ESCOMPTE CLM"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_GTSII_ESCOMPTE_CLM} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_ESCOMPTE_CLM_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:
/KEYS   CTR_NF,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT

if [ -s ${EST_FCTRGROLESII} ]
then

NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
LIBEL="Affectation des agregats par segment LE et segment SII"
PRG=ESTC1072
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BALSHTYEA_NF ${ICLODAT_A}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_FCTRGROLESII_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_20_${IB}_SORT_GTSII_ESCOMPTE_CLM_O.dat
export ${PRG}_I3=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTSII_ESCOMPTE_CLM.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTSII_ESCOMPTE_CLM.log
EXECPRG

else
  NSTEP=${NJOB}_35
  # Copie fichiers
  #------------------------------------------------------------------------------
  LIBEL="CSF CALCULATION touch ${DFILT}/${NJOB}_30_${IB}_ESTC1072_GTSII_ESCOMPTE_CLM.dat"
  EXECKSH_MODE=P
  EXECKSH "touch ${DFILT}/${NJOB}_30_${IB}_ESTC1072_GTSII_ESCOMPTE_CLM.dat"
fi


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ESTC1072 "
ECHO_LOG "#===> Nombre de lignes CLAIM ESCOMPTE "
wc -l ${DFILT}/${NJOB}_20_${IB}_SORT_GTSII_ESCOMPTE_CLM_O.dat
ECHO_LOG "#===> Nombre de lignes FCTRGROLESII "
wc -l ${DFILT}/${NJOB}_10_${IB}_SORT_FCTRGROLESII_O.dat
ECHO_LOG "#===> Nombre de lignes GTSII_ESCOMPTE_CLM "
wc -l ${DFILT}/${NJOB}_30_${IB}_ESTC1072_GTSII_ESCOMPTE_CLM.dat
ECHO_LOG "#========================================================================="


NSTEP=${NJOB}_35A
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde de fichier"
GZIPM_I="${DFILT}/${NJOB}_10_${IB}_SORT_FCTRGROLESII_O.dat ${DFILT}/${NJOB}_20_${IB}_SORT_GTSII_ESCOMPTE_CLM_O.dat ${DFILT}/${NJOB}_30_${IB}_ESTC1072_GTSII_ESCOMPTE_CLM.dat"
GZIPM

NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
LIBEL="Tri / somme sur cles LOBSII, LE et norme du fichier GTSII_ESCOMPTE_CLM"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_ESTC1072_GTSII_ESCOMPTE_CLM.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_ESCOMPTE_CLM_O.dat 2000 1"
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
        SEGMENT_SII     124:1 - 124:,
        SEGMENT_LE      125:1 - 125:,
        AMT_EURO_M      126:1 - 126:EN 15/3
/KEYS SEGMENT_LE,
      SEGMENT_SII,
      NORME_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACMCUR_CF
/SUMMARIZE TOTAL AM01_M, TOTAL AM02_M, TOTAL AM03_M, TOTAL AM04_M, TOTAL AM05_M, TOTAL AM06_M, TOTAL AM07_M, TOTAL AM08_M, TOTAL AM09_M, TOTAL AM10_M,
           TOTAL AM11_M, TOTAL AM12_M, TOTAL AM13_M, TOTAL AM14_M, TOTAL AM15_M, TOTAL AM16_M, TOTAL AM17_M, TOTAL AM18_M, TOTAL AM19_M, TOTAL AM20_M,
           TOTAL AM21_M, TOTAL AM22_M, TOTAL AM23_M, TOTAL AM24_M, TOTAL AM25_M, TOTAL AM26_M, TOTAL AM27_M, TOTAL AM28_M, TOTAL AM29_M, TOTAL AM30_M,
           TOTAL AM31_M, TOTAL AM32_M, TOTAL AM33_M, TOTAL AM34_M, TOTAL AM35_M, TOTAL AM36_M, TOTAL AM37_M, TOTAL AM38_M, TOTAL AM39_M, TOTAL AM40_M,
           TOTAL AM41_M, TOTAL AM42_M, TOTAL AM43_M, TOTAL AM44_M, TOTAL AM45_M, TOTAL AM46_M, TOTAL AM47_M, TOTAL AM48_M, TOTAL AM49_M, TOTAL AM50_M,
           TOTAL AM51_M, TOTAL AM52_M, TOTAL AM53_M, TOTAL AM54_M, TOTAL AM55_M, TOTAL AM56_M, TOTAL AM57_M, TOTAL AM58_M, TOTAL AM59_M, TOTAL AM60_M,
           TOTAL AM61_M, TOTAL AM62_M, TOTAL AM63_M, TOTAL AM64_M, TOTAL AM65_M,
           TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M, TOTAL ACMAMT_M, TOTAL TOTAUX_M, TOTAL AMT_EURO_M
/CONDITION NO_SIN SEGMENT_SII != "" AND SEGMENT_SII != "0" AND SEGMENT_LE != "" AND SEGMENT_LE != "0"
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD ACMAMT_MC ACMAMT_M COMPRESS
/DERIVEDFIELD AMT_EURO_MC AMT_EURO_M COMPRESS
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
/OUTFILE ${SORT_O}
/INCLUDE NO_SIN
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
         ,ACMAMT_MC
         ,ACMCUR_CF
         ,PRS_CF
         ,SEG_NF
         ,LOB_CF
         ,NAT_CF
         ,TYP_CT
         ,NORME_CF
         ,RATING_CF
         ,PATCAT_CT
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
         ,SEGMENT_SII
         ,SEGMENT_LE
         ,AMT_EURO_MC
exit
EOF
SORT

NSTEP=${NJOB}_50
#-----------------------------------------------------------------------------
LIBEL="Tri / somme sur cles LOBSII, LE et norme du fichier GTSII_ESCOMPTE_CLM"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_ESTC1072_GTSII_ESCOMPTE_CLM.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_ESCOMPTE_CLM_O.dat 2000 1"
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
        SEGMENT_SII     124:1 - 124:,
        SEGMENT_LE      125:1 - 125:,
        AMT_EURO_M      126:1 - 126:EN 15/3
/KEYS SEGMENT_LE,
      SEGMENT_SII,
      NORME_CF
/SUMMARIZE TOTAL AM01_M, TOTAL AM02_M, TOTAL AM03_M, TOTAL AM04_M, TOTAL AM05_M, TOTAL AM06_M, TOTAL AM07_M, TOTAL AM08_M, TOTAL AM09_M, TOTAL AM10_M,
           TOTAL AM11_M, TOTAL AM12_M, TOTAL AM13_M, TOTAL AM14_M, TOTAL AM15_M, TOTAL AM16_M, TOTAL AM17_M, TOTAL AM18_M, TOTAL AM19_M, TOTAL AM20_M,
           TOTAL AM21_M, TOTAL AM22_M, TOTAL AM23_M, TOTAL AM24_M, TOTAL AM25_M, TOTAL AM26_M, TOTAL AM27_M, TOTAL AM28_M, TOTAL AM29_M, TOTAL AM30_M,
           TOTAL AM31_M, TOTAL AM32_M, TOTAL AM33_M, TOTAL AM34_M, TOTAL AM35_M, TOTAL AM36_M, TOTAL AM37_M, TOTAL AM38_M, TOTAL AM39_M, TOTAL AM40_M,
           TOTAL AM41_M, TOTAL AM42_M, TOTAL AM43_M, TOTAL AM44_M, TOTAL AM45_M, TOTAL AM46_M, TOTAL AM47_M, TOTAL AM48_M, TOTAL AM49_M, TOTAL AM50_M,
           TOTAL AM51_M, TOTAL AM52_M, TOTAL AM53_M, TOTAL AM54_M, TOTAL AM55_M, TOTAL AM56_M, TOTAL AM57_M, TOTAL AM58_M, TOTAL AM59_M, TOTAL AM60_M,
           TOTAL AM61_M, TOTAL AM62_M, TOTAL AM63_M, TOTAL AM64_M, TOTAL AM65_M,
           TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M, TOTAL ACMAMT_M, TOTAL TOTAUX_M, TOTAL AMT_EURO_M
/CONDITION NO_SIN SEGMENT_SII != "" AND SEGMENT_SII != "0" AND SEGMENT_LE != "" AND SEGMENT_LE != "0"
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD ACMAMT_MC ACMAMT_M COMPRESS
/DERIVEDFIELD AMT_EURO_MC AMT_EURO_M COMPRESS
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
/OUTFILE ${SORT_O}
/INCLUDE NO_SIN
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
         ,ACMAMT_MC
         ,ACMCUR_CF
         ,PRS_CF
         ,SEG_NF
         ,LOB_CF
         ,NAT_CF
         ,TYP_CT
         ,NORME_CF
         ,RATING_CF
         ,PATCAT_CT
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
         ,SEGMENT_SII
         ,SEGMENT_LE
         ,AMT_EURO_MC
exit
EOF
SORT

NSTEP=${NJOB}_100
#------------------------------------------------------------------------------
LIBEL="Generation de la cle d'allocation par CSU"
PRG=ESTC1073
INPUT_TEXT ${FPRM} << EOF
BALSHTYEA_NF ${ICLODAT_A}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_40_${IB}_SORT_GTSII_ESCOMPTE_CLM_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_50_${IB}_SORT_GTSII_ESCOMPTE_CLM_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTSII_ALLOC.dat
EXECPRG

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ESTC1073 "
ECHO_LOG "#===> Nombre de lignes GTSII_ESCOMPTE_CLM AU DETAIL PAR CONTRAT "
wc -l ${DFILT}/${NJOB}_40_${IB}_SORT_GTSII_ESCOMPTE_CLM_O.dat
ECHO_LOG "#===> Nombre de lignes GTSII_ESCOMPTE_CLM CUMULE PAR SEGMENT "
wc -l ${DFILT}/${NJOB}_50_${IB}_SORT_GTSII_ESCOMPTE_CLM_O.dat
ECHO_LOG "#===> Nombre de lignes CLE ALLOCATION "
wc -l ${DFILT}/${NJOB}_100_${IB}_ESTC1073_GTSII_ALLOC.dat
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_100A
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde de fichier"
GZIPM_I="${DFILT}/${NJOB}_40_${IB}_SORT_GTSII_ESCOMPTE_CLM_O.dat ${DFILT}/${NJOB}_50_${IB}_SORT_GTSII_ESCOMPTE_CLM_O.dat ${DFILT}/${NJOB}_100_${IB}_${PRG}_GTSII_ALLOC.dat"
GZIPM

NSTEP=${NJOB}_200
#-----------------------------------------------------------------------------
LIBEL="Sort of FRISKMSII"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FRISKMSII} 500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FRISKMSII_O.dat 500 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS LGENSGTVRS_NT    1:1 -  1:,
        LGENSGMT_NF      2:1 -  2:,
        LOBSIISGMTVRS_NT 3:1 -  3:,
        LOBSIISGMT_NF    4:1 -  4:,
        NORME_CF         5:1 -  5:,
        PER_CF           6:1 -  6:,
        CLOSING_D        7:1 -  7:,
        AMT_M            8:1 -  8:,
        CUR_CF           9:1 -  9:,
        CREUSR_CF        10:1 -  10:,
        CRE_D            11:1 -  11:
/KEYS   LGENSGMT_NF,
        LOBSIISGMT_NF,
        NORME_CF
exit
EOF
SORT

NSTEP=${NJOB}_200A
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde de fichier"
GZIPM_I="${DFILT}/${NJOB}_200_${IB}_SORT_FRISKMSII_O.dat"
GZIPM

NSTEP=${NJOB}_300
#------------------------------------------------------------------------------
LIBEL="allocation des montants de Risk Margin par CSU"
PRG=ESTC1074
INPUT_TEXT ${FPRM} << EOF
BALSHTYEA_NF ${ICLODAT_A}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_100_${IB}_ESTC1073_GTSII_ALLOC.dat
export ${PRG}_I2=${DFILT}/${NJOB}_200_${IB}_SORT_FRISKMSII_O.dat
export ${PRG}_I3=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTSII_RISKMARGIN.dat
EXECPRG

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ESTC1074 "
ECHO_LOG "#===> Nombre de lignes CLE ALLOCATION "
wc -l ${DFILT}/${NJOB}_100_${IB}_ESTC1073_GTSII_ALLOC.dat
ECHO_LOG "#===> Nombre de lignes FRISKMSII RISK MARGIN PAR LEDGER "
wc -l ${DFILT}/${NJOB}_200_${IB}_SORT_FRISKMSII_O.dat
ECHO_LOG "#===> Nombre de lignes RISKMARGIN VENTILE "
wc -l ${DFILT}/${NJOB}_300_${IB}_ESTC1074_GTSII_RISKMARGIN.dat
ECHO_LOG "#========================================================================="


NSTEP=${NJOB}_350
#-----------------------------------------------------------------------------
LIBEL="Tri / somme sur cles LOBSII, LE et norme du fichier GTSII_ESCOMPTE_CLM"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_300_${IB}_ESTC1074_GTSII_RISKMARGIN.dat 2000 1"
SORT_O="${EST_GTSII_RISKMARGIN} 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_RISKMARGIN_O.dat 2000 1"
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
        SEGMENT_SII     124:1 - 124:,
        SEGMENT_LE      125:1 - 125:,
        AMT_EURO_M      126:1 - 126:EN 15/3
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT ,
      ACMTRS_NT,
      PATCAT_CT,
      PATTYP_CT,
      NORME_CF,
      RATING_CF,
      ACMCUR_CF
/CONDITION lobacc  TYP_CT = "A"
/DERIVEDFIELD TIFI_M     "0~"
/DERIVEDFIELD DATTRAIT "${CRE_D}~"
/DERIVEDFIELD USER     "CloP~"
/DERIVEDFIELD CLODAT_D "${ICLODAT_D}~"
/DERIVEDFIELD CLOTYP_CT "${TYPEINV}~"
/DERIVEDFIELD PATTYP2 "RISKM~"
/DERIVEDFIELD PATCAT1 "DSC~"
/DERIVEDFIELD PATCAT2 "RISKM~"
/DERIVEDFIELD ACMTRS2 "317~"
/DERIVEDFIELD LOBACC_NEW if  lobacc then LOB_CF else ""
/DERIVEDFIELD LOBRET_NEW if  lobacc then "" else LOB_CF
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          CLODAT_D,
          CLOTYP_CT,
          BALSHEY_NF,
          BALSHRMTH_NF,
          BALSHRDAY_NF,
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
          ACMTRS2,
          ACMAMT_M,
          ACMCUR_CF,
          DSCCUR_CF,
          PRS_CF,
          SEGMENT_SII,
          LOBACC_NEW,
          LOBRET_NEW,
          NAT_CF,
          TYP_CT,
          NORME_CF,
          RATING_CF,
          COEF_LOB,
          PATCAT2,
          PATTYP2,
          PATTERN_ID,
          DATTRAIT,
          USER,
          TOTAUX_M,
          AM1_40,
          SEGMENT_LE,
          TIFI_M,
          AM41_65
/OUTFILE ${SORT_O2}
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
     ,ACMTRS2
     ,ACMAMT_M
     ,ACMCUR_CF
     ,PRS_CF
     ,SEG_NF
     ,LOB_CF
     ,NAT_CF
     ,TYP_CT
     ,NORME_CF
     ,RATING_CF
     ,PATCAT1
     ,PATTYP2
     ,PATTERN_ID
     ,AM01_M
     ,AM02_M
     ,AM03_M
     ,AM04_M
     ,AM05_M
     ,AM06_M
     ,AM07_M
     ,AM08_M
     ,AM09_M
     ,AM10_M
     ,AM11_M
     ,AM12_M
     ,AM13_M
     ,AM14_M
     ,AM15_M
     ,AM16_M
     ,AM17_M
     ,AM18_M
     ,AM19_M
     ,AM20_M
     ,AM21_M
     ,AM22_M
     ,AM23_M
     ,AM24_M
     ,AM25_M
     ,AM26_M
     ,AM27_M
     ,AM28_M
     ,AM29_M
     ,AM30_M
     ,AM31_M
     ,AM32_M
     ,AM33_M
     ,AM34_M
     ,AM35_M
     ,AM36_M
     ,AM37_M
     ,AM38_M
     ,AM39_M
     ,AM40_M
     ,AM41_M
     ,AM42_M
     ,AM43_M
     ,AM44_M
     ,AM45_M
     ,AM46_M
     ,AM47_M
     ,AM48_M
     ,AM49_M
     ,AM50_M
     ,AM51_M
     ,AM52_M
     ,AM53_M
     ,AM54_M
     ,AM55_M
     ,AM56_M
     ,AM57_M
     ,AM58_M
     ,AM59_M
     ,AM60_M
     ,AM61_M
     ,AM62_M
     ,AM63_M
     ,AM64_M
     ,AM65_M
     ,COEF_LOB
     ,DSCCUR_CF
     ,COMMENT
     ,TOTAUX_M
exit
EOF
SORT

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ESID "
ECHO_LOG "#===> Nombre de lignes FTECLEDSII : ${EST_FTECLEDSII}"
wc -l ${EST_FTECLEDSII}
ECHO_LOG "#===> Nombre de lignes FTECLEDSII RISK MARGIN : ${EST_GTSII_RISKMARGIN}"
wc -l ${EST_GTSII_RISKMARGIN}
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_400
#-----------------------------------------------------------------------------
LIBEL="Generation des lignes GT supplementaires pour Accept"
PRG=ESTC1060
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ICLODAT_D ${ICLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_350_${IB}_SORT_GTSII_RISKMARGIN_O.dat
export ${PRG}_I2=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLDSIIRMGTAA.dat  # [006]
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_DLDSIIRMGTAA_ANO.log  # [006]
EXECPRG

NSTEP=${NJOB}_400A
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde de fichier"
GZIPM_I="${DFILT}/${NJOB}_300_${IB}_ESTC1074_GTSII_RISKMARGIN.dat ${DFILT}/${NJOB}_400_${IB}_ESTC1060_DLDSIIRMGTAA.dat ${DFILT}/${NJOB}_350_${IB}_SORT_GTSII_RISKMARGIN_O.dat"
GZIPM

NSTEP=${NJOB}_420
#-----------------------------------------------------------------------------
LIBEL="DLDSIIGTAA Double entry transaction code addition GTA in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_400_${IB}_ESTC1060_DLDSIIRMGTAA.dat
export ${PRG}_I2=${EST_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLDSIIRMGTAA.dat
EXECPRG

NSTEP=${NJOB}_420A
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde de fichier"
GZIPM_I="${DFILT}/${NJOB}_420_${IB}_ESTM7603_DLDSIIRMGTAA.dat"
GZIPM

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ESTM7603 "
ECHO_LOG "#===> Nombre de lignes GTA SII "
wc -l ${EST_DLDSIIGTAA}
ECHO_LOG "#===> Nombre de lignes GTA SII RISK MARGIN "
wc -l ${DFILT}/${NJOB}_420_${IB}_ESTM7603_DLDSIIRMGTAA.dat
ECHO_LOG "#========================================================================="

#[02]
NSTEP=${NJOB}_440
#------------------------------------------------------------------------------
LIBEL="add ${DFILT}/${NJOB}_420_${IB}_ESTM7603_DLDSIIRMGTAA.dat to ${EST_DLDSIIGTAA}"
EXECKSH_MODE=P
EXECKSH "cat ${DFILT}/${NJOB}_420_${IB}_ESTM7603_DLDSIIRMGTAA.dat >> ${EST_DLDSIIGTAA}"

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ESTM7603 "
ECHO_LOG "#===> Nombre de lignes GTA SII + RISK MARGIN "
wc -l ${EST_DLDSIIGTAA}
ECHO_LOG "#========================================================================="



NSTEP=${NJOB}_600
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
