#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Mise a jour des previsions
# nom du script SHELL           : ESTD7001.cmd
# revision                      : $Revision:   1.2  $
# date de creation              :
# auteur                        :
# references des specifications :
#-----------------------------------------------------------------------------
# description
#      save fichiers GTA GTR CURGTA CURGTR STATGTA STATGTR ARCSTATGTA ARCSTATGTR
#               vers repertoire temporaire
#
# job launched by ESTD7000.cmd
#-----------------------------------------------------------------------------
# historique des modifications
#
#=============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters

# Initialisation des variables

NSTEP=${NJOB}_05
# Begin sort
#----------------------------------------------------------------------------
LIBEL="move GTA (perm) ==> GTA (temp)"
EXECKSH "mv ${DFILP}/${PCH}ESIX7000_GTA.dat ${DFILT}/${PCH}ESIX7000_GTA.dat"

NSTEP=${NJOB}_10
# Begin sort
#----------------------------------------------------------------------------
LIBEL="move GTR (perm) ==> GTR (temp)"
EXECKSH "mv ${DFILP}/${PCH}ESIX7000_GTR.dat ${DFILT}/${PCH}ESIX7000_GTR.dat"

NSTEP=${NJOB}_15
# Begin sort
#----------------------------------------------------------------------------
LIBEL="move CURGTA (perm) ==> CURGTA (temp)"
EXECKSH "mv ${DFILP}/${PCH}ESIX7000_CURGTA.dat ${DFILT}/${PCH}ESIX7000_CURGTA.dat"

NSTEP=${NJOB}_20
# Begin sort
#----------------------------------------------------------------------------
LIBEL="move CURGTR (perm) ==> CURGTR (temp)"
EXECKSH "mv ${DFILP}/${PCH}ESIX7000_CURGTR.dat ${DFILT}/${PCH}ESIX7000_CURGTR.dat"

NSTEP=${NJOB}_25
# Begin sort
#----------------------------------------------------------------------------
LIBEL="move STATGTA (perm) ==> STATGTA (temp)"
EXECKSH "mv ${DFILP}/${PCH}ESIX7000_STATGTA.dat ${DFILT}/${PCH}ESIX7000_STATGTA.dat"

NSTEP=${NJOB}_30
# Begin sort
#----------------------------------------------------------------------------
LIBEL="move STATGTR (perm) ==> STATGTR (temp)"
EXECKSH "mv ${DFILP}/${PCH}ESIX7000_STATGTR.dat ${DFILT}/${PCH}ESIX7000_STATGTR.dat"

NSTEP=${NJOB}_35
# Begin sort
#----------------------------------------------------------------------------
LIBEL="move ARCSTATGTA (perm) ==> ARCSTATGTA (temp)"
EXECKSH "mv ${DFILP}/${PCH}ESIX7000_ARCSTATGTA.dat ${DFILT}/${PCH}ESIX7000_ARCSTATGTA.dat"

NSTEP=${NJOB}_40
# Begin sort
#----------------------------------------------------------------------------
LIBEL="move ARCSTATGTR (perm) ==> ARCSTATGTR (temp)"
EXECKSH "mv ${DFILP}/${PCH}ESIX7000_ARCSTATGTR.dat ${DFILT}/${PCH}ESIX7000_ARCSTATGTR.dat"

JOBEND
