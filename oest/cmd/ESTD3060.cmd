#!/bin/ksh
#=============================================================================
# maj de l'application:           ESTIMATIONS - TRANSFERT INTER-SITES (PORTEFEUILLES)
# nom du script SHELL:            ESTD3060.cmd
# revision:                       $Revision: 1.1.1.1 $
# date de creation:               10/02/2009
# auteur:                         J.Ribot
# references des specifications : :spot:16765
#-----------------------------------------------------------------------------
# description
#
# reception des fichiers créés par ESTD3050 et generation entrees portefeuilles
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#   05/06/2009   Roger Cassis      :spot:17532 -  Ajout possibilite de transmettre l'option Etablissement par parametre dans la ligne de commande
#   17/11/2009   Roger Cassis      :spot:18415 -  Copie reconduction emetteur en date 01/01 puis annulation 02/01 pour contrats Vie parm VIE_B
#   08/02/2010   Roger Cassis      :spot:18937 -  Passage parametre TRANSFESB dans job ESTD3061.
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
set `GETPRM ${DPRM}/ESTD3060.prm`
BLCSHT_D=${1}
BALSHEY_NF=${2}
BALSHTMTH_NF=${3}
QTRLIM_NF=${4}
ESTIM_B=${5}
FORCEBILAN=${6}
TRANSFESB=${7}
GTRETRO=${8}
CREATION_GT=${9}
VIE_B=${10}

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

# Launch technical job TEFJ0011                              reception des fichiers
NJOB="TEFJ0011"
${DUTI}/TEFJ0011.cmd 2>&1 | ${TEE}

# Launch applicative job ESTD3061                           generation entrees portefeuilles
NJOB="ESTD3061"
${DCMD}/ESTD3061.cmd  ${BLCSHT_D} ${BALSHEY_NF} ${BALSHTMTH_NF} ${ESTIM_B} ${FORCEBILAN} ${QTRLIM_NF} ${TRANSFESB} ${VIE_B} ${TRANSFESB} 2>&1 | ${TEE}

# Saving Files GTx (GT)                                      save des fichiers gt
export NUMFILE="GT"
NJOB="ESTD3062"
${DCMD}/ESTD3062.cmd ${NUMFILE} 2>&1 | ${TEE}
# -------------------------------------------------------------------------------

# Saving Files CURGTx (CURGT)                               save des fichiers curgt
export NUMFILE="CURGT"
NJOB="ESTD3062"
${DCMD}/ESTD3062.cmd ${NUMFILE} 2>&1 | ${TEE}
# -------------------------------------------------------------------------------

# Saving Files STATGTx                                  save des fichiers statgt
export NUMFILE="STATGT"
NJOB="ESTD3062"
${DCMD}/ESTD3062.cmd ${NUMFILE} 2>&1 | ${TEE}
# -------------------------------------------------------------------------------

# Cat (GT , CURGT, ARCSTATGT) Files                       integration des fichiers
NJOB="ESTD3063"
${DCMD}/ESTD3063.cmd ${GTRETRO} ${CREATION_GT} 2>&1 | ${TEE}
# -------------------------------------------------------------------------------

CHAINEND
