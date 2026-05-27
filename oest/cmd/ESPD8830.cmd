#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Traitement trimestriel et annuel des données Post-omega IFRS et EBS et maj tables Stat et estimés
# nom du script SHELL           : ESPD8830.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 05/07/2005
# auteur                        : J. Ribot
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Intégration des annulations trimestrielles et des ouvertures annuelles post-omega IFRS et EBS dans les fichiers CURGT et STATGT
#   Mise à jour des tables TACCTRTGT, TACCTRNE et TRTOSTAE
#   Mise à jour des tables Solvency
#-----------------------------------------------------------------------------
# historiques des modifications
# 02/11/2006   SPOT 12888 ajout parametres ESPD8833.cmd
#[008] P. Pezout   27/11/2012 :spot:24041 - Solvency 2
#[009] 20/02/2013 :spot:24875 - -=PhP=-  corrections pour la conso
#[010] 29/05/2013 PPEZOUT :spot:25171 Modifications Solvency
#[011] 29/01/2014 R. Cassis  :spot:26189 Affectation noms de fichiers selon type inventaire
#[012] 11/02/2014 R. cassis  :spot:26222 Reaffectation des variables selon plan1
#[014] 03/08/2017 R. Cassis :spira:63164 Le fichier GTEP a un nom specifique pour chaque type d'inventaire post-omega.
#[015] 28/03/2018 R. Cassis :spira:68016 Reorganisation des lancements de jobs et ajout ESPD8834 pour EBS
#[016] 26/04/2018 R. Cassis :spira:68514 Suppression affectation du COND2 utilisée lors du test
#[017] 15/12/2020 R. Cassis :spira:92386 - Ajout job ESFJ0011 pour traitement du split de l'ARCSTATGTA en compta annuelle
#[002] 22/12/2020 : M.NAJI : . SPIRA 91531 
#							. prise en compte de l'IDF_CT comme 2ème paramètres de la chaine 
#							. remplacement de ESCD9001 par ESPD9001
#[018] 15/12/2021 R. Cassis :spira:101117 - Suppression du traitement EBS dans ce shell.
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1
IDF_CT=$2


NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd "$IDF_CT"

ECHO_LOG "#==> EST_ESPD8830_COND1 = ${EST_ESPD8830_COND1}"
ECHO_LOG "#==> EST_ESPD8830_COND2 = ${EST_ESPD8830_COND2}"

#[015] [018] I4I cond kept for security if planning error
if [ ${NORME_CF} = "I4I" ]
then

	###################################
	ECHO_LOG "#==> Gestion Norme IFRS"
	###################################
	
	# Launch applicative job ESPD8831
	NJOB="ESPD8831"
	${DCMD}/ESPD8831.cmd ${PARM_CRE_D} ${PARM_BOOKING_D} ${PARM_CONSOYEA} ${PARM_CONSOMTH} ${PARM_RETTHRESHOLD_R} 2>&1 | ${TEE}

	# Launch applicative job ESPD8832
	NJOB="ESPD8832"
	${DCMD}/ESPD8832.cmd 2>&1 | ${TEE}

	# Launch applicative job ESPD8833
	NJOB="ESPD8833"
	${DCMD}/ESPD8833.cmd ${PARM_CONSOYEA} ${PARM_CONSOMTH} ${PARM_INVCONSO_D} ${PARM_CRE_D} 2>&1 | ${TEE}
	
	#[017]
	if [ ${PARM_IS_YEARLY} = "Y" ]
	then

		##########################################################################
		ECHO_LOG "#===> COMPTABILISATION ANNUELLE POS IFRS"
		##########################################################################

		# Launch applicative job ESFJ0011 - Split ARCSTATGTA
		NJOB="ESFJ0011"
		${DCMD}/ESFJ0011.cmd $DFILP/${ENV_PREFIX}_ESIX7000_ARCSTATGTA.dat 4 2>&1 | ${TEE}
	fi

#else
#
#	###################################
#	ECHO_LOG "#==> Gestion Norme EBS"
#	###################################
#	
#	# Launch applicative job ESPD8834 for SOCIAL EBS
#	NJOB="ESPD8834"
#	${DCMD}/ESPD8834.cmd ${PARM_CONSOYEA} ${PARM_CONSOMTH} ${PARM_INVCONSO_D} ${PARM_CRE_D} 2>&1 | ${TEE}
#
fi

CHAINEND
