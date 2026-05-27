#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Restitution d'inventaire acceptance
# nom du script SHELL           : ESID8000.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 21/10/1997
# auteur                        : CGI
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#   Chain of acceptance closing period restitution
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 18/04/2012 Roger Cassis  :spot:23802 - Ajout colonne PRS_CF pour Solvency
#[002] 21/09/2018 Roger Cassis  :spira:70467 - Envoi ICLODAT au job ESID8001 pour traitement du FCTREST
#[003] 27/04/2020 R. Cassis     :spira:86503:86536 - Envoit le CRE_D au job ESID8001 -> non pas necessaire
#===============================================================================
#set -x

#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_FBESTCESSION
#	EST_FBESTCONPAR
#	EST_FCTREST
#	EST_FCURQUOT
#	EST_FLOARAT
#	EST_FPRMLOA
#	EST_FT
#	EST_FTRSLNK
#	EST_IADPERICASE
#	EST_TOTGTAA
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
ICLODAT_D=$7
CLODAT_D=$8

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

#[002]
NJOB="ESID8001"
${DCMD}/ESID8001.cmd ${BALSHTYEA_NF} 2>&1 | ${TEE}

# Job launched only in closing period 31/12
if [ ${EST_ESID8000_COND1} = "Y" ]
then

	# Launch applicative job ESID8002
	NJOB="ESID8002"
	${DCMD}/ESID8002.cmd  2>&1 | ${TEE}

fi

CHAINEND
