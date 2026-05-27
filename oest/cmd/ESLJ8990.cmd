#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - MISE A JOUR TREQJOB 
#                                 Mise a jour de la table des demandes PostOmega Final BEST..TREQJOB
# nom du script SHELL           : ESLJ8990.cmd
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

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get the parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$1
CRE_D=$5
DBCLO_D=$6
ENCONSO_D=${20}
INVCONSO_D=${21}
CONSOYEA=${22}
CONSOMTH=${23}
BLCSHTYEALOC_NF=${36}
BLCSHTMTHLOC_NF=${37}

# Launch applicative job ESCD9001
NJOB="ESCD9001"
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${CONSOYEA} ${CONSOMTH} ${CRE_D} ${DBCLO_D} ${INVCONSO_D} ${INVCONSO_D}

# Launch applicative job ESLJ8991
NJOB="ESLJ8991"
${DCMD}/ESLJ8991.cmd ${CRE_D} ${BLCSHTYEALOC_NF} ${BLCSHTMTHLOC_NF} ${INVCONSO_D} ${DBCLO_D} ${INVCONSO_D} 2>&1 | ${TEE}


CHAINEND
