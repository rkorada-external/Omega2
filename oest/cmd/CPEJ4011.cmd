#!/bin/ksh
#==============================================================================
#nom de l'application          : EPROC Batch
#nom du source                 : CPEJ4011
#date de creation              : 22/06/2015
#auteur                        : BSONAL
#references des specifications :
#------------------------------------------------------------------------------
#description :
#       Daily EPROC Batch
#==============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctws.cmd


# Get input parameters
# --------------------
USR_CF=$1
NBR_DAY=$2


# Job Initialisation
JOBINIT


NSTEP=${NJOB}_05
# Begin webservice
#----------------------------------------------------------------------------
LIBEL="EPROC batch"
WS_BATCH_NAME=CPEJ4010
WS_PARAMS_TEXT << EOF
USR_CF          ${USR_CF}
NBR_DAY          ${NBR_DAY}
EOF
WS_OUTPUT_FILE=${DFILT}/${NSTEP}_${IB}_${WS_BATCH_NAME}_O.dat
WS_BATCH
# END of JOB
JOBEND

