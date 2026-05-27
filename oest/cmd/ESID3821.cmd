#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 granularity on delta posting
# nom du script SHELL           : ESFD3821.cmd
# date de creation              : 20/01/2022
# auteur                        : JYP - PERSEE
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  : IFRS17 Granularity appplied to delta posting
#
#-----------------------------------------------------------------------------
# historiques des modifications
#=================================================================================================
#[001] 20/01/2022 JYP : Spira 96729 : Creation , granularity and deltaposting 
#[002] 15/02/2022 JYP : Spira 96729 : change date in QTD file 
#[003] 17/02/2022 JYP : Spira 96729 : specific rule for open/cancel
#[004] 22/04/2022 JYP : Spira 96729 : use PARM_CLODAT_D
#[005] 20/05/2022 DAD : Spira 104528 : forced CLODAT_DAY = 1
#[006] 10/02/2023 JYP : Spira 108760: override empty product code
#===============================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> NORME......................: ${NORME}"
ECHO_LOG "#===> NORME_CF...................: ${NORME_CF}"
ECHO_LOG "#===> IDF_CT ....................: ${IDF_CT} "
ECHO_LOG "#===> CONTEXT_CT ................: ${CONTEXT_CT} "
ECHO_LOG "#===> param_Request_id...........: ${param_Request_id}  "
ECHO_LOG "#===> param_Context_id...........: ${param_Context_id}  "
ECHO_LOG "#===> PARM_CRE_D.................: $PARM_CRE_D"
ECHO_LOG "#===> PARM_CLODAT_D .............: $PARM_CLODAT_D"
ECHO_LOG "#===>     -------- input  ---------"
ECHO_LOG "#===> ESF_FCTRI17PRD ..............: $ESF_FCTRI17PRD "
ECHO_LOG "#===> ESF_FCTRI17PRD_OVR ..........: $ESF_FCTRI17PRD_OVR "
ECHO_LOG "#===> EST_FTECLEDA_MVT_PREV .......: $EST_FTECLEDA_MVT_PREV "
ECHO_LOG "#===> EST_FTECLEDA_MVT       ......: $EST_FTECLEDA_MVT "
ECHO_LOG "#===>     -------- output  ---------"
ECHO_LOG "#===> EST_FTECLEDA_MVT_QTD ........: $EST_FTECLEDA_MVT_QTD "
ECHO_LOG "#===> EST_FTECLEDA_MVT_QTD_TMP ....: $EST_FTECLEDA_MVT_QTD_TMP "
ECHO_LOG "#===> EST_FTECLEDA_MVT_OPN_CAN ....: $EST_FTECLEDA_MVT_OPN_CAN "
ECHO_LOG "#===> EST_FTECLEDA_MVT_POSTING ....: $EST_FTECLEDA_MVT_POSTING "
ECHO_LOG "#========================================================================="





NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="INV INIT POSTING file : touch EST_FTECLEDA_MVT_POSTING=$EST_FTECLEDA_MVT_POSTING   "

if [ ! -f $EST_FTECLEDA_MVT_POSTING  ] 
then
 if [ "$TYPEINV" = "INV" ]
 then
	EXECKSH_MODE=P
	EXECKSH "touch $EST_FTECLEDA_MVT_POSTING  "
	ls -ltr $EST_FTECLEDA_MVT_POSTING  
	wc -l $EST_FTECLEDA_MVT_POSTING  
 fi
fi

NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="POS INIT POSTING file : copy POSI input EST_FTECLEDA_MVT_PREV=$EST_FTECLEDA_MVT_PREV   "

 if [ "$TYPEINV" = "POS" ] || [ "$TYPEINV" = "POC" ]
 then
	if [ -s $EST_FTECLEDA_MVT_POSTING ]
	then
		EXECKSH_MODE=P
		EXECKSH "wc -l $EST_FTECLEDA_MVT_POSTING  "
		ECHO_LOG "Initialization not required, POSING file is not empty "
	else   
	
		if [ ! -f $EST_FTECLEDA_MVT_PREV  ] 
		then
			EXECKSH_MODE=P
			EXECKSH "echo ERROR INVI file missing EST_FTECLEDA_MVT_PREV=$EST_FTECLEDA_MVT_PREV "  
			ECHO_LOG "INVI file missing EST_FTECLEDA_MVT_PREV=$EST_FTECLEDA_MVT_PREV "  
			STEPEND 20
		else
			EXECKSH_MODE=P
			EXECKSH "cp $EST_FTECLEDA_MVT_PREV $EST_FTECLEDA_MVT_POSTING "  
			wc -l $EST_FTECLEDA_MVT_POSTING	 
		fi
	fi
 
 fi



export CLODAT_YEAR=`echo ${PARM_CLODAT_D} | cut -c1-4`
export CLODAT_MTH=`echo ${PARM_CLODAT_D} | cut -c5-6`
#[005]
# export CLODAT_DAY=`echo ${PARM_CLODAT_D} | cut -c7-8`
export CLODAT_DAY='1'


NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="PREPARATION : INIT dates for Quaterly QTD file "
#-----------------------------------------------------------------------------
AWK_I=${EST_FTECLEDA_MVT_POSTING}
AWK_O="${DFILT}/${NSTEP}_${IB}_FCTRI17PRD_UPD_${IDF_CT}.dat"
AWK_PARAM=" -v an=${CLODAT_YEAR} -v mois=${CLODAT_MTH} -v day=${CLODAT_DAY} "
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
{
 \$3=an;
 \$4=mois;
 \$5=day;
 print \$0;
}
exit
EOF
# \$102="";   #remove SAP ID : Sir TD asked to cancel, to be done on DELTA chain by CAP 
AWK




NSTEP=${NJOB}_35
#-----------------------------------------------------------------------------
LIBEL="PREPARATION : split openning/cancelation  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_30_${IB}_FCTRI17PRD_UPD_${IDF_CT}.dat 2000 1"
SORT_O="${EST_FTECLEDA_MVT_OPN_CAN} 2000 1"
SORT_O2="${EST_FTECLEDA_MVT_QTD_TMP} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF          8:1 -  8:,
        END_NT          9:1 -  9:EN,
        SEC_NF         10:1 - 10:EN,
        UWY_NF         11:1 - 11:,
        UW_NT          12:1 - 12:EN,
		FLAG_OA        114:1 -  114:
/CONDITION COND_OA       (FLAG_OA = "O" OR FLAG_OA = "A") 
/CONDITION COND_NOT_OA   (FLAG_OA != "O" AND FLAG_OA != "A") 
/OUTFILE ${SORT_O} overwrite
/INCLUDE COND_OA
/OUTFILE ${SORT_O2} overwrite
/INCLUDE COND_NOT_OA
exit
EOF
SORT


wc -l $EST_FTECLEDA_MVT_POSTING
wc -l $EST_FTECLEDA_MVT_QTD_TMP
wc -l $EST_FTECLEDA_MVT_OPN_CAN


JOBEND

                     
