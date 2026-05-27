#!/bin/ksh
#==================================================================================
# nom de l'application          : ESTIMATIONS 
# nom du script SHELL           : GRANULARITY_EBS.cmd
# revision                      : $Revision: 1.0 $
# date de creation              : 08/12/2021
# auteur                        : JYP
#-----------------------------------------------------------------------------
#set -x


NORME1=$2
TYPEINV=$3
PARM_ICLODAT_D=$4


# if CNLD0030 
#NORME1=EBS 
#TYPEINV=POS
#PARM_ICLODAT_D=20211231

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


# CNV
export EPO_DLREJGTAASIISO="${DFILP}/${ENV_PREFIX}_ESPD2900_DLREJGTAA_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat"
export EPO_DLREJGTARSIISO="${DFILP}/${ENV_PREFIX}_ESPD2900_DLREJGTAR_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat"
export  EPO_DLREJGTRSIISO="${DFILP}/${ENV_PREFIX}_ESPD2900_DLREJGTR_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat"

#UAT
#export EPO_DLREJGTAASIISO="${DFILP}/${ENV_PREFIX}_ESPD2900_DLREJGTAASIISO.dat"
#export EPO_DLREJGTARSIISO="${DFILP}/${ENV_PREFIX}_ESPD2900_DLREJGTARSIISO.dat"
#export  EPO_DLREJGTRSIISO="${DFILP}/${ENV_PREFIX}_ESPD2900_DLREJGTRSIISO.dat"


export ESF_FCTRI17PRD_NEW="${DFILP}/${ENV_PREFIX}_ESFD3940_${NORME2}_GRN_ALL_INI_FCTRI17PRD.dat"


# for dev only
if [ "${LOGNAME}" = "u007314" ]
then
    site="ubeu"
    echo "WARNING run with FORCED site = $site TYPEINV=$TYPEINV PARM_ICLODAT_D=$PARM_ICLODAT_D NORME1=$NORME1 NORME2=$NORME2 " >> $FLOG
else
    site=$LOGNAME
    echo "run with site = $site TYPEINV=$TYPEINV PARM_ICLODAT_D=$PARM_ICLODAT_D NORME1=$NORME1 NORME2=$NORME2 " >> $FLOG
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
if [ -f $EPO_DLREJGTARSIISO ]
then

nbr=`grep -v "$PREFIX" $EPO_DLREJGTARSIISO | wc -l `
nbr2=`grep "$PREFIX" $EPO_DLREJGTARSIISO | wc -l `
echo "BEFORE: $EPO_DLREJGTARSIISO  => $nbr prod_codes missing $nbr2 codes ok " >> $FLOG
wc -l $EPO_DLREJGTARSIISO >> $FLOG
gzip -c ${EPO_DLREJGTARSIISO} > ${DARCH}/${ENV_PREFIX}_ESPD2900_DLREJGTAR_EBS_${TYPEINV}_${PARM_ICLODAT_D}_${today}_$$.gz

NJOB="ESFD3818_TTECLEDR_10"
${DCMD}/ESFD3818.cmd ${EPO_DLREJGTARSIISO} ${ESF_FCTRI17PRD_NEW}

nbr=`grep -v "$PREFIX" $EPO_DLREJGTARSIISO | wc -l `
nbr2=`grep "$PREFIX" $EPO_DLREJGTARSIISO | wc -l `
echo "AFTER: $EPO_DLREJGTARSIISO  => $nbr prod_codes missing $nbr2 codes ok" >> $FLOG
wc -l $EPO_DLREJGTARSIISO >> $FLOG

else
echo "WARNING EPO_DLREJGTARSIISO=$EPO_DLREJGTARSIISO missing or empty is NOT updated !!!!!" >> $FLOG
fi
echo "============================== " >> $FLOG





echo "============================== " >> $FLOG
if [ -f $EPO_DLREJGTRSIISO ]
then

nbr=`grep -v "$PREFIX" $EPO_DLREJGTRSIISO | wc -l `
nbr2=`grep "$PREFIX" $EPO_DLREJGTRSIISO | wc -l `
echo "BEFORE: $EPO_DLREJGTRSIISO  => $nbr prod_codes missing $nbr2 codes ok " >> $FLOG
wc -l $EPO_DLREJGTRSIISO >> $FLOG
gzip -c ${EPO_DLREJGTRSIISO} > ${DARCH}/${ENV_PREFIX}_ESPD2900_DLREJGTR_EBS_${TYPEINV}_${PARM_ICLODAT_D}_${today}_$$.gz

NJOB="ESFD3818_TTECLEDR_20"
${DCMD}/ESFD3818.cmd ${EPO_DLREJGTRSIISO} ${ESF_FCTRI17PRD_NEW}

nbr=`grep -v "$PREFIX" $EPO_DLREJGTRSIISO | wc -l `
nbr2=`grep "$PREFIX" $EPO_DLREJGTRSIISO | wc -l `
echo "AFTER: $EPO_DLREJGTRSIISO  => $nbr prod_codes missing $nbr2 codes ok" >> $FLOG
wc -l $EPO_DLREJGTRSIISO >> $FLOG

else
echo "WARNING EPO_DLREJGTRSIISO=$EPO_DLREJGTRSIISO missing or empty is NOT updated !!!!!" >> $FLOG
fi
echo "============================== " >> $FLOG








echo "============================== " >> $FLOG
if [ -f $EPO_DLREJGTAASIISO ]
then

nbr=`grep -v "$PREFIX" $EPO_DLREJGTAASIISO | wc -l `
nbr2=`grep "$PREFIX" $EPO_DLREJGTAASIISO | wc -l `
echo "BEFORE: $EPO_DLREJGTAASIISO  => $nbr prod_codes missing $nbr2 codes ok " >> $FLOG
wc -l $EPO_DLREJGTAASIISO >> $FLOG
gzip -c ${EPO_DLREJGTAASIISO} > ${DARCH}/${ENV_PREFIX}_ESPD2900_DLREJGTAA_EBS_${TYPEINV}_${PARM_ICLODAT_D}_${today}_$$.gz



EST_BASE=`basename "${EPO_DLREJGTAASIISO%.*}"`
EST_OUT="$EPO_DLREJGTAASIISO"

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

nbr=`grep -v "$PREFIX" $EPO_DLREJGTAASIISO | wc -l `
nbr2=`grep "$PREFIX" $EPO_DLREJGTAASIISO | wc -l `
echo "AFTER: $EPO_DLREJGTAASIISO  => $nbr prod_codes missing $nbr2 codes ok" >> $FLOG
wc -l $EPO_DLREJGTAASIISO >> $FLOG

else
echo "WARNING EPO_DLREJGTAASIISO=$EPO_DLREJGTAASIISO missing or empty is NOT updated !!!!!" >> $FLOG
fi
echo "============================== " >> $FLOG










echo "END status= $? " >> $FLOG

#JOBEND


