#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESTS0023.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 23\03\2020
# auteur                        : Arnaud RUFFAULT
#-----------------------------------------------------------------------------
# description : Sort FCES files by Retro CSUOE
#-----------------------------------------------------------------------------
# Spira#102477 fix syncsort to sort FCES file instead of UPR file
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
INPUT=$2
OUTPUT=$3

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1
LIBEL="Sort FCES files by retro CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF			1:1 - 1:,
 END_NT			2:1 - 2:,
 SEC_NF			3:1 - 3:,
 UWY_NF			4:1 - 4:,
 UW_NT			5:1 - 5:,
 RETCTR_NF			6:1 - 6:,
 RETEND_NT			7:1 - 7:,
 RETSEC_NF			8:1 - 8:,
 RTY_NF			9:1 - 9:,
 RETUW_NT			10:1 - 10:,
 CES1ACCSTA_N			11:1 - 11:,
 CES1ACCEND_N			12:1 - 12:,
 CESSH_R			13:1 - 13:,
 SSD_CF			14:1 - 14:,
 ESB_CF			15:1 - 15:,
 RETCTRCAT_CF			16:1 - 16:,
 ACCADMTYP_CT			17:1 - 17:,
 RETACCADM_B			18:1 - 18:,
 CLECUTPER_B			19:1 - 19:,
 CLECUTPER_NB			20:1 - 20:,
 LOB_CF			21:1 - 21:,
 CUR_CF			22:1 - 22:,
 RETPCPCUR_CF			23:1 - 23:,
 CONRETCTR_B			24:1 - 24:,
 ACCFAM_CT			25:1 - 25:
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
