#!/bin/ksh
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
# AUTHORS:               Nour Miloua, Vincent Gautier, Roger Cassis
# CREATE DATE:           13/12/2015
# LAST MODIF DATE:       13/12/2015
# DESCRIPTION:           Reinsurance analytics dataload switch for ODS and DWH databases
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
# Change Log:
# 13/12/2015: Creation :spot:30171
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
#set -x

usage() {
cat << EOF
Usage:
NZGETACTIVEDB  -M *NZGETACTIVEDB_MODE
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
# The following parameters must be previously defined:
# -M *NZGETACTIVEDB_MODE                     : if set to ODS or DWH, TEACTIVE_DATABASE will be updated with next ODS or DWH database to load
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
EOF
exit -1

}


NZGETACTIVEDB_OUTLOG=$DNZFILT/${NSTEP}_${IB}_GETACTIVEDB.`date "+%Y-%m-%d_%H-%M-%S-%N"`.log

touch ${NZGETACTIVEDB_OUTLOG}

        OPTIND=1
        while getopts "M:" o
        do
                case "${o}" in
                        M)
                        NZGETACTIVEDB_MODE=${OPTARG}
                        ;;
                        * | -h)
                        usage
                        ;;
                esac
        done
        shift $((OPTIND-1))



        echo "[NZGETACTIVEDB MODE]:     ${NZGETACTIVEDB_MODE}" >> ${NZGETACTIVEDB_OUTLOG}
        NZGETACTIVEDB_TMPFILE=`mktemp -t NZGETACTIVEDB.XXXXXXXXXX`
	NZGETACTIVEDB_CMD="nzsql   -c \"select  DELIVERY.SP_DELIVER_GETACTIVEDB('${NZGETACTIVEDB_MODE}')\"  -d DELIVERY_${ENVIRONNEMENT} -o ${NZGETACTIVEDB_TMPFILE} -F \"~\" -t -A"
	echo "[NZGETACTIVEDB_CMD]: ${NZGETACTIVEDB_CMD}" >> ${NZGETACTIVEDB_OUTLOG}

	eval ${NZGETACTIVEDB_CMD}
	NZGETACTIVEDB_CMD_RESULT=$?
 
	if [ ${NZGETACTIVEDB_CMD_RESULT} -ne 0 ]  
	then
		return ${NZGETACTIVEDB_CMD_RESULT}
	fi
	NZGETACTIVEDB_DBNAME=`cat ${NZGETACTIVEDB_TMPFILE}`
        echo "Temporary NZGETACTIVEDB mode query result output before deletion: " >>  ${NZGETACTIVEDB_OUTLOG}
        cat ${NZGETACTIVEDB_TMPFILE} >> ${NZGETACTIVEDB_OUTLOG}
        rm -f ${NZGETACTIVEDB_TMPFILE}
	
	echo "${NZGETACTIVEDB_DBNAME}"

       return 0


