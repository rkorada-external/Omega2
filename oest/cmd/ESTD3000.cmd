#!/bin/ksh
#=============================================================================
# maj de l'application:           ESTIMATIONS - TRANSFERT INTER-SITES
# nom du script SHELL:            ESTD3000.cmd
# revision:                       $Revision: 1.5 $
# date de creation:               10/02/2009
# auteur:                         J.Ribot
# references des specifications : :spot:16765
#-----------------------------------------------------------------------------
# description
#
# extraction des fichiers gt et mise a dispo pour site recepteur
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#  05/06/2009  Roger Cassis      :spot:17532 -  Ajout possibilite de transmettre l'option Etablissement par parametre dans la ligne de commande
#  27/11/2009  R. Cassis         :spot:18415 -> Genere mouvements avec montants a zero dans best..tlifest pour contrats Vie : parm VIE_B
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
if test $3
then
   P_VIE_B=$3
fi

# Chain Initialization variables
CHAININIT $0 $1

#Entry parameters
set `GETPRM ${DPRM}/ESTD3000.prm`
BALSHEY_NF=${1}
BALSHTMTH_NF=${2}
TRANSFESB=${3}
VIE_B=${4}

# Giving Subsidiary, Processing option, Source by parm field
# parm parameters affected
if [ "${P_TRANSFESB}" != "" ]
then
   TRANSFESB=${P_TRANSFESB}
   echo "# --> Establissement option transmitted by processing command parm field : ${TRANSFESB}"  2>&1 | ${TEE}
fi
if [ "${P_VIE_B}" != "" ]
then
   VIE_B=${P_VIE_B}
   echo "# --> Life parameter option transmitted by processing command parm field : ${VIE_B}"  2>&1 | ${TEE}
fi

ECHO_LOG "=> REMOTE_SITE... = ${REMOTE_SITE}"  2>&1 | ${TEE}
ECHO_LOG "=> TRANSFESB..... = ${TRANSFESB}"  2>&1 | ${TEE}
ECHO_LOG "=> VIE_B......... = ${VIE_B}"  2>&1 | ${TEE}

# Launch applicative job ESTD3001                             generation des fichiers
NJOB="ESTD3001"
${DCMD}/ESTD3001.cmd  ${BALSHEY_NF} ${BALSHTMTH_NF} ${TRANSFESB} ${VIE_B} 2>&1 | ${TEE}

# Launch applicative job ESTD3002                             envoi des fichiers
NJOB="ESTD3002"
${DCMD}/ESTD3002.cmd ${TRANSFESB} 2>&1 | ${TEE}

CHAINEND
