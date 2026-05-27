#!/bin/ksh
#=============================================================================
# nom de l'application          : I17G -APP4 (TL and cashflow data aggregation)
# nom du script SHELL           : ESFD4041.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 10\03\2021
# auteur                        : Charles SOCIE
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  TI17CTRINFO update table
#
#-----------------------------------------------------------------------------
# modification
# [001] ART 19/08/2021 Spira 94417 replace the 3 obsoletes CSM/LC pattern Group/Parent/Local by the CSM/LC pattern EBS
# [002] DAD 02/11/2023 Spira 110436 remove RETUW_NT from joinkeys for Ratio Retro NP
#
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT


ECHO_LOG "#========================================================================="
ECHO_LOG "#===> NORME_CF....................................: ${NORME_CF}"
ECHO_LOG "#===> CONTEXT_CT..................................: ${CONTEXT_CT}"
ECHO_LOG "#===> TYPEINV.....................................: ${TYPEINV}"
ECHO_LOG "#===> ............ INPUT ..........................................."
ECHO_LOG "#===> ESF_CSM_LC_AMORT_PATTERN_EBS...............: ${ESF_CSM_LC_AMORT_PATTERN_EBS}"
ECHO_LOG "#===> EST_FLAG_ANN_LMT_I17G.......................: ${EST_FLAG_ANN_LMT_I17G}"
ECHO_LOG "#===> EST_FLAG_ANN_LMT_I17P.......................: ${EST_FLAG_ANN_LMT_I17P}"
ECHO_LOG "#===> EST_FLAG_ANN_LMT_I17L.......................: ${EST_FLAG_ANN_LMT_I17L}"
ECHO_LOG "#===> ESF_FLORETFACTOR_INI_I17G...................: ${ESF_FLORETFACTOR_INI_I17G}"
ECHO_LOG "#===> ESF_FLORETFACTOR_INI_I17P...................: ${ESF_FLORETFACTOR_INI_I17P}"
ECHO_LOG "#===> ESF_FLORETFACTOR_INI_I17L...................: ${ESF_FLORETFACTOR_INI_I17L}"
ECHO_LOG "#===> ESF_FLORETFACTOR_STD........................: ${ESF_FLORETFACTOR_STD}"
ECHO_LOG "#===> EST_IADPERICASE_INI_I17G....................: ${EST_IADPERICASE_INI_I17G}"
ECHO_LOG "#===> EST_IADPERICASE_INI_I17P....................: ${EST_IADPERICASE_INI_I17P}"
ECHO_LOG "#===> EST_IADPERICASE_INI_I17L....................: ${EST_IADPERICASE_INI_I17L}"
ECHO_LOG "#===> EST_IADPERICASE_STD_I17G....................: ${EST_IADPERICASE_STD_I17G}"
ECHO_LOG "#===> EST_IADPERICASE_STD_I17P....................: ${EST_IADPERICASE_STD_I17P}"
ECHO_LOG "#===> EST_IADPERICASE_STD_I17L....................: ${EST_IADPERICASE_STD_I17L}"
ECHO_LOG "#===> EST_IRDPERICASE0............................: ${EST_IRDPERICASE0}"
ECHO_LOG "#===> EST_RATIO_I17G_ASSUMED......................: ${EST_RATIO_I17G_ASSUMED}"
ECHO_LOG "#===> EST_RATIO_I17P_ASSUMED......................: ${EST_RATIO_I17P_ASSUMED}"
ECHO_LOG "#===> EST_RATIO_I17L_ASSUMED......................: ${EST_RATIO_I17L_ASSUMED}"
ECHO_LOG "#===> EST_RATIO_I17G_RETRO_NP.....................: ${EST_RATIO_I17G_RETRO_NP}"
ECHO_LOG "#===> EST_RATIO_I17P_RETRO_NP.....................: ${EST_RATIO_I17P_RETRO_NP}"
ECHO_LOG "#===> EST_RATIO_I17L_RETRO_NP.....................: ${EST_RATIO_I17L_RETRO_NP}"
ECHO_LOG "#===> EST_RATIO_I17G_RETRO_P......................: ${EST_RATIO_I17G_RETRO_P}"
ECHO_LOG "#===> EST_RATIO_I17P_RETRO_P......................: ${EST_RATIO_I17P_RETRO_P}"
ECHO_LOG "#===> EST_RATIO_I17L_RETRO_P......................: ${EST_RATIO_I17L_RETRO_P}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_01
#------------------------------------------------------------------------------------
LIBEL="MANAGE UNFOUND FILES "

if [ ! -f ${EST_IADPERICASE_INI_I17G} ]
then
	ECHO_LOG "EST_IADPERICASE_INI_I17G=${EST_IADPERICASE_INI_I17G} does not exist, take an empty file" >> $FLOG
    EXECKSH "touch ${EST_IADPERICASE_INI_I17G}"
