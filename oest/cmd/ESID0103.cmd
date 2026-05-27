#!/bin/ksh
#-------------------------------------------------------------------
# Application name : SOLVENCY II
# Source name      : ESID0103
# Revision         : 1.0
# Creation date    : 11/04/2012
# Author           : DCH
# references des specifications	: :spot:23390 SOLVENCY II
#-------------------------------------------------------------------
# historiques des modifications
# [01] Florent 23/10/2012 :spot:24041 Solvency II
# [02] Florent 13/05/2016 :spot:30543 gestion du DSI !
#-------------------------------------------------------------------

#- Call generic functions
. ${DUTI}/fctgen.cmd

USR_CF=${1}
CRE_D="${2}"
TYPE_FICHIER=${3}

#Job Initialization
JOBINIT

if [[ ${TYPE_FICHIER} =~ ^(DSC|DSI)$ ]] 
then
  NSTEP=${NJOB}_10
  #--------------------------------
  LIBEL="Call ESTC3003.exe Discount rating generation"
  PRG=ESTC3003
  FPRM=`CFTMP`
  export ${PRG}_PRM=${FPRM}
INPUT_TEXT ${FPRM} <<EOF
CRE_D ${CRE_D}
USR_CF ${USR_CF}
exit
EOF
  export ${PRG}_I1=${EST_FPATTERNSII_CALC_IN} # courbes DSC
  export ${PRG}_O1=${EST_FPATTERNSII_CALC_OUT} # courbes DSC calculées => DSI
  export ${PRG}_O2=${EST_FPATSEGSII_NEW} # trace de l'utilisation des pattern
  EXECPRG
fi

if [ "${TYPE_FICHIER}" = "INF" ]
then
  NSTEP=${NJOB}_20
  #--------------------------------
  LIBEL="Call ESTC3005.exe Inflation generation"
  PRG=ESTC3005
  export ${PRG}_I1=${EST_FPATTERNSII_CALC_IN} # courbes INF
  export ${PRG}_O1=${EST_FPATTERNSII_CALC_OUT} # courbes calculées => INFI
  export ${PRG}_O2=${EST_FPATSEGSII_NEW} # trace de l'utilisation des pattern
  EXECPRG
fi

JOBEND
