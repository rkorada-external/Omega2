#!/bin/ksh
#=============================================================================
# nom de l'application          : IFRS17 Booking
# nom du script SHELL           : ESF8016.cmd
# revision                      : 
# date de creation              : 29/04/2020
# auteur                        : Arnaud RUFFAULT
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  Spira 86253 IFRS 17- Booking  TRETIFRS update
#-----------------------------------------------------------------------------
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ........................ INPUTS ....................................."
ECHO_LOG "#===> NORME_CF...........................................: ${NORME_CF}"
ECHO_LOG "#===> USER...............................................: ${USER_ESFD8010}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="Update table BRET..TRETIFRS"
ISQL_BASE="BRET"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="exec PuRETIFRS_02 '${NORME_CF}', '${USER_ESFD8010}'"
ISQL



JOBEND