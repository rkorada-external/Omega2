#!/bin/ksh
#==================================================================================
# nom de l'application          : ESTIMATIONS 
# nom du script SHELL           : GRANULARITY_I4I.cmd
# revision                      : $Revision: 1.0 $
# date de creation              : 08/12/2021
# auteur                        : JYP
#-----------------------------------------------------------------------------
#set -x


#NORME2=$2
NORME2=I17G

# Call generic functions
. ${DUTI}/fctgen.cmd


CHAININIT CNLD0030 $DENV/CNLD0030.env

NJOB=${ENV_PREFIX}_CNLD0030_CNLD0031

# Initialization of the Job
JOBINIT

echo "Starting $0 $1 $FLOG " 
echo "Starting $0 $1" >> $FLOG
date >> $FLOG

today=`date '+%Y%m%d' `


export EST_CURGTR="${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat"
export EST_CURGTA="${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat"
export ESF_FCTRI17PRD_NEW="${DFILP}/${ENV_PREFIX}_ESFD3940_${NORME2}_GRN_ALL_INI_FCTRI17PRD.dat"



# for dev only
if [ "${LOGNAME}" = "u007314" ]
then
    site="ubxx"
    echo "WARNING : run with forced user $site" >> $FLOG
else
    site=$LOGNAME
    echo "run with site = $site" >> $FLOG
fi




#====== product code prefix by norme 

case "${NORME2}" in
        "I17G") LETTER="G";;
        "I17L") LETTER="L";;
        "I17P") LETTER="P";;
        *) echo "wrong value for NORME: ${NORME2} " >> $FLOG  
       STEPEND 10;;
esac


case "${site}" in
        "ubas") PREFIX="~AS$LETTER" ;;
        "ubeu") PREFIX="~EU$LETTER" ;;
        "ubam") PREFIX="~AM$LETTER" ;;
        *) echo  "wrong value for site : ${site} " >> $FLOG
       STEPEND 20;;
esac


echo "running with PREFIX=$PREFIX " >> $FLOG

#====== check product code  file
if [ ! -f $ESF_FCTRI17PRD_NEW ]
then
echo "ERROR ESF_FCTRI17PRD_NEW=$ESF_FCTRI17PRD_NEW is missing " >> $FLOG
exit 11
fi



echo "============================== " >> $FLOG
if [ -f $EST_CURGTR ]
then

wc -l $EST_CURGTR >> $FLOG
nbr=`grep -v "$PREFIX" $EST_CURGTR | wc -l `
nbr2=`grep "$PREFIX" $EST_CURGTR | wc -l `
echo "BEFORE: $EST_CURGTR  => $nbr prod_codes missing $nbr2 codes ok " >> $FLOG
gzip -c ${EST_CURGTR} > ${DARCH}/${ENV_PREFIX}_ESIX7000_CURGTR.dat_${today}_$$.gz

NJOB="1ESFD3818_TTECLEDR_GTR"
${DCMD}/ESFD3818.cmd ${EST_CURGTR} ${ESF_FCTRI17PRD_NEW}

wc -l $EST_CURGTR >> $FLOG
nbr=`grep -v "$PREFIX" $EST_CURGTR | wc -l `
nbr2=`grep "$PREFIX" $EST_CURGTR | wc -l `
echo "AFTER: $EST_CURGTR  => $nbr prod_codes missing $nbr2 codes ok" >> $FLOG

else
echo "WARNING EST_CURGTR=$EST_CURGTR missing or empty is NOT updated !!!!!" >> $FLOG
fi
echo "============================== " >> $FLOG




echo "============================== " >> $FLOG
if [ -f $EST_CURGTA ]
then

wc -l $EST_CURGTA >> $FLOG
nbr=`grep -v "$PREFIX" $EST_CURGTA | wc -l `
nbr2=`grep "$PREFIX" $EST_CURGTA | wc -l `
echo "BEFORE: $EST_CURGTA  => $nbr prod_codes missing $nbr2 codes ok " >> $FLOG
gzip -c ${EST_CURGTA} > ${DARCH}/${ENV_PREFIX}_ESIX7000_CURGTA.dat_${today}_$$.gz



EST_BASE=`basename "${EST_CURGTA%.*}"`
EST_OUT="$EST_CURGTA"

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ............INPUT ................................................."
ECHO_LOG "#===> ESF_FCTRI17PRD_NEW  .................: ${ESF_FCTRI17PRD_NEW}"
ECHO_LOG "#===> EST_OUT  ............................: ${EST_OUT}"
ECHO_LOG "#===> EST_BASE  ............................: ${EST_BASE}"
ECHO_LOG "#===> ............OUTPUT ................................................."
ECHO_LOG "#===> EST_OUT .............................: ${EST_OUT}"

 
NSTEP=${NJOB}_10
#------------------------------------------------------------------------------------
LIBEL="ASSUMED : split empty prod_code ${EST_OUT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_OUT} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ASSUMED_EMPTY.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_OTHERS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF           8:1 - 8:,
        END_NT           9:1 - 9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
		TRNCOD_CF1		6:1 - 6:1,
		RETCTR_NF       24:1 - 24:,		
		I17PRDCOD_CT    65:1 - 65:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/CONDITION POST_CUR_ASSUMED ( I17PRDCOD_CT = "" AND (TRNCOD_CF1 = "1" OR TRNCOD_CF1 = "3") ) 
