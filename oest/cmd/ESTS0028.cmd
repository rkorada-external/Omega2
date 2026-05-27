#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESTS0028.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 25\06\2020
# auteur                        : Nicolas Briand
#-----------------------------------------------------------------------------
# description : Sort CSM engine file by CTR SSD ESB
#-----------------------------------------------------------------------------
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
INPUT=$2
OUTPUT=$3

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1
LIBEL="Sort CSM engine file by CTR SSD ESB"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	N_ROW			1:1 -  1:,
	SSD_CF			2:1 -  2:,
	ESB_CF			3:1 -  3:,
	CTR_NF			4:1 -  4:,
	SEC_NF			5:1 -  5:,
	PFL				6:1 -  6:,
	INIT_PB_ASS		7:1 -  7:,
	LI_DIR			8:1 -  8:,
	PCS_ST			9:1 -  9:
/KEYS
	CTR_NF,
	SSD_CF,
	ESB_CF
/OUTFILE ${SORT_O}

exit
EOF
SORT