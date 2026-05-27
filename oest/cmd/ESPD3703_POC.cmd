#!/bin/ksh

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
ICLODAT_D=$1

echo "Parameter Date is: ${ICLODAT_D}"

QUARTER=`echo ${ICLODAT_D} | cut -c5-6 | awk '{ if ($0<=3) print "1"; if ($0<=6 && $0>3) print "2"; if ($0<=9 && $0>6) print "3"; if ($0<=12 && $0>9) print "4" }'`

echo "Quarter is: ${QUARTER}"


JOBINIT

: '

********COMMENT OUT CODE OF DYNAMIC FILENAME SELECTION****************
JOBNAME="ESPD3620"

LOGFILE=`ls -rt ${DLOG}/*${JOBNAME}* | tail -1`

if [ ! -z ${LOGFILE} ]
then
        NOGO_CHECK=`cat ${LOGFILE} | grep "NO GO"`
else
        NOGO_CHECK=1
fi

if [ ! -z ${NOGO_CHECK} ]
then
        echo "We have a NO GO/LOG NOT FOUND for ${JOBNAME}."
        JOBNAME="ESPD3700"
        echo "Checking ${JOBNAME}"

        LOGFILE_TWO=`ls -rt ${DLOG}/*${JOBNAME}* | tail -1`
        if [ ! -z ${LOGFILE_TWO} ]
        then
                LOGFILE=${LOGFILE_TWO}
                NOGO_CHECK_TWO=`cat ${LOGFILE} | grep "NO GO"`
        else
                NOGO_CHECK_TWO=1
        fi

        if [ ! -z ${NOGO_CHECK_TWO} ]
        then
                echo "We have a NO GO/LOG NOT FOUND for ${JOBNAME}. Run cancelled."
                JOBEND
        fi
fi

********* Cash flow code commented. No input file.**********

PATTERNLINE=`cat ${LOGFILE} | grep -m1 EST_FSEGPATTERN_CSF`
PATTERNFILE=`echo ${PATTERNLINE} | cut -d":" -f2 | tr -d " "`

echo "Cashflow pattern file: ${PATTERNFILE}"

DLCUMGTAARLINE=`cat ${LOGFILE} | grep -F -m1 EST_DLCUMGTAAR.`
DLCUMGTAARFILE=`echo ${DLCUMGTAARLINE} | cut -d":" -f2 | tr -d " "`

if [ ${JOBNAME} = ESPD3620 ]
then
        cut -d'~' -f1-51 ${DLCUMGTAARLINE} > ${DFILT}/DLCUMGTAARFILE_DATA.dat
        DLCUMGTAARFILE=`echo ${DFILT}/DLCUMGTAARFILE_DATA.dat`
fi

if [ -s ${PATTERNFILE} ]
then

        PATCATEGORY="CSF  "

        NSTEP=${NJOB}_105
        # BCP in BTRAV..TPATTERNS
        #------------------------------------------------------------------------------
        LIBEL="BCP in BTRAV..TPATTERNS"
        BCP_WAY="IN"; BCP_VER="";
        BCP_TRUNCATE="YES"
        BCP_I=${PATTERNFILE}
        BCP_TABLE="BTRAV..TPATTERNS"
        BCP

        NSTEP=${NJOB}_110
        # BCP in BTRAV..DLCUMGTAAR_IBNR_FUTCLAIMS
        #------------------------------------------------------------------------------
        LIBEL="BCP in BTRAV..DLCUMGTAAR_IBNR_FUTCLAIMS"
        BCP_WAY="IN"; BCP_VER="";
        BCP_TRUNCATE="YES"
        BCP_I=${DLCUMGTAARFILE}
        BCP_TABLE="BTRAV..TDLCUMGTAAR_IBNR_FUTCLAIMS"
        BCP

        NSTEP=${NJOB}_115
        # Begin isql
        #---------------------------------------------------------------
        LIBEL="Calculate amount remaining to pay"
        ISQL_BASE="BTRAV"
        ISQL_QRY="execute PsRMNTP_01 ${QUARTER}, ${PATCATEGORY}"
        ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
        #ISQL

        LIBEL='BCP out for CASHFLOW'
        BCP_WAY="OUT"; BCP_VER="+"
        BCP_O=${DFILT}/${NSTEP}_${IB}_CASHFLOW.dat
        BCP_QRY="execute BTRAV..PsRMNTP_01 ${QUARTER}, ${PATCATEGORY}"
        BCP

fi

'

#PATTERNLINE=`cat ${LOGFILE} | grep -m1 EST_FSEGPATTERN_DSC`
#PATTERNFILE=`echo ${PATTERNLINE} | cut -d":" -f2 | tr -d " "`

PATTERNFILE=`echo ${DFILT}/T_ESPD0060_FSEGPATTERN_DSC.dat`

echo "Discount pattern file: ${PATTERNFILE}"

#CURLINE=`cat ${LOGFILE} | grep -m1 EST_FCURSII`
#CURFILE=`echo ${CURLINE}| cut -d":" -f2 | tr -d " "`

CURFILE=`echo ${DFILT}/T_ESPT0000_FCURSII.dat`

echo "Currency file: ${CURFILE}"

#CUMFILE=`ls -rt ${DFILT}/*_70_*_SORT_GTSII_CSF.dat | tail -1`

CUMFILE=`echo ${DFILT}/T_ESPD3700_ESPD3703POC_070_SORT_GTSII_CSF.dat`

