#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Filtre de tous les fichiers
# nom du script SHELL		: ESID0568.cmd
# revision			: $Revision:   1.1  $
# date de creation		: 09/02/04
# auteur			: CGI
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   Filtering files
#
#
#   Output file sort ${EST_FACCSUP}
#                    ${EST_FACCSUPF}
#                    ${EST_IAVPERICASE}
#                    ${EST_IRVPERICASE}
#                    ${EST_FCPLACC}
#
# job launched by ESID0560.cmd
#-----------------------------------------------------------------------------
# historique des modifications
#[001] 10/03/2016 R. Cassis :spot:29162 Ajout creation IADVPERICASE en clodat 1231
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Parameters

CLODAT_D=$1

NSTEP=${NJOB}_05
#EST_FACCSUP0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FACCSUP0 ==> EST_FACCSUP..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FACCSUP0} 1000 1"
SORT_O="${EST_FACCSUP} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_10
#EST_FACCSUP0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FACCSUP12 ==> EST_FACCSUPF..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FACCSUP12} 1000 1"
SORT_O="${EST_FACCSUPF} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_15
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

#[001]
NSTEP=${NJOB}_16
#EST_IADVPERICASE0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_IADVPERICASE0 ==> EST_IADVPERICASE ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADVPERICASE0} 1000 1"
SORT_O="${EST_IADVPERICASE} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_20
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

NSTEP=${NJOB}_25
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

NSTEP=${NJOB}_30
#EST_FLIFPLN screen
#-----------------------------------------------------------------------------
LIBEL="EST_FLIFPLN0 ==> EST_FLIFPLN..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FLIFPLN0} 1000 1"
SORT_O="${EST_FLIFPLN} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT

JOBEND
