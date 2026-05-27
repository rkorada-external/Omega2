#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                               Fusion des GT acceptation
#                               Ajout du poste de contrepartie
# nom du script SHELL		: ESID2061.cmd
# revision			        : $Revision: 1.5 $
# date de creation		    : 08/09/1997
# auteur			        : CGI
# references des specifications	: ESCOM02F.doc
#-----------------------------------------------------------------------------
# description       Merge of acceptance TL
#                   Double entry transaction code addition
#
# Input files
#       EST_DLAGTAA      DFILP
#       EST_DLDGTAA      DFILP
#       EST_DLGTAASNEM   DFILI
#       EST_DLRGTAA      DFILI
#       EST_DLSGTAA      DFILI
#       EST_DLTOTGTAA    DFILP
#       EST_DLVGTAA      DFILP
#       EST_FDETTRS      DFILI
#       EST_IGTAAF       DFILP
#
# Output files
#       EST_DLTOTGTAA    DFILP
#       EST_TOTGTAA      DFILI
#
# Launch C program ESTM2061 ESTM7603
#
# job launched by ESID2060.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications
# 10/06/98 - M.HA-THUC ( Rajout du GT des SNEM au step 05 )
# 15/06/04 - J. Ribot suppression          RMFIL "${EST_DLSGTAA}"
# 23/03/07 - J. Ribot SPOT13142 ajout steps 02 05 07 pour exclure les affaires lob 04, filiales 2,3, 12
#                               et pays de risque FRA
# 15/01/09 - J. Ribot SPOT16593 ajout steps 18 120  generation mvts IFRS
# 04/03/09 - J. Ribot SPOT16990 ajout parametre clodat_d pour la generation mvts IFRS
# 16/09/09 - JF.VDV SPOT17921 mettre le fichier IFRSGTA dans $DFILT et non plus dans $DFILP
#---------------
#MODIFICATION   : [007]
#Auteur         : D.GATIBELZA
#Date           : 07/02/2011
#Version        : 11.1
#Description    : 1GL
#[008]  14/03/2011  R. CASSIS     :spot:21408 - Agrandissement des fichiers au format GT 41+14 col.
#[009]  02/07/2012  R. CASSIS     :spot:23802 - Plus d'agrandissement car les colonnes sont deja garnies
#[010]  21/08/2012  Roger Cassis  :spot:24041 - Filtre Pour omettre les filiales Tare dans GLT placé dans tri DLTOTGTAA
#[011]  09/09/2013  Roger Cassis  :spot:25498 - Remet a blanc les 14 cols pour legale Italie :spot:25427 - Remise à niveau selon derniere version Prod
#[012]  26/11/2013  Roger Cassis  :spot:25427 - Centralization - remplace nawk par awk
#[013]  25/09/2014  Roger Cassis  :spot:25036 - Trncod 1__4 updated to 1__2 for balshey 2014
#[014]  08/10/2014  Gaelle Legay  :spot:25036 - Trncod 1__4 updated to 1__2 for balshey 2014 
#[015]  28/10/2014  Roger Cassis  :spot:27715 - Update dlbl suffix only on trncod suffix updated
#[016]  02/11/2015  Roger Cassis  :spot:29615 - Déconnexion de l'EBS en variante 3
#[017]  15/01/2016  Florent       :spot:29066 formatage du fichier GT 
#[018]  18/01/2018  S.Behague     :spira:34211 Batch: SII - Modify the SII closing process for IAS 39 Model treaties
#[019]  29/01/2021  B.LAGHA       :spira:91085 Remplacer le programme ESTM2569 par ESTM2069.
#[020]  21/07/2023  S.Behague     :spira:109913 IAS 39 Process
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT

# Parameters
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
CLODAT_D=$3

#The Balance Sheet month result is
MTHFIN_NF=`echo ${CLODAT_D} | awk '{ print substr($0,5,2)}'`
#generate start month quarter = month-2
MTHDEB_NF=`echo ${MTHFIN_NF} | awk '{ hist = $0 - 2; print hist }'`