fi
if [ ! -f ${EST_IADPERICASE_INI_I17P} ]
then
	ECHO_LOG "EST_IADPERICASE_INI_I17P=${EST_IADPERICASE_INI_I17P} does not exist, take an empty file" >> $FLOG
    EXECKSH "touch ${EST_IADPERICASE_INI_I17P}"
fi
if [ ! -f ${EST_IADPERICASE_INI_I17L} ]
then
	ECHO_LOG "EST_IADPERICASE_INI_I17L=${EST_IADPERICASE_INI_I17L} does not exist, take an empty file" >> $FLOG
    EXECKSH "touch ${EST_IADPERICASE_INI_I17L}"
fi

if [ ! -f ${ESF_CSM_LC_AMORT_PATTERN_EBS} ]
then
	ECHO_LOG "ESF_CSM_LC_AMORT_PATTERN_EBS=${ESF_CSM_LC_AMORT_PATTERN_EBS} does not exist, take an empty file" >> $FLOG
    EXECKSH "touch ${ESF_CSM_LC_AMORT_PATTERN_EBS}"
fi

if [ ! -f ${EST_FLAG_ANN_LMT_I17G} ]
then
	ECHO_LOG "EST_FLAG_ANN_LMT_I17G=${EST_FLAG_ANN_LMT_I17G} does not exist, take an empty file" >> $FLOG
    EXECKSH "touch ${EST_FLAG_ANN_LMT_I17G}"
fi
if [ ! -f ${EST_FLAG_ANN_LMT_I17P} ]
then
	ECHO_LOG "EST_FLAG_ANN_LMT_I17P=${EST_FLAG_ANN_LMT_I17P} does not exist, take an empty file" >> $FLOG
    EXECKSH "touch ${EST_FLAG_ANN_LMT_I17P}"
fi
if [ ! -f ${EST_FLAG_ANN_LMT_I17L} ]
then
	ECHO_LOG "EST_FLAG_ANN_LMT_I17L=${EST_FLAG_ANN_LMT_I17L} does not exist, take an empty file" >> $FLOG
    EXECKSH "touch ${EST_FLAG_ANN_LMT_I17L}"
fi

if [ ! -f ${ESF_FLORETFACTOR_INI_I17G} ]
then
	ECHO_LOG "ESF_FLORETFACTOR_INI_I17G=${ESF_FLORETFACTOR_INI_I17G} does not exist, take an empty file" >> $FLOG
    EXECKSH "touch ${ESF_FLORETFACTOR_INI_I17G}"
fi
if [ ! -f ${ESF_FLORETFACTOR_INI_I17P} ]
then
	ECHO_LOG "ESF_FLORETFACTOR_INI_I17P=${ESF_FLORETFACTOR_INI_I17P} does not exist, take an empty file" >> $FLOG
    EXECKSH "touch ${ESF_FLORETFACTOR_INI_I17P}"
fi
if [ ! -f ${ESF_FLORETFACTOR_INI_I17L} ]
then
	ECHO_LOG "ESF_FLORETFACTOR_INI_I17L=${ESF_FLORETFACTOR_INI_I17L} does not exist, take an empty file" >> $FLOG
    EXECKSH "touch ${ESF_FLORETFACTOR_INI_I17L}"
fi
if [ ! -f ${ESF_FLORETFACTOR_STD} ]
then
	ECHO_LOG "ESF_FLORETFACTOR_STD=${ESF_FLORETFACTOR_STD} does not exist, take an empty file" >> $FLOG
    EXECKSH "touch ${ESF_FLORETFACTOR_STD}"
fi

if [ ! -f ${EST_IADPERICASE_STD_I17G} ]
then
	ECHO_LOG "EST_IADPERICASE_STD_I17G=${EST_IADPERICASE_STD_I17G} does not exist, take an empty file" >> $FLOG
    EXECKSH "touch ${EST_IADPERICASE_STD_I17G}"
fi

if [ ! -f ${EST_IADPERICASE_STD_I17P} ]
then
	ECHO_LOG "EST_IADPERICASE_STD_I17P=${EST_IADPERICASE_STD_I17P} does not exist, take an empty file" >> $FLOG
    EXECKSH "touch ${EST_IADPERICASE_STD_I17P}"
fi

if [ ! -f ${EST_IADPERICASE_STD_I17L} ]
then
	ECHO_LOG "EST_IADPERICASE_STD_I17L=${EST_IADPERICASE_STD_I17L} does not exist, take an empty file" >> $FLOG
    EXECKSH "touch ${EST_IADPERICASE_STD_I17L}"
fi

if [ ! -f ${EST_IRDPERICASE0} ]
then
	ECHO_LOG "EST_IRDPERICASE0=${EST_IRDPERICASE0} does not exist, take an empty file" >> $FLOG
    EXECKSH "touch ${EST_IRDPERICASE0}"
fi

if [ ! -f ${EST_RATIO_I17G_ASSUMED} ]
then
	ECHO_LOG "EST_RATIO_I17G_ASSUMED=${EST_RATIO_I17G_ASSUMED} does not exist, take an empty file" >> $FLOG
    EXECKSH "touch ${EST_RATIO_I17G_ASSUMED}"
