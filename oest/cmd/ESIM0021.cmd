#!/bin/ksh
#=============================================================================
# nom de l'application      : ESTIMATES
#                           : COMPANY DEBITOR/CREDITOR
# nom du script SHELL       : ESIM0021.cmd
# revision                  : $Revision:   1.0  $
# date de creation          : 16/07/98
# auteur                    : VAN DE VELDE JF
# references des specifications : 
#-----------------------------------------------------------------------------
# description :
# SELECT MOVEMENTS OF THE TABLES TTCLEDA_X  AND TTCLEDR_X 
# UPDATING OF THE TABLE BSTA..TDEBCRED
# JOB LANCHED BY ESIM0020.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
#    
#===============================================================================
#set -x
# Call generic functions
. ${DUTI}/fctgen.cmd

# Get Input parameters
SSD_CF=$1

#Initialisation of the job
JOBINIT
NSTEP=${NJOB}_05
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Chargement de la table BSTA..TDEBCRED"
ISQL_QRY="execute BSTA..PtDEBCRED_02 '${SSD_CF}', '${HOST_PRDSIT}'"
ISQL_BASE="BSTA"
ISQL


# End of the Job
JOBEND
