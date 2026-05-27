#!/bin/ksh
#===============================================================
#application name               : Clearing old data into BEST..TACCTRNE
#source name                    : ESTD0101.cmd
#revision                       : $Revision:   1.1  $
#creation date                  : 20/08/2003
#author                         : Roger Cassis
#specifications reference       :
#                               :
#---------------------------------------------------------------
#description :
# Suppression de mouvements anterieurs a une date dans BEST..TACCTRNE-TRTOSTAE-TACCTRTGT
#
# parameters :
#---------------------------------------------------------------
#modifications chronology  :
#
#[001] 23/01/2015 R. Cassis :spot:28197 Archivage et nettoyage annuel de tables supplémentaires : TRTOSTAE, TACCTRGTGT et TLIFSTADIF
#===============================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Entry parameters
BLCSHT_D=${1}
LAUNCH_D=${2}

BALSHEYEA_NF=`echo ${BLCSHT_D} | cut -c1-4`

datej=`date '+%Y%m%d%H%M%S'`

# Job Initialization
JOBINIT

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> BLCSHT_D.........: ${BLCSHT_D}"
ECHO_LOG "#===> LAUNCH_D.........: ${LAUNCH_D}"
ECHO_LOG "#===> BALSHEYEA_NF.....: ${BALSHEYEA_NF}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_00
# Begin Bcmulti
#---------------------------------------------------------------
LIBEL="Count before cleaning"
BCP_WAY="OUT"; BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_COUNT_before.log
BCP_QRY="SELECT 'TACCTRNE',count(*) FROM best..TACCTRNE
         SELECT 'TRTOSTAE',count(*) FROM best..TRTOSTAE
         SELECT 'TACCTRTGT',count(*) FROM best..TACCTRTGT"
BCP

ECHO_LOG "#========================================================================="
ECHO_LOG "#===> Records before"
cat ${DFILT}/${NSTEP}_${IB}_COUNT_before.log
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_10
# Begin Bcmulti
#---------------------------------------------------------------
LIBEL="BCP out of BEST..TACCTRNE (Archivage)"
BCP_WAY="OUT"; BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_O1_TACCTRNE.dat
BCP_QRY="SELECT * FROM best..TACCTRNE
         where BLCSHT_D <= '${BLCSHT_D}'
         and (EPSTATUS != 'I' or substring(trncod_cf,2,1) in ('S','C','O','R','I','T'))"
BCP

gzip -c ${DFILT}/${NSTEP}_${IB}_BCP_O1_TACCTRNE.dat > ${DARCH}/${NCHAIN}_TACCTRNE_before_${BLCSHT_D}_${datej}.dat.gz

NSTEP=${NJOB}_15
# Begin RMFIL
#---------------------------------------------------------------
LIBEL="Remove of temporary files"
RMFIL "${DFILT}/${NJOB}_10_${IB}_BCP_O1_TACCTRNE.dat"

NSTEP=${NJOB}_20
# Begin Bcmulti
#---------------------------------------------------------------
LIBEL="BCP out of BEST..TACCTRNE (data to keep)"
BCP_WAY="OUT"; BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_O1_TACCTRNE.dat
BCP_QRY="SELECT * FROM best..TACCTRNE
         where BLCSHT_D > '${BLCSHT_D}'
         or    (EPSTATUS = 'I' and substring(trncod_cf,2,1) not in ('S','C','O','R','I','T'))"
BCP

NSTEP=${NJOB}_30
# Begin sort
#-----------------------------------------------------------------
LIBEL="SORT on key data"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_BCP_O1_TACCTRNE.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O1_TACCTRNE.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS   TRN_NT  1:1 -  1:
/KEYS     TRN_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_40
# filling TACCTRNE table
#--------------------------------
LIBEL="filling TACCTRNE table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_30_${IB}_SORT_O1_TACCTRNE.dat
BCP_TRUNCATE=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_TABLE="BEST..TACCTRNE"
BCP

