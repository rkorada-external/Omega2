#!/bin/ksh

export PY_RECEIVER="ddasilvateixeira-external@scor.com,tdeutsch-external@scor.com,mbrik-external@scor.com,BLAGEDER-EXTERNAL@scor.com,rpise-external@scor.com,mghatole-external@scor.com;"
# export PY_RECEIVER="ddasilvateixeira-external@scor.com"
export PY_SRC="${DUTI}/scripts/tools/delivery_package/src"
export PY_DATA="${DUTI}/scripts/tools/delivery_package/data"

VERSION="4H"
ENV_SRC="IN2"
TARGET_RELEASE="05"
DELIVERY_PACKAGE="105"
HOTFIX="00"
FILENAME="PRD_HF_05"
export FILENAME_CAP="PRD_DELIVERY_CAP_FILE"
export FILENAME_AZD="PRD_DELIVERY_AZD_US"

${PY_SRC}/delivery_package_01.py "${VERSION}" "${ENV_SRC}" "${TARGET_RELEASE}" "${DELIVERY_PACKAGE}" "${FILENAME}" "${HOTFIX}" "${FILENAME_CAP}"

${PY_SRC}/delivery_package_02.py
