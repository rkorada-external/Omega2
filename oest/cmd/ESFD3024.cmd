#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATION LOT 21
# nom du script SHELL           : ESID2031.cmd
# revision                      : 
# date de creation              : 
# auteur                        : 
# references des specifications :
#-----------------------------------------------------------------------------
# [001] 28/03/2015 Spot 28585 : Ajout fichier CPLLIFDRIN
# [002] 10/05/2016 R.BEN EZZINE  :spot: : Optimisation ESID2030
# [003] 03/06/2016 S.Behague :spot:30300 EST39
# [004] 18/10/2016 SBE :spot:31343 - Spira 30649 - Propagation Réserves
# [005] 13/12/2016 MMA :SPIRA 49155 - Correction de la proagation des reserves en
#                                     faiant 2 tries préalables
# [006] 15/02/2016 MMA :SPIRA 59274 - Propagation des réserve: activation conditionnelle (auto) 
#                                     du code selon si la propagation est active ou non
# [007] 24/07/2018 Roger Cassis :spira:69797 - remise en place du RMFIL de fin de batch
# [008] 18/12/2018 S.Behague    :REQ.L.02.05: Evolution quarterly
# [009] 11/10/2018 SBE  spira:30649: Merge - Batch: Fixed - INCIDENT IN RESERVES PROPAGATION FROM TAC AFTER COMPLETE ACCOUNT
# [010] 20/01/2021 SBE  spira:92290: [Apolo QE] TECH - On complete account year, Q4 estimation (equals to accounting) are calculated at each closing (TLIFESTD)
# [011] 30/09/2021 BEL  spira:93277: Sauvegarder les anciennes positions de LIFEST afin de les remettre dans CPLIFEST a la fin de la ESID2030 (Step 193Bis)
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Get input parameters
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
CRE_D=$3

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_100
# [005]
# [010]
# Taking into Account Annual Estimates Statistical Expiries
#------------------------------------------------------------------------------
LIBEL="TEST sort GT2"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_430_SORT_GT_O} 1000 1"
SORT_O=$DFILT/${NSTEP}_${IB}_SORT_GT2${IT}.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF           8:1 -  8:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        ACY_NF          14:1 - 14:,
        ACM_NF          75:1 - 75:EN,
        ACMTRS_NT       45:1 - 45:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACM_NF,
      ACMTRS_NT
/STABLE
exit
EOF
SORT

gzip -c $DFILT/${NSTEP}_${IB}_SORT_GT2${IT}.dat > $DFILT/${NSTEP}_SORT_GT2_${IT}.dat.gz

NSTEP=${NJOB}_105
# [005]
# Taking into Account Annual Estimates Statistical Expiries
#------------------------------------------------------------------------------
LIBEL="TEST sort VLIFEST195"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_VLIFEST2070} 1000 1"
SORT_O=$DFILT/${NSTEP}_${IB}_sort_VLIFEST2070${IT}.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF           2:1 -  2:,
        SEC_NF           4:1 -  4:,
        UWY_NF           5:1 -  5:,
        ACY_NF           7:1 -  7:,
        ACM_NF          25:1 - 25:EN,
        ACMTRS_NT       10:1 - 10:
/KEYS 
      CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACM_NF,
      ACMTRS_NT
/STABLE
exit
EOF
SORT

gzip -c $DFILT/${NSTEP}_${IB}_sort_VLIFEST2070${IT}.dat > $DFILT/${NSTEP}_sort_VLIFEST2070_${IT}.dat.gz

