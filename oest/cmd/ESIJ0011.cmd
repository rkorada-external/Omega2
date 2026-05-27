#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                  Extraction des reglements retrocession
# nom du script SHELL           : ESIJ0011.cmd
# revision                      : $Revision: 1.1.1.1 $
# date de creation              : 20/10/2000
# auteur                        : 
# references des specifications : 
#-----------------------------------------------------------------------------
# Description
#   Extracting tables
#-----------------------------------------------------------------------------
# historique des modifications
#_________________
#MODIFICATION    [001]
#Auteur:         D.GATIBELZA
#Date:           15/01/2009
#Version:        9.1
#Description:    ESTDOM16708 changer le hostname mutre dans le job esij0010
#[002]  11/04/2011   R. CASSIS  :spot:21408 - Affectation du nom du fichier MGT selon la variante LAUNCH_B
#_________________
#MODIFICATION    [003]
#Auteur:         D.GATIBELZA
#Date:           12/05/2011
#Version:        11.1
#Description:    ESTDOM21408 OneLedger
#[004]  07/07/2011   R. CASSIS  :spot:22334 - Si MutRE, on ne fait pas le transfert vers OneGl.
#[005]  31/08/2011   R. CASSIS  :spot:22435 - Si simu, on copie pour Onegl avec le meme nom qu'en Booking (comptabilisation)
#[006]  19/10/2011   R. CASSIS  :spot:22752 - Le mois bilan est complete a 2 caracteres si inferieur a 10.
#[007]  02/12/2011   R. CASSIS  :spot:22859 - La date bilan du fichier CMGTS est prise du resultat de la proc PsREQJOB_01
#                                             Connection Oracle que pour Paris
#[008]  01/02/2012   R. CASSIS  :spot:23329 - Gestion du déclenchement ONEGL et paramétrage optionnel du mode Simu. Shell refondu entierement.
#[009]  22/02/2012   R. Cassis  :spot:23418 - Correction des modes pour s'aligner sur ceux d'Oracle Onegl.
#[010]  13/03/2012   R. Cassis  :spot:23541 - Correction sur dates an/mois transmises vers Oracle Onegl
#[011]  16/03/2012   R. Cassis  :spot:23567 - Correction sur nom de fichier transmis à Onegl
#[012]  10/07/2012   R. Cassis  :spot:23984 - Execution OneGL pour tous les sites
#[013]  12/07/2012   R. Cassis  :spot:23998 - Execution OneGL pour tous les sites sauf NY
#[014]  12/07/2012   R. Cassis  :spot:23742 - Execution OneGL pour tous les sites sauf NY et Mutre
#[015]  05/11/2012   R. Cassis  :spot:24445 - Ré-ajustement des conditions de declenchement Onegl.
#[016]  11/01/2013   R. Cassis  :spot:24041 - Activation Onegl pour US
#[017]  28/02/2013   R. Cassis  :spot:24909 - Re-Activation Onegl pour US
#[018]  01/06/2016   R. CASSIS  :spot:30673 - Juste le parametre date pour la proc PsTREQJOB_01
#[019]  05/02/2026   Sir JYP    :US7500     - Review parameters update method to run job 
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd 
. ${DUTI}/fctora.cmd

# Job Initialization
JOBINIT

# Parameters
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
DATE_T=$3
CLODAT_D=$4
DBCLO_D=$5
PROCESSONEGL_CT=$6

NSTEP=${NJOB}_05
# Begin Isql
#----------------------------------------------------------------------------
LIBEL="Parameter determination for BCTA..PtRgComtaGen_01 launching"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
ISQL_QRY="exec BEST..PsTREQJOB_01 '${DATE_T}'"     #[018]
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_FRES_O1.dat
ISQL_INFO

FRES=`cat ${ISQL_FRES}`
LAUNCH_B="$(cat ${ISQL_FRES} | cut -d~ -f1)"
BLCSHTYEA="$(cat ${ISQL_FRES} | cut -d~ -f2)"
BLCSHTMTH="$(cat ${ISQL_FRES} | cut -d~ -f3)"
CLODAT="$(cat ${ISQL_FRES} | cut -d~ -f4)"  # [007]

