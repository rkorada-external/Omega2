#!/bin/ksh
#===========================================================================================
# Application Name          :
# SHELL	Script Name	        : PMUM0012.cmd
# Revision			            : $Revision: 1.1 $
# Creation Date             : 2000/02 (AAAA/MM)
# Author                    : ASCOTT - VERNAY
# Specifications References	:
#-------------------------------------------------------------------------------------------
# Description               : Merge of PeopleSoft CMGT* files for MUTRE/CMF
#-------------------------------------------------------------------------------------------
# Job Launched By           : PMUM0010.cmd
#-------------------------------------------------------------------------------------------
# Modifications History     :
#[001] 19/06/2012 R. Cassis :spot:24245 Ajout messages echo_log
#===========================================================================================
#set -x

#- ---------------------- -
#- Call generic functions -
#- ---------------------- -
. ${DUTI}/fctgen.cmd

#- --------------------- -
#- Get input parmameters -
#- --------------------- -
BALSHEY_NF=$1
BALSHRMTH_NF=$2
INV=$3

#- ------------------ -
#- Job initialisation -
#- ------------------ -
JOBINIT

#- ------------------ -
#- PSOFT Export Files -
#- ------------------ -
if [ ${INV} -eq 0 ]
then
  if [ -f ${EST_CMGTAA}_*_${BALSHEY_NF}${BALSHRMTH_NF}_*_*.dat ] &&
     [ -f ${EST_CMGTR}_*_${BALSHEY_NF}${BALSHRMTH_NF}_*_*.dat ] &&
     [ -f ${EST_CMGTS}_*_${BALSHEY_NF}${BALSHRMTH_NF}_*_*.dat ]
  then
    export PSOFT_MGTAA=`ls -t ${EST_CMGTAA}_*_${BALSHEY_NF}${BALSHRMTH_NF}_*_*.dat | head -1`
    export PSOFT_MGTR=`ls -t ${EST_CMGTR}_*_${BALSHEY_NF}${BALSHRMTH_NF}_*_*.dat | head -1`
    export PSOFT_MGTS=`ls -t ${EST_CMGTS}_*_${BALSHEY_NF}${BALSHRMTH_NF}_*_*.dat | head -1`

  else
    echo "# !!!! Entry file is missing, chain not processed."
    CHAINEND
  fi
else
  if [ -f ${EST_MGTAA} ] &&
     [ -f ${EST_MGTR} ] &&
     [ -f ${EST_MGTS} ]
  then
    export PSOFT_MGTAA=`ls -t ${EST_MGTAA} | head -1`
    export PSOFT_MGTR=`ls -t ${EST_MGTR} | head -1`
    export PSOFT_MGTS=`ls -t ${EST_MGTS} | head -1`
  else
    CHAINEND
  fi

fi

ECHO_LOG "--------------------------------------------"
ECHO_LOG "--> PSOFT_MGTAA...... : ${PSOFT_MGTAA}"
ECHO_LOG "--> PSOFT_MGTR....... : ${PSOFT_MGTAA}"
ECHO_LOG "--> PSOFT_MGTS....... : ${PSOFT_MGTAA}"
ECHO_LOG "--------------------------------------------"

#- ------------- -
#- Step : 05     -
#-    Begin Sort -
#- ------------- -
NSTEP=${NJOB}_05
LIBEL="Keep only 8 and 9 data and merge the files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${PSOFT_MGTAA} 1000 1"
SORT_I2="${PSOFT_MGTR} 1000 1"
SORT_I3="${PSOFT_MGTS} 1000 1"
SORT_O=${DFILT}/${MUTRE_MGT}_${BALSHEY_NF}${BALSHRMTH_NF}.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
   SSD_CF 1:1 - 1:
/CONDITION
   OK (SSD_CF = "8" or SSD_CF = "9")
/OUTFILE
   ${SORT_O}
/INCLUDE
   OK
/COPY
exit
EOF
SORT

#- ------------- -
#- Step : 10     -
#-    Begin Copy -
#- ------------- -
NSTEP=${NJOB}_10
LIBEL="Copy for save"
EXECKSH "cp ${DFILT}/${MUTRE_MGT}_${BALSHEY_NF}${BALSHRMTH_NF}.dat
	    ${DSAV}/${SVG}_${MUTRE_MGT}_${BALSHEY_NF}${BALSHRMTH_NF}.dat"

#- DEBUT AJOUT STEP JR 10/10/2003 -

#- ---------------- -
#- Step : 15        -
#-    Sort Of MGTAA -
#- ---------------- -
NSTEP=${NJOB}_15
LIBEL="Sort of XXXGTAA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${PSOFT_MGTAA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_MGTAA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
   SSD_CF 1:1 - 1:EN,
   ESB_CF 2:1 - 2:EN,
   BALSHEY_NF 3:1 - 3:EN,
   BALSHRMTH_NF 4:1 - 4:EN,
   CUR_CF 18:1 - 18:,
   AMT_M 19:1 - 19:
