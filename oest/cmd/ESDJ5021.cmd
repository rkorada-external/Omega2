#!/bin/ksh
#==============================================================================
# nom de l'application          : ESTIMATIONS - INTRADAY
# nom du script SHELL           : ESDJ5021.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 28/07/2015
# auteur                        : JFO
# references des specifications : EST38 - EST52
#------------------------------------------------------------------------------
# description
#     Job intra-day
#   Notifie l'utilisateur d'écarts dans les saisies manuelles et file upload
#------------------------------------------------------------------------------
# historiques des modifications
# [001]   JFO   29/07/2015  spot29095: Création du fichier
# [002]   MBO   10/02/2016  spot30168: suppression de lignes en double dans les Tables BEST..TIDLIFEST_DETAIL/GLOBAL
# [003]   DFI   18/02/2016  spot20233: suppression des fichiers temporaires
# [004]   MBO   01/03/2016  spot30277: Nettoyage des fichiers $DFILT
# [005]   MBO   04/04/2016  spot30277: pas de spira: conservation de FIDLIFEST_CALL en cas de problème autre que plantage simple
#         MBO   28/04/2016  spot30277: pas de spira: correction nom fichier créé précédement
# [006]   MBO   02/06/2016  spot30691: ajout de la trimestrialisation
# [007]   MBO   07/06/2016  spot30691: correction plantage
# [008]   MBO   14/06/2016  spot30691: récupération iclodat
# [009]   MBO   23/06/2016  spot30691: correction de la currency employé pour la table DETAIL
# [010]   MBO   29/06/2016  spot30691: Trimestrialisation
# [011]   MBO   04/07/2016  spot30691: Rustine temporaire en attente de trouver la source de doublons dans le 5003 (corrige tout de même le problème mais apres coup)
# [012]   MBO   03/08/2016  spot30898: correction du probleme durant les périodes de compta
# [013]   MMA   06/09/2016  spot30898: Deplacement de la génération du FACCPAR0 (step57) dans la s-chaine ESEH1103 => Correction du correctif [012]
#==============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctws.cmd


# Get input parameters
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2 # [007]
CLODAT_D=$3 # [007]
ICLODAT_D=$4 # [008]

# Job Initialisation
JOBINIT

RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat" #[004]

echo "#
# EST_FIDLIFEST_CALL   ==> ${EST_FIDLIFEST_CALL}
# EST_FIDLIFEST_MVT    ==> ${EST_FIDLIFEST_MVT}
# EST_FAVERATE         ==> ${EST_FAVERATE}
# EST_FESB             ==> ${EST_FESB}
# EST_FSUBTRSBASE      ==> ${EST_FSUBTRSBASE}
# STA_LIFSTAREP_PLAN   ==> ${STA_LIFSTAREP_PLAN}
# SAVED_LIFSTAREP_PLAN ==> ${SAVED_LIFSTAREP_PLAN}
# EST_LIFEST_OPENNING  ==> ${DFILP}/${ENV_PREFIX}_EST_ESDJ0110_FLIFESTY_OPENNING_${BALSHTYEA_NF}.dat
# BALSHTYEA_NF         ==> $BALSHTYEA_NF
# BALSHTMTH_NF         ==> ${BALSHTMTH_NF}
# CLODAT_D             ==> ${CLODAT_D}
# ICLODAT_D            ==> ${ICLODAT_D}
# EST_FACCPAR0         ==> ${EST_FACCPAR0}
# EST_SUBTRSASSO       ==> ${EST_SUBTRSASSO}
# EST_SUBTRS           ==> ${EST_SUBTRS}
# EST_IARVPERICASE4    ==> ${EST_IARVPERICASE4}
# EST_FTRSLNK          ==> ${EST_FTRSLNK}"

# If calling table empty, nothing more to do.
if [[ ! -s ${EST_FIDLIFEST_CALL} ]];
    then
  echo "#
# -------------------------------------------------
#
#   Pas de données dans la table d'appel.
#   Le traitement intra-day n'aura pas lieu.
#
# -------------------------------------------------
#
#   No data in calling table.
#   Intra Day Jobs are going to be stopped.
#
# -------------------------------------------------
#"
  JOBEND
fi


NSTEP=${NJOB}_001
# Test if LIFSTAREP_PLAN exists
#------------------------------------------------------------------------------
LIBEL="Test if STA_LIFSTAREP_PLAN exists"
if [[ ! -s ${STA_LIFSTAREP_PLAN} ]];
    then
        echo "#
# Unable to use ${STA_LIFSTAREP_PLAN} File is EMPTY"  # [007]
    JOBEND
fi


