#!/bin/ksh
#==================================================================================
# nom de l'application          : ESTIMATIONS 
# date de creation              : 05/05/2021
# auteur                        : Mr JYP
#-----------------------------------------------------------------------------
# [001] 06/05/2020 JYP: SPIRA 96063 : script to initialize Transition contrats from TRANSITION.dat file
# [002] 17/06/2020 JYP: SPIRA 96063 : SSD filter by site  / EST_SORT_CONDITION
# [003] 20/09/2024 JYP: SPIRA 112188: re-activate TRANSITION, use I17G parm file

PARM_COMMIT=$2
PARM_DATE1=$3

# Call generic functions
. ${DUTI}/fctgen.cmd

CHAININIT CNLD0030 $DENV/CNLD0030.env

. $DFILP/${ENV_PREFIX}_ESFJ0000_PARM_I17G.dat

if [ "$PARM_DATE1" != "" ]
then
        PARM_ICLODAT_D=$PARM_DATE1
fi

if [ "$PARM_COMMIT" != "Y" ]
then
        PARM_COMMIT="N"
fi



if [ "${PARM_ICLODAT_D}" != "" ]
then
        echo "OK: run with PARM_ICLODAT_D=$PARM_ICLODAT_D PARM_COMMIT=$PARM_COMMIT EST_SORT_CONDITION=$EST_SORT_CONDITION "  >> $FLOG
        echo "OK: run with PARM_ICLODAT_D=$PARM_ICLODAT_D PARM_COMMIT=$PARM_COMMIT EST_SORT_CONDITION=$EST_SORT_CONDITION "  
else
        echo "ERROR: could NOT run with PARM_ICLODAT_D=$PARM_ICLODAT_D PARM_COMMIT=$PARM_COMMIT EST_SORT_CONDITION=$EST_SORT_CONDITION "  >> $FLOG
        echo "ERROR: could NOT run with PARM_ICLODAT_D=$PARM_ICLODAT_D PARM_COMMIT=$PARM_COMMIT EST_SORT_CONDITION=$EST_SORT_CONDITION "  
        exit 11
fi



NJOB=TRANSITION_96063

# Initialization of the Job
JOBINIT

#set -x
echo "Starting  " >> $FLOG
date >> $FLOG



#========== check input data
ESF_TRANSITION_DATA="${DFILP}/${ENV_PREFIX}_ESFT0020_I17G_OMG_ALL_TRA_TRANSITION_FILEPOS_${PARM_ICLODAT_D}.dat"
if [ ! -f $ESF_TRANSITION_DATA ]
then
        echo "ERROR: could NOT read ESF_TRANSITION_DATA=$ESF_TRANSITION_DATA "  >> $FLOG
        echo "ERROR: could NOT read ESF_TRANSITION_DATA=$ESF_TRANSITION_DATA "  
        exit 22
fi

NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="Filter TRANSITION file with SSD_CF : ${EST_SORT_CONDITION}  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_TRANSITION_DATA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_TRANSITION_$$.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF          1:1 - 1: EN
/KEYS   SSD_CF
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/OUTFILE ${SORT_O}
exit
EOF
SORT



NSTEP=${NJOB}_10
#----------------------------------------------------------------------------
LIBEL="Generate list of CSUOE from TRANSITION file "
grep "~A~" ${DFILT}/${NJOB}_05_${IB}_TRANSITION_$$.dat  | cut -d"~" -f3-7,10 >  ${DFILT}/${NSTEP}_${IB}_$$_ACC.dat  
grep "~R~" ${DFILT}/${NJOB}_05_${IB}_TRANSITION_$$.dat  | cut -d"~" -f3,5 | sort -u >  ${DFILT}/${NSTEP}_${IB}_$$_RET.dat 
EXECKSH_MODE=P
EXECKSH "wc -l   ${DFILT}/${NSTEP}_${IB}_$$_ACC.dat  ${DFILT}/${NSTEP}_${IB}_$$_RET.dat "


#==================================== ACCEPT : FAC/TRT ================================================================

NSTEP=${NJOB}_20
#----------------------------------------------------------------------------
LIBEL="Generate ACC sql script "


