#!/bin/ksh
#===============================================================
#application name               : Clearing old data into BEST..TACCTRNE
#source name                    : ESTD0100.cmd
#revision                       : $Revision:   1.1  $
#creation date                  : 20/08/2003
#author                         : Roger Cassis
#specifications reference       :
#                               :
#---------------------------------------------------------------
#description :
# Suppression de mouvements anterieurs a une date dans BEST..TACCTRNE-TRTOSTAE-TACCTRTGT
#
# parameters : LSTUPD_D pour les tables TACCTRNE, TRTOSTAE, TACCTRGTGT
#              LAUNCH_D pour TLIFSTADIF
#---------------------------------------------------------------
#modifications chronology  :
#
#[001] 23/01/2015 R. Cassis :spot:28197 Archivage et nettoyage annuel de tables supplémentaires : TRTOSTAE, TACCTRGTGT et TLIFSTADIF
#===============================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Giving Balance Sheet Day BLCSHT_D by parm field
# test if transmitted parameter
if test $2
then
   P_BLCSHT_D=$2
fi

if test $3
then
   P_LAUNCH_D=$3
fi

# Chain Initialization variable
CHAININIT $0 $1

# Entry parameters
set `GETPRM ${DPRM}/ESTD0100.prm`
BLCSHT_D=${1}
LAUNCH_D=${2}

# Giving BLCSHT_D by parm field
# parm parameters affected
if [ "${P_BLCSHT_D}" != "" ]
then
   BLCSHT_D=${P_BLCSHT_D}
   echo "# --> Balance Sheet Day BLCSHT_D transmitted by processing command parm field : ${BLCSHT_D}"  2>&1 | ${TEE}
fi

# Giving LAUNCH_D by parm field
# parm parameters affected
if [ "${P_LAUNCH_D}" != "" ]
then
   LAUNCH_D=${P_LAUNCH_D}
   echo "# --> Balance Sheet Day LAUNCH_D transmitted by processing command parm field : ${LAUNCH_D}"  2>&1 | ${TEE}
fi

# Launch applicative job ESTD0101
NJOB="ESTD0101"
${DCMD}/ESTD0101.cmd ${BLCSHT_D} ${LAUNCH_D} 2>&1 | ${TEE}

#End of chain
CHAINEND
