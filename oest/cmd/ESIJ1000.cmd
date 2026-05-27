#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - CONTROLE DES ESTIMATIONS
#                                 Chaine de redeclenchement de la mise a jour des ultimes
# nom du script SHELL		: ESIJ1000.cmd
# revision			: $Revision:   1.9  $
# date de creation		: 14/01/03
# auteur			: J. Ribot
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   redeclenchement de la mise a jour des ultimes lors d'inventaire
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================
# Modifié par  M. DJELLOULI      10-03-2004
# Ajout de l'appel du ESIJ1001.cmd avec paramètres
# Le traitement ESIJ1001.cmd est conditionné de la manière suivante :
#            SI                     [Max(LSTUPD_D) de BREF..TCURQUOT (SSD_CF = 99)]
#                 est différente de   [LAUNCH_D de BEST..TREQJOB (REQCOD_CT = 'M')]
#            ALORS [EXECUTION DU TRAITEMENT ESIJ1001] et [Nouvelle MAJ de LAUNCH_D]
#            SINON [RIEN]
#
#===============================================================================
##===============================================================================
#set -x


#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_CURGTA
#	EST_GTA
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get the parameters
# ${EST_PARAM} is a global environment variable
set `GETPRM ${EST_PARAM}`
#set -x
SSDs0=$1
SSDs=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}

# Launch applicative job ESIJ1001
NJOB="ESIJ1001"
${DCMD}/ESIJ1001.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} 2 >&1 | ${TEE}

CHAINEND
