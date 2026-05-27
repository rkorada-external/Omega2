#!/bin/ksh
#=============================================================================
# nom de l'application          : Quarterly closing
# nom du script SHELL           : ESFD375B.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 23\10\2019
# auteur                        : Antoine GRUNWALD
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  IFRS17 REQ 12.5/12.6/12.8/12.9 : Sort segment profitability files by CSUOE
#
#-----------------------------------------------------------------------------
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
INPUT=$2
OUTPUT=$3

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1_1
LIBEL="Sort segment profitability files by CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 1000 1"
SORT_O="${OUTPUT}.dat 1000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF			1:1 -  1:,
	END_NT			2:1 -  2:,
	SEC_NF			3:1 -  3:,
	UWY_NF			4:1 -  4:,
	UW_NT			5:1 -  5:,
	CLO_PRO			6:1 -  6:
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
