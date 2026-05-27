#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE 
#                                 Preparation 
#                                 Impression du compte-rendu inventaire vie
# nom du script SHELL		: ESID2042.cmd
# revision			: $Revision:   1.2  $
# date de creation		: 10/07/97
# auteur			: C.G.I. (C.Chavatte)
# references des specifications	: 
#-----------------------------------------------------------------------------
# description 
#   Print report and deleting all temporary files
#
#   Output file sort  ${DFILT}/${NSTEP}_${IB}_SORT_ANO_O.dat
#
#   Launch C program ESTR203A   
#   
# job launched by ESID2040.cmd
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctsplit.cmd

JOBINIT

# Get input parameters
CLODAT_D=$1
CRE_D=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
DBCLO_D=$5
MODE=$6 

#Surcharge mapping
. ${DCMD}/ESFD9001_MAPPING.cmd

if [ ${MODE} = "PA" ]
then
  EST_SIGNANO=${EST_SIGNANO_PA}
else
  EST_SIGNANO=${EST_SIGNANO_PC}
fi

NSTEP=${NJOB}_05
#Anomalies Files Merging
#------------------------------------------------------------------------------
LIBEL="Anomalies Files Merging"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_SEGRATANO}
SORT_I2=${EST_CRIBLEANO}
SORT_I3=${EST_SIGNANO}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_ANO_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS ANOCOD_CF 1:1 - 1:, UWGRP_CF 2:1 - 2:, CTR_NF 3:1 - 3:, SEC_NF 4:1 - 4:, UWY_NF 5:1 - 5:, ACY_NF 6:1 - 6:, ACMTRS_NT 7:1 - 7:, PCPCUR_CF 8:1 - 8:, SSD_CF 9:1 - 9:
/KEYS SSD_CF,UWGRP_CF, ANOCOD_CF, CTR_NF, SEC_NF, UWY_NF, ACY_NF, ACMTRS_NT
exit
EOF
SORT

NSTEP=${NJOB}_10
#Report Generation
#------------------------------------------------------------------------------
LIBEL="Report Generation"
PRG=ESTR203A
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
CRE_D ${CRE_D}
BALSHTYEA_NF ${BALSHTYEA_NF}
BALSHTMTH_NF ${BALSHTMTH_NF}
DBCLO_D ${DBCLO_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_SORT_ANO_O.dat
export ${PRG}_I2=${EST_FSUBSID}
export ${PRG}_I3=${EST_FACMTRSH}
export ${PRG}_I4=${EST_FBANTECL}
export ${PRG}_I5=${EST_FGRP}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_ANO_O.dat
EXECPRG

NSTEP=${NJOB}_15
#Split Files by SSD
#---------------------------------------------------------------
LIBEL="Split files by SSD"
SPLIT_PREFIX=${NJOB}_10
SPLIT_PREFIX_NEW=${NCHAIN}_ESID2043
SPLIT_I=${DFILT}/${NJOB}_10_${IB}_ESTR203A_ANO_O.dat
SPLIT_SSD

#NSTEP=${NJOB}_20
## Begin rm
##------------------------------------------------------------------------------
#LIBEL="Step to remove temporary job files"
#RMFIL "${DFILT}/${NJOB}_*_${IB}_*.dat"

JOBEND
