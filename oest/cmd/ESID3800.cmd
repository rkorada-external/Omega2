#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#              			: Injection des GTA et GTR dans l'infocentre
# nom du script SHELL           : ESID3800.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 13/07/1999
# auteur                        : ASCOTT
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  Injection of rows into the infocenter
#
# Launch applicative jobs ESCD9001 ESID3801 3802
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#  25/03/04 M. DJELLOULI - Modification Epuration TTCLEDA - MOD01
#                          Fiches SPOT 5088 Optimisation inventaire
#                          Fiches SPOT 10076 Suivi BSAR TTECLEDA
#                          Appel du Nouveau JOB ESID3805.cmd (###### Nom a Confirmer avec Hélène)
#                             Le Fichier TTCLEA est Cumulé en Antériorité =< Date BiLAN
#                             et ajouts des écritures > Date du Bilan
#  07/12/05 M. DJELLOULI - Annulation Job Optimisation Inventaire (ESID3805)
#[03]  09/03/2011  R. CASSIS     :spot:21408 - On execute le ESID3802 si on est pas en variante 5 (cond3 != Y)
#                                On execute le ESID3801 2 fois avec mouvements du mois et avec curgt
#[04]  21/12/2011  R. Cassis     :spot:22859 - Si variante 5 ou 6 on execute pas ESID3801 Mvt
#[05]  18/04/2012  Roger Cassis  :spot:23802 - Ajout lettres dans NJOB pour ESID3801 pour possibilite de restart
#[06]  11/03/2015  Roger Cassis  :spot:28408 - For Mutre booking process, don't execute ESID3800
#[07]  11/08/2019  Mehdi NAJI    :spira:     - update ESID3800 to execute it separtly with C and M modes
#[08]  30/10/2019  M. NAJI       :spot:81838 - ajout du mode IFRS4 avec un IDF_CT
#[09]  25/02/2025  Mr JYP        : spira 112324 : rounding estimates amounts calculations
#[10]  05/04/2025  Mr JYP        : spira 112324 : rounding estimates amounts calculations
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1



export IDF_CT="$2"


if [ "${IDF_CT}" != "C" -a "${IDF_CT}" != "M"  ]
then
        # Launch applicative job ESCD9001
         NJOB="ESCD9001"
        . ${DCMD}/ESFD9001.cmd "${IDF_CT}"
	MODE=${ARG2_CHN_3}
fi





# MODE must be C or M




# Get entry parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
ICLODAT_D=$7
CLODAT_D=$8

set `GETPRM ${DPRM}/CLOSING_ROUNDING.prm`
export ROUNDING_FILTER_FLG=${1}
export ROUNDING_APPLY_MAX_AMT=${2}
export ROUNDING_EXCLUDE_LIMIT_AMT=${3}

NJOB="ESCD9001"
# Launch applicative job ESCD9001


if [ "${IDF_CT}" = "C" -o "${IDF_CT}" = "M"  ]
then
	MODE=${IDF_CT}
        # Launch applicative job ESCD9001
        NJOB="ESCD9001"
	export IDF_CT=""
	. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}
fi



if [ "${MODE}" != "C" -a "${MODE}" != "M" ]
then
        MAX_RETURN_CODE=2 # to force abort chain
        CHAINEND
fi

ECHO_LOG "#----> MODE ....................: ${MODE}"


if [ \( "${EST_VARIANTE}" -ne "5" -a "${EST_VARIANTE}" -ne "6" -a ${MODE} = "C" \) -o ${MODE} = "M"  ]
then
	# Launch applicative job ESID3801 Mouvements comptabilises
	NJOB="ESID3801"${MODE}
	${DCMD}/ESID3801.cmd ${CRE_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${ICLODAT_D} ${MODE} 2>&1 | ${TEE}

	# Launch applicative job for rounding split on TTECLEDR
	NJOB="ESFD3934${TYPEINV}"
	${DCMD}/ESFD3934.cmd 2>&1 | ${TEE}

fi

 
CHAINEND