if [ "${BLCSHTYEA}" = "" ]
then
	BLCSHTYEA="${BALSHTYEA_NF}"
fi

if [ "${BLCSHTMTH}" = "" ]
then
	BLCSHTMTH="${BALSHTMTH_NF}"
fi

#[011]
BLCSHTMTH=`echo "${BLCSHTMTH}" | awk '{ if (length($0) < 2) print "0" $0; else print $0;}'`

#[011]
###################################
# Defauts pour Simu
MGT=MGTS
MODE=0
FICHIER=${DFILP}/${ENV_PREFIX}_ESIJ0010_${MGT}.dat
FICHIER2=ESIJ0010_${MGT}
###################################

if [ "${LAUNCH_B}" -eq "1" ] ; then
	# Si Compta reglements (LAUNCH_B=1) car demande type 'V' -> MODE 1
    MGT=CMGTS
    MODE=1
    FICHIER=${DFILP}/${NCHAIN}_${MGT}_${CLODAT}_${BLCSHTYEA}${BLCSHTMTH}_${DBCLO_D}_${DATE_T}.dat  # [007]
    FICHIER2=ESIJ0010_${MGT}_${CLODAT}_${BLCSHTYEA}${BLCSHTMTH}_${DBCLO_D}_${DATE_T}  # [008]
fi

#------------------------------------
ECHO_LOG "FRES.......... : ${FRES}"
ECHO_LOG "LAUNCH_B...... : ${LAUNCH_B}"
ECHO_LOG "BLCSHTYEA..... : ${BLCSHTYEA}"
ECHO_LOG "BLCSHTMTH..... : ${BLCSHTMTH}"
ECHO_LOG "CLODAT........ : ${CLODAT}"
ECHO_LOG "MGT........... : ${MGT}"
ECHO_LOG "MODE.......... : ${MODE}"
ECHO_LOG "FICHIER....... : ${FICHIER}"
ECHO_LOG "FICHIER2...... : ${FICHIER2}"
ECHO_LOG "EST_VARIANTE.. : ${EST_VARIANTE}"
#------------------------------------
	
#PLUS UTILISE: if [ ${MODE} -ne 0 ] ; then

#[001] mutre devient frzprdmutre
#[002] HOST_PRDSIT plutot
#	if [ ${MODE} -eq 2 -a "${HOSTNAME}" = "frzprdmutre" ] ; then
if [ ${MODE} = 1 -a "${HOST_PRDSIT}" = "FRAM" ] ; then

	NSTEP=${NJOB}_05
	# Begin Isql
	#----------------------------------------------------------------------------
	LIBEL="Update of BEST..TREQJOB"
	ISQL_BASE=BEST
	ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.log
	ISQL_QRY="exec BEST..PuTREQJOB_01 '${DATE_T}', ${BLCSHTYEA}, ${BLCSHTMTH}"
	ISQL

fi

#[008] [015]
if [ "${MODE}" = "1" ] ||
	[ "${PROCESSONEGL_CT}" = "1" ]
