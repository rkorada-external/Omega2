#!/bin/ksh
#==============================================================================
# Application Name  : ESTIMATION - Segmentation
# Source name       : ESID2030.cmd
# Revision          : $Revision:   1.0  $
# Date of creation  : 28/04/2015
# Author            : PAUL GARNIER
# References        : EST39 
#        
#------------------------------------------------------------------------------
# Description : 
# Calcul automatique de la prévision de sinistralité en fonction de la
#   segmentation
#
# PA = Prime acquise
#
#-----------------------------------------------------------------------------
# historique des modifications :
# [001] 10/05/2016 R.BEN EZZINE  :spot: : Optimisation ESID2030
# [002] 03/06/2016 S.Behague :spot:30300 EST39 
# [003] 07/09/2016 S.ASKRI     :spot:31169 spira 53597 : SRV : Estimations à 0 sur AC futures pour les traités automatiques
# [004] 18/10/2016 MMA       :spot:31378 spira multi       : Optimisation de la chaine afin de supporter le calcule mono-GAAP
# [006] 10/09/2018 M.NAJI add UWY_NF in TCTRGRO , spira 57605
#=============================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd
. ${DUTI}/fctws.cmd

CRE_D=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_050
# Splitting VLIFEST with and without Crible equals E
#------------------------------------------------------------------------------
LIBEL="Splitting VLIFEST with and without Crible equals E"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I="${EST_VLIFEST_AUTOSEG} 1000 1"                    # [004]
SORT_O="${DFILT}/${NSTEP}_${IB}_VLIFEST_wESTCRB_E.dat"    # VLIFEST with Crible equals E
SORT_O2="${DFILT}/${NSTEP}_${IB}_VLIFEST_woESTCRB_E.dat"  # VLIFEST without Crible equals E
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS   
        CTR_NF         2:1 -  2:,
        END_NT         3:1 -  3:,
        SEC_NF         4:1 -  4:,
        UWY_NF         5:1 -  5:,
        UW_NT          6:1 -  6:,
        ACY_NF         7:1 -  7:,
        ACMTRS_NT     10:1 - 10:,
        ESTCRB_CT     33:1 - 33:
/KEYS 
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      ACMTRS_NT
/STABLE
/CONDITION CRIBLE_E ESTCRB_CT = 'E' AND (ACMTRS_NT = '1243' OR ACMTRS_NT = '1244' OR ACMTRS_NT = '1510') 
/OUTFILE ${SORT_O}
/INCLUDE CRIBLE_E
/OUTFILE ${SORT_O2}
/OMIT CRIBLE_E
exit
EOF
SORT


NSTEP=${NJOB}_100
# Sorting GT
#------------------------------------------------------------------------------
LIBEL="Sorting GT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I="${EST_SRGTC} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SRGTC_PA.dat" # GT trie + PA
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        ACY_NF          14:1 - 14:,
        ACMTRS_NT       45:1 - 45:
/KEYS 
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF
/STABLE
/CONDITION PA ACMTRS_NT = "1220"
/OUTFILE ${SORT_O}
/INCLUDE PA
exit
EOF
SORT


