#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATION - INVENTAIRE
#                                 Extracting life tables 
# nom du script SHELL           : ESID0567.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 30/04/99
# auteur                        : Mehdi NAJI
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Extracting tables.
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT

# Parameters
CLODAT_D=$1

NSTEP=${NJOB}_05
#EST_FCPLACC screen on the subsidary
#-----------------------------------------------------------------------------
LIBEL="EST_FCPLACC0 ==> EST_FCPLACC ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCPLACC0} 1000 1"
SORT_O="${EST_FCPLACC} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION} 
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_10
#IAVPERICASE perimeter screen for the subsidary and the section incoming date
#-----------------------------------------------------------------------------
LIBEL="IAVPERICASE perimeter screen in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IAVPERICASE0} 1000 1"
SORT_O="${EST_IAVPERICASE} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:,
        SSD_CF 1:1 - 1: EN,
        SECINC_D 78:1 - 78: EN
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/CONDITION INVENTAIRE ${EST_SORT_CONDITION} and SECINC_D <= ${CLODAT_D}
/INCLUDE INVENTAIRE
exit
EOF
SORT

NSTEP=${NJOB}_15
#IRVPERICASE perimeter screen for the subsidary and the section incoming date 
#-----------------------------------------------------------------------------
LIBEL="IRVPERICASE perimeter screen in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRVPERICASE0} 1000 1"
SORT_O="${EST_IRVPERICASE} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        SECINC_D 78:1 - 78:
/CONDITION INVENTAIRE ${EST_SORT_CONDITION} and SECINC_D <= "${CLODAT_D}"
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT


JOBEND
