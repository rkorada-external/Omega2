#!/bin/ksh
#===========================================================================================
# Application Name          :
# SHELL	Script Name	        : PMUM0013.cmd
# Revision			            : $Revision: 1.1 $
# Creation Date             : 2000/02 (AAAA/MM)
# Author                    : ASCOTT - VERNAY
# Specifications References	:
#-------------------------------------------------------------------------------------------
# Description               : Extracting data from BTRT..TSECTION and BRET..TRETSEC for
#                                MUTRE/CMR (subsid. 8 and 9)
#-------------------------------------------------------------------------------------------
# Job Launched By           : PMUM0010.cmd
#-------------------------------------------------------------------------------------------
# Modifications History     :
#===========================================================================================
#set -x

#- ---------------------- -
#- Call generic functions -
#- ---------------------- -
. ${DUTI}/fctgen.cmd

#- --------------------- -
#- Get input parmameters -
#- --------------------- -
BALSHEY_NF=${1}
BALSHRMTH_NF=${2}

#- ------------------ -
#- Job initialisation -
#- ------------------ -
JOBINIT

#- ----------------- -
#- Step : 05         -
#-    Begin bcp+ out -
#- ----------------- -
NSTEP=${NJOB}_05
LIBEL="bcp multi from BTRT..TSECTION for SSD_CF = 8 or 9"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${MUTRE_ICA}_${BALSHEY_NF}${BALSHRMTH_NF}.dat
BCP_QRY="exec BTRT..PsMUTSECTION_01"
BCP

#- ----------------- -
#- Step : 10         -
#-    Begin bcp+ out -
#- ----------------- -
NSTEP=${NJOB}_10
LIBEL="bcp multi from BRET..TRETSEC for SSD_CF = 8 or 9"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${MUTRE_ICR}_${BALSHEY_NF}${BALSHRMTH_NF}.dat
BCP_QRY="exec BRET..PsMUTRETSEC_01"
BCP


#- ------------- -
#- Step : 15     -
#-    Begin Copy -
#- ------------- -
NSTEP=${NJOB}_15
LIBEL="Copy for save"
EXECKSH "cp ${DFILT}/${MUTRE_ICA}_${BALSHEY_NF}${BALSHRMTH_NF}.dat
            ${DSAV}/${SVG}_${MUTRE_ICA}_${BALSHEY_NF}${BALSHRMTH_NF}.dat"
EXECKSH "cp ${DFILT}/${MUTRE_ICR}_${BALSHEY_NF}${BALSHRMTH_NF}.dat
            ${DSAV}/${SVG}_${MUTRE_ICR}_${BALSHEY_NF}${BALSHRMTH_NF}.dat"

JOBEND
