#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE 
#                                 Extraction des ecritures de services Post Omega Local - Gestion des fichiers antérieurs
# nom du script SHELL           : ESLJ0092.cmd
# revision                      :
# date de creation              : 04/07/2017
# auteur                        : R. Cassis
# references des specifications : Spira:61508
#-----------------------------------------------------------------------------
# description
#   Reprend les données de la veille et génère des données avec montants inversés pour annuler ce qui a déjà chargé
#   et ne conserver que le Delta non chargé
#
# Input files
#
# output files
#	     ESL_EPOSOCLO
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 07/12/2017 R. Cassis :spira:66334 Les fichiers perimetre ES Local sont nommés ESL_ sont maintenant générés dans le ESID7000
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
BLCSHTYEALOC_NF=${1}
BLCSHTMTHLOC_NF=${2}

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> BLCSHTYEALOC_NF.......: ${BLCSHTYEALOC_NF}"
ECHO_LOG "#===> BLCSHTMTHLOC_NF.......: ${BLCSHTMTHLOC_NF}"
ECHO_LOG "#===> ESL_EPOSOCLO..........: ${ESL_EPOSOCLO}"
ECHO_LOG "#===> ESL_EPOSOCLO_CUR......: ${ESL_EPOSOCLO_CUR}"
ECHO_LOG "#===> ESL_EPOSOCLO_CURNEW...: ${ESL_EPOSOCLO_CURNEW}"
ECHO_LOG "#===> ESL_EPOSOCLO_NEW......: ${ESL_EPOSOCLO_NEW}"
ECHO_LOG "#========================================================================="

# Job Initialisation
JOBINIT

if [ ! -f ${ESL_EPOSOCLO_CUR} ]
then
	touch ${ESL_EPOSOCLO_CUR}
fi

NSTEP=${NJOB}_10
# si EPO_FTECLEDASO_CUR existe sur la période, Inverser tous les mouvements de la période.
#-----------------------------------------------------------------------------
LIBEL="Inversion des montants du fichier ${ESL_EPOSOCLO_CUR} précédent"
AWK_I=${ESL_EPOSOCLO_CUR}
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_EPOSOCLO_CurRevert_O.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
       { if ( \$19 != 0 ) \$19 = sprintf("%-.3lf",-\$19);
         if ( \$35 != 0 ) \$35 = sprintf("%-.3lf",-\$35);
            ; print \$0 }
exit
EOF
AWK

NSTEP=${NJOB}_20
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Summarizing NEW with CurRevert file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESL_EPOSOCLO_NEW}  1000 1 "
SORT_I2="${DFILT}/${NJOB}_10_${IB}_AWK_EPOSOCLO_CurRevert_O.dat 1000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_EPOSOCLO_Delta_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19: EN 15/3,
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
        RETAMT_M 35:1 - 35: EN 15/3,
        PLC_NT 36:1 - 36 :,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETAUTGEN_B 41:1 - 41:,
        ACCTYP_NF 42:1 - 42:,
        TRN_NT 43:1 - 43:,
        ORICOD_LS 44:1 - 44:,
        RETROAUTO_B 45:1 - 45:,
        SPEENTNAT_CT 46:1 - 46:,
        EVT_NF 47:1 - 47:,
        REVT_NF 48:1 - 48:,
        ACCTRN_NT 49:1 - 49:
/KEYS   SSD_CF,
        ESB_CF,
        BALSHEY_NF,
        BALSHRMTH_NF,
        BALSHRDAY_NF,
        TRNCOD_CF,
        DBLTRNCOD_CF,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        OCCYEA_NF,
        ACY_NF,
        SCOSTRMTH_NF,
        SCOENDMTH_NF,
        CLM_NF,
        CUR_CF,
        CED_NF,
        BRK_NF,
        PAY_NF,
        KEY_NF,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        RETOCCYEA_NF,
        RETACY_NF,
        RETSCOSTRMTH_NF,
        RETSCOENDMTH_NF,
        RCL_NF,
        RETCUR_CF,
        PLC_NT,
        RTO_NF,
        INT_NF,
        RETPAY_NF,
        RETKEY_CF,
        RETAUTGEN_B,
        ACCTYP_NF,
        TRN_NT,
        ORICOD_LS,
        RETROAUTO_B,
        SPEENTNAT_CT,
        EVT_NF,
        REVT_NF,
        ACCTRN_NT
/SUMMARIZE  TOTAL AMT_M,
            TOTAL RETAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_30
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Create final EPOSOCLO to process and Delta to process next time"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_EPOSOCLO_Delta_O.dat  1000 1 "
SORT_O="${ESL_EPOSOCLO} OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS BALSHEY_NF 3:1 - 3:EN,
        BALSHRMTH_NF 4:1 - 4:EN,
        AMT_M 19:1 - 19: EN 15/3,
        RETAMT_M 35:1 - 35: EN 15/3
/CONDITION MoisBilan BALSHEY_NF = ${BLCSHTYEALOC_NF} AND BALSHRMTH_NF = ${BLCSHTMTHLOC_NF} AND (AMT_M NE 0 OR RETAMT_M NE 0)        
/OUTFILE ${SORT_O}
/INCLUDE MoisBilan
exit
EOF
SORT

#---------------------------------------------------------------------------
gzip -c ${ESL_EPOSOCLO} > ${DFILT}/${NCHAIN}_${IB}_EST_ESLJ0090_EPOSOCLO.dat.gz
#---------------------------------------------------------------------------

NSTEP=${NJOB}_40
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Summarizing NEW with CurRevert file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESL_EPOSOCLO_CUR} 1000 1 "
SORT_I2="${ESL_EPOSOCLO} 1000 1 "
SORT_O="${ESL_EPOSOCLO_CURNEW} OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_150
# Deletion of temporary files
#------------------------------------------------------------------------------
LIBEL="Deletion of temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
