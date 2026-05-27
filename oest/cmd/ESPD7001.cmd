#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Chaine generation des mouvements
#                                 comptables pour People Soft ecriture post omega
# nom du script SHELL           : ESPD7001.cmd
# revision                      :
# date de creation              : 29/06/2005
# auteur                        : J. Ribot
# references des specifications : SPOT 5085
#-----------------------------------------------------------------------------
# description
#   Update estimates
#
# job launched by ESPD7000.cmd
#-----------------------------------------------------------------------------
# historique des modifications
#_________________
#MODIFICATION    [001]
#Auteur:         D.GATIBELZA
#Date:           23/12/2009
#Version:        9.1
#Description:    ESTVIE18710 Alimentation du MGTAR lors de la comptabilisation de l'arrêté pour la réallocation asie
#_________________
#MODIFICATION    [002]
#Auteur:         D.GATIBELZA
#Date:           29/03/2010
#Version:        10.1
#Description:    ESTDOM19222 Interface Retro Omega PeopleSoft
#[003] 20/06/2013 R. Cassis :spot:25305 Prise en compte des fichiers de rétro interne + :spot:25427 - remise à niveau
#[004] 29/04/2019 R. Cassis :spira:65656 rename fichier EPO_DLRGTAA en EPO_DLRGTAASO
#[005] 05/12/2019 JYP: spira 83498 : bugfix migration ESPD7000 in new archi
#=============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
BOOKING_D=$1
CONSOYEA=$2
CONSOMTH=$3
CRE_D=$4
DBCLO_D=$5

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_01
# RM FILE
#-----------------------------------------------------------------
LIBEL="RM of the permanent files"
RMFIL "${DFILP}/${PCH}ESPD7000_CMGTAA_${BOOKING_D}_*.dat"
RMFIL "${DFILP}/${PCH}ESPD7000_CMGTAR_${BOOKING_D}_*.dat"
RMFIL "${DFILP}/${PCH}ESPD7000_CMGTR_${BOOKING_D}_*.dat"

NSTEP=${NJOB}_05
# Begin sort
#[001]
#[002] Ajout filiale 22
#[003][004]
#----------------------------------------------------------------------------
LIBEL="Split GTA + CURGTA ==> delta(CURGTA), DLTOTGTAAC, DLTOGTARC, GTA-CURGTA, GTAA, GTAAR "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_DLSGTAASO} 1000 1"
SORT_I2="${EPO_DLRGTAASO} 1000 1"
SORT_I3="${EPO_DLSGTARSO} 1000 1"
SORT_I4="${EPO_DLREGTARSO} 1000 1"
SORT_I5="${EPO_DLREMAJGTARSO} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CMGTAASO_O1.dat"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_CMGTARSO_O2.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF      1:1 - 1:,
        BALSHEY     3:1 - 3: EN,
        BALSHTMTH   4:1 - 4: EN,
        TRNCOD_CF   6:1 - 6:,
        TRNCOD1_CF  6:1 - 6:1 ,
        TRNCOD2C_CF 6:2 - 6:2 ,
        TRNCOD8_CF  6:8 - 6:8 EN
/CONDITION COND_CMGTAA ( BALSHEY = ${CONSOYEA} and BALSHTMTH <= ${CONSOMTH})    AND
                       ( TRNCOD1_CF = "1" or TRNCOD1_CF = "3")
/CONDITION COND_CMGTAR ( ( BALSHEY = ${CONSOYEA} and BALSHTMTH <= ${CONSOMTH})  AND
                         ( TRNCOD1_CF EQ "4" OR TRNCOD1_CF EQ "2")              AND
                         ( SSD_CF EQ "2"  OR  SSD_CF EQ "4" OR SSD_CF EQ "20"  OR SSD_CF EQ "22" )  )
/OUTFILE ${SORT_O}
/INCLUDE COND_CMGTAA

/OUTFILE ${SORT_O2}
/INCLUDE COND_CMGTAR

/COPY
exit
EOF
SORT

NSTEP=${NJOB}_10
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Sort of CMGTAR_O"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_CMGTARSO_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CMGTARSO_O.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:
/KEYS CTR_NF,
      END_NT,
      UWY_NF,
      UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_15
