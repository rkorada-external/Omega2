#!/bin/ksh

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

ENV=`echo ${PRD_SRV} | cut -d'_' -f 1`

if [ -n "$2" ]; then 
    ENV=$2 
fi

ENV_RUN=$(echo "${ENV}" | tr '[:upper:]' '[:lower:]')
if [ "${ENV}" != "DEV" ]; then
    DCMD="/scoromega_runnable_aen${ENV_RUN}o2batch/cmd"
    DPRM="/scordata_aen${ENV_RUN}o2batch/ubam/prm"
    DENV="/scordata_aen${ENV_RUN}o2batch/ubam/env"

fi
echo "# DCMD :  $DCMD"
echo "# DPRM :  $DPRM"
echo "# DENV :  $DENV"

# Variable parameter
# ------------------------------------
set `GETPRM ${DPRM}/RPTPY030.prm`
MAILTO_PROD=$1
MAILTO_BU=$2
MAILTO_IT=$3

# Variable initialisation 
# -------------------------------------
PREFIX=""
RECEIVER_MAIL=""

if [ "${ENV}" = "PRD"  ]; then
    PREFIX="P"
elif [ "${ENV}" = "DEV" ]; then
    PREFIX="D"
elif [ "${ENV}" = "CNV" ]; then
    PREFIX="C"
else
    PREFIX="T"
fi


if [ "${ENV}" = "PRD" ] || [ "${ENV}" = "MAI" ]; then
    RECEIVER_MAIL=$MAILTO_PROD
elif [ "${ENV}" = "UAT" ] || [ "${ENV}" = "INT" ] || [ "${ENV}" = "CNV" ]; then
    RECEIVER_MAIL=$MAILTO_BU
else
    RECEIVER_MAIL=$MAILTO_IT
fi


# Variable export
# -------------------------------------

NJOB="RPTPY031"
$DCMD/RPTPY031.cmd "${ENV}" "${PREFIX}" "${RECEIVER_MAIL}" 2>&1 | ${TEE}

# Closing the Chain
CHAINEND
