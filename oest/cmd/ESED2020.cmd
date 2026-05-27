#!/bin/ksh
#=============================================================================
# nom de l'application		: EXPORT SEGMENTATION RESULT
# nom du script SHELL		: ESED2020.cmd
# revision			        : $Revision:   1.0  $
# date de creation		    : 29/07/2013
# auteur			        : G. GUNTHER
# references des specifications	: 
#-----------------------------------------------------------------------------
# description : xwiki: BTH-SEG-805707
# Extract segmentation results
#-----------------------------------------------------------------------------
# Parametres :
# $1 User that asks the job
# $2 parameter n1 - Segmentation run id
# $3 parameter n2 - Production Site of the user
# $4 parameter n3 - Geographical Site of the user
# $5 parameter n4
# $6 parameter n5
# $7 parameter n6
# $8 parameter n7
# $9 parameter n8
# $10 parameter n9
# $11 parameter c1
# $12 parameter c2
# $13 parameter c3
# $14 parameter c4
# $15 parameter c5
# $16 parameter c6
# $17 parameter c7
# $18 parameter c8
# $19 parameter c9
# $20 Current date yyyymmdd
# $21 Current time (?)
# $22 Log file of the daemon
#-----------------------------------------------------------------------------
# Modification history:
# 14/10/2013	GGU: Creation  
#  
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctws.cmd

NJOB=ESED2020

CODEUSER=${1}
RUN_ID=${2}
PRDSIT_CF=${3}
GEOSIT_CF=${4}
LOGFILE=${7}

# Name of the output file to generate: run id - user id - timestamp 
OUTPUTFILENAME="segmentation_result_${RUN_ID}_${1}_$(date +'%Y-%m-%d-%H-%M-%S').csv"

# Environment file
. ${DENV}/ESED2020.env

# Initialisation of the JOB
JOBINIT

# Move to the DW database to retrieve the last run information
NSTEP=${NJOB}_SRV_SWITCH_INF
LIBEL="Switch to DW server"
SWITCH_SRV ${INF_SRV}

# Extract data related to the run we want to extract
# Retrieve booleans that indicates id the run has been evaluated, simulated or archived
NSTEP=${NJOB}_RUN_DATA
RUN_DATA_RES=${DFILT}/${NSTEP}_${IB}_RUN_DATA_RES.dat

LIBEL="Retrieve data related to the run to extract"
BCP_WAY="OUT"; BCP_VER="+"; BCP_FS=" "
BCP_O=${RUN_DATA_RES}
BCP_QRY="select SGT_NT, SGTVER_NT, SGTRESTABNME_LL, SGTERRTABNME_LL from BSEG..TSEGRUN where SGTRUN_NT=${RUN_ID}"
BCP

if [[ ! -s ${RUN_DATA_RES} ]]; then
	echo "Can't found the run to export";
	return 0
fi;

# Extract values of the result query
resultset_pattern=" *([0-9]+) +([0-9]+) +([A-Za-z0-9._]+) +([A-Za-z0-9._]+) *"
SGT_NT=$(sed -r "s/${resultset_pattern}/\1/" ${RUN_DATA_RES} | grep -E '^[0-9]+$')
SGTVER_NT=$(sed -r "s/${resultset_pattern}/\2/" ${RUN_DATA_RES} | grep -E '^[0-9]+$')
SGTRESTABNME_LL=$(sed -r "s/${resultset_pattern}/\3/" ${RUN_DATA_RES} | grep -E '^[A-Za-z0-9._]+$')
SGTERRTABNME_LL=$(sed -r "s/${resultset_pattern}/\4/" ${RUN_DATA_RES} | grep -E '^[A-Za-z0-9._]+$')

NSTEP=${NJOB}_RM_TMP_RUN_DATA
LIBEL='Remove temporary run data'
RMFIL $RUN_DATA_RES