fi

if [ ! -f ${EST_RATIO_I17P_ASSUMED} ]
then
	ECHO_LOG "EST_RATIO_I17P_ASSUMED=${EST_RATIO_I17P_ASSUMED} does not exist, take an empty file" >> $FLOG
    EXECKSH "touch ${EST_RATIO_I17P_ASSUMED}"
fi

if [ ! -f ${EST_RATIO_I17L_ASSUMED} ]
then
	ECHO_LOG "EST_RATIO_I17L_ASSUMED=${EST_RATIO_I17L_ASSUMED} does not exist, take an empty file" >> $FLOG
    EXECKSH "touch ${EST_RATIO_I17L_ASSUMED}"
fi

if [ ! -f ${EST_RATIO_I17G_RETRO_NP} ]
then
	ECHO_LOG "EST_RATIO_I17G_RETRO_NP=${EST_RATIO_I17G_RETRO_NP} does not exist, take an empty file" >> $FLOG
    EXECKSH "touch ${EST_RATIO_I17G_RETRO_NP}"
fi

if [ ! -f ${EST_RATIO_I17P_RETRO_NP} ]
then
	ECHO_LOG "EST_RATIO_I17P_RETRO_NP=${EST_RATIO_I17P_RETRO_NP} does not exist, take an empty file" >> $FLOG
    EXECKSH "touch ${EST_RATIO_I17P_RETRO_NP}"
fi

if [ ! -f ${EST_RATIO_I17L_RETRO_NP} ]
then
	ECHO_LOG "EST_RATIO_I17L_RETRO_NP=${EST_RATIO_I17L_RETRO_NP} does not exist, take an empty file" >> $FLOG
    EXECKSH "touch ${EST_RATIO_I17L_RETRO_NP}"
fi

if [ ! -f ${EST_RATIO_I17G_RETRO_P} ]
then
	ECHO_LOG "EST_RATIO_I17G_RETRO_P=${EST_RATIO_I17G_RETRO_P} does not exist, take an empty file" >> $FLOG
    EXECKSH "touch ${EST_RATIO_I17G_RETRO_P}"
fi

if [ ! -f ${EST_RATIO_I17P_RETRO_P} ]
then
	ECHO_LOG "EST_RATIO_I17P_RETRO_P=${EST_RATIO_I17P_RETRO_P} does not exist, take an empty file" >> $FLOG
    EXECKSH "touch ${EST_RATIO_I17P_RETRO_P}"
fi

if [ ! -f ${EST_RATIO_I17L_RETRO_P} ]
then
	ECHO_LOG "EST_RATIO_I17L_RETRO_P=${EST_RATIO_I17L_RETRO_P} does not exist, take an empty file" >> $FLOG
    EXECKSH "touch ${EST_RATIO_I17L_RETRO_P}"
fi

NSTEP=${NJOB}_05
#------------------------------------------------------------------------------------
LIBEL="Merge all pericase assumed file and reformat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE_INI_I17G} 2000 1"
SORT_I2="${EST_IADPERICASE_INI_I17P} 2000 1"
SORT_I3="${EST_IADPERICASE_INI_I17L} 2000 1"
SORT_I4="${EST_IADPERICASE_STD_I17G} 2000 1"
SORT_I5="${EST_IADPERICASE_STD_I17P} 2000 1"
SORT_I6="${EST_IADPERICASE_STD_I17L} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_MERGE_PERICASE_ASSUMED.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	SSD_CF			1:1 	- 1:,
	SEGTYP_CT		2:1 	- 2:,
	CTR_NF			3:1 	- 3:,
	END_NT			4:1 	- 4:,
	SEC_NF			5:1 	- 5:,
	UWY_NF			6:1 	- 6:,
	UW_NT			7:1 	- 7:,
	FILLER			8:1		- 256:
/KEYS	
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT
/DERIVEDFIELD PLUS_7_CHAMPS "~~~~~~"
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT 
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	PLUS_7_CHAMPS
exit
EOF
SORT


NSTEP=${NJOB}_15
#------------------------------------------------------------------------------------
LIBEL="Merge all FLAG annual limit file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FLAG_ANN_LMT_I17G} 2000 1"
SORT_I2="${EST_FLAG_ANN_LMT_I17P} 2000 1"
SORT_I3="${EST_FLAG_ANN_LMT_I17L} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_MERGE_EST_FLAG_ANN_LMT.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CTR_NF			1:1 	- 1:,
	SEC_NF			2:1 	- 2:,
	UWY_NF			3:1 	- 3:,
	UW_NT			4:1 	- 4:,
	END_NT			5:1		- 5:
/KEYS	
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT,
	END_NT
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT

NSTEP=${NJOB}_17
#------------------------------------------------------------------------------------
LIBEL="Merge all RATIO file ASSUMED"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_RATIO_I17G_ASSUMED} 2000 1"
SORT_I2="${EST_RATIO_I17P_ASSUMED} 2000 1"
SORT_I3="${EST_RATIO_I17L_ASSUMED} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_MERGE_EST_RATIO_ASSUMED.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CTR_NF			1:1 	- 1:,
	SEC_NF			2:1 	- 2:,
	UWY_NF			3:1 	- 3:,
	UW_NT			4:1 	- 4:,
	END_NT			5:1		- 5:
/KEYS	
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT,
	END_NT
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT


NSTEP=${NJOB}_20
#---------------------------------------------------------------------------
LIBEL="Extend Merge pericase with CSM pattern et LC patter columns for Assumed"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_MERGE_PERICASE_ASSUMED.dat 2000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_MERGE_PERICASE_EXTEND_CSM_LC_PATTERN_ASSUMED.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	CTR_NF          1:1 	- 1:,
	SEC_NF          3:1 	- 3:,
	UWY_NF          4:1 	- 4:,
	UW_NT           5:1 	- 5:,
	FILLER          1:1  	- 12:,
	CSM_CTR_NF      1:1 	- 1:,
	CSM_SEC_NF      2:1 	- 2:,
	CSM_UWY_NF      3:1 	- 3:,
	CSM_UW_NT       4:1 	- 4:,
	LC_PATTERN		7:1		- 7:,
	CSM_PATTERN		8:1		- 8:
/JOINKEYS
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT
/INFILE ${ESF_CSM_LC_AMORT_PATTERN_EBS} 2000 1 "~"
/JOINKEYS
	CSM_CTR_NF,
	CSM_SEC_NF,
	CSM_UWY_NF,
	CSM_UW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE  ${SORT_O}
/REFORMAT   
	LEFTSIDE:FILLER,
	RIGHTSIDE:LC_PATTERN,
	RIGHTSIDE:CSM_PATTERN
exit
EOF
SORT



NSTEP=${NJOB}_25
#---------------------------------------------------------------------------
LIBEL="Extend Merge pericase with FLAG columns for Assumed"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_MERGE_PERICASE_EXTEND_CSM_LC_PATTERN_ASSUMED.dat 2000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_MERGE_PERICASE_EXTEND_CSM_LC_PATTERN_FLAG_ASSUMED.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	CTR_NF          1:1 	- 1:,
	END_NT			2:1 	- 2:,
	SEC_NF          3:1 	- 3:,
	UWY_NF          4:1 	- 4:,
	UW_NT           5:1 	- 5:,
	FILLER          1:1  	- 14:,
	FLAG_CTR_NF     1:1 	- 1:,
	FLAG_SEC_NF     2:1 	- 2:,
	FLAG_UWY_NF     3:1 	- 3:,
	FLAG_UW_NT      4:1 	- 4:,
	FLAG_END_NT     5:1 	- 5:,
	FLAG		    6:1		- 6:
/JOINKEYS
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT, 
	END_NT
/INFILE "${DFILT}/${NJOB}_15_${IB}_MERGE_EST_FLAG_ANN_LMT.dat" 2000 1 "~"
/JOINKEYS
	FLAG_CTR_NF,
	FLAG_SEC_NF,
	FLAG_UWY_NF,
	FLAG_UW_NT,
	FLAG_END_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE  ${SORT_O}
/REFORMAT   
	LEFTSIDE:FILLER,
	RIGHTSIDE:FLAG
exit
EOF
SORT

NSTEP=${NJOB}_27
#---------------------------------------------------------------------------
LIBEL="Extend Merge pericase with RATIO columns for Assumed"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25_${IB}_MERGE_PERICASE_EXTEND_CSM_LC_PATTERN_FLAG_ASSUMED.dat 2000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_MERGE_PERICASE_EXTEND_CSM_LC_PATTERN_FLAG_RATIO_ASSUMED.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	CTR_NF          1:1 	- 1:,
	END_NT			2:1 	- 2:,
	SEC_NF          3:1 	- 3:,
	UWY_NF          4:1 	- 4:,
	UW_NT           5:1 	- 5:,
	FILLER          1:1  	- 15:,
	RATIO_CTR_NF     1:1 	- 1:,
	RATIO_END_NT     2:1 	- 2:,
	RATIO_SEC_NF     3:1 	- 3:,
	RATIO_UWY_NF     4:1 	- 4:,
	RATIO_UW_NT      5:1 	- 5:,
	RATIO_EGPI_R1    6:1	- 6:,
	RATIO_EGPI_R2    7:1	- 7:,
	RATIO_EARP_R1    8:1	- 8:
/JOINKEYS
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT, 
	END_NT
/INFILE "${DFILT}/${NJOB}_17_${IB}_MERGE_EST_RATIO_ASSUMED.dat" 2000 1 "~"
/JOINKEYS
	RATIO_CTR_NF,
	RATIO_SEC_NF,
	RATIO_UWY_NF,
	RATIO_UW_NT,
	RATIO_END_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE  ${SORT_O}
