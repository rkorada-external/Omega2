#!/bin/ksh
#=============================================================================
# nom de l'application		    : ESTIMATIONS - INVENTAIRE
#                                Inventaire acceptation dommages
#								 Filtre des fichiers *0.dat 
# nom du script SHELL          : ESID2001A.cmd
# revision                     : $Revision: 1.8 $
# date de creation             : 19/03/2019 
# auteur                       : M.NAJI 
# reference des specifications :
#-----------------------------------------------------------------------------
# Description :
#   Non-life acceptance closing period process ( set 10 )
#
# Job launched by ESFD2010.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#===========================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

#set -x

# Initialization of the Job
JOBINIT

# Parameters
CRE_D=$1
BALSHTYEA_NF=$2
CLOTYP_CT=$3
SEGTYP_CT=$4
CLODAT_D=$5
SSDs=$6
SSDVRS_LL=$7
LSTCLODAT_LL=$8
SSDDEL_LL=$9

NSTEP=${NJOB}_10
#EST_FCPLACC screen on the subsidary
#-----------------------------------------------------------------------------
LIBEL="EST_FCPLACC0 ==> EST_FCPLACC ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCPLACC0} 1000 1"							# <== ESDJ0110.cmd
SORT_O="${EST_FCPLACC} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT





NSTEP=${NJOB}_20
#IADPERICASE perimeter screen for the subsidary and the section incoming date
#-----------------------------------------------------------------------------
LIBEL="IADPERICASE perimeter screen in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE0} 1000 1"						# <== ESDJ0110.cmd
SORT_O="${EST_IADPERICASE} OVERWRITE 1000 1"
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
/CONDITION INVENTAIRE ${EST_SORT_CONDITION} and SECINC_D <= ${PARM_CLODAT_D}
/INCLUDE INVENTAIRE
exit
EOF
SORT



NSTEP=${NJOB}_30
# IADPERIPRMD perimeter screen for the subsidary and the section incoming date
#-----------------------------------------------------------------------------
LIBEL="IADPERIPRMD perimeter screen in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERIPRMD0} 1000 1"							# <=== ESID0060.cmd
SORT_O="${EST_IADPERIPRMD} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 11:1 - 11: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT




NSTEP=${NJOB}_40
#EST_FCTRGRO0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FCTRGRO0 ==> EST_FCTRGRO ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCTRGRO0} 1000 1"							# <== ESDJ0110.cmd
SORT_O="${EST_FCTRGRO} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 5:1 - 5: EN,
        CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2:,
        SEC_NF 3:1 - 3:,
        UWY_NF 21:1 - 21:,
        SEGTYP_CT 6:1 - 6:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
        UWY_NF
/CONDITION INVENTAIRE ${EST_SORT_CONDITION} and SEGTYP_CT = "A"
/INCLUDE INVENTAIRE
exit
EOF
SORT




NSTEP=${NJOB}_50
# EST_MVTPNA screen on the subsidary
#-----------------------------------------------------------------------------
LIBEL="EST_MVTPNA0 ==> EST_MVTPNA ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_MVTPNA0} 1000 1"								# <==== ESID0070.cmd   ? ESID0080.cmd
SORT_O="${EST_MVTPNA} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        BALSHEY_NF 3:1 - 3: EN,
        BALSHRMTH_NF 4:1 - 4: EN,
        BALSHRDAY_NF 5:1 - 5: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION} AND
        BALSHEY_NF   EQ ${ICLODAT_YEA} AND
        BALSHRMTH_NF EQ ${ICLODAT_MTH} AND
        BALSHRDAY_NF EQ ${ICLODAT_DAY}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT



NSTEP=${NJOB}_60
# Split of EST_MVTPNA on accounting transaction code
#[009] Ajout "11104102" pour le fichier *DLGTAFACPRE_O3.dat
#[004]
#-----------------------------------------------------------------------------
LIBEL="Split of EST_MVTPNA on accounting transaction code"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_MVTPNA} 1000 1"									# <=== ESID0562.cmd  EST_MVTPNA0
SORT_O="${EST_MVTPNAC}"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF   6:1 - 6:,
        CTR_NF      8:1 - 8:,
        END_NT      9:1 - 9:,
        SEC_NF     10:1 - 10:,
        UWY_NF     11:1 - 11:,
        UW_NT      12:1 - 12:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/CONDITION PNAC TRNCOD_CF EQ "11410000" OR TRNCOD_CF EQ "11430000" OR TRNCOD_CF EQ "11436000"
/OUTFILE ${SORT_O}
/INCLUDE PNAC


##[006]
#NSTEP=${NJOB}_70
##EST_DTSTATGTAA0 screen
##-----------------------------------------------------------------------------
#LIBEL="EST_DTSTATGTAA0 ==> EST_DTSTATGTAA ..."
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${EST_DTSTATGTAA0} 1000 1"						#<=== ESDJ7000.cmd  ESID1010.cmd
#SORT_O="${EST_DTSTATGTAA} OVERWRITE"
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS SSD_CF 1:1 - 1: EN
#/CONDITION INVENTAIRE  ${EST_SORT_CONDITION}
#/INCLUDE INVENTAIRE
#/COPY
#exit
#EOF
#SORT


JOBEND
