#!/bin/ksh
#===========================================================================================
# Application Name          :
# SHELL	Script Name	       : PMUM0014.cmd
# Revision                  : $Revision: 1.1 $
# Creation Date             : 2000/02 (AAAA/MM)
# Author                    : ASCOTT - VERNAY
# Specifications References :
#-------------------------------------------------------------------------------------------
# Description               : Put the files on the MUTRE server
#-------------------------------------------------------------------------------------------
# Job Launched By           : PMUM0010.cmd
#-------------------------------------------------------------------------------------------
# Modifications History     :
#   2009.06.25 - PhV - [SPOT17557] - Controles CMGT / GT pour Mutré
#[002] 05/12/2011 Roger Cassis   :spot:23008 Archivage des fichiers envoyes a Mutre
#[003] 01/03/2012 Roger Cassis   :spot:23541 Correction sur nom de fichier archive ICA vers ICR
#[004] 02/05/2013 Roger Cassis   :spot:25170 Correction sur noms de fichiers archive
#[005] 11/01/2016 Roger Cassis   :spot:29985 - Normalisation ENV_PREFIX dans noms de fichiers.
#===========================================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctftp.cmd

# Get input parameters
BALSHEY_NF=${1}
BALSHRMTH_NF=${2}
INV=${3}

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_05
# FTP CONNEXION TEST
#----------------------------------------------------------------------------
LIBEL="FTP CONNEXION TEST"
FTP_IP=${MUTRE_IP}
FTP_USR=${MUTRE_USER}
FTP_PSWD=${MUTRE_PASS}
FTP_LDIR=${DFILT}
STEP_NOECHO="YES"
STEPEND_CONTINUE="NO"
FTP_TEST

#[002]
#[003]
#[004]
NSTEP=${NJOB}_10
# ARCHIVAGE
#----------------------------------------------------------------------------
LIBEL="Archive files sent to Mutre"
EXECKSH_MODE=P
EXECKSH "cp ${DFILT}/${MUTRE_MGT}_${BALSHEY_NF}${BALSHRMTH_NF}.dat ${DARCH}"
EXECKSH "cp ${DFILT}/${MUTRE_ICA}_${BALSHEY_NF}${BALSHRMTH_NF}.dat ${DARCH}"
EXECKSH "cp ${DFILT}/${MUTRE_ICR}_${BALSHEY_NF}${BALSHRMTH_NF}.dat ${DARCH}"
EXECKSH "cp ${DFILT}/${MUTRE_CTRL}_${BALSHEY_NF}${BALSHRMTH_NF}.dat ${DARCH}"

#[002]
#[003]
if [ ! -f ${DARCH}/${MUTRE_MGT}_${BALSHEY_NF}${BALSHRMTH_NF}.dat.gz ]
then
	NSTEP=${NJOB}_15
	# ARCHIVAGE
	#----------------------------------------------------------------------------
	LIBEL="gzip Archive files sent to Mutre"
	EXECKSH_MODE=P
	EXECKSH "gzip ${DARCH}/${MUTRE_MGT}_${BALSHEY_NF}${BALSHRMTH_NF}.dat"
	EXECKSH "gzip ${DARCH}/${MUTRE_ICA}_${BALSHEY_NF}${BALSHRMTH_NF}.dat"
	EXECKSH "gzip ${DARCH}/${MUTRE_ICR}_${BALSHEY_NF}${BALSHRMTH_NF}.dat"
	EXECKSH "gzip ${DARCH}/${MUTRE_CTRL}_${BALSHEY_NF}${BALSHRMTH_NF}.dat"
fi

#- ---------------------------------------------------------------------- -
#-       If INV=0, PUT will be done on CMGT files (Done in PMUM0012.cmd). -
#-       Else, PUT will be done on MGT files (Done in PMUM0012.cmd).      -
#- ---------------------------------------------------------------------- -
NSTEP=${NJOB}_20
# Put MGT merged file on MUTRE server
#------------------------------------------------------------------------------
LIBEL="Put MGT merged file on MUTRE server"
FTP_IP=${MUTRE_IP}
FTP_USR=${MUTRE_USER}
FTP_PSWD=${MUTRE_PASS}
FTP_LDIR=${DFILT}
FTP_I=${MUTRE_MGT}_${BALSHEY_NF}${BALSHRMTH_NF}.dat
FTP_O=${MUTRE_MGT}_${BALSHEY_NF}${BALSHRMTH_NF}.dat

#- INV = 0 : Let's push CMGT files or Not ?
if [ INV -eq "0" ]
then
   #- Processing is about CMGT files. CMGTR & CMGTAA Files OK exist ?
   if [ -e ${DFILT}/PMUM0015_*_${ENV_PREFIX}_ESID7050_CMGTR_Result_OK.dat -a -e ${DFILT}/PMUM0016_*_${ENV_PREFIX}_ESID7050_CMGTAA_Result_OK.dat ]
   then
      #- 2 OK files exist, let's push it !
      LIBEL="Put MGT merged file on MUTRE server"
      FTP_PUT
   fi
else
   #- Processing is about MGT files. No test, always push.
   LIBEL="Put MGT merged file on MUTRE server"
   FTP_PUT
fi

NSTEP=${NJOB}_25
# Put ICA file on MUTRE server
#------------------------------------------------------------------------------
LIBEL="Put ICA file on MUTRE server"
FTP_IP=${MUTRE_IP}
FTP_USR=${MUTRE_USER}
FTP_PSWD=${MUTRE_PASS}
FTP_LDIR=${DFILT}
FTP_I=${MUTRE_ICA}_${BALSHEY_NF}${BALSHRMTH_NF}.dat
FTP_O=${MUTRE_ICA}_${BALSHEY_NF}${BALSHRMTH_NF}.dat
FTP_PUT

NSTEP=${NJOB}_30
# Put ICR file on MUTRE server
#------------------------------------------------------------------------------
LIBEL="Put ICR file on MUTRE server"
FTP_IP=${MUTRE_IP}
FTP_USR=${MUTRE_USER}
FTP_PSWD=${MUTRE_PASS}
FTP_LDIR=${DFILT}
FTP_I=${MUTRE_ICR}_${BALSHEY_NF}${BALSHRMTH_NF}.dat
FTP_O=${MUTRE_ICR}_${BALSHEY_NF}${BALSHRMTH_NF}.dat
FTP_PUT

NSTEP=${NJOB}_35
# Put CTRL file on MUTRE server
#------------------------------------------------------------------------------
LIBEL="Put CTRL file on MUTRE server"
FTP_IP=${MUTRE_IP}
FTP_USR=${MUTRE_USER}
FTP_PSWD=${MUTRE_PASS}
FTP_LDIR=${DFILT}
FTP_I=${MUTRE_CTRL}_${BALSHEY_NF}${BALSHRMTH_NF}.dat
FTP_O=${MUTRE_CTRL}_${BALSHEY_NF}${BALSHRMTH_NF}.dat
FTP_PUT

NSTEP=${NJOB}_40
# Remove temporary files
#------------------------------------------------------------------------------
LIBEL="Step to remove temporary files"
RMFIL "${DFILT}/${NCHAIN}*_${IB}_*.dat"
RMFIL "${DFILT}/${MUTRE_CTRL}_${BALSHEY_NF}${BALSHRMTH_NF}.dat"

JOBEND
