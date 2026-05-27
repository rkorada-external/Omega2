#!/bin/ksh
#==================================================================================
# nom de l'application          : ESTIMATIONS 
# date de creation              : 18/12/2020
# auteur                        : Arnaud RUFFAULT
#-----------------------------------------------------------------------------

# Call generic functions
. ${DUTI}/fctgen.cmd

PARM_ICLODAT_D=`grep "PARM_ICLODAT_D=" $DFILP/${ENV_PREFIX}_ESFJ0000_PARM.dat | cut -d"=" -f2 `
PARM_PREV_ICLODAT_D=`grep "PARM_PREV_ICLODAT_D=" $DFILP/${ENV_PREFIX}_ESFJ0000_PARM.dat | cut -d"=" -f2 `

if [ "${PARM_ICLODAT_D}" != "" -a "${PARM_PREV_ICLODAT_D}" != "" ]
then
        echo "OK: run with PARM_ICLODAT_D=$PARM_ICLODAT_D PARM_PREV_ICLODAT_D=$PARM_PREV_ICLODAT_D"  >> $FLOG
        echo "OK: run with PARM_ICLODAT_D=$PARM_ICLODAT_D PARM_PREV_ICLODAT_D=$PARM_PREV_ICLODAT_D" 
else
        echo "error cannot use PARM_ICLODAT_D=$PARM_ICLODAT_D PARM_PREV_ICLODAT_D=$PARM_PREV_ICLODAT_D file=${DFILP}/${ENV_PREFIX}_ESFJ0000_PARM.dat  "  >> $FLOG
        echo "error cannot use PARM_ICLODAT_D=$PARM_ICLODAT_D PARM_PREV_ICLODAT_D=$PARM_PREV_ICLODAT_D file=${DFILP}/${ENV_PREFIX}_ESFJ0000_PARM.dat  "  
        exit 11
fi


if [ ! -f ${DFILP}/${ENV_PREFIX}_ESFD1130_FSEGPATTERNDSCf17_I17G_${PARM_PREV_ICLODAT_D}.dat   ]
then
  if [ -f ${DFILP}/${ENV_PREFIX}_ESFD1130_FSEGPATTERNDSCf17_${PARM_PREV_ICLODAT_D}.dat ]
  then
    cp ${DFILP}/${ENV_PREFIX}_ESFD1130_FSEGPATTERNDSCf17_${PARM_PREV_ICLODAT_D}.dat ${DFILP}/${ENV_PREFIX}_ESFD1130_FSEGPATTERNDSCf17_I17G_${PARM_PREV_ICLODAT_D}.dat
  fi
fi


if [ ! -f ${DFILP}/${ENV_PREFIX}_ESFD1130_FSEGPATTERNDSCf17_I17G_${PARM_ICLODAT_D}.dat   ]
then
  if [ -f ${DFILP}/${ENV_PREFIX}_ESFD1130_FSEGPATTERNDSCf17_${PARM_ICLODAT_D}.dat ]
  then
    cp ${DFILP}/${ENV_PREFIX}_ESFD1130_FSEGPATTERNDSCf17_${PARM_ICLODAT_D}.dat ${DFILP}/${ENV_PREFIX}_ESFD1130_FSEGPATTERNDSCf17_I17G_${PARM_ICLODAT_D}.dat
  fi
fi





