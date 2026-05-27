#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Inventaire vie
# nom du script SHELL		: ESFD2040.cmd
# revision			: $Revision:   1.5  $
# date de creation		: 27/10/97
# auteur			: C.G.I.
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   Life
#
# Launch applicative jobs ESCD9001,ESID2041,ESID2042,ESID2043
#-----------------------------------------------------------------------------
# historique des modifications
#
#   21/08/2003     J. Ribot   ajout 5è parametre appel ESID2041 pour gestion CNA
#   15/10/2003     J. Ribot   ${ICLODAT_MTH} a la place de BALSHTMTH_NF lancement 1er ESID2041
#[003] 05/03/2014  R. Cassis  :spot:25427 Changement noms NJOBS pour possibilité de Restart
#[004] 15/02/2016  DFI        :spot:30195 time shifted, trimestrialisation (PC)
#                                         et annualisation (PA) systematiques
#[005] 18/07/2016  MMA		  :SPOT30985: Integration de traitement pour RA
#				   RKE
#[006] 26/04/2019  SBE :spira:70044  Evolution quarterly
#[007] 03/02/2021  SBE :spira:93252 [TECH] Closing Life - Optimisation
#===============================================================================
#set -x

#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_CPLIFDRI
#	EST_CRIBLEANO
#	EST_DLVGTAR
#	EST_FACMTRSH
#	EST_FBANTECL
#	EST_FCPLACC
#	EST_FCURQUOT
#	EST_FGRP
#	EST_FSUBSID
#	EST_FVPLACEMT
#	EST_IAVPERICASE
#	EST_IRVPERICASE
#	EST_SEGRATANO
#	EST_SIGNANO
#	EST_SRGTC
#	EST_SRGTE
#	EST_SRGTEF
#	EST_VLIFEST195
# Output files
#	EST_DLVGTAA
#	EST_DLVGTAR
#	EST_DLVGTR
#	EST_SIGNANO
#	EST_SRGTE
#	EST_SRGTEF
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2
export IT=`echo $2 | awk -F"_" '{ print $2 }'`


NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd ${IDF_CT}


PARALLEL_JOB_INIT 3

	#Launch applicative job ESID2041
	NJOB="ESID2041_PC"
	PARALLEL_JOB "${DCMD}/ESID2041.cmd ${PARM_BALSHTYEA_NF} ${PARM_BALSHTMTH_NF} ${PARM_ICLODAT_D} ${PARM_CRE_D} ${ICLODAT_MTH} PC "

	ICLODAT2_ORIG=${ICLODAT2}
	export ICLODAT2="${BALSHTYEA_NF}1231"

	# Launch applicative job ESID2041 31/12
	NJOB="ESID2041_PA"
	PARALLEL_JOB "${DCMD}/ESID2041.cmd ${PARM_BALSHTYEA_NF} ${PARM_BALSHTMTH_NF} ${PARM_BALSHTYEA_NF}1231  ${PARM_CRE_D} 12 PA "

	NJOB="ESID2044_PA"
	PARALLEL_JOB "${DCMD}/ESID2044.cmd ${PARM_BALSHTYEA_NF} ${PARM_BALSHTMTH_NF} ${PARM_BALSHTYEA_NF}1231 ${PARM_CRE_D} 12 ${PARM_CLODAT_D} "

PARALLEL_JOB_END


export ICLODAT2="${ICLODAT2_ORIG}"


PARALLEL_JOB_INIT 4

	# Launch applicative job ESID2042
	NJOB="ESID2042_PC"
	PARALLEL_JOB "${DCMD}/ESID2042.cmd ${PARM_ICLODAT_D} ${PARM_CRE_D} ${PARM_BALSHTYEA_NF} ${PARM_BALSHTMTH_NF} ${PARM_DBCLO_D} PC"

	NJOB="ESID2045_PC"
	PARALLEL_JOB "${DCMD}/ESID2045.cmd ${PARM_BALSHTYEA_NF} ${PARM_BALSHTMTH_NF} ${PARM_ICLODAT_D} ${PARM_CRE_D} ${ICLODAT_MTH} PC"

	export ICLODAT2="${PARM_BALSHTYEA_NF}1231"

	# Launch applicative job ESID2042 31/12 
	NJOB="ESID2042_PA"
	PARALLEL_JOB "${DCMD}/ESID2042.cmd ${PARM_BALSHTYEA_NF}1231 ${PARM_CRE_D} ${PARM_BALSHTYEA_NF} ${PARM_BALSHTMTH_NF} ${PARM_DBCLO_D} PA"

	NJOB="ESID2045_PA"
	PARALLEL_JOB "${DCMD}/ESID2045.cmd ${PARM_BALSHTYEA_NF} ${PARM_BALSHTMTH_NF} ${PARM_BALSHTYEA_NF}1231  ${PARM_CRE_D} 12 PA"



PARALLEL_JOB_END


CHAINEND

