#!/bin/ksh
#=============================================================================
# nom de l'application     : ESTIMATIONS - preparation des fichiers pour one GL
# nom du script SHELL      : ESPD3851.cmd
# date de creation         : 15/03/2011
# auteur                   : D.GATIBELZA
#-----------------------------------------------------------------------------
# description: :spot:21408 - Envoi des fichiers FTECLEDA et REcube pour One GL             
#-----------------------------------------------------------------------------
# historiques des modifications :
#===============================================================================
#[001]  05/05/2011  R. CASSIS     :spot:21408 - Modification OneGL
#---------------
#[002] -=Dch=-  19.08.2011      :spot:22435 Archivage avant envoi OneGL
#[003] 07/11/2011 Roger Cassis  :spot:22859 Date mois bilan dans fichier archive et maj table Oracle pour Etl
#[004] 19/03/2012 Roger Cassis  :spot:23567 Ajout cre_d dans fichier archivé
#[005] 02/05/2012 Roger Cassis  :spot:23699 Gestion fichiers flag vtom
#[006] 20/06/2012 Roger Cassis  :spot:23914 Ajustement des parametres Onegl envoyés à Oracle (CLOSING-TYPE)
#[007] 09/07/2012 Roger Cassis  :spot:23984 On lance toujours l'execution de onegl
#[008] 19/09/2012 Roger Cassis  :spot:24245 Ajout de SGP1 dans l'exécution du sql Oracle
#[009] 16/01/2012 Roger Cassis  :spot:24041 Gestion fichier archivé pour PGLM
#[010] 24/01/2012 Roger Cassis  :spot:24752 Gestion des fichiers archivés
#[011] 20/03/2013 Roger Cassis  :spot:24979 Ajout ny pour maj oracle
#[012] 21/03/2013 Roger Cassis  :spot:25006 Ajout Mode 3 pour cas de non-execution OneGl
#[013] 24/03/2014 Roger Cassis  :spot:26481 :spot:25427 Archivage fichiers Conso
#[014] 08/08/2016 Roger Cassis  :spot:31042 pas de JOBEND apres l'archivage des fichiers Conso.
#[015] 27/04/2018 MZM           :spira:67063 Ajout Table Technique VTOM
#[016] 31/07/2018 Roger Cassis  :spira:69887 Le nom BATCH_LS chargé dans la table TVTOMLAUNCH est le nom de la chaine qui envoit les parametres : ESPD3850
#                                            et renommage OTGL0010I au lieu de OTGL0010*.
#[017] 19/07/2019 Roger Cassis  :spira:80028 Suppression de la gestion de flags obsolete avec parametre Force et du test du site FRAM.
#[018] 22/12/2020 : M.NAJI   :. SPIRA 91531 
#						 	 . Remplacement du mapping en dur par un mapping directement dans la table BES..TI17PERMFIL
#[019] 23/03/2022 M.NAJI        :spira 96729  fix calcul MODE  
#[020] 01/04/2022 JYP/TD        :spira:103544 - DELTA posting new mode  
#[021] 13/05/2022 JYP/TD        :spira:103544 - DELTA posting : bugfix TYPEINV POS
#[022] 13/06/2022 TD        :spira:100097
#[023] 08/11/2022 TD/MZM       : spira:107662 Remove temporary file in ES*D3850 (OneGl interface) : Ajout ${DFILT}/${NJOB}_00_${IB}_${ENV_PREFIX}
#[024] 13/01/2023 MiS		:spira:108408 Remplacement de OTGL0010 par OTGL0030
#[025] 15/03/2023 TD/MZM       : spira:108948 Ajout du Mode 4 Simu et fonctionne comme le MODE 1
#-----------------------------------------------------------------------------
# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd 
. ${DUTI}/fctora.cmd

# Get input parameters
CRE_D=$1
CONSOYEA=$2
CONSOMTH=$3
INVCONSO_D=$4
PROCESSONEGL_CT=$5
#[006]
MODE="1"
#[016]
OneGLChain=ESPD3850


# Job Initialisation
JOBINIT

#[003]
FICTOONEGL1=ESPD3800_FTECLEDASO_MVT_${HOST_PRDSIT}
FICTOONEGL=ESPD3800_FTECLEDASO_MVT_${HOST_PRDSIT}_${CRE_D}
FICFROMONEGL=FTECLEDASO_MVT_${HOST_PRDSIT}_${CRE_D}
#[023]
NEW_EST_FTECLEDASO_MVT=${DFILT}/${ENV_PREFIX}_${FICTOONEGL}.dat

#[004]
CONSOMTH=`echo "${CONSOMTH}" | awk '{ if (length($0) < 2) print "0" $0; else print $0;}'`

#[006]
CLOSING_TYPE="post-closing"


VSITE=""
#015 HOST_PRDSIT : UBAS UBEU UBAM

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


#if [ "${EST_ESPD3850_COND1}" != "Y" ]
#then
#        MODE="3"
#fi

#[019][020][022] 
#[025]if [ "$TYPEINV" = "POS" -o "$PARM_IS_SAP_POSTING" = "Y" ]
if [ "$TYPEINV" = "POS" -a "$PARM_IS_SAP_POSTING" = "Y" ]
then
		  MODE="1"
fi		  
 
if  [ "$TYPEINV" = "POS" -a "$PARM_IS_SAP_POSTING" = "N" ]
then
	    MODE="4"
fi

if 	[ "$TYPEINV" != "POS" ]  
then
		 MODE="3"	    
fi


#[006]
ECHO_LOG "#========================================================================="
ECHO_LOG "-> INVCONSO_D .............: ${INVCONSO_D}"
ECHO_LOG "-> CONSOYEA ...............: ${CONSOYEA}"
ECHO_LOG "-> CONSOMTH ...............: ${CONSOMTH}"
ECHO_LOG "-> MODE ...................: ${MODE}"
ECHO_LOG "-> CLOSING_TYPE ...........: ${CLOSING_TYPE}"
ECHO_LOG "-> FICTOONEGL .............: ${FICTOONEGL}"
ECHO_LOG "-> FICTOONEGL1 ............: ${FICTOONEGL1}"
ECHO_LOG "-> FICFROMONEGL ...........: ${FICFROMONEGL}"
ECHO_LOG "-> NEW_EST_FTECLEDASO_MVT .: ${NEW_EST_FTECLEDASO_MVT}"
ECHO_LOG "-> OneGLChain .............: ${OneGLChain}"
ECHO_LOG "#========================================================================="

#if [ "${EST_ESPD3850_COND2}" = "Y" ]  #POC
if [ "${TYPEINV}" = "POC" ]  #POC
then

	NOM=CO
	#if [ ${EST_ESPD3800_COND2} = "Y" ]   #EBS
	if [ ${NORME_CF} = "EBS" ]   #EBS
	then
		EPO_FTECLEDACO=${EPO_FTECLEDASIICO}
		EPO_FTECLEDRCO=${EPO_FTECLEDRSIICO}
		NOM=SIICO
	fi

	ECHO_LOG "#========================================================================="
	ECHO_LOG "-> EPO_FTECLEDACO .....: ${EPO_FTECLEDACO}"
	ECHO_LOG "-> EPO_FTECLEDRCO .....: ${EPO_FTECLEDRCO}"
	ECHO_LOG "#========================================================================="

	if [ -f ${EPO_FTECLEDACO} ]
	then
		#[013]
		NSTEP=${NJOB}_06A
		# Archive si post Conso
		#----------------------------------------------------------------------------
		LIBEL="Archive ${EPO_FTECLEDACO} sur ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDA${NOM}_${INVCONSO_D}_${CRE_D}.dat.gz"
		EXECKSH_MODE=P
		EXECKSH "gzip -c ${EPO_FTECLEDACO} > ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDA${NOM}_${INVCONSO_D}_${CRE_D}.dat.gz"
	fi

	if [ -f ${EPO_FTECLEDRCO} ]
	then
		#[013]
		NSTEP=${NJOB}_06B
		# Archive si post Conso
		#----------------------------------------------------------------------------
		LIBEL="Archive ${EPO_FTECLEDRCO} sur ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDR${NOM}_${INVCONSO_D}_${CRE_D}.dat.gz"
		EXECKSH_MODE=P
		EXECKSH "gzip -c ${EPO_FTECLEDRCO} > ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDR${NOM}_${INVCONSO_D}_${CRE_D}.dat.gz"
	fi

fi





#if [ "${EST_ESPD3850_COND1}" = "Y" ]
#[022]
#if [ "$TYPEINV" = "POS" ]

#[025] if [ "$TYPEINV" = "POS" ] && [ "$PARM_IS_SAP_POSTING" = "Y" ]

