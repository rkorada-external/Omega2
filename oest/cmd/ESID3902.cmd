#!/bin/ksh
#=============================================================================
# nom de l'application           : ESTIMATIONS
#                                  Generation of a perimeter file
# nom du script SHELL            : ESID3902.cmd
# revision                       : $Revision: 1.1.1.1 $
# date de creation               : 13/07/1999
# auteur                         : ASCOTT
# references des specifications  :
#-----------------------------------------------------------------------------
# description : :spot:23802 Fusion des Fichiers IFRS et EBS
#
# Input files
#       EST_FCTRSTAT_EBS		DFILI
#       EST_FSEGSTAT_IFRS		DFILI
#
# Output files
#       EST_FCTRSTAT		DFILP
#       EST_FSEGSTAT		DFILP
#
# job launched by ESID3900.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 29/08/2012 R. Cassis :spot:24122   Maj solvency II - tri-fusion des fichiers
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT

# No Parameters

NSTEP=${NJOB}_10
# Fusionne les fichiers EST_FT_IFRS avec EST_FT_EBS
#------------------------------------------------------------------------------
LIBEL="Touch les fichiers si innexistants"
EXECKSH_MODE=P
EXECKSH "touch ${EST_FSEGSTAT_EBS} ${EST_FSEGSTAT_IFRS} ${EST_FCTRSTAT_EBS} ${EST_FCTRSTAT_IFRS}"

#[001]
NSTEP=${NJOB}_20
# Fusionne les fichiers EST_FT_IFRS avec EST_FT_EBS
#------------------------------------------------------------------------------
LIBEL="Fusionne les fichiers EST_FCTRSTAT_EBS avec EST_FCTRSTAT_IFRS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCTRSTAT_IFRS} 2000 1"
SORT_I2="${EST_FCTRSTAT_EBS} 2000 1"
SORT_O="${EST_FCTRSTAT} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF   1:1 -   1:,
        END_NT   2:1 -   2:,
        SEC_NF   3:1 -   3:,
        UWY_NF   4:1 -   4:,
        UW_NT    5:1 -   5:,
        PRS_CF 206:1 - 206:
/KEYS	CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      PRS_CF
exit
EOF
SORT

#[001]
NSTEP=${NJOB}_30
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Fusionne les fichiers EST_FSEGSTAT_EBS avec EST_FSEGSTAT_IFRS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FSEGSTAT_IFRS} 2000 1"
SORT_I2="${EST_FSEGSTAT_EBS} 2000 1"
SORT_O="${EST_FSEGSTAT} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF     1:1 -   1:,
        ESB_CF     2:1 -   2:,
        SEG_NF     3:1 -   3:,
        UWY_NF     4:1 -   4:,
        EGPCUR_CF  5:1 -   5:,
        PRS_CF   106:1 - 106:
/KEYS SSD_CF,
      ESB_CF,
      SEG_NF,
      UWY_NF,
      EGPCUR_CF,
      PRS_CF
exit
EOF
SORT

NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NCHAIN}*_${IB}_*.dat"

JOBEND
