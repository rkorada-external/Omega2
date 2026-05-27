#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - COMMUNS
# nom du script SHELL           : ESCJ0003.cmd
# date de creation              : 24/02/2016
# auteur                        : Roger Cassis
#-----------------------------------------------------------------------------
# description:  Planification d'un closing de type D dans la Treqjobplan
#
# job launched by ESCJ0000.cmd
#-----------------------------------------------------------------------------
# Modification Records
#---------------
#MODIFICATION   :
#[000]  24/02/2016  Roger Cassis   :spot:30163 - planification de closing
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Parameters
CRE_D=$1
DBCLO_D=$2
BALSHTMTH_NF=$3

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> CRE_D..........: ${CRE_D}"
ECHO_LOG "#===> DBCLO_D........: ${DBCLO_D}"
ECHO_LOG "#===> BALSHTMTH_NF...: ${BALSHTMTH_NF}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_10
# Begin isql
#---------------------------------------------------------------
LIBEL="Generation d'un enregistrement de planification dans la TREQJOBPLAN variante D"
ISQL_BASE="BEST"
ISQL_QRY="execute BEST..PtREQJOBPLAN_04 '${CRE_D}', '${DBCLO_D}', ${BALSHTMTH_NF}"
ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
ISQL

# End of Job
JOBEND

