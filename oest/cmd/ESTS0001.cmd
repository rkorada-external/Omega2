#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESTS0001.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 29\08\2019
# auteur                        : Antoine GRUNWALD
#-----------------------------------------------------------------------------
# description : Sort profitability files by segment id
#-----------------------------------------------------------------------------
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
INPUT=$2
OUTPUT=$3

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1
LIBEL="Sort profitability files by segment id"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	IFRSSEG_CT			1:1 - 1:,
	UWY_NF				2:1 - 2:,
	NORME_CF			3:1 - 3:,
	INIPRO_CF			4:1 - 4:,
	CLODAT_D			5:1 - 5:,
	PER_CF				6:1 - 6:,
	BCHUSR_CF			7:1 - 7:,
	CLOPRO_CF			8:1 - 8:,
	CSMAMT_M			9:1 - 9:,
	SEGPOS_CF			10:1 - 10:,
	CRED_D				11:1 - 11:,
	CREUSR_CF			12:1 - 12:,
	LSTUPDUSR_CF		13:1 - 13:,
	LSTUPD_D			14:1 - 14:
/KEYS
	IFRSSEG_CT,
	INIPRO_CF,
	UWY_NF
/OUTFILE ${SORT_O}

exit
EOF
SORT
