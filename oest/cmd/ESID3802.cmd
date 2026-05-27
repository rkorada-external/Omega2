#!/bin/ksh
#=============================================================================
# nom de l'application : ESTIMATIONS - préparation des GTA et GTR ( SNEM ) à injecter dans l'infocentre
# nom du script SHELL  : ESID3802.cmd
# revision             : $Revision:   1.1  $
# date de creation     : 09/07/99
# auteur               : ASCOTT
# references des specifications  :
#-----------------------------------------------------------------------------
# description
#   Injection of the SNEM Acceptance and Retrocession TL files into the infocenter
#
# Input files
#       EST_DLFTSNEMHIST  DFILI
#       EST_DLGTAASNEM    DFILI
#       EST_DLGTARSNEM    DFILI
#       EST_DLGTRSNEM    DFILI
#       EST_FCPLACC      DFILP
#       EST_FCTRGRO      DFILP
#       EST_FPLC      DFILP
#       EST_FSNEMHIST0      DFILP
#       EST_FSOBBLOB    DFILI
#       EST_FTECLEDASNEM  DFILI
#       EST_FTECLEDRSNEM  DFILI
#       EST_OIADVPERICASE  DFILI
#       EST_OIRDVPERICASE  DFILI
#
# Output files
#       EST_FSNEMHIST0      DFILP
#       EST_FTECLEDASNEM  DFILI
#       EST_FTECLEDRSNEM  DFILI
#
# Launch C program ESTC8801 8802 8803
#
# launched by ESID3800.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#
#===============================================================================
#  11/02/03 J. Ribot   ajout gestion retintamt_m ttecleda
#
#   01/ 06 / 04 J. Ribot ajout test sur COND2 pour garder ou pas les enregistrements
#                        des filiales non presentes dans l'inventaire (SOPT 4935)
#   24/08 /2005   M.DJELLOULI
#                      Suppression du Conditionnement COND2 sur les SNEMS.
#                      Suppression du Test de Condition au STEP 100 EST_FSNEMHIST0
#[04] 18/03/2011 R. Cassis       :spot:21408 Ajout 14 champs dans fichier EST_FTECLEDASNEM
#[05] 09/02/2011 D.GATIBELZA 1GL
#[06] 05/02/2016 Florent  :spot:29066 GT à 71 colonnes
#[07] 05/02/2016 RBE  :spot:29066 GT à 71 colonnes
#-----------------------------------------------------------------------------

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
CRE_D=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CLODAT_D=$4

# Job Initialisation
JOBINIT

# MDJ 24/08/2005 - Définition de l'Année N-1
BALSHTYEA_N1=`echo ${BALSHTYEA_NF} | awk '{print $0 - 1}'`

NSTEP=${NJOB}_05
# Merge and sort of the SNEM Acceptance file
#------------------------------------------------------------------------------
LIBEL="Sort of SNEM Acceptance Technical Ledgers File to format TTCLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLGTAASNEM} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTAA_TCLEDA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        LIGNEGT 1:1 - 39: ,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41:,
        FILLER_30_COLS 42:1 - 71:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/DERIVEDFIELD DATTRAIT "${CRE_D}~"
/DERIVEDFIELD USER "CloP~"
/DERIVEDFIELD SEPARATEUR44  43"~"
/OUTFILE ${SORT_O}
/REFORMAT LIGNEGT,
          RETKEY_CF,
          DATTRAIT,
          USER,
          DATTRAIT,
          USER,
          SEPARATEUR44,
          RETINTAMT_M,
          FILLER_30_COLS
exit
EOF
SORT

NSTEP=${NJOB}_10
# Merge and sort of the SNEM Acceptance and Retrocession files
#------------------------------------------------------------------------------
LIBEL="Sort of SNEM Acceptance - Retrocession Technical Ledgers File to format TTCLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLGTARSNEM} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTAR_TCLEDA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        LIGNEGT 1:1 - 39: ,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41:,
        FILLER_30_COLS 42:1 - 71:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/DERIVEDFIELD DATTRAIT "${CRE_D}~"
