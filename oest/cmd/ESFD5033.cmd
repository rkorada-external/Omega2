#!/bin/ksh
#=================================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD5033.cmd
# revision                      : $Revision:   1.0 $
# date de creation              : 14\11\2023
# auteur                        : Florian CULIOLI
#---------------------------------------------------------------------------------
# description
# FAC Accepted
#  Generation of pericases STD POS 
#
#---------------------------------------------------------------------------------
#=================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

ECHO_LOG "#========================================================================="
ECHO_LOG "#====================================INPUT PARAMETERS====================="
ECHO_LOG "#===> PARM_SEGTYP_CT.....................................................: ${PARM_SEGTYP_CT}"
ECHO_LOG "#===> PARM_ICLODAT_D.....................................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> NORME_CF...........................................................: ${NORME_CF}"
ECHO_LOG "#===> TYPEINV............................................................: ${TYPEINV}"

ECHO_LOG "#====================================INPUT FILE=========================="
ECHO_LOG "#===> EST_IADPERICASE_STD_EBS...............................................: ${EST_IADPERICASE_STD_EBS}"

ECHO_LOG "#====================================OUTPUT FILE=========================="

ECHO_LOG "#========================================================================="




NSTEP=${NJOB}_05
#Call PsPeriFac_01_03
#-----------------------------------------------------------------------------
LIBEL="PsPeriFac_01_03"
BCP_WAY="OUT"
BCP_VER="+"
BCP_QRY="exec BEST..PsPeriFac_01_03 '${PARM_SEGTYP_CT}','${PARM_ICLODAT_D}'"
BCP_O=${EST_IADPERICASE_STD_EBS}
BCP

JOBEND