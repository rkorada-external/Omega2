#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Preparation de l'edition retrocession
# nom du script SHELL		: ESID2591.cmd
# revision			: $Revision:   1.5  $
# date de creation		: 09/97
# auteur			: C.G.I.
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   Preparation of data for concise acceptance closong period print out
#
# Input files
#       EST_FCURQUOT              DFILP
#       EST_FLIBEL1               DFILP
#       EST_FTRSLNK        DFILI
#       EST_OIADVPERICASE  DFILI
#       EST_OIRDVPERICASE  DFILI
#       EST_TOTGTAR        DFILI
#
# Launch C program ESTR7609 ESTR7611 ESTR7612 ESTR7613 ESTR7620
#
# job launched by ESID2590.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications
#---------------
#MODIFICATION   : [001]
#Auteur         : D.GATIBELZA
#Date           : 09/05/2011
#Version        : 11.1
#Description    : ESTDOM21408 OneLedger
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctsplit.cmd


# Job Initialisation
JOBINIT

# Parameters
CLODAT_D=$1
CRE_D=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
DBCLO_D=$5

NSTEP=${NJOB}_05
# Begin sort
#[001] le fichier en entrée passe à un maxi de 1000 caractères au lieu de 256 par défaut.
#------------------------------------------------------------------------------
LIBEL="Accumulation amount, accounting periods undistinguished"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_TOTGTAR} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAR_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS FILLER1 1:1 - 34:,
        TRNCOD_CF 6:1 - 6:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 20/3,
        FILLER2 36:1 - 40:,
        RETINTAMT_M 41:1 - 41:EN 20/3

/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      TRNCOD_CF,
      RETCUR_CF
/SUMMARIZE TOTAL RETAMT_M
/OUTFILE ${SORT_O}
/REFORMAT
           FILLER1,
           RETAMT_M,
           FILLER2
exit
EOF
SORT

NSTEP=${NJOB}_10
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Introduction of contract acceptation nature"
PRG=ESTR7609
export ${PRG}_I1=${EST_OIADVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_05_${IB}_SORT_GTAR_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTA_O.dat
EXECPRG

NSTEP=${NJOB}_15
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_05_${IB}_SORT_GTAR_O.dat

NSTEP=${NJOB}_20
# Begin sort
#[001] le fichier en entrée passe à un maxi de 1000 caractères au lieu de 256 par défaut.
#------------------------------------------------------------------------------
LIBEL="Sort of GTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_ESTR7609_GTA_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTA_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
exit
EOF
SORT

NSTEP=${NJOB}_25
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_10_${IB}_ESTR7609_GTA_O.dat

NSTEP=${NJOB}_30
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Introduction of contract retrocession nature and conversion in subsidiary currency"
PRG=ESTR7611
export ${PRG}_I1=${EST_OIRDVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_20_${IB}_SORT_GTA_O.dat
export ${PRG}_I3=${EST_FCURQUOT}
export ${PRG}_I4=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTIR_O.dat
EXECPRG

NSTEP=${NJOB}_35
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_20_${IB}_SORT_GTA_O.dat

NSTEP=${NJOB}_40
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Accumulation amount by SSD_CF, ESB_CF, LOB_CF, CTRNAT_CT, ACMTRS_NT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_30_${IB}_ESTR7611_FTIR_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FTIR_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:EN,
        ESB_CF 2:1 - 2:EN,
        LOB_CF 3:1 - 3:,
        CTRNAT_CT 4:1 - 4:,
        ACMTRS_NT 5:1 - 5:,
        AMT_M 6:1 - 6:EN 20/3
/KEYS SSD_CF,
      ESB_CF,
      LOB_CF,
      CTRNAT_CT,
      ACMTRS_NT
/SUMMARIZE TOTAL AMT_M
exit
EOF
SORT

NSTEP=${NJOB}_45
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Report preparation - first phase"
PRG=ESTR7612
export ${PRG}_I1=${DFILT}/${NJOB}_40_${IB}_SORT_FTIR_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_REPORTR1_O.dat
EXECPRG

NSTEP=${NJOB}_50
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_40_${IB}_SORT_FTIR_O.dat

NSTEP=${NJOB}_55
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Accumulation amount by SSD_CF, LOB_CF"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_30_${IB}_ESTR7611_FTIR_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FTIR_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:EN,
        ESB_CF 2:1 - 2:EN,
        LOB_CF 3:1 - 3:,
        CTRNAT_CT 4:1 - 4:,
        ACMTRS_NT 5:1 - 5:,
        AMT_M 6:1 - 6:EN 20/3
/KEYS SSD_CF,
      LOB_CF,
      CTRNAT_CT,
      ACMTRS_NT
/SUMMARIZE TOTAL AMT_M
/DERIVEDFIELD ETABLISSEMENT "256"
/DERIVEDFIELD SEPARATEUR "~"
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ETABLISSEMENT,
          SEPARATEUR,
          LOB_CF,
          CTRNAT_CT,
          ACMTRS_NT,
          AMT_M
exit
EOF
SORT

NSTEP=${NJOB}_60
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_30_${IB}_ESTR7611_FTIR_O.dat

NSTEP=${NJOB}_65
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Report preparation - second phase"
PRG=ESTR7613
export ${PRG}_I1=${DFILT}/${NJOB}_55_${IB}_SORT_FTIR_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_REPORTR2_O.dat
EXECPRG

NSTEP=${NJOB}_70
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_55_${IB}_SORT_FTIR_O.dat

NSTEP=${NJOB}_75
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Merge of report preparations"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_45_${IB}_ESTR7612_REPORTR1_O.dat
SORT_I2=${DFILT}/${NJOB}_65_${IB}_ESTR7613_REPORTR2_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_REPORTR_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:EN,
        ESB_CF 2:1 - 2:EN,
        LOB_CF 3:1 - 3:,
        CTRNAT_CT 4:1 - 4:
/KEYS SSD_CF,
      ESB_CF,
      LOB_CF,
      CTRNAT_CT
exit
EOF
SORT

NSTEP=${NJOB}_80
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_45_${IB}_ESTR7612_REPORTR1_O.dat
RMFIL ${DFILT}/${NJOB}_65_${IB}_ESTR7613_REPORTR2_O.dat

NSTEP=${NJOB}_85
#subject : Retrocession closing period process synthesis print out
#---------------------------------------------------------------
PRG=ESTR7620
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
CRE_D ${CRE_D}
BALSHTYEA_NF ${BALSHTYEA_NF}
BALSHTMTH_NF ${BALSHTMTH_NF}
DBCLO_D ${DBCLO_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_75_${IB}_SORT_REPORTR_O.dat
export ${PRG}_I2=${EST_FLIBEL1}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_O.dat
EXECPRG

NSTEP=${NJOB}_90
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_75_${IB}_SORT_REPORTR_O.dat

NSTEP=${NJOB}_95
#subject : Split Files by SSD
#---------------------------------------------------------------
LIBEL="Split files by SSD"
SPLIT_PREFIX=${NJOB}_85
SPLIT_PREFIX_NEW=${NCHAIN}_ESID2592
SPLIT_I=${DFILT}/${NJOB}_85_${IB}_ESTR7620_O.dat
SPLIT_SSD

########################
# Erase temporary files #
# DLSGTAR et DLSGTR etaient auparavant supprimes dans ESID2561
# Cela devient impossible du fait de l'appel 2 fois de suite
# de cette chaine et de la necessite d'avoir les fichiers en entree
########################

NSTEP=${NJOB}_100
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"
RMFIL "${EST_DLSGTAR}"
RMFIL "${EST_DLSGTR}"


JOBEND
