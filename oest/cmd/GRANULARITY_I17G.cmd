#!/bin/ksh
#==================================================================================
# nom de l'application          : ESTIMATIONS 
# nom du script SHELL           : GRANULARITY_I17G.cmd
# revision                      : $Revision: 1.0 $
# date de creation              : 19/11/2021
# auteur                        : JYP
#-----------------------------------------------------------------------------
#set -x


NORME2=$2
#NORME2=I17G

# Call generic functions
. ${DUTI}/fctgen.cmd


CHAININIT CNLD0030 $DENV/CNLD0030.env

NJOB=${ENV_PREFIX}_CNLD0030_CNLD0031

# Initialization of the Job
JOBINIT

echo "Starting $0 $1 $FLOG " 
echo "Starting $0 $1" >> $FLOG
date >> $FLOG

today=`date '+%Y%m%d' `


export ESF_FTECLEDA_OPNG="${DFILP}/${ENV_PREFIX}_ESFD2900_FTECLEDA_OPNG_${NORME2}.dat"
export ESF_FTECLEDR_OPNG="${DFILP}/${ENV_PREFIX}_ESFD2900_FTECLEDR_OPNG_${NORME2}.dat"
export ESF_FCTRI17PRD_NEW="${DFILP}/${ENV_PREFIX}_ESFD3940_${NORME2}_GRN_ALL_INI_FCTRI17PRD.dat"
export ESF_CANCEL_FTECLEDA_REJ="${DFILP}/${ENV_PREFIX}_ESFX7000_FTECLEDA_REJ_${NORME2}.dat"
export ESF_CANCEL_FTECLEDR_REJ="${DFILP}/${ENV_PREFIX}_ESFX7000_FTECLEDR_REJ_${NORME2}.dat"





# for dev only
if [ "${LOGNAME}" = "u007314" ]
then
    site="ubeu"
    echo "WARNING : run with forced user $site" >> $FLOG
else
    site=$LOGNAME
    echo "run with site = $site" >> $FLOG
fi




#====== product code prefix by norme 

case "${NORME2}" in
        "I17G") LETTER="G";;
        "I17L") LETTER="L";;
        "I17P") LETTER="P";;
        *) echo "wrong value for NORME: ${NORME2} " >> $FLOG  
       STEPEND 10;;
esac


case "${site}" in
        "ubas") PREFIX="~AS$LETTER" ;;
        "ubeu") PREFIX="~EU$LETTER" ;;
        "ubam") PREFIX="~AM$LETTER" ;;
        *) echo  "wrong value for site : ${site} " >> $FLOG
       STEPEND 20;;
esac

echo "run with PREFIX=$PREFIX " >> $FLOG


#====== check product code  file
if [ ! -f $ESF_FCTRI17PRD_NEW ]
then
echo "ERROR ESF_FCTRI17PRD_NEW=$ESF_FCTRI17PRD_NEW is missing " >> $FLOG
exit 11
fi



echo "============================== " >> $FLOG
if [ -f $ESF_FTECLEDA_OPNG ] 
then
wc -l $ESF_FTECLEDA_OPNG >> $FLOG 
nba=`grep -v "$PREFIX" $ESF_FTECLEDA_OPNG | wc -l `
nba2=`grep "$PREFIX" $ESF_FTECLEDA_OPNG | wc -l `
echo "BEFORE: $ESF_FTECLEDA_OPNG  => $nba prod_codes missing $nba2 codes ok" >> $FLOG 
gzip -c ${ESF_FTECLEDA_OPNG} > ${DARCH}/${ENV_PREFIX}_ESFD2900_FTECLEDA_OPNG_${NORME2}.dat_${today}_$$.gz

NJOB="ESFD3919_TTECLEDA_OPNG1"
${DCMD}/ESFD3819.cmd ${ESF_FTECLEDA_OPNG} ${ESF_FCTRI17PRD_NEW} 

wc -l $ESF_FTECLEDA_OPNG >> $FLOG 
nba=`grep -v "$PREFIX" $ESF_FTECLEDA_OPNG | wc -l `
nba2=`grep "$PREFIX" $ESF_FTECLEDA_OPNG | wc -l `
echo "AFTER: $ESF_FTECLEDA_OPNG  => $nba prod_codes missing $nba2 codes ok" >> $FLOG 

else
echo "WARNING ESF_FTECLEDA_OPNG=$ESF_FTECLEDA_OPNG missing or empty is NOT updated !!!!!"  >> $FLOG
fi


echo "============================== " >> $FLOG
if [ -f $ESF_FTECLEDR_OPNG ] 
then

wc -l $ESF_FTECLEDR_OPNG >> $FLOG 
nbr=`grep -v "$PREFIX" $ESF_FTECLEDR_OPNG | wc -l `
nbr2=`grep "$PREFIX" $ESF_FTECLEDR_OPNG | wc -l `
echo "BEFORE: $ESF_FTECLEDR_OPNG  => $nbr prod_codes missing $nbr2 codes ok" >> $FLOG 
gzip -c ${ESF_FTECLEDR_OPNG} > ${DARCH}/${ENV_PREFIX}_ESFD2900_FTECLEDR_OPNG_${NORME2}.dat_${today}_$$.gz

NJOB="ESFD3918_TTECLEDR_OPNG2"
echo "${DCMD}/ESFD3818.cmd ${ESF_FTECLEDR_OPNG} ${ESF_FCTRI17PRD_NEW} "
${DCMD}/ESFD3818.cmd ${ESF_FTECLEDR_OPNG} ${ESF_FCTRI17PRD_NEW}

wc -l $ESF_FTECLEDR_OPNG >> $FLOG 
nbr=`grep -v "$PREFIX" $ESF_FTECLEDR_OPNG | wc -l `
nbr2=`grep "$PREFIX" $ESF_FTECLEDR_OPNG | wc -l `
echo "AFTER: $ESF_FTECLEDR_OPNG  => $nbr prod_codes missing $nbr2 codes ok" >> $FLOG 

else
echo "WARNING ESF_FTECLEDR_OPNG=$ESF_FTECLEDR_OPNG missing or empty is NOT updated !!!!!"  >> $FLOG
fi




echo "============================== " >> $FLOG
if [ -f $ESF_CANCEL_FTECLEDA_REJ ]
then
wc -l $ESF_CANCEL_FTECLEDA_REJ >> $FLOG
nba=`grep -v "$PREFIX" $ESF_CANCEL_FTECLEDA_REJ | wc -l `
nba2=`grep "$PREFIX" $ESF_CANCEL_FTECLEDA_REJ | wc -l `
echo "BEFORE: $ESF_CANCEL_FTECLEDA_REJ  => $nba prod_codes missing $nba2 codes ok" >> $FLOG
gzip -c ${ESF_CANCEL_FTECLEDA_REJ} > ${DARCH}/${ENV_PREFIX}_ESFX7000_FTECLEDA_REJ_${NORME2}.dat_${today}_$$.gz

NJOB="ESFD3919_TTECLEDA_REJ3"
${DCMD}/ESFD3819.cmd ${ESF_CANCEL_FTECLEDA_REJ} ${ESF_FCTRI17PRD_NEW}

wc -l $ESF_CANCEL_FTECLEDA_REJ >> $FLOG
nba=`grep -v "$PREFIX" $ESF_CANCEL_FTECLEDA_REJ | wc -l `
nba2=`grep "$PREFIX" $ESF_CANCEL_FTECLEDA_REJ | wc -l `
echo "AFTER: $ESF_CANCEL_FTECLEDA_REJ  => $nba prod_codes missing $nba2 codes ok " >> $FLOG

else
echo "WARNING ESF_CANCEL_FTECLEDA_REJ=$ESF_CANCEL_FTECLEDA_REJ missing or empty is NOT updated !!!!!" >> $FLOG
fi



echo "============================== " >> $FLOG
if [ -f $ESF_CANCEL_FTECLEDR_REJ ]
then

wc -l $ESF_CANCEL_FTECLEDR_REJ >> $FLOG
nbr=`grep -v "$PREFIX" $ESF_CANCEL_FTECLEDR_REJ | wc -l `
nbr2=`grep "$PREFIX" $ESF_CANCEL_FTECLEDR_REJ | wc -l `
echo "BEFORE: $ESF_CANCEL_FTECLEDR_REJ  => $nbr prod_codes missing $nbr2 codes ok " >> $FLOG
gzip -c ${ESF_CANCEL_FTECLEDR_REJ} > ${DARCH}/${ENV_PREFIX}_ESFX7000_FTECLEDR_REJ_${NORME2}.dat_${today}_$$.gz

NJOB="ESFD3918_TTECLEDR_REJ4"
${DCMD}/ESFD3818.cmd ${ESF_CANCEL_FTECLEDR_REJ} ${ESF_FCTRI17PRD_NEW}

set -x
wc -l $ESF_CANCEL_FTECLEDR_REJ >> $FLOG
nbr=`grep -v "$PREFIX" $ESF_CANCEL_FTECLEDR_REJ | wc -l `
nbr2=`grep "$PREFIX" $ESF_CANCEL_FTECLEDR_REJ | wc -l `
echo "AFTER: $ESF_CANCEL_FTECLEDR_REJ  => $nbr prod_codes missing $nbr2 codes ok " >> $FLOG
set +x

else
echo "WARNING ESF_CANCEL_FTECLEDR_REJ=$ESF_CANCEL_FTECLEDR_REJ missing or empty is NOT updated !!!!!" >> $FLOG
fi
echo "============================== " >> $FLOG





echo "END status $? " >> $FLOG

JOBEND