NSTEP=${NJOB}_003
# Test if LIFSTAREP_PLAN exists
#------------------------------------------------------------------------------
LIBEL="Test if SAVED_LIFSTAREP_PLAN exists"
if [[ ! -s ${SAVED_LIFSTAREP_PLAN} ]];
    then
      export SAVED_LIFSTAREP_PLAN=${DFILP}/${PCH}ESDJ5020_LIFSTAREP_PLAN.dat
      cp ${STA_LIFSTAREP_PLAN} ${SAVED_LIFSTAREP_PLAN}
fi


NSTEP=${NJOB}_005
# Determination of the version of LIFSTAREP_PLAN which is going to be used
#------------------------------------------------------------------------------
LIBEL="Determination of the version of LIFSTAREP_PLAN which is going to be used"
cut -d~ -f57 ${STA_LIFSTAREP_PLAN} | grep -cv `expr ${BALSHTYEA_NF} - 1` > /dev/null

if [[ $? -eq 1 ]];
    then
    cp ${STA_LIFSTAREP_PLAN} ${SAVED_LIFSTAREP_PLAN}
elif [[ -s ${SAVED_LIFSTAREP_PLAN} ]];
    then
    STA_LIFSTAREP_PLAN=${SAVED_LIFSTAREP_PLAN}
    echo "# Using SAVED_LIFSTAREP_PLAN instead of STA_LIFSTAREP_PLAN due to inconsistance in data."
elif [[ ! -s ${SAVED_LIFSTAREP_PLAN} ]];
    then
    echo "#
# Unable to use neither STA_LIFSTAREP_PLAN or SAVED_LIFSTAREP_PLAN due to inconsistance in data.
# Quitting Intra Day Jobs. To correct this problem please change inventory date to same year everywhere."
    JOBEND
fi


NSTEP=${NJOB}_010
# Sorting FIDLIFEST_CALL
#------------------------------------------------------------------------------
LIBEL="Sorting FIDLIFEST_CALL"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FIDLIFEST_CALL} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FIDLIFEST_CALL.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
        SSD_CF 3:1 - 3:EN,
        CTR_NF 6:1 - 6:,
        SEC_NF 7:1 - 7:EN,
        UWY_NF 8:1 - 8:EN
/KEYS
    SSD_CF,
    CTR_NF,
    SEC_NF,
    UWY_NF
exit
EOF
SORT


gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_FIDLIFEST_CALL.dat > ${DFILT}/${NSTEP}_${IB}_SORT_FIDLIFEST_CALL.dat.gz #[005]


NSTEP=${NJOB}_020
# Sorting FIDLIFEST_MVT
#------------------------------------------------------------------------------
LIBEL="Sorting FIDLIFEST_MVT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FIDLIFEST_MVT} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FIDLIFEST_MVT.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
      SSD_CF         1:1 -  1:EN,
      CTR_NF         2:1 -  2:,
      SEC_NF         4:1 -  4:EN,
      UWY_NF         5:1 -  5:EN,
      ACY_NF         7:1 -  7:EN,
      CRE_D          8:1 -  8:,
      ESTMNT_M      10:1 - 10:,
      DETTRNCOD_CF  20:1 - 20:EN,
      GAAP_NF       22:1 - 22:EN
/KEYS
    SSD_CF,
    CTR_NF,
    SEC_NF,
    UWY_NF,
    ACY_NF,
    DETTRNCOD_CF,
    GAAP_NF,
    CRE_D DESCENDING,
    ESTMNT_M
/SUM
/STABLE
exit
EOF
SORT


gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_FIDLIFEST_MVT.dat > ${DFILT}/${NSTEP}_${IB}_SORT_FIDLIFEST_MVT.dat.gz


NSTEP=${NJOB}_040
# Sorting LIFSTAREP_PLAN
#------------------------------------------------------------------------------
LIBEL="Sorting LIFSTAREP_PLAN"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${STA_LIFSTAREP_PLAN} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFSTAREP_PLAN.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
        SSD_CF 2:1 - 2:EN,
        CTR_NF 3:1 - 3:,
        SEC_NF 5:1 - 5:EN,
        UWY_NF 6:1 - 6:EN
/KEYS
      SSD_CF,
      CTR_NF,
      SEC_NF,
      UWY_NF
exit
EOF
SORT


