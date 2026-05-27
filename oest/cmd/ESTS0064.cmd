#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 Transition
# nom du script SHELL           : ESTS0064.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 14\12\2023
# auteur                        : FCI
#-----------------------------------------------------------------------------
# description : Sort internal assumed cashflow key recovery file
#-----------------------------------------------------------------------------
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
INPUT=$2
OUTPUT=$3

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1
LIBEL="Sort internal assumed cashflow key recovery file by CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	RETCTR_NF		1:1 -  1:,
	RTY_NF			2:1 -  2:,
	PLC_NT			3:1 -  3:,
	RETSEC_NF		4:1 -  4:,
	UW_NT			5:1 -  5:,
	CTR_NF			6:1 -  6:,
	UWY_NF			7:1 -  7:,
	SEC_NF			8:1 -  8:,
	END_NT			9:1 -  9:,
	CLISSD_NF		10:1 -  10:,
	RTOSSD_CF		11:1 -  12:,
	SSD_CF			12:1 -  12:
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

