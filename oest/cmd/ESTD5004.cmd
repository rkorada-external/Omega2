#!/bin/ksh
#==============================================================================
#nom de l'application: RETRO 
#nom du source: ESTD5004.cmd 
#revision: $Revision:   1.1  $
#date de creation: 07/2001
#auteur:  O.GIRAUX
#description:  Suppression Mutre et CMR dans BTRT ( 45' sur MAIP07)
#
#    Dans l'ordre:
#       - BRET
#       - BEST
#       - BCTA
#       - BTRT
#
#------------------------------------------------------------------------------

#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# JOB initialization
JOBINIT


NSTEP=${NJOB}_05
# Begin bcp
#------------------------------------------------------------------------------
LIBEL=" Delete in BTRT for mutre and cmr"
ISQL_BASE="BTRAV"
ISQL_QRY="exec BTRAV..PdBTRT"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
ISQL

NSTEP=${NJOB}_10
# Begin bcp
#------------------------------------------------------------------------------
LIBEL=" Drop proc PdBTRT"
ISQL_BASE="BTRAV"
ISQL_QRY="DROP PROC dbo.PdBTRT"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
ISQL

JOBEND
