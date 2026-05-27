#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD3721.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 29\08\2019
# auteur                        : Antoine GRUNWALD
#-----------------------------------------------------------------------------
# description
#  IFRS17 REQ 12.3 : CSM at CR level calculation
#
#-----------------------------------------------------------------------------
# modif
# [01] 09/09/2022 Bhimasen 	SPIRA 106367 : Missing retro discount on local/parent
# [02] 18/01/2024 FCI 	SPIRA 101276 : Internal Assumed - IFRS 17 info
# [03] 28/05/2024 MZM 	SPIRA 111713 : FILTRE SUR SSD VIDE 
# [04] 14/11/2024 MZM   SPIRA 112368   REVERT SUR VERSION STABLE
# [05] 10/04/2025 DAD   SPIRA 112735 : remove duplication for file region inter site and stop append for file inter site
# [06] 10/10/2025 HR    US5524 : Retro N+1 - Copy I17 info from RI to AI - Spira 112735
# [07] 15/12/2025 JYP   US8021 : init ESF_REGION_FSECIFRS_INTER_SITE
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctjsb.cmd
. ${DUTI}/fcttransfer.cmd
. ${DUTI}/fctsplit.cmd

# Job Initialisation
JOBINIT

CLOTYP=INI

ECHO_LOG "#===> NCHAIN........................................................: ${NCHAIN}"
ECHO_LOG "#===> OLD_CHAIN........................................................: ${OLD_CHAIN}"

ECHO_LOG "#========================================================================="
ECHO_LOG "#===> BATCHUSER........................................................: ${PARM_BATCHUSER}"
ECHO_LOG "#===> ICLODAT_D........................................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> CLOTYP...........................................................: ${CLOTYP}"
ECHO_LOG "#===> NORME_CF.........................................................: ${NORME_CF}"
ECHO_LOG "#===> PARM_IS_TRN......................................................: ${PARM_IS_TRN}"

ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> ESF_GTSII_CSM....................................................: ${ESF_GTSII_CSM}"
ECHO_LOG "#===> ESF_GTSII_GLOBAL_CASHFLOW........................................: ${ESF_GTSII_GLOBAL_CASHFLOW}"
ECHO_LOG "#===> ESF_FRERETFACCTR_INI.............................................: ${ESF_FRERETFACCTR_INI}"
ECHO_LOG "#===> ESF_IADPERICASE_INI..............................................: ${ESF_IADPERICASE_INI}"
ECHO_LOG "#===> EPO_FCURQUOT_TXT.................................................: ${EPO_FCURQUOT_TXT}"
ECHO_LOG "#===> ESF_FUOASII......................................................: ${ESF_FUOASII}"
ECHO_LOG "#===> ESF_FSSDACTR.....................................................: ${ESF_FSSDACTR}"

ECHO_LOG "#===> ESF_REGION_FSECIFRS_INTER_SITE...................................: ${ESF_REGION_FSECIFRS_INTER_SITE}"

ECHO_LOG "#===> ............ OUTPUT ................................................."
ECHO_LOG "#===> ESF_FSECIFRS.....................................................: ${ESF_FSECIFRS}"
ECHO_LOG "#===> ESF_FSEGPROF.....................................................: ${ESF_FSEGPROF}"
ECHO_LOG "#===> ESF_FRETIFRS.....................................................: ${ESF_FRETIFRS}"
ECHO_LOG "#===> ESF_FSECIFRS_LIGHT...............................................: ${ESF_FSECIFRS_LIGHT}"

ECHO_LOG "#===> ESF_FSECIFRS_INTER_SITE..........................................: ${ESF_FSECIFRS_INTER_SITE}"
ECHO_LOG "#========================================================================="


if [ ! -f ${ESF_REGION_FSECIFRS_INTER_SITE} ]
then
	ECHO_LOG "ESF_REGION_FSECIFRS_INTER_SITE=${ESF_REGION_FSECIFRS_INTER_SITE}  does not exist, take an empty file"  
	EXECKSH "touch ${ESF_REGION_FSECIFRS_INTER_SITE}"
