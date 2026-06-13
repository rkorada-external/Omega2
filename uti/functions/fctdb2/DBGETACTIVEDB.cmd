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
DBGETACTIVEDB  -M *DBGETACTIVEDB_MODE
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
# The following parameters must be previously defined:
# -M *DBGETACTIVEDB_MODE                     : if set to ODS or DWH, TEACTIVE_DATABASE will be updated with next ODS or DWH database to load
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
EOF
exit -1

}


DBGETACTIVEDB_OUTLOG=$DDBFILT/${NSTEP}_${IB}_GETACTIVEDB.`date "+%Y-%m-%d_%H-%M-%S-%N"`.log
DBLOG_DBNAME='BLUDB'

touch ${DBGETACTIVEDB_OUTLOG}

        OPTIND=1
        while getopts "M:" o
        do
                case "${o}" in
                        M)
                        DBGETACTIVEDB_MODE=${OPTARG}
                        ;;
                        * | -h)
                        usage
                        ;;
                esac
        done
        shift $((OPTIND-1))


        echo "[DBGETACTIVEDB MODE]:     ${DBGETACTIVEDB_MODE}" >> ${DBGETACTIVEDB_OUTLOG}
        DBGETACTIVEDB_TMPFILE=`mktemp -t DBGETACTIVEDB.XXXXXXXXXX`
	DBGETACTIVEDB_CMD="dbsql  -schema DELIVERY_${ENVIRONNEMENT} -c \"select  DELIVERY_${ENVIRONNEMENT}.DELIVERY_SP_DELIVER_GETACTIVEDB('${DBGETACTIVEDB_MODE}') FROM sysibm.sysdummy1\"  -d ${DBLOG_DBNAME}  -o ${DBGETACTIVEDB_TMPFILE} -F \"~\" -t -A -nps"
	echo "[DBGETACTIVEDB_CMD]: ${DBGETACTIVEDB_CMD}" >> ${DBGETACTIVEDB_OUTLOG}

	eval ${DBGETACTIVEDB_CMD}
	DBGETACTIVEDB_CMD_RESULT=$?
 
	if [ ${DBGETACTIVEDB_CMD_RESULT} -ne 0 ]  
	then
		return ${DBGETACTIVEDB_CMD_RESULT}
	fi
	DBGETACTIVEDB_DBNAME=`cat ${DBGETACTIVEDB_TMPFILE}`
        echo "Temporary DBGETACTIVEDB mode query result output before deletion: " >>  ${DBGETACTIVEDB_OUTLOG}
        cat ${DBGETACTIVEDB_TMPFILE} >> ${DBGETACTIVEDB_OUTLOG}
        rm -f ${DBGETACTIVEDB_TMPFILE}
	
	echo "${DBGETACTIVEDB_DBNAME}"

       return 0

