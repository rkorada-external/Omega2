#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESTS0060.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 20\04\2022
# auteur                        : Charles SOCIE
#-----------------------------------------------------------------------------
# description : Sort pericase extended files by CSUOE
#-----------------------------------------------------------------------------
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
INPUT=$2
OUTPUT=$3

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1
LIBEL="Sort pericase extended files by CSUOE"
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
	RETCTR_NF		6:1 - 6:,
	RETEND_NT		7:1 - 7:,
	RETSEC_NF		8:1 - 8:,
	RTY_NF			9:1 - 9:,
	RETUW_NT		10:1 - 10:,
	LOFACTORSTD		11:1 - 11:,
	LOFACTORINI		12:1 - 12:,
	LCPATTERN		13:1 - 13:,
	CSMPATTERN		14:1 - 14:,
	FLAG			15:1 - 15:,
	EGPI_R1			16:1 - 16:,
	EGPI_R2			17:1 - 17:,
	EARP_R1			18:1 - 18:
/KEYS
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT,
	END_NT,
	RETCTR_NF,
	RETSEC_NF,
	RTY_NF,
	RETUW_NT,
	RETEND_NT
/OUTFILE ${SORT_O}

exit
EOF
SORT
