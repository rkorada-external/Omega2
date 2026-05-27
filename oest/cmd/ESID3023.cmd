#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATION LOT 21
# nom du script SHELL           : ESID2031.cmd
# revision                      : 
# date de creation              : 
# auteur                        : 
# references des specifications :
#-----------------------------------------------------------------------------
# description :
# Création VLIFEST
#
# job launched by ESID2030.cmd
#-----------------------------------------------------------------------------
# historique des modifications :
#[001] 13/11/2015 M.MECHRI  :spot:296650:Pool retro
#[002] 10/05/2016 R.BEN EZZINE  :spot: : Optimisation ESID2030
#[003] 18/09/2017 SBE  spira:61671: Omega to SAP June simulation. Creation des postes prefixe 1 sur des sections Vie
#[004] 13/02/2019 Raf  REQ.L.02.05: Evolution quarterly 
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Get input parameters
CLODAT_D=$1
CRE_D=$2

# Job Initialisation
JOBINIT


NSTEP=${NJOB}_74
# Merging and Filtering of life A+R perimeter
#------------------------------------------------------------------------------
LIBEL="Merging and Filtering of life A+R perimeter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FLIFEST0}
SORT_O="${DFILT}/${NSTEP}_${IB}_FLIFEST${IT}0_01.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF        2:1 -  2:,
        SEC_NF        4:1 -  4:,
        UWY_NF        5:1 -  5:,
        ACY_NF        7:1 -  7:,
        ACMTRS_NT     10:1 - 10:,
        DETTRNCOD_CF  20:1 - 20:,
        GAAP_NF       22:1 - 22:,
		ACM_NF			25:1 - 25:EN
/KEYS 
      CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF,
	ACM_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_75
#[001]
# Annual Estimates Actualization
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Actualization"
PRG=ESTC2035
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
CRE_D ${CRE_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_74_${IB}_FLIFEST${IT}0_01.dat
export ${PRG}_I2=${EST_IARVPERICASE4}
export ${PRG}_I3=${EST_FLIFDRI}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_SUBTRS}
export ${PRG}_O1=${EST_ESTC2035_LIFDRI_O1}
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_ACCOUNT_LIFEST${IT}_O2.dat
export ${PRG}_O3=${EST_CRIBLEANO}
export ${PRG}_O4=${EST_LIFESTNOACC}
export ${PRG}_O5=${EST_LIFENDCPT}
export ${PRG}_O6=${DFILT}/${NSTEP}_${IB}_${PRG}_NON_CRIBLE${IT}_O6.dat
export ${PRG}_O7=${DFILT}/${NSTEP}_${IB}_${PRG}_NON_SYNCHRO${IT}_O7.dat
export ${PRG}_O8=${EST_LIFESTANA}
export ${PRG}_O9=${EST_LIFESTLIB}
export ${PRG}_O10=${EST_ERRUPDBATCH}
EXECPRG


NSTEP=${NJOB}_76
# Step Reconduction du LIFDRI_ALL
#------------------------------------------------------------------------------
LIBEL="move ${EST_FLIFDRI} ${EST_ESTC2035_LIFDRI_O1}"
EXECKSH "cp ${EST_FLIFDRI} ${EST_ESTC2035_LIFDRI_O1}"

# ------------------------------------
gzip -c ${EST_ESTC2035_LIFDRI_O1}                               > ${DFILT}/${NJOB}_075_ESTC2035_LIFDRI${IT}_O1.dat.gz
gzip -c ${DFILT}/${NJOB}_75_${IB}_${PRG}_ACCOUNT_LIFEST${IT}_O2.dat  > ${DFILT}/${NJOB}_075_ESTC2035_ACCOUNT_LIFEST${IT}_O2.dat.gz
gzip -c ${EST_LIFENDCPT}                                        > ${DFILT}/${NJOB}_075_ESTC2035_END_LIFEST${IT}_O5.dat.gz
gzip -c ${DFILT}/${NJOB}_75_${IB}_${PRG}_NON_CRIBLE${IT}_O6.dat      > ${DFILT}/${NJOB}_075_ESTC2035_NON_CRIBLE${IT}_O6.dat.gz
gzip -c ${DFILT}/${NJOB}_75_${IB}_${PRG}_NON_SYNCHRO${IT}_O7.dat     > ${DFILT}/${NJOB}_075_ESTC2035_NON_SYNCHRO_O7${IT}.dat.gz
# ------------------------------------


NSTEP=${NJOB}_80
#Sort of life A+R perimeter
#------------------------------------------------------------------------------
LIBEL="Sort of life A+R perimeter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IARVPERICASE4} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IARVPERICASE4${IT}_O.dat 1000 1"
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

