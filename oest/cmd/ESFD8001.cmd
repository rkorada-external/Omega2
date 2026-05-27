#!/bin/ksh
#=============================================================================
# nom de l'application          : I17G -APP4 (TL and cashflow data aggregation)
# nom du script SHELL           : ESF8001.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 18\09\2019
# auteur                        : Antoine GRUNWALD
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  IFRS17 REQ 12.3 : TSECIFRS table update
#
#-----------------------------------------------------------------------------
#[001] 08/09/2020 JYP : Spira 83614 : add ESF_FI17PRODUCT 
#[002] 11/09/2020 JYP : Spira 83614 : manage product by site 
#[003] 02/02/2021 JYP : Spira 91991 : manage product by norme I17G/P/L
#[004] 17/02/2021 CAS : Spira 90090 : add a new rule for multi-year contracts
#[005] 02/02/2022 JYP : SPIRA 101782: remove granularity product code
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Get input parameters

ECHO_LOG "#========================================================================="
ECHO_LOG "#===> NORME_CF...........................................: ${NORME_CF}"
ECHO_LOG "#===> PARM_BATCHUSER.....................................: ${PARM_BATCHUSER}"

ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> ESF_FSECIFRS.......................................: ${ESF_FSECIFRS}"
ECHO_LOG "#===> ESF_PI_UPDATE_TSECIFRS.............................: ${ESF_PI_UPDATE_TSECIFRS}"
ECHO_LOG "#===> ESF_FSECIFRS_LIGHT.................................: ${ESF_FSECIFRS_LIGHT}"
ECHO_LOG "#========================================================================="



NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="Delete data from Working Table BTRAV..ESFD8000_TSECIFRS"
ISQL_BASE="BTRAV"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="Delete BTRAV..ESFD8000_TSECIFRS"
ISQL

NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="Load file into the working table BTRAV..ESFD8000_TSECIFRS"
BCP_WAY="IN"
BCP_VER=""
BCP_I="${ESF_FSECIFRS}"
BCP_TABLE="BTRAV..ESFD8000_TSECIFRS"
BCP

NSTEP=${NJOB}_15
#------------------------------------------------------------------------------
LIBEL="Update table BTRT..TSECIFRS"
ISQL_BASE="BTRT"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="exec PuSECIFRS_01 '${NORME_CF}'"
ISQL

NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="Update table BFAC..TSECIFRS"
ISQL_BASE="BFAC"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="exec PuSECIFRS_01 '${NORME_CF}'"
ISQL

NSTEP=${NJOB}_25
#------------------------------------------------------------------------------
LIBEL="Delete data from Working Table BTRAV..ESFD8000_TSECIFRS"
ISQL_BASE="BTRAV"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="Delete BTRAV..ESFD8000_TSECIFRS"
ISQL

NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
LIBEL="Load file into the working table BTRAV..ESFD8000_TSECIFRS"
BCP_WAY="IN"
BCP_VER=""
BCP_I="${ESF_PI_UPDATE_TSECIFRS}"
BCP_TABLE="BTRAV..ESFD8000_TSECIFRS"
BCP

NSTEP=${NJOB}_35
#------------------------------------------------------------------------------
LIBEL="Update table BTRT..TSECIFRS"
ISQL_BASE="BTRT"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="exec PuSECIFRS_03 '${NORME_CF}'"
ISQL



NSTEP=${NJOB}_50
#------------------------------------------------------------------------------
LIBEL="Delete data from Working Table BTRAV..ESFD8000_TSECIFRS"
ISQL_BASE="BTRAV"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="Delete BTRAV..ESFD8000_TSECIFRS"
ISQL

NSTEP=${NJOB}_55
#------------------------------------------------------------------------------
LIBEL="Load file into the working table BTRAV..ESFD8000_TSECIFRS"
BCP_WAY="IN"
BCP_VER=""
BCP_I="${ESF_FSECIFRS_LIGHT}"
BCP_TABLE="BTRAV..ESFD8000_TSECIFRS"
BCP

NSTEP=${NJOB}_60
#------------------------------------------------------------------------------
LIBEL="Update table BTRT..TSECIFRS"
ISQL_BASE="BTRT"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="exec PuSECIFRS_04 '${NORME_CF}'"
ISQL

NSTEP=${NJOB}_65
#------------------------------------------------------------------------------
LIBEL="Update table BFAC..TSECIFRS"
ISQL_BASE="BFAC"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="exec PuSECIFRS_04 '${NORME_CF}'"
ISQL

JOBEND