/DERIVEDFIELD USER "CloP~"
/DERIVEDFIELD SEPARATEUR44  43"~"
/OUTFILE ${SORT_O}
/REFORMAT LIGNEGT ,
          RETKEY_CF ,
          DATTRAIT,
          USER,
          DATTRAIT,
          USER,
          SEPARATEUR44,
          RETINTAMT_M,
          FILLER_30_COLS
exit
EOF
SORT

NSTEP=${NJOB}_15
# File generation in TTECLEDA table format
#-----------------------------------------------------------------------------
LIBEL="Files generation in TTECLEDA table format"
PRG=ESTC8801
export ${PRG}_I1=${EST_OIADVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_05_${IB}_SORT_TOTGTAA_TCLEDA_O.dat
export ${PRG}_I3=${EST_FCTRGRO}
export ${PRG}_I4=${EST_FCPLACC}
export ${PRG}_I5=${DFILT}/${NJOB}_10_${IB}_SORT_TOTGTAR_TCLEDA_O.dat
export ${PRG}_I6=${EST_FSOBBLOB}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAA_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_O2.dat
EXECPRG

NSTEP=${NJOB}_20
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_05_${IB}_SORT_TOTGTAA_TCLEDA_O.dat
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_TOTGTAR_TCLEDA_O.dat

#[07]
NSTEP=${NJOB}_25
# Sort of the SNEM Retrocession File
#------------------------------------------------------------------------------
LIBEL="Sort of SNEM Retrocession Technical Ledger to format TTCLEDR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLGTRSNEM} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF    27:1 - 27:,
        RETUW_NT  28:1 - 28:,
        LIGNEGT          1:1 - 39: ,
        RETKEY_CF       40:1 - 40:,
        FILLER_16_COLS  56:1 - 71:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
/DERIVEDFIELD DATTRAIT "${CRE_D}~"
/DERIVEDFIELD USER "CloP~"
/DERIVEDFIELD AJOUT_12_COLS 11"~"
/OUTFILE ${SORT_O}
/REFORMAT LIGNEGT,
          RETKEY_CF,
          DATTRAIT,
          USER,
          DATTRAIT,
          USER,
          AJOUT_12_COLS,
          FILLER_16_COLS
exit
EOF
SORT

NSTEP=${NJOB}_30
# Sort of the Retrocession File
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance - Retrocession Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_ESTC8801_FTECLEDAR_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDAR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
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

NSTEP=${NJOB}_35
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_15_${IB}_ESTC8801_FTECLEDAR_O2.dat

NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
# File generation in TTECLEDR table format
# [005] ajout:
# [005] export ${PRG}_I4=${EST_FCLIENT}
# [005] export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_FORMAT_AR_O3.dat ( postes financiers 81, 82, 83 et sinisre au comptant 84, 85 et primes différées 10 et 11 )
# [005] export ${PRG}_O4=${EST_FTECLEDAR_REJETE}
#-----------------------------------------------------------------------------
LIBEL="File generation in TTECLEDR and TTECLEDA tables format"
PRG=ESTC8802
export ${PRG}_I1=${EST_OIRDVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_30_${IB}_SORT_FTECLEDAR_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_25_${IB}_SORT_TOTGTR_O.dat
export ${PRG}_I4=${EST_FCLIENT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_FORMAT_AR_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_REJETE_O4.dat
EXECPRG



#[003]
NSTEP=${NJOB}_41
#-----------------------------------------------------------------------------
LIBEL="File generation in TTECLEDR and TTECLEDA tables format"
PRG=ESTC8806
export ${PRG}_I1=${EST_OIADVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_40_${IB}_ESTC8802_FTECLEDR_FORMAT_AR_O3.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_FORMAT_AR_O3.dat
EXECPRG

# Utiliser maintenant le fichier 41 !!!!!!!!

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_30_${IB}_SORT_FTECLEDAR_O.dat                  > ${DFILT}/${NJOB}_30_SORT_FTECLEDAR_O.dat.gz
gzip -c ${DFILT}/${NJOB}_25_${IB}_SORT_TOTGTR_O.dat                     > ${DFILT}/${NJOB}_25_SORT_TOTGTR_O.dat.gz
gzip -c ${DFILT}/${NJOB}_40_${IB}_ESTC8802_FTECLEDR_O1.dat              > ${DFILT}/${NJOB}_40_ESTC8802_FTECLEDR_O1.dat.gz
gzip -c ${DFILT}/${NJOB}_40_${IB}_ESTC8802_FTECLEDAR_O2.dat             > ${DFILT}/${NJOB}_40_ESTC8802_FTECLEDAR_O2.dat.gz
gzip -c ${DFILT}/${NJOB}_40_${IB}_ESTC8802_FTECLEDR_FORMAT_AR_O3.dat    > ${DFILT}/${NJOB}_40_ESTC8802_FTECLEDR_FORMAT_AR_O3.dat.gz
gzip -c ${DFILT}/${NJOB}_40_${IB}_ESTC8802_FTECLEDAR_REJETE_O4.dat      > ${DFILT}/${NJOB}_40_ESTC8802_FTECLEDAR_REJETE_O4.dat.gz
gzip -c ${DFILT}/${NJOB}_41_${IB}_ESTC8806_FTECLEDR_FORMAT_AR_O3.dat    > ${DFILT}/${NJOB}_41_ESTC8806_FTECLEDR_FORMAT_AR_O3.dat.gz
# ----------------------------------------
# FIN TRACES POUR l'ENVIRONNEMENT DE TEST
# ----------------------------------------


##[005]
#NSTEP=${NJOB}_41
##Gzip du fichier FTECLEDAR_REJETE_O4.dat
#LIBEL="Gzip du fichier FTECLEDAR_REJETE_O4.dat"
#gzip ${DFILT}/${NJOB}_40_${IB}_${PRG}_FTECLEDAR_REJETE_O4.dat



NSTEP=${NJOB}_45
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_30_${IB}_SORT_FTECLEDAR_O.dat
RMFIL ${DFILT}/${NJOB}_25_${IB}_SORT_TOTGTR_O.dat



NSTEP=${NJOB}_50
# Sort of the Retrocession File
#------------------------------------------------------------------------------
LIBEL="Sort of Retrocession Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_ESTC8802_FTECLEDR_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        PLC_NT 36:1 - 36:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT
exit
EOF
SORT

NSTEP=${NJOB}_55
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_40_${IB}_ESTC8802_FTECLEDR_O1.dat

NSTEP=${NJOB}_60
# Update of SSDRTO_B ( internal retrocession )
#[005] remplacement du fichier ${PRG}_I2=${EST_FPLC} par export ${PRG}_I2=${EST_FPLACEMT2}
#-----------------------------------------------------------------------------
LIBEL="Update of SSDRTO_B ( internal retrocession )"
PRG=ESTC8803
export ${PRG}_I1=${DFILT}/${NJOB}_50_${IB}_SORT_FTECLEDR_O.dat
export ${PRG}_I2=${EST_FPLACEMT2}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_O.dat
EXECPRG

NSTEP=${NJOB}_65
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_50_${IB}_SORT_FTECLEDR_O.dat

if [ "${EST_ESID3800_COND2}" = "Y" ]
then
  NSTEP=${NJOB}_70
  #-----------------------------------------------------------------------------
  LIBEL="Creation of empty SORT_FTECLEDASNEM Files"
  EXECKSH "touch ${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDASNEM_O.dat"
else
  NSTEP=${NJOB}_70
  #------------------------------------------------------------------------------
  LIBEL="Filter of FTECLEDASNEM file on subsidiaries without closing period demand"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_NOINFILE="YES"
  SORT_I="${EST_FTECLEDASNEM} 1000 1"
  SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDASNEM_O.dat 1000 1"
  INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/OMIT INVENTAIRE
/COPY
exit
EOF
  SORT
fi

# [004]
NSTEP=${NJOB}_75
# Merge of TL files
#[005] ajout fichier I4
#------------------------------------------------------------------------------
LIBEL="Merge of Technical Ledgers files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_ESTC8801_FTECLEDAA_O1.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_40_${IB}_ESTC8802_FTECLEDAR_O2.dat 1000 1"
SORT_I3="${DFILT}/${NJOB}_70_${IB}_SORT_FTECLEDASNEM_O.dat 1000 1"
SORT_I4="${DFILT}/${NJOB}_40_${IB}_ESTC8802_FTECLEDR_FORMAT_AR_O3.dat 1000 1"
SORT_O="${EST_FTECLEDASNEM} 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        ESB_CF 2:1 - 2: EN,
        TRNCOD_CF 6:1 - 6:
/KEYS TRNCOD_CF,
      SSD_CF,
      ESB_CF
exit
EOF
SORT

NSTEP=${NJOB}_80
#-----------------------------------------------------------------------------
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_15_${IB}_ESTC8801_FTECLEDAA_O1.dat
RMFIL ${DFILT}/${NJOB}_40_${IB}_ESTC8802_FTECLEDAR_O2.dat
RMFIL ${DFILT}/${NJOB}_70_${IB}_SORT_FTECLEDASNEM_O.dat

if [ "${EST_ESID3800_COND2}" = "Y" ]
then
  NSTEP=${NJOB}_85
  #-----------------------------------------------------------------------------
  LIBEL="Creation of empty SORT_FTECLEDRSNEM Files"
  EXECKSH "touch ${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDRSNEM_O.dat"
else
  NSTEP=${NJOB}_85
  # Filter of the FTECLEDRSNEM File
  #------------------------------------------------------------------------------
  LIBEL="Filter of FTECLEDRSNEM file on subsidiaries without closing period demand"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_NOINFILE="YES"
  SORT_I="${EST_FTECLEDRSNEM} 1000 1"
  SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDRSNEM_O.dat 1000 1"
  INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/OMIT INVENTAIRE
/COPY
exit
EOF
  SORT
fi

NSTEP=${NJOB}_90
# Constitution of the new FTECLEDR file
#------------------------------------------------------------------------------
LIBEL="Constitution of the new FTECLEDR file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_ESTC8803_FTECLEDR_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_85_${IB}_SORT_FTECLEDRSNEM_O.dat 1000 1"
SORT_O="${EST_FTECLEDRSNEM} 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        ESB_CF 2:1 - 2: EN,
        TRNCOD_CF 6:1 - 6:
/KEYS TRNCOD_CF,
      SSD_CF, ESB_CF
exit
EOF
SORT

NSTEP=${NJOB}_95
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_60_${IB}_ESTC8803_FTECLEDR_O.dat
RMFIL ${DFILT}/${NJOB}_85_${IB}_SORT_FTECLEDRSNEM_O.dat


NSTEP=${NJOB}_100
# Filter of FSNEMHIST0 on closing period and subsidiary
#------------------------------------------------------------------------------
LIBEL="Filter of FSNEMHIST0 on closing period and subsidiary"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FSNEMHIST0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FSNEMHIST0_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
      CLODAT_D 3:1 - 3: EN,
      BALSHTYEA_NF 3:1 - 3:4 EN,
      BALSHTMTH_NF 3:5 - 3:6 EN
/CONDITION KEEPANCIEN ( BALSHTYEA_NF = ${BALSHTYEA_NF} AND CLODAT_D LT ${CLODAT_D} )
                            OR ( BALSHTYEA_NF = ${BALSHTYEA_N1} AND BALSHTMTH_NF = 12 )
/INCLUDE KEEPANCIEN
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_105
#------------------------------------------------------------------------------
LIBEL="Generation of the new FSNEMHIST0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100_${IB}_SORT_FSNEMHIST0_O.dat 1000 1"
SORT_I2="${EST_DLFTSNEMHIST} 1000 1"
SORT_O="${EST_FSNEMHIST0} 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 4:1 - 4:,
        END_NT 5:1 - 5: EN,
        SEC_NF 6:1 - 6: EN,
        UWY_NF 7:1 - 7: EN,
        UW_NT 8:1 - 8: EN
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_110
#------------------------------------------------------------------------------
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_100_${IB}_SORT_FSNEMHIST0_O.dat

########################
# Erase temporary files #
########################
NSTEP=${NJOB}_115
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
