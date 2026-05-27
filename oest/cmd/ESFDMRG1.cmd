#!/bin/ksh
#=============================================================================
# nom de l'application          : Pericase
# nom du script SHELL           : ESFDMRG1.cmd
# revision                      : $Revision:   1.0 $
# date de creation              : 30/03/2023
# auteur                        : Mehdi NAJI
#-----------------------------------------------------------------------------
# description : Merge file in exetended period 
#-----------------------------------------------------------------------------
# modif
# [01] 26/06/2023 : SPIRA 108961  - P&C and Life- Closing output during local extended period
# [02] 16/01/2024 : SPIRA 111122  - POSX impact on some cash flow with ssd esb out of extended closing scope
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

FILE_ORG=$1
FILE_POSX=$2
SSD_COL=$3
ESB_COL=$4
NB_COLS=$5

NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="filter extended ESB"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${FILE_ORG}  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FILE_ORG-POSX.dat "
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF			${SSD_COL}:1 - ${SSD_COL}:,
	ESB_CF			${ESB_COL}:1 - ${ESB_COL}:,
	ALL_FIELDS      1:1  - ${NB_COLS}:,
	CLOPER_SSD_CF   1:1  - 1:,
	CLOPER_ESB_CF   2:1  - 2:
/joinkeys
        SSD_CF,
        ESB_CF
		
/INFILE ${ESF_FI17CLOPER} 2000 1 "~"
/joinkeys
        CLOPER_SSD_CF,
        CLOPER_ESB_CF
/JOIN UNPAIRED leftside ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:ALL_FIELDS
exit
EOF
SORT

NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="filter extended ESB"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${FILE_POSX}  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_POSX_CLEAN.dat "
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF			${SSD_COL}:1 - ${SSD_COL}:,
	ESB_CF			${ESB_COL}:1 - ${ESB_COL}:,
	ALL_FIELDS      1:1  - ${NB_COLS}:,
	CLOPER_SSD_CF   1:1  - 1:,
	CLOPER_ESB_CF   2:1  - 2:
/joinkeys
        SSD_CF,
        ESB_CF
		
/INFILE ${ESF_FI17CLOPER} 2000 1 "~"
/joinkeys
        CLOPER_SSD_CF,
        CLOPER_ESB_CF
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:ALL_FIELDS
exit
EOF
SORT

NSTEP=${NJOB}_15
#------------------------------------------------------------------------------
LIBEL="filter extended ESB"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${FILE_POSX}  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_POSX_HORS_SCOP.dat "
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF			${SSD_COL}:1 - ${SSD_COL}:,
	ESB_CF			${ESB_COL}:1 - ${ESB_COL}:,
	ALL_FIELDS      1:1  - ${NB_COLS}:,
	CLOPER_SSD_CF   1:1  - 1:,
	CLOPER_ESB_CF   2:1  - 2:
/joinkeys
        SSD_CF,
        ESB_CF
		
/INFILE ${ESF_FI17CLOPER} 2000 1 "~"
/joinkeys
        CLOPER_SSD_CF,
        CLOPER_ESB_CF
/JOIN UNPAIRED leftside ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:ALL_FIELDS
exit
EOF
SORT

NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="Sort pericase files by CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_FILE_ORG-POSX.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_10_${IB}_POSX_CLEAN.dat 2000 1"
SORT_O=${FILE_ORG} 
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF						${SSD_COL}:1 - ${SSD_COL}:,
	ESB_CF						${ESB_COL}:1 - ${ESB_COL}:
/COPY
exit
EOF
SORT


JOBEND 
