#!/bin/ksh
#==================================================================================
# nom de l'application          : ESTIMATIONS 
# date de creation              : 05/10/2020
# auteur                        : Mr JYP
#-----------------------------------------------------------------------------
# [001] 15/10/2020 JYP: SPIRA 88975 init micro AOC files  
# [002] 21/10/2020 JYP: SPIRA 83609 init micro AOC files  
# [003] 22/10/2020 JYP: SPIRA 83609 init micro AOC Q-1 files  
# [004] 28/10/2020 JYP: SPIRA 83609 init micro AOC Q-1 files 
# [005] 12/11/2020 JYP: SPIRA 83609 init microAOC, Q-1 files RATE index
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



NJOB=${ENV_PREFIX}_ESID2210_MICROAOC

# Initialization of the Job
JOBINIT

echo "Starting $0 $1 $FLOG " 
echo "Starting $0 $1" >> $FLOG
date >> $FLOG


NSTEP=${NCHAIN}_${NJOB}_05
LIBEL="Init some empty files for MicroAOC  "


for typeaoc in `echo "AA0" "AA1" "AA2" "AA3" `
do
 echo "Init $typeaoc "
 echo "Init $typeaoc " >> $FLOG

touch ${DFILP}/${ENV_PREFIX}_ESFD2550_EBS_ESFD2550___${typeaoc}_DLRIGTAACO.dat
touch ${DFILP}/${ENV_PREFIX}_ESFD2550_EBS_ESFD2550___${typeaoc}_DLDVGTRCO.dat
touch ${DFILP}/${ENV_PREFIX}_ESFD2550_EBS_ESFD2550___${typeaoc}_DLRGTAACO.dat
touch ${DFILP}/${ENV_PREFIX}_ESFD2550_EBS_ESFD2550___${typeaoc}_DLREMAJGTARCO.dat
touch ${DFILP}/${ENV_PREFIX}_ESFD2550_EBS_ESFD2550___${typeaoc}_DLREMAJGTRCO.dat
touch ${DFILP}/${ENV_PREFIX}_ESFD2550_EBS_ESFD2550___${typeaoc}_DLREGTRCO.dat
touch ${DFILP}/${ENV_PREFIX}_ESFD2550_EBS_ESFD2550___${typeaoc}_DLREGTARCO.dat
touch ${DFILP}/${ENV_PREFIX}_ESFD2550_EBS_ESFD2550___${typeaoc}_DLREGTARSIICO.dat
touch ${DFILP}/${ENV_PREFIX}_ESFD2550_EBS_ESFD2550___${typeaoc}_DLREMAJGTARSIICO.dat

touch ${DFILP}/${ENV_PREFIX}_ESFD2550_EBS_ESFD2550___${typeaoc}_DLRIGTAASO.dat
touch ${DFILP}/${ENV_PREFIX}_ESFD2550_EBS_ESFD2550___${typeaoc}_DLDVGTRSO.dat
touch ${DFILP}/${ENV_PREFIX}_ESFD2550_EBS_ESFD2550___${typeaoc}_DLRGTAASO.dat
touch ${DFILP}/${ENV_PREFIX}_ESFD2550_EBS_ESFD2550___${typeaoc}_DLREMAJGTARSO.dat
touch ${DFILP}/${ENV_PREFIX}_ESFD2550_EBS_ESFD2550___${typeaoc}_DLREMAJGTRSO.dat
touch ${DFILP}/${ENV_PREFIX}_ESFD2550_EBS_ESFD2550___${typeaoc}_DLREGTRSO.dat
touch ${DFILP}/${ENV_PREFIX}_ESFD2550_EBS_ESFD2550___${typeaoc}_DLREGTARSO.dat
touch ${DFILP}/${ENV_PREFIX}_ESFD2550_EBS_ESFD2550___${typeaoc}_DLREGTARSIISO.dat
touch ${DFILP}/${ENV_PREFIX}_ESFD2550_EBS_ESFD2550___${typeaoc}_DLREMAJGTARSIISO.dat

touch ${DFILP}/${ENV_PREFIX}_ESFD3620_I17G_DSC_LKI_STD_${typeaoc}_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat
touch ${DFILP}/${ENV_PREFIX}_ESFD3620_I17G_RAD_LKI_STD_${typeaoc}_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat

done



# remove old IDF_CT files 
rm -f $DFILP/${ENV_PREFIX}_ES?D????_AA0_*dat*


ls -ltr ${DFILP}/${ENV_PREFIX}_ESFD2550_EBS*
ls -ltr ${DFILP}/${ENV_PREFIX}_ESFD2550_EBS* >> $FLOG

set -x



if [ ! -f ${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_ICR_${PARM_ICLODAT_D}.dat  ]
then
  if [ -f ${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_ICR.dat ]
  then
    cp ${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_ICR.dat ${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_ICR_${PARM_ICLODAT_D}.dat
  fi
fi



if [ ! -f ${DFILP}/${ENV_PREFIX}_ESFD1130_FSEGPATTERNDSCf17_${PARM_ICLODAT_D}.dat  ]
then
  if [ -f ${DFILP}/${ENV_PREFIX}_ESFD1130_FSEGPATTERNDSCf17.dat  ]
  then
    cp ${DFILP}/${ENV_PREFIX}_ESFD1130_FSEGPATTERNDSCf17.dat  ${DFILP}/${ENV_PREFIX}_ESFD1130_FSEGPATTERNDSCf17_${PARM_ICLODAT_D}.dat
  fi
fi


if [ ! -f ${DFILP}/${ENV_PREFIX}_ESFD1130_FRERETFACCTR_INI_${PARM_ICLODAT_D}.dat  ]
then
  if [ -f ${DFILP}/${ENV_PREFIX}_ESFD1130_FRERETFACCTR_INI.dat  ]
  then
    cp ${DFILP}/${ENV_PREFIX}_ESFD1130_FRERETFACCTR_INI.dat  ${DFILP}/${ENV_PREFIX}_ESFD1130_FRERETFACCTR_INI_${PARM_ICLODAT_D}.dat
  fi
fi


if [ ! -f ${DFILP}/${ENV_PREFIX}_ESFD1130_TRERETFACCTR_${PARM_ICLODAT_D}.dat  ]
then
  if [ -f ${DFILP}/${ENV_PREFIX}_ESFD1130_TRERETFACCTR.dat  ]
  then
    cp ${DFILP}/${ENV_PREFIX}_ESFD1130_TRERETFACCTR.dat ${DFILP}/${ENV_PREFIX}_ESFD1130_TRERETFACCTR_${PARM_ICLODAT_D}.dat
  fi
fi



set +x

echo "End of script OK status $? " >> $FLOG
echo "End of script OK status $? " 

JOBEND


