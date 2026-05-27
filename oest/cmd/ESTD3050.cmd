#!/bin/ksh
#=============================================================================
# maj de l'application:           ESTIMATIONS - TRANSFERT INTER-SITES (PORTEFEUILLES)
# nom du script SHELL:            ESTD3050.cmd
# revision:                       $Revision: 1.4 $
# date de creation:               10/02/2009
# auteur:                         J.Ribot
# references des specifications : :spot:16765
#-----------------------------------------------------------------------------
# description
#
# extraction des fichiers gt et mise a dispo pour site recepteur et generation retraits portefeuilles
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#  05/06/2009  Roger Cassis      :spot:17532 -  Ajout possibilite de transmettre l'option Etablissement par parametre dans la ligne de commande
#  03/12/2009  Roger Cassis      :spot:18415 -> Mise à jour parametres plus utilises - Ajout transfert fichier Plan_Vie et parametre VIE_B
#[003] 03/11/2015 Roger Cassis  :spot:29514 -> Correction parametre transmis a ESTD3051 : VIE_B au lieu de TRANSFESB
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
set `GETPRM ${DPRM}/ESTD3050.prm`
BLCSHT_D=${1}
BALSHEY_NF=${2}
BALSHTMTH_NF=${3}
QTRLIM_NF=${4}
TRANSFESB=${5}
VIE_B=${6}


# Giving Subsidiary, Processing option, Source by parm field
# parm parameters affected
if [ "${P_TRANSFESB}" != "" ]
then
   TRANSFESB=${P_TRANSFESB}
   echo "# --> Establissement option transmitted by processing command parm field : ${TRANSFESB}"  2>&1 | ${TEE}
fi

ECHO_LOG "=> REMOTE_SITE... = ${REMOTE_SITE}"  2>&1 | ${TEE}
ECHO_LOG "=> TRANSFESB..... = ${TRANSFESB}"  2>&1 | ${TEE}

# Launch applicative job ESTD3051                             generation des fichiers
NJOB="ESTD3051"
${DCMD}/ESTD3051.cmd  ${VIE_B} 2>&1 | ${TEE}       #[003]

# Launch applicative job ESTD3052                             envoi des fichiers
NJOB="ESTD3052"
${DCMD}/ESTD3052.cmd 2>&1 | ${TEE}

# Launch applicative job ESTD3053                             generation retraits portefeuilles
NJOB="ESTD3053"
${DCMD}/ESTD3053.cmd  ${BLCSHT_D} ${BALSHEY_NF} ${BALSHTMTH_NF} ${QTRLIM_NF} ${TRANSFESB} ${VIE_B} 2>&1 | ${TEE}

# Saving Files GTx (GT)                                       sauvegarde des fichiers gt
NJOB="ESTD3054"
${DCMD}/ESTD3054.cmd GTA 2>&1 | ${TEE}
# -------------------------------------------------------------------------------

# Cat (GT , CURGT, ARCSTATGT) Files                           integration des fichiers
NJOB="ESTD3055"
${DCMD}/ESTD3055.cmd 2>&1 | ${TEE}
# -------------------------------------------------------------------------------

CHAINEND
