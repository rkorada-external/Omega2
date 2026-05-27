#!/bin/ksh
#=============================================================================
# nom de l'application     : ESTIMATIONS - MDEL SAP file
# nom du script SHELL      : ESFD3967.cmd
# auteur                   : JYP
#-----------------------------------------------------------------------------
# historiques des modifications :
#===============================================================================
#[001]	18/04/2024 JYP :spira 111359: manage MDEL file on SAP server
#-----------------------------------------------------------------------------

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd 
. ${DUTI}/fctftp.cmd


# Job Initialisation
JOBINIT



ECHO_LOG "#========================================================================="
ECHO_LOG "-> ESF_FICFROMONEGL   .......: ${ESF_FICFROMONEGL}"
ECHO_LOG "-> SITE_ONEGL ...............: ${SITE_ONEGL}"
ECHO_LOG "-> SAP Interface (0=NO/1=YES): ${ENV_SAP}"
ECHO_LOG "-> SAP MODE (4=SIMU/1=COMPTA): ${MODE}"
ECHO_LOG "#========================================================================="

if [ "${ENV_SAP}" = "1" ] 
then 

	NSTEP=${NJOB}_70
	# FTP - Delete ESF_FICFROMONEGL on OneGL server 
	# ----------------
	LIBEL="MDEL2 Delete ESF_FICFROMONEGL=$ESF_FICFROMONEGL on OneGL server "
	FTP_FILE=${ENV_PREFIX}_${ESF_FICFROMONEGL}*.zip
	FTP_I=${ENV_PREFIX}_${ESF_FICFROMONEGL}*.zip
	FTP_SITE=${SITE_ONEGL}
	FTP_WAY=MDEL2
	FTP

fi 	
	
JOBEND

