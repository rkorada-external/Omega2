#-----------------------------------------------------------------------------------------------------------------------------------------------------------
# AUTHORS:               Nour Miloua, Vincent Gautier, Roger Cassis
# CREATE DATE:           13/12/2015
# LAST MODIF DATE:       13/12/2015
# DESCRIPTION:           Reinsurance analytics dataload switch for ODS and DWH databases
# Change Log:
# 13/12/2015: Creation :spot:30171
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
#set -x

# Call generic functions
. ${DUTI}/functions/fctnz/NZLOGINIT
. ${DUTI}/functions/fctnz/NZLOGEND

usage() { 
cat << EOF
Usage:
NZSWITCH  -M *NZSWITCH_MODE
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
# The following parameters must be previously defined:
# NSTEP                             : STEP Identifier (Mandatory) defined from caller shell script or set by default to NLOAD_AUTONOMOUS_MODE
# -M *NZSWITCH_MODE            : if set to ODS or DWH, TEACTIVE_DATABASE will be updated with next ODS or DWH database to load
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
EOF
exit -1

}

export JDATE_YYYYMMDDHHMMSS=`date +"%Y%m%d%H%M%S"`
export JDATE_DDMMYYHHMM=`date +"%d/%m/%Y %H:%M"`


NZSWITCH_OUTLOG=$DNZFILT/`hostname`_NZSWITCH_`date "+%Y-%m-%d_%H-%M-%S-%N"`.log


if [ -f ${NZSWITCH_OUTLOG} ] ; then
    mv ${NZSWITCH_OUTLOG} "${NZSWITCH_OUTLOG}.bak"
fi
touch ${NZSWITCH_OUTLOG}


OPTIND=1
while getopts "M:" o
do
    case "${o}" in
        M)
        NZSWITCH_MODE=${OPTARG}
        ;;
        * | -h )
        usage
        ;;
    esac
done
shift $((OPTIND-1))

NZLOGINIT -l LEV1 -j NZSWITCH_${NZSWITCH_MODE}
    
if [ -z ${NZSWITCH_MODE} ] ; 
then
    usage
    NZLOGEND -l LEV1 -j NZSWITCH_${NZSWITCH_MODE} -r 1 -m "Invalid parameters"
fi

# Execute switch
echo "[NZSWITCH_MODE]:         ${NZSWITCH_MODE}" >> ${NZSWITCH_OUTLOG}
NZSWITCH_TMPFILE=`mktemp -t NZSQL.XXXXXXXXXX`
nzsql  -q  -c "select DELIVERY.SP_DELIVER_SWITCH_DB('${NZSWITCH_MODE}')"  -d DELIVERY_${ENVIRONNEMENT} -o ${NZSWITCH_TMPFILE} -F "~" -t -A    
NZSWITCH_RETURN_CODE=$?
if [ ${NZSWITCH_RETURN_CODE} -ne 0 ] ; 
then
    export PRGANO=${NZSWITCH_OUTLOG}
    echo "# Error happend during switch query execution"
    echo "# Log file:  ${NZSWITCH_OUTLOG}"
    NZLOGEND -l LEV1 -j NZSWITCH_${NZSWITCH_MODE} -r 1 -m "Error happend during switch query execution"
    return ${NZSWITCH_RETURN_CODE}
else
    echo "Temporary nzsql mode query result output before deletion: " >>  ${NZSWITCH_OUTLOG}
    cat ${NZSWITCH_TMPFILE} >> ${NZSWITCH_OUTLOG}
    rm -f ${NZSWITCH_TMPFILE}
    echo "# Switch to new ${NZSWITCH_MODE} OK"
    echo "# Log file:  ${NZSWITCH_OUTLOG}"
fi

ACTIVE_DWH=`$DUTI/functions/fctnz/NZGETACTIVEDB.cmd -M DWH`
ACTIVE_BI=`$DUTI/functions/fctnz/NZGETACTIVEDB.cmd -M BI`

