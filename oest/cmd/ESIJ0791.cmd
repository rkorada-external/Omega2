#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INTEGRATION FICHIER des ecritures 
#				                    de service automatiques
# nom du script SHELL		  : ESIJ0790.cmd
# revision			          : $Revision:   1.0  $
# date de creation		    : 14/04/2020 (jour 29 du confinement)
# auteur			            : S.Behague
# spira                   : 82196
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   File integration of assistance entries
#-----------------------------------------------------------------------------
# Job appelé par ESIJ0790.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
# [01] - S.Behague :spira:82196 - création
# [02] - 09/03/2023 S.Behague :spira:104207 AE SAS - Improve error management
# [03] - 31/08/2023 S.Behague :spira:109059 Life - SAS/Omega interface management during local entity extended period
# [04] - 08/07/2024 S.Behague :spira:111650 SAS/Omega- ESU0790 should not crash
# [05] - 05/12/2024 S.Behague :spira:111789 Control/Limit SAS data volume in Omega
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

CRE_D=$1

NSTEP=${NJOB}_00
#-----------------------------------------------------------------
LIBEL="Creation of Rapport file"
REPORT_FILE="${DTRANSFER}/LifeReserving/to/${ENV_PREFIX}_ESIJ0790_REPORTFILE_${CRE_D}.dat"
touch ${REPORT_FILE}

NSTEP=${NJOB}_01
#---------------------------------------------------------------
LIBEL="Extract all parametrs   "
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILI}/${NSTEP}_PARM.dat
BCP_QRY="exec BEST..PsIfrs17Param_02 '$CRE_D' "
BCP

PARM_BALSHTMTH_NF=`cat ${DFILI}/${ENV_PREFIX}_ESIJ0790_ESIJ0791_01_PARM.dat | grep I17G | grep PARM_BALSHTMTH_NF | awk -F"~" '{ print $3 }'`
PARM_BALSHTYEA_NF=`cat ${DFILI}/${ENV_PREFIX}_ESIJ0790_ESIJ0791_01_PARM.dat | grep I17G | grep PARM_BALSHTYEA_NF | awk -F"~" '{ print $3 }'`
PARM_CLODAT_D=`cat ${DFILI}/${ENV_PREFIX}_ESIJ0790_ESIJ0791_01_PARM.dat | grep I17G | grep PARM_CLODAT_D | awk -F"~" '{ print $3 }'`
PARM_REQCODPOS_CT=`cat ${DFILI}/${ENV_PREFIX}_ESIJ0790_ESIJ0791_01_PARM.dat | grep I17G | grep PARM_REQCOD_CT | awk -F"~" '{ print $3 }' | grep POS | grep -v POSB`
PARM_REQCODINV_CT=`cat ${DFILI}/${ENV_PREFIX}_ESIJ0790_ESIJ0791_01_PARM.dat | grep I17G | grep PARM_REQCOD_CT | awk -F"~" '{ print $3 }' | grep INV | grep -v INVB`
PARM_IS_POSXI17L=`cat ${DFILI}/${ENV_PREFIX}_ESIJ0790_ESIJ0791_01_PARM.dat | grep I17L | grep PARM_POSX | awk -F"~" '{ print $3 }'`
PARM_IS_POSXI17P=`cat ${DFILI}/${ENV_PREFIX}_ESIJ0790_ESIJ0791_01_PARM.dat | grep I17P | grep PARM_POSX | awk -F"~" '{ print $3 }'`

if [ "X${PARM_IS_POSXI17L}" != "X_POSX" ] && [ "X${PARM_IS_POSXI17P}" != "X_POSX" ]
then
  # Si on n'est pas en periode etendue, on verifie pour I17G si un inventaire est prevu.
  # Si on est en periode etendue, I17P ou I17L peuvent tourner sans I17G
  NSTEP=${NJOB}_02
	#---------------------------------------------------------------
	LIBEL="Ckecking retrieve of inventory type"
	if [ "X${PARM_REQCODINV_CT}" = "X" ] && [ "X${PARM_REQCODPOS_CT}" = "X" ]
	then
	  if [ -f ${DTRANSFER}/${REMOTE_SITE}/from/${NOM_PREFIX}* ]
  	then
	    ECHO_LOG " WARNING - Problem when retrieving inventory type , Aucune AE inseree"
  	  echo "WARNING - Problem when retrieving inventory type , Aucune AE inseree" >> ${REPORT_FILE}
  	fi
  	touch $DFILT/${ENV_PREFIX}_ESIJ0790_CHAINEND_${IB}.txt
  	JOBEND
	fi
fi

NSTEP=${NJOB}_05
#-----------------------------------------------------------------
LIBEL=" dezippe .zip input files"
cd ${DTRANSFER}/${REMOTE_SITE}/from/
for file in `ls ${NOM_PREFIX}*.zip`
do
	unzip ${file}
	#mv ${file} ${DTRANSFER}/${REMOTE_SITE}/fromsave/
done


NSTEP=${NJOB}_10
#-----------------------------------------------------------------
LIBEL="Rename .txt input files into .dat"
for file in `ls ${NOM_PREFIX}*.txt`
do
	nomfichier=`echo ${file} | awk -F"." '{ print $1} '`
	mv ${file} ${nomfichier}.dat
done




JOBEND


