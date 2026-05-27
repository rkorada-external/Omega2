#!/bin/ksh
#=============================================================================
# maj de l'application:           ESTIMATIONS - TRANSFERT INTER-SITES
# nom du script SHELL:            ESTD3011.cmd
# revision:                       $Revision: 1.3 $
# date de creation:               10/02/2009
# auteur:                         J.Ribot
# references des specifications : :spot:16765
#-----------------------------------------------------------------------------
# description
#
# generation des fichiers GT CURGT STAGT ARCSTATGT pour les nouveaux contrats
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#      05/06/2009 Roger Cassis :spot:17532 Si statuts pas positionnes correctement, arret de la chaine
#      03/12/2009 Roger Cassis :spot:18415 Mise à jour parametres plus utilises
# [03] 07/07/2011 Florent      :spot:22328 ajout de 16 champs dans le GTA
# [04] 13/07/2011 Roger Cassis :spot:22358 ajout de 16 champs dans le GTA
# [05] 19/08/2015 Roger Cassis :spot:29223 Correction du reformat des GT pour Omega 2
#
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd

# Entry parameters
BLCSHT_D=${1}
BALSHEY_NF=${2}
BALSHTMTH_NF=${3}
ESTIM_B=${4}
FORCEBILAN=${5}
QTRLIM_NF=${6}
TRANSFESB=${7}

# Initialization of the Job
JOBINIT

NSTEP=${NJOB}_00A
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Check if data to transfer exist"
ISQL_BASE="BTRT"
ISQL_QRY="set rowcount 2
          select * from BTRT..TRFCROSSREF
          where  (TRFACCSTS_CT = 34 and TRFSTS_CT = 3) OR (TRFACCSTS_CT = 44 and TRFSTS_CT = 14)
          UNION
          select * from BFAC..TRFCROSSREF
          where  (TRFACCSTS_CT = 34 and TRFSTS_CT = 3) OR (TRFACCSTS_CT = 44 and TRFSTS_CT = 14)"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.log
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat
ISQL_NOWARNING="YES"
ISQL_RES

