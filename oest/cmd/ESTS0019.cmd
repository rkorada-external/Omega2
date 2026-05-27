#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESTS0019.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 23\10\2019
# auteur                        : Antoine GRUNWALD
#-----------------------------------------------------------------------------
# description : Sort transaction files by CSUOE
#-----------------------------------------------------------------------------
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
INPUT=$2
OUTPUT=$3

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1
LIBEL="Sort transaction files by CSUOE"
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
	PAY_NF				22:1 - 22:,
	KEY_CF				23:1 - 23:,
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
	LOBACC_CF			45:1 - 45:,
	LOBRET_CF			46:1 - 46:,
	SOBACC_CF			47:1 - 47:,
	SOBRET_CF			48:1 - 48:,
	TOPACC_CF			49:1 - 49:,
	TOPRET_CF			50:1 - 50:,
	NATACC_CF			51:1 - 51:,
	NATRET_CF			52:1 - 52:,
	GARACC_CF			53:1 - 53:,
	GARRET_CF			54:1 - 54:,
	PCPRSKTRYACC_CF		55:1 - 55:,
	PCPRSKTRYRET_CF		56:1 - 56:,
	USRCRTCODACC_CT		57:1 - 57:,
	USRCRTCODRET_CT		58:1 - 58:,
	USRCRTVALACC_LM		59:1 - 59:,
	USRCRTVALRET_LM		60:1 - 60:,
	CTRNAT_CT			61:1 - 61:,
	RETCTRCAT_CF		62:1 - 62:,
	WRKCAT_CT			63:1 - 63:,
	PRDCOD_CT			64:1 - 64:,
	ANLCTY_CF			65:1 - 65:,
	ACCADMTYP_CT		66:1 - 66:,
	RETACCTYP_CT		67:1 - 67:,
	COMACC_B			68:1 - 68:,
	CPLACCUPD_D			69:1 - 69:,
	CTRRET_B			70:1 - 70:,
	UWGRP_CF			71:1 - 71:,
	VRS_NF				72:1 - 72:,
	SEG_NF				73:1 - 73:,
	UWORG_CF			74:1 - 74:,
	ESTCRB_CT			75:1 - 75:,
	ESTCTR_NF			76:1 - 76:,
	ESBACC_CF			77:1 - 77:,
	ORGCED_NF			78:1 - 78:,
	CEDHORDNBR_NT		79:1 - 79:,
	CEDSORDNBR_NT		80:1 - 80:,
	ORGCEDHORDNBR_NT	81:1 - 81:,
	ORGCEDSORDNBR_NT	82:1 - 82:,
	BRKHORDNBR_NT		83:1 - 83:,
	BRKSORDNBR_NT		84:1 - 84:,
	FACADMTYP_CT		85:1 - 85:,
	CLIIND_NF			86:1 - 86:,
	HORDNBR_NT			87:1 - 87:,
	RETINTAMT_M			88:1 - 88:,
	BUKRS_CF			89:1 - 89:,
	RCOMP_CF			90:1 - 90:,
	LDGRP_CF			91:1 - 91:,
	HKONT_CF			92:1 - 92:,
	DBLHKONT_CF			93:1 - 93:,
	GJAHR_NF			94:1 - 94:,
	MONAT_NF			95:1 - 95:,
	VBUND_CF			96:1 - 96:,
	ZZCED_NF			97:1 - 97:,
	SEGMENT_CF			98:1 - 98:,
	BEWAR_CF			99:1 - 99:,
	ZZGAAPDIF_CF		100:1 - 100:,
	BLART_CF			101:1 - 101:,
	ZZRECONKEY_CF		102:1 - 102:,
	TRN_NT				103:1 - 103:,
	ORICOD_LS			104:1 - 104:,
	RETROAUTO_B			105:1 - 105:,
	SPEENTNAT_CT		106:1 - 106:,
	EVT_NF				107:1 - 107:,
	REVT_NF				108:1 - 108:,
	RETARDRETINT_B		109:1 - 109:,
	NEWCOLS1_NF			110:1 - 110:,
	NEWCOLS2_NF			111:1 - 111:,
	NEWCOLS3_NF			112:1 - 112:,
	NEWCOLS4_NF			113:1 - 113:,
	NEWCOLS5_NF			114:1 - 114:,
	NEWCOLS6_NF			115:1 - 115:,
	NEWCOLS7_NF			116:1 - 116:,
	NEWCOLS8_NF			117:1 - 117:,
	NEWCOLS9_NF			118:1 - 118:
/KEYS
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT,
	END_NT
/OUTFILE ${SORT_O}

exit
EOF
SORT
