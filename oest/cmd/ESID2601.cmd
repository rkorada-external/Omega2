#!/bin/ksh
#=============================================================================
# nom de l'application		: INVENTAIRE
#                                 Retour des resultats de l'inventaire pour
#				 l'actuariat
#				  bilan en cours
# nom du script SHELL		: ESID2601.cmd
# revision			: $Revision:   1.4  $
# date de creation		: 27/05/98
# auteur			: C.G.I. (M.HA-THUC)
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   	Sending of Closing period process results to actuary
#
# Job launched by ESID2600.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd


# Job Initialisation
JOBINIT

# Get Input parameter


NSTEP=${NJOB}_05
# Accounting transaction code transformation, ... for the TOTGTAA
# Warning - The TOTGTAA must be sorted on CTR_NF, END_NT, SEC_NF
#-----------------------------------------------------------------------------
LIBEL="Accounting transaction code transformation, ... for the TOTGTAA"
PRG=ESTC1600
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
PRS_CF 717
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_TOTGTAA}
export ${PRG}_I2=${EST_FCTRGRO}
export ${PRG}_I3=${EST_FCURQUOT}
export ${PRG}_I4=${EST_FTRSLNK}
export ${PRG}_I5=${EST_FSEGMENT}
export ${PRG}_I6=${EST_FCPLACC}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_ACCMVT_O.dat
EXECPRG

NSTEP=${NJOB}_10
# Accumulation amount by SSD_CF, SEG_NF, UWY_NF, CUR_CF, ACMTRS_NT
#-----------------------------------------------------------------------------
LIBEL="Accumulation amount by SSD_CF, SEG_NF, UWY_NF, CUR_CF, ACMTRS_NT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_05_${IB}_ESTC1600_ACCMVT_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_ACCMVT_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        SEG_NF 2:1 - 2:,
        UWY_NF 3:1 - 3:,
        CUR_CF 4:1 - 4:,
        ACMTRS_NT 5:1 - 5:,
        AMTSTAT_M 7:1 - 7: EN 30/3,
        AMTBIL_M 8:1 - 8: EN 30/3
/KEYS SSD_CF,
      SEG_NF,
      UWY_NF,
      CUR_CF,
      ACMTRS_NT
/SUMMARIZE TOTAL AMTSTAT_M,
           TOTAL AMTBIL_M
exit
EOF
SORT

NSTEP=${NJOB}_15
# Temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_05_${IB}_ESTC1600_ACCMVT_O.dat

NSTEP=${NJOB}_20
# Preparation of the outfile
#-----------------------------------------------------------------------------
LIBEL="Preparation of the outfile"
PRG=ESTC1601
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_ACCMVT_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FSEGACTACC_O.dat
EXECPRG

NSTEP=${NJOB}_25
# Temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_ACCMVT_O.dat

NSTEP=${NJOB}_30
# Accounting transaction code transformation, ... for the TOTGTAR
# Warning - The TOTGTAR must be sorted on CTR_NF, END_NT, SEC_NF
#-----------------------------------------------------------------------------
LIBEL="Accounting transaction code transformation, ... for the TOTGTAR"
PRG=ESTC1600
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
PRS_CF 714
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_TOTGTAR}
export ${PRG}_I2=${EST_FCTRGRO}
export ${PRG}_I3=${EST_FCURQUOT}
export ${PRG}_I4=${EST_FTRSLNK}
export ${PRG}_I5=${EST_FSEGMENT}
export ${PRG}_I6=${EST_FCPLACC}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_ACCMVT_O.dat
EXECPRG

NSTEP=${NJOB}_35
# Accumulation amount by SSD_CF, SEG_NF, UWY_NF, CUR_CF, ACMTRS_NT
#-----------------------------------------------------------------------------
LIBEL="Accumulation amount by SSD_CF, SEG_NF, UWY_NF, CUR_CF, ACMTRS_NT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_30_${IB}_ESTC1600_ACCMVT_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_ACCMVT_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        SEG_NF 2:1 - 2:,
        UWY_NF 3:1 - 3:,
        CUR_CF 4:1 - 4:,
        ACMTRS_NT 5:1 - 5:,
        AMTSTAT_M 7:1 - 7: EN 30/3,
        AMTBIL_M 8:1 - 8: EN 30/3
