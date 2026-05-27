#!/bin/ksh
#==================================================================================
# nom de l'application          : ESTIMATIONS 
# auteur                        : Mr JYP
#-----------------------------------------------------------------------------
#[001]  19/02/2026  Mr JYP        :US 8620 SERQS POS - no more cash flow on estimates IFRS4

PARM_DATE1=$2

# Call generic functions
. ${DUTI}/fctgen.cmd

CHAININIT CNLD0030 $DENV/CNLD0030.env

. $DFILP/${ENV_PREFIX}_ESFJ0000_PARM_I4I.dat

if [ "$PARM_DATE1" != "" ]
then
        PARM_ICLODAT_D=$PARM_DATE1
fi



if [ "${PARM_ICLODAT_D}" != "" ]
then
        echo "OK: run with PARM_ICLODAT_D=$PARM_ICLODAT_D "  >> $FLOG
        echo "OK: run with PARM_ICLODAT_D=$PARM_ICLODAT_D "  
else
        echo "ERROR: could NOT run with PARM_ICLODAT_D=( $PARM_ICLODAT_D ) PARM_COMMIT=$PARM_COMMIT "  >> $FLOG
        echo "ERROR: could NOT run with PARM_ICLODAT_D=( $PARM_ICLODAT_D ) PARM_COMMIT=$PARM_COMMIT "  
        exit 11
fi


# Initialization of the Job
JOBINIT

echo "Starting  " >> $FLOG
date >> $FLOG

export TYPEINV="INV"

EST_FTECLEDA_CUR="${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_CUR_I4I_INV_${PARM_ICLODAT_D}.dat"
EST_FTECLEDA_MVT_ALL_SITE="${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_MVT_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat"
EST_FTECLEDA_MTH="${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_MTH_I4I_INV_${PARM_ICLODAT_D}.dat" 
EST_FTECLEDA_REP="${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_REP_I4I_INV_${PARM_ICLODAT_D}.dat" 
EST_FTECLEDA_MULTISITE="${DFILP}/${ENV_PREFIX}_ESID8700_FTECLEDA_ALL_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat"
export EST_SUBTRS_TXT="${DFILP}/${ENV_PREFIX}_ESCJ0060_FSUBTRS_TXT.dat"
export EST_SUBTRSESBPROP_TXT="${DFILP}/${ENV_PREFIX}_ESCJ0060_SUBTRSESBPROP_TXT_${TYPEINV}_${PARM_ICLODAT_D}.dat"

echo "EST_FTECLEDA_CUR         = $EST_FTECLEDA_CUR          "
echo "EST_FTECLEDA_MVT_ALL_SITE= $EST_FTECLEDA_MVT_ALL_SITE "
echo "EST_FTECLEDA_MTH         = $EST_FTECLEDA_MTH          "
echo "EST_FTECLEDA_REP         = $EST_FTECLEDA_REP          "
echo "EST_FTECLEDA_MULTISITE   = $EST_FTECLEDA_MULTISITE    "
echo "EST_SUBTRS_TXT           = $EST_SUBTRS_TXT "
echo "EST_SUBTRSESBPROP_TXT    = $EST_SUBTRSESBPROP_TXT "

if [ ! -f "$EST_FTECLEDA_CUR" ]
then
        echo "ERROR: could NOT read $EST_FTECLEDA_CUR "   
        exit 22
fi
if [ ! -f "$EST_FTECLEDA_MVT_ALL_SITE" ]
then
        echo "ERROR: could NOT read $EST_FTECLEDA_MVT_ALL_SITE "   
        exit 23
fi
if [ ! -f "$EST_FTECLEDA_MTH" ]
then
        echo "ERROR: could NOT read $EST_FTECLEDA_MTH "   
        exit 24
fi
if [ ! -f "$EST_FTECLEDA_REP" ]
then
        echo "ERROR: could NOT read $EST_FTECLEDA_REP "   
        exit 25
fi

if [ -f "$EST_FTECLEDA_MULTISITE" ]
then
        echo "ERROR: file already exists, could NOT overwrite $EST_FTECLEDA_MULTISITE  "   
        exit 26
fi

if [ ! -f "$EST_SUBTRS_TXT" ]
then
        echo "ERROR: could NOT read $EST_SUBTRS_TXT    "   
        exit 27
fi

if [ ! -f "$EST_SUBTRSESBPROP_TXT" ]
then
        echo "ERROR: could NOT read $EST_SUBTRSESBPROP_TXT    "   
        exit 28
fi

NJOB="ESID8702B"
${DCMD}/ESID8702.cmd $EST_FTECLEDA_CUR $EST_FTECLEDA_MVT_ALL_SITE $EST_FTECLEDA_MTH $EST_FTECLEDA_REP $EST_FTECLEDA_MULTISITE 118  2>&1 | ${TEE}
	
	
	

echo "End of script OK status $? " >> $FLOG
echo "End of script OK status $? " 

JOBEND


