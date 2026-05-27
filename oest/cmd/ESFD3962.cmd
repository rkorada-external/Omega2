#!/bin/ksh
#=============================================================================
# nom de l'application     : ESTIMATIONS - download SAP File One GL
# nom du script SHELL      : ESFD3962.cmd
# date de creation         : 12/04/2023
# auteur                   : JYP+TD
#-----------------------------------------------------------------------------
# historiques des modifications :
#===============================================================================
#[001]	18/04/2023 JYP/TD  :spira:109178: new version created from old ESFD3961 
#[002]  20/04/2023 JYP/TD  :spira:109440 : check SAP return files and recover
#[003]  22/10/2025 Sir JYP :INC0454273 : bugfix when SIMU, conflict of tmp files
#-----------------------------------------------------------------------------

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd 
. ${DUTI}/fctftp.cmd


FLAG_ERR_WARN=$1
FLAG_FTPMGET=$2
RECOVER_CHAIN=$3

# Job Initialisation
JOBINIT


ECHO_LOG "#========================================================================="
ECHO_LOG "-> CRE_D ..................: ${PARM_CRE_D}"
ECHO_LOG "-> INVCONSO_D .............: ${PARM_INVCONSO_D}"
ECHO_LOG "-> CONSOYEA ...............: ${PARM_CONSOYEA}"
ECHO_LOG "-> CONSOMTH ...............: ${PARM_CONSOMTH}"
ECHO_LOG "-> ESF_FTECLEDA_MVT_TMP .......: ${ESF_FTECLEDA_MVT_TMP}"
ECHO_LOG "-> ESF_FTECLEDA_MVT ...........: ${ESF_FTECLEDA_MVT}"
ECHO_LOG "-> ESF_RECOVERY_STATUS ........: ${ESF_RECOVERY_STATUS}"
ECHO_LOG "-> ESF_POSTING_UPD_STATUS .....: ${ESF_POSTING_UPD_STATUS}"
ECHO_LOG "-> ESF_FICFROMONEGL ...........: ${ESF_FICFROMONEGL}"
ECHO_LOG "-> ESF_FICFROMONEGLARC ........: ${ESF_FICFROMONEGLARC}"
ECHO_LOG "-> SITE_ONEGL .................: ${SITE_ONEGL}"
ECHO_LOG "-> RUNNING_ON_SERVER ..........: ${SRV}"
ECHO_LOG "-> RECOVER_CHAIN(Y=for ESFD4060):${RECOVER_CHAIN}"
ECHO_LOG "-> FLAG_ERR_WARN ..............: ${FLAG_ERR_WARN}"
ECHO_LOG "-> FLAG_FTPMGET ...............: ${FLAG_FTPMGET}"
ECHO_LOG "-> SAP Interface (0=NO/1=YES)..: ${ENV_SAP}"
ECHO_LOG "-> SAP MODE (4=SIMU/1=COMPTA)..: ${MODE}"
ECHO_LOG "#========================================================================="


NSTEP=${NJOB}_01
#------------------------------------------------------------------------------------
LIBEL="MANAGE UNFOUND FILES "

if [ ! -f ${ESF_FTECLEDA_POSTING} ]
then
        ECHO_LOG "ESF_FTECLEDA_POSTING=${ESF_FTECLEDA_POSTING}  does not exist, take an empty file"     >> $FLOG
        EXECKSH "touch ${ESF_FTECLEDA_POSTING}"
fi


if [ ! -f ${ESF_FTECLEDA_MVT_PREV} ]
then
        ECHO_LOG "ESF_FTECLEDA_MVT_PREV=${ESF_FTECLEDA_MVT_PREV}  does not exist, take an empty file"     >> $FLOG
        EXECKSH "touch ${ESF_FTECLEDA_MVT_PREV}"
fi




########################################################################################
# Debut execution premier run. 
# En second run apres KO, comme le fichier existe dans DFILT on sautera cette partie
##########################################################################################

