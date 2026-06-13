cmd=`which   -a  $0`

root_dir=`dirname  $cmd `
${root_dir}/deliver_dev.py $1 $2 $3  2>&1 | tee -a ${DLOG}/delivery_dev_`date +"%Y%m%d"`.log

