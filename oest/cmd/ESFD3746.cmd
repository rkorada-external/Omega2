#!/bin/ksh
#====================================================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 req 08.01 : IFRS17 TL data generation 
# Nom du script SHELL           : ESFD3746.cmd
# Revision                      : $Revision:   1.0  $
# Date de creation              : 15/09/2020
# Auteur                        : L.DOAN
# References des specifications :
#----------------------------------------------------------------------------------------------------
# http://dcvprdxwikiu/xwiki/wiki/omega/view/DEV/BPR-EST-906572 : Assumed contract at inception
# http://dcvprdxwikiu/xwiki/wiki/omega/view/DEV/BPR-EST-911737 : Retro contract at inception
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
# 	<indice>	<jj/mm/aaaa>   	<auteur>   	<spira> 		<description de la modification>
#   [001]   15/09/2020      L.DOAN      SPIRA : 87876           integrate NDIC futures at inception
# 	[002]   21/01/2021      L.DOAN      SPIRA : 90406           IFRS17- NDIC assumed cession
#   [003]   22/02/2021      N.DOAN      SPIRA : 90091 Multiyear changes on GLT transformation
# 	[004]   09/09/2021      N.DOAN      SPIRA : 98275 remove ESF_ACC_NDIC_RET_P_GTR et ESF_ACC_NDIC_RET_P_GTAR 
#   [005] 	07/07/2022      JBD			Spira : 104778  Build new closing for I17S norm
#   [006] 	23/09/2022  	MZM			Spira : 106944 Update counterparty in I17 RA/SAP interface following in I17
#   [007]   28/11/2022      DAD	        Spira : 107135 transforme NDIC TRNCODE STD for future Onerous and Dummy
#   [008]   26/05/2023      DAD	        Spira : 109733 remove NDIC doubled when generating POS from INI on dummy contracts
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters


# Job Initialisation
JOBINIT

#################################################
# NDIC futures at inception to IFRS17                         #
#################################################

NORME_SUFFIX='R'

if [  $NORME_CF = I17G ] || [  $NORME_CF = I17S ]
then
    NORME_SUFFIX='I'
else
    if [  $NORME_CF = I17P ]
    then
         NORME_SUFFIX='K'
    else
        if [  $NORME_CF = I17L ]
        then
            NORME_SUFFIX='M'
        fi
    fi
fi


NSTEP=${NJOB}_01
LIBEL="MANAGE UNFOUND FILES " 
if [ ! -f ${ESF_ACC_NDIC} ]
then
        ECHO_LOG "ESF_ACC_NDIC=${ESF_ACC_NDIC}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_ACC_NDIC}"
fi

if [ ! -f ${ESF_ACC_NDIC_RET_NP} ]
then
        ECHO_LOG "ESF_ACC_NDIC_RET=${ESF_ACC_NDIC_RET_NP}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_ACC_NDIC_RET_NP}"
fi


# [008]
NSTEP=${NJOB}_05
LIBEL="Preparing GTSII Dummy"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_GTSII_DUMMY_STD} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_DUMMY.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF       6:1 - 6:,
        CTR_NF          8:1 - 8:,
        END_NT          9:1 - 9:EN,
        SEC_NF         10:1 - 10:EN,
        UWY_NF         11:1 - 11:,
        UW_NT          12:1 - 12:EN,
	CUR_CF         18:1 - 18:,
	RETCTR_NF      24:1 - 24:,
        RETEND_NT      25:1 - 25:,
        RETSEC_NF      26:1 - 26:,
        RTY_NF         27:1 - 27:,
        RETUW_NT       28:1 - 28:,
        FILLER_1_30    1:1  - 30:
/KEYS   TRNCOD_CF,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
	RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT
/SUMMARIZE
/OUTFILE ${SORT_O} overwrite
/REFORMAT FILLER_1_30
exit
EOF
SORT

NSTEP=${NJOB}_10
LIBEL="Merge NDIC for GTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_ACC_NDIC} 2000 1"
SORT_I2="${ESF_ACC_NDIC_RET_NP} 2000 1"
#SORT_I3="${ESF_ACC_NDIC_RET_P_GTAR} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_NDIC_ASSUMED_INI.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
	CUR_CF           18:1 -  18:,
	RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
	RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT
/OUTFILE ${SORT_O} 
exit
EOF
SORT

# [007]
NSTEP=${NJOB}_11
LIBEL="Extract NDIC Future Onerous"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_NDIC_ASSUMED_INI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_NDIC_ONEFUT.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_CTR_NF       8:1 -  8:,
        GT_END_NT       9:1 -  9:,
        GT_SEC_NF       10:1 - 10:,
        GT_UWY_NF       11:1 - 11:,
        GT_UW_NT        12:1 - 12:,
        GT_TRNCOD_CF    6:1 - 6:,
        GT_ALL_COLS     1:1 - 41:,
        CTR_NF          8:1 - 8:,
        END_NT          9:1 - 9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        TRNCOD_CF       6:1 - 6:
