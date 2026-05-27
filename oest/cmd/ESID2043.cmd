#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Impression du compte rendu inventaire vie
# nom du script SHELL		: ESID2043.cmd
# revision			: $Revision:   1.3  $
# date de creation		: 10/1997
# auteur			: CGI  
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#     Print report 
#
#  job launched by ESID2040.cmd
#-----------------------------------------------------------------------------
# historiques des modifications 
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd
. ${DUTI}/fctws.cmd

. ${DCMD}/ESCD9002.cmd

# Initialisation of the Job
JOBINIT

NSTEP=${NJOB}_05
#if no file generated...
#---------------------------------------------------------------
if [ ! -s ${DFILT}/${NJOB}_${IB}_ESTR203A_ANO_O.dat ]
then
  JOBEND
fi

NSTEP=${NJOB}_10
LIBEL="Formatting of the data"
WS_BATCH_NAME=ESTR2030
WS_INPUT_FILE=${DFILT}/${NJOB}_${IB}_ESTR203A_ANO_O.dat
WS_OUTPUT_FILE=${DFILT}/${NSTEP}_${IB}_ESTR203A_WLP_O.dat
#WS_BATCH

NSTEP=${NJOB}_15
#
#---------------------------------------------------------------
LIBEL="Remove temporary file"
RMFIL "${DFILT}/${NJOB}_${IB}_ESTR203A_ANO_O.dat"

NSTEP=${NJOB}_20
#Modif OG 01/10/02, l'edition ne sortira que ds INTRANET et plus sous papier
#---------------------------------------------------------------
LIBEL="Start printing"
WS_REPORT_NAME=ESTR2030
WS_PARAMS_TEXT << EOF
SSD_CF          ${SSD_CF}
ACTION          WEB
EOF
WS_INPUT_FILE=${DFILT}/${NJOB}_10_${IB}_ESTR203A_WLP_O.dat
#WS_REPORT

########################
# Erase temporary files #
########################

NSTEP=${NJOB}_25
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
