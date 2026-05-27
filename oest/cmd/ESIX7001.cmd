#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Maintenance sur fichier ARCSTATGTR
# nom du script SHELL           : ESIX7001.cmd
# revision                      : $Revision: 1$
# date de creation              : 01/10/2010
# auteur                        : Roger Cassis
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   :spot:20133 - Modification du fichier ARCSTATGTR, recreation a partir du CURGTR archivé.
#
# job launched by ESIX7000.cmd
#-----------------------------------------------------------------------------
# historique des modifications
#
#  <jj/mm/AAAA>  Programer Name  Description de la modification
#=============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_10
# Begin execksh
#-----------------------------------------------------------------
LIBEL="Save ARCSTATGTR"
EXECKSH_MODE=P
EXECKSH "cp ${DFILP}/${ENV_PREFIX}_ESIX7000_ARCSTATGTR.dat ${DSAV}/${ENV_PREFIX}_ESIX7000_${IB}_ARCSTATGTR_20091230.dat"
EXECKSH "compress ${DSAV}/${ENV_PREFIX}_ESIX7000_${IB}_ARCSTATGTR_20091230.dat"

NSTEP=${NJOB}_20
# Begin Sort
#-----------------------------------------------------------------
LIBEL="SUM by rectr for control ARCSTATGTR "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILP}/${ENV_PREFIX}_ESIX7000_ARCSTATGTR.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O1_ARCSTATGTR_AVANT.dat"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
   AMT_M       19:1 - 19:EN 15/3,
	RETCTR_NF   24:1 - 24:,
   RETAMT_M    35:1 - 35:EN 15/3,
   RETINTAMT_M 41:1 - 41:EN 15/3
/KEYS	RETCTR_NF
/SUMMARIZE  TOTAL AMT_M , TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT RETCTR_NF, AMT_MC, RETAMT_MC, RETINTAMT_MC
exit
EOF
SORT

NSTEP=${NJOB}_30
# Begin Sort
#-----------------------------------------------------------------
LIBEL="Extract CURGTR data for selected contracts"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DARCH}/${ENV_PREFIX}_ESIX7000_CURGTR_200912.arc 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O1_CURGTR_CTR.dat"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
	RETCTR_NF 24:1 - 24:
/CONDITION CTR (RETCTR_NF = "04P000058" OR RETCTR_NF = "04P000059" OR RETCTR_NF = "18P000074" OR RETCTR_NF = "19P000004" OR RETCTR_NF = "19P000016" OR RETCTR_NF = "19T700001")
/OUTFILE ${SORT_O}
/INCLUDE CTR
exit
EOF
SORT

NSTEP=${NJOB}_40
# Begin Sort
#-----------------------------------------------------------------
LIBEL="OMIT selected contracts from ARCSTATGTR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILP}/${ENV_PREFIX}_ESIX7000_ARCSTATGTR.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O1_ARCSTATGTR_SANSCTR.dat"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
   BALSHEY_NF 3:1 - 3:,
	RETCTR_NF 24:1 - 24:
/CONDITION CTR BALSHEY_NF = "2009" and (RETCTR_NF = "04P000058" OR RETCTR_NF = "04P000059" OR RETCTR_NF = "18P000074" OR RETCTR_NF = "19P000004" OR RETCTR_NF = "19P000016" OR RETCTR_NF = "19T700001")
/OUTFILE ${SORT_O}
/OMIT CTR
exit
EOF
SORT

NSTEP=${NJOB}_50
# Begin Sort
#-----------------------------------------------------------------
LIBEL="SUM ARCSTATGTR with selected contracts"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_SORT_O1_ARCSTATGTR_SANSCTR.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_30_${IB}_SORT_O1_CURGTR_CTR.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O1_ARCSTATGTR_new.dat"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
        SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
                TRNCOD1_CF 6:1 - 6:1,
                TRNCOD8_CF 6:8 - 6:8 EN,
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
        RETINTAMT_M 41:1 - 41:EN 15/3