NSTEP=${NJOB}_150
# Data extraction
#------------------------------------------------------------------------------
LIBEL="Data extraction"
PRG=ESTC3710
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
CRE_D ${CRE_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_050_${IB}_VLIFEST_wESTCRB_E.dat # Lignes seg du VLIFEST (crible = E)
export ${PRG}_I2=${DFILT}/${NJOB}_100_${IB}_SRGTC_PA.dat          # Lignes des PA du GT (ACMTRS = 1220)
export ${PRG}_I3=${EST_CPLIFDRI}                                  # Lignes CC
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_VLIFEST_CC.dat    # Fichier format LIFEST enrichi CC
EXECPRG


NSTEP=${NJOB}_200
# Enriched LIFEST
#------------------------------------------------------------------------------
LIBEL="Enriched LIFEST"
PRG=ESTC3711
export ${PRG}_I1=${DFILT}/${NJOB}_150_${IB}_ESTC3710_VLIFEST_CC.dat # Fichier format LIFEST enrichi CC
export ${PRG}_I2=${EST_FVCTRGRO}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST_ENRICHI.dat  # Fichier format LIFEST enrichi CC + SEG + VRS + SEGTYP
EXECPRG


NSTEP=${NJOB}_230
# Sort Enriched LIFEST
#------------------------------------------------------------------------------
LIBEL="Sort Enriched LIFEST"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I="${DFILT}/${NJOB}_200_${IB}_ESTC3711_LIFEST_ENRICHI.dat 1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_LIFEST_ENRICHI.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        SSD_CF        1:1 -   1:EN,
        CTR_NF        2:1 -   2:,
        UWY_NF        5:1 -   5:,
        ACY_NF        7:1 -   7:,
        SEG_NF       57:1 -  57:
/KEYS 
      SEG_NF,
      SSD_CF,
      UWY_NF,
      ACY_NF,
      CTR_NF
/STABLE
exit
EOF
SORT


NSTEP=${NJOB}_250
# Segmentation Update
#------------------------------------------------------------------------------
LIBEL="Segmentation Update"
PRG=ESTC3712
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
CRE_D ${CRE_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_230_${IB}_LIFEST_ENRICHI.dat      # Fichier format LIFEST enrichi CC + SEG + VRS + SEGTYP
export ${PRG}_I2=${EST_FVSEGEST}
export ${PRG}_I3=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_PERISEG.dat         # Fichier contenant les informations des differents segments
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST_ENRICHI.dat  # Avec devise en EUR
EXECPRG


NSTEP=${NJOB}_300
# Segmentation Update in VLIFEST195
#------------------------------------------------------------------------------
LIBEL="Segmentation Update in VLIFEST195"
PRG=ESTC3713
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
CRE_D ${CRE_D}
BALSHTYEA_NF ${BALSHTYEA_NF}
BALSHTMTH_NF ${BALSHTMTH_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_250_${IB}_ESTC3712_LIFEST_ENRICHI.dat # Fichier format LIFEST enrichi CC + SEG + VRS + SEGTYP
export ${PRG}_I2=${DFILT}/${NJOB}_250_${IB}_ESTC3712_PERISEG.dat        # Fichier contenant les informations des differents segments
export ${PRG}_I3=${EST_IARVPERICASE4_AUTOSEG}                           # [004] Utilisation du IARVPERICASE4 trié contenant uniquement les AUTOSEG
export ${PRG}_I4=${EST_FCURQUOT}                                        
export ${PRG}_I5=${EST_TACCPAR}                                         
export ${PRG}_I6=${EST_SUBTRSESBPROP}
export ${PRG}_I7=${EST_CPLIFDRI}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_VLIFEST_SEG_MAJ.dat     # Fichier format LIFEST
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_VLIFEST_SEG_LOG.dat     # LOG contenant toutes les lignes + entete
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_CPLIFDRI_O.dat
EXECPRG

gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_VLIFEST_SEG_MAJ.dat > ${DFILT}/${NSTEP}_ESTC3713_VLIFEST_SEG_MAJ.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_VLIFEST_LOG.dat > ${DFILT}/${NSTEP}_ESTC3713_VLIFEST_LOG.dat.gz

NSTEP=${NJOB}_310
# Sort CPLIFDRI binary file
#[007] changement dans le tri pour pointer sur les bons champs
#------------------------------------------------------------------------------
LIBEL="Sort of CPLIFDRI binary file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_300_${IB}_ESTC3713_CPLIFDRI_O.dat fixed 112"
SORT_O=${EST_CPLIFDRI}
INPUT_TEXT $SORT_CMD << EOF
/FIELDS CTR_NF           1 CHAR 10,
        END_NT          10 UINTEGER 1,
        SEC_NF          12 UINTEGER 1,
        UWY_NF          14 INT 2,
        UW_NT           16 UINTEGER 1,
        ACY_NF          17 INT 2,
        SSD_CF          19 UINTEGER 1,
        BALSHEY_NF      21 INT 2,
        BALSHTMTH_NF    23 UINTEGER 1,
        AUTUPD_B        24 UINTEGER 1,
        COMACC_B        25 UINTEGER 1,
        PROPAG_RES_B      26 UINTEGER 1,
        CRE_D             28 CHAR 17
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      CRE_D DESCENDING
exit
EOF
SORT


NSTEP=${NJOB}_400
# Launching cleaning chain ESID0002
#------------------------------------------------------------------------------
LIBEL="Launching cleaning chain ESID0002"
IBC=${IB}
INPUT_FILE1="${DFILT}/${NJOB}_050_${IB}_VLIFEST_wESTCRB_E.dat"
INPUT_FILE2="${DFILT}/${NJOB}_300_${IB}_ESTC3713_VLIFEST_SEG_MAJ.dat"
OUTPUT_FILE_NAME="${DFILT}/${NSTEP}_${IB}_VLIFEST_SEG_MAJ_woDOUBLON.dat"
OUTPUT_FILE_NAME_DIFF="${DFILT}/${NSTEP}_${IB}VLIFEST_SEG_MAJ_DOUBLON.dat"
${DCMD}/ESID0002.cmd ${IBC} ${OUTPUT_FILE_NAME} ${OUTPUT_FILE_NAME_DIFF} ${INPUT_FILE1} ${INPUT_FILE2} 2>&1 | ${TEE}
IB=${IBC}

NSTEP=${NJOB}_450
# Merging VLIFEST without automatique et segmente and automatique et segmente update to rebuilt it
#------------------------------------------------------------------------------
LIBEL="Merging VLIFEST without automatique/segmente and automatique/segmente update to rebuilt it PASSAGE ${PASS}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_400_${IB}_VLIFEST_SEG_MAJ_woDOUBLON.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_050_${IB}_VLIFEST_woESTCRB_E.dat 1000 1"
SORT_O="${EST_VLIFEST_AUTOSEG} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF        2:1 - 2:,
        END_NT        3:1 - 3:,
        SEC_NF        4:1 - 4:,
        UWY_NF        5:1 - 5:,
        UW_NT         6:1 - 6:,
        GAAP_NF       22:1 - 22:
/KEYS 
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      GAAP_NF
/STABLE
exit
EOF
SORT

#[004] Retrait du code de SPLIT par ESID0003

# gzip fichiers temporaires
#------------------------------------------------------------------------------ 
gzip -c  ${EST_VLIFEST_AUTOSEG}  > ${DFILT}/${NJOB}_455_VLIFEST_AUTOSEG_OUTPUT.dat.gz

NSTEP=${NJOB}_460
# Deletion of Temporary Files
#------------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"

# Job End
JOBEND
