#! /bin/ksh
#===============================================================================
#application name               : Extraction data from database
#source name                    : EXTJ0011.cmd
#revision                       : $Revision:   0.1  $
#extraction date                : 17/01/2019
#author                         : Lagha Belaid
#specifications reference       :
#                               :
#-------------------------------------------------------------------------------
#description : Extract table data to compare them
#
#parameters :
#
# PATH_ : path to queries files directory
#
#-------------------------------------------------------------------------------
#modifications chronology  :
# [01] 20/07/2021 D.TEIXEIRA : add EXTJ0010.prm 
# [02] 21/09/2021 D.TEIXEIRA : update query Extracting TBOPAR
# [03] 15/03/2023 D.TEIXEIRA : spira 109120 - redirect stderr to /dev/null
# [04] 17/11/2023 D.TEIXEIRA : spira 99999 - move delete files into new job EXTJ0012
#===============================================================================

# call generic functions
. ${DUTI}/fctgen.cmd

TODAY=`date +"%Y%m%d"`
PATH_=$1
CLODAT_D=$2
_FPARM_=$3
QLSTF=$4


# Job Initialisation
#-------------------
JOBINIT

ECHO_LOG "# CLODAT_D -----> '${CLODAT_D}'"
ECHO_LOG "# BLCSHTYEA_NF -> '$(GETV ${_FPARM_} BLCSHTYEA_NF)'"
ECHO_LOG "# CRE_D --------> '$(GETV ${_FPARM_} CRE_D)'"
ECHO_LOG "# CONSOYEA -----> '$(GETV ${_FPARM_} CONSOYEA)'"
ECHO_LOG "# BATCHUSER ----> '$(GETV ${_FPARM_} BATCHUSER)'"
ECHO_LOG "# SSDCLO_LL ----> '$(GETV ${_FPARM_} SSDCLO_LL)'"


# [02]
BLCSHTYEA_NF=$(GETV ${_FPARM_} BLCSHTYEA_NF)
BALSHTMTH_NF=$(GETV ${_FPARM_} BALSHTMTH_NF)

NSTEP=${NJOB}_SRV_SWITCH_DW
# Move to INFOMEGA
#------------------------------------------------------------------------------
LIBEL="Switch to INFOMEGA server"
SWITCH_SRV ${SRV_2}

# [02]
NSTEP=${NJOB}_10
# Extracting Call table for TBOPAR
#------------------------------------------------------------------------------
LIBEL="Extracting TBOPAR"
OUT_TBOPAR=${DFILT}/${NSTEP}_TBOPAR.dat
FIELD1_CF=`date -d"${BLCSHTYEA_NF}/${BALSHTMTH_NF}/1" +"%Y%m"`
FIELD2_CF=${CLODAT_D}
QUERY="select TAB_CF, TABCIBLE_CF from BSAR..TBOPAR \
 where FIELD2_CF = '${FIELD2_CF}' \
 and FIELD1_CF = '${FIELD1_CF}'
 and (PAR_D=NULL or PAR_D='')
"
ISQL_BASE="BSAR"
ISQL_FRES=${OUT_TBOPAR}
ISQL_QRY=${QUERY}
ISQL_RSLT


NSTEP=${NJOB}_15
# Complete the PARM file
#------------------------------------------------------------------------------
LIBEL="Complete the FPARM file with TBOPAR informations"
FPARM=${DFILT}/${NSTEP}_FPARM.dat
# EXECKSH "cp ${_FPARM_} ${FPARM}"
# #on desactive la ligne ci-dessous car EXECKSH sait pas exec cette cmd
# #EXECKSH "sed 's/ *~ */=\"/g; s/ *$/\"/g' ${OUT_TBOPAR} >> ${FPARM}"
# sed 's/ *~ */=\"/g; s/ *$/\"/g' ${OUT_TBOPAR} >> ${FPARM}
# sed '1s/^/\n#\n# /;s/^/# /g; s/~/ -->  /g' ${OUT_TBOPAR}
# EXECKSH "rm ${OUT_TBOPAR}"
ECHO_LOG "# ${QUERY}"
sed '1s/^/\n# /;s/^/# /g; s/~/ -->  /g' ${OUT_TBOPAR}
STEPSTART
ECHO_LOG "command: cp ${_FPARM_} ${FPARM}"
cp ${_FPARM_} ${FPARM}
sed 's/ *~ */=\"/g; s/ *$/\"/g' ${OUT_TBOPAR} >> ${FPARM}
ECHO_LOG "command: rm ${OUT_TBOPAR}"
rm ${OUT_TBOPAR}
STEPEND 0


NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="Execution of extraction request files"
EXTR_PATH=${PATH_}
EXTR_QLSTF=${QLSTF}
EXTR_CLODAT_D=${CLODAT_D}
EXTR_PARM=${FPARM}
EXTR_QEXT=${QEXT}
EXTR_PMXJ=10
EXTRACT


# SITE=Europe --> SSD_CF=2|SITE=USA --> SSD_CF=10|SITE=ASIA --> SSD_CF=20
#------------------------------------------------------------------------------
case ${PARM_BATCHUSER} in
  "ubeu") LSSD_CF="2";;
  "ubam") LSSD_CF="10";;
  "ubas") LSSD_CF="20";;
  "ubgl") LSSD_CF="";;
esac