if [ ! -s ${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat ]
then
  ECHO_LOG "---> No Data to process because Crossref statuts are not set right"
  STEPEND 1
fi

NSTEP=${NJOB}_00
#---------------------------------------------------------------------------
LIBEL="Get files from directories and merge them"
GET_FILES_DIR=${REMOTE_SITE}
GET_FILES_PREFIX=${EXTCHAIN}_*_TACCSTAT
GET_FILES_MERGE="YES"
GET_FILES_O=${DFILT}/${NSTEP}_${IB}_TACCSTAT_TRANSFP.dat
GET_FILES

NSTEP=${NJOB}_01
#---------------------------------------------------------------------------
LIBEL="Get files from directories and merge them"
GET_FILES_DIR=${REMOTE_SITE}
GET_FILES_PREFIX=${EXTCHAIN}_*_GTA
GET_FILES_MERGE="YES"
GET_FILES_O=${DFILT}/${NSTEP}_${IB}_GTA_TRANSFP.dat
GET_FILES

NSTEP=${NJOB}_02
#---------------------------------------------------------------------------
LIBEL="Get files from directories and merge them"
GET_FILES_DIR=${REMOTE_SITE}
GET_FILES_PREFIX=${EXTCHAIN}_*_CURGTA
GET_FILES_MERGE="YES"
GET_FILES_O=${DFILT}/${NSTEP}_${IB}_CURGTA_TRANSFP.dat
GET_FILES

NSTEP=${NJOB}_03
#---------------------------------------------------------------------------
LIBEL="Get files from directories and merge them"
GET_FILES_DIR=${REMOTE_SITE}
GET_FILES_PREFIX=${EXTCHAIN}_*_ARCSTATGTA
GET_FILES_MERGE="YES"
GET_FILES_O=${DFILT}/${NSTEP}_${IB}_ARCSTATGTA_TRANSFP.dat
GET_FILES

if [ ${TRANSFESB} = "1" ]             # transfert etablissement
then

	NSTEP=${NJOB}_04
	# Begin C Program
	#------------------------------------------------------------------------------
	LIBEL="Extraction des tables"
	PRG=ESTX7015
	export ${PRG}_O1=${DFILT}/${NJOB}_05_${IB}_ESTX7008_CTRCROSSREF.dat
	export ${PRG}_O2=${DFILT}/${NJOB}_05_${IB}_ESTX7008_CLMCROSSREF.dat
	export ${PRG}_O3=${DFILT}/${NJOB}_05_${IB}_ESTX7008_DETTRS.dat
	export ${PRG}_O4=${DFILT}/${NJOB}_05_${IB}_ESTX7008_FACCROSSREF.dat
	EXECPRG

else

	NSTEP=${NJOB}_05
	# Begin C Program
	#------------------------------------------------------------------------------
	LIBEL="Extraction des tables"
	PRG=ESTX7008
	export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_CTRCROSSREF.dat
	export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_CLMCROSSREF.dat
	export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_DETTRS.dat
	export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_FACCROSSREF.dat
	EXECPRG

fi

NSTEP=${NJOB}_07
# Sort binary file
#------------------------------------------------------------------------------
LIBEL="Sort of binary file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_ESTX7008_CTRCROSSREF.dat fixed 33"
SORT_I2="${DFILT}/${NJOB}_05_${IB}_ESTX7008_FACCROSSREF.dat fixed 33"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_TRTFACCROSSREF.dat
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
   CTR_NF	1 CHAR 10,
   SSD_CF	11 UINTEGER 1,
   DESTCTR_NF	12 CHAR 10,
   DESTSSD_CF 22 UINTEGER 1,
   ACCESB_CF  23 UINTEGER 1,
   DESTACCESB_CF  24 UINTEGER 1,
   LSTUPD_D	25 CHAR 9
/KEYS
   CTR_NF,
   SSD_CF,
   DESTCTR_NF,
   DESTSSD_CF,
   ACCESB_CF
exit
EOF
SORT

NSTEP=${NJOB}_08
# [04]
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort TL file according to subsidiary"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I="${DFILT}/${NJOB}_01_${IB}_GTA_TRANSFP.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GTA_TRANSFP.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF       1:1 - 1: EN,
        LIG_GT       2:1 - 41:,
        GT_CTR_NF    8:1 - 8:,
        SSD_EMET_CF 58:1 - 58: EN
/KEYS GT_CTR_NF
/OUTFILE ${SORT_O}
/REFORMAT SSD_EMET_CF, LIG_GT
exit
EOF
SORT

NSTEP=${NJOB}_10
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of TRANSFERTS from GTA.dat"
PRG=ESTM7001
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BLCSHT_D ${BLCSHT_D}
BALSHEY_NF ${BALSHEY_NF}
ESTIM_B ${ESTIM_B}
FORCEBILAN ${FORCEBILAN}
QTRLIM ${QTRLIM_NF}
TRANSFESB ${TRANSFESB}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_08_${IB}_GTA_TRANSFP.dat
export ${PRG}_I2=${DFILT}/${NJOB}_07_${IB}_SORT_TRTFACCROSSREF.dat
export ${PRG}_I3=${DFILT}/${NJOB}_05_${IB}_ESTX7008_CLMCROSSREF.dat
export ${PRG}_I4=${DFILT}/${NJOB}_05_${IB}_ESTX7008_DETTRS.dat
export ${PRG}_O1=${DFILI}/${NJOB}_GTA_TRANSFP.dat
export ${PRG}_O2=${DFILI}/${NJOB}_GTA_TRANSFP_EST.dat
export ${PRG}_O3=${DFILI}/${NJOB}_GTA_CTR_NOT_FOUND.dat
export ${PRG}_O4=${DFILI}/${NJOB}_GTA_CLM_NOT_FOUND_EST.dat
export ${PRG}_O5=${DFILI}/${NJOB}_GTA_RETCTR_EXCLUS.dat
EXECPRG

NSTEP=${NJOB}_13
# [03]
#-----------------------------------------------------------------------------
LIBEL="Sort TL file according to subsidiary"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I="${DFILT}/${NJOB}_02_${IB}_CURGTA_TRANSFP.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CURGTA_TRANSFP.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF       1:1 - 1: EN,
        LIG_GT       2:1 - 57:,
        GT_CTR_NF    8:1 - 8:,
        SSD_EMET_CF 58:1 - 58: EN
/KEYS GT_CTR_NF
/OUTFILE ${SORT_O}
/REFORMAT SSD_EMET_CF, LIG_GT
exit
EOF
SORT

NSTEP=${NJOB}_15
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of TRANSFERTS from CURGTA.dat"
PRG=ESTM7001
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BLCSHT_D ${BLCSHT_D}
BALSHEY_NF ${BALSHEY_NF}
ESTIM_B ${ESTIM_B}
FORCEBILAN ${FORCEBILAN}
QTRLIM ${QTRLIM_NF}
TRANSFESB ${TRANSFESB}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_13_${IB}_CURGTA_TRANSFP.dat
export ${PRG}_I2=${DFILT}/${NJOB}_07_${IB}_SORT_TRTFACCROSSREF.dat
export ${PRG}_I3=${DFILT}/${NJOB}_05_${IB}_ESTX7008_CLMCROSSREF.dat
export ${PRG}_I4=${DFILT}/${NJOB}_05_${IB}_ESTX7008_DETTRS.dat
export ${PRG}_O1=${DFILI}/${NJOB}_CURGTA_TRANSFP.dat
export ${PRG}_O2=${DFILI}/${NJOB}_CURGTA_TRANSFP_EST.dat
export ${PRG}_O3=${DFILI}/${NJOB}_CURGTA_CTR_NOT_FOUND.dat
export ${PRG}_O4=${DFILI}/${NJOB}_CURGTA_CLM_NOT_FOUND.dat
export ${PRG}_O5=${DFILI}/${NJOB}_CURGTA_RETCTR_EXCLUS.dat
EXECPRG

NSTEP=${NJOB}_18
# [03]
#-----------------------------------------------------------------------------
LIBEL="Sort TL file according to subsidiary"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I="${DFILT}/${NJOB}_03_${IB}_ARCSTATGTA_TRANSFP.dat  1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ARCSTATGTA_TRANSFP.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF       1:1 - 1: EN,
        LIG_GT       2:1 - 57:,
        GT_CTR_NF    8:1 - 8:,
        SSD_EMET_CF 58:1 - 58: EN
/KEYS GT_CTR_NF
/OUTFILE ${SORT_O}
/REFORMAT SSD_EMET_CF, LIG_GT
exit
EOF
SORT

NSTEP=${NJOB}_20
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of TRANSFERTS from ${PCH}ESIX7000_ARCSTATGTA.dat"
PRG=ESTM7001
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BLCSHT_D ${BLCSHT_D}
BALSHEY_NF ${BALSHEY_NF}
ESTIM_B ${ESTIM_B}
FORCEBILAN ${FORCEBILAN}
QTRLIM ${QTRLIM_NF}
TRANSFESB ${TRANSFESB}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_18_${IB}_ARCSTATGTA_TRANSFP.dat
export ${PRG}_I2=${DFILT}/${NJOB}_07_${IB}_SORT_TRTFACCROSSREF.dat
export ${PRG}_I3=${DFILT}/${NJOB}_05_${IB}_ESTX7008_CLMCROSSREF.dat
export ${PRG}_I4=${DFILT}/${NJOB}_05_${IB}_ESTX7008_DETTRS.dat
export ${PRG}_O1=${DFILI}/${NJOB}_ARCSTATGTA_TRANSFP.dat
export ${PRG}_O2=${DFILI}/${NJOB}_ARCSTATGTA_TRANSFP_EST.dat
export ${PRG}_O3=${DFILI}/${NJOB}_ARCSTATGTA_CTR_NOT_FOUND.dat
export ${PRG}_O4=${DFILI}/${NJOB}_ARCSTATGTA_CLM_NOT_FOUND.dat
export ${PRG}_O5=${DFILI}/${NJOB}_ARCSTATGTA_RETCTR_EXCLUS.dat
EXECPRG

NSTEP=${NJOB}_25
# Begin sort
#----------------------------------------------------------------------------
LIBEL="Extract GTA ==>  GTA CURGTA ARCSTATGTA "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILI}/${PCH}ESTD3010_ESTD3011_GTA_TRANSFP.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTA_O1.dat
SORT_O1=${DFILT}/${NSTEP}_${IB}_SORT_CURGTA_O1.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_ARCSTATGTA_O1.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF     1:1 - 1:,
        BALSHEY    3:1 - 3: EN,
	     BALSHTMTH  4:1 - 4: EN
