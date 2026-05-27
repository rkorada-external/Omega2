#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESTS0069.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 24\02\2025
# auteur                        : David DA SILVA TEIXEIRA
#-----------------------------------------------------------------------------
# description : Sort contract rate index extended file by CSUOE Retro for retro P
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
LIBEL="Sort P Retro contract rate index extended by CSUOE Retro"
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
	RETCTR_NF				6:1 - 6:,
	RETEND_NT				7:1 - 7:,
	RETSEC_NF				8:1 - 8:,
	RTY_NF				9:1 - 9:,
	RETUW_NT				10:1 - 10:,
	PLC_NT				11:1 - 11:,
	TYP_CT				12:1 - 12:,
	DBLTRNCOD_CF				13:1 - 13:,
	RATEINDEX_CTG_A				14:1 - 14:,
	RATEINDEX_CTP_A				15:1 - 15:,
	RATEINDEX_CTL_A				16:1 - 16:,
	TYPE_A				17:1 - 17:,
	SSD_CF_A				18:1 - 18:,
	ESB_CF_A				19:1 - 19:,
	GRPINISTS_CT_A				20:1 - 20:,
	PARINISTS_CT_A				21:1 - 21:,
	LOCINISTS_CT_A				22:1 - 22:,
	GRPFIRCLO_D_A				23:1 - 23:,
	PARFIRCLO_D_A				24:1 - 24:,
	LOCFIRCLO_D_A				25:1 - 25:,
	GRPIFRSTRA_CT_A				26:1 - 26:,
	PARIFRSTRA_CT_A				27:1 - 27:,
	LOCIFRSTRA_CT_A				28:1 - 28:,
	RATEINDEX_CTG_R				29:1 - 29:,
	RATEINDEX_CTP_R				30:1 - 30:,
	RATEINDEX_CTL_R				31:1 - 31:,
	TYPE_R				32:1 - 32:,
	SSD_CF_R				33:1 - 33:,
	ESB_CF_R				34:1 - 34:,
	GRPINISTS_CT_R				35:1 - 35:,
	PARINISTS_CT_R				36:1 - 36:,
	LOCINISTS_CT_R				37:1 - 37:,
	GRPFIRCLO_D_R				38:1 - 38:,
	PARFIRCLO_D_R				39:1 - 39:,
	LOCFIRCLO_D_R				40:1 - 40:,
	GRPIFRSTRA_CT_R				41:1 - 41:,
	PARIFRSTRA_CT_R				42:1 - 42:,
	LOCIFRSTRA_CT_R				43:1 - 43:
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
/CONDITION P_RETRO_CTR (TYP_CT = "R" OR TYP_CT = "RI") AND DBLTRNCOD_CF != "02"
/INCLUDE P_RETRO_CTR
/OUTFILE ${SORT_O}

exit
EOF
SORT

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1-2
LIBEL="SSort NP Retro contract rate index extended by CSUOE Retro"
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
	RETCTR_NF				6:1 - 6:,
	RETEND_NT				7:1 - 7:,
	RETSEC_NF				8:1 - 8:,
	RTY_NF				9:1 - 9:,
	RETUW_NT				10:1 - 10:,
	PLC_NT				11:1 - 11:,
	TYP_CT				12:1 - 12:,
	DBLTRNCOD_CF				13:1 - 13:,
	RATEINDEX_CTG_A				14:1 - 14:,
	RATEINDEX_CTP_A				15:1 - 15:,
	RATEINDEX_CTL_A				16:1 - 16:,
	TYPE_A				17:1 - 17:,
	SSD_CF_A				18:1 - 18:,
	ESB_CF_A				19:1 - 19:,
	GRPINISTS_CT_A				20:1 - 20:,
	PARINISTS_CT_A				21:1 - 21:,
	LOCINISTS_CT_A				22:1 - 22:,
	GRPFIRCLO_D_A				23:1 - 23:,
	PARFIRCLO_D_A				24:1 - 24:,
	LOCFIRCLO_D_A				25:1 - 25:,
	GRPIFRSTRA_CT_A				26:1 - 26:,
	PARIFRSTRA_CT_A				27:1 - 27:,
	LOCIFRSTRA_CT_A				28:1 - 28:,
	RATEINDEX_CTG_R				29:1 - 29:,
	RATEINDEX_CTP_R				30:1 - 30:,
	RATEINDEX_CTL_R				31:1 - 31:,
	TYPE_R				32:1 - 32:,
	SSD_CF_R				33:1 - 33:,
	ESB_CF_R				34:1 - 34:,
	GRPINISTS_CT_R				35:1 - 35:,
	PARINISTS_CT_R				36:1 - 36:,
	LOCINISTS_CT_R				37:1 - 37:,
	GRPFIRCLO_D_R				38:1 - 38:,
	PARFIRCLO_D_R				39:1 - 39:,
	LOCFIRCLO_D_R				40:1 - 40:,
	GRPIFRSTRA_CT_R				41:1 - 41:,
	PARIFRSTRA_CT_R				42:1 - 42:,
	LOCIFRSTRA_CT_R				43:1 - 43:
