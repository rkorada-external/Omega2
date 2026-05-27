#=============================================================================
# nom de l'application          : ESTIMATIONS - MISE A JOUR TREQJOB 
#                                 Mise a jour de la table des demandes PostOmega Final BEST..TREQJOB
# nom du script SHELL           : ESLJ8991.cmd
# revision                      : 5.1
# date de creation              : 25/10/2017
# auteur                        : R. CASSIS
# references des specifications : Spira:61508
#-----------------------------------------------------------------------------
# description
#   Update of request table
#-----------------------------------------------------------------------------
# historique des modifications
# 
#[xxx] JJ/MM/AAAA R. Cassis    :spira:xxxxx Comments
#===============================================================================
#set -x

# Call geneic functions
. ${DUTI}/fctgen.cmd

#Recupee arguments d'entree
CRE_D=$1
BLCSHTYEALOC_NF=$2
BLCSHTMTHLOC_NF=$3
ENCONSO_D=$4
DBCLO_D=$5
INVCONSO_D=$6
                        
# Job Initialisation
JOBINIT


NSTEP=${NJOB}_05
# Begin isql 
#------------------------------------------------------------------------------
LIBEL="Update of Request table - Type F et T" 
ISQL_BASE="BEST"
ISQL_QRY="exec PuREQJOB_07L '${CRE_D}', ${BLCSHTYEALOC_NF}, ${BLCSHTMTHLOC_NF}, '${INVCONSO_D}', '${DBCLO_D}', '${ENCONSO_D}'"
ISQL

JOBEND
