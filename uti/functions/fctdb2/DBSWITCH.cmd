#/-----------------------------------------------------------------------------------------------------------------------------------------------------------
# AUTHORS:               Nour Miloua, Vincent Gautier, Roger Cassis
# CREATE DATE:           13/12/2015
# LAST MODIF DATE:       13/12/2015
# DESCRIPTION:           Reinsurance analytics dataload switch for ODS and DWH databases
# Change Log:
# 13/12/2015: Creation :spot:30171
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
#set -x

# Call generic functions
. ${DUTI}/functions/fctdb2/DBLOGINIT
. ${DUTI}/functions/fctdb2/DBLOGEND

usage() {
cat << EOF
Usage:
DBSWITCH  -M *DBSWITCH_MODE
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
# The following parameters must be previously defined:
# NSTEP                             : STEP Identifier (Mandatory) defined from caller shell script or set by default to NLOAD_AUTONOMOUS_MODE
# -M *DBSWITCH_MODE            : if set to ODS or DWH, TEACTIVE_DATABASE will be updated with next ODS or DWH database to load
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
EOF
exit -1

}

export JDATE_YYYYMMDDHHMMSS=`date +"%Y%m%d%H%M%S"`
export JDATE_DDMMYYHHMM=`date +"%d/%m/%Y %H:%M"`


DBSWITCH_OUTLOG=$DDBFILT/`hostname`_DBSWITCH_`date "+%Y-%m-%d_%H-%M-%S-%N"`.log


if [ -f ${DBSWITCH_OUTLOG} ] ; then
    mv ${DBSWITCH_OUTLOG} "${DBSWITCH_OUTLOG}.bak"
fi
touch ${DBSWITCH_OUTLOG}


OPTIND=1
DB_BLUDB=BLUDB

while getopts "M:" o
do
    case "${o}" in
        M)
        DBSWITCH_MODE=${OPTARG}
        ;;
        * | -h )
        usage
        ;;
    esac
done
shift $((OPTIND-1))

DBLOGINIT -l LEV1 -j DBSWITCH_${DBSWITCH_MODE}

if [ -z ${DBSWITCH_MODE} ] ;
then
    usage
    DBLOGEND -l LEV1 -j DBSWITCH_${DBSWITCH_MODE} -r 1 -m "Invalid parameters"
fi
# Execute switch
echo "[DBSWITCH_MODE]:         ${DBSWITCH_MODE}" >> ${DBSWITCH_OUTLOG}
DBSWITCH_TMPFILE=`mktemp -t DBSQL.XXXXXXXXXX`
dbsql  -q  -c "call  DELIVERY_${ENVIRONNEMENT}.DELIVERY_SP_DELIVER_SWITCH_DB('${DBSWITCH_MODE}')"  -schema DELIVERY_${ENVIRONNEMENT}  -o ${DBSWITCH_TMPFILE} -F "~" -t -A -nps
DBSWITCH_RETURN_CODE=$?
if [ ${DBSWITCH_RETURN_CODE} -ne 0 ] ;
then
    export PRGANO=${DBSWITCH_OUTLOG}
    echo "# Error happend during switch query execution"
    echo "# Log file:  ${DBSWITCH_OUTLOG}"
    DBLOGEND -l LEV1 -j DBSWITCH_${DBSWITCH_MODE} -r 1 -m "Error happend during switch query execution"
    return ${DBSWITCH_RETURN_CODE}
else
    echo "Temporary dbsql mode query result output before deletion: " >>  ${DBSWITCH_OUTLOG}
    cat ${DBSWITCH_TMPFILE} >> ${DBSWITCH_OUTLOG}
    rm -f ${DBSWITCH_TMPFILE}
    echo "# Switch to new ${DBSWITCH_MODE} OK"
    echo "# Log file:  ${DBSWITCH_OUTLOG}"
fi


ACTIVE_DWH=`$DUTI/functions/fctdb2/DBGETACTIVEDB.cmd -M DWH`
ACTIVE_BI=`$DUTI/functions/fctdb2/DBGETACTIVEDB.cmd -M BI`

