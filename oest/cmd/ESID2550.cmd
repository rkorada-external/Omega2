#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESID2550.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 03/10/1997
# auteur                        : CGI
# references des specifications : ESTIEI23.doc
#-----------------------------------------------------------------------------
# description
#   Generation of the acceptance TL for retrocessionnaire subsidiaries
#-----------------------------------------------------------------------------
# historiques des modifications
#[01] 26/11/2012 PPEZOUT :spot:24516 ECHANGES INTERNES POST OMEGA
#[02] 02/11/2015 Florent :spot:29615 EST45 gestion des doubles bouclettes RETRO
#[03] 03/08/2017 R.Cassis :spira:64246 Le fichier GTEP a un nom specifique pour chaque type d'inventaire post-omega (NORME en parametre du ESID4001)
#[04] 30/10/2019 M. NAJI :spira:81838 	- ajout du mode IFRS4 avec un IDF_CT
#                   			-  suppression des jobs ESID2552 et ESID2553
#					- le ESID2550 travaille avec une copie des fichiers permanents DLREGTR DLRGTAA DLREMAJGTR car il sont en entr/sortie 
#[05] 12/05/2019 M. NAJI :spira:81838 	- activation du job ESID2552 dans la branche commune 
#[06] 28/05:2020 M. NAJI :spira:81838 	- retour a la solution [04] 
#[07] 02/11/2021 MZM     :spira:87852 Retrocession automatized Tax Estimates management : Generation des fichiers I4I
#[08] 08/04/2022 MZM     :spira:103683 Desactivation de 87852 et ou 10985 : Retrocession automatized Tax Estimates management : Generation des fichiers I4I
#===============================================================================
#set -x

#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_DLDVGTAR
#	EST_DLDVGTR
#	EST_DLEIGTAA
#	EST_FDETTRS
#	EST_FPLC
#	EST_FSSDACTR
#	EST_IRDVPERICASE
# Output files
#	EST_DLEIGTAA
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT="$2"

if [ "${IDF_CT}" = "I4_LIFE___" ]
then
        IDF_CT=""
fi



if [ "${IDF_CT}" != "" ]
then
	# Launch applicative job ESCD9001
	 NJOB="ESCD9001"
	. ${DCMD}/ESFD9001.cmd "${IDF_CT}"
	
fi
RMFIL "${DFILT}/*ESID3610*.dat"
# Get parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
ICLODAT_D=$7
CLODAT_D=$8
RETTHRESHOLD_R=${15}
BOUCLES=5
BOUCLE=1


if [ "${IDF_CT}" = "" ]
then
	# Launch applicative job ESCD9001
	 NJOB="ESCD9001"
	. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}  
fi

ECHO_LOG "#==> AVANT ls -lrt TESTS DEBUG ST_IRDVPERICASE .........:  $EST_IRDVPERICASE                 "

##ls -lrt ${EST_DLREGTR} ${EST_DLREMAJGTR} ${EST_DLRGTAA} 2>&1 | ${TEE}

TYPEINV=INV

ECHO_LOG "#==> TESTS DEBUG ST_IRDVPERICASE .........:  $EST_IRDVPERICASE                 "

export ARRET_BOUCLE=${DFILT}/${NCHAIN}_${IB}_ARRET_BOUCLE.dat
while [[ ${BOUCLE} -le ${BOUCLES} ]]; do
	# génération fichier retro RR => DLDVGTR
	NJOB="ESID2563_${BOUCLE}"
	${DCMD}/ESID2563.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${ICLODAT_D} ${CRE_D} ${TYPEINV} ${NORME} ${BOUCLE} 2>&1 | ${TEE}

	#arrêt boucle si EST_DLDVGTR est identique à la boucle précédente !!!!!!!!!
	if [[ -e ${ARRET_BOUCLE} ]]; then
		break
	fi

	# génération fichier accept interne AI intrasite DLRIGTAA
	NJOB="ESID2551_${BOUCLE}"
	${DCMD}/ESID2551.cmd ${RETTHRESHOLD_R} ${CRE_D} ${DBCLO_D} ${TYPEINV} ${NORME} ${BOUCLE} 2>&1 | ${TEE} 

	#[03]
	# génération fusion accept interne intrasite + GTEP intersite, enrichie => DLRGTA 
	NJOB="ESID4001_${BOUCLE}"
	${DCMD}/ESID4001.cmd ${CRE_D} ${TYPEINV} ${BOUCLE} ${NORME} 2>&1 | ${TEE}

	# génération de la retro auto => DLRE*GTR
	NJOB="ESID2504_${BOUCLE}"
	${DCMD}/ESID2504.cmd ${BALSHTYEA_NF} ${ICLODAT_D} ${TYPEINV} ${NORME} ${BOUCLE} 2>&1 | ${TEE} 

	let BOUCLE=BOUCLE+1
done

#[05]
if [ "${IDF_CT}" = "" ]
then

	# Launch applicative job ESID2552 if no Request F (not the last day of Social Post Omega)
	NJOB="ESID2552"
	${DCMD}/ESID2552.cmd ${TYPEINV} ${NORME} 2>&1 | ${TEE}
fi

#if [ "${EST_ESID2550_COND3}" = "Y" ]
#then
#	# Launch applicative job ESID2552 if no Request F (not the last day of Social Post Omega)
#	NJOB="ESID2553"
#	${DCMD}/ESID2553.cmd ${TYPEINV} ${NORME} 2>&1 | ${TEE}
#fi


  #  [08] Revert
	###[07]
	### Integration / Fusion des fichiers DLREGTAR_TAXMNGT et DLREGTR_TAXMNGT EBS ou I4I suivant closing
	###  
	## 
 	##NJOB="ESFD2506"
	##${DCMD}/ESFD2506.cmd ${BALSHTYEA_NF} ${ICLODAT_D} ${TYPEINV} ${NORME_CF} ${IDF_CT} 2>&1 | ${TEE} 
	


CHAINEND
