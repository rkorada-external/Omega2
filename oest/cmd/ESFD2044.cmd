#!/bin/ksh
#=============================================================================
# nom de l'application          : Reinsurance Analytics
# nom du script SHELL           : ESID2044.cmd
# revision                      : $Revision:   1.8  $
# date de creation              : 18/07/16
# auteur                        : KEDDACHE Rafik (RKE) + MMA
# references des specifications : 
#-----------------------------------------------------------------------------
# description :
#   Rassurance Analitique - RA impact Inventaire
#       Creation de fichiers Pour RA :
#   		  VENTILATION DE LA RETRO PAR PLACEMENT
# Input files
#       EST_FVPLACEMT            DFILI
#       EST_LIFESTNOACC          DFILI
#       EST_LIFENDCPT            DFILI
#       EST_VLIFEST195           DFILI
#       EST_SUBTRS               DFILI
#  Output file
#       EST_SRGTR_VENTIL         DFILI
#
#
#   Job launched by ESID2040.cmd
#-----------------------------------------------------------------------------
# historique des modifications :
# <[xxx]> <jj/mm/aaaa> <auteur> <SPOT/SPIRA> <description de la modification>
# 001    08/12/2016   DFI      RA           Retrait des ACY <= BILAN du SRGTR_VENTIL
# 002    19/12/2016   DFI      RA           recopie CUR et AMT_M pour gaap 1
# 003    06/01/2017   MMA      RA           annulation de la correction 001
#                                    003-A  Ajout du TIMESHIFT_LIFEST 
#                                    003-B  Identification des lignes ACY_NF <= BALSHTMTH_NF qui vont dans SRV et pas dans le GLT
# 004    10/01/2017   DFI      57931 SRV RA Intégration des lignes du VLIFEST195 au traitement du ESTC2046 (correction GAAP DIFF)
#                                           + correction des commentaires et LIBEL
# [005]  17/01/2017  R.Cassis  57931 SRV RA On ne prend que acy >= bilan-1 du VLIFEST195 pour optimisation - si acvy = bilan, alors mode = PC
#                                           Ajout des donnees VLIFEST195 pour postes 435 et 439 - le EST_LIFENDCPT est plus pris.
#[006] R.CASSIS 14/02/2017 spira 59564 :spot:xxxxx - ACY + LIF_ACY_MAX sont supprimés du EST_SRGTR_VENTIL en sortie - on prend les liberations Acc
#                                           des acy = annee bilan -4 de vlifest95
#[007] DFI      28/03/2017 spira 60218      Multiplication des gaap avant ESTC2046 pour bien sortir les compléments en suffixe A (annulation si inexistant)
#                                           Ajout dedoublonnage lifest avant
#[008] DFI      06/04/2017 spira 60218      Fusion STEP 13 et 14
#==============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
ICLODAT_D=$3
CRE_D=$4
ICLODAT_MTH=$5
CLODAT_D=$6
MODE=$7

LIF_ACY_MAX=4
LIF_ACY_MIN=4

# Initialise JOB
JOBINIT

ACY_LIFEST=${BALSHTYEA_NF}

ECHO_LOG ""
ECHO_LOG "#===============================   ${MODE}    ================================"
ECHO_LOG "#===============================   PARAMETRES   =============================="
ECHO_LOG "#===> BALSHTYEA_NF ......: ${BALSHTYEA_NF}"
ECHO_LOG "#===> ACY_LIFEST ........: ${ACY_LIFEST}"
ECHO_LOG "#===> BALSHTMTH_NF ......: ${BALSHTMTH_NF}"
ECHO_LOG "#===> ICLODAT_D .........: ${CLODAT_D}"
ECHO_LOG "#===> CRE_D .............: ${CRE_D}"
ECHO_LOG "#===> LIF_ACY_MAX .......: ${LIF_ACY_MAX}"
ECHO_LOG "#===> LIF_ACY_MIN .......: ${LIF_ACY_MIN}"

