#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
# nom du script SHELL		: ESID0063.cmd
# revision			: $Revision:   1.2  $
# date de creation		: 31/10/1997
# auteur			: CGI
# references des specifications	: 
#-----------------------------------------------------------------------------
# Description :
#	Parameter file preparation for PNA FAC
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
# Begin bcp 
#------------------------------------------------------------------------------
LIBEL="Parameter file generation"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PNAPARAM_O.dat
BCP_QRY="exec BEST..PsESTSSD_01"
BCP 


JOBEND



