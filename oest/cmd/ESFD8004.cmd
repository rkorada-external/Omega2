#!/bin/ksh
#=============================================================================
# nom de l'application          : I17G -APP4 (TL and cashflow data aggregation)
# nom du script SHELL           : ESF8004.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 20\04\2019
# auteur                        : Nicolas Briand
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  IFRS17 REQ 12.3 : TRETIFRS tables update
#
#-----------------------------------------------------------------------------
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Get input parameters

ECHO_LOG "#========================================================================="
ECHO_LOG "#===> NORME_CF...........................................: ${NORME_CF}"

ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> ESF_FRETIFRS.......................................: ${ESF_FRETIFRS}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="Delete data from Working Table BTRAV..ESFD8000_TRETIFRS"
ISQL_BASE="BTRAV"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="Delete BTRAV..ESFD8000_TRETIFRS"
ISQL

NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="Load file into the working table BTRAV..ESFD8000_TRETIFRS"
BCP_WAY="IN"
BCP_VER=""
BCP_I="${ESF_FRETIFRS}"
BCP_TABLE="BTRAV..ESFD8000_TRETIFRS"
BCP

NSTEP=${NJOB}_15
#------------------------------------------------------------------------------
#LIBEL="Update table BRET..TRETIFRS"
ISQL_BASE="BRET"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="exec PuRETIFRS_01 '${NORME_CF}'"
ISQL

JOBEND
