#!/bin/ksh
#=============================================================================
# nom de l'application           : ESTIMATIONS -
#                                  Comptabilisation des ecritures de services Post Omega
# nom du script SHELL            : ESPD1800.cmd
# revision                       : $Revision: 1.2 $
# date de creation               : 16/06/2005
# auteur                         : J. Ribot
# references des specifications  : SPOT 5085
#-----------------------------------------------------------------------------
# description
#         Special entries booking
#
# Launch applicative jobs ESCD9001 ESPD1801 ESP1802
#
#-----------------------------------------------------------------------------
# historique des modifications
#_________________
#MODIFICATION    [001]
#Auteur:         D.GATIBELZA
#Date:           05/03/2009
#Version:        9.1
#Description:    ESTDOM16990 IFRS programme ESTM2069
#_________________
#MODIFICATION    [002]
#Auteur:         D.CHETBOUL 
#Date:           23/08/2011
#Version:        9.1
#Description:    :spot:22435 - test de valeur avant lancement de prg
#[003] 17/07/2012 R. Cassis    :spot:23802 SOLVENCY - Gestion oricod_ls
#[004] 26/10/2012 R. Cassis    :spot:24041 SOLVENCY - Gestion Types inventaires
#[005] 15/01/2018 R. Cassis    :spira:66790 SOLVENCY - Le POCI etait exécuté avec le POCE : corrrection des conditions d'execution
#[006] 22/12/2020 : M.NAJI : . SPIRA 91531 
#							. prise en compte de l'IDF_CT comme 2ème paramètres de la chaine 
#							. remplacement de ESCD9001 par ESPD9001
#[007] 04/01/2021 MZM          :spira:92735 Applying LOFACTOR TO AE
#[008] 29/01/2021 B.Lagha      :spira:91085 Remplacer le programme ESTM2569 par ESTM2069
#[009] 27/04/2022 MZM  	SPIRA: 104062 Ecart RA/RR view : Deplacement du LOfactor AE EBS Uniquement dans le Job ESPD1801
#[010] 04/07/2022 JBD   SPIRA : 104778 Build new closing for I17S norm
#[011] 29/07/2022 MZM  	SPIRA: 105825 AE I17 deplacement LOFACTOR DANS Bouclette (du ESFD2507 a ce nouveau JOB ESFD1803 dedie aux AE I17) 
#[012] 07/03/2025 MZM  	SPIRA: 111945 BBNI AE INTEGRATION
#[013] 07/10/2025 MZM   US5637 EBS INI AE INTEGRATION
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

export IDF_CT="$2"

# Launch applicative job ESCD9001
NJOB="ESFD9001"
. ${DCMD}/ESFD9001.cmd "${IDF_CT}" 

#[013] 


if  [ ${IDF_CT} = "I4I_ESPD1800" ]  ||  [ ${IDF_CT} = "EBS_ESPD1800" ]   ||  [ ${IDF_CT} = "EBS_ESPD1800_BBNI" ] ||  [ ${IDF_CT} = "EBS_ESPD1800_INI" ]
then

#[005]
# Launch applicative job ESPD1801
NJOB="ESPD1801${TYPEINV}"
${DCMD}/ESPD1801.cmd ${PARM_INVCONSO_D} ${PARM_CONSOYEA} ${TYPEINV} ${NORME_CF} 2>&1 | ${TEE}

fi

# [010] 
# [011] # Applying LOFACTOR TO AE ONLY FOR AE I17

if  [ ${IDF_CT} = "I17G_AET_RPO_I17" ]  || [ ${IDF_CT} = "I17S_AET_RPO_I17" ] ||  [ ${IDF_CT} = "I17P_AET_RPO_I17" ] ||  [ ${IDF_CT} = "I17L_AET_RPO_I17" ]                                                                                                                                                                                                                                            
then


NJOB="ESFD1803${TYPEINV}"
${DCMD}/ESFD1803.cmd ${PARM_INVCONSO_D} ${PARM_CONSOYEA} ${TYPEINV} ${NORME_CF} 2>&1 | ${TEE}	
	
fi


CHAINEND