: '

if [ ${JOBNAME} = ESPD3620 ]
then
        cut -d'~' -f1-123 ${CUMFILE} > ${DFILT}/CUMILATIVE_DATA.dat
        CUMFILE=`echo ${DFILT}/CUMILATIVE_DATA.dat`
fi

'

echo "Cumulative file: ${CUMFILE}"

if [ ! -s ${CUMFILE} ]
then
        echo "Cumulative file is not available."
        echo "Procedure for ESTC1057 won't be executed."
fi

if [ -s ${CUMFILE} ]
then

        NSTEP=${NJOB}_205
        # BCP in BTRAV..TPATTERNS
        #------------------------------------------------------------------------------
        LIBEL="BCP in BTRAV..TPATTERNS"
        BCP_WAY="IN"; BCP_VER="";
        BCP_TRUNCATE="YES"
        BCP_I=${PATTERNFILE}
        BCP_TABLE="BTRAV..TPATTERNS"
        BCP

        NSTEP=${NJOB}_210
        # BCP in BTRAV..TCURSII
        #------------------------------------------------------------------------------
        LIBEL="BCP in BTRAV..TCURSII"
        BCP_WAY="IN"; BCP_VER="";
        BCP_TRUNCATE="YES"
        BCP_I=${CURFILE}
        BCP_TABLE="BTRAV..TCURSII"
        BCP

        NSTEP=${NJOB}_215
        # BCP in BTRAV..TGTSII_CUMUL
        #------------------------------------------------------------------------------
        LIBEL="BCP in BTRAV..TGTSII_CUMUL"
        BCP_WAY="IN"; BCP_VER="";
        BCP_TRUNCATE="YES"
        BCP_I=${CUMFILE}
        BCP_TABLE="BTRAV..TGTSII_CUMUL"
        BCP

        NSTEP=${NJOB}_220
        # Begin isql
        #---------------------------------------------------------------
        LIBEL="Calculation of expected amount"
        ISQL_BASE="BTRAV"
        ISQL_QRY="execute PsCalcExpAmt_01"
        ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
        #ISQL

        LIBEL='BCP out for CUMULATIVE'
        BCP_WAY="OUT"; BCP_VER="+"
        BCP_O=${DFILT}/${NSTEP}_${IB}_CUMULATIVE.dat
        BCP_QRY="execute BTRAV..PsCalcExpAmt_01"
        BCP

fi


#PATTERNLINE=`cat ${LOGFILE} | grep -m1 EST_FSEGPATTERN_ICR`
#PATTERNFILE=`echo ${PATTERNLINE} | cut -d":" -f2 | tr -d " "`

PATTERNFILE=`echo ${DFILT}/T_ESPD0060_FSEGPATTERN_ICR.dat`

echo "ICR pattern file: ${PATTERNFILE}"

#IBNRLINE=`cat ${LOGFILE} | grep -m1 EST_DLCUMGTAAR_IBNR_FUTCLAIMS`
#IBNRFILE=`echo ${IBNRLINE} | cut -d":" -f2 | tr -d " "`

IBNRFILE=`echo ${DFILT}/T_ESPD3700_DLCUMGTAAR_IBNR_FUTCLAIMS.dat`

#echo ${IBNRFILE}

: '

if [ ${JOBNAME} = ESPD3620 ]
then
        cut -d'~' -f1-51 ${IBNRFILE} > ${DFILT}/IBNR_DATA.dat
        IBNRFILE=`echo ${DFILT}/IBNR_DATA.dat`
fi

'

echo "IBNR file: ${IBNRFILE}"

if [ ! -s ${PATTERNFILE} ]
then
        echo "ICR Pattern file is not available."
        echo "Procedure for ESTC1056 won't be executed."
fi

if [ -s ${PATTERNFILE} ]
then

        PATCATEGORY="ICR  "

        NSTEP=${NJOB}_305
        # BCP in BTRAV..TPATTERNS
        #------------------------------------------------------------------------------
        LIBEL="BCP in BTRAV..TPATTERNS"
        BCP_WAY="IN"; BCP_VER="";
        BCP_TRUNCATE="YES"
        BCP_I=${PATTERNFILE}
        BCP_TABLE="BTRAV..TPATTERNS"
        BCP

        NSTEP=${NJOB}_310
        # BCP in BTRAV..DLCUMGTAAR_IBNR_FUTCLAIMS
        #------------------------------------------------------------------------------
        LIBEL="BCP in BTRAV..DLCUMGTAAR_IBNR_FUTCLAIMS"
        BCP_WAY="IN"; BCP_VER="";
        BCP_TRUNCATE="YES"
        BCP_I=${IBNRFILE}
        BCP_TABLE="BTRAV..TDLCUMGTAAR_IBNR_FUTCLAIMS"
        BCP

        NSTEP=${NJOB}_315
        # Begin isql
        #---------------------------------------------------------------
        LIBEL="Calculate amount remaining to pay"
        ISQL_BASE="BTRAV"
        ISQL_QRY="execute PsRMNTP_01 ${QUARTER}, ${PATCATEGORY}"
        ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
        #ISQL

        LIBEL='BCP out for ICR'
        BCP_WAY="OUT"; BCP_VER="+"
        BCP_O=${DFILT}/${NSTEP}_${IB}_ICR.dat
        BCP_QRY="execute BTRAV..PsRMNTP_01 ${QUARTER}, ${PATCATEGORY}"
        BCP

fi

JOBEND

