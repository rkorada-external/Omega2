#! /bin/ksh
#=======================================================================
#
# Shell :  DB_DUMP_LOGIC.cmd
#
# Objet :  Logical dump tables 
#  
# Syntaxe :   DB_DUMP_LOGIC.cmd  SERVER DBNAME TABLE
#
#########################################################################
echo ""
if [ $# -lt 3 ]
then
        echo 'Syntaxe : DB_DUMP_LOGIC.cmd SERVER DBNAME TABLE'
        exit 12
fi
SERVER=$1
DBNAME=$2
TABLE=$3
USER="sa"
#
# Administration Environment
#
. ${DSYBENV}/ADMSRV.env
#
PASSWD=`GetSaPasswd ${SERVER}`
#
#----------------------
# environment variables
#----------------------
#
file_wrk1=${ADMTMP}/${SERVER}_${DBNAME}_DB_DUMP_LOGIC.tmp
file_wrk2=${ADMLOG}/${SERVER}_${DBNAME}_${TABLE}_DB_DUMP_LOGIC.log
# 
# remove file if exists
#
[ -r $file_wrk1 ] && /usr/bin/rm -f  $file_wrk1
[ -r $file_wrk2 ] && /usr/bin/rm -f  $file_wrk2
##
# message to log file
#
echo ""
und='----------------------------------------------------------------------'
echo "$und " |tee -a ${file_wrk2}
echo "${SERVER} : START OF Logical Dump on ${DBNAME}..${TABLE} : `date`"|tee -a ${file_wrk2}
#--------------------------------------
# connect to SQL to see if login failed
#--------------------------------------
#
${SYBASE}/${SYBASE_OCS}/bin/isql -S${SERVER} -U${USER} > $file_wrk1 << !!! 
${PASSWD}
use ${DBNAME}
go
!!!
# check if login correct
isloginfailed=`grep "Login failed" $file_wrk1 | wc -l`
if [ $isloginfailed -ne 0 ]; then
{
        # remove files and send message
        #
        echo "Server '${SERVER}' : Erreur Login"
	exit 12
}
fi
# check to see if server name is found in interface file
#
isinterface=`grep "Server name not found in interface file" $file_wrk1 | wc -l`
if [ $isinterface -ne 0 ]; then
{
	echo "Server '${SERVER}' : Server name not found in interface file."
	exit 12
}
fi
#
#-------------------------------------------
# connect to SQL Server and get control file
#-------------------------------------------
#
CTRLFILE=${DT_SBACKTRACK_PATH_LOGIC}/${SERVER}/${DBNAME}/${TABLE} 
DTPATH=/produits/sqlbt/sbacktrack.intl-3.1.1/bin
DTTEMPDIR=/testwk/dupli/rec/tmp; export DTTEMPDIR
DTBASE=/produits/sqlbt; export DTBASE
DT_SBACKTRACK_HOME=/produits/sqlbt/sbacktrack; export DT_SBACKTRACK_HOME
echo $DT_SBACKTRACK_HOME
PATH=$DTPATH:$PATH ; export PATH
$DTPATH/dtsbackup -noprompt -nostatus -tasks 4 $CTRLFILE 
DTSTATUS=$?
if [ ${DTSTATUS} -gt 1 ]
then
     ERREUR=1
     echo "${und}" | tee -a $file_wrk2
     echo "ERROR dtsbackup on ${SERVER}" | tee -a $file_wrk2
else   
     ERREUR=0 
     echo "$und" | tee -a $file_wrk2
     echo "${SERVER} : END OF Logical Dump on ${DBNAME}..${TABLE} le : `date`" | tee -a $file_wrk2
fi
echo "${und}" | tee -a $file_wrk2
#
[ -r $file_wrk1 ] && /usr/bin/rm -f  $file_wrk1
exit ${ERREUR}
