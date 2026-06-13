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
Function that displays ODS/DWH/BI current active databases
Usage:
./$0  
EOF
exit -1

}


NZENVSTATE_OUTLOG=$DNZFILT/${NSTEP}_${IB}_GETACTIVEDB.`date "+%Y-%m-%d_%H-%M-%S-%N"`.log

touch ${NZENVSTATE_OUTLOG}


OPTIND=1
while getopts "M:" o
do
        case "${o}" in
                * | -h)
                usage
                ;;
        esac
done
shift $((OPTIND-1))



ACTIVE_ODS=`$DUTI/functions/fctnz/NZGETACTIVEDB.cmd -M ODS`
echo "# [ACTIVE ODS DB]: ${ACTIVE_ODS}"
ACTIVE_DWH=`$DUTI/functions/fctnz/NZGETACTIVEDB.cmd -M DWH`
echo "# [ACTIVE DWH DB]: ${ACTIVE_DWH}"
ACTIVE_BI=`$DUTI/functions/fctnz/NZGETACTIVEDB.cmd -M BI`
echo "# [ACTIVE BI DB]: ${ACTIVE_BI}"

return 0


