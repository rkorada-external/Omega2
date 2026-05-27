#!/bin/ksh

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

ENV=`echo ${PRD_SRV} | cut -d'_' -f 1`
DATE_V=''
TYPEINV_V=''

if [ -n "$2" ]; then 
    ENV=$2 
fi

if [ -n "$3" ]; then 
    DATE_V=$3
fi

if [ -n "$4" ]; then 
    TYPEINV_V=$4
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
set `GETPRM ${DPRM}/RPTPY010.prm`
MAILTO_PROD=$1
MAILTO_TEST=$2
MAILTO_DEV=$3

# Variable initialisation 
# -------------------------------------
DATE=`date +"%d/%m/%Y"`
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
    RECEIVER_MAIL=$MAILTO_TEST
else
    RECEIVER_MAIL=$MAILTO_DEV
fi

# Variable export
# -------------------------------------
export RPTPY010_FTMP_1="${DTMP}/${NCHAIN}_${IB}_TMP_1.dat"
export REPORT_SAS_AE_FILE="${PREFIX}_ESIJ0800_ESIJ0802_ctlfilecsm.dat"

export RPTPY010_SAS_AE_ERROR_FILE="${DTMP}/${NCHAIN}_${ENV}_SAS_AE_ERROR_FILE.xlsx"
export RPTPY010_SAS_PAI_ERROR_FILE="${DTMP}/${NCHAIN}_${ENV}_SAS_PAI_ERROR_FILE.xlsx"

export PYTHONPATH=$SYBASE/$SYBASE_OCS/python/python37_64r/lib

# Launch applicative job python RPTPY011
$DCMD/RPTPY011.cmd "${ENV}" "${PREFIX}" "${DATE_V}" "${TYPEINV_V}" 2>&1 | ${TEE}

# Launch applicative job python RPTPY012
$DCMD/RPTPY012.cmd "${ENV}" "${RECEIVER_MAIL}" "${DATE}" 2>&1 | ${TEE}

# Remove tmp file
rm ${DTMP}/${NCHAIN}_${IB}_*.dat

if [ -f ${RPTPY010_SAS_AE_ERROR_FILE} ]; then
	rm ${RPTPY010_SAS_AE_ERROR_FILE}
fi

if [ -f ${RPTPY010_SAS_PAI_ERROR_FILE} ]; then
	rm ${RPTPY010_SAS_PAI_ERROR_FILE}
fi

# Closing the Chain
CHAINEND
