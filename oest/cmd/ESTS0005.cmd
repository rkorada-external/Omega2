#!/bin/ksh
#=============================================================================
# nom de l'application          : Quarterly closing
# nom du script SHELL           : ESTS0005.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 08\01\2020
# auteur                        : Cyril AVINENS
#-----------------------------------------------------------------------------
# description : Merge files
#-----------------------------------------------------------------------------
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
listArgs=( "$@" )
STEP=$1
INPUT_1=$2
OUTPUT=${listArgs[$# - 1]}
inputNumber=2
ext=".dat 2000 1"

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_${STEP}
LIBEL="Merge files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT_1}${ext}"

for arg in "${listArgs[@]}"; do
	if [[ $arg != ${STEP} ]];then
		if [[ $arg != ${INPUT_1} ]];then
			if [[ $arg != ${OUTPUT} ]];then
				value="${arg}${ext}"
				eval "SORT_I${inputNumber}=\${value}"
				inputNumber=$((inputNumber+1))
			fi
		fi
	fi
done

SORT_O="${OUTPUT}${ext}"

INPUT_TEXT ${SORT_CMD} <<EOF
/COPY
/OUTFILE ${SORT_O}

exit
EOF
SORT
