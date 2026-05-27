#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Internal Retro
# nom du script SHELL           : ESPD4000.cmd
# revision                      : $Revision:   1.0 $
# date de creation              : 26/11/2012
# auteur                        : PPEZOUT
# references des specifications : :spot:24516
#-----------------------------------------------------------------------------
# description: Internal Retro
#-----------------------------------------------------------------------------
# historiques des modifications
#[01] 26/11/2012 PPEZOUT :spot:24516 création, ECHANGES INTERNES POST OMEGA
#[02] 29/05/2013 PPEZOUT :spot:25171 Modifications Solvency
#[03] 28/04/2014 PPEZOUT :spot:26653 Echanges internes Solvency 
#[05] 02/11/2015 P PEZOUT :spot:29615 EST45 gestion des doubles bouclettes RETRO
#[06] 03/08/2017 R.Cassis :spira:63164 Le fichier GTEP a un nom specifique pour chaque type d'inventaire post-omega.
#[07] 30/07/2019 R.Cassis :spira:75645 Correction du parametre typeinv passé au ESCJ0065
#[08] 22/12/2020 : M.NAJI : . SPIRA 91531 
#							. prise en compte de l'IDF_CT comme 2ème paramètres de la chaine 
#							. remplacement de ESCD9001 par ESPD9001
#[09] 27/12/2021 M.NAJI: SPIRA 101295 add norme to prefix of chain
#[10] 22/04/2025 MZM : SPIRA 112870 BBNI- Undiscounted future transactions mapping : Ajout de l'IDF_CT en Parametre pour BBNI
#[11] 30/06/2025 MZM : SPIRA 112870 BBNI- Undiscounted future transactions mapping : Fix Ano Impact BBNI 4000 : Force Fichiers BBNI a vide
#[12] 04/07/2025 MZM : SPira 113135 BBNI - Missing retro and IO BBNI : Force EST_DLEIFTECLEDSIIEP at empty.dat only for BBNI Instance
#[12] 04/07/2025 MZM : US 5637 EBS INI  : Force EST_DLEIFTECLEDSIIEP at empty.dat  for INI AND  BBNI Instance

#===============================================================================
#set -x

#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#
# Output files
#
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd

export IDF_CT=$2

# Chain Initialization variables
CHAININIT $0 $1



NCHAIN_PARAM=`echo ${ARG2_CHN_2} `

NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd "${IDF_CT}" 

#[09]

  if [ "${IDF_CT}" = "EBS_ESPD4000" ]
 then	
export NCHAIN_PARAM=STDE
fi

if [ "${IDF_CT}" = "EBS_ESPD4000_BBNI" ]
then
	export NCHAIN_PARAM=BBNI
fi


if [ "${IDF_CT}" = "EBS_ESPD4000_INI" ]
then
	export NCHAIN_PARAM=INI
fi




if [ "${IDF_CT}" = "EBS_ESPD4000" ] 
then



export EXTCHAIN=${ENV_PREFIX}_ESPD2050${NORME_CF}
export EXTCHAIN_SII=${ENV_PREFIX}_ESPD3700${NORME_CF}

else

##export NCHAIN_PARAM=BBNI  || export NCHAIN_PARAM=INI 

export EXTCHAIN=${ENV_PREFIX}_${NCHAIN_PARAM}${NORME_CF}
###export EXTCHAIN_SII=${ENV_PREFIX}_${NCHAIN_PARAM}${NORME_CF}

fi

export NCHAIN_SHORT=${NCHAIN_PARAM}${NORME_CF}

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> IDF_CT...................: ${IDF_CT}"
ECHO_LOG "#===> TYPEINV..................: ${TYPEINV}"
ECHO_LOG "#===> NCHAIN_PARAM.............: ${NCHAIN_PARAM}"
ECHO_LOG "#===> NCHAIN_SHORT.............: ${NCHAIN_SHORT}"
ECHO_LOG "#===> EXTCHAIN.................: ${EXTCHAIN}"
ECHO_LOG "#===> EXTCHAIN_SII.............: ${EXTCHAIN_SII}"
ECHO_LOG "#===> REMOTE_SITE..............: ${REMOTE_SITE}"
ECHO_LOG ""
ECHO_LOG "#========================================================================="

#if [ "${EST_ESPD2550_COND1}" = "Y" ]
#then
#	TYPEINV=POS
#else
#	TYPEINV=POC
#fi
#
#if [ "${EST_ESPD2550_COND2}" = "Y" ]
#then
#	NORME=EBS
#else
#	NORME=IFRS
#fi

NJOB="TEFJ0011"
# Launch technical job TEFJ0011
# Fetching of TL files from the estimation chain ESID2550
${DUTI}/TEFJ0011.cmd 2>&1 | ${TEE}

# Launch applicative job ESCJ0063
# GTEP File generation
#[06] Ajout variable NORME #[09] Ajout de l'IDF_CT en Parametre pour BBNI
NJOB="ESCJ0063"
${DCMD}/ESCJ0063.cmd "${TYPEINV}"  "${NORME_CF}"  2>&1 | ${TEE}
# Launch applicative job ESCJ0065
# DLEIFTECLEDSIIEI File generation
EXTCHAIN=${EXTCHAIN_SII}

NJOB="TEFJ0011SII"
# Launch technical job TEFJ0011 for SII file
# Fetching of TL files from the estimation chain ESID2550 for SII 
${DUTI}/TEFJ0011.cmd 2>&1 | ${TEE}

#[07] #[09]
# Launch applicative job ESCJ0065
# DLEIFTECLEDSIIEI File generation
NJOB="ESCJ0065"
${DCMD}/ESCJ0065.cmd "${TYPEINV}"  2>&1 | ${TEE}

EXTCHAIN=${EXTCHAIN}


##[12]
if [ "${IDF_CT}" = "EBS_ESPD4000_BBNI" ]  || [ "${IDF_CT}" = "EBS_ESPD4000_INI" ]
then

cp $DFILP/empty.dat ${EST_DLEIFTECLEDSIIEP}

	if [ "${IDF_CT}" = "EBS_ESPD4000_BBNI" ] 
	then
		export NCHAIN_PARAM=BBNI
	else
		export NCHAIN_PARAM=INI
	fi
 
 
fi

#### Generation du GTEP STD et GTEP BBNI par filtre à partir du PERICASE BBNI
##
## if [ "${IDF_CT}" = "EBS_ESPD4000" ]
## then	
##
##${ESF_IADPERICASE_BBNI} 
## 
##NJOB="ESPD4002"
##${DCMD}/ESPD4002.cmd "${TYPEINV}"    2>&1 | ${TEE}
##
## fi

CHAINEND