/KEYS SSD_CF,
      SEG_NF,
      UWY_NF,
      CUR_CF,
      ACMTRS_NT
/SUMMARIZE TOTAL AMTSTAT_M,
           TOTAL AMTBIL_M
exit
EOF
SORT

NSTEP=${NJOB}_40
# Temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_30_${IB}_ESTC1600_ACCMVT_O.dat

NSTEP=${NJOB}_45
# Preparation of the outfile
#-----------------------------------------------------------------------------
LIBEL="Generation of FSEGACTRET"
PRG=ESTC1601
export ${PRG}_I1=${DFILT}/${NJOB}_35_${IB}_SORT_ACCMVT_O.dat
export ${PRG}_O1=${DIBNR}/${NCHAIN}_FSEGACTRET.dat
EXECPRG

NSTEP=${NJOB}_50
# Temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_35_${IB}_SORT_ACCMVT_O.dat

NSTEP=${NJOB}_55
# Merge of FSEGACTACC files
#-----------------------------------------------------------------------------
LIBEL="Generation of the complete FSEGACTACC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FSEGACTBILANT} 1000 1"
SORT_I2="${DFILT}/${NJOB}_20_${IB}_ESTC1601_FSEGACTACC_O.dat 1000 1"
SORT_O="${DIBNR}/${NCHAIN}_FSEGACTACC.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        SEG_NF 2:1 - 2:,
        UWY_NF 3:1 - 3:,
        CUR_CF 4:1 - 4:,
        VRS_NF 5:1 - 5:,
        AMTSTAT1_M 6:1 - 6:EN 30/3,
        AMTSTAT2_M 7:1 - 7:EN 30/3,
        AMTSTAT3_M 8:1 - 8:EN 30/3,
        AMTSTAT4_M 9:1 - 9:EN 30/3,
        AMTSTAT5_M 10:1 - 10:EN 30/3,
        AMTSTAT6_M 11:1 - 11:EN 30/3,
        AMTSTAT7_M 12:1 - 12:EN 30/3,
        AMTSTAT8_M 13:1 - 13:EN 30/3,
        AMTSTAT9_M 14:1 - 14:EN 30/3,
        AMTSTAT10_M 15:1 - 15:EN 30/3,
        AMTSTAT11_M 16:1 - 16:EN 30/3,
        AMTSTAT12_M 17:1 - 17:EN 30/3,
        AMTSTAT13_M 18:1 - 18:EN 30/3,
        AMTBIL1_M 19:1 - 19:EN 30/3,
        AMTBIL2_M 20:1 - 20:EN 30/3,
        AMTBIL3_M 21:1 - 21:EN 30/3,
        AMTBIL4_M 22:1 - 22:EN 30/3,
        AMTBIL5_M 23:1 - 23:EN 30/3,
        AMTBIL6_M 24:1 - 24:EN 30/3,
        AMTBIL7_M 25:1 - 25:EN 30/3,
        AMTBIL8_M 26:1 - 26:EN 30/3,
        AMTBIL9_M 27:1 - 27:EN 30/3,
        AMTBIL10_M 28:1 - 28:EN 30/3,
        AMTBIL11_M 29:1 - 29:EN 30/3,
        AMTBIL12_M 30:1 - 30:EN 30/3,
        AMTBIL13_M 31:1 - 31:EN 30/3
/KEYS SSD_CF,
      SEG_NF,
      UWY_NF,
      CUR_CF,
      VRS_NF
/SUMMARIZE TOTAL AMTSTAT1_M,
           TOTAL AMTSTAT2_M,
           TOTAL AMTSTAT3_M,
           TOTAL AMTSTAT4_M,
           TOTAL AMTSTAT5_M,
           TOTAL AMTSTAT6_M,
           TOTAL AMTSTAT7_M,
           TOTAL AMTSTAT8_M,
           TOTAL AMTSTAT9_M,
           TOTAL AMTSTAT10_M,
           TOTAL AMTSTAT11_M,
           TOTAL AMTSTAT12_M,
           TOTAL AMTSTAT13_M,
           TOTAL AMTBIL1_M,
           TOTAL AMTBIL2_M,
           TOTAL AMTBIL3_M,
           TOTAL AMTBIL4_M,
           TOTAL AMTBIL5_M,
           TOTAL AMTBIL6_M,
           TOTAL AMTBIL7_M,
           TOTAL AMTBIL8_M,
           TOTAL AMTBIL9_M,
           TOTAL AMTBIL10_M,
           TOTAL AMTBIL11_M,
           TOTAL AMTBIL12_M,
           TOTAL AMTBIL13_M
