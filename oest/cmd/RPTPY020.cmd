#!/bin/ksh

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

ENV=`echo ${PRD_SRV} | cut -d'_' -f 1`

if [ -n "$2" ]; then 
    ENV=$2 
fi

# Variable parameter
# ------------------------------------
set `GETPRM ${DPRM}/RPTPY020.prm`
MAILTO_PROD=$1
MAILTO_TEST=$2
MAILTO_DEV=$3

# Variable initialisation 
# -------------------------------------
PREFIX=""
RECEIVER_MAIL=""

if [ "${ENV}" = "PRD" ]; then
    PREFIX="P"
    RECEIVER_MAIL=$MAILTO_PROD
elif [ "${ENV}" = "DEV" ]; then
    PREFIX="D"
    RECEIVER_MAIL=$MAILTO_DEV
elif [ "${ENV}" = "CNV" ]; then
    PREFIX="C"
    RECEIVER_MAIL=$MAILTO_TEST
else
    PREFIX="T"
    RECEIVER_MAIL=$MAILTO_TEST
fi

# Variable export
# -------------------------------------

NJOB="RPTPY021"
$DCMD/RPTPY021.cmd "${ENV}" "${RECEIVER_MAIL}" 2>&1 | ${TEE}

# Closing the Chain
CHAINEND