then

	NSTEP=${NJOB}_10
	# Begin bcp+ out
	#----------------------------------------------------------------------------
	LIBEL="bcp out of BTRAV..TRGLCOMPTA, export for accounting system"
	BCP_WAY="OUT"
	BCP_VER="+"
	BCP_O=${FICHIER}
	BCP_QRY="exec BCTA..PtRgComptaGen_01 ${BLCSHTYEA}, ${BLCSHTMTH}"
	BCP

	#[008]
	if [ ${MODE} = 1 ]
	then
		
		NSTEP=${NJOB}_20
		# Begin execksh
		#-----------------------------------------------------------------
		LIBEL="Archive CMGTS file ${FICHIER}"
		EXECKSH_MODE=P
		EXECKSH "cp ${FICHIER} ${DARCH}"

		NSTEP=${NJOB}_25
		# Begin RMFIL
		#-----------------------------------------------------------------
		LIBEL="Erase ${DARCH}/${ENV_PREFIX}_${FICHIER2}.dat.gz if exist"
		RMFIL "${DARCH}/${ENV_PREFIX}_${FICHIER2}.dat.gz"

		NSTEP=${NJOB}_30
		# Begin execksh
		#-----------------------------------------------------------------
		LIBEL="gzip Archive file ${FICHIER2}"
		EXECKSH_MODE=P
		EXECKSH "gzip ${DARCH}/${ENV_PREFIX}_${FICHIER2}.dat"
		
	fi

	#[013] [014] [016]
	if [ "${HOST_PRDSIT}" != "FRAM" ]
	then

		##############################	
		# Process OneGL 
		##############################	
		NSTEP=${NJOB}_40
		# ZIP
		#----------------------------------------------------------------------------
		LIBEL="Beginning of a ZIP session for ${FICHIER}"
		ZIP_MODE="Z"
		ZIP_ODIR="${DTRANSFER}/OneGL/to"
		ZIP_I="${FICHIER}"
		ZIP_O="${ENV_PREFIX}_${FICHIER2}.zip"
		ZIP_OPT=""
		ZIP
		
	CLOSING_TYPE="closing"
	OneGLChain="ESIJ0010"
	VSITE=""
	if [ "${HOST_PRDSIT}" = "FRA1" ]
	then
		VSITE="UBEU"
	fi
	
	if [ "${HOST_PRDSIT}" = "SGP1" ]
	then
		VSITE="UBAS"
	fi
	
	if [ "${HOST_PRDSIT}" = "USA1" ]
	then
		VSITE="UBAM"
	fi	

ECHO_LOG "#========================================================================="
ECHO_LOG "-> BLCSHTYEA    ...........: ${BLCSHTYEA}"
ECHO_LOG "-> BLCSHTMTH    ...........: ${BLCSHTMTH}"
ECHO_LOG "-> MODE ...................: ${MODE}"
ECHO_LOG "-> CLOSING_TYPE ...........: ${CLOSING_TYPE}"
ECHO_LOG "-> FICHIER          .......: ${FICHIER}"
ECHO_LOG "-> FICHIER2         .......: ${FICHIER2}"
ECHO_LOG "-> VSITE ..................: ${VSITE}"
ECHO_LOG "-> OneGLChain .............: ${OneGLChain}"
ECHO_LOG "#========================================================================="


	
	NSTEP=${NJOB}_42          
	#  ISQL to delete any entry on vTOM table paramter 
	#------------------------------------------------------------------------------
	LIBEL="Remove existing paramter for VTOM"        
	ISQL_BASE="BTEC"		
	ISQL_QRY="delete from BTEC..TVTOMLAUNCH  where PARM2='${HOST_PRDSIT}' and PARM8='OSGL0010' and BATCH_LS='${OneGLChain}' " 
	ISQL


	
	NSTEP=${NJOB}_50
	#  ISQL to insert paramter on vTOM table 
	#------------------------------------------------------------------------------
	LIBEL="ISQL to insert paramter on vTOM table "
	ISQL_BASE="BTEC"
	ISQL_QRY="insert into BTEC..tvtomlaunch (BATCHUSR_CF,BATCH_LS,PARM1,PARM2,PARM3,PARM4,PARM5,PARM6,PARM7,PARM8) values ('${VSITE}','${OneGLChain}','${CLOSING_TYPE}','${HOST_PRDSIT}','${BLCSHTYEA}','${BLCSHTMTH}','${MODE}','${FICHIER2}','${FICHIER2}','OSGL0010')"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log			
	ISQL
  	

	
		#[008]
		NSTEP=${NJOB}_70
		# Begin execksh
		#----------------------------------------------------------------- 
		LIBEL="Touch ${DTMP}/${ENV_PREFIX}_OSGL0010.OK to indicate OneGl will be processed"
		EXECKSH_MODE=P
		EXECKSH "touch ${DTMP}/${ENV_PREFIX}_OSGL0010.OK"

	fi
		
else
	ECHO_LOG "#"
	ECHO_LOG "---> No process because no Settlement accounting and variante not in 3,5,6,7 and PROCESSONEGL_CT = 0"
	ECHO_LOG "#"
	JOBEND
fi

NSTEP=${NJOB}_100
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