/KEYS
        RETCTR_NF ,
        RETEND_NT ,
        RETSEC_NF ,
        RTY_NF ,
        RETUW_NT ,
        CTR_NF ,
        END_NT ,
        SEC_NF ,
        UWY_NF ,
        UW_NT ,
        OCCYEA_NF ,
        ACY_NF ,
        SCOSTRMTH_NF ,
        SCOENDMTH_NF ,
        CLM_NF ,
        CUR_CF ,
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
/SUMMARIZE  TOTAL AMT_M , TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF, END_NT , SEC_NF, UWY_NF, UW_NT, OCCYEA_NF,
 ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_MC, CED_NF, BRK_NF, PAY_NF, KEY_NF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT,
 RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, RETCUR_CF, RETAMT_MC, PLC_NT, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, RETINTAMT_MC
exit
EOF
SORT

echo "#" 2>&1 | ${TEE}
echo "# ----------------------------------------------------------" 2>&1 | ${TEE}
echo "--> Inverse les montants ARCSTATGTR ancien" 2>&1 | ${TEE}
echo "# ----------------------------------------------------------" 2>&1 | ${TEE}

awk  'BEGIN{ FS="~"; OFS="~"; s="" } \
{
	if ($2 != 0) $2 = sprintf("%-.3lf",-$2)
	if ($3 != 0) $3 = sprintf("%-.3lf",-$3)
	if ($4 != 0) $4 = sprintf("%-.3lf",-$4)
	print $0
}' \
 ${DFILT}/${NJOB}_20_${IB}_SORT_O1_ARCSTATGTR_AVANT.dat > ${DFILT}/${NJOB}_20_${IB}_SORT_O1_ARCSTATGTR_AVANT2.dat

NSTEP=${NJOB}_60
# Begin Sort
#-----------------------------------------------------------------
LIBEL="SUM for control new ARCSTATGTR "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_SORT_O1_ARCSTATGTR_new.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O1_ARCSTATGTR_APRES.dat"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
   AMT_M       19:1 - 19:EN 15/3,
	RETCTR_NF   24:1 - 24:,
   RETAMT_M    35:1 - 35:EN 15/3,
   RETINTAMT_M 41:1 - 41:EN 15/3
/KEYS	RETCTR_NF
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT RETCTR_NF, AMT_MC, RETAMT_MC, RETINTAMT_MC
exit
EOF
SORT

NSTEP=${NJOB}_70
# Begin Sort
#-----------------------------------------------------------------
LIBEL="SUM for control new and old ARCSTATGTR "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_O1_ARCSTATGTR_AVANT2.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_60_${IB}_SORT_O1_ARCSTATGTR_APRES.dat"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O1_ARCSTATGTR_CUM.dat"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
	RETCTR_NF   1:1 - 1:,
   AMT_M       2:1 - 2:EN 15/3,
   RETAMT_M    3:1 - 3:EN 15/3,
   RETINTAMT_M 4:1 - 4:EN 15/3
/KEYS	RETCTR_NF
/SUMMARIZE  TOTAL AMT_M , TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT RETCTR_NF, AMT_MC, RETAMT_MC, RETINTAMT_MC
exit
EOF
SORT

echo "#" 2>&1 | ${TEE}
echo "# Liste contrats touchés" 2>&1 | ${TEE}
echo "# ----------------------------------------------------------" 2>&1 | ${TEE}
grep -v "~0~0~0" ${DFILT}/${NSTEP}_${IB}_SORT_O1_ARCSTATGTR_CUM.dat | more
echo "# ----------------------------------------------------------" 2>&1 | ${TEE}

NSTEP=${NJOB}_80
# Begin execksh
#-----------------------------------------------------------------
LIBEL="Rename new ARCSTATGTR"
EXECKSH_MODE=P
EXECKSH "mv ${DFILT}/${NJOB}_50_${IB}_SORT_O1_ARCSTATGTR_new.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_ARCSTATGTR.dat"

NSTEP=${NJOB}_90
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"

JOBEND