NSTEP=${NJOB}_01
#-----------------------------------------------------------------------------
#Last version of ESID2060 files deletion
#-----------------------------------------------------------------
RMFIL "  `dirname ${EST_DLTOTGTAA}`/${PCH}ESID2060_DLTOTGTAA*.dat
         `dirname ${EST_TOTGTAA}`/${PCH}ESID2060_TOTGTAA*.dat"


# SPOT 13142 nouveaux STEPS
NSTEP=${NJOB}_02
#-----------------------------------------------------------------------------
#Tri du fichier ESTC1005_PERICASE Extended with TFAMCHG_O
#-----------------------------------------------------------------------------
LIBEL="Tri de ESTC1005_PERICASE Extended ... "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADVPERICASE} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADVPERICASE_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS	SSD_CF           1:1 -  1:  EN,
        CTR_NF           3:1 -  3:,
        END_NT           4:1 -  4:,
        SEC_NF           5:1 -  5:  EN,
        UWY_NF           6:1 -  6:,
        UW_NT            7:1 -  7:,
        LOB_CF          38:1 - 38:,
        PCPRSKTRY_CF    52:1 - 52:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/CONDITION DECENNALE ( LOB_CF = '04' AND PCPRSKTRY_CF = 'FRA' AND (SSD_CF = 2 OR SSD_CF = 3 OR SSD_CF = 12) )
/OUTFILE ${SORT_O}
/OMIT DECENNALE
exit
EOF
SORT


NSTEP=${NJOB}_05
#-----------------------------------------------------------------------------
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Merging and sorting acceptance TL files..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_DLGTAASNEM}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLGTAASNEM_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF  8:1 -  8:,
        END_NT  9:1 -  9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT  12:1 - 12:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_07
#-----------------------------------------------------------------------------
#
#----------------------------------------------------------------------------
if [ "${EST_ESID2060_COND1}" = "Y" ]
then
    LIBEL="DLGTAASNEM  treatment"
    PRG=ESTM2565
    export ${PRG}_I1=${DFILT}/${NJOB}_02_${IB}_SORT_IADVPERICASE_O.dat
    export ${PRG}_I2=${DFILT}/${NJOB}_05_${IB}_SORT_DLGTAASNEM_O.dat
    export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLGTAASNEM_O.dat
    EXECPRG
else
    LIBEL="touch files _DLGTAASNEM_O"
    EXECKSH_MODE=P
    EXECKSH "touch ${DFILT}/${NJOB}_07_${IB}_ESTM2565_DLGTAASNEM_O.dat"
fi 
# SPOT 13142 fin nouveaux STEPS


######################################
# Merge of dDGTAa, dVGTAa and dRGTAA #
#           d = DL                   #
######################################
NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
#Merge dDGTAa and dVGTAa
#-----------------------------------------------------------------------------
LIBEL="Merge of dDGTAa, dVGTAa and dRGTAA in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLDGTAA} 1000 1"
SORT_I2="${EST_DLVGTAA} 1000 1"
SORT_I3="${EST_DLRGTAA} 1000 1"
SORT_I4="${DFILT}/${NJOB}_07_${IB}_ESTM2565_DLGTAASNEM_O.dat 1000 1"
# inventaire solvency EBS
#[016] plus d'inventaire en variante 3
#if [ "${EST_ESID2060_COND2}" = "Y" ]
#then
#   SORT_I5="${EST_DLDSIIGTAA} 1000 1"
#   SORT_I6="${EST_DLASIIGTAA} 1000 1"
#fi
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DVGTAA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF    6:1 -  6:,
        ORICOD_LS   57:1 - 57:
/KEYS TRNCOD_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT
gzip -c ${DFILT}/${NJOB}_10_${IB}_SORT_DVGTAA_O.dat > ${DFILT}/${NJOB}_10_DVGTAA.dat.gz

