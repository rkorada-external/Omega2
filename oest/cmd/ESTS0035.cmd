#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESTS0035.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 19\08\2020
# auteur                        : Antoine GRUNWALD
#-----------------------------------------------------------------------------
# description : Sort amortization pattern by contract files by CSUOE
# Modification : 09/03/2021 NBD spira#93494 add of AI and RI type
#-----------------------------------------------------------------------------
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
INPUT=$2
OUTPUT_ASSUM=$3
OUTPUT_RETRO_P=$4
OUTPUT_RETRO_NP=$5

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1-1
LIBEL="Sort P Retro amortization pattern by contract files by CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT_RETRO_P}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF				1:1 - 1:,
	END_NT				2:1 - 2:,
	SEC_NF				3:1 - 3:,
	UWY_NF				4:1 - 4:,
	UW_NT				5:1 - 5:,
	RETCTR_NF			6:1 - 6:,
	RETEND_NT			7:1 - 7:,
	RETSEC_NF			8:1 - 8:,
	RTY_NF				9:1 - 9:,
	RETUW_NT			10:1 - 10:,
	PLC_NT				11:1 - 11:,
	TYP_CT				12:1 - 12:,
	NAT_CF				13:1 - 13:,
	LC_PATTERN_CUR		14:1 - 14:,
	CSM_PATTERN_CUR		15:1 - 15:,
	LC_PATTERN_PREV		16:1 - 16:,
	CSM_PATTERN_PREV	17:1 - 17:
/KEYS
	RETCTR_NF,
	RETSEC_NF,
	RTY_NF,
	RETUW_NT,
	RETEND_NT,
	PLC_NT,
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT,
	END_NT
/CONDITION P_RETRO_CTR (TYP_CT = "R" OR TYP_CT = "RI") AND NAT_CF = "P"
/INCLUDE P_RETRO_CTR
/OUTFILE ${SORT_O}

exit
EOF
SORT

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1-2
LIBEL="Sort NP Retro amortization pattern by contract files by CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT_RETRO_NP}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF				1:1 - 1:,
	END_NT				2:1 - 2:,
	SEC_NF				3:1 - 3:,
	UWY_NF				4:1 - 4:,
	UW_NT				5:1 - 5:,
	RETCTR_NF			6:1 - 6:,
	RETEND_NT			7:1 - 7:,
	RETSEC_NF			8:1 - 8:,
	RTY_NF				9:1 - 9:,
	RETUW_NT			10:1 - 10:,
	PLC_NT				11:1 - 11:,
	TYP_CT				12:1 - 12:,
	NAT_CF				13:1 - 13:,
	LC_PATTERN_CUR		14:1 - 14:,
	CSM_PATTERN_CUR		15:1 - 15:,
	LC_PATTERN_PREV		16:1 - 16:,
	CSM_PATTERN_PREV	17:1 - 17:
/KEYS
	RETCTR_NF,
	RETSEC_NF,
	RTY_NF,
	RETUW_NT,
	RETEND_NT,
	PLC_NT
/CONDITION NP_RETRO_CTR (TYP_CT = "R" OR TYP_CT = "RI") AND NAT_CF = "N"
/INCLUDE NP_RETRO_CTR
/OUTFILE ${SORT_O}

exit
EOF
SORT

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1-3
LIBEL="Sort Assum amortization pattern by contract files by CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT_ASSUM}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF				1:1 - 1:,
	END_NT				2:1 - 2:,
	SEC_NF				3:1 - 3:,
	UWY_NF				4:1 - 4:,
	UW_NT				5:1 - 5:,
	RETCTR_NF			6:1 - 6:,
	RETEND_NT			7:1 - 7:,
	RETSEC_NF			8:1 - 8:,
	RTY_NF				9:1 - 9:,
	RETUW_NT			10:1 - 10:,
	PLC_NT				11:1 - 11:,
	TYP_CT				12:1 - 12:,
	NAT_CF				13:1 - 13:,
	LC_PATTERN_CUR		14:1 - 14:,
	CSM_PATTERN_CUR		15:1 - 15:,
	LC_PATTERN_PREV		16:1 - 16:,
	CSM_PATTERN_PREV	17:1 - 17:
/KEYS
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT,
	END_NT
/CONDITION ASSUM_CTR TYP_CT = "A" OR TYP_CT = "AI"
/INCLUDE ASSUM_CTR
/OUTFILE ${SORT_O}

exit
EOF
SORT
