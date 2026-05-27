#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESTS0033.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 22\07\2019
# auteur                        : Cyril AVINENS
#-----------------------------------------------------------------------------
# description : Sort NDIC NCB files
#-----------------------------------------------------------------------------
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
INPUT=$2
OUTPUT=$3

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1
LIBEL="Sort NDIC NCB"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF 			1:1 - 1:,
	END_NT			2:1 - 2:,
	SEC_NF			3:1 - 3:,
	UWY_NF			4:1 - 4:,
	UW_NT			5:1 - 5:,
	TYPE			6:1 - 6:,
	NCB_R			7:1 - 7:,
	NCB_M			8:1 - 8:,
	REN_B			9:1 - 9:,
	ESTCBTTYP_CT	10:1 - 10:,
	ESTCOMTYP_CT	11:1 - 11:
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
