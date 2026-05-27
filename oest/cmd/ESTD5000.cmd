#!/bin/ksh
#==============================================================================
#nom de l'application          : 
#nom du source                 : ESTD5000cmd
#revision                      : $Revision:   1.8  $
#date de creation              : Juillet 2001
#auteur                        : O.GIRAUX
#references des spicifications : #################
#squelette de base             :
#------------------------------------------------------------------------------
#description : Suppression mutre et cmr dans BRET, BEST, BCTA, BTRT
#   
#
#------------------------------------------------------------------------------
#historique des modifications :
#   <jj/mm/aaaa>   <auteur>    <description de la modification>
# 
#=============================================================================
#set -x

. ${DUTI}/fctgen.cmd  

# Chain Initialization variable 
CHAININIT $0 $1


NJOB="ESTD5001"
${DCMD}/ESTD5001.cmd   2>&1 | ${TEE}

NJOB="ESTD5002"
${DCMD}/ESTD5002.cmd   2>&1 | ${TEE}

NJOB="ESTD5003"
${DCMD}/ESTD5003.cmd   2>&1 | ${TEE}

NJOB="ESTD5004"
${DCMD}/ESTD5004.cmd   2>&1 | ${TEE}

CHAINEND