TYP="ACC"
nb=0
nbid=0
id=1
echo "use BEST" >> ${DFILT}/${NJOB}_20_${IB}_$$_${TYP}_${id}.sql
echo "go" >> ${DFILT}/${NJOB}_20_${IB}_$$_${TYP}_${id}.sql 
echo -e "\ngenerating  ${DFILT}/${NJOB}_20_${IB}_$$_${TYP}_${id}.sql   .... \nplease wait near 3mn ..... " >> $FLOG
echo -e "\ngenerating  ${DFILT}/${NJOB}_20_${IB}_$$_${TYP}_${id}.sql   .... \nplease wait near 3mn ..... " 

for line in `cat ${DFILT}/${NJOB}_10_${IB}_$$_${TYP}.dat  `
do

nb=`expr $nb + 1 `
nbid=`expr $nbid + 1 `
ctr=`echo "$line" | cut -d"~" -f1 `
sec=`echo "$line" | cut -d"~" -f2 `
annee=`echo "$line" | cut -d"~" -f3 `
uwnt=`echo "$line" | cut -d"~" -f4 `
endnt=`echo "$line" | cut -d"~" -f5 `
ctrnat=`echo "$line" | cut -d"~" -f6 `

	if [ "$ctrnat" = "F" ]
	then  
		BASE="FAC"
	else
		BASE="TRT"
	fi
  
echo "update B${BASE}..tsecifrs set GRPFIRCLO_D=null,GRPRATEINDEX_CT=null,GRPINIPRO_CF=null,GRPINISTS_CT=null,lstupdusr_cf='INF7',lstupd_d=getdate() where CTR_NF='$ctr' and UWY_NF=$annee and SEC_NF=$sec and uw_nt=$uwnt and END_NT=$endnt " >> ${DFILT}/${NJOB}_20_${IB}_$$_${TYP}_${id}.sql 


if [ $nb -eq 200 ]
then
  echo "go" >> ${DFILT}/${NJOB}_20_${IB}_$$_${TYP}_${id}.sql 
  nb=0
fi

if [ $nbid -eq 5000 ]
then
  echo "go" >> ${DFILT}/${NJOB}_20_${IB}_$$_${TYP}_${id}.sql
  nb=0
  LIBEL="Generate ACC sql script "
  EXECKSH_MODE=P
  EXECKSH "wc -l ${DFILT}/${NJOB}_20_${IB}_$$_${TYP}_${id}.sql" 
  
  	if [ "$PARM_COMMIT" = "Y" ]
    then 
		#Begin isql
		#-----------------------------------------------------------------------------
		LIBEL="execute ACC sql script : ${DFILT}/${NJOB}_20_${IB}_$$_${TYP}_${id}.sql "
		ISQL_BASE="BEST"
		ISQL_QRY="${DFILT}/${NJOB}_20_${IB}_$$_${TYP}_${id}.sql"
		ISQL_O="${DFILT}/${NJOB}_20_${IB}_$$_${TYP}_${id}.log"
		ISQL
    fi

  id=`expr $id + 1 `
  echo "use BEST" >> ${DFILT}/${NJOB}_20_${IB}_$$_${TYP}_${id}.sql
  echo "go" >> ${DFILT}/${NJOB}_20_${IB}_$$_${TYP}_${id}.sql
  nbid=0
  echo -e "\ngenerating  ${DFILT}/${NJOB}_20_${IB}_$$_${TYP}_${id}.sql ....  \nplease wait near 3mn ..... " >> $FLOG
  echo -e "\ngenerating  ${DFILT}/${NJOB}_20_${IB}_$$_${TYP}_${id}.sql ....  \nplease wait near 3mn ..... " 

fi


done

echo "go" >> ${DFILT}/${NJOB}_20_${IB}_$$_${TYP}_${id}.sql 
LIBEL="Generate ACC sql script "
EXECKSH_MODE=P
EXECKSH "wc -l ${DFILT}/${NJOB}_20_${IB}_$$_${TYP}_${id}.sql" 

  	if [ "$PARM_COMMIT" = "Y" ]
    then   
		#Begin isql
		#-----------------------------------------------------------------------------
		LIBEL="execute ACC last sql script : ${DFILT}/${NJOB}_20_${IB}_$$_${TYP}_${id}.sql "
		ISQL_BASE="BEST"
		ISQL_QRY="${DFILT}/${NJOB}_20_${IB}_$$_${TYP}_${id}.sql"
		ISQL_O="${DFILT}/${NJOB}_20_${IB}_$$_${TYP}_${id}.log"
		ISQL
    fi

