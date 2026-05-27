#!/bin/ksh
#=============================================================================
# nom de l'application          :
# nom du script SHELL           : ESID8041.cmd
# revision                      : 
# date de creation              : 03/08/2015
# auteur                        : GBO
# references des specifications :
#-----------------------------------------------------------------------------
# description : generation and export in Sql of Gap for EST26B.
#
# start by ESID8040.cmd.
#
#
#   ENTER :
#
#     EST_CMPCALC
#     EST_FSUBTRS
#     EST_TGAPTHR
#
#   EXIT :
#
#     EST_NOTIFICATIONS
#     EST_GAP_GT_LIFEST
#
#-----------------------------------------------------------------------------
# historique des modifications :
# [001] 22/12/2015 MBO ESTC26B ajout différenciation a1 a2 à propos de la date
# [002] 13/01/2016 MBO Spot 29095, Spira 44533, uncomment une partie de requete SQL ce qui permet d'avoir les filliales des nouveaux écarts du jour
# [003] 08/03/2016 MBO SPOT 30277, pas de Spira, suppression fichier TMP
# [004] 21/04/2016 MMA Spot 30506  SPIRA 45213  Correction de l'identification interne de la notification
#                                  AVANT : SSD/ESB/UWGRP  => APRES : SSD/ESB/CTR/SEC/UWY/UWGRP
# [005] 13/04/2016 MMA SPOT 31090  SPIRA 048161 Révision de l'identification externe de la notification
#                                  AVANT : SSD/ESB/UWGRP  => APRES : SSD/ESB/CTR/SEC/UWGRP
# [006] 16/11/2016 MMA SPIRA 57349: Les «to be checked” (GAPSTS_NT = 2) de la version N seront remplacés par les “to be checked » de la version N+1
#                                   lorsqu’ils ne sont pas en tous points identiques.
# [007] 23/11/2016 MMA SPIRA 57378: Correction sur le tri du fichier de seuil et le CMPCALC afin de corriger les erreurs de rupture dans l'ESTC8040
# [008] 13/12/2016 MMA SPIRA 57351: MAJ du statut de la notif et ajout d'un commantaire pour les ecarts EXCPRO
#                                   qui n'excède plus le seuil ou pour les écarts n'existant plus.
# [009] 19/01/2017 MMA SPIRA 58705 Correction UPDATE
# [010] 28/10/2020 BEL SPIRA 77541 Renvoi de notifications si l'ecart date des trimestres davants.
# [011] 04/01/2021 BEL SPIRA 91871  Delete from TACCEXCPRO table all row with ACY_NF < BALSHYEA - 2.
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd
. ${DUTI}/fctws.cmd



# Get input parameters

set -x
MODE=$1
CLODAT_D=$2
DATE=$3
VAC_NT=$4
BALSHTYEA_NF=$5
set +x


# Job Initialisation
JOBINIT

NSTEP=${NJOB}_010
# Sort CMPCALC
# [007]
#------------------------------------------------------------------------------

LIBEL="Sort CMPCALC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
set -x
SORT_I="${EST_CMPCALC} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CMPCALC.dat"
set +x
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: ,
        ESB_CF 2:1 - 2: ,
        CUR_CF 9:1 - 9:
/KEYS SSD_CF,
      ESB_CF
exit
EOF
SORT

  NSTEP=${NJOB}_025
  # Sort TGAPTHR into TSEUIL
  # [007]
  #------------------------------------------------------------------------------
  LIBEL="Sort TGAPTHR into TSEUIL"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  set -x
  SORT_I="${EST_TGAPTHR}"
  SORT_O="${DFILT}/${NSTEP}_${IB}_TSEUIL.dat"
  set +x
  INPUT_TEXT ${SORT_CMD} <<EOF
  /FIELDS SSD_CF 1:1 - 1: ,
          ESB_CF 2:1 - 2: ,
          CUR_CF 3:1 - 3:
  /KEYS SSD_CF,
        ESB_CF
  exit
EOF
  SORT


  NSTEP=${NJOB}_050
  # execute ESTC8040
  #------------------------------------------------------------------------------
 
  LIBEL="Apply tresholds"
  PRG=ESTC8040
  FPRM=`CFTMP`
  INPUT_TEXT ${FPRM} <<EOF
  MODE ${MODE}
  CLODAT_D ${CLODAT_D}
  DATE ${DATE}
  VAC_NT ${VAC_NT}
  exit
