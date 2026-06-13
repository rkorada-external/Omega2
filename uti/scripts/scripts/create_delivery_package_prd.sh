#!/bin/ksh

export PY_RECEIVER="ddasilvateixeira-external@scor.com,tdeutsch-external@scor.com,mbrik-external@scor.com"
# export PY_RECEIVER="ddasilvateixeira-external@scor.com"
export PY_SRC="${DUTI}/scripts/tools/delivery_package/src"
export PY_DATA="${DUTI}/scripts/tools/delivery_package/data"

VERSION="4D"
ENV_SRC="IN2"
TARGET_RELEASE="01"
DELIVERY_PACKAGE="103"
HOTFIX="03"
FILENAME="PRD_HF_03"
FILENAME_CAP="DELIVERY_CAP_FILE"

${PY_SRC}/delivery_package_01.py "${VERSION}" "${ENV_SRC}" "${TARGET_RELEASE}" "${DELIVERY_PACKAGE}" "${FILENAME}" "${HOTFIX}" "${FILENAME_CAP}"

${PY_SRC}/delivery_package_02.py
