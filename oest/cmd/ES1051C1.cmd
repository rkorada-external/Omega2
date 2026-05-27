#!/bin/ksh
#=============================================================================
# nom de l'application   :ESTC1051A.cmd 
#-----------------------------------------------------------------------------
# description
#   Optimisation ESTC1051A,  cd script remplace les steps qui utilise le programme ESTC1051A.exe
#
#-----------------------------------------------------------------------------
# historiques des modifications
#Create 03/01/2022 M.NAJI  SPIRA 101403 Optimisation du ESTC1051A
#===============================================================================
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[001] 22/09/2012 : JYP : SPIRA 106713 : I17P I17L rule for internal retro
#[002] 20/12/2022 : JYP : SPIRA 107106 : rework seg/lob rules
#===========================================================================
#set -x





ECHO_LOG "#==> EST_IRDPERICASE0 ......................:  $EST_IRDPERICASE0 "



NSTEP0=$NSTEP
LIBEL0=$LIBEL

NSTEP=${NSTEP0}_10
# filter FCURQUOT_TXT  (${BALSHTYEA_NF}) 
#-----------------------------------------------------------------------------
LIBEL="${EST_FCURQUOT_TXT}  ==> FCURQUOT_TXT_${BALSHTYEA_NF} "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCURQUOT_TXT}  1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FCURQUOT_TXT_${BALSHTYEA_NF}_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	CURQUOT_UWY_NF   3:1 -  3:
/CONDITION IS_BALSHTYEA ( CURQUOT_UWY_NF = "${BALSHTYEA_NF}" )
/OUTFILE   ${SORT_O} overwrite
/INCLUDE IS_BALSHTYEA
/COPY
exit
EOF
SORT

NSTEP=${NSTEP0}_20
# add rate of PCP to PERICASE
#-----------------------------------------------------------------------------
LIBEL="$TMP_PERICASE x FCURQUOT_TXT_${BALSHTYEA_NF} ==> PERICASE_PCPRATE "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${TMP_PERICASE} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:,
        UWY_NF           6:1 - 6:,
        PCPCUR_CF        51:1 - 51:,
        CURQUOT_SSD_CF   1:1 -  1:,
        CURQUOT_CUR_CF   2:1 -  2:,
        CURQUOT_UWY_NF   3:1 -  3:,
        CURQUOT_RATE     4:1 -  4:,
        all_cols         1:1  - 205:
/joinkeys
       SSD_CF
      ,PCPCUR_CF
/INFILE ${DFILT}/${NSTEP0}_10_${IB}_FCURQUOT_TXT_${BALSHTYEA_NF}_O.dat  1000 1 "~"
/joinkeys
        CURQUOT_SSD_CF
       ,CURQUOT_CUR_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE   ${DFILT}/${NSTEP}_${IB}_PERICASE_PCPRATE_O.dat
/REFORMAT
        leftside:all_cols
       ,rightside:CURQUOT_RATE
exit
EOF
SORT


NSTEP=${NSTEP0}_30
# add rate of EGP to PERICASE
#-----------------------------------------------------------------------------
LIBEL="$PERICASE_PCPRATE x FCURQUOT_TXT_${BALSHTYEA_NF} ==> PERICASE_PCPRATE_EGPRATE "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NSTEP0}_20_${IB}_PERICASE_PCPRATE_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:,
        UWY_NF           6:1 - 6:,
        PCPCUR_CF        51:1 - 51:,
        CURQUOT_SSD_CF   1:1 -  1:,
        CURQUOT_CUR_CF   2:1 -  2:,
        CURQUOT_UWY_NF   3:1 -  3:,
        CURQUOT_RATE     4:1 -  4:,
        all_cols         1:1  - 206:
/joinkeys
       SSD_CF
      ,PCPCUR_CF
/INFILE ${DFILT}/${NSTEP0}_10_${IB}_FCURQUOT_TXT_${BALSHTYEA_NF}_O.dat  1000 1 "~"
/joinkeys
        CURQUOT_SSD_CF
       ,CURQUOT_CUR_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE   ${DFILT}/${NSTEP}_${IB}_PERICASE_PCPRATE_EGPRATE_O.dat
/REFORMAT
        leftside:all_cols
       ,rightside:CURQUOT_RATE
exit
EOF
SORT

NSTEP=${NSTEP0}_40
# add RATE to GT
#-----------------------------------------------------------------------------
LIBEL="$GT x FCURQUOT_TXT_${BALSHTYEA_NF} ==> GT_RATE "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${TMP_GT} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS  SSD_CF           1:1 -  1:,
        UWY_NF          11:1 - 11:,
        CUR_CF          18:1 - 18:,
        CURQUOT_SSD_CF   1:1 -  1:,
        CURQUOT_CUR_CF   2:1 -  2:,
        CURQUOT_UWY_NF   3:1 -  3:,
        CURQUOT_RATE     4:1 -  4:,
        all_cols         1:1  - 63:
/joinkeys
		SSD_CF
        ,CUR_CF
/INFILE ${DFILT}/${NSTEP0}_10_${IB}_FCURQUOT_TXT_${BALSHTYEA_NF}_O.dat  1000 1 "~"
/joinkeys
        CURQUOT_SSD_CF
       ,CURQUOT_CUR_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE   ${DFILT}/${NSTEP}_${IB}_GT_RATE_O.dat
/REFORMAT
        leftside:all_cols
       ,rightside:CURQUOT_RATE
exit
EOF
SORT



