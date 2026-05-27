#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATES
#                                 Preparation of anterior cession and placement files
# nom du script SHELL		: ESTD2521.cmd
# revision			: $Revision:   1.5  $
# date de creation		: 03/10/1997
# auteur			: CGI
# references des specifications	: 
#-----------------------------------------------------------------------------
# Description :  Preparation of cession and placement files
#
# JOB LAUNCHED BY : ESTD2520.cmd
#-----------------------------------------------------------------------------
# historiques des modifications : 
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job initialisation
JOBINIT

# Get parameters

NSTEP=${NJOB}_05
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="filtering anterior placement file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FPLCANT}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_PLCANT_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:EN
/CONDITION FILIALES (SSD_CF = 5) or (SSD_CF = 6) or (SSD_CF = 10) or (SSD_CF = 11) or (SSD_CF = 20)
/OMIT FILIALES 
exit
EOF
SORT

NSTEP=${NJOB}_10
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Filtering anterior cession file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FCESANT}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_CESANT_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 14:1 - 14:EN
/CONDITION FILIALES (SSD_CF = 5) or (SSD_CF = 6) or (SSD_CF = 10) or (SSD_CF = 11) or (SSD_CF = 20)
/OMIT FILIALES 
exit
EOF
SORT

NSTEP=${NJOB}_15
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Filtering placement file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FPLC}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_PLC_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:EN
/CONDITION FILIALES (SSD_CF = 5) or (SSD_CF = 6) or (SSD_CF = 10) or (SSD_CF = 11) or (SSD_CF = 20)
/INCLUDE FILIALES 
exit
EOF
SORT

NSTEP=${NJOB}_20
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Filtering cession file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FCES}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_CES_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 14:1 - 14:EN
/CONDITION FILIALES (SSD_CF = 5) or (SSD_CF = 6) or (SSD_CF = 10) or (SSD_CF = 11) or (SSD_CF = 20)
/INCLUDE FILIALES 
exit
EOF
SORT

NSTEP=${NJOB}_25
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Merge and SORT for a new anterior placement file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_05_${IB}_SORT_PLCANT_O.dat
SORT_I2=${DFILT}/${NJOB}_15_${IB}_SORT_PLC_O.dat
SORT_O="${EST_FPLCANT} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 3:1 - 3:, RETEND_NT 4:1 - 4: , RETSEC_NF 5:1 - 5: , RTY_NF 6:1 - 6: , RETUW_NT 7:1 - 7: , PLC_NT 8:1 - 8:
/KEYS RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, PLC_NT
exit
EOF
SORT

NSTEP=${NJOB}_30
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Merge and sort for a new anterior cession file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_10_${IB}_SORT_CESANT_O.dat
SORT_I2=${DFILT}/${NJOB}_20_${IB}_SORT_CES_O.dat
SORT_O="${EST_FCESANT} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:, END_NT 2:1 - 2: , SEC_NF 3:1 - 3: , UWY_NF 4:1 - 4: , UW_NT 5:1 - 5: , RETCTR_NF 6:1 - 6:, RETEND_NT 7:1 - 7: , RETSEC_NF 8:1 - 8: , RTY_NF 9:1 - 9: , RETUW_NT 10:1 - 10:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT
exit
EOF
SORT

#erase temporary files
#-----------------------------------------------------------------------------
NSTEP=${NJOB}_35
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"

JOBEND
