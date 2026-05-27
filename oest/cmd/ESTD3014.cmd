#!/bin/ksh
#=============================================================================
# maj de l'application:           ESTIMATIONS - TRANSFERT INTER-SITES
# nom du script SHELL:            ESTD3014.cmd
# revision:                       $Revision: 1.1 $
# date de creation:               10/02/2009
# auteur:                         J.Ribot
# references des specifications : :spot:16765
#-----------------------------------------------------------------------------
# description
#
# integration des fichiers créés par ESTD3010 et des fichiers GT CURGT STAGT ARCSTATGT
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#      03/12/2009 Roger Cassis :spot:18415 -> Mise à jour parametres plus utilises
# [02] 07/07/2011 Florent      :spot:22328 ajout de 16 champs dans le GTA
# [03] 13/07/2011 Roger Cassis :spot:29223 non pas pour la retro -> annule
# [04] 19/08/2015 Roger Cassis :spot:29223 Correction du reformat de l'ARCSTATGTA et du STATGTA
# [05] 09/06/2019 SA           :spira:78240 Commented updates to $DFILP/${PCH}ESIX7000_CURGTA.dat
#                               $DFILP/${PCH}ESIX7000_ARCSTATGTA.dat, $DFILP/${PCH}ESIX7000_STATGTA.dat
#                               They have been tagged with #78240-
#
#===============================================================================
#set -x
# Call generic functions

. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Parameters
GTRETRO=${1}

# GTA

# Spira 78240 - We are adding this line as a temporary fix since the program that creates this file hasn't been changed to add the newly added fields.
cat ${DFILI}/${PCH}ESTD3010_ESTD3011_GTA_AAJOUTER_TRANSFP.dat | awk -F~ '{if (NF == 57 ) {print$0"~~~~~~~~~~~~~~"} else print $0}'  >  ${DFILT}/${PCH}ESTD3010_ESTD3011_GTA_AAJOUTER_TRANSFP_MOD.dat

NSTEP=${NJOB}_05
#
#-----------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
LIBEL="Append GTA Files "
SORT_CMD=`CFTMP`
SORT_I="${DFILP}/${PCH}ESIX7000_GTA.dat 1000 1"
#78240-SORT_I2="${DFILI}/${PCH}ESTD3010_ESTD3011_GTA_AAJOUTER_TRANSFP.dat 1000 1"
SORT_I2="${DFILT}/${PCH}ESTD3010_ESTD3011_GTA_AAJOUTER_TRANSFP_MOD.dat 1000 1"
SORT_O="${DFILT}/${PCH}ESIX7000_GTA.dat.new 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 8:1 - 8:
/KEYS CTR_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_08
# Begin Remove
#--------------------------------------------------------------------------
LIBEL="move $DFILT/${PCH}ESIX7000_GTA.dat.new $DFILP/${PCH}ESIX7000_GTA.dat"
EXECKSH "mv $DFILT/${PCH}ESIX7000_GTA.dat.new $DFILP/${PCH}ESIX7000_GTA.dat"


# CURGTA

NSTEP=${NJOB}_10
#
#-----------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
LIBEL="Append CURGTA Files "
SORT_CMD=`CFTMP`
SORT_I="${DFILP}/${PCH}ESIX7000_CURGTA.dat 1000 1"
SORT_I2="${DFILI}/${PCH}ESTD3010_ESTD3011_CURGTA_AAJOUTER_TRANSFP.dat 1000 1"
SORT_O="${DFILT}/${PCH}ESIX7000_CURGTA.dat.new 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 8:1 - 8:
/KEYS CTR_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_20
# Begin Remove
#--------------------------------------------------------------------------
LIBEL="move $DFILT/${PCH}ESIX7000_CURGTA.dat.new $DFILP/${PCH}ESIX7000_CURGTA.dat"
#78240- EXECKSH "mv $DFILT/${PCH}ESIX7000_CURGTA.dat.new $DFILP/${PCH}ESIX7000_CURGTA.dat"


NSTEP=${NJOB}_25
# Accumulation of GTAA + GTAR amounts and merge with STATGTA [02] [04]
#------------------------------------------------------------------------------
LIBEL="Accumulation of GTAA + GTAR amounts and merge with STATGTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILI}/${PCH}ESTD3010_ESTD3011_STATGTA_TRANSFP.dat 1000 1"
SORT_I2="${DFILP}/${PCH}ESIX7000_STATGTA.dat 1000 1"
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

