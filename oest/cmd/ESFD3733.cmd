#!/bin/ksh
#=============================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 req 08.01 : Merge cashflow for AOC
# Nom du script SHELL           : ESFD3733.cmd
# Revision                      : $Revision:   1.0  $
# Date de creation              : 14/10/2020
# Auteur                        : Linh.DOAN
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Description
# Merge cashflow for AOC
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
#     <indice>  <jj/mm/aaaa>  <auteur>        <spira>    <description de la modification>
#     [001]      14/10/2020   Linh DOAN       84655      prepare TTECLEDSII for AoC       
#     [002]	 20/11/2020   Linh DOAN	      84655 	 fix CLOTYP_CT
#====================================================================================================
#set -x




# all generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctpar.cmd



CLODAT_D=${PARM_ICLODAT_D}



ECHO_LOG ""                                                                                     >>$FLOG
ECHO_LOG "#....................... INPUT ..........................................."           >>$FLOG
ECHO_LOG "#===> CLODAT_D......................: ${CLODAT_D} "                            >>$FLOG
ECHO_LOG "#===> NORME_CF......................: ${NORME_CF} "                            >>$FLOG


ECHO_LOG "#===> ESF_GTSII_AA1.................: ${ESF_GTSII_AA1} "                >>$FLOG
ECHO_LOG "#===> ESF_GTSII_AA2.................: ${ESF_GTSII_AA2} "              >>$FLOG

ECHO_LOG "#....................... OUTPUT ..........................................."          >>$FLOG
ECHO_LOG "#===> ESF_FTECLEDSII ......................: ${ESF_FTECLEDSII}"             >>$FLOG
ECHO_LOG "#========================================================================="           >>$FLOG



# Job Initialisation
JOBINIT


NSTEP=${NJOB}_01
#------------------------------------------------------------------------------------
LIBEL="MANAGE UNFOUND FILES "


if [ ! -f ${ESF_GTSII_RAD_LKI_AA0} ]
then
        ECHO_LOG "ESF_GTSII_RAD_LKI_AA0=${ESF_GTSII_RAD_LKI_AA0}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_GTSII_RAD_LKI_AA0}"
fi



if [ ! -f ${ESF_GTSII_DSC_LKI_AA0} ]
then
        ECHO_LOG "ESF_GTSII_DSC_LKI_AA0=${ESF_GTSII_DSC_LKI_AA0}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_GTSII_DSC_LKI_AA0}"
fi

if [ ! -f ${ESF_GTSII_RAD_LKI_AA1} ]
then
        ECHO_LOG "ESF_GTSII_RAD_LKI_AA1=${ESF_GTSII_RAD_LKI_AA1}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_GTSII_RAD_LKI_AA1}"
fi



if [ ! -f ${ESF_GTSII_DSC_LKI_AA1} ]
then
        ECHO_LOG "ESF_GTSII_DSC_LKI_AA1=${ESF_GTSII_DSC_LKI_AA1}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_GTSII_DSC_LKI_AA1}"
fi


if [ ! -f ${ESF_GTSII_RAD_LKI_AA2} ]
then
        ECHO_LOG "ESF_GTSII_RAD_LKI_AA2=${ESF_GTSII_RAD_LKI_AA2}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_GTSII_RAD_LKI_AA2}"
fi



if [ ! -f ${ESF_GTSII_DSC_LKI_AA2} ]
then
        ECHO_LOG "ESF_GTSII_DSC_LKI_AA2=${ESF_GTSII_DSC_LKI_AA2}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_GTSII_DSC_LKI_AA2}"
fi


if [ ! -f ${ESF_GTSII_RAD_LKI_AA3} ]
then
        ECHO_LOG "ESF_GTSII_RAD_LKI_AA3=${ESF_GTSII_RAD_LKI_AA3}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_GTSII_RAD_LKI_AA3}"
fi



if [ ! -f ${ESF_GTSII_DSC_LKI_AA3} ]
then
        ECHO_LOG "ESF_GTSII_DSC_LKI_AA3=${ESF_GTSII_DSC_LKI_AA3}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_GTSII_DSC_LKI_AA3}"
fi


PARALLEL_INIT 4



NSTEP=${NJOB}_20
LIBEL="Merge GTASII ALL"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_GTSII_DSC_LKI_AA0} 2000 1"
SORT_I2="${ESF_GTSII_RAD_LKI_AA0} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTASII_AA0.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 - 18:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        PLC_NT           36:1 - 36:EN,
        SEGNAT_CT        48:1 - 48:,
        ACCRET_CF        49:1 - 49:,
        NORME_CF         50:1 - 50:,		
		PATCAT_CT3       52:1 - 52:3,
		PATTYP_CT3       53:1 - 53:3,
		GTSII_ALL		 1:1 - 124:	
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        ACCRET_CF,
        SEGNAT_CT,
        PLC_NT,
        CUR_CF
/CONDITION CSF_LKI (( PATCAT_CT3 = "DSC" or PATCAT_CT3 = "BDT" or PATCAT_CT3 = "RAD" ) and  PATTYP_CT3 = "LKI" )
/DERIVEDFIELD ACTASS_CT "AA0~"
/OUTFILE ${SORT_O}
/INCLUDE CSF_LKI
/REFORMAT GTSII_ALL, ACTASS_CT

exit
EOF
#SORT
PARALLEL SORT


NSTEP=${NJOB}_30
LIBEL="Merge GTASII ALL"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_GTSII_DSC_LKI_AA1} 2000 1"
SORT_I2="${ESF_GTSII_RAD_LKI_AA1} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTASII_AA1.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 - 18:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        PLC_NT           36:1 - 36:EN,
        SEGNAT_CT        48:1 - 48:,
        ACCRET_CF        49:1 - 49:,
        NORME_CF         50:1 - 50:,
		PATCAT_CT3       52:1 - 52:3,
		PATTYP_CT3       53:1 - 53:3,		
		GTSII_ALL		 1:1 - 124:	
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        ACCRET_CF,
        SEGNAT_CT,
        PLC_NT,
        CUR_CF
/CONDITION CSF_LKI ((PATCAT_CT3 = "DSC" or PATCAT_CT3 = "BDT" or PATCAT_CT3 = "RAD"  ) and  PATTYP_CT3 = "LKI" )
/DERIVEDFIELD ACTASS_CT "AA1~"
/OUTFILE ${SORT_O}
/INCLUDE CSF_LKI
/REFORMAT GTSII_ALL, ACTASS_CT

exit
EOF
#SORT
PARALLEL SORT

NSTEP=${NJOB}_40
LIBEL="Merge GTASII ALL"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_GTSII_DSC_LKI_AA2} 2000 1"
SORT_I2="${ESF_GTSII_RAD_LKI_AA2} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTASII_AA2.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 - 18:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        PLC_NT           36:1 - 36:EN,
        SEGNAT_CT        48:1 - 48:,
        ACCRET_CF        49:1 - 49:,
        NORME_CF         50:1 - 50:,
		PATCAT_CT3       52:1 - 52:3,
		PATTYP_CT3       53:1 - 53:3,
		GTSII_ALL		 1:1 - 124: 	
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        ACCRET_CF,
        SEGNAT_CT,
        PLC_NT,
        CUR_CF
/CONDITION CSF_LKI ((PATCAT_CT3 = "DSC" or PATCAT_CT3 = "BDT" or PATCAT_CT3 = "RAD"  ) and  PATTYP_CT3 = "LKI" )
/DERIVEDFIELD ACTASS_CT "AA2~"
/OUTFILE ${SORT_O}
/INCLUDE CSF_LKI
/REFORMAT GTSII_ALL, ACTASS_CT

exit
EOF
#SORT
PARALLEL SORT

NSTEP=${NJOB}_50
LIBEL="Merge GTASII ALL"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_GTSII_DSC_LKI_AA3} 2000 1"
SORT_I2="${ESF_GTSII_RAD_LKI_AA3} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTASII_AA3.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 - 18:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        PLC_NT           36:1 - 36:EN,
        SEGNAT_CT        48:1 - 48:,
        ACCRET_CF        49:1 - 49:,
        NORME_CF         50:1 - 50:,
		PATCAT_CT3       52:1 - 52:3,
		PATTYP_CT3       53:1 - 53:3,
		GTSII_ALL		 1:1 - 124: 	
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        ACCRET_CF,
        SEGNAT_CT,
        PLC_NT,
        CUR_CF
/CONDITION CSF_LKI ((PATCAT_CT3 = "DSC" or PATCAT_CT3 = "BDT" or PATCAT_CT3 = "RAD") and  PATTYP_CT3 = "LKI" )
/DERIVEDFIELD ACTASS_CT "AA3~"
/OUTFILE ${SORT_O}
/INCLUDE CSF_LKI
/REFORMAT GTSII_ALL, ACTASS_CT

