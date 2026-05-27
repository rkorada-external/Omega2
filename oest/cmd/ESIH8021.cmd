#!/bin/ksh
#=============================================================================
# nom de l'application      : ESTIMATES
#                           : AGEING BALANCE
# nom du script SHELL       : ESIH8021.cmd
# revision                  : $Revision: 1.3 $
# date de creation          : 05/02/2008
# auteur                    : VAN DE VELDE JF
# references des specifications :
#-----------------------------------------------------------------------------
# description :   TRAITEMENT de la balance agee reference a partir de la date du document
# SELECT THE MOVEMENTS OF THE TABLE BCTA..TCURTRS
# UPDATING OF THE TABLE bsta..TDEBCRED
# JOB LANCHED BY  ESIH8020.cmd
#----------------------------------------------------------------------------------------
# last  modifications :
# 20/03/2008	jfvdv  	SPOT13056: Prise en compte de la nouvelle colonne LOCAL_CF
#                       0 = traitement reference date bilan
#                       1 = traitement reference date du document
# 28/03/2008	jfvdv  	SPOT13056: Amenagement du traitement pour la prise en compte d une ou plusieurs filiales
#                                le parametre SSD_CF devient de l'alphanumerique
# 21/05/2008	jfvdv  	SPOT13056: ajout step de ssuppression des fichiers .dat
# 21/06/2010	JF VDE	[19323] - Refonte du declenchement de la Balance Agee
# 07/10/2010	JF VDE	[19323] - Ajout du parametre LOCAL_CF (distinction BA date doc et BA date bilan)
# 09/09/2013	Prajakta        Data selection changes	(Modification 6)
# 2014-02-12    usumeme Removed extra ',' in the select clause of step 50
# 2014-02-12    usumeme Removed partition option of step 65
#========================================================================================
# Call generic functions
. ${DUTI}/fctgen.cmd
#set -x

# Get Input parameters
DATE_T=$1
FORCE_DTE=$2
SSD_CF=$3
SIMULATION=$4

#Initialisation of the job
JOBINIT

# Ne rien traiter si c'est une simulation mais qu'aucune date n'est renseignee
if [ "${SIMULATION}" = 'Y' ]
then
    if [ "${FORCE_DTE}" = 'null' ] || [ "${FORCE_DTE}" = 'NULL' ] || [ "${FORCE_DTE}" = '' ]
    then
        LOGWRITE 1 '!!! SIMULATION = Y et pas de FORCE_DTE, pas de traitement'
        JOBEND
    fi
fi

#Put a WARNING in status when the parameter FORCE_DTE is used
if [ "${FORCE_DTE}" != 'null' ] && [ "${FORCE_DTE}" != 'NULL' ] && [ "${FORCE_DTE}" != '' ]
then
NSTEP=${NJOB}_00
# Create Warning word file
#---------------------------------------------------------------
LIBEL="Create Warning word file"
cat > ${DFILT}/${NSTEP}_${IB}_WARNING.wng <<EOF
WARNING
!!!! PLEASE, VERIFY THE PARAMETER FORCE_DTE - shouldn't it be replaced by NULL?   !!!!
EOF
fi

#------------------------------------------------------------------------------
NSTEP=${NJOB}_01
# switch server
#------------------------------------------------------------------------------
LIBEL="Switch in Infocenter server"
SWITCH_SRV ${SRV_2}

#------------------------------------------------------------------------------
NSTEP=${NJOB}_02
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Return values month, year, date clothing of the new AND last AGED by date doc"
ISQL_BASE="BCTA"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
ISQL_QRY="execute BSTA..PtBALAGEE_16 '${FORCE_DTE}', '1'"
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_FRES_O1.dat

ISQL_RES

BLCSHTYEA=`cat ${ISQL_FRES} | cut -d_ -f1| sed -e s/\ //g`
BLCSHTMTH=`cat ${ISQL_FRES} | cut -d_ -f2| sed -e s/\ //g`
CLODATNEW=`cat ${ISQL_FRES} | cut -d_ -f3| sed -e s/\ //g`
CLODATLAST=`cat ${ISQL_FRES} | cut -d_ -f4| sed -e s/\ //g`