/CONDITION PERIODE_GTA ( BALSHEY = ${BALSHEY_NF} and BALSHTMTH >= ${BALSHTMTH_NF} )
/CONDITION PERIODE_CURGTA ( BALSHEY = ${BALSHEY_NF} and BALSHTMTH < ${BALSHTMTH_NF} )
/CONDITION PERIODE_ARCSTATGTA ( BALSHEY < ${BALSHEY_NF} )
/OUTFILE ${SORT_O}
/INCLUDE PERIODE_GTA

/OUTFILE ${SORT_O1}
/INCLUDE PERIODE_CURGTA

/OUTFILE ${SORT_O2}
/INCLUDE PERIODE_ARCSTATGTA
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_30
# Begin sort
#----------------------------------------------------------------------------
LIBEL="Extract CURGTA ==>  CURGTA ARCSTATGTA "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILI}/${PCH}ESTD3010_ESTD3011_CURGTA_TRANSFP.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTA_O2.dat
SORT_O1=${DFILT}/${NSTEP}_${IB}_SORT_CURGTA_O2.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_ARCSTATGTA_O2.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF      1:1 - 1:,
        BALSHEY     3:1 - 3: EN,
	      BALSHTMTH  4:1 - 4: EN
/CONDITION PERIODE_GTA ( BALSHEY = ${BALSHEY_NF} and BALSHTMTH >= ${BALSHTMTH_NF} )
/CONDITION PERIODE_CURGTA ( BALSHEY = ${BALSHEY_NF} and BALSHTMTH < ${BALSHTMTH_NF} )
/CONDITION PERIODE_ARCSTATGTA ( BALSHEY < ${BALSHEY_NF} )
/OUTFILE ${SORT_O}
/INCLUDE PERIODE_GTA

