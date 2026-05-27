#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESTS0022.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 10\03\2020
# auteur                        : Antoine GRUNWALD
#-----------------------------------------------------------------------------
# description : Sort amortization pattern files by CSUO
#-----------------------------------------------------------------------------
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
INPUT=$2
OUTPUT_ASSUM=$3
OUTPUT_RETRO=$4

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1-1
LIBEL="Sort Retro amortization pattern files by CSUO"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT_RETRO}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF					1:1 - 1:,
	SEC_NF					2:1 - 2:,
	UWY_NF					3:1 - 3:,
	UW_NT					4:1 - 4:,
	TYP_CT					5:1 - 5:,
	NAT_CF					6:1 - 6:,
	LC_PATTERN				7:1 - 7:,
	CSM_PATTERN				8:1 - 8:
/KEYS
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT
/CONDITION RETRO_CTR TYP_CT = "R"
/INCLUDE RETRO_CTR
/OUTFILE ${SORT_O}

exit
EOF
SORT

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1-2
LIBEL="Sort Assum amortization pattern files by CSUO"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT_ASSUM}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF					1:1 - 1:,
	SEC_NF					2:1 - 2:,
	UWY_NF					3:1 - 3:,
	UW_NT					4:1 - 4:,
	TYP_CT					5:1 - 5:,
	NAT_CF					6:1 - 6:,
	LC_PATTERN				7:1 - 7:,
	CSM_PATTERN				8:1 - 8:
/KEYS
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT
/CONDITION ASSUM_CTR TYP_CT = "A"
/INCLUDE ASSUM_CTR
/OUTFILE ${SORT_O}

exit
EOF
SORT
