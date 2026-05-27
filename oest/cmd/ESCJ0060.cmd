#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Download tables to Binary files
# nom du script SHELL           : ESCJ0060.cmd
# revision                      : $Revision:   1.5  $
# date de creation              : 17/10/1997
# auteur                        : CGI
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Download tables to binary files
#-----------------------------------------------------------------------------
# historiques des modifications
#
#  G. BUISSON    08/09/2003    Ajout du parametre BALSHTMTH_NF dans le lancement de
#                              ESCJ0061.cmd pour eviter de prendre les lignes posterieures
#                              au mois bilan a traiter suite au deblocage des periodes
#                              exceptionnelles
#
#  28/09/2004 J. Ribot ajout ESCJ0064.cmd (Retro interne vie)
#[004]  19/05/2011  Roger Cassis   :spot:21408 - deplacement du job ESTD8991 de ESCJ0000 vers ESCJ0060
# [05] 26/11/2012 PPEZOUT :spot:24516 création, ECHANGES INTERNES POST OMEGA
#[10]  18/07/2017 Roger     :spira:63027 ajout CRE_D dans ESTD8991 pour le déclenchement du nettoyage des fichiers estimation journaliers
#[11]  04/04/2020 Linh     :spira:83013 ajout la creation de fichier mapping GAAP code
#===============================================================================
#set -x

#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_GTEP
# Output files
#	EST_FACMTRSH
#	EST_FBANTECL
#	EST_FCTRFIC
#	EST_FCURCVSNI
#	EST_FCURQUOT
#	EST_FDETTRS
#	EST_FGRP
#	EST_FLIBEL1
#	EST_FLIBEL2
#	EST_FLIFDRI
#	EST_FRETPAR
#	EST_FRETTRF
#	EST_FSEGMENT
#	EST_FSEGPAR
#	EST_FSOBBLOB
#	EST_FSSDACTR
#	EST_FSUBSID
#	EST_FTRSLNK
#	EST_GTEP
# EST_FLIFTHR
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd

#set -x

# Chain Initialization variables
CHAININIT $0 $1

# Recovers input parametrs
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=${SSDs0}
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}

# DEBUT Modification MOD001  ------------------------------------------------
# Si la Variante est 3 ou 7, on supprime les anciens fichiers d'inventaire
. ${EST_PLAN}

if [ ${EST_VARIANTE} = "7"   ] ||  [ ${EST_VARIANTE} = "3" ]
then
	# Launch applicative job ESTD8991
	#[10]
	NJOB="ESTD8991"
	${DCMD}/ESTD8991.cmd ${CRE_D} 2>&1 | ${TEE}
fi
# FIN Modification MOD001  --------------------------------------------------

# Launch applicative job ESCJ0061
NJOB="ESCJ0061"
${DCMD}/ESCJ0061.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} 2>&1 | ${TEE}

# Launch applicative job ESCJ0062
NJOB="ESCJ0062"
${DCMD}/ESCJ0062.cmd 2>&1 | ${TEE}

# Launch technical job TEFJ0011
NJOB="TEFJ0011"
${DUTI}/TEFJ0011.cmd 2>&1 | ${TEE}

# Launch applicative job ESCJ0063
NJOB="ESCJ0063"
${DCMD}/ESCJ0063.cmd INV 2>&1 | ${TEE}

EXTCHAIN=${EXTCHAIN_LIFE}

# Launch technical job TEFJ0011
NJOB="TEFJ0011"
${DUTI}/TEFJ0011.cmd 2>&1 | ${TEE}

# Launch applicative job ESCJ0064
NJOB="ESCJ0064"
${DCMD}/ESCJ0064.cmd 2>&1 | ${TEE}


# Launch applicative job ESCJ0065 : gaap code mapping creation
NJOB="ESCJ0067"
${DCMD}/ESCJ0067.cmd 2>&1 | ${TEE}

CHAINEND
