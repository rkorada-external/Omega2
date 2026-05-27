#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESTS0027.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 25\01\2021
# auteur                        : Charles SOCIE
#-----------------------------------------------------------------------------
# description : Sort FLOARAT file by CSUOE
#-----------------------------------------------------------------------------
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
INPUT=$2
OUTPUT=$3

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1
LIBEL="Sorting of the FLOARAT file by CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF		1:1 - 1:,
	END_NT		2:1 - 2:,
	SEC_NF		3:1 - 3:,
	UWY_NF		4:1 - 4:,
	UW_NT		5:1 - 5:,
	SSD_CF		6:1 - 6:,
	COMMIS_R	7:1 - 7:,
	OVECOM_R	8:1 - 8:,
	TAX_R		9:1 - 9:,
	BROKER_R	10:1 - 10:,
	PRS_CF		11:1 - 11:
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
