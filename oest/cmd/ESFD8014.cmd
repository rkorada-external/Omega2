#!/bin/ksh
#=============================================================================
# nom de l'application          : IFRS17 Booking
# nom du script SHELL           : ESF8014.cmd
# revision                      : 
# date de creation              : 10/04/2020
# auteur                        : Arnaud RUFFAULT
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  Spira 75828 IFRS 17- Booking TTHRHLDLOB update
#-----------------------------------------------------------------------------
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ........................ INPUTS ....................................."
ECHO_LOG "#===> CLOSING DATE.......................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> NORME_CF...........................................: ${NORME_CF}"
ECHO_LOG "#===> USER...............................................: ${USER_ESFD8010}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="Update table BEST..TTHRHLDLOB"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="exec PuTHRHLDLOB_01 '${PARM_ICLODAT_D}', '${NORME_CF}', '${USER_ESFD8010}'"
ISQL

JOBEND
