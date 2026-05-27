#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Filtre de tous les fichiers
# nom du script SHELL		: ESID0562.cmd
# revision			: $Revision:   1.1  $
# date de creation		: 05/09/97
# auteur			: CGI
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   Filtering files
#
#
#   Output file sort ${EST_FACCSUP}
#	             ${EST_DLRIGTAA}
#
# job launched by ESID0560.cmd
#-----------------------------------------------------------------------------
# historique des modifications
#  J.Ribot   18/09/03     creation fichier EST_FACCSUPF  a partir EST_FACCSUP12
#  J.Ribot   02/10/03     ajout test sur ${EST_VARIANTE}" = "7"
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

NSTEP=${NJOB}_07
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

NSTEP=${NJOB}_08
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


if [ "${EST_VARIANTE}" = "7"   ]
then

JOBEND

fi

NSTEP=${NJOB}_10
#Last version of ESID0560 files deletion
#-----------------------------------------------------------------
RMFIL "  `dirname ${EST_DLRIGTAA}`/${PCH}ESID0560_DLRIGTAA*.dat "

NSTEP=${NJOB}_15
# EST_GTEP screen on the subsidary and closing process date
# (EST_GTEP = TL file received from retrocessionnaire subsidiaries)
#-----------------------------------------------------------------------------
LIBEL="EST_GTEP ==> EST_DLRIGTAA ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_GTEP}"
SORT_O="${EST_DLRIGTAA} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FILLER1 1:1 - 40:,
        SSD_CF 1:1 - 1: EN,
	      BALSHEY_NF 3:1 - 3: EN,
        BALSHRMTH_NF 4:1 - 4: EN,
        BALSHRDAY_NF 5:1 - 5: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION} AND
	BALSHEY_NF   EQ ${ICLODAT_YEA} AND
	BALSHRMTH_NF EQ ${ICLODAT_MTH} AND
	BALSHRDAY_NF EQ ${ICLODAT_DAY}
/DERIVEDFIELD ZERO "0.000" CHAR 5
/INCLUDE INVENTAIRE
/OUTFILE ${SORT_O}
/REFORMAT  FILLER1,
           ZERO
/COPY
exit
EOF
SORT

JOBEND