NSTEP=${NJOB}_50
# Begin Bcmulti
#---------------------------------------------------------------
LIBEL="BCP out of BEST..TRTOSTAE (Archivage)"
BCP_WAY="OUT"; BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_O1_TRTOSTAE.dat
BCP_QRY="SELECT * FROM best..TRTOSTAE
         where BALSHEYEA_NF <= convert(int,'${BALSHEYEA_NF}')"
BCP

gzip -c ${DFILT}/${NSTEP}_${IB}_BCP_O1_TRTOSTAE.dat > ${DARCH}/${NCHAIN}_TRTOSTAE_before_${BLCSHT_D}_${datej}.dat.gz

NSTEP=${NJOB}_55
# Begin RMFIL
#---------------------------------------------------------------
LIBEL="Remove of temporary files"
RMFIL "${DFILT}/${NJOB}_50_${IB}_BCP_O1_TRTOSTAE.dat"

NSTEP=${NJOB}_60
# Begin Bcmulti
#---------------------------------------------------------------
LIBEL="BCP out of BEST..TRTOSTAE (data to keep)"
BCP_WAY="OUT"; BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_O1_TRTOSTAE.dat
BCP_QRY="SELECT * FROM best..TRTOSTAE
         where BALSHEYEA_NF > convert(int,'${BALSHEYEA_NF}')"
BCP

NSTEP=${NJOB}_70
# Begin sort
#-----------------------------------------------------------------
LIBEL="SORT on key data"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_BCP_O1_TRTOSTAE.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O1_TRTOSTAE.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS   PLCSTA_NT  1:1 -  1:
/KEYS     PLCSTA_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_80
# filling TRTOSTAE table
#--------------------------------
LIBEL="filling TRTOSTAE table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_70_${IB}_SORT_O1_TRTOSTAE.dat
BCP_TRUNCATE=YES
BCP_TABLE="BEST..TRTOSTAE"
BCP

NSTEP=${NJOB}_90
# Begin Bcmulti
#---------------------------------------------------------------
LIBEL="BCP out of BEST..TACCTRTGT (Archivage)"
BCP_WAY="OUT"; BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_O1_TACCTRTGT.dat
BCP_QRY="SELECT * FROM best..TACCTRTGT
         where BLCSHT_D <= '${BLCSHT_D}'"
BCP

gzip -c ${DFILT}/${NSTEP}_${IB}_BCP_O1_TACCTRTGT.dat > ${DARCH}/${NCHAIN}_TACCTRTGT_before_${BLCSHT_D}_${datej}.dat.gz

NSTEP=${NJOB}_95
# Begin RMFIL
#---------------------------------------------------------------
LIBEL="Remove of temporary files"
RMFIL "${DFILT}/${NJOB}_90_${IB}_BCP_O1_TACCTRTGT.dat"

NSTEP=${NJOB}_100
# Begin Bcmulti
#---------------------------------------------------------------
LIBEL="BCP out of BEST..TACCTRTGT (data to keep)"
BCP_WAY="OUT"; BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_O1_TACCTRTGT.dat
BCP_QRY="SELECT * FROM best..TACCTRTGT
         where BLCSHT_D > '${BLCSHT_D}'"
BCP

NSTEP=${NJOB}_110
# Begin sort
#-----------------------------------------------------------------
LIBEL="SORT on key data"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100_${IB}_BCP_O1_TACCTRTGT.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O1_TACCTRTGT.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS   RETTRN_NT  1:1 -  1:
/KEYS     RETTRN_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_120
# filling TACCTRTGT table
#--------------------------------
LIBEL="filling TACCTRTGT table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_110_${IB}_SORT_O1_TACCTRTGT.dat
BCP_TRUNCATE=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_TABLE="BEST..TACCTRTGT"
BCP

NSTEP=${NJOB}_190
# Begin Bcmulti
#---------------------------------------------------------------
LIBEL="Count after cleaning"
BCP_WAY="OUT"; BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_COUNT_after.log
BCP_QRY="SELECT 'TACCTRNE',count(*) FROM best..TACCTRNE
         SELECT 'TRTOSTAE',count(*) FROM best..TRTOSTAE
         SELECT 'TACCTRTGT',count(*) FROM best..TACCTRTGT"
BCP

