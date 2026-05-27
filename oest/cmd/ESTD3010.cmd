#!/bin/ksh
#=============================================================================
# maj de l'application:           ESTIMATIONS - TRANSFERT INTER-SITES
# nom du script SHELL:            ESTD3010.cmd
# revision:                       $Revision: 1.4 $
# date de creation:               10/02/2009
# auteur:                         J.Ribot
# references des specifications : :spot:16765
#-----------------------------------------------------------------------------
# description
#
# reception des fichiers créés par ESTD3000 et generation des fichiers GT CURGT STAGT ARCSTATGT
# pour les nouveaux contrats
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#  05/06/2009  Roger Cassis      :spot:17532 -  Ajout possibilite de transmettre l'option Etablissement par parametre dans la ligne de commande
#  03/12/2009  Roger Cassis      :spot:18415 -> Mise à jour parametres plus utilises
#
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Giving Subsidiary, Processing option, Source by parm field
# test if transmitted parameters
if test $2
then
   P_TRANSFESB=$2
fi

# Chain Initialization variables
CHAININIT $0 $1

#Entry parameters
set `GETPRM ${DPRM}/ESTD3010.prm`
BLCSHT_D=${1}
BALSHEY_NF=${2}
BALSHTMTH_NF=${3}
QTRLIM_NF=${4}
ESTIM_B=${5}
FORCEBILAN=${6}
TRANSFESB=${7}
GTRETRO=${8}
CREATION_GT=${9}

# Giving Subsidiary, Processing option, Source by parm field
# parm parameters affected
if [ "${P_TRANSFESB}" != "" ]
then
   TRANSFESB=${P_TRANSFESB}
   echo "# --> Establissement option transmitted by processing command parm field : ${TRANSFESB}"  2>&1 | ${TEE}
fi

ECHO_LOG "=> REMOTE_SITE... = ${REMOTE_SITE}"  2>&1 | ${TEE}
ECHO_LOG "=> TRANSFESB..... = ${TRANSFESB}"  2>&1 | ${TEE}

# Launch technical job TEFJ0011                              reception des fichiers
NJOB="TEFJ0011"
${DUTI}/TEFJ0011.cmd 2>&1 | ${TEE}

# Launch applicative job ESTD3011                           recuperation des fichiers et maj
NJOB="ESTD3011"
${DCMD}/ESTD3011.cmd  ${BLCSHT_D} ${BALSHEY_NF} ${BALSHTMTH_NF} ${ESTIM_B} ${FORCEBILAN} ${QTRLIM_NF} ${TRANSFESB} 2>&1 | ${TEE}

if [ ${GTRETRO} = "1" ]                                 # on traite les fichiers retro
then

	# Launch applicative job ESTD3012                           generation retro
	NJOB="ESTD3012"
	${DCMD}/ESTD3012.cmd  ${BLCSHT_D} ${BALSHEY_NF} ${BALSHTMTH_NF} ${ESTIM_B} ${FORCEBILAN} ${CREATION_GT} 2>&1 | ${TEE}

fi

# Saving Files GTx (GT)                                      save des fichiers gt
export NUMFILE="GT"
NJOB="ESTD3013"
${DCMD}/ESTD3013.cmd ${NUMFILE} ${GTRETRO} 2>&1 | ${TEE}
# -------------------------------------------------------------------------------

# Saving Files CURGTx (CURGT)                               save des fichiers curgt
export NUMFILE="CURGT"
NJOB="ESTD3013"
${DCMD}/ESTD3013.cmd ${NUMFILE} ${GTRETRO} 2>&1 | ${TEE}
# -------------------------------------------------------------------------------

# Saving Files STATGTx                                  save des fichiers statgt
export NUMFILE="STATGT"
NJOB="ESTD3013"
${DCMD}/ESTD3013.cmd ${NUMFILE} ${GTRETRO} 2>&1 | ${TEE}
# -------------------------------------------------------------------------------

# Saving Files ARCSTATGTx                                  save des fichiers arcstatgt
export NUMFILE="ARCSTATGT"
NJOB="ESTD3013"
${DCMD}/ESTD3013.cmd ${NUMFILE} ${GTRETRO} 2>&1 | ${TEE}
# -------------------------------------------------------------------------------

# Cat (GT , CURGT, ARCSTATGT) Files                       integration des fichiers
NJOB="ESTD3014"
${DCMD}/ESTD3014.cmd ${GTRETRO} 2>&1 | ${TEE}
# -------------------------------------------------------------------------------

CHAINEND
