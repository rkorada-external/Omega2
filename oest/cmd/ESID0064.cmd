#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
# nom du script SHELL		: ESID0064.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 31/10/1997
# auteur			: CGI
# references des specifications	: 
#-----------------------------------------------------------------------------
# Description :
#   Transferring draft table BCTA..TACCTRNF into TL file
#
# Job launched by ESID0060.cmd
#-----------------------------------------------------------------------------
# historiques des modifications : 
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job initialization
JOBINIT


NSTEP=${NJOB}_05
# Transferring draft table TACCTRNF into TL file 
#------------------------------------------------------------------------------
LIBEL="Transferring draft table BCTA..TACCTRNF into TL file"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_MVTPNA0}
BCP_QRY="exec BEST..PsACCTRNF_01"
BCP 


JOBEND
