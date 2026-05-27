#!/bin/ksh
#=============================================================================
# nom de l'application      : ESTIMATES 
#                           : AGEING BALANCE
# nom du script SHELL       : ESIM0011.cmd
# revision                  : $Revision:   1.0  $
# date de creation          : 16/07/98
# auteur                    : VAN DE VELDE JF
# references des specifications : 
#-----------------------------------------------------------------------------
# description :
# SELECT THE MOVEMENTS OF THE TABLE BSTA..TCURTRS
# UPDATING OF THE TABLE BSTA..TDEBCRED
# JOB LANCHED BY  ESIM0010.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
#    
#===============================================================================
#set -x
# Call generic functions
. ${DUTI}/fctgen.cmd

# Get Input parameters
DATE_T=$1
SSD_CF=$2

#Initialisation of the job
JOBINIT
NSTEP=${NJOB}_05
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Chargement de la table BSTA..TDEBCRED"
ISQL_QRY="execute BSTA..PtDEBCRED_01 '${DATE_T}', '${SSD_CF}', '${HOST_PRDSIT}'"
ISQL_BASE="BSTA"
ISQL


# End of the Job
JOBEND
