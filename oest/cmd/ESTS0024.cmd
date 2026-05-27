#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 transition closing
# nom du script SHELL           : ESTS0024.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 15\04\2020
# auteur                        : Charles SOCIE
#-----------------------------------------------------------------------------
# description : Sort Transition files by CSUOE
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
LIBEL="Sort P Retro Transition files by CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT_RETRO_P}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF				1:1 - 1:,
	ESB_CF				2:1 - 2:,
	CTR_NF				3:1 - 3:,
	SEC_NF				4:1 - 4:,
	UWY_NF				5:1 - 5:,
	UW_NT				6:1 - 6:,
	END_NT				7:1 - 7:,
	CTRINC_D			8:1 - 8:,
	CTR_FLA				9:1 - 9:,
	CTR_PROP			10:1 - 10:,
	CLIENT_NF			11:1 - 11:,
	MULTI_YEAR_TO_NF	12:1 - 12:,
	BS_QUARTER_FC		13:1 - 13:,
	EGPI_AMOUNT_FC		14:1 - 14:,
	EGPI_CUR_FC			15:1 - 15:,
	BS_QUARTER_LR		16:1 - 16:,
	SEG_ACT_LR			17:1 - 17:,
	CTR_UWLR			18:1 - 18:,
	ADJLOSRAT_R			19:1 - 19:,
	LOSRAT_R			20:1 - 20:,
	PRILR_T				21:1 - 21:,
	CTRPRI_B			22:1 - 22:,
	BS_QUARTER_CSF		23:1 - 23:,
	SEG_ACT_CSF			24:1 - 24:,
	BS_QUARTER_LKI		25:1 - 25:,
	RATEINDEX_LKI		26:1 - 26:,
	CSM_FACTOR			27:1 - 27:,
	REF_QUARTER_INC		28:1 - 28:,
	SEG_SHORT_LABEL		29:1 - 29:,
	PRMRAT_R 			30:1 - 30:,
	RSRVRAT_R 			31:1 - 31:
/KEYS
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT,
	END_NT
/CONDITION P_RETRO_CTR (CTR_FLA = "R" OR CTR_FLA = "RI") AND CTR_PROP = "P"
/INCLUDE P_RETRO_CTR
/OUTFILE ${SORT_O}

exit
EOF
SORT

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1-2
LIBEL="Sort NP Retro Transition files by CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT_RETRO_NP}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF				1:1 - 1:,
	ESB_CF				2:1 - 2:,
	CTR_NF				3:1 - 3:,
	SEC_NF				4:1 - 4:,
	UWY_NF				5:1 - 5:,
	UW_NT				6:1 - 6:,
	END_NT				7:1 - 7:,
	CTRINC_D			8:1 - 8:,
	CTR_FLA				9:1 - 9:,
	CTR_PROP			10:1 - 10:,
	CLIENT_NF			11:1 - 11:,
	MULTI_YEAR_TO_NF	12:1 - 12:,
	BS_QUARTER_FC		13:1 - 13:,
	EGPI_AMOUNT_FC		14:1 - 14:,
	EGPI_CUR_FC			15:1 - 15:,
	BS_QUARTER_LR		16:1 - 16:,
	SEG_ACT_LR			17:1 - 17:,
	CTR_UWLR			18:1 - 18:,
	ADJLOSRAT_R			19:1 - 19:,
	LOSRAT_R			20:1 - 20:,
	PRILR_T				21:1 - 21:,
	CTRPRI_B			22:1 - 22:,
	BS_QUARTER_CSF		23:1 - 23:,
	SEG_ACT_CSF			24:1 - 24:,
	BS_QUARTER_LKI		25:1 - 25:,
	RATEINDEX_LKI		26:1 - 26:,
	CSM_FACTOR			27:1 - 27:,
	REF_QUARTER_INC		28:1 - 28:,
	SEG_SHORT_LABEL		29:1 - 29:,
	PRMRAT_R 			30:1 - 30:,
	RSRVRAT_R 			31:1 - 31:
/KEYS
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT,
	END_NT
/CONDITION NP_RETRO_CTR (CTR_FLA = "R" OR CTR_FLA = "RI") AND (CTR_PROP = "N" OR CTR_PROP = "NP")
/INCLUDE NP_RETRO_CTR
/OUTFILE ${SORT_O}

exit
EOF
SORT

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1-3
LIBEL="Sort Assum Transition files by CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT_ASSUM}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF				1:1 - 1:,
	ESB_CF				2:1 - 2:,
	CTR_NF				3:1 - 3:,
	SEC_NF				4:1 - 4:,
	UWY_NF				5:1 - 5:,
	UW_NT				6:1 - 6:,
	END_NT				7:1 - 7:,
	CTRINC_D			8:1 - 8:,
	CTR_FLA				9:1 - 9:,
	CTR_PROP			10:1 - 10:,
	CLIENT_NF			11:1 - 11:,
	MULTI_YEAR_TO_NF	12:1 - 12:,
	BS_QUARTER_FC		13:1 - 13:,
	EGPI_AMOUNT_FC		14:1 - 14:,
	EGPI_CUR_FC			15:1 - 15:,
	BS_QUARTER_LR		16:1 - 16:,
	SEG_ACT_LR			17:1 - 17:,
	CTR_UWLR			18:1 - 18:,
	ADJLOSRAT_R			19:1 - 19:,
	LOSRAT_R			20:1 - 20:,
	PRILR_T				21:1 - 21:,
	CTRPRI_B			22:1 - 22:,
	BS_QUARTER_CSF		23:1 - 23:,
	SEG_ACT_CSF			24:1 - 24:,
	BS_QUARTER_LKI		25:1 - 25:,
	RATEINDEX_LKI		26:1 - 26:,
	CSM_FACTOR			27:1 - 27:,
	REF_QUARTER_INC		28:1 - 28:,
	SEG_SHORT_LABEL		29:1 - 29:,
	PRMRAT_R 			30:1 - 30:,
	RSRVRAT_R 			31:1 - 31:
/KEYS
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT,
	END_NT
/CONDITION ASSUM_CTR CTR_FLA = "A" OR CTR_FLA = "AI"
/INCLUDE ASSUM_CTR
/OUTFILE ${SORT_O}

exit
EOF
SORT
