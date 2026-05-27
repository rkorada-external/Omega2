#!/bin/ksh
#=============================================================================
# maj de l'application:           ESTIMATIONS - TRANSFERT INTER-SITES (PORTEFEUILLES)
# nom du script SHELL:            ESTD3060.cmd
# revision:                       $Revision: 1.1.1.1 $
# date de creation:               10/02/2009
# auteur:                         J.Ribot
# references des specifications : :spot:16765
#-----------------------------------------------------------------------------
# description
#
# generation entrees portefeuilles
#
#-----------------------------------------------------------------------------
# historiques des modifications :
# [01] 05/06/2009 Roger Cassis :spot:17532 Si statuts pas positionnes correctement, arret de la chaine
# [02] 17/11/2009 Roger Cassis :spot:18415 Copie reconduction emetteur en date 01/01 puis annulation 02/01 pour contrats Vie parm VIE_B
#                                           Ajout transfert fichier vie LIFSTAREP_PLAN
# [03] 04/02/2009 Roger Cassis :spot:18937 Si Transfert Etablissement et Vie, on ne fait pas la reconduction ci-dessus - ajout parametre TRANSFESB
#                                           dans ESTM7007
# [04] 06/07/2011 Florent      :spot:22328 ajout de 16 champs dans le GTA
# [05] 19/08/2015 Roger Cassis :spot:29223 Correction du reformat du STATGTA
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
VIE_B=${8}

# Initialization of the Job
JOBINIT

ECHO_LOG "=> VIE_B......... = ${VIE_B}"  2>&1 | ${TEE}

NSTEP=${NJOB}_00
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Check if data to transfer exist"
ISQL_BASE="BTRT"
ISQL_QRY="set rowcount 2
          select * from BTRT..TRFCROSSREF
          where  (TRFACCSTS_CT = 36 and TRFSTS_CT = 3) OR (TRFACCSTS_CT = 46 and TRFSTS_CT = 14)
          UNION
          select * from BFAC..TRFCROSSREF
          where  (TRFACCSTS_CT = 36 and TRFSTS_CT = 3) OR (TRFACCSTS_CT = 46 and TRFSTS_CT = 14)"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.log
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat
ISQL_NOWARNING="YES"
ISQL_RES