echo 'BLCSHTYEA   = ' ${BLCSHTYEA}
echo 'BLCSHTMTH   = ' ${BLCSHTMTH}
echo 'CLODATNEW   = ' ${CLODATNEW}
echo 'CLODATLAST  = ' ${CLODATLAST}


#------------------------------------------------------------------------------
NSTEP=${NJOB}_03
# switch server
#------------------------------------------------------------------------------
LIBEL="Switch in Production server"
SWITCH_SRV ${SRV_DEFAULT}

#------------------------------------------------------------------------------
NSTEP=${NJOB}_05
# Begin isql
# the query can return 4 values
# Values:
# 1 used DATE_T ( treatment is ok)
# 2 used DATE_T accounting date not validated ( treatment is ko)
# 3 used FORCE_DTE ( treatment is ok)
# 4 means no quotation currency for the required date (DATE_T or FORCE_DTE)
#------------------------------------------------------------------------------
LIBEL="Step doing an Control of the balance sheet date "
ISQL_BASE="BCTA"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
ISQL_QRY="execute BCTA..PtBALAGEE_03 '${DATE_T}','${FORCE_DTE}','${SIMULATION}',${BLCSHTYEA},${BLCSHTMTH},'${CLODATNEW}'"
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_FRES_O1.dat

ISQL_RES

# If accounting date not validated for required date DATE_T
# if there is no quotation currency for the required date (DATE_T or FORCE_DTE)
# then the job must not be executed and stopped normally

DATE_STATUS=`cat ${ISQL_FRES} | cut -d_ -f1| sed -e s/\ //g`
CLODAT=`cat ${ISQL_FRES} | cut -d_ -f2| sed -e s/\ //g`

echo 'Date_status = ' ${DATE_STATUS}
echo 'CLODAT      = ' ${CLODAT}

#    DATE_STATUS=`cat ${ISQL_FRES}`
if [ ${DATE_STATUS} -eq 2 ] || [ ${DATE_STATUS} -eq 4 ]
then
   [ ${DATE_STATUS} -eq 2 ] && LOGWRITE 1 '!!!! ACCOUNTING DATE NOT VALIDATED !!!!'
   [ ${DATE_STATUS} -eq 4 ] && LOGWRITE 2 '!!!! NO QUOTATION CURRENCY FOR INPUT DATE !!!!'

    JOBEND
fi

#
# If DATE_T is the date used for the job
# Check if the ageing balance exist for the ${CLODAT} in TDEBCRED
# If it exists, then the job must not continue and be stopped normally
# The test must be done on the infocenter server, that is why SWITCH_SRV is used
#
if [ ${DATE_STATUS} -eq 1 ]
then
   #---------------------------------------------------------------------------
   NSTEP=${NJOB}_10
   # switch server
   #---------------------------------------------------------------------------
   LIBEL="Switch in Infocenter server"
   SWITCH_SRV ${SRV_2}

   #---------------------------------------------------------------------------
   NSTEP=${NJOB}_15
   # Begin isql
   #---------------------------------------------------------------------------
   LIBEL="Test if the ageing balance exist for the ${CLODAT} in TDEBCRED"
   ISQL_QRY=`CFTMP`
   ISQL_BASE="BSTA"
   ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O2.dat
   ISQL_QRY="execute BSTA..PtBALAGEE_14 '${CLODAT}', '${SSD_CF}'"
   ISQL_FRES=${DFILT}/${NSTEP}_${IB}_FRES_O2.dat
   ISQL_INFO
   if [ `cat ${ISQL_FRES}` -eq 1 ]
   then
	RMFIL "${DFILT}/${NSTEP}*_${IB}_*.dat"
	LOGWRITE 1  '!!!! job not processed, because the ageing balance already exist in bsta..TDEBCRED!!!!'
	JOBEND
   fi

   #---------------------------------------------------------------------------
   NSTEP=${NJOB}_20
   # switch server
   #---------------------------------------------------------------------------
   LIBEL="Switch in Production server"
   SWITCH_SRV ${SRV_DEFAULT}

fi # End of test on Infocenter server

#----------------------------------------------------------------------------
NSTEP=${NJOB}_25
# Begin isql
#----------------------------------------------------------------------------

LIBEL="Step doing an extraction of RES from the tables TCURTRS & TTRSHTZ"
ISQL_BASE="BCTA"
ISQL_QRY="execute BCTA..PtBALAGEE_11 '${CLODAT}', '${FORCE_DTE}', '${SSD_CF}'"
ISQL


