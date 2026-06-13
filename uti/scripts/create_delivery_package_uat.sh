#!/bin/ksh

export PY_RECEIVER="ddasilvateixeira-external@scor.com,tdeutsch-external@scor.com,mbrik-external@scor.com,BLAGEDER-EXTERNAL@scor.com"
export PY_SRC="${DUTI}/scripts/tools/delivery_package/src"
export PY_DATA="${DUTI}/scripts/tools/delivery_package/data"

VERSION="4I"
ENV_SRC="ITK"
TARGET_RELEASE="05,01"
DELIVERY_PACKAGE="250,105"
HOTFIX="01"
FILENAME="UAT_05_HF_01"
export FILENAME_CAP="UAT_DELIVERY_CAP_FILE"
export FILENAME_AZD="UAT_DELIVERY_AZD_US"

${PY_SRC}/delivery_package_01.py "${VERSION}" "${ENV_SRC}" "${TARGET_RELEASE}" "${DELIVERY_PACKAGE}" "${FILENAME}" "${HOTFIX}"

${PY_SRC}/delivery_package_02.py
