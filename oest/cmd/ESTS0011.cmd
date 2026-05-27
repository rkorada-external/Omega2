#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESTS0011.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 10\03\2020
# auteur                        : Antoine GRUNWALD
#-----------------------------------------------------------------------------
# description : Sort retro transactions files by CSUOE
#-----------------------------------------------------------------------------
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
INPUT=$2
OUTPUT=$3

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1
LIBEL="Sort retro transaction files by CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF				1:1 - 1:,
	ESB_CF				2:1 - 2:,
	BALSHEY_NF			3:1 - 3:,
	BALSHRMTH_NF		4:1 - 4:,
	BALSHRDAY_NF		5:1 - 5:,
	TRNCOD_CF			6:1 - 6:,
	DBLTRNCOD_CF		7:1 - 7:,
	CTR_NF				8:1 - 8:,
	END_NT				9:1 - 9:,
	SEC_NF				10:1 - 10:,
	UWY_NF				11:1 - 11:,
	UW_NT				12:1 - 12:,
	OCCYEA_NF			13:1 - 13:,
	ACY_NF				14:1 - 14:,
	SCOSTRMTH_NF		15:1 - 15:,
	SCOENDMTH_NF		16:1 - 16:,
	CLM_NF				17:1 - 17:,
	CUR_CF				18:1 - 18:,
	AMT_M				19:1 - 19:,
	CED_NF				20:1 - 20:,
	BRK_NF				21:1 - 21:,
	GEMPRMPAY_NF		22:1 - 22:,
	GANPAYORD_NT		23:1 - 23:,
	RETCTR_NF			24:1 - 24:,
	RETEND_NT			25:1 - 25:,
	RETSEC_NF			26:1 - 26:,
	RETRTY_NF			27:1 - 27:,
	RETUW_NT			28:1 - 28:,
	RETOCCYEA_NF		29:1 - 29:,
	RETACY_NF			30:1 - 30:,
	RETSCOSTRMTH_NF		31:1 - 31:,
	RETSCOENDMTH_NF		32:1 - 32:,
	RCL_NF				33:1 - 33:,
	RETCUR_CF			34:1 - 34:,
	RETAMT_M			35:1 - 35:,
	PLC_NT				36:1 - 36:,
	RTO_NF				37:1 - 37:,
	INT_NF				38:1 - 38:,
	RETPAY_NF			39:1 - 39:,
	RETKEY_CF			40:1 - 40:,
	CRE_D				41:1 - 41:,
	CREUSR_CF			42:1 - 42:,
	LSTUPD_D			43:1 - 43:,
	LSTUPDUSR_CF		44:1 - 44:,
	LOBRET_CF			45:1 - 45:,
	SOBRET_CF			46:1 - 46:,
	TOPRET_CF			47:1 - 47:,
	NATRET_CF			48:1 - 48:,
	GARRET_CF			49:1 - 49:,
	PCPRSKTRYRET_CF		50:1 - 50:,
	USRCRTCODRET_CT		51:1 - 51:,
	USRCRTVALRET_LM		52:1 - 52:,
	RETCTRCAT_CF		53:1 - 53:,
	RETACCTYP_CT		54:1 - 54:,
	SSDRTO_B			55:1 - 55:,
	TRN_NT				56:1 - 56:,
	ORICOD_LS			57:1 - 57:,
	RETROAUTO_B			58:1 - 58:,
	SPEENTNAT_CT		59:1 - 59:,
	EVT_NF				60:1 - 60:,
	REVT_NF				61:1 - 61:,
	RETARDRETINT_B		62:1 - 62:,
	NEWCOLS1_NF			63:1 - 63:,
	NEWCOLS2_NF			64:1 - 64:,
	NEWCOLS3_NF			65:1 - 65:,
	NEWCOLS4_NF			66:1 - 66:,
	NEWCOLS5_NF			67:1 - 67:,
	NEWCOLS6_NF			68:1 - 68:,
	NEWCOLS7_NF			69:1 - 69:,
	NEWCOLS8_NF			70:1 - 70:,
	NEWCOLS9_NF			71:1 - 71:
/KEYS
	RETCTR_NF,
	RETSEC_NF,
	RETRTY_NF,
	RETUW_NT,
	RETEND_NT,
	PLC_NT,
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT,
	END_NT
/OUTFILE ${SORT_O}

exit
EOF
SORT
