#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - COMMUNS
# nom du script SHELL           : ESCJ0663.cmd
# revision                      : 
# date de creation              : 06/09/2021
# auteur                        : M.NAJI
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#   Extraction quatidienne des  fichiers
#
# job launched by ESCJ0000.cmd
#-----------------------------------------------------------------------------
# Modification Records
#---------------
#Creation	    : 
#Auteur         : M.NAJI
#Date           : 06/09/2021
#Version        : 1.0
#Description    :Extraction quatidienne des  fichiers
#===============================================================================
#[001] 06/09/2021 M.NAJI   :spira:91532 Création
#[002] 31/05/2022 R.CASSIS :spira:104409 Gestion de la mise à jour de BEST..TCTRGRO pour EBS/POS
#===============================================================================

#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

############################################################
#[002] Steps deplacees provenant de ESCJ0661 - DEBUT
############################################################
OPTION=Q
SEGTYP_CT=A

NSTEP=${NJOB}_01
# Begin BCP
#-----------------------------------------------------------------------------
LIBEL="Download of BEST..TCTRGRO table"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FCTRGRO0}
BCP_QRY="execute BEST..PsSECTION_10 '${OPTION}', '${SEGTYP_CT}'"
BCP

#######################################################################################################################
#Switch on INFO CENTER server defined in the environment file
#----------------------------------------------------------------
SWITCH_SRV ${SRV_DW}

NSTEP=${NJOB}_02
#Generation of FCTRGROLESII File
#-----------------------------------------------------------------------------
LIBEL="FCTRGROLESII Segment File Generation from TUWSEC..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="${EST_FCTRGROLESII}"
BCP_QRY="execute BSAR..PsRISKMARGIN_SEG '${ICLODAT_D}', 'POS'  with recompile"
BCP

#Switch on TP server defined in the environment file
#----------------------------------------------------------------
SWITCH_SRV ${SRV_TP}
#######################################################################################################################

NSTEP=${NJOB}_03
#EST_FCTRGRO0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FCTRGRO0 ==> EST_FCTRGRO ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCTRGRO0} 1000 1"
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

############################################################
# Comparison of period closing and segmentation perimeters #
#[002]  O3 RoC pas utilisé !!
############################################################
NSTEP=${NJOB}_04
#Comparison of period closing and segmentation perimeters
#(by the contract grouping file)
#-----------------------------------------------------------------------------
LIBEL="Comparison of period closing process and segmentation perimeters ..."
PRG=ESTM1004
export ${PRG}_I1="${DFILT}/${NCHAIN}_ESCJ0662_160_${IB}_IADPERICASE_O2.dat"
export ${PRG}_I2=${EST_FCTRGRO}
export ${PRG}_O1=${EST_FCTRGRO1}
export ${PRG}_O2=${EST_PERIANO}
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_IADPERICASE.dat
EXECPRG

############################################################
#[002] Steps deplacees provenant de ESCJ0661 - FIN
############################################################

NSTEP=${NJOB}_05
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting acceptance perimeter file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADVPERICASE} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_IADVPERICASE_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_10
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting cession file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FCESSION0}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_CES_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
        UW_NT 5:1 - 5:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_20
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Computing new cession file..."
PRG=ESTC2301
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_SORT_IADVPERICASE_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_SORT_CES_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_ESTC2301_CES_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_RETNP_SEGMENT_O.dat    #[001]
EXECPRG


NSTEP=${NJOB}_30
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting new cession file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_20_${IB}_ESTC2301_CES_O.dat
SORT_O="${EST_FCES} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2: ,
        SEC_NF 3:1 - 3: ,
        UWY_NF 4:1 - 4: ,
        UW_NT 5:1 - 5: ,
        RETCTR_NF 6:1 - 6:,
        RETEND_NT 7:1 - 7: ,
        RETSEC_NF 8:1 - 8: ,
        RTY_NF 9:1 - 9: ,
        RETUW_NT 10:1 - 10:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
/CONDITION RETRO RETCTR_NF EQ ""
/OMIT RETRO
exit
EOF
SORT



NSTEP=${NJOB}_150
# Merging of life A+R perimeter
#------------------------------------------------------------------------------
LIBEL="Merging and Filtering of life A+R perimeter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IAVPERICASE0} 1000 1"
SORT_I2="${EST_IRVPERICASE0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IARV_PERICASE.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        CTR_NF 3:1 - 3:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF DESCENDING
/CONDITION NONVIE (SSD_CF = 5 OR SSD_CF = 6)
/OMIT NONVIE
/OUTFILE  ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_200
# Update underwriting data with the data of the last underwriting year
#------------------------------------------------------------------------------
LIBEL="Update underwriting data"
PRG=ESTC2041
export ${PRG}_I1=${DFILT}/${NJOB}_150_${IB}_IARV_PERICASE.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_IARV_PERICASE.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_MAJ_SECACCSTS_UWY_PREC.log
EXECPRG




