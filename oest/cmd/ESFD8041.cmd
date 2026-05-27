#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESFD0041.cmd
# date de creation              : 24/01/2022
# auteur                        : JYP - PERSEE
# references des specifications :
#-----------------------------------------------------------------------------
# description : save granularity product codes into database
#
#-----------------------------------------------------------------------------
# historiques des modifications
#=================================================================================================
#[001] 24/01/2022 JYP : Spira 101782 : Creation : save granularity product codes into database
#[002] 24/02/2022 JYP : Spira 101738 : save granularity contrat product links into database
#[003] 09/06/2022 JYP : SPIRA 104771 : IFRS17 Product defaulting
#[004] 13/03/2024 JYP : SPIRA 111358 : new prm to manage saving into DW
#[005] 23/12/2025 JYP : US6343: optimisation , perf issue on LOCAL 
#===============================================================================================


# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT


set `GETPRM ${DPRM}/ESFD8040.prm`
if [[ "${SRV}" = "PRD_TPO2" ]]
then
        export SAVE_DW_DATABASE=${2}
else
        export SAVE_DW_DATABASE=${1}
fi


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
ECHO_LOG "#===> SAVE_DW_DATABASE ..........: $SAVE_DW_DATABASE"


#--------------------------------------------------------------------------- 
NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="load mapping, specific chain for all NORME "
ISQL_BASE=BEST
ISQL_O=${DFILT}/${NSTEP}_${IB}_ESFD8040.dat
ISQL_QRY="select 'export ' +  PERMFIL_CT + '=\"' + pathpattrn_ll + '\"' from BEST..TI17PERMFIL where IDF_CT = 'ESFD8040' "
ECHO_LOG "ISQL_QRY = [ $ISQL_QRY ] "
ISQL

grep export ${DFILT}/${NSTEP}_${IB}_ESFD8040.dat > ${DFILT}/${NSTEP}_${IB}_ESFD8040_PERMFIL.dat
. ${DFILT}/${NSTEP}_${IB}_ESFD8040_PERMFIL.dat

ECHO_LOG "#===>     -------- input  ---------"
ECHO_LOG "#===> ESF_FCTRI17PRD_NEW  .....: $ESF_FCTRI17PRD_NEW  "
ECHO_LOG "#===> ESF_FI17PRODUCT_NEW .....: $ESF_FI17PRODUCT_NEW "
ECHO_LOG "#===> ESF_FI17PRODUCT_MRG  ....: $ESF_FI17PRODUCT_MRG "
ECHO_LOG "#===> ESF_FCTRI17PRD_MRG   ....: $ESF_FCTRI17PRD_MRG  "
ECHO_LOG "#========================================================================="




#------ check user is OK
case "${DEFAULT_SQL_LOGIN}" in
        "ubas") PREFIX="AS" ;;
        "ubeu") PREFIX="EU" ;;
        "ubam") PREFIX="AM" ;;
        *) ECHO_LOG "wrong value for DEFAULT_SQL_LOGIN : ${DEFAULT_SQL_LOGIN} , should be ubxx "
       STEPEND 20;;
esac
ECHO_LOG "#===> site/DEFAULT_SQL_LOGIN   ....: $DEFAULT_SQL_LOGIN  "
ECHO_LOG "#===> PREFIX              .........: $PREFIX  "


NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="clean BEST..TI17PRODUCT for site $DEFAULT_SQL_LOGIN "
ISQL_BASE=BEST
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="delete BEST..TI17PRODUCT where bchusr_cf = '${DEFAULT_SQL_LOGIN}'  "
ECHO_LOG "ISQL_QRY = [ $ISQL_QRY ] "
ISQL


NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="Load file ESF_FI17PRODUCT_NEW into table BEST..TI17PRODUCT "
BCP_WAY="IN"
BCP_VER=""
BCP_I="${ESF_FI17PRODUCT_NEW}"
BCP_TABLE="BEST..TI17PRODUCT"
BCP


TODAY=`date '+%Y%m%d' `

NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
LIBEL="format contract links file  "
#------------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FCTRI17PRD_NEW} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FCTRI17PRD.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
     CTR_NF                 1:1 - 1:   ,
     END_NT                 2:1 - 2:EN ,
     SEC_NF                 3:1 - 3:EN ,
     UWY_NF                 4:1 - 4:   ,
     UW_NT                  5:1 - 5:EN ,
     CTR_TYP                6:1 - 6:   ,
     I17PRDCOD_CT           8:1 - 8:
/DERIVEDFIELD USER_SITE "${DEFAULT_SQL_LOGIN}"
/DERIVEDFIELD DATE_TODAY "${TODAY}~"
/KEYS
     CTR_NF  ,
     END_NT  ,
     SEC_NF  ,
     UWY_NF  ,
     UW_NT
/OUTFILE ${SORT_O} overwrite
/REFORMAT     CTR_NF       ,
              END_NT       ,
              SEC_NF       ,
              UWY_NF       ,
              UW_NT        ,
              I17PRDCOD_CT ,
              DATE_TODAY   ,
              USER_SITE  
exit
EOF
SORT



NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
LIBEL="clean BEST..TCTRI17PRDLNK for site $DEFAULT_SQL_LOGIN "
ISQL_BASE=BEST
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="delete BEST..TCTRI17PRDLNK where bchusr_cf = '${DEFAULT_SQL_LOGIN}'  "
ECHO_LOG "ISQL_QRY = [ $ISQL_QRY ] "
ISQL


NSTEP=${NJOB}_50
#------------------------------------------------------------------------------
LIBEL="Load file ESF_FCTRI17PRD_NEW into table BEST..TCTRI17PRDLNK "
BCP_WAY="IN"
BCP_VER=""
BCP_I="${DFILT}/${NJOB}_30_${IB}_FCTRI17PRD.dat"
BCP_TABLE="BEST..TCTRI17PRDLNK"
BCP



NSTEP=${NJOB}_60
#------------------------------------------------------------------------------
LIBEL="Unload BEST..TACCSUP from TP to load to Infocenter into BSAR..TACCSUP"
BCP_WAY="OUT"
BCP_VER="+"
BCP_QRY="select a.* from BEST..TACCSUP a, BREF..TBATCHSSD T where a.SSD_CF=T.SSD_CF and T.BATCHUSER_CF=suser_name()"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FACCSUP_O.dat
BCP



NSTEP=${NJOB}_65
#------------------------------------------------------------------------------
LIBEL="Switch Server Infomega $SRV_2 "
SWITCH_SRV ${SRV_2}



NSTEP=${NJOB}_66
#------------------------------------------------------------------------------
LIBEL="Load of BEST..TACCSUP file into BSAR..TACCSUP"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_60_${IB}_BCP_FACCSUP_O.dat
BCP_TRUNCATE=YES
BCP_PARTITION=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_TABLE="BSAR..TACCSUP"
BCP


if [ "${SAVE_DW_DATABASE}" != "Y" ]
then
   ECHO_LOG "#===> setup prm is not activated to save products into DW database , stop the job here  "
   JOBEND
fi 



NSTEP=${NJOB}_70
#------------------------------------------------------------------------------
LIBEL="clean BEST..TI17PRODUCT for site $DEFAULT_SQL_LOGIN $SRV_2 "
ISQL_BASE=BEST
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="delete BEST..TI17PRODUCT where bchusr_cf = '${DEFAULT_SQL_LOGIN}'  "
ECHO_LOG "ISQL_QRY = [ $ISQL_QRY ] "
ISQL


NSTEP=${NJOB}_80
#------------------------------------------------------------------------------
LIBEL="Load file ESF_FI17PRODUCT_NEW into table BEST..TI17PRODUCT $SRV_2 "
BCP_WAY="IN"
BCP_VER=""
BCP_I="${ESF_FI17PRODUCT_NEW}"
BCP_TABLE="BEST..TI17PRODUCT"
BCP


NSTEP=${NJOB}_85
#------------------------------------------------------------------------------
LIBEL="TO BE REMOVED later : check TCTRI17PRDLNK exists on $SRV_2 : useful for 1rst run "
ISQL_BASE=BEST
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="select result= case when isnull(OBJECT_ID('BEST..TCTRI17PRDLNK'),0) = 0 THEN 'TCTRI17PRDLNK NOT EXISTS' ELSE 'TCTRI17PRDLNK FOUND' end  "
ECHO_LOG "ISQL_QRY = [ $ISQL_QRY ] "
ISQL

found=`grep "TCTRI17PRDLNK FOUND" ${DFILT}/${NJOB}_85_${IB}_ISQL.log | wc -l `
if [ $found -eq 0 ]
then
  ECHO_LOG "WARNING : BEST..TCTRI17PRDLNK not exists on DW, stop loading without failing"
  JOBEND
fi



NSTEP=${NJOB}_90
#------------------------------------------------------------------------------
LIBEL="clean BEST..TCTRI17PRDLNK for site $DEFAULT_SQL_LOGIN $SRV_2 "
ISQL_BASE=BEST
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="delete BEST..TCTRI17PRDLNK where bchusr_cf = '${DEFAULT_SQL_LOGIN}'   "
ECHO_LOG "ISQL_QRY = [ $ISQL_QRY ] "
ISQL


NSTEP=${NJOB}_100
#------------------------------------------------------------------------------
LIBEL="Load file ESF_FCTRI17PRD_NEW into table BEST..TCTRI17PRDLNK $SRV_2 "
BCP_WAY="IN"
BCP_VER=""
BCP_I="${DFILT}/${NJOB}_30_${IB}_FCTRI17PRD.dat"
BCP_TABLE="BEST..TCTRI17PRDLNK"
BCP



JOBEND

                     
