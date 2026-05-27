#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESTS0044.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 13\01\2021
# auteur                        : NBD
#-----------------------------------------------------------------------------
# description : Sort Annual Limit file 
#-----------------------------------------------------------------------------
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
INPUT=$2
OUTPUT=$3

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1
LIBEL="Sort Annual Limit file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
 SSD_CF   			1:1 - 1:,
 CTR_NF   			2:1 - 2:,
 SEC_NF         	3:1 - 3:,
 UWY_NF       		4:1 - 4:,
 UW_NT       		5:1 - 5:,
 END_NT         	6:1 - 6:,
 DIV_NT       		7:1 - 7:,
 CUR_CF         	8:1 - 8:,
 ANN_LIMIT_AMT      9:1 - 9:
 
/KEYS
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT,
	END_NT
/OUTFILE ${SORT_O}

exit
EOF
SORT
