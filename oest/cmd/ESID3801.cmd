#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -     
#                             pr�paration des GTA et GTR � injecter dans l'infocentre
# nom du script SHELL		: ESID3801.cmd
# revision			        : $Revision:   1.2  $
# date de creation		    : 09/07/99
# auteur			        : ASCOTT
#-----------------------------------------------------------------------------
# description:              Generation of the Acceptance and Retrocession TL files
#
# Input files
#       EST_DLREJGTAA       DFILP
#       EST_DLREJGTAR       DFILP
#       EST_DLREJGTR        DFILP
#       EST_FCPLACC         DFILP
#       EST_FCTRGRO         DFILP
#       EST_FPLC            DFILP
#       EST_FSOBBLOB        DFILI
#       EST_FSSDACTR        DFILI
#       EST_FTECLEDA        DFILP
#       EST_FTECLEDR        DFILP
#       EST_OIADVPERICASE   DFILI
#       EST_OIRDVPERICASE   DFILI
#       EST_TOTGTAA         DFILI
#       EST_TOTGTAR         DFILI
#       EST_TOTGTR          DFILI
#
# Output files
#       EST_FTECLEDA        DFILP
#       EST_FTECLEDR        DFILP
#
# Launch C program ESTC8801 8802 8803
#
# launched by ESID3800.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#===============================================================================
#  11/02/03 J. Ribot   ajout gestion retintamt_m ttecleda
#
#  01/ 06 / 04 J. Ribot ajout test sur COND2 pour garder ou pas les enregistrements
#                       des filiales non presentes dans l'inventaire (SOPT 4935)
#---------------
#MODIFICATION   : [003]
#Auteur         : D.GATIBELZA
#Date           : 09/02/2011
#Version        : 11.1
#Description    : 1GL
#[004]  09/03/2011  R. Cassis       :spot:21408 Prise en compte du mode de traitement MODETRT_CF
#[005]  08/11/2011  R. Cassis       :spot:22864 Correction sur les mouvements GTAR. Ajout conditions tri retro.
#[006]  28/02/2012  R. Cassis       :spot:23466 Prise en compte des mouvements avec CURGTA comme origine egalement
#[007]  05/03/2012  R. Cassis       :spot:23497 On ne prend plus les mouvements avec CURGTA comme identifiant col 57
#[008]  25/06/2012  Roger Cassis    :spot:23802 - On ne prend pas les EBSGTA
#[009]  03/09/2012  Roger Cassis    :spot:24041 - Solvency 2 : Gestion cond4 pour fichiers DLDSIIGT
#[010]  12/03/2014  C. Despret      :spot:25427 - Retirer les ecritures EBSGTA pour la retro
#[011]  17/06/2014  C. Despret      :spot:26986 - En variante 5 le ESID2560 est en NOGO, aussi les fichier EST_DLTOTGTAR n'est pas cree 
#[012]  07/10/2014  ABJ             :spot:25773 Filtrer les lignes Gaap 5 
#[013]  12/06/2015  SAS             :spot:28694 ajout des steps 11A pour la table A de la segmentation LIFE
#[014]  30/06/2015  D. Fillinger    :spot:28947 Filtre des analytiques dans la g�n�ration de l'interface 1GL
#[015]  18/01/2016  Florent         :spot:29066 formatage du fichier GT
#[016]  27/06/2016  Roger           :spot:30790 Ajout gzip pour traces fichiers et Controle du fichier FTECLEDA_REP.dat
#[017]  10/09/2018  M.NAJI 			:add UWY_NF in TCTRGRO , spira 57605
#[018]  01/07/2021  Roger           :spira:93492 Dans le tri STEP09 sur condition GTAR2 changement > en >= pour prendre les ouvertures du CURGTA
#[019]  16/07/2025 M.NAJI  : US 5849 SERQS 
#-----------------------------------------------------------------------------
# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Get input parameters
CRE_D=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CLODAT_D=$4
MODETRT_CF=$5
# MODETRT_CF => M = Mouvements du mois non comptabilis�s
#               C = Mouvements comptabilis�s depuis le d�but de l'ann�e

# Job Initialisation
JOBINIT

#[004]
#[008]
if [ "${MODETRT_CF}" = "M" ]
then

  NSTEP=${NJOB}_03
  #------------------------------------------------------------------------------
  # Merge and sort of the Acceptance file
  #------------------------------------------------------------------------------
  LIBEL="Get data <= current Balance sheet"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_GTA} 1000 1"
  SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS BALSHEY_NF       3:1 -  3: EN,
        BALSHRMTH_NF     4:1 -  4: EN,
        TRNCOD1_CF       6:1 -  6:1,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/CONDITION COND_GTAA0 ( TRNCOD1_CF eq "1" or TRNCOD1_CF EQ "3" ) and
                      ( ${BALSHTYEA_NF} > BALSHEY_NF or ( ${BALSHTYEA_NF} EQ BALSHEY_NF and ${BALSHTMTH_NF} >= BALSHRMTH_NF ) )
/OUTFILE ${SORT_O}
/INCLUDE COND_GTAA0
exit
EOF
  SORT

  NSTEP=${NJOB}_04
  #------------------------------------------------------------------------------
  # Merge and sort of the Acceptance file
  #------------------------------------------------------------------------------
  LIBEL="Get data <= current Balance sheet"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_GTR} 1000 1"
  SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS BALSHEY_NF       3:1 -  3: EN,
        BALSHRMTH_NF     4:1 -  4: EN,
        TRNCOD1_CF       6:1 -  6:1,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/CONDITION COND_GTR0 ( ${BALSHTYEA_NF} > BALSHEY_NF or ( ${BALSHTYEA_NF} EQ BALSHEY_NF and ${BALSHTMTH_NF} >= BALSHRMTH_NF ) )
/OUTFILE ${SORT_O}
/INCLUDE COND_GTR0
exit
EOF
  SORT

fi

#[003]
#[004]
#[008]
#[009]
# pour variante 5 ( EST_ESID3800_COND3 ), Prendre le IGTAA00, pour fabriquer un TOTGTAA qu'avec les mouvements c�dante.
# sinon, prendre ce qu'il y a en dessous.
NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
# Merge and sort of the Acceptance file
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance Technical Ledgers File to format TTCLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
if [ "${MODETRT_CF}" = "M" ]
then
  SORT_I="${DFILT}/${NJOB}_03_${IB}_SORT_GTAA_O.dat 1000 1"
  if [ "${EST_ESID3800_COND3}" = "N" ]
  then
      SORT_I2="${EST_DLTOTGTAA}  1000 1"
  fi
else
  SORT_I="${EST_CURGTA} 1000 1"
  if [ "${EST_ESID3800_COND1}" = "Y" ]
  then
      SORT_I2="${EST_DLREJGTAA} 1000 1"
  fi
fi
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTAA_FTCLEDA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:EN,
        BALSHEY_NF       3:1 -  3: EN,
        BALSHRMTH_NF     4:1 -  4: EN,
        TRNCOD1_CF       6:1 -  6:1,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        LIGNEGT          1:1 - 39:,
        RETKEY_CF       40:1 - 40:,
        RETINTAMT_M     41:1 - 41:,
        FILLER_30_COLS  42:1 - 71:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/CONDITION COND_GTAA0 ( TRNCOD1_CF eq "1" or TRNCOD1_CF EQ "3" ) 
/DERIVEDFIELD DATTRAIT "${CRE_D}~"
/DERIVEDFIELD USER "CloP~"
/DERIVEDFIELD SEPARATEUR44  43"~"
/OUTFILE ${SORT_O}
/INCLUDE COND_GTAA0
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

# [004] [005] [006] [007] [018]
NSTEP=${NJOB}_09
#------------------------------------------------------------------------------
# Create MVT and CUR files
#------------------------------------------------------------------------------
LIBEL="Create MVT and CUR files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
if [ "${EST_ESID3800_COND3}" = "N" ]
then
  SORT_I="${EST_IGTAR} 1000 1"
else
  SORT_I="${EST_GTA} 1000 1"
fi
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IGTARMVT_O.dat OVERWRITE 1000 1 "
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_IGTARCUR_O.dat OVERWRITE 1000 1"
#SORT_O3="${DFILI}/${NSTEP}_${IB}_SORT_IGTARCUR_OMITPOURCTL.dat OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS BALSHEY_NF       3:1 -  3: EN,
        BALSHRMTH_NF     4:1 -  4: EN,
        TRNCOD1_CF       6:1 -  6:1,
        ORICOD_LS       57:1 - 57:
/CONDITION COND_GTAR0 ( TRNCOD1_CF eq "2" or TRNCOD1_CF EQ "4" ) and (ORICOD_LS NE "CURGTA" and ORICOD_LS NE "CURGTAR" and ORICOD_LS NE "CURGTA_PO") and
                      ( ${BALSHTYEA_NF} > BALSHEY_NF or ( ${BALSHTYEA_NF} EQ BALSHEY_NF and ${BALSHTMTH_NF} >= BALSHRMTH_NF ) )
/CONDITION COND_GTAR2  ( TRNCOD1_CF eq "2" or TRNCOD1_CF EQ "4" ) and (ORICOD_LS EQ "CURGTA" or ORICOD_LS EQ "CURGTAR" or ORICOD_LS EQ "CURGTA_PO") and
                      ( ${BALSHTYEA_NF} > BALSHEY_NF or ( ${BALSHTYEA_NF} EQ BALSHEY_NF and ${BALSHTMTH_NF} >= BALSHRMTH_NF ) )
