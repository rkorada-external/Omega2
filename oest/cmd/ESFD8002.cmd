#!/bin/ksh
#=================================================================================
# nom de l'application          : 
# nom du script SHELL           : ESFD8002.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 25\11\2022
# auteur                        : Suraj Patil
#---------------------------------------------------------------------------------
# description
# Update/Insert of BEST..TI17CTRSML table
# [001] 30/07/2024 DAD - 111515 - Delete of BEST..TI17CTRSML table
#---------------------------------------------------------------------------------
#=================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Get input parameters

ECHO_LOG "#========================================================================="
ECHO_LOG "#===> NORME_CF...........................................: ${NORME_CF}"
ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> ESF_FSECIFRS.......................................: ${ESF_FSECIFRS}"
ECHO_LOG "#===> ESF_PI_UPDATE_TSECIFRS.............................: ${ESF_PI_UPDATE_TSECIFRS}"
ECHO_LOG "#===> ESF_FRETIFRS.......................................: ${ESF_FRETIFRS}"
ECHO_LOG "#===> ESF_FSECIFRS_LIGHT.................................: ${ESF_FSECIFRS_LIGHT}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_01
#------------------------------------------------------------------------------
LIBEL="Delete data from the working table BEST..TI17CTRSML"
ISQL_BASE="BTRAV"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="Delete BEST..TI17CTRSML"
ISQL

NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="Delete data from the working table BTRAV..ESFD8000_TSECIFRS"
ISQL_BASE="BTRAV"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="Delete BTRAV..ESFD8000_TSECIFRS"
ISQL

NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="Load the input file ESF_FSECIFRS in the working table BTRAV..ESFD8000_TSECIFRS"
BCP_WAY="IN"
BCP_VER=""
BCP_I="${ESF_FSECIFRS}"
BCP_TABLE="BTRAV..ESFD8000_TSECIFRS"
BCP

NSTEP=${NJOB}_15
#------------------------------------------------------------------------------
LIBEL="update the table BEST..TI17CTRSML by ESF_FSECIFRS file"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="exec PuI17CTRSML_01"
ISQL

NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="Delete data from the working table BTRAV..ESFD8000_TSECIFRS"
ISQL_BASE="BTRAV"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="Delete BTRAV..ESFD8000_TSECIFRS"
ISQL

NSTEP=${NJOB}_25
#------------------------------------------------------------------------------
LIBEL=" Load the input file ESF_PI_UPDATE_TSECIFRS in the working table BTRAV..ESFD8000_TSECIFRS "
BCP_WAY="IN"
BCP_VER=""
BCP_I="${ESF_PI_UPDATE_TSECIFRS}"
BCP_TABLE="BTRAV..ESFD8000_TSECIFRS"
BCP

NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
LIBEL="update the table BEST..TI17CTRSML by ESF_PI_UPDATE_TSECIFRS file"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="exec PuI17CTRSML_01"
ISQL

NSTEP=${NJOB}_35
#------------------------------------------------------------------------------
LIBEL="Delete data from the working table BTRAV..ESFD8000_TSECIFRS"
ISQL_BASE="BTRAV"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="Delete BTRAV..ESFD8000_TSECIFRS"
ISQL

NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
LIBEL="Load the input file ESF_FSECIFRS_LIGHT in the working table BTRAV..ESFD8000_TSECIFRS "
BCP_WAY="IN"
BCP_VER=""
BCP_I="${ESF_FSECIFRS_LIGHT}"
BCP_TABLE="BTRAV..ESFD8000_TSECIFRS"
BCP

NSTEP=${NJOB}_45
#------------------------------------------------------------------------------
LIBEL="update the table BEST..TI17CTRSML by ESF_FSECIFRS_LIGHT file"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="exec PuI17CTRSML_01"
ISQL

NSTEP=${NJOB}_50
#------------------------------------------------------------------------------
LIBEL="Delete data from the working table BTRAV..ESFD8000_TRETIFRS"
ISQL_BASE="BTRAV"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="Delete BTRAV..ESFD8000_TRETIFRS"
ISQL

NSTEP=${NJOB}_55
#------------------------------------------------------------------------------
LIBEL="Load the input file ESF_FRETIFRS in the working table BTRAV..ESFD8000_TRETIFRS "
BCP_WAY="IN"
BCP_VER=""
BCP_I="${ESF_FRETIFRS}"
BCP_TABLE="BTRAV..ESFD8000_TRETIFRS"
BCP

NSTEP=${NJOB}_60
#------------------------------------------------------------------------------
LIBEL="update the table BEST..TI17CTRSML by ESF_FRETIFRS file"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="exec PuI17CTRSML_02"
ISQL

JOBEND
