#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 granularity on delta posting
# nom du script SHELL           : ESFD3822.cmd
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
#[002] 17/02/2022 JYP : Spira 96729 : specific rule for open/cancel
#[003] 13/05/2022 JYP/TD : Spira 96729 : archive QTD file
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
ECHO_LOG "#===> PARM_ICLODAT_D.............: $PARM_ICLODAT_D"
ECHO_LOG "#===>     -------- input  ---------"
ECHO_LOG "#===> ESF_FCTRI17PRD ..............: $ESF_FCTRI17PRD "
ECHO_LOG "#===> ESF_FCTRI17PRD_OVR ..........: $ESF_FCTRI17PRD_OVR "
ECHO_LOG "#===> EST_FTECLEDA_MVT_PREV .......: $EST_FTECLEDA_MVT_PREV "
ECHO_LOG "#===> EST_FTECLEDA_MVT       ......: $EST_FTECLEDA_MVT "
ECHO_LOG "#===> EST_FTECLEDA_MVT_OPN_CAN ....: $EST_FTECLEDA_MVT_OPN_CAN "
ECHO_LOG "#===>     -------- output  ---------"
ECHO_LOG "#===> ESF_FCTRI17PRD_MRG   ........: $ESF_FCTRI17PRD_MRG "
ECHO_LOG "#===> EST_FTECLEDA_MVT_QTD ........: $EST_FTECLEDA_MVT_QTD "
ECHO_LOG "#===> EST_FTECLEDA_MVT_QTD_TMP ....: $EST_FTECLEDA_MVT_QTD_TMP "
ECHO_LOG "#===> EST_FTECLEDA_MVT_POSTING ....: $EST_FTECLEDA_MVT_POSTING "
ECHO_LOG "#========================================================================="


NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
# Merge of TL files
#------------------------------------------------------------------------------
LIBEL="MERGE : complete the quaterly QTD file "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTECLEDA_MVT_QTD_TMP} 2000 1"
SORT_I2="${EST_FTECLEDA_MVT_OPN_CAN} 2000 1"
SORT_I3="${EST_FTECLEDA_MVT} 2000 1"
SORT_O="${EST_FTECLEDA_MVT_QTD} 2000 1 overwrite"
INPUT_TEXT ${SORT_CMD} <<EOF
/COPY
exit
EOF
SORT


NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
# Archive QTD file
#------------------------------------------------------------------------------
ARCH_FILE=`basename ${EST_FTECLEDA_MVT_QTD}`_${PARM_CLODAT_D}.gz
LIBEL="Archive QTD file ARCH_FILE=$ARCH_FILE "
EXECKSH_MODE=P 
EXECKSH "gzip -c ${EST_FTECLEDA_MVT_QTD} > ${DARCH}/${ARCH_FILE} "


JOBEND

                     
