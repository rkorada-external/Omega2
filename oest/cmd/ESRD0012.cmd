#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS Controle des operations internes
#
# nom du script SHELL		: ESRD0012.cmd
# revision			: 
# date de creation		: 15/12/00
# auteur			: S Llorente
# references des specifications	: 
#-----------------------------------------------------------------------------
# Cumul par postes des fichiers GTA  par poste 
# Envoi vers le site de paris des fichiers cumules GTR et GTA 
#
# Input files
#       EST_FTECLEDA               DFILP
#       EST_FSSDACTR               DFILI
#       EST_FTRSLNK                DFILI
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================


# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd


# Job Initialization
JOBINIT


DATE_T=$3




NSTEP=${NJOB}_00
# Begin Isql
#----------------------------------------------------------------------------
LIBEL="Parameter determination Internal Exchange Comparison Launching"
#LAUNCH_B="$(cat ${ISQL_FRES=${DFILT}/${NCHAIN}_ESRD0011_00_${IB}_FRES_O1.dat} | cut -d~ -f1)"


#if [ ${LAUNCH_B} -eq 1 ] ; then


NSTEP=${NJOB}_05
# Begin sort
#----------------------------------------------------------------------------
LIBEL="Sort FTECLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTECLEDA} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
   CTR_NF 8:1 - 8:,
   SEC_NF 10:1 - 10:,
   END_NT 9:1 - 9:,
   RTY_NF 27:1 - 27:,
   PLC_NT 36:1 - 36:,
   SSD_CF 1:1 - 1:,
   CUR_CF 18:1 - 18:,
   TRNCOD_CF 6:1 - 6:,
   CTRRET_B 70:1 - 70:,
   TRNCOD1 6:1 - 6:1,
   AMT_M 19:1 - 19:,
   UW_NT 12:1 - 12:,
   UWY_NF 11:1 - 11:,
   RETCTR_NF 24:1 - 24:,
   CED_NF 20:1 - 20:
/KEYS
   CTR_NF,
   END_NT,
   SEC_NF,
   UWY_NF,
   UW_NT,
   CUR_CF,
   TRNCOD_CF
/CONDITION RETRO_INTERNE  ( (CTRRET_B EQ "1") AND ((TRNCOD1 EQ "1") OR (TRNCOD1 EQ "3")) )
/INCLUDE RETRO_INTERNE 
/REFORMAT
   CTR_NF,
   END_NT,
   SEC_NF,
   UWY_NF,
   UW_NT,
   CUR_CF,
   TRNCOD_CF,
   RTY_NF,
   PLC_NT,
   SSD_CF,
   AMT_M,
   RETCTR_NF,
   CED_NF
exit
EOF
SORT



NSTEP=${NJOB}_10
# Begin C program
#----------------------------------------------------------------------------
LIBEL="Summarize of RETAMT_M"
PRG=ESTC0012
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_SORT_FTECLEDA.dat
export ${PRG}_I2=${EST_FBOPRSLNK}
export ${PRG}_I3=${EST_FCLIENT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAOUTIO.dat
EXECPRG


NSTEP=${NJOB}_15
# Begin SORT
#------------------------------------------------------------------
LIBEL="Summarize of RETAMT_M in file GTAOUTIO with the complete key"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_10_${IB}_${PRG}_GTAOUTIO.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAOUTIO_${LOCAL_SITE}.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        AMT_M 2:1 - 2: EN 18/3,
        ACMTRS_CF 3:1 - 3:,
        TYPMNT_CT 4:1 - 4:,
        CUR_CF 5:1 - 5:,
        CTR_NF 6:1 - 6:,
        END_NT 7:1 - 7:,
        SEC_NF 8:1 - 8:,
        UWY_NF 9:1 - 9:,
        UW_NT 10:1 - 10:,
        SSDS_CF 11:1 - 11:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACMTRS_CF,
      CUR_CF,
      TYPMNT_CT,
      SSD_CF
/SUMMARIZE TOTAL AMT_M
/DERIVEDFIELD AMT_MS AMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
      AMT_MS,
      ACMTRS_CF,
      TYPMNT_CT,
      CUR_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      SSDS_CF
exit
EOF
SORT



NSTEP=${NJOB}_20
# Concat file names
#------------------------------------------------------------------
LIBEL="Concat file names"
STR_CAT_PREFIX="${DFILT}/${NCHAIN}_*_15_${IB}_SORT_*OUTIO_${LOCAL_SITE}.dat"
STR_CAT


NSTEP=${NJOB}_25
# Send GTROUTIO and GTAOUTIO file to PARIS site
#----------------------------------------------------------------------------
LIBEL="Send GTROUTIO and GTAOUTIO files to PARIS site"
SEND_POOL_PREFIX="${NCHAIN}_ESRD001[12]_15_.*_SORT"
SEND_POOL_FILES="${STR_CAT_O}"
SEND_POOL_TYPE=SITE
SEND_POOL_SITE=${REMOTE_SITE}
SEND_POOL



#NSTEP=${NJOB}_30
# Begin bcp+ out
#----------------------------------------------------------------------------
#LIBEL="Update of BEST..TREQJOB"
#BCP_WAY="OUT"
#BCP_VER="+"
#BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_O1.log
#BCP_QRY="exec BEST..PuTREQJOB_02 '${DATE_T}'"
#BCP


NSTEP=${NJOB}_35
# Begin RMFIL
#--------------------------------------------------------------------------
LIBEL="Remove of temporary files"
RMFIL "${DFILT}/${NCHAIN}_*_${IB}_*.dat"

#fi

JOBEND
