#!/bin/ksh
#=============================================================================
# nom de l'application          : Quarterly closing
# nom du script SHELL           : ESFD375A.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 23\10\2019
# auteur                        : Antoine GRUNWALD
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  IFRS17 REQ 12.5/12.6/12.8/12.9 : Sort segment profitability files by segment id
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
LIBEL="Sort segment profitability files by segment id"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 1000 1"
SORT_O="${OUTPUT}.dat 1000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	IFRSSEG_CT		1:1 -  1:,
	UWY_NF			2:1 -  2:,
	NORME_CF		3:1 -  3:,	
	INIPRO_CF		4:1 -  4:,
	CLODAT_D		5:1 -  5:,
	PER_CF			6:1 -  6:,
	CLOPRO_CF		7:1 -  7:,
	CSMAMT_M		8:1 -  8:,
	SEGCLOPRO_CF	9:1 -  9:,
	CRED_D			10:1 -  10:,
	CREUSR_CF		11:1 -  11:,
	LSTUPDUSR_CF	12:1 -  12:,	
	LSTUPD_D		13:1 -  13:
/KEYS
	IFRSSEG_CT,
	INIPRO_CF,
	UWY_NF
/OUTFILE ${SORT_O}

exit
EOF
SORT