# Begin C Program
#----------------------------------------------------------------------------
LIBEL="  CMGTAR  modifications"
PRG=ESTM2563
export ${PRG}_I1=${EPO_CADVPERIESB0}
export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_SORT_CMGTARSO_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_ESTM2563_CMGTARSO_O.dat
EXECPRG

NSTEP=${NJOB}_20
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Split GTA + DLTOTGTAR ==> MGTARSO "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_ESTM2563_CMGTARSO_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CMGTARSO_O1.dat"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
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
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
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
             RETKEY_CF
exit
EOF
SORT

#[003]
NSTEP=${NJOB}_25
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Split GTR ==> CMGTRSO "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_DLSGTRSO} 1000 1"
SORT_I2="${EPO_DLREGTRSO} 1000 1"
SORT_I3="${EPO_DLREMAJGTRSO} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_CMGTRSO_O.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS BALSHEY  3:1 - 3: EN,
	BALSHTMTH  4:1 - 4: EN,
	TRNCOD_CF 6:1 - 6:,
		TRNCOD1_CF 6:1 - 6:1,
		TRNCOD2C_CF 6:2 - 6:2 ,
		TRNCOD8_CF 6:8 - 6:8 EN
/CONDITION AVANT_PERIODE	( BALSHEY = ${CONSOYEA} and BALSHTMTH <= ${CONSOMTH})
/OUTFILE ${SORT_O}
/INCLUDE AVANT_PERIODE
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_30
# Begin sort
#------------------------------------------------------------------------------
LIBEL="SORT CURGTR "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25_${IB}_SORT_CMGTRSO_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CMGTRSO_O.dat"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
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
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
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
             RETKEY_CF
exit
EOF
SORT

NSTEP=${NJOB}_35
# Inversion of estimates  amounts before using
#-----------------------------------------------------------------------------
LIBEL="Inversion of amounts to calculate Delta amounts"
AWK_I=${EPO_CMGTAASO}
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_CMGTAASO_PRECED.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
       { if ( \$19 != 0 ) \$19 = sprintf("%-.3lf",-\$19);
         if ( \$35 != 0 ) \$35 = sprintf("%-.3lf",-\$35);
            ; print \$0 }
exit
EOF
AWK

NSTEP=${NJOB}_40
# Inversion of estimates amounts before using
#-----------------------------------------------------------------------------
LIBEL="Inversion of amounts to calculate Delta amounts"
AWK_I=${EPO_CMGTARSO}
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_CMGTARSO_PRECED.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
       { if ( \$19 != 0 ) \$19 = sprintf("%-.3lf",-\$19);
         if ( \$35 != 0 ) \$35 = sprintf("%-.3lf",-\$35);
            ; print \$0 }
exit
EOF
AWK

NSTEP=${NJOB}_45
# Inversion of estimates amounts before using
#-----------------------------------------------------------------------------
LIBEL="Inversion of amounts to calculate Delta amounts"
AWK_I=${EPO_CMGTRSO}
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_CMGTRSO_PRECED.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
       { if ( \$19 != 0 ) \$19 = sprintf("%-.3lf",-\$19);
         if ( \$35 != 0 ) \$35 = sprintf("%-.3lf",-\$35);
            ; print \$0 }
exit
EOF
AWK

NSTEP=${NJOB}_50
# Begin sort
#------------------------------------------------------------------------------
LIBEL="SUM old MGTAASO + new MGTAASO ==> DELTA CMGTAA for people soft"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_CMGTAASO_O1.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_35_${IB}_AWK_CMGTAASO_PRECED.dat 1000 1"
SORT_O=${EPO_CMGTAA}
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS FILLER1 1:1 - 18:,
        FILLER2 20:1 - 41:,
        ESB_CF 2:1 - 2:,
        TRNCOD_CF 6:1 - 6:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        ACY_NF 14:1 - 14:,
       	CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19:EN 15/3
/KEYS ESB_CF, TRNCOD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, ACY_NF, CUR_CF
/SUMMARIZE  TOTAL AMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT FILLER1, AMT_MC, FILLER2
exit
EOF
SORT

