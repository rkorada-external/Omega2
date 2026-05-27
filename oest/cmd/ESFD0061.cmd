#!/bin/ksh
#=============================================================================
# NOM DE L'APPLICATION          : ESTIMATIONS - GET DATA IFRS17                                
# NOM DU SCRIPT SHELL           : ESFD0061.cmd
# REVISION                      : $Revision:   1.0  $
# DATE DE CREATION              : 15/11/2019
# AUTEURS                       : JYP and LEL
# REFERENCES DES SPECIFICATIONS :
#-----------------------------------------------------------------------------
# 
#
#-----------------------------------------------------------------------------
# HISTORIQUES DES MODIFICATIONS
#===============================================================================
#[001] 15/11/2019 LEL : SPIRA 82279 : EXTRACT FLOARAT FOR IFRS17 AT INCEPTION
#[002] 27/01/2020 LEL : SPIRA 83904 : JOB DEACTIVATED : MAPING FILES MANAGEMENT
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT

# Parameters
ECHO_LOG ""
ECHO_LOG "#============================================================================="
ECHO_LOG "#===> TYPEINV..........................: ${TYPEINV}"
ECHO_LOG "#===> NORME............................: ${NORME}"
ECHO_LOG "#===> NORME_CF.........................: ${NORME_CF}"
ECHO_LOG "#===> param_Request_id.................: ${param_Request_id}"
ECHO_LOG "#===> param_Context_id.................: ${param_Context_id}"
ECHO_LOG "#===> PARM_CRE_D.......................: $PARM_CRE_D"
ECHO_LOG "#===> PARM_CLODAT_D....................: $PARM_CLODAT_D"
ECHO_LOG "#===> PARM_ICLODAT_D...................: $PARM_ICLODAT_D"
ECHO_LOG "#===>     ---------------  INPUT   -------------------"
ECHO_LOG "#===>                       none	 					"
ECHO_LOG "#===>     ---------------  OUTPUT  -------------------"
ECHO_LOG "#===> ESF_FLOARAT_I17G ..............: $ESF_FLOARAT_I17G"
ECHO_LOG "#============================================================================="


NSTEP=${NJOB}_35
#-----------------------------------------------------------------------------------
LIBEL="SWITCH TO STANDART ${SRV_2}"
SWITCH_SRV ${SRV_2}

NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------------
LIBEL="CALL PROC BEST..PsFLOARAT_I17G_01 TO EXTRACT PERM FILE ESF_FLOARAT_I17G "
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="${ESF_FLOARAT_I17G}"
BCP_QRY="execute BEST..PsFLOARAT_I17G_01"
BCP

JOBEND