# SAP File treatment
if [ "${ENV_SAP}" = "0" ] || [ "$FLAG_FTPMGET" = "N" ] 
then

	ECHO_LOG "#===================================================================================================================="
	ECHO_LOG "# SAP NOT Processing  OneGL on ${SRV} : SAP_ENV.prm is ${ENV_SAP} (0=NO/1=YES) and MODE is ${MODE} (4=SIMU/1=COMPTA) "
	ECHO_LOG "# copy ${ESF_FTECLEDA_MVT_PREV} to ${ESF_FTECLEDA_MVT_TMP}                  "
	ECHO_LOG "#===================================================================================================================="
	# copy IN to OUT
	cp -a ${ESF_FTECLEDA_MVT_PREV} ${ESF_FTECLEDA_MVT_TMP}
	ECHO_LOG "rcode=$? "
	wc -l ${ESF_FTECLEDA_MVT_TMP} >> $FLOG 
    JOBEND
else

		ECHO_LOG "#=========================================================================="
		ECHO_LOG "# SAP Processing  OneGL on ${SRV} : Param is ${ENV_SAP}  (0=NO/1=YES)      "
		ECHO_LOG "#=========================================================================="
	
	
		NSTEP=${NJOB}_10
		# FTP - Get FTECLEDA_MVT OneGL data from OneGL server
		# ----------------
		LIBEL="Get FTECLEDA_MVT OneGL data from OneGL server ${SITE_ONEGL}"
		FTP_FILE=${DFILT}/${ENV_PREFIX}_${ESF_FICFROMONEGL}*.zip
		FTP_SITE=${SITE_ONEGL}
		FTP_MODE=binary
		FTP_WAY=MGET
		FTP
	
		if [ -s ${DFILT}/${ENV_PREFIX}_${ESF_FICFROMONEGL}*.zip ]
		then
	
			ONEGLFILEZIP=`ls -rt ${DFILT}/${ENV_PREFIX}_${ESF_FICFROMONEGL}*.zip | tail -1`
	
			echo "File to unzip: ${ONEGLFILEZIP}"	
			NSTEP=${NJOB}_20
			LIBEL="UNZIP Cessions File"
			#-----------------------------------------------------------------
			ZIP_ODIR=${DFILT}
			ZIP_I=${ONEGLFILEZIP}
			ZIP_OPT=""
			PKUNZIP
		fi


		if [ ! -f ${DFILT}/${ENV_PREFIX}_${ESF_FICFROMONEGL}*.dat ] 
		then


		 if [ "$FLAG_ERR_WARN" = "E" ]
		 then 

			#=== spira 109440 : when SAP_POSTING date, update flag NOT to update POSTING file later
			if [ "${PARAM_IS_SAP_POSTING}" = "Y" -a "${RECOVER_CHAIN}" = "Y" ] 
			then 
			
				#---- init PRM if not exists to avoid failure
				ESFD3460_PRM=${DPRM}/ESFD3460_RECOVERY_${NORME_CF}.prm 
				ESFD3960_PRM=${DPRM}/ESFD3960_SAPPOSTING_${NORME_CF}.prm 
				if [ "${NORME_CF}" = "EBS" ]
				then 
					ESXJ8990_PRM=${DPRM}/ESPJ8990_REQUEST_${NORME_CF}.prm 
				else 
					ESXJ8990_PRM=${DPRM}/ESFJ8990_REQUEST_${NORME_CF}.prm 
				fi 
					
				if [ ! -f $ESFD3460_PRM ]
				then
					NSTEP=${NJOB}_22
					#-----------------------------------------------------------------------------
					LIBEL="init of 3 PRM once : $ESFD3460_PRM $ESFD3960_PRM $ESXJ8990_PRM  "
					EXECKSH_MODE=P
					EXECKSH "touch $ESFD3460_PRM "
					touch $ESFD3960_PRM
					touch $ESXJ8990_PRM
				fi 
			
			    #-- flags for next run ESFD3960/ESFD3460/ES?J8990 , updated only once to Y
				if [ "$RECOVERY_MODE" != "Y" ]
				then 


					NSTEP=${NJOB}_24
					#-----------------------------------------------------------------------------
					LIBEL="set RECOVERY_MODE=Y into ${ESFD3460_PRM}   "
					AWK_I=${ESFD3460_PRM}
					AWK_O=${DFILT}/${NJOB}_22_${IB}_RECOVERY_${NORME_CF}.dat
					AWK_CMD=`CFTMP`
					INPUT_TEXT ${AWK_CMD} <<EOF
					{ 
					if (substr(\$1,1, 13) != "RECOVERY_MODE" ) 
						{print \$0;}
					}
					END { print "RECOVERY_MODE Y";} 
					exit
