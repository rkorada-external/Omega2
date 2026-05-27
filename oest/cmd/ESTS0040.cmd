#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESTS0040.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 15/10/2020
# auteur                        : Charles Socie
#-----------------------------------------------------------------------------
# description : Sorting of the FPLC file by CSUOER
#-----------------------------------------------------------------------------
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
INPUT=$2
OUTPUT=$3

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1
LIBEL="Sort FPLC file by CSUOER"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF			1:1 - 1:,
	ESB_CF			2:1 - 2:,
	RETCTR_NF		3:1 - 3:,
	RETEND_NT		4:1 - 4:,
	RETSEC_NF		5:1 - 5:,
	RTY_NF			6:1 - 6:,
	RETUW_NT		7:1 - 7:,
	PLC_NT			8:1 - 8:,
	OVRCOM_R		9:1 - 9:,
	RTO_NF			10:1 - 10:,
	INT_NF			11:1 - 11:,
	PAY_NF			12:1 - 12:,
	KEY_CF			13:1 - 13:,
	ORICUR_B		14:1 - 14:,
	SSDRTO_B		15:1 - 15:,
	RETSIGSHA_R		16:1 - 16:,
	LOB_CF			17:1 - 17:,
	RAICOM_B		18:1 - 18:,
	RETOVRCOM_B		19:1 - 19:,
	CTR_NF			20:1 - 20:,
	END_NT			21:1 - 21:,
	SEC_NF			22:1 - 22:,
	UWY_NF			23:1 - 23:,
	UW_NT			24:1 - 24:,
	CUR_CF			25:1 - 25:,
	CESSH_R			26:1 - 26:,
	CLMFUN_R		27:1 - 27:,
	URRFUN_R		28:1 - 28:,
	CLMFUNINT_R		29:1 - 29:,
	URRFUNINT_R		30:1 - 30:,
	CONRETCTR_B		31:1 - 31:,
	DEPORI_B		32:1 - 32:,
	RTOCTY_CF		33:1 - 33:,
	BASIS_NT		34:1 - 34:,
	OVRBASIS_NT		35:1 - 35:,
	FIXCOM_R		36:1 - 36:,
	PRETAX_R		37:1 - 37:
/KEYS
	RETCTR_NF,
	RETSEC_NF,
	RTY_NF,
	RETUW_NT,
	RETEND_NT
/OUTFILE ${SORT_O}

exit
EOF
SORT