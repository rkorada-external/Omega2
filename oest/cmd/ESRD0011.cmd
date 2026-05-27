#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS Controle des operations internes
#
# nom du script SHELL		: ESRD0011.cmd
# revision			: 
# date de creation		: 15/12/00
# auteur			: S Llorente
# references des specifications	: 
#-----------------------------------------------------------------------------
# Cumul par postes des fichiers GTR par poste 750
# 
# 
# Input files
#       EST_FTECLEDR               DFILP
#       EST_FSSDACTR               DFILI
#       EST_FTRSLNK                DFILI
#
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd


# Job Initialization
JOBINIT

# Parametres
DATE_T=$1

	
NSTEP=${NJOB}_00
# Begin Isql
#----------------------------------------------------------------------------
#LIBEL="Parameter determination Internal Exchange Comparison Launching"
#ISQL_BASE="BEST"
#ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
#ISQL_QRY="exec BEST..PsTREQJOB_02 '${DATE_T}'"
#ISQL_FRES=${DFILT}/${NSTEP}_${IB}_FRES_O1.dat
#ISQL_INFO

#LAUNCH_B="$(cat ${ISQL_FRES} | cut -d~ -f1)"


#if [ ${LAUNCH_B} -eq 1 ] ; then

NSTEP=${NJOB}_05
# Begin sort
#----------------------------------------------------------------------------
LIBEL="Sort FTECLEDR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTECLEDR} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
   RETCTR_NF 24:1 - 24:,
   CTR_NF 8:1 - 8:,
   RETSEC_NF 26:1 - 26:,
   RETRTY_NF 27:1 - 27:,
   PLC_NT 36:1 - 36:,
   SSD_CF 1:1 - 1:,
   RETCUR_CF 34:1 - 34:,
   TRNCOD_CF 6:1 - 6:,
   SSDRTO_B 55:1 - 55:,
   RETAMT_M 35:1 - 35:
/KEYS
   RETCTR_NF,
   RETSEC_NF,
   RETRTY_NF,
   PLC_NT,
   SSD_CF,
   RETCUR_CF,
   TRNCOD_CF
/REFORMAT 
   RETCTR_NF,
   RETSEC_NF,
   RETRTY_NF,
   PLC_NT,
   SSD_CF,
   RETCUR_CF,
   TRNCOD_CF,
   RETAMT_M,
   SSDRTO_B,
   CTR_NF
/CONDITION IO SSDRTO_B EQ "1"
/INCLUDE IO
exit
EOF
SORT



NSTEP=${NJOB}_10
# Begin C program
#----------------------------------------------------------------------------
LIBEL="Synchronization of FTECLEDR with FSSDACTR and FTRSLNK tables"
PRG=ESTC0010
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_SORT_FTECLEDR.dat
export ${PRG}_I2=${EST_FSSDACTR}
export ${PRG}_I3=${EST_FBOPRSLNK}
#export ${PRG}_I4=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTROUTIO.dat
EXECPRG


NSTEP=${NJOB}_13
# Begin sort
#----------------------------------------------------------------------------
LIBEL="Sort FTECLEDR and SUMMARIZE RETAMT_M with the first key"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_ESTC0010_GTROUTIO.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTROUTIO.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
   SSD_CF 1:1 - 1:,
   SSD_CF_R 2:1 - 2:,
   RETAMT_M 3:1 - 3: EN,
   ACMTRS_NT 4:1 - 4:,
   TYPMNT_CT 5:1 - 5:,
   RETCUR_CF 6:1 - 6:,
   CTR_NF 7:1 - 7:,
   END_NT 8:1 - 8:,
   SEC_NF 9:1 - 9:,
   UWY_NF 10:1 - 10:,
   UW_NT 11:1 - 11:,
   RETCTR_NF 12:1 - 12:,
   RETSEC_NF 13:1 - 13:,
   RTY_NF 14:1 - 14:,
   PLC_NT 15:1 - 15:
/KEYS
   SSD_CF,
   SSD_CF_R,
   RETCTR_NF,
   RETSEC_NF,
   RTY_NF,
   PLC_NT,
   ACMTRS_NT,
   RETCUR_CF,
   TYPMNT_CT
/SUMMARIZE TOTAL RETAMT_M
/DERIVEDFIELD RETAMT_MS RETAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          SSD_CF_R,
          RETAMT_MS,
          ACMTRS_NT,
          TYPMNT_CT,
          RETCUR_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT

exit
EOF
SORT


NSTEP=${NJOB}_15
# Begin sort
#----------------------------------------------------------------------------
LIBEL="Sort FTECLEDR and SUMMARIZE RETAMT_M with the last key" 
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_13_${IB}_SORT_GTROUTIO.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTROUTIO_${LOCAL_SITE}.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
   SSD_CF 1:1 - 1:,
   SSD_CF_R 2:1 - 2:,
   RETAMT_M 3:1 - 3: EN,
   ACMTRS_CF 4:1 - 4:,
   TYPMNT_CT 5:1 - 5:,
   RETCUR_CF 6:1 - 6:,
   CTR_NF 7:1 - 7:,
   END_NT 8:1 - 8:,
   SEC_NF 9:1 - 9:,
   UWY_NF 10:1 - 10:,
   UW_NT 11:1 - 11:
/KEYS
   CTR_NF,
   END_NT,
   SEC_NF,
   UWY_NF,
   UW_NT,
   ACMTRS_CF,
   RETCUR_CF,
   TYPMNT_CT,
   SSD_CF_R,
   SSD_CF
/SUMMARIZE TOTAL RETAMT_M
/DERIVEDFIELD RETAMT_MS RETAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          SSD_CF_R,
          RETAMT_MS,
          ACMTRS_CF,
          TYPMNT_CT,
          RETCUR_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT

exit
EOF
SORT


#fi



JOBEND
