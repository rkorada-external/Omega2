#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESFD0041.cmd
# date de creation              : 08/11/2023
# auteur                        : JYP - PERSEE
# references des specifications :
#-----------------------------------------------------------------------------
# description : Granularity product codes 
#
#-----------------------------------------------------------------------------
# historiques des modifications
#=================================================================================================
#[001] 08/11/2023 JYP : Spira 110086 : creation
#[002] 20/12/2023 JYP : Spira 110086 : manage prm and bugfix
#[003] 10/11/2024 JYP : Spira 110086 : manage maintenance file
#[004] 11/11/2024 JYP : Spira 110086 : complete checks
#===============================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd
. ${DUTI}/fctftp.cmd

# Job Initialization
JOBINIT

TODAY=`date '+%Y%m%d' `

#---------------------------------------------------------------------------
NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="load mapping, specific chain for all NORME "
ISQL_BASE=BEST
ISQL_O=${DFILT}/${NSTEP}_${IB}_ESFD0050.dat
ISQL_QRY="select 'export ' +  PERMFIL_CT + '=\"' + pathpattrn_ll + '\"' from BEST..TI17PERMFIL where IDF_CT = 'ESFD0050' "
ECHO_LOG "ISQL_QRY = [ $ISQL_QRY ] "
ISQL

grep export ${DFILT}/${NSTEP}_${IB}_ESFD0050.dat  > ${DFILT}/${ENV_PREFIX}_ESFD0050_${IB}_PERMFIL.dat
. ${DFILT}/${ENV_PREFIX}_ESFD0050_${IB}_PERMFIL.dat
cat ${DFILT}/${ENV_PREFIX}_ESFD0050_${IB}_PERMFIL.dat | sed 's/    //g' >> $FLOG 


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> IDF_CT.....................: ${IDF_CT} "
ECHO_LOG "#===> ENV_SAP_I4I................: $ENV_SAP_I4I"
ECHO_LOG "#===> ENV_SAP_NotI4I.............: $ENV_SAP_NotI4I"
ECHO_LOG "#===> SITE_ONEGL.................: $SITE_ONEGL"
ECHO_LOG "#===> TODAY......................: $TODAY "
ECHO_LOG "#===>     -------- input  ---------"
ECHO_LOG "#===> ESF_SAP_FTP_FILE...........: $ESF_SAP_FTP_FILE "
ECHO_LOG "#===> ESF_MAINTENANCE_SETUP......: $ESF_MAINTENANCE_SETUP "
ECHO_LOG "#===>     -------- output  ---------"
ECHO_LOG "#===> ESF_SAP_GAAPS_FILTER.......: $ESF_SAP_GAAPS_FILTER "
ECHO_LOG "#===> ESF_SAP_ARCH_FILE..........: $ESF_SAP_ARCH_FILE "


#--------------------------------------------------------------------------- 
NSTEP=${NJOB}_15
#------------------------------------------------------------------------------
LIBEL="touch setup file ESF_SAP_GAAPS_FILTER=$ESF_SAP_GAAPS_FILTER "
if [ ! -f $ESF_SAP_GAAPS_FILTER ]
then
   EXECKSH_MODE=P
   EXECKSH "touch $ESF_SAP_GAAPS_FILTER "
fi 

LIBEL="touch setup file ESF_MAINTENANCE_SETUP=$ESF_MAINTENANCE_SETUP "
if [ ! -f $ESF_MAINTENANCE_SETUP ]
then
   EXECKSH_MODE=P
   EXECKSH "touch $ESF_MAINTENANCE_SETUP "
fi 


if [ "$ENV_SAP_I4I" = "1" ] || [ "$ENV_SAP_NotI4I" = "1" ] 
then
  echo "SAP prm is activated, need to FTPget the new setup file " 
  ECHO_LOG "SAP prm is activated, need to FTPget the new setup file "  
else 
  echo "SAP prm is NOT activated, no need to FTPget the new setup file " 
  ECHO_LOG "SAP prm is NOT activated, no need to FTPget the new setup file " 
  JOBEND
fi 



