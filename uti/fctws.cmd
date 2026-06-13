#!/bin/ksh
#=============================================================================
# Application name             : technical library
# Source name                  : fctws
# Creation date                : 2013-02-25
#------------------------------------------------------------------------------
# Description:
#       Generic functions that Web Service calls for batch and report execution
#
#       - WS_BATCH
#       - WS_REPORT
#       - WS_PARAMS_TEXT
#       - WS_LIST_RUNNING_BATCHES
#       - WS_STOP_BATCH
#       - WS_LIST_RUNNING_REPORTS
#       - WS_STOP_REPORT
#       - GET_MAILID_FROMUSER
#
#------------------------------------------------------------------------------
# Modifications history :
#   <yyyy-mm-dd>   <user>    <comment>
#
#----------------------------------------------------------------------------

# Functions directory
DFUNCTION=${DUTI}/functions/fctws

# Import functions definition
. ${DFUNCTION}/WS_CALL
. ${DFUNCTION}/WS_BATCH
. ${DFUNCTION}/WS_LIST_RUNNING_BATCHES
. ${DFUNCTION}/WS_LIST_RUNNING_REPORTS
. ${DFUNCTION}/WS_PARAMS_TEXT
. ${DFUNCTION}/WS_REPORT
. ${DFUNCTION}/WS_STOP_BATCH
. ${DFUNCTION}/WS_STOP_REPORT
