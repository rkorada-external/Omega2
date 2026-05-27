#!/bin/ksh
#=================================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD3891.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 20\08\2020
# auteur                        : Michael SEKBRAOUDINE
#---------------------------------------------------------------------------------
# description
#  IFRS17 REQ 11.9 - AOC- Experience Adjustement
#
#---------------------------------------------------------------------------------
# [01] 20/01/2021  M.NAJI : SPIRA 91531 remplacer ICLADAT_D par PARM_ICLODAT_D
# [02] 29/03/2021: MZM :    SPIRA 92612 : Impact REQ11.9 macro AOC Ajout du fichier ESF_DLSGTAA
# [03] 01/07/2021  MiS    : SPIRA 92612 : Ajout fichier ESF_FTECLEDA_OPNG et ESF_FTECLEDA_REJ
# [04] 19/08/2021  NLD    : SPIRA 98285 : I17G- Transaction with strange TC 99999119, remove it
# [05] 03/11/2021  MiS    : SPIRA 99266 : REQ 11.09 - IFRS 17 - Change in the rule of first closing for macro AoC
# [06] 15/12/2021  Dad    : SPIRA 100138 : File ESF_DLSGTAA is excluded
#=================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT
 
# Get input parameters

ECHO_LOG "#========================================================================="
ECHO_LOG "#===> PARM_ICLODAT_D....................................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> CLOTYP.......................................................: ${TYPEINV}"
ECHO_LOG "#===> NORME_CF.....................................................: ${NORME_CF}"
ECHO_LOG "#===> BATCHUSER....................................................: ${PARM0_BATCHUSER}"

ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> EST_IADPERICASE_STD..........................................: ${EST_IADPERICASE_STD}"
ECHO_LOG "#===> EST_IADPERICASE_INI..........................................: ${EST_IADPERICASE_INI}"
ECHO_LOG "#===> ESF_FTECLEDA.................................................: ${ESF_FTECLEDA}"
ECHO_LOG "#===> EST_FCURQUOT.................................................: ${EST_FCURQUOT}"
ECHO_LOG "#===> EST_FTECLEDA.................................................: ${EST_FTECLEDA}"
ECHO_LOG "#===> EST_FSEGEST..................................................: ${EST_FSEGEST}"
ECHO_LOG "#===> ESF_FRARAT...................................................: ${ESF_FRARAT}"
ECHO_LOG "#===> ESF_FTECLEDR.................................................: ${ESF_FTECLEDR}"
ECHO_LOG "#===> ESF_FEXPRAT..................................................: ${ESF_FEXPRAT}"
ECHO_LOG "#===> EPO_FBOPRSLNK................................................: ${EPO_FBOPRSLNK}"
ECHO_LOG "#===> EPO_FULTIMATES...............................................: ${EPO_FULTIMATES}"
ECHO_LOG "#===> ESF_FMARKET..................................................: ${ESF_FMARKET}"
# ECHO_LOG "#===> ESF_DLSGTAA..................................................: ${ESF_DLSGTAA}"
ECHO_LOG "#===> ESF_FTECLEDA_OPNG............................................: ${ESF_FTECLEDA_OPNG}"
ECHO_LOG "#===> ESF_FTECLEDA_REJ.............................................: ${ESF_FTECLEDA_REJ}"

ECHO_LOG "#===> ............ OUTPUT ................................................"
ECHO_LOG "#===> ESF_FTECLEDA_AOC.............................................: ${ESF_FTECLEDA_AOC}"
ECHO_LOG "#========================================================================="




# if [ ! -f ${ESF_DLSGTAA} ]
# then
# 	touch ${ESF_DLSGTAA}
# fi

if [ ! -f ${ESF_FTECLEDA_OPNG} ]
then
        touch ${ESF_FTECLEDA_OPNG}
fi

if [ ! -f ${ESF_FTECLEDA_REJ} ]
then
        touch ${ESF_FTECLEDA_REJ}
fi

NSTEP=${NJOB}_00
#------------------------------------------------------------------------------
# sort of the ${DLCUMGTAAR_MVT} file
#------------------------------------------------------------------------------
LIBEL="Sort of $DLCUMGTAAR_MVT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DLCUMGTAAR_MVT} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DLCUMGTAAR_MVT.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF    8:1  -  8:,
        END_NT    9:1  -  9:,
        SEC_NF    10:1 -  10:EN,
        UWY_NF    11:1 -  11:,
        UW_NT     12:1 -  12:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT

# [02] [03] [06]
NSTEP=${NJOB}_01
#------------------------------------------------------------------------------
# sort of the merge ${ESF_FTECLEDA}, ${ESF_DLSGTAA}, ${ESF_FTECLEDA_OPNG} and ${ESF_FTECLEDA_REJ} files
#------------------------------------------------------------------------------
LIBEL="Sort of $ESF_FTECLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA} 2000 1"
# SORT_I2="${ESF_DLSGTAA} 2000 1"
SORT_I2="${ESF_FTECLEDA_OPNG} 2000 1" 
SORT_I3="${ESF_FTECLEDA_REJ} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SII_GLT_STD_FTECLEDA_${PARM_ICLODAT_D}.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF    8:1  -  8:,
        END_NT    9:1  -  9:,
        SEC_NF    10:1 -  10:EN,
        UWY_NF    11:1 -  11:,
        UW_NT     12:1 -  12:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_03
#------------------------------------------------------------------------------
# sort of the ${ESF_FRARAT} file
#------------------------------------------------------------------------------
LIBEL="Sort of $ESF_FRARAT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FRARAT} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FRARAT_SORT.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF    	1:1  -  1:EN,
        ESB_CF    	2:1  -  2:EN,
        SEG_NF    	9:1  -  9:,
        CTRNAT_CT    	5:1  -  5:,
        DOMAIN_CF     	6:1  -  6:
/KEYS   SSD_CF,
        ESB_CF,
        SEG_NF,
        CTRNAT_CT,
        DOMAIN_CF
exit
EOF
SORT

NSTEP=${NJOB}_04
#------------------------------------------------------------------------------
# sort of the ${ESF_FEXPRAT} file
#------------------------------------------------------------------------------
LIBEL="Sort of $ESF_FEXPRAT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FEXPRAT} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FEXPRAT_SORT.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF    	1:1  -  1:EN,
        ESB_CF    	2:1  -  2:EN,
        PLBL_CF    	5:1  -  5:EN,
        CTRNAT_CT	7:1  -  7:
/KEYS   SSD_CF,
        ESB_CF,
        PLBL_CF,
        CTRNAT_CT
exit
EOF
SORT

NSTEP=${NJOB}_07
#------------------------------------------------------------------------------
# sort of the ${ESF_FMARKET} file
#------------------------------------------------------------------------------
LIBEL="Sort of $ESF_FMARKET"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FMARKET} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FMARKET_SORT.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF    1:1  -  1:,
        END_NT    2:1  -  2:,
        SEC_NF    3:1  -  3:EN,
        UWY_NF    4:1  -  4:,
        UW_NT     5:1  -  5:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_08
#------------------------------------------------------------------------------
# sort of the ${EST_IADPERICASE_STD} file
#------------------------------------------------------------------------------
LIBEL="Sort of $EST_IADPERICASE_STD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE_STD} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE_STD.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF    3:1  -  3:,
        END_NT    4:1  -  4:,
        SEC_NF    5:1  -  5:EN,
        UWY_NF    6:1  -  6:,
        UW_NT     7:1  -  7:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT

# [05]
NSTEP=${NJOB}_09
#------------------------------------------------------------------------------
# sort of the ${ESF_TRERETFACCTR} file
#------------------------------------------------------------------------------
LIBEL="Sort of $ESF_TRERETFACCTR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_TRERETFACCTR} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_TRERETFACCTR_SORT.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF    1:1  -  1:,
        END_NT    2:1  -  2:,
        SEC_NF    3:1  -  3:EN,
        UWY_NF    4:1  -  4:,
        UW_NT     5:1  -  5:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_10
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Computing MaoC"
PRG=ESFC3890
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
NORME		${NORME_CF}
CLODAT		${PARM_ICLODAT_D}
TYPEINV 	${TYPEINV}
PREV_ICLODAT	${PARM_PREV_ICLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_08_${IB}_IADPERICASE_STD.dat
export ${PRG}_I2=${DFILT}/${NJOB}_01_${IB}_SII_GLT_STD_FTECLEDA_${PARM_ICLODAT_D}.dat
export ${PRG}_I3=${EST_FCURQUOT}
export ${PRG}_I4=${DFILT}/${NJOB}_00_${IB}_DLCUMGTAAR_MVT.dat
export ${PRG}_I5=${ESF_FTECLEDR}
export ${PRG}_I6=${EST_FSEGEST}
export ${PRG}_I7=${DFILT}/${NJOB}_03_${IB}_FRARAT_SORT.dat
export ${PRG}_I8=${DFILT}/${NJOB}_04_${IB}_FEXPRAT_SORT.dat
export ${PRG}_I9=${EPO_FBOPRSLNK}
export ${PRG}_I10=${EPO_FULTIMATES}
export ${PRG}_I11=${DFILT}/${NJOB}_07_${IB}_FMARKET_SORT.dat
export ${PRG}_I12=${DFILT}/${NJOB}_09_${IB}_TRERETFACCTR_SORT.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_GT_AOC_STD_${PRG}.dat
EXECPRG

NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
# Merge and sort of the Acceptance file
#------------------------------------------------------------------------------
LIBEL="Sort and Merge of Output Files to format TTCLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_GT_AOC_STD_${PRG}.dat 2000 1"
SORT_O="${ESF_FTECLEDA_AOC}  2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:EN,
        BALSHEY_NF       3:1 -  3: EN,
        BALSHRMTH_NF     4:1 -  4: EN,
        TRNCOD1_CF       6:1 -  6:1,
	TRNCOD_CF	 6:1 -  6:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        CUR_CF          18:1 -  18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        PLC_NT          36:1 - 36:EN,
        SEGNAT_CT       48:1 - 48:,
        ACCRET_CF       49:1 - 49:,
        LIGNEGT          1:1 - 39:,
        RETKEY_CF       40:1 - 40:,
        RETINTAMT_M     41:1 - 41:,
        SEG_NF          46:1 - 46:,
        FILLER_30_COLS  42:1 - 71:
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
        CUR_CF,
        SEG_NF
/CONDITION COND_GTAA0 ( TRNCOD1_CF eq "1" )
/CONDITION TRANS_9999 ( TRNCOD_CF eq "99999119")
/DERIVEDFIELD DATTRAIT "${CRE_D}~"
/DERIVEDFIELD USER "CloP~"
/DERIVEDFIELD SEPARATEUR44  43"~"
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT LIGNEGT,
          RETKEY_CF,
          DATTRAIT,
          USER,
          DATTRAIT,
          USER,
          SEPARATEUR44,
          RETINTAMT_MC,
          FILLER_30_COLS
/OMIT TRANS_9999
exit
EOF
SORT


NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
LIBEL="Erase temporary files"
#RMFIL "${DFILT}/${NJOB}*${IB}*.dat "

JOBEND
