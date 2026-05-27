#!/bin/ksh
#=============================================================================
# nom de l'application          : I17G - Transition File generation
# nom du script SHELL           : ESFT0021.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 29\06\2020
# auteur                        : Arnaud RUFFAULT
#-----------------------------------------------------------------------------
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctjsb.cmd

# Job Initialisation
JOBINIT


NUMBEROFCOL=$(awk -F~ '{print NF }' ${TRANSITION_INPUT_FILE} | sort -u)

ECHO_LOG "#========================================================================="
ECHO_LOG "#===> NORME_CF.........................................................: ${NORME_CF}"
ECHO_LOG "#===> NUMBEROFCOL......................................................: ${NUMBEROFCOL}"

ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> TRANSITION_INPUT_FILE............................................: ${TRANSITION_INPUT_FILE}"

ECHO_LOG "#===> ............ OUTPUT ................................................"
ECHO_LOG "#===> TRANSITION_OUTPUT_FILE...........................................: ${TRANSITION_OUTPUT_FILE}"
ECHO_LOG "#===> BUSINESS_LOGS....................................................: ${BUSINESS_LOGS}"
ECHO_LOG "#========================================================================="

if [ -s ${BUSINESS_LOGS} ]
then
NSTEP=${NJOB}_1
#------------------------------------------------------------------------------
LIBEL="empty log file"
RMFIL "${BUSINESS_LOGS}"

fi

if [ ! -s ${BUSINESS_LOGS} ]
then
NSTEP=${NJOB}_2
#------------------------------------------------------------------------------
LIBEL="touch ${BUSINESS_LOGS}"
EXECKSH "touch ${BUSINESS_LOGS}"

fi

if [ "${NUMBEROFCOL}" == "31" ]
then
NSTEP=${NJOB}_3
#------------------------------------------------------------------------------

# inputs files
export ESTJ0000_TRANSITION_INPUT_FILE="${TRANSITION_INPUT_FILE}"


# tmp files
export ESTJ0000_BUSINESS_LOGS="${BUSINESS_LOGS}"

# outputs files
export ESTJ0000_TRANSITION_OUTPUT_FILE="${TRANSITION_OUTPUT_FILE}"

# Jar execution
JSB_CHAIN="estj0000"
JSB_PARAMS="normcf=${NORME_CF}"
#JSB_JAR_PATH="${DEXE}/OMEGA-IFRS17-0.0.1-SNAPSHOT.jar"
EXECJSB

else 

NSTEP=${NJOB}_3B
#------------------------------------------------------------------------------
LIBEL="edit ${BUSINESS_LOGS}"
EXECKSH_MODE=A
EXECKSH_O=${BUSINESS_LOGS}
EXECKSH "echo file do not have 31 columns in each line"

fi 

if [ -s ${BUSINESS_LOGS} ]
then 
NSTEP=${NJOB}_4
#------------------------------------------------------------------------------
LIBEL="clean transition file if log file is not empty"
RMFIL ${TRANSITION_OUTPUT_FILE}

NSTEP=${NJOB}_4B
#------------------------------------------------------------------------------
LIBEL="touch ${TRANSITION_OUTPUT_FILE}"
EXECKSH "touch ${TRANSITION_OUTPUT_FILE}"

fi

NSTEP=${NJOB}_5
#------------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*${IB}*.dat "

JOBEND
