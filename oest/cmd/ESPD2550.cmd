#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESPD2550.cmd
# revision                      : $Revision:   1.0 $
# date de creation              : 26/11/2012
# auteur                        : PPEZOUT
# references des specifications : :spot:24516
#-----------------------------------------------------------------------------
# description
#   Generation of the acceptance TL for retrocessionnaire subsidiaries
#-----------------------------------------------------------------------------
# historiques des modifications
#[03] 28/04/2014 PPEZOUT :spot:26653 Echanges internes Solvency 
#[01] 26/11/2012 PPEZOUT :spot:24516 création, ECHANGES INTERNES POST OMEGA
#[02] 29/05/2013 PPEZOUT :spot:25171 Modifications Solvency
#[03] 28/04/2014 PPEZOUT :spot:26653 Echanges internes Solvency 
#[04] 02/11/2015 Florent :spot:29615 EST45 gestion des doubles bouclettes RETRO
#[05] 17/03/2016 Roger   :spot:30151 Suppression des appels aux jobs ESID2552-53 qui sont exécutés maintenant dans le ESPD2050.
#[06] 03/08/2017 R.Cassis :spira:63164 Le fichier GTEP a un nom specifique pour chaque type d'inventaire post-omega.
#[07] 12/02/2020 MZM      :spira:71539 Le fichier des OVERRIDES COMMISSION EST_DLREGTAR_OVR est merge avec le EST_DLREGTAR pour genere
#[08] 22/12/2020 : M.NAJI : . SPIRA 91531 
#							. prise en compte de l'IDF_CT comme 2ème paramètres de la chaine 
#							. remplacement de ESCD9001 par ESPD9001
#[09] 07/04/2021 MZM      :spira:90073 Le fichier des DAC IFRS17 est merge avec le EST_DLREGTAR pour genere EST_DLREGTAR
#[10] 09/09/2021 MZM      :spira:98725 Ne plus executer ESID2507 en I4I (suite Ano de PRD)
#[11] 05/10/2021 MZM      :spira:87852 Retrocession automatized Tax Estimates management : Generation des fichiers
#[12] 09/12/2021 MZM      :spira:97734 APPLICATION LORETROFACTOR JUSTE APRES LES CESSION (ESID2504)
#[13] 28/02/2022 MZM      :spira:101275 OVERRINDING DANS BOUCLETTE   
#[14] 08/04/2022 MZM      :spira:103683 Desactivation de 87852 et ou 10985 : Retrocession automatized Tax Estimates management : Generation des fichiers
#[15] 04/07/2025 MZM      :SPira 113135 BBNI - Missing retro and IO BBNI : ADD The ESID2552 only for BBNI Instance
#[16] 10/10/2025 MZM      :US 5637 EBS INI  - Instance

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
#	EST_DLCUMGTAATOT
# Output files
#	EST_DLEIGTAA
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2

BOUCLES=5
BOUCLE=1

NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd "${IDF_CT}"



ICLODAT_D=${PARM_INVCONSO_D}
BALSHTYEA_NF=${PARM_CONSOYEA}

  #[08]
	# Merge  du DAC IFRS et du DLGTAA ===>  EST_DLGTAA 
 if [ "${IDF_CT}" = "EBS_ESPD2550" ] 
 then	
		ECHO_LOG "#===> IDF_CT ......007..............: ${IDF_CT} " 
 
	NJOB="ESFD2508"
	${DCMD}/ESFD2508.cmd  ${PARM_CONSOYEA} ${PARM_INVCONSO_D} ${TYPEINV}  ${IDF_CT}  2>&1 | ${TEE} 2>&1 | ${TEE} 
 fi


