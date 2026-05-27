#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE POST-OMEGA
#                                 Restitution d'inventaire acceptation
# nom du script SHELL           : ESPD8000.cmd
# revision                      : 
# date de creation              : 08/04/2019
# auteur                        : Roger Cassis
# references des specifications : :spira:65656
#-----------------------------------------------------------------------------
# description
#    Rechargement de la table BEST..TCTREST
#
#-----------------------------------------------------------------------------
# historiques des modifications
#---------------
#[001] 30/03/2020 R. Cassis: spira:86536 Ajout parms CRE_D et ICLODAT_D
#[002] 29/04/2020 R. Cassis: spira:86536 -> non plus necessaire
#[003] 22/12/2020 : M.NAJI :. SPIRA 91531 
#						 	. Remplacement du mapping end par un mapping directement dans la table BES..TI17PERMFIL
#							. prise en compte de l'IDF_CT comme 2ème paramètres de la chaine 
#							. remplacement de ESCD9001 par ESPD9001
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters

IDF_CT="$2"

NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd "${IDF_CT}"

NJOB="ESPD8001"
${DCMD}/ESPD8001.cmd 2>&1 | ${TEE}

CHAINEND