fi 
	
if [[ ${NORME_CF} = "I17G" ]];
then
ECHO_LOG "#===> EXTCHAIN......................................................: ${EXTCHAIN}"
ECHO_LOG "#===> REMOTE_SITE...................................................: ${REMOTE_SITE}"

NSTEP=${NJOB}_0
#------------------------------------------------------------------------------
LIBEL="Get the unzipped files from other region."
GET_FILES_DIR=${REMOTE_SITE}
GET_FILES_PREFIX=${EXTCHAIN}
GET_FILES_MERGE="YES"
GET_FILES_O=${DFILT}/${NSTEP}_${IB}_GETFILES_FROM_O.dat
GET_FILES

export FILE_FROM_OTHER_REGION="${DFILT}/${NSTEP}_${IB}_GETFILES_FROM_O.dat"
if [ -f ${FILE_FROM_OTHER_REGION} ]; then
	NSTEP=${NJOB}_1
	#------------------------------------------------------------------------------
	
#[06]
LIBEL="Collecting SSD"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="${DFILT}/${NSTEP}_${IB}_TBATCHSSD.dat"
BCP_QRY="SELECT BATCHUSER_CF, SSD_CF FROM BREF..TBATCHSSD WHERE BATCHUSER_CF != '${PARM_BATCHUSER}'"
BCP

LIBEL="Filter FSSDACTR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FSSDACTR} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FSSDACTR_TXT_EBS_FILTERED.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        SSD_CF_F1         12:1 - 12:,
        SSD_CF_F2         2:1 - 2:,
        FILLERF1          6:1 - 10:		
/JOINKEYS
        SSD_CF_F1
/INFILE ${DFILT}/${NSTEP}_${IB}_TBATCHSSD.dat 2000 1 "~"
/JOINKEYS
        SSD_CF_F2
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT leftside: FILLERF1
exit
EOF
SORT

LIBEL="Remove duplicates FSSDACTR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NSTEP}_${IB}_FSSDACTR_TXT_EBS_FILTERED.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FSSDACTR_TXT_EBS_FILTERED_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
	CTR_NF_F1		1:1 - 1:,
	UWY_NF_F1		2:1 - 2:,
	UW_NT_F1		3:1 - 3:,
	END_NT_F1		4:1 - 4:,
	SEC_NF_F1		5:1 - 5:
/KEYS
	CTR_NF_F1,
	UWY_NF_F1,
	UW_NT_F1,
	END_NT_F1,
	SEC_NF_F1
/SUM	
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT

LIBEL="Filter FSSDACTR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_REGION_FSECIFRS_INTER_SITE} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_REGION_FSECIFRS_INTER_SITE_FILTERED.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
	CTR_NF_F1		1:1 - 1:,
	UWY_NF_F1		2:1 - 2:,
	UW_NT_F1		3:1 - 3:,
	END_NT_F1		4:1 - 4:,
	SEC_NF_F1		5:1 - 5:,
	CTR_NF_F2		6:1 - 6:,
	UWY_NF_F2		7:1 - 7:,
	UW_NT_F2		8:1 - 8:,
	END_NT_F2		9:1 - 9:,
	SEC_NF_F2		10:1 - 10:
/JOINKEYS
	CTR_NF_F1,
	UWY_NF_F1,
	UW_NT_F1,
	END_NT_F1,
	SEC_NF_F1
/INFILE ${DFILT}/${NSTEP}_${IB}_FSSDACTR_TXT_EBS_FILTERED_O.dat 2000 1 "~"
/JOINKEYS
	CTR_NF_F2,
	UWY_NF_F2,
	UW_NT_F2,
	END_NT_F2,
	SEC_NF_F2
