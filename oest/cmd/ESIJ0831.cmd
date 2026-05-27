#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INTEGRATION FICHIER des ecritures 
#				                    de service automatiques
# nom du script SHELL		  : ESIJ0830.cmd
# revision			          : $Revision:   1.0  $
# date de creation		    : 07/05/2022
# auteur			            : S.Behague
# spira                   : 110557
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   File integration of assistance entries
#-----------------------------------------------------------------------------
# Job appelé par ESIJ0820.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
# historique des modifications
# [01] - S.Behague 29/04/2024:spira:110557 - création
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

CRE_D=$1

NSTEP=${NJOB}_10
#---------------------------------------------------------------
LIBEL="Update of assumed contracts"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_LIST_TREPLINK.dat
BCP_QRY="exec BTRT..PuTRT_TREPLINK_TSECIFRS_01 '$CRE_D'"
BCP

NSTEP=${NJOB}_20
#---------------------------------------------------------------
LIBEL="Update of Retro contracts"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_LIST_TRREPLINK.dat
BCP_QRY="exec BRET..PuRET_TRREPLINK_TRETIFRS_01 '$CRE_D'"
BCP




JOBEND


