#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESTS0029.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 25\06\2020
# auteur                        : Nicolas Briand
#-----------------------------------------------------------------------------
# description : Sort CSM engine ASSUMED Pericase file by CTR SSD ESB
#-----------------------------------------------------------------------------
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
INPUT=$2
OUTPUT=$3

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1
LIBEL="Sort CSM engine ASSUMED Pericase file by CTR SSD ESB"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF			1:1 -  1:,
	SEC_NF			2:1 -  2:,
	UWY_NF			3:1 -  3:,
	UW_NT			4:1 -  4:,
	END_NT			5:1 -  5:,
	SSD_CF			6:1 -  6:,
	ESB_CF			7:1 -  7:,
	GRPINISTS_CT	8:1 -  8:,
	PARINISTS_CT	9:1 -  9:,
	LOCINISTS_CT	10:1 - 10:,
	GRPIFRSTRA_CT	11:1 - 11:,
	PARIFRSTRA_CT	12:1 - 12:,
	LOCIFRSTRA_CT	13:1 - 13:,
	GRPIFRSSEG_CT	14:1 - 14:,
	PARIFRSSEG_CT	15:1 - 15:,
	LOCIFRSSEG_CT	16:1 - 16:,
	GRPINIPRO_CF	17:1 - 17:,
	PARINIPRO_CF	18:1 - 18:,
	LOCINIPRO_CF	19:1 - 19:
/KEYS
	CTR_NF,
	SSD_CF,
	ESB_CF
/OUTFILE ${SORT_O}

exit
EOF
SORT