#----------------------------------------------------------------------------
NSTEP=${NJOB}_30
# Begin BCP OUT
#----------------------------------------------------------------------------
LIBEL="BCP out of the new ageing balance built in BCTA..PtBALAGEE_02 "
BCP_WAY="OUT"; BCP_VER="+"
BCP_O="${DFILT}/${NSTEP}_${IB}_BCP_TDEBCRED_O1.dat"
BCP_QRY="execute BCTA..PtBALAGEE_12 '${CLODAT}', '${FORCE_DTE}', '${SSD_CF}', '${HOST_PRDSIT}', '${SIMULATION}'"
BCP

#------------------------------------------------------------------------------
NSTEP=${NJOB}_35
# switch server
#------------------------------------------------------------------------------
LIBEL="Switch in Infocenter server"
SWITCH_SRV ${SRV_2}

#----------------------------------------------------------------------------
NSTEP=${NJOB}_40
# Begin isql
#----------------------------------------------------------------------------
LIBEL="DELETED table bsta..TDEBCRED"
# DELETED if the ageing balance exist for the required date(FORCE_DTE)
#            equal the closing date(CLODATE_D)
# None action if the ageing balance not exist
ISQL_BASE="BSTA"
ISQL_QRY="execute BSTA..PtBALAGEE_15 '${DATE_T}', '${FORCE_DTE}', '${SSD_CF}','${HOST_PRDSIT}', '${SIMULATION}'"
ISQL

#----------------------------------------------------------------------------
NSTEP=${NJOB}_45
# Begin BCP IN
#----------------------------------------------------------------------------
#Modification 6
LIBEL="BCP in of the new ageing balance built in BCTA..PtBALAGEE_02 "
BCP_WAY="IN"; BCP_VER=""; BCP_PARTITION="YES"
BCP_I="${DFILT}/${NJOB}_30_${IB}_BCP_TDEBCRED_O1.dat"
#  BCP_I="${DFILT}/D_ESIH8020_ESIH8021_30_BCP_TDEBCRED_O1.dat"
BCP_TABLE="BSTA..TDEBCRED"
BCP

NSTEP=${NJOB}_50
# Begin isql-bcpmulti
#---------------------------------------------------------------
#MODIFICATION 6
LIBEL="Extraction des enregistrements presents dant TLSTTRT infomega concernant ESIH8020"
BCP_WAY="OUT"; BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_O1_TLSTTRT_INFOCENTRE.dat
BCP_QRY="select * from BCTA..TLSTTRT T1,BREF..TBATCHSSD TSSD	
          where T1.BATCH_LS = 'ESIH8020' 
		  and T1.ssd_cf = TSSD.ssd_cf
		  and TSSD.BATCHUSER_CF = suser_name()"
BCP

NSTEP=${NJOB}_55
# switch server
#------------------------------------------------------------------------------
LIBEL="Switch in prod server"
SWITCH_SRV ${SRV_DEFAULT}

NSTEP=${NJOB}_60
# Begin isql
#-----------------------------------------------------------------
#MODIFICATION 6
LIBEL="Suppression des enregistrements de TLSTTRT concernant ESIH8200 sur prod"
ISQL_BASE="BCTA"
ISQL_QRY="
delete BCTA..TLSTTRT
  from BCTA..TLSTTRT
 where BATCH_LS = 'ESIH8020' 
 and ssd_cf IN (SELECT TSSD.ssd_cf from BREF..TBATCHSSD TSSD
 WHERE TSSD.BATCHUSER_CF = suser_name())	"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_DELETE_TTLSTTRT.log
ISQL

NSTEP=${NJOB}_65
# Begin BCP IN
#-----------------------------------------------------------------
#MODIFICATION 6
LIBEL="Bcp in "
BCP_WAY="IN"; BCP_VER=""
BCP_I=${DFILT}/${NJOB}_50_${IB}_BCP_O1_TLSTTRT_INFOCENTRE.dat
BCP_TABLE="BCTA..TLSTTRT"
BCP

#------------------------------------------------------------------------------
NSTEP=${NJOB}_70
# Begin rm
#------------------------------------------------------------------------------
LIBEL="Remove the temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"


# End of the Job
JOBEND
