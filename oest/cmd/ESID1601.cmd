#!/bin/ksh
#=============================================================================
# nom de l'application		: INVENTAIRE
#                                 Retour des resultats de l'inventaire pour
#				 l'actuariat bilans anterieurs
# nom du script SHELL		: ESID1601.cmd
# revision			: $Revision:   1.7  $
# date de creation		: 26/05/98
# auteur			: C.G.I. (M.HA-THUC)
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#	Sending of Closing period process results to actuary   
#
# Job launched by ESID1600.cmd
#
# Launch C programs ESTC1600 and ESTC1601
# Output file sort
#		${DFILT}/${NSTEP}_${IB}_SORT_ARCSTATGTAA_O.dat	 
#		${DFILT}/${NSTEP}_${IB}_SORT_FCTRGRO0_O.dat
#		${DFILT}/${NSTEP}_${IB}_SORT_ACCMVT_O.dat
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd


# Job Initialisation
JOBINIT

# Get Input parameter


NSTEP=${NJOB}_00
#Last version of ESID1600 files deletion
#-----------------------------------------------------------------
RMFIL " `dirname ${EST_FSEGACTBILANT}`/${PCH}ESID1600_FSEGACTBILANT*.dat"

NSTEP=${NJOB}_05
# Filter of ARCSTATGTA on acceptance
# Warning - This file must be sorted on CTR_NF, END_NT, SEC_NF
#------------------------------------------------------------------------------
LIBEL="Filter of ARCSTATGTA on acceptance" 
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_ARCSTATGTA}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_ARCSTATGTAA_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:EN,
        TRNCOD_PREFIX 6:1 - 6:1,
        TRNCOD_SOUSPRE 6:2 - 6:2 
/COPY
/CONDITION ACCEPT ${EST_SORT_CONDITION} and ( TRNCOD_PREFIX EQ "1" or
           TRNCOD_PREFIX EQ "3" ) and ( TRNCOD_SOUSPRE EQ "1" or
           TRNCOD_SOUSPRE EQ "2" or TRNCOD_SOUSPRE EQ "3") 
/INCLUDE ACCEPT
exit
EOF
SORT

NSTEP=${NJOB}_10
# FCTRGRO file sort by contract/endorsement/section
#-----------------------------------------------------------------------------
LIBEL="FCTRGRO file sort in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FCTRGRO0}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCTRGRO0_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2:,
        SEC_NF 3:1 - 3:
        UWY_NF 21:1 - 21:,
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
	  UWY_NF
exit
EOF
SORT

NSTEP=${NJOB}_15
# Accounting transaction code transformation, ... for the ARCSTATGTAA
#-----------------------------------------------------------------------------
LIBEL="Accounting transaction code transformation, ... for the ARCSTATGTAA"
PRG=ESTC1600
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
PRS_CF 717
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_SORT_ARCSTATGTAA_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_SORT_FCTRGRO0_O.dat
export ${PRG}_I3=${EST_FCURQUOT}
export ${PRG}_I4=${EST_FTRSLNK}
export ${PRG}_I5=${EST_FSEGMENT}
export ${PRG}_I6=${EST_FCPLACC0}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_ACCMVT_O.dat
EXECPRG

NSTEP=${NJOB}_17
# Temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_05_${IB}_SORT_ARCSTATGTAA_O.dat
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_FCTRGRO0_O.dat

NSTEP=${NJOB}_20
# Accumulation amount by SSD_CF, SEG_NF, UWY_NF, CUR_CF, ACMTRS_NT
#-----------------------------------------------------------------------------
LIBEL="Accumulation amount by SSD_CF, SEG_NF, UWY_NF, CUR_CF, ACMTRS_NT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_15_${IB}_ESTC1600_ACCMVT_O.dat
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

NSTEP=${NJOB}_22
# Temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_15_${IB}_ESTC1600_ACCMVT_O.dat

NSTEP=${NJOB}_25
# Preparation of the outfile
#-----------------------------------------------------------------------------
LIBEL="Preparation of the outfile"
PRG=ESTC1601
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_ACCMVT_O.dat
export ${PRG}_O1=${EST_FSEGACTBILANT}
EXECPRG

NSTEP=${NJOB}_30
# Erase temporary files
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"


JOBEND
