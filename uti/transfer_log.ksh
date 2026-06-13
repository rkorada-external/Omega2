#!/bin/ksh


#FTP_HOST=10.1.5.56
FTP_HOST=10.16.32.43
FTP_USER=batchlog
FTP_PASSWD=batchlog

TO_ZIP="DLOG DFILT DDAEM"
SCRIPTNAME=${0##.*/}


for DIRVAR in $TO_ZIP
do
    (
    DIR=$(eval "echo \$$DIRVAR")
    # change to $DIR. If it fails, report an error
    cd "$DIR"  || { echo "Cannot find $DIR, skipping..." ; continue ; }

    # Timestamp file to get only modified/created files since last run
    TIMESTAMP="$DLOG/$SCRIPTNAME.$LOCAL_SITE.$ENV_PREFIX.$DIRVAR.ts"
    [ -f "$TIMESTAMP" ] || touch "$TIMESTAMP"

    # Tar file
    TARFILE="/tmp/$LOCAL_SITE.$ENV_PREFIX.$DIRVAR.$(date +"%Y%m%d.%H%M").tar.gz"
    LSTFILE="$TARFILE.lst"

    # create the tar
    find  . -newer "$TIMESTAMP" -name "*.log" -o -newer "$TIMESTAMP" -name "*.ano" > "$LSTFILE"
    if [ -s "$LSTFILE" ] ; then
	echo "Creating $TARFILE"
	/usr/sfw/bin/gtar czvf "$TARFILE" --files-from="$LSTFILE" || { echo "Error" ; ERR=1 ; }
    else
	echo "Nothing to do for $DIRVAR"
	rm "$LSTFILE"
	continue
    fi

    touch "$TIMESTAMP"

    # send it
    echo "Sending files via ftp"
    ftp -ivn <<EOF | grep "^226 " || { echo "Error" ; ERR=1 ; }
open $FTP_HOST
user $FTP_USER $FTP_PASSWD
binary
lcd "$(dirname $TARFILE)"
put "$(basename $TARFILE)"
EOF

    # Delete temp files
    rm "$TARFILE" "$LSTFILE"
    )
done

exit $ERR