exit
EOF
#SORT
PARALLEL SORT

PARALLEL_END


NSTEP=${NJOB}_60
LIBEL="Merge GTASII ALL"

SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_GTASII_AA0.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_30_${IB}_SORT_GTASII_AA1.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_40_${IB}_SORT_GTASII_AA2.dat 2000 1"
SORT_I4="${DFILT}/${NJOB}_50_${IB}_SORT_GTASII_AA3.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTASII_ALL.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 - 18:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        PLC_NT           36:1 - 36:EN,
        SEGNAT_CT        48:1 - 48:,
        ACCRET_CF        49:1 - 49:,
        NORME_CF         50:1 - 50:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        ACCRET_CF,
        SEGNAT_CT,
        PLC_NT,
        CUR_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT




NSTEP=${NJOB}_70

LIBEL="Merge IFRS17 cashflow and discount files : INI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_SORT_GTASII_ALL.dat 2000 1"
SORT_O="${ESF_FTECLEDSII} 2000 1"

INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
    SSD_CF            1:1 -  1:EN,
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
        AMT_M            19:1 - 19:EN 18/3,
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
        RETAMT_M         35:1 - 35:EN 18/3,
        PLC_NT           36:1 - 36:EN,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 18/3,
        ACMTRS_NT        42:1 - 42:,
        ACMAMT_M         43:1 - 43:EN 18/3,
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
        PATTYP_CT        53:1 - 53:,
        PATTERN_ID       54:1 - 54:,
        AM01_M           55:1 - 55:EN 18/3,
        AM02_M           56:1 - 56:EN 18/3,
        AM03_M           57:1 - 57:EN 18/3,
        AM04_M           58:1 - 58:EN 18/3,
        AM05_M           59:1 - 59:EN 18/3,
        AM06_M           60:1 - 60:EN 18/3,
        AM07_M           61:1 - 61:EN 18/3,
        AM08_M           62:1 - 62:EN 18/3,
        AM09_M           63:1 - 63:EN 18/3,
        AM10_M           64:1 - 64:EN 18/3,
        AM11_M           65:1 - 65:EN 18/3,
        AM12_M           66:1 - 66:EN 18/3,
        AM13_M           67:1 - 67:EN 18/3,
        AM14_M           68:1 - 68:EN 18/3,
        AM15_M           69:1 - 69:EN 18/3,
        AM16_M           70:1 - 70:EN 18/3,
        AM17_M           71:1 - 71:EN 18/3,
        AM18_M           72:1 - 72:EN 18/3,
        AM19_M           73:1 - 73:EN 18/3,
        AM20_M           74:1 - 74:EN 18/3,
        AM21_M           75:1 - 75:EN 18/3,
        AM22_M           76:1 - 76:EN 18/3,
        AM23_M           77:1 - 77:EN 18/3,
        AM24_M           78:1 - 78:EN 18/3,
        AM25_M           79:1 - 79:EN 18/3,
        AM26_M           80:1 - 80:EN 18/3,
        AM27_M           81:1 - 81:EN 18/3,
        AM28_M           82:1 - 82:EN 18/3,
        AM29_M           83:1 - 83:EN 18/3,
        AM30_M           84:1 - 84:EN 18/3,
        AM31_M           85:1 - 85:EN 18/3,
        AM32_M           86:1 - 86:EN 18/3,
        AM33_M           87:1 - 87:EN 18/3,
        AM34_M           88:1 - 88:EN 18/3,
        AM35_M           89:1 - 89:EN 18/3,
        AM36_M           90:1 - 90:EN 18/3,
        AM37_M           91:1 - 91:EN 18/3,
        AM38_M           92:1 - 92:EN 18/3,
        AM39_M           93:1 - 93:EN 18/3,
        AM40_M           94:1 - 94:EN 18/3,
        AM41_M           95:1 - 95:EN 18/3,
        AM42_M           96:1 - 96:EN 18/3,
        AM43_M           97:1 - 97:EN 18/3,
        AM44_M           98:1 - 98:EN 18/3,
        AM45_M           99:1 - 99:EN 18/3,
        AM46_M          100:1 - 100:EN 18/3,
        AM47_M          101:1 - 101:EN 18/3,
        AM48_M          102:1 - 102:EN 18/3,
        AM49_M          103:1 - 103:EN 18/3,
        AM50_M          104:1 - 104:EN 18/3,
        AM51_M          105:1 - 105:EN 18/3,
        AM52_M          106:1 - 106:EN 18/3,
        AM53_M          107:1 - 107:EN 18/3,
        AM54_M          108:1 - 108:EN 18/3,
        AM55_M          109:1 - 109:EN 18/3,
        AM56_M          110:1 - 110:EN 18/3,
        AM57_M          111:1 - 111:EN 18/3,
        AM58_M          112:1 - 112:EN 18/3,
        AM59_M          113:1 - 113:EN 18/3,
        AM60_M          114:1 - 114:EN 18/3,
        AM61_M          115:1 - 115:EN 18/3,
        AM62_M          116:1 - 116:EN 18/3,
        AM63_M          117:1 - 117:EN 18/3,
        AM64_M          118:1 - 118:EN 18/3,
        AM65_M          119:1 - 119:EN 18/3,
        COEF_LOB        120:1 - 120:,
        DSCCUR_CF       121:1 - 121:,
        COMMENT         122:1 - 122:,
        TOTAUX_M        123:1 - 123:EN 18/3,
		ACMTRS3_NT    124:1 - 124:EN 18/3,
		ACTASS_CT     125:1 - 125:

