#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - COMMUNS
# nom du script SHELL           : ESCJ0000.cmd
# revision                      : $Revision: 1.3 $
# date de creation              : 22/09/1997
# auteur                        : CGI
# references des specifications : ESTPARAM.doc
#-----------------------------------------------------------------------------
# description
#  Preparing parametrs files and planning executions
# parameters: 4
#    1 - CRE_D        -> overides DATE_T of ESCJ0000.prm to generate plan-parms.
#    2 - PRM          -> If 'p' or 'P' inserted, the CRE_D sent will update ESCJ0000.prm with this value
#    3 - DBCLO_D      -> If not null, it's DBCLO_D value to plan a closing      : date trimestre
#    4 - BALSHTMTH_NF -> If not null, it's BALSHTMTH_NF value to plan a closing : mois bilan
#
#    ex : ESCJ0000.cmd = 20160205 p
#         ESCJ0000.cmd = 20160305 p 20160331 3
#-----------------------------------------------------------------------------
# historiques des modifications
# Modifié le            Par                 Desc.
# 07-04-2004            M. DJELLOULI        On supprime les Fichiers de l'inventaire
#                                           avant execution si Variante 3 ou 7
#                                           Modification MOD0001
# 08-11-2004            M. DJELLOULI        Mise en Place de ESTD8991.cmd en place de ESCJ0002.cmd
#---------------
#MODIFICATION   : [003]
#Auteur         : D.GATIBELZA
#Date           : 23/08/2010
#Version        : 10.0
#Description    : ESTDOM19070 V10 scheduler pour le lancement des inventaires
#[004]  19/05/2011  Roger Cassis   :spot:21408 - deplacement job ESTD8991 dans ESCJ0060
#[005]  16/12/2013  Roger Cassis   :spot:25427 - execution ESCJ0011 au lieu de ESCJ0010
#[006]  10/02/2016  Roger Cassis   :spot:30163 - Option de passage par date CRE_D dans le parm au format AAAAMMJJ et de planification
#[007]  08/10/2020  M.NAJI: Spira 87596 Mise à joure de TREQJOBPLAN si une demande est faite dans TI17REQJOBPLAN
#[008]  08/12/2020  M.NAJI: Spira 87596 Supression de la mise a joure de TREQJOBPLAN si une demande est faite dans TI17REQJOBPLAN
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

#[006]
# test if option CRE_D sent by parm
P_CRE_D=""
P_PRM=""
P_DBCLO_D=""
P_BALSHTMTH_NF=""
plan="N"
if test $2
then
	P_CRE_D=$2
	if test $3
	then
		P_PRM=$3
		if test $4
		then
			P_DBCLO_D=$4
			if test $5
			then
				P_BALSHTMTH_NF=$5
				plan="Y"
			fi
		fi
	fi
fi


# Chain Initialization variables
CHAININIT $0 $1

#Get input parameters
set `GETPRM ${DPRM}/ESCJ0000.prm` 
CRE_D=$1

#[006]
if [ "${P_CRE_D}" != "" ]
then
   CRE_D=${P_CRE_D}
	ECHO_LOG "#========================================================================="
	ECHO_LOG "#===> CRE_d ${CRE_D} sent by parm overides .prm data"
	ECHO_LOG "#========================================================================="
	if [ "${P_PRM}" = "p" -o "${P_PRM}" = "P" ]
	then
   	# Modification du .prm
		awk -v var="DATE_T" -v valeur="${CRE_D}" '{split($0,tab," "); if (tab[1] == var) print var " " valeur; else print $0}' ${DPRM}/ESCJ0000.prm > ${DFILT}/${NJOB}_${IB}_ESCJ0000_prm.log
		cp ${DFILT}/${NJOB}_${IB}_ESCJ0000_prm.log ${DPRM}/ESCJ0000.prm
		ECHO_LOG "#========================================================================="
		ECHO_LOG "#===> .prm modifié a ${CRE_D} demandé par l'option P"
		ECHO_LOG "#========================================================================="
	fi
fi

#[007] Mise à joure de TREQJOBPLAN si une demande est faite dans TI17REQJOBPLAN [005]
NJOB="ESCJ0004"
${DCMD}/ESCJ0004.cmd ${CRE_D} 2>&1 | ${TEE}

#[006]
if [ "${plan}" = "Y" ]
then
	# Launch applicative job ESCJ0003 to plan a closing
	NJOB="ESCJ0003"
	${DCMD}/ESCJ0003.cmd ${P_CRE_D} ${P_DBCLO_D} ${P_BALSHTMTH_NF} 2>&1 | ${TEE}
fi

#[003] Nettoyage TREQJOB [005]
NJOB="ESCJ0011"
${DCMD}/ESCJ0011.cmd ${CRE_D} 2>&1 | ${TEE}

#[003] Launch applicative job ESCJ0002
NJOB="ESCJ0002"
${DCMD}/ESCJ0002.cmd ${CRE_D} 2>&1 | ${TEE}

#[003] Demandes Z planifiees ( Chargement des tables )
NJOB="ESID0081"
${DCMD}/ESID0081.cmd "vide" "vide" ${CRE_D} 2>&1 | ${TEE}

# Launch applicative job ESCJ0001
NJOB="ESCJ0001"
${DCMD}/ESCJ0001.cmd ${CRE_D} 2>&1 | ${TEE}

CHAINEND