ECHO_LOG "#===============================   IMPUT FILE   =============================="
ECHO_LOG "#===> EST_LIFESTNOACC ..........: ${EST_LIFESTNOACC}"
ECHO_LOG "#===> EST_LIFENDCPT ............: ${EST_LIFENDCPT}"
ECHO_LOG "#===> EST_VLIFEST195 ...........: ${EST_VLIFEST195}"
ECHO_LOG "#===> EST_FVPLACEMT ............: ${EST_FVPLACEMT}"
ECHO_LOG "#===> EST_SUBTRS ...............: ${EST_SUBTRS}"
ECHO_LOG "#===> EST_SUBTRSESBPROP ........: ${EST_SUBTRSESBPROP}"
ECHO_LOG "#===> EST_IARVPERICASE4 ........: ${EST_IARVPERICASE4}"

ECHO_LOG "#=============================  OUTPUT FILE    ================================"
ECHO_LOG "#===> EST_SRGTR_VENTIL ........: ${EST_SRGTR_VENTIL}"
ECHO_LOG "#=============================================================================="
ECHO_LOG ""


NSTEP=${NJOB}_10
# SORT of FVPLACEMT
#----------------------------------------------------------------------------
LIBEL="SORT of FVPLACEMT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
set -x
SORT_I="${EST_FVPLACEMT} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FVPLACEMT_O.dat 1000 1"
set +x
INPUT_TEXT $SORT_CMD <<EOF
/FIELD  RCTR_NF     3:1 - 3:,
        RSEC_NF     5:1 - 5: EN,
        RTY_NF      6:1 - 6: EN
/KEYS RCTR_NF,RSEC_NF,RTY_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT

#[005] [006] [008]
NSTEP=${NJOB}_14
# Extract ACY>=BALSHYEA and old ending and beginning 
#----------------------------------------------------------------------------
LIBEL="Extract ACY>=BALSHYEA and old ending and beginning"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
set -x
SORT_I="${EST_VLIFEST195} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_VLIFEST195.dat"
set +x
INPUT_TEXT $SORT_CMD <<EOF
/FIELD  ACY_NF          7:1 -  7:EN,
        ACMTRS_NT      10:1 - 10: ,
        ACMTRS_NT1     10:1 - 10:1,
        ACMTRS_NT4     10:4 - 10:4,
        DETTRNCOD_CF   20:1 - 20: ,
        DETTRNCOD_CF01 20:1 - 20:1,
        DETTRNCOD_CF1  20:1 - 20:3 
/CONDITION bilan (ACY_NF >= ${ACY_LIFEST}) or
                 (ACY_NF = `expr ${BALSHTYEA_NF} - ${LIF_ACY_MIN}` and (DETTRNCOD_CF1 = "435" OR DETTRNCOD_CF1 = "439")) or
                 (ACY_NF = `expr ${BALSHTYEA_NF} - 4` and ACMTRS_NT1 = "1" and ACMTRS_NT4 = "4") or
                 (ACY_NF = `expr ${BALSHTYEA_NF} - 5` and ACMTRS_NT1 = "2" and ACMTRS_NT4 = "3")
/OUTFILE ${SORT_O}
/INCLUDE bilan
exit
EOF
SORT

gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_VLIFEST195.dat > ${DFILT}/${NSTEP}_SORT_VLIFEST195.dat.gz

NSTEP=${NJOB}_15
# Sort LIFENDCPT, LIFESTNOACC and VLIFEST195
#----------------------------------------------------------------------------
LIBEL="Sort and merge LIFENDCPT, LIFESTNOACC and VLIFEST195"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
set -x
SORT_I="${EST_LIFESTNOACC} 1000 1"
#SORT_I2="${EST_LIFENDCPT} 1000 1"  # donnees pas souhaitees pour RA (RC)
#SORT_I3="${EST_VLIFEST195} 1000 1" #[005]
SORT_I2="${DFILT}/${NJOB}_14_${IB}_SORT_VLIFEST195.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat"
set +x
INPUT_TEXT $SORT_CMD <<EOF
/FIELD  CTR_NF        2:1 -  2: ,
        SEC_NF        4:1 -  4: ,
        UWY_NF        5:1 -  5: EN ,
        ACY_NF        7:1 -  7: EN ,
        CRE_D         8:1 -  8: ,        
        ACMTRS_NT    10:1 - 10: ,
        DETTRNCOD_CF 20:1 - 20: ,
        GAAP_NF      22:1 - 22:      
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT

gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat > ${DFILT}/${NSTEP}_SORT_LIFEST_O.dat.gz

#[007]
NSTEP=${NJOB}_16
# Deduplicate estimations with ESID0002
#------------------------------------------------------------------------------
LIBEL="Deduplicate estimations with ESID0002"
IBC=${IB}
INPUT_FILE1="${DFILT}/${NJOB}_15_${IB}_SORT_LIFEST_O.dat"
OUTPUT_FILE_NAME="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat"
OUTPUT_FILE_NAME_DIFF="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O_DOUBLON.dat"
${DCMD}/ESID0002.cmd ${IBC} ${OUTPUT_FILE_NAME} ${OUTPUT_FILE_NAME_DIFF} ${INPUT_FILE1} ${INPUT_FILE2} 2>&1 | ${TEE}
IB=${IBC}

gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat > ${DFILT}/${NSTEP}_SORT_LIFEST_LAST.dat.gz

#[007]
NSTEP=${NJOB}_17
#Multiplicate LIFEST in all 5 gaap
#----------------------------------------------------------------------------
LIBEL="Multiplicate LIFEST in all 5 gaap"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_16_${IB}_SORT_LIFEST_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O1.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O2.dat
SORT_O3=${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O3.dat
SORT_O4=${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O4.dat
SORT_O5=${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O5.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS  ZONE1       1: - 13:,
        ZONE2      15: - 21:,
        ZONE3      23: - 54:
/DERIVEDFIELD MNT "0.000~"
/DERIVEDFIELD GAAP1 "1~"
/DERIVEDFIELD GAAP2 "2~"
/DERIVEDFIELD GAAP3 "3~"
/DERIVEDFIELD GAAP4 "4~"
/DERIVEDFIELD GAAP5 "5~"
/COPY
/OUTFILE ${SORT_O}
/REFORMAT ZONE1,MNT, ZONE2,GAAP1,ZONE3
/OUTFILE ${SORT_O2}
/REFORMAT ZONE1,MNT, ZONE2,GAAP2,ZONE3
/OUTFILE ${SORT_O3}
/REFORMAT ZONE1,MNT, ZONE2,GAAP3,ZONE3
/OUTFILE ${SORT_O4}
/REFORMAT ZONE1,MNT, ZONE2,GAAP4,ZONE3
/OUTFILE ${SORT_O5}
/REFORMAT ZONE1,MNT, ZONE2,GAAP5,ZONE3
exit
EOF
SORT

gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O1.dat > ${DFILT}/${NSTEP}_SORT_LIFEST_O1.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O2.dat > ${DFILT}/${NSTEP}_SORT_LIFEST_O2.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O3.dat > ${DFILT}/${NSTEP}_SORT_LIFEST_O3.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O4.dat > ${DFILT}/${NSTEP}_SORT_LIFEST_O4.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O5.dat > ${DFILT}/${NSTEP}_SORT_LIFEST_O5.dat.gz

#[007]
NSTEP=${NJOB}_18
#Multiplicate LIFEST in all 5 gaap
#----------------------------------------------------------------------------
LIBEL="Multiplicate LIFEST in all 5 gaap"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_16_${IB}_SORT_LIFEST_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_17_${IB}_SORT_LIFEST_O1.dat 1000 1"
SORT_I3="${DFILT}/${NJOB}_17_${IB}_SORT_LIFEST_O2.dat 1000 1"
SORT_I4="${DFILT}/${NJOB}_17_${IB}_SORT_LIFEST_O3.dat 1000 1"
SORT_I5="${DFILT}/${NJOB}_17_${IB}_SORT_LIFEST_O4.dat 1000 1"
SORT_I6="${DFILT}/${NJOB}_17_${IB}_SORT_LIFEST_O5.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_ALL_GAAP_O1.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF        2:1 -  2:,
        SEC_NF        4:1 -  4:,
        UWY_NF        5:1 -  5:,
        ACY_NF        7:1 -  7:,
        CRE_D         8:1 -  8:,
        ACMTRS_NT     10:1 - 10:,
        ESTMNT_M      14:1 - 14:EN 15/3,
        DETTRNCOD_CF  20:1 - 20:,
        GAAP_NF       22:1 - 22:,
        GAAPDIFF_M    23:1 - 23:EN 15/3
/KEYS CTR_NF,
      SEC_NF,
      ACY_NF,
      UWY_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF
/SUMMARIZE TOTAL ESTMNT_M, TOTAL GAAPDIFF_M
/OUTFILE ${SORT_O}
exit
EOF
SORT

gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_ALL_GAAP_O1.dat > ${DFILT}/${NSTEP}_SORT_LIFEST_ALL_GAAP_O1.dat.gz

NSTEP=${NJOB}_20
# Calcul de la difference de Gaap 
#------------------------------------------------------------------------------
LIBEL="DiffGaap Calculation"
PRG=ESTC2046
export ${PRG}_I1=${DFILT}/${NJOB}_18_${IB}_SORT_LIFEST_ALL_GAAP_O1.dat #[007]
export ${PRG}_I2=${EST_SUBTRSESBPROP}
export ${PRG}_I3=${EST_SUBTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_STLIFEST10_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_VLIFEST_ERR.log
EXECPRG

gzip -c ${DFILT}/${NJOB}_20_${IB}_ESTC2046_STLIFEST10_O1.dat > ${DFILT}/${NJOB}_20_ESTC2046_STLIFEST10_O1.dat.gz

#[008]
NSTEP=${NJOB}_25
# Extract liberation from STLIFEST
#----------------------------------------------------------------------------
LIBEL="Extract liberation from STLIFEST"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
set -x
SORT_I="${DFILT}/${NJOB}_20_${IB}_${PRG}_STLIFEST10_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_LIFEST_LIB.dat"
set +x
INPUT_TEXT $SORT_CMD <<EOF
/FIELD  ACY_NF          7:1 -  7:EN,
        ACMTRS_NT      10:1 - 10: ,
        ACMTRS_NT1     10:1 - 10:1,
        ACMTRS_NT4     10:4 - 10:4,
        DETTRNCOD_CF   20:1 - 20: ,
        DETTRNCOD_CF01 20:1 - 20:1,
        DETTRNCOD_CF1  20:1 - 20:3 
/CONDITION acy_lib (ACY_NF = `expr ${BALSHTYEA_NF} - ${LIF_ACY_MIN}` and (DETTRNCOD_CF1 = "435" OR DETTRNCOD_CF1 = "439")) or
                   (ACY_NF = `expr ${BALSHTYEA_NF} - 4` and ACMTRS_NT1 = "1" and ACMTRS_NT4 = "4") or
                   (ACY_NF = `expr ${BALSHTYEA_NF} - 5` and ACMTRS_NT1 = "2" and ACMTRS_NT4 = "3")                 
/OUTFILE ${SORT_O}
/INCLUDE acy_lib
exit
EOF
SORT

NSTEP=${NJOB}_30
# Sort LIFENDCPT, LIFESTNOACC and VLIFEST195
#----------------------------------------------------------------------------
LIBEL="Sort Estimates"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
set -x
SORT_I="${DFILT}/${NJOB}_20_${IB}_ESTC2046_STLIFEST10_O1.dat 1000 1"
#SORT_I2="${EST_VLIFEST195} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat 1000"
set +x
INPUT_TEXT $SORT_CMD <<EOF
/FIELD  CTR_NF        2:1 -  2: ,
        SEC_NF        4:1 -  4: ,
        UWY_NF        5:1 -  5: EN ,
        ACY_NF        7:1 -  7: EN ,
        CRE_D         8:1 -  8:,        
        ACMTRS_NT    10:1 - 10: ,
        DETTRNCOD_CF 20:1 - 20: ,
        GAAP_NF         22:1 - 22:,
        BALSHEY_NF  11:1 - 11:,
        BALSHMTH_NF 12:1 - 12:EN            
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF,
      BALSHEY_NF DESCENDING,
      BALSHMTH_NF DESCENDING,
      CRE_D DESCENDING
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_33
# [003-A]
# Separation des écritures allant ou non dans le GLT
#------------------------------------------------------------------------------
LIBEL="Excluding GLT Feeding line"
PRG=ESTC2049
set -x
export ${PRG}_I1=${DFILT}/${NJOB}_30_${IB}_SORT_LIFEST_O.dat
export ${PRG}_I2=${EST_SUBTRSESBPROP}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST_O.dat
set +x
FPRM=`CFTMP`
export ${PRG}_PRM=${FPRM}
INPUT_TEXT ${FPRM} <<EOF
BALSHTYEA_NF ${BALSHTYEA_NF}
exit
EOF
EXECPRG

NSTEP=${NJOB}_35
# [003-B]
# [020] Recuperation estimation ACY=BILAN des traites decales quand BALSHTMTH_NF > mois d'effet
#------------------------------------------------------------------------------
LIBEL="Recuperation estimation ACY=BILAN des traites decales quand BALSHTMTH_NF < mois d'effet"
PRG=STAM1508
set -x
export ${PRG}_I1=${EST_IARVPERICASE4}
export ${PRG}_I2=${DFILT}/${NJOB}_30_${IB}_SORT_LIFEST_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_TIMESHIFT_LIFEST.dat
set +x
FPRM=`CFTMP`
export ${PRG}_PRM=${FPRM}
INPUT_TEXT ${FPRM} <<EOF
BALSHTYEA_NF ${BALSHTYEA_NF}
BALSHTMTH_NF ${BALSHTMTH_NF}
exit
EOF
EXECPRG

gzip -c ${DFILT}/${NJOB}_33_${IB}_ESTC2049_LIFEST_O.dat > ${DFILT}/${NJOB}_33_ESTC2049_LIFEST_O.dat.gz
gzip -c ${DFILT}/${NJOB}_35_${IB}_STAM1508_TIMESHIFT_LIFEST.dat > ${DFILT}/${NJOB}_35_STAM1508_TIMESHIFT_LIFEST.dat.gz

NSTEP=${NJOB}_37
# [003]
# Merge of estimates (VLIFEST + LIFESTANA + LIFESTNOACC) and TIMESHIFT_LIFEST
#----------------------------------------------------------------------------
LIBEL="Merge of estimates and sort for deduplication"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
set -x
SORT_I="${DFILT}/${NJOB}_33_${IB}_ESTC2049_LIFEST_O.dat 1000"
SORT_I2="${DFILT}/${NJOB}_35_${IB}_STAM1508_TIMESHIFT_LIFEST.dat 1000"
SORT_I3="${DFILT}/${NJOB}_25_${IB}_LIFEST_LIB.dat 1000"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat 1000"
set +x
INPUT_TEXT $SORT_CMD <<EOF
/FIELD  CTR_NF        2:1 -  2: ,
        SEC_NF        4:1 -  4: ,
        UWY_NF        5:1 -  5: EN ,
        ACY_NF        7:1 -  7: EN ,
        CRE_D         8:1 -  8:,        
        ACMTRS_NT    10:1 - 10: ,
        DETTRNCOD_CF 20:1 - 20: ,
        GAAP_NF         22:1 - 22:,
        BALSHEY_NF  11:1 - 11:,
        BALSHMTH_NF 12:1 - 12:EN            
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF,
      BALSHEY_NF DESCENDING,
      BALSHMTH_NF DESCENDING,
      CRE_D DESCENDING
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_40
# Dédoublonnage
#------------------------------------------------------------------------------
LIBEL="Deduplication"
PRG=ESTC2040
export ${PRG}_I1=${DFILT}/${NJOB}_37_${IB}_SORT_LIFEST_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_STLIFEST10_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_STLIFESTOLD_O2.dat
EXECPRG

gzip -c ${DFILT}/${NJOB}_37_${IB}_SORT_LIFEST_O.dat > ${DFILT}/${NJOB}_37_SORT_LIFEST_O.dat.gz
gzip -c ${DFILT}/${NJOB}_40_${IB}_ESTC2040_STLIFEST10_O1.dat > ${DFILT}/${NJOB}_40_ESTC2040_STLIFEST10_O1.dat.gz

NSTEP=${NJOB}_50
# Mise au format GT du fichier prevision
#------------------------------------------------------------------------------
LIBEL="Mise au format GT du fichier des previsions"
PRG=STAM1502
set -x
export ${PRG}_I1=${DFILT}/${NJOB}_40_${IB}_ESTC2040_STLIFEST10_O1.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_STGTEST15_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_STGTEST15_ANA_O1.dat
set +x
FPRM=`CFTMP`
export ${PRG}_PRM=${FPRM}
INPUT_TEXT ${FPRM} <<EOF
AMOUNT_CT    1
ICLODAT_D ${ICLODAT_D}
exit
EOF
EXECPRG

gzip -c ${DFILT}/${NJOB}_50_${IB}_STAM1502_STGTEST15_O1.dat > ${DFILT}/${NJOB}_50_STAM1502_STGTEST15_O1.dat.gz

#[005]
NSTEP=${NJOB}_55
#-----------------------------------------------------------------------------
LIBEL="If ACY = Bilan then insert PC mode"
set -x
AWK_I=${DFILT}/${NJOB}_50_${IB}_STAM1502_STGTEST15_O1.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_STGTEST15_O1.dat
set +x
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
{
	if (\$14 == \$3) {\$58 = "PC"};
	print \$0
}
exit
EOF
AWK

gzip -c ${DFILT}/${NJOB}_55_${IB}_AWK_STGTEST15_O1.dat > ${DFILT}/${NJOB}_55_AWK_STGTEST15_O1.dat.gz

NSTEP=${NJOB}_60
# Filter RETRO
#[006]
#------------------------------------------------------------------------------
LIBEL="Filter les postes retro"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
set -x
SORT_I="${DFILT}/${NJOB}_55_${IB}_AWK_STGTEST15_O1.dat 1000 "   #[005]
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_STGTR_O.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_STGTA_O.dat 1000 1"
set +x
INPUT_TEXT $SORT_CMD <<EOF
/FIELD  CTR_NF     8:1 -  8: ,
        SEC_NF    10:1 - 10: ,
        UWY_NF    11:1 - 11: EN ,
        ACY_NF    14:1 - 14: EN ,
        ACMTRS_NT 45:1 - 45:,
        TRNCOD_CF  6:1 -  6:,
        TRNCOD1_CF 6:1 -  6:1
/KEYS CTR_NF,SEC_NF,UWY_NF,ACY_NF,ACMTRS_NT,TRNCOD_CF
/CONDITION ACCEPT (TRNCOD1_CF = '1' OR TRNCOD1_CF = '3')
/OUTFILE ${SORT_O}
/OMIT ACCEPT
/OUTFILE ${SORT_O2}
/INCLUDE ACCEPT
exit
EOF
SORT

NSTEP=${NJOB}_70
# Ajout ACCRET 'R' pour fichier retro
#------------------------------------------------------------------------------
LIBEL="# Ajout ACCRET 'R' pour fichier retro"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
set -x
SORT_I="${DFILT}/${NJOB}_60_${IB}_SORT_STGTR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_STGTR_O.dat 1000 1"
set +x
INPUT_TEXT $SORT_CMD <<EOF
/FIELD  CTR_NF     8:1 -  8: ,
        SEC_NF    10:1 - 10: ,
        UWY_NF    11:1 - 11: EN ,
        ACY_NF    14:1 - 14: EN ,
        ACMTRS_NT 45:1 - 45:,
        TRNCOD_CF  6:1 -  6:,
        FILLER1    1:1 -  59:,
        FILLER2   61:1 -  73:
/KEYS CTR_NF,SEC_NF,UWY_NF,ACY_NF,ACMTRS_NT,TRNCOD_CF
/DERIVEDFIELD ACCRET_B1 "R~"
/OUTFILE ${SORT_O}
/REFORMAT FILLER1, ACCRET_B1, FILLER2
exit
EOF
SORT

gzip -c ${DFILT}/${NJOB}_70_${IB}_SORT_STGTR_O.dat > ${DFILT}/${NJOB}_70_SORT_STGTR_O.dat.gz

NSTEP=${NJOB}_80
# Ventilation par placement des estimations au format GT
#------------------------------------------------------------------------------
LIBEL="Amount by retrocessionnaire"
PRG=STAM1225
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_FVPLACEMT_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_70_${IB}_SORT_STGTR_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_SRGTR_VENTIL.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_STGTR_REJET_O1.log
FPRM=`CFTMP`
export ${PRG}_PRM=${FPRM}
INPUT_TEXT ${FPRM} <<EOF
BALSHTYEA_NF ${BALSHTYEA_NF}
exit
EOF
EXECPRG

NSTEP=${NJOB}_90
# Merge estimate acceptation and cession data
# [001] Retrait des ACY <= BILAN du SRGTR_VENTIL
# [002] recopie devise et montant pour gaap 1
#[006]
#----------------------------------------------------------------------------
LIBEL="Regroupement des données ESTIMATION acceptation et retro"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
set -x
SORT_I="${DFILT}/${NJOB}_80_${IB}_STAM1225_SRGTR_VENTIL.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_60_${IB}_SORT_STGTA_O.dat 1000 1"
SORT_O=${EST_SRGTR_VENTIL}
set +x
INPUT_TEXT $SORT_CMD <<EOF
/FIELD  TRNCOD1_CF    6:1 - 6:1,
        TRNCOD8_CF    6:8 - 6:8,
        CTR_NF        8:1 - 8:,
        UWY_NF       11:1 - 11: EN,
        SEC_NF       10:1 - 10: EN,
        ACY_NF       14:1 - 14: EN,
        AMT_M        19:1 - 19:,
        ESTCUR_CF    42:1 - 42:,
        ESTAMT_M     43:1 - 43:,
        FILLER1      1:1  - 17:,
        FILLER2      20:1 - 73:
/KEYS CTR_NF,SEC_NF,UWY_NF, ACY_NF
/CONDITION GAAP1 (TRNCOD8_CF EQ "2")
/CONDITION ACY_MAX ACY_NF <= `expr ${BALSHTYEA_NF} + ${LIF_ACY_MAX}` and
                   ACY_NF >= `expr ${BALSHTYEA_NF} - ${LIF_ACY_MIN}`
/DERIVEDFIELD CUR ESTCUR_CF
/DERIVEDFIELD AMT IF GAAP1 THEN ESTAMT_M ELSE AMT_M
/OUTFILE ${SORT_O}
/INCLUDE ACY_MAX
/REFORMAT FILLER1, CUR, AMT, FILLER2
exit
EOF
SORT

NSTEP=${NJOB}_990
# Suppression des fichiers Temporaires
#------------------------------------------------------------------------------
LIBEL="Delete temporary files"
RMFIL "${DFILT}/${NJOB}*_*.dat"

JOBEND
