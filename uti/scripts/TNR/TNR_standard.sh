




TNR_standard ( ) 
{

			if [[ "$1" == *gz ]]
			then
				zcat -c $1 > file1
				file1="file1"
			else
				file1="$1"
			fi

			if [[ "$2" == *gz ]]
			then
				zcat -c $2 > file2
				file2="file2"
			else
				file2="$2"
			fi

			keyDef="$3"
			keyJoin="$4"
			size="$5"
bn=`basename $1`
syncsort << endofsort
/STATISTICS
/workspace  ${SORTWORK}
/FIELDS
		$keyDef,
        ALL_COLS  1:1 - $size :
/INFILE $file1 2000 1  "~"
/joinkeys
		$keyJoin
/INFILE $file2    2000 1  "~"
/joinkeys
		$keyJoin
/JOIN UNPAIRED  ONLY 
/OUTFILE  $DFILT/${bn}_diff overwrite
/REFORMAT
		leftside:ALL_COLS,
		rightside:ALL_COLS
endofsort

}


TNR_standard "$1" "$2" "$3" "$4" "$5"