/OUTFILE ${SORT_O}
/INCLUDE COND_GTAR0
/OUTFILE ${SORT_O2}
/INCLUDE COND_GTAR2

exit
EOF
  SORT


# [003]
# [004]
# [009]
# pour variante 5 ( EST_ESID3800_COND3 ), Prendre le IGTAA00, pour fabriquer un TOTGTAR qu'avec les mouvements c�dante.
# sinon, prendre ce qu'il y a en dessous.
NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
# Merge and sort of the Acceptance and Retrocession files
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance - Retrocession Technical Ledgers File format TTCLEDAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
if [ "${MODETRT_CF}" = "M" ]
then
  SORT_I="${DFILT}/${NJOB}_09_${IB}_SORT_IGTARMVT_O.dat 1000 1"
  if [ "${EST_ESID3800_COND3}" = "N" ]
  then
      SORT_I2="${EST_DLTOTGTAR} 1000 1"
  fi
else
  SORT_I="${DFILT}/${NJOB}_09_${IB}_SORT_IGTARCUR_O.dat 1000 1"
# [014] suppression du step 02 (les EBS sont filtrees au step 90)
  #SORT_I2="${DFILT}/${NJOB}_09B_${IB}_SORT_DLTOTGTAR_O_EBS.dat 1000 1"
  if [ "${EST_ESID3800_COND1}" = "Y" ]
  then
    SORT_I3="${EST_DLREJGTAR} 1000 1"
  fi
#[009]
#	if [ "${EST_ESID3800_COND4}" = "Y" ]
#	then
#		SORT_I3="${EST_DLDSIIGTAR} 1000 1"
#	fi
fi
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTAR_FTCLEDAR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS BALSHEY_NF       3:1 -  3: EN,
        BALSHRMTH_NF     4:1 -  4: EN,
        TRNCOD1_CF       6:1 -  6:1,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        LIGNEGT          1:1 - 39:,
        RETKEY_CF       40:1 - 40:,
        RETINTAMT_M     41:1 - 41:,
        FILLER_30_COLS  42:1 - 71:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/DERIVEDFIELD DATTRAIT "${CRE_D}~"
/DERIVEDFIELD USER "CloP~"
/DERIVEDFIELD SEPARATEUR44  43"~"
/CONDITION COND_GTAR0 ( TRNCOD1_CF EQ "2" or TRNCOD1_CF EQ "4" ) 
/INCLUDE COND_GTAR0
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

if [ "${EST_ESID3800_COND3}" = "Y" ]
then

  NSTEP=${NJOB}_11A
  #EST_FCTRGRO0 screen
  #-----------------------------------------------------------------------------
  LIBEL="EST_FCTRGRO0 ==> EST_FCTRGRO ..."
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_FCTRGRO0} 1000 1"
  SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_FCTRGRO.dat 1000 1 OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 5:1 - 5: EN,
        CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2:,
        SEC_NF 3:1 - 3:,
        UWY_NF    21:1 - 21:,
       SEGTYP_CT 6:1 - 6:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
	  UWY_NF
/CONDITION INVENTAIRE SEGTYP_CT = "A"
/INCLUDE INVENTAIRE
exit
EOF
  SORT

  NSTEP=${NJOB}_11B
  #------------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  LIBEL="cp ${EST_FCPLACC0} ${DFILT}/${NSTEP}_11B_${IB}_SORT_O_FCPLACC.dat"
  EXECKSH "cp ${EST_FCPLACC0} ${DFILT}/${NSTEP}_${IB}_SORT_O_FCPLACC.dat"

   NSTEP=${NJOB}_12
   #-----------------------------------------------------------------------------
   LIBEL="Merge of OADVPERICASE and IADVPERICASE Files..."
   SORT_WDIR=${SORTWORK}
   SORT_CMD=`CFTMP`
   SORT_I="${EST_IADVPERICASE0} 1000 1"
   SORT_I2="${EST_OADVPERICASE0} 1000 1"
   SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_OIADVPERICASE.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:
/KEYS CTR_NF,
       END_NT,
       SEC_NF,
       UWY_NF,
       UW_NT
exit
EOF
  SORT

  NSTEP=${NJOB}_13
  #-----------------------------------------------------------------------------
  LIBEL="Merge of ORDVPERICASE0 and IRDVPERICASE0 Files..."
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_IRDVPERICASE0} 1000 1"
  SORT_I2="${EST_ORDVPERICASE0} 1000 1"
   SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_OIRDVPERICASE.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
  SORT

