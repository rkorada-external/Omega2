#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INTEGRATION FICHIER des ecritures 
#				                    de service automatiques
# nom du script SHELL		  : ESFD0820.cmd
# revision			          : $Revision:   1.0  $
# date de creation		    : 11/04/2022
# auteur			            : S.Behague
# spira                   : 110557
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   File integration of assistance entries
#-----------------------------------------------------------------------------
# Job appelé par ESFD0820.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
# [01] - S.Behague 11/04/2024:spira:110557 - création
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

CRE_D=$1
BALSHYEA=$2
CLODAT=$3


NSTEP=${NJOB}_10
#---------------------------------------------------------------
LIBEL="Extraction of assumed contracts"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_LIST_TREPLINK.dat
BCP_QRY="exec BTRT..PsTRT_TREPLINK_01 '$CRE_D', '$BALSHYEA', '$CLODAT' "
BCP


NSTEP=${NJOB}_20
#---------------------------------------------------------------
#LIBEL="Extraction of retro contracts"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_LIST_TRREPLINK.dat
BCP_QRY="exec BRET..PsRET_TRREPLINK_01 '$CRE_D', '$BALSHYEA', '$CLODAT' "
BCP


JOBEND