NSTEP=${NJOB}_60
# Begin sort
#------------------------------------------------------------------------------
LIBEL="SUM old MGTARSO + new MGTARSO ==> DELTA CMGTAR for people soft"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_CMGTARSO_O1.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_40_${IB}_AWK_CMGTARSO_PRECED.dat 1000 1"
SORT_O=${EPO_CMGTAR}
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS FILLER1 1:1 - 18:,
        FILLER2 20:1 - 34:,
        FILLER3 36:1 - 40:,
        SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
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
        RETAMT_M 35:1 - 35:EN 15/3
/KEYS ESB_CF, TRNCOD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, ACY_NF, CUR_CF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT,
      RETACY_NF, RETCUR_CF
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT FILLER1, AMT_MC, FILLER2, RETAMT_MC, FILLER3
exit
EOF
SORT

NSTEP=${NJOB}_70
# Begin sort
#------------------------------------------------------------------------------
LIBEL="SUM old MGTRSO + new MGTRSO ==> DELTA CMGTR for people soft"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_SORT_CMGTRSO_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_45_${IB}_AWK_CMGTRSO_PRECED.dat 1000 1"
SORT_O=${EPO_CMGTR}
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS FILLER1 1:1 - 34:,
        FILLER2 36:1 - 40:,
        ESB_CF 2:1 - 2:,
        TRNCOD_CF 6:1 - 6:,
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
        RETAMT_M 35:1 - 35:EN 15/3
/KEYS ESB_CF, TRNCOD_CF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT,
      RETACY_NF, RETCUR_CF
/SUMMARIZE  TOTAL RETAMT_M
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT FILLER1, RETAMT_MC, FILLER2
exit
EOF
SORT

NSTEP=${NJOB}_80
# Begin sort
#------------------------------------------------------------------------------
LIBEL="create new reference file "
EXECKSH "cp ${DFILT}/${NJOB}_05_${IB}_SORT_CMGTAASO_O1.dat ${EPO_CMGTAASO}"
EXECKSH "cp ${DFILT}/${NJOB}_20_${IB}_SORT_CMGTARSO_O1.dat ${EPO_CMGTARSO}"
EXECKSH "cp ${DFILT}/${NJOB}_30_${IB}_SORT_CMGTRSO_O.dat  ${EPO_CMGTRSO}"

NSTEP=${NJOB}_85
# Begin EXECKSH
#------------------------------------------------------------------------------
LIBEL="save DELTA file"
#------------------------------------------------------------------------------
export CLOPRD=`printf "%04d%02d" ${CONSOYEA} ${CONSOMTH}`

ECHO_LOG "cp ${EPO_CMGTAA}  ${DFILP}/${PCH}ESPD7000_${CLOPRD}_CMGTAA_${BOOKING_D}_${CLOPRD}_${DBCLO_D}_${CRE_D}.dat"
cp ${EPO_CMGTAA}  ${DFILP}/${PCH}ESPD7000_${CLOPRD}_CMGTAA_${BOOKING_D}_${CLOPRD}_${DBCLO_D}_${CRE_D}.dat

ECHO_LOG "cp ${EPO_CMGTAR}  ${DFILP}/${PCH}ESPD7000_${CLOPRD}_CMGTAR_${BOOKING_D}_${CLOPRD}_${DBCLO_D}_${CRE_D}.dat"
cp ${EPO_CMGTAR}  ${DFILP}/${PCH}ESPD7000_${CLOPRD}_CMGTAR_${BOOKING_D}_${CLOPRD}_${DBCLO_D}_${CRE_D}.dat

ECHO_LOG "cp ${EPO_CMGTR}   ${DFILP}/${PCH}ESPD7000_${CLOPRD}_CMGTR_${BOOKING_D}_${CLOPRD}_${DBCLO_D}_${CRE_D}.dat"
cp ${EPO_CMGTR}   ${DFILP}/${PCH}ESPD7000_${CLOPRD}_CMGTR_${BOOKING_D}_${CLOPRD}_${DBCLO_D}_${CRE_D}.dat




########################
# Erase temporary files #
########################

NSTEP=${NJOB}_90
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"

JOBEND