# Check if ALL_ACMTRS_MACRO_TTECLEDSII file exists and filter just one
# ssd for each site
#------------------------------------------------------------------------------
if [ -f ${DFILI}/${NJOB}_*ALLACMTRSMACROTTECLEDSII_${CLODAT_D}_${PARM_CRE_D}.csv ]
then 
  NSTEP=${NJOB}_35
  # sort ${DFILI}/${NJOB}_*ALLACMTRSMACROTTECLEDSII_${CLODAT_D}_${PARM_CRE_D}.csv
  #----------------------------------------------------------------------------
  FILE=`ls ${DFILI}/${NJOB}_*ALLACMTRSMACROTTECLEDSII_${CLODAT_D}_${PARM_CRE_D}.csv`
  BASE_NAME=`basename ${FILE}`

  # store head in HEAD variable
  #----------------------------
  HEAD=`sed -n '1p' ${FILE} && sed -i '1d' ${FILE}`
  LIBEL="Sort ALLACMTRSMACROTTECLEDSII_${CLODAT_D}_${PARM_CRE_D}.csv"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_FS=";"
  SORT_I="${FILE} 1000 1"
  SORT_O=${DFILT}/${BASE_NAME}_SORT.dat
  INPUT_TEXT ${SORT_CMD} << EOF
  /FIELDS
     SSD_CF 3:1 - 3:EN

  /CONDITION  COND1 (SSD_CF EQ ${LSSD_CF})
  /COPY
  /OUTFILE ${SORT_O} OVERWRITE
  /INCLUDE COND1
exit
EOF
  SORT

  sed "1s/^/${HEAD}\n/g" ${DFILT}/${BASE_NAME}_SORT.dat > ${FILE}
fi


# Check if ALL_ACMTRS_DETAILED_TTECLEDSII file exists and filter just one
# ssd for each site
#------------------------------------------------------------------------------
if [ -f ${DFILI}/${NJOB}_*ALLACMTRSDETAILEDTTECLEDSII_${CLODAT_D}_${PARM_CRE_D}.csv ]
then 
  NSTEP=${NJOB}_40
  # sort ${DFILI}/${NJOB}_*ALLACMTRSDETAILEDTTECLEDSII_${CLODAT_D}_${PARM_CRE_D}.csv
  #----------------------------------------------------------------------------
  FILE=`ls ${DFILI}/${NJOB}_*ALLACMTRSDETAILEDTTECLEDSII_${CLODAT_D}_${PARM_CRE_D}.csv`
  BASE_NAME=`basename ${FILE}`

  # store head in HEAD variable
  #----------------------------
  HEAD=`sed -n '1p' ${FILE} && sed -i '1d' ${FILE}`
  LIBEL="Sort ALLACMTRSDETAILEDTTECLEDSII_${CLODAT_D}_${PARM_CRE_D}.csv"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_FS=";"
  SORT_I="${FILE} 1000 1"
  SORT_O=${DFILT}/${BASE_NAME}_SORT.dat
  INPUT_TEXT ${SORT_CMD} << EOF
  /FIELDS
     SSD_CF 3:1 - 3:EN

  /CONDITION  COND1 (SSD_CF EQ ${LSSD_CF})
  /COPY
  /OUTFILE ${SORT_O} OVERWRITE
  /INCLUDE COND1
exit
EOF
  SORT

  sed "1s/^/${HEAD}\n/g" ${DFILT}/${BASE_NAME}_SORT.dat > ${FILE}
fi


# Check if FUTUR_MACRO_TTECLEDSII file exists and filter just one
# ssd for each site
#------------------------------------------------------------------------------
if [ -f ${DFILI}/${NJOB}_*FUTURMACROTTECLEDSII_${CLODAT_D}_${PARM_CRE_D}.csv ]
then 
  NSTEP=${NJOB}_45
  # sort ${DFILI}/${NJOB}_*FUTURMACROTTECLEDSII_${CLODAT_D}_${PARM_CRE_D}.csv
  #----------------------------------------------------------------------------
  FILE=`ls ${DFILI}/${NJOB}_*FUTURMACROTTECLEDSII_${CLODAT_D}_${PARM_CRE_D}.csv`
  BASE_NAME=`basename ${FILE}`

  # store head in HEAD variable
  #----------------------------
  HEAD=`sed -n '1p' ${FILE} && sed -i '1d' ${FILE}`
  LIBEL="Sort FUTURMACROTTECLEDSII_${CLODAT_D}_${PARM_CRE_D}.csv"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_FS=";"
  SORT_I="${FILE} 1000 1"
  SORT_O=${DFILT}/${BASE_NAME}_SORT.dat
  INPUT_TEXT ${SORT_CMD} << EOF
  /FIELDS
     SSD_CF 2:1 - 2:EN

  /CONDITION  COND1 (SSD_CF EQ ${LSSD_CF})
  /COPY
  /OUTFILE ${SORT_O} OVERWRITE 
  /INCLUDE COND1
exit
EOF
  SORT

  sed "1s/^/${HEAD}\n/g" ${DFILT}/${BASE_NAME}_SORT.dat > ${FILE}
fi

# TODO FOR :
#------------------------------------------------------------------------------
# ${DFILI}/${NJOB}_*AcquisitionExpensesSII_${CLODAT_D}_${PARM_CRE_D}.csv
# ${DFILI}/${NJOB}_*RiskAdjustementSII_${CLODAT_D}_${PARM_CRE_D}.csv

# END Of Job
#------------------------------------------------------------------------------
JOBEND
