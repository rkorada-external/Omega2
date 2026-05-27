#!/bin/ksh
#===============================================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESTS0018.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 10\10\2019
# auteur                        : Cyril AVINENS
#------------------------------------------------------------------------------------------------
# description : Sort uoaDataRecovery files by segment id
#------------------------------------------------------------------------------------------------
#================================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
INPUT=$2
OUTPUT=$3

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1
LIBEL="Sort uoaDataRecovery files by segment id"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF				1:1 - 1:,
	END_NT				2:1 - 2:,
	SEC_NF				3:1 - 3:,
	UWY_NF				4:1 - 4:,
	UW_NT				5:1 - 5:,
	PBAAC_M				6:1 - 6:,
	PAMOR_M				7:1 - 7:,
	IFRSSEG_CT			8:1 - 8:,
	INIPRO_CF			9:1 - 9:,
	CR_CRUWY_NF		   10:1 - 10:
/KEYS
	IFRSSEG_CT,
	INIPRO_CF,
	CR_CRUWY_NF
/OUTFILE ${SORT_O}

exit
EOF
SORT