# If the target table is specified
# Extract data using BCP and send the output file to the report server using java batch
if [[ ! -z "$SGTRESTABNME_LL" ]]; then
	SEGMENT_DEFINITIONS=${DFILT}/${NJOB}_SEGMENT_DEFINITIONS.dat
	BALAI_DEFINITIONS=${DFILT}/${NJOB}_BALAI_DEFINITIONS.dat
	EXTRACT_FILE=${DFILT}/${NJOB}_EXTRACT_DATA.dat
	EXPORT_FILE=${DFILT}/${OUTPUTFILENAME}

	SWITCH_SRV $PRD_SRV

	NSTEP=${NJOB}_BALAI_DEFINITIONS
	LIBEL='Extract balai definitions'
	BCP_WAY="OUT"; BCP_VER="+"; BCP_FS=$'\x1c'
	BCP_O=${BALAI_DEFINITIONS}
	BCP_QRY="select rtrim(colval_ct), colval_ls, colval_lm from bref..tbantecl where col_ls = 'sgtbalaityp_cf' and lag_cf = 'e' "
	BCP

	NSTEP=${NJOB}_SEGMENT_DEFINITIONS
	LIBEL='Extract segment definitions'
	BCP_WAY="OUT"; BCP_VER="+"; BCP_FS=$'\x1c'
	BCP_O=${SEGMENT_DEFINITIONS}
	BCP_QRY="select sgmt_nf, sgmt_ls, sgmt_ll from best..tsegmt where sgt_nt=${SGT_NT} and sgtver_nt=${SGTVER_NT} "
	BCP
	
	NSTEP=${NJOB}_COMPLETE_DEFINITIONS
	LIBEL='Complete segment definitions with balai values'
	STEPSTART
	cat $BALAI_DEFINITIONS >> $SEGMENT_DEFINITIONS
	STEPEND $?

	SWITCH_SRV $INF_SRV
	
	NSTEP=${NJOB}_EXTRACT_DATA
	LIBEL='Extract run data'
	BCP_WAY="OUT"; BCP_VER="+"; BCP_FS=$'\x1c'
	BCP_O=${EXTRACT_FILE}
	BCP_QRY="select sgmt_nf, ctr_nf, uwy_nf, uw_nt, sec_nf, rto_nf from ${SGTRESTABNME_LL} "
	BCP
	
	NSTEP=${NJOB}_PREPARE_EXPORT
	LIBEL='Prepare export file by adding columns headers'
	STEPSTART
	echo 'Segment Short Label,Segment Long Label,Contract,Underwriting Year,Order,Section,Retrocessionaire' > $EXPORT_FILE
	STEPEND $?

	# Fill up extract to the left by adding segment labels
	NSTEP=${NJOB}_FILL_RESULTS
	LIBEL='Fill in results with definitions'
	STEPSTART
	# Block 1: Store segments values by reading the whole segment definitions
	# Block 2: Once definitions fully read, use them to fill in results
	awk 'BEGIN { FS="'$'\x1c''" ; OFS="," }
	NR==FNR { def_ls[$1]=$2 ; def_ll[$1]=$3 ; next }
	{ if ($1 in def_ls) { ls=def_ls[$1] ; ll=def_ll[$1] }
	  else { ls="" ; ll="" }
	  print ls,ll,$2,$3,$4,$5,$6
	}
	' $SEGMENT_DEFINITIONS $EXTRACT_FILE >> $EXPORT_FILE
	STEPEND $?

	# Send the file to the GUI
	NSTEP=${NJOB}_SEND_DATA
	LIBEL="Send file to be read by the omega2 GUI"
	WS_REPORT_NAME=NULL_REPORT
	WS_INPUT_FILE=${EXPORT_FILE}
	WS_SYNCHRONOUS=true
    WS_PARAMS_TEXT << EOF
INPUT_FORMAT RAW
ACTION   	MOVE
LOGFILE     ${LOGFILE}
ITASK       best13a1
OUTPUT_FORMAT APPLICATION_CSV
OUTPUT_FILENAME ${OUTPUTFILENAME}
EOF
	WS_REPORT
fi

	NSTEP=${NJOB}_RM_EXPORTED_FILE
	LIBEL='Remove exported file'
	RMFIL $EXPORT_FILE
	
	NSTEP=${NJOB}_RM_TMP_EXTRACT_DATA
	LIBEL='Remove temporary extracted data file'
	RMFIL $EXTRACT_FILE
	
	NSTEP=${NJOB}_RM_TMP_SEGMENTS
	LIBEL='Remove temporary segment definitions'
	RMFIL $SEGMENT_DEFINITIONS
	
	NSTEP=${NJOB}_RM_TMP_BALAIS
	LIBEL='Remove temporary balai definitions'
	RMFIL $BALAI_DEFINITIONS

# End of the Job
JOBEND