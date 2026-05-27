#!/bin/ksh
#=============================================================================
# maj de l'application:          ESTIMATIONS - TRANSFERT PORTEFEUILLE INTER-SITES
# nom du script SHELL:           ESTD3032.cmd
# revision: $Revision:           1.1  $
# date de creation:              08/02/2007
# auteur:                        J.Ribot
# references des specifications : SPOT EST13720
#-----------------------------------------------------------------------------
# description
#   Transfert Amerique du Sud
#
# job launched by ESTD3030.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
#   <JJ/MM/AAAA>   <Auteur >    <Description de la modification>
#
#===============================================================================

# Call generic functions

. ${DUTI}/fctgen.cmd

#set -x
# Job Initialisation
JOBINIT

# Parameters
IN_OUT=${1}

# GTA

if [ ${IN_OUT} = 1 ]
then


NSTEP=${NJOB}_05
#
#-----------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
LIBEL="Append GTA Files "
SORT_CMD=`CFTMP`
SORT_I="${DFILP}/${PCH}ESIX7000_GTA.dat 1000 1"
SORT_I2="${DFILI}/${PCH}ESTD3020_ESTD3021_GTA_TRANSFP_RETRAIT.dat 1000 1"
SORT_O="${DFILT}/${PCH}ESIX7000_GTA.dat.new 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 8:1 - 8:
/KEYS CTR_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_07
#
#-----------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
LIBEL="Append CURGTA Files "
SORT_CMD=`CFTMP`
SORT_I="${DFILP}/${PCH}ESIX7000_CURGTA.dat 1000 1"
SORT_I2="${DFILI}/${PCH}ESTD3020_ESTD3021_CURGTA_TRANSFP_RETRAIT.dat 1000 1"
SORT_O="${DFILT}/${PCH}ESIX7000_CURGTA.dat.new 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 8:1 - 8:
/KEYS CTR_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT

fi

if [ ${IN_OUT} = 0 ]
then


NSTEP=${NJOB}_10
#
#-----------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
LIBEL="Append GTA Files "
SORT_CMD=`CFTMP`
SORT_I="${DFILP}/${PCH}ESIX7000_GTA.dat 1000 1"
SORT_I2="${DFILI}/${PCH}ESTD3020_ESTD3022_GTA_TRANSFP_ENTREE.dat 1000 1"
SORT_O="${DFILT}/${PCH}ESIX7000_GTA.dat.new 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 8:1 - 8:
/KEYS CTR_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_12
#
#-----------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
LIBEL="Append CURGTA Files "
SORT_CMD=`CFTMP`
SORT_I="${DFILP}/${PCH}ESIX7000_CURGTA.dat 1000 1"
SORT_I2="${DFILI}/${PCH}ESTD3020_ESTD3022_CURGTA_TRANSFP_ENTREE.dat 1000 1"
SORT_O="${DFILT}/${PCH}ESIX7000_CURGTA.dat.new 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 8:1 - 8:
/KEYS CTR_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT

fi


NSTEP=${NJOB}_15
# Begin Remove
#--------------------------------------------------------------------------
LIBEL="move $DFILT/${PCH}ESIX7000_GTA.dat.new $DFILP/${PCH}ESIX7000_GTA.dat"
EXECKSH "mv $DFILT/${PCH}ESIX7000_GTA.dat.new $DFILP/${PCH}ESIX7000_GTA.dat"

NSTEP=${NJOB}_18
# Begin Remove
#--------------------------------------------------------------------------
LIBEL="move $DFILT/${PCH}ESIX7000_CURGTA.dat.new $DFILP/${PCH}ESIX7000_CURGTA.dat"
EXECKSH "mv $DFILT/${PCH}ESIX7000_CURGTA.dat.new $DFILP/${PCH}ESIX7000_CURGTA.dat"


NSTEP=${NJOB}_20
#Temporary file deletion
#------------------------------------------------
LIBEL="Temporary file deletion in progress"
#RMFIL "${DFILI}/${PCH}ESTD3020_*.dat"
RMFIL "${DFILT}/${PCH}ESIX7000_*.dat.new"

JOBEND


