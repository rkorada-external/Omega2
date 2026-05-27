#!/bin/ksh
#=============================================================================
# nom de l'application   : ESTIMATIONS - preparation des fichiers pour one GL
# nom du script SHELL    : ESFD3851.cmd
# date de creation	    : 15/03/2011
# auteur			          : D.GATIBELZA
#-----------------------------------------------------------------------------
# description: :spot:21408 - Envoi des fichiers FTECLEDA et REcube pour One GL             
#-----------------------------------------------------------------------------
# historiques des modifications :
#===============================================================================
#---------------
#[001] 19.08.2011 -=Dch=-       :spot:22435 Ajout de l'archivage des fichiers avant envoi OneGL
#[002] 07/11/2011 Roger Cassis  :spot:22859 Maj table Oracle pour Etl et gestion sauvegarde et archivage
#[003] 01/03/2012 Roger Cassis  :spot:23541 Archivage fichier MVT avec dates pour comptabilisation
#[004] 19/03/2012 Roger Cassis  :spot:23567 Gestion noms de fichiers et dates bilans
#[005] 02/05/2012 Roger Cassis  :spot:23699 Etape Oracle OneGL execut�e dans tous les cas
#[006] 20/06/2012 Roger Cassis  :spot:23914 Ajustement des parametres Onegl envoy�s � Oracle (CLOSING-TYPE)
#[007] 09/07/2012 Roger Cassis  :spot:23984 On force l'execution de onegl en periode de comptabilisation
#[008] 18/07/2012 Roger Cassis  :spot:23742 Si Ny ou Mutre -> Pas de gestion OneGL
#[009] 10/01/2013 Roger Cassis  :spot:24041 Ajustements pour archivage � New-york
#[010] 24/01/2013 Roger Cassis  :spot:24752 Gestion des fichiers archiv�s
#[011] 01/02/2013 Roger Cassis  :spot:24818 Activation Ny dans OneGL
#[012] 21/03/2013 Roger Cassis  :spot:25006 Ajout Mode 3 pour cas de non-execution OneGl
#[013] 01/07/2014 Roger Cassis  :spot:27046 - :spot:25773 For Mutre, nosave to ../oneGl
#[014] 01/07/2016 Roger Cassis  :spot:30646 Remet � blanc les 14 champs identifiants SAP avant envoi.
#[015] 27/04/2018 MZM           :spira:67063 Ajout Table Technique VTOM
#[016] 31/07/2018 Roger Cassis  :spira:69887 Le nom BATCH_LS charg� dans la table TVTOMLAUNCH est le nom de la chaine qui envoit les parametres : ESFD3850
#                                            et renommage OTGL0030I au lieu de OTGL0030*.
#[017] 19/07/2019 Roger Cassis  :spira:80028 Suppression de la gestion de flags obsolete avec parametre Force et du test du site FRAM.
#[018] 30/09/2019 Roger Cassis  :spira:81552 Remplacement du mode 0 par le mode 4 envoy� � SAP par l'intermediaire de VTOM.
#[019] 11/05/2020 Linh DOAN     :spira:85741 ESB + IFRS17 GLT to SAP
#[020] 19/07/2021 Linh DOAN	    :spira:97830 Mapping correction
#[021] 17/12/2021 Mr JYP        :spira:101025 new product catalog files OVR
#[022] 20/12/2021 Mr JYP        :spira:101025 new contrat_links files OVR
#[023] 01/02/2022 Mr JYP        :SPIRA 101782 : granularity move in other chain ESFD0040
#[018] 24/02/2022 Roger Cassis  :spira:100487 Manage MODE for SAP OneGL processing
#[019] 13/06/2022 Da David      :spira:100097 Manage MODE and add MODE=4 (SIMULATION)
#[020] 01/07/2022 Da David      :spira:105384 Execute PUT to OneGl firectory on 1 or 4 mode
#[021] 08/11/2022 TD/MZM       : spira:107662 Remove temporary file in ES*D3850 (OneGl interface) : Ajout du "${NJOB}_00_${IB}_" pour zip les fichiers
#[022] 23/03/2023 TD/MZM       : spira:109324 Interface SAP - Probleme de parametre CLOSING_TYPE  ; Et Suppression des Fichiers Temporaire 
#[023] 06/04/2023 JYP/TD       :spira:109414 when POC No SAP interface
#[024] 24/05/2023 JYP/TD       :spira:109832 remove temporary file after zipping into OneGl/to
#-----------------------------------------------------------------------------
# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd 
. ${DUTI}/fctora.cmd

# Get input parameters
CRE_D=${PARM_CRE_D}
INVCONSO_D=${PARM_INVCONSO_D}
CONSOYEA=${PARM_CONSOYEA}
CONSOMTH=${PARM_CONSOMTH}
CLODAT_D=${PARM_CLODAT_D}
PROCESSONEGL_CT=$1

