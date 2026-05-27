#!/bin/ksh
#===============================================================
#application name               : Clearing old data into BEST..TRTOSTAE
#source name                    : ESTD0110.cmd
#revision                       : $Revision:   1.1  $
#creation date                  : 26/09/2003
#author                         : Roger Cassis
#specifications reference       :
#                               :
#---------------------------------------------------------------
#description :
# Suppression de mouvements anterieurs a une date dans BEST..TRTOSTAE
#
# parameters :
# BALSHEY_NF = Min update date of movements to be kept into BEST..TRTOSTAE
#
#---------------------------------------------------------------
#modifications chronology  :
#   <jj/mm/aaaa>   <author>    <modification description>
#
#===============================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variable
CHAININIT $0 $1

# Entry parameters
set `GETPRM ${DPRM}/ESTD0110.prm`
BALSHEYEA_NF=${1}

# Launch applicative job ESTD0111
NJOB="ESTD0111"
${DCMD}/ESTD0111.cmd ${BALSHEYEA_NF} 2>&1 | ${TEE}

#End of chain
CHAINEND
