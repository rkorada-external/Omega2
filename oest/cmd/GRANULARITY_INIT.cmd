#!/bin/ksh
#==================================================================================
# nom de l'application          : ESTIMATIONS 
# nom du script SHELL           : GRANULARITY_INIT
# revision                      : $Revision: 1.0 $
# date de creation              : 09/10/2020
# auteur                        : JYP
#-----------------------------------------------------------------------------
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

CHAININIT CNLD0030 $DENV/CNLD0030.env

NJOB=${ENV_PREFIX}_CNLD0030_CNLD0031

# Initialization of the Job
JOBINIT

echo "Starting $0 $1 $FLOG " 
echo "Starting $0 $1" >> $FLOG
date >> $FLOG


NSTEP=${NCHAIN}_${NJOB}_05
LIBEL="Init some empty files for Granularity  "


touch ${DFILP}/${ENV_PREFIX}_ESFD3940_I17G_GRN_ALL_INI_FCTRI17PRD.dat
touch ${DFILP}/${ENV_PREFIX}_ESFD3940_I17G_GRN_ALL_INI_FI17PRODUCT.dat

ls -ltr ${DFILP}/${ENV_PREFIX}_ESFD3940_*
ls -ltr ${DFILP}/${ENV_PREFIX}_ESFD3940_*  >> $FLOG


echo $? >> $FLOG

JOBEND


