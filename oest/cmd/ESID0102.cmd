#!/bin/ksh
#-------------------------------------------------------------------
# Application name : SOLVENCY II
# Source name      : ESID0102
# Revision         : 1.0
# Creation date    : 11/04/2012
# Author           : DCH
# references des specifications	: :spot:23390 SOLVENCY II
#-------------------------------------------------------------------
# historiques des modifications
# [01] Florent 22/10/2012 :spot:24041 Solvency II
# [02] Florent 29/04/2015 :spot:26391 ajout gestion ICV avec TYPE_FICHIER
# [03] 26/09/2019 KBagwe : #80560 :- REQ3.3.1 - Change in CSF (CUM and ICV) pattern Upload (complement to 62221 ). Pass closing date to C program .step#10.
#====================================================================


#- Call generic functions
. ${DUTI}/fctgen.cmd
#set -x

TYPE_FICHIER=$1
ICLODAT=$2

#Job Initialization
JOBINIT

NSTEP=${NJOB}_10
#--------------------------------
LIBEL="Call ESTC3002.exe CashFlow rating generation"
PRG=ESTC3002
FPRM=`CFTMP`
export ${PRG}_PRM=${FPRM}
INPUT_TEXT ${FPRM} <<EOF
TYPE_FICHIER ${TYPE_FICHIER}
ICLODAT ${ICLODAT}
exit
EOF
export ${PRG}_I1=${EST_FPATTERNSII_CALC_IN} # issue de ESTC3001
export ${PRG}_O1=${EST_FPATTERNSII_CALC_OUT} # courbes Incrémentales
export ${PRG}_O2=${EST_FPATSEGSII_NEW}     # traceur des id de pattern utilisée
EXECPRG


JOBEND