#[016]
OneGLChain="ESFD3850_${NORME_CF}"

VSITE=""

# Job Initialisation
JOBINIT

#[003]
#ESF_FICTOONEGL1=ESFD3840_FTECLEDA_${NORME_CF}_MVT_${HOST_PRDSIT}
ESF_FICTOONEGL=${ESF_FICTOONEGL1}_${CRE_D}
#ESF_FICFROMONEGL=FTECLEDA_${NORME_CF}_MVT_${HOST_PRDSIT}_${CRE_D}
#[021]
NEW_ESF_FTECLEDA_MVT=${DFILT}/${ENV_PREFIX}_${ESF_FICTOONEGL}.dat
ESF_FICTOONEGLARC=${ESF_FICTOONEGL1}_${INVCONSO_D}_${CRE_D}

#[004]
CONSOMTH=`echo "${CONSOMTH}" | awk '{ if (length($0) < 2) print "0" $0; else print $0;}'`

#[006]
##CLOSING_TYPE=${NORME_CF}

#[022]
if [ "${TYPEINV}" = "POS" ]
then 
CLOSING_TYPE="post-closing"
else 
CLOSING_TYPE="closing"
fi


#[019]
# MODE="1" COMPTABILISATION
# MODE="3" L'interface OneGL ne tourne pas
# MODE="4" SIMULATION
MODE=""

if [ "${TYPEINV}" != "" ] && [ "${TYPEINV}" != "POC" ] &&  [ "${PROCESSONEGL_CT}" = "1" ] 
then
    if [ ${PARAM_IS_SAP_POSTING} = "Y" -o ${PARM_IS_COMPTA} = "Y" ]
    then
        MODE="1" # COMPTABILISATION
    else
        MODE="4" # SIMULATION
    fi	
else
    MODE="3" # L'interface OneGL ne tourne pas
fi

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


ECHO_LOG "#========================================================================="
ECHO_LOG "-> CLODAT_D ...............: ${CLODAT_D}"
ECHO_LOG "-> CONSOYEA ...............: ${CONSOYEA}"
ECHO_LOG "-> CONSOMTH ...............: ${CONSOMTH}"
ECHO_LOG "-> MODE ...................: ${MODE}"
ECHO_LOG "-> NORME_CF ...............: ${NORME_CF}"
ECHO_LOG "-> CLOSING_TYPE ...........: ${CLOSING_TYPE}"
ECHO_LOG "-> ESF_FICTOONEGL .........: ${ESF_FICTOONEGL}"
ECHO_LOG "-> ESF_FICTOONEGL1 ........: ${ESF_FICTOONEGL1}"
ECHO_LOG "-> ESF_FICTOONEGLARC ......: ${ESF_FICTOONEGLARC}"
ECHO_LOG "-> ESF_FICFROMONEGL .......: ${ESF_FICFROMONEGL}"
ECHO_LOG "-> NEW_ESF_FTECLEDA_MVT ...: ${NEW_ESF_FTECLEDA_MVT}"
ECHO_LOG "-> VSITE ..................: ${VSITE}"
ECHO_LOG "-> OneGLChain .............: ${OneGLChain}"
ECHO_LOG "#========================================================================="

if [ ! -f ${ESF_FTECLEDA_MVT} ]
then
        ECHO_LOG "ESF_FTECLEDA_MVT=${ESF_FTECLEDA_MVT}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_FTECLEDA_MVT}"
fi

# only if booking
# if [ "${PROCESSONEGL_CT}" = "1" ] &&
# 	 [ ${PARAM_IS_SAP_POSTING} = "Y" -o ${PARM_IS_COMPTA} = "Y" ]
#[020]
if [[ "${MODE}" = "1" || "${MODE}" = "4" ]]
then
	#L'interface OneGL tourne
	# MODE=1
	#COMPTABILISATION
	#[002] [009]
	NSTEP=${NJOB}_10
	# Copy to Tosave
	#----------------------------------------------------------------------------
	LIBEL="Copy MVT file to tosave"
	EXECKSH_MODE=P     
	EXECKSH "gzip -c ${ESF_FTECLEDA_MVT} > ${DTRANSFER}/OneGL/tosave/${ENV_PREFIX}_${ESF_FICTOONEGL}.dat.gz"	

   if [ "${MODE}" = "4" ]
   then  
		NSTEP=${NJOB}_20
		# Begin execksh
		#-----------------------------------------------------------------
		LIBEL="copy MVT to ${DSAV}/${ENV_PREFIX}_${ESF_FICTOONEGLARC}.dat"
		EXECKSH_MODE=P
		EXECKSH "gzip -c ${ESF_FTECLEDA_MVT} > ${DSAV}/${ENV_PREFIX}_${ESF_FICTOONEGLARC}.dat.gz"
  else 
		NSTEP=${NJOB}_25
		# Begin execksh
		#-----------------------------------------------------------------
		LIBEL="copy MVT to ${DARCH}/${ENV_PREFIX}_${ESF_FICTOONEGLARC}.dat"
		EXECKSH_MODE=P
		EXECKSH "gzip -c ${ESF_FTECLEDA_MVT} > ${DARCH}/${ENV_PREFIX}_${ESF_FICTOONEGLARC}.dat.gz"
  fi 
 
 

	#[014]
	NSTEP=${NJOB}_30
	# Merge FTECLEDA_CUR and FTECLEDA_MVT
	#--------------------------------
	LIBEL="Blank to 14 SAP columns"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${ESF_FTECLEDA_MVT} 1000 1"
	SORT_O="${NEW_ESF_FTECLEDA_MVT} 1000 1"
	INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
  Filler1    1:1 -  88:,
  Filler2  103:1 - 118:
