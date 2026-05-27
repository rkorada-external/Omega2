#!/bin/ksh
#==================================================================================
# nom de l'application          : ESTIMATIONS 
# auteur                        : Mr JYP
#-----------------------------------------------------------------------------
# [001] 17/07/2025 : Mr JYP :US 5559 spira 113075 : SERQS split files by site




# Call generic functions
. ${DUTI}/fctgen.cmd

CHAININIT CNLD0030 $DENV/CNLD0030.env

set -x


NJOB=SERQS_INIT

# Initialization of the Job
JOBINIT

echo "Starting $0 $1 $FLOG " 
echo "Starting $0 $1" >> $FLOG
date >> $FLOG


export DFILPAS="${DSCORDATA}/ubas/perm"
export DFILPEU="${DSCORDATA}/ubeu/perm"
export DFILPAM="${DSCORDATA}/ubam/perm"

case "$DEFAULT_SQL_LOGIN" in
     "ubas" ) SITE="SGP1" ;;
     "ubeu" ) SITE="FRA1" ;;
     "ubam" ) SITE="USA1" ;;
      *)      SITE="OTH1" ;; #--- ubgl or future users
esac


export LOCALTOAM="${SITE}_USA1"               # example on AS: "SGP1_USA1"
export LOCALTOEU="${SITE}_FRA1"               # example on AS: "SGP1_FRA1"
export LOCALTOAS="${SITE}_SGP1"               # example on EU: "FRA1_SGP1"
export PARAM_LOCALSIT="${SITE}_${SITE}"       # example on AS: "SGP1_SGP1"

ECHO_LOG "#===> DEFAULT_SQL_LOGIN => SITE ................: ${DEFAULT_SQL_LOGIN} => $SITE "

ECHO_LOG "#===> LOCALTOAS ................: ${LOCALTOAS}"
ECHO_LOG "#===> LOCALTOEU ................: ${LOCALTOEU}"
ECHO_LOG "#===> LOCALTOAM ................: ${LOCALTOAM}"

ECHO_LOG "#===> DFILPAS ................: ${DFILPAS}"
ECHO_LOG "#===> DFILPEU ................: ${DFILPEU}"
ECHO_LOG "#===> DFILPAM ................: ${DFILPAM}"

NSTEP=${NCHAIN}_${NJOB}_05
LIBEL="Init some empty files gaap codes  "
#------------------------------------------------------------------------------
if [ -f ${DFILP}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING.dat  ]
then
	EXECKSH_MODE=P
	EXECKSH "cp ${DFILP}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING.dat ${DFILPAS}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING_${LOCALTOAS}.dat "
	EXECKSH_MODE=P
	EXECKSH "cp  ${DFILP}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING.dat ${DFILPEU}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING_${LOCALTOEU}.dat "
	EXECKSH_MODE=P
	EXECKSH "cp ${DFILP}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING.dat ${DFILPAM}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING_${LOCALTOAM}.dat"
fi 

ls -ltr ${DFILPAS}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING_${SITE}*dat 
ls -ltr ${DFILPEU}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING_${SITE}*dat 
ls -ltr ${DFILPAM}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING_${SITE}*dat 

ls -ltr ${DFILPAS}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING_${SITE}*dat >> $FLOG
ls -ltr ${DFILPEU}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING_${SITE}*dat >> $FLOG
ls -ltr ${DFILPAM}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING_${SITE}*dat >> $FLOG


NSTEP=${NCHAIN}_${NJOB}_10
LIBEL="Init some empty files products codes  "
#------------------------------------------------------------------------------
if [ -f ${DFILP}/${ENV_PREFIX}_ESFD0040_FCTRI17PRD.dat ]
then 
	EXECKSH_MODE=P
	EXECKSH "cp  ${DFILP}/${ENV_PREFIX}_ESFD0040_FCTRI17PRD.dat ${DFILPAS}/${ENV_PREFIX}_ESFD0040_FCTRI17PRD_${LOCALTOAS}.dat "
	EXECKSH_MODE=P
	EXECKSH "cp  ${DFILP}/${ENV_PREFIX}_ESFD0040_FCTRI17PRD.dat ${DFILPEU}/${ENV_PREFIX}_ESFD0040_FCTRI17PRD_${LOCALTOEU}.dat "
	EXECKSH_MODE=P
	EXECKSH "cp  ${DFILP}/${ENV_PREFIX}_ESFD0040_FCTRI17PRD.dat ${DFILPAM}/${ENV_PREFIX}_ESFD0040_FCTRI17PRD_${LOCALTOAM}.dat"
fi 

ls -ltr ${DFILPAS}/${ENV_PREFIX}_ESFD0040_FCTRI17PRD_${SITE}*dat 
ls -ltr ${DFILPEU}/${ENV_PREFIX}_ESFD0040_FCTRI17PRD_${SITE}*dat 
ls -ltr ${DFILPAM}/${ENV_PREFIX}_ESFD0040_FCTRI17PRD_${SITE}*dat 

