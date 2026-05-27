#!/bin/ksh
#=============================================================================
# nom de l'application  : ESTIMATIONS - MISE A JOUR TREQJOB
#                         Mise a jour de la table des demandes  BEST..TREQJOB
# nom du script SHELL   : ESCJ8990.cmd
# date de creation		: 28/11/97
# auteur			    : C.G.I. (M.HA-THUC)
#-----------------------------------------------------------------------------
# description :         Update of request table
#-----------------------------------------------------------------------------
# historique des modifications
# 27/06/2005 - M.DJELLOULI - Ajout d'une Ligne Booking dans TREQJOB en Comptabilisation
# 25/11/2009 - JF VDV - Ajout job ESCJ8994, basculement de FIELD1_CF en mois+1
#---------------
#MODIFICATION   : [003]
#Auteur         : D.GATIBELZA
#Date           : 25/05/2010
#Version        : 10.1
#Description    : ESTDOM12363 Revoir le mécanisme de lancement de la comptabilisation des réglements, de lancement des inventaires
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
SSDCLO_LL=${1}
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6
CLODATMAX_D=${22}

# Launch applicative job ESCD9001
NJOB="ESCD9001"
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}


# DEBUT Modification MOD001  ------------------------------------------------
# Si l'on est en Variante 6 (Comptabilisation), on vérifie et ajoute une Ligne dans TREQJOB de type B (Booking)
# Le traitement doit passer avant la PuREqJOB_02
#. ${EST_PLAN}

if [ ${EST_VARIANTE} = "6"   ]
then
    # Launch applicative job ESCJ8992
    NJOB="ESCJ8992"
    ${DCMD}/ESCJ8992.cmd ${CRE_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CLODAT_D} ${CLODAT_D} ${DBCLO_D} ${CLODATMAX_D} 2>&1 | ${TEE}

    # Launch applicative job ESCJ8993
    # Dans ESCJ8993, on récupère le Paramètre du JOB ESCJ8992 (Switch Server)
    NJOB="ESCJ8993"
    ${DCMD}/ESCJ8993.cmd ${CRE_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CLODAT_D} ${CLODAT_D} ${DBCLO_D} ${CLODATMAX_D} ${SSDCLO_LL} 2>&1 | ${TEE}
fi

# Launch applicative job ESCJ8991
NJOB="ESCJ8991"
${DCMD}/ESCJ8991.cmd ${CRE_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CLODAT_D} ${DBCLO_D} ${CLODATMAX_D} 2>&1 | ${TEE}


if [ ${EST_VARIANTE} = "5"   ]
then
    # Launch applicative job ESCJ8994
    #[003] Ajout de CRE_D
    NJOB="ESCJ8994"
    ${DCMD}/ESCJ8994.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} 2>&1 | ${TEE}
fi

CHAINEND

