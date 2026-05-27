#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - CONTROLE DES ESTIMATIONS
#                                 Cumul des montants comptabilises en monnaie
#                                 de l'aliment
# nom du script SHELL		: ESEJ1002_bis.cmd
# revision			: $Revision:   1.11  $
# date de creation		: 20/06/97
# auteur			: C.G.I. (M.HA-THUC)
# references des specifications	: ESTIR32F.doc
#-----------------------------------------------------------------------------
# description
#   Accumulation of amounts booked in EGPI currency (set 32)
#
# job launched by ESEJ9999.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

#Recupere arguments d'entree
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
SSDCLO_LL=$3

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_05
#Merge of CURGTA and GTA
#-----------------------------------------------------------------------------
LIBEL="Current merge of CURGTA of GTA ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_GTA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTA_O.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_ESTCTRGTA_O2.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF 1:1 - 1: EN,
	BALSHEY_NF 3:1 - 3: EN,
	BALSHRMTH_NF 4:1 - 4: EN,
	TRNCOD1_CF 6:1 - 6:2,
	TRNCOD2_CF 6:8 - 6:8,
	CTR_NF 8:1 - 8:,
	END_NT 9:1 - 9:,
	SEC_NF 10:1 - 10:,
	UWY_NF 11:1 - 11:,
	UW_NT 12:1 - 12:

/CONDITION LIGNECPT (( TRNCOD1_CF EQ "11" or TRNCOD1_CF EQ "12" ) and TRNCOD2_CF EQ "0" ) and ( ${BALSHTYEA_NF} > BALSHEY_NF or ( ${BALSHTYEA_NF} EQ BALSHEY_NF and ${BALSHTMTH_NF} >= BALSHRMTH_NF ) )

/CONDITION OMMITCPT (( TRNCOD1_CF EQ "11" or TRNCOD1_CF EQ "12" ) and TRNCOD2_CF EQ "0" ) and ( ${BALSHTYEA_NF} <= BALSHEY_NF and ( ${BALSHTYEA_NF} NE BALSHEY_NF or ${BALSHTMTH_NF} < BALSHRMTH_NF ) )

/KEYS  	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT

/OUTFILE ${SORT_O}
   /INCLUDE LIGNECPT

/OUTFILE ${SORT_O2}
  /INCLUDE OMMITCPT
exit
EOF
SORT

NSTEP=${NJOB}_07
#Compressing ESTCTRGTA
#-----------------------------------------------------------------------------
LIBEL="Current compress of ESTCTRGTA ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_ESTCTRGTA_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESTCTRGTA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF 1:1 - 1: EN,
	BALSHEY_NF 3:1 - 3: EN,
	BALSHRMTH_NF 4:1 - 4: EN,
	TRNCOD1_CF 6:1 - 6:2,
	TRNCOD2_CF 6:8 - 6:8,
	CTR_NF 8:1 - 8:,
	END_NT 9:1 - 9:,
	SEC_NF 10:1 - 10:,
	UWY_NF 11:1 - 11:,
	UW_NT 12:1 - 12:

/KEYS  	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT

/SUMMARIZE
/REFORMAT CTR_NF,
	  END_NT,
	  SEC_NF,
	  UWY_NF,
	  UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_08
# Deletion of temporary files
#------------------------------------------------------------------------------
LIBEL="Deletion of temporary files"
RMFIL "${DFILT}/${NJOB}_05_${IB}_SORT_ESTCTRGTA_O2.dat 1000 1"

NSTEP=${NJOB}_10
# Putting into phase accounting rows - contracts list
#------------------------------------------------------------------------------
LIBEL="Putting into phase accounting rows - contracts list"
PRG=ESTC3211
export ${PRG}_I1=${DFILT}/${NCHAIN}_ESEJ1001_bis_40_${IB}_SORT_ESTCTRLIS_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_05_${IB}_SORT_GTA_O.dat
export ${PRG}_I3=${EST_STATGTA}
export ${PRG}_I4=${EST_ARCSTATGTA}
export ${PRG}_I5=${EST_FTRSLNK}
export ${PRG}_I6=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_ESTMVTCPT_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_ESTCTRLIS_O.dat
EXECPRG

NSTEP=${NJOB}_15
# Accumulation of amounts in EGPI currency by contract
#------------------------------------------------------------------------------
LIBEL="Accumulation of amounts in EGPI currency by contract"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_10_${IB}_ESTC3211_ESTMVTCPT_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_ESTMVTCPT_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
	BALSHEY_NF 2:1 - 2:,
	CTR_NF 3:1 - 3:,
	END_NT 4:1 - 4:,
	SEC_NF 5:1 - 5:,
	UWY_NF 6:1 - 6:,
	UW_NT 7:1 - 7:,
	ACMTRS_NT 8:1 - 8:,
	EGPCUR_CF 9:1 - 9:,
	EGPCUR_M 10:1 - 10:EN 30/3
/KEYS 	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	ACMTRS_NT
/SUMMARIZE TOTAL EGPCUR_M
/REFORMAT SSD_CF,
	BALSHEY_NF,
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	ACMTRS_NT,
	EGPCUR_CF,
	EGPCUR_M
exit
EOF
SORT

JOBEND