/OUTFILE ${SORT_O1}
/INCLUDE PERIODE_CURGTA

/OUTFILE ${SORT_O2}
/INCLUDE PERIODE_ARCSTATGTA
/COPY
exit
EOF
SORT


NSTEP=${NJOB}_35
#
#-----------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
LIBEL="Append GTA Files "
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25_${IB}_SORT_GTA_O1.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_30_${IB}_SORT_GTA_O2.dat 1000 1"
SORT_O="${DFILI}/${PCH}ESTD3010_ESTD3011_GTA_AAJOUTER_TRANSFP.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF  8:1 - 8:,
        COLS1   1:1 - 41:,
        COLS2  56:1 - 57:
/DERIVEDFIELD PLUS_14_CHAMPS 14"~"
/KEYS CTR_NF
/OUTFILE ${SORT_O}
/REFORMAT COLS1, PLUS_14_CHAMPS, COLS2
exit
EOF
SORT

NSTEP=${NJOB}_40
#
#-----------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
LIBEL="Append CURGTA Files "
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25_${IB}_SORT_CURGTA_O1.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_30_${IB}_SORT_CURGTA_O2.dat 1000 1"
SORT_O="${DFILI}/${PCH}ESTD3010_ESTD3011_CURGTA_AAJOUTER_TRANSFP.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF  8:1 - 8:,
        COLS1   1:1 - 41:,
        COLS2  56:1 - 57:
/DERIVEDFIELD PLUS_14_CHAMPS 14"~"
/KEYS CTR_NF
/OUTFILE ${SORT_O}
/REFORMAT COLS1, PLUS_14_CHAMPS, COLS2
exit
EOF
SORT