export ARRET_BOUCLE=${DFILT}/${NCHAIN}_${IB}_ARRET_BOUCLE.dat
while [[ ${BOUCLE} -le ${BOUCLES} ]]; do
	# génération fichier retro RR => DLDVGTR
	NJOB="ESID2563_${BOUCLE}"
	${DCMD}/ESID2563.cmd ${BALSHTYEA_NF} ${PARM_BALSHTMTH_NF} ${ICLODAT_D} ${PARM_CRE_D} ${TYPEINV} ${NORME_CF} ${BOUCLE} 2>&1 | ${TEE}

	#arrêt boucle si EST_DLDVGTR est identique à la boucle précédente !!!!!!!!!
	if [[ -e ${ARRET_BOUCLE} ]]; then
		break
	fi

	# génération fichier accept interne AI intrasite DLRIGTAA
	NJOB="ESID2551_${BOUCLE}"
	${DCMD}/ESID2551.cmd ${PARM_RETTHRESHOLD_R} ${PARM_CRE_D} ${PARM_DBCLO_D} ${TYPEINV} ${NORME_CF} ${BOUCLE} 2>&1 | ${TEE} 

	#[06]
	# génération fusion accept interne intrasite + GTEP intersite, enrichie => DLRGTA
	NJOB="ESID4001_${BOUCLE}"
	${DCMD}/ESID4001.cmd ${CRE_D} ${TYPEINV} ${BOUCLE} ${NORME_CF} 2>&1 | ${TEE}

	# génération de la retro auto => DLRE*GTR
	NJOB="ESID2504_${BOUCLE}"
	${DCMD}/ESID2504.cmd ${BALSHTYEA_NF} ${ICLODAT_D} ${TYPEINV} ${NORME_CF} ${BOUCLE} 2>&1 | ${TEE} 
	
#[10]

##if [ ${NORME_CF} != "I4I" ]
##then

#[13] OVERRIDING DANS BOUCLETTE

if [ "${VNORME}" != "I4I" -a "${VNORME}" != "" ]
then

	# Merge  du EST_DLREGTAR et du EST_DLREGTAR_OVR
	NJOB="ESID2507"
	${DCMD}/ESID2507.cmd ${BALSHTYEA_NF} ${ICLODAT_D} ${TYPEINV} ${NORME_CF}  2>&1 | ${TEE} 

fi	
	

	let BOUCLE=BOUCLE+1
done

#[17] DEB

  if [ "${IDF_CT}" = "EBS_ESPD2550" ]
 then	
export NCHAIN_PARAM=STDE
 fi
  if [ "${IDF_CT}" = "EBS_ESPD2550_BBNI" ]
 then	
export NCHAIN_PARAM=BBNI
 fi
 
##[16] 
if [ "${IDF_CT}" = "EBS_ESPD2550_INI" ]
then	
	export NCHAIN_PARAM=EINI
fi


###[15]

if [ "${IDF_CT}" = "EBS_ESPD2550_BBNI" ] || [ "${IDF_CT}" = "EBS_ESPD2550_INI" ] 
then	

OLD_CHAIN=${NCHAIN}
export NCHAIN=${ENV_PREFIX}_${NCHAIN_PARAM}${NORME_CF}

# Launch applicative job ESID2552 if no Request F (not  the last day of Social Post Omega)
	NJOB="ESID2552"
	${DCMD}/ESID2552.cmd ${TYPEINV} ${IDF_CT}  2>&1 | ${TEE}

export NCHAIN=${OLD_CHAIN}

#[15] FIN

fi






	# Generation du fichier DAC IFRS17 : Merge des Fichiers EST_DLCUMGTAATOT   filtres sur "1143060I" 
	#                                                       Assumed EST_DLGTAA filtres sur "1143060I" 
	#                                                       Retro  EST_DLGTAR  filtres sur "2143060I"  
 if [ "${IDF_CT}" = "EBS_ESPD2550" ] 
 then	
 
	NJOB="ESFD2509"
	${DCMD}/ESFD2509.cmd ${BALSHTYEA_NF} ${ICLODAT_D} ${TYPEINV} ${NORME_CF} ${IDF_CT} 2>&1 | ${TEE} 
	
 fi

#[21] Revert
	###[11]
	### Integration / Fusion des fichiers DLREGTAR_TAXMNGT et DLREGTR_TAXMNGT EBS ou I4I suivant closing
	###  
	## 
 	##NJOB="ESFD2506"
	##${DCMD}/ESFD2506.cmd ${BALSHTYEA_NF} ${ICLODAT_D} ${TYPEINV} ${NORME_CF} ${IDF_CT} 2>&1 | ${TEE} 
	


CHAINEND
