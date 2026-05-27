#!/bin/ksh
#-------------------------------------------------------------------
# Application name : SOLVENCY II
# Source name      : ESID0104
# Revision         : 1.0
# Creation date    : 11/04/2012
# Author           : DCH
#-------------------------------------------------------------------
# [01] Florent 23/10/2012 :spot:24041 Solvency II
#- Call generic functions

. ${DUTI}/fctgen.cmd
USR_CF=$1
CRE_D="$2"

#Job Initialization
JOBINIT

NSTEP=${NJOB}_10
#--------------------------------
LIBEL="Call ESTC3004.exe Rating generation"
PRG=ESTC3004
FPRM=`CFTMP`
export ${PRG}_PRM=${FPRM}
INPUT_TEXT ${FPRM} <<EOF
CRE_D 	   ${CRE_D}
USR_CF    ${USR_CF}
exit
EOF
export ${PRG}_I1=${EST_FRATINGSII}
export ${PRG}_O1=${EST_FPATTERNSII_CALC_OUT}
EXECPRG

JOBEND
