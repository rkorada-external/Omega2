#!/bin/ksh  
#=============================================================================
# nom de l'application : Complete Account
# nom du script SHELL  : CPTD0912.cmd
# date de creation     : 12/04/2019
# auteur               : KBagwe
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Load complete account data : Spira#70043
#   http://dcvprdxwikiu/xwiki/wiki/omega/view/DEV/BPR-CPT-908922
#
# Asynchronous Job launched by the TP 
#-----------------------------------------------------------------------------
# historiques des modifications
#[01] KBhimasen Spira 97604 - step 25 line number should be always +1
#===============================================================================
# set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Custumised Error handling
EXCEPTION () {

# Si le traitement va jusqu a la fin la fonction EXCEPTION ne doit rien faire
if test ${V_TESTEXCEPTION} -ne 0
   then
      # Cartouche de debut exception  ----------
      EXCEPTION_INIT

      if test ${V_RETURNCODE} -ne ${V_ANAMOLY_CHECK}   # To avoid SP call in case of anamoly raised by coherence check step.
      then
        # Begin isql
        #------------------------------------------------------------------------------
        LIBEL="Insert Error code for batch failure"
        ISQL_BASE="BCTA"
        ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
        ISQL_QRY="exec PiCACOHRCHK_01 ${SSD_CF}, ${ESB_CF}, '${USR_CF}', ${V_MESS}, ${NUMFIC_NT}, '${BALSHT_D}'  "
        ISQL_FRES=${DFILT}/${NSTEP}_${IB}_FRES_O1.dat
        ISQL
      fi

      # Cartouche de fin exception  ----------
      EXCEPTION_END
fi
}


# Job Initialisation
JOBINIT


#Step 1 Read input parameters
USR_CF=${1}
SSD_CF=${2}
ESB_CF=${3}
NUMFIC_NT=${4}
CUR_DATE=${5}
BALSHT_D=${6}
REP=${7}

V_MESS=''
V_TESTEXCEPTION=1
V_RETURNCODE=0
V_ANAMOLY_CHECK=9999     #To avoid PiCACOHRCHK_01 SP call again in case of anamoly raised by coherence check step.

if [ "${REP}" = "1" ] 
then
FILENAME=${DFILT}/${PCH}CPTJ1000_${SSD_CF}_${ESB_CF}_${USR_CF}_${NUMFIC_NT}.dat
else
FILENAME=${DUSERS}/${PCH}CPTD0912_${SSD_CF}_${ESB_CF}_${USR_CF}_${NUMFIC_NT}.dat
fi

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> USR_CF......................: ${USR_CF}"
ECHO_LOG "#===> SSD_CF......................: ${SSD_CF}"
ECHO_LOG "#===> CUR_DATE....................: ${CUR_DATE}  "
ECHO_LOG "#===> ESB_CF......................: ${ESB_CF}  "
ECHO_LOG "#===> NUMFIC_NT...................: ${NUMFIC_NT}"
ECHO_LOG "#===> BALSHT_D....................: ${BALSHT_D}"
ECHO_LOG "#===> REP.........................: ${REP}"


ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> FILENAME................: ${FILENAME}"

ECHO_LOG "#========================================================================="

V_MESS=3678
NSTEP=${NJOB}_00
#------------------------------------------------------------------------------
LIBEL="Check if file exists at FTP location"
if [ ! -e ${FILENAME} ]
then
echo "file not found at the location  ${FILENAME}"
        V_RETURNCODE=${V_MESS}
	trap EXCEPTION 0
         return V_RETURNCODE
fi

V_MESS=35119
NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="Check if file exists not empty"
if [ ! -s ${FILENAME} ]
then
echo "file empty  ${FILENAME}"
        V_RETURNCODE=${V_MESS} 
	trap EXCEPTION 0
         return V_RETURNCODE
fi

V_MESS=35120
NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="Check number of columns in file"
awk 'BEGIN{FS="~"} {if(NF!= 4){print 1;exit}}' ${FILENAME} > $DFILT/${NSTEP}_${IB}_ANO.dat
if [ -s $DFILT/${NSTEP}_${IB}_ANO.dat ]
then
echo "Wrong columns  ${FILENAME}"
	     V_RETURNCODE=${V_MESS}
         trap EXCEPTION 0
         return V_RETURNCODE
fi

