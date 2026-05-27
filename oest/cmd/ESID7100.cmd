#!/bin/ksh
#=============================================================================
# nom de l'application		    : ESTIMATIONS - CAC State File Extraction
# nom du script SHELL		    : ESID7100.cmd
# revision			            : 5.1
# date de creation		        : 06/10/2005
# auteur			            : M. DJELLOULI
# references des specifications	: Spot 11179
#-----------------------------------------------------------------------------
# description
#   Extraction of CAC STATE File
#-----------------------------------------------------------------------------
# Historical modification
# 24/01/2006 - M.DJELLOULI  - Correction Automatic/Manual
# - MANU By Automat       1 : Read Parameter From ESID7100.prm
#                         0 : Read Parameter From PARM0 (Estimation)
#
# 20/06/2007 J.Ribot        SPOT 14170 suppression test variante 6
# 25/06/2007 J.Ribot        SPOT 14170 ajout appel ESCD9001 pour gestion du GONOGO
# 22/04/2008 J.Ribot        SPOT 15168 ajout parametre TAUX pour sortie etats CAC au taux moyen et au taux cloture en un seul passage
#                                       remplace CLODATMAX_D=${22} par INVCONSO_D=${33} pour recherche dans TBOPAR
# 08/07/2008 D.GATIBELZA    SPOT 15168 je remplace aussi CLODATMAX_D par INVCONSO_D pour le lancement manuel
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

MANU=$2

# Manual Execution - Read Other Parameters from ESID7100.prm
if [ ${MANU} = "MANU"   ]
then
set `GETPRM ${DPRM}/ESID7100.prm`
CRE_D=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CLODATMAX_D=$4
CLODAT_D=$5
DBCLO_D=$6
EST_VARIANTE=$7
INVCONSO_D=${CLODATMAX_D}
else
# Get the parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$1
SSDCLO_LL=${1}
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6
INVCONSO_D=${33}

. ${EST_PLAN}

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}

fi

TAUX='TXC'

#  extraction avec conversion au taux moyen

#if [ ${EST_VARIANTE} = "6"   ]
#then
# Launch applicative job ESID7101
NJOB="ESID7101"
${DCMD}/ESID7101.cmd ${CRE_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${INVCONSO_D} ${CLODAT_D} ${DBCLO_D} ${TAUX} 2>&1 | ${TEE}

TAUX='TXM'

#  extraction avec conversion au taux cloture

#if [ ${EST_VARIANTE} = "6"   ]
#then
# Launch applicative job ESID7101
NJOB="ESID7101"
${DCMD}/ESID7101.cmd ${CRE_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${INVCONSO_D} ${CLODAT_D} ${DBCLO_D} ${TAUX} 2>&1 | ${TEE}

#fi

CHAINEND
