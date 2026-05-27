#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#              			        : Preparation des fichiers d'ecritures Locales pour OneGL
# nom du script SHELL           : ESLD3850.cmd
# revision                      : 
# date de creation              : 04/07/2017
# auteur                        : R. Cassis
# references des specifications : Spira:61508
#-----------------------------------------------------------------------------
# description:
#
#-----------------------------------------------------------------------------
# historiques des modifications
#---------------
#[001] 14/05/2018 R. Cassis :spira:68778 Extraction de l'année/mois bilan Local BLCSHTYEALOC_NF/BLCSHTMTHLOC_NF traité et envoi l'information au ESLD3851
#[002] 04/08/2025 Mr JYP : US 5559 SERQS RA/SAP phase1 
#[003] 02/09/2025 Mr JYP : US 6793 SERQS old archi parameters issue
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# test if transmitted parameter
if test $2
then
   P_PROCESSONEGL_CT=$2
fi

# Chain Initialization variables
CHAININIT $0 $1


# Get entry parameters
typeset -A TAB_PARAM
export TAB_PARAM
GETPRMO TAB_PARAM "$EST_PARAM"

#for key in "${!TAB_PARAM[@]}"; do
#        print "[ $key ] => [ ${TAB_PARAM[$key]} ]"
#done

#new variables from GETPRMO
N_SSDs0=${TAB_PARAM["SSDs0"]}
N_SSDs=${TAB_PARAM["SSDs"]}
N_BALSHTYEA_NF=${TAB_PARAM["BALSHTYEA_NF"]}
N_BALSHTMTH_NF=${TAB_PARAM["BALSHTMTH_NF"]}
N_CRE_D=${TAB_PARAM["CRE_D"]}
N_DBCLO_D=${TAB_PARAM["DBCLO_D"]}
N_ICLODAT_D=${TAB_PARAM["ICLODAT_D"]}
N_CLODAT_D=${TAB_PARAM["CLODAT_D"]}
N_INVCONSO_D=${TAB_PARAM["INVCONSO_D"]}
N_CONSOYEA=${TAB_PARAM["CONSOYEA"]}
N_CONSOMTH=${TAB_PARAM["CONSOMTH"]}
N_BLCSHTYEALOC_NF=${TAB_PARAM["BLCSHTYEALOC_NF"]}
N_BLCSHTMTHLOC_NF=${TAB_PARAM["BLCSHTMTHLOC_NF"]}
EST_SORT_CONDITION_AS=${TAB_PARAM["EST_SORT_CONDITION_AS"]}
EST_SORT_CONDITION_EU=${TAB_PARAM["EST_SORT_CONDITION_EU"]}
EST_SORT_CONDITION_AM=${TAB_PARAM["EST_SORT_CONDITION_AM"]}


set `GETPRM ${DPRM}/ESLD3850.prm`
PROCESSONEGL_CT=${1}

# parm parameters affected
if [ "${P_PROCESSONEGL_CT}" != "" ]
then
   PROCESSONEGL_CT=${P_PROCESSONEGL_CT}
   echo "# --> PROCESSONEGL_CT option transmitted by processing command parm field : ${PROCESSONEGL_CT}"  2>&1 | ${TEE}
fi

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${N_SSDs0} ${N_SSDs} ${N_BALSHTYEA_NF} ${N_BALSHTMTH_NF} ${N_CRE_D} ${N_DBCLO_D} ${N_CLODAT_D} ${N_ICLODAT_D}

#[001]
# Launch applicative job ESLD3851
NJOB="ESLD3851"
${DCMD}/ESLD3851.cmd ${N_CRE_D} ${N_CONSOYEA} ${N_CONSOMTH} ${N_INVCONSO_D} ${PROCESSONEGL_CT} ${N_BLCSHTYEALOC_NF} ${N_BLCSHTMTHLOC_NF} 2>&1 | ${TEE}

CHAINEND
