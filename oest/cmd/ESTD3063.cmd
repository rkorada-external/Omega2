#!/bin/ksh
#=============================================================================
# maj de l'application:           ESTIMATIONS - TRANSFERT INTER-SITES (PORTEFEUILLES)
# nom du script SHELL:            ESTD3063.cmd
# revision:                       $Revision: 1.1 $
# date de creation:               10/02/2009
# auteur:                         J.Ribot
# references des specifications : :spot:16765
#-----------------------------------------------------------------------------
# description :
#
#Integration des retraits portefeuilles
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#      13/01/2010 Roger Cassis :spot:18415 Ajout transfert fichier vie LIFSTAREP_PLAN
# [02] 06/07/2011 Florent      :spot:22328 ajout de 16 champs dans le GTA
# [03] 19/08/2015 Roger Cassis :spot:29223 Correction du reformat du STATGTA
#
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Parameters

# GTA

NSTEP=${NJOB}_05
# Append GTA Files
#-----------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
LIBEL="Append GTA Files "
SORT_CMD=`CFTMP`
SORT_I="${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat 1000 1"
SORT_I2="${DFILI}/${ENV_PREFIX}_ESTD3060_ESTD3061_GTA_AAJOUTER_TRANSFP_ENTREE.dat 1000 1"
SORT_O="${DFILT}/${ENV_PREFIX}_ESIX7000_GTA.dat.new 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 8:1 - 8:
/KEYS CTR_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_10
# Append CURGTA Files
#-----------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
LIBEL="Append CURGTA Files "
SORT_CMD=`CFTMP`
SORT_I="${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat 1000 1"
SORT_I2="${DFILI}/${ENV_PREFIX}_ESTD3060_ESTD3061_CURGTA_AAJOUTER_TRANSFP_ENTREE.dat 1000 1"
SORT_O="${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTA.dat.new 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 8:1 - 8:
/KEYS CTR_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_15
# STATGTA [02] [03]
#------------------------------------------------------------------------------
LIBEL="STATGTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILP}/${ENV_PREFIX}_ESIX7000_STATGTA.dat 1000 1"
SORT_I2="${DFILI}/${ENV_PREFIX}_ESTD3060_ESTD3061_STATGTA_AAJOUTER_TRANSFP_ENTREE.dat 1000 1"
SORT_O="${DFILT}/${ENV_PREFIX}_ESIX7000_STATGTA.dat.new 1000 1"
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

if [ -s ${DFILI}/${NCHAIN}_ESTD3061_LIFSTAREP_PLAN_TRANSFP.dat ]
then

	# [03] Mise a niveau tri
	NSTEP=${NJOB}_20
	# Ajout du fichier plan
	#----------------------------------------------------------------------------
	LIBEL="Ajout du fichier plan de transfert"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILP}/${ENV_PREFIX}_STAD1520_LIFSTAREP_PLAN.dat 1000 "
	SORT_I2="${DFILI}/${NCHAIN}_ESTD3061_LIFSTAREP_PLAN_TRANSFP.dat"
	SORT_O=${DFILT}/${ENV_PREFIX}_STAD1520_LIFSTAREP_PLAN.dat.new
INPUT_TEXT $SORT_CMD <<EOF
/FIELD  CLODAT_D    1:  -  1:,
        SSD_CF      2:  -  2: EN,
        CTR_NF      3:  -  3:,
        END_NT      4:  -  4: EN 2/0,
        SEC_NF      5:  -  5: EN 3/0,
        UWY_NF      6:  -  6: EN 4/0,
        UW_NT       7:  -  7: EN 2/0,
        PLC_NT      8:  -  8:,
        ACCRET_CF   9:  -  9:,
        ACY_NF     10:  - 10: EN 4/0,
        ACMTRS_NT  11:  - 11:,
        DETTRNCOD  12:  - 12:,
        PCPCUR_CF  13:  - 13:,
        CED_NF     31:1 - 31:
/KEYS CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF, ACMTRS_NT, DETTRNCOD, PCPCUR_CF, CED_NF
/OUTFILE ${SORT_O}
exit
EOF
	SORT

fi

NSTEP=${NJOB}_25
# Begin Remove
#--------------------------------------------------------------------------
LIBEL="move $DFILT/${ENV_PREFIX}_ESIX7000_GTA.dat.new $DFILP/${ENV_PREFIX}_ESIX7000_GTA.dat"
EXECKSH "mv $DFILT/${ENV_PREFIX}_ESIX7000_GTA.dat.new $DFILP/${ENV_PREFIX}_ESIX7000_GTA.dat"

NSTEP=${NJOB}_30
# Begin Remove
#--------------------------------------------------------------------------
LIBEL="move $DFILT/${ENV_PREFIX}_ESIX7000_CURGTA.dat.new $DFILP/${ENV_PREFIX}_ESIX7000_CURGTA.dat"
EXECKSH "mv $DFILT/${ENV_PREFIX}_ESIX7000_CURGTA.dat.new $DFILP/${ENV_PREFIX}_ESIX7000_CURGTA.dat"

NSTEP=${NJOB}_35
# Begin Remove
#--------------------------------------------------------------------------
LIBEL="move $DFILT/${ENV_PREFIX}_ESIX7000_STATGTA.dat.new $DFILP/${ENV_PREFIX}_ESIX7000_STATGTA.dat"
EXECKSH "mv $DFILT/${ENV_PREFIX}_ESIX7000_STATGTA.dat.new $DFILP/${ENV_PREFIX}_ESIX7000_STATGTA.dat"

if [ -s ${DFILT}/${ENV_PREFIX}_STAD1520_LIFSTAREP_PLAN.dat.new ]
then

	NSTEP=${NJOB}_40
	# Begin Remove
	#--------------------------------------------------------------------------
	LIBEL="move ${DFILT}/${ENV_PREFIX}_STAD1520_LIFSTAREP_PLAN.dat.new $DFILP/${ENV_PREFIX}_STAD1520_LIFSTAREP_PLAN.dat"
	EXECKSH "mv ${DFILT}/${ENV_PREFIX}_STAD1520_LIFSTAREP_PLAN.dat.new $DFILP/${ENV_PREFIX}_STAD1520_LIFSTAREP_PLAN.dat"

	NSTEP=${NJOB}_45
	# Begin Remove
	#--------------------------------------------------------------------------
	LIBEL="cp ${DFILI}/${NCHAIN}_ESTD3061_LIFSTAREP_PLAN_TRANSFP.dat ${DSAV}/${SVG}_${ENV_PREFIX}_STAD1520_LIFSTAREP_PLAN.dat"
	EXECKSH "cp ${DFILI}/${NCHAIN}_ESTD3061_LIFSTAREP_PLAN_TRANSFP.dat ${DSAV}/${SVG}_${ENV_PREFIX}_STAD1520_LIFSTAREP_PLAN.dat"

	NSTEP=${NJOB}_50
	# Begin Remove
	#--------------------------------------------------------------------------
	LIBEL="gzip ${DSAV}/${SVG}_${ENV_PREFIX}_STAD1520_LIFSTAREP_PLAN.dat"
	EXECKSH "gzip ${DSAV}/${SVG}_${ENV_PREFIX}_STAD1520_LIFSTAREP_PLAN.dat"

fi
NSTEP=${NJOB}_55
#Temporary file deletion
#------------------------------------------------
LIBEL="Temporary file deletion in progress"
#RMFIL "${DFILI}/${ENV_PREFIX}_ESTD3060_*.dat"
RMFIL "${DFILT}/${ENV_PREFIX}_ESIX7000_*.dat.new"

JOBEND