/OUTFILE
   ${SORT_O}
/DERIVEDFIELD
   NAME_FIC "MGTAA~" CHAR 6
/KEYS
   SSD_CF,
   ESB_CF,
   BALSHEY_NF,
   BALSHRMTH_NF,
   CUR_CF
/REFORMAT
   NAME_FIC,
   SSD_CF,
   ESB_CF,
   BALSHEY_NF,
   BALSHRMTH_NF,
   CUR_CF,
   AMT_M
exit
EOF
SORT

#- --------------- -
#- Step : 20       -
#-    Sort Of MGTR -
#- --------------- -
NSTEP=${NJOB}_20
LIBEL="Sort of XXXGTR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${PSOFT_MGTR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_MGTR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
   SSD_CF 1:1 - 1:EN,
   ESB_CF 2:1 - 2:EN,
   BALSHEY_NF 3:1 - 3:EN,
   BALSHRMTH_NF 4:1 - 4:EN,
   BALSHRDAY_NF 5:1 - 5:EN,
   RETCUR_CF 34:1 - 34:,
   RETAMT_M 35:1 - 35:
/OUTFILE
   ${SORT_O}
/DERIVEDFIELD
   NAME_FIC "MGTR ~" CHAR 6
/KEYS
	SSD_CF,
  ESB_CF,
  BALSHEY_NF,
  BALSHRMTH_NF,
  RETCUR_CF
/REFORMAT NAME_FIC,
        SSD_CF,
        ESB_CF,
        BALSHEY_NF,
        BALSHRMTH_NF,
        RETCUR_CF,
        RETAMT_M
exit
EOF
SORT

#- --------------- -
#- Step : 25       -
#-    Sort Of MGTS -
#- --------------- -
NSTEP=${NJOB}_25
LIBEL="Sort of XXXGTS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${PSOFT_MGTS} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_MGTS_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
   SSD_CF 1:1 - 1:EN,
   ESB_CF 2:1 - 2:EN,
   BALSHEY_NF 3:1 - 3:EN,
   BALSHRMTH_NF 4:1 - 4:EN,
   BALSHRDAY_NF 5:1 - 5:EN,
   RETINTAMT_M 41:1 - 41:,
   CUR_CF 42:1 - 42:
/OUTFILE
   ${SORT_O}
/DERIVEDFIELD
   NAME_FIC "MGTS ~" CHAR 6
/KEYS
	SSD_CF,
  ESB_CF,
  BALSHEY_NF,
  BALSHRMTH_NF,
  CUR_CF
/REFORMAT
   NAME_FIC,
   SSD_CF,
   ESB_CF,
   BALSHEY_NF,
   BALSHRMTH_NF,
   CUR_CF,
   RETINTAMT_M
exit
EOF
SORT

#- ----------------------- -
#- Step : 30               -
#-    Sort/Merge of XXXGTX -
#- ----------------------- -
NSTEP=${NJOB}_30
LIBEL="Sort of XXXGTX"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_SORT_MGTAA_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_20_${IB}_SORT_MGTR_O.dat 1000 1"
SORT_I3="${DFILT}/${NJOB}_25_${IB}_SORT_MGTS_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_MGTARS_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
   NAME_FIC 1:1 - 1:,
   SSD_CF 2:1 - 2:,
   ESB_CF 3:1 - 3:,
   BALSHEY_NF 4:1 - 4:,
   BALSHRMTH_NF 5:1 - 5:,
   CUR_CF 6:1 - 6:
/OUTFILE
   ${SORT_O}
/KEYS
   NAME_FIC,
   SSD_CF,
   ESB_CF,
   BALSHEY_NF,
   BALSHRMTH_NF,
   CUR_CF
exit
EOF
SORT

#- -------------------------- -
#- Step : 35                  -
#-    Temporary file deletion -
#- -------------------------- -
NSTEP=${NJOB}_35
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_15_${IB}_SORT_MGTAA_O.dat
RMFIL ${DFILT}/${NJOB}_20_${IB}_SORT_MGTR_O.dat
RMFIL ${DFILT}/${NJOB}_25_${IB}_SORT_MGTS_O.dat

#- -------------------------------------------- -
#- Step : 40                                    -
#-    Retrocession and Acceptance Data Exchange -
#- -------------------------------------------- -
NSTEP=${NJOB}_40
LIBEL="Retrocession and Acceptance Data Exchange"
PRG=PMUC0001
export ${PRG}_I1=${DFILT}/${NJOB}_30_${IB}_SORT_MGTARS_O.dat
export ${PRG}_O1=${DFILT}/${MUTRE_CTRL}_${BALSHEY_NF}${BALSHRMTH_NF}.dat
EXECPRG

#- -------------------------- -
#- Step : 45                  -
#-    Temporary file deletion -
#- -------------------------- -
NSTEP=${NJOB}_45
LIBEL="Delete temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"