if [ ! -s ${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat ]
then
  ECHO_LOG "---> No Data to process because Crossref statuts are not set right"
  STEPEND 1
fi

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
LIBEL="Get files LIFSTAREP_PLAN from directories and merge them"
GET_FILES_DIR=${REMOTE_SITE}
GET_FILES_PREFIX=${EXTCHAIN}_*_LIFSTAREP_PLAN
GET_FILES_MERGE="YES"
GET_FILES_O=${DFILT}/${NSTEP}_${IB}_LIFSTAREP_PLAN_TRANSFP.dat
GET_FILES

if [ ${TRANSFESB} = "1" ]             # transfert etablissement
then

	NSTEP=${NJOB}_04
	# Begin C Program
	#------------------------------------------------------------------------------
	LIBEL="Extraction des tables"
	PRG=ESTX7019
	export ${PRG}_O1=${DFILT}/${NJOB}_05_${IB}_ESTX7010_CTRCROSSREF.dat
	export ${PRG}_O2=${DFILT}/${NJOB}_05_${IB}_ESTX7010_CLMCROSSREF.dat
	export ${PRG}_O3=${DFILT}/${NJOB}_05_${IB}_ESTX7010_DETTRS.dat
	export ${PRG}_O4=${DFILT}/${NJOB}_05_${IB}_ESTX7010_FACCROSSREF.dat
	EXECPRG

else

	NSTEP=${NJOB}_05
	# Begin C Program
	#------------------------------------------------------------------------------
	LIBEL="Extraction des tables"
	PRG=ESTX7010
	export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_CTRCROSSREF.dat
	export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_CLMCROSSREF.dat
	export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_DETTRS.dat
	export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_FACCROSSREF.dat
	EXECPRG

fi

if [ ${VIE_B} = "1" ]  &&
   [ -s ${DFILT}/${NJOB}_03_${IB}_LIFSTAREP_PLAN_TRANSFP.dat ]
then

	NSTEP=${NJOB}_06
	#
	#-----------------------------------------------------------------------------
	SORT_WDIR=${SORTWORK}
	LIBEL="OMIT subsidiary in column 1 of TLIFSTAREP_PLAN file "
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${NJOB}_03_${IB}_LIFSTAREP_PLAN_TRANSFP.dat 1000 1"
	SORT_O="${DFILI}/${NJOB}_LIFSTAREP_PLAN_TRANSFP.dat OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 -  1:,
        RESTE  2:1 - 34:
/KEYS SSD_CF
/OUTFILE ${SORT_O}
/REFORMAT RESTE
exit
EOF
	SORT

fi
NSTEP=${NJOB}_07
# Sort binary file
#------------------------------------------------------------------------------
LIBEL="Sort of binary file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_ESTX7010_CTRCROSSREF.dat fixed 33"
SORT_I2="${DFILT}/${NJOB}_05_${IB}_ESTX7010_FACCROSSREF.dat fixed 33"
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

NSTEP=${NJOB}_10
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Extraction des tables des postes a transformer"
PRG=ESTX7012
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_PTF.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_CTPE.dat
EXECPRG

NSTEP=${NJOB}_15
# [04]
#-----------------------------------------------------------------------------
LIBEL="Sort TL file according to subsidiary"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I="${DFILT}/${NJOB}_01_${IB}_GTA_TRANSFP.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTA.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF       1:1 -  1: EN,
        LIG_GT       2:1 - 57:,
        GT_CTR_NF    8:1 -  8:,
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
LIBEL="Generation of TRANSFERTS from GTA.dat"
PRG=ESTM7007
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BLCSHT_D ${BLCSHT_D}
BALSHEY_NF ${BALSHEY_NF}
ESTIM_B ${ESTIM_B}
FORCEBILAN ${FORCEBILAN}
QTRLIM ${QTRLIM_NF}
VIE ${VIE_B}
TRANSFESB ${TRANSFESB}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_15_${IB}_SORT_GTA.dat
export ${PRG}_I2=${DFILT}/${NJOB}_07_${IB}_SORT_TRTFACCROSSREF.dat
export ${PRG}_I3=${DFILT}/${NJOB}_05_${IB}_ESTX7010_CLMCROSSREF.dat
export ${PRG}_I4=${DFILT}/${NJOB}_05_${IB}_ESTX7010_DETTRS.dat
export ${PRG}_I5=${DFILT}/${NJOB}_10_${IB}_ESTX7012_PTF.dat
export ${PRG}_I6=${DFILT}/${NJOB}_10_${IB}_ESTX7012_CTPE.dat
export ${PRG}_O1=${DFILI}/${NJOB}_GTA_TRANSFP_ENTREE.dat
EXECPRG

NSTEP=${NJOB}_25
# [04]
#-----------------------------------------------------------------------------
LIBEL="Sort TL file according to subsidiary"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I="${DFILT}/${NJOB}_02_${IB}_CURGTA_TRANSFP.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CURGTA.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF       1:1 -  1: EN,
        LIG_GT       2:1 - 57:,
        GT_CTR_NF    8:1 -  8:,
        SSD_EMET_CF 58:1 - 58: EN
/KEYS GT_CTR_NF
/OUTFILE ${SORT_O}
/REFORMAT SSD_EMET_CF, LIG_GT
exit
EOF
SORT

NSTEP=${NJOB}_30
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of TRANSFERTS from CURGTA.dat"
PRG=ESTM7007
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BLCSHT_D ${BLCSHT_D}
BALSHEY_NF ${BALSHEY_NF}
ESTIM_B ${ESTIM_B}
FORCEBILAN ${FORCEBILAN}
QTRLIM ${QTRLIM_NF}
VIE ${VIE_B}
TRANSFESB ${TRANSFESB}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_25_${IB}_SORT_CURGTA.dat
export ${PRG}_I2=${DFILT}/${NJOB}_07_${IB}_SORT_TRTFACCROSSREF.dat
export ${PRG}_I3=${DFILT}/${NJOB}_05_${IB}_ESTX7010_CLMCROSSREF.dat
export ${PRG}_I4=${DFILT}/${NJOB}_05_${IB}_ESTX7010_DETTRS.dat
export ${PRG}_I5=${DFILT}/${NJOB}_10_${IB}_ESTX7012_PTF.dat
export ${PRG}_I6=${DFILT}/${NJOB}_10_${IB}_ESTX7012_CTPE.dat
export ${PRG}_O1=${DFILI}/${NJOB}_CURGTA_TRANSFP_ENTREE.dat
EXECPRG

# ajout step tri gt

NSTEP=${NJOB}_35
# Begin sort
#----------------------------------------------------------------------------
LIBEL="Extract GTA ==>  GTA CURGTA "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILI}/${PCH}ESTD3060_ESTD3061_GTA_TRANSFP_ENTREE.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTA_O1.dat
SORT_O1=${DFILT}/${NSTEP}_${IB}_SORT_CURGTA_O1.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF     1:1 - 1:,
        BALSHEY    3:1 - 3: EN,
	     BALSHTMTH  4:1 - 4: EN
/CONDITION PERIODE_GTA ( BALSHEY = ${BALSHEY_NF} and BALSHTMTH >= ${BALSHTMTH_NF} )
/CONDITION PERIODE_CURGTA ( BALSHEY = ${BALSHEY_NF} and BALSHTMTH < ${BALSHTMTH_NF} )
/OUTFILE ${SORT_O}
/INCLUDE PERIODE_GTA
/OUTFILE ${SORT_O1}
/INCLUDE PERIODE_CURGTA
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_40
# Begin sort
#----------------------------------------------------------------------------
LIBEL="Extract CURGTA ==>  CURGTA "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILI}/${PCH}ESTD3060_ESTD3061_CURGTA_TRANSFP_ENTREE.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTA_O2.dat
SORT_O1=${DFILT}/${NSTEP}_${IB}_SORT_CURGTA_O2.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF      1:1 - 1:,
        BALSHEY     3:1 - 3: EN,
	      BALSHTMTH  4:1 - 4: EN
/CONDITION PERIODE_GTA ( BALSHEY = ${BALSHEY_NF} and BALSHTMTH >= ${BALSHTMTH_NF} )
/CONDITION PERIODE_CURGTA ( BALSHEY = ${BALSHEY_NF} and BALSHTMTH < ${BALSHTMTH_NF} )
/OUTFILE ${SORT_O}
/INCLUDE PERIODE_GTA
/OUTFILE ${SORT_O1}
/INCLUDE PERIODE_CURGTA
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_45
#
#-----------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
LIBEL="Append GTA Files "
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_35_${IB}_SORT_GTA_O1.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_40_${IB}_SORT_GTA_O2.dat 1000 1"
SORT_O="${DFILI}/${PCH}ESTD3060_ESTD3061_GTA_AAJOUTER_TRANSFP_ENTREE.dat 1000 1"
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

NSTEP=${NJOB}_50
#
#-----------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
LIBEL="Append CURGTA Files "
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_35_${IB}_SORT_CURGTA_O1.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_40_${IB}_SORT_CURGTA_O2.dat 1000 1"
SORT_O="${DFILI}/${PCH}ESTD3060_ESTD3061_CURGTA_AAJOUTER_TRANSFP_ENTREE.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 8:1 - 8:
/KEYS CTR_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_55
# STATGTA  [04] [05]
#------------------------------------------------------------------------------
LIBEL="STATGTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILI}/${PCH}ESTD3060_ESTD3061_CURGTA_AAJOUTER_TRANSFP_ENTREE.dat 1000 1"
SORT_O="${DFILI}/${PCH}ESTD3060_ESTD3061_STATGTA_AAJOUTER_TRANSFP_ENTREE.dat 1000 1"
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

# fin ajout step tri GT

if [ ${TRANSFESB} = "0" ]             # pas transfert etablissement
then

	# mise a jour site recepteur

	NSTEP=${NJOB}_60
	# Begin ISQL
	#------------------------------------------------------------------------------
	LIBEL="Update TRFACCSTS_CT = 51 apres TRANSFERTS"
	ISQL_BASE="BTRT"
	ISQL_QRY="update BTRT..TRFCROSSREF
	             set TRFACCSTS_CT = 51
             from BTRT..TRFCROSSREF where TRFSTS_CT = 3  AND TRFACCSTS_CT = 36"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
	ISQL

	NSTEP=${NJOB}_65
	# Begin ISQL
	#------------------------------------------------------------------------------
	LIBEL="Update TRFACCSTS_CT = 51 apres TRANSFERTS"
	ISQL_BASE="BFAC"
	ISQL_QRY="update BFAC..TRFCROSSREF
	             set TRFACCSTS_CT = 51
	          from BFAC..TRFCROSSREF where TRFSTS_CT = 3  AND TRFACCSTS_CT = 36"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
	ISQL

	# mise a jour site emetteur

	NSTEP=${NJOB}_70
	# Begin ISQL
	#------------------------------------------------------------------------------
	LIBEL="Update TRFACCSTS_CT = 51 apres TRANSFERTS"
	ISQL_BASE="BTRT"
	ISQL_QRY="update BTRT..TRFCROSSREF
	             set TRFACCSTS_CT = 51
	          from BTRT..TRFCROSSREF where TRFSTS_CT = 2 AND TRFACCSTS_CT = 24"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
	ISQL

	NSTEP=${NJOB}_75
	# Begin ISQL
	#------------------------------------------------------------------------------
	LIBEL="Update TRFACCSTS_CT = 51 apres TRANSFERTS"
	ISQL_BASE="BFAC"
	ISQL_QRY="update BFAC..TRFCROSSREF
	             set TRFACCSTS_CT = 51
	          from BFAC..TRFCROSSREF where TRFSTS_CT = 2  AND TRFACCSTS_CT = 24"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
	ISQL

else

	NSTEP=${NJOB}_80
	# Begin ISQL
	#------------------------------------------------------------------------------
	LIBEL="Update TRFACCSTS_CT = 51 apres TRANSFERTS"
	ISQL_BASE="BTRT"
	ISQL_QRY="update BTRT..TRFCROSSREF
	             set TRFACCSTS_CT = 51
	          from BTRT..TRFCROSSREF where TRFSTS_CT = 14  AND TRFACCSTS_CT = 46"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
	ISQL

	NSTEP=${NJOB}_85
	# Begin ISQL
	#------------------------------------------------------------------------------
	LIBEL="Update TRFACCSTS_CT = 51 apres TRANSFERTS"
	ISQL_BASE="BFAC"
	ISQL_QRY="update BFAC..TRFCROSSREF
	             set TRFACCSTS_CT = 51
	          from BFAC..TRFCROSSREF where TRFSTS_CT = 14  AND TRFACCSTS_CT = 46"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
	ISQL

fi

NSTEP=${NJOB}_90
# delete old temporary Data files
#---------------------------------------------------------------
LIBEL="delete old temporary Data files"
RMFIL "${DFILT}/${NJOB}*_${IB}*.dat"

JOBEND

# si "${CREATION_GT}" = 0 on prend les 2 fichiers car on ne genere pas de GTA

NSTEP=${NJOB}_60
# Begin sort
#----------------------------------------------------------------------------
LIBEL="Split GTA/CURGTA ==>  GTAA "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILI}/${PCH}ESTD3050_ESTD3053_CURGTA_TRANSFP.dat 1000 1"
if [ "${CREATION_GT}" = 0 ]
then
SORT_I2="${DFILI}/${PCH}ESTD3050_ESTD3053_GTA_TRANSFP.dat 1000 1"
fi
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAA_O1.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF 1:1 - 1:,
        BALSHEY  3:1 - 3: EN,
	BALSHTMTH  4:1 - 4: EN,
	TRNCOD_CF 6:1 - 6:,
	TRNCOD1_CF 6:1 - 6:1 ,
	TRNCOD2C_CF 6:2 - 6:2 ,
	TRNCOD8_CF 6:8 - 6:8 EN
/CONDITION AVANT_PERIODE_ACC ( BALSHEY = ${BALSHEY_NF} and BALSHTMTH <= ${BALSHTMTH_NF} ) AND
				( TRNCOD1_CF = "1" or TRNCOD1_CF = "3") AND
				( TRNCOD8_CF  = 0 or TRNCOD8_CF  = 1 )
/OUTFILE ${SORT_O}
/INCLUDE AVANT_PERIODE_ACC
/COPY
exit
EOF
SORT


NSTEP=${NJOB}_65
# Accumulation of GTAA + GTAR amounts and merge with STATGTA [04] [05]
#------------------------------------------------------------------------------
LIBEL="Accumulation of GTAA  merge with STATGTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_60_${IB}_SORT_GTAA_O1.dat
SORT_O="${DFILI}/${PCH}ESTD3050_ESTD3053_STATGTA_TRANSFP.dat 1000 1"
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


NSTEP=${NJOB}_70
# delete old temporary Data files
#---------------------------------------------------------------
LIBEL="delete old temporary Data files"
RMFIL "${DFILT}/${NJOB}*_${IB}*.dat"

JOBEND

