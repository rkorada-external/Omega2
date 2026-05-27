#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Mise a jour des previsions
# nom du script SHELL           : ESID7003.cmd
# revision                      : $Revision: 1.0 $
# date de creation              : 26/05/97
# auteur                        : Roger Cassis
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#   :spot:21408 - Traitement double de mise à jour du CURGTA sur ancien format de fichier pour controle
#
# job launched by ESID7000.cmd
#-----------------------------------------------------------------------------
# historique des modifications
#     jj/mm/aaaa  Name
#[01] 04/02/2015  Cyrille DESPRET :spot:28211 - Test du dernier caractère du poste comptable en numérique. Depuis la version 2C, le GAAP est un caractere sur la position 8 du poste
#[03] 16/02/2016  Florent         :spot:29066 - formatage du fichier GT
#[04] 07/07/2017  Roger           :spira:62999 Saisie taille de records dans tri.
#===================================================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
BALSHEYEA=$1
BALSHTMTH=$2

# Job Initialisation
JOBINIT

export BALSHEYEAS=$((${BALSHEYEA}+1))

NSTEP=${NJOB}_05
# Begin sort
#[001] TRNCOD8_CF no more EN
#[001] TRNCOD8_CF  = 0 or TRNCOD8_CF  = 1 -> TRNCOD8_CF  = "0"           or      TRNCOD8_CF  = "1"
#----------------------------------------------------------------------------
LIBEL="Split GTACTL + CURGTA ==> delta(CURGTA), DLTOTGTAAC, DLTOGTARC, GTA-CURGTA, GTAA, GTAAR "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_GTACTL} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_CURGTA_O1.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_GTAA_O2.dat
SORT_O3=${DFILT}/${NSTEP}_${IB}_SORT_GTAR_O3.dat
SORT_O4=${DFILT}/${NSTEP}_${IB}_SORT_GTA_O4.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS REDUCTION1   1:1 - 6:,
        SSD_CF       1:1 - 1:,
        ESB_CF       2:1 - 2:,
        BALSHEY      3:1 - 3: EN,
        BALSHTMTH    4:1 - 4: EN,
        TRNCOD_CF    6:1 - 6:,
        TRNCOD1_CF   6:1 - 6:1,
        TRNCOD2C_CF  6:2 - 6:2,
        TRNCOD3      6:3 - 6:3,
        TRNCOD8_CF   6:8 - 6:8,
        REDUCTION2   7:1 - 71:
/CONDITION AVANT_PERIODE 	    ( BALSHEY = ${BALSHEYEA}    and     BALSHTMTH <= ${BALSHTMTH} )
/CONDITION AVANT_PERIODE_ACC 	 ( BALSHEY = ${BALSHEYEA}    and     BALSHTMTH <= ${BALSHTMTH} )     AND
                                ( TRNCOD1_CF = "1"          or      TRNCOD1_CF = "3" )             AND
                                ( TRNCOD8_CF  = "0"           or      TRNCOD8_CF  = "1"  )
/CONDITION AVANT_PERIODE_RETRO ( BALSHEY = ${BALSHEYEA}    and     BALSHTMTH <= ${BALSHTMTH} )     AND
                                ( TRNCOD1_CF = "2"          or      TRNCOD1_CF = "4" )             AND
                                ( TRNCOD8_CF  = "0"           or      TRNCOD8_CF  = "1" )
/CONDITION APRES_PERIODE	    BALSHEY > ${BALSHEYEA}      or
                                ( BALSHEY = ${BALSHEYEA}    and     BALSHTMTH > ${BALSHTMTH} )
/OUTFILE ${SORT_O}
/INCLUDE AVANT_PERIODE
/REFORMAT REDUCTION1, REDUCTION2
/OUTFILE ${SORT_O2}
/INCLUDE AVANT_PERIODE_ACC
/REFORMAT REDUCTION1, REDUCTION2
/OUTFILE ${SORT_O3}
/INCLUDE AVANT_PERIODE_RETRO
/REFORMAT REDUCTION1, REDUCTION2
/OUTFILE ${SORT_O4}
/INCLUDE APRES_PERIODE
/REFORMAT REDUCTION1, REDUCTION2
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_06
# Begin sort
#------------------------------------------------------------------------------
LIBEL="move GTA ==> GTACTL"
EXECKSH "mv ${DFILT}/${NJOB}_05_${IB}_SORT_GTA_O4.dat ${EST_GTACTL}"

NSTEP=${NJOB}_10
# Begin Sort
#-----------------------------------------------------------------
LIBEL="APPEND CURGTACTL"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_CURGTA_O1.dat 1000 1"
SORT_O="${EST_CURGTACTL} APPEND"
INPUT_TEXT $SORT_CMD << EOF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_15
# Begin Sort
#-----------------------------------------------------------------
LIBEL="APPEND CURGTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_GTAR_O3.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR_O1.dat"
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

NSTEP=${NJOB}_20
#Dividing of STATGTR in retrocession by acceptance life and non-life
#-----------------------------------------------------------------------------
LIBEL="Eliminating Non-life transactions of GTAR"
PRG=ESTM7606
export ${PRG}_I1=${DFILT}/${NJOB}_15_${IB}_SORT_GTAR_O1.dat
export ${PRG}_I2=${EST_CRVPERICASE0}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DGTR_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR_O2.dat
export ${PRG}_O3=${EST_GTRANO}
EXECPRG

#[04]
NSTEP=${NJOB}_25
# Accumulation of GTAA + GTAR amounts and merge with STATGTA
#[001] TRNCOD8_CF no more EN
#------------------------------------------------------------------------------
LIBEL="Accumulation of GTAA + GTAR amounts and merge with STATGTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_GTAA_O2.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_20_${IB}_ESTM7606_GTAR_O2.dat 1000 1"
SORT_I3="${EST_STATGTACTL} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_STATGTA_O.dat 1000 1"
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
        FILLER_30_COLS 42:1 - 71:
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
/SUMMARIZE  TOTAL AMT_M , TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF, END_NT , SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_MC, CED_NF, BRK_NF, PAY_NF, KEY_NF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, RETCUR_CF, RETAMT_MC, PLC_NT, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, RETINTAMT_MC, FILLER_30_COLS
exit
EOF
SORT

NSTEP=${NJOB}_30
# Begin Sort
#-----------------------------------------------------------------
LIBEL="STATGTA sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25_${IB}_SORT_STATGTA_O.dat 1000 1"
SORT_O="${EST_STATGTACTL} OVERWRITE"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
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
	RETCTR_NF 24:1 - 24:,
	RETEND_NT 25:1 - 25:,
	RETSEC_NF 26:1 - 26:,
	RTY_NF 27:1 - 27:,
	RETUW_NT 28:1 - 28:
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
exit
EOF
SORT


########################
# Erase temporary files #
########################

NSTEP=${NJOB}_35
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"

JOBEND
