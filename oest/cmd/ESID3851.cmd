#!/bin/ksh
#=============================================================================
# nom de l'application   : ESTIMATIONS - preparation des fichiers pour one GL
# nom du script SHELL    : ESID3851.cmd
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
#[005] 02/05/2012 Roger Cassis  :spot:23699 Etape Oracle OneGL executée dans tous les cas
#[006] 20/06/2012 Roger Cassis  :spot:23914 Ajustement des parametres Onegl envoyés à Oracle (CLOSING-TYPE)
#[007] 09/07/2012 Roger Cassis  :spot:23984 On force l'execution de onegl en periode de comptabilisation
#[008] 18/07/2012 Roger Cassis  :spot:23742 Si Ny ou Mutre -> Pas de gestion OneGL
#[009] 10/01/2013 Roger Cassis  :spot:24041 Ajustements pour archivage à New-york
#[010] 24/01/2013 Roger Cassis  :spot:24752 Gestion des fichiers archivés
#[011] 01/02/2013 Roger Cassis  :spot:24818 Activation Ny dans OneGL
#[012] 21/03/2013 Roger Cassis  :spot:25006 Ajout Mode 3 pour cas de non-execution OneGl
#[013] 01/07/2014 Roger Cassis  :spot:27046 - :spot:25773 For Mutre, nosave to ../oneGl
#[014] 01/07/2016 Roger Cassis  :spot:30646 Remet à blanc les 14 champs identifiants SAP avant envoi.
#[015] 27/04/2018 MZM           :spira:67063 Ajout Table Technique VTOM
#[016] 31/07/2018 Roger Cassis  :spira:69887 Le nom BATCH_LS chargé dans la table TVTOMLAUNCH est le nom de la chaine qui envoit les parametres : ESID3850
#                                            et renommage OTGL0010I au lieu de OTGL0010*.
#[017] 19/07/2019 Roger Cassis  :spira:80028 Suppression de la gestion de flags obsolete avec parametre Force et du test du site FRAM.
#[018] 30/09/2019 Roger Cassis  :spira:81552 Remplacement du mode 0 par le mode 4 envoyé à SAP par l'intermediaire de VTOM.
#[019] 22/07/2020 Linh DOAN     :spira:88544 Filter DAC IFRS 17 in SAP interface
#[020] 03/02/2022 T. DEUTSCH   : spira:100097
#[021] 06/07/2022 TD/JYP       : spira:100097 bugfix
#[022] 08/11/2022 TD/MZM       : spira:107662 Remove temporary file in ES*D3850 (OneGl interface) : Ajout ${DFILT}/${NJOB}_00_${IB}_${ENV_PREFIX} 
#[023] 13/01/2023 MiS           :spira:108408 Remplacement de OTGL0010 par OTGL0030
#-----------------------------------------------------------------------------
# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd 
. ${DUTI}/fctora.cmd

# Get input parameters
CRE_D=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CLODAT_D=$4
PROCESSONEGL_CT=$5
MODE=""
#[016]
OneGLChain=ESID3850

VSITE=""

# Job Initialisation
JOBINIT

#[003]
FICTOONEGL1=ESID3800_FTECLEDA_MVT_${HOST_PRDSIT}
FICTOONEGL=ESID3800_FTECLEDA_MVT_${HOST_PRDSIT}_${CRE_D}
FICFROMONEGL=FTECLEDA_MVT_${HOST_PRDSIT}_${CRE_D}
#[022]
NEW_EST_FTECLEDA_MVT=${DFILT}/${ENV_PREFIX}_${FICTOONEGL}.dat
FICTOONEGLARC=${FICTOONEGL1}

#[004]
BALSHTMTH_NF=`echo "${BALSHTMTH_NF}" | awk '{ if (length($0) < 2) print "0" $0; else print $0;}'`

#[006]
CLOSING_TYPE="closing"

#[012]
#L'interface OneGL ne tourne pas
MODE="3"

#[018][020]
if [ ${EST_VARIANTE} = 3 -o ${EST_VARIANTE} = 4 ] &&
	[ "${PROCESSONEGL_CT}" = "1" ] && [ "${TYPEINV}" = "INV" ] 
then
	#INVENTAIRE(SIMU)
	MODE="4"
fi
#[004]
if [ ${EST_VARIANTE} = "5" ] || [ ${EST_VARIANTE} = "6" ] || [ ${EST_VARIANTE} = "8" ]
then
	#COMPTABILISATION
	MODE="1"
	FICTOONEGLARC=${FICTOONEGL1}_${CLODAT_D}_${BALSHTYEA_NF}${BALSHTMTH_NF}_${CRE_D}_${EST_VARIANTE}
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
ECHO_LOG "-> BALSHTYEA_NF ...........: ${BALSHTYEA_NF}"
ECHO_LOG "-> BALSHTMTH_NF ...........: ${BALSHTMTH_NF}"
ECHO_LOG "-> MODE ...................: ${MODE}"
ECHO_LOG "-> CLOSING_TYPE ...........: ${CLOSING_TYPE}"
ECHO_LOG "-> FICTOONEGL .............: ${FICTOONEGL}"
ECHO_LOG "-> FICTOONEGL1 ............: ${FICTOONEGL1}"
ECHO_LOG "-> FICTOONEGLARC ..........: ${FICTOONEGLARC}"
ECHO_LOG "-> FICFROMONEGL ...........: ${FICFROMONEGL}"
ECHO_LOG "-> NEW_EST_FTECLEDA_MVT ...: ${NEW_EST_FTECLEDA_MVT}"
ECHO_LOG "-> VSITE ..................: ${VSITE}"
ECHO_LOG "-> OneGLChain .............: ${OneGLChain}"
ECHO_LOG "#========================================================================="


#[002]
#[007]
#[020]
if ( [ "${PROCESSONEGL_CT}" = "1" ] ||
	[ ${EST_VARIANTE} = "5" ] || [ ${EST_VARIANTE} = "6" ] || [ ${EST_VARIANTE} = "8" ] ) && [ "${TYPEINV}" = "INV" ]
then

	#[002] [009]
	NSTEP=${NJOB}_10
	# Copy to Tosave
	#----------------------------------------------------------------------------
	LIBEL="Copy MVT file to tosave"
	EXECKSH_MODE=P     
	EXECKSH "gzip -c ${EST_FTECLEDA_MVT} > ${DTRANSFER}/OneGL/to/${ENV_PREFIX}_${FICTOONEGL}.dat.gz"	

	#[013]
	NSTEP=${NJOB}_20
	# Begin execksh
	#-----------------------------------------------------------------
	LIBEL="copy MVT to ${DARCH}/${ENV_PREFIX}_${FICTOONEGLARC}.dat"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${EST_FTECLEDA_MVT} > ${DARCH}/${ENV_PREFIX}_${FICTOONEGLARC}.dat.gz"

	#[014] #[019]
	NSTEP=${NJOB}_30
	# Merge FTECLEDA_CUR and FTECLEDA_MVT
	#--------------------------------
	LIBEL="Blank to 14 SAP columns"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${EST_FTECLEDA_MVT} 1000 1"
	SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA_MVT_MRG.dat 1000 1"
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

#[019]
        NSTEP=${NJOB}_35
        # Merge FTECLEDA_CUR and FTECLEDA_MVT + Filter DAC IFRS 17
        #--------------------------------
        LIBEL="Filter DAC IFRS 17 in SAP interface"
        SORT_WDIR=${SORTWORK}
        SORT_CMD=`CFTMP`
        SORT_I="${DFILT}/${NJOB}_30_${IB}_FTECLEDA_MVT_MRG.dat 1000 1"
        SORT_O="${NEW_EST_FTECLEDA_MVT} 1000 1"
        INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
  TRNCOD8_CF         6:8 -  6:8
/CONDITION COND_I17G  TRNCOD8_CF EQ "I"
/OUTFILE ${SORT_O} OVERWRITE
/OMIT COND_I17G

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
	ISQL_QRY="insert into BTEC..tvtomlaunch (BATCHUSR_CF,BATCH_LS,PARM1,PARM2,PARM3,PARM4,PARM5,PARM6,PARM7,PARM8) values ('${VSITE}','${OneGLChain}','${CLOSING_TYPE}','${HOST_PRDSIT}','${BALSHTYEA_NF}','${BALSHTMTH_NF}','${MODE}','${FICTOONEGL}','${FICFROMONEGL}','OTGL0030')"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log			
	ISQL
  	
	NSTEP=${NJOB}_60
	# ZIP
	#----------------------------------------------------------------------------
	LIBEL="Beginning of a ZIP session"
	ZIP_MODE="Z" 
	ZIP_ODIR="${DTRANSFER}/OneGL/to"  
	ZIP_I="${NEW_EST_FTECLEDA_MVT}"
	ZIP_O="${ENV_PREFIX}_${FICTOONEGL}.zip"
	ZIP_OPT=""
	ZIP
  	
else

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
	ISQL_QRY="insert into BTEC..tvtomlaunch (BATCHUSR_CF,BATCH_LS,PARM1,PARM2,PARM3,PARM4,PARM5,PARM6,PARM7,PARM8) values ('${VSITE}','${OneGLChain}','${CLOSING_TYPE}','${HOST_PRDSIT}','${BALSHTYEA_NF}','${BALSHTMTH_NF}','${MODE}','${FICTOONEGL}','${FICFROMONEGL}','OTGL0030')"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
	ISQL		
						
fi

NSTEP=${NJOB}_100
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"
RMFIL "${DFILT}/${ENV_PREFIX}_${FICTOONEGL}.dat"

JOBEND

