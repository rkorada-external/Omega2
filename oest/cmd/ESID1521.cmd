#!/bin/ksh
#=============================================================================
# nom de l'application           : ESTIMATIONS - Comptabilisation des ecritures de services
# nom du script SHELL            : ESID1521.cmd
# revision                       : $Revision:   1.8  $
# date de creation               : 03/09/2003
# auteur                         : J. Ribot
# references des specifications  : SPOT EST6481.doc
#-----------------------------------------------------------------------------
# description
#   Special entries booking
#
# Input files
#       EST_FCESSION0      DFILI
#       EST_FPLACEMT0      DFILI
#       EST_IADVPERICASE0   DFILI
#       EST_IRDVPERICASE0   DFILI
#
# Output files
#       EST_FCES        DFILI
#       EST_FPLC        DFILI
#
# Job launched by ESID1520.cmd
#
# Launch C programs ESTC2301 ESTC2302
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#[001] 15/06/2012 Roger Cassis :spot:23802 - Modifications pour Solvency - ajout sortie ESTC2301
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

#Get input parameters

#===============================================================================

# Job Initialisation
JOBINIT


NSTEP=${NJOB}_05
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting acceptance perimeter file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADVPERICASE0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADVPERICASE_O.dat  1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        CTR_NF 3:1 - 3:,
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

#/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
#/INCLUDE INVENTAIRE

NSTEP=${NJOB}_10
# EST_FCESSION0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FCESSION0 ==> CES dat ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCESSION0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CES_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
        UW_NT 5:1 - 5:,
        SSD_CF 14:1 - 14: EN
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      UW_NT

exit
EOF
SORT

#/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
#/INCLUDE INVENTAIRE

NSTEP=${NJOB}_20
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Computing new cession file..."
PRG=ESTC2301
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_SORT_IADVPERICASE_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_SORT_CES_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_CES_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_RETNP_SEGMENT_O.dat   #[001]
EXECPRG

NSTEP=${NJOB}_25
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_05_${IB}_SORT_IADVPERICASE_O.dat
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_CES_O.dat

NSTEP=${NJOB}_30
# Begin Sort
# Warning : do not remove this step!!!
# All other steps using the file EST_FCES assume that it is already
# sorted according to ctr_nf/end_nt/sec_nf/uwy_nf/uw_nt/
# retctr_nf/retend_nt/retsec_nf/rty_nf/retuw_nt
#-----------------------------------------------------------------------------
LIBEL="Sorting new cession file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_20_${IB}_ESTC2301_CES_O.dat
SORT_O="${EST_FCES} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
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

NSTEP=${NJOB}_40
#EST_FPLACEMT0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FPLACEMT0 ==> PLC dat..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FPLACEMT0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_PLC_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        RETCTR_NF 3:1 - 3:,
        RETEND_NT 4:1 - 4: ,
        RETSEC_NF 5:1 - 5: ,
        RTY_NF 6:1 - 6: ,
        RETUW_NT 7:1 - 7:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
exit
EOF
SORT

NSTEP=${NJOB}_45
#EST_IRDVPERICASE0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_IRDVPERICASE0 ==> EST_IRDVPERICASE ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDVPERICASE0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IRDVPERICASE_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_50
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Computing new placement file..."
PRG=ESTC2302
export ${PRG}_I1=${DFILT}/${NJOB}_45_${IB}_SORT_IRDVPERICASE_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_40_${IB}_SORT_PLC_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_PLC_O.dat
EXECPRG

NSTEP=${NJOB}_55
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_40_${IB}_SORT_PLC_O.dat
RMFIL ${DFILT}/${NJOB}_45_${IB}_SORT_IRDVPERICASE_O.dat

NSTEP=${NJOB}_60
# Begin Sort
# Warning : do not remove this step!!!
# All other steps using the file EST_FPLC assume that it is already
# sorted according to retctr_nf/retend_nt/retsec_nf/rty_nf/retuw_nt/plc_nt
#-----------------------------------------------------------------------------
LIBEL="Sorting new placement file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_50_${IB}_ESTC2302_PLC_O.dat
SORT_O="${EST_FPLC} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 3:1 - 3:,
        RETEND_NT 4:1 - 4: ,
        RETSEC_NF 5:1 - 5: ,
        RTY_NF 6:1 - 6: ,
        RETUW_NT 7:1 - 7: ,
        PLC_NT 8:1 - 8:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT
exit
EOF
SORT


NSTEP=${NJOB}_65
# Begin rm
#----------------------------------------------------------------------------
LIBEL="Delete temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND

