#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#              			            : Preparation des fichiers d'ecritures Locales pour OneGL
# nom du script SHELL           : ESLD3851.cmd
# revision                      : 
# date de creation              : 04/07/2017
# auteur                        : R. Cassis
# references des specifications : Spira:61508
#-----------------------------------------------------------------------------
# description:
#
#-----------------------------------------------------------------------------
# historiques des modifications
#---------------
#[001] 07/12/2017 R. Cassis :spira:66334 Les fichiers perimetre ES Local sont nomm�s ESL_ sont maintenant g�n�r�s dans le ESID7000
#[002] 27/12/2017 R. Cassis :Spira:66794 renomage de OLGL0010 en OTGL0010
#[003] 20/04/2018 R. Cassis :Spira:68459 Passage du mode 3 pour d�sactiver ONEGL si pas de Local planifi�
#[004] 14/05/2018 R. Cassis :spira:68778 Extraction de l'ann�e/mois bilan Local BLCSHTYEALOC_NF/BLCSHTMTHLOC_NF trait� pour SAP
#[007] 27/04/2018 MZM       :spira:67063 Ajout Table Technique VTOM ; Type_Closing passe de "postl-closing" � "closing" pour SAP...
#[008] 31/07/2018 R. Cassis :spira:69887 Le nom BATCH_LS charg� dans la table TVTOMLAUNCH est le nom de la chaine qui envoit les parametres : ESLD3850
#[009] 19/07/2019 R. Cassis :spira:80028 Suppression de la gestion de flags obsolete avec parametre Force et du test du site FRAM.
#[010] 18/07/2022 DAD       :spira:105696 Local fix SAP MODE send to SAP
#[011] 28/11/2022 J.B-D			:spira:107836 O2/SAP interface for IFRS4 local logic change
#[012] 13/01/2023 MiS       :spira:108408 Remplacement de OTGL0010 par OTGL0030
#[013] 02/09/2025 Mr JYP    :US 6793 :  SERQS old archi parameters issue
#===============================================================================
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
BLCSHTYEALOC_NF=$6
BLCSHTMTHLOC_NF=$7
MODE="1"
#[008]
OneGLChain=ESLD3850

#MODE 0 -> Comptabilise dans SAP par ONEGL
#MODE 1 -> Simulation et chargement dans SAP par ONEGL
#MODE 3 -> D�sactive ONEGL

# Job Initialisation
JOBINIT

#[003] Si pas d'inventaire Local planifi�, on d�sactive le process ONEGL
# [010]
if [ `grep 'EST_ESLJ0090_ESLJ0090_GONOGO=Y' ${DFILP}/*_ESFJ0000_PLAN.dat | wc -l` -eq 0 ]
then
	MODE=3
fi

#[007] HOST_PRDSIT : UBAS UBEU UBAM

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

FICTOONEGL1=ESLD3800_FTECLEDALO_MVT_${HOST_PRDSIT}
FICTOONEGL=ESLD3800_FTECLEDALO_MVT_${HOST_PRDSIT}_${CRE_D}
FICFROMONEGL=FTECLEDALO_MVT_${HOST_PRDSIT}_${CRE_D}
NEW_EST_FTECLEDALO_MVT=${DFILT}/${ENV_PREFIX}_${FICTOONEGL}.dat

#[004]
CONSOMTH=`echo "${CONSOMTH}" | awk '{ if (length($0) < 2) print "0" $0; else print $0;}'`
BLCSHTMTHLOC_NF=`echo "${BLCSHTMTHLOC_NF}" | awk '{ if (length($0) < 2) print "0" $0; else print $0;}'`

#[007]
#CLOSING_TYPE="postl-closing"
CLOSING_TYPE="closing"

