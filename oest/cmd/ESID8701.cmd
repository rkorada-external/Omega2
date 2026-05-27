#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#              			        : Fusion des fichiers FTECLEDA_CUR et _MVT dans FTECLEDA
# nom du script SHELL           : ESID8701.cmd
# revision                      : 
# date de creation              : 15/03/2011
# auteur                        : R. Cassis
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#  :spot:21408 - Fusion des fichiers FTECLEDA_CUR et FTECLEDA_MVT dans FTECLEDA final
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[001]  08/09/2011  Roger Cassis   :spot:22435 - Suppression du step de delete du FTECLEDA_CUR.
#[002]  30/06/2015  DFI            :spot:28947 - filtre des analytiques dans la generation de l'interface 1GL
#[003]	07/09/2016	MMA			   :SPOT:31161 - SPIRA 53727 & 53733 : Verification des Poste analytique afin de les écarter
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# No input parameters

# Job Initialisation
JOBINIT

ECHO_LOG "#===> EST_FTECLEDA_CUR ................ ${EST_FTECLEDA_CUR}"
ECHO_LOG "#===> EST_FTECLEDA_MVT ................ ${EST_FTECLEDA_MVT}"
ECHO_LOG "#===> EST_FTECLEDA_MTH ................ ${EST_FTECLEDA_MTH}"
ECHO_LOG "#===> EST_FTECLEDA_REP ................ ${EST_FTECLEDA_REP}"
ECHO_LOG "#===> EST_SUBTRSESBPROP ................ ${EST_SUBTRSESBPROP}"
ECHO_LOG "#===> EST_SUBTRS ................ ${EST_SUBTRS}"
ECHO_LOG "#===> EST_FTECLEDR_CUR ................ ${EST_FTECLEDR_CUR}"
ECHO_LOG "#===> EST_FTECLEDR_MVT ................ ${EST_FTECLEDR_MVT}"

NSTEP=${NJOB}_10
# Merge FTECLEDA_CUR and FTECLEDA_MVT
#--------------------------------
LIBEL="Merge FTECLEDA_CUR and FTECLEDA_MVT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
set -x
SORT_I="${EST_FTECLEDA_CUR} 1000 1"
SORT_I2="${EST_FTECLEDA_MVT} 1000 1"
SORT_I3="${EST_FTECLEDA_MTH} 1000 1"       # [002]
SORT_I4="${EST_FTECLEDA_REP} 1000 1"       # [002]
SORT_O="${DFILT}/${NSTEP}_SORT_TECLEDA_O.dat 1000 1"
set +x
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	ESB_CF 2:1 - 2:,
	BALSHEY_NF 3:1 - 3:,
	BALSHRMTH_NF 4:1 - 4:,
	TRNCOD_CF 6:1 - 6:,
	DBLTRNCOD_CF 7:1 - 7:,
	CTR_NF 8:1 - 8:,
	END_NT 9:1 - 9:,
	SEC_NF 10:1 - 10:,
	UWY_NF 11:1 - 11:,
	UW_NT 12:1 - 12:,
	OCCYEA_NF 13:1 - 13:,
	ACY_NF 14:1 - 14:,
	SCOSTRMTH_NF 15:1 - 15:,
	SCOENDMTH_NF 16:1 - 16:,
	CUR_CF 18:1 - 18:,
	AMT_M 19:1 - 19:EN 15/3,
	CED_NF 20:1 - 20:,
	RETCTR_NF 24:1 - 24:,
	RETEND_NT 25:1 - 25:,
	RETSEC_NF 26:1 - 26:,
	RTY_NF 27:1 - 27:,
	RETUW_NT 28:1 - 28:,
	RETOCCYEA_NF 29:1 - 29:,
	RETACY_NF 30:1 - 30:,
	RETSCOSTRMTH_NF 31:1 - 31:,
	RETSCOENDMTH_NF 32:1 - 32:,
	RETCUR_CF 34:1 - 34:,
	RETAMT_M 35:1 - 35:EN 15/3,
   TECLEDA_PLC_NT 36:1 - 36:EN,
   TECLEDA_RTO_NF 37:1 - 37:EN,
	RETINTAMT_M 88:1 - 88:EN 15/3,
	ZZRECONKEY_CF 102:1 - 102:
/KEYS
	ESB_CF,
	BALSHEY_NF,
	BALSHRMTH_NF,
	TRNCOD_CF,
	DBLTRNCOD_CF,
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	OCCYEA_NF,
	ACY_NF,
	SCOSTRMTH_NF,
	SCOENDMTH_NF,
	CUR_CF,
	CED_NF,
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF,
	RETUW_NT,
	RETOCCYEA_NF,
	RETACY_NF,
	RETSCOSTRMTH_NF,
	RETSCOENDMTH_NF,
	RETCUR_CF,
   TECLEDA_PLC_NT,
   TECLEDA_RTO_NF,
	ZZRECONKEY_CF
exit
EOF
SORT

NSTEP=${NJOB}_15
# Annual Estimates Screen
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Screen"
PRG=ESTC8701
set -x
export ${PRG}_I1=${DFILT}/${NJOB}_10_SORT_TECLEDA_O.dat
export ${PRG}_I2=${EST_SUBTRSESBPROP}
export ${PRG}_I3=${EST_SUBTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_SORT_TECLEDA_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_TECLEDA_03_ERR.log
set +x
EXECPRG
# cd $DEXE
# debugV2 $PRG

NSTEP=${NJOB}_20
# Begin EXECKSH
#-------------------------------------------------------------------------------
LIBEL="Save ${EST_FTECLEDA_CUR}"
EXECKSH "cp ${EST_FTECLEDA_CUR} ${DSAV}/${SVG}_${NCHAIN}_EST_FTECLEDA_CUR.dat"

NSTEP=${NJOB}_30
# Begin EXECKSH
#-------------------------------------------------------------------------------
LIBEL="gzip ${DSAV}/${SVG}_${NCHAIN}_EST_FTECLEDA_CUR.dat"
EXECKSH "gzip ${DSAV}/${SVG}_${NCHAIN}_EST_FTECLEDA_CUR.dat"

NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
#-----------------------------------------------------------------------------
LIBEL="Rename ${DFILT}/${NJOB}_15_${IB}_SORT_TECLEDA_O.dat to ${EST_FTECLEDA}"
EXECKSH "mv ${DFILT}/${NJOB}_15_${IB}_SORT_TECLEDA_O.dat ${EST_FTECLEDA}"

NSTEP=${NJOB}_60
# Generation of the new FTECLEDR
#------------------------------------------------------------------------------
LIBEL="Generation of the new FSNEMHIST0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTECLEDR_CUR} 1000 1"
SORT_I2="${EST_FTECLEDR_MVT} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TECLEDR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
exit
EOF
SORT

NSTEP=${NJOB}_70
# Annual Estimates Screen
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Screen"
PRG=ESTC8701
set -x
export ${PRG}_I1=${DFILT}/${NJOB}_60_${IB}_SORT_TECLEDR_O.dat
export ${PRG}_I2=${EST_SUBTRSESBPROP}
export ${PRG}_I3=${EST_SUBTRS}
export ${PRG}_O1=${EST_FTECLEDR}
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_TECLEDR_03_ERR.log
set +x
EXECPRG
# cd $DEXE
# debugV2 $PRG

NSTEP=${NJOB}_70
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND

