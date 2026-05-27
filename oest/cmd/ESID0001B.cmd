#!/bin/ksh
#=============================================================================
# nom de l'application          : I17G -ANN (Annual Limit)
# nom du script SHELL           : ESID0004.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 07\01\2021
# auteur                        : NBD
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  IFRS17 : BFAC and BTRT Annual Limit Extract 
#
#-----------------------------------------------------------------------------
#===============================================================================
# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT


ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ............ OUTPUT ................................................."
ECHO_LOG "#===> EST_ANN_LIMIT_FAC.......................................: ${EST_ANN_LIMIT_FAC}"
ECHO_LOG "#===> EST_ANN_LIMIT_TRT.......................................: ${EST_ANN_LIMIT_TRT}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="Generation of the file EST_ANN_LIMIT_FAC  for Annual Limit"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_ANN_LIMIT_FAC}
BCP_QRY="execute BFAC..PsFacAnnualLimit"
BCP


NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="Generation of the file EST_ANN_LIMIT_TRT  for Annual Limit"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_ANN_LIMIT_TRT}
BCP_QRY="execute BTRT..PsTrtAnnualLimit"
BCP


JOBEND