if [ ${DBSWITCH_MODE} == 'BI' ]
then

    DBSWITCH_TMPFINAL=`mktemp -t DBSQL.XXXXXXXXXX`


    #Extract BI database synonyms to drop
    echo "# BI Switch step 1" >> ${DBSWITCH_OUTLOG}
    DBSWITCH_TMPFILE1=`mktemp -t DBSQL.XXXXXXXXXX`
    DBSWITCH_TMPQUERY="select concat(concat('DROP SYNONYM BI_${ENVIRONNEMENT}.', TABNAME), ';')  as QUERY_CF from SYSCAT.TABLES a where a.TABSCHEMA = 'BI_${ENVIRONNEMENT}' and a.type ='A' AND NOT EXISTS (SELECT 1 FROM DELIVERY_${ENVIRONNEMENT}.DELIVERY_SWITCH_BI b WHERE a.tabname=b.SYNONYM_N)"
    DBSWITCH_TMP_CMD="dbsql -q -c \"${DBSWITCH_TMPQUERY}\"  -d ${DB_BLUDB} -schema BI_${ENVIRONNEMENT} -o ${DBSWITCH_TMPFILE1} -F \"~\" -t -A -nps"
    echo ${DBSWITCH_TMP_CMD}  >> ${DBSWITCH_OUTLOG}
    eval ${DBSWITCH_TMP_CMD} 2>&1
    cat ${DBSWITCH_TMPFILE1} >> ${DBSWITCH_TMPFINAL}



    #Extract new active BI-DWH tables for which synonyms need to be created
    echo "# BI Switch step 2" >> ${DBSWITCH_OUTLOG}
    DBSWITCH_TMPFILE2=`mktemp -t DBSQL.XXXXXXXXXX`
    DBSWITCH_TMPQUERY=" select concat(concat(concat(concat('CREATE SYNONYM BI_${ENVIRONNEMENT}.', REPLACE(TABNAME,'DWH_','') ), ' FOR ${ACTIVE_BI}.'), TABNAME), ';') AS QUERY_CF from SYSCAT.TABLES a  where  a.TABSCHEMA = '${ACTIVE_BI}' and a.type='T'  AND NOT EXISTS (SELECT 1 FROM DELIVERY_${ENVIRONNEMENT}.DELIVERY_SWITCH_BI b WHERE a.tabname=b.TABLE_N )"
    DBSWITCH_TMP_CMD="dbsql  -q  -c \"${DBSWITCH_TMPQUERY}\"  -d  ${DB_BLUDB} -schema ${ACTIVE_BI} -o ${DBSWITCH_TMPFILE2} -F \"~\" -t -A -nps"
    echo ${DBSWITCH_TMP_CMD}  >> ${DBSWITCH_OUTLOG}
    eval ${DBSWITCH_TMP_CMD} 2>&1
    cat ${DBSWITCH_TMPFILE2} >> ${DBSWITCH_TMPFINAL}


    #Generated new synonyms on BI database
    echo "# BI Switch step 3" >> ${DBSWITCH_OUTLOG}
    echo "# Executing script :" >> ${DBSWITCH_OUTLOG}
    echo "# BEGIN SCRIPT"  >> ${DBSWITCH_OUTLOG}
    cat ${DBSWITCH_TMPFINAL}  >> ${DBSWITCH_OUTLOG}
    echo "# END SCRIPT"  >> ${DBSWITCH_OUTLOG}

    #OLD Version, replace by EXECUTE IMMEDIATE CALL THROUGH STORED PROCEDURE
    # IBM MIGRATION
    DBSWITCH_TMPFILE3=`mktemp -t DBSQL.XXXXXXXXXX`
    DBSWITCH_TMP_CMD="dbsql  -q  -f ${DBSWITCH_TMPFINAL}  -d ${DB_BLUDB} -schema BI_${ENVIRONNEMENT} -o ${DBSWITCH_TMPFILE3} -F \"~\" -t -A -nps"
    echo "# executing command: ${DBSWITCH_TMP_CMD}"  >> ${DBSWITCH_OUTLOG}
    eval ${DBSWITCH_TMP_CMD} 2>&1

    # Update DATABASE_STATUS table
    DBSWITCH_TMPFILE4=`mktemp -t DBSQL.XXXXXXXXXX`
    DBSWITCH_TMPQUERY="DELETE FROM BI_DATABASE_STATUS WHERE DATABASE_TYPE = '${DBSWITCH_MODE}' AND LAST_PRDSIT_CF ='${HOST_PRDSIT}'; INSERT INTO BI_DATABASE_STATUS (DATABASE_TYPE, DATABASE_NAME, CURRENT_ENVIRONMENT, LAST_SWITCH, LAST_PRDSIT_CF) VALUES ('${DBSWITCH_MODE}','${ACTIVE_BI}','${ENVIRONNEMENT}', current_timestamp, '${HOST_PRDSIT}');"
    DBSWITCH_TMP_CMD="dbsql  -A -t -r -c \"${DBSWITCH_TMPQUERY}\" -d ${DB_BLUDB} -schema BI_${ENVIRONNEMENT} -nps"
    echo "# executing command: ${DBSWITCH_TMP_CMD}"  >> ${DBSWITCH_OUTLOG}
    eval ${DBSWITCH_TMP_CMD} 2>&1

fi

DBLOGEND -l LEV1 -j DBSWITCH_${DBSWITCH_MODE} -r 0 -m "Switch Ok"