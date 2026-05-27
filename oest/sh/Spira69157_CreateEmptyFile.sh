#!/bin/ksh
#=============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

NJOB=${ENV_PREFIX}_CNLD0030_CNLD0031

# Initialization of the Job
JOBINIT


filename=$DFILP/empty.dat
echo "filename=$filename"

if [ ! -f $filename -o ! -r $filename ]
then
   touch $filename
   chmod 644 $filename
   echo "creating the missing file $filename"
else
   echo "$filename already exists "   
fi

JOBEND