/DERIVEDFIELD PLUS_14_CHAMPS 14"~"
/COPY
/OUTFILE ${SORT_O}
/REFORMAT Filler1, PLUS_14_CHAMPS, Filler2
exit
EOF
	SORT

	#[016]  	
	NSTEP=${NJOB}_40          
	#  ISQL to delete any entry on vTOM table paramter for OTGL0030
	#------------------------------------------------------------------------------
	LIBEL="Remove existing paramter for VTOM"        
	ISQL_BASE="BTEC"		
	ISQL_QRY="delete from BTEC..TVTOMLAUNCH  where PARM2='${HOST_PRDSIT}' and PARM8='OTGL0030' and BATCH_LS='${OneGLChain}' " 
	ISQL
 	
	#[002]
	#[006]
	#[015] [016]
	NSTEP=${NJOB}_50
	#  ISQL to insert paramter on vTOM table for OTGL0030
	#------------------------------------------------------------------------------
	LIBEL="ISQL to insert paramter on vTOM table for OTGL0030"
	ISQL_BASE="BTEC"
	ISQL_QRY="insert into BTEC..tvtomlaunch (BATCHUSR_CF,BATCH_LS,PARM1,PARM2,PARM3,PARM4,PARM5,PARM6,PARM7,PARM8) values ('${VSITE}','${OneGLChain}','${CLOSING_TYPE}','${HOST_PRDSIT}','${CONSOYEA}','${CONSOMTH}','${MODE}','${ESF_FICTOONEGL}','${ESF_FICFROMONEGL}','OTGL0030')"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log			
	ISQL
  	
	NSTEP=${NJOB}_60
	# ZIP
	#----------------------------------------------------------------------------
	LIBEL="Beginning of a ZIP session"
	ZIP_MODE="Z" 
	ZIP_ODIR="${DTRANSFER}/OneGL/to"  
	ZIP_I="${NEW_ESF_FTECLEDA_MVT}"
	ZIP_O="${ENV_PREFIX}_${ESF_FICTOONEGL}.zip"
	ZIP_OPT=""
	ZIP

    NSTEP=${NJOB}_65
    #-----------------------------------------------------------------------------
    LIBEL="remove temporary file NEW_ESF_FTECLEDA_MVT=$NEW_ESF_FTECLEDA_MVT  "
    EXECKSH_MODE=P
    EXECKSH "rm -f $NEW_ESF_FTECLEDA_MVT  "
  	
else
	#INVENTAIRE(SIMU)
	#[015] [016]
	NSTEP=${NJOB}_70
	#  ISQL to delete any entry on vTOM table paramter for OTGL0030
	#------------------------------------------------------------------------------
	LIBEL="Remove existing paramter for vTOM"
	ISQL_BASE="BTEC"
	ISQL_QRY="delete BTEC..tvtomlaunch where PARM2='${HOST_PRDSIT}' and PARM8='OTGL0030' and BATCH_LS='${OneGLChain}' "
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
	ISQL

	#[016]
	NSTEP=${NJOB}_80
	#  ISQL to insert paramter on vTOM table for OTGL0030
	#------------------------------------------------------------------------------
	LIBEL="insert paramter on vTOM table for OTGL0030"
	ISQL_BASE="BTEC"
	ISQL_QRY="insert into BTEC..tvtomlaunch (BATCHUSR_CF,BATCH_LS,PARM1,PARM2,PARM3,PARM4,PARM5,PARM6,PARM7,PARM8) values ('${VSITE}','${OneGLChain}','${CLOSING_TYPE}','${HOST_PRDSIT}','${CONSOYEA}','${CONSOMTH}','${MODE}','${ESF_FICTOONEGL}','${ESF_FICFROMONEGL}','OTGL0030')"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
	ISQL		
						
fi

NSTEP=${NJOB}_90
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"
RMFIL "${DFILT}/${ENV_PREFIX}_${FICTOONEGL}.dat"

JOBEND

