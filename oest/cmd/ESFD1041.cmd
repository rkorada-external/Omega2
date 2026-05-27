#!/bin/ksh
#=============================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 update product code and gaap_code for historical data
# Date de creation              : 04/03/2022
# Auteur                        : JYP
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Description
#  update product code and gaap_code for historical data
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
#[001] 04/03/2022 JYP : Spira 102394 : update product code and gaap_code for historical data 
#[002] 30/03/2022 JYP : Spira 102394 : complete IFRS4 case 
#[003] 04/04/2022 JYP : Spira 102394 : update gaap_product codes , add log option
#====================================================================================================
#set -x

EST_OUT="$1"       # file to update
FORMAT="$2"        # format 71 or 118
GAAP_PRD_OPT="$3"  # GAAP_ONLY / PRD_ONLY / empty=ALL
STAT_OPT="$4"      # Y or empty
EST_BASE=`basename "${1%.*}"`
today=`date '+%Y%m%d' `


# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT



#------ product code prefix 
case "${DEFAULT_SQL_LOGIN}" in
        "ubas") PREFIX="~AS" ;;
        "ubeu") PREFIX="~EU" ;;
        "ubam") PREFIX="~AM" ;;
        *) ECHO_LOG "wrong value for DEFAULT_SQL_LOGIN : ${DEFAULT_SQL_LOGIN} , should be ubxx "
       STEPEND 1 ;;
esac

#------ fields to update 
case "${FORMAT}" in
        "71") GAAP_FIELD="64" 
              PRDC_FIELD="65" ;;
        "118") GAAP_FIELD="111" 
               PRDC_FIELD="112" ;;
        *) ECHO_LOG "wrong value for FORMAT : ${FORMAT} , 71 or 118 "
       STEPEND 2 ;;
esac




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
ECHO_LOG "#===> PARM_ICLODAT_D.............: $PARM_ICLODAT_D"
ECHO_LOG "#===> site/DEFAULT_SQL_LOGIN   ..: $DEFAULT_SQL_LOGIN  "
ECHO_LOG "#===> GAAP_PRD_OPT ..............: $GAAP_PRD_OPT "
ECHO_LOG "#===> STAT_OPT     ..............: $STAT_OPT "
ECHO_LOG "#===> FORMAT       ..............: $FORMAT "
ECHO_LOG "#===> GAAP_FIELD   ..............: $GAAP_FIELD "
ECHO_LOG "#===> PRDC_FIELD    .............: $PRDC_FIELD "
ECHO_LOG "#===> PREFIX                 ....: $PREFIX  "
ECHO_LOG "#===> EST_BASE               ....: $EST_BASE  "

ECHO_LOG "#===>     -------- input  ---------"
ECHO_LOG "#===> EST_OUT .......: $EST_OUT     "
ECHO_LOG "#===> EST_GAAPCOD_MAPPING .......: $EST_GAAPCOD_MAPPING     "
ECHO_LOG "#===> ESF_FCTRI17PRD_NEW  .......: $ESF_FCTRI17PRD_NEW      "
ECHO_LOG "#===> ESF_FI17PRODUCT      ......: $ESF_FI17PRODUCT         "
ECHO_LOG "#===> ESF_FTECLEDR_REJ      .....: $ESF_FTECLEDR_REJ        "
ECHO_LOG "#===> ESF_FTECLEDA_OPNG   .......: $ESF_FTECLEDA_OPNG       "
ECHO_LOG "#===> ESF_FTECLEDR_OPNG   .......: $ESF_FTECLEDR_OPNG       "
ECHO_LOG "#===> ESF_FTECLEDA_REJ     ......: $ESF_FTECLEDA_REJ        "
ECHO_LOG "#===> EPO_DLREJGTAASIISO    .....: $EPO_DLREJGTAASIISO      "
ECHO_LOG "#===> EPO_DLREJGTARSIISO  .......: $EPO_DLREJGTARSIISO      "
ECHO_LOG "#===> EPO_DLREJGTRSIISO   .......: $EPO_DLREJGTRSIISO       "
ECHO_LOG "#===> EST_CURGTR           ......: $EST_CURGTR              "
ECHO_LOG "#===> EST_CURGTA            .....: $EST_CURGTA              "
ECHO_LOG "#===>     -------- output  ---------"
ECHO_LOG "#===> EST_OUT .......: $EST_OUT     "
ECHO_LOG "#========================================================================="




NSTEP=${NJOB}_00
#-----------------------------------------------------------------------------
LIBEL="check input file EST_OUT=$EST_OUT  "
EXECKSH_MODE=P
EXECKSH "echo EST_OUT=$EST_OUT  "
#====== do NOT process empty files , wihout failing
if [ ! -s "$EST_OUT" ] || [ ! -f "$EST_OUT" ]
then
   ECHO_LOG "WARNING : empty or missing file is NOT processed EST_OUT=$EST_OUT  " 
   JOBEND
fi


NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="BEFORE cleaning fields : save and stat file EST_OUT=$EST_OUT "
EXECKSH_MODE=P
EXECKSH "echo BEFORE: gaap_code for $EST_OUT  :  "
cut -d~ -f$GAAP_FIELD $EST_OUT | sort | uniq -c >>   $FLOG

ECHO_LOG "BEFORE: product_code for $EST_OUT  :  " 
cut -d~ -f$PRDC_FIELD  $EST_OUT | cut -c1-2 | sort | uniq -c >>   $FLOG
gzip -c ${EST_OUT} > ${DSAVE}/${SVG}_${EST_BASE}_before_${today}_$$.gz



NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="CLEAN old product code, fields 65 or 112 "
#-----------------------------------------------------------------------------
AWK_I=${EST_OUT}
AWK_O=${DFILT}/${NJOB}_20_${EST_BASE}_$$.dat
AWK_PARAM=" -v format=${FORMAT} -v opt=${GAAP_PRD_OPT} "
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
{
 if ( opt == "" || opt == "GAAP_ONLY" || opt == "ALL" )
    \$${GAAP_FIELD}="";

 if ( opt == "" || opt == "PRD_ONLY" || opt == "ALL" )
    \$${PRDC_FIELD}="";
 
 print \$0;
}
exit
EOF
echo "AWK_CMD=[ "
cat $AWK_CMD 
AWK



if [ "$STAT_OPT" = "Y" ]
then
	NSTEP=${NJOB}_30
	#-----------------------------------------------------------------------------
	LIBEL="AFTER cleaning fields : stat file EST_OUT=$EST_OUT "
	EXECKSH_MODE=P
	EXECKSH "wc -l ${DFILT}/${NJOB}_20_${EST_BASE}_$$.dat  "
	ECHO_LOG "AFTER: gaap_code for $EST_OUT  :  " 
	cut -d~ -f$GAAP_FIELD ${DFILT}/${NJOB}_20_${EST_BASE}_$$.dat  | sort | uniq -c >>   $FLOG
	
	ECHO_LOG "AFTER: product_code for $EST_OUT  :  " 
	cut -d~ -f$PRDC_FIELD  $EST_OUT | cut -c1-2 | sort | uniq -c >>   $FLOG
fi


NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
LIBEL="overwrite EST_OUT=$EST_OUT "
EXECKSH_MODE=P
EXECKSH "mv  ${DFILT}/${NJOB}_20_${EST_BASE}_$$.dat $EST_OUT "

JOBEND

                     