if [ ${NZSWITCH_MODE} == 'BI' ] 
then 

    NZSWITCH_TMPFINAL=`mktemp -t NZSQL.XXXXXXXXXX`
     
    #Extract BI database synonyms to drop
    echo "# BI Switch step 1" >> ${NZSWITCH_OUTLOG}
    NZSWITCH_TMPFILE1=`mktemp -t NZSQL.XXXXXXXXXX`
    NZSWITCH_TMPQUERY="select 'DROP SYNONYM BI.'|| SYNONYM_NAME || ';'  as QUERY_CF from SYSTEM.DEFINITION_SCHEMA._V_SYNONYM a where a.DATABASE = 'BI_${ENVIRONNEMENT}'  and a.SCHEMA = 'BI'"
    NZSWITCH_TMP_CMD="nzsql -q -c \"${NZSWITCH_TMPQUERY}\" -d BI_${ENVIRONNEMENT} -o ${NZSWITCH_TMPFILE1} -F \"~\" -t -A"
    echo ${NZSWITCH_TMP_CMD}  >> ${NZSWITCH_OUTLOG}
    eval ${NZSWITCH_TMP_CMD}
    cat ${NZSWITCH_TMPFILE1} >> ${NZSWITCH_TMPFINAL}



    #Extract new active BI-DWH tables for which synonyms need to be created
    echo "# BI Switch step 2" >> ${NZSWITCH_OUTLOG}
    NZSWITCH_TMPFILE2=`mktemp -t NZSQL.XXXXXXXXXX`
    NZSWITCH_TMPQUERY="select  'CREATE SYNONYM BI.'|| TABLENAME || ' FOR ${ACTIVE_BI}.' || 'DWH' || '.' || TABLENAME || ';' AS QUERY_CF from SYSTEM.DEFINITION_SCHEMA._V_TABLE a  where a.DATABASE = '${ACTIVE_BI}'  and a.SCHEMA = 'DWH'"
    NZSWITCH_TMP_CMD="nzsql  -q  -c \"${NZSWITCH_TMPQUERY}\"  -d ${ACTIVE_BI} -o ${NZSWITCH_TMPFILE2} -F \"~\" -t -A"
    echo ${NZSWITCH_TMP_CMD}  >> ${NZSWITCH_OUTLOG}
    eval ${NZSWITCH_TMP_CMD}
    cat ${NZSWITCH_TMPFILE2} >> ${NZSWITCH_TMPFINAL}


    #Generated new synonyms on BI database
    echo "# BI Switch step 3" >> ${NZSWITCH_OUTLOG}
    echo "# Executing script :" >> ${NZSWITCH_OUTLOG}
    echo "# BEGIN SCRIPT"  >> ${NZSWITCH_OUTLOG}
    cat ${NZSWITCH_TMPFINAL}  >> ${NZSWITCH_OUTLOG}
    echo "# END SCRIPT"  >> ${NZSWITCH_OUTLOG}

    #OLD Version, replace by EXECUTE IMMEDIATE CALL THROUGH STORED PROCEDURE
    #NZSWITCH_TMPFILE3=`mktemp -t NZSQL.XXXXXXXXXX`
    #NZSWITCH_TMP_CMD="nzsql  -q  -f ${NZSWITCH_TMPFINAL}  -d BI_${ENVIRONNEMENT} -o ${NZSWITCH_TMPFILE3} -F \"~\" -t -A"
    #echo "# executing command: ${NZSWITCH_TMP_CMD}"  >> ${NZSWITCH_OUTLOG}
    #eval ${NZSWITCH_TMP_CMD}


    NZSWITCH_TMPFILE3=`mktemp -t NZSQL.XXXXXXXXXX`
    NZSWITCH_TMP_CMD="nzsql -q -c \"SELECT BI.SP_BI_EXECUTE_QUERY('`cat ${NZSWITCH_TMPFINAL}`')\" -d BI_${ENVIRONNEMENT} -o ${NZSWITCH_TMPFILE3} -F \"~\" -t -A"
    echo "# executing command: ${NZSWITCH_TMP_CMD}"  >> ${NZSWITCH_OUTLOG}
    eval ${NZSWITCH_TMP_CMD}

    # Update DATABASE_STATUS table
    NZSWITCH_TMPFILE4=`mktemp -t NZSQL.XXXXXXXXXX`
    NZSWITCH_TMPQUERY="DELETE FROM DATABASE_STATUS WHERE DATABASE_TYPE = '${NZSWITCH_MODE}' AND LAST_PRDSIT_CF ='${HOST_PRDSIT}'; INSERT INTO DATABASE_STATUS (DATABASE_TYPE, DATABASE_NAME, CURRENT_ENVIRONMENT, LAST_SWITCH, LAST_PRDSIT_CF) VALUES ('${NZSWITCH_MODE}','${ACTIVE_BI}','${ENVIRONNEMENT}', current_timestamp, '${HOST_PRDSIT}');"
    NZSWITCH_TMP_CMD="nzsql -d -A -t -r -c \"${NZSWITCH_TMPQUERY}\" -d BI_${ENVIRONNEMENT}"
    echo "# executing command: ${NZSWITCH_TMP_CMD}"  >> ${NZSWITCH_OUTLOG}
    eval ${NZSWITCH_TMP_CMD}

fi

NZLOGEND -l LEV1 -j NZSWITCH_${NZSWITCH_MODE} -r 0 -m "Switch Ok"