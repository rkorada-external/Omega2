#!/bin/ksh

Erreur()
{
 echo "\nError :\n"
 echo "   $*"
 echo "\n   Aborting ...\n"
 exit 1
}

Usage()
{
 echo "\nUsage : $PGM -Y <year> -Q <quarter> -u\n"
 echo " Y = Year to archive"
 echo " Q = Quarter to archive"
 echo " u = Usage (display syntax)"
 echo ""
 exit 0
}

trap "echo 'Interruption ...' ; exit 0"  1 2 3 15

[ $# = 0 ] && Usage

while getopts Y:Q:u OPTION
do
  case $OPTION in
    Y)   YEAR=$OPTARG ;;
    Q)   QUARTER=$OPTARG ;;
    u)   Usage ;;
    \?)  Usage ;;
  esac
done
shift `expr $OPTIND - 1`

[ ! -d $DARCH ] && Erreur "Archice directory \$DARCH does not exist ..."

[ "$QUARTER" = 1 -o "$QUARTER" = 2 -o "$QUARTER" = 3 -o "$QUARTER" = 4 ] || Erreur "Quarter incorrect ..."

[ $YEAR -lt 2000 -o $YEAR -gt 2020 ] && Erreur "Year incorrect ..."

TABLES="
TCTRSTAT
TSEGSTAT
TTECLEDASNEM
TTECLEDA
TTECLEDRSNEM
TTECLEDR
"


for TAB in $TABLES
do
  FILE_TO_SEARCH="${DARCH}/P_ESPD9990_ESID9991*${TAB}_[A-Z]_${QUARTER}Q${YEAR}.arc.zip"
  FILE=`ls $FILE_TO_SEARCH`
  [ ! -f $FILE ] && Erreur "Archive file for $TAB not found ..."
done

echo "\nFiles to archive :"
echo "------------------\n"
for TAB in $TABLES
do
  FILE_TO_SEARCH="${DARCH}/P_ESPD9990_ESID9991*${TAB}_[A-Z]_${QUARTER}Q${YEAR}.arc.zip"
  FILE=`ls $FILE_TO_SEARCH`
  echo "\t${FILE}"
done

ARCHNAME="Comptabilite Informatise $HOST $YEAR"
echo "\nArchive files for Quarter ${QUARTER}Q / Year ${YEAR} into \"$ARCHNAME\" (Y/N) : \c"
read REP

if [ "$REP" = "Y" -o "$REP" = "y" ]
then
{
 echo "Starting ..." 
 for TAB in $TABLES
 do
   FILE_TO_SEARCH="${DARCH}/P_ESPD9990_ESID9991*${TAB}_[A-Z]_${QUARTER}Q${YEAR}.arc.zip"
   FILE=`ls $FILE_TO_SEARCH`
   echo "dsmc archive -description=\"$ARCHNAME\" $FILE"
 done
}
else
{
  echo "Aborting ..."
  exit 0
}
fi

exit 0
