#!/bin/ksh
#=============================================================================
# nom de l'application          : Automatic Calculation
# nom du script SHELL           : ESID3026A.cmd
# revision                      : $Revision: 1.0 $
# date de creation              : 06/05/2015
# auteur                        : Paul GARNIER
# references des specifications : SPOT 28559
#-----------------------------------------------------------------------------
# description : Automatic calculation for treaties with ESTCRB=A (Automatic)
#               or E (Segmented)
#
# 2 Pass :
#   Pass 1 : calculate all acmtrs for Automatic
#            but only till 1510 (earned premium) for Segmented
#   Pass 2 : does nothing for Automatic
#            calculate the remaining acmtrs for Segemented
#
# job launched by ESID2030.cmd
#-----------------------------------------------------------------------------
# historique des modifications :
# [001] 06/05/2015 P.GARNIER spot:28742   : 
# [002] 03/06/2015 D.FILLINGER spot:28742: cleaning for UAT delivery
# [003] 10/05/2016 R.BEN EZZINE  :spot: : Optimisation ESID2030
# [004] 13/06/2016 S.ASKRI spot:30741 Traité segmenté : Date bilan fausse dans Hstorique des maj
# [005] 29/06/2016 D.FILLINGER :spot:30741 spira 52350 : les postes futurs sont doubles
# [006] 10/08/2016 S.ASKRI     :spot:31047 spira 53597 - 53228 : SRV : Estimations à 0 sur AC futures (suppression de la correction [005])
# [007] 05/08/2016 MMA         :SPOT:31053 spira 52411 - 48007 : Ajout de sinistralité pour les GAAP5 
# [008] 07/09/2016 S.ASKRI     :spot:31169 spira 53597 : SRV : Estimations à 0 sur AC futures pour les traités automatiques
# [009] 07/10/2016 MMA         :spot:31375 spira       : - Correction du repertoire des fichier archivés $DFILI -> $DFILT
#                                                        - Suppression de la correction [007]
#                                                        - Optimisation du traitement + Ajout du calcule sur 1 GAAP et propagation de GAAP
# [010] 25/11/2016 MMA         :            spira 56877: Supression du merge du VLIFEST195 avec le LIFESTNOACC car jamais séparer dans l'ESID3026
#
# [011] 30/07/2018 HHH         :            spira 62222: ajout en archive de fichiers en sortie s'il ne l'est pas  
# [012] 06/08/2018 HHH         :            spira 62222: Mise en archive de tous fichiers input du  module ESTC2045.c
# [013] 11/03/2019 B.LAGHA     :            spira 64222: Mettre le batch au niveau du GUI + implimentation des nouveaux calculs des postes 
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd
. ${DUTI}/fctws.cmd

# Get input parameters
BALSHTYEA_NF=$1
CRE_D=$2
PASS=$3
BALSHTMTH_NF=$4

# Job Initialisation
JOBINIT

if [ "${PASS}" = "1" ]
then

    # Archivage des fichiers en entree
    gzip -c ${EST_VLIFEST195}          > ${DFILT}/${NJOB}_000_VLIFEST195_INPUT_PASS${PASS}.dat.gz     #[009]
    gzip -c ${EST_IARVPERICASE4}       > ${DFILT}/${NJOB}_000_IARVPERICASE4_INPUT_PASS${PASS}.dat.gz  #[009]
  
    NSTEP=${NJOB}_050a
    # Splitting VLIFEST in two : Part with and without automatique et segmente
    #------------------------------------------------------------------------------
    LIBEL="Splitting VLIFEST in two : Part with and without automatique et segmente PASS${PASS}"
    SORT_WDIR=${SORTWORK}
    SORT_CMD=`CFTMP`
    SORT_NOINFILE="YES"
    SORT_I="${EST_VLIFEST195} 1000 1"
    # SORT_I2="${EST_LIFESTNOACC} 1000 1"   # [005]  #[006] #[010]
    SORT_O="${EST_VLIFEST_AUTOSEG}"     # VLIFEST with automatique et segmente
    INPUT_TEXT ${SORT_CMD} <<EOF
    /FIELDS 
        CTR_NF        2:1 - 2:,
        END_NT        3:1 - 3:,
        SEC_NF        4:1 - 4:,
        UWY_NF        5:1 - 5:,
        ACY_NF        7:1 - 7:,
        UW_NT         6:1 - 6:,
        GAAP_NF       22:1 - 22:,
        ESTCRB_CT     33:1 - 33:
    /KEYS 
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      GAAP_NF,
      ACY_NF
    /STABLE
    /CONDITION AUTOSEG (ESTCRB_CT = "A" OR ESTCRB_CT = "E") AND GAAP_NF = "1"
    /OUTFILE ${SORT_O}
    /INCLUDE AUTOSEG
    exit