NSTEP=${NJOB}_050
# Generating detailled report
#------------------------------------------------------------------------------
LIBEL="Generating detailled report"
PRG=ESTC5000
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
BALSHTYEA_NF ${BALSHTYEA_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_010_${IB}_SORT_FIDLIFEST_CALL.dat
export ${PRG}_I2=${DFILT}/${NJOB}_020_${IB}_SORT_FIDLIFEST_MVT.dat
export ${PRG}_I3=${DFILP}/${ENV_PREFIX}_EST_ESDJ0110_FLIFESTY_OPENNING_${BALSHTYEA_NF}.dat
export ${PRG}_I4=${DFILT}/${NJOB}_040_${IB}_SORT_LIFSTAREP_PLAN.dat
export ${PRG}_I5=${EST_FAVERATE}
export ${PRG}_I6=${EST_SUBTRSASSO} #[010]
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_IDAY_DETAILLED.dat
EXECPRG

#[010]
NSTEP=${NJOB}_055
# Sorting IDAY_DETAILLED.dat
#------------------------------------------------------------------------------
LIBEL="Sorting IDAY_DETAILLED.dat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_050_${IB}_IDAY_DETAILLED.dat"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IDAY_DETAILLED.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS PERIOD_NT      5:1 - 5:,
        CTR_NF         6:1 - 6:,
        SEC_NF         7:1 - 7:,
        UWY_NF         8:1 - 8:,
        ACY_NF         9:1 - 9:EN,
        ACMDET_NT     23:1 - 23:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      PERIOD_NT,
      ACMDET_NT DESCENDING     
/OUTFILE ${SORT_O} 
exit
EOF
SORT
#![010]

#[013]
#*/ Suppression du Bloc */ 

NSTEP=${NJOB}_060
# Trimestrialisation
#------------------------------------------------------------------------------
LIBEL="Quaterlisation of report"
PRG=ESTC5003
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
BALSHTYEA_NF ${BALSHTYEA_NF}
BALSHTMTH_NF ${BALSHTMTH_NF}
CLODAT_D ${CLODAT_D}
ICLODAT_D ${ICLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_055_${IB}_SORT_IDAY_DETAILLED.dat
export ${PRG}_I2=${EST_FACCPAR0}
export ${PRG}_I3=${EST_SUBTRSASSO}
export ${PRG}_I4=${EST_SUBTRS}
export ${PRG}_I5=${EST_IARVPERICASE4}
export ${PRG}_I6=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_IDAY_DETAILLED_QUARTERLIZED.dat
EXECPRG

#[011]
NSTEP=${NJOB}_060_bis
# Correction temporaire du probleme de doublons généré par le 5003, correction des Symptomes et non de la Cause...
# cette étape devra disparaitre à terme.
#------------------------------------------------------------------------------
LIBEL="Suppression doublon de clef"
AWK_I="${DFILT}/${NJOB}_060_${IB}_IDAY_DETAILLED_QUARTERLIZED.dat"
AWK_O="${DFILT}/${NJOB}_060_${IB}_IDAY_DETAILLED_QUARTERLIZED.dat.bis"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN { FS="\~" ; OFS="\~" }

    {
        if (LINE[\$1 FS \$5 FS \$6 FS \$7 FS \$8 FS \$9 FS \$10 FS \$21, NF] != \$0)
            {
                LINE[\$1 FS \$5 FS \$6 FS \$7 FS \$8 FS \$9 FS \$10 FS \$21, NF] = \$0
            }
    }

END { for (i in LINE) print LINE[i] }

exit
EOF
AWK
#[011]

#[010]
NSTEP=${NJOB}_065
# Sorting IDAY_DETAILLED.dat
#------------------------------------------------------------------------------
LIBEL="REFORMAT IDAY_DETAILLED.dat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_055_${IB}_SORT_IDAY_DETAILLED.dat"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IDAY_DETAILLED_2.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FILLER   1:1 - 21:
/OUTFILE ${SORT_O}
/REFORMAT FILLER
exit
EOF
SORT
#![010]


#[010]
NSTEP=${NJOB}_068
# Sorting IDAY_DETAILLED.dat
#------------------------------------------------------------------------------
LIBEL="REFORMAT IDAY_DETAILLED.dat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_060_${IB}_IDAY_DETAILLED_QUARTERLIZED.dat.bis"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IDAY_DETAILLED_QUARTERLIZED.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FILLER   1:1 - 21:
/OUTFILE ${SORT_O}
/REFORMAT FILLER
exit
EOF
SORT
#![010]


NSTEP=${NJOB}_070
# Converting detailled lines currency to ledger
#------------------------------------------------------------------------------
LIBEL="Converting detailled lines currency to ledger"
PRG=ESTC5001
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
QUARTERLIZED 0
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_065_${IB}_SORT_IDAY_DETAILLED_2.dat #[010]
export ${PRG}_I2=${EST_FESB}
export ${PRG}_I3=${EST_FAVERATE}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_IDAY_DETAILLED_CONV.dat
EXECPRG


# [006]
NSTEP=${NJOB}_080
# Converting detailled lines currency to ledger and QUARTERLIZED
#------------------------------------------------------------------------------
LIBEL="Converting detailled lines currency to ledger and QUARTERLIZED"
PRG=ESTC5001
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
QUARTERLIZED 1
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_068_${IB}_SORT_IDAY_DETAILLED_QUARTERLIZED.dat #[010]
export ${PRG}_I2=${EST_FESB}
export ${PRG}_I3=${EST_FAVERATE}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_IDAY_DETAILLED_CONV_QUARTERLIZED.dat
EXECPRG
# \[006]


NSTEP=${NJOB}_090
# Finding when was the last inventory
#------------------------------------------------------------------------------
LIBEL="Finding when was the last inventory"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_last_date_inv.dat # derniere date inventaire
BCP_QRY="select Convert(Char(8), max(LAUNCH_D), 112) from BEST..TREQJOB where REQCOD_CT='L' and BALSHEYEA_NF=1900"
BCP


# derniere date modif taux de change
TXCHA=`cut -d"~" -f3 ${EST_FAVERATE} | tail -n1`
# derniere date inventaire
DLINV=`cat ${DFILT}/${NJOB}_090_last_date_inv.dat`


NSTEP=${NJOB}_095
# Sorting FIDLIFEST_CALL
#------------------------------------------------------------------------------
LIBEL="Sorting FIDLIFEST_CALL"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_070_${IB}_IDAY_DETAILLED_CONV.dat"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IDAY_DETAILLED_CONV_ID.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
        ID_CF 1:1 - 1:EN
/KEYS
        ID_CF
/STABLE
exit
EOF
SORT


# [006]
NSTEP=${NJOB}_098
# Sorting FIDLIFEST_CALL
#------------------------------------------------------------------------------
LIBEL="Sorting FIDLIFEST_CALL QUARTERLIZED"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_080_${IB}_IDAY_DETAILLED_CONV_QUARTERLIZED.dat"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IDAY_DETAILLED_CONV_ID_QUARTERLIZED.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
        ID_CF 1:1 - 1:EN
/KEYS
        ID_CF
/STABLE
exit
EOF
SORT
# \[006]


NSTEP=${NJOB}_100
# Begin programme C to generate global report
#------------------------------------------------------------------------------
LIBEL="Generating global report"
PRG=ESTC5002
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
TXCHA ${TXCHA}
DLINV ${DLINV}
BALSHTYEA_NF ${BALSHTYEA_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_010_${IB}_SORT_FIDLIFEST_CALL.dat
export ${PRG}_I2=${EST_FSUBTRSBASE}
export ${PRG}_I3=${DFILT}/${NJOB}_095_${IB}_SORT_IDAY_DETAILLED_CONV_ID.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_IDAY_GLOBAL.dat
EXECPRG


# [006]
NSTEP=${NJOB}_110
# Begin programme C to generate global report
#------------------------------------------------------------------------------
LIBEL="Generating global report QUARTERLIZED"
PRG=ESTC5002
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
TXCHA ${TXCHA}
DLINV ${DLINV}
BALSHTYEA_NF ${BALSHTYEA_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_010_${IB}_SORT_FIDLIFEST_CALL.dat
export ${PRG}_I2=${EST_FSUBTRSBASE}
export ${PRG}_I3=${DFILT}/${NJOB}_098_${IB}_SORT_IDAY_DETAILLED_CONV_ID_QUARTERLIZED.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_IDAY_GLOBAL_QUARTERLIZED.dat
EXECPRG
# \[006]


#[002] MBO : suppression de lignes en double
NSTEP=${NJOB}_120
# Removal of already processed DETAIL's lines
#------------------------------------------------------------------------------
LIBEL="Removal of already processed DETAIL's lines"
ISQL_QRY="DELETE FROM BEST..TIDLIFEST_DETAIL FROM BEST..TIDLIFEST_DETAIL detail, BEST..TIDLIFEST_CALL call, BREF..TBATCHSSD batch
WHERE
    detail.ID_CF        = call.ID_CF        AND
    call.SSD_CF         = batch.SSD_CF      AND
    batch.BATCHUSER_CF  = suser_name()      AND
    call.FLAG_B         = 1"
ISQL_BASE="BEST"
ISQL


NSTEP=${NJOB}_130
# Removal of already processed DETAIL's lines
#------------------------------------------------------------------------------
LIBEL="Removal of already processed GLOBAL's lines"
ISQL_QRY="DELETE FROM BEST..TIDLIFEST_GLOBAL FROM BEST..TIDLIFEST_GLOBAL global, BEST..TIDLIFEST_CALL call, BREF..TBATCHSSD batch
WHERE
    global.ID_CF        = call.ID_CF        AND
    call.SSD_CF         = batch.SSD_CF      AND
    batch.BATCHUSER_CF  = suser_name()      AND
    call.FLAG_B         = 1"
ISQL_BASE="BEST"
ISQL
#\[002] MBO : suppression de lignes en double


# [006]
NSTEP=${NJOB}_140
#Merge _IDAY_DETAILLED_CONV_FINALIZED & _IDAY_DETAILLED_CONV_QUARTERLIZED_FINALIZED
#------------------------------------------------------------
LIBEL="merge IDAY_DETAILLED & IDAY_DETAILLED_QUARTERLIZED"
STEPSTART
STEP_I=${DFILT}/${NJOB}_065_${IB}_SORT_IDAY_DETAILLED_2.dat                #[009] [010]
STEP_I2=${DFILT}/${NJOB}_068_${IB}_SORT_IDAY_DETAILLED_QUARTERLIZED.dat    #[009] [010]
STEP_O=${DFILT}/${NSTEP}_${IB}_IDAY_DETAILLED_MERGED.dat
cp ${STEP_I} ${STEP_O}
cat ${STEP_I2} >> ${STEP_O}
STEPEND $?


NSTEP=${NJOB}_145
#Merge _IDAY_GLOBAL_FINALIZED & _IDAY_GLOBAL_QUARTERLIZED_FINALIZED
#------------------------------------------------------------
LIBEL="merge IDAY_GLOBAL & IDAY_GLOBAL_QUARTERLIZED"
STEPSTART
STEP_I=${DFILT}/${NJOB}_100_${IB}_IDAY_GLOBAL.dat
STEP_I2=${DFILT}/${NJOB}_110_${IB}_IDAY_GLOBAL_QUARTERLIZED.dat
STEP_O=${DFILT}/${NSTEP}_${IB}_IDAY_GLOBAL_MERGED.dat
cp ${STEP_I} ${STEP_O}
cat ${STEP_I2} >> ${STEP_O}
STEPEND $?
# \[006]

NSTEP=${NJOB}_150
# Uploading detailed report
#------------------------------------------------------------------------------
LIBEL="Uploading detailed report"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_140_${IB}_IDAY_DETAILLED_MERGED.dat # [006]
BCP_TABLE="BEST..TIDLIFEST_DETAIL"
BCP


NSTEP=${NJOB}_200
# Uploading global report
#------------------------------------------------------------------------------
LIBEL="Uploading global report"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_145_${IB}_IDAY_GLOBAL_MERGED.dat # [006]
BCP_TABLE="BEST..TIDLIFEST_GLOBAL"
BCP


NSTEP=${NJOB}_220
# Creating WS_BATCH param file
#------------------------------------------------------------------------------
LIBEL="Creating WS_BATCH param file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_140_${IB}_IDAY_DETAILLED_MERGED.dat 1000 1" # [006]
SORT_O="${DFILT}/${NSTEP}_${IB}_NOTIFICATION.dat 1000 1" # [006]
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
  ID_CF 1:1 - 1:
/KEYS
  ID_CF
/SUMMARIZE
/OUTFILE ${SORT_O}
/REFORMAT ID_CF
exit
EOF
SORT


NSTEP=${NJOB}_250
#------------------------------------------------------------------------------
LIBEL="Appel de la notification"
WS_BATCH_NAME=EST817860  # Nom du prog JAVA
WS_PARAMS_TEXT <<EOF
INPUT_FILE     ${DFILT}/${NJOB}_220_${IB}_NOTIFICATION.dat
EOF
WS_OUTPUT_FILE=${DFILT}/${NSTEP}_${IB}_${WS_BATCH_NAME}_O.dat
WS_BATCH


NSTEP=${NJOB}_300
# Removal of already processed lines
#------------------------------------------------------------------------------
LIBEL="Removal of already processed lines"
ISQL_QRY="DELETE FROM BEST..TIDLIFEST_CALL FROM BEST..TIDLIFEST_CALL a, BREF..TBATCHSSD b
WHERE
    a.FLAG_B        = 1             AND
    a.SSD_CF        = b.SSD_CF      AND
    b.BATCHUSER_CF  = suser_name()"
ISQL_BASE="BEST"
ISQL


NSTEP=${NJOB}_350
# Erase temporary files [003]
#------------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat" #[004]
RMFIL "${DFILT}/${NJOB}*_${IB}_*_IDAY_DETAILLED_QUARTERLIZED.dat.bis"

JOBEND
