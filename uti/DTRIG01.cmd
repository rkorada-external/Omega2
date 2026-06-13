#! /bin/ksh
#===============================================================================
# nom de l'application          : MISE EN OEUVRE LOT 1
# nom du script SHELL           : DTRIG01.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 27/08/96
# auteur                        : J.Y. Caro
# references des specifications :
#-----------------------------------------------------------------------------
# historiques des modifications :
#    <23/09/1996>   <H. Roger>   <Integration dans chaine mise en oeuvre>
#===============================================================================
#
# Shell :   DTRIG01.cmd
#
# Objet :   Export all Triggers of a database and drop them
#
# Syntaxe : DTRIG01.cmd Server Base
#
# Input Variable : $ENV :
###########################################################
# set -x

. ${DSYBENV}/ADMSRV.env

if [ $# -lt 2 ]
then
	echo 'Syntaxe : DTRIG01.cmd  SERVER BASE'
	exit 12
fi
NJOB=DROPTRIG                   
#
#  Administration Environment
#  --------------------------
SERVER=$1
BASE=$2
USER="sa"
PASSWD=`GetSaPasswd ${SERVER}`
#
# message to log file
# -------------------
echo ""
und='---------------------------------------------------------------------------
-----'
echo "$und " 
# environment variables
# ---------------------
file_wrk1=${ADMTMP}/${SERVER}_${BASE}_${NJOB}.trig1
file_wrk3=${ADMTMP}/${SERVER}_${BASE}_${NJOB}.trig2
file_wrk4=${ADMTMP}/${SERVER}_${BASE}_${NJOB}.trig3
[ ! -d ${ADMDAT} ] && mkdir ${ADMDAT} 
ADMTRIG=${ADMDAT}/${SERVER}/${BASE}/TRIG
[ ! -d ${ADMTRIG} ] && mkdir -p ${ADMTRIG} 
#
# remove file if exists
# ---------------------
[ -r $file_wrk1 ] && /usr/bin/rm -f  $file_wrk1
[ -r $file_wrk3 ] && /usr/bin/rm -f  $file_wrk3
[ -r $file_wrk4 ] && /usr/bin/rm -f  $file_wrk4
/usr/bin/rm ${ADMTRIG}/*
#
echo "${SERVER} : START OF Extract Trigger from ${BASE} : `date`"
echo "$und " 
#
#
# connect to SQL to see if login failed
# -------------------------------------
${SYBASE}/${SYBASE_OCS}/bin/isql -S${SERVER} -U${USER} > $file_wrk1 << !!!
${PASSWD}
use master
go
!!!
# check if login correct
# ----------------------
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
# ------------------------------------------------------
isinterface=`grep "Server name not found in interface file" $file_wrk1 | wc -l`
if [ $isinterface -ne 0 ]; then
{
        echo "Server '${SERVER}' : Server name not found in interaface file."
        exit 12
}
fi     
# 
#       Select of Triggers 
#       ------------------
${SYBASE}/${SYBASE_OCS}/bin/isql -Usa -S${SERVER} <<EOF > ${file_wrk3}
${PASSWD}
use ${BASE}
go
select name
from sysobjects where type = "TR"
go
EOF
grep -i " t" ${file_wrk3} > ${file_wrk4}
#
#      Extract Trigger by dfncopy
#      --------------------------
for i in `cat ${file_wrk4}`
do
   echo " Extraction of Trigger " $i
   defncopy -Usa -P${PASSWD} -S${SERVER} -Jiso_1 out ${ADMTRIG}/$i.trig ${BASE} dbo.$i 
done
#
# Delete 'END of DEFNCOPY' message
#
CHEMIN=${ADMTRIG}
for i in `ls ${CHEMIN} | cat `
do
	awk '{ if ($0 != "/* ### DEFNCOPY: END OF DEFINITION */") print $0 }' ${CHEMIN}/$i > ${ADMTMP}/$i
	mv ${CHEMIN}/$i ${CHEMIN}/$i.old
	mv ${ADMTMP}/$i ${CHEMIN}/$i
	[ -r ${CHEMIN}/$i.old ] && /usr/bin/rm -f ${CHEMIN}/$i.old
done

echo "$und "
echo "${SERVER} : END OF Extract Trigger from ${BASE} : `date`"
echo "$und " 
echo "${SERVER} : START OF Drop Trigger from ${BASE} :" `date`
echo "$und "

for i in `cat ${file_wrk4}`
do
${SYBASE}/${SYBASE_OCS}/bin/isql -Usa -S${SERVER} <<EOF 
${PASSWD}
use ${BASE}
go
drop trigger $i
go
EOF
done
echo "$und "
echo "${SERVER} : END OF Drop Trigger from ${BASE} : `date`"
echo "$und "
[ -r $file_wrk1 ] && /usr/bin/rm -f  $file_wrk1
[ -r $file_wrk3 ] && /usr/bin/rm -f  $file_wrk3
[ -r $file_wrk4 ] && /usr/bin/rm -f  $file_wrk4