NSTEP=${NJOB}_17
#-----------------------------------------------------------------
LIBEL="clean DFILT for our file ${ENV_PREFIX}_${ESF_SAP_FTP_FILE} "
rm ${DFILT}/${ENV_PREFIX}_${ESF_SAP_FTP_FILE}*
ECHO_LOG "rm ${DFILT}/${ENV_PREFIX}_${ESF_SAP_FTP_FILE}* : RC=$? "



NSTEP=${NJOB}_20
# FTP - Get  from OneGL server
# ----------------
LIBEL="Get ESF_SAP_FTP_FILE  from OneGL server ${SITE_ONEGL}"
FTP_FILE=${DFILT}/${ENV_PREFIX}_${ESF_SAP_FTP_FILE}*.zip
FTP_SITE=${SITE_ONEGL}
FTP_MODE=binary
FTP_WAY=MGET
FTP
				
if [ -s ${DFILT}/${ENV_PREFIX}_${ESF_SAP_FTP_FILE}*.zip ]
then

        ONEGLFILEZIP=`ls -rt ${DFILT}/${ENV_PREFIX}_${ESF_SAP_FTP_FILE}*.zip | tail -1`

        echo "File to unzip: ${ONEGLFILEZIP}"
        NSTEP=${NJOB}_30
        LIBEL="UNZIP File ONEGLFILEZIP=$ONEGLFILEZIP"
        #-----------------------------------------------------------------
        ZIP_ODIR=${DFILT}
        ZIP_I=${ONEGLFILEZIP}
        ZIP_OPT=""
        PKUNZIP
fi


ls -l ${DFILT}/${ENV_PREFIX}_${ESF_SAP_FTP_FILE}*.dat