/JOIN UNPAIRED LEFTSIDE ONLY	
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT
	
	ECHO_LOG "Delete first SSD field from all lines to use it during java part."
	pattern="(\d+)~(.*)$"
	cat ${DFILT}/${NSTEP}_${IB}_REGION_FSECIFRS_INTER_SITE_FILTERED.dat > ${DFILT}/${NSTEP}_${IB}_REGION_FSECIFRS_INTER_SITE.dat
	while IFS= read -r line
	do
	  if [[ $line =~ $pattern ]]; then
		echo ${.sh.match[2]} >> ${DFILT}/${NSTEP}_${IB}_REGION_FSECIFRS_INTER_SITE.dat
		ECHO_LOG "add  ${.sh.match[2]} into ${DFILT}/${NSTEP}_${IB}_REGION_FSECIFRS_INTER_SITE.dat"
	  else
		ECHO_LOG "${DFILT}/${NSTEP}_${IB}_GETFILES_FROM_O.dat doesnt match the expected format."
	  fi
	done < "$FILE_FROM_OTHER_REGION"


	LIBEL="SORT - remove duplicate for file region FSECIFRS inter site "
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${NSTEP}_${IB}_REGION_FSECIFRS_INTER_SITE.dat 2000 1"
	SORT_O="${ESF_REGION_FSECIFRS_INTER_SITE} 2000 1"
	INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF		1:1 - 1:,
	UWY_NF		2:1 - 2:,
	UW_NT		3:1 - 3:,
	END_NT		4:1 - 4:,
	SEC_NF		5:1 - 5:
/KEYS
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT,
	END_NT
/SUM
/OUTFILE ${SORT_O}

exit
EOF
SORT

fi

fi

NSTEP=${NJOB}_2
#------------------------------------------------------------------------------

# inputs files
export ESTJ0002_CSM_CASHFLOW="${ESF_GTSII_CSM}"
export ESTJ0002_EGPI_CASHFLOW="${ESF_GTSII_GLOBAL_CASHFLOW}"
export ESTJ0002_CONTRACT_RATE_INDEX="${ESF_FRERETFACCTR_INI}"
export ESTJ0002_CONTRACT_PERICASE="${ESF_IADPERICASE_INI}"
export ESTJ0002_CURRENCY="${EPO_FCURQUOT_TXT}"
export ESTJ0002_THRESHOLD="${ESF_FUOASII}"
export ESTJ0002_CASHFLOW_INTERNAL_KEY_RECOVERY="${ESF_FSSDACTR}"

export ESTJ0002_REGION_TSECIFRS_INTER_SITE="${ESF_REGION_FSECIFRS_INTER_SITE}"