/OUTFILE ${SORT_O}
/INCLUDE POST_CUR_ASSUMED
/OUTFILE ${SORT_O2}
/OMIT POST_CUR_ASSUMED

exit
EOF
SORT



#${EST_OUT}
NSTEP=${NJOB}_20
#------------------------------------------------------------------------------------
LIBEL="ASSUMED join ESF_FCTRI17PRD_NEW to ${EST_OUT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_${EST_BASE}_ASSUMED_EMPTY.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ASSUMED_PRDCOD.dat 2000 1"

INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF              8:1 - 8:,
        END_NT              9:1 - 9:,
        SEC_NF              10:1 - 10:,
        UWY_NF              11:1 - 11:,
        UW_NT               12:1 - 12:,
		TRNCOD_CF1			6:1 - 6:1,
		RETCTR_NF           24:1 - 24:,
        S_HEAD              1:1 - 64:,
        S_TAIL              66:1 - 71:,
        PRD_CTR_NF           1:1 - 1:,
        PRD_END_NT           2:1 - 2:,
        PRD_SEC_NF           3:1 - 3:,
        PRD_UWY_NF           4:1 - 4:,
        PRD_UW_NT            5:1 - 5:,		
        I17PRDCOD_CT         8:1 - 8:
/JOINKEYS
        CTR_NF  ,
        END_NT  ,
        SEC_NF  ,
        UWY_NF  ,
        UW_NT  
/INFILE ${ESF_FCTRI17PRD_NEW} 2000 1 "~"
/JOINKEYS
        PRD_CTR_NF  ,
        PRD_END_NT  ,
        PRD_SEC_NF  ,
        PRD_UWY_NF  ,
        PRD_UW_NT   
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside : S_HEAD, rightside : I17PRDCOD_CT , leftside : S_TAIL
exit
EOF
SORT


NSTEP=${NJOB}_30
#------------------------------------------------------------------------------------
LIBEL="RETRO P NP : split empty prod_code with others input ${EST_OUT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_${EST_BASE}_OTHERS.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_RETRO_EMPTY.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_OTHERS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF           8:1 - 8:,
        END_NT           9:1 - 9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
		TRNCOD_CF1		6:1 - 6:1,
		RETCTR_NF       24:1 - 24:,			
		I17PRDCOD_CT    65:1 - 65:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/CONDITION POST_CUR_RETRO ( I17PRDCOD_CT = "" AND RETCTR_NF != "" AND (TRNCOD_CF1 = "2" OR TRNCOD_CF1 = "4") ) 
/OUTFILE ${SORT_O}
/INCLUDE POST_CUR_RETRO
/OUTFILE ${SORT_O2}
/OMIT POST_CUR_RETRO

exit
EOF
SORT


#${EST_OUT}
NSTEP=${NJOB}_40
#------------------------------------------------------------------------------------
LIBEL="RETRO join ESF_FCTRI17PRD_NEW to ${EST_OUT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_${EST_BASE}_RETRO_EMPTY.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_RETRO_PRDCOD.dat 2000 1"

INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS RETCTR_NF           24:1 - 24:,
        RETEND_NT           25:1 - 25:,
        RETSEC_NF           26:1 - 26:,
        RETRTY_NF           27:1 - 27:,
        RETUW_NT            28:1 - 28:,
        S_HEAD              1:1 - 64:,
        S_TAIL              66:1 - 71:,
        PRD_CTR_NF           1:1 - 1:,
        PRD_END_NT           2:1 - 2:,
        PRD_SEC_NF           3:1 - 3:,
        PRD_UWY_NF           4:1 - 4:,
        PRD_UW_NT            5:1 - 5:,		
        I17PRDCOD_CT         8:1 - 8:
/JOINKEYS
        RETCTR_NF ,
        RETEND_NT ,
        RETSEC_NF ,
        RETRTY_NF ,
        RETUW_NT  
/INFILE ${ESF_FCTRI17PRD_NEW} 2000 1 "~"
/JOINKEYS
        PRD_CTR_NF  ,
        PRD_END_NT  ,
        PRD_SEC_NF  ,
        PRD_UWY_NF  ,
        PRD_UW_NT   
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside : S_HEAD, rightside : I17PRDCOD_CT , leftside : S_TAIL
exit
EOF
SORT



NSTEP=${NJOB}_50
#------------------------------------------------------------------------------------
LIBEL="merge files to ouput ${EST_OUT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_${EST_BASE}_ASSUMED_PRDCOD.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_40_${IB}_${EST_BASE}_RETRO_PRDCOD.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_30_${IB}_${EST_BASE}_OTHERS.dat 2000 1"
SORT_O="${EST_OUT} 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF           8:1 - 8:,
        END_NT           9:1 - 9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT

/OUTFILE ${SORT_O} OVERWRITE

exit
EOF
SORT

wc -l $EST_CURGTA >> $FLOG
nbr=`grep -v "$PREFIX" $EST_CURGTA | wc -l `
nbr2=`grep "$PREFIX" $EST_CURGTA | wc -l `
echo "AFTER: $EST_CURGTA  => $nbr prod_codes missing $nbr2 codes ok" >> $FLOG

else
echo "WARNING EST_CURGTA=$EST_CURGTA missing or empty is NOT updated !!!!!" >> $FLOG
fi
echo "============================== " >> $FLOG




echo "END status= $? " >> $FLOG

#JOBEND


