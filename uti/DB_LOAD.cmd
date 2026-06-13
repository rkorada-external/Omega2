#! /bin/ksh
#=======================================================================
#
# Shell :  DB_LOAD.cmd
#
# Objet :  Load database on each databases of a SQL Server
#  
# Syntaxe :   DB_LOAD.cmd  SERVER DBNAME
#
#########################################################################
echo ""
if [ $# -lt 2 ]
then
        echo 'Syntaxe : DB_LOAD.cmd SERVER DBNAME'
        exit 12
fi
SERVER=$1
DBNAME=$2
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
file_wrk1=${ADMTMP}/${SERVER}_${DBNAME}_DB_LOAD.tmp
file_wrk2=${ADMLOG}/${SERVER}_${DBNAME}_DB_LOAD.log
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
echo "${SERVER} : START OF Load Database on ${DBNAME}  : `date`"|tee -a ${file_wrk2}
#--------------------------------------
# connect to SQL to see if login failed
#--------------------------------------
#
${SYBASE}/${SYBASE_OCS}/bin/isql -S${SERVER} -U${USER} > $file_wrk1 << !!! 
${PASSWD}
use master
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
${DSYBBIN}/dba_load_database.ksh -F ${SERVER} -T ${SERVER} -D ${DBNAME}
DTSTATUS=$?
if [ ${DTSTATUS} -ne 0 ]
then
     ERREUR=1
     echo "${und}" | tee -a $file_wrk2
     echo "ERROR dba_load_database on ${SERVER}" | tee -a $file_wrk2
else   
     ERREUR=0 
     echo "$und" | tee -a $file_wrk2
     echo "${SERVER} : END OF Load Database on ${DBNAME} le : `date`" | tee -a $file_wrk2
fi
echo "${und}" | tee -a $file_wrk2
#
[ -r $file_wrk1 ] && /usr/bin/rm -f  $file_wrk1
exit ${ERREUR}