NSTEP=${NJOB}_30
# Begin Sort
#-----------------------------------------------------------------
LIBEL="STATGTA sort"
#78240-SORT_WDIR=${SORTWORK}
#78240-SORT_CMD=`CFTMP`
#78240-SORT_I="${DFILT}/${PCH}ESIX7000_STATGTA.dat.new 1000 1"
#78240-SORT_O="${DFILP}/${PCH}ESIX7000_STATGTA.dat 1000 1"
#78240-INPUT_TEXT $SORT_CMD << EOF
#78240-/FIELDS
#78240-        CTR_NF 8:1 - 8:,
#78240-        END_NT 9:1 - 9:,
#78240-        SEC_NF 10:1 - 10:,
#78240-        UWY_NF 11:1 - 11:,
#78240-        UW_NT 12:1 - 12:,
#78240-        OCCYEA_NF 13:1 - 13:,
#78240-        ACY_NF 14:1 - 14:,
#78240-        SCOSTRMTH_NF 15:1 - 15:,
#78240-        SCOENDMTH_NF 16:1 - 16:,
#78240-        CLM_NF 17:1 - 17:,
#78240-        CUR_CF 18:1 - 18:,
#78240-        RETCTR_NF 24:1 - 24:,
#78240-        RETEND_NT 25:1 - 25:,
#78240-        RETSEC_NF 26:1 - 26:,
#78240-        RTY_NF 27:1 - 27:,
#78240-        RETUW_NT 28:1 - 28:
#78240-/KEYS
#78240-        CTR_NF ,
#78240-        END_NT ,
#78240-        SEC_NF ,
#78240-        UWY_NF ,
#78240-        UW_NT ,
#78240-        OCCYEA_NF ,
#78240-        ACY_NF ,
#78240-        SCOSTRMTH_NF ,
#78240-        SCOENDMTH_NF ,
#78240-        CLM_NF,
#78240-        CUR_CF
#78240-exit
#78240-EOF
#78240-SORT

NSTEP=${NJOB}_60
# Merge new GTA file to P_ESIX7000_ARCSTATGTA.dat [02]
#------------------------------------------------------------------------------
LIBEL="Merge new GTA file to _ESIX7000_ARCSTATGTA.dat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILP}/${PCH}ESIX7000_ARCSTATGTA.dat 1000 1"
SORT_I2="${DFILI}/${PCH}ESTD3010_ESTD3011_ARCSTATGTA_AAJOUTER_TRANSFP.dat 1000 1"
SORT_O="${DFILT}/${PCH}ESIX7000_ARCSTATGTA.dat.new 1000 1"
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
	RETINTAMT_M 41:1 - 41:EN 15/3,
	BUKRS_CF 42:1 - 42:,
	RCOMP_CF 43:1 - 43:,
	LDGRP_CF 44:1 - 44:,
	HKONT_CF 45:1 - 45:,
	DBLHKONT_CF 46:1 - 46:,
	GJAHR_NF 47:1 - 47:,
	MONAT_NF 48:1 - 48:,
	VBUND_CF 49:1 - 49:,
	ZZCED_NF 50:1 - 50:,
	SEGMENT_CF 51:1 - 51:,
	BEWAR_CF 52:1 - 52:,
	ZZGAAPDIF_CF 53:1 - 53:,
	BLART_CF 54:1 - 54:,
	ZZRECONKEY_CF 55:1 - 55:,
	TRN_NT 56:1 - 56:,
	FILETYP_CF 57:1 - 57:

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
/REFORMAT SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF, END_NT , SEC_NF, UWY_NF, UW_NT,
          OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_MC, CED_NF, BRK_NF, PAY_NF, KEY_NF, RETCTR_NF,
          RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF,
          RETCUR_CF, RETAMT_MC, PLC_NT, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, RETINTAMT_MC, BUKRS_CF, RCOMP_CF,
          LDGRP_CF, HKONT_CF, DBLHKONT_CF, GJAHR_NF, MONAT_NF,VBUND_CF, ZZCED_NF, SEGMENT_CF, BEWAR_CF, ZZGAAPDIF_CF,
          BLART_CF, ZZRECONKEY_CF, TRN_NT, FILETYP_CF
exit
EOF
SORT

NSTEP=${NJOB}_70
# Begin Remove
#--------------------------------------------------------------------------
LIBEL="move $DFILT/${PCH}ESIX7000_ARCSTATGTA.dat.new $DFILP/${PCH}ESIX7000_ARCSTATGTA.dat"
#78240-EXECKSH "mv $DFILT/${PCH}ESIX7000_ARCSTATGTA.dat.new $DFILP/${PCH}ESIX7000_ARCSTATGTA.dat"

#################    retro

if [ ${GTRETRO} = "1" ]             # on traite les fichiers retro
then

# GTR

	NSTEP=${NJOB}_72
	#
	#-----------------------------------------------------------------------------
	SORT_WDIR=${SORTWORK}
	LIBEL="Append GTR Files "
	SORT_CMD=`CFTMP`
	SORT_I="${DFILP}/${PCH}ESIX7000_GTR.dat 1000 1"
	SORT_I2="${DFILI}/${PCH}ESTD3010_ESTD3012_GTR_TRANSFP.dat 1000 1"
	SORT_O="${DFILT}/${PCH}ESIX7000_GTR.dat.new 1000 1"
	INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 8:1 - 8:
/KEYS CTR_NF
/OUTFILE ${SORT_O}
exit
EOF
	SORT

	NSTEP=${NJOB}_75
	# Begin Remove
	#--------------------------------------------------------------------------
	LIBEL="move $DFILT/${PCH}ESIX7000_GTR.dat.new $DFILP/${PCH}ESIX7000_GTR.dat"
	EXECKSH "mv $DFILT/${PCH}ESIX7000_GTR.dat.new $DFILP/${PCH}ESIX7000_GTR.dat"

	NSTEP=${NJOB}_80
	# Cat CURGTR Files
	#-----------------------------------------------------------------------------
	SORT_WDIR=${SORTWORK}
	LIBEL="Append CURGTR Files "
	SORT_CMD=`CFTMP`
	SORT_I="${DFILP}/${PCH}ESIX7000_CURGTR.dat 1000 1"
	SORT_I2="${DFILI}/${PCH}ESTD3010_ESTD3012_CURGTR_TRANSFP_CURGTR.dat 1000 1"
	SORT_O="${DFILT}/${PCH}ESIX7000_CURGTR.dat.new 1000 1"
	INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 8:1 - 8:
/KEYS CTR_NF
/OUTFILE ${SORT_O}
exit
EOF
	SORT

	NSTEP=${NJOB}_85
	# Begin Remove
	#--------------------------------------------------------------------------
	LIBEL="move $DFILT/${PCH}ESIX7000_CURGTR.dat.new $DFILP/${PCH}ESIX7000_CURGTR.dat"
	EXECKSH "mv $DFILT/${PCH}ESIX7000_CURGTR.dat.new $DFILP/${PCH}ESIX7000_CURGTR.dat"

	NSTEP=${NJOB}_90
	# Cat ARCSTATGTR Files [02] [03]
	#-----------------------------------------------------------------------------
	SORT_WDIR=${SORTWORK}
	LIBEL="Append ARCSTATGTR Files "
	SORT_CMD=`CFTMP`
	SORT_I="${DFILP}/${PCH}ESIX7000_ARCSTATGTR.dat 1000 1"
	SORT_I2="${DFILI}/${PCH}ESTD3010_ESTD3012_ARCSTATGTR_TRANSFP_ARCSTATGTR.dat 1000 1"
	SORT_O="${DFILT}/${PCH}ESIX7000_ARCSTATGTR.dat.new"
	INPUT_TEXT $SORT_CMD <<EOF
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
	RETKEY_CF 40:1 - 40:
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
/SUMMARIZE  TOTAL AMT_M , TOTAL RETAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD SEPA "~"
/DERIVEDFIELD ZERO "0.000" CHAR 5
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF, END_NT , SEC_NF, UWY_NF, UW_NT,
          OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_MC, CED_NF, BRK_NF, PAY_NF, KEY_NF, RETCTR_NF, RETEND_NT,
          RETSEC_NF, RTY_NF, RETUW_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, RETCUR_CF, RETAMT_MC,
          PLC_NT, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, SEPA, ZERO
exit
EOF
	SORT

	NSTEP=${NJOB}_100
	# Begin Remove
	#--------------------------------------------------------------------------
	LIBEL="move $DFILT/${PCH}ESIX7000_ARCSTATGTR.dat.new $DFILP/${PCH}ESIX7000_ARCSTATGTR.dat"
	EXECKSH "mv $DFILT/${PCH}ESIX7000_ARCSTATGTR.dat.new $DFILP/${PCH}ESIX7000_ARCSTATGTR.dat"

	## STATGTR

	NSTEP=${NJOB}_120
	# Begin Sort
	#-----------------------------------------------------------------
	LIBEL="STATGTR sort"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I=${DFILI}/${PCH}ESTD3010_ESTD3012_STATGTR_TRANSFP_STATGTR.dat
	SORT_I2=${DFILP}/${PCH}ESIX7000_STATGTR.dat
	SORT_O=${DFILT}/${PCH}ESIX7000_STATGTR.dat.new
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

	NSTEP=${NJOB}_130
	# Begin Remove
	#--------------------------------------------------------------------------
	LIBEL="move $DFILT/${PCH}ESIX7000_STATGTR.dat.new $DFILP/${PCH}ESIX7000_STATGTR.dat"
	EXECKSH "mv $DFILT/${PCH}ESIX7000_STATGTR.dat.new $DFILP/${PCH}ESIX7000_STATGTR.dat"

fi

###############  fin retro

NSTEP=${NJOB}_140
#Temporary file deletion
#------------------------------------------------
LIBEL="Temporary file deletion in progress"
#RMFIL "${DFILI}/${PCH}ESTD3010_*.dat"
#RMFIL "${DFILT}/${PCH}ESIX7000_*.dat.new"

JOBEND
