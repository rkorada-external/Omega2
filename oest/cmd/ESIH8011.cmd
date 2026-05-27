#!/bin/ksh
#=============================================================================
# nom de l'application      : ESTIMATES
#                           : COMPANY DEBITOR/CREDITOR
# nom du script SHELL       : ESIH8011.cmd
# revision                  : $Revision: 1.4 $
# date de creation          : 03/12/98
# auteur                    : VAN DE VELDE JF
# references des specifications :
#-----------------------------------------------------------------------------
# description :
# SELECT THE MOVEMENTS OF THE TABLE BSAR..TTCLEDA_X and TTCLEDR_X
# UPDATING OF THE TABLE BSTA..TDEBCRED
# JOB LANCHED BY  ESIH8010.cmd
#----------------------------------------------------------------------------------------
# last  modifications :
# <jj/mm/aaaa>	<author>	<description of  modification>
#  21/12/1998	van de velde	balsheyea and balshtmth must be  char( ) parameters
#  26/01/1999	van de velde	Put parameter SSD_CF in first position
#				replace ssd_cf = 2 by ssd_cf =${SSD_CF} step 10
#  27/06/2000	van de velde	Replace "STEPEND" by "JOBEND" (step 05 & 20 )
#  12/10/2002   D.GATIBELZA     Ajout du parametre de SIMULATION ( forcee a  'N' ) a  l'envoi
#                                de PtBALAGEE_03
# 02/02/2005	JF VDE	    Put a WARNING in status when the parameter FORCE_DTE is used
#                           (For not to forget to give the FORCE_DTE to NULL after execution)
#20/02/2006	JF VDE	    replace the table TCALEND by TBLCSHTD (proc bcta..PtBALAGEE_03)
#17/10/2006	JF VDE	    new step 20 research if company debitor creditor exist on table TDEBCRED (proc bsta..PtDEBCRED_02)
#12/02/2007	JF VDE	    changed test (step 20) with a new paremeter ${SDC_STATUS}
#03/12/2009	JF VDE	    [18356] - Mise en place d'un traitement SDC par simulation (nouveau lanceur ESID8920.cmd)
#16/06/2010	JF VDE	    [19323] - Refonte du declenchement de la Balance Agee et des SDC
#07/10/2010	JF VDE	    [19323] - Ajout filiale pour recherche derniere SDC
#========================================================================================
# Call generic functions
. ${DUTI}/fctgen.cmd
#set -x

# Get Input parameters
SSD_CF=$1
DATE_T=$2
FORCE_DTE=$3
SIMULATION=$5

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
NSTEP=${NJOB}_05
# switch server
#------------------------------------------------------------------------------
LIBEL="Switch in Infocenter server"
SWITCH_SRV ${SRV_2}

#------------------------------------------------------------------------------
NSTEP=${NJOB}_10
# Begin isql
# the query can return 4 status values
# Values:
# 1 DATE_T is used, controls with accounting date to BA is ok
# 2 DATE_T is used, BA not exist for the new accounting date (job stopped normally)
# 3 FORCE_DTE is USED, BA exist
# 4 FORCE_DTE is USED, BA not exist (job stopped normally)
#------------------------------------------------------------------------------
LIBEL="Return values status, year, month, date clothing of the last AND new SDC"
ISQL_BASE="BCTA"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
ISQL_QRY="execute BSTA..PtBALAGEE_17 '${FORCE_DTE}', ${SSD_CF}"
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_FRES_O1.dat

ISQL_RES
STATUS=`cat ${ISQL_FRES} | cut -d_ -f1| sed -e s/\ //g`
BLCSHTYEA=`cat ${ISQL_FRES} | cut -d_ -f2| sed -e s/\ //g`
BLCSHTMTH=`cat ${ISQL_FRES} | cut -d_ -f3| sed -e s/\ //g`
CLODATLAST=`cat ${ISQL_FRES} | cut -d_ -f4| sed -e s/\ //g`
CLODATNEW=`cat ${ISQL_FRES} | cut -d_ -f5| sed -e s/\ //g`
CLODAT_ba=`cat ${ISQL_FRES} | cut -d_ -f6| sed -e s/\ //g`

echo 'STATUS      = ' ${STATUS}
echo 'BLCSHTYEA   = ' ${BLCSHTYEA}
echo 'BLCSHTMTH   = ' ${BLCSHTMTH}
echo 'CLODATLAST  = ' ${CLODATLAST}
echo 'CLODATNEW   = ' ${CLODATNEW}
echo 'CLODAT_ba   = ' ${CLODAT_ba}
echo 'SSD_CF      = ' ${SSD_CF}
echo 'DATE_T      = ' ${DATE_T}
echo 'FORCE_DTE   = ' ${FORCE_DTE}