/KEYS
 RETCTR_NF,
 RETSEC_NF,
 RTY_NF,
 RETUW_NT,
 RETEND_NT,
 CTR_NF,
 SEC_NF,
 UWY_NF,
 UW_NT,
 END_NT
/CONDITION NP_RETRO_CTR (TYP_CT = "R" OR TYP_CT = "RI") AND DBLTRNCOD_CF = "02"
/INCLUDE NP_RETRO_CTR
/OUTFILE ${SORT_O}

exit
EOF
SORT

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1-3
LIBEL="Sort Assum contract rate index extended by CSUOE Assum"
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
	RETCTR_NF				6:1 - 6:,
	RETEND_NT				7:1 - 7:,
	RETSEC_NF				8:1 - 8:,
	RTY_NF				9:1 - 9:,
	RETUW_NT				10:1 - 10:,
	PLC_NT				11:1 - 11:,
	TYP_CT				12:1 - 12:,
	DBLTRNCOD_CF				13:1 - 13:,
	RATEINDEX_CTG_A				14:1 - 14:,
	RATEINDEX_CTP_A				15:1 - 15:,
	RATEINDEX_CTL_A				16:1 - 16:,
	TYPE_A				17:1 - 17:,
	SSD_CF_A				18:1 - 18:,
	ESB_CF_A				19:1 - 19:,
	GRPINISTS_CT_A				20:1 - 20:,
	PARINISTS_CT_A				21:1 - 21:,
	LOCINISTS_CT_A				22:1 - 22:,
	GRPFIRCLO_D_A				23:1 - 23:,
	PARFIRCLO_D_A				24:1 - 24:,
	LOCFIRCLO_D_A				25:1 - 25:,
	GRPIFRSTRA_CT_A				26:1 - 26:,
	PARIFRSTRA_CT_A				27:1 - 27:,
	LOCIFRSTRA_CT_A				28:1 - 28:,
	RATEINDEX_CTG_R				29:1 - 29:,
	RATEINDEX_CTP_R				30:1 - 30:,
	RATEINDEX_CTL_R				31:1 - 31:,
	TYPE_R				32:1 - 32:,
	SSD_CF_R				33:1 - 33:,
	ESB_CF_R				34:1 - 34:,
	GRPINISTS_CT_R				35:1 - 35:,
	PARINISTS_CT_R				36:1 - 36:,
	LOCINISTS_CT_R				37:1 - 37:,
	GRPFIRCLO_D_R				38:1 - 38:,
	PARFIRCLO_D_R				39:1 - 39:,
	LOCFIRCLO_D_R				40:1 - 40:,
	GRPIFRSTRA_CT_R				41:1 - 41:,
	PARIFRSTRA_CT_R				42:1 - 42:,
	LOCIFRSTRA_CT_R				43:1 - 43:
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
