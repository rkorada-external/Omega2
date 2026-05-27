#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESTS0014.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 23\10\2019
# auteur                        : Antoine GRUNWALD
#-----------------------------------------------------------------------------
# description : Sort pericase light files by segment id
#-----------------------------------------------------------------------------
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
INPUT=$2
OUTPUT=$3

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1
LIBEL="Sort pericase light files by segment id"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF			1:1 - 1:,
	END_NT			2:1 - 2:,
	SEC_NF			3:1 - 3:,
	UWY_NF			4:1 - 4:,
	UW_NT			5:1 - 5:,
	INIPRO_CF		6:1 - 6:,
	IFRSSEG_CT		7:1 - 7:,
	CR_CRUWY_NF		8:1 - 8:
/KEYS
	IFRSSEG_CT,
	INIPRO_CF,
	CR_CRUWY_NF
/OUTFILE ${SORT_O}

exit
EOF
SORT
