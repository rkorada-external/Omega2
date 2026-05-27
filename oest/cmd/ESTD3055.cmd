#!/bin/ksh
#=============================================================================
# maj de l'application:           ESTIMATIONS - TRANSFERT INTER-SITES (PORTEFEUILLES)
# nom du script SHELL:            ESTD3055.cmd
# revision:                       $Revision: 1.1.1.1 $
# date de creation:               10/02/2009
# auteur:                         J.Ribot
# references des specifications : :spot:16765
#-----------------------------------------------------------------------------
# description
#
# integration des retraits portefeuilles
#
#-----------------------------------------------------------------------------
# historiques des modifications :
# [01] 15/06/2009 Roger Cassis :spot:17532 Si pas de donnees a extraire on stoppe le job sans Abort
# [02] 07/07/2011 Florent      :spot:22328 ajout de 16 champs dans le GTA
# [03] 19/08/2015 Roger Cassis :spot:29223 Correction du reformat des GT pour Omega 2
#
#===============================================================================
#set -x

# Call generic functions

. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Parameters

# GTA

if [ ! -s "${DFILT}/${PCH}ESTD3050_ESTD3051_GTA_TRANSFP.dat" ] &&
   [ ! -s "${DFILT}/${PCH}ESTD3050_ESTD3051_CURGTA_TRANSFP.dat" ]
then
  ECHO_LOG "---> No Data to process because Input files are empty - Stop processing"
  JOBEND
fi

NSTEP=${NJOB}_05
#
#-----------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
LIBEL="Append GTA Files "
SORT_CMD=`CFTMP`
SORT_I="${DFILP}/${PCH}ESIX7000_GTA.dat 1000 1"
SORT_I2="${DFILI}/${PCH}ESTD3050_ESTD3053_GTA_AAJOUTER_TRANSFP_RETRAIT.dat 1000 1"
SORT_O="${DFILT}/${PCH}ESIX7000_GTA.dat.new 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 8:1 - 8:
/KEYS CTR_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_10
#
#-----------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
LIBEL="Append CURGTA Files "
SORT_CMD=`CFTMP`
SORT_I="${DFILP}/${PCH}ESIX7000_CURGTA.dat 1000 1"
SORT_I2="${DFILI}/${PCH}ESTD3050_ESTD3053_CURGTA_AAJOUTER_TRANSFP_RETRAIT.dat 1000 1"
SORT_O="${DFILT}/${PCH}ESIX7000_CURGTA.dat.new 1000 1"
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
SORT_I="${DFILP}/${PCH}ESIX7000_STATGTA.dat 1000 1"
SORT_I2="${DFILI}/${PCH}ESTD3050_ESTD3053_STATGTA_AAJOUTER_TRANSFP_RETRAIT.dat 1000 1"
SORT_O="${DFILT}/${PCH}ESIX7000_STATGTA.dat.new 1000 1"
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

NSTEP=${NJOB}_20
# Begin Remove
#--------------------------------------------------------------------------
LIBEL="move $DFILT/${PCH}ESIX7000_GTA.dat.new $DFILP/${PCH}ESIX7000_GTA.dat"
EXECKSH "mv $DFILT/${PCH}ESIX7000_GTA.dat.new $DFILP/${PCH}ESIX7000_GTA.dat"

NSTEP=${NJOB}_25
# Begin Remove
#--------------------------------------------------------------------------
LIBEL="move $DFILT/${PCH}ESIX7000_CURGTA.dat.new $DFILP/${PCH}ESIX7000_CURGTA.dat"
EXECKSH "mv $DFILT/${PCH}ESIX7000_CURGTA.dat.new $DFILP/${PCH}ESIX7000_CURGTA.dat"

NSTEP=${NJOB}_30
# Begin Remove
#--------------------------------------------------------------------------
LIBEL="move $DFILT/${PCH}ESIX7000_STATGTA.dat.new $DFILP/${PCH}ESIX7000_STATGTA.dat"
EXECKSH "mv $DFILT/${PCH}ESIX7000_STATGTA.dat.new $DFILP/${PCH}ESIX7000_STATGTA.dat"

NSTEP=${NJOB}_35
#Temporary file deletion
#------------------------------------------------
LIBEL="Temporary file deletion in progress"
RMFIL "${DFILT}/${PCH}ESTD3050_*.dat"
RMFIL "${DFILT}/${PCH}ESIX7000_*.dat.new"

JOBEND