NSTEP=${NSTEP0}_50
# add RETRATE to GT
#-----------------------------------------------------------------------------
LIBEL="$GT_RATE x FCURQUOT_TXT_${BALSHTYEA_NF} ==> GT_RATE_RETRATE "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NSTEP0}_40_${IB}_GT_RATE_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS  SSD_CF            1:1 -  1:,
        RTY_NF           27:1 - 27:,
        RETCUR_CF        34:1 - 34:,
        CURQUOT_SSD_CF   1:1 -  1:,
        CURQUOT_CUR_CF   2:1 -  2:,
        CURQUOT_UWY_NF   3:1 -  3:,
        CURQUOT_RATE     4:1 -  4:,
        all_cols         1:1  - 64:
/joinkeys
		 SSD_CF
           ,RETCUR_CF
/INFILE ${DFILT}/${NSTEP0}_10_${IB}_FCURQUOT_TXT_${BALSHTYEA_NF}_O.dat  2000 1 "~"
/joinkeys
        CURQUOT_SSD_CF
       ,CURQUOT_CUR_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE   ${DFILT}/${NSTEP}_${IB}_GT_RATE_RETRATE_O.dat
/REFORMAT
        leftside:all_cols
       ,rightside:CURQUOT_RATE
exit
EOF
SORT



NSTEP=${NJOB}_55
# add RETCTRCAT retro to GT file
#-----------------------------------------------------------------------------
LIBEL="add RETCTRCAT retro to GT, from $IRDPERICASE0  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NSTEP0}_50_${IB}_GT_RATE_RETRATE_O.dat  2000 1"
SORT_O="${DFILT}/${NSTEP0}_55_${IB}_GT_RATE_RETRATE_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
         PER_CTR_NF          3:1 -   3:
        ,PER_END_NT          4:1 -   4:
        ,PER_SEC_NF          5:1 -   5:
        ,PER_UWY_NF          6:1 -   6:
        ,PER_UW_NT           7:1 -   7:
        ,PER_CTRINC_D      19:1 -  19:	
        ,PER_RETCTRCAT_CF  107:1 - 107:
        ,GT_RETCTR_NF      24:1 -  24:
        ,GT_RETEND_NT      25:1 -  25:
        ,GT_RETSEC_NF      26:1 -  26:
        ,GT_RTY_NF         27:1 -  27:
        ,GT_RETUW_NT       28:1 -  28:
		,all_cols          1:1  - 65:
/joinkeys
         GT_RETCTR_NF
        ,GT_RETEND_NT
        ,GT_RETSEC_NF
        ,GT_RTY_NF
        ,GT_RETUW_NT
/INFILE ${EST_IRDPERICASE0} 2000 1 "~"
/joinkeys
         PER_CTR_NF
        ,PER_END_NT
        ,PER_SEC_NF
        ,PER_UWY_NF
        ,PER_UW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT
         leftside:all_cols
        ,rightside:PER_RETCTRCAT_CF
exit
EOF
SORT


NSTEP=${NSTEP0}_60
# SORT PERICASE 
#-----------------------------------------------------------------------------
LIBEL="${PERICASE_PCPRATE_EGPRATE}  ==> PERICASE_PCPRATE_EGPRATE_SORT "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NSTEP0}_30_${IB}_PERICASE_PCPRATE_EGPRATE_O.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PERICASE_PCPRATE_EGPRATE_SORT_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF    3:1 -  3:,
        END_NT    4:1 -  4:,
        SEC_NF    5:1 -  5:EN,
        UWY_NF    6:1 -  6:,
        UW_NT     7:1 -  7:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT


NSTEP=${NSTEP0}_70
if [ "${ACCRET_CT}" = "A" ] 
then


# sort GT ACCEPT
#-----------------------------------------------------------------------------
LIBEL="GT_RATE_RETRATE  ACCEPT ==> GT_RATE_RETRATE ACCEPT "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NSTEP0}_55_${IB}_GT_RATE_RETRATE_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${IB}_GT_RATE_RETRATE_SORT_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        PLC_NT           36:1 - 36:
/KEYS   CTR_NF
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
exit
EOF
SORT


else 

# sort GT RETRO
#-----------------------------------------------------------------------------
LIBEL="GT_RATE_RETRATE  RETRO ==> GT_RATE_RETRATE  RETRO "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NSTEP0}_55_${IB}_GT_RATE_RETRATE_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${IB}_GT_RATE_RETRATE_SORT_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        PLC_NT           36:1 - 36:
/KEYS    RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
       ,PLC_NT
       ,CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
       
exit
EOF
SORT

fi 







NSTEP=${NSTEP0}_80
#------------------------------------------------------------------------------
LIBEL=$LIBEL0
PRG=ESTC1051C
FPRM=`CFTMP`
export ${PRG}_PRM=${FPRM}
INPUT_TEXT ${FPRM} << EOF
ACCRET_CT ${ACCRET_CT}
BALSHTYEA_NF ${BALSHTYEA_NF}
PRS_CF ${PRS_CF} 
NORME_CF ${NORME_CF} 
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NSTEP0}_60_${IB}_PERICASE_PCPRATE_EGPRATE_SORT_O.dat 
export ${PRG}_I2=${DFILT}/${NSTEP0}_70_${IB}_${IB}_GT_RATE_RETRATE_SORT_O.dat
export ${PRG}_O1=${TMP_GTCUM_ACCRET}
export ${PRG}_O2=${TMP_GTCUM_ACCRET_ANO}
EXECPRG
