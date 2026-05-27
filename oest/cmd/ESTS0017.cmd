#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESTS0017.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 23\10\2019
# auteur                        : Antoine GRUNWALD
#-----------------------------------------------------------------------------
# description : Sort segment profitability files by CSUOE
#-----------------------------------------------------------------------------
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
INPUT=$2
OUTPUT=$3

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1
LIBEL="Sort segment profitability files by CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF			1:1 - 1:,
	SEC_NF			2:1 - 2:,
	UWY_NF			3:1 - 3:,
	UW_NT			4:1 - 4:,
	END_NT			5:1 - 5:,
	CUR_CLO_PRO		6:1 - 6:,
	PREV_CLO_PRO	7:1 - 7:,
	INI_CLO_PRO		8:1 - 8:,
	NEWCOLS1_NF		9:1 - 9:,
	NEWCOLS2_NF		10:1 - 10:
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
