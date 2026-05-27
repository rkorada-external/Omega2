#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE 
#                                 SHERPA
# nom du script SHELL		: ESID1022.cmd
# revision			: 
# date de creation		: 10/07/98
# auteur			: L.Capomazza
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   Life
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================
#set -x
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd

CLODAT_D=$1

# Initialization of the Job
JOBINIT

NSTEP=${NJOB}_05
# Merge of all the GROUPED USER'S FILES
#------------------------------------------------------------------------------
LIBEL="Merge of all the GROUPED USER'S FILES"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NCHAIN}_ESID1021_55_${IB}_SORT_FTECLEDA.dat
SORT_I2=${DFILT}/${NCHAIN}_ESID1021_120_${IB}_SORT_FTECLEDR.dat
SORT_I3=${DFILT}/${NCHAIN}_ESID1021_130_${IB}_SORT_FTECLEDN.dat
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECG.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS  SSD_CF 2: 1 - 2:, TRNCOD_CF 6: 1 - 6:
/KEYS SSD_CF , TRNCOD_CF 
exit
EOF
SORT

NSTEP=${NJOB}_10
# Creation of the GROUPED USER'S FILES by subsidiary
#------------------------------------------------------------------------------
LIBEL="Creation of the GROUPED USER'S FILES by subsidiary"
PRG=ESTC1043
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
PREFIXE ${DFILT}/${NCHAIN}
SUFFIXE FTECLEDG.dat
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NCHAIN}_ESID1022_05_${IB}_SORT_FTECG.dat
export ${PRG}_I2=${EST_FSUBSID}
EXECPRG

NSTEP=${NJOB}_15
# Concat file names
#-----------------------------------------------------------------------------
LIBEL="Concat file names"
STR_CAT_PREFIX="${DFILT}/${NCHAIN}_*_FTECLEDG.dat"
STR_CAT

NSTEP=${NJOB}_20
# Move GROUPED USER'S FILES into users directory
#--------------------------------------------------------
LIBEL="Move GROUPED USER'S FILES into users directory" 
EXECKSH " mv ${DFILT}/${NCHAIN}_*_FTECLEDG.dat ${DUSERS}"

NSTEP=${NJOB}_25
# Merge of all the DETAILED USER'S FILES
#------------------------------------------------------------------------------
LIBEL="Merge of all the DETAILED USER'S FILES"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NCHAIN}_ESID1021_50_${IB}_ESTC1029_FTECLEDA.dat
SORT_I2=${DFILT}/${NCHAIN}_ESID1021_105_${IB}_ESTC1033_FTECLEDR.dat
SORT_I3=${DFILT}/${NCHAIN}_ESID1021_125_${IB}_ESTC1029_FTECLEDN.dat
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECD.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS  SSD_CF 2: 1 - 2:, TRNCOD_CF 6: 1 - 6:
/KEYS SSD_CF , TRNCOD_CF 
exit
EOF
SORT

NSTEP=${NJOB}_30
# Creation of the DETAILED USER'S FILES by subsidiary
#------------------------------------------------------------------------------
LIBEL="Creation of the DETAILED USER'S FILES by subsidiary"
PRG=ESTC1045
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
PREFIXE ${DFILT}/${NCHAIN}
SUFFIXE FTECLEDD.dat
CLODAT_D ${CLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NCHAIN}_ESID1022_25_${IB}_SORT_FTECD.dat
export ${PRG}_I2=${EST_FSUBSID}
EXECPRG

NSTEP=${NJOB}_35
# Concat file names
#-----------------------------------------------------------------------------
LIBEL="Concat file names"
STR_CAT_PREFIX="${DFILT}/${NCHAIN}_*_FTECLEDD.dat"
STR_CAT

NSTEP=${NJOB}_40
# Move DETAILED USER'S FILES into users directory
#--------------------------------------------------------
LIBEL="Move DETAILED USER'S FILES into users directory" 
EXECKSH " mv ${DFILT}/${NCHAIN}_*_FTECLEDD.dat ${DUSERS}"

NSTEP=${NJOB}_45
# Deletion of Temporary Files
#------------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NCHAIN}_*_${IB}_*"

JOBEND