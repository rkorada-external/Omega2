#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Inventaire vie
# nom du script SHELL		: ESID2040.cmd
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
#[007] 27/02/2021  M.NAJI "spira 91531 manque un # Ã  ligne 84"
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


IDF_CT=$2
export IT=`echo $2 | awk -F"_" '{ print $2 }'`

# Chain Initialization variables
CHAININIT $0 $1

# Get the parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
ICLODAT_D=$7
CLODAT_D=$8

# Launch applicative job ESCD9001
NJOB="ESCD9001"
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}


# Launch applicative job ESFD2041
NJOB="ESFD2041"
${DCMD}/ESFD2041.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${ICLODAT_D} ${CRE_D} ${ICLODAT_MTH} PC 2>&1 | ${TEE}  #[004]

# Launch applicative job ESFD2042
NJOB="ESFD2042"
${DCMD}/ESFD2042.cmd ${ICLODAT_D} ${CRE_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${DBCLO_D} 2>&1 | ${TEE}

# Launch applicative job ESID2043
NJOB="ESID2043"
LOOP_JOB_SSD ${DCMD}/ESID2043.cmd 99 2>&1 | ${TEE}

# # [005]
NJOB="ESFD2045"
${DCMD}/ESFD2045.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${ICLODAT_D} ${CRE_D} ${ICLODAT_MTH} PC 2>&1 | ${TEE}  

# # n oublier pas de copier certains fichier du DFILI avec la date ${BALSHTMTH_NF} "${BALSHTYEA_NF}1231" 
# if [ "${ICLODAT_MTH}" != "12"   ]  #[004]
# then                               #[004]
if [ "X${IT}" == "XY" ]
then
	EST_SRGTE_PCD=`echo ${EST_SRGTE_PC} | sed "s/${IT}_/_/"`
	cp -v $EST_SRGTE_PC $EST_SRGTE_PCD
	EST_TRACEFILED=`echo ${EST_TRACEFILE} | sed "s/${IT}_/_/"`
	cp -v $EST_TRACEFILE $EST_TRACEFILED
	EST_DLVGTAA_PCD=`echo ${EST_DLVGTAA_PC} | sed "s/${IT}_/_/"`
	cp -v $EST_DLVGTAA_PC $EST_DLVGTAA_PCD
	EST_DLVGTAR_PCD=`echo ${EST_DLVGTAR_PC} | sed "s/${IT}_/_/"`
	cp -v $EST_DLVGTAR_PC $EST_DLVGTAR_PCD
	EST_DLVGTR_PCD=`echo ${EST_DLVGTR_PC} | sed "s/${IT}_/_/"`
	cp -v $EST_DLVGTR_PC $EST_DLVGTR_PCD
	EST_SIGNANOD=`echo ${EST_SIGNANO} | sed "s/${IT}_/_/"`
	cp -v $EST_SIGNANO $EST_SIGNANOD
	EST_SRGTR_VENTILD=`echo ${EST_SRGTR_VENTIL} | sed "s/${IT}_/_/"`
	cp -v $EST_SRGTR_VENTIL $EST_SRGTR_VENTILD
	EST_SRGTE_PCD=`echo ${EST_SRGTE_PC} | sed "s/${IT}_/_/"`
	cp -v $EST_SRGTE_PC $EST_SRGTE_PCD
	EST_SRGTEF_PCD=`echo ${EST_SRGTEF_PC} | sed "s/${IT}_/_/"`
	cp -v $EST_SRGTEF_PC $EST_SRGTEF_PCD
	EST_CMPCALC_PCD=`echo ${EST_CMPCALC_PC} | sed "s/${IT}_/_/"`
	cp -v $EST_CMPCALC_PC $EST_CMPCALC_PCD
	EST_SRGTR_VENTILD=`echo ${EST_SRGTR_VENTIL} | sed "s/${IT}_/_/"`
	cp -v $EST_SRGTR_VENTIL $EST_SRGTR_VENTILD
	EST_SRGTE_VENTIL_PCD=`echo ${EST_SRGTE_VENTIL_PC} | sed "s/${IT}_/_/"`
	cp -v $EST_SRGTE_VENTIL_PC $EST_SRGTE_VENTIL_PCD
	EST_SRGTEF_VENTIL_PCD=`echo ${EST_SRGTEF_VENTIL_PC} | sed "s/${IT}_/_/"`
	cp -v $EST_SRGTEF_VENTIL_PC $EST_SRGTEF_VENTIL_PCD
	EST_SRGTE_SRV_PCD=`echo ${EST_SRGTE_SRV_PC} | sed "s/${IT}_/_/"`
	cp -v $EST_SRGTE_SRV_PC $EST_SRGTE_SRV_PCD
	EST_SRGTEF_SRV_PCD=`echo ${EST_SRGTEF_SRV_PC} | sed "s/${IT}_/_/"`
	cp -v $EST_SRGTEF_SRV_PC $EST_SRGTEF_SRV_PCD
fi

NJOB="ESCD9001"
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} "${BALSHTYEA_NF}1231"

# Launch applicative job ESFD2041 31/12
NJOB="ESFD2041B"
${DCMD}/ESFD2041.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} "${BALSHTYEA_NF}1231"  ${CRE_D} 12 PA 2>&1 | ${TEE}  #[004]

# Launch applicative job ESFD2042 31/12
NJOB="ESFD2042B"
${DCMD}/ESFD2042.cmd "${BALSHTYEA_NF}1231" ${CRE_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${DBCLO_D} 2>&1 | ${TEE}

# Launch applicative job ESID2043 31/12
NJOB="ESID2043B"
LOOP_JOB_SSD ${DCMD}/ESID2043.cmd 99 2>&1 | ${TEE}

NJOB="ESFD2044B"
${DCMD}/ESFD2044.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} "${BALSHTYEA_NF}1231" ${CRE_D} 12 ${CLODAT_D} PA 2>&1 | ${TEE}

NJOB="ESFD2045B"
${DCMD}/ESFD2045.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} "${BALSHTYEA_NF}1231"  ${CRE_D} 12 PA 2>&1 | ${TEE}  

# fi  #[004]

if [ "X${IT}" == "XY" ]
then
	EST_TRACEFILED=`echo ${EST_TRACEFILE} | sed "s/${IT}_/_/"`
	cp -v $EST_TRACEFILE $EST_TRACEFILED
	EST_DLVGTAA_PAD=`echo ${EST_DLVGTAA_PA} | sed "s/${IT}_/_/"`
	cp -v $EST_DLVGTAA_PA $EST_DLVGTAA_PAD
	EST_DLVGTAR_PAD=`echo ${EST_DLVGTAR_PA} | sed "s/${IT}_/_/"`
	cp -v $EST_DLVGTAR_PA $EST_DLVGTAR_PAD
	EST_DLVGTR_PAD=`echo ${EST_DLVGTR_PA} | sed "s/${IT}_/_/"`
	cp -v $EST_DLVGTR_PA $EST_DLVGTR_PAD
	EST_SRGTE_PAD=`echo ${EST_SRGTE_PA} | sed "s/${IT}_/_/"`
	cp -v $EST_SRGTE_PA $EST_SRGTE_PAD
	EST_SRGTEF_PAD=`echo ${EST_SRGTEF_PA} | sed "s/${IT}_/_/"`
	cp -v $EST_SRGTEF_PA $EST_SRGTEF_PAD
	EST_CMPCALC_PAD=`echo ${EST_CMPCALC_PA} | sed "s/${IT}_/_/"`
	cp -v $EST_CMPCALC_PA $EST_CMPCALC_PAD
	EST_SRGTE_VENTIL_PAD=`echo ${EST_SRGTE_VENTIL_PA} | sed "s/${IT}_/_/"`
	cp -v $EST_SRGTE_VENTIL_PA $EST_SRGTE_VENTIL_PAD
	EST_SRGTEF_VENTIL_PAD=`echo ${EST_SRGTEF_VENTIL_PA} | sed "s/${IT}_/_/"`
	cp -v $EST_SRGTEF_VENTIL_PA $EST_SRGTEF_VENTIL_PAD
	EST_SRGTE_SRV_PAD=`echo ${EST_SRGTE_SRV_PA} | sed "s/${IT}_/_/"`
	cp -v $EST_SRGTE_SRV_PA $EST_SRGTE_SRV_PAD
	EST_SRGTEF_SRV_PAD=`echo ${EST_SRGTEF_SRV_PA} | sed "s/${IT}_/_/"`
	cp -v $EST_SRGTEF_SRV_PA $EST_SRGTEF_SRV_PAD
	EST_SRGTR_VENTILD=`echo ${EST_SRGTR_VENTIL} | sed "s/${IT}_/_/"`
	cp -v $EST_SRGTR_VENTIL $EST_SRGTR_VENTILD
	EST_SIGNANOD=`echo ${EST_SIGNANO} | sed "s/${IT}_/_/"`
	cp -v $EST_SIGNANO $EST_SIGNANOD
	EST_SRGTR_VENTILD=`echo ${EST_SRGTR_VENTIL} | sed "s/${IT}_/_/"`
	cp -v $EST_SRGTR_VENTIL $EST_SRGTR_VENTILD
fi

CHAINEND
