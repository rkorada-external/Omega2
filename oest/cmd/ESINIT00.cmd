#!/bin/ksh
#=============================================================================
# nom de l'application      : EXECUTION DE TRAITEMENT D'INITIALISATION de FICHIERS
# nom du script SHELL		: ESINIT00.cmd
#
# date de creation		    : 01/03/2011
# auteur			        : D.GATIBELZA
#-----------------------------------------------------------------------------
# description               : exécute les commandes batch du fichier envoyé en parametre
#
#-----------------------------------------------------------------------------
# historique des modifications
#---------------
#MODIFICATION   :
#Auteur         :
#Date           :
#Version        :
#Description    :
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Recovers input parametrs
set `GETPRM ${DPRM}/ESINIT00.prm` 
REF_SPOT=$1

# Launch applicative job ESINIT01
NJOB="ESINIT01"
${DCMD}/ESINIT01.cmd  ${REF_SPOT} 2>&1 | ${TEE}

CHAINEND
