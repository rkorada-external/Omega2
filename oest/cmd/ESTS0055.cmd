#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESTS0055.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 03\05\2021
# auteur                        : Arnaud RUFFAULT
#-----------------------------------------------------------------------------
# description : Sort SECIFRS files by CSUOE
#-----------------------------------------------------------------------------
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
INPUT=$2
OUTPUT=$3

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1
LIBEL="Sort SECIFRS files by CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF						1:1 - 1:,
	UWY_NF						2:1 - 2:,
	UW_NT						3:1 - 3:,
	END_NT						4:1 - 4:,
	SEC_NF						5:1 - 5:,
	PRISRC_CT					6:1 - 6:,
	CTRPRI_B					7:1 - 7:,
	PRILR_R						8:1 - 8:,
	EGPCUR_CF					9:1 - 9:,
	PSTEGP_M					10:1 - 10:,
	CUREGP_M					11:1 - 11:,
	CANEGP_M					12:1 - 12:,
	TTLEGP_M					13:1 - 13:,
	GRPRATEINDEX_CT				14:1 - 14:,
	GRPFIRCLO_D					15:1 - 15:,
	GRPIFRSSEG_CT				16:1 - 16:,
	GRPIFRSSEG_LL				17:1 - 17:,
	GRPINIPRO_CF				18:1 - 18:,
	PARRATEINDEX_CT				19:1 - 19:,
	PARFIRCLO_D					20:1 - 20:,
	PARIFRSSEG_CT				21:1 - 21:,
	PARIFRSSEG_LL				22:1 - 22:,
	PARINIPRO_CF				23:1 - 23:,
	LOCRATEINDEX_CT				24:1 - 24:,
	LOCFIRCLO_D					25:1 - 25:,
	LOCIFRSSEG_CT				26:1 - 26:,
	LOCIFRSSEG_LL				27:1 - 27:,
	LOCINIPRO_CF				28:1 - 28:,
	CMT_NT						29:1 - 29:,
	LSTUPD_D					30:1 - 30:,
	LSTUPDUSR_CF				31:1 - 31:,
	DIV_NT						32:1 - 32:,
	GRPINISTS_CT				33:1 - 33:,
	PARINISTS_CT				34:1 - 34:,
	LOCINISTS_CT				35:1 - 35:,
	CTRTYP_CT					36:1 - 36:
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

