#!/bin/ksh
#==================================================================================
# nom de l'application          : ESTIMATIONS 
# date de creation              : 05/10/2020
# auteur                        : Mr JYP
#-----------------------------------------------------------------------------
# [001] 16/12/2020 JYP: SPIRA 90059 rename DSC RateIndex file
#set -x

PARM_DATE1=$2
PARM_DATE2=$3

# Call generic functions
. ${DUTI}/fctgen.cmd

CHAININIT CNLD0030 $DENV/CNLD0030.env




if [ "$PARM_DATE1" != "" ]
then
        PARM_ICLODAT_D=$PARM_DATE1
else
        PARM_ICLODAT_D=`grep "PARM_ICLODAT_D=" $DFILP/${ENV_PREFIX}_ESFJ0000_PARM.dat | cut -d"=" -f2 `
fi

if [ "$PARM_DATE2" != "" ]
then
        PARM_PREV_ICLODAT_D=$PARM_DATE2
else
        PARM_PREV_ICLODAT_D=`grep "PARM_PREV_ICLODAT_D=" $DFILP/${ENV_PREFIX}_ESFJ0000_PARM.dat | cut -d"=" -f2 `
fi



if [ "${PARM_ICLODAT_D}" != "" -a "${PARM_PREV_ICLODAT_D}" != "" ]
then
        echo "OK: run with PARM_ICLODAT_D=$PARM_ICLODAT_D PARM_PREV_ICLODAT_D=$PARM_PREV_ICLODAT_D"  >> $FLOG
        echo "OK: run with PARM_ICLODAT_D=$PARM_ICLODAT_D PARM_PREV_ICLODAT_D=$PARM_PREV_ICLODAT_D" 
else
        echo "error cannot use PARM_ICLODAT_D=$PARM_ICLODAT_D PARM_PREV_ICLODAT_D=$PARM_PREV_ICLODAT_D file=${DFILP}/${ENV_PREFIX}_ESFJ0000_PARM.dat  "  >> $FLOG
        echo "error cannot use PARM_ICLODAT_D=$PARM_ICLODAT_D PARM_PREV_ICLODAT_D=$PARM_PREV_ICLODAT_D file=${DFILP}/${ENV_PREFIX}_ESFJ0000_PARM.dat  "  
        exit 11
fi



NJOB=${ENV_PREFIX}_ESID2210_90054

# Initialization of the Job
JOBINIT

echo "Starting $0 $1 $FLOG " 
echo "Starting $0 $1" >> $FLOG
date >> $FLOG


NSTEP=${NCHAIN}_${NJOB}_05
LIBEL="rename file  "


set -x



if [ ! -f ${DFILP}/${ENV_PREFIX}_ESFD1130_TRERETFACCTR_I17G_${PARM_PREV_ICLODAT_D}.dat   ]
then
  if [ -f ${DFILP}/${ENV_PREFIX}_ESFD1130_TRERETFACCTR_${PARM_PREV_ICLODAT_D}.dat ]
  then
    cp ${DFILP}/${ENV_PREFIX}_ESFD1130_TRERETFACCTR_${PARM_PREV_ICLODAT_D}.dat ${DFILP}/${ENV_PREFIX}_ESFD1130_TRERETFACCTR_I17G_${PARM_PREV_ICLODAT_D}.dat
  fi
fi


if [ ! -f ${DFILP}/${ENV_PREFIX}_ESFD1130_TRERETFACCTR_I17G_${PARM_ICLODAT_D}.dat   ]
then
  if [ -f ${DFILP}/${ENV_PREFIX}_ESFD1130_TRERETFACCTR_${PARM_ICLODAT_D}.dat ]
  then
    cp ${DFILP}/${ENV_PREFIX}_ESFD1130_TRERETFACCTR_${PARM_ICLODAT_D}.dat ${DFILP}/${ENV_PREFIX}_ESFD1130_TRERETFACCTR_I17G_${PARM_ICLODAT_D}.dat
  fi
fi





set +x

echo "End of script OK status $? " >> $FLOG
echo "End of script OK status $? " 

JOBEND


