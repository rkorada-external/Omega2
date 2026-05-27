#!/bin/ksh
#=============================================================================
# nom de l'application          : IFRS17 Booking
# nom du script SHELL           : ESF8012.cmd
# revision                      : 
# date de creation              : 10/04/2020
# auteur                        : Arnaud RUFFAULT
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  Spira 82867 IFRS 17- Booking  TSECIFRS update
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
LIBEL="Update table BTRT..TSECIFRS"
ISQL_BASE="BTRT"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="exec PuSECIFRS_02 '${NORME_CF}', '${USER_ESFD8010}'"
ISQL

NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="Update table BFAC..TSECIFRS"
ISQL_BASE="BFAC"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="exec PuSECIFRS_02 '${NORME_CF}', '${USER_ESFD8010}'"
ISQL

JOBEND