NSTEP=${NJOB}_110
# Taking into Account Annual Estimates Statistical Expiries
#------------------------------------------------------------------------------
LIBEL="Taking into Account Annual Estimates Statistical Expiries"
PRG=ESTC2038
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BALSHTYEA_NF  ${BALSHTYEA_NF}
BALSHTMTH_NF  ${BALSHTMTH_NF}
CRE_D ${CRE_D}
NB_YEAR 5
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=$DFILT/${NJOB}_100_${IB}_SORT_GT2${IT}.dat
export ${PRG}_I2=${EST_ESTC2035_LIFDRI_O1}
export ${PRG}_I3=$DFILT/${NJOB}_105_${IB}_sort_VLIFEST2070${IT}.dat
export ${PRG}_I4=${EST_SUBTRSESBPROP}
export ${PRG}_I5=${EST_SUBTRSASSO}
export ${PRG}_I6=${EST_SUBTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFDRI_O1${IT}.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST_O2${IT}.dat
export ${PRG}_O3=${EST_CPLIFDRIASC}
export ${PRG}_O4=$DFILT/${NSTEP}_${IB}_${PRG}_RESERVE_NOACC_01${IT}.dat
export ${PRG}_O5=$DFILT/${NSTEP}_${IB}_${PRG}_RESERVE_01${IT}.dat
EXECPRG

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_110_${IB}_ESTC2038_LIFEST_O2${IT}.dat                  > ${DFILT}/${NJOB}_110_ESTC2038_LIFEST_O2_${IT}.dat.gz
gzip -c ${DFILT}/${NJOB}_110_${IB}_ESTC2038_LIFDRI_O1${IT}.dat                  > ${DFILT}/${NJOB}_110_ESTC2038_LIFDRI_O1_${IT}.dat.gz
# ----------------------------------------


NSTEP=${NJOB}_115
#Sort of life A+R perimeter
#------------------------------------------------------------------------------
LIBEL="Sort of life A+R perimeter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IARVPERICASE4} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IARVPERICASE4_O${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF DESC
exit
EOF
SORT

NSTEP=${NJOB}_120
#Sort of life A+R perimeter
#------------------------------------------------------------------------------
LIBEL="Sort of life reserve file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_ESTC2038_RESERVE_01${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ESTC2038_RESERVE_02${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 2:1 - 2:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF DESC
exit
EOF
SORT

NSTEP=${NJOB}_125
# Loader programs V2
#-----------------------------------------------------------------------------
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Verification et recalcul des reserves propagees"
PRG=ESTC2053
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
exit
EOF
export ${PRG}_PRM=${DPRM}/${PRG}.prm
export ${PRG}_I1=${DFILT}/${NJOB}_115_${IB}_SORT_IARVPERICASE4_O${IT}.dat
export ${PRG}_I2=${DFILT}/${NJOB}_120_${IB}_ESTC2038_RESERVE_02${IT}.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_RESERVE_02${IT}.dat
EXECPRG

gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_RESERVE_02${IT}.dat > ${DFILT}/${NSTEP}_${PRG}_RESERVE_02${IT}.dat.gz

NSTEP=${NJOB}_130
#Sort of life A+R perimeter
#------------------------------------------------------------------------------
LIBEL="Sort of life A+R perimeter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_ESTC2038_RESERVE_NOACC_01${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ESTC2038_RESERVE_NOACC_02${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 2:1 - 2:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF DESC
exit
EOF
SORT

NSTEP=${NJOB}_135
# Loader programs V2
#-----------------------------------------------------------------------------
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Verification et recalcul des reserves propagees"
PRG=ESTC2053
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
exit
EOF
export ${PRG}_PRM=${DPRM}/${PRG}.prm
export ${PRG}_I1=${DFILT}/${NJOB}_115_${IB}_SORT_IARVPERICASE4_O${IT}.dat
export ${PRG}_I2=${DFILT}/${NJOB}_130_${IB}_ESTC2038_RESERVE_NOACC_02${IT}.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_RESERVE_NOACC_02${IT}.dat
EXECPRG

gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_RESERVE_NOACC_02${IT}.dat > ${DFILT}/${NSTEP}_${PRG}_RESERVE_NOACC_02${IT}.dat.gz


NSTEP=${NJOB}_190_1
# Tri du fichier RESERVE de sortie du traitement ESTC2038
# selon CTR et ACY
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_125_${IB}_ESTC2053_RESERVE_02${IT}.dat  1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_RESERVE_02${IT}.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF       1:1 -  1: EN,
        CTR_NF       2:1 -  2:,
        ACY_NF       7:1 -  7:,
        ACM_NF       25:1 - 25:EN
/KEYS CTR_NF,
      ACY_NF,
      ACM_NF
exit
EOF
SORT

NSTEP=${NJOB}_190_2
# Loader programs V2
#-----------------------------------------------------------------------------
# Begin programme C
#------------------------------------------------------------------------------
if [ ! -s $DFILT/${NJOB}_190_1_${IB}_RESERVE_02${IT}.dat ]
then
LIBEL="test"
PRG=ESTC2051
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1="$DFILT/${NJOB}_190_1_${IB}_RESERVE_02${IT}.dat"
export ${PRG}_I2="${EST_FCPLACC0}"
export ${PRG}_O1="${DFILT}/${NSTEP}_${IB}_RESERVE_03${IT}.dat"

EXECPRG
else
    cp $DFILT/${NJOB}_190_1_${IB}_RESERVE_02${IT}.dat ${DFILT}/${NSTEP}_${IB}_RESERVE_03${IT}.dat
fi

#[001]
NSTEP=${NJOB}_190A
# Tri fu fichier GT contenant les contrat non criblés
#------------------------------------------------------------------------------
LIBEL="Grouping All Treaties Transactions except non-sorted ones"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_470_SORT_GT_O} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT_O${IT}.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_DBLTRNCOD    1:1 -  5:,
        BALSHEY_NF       3:1 -  3:,
        TRNCOD_CF        6:1 -  6:,
        TRNCOD1_CF       6:1 -  6:1,
        TRNCOD5_CF       6:3 -  6:7,
        DBLTRNCOD_CF     7:1 -  7:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        OCCYEA_NF       13:1 - 13:,
        ACY_NF          14:1 - 14:EN,
        ACM_NF          75:1 - 75:EN,
        SCOSTR_CUR      15:1 - 18:,
        AMT_M           19:1 - 19:,
        CED_ESTCUR      20:1 - 42:,
        ESTAMT_M        43:1 - 43:EN 15/3,
        NAT_CF          44:1 - 44:,
        ACMTRS_NT       45:1 - 45:,
        ESTCTR_NF       46:1 - 46:,
        ESTSEC_NF       47:1 - 47:,
        LOB_CF          48:1 - 48:,
        SCOEGP_M        49:1 - 49:,
        ESTCRB_CT       50:1 - 50:,
        ESTCRB_UWGRP    50:1 - 75:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACM_NF,
      ACMTRS_NT,
      TRNCOD5_CF