# tmp files
export ESTJ0002_SORTED_CSM_CASHFLOW="${DFILT}/${NJOB}_1_${IB}_SORTED_CSM_CASHFLOW.dat"
export ESTJ0002_SORTED_EGPI_CASHFLOW="${DFILT}/${NJOB}_1_${IB}_SORTED_EGPI_CASHFLOW.dat"
export ESTJ0002_SORTED_CONTRACT_RATE_INDEX="${DFILT}/${NJOB}_1_${IB}_SORTED_CONTRACT_RATE_INDEX.dat"
export ESTJ0002_SORTED_CONTRACT_PERICASE="${DFILT}/${NJOB}_1_${IB}_SORTED_CONTRACT_PERICASE.dat"
export ESTJ0002_EXTENDED_CONTRACT_PERICASE="${DFILT}/${NJOB}_1_${IB}_EXTENDED_CONTRACT_PERICASE.dat"
export ESTJ0002_SORTED_EXTENDED_CONTRACT_PERICASE="${DFILT}/${NJOB}_1_${IB}_SORTED_EXTENDED_CONTRACT_PERICASE.dat"
export ESTJ0002_PROFITABILITY_CR="${DFILT}/${NJOB}_1_${IB}_PROFITABILITY_CR.dat"
export ESTJ0002_SORTED_PROFITABILITY_CR="${DFILT}/${NJOB}_1_${IB}_SORTED_PROFITABILITY_CR.dat"
export ESTJ0002_SORTED_CSM_CASHFLOW_R="${DFILT}/${NJOB}_1_${IB}_SORTED_CSM_CASHFLOW_R.dat"
export ESTJ0002_SORTED_CONTRACT_RATE_INDEX_R="${DFILT}/${NJOB}_1_${IB}_SORTED_CONTRACT_RATE_INDEX_R.dat"
export ESTJ0002_SORTED_CASHFLOW_INTERNAL_KEY_RECOVERY="${DFILT}/${NJOB}_1_${IB}_SORTED_CASHFLOW_INTERNAL_KEY_RECOVERY.dat"
export ESTJ0002_UPDATE_TSECIFRS_TMP="${DFILT}/${NJOB}_1_${IB}_UPDATE_TSECIFRS_TMP.dat"
export ESTJ0002_MERGED_UPDATE_TSECIFRS_TMP="${DFILT}/${NJOB}_1_${IB}_MERGED_UPDATE_TSECIFRS_TMP.dat"
export ESTJ0002_SORTED_UPDATE_TSECIFRS_TMP="${DFILT}/${NJOB}_1_${IB}_SORTED_UPDATE_TSECIFRS_TMP.dat"
export ESTJ0002_SORTED_UPDATE_TSECIFRS="${DFILT}/${NJOB}_1_${IB}_SORTED_UPDATE_TSECIFRS.dat"
export ESTJ0002_TSECIFRS_INTER_SITE="${DFILT}/${NJOB}_1_${IB}_TSECIFRS_INTER_SITE.dat"
export ESTJ0002_TSECIFRS_INTER_SITE_SSD="${DFILT}/${NJOB}_1_${IB}_TSECIFRS_INTER_SITE_SSD.dat"
export ESTJ0002_SORTED_CASHFLOW_INTERNAL_KEY_RECOVERY_INTERSITE="${DFILT}/${NJOB}_1_${IB}_SORTED_CASHFLOW_INTERNAL_KEY_RECOVERY_INTERSITE.dat"
export ESTJ0002_BUSINESS_LOGS="${DFILT}/${NJOB}_1_${IB}_BUSINESS_JAVALOGS.log"

# outputs files
export ESTJ0002_UPDATE_TSECIFRS="${ESF_FSECIFRS}"
export ESTJ0002_UPDATE_TSEGPROF="${ESF_FSEGPROF}"
export ESTJ0002_UPDATE_TRETIFRS="${ESF_FRETIFRS}"
export ESTJ0002_UPDATE_TSECIFRS_LIGHT="${ESF_FSECIFRS_LIGHT}"
export ESTJ0002_SORTED_TSECIFRS_INTER_SITE="${ESF_FSECIFRS_INTER_SITE}"
export ESTJ0002_SORTED_TSECIFRS_INTER_SITE_SSD="${ESF_FSECIFRS_INTER_SITE_SSD}"

# CMD variable
export SYNCSORT_CMD_ESTJ0002_SORT_CASHFLOW_BY_CTR_ID=${DCMD}/ESTS0063.cmd
export SYNCSORT_CMD_ESTJ0002_SORT_RATE_INDEX_BY_CTR_ID=${DCMD}/ESTS0002.cmd
export SYNCSORT_CMD_ESTJ0002_SORT_CASHFLOW_BY_CTR_UWY=${DCMD}/ESTS0025.cmd
export SYNCSORT_CMD_ESTJ0002_SORT_RATE_INDEX_BY_CTR_UWY=${DCMD}/ESTS0026.cmd
export SYNCSORT_CMD_ESTJ0002_SORT_CONTRACT_PERICASE_BY_CTR_ID=${DCMD}/ESTS0003.cmd
export SYNCSORT_CMD_ESTJ0002_SORT_EXTENDED_CONTRACT_PERICASE_BY_CR_ID=${DCMD}/ESTS0013.cmd
export SYNCSORT_CMD_ESTJ0002_SORT_PROFITABILITY_BY_SEGMENT_ID=${DCMD}/ESTS0001.cmd
export SYNCSORT_CMD_ESTJ0002_SORT_INTERNAL_CASHFLOW_KEY_RECOVERY_BY_CTR_UWY=${DCMD}/ESTS0054.cmd
export SYNCSORT_CMD_ESTJ0002_SORT_INTERNAL_CASHFLOW_KEY_RECOVERY_INTERSITE_BY_CSUOE=${DCMD}/ESTS0064.cmd
export SYNCSORT_CMD_ESTJ0002_SORT_INTERSITE_BY_SSD_CSUOE=${DCMD}/ESTS0065.cmd
export SYNCSORT_CMD_ESTJ0002_SORT_UPDATE_TSECIFRS_BY_CTR_ID=${DCMD}/ESTS0055.cmd
export SYNCSORT_CMD_ESTJ0002_MERGE_FILE=${DCMD}/ESTS0005.cmd

