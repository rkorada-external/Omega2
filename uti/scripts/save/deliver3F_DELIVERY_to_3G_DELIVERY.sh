#set -x
export DELIVERY_ENV='3F_DELIVERY_to_3G_DELIVERY'
/scor/scoromega/runnable/uti/scripts/deliver.py $1 $2 $3  2>&1 | tee -a ${DLOG}/delivery_${delivryEnv}_`date +"%Y%m%d"`.log