EOF
  set -x
  export ${PRG}_PRM=${FPRM}
  export ${PRG}_I1=${DFILT}/${NJOB}_010_${IB}_CMPCALC.dat
  export ${PRG}_I2=${DFILT}/${NJOB}_025_${IB}_TSEUIL.dat
  export ${PRG}_I3=/dev/null
  export ${PRG}_I4=${EST_FCURQUOT}
  export ${PRG}_I5=${EST_SUBTRS}
  export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_GAP_GT_LIFEST.dat
  export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_ANOFILE.dat
  export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_NOTIF.dat
  set +x
  EXECPRG
  # cd $DEXE 
  # debugV2 $PRG

NSTEP=${NJOB}_80
# Supprime les lignes de jour (en cas de relance du job)
#------------------------------------------------------------------------------
# voir la table a changer, pas la BREF..TBATCHSSD mais BTRAV..TESTSSD, AND b.BATCHUSER_CF = suser_name() doit disparaitre
LIBEL="Supprime les lignes de jour dans la table TACCEXCPRO"
ISQL_QRY="DELETE FROM BEST..TACCEXCPRO FROM BEST..TACCEXCPRO a, BTRAV..TESTSSD b WHERE a.SSD_CF = b.SSD_CF AND GAP_D='${DATE}'"
ISQL_BASE='BEST'
ISQL


##[011]
NSTEP=${NJOB}_90
# Delete from TACCEXCPRO table all row with ACY_NF < BALSHYEA - 2
#------------------------------------------------------------------------------
LIBEL="purge of BEST..TACCEXCPRO"
ISQL_BASE='BEST'
ISQL_QRY=`CFTMP`
INPUT_TEXT ${ISQL_QRY} <<EOF
declare @lignes int, @erreur int
set rowcount 50000
select @lignes = 1, @erreur = 0
WHILE @lignes > 0
BEGIN
	BEGIN TRAN
	DELETE BEST..TACCEXCPRO
	WHERE ACY_NF <  ${BALSHTYEA_NF}-2
	select @erreur = @@error , @lignes = @@rowcount
	if @erreur != 0
	BEGIN
		ROLLBACK TRAN
		BREAK
	END
	COMMIT TRAN
END
set rowcount 0
go
exit
EOF
ISQL


NSTEP=${NJOB}_100
# Do BCPIN
#------------------------------------------------------------------------------
LIBEL="filling TACCEXCPRO table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_050_${IB}_GAP_GT_LIFEST.dat
BCP_TRUNCATE=NO
BCP_UPDATE_INDEX_STAT=YES
BCP_TABLE="BEST..TACCEXCPRO"
BCP

NSTEP=${NJOB}_140
# Inserting LSTUPDUSR from TACCTRN into TACCEXCPRO
#------------------------------------------------------------------------------
LIBEL="Inserting LSTUPDUSR from TACCTRN into TACCEXCPRO"
ISQL_QRY="execute BEST..PuACCEXCPRO_LSTUPDUSR"
ISQL_BASE='BEST'
ISQL

NSTEP=${NJOB}_142
# [006] Les «to be checked” (GAPSTS_NT = 2) de la version N seront remplacés par les “to be checked » de la version N+1 lorsqu’ils ne sont pas en tous points identiques.
#------------------------------------------------------------------------------
LIBEL="Uniq"
ISQL_QRY="DELETE FROM BEST..TACCEXCPRO FROM BEST..TACCEXCPRO a1,  BEST..TACCEXCPRO a2, BTRAV..TESTSSD b
WHERE a1.SSD_CF     = a2.SSD_CF
AND a1.ESB_CF       = a2.ESB_CF
AND a1.CTR_NF       = a2.CTR_NF
AND a1.SEC_NF       = a2.SEC_NF
AND a1.UWY_NF       = a2.UWY_NF 
AND a1.ACY_NF       = a2.ACY_NF
AND a1.DETTRNCOD_CF = a2.DETTRNCOD_CF
AND (a1.ACCMNT_M    != a2.ACCMNT_M   OR  a1.ESTMNT_M  !=  a2.ESTMNT_M OR a1.LSTUPDUSR_CF != a2.LSTUPDUSR_CF)
AND a1.CUR_CF       = a2.CUR_CF
AND a1.GAPSTS_NT    = a2.GAPSTS_NT
AND a2.GAPSTS_NT    = 2
AND a2.GAP_D        = '${DATE}'
AND a1.SSD_CF       = b.SSD_CF
AND a2.GAP_D        > a1.GAP_D"
ISQL_BASE='BEST'
ISQL


