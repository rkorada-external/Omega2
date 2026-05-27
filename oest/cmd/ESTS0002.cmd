#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESTS0002.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 26\06\2019
# auteur                        : Antoine GRUNWALD
#-----------------------------------------------------------------------------
# description : Sort rate index files by CSUOE
#-----------------------------------------------------------------------------
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
INPUT=$2
OUTPUT=$3

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1
LIBEL="Sort rate index files by CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF			1:1 -  1:,
	END_NT			2:1 -  2:,
	SEC_NF			3:1 -  3:,
	UWY_NF			4:1 -  4:,
	UW_NT			5:1 -  5:,
	RATEINDEX_CTG	6:1 -  6:,
	RATEINDEX_CTP	7:1 -  7:,
	RATEINDEX_CTL	8:1 -  8:,
	TYPE			9:1 -  9:,
	SSD_CF			10:1 -  10:,
	ESB_CF			11:1 -  11:,
	GRPINISTS_CT	12:1 -  12:,
	PARINISTS_CT	13:1 -  13:,
	LOCINISTS_CT	14:1 -  14:,
	GRPFIRCLO_D		15:1 -  15:,
	PARFIRCLO_D		16:1 -  16:,
	LOCFIRCLO_D		17:1 -  17:,
	GRPIFRSTRA_CT	18:1 -  18:,
	PARIFRSTRA_CT	19:1 -  19:,
	LOCIFRSTRA_CT	20:1 -  20:
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
