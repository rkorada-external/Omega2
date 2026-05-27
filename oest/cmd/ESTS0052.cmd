#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 Transition
# nom du script SHELL           : ESTS0051.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 10\03\2021
# auteur                        : Antoine GRUNWALD
#-----------------------------------------------------------------------------
# description : Sort retro pericase extended file for Retro P and Retro NP
# NBD spira92616 add three champs
#-----------------------------------------------------------------------------
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
INPUT=$2
OUTPUT_RETRO_P=$3
OUTPUT_RETRO_NP=$4

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1-1
LIBEL="Sort retro pericase extended file by CSUOE R P"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT_RETRO_P}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF			1:1 - 1:,
	ESB_CF			2:1 - 2:,
	CTR_NF			3:1 - 3:,
	END_NT			4:1 - 4:,
	SEC_NF			5:1 - 5:,
	UWY_NF			6:1 - 6:,
	UW_NT			7:1 - 7:,
	RETCTR_NF		8:1 - 8:,
	RETEND_NT		9:1 - 9:,
	RETSEC_NF		10:1 - 10:,
	RTY_NF			11:1 - 11:,
	RETUW_NT		12:1 - 12:,
	PLC_NT			13:1 - 13:,
	NAT_CF			14:1 - 14:,
	CUR_CF			15:1 - 15:,
	PC_R			16:1 - 16:,
	EXP_R			17:1 - 17:,
	MAXCOM_R		18:1 - 18:,
	MINCOM_R		19:1 - 19:,
	BRK_R			20:1 - 20:,
	COM_R			21:1 - 21:,
	TAX_R			22:1 - 22:,
	NCB_R			23:1 - 23:,
	ESTCBTTYP_CT	24:1 - 24:,
	ESTCOMTYP_CT	25:1 - 25:,
	COMTYP_CT		26:1 - 26:,
	RETPC_R			27:1 - 27:,
	RETEXP_R		28:1 - 28:,
	RETBRK_R		29:1 - 29:,
	RETORICOM_R		30:1 - 30:,
	RETCOM_R		31:1 - 31:,
	OVRCOM_R		32:1 - 32:,
	PRETAX_R		33:1 - 33:,
	OVRBASIS_NT		34:1 - 34:,
	RTO_NF			35:1 - 35:
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
/CONDITION P_RETRO NAT_CF = "P"
/INCLUDE P_RETRO
/OUTFILE ${SORT_O}

exit
EOF
SORT

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1-2
LIBEL="Sort retro pericase extended file by CSUOE RNP"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT_RETRO_NP}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF			1:1 - 1:,
	ESB_CF			2:1 - 2:,
	CTR_NF			3:1 - 3:,
	END_NT			4:1 - 4:,
	SEC_NF			5:1 - 5:,
	UWY_NF			6:1 - 6:,
	UW_NT			7:1 - 7:,
	RETCTR_NF		8:1 - 8:,
	RETEND_NT		9:1 - 9:,
	RETSEC_NF		10:1 - 10:,
	RTY_NF			11:1 - 11:,
	RETUW_NT		12:1 - 12:,
	PLC_NT			13:1 - 13:,
	NAT_CF			14:1 - 14:,
	CUR_CF			15:1 - 15:,
	PC_R			16:1 - 16:,
	EXP_R			17:1 - 17:,
	MAXCOM_R		18:1 - 18:,
	MINCOM_R		19:1 - 19:,
	BRK_R			20:1 - 20:,
	COM_R			21:1 - 21:,
	TAX_R			22:1 - 22:,
	NCB_R			23:1 - 23:,
	ESTCBTTYP_CT	24:1 - 24:,
	ESTCOMTYP_CT	25:1 - 25:,
	COMTYP_CT		26:1 - 26:,
	RETPC_R			27:1 - 27:,
	RETEXP_R		28:1 - 28:,
	RETBRK_R		29:1 - 29:,
	RETORICOM_R		30:1 - 30:,
	RETCOM_R		31:1 - 31:,
	OVRCOM_R		32:1 - 32:,
	PRETAX_R		33:1 - 33:,
	OVRBASIS_NT		34:1 - 34:,
	RTO_NF			35:1 - 35:
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
/CONDITION NP_RETRO NAT_CF = "N"
/INCLUDE NP_RETRO
/OUTFILE ${SORT_O}

exit
EOF
SORT
