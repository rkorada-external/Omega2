#!/bin/ksh

export PY_RECEIVER="ddasilvateixeira-external@scor.com,tdeutsch-external@scor.com,mbrik-external@scor.com"
export PY_SRC="${DUTI}/scripts/tools/delivery_package/src"
export PY_DATA="${DUTI}/scripts/tools/delivery_package/data"

VERSION="4E"
ENV_SRC="ITK"
TARGET_RELEASE="03,01"
DELIVERY_PACKAGE="210,102"
HOTFIX="00"
FILENAME="UAT_1"
FILENAME_CAP="DELIVERY_CAP"

${PY_SRC}/delivery_package_01.py "${VERSION}" "${ENV_SRC}" "${TARGET_RELEASE}" "${DELIVERY_PACKAGE}" "${FILENAME}" "${HOTFIX}" "${FILENAME_CAP}"

${PY_SRC}/delivery_package_02.py
