#!/bin/ksh
#=============================================================================
# nom de l'application          : DATABASE ADMINISTRATION
# nom du script SHELL		: CTRIG01.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 27/08/96
# auteur			: J.Y. Caro
# references des specifications : 
#-----------------------------------------------------------------------------
# description :
# Objet :   Creation Triggers for a database 
#
# Syntaxe : CTRIG01.cmd SERVERFrom BASE SERVERTo 
# 
#-----------------------------------------------------------------------------
# historiques des modifications :
#===============================================================================
#set -x


. ${DSYBENV}/ADMSRV.env

if [ $# -lt 2 ]
then
	echo 'Syntaxe : CTRIG01.cmd  SERVERfrom BASE [SERVERto]'
	echo 'if SERVERto is not given, SERVERto=SERVERfrom'
	exit 12
fi

SERVERfrom=$1
BASE=$2
if [ $# = 3 ]
then 
  SERVERto=$3
else
  SERVERto=$SERVERfrom
fi

USER="sa"
SORTIERREUR="NON"
JOBNAME=CREATRIG

#
# Administration Environment
# --------------------------
#
PASSWD=`GetSaPasswd ${SERVERto}`
##
# temp files
#
LISFIC=${ADMTMP}/${SERVERfrom}_${SERVERto}_${BASE}_${JOBNAME}_listfic.tmp
TRIGDIR=${ADMDAT}/${SERVERfrom}/${BASE}/TRIG
und='-----------------------------------------------------------------------------'
[ -f ${LISFIC} ] && /usr/bin/rm -f ${LISFIC}

# message sent to log file
# ------------------------
echo $und  
echo "${SERVERto} : START OF CREATE TRIGGER ${BASE} from ${SERVERfrom}: " `date`
echo $und 
#
# First, get the list of SQL file to run  
# --------------------------------------
ls ${TRIGDIR}/* > ${LISFIC}
#
#  Execute SQL File  
#  ----------------
for ficnam in `cat ${LISFIC}`
do
CRTRIG=${ADMTMP}/${SERVERfrom}_${SERVERto}_${BASE}_${JOBNAME}2.tmp
TMPUPD=${ADMTMP}/${SERVERfrom}_${SERVERto}_${BASE}_${JOBNAME}.tmp
[ -f ${CRTRIG} ] && /usr/bin/rm ${CRTRIG} 
echo " Create trigger "${ficnam}
echo "${SYBASE}/${SYBASE_OCS}/bin/isql -Usa -S${SERVERto} -Jiso_1 << EOF  " > ${CRTRIG}
echo "$PASSWD" >> ${CRTRIG} 
echo "use ${BASE}" >> ${CRTRIG} 
echo "go" >> ${CRTRIG} 
cat ${ficnam}  >> ${CRTRIG} 
echo "go" >> ${CRTRIG} 
echo "EOF" >> ${CRTRIG} 
chmod 770 ${CRTRIG}
${CRTRIG} > ${TMPUPD} 
grep '^[        ]*Msg' ${TMPUPD} > /dev/null 2>&1
if [ $? = 0 ]
then
     echo "${und}" 
     echo "ERROR during CREATION of ${ficnam} on ${SERVERto}"
     grep '^[        ]*Msg' ${TMPUPD} 2>&1
     echo "${und}"  
     SORTIERREUR="OUI"
fi
[ -f ${TMPUPD} ] && /usr/bin/rm ${TMPUPD} 
[ -f ${CRTRIG} ] && /usr/bin/rm ${CRTRIG} 
done
#
# message sent to log file
# ------------------------
echo $und 
echo "${SERVERto} : END OF CREATE TRIGGER : `date` " 
echo $und 
if [ ${SORTIERREUR} = "OUI" ]
then
  echo "ERROR in Creating trigger for ${BASE}  : Read the LOG File" 
  exit 12
fi    
[ -f ${LISFIC} ] && /usr/bin/rm -f ${LISFIC}
exit 0
# end of script