#[004]
ECHO_LOG "#========================================================================="
ECHO_LOG "-> CRE_D      .................: ${CRE_D}"
ECHO_LOG "-> INVCONSO_D .................: ${INVCONSO_D}"
ECHO_LOG "-> CONSOYEA ...................: ${CONSOYEA}"
ECHO_LOG "-> CONSOMTH ...................: ${CONSOMTH}"
ECHO_LOG "-> BLCSHTYEALOC_NF(an SAP) ....: ${BLCSHTYEALOC_NF}"
ECHO_LOG "-> BLCSHTMTHLOC_NF(mois SAP) ..: ${BLCSHTMTHLOC_NF}"
ECHO_LOG "-> MODE .......................: ${MODE}"
ECHO_LOG "-> CLOSING_TYPE ...............: ${CLOSING_TYPE}"
ECHO_LOG "-> FICTOONEGL .................: ${FICTOONEGL}"
ECHO_LOG "-> FICTOONEGL1 ................: ${FICTOONEGL1}"
ECHO_LOG "-> FICFROMONEGL ...............: ${FICFROMONEGL}"
ECHO_LOG "-> ESL_FTECLEDALO_MVT .........: ${ESL_FTECLEDALO_MVT}"
ECHO_LOG "-> NEW_EST_FTECLEDALO_MVT .....: ${NEW_EST_FTECLEDALO_MVT}"
ECHO_LOG "-> OneGLChain .................: ${OneGLChain}"
ECHO_LOG "#========================================================================="

#MOD[011]
if [ -f ${ESL_FTECLEDALO_MVT} -a -s ${ESL_FTECLEDALO_MVT} ] && [ MODE -ne 3 ]
then

	NSTEP=${NJOB}_10
	# copie fichier FTECLEDA
	#------------------------------------------------------------------------------
	LIBEL="copie fichier FTECLEDA"
	EXECKSH_MODE=P
	EXECKSH "cp ${ESL_FTECLEDALO_MVT} ${NEW_EST_FTECLEDALO_MVT}"

	NSTEP=${NJOB}_15         
	#  ISQL to delete any entry on vTOM table paramter for OTGL0030
	#------------------------------------------------------------------------------                   

	#[008]          
	LIBEL="Remove existing paramter for VTOM"        
	ISQL_BASE="BTEC"		
	ISQL_QRY="delete from BTEC..TVTOMLAUNCH  where PARM2='${HOST_PRDSIT}' and PARM8='OTGL0030' and BATCH_LS='${OneGLChain}' " 
	ISQL
		
	#[007] [008]
	NSTEP=${NJOB}_20
	#  ISQL to insert paramter on vTOM table for OTGL0030
	#------------------------------------------------------------------------------
	LIBEL="ISQL to insert paramter on vTOM table for OTGL0030"
	ISQL_BASE="BTEC"
	ISQL_QRY="insert into BTEC..tvtomlaunch (BATCHUSR_CF,BATCH_LS,PARM1,PARM2,PARM3,PARM4,PARM5,PARM6,PARM7,PARM8) values ('${VSITE}','${OneGLChain}','${CLOSING_TYPE}','${HOST_PRDSIT}','${BLCSHTYEALOC_NF}','${BLCSHTMTHLOC_NF}','${MODE}','${FICTOONEGL}','${FICFROMONEGL}','OTGL0030')"
	ECHO_LOG "ISQL_QRY=[ $ISQL_QRY ] "
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log			
	ISQL

	NSTEP=${NJOB}_25
	# ZIP
	#----------------------------------------------------------------------------
	LIBEL="Beginning of a ZIP session"
	ZIP_MODE="Z"
	ZIP_ODIR="${DTRANSFER}/OneGL/to"
	ZIP_I="${NEW_EST_FTECLEDALO_MVT}"
	ZIP_O="${ENV_PREFIX}_${FICTOONEGL}.zip"
	ZIP_OPT=""
	ZIP

	NSTEP=${NJOB}_30
	# Begin execksh
	#----------------------------------------------------------------- 
	LIBEL="Touch ${DTMP}/${ENV_PREFIX}_OTGL0030L.OK to indicate OneGl will be processed"
	EXECKSH_MODE=P
	EXECKSH "touch ${DTMP}/${ENV_PREFIX}_OTGL0030L.OK"

	NSTEP=${NJOB}_35
	# Copy to Tosave
	#----------------------------------------------------------------------------
	LIBEL="Copy MVT file to tosave"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${DFILT}/${ENV_PREFIX}_${FICTOONEGL}.dat > ${DTRANSFER}/OneGL/tosave/${ENV_PREFIX}_${FICTOONEGL}.dat.gz"

	NSTEP=${NJOB}_40
	# Begin execksh
	#-----------------------------------------------------------------
	LIBEL="copy MVT to ${DARCH}/${ENV_PREFIX}_${FICTOONEGL1}_${INVCONSO_D}_${CONSOYEA}${CONSOMTH}_${CRE_D}.dat"
	EXECKSH_MODE=P
	EXECKSH "cp ${DFILT}/${ENV_PREFIX}_${FICTOONEGL}.dat ${DARCH}/${ENV_PREFIX}_${FICTOONEGL1}_${INVCONSO_D}_${CONSOYEA}${CONSOMTH}_${CRE_D}.dat"

	NSTEP=${NJOB}_44
	# Begin Sort
	#-----------------------------------------------------------------
	LIBEL="RM of ${DARCH}/${ENV_PREFIX}_${FICTOONEGL1}_${INVCONSO_D}_${CONSOYEA}${CONSOMTH}_${CRE_D}.dat.gz"
	RMFIL "${DARCH}/${ENV_PREFIX}_${FICTOONEGL1}_${INVCONSO_D}_${CONSOYEA}${CONSOMTH}_${CRE_D}.dat.gz"

	NSTEP=${NJOB}_45
	# Begin execksh
	#-----------------------------------------------------------------
	LIBEL="Archive last file to DARCH"
	EXECKSH_MODE=P
	EXECKSH "gzip ${DARCH}/${ENV_PREFIX}_${FICTOONEGL1}_${INVCONSO_D}_${CONSOYEA}${CONSOMTH}_${CRE_D}.dat"