#==================================== RETRO  ================================================================

NSTEP=${NJOB}_40
#----------------------------------------------------------------------------
LIBEL="Generate RET sql script "

TYP="RET"
nb=0
nbid=0
id=1
echo "use BEST" >> ${DFILT}/${NSTEP}_${IB}_$$_${TYP}_${id}.sql
echo "go" >> ${DFILT}/${NSTEP}_${IB}_$$_${TYP}_${id}.sql 
echo -e "\ngenerating  ${DFILT}/${NSTEP}_${IB}_$$_${TYP}_${id}.sql   .... \nplease wait near 3mn ..... " >> $FLOG
echo -e "\ngenerating  ${DFILT}/${NSTEP}_${IB}_$$_${TYP}_${id}.sql   .... \nplease wait near 3mn ..... " 

for line in `cat ${DFILT}/${NJOB}_10_${IB}_$$_${TYP}.dat  `
do

nb=`expr $nb + 1 `
nbid=`expr $nbid + 1 `
ctr=`echo "$line" | cut -d"~" -f1 `
annee=`echo "$line" | cut -d"~" -f2 `


echo "update bret..tretifrs set GRPFSTCLO_D=null,GRPRATEINDEX_CT=null,GRPINISTS_CT=0,lstupdusr_cf='INF7',lstupd_d=getdate() where retctr_nf='$ctr' and rty_nf= $annee " >> ${DFILT}/${NSTEP}_${IB}_$$_${TYP}_${id}.sql


if [ $nb -eq 200 ]
then
  echo "go" >> ${DFILT}/${NSTEP}_${IB}_$$_${TYP}_${id}.sql 
  nb=0
fi

if [ $nbid -eq 5000 ]
then
  echo "go" >> ${DFILT}/${NSTEP}_${IB}_$$_${TYP}_${id}.sql
  nb=0
  LIBEL="Generate RET sql script "
  EXECKSH_MODE=P
  EXECKSH "wc -l ${DFILT}/${NSTEP}_${IB}_$$_${TYP}_${id}.sql" 

  	if [ "$PARM_COMMIT" = "Y" ]
    then 
		#Begin isql
		#-----------------------------------------------------------------------------
		LIBEL="execute RET sql script : ${DFILT}/${NJOB}_40_${IB}_$$_${TYP}_${id}.sql "
		ISQL_BASE="BEST"
		ISQL_QRY="${DFILT}/${NJOB}_40_${IB}_$$_${TYP}_${id}.sql"
		ISQL_O="${DFILT}/${NJOB}_40_${IB}_$$_${TYP}_${id}.log"
		ISQL
    fi
	
  id=`expr $id + 1 `
  echo "use BEST" >> ${DFILT}/${NSTEP}_${IB}_$$_${TYP}_${id}.sql
  echo "go" >> ${DFILT}/${NSTEP}_${IB}_$$_${TYP}_${id}.sql
  nbid=0
  echo -e "\ngenerating  ${DFILT}/${NSTEP}_${IB}_$$_${TYP}_${id}.sql ....  \nplease wait near 3mn ..... " >> $FLOG
  echo -e "\ngenerating  ${DFILT}/${NSTEP}_${IB}_$$_${TYP}_${id}.sql ....  \nplease wait near 3mn ..... " 

fi


done

echo "go" >> ${DFILT}/${NSTEP}_${IB}_$$_${TYP}_${id}.sql 
LIBEL="Generate RET sql script "
EXECKSH_MODE=P
EXECKSH "wc -l ${DFILT}/${NSTEP}_${IB}_$$_${TYP}_${id}.sql" 

  	if [ "$PARM_COMMIT" = "Y" ]
    then 
		#Begin isql
		#-----------------------------------------------------------------------------
		LIBEL="execute RET last sql script : ${DFILT}/${NJOB}_40_${IB}_$$_${TYP}_${id}.sql "
		ISQL_BASE="BEST"
		ISQL_QRY="${DFILT}/${NJOB}_40_${IB}_$$_${TYP}_${id}.sql"
		ISQL_O="${DFILT}/${NJOB}_40_${IB}_$$_${TYP}_${id}.log"		
		ISQL
    fi
	
	

echo "End of script OK status $? " >> $FLOG
echo "End of script OK status $? " 

JOBEND


