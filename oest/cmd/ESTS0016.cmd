#!/bin/ksh
#===============================================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESTS0016.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 10\12\2019
# auteur                        : Cyril AVINENS
#------------------------------------------------------------------------------------------------
# description : Sort segmentIndicatorRecovery files by segment id
#------------------------------------------------------------------------------------------------
#================================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
INPUT=$2
OUTPUT=$3

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1
LIBEL="Sort segmentIndicatorRecovery files by segment id"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	IFRSSEG_CT			1:1 - 1:,
	IFRSSNPI			2:1 - 2:
/KEYS
	IFRSSEG_CT
/OUTFILE ${SORT_O}

exit
EOF
SORT
