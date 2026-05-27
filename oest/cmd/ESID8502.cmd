#!/bin/ksh
#=============================================================================
# nom de l'application           : ESTIMATIONS - INVENTAIRE - Chargement de FTVENTNPHIST
# nom du script SHELL            : ESID8502.cmd
# revision                       : $Revision:   1.1  $
# date de creation               : 16/12/2011
# auteur                         : P. PEZOUT, R. CASSIS
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   Chargement de FTVENTNPHIST 
#
# job launched by ESID8500.cmd  :spot:22862
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
BALSHEYEA=$1
BALSHTMTH=$2

# Job Initialisation
JOBINIT

export BALSHEYEAS=$((${BALSHEYEA}+1))

## compta trimestrielle
NSTEP=${NJOB}_05
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Current Generation of FTVENTNPHIST"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_FTVENTNPHIS_BCP_O.dat
BCP_QRY="execute BRET..PsTVENTNP_07"
BCP

NSTEP=${NJOB}_10
# Reformat of EST_FTVENTNPHIS with BALSHEYEA and BALSHTMTH
#-----------------------------------------------------------------------------
LIBEL="Reformat EST_FTVENTNPHIS  with BALSHEYEA and BALSHTMTH ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${EST_FTVENTNPHIS}"
SORT_I="${DFILT}/${NJOB}_05_${IB}_FTVENTNPHIS_BCP_O.dat"
SORT_NOINFILE=YES
SORT_O="${DFILT}/${NSTEP}_${IB}_FTVENTNPHIS_O.dat OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FILLER1 1:1 - 17:
/DERIVEDFIELD SEPA "~"
/DERIVEDFIELD VALNULL ""
/DERIVEDFIELD BALYEA ${BALSHEYEA}
/DERIVEDFIELD BALTMTH ${BALSHTMTH}
/OUTFILE ${SORT_O}
/REFORMAT  BALYEA,
           SEPA,
           BALTMTH,
           SEPA,
           FILLER1,
           VALNULL
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_15
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Loading FTVENTNPHIS table into TVENTNPHIS"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_10_${IB}_FTVENTNPHIS_O.dat
BCP_TABLE="BRET..TVENTNPHIS"
BCP

NSTEP=${NJOB}_20
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"

JOBEND
