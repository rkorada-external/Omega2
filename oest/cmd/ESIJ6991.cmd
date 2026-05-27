#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - 
#                                 
# nom du script SHELL		: ESIJ6991.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 17/02/97
# auteur			: M.NAJI
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#
# launched by ESIJ6990.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
#    
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

if [ ${SRV} = "FRMP03_SRV" ]
then

NSTEP=${NJOB}_05
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Update TDRYTRN" 
ISQL_BASE="BEST"
ISQL_QRY="UPDATE  BCTA..TDRYTRN SET ESTFLG_B = 1 from  BCTA..TDRYTRN where SSD_CF  in(2,3,4,6,12) AND ESTFLG_B=0"
ISQL

fi

JOBEND