else
  NSTEP=${NJOB}_14
  #------------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  LIBEL="cp ${EST_OIADVPERICASE} ${DFILT}/${NJOB}_12_${IB}_SORT_O_OIADVPERICASE.dat"
  EXECKSH "cp ${EST_OIADVPERICASE} ${DFILT}/${NJOB}_12_${IB}_SORT_O_OIADVPERICASE.dat"
  EXECKSH "cp ${EST_OIRDVPERICASE} ${DFILT}/${NJOB}_13_${IB}_SORT_O_OIRDVPERICASE.dat"
  EXECKSH "cp ${EST_FCTRGRO} ${DFILT}/${NJOB}_11A_${IB}_SORT_O_FCTRGRO.dat"
  EXECKSH "cp ${EST_FCPLACC} ${DFILT}/${NJOB}_11B_${IB}_SORT_O_FCPLACC.dat"
fi

NSTEP=${NJOB}_15
#------------------------------------------------------------------------------
# File generation in TTECLEDA table format
#-----------------------------------------------------------------------------
LIBEL="Files generation in TTECLEDA table format"
PRG=ESTC8801
export ${PRG}_I1=${DFILT}/${NJOB}_12_${IB}_SORT_O_OIADVPERICASE.dat
export ${PRG}_I2=${DFILT}/${NJOB}_05_${IB}_SORT_TOTGTAA_FTCLEDA_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_11A_${IB}_SORT_O_FCTRGRO.dat
export ${PRG}_I4=${DFILT}/${NJOB}_11B_${IB}_SORT_O_FCPLACC.dat
export ${PRG}_I5=${DFILT}/${NJOB}_10_${IB}_SORT_TOTGTAR_FTCLEDAR_O.dat
export ${PRG}_I6=${EST_FSOBBLOB}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAA_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_O2.dat
EXECPRG

#------------------------------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_12_${IB}_SORT_O_OIADVPERICASE.dat      > ${DFILT}/${NJOB}_12_SORT_O_OIADVPERICASE.dat.gz
gzip -c ${DFILT}/${NJOB}_05_${IB}_SORT_TOTGTAA_FTCLEDA_O.dat    > ${DFILT}/${NJOB}_05_SORT_TOTGTAA_FTCLEDA_O.dat.gz
gzip -c ${DFILT}/${NJOB}_11A_${IB}_SORT_O_FCTRGRO.dat           > ${DFILT}/${NJOB}_11A_SORT_O_FCTRGRO.dat.gz
gzip -c ${DFILT}/${NJOB}_11B_${IB}_SORT_O_FCPLACC.dat           > ${DFILT}/${NJOB}_11B_SORT_O_FCPLACC.dat.gz
gzip -c ${DFILT}/${NJOB}_10_${IB}_SORT_TOTGTAR_FTCLEDAR_O.dat   > ${DFILT}/${NJOB}_10_SORT_TOTGTAR_FTCLEDAR_O.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAA_O1.dat         > ${DFILT}/${NSTEP}_${PRG}_FTECLEDAA_O1.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_O2.dat         > ${DFILT}/${NSTEP}_${PRG}_FTECLEDAR_O2.dat.gz
#------------------------------------------------------------------------------

NSTEP=${NJOB}_20
#Temporary files deletion
LIBEL="Temporary files deletion"
#RMFIL ${DFILT}/${NJOB}_05_${IB}_SORT_TOTGTAA_FTCLEDA_O.dat
#RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_TOTGTAR_FTCLEDAR_O.dat


# [003]
# [009]
# pour variante 5 ( EST_ESID3800_COND3 ), Prendre le CURGTR et le GTR, pour fabriquer un TOTGTR
# sinon, prendre ce qu'il y a en dessous.
NSTEP=${NJOB}_25
#------------------------------------------------------------------------------
# Sort of the Retrocession File
#------------------------------------------------------------------------------
LIBEL="Sort of Retrocession Technical Ledger to format TTCLEDR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#MOUVEMENTS NON COMPTABILISES
if [ "${MODETRT_CF}" = "M" ]
then
    SORT_I="${DFILT}/${NJOB}_04_${IB}_SORT_GTR_O.dat 1000 1"
    if [ "${EST_ESID3800_COND3}" = "N" ]
    then
        SORT_I2="${EST_DLTOTGTR} 1000 1"
    fi
#MOUVEMENTS COMPTABILISES
else
    SORT_I="${EST_CURGTR} 1000 1"
    if [ "${EST_ESID3800_COND1}" = "Y" ]
    then
        SORT_I2="${EST_DLREJGTR} 1000 1"
    fi
#[009]
#	if [ "${EST_ESID3800_COND4}" = "Y" ]
#	then
#		SORT_I3="${EST_DLDSIIGTR} 1000 1"
#	fi
fi
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTR_FTECLEDR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:EN,
        BALSHEY_NF       3:1 -  3:EN,
        BALSHRMTH_NF     4:1 -  4:EN,
        TRNCOD1_CF       6:1 -  6:1,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
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
/CONDITION COND_GTR (TRNCOD1_CF EQ "2" or TRNCOD1_CF EQ "4") 
/DERIVEDFIELD AJOUT_11_COLS 11"~"
/INCLUDE COND_GTR
/OUTFILE ${SORT_O}
/REFORMAT LIGNEGT,
          RETKEY_CF,
          DATTRAIT,
          USER,
          DATTRAIT,
          USER,
          AJOUT_11_COLS,
          FILLER_16_COLS