FILE_TODELETE="N"
if [ -s ${DFILT}/${ENV_PREFIX}_${ESF_SAP_FTP_FILE}*.dat ]
then
    FILE_TODELETE="Y"
    ONEGLFILEDAT=`ls -rt ${DFILT}/${ENV_PREFIX}_${ESF_SAP_FTP_FILE}*.dat | tail -1`
    ECHO_LOG "File to move: ${ONEGLFILEDAT}"

    NSTEP=${NJOB}_40
    #-----------------------------------------------------------------
    LIBEL="copy ${ONEGLFILEDAT} to ${DFILT}/${NSTEP}_${IB}_${ESF_SAP_FTP_FILE}.dat"
    EXECKSH_MODE=P
    EXECKSH "tr -d '\r' <${ONEGLFILEDAT} > ${DFILT}/${NSTEP}_${IB}_${ESF_SAP_FTP_FILE}.dat"


    NSTEP=${NJOB}_50
    #-----------------------------------------------------------------
    LIBEL="check if setup from SAP should be used : DFILT/${NJOB}_40_${IB}_${ESF_SAP_FTP_FILE}.dat "
    nb_setup=`wc -l ${DFILT}/${NJOB}_40_${IB}_${ESF_SAP_FTP_FILE}.dat  | cut -d" " -f1 `
    nb_fields=`awk  'BEGIN{FS="~" } { print NF} ' ${DFILT}/${NJOB}_40_${IB}_${ESF_SAP_FTP_FILE}.dat    | sort -u | head -1`
    
    cat ${DFILT}/${NJOB}_40_${IB}_${ESF_SAP_FTP_FILE}.dat | sort -u | cut -d~ -f1,2 |  uniq -c | grep -v " 1 " > ${DFILT}/${NJOB}_50_${IB}_SAP_DUPLICATES.dat
    nb_duplicate=`wc -l ${DFILT}/${NJOB}_50_${IB}_SAP_DUPLICATES.dat  | cut -d" " -f1 `
    
    EXECKSH_MODE=P
    EXECKSH "echo nb_setup=$nb_setup nb_fields=$nb_fields nb_duplicate=$nb_duplicate "
	
	if [ $nb_setup -lt 5 ] || [ $nb_fields -ne 3 ] || [ $nb_duplicate -ne 0 ]	
	then 
		ECHO_LOG "  "
		ECHO_LOG "#==============================================================="
		ECHO_LOG "#===> cannot override ESF_SAP_GAAPS_FILTER=$ESF_SAP_GAAPS_FILTER"
		ECHO_LOG "#===> WRONG FILE received but NOT used => the closing can continue, just alert SAP team please"
		ECHO_LOG "#==============================================================="
		ECHO_LOG "  "
		STEPEND 1
		
    else 
		NSTEP=${NJOB}_60
		#-----------------------------------------------------------------
		LIBEL="merge $ESF_SAP_GAAPS_FILTER with $ESF_MAINTENANCE_SETUP "
        EXECKSH_MODE=P
        EXECKSH "cat ${DFILT}/${NJOB}_40_${IB}_${ESF_SAP_FTP_FILE}.dat $ESF_MAINTENANCE_SETUP | sort -u > ${DFILT}/${NJOB}_60_${IB}_ALL_SETUP.dat "

        cat ${DFILT}/${NJOB}_60_${IB}_ALL_SETUP.dat | cut -d~ -f1,2 |  uniq -c | grep -v " 1 " > ${DFILT}/${NJOB}_60_${IB}_SAP_DUPLICATES.dat
        nb_duplicate=`wc -l ${DFILT}/${NJOB}_60_${IB}_SAP_DUPLICATES.dat  | cut -d" " -f1 `

	    if [ $nb_duplicate -ne 0 ]	
	    then 
	    	ECHO_LOG "  "
	    	ECHO_LOG "#==============================================================="
	    	ECHO_LOG "#===> duplicate SSD/ESB found : cannot merge SAPsetup with ESF_MAINTENANCE_SETUP=$ESF_MAINTENANCE_SETUP "
	    	ECHO_LOG "#===> the new setup is NOT used => the closing can continue"
	    	ECHO_LOG "#==============================================================="
	    	ECHO_LOG "  "
	    	STEPEND 2
		else 
		   NSTEP=${NJOB}_65
		   #-----------------------------------------------------------------
		   LIBEL="ALL CHECKS OK : override $ESF_SAP_GAAPS_FILTER  "
           EXECKSH_MODE=P
           EXECKSH "cp ${DFILT}/${NJOB}_60_${IB}_ALL_SETUP.dat $ESF_SAP_GAAPS_FILTER  "
        fi 	
	
		ls -ltr $ESF_SAP_GAAPS_FILTER
		wc -l   $ESF_SAP_GAAPS_FILTER
	fi 

fi



if [ ${FILE_TODELETE} = "Y" ]
then

        #[004]
        NSTEP=${NJOB}_70
        # Copy to Tosave
        #----------------------------------------------------------------------------
        LIBEL="Copy file to DTRANSFER/fromsave"
        EXECKSH_MODE=P
        EXECKSH "gzip -c ${ONEGLFILEDAT} > ${DTRANSFER}/OneGL/fromsave/${ENV_PREFIX}_${ESF_SAP_FTP_FILE}_${TODAY}_$$.dat.gz"

        #[005]
        NSTEP=${NJOB}_80
        # ARCHIVAGE
        #----------------------------------------------------------------------------
        LIBEL="Archive new file ESF_SAP_GAAPS_FILTER into DSAV/${SVG}_${ENV_PREFIX}_${ESF_SAP_ARCH_FILE}_${TODAY}_$$.dat.gz "
        EXECKSH_MODE=P
        EXECKSH "gzip -c ${ESF_SAP_GAAPS_FILTER} > ${DSAV}/${SVG}_${ENV_PREFIX}_${ESF_SAP_ARCH_FILE}_${TODAY}_$$.dat.gz"

        NSTEP=${NJOB}_90
        # ----------------
        LIBEL="Delete ESF_SAP_FTP_FILE on OneGL server "
        FTP_FILE=${ENV_PREFIX}_${ESF_SAP_FTP_FILE}*.zip
        FTP_I=${ENV_PREFIX}_${ESF_SAP_FTP_FILE}*.zip
        FTP_SITE=${SITE_ONEGL}
        FTP_WAY=MDEL2
        FTP

fi


JOBEND

                     
