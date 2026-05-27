#!/bin/ksh
#=============================================================================
# nom de l'application          : Sort rate index files
# nom du script SHELL           : syncsort-2066-rate-index.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 26\06\2019
# auteur                        : Antoine Grunwald
# references des specifications :
#-----------------------------------------------------------------------------

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
INPUT=$2
OUTPUT=$3

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1_1
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 1000 1"
SORT_O="${OUTPUT}.dat 1000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS		SSD_CF		1:1 -  1:,
		CTR_NF		2:1 -  2:,
		END_NT		3:1 -  3:,
		SEC_NF		4:1 -  4:,
		UWY_NF		5:1 -  5:,
		UW_NT		6:1 -  6:,
		RATEINDEX_CTG	7:1 -  7:,
		RATEINDEX_CTP	8:1 -  8:,
		RATEINDEX_CTL	9:1 -  9:
/KEYS  		CTR_NF,
		SEC_NF,
		UWY_NF,
		UW_NT,
		END_NT
/OUTFILE ${SORT_O}

exit
EOF
SORT >> ${FLOG}
