#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - COMMUNS - NETTOYAGE TREQJOB
# nom du script SHELL           : ESCJ0011.cmd
# date de creation              : 28/09/2010
# auteur                        : D.GATIBELZA
#-----------------------------------------------------------------------------
# description:  Suppression des anciennes demandes non exécutées dans la TREQJOB
#-----------------------------------------------------------------------------
# historiques des modifications
#---------------
#MODIFICATION   : [001]
#Auteur         : 
#Date           : 
#Version        : 
#Description    : 
#[002] 04/11/2015 R. Cassis     :spot:29654 Gestion plan2 pour le Post-omega - delete records if exists
#===============================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Parameters
CRE_D=$1

#[002]
NSTEP=${NJOB}_05
# Begin isql
#---------------------------------------------------------------
LIBEL="Reset planned records if job launched again"
ISQL_BASE="BEST"
ISQL_QRY="update best..treqjobplan
  			   set launch_d  = null
  			where launch_d  = '19001231'
  			and   dbclo_d  <= '${CRE_D}'
  			and   site_cf   = '${HOST_PRDSIT}'
  			update best..treqjob
  			   set launch_d  = null
  			where launch_d  = '19001231'
  			and   dbclo_d  <= '${CRE_D}'
  			and   site_cf   = '${HOST_PRDSIT}'
"
ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log	          
ISQL

NSTEP=${NJOB}_10
# Begin isql
#---------------------------------------------------------------
LIBEL="Suppression des anciennes demandes non exécutées dans la TREQJOB"
ISQL_BASE="BEST"
ISQL_QRY="execute BEST..PdREQJOB_02 '${CRE_D}'"
ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
ISQL


# End of Job
JOBEND

