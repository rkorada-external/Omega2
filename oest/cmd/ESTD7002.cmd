#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 reprise des fichiers GT
# nom du script SHELL           : ESTD7002.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 04/03/03
# auteur                        : J.Ribot
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Update estimates
#
# job launched by ESTM7000.cmd
#-----------------------------------------------------------------------------
# historique des modifications
#
#=============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Entry parameters

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_01
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="cumul placements"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_FPLATXCUM.dat
BCP_QRY="execute BRET..PsPLACEMT_35"
BCP

NSTEP=${NJOB}_05
#GTA merge and sort
#-----------------------------------------------------------------------------
LIBEL="GTA SORT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${PCH}ESIX7000_GTA.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTA.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETSEC_NF 26:1 - 26: EN,
        RTY_NF 27:1 - 27:,
        PLC_NT 36:1 - 36:EN
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      PLC_NT
exit
EOF
SORT

NSTEP=${NJOB}_10
# Prog affectation retro interne
#-----------------------------------------------------------------------------
LIBEL="Prog affectation retro interne"
PRG=RETM0532
export ${PRG}_I1=${DFILT}/${NJOB}_01_${IB}_FPLATXCUM.dat
export ${PRG}_I2=${DFILT}/${NJOB}_05_${IB}_SORT_GTA.dat
export ${PRG}_O1=${DFILP}/${PCH}ESIX7000_GTA.dat
EXECPRG


NSTEP=${NJOB}_15
#Temporary file deletion
LIBEL="Temporary file deletion in progress"
RMFIL ${DFILT}/${NJOB}_05_${IB}_SORT_GTA.dat

NSTEP=${NJOB}_20
#GTR merge and sort
#-----------------------------------------------------------------------------
LIBEL="GTR SORT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${PCH}ESIX7000_GTR.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTR.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETSEC_NF 26:1 - 26: EN,
        RTY_NF 27:1 - 27:,
        PLC_NT 36:1 - 36:EN
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      PLC_NT
exit
EOF
SORT

NSTEP=${NJOB}_25
# Prog affectation retro interne
#-----------------------------------------------------------------------------
LIBEL="Prog affectation retro interne"
PRG=RETM0532
export ${PRG}_I1=${DFILT}/${NJOB}_01_${IB}_FPLATXCUM.dat
export ${PRG}_I2=${DFILT}/${NJOB}_20_${IB}_SORT_GTR.dat
export ${PRG}_O1=${DFILP}/${PCH}ESIX7000_GTR.dat
EXECPRG

NSTEP=${NJOB}_30
#Temporary file deletion
LIBEL="Temporary file deletion in progress"
RMFIL ${DFILT}/${NJOB}_20_${IB}_SORT_GTR.dat

NSTEP=${NJOB}_35
#CURGTA merge and sort
#-----------------------------------------------------------------------------
LIBEL="CURGTA SORT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${PCH}ESIX7000_CURGTA.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CURGTA.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETSEC_NF 26:1 - 26: EN,
        RTY_NF 27:1 - 27:,
        PLC_NT 36:1 - 36:EN
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      PLC_NT
exit
EOF
SORT

NSTEP=${NJOB}_40
# Prog affectation retro interne
#-----------------------------------------------------------------------------
LIBEL="Prog affectation retro interne"
PRG=RETM0532
export ${PRG}_I1=${DFILT}/${NJOB}_01_${IB}_FPLATXCUM.dat
export ${PRG}_I2=${DFILT}/${NJOB}_35_${IB}_SORT_CURGTA.dat
export ${PRG}_O1=${DFILP}/${PCH}ESIX7000_CURGTA.dat
EXECPRG


NSTEP=${NJOB}_45
#Temporary file deletion
LIBEL="Temporary file deletion in progress"
RMFIL ${DFILT}/${NJOB}_35_${IB}_SORT_CURGTA.dat

NSTEP=${NJOB}_50
#CURGTR merge and sort
#-----------------------------------------------------------------------------
LIBEL="CURGTR SORT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${PCH}ESIX7000_CURGTR.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CURGTR.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETSEC_NF 26:1 - 26: EN,
        RTY_NF 27:1 - 27:,
        PLC_NT 36:1 - 36:EN
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      PLC_NT
exit
EOF
SORT

NSTEP=${NJOB}_55
# Prog affectation retro interne
#-----------------------------------------------------------------------------
LIBEL="Prog affectation retro interne"
PRG=RETM0532
export ${PRG}_I1=${DFILT}/${NJOB}_01_${IB}_FPLATXCUM.dat
export ${PRG}_I2=${DFILT}/${NJOB}_50_${IB}_SORT_CURGTR.dat
export ${PRG}_O1=${DFILP}/${PCH}ESIX7000_CURGTR.dat
EXECPRG


NSTEP=${NJOB}_60
#Temporary file deletion
LIBEL="Temporary file deletion in progress"
RMFIL ${DFILT}/${NJOB}_50_${IB}_SORT_CURGTR.dat

NSTEP=${NJOB}_65
#STATGTA merge and sort
#-----------------------------------------------------------------------------
LIBEL="STATGTA SORT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${PCH}ESIX7000_STATGTA.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_STATGTA.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETSEC_NF 26:1 - 26: EN,
        RTY_NF 27:1 - 27:,
        PLC_NT 36:1 - 36:EN
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      PLC_NT
exit
EOF
SORT

