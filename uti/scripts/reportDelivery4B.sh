#!/bin/ksh
export DELIVERY_PATH="/scor/scoromega/delivery/4B_DELIVERY/OM2.DELIVERY"
export LELT_FILENAME="OM2.4B_DELIVERY_AZDEV.csv"
export RIGHT_FILENAME="OM2.4B_DELIVERY_AZITK.csv"
export RECIPIENT="ddasilvateixeira-external@scor.com,tdeutsch-external@scor.com"

cd $DELIVERY_PATH
svn up
cd $DUTI


version=2
if [[ $1 -ne "" ]] 
then 
    version=$1 
fi
echo "version : ${version}"

if [ $version = 1 ]
then
    echo "Launch : reportDelivery_v1.py"
    ${DUTI}/scripts/reportDelivery_v1.py
fi

if [ $version = 2 ]
then
    echo "Launch : reportDelivery_v2.py"
    ${DUTI}/scripts/reportDelivery_v2.py
fi
