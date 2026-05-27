#!/bin/ksh
#=================================================================================
# nom de l'application          : IRFS17 NIGHT CLOSING
# nom du script SHELL           : ESFD3781.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 04\06\2020
# auteur                        : Cyril AVINENS
#---------------------------------------------------------------------------------
# Description
#	Spira #85996
#	Create extract file from BTRT table
#---------------------------------------------------------------------------------
#=================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Get input parameters
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> NORME_CF...............................................: ${NORME_CF}"

ECHO_LOG "#===> ............ OUTPUT ...................................."
ECHO_LOG "#===> ESF_PI_ASSUM_EXTRACT...........................: ${ESF_PI_ASSUM_EXTRACT}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="Create the extract file from BTRT..TCONTR and BTRT..TSECIFRS"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_PI_ASSUM_EXTRACT}
BCP_QRY="exec BTRT..PsCSMENPERITRT_01 ${NORME_CF}"
BCP

JOBEND