# Jar execution
JSB_CHAIN="estj0002"
JSB_PARAMS="cloDate=${PARM_ICLODAT_D} cloType=${CLOTYP} normcf=${NORME_CF} cloUser=${PARM_BATCHUSER} isTrnMode=${PARM_IS_TRN}"
# JSB_JAR_PATH="${DJAVA}/OMEGA-IFRS17-3.07.DEV-SNAPSHOT.jar"
EXECJSB


NSTEP=${NJOB}_3
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> Sauvegarde ...... ${ESTJ0002_TSECIFRS_INTER_SITE}"
ECHO_LOG "#========================================================================="
#gzip -c ${ESTJ0002_TSECIFRS_INTER_SITE} > ${DFILT}/${NJOB}_6_${IB}_INTER_SITE.dat.gz


if [[ ${NORME_CF} != "I17G" ]];
then

ECHO_LOG "not I17G, remove intersite files"

NSTEP=${NJOB}_3
#------------------------------------------------------------------------------
LIBEL="Erase intersite files for I17 P/L/S"
RMFIL "${DFILP}/${NJOB}*INTER_SITE*.dat"


else

ECHO_LOG "I17G intersite treatment"
ECHO_LOG "#===> Sort of ...... ${ESTJ0002_SORTED_TSECIFRS_INTER_SITE_SSD}"

##[03]

NSTEP=${NJOB}_05
# This sort is already done in JSB side
#-----------------------------------------------------------------------------
LIBEL="Sort INTERSITE file according to subsidiary"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESTJ0002_SORTED_TSECIFRS_INTER_SITE_SSD} 500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FSECIFRS_INTER_SITE.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/KEYS SSD_CF
/CONDITION EST_VIDE_SSD (SSD_CF = 0 )
/OMIT EST_VIDE_SSD
exit
EOF
SORT

ECHO_LOG "${NJOB}_10 incoming"
ECHO_LOG "#===> Split of ...... ${DFILT}/${NJOB}_05_${IB}_SORT_FSECIFRS_INTER_SITE.dat cancelled"

NSTEP=${NJOB}_10
# Split INTERSITE file by subsidiary
#-----------------------------------------------------------------------------
LIBEL="Split INTERSITE file by subsidiary"
SPLIT_PREFIX=${NJOB}_05
SPLIT_PREFIX_NEW=${NSTEP}
SPLIT_I=${DFILT}/${NJOB}_05_${IB}_SORT_FSECIFRS_INTER_SITE.dat
SPLIT_FILE


NSTEP=${NJOB}_15
# Concat file names
#-----------------------------------------------------------------------------
LIBEL="Concat file names"
STR_CAT_PREFIX="${DFILT}/${NJOB}_10_*_${IB}*.dat"
STR_CAT

ECHO_LOG "#===> Concat of ...... ${STR_CAT_O}"

export NCHAIN=${EXTCHAIN}

NSTEP=${NJOB}_20
# Send files
#-----------------------------------------------------------------------------
LIBEL="Send files to pool"
SEND_POOL_PREFIX="${NJOB}_10_.*_${IB}"
SEND_POOL_FILES=${STR_CAT_O}
SEND_POOL_TYPE="SSD"
SEND_POOL

export NCHAIN=${OLD_CHAIN}

fi

NSTEP=${NJOB}_25
#------------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*${IB}*.dat "

JOBEND
