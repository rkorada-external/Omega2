#!/bin/ksh
#=============================================================================
# nom de l'application          : Tri génerique de fichier
# nom du script SHELL           : ESID0003.cmd
# revision                      : $Revision: 1.0 $
# date de creation              : 03/12/2015
# auteur                        : MME
# references des specifications :
#-----------------------------------------------------------------------------
# description :
#   division de fichier de previsions en Vlifest et Lifestnoacc 
#
#-----------------------------------------------------------------------------
# historique des modifications :
#   <jj/mm/aaaa>   <auteur>    <description de la modification>
# [001] 25/02/2019 R.vieville spot:70045: Add mount in SORT
#==============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Name of the job
NSUBJOB=$(basename $0 .cmd)

# Initialisation of the JOB
SUBJOBINIT

# Get input parameters
OUTPUT_FILE_NAME_1=$1    # Output file 1
OUTPUT_FILE_NAME_2=$2    # Output file 2 - lifestnoacc
INPUT_FILE1=$3
BALSHTYEA_NF=$4

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> OUTPUT_FILE_NAME_1....: ${OUTPUT_FILE_NAME_1}"
ECHO_LOG "#===> OUTPUT_FILE_NAME_2....: ${OUTPUT_FILE_NAME_2}"
ECHO_LOG "#===> INPUT_FILE1...........: ${INPUT_FILE1}"
ECHO_LOG "#===> BALSHTYEA_NF...........: ${BALSHTYEA_NF}"
ECHO_LOG "#========================================================================="

if [[ "$#" -ne 4 ]]; then
    ECHO_LOG "Missing arguments, should have OUTPUT_FILE_NAME_1 OUTPUT_FILE_NAME_2 INPUT_FILE1,exiting"
    SUBJOBEND
fi

NSTEP=${NSUBJOB}_050
# [001]
#------------------------------------------------------------------------------
LIBEL="Spiliting VLIFEST "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT_FILE1} 1000 1"
SORT_O="${OUTPUT_FILE_NAME_1} OVERWRITE 1000 1"
SORT_O2="${OUTPUT_FILE_NAME_2} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	CTR_NF			2:1 - 2:,
	END_NT			3:1 - 3:,
	SEC_NF			4:1 - 4:EN,
	ACY_NF			7:1 - 7:,
	UWY_NF			5:1 - 5:,
	UW_NT			6:1 - 6:,
	ACMTRS_NT		10:1 - 10:,
	ACMTRS4_NT		10:4 - 10:4,
	DETTRNCOD_CF	20:1 - 20:,
	GAAP_NF			22:1 - 22:,
	ACM_NF			25:1 - 25:EN
/KEYS 
	CTR_NF,
	END_NT,
	SEC_NF,
	ACY_NF,
	ACM_NF,
	UWY_NF,
	UW_NT,
	ACMTRS_NT,
	DETTRNCOD_CF,
	GAAP_NF
/CONDITION ACY (ACY_NF > "${BALSHTYEA_NF}")
/OUTFILE ${SORT_O}
/OMIT ACY
/OUTFILE ${SORT_O2}
/INCLUDE ACY
exit
EOF
SORT

SUBJOBEND