/REFORMAT   
	LEFTSIDE:FILLER,
	RIGHTSIDE:RATIO_EGPI_R1,RATIO_EGPI_R2,RATIO_EARP_R1
exit
EOF
SORT


NSTEP=${NJOB}_30
#---------------------------------------------------------------------------
LIBEL="Extend pericase retro with CSM pattern et LC patter columns for Retro"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDPERICASE0} 2000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_PERICASE_EXTEND_RETRO.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	RETCTR_NF       3:1 	- 3:,
	RETEND_NT       4:1 	- 4:,
	RETSEC_NF       5:1 	- 5:,
	RTY_NF       	6:1 	- 6:,
	RETUW_NT        7:1 	- 7:,
	FILLER          3:1  	- 7:,
	CTR_NF          1:1 	- 1:,
	SEC_NF          2:1 	- 2:,
	UWY_NF          3:1 	- 3:,
	UW_NT           4:1 	- 4:,
	LC_PATTERN		7:1		- 7:,
	CSM_PATTERN		8:1		- 8:
/JOINKEYS
	RETCTR_NF,
	RETSEC_NF,
	RTY_NF,
	RETUW_NT
/INFILE "${ESF_CSM_LC_AMORT_PATTERN_EBS}" 2000 1 "~"
/JOINKEYS
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT
/JOIN UNPAIRED LEFTSIDE
/DERIVEDFIELD PLUS_5_CHAMPS "~~~~~"
/DERIVEDFIELD PLUS_2_CHAMPS "~~"
/DERIVEDFIELD PLUS_1_CHAMPS ""
/OUTFILE  ${SORT_O}
/REFORMAT   
	LEFTSIDE:PLUS_5_CHAMPS,
	LEFTSIDE:FILLER,
	LEFTSIDE:PLUS_2_CHAMPS,
	RIGHTSIDE:LC_PATTERN,
	RIGHTSIDE:CSM_PATTERN,
	RIGHTSIDE:PLUS_1_CHAMPS
exit
EOF
SORT


NSTEP=${NJOB}_31
#------------------------------------------------------------------------------------
LIBEL="Merge all RATIO file RETRO NP"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_RATIO_I17G_RETRO_NP} 2000 1"
SORT_I2="${EST_RATIO_I17P_RETRO_NP} 2000 1"
SORT_I3="${EST_RATIO_I17L_RETRO_NP} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_MERGE_EST_RATIO_RETRO_NP.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	RETCTR_NF			1:1 	- 1:,
	RETEND_NT			2:1		- 2:,
	RETSEC_NF			3:1 	- 3:,
	RTY_NF				4:1 	- 4:,
	RETUW_NT			5:1 	- 5:
/KEYS	
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF,
	RETUW_NT
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT

# [002]
NSTEP=${NJOB}_32
#---------------------------------------------------------------------------
LIBEL="Extend pericase retro with RATIO columns for Retro"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_PERICASE_EXTEND_RETRO.dat 2000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_PERICASE_EXTEND_RETRO_RATIO.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	RETCTR_NF       6:1 	- 6:,
	RETEND_NT       7:1 	- 7:,
	RETSEC_NF       8:1 	- 8:,
	RTY_NF       	9:1 	- 9:,
	RETUW_NT        10:1 	- 10:,
	FILLER          1:1  	- 15:,
	CTR_NF          1:1 	- 1:,
	END_NT       	2:1 	- 2:,
	SEC_NF          3:1 	- 3:,
	UWY_NF          4:1 	- 4:,
	UW_NT           5:1 	- 5:,
	RATIO_EGPI_R1    7:1	- 7:,
	RATIO_EGPI_R2    8:1	- 8:,
	RATIO_EARP_R1    9:1	- 9:
/JOINKEYS
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF
/INFILE "${DFILT}/${NJOB}_31_${IB}_MERGE_EST_RATIO_RETRO_NP.dat" 2000 1 "~"
/JOINKEYS
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE  ${SORT_O}
/REFORMAT   
	LEFTSIDE:FILLER,
	RIGHTSIDE:RATIO_EGPI_R1,
	RIGHTSIDE:RATIO_EGPI_R2,
	RIGHTSIDE:RATIO_EARP_R1
exit
EOF
SORT

NSTEP=${NJOB}_35
#------------------------------------------------------------------------------------
LIBEL="Merge all ESF_FLORETFACTOR INI and STD and reformat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FLORETFACTOR_INI_I17G} 2000 1"
SORT_I2="${ESF_FLORETFACTOR_INI_I17P} 2000 1"
SORT_I3="${ESF_FLORETFACTOR_INI_I17L} 2000 1"
SORT_I4="${ESF_FLORETFACTOR_STD} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_MERGE_ESF_FLORETFACTOR_INI_STD.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CTR_NF			1:1 	- 1:,
	END_NT			2:1 	- 2:,
	SEC_NF			3:1 	- 3:,
	UWY_NF			4:1 	- 4:,
	UW_NT			5:1 	- 5:,
	RETCTR_NF		6:1 	- 6:,
	RETEND_NT		7:1 	- 7:,
	RETSEC_NF		8:1 	- 8:,
	RTY_NF			9:1 	- 9:,
	RETUW_NT		10:1 	- 10:
/KEYS	
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
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT 
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
exit
EOF
SORT

NSTEP=${NJOB}_40
#------------------------------------------------------------------------------------
LIBEL="Merge all ESF_FLORETFACTOR INI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FLORETFACTOR_INI_I17G} 2000 1"
SORT_I2="${ESF_FLORETFACTOR_INI_I17P} 2000 1"
SORT_I3="${ESF_FLORETFACTOR_INI_I17L} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_MERGE_ESF_FLORETFACTOR_INI.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CTR_NF			1:1 	- 1:,
	END_NT			2:1 	- 2:,
	SEC_NF			3:1 	- 3:,
	UWY_NF			4:1 	- 4:,
	UW_NT			5:1 	- 5:,
	RETCTR_NF		6:1 	- 6:,
	RETEND_NT		7:1 	- 7:,
	RETSEC_NF		8:1 	- 8:,
	RTY_NF			9:1 	- 9:,
	RETUW_NT		10:1 	- 10:
/KEYS	
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
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT

NSTEP=${NJOB}_45
#---------------------------------------------------------------------------
LIBEL="Extend merge FLORETFACTOR_INI_STD file with LO FACTOR STD columns"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_35_${IB}_MERGE_ESF_FLORETFACTOR_INI_STD.dat 2000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_MERGE_FLORETFACTOR_INI_STD_EXTEND_STD_LOFAC.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	CTR_NF			1:1 	- 1:,
	END_NT			2:1 	- 2:,
	SEC_NF			3:1 	- 3:,
	UWY_NF			4:1 	- 4:,
	UW_NT			5:1 	- 5:,
	RETCTR_NF		6:1 	- 6:,
	RETEND_NT		7:1 	- 7:,
	RETSEC_NF		8:1 	- 8:,
	RTY_NF			9:1 	- 9:,
	RETUW_NT		10:1 	- 10:,
	FILLER          1:1  	- 10:,
	STDCTR_NF			1:1 	- 1:,
	STDEND_NT			2:1 	- 2:,
	STDSEC_NF			3:1 	- 3:,
	STDUWY_NF			4:1 	- 4:,
	STDUW_NT			5:1 	- 5:,
	STDRETCTR_NF		6:1 	- 6:,
	STDRETEND_NT		7:1 	- 7:,
	STDRETSEC_NF		8:1 	- 8:,
	STDRTY_NF			9:1 	- 9:,
	STDRETUW_NT		10:1 	- 10:,
	LO_FACTOR		30:1	- 30:
/JOINKEYS
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
/INFILE ${ESF_FLORETFACTOR_STD} 2000 1 "~"
/JOINKEYS
	STDCTR_NF,
	STDEND_NT,
	STDSEC_NF,
	STDUWY_NF,
	STDUW_NT,
	STDRETCTR_NF,
	STDRETEND_NT,
	STDRETSEC_NF,
	STDRTY_NF,
	STDRETUW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE  ${SORT_O}
/REFORMAT   
	LEFTSIDE:FILLER,
	RIGHTSIDE:LO_FACTOR
exit
EOF
SORT

NSTEP=${NJOB}_50
#---------------------------------------------------------------------------
LIBEL="Extend merge FLORETFACTOR_INI_STD file with LO FACTOR INI columns"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_45_${IB}_MERGE_FLORETFACTOR_INI_STD_EXTEND_STD_LOFAC.dat 2000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_MERGE_FLORETFACTOR_INI_STD_EXTEND_INI_LOFAC.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	CTR_NF			1:1 	- 1:,
	END_NT			2:1 	- 2:,
	SEC_NF			3:1 	- 3:,
	UWY_NF			4:1 	- 4:,
	UW_NT			5:1 	- 5:,
	RETCTR_NF		6:1 	- 6:,
	RETEND_NT		7:1 	- 7:,
	RETSEC_NF		8:1 	- 8:,
	RTY_NF			9:1 	- 9:,
	RETUW_NT		10:1 	- 10:,
	FILLER          1:1  	- 11:,
	INICTR_NF		1:1 	- 1:,
	INIEND_NT		2:1 	- 2:,
	INISEC_NF		3:1 	- 3:,
	INIUWY_NF		4:1 	- 4:,
	INIUW_NT		5:1 	- 5:,
	INIRETCTR_NF	6:1 	- 6:,
	INIRETEND_NT	7:1 	- 7:,
	INIRETSEC_NF	8:1 	- 8:,
	INIRTY_NF		9:1 	- 9:,
	INIRETUW_NT		10:1 	- 10:,
	LO_FACTOR		30:1	- 30:
/JOINKEYS
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
/INFILE ${DFILT}/${NJOB}_40_${IB}_MERGE_ESF_FLORETFACTOR_INI.dat 2000 1 "~"
/JOINKEYS
	INICTR_NF,
	INIEND_NT,
	INISEC_NF,
	INIUWY_NF,
	INIUW_NT,
	INIRETCTR_NF,
	INIRETEND_NT,
	INIRETSEC_NF,
	INIRTY_NF,
	INIRETUW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE  ${SORT_O}
/REFORMAT   
	LEFTSIDE:FILLER,
	RIGHTSIDE:LO_FACTOR
exit
EOF
SORT

NSTEP=${NJOB}_51
#------------------------------------------------------------------------------------
LIBEL="Merge all RATIO file RETRO P"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_RATIO_I17G_RETRO_P} 2000 1"
SORT_I2="${EST_RATIO_I17P_RETRO_P} 2000 1"
SORT_I3="${EST_RATIO_I17L_RETRO_P} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_MERGE_EST_RATIO_RETRO_P.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CTR_NF				1:1 	- 1:,
	END_NT				2:1 	- 2:,
	SEC_NF				3:1 	- 3:,
	UWY_NF				4:1 	- 4:,
	UW_NT				5:1		- 5:,
	RETCTR_NF			6:1 	- 6:,
	RETEND_NT			7:1 	- 7:,
	RETSEC_NF			8:1 	- 8:,
	RTY_NF				9:1 	- 9:,
	RETUW_NT			10:1	- 10:
/KEYS	
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
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_52
LIBEL="Sort EGPI EARNE Ratio"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_51_${IB}_MERGE_EST_RATIO_RETRO_P.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_MERGE_REDUCED_EST_RATIO_RETRO_P.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF	1:1 -  1:,
	END_NT	2:1 -  2:,
	SEC_NF	3:1 -  3:,
	UWY_NF	4:1 -  4:,
	UW_NT	5:1 -  5:,
	RETCTR_NF	6:1 -  6:,
	RETEND_NT	7:1 -  7:,
	RETSEC_NF	8:1 -  8:,
	RTY_NF		9:1 -  9:,
	RETUW_NT	10:1 - 10:,
	PLC_NT		11:1 - 11:,
	EGPI_R1		12:1 - 13:,
	EGPI_R2		13:1 - 13:,
	EARP_R1 	14:1 - 14:,
	CSUOE_RETCSUOE		1:1  - 10:,
	EGPIS				12:1 - 14:
/KEYS
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
/OUTFILE ${SORT_O}
/REFORMAT 
	CSUOE_RETCSUOE,EGPIS
exit
EOF
SORT

NSTEP=${NJOB}_54
#---------------------------------------------------------------------------
LIBEL="Extend Merge EST_RATIO_RETRO_P with CSM pattern et LC patter columns "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_52_${IB}_MERGE_REDUCED_EST_RATIO_RETRO_P.dat 2000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_MERGE_EST_RATIO_RETRO_P_EXTEND_CSM_LC_PATTERN.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	CTR_NF          1:1 	- 1:,
	SEC_NF          3:1 	- 3:,
	UWY_NF          4:1 	- 4:,
	UW_NT           5:1 	- 5:,
	FILLER          1:1  	- 13:,
	CSM_CTR_NF      1:1 	- 1:,
	CSM_SEC_NF      2:1 	- 2:,
	CSM_UWY_NF      3:1 	- 3:,
	CSM_UW_NT       4:1 	- 4:,
	CSM_LC_PATTERN		7:1		- 7:,
	CSM_CSM_PATTERN		8:1		- 8:
/JOINKEYS
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT
/INFILE ${ESF_CSM_LC_AMORT_PATTERN_EBS} 2000 1 "~"
/JOINKEYS
	CSM_CTR_NF,
	CSM_SEC_NF,
	CSM_UWY_NF,
	CSM_UW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE  ${SORT_O}
/REFORMAT   
	LEFTSIDE:FILLER,
	RIGHTSIDE:CSM_LC_PATTERN,
	RIGHTSIDE:CSM_CSM_PATTERN
exit
EOF
SORT


NSTEP=${NJOB}_57
#---------------------------------------------------------------------------
LIBEL="Extend Merge EST_RATIO_RETRO_P with FLAG columns "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_54_${IB}_MERGE_EST_RATIO_RETRO_P_EXTEND_CSM_LC_PATTERN.dat 2000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_MERGE_EST_RATIO_RETRO_P_EXTEND_CSM_LC_PATTERN_FLAG.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	CTR_NF          1:1 	- 1:,
	END_NT			2:1 	- 2:,
	SEC_NF          3:1 	- 3:,
	UWY_NF          4:1 	- 4:,
	UW_NT           5:1 	- 5:,
	FILLER          1:1  	- 15:,
	FLAG_CTR_NF     1:1 	- 1:,
	FLAG_SEC_NF     2:1 	- 2:,
	FLAG_UWY_NF     3:1 	- 3:,
	FLAG_UW_NT      4:1 	- 4:,
	FLAG_END_NT     5:1 	- 5:,
	FLAG		    6:1		- 6:
/JOINKEYS
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT, 
	END_NT