EOF
					cat $AWK_CMD >> $FLOG
					AWK
					cp -p ${DFILT}/${NJOB}_22_${IB}_RECOVERY_${NORME_CF}.dat ${ESFD3460_PRM}
				
					NSTEP=${NJOB}_26
					#-----------------------------------------------------------------------------
					LIBEL="set POSTING_UPDATE_CANCELED=Y into ${ESFD3960_PRM}  "
					AWK_I=${ESFD3960_PRM}
					AWK_O=${DFILT}/${NJOB}_26_${IB}_POSTING_UPDATE_CANCELED_${NORME_CF}.dat
					AWK_CMD=`CFTMP`
					INPUT_TEXT ${AWK_CMD} <<EOF
					{ 
					if (substr(\$1,1,23) != "POSTING_UPDATE_CANCELED" ) 
						{print \$0;}
					}
					END { print "POSTING_UPDATE_CANCELED Y";} 
					exit
EOF
					AWK
					cp -p ${DFILT}/${NJOB}_26_${IB}_POSTING_UPDATE_CANCELED_${NORME_CF}.dat ${ESFD3960_PRM}

					NSTEP=${NJOB}_28
					#-----------------------------------------------------------------------------
					LIBEL="set CLOSING_REQUEST_CANCELED=Y into ${ESXJ8990_PRM}  "
					AWK_I=${ESXJ8990_PRM}
					AWK_O=${DFILT}/${NJOB}_28_${IB}_CLOSING_REQUEST_CANCELED_${NORME_CF}.dat
					AWK_CMD=`CFTMP`
					INPUT_TEXT ${AWK_CMD} <<EOF
					{ 
					if (substr(\$1,1,24) != "CLOSING_REQUEST_CANCELED" ) 
						{print \$0;}
					}
					END { print "CLOSING_REQUEST_CANCELED Y";} 
					exit
EOF
					AWK
					cp -p ${DFILT}/${NJOB}_28_${IB}_CLOSING_REQUEST_CANCELED_${NORME_CF}.dat ${ESXJ8990_PRM}

				else
					ECHO_LOG "--> FLAGS to recover already=Y from previous run "					
				fi 


			fi # SAP POSTING from RECOVER_CHAIN ESFD3460


			ECHO_LOG ""
			ECHO_LOG "#==============================================================="
			ECHO_LOG "#======> read file ESF_FICFROMONEGL=${ESF_FICFROMONEGL}..dat "
			ECHO_LOG "#======> No OneGL data file received for Post-Social accounting -> STOP Processing <======="
			ECHO_LOG "#==============================================================="

			STEPEND 1	

         else
			ECHO_LOG ""
			ECHO_LOG "#==============================================================="
			ECHO_LOG "#======> read file ESF_FICFROMONEGL=${ESF_FICFROMONEGL}..dat "
			ECHO_LOG "#======> No OneGL data file received for Post-Social accounting -> no need failure  <======="
			ECHO_LOG "#==============================================================="

		 fi # end if need failure FLAG_ERR_WARN=E
		 
		fi # end if FTP_file not received

fi # end if get FTP_file from SAP server 



#--- copy final file for next chains 

if [ -f ${DFILT}/${ENV_PREFIX}_${ESF_FICFROMONEGL}*.dat ]
then
	
		ONEGLFILEDAT=`ls -rt ${DFILT}/${ENV_PREFIX}_${ESF_FICFROMONEGL}*.dat | tail -1`
		ECHO_LOG "File to move: ${ONEGLFILEDAT}"	
	
		NSTEP=${NJOB}_30
		# Begin execksh
		#-----------------------------------------------------------------
		LIBEL="copy ${ONEGLFILEDAT} to ${ESF_FTECLEDA_MVT_TMP}"
		EXECKSH_MODE=P
		EXECKSH "tr -d '\r' <${ONEGLFILEDAT} > ${ESF_FTECLEDA_MVT_TMP}"
		EXECKSH "gzip -f ${DFILT}/${ENV_PREFIX}_${ESF_FICFROMONEGL}*.dat"
		EXECKSH "rm -f ${DFILT}/${ENV_PREFIX}_${ESF_FICFROMONEGL}*.dat"
	
fi

###############################
# Fin execution premier run. 
###############################



wc -l  $ESF_FTECLEDA_MVT_TMP >> $FLOG


JOBEND

