#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESTS0049.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 01\12\2019
# auteur                        : Cyril AVINENS
#-----------------------------------------------------------------------------
# description : Sort rate index files
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
LIBEL="Sort Assum cashflow"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT_ASSUM}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF			1:1 -  1:,
	END_NT			2:1 -  2:,
	SEC_NF			3:1 -  3:,
	UWY_NF			4:1 -  4:,
	UW_NT			5:1 -  5:,
	RETCTR_NF		6:1 -  6:,
	RETEND_NT		7:1 -  7:,
	RETSEC_NF		8:1 -  8:,
	RTY_NF			9:1 -  9:,
	RETUW_NT		10:1 -  10:,
	PLC_NT			11:1 -  11:,
	CUR_CF			12:1 -  12:,
	PATCAT_CT		13:1 -  13:,
	ACMCUR_CF		14:1 -  14:,
	RETCUR_CF		15:1 -  15:,
	ACMTRS_NT		16:1 -  16:,
	ACMTRS3_NT		17:1 -  17:,
	RATEINDEX_CTG	18:1 -  18:,
	RATEINDEX_CTP	19:1 -  19:,
	RATEINDEX_CTL	20:1 -  20:,
	TYPE			21:1 -  21:,
	SSD_CF			22:1 -  22:,
	ESB_CF			23:1 -  23:,
	GRPINISTS_CT	24:1 -  24:,
	PARINISTS_CT	25:1 -  25:,
	LOCINISTS_CT	26:1 -  26:,
	GRPFIRCLO_D		27:1 -  27:,
	PARFIRCLO_D		28:1 -  28:,
	LOCFIRCLO_D		29:1 -  29:
/KEYS
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT,
	END_NT,
	CUR_CF,
	ACMTRS_NT,
	ACMTRS3_NT,
	ACMCUR_CF,
	PATCAT_CT
/CONDITION ASSUM_CTR TYPE = "F" OR TYPE = "T"
/INCLUDE ASSUM_CTR
/OUTFILE ${SORT_O}

exit
EOF
SORT

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1-2
LIBEL="Sort Retro cashflow"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT_RETRO}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF			1:1 -  1:,
	END_NT			2:1 -  2:,
	SEC_NF			3:1 -  3:,
	UWY_NF			4:1 -  4:,
	UW_NT			5:1 -  5:,
	RETCTR_NF		6:1 -  6:,
	RETEND_NT		7:1 -  7:,
	RETSEC_NF		8:1 -  8:,
	RTY_NF			9:1 -  9:,
	RETUW_NT		10:1 -  10:,
	PLC_NT			11:1 -  11:,
	CUR_CF			12:1 -  12:,
	PATCAT_CT		13:1 -  13:,
	ACMCUR_CF		14:1 -  14:,
	RETCUR_CF		15:1 -  15:,
	ACMTRS_NT		16:1 -  16:,
	ACMTRS3_NT		17:1 -  17:,
	RATEINDEX_CTG	18:1 -  18:,
	RATEINDEX_CTP	19:1 -  19:,
	RATEINDEX_CTL	20:1 -  20:,
	TYPE			21:1 -  21:,
	SSD_CF			22:1 -  22:,
	ESB_CF			23:1 -  23:,
	GRPINISTS_CT	24:1 -  24:,
	PARINISTS_CT	25:1 -  25:,
	LOCINISTS_CT	26:1 -  26:,
	GRPFIRCLO_D		27:1 -  27:,
	PARFIRCLO_D		28:1 -  28:,
	LOCFIRCLO_D		29:1 -  29:
/KEYS
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT,
	END_NT,
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF,
	RETUW_NT,
	PLC_NT,
	RETCUR_CF,
	ACMTRS_NT,
	ACMTRS3_NT,
	ACMCUR_CF,
	PATCAT_CT,
	CUR_CF
/CONDITION RETRO_CTR TYPE = "R"
/INCLUDE RETRO_CTR
/OUTFILE ${SORT_O}

exit
EOF
SORT