/INFILE "${DFILT}/${NJOB}_15_${IB}_MERGE_EST_FLAG_ANN_LMT.dat" 2000 1 "~"
/JOINKEYS
	FLAG_CTR_NF,
	FLAG_SEC_NF,
	FLAG_UWY_NF,
	FLAG_UW_NT,
	FLAG_END_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE  ${SORT_O}
/REFORMAT   
	LEFTSIDE:FILLER,
	RIGHTSIDE:FLAG
exit
EOF
SORT



NSTEP=${NJOB}_61
#---------------------------------------------------------------------------
LIBEL="Extend Merge EST_RATIO_RETRO_P with ESF_FLORETFACTOR LO FACTOR columns "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_57_${IB}_MERGE_EST_RATIO_RETRO_P_EXTEND_CSM_LC_PATTERN_FLAG.dat 2000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_MERGE_EST_RATIO_RETRO_P_EXTEND_CSM_LC_PATTERN_FLAG_LOFACTOR.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	CTR_NF			1:1 	- 1:,
	END_NT			2:1 	- 2:,
	SEC_NF			3:1 	- 3:,
	UWY_NF			4:1 	- 4:,
	UW_NT			5:1 	- 5:,
	RETCTR_NF		6:1 	- 6:,
	RETEND_NT		7:1 	- 7:,
	RETSEC_NF		8:1 	- 8:,
	RTY_NF			9:1 	- 9:,
	RETUW_NT		10:1 	- 10:,	
	EGPI_R1	 		11:1	- 11:,
	EGPI_R2	 		12:1	- 12:,
	EARP_R1	 		13:1	- 13:,
	LC_PATTERN		14:1	- 14:,
	CSM_PATTERN		15:1	- 15:,
	FLAG			16:1	- 16:,
	FILLER_CSUOE    1:1  	- 10:,
	FLORETFACTOR_CTR_NF     1:1 	- 1:,
	FLORETFACTOR_END_NT     2:1 	- 2:,
	FLORETFACTOR_SEC_NF     3:1 	- 3:,
	FLORETFACTOR_UWY_NF     4:1 	- 4:,
	FLORETFACTOR_UW_NT      5:1 	- 5:,
	FLORETFACTOR_RETCTR_NF  6:1 	- 6:,
	FLORETFACTOR_RETEND_NT  7:1 	- 7:,
	FLORETFACTOR_RETSEC_NF  8:1 	- 8:,
	FLORETFACTOR_RTY_NF     9:1 	- 9:,
	FLORETFACTOR_RETUW_NT   10:1 	- 10:,
	FLORETFACTOR_LOFACTOR_STD	 11:1	- 11:,
	FLORETFACTOR_LOFACTOR_INI	 12:1	- 12:
/JOINKEYS
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
/INFILE "${DFILT}/${NJOB}_50_${IB}_MERGE_FLORETFACTOR_INI_STD_EXTEND_INI_LOFAC.dat" 2000 1 "~"
/JOINKEYS
	FLORETFACTOR_CTR_NF,
	FLORETFACTOR_END_NT,
	FLORETFACTOR_SEC_NF,
	FLORETFACTOR_UWY_NF,
	FLORETFACTOR_UW_NT,
	FLORETFACTOR_RETCTR_NF,
	FLORETFACTOR_RETEND_NT,
	FLORETFACTOR_RETSEC_NF,
	FLORETFACTOR_RTY_NF,
	FLORETFACTOR_RETUW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE  ${SORT_O}
/REFORMAT   
	LEFTSIDE:FILLER_CSUOE,
	RIGHTSIDE:FLORETFACTOR_LOFACTOR_STD,FLORETFACTOR_LOFACTOR_INI,
	LEFTSIDE:LC_PATTERN,CSM_PATTERN,FLAG,EGPI_R1,EGPI_R2,EARP_R1
exit
EOF
SORT



NSTEP=${NJOB}_65
#---------------------------------------------------------------------------
LIBEL="delete duplicate in file"
sort -u ${DFILT}/${NJOB}_61_${IB}_MERGE_EST_RATIO_RETRO_P_EXTEND_CSM_LC_PATTERN_FLAG_LOFACTOR.dat > ${DFILT}/${NSTEP}_${IB}_MERGE_EST_RATIO_RETRO_P_EXTEND_CSM_LC_PATTERN_FLAG_LOFACTOR.dat
sort -u ${DFILT}/${NJOB}_32_${IB}_PERICASE_EXTEND_RETRO_RATIO.dat >  ${DFILT}/${NSTEP}_${IB}_PERICASE_EXTEND_RETRO.dat
sort -u ${DFILT}/${NJOB}_27_${IB}_MERGE_PERICASE_EXTEND_CSM_LC_PATTERN_FLAG_RATIO_ASSUMED.dat > ${DFILT}/${NSTEP}_${IB}_MERGE_PERICASE_EXTEND_CSM_LC_PATTERN_FLAG_RATIO_ASSUMED.dat

JOBEND
