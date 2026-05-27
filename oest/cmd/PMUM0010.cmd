#!/bin/ksh
#===========================================================================================
# Application Name          :
# SHELL	Script Name	        : PMUM0010.cmd
# Revision			            : $Revision: 1.3 $
# Creation Date             : 2000/01 (AAAA/MM)
# Author                    : ASCOTT - VERNAY
# Specifications References	:
#-------------------------------------------------------------------------------------------
# Description               : Merge of MGT files, keeping only MUTRE subsidiaries (8 and 9).
# 		                           Extraction of TSECTION tables
#-------------------------------------------------------------------------------------------
# Modifications History     :
#-------------------------------------------------------------------------------------------
# MODIFICATION   : [001]
# Auteur         : Ph.VESSIERE
# Date           : 2009.06.25 (YYYY.MM.DD)
# Version        : 
# Description    : [SPOT17557] - Controles CMGT / GT pour Mutré
#[002] 19/06/2012 R. Cassis :spot:24245 Si variante = 6, alors inv = 0
#===========================================================================================
#set -x

#- ---------------------- -
#- Call generic functions -
#- ---------------------- -
. ${DUTI}/fctgen.cmd

#- ------------------------------ -
#- Chain Initialization variables -
#- ------------------------------ -
CHAININIT $0 $1

#- Get directory & file for ${EST_PARAM} and ${EST_PLAN}
. ${DENV}/EST.env
#- Get ${EST_VARIANTE}
. ${EST_PLAN}

#- --------------------------------------------------- -
#- Get default input parameters thanks to PMUM0010.prm -
#- --------------------------------------------------- -
set `GETPRM ${DPRM}/PMUM0010.prm`
BALSHEY_NF=${1}
BALSHRMTH_NF=${2}
INV=${3}
MODE=${4}

#- -------------------------- -
#- AUTOMATIC or MANUAL Mode ? -
#- -------------------------- -
if [ ${MODE} -eq 0 ]
then

   #- -------------- -
   #- AUTOMATIC Mode -
   #- -------------- -

   echo "+++++++++++++++++++ MODE AUTO +++++++++++++++++++++"

   #- Get real production input parameters from ESCJ0000_PARM0.dat        -
   #-    Warning : Values into ESCJ0000_PARM0.dat can be updated everyday -
   set `GETPRM ${EST_PARAM}`
   BALSHEY_NF=${2}
   BALSHTRMTH_NF=${3}

   #- Month with two digit number
   if [ ${BALSHTRMTH_NF} -lt 10 ]
   then
      export BALSHRMTH_NF="0"${BALSHTRMTH_NF}
   else
      export BALSHRMTH_NF=${BALSHTRMTH_NF}
   fi

   #- INV is used in job 12
   if [ ${EST_VARIANTE} -eq 5 ]
   then
      INV="0"
   fi

	#[002]
   #- INV is used in job 12
   if [ ${EST_VARIANTE} -eq 6 ]
   then
      INV="0"
   fi

   #- EST_VARIANTE must be 5 OR 6 to launch the process
   if [ ! ${EST_VARIANTE} -eq 5 -a ! ${EST_VARIANTE} -eq 6 ]
   then
      echo "PMUM0010 will not be launched"
      CHAINEND
   fi

else

   #- ----------- -
   #- MANUAL Mode -
   #- ----------- -
   echo "++++++++++++++++ MODE DEBRAYE +++++++++++++++++++++"

fi

#- ---------------------------------------------------- -
#- Launch applicative job PMUM0015                      -
#-    Compare CMGTR monthly file to CURGTR history file -
#-    [SPOT17557] - Controles CMGT / GT pour Mutré          -
#- ---------------------------------------------------- -
NJOB="PMUM0015.cmd"
${DCMD}/PMUM0015.cmd ${BALSHEY_NF} ${BALSHRMTH_NF} 2>&1 | ${TEE}

#- --------------------------------------------------- -
#- Launch applicative job PMUM0016                     -
#-    Compare CMGTAA monthly files to CURGTA year file -
#-    [SPOT17557] - Controles CMGT / GT pour Mutré         -
#- --------------------------------------------------- -
NJOB="PMUM0016.cmd"
${DCMD}/PMUM0016.cmd ${BALSHEY_NF} ${BALSHRMTH_NF} 2>&1 | ${TEE}

#- ------------------------------- -
#- Launch applicative job PMUM0012 -
#-    Export files
#- ------------------------------- -
NJOB="PMUM0012"
${DCMD}/PMUM0012.cmd ${BALSHEY_NF} ${BALSHRMTH_NF} ${INV} 2>&1 | ${TEE}


#- ------------------------------- -
#- Launch applicative job PMUM0013 -
#-    Export files
#- ------------------------------- -
NJOB="PMUM0013"
${DCMD}/PMUM0013.cmd ${BALSHEY_NF} ${BALSHRMTH_NF} 2>&1 | ${TEE}


#- ------------------------------- -
#- Launch applicative job PMUM0014 -
#-    FTP Transfert
#- ------------------------------- -
NJOB="PMUM0014"
${DCMD}/PMUM0014.cmd ${BALSHEY_NF} ${BALSHRMTH_NF} ${INV} 2>&1 | ${TEE}


#- --------------------------- -
#- Chain/Jobs/Steps are over ! -
#- --------------------------- -
CHAINEND

