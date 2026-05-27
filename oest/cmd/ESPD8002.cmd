#!/bin/ksh
#=============================================================================
# nom de l'application          : EBS INI(TL and cashflow data aggregation)
# nom du script SHELL           : ESPD8002.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 12/02/2026
# auteur                        : MZM
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  US 7847 : EBS INI TSECEBSINI table update
#
#-----------------------------------------------------------------------------
#[001] 
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
ECHO_LOG "#===> ESF_FSECEBSINI.......................................: ${ESF_FSECEBSINI}"
ECHO_LOG "#===> ESF_FRETEBSINI.......................................: ${ESF_FRETEBSINI}"
ECHO_LOG "#========================================================================="



NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="Delete data from Working Table BTRAV..ESFD8000_TSECEBSINI"
ISQL_BASE="BTRAV"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="Delete BTRAV..ESFD8000_TSECEBSINI"
ISQL

NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="Load file into the working table BTRAV..ESFD8000_TSECEBSINI"
BCP_WAY="IN"
BCP_VER=""
BCP_I="${ESF_FSECEBSINI}"
BCP_TABLE="BTRAV..ESFD8000_TSECEBSINI"
BCP

NSTEP=${NJOB}_15
#------------------------------------------------------------------------------
LIBEL="Update table BFAC..TSECIFRS"
ISQL_BASE="BFAC"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="exec PuSECIFRS_04 '${NORME_CF}'"
ISQL


##NSTEP=${NJOB}_25
###------------------------------------------------------------------------------
##LIBEL="Delete data from Working Table BTRAV..ESFD8000_TSECEBSINI"
##ISQL_BASE="BTRAV"
##ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
##ISQL_QRY="Delete BTRAV..ESFD8000_TSECEBSINI"
##ISQL
##
##
##NSTEP=${NJOB}_30
###------------------------------------------------------------------------------
##LIBEL="Load file into the working table BTRAV..ESFD8000_TSECEBSINI"
##BCP_WAY="IN"
##BCP_VER=""
##BCP_I="${ESF_FSECEBSINI}"
##BCP_TABLE="BTRAV..ESFD8000_TSECEBSINI"
##BCP


NSTEP=${NJOB}_35
#------------------------------------------------------------------------------
LIBEL="Update table BTRT..TSECEBSINI"
ISQL_BASE="BTRT"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="exec PuSECIFRS_04 '${NORME_CF}'"
ISQL


## BRET UPDATE

NSTEP=${NJOB}_50
#------------------------------------------------------------------------------
LIBEL="Delete data from Working Table BTRAV..ESFD8000_TRETEBSINI"
ISQL_BASE="BTRAV"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="Delete BTRAV..ESFD8000_TRETEBSINI"
ISQL

NSTEP=${NJOB}_55
#------------------------------------------------------------------------------
LIBEL="Load file into the working table BTRAV..ESFD8000_TRETEBSINI"
BCP_WAY="IN"
BCP_VER=""
BCP_I="${ESF_FRETEBSINI}"
BCP_TABLE="BTRAV..ESFD8000_TRETEBSINI"
BCP

NSTEP=${NJOB}_60
#------------------------------------------------------------------------------
LIBEL="Update table BRET..TRETIFRS"
ISQL_BASE="BRET"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="exec PuRETIFRS_01 '${NORME_CF}'"
ISQL


JOBEND