/KEYS     CTR_NF,
    END_NT,  
    SEC_NF,
    UWY_NF,
    UW_NT

/CONDITION pattern PATTERN_ID = ""
/CONDITION pattyp  PATTYP_CT = ""
/CONDITION patcat  PATCAT_CT = ""
/CONDITION lobacc  TYP1_CT = "A"
/DERIVEDFIELD DATTRAIT "${CRE_D}~"
/DERIVEDFIELD USER     "CloP~"
/DERIVEDFIELD PATTERN2_ID if pattern then "EMPTY" else PATTERN_ID
/DERIVEDFIELD PATTYP2 if  pattyp then "ER" else PATTYP_CT
/DERIVEDFIELD PATCAT2 if  patcat then "ER" else PATCAT_CT
/DERIVEDFIELD LOBACC_CF if  lobacc then LOB_CF else ""
/DERIVEDFIELD LOBRET_CF if  lobacc then "" else LOB_CF
/DERIVEDFIELD CLODAT_D "${CLODAT_D}~"
/DERIVEDFIELD CLOTYP_CT "${TYPEINV}~"
/DERIVEDFIELD CLODAT_A "${ICLODAT_A}~"
/DERIVEDFIELD CLODAT_M "${ICLODAT_M}~"
/DERIVEDFIELD CLODAT_J "${ICLODAT_J}~"
/DERIVEDFIELD TYPA_CT "A~"
/DERIVEDFIELD TIFI_M     "0~"