NSTEP=${NJOB}_250
# Merging and Filtering of life A+R perimeter
#------------------------------------------------------------------------------
LIBEL="Merging and Filtering of life A+R perimeter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_200_${IB}_ESTC2041_IARV_PERICASE.dat 1000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_IAV_PERICASE.dat"
SORT_O1="${DFILT}/${NSTEP}_${IB}_IRV_PERICASE.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SEGTYP_CT  2:1 -  2:,
        CTR_NF     3:1 -  3:,
        SEC_NF     5:1 -  5:,
        UWY_NF     6:1 -  6:,
        ESTCRB_CT 24:1 - 24:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF
/CONDITION ACCEP SEGTYP_CT NE ""
/OUTFILE ${SORT_O1}
/OMIT ACCEP
/OUTFILE ${SORT_O}
/INCLUDE ACCEP
exit
EOF
SORT



NSTEP=${NJOB}_300
# Refreshing Fictitious Treaties and Analysis segments
## rechercher la section du traité de R qui correspond a la lob des Traité NC
#------------------------------------------------------------------------------
LIBEL="Refreshing Fictitious Treaties and Analysis segments"
PRG=ESTC2032
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
CRE_D ${CRE_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_250_${IB}_IAV_PERICASE.dat
export ${PRG}_I2=${EST_FSEGPAR}
export ${PRG}_I3=${EST_FCTRFIC}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_IAV_PERICASE.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FRATTACHEVOL.dat
export ${PRG}_O3=${EST_SEGRATANO}
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_RATTACHEMENT.log
EXECPRG




NSTEP=${NJOB}_350
#------------------------------------------------------------------------------
LIBEL="creating IADPERICASE from EST_FVCTRGRO"
PRG=ESTM1004
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
CRE_D ${CRE_D}
exit
EOF
export ${PRG}_I1=${DFILT}/${NJOB}_300_${IB}_ESTC2032_IAV_PERICASE.dat
export ${PRG}_I2=${EST_FVCTRGRO}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_FVCTRGRO1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_PERIANO.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_IAV_PERICASE.dat
EXECPRG


NSTEP=${NJOB}_445
#-----------------------------------------------------------------------------
LIBEL="Completion du ficher FTTHRHLDUWY avec les donnes de l'IADPERICASE "
DATE_T=`date +"%Y%m%d %H:%M:%S"`
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
echo " Date {$DATE_T} "
SORT_I="${EST_IADPERICASE0} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_FTHRHLDUWYBIS.dat
INPUT_TEXT ${SORT_CMD} <<EOF

/FIELDS SSD_CF 1:1 - 1: EN , ACCESB_CF  8:1 -  8:, LOB_CF  38:1 -  38:, NAT_CF  49:1 -  49: EN ,CTRNAT_CT 85:1 - 85:
/KEYS  SSD_CF ,ACCESB_CF ,LOB_CF,NAT_CF , CTRNAT_CT
/CONDITION COND_NATURE (CTRNAT_CT  != "F")
/CONDITION COND_NATURE1 (CTRNAT_CT  eq "P")
/DERIVEDFIELD NATURE IF  COND_NATURE  THEN  IF COND_NATURE1 THEN "1~" ELSE "2~" ELSE "3~"
/DERIVEDFIELD UWY "2003~"
/DERIVEDFIELD DATE1  "${DATE_T}~"
/DERIVEDFIELD DBO "dbo~"
/DERIVEDFIELD DATE2 "${DATE_T}~"
/DERIVEDFIELD DBO1 "dbo"
/OUTFILE   ${SORT_O}
/INCLUDE COND_NATURE
/REFORMAT SSD_CF,ACCESB_CF,LOB_CF,NATURE,UWY,DATE1,DBO,DATE2,DBO1
exit
EOF
SORT


NSTEP=${NJOB}_450
#Sort of life A+R perimeter
#------------------------------------------------------------------------------
LIBEL="Sort of life A+R perimeter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_350_${IB}_ESTM1004_IAV_PERICASE.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_250_${IB}_IRV_PERICASE.dat 1000 1"
SORT_O="${EST_IARVPERICASE0} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF
exit
EOF
SORT


NSTEP=${NJOB}_455
#-----------------------------------------------------------------------------
LIBEL="Merge des fichiers FTHRHLDUWY  et  FTHRHLDUWYBIS.dat "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FTHRHLDUWY}
SORT_I2="${DFILT}/${NJOB}_445_${IB}_FTHRHLDUWYBIS.dat"
SORT_O=${DFILT}/${NSTEP}_${IB}_FTHRHLDUWYTEMP.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN , ACCESB_CF 2:1 - 2: ,LOB_CF 3:1 - 3: ,NAT_CF 4:1 - 4: ,PARAM1 5:1 - 5:   ,DATE1 6:1 - 6: ,DBO 7:1 - 7: ,DATE2 8:1 - 8: ,DBO1 9:1 - 9:
/OUTFILE ${SORT_O}
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_460
#-----------------------------------------------------------------------------
LIBEL="dedoublonnage du fichier FTHRHLDUWYBIS.dat "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_455_${IB}_FTHRHLDUWYTEMP.dat
SORT_O=${EST_FTHRHLDUWY}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:, ACCESB_CF  2:1 -  2:, LOB_CF  3:1 -  3:, NAT_CF  4:1 -  4:
/KEYS  SSD_CF ,ACCESB_CF ,LOB_CF,NAT_CF
/SUM
/STABLE
/OUTFILE ${SORT_O}
exit
EOF
SORT


# End of Job
JOBEND