#################################
# Double entry transaction code #
#################################
NSTEP=${NJOB}_15
#-----------------------------------------------------------------------------
#Double entry transaction code addition in dDVGTAa
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition dDVGTAa in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_DVGTAA_O.dat
export ${PRG}_I2=${EST_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLDVGTAA_O.dat
EXECPRG

NSTEP=${NJOB}_16A
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_DVGTAA_O.dat

#[008] Agrandissement au format 41+14 col
#[009] on le fait plus
NSTEP=${NJOB}_16B
#Reduction of CURGTA
#-----------------------------------------------------------------------------
LIBEL="Reduction of CURGTA to 41 col ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_ESTM7603_DLDVGTAA_O.dat 1000 1"
SORT_I2="${EST_DLSGTAA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDVGTAA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/COPY
exit
EOF
SORT

gzip -c ${DFILT}/${NJOB}_16B_${IB}_SORT_DLDVGTAA_O.dat > ${DFILT}/${NJOB}_16_DVGTAA.dat.gz


NSTEP=${NJOB}_17
#-----------------------------------------------------------------------------
# GTAa files merge
#[007]
#-----------------------------------------------------------------------------
LIBEL="1GL: Merge and sort of dGTAa files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IGTAAF} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IGTAAF_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -  1:,
        ESB_CF           2:1 -  2:,
        BALSHEY_NF       3:1 -  3:  EN,
        BALSHRMTH_NF     4:1 -  4:  EN,
        BALSHRDAY_NF     5:1 -  5:  EN,
        TRNCOD_CF        6:1 -  6:,
        TRNCOD2_CF       6:2 -  6:2,
        TRNCOD8_CF       6:8 -  6:8,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      TRNCOD_CF
/CONDITION COND_TRIM ( ( BALSHEY_NF != ${BALSHTYEA_NF} OR (BALSHRMTH_NF > ${MTHFIN_NF} OR BALSHRMTH_NF < ${MTHDEB_NF}) ) OR
                       ( ( TRNCOD2_CF = "1" OR TRNCOD2_CF = "2" OR TRNCOD2_CF = "3" OR TRNCOD2_CF = "4") AND
                         ( TRNCOD8_CF != "0" AND TRNCOD8_CF != "1") ) )
/OMIT COND_TRIM
exit
EOF
SORT

NSTEP=${NJOB}_18
#-----------------------------------------------------------------------------
# GTAa files merge
#-----------------------------------------------------------------------------
LIBEL="Merge and sort of dGTAa files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_16B_${IB}_SORT_DLDVGTAA_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_17_${IB}_SORT_IGTAAF_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IFRSGTA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF  1:1 -  1:,
        ESB_CF  2:1 -  2:,
        CTR_NF  8:1 -  8:,
        END_NT  9:1 -  9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF
exit
EOF
SORT


NSTEP=${NJOB}_19
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_17_${IB}_SORT_IGTAAF_O.dat

NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
#
#----------------------------------------------------------------------------
LIBEL="IFRS  treatment"
PRG=ESTM2069
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_02_${IB}_SORT_IADVPERICASE_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_18_${IB}_SORT_IFRSGTA_O.dat
export ${PRG}_I3=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_IFRS_GTA_O.dat
EXECPRG

NSTEP=${NJOB}_21
#-----------------------------------------------------------------------------
# DLTOTGTAA permanent file (with special italian transaction and UPR/DAC)
#-----------------------------------------------------------------------------
LIBEL="DLTOTGTAA permanent file (with special italian transaction and UPR/DAC) "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_${PRG}_IFRS_GTA_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IFRSGTA_O.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

#[018]
NSTEP=${NJOB}_22
#-----------------------------------------------------------------------------
#Suppression traite model IAS39
#-----------------------------------------------------------------------------
LIBEL="Suppression traite model IAS39"
PRG=ESTC2057
export ${PRG}_I1=${DFILT}/${NJOB}_21_${IB}_SORT_IFRSGTA_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_02_${IB}_SORT_IADVPERICASE_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_IFRS_GTA_O.dat
EXECPRG

##############################################################################g
# Closing period process, special entries, cancellation TL merge
###############################################################################

NSTEP=${NJOB}_25
#-----------------------------------------------------------------------------
# GTAa files merge
#[007] ajout des 16 champs
#-----------------------------------------------------------------------------
LIBEL="1GL: Merge and sort of dGTAa files ... ajout des 16 champs"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_16B_${IB}_SORT_DLDVGTAA_O.dat 1000 1"
SORT_I2="${EST_DLAGTAA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLTOTGTAA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/COPY
exit
EOF
SORT

gzip -c ${DFILT}/${NJOB}_25_${IB}_SORT_DLTOTGTAA_O.dat > ${DFILT}/${NJOB}_25_DVGTAA.dat.gz

NSTEP=${NJOB}_30
# Deletion of permanent & temporary files
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL ${DFILT}/${NJOB}_15_${IB}_ESTM7603_DLDVGTAA_O.dat



##############################################################################g
# All balance sheet year Acceptance TL files merge
###############################################################################

#Suppression: #[008] Reduction au format 41 col
NSTEP=${NJOB}_35
#-----------------------------------------------------------------------------
# All balance sheet year Acceptance TL files merge
#-----------------------------------------------------------------------------
LIBEL="Merge of balance sheet year GTAa files in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25_${IB}_SORT_DLTOTGTAA_O.dat 1000 1"
SORT_I2="${EST_IGTAAF} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTAA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        ACY_NF          14:1 - 14:,
        SCOENDMTH_NF    16:1 - 16:,
        SCOSTRMTH_NF    15:1 - 15:,
        OCCYEA_NF       13:1 - 13:,
        CLM_NF          17:1 - 17:,
        CUR_CF          18:1 - 18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETACY_NF       30:1 - 30:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETOCCYEA_NF    29:1 - 29:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        PLC_NT          36:1 - 36:,
        TRNCOD_CF        6:1 -  6:,
        FIELD_41         1:1 - 41:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      SCOENDMTH_NF,
      SCOSTRMTH_NF,
      OCCYEA_NF,
      CLM_NF,
      CUR_CF,
      TRNCOD_CF
exit
EOF
SORT


NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
# Begin programme C
# Current ACY transactions blanking for italian TOTGTAA only
#------------------------------------------------------------------------------
LIBEL="Current ACY transactions blanking for italian TOTGTAA only"
PRG=ESTM2061
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
BALSHTYEA_NF ${BALSHTYEA_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_35_${IB}_SORT_TOTGTAA_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_TOTGTAA_O.dat
EXECPRG

#[011]
NSTEP=${NJOB}_42
#-----------------------------------------------------------------------------
# Begin sort : italian blanking accumulation                      SPOT16593
#------------------------------------------------------------------------------
LIBEL="italian TOTGTAA blanking accumulation"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_ESTM2061_TOTGTAA_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTAA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:,
        ESB_CF           2:1 -  2:,
        BALSHEY_NF       3:1 -  3:,
        BALSHRMTH_NF     4:1 -  4:,
        BALSHRDAY_NF     5:1 -  5:,
        TRNCOD_CF        6:1 -  6:,
        DBLTRNCOD_CF     7:1 -  7:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        OCCYEA_NF       13:1 - 13:,
        ACY_NF          14:1 - 14:,
        SCOSTRMTH_NF    15:1 - 15:,
        SCOENDMTH_NF    16:1 - 16:,
        CLM_NF          17:1 - 17:,
        CUR_CF          18:1 - 18:,
        AMT_M           19:1 - 19:  EN 15/3,
        RETAMT_M        35:1 - 35:  EN 15/3,
        TRN_NT          56:1 - 56:,
        RETROAUTO_B     58:1 - 58:,
        REC1             1:1 - 18:,
        REC2            20:1 - 41:,
        FILLER_15_COL   42:1 - 56:,
        FILLER_14_COL   58:1 - 71:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      CUR_CF,
      TRNCOD_CF,
      TRN_NT,
      RETROAUTO_B
/SUMMARIZE TOTAL AMT_M
/DERIVEDFIELD ORICOD_LS "CURGTA~"
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT REC1, AMT_MC, REC2, FILLER_15_COL, ORICOD_LS, FILLER_14_COL
exit
EOF
SORT

NSTEP=${NJOB}_45
#-----------------------------------------------------------------------------
# Begin sort : italian blanking accumulation et IFRS       SPOT16593
#------------------------------------------------------------------------------
LIBEL="italian TOTGTAA blanking accumulation"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_42_${IB}_SORT_TOTGTAA_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_22_${IB}_IFRS_GTA_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTAA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:,
        ESB_CF           2:1 -  2:,
        BALSHEY_NF       3:1 -  3:,
        BALSHRMTH_NF     4:1 -  4:,
        BALSHRDAY_NF     5:1 -  5:,
        TRNCOD_CF        6:1 -  6:,
        DBLTRNCOD_CF     7:1 -  7:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        OCCYEA_NF       13:1 - 13:,
        ACY_NF          14:1 - 14:,
        SCOSTRMTH_NF    15:1 - 15:,
        SCOENDMTH_NF    16:1 - 16:,
        CLM_NF          17:1 - 17:,
        CUR_CF          18:1 - 18:,
        AMT_M           19:1 - 19:  EN 15/3,
        RETAMT_M        35:1 - 35:  EN 15/3,
        TRN_NT          56:1 - 56:,
        RETROAUTO_B     58:1 - 58:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      CUR_CF,
      TRNCOD_CF,
      BALSHEY_NF,
      BALSHRMTH_NF,
      BALSHRDAY_NF,
      TRN_NT,
      RETROAUTO_B
/SUMMARIZE TOTAL AMT_M
exit
EOF
SORT

#################################
# Double entry transaction code #
#################################

NSTEP=${NJOB}_50
#-----------------------------------------------------------------------------
#Double entry transaction code addition in  TOTGTAA
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition TOTGTAA in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_45_${IB}_SORT_TOTGTAA_O.dat
export ${PRG}_I2=${EST_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_TOTGTAA_O.dat
EXECPRG

#[009]
NSTEP=${NJOB}_55
#-----------------------------------------------------------------------------
# All balance sheet year Acceptance TL files merge
#-----------------------------------------------------------------------------
LIBEL="Merge of balance sheet year GTAa files in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_35_${IB}_SORT_TOTGTAA_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_50_${IB}_ESTM7603_TOTGTAA_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTAA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        ACY_NF          14:1 - 14:,
        SCOENDMTH_NF    16:1 - 16:,
        SCOSTRMTH_NF    15:1 - 15:,
        OCCYEA_NF       13:1 - 13:,
        CLM_NF          17:1 - 17:,
        CUR_CF          18:1 - 18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETACY_NF       30:1 - 30:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETOCCYEA_NF    29:1 - 29:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        PLC_NT          36:1 - 36:,
        TRNCOD_CF        6:1 -  6:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      SCOENDMTH_NF,
      SCOSTRMTH_NF,
      OCCYEA_NF,
      CLM_NF,
      CUR_CF,
      TRNCOD_CF
exit
EOF
SORT

#[009]
NSTEP=${NJOB}_58
# exec awk
#-----------------------------------------------------------------------------
LIBEL="Update oricod_ls to EBSGTA for trn EBS"
AWK_I=${DFILT}/${NJOB}_55_${IB}_SORT_TOTGTAA_O.dat
AWK_O=${EST_TOTGTAA}
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
	{	post = substr(\$6,2,1);
		if ( post == "A" || post == "B" || post == "D" || post == "E" || post == "G" ||
		     post == "H" || post == "J" || post == "K" || post == "L" )
		{
			\$57 = "EBSGTA";
		}
		print \$0
	}
exit
EOF
AWK

#[009]
#[010]
NSTEP=${NJOB}_59
#-----------------------------------------------------------------------------
# DLTOTGTAA permanent file (with special italian transaction and UPR/DAC)
#-----------------------------------------------------------------------------
LIBEL=" DLTOTGTAA permanent file (with special italian transaction and UPR/DAC) "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25_${IB}_SORT_DLTOTGTAA_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_50_${IB}_ESTM7603_TOTGTAA_O.dat 1000 1"
SORT_I3="${EST_MVTPNAC} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLTOTGTAA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

gzip -c ${DFILT}/${NJOB}_60_${IB}_SORT_DLTOTGTAA_O.dat > ${DFILT}/${NJOB}_60_DVGTAA.dat.gz

#[013]
#[014] [015]
NSTEP=${NJOB}_60
# Begin Awk
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD en Norme EBS : '1xxxxxx4' en '1xxxxxx2' pour bilan 2014"
AWK_I=${DFILT}/${NJOB}_59_${IB}_SORT_DLTOTGTAA_O.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLTOTGTAA_O.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN	{ FS="\~"; OFS="\~" }
		{
			if (substr(\$6,1,1) == "1" && substr(\$6,8,1) == "4" && \$3 == 2014)
			{
				\$6 = substr(\$6,1,7) "2";
				\$7 = substr(\$7,1,7) "2";
			}
			print \$0;
		}
exit
EOF
AWK

#[009]
NSTEP=${NJOB}_61
# exec awk
#-----------------------------------------------------------------------------
LIBEL="Update oricod_ls to EBSGTA for trn EBS"
AWK_I=${DFILT}/${NJOB}_60_${IB}_AWK_DLTOTGTAA_O.dat
AWK_O=${EST_DLTOTGTAA}
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
	{	post = substr(\$6,2,1);
		if ( post == "A" || post == "B" || post == "D" || post == "E" || post == "G" ||
		     post == "H" || post == "J" || post == "K" || post == "L" )
		{
			\$57 = "EBSGTA";
		}
		print \$0
	}
exit
EOF
AWK

NSTEP=${NJOB}_65
#-----------------------------------------------------------------------------
# Split GTA + DLTOTGTAA ==> MGTAA
#----------------------------------------------------------------------------
LIBEL=" Split GTA + DLTOTGTAA ==> MGTAA "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_GTA} 1000 1"
SORT_I2="${EST_DLTOTGTAA} 1000 1"
SORT_O="${EST_MGTAA}"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -  1:,
        ESB_CF           2:1 -  2:,
        BALSHEY_NF       3:1 -  3:  EN,
	    BALSHRMTH_NF     4:1 -  4:  EN,
        BALSHRDAY_NF     5:1 -  5:  EN,
	    TRNCOD_CF        6:1 -  6:,
	    TRNCOD1_CF       6:1 -  6:1,
	    TRNCOD2_CF       6:2 -  6:2 EN,
	    TRNCOD2C_CF      6:2 -  6:2,
	    TRNCOD8_CF       6:8 -  6:8 EN,
        DBLTRNCOD_CF     7:1 -  7:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        OCCYEA_NF       13:1 - 13:,
        ACY_NF          14:1 - 14:,
        SCOSTRMTH_NF    15:1 - 15:,
        SCOENDMTH_NF    16:1 - 16:,
        CLM_NF          17:1 - 17:,
       	CUR_CF          18:1 - 18:,
        AMT_M           19:1 - 19:,
        CED_NF          20:1 - 20:,
        BRK_NF          21:1 - 21:,
        PAY_NF          22:1 - 22:,
        KEY_NF          23:1 - 23:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETOCCYEA_NF    29:1 - 29:,
        RETACY_NF       30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        RETAMT_M        35:1 - 35:,
        PLC_NT          36:1 - 36:,
        RTO_NF          37:1 - 37:,
        INT_NF          38:1 - 38:,
        RETPAY_NF       39:1 - 39:,
        RETKEY_CF       40:1 - 40:,
        RETINTAMT_M     41:1 - 41:
/CONDITION COND_MGTAA ( BALSHEY_NF = ${BALSHTYEA_NF} and BALSHRMTH_NF <= ${BALSHTMTH_NF}) AND
                      ( TRNCOD1_CF = "1" or TRNCOD1_CF = "3" )
/OUTFILE ${SORT_O}
/INCLUDE COND_MGTAA
/REFORMAT SSD_CF,
          ESB_CF,
          BALSHEY_NF,
          BALSHRMTH_NF,
          BALSHRDAY_NF,
          TRNCOD_CF,
          DBLTRNCOD_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          OCCYEA_NF,
          ACY_NF,
          SCOSTRMTH_NF,
          SCOENDMTH_NF,
          CLM_NF,
          CUR_CF,
          AMT_M,
          CED_NF,
          BRK_NF,
          PAY_NF,
          KEY_NF,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETOCCYEA_NF,
          RETACY_NF,
          RETSCOSTRMTH_NF,
          RETSCOENDMTH_NF,
          RCL_NF,
          RETCUR_CF,
          RETAMT_M,
          PLC_NT,
          RTO_NF,
          INT_NF,
          RETPAY_NF,
          RETKEY_CF
/COPY
exit
EOF
SORT


########################
# Erase temporary files #
########################
NSTEP=${NJOB}_70
LIBEL="Erase permanent & temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND


