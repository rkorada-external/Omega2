#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INTEGRATION FICHIER des ecritures 
#				                    de service automatiques
# nom du script SHELL		  : ESFD0830.cmd
# revision			          : $Revision:   1.0  $
# date de creation		    : 07/05/2022
# auteur			            : S.Behague
# spira                   : 110557
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   File integration of assistance entries
#-----------------------------------------------------------------------------
# Job appelé par ESFD0830.cmd
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
INV_DATE=$2
UPDATE_DELAY_INF=$3
POS_DATE=$4
UPDATE_DELAY_SUP=$5


NSTEP=${NJOB}_05
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Calcul of the extract date"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_SELECT_UPDATE_DATE.log
ISQL_QRY="SELECT 
 					CASE 
					WHEN '$CRE_D' <= DATEADD( DAY, -($UPDATE_DELAY_SUP), '$POS_DATE' ) AND '$CRE_D' >= DATEADD( DAY, -($UPDATE_DELAY_INF), '$INV_DATE' ) THEN 'OK'
					WHEN '$CRE_D' > DATEADD( DAY, -($UPDATE_DELAY_SUP), '$POS_DATE' ) OR '$CRE_D' < DATEADD( DAY, -($UPDATE_DELAY_INF), '$INV_DATE' )  THEN 'KO'
					END"
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQL_SELECT_UPDATE_DATE.dat
ISQL_RES

RETOUR=`cat ${DFILT}/${NSTEP}_${IB}_ISQL_SELECT_UPDATE_DATE.dat | cut -d" " -f2`

echo "Dates du traitement CRE_D :            <${CRE_D}>" >> ${DFILT}/${NSTEP}_${IB}_ISQL_SELECT_UPDATE_DATE.log
echo "                    INV_DATE :         <${INV_DATE}>"  >> ${DFILT}/${NSTEP}_${IB}_ISQL_SELECT_UPDATE_DATE.log
echo "                    UPDATE_DELAY_INF : <${UPDATE_DELAY_INF}>"  >> ${DFILT}/${NSTEP}_${IB}_ISQL_SELECT_UPDATE_DATE.log
echo "                    POS_DATE :         <${POS_DATE}>"  >> ${DFILT}/${NSTEP}_${IB}_ISQL_SELECT_UPDATE_DATE.log
echo "                    UPDATE_DELAY_SUP : <${UPDATE_DELAY_SUP}>"  >> ${DFILT}/${NSTEP}_${IB}_ISQL_SELECT_UPDATE_DATE.log
echo "                    RETOUR :           <${RETOUR}>"  >> ${DFILT}/${NSTEP}_${IB}_ISQL_SELECT_UPDATE_DATE.log


if [ "X${RETOUR}" = "XKO" ]
then
	JOBEND
fi

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


