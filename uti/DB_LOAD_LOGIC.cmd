#! /bin/ksh
#=======================================================================
#
# Shell :  DB_LOAD_LOGIC.cmd
#
# Objet :  Logical Load database on server database
#		OR  
#	  logical load of object type on server database  
#  
# Syntaxe :   DB_LOAD_LOGIC.cmd P SERVER.ORIG DBNAME.ORIG TABLE.ORIG SERVER.TARG [ DBNAME.TARG]
# 	OR
# Syntaxe :   DB_LOAD_LOGIC.cmd PT SERVER.ORIG DBNAME.ORIG type-of-object SERVER.TARG [ DBNAME.TARG]
#
# $2 name of source server (mandatory)
# $3 name of source database (mandatory) 
# $4 name of source table (mandatory) 
# $5 name of target server (mandatory) 
# $6 name of taget database (optional)
#########################################################################
# set -x
# initialisation des variables
SRV="" 
DB=""
TAB=""
SRV_TARG=""
SRV_T=""
DB_T=""
TYPE=$1
export USER=sa
echo ""
if [ $# -lt 4 ]
then
        echo 'Syntaxe : DB_LOAD_LOGIC.cmd TYPE SERVER.ORIG DBNAME.ORIG TABLE.ORIG SERVER.TARG [ DBNAME.TARG ] ' 
                exit 12
else
	SRV=$2;export SRV
	DB=$3; export DB
	TAB=$4; export TAB
	DB_L=${DB}
fi
if [ $# -ge 5 ]
then
	SRV_TARG="-server $5";export SRV_TARG
	SRV_T=$5
	if [ $# -ge 6 ]
	then
		DB_T="-database $6"; export DB_T
		DB_L=${DB_T}
	fi
fi		 

#
# Administration Environment
#
. ${DSYBENV}/ADMSRV.env
#

#----------------------
# environment variables
#----------------------
#
file_wrk1=${DTMP}/${SRV}_${DB}_${TAB}_DB_LOAD_LOGIC.tmp
# 
# remove file if exists
#
[ -r $file_wrk1 ] && /usr/bin/rm -f  $file_wrk1
##
# message to log file
#
echo ""
und='----------------------------------------------------------------------'
echo "$und " 
echo "${SRV} : START OF Logical Load on ${DB_L}..${TAB}  : `date`"
echo "$und "
#--------------------------------------
# connect to SQL ORIG to see if login failed
#--------------------------------------
#
PASSWD=`GetSaPasswd ${SRV}`
#
${SYBASE}/${SYBASE_OCS}/bin/isql -S${SRV} -U${USER} > $file_wrk1 << !!! 
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
        echo "Server '${SRV}' : Erreur Login" 
	exit 12
}
fi
# check to see if server name is found in interface file
#
isinterface=`grep "Server name not found in interface file" $file_wrk1 | wc -l`
if [ $isinterface -ne 0 ]; then
{
	echo "Server '${SRV}' : Server name not found in interface file." 
	exit 12
}
fi
#
#--------------------------------------
# connect to SQL TARGET to see if login failed
#--------------------------------------
#
PASSWD_T=`GetSaPasswd ${SRV_T}`

#
${SYBASE}/${SYBASE_OCS}/bin/isql -S${SRV_T} -U${USER} > $file_wrk1 << !!! 
${PASSWD_T}
use master
go
!!!
# check if login correct
isloginfailed=`grep "Login failed" $file_wrk1 | wc -l`
if [ $isloginfailed -ne 0 ]; then
{
        # remove files and send message
        #
        echo "Server '${SRV_T}' : Erreur Login" 
	exit 12
}
fi
# check to see if server name is found in interface file
#
isinterface=`grep "Server name not found in interface file" $file_wrk1 | wc -l`
if [ $isinterface -ne 0 ]; then
{
	echo "Server '${SRV_T}' : Server name not found in interface file." 
	exit 12
}
fi

#-------------------------------------------
# connect to SQL Server and get control file
#-------------------------------------------
#
case ${TYPE} in
	"L") CTRLFILE=${DT_SBACKTRACK_PATH_LOGIC}/${SRV}/${DB}/${TAB};
		OPTIONS=" -password ${PASSWD_T} -user ${USER}";OBJECT="-merge -replace";;
	"P") CTRLFILE=${DT_SBACKTRACK_PATH}/${SRV}/${DB};
		OPTIONS=" -password ${PASSWD_T} -user ${USER}";OBJECT="-object ${TAB} -tasks 3 -merge -replace";;
	"PT") CTRLFILE=${DT_SBACKTRACK_PATH}/${SRV}/${DB};OBJECT="-merge -replace -verbose";
		OPTIONS=" -password ${PASSWD_T} -user ${USER} -type ${TAB}";;
	*) echo invalid type of restore : L or P or PT;;
esac

dtsrecover $CTRLFILE ${SRV_TARG} ${DB_T} ${OBJECT} $OPTIONS
 
DTSTATUS=$?
if [ ${DTSTATUS} -gt 1 ]
then
     ERREUR=12
     echo "${und}" | tee -a $file_wrk2
     echo "ERROR Logical dtsrecover on ${TAB}" | tee -a $file_wrk2
else   
     ERREUR=0 
     echo "$und" | tee -a $file_wrk2
     echo "${SRV} : END OF Logical Load  ${TAB} le : `date`" 
fi
echo "${und}" 
#
[ -r $file_wrk1 ] && /usr/bin/rm -f  $file_wrk1
exit ${ERREUR}