else

	#L'interface OneGL ne tourne pas
	MODE="3"

	NSTEP=${NJOB}_50          
	#  ISQL to delete any entry on vTOM table paramter for OTGL0030
	#------------------------------------------------------------------------------          

	#[008]          
	LIBEL="Remove existing paramter for VTOM"        
	ISQL_BASE="BTEC"		
	ISQL_QRY="delete from BTEC..TVTOMLAUNCH  where PARM2='${HOST_PRDSIT}' and PARM8='OTGL0030' and BATCH_LS='${OneGLChain}' " 
	ISQL

	#[007] [008]
	NSTEP=${NJOB}_60
	#  ISQL to insert paramter on vTOM table for OTGL0030
	#------------------------------------------------------------------------------
	LIBEL="ISQL to insert paramter on vTOM table for OTGL0030"
	ISQL_BASE="BTEC"
	ISQL_QRY="insert into BTEC..tvtomlaunch (BATCHUSR_CF,BATCH_LS,PARM1,PARM2,PARM3,PARM4,PARM5,PARM6,PARM7,PARM8) values ('${VSITE}','${OneGLChain}','${CLOSING_TYPE}','${HOST_PRDSIT}','${BLCSHTYEALOC_NF}','${BLCSHTMTHLOC_NF}','${MODE}','${FICTOONEGL}','${FICFROMONEGL}','OTGL0030')"
	ECHO_LOG "ISQL_QRY=[ $ISQL_QRY ] "
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log			
	ISQL

fi

NSTEP=${NJOB}_80
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"
RMFIL "${DFILT}/${ENV_PREFIX}_${FICTOONEGL}.dat"

JOBEND