## TO BE DONE BASED ON PARAMETER FROM EXTERNAL SYSTEM
##if [ "${NUMFIC_NT}" == "" ]
##then
##
##V_MESS=3679
##NSTEP=${NJOB}_14
### Begin isql
###------------------------------------------------------------------------------
##LIBEL="Insert row in TLOADCA to get NUMFIC_NT"
##ISQL_BASE="BCTA"
##ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
##ISQL_QRY="exec PtLOADCA_01 ${SSD_CF}, ${ESB_CF}, '${USR_CF}', '${FILENAME}' "
##ISQL_FRES=${DFILT}/${NSTEP}_${IB}_FRES_O1.dat
##ISQL_INFO
##
##export NUMFIC_NT=`cut -d"~" -f0`
##ECHO_LOG "#===> NEW NUMFIC_NT...................: ${NUMFIC_NT}"
##
##fi

V_MESS=3679
NSTEP=${NJOB}_15
#------------------------------------------------------------------------------
LIBEL=" Move file from FTP location to temporary location(DFILT)"
EXECKSH "mv ${FILENAME} ${DFILT}/${NSTEP}_${IB}_CPTD0912_${SSD_CF}_${ESB_CF}_${USR_CF}.dat"


V_MESS=3679
NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="Convert carriage-returns to Unix"
EXECKSH "dos2unix ${DFILT}/${NJOB}_15_${IB}_CPTD0912_${SSD_CF}_${ESB_CF}_${USR_CF}.dat"


V_MESS=3679
NSTEP=${NJOB}_25
#------------------------------------------------------------------------------
LIBEL="Add line number to file"
awk -v USR_CF=${USR_CF} -v SSD_CF=${SSD_CF} -v ESB_CF=${ESB_CF} -v BALSHT_D=${BALSHT_D} -v NUMFIC_NT=${NUMFIC_NT} 'BEGIN{FS="~"; OFS="~"}   {print $1,$2,$3,$4,SSD_CF, ESB_CF,USR_CF,BALSHT_D,NUMFIC_NT,NR+1,0 } ' ${DFILT}/${NJOB}_15_${IB}_CPTD0912_${SSD_CF}_${ESB_CF}_${USR_CF}.dat > ${DFILT}/${NSTEP}_${IB}_CPTD0912_${SSD_CF}_${ESB_CF}_${USR_CF}_AWK.dat

V_MESS=3679
NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
LIBEL="Delete existing data BTRAV..CPTD0912_WORKFILE"
ISQL_BASE="BTRAV"
ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
ISQL_QRY="Delete BTRAV..CPTD0912_WORKFILE where GSSD_CF=${SSD_CF} and GESB_CF=${ESB_CF} and USR_CF='${USR_CF}' "
ISQL


V_MESS=3679
NSTEP=${NJOB}_35
#------------------------------------------------------------------------------
LIBEL="Load in BTRAV...CPTD0912_WORKFILE"
BCP_WAY="IN"; BCP_VER=""
BCP_I="${DFILT}/${NJOB}_25_${IB}_CPTD0912_${SSD_CF}_${ESB_CF}_${USR_CF}_AWK.dat"
BCP_TABLE="BTRAV..CPTD0912_WORKFILE"
BCP


V_MESS=3679
NSTEP=${NJOB}_40
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Coherence checks"
ISQL_BASE="BCTA"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
ISQL_QRY="exec PiCACOHRCHK_01 ${SSD_CF}, ${ESB_CF}, '${USR_CF}', 0, ${NUMFIC_NT}, '${BALSHT_D}' "
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_FRES_O1.dat
ISQL_INFO


RET_STATUS=`cat ${ISQL_FRES}`
if [ ${RET_STATUS} -eq 1 ]
then
	     V_RETURNCODE=${V_ANAMOLY_CHECK}
         trap EXCEPTION 0
         return V_RETURNCODE
fi

V_MESS=3679
NSTEP=${NJOB}_45
#------------------------------------------------------------------------------
LIBEL="Update table complete account"
ISQL_BASE="BCTA"
ISQL_O=${DFILT}/${NSTEP}_${IB}_CA_ISQL.log
ISQL_QRY="exec PtCAACC_01  ${SSD_CF}, ${ESB_CF}, '${USR_CF}', ${NUMFIC_NT}, '${BALSHT_D}'"
ISQL

V_MESS=3679
NSTEP=${NJOB}_50
#------------------------------------------------------------------------------
LIBEL="Delete existing data BTRAV..CPTD0912_WORKFILE after success"
ISQL_BASE="BTRAV"
ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
ISQL_QRY="Delete BTRAV..CPTD0912_WORKFILE where GSSD_CF=${SSD_CF} and GESB_CF=${ESB_CF} and USR_CF='${USR_CF}' and NUMFIC_NT=${NUMFIC_NT}"
ISQL


 
# JOBEND execute d office la fonction EXCEPTION, comme cette derniere est surchargee,
# il faut repositionner ce flag pour qu'elle retrouve son contenu initialement vide
#-----------------------------------------------------------------------------
V_TESTEXCEPTION=0

NSTEP=${NJOB}_85
# Erase temporary files
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND 