/SUM TOTAL ESTAMT_M
/DERIVEDFIELD ESTAMT_MC ESTAMT_M COMPRESS
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD SCOEGP_MC SCOEGP_M COMPRESS
/DERIVEDFIELD DBLTRN "~"
/DERIVEDFIELD DBLTRN2 "~~"
/CONDITION NONVIE ( TRNCOD_CF = "" and CTR_NF="         ")
/CONDITION ACCEPT ( TRNCOD1_CF = "1" or TRNCOD1_CF = "3")
/DERIVEDFIELD ACCRET if ACCEPT then "A" else "R"
/OMIT NONVIE
/OUTFILE ${SORT_O}
/REFORMAT SSD_DBLTRNCOD,TRNCOD_CF,DBLTRN, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTR_CUR, AMT_MC,
          CED_ESTCUR, ESTAMT_MC, NAT_CF, ACMTRS_NT, ESTCTR_NF, ESTSEC_NF, LOB_CF, SCOEGP_MC, ESTCRB_UWGRP
exit
EOF
SORT

gzip -c $DFILT/${NJOB}_190A_${IB}_SORT_GT_O${IT}.dat                  > ${DFILT}/${NJOB}_190A_SORT_GT_O_${IT}.dat.gz

#[001]
NSTEP=${NJOB}_190B
# Positionnement du flag compte complet dans le fichier LIFDRI
# pour les contrat Non Criblés (ESTCRB_CT)
#------------------------------------------------------------------------------
LIBEL="Taking into Account Annual Estimates Statistical Expiries"
PRG=ESTC2050
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CRE_D ${CRE_D}
BALSHTYEA_NF  ${BALSHTYEA_NF}
BALSHTMTH_NF  ${BALSHTMTH_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_190A_${IB}_SORT_GT_O${IT}.dat
export ${PRG}_I2=${DFILT}/${NJOB}_110_${IB}_ESTC2038_LIFDRI_O1${IT}.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFDRI_O1${IT}.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${PRG}_LIFDRIN_ASCII${IT}.dat
EXECPRG

gzip -c ${DFILT}/${NJOB}_190B_${PRG}_LIFDRIN_ASCII${IT}.dat                 > ${DFILT}/${NJOB}_190B_${PRG}_LIFDRIN_ASCII_${IT}.dat.gz

NSTEP=${NJOB}_191
# Sort CPLIFDRI binary file
#[007] changement dans le tri pour pointer sur les bons champs
#------------------------------------------------------------------------------
LIBEL="Sort of CPLIFDRI binary file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_ESTC2038_LIFDRI_O1${IT}.dat fixed 112"
SORT_O=${EST_CPLIFDRI}
INPUT_TEXT $SORT_CMD << EOF
/FIELDS CTR_NF           1 CHAR 10,
        END_NT	        10 UINTEGER 1,
        SEC_NF	        12 UINTEGER 1,
        UWY_NF          14 INT 2,
        UW_NT           16 UINTEGER 1,
        ACY_NF          17 INT 2,
        SSD_CF          19 UINTEGER 1,
        BALSHEY_NF      21 INT 2,
        BALSHTMTH_NF    23 UINTEGER 1,
        AUTUPD_B        24 UINTEGER 1,
        COMACC_B        25 UINTEGER 1,
        PROPAG_RES_B	  26 UINTEGER 1,
        CRE_D	          28 CHAR 17
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      CRE_D DESCENDING
exit
EOF
SORT
#S2L fin

#[001]
NSTEP=${NJOB}_191A
# Sort CPLIFDRI_N binary file
#[007] changement dans le tri pour pointer sur les bons champs
#------------------------------------------------------------------------------
LIBEL="Sort of CPLIFDRI binary file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_190B_${IB}_ESTC2050_LIFDRI_O1${IT}.dat fixed 112"
SORT_O=${EST_CPLIFDRIN}
INPUT_TEXT $SORT_CMD << EOF
/FIELDS CTR_NF           1 CHAR 10,
        END_NT	        10 UINTEGER 1,
        SEC_NF	        12 UINTEGER 1,
        UWY_NF          14 INT 2,
        UW_NT           16 UINTEGER 1,
        ACY_NF          17 INT 2,
        SSD_CF          19 UINTEGER 1,
        BALSHEY_NF      21 INT 2,
        BALSHTMTH_NF    23 UINTEGER 1,
        AUTUPD_B        24 UINTEGER 1,
        COMACC_B        25 UINTEGER 1,
        PROPAG_RES_B	  26 UINTEGER 1,
        CRE_D	          28 CHAR 17
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      CRE_D DESCENDING
exit
EOF
SORT
#S2L fin

NSTEP=${NJOB}_191_A
# Tri du fichier LIFEST de sortie du traitement ESTC2038
# selon les dates
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`

SORT_I="${DFILT}/${NJOB}_110_${IB}_ESTC2038_LIFEST_O2${IT}.dat  1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_LIFEST_O2${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       2:1 -  2:,
        SEC_NF       4:1 -  4:,
        UWY_NF       5:1 -  5:,
        ACY_NF       7:1 -  7:,
        ACM_NF      25:1 - 25:EN,
        CRE_D        8:1 -  8:,
        ACMTRS_NT   10:1 - 10:,
        DETTRNCOD_CF    20:1 - 20:,
        GAAP_NF         22:1 - 22:,
        BALSHEY_NF  11:1 - 11:,
        BALSHMTH_NF 12:1 - 12:EN
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACM_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF,
      BALSHEY_NF,
      BALSHMTH_NF,
      CRE_D
exit
EOF
SORT

#------------------------------------------------------------------------------

#------------------------------------------------------------------------------

NSTEP=${NJOB}_191_B
## récupèration de la dernière version du LIFEST 
## n'ayant pas subi de modification de montant
##------------------------------------------------------------------------------
LIBEL="récupèration de la dernière version du LIFEST n'ayant pas subi de modification de montant"
PRG=ESTC2043
export ${PRG}_I1=${DFILT}/${NJOB}_191_A_${IB}_LIFEST_O2${IT}.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LAST_LIFEST_O2${IT}.dat
EXECPRG

gzip -c ${DFILT}/${NJOB}_190B_${IB}_ESTC2050_LIFDRI_O1${IT}.dat > ${DFILT}/${NJOB}_190B_ESTC2050_LIFDRI_O1.dat_${IT}.gz

NSTEP=${NJOB}_192
# Tri du fichier LIFEST de sortie du traitement ESTC2038
# selon les dates decroissantes
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`

SORT_I="${DFILT}/${NJOB}_191_B_${IB}_ESTC2043_LAST_LIFEST_O2${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_LIFEST_O3${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       2:1 -  2:,
        SEC_NF       4:1 -  4:,
        UWY_NF       5:1 -  5:,
        ACY_NF       7:1 -  7:,
        ACM_NF       25:1 - 25:EN,
        CRE_D        8:1 -  8:,
        ACMTRS_NT   10:1 - 10:,
        DETTRNCOD_CF    20:1 - 20:,
        GAAP_NF         22:1 - 22:,
        BALSHEY_NF  11:1 - 11:,
        BALSHMTH_NF 12:1 - 12:EN
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACM_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF,
      BALSHEY_NF DESCENDING,
      BALSHMTH_NF DESCENDING,
      CRE_D DESCENDING
exit
EOF
SORT
#------------------------------------------------------------------------------

NSTEP=${NJOB}_193
# Traitement 2038 sur le fichier LIFEST_03
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Screen"
PRG=ESTC2040
export ${PRG}_I1=$DFILT/${NJOB}_192_${IB}_LIFEST_O3${IT}.dat
export ${PRG}_O1=$DFILT/${NSTEP}_${IB}_${PRG}_LAST_LIFEST_O4${IT}.dat
export ${PRG}_O2=$DFILT/${NSTEP}_${IB}_${PRG}_OLD_LIFEST_O4${IT}.dat
EXECPRG
#------------------------------------------------------------------------------


NSTEP=${NJOB}_193Bis
# Merging Annual Estimates for Sybase Insertion
#------------------------------------------------------------------------------
LIBEL="Merging Annual Estimates for Sybase Insertion"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_193_${IB}_ESTC2040_OLD_LIFEST_O4${IT}.dat 1000 1"
SORT_O="${EST_CPLIFEST_INTERM} 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        SSD_CF           1:1 -  1: EN,
        CTR_NF           2:1 -  2:,
        END_NT           3:1 -  3:,
        SEC_NF           4:1 -  4:,
        UWY_NF           5:1 -  5:,
        UW_NT            6:1 -  6:,
        ACY_NF           7:1 -  7:,
        CRE_D            8:1 -  8:,
        PRS_CF           9:1 -  9:,
        ACMTRS_NT       10:1 - 10:,
        BALSHEY_NF      11:1 - 11:,
        BALSHTMTH_NF    12:1 - 12:EN,
        CUR_CF          13:1 - 13:,
        ESTMNT_M        14:1 - 14:EN 15/3,
        INDSUP_B        15:1 - 15:,
        ORICOD_LS       16:1 - 16:,
        CREUSR_CF       17:1 - 17:,
        LSTUPD_D        18:1 - 18:,
        LSTUPDUSR_CF    19:1 - 19:,
        DETTRNCOD_CF	20:1 - 20:,
        GAAP_NF         22:1 - 22:,
        GAAPDIFF_M      23:1 - 23:EN 15/3,
        PROPAGATION_B   24:1 - 24:,
        ESTMTH_NF       25:1 - 25:,
        ORICTR_NF       26:1 - 26:,
        ORISEC_NF       27:1 - 27:,
        ORIUWY_NF       28:1 - 28:,
        BATCH_B         52:1 - 52:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CRE_D, BALSHEY_NF, BALSHTMTH_NF,
      ACY_NF, ESTMTH_NF, ACMTRS_NT, DETTRNCOD_CF, GAAP_NF
/SUM TOTAL ESTMNT_M
/DERIVEDFIELD CALCULATED_B "0~"
/OUTFILE ${SORT_O}
/REFORMAT 
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          CRE_D,
          BALSHEY_NF,
          BALSHTMTH_NF,
          ACY_NF,
          GAAP_NF,
          DETTRNCOD_CF,
          ESTMTH_NF,
          PRS_CF,
          ACMTRS_NT,
          SSD_CF,
          CUR_CF,
          ESTMNT_M,
          INDSUP_B,
          ORICOD_LS,
          CREUSR_CF,
          LSTUPD_D,
          LSTUPDUSR_CF,
          ORICTR_NF,
          ORISEC_NF,
          ORIUWY_NF,
          GAAPDIFF_M,
          PROPAGATION_B,
          CALCULATED_B,
          BATCH_B  
exit
EOF
SORT


NSTEP=${NJOB}_194
# Tri du fichier ESTC2040_LAST_LIFEST_O4
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_193_${IB}_ESTC2040_LAST_LIFEST_O4${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_LAST_LIFEST_O4_TRIE${IT}.dat"
SORT_O2="${DFILT}/${NSTEP}_${IB}_OLD_LIFEST_O4${IT}.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF         1:1 -  1: EN,
        CTR_NF         2:1 -  2:,
        SEC_NF         4:1 -  4:,
        UWY_NF         5:1 -  5:,
        ACY_NF         7:1 -  7:,
        ACM_NF        25:1 - 25:EN,
        CRE_D2         8:1 -  8:14,
        ACMTRS_NT     10:1 - 10:,
        DETTRNCOD_CF  20:1 - 20:,
        GAAP_NF       22:1 - 22:,
        BATCH_B       52:1 - 52:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACM_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF
/CONDITION NEWLIGNE  ( ( CRE_D2 = "${CRE_D} 23:59" ) AND BATCH_B = "1" ) 
/OUTFILE  ${SORT_O}
/INCLUDE NEWLIGNE
/OUTFILE  ${SORT_O2}
/OMIT NEWLIGNE

exit
EOF
SORT
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
NSTEP=${NJOB}_194A

#NSTEP=${NJOB}_194A
# Tri du fichier reserve
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_190_2_${IB}_RESERVE_03${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_RESERVE_TRIE_01${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF       1:1 -  1: EN,
        CTR_NF       2:1 -  2:,
        SEC_NF       4:1 -  4:,
        UWY_NF       5:1 -  5:,
        ACY_NF       7:1 -  7:,
        ACM_NF      25:1 - 25:EN,
        ACMTRS_NT   10:1 - 10:,
        ESTMNT_M    14:1 - 14:EN,
        DETTRNCOD_CF    20:1 - 20:,
        GAAP_NF         22:1 - 22:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACM_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF
/SUMMARIZE TOTAL ESTMNT_M      
/OUTFILE  ${SORT_O}
exit
EOF
SORT
#------------------------------------------------------------------------------

NSTEP=${NJOB}_195
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
#RMFIL ${DFILT}/${NJOB}_75_${IB}_ESTC2035_LIFDRI_O1${IT}.dat
RMFIL ${DFILT}/${NJOB}_180_${IB}_ESTC2040_LAST_LIFEST_O1${IT}.dat
#S2L
#RMFIL ${DFILT}/${NJOB}_110_${IB}_ESTC2038_LIFDRI_O1.dat

NSTEP=${NJOB}_196
# Annual Estimates Sort
#------------------------------------------------------------------------------
# Appel ESTC2044 pour fusion entre LIFEST et RESERVE du ESTC2038
#------------------------------------------------------------------------------
LIBEL="Taking into Account Annual Estimates Statistical Expiries"
PRG=ESTC2044
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CRE_D ${CRE_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_194A_${IB}_RESERVE_TRIE_01${IT}.dat
export ${PRG}_I2=${DFILT}/${NJOB}_194_${IB}_LAST_LIFEST_O4_TRIE${IT}.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_RESERVE_O2${IT}.dat
EXECPRG
#------------------------------------------------------------------------------

gzip -c ${DFILT}/${NJOB}_194A_${IB}_RESERVE_TRIE_01${IT}.dat > ${DFILT}/${NJOB}_194A_RESERVE_TRIE_01${IT}.dat
gzip -c ${DFILT}/${NJOB}_194_${IB}_LAST_LIFEST_O4_TRIE${IT}.dat > ${DFILT}/${NJOB}_194_LAST_LIFEST_O4_TRIE${IT}.dat
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_RESERVE_O2${IT}.dat > ${DFILT}/${NSTEP}_${PRG}_RESERVE_O2${IT}.dat

NSTEP=${NJOB}_197
# Merge du fichier RESERVE_O2 et du fichier LAST_LIFEST_O4_TRIE
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_196_${IB}_ESTC2044_RESERVE_O2${IT}.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_194_${IB}_LAST_LIFEST_O4_TRIE${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ALL_LIFEST_O1${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       2:1 -  2:,
        SEC_NF       4:1 -  4:,
        UWY_NF       5:1 -  5:,
        ACY_NF       7:1 -  7:,
        ACM_NF      25:1 - 25:EN,
        CRE_D        8:1 -  8:,
        ACMTRS_NT   10:1 - 10:,
        DETTRNCOD_CF    20:1 - 20:,
        GAAP_NF         22:1 - 22:,
        BALSHEY_NF  11:1 - 11:,
        BALSHMTH_NF 12:1 - 12:EN
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACM_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF,
      BALSHEY_NF DESCENDING,
      BALSHMTH_NF DESCENDING,
      CRE_D DESCENDING
/OUTFILE  ${SORT_O}
exit
EOF
SORT
#------------------------------------------------------------------------------

NSTEP=${NJOB}_198
# Traitement 2040 sur le fichier ALL_LIFEST_O1
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Screen"
PRG=ESTC2040
export ${PRG}_I1=$DFILT/${NJOB}_197_${IB}_ALL_LIFEST_O1${IT}.dat
export ${PRG}_O1=$DFILT/${NSTEP}_${IB}_${PRG}_LAST_ALL_LIFEST_O1${IT}.dat
export ${PRG}_O2=$DFILT/${NSTEP}_${IB}_${PRG}_OLD_ALL_LIFEST_O1${IT}.dat
EXECPRG
#------------------------------------------------------------------------------


NSTEP=${NJOB}_199
# Tri du fichier reserve NOACC
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_135_${IB}_ESTC2053_RESERVE_NOACC_02${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_RESERVE_NOACC_TRIE_01${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF       1:1 -  1: EN,
        CTR_NF       2:1 -  2:,
        SEC_NF       4:1 -  4:,
        UWY_NF       5:1 -  5:,
        ACY_NF       7:1 -  7:,
        ACM_NF      25:1 - 25:EN,
        CRE_D        8:1 -  8:,
        ACMTRS_NT   10:1 - 10:,
        ESTMNT_M    14:1 - 14:EN,
        DETTRNCOD_CF    20:1 - 20:,
        GAAP_NF         22:1 - 22:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACM_NF,
      CRE_D,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF
/SUMMARIZE TOTAL ESTMNT_M      
/OUTFILE  ${SORT_O}
exit
EOF
SORT
#------------------------------------------------------------------------------

cp ${EST_LIFESTNOACC} ${DFILT}/${NSTEP}_LIFEST_NOACC_199${IT}.dat

NSTEP=${NJOB}_200
# Annual Estimates Sort
#------------------------------------------------------------------------------
# Appel ESTC2044 pour fusion entre LIFESTNOACC et RESERVE_NOACC du ESTC2038
#------------------------------------------------------------------------------
LIBEL="Taking into Account Annual Estimates Statistical Expiries"
PRG=ESTC2044
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CRE_D ${CRE_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_199_${IB}_RESERVE_NOACC_TRIE_01${IT}.dat
export ${PRG}_I2=${EST_LIFESTNOACC}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_ALL_LIFEST_NOACC_O1${IT}.dat
EXECPRG
#------------------------------------------------------------------------------
#fusion EST_LIFESTNOACC + O1
cp ${EST_LIFESTNOACC} $DFILT/LIFEST_NOACC_200${IT}.dat

NSTEP=${NJOB}_200Bis
# Annual Estimates Sort
# [006]
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# STEP pour test. Comme le fichier RESERVE_NOACC est vide (Traitement désactivé dans ESTC2038)
# on recopie le fichier EST_LIFESTNOACC dans ${DFILT}/${NSTEP}_${IB}_${PRG}_ALL_LIFEST_NOACC_O1${IT}.dat
# pour reprendre la suite du traitement normalement
if [ ! -s ${DFILT}/${NJOB}_199_${IB}_RESERVE_NOACC_TRIE_01${IT}.dat ]
then
  echo "le fichier ${DFILT}/${NJOB}_199_${IB}_RESERVE_NOACC_TRIE_01${IT}.dat est absent ou vide:"
  wc ${DFILT}/${NJOB}_199_${IB}_RESERVE_NOACC_TRIE_01${IT}.dat
  echo "Recopie du fichier EST_LIFESTNOACC dans ${DFILT}/${NSTEP}_${IB}_${PRG}_ALL_LIFEST_NOACC_O1${IT}.dat pour reprendre la suite du traitement normalement"
  cp -v ${EST_LIFESTNOACC} ${DFILT}/${NJOB}_200_${IB}_ESTC2044_ALL_LIFEST_NOACC_O1${IT}.dat
fi


NSTEP=${NJOB}_201
# Traitement 2040 sur le fichier ESTC2044_ALL_LIFEST_NOACC_O1.dat
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Screen"
PRG=ESTC2040
export ${PRG}_I1=$DFILT/${NJOB}_200_${IB}_ESTC2044_ALL_LIFEST_NOACC_O1${IT}.dat
export ${PRG}_O1=${EST_LIFESTNOACC}
export ${PRG}_O2=$DFILT/${NSTEP}_${IB}_${PRG}_OLD_ALL_LIFEST_NOACC_O1${IT}.dat

EXECPRG
#
#------------------------------------------------------------------------------
cp ${EST_LIFESTNOACC} $DFILT/LIFEST_NOACC_201${IT}.dat

NSTEP=${NJOB}_204
# Merge des fichiers LIFEST et LIFEST_NOACC
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_198_${IB}_ESTC2040_LAST_ALL_LIFEST_O1${IT}.dat 1000 1"
SORT_I2=${EST_LIFESTNOACC}
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       2:1 -  2:,
        SEC_NF       4:1 -  4:,
        UWY_NF       5:1 -  5:,
        ACY_NF       7:1 -  7:,
        ACM_NF      25:1 - 25:EN,
        CRE_D        8:1 -  8:,
        ACMTRS_NT   10:1 - 10:,
        DETTRNCOD_CF    20:1 - 20:,
        GAAP_NF         22:1 - 22:,
        BALSHEY_NF  11:1 - 11:,
        BALSHMTH_NF 12:1 - 12:EN
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACM_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF,
      BALSHEY_NF DESCENDING,
      BALSHMTH_NF DESCENDING,
      CRE_D DESCENDING
exit
EOF
SORT

NSTEP=${NJOB}_205
## Annual Estimates Screen
##------------------------------------------------------------------------------
#LIBEL="Annual Estimates Screen"
PRG=ESTC2040
export ${PRG}_I1=${DFILT}/${NJOB}_204_${IB}_SORT_LIFEST_O${IT}.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LAST_LIFEST_O1${IT}.dat
#export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_OLD_LIFEST_O2${IT}.dat
export ${PRG}_O2=${EST_205_ESTC2040_OLD_LIFEST_O2}
EXECPRG

NSTEP=${NJOB}_206
# ------------------------------------
#gzip -c ${DFILT}/${NJOB}_200_${IB}_SORT_LIFEST_O${IT}.dat           > ${DFILT}/${NJOB}_200_SORT_LIFEST_O_${IT}.dat.gz
#gzip -c ${DFILT}/${NJOB}_205_${IB}_ESTC2040_LAST_LIFEST_O1${IT}.dat > ${DFILT}/${NJOB}_205_ESTC2040_LAST_LIFEST_O1_${IT}.dat.gz
#gzip -c ${DFILT}/${NJOB}_205_${IB}_ESTC2040_OLD_LIFEST_O2${IT}.dat  > ${DFILT}/${NJOB}_205_ESTC2040_OLD_LIFEST_O2_${IT}.dat.gz
gzip -c ${DFILT}/${NJOB}_110_${IB}_ESTC2038_LIFEST_O2${IT}.dat           > ${DFILT}/${NJOB}_190_ESTC2038_LIFEST_O2_${IT}.dat.gz
gzip -c ${DFILT}/${NJOB}_192_${IB}_LIFEST_O3${IT}.dat                    > ${DFILT}/${NJOB}_192_LIFEST_O3_${IT}.dat.gz
gzip -c ${DFILT}/${NJOB}_193_${IB}_ESTC2040_LAST_LIFEST_O4${IT}.dat      > ${DFILT}/${NJOB}_193_ESTC2040_LAST_LIFEST_O4_${IT}.dat.gz
gzip -c ${DFILT}/${NJOB}_110_${IB}_ESTC2038_RESERVE_01${IT}.dat          > ${DFILT}/${NJOB}_190_ESTC2038_RESERVE_01_${IT}.dat.gz
#gzip -c ${DFILT}/${NJOB}_194A_${IB}_RESERVE_TRIE_01${IT}.dat             > ${DFILT}/${NJOB}_194A_RESERVE_TRIE_01_${IT}.dat.gz
gzip -c ${DFILT}/${NJOB}_194_${IB}_LAST_LIFEST_O4_TRIE${IT}.dat          > ${DFILT}/${NJOB}_194_LAST_LIFEST_O4_TRIE_${IT}.dat.gz
#gzip -c ${DFILT}/${NJOB}_196_${IB}_ESTC2044_RESERVE_O2${IT}.dat          > ${DFILT}/${NJOB}_196_ESTC2044_RESERVE_O2_${IT}.dat.gz
gzip -c ${DFILT}/${NJOB}_194_${IB}_LAST_LIFEST_O4_TRIE${IT}.dat          > ${DFILT}/${NJOB}_194_LAST_LIFEST_O4_TRIE_${IT}.dat.gz
#gzip -c ${DFILT}/${NJOB}_197_${IB}_ALL_LIFEST_O1${IT}.dat                > ${DFILT}/${NJOB}_197_ALL_LIFEST_O1_${IT}.dat.gz
gzip -c ${DFILT}/${NJOB}_110_${IB}_ESTC2038_RESERVE_NOACC_01${IT}.dat    > ${DFILT}/${NJOB}_190_ESTC2038_RESERVE_NOACC_01_${IT}.dat.gz
#gzip -c ${DFILT}/${NJOB}_199_${IB}_RESERVE_NOACC_TRIE_01${IT}.dat        > ${DFILT}/${NJOB}_199_RESERVE_NOACC_TRIE_01_${IT}.dat.gz
#gzip -c ${DFILT}/${NJOB}_200_${IB}_ESTC2044_ALL_LIFEST_NOACC_O1${IT}.dat > ${DFILT}/${NJOB}_200_ESTC2044_ALL_LIFEST_NOACC_O1_${IT}.dat.gz
#gzip -c ${DFILT}/${NJOB}_198_${IB}_ESTC2040_LAST_ALL_LIFEST_O1${IT}.dat  > ${DFILT}/${NJOB}_198_ESTC2040_LAST_ALL_LIFEST_O1_${IT}.dat.gz
#gzip -c ${DFILT}/${NJOB}_204_${IB}_SORT_LIFEST_O${IT}.dat                > ${DFILT}/${NJOB}_204_SORT_LIFEST_O_${IT}.dat.gz
# ----------------------------------------

NSTEP=${NJOB}_207
# Annual Estimates Screen
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Screen"
PRG=ESTC2046
export ${PRG}_I1=${DFILT}/${NJOB}_194_${IB}_LAST_LIFEST_O4_TRIE${IT}.dat
export ${PRG}_I2=${EST_SUBTRSESBPROP}
export ${PRG}_I3=${EST_SUBTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST_02${IT}.dat 
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_FLIFEST0_02_ERR.log
EXECPRG



NSTEP=${NJOB}_208
# Merge des fichiers LIFEST AVANT ET APRES
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_194_${IB}_OLD_LIFEST_O4${IT}.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_207_${IB}_ESTC2046_LIFEST_02${IT}.dat 1000 1"
SORT_O="${EST_VLIFEST195}"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       2:1 -  2:,
        SEC_NF       4:1 -  4:,
        UWY_NF       5:1 -  5:,
        ACY_NF       7:1 -  7:,
        ACM_NF      25:1 - 25:EN,
        CRE_D        8:1 -  8:,
        ACMTRS_NT   10:1 - 10:,
        DETTRNCOD_CF    20:1 - 20:,
        GAAP_NF         22:1 - 22:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACM_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF
exit
EOF
SORT


NSTEP=${NJOB}_235
#------------------------------------------------------------------------------ 
gzip -c  ${EST_VLIFEST195}  > ${DFILT}/${NJOB}_235_VLIFEST_O_${IT}.dat.gz
gzip -c  ${EST_LIFESTNOACC} > ${DFILT}/${NJOB}_235_LIFESTNOACC_${IT}.dat.gz


NSTEP=${NJOB}_240
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"

# Job End
JOBEND