exit
EOF
SORT

NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
# Sort of the Retrocession File
#[003] ${DFILT}/${NJOB}_15_${IB}_ESTC8801_FTECLEDAR_O2.dat 1000 1"
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance - Retrocession Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_ESTC8801_FTECLEDAR_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDAR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF   24:1 - 24:,
        RETEND_NT   25:1 - 25:,
        RETSEC_NF   26:1 - 26:,
        RTY_NF      27:1 - 27:,
        RETUW_NT    28:1 - 28:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
exit
EOF
SORT

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_25_${IB}_SORT_TOTGTR_FTECLEDR_O.dat > ${DFILT}/${NJOB}_25_SORT_TOTGTR_FTECLEDR_O.dat.gz
# ----------------------------------------
# FIN TRACES POUR l'ENVIRONNEMENT DE TEST
# ----------------------------------------

NSTEP=${NJOB}_35
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_15_${IB}_ESTC8801_FTECLEDAR_O2.dat


NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
# File generation in TTECLEDR table format
# [003] ajout:
# [003] export ${PRG}_I4=${EST_FCLIENT}
# [003] export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_FORMAT_AR_O3.dat ( postes financiers 81, 82, 83 et sinisre au comptant 84, 85 et primes diff�r�es 10 et 11 )
# [003] export ${PRG}_O4=${EST_FTECLEDAR_REJETE}
# [003] modif I3: ${DFILT}/${NJOB}_25_${IB}_SORT_TOTGTR_FTECLEDR_O.dat
#-----------------------------------------------------------------------------
LIBEL="File generation in TTECLEDR and TTECLEDA tables format"
PRG=ESTC8802
export ${PRG}_I1=${DFILT}/${NJOB}_13_${IB}_SORT_O_OIRDVPERICASE.dat
export ${PRG}_I2=${DFILT}/${NJOB}_30_${IB}_SORT_FTECLEDAR_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_25_${IB}_SORT_TOTGTR_FTECLEDR_O.dat
export ${PRG}_I4=${EST_FCLIENT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_FORMAT_AR_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_REJETE_O4.dat
EXECPRG

#------------------------------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_13_${IB}_SORT_O_OIRDVPERICASE.dat       > ${DFILT}/${NJOB}_13_SORT_O_OIRDVPERICASE.dat.gz
gzip -c ${DFILT}/${NJOB}_30_${IB}_SORT_FTECLEDAR_O.dat           > ${DFILT}/${NJOB}_30_SORT_FTECLEDAR_O.dat.gz
gzip -c ${DFILT}/${NJOB}_25_${IB}_SORT_TOTGTR_FTECLEDR_O.dat     > ${DFILT}/${NJOB}_25_SORT_TOTGTR_FTECLEDR_O.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_O1.dat           > ${DFILT}/${NSTEP}_${PRG}_FTECLEDR_O1.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_O2.dat          > ${DFILT}/${NSTEP}_${PRG}_FTECLEDAR_O2.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_FORMAT_AR_O3.dat > ${DFILT}/${NSTEP}_${PRG}_FTECLEDR_FORMAT_AR_O3.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_REJETE_O4.dat   > ${DFILT}/${NSTEP}_${PRG}_FTECLEDAR_REJETE_O4.dat.gz
#------------------------------------------------------------------------------

if [ "${MODETRT_CF}" = "M" ]
then
   #[003]
   NSTEP=${NJOB}_41
   #-----------------------------------------------------------------------------
   LIBEL="File generation in TTECLEDR and TTECLEDA tables format"
   PRG=ESTC8806
   export ${PRG}_I1=${DFILT}/${NJOB}_12_${IB}_SORT_O_OIADVPERICASE.dat
   export ${PRG}_I2=${DFILT}/${NJOB}_40_${IB}_ESTC8802_FTECLEDR_FORMAT_AR_O3.dat
   export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_FORMAT_AR_O3.dat
   EXECPRG

	#------------------------------------------------------------------------------
	gzip -c ${DFILT}/${NJOB}_12_${IB}_SORT_O_OIADVPERICASE.dat       > ${DFILT}/${NJOB}_12_SORT_O_OIADVPERICASE.dat.gz
	gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_FORMAT_AR_O3.dat > ${DFILT}/${NSTEP}_${PRG}_FTECLEDR_FORMAT_AR_O3.dat.gz
	#------------------------------------------------------------------------------
fi

NSTEP=${NJOB}_45
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_30_${IB}_SORT_FTECLEDAR_O.dat
RMFIL ${DFILT}/${NJOB}_25_${IB}_SORT_TOTGTR_FTECLEDR_O.dat
#[003]

#----------------------------------------
# FTECLEDA
#----------------------------------------

NSTEP=${NJOB}_50
#------------------------------------------------------------------------------
# Merge des fichiers
#[003] ajout fichier I3
#------------------------------------------------------------------------------
LIBEL="Merge des fichiers"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_ESTC8801_FTECLEDAA_O1.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_40_${IB}_ESTC8802_FTECLEDAR_O2.dat 1000 1"
if [ "${MODETRT_CF}" = "M" ]
then
   SORT_I3="${DFILT}/${NJOB}_41_${IB}_ESTC8806_FTECLEDR_FORMAT_AR_O3.dat 1000 1"
else
   SORT_I3="${DFILT}/${NJOB}_40_${IB}_ESTC8802_FTECLEDAR_REJETE_O4.dat 1000 1"
fi
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDAA_O1.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/COPY
exit
EOF
SORT

# [004]
#NSTEP=${NJOB}_70
#if [ "${EST_ESID3800_COND2}" = "Y" ] || [ "${EST_ESID3800_COND3}" = "Y" ] || [ "${MODETRT_CF}" = "M" ]
#then
#    NSTEP=${NJOB}_70
#    #------------------------------------------------------------------------------
#    #-----------------------------------------------------------------------------
#    LIBEL="Creation of empty SORT_FTECLEDA Files"
#    EXECKSH "touch ${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_O.dat"
#else
#    NSTEP=${NJOB}_70
#    #------------------------------------------------------------------------------
#    # Filter of the FTECLEDA File
#    #------------------------------------------------------------------------------
#    LIBEL="Filter of FTECLEDA file on subsidiaries without closing period demand"
#    SORT_WDIR=${SORTWORK}
#    SORT_CMD=`CFTMP`
#    SORT_I="${EST_FTECLEDA} 1000 1"
#    SORT_NOINFILE="YES"
#    SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_O.dat 1000 1"
#    INPUT_TEXT ${SORT_CMD} <<EOF
#    /FIELDS SSD_CF 1:1 - 1: EN
#    /CONDITION INVENTAIRE ${EST_SORT_CONDITION}
#    /OMIT INVENTAIRE
#    /COPY
#    exit
#EOF
#    SORT
#fi

# [004]
NSTEP=${NJOB}_80
#------------------------------------------------------------------------------
# Merge of TL files
#------------------------------------------------------------------------------
LIBEL="Merge of Technical Ledgers files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_FTECLEDAA_O1.dat 1000 1"
#SORT_I2="${DFILT}/${NJOB}_70_${IB}_SORT_FTECLEDA_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_O_${MODETRT_CF}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/COPY
exit
EOF
SORT

gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_O_${MODETRT_CF}.dat > ${DFILT}/${NSTEP}_SORT_FTECLEDA_O_${MODETRT_CF}.dat.gz

## 1 step pour splitter le FTECLEDA_MVT en trois lors du passage M
if [ "${MODETRT_CF}" = "M" ]
then
	NSTEP=${NJOB}_90
	#------------------------------------------------------------------------------
	# Split FTECLEDA_MVT generation in TTECLEDR table format
	#-----------------------------------------------------------------------------
	LIBEL="File generation in TTECLEDR and TTECLEDA tables format"
	PRG=ESTC8807
	export ${PRG}_I1=${DFILT}/${NJOB}_80_${IB}_SORT_FTECLEDA_O_M.dat
	export ${PRG}_I2=${EST_SUBTRS}
	export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDA_MVT.dat
	export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDA_MTH.dat
	export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDA_REP.dat
	EXECPRG

	#------------------------------------------------------------------------------
	gzip -c ${DFILT}/${NJOB}_90_${IB}_ESTC8807_FTECLEDA_MVT.dat > ${DFILT}/${NJOB}_90_ESTC8807_FTECLEDA_MVT.dat.gz
	gzip -c ${DFILT}/${NJOB}_90_${IB}_ESTC8807_FTECLEDA_MTH.dat > ${DFILT}/${NJOB}_90_ESTC8807_FTECLEDA_MTH.dat.gz
	gzip -c ${DFILT}/${NJOB}_90_${IB}_ESTC8807_FTECLEDA_REP.dat > ${DFILT}/${NJOB}_90_ESTC8807_FTECLEDA_REP.dat.gz
	#------------------------------------------------------------------------------

	#[016]
	NSTEP=${NJOB}_91
	# summarize TTECLEDA by BALSHTDAY
	#--------------------------------
	LIBEL="Summarize TTECLEDA_REP to check amounts to zero"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${NJOB}_90_${IB}_ESTC8807_FTECLEDA_REP.dat 1000 1"
	SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_REPCUM.log 1000 1"
	INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	TRNCOD_CF         6:1 -   6:,
	TRNCOD1_CF        6:1 -   6:1,
	AMT_M            19:1 -  19:EN 15/3,
	RETCTR_NF        24:1 -  24:,
	RETCUR_CF        34:1 -  34:,
	RETAMT_M         35:1 -  35:EN 15/3,
	RETINTAMT_M      88:1 -  88:EN 15/3
/KEYS
	TRNCOD_CF,
	RETCTR_NF,
	RETCUR_CF
/CONDITION RESTRICTION (TRNCOD1_CF = "2" OR TRNCOD1_CF = "4")
/SUMMARIZE  TOTAL AMT_M , TOTAL RETAMT_M , TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
/REFORMAT TRNCOD_CF,RETCTR_NF,RETCUR_CF,AMT_M,RETAMT_M,RETINTAMT_M
exit
EOF
	SORT

	if [ `cut -d~ -f4 ${DFILT}/${NJOB}_91_${IB}_SORT_FTECLEDA_REPCUM.log | grep -v "0.0" | wc -l` -gt 0 ] ||
		[ `cut -d~ -f5 ${DFILT}/${NJOB}_91_${IB}_SORT_FTECLEDA_REPCUM.log | grep -v "0.0" | wc -l` -gt 0 ] ||
		[ `cut -d~ -f6 ${DFILT}/${NJOB}_91_${IB}_SORT_FTECLEDA_REPCUM.log | grep -v "0.0" | wc -l` -gt 0 ]
	then
		ECHO_LOG ""
		ECHO_LOG "#========================================================================="
		ECHO_LOG "#===> La somme des montants du fichier _FTECLEDA_FTECLEDA_REP.dat est diff�rente de z�ro - Warning pour analyse et correction"
		ECHO_LOG "#========================================================================="
		ECHO_LOG ""
		NSTEP=${NJOB}_50
		# Create Warning word file
		#---------------------------------------------------------------
		LIBEL="Create Warning word file"
		cat > ${DFILT}/${NSTEP}_${IB}_INVALID_REP.wng <<EOF
WARNING
EOF
	fi
	
	NSTEP=${NJOB}_95
	#------------------------------------------------------------------------------
	LIBEL="create ${EST_FTECLEDA_MVT}"
	EXECKSH_MODE=P
	EXECKSH "cp ${DFILT}/${NJOB}_90_${IB}_ESTC8807_FTECLEDA_MVT.dat ${EST_FTECLEDA_MVT}"
	
	NSTEP=${NJOB}_96
	#------------------------------------------------------------------------------
	LIBEL="create ${EST_FTECLEDA_MTH}"
	EXECKSH_MODE=P
	EXECKSH "cp ${DFILT}/${NJOB}_90_${IB}_ESTC8807_FTECLEDA_MTH.dat ${EST_FTECLEDA_MTH}"
	
	NSTEP=${NJOB}_97
	#------------------------------------------------------------------------------
	LIBEL="create ${EST_FTECLEDA_REP}"
	EXECKSH_MODE=P
	EXECKSH "cp ${DFILT}/${NJOB}_90_${IB}_ESTC8807_FTECLEDA_REP.dat ${EST_FTECLEDA_REP}"
fi

if [ "${MODETRT_CF}" = "C" ]
then
	NSTEP=${NJOB}_100
	#------------------------------------------------------------------------------
	LIBEL="create ${EST_FTECLEDA_CUR}"
	EXECKSH_MODE=P
	EXECKSH "cp ${DFILT}/${NJOB}_80_${IB}_SORT_FTECLEDA_O_C.dat ${EST_FTECLEDA_CUR}"
fi

NSTEP=${NJOB}_150
#Temporary files deletion
# ajout fichier FTECLEDR_FORMAT_AR_O3.dat
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_15_${IB}_ESTC8801_FTECLEDAA_O1.dat
RMFIL ${DFILT}/${NJOB}_40_${IB}_ESTC8802_FTECLEDAR_O2.dat
RMFIL ${DFILT}/${NJOB}_40_${IB}_ESTC8802_FTECLEDR_FORMAT_AR_O3.dat
#RMFIL ${DFILT}/${NJOB}_70_${IB}_SORT_FTECLEDA_O.dat

#----------------------------------------
#----------------------------------------

#[004]
if [ "${EST_ESID3800_COND3}" = "N" ]
then

  #----------------------------------------
  # FTECLEDR
  #----------------------------------------
  
  NSTEP=${NJOB}_190
  #------------------------------------------------------------------------------
  # Sort of the Retrocession File
  #------------------------------------------------------------------------------
  LIBEL="Sort of Retrocession Technical Ledgers File"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${DFILT}/${NJOB}_40_${IB}_ESTC8802_FTECLEDR_O1.dat 1000 1"
  SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_O.dat 1000 1"
  INPUT_TEXT ${SORT_CMD} <<EOF
  /FIELDS RETCTR_NF   24:1 - 24:,
          RETEND_NT   25:1 - 25: EN,
          RETSEC_NF   26:1 - 26: EN,
          RTY_NF      27:1 - 27: EN,
          RETUW_NT    28:1 - 28: EN,
          PLC_NT      36:1 - 36: EN
  /KEYS RETCTR_NF,
        RTY_NF,
        PLC_NT
  exit
EOF
  SORT


  NSTEP=${NJOB}_195
  #Temporary file deletion
  LIBEL="Temporary file deletion"
  RMFIL ${DFILT}/${NJOB}_40_${IB}_ESTC8802_FTECLEDR_O1.dat


	NSTEP=${NJOB}_205
	#------------------------------------------------------------------------------
	# Update of SSDRTO_B ( internal retrocession )
	#[003] remplacement du fichier ${PRG}_I2=${DFILT}/${NJOB}_100_${IB}_SORT_FPLC_O.dat par ${EST_FPLACEMT2}
	#-----------------------------------------------------------------------------
	LIBEL="Update of SSDRTO_B ( internal retrocession )"
	PRG=ESTC8803
	export ${PRG}_I1=${DFILT}/${NJOB}_190_${IB}_SORT_FTECLEDR_O.dat
	export ${PRG}_I2=${EST_FPLACEMT2}
	export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_O.dat
	EXECPRG
  
	#------------------------------------------------------------------------------
	gzip -c ${DFILT}/${NJOB}_190_${IB}_SORT_FTECLEDR_O.dat  > ${DFILT}/${NJOB}_190_SORT_FTECLEDR_O.dat.gz
	gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_O.dat   > ${DFILT}/${NSTEP}_${PRG}_FTECLEDR_O.dat.gz
	#------------------------------------------------------------------------------

  NSTEP=${NJOB}_210
  #------------------------------------------------------------------------------
  #Temporary file deletion
  #-----------------------------------------------------------------------------
  LIBEL="Temporary file deletion"
  RMFIL ${DFILT}/${NJOB}_90_${IB}_SORT_FTECLEDR_O.dat
  
#  NSTEP=${NJOB}_215
#  if [ "${EST_ESID3800_COND2}" = "Y" ] || [ "${EST_ESID3800_COND3}" = "Y" ] || [ "${MODETRT_CF}" = "M" ]
#  then
#      NSTEP=${NJOB}_215
#      #-----------------------------------------------------------------------------
#      LIBEL="Creation of empty SORT_FTECLEDR Files"
#      EXECKSH "touch ${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_O.dat"
#  else
#      NSTEP=${NJOB}_215
#      #------------------------------------------------------------------------------
#      # Filter of the FTECLEDR File
#      #------------------------------------------------------------------------------
#      LIBEL="Filter of FTECLEDR file on subsidiaries without closing period demand"
#      SORT_WDIR=${SORTWORK}
#      SORT_CMD=`CFTMP`
#      SORT_I="${EST_FTECLEDR} 1000 1"
#      SORT_NOINFILE="YES"
#      SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_O.dat 1000 1"
#      INPUT_TEXT ${SORT_CMD} <<EOF
#      /FIELDS SSD_CF 1:1 - 1: EN
#      /CONDITION INVENTAIRE ${EST_SORT_CONDITION}
#      /OMIT INVENTAIRE
#      /COPY
#      exit
#EOF
#      SORT
#  fi
  
  NSTEP=${NJOB}_220
  #------------------------------------------------------------------------------
  # Constitution of the new FTECLEDR file
  #------------------------------------------------------------------------------
  LIBEL="Constitution of the new FTECLEDR file"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${DFILT}/${NJOB}_205_${IB}_ESTC8803_FTECLEDR_O.dat 1000 1"
  #SORT_I2="${DFILT}/${NJOB}_215_${IB}_SORT_FTECLEDR_O.dat 1000 1"
  SORT_O="${DFILT}/${NSTEP}_${IB}_MERGE_FTECLEDR_O.dat 1000 1"
  INPUT_TEXT ${SORT_CMD} <<EOF
  /COPY
  exit
EOF
  SORT
  
  NSTEP=${NJOB}_225
  #------------------------------------------------------------------------------
  #[003]
  #-----------------------------------------------------------------------------
  LIBEL="Internal reference addition in the new FTECLEDR file"
  PRG=ESTC8804
  export ${PRG}_I1=${DFILT}/${NJOB}_220_${IB}_MERGE_FTECLEDR_O.dat
  export ${PRG}_I2=${EST_FSSDACTR}
    if [ "${MODETRT_CF}" = "M" ]
    then
        export ${PRG}_O1=${EST_FTECLEDR_MVT}
    else
        export ${PRG}_O1=${EST_FTECLEDR_CUR}
    fi
  EXECPRG
fi

########################
# Erase temporary files #
########################

NSTEP=${NJOB}_300
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
