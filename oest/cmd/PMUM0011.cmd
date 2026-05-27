#!/bin/ksh
#===========================================================================================
# Application Name          :
# SHELL	Script Name	        : PMUM0011.cmd
# Revision			            : $Revision: 1.1 $
# Creation Date             : 2000/02 (AAAA/MM)
# Author                    : ASCOTT - VERNAY
# Specifications References	:
#-------------------------------------------------------------------------------------------
# Description               : Check the existence of the entry files
#-------------------------------------------------------------------------------------------
# Job Launched By           : PMUM0010.cmd
#-------------------------------------------------------------------------------------------
# Modifications History     :
#===========================================================================================
#set -x

#- Get input parmameters
BALSHEY_NF=${1}
BALSHRMTH_NF=${2}
INV=${3}

#- ------------------ -
#- Export PSOFT Files -
#- ------------------ -
if [ ${INV} -eq 0 ]
then
  if [ -f ${EST_CMGTAA}_*_${BALSHEY_NF}${BALSHRMTH_NF}_*_*.dat ] &&
     [ -f ${EST_CMGTR}_*_${BALSHEY_NF}${BALSHRMTH_NF}_*_*.dat ] &&
     [ -f ${EST_CMGTS}_*_${BALSHEY_NF}${BALSHRMTH_NF}_*_*.dat ]
  then
    export PSOFT_MGTAA=`ls -t ${EST_CMGTAA}_*_${BALSHEY_NF}${BALSHRMTH_NF}_*_*.dat | head -1`
    export PSOFT_MGTR=`ls -t ${EST_CMGTR}_*_${BALSHEY_NF}${BALSHRMTH_NF}_*_*.dat | head -1`
    export PSOFT_MGTS=`ls -t ${EST_CMGTS}_*_${BALSHEY_NF}${BALSHRMTH_NF}_*_*.dat | head -1`
  else
    echo "# !!!! Entry file is missing, chain not processed."
    CHAINEND
  fi
else
  if [ -f ${EST_MGTAA} ] &&
     [ -f ${EST_MGTR} ] &&
     [ -f ${EST_MGTS} ]
  then
    export PSOFT_MGTAA=`ls -t ${EST_MGTAA} | head -1`
    export PSOFT_MGTR=`ls -t ${EST_MGTR} | head -1`
    export PSOFT_MGTS=`ls -t ${EST_MGTS} | head -1`
  else
    CHAINEND
  fi
fi
