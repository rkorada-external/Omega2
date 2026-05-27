#!/bin/ksh
#==============================================================================
#nom de l'application          : EPROC Batch
#nom du source                 : CPEJ4021
#date de creation              : 22/06/2015
#auteur                        : BSONAL
#references des specifications :
#------------------------------------------------------------------------------
#description :
#      E-Processing PWA Auto Matching  
#==============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctws.cmd


# Get input parameters
# --------------------
DATE_T=$1
USR_CF=$2


# Job Initialisation
JOBINIT


NSTEP=${NJOB}_05
# Begin webservice
#----------------------------------------------------------------------------
LIBEL="EPROC batch"
WS_BATCH_NAME=CPEJ4020
WS_PARAMS_TEXT << EOF
USR_CF          ${USR_CF}
DATE_T          ${DATE_T}
EOF
WS_OUTPUT_FILE=${DFILT}/${NSTEP}_${IB}_${WS_BATCH_NAME}_O.dat
WS_BATCH
# END of JOB
JOBEND