if [ "${MODE}" != "3" ]
then

	NSTEP=${NJOB}_10
	LIBEL="copie fichier FTECLEDA"
	EXECKSH_MODE=P
	EXECKSH "cp ${EPO_FTECLEDASO_MVT} ${NEW_EST_FTECLEDASO_MVT}"

	#[003] [016]
	NSTEP=${NJOB}_15          
	#  ISQL to delete any entry on vTOM table paramter for OTGL0030
	#------------------------------------------------------------------------------
	LIBEL="Remove existing paramter for VTOM"        
	ISQL_BASE="BTEC"		
	ISQL_QRY="delete from BTEC..TVTOMLAUNCH  where PARM2='${HOST_PRDSIT}' and PARM8='OTGL0030' and BATCH_LS='${OneGLChain}' " 
	ISQL

	#[002]
	#[006]
	#[015] [016]
	NSTEP=${NJOB}_20
	#  ISQL to insert paramter on vTOM table for OTGL0030
	#------------------------------------------------------------------------------
	LIBEL="ISQL to insert paramter on vTOM table for OTGL0030"
	ISQL_BASE="BTEC"
	ISQL_QRY="insert into BTEC..tvtomlaunch (BATCHUSR_CF,BATCH_LS,PARM1,PARM2,PARM3,PARM4,PARM5,PARM6,PARM7,PARM8) values ('${VSITE}','${OneGLChain}','${CLOSING_TYPE}','${HOST_PRDSIT}','${CONSOYEA}','${CONSOMTH}','${MODE}','${FICTOONEGL}','${FICFROMONEGL}','OTGL0030')"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log			
	ISQL

	NSTEP=${NJOB}_25
	# ZIP
	#----------------------------------------------------------------------------
	LIBEL="Beginning of a ZIP session"
	ZIP_MODE="Z"
	ZIP_ODIR="${DTRANSFER}/OneGL/to"
	ZIP_I="${NEW_EST_FTECLEDASO_MVT}"
	ZIP_O="${ENV_PREFIX}_${FICTOONEGL}.zip"
	ZIP_OPT=""
	ZIP
	
	#[003]
	NSTEP=${NJOB}_35
	# Copy to Tosave
	#----------------------------------------------------------------------------
	LIBEL="Copy MVT file to tosave"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${DFILT}/${ENV_PREFIX}_${FICTOONEGL}.dat > ${DTRANSFER}/OneGL/tosave/${ENV_PREFIX}_${FICTOONEGL}.dat.gz"

	#[004]
	NSTEP=${NJOB}_40
	# Begin execksh
	#-----------------------------------------------------------------
	LIBEL="copy MVT to ${DARCH}/${ENV_PREFIX}_${FICTOONEGL1}_${INVCONSO_D}_${CONSOYEA}${CONSOMTH}_${CRE_D}.dat"
	EXECKSH_MODE=P
	EXECKSH "cp ${DFILT}/${ENV_PREFIX}_${FICTOONEGL}.dat ${DARCH}/${ENV_PREFIX}_${FICTOONEGL1}_${INVCONSO_D}_${CONSOYEA}${CONSOMTH}_${CRE_D}.dat"

	#[010]
	NSTEP=${NJOB}_44
	# Begin Sort
	#-----------------------------------------------------------------
	LIBEL="RM of ${DARCH}/${ENV_PREFIX}_${FICTOONEGL1}_${INVCONSO_D}_${CONSOYEA}_${CONSOMTH}_${CRE_D}.dat.gz"
	RMFIL "${DARCH}/${ENV_PREFIX}_${FICTOONEGL1}_${INVCONSO_D}_${CONSOYEA}${CONSOMTH}_${CRE_D}.dat.gz"

	#[009]
	NSTEP=${NJOB}_45
	# Begin execksh
	#-----------------------------------------------------------------
	LIBEL="Archive last file to DARCH"
	EXECKSH_MODE=P
	EXECKSH "gzip ${DARCH}/${ENV_PREFIX}_${FICTOONEGL1}_${INVCONSO_D}_${CONSOYEA}${CONSOMTH}_${CRE_D}.dat"

else

	#L'interface OneGL ne tourne pas
	MODE="3"

	#[015] [016]
	NSTEP=${NJOB}_50          
	#  ISQL to delete any entry on vTOM table paramter for OTGL0030
	#------------------------------------------------------------------------------
	LIBEL="Remove existing paramter for VTOM"        
	ISQL_BASE="BTEC"		
	ISQL_QRY="delete from BTEC..TVTOMLAUNCH  where PARM2='${HOST_PRDSIT}' and PARM8='OTGL0030' and BATCH_LS='${OneGLChain}' " 
	ISQL

	#[002]
	#[006] [015] [016]
	NSTEP=${NJOB}_60
	#  ISQL to insert paramter on vTOM table for OTGL0030
	#------------------------------------------------------------------------------
	LIBEL="ISQL to insert paramter on vTOM table for OTGL0030"
	ISQL_BASE="BTEC"
	ISQL_QRY="insert into BTEC..tvtomlaunch (BATCHUSR_CF,BATCH_LS,PARM1,PARM2,PARM3,PARM4,PARM5,PARM6,PARM7,PARM8) values ('${VSITE}','${OneGLChain}','${CLOSING_TYPE}','${HOST_PRDSIT}','${CONSOYEA}','${CONSOMTH}','${MODE}','${FICTOONEGL}','${FICFROMONEGL}','OTGL0030')"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log			
	ISQL

fi

NSTEP=${NJOB}_80
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"
RMFIL "${DFILT}/${ENV_PREFIX}_${FICTOONEGL}.dat"

JOBEND