/DERIVEDFIELD AMTSTAT1_MC    AMTSTAT1_M     COMPRESS
/DERIVEDFIELD AMTSTAT2_MC    AMTSTAT2_M     COMPRESS
/DERIVEDFIELD AMTSTAT3_MC    AMTSTAT3_M     COMPRESS
/DERIVEDFIELD AMTSTAT4_MC    AMTSTAT4_M     COMPRESS
/DERIVEDFIELD AMTSTAT5_MC    AMTSTAT5_M     COMPRESS
/DERIVEDFIELD AMTSTAT6_MC    AMTSTAT6_M     COMPRESS
/DERIVEDFIELD AMTSTAT7_MC    AMTSTAT7_M     COMPRESS
/DERIVEDFIELD AMTSTAT8_MC    AMTSTAT8_M     COMPRESS
/DERIVEDFIELD AMTSTAT9_MC    AMTSTAT9_M     COMPRESS
/DERIVEDFIELD AMTSTAT10_MC    AMTSTAT10_M     COMPRESS
/DERIVEDFIELD AMTSTAT11_MC    AMTSTAT11_M     COMPRESS
/DERIVEDFIELD AMTSTAT12_MC    AMTSTAT12_M     COMPRESS
/DERIVEDFIELD AMTSTAT13_MC    AMTSTAT13_M     COMPRESS
/DERIVEDFIELD AMTBIL1_MC    AMTBIL1_M     COMPRESS
/DERIVEDFIELD AMTBIL2_MC    AMTBIL2_M     COMPRESS
/DERIVEDFIELD AMTBIL3_MC    AMTBIL3_M     COMPRESS
/DERIVEDFIELD AMTBIL4_MC    AMTBIL4_M     COMPRESS
/DERIVEDFIELD AMTBIL5_MC    AMTBIL5_M     COMPRESS
/DERIVEDFIELD AMTBIL6_MC    AMTBIL6_M     COMPRESS
/DERIVEDFIELD AMTBIL7_MC    AMTBIL7_M     COMPRESS
/DERIVEDFIELD AMTBIL8_MC    AMTBIL8_M     COMPRESS
/DERIVEDFIELD AMTBIL9_MC    AMTBIL9_M     COMPRESS
/DERIVEDFIELD AMTBIL10_MC    AMTBIL10_M     COMPRESS
/DERIVEDFIELD AMTBIL11_MC    AMTBIL11_M     COMPRESS
/DERIVEDFIELD AMTBIL12_MC    AMTBIL12_M     COMPRESS
/DERIVEDFIELD AMTBIL13_MC    AMTBIL13_M     COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          SEG_NF,
          UWY_NF,
          CUR_CF,
          VRS_NF,
          AMTSTAT1_MC,
          AMTSTAT2_MC,
          AMTSTAT3_MC,
          AMTSTAT4_MC,
          AMTSTAT5_MC,
          AMTSTAT6_MC,
          AMTSTAT7_MC,
          AMTSTAT8_MC,
          AMTSTAT9_MC,
          AMTSTAT10_MC,
          AMTSTAT11_MC,
          AMTSTAT12_MC,
          AMTSTAT13_MC,
          AMTBIL1_MC,
          AMTBIL2_MC,
          AMTBIL3_MC,
          AMTBIL4_MC,
          AMTBIL5_MC,
          AMTBIL6_MC,
          AMTBIL7_MC,
          AMTBIL8_MC,
          AMTBIL9_MC,
          AMTBIL10_MC,
          AMTBIL11_MC,
          AMTBIL12_MC,
          AMTBIL13_MC
exit
EOF
SORT

NSTEP=${NJOB}_60
# Erase temporary files
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"


JOBEND