ECHO_LOG "#========================================================================="
ECHO_LOG "#===> Records After"
cat ${DFILT}/${NSTEP}_${IB}_COUNT_after.log
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_200
# Switch to non infocentre server ${SRV_2}
# ${SRV_2} is already difined in the environnement file
#--------------------------------------------------------------------------
LIBEL="Switch to infocentre server ${SRV_2}"
SWITCH_SRV ${SRV_2}

NSTEP=${NJOB}_200
# Begin Bcmulti
#---------------------------------------------------------------
LIBEL="Count before cleaning"
BCP_WAY="OUT"; BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_COUNT_before.log
BCP_QRY="SELECT 'TLIFSTADIF',count(*) FROM BSTA..TLIFSTADIF"
BCP

ECHO_LOG "#========================================================================="
ECHO_LOG "#===> Records before"
cat ${DFILT}/${NSTEP}_${IB}_COUNT_before.log
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_210
# Begin Bcmulti
#---------------------------------------------------------------
LIBEL="BCP out of BSTA..TLIFSTADIF (Archivage)"
BCP_WAY="OUT"; BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_O1_TLIFSTADIF.dat
BCP_QRY="SELECT * FROM BSTA..TLIFSTADIF
         where LAUNCH_D <= '${LAUNCH_D}'"
BCP

gzip -c ${DFILT}/${NSTEP}_${IB}_BCP_O1_TLIFSTADIF.dat > ${DARCH}/${NCHAIN}_TLIFSTADIF_before_${LAUNCH_D}_${datej}.dat.gz

NSTEP=${NJOB}_215
# Begin RMFIL
#---------------------------------------------------------------
LIBEL="Remove of temporary files"
RMFIL "${DFILT}/${NJOB}_210_${IB}_BCP_O1_TLIFSTADIF.dat"

NSTEP=${NJOB}_220
# Begin Bcmulti
#---------------------------------------------------------------
LIBEL="BCP out of BSTA..TLIFSTADIF (data to keep)"
BCP_WAY="OUT"; BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_O1_TLIFSTADIF.dat
BCP_QRY="SELECT * FROM BSTA..TLIFSTADIF
         where LAUNCH_D > '${LAUNCH_D}'"
BCP

NSTEP=${NJOB}_230
# Begin sort
#-----------------------------------------------------------------
LIBEL="SORT on key data"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_220_${IB}_BCP_O1_TLIFSTADIF.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O1_TLIFSTADIF.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS  SSD_CF        1:1 -  1:EN,
         LAUNCH_D      2:1 -  2:, 
         CTR_NF        3:1 -  3:, 
         END_NT        4:1 -  4:, 
         SEC_NF        5:1 -  5:, 
         UWY_NF        6:1 -  6:, 
         UW_NT         7:1 -  7:, 
         PLC_NT        8:1 -  8:, 
         ACCRET_CF     9:1 -  9:, 
         ACY_NF       10:1 - 10:, 
         ACMTRS_NT    11:1 - 11: 
/KEYS    SSD_CF,LAUNCH_D,CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,PLC_NT,ACCRET_CF,ACY_NF,ACMTRS_NT
exit
EOF
SORT

NSTEP=${NJOB}_240
# filling TACCTRNE table
#--------------------------------
LIBEL="filling TLIFSTADIF table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_230_${IB}_SORT_O1_TLIFSTADIF.dat
BCP_TRUNCATE=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_TABLE="BSTA..TLIFSTADIF"
BCP

NSTEP=${NJOB}_250
# Begin Bcmulti
#---------------------------------------------------------------
LIBEL="Count after cleaning"
BCP_WAY="OUT"; BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_COUNT_after.log
BCP_QRY="SELECT 'TLIFSTADIF',count(*) FROM BSTA..TLIFSTADIF"
BCP

ECHO_LOG "#========================================================================="
ECHO_LOG "#===> Records after"
cat ${DFILT}/${NSTEP}_${IB}_COUNT_after.log
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_300
# Begin RMFIL
#---------------------------------------------------------------
LIBEL="Remove of temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

#End of job
JOBEND
