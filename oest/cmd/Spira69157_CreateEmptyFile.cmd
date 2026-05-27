#!/bin/ksh
#=============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

CHAININIT CNLD0030 CNLD0000.env

NJOB=${ENV_PREFIX}_CNLD0030_CNLD0031

# Initialization of the Job
JOBINIT

echo $FLOG

echo  "Starting $0 ... " > $FLOG
date >> $FLOG

filename=$DFILP/empty.dat
echo "filename=$filename" >> $FLOG

if [ ! -f $filename -o ! -r $filename ]
then
   touch $filename
   chmod 644 $filename
   echo "creating the missing file $filename" >> $FLOG
else
   echo "$filename already exists "   >> $FLOG
fi

echo "End $0 status=$? " >> $FLOG



