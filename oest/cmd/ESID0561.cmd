#!/bin/ksh
# nom de l'application           : ESTIMATIONS - INVENTAIRE
#                                  Filtre de tous les fichiers
# nom du script SHELL            : ESID0561.cmd
# revision                       : $Revision:   1.10  $
# date de creation               : 05/09/97
# auteur                         : CGI
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   Filtering files
#
# output file sort ${EST_FAMPROT}
#	           ${EST_FAPR}
#	           ${EST_FPLACEMT}
#	           ${EST_FCESSION}
#		   ${EST_FCPLACC}
#	           ${EST_IRVPERICASE}
#		   ${EST_IADPERIPRMD}
#		   ${EST_IADPERIFCT}
#		   ${EST_IADPERIFCI}
#		   ${EST_IADPERIFR}
#		   ${EST_IAVPERICASE}
#		   ${EST_IADPERICASE}
#	           ${EST_FPLACEMTCOM}
#
# job launched by ESID0560.cmd
#
#-----------------------------------------------------------------------------
# historique des modifications
#[001] 07/05/2012 R. CASSIS   :spot:23802 - Gzip fichier pour optimisation Solvency.
#                             Ajout EST_FCURSII et EST_FRATINGSII
#[002] 14/08/2012 R. Cassis   :spot:24041 - Suppression EST_FCURSII et EST_FRATINGSII
#[003] 24/02/2014 R. Cassis   :spot:25427 - Tri en mode car et pas num�rique sur cl� au lieu de filiale car non presente
#[004] 12/05/2014 R. Cassis   :spot:25427 - Ajout plc_nt au tri du fichier placement
#[005] 14/05/2014 A.Ben Jeddou:spot:26738 - Modification du tri du fichier placement - puis suppression ctl-m
#[006] 19/01/2015 R. cassis   :spot:28140 - Suppression du gzip de ESID0561 de EST_IADPERICASE0 car fichier utilis� plus loin.
#[007] 26/02/2021 M.NAJI Spira 91531  commenter les suppression des fichier permanents  
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT

# Parameters

CLODAT_D=$1

#[007]
#NSTEP=${NJOB}_00
##Last version of ESID0560 files deletion
##-----------------------------------------------------------------
#RMFIL "  `dirname ${EST_DLAGTAA}`/${PCH}ESID0560_DLAGTAA*.dat
# `dirname ${EST_DLAGTAR}`/${PCH}ESID0560_DLAGTAR*.dat
# `dirname ${EST_DLAGTR}`/${PCH}ESID0560_DLAGTR*.dat
# `dirname ${EST_DLRIGTAA}`/${PCH}ESID0560_DLRIGTAA*.dat
# `dirname ${EST_DTSTATGTAA}`/${PCH}ESID0560_DTSTATGTAA*.dat
# `dirname ${EST_FACCSUP}`/${PCH}ESID0560_FACCSUP*.dat
# `dirname ${EST_FACCTRAA}`/${PCH}ESID0560_FACCTRAA*.dat
# `dirname ${EST_FACCTRAI}`/${PCH}ESID0560_FACCTRAI*.dat
# `dirname ${EST_FAPR}`/${PCH}ESID0560_FAPR*.dat
# `dirname ${EST_FAMPROT}`/${PCH}ESID0560_FAMPROT*.dat
# `dirname ${EST_FCESSION}`/${PCH}ESID0560_FCESSION*.dat
# `dirname ${EST_FCMUSPLI}`/${PCH}ESID0560_FCMUSPLI*.dat
# `dirname ${EST_FCMUSPLIT}`/${PCH}ESID0560_FCMUSPLIT*.dat
# `dirname ${EST_FCPLACC}`/${PCH}ESID0560_FCPLACC*.dat
# `dirname ${EST_FCTREST}`/${PCH}ESID0560_FCTREST*.dat
# `dirname ${EST_FCTRGRO}`/${PCH}ESID0560_FCTRGRO_*.dat
# `dirname ${EST_FCTRGROBO}`/${PCH}ESID0560_FCTRGROBO_*.dat
# `dirname ${EST_FCTRULT}`/${PCH}ESID0560_FCTRULT*.dat
# `dirname ${EST_FLABOCY}`/${PCH}ESID0560_FLABOCY*.dat
# `dirname ${EST_FOUTTRAA}`/${PCH}ESID0560_FOUTTRAA*.dat
# `dirname ${EST_FOUTTRAI}`/${PCH}ESID0560_FOUTTRAI*.dat
# `dirname ${EST_FPLACEMT}`/${PCH}ESID0560_FPLACEMT*.dat
# `dirname ${EST_FPLACEMTCOM}`/${PCH}ESID0560_FPLACEMTCOM*.dat
# `dirname ${EST_FSEGEST}`/${PCH}ESID0560_FSEGEST*.dat
# `dirname ${EST_IADPERICASE}`/${PCH}ESID0560_IADPERICASE*.dat
# `dirname ${EST_IADPERIFCI}`/${PCH}ESID0560_IADPERIFCI*.dat
# `dirname ${EST_IADPERIFCT}`/${PCH}ESID0560_IADPERIFCT*.dat
# `dirname ${EST_IADPERIFR}`/${PCH}ESID0560_IADPERIFR*.dat
# `dirname ${EST_IADPERIPRMD}`/${PCH}ESID0560_IADPERIPRMD*.dat
# `dirname ${EST_IADVPERICASE}`/${PCH}ESID0560_IADVPERICASE*.dat
# `dirname ${EST_IAVPERICASE}`/${PCH}ESID0560_IAVPERICASE*.dat
# `dirname ${EST_IGTAA}`/${PCH}ESID0560_IGTAA*.dat
# `dirname ${EST_IGTAR}`/${PCH}ESID0560_IGTAR*.dat
# `dirname ${EST_IGTR}`/${PCH}ESID0560_IGTR*.dat
# `dirname ${EST_IRDVPERICASE}`/${PCH}ESID0560_IRDVPERICASE*.dat
# `dirname ${EST_IRVPERICASE}`/${PCH}ESID0560_IRVPERICASE*.dat
# `dirname ${EST_MVTPNA}`/${PCH}ESID0560_MVTPNA*.dat
# `dirname ${EST_OADVPERICASE}`/${PCH}ESID0560_OADVPERICASE*.dat
# `dirname ${EST_ORDVPERICASE}`/${PCH}ESID0560_ORDVPERICASE*.dat
# `dirname ${EST_TOTGTAR}`/${PCH}ESID0560_TOTGTAR*.dat
# `dirname ${EST_TOTGTR}`/${PCH}ESID0560_TOTGTR*.dat
# `dirname ${EST_TSTATGTA}`/${PCH}ESID0560_TSTATGTA*.dat
# `dirname ${EST_FSNEMHIST}`/${PCH}ESID0560_FSNEMHIST*.dat"