/joinkeys 
        GT_CTR_NF,
        GT_END_NT,
        GT_SEC_NF,
        GT_UWY_NF,
        GT_UW_NT,
        GT_TRNCOD_CF
/INFILE ${ESF_GTSII_ONEFUT_STD} 2000 1 "~"
/joinkeys 
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        GT_TRNCOD_CF
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        LEFTSIDE:GT_ALL_COLS
exit
EOF
SORT

# [007] [008]
NSTEP=${NJOB}_12
LIBEL="Extract NDIC Future Dummy"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_NDIC_ASSUMED_INI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_NDIC_DUMMYFUT.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_CTR_NF       8:1 -  8:,
        GT_END_NT       9:1 -  9:,
        GT_SEC_NF       10:1 - 10:,
        GT_UWY_NF       11:1 - 11:,
        GT_UW_NT        12:1 - 12:,
        GT_TRNCOD_CF    6:1 - 6:,
        GT_ALL_COLS     1:1 - 41:,
        CTR_NF          8:1 - 8:,
        END_NT          9:1 - 9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        TRNCOD_CF       6:1 - 6:
/joinkeys 
        GT_CTR_NF,
        GT_END_NT,
        GT_SEC_NF,
        GT_UWY_NF,
        GT_UW_NT,
        GT_TRNCOD_CF
/INFILE ${DFILT}/${NJOB}_05_${IB}_SORT_GTSII_DUMMY.dat 2000 1 "~"
/joinkeys 
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        GT_TRNCOD_CF
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        LEFTSIDE:GT_ALL_COLS
exit
EOF
SORT

# [007]
NSTEP=${NJOB}_15
LIBEL="Merge NDIC Future Onerous and Dummy"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_11_${IB}_SORT_NDIC_ONEFUT.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_12_${IB}_SORT_NDIC_DUMMYFUT.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_NDIC_ONEFUT_DUMMY.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
	    CUR_CF           18:1 -  18:,
	    RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
	    RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT
/OUTFILE ${SORT_O} 
exit
EOF
SORT


NSTEP=${NJOB}_20
LIBEL="Merge NDIC for GTR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_ACC_NDIC_RET_NP} 2000 1"
#SORT_I2="${ESF_ACC_NDIC_RET_P_GTR} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_NDIC_RETRO_INI.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
	CUR_CF           18:1 -  18:,
	RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
	RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT
/OUTFILE ${SORT_O} 
exit
EOF
SORT

# [007] [008]
NSTEP=${NJOB}_21
LIBEL="Extract NDIC Future Dummy for GTR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_NDIC_RETRO_INI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_NDIC_RETRO_DUMMY.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_CTR_NF       8:1 -  8:,
        GT_END_NT       9:1 -  9:,
        GT_SEC_NF       10:1 - 10:,
        GT_UWY_NF       11:1 - 11:,
        GT_UW_NT        12:1 - 12:,
        GT_TRNCOD_CF    6:1 - 6:,
        GT_ALL_COLS     1:1 - 41:,
        CTR_NF          8:1 - 8:,
        END_NT          9:1 - 9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        TRNCOD_CF       6:1 - 6:
/joinkeys 
        GT_CTR_NF,
        GT_END_NT,
        GT_SEC_NF,
        GT_UWY_NF,
        GT_UW_NT,
        GT_TRNCOD_CF
/INFILE ${DFILT}/${NJOB}_05_${IB}_SORT_GTSII_DUMMY.dat 2000 1 "~"
/joinkeys 
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        GT_TRNCOD_CF
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        LEFTSIDE:GT_ALL_COLS
exit
EOF
SORT

# [007]
NSTEP=${NJOB}_25
LIBEL="Transforme NDIC TRNCOD for Futures Onerous and Dummy"
AWK_I="${DFILT}/${NJOB}_15_${IB}_SORT_NDIC_ONEFUT_DUMMY.dat"
AWK_O="${DFILT}/${NSTEP}_${IB}_SORT_NDIC_ONEFUT_DUMMY.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
      if (\$6 == "1143013${NORME_SUFFIX}") { \$6 = "1143014${NORME_SUFFIX}";  \$7 = "1243014${NORME_SUFFIX}";  }
 else if (\$6 == "1143020${NORME_SUFFIX}") { \$6 = "1143034${NORME_SUFFIX}";  \$7 = "1243034${NORME_SUFFIX}";  }
 else if (\$6 == "1143030${NORME_SUFFIX}") { \$6 = "1143024${NORME_SUFFIX}";  \$7 = "1243024${NORME_SUFFIX}";  }
 else if (\$6 == "2143013${NORME_SUFFIX}") { \$6 = "2143014${NORME_SUFFIX}";  \$7 = "2243014${NORME_SUFFIX}";  }
 else if (\$6 == "2143020${NORME_SUFFIX}") { \$6 = "2143034${NORME_SUFFIX}";  \$7 = "2243034${NORME_SUFFIX}";  }
 else if (\$6 == "2143030${NORME_SUFFIX}") { \$6 = "2143024${NORME_SUFFIX}";  \$7 = "2243024${NORME_SUFFIX}";  }