#    STATUS=`cat ${ISQL_FRES}`
if [ ${STATUS} -eq 2 ] || [ ${STATUS} -eq 4 ]
then
   [ ${STATUS} -eq 2 ] && LOGWRITE 1 '!!!! DATE-T is used, BA not exists for the new accounting date (normaly end of treatment) !!!!'
   [ ${STATUS} -eq 4 ] && LOGWRITE 2 '!!!! FORCE_DTE is used, BA not exists for the request accounting date (normaly end of treatment) !!!!'

  JOBEND
fi

#------------------------------------------------------------------------------
NSTEP=${NJOB}_15
# switch server
#------------------------------------------------------------------------------
LIBEL="Switch in Production server"
SWITCH_SRV ${SRV_DEFAULT}

#------------------------------------------------------------------------------
NSTEP=${NJOB}_20
# Begin isql
# the query can return 2 values
# Values:
# 0 used DATE_T or FORCE_DTE means quotation currency exist (treatment is ok)
# 1 used DATE_T or FORCE_DTE means no quotation currency for the required date (end of job)
#------------------------------------------------------------------------------
LIBEL="Step doing an Control of the quotation currency "
ISQL_BASE="BCTA"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
ISQL_QRY="execute BCTA..PtDEBCRED_03 ${BLCSHTMTH},${BLCSHTYEA},'${SIMULATION}'"
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_FRES_O1.dat

ISQL_RES

# if there is no quotation currency for the required date (DATE_T or FORCE_DTE)
# then the job must not be executed and stopped normally

CUR_STATUS=`cat ${ISQL_FRES} | cut -d_ -f1| sed -e s/\ //g`
echo 'CUR_STATUS = ' ${CUR_STATUS}

if [ ${CUR_STATUS} -eq 1 ]
then
   [ ${CUR_STATUS} -eq 1 ] && LOGWRITE 2 '!!!! NO QUOTATION CURRENCY FOR INPUT DATE !!!!'

    JOBEND
fi

#------------------------------------------------------------------------------
NSTEP=${NJOB}_25
# switch server
#------------------------------------------------------------------------------
LIBEL="Switch in Infocenter server"
SWITCH_SRV ${SRV_2}

# no control if the company debitor creditor already exist when the parameter FORCE_DTE is used
if [ "${FORCE_DTE}" != 'null' ] && [ "${FORCE_DTE}" != 'NULL' ] && [ "${FORCE_DTE}" != '' ]
then
    echo 'the parameter FORCE_DTE is used'
else
    #---------------------------------------------------------------------------
    NSTEP=${NJOB}_30
    # Begin isql
    #---------------------------------------------------------------------------
    LIBEL="Test if the CPY debitor creditor exist for the CLODAT ${CLODATNEW} in TDEBCRED "
    ISQL_QRY=`CFTMP`
    ISQL_BASE="BSTA"
    ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
    ISQL_QRY="execute BSTA..PtDEBCRED_02 '${CLODATNEW}','${SSD_CF}'"
    ISQL_FRES=${DFILT}/${NSTEP}_${IB}_FRES_O1.dat
ISQL_RES

    SDC_STATUS=`cat ${ISQL_FRES} | cut -d_ -f1| sed -e s/\ //g`
    echo 'SDC_STATUS = ' ${SDC_STATUS}

    if [ ${SDC_STATUS} -ge 1 ]
    then
        RMFIL "${DFILT}/${NSTEP}*_${IB}_*.dat"
       LOGWRITE 1  '!!!! job not processed, because the company debitor creditor already exist !!!!'
       JOBEND
    fi
    echo 'BLCSHTYEA   = ' ${BLCSHTYEA}
    echo 'BLCSHTMTH   = ' ${BLCSHTMTH}
    echo 'CLODATNEW   = ' ${CLODATNEW}
    echo 'CLODATLAST  = ' ${CLODATLAST}
    echo 'SSD_CF      = ' ${SSD_CF}
    echo 'DATE_T      = ' ${DATE_T}
    echo 'HOST_PRDSIT = ' ${HOST_PRDSIT}
    echo 'FORCE_DTE   = ' ${FORCE_DTE}
    echo 'SIMULATION  = ' ${SIMULATION}
fi

echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! '
echo '!!!!!!! Beginning of load to the company debitor creditor !!!!!!! '
echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! '

#------------------------------------------------------------------
NSTEP=${NJOB}_35
# Begin isql
#------------------------------------------------------------------
LIBEL="TTCLEDA_X & TTCLEDR_X extraction	and BSTA..TDEBCRED update"
ISQL_QRY="execute BSTA..PtDEBCRED_01 '${DATE_T}', '${FORCE_DTE}', '${SSD_CF}','${HOST_PRDSIT}', '${BLCSHTYEA}' ,'${BLCSHTMTH}' , '${CLODATNEW}','${SIMULATION}'"
ISQL_BASE="BSTA"
ISQL

#----------------------------------------------------------------------
NSTEP=${NJOB}_40
# Begin rm
#----------------------------------------------------------------------
LIBEL="Remove the temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"


# End of the Job
JOBEND
