#!/bin/ksh
#=============================================================================
# nom de l'application          : IFRS17 
# nom du script SHELL           : ESFT0011.cmd
# revision                      : 
# date de creation              : 30/06/2020
# auteur                        : Arnaud RUFFAULT
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  IFRS17: The goal of this job is to retrieve the Omega 2 extract in a file
#
#-----------------------------------------------------------------------------
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT


ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ............ INPUT PARAMETERS........................................"
ECHO_LOG "#===> NORME_CF..................................................: ${NORME_CF}"
ECHO_LOG "#===> PARM_TRA_Q_DATE...........................................: ${PARM_TRA_Q_DATE}"
ECHO_LOG "#===> ............ OUTPUT FILE............................................."
ECHO_LOG "#===> OMEGA_EXTRACT_TRN.......................................: ${OMEGA_EXTRACT_TRN}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="Generation of the file OMEGA_EXTRACT_TRN (Omega 2 extract) for Transition file generation"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${OMEGA_EXTRACT_TRN}
BCP_QRY="execute BSEG..PsOmegaExtract '${PARM_TRA_Q_DATE}', '${NORME_CF}'"
BCP


JOBEND