#[05]
NSTEP=${NJOB}_45
# Merge new GTA file to P_ESIX7000_ARCSTATGTA.dat [03]
#------------------------------------------------------------------------------
LIBEL="Append ARCSTATGTA Files "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25_${IB}_SORT_ARCSTATGTA_O1.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_30_${IB}_SORT_ARCSTATGTA_O2.dat 1000 1"
SORT_I3="${DFILI}/${PCH}ESTD3010_ESTD3011_ARCSTATGTA_TRANSFP.dat 1000 1"
SORT_O="${DFILI}/${PCH}ESTD3010_ESTD3011_ARCSTATGTA_AAJOUTER_TRANSFP.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF 1:1 - 1:,
	ESB_CF 2:1 - 2:,
	BALSHEY_NF 3:1 - 3:,
	BALSHRMTH_NF 4:1 - 4:,
	BALSHRDAY_NF 5:1 - 5:,
	TRNCOD_CF 6:1 - 6:,
	TRNCOD1_CF 6:1 - 6:1,
	TRNCOD8_CF 6:8 - 6:8 EN ,
	DBLTRNCOD_CF 7:1 - 7:,
	CTR_NF 8:1 - 8:,
	END_NT 9:1 - 9:,
	SEC_NF 10:1 - 10:,
	UWY_NF 11:1 - 11:,
	UW_NT 12:1 - 12:,
	OCCYEA_NF 13:1 - 13:,
	ACY_NF 14:1 - 14:,
	SCOSTRMTH_NF 15:1 - 15:,
	SCOENDMTH_NF 16:1 - 16:,
	CLM_NF 17:1 - 17:,
	CUR_CF 18:1 - 18:,
	AMT_M 19:1 - 19:EN 15/3,
	CED_NF 20:1 - 20:,
	BRK_NF 21:1 - 21:,
	PAY_NF 22:1 - 22:,
	KEY_NF 23:1 - 23:,
	RETCTR_NF 24:1 - 24:,
	RETEND_NT 25:1 - 25:,
	RETSEC_NF 26:1 - 26:,
	RTY_NF 27:1 - 27:,
	RETUW_NT 28:1 - 28:,
	RETOCCYEA_NF 29:1 - 29:,
	RETACY_NF 30:1 - 30:,
	RETSCOSTRMTH_NF 31:1 - 31:,
	RETSCOENDMTH_NF 32:1 - 32:,
	RCL_NF 33:1 - 33:,
	RETCUR_CF 34:1 - 34:,
	RETAMT_M 35:1 - 35:EN 15/3,
	PLC_NT 36:1 - 36:,
	RTO_NF 37:1 - 37:,
	INT_NF 38:1 - 38:,
	RETPAY_NF 39:1 - 39:,
	RETKEY_CF 40:1 - 40:,
	RETINTAMT_M 41:1 - 41:EN 15/3,
	BUKRS_CF 42:1 - 42:,
	RCOMP_CF 43:1 - 43:,
	LDGRP_CF 44:1 - 44:,
	HKONT_CF 45:1 - 45:,
	DBLHKONT_CF 46:1 - 46:,
	GJAHR_NF 47:1 - 47:,
	MONAT_NF 48:1 - 48:,
	VBUND_CF 49:1 - 49:,
	ZZCED_NF 50:1 - 50:,
	SEGMENT_CF 51:1 - 51:,
	BEWAR_CF 52:1 - 52:,
	ZZGAAPDIF_CF 53:1 - 53:,
	BLART_CF 54:1 - 54:,
	ZZRECONKEY_CF 55:1 - 55:,
	TRN_NT 56:1 - 56:,
	FILETYP_CF 57:1 - 57:,
   COLS2  56:1 - 57:
/KEYS
	CTR_NF ,
	END_NT ,
	SEC_NF ,
	UWY_NF ,
	UW_NT ,
	OCCYEA_NF ,
	ACY_NF ,
	SCOSTRMTH_NF ,
	SCOENDMTH_NF ,
	CLM_NF,
	CUR_CF,
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF ,
	RETUW_NT,
	SSD_CF ,
	ESB_CF ,
	BALSHEY_NF,
	TRNCOD_CF,
	DBLTRNCOD_CF ,
	CED_NF ,
	BRK_NF ,
	PAY_NF ,
	KEY_NF ,
	RETOCCYEA_NF ,
	RETACY_NF ,
	RETSCOSTRMTH_NF ,
	RETSCOENDMTH_NF ,
	RCL_NF ,
	RETCUR_CF ,
	PLC_NT ,
	RTO_NF ,
	INT_NF ,
	RETPAY_NF ,
	RETKEY_CF
/DERIVEDFIELD PLUS_14_CHAMPS 14"~"
/SUMMARIZE  TOTAL AMT_M , TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF, END_NT , SEC_NF, UWY_NF, UW_NT,
          OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_MC, CED_NF, BRK_NF, PAY_NF, KEY_NF, RETCTR_NF,
          RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF,
          RETCUR_CF, RETAMT_MC, PLC_NT, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, RETINTAMT_MC, PLUS_14_CHAMPS, COLS2
exit
EOF
SORT

NSTEP=${NJOB}_50
# Accumulation of GTAA + GTAR amounts and merge with STATGTA [03]
#------------------------------------------------------------------------------
LIBEL="Accumulation of GTAA  merge with STATGTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25_${IB}_SORT_CURGTA_O1.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_30_${IB}_SORT_CURGTA_O2.dat 1000 1"
SORT_O="${DFILI}/${PCH}ESTD3010_ESTD3011_STATGTA_TRANSFP.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
        SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
          TRNCOD1_CF 6:1 - 6:1,
          TRNCOD8_CF 6:8 - 6:8,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19:EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41:EN 15/3,
        PLUS_13_CHAMPS  42:1 - 54:,
        KeyReconciliation  55:1 - 55:,
        PLUS_2_CHAMPS 56:1 - 57:
/KEYS
        CTR_NF ,
        END_NT ,
        SEC_NF ,
        UWY_NF ,
        UW_NT ,
        OCCYEA_NF ,
        ACY_NF ,
        SCOSTRMTH_NF ,
        SCOENDMTH_NF ,
        CLM_NF,
        CUR_CF,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF ,
        RETUW_NT,
        SSD_CF ,
        ESB_CF ,
        BALSHEY_NF,
        TRNCOD_CF,
        DBLTRNCOD_CF ,
        CED_NF ,
        BRK_NF ,
        PAY_NF ,
        KEY_NF ,
        RETOCCYEA_NF ,
        RETACY_NF ,
        RETSCOSTRMTH_NF ,
        RETSCOENDMTH_NF ,
        RCL_NF ,
        RETCUR_CF ,
        PLC_NT ,
        RTO_NF ,
        INT_NF ,
        RETPAY_NF ,
        RETKEY_CF,
        KeyReconciliation
/SUMMARIZE  TOTAL AMT_M , TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF,
          CTR_NF, END_NT , SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF,
          CLM_NF, CUR_CF, AMT_MC, CED_NF, BRK_NF, PAY_NF, KEY_NF, RETCTR_NF, RETEND_NT, RETSEC_NF,
          RTY_NF, RETUW_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, RETCUR_CF,
          RETAMT_MC, PLC_NT, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, RETINTAMT_MC, PLUS_13_CHAMPS, KeyReconciliation, PLUS_2_CHAMPS

exit
EOF
SORT

if [ ${TRANSFESB} = "0" ]             # pas transfert etablissement
then

	NSTEP=${NJOB}_55
	# filling TACCSTAT table
	#--------------------------------
	LIBEL="filling TACCSTAT table"
	BCP_WAY="IN"
	BCP_VER=""
	BCP_I=${DFILT}/${NJOB}_00_${IB}_TACCSTAT_TRANSFP.dat
	BCP_TABLE="BEST..TACCSTAT"
	BCP

	NSTEP=${NJOB}_60
	# Begin ISQL
	#------------------------------------------------------------------------------
	LIBEL="Update TRFACCSTS_CT = 36 apres TRANSFERTS"
	ISQL_BASE="BTRT"
	ISQL_QRY="update BTRT..TRFCROSSREF
	             set TRFACCSTS_CT = 36
	          from BTRT..TRFCROSSREF where TRFSTS_CT = 3  AND TRFACCSTS_CT = 34"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
	ISQL

	NSTEP=${NJOB}_65
	# Begin ISQL
	#------------------------------------------------------------------------------
	LIBEL="Update TRFACCSTS_CT = 36 apres TRANSFERTS"
	ISQL_BASE="BFAC"
	ISQL_QRY="update BFAC..TRFCROSSREF
	             set TRFACCSTS_CT = 36
	          from BFAC..TRFCROSSREF where TRFSTS_CT = 3  AND TRFACCSTS_CT = 34"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
	ISQL

else

	NSTEP=${NJOB}_70
	# Begin ISQL
	#------------------------------------------------------------------------------
	LIBEL="Update TRFACCSTS_CT = 46 apres TRANSFERTS"
	ISQL_BASE="BTRT"
	ISQL_QRY="update BTRT..TRFCROSSREF
	             set TRFACCSTS_CT = 46
	          from BTRT..TRFCROSSREF where TRFSTS_CT = 14  AND TRFACCSTS_CT = 44"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
	ISQL

	NSTEP=${NJOB}_75
	# Begin ISQL
	#------------------------------------------------------------------------------
	LIBEL="Update TRFACCSTS_CT = 46 apres TRANSFERTS"
	ISQL_BASE="BFAC"
	ISQL_QRY="update BFAC..TRFCROSSREF
	             set TRFACCSTS_CT = 46
             from BFAC..TRFCROSSREF where TRFSTS_CT = 14  AND TRFACCSTS_CT = 44"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
	ISQL

fi

NSTEP=${NJOB}_80
# delete old temporary Data files
#---------------------------------------------------------------
LIBEL="delete old temporary Data files"
#RMFIL "${DFILT}/${NJOB}*_${IB}*.dat"

JOBEND