ls -ltr ${DFILPAS}/${ENV_PREFIX}_ESFD0040_FCTRI17PRD_${SITE}*dat >> $FLOG  
ls -ltr ${DFILPEU}/${ENV_PREFIX}_ESFD0040_FCTRI17PRD_${SITE}*dat >> $FLOG  
ls -ltr ${DFILPAM}/${ENV_PREFIX}_ESFD0040_FCTRI17PRD_${SITE}*dat >> $FLOG  




# get last date I17G
PARM_ICLODAT_D=`ls -t1  ${DFILP}/${ENV_PREFIX}_ESFD3870_I17G_GLT_ALL_STD_FTECLEDA_* | head -1 | cut -d_ -f9 | cut -d"." -f1 `
PARM_ICLODAT_I17L=`ls -t1  ${DFILP}/${ENV_PREFIX}_ESFD3870_I17L_GLT_ALL_STD_FTECLEDA_* | head -1 | cut -d_ -f9 | cut -d"." -f1 `


NSTEP=${NCHAIN}_${NJOB}_15
LIBEL="Init file ESID8700_FTECLEDAEBS used by I17G PARM_ICLODAT_D=$PARM_ICLODAT_D  "
#------------------------------------------------------------------------------
ls -ltr  ${DFILP}/${ENV_PREFIX}_ESID8700_FTECLEDA_I4I_${PARM_ICLODAT_D}.dat ${DFILP}/${ENV_PREFIX}_ESID8700_PC_FTECLEDAEBS_I4I_${PARM_ICLODAT_D}_${PARAM_LOCALSIT}.dat 
if [ ! -f ${DFILP}/${ENV_PREFIX}_ESID8700_PC_FTECLEDAEBS_I4I_${PARM_ICLODAT_D}_${PARAM_LOCALSIT}.dat ] && [ -f ${DFILP}/${ENV_PREFIX}_ESID8700_FTECLEDA_I4I_${PARM_ICLODAT_D}.dat ]
then 
	EXECKSH_MODE=P 
	EXECKSH "cp  ${DFILP}/${ENV_PREFIX}_ESID8700_FTECLEDA_I4I_${PARM_ICLODAT_D}.dat ${DFILP}/${ENV_PREFIX}_ESID8700_PC_FTECLEDAEBS_I4I_${PARM_ICLODAT_D}_${PARAM_LOCALSIT}.dat  "
fi 
ls -ltr  ${DFILP}/${ENV_PREFIX}_ESID8700_FTECLEDA_I4I_${PARM_ICLODAT_D}.dat ${DFILP}/${ENV_PREFIX}_ESID8700_PC_FTECLEDAEBS_I4I_${PARM_ICLODAT_D}_${PARAM_LOCALSIT}.dat 


NSTEP=${NCHAIN}_${NJOB}_20
LIBEL="Init file ESID8700_FTECLEDAEBS used by I17LP PARM_ICLODAT_I17L=$PARM_ICLODAT_I17L  "
#------------------------------------------------------------------------------
ls -ltr  ${DFILP}/${ENV_PREFIX}_ESID8700_FTECLEDA_I4I_${PARM_ICLODAT_I17L}.dat ${DFILP}/${ENV_PREFIX}_ESID8700_PC_FTECLEDAEBS_I4I_${PARM_ICLODAT_I17L}_${PARAM_LOCALSIT}.dat 
if [ ! -f ${DFILP}/${ENV_PREFIX}_ESID8700_PC_FTECLEDAEBS_I4I_${PARM_ICLODAT_I17L}_${PARAM_LOCALSIT}.dat ] && [ -f ${DFILP}/${ENV_PREFIX}_ESID8700_FTECLEDA_I4I_${PARM_ICLODAT_I17L}.dat ]
then 
	EXECKSH_MODE=P 
	EXECKSH "cp  ${DFILP}/${ENV_PREFIX}_ESID8700_FTECLEDA_I4I_${PARM_ICLODAT_I17L}.dat ${DFILP}/${ENV_PREFIX}_ESID8700_PC_FTECLEDAEBS_I4I_${PARM_ICLODAT_I17L}_${PARAM_LOCALSIT}.dat  "
fi 
ls -ltr  ${DFILP}/${ENV_PREFIX}_ESID8700_FTECLEDA_I4I_${PARM_ICLODAT_I17L}.dat ${DFILP}/${ENV_PREFIX}_ESID8700_PC_FTECLEDAEBS_I4I_${PARM_ICLODAT_I17L}_${PARAM_LOCALSIT}.dat 



set +x

echo "End of script OK status $? " >> $FLOG
echo "End of script OK status $? " 

JOBEND


