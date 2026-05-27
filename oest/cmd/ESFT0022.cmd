#!/bin/ksh
#=============================================================================
# nom de l'application          : I17G - Transition File generation
# nom du script SHELL           : ESFT0022.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 18\11\2020
# auteur                        : Arnaud RUFFAULT
#-----------------------------------------------------------------------------

#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT



# Get input parameters

ECHO_LOG "#========================================================================="

ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> TRANSITION_FILE..............................................: ${TRANSITION_FILE}"

ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="Delete data from Working Table BTRAV..ESFT0020_TRANSITION_FILE"
ISQL_BASE="BTRAV"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="Delete BTRAV..ESFT0020_TRANSITION_FILE"
ISQL

NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="Load transition file into the working table BTRAV..ESFT0020_TRANSITION_FILE"
BCP_WAY="IN"
BCP_VER=""
BCP_I="${TRANSITION_FILE}"
BCP_TABLE="BTRAV..ESFT0020_TRANSITION_FILE"
BCP

JOBEND