EOF
    SORT

    gzip -c ${EST_VLIFEST_AUTOSEG}          > ${DFILT}/${NSTEP}_VLIFEST_AUTOSEG_PASS${PASS}.dat.gz     #[011]

    NSTEP=${NJOB}_070
    # Splitting IARVPERICASE4 in two : Part with and without automatique et segmente PASS${PASS}
    #------------------------------------------------------------------------------
    LIBEL="Splitting IARVPERICASE4 in two : Part with and without automatique et segmente PASS${PASS}"
    SORT_WDIR=${SORTWORK}
    SORT_CMD=`CFTMP`
    SORT_NOINFILE="YES"
    SORT_I="${EST_IARVPERICASE4} 1000 1"
    SORT_O="${EST_IARVPERICASE4_AUTOSEG}"     # IARVPERICASE4 with ONLY automatique & segmented
    INPUT_TEXT ${SORT_CMD} <<EOF
    /FIELDS 
        CTR_NF        2:1 - 2:,
        END_NT        3:1 - 3:,
        SEC_NF        4:1 - 4:,
        UWY_NF        5:1 - 5:,
        UW_NT         6:1 - 6:,
        ESTCRB_CT     24:1 - 24:
    /KEYS 
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
    /CONDITION AUTOSEG ESTCRB_CT = "A" OR ESTCRB_CT = "E"
    /OUTFILE ${SORT_O}
    /INCLUDE AUTOSEG
    exit
EOF
    SORT

    gzip -c ${EST_IARVPERICASE4_AUTOSEG} > ${DFILT}/${NSTEP}_PERICASE_AUTOSEG.dat.gz  #[009]
    gzip -c ${EST_IARVPERICASE4_AUTOSEG} > ${DFILT}/${NSTEP}_IARVPERICASE4_AUTOSEG_PASS${PASS}.dat.gz  #[011]

else  # $PASS = 2

    NSTEP=${NJOB}_050b
    # Splitting VLIFEST in two : Part with and without automatique et segmente
    #------------------------------------------------------------------------------
    LIBEL="Splitting VLIFEST in two : Part with and without automatique et segmente PASS${PASS}"
    SORT_WDIR=${SORTWORK}
    SORT_CMD=`CFTMP`
    SORT_NOINFILE="YES"
    SORT_I="${EST_VLIFEST_AUTOSEG} 1000 1"
    SORT_O="${DFILT}/${NSTEP}_VLIFEST_AUTOSEG.dat"     # VLIFEST with automatique et segmente
    INPUT_TEXT ${SORT_CMD} <<EOF
    /FIELDS 
        CTR_NF        2:1 - 2:,
        END_NT        3:1 - 3:,
        SEC_NF        4:1 - 4:,
        UWY_NF        5:1 - 5:,
        ACY_NF        7:1 - 7:,
        UW_NT         6:1 - 6:,
        GAAP_NF       22:1 - 22:,
        ESTCRB_CT     33:1 - 33:
    /KEYS 
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      GAAP_NF,
      ACY_NF
    /STABLE
    exit
