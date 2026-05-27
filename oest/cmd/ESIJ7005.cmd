#!/bin/ksh
#=============================================================================
# Application name          : ESTIMATION LOT 28
# source file               : ESIJ7005.cmd
# revision                  : $Revision: 1.3 $
# creation date             : 01/08/97
# author                    : C.G.I. (M.NAJI)
# specifications references : ESARC01F.DOC
#-----------------------------------------------------------------------------
# description :
# JOB SET: Lot 28 -  Integration of accounts and  retro mouvements 
#                      in the daily GT 
#       Variables used by the job set (defined in ESCD9001.cmd) :
#        ${EST_GTA}
#        ${EST_GTR}
#        ${EST_FDRYTRN}
#        ${EST_FRTOSTA}
#        ${EST_FACCTRTGT}
#
#-----------------
#   09/05/2008   D.GATIBELZA    MODIF: [001]
#                               ESTDOM15390 Specifications for the Omega to Visma interface
#                               ajout fichier EST_GTASW et EST_GTRSW
#-----------------
#   11/02/2009   D.GATIBELZA    MODIF: [002]
#                               ESTDOM16910 Interface Omega  Visma:  pas de retro dans le fichier GTASW.
#-----------------
#   01/04/2009   D.GATIBELZA    MODIF: [003]
#                               ESTDOM17185 non prise en compte des TRNCOD commençant par 2 ou 4 pour la constitution du fichier GTASW
#---------------
#MODIFICATION   : [004]
#Auteur         : D.GATIBELZA
#Date           : 07/02/2011
#Version        : 11.1
#Description    : 1GL
#---------------
#[005]  10/03/2011   R. CASSIS  :spot:21408 - On prend les 16 champs en plus dans la creation du IGTAA00 (step 40)
#[006]  09/03/2012   R. CASSIS  :spot:23541 - Le STATGTR et GTR sont cumules dans le IGTR00
#[007]  01/07/2015   D. FILLINGER :spot:28947 - forcer "CURGTA" comme ORICOD_LS des lignes de EST_CURGTA
#[008]  18/01/2016   Florent      :spot:29066 formatage du fichier GT
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_05
#[001] ajout des fichiers EST_GTASW et EST_GTRSW
#[004] ajout du fichier EST_IGTAA00
#-----------------------------------------------------------------
LIBEL="Size of files "
EXECKSH "touch ${EST_GTA} ${EST_GTR} ${EST_FDRYTRN} ${EST_FRTOSTA} ${EST_FACCTRTGT} ${EST_GTASW} ${EST_GTRSW} ${EST_IGTAA00}"
EXECKSH "wc ${EST_GTA} ${EST_GTR} ${EST_FDRYTRN} ${EST_FRTOSTA} ${EST_FACCTRTGT} ${EST_GTASW} ${EST_GTRSW} ${EST_IGTAA00}"

NSTEP=${NJOB}_09
#-----------------------------------------------------------------
LIBEL="Reformat to 71 cols ${EST_FACCTRTGT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FACCTRTGT} 800  1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FACCTRTGT_O.dat 1000 1"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS FORMAT_STANDARD 1:1 - 41:
/DERIVEDFIELD PLUS_16_CHAMPS "~~~~~~~~~~~~~~~GTAR"
/DERIVEDFIELD PLUS_14_CHAMPS 14"~"
/OUTFILE ${SORT_O}
/REFORMAT FORMAT_STANDARD,PLUS_16_CHAMPS,PLUS_14_CHAMPS
exit
EOF
SORT

NSTEP=${NJOB}_10
# Begin Sort
#-----------------------------------------------------------------
LIBEL="Concatenation of files ${EST_GTA}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FDRYTRN} 800  1"
SORT_I2="${DFILT}/${NJOB}_09_${IB}_SORT_FACCTRTGT_O.dat 800  1"
SORT_O="${EST_GTA} APPEND"
INPUT_TEXT $SORT_CMD << EOF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_15
#[001][003] Extraction des fichiers GTASW
#-----------------------------------------------------------------------------
LIBEL="Extraction of GTASW file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FDRYTRN} 1000 1"
SORT_O="${EST_GTASW} APPEND"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF 1:1 - 1: EN, 
        ESB_CF 2:1 - 2: EN,
        TRNCOD1_CF 6:1 - 6:1 EN
/CONDITION LIGNESSDESB ( SSD_CF=18 and ESB_CF=3 and TRNCOD1_CF!=2 and TRNCOD1_CF!=4 ) 
/INCLUDE LIGNESSDESB
exit
EOF
SORT

NSTEP=${NJOB}_19
#[005] ajout du fichier EST_IGTAA00
#-----------------------------------------------------------------
LIBEL="Save FACCTRTGT before delete"
EXECKSH "cp ${EST_FACCTRTGT} ${DSAVE}/${SVG}_RTCJ0501_FACCTRTGT.dat"
EXECKSH "gzip ${DSAVE}/${SVG}_RTCJ0501_FACCTRTGT.dat"

NSTEP=${NJOB}_20
#-----------------------------------------------------------------
LIBEL="delete of files ${EST_FDRYTRN} ${EST_FRTOSTA}"
RMFIL "${EST_FDRYTRN}"
RMFIL "${EST_FACCTRTGT}"


NSTEP=${NJOB}_24
#-----------------------------------------------------------------
LIBEL="Reformat to 71 cols ${EST_FRTOSTA}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FRTOSTA} 800  1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FRTOSTA_O.dat 1000 1"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS CHAMPS71 1:1 - 71:
/OUTFILE ${SORT_O}
/COPY
/REFORMAT CHAMPS71
exit
EOF
SORT

NSTEP=${NJOB}_25
#-----------------------------------------------------------------
LIBEL="Concatenation of files ${EST_GTR}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_24_${IB}_SORT_FRTOSTA_O.dat 1000  1"
SORT_O="${EST_GTR} APPEND"
INPUT_TEXT $SORT_CMD << EOF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_30
#[001] Extraction des fichiers GTRSW
#-----------------------------------------------------------------------------
LIBEL="Extraction of GTRSW file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_24_${IB}_SORT_FRTOSTA_O.dat 1000 1"
SORT_O="${EST_GTRSW} APPEND"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF 1:1 - 1: EN, 
        ESB_CF 2:1 - 2: EN
/CONDITION LIGNESSDESB ( SSD_CF=18 and ESB_CF=3 ) 
/INCLUDE LIGNESSDESB
exit
EOF
SORT

NSTEP=${NJOB}_34
#[005] ajout du fichier EST_IGTAA00
#-----------------------------------------------------------------
LIBEL="Save FRTOSTA before delete"
EXECKSH "cp ${EST_FRTOSTA} ${DSAVE}/${SVG}_RTCJ0501_FRTOSTA.dat"
EXECKSH "gzip ${DSAVE}/${SVG}_RTCJ0501_FRTOSTA.dat"

NSTEP=${NJOB}_35
#-----------------------------------------------------------------
LIBEL="delete of file ${EST_FRTOSTA}"
RMFIL "${EST_FRTOSTA}"

NSTEP=${NJOB}_38
#[007] forcer "CURGTA" comme ORICOD_LS des lignes de EST_CURGTA
#-----------------------------------------------------------------
LIBEL="Set ORICOD_LS=CURGTA when EBSGTA in file EST_CURGTA"
sed s/EBSGTA/CURGTA/g ${EST_CURGTA} > ${DFILT}/${NSTEP}_${IB}_CURGTA.dat

gzip -c ${EST_CURGTA}                       > ${DFILT}/SAUVEGARDE_ESIJ7005_EST_CURGTA.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_CURGTA.dat  > ${DFILT}/SAUVEGARDE_ESIJ7005_SED_CURGTA.dat.gz

#[004]
#[005]
NSTEP=${NJOB}_40
# Begin Sort
#-----------------------------------------------------------------
LIBEL="Création fichier Permanent: IGTAA00"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_GTA} 800  1"
SORT_I2="${DFILT}/${NJOB}_38_${IB}_CURGTA.dat 800  1" #[007]
SORT_O="${EST_IGTAA00}"
INPUT_TEXT $SORT_CMD << EOF
/COPY
exit
EOF
SORT

#[006]
NSTEP=${NJOB}_45
# Begin Sort
#-----------------------------------------------------------------
LIBEL="Création fichier Permanent: IGTAA00"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_STATGTR} 800  1"
SORT_I2="${EST_GTR} 800  1"
SORT_O="${EST_IGTR00}"
INPUT_TEXT $SORT_CMD << EOF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_40
#-----------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
