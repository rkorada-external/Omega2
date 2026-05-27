#!/bin/ksh
#=============================================================================
# maj de l'application:          ESTIMATIONS - TRANSFERT PORTEFEUILLE INTER-SITES
#                                              ENTREES et RETRAIT PORTEFEUILLE
# nom du script SHELL:           ESTD3000.cmd
# revision: $Revision:           1.1  $
# date de creation:              29/11/2006
# auteur:                        J.Ribot
# references des specifications : SPOT EST13427
#-----------------------------------------------------------------------------
# description
#   Transfert Amerique du Sud
#
# les fichiers créés par ESTD3000 sont cumulés aux fichiers GT CURGT STAGT ARCSTATGT par ESTD3010
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#   <JJ/MM/AAAA>   <Auteur >    <Description de la modification>
#
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

#Entry parameters
set `GETPRM ${DPRM}/ESTD3020.prm`
BLCSHT_D=${1}
BALSHEY_NF=${2}
BALSHTMTH_NF=${3}
ESTIM_B=${4}
FORCEBILAN=${5}
GTRETRO=${6}
ENVOI=${7}
RECEPT=${8}


if [ ${ENVOI} = "1" ]             # on lance les traitements de generation et envoi des fichiers
then

# Launch applicative job ESTD3021                             envoi des fichiers
NJOB="ESTD3021"
${DCMD}/ESTD3021.cmd  ${BLCSHT_D} ${BALSHEY_NF} 2>&1 | ${TEE}

fi


if [ ${RECEPT} = "1" ]             # on lance les traitements de reception et integration des fichiers
then

# Launch applicative job ESTD3022                           recuperation des fichiers et maj
NJOB="ESTD3022"
${DCMD}/ESTD3022.cmd  ${BLCSHT_D} ${BALSHEY_NF} ${BALSHTMTH_NF} ${ESTIM_B} ${FORCEBILAN} 2>&1 | ${TEE}

fi

CHAINEND