EOF
    SORT

    gzip -c ${DFILT}/${NSTEP}_VLIFEST_AUTOSEG.dat  > ${DFILT}/${NSTEP}_VLIFEST_AUTOSEG_PASS${PASS}.dat.gz  #[011]

    NSTEP=${NJOB}_80
    # Copie du VLIFEST_AUTOSEG après Sort
    #-----------------------------------------------------------------------------
    LIBEL="Copy VLIFEST_AUTOSEG after sorting the file"
    EXECKSH "cp ${DFILT}/${NJOB}_050b_VLIFEST_AUTOSEG.dat ${EST_VLIFEST_AUTOSEG}"

fi

# Archivage du fichier produit
gzip -c ${EST_VLIFEST_AUTOSEG} > ${DFILT}/${NJOB}_VLIFEST_AUTOSEG_PASS${PASS}.dat.gz  #[009]
gzip -c ${EST_IARVPERICASE4_AUTOSEG} > ${DFILT}/${NJOB}_EST_IARVPERICASE4_AUTOSEG_PASS${PASS}.dat.gz  
gzip -c ${EST_CPLIFDRI} > ${DFILT}/${NJOB}_EST_CPLIFDRI_PASS${PASS}.dat.gz  
gzip -c ${EST_SUBTRSASSO} > ${DFILT}/${NJOB}_EST_SUBTRSASSO_PASS${PASS}.dat.gz  
gzip -c ${EST_TACCPAR} > ${DFILT}/${NJOB}_EST_TACCPAR_PASS${PASS}.dat.gz  
gzip -c ${EST_FTRSLNK} > ${DFILT}/${NJOB}_EST_FTRSLNK_PASS${PASS}.dat.gz  
gzip -c ${EST_SUBTRSESBPROP} > ${DFILT}/${NJOB}_EST_SUBTRSESBPROP_PASS${PASS}.dat.gz  

#--------------------------#
# Modification [013] start #
#--------------------------#
# On utilise que IAVPERICASE_ADDI car la retro n'a pas de contrat AUTO ou 
# SEG  (ici on fait que les calculs AUTO et SEG)
#------------------------------------------------------------------------------
NSTEP=${NJOB}_90
# Join and sort of perimetre files by CTR,END,SEC,UWY and UW
#------------------------------------------------------------------------------
LIBEL="Current Perimeters File Sort, Join and Fusion ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IARVPERICASE0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IARVPERICASE0_ADDI_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF_F1 3:1 - 3:,
        END_NT_F1 4:1 - 4:,
        SEC_NF_F1 5:1 - 5:,
        UWY_NF_F1 6:1 - 6:,
        UW_NT_F1  7:1 - 7:,
        ALL_F1    1:1 - 206:,
        CTR_NF_F2 2:1 - 2:,
        END_NT_F2 3:1 - 3:,
        SEC_NF_F2 4:1 - 4:,
        UWY_NF_F2 5:1 - 5:,
        UW_NT_F2  6:1 - 6:,
        ADDI_F_F2 7:1 - 19:
/INFILE ${EST_IARVPERICASE0} 1000 1 "~"
/JOINKEYS CTR_NF_F1,
          END_NT_F1,
          SEC_NF_F1,
          UWY_NF_F1,
          UW_NT_F1
/INFILE ${EST_IAVPERICASE0_ADDI} 1000 1 "~"
/JOINKEYS CTR_NF_F2,
          END_NT_F2,
          SEC_NF_F2,
          UWY_NF_F2,
          UW_NT_F2
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: ALL_F1, RIGHTSIDE: ADDI_F_F2
exit
EOF
SORT

NSTEP=${NJOB}_91
# Delete duplicate records of perimeters File by CTR,END,SEC,UWY and UW 
#------------------------------------------------------------------------------
LIBEL="Current perimeters files Delete duplicate records ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_90_${IB}_IARVPERICASE0_ADDI_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IARVPERICASE0_ADDI_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF_F1 3:1 - 3:,
        END_NT_F1 4:1 - 4:,
        SEC_NF_F1 5:1 - 5:,
        UWY_NF_F1 6:1 - 6:,
        UW_NT_F1  7:1 - 7:
/KEYS CTR_NF_F1,
      END_NT_F1,
      SEC_NF_F1,
      UWY_NF_F1,
      UW_NT_F1
/SUMMARIZE
/OUTFILE  ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_95
# Fichier Pericase contenant tous les exercices jusqu'a Annee de bilan + 4
#----------------------------------------------------------------------------
LIBEL="Fichier Pericase contenant tous les exercices jusqu'a Annee bilan + 4"
PRG=STAM1550
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
BALSHTYEA_NF ${BALSHTYEA_NF}
exit
EOF
export ${PRG}_I1="${DFILT}/${NJOB}_91_${IB}_SORT_IARVPERICASE0_ADDI_O.dat"
export ${PRG}_O1="${DFILT}/${NSTEP}_${IB}_IARVPERICASE4_ADDI_O.dat"
export ${PRG}_PRM=${FPRM}
EXECPRG

NSTEP=${NJOB}_98
# Join and sort of perimetre files by CTR,END,SEC,UWY and UW
#------------------------------------------------------------------------------
LIBEL="Current Perimeters File Sort and Join ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IARVPERICASE4_AUTOSEG} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IARVPERICASE4_AUTOSEG_ADDI_O.dat 1000 1"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT  7:1 - 7:,
        ALL_F2 1:1 - 219:
/INFILE ${EST_IARVPERICASE4_AUTOSEG} 1000 1 "~"
/JOINKEYS CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT
/INFILE ${DFILT}/${NJOB}_95_${IB}_IARVPERICASE4_ADDI_O.dat 1000 1 "~"
/JOINKEYS CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT
/OUTFILE ${SORT_O}
/REFORMAT RIGHTSIDE: ALL_F2
exit
EOF
SORT

NSTEP=${NJOB}_99
# Delete duplicate records of perimeters File by CTR,END,SEC,UWY and UW
#------------------------------------------------------------------------------
LIBEL="Current perimeters files Delete duplicate records ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_98_${IB}_IARVPERICASE4_AUTOSEG_ADDI_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IARVPERICASE4_AUTOSEG_ADDI_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF_F1 3:1 - 3:,
        END_NT_F1 4:1 - 4:,
        SEC_NF_F1 5:1 - 5:,
        UWY_NF_F1 6:1 - 6:,
        UW_NT_F1  7:1 - 7:
/KEYS CTR_NF_F1,
      END_NT_F1,
      SEC_NF_F1,
      UWY_NF_F1,
      UW_NT_F1
/SUMMARIZE
/OUTFILE  ${SORT_O}
exit
EOF
SORT

# Archivage des fichiers produits
gzip -c ${DFILT}/${NJOB}_99_${IB}_SORT_IARVPERICASE4_AUTOSEG_ADDI_O.dat > ${DFILT}/${NJOB}_99_${IB}_SORT_IARVPERICASE4_AUTOSEG_ADDI_O.dat.gz
gzip -c ${DFILT}/${NJOB}_91_${IB}_SORT_IARVPERICASE0_ADDI_O.dat > ${DFILT}/${NJOB}_91_${IB}_SORT_IARVPERICASE0_ADDI_O.dat.gz

#------------------------#
# Modification [013] end #
#------------------------#

NSTEP=${NJOB}_100
# calcul des segmente et des automatique
#[004]
#------------------------------------------------------------------------------
LIBEL="calcul des segmente et des automatique PASSAGE ${PASS}"
PRG=ESTC2045
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
BALSHTYEA_NF  ${BALSHTYEA_NF}
CRE_D ${CRE_D}
PASS ${PASS}
BALSHTMTH_NF ${BALSHTMTH_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_VLIFEST_AUTOSEG}
export ${PRG}_I2=${DFILT}/${NJOB}_99_${IB}_SORT_IARVPERICASE4_AUTOSEG_ADDI_O.dat
export ${PRG}_I3=${EST_CPLIFDRI}
export ${PRG}_I4=${EST_SUBTRSASSO}
export ${PRG}_I5=${EST_TACCPAR}
export ${PRG}_I6=${EST_FTRSLNK}
export ${PRG}_I7=${EST_SUBTRSESBPROP}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_VLIFEST_AUTOSEG_MAJ.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_VLIFEST_AUTOSEG_ANO.dat
cat ${FPRM}
EXECPRG

# Archivage des fichiers produits
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_VLIFEST_AUTOSEG_MAJ.dat > ${DFILT}/${NSTEP}_${PRG}_VLIFEST_AUTOSEG_MAJ_PASS${PASS}.dat.gz #[009]
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_VLIFEST_AUTOSEG_ANO.dat > ${DFILT}/${NSTEP}_${PRG}_VLIFEST_AUTOSEG_ANO_PASS${PASS}.dat.gz #[009]

NSTEP=${NJOB}_150
# Launching cleaning chain ESID0002
#------------------------------------------------------------------------------
LIBEL="Launching cleaning chain ESID0002 PASSAGE ${PASS}"
IBC=${IB}
INPUT_FILE1="${DFILT}/${NJOB}_100_${IB}_ESTC2045_VLIFEST_AUTOSEG_MAJ.dat"
OUTPUT_FILE_NAME="${DFILT}/${NSTEP}_${IB}_ESID0002_VLIFEST_AUTOSEG_MAJ_woDOUBLON.dat"
OUTPUT_FILE_NAME_DIFF="${DFILT}/${NSTEP}_${IB}_ESID0002_VLIFEST_AUTOSEG_MAJ_DOUBLON.dat"
${DCMD}/ESID0002.cmd ${IBC} ${OUTPUT_FILE_NAME} ${OUTPUT_FILE_NAME_DIFF} ${INPUT_FILE1} ${INPUT_FILE2} 2>&1 | ${TEE}
IB=${IBC}

gzip -c ${DFILT}/${NSTEP}_${IB}_ESID0002_VLIFEST_AUTOSEG_MAJ_woDOUBLON.dat > ${DFILT}/${NSTEP}_${IB}_ESID0002_VLIFEST_AUTOSEG_MAJ_woDOUBLON.dat.gz #[011]

NSTEP=${NJOB}_180
# Copy VLIFEST195 after cleaning
#-----------------------------------------------------------------------------
LIBEL="Copy VLIFEST_AUTOSEG after cleaning"
EXECKSH "cp ${DFILT}/${NJOB}_150_${IB}_ESID0002_VLIFEST_AUTOSEG_MAJ_woDOUBLON.dat ${EST_VLIFEST_AUTOSEG}"


if [ "${PASS}" = "2" ]
then

    NSTEP=${NJOB}_190
    # Propagation et verification des GAAP interdits 
    #------------------------------------------------------------------------------
    LIBEL="Propagation des GAAPs"
    PRG=ESTC2048
    FPRM=`CFTMP`
    INPUT_TEXT ${FPRM} <<EOF
CRE_D ${CRE_D}
exit
EOF
    export ${PRG}_PRM=${FPRM}
    export ${PRG}_I1=${EST_VLIFEST_AUTOSEG}
    export ${PRG}_I2=${EST_SUBTRSESBPROP}
    export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST_PROPAG.dat
    cat ${FPRM} > ${DFILT}/FPRM.dat
    EXECPRG
#     cd $DEXE
# #Pour lancer DBX
# debugV2 ${PRG}

