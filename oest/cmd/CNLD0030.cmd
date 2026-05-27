#!/bin/ksh
#===============================================================
#application name               : Checkers-Loaders : Execution d'un fichier de commandes Unix et Awk
#source name                    : CNLD0031.cmd
#revision                       : $Revision:   1.0  $
#creation date                  : 09/12/2008
#author                         : Roger Cassis
#specifications reference       :
#---------------------------------------------------------------
#description :
#  :spot:16588 - Cette chaine permet d'exécuter un fichier de commandes Unix et (ou) awk
#  Le fichier doit etre copié sous ce nom ${ENV_PREFIX}_CNLD0030_SOURCE.dat dans /scor/livraison/tmp/destination
#  SOURCE = nom personnalisé à votre choix
#parameters :
#     SOURCE doit etre saisi en parametre dans la ligne de commande
#     ex : CNLD0030.cmd = majtoto 
#          (le fichier de commandes s'appelle alors ${ENV_PREFIX}_CNLD0030_majtoto.dat)
#
#---------------------------------------------------------------
#modifications chronology  :
#[001] 21/10/2011 Roger Cassis   :spot:22752 - Affinage du nom de fichier parametre
#[002] 20/08/2014 Roger Cassis   :spot:25773 - Adaptations to 2B, add CNLD0030.prm for server names
#[003] 17/04/2015 Roger Cassis   :spot:28638 - Adaptation configuration to new dbatools server adress
#===============================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variable
CHAININIT $0 $1

#No Entry parameters

# Launch applicative job CNLD0031.cmd - Fusion des fichiers C/L avec les fichiers GT
NJOB="CNLD0031"
###----------------------------------------------------------------------------
echo "*********************************************************"
echo "==> Parametre recu : $2"
echo "*********************************************************"
${DCMD}/CNLD0031.cmd $2 2>&1 | ${TEE}

CHAINEND