#####################
# Perimeters screen #
#####################
NSTEP=${NJOB}_05
#IADPERICASE perimeter screen for the subsidary and the section incoming date
#-----------------------------------------------------------------------------
LIBEL="IADPERICASE perimeter screen in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE0} 1000 1"
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
/CONDITION INVENTAIRE ${EST_SORT_CONDITION} and SECINC_D <= ${CLODAT_D}
/INCLUDE INVENTAIRE
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
#IADPERIFR perimeter screen for the subsidary and the section incoming date
#-----------------------------------------------------------------------------
LIBEL="IADPERIFR perimeter screen in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERIFR0} 1000 1"
SORT_O="${EST_IADPERIFR} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 12:1 - 12: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_20
#IADPERIFCI perimeter screen for the subsidary and the section incoming date
#-----------------------------------------------------------------------------
LIBEL="IADPERIFCI perimeter screen in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERIFCI0} 1000 1"
SORT_O="${EST_IADPERIFCI} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 14:1 - 14: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_25
#IADPERIFCT perimeter screen for the subsidary and the section incoming date
#-----------------------------------------------------------------------------
LIBEL="IADPERIFCT perimeter screen in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERIFCT0} 1000 1"
SORT_O="${EST_IADPERIFCT} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2:,
        SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
        UW_NT 5:1 - 5:,
        SSD_CF 7:1 - 7: EN
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
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
SORT_I="${EST_IADPERIPRMD0} 1000 1"
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

NSTEP=${NJOB}_45
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

NSTEP=${NJOB}_55
# EST_FCESSION0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FCESSION0 ==> EST_FCESSION ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCESSION0} 1000 1"
SORT_O="${EST_FCESSION} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 14:1 - 14: EN
/COPY
exit
EOF
SORT

#/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
#/INCLUDE INVENTAIRE

NSTEP=${NJOB}_60
#EST_FPLACEMT0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FPLACEMT0 ==> EST_FPLACEMT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FPLACEMT0} 1000 1"
SORT_O="${EST_FPLACEMT} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_63
#EST_FPLACEMTCOM0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FPLACEMTCOM0 ==> EST_FPLACEMTCOM..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FPLACEMTCOM0} 1000 1"
SORT_O="${EST_FPLACEMTCOM} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT

#[001]
NSTEP=${NJOB}_64
# execksh
#------------------------------------------------------------------------------
LIBEL="cp ${EST_FPLATXCUMALL0} ${EST_FPLATXCUMALL}"
EXECKSH_MODE=P
EXECKSH "cp ${EST_FPLATXCUMALL0} ${EST_FPLATXCUMALL}"

NSTEP=${NJOB}_65
#EST_FAPR0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FAPR0 ==> EST_FAPR..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FAPR0} 1000 1"
SORT_O="${EST_FAPR} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_70
#EST_FAMPROT0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FAMPROT0 ==> EST_FAMPROT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FAMPROT0} 1000 1"
SORT_O="${EST_FAMPROT} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT

#[003]
#/FIELDS SSD_CF 1:1 - 1:2 EN
#/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
#/INCLUDE INVENTAIRE
#/COPY
#[004]
#[005]
NSTEP=${NJOB}_75
#EST_FPLACEMT0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FPLATXCUM0 ==> EST_FPLATXCUM..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FPLATXCUM0} 1000 1"
SORT_O="${EST_FPLATXCUM} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 1:1 - 1:,
        RETSEC_NF 2:1 - 2: EN,
        RTY_NF    3:1 - 3:,
        PLC_NF    4:1 - 4:
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      PLC_NF
exit
EOF
SORT

NSTEP=${NJOB}_80
#EST_FPLACEMT0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FCURCVSN0 ==> EST_FCURCVSN..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCURCVSN0} 1000 1"
SORT_O="${EST_FCURCVSN} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
#SORT

#[001] [006]
#NSTEP=${NJOB}_07
## gzip des fichiers pour optimisation
##------------------------------------------------------------------------------
#LIBEL="gzip des fichiers pour optimisation"
#EXECKSH_MODE=P
#RMFIL "${EST_IADPERICASE0}.gz"
#
#EXECKSH "gzip ${EST_IADPERICASE0}"

########################
# Erase temporary files #
########################

NSTEP=${NJOB}_95
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"


JOBEND
