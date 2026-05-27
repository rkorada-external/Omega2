#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESTS0065.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 14\12\2023
# auteur                        : Florian CULIOLI
#-----------------------------------------------------------------------------
# description : Sort IntersideSSd files by CSUOE
#-----------------------------------------------------------------------------
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
INPUT=$2
OUTPUT=$3

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1
LIBEL="Sort Intersite SSD files by SSD/CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF						1:1 - 1:,
	CTR_NF						2:1 - 2:,
	UWY_NF						3:1 - 3:,
	UW_NT						4:1 - 4:,
	END_NT						5:1 - 5:,
	SEC_NF						6:1 - 6:,
	PRISRC_CT					7:1 - 7:,
	CTRPRI_B					8:1 - 8:,
	PRILR_R						9:1 - 9:,
	EGPCUR_CF					10:1 - 10:,
	PSTEGP_M					11:1 - 11:,
	CUREGP_M					12:1 - 12:,
	CANEGP_M					13:1 - 13:,
	TTLEGP_M					14:1 - 14:,
	GRPRATEINDEX_CT				15:1 - 15:,
	GRPFIRCLO_D					16:1 - 16:,
	GRPIFRSSEG_CT				17:1 - 17:,
	GRPIFRSSEG_LL				18:1 - 18:,
	GRPINIPRO_CF				19:1 - 19:,
	PARRATEINDEX_CT				20:1 - 20:,
	PARFIRCLO_D					21:1 - 21:,
	PARIFRSSEG_CT				22:1 - 22:,
	PARIFRSSEG_LL				23:1 - 23:,
	PARINIPRO_CF				24:1 - 24:,
	LOCRATEINDEX_CT				25:1 - 25:,
	LOCFIRCLO_D					26:1 - 26:,
	LOCIFRSSEG_CT				27:1 - 27:,
	LOCIFRSSEG_LL				28:1 - 28:,
	LOCINIPRO_CF				29:1 - 29:,
	CMT_NT						30:1 - 30:,
	LSTUPD_D					31:1 - 31:,
	LSTUPDUSR_CF				32:1 - 32:,
	DIV_NT						33:1 - 33:,
	GRPINISTS_CT				34:1 - 34:,
	PARINISTS_CT				35:1 - 35:,
	LOCINISTS_CT				36:1 - 36:,
	CTRTYP_CT					37:1 - 37:
/KEYS
	SSD_CF,
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT,
	END_NT
/OUTFILE ${SORT_O}

exit
EOF
SORT