/DERIVEDFIELD    ACMAMT_MC      ACMAMT_M          COMPRESS
/DERIVEDFIELD      AM01_MC        AM01_M          COMPRESS
/DERIVEDFIELD      AM02_MC        AM02_M          COMPRESS
/DERIVEDFIELD      AM03_MC        AM03_M          COMPRESS
/DERIVEDFIELD      AM04_MC        AM04_M          COMPRESS
/DERIVEDFIELD      AM05_MC        AM05_M          COMPRESS
/DERIVEDFIELD      AM06_MC        AM06_M          COMPRESS
/DERIVEDFIELD      AM07_MC        AM07_M          COMPRESS
/DERIVEDFIELD      AM08_MC        AM08_M          COMPRESS
/DERIVEDFIELD      AM09_MC        AM09_M          COMPRESS
/DERIVEDFIELD      AM10_MC        AM10_M          COMPRESS
/DERIVEDFIELD      AM11_MC        AM11_M          COMPRESS
/DERIVEDFIELD      AM12_MC        AM12_M          COMPRESS
/DERIVEDFIELD      AM13_MC        AM13_M          COMPRESS
/DERIVEDFIELD      AM14_MC        AM14_M          COMPRESS
/DERIVEDFIELD      AM15_MC        AM15_M          COMPRESS
/DERIVEDFIELD      AM16_MC        AM16_M          COMPRESS
/DERIVEDFIELD      AM17_MC        AM17_M          COMPRESS
/DERIVEDFIELD      AM18_MC        AM18_M          COMPRESS
/DERIVEDFIELD      AM19_MC        AM19_M          COMPRESS
/DERIVEDFIELD      AM20_MC        AM20_M          COMPRESS
/DERIVEDFIELD      AM21_MC        AM21_M          COMPRESS
/DERIVEDFIELD      AM22_MC        AM22_M          COMPRESS
/DERIVEDFIELD      AM23_MC        AM23_M          COMPRESS
/DERIVEDFIELD      AM24_MC        AM24_M          COMPRESS
/DERIVEDFIELD      AM25_MC        AM25_M          COMPRESS
/DERIVEDFIELD      AM26_MC        AM26_M          COMPRESS
/DERIVEDFIELD      AM27_MC        AM27_M          COMPRESS
/DERIVEDFIELD      AM28_MC        AM28_M          COMPRESS
/DERIVEDFIELD      AM29_MC        AM29_M          COMPRESS
/DERIVEDFIELD      AM30_MC        AM30_M          COMPRESS
/DERIVEDFIELD      AM31_MC        AM31_M          COMPRESS
/DERIVEDFIELD      AM32_MC        AM32_M          COMPRESS
/DERIVEDFIELD      AM33_MC        AM33_M          COMPRESS
/DERIVEDFIELD      AM34_MC        AM34_M          COMPRESS
/DERIVEDFIELD      AM35_MC        AM35_M          COMPRESS
/DERIVEDFIELD      AM36_MC        AM36_M          COMPRESS
/DERIVEDFIELD      AM37_MC        AM37_M          COMPRESS
/DERIVEDFIELD      AM38_MC        AM38_M          COMPRESS
/DERIVEDFIELD      AM39_MC        AM39_M          COMPRESS
/DERIVEDFIELD      AM40_MC        AM40_M          COMPRESS
/DERIVEDFIELD      AM41_MC        AM41_M          COMPRESS
/DERIVEDFIELD      AM42_MC        AM42_M          COMPRESS
/DERIVEDFIELD      AM43_MC        AM43_M          COMPRESS
/DERIVEDFIELD      AM44_MC        AM44_M          COMPRESS
/DERIVEDFIELD      AM45_MC        AM45_M          COMPRESS
/DERIVEDFIELD      AM46_MC        AM46_M          COMPRESS
/DERIVEDFIELD      AM47_MC        AM47_M          COMPRESS
/DERIVEDFIELD      AM48_MC        AM48_M          COMPRESS
/DERIVEDFIELD      AM49_MC        AM49_M          COMPRESS
/DERIVEDFIELD      AM50_MC        AM50_M          COMPRESS
/DERIVEDFIELD      AM51_MC        AM51_M          COMPRESS
/DERIVEDFIELD      AM52_MC        AM52_M          COMPRESS
/DERIVEDFIELD      AM53_MC        AM53_M          COMPRESS
/DERIVEDFIELD      AM54_MC        AM54_M          COMPRESS
/DERIVEDFIELD      AM55_MC        AM55_M          COMPRESS
/DERIVEDFIELD      AM56_MC        AM56_M          COMPRESS
/DERIVEDFIELD      AM57_MC        AM57_M          COMPRESS
/DERIVEDFIELD      AM58_MC        AM58_M          COMPRESS
/DERIVEDFIELD      AM59_MC        AM59_M          COMPRESS
/DERIVEDFIELD      AM60_MC        AM60_M          COMPRESS
/DERIVEDFIELD      AM61_MC        AM61_M          COMPRESS
/DERIVEDFIELD      AM62_MC        AM62_M          COMPRESS
/DERIVEDFIELD      AM63_MC        AM63_M          COMPRESS
/DERIVEDFIELD      AM64_MC        AM64_M          COMPRESS
/DERIVEDFIELD      AM65_MC        AM65_M          COMPRESS
/DERIVEDFIELD    TOTAUX_MC      TOTAUX_M          COMPRESS

/OUTFILE ${SORT_O}
/REFORMAT
  SSD_CF
 ,ESB_CF
 ,CLODAT_D
 ,CLOTYP_CT
 ,BALSHEY_NF
 ,BALSHRMTH_NF
 ,BALSHRDAY_NF
 ,CTR_NF
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
 ,RTO_NF
 ,ACMTRS_NT
 ,ACMAMT_MC
 ,ACMCUR_CF
 ,DSCCUR_CF
 ,PRS_CF
 ,SEG_NF
 ,LOBACC_CF
 ,LOBRET_CF
 ,NAT_CF
 ,TYP_CT
 ,NORME_CF
 ,RATING_CF
 ,COEF_LOB
 ,PATCAT2
 ,PATTYP2
 ,PATTERN2_ID
 ,DATTRAIT
 ,USER
 ,TOTAUX_MC
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
 ,COMMENT
 ,TIFI_M
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
 ,ACMTRS3_NT
 ,ACTASS_CT
exit
EOF
SORT


JOBEND