print \$0;                                                                                                  
  }                                                                                                         
exit
EOF
AWK


##[006]
NSTEP=${NJOB}_30
# #[043] Creation d'un fichier AT INI avec TRNCOD INI
#-----------------------------------------------------------------------------
LIBEL="Transforme NDIC Assumed TRNCOD INI"
AWK_I="${DFILT}/${NJOB}_10_${IB}_SORT_NDIC_ASSUMED_INI.dat"
AWK_O="${DFILT}/${NSTEP}_${IB}_SORT_NDIC_INI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

      if (\$6 == "1143013${NORME_SUFFIX}") { \$6 = "1143011${NORME_SUFFIX}";  \$7 = "1243011${NORME_SUFFIX}";  }
 else if (\$6 == "1143020${NORME_SUFFIX}") { \$6 = "1143021${NORME_SUFFIX}";  \$7 = "1243021${NORME_SUFFIX}";  }
 else if (\$6 == "1143030${NORME_SUFFIX}") { \$6 = "1143031${NORME_SUFFIX}";  \$7 = "1243031${NORME_SUFFIX}";  }
 else if (\$6 == "2143013${NORME_SUFFIX}") { \$6 = "2143011${NORME_SUFFIX}";  \$7 = "2243011${NORME_SUFFIX}";  }
 else if (\$6 == "2143020${NORME_SUFFIX}") { \$6 = "2143021${NORME_SUFFIX}";  \$7 = "2243021${NORME_SUFFIX}";  }
 else if (\$6 == "2143030${NORME_SUFFIX}") { \$6 = "2143031${NORME_SUFFIX}";  \$7 = "2243031${NORME_SUFFIX}";  }
print \$0;                                                                                                  
  }                                                                                                         
exit
EOF
AWK

# [007]
NSTEP=${NJOB}_35
LIBEL="Merge NDIC INI and STD Futures Onerous and Dummy"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25_${IB}_SORT_NDIC_ONEFUT_DUMMY.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_30_${IB}_SORT_NDIC_INI.dat 2000 1"
SORT_O=${ESF_ACC_NDIC_INI}
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
	    CUR_CF           18:1 -  18:,
	    RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
	    RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT
/OUTFILE ${SORT_O} 
exit
EOF
SORT


NSTEP=${NJOB}_40
# #[043] Creation d'un fichier AT INI avec TRNCOD INI
#-----------------------------------------------------------------------------
LIBEL="Transforme NDIC Retro TRNCOD INI"
AWK_I="${DFILT}/${NJOB}_20_${IB}_SORT_NDIC_RETRO_INI.dat"
AWK_O="${DFILT}/${NSTEP}_${IB}_SORT_NDIC_RETRO_INI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

      if (\$6 == "2143013${NORME_SUFFIX}") { \$6 = "2143011${NORME_SUFFIX}";  \$7 = "2243011${NORME_SUFFIX}";    }
 else if (\$6 == "2143020${NORME_SUFFIX}") { \$6 = "2143021${NORME_SUFFIX}";  \$7 = "2243021${NORME_SUFFIX}";    }
 else if (\$6 == "2143030${NORME_SUFFIX}") { \$6 = "2143031${NORME_SUFFIX}";  \$7 = "2243031${NORME_SUFFIX}";    }
print \$0;
  }
exit
EOF
AWK

# [007]
NSTEP=${NJOB}_45
LIBEL="Transforme NDIC RETRO TRNCOD for Dummy"
AWK_I="${DFILT}/${NJOB}_21_${IB}_SORT_NDIC_RETRO_DUMMY.dat"
AWK_O="${DFILT}/${NSTEP}_${IB}_SORT_NDIC_RETRO_DUMMY.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

      if (\$6 == "2143013${NORME_SUFFIX}") { \$6 = "2143014${NORME_SUFFIX}";  \$7 = "2243014${NORME_SUFFIX}";  }
 else if (\$6 == "2143020${NORME_SUFFIX}") { \$6 = "2143034${NORME_SUFFIX}";  \$7 = "2243034${NORME_SUFFIX}";  }
 else if (\$6 == "2143030${NORME_SUFFIX}") { \$6 = "2143024${NORME_SUFFIX}";  \$7 = "2243024${NORME_SUFFIX}";  }
print \$0;
  }
exit
EOF
AWK

# [007]
NSTEP=${NJOB}_50
LIBEL="Merge NDIC Retro INI and STD Dummy"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_SORT_NDIC_RETRO_INI.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_45_${IB}_SORT_NDIC_RETRO_DUMMY.dat 2000 1"
SORT_O=${ESF_ACC_NDIC_RET_INI}
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
	    CUR_CF           18:1 -  18:,
	    RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
	    RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT
/OUTFILE ${SORT_O} 
exit
EOF
SORT
	

JOBEND

