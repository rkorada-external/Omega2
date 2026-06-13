#!/bin/ksh
# rm de fichiers generalise
# set -x
if [ ! -d "$1" ]
then
   RM_FILE=`basename "$1"`
   if [ "${RM_FILE}" != "" ]  && [ "${RM_FILE}" != '*' ]
   then
       /bin/rm -f $1 2>&1 > /dev/null
       exit 0
   fi
fi

echo "WARNING RMFIL Too dangerous to delete all files in $1"
exit 0