NSTEP=${NJOB}_90
#Sort of life A+R perimeter
#------------------------------------------------------------------------------
LIBEL="Sort of life A+R perimeter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75_${IB}_ESTC2035_ACCOUNT_LIFEST${IT}_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ACCOUNT_LIFEST${IT}_O2.dat 1000 1"
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


NSTEP=${NJOB}_100
# Loader programs V2
#-----------------------------------------------------------------------------
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="test"
PRG=ESTC2052
export ${PRG}_I1=${DFILT}/${NJOB}_80_${IB}_SORT_IARVPERICASE4${IT}_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_90_${IB}_SORT_ACCOUNT_LIFEST${IT}_O2.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_ACCOUNT_LIFEST${IT}_O2.dat
EXECPRG


NSTEP=${NJOB}_150
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_75_${IB}_ESTC2035_NON_CRIBLE${IT}_O6.dat
RMFIL ${DFILT}/${NJOB}_75_${IB}_ESTC2035_NON_SYNCHRO${IT}_O7.dat


NSTEP=${NJOB}_170
# Annual Estimates Sort
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100_${IB}_ESTC2052_ACCOUNT_LIFEST${IT}_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST${IT}_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF       2:1 -  2:,
        SEC_NF       4:1 -  4:,
        UWY_NF       5:1 -  5:,
        ACY_NF       7:1 -  7:,
        CRE_D        8:1 -  8:,
        ACMTRS_NT    10:1 - 10:,
        DETTRNCOD_CF 20:1 - 20:,
        GAAP_NF			 22:1 - 22:,
        BALSHEY_NF   11:1 - 11:,
        BALSHMTH_NF  12:1 - 12:EN,
        ESTMNT_M     14:1 - 14:EN,
		ACM_NF		25:1 - 25:EN
/KEYS
      CTR_NF,
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
/SUM TOTAL ESTMNT_M
/OUTFILE  ${SORT_O}
exit
EOF
SORT


#NSTEP=${NJOB}_177
## Annual Estimates Screen
##------------------------------------------------------------------------------
#LIBEL="Annual Estimates Screen"
#PRG=ESTC2046
#export ${PRG}_I1=${EST_LIFESTNOACC}
#export ${PRG}_I2=${EST_SUBTRSESBPROP}
#export ${PRG}_I3=${EST_SUBTRS}
#export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FLIFEST${IT}0_NOACC_03.dat
#export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_FLIFEST0_03_NOACC${IT}_ERR.log
#EXECPRG


#NSTEP=${NJOB}_178
## Remove EST_LIFESTNOACC
##------------------------------------------------------------------------------
#LIBEL="move ${DFILT}/${NJOB}_177_${IB}_ESTC2046_FLIFEST0_NOACC_03.dat ${EST_LIFESTNOACC}"
#EXECKSH "mv ${DFILT}/${NJOB}_177_${IB}_ESTC2046_FLIFEST0_NOACC_03.dat ${EST_LIFESTNOACC}"


NSTEP=${NJOB}_180
# Annual Estimates Screen
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Screen"
PRG=ESTC2040
export ${PRG}_I1=${DFILT}/${NJOB}_170_${IB}_SORT_LIFEST${IT}_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST${IT}_O.dat
export ${PRG}_O2=${EST_180_ESTC2040_OLD_LIFEST_O2}
EXECPRG

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_170_${IB}_SORT_LIFEST${IT}_O.dat        > ${DFILT}/${NJOB}_170_SORT_LIFEST${IT}_O.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_ESTC2040_LIFEST${IT}_O.dat       > ${DFILT}/${NSTEP}_ESTC2040_LIFEST${IT}_O.dat.gz
gzip -c ${EST_180_ESTC2040_OLD_LIFEST_O2}                   > ${DFILT}/${NSTEP}_ESTC2040_OLD_LIFEST${IT}_O2.dat.gz
# ------------------------------------

NSTEP=${NJOB}_183
# Annual Estimates Screen
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Screen"
PRG=ESTC2046
export ${PRG}_I1=${DFILT}/${NJOB}_180_${IB}_ESTC2040_LIFEST${IT}_O.dat
export ${PRG}_I2=${EST_SUBTRSESBPROP}
export ${PRG}_I3=${EST_SUBTRS}
export ${PRG}_O1=${EST_VLIFEST2070}
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_FLIFEST${IT}0_03_ERR.log
EXECPRG

# ------------------------------------
gzip -c ${EST_VLIFEST2070} > ${DFILT}/${NJOB}_183_ESTC2046_VLIFEST2070${IT}.dat.gz
# ------------------------------------

NSTEP=${NJOB}_185
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"

# Job End
JOBEND