NSTEP=${NJOB}_143
# [008] MAJ du statut et de la GAP_D de la notif pour les ecarts EXCPRO
#       qui n'excède plus le seuil ou pour les écarts n'existant plus
# [009] a2.GAP_D = '${DATE} 00:00:01' => a1.GAP_D = '${DATE} 00:00:01'
#------------------------------------------------------------------------------
LIBEL="Uniq"
ISQL_QRY="UPDATE BEST..TACCEXCPRO 
set a1.GAPSTS_NT = 0,
a1.GAP_D = '${DATE} 00:00:01'
FROM  BEST..TACCEXCPRO a1, BTRAV..TESTSSD b
WHERE NOT EXISTS ( SELECT 1 
                  FROM BEST..TACCEXCPRO a2 
                  WHERE a1.SSD_CF     = a2.SSD_CF
                  AND a1.ESB_CF       = a2.ESB_CF
                  AND a1.CTR_NF       = a2.CTR_NF
                  AND a1.SEC_NF       = a2.SEC_NF
                  AND a1.UWY_NF       = a2.UWY_NF
                  AND a1.ACY_NF       = a2.ACY_NF
                  AND a1.DETTRNCOD_CF = a2.DETTRNCOD_CF
                  AND a1.CUR_CF       = a2.CUR_CF
                  AND a1.GAPSTS_NT    = a2.GAPSTS_NT
                  AND a2.GAPSTS_NT    = 2
                  AND a2.GAP_D = '${DATE}')
AND a1.SSD_CF       = b.SSD_CF
AND a1.GAPSTS_NT    = 2
and a1.ACY_NF > ${BALSHTYEA_NF}-2"
ISQL_BASE='BEST'
ISQL


NSTEP=${NJOB}_145
# Lorsque deux écarts sont en tout points identiques on conserve le plus ancien
# [001] 22/12/2015 MBO ESTC26B ajout différenciation a1 a2 à propos de la date
#------------------------------------------------------------------------------
LIBEL="Uniq"
ISQL_QRY="DELETE FROM BEST..TACCEXCPRO FROM BEST..TACCEXCPRO a1,  BEST..TACCEXCPRO a2, BTRAV..TESTSSD b
  WHERE a1.SSD_CF     = a2.SSD_CF
  AND a1.ESB_CF       = a2.ESB_CF
  AND a1.LSTUPDUSR_CF = a2.LSTUPDUSR_CF
  AND a1.CTR_NF       = a2.CTR_NF
  AND a1.SEC_NF       = a2.SEC_NF
  AND a1.UWY_NF       = a2.UWY_NF
  AND a1.ACY_NF       = a2.ACY_NF
  AND a1.DETTRNCOD_CF = a2.DETTRNCOD_CF
  AND a1.ACCMNT_M     = a2.ACCMNT_M
  AND a1.ESTMNT_M     = a2.ESTMNT_M
  AND a1.DIFFMNT_M    = a2.DIFFMNT_M
  AND a1.CUR_CF       = a2.CUR_CF 
  AND a1.SSD_CF       = b.SSD_CF
  AND a1.GAP_D        = '${DATE}'
  AND a2.GAP_D       != a1.GAP_D"
ISQL_BASE='BEST'
ISQL


# INSERT THE NEW CODE HERE [010]
#------------------------------------------------------------------------------
NSTEP=${NJOB}_145B
# Update GAP_D of each Gap with "to_be_checked" status to today date 
# for sinding a new NOTIFICATION, if is a previouse quarter gap
#------------------------------------------------------------------------------
LIBEL="Update GAP_D to today date for sinding a new NOTIFICATION"
ISQL_QRY="UPDATE BEST..TACCEXCPRO
    set GAP_D = '${DATE}'
  FROM BEST..TACCEXCPRO a1, BTRAV..TESTSSD b
  WHERE a1.GAPSTS_NT    = 2
  AND( year(a1.GAP_D)  < year('${DATE}')
       OR ( year(a1.GAP_D) = year('${DATE}')        
            AND month(a1.GAP_D) < case 
                                   when (month('${DATE}') between  4 and  6) then  4
                                   when (month('${DATE}') between  7 and  9) then  7
                                   when (month('${DATE}') between 10 and 12) then 10
                                  end 
          )
     )
  AND a1.SSD_CF     = b.SSD_CF"
ISQL_BASE='BEST'
ISQL
#------------------------------------------------------------------------------
# END OF NEW CODE [010]


NSTEP=${NJOB}_146
# Dédoublonage fichier notif en cours
#------------------------------------------------------------------------------
LIBEL="Uniq"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_NOTIF_SSDESB.dat
BCP_QRY="SELECT DISTINCT SSD_CF, ESB_CF, CTR_NF, SEC_NF, UWY_NF FROM BEST..TACCEXCPRO WHERE GAP_D='${DATE}'"  # [002] MBO , uncomment WHERE GAP_D='${DATE} ce qui permet les filliales des nouveaux écarts du jour
                                                                                                              # [004] MMA , Ajout de CTR/SEC/UWY dans l'identification des notifications
BCP

NSTEP=${NJOB}_147
# Dédoublonage fichier notif en cours
# [004] MMA , Ajout de CTR/SEC/UWY dans l'identification des notifications
# [005] MMA , Révision de l'identification externe de la notification
#------------------------------------------------------------------------------
LIBEL="Uniq"
set -x
AWK_I1=${DFILT}/${NJOB}_050_${IB}_NOTIF.dat
AWK_I2=${DFILT}/${NJOB}_146_${IB}_NOTIF_SSDESB.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_NOTIFICATION.dat
set +x
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF 
FNR==NR{a[\$1,\$2,\$3,\$4,\$5]=\$6; next}{ print \$1 FS \$2 FS \$3 FS \$4 FS a[\$1,\$2,\$3,\$4,\$5]}                        
exit
EOF
cat ${AWK_CMD}
STEPSTART
if [ -s "${AWK_I2}" ] || [ -s "${AWK_I1}" ]; then
  awk -F~ -f ${AWK_CMD} ${AWK_I1} ${AWK_I2} > ${AWK_O}
else
  echo "AWK_I2 or AWK_I1 file are empty"
  touch ${AWK_O}
fi
STEPEND $?

NSTEP=${NJOB}_149
#------------------------------------------
# [004] Dédoublonnage + Suppression des notifications sans UWGRP 
# (car pas d'UWGRP dans le perimetre retro pour l'instant)
# [005] 
#------------------------------------------
LIBEL="Summurize NOTIFICATIONS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_147_${IB}_NOTIFICATION.dat"
SORT_O="${DFILT}/${NSTEP}_${IB}_NOTIFICATION_ACCEPT.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF    1:1 - 1: EN,
        ESB_CF    2:1 - 2: EN,
        CTR_NF    3:1 - 3: EN,
        SEC_NF    4:1 - 4: EN,
        UWGRP_CF  5:1 - 5:
/KEYS SSD_CF,
      ESB_CF,
      CTR_NF,
      SEC_NF,
      UWGRP_CF
/CONDITION A_UWGRP UWGRP_CF NE ""
/SUM
/OUTFILE ${SORT_O}
/INCLUDE A_UWGRP
exit
EOF
SORT
gzip -c ${DFILT}/${NSTEP}_${IB}_NOTIFICATION_ACCEPT.dat > ${DFILT}/${NSTEP}_${IB}_NOTIFICATION_ACCEPT.dat.gz 


NSTEP=${NJOB}_150
#----------------------------------------------------------------------------
LIBEL="Appel de la notification"
WS_BATCH_NAME=EST26817824 # Nom du prog JAVA
WS_PARAMS_TEXT <<EOF
INPUT_FILE     ${DFILT}/${NJOB}_149_${IB}_NOTIFICATION_ACCEPT.dat
EOF
WS_OUTPUT_FILE=${DFILT}/${NSTEP}_${IB}_${WS_BATCH_NAME}_O.dat
WS_BATCH

# NSTEP=${NJOB}_160
# #------------------------------------------
# # Suppression des fichiers temporaires
# #------------------------------------------
# RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat" #[003]

JOBEND