# STEPEND 1
  
    gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST_PROPAG.dat > ${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST_PROPAG_PASS${PASS}.dat.gz #[011]

    NSTEP=${NJOB}_200
    # Merging VLIFEST without automatique et segmente and automatique et segmente update to rebuilt it
    #------------------------------------------------------------------------------
    LIBEL="Merging VLIFEST without automatique/segmente and automatique/segmente update to rebuilt it PASSAGE ${PASS}"
    SORT_WDIR=${SORTWORK}
    SORT_CMD=`CFTMP`
    SORT_I="${DFILT}/${NJOB}_190_${IB}_ESTC2048_LIFEST_PROPAG.dat 1000 1"
    SORT_I2="${EST_VLIFEST195} 1000 1"
    SORT_I3="${EST_LIFESTNOACC} 1000 1"
    SORT_O="${DFILT}/${NSTEP}_${IB}_VLIFEST195.dat"
    INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF        2:1 - 2:,
        END_NT        3:1 - 3:,
        SEC_NF        4:1 - 4:,
        UWY_NF        5:1 - 5:,
        UW_NT         6:1 - 6:,
        DETTRNCOD_CF  20:1 - 20:,
        GAAP_NF       22:1 - 22:
/KEYS 
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      GAAP_NF
/STABLE
/CONDITION DETTRNCOD_TMP DETTRNCOD_CF != "XXXXX"
/OUTFILE ${SORT_O}
/INCLUDE DETTRNCOD_TMP 
exit
EOF
    SORT
  
    gzip -c ${DFILT}/${NSTEP}_${IB}_VLIFEST195.dat > ${DFILT}/${NSTEP}_${IB}_VLIFEST195_PASS${PASS}.dat.gz #[011]

    NSTEP=${NJOB}_220
    # Launching cleaning chain ESID0002
    #------------------------------------------------------------------------------
    LIBEL="Launching cleaning chain ESID0002 PASSAGE ${PASS}"
    IBC=${IB}
    INPUT_FILE1="${DFILT}/${NJOB}_200_${IB}_VLIFEST195.dat"
    OUTPUT_FILE_NAME="${DFILT}/${NSTEP}_${IB}_ESID0002_VLIFEST_woDOUBLON.dat"
    OUTPUT_FILE_NAME_DIFF="${DFILT}/${NSTEP}_${IB}_ESID0002_VLIFEST_AUTOSEG_MAJ_DOUBLON.dat"
    ${DCMD}/ESID0002.cmd ${IBC} ${OUTPUT_FILE_NAME} ${OUTPUT_FILE_NAME_DIFF} ${INPUT_FILE1} ${INPUT_FILE2} 2>&1 | ${TEE}
    IB=${IBC}

gzip -c ${DFILT}/${NSTEP}_${IB}_ESID0002_VLIFEST_AUTOSEG_MAJ_DOUBLON.dat > ${DFILT}/${NSTEP}_${IB}_ESID0002_VLIFEST_AUTOSEG_MAJ_DOUBLON_PASS${PASS}.dat.gz #[011]
gzip -c ${DFILT}/${NJOB}_220_${IB}_ESID0002_VLIFEST_woDOUBLON.dat > ${DFILT}/${NSTEP}_220_${IB}_ESID0002_VLIFEST_woDOUBLON.dat.gz #[011]

    NSTEP=${NJOB}_250
    #------------------------------------------------------------------------------
    LIBEL="Launching spliting chain ESID0003"
    INPUT_FILE1="${DFILT}/${NJOB}_220_${IB}_ESID0002_VLIFEST_woDOUBLON.dat"
    OUTPUT_FILE_NAME_1="${EST_VLIFEST195}"
    OUTPUT_FILE_NAME_2="${EST_LIFESTNOACC}"
    ${DCMD}/ESID0003.cmd ${OUTPUT_FILE_NAME_1} ${OUTPUT_FILE_NAME_2} ${INPUT_FILE1} ${BALSHTYEA_NF} 2>&1 | ${TEE}
  
    # gzip fichiers temporaires
    #------------------------------------------------------------------------------ 
    gzip -c  ${EST_VLIFEST195}  > ${DFILT}/${NJOB}_250_VLIFEST_OUTPUT_${PASS}.dat.gz
    gzip -c  ${EST_LIFESTNOACC} > ${DFILT}/${NJOB}_250_LIFESTNOACC_OUTPUT_${PASS}.dat.gz

fi


# NSTEP=${NJOB}_260

# # Deletion of Temporary Files
# #------------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files PASSAGE ${PASS}"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"

JOBEND