NSTEP=${NJOB}_70
# Prog affectation retro interne
#-----------------------------------------------------------------------------
LIBEL="Prog affectation retro interne"
PRG=RETM0532
export ${PRG}_I1=${DFILT}/${NJOB}_01_${IB}_FPLATXCUM.dat
export ${PRG}_I2=${DFILT}/${NJOB}_65_${IB}_SORT_STATGTA.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_RETM0532_STATGTA.dat
EXECPRG

NSTEP=${NJOB}_72
#Temporary file deletion
LIBEL="Temporary file deletion in progress"
RMFIL ${DFILT}/${NJOB}_65_${IB}_SORT_STATGTA.dat

NSTEP=${NJOB}_75
# Begin Sort
#------------------------------------------------------------------------------
LIBEL="EST_STATGTA SORT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_70_${IB}_RETM0532_STATGTA.dat
SORT_O=${DFILP}/${PCH}ESIX7000_STATGTA.dat
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
        RETINTAMT_M 41:1 - 41:EN 15/3
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
exit
EOF
SORT

NSTEP=${NJOB}_77
#Temporary file deletion
LIBEL="Temporary file deletion in progress"
RMFIL ${DFILT}/${NJOB}_70_${IB}_RETM0532_STATGTA.dat

NSTEP=${NJOB}_80
#STATGTR merge and sort
#-----------------------------------------------------------------------------
LIBEL="CURGTA SORT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${PCH}ESIX7000_STATGTR.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_STATGTR.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETSEC_NF 26:1 - 26: EN,
        RTY_NF 27:1 - 27:,
        PLC_NT 36:1 - 36:EN
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      PLC_NT
exit
EOF
SORT

NSTEP=${NJOB}_85
# Prog affectation retro interne
#-----------------------------------------------------------------------------
LIBEL="Prog affectation retro interne"
PRG=RETM0532
export ${PRG}_I1=${DFILT}/${NJOB}_01_${IB}_FPLATXCUM.dat
export ${PRG}_I2=${DFILT}/${NJOB}_80_${IB}_SORT_STATGTR.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_RETM0532_STATGTR.dat
EXECPRG


NSTEP=${NJOB}_87
#Temporary file deletion
LIBEL="Temporary file deletion in progress"
RMFIL ${DFILT}/${NJOB}_80_${IB}_SORT_STATGTR.dat
RMFIL ${DFILT}/${NJOB}_01_${IB}_FPLATXCUM.dat

NSTEP=${NJOB}_90
# Begin Sort
#-----------------------------------------------------------------
LIBEL="EST_STATGTR sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_85_${IB}_RETM0532_STATGTR.dat
SORT_O=${DFILP}/${PCH}ESIX7000_STATGTR.dat
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
	RETCTR_NF 24:1 - 24:,
	RETEND_NT 25:1 - 25:,
	RETSEC_NF 26:1 - 26:,
	RTY_NF 27:1 - 27:,
	RETUW_NT 28:1 - 28:
/KEYS
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF ,
	RETUW_NT
exit
EOF
SORT

NSTEP=${NJOB}_92
#Temporary file deletion
LIBEL="Temporary file deletion in progress"
RMFIL ${DFILT}/${NJOB}_85_${IB}_RETM0532_STATGTR.dat

NSTEP=${NJOB}_95
#Sort of ARCSTATGTA
#-----------------------------------------------------------------------------
LIBEL="Sort AND Refrormat  ARCSTATGTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${PCH}ESIX7000_ARCSTATGTA.dat
SORT_O=${DFILP}/${PCH}ESIX7000_ARCSTATGTA.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:EN,
        ESB_CF 2:1 - 2:EN,
        BALSHEY_NF 3:1 - 3:EN,
        BALSHRMTH_NF 4:1 - 4:EN,
        BALSHRDAY_NF 5:1 - 5:EN,
        TRNCOD_CF 6:1 - 6:,
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
        AMT_M 19:1 - 19:,
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
        RETAMT_M 35:1 - 35:,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:
/OUTFILE ${SORT_O}
/DERIVEDFIELD ZERO "0.000" CHAR 5
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
	CUR_CF
/REFORMAT SSD_CF,
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
        AMT_M,
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
        RETAMT_M,
        PLC_NT,
        RTO_NF,
        INT_NF,
        RETPAY_NF,
        RETKEY_CF,
        ZERO
exit
EOF
SORT

NSTEP=${NJOB}_100
#Sort of ARCSTATGTR
#-----------------------------------------------------------------------------
LIBEL="Sort AND Refrormat  ARCSTATGTR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${PCH}ESIX7000_ARCSTATGTR.dat
SORT_O=${DFILP}/${PCH}ESIX7000_ARCSTATGTR.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:EN,
        ESB_CF 2:1 - 2:EN,
        BALSHEY_NF 3:1 - 3:EN,
        BALSHRMTH_NF 4:1 - 4:EN,
        BALSHRDAY_NF 5:1 - 5:EN,
        TRNCOD_CF 6:1 - 6:,
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
        AMT_M 19:1 - 19:,
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
        RETAMT_M 35:1 - 35:,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:
/OUTFILE ${SORT_O}
/DERIVEDFIELD ZERO "0.000" CHAR 5
/KEYS
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF ,
	RETUW_NT
/REFORMAT SSD_CF,
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
        AMT_M,
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
        RETAMT_M,
        PLC_NT,
        RTO_NF,
        INT_NF,
        RETPAY_NF,
        RETKEY_CF,
        ZERO
exit
EOF
SORT

JOBEND
